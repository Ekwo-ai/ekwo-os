# One tax engine, several kinds of tax

> Status: accepted

## Context

European VAT — fully deductible, computed on a price that excludes it — is one
case. GST, sales tax, withholding, partly deductible VAT and tax-inclusive
prices are others. The pack format has words for all of them (`kind`,
`recoverable`, `price_include`, `jurisdiction`, `cash_basis`,
`rounding_method`, `cash_rounding_unit`), and each needs a column the engine
reads, or an explicit statement that nothing reads it yet.

## Decision

**A kind is a label, never an input to the calculation.** `tax_kind` is
`vat | gst | sales_tax | withholding | other` and drives reports only. A GST is
computed like a VAT. `recoverable` and `jurisdiction` likewise say what a tax
*is*, so nothing guesses it from a code.

**Non-deductible VAT is a cost, booked on the line's own account.**
`tax_posting_type` gains `tax_on_base`: like `base` it carries no account (the
document line names it); its amount is a share of the tax. Example: a Belgian
company car at 21 % with deduction capped at 50 % books 1 000 on the vehicle,
105 on deductible VAT, 105 more on the vehicle, 1 210 to the supplier; box 83
reports 1 105 (base plus the non-deductible share) through
`box_factor_percent`, with no new column.

**A `tax_on_base` line is not a tax line.** It sits on a base account and
belongs to the base side of the declaration; `tax_line = true` would split one
grid into two rows.

**The postings of one side share out the tax of the group; the last takes the
remainder.** The group's tax is rounded once (BR-CO-14) and shared: 3,00 at
21 % is 0,63, shared 0,32 and 0,31 — rounding 0,315 twice would book 0,64
against a document totalling 3,63. The same rule spreads a `tax_on_base` share
over several accounts in proportion to their bases.

**A declaration figure is not a ledger figure.** Box amounts round per
posting, so on that 3,00 invoice the ledger books 0,31 where box 82 reports
0,32. Only the ledger has to balance; letting a grid drive a posting is the
alternative refused.

**No country is anybody's default.** A pack says how its country rounds; a
pack that says nothing gets the column's own neutral default (`half_up`,
`recoverable = true`, `tax_kind = 'vat'`), and the compiler writes `default`
rather than a value of its own, so the CLI never becomes a second place where a
country model is decided. `tests/tax_on_base.test.ts` also refuses a country's
*answer* used as a fallback.

**Columns may land before their reader** when adding them later would mean
migrating a table of years of rows a second time — and the column's comment
says it has no reader yet.

**Adding a tax is a minor pack version**, and a test proves nothing that
existed changed: after-state narrowed to the natural keys of the before-state,
new codes named in a test of their own.

## Consequences

- A new kind of tax is a label and postings, not a code path.
- Box figures and ledger figures may differ by rounding, by design.

## See also

- [0021 Cash-basis VAT and realised exchange differences](0021-cash-basis-vat-and-realised-exchange-differences.md)
- [0022 A price that already holds its tax](0022-a-price-that-holds-its-tax.md)
- `tests/tax_on_base.test.ts`
