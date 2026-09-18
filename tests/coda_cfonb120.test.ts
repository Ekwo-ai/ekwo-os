import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { readCamt053 } from '@ekwo-ai/camt053';
import { ibanOf, readCfonb120 } from '@ekwo-ai/cfonb120';
import { readCoda } from '@ekwo-ai/coda';
import { file as cfonbFile } from '../packages/formats/cfonb120/test/build.js';
import { file as codaFile, iban, type MovementSpec } from '../packages/formats/coda/test/build.js';
import { freshDatabase, one, repoRoot, rows } from './helpers/db.js';
import { newCompany, type Fixture } from './helpers/factory.js';

/**
 * The two readers of fixed-position statements, into the two tables — and the
 * question the roadmap asked of them by name: **the same month imported once
 * from a CODA and once from a camt.053**.
 *
 * What a reader returns goes to `import_bank_statement()` as it is, with no
 * adapter in between: if this file needed one, the shape the bricks share
 * would not be shared.
 *
 * The answer to the question is not the one anybody would like, and the last
 * two `describe` blocks assert it as it is rather than as it should be:
 * replaying a format against itself creates nothing; across formats, the lines
 * are recognised **only when the bank writes the same reference in both** —
 * which CODA's own standard says it does not promise — and a CFONB 120 has no
 * bank reference at all, so its month is imported twice. docs/decisions.md
 * says what would close that, and it is not in this change.
 */

interface Report {
  statement_ref: string;
  already_imported: boolean;
  lines_read: number;
  lines_imported: number;
  lines_known: number;
  warnings: { code: string }[];
}

const fixtures = (brick: string, name: string): string =>
  readFileSync(join(repoRoot, 'packages', 'formats', brick, 'test', 'fixtures', name), 'utf8');

let db: PGlite;
let fx: Fixture;

async function bankAccount(companyId: string, identifier: string): Promise<string> {
  const row = await one<{ id: string }>(
    db,
    `insert into bank_accounts (company_id, name, currency_code, iban, journal_id)
     values ($1, 'Compte ' || $2, (select currency_code from companies where id = $1), $2,
             (select id from journals where company_id = $1 and journal_type = 'bank' order by code limit 1))
     returning id`,
    [companyId, identifier],
  );
  return row.id;
}

async function importFile(file: unknown, bankAccountId: string | null = null): Promise<Report[]> {
  return rows<Report>(db, `select * from import_bank_statement($1, $2::jsonb, null, $3)`, [
    fx.companyId,
    JSON.stringify(file),
    bankAccountId,
  ]);
}

async function lineCount(bankAccountId: string): Promise<number> {
  const row = await one<{ n: number }>(
    db,
    `select count(*)::int as n from bank_transactions where bank_account_id = $1`,
    [bankAccountId],
  );
  return row.n;
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('a CODA, as the reader returns it', () => {
  const golden = readCoda(fixtures('coda', 'golden.cod'));
  let accountId: string;

  it('is imported without an adapter: eleven lines, a statement that proves itself', async () => {
    accountId = await bankAccount(fx.companyId, golden.statements[0]!.account.identifier.value);
    const [report] = (await importFile(golden)) as [Report];
    expect(report).toMatchObject({
      statement_ref: '2026-042',
      already_imported: false,
      lines_read: 11,
      lines_imported: 11,
      lines_known: 0,
      warnings: [],
    });
    const statement = await one<Record<string, unknown>>(
      db,
      `select source_format, sequence_number::int as sequence_number, period_start::text, statement_date::text,
              balance_start::text, balance_end_declared::text, balance_end_computed::text
         from bank_statements where bank_account_id = $1`,
      [accountId],
    );
    expect(statement).toEqual({
      source_format: 'coda.2',
      sequence_number: 42,
      period_start: '2026-03-04',
      statement_date: '2026-03-05',
      balance_start: '1000.00',
      balance_end_declared: '1511.85',
      balance_end_computed: '1511.85',
    });
  });

  it('writes each line as the reconciliation reads it', async () => {
    const written = await rows<Record<string, unknown>>(
      db,
      `select amount::text, counterpart_name, counterpart_iban, reference, structured_reference, description
         from bank_transactions where bank_account_id = $1 order by sequence limit 3`,
      [accountId],
    );
    expect(written[0]).toEqual({
      amount: '1210.00',
      counterpart_name: 'CLIENT EXEMPLE UN',
      counterpart_iban: golden.statements[0]!.lines[0]!.counterparty!.account!.value,
      reference: 'REF0000000000000001',
      structured_reference: '202600010704',
      description: null,
    });
    // The two halves of a split total are two lines under one bank reference.
    expect(written.slice(1).map((line) => [line['amount'], line['reference']])).toEqual([
      ['-450.50', 'REF0000000000000002'],
      ['-500.00', 'REF0000000000000003'],
    ]);
  });

  it('replayed, creates nothing', async () => {
    const [again] = (await importFile(readCoda(fixtures('coda', 'golden.cod')))) as [Report];
    expect(again).toMatchObject({ already_imported: true, lines_imported: 0, lines_known: 11 });
    expect(await lineCount(accountId)).toBe(11);
  });

  it('then the next day, from a file of two statements: only the next day is new, and the numbering has no hole', async () => {
    const reports = await importFile(readCoda(fixtures('coda', 'two-statements.cod')));
    expect(reports.map((report) => [report.statement_ref, report.lines_imported, report.warnings])).toEqual([
      ['2026-042', 0, []],
      ['2026-043', 1, []],
    ]);
  });

  it('is refused when it does not add up, by the database and whatever the reader said', async () => {
    const broken = fixtures('coda', 'golden.cod').replace('0000000001511850050326', '0000000001511840050326');
    const read = readCoda(broken);
    expect(read.violations.map((violation) => violation.code)).toEqual(['balance_mismatch']);
    await expect(importFile(read)).rejects.toThrow(/unbalanced_statement/);
  });
});

describe('a CFONB 120, as the reader returns it', () => {
  const content = fixtures('cfonb120', 'golden.cfonb120.txt');

  it('is imported on the IBAN its account makes in the country the caller names', async () => {
    const read = readCfonb120(content, { ibanCountry: 'FR' }); // country-literal: the caller's word, which the format does not carry
    const { bankCode, branchCode, accountNumber } = read.statements[0]!.account;
    const accountId = await bankAccount(fx.companyId, ibanOf('FR', bankCode, branchCode, accountNumber) as string); // country-literal: the same word
    const [report] = (await importFile(read)) as [Report];
    expect(report).toMatchObject({
      statement_ref: '2026-02-28/2026-03-31',
      lines_read: 6,
      lines_imported: 6,
      warnings: [],
    });
    const [again] = (await importFile(readCfonb120(content, { ibanCountry: 'FR' }))) as [Report]; // country-literal: the same word
    expect(again).toMatchObject({ already_imported: true, lines_imported: 0, lines_known: 6 });
    expect(await lineCount(accountId)).toBe(6);
    const first = await one<Record<string, unknown>>(
      db,
      `select counterpart_name, reference, description, import_key like 'fp:%' as fingerprinted
         from bank_transactions where bank_account_id = $1 order by sequence limit 1`,
      [accountId],
    );
    expect(first).toEqual({
      counterpart_name: 'CLIENT EXEMPLE UN SARL',
      reference: null,
      description: 'FACTURE 2026-0107 DU 28 FEVRIER 2026 - CHANTIER RUE INVENTEE - MERCI POUR VOTRE CONFIANCE',
      fingerprinted: true,
    });
  });

  it('with no country named, is imported on the account the caller names — and on nothing it guessed', async () => {
    const other = content.replaceAll('0000000101A', '0000000909Z');
    const read = readCfonb120(other);
    await expect(importFile(read)).rejects.toThrow(/unknown_bank_account.*99999000010000000909Z/);
    const accountId = await bankAccount(fx.companyId, 'compte-nomme-a-la-main');
    const [report] = (await importFile(read, accountId)) as [Report];
    expect(report).toMatchObject({ lines_imported: 6 });
  });
});

// ---------------------------------------------------------------------------
// The same day, from two formats
// ---------------------------------------------------------------------------

const DAY: { reference: string; amount: bigint; text: string; payer: string }[] = [
  { reference: 'BANKREF-0001', amount: 250_000n, text: 'LOYER MARS', payer: 'LOCATAIRE EXEMPLE UN' },
  { reference: 'BANKREF-0002', amount: 250_000n, text: 'LOYER MARS', payer: 'LOCATAIRE EXEMPLE DEUX' },
  { reference: 'BANKREF-0003', amount: -99_900n, text: 'FACTURE 42', payer: 'FOURNISSEUR EXEMPLE' },
];

function codaDay(account: string): string {
  const movements: MovementSpec[] = DAY.map((line, index) => ({
    sequence: index + 1,
    reference: line.reference,
    amount: line.amount,
    valueDate: '050326',
    entryDate: '050326',
    free: line.text,
    counterpartyName: line.payer,
  }));
  return codaFile({ account, opening: 1_000_000n, openingDate: '040326', closingDate: '050326', movements });
}

/** The same day as a bank would write it in camt.053 — with the references given, or none. */
function camtDay(account: string, reference: (line: (typeof DAY)[number]) => string | null): string {
  const decimal = (amount: bigint): string => {
    const digits = (amount < 0n ? -amount : amount).toString().padStart(4, '0');
    return `${digits.slice(0, -3)}.${digits.slice(-3, -1)}`;
  };
  const entries = DAY.map((line) => {
    const ref = reference(line);
    return `<Ntry><Amt Ccy="EUR">${decimal(line.amount)}</Amt><CdtDbtInd>${line.amount < 0n ? 'DBIT' : 'CRDT'}</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><BookgDt><Dt>2026-03-05</Dt></BookgDt><ValDt><Dt>2026-03-05</Dt></ValDt>${ref === null ? '' : `<AcctSvcrRef>${ref}</AcctSvcrRef>`}<BkTxCd/><NtryDtls><TxDtls><RltdPties><${line.amount < 0n ? 'Cdtr' : 'Dbtr'}><Pty><Nm>${line.payer}</Nm></Pty></${line.amount < 0n ? 'Cdtr' : 'Dbtr'}></RltdPties><RmtInf><Ustrd>${line.text}</Ustrd></RmtInf></TxDtls></NtryDtls></Ntry>`;
  }).join('');
  const balance = (type: string, amount: string, date: string): string =>
    `<Bal><Tp><CdOrPrtry><Cd>${type}</Cd></CdOrPrtry></Tp><Amt Ccy="EUR">${amount}</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>${date}</Dt></Dt></Bal>`;
  return `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.053.001.08"><BkToCstmrStmt><GrpHdr><MsgId>M</MsgId></GrpHdr><Stmt><Id>STMT-2026-03-05</Id><LglSeqNb>42</LglSeqNb><Acct><Id><IBAN>${account}</IBAN></Id><Ccy>EUR</Ccy></Acct>${balance('OPBD', '1000.00', '2026-03-04')}${balance('CLBD', '1400.10', '2026-03-05')}${entries}</Stmt></BkToCstmrStmt></Document>`;
}

describe('the same day from a CODA, then from a camt.053', () => {
  // Invented accounts, with the check digits ISO 13616 gives them.
  const SAME = iban('BE', '999000000505'); // country-literal: an invented account has to be of somewhere
  const OTHER = iban('BE', '999000000606'); // country-literal: the same

  it('when the bank writes the same reference in both: the lines are known, and the day is still two statements', async () => {
    const accountId = await bankAccount(fx.companyId, SAME);
    const [coda] = (await importFile(readCoda(codaDay(SAME)))) as [Report];
    expect(coda).toMatchObject({ lines_imported: 3, lines_known: 0 });

    const [camt] = (await importFile(readCamt053(camtDay(SAME, (line) => line.reference)))) as [Report];
    expect(camt).toMatchObject({ already_imported: false, lines_imported: 0, lines_known: 3, warnings: [] });
    expect(await lineCount(accountId)).toBe(3);
    // The statement itself is not recognised: the two formats name it differently.
    const statements = await rows<{ statement_ref: string; source_format: string }>(
      db,
      `select statement_ref, source_format from bank_statements where bank_account_id = $1 order by created_at, statement_ref`,
      [accountId],
    );
    expect(statements.map((statement) => statement.source_format).sort()).toEqual([
      'coda.2',
      'urn:iso:std:iso:20022:tech:xsd:camt.053.001.08',
    ]);
  });

  it('when it does not — another reference, or none: THE DAY IS IMPORTED TWICE, and nothing says so', async () => {
    const accountId = await bankAccount(fx.companyId, OTHER);
    await importFile(readCoda(codaDay(OTHER)));

    const [camt] = (await importFile(readCamt053(camtDay(OTHER, () => null)))) as [Report];
    // This is the gap, asserted as it is. When it is closed this expectation
    // fails, and whoever closes it turns it round.
    expect(camt).toMatchObject({ lines_imported: 3, lines_known: 0, warnings: [] });
    expect(await lineCount(accountId)).toBe(6);
  });
});

describe('the same day from a CFONB 120, then from a camt.053', () => {
  it('IS IMPORTED TWICE, whatever the bank references: the format gives a movement none to be recognised by', async () => {
    const account = ibanOf('FR', '99999', '00001', '00000000707') as string; // country-literal: the caller's word
    const accountId = await bankAccount(fx.companyId, account);
    const cfonb = readCfonb120(
      cfonbFile({
        accountNumber: '00000000707',
        opening: 100_000n,
        openingDate: '040326',
        closingDate: '050326',
        movements: DAY.map((line) => ({
          amount: line.amount / 10n,
          bookingDate: '050326',
          label: line.text,
          complements: [{ qualifier: line.amount < 0n ? 'NBE' : 'NPY', text: line.payer }],
        })),
      }),
      { ibanCountry: 'FR' }, // country-literal: the same word
    );
    expect(cfonb.statements[0]!.lines.every((line) => line.bankReference === null)).toBe(true);
    expect((await importFile(cfonb))[0]).toMatchObject({ lines_imported: 3 });

    const [camt] = (await importFile(readCamt053(camtDay(account, (line) => line.reference)))) as [Report];
    // The gap again, asserted as it is.
    expect(camt).toMatchObject({ lines_imported: 3, lines_known: 0, warnings: [] });
    expect(await lineCount(accountId)).toBe(6);
  });
});
