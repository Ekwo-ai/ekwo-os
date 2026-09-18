/**
 * What the bookkeeping functions share: reading one row or saying why not,
 * turning codes into ids, and the currency a company keeps its books in.
 */

import { BooksError, type Backend } from './backend.js';

/** The row, or a refusal naming what row level security did not return. */
export function only<T>(rows: T[], what: string): T {
  const row = rows[0];
  if (row === undefined) {
    throw new BooksError(
      `not_found: ${what}. Either it does not exist, or your role on that company does not allow this.`,
    );
  }
  return row;
}


/** The row, or a refusal that says what was not visible rather than crashing. */
export function onlyVisible<T>(rows: T[], what: string): T {
  const row = rows[0];
  if (row === undefined) {
    throw new BooksError(
      `not_found: ${what}. Either it does not exist or you are not a member of the company that holds it.`,
    );
  }
  return row;
}


/** `{ id: name }` for a set of rows, to put names next to foreign keys. */
export async function namesOf(
  backend: Backend,
  table: string,
  ids: (string | null | undefined)[],
): Promise<Record<string, string>> {
  const wanted = [...new Set(ids.filter((id): id is string => typeof id === 'string'))];
  if (wanted.length === 0) return {};
  const rows = await backend.select<{ id: string; name: string }>({
    table,
    columns: ['id', 'name'],
    where: [{ column: 'id', op: 'in', value: wanted }],
  });
  return Object.fromEntries(rows.map((row) => [row.id, row.name]));
}


/**
 * The row a caller already created under this reference, if there is one.
 *
 * A creation that carries a `client_ref` is looked up before it is made, so a
 * caller that repeats itself after a dropped connection gets the first row
 * back rather than a second one. The lookup is a convenience and not the
 * guarantee: two callers racing each other both find nothing, and the unique
 * index on `(company_id, client_ref)` is what refuses the slower one.
 */
export async function createdBefore(
  backend: Backend,
  table: 'contacts' | 'documents' | 'payments',
  company: string,
  clientRef: string | undefined,
  columns: string[],
): Promise<Record<string, unknown> | undefined> {
  if (clientRef === undefined) return undefined;
  const rows = await backend.select<Record<string, unknown>>({
    table,
    columns,
    where: [
      { column: 'company_id', op: 'eq', value: company },
      { column: 'client_ref', op: 'eq', value: clientRef },
    ],
  });
  return rows[0];
}

/** Resolves codes to ids in one query, and says which code was unknown. */
/**
 * The currency an amount is in when the caller names none: the company's own.
 *
 * Never a literal. A company that keeps its books in Canadian dollars would
 * get a euro invoice out of a euro written here, and a wrong answer is worse
 * than a refusal. `companies.currency_code` is never null, so there is always
 * one to find.
 */
export async function companyCurrency(backend: Backend, company: string): Promise<string> {
  const rows = await backend.select<{ currency_code: string }>({
    table: 'companies',
    columns: ['currency_code'],
    where: [{ column: 'id', op: 'eq', value: company }],
  });
  const currency = rows[0]?.currency_code;
  if (currency === undefined) {
    throw new BooksError(
      `not_found: company ${company}. Either it does not exist or you are not a member of it.`,
    );
  }
  return currency;
}

export async function idsByCode(
  backend: Backend,
  table: 'accounts' | 'taxes' | 'journals',
  company: string,
  codes: string[],
): Promise<Map<string, string>> {
  const singular = { accounts: 'account', taxes: 'tax', journals: 'journal' }[table];
  const wanted = [...new Set(codes)];
  if (wanted.length === 0) return new Map();
  const rows = await backend.select<{ id: string; code: string }>({
    table,
    columns: ['id', 'code'],
    where: [
      { column: 'company_id', op: 'eq', value: company },
      { column: 'code', op: 'in', value: wanted },
    ],
  });
  const found = new Map(rows.map((row) => [row.code, row.id]));
  for (const code of wanted) {
    if (!found.has(code)) {
      throw new BooksError(
        `unknown_${singular}_code: no ${singular} "${code}" in this company. list_accounts, get_company and the ekwo://companies/{id}/taxes resource say what exists.`,
      );
    }
  }
  return found;
}

