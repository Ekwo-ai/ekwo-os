/**
 * The books read back: trial balance, general ledger, journal book and aged
 * balance.
 *
 * Each is one function of the schema — `trial_balance()`, `general_ledger()`,
 * `journal_book()` with `journal_totals()`, `aged_balance()` — and what is
 * here is what both surfaces need around it: an account or a journal named by
 * its code, the amounts as the decimal strings the ledger holds, the period
 * said back. They lived in the MCP server until the command line printed the
 * same reports, as `ekwo balance`, `ekwo ledger`, `ekwo journal` and
 * `ekwo aged`.
 */

import { BooksError, type Backend, type Row } from './backend.js';
import { moneyFields } from './format.js';

export interface PeriodArgs {
  company_id: string;
  /** First day of the period, YYYY-MM-DD. */
  from: string;
  /** Last day of the period, YYYY-MM-DD. */
  to: string;
}

export type TrialBalanceArgs = PeriodArgs;

/**
 * Opening balance, movements and closing balance of every account over the
 * period, from posted entries only, and the debit and credit totals.
 */
export async function trialBalance(backend: Backend, args: TrialBalanceArgs): Promise<unknown> {
  const rows = await backend.rpc<Row>('trial_balance', {
    p_company_id: args.company_id,
    p_from: args.from,
    p_to: args.to,
  });
  const accounts = moneyFields(rows, ['opening_balance', 'debit', 'credit', 'closing_balance']);
  const total = (key: string): string =>
    accounts.reduce((sum, row) => sum + Number(row[key] ?? 0), 0).toFixed(2);

  return {
    period: { from: args.from, to: args.to },
    accounts,
    totals: { debit: total('debit'), credit: total('credit') },
  };
}

export interface GeneralLedgerArgs extends PeriodArgs {
  /** One account, by its code. */
  account_code?: string | undefined;
  /** Accounts by id. Neither: every account. */
  account_ids?: string[] | undefined;
}

/**
 * Every posted line of an account over the period, with the balance carried
 * forward from before it and a running balance.
 */
export async function generalLedger(backend: Backend, args: GeneralLedgerArgs): Promise<unknown> {
  let ids = args.account_ids ?? null;
  if (args.account_code !== undefined) {
    const accounts = await backend.select<{ id: string }>({
      table: 'accounts',
      columns: ['id'],
      where: [
        { column: 'company_id', op: 'eq', value: args.company_id },
        { column: 'code', op: 'eq', value: args.account_code },
      ],
    });
    ids = [...(ids ?? []), ...accounts.map((account) => account.id)];
    if (ids.length === 0) {
      throw new BooksError(`not_found: no account ${args.account_code} in this company.`);
    }
  }

  const rows = await backend.rpc<Row>('general_ledger', {
    p_company_id: args.company_id,
    p_from: args.from,
    p_to: args.to,
    p_account_ids: ids,
  });

  return {
    period: { from: args.from, to: args.to },
    lines: moneyFields(rows, ['debit', 'credit', 'running_balance']),
    count: rows.length,
  };
}

export interface JournalBookArgs extends PeriodArgs {
  /** One journal, by its code. */
  journal_code?: string | undefined;
  /** Journals by id. Neither: every journal. */
  journal_ids?: string[] | undefined;
}

/**
 * The book of a journal — every line of every posted entry of the period, in
 * the order a book is read — and the head of each journal, the totals the
 * database adds up (`journal_totals()`).
 */
export async function journalBook(backend: Backend, args: JournalBookArgs): Promise<unknown> {
  let ids = args.journal_ids ?? null;
  if (args.journal_code !== undefined) {
    const journals = await backend.select<{ id: string }>({
      table: 'journals',
      columns: ['id'],
      where: [
        { column: 'company_id', op: 'eq', value: args.company_id },
        { column: 'code', op: 'eq', value: args.journal_code },
      ],
    });
    ids = [...(ids ?? []), ...journals.map((journal) => journal.id)];
    if (ids.length === 0) {
      throw new BooksError(`not_found: no journal ${args.journal_code} in this company.`);
    }
  }

  const totals = await backend.rpc<Row>('journal_totals', {
    p_company_id: args.company_id,
    p_from: args.from,
    p_to: args.to,
  });
  const lines = await backend.rpc<Row>('journal_book', {
    p_company_id: args.company_id,
    p_from: args.from,
    p_to: args.to,
    p_journal_ids: ids,
  });
  const asked = ids === null ? null : new Set(ids);

  return {
    period: { from: args.from, to: args.to },
    journals: moneyFields(
      totals.filter((row) => asked === null || asked.has(String(row['journal_id']))),
      ['debit', 'credit'],
    ),
    lines: moneyFields(lines, ['debit', 'credit']),
    count: lines.length,
  };
}

export interface AgedBalanceArgs {
  company_id: string;
  /** The day to age at, YYYY-MM-DD. Defaults to today. */
  at?: string | undefined;
  group?: 'receivable' | 'payable' | undefined;
}

/**
 * What is still open on the receivable (or payable) accounts, by contact,
 * bucketed by how overdue it is — read from unmatched ledger lines, so it
 * ties back to the balance sheet.
 */
export async function agedBalance(backend: Backend, args: AgedBalanceArgs): Promise<unknown> {
  const at = args.at ?? new Date().toISOString().slice(0, 10);
  const group = args.group ?? 'receivable';
  const rows = await backend.rpc<Row>('aged_balance', {
    p_company_id: args.company_id,
    p_at: at,
    p_group: group,
  });
  return {
    at,
    group,
    rows: moneyFields(rows, ['not_due', 'days_1_30', 'days_31_60', 'days_61_90', 'days_over_90', 'total']),
  };
}
