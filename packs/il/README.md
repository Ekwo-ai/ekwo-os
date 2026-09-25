# Israel

Everything Israel adds to Ekwo, as data: a chart of accounts, the journals,
the 18% value added tax with its zero-rated exports and its Eilat exemption,
a periodic VAT report built on what the Value Added Tax Law and its
Regulations ask a registered dealer to report, the statement of financial
position and the statement of profit or loss of IAS 1, and the sentence the
law puts on a self-invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content
came from and which decisions it rests on, so that an Israeli accountant
reading the pack can disagree with a specific sentence rather than with the
whole of it.

**Status: `community`.** Nobody who files an Israeli VAT return has reviewed
it. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds eleven texts.

**The Knesset's own official National Legislation Database
(מאגר החקיקה הלאומי, `main.knesset.gov.il`) lists every Israeli law and every
amendment to it, and did not serve a fetchable consolidated text to this
research pass — its pages did not render outside a browser.** `gov.il` itself
refused every unauthenticated request this research pass tried, for every one
of its pages this pack cites, the same finding `packs/ae/`'s README records
for `uaelegislation.gov.ae`. What this pack cites instead for the law and the
regulations is **Nevo** (`nevo.co.il`), a private legal publisher and not a
government body — named as exactly that in the `publisher` field of every
entry that relies on it — because it is the consolidated text every Israeli
professional source this pack's research read in turn cites, and reading the
statute itself rather than a professional's paraphrase of it was judged the
better source even where the publisher is not official. **This is the first
thing a reviewer with access to a working copy of the National Legislation
Database, or to Reshumot (the Official Gazette) directly, should check the
pack against.**

| What | Text | Where this pack read it |
|---|---|---|
| The rate, the zero-rated exports and services, section 31's exemptions, the deduction of input tax, the charge on an import of goods | Value Added Tax Law, 5736-1975 | Nevo |
| The self-invoice on an imported service, the blocked input tax on a private vehicle, invoice numbering | Value Added Tax Regulations, 5736-1976 | Nevo |
| The Eilat exemption | Free Trade Area (Eilat) Law (Exemptions and Tax Reductions), 5745-1985 | Nevo |
| The rate itself — 18% from 1 January 2025, 17% from 1 October 2015 | Value Added Tax Order (Rate of Tax on a Transaction and on Import of Goods), 5765-2005, as amended | Nevo, corroborated by the Tax Authority's own announcement of the 2025 change |
| The reporting and payment dates, the monthly/bimonthly turnover threshold | The Tax Authority's own yearly notice (gov.il) | gov.il (cited by URL; not rendered by this research pass — see above) |
| The invoice allocation-number regime | The Tax Authority's own service and guidance pages (gov.il) | gov.il (cited by URL; not rendered by this research pass) |
| That a reporting corporation prepares its statements under IFRS | Accounting Standard 29 of the Israel Accounting Standards Board; Securities Regulations (Annual Financial Statements), 5770-2010 | The Board's own site; Nevo |

## The chart of accounts, and why this one

**There is no statutory chart of accounts in Israel.** The Companies Law,
5759-1999 requires a company to keep books and prepare financial statements;
Accounting Standard 29 requires a *reporting corporation* — a public company,
and a private company that has issued bonds to the public — to prepare them
under IFRS from periods beginning 1 January 2008; a private company outside
that definition is bound by no statute to a specific chart or a specific
framework. This pack's research found no official, numbered reference chart
to transcribe — the same finding `packs/ae/`, `packs/sg/` and `packs/hk/`
each record for their own country.

- **Four digits, by class**, the same shape as the United Arab Emirates,
  Singapore and Hong Kong packs: `1` assets, `2` liabilities, `3` equity, `4`
  revenue and other income, `5` cost of sales, `6` other expenses, `7`
  finance costs, `8` income tax.
- **Flat**, every account a leaf, grouped by the ranges of `statements.json`.
- **The accounts an Israeli VAT-registered business actually keeps**: VAT
  input and output tax, the net amount payable to or receivable from the Tax
  Authority, and a separate suspense account.
- **Written in Hebrew, the pack's own `defaults.language`**, in ordinary
  Israeli bookkeeping usage rather than as a transcription of any official
  document — see [`i18n/README.md`](i18n/README.md).

85 accounts, all postable. None was copied from a published chart.

## Taxes

**One rate, 18% since 1 January 2025.** Section 2 of the Law lets the
Minister of Finance set the rate by order after consulting the Knesset
Finance Committee; the order carried 17% from 1 October 2015 and has carried
18% since 1 January 2025 (Amendment 5784-2024, Reshumot 28 February 2024).
Israel has no reduced rate beside the standard one, so — the same case as
Togo's, whose reduced rate was abrogated — this pack carries one current
positive-rate code on each side, `IL-S-SR` and `IL-P-SR`, and does not code
the 17% rate that stopped applying before this pack was written: no
installation holds an open period at that rate for a code to correct, and
the change is recorded here and in each current code's own `legal_reference`
instead.

**What a sale can be, and where it lands on the return:**

| | Code | Box | Article |
|---|---|---|---|
| Standard-rated | `IL-S-SR` | 1, tax in 2 | סעיף 2 |
| Export of goods | `IL-S-ZR-EXP` | 3 | סעיף 30(א)(1) |
| Service to a foreign resident | `IL-S-ZR-SVC` | 3 | סעיף 30(א)(5) |
| Service in the Eilat area by an Eilat-area resident | `IL-S-ZR-EILAT` | 3 | חוק אזור סחר חפשי באילת, סעיף 5(ה) |
| Residential lease, ≤ 25 years | `IL-S-EX-RESI` | 4 | סעיף 31(1) |

**What a purchase can be:**

| | Code | Box |
|---|---|---|
| Standard-rated, fully recoverable | `IL-P-SR` | 5, 6 |
| Fixed asset, recoverable | `IL-P-CAP` | 7, 8 |
| Private vehicle — input tax blocked | `IL-P-BL-VEH` | none |
| Import of goods, per an import declaration | `IL-P-IMP` | 11, 12 |
| Imported service, self-invoice | `IL-P-RC-SVC` | 9 (value), 6 (recoverable), 10 (self-assessed) |
| Exempt | `IL-P-EX` | none |

**The Eilat exemption turns on two facts a document alone does not carry** —
that the seller is a resident of the Eilat free-trade area, and that the
service is supplied there — so `IL-S-ZR-EILAT` carries
`conditions: ["supply_nature"]` rather than a territory rule: modelling it as
`applies_when.seller_in` would need a sub-national territory code this pack's
research found no ISO 3166-2 entry for, and ISO 3166-2:IL's own districts do
not reach city level. A second, narrower exemption of the same Law — goods
brought into Eilat for sale there, section 5(א), with import VAT paid and
then refunded under the Law's own Regulations — is not carried at all; see
"What this pack does not carry".

**An import of goods is charged at the border, and this pack routes it
through the customs or forwarding agent rather than inventing a deferred
self-assessment Israeli law does not give an ordinary importer.** Sections 19
to 20 charge VAT on an import against the import declaration (רשימון יבוא),
collected by Customs; section 38(א) then lets the importer deduct it. In
practice an Israeli import reaches a business as one invoice from its customs
broker covering the customs value, the duty and the VAT together, and
`IL-P-IMP` is modelled on that invoice — unlike the United Arab Emirates
pack's `AE-P-IMP`, which models a genuine legal deferral its own law gives
the ordinary importer and which Israeli law does not.

**An imported service is a genuine self-assessment**, and is modelled the
same way `AE-P-RC-SVC` is: the recipient issues a self-invoice (חשבונית
עצמית) under regulation 6ג/6ד of the Regulations, self-charging the tax
(box 10, posted with a flipped sign so nothing is added to what is owed the
foreign supplier) and — to the extent the import serves a taxable activity —
deducting the same amount in the same report (box 6).

**Every base is a value without VAT**, as boxes 1, 3, 4, 5, 7, 9 and 11 ask.

## The return

`IL-VAT-PERIODIC` is not a transcription of the Tax Authority's own online
report screen: `gov.il` refused every request this research pass made for a
directly-fetchable copy of it, or of regulation 23 of the Regulations, which
most likely prescribes its content. The fifteen boxes below are this pack's
own numbering, built on what every independent professional description of
the report this research pass could read agrees it holds — output tax on
domestic sales, zero-rated sales, exempt sales, input tax split between
ordinary inputs and fixed-asset inputs, and the self-invoice and import
categories a distinct section of the Tax Authority's own guide to the
detailed electronic report file (PCN874) names apart from an ordinary
purchase. **A reviewer with access to the live report screen should check
this pack's box numbers against it before trusting them as more than this
pack's own scaffold.**

| Boxes | How |
|---|---|
| 1, 3, 4, 5, 7, 9, 11 | bases, summed from the ledger |
| 2, 6, 8, 10, 12 | taxes, summed from the ledger |
| 13, 14, 15 | the return's own arithmetic |

**The ordinary period is two months; a dealer above a turnover ceiling files
monthly.** Section 67(א2)(1) sets the ceiling and lets the Tax Authority
update it every 1 January by the rise in the price index — NIS 1,725,000 for
the 2025 tax year, per the Authority's own published table. Because the
ceiling is a fact about each dealer's own turnover and not an answer the Law
gives every dealer alike, this pack proposes no `period_default` — the
reading `packs/lu/` gives its own turnover-conditioned cadence.

**The deadline is the 23rd of the month after the period, for a dealer who
files online — which is the ordinary case.** Section 67(ב) sets a baseline
of fifteen days, which a dealer who still files on paper remains on; this
pack's research corroborates the 23rd across the Tax Authority's own yearly
notice and multiple independent professional sources, but could not open
regulation 23(ג) itself, which most likely sets it — see "Reviewing this
pack".

**Where the balance of a return lands.** `tax_payable` is `2110`,
`tax_receivable` is `1155`. Neither is posted to by any tax; they hold the
net of a filed return.

## The accounts

`statements.json` carries the statement of financial position and the
statement of profit or loss of IAS 1, for the reason given under "Sources" —
no statute binds most Israeli companies to a specific framework, and
Accounting Standard 29 binds only a reporting corporation to IFRS itself,
without fixing a numbered scheme of lines. The income statement is by
nature, which a small company's ledger holds without an allocation to
functions.

**Realised and unrealised exchange differences sit beside interest in
"Finance costs, net"** rather than each carrying a line of their own — a
simplification of a first pack, named rather than hidden.

**No fact keys.** Nothing checked here says which taxonomy, if any, an
Israeli filing uses, so `xbrl` and `taxonomy` are null throughout.

## Closing the year

`fiscal_year_default` is `calendar`, a proposal and nothing more. `closing_style`
is `retained_earnings`: the chart carries no current-year result account.
`3210 Dividends declared` sits beside retained earnings and is booked by
hand.

## On the invoice

**Numbering is `gapless`, with no yearly reset.** תקנות מס ערך מוסף,
התשל״ו-1976, תקנה 9ב requires a computer-issued tax invoice to carry a
running, sequential number with no gap and no repetition — 'ברצף רץ ללא
הפסק וללא חזרה על אותו מספר' — for as long as the dealer keeps books by
computer; this pack's research read the requirement from professional
secondary sources and could not itself open the regulation's text.

**One mention.** The self-invoice sentence regulation 6ג/6ד's own mechanism
implies, carried under `applies_when: reverse_charge`. This pack's research
found no article requiring a printed sentence on a zero-rated or an exempt
line.

**No default payment term and no late payment interest** are declared: this
research pass found no Israeli statute setting either between businesses
absent an agreement, and did not look long enough to say there is none.

**The tax point is the invoice where one was issued first, and otherwise
delivery or completion.** Section 24 (a sale of goods) and section 28 (a
service) put the charge at delivery or at completion; section 29 overrides
both and brings the charge forward to the invoice date wherever the invoice
was issued first — the ordinary case for a business that invoices on or
before delivery. A dealer under the cash-basis ceiling of section 21 may
instead be taxed on collection; this pack does not carry a `cash_basis` tax
for it, and a reviewer whose company qualifies should add one.

## Electronic invoicing

`einvoicing.obligation` is `none`, and `profile` is null — not because
nothing is required, but because what Israel requires is not a structured
invoice exchange this field has a vocabulary for. The Economic Efficiency
Law (Legislative Amendments to Achieve the Budget Targets for the 2023 and
2024 Budget Years), 5783-2023, from 1 January 2024, conditions a buyer's
input-tax deduction on a tax invoice above a declining threshold on the
seller first requesting an "allocation number" (מספר הקצאה) from the Tax
Authority's own system and printing it on the invoice — NIS 25,000 from
May 2024, NIS 20,000 from 1 January 2025, NIS 10,000 from 1 January 2026 and
NIS 5,000 from 1 June 2026. The invoice itself carries no required structured
format; the control is a real-time authorisation number, closer to a
clearance model than to a Peppol exchange between two parties' own software.
This gap is named rather than patched — see `docs/international.md` under
"Israel".

## What this pack does not carry

- **The allocation-number clearance control itself.** Nothing in the core
  reaches out to an external system when a document posts, and this pack
  does not pretend otherwise — see "Electronic invoicing" above and
  `docs/international.md`.
- **Section 5(א)'s Eilat import exemption**: goods brought into the Eilat
  free-trade area for sale there, VAT paid at import and refunded once the
  goods are shown to be in Eilat for that purpose (regulation 19 of the
  Eilat Law's own Regulations). Only the section 5(ה) services exemption is
  coded.
- **The cash-basis regime of section 21**, for a dealer under its turnover
  ceiling, taxed on collection rather than on the section 24/28/29 tax
  point.
- **מלכ״ר (a non-profit body) and מוסד כספי (a financial institution)**,
  which the Law taxes differently from an ordinary עוסק — a wage tax alone
  for the first, a wage-and-profit tax rather than output VAT for the
  second (חוק מס ערך מוסף, פרק ד׳). This pack carries only an ordinary
  registered dealer.
- **Section 47's cash-transaction restrictions**, a Money Laundering
  Prohibition Law concern rather than a VAT one, and out of scope here.
- **Corporate tax** (פקודת מס הכנסה), named only where a balance sheet needs
  an account for it (`8000`).
- **Fixed assets.** No `assets.json`.
- **Bank formats.** Nothing checked says which formats Israeli banks send.
- **Filing.** The return is filed on the Tax Authority's own site; submitting
  it is a credential and a format, not a pack.

## Reviewing this pack

Open an issue titled "Review: Israel". What a review is, and what it is not,
is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who
may say what". The points an Israeli-qualified accountant should read first,
roughly in the order the author is least sure of them:

1. **Every box of `IL-VAT-PERIODIC`**, built on secondary description rather
   than on a directly-fetched copy of regulation 23 or of the live report
   screen — see "The return".
2. **The 23rd-of-the-month deadline**, corroborated across several
   professional sources but not read from regulation 23(ג) itself.
3. **`IL-P-IMP`'s modelling as an invoice from the customs broker**, rather
   than from the foreign supplier — a simplification named in "Taxes" above.
4. **`IL-S-ZR-EILAT`'s `conditions` rather than a territory rule**, and the
   Section 5(א) goods-import exemption this pack does not carry at all.
5. **regulation 14(א)'s private-vehicle block and regulation 6ג/6ד's
   self-invoice mechanism**, both read from secondary sources.
6. **The choice of IAS 1 for `statements.json`**, where no Israeli statute
   binds most companies to it — see "Sources".
7. **The scope of "ordinary dealer"**: מלכ״ר and מוסד כספי are out of scope
   entirely, named above.
