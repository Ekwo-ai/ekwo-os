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
   * The Postgres schema the table lives in. Undefined is the socle's, which a
   * backend resolves once by its marker (`socleSchemaResolver()`): `ekwo`, or
   * `public` on an installation the socle has not moved out of yet. A module
   * names its own — `fixed_assets`, `budgets` — and PostgREST serves it only
   * once the project lists it under its exposed schemas.
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

/**
 * What a session of an agent chose for itself, the way a person passes
 * `--autopilot` or `--review` to one session. Unset, each company's
 * `agent_posting` decides; a company that is `review_only` refuses autopilot
 * (`autopilot_forbidden`).
 */
export type SessionPosting = 'review' | 'autopilot';
export const SESSION_POSTING: readonly SessionPosting[] = ['review', 'autopilot'];

/**
 * The mark an agent puts on every transaction it opens (`agent_call()`): its
 * session's choice, if it made one, and a name for the session, which the
 * audit trail records beside every posting it makes.
 */
export interface AgentSession {
  posting?: SessionPosting | undefined;
  id?: string | undefined;
}

export interface Backend {
  /** Which route this is, for `status` and for the error messages. */
  readonly mode: 'postgrest' | 'sql';
  /** Who we are acting as, when that is known. */
  readonly actingAs: string | undefined;
  /** Set when every transaction is marked as an agent's, with its session. */
  readonly agent?: AgentSession | undefined;
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
 * Answers whether the marker is in `schema`. Each route asks in its own way —
 * the catalogue over SQL, a call with a profile over PostgREST — and the
 * decision stays here.
 */
export type SocleProbe = (schema: string) => Promise<boolean>;

/**
 * The socle's schema, resolved once and kept.
 *
 * Once per connection: a backend builds one resolver and every call after the
 * first reads the answer it kept. A probe that fails is not kept, so the next
 * call asks again rather than living on an error.
 */
export function socleSchemaResolver(probe: SocleProbe): () => Promise<string> {
  let resolved: Promise<string> | undefined;
  return () => {
    if (resolved === undefined) {
      resolved = probe(SOCLE_SCHEMA).then(
        (found) => (found ? SOCLE_SCHEMA : FORMER_SOCLE_SCHEMA),
        (error: unknown) => {
          resolved = undefined;
          throw error;
        },
      );
    }
    return resolved;
  };
}

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
 * What a call of the marker over PostgREST says about the schema it named.
 *
 * PostgREST answers 406 (`PGRST106`) for a schema the project does not expose
 * and 404 (`PGRST202`) for a function its cache does not hold there: in both
 * cases the socle is not in that schema yet. A refusal of the call itself
 * (`42501`) means the function is there and this caller may not run it, which
 * still places the socle. Anything else is not an answer to the question:
 * `undefined`, and the caller throws what it received.
 */
export function socleMarkerAnswer(answer: { ok: boolean; status?: number | undefined; code?: string | undefined }): boolean | undefined {
  if (answer.ok || answer.code === '42501') return true;
  if (answer.code === 'PGRST106' || answer.code === 'PGRST202') return false;
  if (answer.status === 404 || answer.status === 406) return false;
  return undefined;
}

/** A backend that also says where the socle is. */
export interface SocleBackend extends Backend {
  /** `ekwo` or `public`, resolved by the marker on first use. */
  socleSchema(): Promise<string>;
}

/**
 * The same backend, with the socle's schema named on every call.
 *
 * A function of this folder names a module's schema and leaves the socle's
 * unsaid; this is where the unsaid one becomes explicit, for both routes —
 * `Accept-Profile` / `Content-Profile` over PostgREST, `ekwo.x` or `public.x`
 * over SQL — so neither depends on a default of the server.
 */
export function onSocle(inner: Backend, socleSchema: () => Promise<string>): SocleBackend {
  const schemaOf = async (schema: string | undefined): Promise<string> => schema ?? (await socleSchema());
  return {
    mode: inner.mode,
    actingAs: inner.actingAs,
    agent: inner.agent,
    socleSchema,
    async rpc<T>(fn: string, args?: Record<string, unknown>, schema?: string): Promise<T[]> {
      return inner.rpc<T>(fn, args, await schemaOf(schema));
    },
    async rpcVoid(fn: string, args?: Record<string, unknown>, schema?: string): Promise<void> {
      return inner.rpcVoid(fn, args, await schemaOf(schema));
    },
    async select<T>(query: SelectQuery): Promise<T[]> {
      return inner.select<T>({ ...query, schema: await schemaOf(query.schema) });
    },
    async insert<T>(table: string, rows: Row[], returning?: string[], schema?: string): Promise<T[]> {
      return inner.insert<T>(table, rows, returning, await schemaOf(schema));
    },
    async update<T>(table: string, patch: Row, where: Filter[], returning?: string[], schema?: string): Promise<T[]> {
      return inner.update<T>(table, patch, where, returning, await schemaOf(schema));
    },
    async remove(table: string, where: Filter[], schema?: string): Promise<void> {
      return inner.remove(table, where, await schemaOf(schema));
    },
    close: () => inner.close(),
  };
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
 * `fixed_assets.disposals`, or `disposals` when there is no schema to name.
 *
 * A backend built by `onSocle()` always has one to name: the socle's own
 * schema is resolved before a call reaches here, so `undefined` is left to
 * SQL that is meant to follow the connection's `search_path`.
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
