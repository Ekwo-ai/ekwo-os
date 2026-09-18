import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { readCamt053, type StatementFile } from '@ekwo-ai/camt053';
import { asUser, expectError, freshDatabase, one, repoRoot, rows } from './helpers/db.js';
import { newCompany, newUser, type Fixture } from './helpers/factory.js';

/**
 * From what a reader read to the two tables, and the guarantees on the way.
 *
 * The files are the brick's own invented fixtures, read by the brick: the
 * function is given exactly what it will be given in use, and never a jsonb
 * somebody typed to please it.
 */

const fixtures = join(repoRoot, 'packages', 'formats', 'camt053', 'test', 'fixtures');
const golden = readFileSync(join(fixtures, 'golden.camt.053.001.08.xml'), 'utf8');
const otherAccount = readFileSync(join(fixtures, 'other-account.camt.053.001.08.xml'), 'utf8');

const ACCOUNT = 'BE96999000000101';

interface Report {
  statement_index: number;
  statement_id: string;
  bank_account_id: string;
  statement_ref: string;
  already_imported: boolean;
  lines_read: number;
  lines_imported: number;
  lines_known: number;
  lines_not_booked: number;
  warnings: { code: string; message: string }[];
}

let db: PGlite;
let fx: Fixture;

function change(xml: string, from: string, to: string): string {
  const out = xml.replace(from, to);
  if (out === xml) throw new Error(`"${from}" is not in the file`);
  return out;
}

/** The first five entries of the golden month, as the statement of its first fortnight. */
function fortnight(): string {
  const start = golden.indexOf('<Ntry>\n        <NtryRef>6</NtryRef>');
  const end = golden.lastIndexOf('</Ntry>') + '</Ntry>'.length;
  return (golden.slice(0, start) + golden.slice(end))
    .replace('<Id>STMT-2026-003</Id>', '<Id>STMT-2026-003-A</Id>')
    .replace('<Amt Ccy="EUR">1562.36</Amt>', '<Amt Ccy="EUR">1277.60</Amt>')
    .replace('<Dt><Dt>2026-03-31</Dt></Dt>', '<Dt><Dt>2026-03-15</Dt></Dt>');
}

/** A statement of one account, with the entries given, that adds up. */
function statement(options: {
  id: string;
  account?: string;
  opening: string;
  closing: string;
  from: string;
  to: string;
  sequence?: number;
  entries: { amount: string; date: string; reference?: string; text?: string; payer?: string }[];
}): string {
  const entries = options.entries
    .map(
      (entry) => `<Ntry><Amt Ccy="EUR">${entry.amount.replace('-', '')}</Amt><CdtDbtInd>${entry.amount.startsWith('-') ? 'DBIT' : 'CRDT'}</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><BookgDt><Dt>${entry.date}</Dt></BookgDt>${entry.reference ? `<AcctSvcrRef>${entry.reference}</AcctSvcrRef>` : ''}<BkTxCd/><NtryDtls><TxDtls><RltdPties><Dbtr><Pty><Nm>${entry.payer ?? 'Locataire Exemple'}</Nm></Pty></Dbtr></RltdPties><RmtInf><Ustrd>${entry.text ?? 'loyer'}</Ustrd></RmtInf></TxDtls></NtryDtls></Ntry>`,
    )
    .join('');
  const balance = (type: string, amount: string, date: string): string =>
    `<Bal><Tp><CdOrPrtry><Cd>${type}</Cd></CdOrPrtry></Tp><Amt Ccy="EUR">${amount}</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>${date}</Dt></Dt></Bal>`;
  return `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.053.001.08"><BkToCstmrStmt><GrpHdr><MsgId>M</MsgId></GrpHdr><Stmt><Id>${options.id}</Id>${options.sequence ? `<LglSeqNb>${options.sequence}</LglSeqNb>` : ''}<Acct><Id><IBAN>${options.account ?? ACCOUNT}</IBAN></Id><Ccy>EUR</Ccy></Acct>${balance('OPBD', options.opening, options.from)}${balance('CLBD', options.closing, options.to)}${entries}</Stmt></BkToCstmrStmt></Document>`;
}

async function bankAccount(companyId: string, identifier: string, currency = 'EUR'): Promise<string> {
  const row = await one<{ id: string }>(
    db,
    `insert into bank_accounts (company_id, name, currency_code, iban, journal_id)
     values ($1, 'Compte ' || $2, $3, $2,
             (select id from journals where company_id = $1 and journal_type = 'bank' order by code limit 1))
     returning id`,
    [companyId, identifier, currency],
  );
  return row.id;
}

async function importFile(
  companyId: string,
  file: StatementFile,
  source: Record<string, unknown> | null = null,
  bankAccountId: string | null = null,
): Promise<Report[]> {
  return rows<Report>(db, `select * from import_bank_statement($1, $2::jsonb, $3::jsonb, $4)`, [
    companyId,
    JSON.stringify(file),
    source === null ? null : JSON.stringify(source),
    bankAccountId,
  ]);
}

async function refusal(companyId: string, file: StatementFile, bankAccountId: string | null = null): Promise<string> {
  return expectError(db, `select * from import_bank_statement($1, $2::jsonb, null, $3)`, [
    companyId,
    JSON.stringify(file),
    bankAccountId,
  ]);
}

async function count(table: string, companyId: string): Promise<number> {
  const row = await one<{ n: number }>(db, `select count(*)::int as n from ${table} where company_id = $1`, [companyId]);
  return row.n;
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  await bankAccount(fx.companyId, ACCOUNT);
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('a fortnight, then the month that contains it, then the month again', () => {
  let first: Report;
  let month: Report;

  it('imports the fortnight: five lines, a statement that proves itself, and no entry', async () => {
    const entriesBefore = await count('entries', fx.companyId);
    const paymentsBefore = await count('payments', fx.companyId);
    [first] = (await importFile(fx.companyId, readCamt053(fortnight()))) as [Report];
    expect(first).toMatchObject({
      statement_ref: 'STMT-2026-003-A',
      already_imported: false,
      lines_read: 5,
      lines_imported: 5,
      lines_known: 0,
      warnings: [],
    });
    const stored = await one<{ is_consistent: boolean; balance_end_computed: string; source_format: string; period_start: string }>(
      db,
      `select is_consistent, balance_end_computed::text, source_format, period_start::text from bank_statements where id = $1`,
      [first.statement_id],
    );
    expect(stored).toEqual({
      is_consistent: true,
      balance_end_computed: '1277.60',
      source_format: 'urn:iso:std:iso:20022:tech:xsd:camt.053.001.08',
      period_start: '2026-03-01',
    });
    // A statement never becomes an entry: nothing was booked and nothing paid.
    expect(await count('entries', fx.companyId)).toBe(entriesBefore);
    expect(await count('payments', fx.companyId)).toBe(paymentsBefore);
  });

  it('imports of the month only what the fortnight did not bring, and lists all of it', async () => {
    [month] = (await importFile(fx.companyId, readCamt053(golden))) as [Report];
    expect(month).toMatchObject({
      statement_ref: 'STMT-2026-003',
      already_imported: false,
      lines_read: 11,
      lines_imported: 6,
      lines_known: 5,
      lines_not_booked: 1,
    });
    expect(await count('bank_transactions', fx.companyId)).toBe(11);
    const listed = await one<{ n: number }>(
      db,
      `select count(*)::int as n from bank_statement_lines where statement_id = $1`,
      [month.statement_id],
    );
    expect(listed.n).toBe(11);
  });

  it('still proves both closing balances, though the month holds six of its eleven lines', async () => {
    const statements = await rows<{ statement_ref: string; held: number; is_consistent: boolean; balance_end_computed: string }>(
      db,
      `select s.statement_ref, s.is_consistent, s.balance_end_computed::text,
              (select count(*)::int from bank_transactions t where t.statement_id = s.id) as held
         from bank_statements s where s.company_id = $1 order by s.statement_date`,
      [fx.companyId],
    );
    expect(statements).toEqual([
      { statement_ref: 'STMT-2026-003-A', held: 5, is_consistent: true, balance_end_computed: '1277.60' },
      { statement_ref: 'STMT-2026-003', held: 6, is_consistent: true, balance_end_computed: '1562.36' },
    ]);
  });

  it('does not take the fortnight for the statement before the month', async () => {
    // They open on the same day. The previous statement is one that opened
    // before, and there is none: no break is reported.
    expect(month.warnings).toEqual([]);
  });

  it('replayed, creates nothing', async () => {
    const before = await count('bank_transactions', fx.companyId);
    const [again] = await importFile(fx.companyId, readCamt053(golden));
    expect(again).toMatchObject({
      statement_id: month.statement_id,
      already_imported: true,
      lines_read: 11,
      lines_imported: 0,
      lines_known: 11,
    });
    expect(await count('bank_transactions', fx.companyId)).toBe(before);
    expect(await count('bank_statements', fx.companyId)).toBe(2);
    expect(await count('bank_statement_lines', fx.companyId)).toBe(16);
  });

  it('is replayed from any version of the message without creating anything either', async () => {
    const v02 = readFileSync(join(fixtures, 'golden.camt.053.001.02.xml'), 'utf8');
    const [again] = await importFile(fx.companyId, readCamt053(v02));
    expect(again).toMatchObject({ already_imported: true, lines_imported: 0, lines_known: 11 });
  });

  it('writes each line as the reconciliation reads it', async () => {
    const lines = await rows<Record<string, unknown>>(
      db,
      `select sequence, transaction_date::text, value_date::text, amount::text, currency_code, description,
              counterpart_name, counterpart_iban, reference, structured_reference, state::text, entry_id,
              left(import_key, 4) as key
         from bank_transactions where company_id = $1 order by transaction_date, sequence`,
      [fx.companyId],
    );
    expect(lines[0]).toEqual({
      sequence: 1,
      transaction_date: '2026-03-03',
      value_date: '2026-03-03',
      amount: '1210.00',
      currency_code: 'EUR',
      description: null,
      counterpart_name: 'Client Exemple & Fils',
      counterpart_iban: 'FR499999900000000000010199',
      reference: 'ZZ26030300001',
      structured_reference: 'RF73INV20260042',
      state: 'pending',
      entry_id: null,
      key: 'ref:',
    });
    expect(lines[1]).toMatchObject({ amount: '-450.50', description: 'Invoice 2026-0107 thank you', structured_reference: null });
    // A counterparty that has no IBAN is still the counterparty: what the
    // statement wrote is kept, because it is what recognising it compares.
    expect(lines[4]).toMatchObject({ amount: '-920.00', counterpart_iban: '9999999920000123456' });
    // The three transactions of the batch, each with its own reference.
    expect(lines.slice(5, 8).map((line) => [line.amount, line.reference])).toEqual([
      ['100.00', 'ZZ26031700006-1'],
      ['120.00', 'ZZ26031700006-2'],
      ['80.00', 'ZZ26031700006-3'],
    ]);
    const raw = await one<{ raw: { remittance: unknown; instructedAmount: unknown } }>(
      db,
      `select raw from bank_transactions where company_id = $1 and sequence = 5`,
      [fx.companyId],
    );
    expect(raw.raw.instructedAmount).toEqual({ amount: '1000.00', currency: 'USD' });
  });

  it('never imports the pending entry', async () => {
    const pending = await rows(db, `select 1 from bank_transactions where company_id = $1 and amount = 500`, [fx.companyId]);
    expect(pending).toEqual([]);
  });
});

describe('two transfers that say exactly the same thing', () => {
  let company: Fixture;
  const rent = { amount: '650.00', date: '2026-04-01' };

  beforeAll(async () => {
    company = await newCompany(db, { name: 'Bailleur Exemple' });
    await bankAccount(company.companyId, ACCOUNT);
  });

  it('are two lines, not a duplicate: same day, same amount, same words, no reference', async () => {
    const file = readCamt053(
      statement({ id: 'RENT-04-A', opening: '0.00', closing: '1300.00', from: '2026-04-01', to: '2026-04-01', entries: [rent, rent] }),
    );
    expect(file.statements[0]?.lines[0]?.bankReference).toBeNull();
    const [report] = await importFile(company.companyId, file);
    expect(report).toMatchObject({ lines_read: 2, lines_imported: 2, lines_known: 0 });
    const keys = await rows<{ import_key: string }>(db, `select import_key from bank_transactions where company_id = $1`, [company.companyId]);
    expect(new Set(keys.map((row) => row.import_key)).size).toBe(2);
    expect(keys.every((row) => row.import_key.startsWith('fp:'))).toBe(true);
  });

  it('replayed, are still two', async () => {
    const [report] = await importFile(
      company.companyId,
      readCamt053(statement({ id: 'RENT-04-A', opening: '0.00', closing: '1300.00', from: '2026-04-01', to: '2026-04-01', entries: [rent, rent] })),
    );
    expect(report).toMatchObject({ already_imported: true, lines_imported: 0, lines_known: 2 });
  });

  it('found again in a statement that overlaps, with a third, are three', async () => {
    const [report] = await importFile(
      company.companyId,
      readCamt053(statement({ id: 'RENT-04', opening: '0.00', closing: '1950.00', from: '2026-04-01', to: '2026-04-30', entries: [rent, rent, rent] })),
    );
    expect(report).toMatchObject({ lines_read: 3, lines_imported: 1, lines_known: 2 });
    expect(await count('bank_transactions', company.companyId)).toBe(3);
  });

  it('are told apart from a line that differs by one word', async () => {
    const [report] = await importFile(
      company.companyId,
      readCamt053(
        statement({ id: 'RENT-05', opening: '1950.00', closing: '3250.00', from: '2026-05-01', to: '2026-05-31', entries: [{ ...rent, date: '2026-05-01' }, { ...rent, date: '2026-05-01', text: 'loyer mai' }] }),
      ),
    );
    expect(report).toMatchObject({ lines_imported: 2, warnings: [] });
  });

  it('with a bank reference, are keyed on it — and a reference seen again is known whatever else moved', async () => {
    const entries = [
      { ...rent, date: '2026-06-01', reference: 'REF-1' },
      { ...rent, date: '2026-06-01', reference: 'REF-2' },
    ];
    await importFile(company.companyId, readCamt053(statement({ id: 'RENT-06-A', opening: '3250.00', closing: '4550.00', from: '2026-06-01', to: '2026-06-01', entries })));
    const reworded = entries.map((entry) => ({ ...entry, text: 'loyer juin (libellé corrigé par la banque)' }));
    const [report] = await importFile(
      company.companyId,
      readCamt053(statement({ id: 'RENT-06', opening: '3250.00', closing: '4550.00', from: '2026-06-01', to: '2026-06-30', entries: reworded })),
    );
    expect(report).toMatchObject({ lines_imported: 0, lines_known: 2 });
  });
});

describe('what is refused, by name, before anything is written', () => {
  let company: Fixture;

  beforeAll(async () => {
    company = await newCompany(db, { name: 'Refus Exemple' });
    await bankAccount(company.companyId, ACCOUNT);
  });

  const untouched = async (): Promise<void> => {
    expect(await count('bank_statements', company.companyId)).toBe(0);
    expect(await count('bank_transactions', company.companyId)).toBe(0);
    expect(await count('bank_accounts', company.companyId)).toBe(1);
  };

  it('an account the company does not have — named, and never created', async () => {
    const message = await refusal(company.companyId, readCamt053(golden.replaceAll(ACCOUNT, 'BE85999000000202')));
    expect(message).toContain('unknown_bank_account');
    expect(message).toContain('BE85999000000202');
    await untouched();
  });

  it('a statement that does not add up — recomputed here, not taken from the reader', async () => {
    const file = readCamt053(change(golden, '<Amt Ccy="EUR">1562.36</Amt>', '<Amt Ccy="EUR">1562.35</Amt>'));
    expect(file.statements[0]?.balanced).toBe(false);
    // Somebody who flips the flag imports nothing more.
    for (const claimed of [false, true]) {
      file.statements[0]!.balanced = claimed;
      const message = await refusal(company.companyId, file);
      expect(message).toContain('unbalanced_statement');
      expect(message).toContain('a difference of -0.01');
    }
    await untouched();
  });

  it('a statement without its balances', async () => {
    const start = golden.indexOf('<Bal>');
    const end = golden.indexOf('</Bal>') + '</Bal>'.length;
    const message = await refusal(company.companyId, readCamt053(golden.slice(0, start) + golden.slice(end)));
    expect(message).toContain('statement_without_balances');
    await untouched();
  });

  it('a booked line in another currency, which is reported and not converted', async () => {
    const message = await refusal(company.companyId, readCamt053(change(golden, '<Amt Ccy="EUR">12.40</Amt>', '<Amt Ccy="CHF">12.40</Amt>')));
    expect(message).toContain('unreadable_statement_line');
    expect(message).toContain('in CHF, not converted');
    await untouched();
  });

  it('a booked line finer than the column that would hold it', async () => {
    const file = change(change(golden, '<Amt Ccy="EUR">0.01</Amt>', '<Amt Ccy="EUR">0.015</Amt>'), '1562.36', '1562.365');
    const message = await refusal(company.companyId, readCamt053(file));
    expect(message).toContain('unreadable_statement_line');
    expect(message).toContain('more than two decimals');
    await untouched();
  });

  it('a statement in another currency than its account', async () => {
    const message = await refusal(company.companyId, readCamt053(golden.replaceAll('Ccy="EUR"', 'Ccy="CHF"').replace('<Ccy>EUR</Ccy>', '<Ccy>CHF</Ccy>')));
    expect(message).toContain('statement_currency_mismatch');
    await untouched();
  });

  it('a file of two statements when one of the two accounts is unknown: neither is imported', async () => {
    const two = readCamt053(golden);
    const stranger = structuredClone(two.statements[0]!);
    stranger.account.identifier = { kind: 'iban', value: 'BE85999000000202' };
    two.statements.push(stranger);
    expect(await refusal(company.companyId, two)).toContain('unknown_bank_account');
    await untouched();
  });

  it('what is not a statement file at all', async () => {
    for (const payload of ['{}', '{"statements": []}', '{"statements": "none"}', '[]']) {
      const message = await expectError(db, `select * from import_bank_statement($1, $2::jsonb)`, [company.companyId, payload]);
      expect(message, payload).toContain('invalid_statement_file');
    }
    expect(await expectError(db, `select * from import_bank_statement($1, '{}'::jsonb)`, [crypto.randomUUID()])).toContain('unknown_company');
  });

  it('the same statement again with other balances', async () => {
    await importFile(company.companyId, readCamt053(golden));
    const shifted = change(change(golden, '<Amt Ccy="EUR">1000.00</Amt>', '<Amt Ccy="EUR">1001.00</Amt>'), '1562.36', '1563.36');
    const message = await refusal(company.companyId, readCamt053(shifted));
    expect(message).toContain('statement_conflict');
    expect(await count('bank_statements', company.companyId)).toBe(1);
  });

  it('a named bank account that is not the account of the statement', async () => {
    const other = await bankAccount(company.companyId, 'BE85999000000202');
    expect(await refusal(company.companyId, readCamt053(golden), other)).toContain('bank_account_mismatch');
    expect(await refusal(company.companyId, readCamt053(golden), crypto.randomUUID())).toContain('unknown_bank_account');
  });
});

describe('what is signalled, and never refused', () => {
  let company: Fixture;

  beforeAll(async () => {
    company = await newCompany(db, { name: 'Continuité Exemple' });
    await bankAccount(company.companyId, ACCOUNT);
    await importFile(company.companyId, readCamt053(golden));
  });

  it('an opening balance that is not the previous closing one: a month is missing, and it shows', async () => {
    const may = statement({ id: 'STMT-2026-005', sequence: 5, opening: '2000.00', closing: '2100.00', from: '2026-05-01', to: '2026-05-31', entries: [{ amount: '100.00', date: '2026-05-10' }] });
    const [report] = await importFile(company.companyId, readCamt053(may));
    expect(report!.lines_imported).toBe(1);
    expect(report!.warnings.map((warning) => warning.code)).toEqual(['balance_chain_broken', 'statement_number_gap']);
    expect(report!.warnings[0]!.message).toContain('opens at 2000.00');
    expect(report!.warnings[0]!.message).toContain('closed at 1562.36');
    expect(report!.warnings[0]!.message).toContain('437.64 is unaccounted for');
    expect(report!.warnings[1]).toMatchObject({ missing_statements: 1 });
  });

  it('is closed by importing the missing month, without anybody touching a row', async () => {
    const april = statement({ id: 'STMT-2026-004', sequence: 4, opening: '1562.36', closing: '2000.00', from: '2026-04-01', to: '2026-04-30', entries: [{ amount: '437.64', date: '2026-04-12' }] });
    const [report] = await importFile(company.companyId, readCamt053(april));
    expect(report!.warnings).toEqual([]);
    const chain = await rows<{ statement_ref: string; previous_statement_ref: string | null; is_broken: boolean; missing_statements: string | null }>(
      db,
      `select statement_ref, previous_statement_ref, is_broken, missing_statements::text
         from bank_statement_continuity where company_id = $1 order by statement_date`,
      [company.companyId],
    );
    expect(chain).toEqual([
      { statement_ref: 'STMT-2026-003', previous_statement_ref: null, is_broken: false, missing_statements: null },
      { statement_ref: 'STMT-2026-004', previous_statement_ref: 'STMT-2026-003', is_broken: false, missing_statements: '0' },
      { statement_ref: 'STMT-2026-005', previous_statement_ref: 'STMT-2026-004', is_broken: false, missing_statements: '0' },
    ]);
  });
});

describe('an account that is not an IBAN', () => {
  it('is found by what the statement wrote, or by being named', async () => {
    const company = await newCompany(db, { name: 'Compte Sans IBAN' });
    const file = readCamt053(otherAccount);
    expect(await refusal(company.companyId, file)).toContain('unknown_bank_account: no bank account of this company is identified by 0000123456 (other)');
    const accountId = await bankAccount(company.companyId, '0000123456', 'USD');
    const [report] = await importFile(company.companyId, file);
    // Two booked entries; the one under a proprietary status is left out.
    expect(report).toMatchObject({ bank_account_id: accountId, lines_read: 2, lines_imported: 2, lines_not_booked: 1 });
    const [named] = await importFile(company.companyId, file, null, accountId);
    expect(named).toMatchObject({ already_imported: true, lines_imported: 0 });
  });
});

describe('the file itself', () => {
  it('leaves its checksum on the statement, and a row in attachments when it was stored somewhere', async () => {
    const company = await newCompany(db, { name: 'Pièce Exemple' });
    await bankAccount(company.companyId, ACCOUNT);
    const source = {
      file_name: 'statement-2026-03.xml',
      checksum: 'sha256:0f343b0931126a20f133d67c2b018a3b',
      byte_size: golden.length,
      mime_type: 'application/xml',
      storage_path: 'statements/2026/03/statement-2026-03.xml',
    };
    const [report] = await importFile(company.companyId, readCamt053(golden), source);
    await importFile(company.companyId, readCamt053(golden), source);
    const stored = await one<{ source_checksum: string; source_file_name: string }>(
      db,
      `select source_checksum, source_file_name from bank_statements where id = $1`,
      [report!.statement_id],
    );
    expect(stored).toEqual({ source_checksum: source.checksum, source_file_name: source.file_name });
    const attached = await rows<{ entity_type: string; checksum: string; storage_path: string }>(
      db,
      `select entity_type, checksum, storage_path from attachments where company_id = $1`,
      [company.companyId],
    );
    expect(attached).toEqual([{ entity_type: 'bank_statement', checksum: source.checksum, storage_path: source.storage_path }]);
  });
});

describe('under row level security, as the person who asks', () => {
  let mine: Fixture;
  let theirs: Fixture;
  const file = JSON.stringify(readCamt053(golden));

  const attempt = (userId: string, companyId: string): Promise<Report[]> =>
    asUser(db, userId, () => rows<Report>(db, `select * from import_bank_statement($1, $2::jsonb)`, [companyId, file]));

  const refused = async (userId: string, companyId: string): Promise<string> => {
    try {
      await attempt(userId, companyId);
    } catch (error) {
      return (error as Error).message;
    }
    throw new Error('expected a refusal');
  };

  beforeAll(async () => {
    mine = await newCompany(db, { name: 'La Mienne' });
    theirs = await newCompany(db, { name: 'La Leur' });
    await bankAccount(mine.companyId, ACCOUNT);
    await bankAccount(theirs.companyId, ACCOUNT);
  });

  it('refuses a viewer and a client, who read and do not write', async () => {
    for (const role of ['viewer', 'client']) {
      const userId = await newUser(db);
      await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, $3)`, [mine.companyId, userId, role]);
      expect(await refused(userId, mine.companyId), role).toContain('not_allowed');
    }
    expect(await count('bank_transactions', mine.companyId)).toBe(0);
  });

  it('tells the owner of another company that there is no such company, which is all they may know', async () => {
    expect(await refused(theirs.ownerId, mine.companyId)).toContain('unknown_company');
    expect(await count('bank_transactions', mine.companyId)).toBe(0);
  });

  it('refuses somebody who lost bank.write alone, by the capability and not by the role', async () => {
    const userId = await newUser(db);
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_revoked) values ($1, $2, 'accountant', array['bank.write'])`,
      [mine.companyId, userId],
    );
    expect(await refused(userId, mine.companyId)).toContain('not_allowed');
  });

  it('lets the owner import, as authenticated, and touches no other company that has the same account', async () => {
    const [report] = await attempt(mine.ownerId, mine.companyId);
    expect(report).toMatchObject({ lines_imported: 11 });
    expect(await count('bank_transactions', mine.companyId)).toBe(11);
    expect(await count('bank_transactions', theirs.companyId)).toBe(0);
    expect(await count('bank_statements', theirs.companyId)).toBe(0);
  });

  it('keeps the two companies apart the other way round: the same file is new to the other one', async () => {
    const [report] = await attempt(theirs.ownerId, theirs.companyId);
    expect(report).toMatchObject({ already_imported: false, lines_imported: 11, lines_known: 0 });
    expect(await count('bank_transactions', mine.companyId)).toBe(11);
  });

  it('is not callable by anon', async () => {
    const message = await asUser(db, crypto.randomUUID(), () => expectError(db, `select * from import_bank_statement($1, $2::jsonb)`, [mine.companyId, file]), 'anon');
    expect(message).toContain('permission denied');
  });
});

describe('on a session nobody prepared', () => {
  // The pattern of `fresh_session.test.ts`: the database reloaded into a second
  // instance, where `ekwo.installing` was never set and answers NULL. A caller
  // with no session and no key — which is what `service_role` is — holds no
  // capability and is not the installer, and a guard that negated a NULL would
  // have let it through.
  it('refuses a caller with no session and no key, and writes nothing', async () => {
    const company = await newCompany(db, { name: 'Session Neuve' });
    await bankAccount(company.companyId, ACCOUNT);
    const fresh = new PGlite({ loadDataDir: await db.dumpDataDir('none') });
    await fresh.waitReady;
    try {
      const { setting } = await one<{ setting: string | null }>(fresh, `select current_setting('ekwo.installing', true) as setting`);
      expect(setting).toBeNull();
      await fresh.exec(`set role service_role;`);
      try {
        const message = await expectError(fresh, `select * from import_bank_statement($1, $2::jsonb)`, [
          company.companyId,
          JSON.stringify(readCamt053(golden)),
        ]);
        expect(message).toContain('not_allowed');
      } finally {
        await fresh.exec(`reset role;`);
      }
      const { n } = await one<{ n: number }>(fresh, `select count(*)::int as n from bank_transactions where company_id = $1`, [company.companyId]);
      expect(n).toBe(0);
    } finally {
      await fresh.close();
    }
  });
});
