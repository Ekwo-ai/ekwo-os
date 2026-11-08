/**
 * Bank accounts through the tools, and the first payment they make possible.
 *
 * Everything here runs under `set role authenticated` with real JWT claims —
 * `backendFor` sets both on every call — so a viewer is refused by the policy
 * and an accountant succeeds because the policy lets them. The point of the
 * file is the setup path an operator used to have to do in SQL: without a
 * bank account, `record_payment` answered `no_bank_account` and the tools
 * offered no way out of it.
 */

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { SCHEMA_FEATURES } from '../../packages/core/src/index.js';
import { readTools, writeTools, type Backend } from '../../packages/mcp/src/index.js';
import { freshDatabase, repoRoot, rows } from '../helpers/db.js';
import { newCompany, type Fixture } from '../helpers/factory.js';
import { backendFor, ledgerOfEntry, list, record } from './helpers.js';

const IBAN = 'BE71 0961 2345 6769';

let db: PGlite;
let one: Fixture;
let two: Fixture;
let accountant: Backend;
let viewer: Backend;
let otherOwner: Backend;
let customerId: string;

beforeAll(async () => {
  db = await freshDatabase();
  // The profile of a bank account's CSV statements is kept on a schema that
  // says it has the column (`SCHEMA_FEATURES.statement_profile`). Until the
  // release that brings it redefines `ekwo_schema_version()`, this database
  // says the version it will be; `schema_floor.test.ts` proves the older one.
  await db.query(
    `create or replace function ekwo.ekwo_schema_version() returns text language sql immutable as $$ select '${SCHEMA_FEATURES.statement_profile.since}'::text $$`,
  );
  one = await newCompany(db, { country: 'BE', name: 'Banque Une SRL' });
  two = await newCompany(db, { country: 'BE', name: 'Banque Deux SRL' });

  const accountantId = crypto.randomUUID();
  const viewerId = crypto.randomUUID();
  await db.query(
    `insert into company_members (company_id, user_id, role)
     values ($1, $2, 'accountant'), ($1, $3, 'viewer')`,
    [one.companyId, accountantId, viewerId],
  );

  accountant = backendFor(db, accountantId);
  viewer = backendFor(db, viewerId);
  otherOwner = backendFor(db, two.ownerId);

  const contact = record(
    await writeTools.createContact(accountant, {
      company_id: one.companyId,
      name: 'Cliente Banque',
      contact_type: 'customer',
    }),
  );
  customerId = String(record(contact['contact'])['id']);
});

afterAll(async () => {
  await db.close();
});

describe('create_bank_account', () => {
  it('says there is none before there is one', async () => {
    const empty = record(await readTools.listBankAccounts(accountant, { company_id: one.companyId }));
    expect(list(empty['bank_accounts'])).toHaveLength(0);
    expect(String(empty['note'])).toContain('create_bank_account');
  });

  it('is refused to a viewer, by the schema and by name', async () => {
    await expect(
      writeTools.createBankAccount(viewer, { company_id: one.companyId, iban: 'BE68539007547034' }),
    ).rejects.toThrow(/not_allowed.*bank\.write/);

    const still = await rows(db, 'select id from bank_accounts where company_id = $1', [
      one.companyId,
    ]);
    expect(still).toHaveLength(0);
  });

  it('takes the journal and the ledger account from the country template', async () => {
    const created = record(
      await writeTools.createBankAccount(accountant, {
        company_id: one.companyId,
        iban: IBAN,
        bic: 'GKCCBEBB',
        bank_name: 'Banque Exemple',
      }),
    );
    expect(created['created']).toBe(true);

    const account = record(created['bank_account']);
    // Spaces out, upper case in: the IBAN is the natural key of the row.
    expect(account['iban']).toBe('BE71096123456769');
    expect(account['bic']).toBe('GKCCBEBB');
    expect(account['name']).toBe('Banque Exemple');
    expect(record(created['journal'])['code']).toBe('BNK');

    const ledger = await rows<{ code: string }>(
      db,
      'select a.code from bank_accounts b join accounts a on a.id = b.account_id where b.id = $1',
      [account['id']],
    );
    // 550000 is where the Belgian model points the bank journal.
    expect(ledger[0]?.code).toBe('550000');

    const journal = await rows<{ bank_account_id: string }>(
      db,
      `select bank_account_id from journals where company_id = $1 and code = 'BNK'`,
      [one.companyId],
    );
    expect(journal[0]?.bank_account_id).toBe(account['id']);
  });

  it('returns the existing one rather than a second with the same IBAN', async () => {
    const again = record(
      await writeTools.createBankAccount(accountant, {
        company_id: one.companyId,
        iban: 'be71096123456769',
      }),
    );
    expect(again['created']).toBe(false);
    const all = await rows(db, 'select id from bank_accounts where company_id = $1', [
      one.companyId,
    ]);
    expect(all).toHaveLength(1);
  });

  it('is invisible from another company of the same installation', async () => {
    const theirs = record(await readTools.listBankAccounts(otherOwner, { company_id: two.companyId }));
    expect(list(theirs['bank_accounts'])).toHaveLength(0);

    // And asking for the first company's list as the other owner returns
    // nothing at all, rather than a refusal that confirms it exists.
    const peek = record(await readTools.listBankAccounts(otherOwner, { company_id: one.companyId }));
    expect(list(peek['bank_accounts'])).toHaveLength(0);
  });
});

describe('a payment on that account', () => {
  it('books the bank side against the account the bank account carries', async () => {
    const accounts = list(
      record(await readTools.listBankAccounts(accountant, { company_id: one.companyId }))[
        'bank_accounts'
      ],
    );
    const bankAccountId = String(accounts[0]?.['id']);

    const draft = record(
      await writeTools.createDocument(accountant, {
        company_id: one.companyId,
        doc_type: 'sale_invoice',
        contact_id: customerId,
        document_date: '2026-06-15',
        lines: [
          { name: 'Conseil', unit_price: '1000.00', account_code: '704000', tax_code: 'BE-S-21' },
        ],
      }),
    );
    const documentId = String(record(draft['document'])['id']);
    await writeTools.postDocument(accountant, { document_id: documentId });

    const payment = record(
      await writeTools.recordPayment(accountant, {
        company_id: one.companyId,
        direction: 'inbound',
        amount: '1210.00',
        payment_date: '2026-06-20',
        contact_id: customerId,
        journal_code: 'BNK',
        bank_account_id: bankAccountId,
      }),
    );

    const entry = record(payment['entry']);
    expect(await ledgerOfEntry(db, String(entry['id']))).toEqual([
      { code: '550000', debit: '1210.00', credit: '0.00' },
      { code: '400000', debit: '0.00', credit: '1210.00' },
    ]);
    expect(list(payment['matched'])).toHaveLength(1);

    const document = record(
      record(await readTools.getDocument(accountant, { document_id: documentId }))['document'],
    );
    expect(document['payment_state']).toBe('paid');
  });

  it('takes the journal from the bank account when the caller names only the account', async () => {
    // Found on the first real run of the server: record_payment with a
    // bank_account_id and no journal answered missing_journal, although the
    // account had carried its journal since ekwo init created it.
    const accounts = list(
      record(await readTools.listBankAccounts(accountant, { company_id: one.companyId }))[
        'bank_accounts'
      ],
    );
    const bankAccountId = String(accounts[0]?.['id']);
    const payment = record(
      await writeTools.recordPayment(accountant, {
        company_id: one.companyId,
        direction: 'inbound',
        amount: '50.00',
        payment_date: '2026-06-21',
        bank_account_id: bankAccountId,
        match_open_items: false,
      }),
    );
    const journal = await rows<{ id: string }>(
      db,
      `select id from journals where company_id = $1 and code = 'BNK'`,
      [one.companyId],
    );
    expect(record(payment['payment'])['journal_id']).toBe(journal[0]?.id);
    expect(await ledgerOfEntry(db, String(record(payment['entry'])['id']))).toEqual([
      { code: '550000', debit: '50.00', credit: '0.00' },
      { code: '400000', debit: '0.00', credit: '50.00' },
    ]);
  });

  it('still refuses a payment that names neither a journal nor a bank account', async () => {
    await expect(
      writeTools.recordPayment(accountant, {
        company_id: one.companyId,
        direction: 'inbound',
        amount: '10.00',
        payment_date: '2026-06-21',
      }),
    ).rejects.toThrow(/missing_journal/);
  });
});

describe('settle_from_statement', () => {
  it('settles a payout net of the fee the provider kept, in one entry, and refuses one a cent off', async () => {
    const accounts = list(
      record(await readTools.listBankAccounts(accountant, { company_id: one.companyId }))['bank_accounts'],
    );
    const bankAccountId = String(accounts[0]?.['id']);
    const fee = await rows<{ code: string }>(
      db,
      `select code from accounts where company_id = $1 and account_type = 'expense' and not reconcilable order by code limit 1`,
      [one.companyId],
    );
    const feeCode = String(fee[0]?.code);

    const draft = record(
      await writeTools.createDocument(accountant, {
        company_id: one.companyId,
        doc_type: 'sale_invoice',
        contact_id: customerId,
        document_date: '2026-06-22',
        lines: [{ name: 'Abonnement', unit_price: '100.00', account_code: '704000' }],
      }),
    );
    const documentId = String(record(draft['document'])['id']);
    await writeTools.postDocument(accountant, { document_id: documentId });

    const payout = String(
      record(
        record(
          await writeTools.createBankTransaction(accountant, {
            company_id: one.companyId,
            bank_account_id: bankAccountId,
            transaction_date: '2026-06-25',
            amount: '97.00',
            contact_id: customerId,
          }),
        )['transaction'],
      )['id'],
    );

    await expect(
      writeTools.settleFromStatement(accountant, {
        transaction_id: payout,
        document_id: documentId,
        extra_lines: [{ account: feeCode, amount: '2.99' }],
      }),
    ).rejects.toThrow(/settlement_unbalanced/);

    const settled = record(
      await writeTools.settleFromStatement(accountant, {
        transaction_id: payout,
        document_id: documentId,
        amounts: ['100.00'],
        extra_lines: [{ account: feeCode, amount: '3.00', description: 'Provider fee' }],
      }),
    );
    const transaction = record(settled['transaction']);
    expect(transaction['state']).toBe('reconciled');
    expect(await ledgerOfEntry(db, String(transaction['entry_id']))).toEqual([
      { code: '550000', debit: '97.00', credit: '0.00' },
      { code: '400000', debit: '0.00', credit: '100.00' },
      { code: feeCode, debit: '3.00', credit: '0.00' },
    ]);
    const document = record(
      record(await readTools.getDocument(accountant, { document_id: documentId }))['document'],
    );
    expect(document['payment_state']).toBe('paid');
  });
});

describe('import_bank_statement', () => {
  // The brick's own invented statement: eleven booked lines and one pending,
  // on an account that exists nowhere.
  const content = readFileSync(
    join(repoRoot, 'packages', 'formats', 'camt053', 'test', 'fixtures', 'golden.camt.053.001.08.xml'),
    'utf8',
  );
  const input = { format: 'camt.053' as const, content, file_name: 'statement-2026-03.xml' };

  it('refuses the statement of an account the company does not have, and creates none', async () => {
    const before = await rows(db, 'select id from bank_accounts where company_id = $1', [one.companyId]);
    await expect(
      writeTools.importBankStatement(accountant, { company_id: one.companyId, ...input }),
    ).rejects.toThrow(/unknown_bank_account.*BE96999000000101/);
    const after = await rows(db, 'select id from bank_accounts where company_id = $1', [one.companyId]);
    expect(after).toHaveLength(before.length);
  });

  it('is refused to a viewer, and says it is about bank.write', async () => {
    await writeTools.createBankAccount(accountant, { company_id: one.companyId, iban: 'BE96999000000101' });
    await expect(
      writeTools.importBankStatement(viewer, { company_id: one.companyId, ...input }),
    ).rejects.toThrow(/not_allowed.*bank\.write/);
  });

  it('is refused to the owner of another company', async () => {
    await expect(
      writeTools.importBankStatement(otherOwner, { company_id: one.companyId, ...input }),
    ).rejects.toThrow(/unknown_company|not_allowed/);
  });

  it('imports the file, books nothing, and says what it read', async () => {
    const entries = await rows(db, 'select id from entries where company_id = $1', [one.companyId]);
    const result = record(await writeTools.importBankStatement(accountant, { company_id: one.companyId, ...input }));
    expect(result['version']).toBe('08');
    expect(String(result['checksum'])).toMatch(/^sha256:[0-9a-f]{64}$/);
    expect(result['violations']).toEqual([]);
    expect(list(result['statements'])[0]).toMatchObject({
      statement_ref: 'STMT-2026-003',
      already_imported: false,
      lines_read: 11,
      lines_imported: 11,
      lines_not_booked: 1,
      warnings: [],
    });
    expect(await rows(db, 'select id from entries where company_id = $1', [one.companyId])).toHaveLength(entries.length);
    const stored = await rows<{ source_file_name: string; source_checksum: string }>(
      db,
      'select source_file_name, source_checksum from bank_statements where company_id = $1',
      [one.companyId],
    );
    expect(stored).toEqual([{ source_file_name: 'statement-2026-03.xml', source_checksum: result['checksum'] }]);
  });

  it('a second time, creates nothing', async () => {
    const result = record(await writeTools.importBankStatement(accountant, { company_id: one.companyId, ...input }));
    expect(list(result['statements'])[0]).toMatchObject({ already_imported: true, lines_imported: 0, lines_known: 11 });
  });

  it('refuses a file written to hurt the reader before the database hears of it', async () => {
    const hostile = content.replace('<Document', '<!DOCTYPE d [<!ENTITY x SYSTEM "file:///etc/passwd">]><Document');
    await expect(
      writeTools.importBankStatement(accountant, { company_id: one.companyId, format: 'camt.053', content: hostile }),
    ).rejects.toMatchObject({ code: 'doctype_forbidden' });
  });

  it('reads the two formats of fixed positions by the same road, and never guesses which one a file is', async () => {
    const fixture = (brick: string, name: string): string =>
      readFileSync(join(repoRoot, 'packages', 'formats', brick, 'test', 'fixtures', name), 'utf8');
    // The brick's own invented CODA, which happens to be of the account above.
    const coda = record(
      await writeTools.importBankStatement(accountant, {
        company_id: one.companyId,
        format: 'coda',
        content: fixture('coda', 'golden.cod'),
      }),
    );
    expect(coda).toMatchObject({ format: 'coda', version: '2', version_verified: null, violations: [] });
    expect(list(coda['statements'])[0]).toMatchObject({ statement_ref: '2026-042', lines_imported: 11 });

    // A CFONB 120 names no country: without one its account is the three
    // codes joined, which this company does not hold.
    await expect(
      writeTools.importBankStatement(accountant, {
        company_id: one.companyId,
        format: 'cfonb120',
        content: fixture('cfonb120', 'golden.cfonb120.txt'),
      }),
    ).rejects.toThrow(/unknown_bank_account.*99999000010000000101A/);

    // And a file given under the wrong name is refused by the reader, by name.
    await expect(
      writeTools.importBankStatement(accountant, {
        company_id: one.companyId,
        format: 'cfonb120',
        content: fixture('coda', 'golden.cod'),
      }),
    ).rejects.toMatchObject({ code: 'invalid_record_length' });
  });

  it('passes on a statement that does not add up as the refusal of the database, not its own', async () => {
    await expect(
      writeTools.importBankStatement(accountant, {
        company_id: one.companyId,
        format: 'camt.053',
        content: content.replace('1562.36', '1562.35').replace('STMT-2026-003', 'STMT-OTHER'),
      }),
    ).rejects.toThrow(/unbalanced_statement/);
  });
});

describe('import_bank_statement of a CSV', () => {
  // A statement exported as CSV by a payment service: a gross amount, its fee
  // and the running balance, on the account the statements above were of.
  const content = [
    'Date,Name,Type,Gross,Fee,Balance,Transaction ID',
    '04/05/2026,Ada Client,Payment received,"1,200.00",-35.10,"1,214.90",TX-0001',
    '06/05/2026,,Withdrawal,-50.00,0.00,"1,164.90",TX-0002',
  ].join('\n');
  const csvProfile = {
    delimiter: ',',
    dateFormat: 'DD/MM/YYYY',
    decimalSeparator: '.' as const,
    thousandsSeparator: ',',
    columns: { date: 'Date', counterparty: 'Name', description: 'Type', amount: 'Gross', fee: 'Fee', balance: 'Balance', reference: 'Transaction ID' },
  };
  let accountId: string;

  beforeAll(async () => {
    const [account] = await rows<{ id: string }>(
      db,
      "select id from bank_accounts where company_id = $1 and replace(iban, ' ', '') = 'BE96999000000101'",
      [one.companyId],
    );
    accountId = account!.id;
  });

  it('is refused without the profile of its columns, and without the account it is of', async () => {
    await expect(
      writeTools.importBankStatement(accountant, { company_id: one.companyId, format: 'csv', content, bank_account_id: accountId }),
    ).rejects.toMatchObject({ code: 'csv_profile_required' });
    await expect(
      writeTools.importBankStatement(accountant, { company_id: one.companyId, format: 'csv', content, csv_profile: csvProfile }),
    ).rejects.toMatchObject({ code: 'csv_bank_account_required' });
  });

  it('is refused by the database when nothing proves its lines are all there', async () => {
    const withoutBalance = { ...csvProfile, columns: { ...csvProfile.columns, balance: undefined } };
    await expect(
      writeTools.importBankStatement(accountant, {
        company_id: one.companyId,
        format: 'csv',
        content,
        csv_profile: withoutBalance,
        bank_account_id: accountId,
      }),
    ).rejects.toThrow(/statement_without_balances/);
    // An import that failed keeps nothing on the account.
    const [kept] = await rows<{ statement_profile: unknown }>(db, 'select statement_profile from bank_accounts where id = $1', [accountId]);
    expect(kept?.statement_profile).toBeNull();
  });

  it('imports a row with a fee as two lines, proved by the running balance, and a second time creates nothing', async () => {
    const args = { company_id: one.companyId, format: 'csv' as const, content, csv_profile: csvProfile, bank_account_id: accountId, file_name: 'activity.csv' };
    const result = record(await writeTools.importBankStatement(accountant, args));
    expect(result).toMatchObject({ format: 'csv', version: null, violations: [] });
    expect(list(result['statements'])[0]).toMatchObject({ statement_ref: '2026-05-04/2026-05-06', already_imported: false, lines_imported: 3 });
    const lines = await rows<{ amount: string; reference: string; counterpart_name: string | null }>(
      db,
      `select t.amount::text as amount, t.reference, t.counterpart_name
         from bank_transactions t join bank_statements s on s.id = t.statement_id
        where s.statement_ref = '2026-05-04/2026-05-06' order by t.sequence`,
    );
    expect(lines).toEqual([
      { amount: '1200.00', reference: 'TX-0001', counterpart_name: 'Ada Client' },
      { amount: '-35.10', reference: 'TX-0001', counterpart_name: 'Ada Client' },
      { amount: '-50.00', reference: 'TX-0002', counterpart_name: null },
    ]);
    const [statement] = await rows<{ balance_start: string; balance_end_declared: string; source_format: string }>(
      db,
      "select balance_start::text, balance_end_declared::text, source_format from bank_statements where statement_ref = '2026-05-04/2026-05-06'",
    );
    expect(statement).toEqual({ balance_start: '50.00', balance_end_declared: '1164.90', source_format: 'csv' });

    const again = record(await writeTools.importBankStatement(accountant, args));
    expect(list(again['statements'])[0]).toMatchObject({ already_imported: true, lines_imported: 0, lines_known: 3 });
  });

  it('keeps the profile it was given on the account, for every member', async () => {
    const [kept] = await rows<{ statement_profile: unknown }>(db, 'select statement_profile from bank_accounts where id = $1', [accountId]);
    expect(kept?.statement_profile).toEqual(csvProfile);
    const listed = list(record(await readTools.listBankAccounts(viewer, { company_id: one.companyId }))['bank_accounts']);
    expect(listed.find((account) => account['id'] === accountId)?.['statement_profile']).toEqual(csvProfile);
  });

  it('reads the next file of the account with the profile it keeps', async () => {
    const next = [
      'Date,Name,Type,Gross,Fee,Balance,Transaction ID',
      '08/05/2026,Bea Client,Payment received,100.00,0.00,"1,264.90",TX-0003',
    ].join('\n');
    const result = record(
      await writeTools.importBankStatement(accountant, { company_id: one.companyId, format: 'csv', content: next, bank_account_id: accountId }),
    );
    expect(result['csv_profile']).toEqual({ source: 'account', kept_on_account: true });
    expect(list(result['statements'])[0]).toMatchObject({ statement_ref: '2026-05-08/2026-05-08', lines_imported: 1 });
    // The profile given again, unchanged, is not written again.
    const same = record(
      await writeTools.importBankStatement(accountant, { company_id: one.companyId, format: 'csv', content: next, bank_account_id: accountId, csv_profile: csvProfile }),
    );
    expect(same['csv_profile']).toEqual({ source: 'given', kept_on_account: true });
  });
});

describe('update_bank_account', () => {
  const profile = {
    delimiter: ';',
    dateFormat: 'DD.MM.YYYY',
    decimalSeparator: ',' as const,
    columns: { date: 'Booking date', debit: 'Debit', credit: 'Credit', balance: 'Balance' },
  };
  let accountId: string;

  beforeAll(async () => {
    const [account] = await rows<{ id: string }>(
      db,
      "select id from bank_accounts where company_id = $1 and replace(iban, ' ', '') = 'BE96999000000101'",
      [one.companyId],
    );
    accountId = account!.id;
  });

  it('keeps a profile on the account, and list_bank_accounts returns it', async () => {
    const result = record(
      await writeTools.updateBankAccount(accountant, { company_id: one.companyId, bank_account_id: accountId, statement_profile: profile }),
    );
    expect(record(result['bank_account'])['statement_profile']).toEqual(profile);
    const listed = list(record(await readTools.listBankAccounts(accountant, { company_id: one.companyId }))['bank_accounts']);
    expect(listed.find((account) => account['id'] === accountId)?.['statement_profile']).toEqual(profile);
  });

  it('refuses a profile no file could be read with, and changes nothing', async () => {
    await expect(
      writeTools.updateBankAccount(accountant, {
        company_id: one.companyId,
        bank_account_id: accountId,
        statement_profile: { ...profile, dateFormat: 'DD.MM' },
      }),
    ).rejects.toMatchObject({ code: 'invalid_profile' });
    const [kept] = await rows<{ statement_profile: unknown }>(db, 'select statement_profile from bank_accounts where id = $1', [accountId]);
    expect(kept?.statement_profile).toEqual(profile);
  });

  it('is refused to a viewer, and to another company', async () => {
    await expect(
      writeTools.updateBankAccount(viewer, { company_id: one.companyId, bank_account_id: accountId, statement_profile: null }),
    ).rejects.toThrow(/not_allowed/);
    await expect(
      writeTools.updateBankAccount(otherOwner, { company_id: two.companyId, bank_account_id: accountId, statement_profile: null }),
    ).rejects.toMatchObject({ code: 'unknown_bank_account' });
  });

  it('forgets it with null, after which a CSV without a profile is refused', async () => {
    await writeTools.updateBankAccount(accountant, { company_id: one.companyId, bank_account_id: accountId, statement_profile: null });
    const [kept] = await rows<{ statement_profile: unknown }>(db, 'select statement_profile from bank_accounts where id = $1', [accountId]);
    expect(kept?.statement_profile).toBeNull();
    await expect(
      writeTools.importBankStatement(accountant, {
        company_id: one.companyId,
        format: 'csv',
        content: 'Booking date;Debit;Credit;Balance\n01.06.2026;;10,00;10,00',
        bank_account_id: accountId,
      }),
    ).rejects.toMatchObject({ code: 'csv_profile_required' });
  });
});
