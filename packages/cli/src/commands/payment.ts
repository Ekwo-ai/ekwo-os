/**
 * `ekwo payment record` and `ekwo match`.
 *
 * `recordPayment()` of the core is the MCP server's `record_payment`: it
 * inserts the payment, has `post_payment()` book it and `reconcile()` match
 * it. `settleFromStatement()` is `settle_from_statement()` of the schema: the
 * statement line is booked as the payment it is and matched to what is open
 * on the document — for the amount given with `--amount`, one per document,
 * and with the fees and charges it is net of as `--extra` lines in the same
 * entry. Which way the money goes, who it is from, how much is still owed and
 * whether the line balances are read from the ledger, never worked out here.
 */

import {
  recordPayment,
  resolveContact,
  resolveDocument,
  settleFromStatement,
  type RecordPaymentArgs,
  type SettlementExtraLine,
} from '@ekwo-ai/core';
import { UsageError, boolFlag, rejectUnknownFlags, stringFlag, stringFlags, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, CREATE_FLAGS, given, openBooks, required, stdinDocument, today, uuidArg, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, line, note, pairs, step } from '../ui.js';

type Row = Record<string, unknown>;

const RECORD_FLAGS = [
  ...CREATE_FLAGS, 'doc', 'contact', 'direction', 'amount', 'date', 'bank-account', 'journal', 'reference', 'memo', 'currency', 'rate', 'no-match',
] as const;
const RECORD_FIELDS = [
  'document_id', 'document', 'contact_id', 'contact', 'direction', 'amount', 'payment_date', 'bank_account_id', 'journal_id',
  'journal_code', 'reference', 'memo', 'currency_code', 'exchange_rate', 'match_open_items', 'client_ref',
] as const;

const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

export async function paymentCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  if (args.positional[0] !== 'record') {
    throw new UsageError('usage: ekwo payment record --doc <document> --amount <amount> [--date --bank-account <id> | --journal <code>] [--ref]');
  }
  rejectUnknownFlags(args, RECORD_FLAGS);
  const input = await stdinDocument(args, deps, RECORD_FIELDS);
  const { backend, company } = await openBooks(args, deps);

  const doc = stringFlag(args, 'doc') ?? (input['document_id'] as string | undefined) ?? (input['document'] as string | undefined);
  const who = stringFlag(args, 'contact') ?? (input['contact_id'] as string | undefined) ?? (input['contact'] as string | undefined);
  const direction = stringFlag(args, 'direction') ?? (input['direction'] as string | undefined);
  if (direction !== undefined && direction !== 'inbound' && direction !== 'outbound') {
    throw new UsageError(`bad_value: --direction is inbound or outbound, got "${direction}".`);
  }
  const bankAccount = stringFlag(args, 'bank-account') ?? (input['bank_account_id'] as string | undefined);
  const date = stringFlag(args, 'date') ?? (input['payment_date'] as string | undefined);
  const paymentDate = date ?? today();

  const fields = given({
    company_id: company.id,
    document_id: doc === undefined ? undefined : await resolveDocument(backend, company.id, doc),
    contact_id: who === undefined ? undefined : (await resolveContact(backend, company.id, who)).id,
    direction,
    amount: required(stringFlag(args, 'amount') ?? (input['amount'] as string | undefined), 'the amount paid', '--amount'),
    payment_date: paymentDate,
    bank_account_id: bankAccount === undefined ? undefined : uuidArg(bankAccount, '--bank-account'),
    journal_id: input['journal_id'],
    journal_code: stringFlag(args, 'journal') ?? input['journal_code'],
    reference: stringFlag(args, 'reference') ?? input['reference'],
    memo: stringFlag(args, 'memo') ?? input['memo'],
    currency_code: stringFlag(args, 'currency') ?? input['currency_code'],
    exchange_rate: stringFlag(args, 'rate') ?? input['exchange_rate'],
    match_open_items: boolFlag(args, 'no-match') ? false : input['match_open_items'],
    client_ref: stringFlag(args, 'ref') ?? input['client_ref'],
  }) as RecordPaymentArgs;

  const result = (await recordPayment(backend, fields)) as Row;
  setResult(result);

  const payment = (result['payment'] ?? {}) as Row;
  const entry = (result['entry'] ?? {}) as Row;
  const matched = (result['matched'] ?? []) as (Row | null)[];
  heading(`Payment, in ${company.name}`);
  if (result['replayed'] === true) note(dim(`already recorded under the reference ${text(fields.client_ref)}; nothing was recorded twice`));
  if (date === undefined) note(dim(`dated today, ${paymentDate}: no --date was given`));
  pairs([
    ['payment', `${text(payment['direction'])} ${text(payment['amount'])} ${text(payment['currency_code'])}  ${dim(text(payment['id']))}`],
    ['date', text(payment['payment_date'])],
    ['entry', text(entry['number'])],
  ]);
  line();
  if (matched.length === 0) note(dim('Matched against nothing.'));
  for (const matching of matched) step(`matched ${text(matching?.['amount'])} under ${text(matching?.['matching_number'])}`);
  line();
  note(dim(text(result['note'])));
  return 0;
}

const MATCH_FLAGS = [...BOOKS_FLAGS, 'amount', 'extra'] as const;
const EXTRA_KEYS = ['account', 'amount', 'tax', 'description'] as const;

/**
 * `--extra "account=<code>,amount=3.00,tax=<code>,description=Provider fee"` —
 * a line the settlement books beside the documents, named fields as `--line`
 * reads them. The amount goes in as it was typed.
 */
function parseExtra(text: string): SettlementExtraLine {
  const extra: Record<string, string> = {};
  for (const part of text.split(/(?<!\\),/)) {
    const equals = part.indexOf('=');
    const key = (equals === -1 ? part : part.slice(0, equals)).trim();
    if (equals === -1 || !(EXTRA_KEYS as readonly string[]).includes(key)) {
      throw new UsageError(
        `bad_extra: "${part.trim()}" is not key=value with a key among ${EXTRA_KEYS.join(', ')}. Example: --extra "account=<account code>,amount=3.00,tax=<tax code>".`,
      );
    }
    extra[key] = part.slice(equals + 1).trim().replace(/\\,/g, ',');
  }
  if (extra['account'] === undefined || extra['amount'] === undefined) {
    throw new UsageError(`bad_extra: "${text}" needs an account and an amount.`);
  }
  return extra as unknown as SettlementExtraLine;
}

export async function matchCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  rejectUnknownFlags(args, MATCH_FLAGS);
  const transactionId = uuidArg(args.positional[0], 'the bank transaction');
  const extras = stringFlags(args, 'extra').map(parseExtra);
  const amounts = stringFlags(args, 'amount');
  const named = args.positional.slice(1);
  if (named.length === 0 && extras.length === 0) {
    throw new UsageError('missing_argument: the document it pays was not given. Pass <document>, or --extra lines that are the whole of the statement line.');
  }
  const { backend, company } = await openBooks(args, deps);
  const documentIds: string[] = [];
  for (const document of named) documentIds.push(await resolveDocument(backend, company.id, document));

  const result = (await settleFromStatement(backend, {
    transaction_id: transactionId,
    document_ids: documentIds,
    ...(amounts.length === 0 ? {} : { amounts }),
    ...(extras.length === 0 ? {} : { extra_lines: extras }),
  })) as Row;
  setResult({ document_id: documentIds[0] ?? null, document_ids: documentIds, ...result });

  const transaction = (result['transaction'] ?? {}) as Row;
  heading(`Statement line, in ${company.name}`);
  pairs([
    ['line', `${text(transaction['transaction_date'])}  ${text(transaction['amount'])} ${text(transaction['currency_code'])}  ${dim(text(transaction['id']))}`],
    ['state', text(transaction['state'])],
    ['entry', dim(text(transaction['entry_id']))],
  ]);
  for (const extra of extras) step(`booked ${text(extra.amount)} on ${extra.account}${extra.tax === undefined ? '' : ` with ${extra.tax}`}`);
  return 0;
}
