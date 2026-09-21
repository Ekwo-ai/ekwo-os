# A country has charts, and a financial statement is data

> Status: accepted

## Context

A country may offer more than one chart of accounts (a company chart and an
association chart; alternative national charts). And a balance sheet printed
by code for one country is a hole in the core for every other.

## Decision

**A chart is a dimension.** `chart_templates` lists what a country offers;
`account_templates` is keyed `(country, chart_code, code)`;
`company_packs.chart_code` records the chart a company copied. The default
chart code is `default`, a mechanism word; the pack names the chart.

**Journals, taxes and the declaration form are common to a country's
charts.** Roles stay on `country_defaults`, and `ekwo pack check` refuses a
pack whose role codes and tax posting accounts are not in every chart it
ships.

**`ekwo init --chart` asks only when there is a choice**, preselecting nothing
beyond the pack's own default; non-interactively the flag is required.

**A financial statement is three tables and one function.**
`statement_templates` (a scheme), `statement_line_templates` (its lines, with
plus/minus lists for totals), `statement_line_rules` (how accounts reach a
line: code range, prefix, account type or one code).
`financial_statement(company, code, from, to)` returns the whole frame in print
order, nil lines included. A balance sheet reads cumulative balances; an
income statement reads movements.

**`balance_side` splits one account between two lines** (a suspense account
is a receivable in debit and a payable in credit). Two lines may share an
account only when their sides exclude each other.

**The pack guarantees the statement ties out.** Every postable account of a
chart reaches a line of some statement of that chart. At runtime
`unmapped_accounts()` answers the same for a company, and the MCP tool returns
that list beside the statement.

**A sign belongs to a line summed from the ledger.** `sign: -1` flips a credit
balance to print positive. Totals are computed from lines that already read the
way the scheme prints them, so `ekwo pack check` refuses `sign` (including an
explicit `1`) on a line with `plus` or `minus`; a total against the direction
of its components is a line of its own.

**Closing and appropriation entries.** An income statement leaves out
`kind = 'closing'` and `'appropriation'` entries; a balance sheet keeps both;
an allocation section reads `appropriation`. See
[0031](0031-opening-and-closing-are-parameters.md).

**The generic balance sheet derives the result; the legal ones do not.** Filing
frames show the result on the line the close put it on; the generic scheme sums
income and expense types so it balances whether or not the year is closed.

**The generic framework is a pack with no country** (`packs/generic/`), whose
rules are all `account_type`. It gives a readable balance sheet on any chart,
including code-less ones, and is the fallback for a chart without a scheme.

**Legal schemes are read off the published forms**, not off circulating tables,
which carry obsolete codes. **`xbrl_element` holds a fact key**, not an element
name: a dimensional taxonomy expresses a rubric as a metric plus dimension
members, verified against the taxonomy version, and null where unverified.

## Consequences

- A country's statutory statements are a pack section, reviewable line by line.
- A statement that does not balance is detected in the pack, not discovered in a report.

## See also

- `tests/charts.test.ts`, `tests/statements.test.ts`
- [0018 Reports read the ledger](0018-reports-read-the-ledger.md)
