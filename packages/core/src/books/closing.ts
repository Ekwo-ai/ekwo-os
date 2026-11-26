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
    note: 'What was still open in a foreign currency is stated at the closing rate on the last day and back at its own rate the next (revaluation_entry_id, revaluation_reversal_entry_id, unrealised_exchange_difference). The income statement is back at zero and the year refuses new entries. It can still be reopened with reopen_fiscal_year. What a general meeting decides to do with the result — a dividend, a reserve — is a later entry, and the close never writes it. Where final_close.required is true, the country requires a final close by final_close.due_date: tell the user, and call close_fiscal_year_finally only when they ask for it.',
  };
}

export interface ClosingRateArgs {
  company_id: string;
  /** ISO 4217 code of the currency, other than the company's. */
  currency_code: string;
  /** The day the rate is the closing rate of: the last day of a year, for its close. */
  rate_date: string;
  /** Units of that currency for one unit of the company's, as a decimal string. */
  rate: string | number;
  /** Where the rate comes from — a central bank, a published series. */
  source?: string | null | undefined;
}

const CLOSING_RATE_COLUMNS = ['id', 'currency_code', 'rate_date::text', 'rate::text', 'source'];

/**
 * Records the rate a company closes a currency at on a day: its own row of
 * `currency_rates`, the one that names the company, in units of the currency
 * for one unit of the company's. The same currency and day again replaces
 * the rate; the instance-wide rows, with no company, are never touched. Whoever
 * may close a year may set it (`year_end.close`), and the table's policies
 * say so, not this function.
 */
export async function setClosingRate(backend: Backend, args: ClosingRateArgs): Promise<unknown> {
  const where = [
    { column: 'company_id', op: 'eq' as const, value: args.company_id },
    { column: 'currency_code', op: 'eq' as const, value: args.currency_code.toUpperCase() },
    { column: 'rate_date', op: 'eq' as const, value: args.rate_date },
  ];
  const patch: Row = { rate: String(args.rate), source: args.source ?? null };
  const updated = await backend.update<Row>('currency_rates', patch, where, CLOSING_RATE_COLUMNS);
  const rate =
    updated[0] ??
    (
      await backend.insert<Row>(
        'currency_rates',
        [{ company_id: args.company_id, currency_code: args.currency_code.toUpperCase(), rate_date: args.rate_date, ...patch }],
        CLOSING_RATE_COLUMNS,
      )
    )[0];
  if (rate === undefined) {
    throw new BooksError('not_allowed: setting a closing rate in this company needs year_end.close, and nothing was written.');
  }
  return {
    closing_rate: rate,
    note: 'A close reads the rate of the last day of the year, that day exactly, for every currency still open; currency_revaluation shows what it would move.',
  };
}

export interface CurrencyRevaluationArgs {
  company_id: string;
  /** The closing day: the last day of the year to be closed. */
  at: string;
}

/**
 * What a close on `at` would revalue: `currency_revaluation()`, position by
 * account, counterparty and currency, and the currencies still open with no
 * closing rate for that day, which would refuse the close. Writes nothing.
 */
export async function currencyRevaluation(backend: Backend, args: CurrencyRevaluationArgs): Promise<unknown> {
  const positions = await backend.rpc<Row>('currency_revaluation', { p_company_id: args.company_id, p_at: args.at });
  const missing = [...new Set(positions.filter((p) => p['closing_rate'] === null).map((p) => String(p['currency_code'])))].sort();
  return {
    at: args.at,
    positions,
    missing_rates: missing,
    note:
      missing.length > 0
        ? `No closing rate on ${args.at} for ${missing.join(', ')}: close_fiscal_year refuses the year until one is set with set_closing_rate.`
        : 'close_fiscal_year books each difference on the last day of the year, on the accounts the country pack names, and reverses it the next day. A position is the open part of the receivables and payables in that currency, or the balance of a bank account kept in it.',
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
