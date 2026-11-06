/**
 * `ekwo close` and `ekwo reopen` — a month and a financial year, closed and
 * opened again from a terminal: `lockPeriod()`, `closeFiscalYear()`,
 * `closeFiscalYearFinally()` and `reopenFiscalYear()` of the core, which are
 * the MCP server's `lock_period`, `close_fiscal_year`,
 * `close_fiscal_year_finally` and `reopen_fiscal_year`.
 *
 * A month is closed by moving the lock date of the company to its last day:
 * the triggers on the ledger then refuse anything dated on or before it. A
 * year is closed by `close_fiscal_year()`, which takes the result out of the
 * income statement the way the country pack says. Which entries are written,
 * and when a year may be closed, is the database's to say; a refusal is
 * printed word for word.
 *
 * Every verb here changes what may be booked, so each one asks first. In a
 * terminal it shows what it is about to do and waits for a yes; anywhere else
 * — a script, an agent, `--json` — it refuses unless `--yes` was typed, so
 * that nothing closes the books by ricochet.
 */

import { closeFiscalYear, closeFiscalYearFinally, getCompany, lockPeriod, reopenFiscalYear } from '@ekwo-ai/core';
import { UsageError, boolFlag, rejectUnknownFlags, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, openBooks, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { confirm, isInteractive } from '../prompt.js';
import { dim, heading, line, note, pairs, skipped, step, warn } from '../ui.js';

type Row = Record<string, unknown>;

const CONFIRM_FLAGS = [...BOOKS_FLAGS, 'yes'] as const;
const YEAR_FLAGS = [...BOOKS_FLAGS, 'yes', 'final'] as const;

const CLOSE_USAGE = 'usage: ekwo close month <YYYY-MM> [--yes] | ekwo close year <name|id> [--final] [--yes]';
const REOPEN_USAGE = 'usage: ekwo reopen month <YYYY-MM> [--yes] | ekwo reopen year <name|id> [--yes]';

const text = (value: unknown): string => (value === null || value === undefined ? '—' : String(value));

interface CompanyState {
  locks: { lock_date: string | null; tax_lock_date: string | null };
  fiscal_years: Row[];
}

/**
 * The last day of a month and the last day of the one before, as the
 * calendar has them. A month is written YYYY-MM; anything else is refused.
 */
export function monthBounds(month: string | undefined, usage: string): { month: string; lastDay: string; dayBefore: string } {
  if (month === undefined || !/^\d{4}-(0[1-9]|1[0-2])$/.test(month)) {
    throw new UsageError(`bad_month: a month is written YYYY-MM${month === undefined ? '' : `, got "${month}"`}. ${usage}`);
  }
  const first = new Date(`${month}-01T00:00:00Z`);
  const last = new Date(first);
  last.setUTCMonth(first.getUTCMonth() + 1, 0);
  const before = new Date(first);
  before.setUTCDate(0);
  const iso = (d: Date): string => d.toISOString().slice(0, 10);
  return { month, lastDay: iso(last), dayBefore: iso(before) };
}

/** The year the caller named, by its id or by its name in this company. */
function fiscalYear(years: Row[], asked: string | undefined, usage: string): Row {
  if (asked === undefined) throw new UsageError(`missing_argument: which financial year was not given. ${usage}`);
  const wanted = asked.toLowerCase();
  const year = years.find((y) => text(y['id']).toLowerCase() === wanted || text(y['name']).toLowerCase() === wanted);
  if (year === undefined) {
    const names = years.map((y) => text(y['name']));
    throw new UsageError(
      `no_fiscal_year: no financial year of this company is called "${asked}". ${names.length === 0 ? 'It has none yet.' : `It has: ${names.join(', ')}.`} ekwo company show lists them with their dates.`,
    );
  }
  return year;
}

/**
 * Yes when `--yes` was typed, or when the person at the terminal says so.
 * Nowhere to ask is a refusal, never a yes.
 */
async function confirmed(args: ParsedArgs, question: string): Promise<boolean> {
  if (boolFlag(args, 'yes')) return true;
  if (!isInteractive()) {
    throw new UsageError(
      'confirmation_required: this changes what may be booked, and there is no terminal to ask in. Pass --yes once the person who keeps these books has said so.',
    );
  }
  return await confirm(question, false);
}

function declined(): number {
  skipped('nothing changed');
  line();
  return 0;
}

export async function closeCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  const [action, target, ...rest] = args.positional;
  if (rest.length > 0) throw new UsageError(`too_many_arguments: ${rest.join(' ')}. ${CLOSE_USAGE}`);
  if (action === 'month') return await closeMonth(target, args, deps);
  if (action === 'year') return await closeYear(target, args, deps);
  throw new UsageError(action === undefined ? CLOSE_USAGE : `unknown_action: close ${action}. ${CLOSE_USAGE}`);
}

export async function reopenCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  const [action, target, ...rest] = args.positional;
  if (rest.length > 0) throw new UsageError(`too_many_arguments: ${rest.join(' ')}. ${REOPEN_USAGE}`);
  if (action === 'month') return await reopenMonth(target, args, deps);
  if (action === 'year') return await reopenYear(target, args, deps);
  throw new UsageError(action === undefined ? REOPEN_USAGE : `unknown_action: reopen ${action}. ${REOPEN_USAGE}`);
}

async function closeMonth(month: string | undefined, args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, CONFIRM_FLAGS);
  const { lastDay } = monthBounds(month, CLOSE_USAGE);
  const { backend, company } = await openBooks(args, deps);
  const state = (await getCompany(backend, { company_id: company.id })) as CompanyState;
  const previous = state.locks.lock_date;

  // A close moves the lock forward only. Moving it back is a reopening, and
  // is asked for as one.
  if (previous !== null && previous >= lastDay) {
    throw new UsageError(
      `already_closed: ${company.name} is locked up to ${previous}, which already covers ${month}. ekwo reopen month <YYYY-MM> opens a month again.`,
    );
  }

  heading(`Close ${month} for ${company.name}`);
  pairs([
    ['lock date now', text(previous)],
    ['lock date after', lastDay],
  ]);
  note(dim(`Nothing dated on or before ${lastDay} can then be booked, changed or cancelled, by anybody.`));
  if (!(await confirmed(args, `Close ${month}?`))) return declined();

  const result = (await lockPeriod(backend, { company_id: company.id, lock_date: lastDay })) as { company: Row; note: string };
  setResult({ ...result, previous_lock_date: previous });
  step(`${month} is closed: ${company.name} is locked up to ${text(result.company['lock_date'])}`);
  note(dim('ekwo reopen month <YYYY-MM> opens it again, for an owner of the company.'));
  line();
  return 0;
}

async function reopenMonth(month: string | undefined, args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, CONFIRM_FLAGS);
  const { dayBefore } = monthBounds(month, REOPEN_USAGE);
  const { backend, company } = await openBooks(args, deps);
  const state = (await getCompany(backend, { company_id: company.id })) as CompanyState;
  const previous = state.locks.lock_date;

  if (previous === null || previous <= dayBefore) {
    throw new UsageError(
      `not_closed: ${month} is not locked — ${company.name} is ${previous === null ? 'not locked at all' : `locked up to ${previous}`}. Nothing to reopen.`,
    );
  }

  heading(`Reopen ${month} for ${company.name}`);
  pairs([
    ['lock date now', previous],
    ['lock date after', dayBefore],
  ]);
  note(dim(`Everything dated from ${month}-01 to ${previous} can be booked and changed again.`));
  if (!(await confirmed(args, `Reopen ${month} and every month after it?`))) return declined();

  const result = (await lockPeriod(backend, { company_id: company.id, lock_date: dayBefore })) as { company: Row; note: string };
  setResult({ ...result, previous_lock_date: previous });
  step(`${month} is open again: ${company.name} is locked up to ${text(result.company['lock_date'])}`);
  line();
  return 0;
}

async function closeYear(asked: string | undefined, args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, YEAR_FLAGS);
  const final = boolFlag(args, 'final');
  const { backend, company } = await openBooks(args, deps);
  const state = (await getCompany(backend, { company_id: company.id })) as CompanyState;
  const year = fiscalYear(state.fiscal_years, asked, CLOSE_USAGE);
  const id = text(year['id']);
  const name = text(year['name']);

  heading(`${final ? 'Close for good' : 'Close'} the financial year ${name} of ${company.name}`);
  pairs([
    ['from', text(year['start_date'])],
    ['to', text(year['end_date'])],
    ['state', year['is_closed'] === true ? 'closed' : 'open'],
  ]);
  if (final) {
    warn('A final close cannot be undone: nobody can reopen the year or change it afterwards, and a correction is booked in a later year.');
  } else {
    note(dim('The result leaves the income statement the way the country pack says, and the year refuses new entries. ekwo reopen year undoes it.'));
  }
  if (!(await confirmed(args, final ? `Close ${name} for good?` : `Close ${name}?`))) return declined();

  if (final) {
    const result = (await closeFiscalYearFinally(backend, { fiscal_year_id: id })) as Row;
    setResult(result);
    step(`${name} is closed for good`);
    line();
    return 0;
  }

  const result = (await closeFiscalYear(backend, { fiscal_year_id: id })) as { close: Row; final_close: Row };
  setResult(result);
  step(`${name} is closed`);
  // The result as the database wrote it, and the way the country pack carried it.
  pairs([
    ['result', text(result.close['result'])],
    ['result kind', text(result.close['result_kind'])],
    ['closing style', text(result.close['closing_style'])],
  ]);
  const finalClose = result.final_close;
  if (finalClose['required'] === true) {
    const by = finalClose['due_date'] ? ` by ${text(finalClose['due_date'])}` : '';
    const under = finalClose['legal_reference'] ? ` (${text(finalClose['legal_reference'])})` : '';
    warn(`The country also requires a final close of ${name}${by}${under}. ekwo close year ${name} --final does it, when you decide to.`);
  }
  note(dim('What a general meeting decides to do with the result is a later entry; the close never writes it.'));
  line();
  return 0;
}

async function reopenYear(asked: string | undefined, args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, CONFIRM_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const state = (await getCompany(backend, { company_id: company.id })) as CompanyState;
  const year = fiscalYear(state.fiscal_years, asked, REOPEN_USAGE);
  const name = text(year['name']);

  heading(`Reopen the financial year ${name} of ${company.name}`);
  pairs([
    ['from', text(year['start_date'])],
    ['to', text(year['end_date'])],
  ]);
  note(dim('The entries the close wrote are reversed, never deleted, and the year accepts entries again.'));
  if (!(await confirmed(args, `Reopen ${name}?`))) return declined();

  const result = (await reopenFiscalYear(backend, { fiscal_year_id: text(year['id']) })) as Row;
  setResult(result);
  step(`${name} is open again`);
  line();
  return 0;
}
