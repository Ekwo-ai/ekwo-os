# An analysis for every country, by account type

> Status: accepted

## Context

`financial_analysis()` returns the aggregates a ratio is computed from — the
revenue, the net result, the equity, the current assets — and reads which
accounts make each one in the company's country pack, in `analysis.json`. A
pack that carried no such section gave no row, by design: an aggregate read on
another country's chart would be a figure, plausible and wrong. Three packs
carried the section, so the companies of every other country opened an
Analysis screen with nothing on it.

Most of the sixteen aggregates do not need a chart to be read. Every account
carries one of eighteen account types, whatever its chart, and the framework
pack already builds a balance sheet and an income statement out of those types
alone (`packs/generic/statements.json`, decision 0030). The revenue is the
`income` accounts; the total assets are every asset type; the equity is
`equity` and `equity_retained` with the result not closed. Three aggregates are
not like that: staff costs, the financial result and the tax on the result are
booked on `expense` and `income_other` accounts beside everything else.

## Decision

**The framework pack carries an analysis.** `packs/generic/analysis.json`
writes thirteen aggregates as sums of account types and nothing else: the
framework has no chart, so a rule by code means nothing to it, and
`ekwo pack check` refuses one as it refuses one in the generic statements. The
schema holds the section to `$defs.framework_analysis`: no `charts`, no
`source`, `account_type` rules only. Each aggregate cites the section of IFRS
for SMEs it follows and the account types it reads.

**What no account type tells apart is left out.** `staff_costs`,
`financial_result` and `income_tax` are absent from the framework. A company
read through it gets no row for them, never a zero: a screen shows "not read",
which is true, where a zero would be a figure, and false.

**The pack first, the framework otherwise, and the rows say which.**
`financial_analysis()` reads the country pack's rows when the company's
(country, chart) has any — all of them and only them — and a framework's
otherwise: the framework whose statements the chart declares, else the one the
installation carries, first by code. This is the order
`default_statement_code()` gives the statements. A fourth column, `source`,
says `pack` or `framework`, the same on every row of one call. The function
finds the framework through `analysis_templates` and `statement_templates`; no
framework code is written in it.

**A framework's rows live in the same tables.** `analysis_templates` and
`analysis_rules` take a `framework` column, on the model of
`statement_templates`: a row is a country's and a chart's, or a framework's
with no country and no chart, and a check says it is one or the other. The
country key `(country, chart_code, aggregate)` stays a unique constraint, so
every country seed upserts as before; the framework seed upserts on
`(framework, aggregate)`, and its rules reference it through that key. A
framework's rule must be an `account_type` rule, which the table checks too.

## Consequences

- Every company has an analysis from the day it is created, in every country
  the installation carries, with thirteen figures and the accounts that make
  each one.
- A country pack that writes its own section takes over for the charts it
  names, whole: an aggregate it leaves out then gets no row, even one the
  framework would have read. A pack section is a reading of a chart, and is
  not mixed with another.
- The framework's `purchases` is every charge typed `expense` or
  `expense_direct_cost`, staff costs and interest included, because the types
  say no more. A margin computed from it is the margin of the account types.
- With the books balanced, the framework's `total_assets` equals `equity`
  plus `current_liabilities` plus `long_term_debt`, to the cent: between them
  they take every account that carries forward, `off_balance` aside.
- `financial_analysis()` returns one more column. A caller that names its
  columns reads as before; the function was dropped and created again, with
  its comment and its grants, because a return type cannot be replaced in
  place.

## See also

- `supabase/migrations/20261016065440_an_analysis_for_every_country.sql`
- `supabase/migrations/20261014152111_what_the_accounts_mean_to_an_analysis.sql`
- `packs/generic/analysis.json`, `supabase/seed/05_framework_generic.sql`
- `tests/financial_analysis.test.ts`, `tests/pack_analysis.test.ts`
- [0030 A country has charts, and a financial statement is data](0030-charts-and-financial-statements-are-data.md)
- [0025 A country is a pack of data, compiled into SQL](0025-a-country-is-a-pack-of-data.md)
- [`docs/analysis.md`](../analysis.md#when-the-pack-says-nothing), [`docs/packs.md`](../packs.md#the-frameworks-analysis)
