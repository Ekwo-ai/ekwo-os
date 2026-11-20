# A document keeps the tax its source states, within a rounding

> Status: accepted

## Context

Ekwo rounds the tax once per tax group, on the rounded basis (decision
[0010](0010-amounts-are-positive-and-totals-derived.md), EN 16931 BR-CO-14).
Many suppliers and billing systems round it line by line instead, which
EN 16931 allows: its rule BR-CO-17 accepts a group tax within one unit of its
base times its rate. Three lines of 0.25 at 6 % are then invoiced with a tax
of 0.02 + 0.02 + 0.02 = 0.06, where the group rounded once gives 0.05.

The invoice the customer received says 0.06. A document recorded with 0.05 is
not that invoice: its total disagrees with what was paid, its receivable is
never settled to the cent, and a connector that checks the totals it was given
can only hold it. Rounding the stated tax away into another account would make
the ledger agree with the invoice by a figure that means nothing.

## Decision

**The stated tax is a fact of the line.** `document_lines.stated_tax_amount`
is the tax the source states for the line, in the document's currency. It is
optional and written where the line is written — `create_document()`,
`replace_document_lines()`, the MCP tool, `--line stated_tax=…`, an insert of
a connector. A source that rounds line by line has the figure per line; a
source that only prints a figure per group states it on one line of a group of
one.

**A group is stated whole or not at all.** When every product line of a tax
group states its tax, the group's tax is their sum. A group stated on some
lines only is refused at posting, `stated_tax_partial`.

**Within one unit of the currency per line, or refused.** The stated tax of a
group may differ from Ekwo's computation by at most one unit of the currency
per line of the group — 0.01 per line in a currency with cents, 1 in a
currency without (decision [0011](0011-an-amount-is-rounded-at-its-currency.md)).
`stated_tax_tolerance(company, currency, lines)` is the one place it is
written; posting and any connector that chooses a tax for a stated amount ask
it. Beyond it, posting refuses `stated_tax_out_of_tolerance` and says what to
do: check the stated tax against the source and the tax of each line, or leave
it out.

**One figure, read everywhere.** `document_tax_summary` is the breakdown every
reader asks — the totals, the tax lines of the entry and their declaration
boxes, the PDF, the electronic invoice. Its `tax_amount` is the stated tax
where the group states one, Ekwo's otherwise, and `tax_charged` follows from
it as before. The view appends `tax_amount_computed`, `stated_tax_amount` and
`line_count`, so a screen can show the gap. The base stays the base: the
difference is booked nowhere.

**Not on a price that holds its tax.** There the base is the gross less the
tax (decision [0022](0022-a-price-that-holds-its-tax.md)); a second figure for
the tax would make the base and the gross disagree. Refused,
`stated_tax_on_inclusive_price`.

**Refused at posting, not at each write.** Some callers write a draft one line
at a time, and a group is whole only once every line is there; a draft shows
the stated figure as soon as the group is whole, and posting is where it is
accepted or refused.

**A credit note gives back what was charged.** `cancel_document()` copies the
stated tax of each line, so the credit note undoes the invoice to the cent.

## Consequences

- A document that states nothing computes exactly as before: every expression
  of the view is the one it had.
- A received invoice read by `@ekwo-ai/document-reading` can carry the tax of
  each line as printed; a billing connector that only knows the three totals
  rebuilds its lines from them and states the tax it was given.
- The tolerance is per line of the group, so a group of many lines tolerates
  more: that is the drift line-by-line rounding can have, and nothing wider.

## See also

- `tests/stated_tax.test.ts`
- [0010 Amounts are positive; totals are derived](0010-amounts-are-positive-and-totals-derived.md)
- [0011 An amount is rounded at the decimals of its currency](0011-an-amount-is-rounded-at-its-currency.md)
