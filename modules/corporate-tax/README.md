# Corporate income tax — estimated from the books

One Postgres schema, `tax`. It depends on the socle by foreign key, reads the
ledger through the socle's own financial statements, estimates a tax, keeps
the estimate and lets an owner call one final. It writes to the ledger once,
and only through `post_module_entry()`: the **provision** of a computation.
And it plans the **prepayments** of a year from the schedule of the pack.

Corporate income tax starts from the accounting result. Everything after that
is a rule of a country — data, in `packs/<cc>/corporate_tax.json` — plus a
handful of facts only the company can state. The engine knows no country: no
rate, no threshold, no account and no article is written in its SQL.

**This is an estimate, computed from what is booked and from a reading of the
rules. It is not tax advice and it files nothing.** Read
[`DISCLAIMER.md`](../../DISCLAIMER.md), and have a qualified professional check
the declarations of a company and its first computations.

| Name | What it is |
|---|---|
| module code | `tax` — the key of `public.modules` |
| schema | `tax` |
| capabilities | `tax.read`, `tax.write`, `tax.finalize` — their area is the module code |
| pack section | `packs/<cc>/corporate_tax.json`, with its worked examples in `packs/<cc>/golden/corporate_tax.json` |
| posts to the ledger | the provision of a computation, through `post_module_entry()` and nothing else |

## What it holds

**What a country says** — reference data, filled by `ekwo pack build`, read
where it stands and never copied into a company:

| Table | What it is |
|---|---|
| `tax.country_rules` | What the country calls its tax, the line of the income statement the computation starts from, and the accounts the tax is booked on. |
| `tax.parameter_templates` | The facts a company has to declare for a year: a judgement or an amount. |
| `tax.adjustment_rule_templates` | What is added back or deducted: a percentage, or a formula of what the company states about an expense. Dated. |
| `tax.rate_templates` | The rates, the slice each applies to and the conditions of each. Dated. |
| `tax.loss_rule_templates` | How far a loss of an earlier year may be set against a profit. Dated. |
| `tax.prepayment_templates` | When the tax is paid in advance and what each payment is worth. Dated. Read by the plan of prepayments. |
| `tax.credit_templates` | The credits a company may set against the tax. Dated. |

**What a company declares** — written with `tax.write`:

| Table | What it is |
|---|---|
| `tax.company_parameters` | The company's answer to each parameter, per financial year. |
| `tax.adjustments` | What falls under a rule: an account whose balance is read from the ledger each time, or an amount stated for one year. |
| `tax.credits` | A credit the company holds for one year. |
| `tax.losses` | The losses by year of origin: the ones the company carried in, and the ones a final computation recorded. |
| `tax.prepayments` | Each payment the company made in advance on the tax of a year, on the day it made it, and the entry that carried it if it points at one. |

**What was computed and kept** — written by three functions and by nothing
else; no role holds a write privilege on these tables:

| Table | What it is |
|---|---|
| `tax.computations` | One computation of one year as it stood on a day, numbered per year: `estimate`, `final` or `superseded`. |
| `tax.computation_lines` | Its lines, as `tax.estimate()` returned them. |
| `tax.loss_uses` | How much of each earlier loss a final computation used. |

## The functions

```sql
-- The tax of a year as the ledger stands on a day; the whole year with no day.
select * from tax.estimate(company, fiscal_year, date '2026-06-30');

-- Keep what it says as the next computation of the year.
select tax.record_computation(company, fiscal_year);

-- Call the latest one final, or take a final one back. Needs tax.finalize.
select tax.finalise_computation(computation);
select tax.withdraw_computation(computation);

-- What is left of each loss.
select * from tax.loss_stock(company);

-- Book what a computation says as the charge of its year. Needs tax.write.
select tax.book_provision(computation);

-- The instalments of a year: their days, what each is worth, what was paid.
select * from tax.prepayment_plan(company, fiscal_year, date '2026-05-01');
```

`tax.estimate()` reads and writes nothing, and answers line by line:

| `kind` | What the line says |
|---|---|
| `accounting_result` | The line of the income statement the pack names, for the period. |
| `adjustment` | One rule applied: its base, its percentage, what it moves, and the article. |
| `adjustment_not_applied` | An expense the company named under a rule that is not in force for the year. |
| `fiscal_result` | The result after the adjustments. |
| `loss_used` | A loss of an earlier year set against the profit, by its year of origin. |
| `taxable_base` | What the rates apply to. Never below zero. |
| `loss_of_period` | What the year lost, where it ended below zero: the stock a later year draws on. |
| `rate` | One rate, the slice it takes and the tax on it, with the article. |
| `rate_not_applied` | A rate whose conditions are not met, and the parameter that stands in the way: `not_declared` or `not_met`. |
| `tax_before_credits`, `credit`, `credit_not_applied` | The credits the company holds. |
| `estimated_tax` | The figure, under the only name an estimate gives it. |

## How the figure is worked out

1. **The accounting result** is one line of the income statement the pack
   names, asked of `public.financial_statement()` from the first day of the
   year to the day of the estimate. A closed year reads as it did before its
   close, because that statement leaves the closing entry out.
2. **The adjustments.** For each rule in force: what the pack's own account
   rules catch, then each account the company named, then each amount it
   stated. The base times the percentage, rounded, added back or deducted. An
   account the company names is taken out of what the pack's rules catch, so
   nothing is counted twice. Balances come from
   `public.statement_account_matches()`, which is what the statement itself is
   summed from — the two cannot disagree.
3. **The losses** of earlier years, oldest first, up to the limit the country
   sets: in full, or a floor plus a share of the profit beyond it.
4. **The base** is what is left, and never below zero. A year that ends below
   zero carries its loss in a line of its own.
5. **The rates.** Each rate in force whose conditions are all met takes its
   slice: the ones with a threshold first, lowest threshold first, then the
   one without. A condition is a test on a parameter the company declared for
   the year; **one that is not declared is not met**, and the estimate says
   which. A threshold stated for twelve months is shared out over the months
   of a shorter or longer year where the pack says so.
6. **The credits** the company holds: one that is not paid back stops at the
   tax, one that is may take the figure below zero.

Every amount is rounded by `public.round_amount()` at the decimals of the
company's currency. Percentages are `numeric`; nothing here is a float.

**An estimate during the year is the tax on the year so far**, as if it
stopped on that day. It annualises nothing and forecasts nothing: a threshold
is the year's own, and a profit of six months is taxed as the profit of the
year.

## The provision

`tax.book_provision(computation)` books the tax a computation comes to as the
charge of its year: the **expense** account of the pack against its
**payable** account, dated on the day the computation read the ledger up to,
through `post_module_entry()` on the miscellaneous journal.

It books **the difference** with what the expense account already carries for
the year up to that day, read the way the income statement reads it. A charge
the company booked by hand is counted and not booked twice; a later
computation books only what moved, on the debit side when the tax went up and
on the credit side when it came down; a computation that says what the books
already say books nothing and returns null.

- **One entry per computation.** The entry is named after it, so a second call
  returns the first entry and a third does too.
- **The latest computation of the year**, an estimate or a final one. An
  earlier version is refused as `computation_not_latest`, a withdrawn one as
  `computation_superseded`.
- **It does not move the tax.** A pack starts from a result before income tax,
  or adds the charge back by a rule on its accounts. Either way the base, the
  rates and the tax stay where they were; the golden tests book the provision
  of every worked example of every pack and hold the tax to the cent.
- In a pack that starts from the **net result**, the provision moves the
  accounting result and the rule that adds the charge back, together. A
  computation recorded before the provision is then history: record the year
  again before calling it final, or book the provision of the final one.
- It needs `tax.write`, and the right to post entries: the socle checks
  `entries.post` as it does for any entry. A closed year is refused by the
  socle too.

## The plan of prepayments

`tax.prepayment_plan(company, fiscal_year, at, tax)` reads the schedule of the
pack in force for the year and answers line by line. Each **instalment** falls
on its day of a month — of the calendar, or of the financial year, as the pack
says — on the last day of a month too short for it, and not at all when that
day is outside the year. A payment the company declared in `tax.prepayments`
counts towards the first instalment due on or after the day it was made; one
made after the last instalment is a line of its own, `paid_late`.

| Method | What the plan says |
|---|---|
| `share_of_reference_tax` | The **reference**: the final computation of the year before, or a tax the company states. Each instalment is its share of it. Under the pack's `exempt_up_to`, a line `exempt` and nothing asked. |
| `surcharge_on_shortfall` | The **tax** of the year: the latest computation recorded for it, or a tax the company states. The **surcharge** on it, what the payments already made earn against it, and **the same amount at every instalment due on or after `at`** that leaves no surcharge — rounded up to the next unit of the currency, and never more, together, than the tax still unpaid. The last line, `surcharge_left`, is what remains when the time left is too short. |

| `kind` | What the line says |
|---|---|
| `reference_tax`, `exempt` | The reference of a schedule of shares, and the exemption that applies to it. |
| `tax`, `surcharge` | The tax a surcharge is reckoned on, and the surcharge with its percentage. |
| `instalment` | One instalment: its sequence, its day, its percentage (share or credit), what to pay and what was paid towards it. |
| `total` | What the plan asks, and what was paid. |
| `surcharge_left` | The surcharge that would remain if the plan were followed. |
| `paid_late` | A payment made after the last instalment of the year. |

A year with no schedule in force is refused as `no_prepayment_rules`, a
schedule of shares with no final year before it as `no_reference_tax`, and a
surcharge with no computation of the year as `no_computation` — each with the
way out in its sentence: call the year before final, record one, or state the
tax.

## Estimate, final, superseded

`tax.estimate()` says `estimated_tax`. The words `tax_due` appear only on a
computation somebody holding **`tax.finalize`** has called final — the owner
preset holds it, the accountant preset does not. `finalise_computation()`
accepts the latest computation of a year, only if it reads the whole year, and
only while an estimate run again gives the same lines: a ledger that moved
since the recording makes the recorded computation history, and it is refused
by name, `computation_stale`.

The loss stock moves with final computations and with nothing else. A final
loss year writes its loss into `tax.losses`; a final profit year writes what
it used into `tax.loss_uses`. `withdraw_computation()` takes both back and
marks the computation `superseded` — kept, never deleted.

**The years are called final in their order, and taken back in the reverse of
it.** A later year that is already final read the loss stock as it stood, so
an earlier year is refused — `later_year_final` — until the later one is
withdrawn. A loss a final computation has used keeps its amount and its year
(`loss_in_use`).

**Nothing here locks the books.** A final computation says what the ledger
said on the day it was called final; an entry booked in that year afterwards
changes what `tax.estimate()` answers and not the final computation. Keeping
the two together is the socle's lock date and the close of the year.

## Worked examples

Four companies from four packs, chosen because each shows a different part of
the computation. Every pack that carries the section has its own in
`packs/<cc>/golden/corporate_tax.json`, with the arithmetic written out step
by step.

### A reduced rate under conditions, and a formula — Belgium

*Atelier Lumen SRL*, financial year 2025 (assessment year 2026), a small
company that meets the conditions of the reduced rate. The books show a result
before income tax of 134 675,20.

| Line | Base | % | Amount |
|---|---|---|---|
| Result before income tax (9903) | | | 134 675,20 |
| Restaurant — art. 53, 8°bis | 3 127,45 | 31 | 969,51 |
| Reception and gifts — art. 53, 8° | 1 045,30 | 50 | 522,65 |
| Fines — art. 53, 6°, from account 664100 | 250,00 | 100 | 250,00 |
| Car, diesel, 110 g — art. 66: 120 − 0,5 × 1 × 110 = 65 % deductible | 8 412,60 | 35 | 2 944,41 |
| **Fiscal result and taxable base** | | | **139 361,77** |
| Reduced rate on the first 100 000 — art. 215, al. 2 | 100 000,00 | 20 | 20 000,00 |
| Ordinary rate — art. 215, al. 1 | 39 361,77 | 25 | 9 840,44 |
| **Estimated tax** | | | **29 840,44** |

### An exemption written as slices — Singapore

*Merlion Kopi Roasters Pte. Ltd.*, financial year 2025 (Year of Assessment
2026), an established company. The partial tax exemption leaves a quarter of
the first 10 000 and half of the next 190 000 taxable, which is the standard
rate of 17 % on what is left: 4,25 % and 8,5 %. The company declares that it is
not a new start-up company, so the start-up exemption is refused.

| Line | Base | % | Amount |
|---|---|---|---|
| Profit before income tax (line 8) | | | 240 800,00 |
| Depreciation, from account 6200 | 9 500,00 | 100 | 9 500,00 |
| Private motor vehicle expenses, stated by the company | 4 200,00 | 100 | 4 200,00 |
| Capital allowances, stated by the company | 11 300,00 | 100 | −11 300,00 |
| **Fiscal result and taxable base** | | | **243 200,00** |
| Partial exemption, first 10 000 | 10 000,00 | 4,25 | 425,00 |
| Partial exemption, next 190 000 | 190 000,00 | 8,5 | 16 150,00 |
| Start-up exemption | | | not applied — `not_met: new_start_up_company` |
| Standard rate | 43 200,00 | 17 | 7 344,00 |
| **Estimated tax** | | | **23 919,00** |

### One rate for every company, and a limit on losses — United States

*Redwood Freight Holdings, Inc.*, financial year 2025, federal tax only. It
carries 700 000 of losses from 2023 and 500 000 from 2024, and the losses of
earlier years may take 80 % of the income of the year.

| Line | Amount |
|---|---|
| Income before income tax expense (line 10) | 1 149 500,00 |
| Meals, 50 % of 48 000 — 26 U.S.C. § 274(n) | 24 000,00 |
| Entertainment — § 274(a) | 14 500,00 |
| Amount paid to a government — § 162(f) | 18 000,00 |
| State income tax of the year, stated by the company — § 164(a)(3) | −56 000,00 |
| **Fiscal result** | **1 150 000,00** |
| Limit on losses — § 172(a)(2): 80 % × 1 150 000 | 920 000,00 |
| Loss of 2023 used | −700 000,00 |
| Loss of 2024 used, 280 000 left | −220 000,00 |
| **Taxable base** | **230 000,00** |
| Federal rate, 21 % — § 11(b) | 48 300,00 |
| **Estimated tax** | **48 300,00** |

### A rate refused, and a floor before the limit — France

*Négoce Atlantique SAS*, financial year 2025. Its capital is not held at 75 %
by individuals, so the reduced rate is refused; it carries 900 000 of losses
from 2023 and 600 000 from 2024.

| Line | Amount |
|---|---|
| Accounting profit (HN) | 1 399 120,00 |
| Fines, from account 671200 — CGI art. 39, 2 | 880,00 |
| **Fiscal result** | **1 400 000,00** |
| Limit on losses — CGI art. 209, I: 1 000 000 + 50 % × 400 000 | 1 200 000,00 |
| Loss of 2023 used | −900 000,00 |
| Loss of 2024 used, 300 000 left | −300 000,00 |
| **Taxable base** | **200 000,00** |
| Reduced rate | not applied — `not_met: held_75_percent_by_individuals` |
| Standard rate, 25 % — CGI art. 219, I | 50 000,00 |
| **Estimated tax** | **50 000,00** |

All four are replayed to the cent, with every other company of every pack
that carries the section, by [`tests/golden.test.ts`](tests/golden.test.ts).

## For an accountant to read

Ten things here are a reading of the mechanics or a limit of this version,
and an accountant should say whether each is acceptable for the company. What
a country's section leaves out, and why, is in the README of its pack.

1. **Only what is declared is adjusted.** A pack adds back by itself only
   what a chart keeps on an account of its own — a tax charge, fines where
   they have their account. Everything else waits for the company to name an
   account or state an amount: a chart that books two expenses with two
   treatments on one account cannot say which is which.
2. **A condition is the company's word.** "Small company", "new start-up
   company", "held at 75 % by individuals", the remuneration of a director:
   none is checked against the books. The estimate applies a reduced rate
   because the company said so.
3. **One limit for every loss.** A country that limits losses differently by
   their year of origin, or that limits several carried-forward deductions
   together, is computed for its losses under the rule in force for the year,
   and for nothing else in the basket.
4. **A rule takes one figure.** A deduction that depends on two figures of
   one expense — the price of a vehicle and its emission — is left to the
   company to state; the pack cites the article.
5. **No tax on a tax, no minimum tax, no local rate.** Surtaxes computed on
   the tax, minimum taxes on turnover or on group income, and the taxes of a
   state, a province or a municipality on the same profit are outside this
   version. None applies to a small company with an ordinary year in most
   countries, and all of them apply to somebody.
6. **A credit is an amount the company states.** A credit that is a share of
   the tax, with or without a ceiling, is not computed.
7. **Figures are kept at the cent.** A country that files its base and its
   tax rounded to the unit says so on its form; forms are a later version.
8. **The provision is one account against one.** The charge goes to the
   pack's expense account and the debt to its payable account; what the
   company paid in advance stays where it booked it, and setting the two off
   at the close is the company's entry.
9. **A plan of shares reads one reference: the year before.** A country whose
   first instalment rests on an older year and is put right later, or whose
   reference is the last year whose deadline has passed, is planned on the
   final tax of the year just before, or on the tax the company states.
10. **A surcharge is the pack's percentage of the tax.** A threshold under
   which no surcharge is due, an exemption for the first years of a small
   company, a bonus for paying more than the surcharge asks, and a day moved
   because it falls on a holiday are outside this version; the pack cites the
   articles.

## Rights

| Capability | Holds it by default | Lets somebody |
|---|---|---|
| `tax.read` | viewer, client, accountant, owner | read the declarations, the estimates and the final computations, and run `tax.estimate()` |
| `tax.write` | accountant, owner | declare parameters, adjustments, losses, credits and payments made in advance; record an estimate; book its provision |
| `tax.finalize` | owner | call a computation final, or withdraw one |

Recording and finalising run the estimate, so both need `tax.read` as well: a
key or a member given `tax.write` alone is told so by name.

Every policy asks `module_enabled(company_id, 'tax')` first: a company that
has not enabled the module sees none of it, and neither does a stranger.
Disabling hides the rows and deletes nothing.

## Enabling it

```sh
ekwo module migrate tax          # its migration and its country seeds
ekwo module enable tax --company "…"
```

`tax` is the module code; the folder name, `corporate-tax`, is accepted as
well. Then add `tax` to the project's exposed schemas — Supabase dashboard →
Project Settings → API, or `[api] schemas` in `supabase/config.toml`. No
migration can do that: it is a setting of the API and not of the database.

An installation that already exists gets the module by upgrading as for any
release: `ekwo migrate` applies the migrations of the module —
`20260930104417_corporate_tax.sql` first, then the later ones, such as
`20261010073000_tax_provision_and_prepayments.sql` for version 1.1.0 — after
the socle's migrations, then the seeds under
`supabase/seed/modules/corporate_tax/`. Nothing of the socle changes, and no
company is touched until it enables the module.

## What is not here yet

- The declaration forms.
- MCP tools.
- A country other than the ones whose pack carries a `corporate_tax.json`. A
  company of any other country is refused by name, `no_corporate_tax_rules`,
  rather than given a neighbour's rates. [`docs/packs.md`](../../docs/packs.md)
  says how a pack writes the section.
