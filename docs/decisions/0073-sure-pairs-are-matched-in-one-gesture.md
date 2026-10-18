# The sure pairs are matched in one gesture, and what undoes an entry is matched as it is posted

> Status: accepted

## Context

A matching screen over books brought in from elsewhere opens on hundreds of
proposals, and most of them are not questions. One invoice of 1 200.00 and
one payment of 1 200.00 of the same customer, with nothing else of that
amount on the account; a subscription billed and paid every month for the
same amount. Clicking each of them is a gesture repeated until nobody reads
what they click.

Some pairs are not even proposals: an entry and its reversal, an invoice and
the credit note that names it. `reverse_entry()` and `cancel_document()`
already match the mirror they post
([0071](0071-several-lines-settle-together-and-a-difference-is-booked.md)
builds on the same path). Three ways of posting a mirror did not: a reversal
keyed as a draft that names its entry and posted by `post_entry()`; a credit
note that names its invoice, posted by `post_document()` for part of it; and
the mirror `unreconcile()` posts to take back an exchange difference, which
left two open lines behind. A payment is not one of them: `payments` names no
document, and the library that records the payment of a document matches it
with that document's open items as it records it.

## Decision

**What is sure is said by one function, with its reason.**
`suggest_sure_pairs(company, contact)` gives one row per pair — a debit and a
credit of one counterparty on one account, open for the same amount to the
cent, each line in one pair at most — among the lines the matching already
searches (`matchable_lines()`, which `suggest_item_combinations()` reads too).
The evidence, in the order the rules are read, each on what the earlier ones
left:

- `same_document` — both lines are of one document, or the settlement's entry
  carries the document's number or payment reference;
- `reversal` — one entry undoes the other, or a credit note names the invoice;
- `unique_amount` — the one open debit and the one open credit of that amount;
- `recurring_in_date_order` — several lines of one amount: the oldest invoice
  (the debit of a receivable, the credit of a payable) with the first
  settlement dated on or after it, then the next. A settlement dated before an
  invoice is never its pair under this rule.

Nothing is matched by the function: a person accepts the list.

**One gesture, undone as one.** `reconcile_batch(pairs)` matches every pair
through the checks of `reconcile_many()` and `reconcile()`, records the
gesture in `reconciliation_batches` and names it on each matching. The first
refusal refuses the whole batch and says which pair. `unreconcile_batch(batch)`
undoes, through `unreconcile()`, every matching of the batch still standing,
and records when and by whom. Both ask `reconcile.write`; a batch is written
by these two functions and by nothing else.

**What undoes an entry is matched as it is posted.** When an entry that names
what it undoes (`reversed_entry_id`) is posted, and when a credit note that
names its invoice (`reversed_document_id`) is posted — the invoice posted, of
the matching kind, in the same currency at the same rate — their third-party
lines are matched with the other's on the spot, through `match_reversal()`,
for what both still have open, never across two counterparties. A credit note
for part of an invoice settles that part. The caller has to be one who may
match (`reconcile.write`, and `settings.read` where reconcilable is written);
for anybody else the posting goes through as before and the two lines stay
open, where `suggest_sure_pairs()` proposes them as `reversal`.

**A person undoes it like any matching.** An automatic matching is an
ordinary row of `reconciliations`: `unreconcile(id)` removes it and what it
booked, and the two lines are open again. The matching of an invoice that
`cancel_document()` cancelled stays, as before: a cancelled document stays
cancelled.

## Consequences

- A screen can offer one button for every pair that leaves nothing to choose,
  and one to take the whole gesture back.
- A pair in the list is exact and of one counterparty on one account; what
  needs a difference or several lines stays with `suggest_item_combinations()`.
- A reversal or a credit note naming its invoice no longer leaves two open
  items that cancel on paper. Unposting such a credit note, or the invoice it
  names, asks for the matching to be undone first, as for a payment.
- A unique amount is paired whichever line is older: an advance paid before
  its invoice is still its pair. Only several lines of one amount are read in
  date order.

## See also

- `supabase/migrations/20261018230000_sure_pairs_are_matched_in_one_gesture.sql`
- `tests/sure_pairs.test.ts`
- [0071](0071-several-lines-settle-together-and-a-difference-is-booked.md) — Several lines settle together, and a small difference is booked
- [0072](0072-a-line-left-unnamed-and-a-name-among-several.md) — A line may be left unnamed, and a name among several is a doubt
