/**
 * Where the socle lives, for the connection that installs and operates it.
 *
 * The socle was created in `public` and lives in its own schema, `ekwo`,
 * since `20261028040000` (decision 0090); a database that has not run that
 * file yet still holds it in `public`. The bookkeeping routes resolve it once per connection in
 * `@ekwo-ai/core`; this file is the same question asked on the owner's
 * connection, by the same marker and the same catalogue query.
 *
 * It is asked again each time rather than kept. This connection is the one
 * that runs the migrations, and so the one that may move the socle while it
 * is open: what was true before `ekwo migrate` need not be true after it.
 */

import {
  FORMER_SOCLE_SCHEMA,
  SOCLE_SCHEMA,
  identifier,
  socleMarkerInCatalogue,
} from '@ekwo-ai/core';
import { scalar, type SqlClient } from './sql.js';

/** `ekwo` once the socle is there, `public` until then. */
export async function socleSchemaOf(db: SqlClient): Promise<string> {
  const found = await socleMarkerInCatalogue((sql, params) => db.query(sql, params), SOCLE_SCHEMA);
  return found ? SOCLE_SCHEMA : FORMER_SOCLE_SCHEMA;
}

/**
 * Puts the socle's schema first on this connection's `search_path`, and
 * returns it.
 *
 * The seeds are written unqualified — `insert into country_packs …` — and so
 * is most of the SQL this command line runs as the owner. With the socle's
 * schema first they land in the socle wherever it is, and the rest of the path
 * (`extensions` on Supabase, for one) stays as it was behind it. Session-wide,
 * like `ekwo.installing`, on a pool of one connection.
 */
export async function useSocleSchema(db: SqlClient): Promise<string> {
  const schema = await socleSchemaOf(db);
  const current = (await scalar<string>(db, `select current_setting('search_path')`)) ?? '';
  const rest = current
    .split(',')
    .map((part) => part.trim())
    .filter((part) => part.length > 0 && part !== schema && part !== `"${schema}"`);
  await db.query(`select set_config('search_path', $1, false)`, [[identifier(schema), ...rest].join(', ')]);
  return schema;
}

/**
 * The one line that exposes the socle's schema to the Data API.
 *
 * No migration can do it: the schemas PostgREST serves are a setting of the
 * project, not of the database. Printed by `ekwo migrate` and by the doctor
 * until the schema is exposed.
 */
export const EXPOSE_SOCLE_LINE =
  `Add "${SOCLE_SCHEMA}" to Project Settings → Data API → Exposed schemas (on a local stack, \`schemas\` under [api] in supabase/config.toml) — the socle lives there, and every call of every client names it.`;
