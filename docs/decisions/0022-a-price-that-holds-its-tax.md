# A price that holds its tax is converted per group

> Status: accepted

## Context

Retail prices in many countries are quoted with the tax in them. A line
carrying such a tax must not have the tax added on top of what the customer
paid.

## Decision

**The group is the unit of the conversion.** For each tax group of a document
quoted gross, the tax is `round(gross − gross / (1 + rate/100))`, rounded once
at the document currency's decimals by the country's method, and the base is
the gross less that tax. That is one rounding per group (EN 16931 BR-CO-14),
which tax administrations also accept for retailers (for example HMRC VAT
Notice 700, §§ 17.5–17.6). `rounding_method` is the arithmetic of a country,
not the unit it applies to; a "per line" option would describe an invoice that
fails validation.

**The base is subtracted, never computed.** `gross × 100 / (100 + rate)`
rounded on its own, beside a tax rounded on its own, misses the gross by a unit
about once in fifty prices at 20 %. Subtracting makes `base + tax = gross`,
which is what a customer holding the receipt can check.

**The tax is never re-derived from the base.** 99,99 at 20 % gives a tax of
16,67 and a base of 83,32; 83,32 × 20 % rounds back to 16,66. So
`document_tax_summary` computes an inclusive group's tax from the gross, and
every other group exactly as before.

**The base is shared over the lines; the last takes the remainder**, as a
non-deductible share is shared over accounts.

**The line keeps the gross and the flag.** `amount_incl_tax` is the price as
quoted; `unit_price_includes_tax` is a snapshot from the tax while the
document is a draft, frozen at posting, so a pack upgrade cannot rewrite a sent
invoice. `document_line_items` and `shared_document()` publish both.

**Three refusals, each as early as possible.** A fixed-amount tax cannot be
price-inclusive (check constraint on `taxes` and `tax_templates`, and
`ekwo pack check`); an inclusive line must name its tax (check constraint); a
tax group cannot be half inclusive (`mixed_price_include`).

## Consequences

- **Known gap:** the net unit price (BT-146) of an inclusive line is not
  published. Its honest definition is base ÷ quantity at the precision of the
  price column, which `round_amount` does not express.
- Inclusive line amounts are stored at two decimals like every monetary column
  (see [0011](0011-an-amount-is-rounded-at-its-currency.md)).

## See also

- `tests/price_include.test.ts`
- [`international.md`](../international.md)
