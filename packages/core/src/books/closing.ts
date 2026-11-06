/**
 * Closing the books: the lock dates of a company, and the close of a
 * financial year — ordinary, undone, or final.
 *
 * Each is one write the schema checks. A lock date is a column of the
 * company, and the triggers on the ledger refuse anything dated on or before
 * it; the close of a year is `close_fiscal_year()`, which decides the account
 * the result travels through and which entries are written, from the country
 * pack. Nothing of a rule is here. They lived in the MCP server until the
 * command line closed the same months and years, as `ekwo close` and
 * `ekwo reopen`.
 */

import { BooksError, type Backend, type Row } from './backend.js';
import { only } from './shared.js';

export interface LockPeriodArgs {
  company_id: string;
  /** Nothing may be booked on or before it. `null` lifts the lock; left out, unchanged. */
  lock_date?: string | null | undefined;
  /** Additionally freezes anything carrying a VAT box. `null` lifts it; left out, unchanged. */
  tax_lock_date?: string | null | undefined;
}

/** Moves the lock date, the VAT lock date, or both. Only an owner of the company may. */
export async function lockPeriod(backend: Backend, args: LockPeriodArgs): Promise<unknown> {
  const patch: Row = {};
  if (args.lock_date !== undefined) patch['lock_date'] = args.lock_date;
  if (args.tax_lock_date !== undefined) patch['tax_lock_date'] = args.tax_lock_date;
  if (Object.keys(patch).length === 0) {
    throw new BooksError('nothing_to_lock: give lock_date, tax_lock_date, or both.');
  }

  const rows = await backend.update<Row>(
    'companies',
    patch,
    [{ column: 'id', op: 'eq', value: args.company_id }],
    ['id', 'name', 'lock_date::text', 'tax_lock_date::text'],
  );
  const company = rows[0];
  if (company === undefined) {
    throw new BooksError('not_owner: only an owner of the company may move its lock dates, and nothing was changed.');
  }
  return {
    company,
    note: 'Locking is enforced by triggers on the ledger, not by this server. Everything on or before the date now refuses to move.',
  };
}

export interface FiscalYearArgs {
  fiscal_year_id: string;
}

/**
 * Closes a year: `close_fiscal_year()`, then what the country asks next —
 * a final close, by when and under which article, or nothing — from
 * `fiscal_year_final_close()`. The pack says it; this only passes it on.
 */
export async function closeFiscalYear(backend: Backend, args: FiscalYearArgs): Promise<unknown> {
  const answer = await backend.rpc<Row>('close_fiscal_year', { p_fiscal_year_id: args.fiscal_year_id });
  const finalClose = await backend.rpc<Row>('fiscal_year_final_close', { p_fiscal_year_id: args.fiscal_year_id });
  return {
    close: only(answer, `fiscal year ${args.fiscal_year_id}`),
    final_close: only(finalClose, `fiscal year ${args.fiscal_year_id}`),
    note: 'The income statement is back at zero and the year refuses new entries. It can still be reopened with reopen_fiscal_year. What a general meeting decides to do with the result — a dividend, a reserve — is a later entry, and the close never writes it. Where final_close.required is true, the country requires a final close by final_close.due_date: tell the user, and call close_fiscal_year_finally only when they ask for it.',
  };
}

/** Undoes an ordinary close: `reopen_fiscal_year()`. */
export async function reopenFiscalYear(backend: Backend, args: FiscalYearArgs): Promise<unknown> {
  const answer = await backend.rpc<Row>('reopen_fiscal_year', { p_fiscal_year_id: args.fiscal_year_id });
  return {
    reopen: only(answer, `fiscal year ${args.fiscal_year_id}`),
    note: 'The entries the close wrote are reversed, not deleted, and the year accepts entries again. Entries of later years are untouched: they read this year from the ledger, so a new close carries the corrected result to them by itself.',
  };
}

/** The final close of a closed year: `close_fiscal_year_finally()`. Irreversible. */
export async function closeFiscalYearFinally(backend: Backend, args: FiscalYearArgs): Promise<unknown> {
  const answer = await backend.rpc<Row>('close_fiscal_year_finally', { p_fiscal_year_id: args.fiscal_year_id });
  return {
    final_close: only(answer, `fiscal year ${args.fiscal_year_id}`),
    note: 'The year is closed for good: reopen_fiscal_year refuses it for everybody, and nothing about it changes any more. A correction is booked in an open year.',
  };
}
