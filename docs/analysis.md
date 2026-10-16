# What the accounts mean to an analysis

A financial statement knows its national lines and nothing else: a rubric of
one country's balance sheet, a line of another's tax return. A ratio needs the
same figure in every country — the revenue, the equity, the current assets —
and the core is not allowed to know which accounts make them, because an
account code means one thing in one chart and another thing in the next.

So the figure has a name in the core and its accounts in the pack.
`financial_analysis(company, from, to)` returns, for one company, the
**aggregates** its country pack defines — or, where the pack defines none, the
aggregates the generic framework reads by account type — each with its amount
and the accounts that make it, and a screen computes its ratios from them: a net margin, a
current ratio, an equity ratio, days of cash, days of sales and of purchases
outstanding, growth from one period to the next.

## The aggregates

The list is closed and belongs to the core (`analysis_aggregates`). How an
aggregate is read and the sign it comes back with are part of it, so every
pack reads `revenue` the same way up; a pack says only which of its accounts
make it.

| Aggregate | Read on | Sign |
|---|---|---|
| `revenue` | movements of the period | positive when earned |
| `other_operating_income` | movements | positive |
| `purchases` — purchases and external charges | movements | positive |
| `staff_costs` | movements | positive |
| `depreciation` — depreciation, impairment and provisions | movements | positive |
| `financial_result` | movements | positive when a gain |
| `income_tax` | movements | positive when a charge |
| `net_result` — all income less all expense | movements | positive when a profit |
| `equity` | balance at the end, **with the result of every year not closed** | positive |
| `total_assets` | balance at the end | positive |
| `current_assets` | balance at the end | positive |
| `cash` | balance at the end | positive |
| `trade_receivables` | balance at the end | positive |
| `current_liabilities` | balance at the end | positive |
| `trade_payables` | balance at the end | positive |
| `long_term_debt` | balance at the end | positive |

**Movements** are what the posted entries dated from `p_from` to `p_to` added,
less the entries `close_fiscal_year()` marks `closing` — the reading of an
income statement, so a closed year still reads as what it earned. **Balances**
are cumulative to `p_to`, every posted entry included — the reading of a
balance sheet.

**Equity takes the result nobody has closed.** Until a year is closed its
result stands on the income and expense accounts, and no equity account holds
it. `equity` adds the balance, at `p_to`, of every income and expense account
its rules do not catch — the result of the earlier years not closed and of the
year in progress — and shows it on the account the close would leave it on,
the one `year_result_account()` names. After a close those accounts are nil
and nothing is added. With the books balanced, `total_assets` is therefore
`equity` plus everything else the balance sheet holds, to the cent;
`tests/financial_analysis.test.ts` and the golden of each pack hold every pack
that defines the section to it.

## The function

```sql
select * from financial_analysis(p_company_id uuid, p_from date, p_to date);
```

| Column | Type | What it holds |
|---|---|---|
| `aggregate` | `text` | the code, from the list above, in its order |
| `amount` | `numeric` | in the company currency, to its decimals, signed as the table says |
| `accounts` | `jsonb` | `[{ "code": …, "name": …, "amount": … }]`, by code: the accounts that make the amount, each with its part and the same sign; an account that comes to nothing is left out |
| `source` | `text` | `pack` or `framework`: whose reading of the accounts the rows are, the same on every row of one call — see [When the pack says nothing](#when-the-pack-says-nothing) |

One row per aggregate the company's pack defines for the chart the company
keeps its books on. A company whose pack defines none is read through the
framework instead, never through another country's chart: an aggregate read on
another country's chart would be a figure, plausible and wrong. An aggregate
that is defined and that the books do not reach comes back with `0` and an
empty list.

An account reaches an aggregate once, whatever the number of its rules that
take it, and two aggregates may take the same account: cash is part of the
current assets, which are part of the total. The part of `equity` that is the
result not closed is one entry, on the account the close would use; its `code`
and `name` are null only where the pack names no such account.

It is `security invoker` and `stable`, as `trial_balance()` is. It asks for
`entries.read` and reads the ledger with the caller's own rights. It refuses,
by name: `unknown_company` for a company that does not exist or that the
caller cannot see, `not_allowed` for a member without `entries.read`, and
`invalid_period` for a period that ends before it starts.

The same call is `EkwoClient.financialAnalysis({ companyId, from, to })` in
`@ekwo-ai/core`, typed `FinancialAnalysisRow[]`, and the tool
`financial_analysis` of `@ekwo-ai/mcp`.

## When the pack says nothing

Most country packs carry no `analysis.json`. Their companies are read through
the generic framework, `packs/generic/analysis.json`, which writes each
aggregate as a sum of **account types** — the eighteen every account carries,
whatever its chart — exactly as `packs/generic/statements.json` builds a
balance sheet and an income statement for any country. The function takes the
country pack's rows when the company's chart has any; otherwise the rows of a
framework: the framework whose statements the chart declares, else the one the
installation carries, as `default_statement_code()` falls back to the generic
statements. Every row then says `source = 'framework'`.

Thirteen aggregates are a sum of account types:

| Aggregate | Account types |
|---|---|
| `revenue` | `income` |
| `other_operating_income` | `income_other` |
| `purchases` | `expense_direct_cost`, `expense` |
| `depreciation` | `expense_depreciation` |
| `net_result` | every income and expense type: `income`, `income_other`, `expense`, `expense_direct_cost`, `expense_depreciation` |
| `equity` | `equity`, `equity_retained` — and the result not closed, as for any pack |
| `total_assets` | `asset_cash`, `asset_receivable`, `asset_current`, `asset_prepayments`, `asset_fixed`, `asset_non_current` |
| `current_assets` | `asset_cash`, `asset_receivable`, `asset_current`, `asset_prepayments` |
| `cash` | `asset_cash` |
| `trade_receivables` | `asset_receivable` |
| `current_liabilities` | `liability_payable`, `liability_current`, `liability_credit_card` |
| `trade_payables` | `liability_payable` |
| `long_term_debt` | `liability_non_current` |

**Three are not read**: `staff_costs`, `financial_result` and `income_tax`.
Wages, interest and the tax on the result are booked on `expense` and
`income_other` accounts beside every other charge and income, and no account
type tells them apart. The framework leaves them out rather than guessing, so
a company read through it gets **no row** for them, which a screen shows as
"not read" — a zero would look like a figure. For the same reason `purchases`
holds every charge typed `expense`, staff costs and interest included: the
framework reads what the types say and nothing more.

With the books balanced, the framework's `total_assets` is `equity` plus
`current_liabilities` plus `long_term_debt`, to the cent: the six asset types,
the two equity types with the result not closed, and the four liability types
are every account that carries forward, `off_balance` aside.

A country pack that writes its own section replaces this reading for the
charts it names, whole: its rows alone are read, an aggregate it leaves out
gets no row, and `source` becomes `pack`.

## Which packs define their own

| Pack | Chart | Read from |
|---|---|---|
| Belgium | `default`, PCMN | the rubrics of the abbreviated model of the annual accounts and the classes of the PCMN |
| France | `default`, PCG | the lines of the liasse 2050 to 2053 and the accounts of the PCG |
| Estonia | `default` | the lines of the balance sheet and of income statement scheme 1 of the Raamatupidamise seadus, annexes 1 and 2, and the four-class chart of the pack |

`packs/<cc>/analysis.json` says, aggregate by aggregate, which text each
reading comes from. The balance-sheet aggregates of both packs take exactly
the accounts their own balance sheet puts on the same lines, side included —
`total_assets` is the total of the assets, `equity` the equity rubric — and the
golden of each pack, `golden/analysis.json`, holds the figures of its year of
books beside the statements of the same year.

## Adding the section to a pack

A pack adds one file and touches nothing outside its folder except its seed.
The format, field by field, and what `ekwo pack check` refuses are in
[`packs.md`](packs.md#the-analysis-section); in short:

1. **Write `packs/<cc>/analysis.json`**, one entry per aggregate, with the
   rules of a statement line — `code_range`, `code_prefix`, `account_code`,
   `account_type`, and `side` where the balance sheet splits an account by
   its balance. Start from the pack's own statements: the line of the balance
   sheet that is the total of the assets *is* `total_assets`, the equity
   rubric *is* `equity`.
2. **Cite each one** in `legal_reference` — the class of the chart, or the
   line of the statement it mirrors — with the key of the register entry in
   `source`.
3. **Define at least** `revenue`, `net_result`, `equity` and `total_assets`.
4. **Raise `schema_min`** to the migration that created the analysis tables,
   `20261014152111`, and the pack's version.
5. **Run `ekwo pack build <cc>`**, then
   `UPDATE_GOLDEN=1 npm test -- tests/golden.test.ts` to write
   `golden/analysis.json`, and read it against `golden/statements.json`: an
   aggregate that mirrors a line has that line's figure.
