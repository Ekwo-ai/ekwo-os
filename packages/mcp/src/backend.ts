/**
 * The one interface every tool is written against.
 *
 * There are two ways to reach an Ekwo database and neither of them is a
 * privileged one. The recommended route is PostgREST with the signed-in
 * user's own token, which is how the schema is meant to be read and written:
 * row level security decides, exactly as it would for that person in a
 * browser. The second is a direct Postgres connection, for a self-hosted
 * installation and for the tests — and even there the claims and the role are
 * set on every call, so the same policies apply.
 *
 * Tools therefore never see a client, a token or a connection string. They
 * see `select`, `insert`, `update`, `remove` and `rpc`, and what comes back
 * is whatever the policies let through.
 */

import {
  BooksError,
  columnName,
  identifier,
  qualified,
  socleCode,
  type AgentSession,
  type Backend,
  type Filter,
  type Order,
  type Row,
  type SelectQuery,
  type SessionPosting,
  type Value,
} from '@ekwo-ai/core';

// Moved to the core, where the command line reads them too: what a refusal is
// called, what a backend is and what an error of this layer looks like cannot
// be decided twice. Still exported from here, under the names they always had.
export { columnName, identifier, qualified, socleCode };
export type { AgentSession, Backend, Filter, Order, Row, SelectQuery, SessionPosting, Value };

/** The core's error, under the name this package has always exported. */
export const EkwoMcpError = BooksError;
export type EkwoMcpError = BooksError;

/**
 * What each socle refusal means, in one sentence.
 *
 * Only the codes a client of this server can actually provoke are listed. An
 * unknown code is not a failure of this table: the raw message is already the
 * answer, and the sentence is the part that was optional.
 */
const HINTS: Record<string, string> = {
  period_locked: 'The company has an accounting lock date on or after this date. Ask the owner to move lock_date, or book on a later date.',
  tax_period_locked: 'The company has a VAT lock date covering this date. Anything carrying a declaration box is frozen there.',
  fiscal_year_closed: 'The financial year covering this date is closed. Reopen it, or book in an open year.',
  entry_unbalanced: 'The debit and the credit of the entry differ. Nothing was posted.',
  entry_empty: 'The entry has no lines.',
  document_empty: 'The document has no billable line, so there is nothing to book.',
  document_already_posted: 'This document has already been booked. Read it back rather than posting it twice.',
  document_already_booked: 'This document already points at an entry. Read it back rather than posting it twice.',
  document_cancelled: 'A cancelled document cannot be booked.',
  entry_posted: 'A posted entry is immutable, in an open period too: its lines, its date, its state, and it is not deleted. Undo it with reverse_entry, which posts the reversal that names it.',
  entry_posted_by_hand: 'An entry becomes posted through post_entry, which draws its number from the journal counter, dates the posting and checks the period. Setting the state by hand is refused unless the row is exactly what post_entry would have written.',
  document_posted_by_hand: 'A document becomes posted through post_document, which builds its entry. Setting the state by hand on an entry that was not built for this document is refused.',
  entry_born_posted: 'An entry is created as a draft and posted with post_entry. One that is already posted arrives only with a company loaded from an archive, by import_company.',
  document_posted: 'This document was issued, and what produced an entry does not change afterwards: not its lines, not its figures, not its state, and it is not deleted. Undo it with cancel_document, which puts it back to draft where its country allows it and nothing has left, and issues the credit note that names it otherwise.',
  posted_edit_reversal_only: "This country keeps a posted document as it was posted. It is undone by a credit note: cancel_document issues it.",
  document_sent: 'The document has been sent, so the customer holds its number. It is undone by a credit note: cancel_document issues it.',
  document_has_history: 'Other entries name this document, and they stay. It is undone by a credit note: cancel_document issues it.',
  document_period_closed: 'The document is booked or taxed in a period that is no longer open. It is undone by a credit note on an open date: cancel_document, with the date the user chooses.',
  document_declared: 'The document falls in a declaration that has been filed. It is undone by a credit note, which the next declaration carries: cancel_document.',
  document_not_last_number: 'A later number has been drawn in the same journal, and this country forbids a hole. It is undone by a credit note: cancel_document issues it.',
  document_cancelled_stays_matched: 'This matching is what cancels the document against its credit note, and a cancelled document stays cancelled. Issue the document again if it was right after all.',
  document_cancelled_by_hand: 'A posted document becomes cancelled through cancel_document, which issues the credit note that names it and matches the two. Setting the state by hand is refused.',
  reversal_date_needed: 'What is undone is dated in a period that is locked or closed, and the reversal is booked in an open one. Ask the user which date to use and pass it; none is chosen for them.',
  reversal_before_original: 'A reversal is dated on or after what it undoes.',
  entry_not_posted: 'A draft entry is changed or deleted; only a posted one is reversed.',
  entry_is_a_reversal: 'This entry undoes another one. A reversal is not reversed; post the original again as a new entry if it was right after all.',
  entry_already_reversed: 'A posted reversal already names this entry. Read it back rather than reversing twice.',
  entry_of_a_document: 'A document wrote this entry, and it is undone with the document: cancel_document.',
  fiscal_year_finally_closed: 'The financial year is under a final close: nobody reopens it or changes it. Book the correction in an open year.',
  later_fiscal_year_closed: 'A later financial year is closed. Reopen the later one first, then this one — latest first.',
  entry_of_a_year_end: 'The entries of a close are undone by reopen_fiscal_year; an opening is corrected by an ordinary entry of the year.',
  entry_belongs_elsewhere: 'Something else wrote this entry — a payment, a bank transaction, a module, a declaration or a matching — and it is undone there.',
  entry_matched: 'The entry is matched. Undo the matching with unreconcile first, and only when the user says so: it records money that moved.',
  document_not_posted: 'A draft is changed or deleted; only a posted invoice is undone.',
  document_already_cancelled: 'This document is already cancelled.',
  document_is_a_credit_note: 'A credit note is not cancelled by another one. Issue the invoice again if it was right after all.',
  document_already_credited: 'A posted credit note already names this document. Cancelling it would credit it twice.',
  document_paid: 'The document is settled in part or in full. Undo that matching with unreconcile first, and only when the user says so: the money it records came in and stays.',
  credit_note_differs: 'The lines of the invoice no longer give the figures it was issued with, so the credit note would not mirror it. Credit it by hand, line by line.',
  document_born_posted: 'A document is created as a draft and posted with post_document. One that is already posted arrives only with a company loaded from an archive, by import_company.',
  document_posted_without_entry: 'A document becomes posted through post_document, which builds its entry. Setting the state by hand is refused.',
  document_amount_paid_is_derived: 'What a document was settled by comes from the matching of its entry. Match a payment or a credit note against it instead of writing the figure.',
  document_payment_state_is_derived: 'The settlement state follows from what was matched against the document. It is never written.',
  approval_required: 'Agents post in review here: a person approves each document an agent proposes before it is posted. Show the user the draft (and post_document with dry_run: true for its entry) and ask them to approve it — ekwo doc approve <document>, or the web application. Do not post it another way; a draft changed after the approval needs another one.',
  approval_by_a_person: 'Only a person signed in approves a document for posting. Ask the user to do it.',
  agent_posting_by_a_person: 'How agents post is the user\'s choice (agent_posting, in their settings, or ekwo company agent-posting): an agent may make it stricter when they ask, never looser. Never change it for them.',
  autopilot_forbidden: 'This company allows review only, so this session cannot post in autopilot here. Ask the user to approve the draft (ekwo doc approve <document>), or to start the session without --autopilot.',
  document_not_accountable: 'Quotes and purchase orders are not booked. Turn it into an invoice first.',
  document_total_mismatch: 'The header total disagrees with what the lines book. The lines are right by construction, so the header is what needs fixing.',
  tax_not_in_force: 'That tax is not applicable on the accounting date. Pick the tax in force for that period.',
  unsupported_tax_amount_type: 'Only percentage taxes can be posted; a fixed-amount tax has no basis to spread.',
  no_counterpart_account: 'No receivable or payable account is set, either on the contact or as a company default.',
  no_journal: 'No journal was given and the company has no default for this kind of document.',
  unknown_bank_account: 'The statement is of an account this company does not have, and an import never creates one: an account nobody decided is mapped to no journal. create_bank_account adds it; then import the file again.',
  unbalanced_statement: 'The opening balance plus the booked lines is not the closing balance the bank declared, so a line is missing or altered. Nothing was imported; get the file again from the bank.',
  statement_without_balances: 'Without an opening and a closing balance nothing proves the lines are all there. Nothing was imported.',
  unreadable_statement_line: 'A booked line cannot be held as it is — no amount, no date, another currency than the account, or more decimals than the ledger keeps. Nothing was imported.',
  statement_conflict: 'A statement with this identifier and date was already imported with other balances. The bank may have reissued it; nothing was changed.',
  statement_currency_mismatch: 'The statement is in another currency than the bank account it belongs to. Nothing is converted on import.',
  bank_account_mismatch: 'The bank account named is not the account the statement is of.',
  no_bank_account: 'The payment names no bank account and its journal has no default account. create_bank_account adds one and wires it to the journal.',
  missing_account: 'The line names no account, and the company and its country model have no default for this kind of document. Give account_code on the line, or set the company default.',
  payment_already_booked: 'This payment already has an entry.',
  payment_cancelled: 'A cancelled payment cannot be booked.',
  reconcile_same_side: 'Matching pairs a debit with a credit; both lines are on the same side.',
  reconcile_account_mismatch: 'The two lines are on different accounts.',
  reconcile_over_debit: 'The amount is larger than what is still open on the debit line.',
  reconcile_over_credit: 'The amount is larger than what is still open on the credit line.',
  reconcile_nothing_left: 'Both lines are already fully matched.',
  account_not_reconcilable: 'That account is not reconcilable, so nothing on it can be matched.',
  settlement_unbalanced: 'The statement line does not equal the items it settles and its extra lines, to the cent; the difference is in the message. Read the amounts again with the user — a fee or a charge missing, or an item settled for the wrong amount — and never add a line to make it balance on your own.',
  account_takes_no_entries: 'An extra line, or a difference, goes on an account that takes a charge or an income. A customer or supplier account is settled by naming its open items, not by an extra line.',
  extra_line_sign: 'A charge bearing a tax is positive. A charge the provider refunded is a credit note of theirs, not an extra line.',
  settlement_over_open: 'An amount named is more than that item has open. List the open items again; what is already settled cannot be settled twice.',
  unknown_document: 'No document with that id is visible to you.',
  unknown_entry: 'No entry with that id is visible to you, or your role does not allow changing it.',
  unknown_entry_line: 'No ledger line with that id is visible to you.',
  unknown_reconciliation: 'No matching with that id is visible to you.',
  unknown_payment: 'No payment with that id is visible to you.',
  unknown_line: 'No ledger line with that id is visible to you. suggest_line_contacts lists the lines that can be named.',
  line_has_contact: 'The line already names a contact, and keeps it. A posted counterparty is corrected by reversing the entry, and only when the user says so.',
  line_matched: 'The line is matched, and keeps the counterparty it was matched as. Undo the matching with unreconcile first, and only when the user says so.',
  line_not_third_party: 'Only a line on a receivable or payable account is named this way. suggest_line_contacts lists the ones that can be.',
  line_not_posted: 'The line belongs to a draft, which takes its contact like any other column and is posted with it.',
  same_contact: 'A merge joins two contacts; the same id was given twice.',
  already_merged: 'That contact was merged before. Merge into the contact that holds its history, which the message names.',
  different_identifiers: 'The two contacts carry different VAT or registration numbers, so they are two parties. Ask the user; if one number is wrong, correct it first.',
  matching_across_parties: 'A matching of the absorbed contact would end up settling the items of two parties. Show the user the matching the message names; undo it with unreconcile only when they say so.',
  contact_merged: 'That contact was merged into another, which holds its history now. Use the contact the message names.',
  no_lines_named: 'A matching names at least two lines, a debit and a credit.',
  duplicate_line: 'Each line is named once.',
  reconcile_company_mismatch: 'The lines belong to two companies.',
  reconcile_contact_mismatch: 'The lines name two counterparties, and a matching settles the items of one. A branch and its parent are one party.',
  reconcile_foreign_currency: 'A line is stated in another currency than the company\'s. Match it pair by pair with reconcile, which books the exchange difference.',
  line_not_open: 'A line has nothing left open. List the open items again.',
  reconcile_unbalanced: 'The debits and the credits differ; the amounts are in the message. Show the user the difference: reconcile_with_difference books it with a reason they choose, within the company tolerance. Never add a line yourself.',
  no_difference: 'The lines balance to the cent: reconcile_many matches them.',
  difference_above_tolerance: 'The difference is more than the company books by itself (matching_difference_options gives the tolerance). Look at the lines again with the user: an item missing, or a payment that is not for these invoices.',
  unknown_difference_reason: 'matching_difference_options lists the reasons this company can book a difference for.',
  no_account_for_reason: 'The pack or the company names no account for that reason on that side. Pick another reason with the user, or have the account set up.',
  reason_required: 'Say why the line names nobody: the reason is what the next person reads.',
  line_left_unnamed: 'The line is already left unnamed. undo_leave_line_unnamed takes that back.',
  line_not_left_unnamed: 'The line was not left unnamed.',
};

/**
 * Check constraints that a client can legitimately provoke, in the words a
 * model can act on.
 *
 * Postgres names the constraint and nothing else — "violates check constraint
 * document_lines_product_has_account" says which rule broke and not what to
 * do. These few are the ones reachable through a tool, so they get the same
 * shape as a socle raise: an identifier, then a sentence.
 */
const CONSTRAINTS: Record<string, string> = {
  document_lines_product_has_account:
    'missing_account: a line has no account, and neither the product, the company nor the country model supplies a default for this kind of document',
};

/** The socle error, with the sentence that explains it when we have one. */
export function explain(message: string): EkwoMcpError {
  for (const [constraint, rewritten] of Object.entries(CONSTRAINTS)) {
    if (message.includes(constraint)) {
      const code = socleCode(rewritten);
      const hint = code === undefined ? undefined : HINTS[code];
      return new EkwoMcpError(rewritten, {
        ...(code !== undefined ? { code } : {}),
        ...(hint !== undefined ? { hint } : {}),
      });
    }
  }
  const code = socleCode(message);
  const hint = code === undefined ? undefined : HINTS[code];
  return new EkwoMcpError(message, { ...(code !== undefined ? { code } : {}), ...(hint !== undefined ? { hint } : {}) });
}

