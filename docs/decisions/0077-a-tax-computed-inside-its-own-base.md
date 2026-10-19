# A tax computed inside its own base is one key of the tax

> Status: accepted

## Context

Some taxes are levied on a base that already contains them. The legal rate
applies to the price *with* the tax in it, so on a net amount N at a rate r the
tax is N × r / (1 − r), and on a price P that holds it the tax is P × r. The
Brazilian ICMS is the best-known case: the Lei Complementar n.º 87/1996, art.
13, § 1º, I, says that the amount of the tax itself is part of its base, "the
amount shown on the invoice being a mere indication for control"
([planalto.gov.br](https://www.planalto.gov.br/ccivil_03/leis/lcp/lcp87.htm)),
and the Federal Constitution, art. 155, § 2º, XII, *i*, requires the base to be
fixed so that the tax is part of it. The Bolivian IVA works the same way, by
article 5 of Ley N.° 843.

Two mechanisms of the schema came close, and neither says it:

- `price_include` (decision 0022) takes a tax *out* of a gross price at the
  rate over one hundred plus the rate. A pack reproduces P × r with it only by
  declaring the effective rate r / (1 − r) — 13/87 is 14.942528… — rounded to
  the four decimals of `taxes.amount`. The answer drifts: 1 000 000.00 at
  18/82 rounded to 21.9512 % carries 219 512.00 where the law gives
  219 512.20, and a price of 0.25 holding 18 % carries 0.04 where the exact
  0.045 rounds half up to 0.05. The rate printed on the invoice is not the
  rate of the law, and the base reported is the net.
- an ordinary tax adds N × r on top, which is another figure altogether.

A tax group of several taxes on one line, with one tax entering the base of
another, does not exist: the core takes one tax per line, and the `group` of
a pack is reserved and refused by the compiler.

## Decision

**A tax says `base_includes_tax: true`, and its rate stays the rate of the
law.** It is a closed, named key of the tax, like `price_include` — no
expression, no formula, no country in the core. It is a column of `taxes` and
`tax_templates`, compiled from `taxes.json` and copied onto the tax a company
installs, and a snapshot on `document_lines`, derived while the document is a
draft and kept once it is posted, like `unit_price_includes_tax` and BT-152.

**One function says how much tax a group carries.** `tax_amount_of(amount,
rate, price_include, base_includes_tax)`, unrounded, read by the breakdown
`document_tax_summary`, by the allocator of a price that holds its tax and by
the provisional net of a single line:

| | price excludes the tax | price includes the tax |
|---|---|---|
| ordinary tax | N × r / 100 | P − P / (1 + r / 100) |
| base includes the tax | N × r / (100 − r) | P × r / 100 |

The two ordinary cells are the expressions the schema always evaluated, so a
tax that does not declare the key goes through exactly the arithmetic it went
through before. The tax of a group is rounded once, at the currency (EN 16931
BR-CO-14). The two new cells are exact in `numeric`: one division, rounded
once.

**The declaration reads the base the rate was applied to.** The box of the
`base` posting of such a tax reports the net plus the tax: each ledger line
its net plus its share of the group's tax, shares cumulated in booking order
and rounded on the cumulated figure, so the boxes of one tax add up to the base
plus the tax of the group exactly. The ledger keeps the net on the account of
the line. `document_tax_summary` says the same in two appended columns,
`base_includes_tax` and `taxable_amount`.

**Three refusals, by name.** A fixed amount, and a rate of one hundred or more,
cannot be computed inside their base: the check constraints
`taxes_base_includes_tax_needs_a_rate` and
`tax_templates_base_includes_tax_needs_a_rate`, and `ekwo pack check`, refuse
them. A tax group whose lines disagree on the snapshot is refused at posting,
`mixed_base_includes_tax`.

## Consequences

- A pack states the rate of its law and the key, and gets the figure of its
  law to the cent, on a net amount and on a price that holds the tax alike.
- No pack of this repository declares the key, and the compiler writes it in a
  separate statement only for a pack that mentions it, so every seed is byte
  for byte what it was and every golden year is unchanged. A pack that retires
  the key writes `"base_includes_tax": false` on its last tax for one version,
  and the templates follow.
- The Bolivian pack keeps its effective rate until it is upgraded to the key;
  that upgrade is a change of the pack, reviewed on its own, and it moves the
  rate it publishes from 14.9425 to 13.
- An EN 16931 invoice cannot carry such a tax: BR-CO-17 requires the tax of a
  category to be its taxable amount times its rate, and the taxable amount of
  EN 16931 is the net. A country that levies one prescribes its own invoice
  format, and that format reads `taxable_amount`.
- A tax computed inside its base *and* in the base of another tax on the same
  line — the Brazilian IPI entering the ICMS base, for instance — waits for
  several taxes on one line, the reserved `group`. Until then a pack writes the
  two taxes on separate lines or says the gap in its README.

## See also

- `supabase/migrations/20261020072000_a_tax_computed_inside_its_own_base.sql`
- `tests/base_includes_tax.test.ts`
- [0022](0022-a-price-that-holds-its-tax.md) — A price that holds its tax is converted per group
- [0020](0020-one-tax-engine-several-kinds-of-tax.md) — One tax engine, several kinds of tax
- [`docs/packs.md`](../packs.md#what-a-tax-says-and-where-its-postings-land)
