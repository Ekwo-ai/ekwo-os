import type { PGlite } from '@electric-sql/pglite';
import { one } from './db.js';
import { newUser } from './factory.js';

/**
 * What a signed-in member is told, in a transaction rolled back afterwards:
 * `accepted`, or the sentence the database refused with. `prelude` runs first,
 * in the same transaction and as the same member — a setting raised by hand,
 * say.
 */
export async function refusalAs(
  db: PGlite,
  who: string,
  sql: string,
  params: unknown[] = [],
  prelude?: string,
): Promise<string> {
  await db.exec('begin');
  try {
    await db.query(`select set_config('ekwo.installing', '', true), set_config('request.jwt.claims', $1, true)`, [
      JSON.stringify({ sub: who, role: 'authenticated' }),
    ]);
    await db.exec('set local role authenticated');
    if (prelude !== undefined) await db.exec(prelude);
    return await db.query(sql, params).then(
      () => 'accepted',
      (error: Error) => error.message,
    );
  } finally {
    await db.exec('rollback');
  }
}

/**
 * A sale any pack can book, read from the company's own books rather than
 * named: a domestic tax at a percentage, not on a cash basis, whose base and
 * tax postings of an invoice both name a declaration box — the highest rate
 * first — and the first income account of the chart.
 */
export async function plainSale(
  db: PGlite,
  companyId: string,
): Promise<{ taxCode: string; taxId: string; accountCode: string }> {
  const tax = await one<{ code: string; id: string }>(
    db,
    `select t.code, t.id
       from taxes t
      where t.company_id = $1
        and t.applies_to in ('sale', 'both')
        and t.treatment = 'domestic'
        and t.amount_type = 'percent'
        and t.amount > 0
        and t.active
        and not t.price_include
        and not t.cash_basis
        and t.valid_to is null
        and exists (select 1 from tax_postings p
                     where p.tax_id = t.id and p.document_kind = 'invoice'
                       and p.posting_type = 'tax' and p.declaration_box is not null)
        and exists (select 1 from tax_postings p
                     where p.tax_id = t.id and p.document_kind = 'invoice'
                       and p.posting_type = 'base' and p.declaration_box is not null)
      order by t.amount desc, t.code
      limit 1`,
    [companyId],
  );
  const account = await one<{ code: string }>(
    db,
    `select code from accounts where company_id = $1 and account_type = 'income' order by code limit 1`,
    [companyId],
  );
  return { taxCode: tax.code, taxId: tax.id, accountCode: account.code };
}

/** A member of the company in the role named, as a user of its own. */
export async function newMember(db: PGlite, companyId: string, role: string): Promise<string> {
  const id = await newUser(db);
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, $3)`, [
    companyId,
    id,
    role,
  ]);
  return id;
}
