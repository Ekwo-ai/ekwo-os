# Amounts are positive; totals are derived

> Status: accepted

## Context

Where a header and its lines can disagree, they eventually will, and the
ledger is the one that has to be right.

## Decision

**Amounts are always positive; a reversal flips the side.** A credit note
debits what the invoice credited, with the same positive figures. Negative
debits break every check constraint that says a line has one side and make a
trial balance unreadable.

**Totals are derived from the lines.** `document_lines.amount_untaxed` is
written by a `before` trigger on every insert and update (it is not a
generated column because a generated column cannot look up the document's
currency); document and entry totals are maintained by triggers, on drafts.

**What a document has been settled by is derived from its matching.**
`documents.amount_paid` is recomputed from the matched amounts on the
third-party lines of its entry, so `amount_residual` and `payment_state`
follow from the ledger. The recomputation lives in the existing
reconciliation trigger rather than a second one, because two `after` row
triggers fire in name order and this one must run after the line residuals.
On a posted document the guard accepts only the value
`document_amount_paid()` gives, whatever path writes it.

**The counterpart line is the difference of everything already written.** The
entry balances by construction; when the document header disagrees,
`post_document` raises and names the document
(`document_total_mismatch`). Patching a ledger line to make a wrong header
true is how a wrong invoice becomes a wrong ledger.

**One discount rule: a percentage off the line.**
`quantity × unit_price × (1 − discount / 100)`, rounded once at the decimals
of the document's currency. An absolute discount is a percentage or a line of
its own.

**Tax is rounded once per tax group, on the rounded basis** — EN 16931
BR-CO-14, and what every validator checks. Not per line, which accumulates
drift; not on the document total, which loses the breakdown.

**A missing tax is a missing tax, never zero per cent.** A line with no
`tax_id` produces a base line with no declaration box. Defaulting to zero
turns a data-entry gap into a false return.

## Consequences

- A header that disagrees with its lines is refused at posting, never silently corrected.
- A value keyed by hand on a derived column is overwritten or refused.

## See also

- [0011 An amount is rounded at the decimals of its currency](0011-an-amount-is-rounded-at-its-currency.md)
- [0019 Tax postings carry the account and the box](0019-tax-postings-carry-the-account-and-the-box.md)
- `tests/posting.test.ts`, `tests/reconciliation.test.ts`
