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

import { SCHEMA_FEATURES, supports, type SchemaFeature } from '../schema.js';

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

export { FORMER_SOCLE_SCHEMA, SOCLE_MARKER, SOCLE_SCHEMA, socleMarkerInCatalogue, socleNamed } from './socle-names.js';
import { FORMER_SOCLE_SCHEMA, SOCLE_MARKER, SOCLE_SCHEMA } from './socle-names.js';

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

/** A backend that also says where the socle is, and at which version. */
export interface SocleBackend extends Backend {
  /** `ekwo` or `public`, resolved by the marker on first use. */
  socleSchema(): Promise<string>;
  /**
   * What `ekwo_schema_version()` answers, asked the first time a call touches
   * something of `SCHEMA_FEATURES` and kept; `undefined` while it does not
   * answer.
   */
  schemaVersion(): Promise<string | undefined>;
}

/** Each column of `SCHEMA_FEATURES`, by table: what a read leaves out below its version. */
const FEATURE_COLUMNS = new Map<string, Array<{ column: string; feature: SchemaFeature }>>();
/** Each function of `SCHEMA_FEATURES`, and the feature it belongs to. */
const FEATURE_FUNCTIONS = new Map<string, SchemaFeature>();
for (const [feature, objects] of Object.entries(SCHEMA_FEATURES) as Array<[SchemaFeature, (typeof SCHEMA_FEATURES)[SchemaFeature]]>) {
  for (const qualified of objects.columns) {
    const [table, column] = qualified.split('.') as [string, string];
    FEATURE_COLUMNS.set(table, [...(FEATURE_COLUMNS.get(table) ?? []), { column, feature }]);
  }
  for (const fn of objects.functions) FEATURE_FUNCTIONS.set(fn, feature);
}

/** `amount` for `amount`, `amount::text` and `total:amount`, the forms a select list takes. */
function selectedColumn(entry: string): string {
  const cast = entry.indexOf('::');
  const bare = cast === -1 ? entry : entry.slice(0, cast);
  const alias = bare.indexOf(':');
  return (alias === -1 ? bare : bare.slice(alias + 1)).trim();
}

/**
 * Whether the schema behind `backend` has `feature`.
 *
 * A backend that has `schemaVersion()` answers from it: every one built by
 * `onSocle()`, and any other that a surface gives the method — Ekwo Cloud's
 * own, which reads the version of the project it is signed in to. A backend
 * without it — and one whose database has not said its version — is taken
 * to be at this release, which is what every call assumed before the floor
 * was separated from the release: an unknown version never makes a current
 * installation lose a column.
 */
export async function backendSupports(backend: Backend, feature: SchemaFeature): Promise<boolean> {
  const versioned = backend as Partial<SocleBackend>;
  if (typeof versioned.schemaVersion !== 'function') return true;
  const installed = await versioned.schemaVersion();
  return installed === undefined || supports(installed, feature);
}

/** The refusal of a call that needs a newer schema than the one it reached. */
export function schemaTooOldFor(feature: SchemaFeature, installed: string, what: string): BooksError {
  const since = SCHEMA_FEATURES[feature].since;
  return new BooksError(
    `schema_too_old_for: ${what} needs schema ${since} (${feature}), and this database is at ${installed}. Its operator runs \`ekwo migrate\`.`,
    {
      hint: 'Everything older than that keeps working on this database; this one thing waits for the update.',
    },
  );
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

  // Asked once, and only by a call that touches a feature: a backend that
  // never reads one of those columns never pays the round trip. An answer that
  // fails is not kept, so the next call asks again.
  let version: Promise<string | undefined> | undefined;
  const schemaVersion = (): Promise<string | undefined> => {
    if (version === undefined) {
      version = (async () => {
        const rows = await inner.rpc<unknown>(SOCLE_MARKER, {}, await socleSchema());
        const answer = rows[0];
        return typeof answer === 'string' ? answer : undefined;
      })().then(
        (answer) => {
          if (answer === undefined) version = undefined;
          return answer;
        },
        () => {
          version = undefined;
          return undefined;
        },
      );
    }
    return version;
  };

  // The columns among `named` of a socle table this database does not have
  // yet, and the version it is at: nothing when none of them belongs to a
  // feature — the version is not even asked then — when the call names a
  // module's schema, or when the version is not known.
  const lacking = async (
    table: string,
    schema: string | undefined,
    named: readonly string[],
  ): Promise<{ columns: Map<string, SchemaFeature>; installed: string } | undefined> => {
    const gated = FEATURE_COLUMNS.get(table)?.filter((g) => named.includes(g.column));
    if (gated === undefined || gated.length === 0) return undefined;
    if (schema !== undefined && schema !== (await socleSchema())) return undefined;
    const installed = await schemaVersion();
    if (installed === undefined) return undefined;
    const columns = new Map(gated.filter((g) => !supports(installed, g.feature)).map((g) => [g.column, g.feature]));
    return columns.size === 0 ? undefined : { columns, installed };
  };

  const refuseCall = async (fn: string, schema: string | undefined): Promise<void> => {
    const feature = FEATURE_FUNCTIONS.get(fn);
    if (feature === undefined || (schema !== undefined && schema !== (await socleSchema()))) return;
    const installed = await schemaVersion();
    if (installed !== undefined && !supports(installed, feature)) throw schemaTooOldFor(feature, installed, `${fn}()`);
  };

  const refuseWrite = async (table: string, rows: Row[], schema: string | undefined): Promise<void> => {
    const missing = await lacking(table, schema, [...new Set(rows.flatMap((row) => Object.keys(row)))]);
    if (missing === undefined) return;
    for (const row of rows) {
      for (const key of Object.keys(row)) {
        const feature = missing.columns.get(key);
        if (feature !== undefined) throw schemaTooOldFor(feature, missing.installed, `writing ${table}.${key}`);
      }
    }
  };

  return {
    mode: inner.mode,
    actingAs: inner.actingAs,
    agent: inner.agent,
    socleSchema,
    schemaVersion,
    async rpc<T>(fn: string, args?: Record<string, unknown>, schema?: string): Promise<T[]> {
      await refuseCall(fn, schema);
      return inner.rpc<T>(fn, args, await schemaOf(schema));
    },
    async rpcVoid(fn: string, args?: Record<string, unknown>, schema?: string): Promise<void> {
      await refuseCall(fn, schema);
      return inner.rpcVoid(fn, args, await schemaOf(schema));
    },
    async select<T>(query: SelectQuery): Promise<T[]> {
      // A column a newer schema added is not asked of an older one: the row
      // comes back without it, as it did from the release that introduced it.
      const missing = await lacking(query.table, query.schema, query.columns.map(selectedColumn));
      const columns =
        missing === undefined ? query.columns : query.columns.filter((c) => !missing.columns.has(selectedColumn(c)));
      return inner.select<T>({ ...query, columns, schema: await schemaOf(query.schema) });
    },
    async insert<T>(table: string, rows: Row[], returning?: string[], schema?: string): Promise<T[]> {
      await refuseWrite(table, rows, schema);
      const missing = returning === undefined ? undefined : await lacking(table, schema, returning.map(selectedColumn));
      const kept = missing === undefined ? returning : returning?.filter((c) => !missing.columns.has(selectedColumn(c)));
      return inner.insert<T>(table, rows, kept, await schemaOf(schema));
    },
    async update<T>(table: string, patch: Row, where: Filter[], returning?: string[], schema?: string): Promise<T[]> {
      await refuseWrite(table, [patch], schema);
      const missing = returning === undefined ? undefined : await lacking(table, schema, returning.map(selectedColumn));
      const kept = missing === undefined ? returning : returning?.filter((c) => !missing.columns.has(selectedColumn(c)));
      return inner.update<T>(table, patch, where, kept, await schemaOf(schema));
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
