# Several lines settle together, and a small difference is booked

> Status: accepted

## Context

`reconcile()` matches one debit line against one credit line. A screen that
cleans the receivable and payable accounts meets three shapes it does not
answer in one gesture: one payment that settles several invoices of one
customer, one invoice paid in several instalments, and a pair that differs by
a little — 97.00 received for an invoice of 100.00, the bank having kept the
rest.

The proposals behind those gestures already exist for a bank statement line:
`suggest_combination()` walks one counterparty's open items oldest first and
proposes a subset that reaches the amount
([0046](0046-settling-applies-identification-and-offers-resemblance.md)).
Writing a second search for ledger lines would give two answers to one
question.

A small difference is the other half. Leaving it open keeps the invoice in
the aged balance for an amount nobody will ever pay; matching the pair in part
hides it. The company tolerance that exists, `amount_tolerance_units`, decides
what `auto_settle()` applies without anybody, and is one unit of the currency
by default.

## Decision

**One search.** The walk of `suggest_combination()` becomes
`combination_subsets()`: the same order and the same rule for taking an item
(no more than what is left plus the tolerance), made a depth-first search, so
the first subset it meets is the greedy one whenever the greedy walk had one,
and it finds the subsets the greedy walk stepped over. Its bounds are written
once, in `matching_search_bounds()`: 40 candidates for a line, 10 lines in a
subset, 20 000 steps of the walk, 3 proposals for a line. A statement line
and a ledger line both ask it.

**Proposals between ledger lines, never applied.**
`suggest_item_combinations(company, contact)` proposes, for each open
receivable or payable line, what lines of the other side of the same
counterparty and account settle it: an exact pair, then several lines to the
cent, and only when nothing is exact, a pair then several lines within the
difference tolerance, with the difference signed. Each proposal has a stable
id. Lines naming nobody and lines in a foreign currency are not searched.

**Several lines in one gesture.** `reconcile_many(lines)` matches a set of
posted lines of one company, one reconcilable account and one counterparty —
a line naming nobody is attributed by the matching, as with `reconcile()` —
in the company's currency, whose open debits and credits are equal to the
cent. It pairs them oldest first through `reconcile()`, which stays the only
writer of a matching. Anything else is refused by name; a total a cent off is
refused, not settled in part.

**A difference is booked, never forgiven.** `reconcile_with_difference(lines,
reason)` takes the same set when its totals differ by no more than the
company's difference tolerance, posts an entry in the miscellaneous journal
that books the difference on the same account and counterparty against the
account the pack gives for the reason, and matches everything under one
letter. The reasons are the roles packs carry: `rounding` (the company's
rounding account, from the pack role `rounding`) and `exchange_difference`
(the pack roles `fx_loss` for a charge, `fx_gain` for an income). No pack
names an account for bank charges or a payment discount, so neither is a
reason; a reason without an account is refused rather than booked on a
neighbour. `matching_difference_reasons()` and `matching_difference_tolerance()`
tell a screen what it may propose.

**The difference has its own tolerance.** `difference_tolerance_units`, in
units of the currency like the other numbers of `matching_settings`, 500 when
the company has no opinion. Raising `amount_tolerance_units` instead would let
`auto_settle()` settle a short payment with nobody looking.

**Undoing takes back what was booked.** The entry of a difference is named on
the matchings of its line (`reconciliations.adjustment_entry_id`).
`unreconcile()` of one of them removes every matching of that line, posts the
mirror of the entry and matches the line with its mirror, so neither stays
open.

## Consequences

- One payment against several invoices, and the reverse, is one call and one
  letter, and the trail of each pairing is the trail `reconcile()` writes.
- `suggest_combination()` answers as before whenever the greedy walk found a
  subset within the bounds, and now also when it did not; it considers the 40
  oldest open items of the window rather than all of them.
- A difference is always an entry with a reason and an account a pack gave;
  the difference of a locked period is refused by `post_entry()`.
- A pack that adds a role for bank charges or discounts adds a reason without
  touching the gesture.

## See also

- `supabase/migrations/20261018210000_several_lines_settle_together_and_a_difference_is_booked.sql`
- `tests/item_matching.test.ts`
- [0045](0045-recognising-a-counterparty.md) — A counterparty is recognised from learned patterns
- [0046](0046-settling-applies-identification-and-offers-resemblance.md) — Settling applies identification, offers resemblance
- [0070](0070-a-line-that-names-nobody-is-named-once.md) — A third-party line that names nobody is named once
- [0072](0072-a-line-left-unnamed-and-a-name-among-several.md) — A line may be left unnamed, and a name among several is a doubt
