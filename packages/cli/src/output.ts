/**
 * The output contract: what a command answers, and with which exit code.
 *
 * Every command of this CLI is run through `execute()`, so the contract is
 * written once and a command cannot opt out of it by forgetting.
 *
 *   0  done.
 *   1  it did not end well and the books were not asked: the network, a
 *      database that does not answer, a bug — and a check that found
 *      something (`doctor`, `pack check`, a pending migration), which is how
 *      a CI job goes red.
 *   2  the command was called wrong: an unknown option, a missing argument,
 *      a question that needed an answer and no terminal to ask it on.
 *   3  the database refused. A locked period, a capability the caller does
 *      not hold, a tax that does not apply here. The command was well formed
 *      and everything worked; the accounting said no.
 *
 * A caller — an agent with a shell, a Makefile — has to tell 2 from 3 without
 * reading a sentence, and that is the reason 3 exists.
 *
 * The refusal itself is printed as the database wrote it. Its name
 * (`period_locked`) is the part a program matches on and its sentence is the
 * part a person reads; neither is rephrased here, and nothing in this file
 * knows what any of the names mean. Which SQLSTATEs count as a refusal and
 * how a name is read out of a message are in `@ekwo-ai/core`, where the MCP
 * server reads them too.
 */

import { BooksError, isRefusalState, socleCode } from '@ekwo-ai/core';
import { UsageError, type ParsedArgs } from './args.js';
import { NotInteractiveError } from './prompt.js';
import { collectedWarnings, dim, emit, fail, isJsonMode, line, setJsonMode } from './ui.js';

export const EXIT_OK = 0;
export const EXIT_ERROR = 1;
export const EXIT_USAGE = 2;
export const EXIT_REFUSED = 3;

export type ErrorKind = 'refusal' | 'usage' | 'technical';

export interface OutputError {
  kind: ErrorKind;
  /** `period_locked`, when the message carries a name. Never invented. */
  name?: string;
  /** What was said, word for word. */
  message: string;
  /** What Postgres called it, when the error came from the database. */
  sqlstate?: string;
  /** The DETAIL and HINT of the raise, when the database gave them. */
  detail?: string;
  hint?: string;
}

/** The one JSON document a command writes under `--json`. */
export interface OutputDocument {
  ok: boolean;
  command: string;
  exitCode: number;
  /** What the command has to say. Absent when it failed before having any. */
  data?: unknown;
  /**
   * On whose behalf, where, and for which company the answer was rendered.
   * Present on every command that acts as a person; absent on the commands
   * that install and operate, which act as nobody.
   */
  context?: OutputContext;
  /** Every warning the command printed, without the colours. */
  warnings: string[];
  error?: OutputError;
}

/**
 * What a caller checks before it believes the rest.
 *
 * An agent that keeps the books of two companies and answers for the wrong
 * one has made the one mistake no total will reveal. So the company is in the
 * document itself — `null` when none is in use — on success and on a refusal
 * alike, as soon as it is known.
 */
export interface OutputContext {
  /** `null` when the environment said who, and no profile was read. */
  profile: string | null;
  instance: string;
  company: { id: string; name: string } | null;
}

let result: unknown;
let context: OutputContext | undefined;

/** Called by a command that acts as a person, as soon as it knows for which company. */
export function setContext(value: OutputContext): void {
  context = value;
}

/**
 * What the command answers under `--json`.
 *
 * Called by the command with the same values it prints, never with values of
 * its own: a figure that exists in one of the two forms only is a bug.
 */
export function setResult(data: unknown): void {
  result = data;
}

const TWO_WORDS = new Set(['module', 'pack', 'company', 'contact', 'invoice', 'payment', 'doc']);

/** `module list`, `pack upgrade`, `status`: the words that named the command. */
export function commandLabel(args: ParsedArgs): string {
  if (args.command === undefined && args.flags.get('version') === true) return 'version';
  const command = args.command ?? 'help';
  const takesAction = TWO_WORDS.has(command);
  const action = takesAction ? args.positional[0] : undefined;
  if (action === undefined) return command;
  // `invoice line add`: the one verb of three words.
  if (command === 'invoice' && action === 'line' && args.positional[1] !== undefined) {
    return `invoice line ${args.positional[1]}`;
  }
  return `${command} ${action}`;
}

function field(error: unknown, name: string): string | undefined {
  if (typeof error !== 'object' || error === null) return undefined;
  const value = (error as Record<string, unknown>)[name];
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}

/** Which of the three an error is, and with it the exit code. */
export function classify(error: unknown): { exitCode: number; error: OutputError } {
  const message = error instanceof Error ? error.message : String(error);
  const name = socleCode(message);
  const named = name === undefined ? {} : { name };

  // An error of the core's bookkeeping layer was raised before the database
  // was asked, or about something it did not return: an unknown account code,
  // a document that is not a draft. The call has to change; the books did not
  // refuse, so it is not 3.
  if (error instanceof UsageError || error instanceof NotInteractiveError || error instanceof BooksError) {
    return { exitCode: EXIT_USAGE, error: { kind: 'usage', ...named, message } };
  }

  // Both drivers this CLI meets — `postgres` on a real project, PGlite in the
  // tests — put the SQLSTATE in `code`. A Node network error has a `code` too
  // (`ECONNREFUSED`), which is not five characters of the SQL alphabet.
  const code = field(error, 'code');
  const sqlstate = code !== undefined && /^[0-9A-Z]{5}$/.test(code) ? code : undefined;
  const detail = field(error, 'detail');
  const hint = field(error, 'hint');
  const fromDatabase = {
    ...(sqlstate === undefined ? {} : { sqlstate }),
    ...(detail === undefined ? {} : { detail }),
    ...(hint === undefined ? {} : { hint }),
  };

  if (isRefusalState(sqlstate)) {
    return { exitCode: EXIT_REFUSED, error: { kind: 'refusal', ...named, message, ...fromDatabase } };
  }
  return { exitCode: EXIT_ERROR, error: { kind: 'technical', ...named, message, ...fromDatabase } };
}

/** `--json` as it was typed, for the errors that happen before flags are read. */
export function askedForJson(argv: readonly string[]): boolean {
  for (const token of argv) {
    if (token === '--') return false;
    if (token === '--json' || token === '--json=true' || token === '--json=yes') return true;
  }
  return false;
}

function printError(error: OutputError): void {
  fail(error.message);
  if (error.detail !== undefined) line(`  ${dim(error.detail)}`);
  if (error.hint !== undefined) line(`  ${dim(error.hint)}`);
}

/** An error met before any command ran: a bad option, an unknown command. */
export function reportFailure(command: string, json: boolean, error: unknown): number {
  setJsonMode(json);
  const outcome = classify(error);
  printError(outcome.error);
  if (json) {
    emit({
      ok: false,
      command,
      exitCode: outcome.exitCode,
      warnings: collectedWarnings(),
      error: outcome.error,
    } satisfies OutputDocument);
  }
  return outcome.exitCode;
}

/**
 * Runs one command under the contract.
 *
 * The handler prints for a person as it goes and hands `setResult()` what a
 * program should read. Here the two are kept apart: under `--json` the prose
 * has already gone to the standard error, and the standard output receives
 * exactly one document — on success, on a finding, and on a refusal alike, so
 * a caller parses the same shape whatever happened.
 */
export async function execute(
  args: ParsedArgs,
  json: boolean,
  handler: () => Promise<number>,
): Promise<number> {
  const command = commandLabel(args);
  setJsonMode(json);
  result = undefined;
  context = undefined;

  let exitCode: number;
  let error: OutputError | undefined;
  try {
    exitCode = await handler();
  } catch (thrown) {
    const outcome = classify(thrown);
    exitCode = outcome.exitCode;
    error = outcome.error;
    printError(error);
  }

  if (isJsonMode()) {
    emit({
      ok: exitCode === EXIT_OK,
      command,
      exitCode,
      ...(result === undefined ? {} : { data: result }),
      ...(context === undefined ? {} : { context }),
      warnings: collectedWarnings(),
      ...(error === undefined ? {} : { error }),
    } satisfies OutputDocument);
  }
  return exitCode;
}
