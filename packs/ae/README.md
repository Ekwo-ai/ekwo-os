# United Arab Emirates

Everything the United Arab Emirates adds to Ekwo, as data: a chart of
accounts, the journals, the 5 % value added tax with its zero-rated and
exempt supplies and its reverse charge, a VAT return built from what the
Executive Regulation says a return must hold, the statement of financial
position and the income statement of the IFRS for Small and Medium-sized
Entities Accounting Standard, and the sentences the law puts on a tax
invoice. The format is [`docs/packs.md`](../../docs/packs.md); this file
says which sources and decisions the content rests on, so that a UAE
accountant can disagree with a specific sentence rather than with the whole.

**Status: `community`.** Nobody who files a UAE VAT return has reviewed it.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

Electronic invoicing in the UAE is a 5-corner reporting model rather than a
Peppol exchange between the two parties' own access points. What the core
cannot yet say is in
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds nine texts. The two the rest of this file leans on most:

| What | Text | Where |
|---|---|---|
| The rate, scope, zero-rated and exempt supplies, the reverse charge, designated zones, tax invoices, tax periods and the return | Federal Decree-Law No. 8 of 2017 on Value Added Tax, and its Executive Regulation (Cabinet Decision No. 52 of 2017), both as amended and consolidated | `tax.gov.ae` |
| The electronic invoicing timeline, the 5-corner DCTCE model and PINT AE | Ministry of Finance, *UAE Electronic Invoicing Guidelines*, Version 1.1, 1 June 2026 | `mof.gov.ae` |

**Two texts rest on a secondary source.** Every date and figure about
Ministerial Decision No. 243 of 2025 (the Electronic Invoicing System) and
Ministerial Decision No. 244 of 2025 (its implementation timeline) rests on
the Ministry of Finance's Guidelines; the Decisions themselves should be
checked. The same holds for the three Cabinet Decisions the Guidelines name
for a domestic reverse charge (see "What this pack does not carry").

**No UAE text backs the statements.** Federal Decree-Law No. 32 of 2021 on
Commercial Companies, the law that would require accounting records and
financial statements, is not cited. The statement of financial position and
the income statement are built on the minimum line items of the IFRS for
SMEs Accounting Standard, with no UAE-specific legal citation for that
choice. This is the first thing a reviewer should check; the chart's own
`legal_reference` in `pack.json` says so.

## The chart of accounts, and why this one

**There is no legal chart of accounts in the United Arab Emirates**, as far
as could be established.

- **Four digits, by class**: `1` assets, `2` liabilities, `3` equity, `4`
  revenue and other income, `5` cost of sales, `6` other expenses, `7`
  finance costs, `8` corporate tax.
- **Flat**, every account a leaf, grouped by the ranges of `statements.json`.
- **Cost and accumulated depreciation adjacent**, right-of-use assets among
  them (IFRS 16).
- **The accounts a UAE company actually keeps**: VAT input and output tax,
  the amount payable to and receivable from the Federal Tax Authority, and
  import VAT self-assessed under the reverse charge (see "Taxes"). A
  provision for end-of-service gratuity is carried as a matter of practice
  (Labour Law), not traced to a specific article of Federal Decree-Law
  No. 33 of 2021; a reviewer should check that citation.

111 accounts, all postable.

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
registered importer.** Article 48(1) of the Decree-Law treats an importing
Taxable Person as making a taxable supply to themselves, provided (Executive
Regulation, Article 48(1)) it can show its Tax Registration and Customs
registration number at import. The Due Tax is self-assessed in the return,
so `AE-P-IMP` posts a self-assessed tax (factor `-100` on the output side,
so a purchase document still credits the output account) instead of
clearing an import-VAT account. Article 50 (the other importers) is not
carried.

**Domestic reverse charge: one goods class.** Article 48(3): crude or
refined oil, natural gas or pure hydrocarbons supplied between two
Registrants for resale or energy use. The supplier charges no Tax (Clause
3(a)), the recipient self-assesses it (Clause 3(b)), on written declarations
of use and of registration (Clause 4) — `conditions: ["buyer_certificate",
"buyer_status"]` on both `AE-S-DRC-HC` and `AE-P-DRC-HC`.

**Every base is a value without VAT**, as boxes d1, e, f, g1 and h1 ask.

## The return

`tax_report.json` is not the Federal Tax Authority's own VAT201 return form:
the boxes below are built letter by letter on the minimum content Article
64(5) of the Executive Regulation requires a Tax Return to hold — `d1`/`d2`
through `j`, named after the clause letters of that article. **A reviewer
who knows the live EmaraTax screen should check this first**: these boxes
and the portal's box numbers 1 to 13 almost certainly do not correspond one
to one, and nothing here claims they do.

| Boxes | How |
|---|---|
| d1, e, f, g1, h1 | bases, summed from the ledger |
| d2, g2, h2 | taxes, summed from the ledger |
| i1, i2, j | the return's own arithmetic |

**Box g2 is this pack's own addition**, not a clause of Article 64(5): the
article names only the *value* of a reverse-charge supply (g1), but Article
48(4)(a) of the Decree-Law requires the Tax on it to be accounted for. It is
the one box not transcribed from a lettered clause; check it against a real
filing.

**Quarterly by default, monthly by administrative assignment.** Article
62(1) of the Executive Regulation sets a standard Tax Period of three
calendar months; Article 62(2) lets the Authority assign another "where it
considers that necessary or beneficial", without a turnover figure. Larger
taxable persons are in practice assigned a monthly period, so `period` lists
both `month` and `quarter`; no threshold is invented.

**The deadline is exact.** Article 64(1): the return and the payment are
both due no later than the 28th day following the end of the Tax Period.

**Where the balance of a return lands.** `tax_payable` is `2110`, `tax_
receivable` is `1155`. Neither is posted to by any tax; they hold the net of
a filed return, matched against a payment to or a refund from the Federal
Tax Authority.

## The accounts

`statements.json` carries the statement of financial position and the
income statement of the IFRS for SMEs Accounting Standard, for the reason
given under "Sources". The income statement is by nature, which a small
company's ledger holds without an allocation to functions.

**VAT is a receivable and a payable, not current tax.** Current tax is
corporate tax under Federal Decree-Law No. 47 of 2022, which this
VAT-focused pack does not otherwise carry; the accounts (`1350`, `2130`,
`8000`) exist for a company to book the charge by hand.

**No fact keys.** Nothing checked here says which XBRL taxonomy, if any, a
UAE filing uses, so `xbrl` and `taxonomy` are null throughout.

## Closing the year

`fiscal_year_default` is `calendar`, a proposal only: a UAE company chooses
its own year end. `closing_style` is `retained_earnings`: the chart carries
no current-year result account. `3210 Dividends paid` sits beside retained
earnings and is booked by hand.

## On the invoice

**The tax invoice is a list of particulars** (Executive Regulation, Article
59(1)): "Tax Invoice", date, number, supplier's name, address and TRN, the
same for a Registrant recipient, each line with its rate and Tax, and —
under the reverse charge — a statement and the Decree-Law provision. A
simplified Tax Invoice (Article 59(2)) is allowed for a non-Registrant
recipient or up to AED 10,000 including Tax, never under the reverse
charge.

**Numbering is `sequential`.** Article 59(1)(d) asks for "a sequential Tax
Invoice number or a unique number which enables identification of the Tax
Invoice and the order of the Tax Invoice in any sequence" — no gap-free rule.

**One mention.** No article was found requiring a printed sentence on a
zero-rated or an exempt line — a UAE tax invoice already shows the rate of
Tax against each line (Article 59(1)(h)), which is what distinguishes them.
The one mention carried is the reverse-charge statement Article 59(1)(l)
requires.

**No default payment term and no late payment interest** are declared: no
UAE statute setting either between businesses absent an agreement was
found; a reviewer should confirm there is none.

**The tax point approximates a three-way rule.** Article 25 of the
Decree-Law takes the earliest of delivery or completion, payment, or the
Tax Invoice date; `tax_point` has room for two. `earliest_of_delivery_or_
payment` is what the rule reduces to in the ordinary case, Article 67
requiring the invoice within 14 days; it misses a supply invoiced late, or
paid before either delivery or an invoice.

## Electronic invoicing

The profile is `pint-ae`, the Peppol International invoicing specification
localised for the UAE. `obligation` is `mandatory`, phased by annual
revenue: voluntary from 1 July 2026; mandatory by 1 January 2027 at AED
50,000,000 or more, by 1 July 2027 for every other Person, by 1 October 2027
for a Government Entity, each with an earlier deadline to appoint an
Accredited Service Provider. `mandatory_from` carries 1 January 2027; the
full calendar, including the 24-month grace period within a VAT group, is in
`einvoicing.legal_reference` in `pack.json`.

**A 5-corner model (DCTCE).** Supplier (Corner 1) and buyer (Corner 4) each
sit behind an Accredited Service Provider (Corners 2 and 3), which report the
Tax Data of every Electronic Invoice to the Federal Tax Authority (Corner 5).
A party is
addressed by ICD `0235` followed by its 10-digit Tax Identification Number,
the first 10 digits of its 15-digit Tax Registration Number; `vat_scheme` is
left empty because no separate ISO 6523 code is registered for the 15-digit
TRN itself.

**PINT AE has its own six tax categories** — Standard Rate, Exempt from VAT,
Out of scope, Reverse Charge, Zero rated, Margin scheme — and they are not
the UNCL5305 letters `vat_category` holds. Each tax names its PINT AE
category in its own `legal_reference`, for a renderer to map.

## What this pack does not carry

- **The Electronic Invoice's additional mandatory fields** (Guidelines,
  section 10): the pack covers the VAT treatment, not the wire format.
- **Three domestic reverse charge classes** resting on a secondary source:
  electronic devices (Cabinet Decision No. 91 of 2023), precious metals and
  precious stones (Cabinet Decision No. 127 of 2024), and metal scrap
  trading (Cabinet Decision No. 153 of 2025). Only the hydrocarbon class of
  Article 48(3) of the Decree-Law is coded.
- **Designated zones** (Decree-Law, Articles 50 to 52; Executive Regulation,
  Article 51): treated as outside the State for goods; the core has no
  place-of-supply engine that reaches a sub-national zone.
- **Article 50's "Special Rules of Import"**, for the importer who pays Tax
  at, or through, Customs directly. Account `1157` exists in the chart for
  this case; no tax code posts to it.
- **Apportionment of input tax for a partly exempt business** (Executive
  Regulation, Article 55) and adjustment under the Capital Assets Scheme
  (Articles 57 to 58).
- **Withholding tax**: no UAE withholding tax regime on payments abroad was
  found.
- **Corporate tax** (Federal Decree-Law No. 47 of 2022): estimated in
  `corporate_tax.json`; see "Corporate income tax" below.
- **Fixed assets.** `fixed_assets.json` carries the accounting rules and usual lives; see
  "Fixed assets" below and "Fixed assets: what `fixed_assets.json` leaves out".
- **Bank formats.** Nothing checked says which formats UAE banks send.
- **Filing.** The return is filed on EmaraTax; submitting it is a credential
  and a format, not a pack.

## Reviewing this pack

Open an issue titled "Review: United Arab Emirates". What a review is, and
what it is not, is in [`docs/packs.md`](../../docs/packs.md) under
"Certification, and who may say what". The points a UAE-qualified accountant
should read first, roughly in order of least certainty:

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
   is not cited.
6. **`earliest_of_delivery_or_payment` as the tax point**, which drops the
   third trigger — the invoice date — that Article 25(7) of the Decree-Law
   also names.
7. **The single domestic reverse charge class coded** (hydrocarbons) against
   the three named only in a secondary source.
8. **`einvoicing.mandatory_from`**, which names the earliest phase
   (≥ AED 50,000,000 revenue) and not a single date every business meets.

## Corporate income tax: what `corporate_tax.json` leaves out

The section carries the rates of Federal Decree-Law No. 47 of 2022, art. 3
and Cabinet Decision No. 116 of 2022 (0 % up to 375 000 AED, 9 % above), the
75 % limit on tax losses (art. 37), the half-deduction of entertainment
(art. 32) and the non-deductible expenditure of art. 33. It starts from line
8 of `AE-IFRSSME-IS`, the profit before corporate tax. A rule that is missing
makes an estimate too high or too low by something a reader can name; these
are the ones to name.

| Not carried | Why |
|---|---|
| Small Business Relief (art. 21; Ministerial Decision No. 73 of 2023) | An election (revenue of 3 000 000 AED or less) that treats the company as having no Taxable Income and switches off loss relief (art. 21, para 2(d)); the module has no such election. A company that elects it overstates its estimate. The announced extension to periods ending on or before 31 December 2029 (Ministerial Decision No. 131) should be checked against the decision's text. |
| General interest deduction limitation (art. 30: net interest deductible up to 30 % of EBITDA, carried forward ten periods) | Needs the company's EBITDA and a de minimis amount set by Ministerial decision. A company over the limit declares the disallowed interest as an amount. |
| Qualifying Free Zone Persons (arts 3, para 2, and 18) | A 0 % rate on Qualifying Income, defined by Cabinet decision; the module cannot split the base. |
| Top-up Tax on Multinational Enterprises at an effective 15 % (art. 3, para 3) | A group tax set by Cabinet decision; the section has no shape for one. |
| Losses: pre-regime losses (art. 37, para 3), continuity of ownership (art. 39), transfers within a group (art. 38) | They depend on facts the books do not hold. The company enters only the losses it may use. |
| Exempt income, participation exemption, qualifying group and restructuring reliefs (arts 22 to 27) | Conditions the company must judge; no flat rule to write. |
| Disallowed fines, donations, bribes and foreign income tax on named accounts | The chart has no account for any of them: the rules wait for the company to state an amount. Entertainment is the only rule that names an account, `6310`, which holds nothing else. |
| Related-party and connected-person adjustments (arts 34 to 36) | Not carried. |
| Prepayments | None found in the Decree-Law; nothing is declared. |
| Credits (foreign tax credit, art. 47; withholding tax credit, art. 46; refund, art. 49) | The amount is the company's to declare, so `credits` is empty. |
| A threshold shared out over a short period | Cabinet Decision No. 116 says "in the relevant Tax Period"; no pro-rating is applied, the 375 000 is applied whole. |
| Language of the labels | The pack declares no language besides English, so there is no `corporate_tax` key to translate. |

## Fixed assets

`fixed_assets.json` is practice rather than law, and says so on every category.
The United Arab Emirates has no table of useful lives: IFRS for SMEs, Section 17
(paragraphs 17.18 to 17.22) asks the entity to estimate the life of its own asset
and to pick the method that reflects how it consumes it, and Federal Decree-Law
No. 47 of 2022, Article 20, starts the Taxable Income from the Accounting Income
of financial statements prepared under the accounting standards accepted in the
State. The Decree-Law sets no depreciation table. The durations are common
practice, except the ten-year ceiling of goodwill (paragraph 19.23) and of an
intangible whose life cannot be established (paragraph 18.20).

- **Prorata:** real days from the day the asset is available for use
  (paragraph 17.20), for both methods. The standard does not fix a convention; a
  company that counts months sets `prorata = 'months'` on the asset.
- **Declining balance:** no cap, switch to the straight line on. No category uses
  it: nothing suggests a coefficient.
- **Disposal:** `net_result`, on `4750` (gain) and `6960` (loss), as paragraphs
  17.28 and 17.30 recognise one difference in profit or loss.
- **Right-of-use assets** (`1690`) have no category: the pack's statements are
  those of IFRS for SMEs, whose Section 20 does not capitalise an operating lease.

## Fixed assets: what `fixed_assets.json` leaves out

| Not carried | Why |
|---|---|
| Tax depreciation of an investment property held at fair value (Ministerial Decision No. 173 of 2025: the lower of the tax written-down value and 4 % of the original cost per twelve months, on election of the realisation basis of Decree-Law art. 20(3), with recapture on realisation) | Rests on the Ministry of Finance's announcement; the decision's own text should be checked. The module has one depreciation, the accounting one, and cannot keep a tax depreciation distinct from the book charge. |
| Realisation-basis election for assets on capital account (art. 20(3)(b)) | A tax election on gains and losses; the module has no tax column. |
| Revaluation and fair value of property, plant and equipment or investment property | The module depreciates cost only. |
| Impairment, component depreciation (paragraph 17.16), a capitalisation threshold | The module has no such vocabulary. |
| A depreciation by units of production | The module refuses it by name. |
| Capital Assets Scheme of the VAT Executive Regulation (arts 57 to 58) | A VAT adjustment, not a depreciation. |
