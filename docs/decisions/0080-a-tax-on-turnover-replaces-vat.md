# A regime where one tax on turnover replaces VAT

> Status: accepted

## Context

Many small companies are not VAT payers. Their country puts them under a
regime that replaces VAT with one tax computed on what they sold: a flat
percentage of the turnover of the month or the quarter, or a rate graded by
brackets of the turnover of a trailing year — the effective rate of a bracket
being (base × nominal rate − deduction) / base, applied to the turnover of the
period. Their invoices carry no VAT, their purchases give back none, and the
return they file is the one of that tax. Such regimes exist under many names,
for micro-enterprises, simplified taxpayers and small traders.

The core had none. The VAT engine computes a tax per line and the periodic
return sums the lines' boxes; nothing computed a tax on a period's turnover,
and nothing kept a company that pays one from charging VAT. Packs said so in
their README and let such a company install the VAT payer's taxes and use
none of them.

## Decision

**A regime is pack data; a company declares it by whole financial years; its
tax is computed on the ledger's turnover and posted once per period.**

- `turnover_tax.json` declares each regime: its code and name, the kinds of
  tax it replaces (`replaces`, the closed `tax_kind` vocabulary), the form it
  is declared on — its own row of `tax_report_templates`, not the periodic
  return, with its cadence and deadline — the account its tax is an expense
  on, the trailing window its bracket is read over (`window.months`,
  `window.includes_period`, `window.short`), and its brackets: `up_to`
  (inclusive; left out on the last), `rate`, `deduction`, each dated and
  cited. There is no expression: a flat rate is one bracket with no threshold
  and no deduction. It compiles into `turnover_tax_regimes`,
  `turnover_tax_brackets` and the form, written only for a pack that carries
  the file.
- `company_tax_regimes` is the company's declaration, from the first day of a
  financial year and to the last day of one, or open-ended. A change in the
  middle of a year is **refused** (`regime_change_mid_year`), two regimes on
  one day too (`regime_overlap`). Recording a regime records the cadence of
  its form in `company_filing_periods`.
- Under the regime a document whose line carries a tax of a replaced kind is
  refused at posting, `tax_replaced_by_regime`: the line is booked without it.
- The turnover of a period is what posted sale invoices and credit notes
  dated in it put on the income accounts, credit less debit, in the company's
  currency. A credit note lowers the turnover of its own period.
- The base the bracket is read on is the turnover of the window. A company
  active for fewer months than the window counts — from the first month of its
  first financial year — has it annualised (the turnover of the months it has,
  times the window's months over their number; in its very first period, the
  period's own turnover annualised), or read as it is where the pack says
  `as_is`.
- `turnover_tax_return()` returns the arithmetic line by line and writes
  nothing. `post_turnover_tax()` posts the tax on the regime's expense account
  against the account the pack names for what a declaration owes, prepares
  the period's filing on the regime's form and keeps the figures in
  `turnover_tax_assessments`, once per period. The tax is rounded once, at
  the unit of the form; the effective rate is kept unrounded.
- `upcoming_filings()` lists the regime's form and leaves out the periodic
  VAT return for the periods a regime replacing VAT covers entirely.

Nothing in the schema names a country, a regime or a rate.

## Consequences

- No pack of this repository carries the file yet: every seed is byte for
  byte what it was, and every golden year is unchanged.
- A company that leaves the regime in the middle of a year — because its
  turnover crossed a ceiling, where its law moves it out at once — cannot say
  so yet; the refusal names the case. Ceilings that move a company out of the
  regime, and the tax of the excess, are not modelled.
- A company with activities on several tables of the same regime — the annexes
  of a regime graded by activity — is under one regime at a time; the split of
  turnover by activity is not modelled.
- A period whose credit notes outweigh its sales owes nothing, and the
  difference is not carried to the next.
- The filing it prepares carries no boxes: the figures are the assessment's,
  and `filing_drift()`, which reads the VAT return, does not apply to it.

## See also

- `supabase/migrations/20261020090000_a_tax_on_turnover_replaces_vat.sql`
- `tests/turnover_tax_regime.test.ts`
- [0019](0019-tax-postings-carry-the-account-and-the-box.md) — A tax posting carries the account and the box
- [0025](0025-a-country-is-a-pack-of-data.md) — A country is a pack of data
- [`docs/packs.md`](../packs.md#a-tax-on-turnover-in-the-place-of-vat-turnover_taxjson)
