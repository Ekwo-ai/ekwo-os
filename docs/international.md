# Ekwo OS beyond Belgium and France

> The plan for making the core usable in any country. The format of a country
> pack — the one taxonomy in this plan that will not get to be redone — was
> settled first, before any code was written, and is recorded in
> [`decisions.md`](decisions.md). This document is the map; that decision is
> the first step on it.

## The premise

A country is data, not code. Odoo ships one Python module per localisation;
Xero and QuickBooks ship one product per market. Ekwo ships **one core and
one versioned pack per country**, and a pack is something an accountant can
read, a contributor can propose in a pull request, and a test can prove.
Everything below follows from that.

Where the core stands today, phase 0 being done: 18 account types shared with
Xero, QuickBooks and Odoo; taxes, their postings and the boxes of a declaration
as rows a pack fills; financial statements as rows too, with a country-less
framework behind any chart that prescribes none; EN 16931 fields as columns;
the French FEC; XBRL for the Belgian NBB; Factur-X; a REST API and an MCP
server; row level security everywhere. The seven file formats — the French FEC,
the Belgian CBSO taxonomy, Factur-X, and the four recapitulative statements
added with `ec_sales_list()` — are MIT packages under
[`packages/formats/`](../packages/formats/), organised by format and never by
country.

**No function of the core holds a country code, and a test enforces it.**
Belgium, Estonia, France, Luxembourg, the United Kingdom and the United States
are six directories under [`packs/`](../packs/) and six compiled seeds, each
carrying a year of books and the figures it produces. The fifth is the first
that is not a Member State of the Union, and the sixth is the first that levies
no value added tax at all; both were written for that reason.

## What an international core needs and does not have

The list this plan started from, with what phase 0 closed and what it did not.

| Gap | Where it stands | Why it matters outside Belgium and France |
|---|---|---|
| No pack object | **Closed.** `packs/<cc>/` compiled into a committed seed, versioned, with `country_packs` and `company_packs` recording what an installation and a company hold | UK, US or Canada would each add a third place where a country lives |
| Nothing on the invoice itself | **Closed.** Numbering and its pattern, the legal payment term, the tax point, the e-invoicing profile, the bank formats and the legal mentions are pack data, each rule citing the article that imposes it | Every country prescribes different sentences on an invoice, and a renderer that hard-codes them is a renderer per country |
| No year-end close, no opening balances | **Closed.** `opening_balance()`, `close_fiscal_year()`, `reopen_fiscal_year()` and a `closing_style` the pack declares; shifted and 52/53-week years were always covered by `fiscal_years` | UK years run April to March; US retail runs 52/53 weeks; every migration starts with an opening balance |
| Currencies without realised gains or revaluation | **Half closed.** A matching that realises an exchange difference books it on the accounts the pack names; revaluation of open items is still out | Mandatory the day a company invoices outside its functional currency |
| Accrual only | **Half closed.** A tax can fall due on collection, which is what French services needed; cash accounting as a ledger is still out | UK and US small businesses report on a cash basis; French VAT on services is due on collection; the UK has a cash accounting scheme |
| A tax engine that knows only EU VAT | **Closed except stacked taxes on one line.** Kind, recoverability, jurisdiction, tax-inclusive prices, non-deductible VAT on the account of the line it taxes, rounding method per country | GST with input credits (Canada, Australia, Singapore); stacked taxes on one line (GST + QST in Québec, phase 1); non-recoverable sales tax (US, Canadian PST); withholding (Spain, Italy, Portugal); tax-inclusive pricing (UK, Australia retail) |
| No cash-flow statement | **Open**, and deliberately: `statements.json` already accepts `cash_flow` as a kind, and no pack here prescribes one | Expected before tax compliance in the English-speaking world |
| Nothing proved a pack against figures | **Closed.** A golden year of books per pack, and a legal source required on every tax and every box | A pack that cannot be wrong in a way anyone notices is a pack nobody can review |

## Four phases

### Phase 0 — a complete, country-agnostic core — **done, 14 September 2026**

The phase that decides everything. Nothing country-specific was added until it
was done. The format of the pack was decided on 12 September 2026 and is
written up in `decisions.md`; the twelve steps below were its execution order,
and they recut the first list in three places: opening balances came first
because they blocked adoption in Belgium and France; cash-basis VAT came
before any new country because the French pack was wrong for services; the
cash-flow statement, the revaluation of open items and several taxes on one
line wait for the countries that need them.

All twelve are delivered and shipped in `v0.2.0`. What that buys is narrow and
worth stating plainly: a country can now be described entirely in data, checked
by a tool, replayed against a year of books, translated, versioned and upgraded
in place — and a third country adds no place where a country lives. It does not
buy a third country, which is phase 1.

1. Pack format and compiler; Belgium and France extracted into `packs/`. **Done.**
2. The pack migration: `country_packs`, `company_packs`, translated labels,
   seeds that upsert the template tables. **Done.**
3. Declaration boxes as data, a generic `vat_return()`. **Done** — the boxes
   and their plus/minus formulas live in `tax_report_templates` and
   `tax_report_box_templates`, filled by the pack; the Belgian 71/72 and the
   French CA3 totals are pack data, and no function in the core holds a
   country code any more, which a test now enforces.
4. Financial statements as data, a generic statement by account type.
   **Done** — `statement_templates`, `statement_line_templates` and
   `statement_line_rules` filled by the packs, `financial_statement()` and
   `unmapped_accounts()`; the NBB abbreviated schemes and the French liasse
   2050-2053; a country-less `packs/generic/` whose rules are all account
   types, which gives any chart a balance sheet that ties out. A country also
   gained **several charts of accounts** — `chart_templates`, `chart_code` on
   the template accounts and on `company_packs`, `ekwo init --chart` — with
   the Belgian association chart as the first second chart.
5. The generalised tax engine: kind, recoverability, jurisdiction,
   tax-inclusive prices, non-deductible VAT, rounding rules. **Done**
   (12 September 2026): `tax_kind`, `recoverable`, `jurisdiction`,
   `price_include`, `cash_basis` on the taxes and their templates;
   `rounding_method` and `cash_rounding_unit` on the country model; the
   `tax_on_base` posting, which books non-deductible VAT on the account of the
   line it taxes. Belgian cars at 50 % and French fuel at 80 % are in the
   packs. The gross-to-net computation of a tax-inclusive price and the
   behaviour of `cash_basis` are not: the first waits for the country that
   sells that way, the second is phase 6.
6. Cash-basis VAT and realised exchange differences. **Done**
   (12 September 2026): `post_document` books a cash-basis tax — and the base
   it is computed on — on the transition account the pack names and on no
   declaration box, and `reconcile()` moves the settled share, pro rata and
   cumulative, to the account and the box it is declared on. `post_document`
   and `post_payment` convert to the company's currency and write
   `amount_currency`, which nothing did before, and a matching between two
   lines in the same foreign currency books the realised difference on
   `fx_gain_code` / `fx_loss_code` of the country model. The French pack gains
   the six services taxes that fall due on collection; the option for the
   debits is the tax that was already there. Out of scope and staying out:
   revaluation of open items, and cash accounting as a ledger.
7. Document rules, e-invoicing profiles and bank formats as data. **Done**:
   twenty columns on the country model — gapless numbering and the
   number pattern, the legal payment term and where its interest comes from,
   the tax point, the e-invoicing profile and the day it becomes obligatory,
   the ISO 6523 party and VAT schemes, the bank statement and payment
   formats, the usual opening of the financial year, and the article behind
   four of those rules with the register entry it is read at — plus
   `legal_mention_templates`, the sentences a country requires on an invoice
   with a closed vocabulary of nine conditions. `document_legal_mentions`
   decides which of them apply to one document from its country, its date and
   the treatments of the taxes on its lines; `document_line_items` gained the
   treatment and the exemption reason. Nothing executable: no function was
   added, and the numbering engine still builds its own number — the pattern
   is declared so that the engine which reads one changes nothing when it
   arrives.
8. Opening balances and a parameterised year-end close. **Done** —
   `opening_balance()`, `close_fiscal_year()`, `reopen_fiscal_year()`, and
   `closing_style` with its four account roles in the pack.
9. Pack versioning, `ekwo pack upgrade`, an append-only audit log. **Done** —
   `country_packs` and `company_packs` carry the versions, `ekwo pack status`
   and `ekwo pack upgrade` diff by natural key and apply only an addition and
   a closed validity, and `audit_log` records every change to the
   configuration of a company and every act that changes a state. The ledger
   itself is not audited: a posted entry is immutable and is corrected by a
   reversal.
10. One golden test per pack, a certification status. **Done** — each pack
    carries `golden/scenario.json`, a year of at least ten documents with the
    payments that settle some of them, and beside it the declaration, the
    statements and the trial balance the engine makes of it, to the cent.
    `tests/golden.test.ts` is one runner with no country in it: what it asks of
    a scenario, it asks of that scenario's own pack. A pack with no golden is
    refused unless its manifest says why. `legal_reference` became **required**
    on every tax and every box, and `certification.status` — `community`,
    `maintained`, `reviewed` — is printed by `ekwo init` before a company is
    created. There is no status meaning "certified by Ekwo": writing a pack is
    not reviewing it. The first run reported two defects in the French pack
    rather than adjusting the golden to match them.
11. End-to-end test, including an upgrade from the published version. **Done** —
    `tests/e2e/` installs the same release twice, once through the CLI's runner
    and once the way `supabase db push` and `psql -f` do, and compares every row
    of every table the seeds write; then it takes a company installed at the
    previous version, upgrades its pack, replays that pack's own golden
    scenario, files the declaration, prints both statements, closes the year,
    re-opens it and closes it again — comparing every figure to one it works
    out itself from `sum(debit) - sum(credit)`. `npm run e2e:supabase` covers
    what PGlite cannot reach: the published binary over a pooler connection,
    PostgREST, GoTrue and a hosted project's extensions.
12. Documentation: `docs/packs.md`, the contributor's guide. **Done** —
    [`packs.md`](packs.md) is the format file by file, the compiler, every rule
    `ekwo pack check` applies, the certification policy and a walkthrough for
    adding a country in a day; [`CONTRIBUTING.md`](../CONTRIBUTING.md) carries
    the invariants a country pack may not break; and the installation
    documentation names the four things an operator has to do on their own
    project, which `ekwo init` prints at the end of a successful run.

The original six-item list, for the record:

1. **The country pack format** — chart of accounts with translations, taxes
   and boxes, financial-statement mappings per framework, document rules,
   e-invoicing profile, bank formats, defaults; versioned; installed by a
   generalised `install_country_template`; **one golden test per pack**:
   ten posted documents, every box and every statement line to the cent.
   Belgium and France become the first two packs, which purges the core of
   what was theirs.
2. **Year-end close and periods** — result allocation, opening entries,
   monthly or 13 periods, shifted and 52/53-week years, opening balance
   import.
3. **Multi-currency, properly** — functional currency per company, realised
   gains and losses at matching, periodic revaluation of open items and of
   foreign-currency bank accounts.
4. **Cash basis alongside accrual** — reports derived from payments; VAT on
   collection (French services, the UK cash accounting scheme).
5. **Cash-flow statement, immutable audit log, translated labels.**
6. **A generalised tax engine** — a tax declares its kind (VAT, GST, sales
   tax, withholding, excise), whether it is recoverable, what it is computed
   on, whether prices include it, its jurisdiction, and its rounding rule.
   Reverse charge is already there.

### Phase 1 — first wave (first quarter of 2027)

- **Estonia** — **done, 14 September 2026**, and out of order: a small VAT
  system with a rate that moved twice in eighteen months, no legal chart of
  accounts, and a return that nests its boxes. It was picked to test the format
  against a country nobody designed it for, and the six gaps below are what it
  returned. A seventh — that a seed's file name was the country's alphabetical
  rank, so adding one renamed the seeds of every country after it — was fixed
  rather than recorded, because leaving it would have meant shipping the
  damage.
- **United Kingdom** — **done, 15 September 2026**, and the first pack of a
  country outside the Union: no intra-Community tax on either side, retail
  prices quoted with the tax in them, an exemption the European code lists have
  no code for, and a nine-box return that prints one amount in two boxes at
  once. A British-style chart mapped onto the statutory small-company formats,
  the nine boxes of the VAT Return, FRS 102 for the fixed assets, and the gaps
  listed under "From the United Kingdom" are what it returned — the first two
  of them closed the same week. Northern Ireland,
  Making Tax Digital submission and the VAT schemes are out of its scope.
- **Ireland** — a chart of accounts and form VAT 3; the pack format has
  everything it needs since the United Kingdom landed.
- **Canada and Québec** — GST, HST and QST stacked per line, PST as a
  non-recoverable tax in British Columbia, Saskatchewan and Manitoba, two
  administrations (CRA and Revenu Québec), bilingual labels, a QuickBooks or
  Sage 50 style chart, shifted years. **Rates live in the pack**: fifteen or so
  stable combinations published by the CRA are data, not the thousands of
  monthly-changing American jurisdictions that belong to a feed. It comes
  **before the United States**: closer to the accounting model this core was
  built on, and a test of the tax model that the US does not offer.
  `report_code` on the postings and `region` on companies and contacts were
  built in phase 0 so that this pack migrates nothing twice.
- **Netherlands, Germany, Luxembourg** — RGS, SKR03/04 with XRechnung, PCN.
  **Luxembourg is done**, as `packs/lu/`, and is described below.
- **United States** — **done, 16 September 2026**, and out of order for the
  same reason Estonia was: it is the country that tests what the format assumes
  about a *tax*. Every pack before it, the British one included, described a
  value added tax — levied nationally, reclaimed by the buyer, declared on one
  form. Here the tax is levied by the states and by thousands of districts under
  them, the buyer never gets a cent of it back, there is no national return and
  no legal chart of accounts. A chart written against Regulation S-X, sales and
  use taxes for three states chosen for what each demonstrates, California's
  thirty-nine-line return, and the gaps listed under "From the United States"
  are what it returned. Cash-basis reports, 1099 fields, the other
  forty-five states and every return but California's are out of its scope, and
  the rates of American jurisdictions remain what the decision below says they
  are: a feed, not a pack.
- **Formats** — Peppol PINT and UBL 2.1 as the universal invoice; OFX, BAI2,
  MT940 and camt.053 bank parsers (camt.053 is read: `@ekwo-ai/camt053`). MIT packages under `packages/formats/`,
  one per format: camt.053 is no more European than UBL is universal, and
  neither is a country.

### Phase 2 — GST countries and southern Europe (mid-2027)

Australia and New Zealand (BAS), Singapore; Spain, Italy and Portugal
(withholding, FatturaPA, SII); consolidation across companies; iXBRL accounts
for Companies House.

### Phase 3 — the community makes the countries

A contribution kit for a pack with its golden test, a status page per
country, a reviewed-pack label. Odoo's localisations are code; Ekwo's are
data, contributable without touching the core.

Part of this arrived early, as a by-product of phase 0: the golden runner takes
any pack, `ekwo pack check` tells a contributor what is wrong in their own
terms, the three certification statuses exist and `ekwo init` prints the one it
is installing, and [`packs.md`](packs.md) walks through adding a country. What
is missing is the outside of it — a page that shows the state of every pack,
and enough contributed packs for the question to be interesting.

## The packs, country by country

| Country | Pack | Status | Out of scope, and why |
|---|---|---|---|
| Belgium | `packs/be/` | `maintained` | — |
| Estonia | `packs/ee/` | `community` | KMD INF, the § 44 cash-accounting scheme, the fixed-asset rules, the XBRL fact keys of the annual report, and versions of form KMD before 1 July 2025 |
| France | `packs/fr/` | `maintained` | — |
| Luxembourg | `packs/lu/` | `community` | the eCDF XML of the periodic return, the FAIA audit file, the annual VAT return, the special regimes, and corporate income tax |
| United Kingdom | `packs/gb/` | `community` | Northern Ireland and the `XI` prefix, Making Tax Digital submission, the flat rate, cash accounting, annual accounting, margin and retail schemes, partial exemption, the Construction Industry Scheme return, corporation tax and capital allowances, the medium and large formats of S.I. 2008/410, and iXBRL for Companies House |
| United States | `packs/us/` | `community` | forty-five other states with a sales tax and every return but California's, district rates by address, the local taxes Alaska, Colorado and Louisiana administer themselves, the Streamlined Sales and Use Tax Agreement, sales tax on services, marketplace facilitator rules, federal and state income tax, MACRS, and Inline XBRL for the Securities and Exchange Commission |

### Estonia

Written from the outside in, against a country nobody had designed the format
for, and picked because it is small enough to finish and awkward enough to be
interesting: a standard rate that moved twice in eighteen months, a reduced
rate that went 9 %, 5 % and 9 % again, a return whose boxes nest three deep,
and **no legal chart of accounts at all**.

It carries an original chart of 120 accounts, 29 taxes with the rate history
back to 2009, form KMD as it stands since 1 July 2025, and the balance sheet
and income statement scheme 1 of the annual report. Three things are worth
knowing beyond the pack's own [`README`](../packs/ee/README.md):

- **The chart is written, not transcribed.** The Accounting Act obliges every
  entity to draw up its own, so there is no text to copy. The pack follows the
  convention Estonian practice shares — four digits, four classes, equity
  inside class 2 — and blocks the codes so each range maps onto one line of the
  statutory schemes.
- **No tax provision is booked at the close, and that is the law.** Estonia
  taxes distributed profit, not earned profit. `closing_style` is
  `result_accounts` because the statutory balance sheet keeps the year's result
  on a line of its own until the shareholders allocate it.
- **It is `community`.** Nobody who files an Estonian return has read it, and
  the pack's README ends on the four points a reviewer should look at first.

### Luxembourg

The third pack, and the first written from published sources alone rather than
from a running installation. It carries the **plan comptable normalisé** of the
*règlement grand-ducal du 12 septembre 2019* whole — 1 026 accounts, 747 of them
postable — the four VAT rates of article 39 with the temporary 2023 rates beside
them, the 156 numbered fields of the eCDF periodic return, and the two abridged
schemes of annual accounts keyed by their own eCDF field identifiers.

Three things about it are worth knowing beyond the pack's own
[`README`](../packs/lu/README.md):

- **The State publishes the mapping.** The annex that carries the chart carries
  the *tableau de passage* as well: which line of the abridged balance sheet or
  of the abridged profit and loss account each account reports in. The pack
  transcribes it account by account, so every postable account reaches exactly
  one line without anybody inferring a range.
- **It is `community`.** Nothing here was read by a Luxembourg accountant, and
  the pack's README ends on the ten points a reviewer should look at first.
- **Out of scope, on purpose.** The eCDF XML of the *periodic return*, the FAIA
  audit file, the annual VAT return (a different form with fields of its own),
  the franchise and VAT-group regimes, the full unabridged schemes and their
  notes, and the `tax` module. The first of those is a format library and not a
  pack; the rest wait for somebody who files them. The eCDF envelope itself is
  written by [`@ekwo-ai/ecdf`](../packages/formats/ecdf/) since the
  recapitulative statement arrived, which is what the distinction looks like in
  practice: an envelope is a format, the boxes of a return are a pack.

### United Kingdom

The fifth pack, and the first of a country that is **not** a Member State of
the Union. It was written for that reason: every pack before it could lean on
the VAT Directive, on the intra-Community mechanism and on the European code
lists, and nobody knew how much of the format silently assumed them.

It carries an original chart of 190 accounts, 25 taxes with the standard rate
back to the commencement of the Value Added Tax Act 1994, the nine boxes of the
VAT Return as they stand since 1 January 2021, the balance sheet and the profit
and loss account of the small companies regime, and the usual lives of a fixed
asset under FRS 102. Four things are worth knowing beyond the pack's own
[`README`](../packs/gb/README.md):

- **There is no legal chart of accounts, and no legal statement schemes
  either — there are legal *formats*.** Companies Act 2006, s. 396 requires the
  accounts to comply with regulations as to their form and content, and those
  regulations prescribe the lines of the balance sheet and of the profit and
  loss account letter by letter. So the statements of this pack are
  transcribed, exactly as Luxembourg's are, while the chart underneath them is
  written: the codes are the four-digit convention a British nominal ledger
  uses, blocked so that each range reaches one item of Schedule 1 Format 1.
- **Nothing here is intra-Community, on either side.** Since 1 January 2021 a
  supply from Great Britain to a Member State is an export and an arrival is an
  import, so four of the eleven treatments never occur. What replaced them is
  postponed VAT accounting, which the pack models as an `import` posting to
  boxes 1, 4 and 7 that nets to nothing in the ledger.
- **Northern Ireland is deliberately absent.** The Windsor Framework keeps it
  inside the Union's rules for goods under one registration with Great Britain,
  and boxes 2, 8 and 9 of the return are about that trade alone. They are
  declared and empty; see the last gap below for why the pack could not carry
  them.
- **It is `community`.** Nobody who files a British return has read it, and the
  pack's README ends on the points a reviewer should look at first. The first
  two of them were the exemption reason code this pack had to invent and the
  Union's export code it had to borrow; both are gone with pack version 0.1.1,
  which leaves no `exemption_code` on any British tax.

## What a new country shows the core cannot say

### From Luxembourg

A country pack is a test of the format as much as of the country. Four things
the Luxembourg pack had to work around, with what would fix each. None was
implemented for Luxembourg's sake — a gap the core has is a core issue, and
patching the core for one country is what this format exists not to do. Three
were closed on their own merits, a day later and for every country; the fourth
waited until a third pack met it, and is closed too.

- ~~**A company does not record which period it files on.**~~ **Closed, 14
  September 2026.** `companies.vat_period` holds the answer, nullable and with
  no default; `country_defaults.vat_period_default` is where a pack proposes
  one, and every pack here leaves it null because Belgium, France and
  Luxembourg all make the cadence follow turnover. `ekwo init` asks when the
  form offers several, `ekwo status` prints it, and `vat_return()` does read it
  after all: it refuses a period the company does not file on, which is the one
  use of the answer that nothing around the return could have.
- ~~**A form's `period` cannot say "month, quarter or year".**~~ **Closed, 14
  September 2026.** `tax_report_templates.periods` is a list of
  `declaration_period`, and `tax_report.json` takes either the list or the
  single word it used to. `month_or_quarter` is read as the two cadences it
  always meant, and the column's default — which handed Belgium's cadence to
  every country that had not spoken — is gone: a form that names none is
  refused by `ekwo pack check`.
- ~~**`sequence` on a declaration box means print order and evaluation order at
  once.**~~ **Closed, 16 September 2026**, and by both halves of the fix this
  entry proposed. The rule in `ekwo pack check` that refused a total naming a
  total at the same sequence or later is gone, replaced by the cycle check the
  statements already had, which names the boxes; `evaluate_totals()` had
  ordered by dependency since 12 September and the rule was the only thing
  saying otherwise. And `print_sequence` is now a field of a box, optional and
  meaning `sequence` where it is left out, so a form says where the
  administration prints a box and where the pack declares it, and the order
  they are worked out in is neither. `vat_return()` answers the resolved value.
  Raised by Luxembourg, met again by Estonia and by the United States, and
  closed by the pack that needed a box worked out from another box.
- ~~**A statement line may be computed and carry a sign, and the sign is applied
  to the total.**~~ **Closed, 14 September 2026.** `ekwo pack check` refuses
  `sign` together with `plus` or `minus`, the way it already refuses a line
  that is both summed and computed. The evaluator is unchanged: applying the
  sign "once" has no meaning while the lines below carry their own, and the day
  a country wants a total presented against its components, the honest shape is
  a second line rather than a flag that reverses one. No pack combined the two,
  so no golden figure moved.

One restriction turned out to be worth keeping. **A tax takes one `base`
posting per kind of document**, and the Luxembourg return reports the taxable
amount of a sale twice — as turnover in section I, and in the rate breakdown of
section II. The pack expresses the second as a total computed from the first,
which is one definition instead of two and is the better shape. **Documented,
15 September 2026**, and not a change to the core: [`packs.md`](packs.md)
carries the rule where the postings are defined and again in the walkthrough,
with box `472` as the worked example.

### From Estonia

None of these blocked the pack. Each one made it say something less precise
than the law does, and each is a change to the core rather than to a pack.

**A fact key cannot be a plain element name, and a taxonomy version cannot be a
date.** `ekwo pack check` requires an `xbrl` key to be a metric plus at least
one domain member, each part lower case, because the Belgian CBSO taxonomy is
dimensional; and it requires `taxonomy` to read `<name>:<dotted number>`. The
Estonian `et-gaap` taxonomy names the lines of its primary statements with
plain, undimensioned concepts — `et-gaap:CashAndCashEquivalents` — and versions
itself by date, `et-gaap_2026-01-01`. *Fix*: accept a single-part key, allow a
hyphen in the prefix and mixed case in the local name, and widen the version to
any sequence of letters, digits, dots and hyphens. *Until then*: the Estonian
statements carry no fact keys at all, because a wrong key is worse than none,
and no filing brick can read them.

~~**A declaration form whose boxes nest cannot be expressed directly.**~~
**Closed, 15 September 2026**, by the first of the two fixes this note
proposed: a `base` posting names several boxes. `box` takes a string or a list
of strings in `taxes.json`, `declaration_boxes text[]` carries the list beside
the `declaration_box` it starts at, and `vat_return()` sums a line into every
box the posting behind it names. The second fix — a posting type that reports
and books nothing — was not needed and would have been worse: it would have put
a row on the ledger side of the format for something that is not a ledger fact.
The Estonian pack now posts an intra-Community acquisition to boxes 1, 6 and
6.1 at once, and its six `hidden` boxes are gone, with every figure of the
golden scenario unchanged to the cent. What is *not* closed is the rule that
caused it: a tax still carries one `base` posting per kind of document, and a
parent that **is** a sum is still a `total`. Only a parent that is not a sum is
named by the posting.

~~**There is no treatment for a service received from outside the Union.**~~
**Closed, 15 September 2026**, and not under the name this note proposed. The
value is `foreign_services_received`, not `import_services`, because the rule
it names — articles 44 and 196 of Directive 2006/112/EC — turns on whether the
supplier is **established** in the buyer's country and not on whether the
service crossed the Union's border; a name built on "import" would have been
as wrong for it as `import` already was, and `import` in this vocabulary means
goods declared to customs, which is a different mechanism behind a different
document. The Estonian `EE-P-VS-24` carries it and has dropped the sentence of
its legal reference that apologised for saying `import`. On the invoice it
resolves to the reverse-charge mention: the same mechanism as a domestic
reverse charge, under a different article.

**A country that keeps one account for both signs of the year's result has to
name it twice.** `retained_earnings_loss` may be null and falls back to
`retained_earnings`; `current_year_result_loss` has no such fallback, and
`result_accounts` closing requires both. The Estonian balance sheet has one
line, *Aruandeaasta kasum (kahjum)*, and Estonian practice one account. *Fix*:
let `current_year_result_loss` fall back to `current_year_result_profit`, as
its sibling already does. *Until then*: the manifest names `2980` twice.

**An e-invoicing obligation that depends on the buyer cannot be said.**
`einvoicing.mandatory_from` is a date and nothing else, so a pack can say "from
this day everyone is bound" or say nothing. Since 1 July 2025 an Estonian
seller must issue an e-invoice when the buyer is registered in the commercial
register as an e-invoice recipient and asks for one; there is no day on which
everyone is bound. *Fix*: an `obligation` field beside the date, with a closed
vocabulary — `none`, `on_buyer_request`, `reception`, `emission`. *Until then*:
Estonia leaves `mandatory_from` null and puts the rule in the legal reference,
so a reader asking whether e-invoicing is obligatory there is told nothing
rather than told wrongly.

**A box of a declaration is a monetary amount.** Boxes 5.3 and 5.4 of form KMD
each carry a number of cars beside the amount deducted. No fix is proposed
here: a count comes from somewhere other than the ledger, and where that is
belongs to a longer conversation than this list. *Until then*: the Estonian
pack declares the two amounts and not the two counts, and says so.

One of Luxembourg's four turned up again, which is the answer to whether it was
a Luxembourg problem: **`sequence` on a declaration box means print order
and evaluation order at once**. Box 1 of form KMD is printed first and is a
total of boxes printed after it. Estonia escapes because the rule only
constrains a total that names another total, and box 1 names base boxes — but
it escapes by luck, and the fix Luxembourg proposes is the fix. **Closed, 16
September 2026**, by `print_sequence` and by the removal of that rule.

### From the United Kingdom

Seven things the first pack outside the Union could not say precisely. Four of
them are about the same assumption — that a country's VAT is the Union's VAT —
and the other three are about what a price, a rounding rule and a filing cadence
belong to. None blocked the pack. None was patched for its sake: the first two
were closed afterwards, on their own, with the pack already landed and its own
README naming them as the things a reviewer should refuse first.

An eighth is of a different kind and is recorded at the end: ten assertions of
the test suite that had never been contradicted, and that were fixed rather than
worked around, because a test reading the pack is what this repository asks for
in as many words.

~~**A VAT exemption outside the Union has no reason code, and one is
required.**~~ **Closed, 15 September 2026.** `ekwo pack check` demanded an
`exemption_code` as soon as `vat_category` was `E`, and checked its shape
against `VATEX-EU-<article>` or `VATEX-<country>-<article>`. The VATEX list is
European: its own codes name articles of Directive 2006/112/EC, and its
national codes — `VATEX-FR-CGI261-1` and the rest — belong to Member States
that publish them. A British exemption is Schedule 9 to the Value Added Tax Act
1994 and no published list carries a code for it, because no administration
that would publish one has any reason to. The rule was right for a Member State
and had no answer for a third country.
The fix is the one proposed, generalised: the last column of the table under
"What a tax says on the invoice" now applies where the Union's VAT does, and
nowhere else. For a pack whose country the common system does not reach,
`exemption_code` stays null, the article goes in `legal_reference` where it was
going anyway, a `VATEX-*` code is refused by name, and the five `intracom_*`
treatments are refused outright. The categories are untouched, because UNCL5305
is a UN/CEFACT list and `E`, `G`, `O` and `AE` mean there what they mean
anywhere. Which side of the line a pack is on is read from `territories` — the
`eu_vat_scope` of its country at the manifest's `released_at` — and nothing
about it is written into the code: `pack check` has no database, so it parses
`supabase/seed/00_territories.sql`, and `tests/vat_codes.test.ts` holds its
answer against `eu_vat_scope_of()` for every territory on every date the table
carries. Should a third country ever publish reason codes of its own, the
column takes them where the pack's register declares that list with
`kind: standard`; the field is provided for and the content is not, because
nobody has published one. `packs/gb/` 0.1.1 drops `VATEX-GB-SCH9` and the three
Union codes it had borrowed, and its README's first two review points are gone
with them.

~~**`G` and `VATEX-EU-G` say "export outside the EU", and a third country's
export is not that.**~~ **Closed, 15 September 2026**, as the same change and
by reading the standard more carefully. The claim that `G` describes the
Union's border came from use case 4 of the Commission's technical guidance,
which is written for a seller established in a Member State. UNCL5305 itself
says of `G` *free export item, VAT not charged*: the goods leave the territory
of whoever levies the tax, and a supply from Great Britain to a Member State is
one. So the category was never wrong for a British export and the refusal
message was — it now says what UNCL5305 says, with the guidance's use case
named as the Member State's case of it, and `docs/packs.md` reads the same way.
The code was the wrong half: `VATEX-EU-G` names article 146 of a Directive that
does not bind the seller, and it is refused outside the Union along with the
rest of the list. `GB-S-EXPORT` carries `G` and nothing else, with s. 30(6) of
the Value Added Tax Act 1994 in its `legal_reference`.

~~**One taxable amount, two printed boxes that are siblings and not nested.**~~
**Closed, 15 September 2026**, by the Estonian fix, which covered both shapes
exactly as this note said it would. The value of a service received from a
supplier established abroad is one `base` posting naming `["6", "7"]`, and
boxes 6 and 7 are ordinary boxes summed from the ledger again rather than
totals of a workaround. The three `hidden` boxes are gone from a nine-box form,
and the golden scenario's figures did not move. Nothing here turned on the two
boxes being siblings rather than nested: a posting names the boxes the form
prints its amount in, and where they stand on the form is the form's business.

~~**A price that includes the tax is declared and never computed.**~~
**Closed, 15 September 2026.** The engine takes the tax out of the gross of
each tax group, rounds it once as BR-CO-14 requires, subtracts it to get the
base — so `base + tax` is the price that was quoted, always — and shares that
base back over the lines in proportion to their gross, the last line taking the
remainder. The line keeps the gross it was quoted at and a snapshot of the flag,
frozen when the document is posted. `GB-S-20-INC` is now booked in the golden
scenario for what it is, a day of counter sales of 5 493,92 gross, and
`docs/decisions.md` is where the arithmetic and the three refusals are written
down. The shared invoice carries the two fields too, so a link says which price
it is showing. Two narrower gaps came out of it and are below: the choice HMRC
gives a retailer between two rounding units, and BT-146, the net unit price,
which nothing publishes where the price was quoted gross.

**A rounding *unit* is a choice a country may give a trader, and nothing can
record it.** VAT Notice 700, §§ 17.5 and 17.6, lets a retailer work the tax out
line by line or invoice by invoice, and both are lawful. Ekwo does it invoice by
invoice, per tax group, because that is what EN 16931 BR-CO-14 requires of a
structured invoice and a line-by-line figure would fail validation. That is the
right default and it is still a choice made for the trader rather than by them.
*Fix*: whatever records the choice belongs beside the other one on this page —
a nullable column on `companies` overriding the country, in the shape
`vat_period` already has — and it is a different field from
`rounding_method`, which is the arithmetic and not the unit it applies to. No
new vocabulary was invented for it here, on purpose: a word in the pack format
is a word every pack has to mean something by. *Until then*: a British retailer
who works line by line files a figure Ekwo does not produce, and is within a
penny or two of it on any invoice with more than one line.

**BT-146 is the net unit price, and nothing publishes it where the price was
quoted gross.** `document_lines.unit_price` is the price as it was keyed, which
on a retail line is the gross one, and `document_line_items` hands it on under
that name. Nothing is ambiguous about it — the view and the shared payload both
carry `unit_price_includes_tax` and `amount_incl_tax`, so a reader knows which
price they have and what the gross was — but the net unit price itself is not
published anywhere. Its honest definition is the base divided by the quantity,
because BR-CO-10 wants quantity times BT-146 to be BT-131 and the group's
remainder lands on a line. What stops it
being a column today is the precision: it is the *price* column's six decimals
and not the currency's, which `round_amount` does not express, and writing
`::numeric(16, 6)` would put a second place where decimals are decided —
exactly what `npm run check:rounding` exists to refuse, and it refuses it.
*Fix*: a way to say "at the precision this column has" that the rounding rule
owns, then a `unit_price_net` beside the two fields that are already there.
*Until then*: a renderer that needs BT-146 divides `amount_untaxed` by the
quantity itself, which is the same arithmetic done one layer out, and every
pack here but the British retail tax prices net and is unaffected.

**A rounding rule belongs to a country, and HMRC gives one to each kind of
trader.** `country_defaults.rounding_method` is one value per country and there
is no column beside it on `companies`. HMRC's concession, recorded in
VATREC12010 and VATREC12020, lets an **invoice trader** round the VAT payable
*down* to a whole penny, because the rounding is neutral between the supplier's
output tax and the customer's input tax; and it says the same concession is not
appropriate for a **retailer**, for whom rounding down reduces the tax accounted
for without reducing the tax charged. Two lawful methods in one country,
chosen by what the business is. *Fix*: a nullable `rounding_method` on
`companies` that overrides the country's, which is the shape `vat_period`
already has — the pack proposes, the company decides, and nothing falls back on
another country. *Until then*: `packs/gb/` declares `half_up`, which is the
method a retailer must use and one an invoice trader may, and a company on the
concession has nowhere to record it.

~~**A tax cannot depend on the territory the parties are in, and one
registration can cover two tax territories.**~~ **Closed, 16 September 2026**,
and by the fix this note proposed, word for word: a tax names a territory, a
party records the one it is in, and the engine compares them.
`applies_when` on a tax takes `seller_in`, `buyer_in` and `supply_in`, each one
territory of the reference table; `companies.territory_code` and
`contacts.territory_code` say where a party is, `documents.supply_territory_code`
says where a supply lands, and a condition is satisfied by the territory named
**and by every territory inside it**, so a British tax that says nothing reaches
a seller in Northern Ireland and one that says `XI` does not reach a seller in
Manchester. `post_document()` raises `tax_territory_mismatch` where a document
contradicts a condition, and `ekwo pack check` now judges a tax's VAT regime on
the territory it applies in rather than on the pack's country — which is what
makes `eu_vat_scope = 'goods'` mean something: a tax applying in `XI` is inside
the common system for a supply or an acquisition of **goods** and outside it for
everything else. `tests/tax_territory.test.ts` proves all three on a copy of
`packs/gb/` with one tax changed, because no pack of this repository declares an
invented tax. **`packs/gb/` still carries no Northern Ireland tax**: the case is
expressible and writing the codes is a transcription of the Protocol that a
British accountant should sign, not a thing to do in the pull request that made
it possible. Boxes 2, 8 and 9 stay declared and empty until somebody does. The
decision, and the three shapes weighed against it, are in `decisions.md`. What
follows is the note as it was written.

**A tax cannot depend on the territory the parties are in, and one
registration can cover two tax territories.** Half of what this note first
proposed landed the same day, from the recapitulative statement's own list:
`territories` is reference data of the framework, `XI` is in it with
`eu_vat_scope = 'goods'` and the prefix VIES publishes for it, and `GB` carries
the day it left the common system. What that buys is a **reader** — the
statement asks the table and stops listing supplies to the United Kingdom after
2020. What it does not buy is a **pack**. Since 1 January 2021 one VAT
registration covers Great Britain, where the Union's rules do not apply, **and**
Northern Ireland, where they do for goods: a Northern Irish seller identifies
under `XI`, makes intra-Community supplies of goods, and files boxes 2, 8 and 9
of the same nine-box return. A pack is keyed on a country and has no unit below
it; `companies.region` and `contacts.region` exist and nothing reads them; and
no tax may be conditioned on either. So `packs/gb/` cannot carry the Northern
Ireland taxes without claiming they apply to a company in Manchester. *Fix*: let
a tax name a territory the way it already names a `jurisdiction`, and let a
company record the territory it is established in, so that one country's pack
can carry two sets of taxes and offer each where it applies — the table that
says which territory is which already exists. *Until then*: `packs/gb/` is Great
Britain's return, boxes 2, 8 and 9 are declared and empty, and the pack's README
sends a reader to `territories` for what `XI` is.

~~**A pack may propose a filing cadence only where its form accepts exactly
one, and the United Kingdom has a default its form does not show.**~~
**Closed, 16 September 2026**, and by the fix this note proposed: the proposal
is judged against the law and not against the length of a list. It also moved
where it belongs — onto the form, as `tax_report.json`'s `period_default` — so
that a pack carrying two declarations can propose a cadence for each.
`packs/gb` now proposes `quarter` on a form filed on three cadences, citing reg.
25(1). Re-reading the other four against the same rule moved two of them:
Belgium and France each make the monthly return the rule of the code and the
quarterly one an authorisation granted on turnover, which is a default the law
gives everybody, so both propose `month`; Luxembourg proposes nothing, because
there the cadence follows turnover with no answer for everybody. What follows is
the note as it was written.

**A pack may propose a filing cadence only where its form accepts exactly one,
and the United Kingdom has a default its form does not show.**
`tests/tax_report.test.ts` states the policy as an invariant over every pack: a
form filed on one cadence has that cadence proposed in `defaults.vat_period`, a
form filed on several proposes nothing. The reason given is sound for every pack
written before this one — everywhere in Europe the cadence follows turnover, so
the answer is a fact about the company and a pack proposing one would be
choosing a filing deadline for somebody it knows nothing about. Regulation 25(1)
of the Value Added Tax Regulations 1995 makes the prescribed accounting period
three months **for everybody**, and a month or a year is something the
Commissioners *allow or direct* on application. So the British form is filed on
three cadences and the British law still gives one default, which is the case
the rule cannot express: it reads the length of a list where the question is
what the law says. *Fix*: judge the proposal against the law rather than against
the form — keep the refusal of a proposed cadence the form is not filed on,
which catches a real mistake, and drop the rule that a form with several may
propose none. If the invariant is worth keeping mechanically, the manifest is
where the distinction belongs: a cadence the law gives, and a cadence left to
the company, are two different silences and today they are the same one. *Until
then*: `packs/gb/` proposes nothing, `ekwo init` asks a British company what it
files on, and the pack's README says that a company which has asked HMRC for
nothing files quarterly.

**And ten assertions that were an unnamed country.** These are not gaps in the
format: the core supported everything the United Kingdom asked of it. They are
places where `tests/` had assumed something every pack until now happened to
satisfy, and the invariant CONTRIBUTING states — *a test may book in a country,
it may not expect one* — is what says they are defects. Unlike the seven above,
they were fixed, in a commit of their own, and every fix **removes** an
assumption rather than adding a country: `npm run check:no-country-literals`
never saw any of them, because none of them spelled a country code.

| What was assumed | What the United Kingdom is | What the test reads now |
|---|---|---|
| every pack declares at least one other language | a pack written in English has none to declare | the promise is checked for what is declared, and one assertion says the repository still has a multilingual pack |
| `manifest.languages` is an array | it is optional and absent | `?? []` |
| every asset category has translated labels | a pack with no i18n file has none | the column's own empty object |
| a declaration form has more than twenty boxes | the VAT Return has nine, and had twelve with the pack's hidden ones | the form carries every box the pack's taxes post to, at least one of them, and at least one total |
| the fixed-assets module has exactly two country seeds, named | it has one per pack that says something about fixed assets | derived from `allPacks` and each manifest's `seed_sequence` |
| `country_packs` in slug order is `allPacks` order | the first pack whose name does not sort where its slug does — United Kingdom after Luxembourg | sorted the way the query asks, by name |
| a closing style is `appropriation_accounts` or `result_accounts` | the first pack that closes straight into retained earnings, which the schema has always allowed and `docs/packs.md` names the United Kingdom for | the enum of `packs/schema/pack.1.json`, beside the statuses and the cadences already read there |
| every pack names an account for the result of the year | under `retained_earnings` there is no such account and the schema says the roles are null | the roles, nullable |
| every pack's country is a Member State | it is in `territories` with the day it left | the country has to be *known* to the table, and a Member State exactly where the pack's own treatments are intra-Community |

The last one arrived with `territories` on the same day, and is the sharpest of
them: the table was written so that the core could say whether a country is in
the common system, and the test that read it asked every pack's country to be a
Member State. It now asks the pack. A pack whose taxes are intra-Community has
to be inside the system and one whose taxes are not has to be outside it, which
is a stronger claim than the one it replaces and the only one a pack of a third
country can satisfy.

The eleventh is the cadence above. It was **not** fixed on the day it was
found — it is a policy and not an assumption, so the pack worked around it —
and it was fixed on 16 September 2026, by the fix it proposed.

One thing the United Kingdom **confirmed** rather than found. A legal mention
cannot tell a domestic reverse charge from a foreign one — recorded from the
EN 16931 code lists, where no pack needed the distinction. This one does: s. 55A
of the Value Added Tax Act 1994 moves the liability on a construction service
supplied inside the United Kingdom, and s. 8 does it on a service received from
a supplier established abroad. Two articles, two mechanisms, one
`applies_when`. The pack prints one sentence and names both articles in its
legal reference, which is the argument for the tenth condition that note
proposed.

### From the United States

Fourteen things the first pack of a country with **no value added tax** could not
say precisely, and they are not the same kind of thing as the seven the United
Kingdom returned. Those were about a VAT that is not the Union's. These are
about a tax that is not a VAT at all, levied by a government the pack format has
no unit for, on a return that has no national version, against accounts no
statute prescribes. None of them blocked the pack. None was patched for its
sake — and two were then closed on their own merits, on 16 September 2026, for
every country: the first on this list and the confirmation at the end of it,
which turned out to be one change, because a box worked out from another box is
what makes a print order and an evaluation order two different questions.

Two are recorded at the end and are of a different kind: one row of framework
reference data a pack outside the Union cannot do without, and one assertion of
the test suite that had never been contradicted.

**Six of the fourteen were answered on 16 September 2026.** Four of them are
about *vocabulary* — a word for a tax the buyer assesses on themselves, a
category asked where no invoice carries one, a register entry read as a code
list it never claimed to be, and an exemption whose condition could not be
written down. Three of those are struck through below, with what was done and
what a reviewer still has to decide; the fourth is not, because the pack can now
say *what* an exemption depends on and still cannot hold the evidence, so that
note stands with the half that is closed marked and the half that is not written
out. The fifth is the arithmetic of a form itself. The sixth is the largest of
the list — a tax that could not name the territory its parties are in — and it
was written from both ends, here and from the United Kingdom, before the same
fix closed both. The rest stand, and what they are waiting on is no longer one
another.

~~**A box of a declaration form can be a rate applied to another box, and a total
is only a list of boxes to add.**~~ **Closed, 16 September 2026**, by the fix
this entry proposed and under the names it proposed. CDTFA-401-A states four of
its lines as a multiplication in as many words: line 13 is line 12 times 0.06,
line 14 is line 12 times 0.0025, line 15 is line 12 times 0.01, and Sections C
and D are a base times 0.05 and times 0.039375. There is no expression language
in this format and there is none now: a box may carry `rate`, a percentage, and
`rate_of`, the one box it applies to, resolved the way a `plus` reference is —
two named fields, nothing to parse, and a reviewer reads *six per cent of line
12* in the diff. A box is a list or a rate and never both, only a computed box
carries either, and `evaluate_totals()` works one out exactly as it works out a
list: when the box it names has been worked out. Lines 13, 14 and 15 of
`packs/us` are written that way and the four `tax` postings that used to fill
them from the ledger have lost their boxes; **not one figure of the golden year
moved**, in any of the three quarters, which is what the apportionment had
promised and could not guarantee.

Two things the closure did not cover, and both are the pack's and not the
format's. **Line 16 is not a rate of line 12**: a district tax is owed on the
sales made in that district and not on the period's whole taxable total, and
the form carries the figure over from CDTFA-531-A2 rather than multiplying, so
that box stays summed from the ledger — correctly, and it is the one of the
four that was never an apportionment of anything. **Sections C and D are still
not carried**: their shape is sayable now, and what is missing is the eight
deduction lines they hold and the taxes that would reach them, which nobody has
transcribed. Line 20a, which they feed, is still declared and empty.

**A pack declares one declaration form, and this country files fifty of the same
one.** The gap itself is not new — it is written above, under the recapitulative
statement, where a pack that cannot declare a second form leaves
`ec_sales_list()` with a guard nobody can arm. What the United States adds is
the shape of the second form. There, the forms a pack is missing are *other*
declarations of one country: a recapitulative statement, an annual return beside
the periodic one, each with a kind of its own. Here they are **the same
declaration, fifty times over**, filed to fifty administrations under fifty
bodies of law, with different boxes, different cadences, different due dates and
a different territory each. A company selling into three states files three sales
tax returns and none of them is national. `packs/us/` carries California's; the
New York tax posts to the ledger and to no box at all, so an amount the company
genuinely owes New York is invisible to every return the core can produce.
*Fix*: the one proposed above — a list of forms per pack, with a kind on each —
and one thing it has to carry that a European pack would not have asked for,
which is **the territory the form belongs to**, because that is what says which
of the fifty a given sale is declared on. *Until then*: one state, and a README
that says which.

~~**A tax cannot be conditioned on the territory of the parties, so a pack
cannot offer a company only the taxes that apply to it.**~~ **Closed, 16
September 2026**, and by the fix both notes proposed, including the second half
this one added: the condition is on the buyer and on the place of supply and not
only on the seller. `packs/us/` now says where each of its codes applies —
`US-CA-S-725` is a Californian seller and a Californian delivery, `US-NY-S-8875`
is a delivery to New York, `US-OR-S-0` a delivery to Oregon — and
`post_document()` refuses the Californian tax on a document delivered to New
York, by name, before anything reaches the ledger. The golden year gained the
territories of its eight parties and its one out-of-state shipment, and **not one
figure of the three expectation files moved**: the codes, the rates and the
postings are what they were, and all that is new is that the wrong one can no
longer be booked. What the fix does *not* do is make the New York tax
declarable — see the paragraph above on filing fifty of one form, which is where
that belongs. The note as it was written follows.

**A tax cannot be conditioned on the territory of the parties, so a pack cannot
offer a company only the taxes that apply to it.** The United Kingdom recorded
this as the reason Northern Ireland is absent from `packs/gb/`, and it is worse
here. `packs/us/` offers a California company the New York and Oregon codes and
an Oregon company the California ones, because `jurisdiction` is a label on the
tax and nothing reads it; `companies.region` and `contacts.region` exist, carry
a state code, and are read by nothing. The fix the British note proposes — let a
tax name a territory, let a company record the one it is established in — is the
same fix, and the American case adds the second half of it: the tax also follows
the **buyer's** territory, because a sale is taxed where the goods are delivered.
*Until then*: the codes are named for the state they belong to and a bookkeeper
picks the right one.

~~**How often a company files is one column, and it belongs to the return it is
named after.**~~ **Closed before this pack landed**, by `company_filing_periods`
— one row per declaration a company is subject to, keyed on the company and the
code of the form. The United States was written against the column and rebased
onto the table, and it has nothing to add to the fix except the reason it will
matter more here than anywhere: an American company's cadences are not merely
different lengths of the same obligation, they belong to different
administrations, so the company's side of the answer is per form **and** per
territory at once. The key is ready for the first half and the second waits on
the paragraph above.

~~**There is no treatment for a tax the buyer assesses on themselves that is not
the reverse charge of the common system.**~~ **Closed, 16 September 2026**, by
the fix this note proposed: `self_assessed`, a treatment of its own for a tax a
buyer owes **directly to an administration under that administration's own
law** and computes and declares themselves. California's use tax is imposed on
the buyer by section 6201 and section 6202(a) makes them liable for it;
mechanically that is the shape `domestic_reverse_charge` books, and it was
wrong in every other respect — no exempt supply behind it, no supplier who was
relieved of anything, no recapitulative statement, no article 196 of Directive
2006/112/EC, and nothing recovered at the other end, the same document carrying
a `tax_on_base` posting because the tax is a cost. `US-CA-P-USE-725` now says
`self_assessed`, and its `legal_reference` states the mechanism instead of
denying another one. The value carries no EN 16931 category and no reason code,
for the reason `import` and `foreign_services_received` carry none: a buyer
assessing a tax on themselves holds no invoice the standard governs, and there
may be no supplier the levying State can reach at all. It is **not** refused
inside the common system — a Member State levying a duty of its own that a
buyer self-assesses would be describing this and not article 194 — and what
tells the two apart is the law each tax cites, which every tax already carries.
**What a reviewer holding a CPA licence still has to decide** is whether
California's use tax is one operation or two: section 6202(a) says the buyer's
liability is not extinguished until the tax has been paid to the State **or to
a retailer who collects it**, and the pack splits those into `US-CA-P-USE-725`
and `US-CA-P-725`. Whether a California practitioner recognises that split, and
whether the use tax accrual belongs on the same four accounts as the sales tax,
are questions the vocabulary cannot settle. `packs/us/README.md` puts both on
its reviewer's list.

**And there is no treatment for a supply outside the taxing territory but inside
the country.** Section 6396 exempts a sale that the contract requires to be
shipped, and that is shipped, outside California. It is not an `export`, which
in this vocabulary means goods leaving the country; it is not `not_subject`,
which is a supply the law places elsewhere; and it is not quite `exempt` either,
because what the statute says is that the receipts are exempted from the
computation of the tax. The pack writes `exempt` and explains itself. *Fix*: the
same one the territory gap needs — once a tax can name a territory, a supply
that leaves it has a word. *Until then*: three American codes carry `exempt` for
three different reasons and the `legal_reference` is the only place the
difference is recorded.

~~**A tax that can reach a sale must name an EN 16931 category, in a country
whose invoices are governed by no standard at all.**~~ **Closed, 16 September
2026**, by the fix this note proposed, and on the border ST38-1 had already
drawn one field over. The British pack closed the reason code half: outside the
common system `exemption_code` is null and the article goes in
`legal_reference`. The category is now asked **where a category is read** —
inside the common system, or where the pack declares an `einvoicing.profile`,
every one the format names being built on the semantic model of EN 16931 and
carrying BT-151 — and a pack that declares neither may leave the column null,
the way a purchase-only tax already could. The United Kingdom is unaffected: it
declares `peppol-bis-3` and its sellers do issue invoices somebody reads BT-151
on. The United States declares no profile, no American administration publishes
a category list, and nothing there reads the field.

The column is now free in such a pack and it is **not** unchecked: the category
codes are UNCL5305, a UN/CEFACT list, so a value a pack does name is still held
to its treatment, to its reason and to its rate, everywhere. `packs/us/`
therefore keeps what it wrote — `S` on a taxed sale, `E` on an exempt one, `O`
on a sale into a state with no tax — because those are true statements about
the operation and nothing in a pack is ever deleted. What changed is that they
are the pack's choice rather than a European standard's demand.

~~**A register entry of kind `standard` is read as the code list BT-121 comes
from, whatever standard it actually is.**~~ **Closed, 16 September 2026**, by
the first of the two fixes this note proposed: `"reason_codes": true` on the
entry that publishes the list, rather than the first `standard` in declaration
order. A `kind` of its own was the alternative and was not taken — a published
list of codes **is** a technical norm, so a second kind would have made a pack
choose between two true things, and a register may name several standards of
which at most one is a list of exemption reasons. `ekwo pack check` refuses a
second flagged entry and refuses the flag on an entry that is not a `standard`.

The trap it closes was live in two packs, not one. `packs/us/` declared the
FASB Accounting Standards Codification first and the Digital Business Networks
Alliance second; `packs/gb/` declares FRS 102 first, so a British reason code
would have been authorised by a financial reporting standard. Neither pack
carries an `exemption_code` anywhere, so nothing wrong was ever emitted. No
pack of this repository declares `reason_codes` today and a test says so: the
field is provided for and the content does not exist yet, because no country
outside the Union publishes exemption reason codes and PINT is where one would
surface.

**An exemption that depends on a document the buyer signed cannot be recorded,
and neither can one that depends on a threshold the seller crossed.** *Half
closed, 16 September 2026, and the half that is not is written out below.* A
sale for resale is untaxed because the seller holds a resale certificate —
section 6091 presumes every receipt taxable until they do, and Regulation 1668
says what the certificate contains. A seller must collect in a state where they
have economic nexus, which since *South Dakota v. Wayfair* is a running total of
sales into that state: 500,000 dollars for California. Both decide which tax
code a line carries.

What is now recorded is **what the question was**. `conditions` is a closed
vocabulary of five words on a tax — `buyer_certificate`, `buyer_status`,
`transport_evidence`, `seller_threshold`, `supply_nature` — and there is no
value beside any of them: no threshold amount, no certificate number, no
operator and no expression. A field that could carry `sales_into_territory >
500000` would be a pack that evaluates, and the next country would want a
second operator; the figure a threshold is set at and the contents a
certificate must have are in the article the tax already cites, which is where
a reviewer reads them. Five American codes now say which question they are the
answer to, and a reader of the chart no longer sees four zero-rated codes and a
rate, each with one long sentence and nothing else. Nothing in the core reads the field, exactly as nothing
reads `treatment`: it lets an application put the question to a human being
instead of pretending to answer it. It compiles to `tax_templates.conditions`
and stops there, the way `source_key` does — it is the pack's transcription of
a country's rule, not a property of the tax a company went on to edit.

**The evidence itself is still nowhere, and no fix is proposed for it here.**
There is no place on a contact for a certificate, for what it covers and for
when it expires, and no place anywhere for a rolling total of sales per
territory. The first is a document-management question — a file, a validity
window, a renewal, and a rule about who may see it — and the second is a
reporting one that needs what the third note of this section is about, a tax
that can name a territory. Both are larger than the pack format and neither
should be answered inside it: a `conditions` that grew a value would become the
rule engine this format exists not to have. What the pack states is the code a
bookkeeper reaches for once the answer is known, and what it now also states is
that somebody has to know it.

**`fiscal_year_default` offers four opening months where the law offers twelve
and then offers a year that opens on no first of a month at all.** The Internal
Revenue Service publishes three kinds of tax year: the calendar year, a fiscal
year ending on the last day of any month except December, and a 52-53-week year
that varies between 52 and 53 weeks and need not end on the last day of a month.
The enum is `calendar`, `april`, `july`, `october` — the four openings the first
five packs needed. *Fix*: a month number, or nothing at all: the column exists so
that `fiscal_year_bounds()` can open a first year without being told the dates,
and a country where the answer is "whatever the company chose" should be able to
say that and be asked. *Until then*: `packs/us/` declares `calendar`, which is
the ordinary American corporate answer, and its golden scenario runs a 52-week
year from bounds it names itself, which `fiscal_years` has always accepted.

**A declaration form filed in whole units, over a ledger kept in cents, cannot
be said.** CDTFA-401-A prints "please round cents to the nearest whole dollar"
on its face. `rounding_method` is the arithmetic of the ledger and
`cash_rounding_unit` is the smallest coin of a cash payment; neither is the unit
a declaration is filed in, and there is no third field. *Fix*: a
`rounding_unit` on the declaration form, beside its cadence, since it is a
property of the form and not of the country — the same form is filed in dollars
whoever files it. *Until then*: `vat_return()` gives cents, the golden records
cents, and a filer rounds by hand. It is also, incidentally, why the first gap
on this page costs less than it might: a cent of difference between line 17 and
the ledger disappears on a form filed in dollars.

**The close cannot send other comprehensive income anywhere but the result.**
`close_fiscal_year()` closes every income and expense account into the style the
pack declares, which here is retained earnings. Generally accepted accounting
principles put a foreign currency translation adjustment and an unrealised gain
on an available-for-sale security in other comprehensive income, which closes to
**accumulated** other comprehensive income — a separate line of equity, caption
30 of rule 5-02, that never passes through net income. Caption 21 of rule 5-03
is on the pack's income statement and two accounts reach it, and closing the
year would put them in the wrong reserve. *Fix*: a fifth account role, or a flag
on the account type, saying which income accounts close elsewhere. *Until then*:
the pack's README says not to post to `8400` and `8410`, and the golden year
does not.

**A fixed asset has one depreciation plan, and an American asset has two.** The
accounting charge is the Codification, topic 360: a life the entity estimates,
no table, no method prescribed. The tax deduction is the Modified Accelerated
Cost Recovery System of Publication 946: statutory recovery periods, a half-year
or mid-quarter convention, a mid-month convention for real property, and a
switch from double declining balance to the straight line. They are not
variations of one thing — they are two computations over the same asset that an
American company keeps side by side for its whole life, and the difference
between them is a deferred tax. `assets.json` carries one plan per category.
*Fix*: a second plan per category, or a category that names a purpose, so that
one asset can carry an accounting schedule and a tax schedule. *Until then*:
`packs/us/assets.json` is the accounting one, every category says so, and
`docs/international.md` has always listed MACRS as deliberately out of scope —
which was the right call for a module and is not an answer for a country.

**`defaults.region` cannot say that a country has no default region.** The field
exists so a pack can propose the province a company sits in, and it was built
for Canada. An American pack cannot use it: naming a state would give every
American company California's, which is the country-default mistake one level
down, and leaving it null is read as "this country taxes uniformly", which is the
opposite of true. *Fix*: a value that means "required, and the company must
answer" — the shape `vat_period` has, where a pack that proposes nothing makes
`ekwo init` ask. *Until then*: `packs/us/` leaves it out and nothing reads it
anyway.

~~**And one thing this pack confirmed rather than found.**~~ **Closed, 16
September 2026.** `sequence` on a declaration box meant print order and
evaluation order at once, for the third time: CDTFA-401-A prints line 11 on
page 1 and computes it from Sections A and B on page 3, so the pack ordered by
dependency and the form's own order was lost. Luxembourg proposed the fix,
Estonia escaped it by luck, and the United States was the second pack that
could not print its form in the order the administration prints it. It is what
the rate box forced: a box worked out from a box has a dependency the print
order knows nothing about, so the two had to stop being one field. Every box of
`packs/us/tax_report.json` now carries a `print_sequence`, and `sequence` is
left where the pack declared it.

A second confirmation was on this list until the day the pack landed and is not
a gap any more. Section 6452(a) of the California code makes the return
quarterly for everybody and section 6455(a) lets the Department require another
period — regulation 25(1) of the British VAT Regulations word for word in
another language, and the case a pack could not express while a proposal was
judged by the length of the form's list of cadences. `period_default` moved the
proposal onto the form and made it a question about the law, so `packs/us/`
proposes `quarter` on a form filed on three cadences, exactly as `packs/gb/`
does. Two countries, two continents, the same rule, and the fix taken before
either of them needed the workaround.

**A pack of a third country needs a row in framework reference data, which is
not one of the two places a pack is written.** `docs/packs.md` says adding a
country touches `packs/<cc>/` and `packs/<cc>/golden/` and nothing else. That is
true of a Member State and false of a third country: `vatRegime()` reads
`territories` to decide whether the VATEX list reaches the pack, and a country
the table carries no row for is held to the Union's table — so an American
exempt sale with no `exemption_code` would be refused, and the pack would be
told to write a code naming an article of a Directive its seller is not bound
by. `tests/territories.test.ts` refuses such a pack from the other side, for the
same reason. So `supabase/seed/00_territories.sql` gains a `US` row, with
`eu_vat_scope` `none` and no window, in a commit of its own. It is reference
data of the framework and not a country literal in the core — the table exists
precisely so that no function holds a list of countries — but it is a third
place, and the walkthrough should say so: **a pack for a country outside the
common system of VAT adds one row to `territories` before anything else.**

**And one assertion of the test suite that was an unnamed country.**
`tests/pack_install.test.ts` groups every tax posting of every pack by country
and by declaration form, with `order by 1` — the country, and nothing else —
and compares the result to a list it sorts itself by country and then by form
code. Every pack until the sixth had one form and, at most, one group of
postings that name no box, and the two happened to arrive in the order the
comparator wanted. The United States is the first pack whose form code sorts
after the word `null` under the comparator and before it in the database, so the
query turned out never to have been asked for a total order. Fixed in a commit
of its own, by sorting both sides with the same comparator: the fix **removes**
the assumption that the database's order is the test's, and adds no country to
anything. `npm run check:no-country-literals` never saw it, because it does not
spell a country code.

### From a box worked out from another box

Found while closing the first entry of the American list — `rate` and `rate_of`
on a box, and `print_sequence` beside `sequence`. None of the four blocked that
work, and none is patched here.

**Nothing compares the rates a form prints with the rates the taxes charge.**
`packs/us` states line 13 as 6.00 per cent of line 12, line 14 as 0.25 and line
15 as 1.00, and its statewide sale code charges 7.25 — which is the three added
up, and has to be. Nothing anywhere checks that. A pack whose form says 6.00
where the tax says 6.50 compiles, passes `ekwo pack check`, passes every unit
test, and files a return that is wrong by half a point against a ledger that is
right; only a golden scenario written by somebody who noticed would catch it,
and a golden is the pack's own arithmetic either way. *Fix*: a check that, for
each tax posting to a form, the rates of the boxes a taxable base reaches add
to the tax's own rate — which needs the form to say which boxes are the tax
lines of which base, and that is the honest reason it is not done here. *Until
then*: `packs/us/golden/expectations.json` states the three rates by hand
beside the arithmetic of every other computed box, and `tests/tax_report.test.ts`
holds the pack to them.

**A box worked out from a base no longer depends on the tax being posted at
all.** This is the same coin. While lines 13 to 16 were summed from the ledger,
a sale booked with no tax code showed up as a missing tax; now the tax lines
follow line 12, which follows line 1, so a base posted with the wrong code
still produces a tax the company may not owe, or hides one it does. That is not
a defect of the rate — it is how the form itself works, and it is why the
United States files on the form's arithmetic and Belgium on the ledger's. *No
fix is proposed*: what would help is a reconciliation between a declaration box
and the account its tax is booked on, which is a report and not a pack field.

**A rate cannot change inside a version of a form.** `tax_report_box_templates`
is keyed on `(country, report_code, box, kind)`, so a box has exactly one row
however many `valid_from` windows one might want. A tax that changes rate is a
new tax code; a box whose rate changes on the first of January is a **new form
code**, with all thirty-nine of its boxes copied. That is defensible — a rate on
a form is the form's own text — and it is expensive, and nobody has met it yet.
*Fix*: if it becomes real, a validity in the key, which is how the taxes already
do it. *Until then*: a new form version.

**A financial statement line still says `sequence` means evaluation order, and
it has not for four days.** The comment on `statement_line_templates.plus_lines`
reads *evaluated in `sequence` order, so a total may only name one computed
before it*, which `20260912100412` made untrue in the same file that wrote it:
`evaluate_totals()` resolves by dependency for both callers, and the statement
half of `ekwo pack check` has always tested for a cycle and never for an order.
The declaration half is what carried the real rule, and it is the half that
changed. *Fix*: a `comment on column` in a later migration, and a
`print_sequence` on a statement line the day a scheme needs one — no pack has
asked, because a statement's `sequence` was only ever used for printing.
*Until then*: one stale sentence in `docs/schema.md`, which is generated from
that comment.

### From making a tax follow the territory

Five things found while closing the two notes above, on 16 September 2026. None
of them blocked the work and none was patched for its sake.

**A tax can name a place a party is in and not a place a party is not in.**
`applies_when` is three keys, each an equality, and that is deliberate: the
moment it grows an operator it is an expression language and the format stops
being reviewable. The case it cannot reach is the one `packs/us/` already had —
section 6396 exempts a sale the contract requires to be shipped **out of**
California, and "out of" is a negation. A fourth key, `supply_outside`, is the
obvious shape and was not added, because nothing in this repository would read
it and because the gap it belongs to is a different one: what is missing is the
*word* for the operation, not the *condition*. The territory work gives that
word its anchor — a tax names the territory that levies it and a document names
the territory of the supply, so a `treatment` of "outside the taxing territory"
finally has two things to be checked against — and the value itself belongs to
whoever writes the treatments. *Until then*: `US-CA-S-SHIPPED` says `seller_in`
and nothing about where the goods went, carries `exempt`, and explains itself in
`legal_reference`.

**The reference table now grows for a second reason, and nobody owns the
growth.** `territories` was the territories of the common system of VAT plus the
third countries a pack books in. It is now also every territory a tax names and
every territory a document delivers to, because all four columns are foreign
keys — which is the whole point, since a code nobody can look up is what
`jurisdiction` has been since the day it was added. The cost is real and is not
paid here: an American company that ships to forty states needs forty rows of
framework reference data, and framework reference data is shipped by a release.
`packs/us/` adds four rows and its golden year ships to one state it levies
nothing in. *No fix is proposed*: the question is whether a release carries every
ISO 3166-2 subdivision of every country a pack exists for, or whether a
destination outside the table is allowed and simply satisfies no condition. What
is certain is that the answer is a decision about reference data and not a column
on a document.

**A destination the table does not carry is refused by a constraint and not by a
name.** Everywhere else in this schema a value that cannot be resolved is
refused by an exception that says which value is missing —
`no_cash_basis_account`, `no_territories`, `unknown_chart`. A
`supply_territory_code` the table has no row for is refused by the foreign key,
with the message Postgres writes for a foreign key, naming the constraint rather
than the question. It is the correct refusal and it is the wrong sentence.
*Fix*: a trigger, or a check in whatever writes a document, that says "this
release carries no territory X; here is where territories come from". *Until
then*: the constraint's own message, which a reader can at least act on.

**A document does not record the territory it was judged against.**
`document_territory()` resolves the supply to the delivery address and then to
the buyer, and `post_document()` compares the answer with the tax's conditions —
and then nothing keeps the answer. Correct a contact's `territory_code` two years
later and the entry that was booked is unchanged, which is right, but there is no
column that says what the engine believed at the time. `vat_category` is
snapshotted onto the document for exactly this reason and this is the same kind
of fact. *Fix*: three columns on `documents`, written by `post_document()` the
way `entry_lines.posting_type` now is. *Until then*: the ledger says which tax
was booked, and the tax says which territories it required, so the answer is
recoverable but not recorded.

**Two columns now look like they answer the same question, and one of them is
still read by nothing.** `companies.region` and `contacts.region` are ISO 3166-2
without the prefix, added for a Canadian pack that will want to ask "which
province" as a question with a short list of answers. `territory_code` is a key
of `territories` and answers "which body of tax law is this party under". They
are genuinely different questions — a Québec company is in `CA-QC` for the tax
and picks `QC` from a list of thirteen — but a reader meeting both for the first
time will not see that, and `region` has had no reader for four days longer than
it should have. *Fix*: the Canadian pack decides, when it arrives, whether the
province is derivable from the territory and `region` goes, or whether the two
stay and the comments do the work. *Until then*: both exist, only one is read,
and this paragraph is why.

### From the EN 16931 code lists

Found while teaching `ekwo pack check` to compare a tax's treatment with its
category and its exemption reason. Neither blocked that work; both are about
the same two columns, and both are a change to the core rather than to a pack.

~~**A VAT category comes back padded with a space.**~~ **Closed, 15 September
2026.** `taxes.vat_category`, `tax_templates.vat_category` and
`document_lines.vat_category` were `char(2)`, and every category of EN 16931
but `AE` is one character — so the database answered `S `, `K `, `E `, `G `,
`Z `, `O `, and had done since the column was created. `document_line_items`
and `document_tax_summary` published that as BT-151, which is not a code of
UNCL5305: a renderer writing it straight into an invoice emits one that fails
validation, a reader comparing it to `'S'` finds nothing, and since
`shared_document()` reads both views it reached whoever held the link to an
invoice. Nothing here noticed, because the only test that compared the column
compared two databases that pad identically and trimmed before it looked.
The three columns are `text`, under a check constraint that accepts one or two
capitals and nothing else, so the column now refuses what it used to
manufacture; the two views were dropped and recreated unchanged but for
existing, with their comments and their grants. No pack moved: a pack never
wrote the space, the column added it — the golden files are identical and the
seeds are untouched. `tests/vat_category.test.ts` follows one pack's category
from the manifest to the payload an anonymous reader receives, and
`tests/packs.test.ts` has dropped the expectation it used to pad on purpose.

**A legal mention cannot tell a domestic reverse charge from a foreign one.**
`applies_when` is a closed vocabulary of nine conditions, and
`foreign_services_received` had to join `reverse_charge` because that is the
sentence all four packs print for it — the mechanism is the same and the
wording is the same. A country whose law prescribes a different sentence for a
service bought from a supplier established elsewhere cannot say so: it would
have to choose between the two sentences for both cases. *Fix*: a tenth
condition, `foreign_reverse_charge`, beside the one that exists. *Until then*:
no pack here needs the distinction, and a pack that does will be the argument
for adding it.

**And it cannot name the simplification a triangular supply is relieved
under.** `intracom_triangular` joined the same condition on 15 September 2026,
for the same reason — the mechanism is the customer owing the tax and the
sentence is *Reverse charge*, which is what article 226(11a) requires. But
article 226(11) also wants a reference to the provision that relieves the
supply, and several Member States ask a triangular invoice to name article 141
itself. A pack that wants that sentence has today to fold it into its
reverse-charge wording, where it would also print on a domestic reverse charge
that has nothing to do with article 141. *Fix*: the same tenth condition
generalised, or an eleventh — three articles behind one sentence is one too
many. *Until then*: three treatments share `reverse_charge`, and the value of
the treatment on the line is the only place the difference is recorded.


### From a document read by its recipient

Publishing an invoice behind a link (`20260915153000`) put a reader in front of
it who has no session, no preferences and no membership, and that reader found
two things the core could not say. Both are closed by `20260915191200`, and
they turned out to be one thing: a chain that was re-walked on every read, from
a starting point only a session could supply.

~~**A document does not record the language it was written in.**~~ **Closed,
15 September 2026.** `documents` had no `language` column: the language was
re-derived, every time, from the contact's, then the company's, then the one
the country pack declares. So an invoice reprinted after the customer switched
to another language came out in a language it was never sent in — wrong on a
document whose legal mentions are part of what the law requires.
`documents.language` is now a column of the table, filled from that same chain
when the document is created and frozen the moment it is posted, which is what
`document_lines.vat_category` and `vat_rate` already are and for the same
reason. A draft keeps following the chain — it carries no number, no entry, and
the customer on it may still change — and a posted document refuses the move
by name, `document_language_frozen`. The documents that were already here were
filled from the chain once, in the migration, which is the best that can be
said about a document somebody has already sent.

~~**`preferred_languages()` cannot serve a reader who is not signed in.**~~
**Closed, 15 September 2026.** It started at `user_preferences` for
`auth.uid()`, which is null for `anon`, so the one published way of choosing a
language was unavailable to the one reader who is outside the installation, and
`shared_document()` resolved the chain itself — a second place a language was
chosen. The chain was never about a *user*, only about where it starts:
`preferred_languages(language, company)` takes the starting point explicitly,
and `preferred_languages(company)` is now one line on top of it, supplying the
signed-in reader's preference. `document_legal_mentions` walks the chain from
`documents.language`, `shared_document()` reads the column and the view, and
neither writes a chain of its own. `anon` gains nothing: the overload is
granted to `authenticated` and `service_role`, and the public door is still one
`security definer` function.

### From the recapitulative statement

The statement of intra-Community supplies — `ec_sales_list()` and the four
format bricks beside it — was the first thing written that is European rather
than national: one engine, four files, no `packs/eu/`. Five things it could not
say precisely, each a change to the core rather than to a pack.

~~**A company records how often it files its return, and that is not how often
it files anything else.**~~ **Closed, 16 September 2026**, and by the fix this
note proposed: `company_filing_periods`, one row per declaration a company is
subject to, keyed on the company and the code of the form. `vat_return()` reads
the cadence of the form it was asked for rather than the one on the company, and
`ec_sales_list()` gained the same guard with one condition more — the caller
names the statement it is preparing, and a caller that names none is asking for
figures and is refused nothing. Two decisions are worth knowing.
`companies.vat_period` was **kept**, because it has been published since v0.3.0
and a reader outside this repository still reads it; it is now derived, a mirror
of the row for the country's periodic return, held in step by two triggers that
each write only when the other is out of date — the shape `declaration_box` and
`declaration_boxes` already use. And the proposal moved with the fact: a pack
proposes a cadence on the **form** now, in `tax_report.json`'s `period_default`,
because a country-level proposal can only ever be about one of the several
declarations a company files. `country_defaults.vat_period_default` is
deprecated and carries a copy written from the form.

**A pack declares one declaration form, and a country files several.**
`packs/<cc>/tax_report.json` is a single object and `pack.report` a single form:
the periodic return. Every other declaration a country files — the
recapitulative statement, an annual return beside the periodic one, a form a
second registration brings — has no `report_code` anywhere, which is why
`ec_sales_list()` has to be *told* which statement it is preparing and why no
pack of this repository can answer. The consequence is that the guard the fix
above gave it is, today, a guard nobody in this repository can arm: a company
can record a cadence only for a form the installation carries, and the only form
it carries is the return. *Fix*: a list of forms per pack rather than one —
`tax_report.json` becomes an array, or a `tax_reports.json` sits beside it — with
a kind on each so the core can tell a periodic return from a recapitulative
statement without naming a country, the way `is_periodic_return` already does
for one of the two. It is a change to every pack, to `ekwo pack check` and to
the compiler, which is why it is written here and not taken. *Until then*:
`ec_sales_list()` accepts any `report_code` the installation carries and checks
the period against it, `ekwo init` asks once per form a pack declares, and both
are ready for the day a pack declares two.

**One cadence per form is one too few where a country splits a statement by
what is supplied.** `company_filing_periods` is keyed on the company and the
form, which is the shape of the fact in three of the four countries read while
the statement was written. Luxembourg is the fourth: it lets a taxable person
choose the cadence of the recapitulative statement **separately for goods and
for services**, so one company files one form on two cadences at once. Nothing
in the key can say that. *Fix*: the nature of the supply is already a column of
what `ec_sales_list()` returns, so the cadence could be keyed on it too — a
nullable third key column meaning *whatever this form covers that no other row
names*. It is not taken here because no pack declares the statement as a form
yet, so the row it would refine does not exist. *Until then*: such a company
records the cadence of the statement it files more often, which is the safe half
of the answer — a guard that refuses only what is certain will then refuse
nothing on the other.

~~**The core cannot say whether a country is a Member State.**~~ **Closed, 15
September 2026**, and by the fix this note proposed: `territories`, a reference
table of the framework beside `currencies`, seeded by
`supabase/seed/00_territories.sql` and read by `is_eu_member(code, on)`,
`eu_vat_scope_of(code, on)` and `territory_of(code)`. It carries 49 rows — the
27 Member States with the day each became bound, the United Kingdom with the
day it stopped being, Northern Ireland, and the territories articles 6 and 7 of
Directive 2006/112/EC take out of the common system or put into it — each with
the text it comes from. `ec_sales_list()` asks it **as at the entry date of the
line**, so a statement for a period in 2020 still reports supplies to the
United Kingdom and one for 2021 does not, and a supply to a territory the
system did not reach comes back as `vat_country_outside_the_union` instead of
being listed. Two decisions are worth knowing: the columns are named for VAT
and not for membership — the United Kingdom left the Union on 31 January 2020
and the common system on 31 December 2020, and the reader of this table is VAT
code — and Northern Ireland is a **row of its own** with a parent rather than a
flag on the United Kingdom, with an `eu_vat_scope` of `goods`, because it is
inside the system for supplies of goods and outside it for supplies of
services. A statement of services to an `XI` customer therefore comes back as
`vat_country_outside_the_union_for_this_supply`, which nothing could have said
before.

~~**A VAT identification prefix is not always the ISO country code.**~~
**Closed, 15 September 2026**, by the same table: `vat_prefix_of(code)` answers
the two letters a territory's numbers carry, and `territories.vat_prefix` holds
that answer only where it differs from the code — `EL` for Greece, `FR` for
Monaco, `GB` for the Isle of Man — so the column is a difference and never a
copy. Both paths into `ec_sales_list()` go through it, the prefix read off the
number and the contact's ISO country alike, which means a number typed `GR…` is
corrected as readily as one typed with none. It also fixed a defect nobody in
Belgium or France could have seen: the company's own country was compared raw,
so `vat_country_is_the_company_country` would never have fired for a Greek
filer and a domestic supply would have been listed as an intra-Community one.
A territory the table does not carry keeps its own two letters, so a third
country is still readable on the statement that then refuses it.

~~**A ledger line does not say which posting wrote it.**~~ **Closed, 16
September 2026**, and by the fix this note proposed: `entry_lines.posting_type`,
the vocabulary of `tax_postings` — `base`, `tax`, `tax_on_base` — written by
`post_document()` from the posting it is already reading, and by
`settle_cash_basis_tax()` on both legs of the transfer that makes a cash-basis
tax due. A line no tax posting wrote is null, because null is what a column says
about a question that does not apply; a `none` inside the vocabulary of what a
posting *is* would then have to be refused on `tax_postings` itself. Null
therefore carries two readings and `tax_id` separates them — with no tax it is
*not a posting*, with one it is *written before the column existed and not
identified*. The backfill wrote only what was certain: a line whose tax and
declaration box name one posting type and no other. `ec_sales_list()` now says
what it means, excluding a line **known** to be a `tax_on_base` one and leaving
a null read exactly as it read before.

~~**There is no treatment for a triangular operation.**~~ **Closed, 15 September
2026**, and it cost exactly what this note predicted: the value
`intracom_triangular`, and nothing else. `ec_sales_list()` returns the nature
`triangular` without a line of it changing, and the four bricks — published
before the value existed — write `T` on the Belgian listing, the `TVA_LICT`
form of the Luxembourg envelope and the `kolmnurktehing` column of the Estonian
form VD, while the French DES says by name that a supply of goods belongs on
another file. It is the middle supply of the arrangement — B's sale to C,
relieved by article 141 of Directive 2006/112/EC and reverse-charged to C by
article 197 — and not A's, which is an ordinary intra-Community supply. On the
invoice it resolves to the **reverse-charge** mention and not to the
intra-Community one, which is the sentence article 226(11a) requires: the
supply is not exempt under article 138, it takes place where the goods arrive
and the customer owes the tax. **No pack of this repository declares a
triangular tax**, and a test insists on that — the path is proved on a fixture,
a company's own tax with its treatment changed, because writing an invented tax
into `packs/<cc>/` is writing a rule nobody can review.


## The same rule, next: the One-Stop Shop

Nothing is coded for it here, and this paragraph exists so that the next person
does not rediscover the shape.

A recapitulative statement asks: *who, in another Member State, did I supply,
and how much*. The One-Stop Shop asks: *in which Member State did I have to
charge the tax, at what rate, and how much*. Both are answered from the same
two facts — **the treatment of the tax on the line, and the country of the
customer** — and from nothing else. The statement reads a treatment that says
the supply is exempt in the seller's country and taxable in the buyer's, and
groups by the buyer's VAT number; the One-Stop Shop reads a treatment that says
the supply is taxable in the buyer's country, and groups by that country and by
the rate applied. `ec_sales_list()` is the first of the two, written as a
function of the core with a flat row shape and a brick per file, and the second
is the same three pieces: a treatment the pack declares, an aggregation the
core computes, a format package per administration.

Two things the second one will need that the first did not. **One of them now
exists.** It needs to know which country a customer is in *and whether that
country is in the Union*, because the scheme applies to consumers and not to
identified businesses, so the VAT number is not the key — and that is
`territories`, asked as at a date, which is what `ec_sales_list()` already does
line by line. A consumer in a territory the system does not reach is not a
One-Stop Shop supply at all, and the table says so for the Canary Islands and
for Northern Ireland's services as readily as for Switzerland.

What it does **not** give is a rate per Member State of consumption, which is
the genuinely new question and is unchanged by any of this. A French company
selling into Germany charges German rates, and today the only place a German
rate lives is the German pack that company does not hold. Adding rates to
`territories` would be the wrong answer twice over: a rate has a validity and a
category and an exemption reason, which is a tax and not a territory, and a tax
is what a pack carries. So the choice stays the one this paragraph always
named — either a company holds several packs, or the rates of the scheme are
framework data of their own — and the table below it settles only where the
system applies, not what it charges.

### From the register of sources

Found while turning `certification.sources` into a register a reviewer can
open — a key, a title, the publisher, an absolute link — and pointing every
`legal_reference` at one of its keys. Neither blocked that work. Both were
places where the format let a pack claim something and gave it nowhere to
say where the claim came from, and both were closed the day after.

~~**What a country puts on an invoice cites nothing.**~~ **Closed, 15 September
2026.** `documents.references` carries a `legal_reference` and a `source` per
rule — `numbering`, `payment_terms`, `tax_point` — and not one for the section,
because they are two or three different texts in every country the packs cover:
Belgium numbers an invoice under a royal decree of 1992 and counts a payment
term under a law of 2002, France numbers under an annex to the tax code and
counts under the commercial code. A single citation would have had to name them
all in one string, and then no rule would have had one. Six columns of
`country_defaults` hold the three pairs, beside the rule each belongs to, and
`cgi-annexe-2` is now named by the rule it was read for. `ekwo pack check`
refuses a declared rule that cites no article on a `reviewed` pack, warns about
one on any other, and refuses a key the register does not carry.

~~One thing the reading turned up and this change did not act on. The
Luxembourg pack declares `tax_point: invoice_date`, and the principle of the VAT
law is art. 21.~~ **Closed, 16 September 2026**, and it was true of three packs
rather than one.

The vocabulary gained the two words it was missing —
`invoice_if_issued` and `earliest_of_delivery_or_payment` — and the column
gained a reader, because a vocabulary nothing reads is a comment. Each text was
opened before the word was chosen, and one of the assumptions the work started
from was wrong.

* **Luxembourg**, art. 21: "Le fait générateur de la taxe intervient et la taxe
  devient exigible au moment où la livraison de biens ou la prestation de
  services est effectuée." Art. 24, par. 1er derogates "lorsqu'il y a
  obligation d'émettre une facture", to the issue of the invoice within the
  delay of art. 63, par. 5, or to the day that delay expires — and not for a
  supply with no invoicing obligation, nor for a service the customer is liable
  for under art. 61, par. 5. → `invoice_if_issued`.
* **Belgium** was the same shape and nobody had looked. Art. 16, § 1er and
  art. 22, § 1er are the principle; art. 17, § 1er and art. 22bis, § 1er
  derogate to the invoice "peu importe que l'émission de cette facture ait lieu
  avant ou après le moment où la livraison est effectuée", with the fifteenth
  day of the following month where none was issued. → `invoice_if_issued`.
* **The United Kingdom** likewise: VATA 1994 s. 6(2) and 6(3) give the basic
  tax point, s. 6(4) and 6(5) displace it. Its own citation already said the
  declared value was "a derogation the Act grants and not the principle".
  → `invoice_if_issued`.
* **Estonia** was the assumption that turned out wrong. The work began from
  "KMS § 11 lg 1 keeps the first of three dates: supply, invoice, payment". The
  official English translation of lg 1 lists **two** acts for an ordinary
  supply — "1) the goods are dispatched or made available to the purchaser, or
  the services are provided; 2) full or partial payment is received" — and the
  invoice is not one of them: it belongs to lg 2, the separate rule for
  intra-Community supply. → `earliest_of_delivery_or_payment`, two branches and
  not three.
* **France** was read and left alone. CGI art. 269, 1, a and 2, a put goods on
  the supply, art. 269, 2, c puts services on collection unless the taxpayer
  opts for the débits, and that half is `taxes.cash_basis` by a decision this
  repository already wrote down. `delivery_date` is France's principle and says
  so.

**What the engine does with the word.** `tax_point_of()` is its only reader;
`documents.tax_point_date` (BT-7, which the table had been missing) and
`entry_lines.tax_point_date` are where the answer is written; `post_document()`
and `settle_cash_basis_tax()` write them and `vat_return()` reads them, so a
figure lands in the period its tax fell due in rather than the period its entry
was booked in. Null keeps the entry's date, which is what every reader did
before, so no existing ledger and no golden moves.

**Three things this left open**, and none of them is a one-line follow-up:

* **A payment cannot pull a tax point forward unless the tax says
  `cash_basis`.** The payment branch of `earliest_of_delivery_or_payment` — and
  of Belgian art. 17, § 1er, al. 3, and of VATA s. 6(4) — is a prepayment rule,
  and Ekwo has no prepayment document: matching is recorded against the entry
  `post_document()` is writing, so at posting time no payment of the document
  exists. `post_document()` passes null and the branch degenerates to the
  supply. *Fix*: a prepayment document of its own, or a tax point recomputed
  when a payment is matched, which is a design discussion and not a column.
* **The recapitulative statement still reads the entry date.**
  `ec_sales_list()` was deliberately not moved onto the tax point, because the
  moment an intra-Community supply arises is a different article in both
  countries read here — KMS § 11 lg 2 in Estonia, art. 17, § 2 in Belgium, both
  of them the fifteenth of the following month or the invoice if earlier — and
  none of that is the rule `tax_point_rule` carries. Computing the statement
  from the general rule would make it wrong in a new way. *Fix*: a second rule
  on the country model for the intra-Community tax point, once a pack needs it.
* **BT-7 does not cross to a renderer.** `documents.tax_point_date` is the
  field EN 16931 calls the value added tax point date, and `document_header` —
  the view an invoice is printed and an e-invoice emitted from — does not
  select it, nor `documents.delivery_date` beside it. The column is reachable
  by anything that reads `documents` and not by anything that reads the header,
  so a renderer would have to make a second query for a field that belongs on
  the letterhead. *Fix*: both columns in `document_header` and in the MCP's
  `DOCUMENT_HEADER`, when the view is next replaced — it is four hundred lines
  and replacing it for two columns alone was not worth the churn on the day
  this was found.
* **A purchase is dated by the buyer's country rule, which is the supplier's
  question.** The tax point of a purchase invoice is fixed by the law the
  *supplier* is under, and `tax_point_of()` reads the company's own
  `fiscal_country`. It is exact for a domestic purchase and for the reverse
  charge, where the buyer is the person liable; it is an approximation for
  anything else. *Fix*: none proposed — the alternative is a country model per
  contact, and no pack has asked.

~~**A legal reference the schema accepts and the compiler drops.**~~ **Closed,
15 September 2026**, for the half of it that was about e-invoicing.
`einvoicing.legal_reference` had been read by `pack.1.json` and written by all
four packs since the section existed — it is where the day an obligation starts
is justified, and where France writes out an emission calendar that depends on
the size of a company the core cannot yet hold — and the compiler dropped it on
the floor. `country_defaults.einvoice_legal_reference` and
`einvoice_source_key` now sit beside the profile and the date, written by the
same `update` so that a rule and the text imposing it cannot reach the database
by two routes and have one of them left behind.

~~What is left of the note is the other two: `charts[].legal_reference`
compiles and the `source` beside it does not, and a statement line carries both
in the pack and neither in the database.~~ **Closed, 16 September 2026.**
`source_key` on `chart_templates` and `statement_line_templates`, the way the
register added it to `tax_templates` and `tax_report_box_templates` — and on
`statement_templates` as well, which the note had not counted and which drops
its `source` for exactly the same reason. Reading the compiler to write it
corrected half the note: `statement_line_templates.legal_reference` was
compiled all along, so a statement line carried the article and not the text it
is in. Three nullable columns, filled by the compiled seed like the two before
them, no backfill and no foreign key.

### From recognising who paid

Found on 17 September 2026 while writing the motifs a counterparty is
recognised by, and not blocking that work: the new table says
`counterparty_account` where the rest of the schema says `iban`.

**An account is named as if every country had an IBAN.** `bank_accounts.iban`
and `.bic`, `contacts.iban` and `.bic`, `bank_transactions.counterpart_iban`
and `documents.payee_iban` are six columns that spell out ISO 13616 and leave
no room for anything else. About half the world uses something else: the United
States identifies an account by an ABA routing number and an account number,
Canada by a transit and an institution number, Australia by a BSB, India by an
IFSC; the United Kingdom has IBANs but pays domestically on a sort code and an
account number. The sixth column is the one that gives the game away —
`documents.payee_iban` carries BT-84 of EN 16931, which the standard calls
*Payment account identifier* and which is not an IBAN: the schema narrowed the
term it was citing.

The sixth pack did not catch it, and that is worth saying: `packs/us/` models a
tax and never records a payment, so nothing in it ever had to name an American
bank account. The first American installation finds this on its first statement,
which is the wrong moment.

*Fix*: the shape the same table already uses for another identifier —
`contacts.peppol_scheme` beside `contacts.peppol_identifier`. An account
identifier is a **scheme and a value**, the scheme from a closed list the
database carries, `iban` being one entry of it, and the existing columns
deprecated and mirrored the way `companies.vat_period` was when the cadence
became a table: one source, two names, a trigger, and a release to remove the
old one. The check digits follow the scheme — ISO 7064 mod-97-10 for an IBAN,
the weighted sum of an ABA routing number — so a validator that assumed one
becomes a validator that reads the scheme first.

*Until then*: `contact_patterns` stores what the statement wrote, under a kind
that names neither a country nor a scheme, so the day the columns above learn
to say their scheme, nothing in the matching has to be renamed.

### From settling a statement line

Found on 17 September 2026 while matching a statement line against what it
pays. Neither blocked the work; both are places where the core does something
correct and cannot do the country-specific thing that would make it strong.

**A structured communication is checkable arithmetically, and nothing checks
it.** `bank_transactions.structured_reference` is compared to a document's
reference as a string, which is right and weak. A Belgian structured
communication is twelve digits whose last two are the remainder of the first
ten modulo 97 — with zero written as 97 — and an ISO 11649 creditor reference
carries its own two check digits under mod-97-10, the same algorithm an IBAN
uses. **A communication whose key is wrong is not a communication**, and it
should never start a settlement: it is a typo, a truncation or somebody else's
reference. *Fix*: the scheme belongs to the pack — `bank.structured_reference`,
a closed vocabulary, one entry per scheme a country's banks actually use — and
the check itself is arithmetic the core can do once the scheme is named. It
also wants a second look at Estonia, whose reference numbers use the 7-3-1
weighting rather than mod 97, which would be the first non-97 scheme and the
proof the field is worth having.

**A payment in one currency cannot settle a document in another.**
`suggest_matches()` returns nothing when the statement line's currency is not
the company's, deliberately rather than by omission: the ledger amount and the
statement amount are then two numbers in two currencies, and the rate that
reconciles them is what `reconcile()` decides at the moment of matching — it
books the realised exchange difference — not something a search may assume
beforehand. *Fix*: match on `entry_lines.amount_currency` where the currency
agrees with the statement, and leave the rate to the matching, which already
knows how to write the difference. Until then a company with a foreign-currency
bank account matches those lines by hand.

### From importing a statement

Found on 18 September 2026 while writing `import_bank_statement()`. None blocked
the work; each is a place where the import refuses, by name, what a country
could legitimately send.

**A statement line holds two decimals.** `bank_transactions.amount` and the
balances of `bank_statements` are `numeric(16, 2)`, from the first bank
migration, while `round_amount()` has read the currency's decimals since the
rounding did. A dinar has three. The reader returns them and the import refuses
the line (`unreadable_statement_line`, "more than two decimals") rather than
round a bank's figure. *Fix*: widen the columns to what `currencies.decimal_places`
can ask for — the same change `documents` and `entry_lines` would need, and
better made once.

**An entry in another currency than its account is refused, not converted.**
The roadmap card asked for a conversion through `currency_rates`, traced — rate,
date, source. It is not written: in a camt.053 the entry is in the account's
currency and the foreign amount sits beside it (`instructedAmount`, kept in
`raw`), so the case has not been met yet, and a conversion nobody has seen a
file for would be a guess with an audit trail. *Fix*: when a format or a bank
that books foreign entries is met, convert at import through `currency_rates`
and keep the three facts on the line.

**The account is looked up in a column called `iban`.** The reader says whether
the identifier is an IBAN or not; the core has one column for it and compares
whatever the statement wrote. That works — the end-to-end test pays an invoice, in every pack, on an account
identified by `Othr/Id` — and it is the wrong name, which
is the gap written under *From recognising who paid* and fixed by the same
change. A bank account that the file identifies one way and the company another
can be named explicitly to the import.

**Two readers of two formats do not recognise each other's lines — measured,
now that there are three.** The key of a line with a bank reference is that
reference. `tests/coda_cfonb120.test.ts` imports the same invented day from a
CODA and then from a camt.053, and asserts what happens as it is: when the bank
writes the same reference in both, the lines are known and nothing is imported
twice (the *statement* still is — the two formats name it differently); when it
writes another, or none, **the day is imported twice and nothing says so**.
Febelfin's standard calls the CODA reference "purely informative" and lets the
bank change it without notice, so the first case is a courtesy and not a
guarantee. A CFONB 120 has no bank reference at all: its month and the camt.053
of the same month are always imported twice. *Fix*: not a cleverer key — a
fingerprint across formats compares a name cut at thirty-five characters with
one that is not. What is comparable across formats is the statement: the same
account, the same closing date, the same two balances, another
`source_format`. An import that finds one should say so by name
(`statement_already_covered`) and let the caller decide; that is a migration of
its own, with the question of what a fortnight and its month look like to it.

### From asking when a declaration is due

Written on 17 September 2026, with the deadline rule. Two of the six packs
declared no date at all, and that was the finding rather than the omission.
Both are answered since 21 September 2026 — see the next paragraph and "What
the packs do not say yet".

**A deadline can depend on the taxpayer rather than on the period, and the
format cannot say that.** `packs/fr/` declares none: the French periodic return
is due on a day the administration assigns from the taxpayer's identification
number and legal form, staggered across the second half of the month, and no
rule of the shape *day N of the month that follows* is true for more than a
slice of filers. `packs/lu/` declared none either, for a different reason — the
date was not read, and a pack does not guess. It has been read since: art. 64,
par. 6 of the VAT law, and the pack declares day 14. France now *says* what it
could not compute: the rule `depends_on_taxpayer` carries the text that
assigns the day — the CIBS, art. A. 161-28 and A. 161-29 since 2025 — and no
day, so the country page prints an answer and not a gap. *Fix* for the date
itself, when somebody writes it: a rule whose day comes from a value on the
company, which is a fourth shape and a bigger change than it looks, because the
values (place of filing, legal form, the first digits of the SIREN) are country
data on a table the core owns. *Until then*: `filing_deadline()` answers null
and `upcoming_filings()` lists the period with no date, which is honest and
visibly incomplete.

**An extension can depend on the scheme a company is in.** The United Kingdom
adds seven days to a return filed online and paid electronically, and takes
them back from a business on annual accounting or on payments on account. The
pack states the seven days and says so in the reference, because the usual case
is the extension; what it cannot express is the exception, since nothing
records which scheme a company is in. That is the same shape as the gap the
cadence had before `company_filing_periods`, one field over.

**And a date that falls on a day nobody works is still that date here.**
Several administrations move a deadline to the next working day, which needs a
calendar of public holidays — national, sometimes regional, and revised by law
every few years. No pack carries one and none should invent one, so a deadline
this function produces may land on a Sunday. Saying so is better than a rule
that is right in one country and wrong in the next.

## Decisions taken with the plan

- **US sales tax is not in the core.** Tens of thousands of jurisdictions
  and their updates; the core models the shape, a provider supplies the
  rates, in the commercial layer. Xero and QuickBooks do the same. `packs/us/`
  holds to it: one statewide rate per state and one worked district combination,
  documented as a worked example, and no rate that depends on a delivery
  address.
- **Order: Europe, then the UK and Ireland, then Canada and Québec, then the
  Commonwealth, then the United States.** It is the order of proximity to the
  accounting model this core was built on, and the reverse of market size.
- **The pack comes before any new country.** Adding the UK on the core as it
  stood would have added a third place where a country lives. Phase 0 was first
  a taxonomy decision, and a taxonomy is the one thing that does not get
  redone.

## Deliberately out of scope

Inventory, payroll, advanced fixed-asset regimes (MACRS), point of sale and
its certifications. A products table exists so that inventory can come later
as its own schema, as `decisions.md` describes.

## What the packs do not say yet

Building a page per country made every silence in a pack visible at once, which
is the one thing a folder of JSON does not do on its own. The list below is the
one the pages printed on 19 September 2026, and what became of each item on 21
September. The rule for every line was the same: fill it from an official text
in the pack's register, or make the pack *say* that the silence is the answer
— and where neither was possible, leave it and say so here.

| Pack | What the page printed | Now | On what |
|---|---|---|---|
| `ee` | tax balance: no account, either side | **filled** — `2370` payable, `1211` receivable | KMS § 27 (1), § 29 (1), § 34 (1); the Ministry of Finance's commentary of January 2026 |
| `gb` | tax balance: no receivable account | **filled** — `1145`, beside `2210` | VATA 1994 s. 25(2)–(3) |
| `us` | tax balance: no account, either side | **filled** — `2208` payable, `1185` receivable, for the sales and use tax a return carries | California R&TC § 6452(a) and § 6901 |
| `fr` | deadline: not declared | **stated** — `depends_on_taxpayer`: the fifteenth to the twenty-fourth, by place of filing, legal form and SIREN | CIBS, art. A. 161-28 and A. 161-29, to which CGI ann. IV art. 39 refers since 2025 |
| `lu` | deadline: not declared | **filled** — day 14 of the month after the period | VAT law art. 64, par. 6 ("avant le quinzième jour"), in the AED's coordinated text; the AED portal for the quarterly return |
| `gb` | e-invoicing: no date of obligation | **stated** — `obligation: none` | the consultation response of 26 November 2025: mandatory e-invoicing is announced for 2029 and not legislated |
| `us` | e-invoicing: no profile declared | **stated** — `obligation: none`, with no profile to sit beside | the pack's own legal reference: no statute, federal or of any state, obliges anybody; the network it names is voluntary |
| `ee` | e-invoicing: no date of obligation | **stated** — `obligation: on_request`, not `none` | RPS § 7¹ (7): since 1 July 2025 a buyer registered as an e-invoice recipient may require one; the Ministry of Finance confirms no general B2B obligation and no date |
| `ee`, `gb`, `lu`, `us` | bank statements: `bai2`, `camt.052`, `csv`, `mt940`, `ofx` read by nothing | **remains** — no reader was written | `ekwo pack check` now warns once per format; the ledger of the debt is `tests/bank_statement_formats.test.ts` |
| every pack | certification: no named reviewer | **remains** — a person's act, and nothing here can stand in for it | — |

Three findings came out of it, and each is worth more than the line it closed.

- **The premise was wrong once, and the vocabulary grew a word for it.** The
  Estonian line was expected to close as "no e-invoicing obligation between
  companies". There is no general one — but since 1 July 2025 a seller
  must issue one when a registered buyer asks, which is an obligation and not a
  preference. Writing `none` would have been false; `on_request` is the word.
- **"Avant le quinzième jour" is the fourteenth.** Luxembourg's law writes "au
  plus tard le quinzième jour" where it includes the day (art. 63, par. 5) and
  "avant" where it does not, and most secondary sources round it to the
  fifteenth. The pack follows the text, which is also the reading under which a
  return is never late; the pack's README asks a reviewer to confirm it.
- **A role has no citation of its own.** `defaults.roles` names an account and
  cannot say which article makes a credit a claim on the administration, so the
  justification of every settlement account is in the pack's README and the
  texts are in its register. A reviewer reads both.

One silence is still the packs' and not the format's:

- **No pack is `reviewed`.** Four are `community` and two are `maintained`,
  which means the maintainers keep them current and no named professional has
  read them against the law. Every country page says so in those words.

And one claim about coverage is still about the engine: **the currency seed
carries eleven currencies**, "the handful a European ledger meets", at zero and
two decimals. The engine reads a currency's decimals rather than assuming
cents, so a third is a row and not a change — but until somebody adds the rows,
the claim is about the engine and not about coverage.

## Ireland

The seventh pack, `packs/ie/`, `community`, seed 16. It carries an original
chart of 209 accounts mapped onto Schedule 3A of the Companies Act 2014, 39
taxes with the rate history since the Value-Added Tax Consolidation Act 2010
came into force on 1 November 2010 — the temporary 21 % of 2020–2021 and the
three 9 % reliefs among them — the nine boxes of the VAT3 (T1 to T4, E1, E2,
ES1, ES2, PA1), the balance sheet and the profit and loss account of Schedule
3A Format 1, and a register of thirty-six texts, all opened on 21 September
2026. The pack's own [`README`](../packs/ie/README.md) says where each rule
comes from and ends on what a reviewer should read first.

### From Ireland

Five things the format could not say, none of them patched: each is contoured
inside the pack and written down here.

**A two-month taxable period.** Section 2 of the 2010 Act defines the taxable
period as two months beginning on 1 January, 1 March, 1 May, 1 July, 1
September or 1 November, and that is the cadence of every Irish VAT3 unless
Revenue authorises another. `tax_report.period` knows `month`, `quarter` and
`year`, so the pack declares the monthly and annual returns Revenue allows and
proposes no `period_default` rather than a wrong one; the four-monthly and
six-monthly periods Revenue authorises for small liabilities are not
expressible either. `vat_return()` still computes a two-month period — the
golden files on them — because a period that is not a whole cadence is never
refused. *Fix*: a `bimonth` cadence (and `four_month`, `half_year`) in the
schema, in `company_filing_periods` and in the guard of `vat_return()`.

**A second declaration with a period of its own.** The Return of Trading
Details is annual, due with the last VAT3 of the company's accounting year,
and breaks sales and purchases down by rate; it is where the values of
domestic supplies, exports and reverse-charge construction services are
reported, since the VAT3 has no box for them. A pack carries one
`tax_report.json`, so the RTD is absent and the domestic base postings name no
box. *Fix*: several forms per pack, which `report_code` on a posting already
anticipates.

**A deadline that depends on how the company files, and an extension on a
day of the month.** The return is due on the 19th (s. 76(1)) and on the 23rd
for a return filed and paid through ROS. The pack declares `day: 19` and no
`plus_days`: `tests/filing_calendar.test.ts` checks an extension against the
last day of the following month, which is the British rule and not this one,
so the four days would fail it. The deadline is therefore four days early for
a ROS filer and right for a filer exempted from electronic filing. *Fix*: the
test reading the rule it checks, and a condition on the filer for the
extension, which is the British gap again.

**A financial year the law leaves to the company.** Companies Act 2014, s. 288
lets the directors fix the year end. The pack still declares
`fiscal_year_default: calendar`, because `bootstrap` refuses a pack with none
unless the first day is named, and the bootstrap test installs the first pack
whose form proposes no cadence — alphabetically, Ireland — without naming one.
It is a proposal an operator overrides, not a reading of the Act.

**One sentence for every reverse charge a seller issues.** The subcontractor's
invoice under the construction reverse charge carries "VAT on this supply to be
accounted for by the principal contractor", and the other domestic reverse
charges of s. 16 — emission allowances, scrap metal, construction work between
connected persons, gas and electricity to a dealer — would name the recipient
instead. `applies_when: reverse_charge` is one condition, so the pack carries
only the construction case on the sale side. *Fix*: a mention that can be
tied to a tax rather than to a treatment.

**The moneys received basis is a regime of the company.** Section 80 authorises
a company, not a tax, to account on receipts, and only for its sales. The pack
carries it as two sale codes with `cash_basis` and `conditions:
["seller_threshold"]`, as France carries services on collection; nothing stops
an authorised company from picking the invoice-basis code, or an unauthorised
one from picking this. The core records no such regime, which is the
`small_business` gap in another form.

One practical note beside those: `cro.ie` answers every request without a
browser with a Cloudflare challenge, so the Companies Registration Office is not
in the register even though it is where Irish financial statements are filed;
the Companies Act is cited instead. And `camt.053` is the only statement format
declared, because it is the only one Ekwo reads that an Irish bank sends; no
payment format is declared because Ekwo writes none.

### From Spain

Written on 21 September 2026 with `packs/es/`, the first pack of southern
Europe. Status `community`; the pack's own
[`README`](../packs/es/README.md) says what it carries and ends on the points
a reviewer should read first. It carries a selection of 220 accounts of the
Plan General de Contabilidad with the official codes, 26 taxes with the rate
history back to 2010 and the temporary food rates of 2023–2024, the 63 boxes
of form 303 that a company in the general regime fills, and the abridged
balance sheet and profit and loss account transcribed from the account column
the PGC itself prints. Seven things the format could not say, none of which was
patched in the core:

- **A surcharge on the same line as the tax.** The *recargo de equivalencia*
  (Ley 37/1992, arts. 154 to 163) is charged by a supplier to a retailer in the
  scheme on top of the VAT of the same line. That is the stacked tax `group` is
  reserved for, and the core refuses it. The boxes of the surcharge are
  declared and empty so that box 27 keeps the form's formula. *Fix*: the same
  one the Canadian GST and QST need.
- **A country minus one of its territories.** Spanish VAT applies in Spain
  except in the Canary Islands, Ceuta and Melilla (art. 3). The territories
  exist, the export to `ES-CN` is in the golden, but `applies_when` has no
  negation, so the Spanish rates cannot refuse a supply that lands in `ES-CN`.
  The United States gap under *What it cannot say* is the same one.
- **A deadline with an exception for one period and another for one kind of
  filer.** Form 303 is due on the 20th, except the last period of the year
  (30 January) and returns of SII filers (thirty days, end of February for
  January), all in Reglamento del IVA, art. 71.4. The pack declares the rule
  and writes the exceptions in its reference.
- **Invoice reporting that is not an invoice format.** SII (records sent
  within four days, Reglamento del IVA, arts. 62.6 and 69 bis) and VERI*FACTU
  (Real Decreto 1007/2023) are obligations about *transmitting* invoice
  records, with their own dates and populations. `einvoicing` has room for a
  profile and a date only, so both are written in the README and in the
  e-invoicing reference.
- **An e-invoicing date that depends on a text not yet published.** Real
  Decreto 238/2026 counts twelve or twenty-four months from a ministerial
  order that was not found in the BOE on the day of writing. `mandatory_from`
  is null, and the profile too: no brick writes a Spanish invoice, and
  declaring UBL or Facturae would make `describe_pack` say one does.
- **Norma 43.** Spanish banks deliver statements in the AEB/CSB Norma 43
  format, which is not in the list of statement formats; the pack names
  `camt.053` and `mt940`.
- **A receivable that is not reconcilable passes `ekwo pack check` and fails
  the seed.** The first build of this pack had three *facturas pendientes*
  accounts (4009, 4109, 4309) typed payable or receivable and not
  reconcilable. The check accepted them; the seed then failed on the check
  constraint `account_templates_third_party_reconcilable`. The check should
  refuse what the table refuses.

And one thing about the register rather than the format: the BOE answers
`200` for a page that does not exist and says so only in its title. `pack check
--links` reads status codes, so it will call a mistyped ELI of the BOE good.
Every link of this register was checked by its title instead.

## From the OHADA packs

Senegal and Côte d'Ivoire are the first two of the seventeen States that keep
their books on the SYSCOHADA révisé. The chart, the journals, the roles and the
two statements are the same for all of them and live once, in
[`packs/ohada/`](../packs/ohada/README.md); `scripts/ohada-packs.mjs` copies
them into each member and the CI's *hygiene* job refuses a copy that has
drifted. Every pack stays autonomous and nothing in the schema moved. What the
two packs could not say, each a change to the core rather than to a pack:

**A statement code is unique across every country.** `statement_templates` is
keyed on `code` alone, where an account, a tax and a journal are keyed on their
country too, so seventeen packs carrying `SYSCOHADA-BS` would be one row, the
last seed applied winning. The copy puts the country in front
(`SN-SYSCOHADA-BS`); the same scheme is then seventeen rows. *Fix*: key a
statement on `(country, code)` like the rest.

**A frozen box holds two decimals.** `tax_filing_boxes.amount` is
`numeric(16, 2)`: a return in XOF, which has none, freezes `1000000.00` where
`vat_return()` answers `1000000`, and a return in a currency with three would
be cut. `tests/filing_golden.test.ts` now compares the two as values
(`trim_scale`), which is what "figure for figure" meant. *Fix*: the column at
the scale of the currency, like every other amount.

**A pack carries one form, and a Senegalese company files three.** The
monthly return, the declaration of *précompte* (art. 372-2 b) and, by the
DGID's calendar, the *TVA pour compte*; in Côte d'Ivoire the *TVA pour compte
de tiers* of art. 442 is a declaration of its own on e-impots. The withheld tax
waits on 4478 with no box; the *TVA pour compte* of Senegal has a box on the
return, said in its reference to be a transcription. This is the gap the
Canadian note above already names.

**The seller's side of a withholding by the buyer.** Under the Senegalese
*précompte* the buyer pays the price before tax and the tax to the State, and
the supplier's tax falls due when it is paid (art. 362-5 b) — by somebody else.
A cash-basis tax would wait on its transition account for ever. No text says
how the supplier's books clear it, and the pack says nothing.

**A tax on a tax.** The Ivorian AIRSI is 5 % of the invoice *including the
VAT*, added to it for a buyer outside the *régimes réels*. That is a `group`,
which the format reserves and the core does not carry.

**A withholding on a payment.** The Senegalese BRS (5 % of a service invoice,
art. 200) and the Ivorian 2 % on the services of a micro-enterprise (art. 84
bis) are withheld when the invoice is paid, not charged on it. There is no
posting of that kind.

**A credit carried into the next return.** Line 5.2 of the Ivorian form is
the credit of the month before. `settle_filing()` carries a credit to 4449 and
the next `vat_return()` does not read it back, so the pack stops at the credit
of the period (6.2) and says so.

**An electronic invoice that is not EN 16931.** The Ivorian FNE is a national
API — codes TVA, TVAB, TVAC and TVAD, a QR code, a number the DGI's platform
issues — compulsory since 1 December 2025 for every *régime réel*; Senegal's
Code requires an electronic invoice since 2025 and no order has said what it
is. `einvoicing.profile` names profiles of EN 16931, so both packs leave it
empty, and neither the NCC nor the NINEA has an ISO 6523 code for
`party_scheme`.

**A condition on the seller.** Senegal's 10 % is for *approved* tourist
accommodation: a status of the seller, which the five words of `conditions` do
not have. The pack says `supply_nature`, the nearest.

**A deadline that depends on the taxpayer's office.** The Ivorian return is
due on the 10th, the 15th or the 20th depending on whether a company belongs to
the large or medium taxpayers' office and on its sector — the gap the note on
deadlines already carries.

**A cash book.** The *Système minimal de trésorerie* of AUDCIF art. 13, open
to the smallest entities, is a book of receipts and payments per bank and per
cash box with a year-end inventory taken outside it, and its statements name
no account. A double-entry chart could only imitate it by inventing accounts,
so the packs carry the *Système normal* and nothing else.

**The currencies.** XOF is added to the seed, at no decimal. XAF, KMF, GNF and
CDF come with the first pack that needs each; the note above about the seed's
eleven currencies is now twelve.

## The Netherlands

Written from published sources alone, on 21 September 2026, and `community`
like every pack nobody who files the return has read. It carries a selection of
**283 postable accounts of the Referentie GrootboekSchema 3.8** under their RGS
reference codes, the rates of article 9 of the *Wet op de omzetbelasting 1968*
with the reduced rate's move from 6 % to 9 % on 1 January 2019, the rubrics of
the **2026 aangifte omzetbelasting** keyed to their elements in the Dutch
Taxonomy, and **models C and E** of the *Besluit modellen jaarrekening*. The
pack's own [`README`](../packs/nl/README.md) ends on the ten points a reviewer
should look at first; four things are worth knowing here.

- **A reference chart is not a legal chart, and the pack says which it is.**
  The Netherlands prescribes no chart; the RGS is a standard of the Standard
  Business Reporting programme that Dutch software maps its ledgers onto. The
  pack uses the RGS reference *codes* as account codes, because they are the
  only identifiers in the published file that nest by prefix — the reference
  *numbers* lose their leading zero on some rows — and the statements read
  them by prefix.
- **The mapping to the statements is published, not inferred.** The RGS
  publishes with the chart a dataset linking every code to the taxonomy
  concepts it reports in, the `jenv-bw2` concepts of Book 2, title 9 of the
  Civil Code among them. The lines of models C and E follow it.
- **E-invoicing is an obligation to receive, and only for the State.** The
  pack declares Peppol BIS 3.0, the KVK number (EAS 0106) and the Dutch VAT
  number (EAS 9944), and no `mandatory_from`, because no Dutch text obliges a
  business to send an electronic invoice to anybody.
- **Out of scope, on purpose.** The ICP statement as a form of its own, the
  file of either declaration, the OSS return, the small-business scheme, cash
  accounting under article 26, the margin schemes, the *suppletie*, corporate
  income tax, and the XBRL fact keys of the annual accounts.

### From the Netherlands

Four things the pack could not say, each a change to the core rather than to a
pack, and none taken here.

**The recapitulative statement is still not a form a pack can declare.** The
*opgaaf intracommunautaire prestaties* of article 37a is filed on its own
cadence — monthly for goods, quarterly on option below a threshold, quarterly
on option for services — and the Belastingdienst publishes it as an entrypoint
of its own (`bd-rpt-icp-opgaaf-2026`). `ec_sales_list()` computes its lines from
box 3b, which is enough to fill it by hand; what is missing is the form, the
gap *From the recapitulative statement* already names. The Dutch statement
adds one more voice to it and asks nothing new, except that the cadence of
goods and the cadence of services differ, as in Luxembourg.

**A statement cannot carry a fact key that is a plain element.** The Dutch
Taxonomy names `jenv-bw2-i:TradeReceivables`, an element with no dimension, and
the format refuses a key that is not a metric plus a member — the gap Estonia
raised. The lines carry `xbrl: null` and name the concept only in the pack's
README. *Fix*: the one proposed under Estonia.

**A heading of the RGS is postable in the RGS and a heading here.** RGS levels
2 and 3 are aggregation codes and level 4 is where a ledger posts, which is how
the pack reads them. But a Dutch ledger keyed on RGS may post at level 5
(*mutaties*) under a level-4 code, and the format has no way to say that a
level-4 account is postable **and** has children. The pack stops at level 4.
*Fix*: none needed until a user wants level 5; the day one does, a chart would
need either a postable-heading flag or level 5 as its leaves.

**The payment branch of the tax point.** Article 13(2) makes the tax due, at
the latest, when the consideration is received — so an advance payment moves
the tax point forward. The pack declares `invoice_if_issued` for paragraph 1;
paragraph 2 waits for the prepayment document the core does not have, the gap
already written under the tax point in [`packs.md`](packs.md).
