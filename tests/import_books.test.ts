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
import { importBooks, proposeAccount, type BookFile, type ImportMapping } from '@ekwo-ai/core';
import { freshDatabase, one, repoRoot, rows } from './helpers/db.js';
import { newCompany, newUser } from './helpers/factory.js';
import { roleOf, somePack } from './helpers/packs.js';
import { backendFor } from './mcp/helpers.js';

const HOME = somePack.manifest.country;
const journalRoles = somePack.manifest.defaults.journal_roles as Record<string, string>;

const fixture = (brick: string, name: string): BookFile => ({
  name,
  content: readFileSync(join(repoRoot, 'packages', 'formats', brick, 'test', 'fixtures', name), 'utf8'),
});

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
    ).rejects.toThrow(/import_already_done/);
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
});

describe('the proposal reads the codes and nothing else', () => {
  const chart = [
    { code: '411000', name: 'Customers', account_type: 'asset_receivable', deprecated: false },
    { code: '401000', name: 'Suppliers', account_type: 'liability_payable', deprecated: false },
    { code: '4010', name: 'Suppliers again', account_type: 'liability_payable', deprecated: true },
    { code: '6061', name: 'Water', account_type: 'expense', deprecated: false },
    { code: '6062', name: 'Power', account_type: 'expense', deprecated: false },
  ];

  it('the same code, the same digits without their padding, the longest beginning of three or more', () => {
    expect(proposeAccount('411000', chart)).toEqual({ target: '411000', basis: 'exact' });
    expect(proposeAccount('411', chart)).toEqual({ target: '411000', basis: 'same-digits' });
    expect(proposeAccount('401ACME', chart)).toEqual({ target: '401000', basis: 'prefix' });
    expect(proposeAccount('606100', chart)).toEqual({ target: '6061', basis: 'same-digits' });
    expect(proposeAccount('60612', chart)).toEqual({ target: '6061', basis: 'prefix' });
  });

  it('answers nothing on a tie, on two digits, or on a deprecated account', () => {
    expect(proposeAccount('606', chart)).toEqual({ target: null, basis: 'none' });
    expect(proposeAccount('61', chart)).toEqual({ target: null, basis: 'none' });
    expect(proposeAccount('4010', chart)).toEqual({ target: '401000', basis: 'same-digits' });
  });
});
