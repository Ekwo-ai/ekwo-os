/**
 * Books taken over from an export, through `importBooks()` of the core and
 * `import_books()` of the schema — the function `ekwo import` and the MCP tool
 * `import_books` both call.
 *
 * The files are the fixtures of the readers, written for a chart nobody here
 * uses; the correspondence to the company's chart is given the way a user
 * gives it, from the roles of the pack the company was installed from. So the
 * scenario books in some country, and nothing it expects names one.
 */

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { importBooks, proposeAccount, readBooks, type BookFile, type ImportMapping, type ProposedAccount, type SourceAccount } from '@ekwo-ai/core';
import type { Pack } from '../packages/cli/src/index.js';
import { MAX_TEXT_KIB, cliEquivalent, importBooksTool } from '../packages/mcp/src/tools/import-books.js';
import { freshDatabase, one, repoRoot, rows } from './helpers/db.js';
import { newCompany, newUser } from './helpers/factory.js';
import { allPacks, packsWhere, roleOf, somePack } from './helpers/packs.js';
import { backendFor } from './mcp/helpers.js';

const HOME = somePack.manifest.country;
const journalRoles = somePack.manifest.defaults.journal_roles as Record<string, string>;

const fixture = (brick: string, name: string): BookFile => ({
  name,
  content: readFileSync(join(repoRoot, 'packages', 'formats', brick, 'test', 'fixtures', name), 'utf8'),
});

const fixtureAt = (path: string): BookFile => ({ name: path, content: readFileSync(join(repoRoot, path), 'utf8') });

const FEC = fixture('fec', 'sample.fec.txt');

/** What a user answers for the FEC fixture, in the company's own codes. */
const FEC_MAPPING: Partial<ImportMapping> = {
  accounts: {
    '512000': roleOf(somePack, 'bank'),
    '101000': roleOf(somePack, 'retained_earnings'),
    '411000': roleOf(somePack, 'receivable'),
    '706000': roleOf(somePack, 'sales'),
    '445710': roleOf(somePack, 'tax_payable'),
    '606100': roleOf(somePack, 'purchase'),
    '445660': roleOf(somePack, 'tax_receivable'),
    '401000': roleOf(somePack, 'payable'),
  },
  journals: {
    AN: '@opening',
    VE: journalRoles['sales']!,
    AC: journalRoles['purchase']!,
    BQ: journalRoles['miscellaneous']!,
  },
};

let db: PGlite;
let owner: string;
let viewer: string;

async function company(name: string): Promise<string> {
  const { companyId } = await newCompany(db, { country: HOME, name, ownerId: owner });
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [companyId, viewer]);
  return companyId;
}

const count = async (table: string, companyId: string): Promise<number> =>
  (await one<{ n: number }>(db, `select count(*)::int as n from ${table} where company_id = $1`, [companyId])).n;

beforeAll(async () => {
  db = await freshDatabase();
  owner = await newUser(db, 'owner@example.test');
  viewer = await newUser(db, 'viewer@example.test');
});

afterAll(async () => {
  await db.close();
});

describe('a FEC taken over whole', () => {
  let companyId: string;
  let answer: Record<string, unknown>;

  beforeAll(async () => {
    companyId = await company('Import One');
  });

  it('proposes a correspondence for every account and every journal before anything is answered, and writes nothing', async () => {
    const rehearsal = await importBooks(backendFor(db, owner), { company_id: companyId, source: 'fec', files: [FEC], dry_run: true });
    const mapping = rehearsal['mapping'] as ImportMapping;
    expect(Object.keys(mapping.accounts).sort()).toEqual(['101000', '401000', '411000', '445660', '445710', '512000', '606100', '706000']);
    expect(Object.keys(mapping.journals).sort()).toEqual(['AC', 'AN', 'BQ', 'VE']);
    expect(await count('entries', companyId)).toBe(0);
  });

  it('rehearses the import with the correspondence, and takes all of it back', async () => {
    const rehearsal = await importBooks(backendFor(db, owner), {
      company_id: companyId, source: 'fec', files: [FEC], mapping: FEC_MAPPING, dry_run: true, open_years: true,
    });
    expect(rehearsal['refusals']).toEqual([]);
    const result = rehearsal['result'] as Record<string, unknown>;
    expect(result['dry_run']).toBe(true);
    expect(result['entries']).toBe(4);
    expect(result['opening_number']).not.toBeNull();
    expect(result['contacts_created']).toBe(3);
    expect((result['fiscal_years_opened'] as unknown[]).length).toBe(1);

    expect(await count('entries', companyId)).toBe(0);
    expect(await count('contacts', companyId)).toBe(0);
    expect(await count('book_imports', companyId)).toBe(0);
    expect(await count('fiscal_years', companyId)).toBe(1);
  });

  it('refuses entries that fall in no fiscal year unless it is asked to open them', async () => {
    await expect(
      importBooks(backendFor(db, owner), { company_id: companyId, source: 'fec', files: [FEC], mapping: FEC_MAPPING }),
    ).rejects.toThrow(/import_outside_fiscal_year/);
    expect(await count('entries', companyId)).toBe(0);
  });

  it('posts every entry through post_entry(), and the opening through opening_balance()', async () => {
    answer = await importBooks(backendFor(db, owner), {
      company_id: companyId, source: 'fec', files: [FEC], mapping: FEC_MAPPING, open_years: true,
    });
    const result = answer['result'] as Record<string, unknown>;
    expect(result['dry_run']).toBe(false);

    const entries = await rows<{ number: string; state: string; kind: string; reference: string | null; balanced: boolean; posted: boolean }>(
      db,
      `select number, state::text, kind::text, reference, total_debit = total_credit as balanced, posted_at is not null as posted
         from entries where company_id = $1 order by entry_date, number`,
      [companyId],
    );
    expect(entries).toHaveLength(5);
    expect(entries.every((e) => e.state === 'posted' && e.balanced && e.posted)).toBe(true);
    expect(entries.filter((e) => e.kind === 'opening')).toHaveLength(1);
    expect(entries.map((e) => e.reference)).toContain('F-001');
    expect(result['opening_number']).toBe(entries.find((e) => e.kind === 'opening')?.number);
  });

  it('opens the year before on the rhythm of the company', async () => {
    const years = await rows<{ start_date: string; end_date: string }>(
      db, `select start_date::text, end_date::text from fiscal_years where company_id = $1 order by start_date`, [companyId],
    );
    expect(years.map((y) => [y.start_date, y.end_date])).toEqual([
      ['2025-01-01', '2025-12-31'],
      ['2026-01-01', '2026-12-31'],
    ]);
  });

  it('keeps every amount, the foreign currency, and the ledger in balance', async () => {
    const totals = await one<{ debit: string; credit: string }>(
      db, `select sum(debit)::text as debit, sum(credit)::text as credit from entry_lines where company_id = $1`, [companyId],
    );
    expect(totals).toEqual({ debit: '7852.00', credit: '7852.00' });
    const foreign = await one<{ currency_code: string; amount_currency: string }>(
      db, `select currency_code, amount_currency::text from entry_lines where company_id = $1 and currency_code is not null limit 1`, [companyId],
    );
    expect(foreign).toEqual({ currency_code: 'USD', amount_currency: '100.00' });
  });

  it('creates each party once, a customer or a supplier by where its lines are booked', async () => {
    const contacts = await rows<{ name: string; contact_type: string; auxiliary_code: string }>(
      db, `select name, contact_type::text, auxiliary_code from contacts where company_id = $1 order by auxiliary_code`, [companyId],
    );
    expect(contacts).toEqual([
      { name: 'Atelier Sirocco', contact_type: 'customer', auxiliary_code: 'C0001' },
      { name: 'Verger du Moulin', contact_type: 'supplier', auxiliary_code: 'F0001' },
      { name: 'Kestrel Joinery', contact_type: 'supplier', auxiliary_code: 'F0002' },
    ]);
  });

  it('records the import, and refuses the same files a second time', async () => {
    const record = await one<{ source: string; entry_count: number; file_names: string[] }>(
      db, `select source, entry_count, file_names from book_imports where company_id = $1`, [companyId],
    );
    expect(record).toEqual({ source: 'fec', entry_count: 4, file_names: ['sample.fec.txt'] });
    await expect(
      importBooks(backendFor(db, owner), { company_id: companyId, source: 'fec', files: [FEC], mapping: FEC_MAPPING, open_years: true }),
    ).rejects.toThrow(/import_already_done: sample\.fec\.txt \(fec\) was imported on \d{4}-\d{2}-\d{2} \d{2}:\d{2} UTC: 4 entries, numbered \S+ to \S+ and the opening entry \S+ and \d+ lines\./);
    expect(await count('entries', companyId)).toBe(5);
  });
});

describe('all or nothing', () => {
  it('leaves nothing behind when one entry is refused, not even the years and the parties', async () => {
    const companyId = await company('Import Locked');
    await db.query(`insert into fiscal_years (company_id, name, start_date, end_date) values ($1, 'FY2025', '2025-01-01', '2025-12-31')`, [companyId]);
    await db.query(`update companies set lock_date = '2025-01-20' where id = $1`, [companyId]);
    await expect(
      importBooks(backendFor(db, owner), { company_id: companyId, source: 'fec', files: [FEC], mapping: FEC_MAPPING }),
    ).rejects.toThrow(/period_locked/);
    expect(await count('entries', companyId)).toBe(0);
    expect(await count('contacts', companyId)).toBe(0);
    expect(await count('book_imports', companyId)).toBe(0);
  });

  it('posts nothing while an account or a journal has no answer, and says which', async () => {
    const companyId = await company('Import Unmapped');
    const partial = { ...FEC_MAPPING, accounts: { ...FEC_MAPPING.accounts, '606100': null } };
    const rehearsal = await importBooks(backendFor(db, owner), {
      company_id: companyId, source: 'fec', files: [FEC], mapping: partial, dry_run: true, open_years: true,
    });
    // Either the codes propose an account of this chart for 606100 or they do
    // not; what is asserted is that an unanswered one stops everything.
    if ((rehearsal['unmapped_accounts'] as string[]).includes('606100')) {
      expect(rehearsal['result']).toBeNull();
      await expect(
        importBooks(backendFor(db, owner), { company_id: companyId, source: 'fec', files: [FEC], mapping: partial, open_years: true }),
      ).rejects.toThrow(/import_unmapped_accounts: .*606100/);
    }
    await expect(
      importBooks(backendFor(db, owner), {
        company_id: companyId, source: 'fec', files: [FEC], open_years: true,
        mapping: { ...FEC_MAPPING, accounts: { ...FEC_MAPPING.accounts, '606100': 'NOT-AN-ACCOUNT' } },
      }),
    ).rejects.toThrow(/unknown_account: NOT-AN-ACCOUNT/);
    expect(await count('entries', companyId)).toBe(0);
  });

  it('refuses books whose reader found something that does not add up', async () => {
    const companyId = await company('Import Unbalanced');
    const broken = { name: 'broken.txt', content: (FEC.content as string).replace('0,00|1000,00|||20250115', '0,00|999,00|||20250115') };
    await expect(
      importBooks(backendFor(db, owner), { company_id: companyId, source: 'fec', files: [broken], mapping: FEC_MAPPING, open_years: true }),
    ).rejects.toThrow(/import_violations/);
  });

  it('refuses a member who may only read', async () => {
    const companyId = await company('Import Viewer');
    await expect(
      importBooks(backendFor(db, viewer), { company_id: companyId, source: 'fec', files: [FEC], mapping: FEC_MAPPING, open_years: true }),
    ).rejects.toThrow(/not_allowed/);
  });
});

describe('a trial balance as the opening of a year', () => {
  const BALANCE = fixture('trial-balance', 'balance.csv');
  const mapping: Partial<ImportMapping> = {
    accounts: {
      '512000': roleOf(somePack, 'bank'),
      '411000': roleOf(somePack, 'receivable'),
      '401000': roleOf(somePack, 'payable'),
      '101000': roleOf(somePack, 'retained_earnings'),
      '120000': roleOf(somePack, 'retained_earnings'),
      '218300': roleOf(somePack, 'bank'),
    },
  };

  it('needs the day it opens, which the file does not say', async () => {
    const companyId = await company('Balance Dateless');
    await expect(
      importBooks(backendFor(db, owner), { company_id: companyId, source: 'trial-balance', files: [BALANCE], mapping }),
    ).rejects.toThrow(/missing_opening_date/);
  });

  it('refuses a day that is not the first of a year', async () => {
    const companyId = await company('Balance Mid Year');
    await expect(
      importBooks(backendFor(db, owner), { company_id: companyId, source: 'trial-balance', files: [BALANCE], mapping, opening_date: '2026-03-01' }),
    ).rejects.toThrow(/opening_not_first_day/);
  });

  it('posts one opening entry, with the parties of the receivables and payables', async () => {
    const companyId = await company('Balance Opened');
    const answer = await importBooks(backendFor(db, owner), {
      company_id: companyId, source: 'trial-balance', files: [BALANCE], mapping, opening_date: '2026-01-01',
    });
    const result = answer['result'] as Record<string, unknown>;
    expect(result['entries']).toBe(0);
    const opening = await one<{ kind: string; total_debit: string; entry_date: string }>(
      db, `select kind::text, total_debit::text, entry_date::text from entries where company_id = $1`, [companyId],
    );
    expect(opening).toEqual({ kind: 'opening', total_debit: '10150.50', entry_date: '2026-01-01' });
    expect(await count('contacts', companyId)).toBe(3);
    const named = await one<{ n: number }>(
      db, `select count(*)::int as n from entry_lines where company_id = $1 and contact_id is not null`, [companyId],
    );
    expect(named.n).toBe(3);

    // A balance has no entry: the refusal of a second import says what it did write.
    const again = importBooks(backendFor(db, owner), {
      company_id: companyId, source: 'trial-balance', files: [BALANCE], mapping, opening_date: '2026-01-01',
    });
    await expect(again).rejects.toThrow(/import_already_done: balance\.csv \(trial-balance\) was imported on .* UTC: the opening entry \S+ and \d+ lines\./);
    await expect(again).rejects.not.toThrow(/0 entries/);
  });

  it('refuses an income or expense account unless the books are taken over in the middle of a year', async () => {
    const companyId = await company('Balance Result');
    const withSales = { accounts: { ...mapping.accounts, '120000': roleOf(somePack, 'sales') } };
    await expect(
      importBooks(backendFor(db, owner), { company_id: companyId, source: 'trial-balance', files: [BALANCE], mapping: withSales, opening_date: '2026-01-01' }),
    ).rejects.toThrow(/opening_result_account/);
    const answer = await importBooks(backendFor(db, owner), {
      company_id: companyId, source: 'trial-balance', files: [BALANCE], mapping: withSales, opening_date: '2026-01-01', allow_result_accounts: true,
    });
    expect((answer['result'] as Record<string, unknown>)['opening_number']).not.toBeNull();
  });
});

describe('the exports of other ledgers, through the same function', () => {
  it('takes over journal items with their chart and partners', async () => {
    const companyId = await company('Items');
    const files = [fixture('journal-items', 'journal-items.csv'), fixture('journal-items', 'accounts.csv'), fixture('journal-items', 'partners.csv')];
    const general = journalRoles['miscellaneous']!;
    const mapping: Partial<ImportMapping> = {
      accounts: {
        '101000': roleOf(somePack, 'retained_earnings'),
        '550000': roleOf(somePack, 'bank'),
        '400000': roleOf(somePack, 'receivable'),
        '700000': roleOf(somePack, 'sales'),
        '451000': roleOf(somePack, 'tax_payable'),
        '440000': roleOf(somePack, 'payable'),
        '610000': roleOf(somePack, 'purchase'),
      },
      journals: { 'Miscellaneous Operations': general, 'Customer Invoices': journalRoles['sales']!, 'Vendor Bills': journalRoles['purchase']! },
    };
    // The export states the currency of the company it came from. Written in
    // this company's currency it is taken; in any other it is refused before
    // the database is asked.
    const currency = (await one<{ currency_code: string }>(db, `select currency_code from companies where id = $1`, [companyId])).currency_code;
    const other = currency === 'USD' ? 'EUR' : 'USD';
    const inCurrency = (code: string): BookFile[] =>
      files.map((file) => ({ ...file, content: (file.content as string).replaceAll('"EUR"', `"${code}"`) }));

    const refused = await importBooks(backendFor(db, owner), { company_id: companyId, source: 'journal-items', files: inCurrency(other), mapping, open_years: true, dry_run: true });
    expect((refused['refusals'] as string[]).some((r) => r.startsWith('import_currency_mismatch'))).toBe(true);

    const done = await importBooks(backendFor(db, owner), { company_id: companyId, source: 'journal-items', files: inCurrency(currency), mapping, open_years: true });
    expect((done['result'] as Record<string, unknown>)['entries']).toBe(3);
    const partner = await one<{ contact_type: string; email: string; vat_number: string }>(
      db, `select contact_type::text, email, vat_number from contacts where company_id = $1 and name = 'Atelier Sirocco'`, [companyId],
    );
    expect(partner).toEqual({ contact_type: 'customer', email: 'accounts@sirocco.example', vat_number: 'XX0000000001' });
  });

  it('takes over a journal report, its dates read in the order the caller names', async () => {
    const companyId = await company('Report');
    const files = [fixture('journal-report', 'journal-report.csv'), fixture('journal-report', 'chart.csv')];
    const mapping: Partial<ImportMapping> = {
      accounts: {
        '090': roleOf(somePack, 'bank'),
        '970': roleOf(somePack, 'retained_earnings'),
        '610': roleOf(somePack, 'receivable'),
        '200': roleOf(somePack, 'sales'),
        '820': roleOf(somePack, 'tax_payable'),
      },
    };
    await expect(
      importBooks(backendFor(db, owner), { company_id: companyId, source: 'journal-report', files, mapping, open_years: true }),
    ).rejects.toThrow(/in which order/);
    const answer = await importBooks(backendFor(db, owner), {
      company_id: companyId, source: 'journal-report', files, mapping, open_years: true, date_order: 'dmy',
    });
    // A report names no journal code: every entry goes to the general journal the proposal found.
    expect(Object.values((answer['mapping'] as ImportMapping).journals).every((code) => code === journalRoles['miscellaneous'])).toBe(true);
    expect((answer['result'] as Record<string, unknown>)['entries']).toBe(3);
  });

  it('takes over an audit file, its opening balance on the day the file gives, the ledger even to the cent', async () => {
    const companyId = await company('Audit file');
    const currency = (await one<{ currency_code: string }>(db, `select currency_code from companies where id = $1`, [companyId])).currency_code;
    // The file states the currency of its books; written in this company's, it is taken.
    const file = fixture('xaf', 'books.v4.xaf');
    const files: BookFile[] = [{ ...file, content: (file.content as string).replace('<curCode>EUR</curCode>', `<curCode>${currency}</curCode>`) }];
    const mapping: Partial<ImportMapping> = {
      accounts: {
        '0500': roleOf(somePack, 'retained_earnings'),
        '1100': roleOf(somePack, 'bank'),
        '1300': roleOf(somePack, 'receivable'),
        '1500': roleOf(somePack, 'tax_payable'),
        '1600': roleOf(somePack, 'payable'),
        '4500': roleOf(somePack, 'purchase'),
        '8000': roleOf(somePack, 'sales'),
      },
      journals: { VK: journalRoles['sales']!, IK: journalRoles['purchase']!, BNK: journalRoles['miscellaneous']! },
    };

    const rehearsal = await importBooks(backendFor(db, owner), { company_id: companyId, source: 'xaf', files, mapping, open_years: true, dry_run: true });
    expect(rehearsal['refusals']).toEqual([]);
    expect(await count('entries', companyId)).toBe(0);

    const done = await importBooks(backendFor(db, owner), { company_id: companyId, source: 'xaf', files, mapping, open_years: true });
    const result = done['result'] as Record<string, unknown>;
    expect(result['entries']).toBe(4);
    expect(result['opening_number']).not.toBeNull();

    const opening = await one<{ entry_date: string; total_debit: string }>(
      db, `select entry_date::text, total_debit::text from entries where company_id = $1 and kind = 'opening'`, [companyId],
    );
    expect(opening).toEqual({ entry_date: '2025-01-01', total_debit: '5000.00' });
    // The opening, 5000.00, and the four transactions, 2512.00: each side to the cent.
    const totals = await one<{ debit: string; credit: string }>(
      db, `select sum(debit)::text as debit, sum(credit)::text as credit from entry_lines where company_id = $1`, [companyId],
    );
    expect(totals).toEqual({ debit: '7512.00', credit: '7512.00' });
    const receivable = await one<{ balance: string }>(
      db,
      `select sum(l.debit - l.credit)::text as balance from entry_lines l join accounts a on a.id = l.account_id
        where l.company_id = $1 and a.code = $2`,
      [companyId, roleOf(somePack, 'receivable')],
    );
    // Invoiced 1210.00, credited 121.00, paid 1089.00: nothing left open.
    expect(Number(receivable.balance)).toBe(0);
    const parties = await rows<{ name: string; contact_type: string; auxiliary_code: string }>(
      db, `select name, contact_type::text, auxiliary_code from contacts where company_id = $1 order by auxiliary_code`, [companyId],
    );
    expect(parties).toEqual([
      { name: 'Atelier Sirocco', contact_type: 'customer', auxiliary_code: 'C01' },
      { name: 'Kestrel Joinery', contact_type: 'supplier', auxiliary_code: 'S02' },
    ]);
  });
});

/** An account of the old books, as the proposal reads it. */
const old = (code: string, name: string | null = null, type: string | null = null, side: 'debit' | 'credit' | null = null): SourceAccount => ({ code, name, type, side });

/** A pack's default chart, as the proposal reads the company's. */
const chartOf = (pack: Pack) => pack.accounts.map((account) => ({ code: account.code, name: account.name, account_type: account.type, deprecated: false }));

/** A code without the zeros it was padded with on the right, the way the proposal compares digits. */
const digitsOf = (code: string): string => code.replace(/0+$/, '') || code;

describe('the proposal: the codes give a candidate, the files confirm it', () => {
  const chart = [
    { code: '411000', name: 'Customers', account_type: 'asset_receivable', deprecated: false },
    { code: '401000', name: 'Suppliers', account_type: 'liability_payable', deprecated: false },
    { code: '4010', name: 'Suppliers again', account_type: 'liability_payable', deprecated: true },
    { code: '6061', name: 'Water', account_type: 'expense', deprecated: false },
    { code: '6062', name: 'Power', account_type: 'expense', deprecated: false },
  ];

  it('is exact only for the same code, where the files say the same kind of account', () => {
    expect(proposeAccount(old('411000', 'Customers'), chart)).toMatchObject({ target: '411000', basis: 'exact', match: 'same-code', doubtful: false });
    expect(proposeAccount(old('6061', null, null, 'debit'), chart)).toMatchObject({ target: '6061', basis: 'exact' });
  });

  it('only suggests the same digits and the longest beginning, with the reason', () => {
    const digits = proposeAccount(old('411', 'Clients'), chart);
    expect(digits).toMatchObject({ target: '411000', basis: 'suggested', match: 'same-digits', doubtful: true });
    expect(digits.reason).toContain('the same digits');
    expect(proposeAccount(old('401ACME', null, null, 'credit'), chart)).toMatchObject({ target: '401000', basis: 'suggested', match: 'prefix' });
    expect(proposeAccount(old('606100', null, null, 'debit'), chart)).toMatchObject({ target: '6061', basis: 'suggested', match: 'same-digits' });
    expect(proposeAccount(old('60612', null, null, 'debit'), chart)).toMatchObject({ target: '6061', basis: 'suggested', match: 'prefix' });
  });

  it('does not take the same code for certain when the files say nothing of the account', () => {
    const silent = proposeAccount(old('6061'), chart);
    expect(silent).toMatchObject({ target: '6061', basis: 'suggested', doubtful: true });
    expect(silent.reason).toContain('nothing in the files');
  });

  it('drops a candidate the files contradict, and names the one account of the kind they say', () => {
    const contradicted = proposeAccount(old('6061', 'Customers', null, 'debit'), chart);
    expect(contradicted).toMatchObject({ target: '411000', basis: 'suggested', match: 'kind' });
    expect(contradicted.reason).toContain('6061');
    expect(proposeAccount(old('6062', 'Sales', 'Revenue', 'credit'), chart)).toMatchObject({ target: null, basis: 'none' });
  });

  it('leaves to the user a candidate only the side of the balance disagrees with', () => {
    // An accumulated depreciation is an asset with a credit balance: the side
    // alone never drops a candidate, and never confirms one against it.
    const side = proposeAccount(old('6062', 'Deposits received', null, 'credit'), chart);
    expect(side).toMatchObject({ target: '6062', basis: 'suggested', doubtful: true });
    expect(side.reason).toContain('credit side');
  });

  it('answers nothing on a tie, on two digits, or on a deprecated account', () => {
    expect(proposeAccount(old('606', null, null, 'debit'), chart)).toMatchObject({ target: null, basis: 'none' });
    expect(proposeAccount(old('61', null, null, 'debit'), chart)).toMatchObject({ target: null, basis: 'none' });
    expect(proposeAccount(old('4010', 'Suppliers', null, 'credit'), chart)).toMatchObject({ target: '401000', basis: 'suggested', match: 'same-digits' });
  });

  it('gives back every account of a chart, exact, from that same chart', () => {
    for (const pack of allPacks) {
      const own = chartOf(pack);
      const wrong = own.filter((account) => {
        const proposal = proposeAccount(old(account.code, account.name), own);
        return proposal.basis !== 'exact' || proposal.target !== account.code;
      });
      expect(wrong.map((account) => `${pack.slug} ${account.code}`)).toEqual([]);
    }
  });
});

describe('two charts that give the same digits to different things', () => {
  // A receivable of one chart is 610; in these packs the same digits are an
  // account of another kind — an expense, typically. Read from the charts, so
  // every pack where it holds is tested and none is named.
  const clashes = packsWhere('whose chart gives the digits of 610 to an account that is not a receivable', (pack) =>
    pack.accounts.some((account) => digitsOf(account.code) === '61' && account.type !== 'asset_receivable'),
  );
  const typeIn = (pack: Pack, code: string | null): string | undefined => pack.accounts.find((account) => account.code === code)?.type;

  it('holds in the charts of more than one country', () => {
    expect(new Set(clashes.map((pack) => pack.manifest.country)).size).toBeGreaterThanOrEqual(2);
  });

  it('never sends a receivable to them, whether the files give a type, a name in any language, or only a balance', () => {
    for (const pack of clashes) {
      for (const receivable of [
        old('610', 'Accounts Receivable', 'Accounts Receivable', 'debit'),
        old('610', 'Accounts receivable', null, 'debit'),
        old('610', 'Clients', null, 'debit'),
        old('610', 'Debiteuren', null, 'debit'),
      ]) {
        const proposal = proposeAccount(receivable, chartOf(pack));
        expect(proposal.basis, `${pack.slug}: ${receivable.name}`).not.toBe('exact');
        if (proposal.target !== null) expect(typeIn(pack, proposal.target), `${pack.slug}: ${receivable.name}`).toBe('asset_receivable');
        expect(proposal.reason).not.toBeNull();
      }
      const payable = proposeAccount(old('800', 'Accounts payable', null, 'credit'), chartOf(pack));
      expect(payable.basis).not.toBe('exact');
      if (payable.target !== null) expect(typeIn(pack, payable.target), pack.slug).toBe('liability_payable');
    }
  });

  it('posts none of it from an export of entries, until the user answers', async () => {
    const pack = clashes[0]!;
    const { companyId } = await newCompany(db, { country: pack.manifest.country, name: 'Report Clash', ownerId: owner });
    const files = [fixture('journal-report', 'journal-report.csv'), fixture('journal-report', 'chart.csv')];
    const base = { company_id: companyId, source: 'journal-report' as const, files, open_years: true, date_order: 'dmy' as const };

    const rehearsal = await importBooks(backendFor(db, owner), { ...base, dry_run: true });
    const receivable = (rehearsal['accounts'] as ProposedAccount[]).find((account) => account.source === '610')!;
    expect(receivable.doubtful).toBe(true);
    if (receivable.target !== null) expect(typeIn(pack, receivable.target)).toBe('asset_receivable');
    expect((rehearsal['mapping'] as ImportMapping).accounts['610']).toBeNull();
    expect(rehearsal['result']).toBeNull();

    await expect(importBooks(backendFor(db, owner), base)).rejects.toThrow(/import_un(confirmed|mapped)_accounts: .*610/);
    expect(await count('entries', companyId)).toBe(0);
    // Accepting every suggestion accepts no clash either: 610 was never suggested onto one.
    const accepted = await importBooks(backendFor(db, owner), { ...base, accept_suggestions: true, dry_run: true });
    const taken = (accepted['mapping'] as ImportMapping).accounts['610'] ?? null;
    if (taken !== null) expect(typeIn(pack, taken)).toBe('asset_receivable');

    // An answer the files contradict is the user's to give, and is still said.
    const clash = pack.accounts.find((account) => digitsOf(account.code) === '61' && account.type !== 'asset_receivable')!;
    const given = await importBooks(backendFor(db, owner), { ...base, mapping: { accounts: { '610': clash.code } }, dry_run: true });
    const answered = (given['accounts'] as ProposedAccount[]).find((account) => account.source === '610')!;
    expect(answered).toMatchObject({ target: clash.code, basis: 'given', doubtful: true });
    expect(answered.reason).toContain('Accounts Receivable');
  });
});

describe('a suggestion waits for the user', () => {
  // Two accounts of the company's own chart, written in the old books with one
  // more padding zero: the same digits, so only suggested.
  const own = somePack.accounts.filter((account) => somePack.accounts.filter((other) => digitsOf(other.code) === digitsOf(account.code)).length === 1);
  const asset = own.find((account) => account.type === 'asset_cash')!;
  const equity = own.find((account) => account.type.startsWith('equity'))!;
  const balance: BookFile = {
    name: 'padded.csv',
    content: `account,name,debit,credit\n${asset.code}0,${asset.name},250.00,\n${equity.code}0,${equity.name},,250.00\n`,
  };
  const base = (companyId: string) => ({ company_id: companyId, source: 'trial-balance' as const, files: [balance], opening_date: '2026-01-01' });

  it('is refused until it is confirmed, and taken once it is', async () => {
    const companyId = await company('Suggested');
    const rehearsal = await importBooks(backendFor(db, owner), { ...base(companyId), dry_run: true });
    expect(rehearsal['unconfirmed_accounts']).toEqual([`${asset.code}0`, `${equity.code}0`].sort());
    const mapping = rehearsal['mapping'] as ImportMapping;
    expect(mapping.accounts[`${asset.code}0`]).toBeNull();
    expect(mapping.suggested?.[`${asset.code}0`]?.target).toBe(asset.code);
    expect((rehearsal['refusals'] as string[]).some((refusal) => refusal.startsWith('import_unconfirmed_accounts'))).toBe(true);

    await expect(importBooks(backendFor(db, owner), base(companyId))).rejects.toThrow(/import_unconfirmed_accounts/);
    expect(await count('entries', companyId)).toBe(0);

    const accepted = await importBooks(backendFor(db, owner), { ...base(companyId), accept_suggestions: true });
    expect((accepted['result'] as Record<string, unknown>)['opening_number']).not.toBeNull();
  });

  it('is confirmed one by one by writing its code in the correspondence', async () => {
    const companyId = await company('Confirmed');
    const mapping = { accounts: { [`${asset.code}0`]: asset.code, [`${equity.code}0`]: equity.code } };
    const answer = await importBooks(backendFor(db, owner), { ...base(companyId), mapping });
    expect(answer['unconfirmed_accounts']).toEqual([]);
    expect((answer['result'] as Record<string, unknown>)['opening_number']).not.toBeNull();
  });
});

describe('the tool, for a file too large to travel as text', () => {
  it('refuses it and gives the command that imports it from the disk', async () => {
    const content = 'x'.repeat(MAX_TEXT_KIB * 1024 + 1);
    const args = { company_id: crypto.randomUUID(), source: 'fec' as const, files: [{ name: 'big export.txt', content }], open_years: true };
    await expect(importBooksTool(backendFor(db, owner), args)).rejects.toThrow(/files_too_large/);
    expect(cliEquivalent(args)).toBe(`npx -y ekwo-os@latest import fec 'big export.txt' --company ${args.company_id} --dry-run --open-years --save-mapping correspondence.json`);
  });
});

describe('the correspondence the guide shows', () => {
  // country-literal: docs/start-with-claude.md walks one Estonian and one British company through an import, and this recomputes its two tables
  const guide = [
    { slug: 'ee', file: 'ee-trial-balance.csv' },
    { slug: 'gb', file: 'gb-trial-balance.csv' },
  ];
  const page = readFileSync(join(repoRoot, 'docs', 'start-with-claude.md'), 'utf8');

  it('is what the proposal answers for its two files and its two charts', () => {
    // Every row of the two tables is checked, and the count is read off the
    // page rather than written here: a row added to the guide used to leave
    // this number behind, and a number that has to be kept in step by hand is
    // the thing it was guarding against. What it still catches is the loop
    // falling through — a fixture whose codes no longer reach the page — which
    // is a count below this one and never a stale expectation.
    const tabulated = page.split('\n').filter((line) => /^\| \d{3,6} /.test(line)).length;
    let checked = 0;
    for (const { slug, file } of guide) {
      const pack = allPacks.find((candidate) => candidate.slug === slug)!;
      const books = readBooks('trial-balance', [fixtureAt(join('docs', 'demo', 'start-with-claude', file))]);
      for (const row of page.split('\n').filter((line) => /^\| \d{3,6} /.test(line))) {
        const [, code, proposed, basis] = /^\| (\d+) [^|]+\| (\S+) \| (\w+)/.exec(row) ?? [];
        const account = books.accounts.find((candidate) => candidate.code === code);
        if (account === undefined) continue;
        const lines = books.opening.filter((line) => line.account === code);
        const debit = lines.some((line) => Number(line.debit) > 0);
        const proposal = proposeAccount(old(account.code, account.name, account.type, debit ? 'debit' : 'credit'), chartOf(pack));
        expect({ code, target: proposal.target ?? '—', basis: proposal.basis }, `${file}: ${row}`).toEqual({ code, target: proposed, basis });
        checked += 1;
      }
    }
    expect(tabulated).toBeGreaterThan(0);
    expect(checked).toBe(tabulated);
  });
});
