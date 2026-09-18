import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { expectError, freshDatabase, one, rows } from './helpers/db.js';
import { newCompany, newContact, type Fixture } from './helpers/factory.js';

let db: PGlite;
let fx: Fixture;
let bankAccountId: string;

interface Suggestion {
  contact_id: string;
  score: string;
  method: string;
  because: string;
  alternatives: number;
}

/** A statement line, with whatever the bank wrote on it. */
async function statementLine(options: {
  amount: number;
  name?: string | null;
  iban?: string | null;
  description?: string | null;
  date?: string;
}): Promise<string> {
  const row = await one<{ id: string }>(
    db,
    `insert into bank_transactions
       (company_id, bank_account_id, sequence, transaction_date, amount, currency_code,
        description, counterpart_name, counterpart_iban, state)
     select $1, $2, coalesce(max(sequence), 0) + 1, $3::date, $4, c.currency_code,
            $5, $6, $7, 'pending'
       from bank_transactions t, companies c
      where c.id = $1
      group by c.currency_code
     returning id`,
    [
      fx.companyId,
      bankAccountId,
      options.date ?? '2026-03-02',
      options.amount,
      options.description ?? null,
      options.name ?? null,
      options.iban ?? null,
    ],
  );
  return row.id;
}

async function suggestions(transactionId: string): Promise<Suggestion[]> {
  return rows<Suggestion>(db, `select * from suggest_contacts($1)`, [transactionId]);
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db);
  const account = await one<{ id: string }>(
    db,
    `insert into bank_accounts (company_id, name, currency_code)
     select $1, 'Compte courant', currency_code from companies where id = $1
     returning id`,
    [fx.companyId],
  );
  bankAccountId = account.id;
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe('the numbers the matching runs on', () => {
  it('are answered for a company that has never had an opinion', async () => {
    const policy = await one<{
      name_threshold: string;
      amount_tolerance_units: number;
      sum_tolerance_units: number;
      date_window_days: number;
      minimum_word_length: number;
    }>(db, `select * from matching_policy_of($1)`, [fx.companyId]);
    expect(Number(policy.name_threshold)).toBeGreaterThan(0);
    expect(policy.amount_tolerance_units).toBe(1);
    expect(policy.sum_tolerance_units).toBe(2);
    expect(policy.date_window_days).toBeGreaterThan(0);
    expect(policy.minimum_word_length).toBeGreaterThan(1);
  });

  it('are the company own once it has one, and only the columns it filled', async () => {
    const other = await newCompany(db, { name: 'Strict Company' });
    await db.query(
      `insert into matching_settings (company_id, name_threshold) values ($1, 0.900)`,
      [other.companyId],
    );
    const policy = await one<{ name_threshold: string; minimum_word_length: number }>(
      db,
      `select * from matching_policy_of($1)`,
      [other.companyId],
    );
    expect(Number(policy.name_threshold)).toBe(0.9);
    // Untouched, so still the shipped answer rather than a null.
    expect(policy.minimum_word_length).toBeGreaterThan(1);
  });
});

describe('what a name is worth', () => {
  it('proposes the contact whose name the statement carries', async () => {
    const contact = await newContact(db, fx.companyId, { name: 'Papeterie Lambert' });
    const tx = await statementLine({ amount: -242, name: 'PAPETERIE LAMBERT' });
    const found = await suggestions(tx);
    const byName = found.filter((s) => s.method === 'name');
    expect(byName).toHaveLength(1);
    expect(byName[0]!.contact_id).toBe(contact);
    expect(Number(byName[0]!.score)).toBeGreaterThanOrEqual(0.9);
    expect(byName[0]!.alternatives).toBe(1);
  });

  it('says nothing when the line carries no word long enough to be evidence', async () => {
    await newContact(db, fx.companyId, { name: 'Ateliers du Nord' });
    const tx = await statementLine({ amount: -50, name: 'VIR SEPA' });
    const found = await suggestions(tx);
    expect(found.filter((s) => s.method === 'name')).toHaveLength(0);
  });

  /**
   * 16 April 2026, in the production this design comes from: matching on the
   * first five characters of a name made `SARL` equal to `SASU` and `SPRL`,
   * and unrelated suppliers were matched to each other. The fix here is not a list of legal forms to
   * ignore — that would be country data in the core — but the count of what
   * the evidence reaches: a word carried by two contacts identifies neither.
   */
  it('does not let a word two contacts share identify either of them', async () => {
    const company = await newCompany(db, { name: 'Two Suppliers' });
    const account = await one<{ id: string }>(
      db,
      `insert into bank_accounts (company_id, name, currency_code)
       select $1, 'Compte', currency_code from companies where id = $1 returning id`,
      [company.companyId],
    );
    await newContact(db, company.companyId, { name: 'Dupont SARL' });
    await newContact(db, company.companyId, { name: 'Martin SARL' });
    const tx = await one<{ id: string }>(
      db,
      `insert into bank_transactions
         (company_id, bank_account_id, sequence, transaction_date, amount, currency_code,
          counterpart_name, state)
       select $1, $2, 1, '2026-03-02'::date, -100, currency_code, 'VIREMENT SARL', 'pending'
         from companies where id = $1
       returning id`,
      [company.companyId, account.id],
    );
    const found = await rows<Suggestion>(db, `select * from suggest_contacts($1)`, [tx.id]);
    const byName = found.filter((s) => s.method === 'name');
    // Both are reached, and the count says so — which is what a caller applying
    // a match on its own is required to look at.
    expect(byName.length).toBeGreaterThan(1);
    expect(byName.every((s) => s.alternatives > 1)).toBe(true);
  });
});

describe('an account is not a resemblance', () => {
  it('is worth 1 when the statement carries the account recorded against a contact', async () => {
    const contact = await newContact(db, fx.companyId, { name: 'Fournisseur Sud' });
    await db.query(`update contacts set iban = 'BE68539007547034' where id = $1`, [contact]);
    const tx = await statementLine({ amount: -900, name: 'F. SUD', iban: 'BE68 5390 0754 7034' });
    const found = await suggestions(tx);
    const byAccount = found.filter((s) => s.method === 'account');
    expect(byAccount).toHaveLength(1);
    expect(byAccount[0]!.contact_id).toBe(contact);
    expect(Number(byAccount[0]!.score)).toBe(1);
  });
});

describe('a confirmation teaches', () => {
  it('turns the account and the name the bank wrote into motifs', async () => {
    const contact = await newContact(db, fx.companyId, { name: 'Imprimerie Centrale' });
    const tx = await statementLine({
      amount: -480,
      name: 'IMPR CENTRALE BVBA',
      iban: 'BE62510007547061',
    });
    await db.query(`select confirm_contact($1, $2)`, [tx, contact]);

    const attributed = await one<{ contact_id: string }>(
      db,
      `select contact_id from bank_transactions where id = $1`,
      [tx],
    );
    expect(attributed.contact_id).toBe(contact);

    const learned = await rows<{ kind: string; value: string; source: string; confidence: string }>(
      db,
      `select kind, value, source, confidence from contact_patterns
        where contact_id = $1 order by kind`,
      [contact],
    );
    expect(learned.map((p) => p.kind).sort()).toEqual(['counterparty_account', 'name_variation']);
    expect(learned.every((p) => p.source === 'learned')).toBe(true);
    // One confirmation is one confirmation: worth more than nothing and less
    // than certainty.
    expect(learned.every((p) => Number(p.confidence) > 0.5 && Number(p.confidence) < 1)).toBe(true);
  });

  it('recognises the next line by the motif, and the motif is worth more each time', async () => {
    const contact = await newContact(db, fx.companyId, { name: 'Garage Molitor' });
    const line = () => statementLine({ amount: -310, name: 'GARAGE MOLITOR SPRL' });

    const first = await line();
    await db.query(`select confirm_contact($1, $2)`, [first, contact]);
    const after1 = await one<{ confidence: string }>(
      db,
      `select confidence from contact_patterns where contact_id = $1 and kind = 'name_variation'`,
      [contact],
    );

    const second = await line();
    const proposed = await suggestions(second);
    expect(proposed.some((s) => s.method === 'pattern:name_variation' && s.contact_id === contact))
      .toBe(true);

    await db.query(`select confirm_contact($1, $2)`, [second, contact]);
    const after2 = await one<{ confidence: string; usage_count: number; success_count: number }>(
      db,
      `select confidence, usage_count, success_count from contact_patterns
        where contact_id = $1 and kind = 'name_variation'`,
      [contact],
    );
    expect(Number(after2.confidence)).toBeGreaterThan(Number(after1.confidence));
    expect(after2.success_count).toBe(after2.usage_count);
  });

  it('charges a motif that named somebody else, so being wrong costs confidence', async () => {
    const wrong = await newContact(db, fx.companyId, { name: 'Alpha Consulting' });
    const right = await newContact(db, fx.companyId, { name: 'Beta Consulting' });
    await db.query(
      `insert into contact_patterns (company_id, contact_id, kind, value, source,
                                     usage_count, success_count, confidence)
       values ($1, $2, 'description_keyword', 'consulting', 'declared', 4, 4, 0.833)`,
      [fx.companyId, wrong],
    );
    const tx = await statementLine({
      amount: -1500,
      name: 'PAIEMENT',
      description: 'Honoraires consulting mars',
    });
    await db.query(`select confirm_contact($1, $2)`, [tx, right]);

    const charged = await one<{ usage_count: number; success_count: number; confidence: string }>(
      db,
      `select usage_count, success_count, confidence from contact_patterns
        where contact_id = $1 and kind = 'description_keyword'`,
      [wrong],
    );
    expect(charged.usage_count).toBe(5);
    expect(charged.success_count).toBe(4);
    expect(Number(charged.confidence)).toBeLessThan(0.833);
  });

  it('refuses a contact of another company, by name', async () => {
    const other = await newCompany(db, { name: 'Elsewhere' });
    const stranger = await newContact(db, other.companyId, { name: 'Ailleurs' });
    const tx = await statementLine({ amount: -10, name: 'AILLEURS' });
    const message = await expectError(db, `select confirm_contact($1, $2)`, [tx, stranger]);
    expect(message).toContain('contact_not_of_company');
  });
});

describe('a motif that is turned off', () => {
  it('is never read, and keeps what it learned', async () => {
    const contact = await newContact(db, fx.companyId, { name: 'Abonnement Presse' });
    await db.query(
      `insert into contact_patterns (company_id, contact_id, kind, value, source,
                                     usage_count, success_count, confidence, active)
       values ($1, $2, 'description_keyword', 'abonnement', 'declared', 3, 3, 0.800, false)`,
      [fx.companyId, contact],
    );
    const tx = await statementLine({
      amount: -29,
      name: 'PRELEVEMENT',
      description: 'Abonnement mensuel',
    });
    const found = await suggestions(tx);
    expect(found.some((s) => s.method === 'pattern:description_keyword')).toBe(false);
    const kept = await one<{ success_count: number }>(
      db,
      `select success_count from contact_patterns where contact_id = $1`,
      [contact],
    );
    expect(kept.success_count).toBe(3);
  });

  it('gives a keyword its exclusions', async () => {
    const broker = await newContact(db, fx.companyId, { name: 'Courtier General' });
    await db.query(
      `insert into contact_patterns (company_id, contact_id, kind, value, exclude_words, source,
                                     usage_count, success_count, confidence)
       values ($1, $2, 'description_keyword', 'assurance', array['auto'], 'declared', 2, 2, 0.750)`,
      [fx.companyId, broker],
    );
    const covered = await statementLine({ amount: -120, description: 'Prime assurance bureau' });
    const excluded = await statementLine({ amount: -95, description: 'Prime assurance auto' });
    expect((await suggestions(covered)).some((s) => s.contact_id === broker)).toBe(true);
    expect((await suggestions(excluded)).some((s) => s.contact_id === broker)).toBe(false);
  });
});

describe('the shape of a motif', () => {
  it('refuses a keyword with an amount band, and a band with a keyword', async () => {
    const contact = await newContact(db, fx.companyId, { name: 'Shape Test' });
    const halfAndHalf = await expectError(
      db,
      `insert into contact_patterns (company_id, contact_id, kind, value, amount_min, amount_max,
                                     currency_code, source, confidence)
       select $1, $2, 'description_keyword', 'loyer', 100, 200, currency_code, 'declared', 0.5
         from companies where id = $1`,
      [fx.companyId, contact],
    );
    expect(halfAndHalf).toContain('contact_patterns_shape');

    const bandWithValue = await expectError(
      db,
      `insert into contact_patterns (company_id, contact_id, kind, value, source, confidence)
       values ($1, $2, 'amount_range', 'loyer', 'declared', 0.5)`,
      [fx.companyId, contact],
    );
    expect(bandWithValue).toContain('contact_patterns_shape');
  });

  it('refuses more successes than uses', async () => {
    const contact = await newContact(db, fx.companyId, { name: 'Counters Test' });
    const message = await expectError(
      db,
      `insert into contact_patterns (company_id, contact_id, kind, value, source,
                                     usage_count, success_count, confidence)
       values ($1, $2, 'name_variation', 'COUNTERS', 'declared', 1, 2, 0.9)`,
      [fx.companyId, contact],
    );
    expect(message).toContain('contact_patterns_success_within_usage');
  });
});

describe('what this never does', () => {
  /**
   * The distinction between `matched` and `validated`, kept:
   * knowing who the money came from is not knowing what it pays. Confusing the
   * two marks an invoice paid that nobody paid.
   */
  it('attributes a line to a contact without reconciling anything', async () => {
    const contact = await newContact(db, fx.companyId, { name: 'Client Fidele' });
    const tx = await statementLine({ amount: 1210, name: 'CLIENT FIDELE' });
    await db.query(`select confirm_contact($1, $2)`, [tx, contact]);
    const after = await one<{ state: string; entry_id: string | null }>(
      db,
      `select state, entry_id from bank_transactions where id = $1`,
      [tx],
    );
    expect(after.state).toBe('pending');
    expect(after.entry_id).toBeNull();
    const matchings = await one<{ count: string }>(
      db,
      `select count(*)::text as count from reconciliations where company_id = $1`,
      [fx.companyId],
    );
    expect(matchings.count).toBe('0');
  });

  it('carries no country, currency or language of its own', async () => {
    const literals = await rows<{ proname: string }>(
      db,
      `select p.proname
         from pg_proc p join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public'
          and p.proname in ('suggest_contacts', 'confirm_contact', 'significant_words',
                            'matching_policy_of')
          and (p.prosrc ~ '''[A-Z]{2}[0-9]{2}[A-Z0-9]{10,}'''
               or p.prosrc ~ '''(EUR|USD|GBP)'''
               or p.prosrc ~ '''(fr|nl|en|de)''\\s*(as|,|\\))')`,
    );
    expect(literals).toEqual([]);
  });
});
