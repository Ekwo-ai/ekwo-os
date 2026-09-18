/**
 * What every bookkeeping verb starts with, and nothing about bookkeeping.
 *
 * A verb of this CLI is one function of `@ekwo-ai/core` — the function the MCP
 * server calls for the tool of the same meaning — handed a `Backend` that
 * speaks PostgREST as the person signed in. This file opens that backend,
 * settles which company the verb runs on, and reads what the caller typed:
 * flags, or one JSON document on the standard input. It passes values on as
 * text. No amount is parsed, added or rounded on this side of the database,
 * and `tests/cli/no-rules.test.ts` reads the commands to keep it that way.
 */

import type { Backend } from '@ekwo-ai/core';
import { UsageError, boolFlag, stringFlag, type ParsedArgs } from './args.js';
import { matchCompany } from './company.js';
import { actAsUser, refuseInstallerKey, type UserDeps } from './identity.js';
import { setContext } from './output.js';
import type { CompanyRef } from './profiles.js';

/** The flags every bookkeeping verb accepts. */
export const BOOKS_FLAGS = ['profile', 'company', 'supabase-url', 'anon-key'] as const;
/** And those of a verb that creates something. */
export const CREATE_FLAGS = [...BOOKS_FLAGS, 'ref', 'stdin'] as const;

export interface BooksDeps extends UserDeps {
  /** The standard input, when a test stands in for it. */
  stdin?: string | undefined;
}

export interface Books {
  backend: Backend;
  company: CompanyRef;
}

/** Signs in as the person, settles the company, and says so in the document. */
export async function openBooks(args: ParsedArgs, deps: BooksDeps): Promise<Books> {
  refuseInstallerKey(args);
  const acting = await actAsUser(args, deps);
  const backend = acting.client.backend(undefined);
  const instance = acting.client.instance.supabaseUrl;

  const asked = stringFlag(args, 'company');
  let company = acting.storedCompany;
  if (asked !== undefined) {
    const visible = await backend.select<{ id: string; name: string }>({
      table: 'companies',
      columns: ['id', 'name'],
      order: [{ column: 'name' }],
    });
    const match = matchCompany(visible, asked);
    company = { id: match.id, name: match.name };
  }
  setContext({ profile: acting.profile ?? null, instance, company: company ?? null });
  if (company === undefined) {
    throw new UsageError(
      'no_company: no company is in use. Run `ekwo use <company>`, or pass --company. None is ever picked for you, not even the only one.',
    );
  }
  return { backend, company };
}

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** An argument that has to be an id, refused here rather than by a cast in the database. */
export function uuidArg(value: string | undefined, what: string): string {
  if (value === undefined) throw new UsageError(`missing_argument: ${what} was not given.`);
  if (!UUID.test(value)) throw new UsageError(`bad_id: ${what} must be a uuid, got "${value}".`);
  return value.toLowerCase();
}

export function required(value: string | undefined, what: string, flag: string): string {
  if (value === undefined) throw new UsageError(`missing_argument: ${what} was not given. Pass ${flag}.`);
  return value;
}

/** Today, as the machine running the command calls it. Printed wherever it is used. */
export function today(): string {
  const now = new Date();
  const pad = (n: number): string => String(n).padStart(2, '0');
  return `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`;
}

async function readAll(): Promise<string> {
  const chunks: Buffer[] = [];
  for await (const chunk of process.stdin) chunks.push(Buffer.from(chunk as Uint8Array));
  return Buffer.concat(chunks).toString('utf8');
}

/**
 * The JSON document on the standard input, under `--stdin`.
 *
 * The way in for a program: the fields are the ones the MCP tool of the same
 * meaning takes, so an agent composes one object and escapes nothing. A field
 * nobody defined is refused rather than dropped — `unit_prise` silently doing
 * nothing is an invoice at the catalogue price. Flags given beside it win.
 */
export async function stdinDocument(
  args: ParsedArgs,
  deps: BooksDeps,
  known: readonly string[],
): Promise<Record<string, unknown>> {
  if (!boolFlag(args, 'stdin')) return {};
  if (deps.stdin === undefined && process.stdin.isTTY === true) {
    throw new UsageError('missing_input: --stdin reads a JSON document from the standard input, and this is a terminal. Pipe one in.');
  }
  const text = deps.stdin ?? (await readAll());
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch (error) {
    throw new UsageError(`bad_json: the standard input is not JSON: ${(error as Error).message}`);
  }
  if (typeof parsed !== 'object' || parsed === null || Array.isArray(parsed)) {
    throw new UsageError('bad_json: the standard input must be one JSON object.');
  }
  const unknown = Object.keys(parsed).filter((key) => !known.includes(key));
  if (unknown.length > 0) {
    throw new UsageError(`unknown_field: ${unknown.join(', ')}. This command reads: ${known.join(', ')}.`);
  }
  return parsed as Record<string, unknown>;
}

export const LINE_FIELDS = [
  'name',
  'description',
  'quantity',
  'unit_code',
  'unit_price',
  'discount_percent',
  'product_id',
  'product_code',
  'account_id',
  'account_code',
  'tax_id',
  'tax_code',
] as const;

/** The short keys `--line` accepts, and the field each one is. */
const LINE_KEYS: Record<string, (typeof LINE_FIELDS)[number]> = {
  name: 'name',
  description: 'description',
  qty: 'quantity',
  unit: 'unit_code',
  price: 'unit_price',
  discount: 'discount_percent',
  product: 'product_code',
  account: 'account_code',
  tax: 'tax_code',
};

/**
 * `--line "name=Audit,price=1500.00,tax=<code>"` — named fields, never positions.
 *
 * The card offered `"Audit 1 500 EUR@21"` and asked for an arbitration. It is
 * not shipped: "1 500" is one number or two, `@21` names a rate where the
 * books need a tax — several taxes share a rate — and a currency belongs to
 * the document, not to a line. Named fields cost a few characters and cannot
 * be misread; a comma inside a value is written `\,`. Anything richer goes
 * through `--stdin`, which is the form that is authoritative.
 */
export function parseLine(text: string): Record<string, string> {
  const line: Record<string, string> = {};
  for (const part of text.split(/(?<!\\),/)) {
    const equals = part.indexOf('=');
    const key = (equals === -1 ? part : part.slice(0, equals)).trim();
    const field = LINE_KEYS[key];
    if (equals === -1 || field === undefined) {
      throw new UsageError(
        `bad_line: "${part.trim()}" is not key=value with a key among ${Object.keys(LINE_KEYS).join(', ')}. Example: --line "name=Audit,price=1500.00,tax=<tax code>".`,
      );
    }
    line[field] = part.slice(equals + 1).trim().replace(/\\,/g, ',');
  }
  return line;
}

/** Refuses a line from `--stdin` that carries a field nobody defined. */
export function checkedLines(value: unknown): Record<string, unknown>[] {
  if (!Array.isArray(value)) throw new UsageError('bad_json: `lines` must be a list.');
  return value.map((line, index) => {
    if (typeof line !== 'object' || line === null || Array.isArray(line)) {
      throw new UsageError(`bad_json: line ${index + 1} must be an object.`);
    }
    const unknown = Object.keys(line).filter((key) => !(LINE_FIELDS as readonly string[]).includes(key));
    if (unknown.length > 0) {
      throw new UsageError(`unknown_field: ${unknown.join(', ')} on line ${index + 1}. A line reads: ${LINE_FIELDS.join(', ')}.`);
    }
    return line as Record<string, unknown>;
  });
}

/** Drops what was not given, so the core sees an absent field and not an undefined one. */
export function given<T extends Record<string, unknown>>(fields: T): T {
  return Object.fromEntries(Object.entries(fields).filter(([, value]) => value !== undefined)) as T;
}
