/**
 * Every account of the books is a scheme and a value.
 *
 * `20261123203300_an_account_is_a_scheme_and_a_value.sql` gives the five
 * columns that named an IBAN or a BIC alone — `bank_accounts.bic`,
 * `contacts.iban` and `.bic`, `bank_transactions.counterpart_iban`,
 * `documents.payee_iban` (BT-84) — a scheme and a value from the closed list
 * `bank_identifier_schemes`, and keeps the old names in step with them.
 *
 * This file follows one account end to end in each of three packs whose
 * banks do not use an IBAN — a routing number and an account, a BSB and an
 * account, an IFSC and an account: the company's own account, a customer's,
 * the payee of a sales document, the counterpart of a statement line and the
 * customer recognised by it. Then the mirror both ways, the refusal of a
 * write that says two things, the check that follows the scheme, and the list
 * held together with the registry of `@ekwo-ai/core`.
 *
 * The packs are chosen by what they declare, never by name. The identifiers
 * are shapes that pass their check digits, not accounts.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { BANK_ACCOUNT_SCHEME_KEYS } from '@ekwo-ai/core';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { packWhere } from './helpers/packs.js';

/** One account per scheme, its bank in the matching institution scheme. */
const CASES = [
  { scheme: 'aba-routing-account', typed: '021000021 123456789', canonical: '021000021 123456789', bankScheme: 'aba', bank: '021000021' },
  { scheme: 'bsb-account', typed: '062-000 12345678', canonical: '062000 12345678', bankScheme: 'bsb', bank: '062000' },
  { scheme: 'ifsc-account', typed: 'sbin0001234 123456789012', canonical: 'SBIN0001234 123456789012', bankScheme: 'ifsc', bank: 'SBIN0001234' },
] as const;

/** A customer's account in the same scheme, another number. */
const CUSTOMER: Record<string, string> = {
  'aba-routing-account': '021000021 987654321',
  'bsb-account': '062000 87654321',
  'ifsc-account': 'SBIN0001234 987654321098',
};

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
});

afterAll(async () => {
  await db.close();
});

describe.each(CASES)('an account in the scheme $scheme, end to end', (c) => {
  const pack = packWhere(`whose banks use ${c.scheme}`, (p) => p.documents.bank_account_scheme === c.scheme);
  const country = pack.manifest.country;

  it('is the company account, a customer account, the payee of a sale and the counterpart that names the customer', async () => {
    const company = await newCompany(db, { country, name: `Example ${c.scheme}` });

    // The company's own account, read in the scheme of its pack.
    const created = await one<{ answer: { bank_account: { id: string; account_scheme: string; account_identifier: string; iban: string | null } } }>(
      db,
      `select create_bank_account($1, $2, p_bank_name => 'Example Bank') as answer`,
      [company.companyId, c.typed],
    );
    const account = created.answer.bank_account;
    expect(account).toMatchObject({ account_scheme: c.scheme, account_identifier: c.canonical, iban: null });
    await db.query(
      `update bank_accounts set bank_scheme = $2, bank_identifier = $3 where id = $1`,
      [account.id, c.bankScheme, c.bank],
    );
    await db.query(`update companies set default_bank_account_id = $2 where id = $1`, [company.companyId, account.id]);
    expect(
      await one(db, `select bic, bank_scheme, bank_identifier from bank_accounts where id = $1`, [account.id]),
    ).toEqual({ bic: null, bank_scheme: c.bankScheme, bank_identifier: c.bank });

    // A customer paid from an account of the same scheme.
    const contact = await one<{ id: string; iban: string | null; bic: string | null }>(
      db,
      `insert into contacts (company_id, name, contact_type, country, account_scheme, account_identifier, bank_scheme, bank_identifier)
       values ($1, 'Example Customer', 'customer', $2, $3, $4, $5, $6)
       returning id, iban, bic`,
      [company.companyId, country, c.scheme, CUSTOMER[c.scheme], c.bankScheme, c.bank],
    );
    expect(contact).toMatchObject({ iban: null, bic: null });

    // A sales document asks to be paid into the company's account, scheme and all (BT-84).
    const doc = await one<{ id: string; payee_iban: string | null; payee_account_scheme: string; payee_account_identifier: string }>(
      db,
      `insert into documents (company_id, doc_type, contact_id, document_date)
       values ($1, 'sale_invoice', $2, '2026-03-01')
       returning id, payee_iban, payee_account_scheme, payee_account_identifier`,
      [company.companyId, contact.id],
    );
    expect(doc).toMatchObject({ payee_iban: null, payee_account_scheme: c.scheme, payee_account_identifier: c.canonical });
    expect(
      await one(
        db,
        `select payee_iban, payee_account_scheme, payee_account_identifier, payee_bank_scheme, payee_bank_identifier
           from document_header where document_id = $1`,
        [doc.id],
      ),
    ).toEqual({
      payee_iban: null,
      payee_account_scheme: c.scheme,
      payee_account_identifier: c.canonical,
      payee_bank_scheme: c.bankScheme,
      payee_bank_identifier: c.bank,
    });

    // The statement line the customer's money arrives on names their account,
    // and the account is what recognises them.
    const line = await one<{ id: string; counterpart_iban: string | null }>(
      db,
      `insert into bank_transactions
         (company_id, bank_account_id, sequence, transaction_date, amount, currency_code,
          description, counterpart_account_scheme, counterpart_account_identifier, state)
       select $1, $2, 1, '2026-03-02', 100, c.currency_code, 'transfer', $3, $4, 'pending'
         from companies c where c.id = $1
       returning id, counterpart_iban`,
      [company.companyId, account.id, c.scheme, CUSTOMER[c.scheme]],
    );
    expect(line.counterpart_iban).toBeNull();
    const suggested = await rows<{ contact_id: string; method: string }>(db, `select * from suggest_contacts($1)`, [line.id]);
    expect(suggested[0]).toMatchObject({ contact_id: contact.id, method: 'account' });
  });
});

describe('the old names and the new pair say one thing', () => {
  let companyId: string;

  beforeAll(async () => {
    const pack = packWhere('whose banks use an IBAN', (p) => p.documents.bank_account_scheme === 'iban');
    companyId = (await newCompany(db, { country: pack.manifest.country, name: 'Example Mirror' })).companyId;
  });

  it('a write to the old column writes the pair, and clearing it clears the pair', async () => {
    const contact = await one<{ id: string; account_scheme: string; account_identifier: string; bank_scheme: string; bank_identifier: string }>(
      db,
      `insert into contacts (company_id, name, contact_type, iban, bic)
       values ($1, 'Example Old Writer', 'customer', 'XX00 OLD WRITER', 'EXAMPLEXXXX')
       returning id, account_scheme, account_identifier, bank_scheme, bank_identifier`,
      [companyId],
    );
    expect(contact).toMatchObject({
      account_scheme: 'iban',
      account_identifier: 'XX00 OLD WRITER',
      bank_scheme: 'bic',
      bank_identifier: 'EXAMPLEXXXX',
    });
    await db.query(`update contacts set iban = null, bic = null where id = $1`, [contact.id]);
    expect(
      await one(db, `select account_scheme, account_identifier, bank_scheme, bank_identifier from contacts where id = $1`, [contact.id]),
    ).toEqual({ account_scheme: null, account_identifier: null, bank_scheme: null, bank_identifier: null });
  });

  it('a write to the pair writes the old column in its scheme and clears it in any other', async () => {
    const contact = await one<{ id: string }>(
      db,
      `insert into contacts (company_id, name, contact_type, account_scheme, account_identifier)
       values ($1, 'Example New Writer', 'customer', 'iban', 'XX00NEWWRITER') returning id`,
      [companyId],
    );
    expect(await one(db, `select iban from contacts where id = $1`, [contact.id])).toEqual({ iban: 'XX00NEWWRITER' });
    await db.query(
      `update contacts set account_scheme = 'bsb-account', account_identifier = '062000 12345678' where id = $1`,
      [contact.id],
    );
    expect(await one(db, `select iban from contacts where id = $1`, [contact.id])).toEqual({ iban: null });
  });

  it('refuses a write to both that says two things', async () => {
    const error = await expectError(
      db,
      `insert into contacts (company_id, name, contact_type, iban, account_scheme, account_identifier)
       values ($1, 'Example Two Things', 'customer', 'XX00ONE', 'iban', 'XX00OTHER')`,
      [companyId],
    );
    expect(error).toContain('bank_identifier_disagrees');
  });

  it('refuses a scheme outside the list, by its reference', async () => {
    const error = await expectError(
      db,
      `insert into contacts (company_id, name, contact_type, account_scheme, account_identifier)
       values ($1, 'Example Unlisted', 'customer', 'no-such-scheme', '123')`,
      [companyId],
    );
    expect(error).toMatch(/foreign key|violates/);
  });

  it('keeps counterpart_iban and the counterpart pair in step on a statement line', async () => {
    const account = await one<{ id: string }>(
      db,
      `insert into bank_accounts (company_id, name, currency_code)
       select $1, 'Example Account', currency_code from companies where id = $1 returning id`,
      [companyId],
    );
    const line = await one<{ id: string; counterpart_account_scheme: string; counterpart_account_identifier: string }>(
      db,
      `insert into bank_transactions (company_id, bank_account_id, sequence, transaction_date, amount, currency_code, counterpart_iban, state)
       select $1, $2, 1, '2026-03-02', 10, currency_code, 'XX00LINE', 'pending' from companies where id = $1
       returning id, counterpart_account_scheme, counterpart_account_identifier`,
      [companyId, account.id],
    );
    expect(line).toMatchObject({ counterpart_account_scheme: 'iban', counterpart_account_identifier: 'XX00LINE' });
  });
});

describe('two contacts paid from one account in a scheme other than IBAN', () => {
  it('are proposed as one party', async () => {
    const pack = packWhere('whose banks use a BSB', (p) => p.documents.bank_account_scheme === 'bsb-account');
    const { companyId } = await newCompany(db, { country: pack.manifest.country, name: 'Example Duplicates' });
    const ids: string[] = [];
    for (const name of ['Example Trading', 'Example Holdings']) {
      ids.push(
        (
          await one<{ id: string }>(
            db,
            `insert into contacts (company_id, name, contact_type, account_scheme, account_identifier)
             values ($1, $2, 'customer', 'bsb-account', '062000 12345678') returning id`,
            [companyId, name],
          )
        ).id,
      );
    }
    const pairs = await rows<{ keep_id: string; absorb_id: string; evidence: string }>(
      db,
      `select keep_id, absorb_id, evidence from suggest_duplicate_contacts($1)`,
      [companyId],
    );
    expect(pairs.some((p) => p.evidence.includes('account') && ids.includes(p.keep_id) && ids.includes(p.absorb_id))).toBe(true);
  });
});

describe('the check follows the scheme', () => {
  it('answers why a value breaks its scheme, and stores a scheme without a check as written', async () => {
    const problem = async (scheme: string, value: string): Promise<string | null> =>
      (await one<{ p: string | null }>(db, `select bank_identifier_problem($1, $2) as p`, [scheme, value])).p;
    expect(await problem('aba-routing-account', '021000021 123456789')).toBeNull();
    expect(await problem('aba-routing-account', '021000022 123456789')).toContain('ABA routing number check digit');
    expect(await problem('aba', '021000021')).toBeNull();
    expect(await problem('aba', '021000022')).toContain('check digit');
    expect(await problem('bsb-account', '062000 12345678')).toBeNull();
    expect(await problem('iban', 'XX00NOTANIBAN')).toContain('invalid_bank_account');
    expect(await problem('bic', 'EXAMPLEXXXX')).toBeNull();
    expect(await problem('sort-code', 'anything as written')).toBeNull();
  });

  it('lists every account scheme of the core registry, and the registry lists every account scheme of the table', async () => {
    const listed = await rows<{ code: string }>(
      db,
      `select code from bank_identifier_schemes where identifies = 'account' order by code`,
    );
    expect(listed.map((r) => r.code)).toEqual([...BANK_ACCOUNT_SCHEME_KEYS].sort());
  });
});
