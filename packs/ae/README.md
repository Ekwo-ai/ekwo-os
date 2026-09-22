# United Arab Emirates

Everything the United Arab Emirates adds to Ekwo, as data: a chart of
accounts, the journals, the 5 % value added tax with its zero-rated and
exempt supplies and its reverse charge, a VAT return built from what the
Executive Regulation says a return must hold, the statement of financial
position and the income statement of the IFRS for Small and Medium-sized
Entities Accounting Standard, and the sentences the law puts on a tax
invoice. The format is [`docs/packs.md`](../../docs/packs.md); this file
says where the content came from and which decisions it rests on, so that a
UAE accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Status: `community`.** Nobody who files a UAE VAT return has reviewed it.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**This is the first pack of the Gulf**, and the United Arab Emirates is the
first country in this repository whose electronic invoicing regime is a
5-corner reporting model rather than a Peppol exchange between the two
parties' own access points. What the core could not say is written up in
[`docs/international.md`](../../docs/international.md) under "United Arab
Emirates". None of it was patched for this pack's sake.

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds nine texts, every one of them opened on 22 September 2026.
The two the rest of this file leans on most:

| What | Text | Where |
|---|---|---|
| The rate, scope, zero-rated and exempt supplies, the reverse charge, designated zones, tax invoices, tax periods and the return | Federal Decree-Law No. 8 of 2017 on Value Added Tax, and its Executive Regulation (Cabinet Decision No. 52 of 2017), both as amended and consolidated | `tax.gov.ae` |
| The electronic invoicing timeline, the 5-corner DCTCE model and PINT AE | Ministry of Finance, *UAE Electronic Invoicing Guidelines*, Version 1.1, 1 June 2026 | `mof.gov.ae` |

**Two texts this pack leaned on for cross-checking, and could not itself
open.** Ministerial Decision No. 243 of 2025 (the Electronic Invoicing
System itself) and Ministerial Decision No. 244 of 2025 (its implementation
timeline) are cited throughout the Ministry of Finance's own Guidelines, and
every date and figure this pack carries about them is read from that
secondary document and not from either Decision's own text, which this
research pass did not find at a directly-fetchable URL. The same is true of
the three Cabinet Decisions the Guidelines name for a domestic reverse
charge on electronic devices (No. 91 of 2023), precious metals and precious
stones (No. 127 of 2024), and metal scrap trading (No. 153 of 2025): this
pack carries only the one domestic reverse charge it read from the Decree-Law
itself — crude oil, natural gas and pure hydrocarbons, Article 48(3) — and
names the other three in "What this pack does not carry" below rather than
coding them from a citation it could not open.

**One text this pack could not open at all, and it matters more.**
Federal Decree-Law No. 32 of 2021 on Commercial Companies — the law that, in
every other country this repository's packs cover, is cited for the
requirement to keep accounting records and prepare financial statements —
could not be read from an official portal in this research pass:
`uaelegislation.gov.ae` refused every unauthenticated request tried, and the
Ministry of Economy and Tourism's own site returned no working legislation
link. The statement of financial position and the income statement below are
therefore built, like `packs/sg/` and `packs/hk/` build theirs where no
country text could be opened, on the minimum line items of the IFRS for SMEs
Accounting Standard, with no UAE-specific legal citation for that choice.
This is the first thing a reviewer should check, and it is why the chart's
own `legal_reference` in `pack.json` says so at length rather than naming an
article.

## The chart of accounts, and why this one

**There is no legal chart of accounts in the United Arab Emirates**, as far
as this pack's research could establish — see "Sources" above for what could
not be opened to confirm it directly.

- **Four digits, by class**, the same shape as the Singapore and Hong Kong
  packs: `1` assets, `2` liabilities, `3` equity, `4` revenue and other
  income, `5` cost of sales, `6` other expenses, `7` finance costs, `8`
  corporate tax.
- **Flat**, every account a leaf, grouped by the ranges of `statements.json`.
- **Cost and accumulated depreciation adjacent**, right-of-use assets among
  them, since IFRS 16 reaches a UAE lessee's books the same way it reaches
  any other IFRS preparer's.
- **The accounts a UAE company actually keeps**: VAT input and output tax,
  the amount payable to and receivable from the Federal Tax Authority, and
  import VAT self-assessed under the reverse charge, which never touches
  Customs directly in the ordinary case (see "Taxes" below). A provision for
  employees' end-of-service gratuity is carried as a matter of practice —
  every UAE employer owes one under the Labour Law — but this pack's
  research did not trace it to a specific article of Federal Decree-Law
  No. 33 of 2021, and a reviewer should check that citation before it is
  trusted.

111 accounts, all postable. None was copied from a published chart.

## Taxes

**One rate, 5 %, one code.** Article 3 of the Decree-Law: "5% Tax shall be
imposed on any supply or Import pursuant to Article 2 of this Decree-Law",
in force since the Decree-Law commenced on 1 January 2018. There has been no
other rate, so `AE-S-SR` and `AE-P-SR` carry no `valid_to`.

**What a sale can be, and where it lands on the return:**

| | Code | Box | Category |
|---|---|---|---|
| Standard-rated | `AE-S-SR` | d1, tax in d2 | S |
| Export of goods or services, Article 45(1) | `AE-S-ZR-EXP` | e | G |
| International transport, Article 45(2)–(3) | `AE-S-ZR-TRANSPORT` | e | G |
| Investment precious metals, ≥ 99 % purity, Article 45(8) | `AE-S-ZR-METAL` | e | Z |
| First supply of a residential building within 3 years, Article 45(9) | `AE-S-ZR-RESI` | e | Z |
| Financial services on margin, Article 46(1) | `AE-S-EX-FIN` | f | E |
| Residential building beyond the first supply, Article 46(2) | `AE-S-EX-RESI` | f | E |
| Bare land, Article 46(3) | `AE-S-EX-LAND` | f | E |
| Local passenger transport, Article 46(4) | `AE-S-EX-TRANSPORT` | f | E |
| Outside the scope | `AE-S-OS` | none | O |
| Domestic reverse charge, crude oil / gas / hydrocarbons, Article 48(3) | `AE-S-DRC-HC` | d1, no tax | AE |

**What a purchase can be:**

| | Code | Boxes |
|---|---|---|
| Standard-rated, fully recoverable | `AE-P-SR` | h1, h2 |
| Entertainment, Article 53(1)(a) — input tax blocked | `AE-P-BL-ENT` | none |
| Motor vehicle available for personal use, Article 53(1)(b) — blocked | `AE-P-BL-CAR` | none |
| Zero-rated, from a UAE Registrant | `AE-P-ZR` | h1 |
| Exempt | `AE-P-EX` | none |
| From a supplier not registered for VAT | `AE-P-NR` | none |
| Import of goods, reverse charge, Article 48(1) | `AE-P-IMP` | g1, g2, h2 |
| Imported services, reverse charge, Article 48(1) | `AE-P-RC-SVC` | g1, g2, h2 |
| Domestic reverse charge, crude oil / gas / hydrocarbons, Article 48(3)(b) | `AE-P-DRC-HC` | g1, g2, h2 |

**Import is a reverse charge, not a payment at the border, for the ordinary
registered importer.** Article 48(1) of the Decree-Law treats a Taxable
Person who imports Concerned Goods as making a taxable supply to themselves;
Article 48(1) of the Executive Regulation conditions this on the Person
being able to demonstrate its Tax Registration and Customs registration
number at the time of import — the case every VAT-registered importer meets
in practice. The Person self-assesses the Due Tax in the return rather than
paying it to Customs, which is why `AE-P-IMP` posts a self-assessed tax
(factor `-100` on the output side, so a purchase document still credits the
output account) instead of clearing an import-VAT account. Article 50 of the
Executive Regulation covers the Person who does not meet those conditions,
and this pack does not carry it.

**Domestic reverse charge reaches one goods class this pack could verify
from the Decree-Law itself.** Article 48(3): a taxable supply in the State,
between two Registrants, of crude or refined oil, unprocessed or processed
natural gas, or pure hydrocarbons, where the recipient intends to resell the
goods as such or to use them to produce or distribute energy. The supplier
charges no Tax (Clause 3(a)) and the recipient self-assesses it (Clause
3(b)), conditioned on written declarations of intended use and of Tax
Registration status (Clause 4) — `conditions: ["buyer_certificate",
"buyer_status"]` on both `AE-S-DRC-HC` and `AE-P-DRC-HC`. Three other
domestic reverse charge classes exist under separate Cabinet Decisions this
pack's research could not open — see "What this pack does not carry".

**Every base is a value without VAT**, as boxes d1, e, f, g1 and h1 ask.

## The return

`tax_report.json` is not the Federal Tax Authority's own VAT201 return form:
this research pass could not open a directly-fetchable text of the form
itself or of its administrative box numbering (1 to 13, on the live
EmaraTax portal), so the boxes below are built letter by letter on the
minimum content Article 64(5) of the Executive Regulation itself requires a
Tax Return to hold — `d1`/`d2` through `j`, named after the clause letters
of that article. **A reviewer who knows the live EmaraTax screen should
check this first**: this pack's boxes and the portal's box numbers 1 to 13
almost certainly do not correspond one to one, and nothing here claims they
do.

| Boxes | How |
|---|---|
| d1, e, f, g1, h1 | bases, summed from the ledger |
| d2, g2, h2 | taxes, summed from the ledger |
| i1, i2, j | the return's own arithmetic |

**Box g2 is this pack's own addition**, not a separate clause of Article
64(5): the article names only the *value* of a reverse-charge supply in box
g1, but Article 48(4)(a) of the Decree-Law requires the Tax on that value to
be accounted for, and a return that reported the value without it would be
short by exactly that amount. It is the one box in this return that is not a
direct transcription of a lettered clause, and the first thing a reviewer
should check against a real filing.

**Quarterly by default, monthly by administrative assignment.** Article
62(1) of the Executive Regulation gives every Taxable Person a standard Tax
Period of three calendar months; Article 62(2) lets the Authority assign a
shorter or longer period "where it considers that necessary or beneficial",
without a turnover figure in the text this pack's research could open. In
practice the Authority assigns a monthly period to larger taxable persons,
which is why `period` lists both `month` and `quarter`, but no article this
pack found pins a threshold to it, and none is invented here.

**The deadline is exact.** Article 64(1): the return and the payment are
both due no later than the 28th day following the end of the Tax Period.

**Where the balance of a return lands.** `tax_payable` is `2110`, `tax_
receivable` is `1155`. Neither is posted to by any tax; they hold the net of
a filed return, matched against a payment to or a refund from the Federal
Tax Authority.

## The accounts

`statements.json` carries the statement of financial position and the
income statement of the IFRS for SMEs Accounting Standard, for the reason
given under "Sources" — no UAE-specific legal citation was found for using
this framework rather than a country one, and that gap is named rather than
patched. The income statement is by nature, which a small company's ledger
holds without an allocation to functions.

**VAT is a receivable and a payable, not current tax.** Current tax is
corporate tax under Federal Decree-Law No. 47 of 2022, which this
VAT-focused pack does not otherwise carry; the accounts (`1350`, `2130`,
`8000`) exist for a company to book the charge by hand.

**No fact keys.** Nothing checked here says which XBRL taxonomy, if any, a
UAE filing uses, so `xbrl` and `taxonomy` are null throughout.

## Closing the year

`fiscal_year_default` is `calendar`, a proposal and nothing more: a UAE
company chooses its own financial year end, and the golden year uses the
calendar year because Article 3 of the Decree-Law dates the (single) rate
from a calendar date. `closing_style` is `retained_earnings`: the chart
carries no current-year result account. `3210 Dividends paid` sits beside
retained earnings and is booked by hand.

## On the invoice

**The tax invoice is a list of particulars** (Executive Regulation, Article
59(1)): the words "Tax Invoice", the date, an identifying or sequential
number, the supplier's name, address and Tax Registration Number, the same
for the recipient where it is a Registrant, a description of each line with
its rate and the Tax charged, and — where the recipient must account for the
Tax — a statement to that effect and a reference to the relevant Decree-Law
provision. A simplified Tax Invoice (Article 59(2)) is allowed where the
recipient is not a Registrant, or where the consideration does not exceed
AED 10,000 including Tax — except where the reverse charge applies, which
always requires the full particulars.

**Numbering is `sequential`.** Article 59(1)(d) asks for "a sequential Tax
Invoice number or a unique number which enables identification of the Tax
Invoice and the order of the Tax Invoice in any sequence", which identifies
each invoice and its place in a series without asking that the series carry
no gap.

**One mention.** This pack's research found no article requiring a printed
sentence on a zero-rated or an exempt line — a UAE tax invoice already shows
the rate of Tax against each line (Article 59(1)(h)), which is what
distinguishes them — unlike, for instance, Singapore's reg. 11(3). The one
mention this pack carries is the reverse-charge statement Article 59(1)(l)
requires.

**No default payment term and no late payment interest** are declared: this
research pass found no UAE statute setting either between businesses absent
an agreement, and did not look long enough to say there is none.

**The tax point is an approximation of a three-way rule.** Article 25 of the
Decree-Law makes the date of supply the earliest of delivery or completion,
the date of payment, or the date the Tax Invoice was issued — three
triggers, where the closed vocabulary of `tax_point` has room for two.
`earliest_of_delivery_or_payment` is the nearest value and what the rule
reduces to in the ordinary case, because Article 67 already requires the
invoice within 14 days of that same date; the case this approximation
misses is a supply invoiced late, or paid before either delivery or an
invoice.

## Electronic invoicing

The profile is `pint-ae`, the Peppol International invoicing specification
localised for the UAE. `obligation` is `mandatory`, phased by the Person's
annual revenue rather than by a single date: a voluntary pilot and general
voluntary phase both open on 1 July 2026, and mandatory implementation
follows — by 1 January 2027 for a Person with AED 50,000,000 or more in
annual revenue, by 1 July 2027 for every other Person, and by 1 October 2027
for a Government Entity, each with its own deadline to appoint an
Accredited Service Provider before the go-live date. `mandatory_from`
carries 1 January 2027, the earliest date the obligation binds anyone; the
full phased calendar, including the 24-month grace period for transactions
between members of the same VAT group, is in `pack.json`'s own
`einvoicing.legal_reference` and in `docs/international.md`.

**A 5-corner model, not a 4-corner Peppol exchange.** The Guidelines call it
DCTCE — Decentralised Continuous Transaction Control and Exchange — Corner 1
the supplier and Corner 4 the buyer, each behind its own Accredited Service
Provider (Corners 2 and 3), which independently report the Tax Data of every
Electronic Invoice to the Federal Tax Authority (Corner 5). A party is
addressed by ICD `0235` followed by its 10-digit Tax Identification Number,
the first 10 digits of its 15-digit Tax Registration Number; `vat_scheme` is
left empty because no separate ISO 6523 code is registered for the 15-digit
TRN itself.

**PINT AE has its own six tax categories** — Standard Rate, Exempt from VAT,
Out of scope, Reverse Charge, Zero rated, Margin scheme — and they are not
the UNCL5305 letters `vat_category` holds. Each tax names its PINT AE
category in its own `legal_reference`, for a renderer to map.

## What this pack does not carry

- **The rest of the tax invoice's mandatory fields** the Guidelines describe
  for an Electronic Invoice specifically (section 10), where they add to
  what Article 59 of the Executive Regulation already requires of a paper or
  PDF tax invoice — this pack's `documents.mentions` and `postings` cover
  the substantive VAT treatment and not the wire format.
- **Three domestic reverse charge classes named only in a secondary
  source**: electronic devices (Cabinet Decision No. 91 of 2023), precious
  metals and precious stones (Cabinet Decision No. 127 of 2024), and metal
  scrap trading (Cabinet Decision No. 153 of 2025). Only the hydrocarbon
  class this pack could read from the Decree-Law itself, Article 48(3), is
  coded.
- **Designated zones** (Decree-Law, Articles 50 to 52; Executive Regulation,
  Article 51): a fenced, Customs-controlled area the Cabinet designates is
  treated as outside the State for goods, with its own place-of-supply and
  import rules. The core has no place-of-supply engine that reaches a
  sub-national zone, and this pack does not patch around it: a supply into,
  out of or within a designated zone is not modelled, and the list of
  designated zones itself was not verified against a Cabinet Decision this
  research could open.
- **Article 50's "Special Rules of Import"**, for the importer who does not
  meet the reverse-charge conditions of Article 48(1) of the Executive
  Regulation and pays Tax at, or through, Customs directly. Account `1157`
  exists in the chart for this case; no tax code posts to it.
- **Apportionment of input tax for a partly exempt business** (Executive
  Regulation, Article 55) and adjustment under the Capital Assets Scheme
  (Articles 57 to 58).
- **Withholding tax**: this pack's research found no UAE withholding tax
  regime on payments abroad, unlike Singapore's.
- **Corporate tax** (Federal Decree-Law No. 47 of 2022), named only where a
  balance sheet needs an account for it, and deliberately outside this
  VAT-focused pack's research — see "Sources".
- **Fixed assets.** No `assets.json`: whether the UAE's tax rules recognise
  a depreciation schedule at all was not established in this research pass,
  since it is a corporate tax question and out of scope here.
- **Bank formats.** Nothing checked says which formats UAE banks send.
- **Filing.** The return is filed on EmaraTax; submitting it is a credential
  and a format, not a pack.

## Reviewing this pack

Open an issue titled "Review: United Arab Emirates". What a review is, and
what it is not, is in [`docs/packs.md`](../../docs/packs.md) under
"Certification, and who may say what". The points a UAE-qualified accountant
should read first, roughly in the order the author is least sure of them:

1. **The statement of financial position and the income statement against a
   real UAE-filed IFRS statement** — no UAE-specific legal citation backs
   the choice of framework; see "Sources".
2. **Box g2 of the return**, this pack's own addition and not a direct
   transcription of Article 64(5).
3. **The `month` cadence of the return**, carried with no statutory
   threshold behind it.
4. **`AE-P-IMP`'s self-assessment posting**, which assumes the ordinary
   Article 48(1) reverse-charge case and never clears an import-VAT account
   at Customs.
5. **The provision for end-of-service gratuity**, whose Labour Law article
   this pack's research did not trace.
6. **`earliest_of_delivery_or_payment` as the tax point**, which drops the
   third trigger — the invoice date — that Article 25(7) of the Decree-Law
   also names.
7. **The single domestic reverse charge class coded** (hydrocarbons) against
   the three named only in a secondary source.
8. **`einvoicing.mandatory_from`**, which names the earliest phase
   (≥ AED 50,000,000 revenue) and not a single date every business meets.
