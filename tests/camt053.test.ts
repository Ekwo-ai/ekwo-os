import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { validateXML } from 'xmllint-wasm';
import { readCamt053 } from '@ekwo-ai/camt053';
import { asUser, freshDatabase, one, repoRoot, rows } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { replayScenario } from './helpers/golden-scenario.js';
import { packsWhere } from './helpers/packs.js';

/**
 * Where a file a bank sends and an invoice that is still open meet.
 *
 * The chain: a country pack's golden year of books, through the real engine;
 * then a statement — invented, in the currency the company keeps its books in,
 * valid against the schema ISO publishes — read by the brick, imported by
 * `import_bank_statement()` **as the owner, under row level security**, and
 * handed to `auto_settle()`, which has to find the invoice the customer paid
 * from nothing but what the statement says.
 *
 * Every pack that names `camt.053` among the statements its banks send is
 * walked, and none is named: the format is the pack's claim, and this is where
 * the claim is exercised. The account is identified the way ISO 20022 lets an
 * account without an IBAN be — `Othr/Id` — because a test that built an IBAN
 * would be deciding, for every pack, that its country has one.
 */

const packs = packsWhere('names camt.053 among the statements its banks send', (pack) =>
  pack.documents.bank_statement_formats.includes('camt.053'),
);

const NAMESPACE = 'urn:iso:std:iso:20022:tech:xsd:camt.053.001.08';
const xsd = readFileSync(
  join(repoRoot, 'packages', 'formats', 'camt053', 'test', 'xsd', 'camt.053.001.08.xsd'),
);
const ACCOUNT = '0000123456';

async function schemaErrors(xml: string): Promise<string[]> {
  const result = await validateXML({
    xml: [{ fileName: 'statement.xml', contents: xml }],
    schema: [{ fileName: 'camt.053.001.08.xsd', contents: xsd }],
  });
  return result.errors.map((error) => error.message);
}

interface Open {
  document_id: string;
  amount_open: string;
  reference: string;
  contact: string;
}

/** A customer paying one invoice in full, and the bank charging for the month. */
function statementOf(options: { currency: string; open: Open; date: string; fee: string }): string {
  const closing = (Number(options.open.amount_open) * 100 - Number(options.fee) * 100) / 100;
  const balance = (type: string, amount: string): string => `
      <Bal>
        <Tp><CdOrPrtry><Cd>${type}</Cd></CdOrPrtry></Tp>
        <Amt Ccy="${options.currency}">${amount}</Amt>
        <CdtDbtInd>CRDT</CdtDbtInd>
        <Dt><Dt>${options.date}</Dt></Dt>
      </Bal>`;
  return `<?xml version="1.0" encoding="UTF-8"?>
<Document xmlns="${NAMESPACE}">
  <BkToCstmrStmt>
    <GrpHdr><MsgId>MSG-GOLDEN</MsgId><CreDtTm>${options.date}T20:00:00Z</CreDtTm></GrpHdr>
    <Stmt>
      <Id>STMT-GOLDEN</Id>
      <Acct><Id><Othr><Id>${ACCOUNT}</Id></Othr></Id><Ccy>${options.currency}</Ccy></Acct>${balance('OPBD', '0.00')}${balance('CLBD', closing.toFixed(2))}
      <Ntry>
        <Amt Ccy="${options.currency}">${options.open.amount_open}</Amt>
        <CdtDbtInd>CRDT</CdtDbtInd>
        <Sts><Cd>BOOK</Cd></Sts>
        <BookgDt><Dt>${options.date}</Dt></BookgDt>
        <AcctSvcrRef>GOLDEN-1</AcctSvcrRef>
        <BkTxCd><Domn><Cd>PMNT</Cd><Fmly><Cd>RCDT</Cd><SubFmlyCd>OTHR</SubFmlyCd></Fmly></Domn></BkTxCd>
        <NtryDtls><TxDtls>
          <RltdPties><Dbtr><Pty><Nm>${options.open.contact.replace(/&/g, '&amp;').replace(/</g, '&lt;')}</Nm></Pty></Dbtr></RltdPties>
          <RmtInf><Ustrd>${options.open.reference.replace(/&/g, '&amp;').replace(/</g, '&lt;')}</Ustrd></RmtInf>
        </TxDtls></NtryDtls>
      </Ntry>
      <Ntry>
        <Amt Ccy="${options.currency}">${options.fee}</Amt>
        <CdtDbtInd>DBIT</CdtDbtInd>
        <Sts><Cd>BOOK</Cd></Sts>
        <BookgDt><Dt>${options.date}</Dt></BookgDt>
        <AcctSvcrRef>GOLDEN-2</AcctSvcrRef>
        <BkTxCd><Domn><Cd>ACMT</Cd><Fmly><Cd>MDOP</Cd><SubFmlyCd>CHRG</SubFmlyCd></Fmly></Domn></BkTxCd>
        <AddtlNtryInf>Account fees</AddtlNtryInf>
      </Ntry>
    </Stmt>
  </BkToCstmrStmt>
</Document>`;
}

for (const pack of packs) {
  describe(`${pack.slug}: a statement read, imported, and the invoice it pays settled`, () => {
    const golden = pack.golden as NonNullable<typeof pack.golden>;
    let db: PGlite;
    let companyId: string;
    let ownerId: string;
    let open: Open;
    let xml: string;

    beforeAll(async () => {
      db = await freshDatabase();
      ({ companyId, ownerId } = await newCompany(db, {
        country: pack.manifest.country,
        name: golden.name,
        chart: golden.chart,
        language: golden.language,
        fiscalYear: golden.fiscalYear,
      }));
      await replayScenario(db, companyId, golden);
      await db.query(
        `insert into bank_accounts (company_id, name, currency_code, iban, journal_id)
         select c.id, 'Current account', c.currency_code, $2,
                (select j.id from journals j where j.company_id = c.id and j.journal_type = 'bank' order by j.code limit 1)
           from companies c where c.id = $1`,
        [companyId, ACCOUNT],
      );
      // The largest sale of the golden year that nobody has paid yet.
      open = await one<Open>(
        db,
        `select i.document_id, i.amount_open::text, i.reference, k.name as contact
           from open_items($1) i
           join documents d on d.id = i.document_id
           join contacts k on k.id = d.contact_id
          where i.side = 'debit' and d.doc_type = 'sale_invoice'
          order by i.amount_open desc, i.reference
          limit 1`,
        [companyId],
      );
      const currency = await one<{ currency_code: string }>(db, `select currency_code from companies where id = $1`, [companyId]);
      xml = statementOf({ currency: currency.currency_code, open, date: golden.fiscalYear.end, fee: '4.50' });
    }, 300_000);

    afterAll(async () => {
      await db?.close();
    });

    it('starts from a file the published schema accepts', async () => {
      expect(await schemaErrors(xml)).toEqual([]);
    });

    it('is read without a violation, to a statement that adds up', () => {
      const file = readCamt053(xml);
      expect(file.violations).toEqual([]);
      expect(file.statements[0]?.balanced).toBe(true);
      expect(file.statements[0]?.lines.map((line) => line.amount)).toEqual([open.amount_open, '-4.50']);
    });

    it('is imported by the owner under row level security, and books nothing', async () => {
      const entries = await one<{ n: number }>(db, `select count(*)::int as n from entries where company_id = $1`, [companyId]);
      const report = await asUser(db, ownerId, () =>
        rows<{ lines_imported: number; warnings: unknown[] }>(db, `select * from import_bank_statement($1, $2::jsonb)`, [
          companyId,
          JSON.stringify(readCamt053(xml)),
        ]),
      );
      expect(report).toMatchObject([{ lines_imported: 2, warnings: [] }]);
      const after = await one<{ n: number }>(db, `select count(*)::int as n from entries where company_id = $1`, [companyId]);
      expect(after.n).toBe(entries.n);
    });

    it('lets auto_settle() find the invoice from the reference the statement carries, and leave the fee alone', async () => {
      const passed = await rows<{ action: string; method: string; because: string }>(
        db,
        `select a.action, a.method, a.because
           from auto_settle($1, $2::date, $3::date, true) a
           join bank_transactions t on t.id = a.transaction_id
          order by t.sequence`,
        [companyId, golden.fiscalYear.start, golden.fiscalYear.end],
      );
      expect(passed.map((row) => [row.action, row.method])).toEqual([
        ['settled', 'reference'],
        ['proposed', 'none'],
      ]);
    });

    it('leaves the invoice paid, the line reconciled, and the books saying so', async () => {
      const document = await one<{ payment_state: string; amount_residual: string }>(
        db,
        `select payment_state::text, amount_residual::text from documents where id = $1`,
        [open.document_id],
      );
      expect(document.payment_state).toBe('paid');
      expect(Number(document.amount_residual)).toBe(0);
      const lines = await rows<{ state: string; booked: boolean }>(
        db,
        `select state::text, entry_id is not null as booked from bank_transactions where company_id = $1 order by sequence`,
        [companyId],
      );
      expect(lines).toEqual([
        { state: 'reconciled', booked: true },
        { state: 'pending', booked: false },
      ]);
    });

    it('imported again after the settlement, creates nothing and undoes nothing', async () => {
      const [report] = await rows<{ already_imported: boolean; lines_imported: number; lines_known: number }>(
        db,
        `select * from import_bank_statement($1, $2::jsonb)`,
        [companyId, JSON.stringify(readCamt053(xml))],
      );
      expect(report).toMatchObject({ already_imported: true, lines_imported: 0, lines_known: 2 });
      const line = await one<{ state: string }>(db, `select state::text from bank_transactions where company_id = $1 and sequence = 1`, [companyId]);
      expect(line.state).toBe('reconciled');
    });
  });
}
