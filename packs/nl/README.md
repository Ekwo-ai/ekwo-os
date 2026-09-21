# `packs/nl/` — the Netherlands

A Dutch company keeps its books on a chart of its own making, files one
periodic VAT return, a recapitulative statement of its intra-Community
supplies, and deposits annual accounts laid out on the models of a decree.
Every file below names the text it comes from, and the register in
`pack.json` holds the thirty-eight texts this pack was written from.

`certification.status` is **`community`**: this pack was written from the
published sources and **no Dutch accountant has read it**. What that means in
practice is in [`../../DISCLAIMER.md`](../../DISCLAIMER.md), and the points a
reviewer should look at first are at the end of this file.

## The chart

**The Netherlands prescribes no chart of accounts.** Book 2 of the Civil Code,
article 10, and article 52 of the *Algemene wet inzake rijksbelastingen* ask
for records from which the rights and obligations of the business appear at
all times, and say nothing about their shape. What the country does have is a
**reference** chart: the *Referentie GrootboekSchema* (RGS), released by the
*Taakgroep RGS*, a public-private partnership within the Standard Business
Reporting programme in which the Belastingdienst, the Chamber of Commerce,
Statistics Netherlands, SBR Nexus, the accountancy bodies and the software
vendors take part, and built so that every account maps onto the Dutch
Taxonomy the returns and the annual accounts are filed in.

`accounts.csv` is a **selection of RGS 3.8**, the definitive version published
on referentiegrootboekschema.nl, taken from the *MKB* worksheet and its *Basis*
filter:

- **The codes are RGS reference codes** — `BLimBanRba`, `WOmzNohOlh` — and not
  numbers of our own. They are hierarchical by prefix (`BLim` → `BLimBan` →
  `BLimBanRba`), which is what the statements read. The RGS reference
  *numbers* were not used: in the published file they lose their leading zero
  on some rows (`101015` for `0101015`) and do not nest.
- **283 postable accounts** at RGS level 4, under 125 headings at levels 2 and
  3, for 408 rows. RGS 3.8 carries some 1 100 level-4 accounts in its *Basis*
  filter alone; the selection keeps what a trading and services B.V. books
  and leaves out housing corporations, healthcare, agriculture, the sole
  trader's private accounts, the *werkkostenregeling* detail and the
  actual-cost and revaluation variants of every fixed asset.
- **The names are RGS's own short descriptions**, except where RGS gives the
  same short name to several accounts (`Verkrijgings- of vervaardigingsprijs`
  under every fixed asset), where the full description is used.
- **Every account type is a reading of the RGS debit/credit column and of the
  taxonomy concept the account maps to**, never a guess from a prefix outside
  the pack.

RGS splits revenue by the box of the VAT return it belongs in — `WOmzNohOlh`
is turnover from goods at the standard rate, question 1a — and the golden
scenario books each sale on the account that says so. Nothing in the engine
reads that correspondence: the box is filled by the tax, as everywhere else.

## The taxes

`taxes.json` carries the rates of article 9 of the *Wet op de omzetbelasting
1968*: **21 %** (paragraph 1), **9 %** (paragraph 2 (a) and table I) and the
**zero rate** of table II, with the history of the reduced rate — **6 % until
31 December 2018, 9 % from 1 January 2019** (Belastingplan 2019, Stb. 2018,
504, which replaced «6 percent» by «9 percent»). The history starts on
**1 October 2012**, the day the standard rate became 21 % (Stb. 2012, 321);
older rates are not in the pack.

Beyond the rates: the intra-Community supply of goods (table II, part a, item
6) and of services (article 6(1)), the export (table II, part a, item 2), the
domestic reverse charge on both sides (article 12(5) and articles 24b and
following of the *Uitvoeringsbesluit*), the intra-Community acquisition of
goods and of services, a service bought from outside the Union, an import under
an *article 23* licence, the exempt letting of immovable property (article
11(1)(b)), and one tax whose deduction is excluded by the *Besluit uitsluiting
aftrek omzetbelasting 1968* — business gifts, staff provisions, the
*voeren van een zekere staat* — which books its VAT on the cost account of the
line and nothing in box 5b.

**No cash accounting.** Article 26 lets the minister designate businesses that
do not usually supply other businesses to account on receipts. It is a
designation, not the general rule, and it is not in v0.1.

**No small-business scheme.** The *kleineondernemersregeling* of article 25a is
an exemption a business opts into, and paragraph 4 forbids it to mention VAT on
an invoice *in any way*. So the pack carries no `small_business` sentence at
all: the right sentence for a KOR invoice is none.

## The declaration

`tax_report.json` is the **aangifte omzetbelasting** as it stands in 2026,
code `NL-OB-AANGIFTE`, with the rubrics of the Belastingdienst's own
*Toelichting bij de btw-aangifte 2026*, each carrying the element of the Dutch
Taxonomy that holds it in the digital return (`xml_element`,
`bd-i:TaxedTurnoverSuppliesServicesGeneralTariff` for 1a's turnover).

| Rubric | Is |
|---|---|
| 1a–1e | domestic supplies: high rate, low rate, other rates, private use, 0 % or not taxed with you |
| 2a | domestic reverse charge, where the VAT was reversed **to you** |
| 3a–3c | exports, intra-Community supplies (to be itemised on the ICP statement), installation and distance sales |
| 4a–4b | supplies to you from outside and from inside the Union |
| 5a | VAT owed, the sum of the tax columns of 1 to 4 |
| 5b | input VAT |
| 5g | total to pay or to reclaim — 5a minus 5b, negative for a refund |

**5c to 5f are not there.** The subtotal, the reduction under the
small-business scheme and the two estimates are rubrics of earlier versions of
the return; the 2026 entrypoint of the Dutch Taxonomy (`bd-rpt-ob-aangifte-2026`)
holds 5a, 5b and the total and nothing between them, so the pack declares the
three it can source.

**The cadence is the quarter**, and it is proposed to everybody: article 25(1)
of the *Uitvoeringsregeling AWR 1994* makes the calendar quarter the period,
the month applying where the inspector demands it or the taxpayer files
monthly, and paragraph 3 lets the inspector set another — the year. **The
deadline is the last day of the month after the period** (AWR, article 19(1)),
and article 19(5) excludes the general extension of time limits, so a date that
falls on a weekend does not move.

**The ICP statement** (*opgaaf intracommunautaire prestaties*, article 37a) is
what `ec_sales_list()` computes: the lines of box 3b, per customer and per
nature. It is not declared as a form, because a pack declares one form — see
[`../../docs/international.md`](../../docs/international.md) — and no brick
writes its file yet.

## The financial statements

`statements.json` carries the models of the *Besluit modellen jaarrekening*
that a small B.V. uses:

| Code | Is |
|---|---|
| `NL-BMJ-C` | balance sheet, **model C** — the vertical layout a company under article 2:396 of the Civil Code may choose (art. 1(2) of the decree) |
| `NL-BMJ-E` | profit and loss account, **model E** — the categorical layout, vertical (art. 1(1)) |

The mapping follows the dataset the RGS publishes beside the chart,
which links every RGS code to the concepts of the Dutch Taxonomy, `jenv-bw2`
among them: `BVorDebHad` is `TradeReceivables` under `Receivables`, so it is on
line B.II. Every line reads a set of RGS prefixes; the only account split
between two lines is VAT and the suspense accounts, which are receivables in
debit and liabilities in credit.

Model C ends on E, *assets less current liabilities*, and puts long-term debt,
provisions and equity below it. Line **I** is not in the model: it is the sum
of F, G and H, printed so that a reader sees it equal E once the year is
closed. The fact keys of the taxonomy are not declared (`xbrl` is null): the
Dutch Taxonomy names plain elements, which the format cannot hold yet.

## The close

`closing_style` is `result_accounts`: the result lands on `BEivOreRvh`,
*Resultaat van het boekjaar*, inside *onverdeelde winst* (line H.VI), which is
where article 11 of the decree wants an unallocated result shown. Retained
earnings are `BEivOvrAlr`, *Algemene reserve*, under other reserves.

## The invoice

Article 35a of the VAT law lists what an invoice carries, and the mentions of
`pack.json` are the sentences it requires: **«btw verlegd»** where the
customer owes the tax (point m, which is the law's own wording), a reference to
table II for an intra-Community supply or an export, and to article 11 for an
exemption (point l). Numbering follows point b — *een opeenvolgend nummer, met
één of meer reeksen*.

**Electronic invoicing is not an obligation, to anybody.** Contracting
authorities have had to *receive* EN 16931 invoices since 18 April 2019
(article 6 of the *Aanbestedingsbesluit*, Stb. 2018, 321); no text obliges a
business to *send* one, to the State or to another business, and article 35b(1)
of the VAT law makes an electronic invoice subject to the customer's
acceptance. The pack declares the Peppol BIS 3.0 profile — which carries the
Dutch rules — with the Chamber of Commerce number (EAS `0106`) and the Dutch VAT
number (EAS `9944`), and **no `mandatory_from`**.

## The golden scenario

`golden/scenario.json` is a year of a Dutch trading and services B.V. filing
quarterly: both positive rates, a credit note, an intra-Community supply of
goods and one of services, an export, an intra-Community acquisition, a service
from each side of the Union's border, a domestic reverse charge on each side,
an exempt letting, a purchase whose deduction is excluded and a fixed asset.
The third quarter ends in a refund (5g = −630). The result of the open year,
23 945 euros, is the gap between line E and line I of the balance sheet until
the year is closed.

## What a Dutch reviewer should look at first

1. **The selection of RGS accounts.** 283 of the *Basis* filter, chosen for a
   trading and services B.V. Whether a different selection — or the whole
   filter — serves a small business better is a practitioner's call.
2. **The account types**, read from the debit/credit column and the taxonomy
   mapping. `BLimKru*` (items in transit) is typed as a current asset rather
   than cash.
3. **Model C and model E.** A small B.V. may also use model A, and model I
   for the profit and loss account (starting from the gross margin); the
   micro-entity of article 2:395a is outside the decree altogether.
4. **Pensions under *sociale lasten*** in model E; article 2:382 asks for them
   separately in the notes.
5. **5c to 5f.** The pack follows the 2026 taxonomy; if the portal still prints
   intermediate lines, they are totals the format can add.
6. **Numbering.** Article 35a asks for a *consecutive* number; the pack says
   `gapless_per_year`. `sequential` is defensible too.
7. **The tax point.** Article 13(1) is declared as `invoice_if_issued`; article
   13(2), the tax due on an earlier payment, cannot be said because the core
   has no prepayment document.
8. **The BUA threshold.** Article 1a of the *Besluit uitsluiting aftrek* only
   excludes deduction above an amount per person per year; the tax code is
   the answer once that question is settled, not the question.
9. **Private use (1d)**, the 13 % canteen rate (1c) and distance sales (3c) are
   declared and no tax of the pack posts to them.
10. **The English labels** are, for the return, the Belastingdienst's own
    Explanatory notes; everything else was translated here — see
    [`i18n/README.md`](i18n/README.md).
