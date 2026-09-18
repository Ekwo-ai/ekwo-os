/**
 * Payments and matching.
 *
 * `post_payment`, `reconcile` and `unreconcile` carry the rules and this file
 * calls them. The one thing decided here is which open items a payment is
 * offered to, oldest first — never how much is owed, which the ledger says.
 */

import { BooksError, type Backend, type Filter, type Row } from './backend.js';
import * as columns from './columns.js';
import { amountIn, moneyFields } from './format.js';
import { companyCurrency, createdBefore, idsByCode, only } from './shared.js';

export interface RecordPaymentArgs {
  company_id: string;
  /** Left out when `document_id` is given: the open item says which way the money goes. */
  direction?: 'inbound' | 'outbound' | undefined;
  amount: string | number;
  payment_date: string;
  contact_id?: string | undefined;
  journal_id?: string | undefined;
  journal_code?: string | undefined;
  bank_account_id?: string | undefined;
  reference?: string | undefined;
  memo?: string | undefined;
  currency_code?: string | undefined;
  exchange_rate?: string | number | undefined;
  match_open_items?: boolean | undefined;
  /**
   * The document this money pays. It names the contact and the direction —
   * read off what is still open on it, as the ledger holds it — and the
   * matching is offered to that document alone.
   */
  document_id?: string | undefined;
  /** Your own reference. Recording twice under one reference records once. */
  client_ref?: string | undefined;
}

export interface SettleFromStatementArgs {
  transaction_id: string;
  /** The document the statement line pays: its open items are the lines settled. */
  document_id?: string | undefined;
  /** Or the open items themselves, by ledger line. */
  line_ids?: string[] | undefined;
}

interface OpenItem {
  line_id: string;
  contact_id: string | null;
  side: 'debit' | 'credit';
  document_id: string | null;
}

/** What is still open on one document, as `open_items()` reports it. */
async function openItemsOf(backend: Backend, company: string, documentId: string): Promise<OpenItem[]> {
  const items = await backend.rpc<OpenItem>('open_items', { p_company_id: company });
  const open = items.filter((item) => item.document_id === documentId);
  if (open.length === 0) {
    throw new BooksError(
      `nothing_open: document ${documentId} has no open item. Either it is not posted yet, or it is already settled, or it is not visible to you.`,
    );
  }
  return open;
}

export interface ReconcileArgs {
  line_a: string;
  line_b: string;
  amount?: string | number | undefined;
}

export interface UnreconcileArgs {
  reconciliation_id: string;
}

export async function recordPayment(
  backend: Backend,
  args: RecordPaymentArgs,
): Promise<unknown> {
  const before = await createdBefore(backend, 'payments', args.company_id, args.client_ref, ['id', 'entry_id']);

  // A payment of a document: who and which way are read off its open item,
  // which the ledger holds, rather than deduced from the kind of document.
  // Recorded before under this reference, the document may well have nothing
  // open any more — that is what the first call was for — so nothing open is
  // then not a refusal.
  let paid: OpenItem[] | undefined;
  if (args.document_id !== undefined) {
    try {
      paid = await openItemsOf(backend, args.company_id, args.document_id);
    } catch (error) {
      if (before === undefined) throw error;
    }
  }
  const contactId = args.contact_id ?? paid?.[0]?.contact_id ?? undefined;
  const direction = args.direction ?? (paid === undefined ? undefined : paid[0]?.side === 'debit' ? 'inbound' : 'outbound');
  if (direction === undefined && before === undefined) {
    throw new BooksError('missing_direction: a payment is inbound or outbound — say which, or give document_id and the open item says it.');
  }

  let journalId = args.journal_id;
  if (journalId === undefined && args.journal_code !== undefined) {
    journalId = (await idsByCode(backend, 'journals', args.company_id, [args.journal_code])).get(
      args.journal_code,
    ) as string;
  }
  if (journalId === undefined && args.bank_account_id !== undefined) {
    // A bank account knows the journal it moves through; asking the caller
    // to repeat it was the first thing the real test tripped over.
    const account = await backend.select<{ journal_id: string | null }>({
      table: 'bank_accounts',
      columns: ['journal_id'],
      where: [
        { column: 'id', op: 'eq', value: args.bank_account_id },
        { column: 'company_id', op: 'eq', value: args.company_id },
      ],
    });
    journalId = account[0]?.journal_id ?? undefined;
  }
  if (journalId === undefined && before === undefined) {
    throw new BooksError(
      'missing_journal: a payment needs the bank or cash book it goes through — give bank_account_id (list_bank_accounts), or journal_id / journal_code (get_company lists the journals).',
    );
  }

  // Recorded before under this reference: nothing is inserted, and what a
  // dropped connection left undone — the booking, the matching — is finished.
  const payment = before ?? only(
    await backend.insert<Row>(
      'payments',
      [
        {
          company_id: args.company_id,
          direction,
          payment_date: args.payment_date,
          amount: amountIn(args.amount),
          // Never a literal, for the reason `create_document` gives: a company
          // that keeps its books in another currency would get a euro payment
          // out of a euro written here.
          currency_code:
            args.currency_code ?? (await companyCurrency(backend, args.company_id)),
          exchange_rate: args.exchange_rate === undefined ? 1 : String(args.exchange_rate),
          contact_id: contactId ?? null,
          journal_id: journalId as string,
          bank_account_id: args.bank_account_id ?? null,
          reference: args.reference ?? null,
          memo: args.memo ?? null,
          client_ref: args.client_ref ?? null,
        },
      ],
      ['id'],
    ),
    'the payment could not be created',
  );

  const booked = typeof payment['entry_id'] === 'string' ? (payment['entry_id'] as string) : undefined;
  const entry = only(
    booked === undefined
      ? moneyFields(await backend.rpc<Row>('post_payment', { p_payment_id: payment['id'] as string }), [
          'total_debit',
          'total_credit',
        ])
      : await backend.select<Row>({
          table: 'entries',
          columns: columns.ENTRY,
          where: [{ column: 'id', op: 'eq', value: booked }],
        }),
    'the payment produced no entry',
  );

  const lines = await backend.select<Row>({
    table: 'entry_lines',
    columns: columns.ENTRY_LINE,
    where: [{ column: 'entry_id', op: 'eq', value: entry['id'] as string }],
    order: [{ column: 'sequence' }],
  });

  const matched =
    args.match_open_items === false || contactId === undefined || (args.document_id !== undefined && paid === undefined)
      ? []
      : await matchOpenItems(
          backend,
          args.company_id,
          contactId,
          lines,
          paid === undefined ? undefined : new Set(paid.map((item) => item.line_id)),
        );

  const settled = await backend.select<Row>({
    table: 'payments',
    columns: columns.PAYMENT,
    where: [{ column: 'id', op: 'eq', value: payment['id'] as string }],
  });

  return {
    payment: settled[0] ?? null,
    entry,
    entry_lines: lines,
    matched,
    ...(before === undefined ? {} : { replayed: true }),
    note:
      contactId === undefined
        ? 'No contact was given, so the payment landed on the company default third-party account and nothing was matched.'
        : 'Matching is what makes a document paid: documents.amount_paid is derived from it.',
  };
}

/**
 * Matches the payment against the open items of a contact, oldest first.
 *
 * Only lines on the same third-party account, on the other side, still
 * carrying a residual. Each pairing is a call to `reconcile`, which is what
 * draws the letter and keeps the residual honest; this function decides
 * nothing about amounts beyond "the smaller of what is left on either side".
 */
async function matchOpenItems(
  backend: Backend,
  company: string,
  contact: string,
  paymentLines: Row[],
  among?: Set<string>,
): Promise<unknown[]> {
  const accounts = await backend.select<{ id: string; reconcilable: boolean }>({
    table: 'accounts',
    columns: ['id', 'reconcilable'],
    where: [
      {
        column: 'id',
        op: 'in',
        value: paymentLines
          .map((line) => line['account_id'])
          .filter((id): id is string => typeof id === 'string'),
      },
    ],
  });
  const reconcilable = new Set(accounts.filter((account) => account.reconcilable).map((a) => a.id));
  const paymentLine = paymentLines.find(
    (line) => typeof line['account_id'] === 'string' && reconcilable.has(line['account_id']),
  );
  if (paymentLine === undefined) return [];

  const accountId = paymentLine['account_id'] as string;
  const paymentIsDebit = Number(paymentLine['debit'] ?? 0) > 0;

  const candidates = await backend.select<Row>({
    table: 'entry_lines',
    columns: [...columns.ENTRY_LINE, 'company_id'],
    where: [
      { column: 'company_id', op: 'eq', value: company },
      { column: 'contact_id', op: 'eq', value: contact },
      { column: 'account_id', op: 'eq', value: accountId },
    ] satisfies Filter[],
    limit: 500,
  });

  const entryIds = [...new Set(candidates.map((line) => line['entry_id'] as string))];
  const entries = await backend.select<{ id: string; state: string; entry_date: string }>({
    table: 'entries',
    columns: ['id', 'state', 'entry_date::text'],
    where: [{ column: 'id', op: 'in', value: entryIds }],
  });
  const posted = new Map(entries.filter((entry) => entry.state === 'posted').map((e) => [e.id, e]));

  // Which scale the allocation is worked out on. `reconcile` matches two
  // lines in the same foreign currency in *that* currency, because that is
  // where they are equal, and reads `p_amount` the same way. So when the
  // payment is foreign the amounts below are its currency's, and a candidate
  // in another currency is left alone rather than matched at the wrong scale.
  const home = await companyCurrency(backend, company);
  const currency = paymentLine['currency_code'] as string | null;
  const foreign =
    currency !== null && currency !== home && paymentLine['amount_currency'] !== null;

  /** What is still open on a line, on the scale the matching uses. */
  const openOf = (line: Row): number => {
    const ledger = Math.abs(Number(line['balance'] ?? 0));
    const left = ledger - Number(line['matched_amount'] ?? 0);
    if (!foreign) return left;
    const inCurrency = Math.abs(Number(line['amount_currency'] ?? 0));
    return ledger === 0 ? 0 : Math.round((inCurrency * left * 100) / ledger) / 100;
  };

  const open = candidates
    .filter((line) => line['id'] !== paymentLine['id'])
    .filter((line) => among === undefined || among.has(line['id'] as string))
    .filter((line) => posted.has(line['entry_id'] as string))
    .filter((line) => (Number(line['debit'] ?? 0) > 0) !== paymentIsDebit)
    .filter((line) => !foreign || line['currency_code'] === currency)
    .map((line) => ({
      line,
      residual: openOf(line),
      due: String(line['date_maturity'] ?? posted.get(line['entry_id'] as string)?.entry_date ?? ''),
    }))
    .filter((item) => item.residual > 0.005)
    .sort((a, b) => a.due.localeCompare(b.due));

  let remaining = openOf(paymentLine);
  const done: unknown[] = [];

  for (const item of open) {
    if (remaining <= 0.005) break;
    const amount = Math.min(remaining, item.residual).toFixed(2);
    const reconciliation = moneyFields(
      await backend.rpc<Row>('reconcile', {
        p_line_a: paymentLine['id'],
        p_line_b: item.line['id'],
        p_amount: amount,
      }),
      ['amount'],
    );
    done.push(reconciliation[0] ?? null);
    remaining -= Number(amount);
  }

  return done;
}

export async function reconcile(
  backend: Backend,
  args: ReconcileArgs,
): Promise<unknown> {
  const rows = moneyFields(
    await backend.rpc<Row>('reconcile', {
      p_line_a: args.line_a,
      p_line_b: args.line_b,
      p_amount: args.amount === undefined ? null : amountIn(args.amount),
    }),
    ['amount'],
  );
  return { reconciliation: rows[0] ?? null };
}

export async function unreconcile(
  backend: Backend,
  args: UnreconcileArgs,
): Promise<unknown> {
  await backend.rpcVoid('unreconcile', { p_reconciliation_id: args.reconciliation_id });
  return {
    unreconciled: args.reconciliation_id,
    note: 'The matching is undone. The entries themselves are untouched: matching changes no account.',
  };
}

/**
 * A statement line pays a document: `settle_from_statement()` books the
 * payment the line is and matches it against the open items named. Naming a
 * document names what is open on it; nothing here chooses between candidates.
 */
export async function settleFromStatement(
  backend: Backend,
  args: SettleFromStatementArgs,
): Promise<unknown> {
  let lineIds = args.line_ids;
  if (lineIds === undefined || lineIds.length === 0) {
    if (args.document_id === undefined) {
      throw new BooksError('no_lines_named: settling needs the document this money pays, or the open items themselves.');
    }
    const transaction = only(
      await backend.select<{ company_id: string }>({
        table: 'bank_transactions',
        columns: ['company_id'],
        where: [{ column: 'id', op: 'eq', value: args.transaction_id }],
      }),
      `bank transaction ${args.transaction_id}`,
    );
    lineIds = (await openItemsOf(backend, transaction.company_id, args.document_id)).map((item) => item.line_id);
  }

  await backend.rpc<Row>('settle_from_statement', {
    p_transaction_id: args.transaction_id,
    p_line_ids: lineIds,
  });
  const settled = await backend.select<Row>({
    table: 'bank_transactions',
    columns: columns.BANK_TRANSACTION,
    where: [{ column: 'id', op: 'eq', value: args.transaction_id }],
  });
  return { transaction: settled[0] ?? null, settled_lines: lineIds };
}
