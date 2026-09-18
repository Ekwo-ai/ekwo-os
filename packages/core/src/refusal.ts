/**
 * Reading a refusal of the database — once, for every surface.
 *
 * The accounting rules live in the schema and they raise with a prefixed
 * name: `period_locked: 2026-03-31 is …`, `tax_territory_mismatch: …`. The
 * MCP server hands that name to a model and the command line turns it into an
 * exit code, so both have to agree on what a name is and on what counts as
 * the books saying no. That agreement is this file. It imports nothing, on
 * purpose: the CLI is handed a database password, and what it loads from here
 * has to be readable in one sitting.
 */

/** The identifier of a raise like `period_locked: 2026-03-31 is …`, or undefined. */
export function socleCode(message: string): string | undefined {
  const match = /^([a-z][a-z0-9_]{3,}):/.exec(message.trim());
  return match?.[1];
}

/**
 * Whether an SQLSTATE is the database declining, as opposed to failing.
 *
 * The schema refuses in a small number of ways and every one of them is a
 * decision: a `raise exception` of its own (`P0001`, and `P0002` where a
 * function names something that is not there or not visible), a capability
 * the caller does not hold or a row level security policy (`42501`), a lock
 * on a period or a closed year (`55006`), and a constraint (class `23`).
 * Everything else — a connection that dropped (`08…`), a relation that does
 * not exist (`42P01`), a syntax error — is the software failing, and a caller
 * that retries or reports a bug is right to.
 */
export function isRefusalState(sqlstate: string | undefined): boolean {
  if (sqlstate === undefined) return false;
  if (sqlstate === 'P0001' || sqlstate === 'P0002') return true;
  if (sqlstate === '42501' || sqlstate === '55006') return true;
  return sqlstate.startsWith('23');
}
