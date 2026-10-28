/**
 * Where the socle lives, in words a file with no dependency can carry.
 *
 * The constants, the catalogue question and the reading of a module's SQL
 * for the socle's schema of the day live here, imported by `backend.ts` and
 * by the test image builder alike — the latter runs under plain Node, so
 * this file imports nothing.
 */

/**
 * Where the socle lives: its own schema, and the one it is leaving.
 *
 * The socle was created in `public` and moves to `ekwo` (decision 0090). A
 * client of either layout finds it by one marker, the function that carries
 * the schema's version: present in `ekwo`, the socle is there; absent, it is
 * still in `public`. Nothing else is guessed, and no other schema is tried —
 * a database that has neither is not an Ekwo installation, and the first
 * query says so in the database's own words.
 */
export const SOCLE_SCHEMA = 'ekwo';
export const FORMER_SOCLE_SCHEMA = 'public';
export const SOCLE_MARKER = 'ekwo_schema_version';

/**
 * Whether the marker is in `schema`, read from the catalogue of a direct
 * connection.
 *
 * Asked as the connection, before any role is set: `pg_proc` is readable by
 * everybody, and the question is where a function is, not whether this user
 * may call it. `query` is the driver's, whichever it is.
 */
export async function socleMarkerInCatalogue(
  query: (sql: string, params: unknown[]) => Promise<Array<Record<string, unknown>>>,
  schema: string,
): Promise<boolean> {
  const rows = await query(
    `select exists (
       select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = $1 and p.proname = $2 and p.pronargs = 0
     ) as found`,
    [schema, SOCLE_MARKER],
  );
  return rows[0]?.['found'] === true;
}

/**
 * The SQL of a module, read for the socle's schema of the day.
 *
 * A module names the socle: `references public.companies(id)`,
 * `public.is_company_member(…)`, `set search_path = public, pg_temp`
 * (decision 0051). Its migrations are published and never edited, and they
 * run on a fresh installation after the socle has moved to `ekwo`
 * (`20261028040000`, decision 0090). So whoever applies a module's file reads
 * it for the socle's schema of the day: with the socle in `ekwo`, `public.`
 * before a name becomes `ekwo.`, the string `'public'` becomes `'ekwo'` and a
 * `search_path = public` names `ekwo` — the same three rewrites the move
 * applied to the functions already installed. A file written for `ekwo`
 * passes unchanged, and so does every file while the socle is in `public`. A
 * sentence that ends with the word "public." is left alone: only a name
 * follows the dot that is rewritten.
 */
export function socleNamed(sql: string, schema: string): string {
  if (schema === FORMER_SOCLE_SCHEMA) return sql;
  return sql
    .replace(/\bpublic\.(?=[a-z_])/g, `${schema}.`)
    .replace(/'public'/g, `'${schema}'`)
    .replace(/(search_path\s*=\s*)public\b/g, `$1${schema}`);
}
