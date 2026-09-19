/**
 * What has not left goes back to draft, where the country allows it.
 *
 * `unpost_document()` puts a posted invoice back to draft when the country's
 * `posted_edit_policy` is `unpost_if_untouched` and nothing about the document
 * has left; `unpost_refusal()` says why not otherwise, and every refusal names
 * what to do instead. What is held here:
 *
 *   * the country's word, read from the pack: a pack that declares
 *     `reversal_only` and one that says nothing both refuse, and name
 *     `cancel_document()`;
 *   * the happy path, read back from the ledger: the entry and its lines are
 *     gone, the draft has given back what posting derived, the counter has
 *     stepped back and the next posting draws the same number again, and the
 *     act is in `document_unpostings` and in the audit trail;
 *   * every refusal, by name, and that a refusal writes nothing;
 *   * the last-number rule, both ways: refused where the country forbids a
 *     hole, allowed and recorded where it does not;
 *   * the exception is narrow: a hand that writes `draft`, deletes a posted
 *     entry or writes the record itself is refused;
 *   * and the fix of `20260919090000`: a cancelled invoice is not unmatched
 *     from its credit note.
 *
 * No pack shipped today declares `unpost_if_untouched` — the packs that speak
 * cite a law that makes a validated entry irreversible, and the others say
 * nothing. So the acceptance path is exercised on a pack chosen for its
 * numbering, whose country is given the other word in this test database: the
 * test states the policy, and never which country holds it.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Pack } from '../packages/cli/src/index.js';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { accountId, newCompany, newContact, newDocument, newUser } from './helpers/factory.js';
import { thirdPartyLine } from './helpers/golden-scenario.js';
import { packWhere, packsWhere, roleOf } from './helpers/packs.js';

type PackTax = Pack['taxes'][number];
const charged = (pack: Pack): PackTax | undefined =>
  pack.taxes
    .filter(
      (tax) =>
        tax.scope === 'sale' && tax.treatment === 'domestic' && tax.amount_type === 'percent' &&
        tax.rate > 0 && tax.valid_to === null && !tax.price_include && !tax.cash_basis,
    )
    .sort((a, b) => b.rate - a.rate)[0];
const bookable = (pack: Pack): boolean =>
  charged(pack) !== undefined &&
  ['receivable', 'sales', 'bank'].every((role) => typeof pack.manifest.defaults.roles[role] === 'string');

let db: PGlite;

/** One company of a pack, with an accountant, a viewer and a customer. */
interface Books {
  pack: Pack;
  tax: PackTax;
  companyId: string;
  ownerId: string;
  accountant: string;
  viewer: string;
  customer: string;
}

async function books(pack: Pack, name: string): Promise<Books> {
  const { companyId, ownerId } = await newCompany(db, { country: pack.manifest.country, name });
  const accountant = await newUser(db, `accountant@${pack.slug}.${name.toLowerCase()}.test`);
  const viewer = await newUser(db, `viewer@${pack.slug}.${name.toLowerCase()}.test`);
  await db.query(
    `insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant'), ($1, $3, 'viewer')`,
    [companyId, accountant, viewer],
  );
  const customer = await newContact(db, companyId, { country: pack.manifest.country });
  return { pack, tax: charged(pack) as PackTax, companyId, ownerId, accountant, viewer, customer };
}

/** A posted sale invoice of two lines, booked by the accountant. */
async function invoice(b: Books, date = '2026-06-15'): Promise<string> {
  const account = roleOf(b.pack, 'sales');
  const id = await newDocument(db, b.companyId, {
    docType: 'sale_invoice',
    contactId: b.customer,
    date,
    lines: [
      { name: 'First', unitPrice: 100, taxCode: b.tax.code, accountCode: account },
      { name: 'Second', quantity: 3, unitPrice: 33.33, taxCode: b.tax.code, accountCode: account },
    ],
  });
  await asUser(db, b.accountant, () => db.query(`select post_document($1)`, [id]));
  return id;
}

const unpost = (b: Books, id: string) =>
  asUser(db, b.accountant, () =>
    one<Record<string, unknown>>(
      db,
      `select id, state, number, entry_id, accounting_date::text, tax_point_date::text, payment_state
         from unpost_document($1)`,
      [id],
    ),
  );

/** The refusal a call made as `who` gets, in its own words; the call is rolled back either way. */
async function refusalOf(sql: string, params: unknown[], who: string): Promise<string> {
  await db.exec('begin');
  try {
    await db.query(`select set_config('ekwo.installing', '', true), set_config('request.jwt.claims', $1, true)`, [
      JSON.stringify({ sub: who, role: 'authenticated' }),
    ]);
    await db.exec('set local role authenticated');
    return await db.query(sql, params).then(
      () => 'accepted',
      (error: Error) => error.message,
    );
  } finally {
    await db.exec('rollback');
  }
}

/** What the accountant is told by `unpost_refusal()` — null where it may go back. */
const verdict = async (b: Books, id: string): Promise<string | null> =>
  (await asUser(db, b.accountant, () => one<{ why: string | null }>(db, `select unpost_refusal($1) as why`, [id]))).why;

const counterOf = async (entryNumber: string, companyId: string) =>
  (await one<{ last_number: number }>(
    db,
    `select s.last_number
       from journal_sequences s
       join entries e on e.journal_id = s.journal_id
      where e.company_id = $1 and e.number = $2
        and s.year in (0, extract(year from e.entry_date)::smallint)`,
    [companyId, entryNumber],
  )).last_number;

/** Lets the country of a pack put a posted document back to draft, in this database only. */
const allowUnposting = (pack: Pack) =>
  db.query(`update country_defaults set posted_edit_policy = 'unpost_if_untouched' where country = $1`, [
    pack.manifest.country,
  ]);

let gapless: Books;
let holed: Books;

beforeAll(async () => {
  db = await freshDatabase();
  // Two packs that say nothing about a posted document, so that giving their
  // country the other word contradicts no article a pack cites.
  const withHoleless = packWhere('numbers without a hole, is silent on a posted document, and books a taxed sale', (p) =>
    p.documents.numbering_gapless === true && p.documents.posted_edit_policy === null && bookable(p),
  );
  const withHoles = packWhere('allows a hole in the numbering, is silent on a posted document, and books a taxed sale', (p) =>
    p.documents.numbering_gapless === false && p.documents.posted_edit_policy === null && bookable(p),
  );
  await allowUnposting(withHoleless);
  await allowUnposting(withHoles);
  gapless = await books(withHoleless, 'Gapless');
  holed = await books(withHoles, 'Holed');
}, 180_000);

afterAll(async () => {
  await db.close();
});

// ---------------------------------------------------------------------------
// The country's word
// ---------------------------------------------------------------------------

describe('the country says whether a posted document goes back to draft', () => {
  it('keeps it posted where the pack declares reversal_only, and names cancel_document()', async () => {
    const strict = packWhere('keeps a posted document as it was posted', (p) =>
      p.documents.posted_edit_policy === 'reversal_only' && bookable(p),
    );
    // The pack says why, with the article.
    expect(strict.documents.posted_edit_policy_reference.legal_reference).toEqual(expect.any(String));
    const b = await books(strict, 'Strict');
    const id = await invoice(b);
    expect(await one(db, `select posted_edit_policy($1) as policy`, [b.companyId])).toEqual({ policy: 'reversal_only' });
    expect(await verdict(b, id)).toMatch(/^posted_edit_reversal_only\b.*declares reversal_only.*cancel_document\(\)/);
    expect(await refusalOf(`select unpost_document($1)`, [id], b.accountant)).toMatch(/^posted_edit_reversal_only\b/);
  });

  it('reads a pack that says nothing as reversal_only, the stricter word', async () => {
    const silent = packWhere('says nothing about a posted document', (p) =>
      p.documents.posted_edit_policy === null && bookable(p) &&
      p.manifest.country !== gapless.pack.manifest.country && p.manifest.country !== holed.pack.manifest.country,
    );
    const b = await books(silent, 'Silent');
    const id = await invoice(b);
    expect(await one(db, `select posted_edit_policy($1) as policy`, [b.companyId])).toEqual({ policy: 'reversal_only' });
    expect(await verdict(b, id)).toMatch(/^posted_edit_reversal_only\b.*says nothing, which reads the same.*cancel_document\(\)/);
  });

  it('holds every pack that allows it to cite the article that does', () => {
    for (const pack of packsWhere('declares a posted_edit_policy', (p) => p.documents.posted_edit_policy !== null)) {
      expect(pack.documents.posted_edit_policy_reference.legal_reference, pack.slug).toEqual(expect.any(String));
      expect(pack.documents.posted_edit_policy_reference.source, pack.slug).toEqual(expect.any(String));
    }
  });
});

// ---------------------------------------------------------------------------
// Back to draft
// ---------------------------------------------------------------------------

describe('unpost_document', () => {
  it('takes the entry away, gives the number back and returns the draft as it was before posting', async () => {
    const id = await invoice(gapless);
    const posted = await one<{ number: string; entry_id: string; journal_id: string; entry_date: string }>(
      db,
      `select d.number, d.entry_id, e.journal_id, e.entry_date::text
         from documents d join entries e on e.id = d.entry_id where d.id = $1`,
      [id],
    );
    const counter = await counterOf(posted.number, gapless.companyId);
    expect(await verdict(gapless, id)).toBeNull();

    const draft = await unpost(gapless, id);
    expect(draft).toEqual({
      id,
      state: 'draft',
      number: null,
      entry_id: null,
      accounting_date: null,
      tax_point_date: null,
      payment_state: 'not_paid',
    });

    // The entry, its lines, nothing left of it.
    expect(await rows(db, `select 1 from entries where id = $1`, [posted.entry_id])).toEqual([]);
    expect(await rows(db, `select 1 from entry_lines where entry_id = $1`, [posted.entry_id])).toEqual([]);
    expect(
      await one<{ last_number: number }>(
        db,
        `select last_number from journal_sequences where journal_id = $1 and last_number = $2`,
        [posted.journal_id, counter - 1],
      ),
    ).toEqual({ last_number: counter - 1 });

    // The record of the act, readable by whoever reads the documents.
    const record = await asUser(db, gapless.viewer, () =>
      rows(
        db,
        `select document_id, doc_type, entry_id, entry_number, journal_id, entry_date::text, number_returned, unposted_by
           from document_unpostings where document_id = $1`,
        [id],
      ),
    );
    expect(record).toEqual([
      {
        document_id: id,
        doc_type: 'sale_invoice',
        entry_id: posted.entry_id,
        entry_number: posted.number,
        journal_id: posted.journal_id,
        entry_date: posted.entry_date,
        number_returned: true,
        unposted_by: gapless.accountant,
      },
    ]);

    // And in the audit trail, by the triggers that record every act.
    const acts = await rows<{ action: string; record_key: string }>(
      db,
      `select action, record_key from audit_log
        where company_id = $1 and action in ('document_draft', 'document_unposted') order by id`,
      [gapless.companyId],
    );
    expect(acts).toEqual(
      expect.arrayContaining([
        { action: 'document_draft', record_key: id },
        { action: 'document_unposted', record_key: posted.number },
      ]),
    );

    // Posted again, it draws the number it gave back: no hole, no second number.
    await asUser(db, gapless.accountant, () => db.query(`select post_document($1)`, [id]));
    expect(await one(db, `select state, number from documents where id = $1`, [id])).toEqual({
      state: 'posted',
      number: posted.number,
    });
  });

  it('keeps a booking day that was keyed, and gives back only what posting derived', async () => {
    const id = await newDocument(db, gapless.companyId, {
      docType: 'sale_invoice',
      contactId: gapless.customer,
      date: '2026-06-10',
      lines: [{ unitPrice: 50, taxCode: gapless.tax.code, accountCode: roleOf(gapless.pack, 'sales') }],
    });
    await db.query(`update documents set accounting_date = '2026-06-12' where id = $1`, [id]);
    await asUser(db, gapless.accountant, () => db.query(`select post_document($1)`, [id]));
    const draft = await unpost(gapless, id);
    expect(draft['accounting_date']).toBe('2026-06-12');
    expect(draft['number']).toBeNull();
  });

  it('refuses what has left, by name, names what to do instead, and writes nothing', async () => {
    const b = gapless;
    const count = async () =>
      (await one<{ n: number }>(db, `select count(*)::int as n from entries where company_id = $1`, [b.companyId])).n;

    // A draft.
    const draft = await newDocument(db, b.companyId, {
      docType: 'sale_invoice',
      contactId: b.customer,
      lines: [{ unitPrice: 10, taxCode: b.tax.code, accountCode: roleOf(b.pack, 'sales') }],
    });
    expect(await refusalOf(`select unpost_document($1)`, [draft], b.accountant)).toMatch(/^document_not_posted\b/);

    // Sent to the customer, and gone on Peppol.
    const sent = await invoice(b);
    await asUser(db, b.accountant, () => db.query(`update documents set sent_at = now() where id = $1`, [sent]));
    expect(await refusalOf(`select unpost_document($1)`, [sent], b.accountant)).toMatch(/^document_sent\b.*cancel_document\(\)/);
    const peppol = await invoice(b);
    await asUser(db, b.accountant, () => db.query(`update documents set peppol_status = 'delivered' where id = $1`, [peppol]));
    expect(await refusalOf(`select unpost_document($1)`, [peppol], b.accountant)).toMatch(/^document_sent\b.*Peppol/);

    // Settled in part.
    const paid = await invoice(b);
    await asUser(db, b.accountant, async () => {
      const journal = await one<{ id: string }>(db, `select miscellaneous_journal_id as id from companies where id = $1`, [b.companyId]);
      const payment = await one<{ id: string }>(
        db,
        `insert into entries (company_id, journal_id, entry_date, description) values ($1, $2, '2026-06-20', 'Paid') returning id`,
        [b.companyId, journal.id],
      );
      await db.query(
        `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit, contact_id)
         values ($1, $2, $3, 10, 50, 0, null), ($1, $2, $4, 20, 0, 50, $5)`,
        [payment.id, b.companyId, await accountId(db, b.companyId, roleOf(b.pack, 'bank')),
         await accountId(db, b.companyId, roleOf(b.pack, 'receivable')), b.customer],
      );
      await db.query(`select post_entry($1)`, [payment.id]);
      const line = await one<{ id: string }>(db, `select id from entry_lines where entry_id = $1 and credit > 0`, [payment.id]);
      await db.query(`select reconcile($1, $2)`, [await thirdPartyLine(db, 'document_id', paid), line.id]);
    });
    expect(await refusalOf(`select unpost_document($1)`, [paid], b.accountant)).toMatch(/^document_paid\b.*unreconcile/);

    // Credited by a posted credit note that names it.
    const credited = await invoice(b);
    const byHand = await newDocument(db, b.companyId, {
      docType: 'sale_credit_note',
      contactId: b.customer,
      lines: [{ unitPrice: 10, taxCode: b.tax.code, accountCode: roleOf(b.pack, 'sales') }],
    });
    await asUser(db, b.accountant, async () => {
      await db.query(`update documents set reversed_document_id = $2 where id = $1`, [byHand, credited]);
      await db.query(`select post_document($1)`, [byHand]);
    });
    expect(await refusalOf(`select unpost_document($1)`, [credited], b.accountant)).toMatch(/^document_already_credited\b/);

    // Not the last number drawn, in a country that forbids a hole: the credit
    // note above drew after it.
    const early = await invoice(b);
    await invoice(b);
    expect(await refusalOf(`select unpost_document($1)`, [early], b.accountant)).toMatch(
      /^document_not_last_number\b.*forbids a hole.*cancel_document\(\)/,
    );

    // Its period: locked, tax-locked, in a closed year, or declared.
    const last = await invoice(b, '2026-03-11');
    for (const [lock, refused] of [
      [`update companies set lock_date = '2026-03-31' where id = $1`, /^document_period_closed\b.*period_locked/],
      [`update companies set tax_lock_date = '2026-03-31' where id = $1`, /^document_period_closed\b.*tax_period_locked/],
      [`update fiscal_years set is_closed = true where company_id = $1`, /^document_period_closed\b.*fiscal_year_closed/],
    ] as const) {
      await db.exec('begin');
      try {
        // A year is closed by close_fiscal_year(), which books its closing
        // entries; only the fact that it is closed is under test here.
        await db.exec('alter table fiscal_years disable trigger fiscal_years_guard_closed');
        await db.query(lock, [b.companyId]);
        await db.query(`select set_config('ekwo.installing', '', true), set_config('request.jwt.claims', $1, true)`, [
          JSON.stringify({ sub: b.accountant, role: 'authenticated' }),
        ]);
        await db.exec('set local role authenticated');
        const message = await db.query(`select unpost_document($1)`, [last]).then(
          () => 'accepted',
          (error: Error) => error.message,
        );
        expect(message).toMatch(refused);
      } finally {
        await db.exec('rollback');
      }
    }
    // A declaration that has gone over it, the tax lock left where it was.
    await db.exec('begin');
    try {
      await db.query(
        `insert into tax_filings (company_id, report_code, period_start, period_end, state, filed_at)
         values ($1, $2, '2026-03-01', '2026-03-31', 'filed', now())`,
        [b.companyId, b.pack.reportCode],
      );
      await db.query(`select set_config('ekwo.installing', '', true), set_config('request.jwt.claims', $1, true)`, [
        JSON.stringify({ sub: b.accountant, role: 'authenticated' }),
      ]);
      await db.exec('set local role authenticated');
      const message = await db.query(`select unpost_document($1)`, [last]).then(
        () => 'accepted',
        (error: Error) => error.message,
      );
      expect(message).toMatch(/^document_declared\b.*filed.*cancel_document\(\)/);
    } finally {
      await db.exec('rollback');
    }

    // Somebody who may only read, and a key that may not post a document.
    expect(await refusalOf(`select unpost_document($1)`, [last], b.viewer)).toMatch(/^not_allowed\b.*documents\.post/);
    expect(await refusalOf(`select unpost_document(gen_random_uuid())`, [], b.accountant)).toMatch(/^unknown_document\b/);

    // Every refusal was rolled back: the counter of entries moved only with
    // the documents and the payment the setup posted.
    const before = await count();
    expect(await refusalOf(`select unpost_document($1)`, [early], b.accountant)).not.toBe('accepted');
    expect(await count()).toBe(before);

    // And the last one does go back.
    expect((await unpost(b, last))['state']).toBe('draft');
  });

  it('allows a number that is not the last where the country allows a hole, and leaves the counter alone', async () => {
    const early = await invoice(holed);
    const later = await invoice(holed);
    const earlyNumber = (await one<{ number: string }>(db, `select number from documents where id = $1`, [early])).number;
    const laterNumber = (await one<{ number: string }>(db, `select number from documents where id = $1`, [later])).number;
    const counter = await counterOf(laterNumber, holed.companyId);

    expect(await verdict(holed, early)).toBeNull();
    expect((await unpost(holed, early))['number']).toBeNull();
    expect(await counterOf(laterNumber, holed.companyId)).toBe(counter);
    expect(
      await one(db, `select number_returned from document_unpostings where document_id = $1`, [early]),
    ).toEqual({ number_returned: false });

    // Posted again, it takes the next number, and the hole is the one the
    // country allows.
    await asUser(db, holed.accountant, () => db.query(`select post_document($1)`, [early]));
    const reposted = (await one<{ number: string }>(db, `select number from documents where id = $1`, [early])).number;
    expect(reposted).not.toBe(earlyNumber);
    expect(await counterOf(reposted, holed.companyId)).toBe(counter + 1);
  });
});

// ---------------------------------------------------------------------------
// The exception is narrow
// ---------------------------------------------------------------------------

describe('a posted document goes back to draft through unpost_document(), and in no other way', () => {
  it('refuses draft keyed by hand, a posted entry deleted by hand, and a record written by hand', async () => {
    const id = await invoice(gapless);
    const entryId = (await one<{ entry_id: string }>(db, `select entry_id from documents where id = $1`, [id])).entry_id;

    expect(await refusalOf(`update documents set state = 'draft', entry_id = null where id = $1`, [id], gapless.accountant)).toMatch(
      /^document_posted\b.*unpost_document\(\)/,
    );
    await expect(db.query(`update documents set state = 'draft' where id = $1`, [id])).rejects.toThrow(/document_posted/);
    expect(await refusalOf(`delete from entries where id = $1`, [entryId], gapless.accountant)).toMatch(/^entry_posted\b/);
    await expect(db.query(`delete from entries where id = $1`, [entryId])).rejects.toThrow(/entry_posted/);

    // The record is written by unpost_document() and by nobody else.
    expect(
      await refusalOf(
        `insert into document_unpostings (company_id, document_id, doc_type, entry_id, entry_number, journal_id, entry_date, number_returned)
         select company_id, id, doc_type, entry_id, number, (select journal_id from entries where id = entry_id), document_date, false
           from documents where id = $1`,
        [id],
        gapless.accountant,
      ),
    ).toMatch(/permission denied/);

    // A record of another transaction lets nothing through: the installer
    // writes one, and the next statement is still refused.
    await db.query(
      `insert into document_unpostings (company_id, document_id, doc_type, entry_id, entry_number, journal_id, entry_date, number_returned)
       select d.company_id, d.id, d.doc_type, d.entry_id, d.number, e.journal_id, e.entry_date, false
         from documents d join entries e on e.id = d.entry_id where d.id = $1`,
      [id],
    );
    await expect(db.query(`update documents set state = 'draft', entry_id = null where id = $1`, [id])).rejects.toThrow(/document_posted/);
    await expect(db.query(`delete from entries where id = $1`, [entryId])).rejects.toThrow(/entry_posted/);
    await db.query(`delete from document_unpostings where document_id = $1`, [id]);
    expect(await one(db, `select state from documents where id = $1`, [id])).toEqual({ state: 'posted' });
  });
});

// ---------------------------------------------------------------------------
// A cancelled invoice stays matched to its credit note
// ---------------------------------------------------------------------------

describe('a cancelled invoice is not unmatched from what cancelled it', () => {
  it('refuses unreconcile() and a delete by hand, by name', async () => {
    const id = await invoice(gapless);
    await asUser(db, gapless.accountant, () => db.query(`select cancel_document($1)`, [id]));
    const matching = await one<{ id: string }>(
      db,
      `select r.id from reconciliations r
         join entry_lines l on l.id in (r.debit_line_id, r.credit_line_id)
         join documents d on d.entry_id = l.entry_id
        where d.id = $1 limit 1`,
      [id],
    );
    expect(await refusalOf(`select unreconcile($1)`, [matching.id], gapless.accountant)).toMatch(
      /^document_cancelled_stays_matched\b/,
    );
    expect(await refusalOf(`delete from reconciliations where id = $1`, [matching.id], gapless.accountant)).toMatch(
      /^document_cancelled_stays_matched\b/,
    );
    await expect(db.query(`select unreconcile($1)`, [matching.id])).rejects.toThrow(/document_cancelled_stays_matched/);
    expect(await one(db, `select state, payment_state from documents where id = $1`, [id])).toEqual({
      state: 'cancelled',
      payment_state: 'reversed',
    });
  });
});
