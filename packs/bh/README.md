# Bahrain

Everything Bahrain adds to Ekwo, as data: a chart of accounts, the journals,
the 10% value added tax with its zero-rated exports, basic food, healthcare,
education, new-building construction, local transport and oil-and-gas
supplies, its exempt financial services and real estate, a periodic return
built from what the VAT Law and its Executive Regulations actually require a
return to hold, the statement of financial position and the income statement
of the IFRS for SMEs Standard, and what the law puts on a tax invoice. The
format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on.

**Status: `community`.** Nobody who files a Bahraini VAT return has reviewed
it. The figures are replayed against a quarter of books by
`tests/golden.test.ts`, which proves the pack is internally coherent and
proves nothing about whether it is right.

**Language.** The pack's own labels — the chart, the journals, the taxes, the
boxes of the return, the statement lines — are written in Arabic,
`defaults.language`, with a full English translation in
[`i18n/en.json`](i18n/en.json); see [`i18n/README.md`](i18n/README.md) for
why the two split the way they do. English is also where the National Bureau
for Revenue (NBR) publishes its own Law translation, Executive Regulations
guidance and VAT General Guide, so this pack's `legal_reference` commentary
is in English throughout.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and
beside it the key of the text that article is in. The register in
`pack.json` holds six texts, every one of them opened on 26 September 2026:

| What | Text | Where |
|---|---|---|
| The tax, its rate, zero-rating, exemptions, registration, tax invoices, the return | Legislative Decree No. (48) of 2018 promulgating the VAT Law | `lloc.gov.bh` |
| The increase of the standard rate from 5% to 10% | Law No. (33) of 2021, in force 1 January 2022 | `lloc.gov.bh` |
| The operative conditions behind each zero rate and exemption, registration and the tax invoice | Executive Regulations (Resolution No. (12) of 2018) | unofficial English translation, Grant Thornton Bahrain |
| The tax period thresholds, the return's filing and payment deadline, and the electronic-invoice permission | VAT General Guide, Version 1.13 | `nbr.gov.bh`, NBR's own hosted PDF |
| Where a return is filed and paid | NBR's own VAT section | `nbr.gov.bh` |
| The reporting framework behind the statements | IFRS Foundation, Jurisdictional Profile: Bahrain | `ifrs.org` |

**One gap this pack's research could not close: no official NBR or LLOC
English text of the Executive Regulations (Resolution No. (12) of 2018)
could be opened.** The Legislation and Legal Opinion Commission's own
database, which carries an English rendering of the Law and of Law No. (33)
of 2021, appears not to carry Bureau or Cabinet resolutions the same way.
Every citation to the Executive Regulations in this pack is therefore to an
unofficial English translation a professional firm circulates, clearly
marked so on its own cover page; the Arabic original is what actually binds,
and a reviewer fluent in it should check every Article number this pack
cites against it before the pack is trusted on that point.

**A second gap: the exact on-screen boxes of the live NBR return.** This
pack's research found no directly-fetchable primary text naming them letter
by letter or number by number — commercial guides describe a numbered
"Box 1" to "Box 17" form, but this pack's research could not verify that
description against an NBR original, so it is not used here.
`tax_report.json`'s boxes — `a1` through `j` — are this pack's own
construction, built on what Article 36 of the VAT Law requires a return to
disclose ("all Imports and Supplies ... made or received") and on what
section 12.3.1 of the VAT General Guide says the return states in substance
(total output VAT due, total input VAT recoverable). A reviewer who has
filed on the NBR portal should check this first.

## The chart of accounts, and why this one

**This pack's research found no chart of accounts a Bahraini company is
legally required to use.** What the law does prescribe is the reporting
framework: Article 219 of the Commercial Companies Law (Legislative Decree
No. 21 of 2001) conditions a clean audit opinion on financial statements
"prepared according to the international accounting standards", and the
IFRS Foundation's own Jurisdictional Profile records that Bahrain has
adopted IFRS Accounting Standards and the IFRS for SMEs Standard with no
local GAAP of its own, and that "all SMEs are permitted to use the IFRS for
SMEs Standard".

- **Four digits, by class**, the same shape as `packs/ae`, `packs/sa` and
  `packs/eg`: `1` assets, `2` liabilities, `3` equity, `4` revenue and other
  income, `5` cost of sales, `6` other expenses, `7` finance costs, `8`
  income tax.
- **Flat**, every account a leaf, grouped by the ranges `statements.json`
  reads.
- **The accounts a Bahraini company actually keeps**: VAT input and output
  tax apart from the net amount due to or from the NBR, VAT deferred at
  import, a self-assessment account for the domestic reverse charge, and an
  end-of-service gratuity provision under the Labour Law for the Private
  Sector (Law No. 36 of 2012) — this pack's research did not trace the
  provision to a specific article and a reviewer should check that citation.

109 accounts, all postable. None was copied from a published chart.

**No general corporate income tax.** Bahrain taxes no company's profit
except a hydrocarbon producer or refiner, under a separate regime this
VAT-focused pack's research did not open; accounts `2360` and `8000` exist
only so such a company has somewhere to book the charge, and every other
company simply never posts to them.

## Taxes

**One standard rate, 10%, since 1 January 2022** (5% from 1 January 2019):
Law No. (33) of 2021, Article Three, replacing Article 3 of the VAT Law;
Article Four of the same amending law keeps a contract concluded before the
change at 5% until its own term, amendment, renewal, or one year from the
change, whichever is earlier — a transitional rule this pack's 2026 golden
scenario does not exercise.

**What a sale can be:**

| | Code | Box |
|---|---|---|
| Standard-rated | `BH-S-STD` | a1, tax in a2 |
| Export of goods, Article 53 | `BH-S-EXPORT-GOODS` | b |
| Services to a non-resident customer outside the Kingdom, Executive Regulations Article 73 | `BH-S-EXPORT-SVC` | b |
| Basic food items, not sold by a restaurant or caterer, Executive Regulations Article 80 | `BH-S-ZR-FOOD` | b |
| Construction services for a new building, Executive Regulations Article 76 | `BH-S-ZR-CONSTRUCTION` | b |
| Educational services by a licensed institution to an enrolled student, Executive Regulations Article 77 | `BH-S-ZR-EDUCATION` | b |
| Preventive and basic healthcare services, Executive Regulations Article 69 | `BH-S-ZR-HEALTHCARE` | b |
| Local transport of goods or passengers by a licensed operator, Executive Regulations Article 78 | `BH-S-ZR-TRANSPORT` | b |
| Oil, oil derivatives and gas, Executive Regulations Article 79 | `BH-S-ZR-OILGAS` | b |
| Exempt financial services, Article 54 and Executive Regulations Article 81 | `BH-S-EXEMPT-FIN` | c |
| Sale or lease of real estate, exempt, Article 55 and Executive Regulations Article 82 | `BH-S-EXEMPT-REALESTATE` | c |

**What a purchase can be:**

| | Code | Box |
|---|---|---|
| Standard-rated, fully deductible | `BH-P-STD` | f1, f2 |
| Imported goods, tax collected by Customs Affairs on release | `BH-P-IMPORT` | f1, f2 |
| Goods or services received from a non-resident supplier, self-assessed | `BH-P-RC` | e1, e2, deductible share in f2 |
| A domestic purchase of zero-rated goods or services | `BH-P-ZR` | f1 |
| Exempt | `BH-P-EXEMPT` | none |

**All zero-rated sales share one box.** VAT Law Chapter Thirteen states the
zero rate once for every transaction Article 53 lists — exports, basic food,
healthcare, education, new-building construction, local transport, oil and
gas among them — and box `b` reads the same way: one figure for the whole
chapter, not a box per category the Law itself does not carry.

**Bahrain is outside the common system of VAT.** `supabase/seed/00_territories.sql`
carries a `BH` row with `eu_vat_scope: none`, so `exemption_code` is null on
every tax here and the exempting or zero-rating article is stated in
`legal_reference` instead, the `intracom_*` treatments do not exist, and
`vat_category` is carried without being required — this pack declares no
`einvoicing.profile`.

**Reverse charge reaches a non-resident supplier, not a domestic sector.**
VAT Law Article 4 puts the Tax on "a taxable Customer who receives Goods or
Services in the Kingdom from a Supplier who is a non-resident" — the shape
`BH-P-RC` models. Executive Regulations Article 66 offers a second, elective
domestic reverse charge to a Taxable Person "primarily engaged in making
Intra-GCC Supplies or Exports of Goods", granted by NBR certificate on
application; this pack carries no tax code for it; see "What this pack does
not carry".

**An import of goods is ordinarily paid at the border, not self-assessed on
the return.** Executive Regulations Article 65(A): Tax due at import is paid
to Customs Affairs at the Ministry of Interior, collected the way customs
duties are. Article 22 lets an NBR-approved, Customs-bonded importer defer
that cash payment to the periodic return instead; this pack models only the
ordinary case.

**Every base is a value without VAT**, as boxes a1, b, c, e1 and f1 ask.

## The return

`tax_report.json` files monthly or quarterly, and proposes neither as the
one every registrant gets: Executive Regulations Article 48(A) assigns
monthly filing to a Taxable Person whose annual Supplies exceed BHD
3,000,000, and quarterly filing (1 Jan–31 Mar, 1 Apr–30 Jun, 1 Jul–30 Sep,
1 Oct–31 Dec) to one below it — the cadence follows the registrant's own
turnover with no answer the Law gives everybody, the same shape
`packs/lu` records for its own return.

**The deadline is the last day of the month following the tax period, for
filing and for payment alike.** VAT Law Article 36: "by no later than the
last day of the month following the end of the Tax Period concerned." VAT
General Guide, section 12.3.2, states the same day for payment. **A return
is due even where nothing was sold or bought in the period** (Article 36,
second paragraph).

**No floor at zero.** A negative net figure is an excess the Taxable Person
carries forward under Article 58, or asks the Bureau to refund under Article
57 instead; neither article of this pack's research names a minimum number
of periods before a refund may be requested, unlike Saudi Arabia's and
Egypt's six.

## The statements

`statements.json` carries the statement of financial position and the
income statement built on the minimum line items of the general IFRS for
SMEs Accounting Standard, for the reason given under "Sources": this
research pass found no Bahraini text prescribing a line-by-line format of
its own for either statement. The income statement is by nature, which a
small company's ledger holds without an allocation to functions.

**VAT is a receivable and a payable, not income tax.** Bahrain has no
general corporate income tax; accounts `2360` and `8000` exist only for the
hydrocarbon sector's own regime, outside this VAT-focused pack's research.

**No fact keys.** Nothing checked here says which taxonomy, if any, a
Bahraini filing uses, so `xbrl` and `taxonomy` are null throughout.

## Closing the year

`fiscal_year_default` is `calendar`, a proposal and nothing more: a Bahraini
company chooses its own financial year end. `closing_style` is
`retained_earnings`: the chart carries no current-year result account.

## On the invoice

**Numbering is `sequential`.** Executive Regulations Article 52(A)(5): a Tax
Invoice states "a sequential invoice number" — a running, ordered sequence,
not, in the text this pack's research could open, an explicit no-gap rule.

**No default payment term and no late-payment interest** are declared: this
research pass found no Bahraini statute setting either between businesses
absent an agreement, and did not look long enough to say there is none.

**One invoice mention is declared: the reverse charge.** VAT Law Article 4
puts the obligation to account for Tax on the customer for a non-resident
supply; this pack's research found no article requiring a specific printed
sentence for it on the invoice itself, so the wording in `documents.mentions`
is this pack's own, the same way `packs/sa` writes its own reverse-charge
sentence where the text names the duty and not the words.

**The tax point is an approximation of a three-way rule.** VAT Law Article
12: Tax is due on the earliest of the date of supply, the date of the Tax
Invoice, or the date of payment — three triggers, where the closed
vocabulary of `tax_point` has room for two. `earliest_of_delivery_or_payment`
is the nearest value and what the rule reduces to whenever no invoice is
issued ahead of delivery or payment, the same gap `packs/sa`, `packs/ae` and
`packs/eg` record for their own three-way wording.

## Electronic invoicing

**No statute obliges an exchange of electronic invoices in Bahrain at the
day this pack was released.** VAT General Guide, section 9.2.1, records only
that a VAT-registered person "may issue and retain VAT Invoices, credit and
debit notes and other documents that evidence his supply in an electronic
form" without prior NBR approval, once the person's own systems meet
Executive Regulations Articles 52 to 54 — a permission to keep an invoice as
a PDF, not a structured-format exchange or a clearance regime. Public
reporting from mid-2026 describes a nationwide business-to-business
e-invoicing platform at the tender and procurement stage since 2022, with no
technical specification, network, party identifier or legislated date
published; this pack's own research could not open a directly-fetchable
primary NBR text confirming any of it, and carries nothing beyond the
General Guide's own permission. `einvoicing.obligation` is `none`: at
`released_at` no statute obliges anyone. See
[`docs/international.md`](../../docs/international.md), "From Bahrain."

## What this pack does not carry

- **The elective domestic reverse charge of Executive Regulations Article
  66**, granted by NBR certificate to a Taxable Person primarily engaged in
  intra-GCC supplies or exports of goods. See "Taxes" above.
- **The deferral of import VAT to the periodic return** (Executive
  Regulations Article 22), an NBR approval this pack's ordinary
  `BH-P-IMPORT` does not model. See "Taxes" above.
- **The list of basic food items itself.** VAT General Guide, section
  6.3.5: the schedule is "available on NBR website"; this pack's research
  did not open it, and `BH-S-ZR-FOOD` carries the rule and not the list.
- **The registration thresholds as a rule the core enforces.** Executive
  Regulations Articles 33 and 44, read with the VAT General Guide: BHD
  37,500 mandatory, BHD 18,750 voluntary, over a trailing or an anticipated
  twelve months. The core has no registration threshold of its own to
  enforce in any country.
- **A B2B or B2G electronic invoicing platform** — none is legislated yet.
  See "Electronic invoicing" above.
- **Withholding tax.** This VAT-focused pack's research did not establish
  whether Bahrain levies one.
- **The hydrocarbon sector's own income tax regime**, beyond the two
  accounts named for it.
- **Fixed assets.** No `assets.json`: whether a usual depreciation duration
  is prescribed by a text this research pass could open was not
  established.
- **Bank formats.** Nothing checked here says which formats Bahraini banks
  send.
- **Filing.** The return is filed and paid on the NBR's own online portal;
  submitting it is a credential, not a pack.

## Reviewing this pack

Open an issue titled "Review: Bahrain". What a review is, and what it is
not, is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and
who may say what". The points a Bahraini-qualified accountant should read
first, roughly in the order the author is least sure of them:

1. **Every Article number cited to the Executive Regulations**, sourced from
   an unofficial translation and not from an NBR or LLOC original — see
   "Sources".
2. **The boxes of `tax_report.json`**, this pack's own construction and not
   a transcription of the live NBR return.
3. **The statement of financial position and the income statement against a
   real IFRS-for-SMEs-prepared Bahraini set of accounts** — no
   Bahrain-specific citation backs the choice of line items.
4. **The end-of-service gratuity provision**, whose Labour Law article this
   research pass did not trace.
5. **`earliest_of_delivery_or_payment` as the tax point**, which drops the
   invoice-date trigger VAT Law Article 12 also names.
6. **The state of e-invoicing**, carried as "none" on research that could
   not open a primary NBR text past the General Guide's own PDF-retention
   permission.
