/**
 * The books read back: trial balance, general ledger, journal book, aged
 * balance and subsidiary ledger.
 *
 * Each is one function of the schema — `trial_balance()`, `general_ledger()`,
 * `journal_book()` with `journal_totals()`, `aged_balance()`, `subledger()` —
 * and what is
 * here is what both surfaces need around it: an account or a journal named by
 * its code, the amounts as the decimal strings the ledger holds, the period
 * said back. They lived in the MCP server until the command line printed the
 * same reports, as `ekwo balance`, `ekwo ledger`, `ekwo journal` and
 * `ekwo aged`.
 */

import { BooksError, backendSupports, schemaTooOldFor, type Backend, type Row, type SocleBackend } from './backend.js';
import { addDecimals, money, moneyFields } from './format.js';

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
  /**
   * The lines of these contacts only, each with its own balance carried
   * forward and running balance on the account: the detail of a row of
   * `subledger()`. Needs schema 0.26.0 (`ledger_by_contact`).
   */
  contact_ids?: string[] | undefined;
}

/**
 * The ids of the accounts a report is asked for: those given, and the one
 * named by its code. Null when neither is given — every account.
 */
async function accountIdsOf(
  backend: Backend,
  args: { company_id: string; account_code?: string | undefined; account_ids?: string[] | undefined },
): Promise<string[] | null> {
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
  return ids;
}

/**
 * Every posted line of an account over the period, with the balance carried
 * forward from before it and a running balance — or, with `contact_ids`, the
 * lines of those contacts, each running its own balance.
 */
export async function generalLedger(backend: Backend, args: GeneralLedgerArgs): Promise<unknown> {
  const ids = await accountIdsOf(backend, args);
  const contacts = args.contact_ids;
  // Named only when asked: a call without it reaches a schema before
  // `20261107100000` too, and one with it is refused there by name.
  if (contacts !== undefined && !(await backendSupports(backend, 'ledger_by_contact'))) {
    const installed = (await (backend as SocleBackend).schemaVersion()) ?? 'an older version';
    throw schemaTooOldFor('ledger_by_contact', installed, 'general_ledger() by contact');
  }

  const rows = await backend.rpc<Row>('general_ledger', {
    p_company_id: args.company_id,
    p_from: args.from,
    p_to: args.to,
    p_account_ids: ids,
    ...(contacts === undefined ? {} : { p_contact_ids: contacts }),
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

export interface SubledgerArgs extends PeriodArgs {
  /** One account, by its code. */
  account_code?: string | undefined;
  /** Accounts by id. Neither: every receivable and payable account. */
  account_ids?: string[] | undefined;
}

const SUBLEDGER_AMOUNTS = ['opening_balance', 'debit', 'credit', 'closing_balance'] as const;
type SubledgerAmounts = Record<(typeof SUBLEDGER_AMOUNTS)[number], string>;

/** The four amounts of some rows, added exactly; zeros when there is none. */
function totalOf(rows: Row[]): SubledgerAmounts {
  return Object.fromEntries(
    SUBLEDGER_AMOUNTS.map((key) => [key, addDecimals(['0', ...rows.map((row) => String(money(row[key]) ?? '0'))])]),
  ) as SubledgerAmounts;
}

function minus(value: string): string {
  return value.startsWith('-') ? value.slice(1) : `-${value}`;
}

function isZero(value: string): boolean {
  return /^-?0*(\.0*)?$/.test(value);
}

/**
 * The subsidiary ledger of the control accounts, from `subledger()`: per
 * account and contact, the balance brought forward before `from`, the debit
 * and the credit of the period, the closing balance, the lines of the period
 * and the lines still open; the lines naming nobody in a row of their own,
 * `contact_id` null.
 *
 * Beside the rows, the control of each account: its figures in the trial
 * balance, the sum of its named contacts, and the difference, which is what
 * the lines naming nobody amount to. `ties_out` says the row of those lines
 * is that difference, to the cent — it is, unless the ledger moved between
 * the two reads. Amounts are decimal strings in the company currency, debit
 * minus credit.
 */
export async function subledger(backend: Backend, args: SubledgerArgs): Promise<unknown> {
  const ids = await accountIdsOf(backend, args);
  const rows = await backend.rpc<Row>('subledger', {
    p_company_id: args.company_id,
    p_from: args.from,
    p_to: args.to,
    p_account_ids: ids,
  });
  const trial = await backend.rpc<Row>('trial_balance', {
    p_company_id: args.company_id,
    p_from: args.from,
    p_to: args.to,
  });

  // The accounts controlled: those of a row, and those asked for by name
  // even when nothing moved on them.
  const accounts = new Set<string>([...rows.map((row) => String(row['account_id'])), ...(ids ?? [])]);
  const control = trial
    .filter((account) => accounts.has(String(account['account_id'])))
    .map((account) => {
      const id = String(account['account_id']);
      const mine = rows.filter((row) => String(row['account_id']) === id);
      const named = totalOf(mine.filter((row) => row['contact_id'] !== null && row['contact_id'] !== undefined));
      const nobody = totalOf(mine.filter((row) => row['contact_id'] === null || row['contact_id'] === undefined));
      const ledger = totalOf([account]);
      const naming_nobody = Object.fromEntries(
        SUBLEDGER_AMOUNTS.map((key) => [key, addDecimals([ledger[key], minus(named[key])])]),
      ) as SubledgerAmounts;
      return {
        account_id: id,
        account_code: account['account_code'],
        account_name: account['account_name'],
        control_account: ledger,
        contacts: named,
        lines_naming_nobody: naming_nobody,
        ties_out: SUBLEDGER_AMOUNTS.every((key) => isZero(addDecimals([naming_nobody[key], minus(nobody[key])]))),
      };
    });

  return {
    period: { from: args.from, to: args.to },
    rows: moneyFields(rows, [...SUBLEDGER_AMOUNTS]),
    control,
    count: rows.length,
  };
}
