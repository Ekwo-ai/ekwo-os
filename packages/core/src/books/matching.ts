/**
 * Matching open items of one counterparty: what settles what, several lines in
 * one gesture, a small difference booked, and a line left unnamed on purpose.
 *
 * `suggest_item_combinations()` proposes, `reconcile_many()` and
 * `reconcile_with_difference()` match, `leave_line_unnamed()` and its undo
 * record a decision about a line (decisions 0071 and 0072). The search, the
 * accounts a difference is booked on, the tolerance and every refusal are the
 * schema's; this file asks for them and shapes the answer.
 */

import type { Backend, Row } from './backend.js';
import { money, moneyFields } from './format.js';
import { only } from './shared.js';

export interface SuggestItemCombinationsArgs {
  company_id: string;
  /** One contact (its branches and parent count as one party). Left out: every counterparty of the company. */
  contact_id?: string | undefined;
}

export interface MatchLinesArgs {
  /** The lines to match together: at least one debit and one credit. */
  line_ids: string[];
}

export interface ReconcileWithDifferenceArgs extends MatchLinesArgs {
  /** A reason `matching_difference_reasons()` lists: `rounding`, `exchange_difference`. */
  reason: string;
}

export interface LeaveLineUnnamedArgs {
  line_id: string;
  reason: string;
}

/** One proposal, as `suggest_item_combinations()` answers it. */
export interface ItemProposal {
  proposal_id: string;
  ordinal: number;
  contact_id: string;
  account_id: string;
  line_id: string;
  side: string;
  amount: string | null;
  kind: string;
  line_ids: string[];
  total: string | null;
  difference: string | null;
  because: string;
  alternatives: number;
}

/**
 * What lines of one counterparty and one account could settle each other, line
 * by line: an exact pair, several lines to the cent, or — when nothing is
 * exact — a pair or several lines within the company's difference tolerance.
 */
export async function suggestItemCombinations(
  backend: Backend,
  args: SuggestItemCombinationsArgs,
): Promise<unknown> {
  const found = await backend.rpc<Row>('suggest_item_combinations', {
    p_company_id: args.company_id,
    ...(args.contact_id === undefined ? {} : { p_contact_id: args.contact_id }),
  });
  const proposals: ItemProposal[] = found.map((row) => ({
    proposal_id: String(row['proposal_id']),
    ordinal: Number(row['ordinal']),
    contact_id: String(row['contact_id']),
    account_id: String(row['account_id']),
    line_id: String(row['line_id']),
    side: String(row['side']),
    amount: money(row['amount']),
    kind: String(row['kind']),
    line_ids: ((row['line_ids'] as unknown[] | null) ?? []).map(String),
    total: money(row['total']),
    difference: money(row['difference']),
    because: String(row['because']),
    alternatives: Number(row['alternatives']),
  }));
  return {
    proposals,
    count: proposals.length,
    note: 'Nothing is matched by a proposal. A difference other than 0.00 is closed only by reconcile_with_difference, with a reason, once the user has seen the difference and said so; reconcile_many matches a proposal whose difference is 0.00.',
  };
}

/** The reasons a difference may be booked for, with their accounts, and the largest difference the company books. */
export async function matchingDifferenceOptions(backend: Backend, args: { company_id: string }): Promise<unknown> {
  const [tolerance] = await backend.rpc<Row>('matching_difference_tolerance', { p_company_id: args.company_id });
  const reasons = await backend.rpc<Row>('matching_difference_reasons', { p_company_id: args.company_id });
  return {
    tolerance: tolerance === undefined
      ? null
      : {
          units: Number(tolerance['tolerance_units']),
          amount: money(tolerance['tolerance']),
          currency_code: tolerance['currency_code'] ?? null,
        },
    reasons,
    note: 'side says which difference a reason answers: charge when the lines carry more debit than credit, income the other way, either for both. A reason that is not available has no account to be booked on, and is refused.',
  };
}

function matched(rows: Row[], what: string): Row {
  return only(moneyFields(rows, ['amount', 'difference']), what);
}

/** Matches several lines together, their open debits and credits equal to the cent. */
export async function reconcileMany(backend: Backend, args: MatchLinesArgs): Promise<unknown> {
  const done = matched(await backend.rpc<Row>('reconcile_many', { p_line_ids: args.line_ids }), 'the lines were not matched');
  return {
    matching: done,
    note: 'The lines are matched under one letter, pair by pair through reconcile(). unreconcile undoes one matching at a time.',
  };
}

/** Books the difference on the account of the reason and matches everything. */
export async function reconcileWithDifference(backend: Backend, args: ReconcileWithDifferenceArgs): Promise<unknown> {
  const done = matched(
    await backend.rpc<Row>('reconcile_with_difference', { p_line_ids: args.line_ids, p_reason: args.reason }),
    'the lines were not matched',
  );
  return {
    matching: done,
    note: 'The difference is booked in a posted entry (adjustment_entry_id) on the same account and counterparty, against the account the pack gives for the reason, and every line is matched under one letter. unreconcile of the matching of the difference line takes the entry back with its mirror.',
  };
}

/** Records that a line names nobody on purpose: it is no longer proposed a contact. */
export async function leaveLineUnnamed(backend: Backend, args: LeaveLineUnnamedArgs): Promise<unknown> {
  const left = only(
    await backend.rpc<Row>('leave_line_unnamed', { p_line_id: args.line_id, p_reason: args.reason }),
    `line ${args.line_id} was not left unnamed`,
  );
  return {
    left_unnamed: left,
    note: 'The line is no longer proposed a contact. It is still an open item, it can still be matched or named, and undo_leave_line_unnamed takes the decision back.',
  };
}

/** Takes back `leave_line_unnamed()`: the line is proposed a contact again. */
export async function undoLeaveLineUnnamed(backend: Backend, args: { line_id: string }): Promise<unknown> {
  const removed = only(
    await backend.rpc<Row>('undo_leave_line_unnamed', { p_line_id: args.line_id }),
    `line ${args.line_id} was not left unnamed`,
  );
  return {
    removed,
    note: 'The line is proposed a contact again.',
  };
}
