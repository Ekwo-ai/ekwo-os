/**
 * The one interface every bookkeeping function is written against.
 *
 * There are two ways to reach an Ekwo database and neither of them is a
 * privileged one. The recommended route is PostgREST with the signed-in
 * user's own token, which is how the schema is meant to be read and written:
 * row level security decides, exactly as it would for that person in a
 * browser. The second is a direct Postgres connection, for a self-hosted
 * installation and for the tests — and even there the claims and the role are
 * set on every call, so the same policies apply.
 *
 * The functions of this folder therefore never see a client, a token or a
 * connection string. They see `select`, `insert`, `update`, `remove` and
 * `rpc`, and what comes back is whatever the policies let through.
 *
 * This lived in the MCP server. The command line keeps the same books through
 * the same functions, so the interface and the functions moved here, and each
 * surface brings its own implementation of it: the server's over
 * `@supabase/supabase-js` or a Postgres driver, the command line's over
 * `fetch`. Nothing in this folder imports anything from outside the core.
 */

export type Value = string | number | boolean | null;

export type Filter =
  | { column: string; op: 'eq' | 'neq' | 'gt' | 'gte' | 'lt' | 'lte'; value: Value }
  | { column: string; op: 'in'; value: Value[] }
  | { column: string; op: 'ilike'; value: string }
  | { column: string; op: 'is'; value: null };

export interface Order {
  column: string;
  ascending?: boolean;
}

export interface SelectQuery {
  table: string;
  /**
   * The Postgres schema the table lives in. Undefined is `public`, which is
   * the socle; a module names its own — `assets`, `budgets` — and PostgREST
   * serves it only once the project lists it under its exposed schemas.
   */
  schema?: string;
  /**
   * Columns to read. A `numeric` column is asked for as `amount::text`, so it
   * arrives as the decimal string Postgres holds rather than as a float that
   * JSON happened to survive. Both backends understand that spelling.
   */
  columns: string[];
  where?: Filter[];
  order?: Order[];
  limit?: number;
}

export type Row = Record<string, unknown>;

export interface Backend {
  /** Which route this is, for `status` and for the error messages. */
  readonly mode: 'postgrest' | 'sql';
  /** Who we are acting as, when that is known. */
  readonly actingAs: string | undefined;
  /**
   * Calls a function of the schema. Always an array of rows, whatever the
   * function returns: PostgREST hands back an object for a function returning
   * one composite row and an array for a set, and a tool should not have to
   * care which route it came over.
   */
  rpc<T = Row>(fn: string, args?: Record<string, unknown>, schema?: string): Promise<T[]>;
  /** The same, for a function that returns nothing. */
  rpcVoid(fn: string, args?: Record<string, unknown>, schema?: string): Promise<void>;
  select<T = Row>(query: SelectQuery): Promise<T[]>;
  insert<T = Row>(table: string, rows: Row[], returning?: string[], schema?: string): Promise<T[]>;
  update<T = Row>(
    table: string,
    patch: Row,
    where: Filter[],
    returning?: string[],
    schema?: string,
  ): Promise<T[]>;
  remove(table: string, where: Filter[], schema?: string): Promise<void>;
  close(): Promise<void>;
}

/**
 * An error of this layer, or one that carries what the database said.
 *
 * The accounting rules live in the schema and they raise with a prefixed code
 * — `period_locked:`, `entry_unbalanced:`, `document_total_mismatch:`. Those
 * messages are the most useful thing we can hand a model, so they travel up
 * unchanged; `hint` adds the sentence a human would add, never a replacement.
 */
export class BooksError extends Error {
  override name = 'BooksError';
  readonly code: string | undefined;
  readonly hint: string | undefined;

  constructor(message: string, options: { code?: string | undefined; hint?: string } = {}) {
    super(message);
    this.code = options.code;
    this.hint = options.hint;
  }
}

const IDENTIFIER = /^[a-z_][a-z0-9_]*$/;

/**
 * Refuses anything that is not a plain lowercase identifier.
 *
 * Table and column names in this package are written in this package — none
 * of them comes from a tool argument. This function is the proof of that
 * rather than a defence against it, and it costs nothing to keep true.
 */
/**
 * `assets.assets`, or `assets` when there is no schema to name.
 *
 * Both halves go through `identifier()`, so a module code that came from the
 * registry rather than from this package still cannot be anything but a plain
 * lowercase name.
 */
export function qualified(schema: string | undefined, name: string): string {
  return schema === undefined ? identifier(name) : `${identifier(schema)}.${identifier(name)}`;
}

export function identifier(name: string): string {
  if (!IDENTIFIER.test(name)) {
    throw new BooksError(`bad_identifier: ${name} is not a plain column or table name`);
  }
  return name;
}

/** `amount::text` reads back as `amount`; every other column is itself. */
export function columnName(column: string): string {
  const cast = column.indexOf('::');
  return identifier(cast === -1 ? column : column.slice(0, cast));
}
