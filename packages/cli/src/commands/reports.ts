/**
 * `ekwo balance`, `ekwo ledger`, `ekwo journal` and `ekwo aged` — the books
 * read back in a terminal: `trialBalance()`, `generalLedger()`,
 * `journalBook()` and `agedBalance()` of the core, which are the MCP server's
 * `trial_balance`, `general_ledger`, `journal_book` and `aged_balance`.
 *
 * Each is one function of the schema and reads posted entries only. Every
 * figure is the database's and is printed as it came: nothing is added up,
 * rounded or re-signed here (decision 0056).
 */

import { agedBalance, generalLedger, journalBook, trialBalance } from '@ekwo-ai/core';
import { UsageError, boolFlag, rejectUnknownFlags, stringFlag, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, openBooks, required, today, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, note, pairs, table } from '../ui.js';

type Row = Record<string, unknown>;

const PERIOD_FLAGS = [...BOOKS_FLAGS, 'from', 'to'] as const;
const AGED_FLAGS = [...BOOKS_FLAGS, 'at', 'payable', 'receivable'] as const;

const cell = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

/** `--from` is asked for; `--to` is today when it is not given, and the heading says so. */
function period(args: ParsedArgs, usage: string): { from: string; to: string; toToday: boolean } {
  const from = required(stringFlag(args, 'from'), 'the first day of the period', `--from <YYYY-MM-DD>. ${usage}`);
  const given = stringFlag(args, 'to');
  return { from, to: given ?? today(), toToday: given === undefined };
}

/** A second positional is a mistake worth naming, not an argument to drop. */
function atMostOne(args: ParsedArgs, usage: string): string | undefined {
  if (args.positional.length > 1) throw new UsageError(`too_many_arguments: ${args.positional.slice(1).join(' ')}. ${usage}`);
  return args.positional[0];
}

const BALANCE_USAGE = 'usage: ekwo balance --from <YYYY-MM-DD> [--to <YYYY-MM-DD>]';

export async function balanceCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  rejectUnknownFlags(args, PERIOD_FLAGS);
  if (args.positional.length > 0) throw new UsageError(`too_many_arguments: ${args.positional.join(' ')}. ${BALANCE_USAGE}`);
  const { from, to, toToday } = period(args, BALANCE_USAGE);
  const { backend, company } = await openBooks(args, deps);

  const result = (await trialBalance(backend, { company_id: company.id, from, to })) as {
    accounts: Row[];
    totals: { debit: string; credit: string };
  };
  setResult(result);

  heading(`Trial balance of ${company.name}, ${from} to ${to}`);
  if (toToday) note(dim(`to today, ${to}: no --to was given`));
  if (result.accounts.length === 0) note(dim('No account has a posted line or a balance in the period.'));
  else {
    table(
      [
        { title: 'account' }, { title: 'name' },
        { title: 'opening', align: 'right' }, { title: 'debit', align: 'right' },
        { title: 'credit', align: 'right' }, { title: 'closing', align: 'right' },
      ],
      result.accounts.map((a) => [
        cell(a['account_code']), cell(a['account_name']),
        cell(a['opening_balance']), cell(a['debit']), cell(a['credit']), cell(a['closing_balance']),
      ]),
    );
  }
  pairs([
    ['total debit', result.totals.debit],
    ['total credit', result.totals.credit],
  ]);
  note(dim('Posted entries only. Balances are debit minus credit, in the currency of the company.'));
  return 0;
}

const LEDGER_USAGE = 'usage: ekwo ledger [<account code>] --from <YYYY-MM-DD> [--to <YYYY-MM-DD>]';

export async function ledgerCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  rejectUnknownFlags(args, PERIOD_FLAGS);
  const account = atMostOne(args, LEDGER_USAGE);
  const { from, to, toToday } = period(args, LEDGER_USAGE);
  const { backend, company } = await openBooks(args, deps);

  const result = (await generalLedger(backend, {
    company_id: company.id,
    from,
    to,
    ...(account === undefined ? {} : { account_code: account }),
  })) as { lines: Row[]; count: number };
  setResult(result);

  heading(`General ledger of ${company.name}${account === undefined ? '' : `, account ${account}`}, ${from} to ${to}`);
  if (toToday) note(dim(`to today, ${to}: no --to was given`));
  if (result.lines.length === 0) note(dim('No posted line in the period.'));
  else {
    table(
      [
        { title: 'account' }, { title: 'date' }, { title: 'journal' }, { title: 'entry' },
        { title: 'label' }, { title: 'contact' },
        { title: 'debit', align: 'right' }, { title: 'credit', align: 'right' },
        { title: 'balance', align: 'right' }, { title: 'match' },
      ],
      result.lines.map((l) => [
        cell(l['account_code']), cell(l['entry_date']), cell(l['journal_code']), cell(l['entry_number']),
        cell(l['line_name']), cell(l['contact_name']),
        cell(l['debit']), cell(l['credit']), cell(l['running_balance']), cell(l['matching_number']),
      ]),
    );
  }
  note(dim('Posted lines only; the balance runs per account, from the one carried forward to the first day.'));
  return 0;
}

const JOURNAL_USAGE = 'usage: ekwo journal [<journal code>] --from <YYYY-MM-DD> [--to <YYYY-MM-DD>]';

export async function journalCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  rejectUnknownFlags(args, PERIOD_FLAGS);
  const journal = atMostOne(args, JOURNAL_USAGE);
  const { from, to, toToday } = period(args, JOURNAL_USAGE);
  const { backend, company } = await openBooks(args, deps);

  const result = (await journalBook(backend, {
    company_id: company.id,
    from,
    to,
    ...(journal === undefined ? {} : { journal_code: journal }),
  })) as { journals: Row[]; lines: Row[]; count: number };
  setResult(result);

  heading(`Journal book of ${company.name}${journal === undefined ? '' : `, journal ${journal}`}, ${from} to ${to}`);
  if (toToday) note(dim(`to today, ${to}: no --to was given`));
  table(
    [
      { title: 'journal' }, { title: 'name' }, { title: 'entries', align: 'right' }, { title: 'lines', align: 'right' },
      { title: 'debit', align: 'right' }, { title: 'credit', align: 'right' },
    ],
    result.journals.map((j) => [
      cell(j['journal_code']), cell(j['journal_name']), cell(j['entries']), cell(j['lines']), cell(j['debit']), cell(j['credit']),
    ]),
  );
  if (result.lines.length === 0) note(dim('No posted line in the period.'));
  else {
    table(
      [
        { title: 'date' }, { title: 'journal' }, { title: 'entry' }, { title: 'account' },
        { title: 'label' }, { title: 'contact' },
        { title: 'debit', align: 'right' }, { title: 'credit', align: 'right' },
      ],
      result.lines.map((l) => [
        cell(l['entry_date']), cell(l['journal_code']), cell(l['entry_number']), cell(l['account_code']),
        cell(l['line_name'] ?? l['description']), cell(l['contact_name']),
        cell(l['debit']), cell(l['credit']),
      ]),
    );
  }
  note(dim('Posted entries only, in the order a book is read: day, journal, entry, line.'));
  return 0;
}

const AGED_USAGE = 'usage: ekwo aged [--receivable | --payable] [--at <YYYY-MM-DD>]';

export async function agedCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  rejectUnknownFlags(args, AGED_FLAGS);
  if (args.positional.length > 0) throw new UsageError(`too_many_arguments: ${args.positional.join(' ')}. ${AGED_USAGE}`);
  const payable = boolFlag(args, 'payable');
  if (payable && boolFlag(args, 'receivable')) {
    throw new UsageError(`conflicting_flags: --receivable and --payable are two reports; ask for one. ${AGED_USAGE}`);
  }
  const group = payable ? 'payable' : 'receivable';
  const givenAt = stringFlag(args, 'at');
  const at = givenAt ?? today();
  const { backend, company } = await openBooks(args, deps);

  const result = (await agedBalance(backend, { company_id: company.id, at, group })) as { rows: Row[] };
  setResult(result);

  heading(`Aged ${group} of ${company.name} at ${at}`);
  if (givenAt === undefined) note(dim(`at today, ${at}: no --at was given`));
  if (result.rows.length === 0) note(dim(`Nothing ${group === 'payable' ? 'is owed to a supplier' : 'is owed by a customer'} at that day.`));
  else {
    table(
      [
        { title: 'contact' }, { title: 'account' },
        { title: 'not due', align: 'right' }, { title: '1-30', align: 'right' }, { title: '31-60', align: 'right' },
        { title: '61-90', align: 'right' }, { title: 'over 90', align: 'right' }, { title: 'total', align: 'right' },
      ],
      result.rows.map((r) => [
        cell(r['contact_name']), cell(r['account_code']),
        cell(r['not_due']), cell(r['days_1_30']), cell(r['days_31_60']),
        cell(r['days_61_90']), cell(r['days_over_90']), cell(r['total']),
      ]),
    );
  }
  note(dim('Unmatched posted lines, by days overdue: an invoice is settled once its payment is matched to it.'));
  return 0;
}
