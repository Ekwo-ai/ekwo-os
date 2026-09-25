# Philippines

Everything the Philippines adds to Ekwo, as data: a chart of accounts, the
journals, the value-added tax of the National Internal Revenue Code with its
zero rate and its exemptions, a withholding mechanism on services bought from
a non-resident, the quarterly return, and a statement of financial position
and a statement of comprehensive income grouped by this chart's own account
ranges. The format is [`docs/packs.md`](../../docs/packs.md); this file says
where the content came from and which decisions it rests on, so that a
Philippine accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Status: `community`.** Nobody who files a Philippine VAT return has
reviewed it. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**Language: `en`.** The National Internal Revenue Code and the Bureau of
Internal Revenue's own forms are written and administered in English, so the
pack's labels are English throughout; no other version is carried.

## Sources

Every tax, box and mention carries its own `legal_reference`, and beside it
the key of the text that article is in. The register in `pack.json` holds
eight texts, all consulted on 25 September 2026.

| What | Text | Where |
|---|---|---|
| The rate, zero-rated export sales, exempt transactions, invoicing rules, filing deadline | Republic Act No. 10963 (TRAIN Law) and Republic Act No. 11976 (Ease of Paying Taxes Act), amending the National Internal Revenue Code of 1997 | Supreme Court of the Philippines, E-Library — read directly |
| The zero-rating regime for IPA-registered export enterprises (out of scope) | Republic Act No. 12066 (CREATE MORE Act) | Supreme Court of the Philippines, E-Library |
| The quarterly VAT return and its item numbers | BIR Form No. 2550Q, April 2024 (ENCS), and its Guidelines and Instructions | Bureau of Internal Revenue, `bir-cdn.bir.gov.ph` — read directly |
| The value-added tax withheld on services from a non-resident | BIR Form No. 1600-VT (January 2018) and its Guidelines and Instructions | Bureau of Internal Revenue — read directly |
| Electronic invoicing (the Electronic Invoicing/Receipting System) | Revenue Regulations No. 8-2022 | Bureau of Internal Revenue |
| Where the return is filed electronically | eFPS | `efps.bir.gov.ph` |

Most of this pack was read from the Supreme Court E-Library's and the
Bureau's own PDFs directly this session — a marked improvement over several
earlier packs of this repository, whose primary texts resisted extraction.
Where a text could not be opened as primary text and a secondary summary was
used instead, the rule's own `legal_reference` says so.

## The chart of accounts, and why this one

**The Philippines prescribes no chart of accounts.** What this session could
verify is that the Financial and Sustainability Reporting Standards Council,
under the authority of the Board of Accountancy (Republic Act No. 9298, the
Philippine Accountancy Act of 2004), adopts the Philippine Financial
Reporting Standards, including one for small and medium-sized entities and
one for small entities, and that the Securities and Exchange Commission
requires financial statements filed with it to follow one of those
frameworks — neither the Council's own standards nor the Commission's Rule 68
prescribe a numbered account code, and this session did not open either
text in full. So the chart is written, not transcribed: four digits by
class, the numbering the sibling Southeast Asian packs (Thailand, Vietnam,
Singapore) use — `1` assets, `2` liabilities, `3` equity, `4` revenue, `5`
cost of sales, `6` operating expenses, `7` finance items, `8` income tax —
with the accounts a value-added-tax-registered Philippine company's books
hold: output and input value-added tax, the VAT payable account a filed
return settles to, VAT withheld on services from a non-resident pending its
own monthly remittance, and the SSS, PhilHealth and Pag-IBIG contributions
and 13th-month pay every Philippine payroll carries. 156 accounts, all
postable. None was copied from a published chart.

**Six value-added-tax-related accounts.** `2100` holds the output tax and
`1150` the input tax — the two the taxes post to. `2110` and `1155` are
where a filed return's balance lands: `tax_payable` and `tax_receivable`,
apart from the posting accounts and both reconcilable, so a payment to the
Bureau and a refund from it are each matched against their own account.
`2115` holds the value-added tax a company withholds on a payment to a
non-resident, pending its own remittance on BIR Form No. 1600-VT.

## Taxes

**One combined rate, one posting.** Sections 106(A) and 108(A) set the rate
at 12% of "gross sales", the term Republic Act No. 11976 substituted for
"gross selling price"/"gross value in money"/"gross receipts" without
changing the figure. `PH-S-STD` and `PH-P-STD` carry it as one rate and one
posting.

**Exports and cross-border services are zero-rated, separately.**
`PH-S-ZR-EXP` is the sale and actual shipment of goods from the Philippines
paid for in acceptable foreign currency, under Section 106(A)(2)(a)(1);
`PH-S-ZR-SVC` is a service performed for a person engaged in business
outside the Philippines, or a nonresident outside it, paid for in acceptable
foreign currency, under Section 108(B)(2). Both report their value in item
32 and carry no tax. Neither subparagraph is one of the export-sale
categories a conditional sunset clause of Section 106(A)(2) reduces to 12%
once an enhanced VAT-refund system is certified (that clause reaches only
the raw-material and Omnibus Investment Code categories the same
subparagraph lists); this session found nothing suggesting the clause has
been triggered even for those.

**A residential lease at or below the statutory threshold is exempt, and
carries no box.** `PH-S-EX` and `PH-P-EX` — the golden year uses a
residential unit rented to a tenant and an office space rented from an
individual landlord — report a base and nothing else under Section 109(Q):
nothing read this session shows BIR Form No. 2550Q asking for the value of
an exempt sale on a box of its own, the way it asks for zero-rated sales at
item 32; this pack reports it at item 33 instead, which the form itself
carries as "Exempt Sales".

**Value-added tax withheld on a service bought from a non-resident.**
`PH-P-RC` is a service performed for the company by a person not established
in the Philippines: Section 108(A) taxes "the performance of all kinds of
services in the Philippines for others", and the company itself withholds
and remits the 12% rather than the non-resident charging it, filing BIR Form
No. 1600-VT "on or before the tenth (10th) day of the month following the
month in which the withholding was made" (the form's own Guidelines, read
directly). It posts the value to item 45, the withholding liability to
`2115`, and the same amount to `1150` as an immediate input tax credit.
**This overstates how fast the credit is available**: BIR Form No. 1600-VT
is a monthly return this pack does not carry as a `tax_report.json` — it
touches no box of BIR Form No. 2550Q at all — while the input credit is
claimed on the quarterly return's own item 45; this code posts the
withholding and the credit on the same document, exactly the simplification
`packs/th/`'s `TH-P-RC` names for Thailand's VAT 36/VAT 30 pair. See
`docs/international.md`.

## The return

`PH-VAT-2550Q` is this pack's own reading of BIR Form No. 2550Q (April 2024,
ENCS), filed quarterly. **Its box numbers — `31`, `32`, `33`, `37`, `44`,
`45`, `51`, `61` — are the form's own printed item numbers**, read directly
from the form itself, unlike several other packs of this repository whose
box codes are invented because the form's own wording could not be read.
**What this pack does not model are the form's own schedules and
adjustments**: item 34's running total and items 35-36 (the Ease of Paying
Taxes Act's output-tax adjustment for uncollected and recovered
receivables, Section 110(D)); items 38-43 (input tax carried over,
deferred on capital goods, transitional or presumptive); items 46-50
(importations, other current purchases, purchases with no input tax,
exempt importations); items 52-60 (deductions from and adjustments to
input tax, including the capital-goods amortisation schedule of Part V);
and Part II (items 15-30: tax credits, penalties, payment details) and
Part V's four schedules entirely. Item 37 is therefore taken directly from
item 31's output tax, item 51 directly from items 44 and 45, and item 61
(`Net VAT Payable/(Excess Input Tax)`) directly from items 37 and 51.

**The deadline is exact.** Twenty-five days after the close of the quarter
(Section 114(A), as amended), filed and paid electronically through eFPS or
manually. The same subsection's earlier proviso for monthly payment is read
as superseded by its own later proviso ("beginning January 1, 2023 ...
within twenty-five (25) days following the close of each taxable quarter"),
which matches secondary reporting of Revenue Memorandum Circular No. 5-2023
that BIR Form No. 2550M (the monthly return) is no longer required — this
session did not read that Circular's own primary text.

**Item 61 is not floored to zero.** A negative figure is an excess input
tax carried to the next quarter rather than a refund claimed automatically
(Section 112); this session did not read that section closely enough to
model the choice between carry-over and refund, which stays a figure only.

## The statements

`PH-BS` and `PH-IS` are original: lines grouped by the code ranges this
chart's own numbering gives its accounts — current and non-current, revenue
and cost of sales, operating expenses and depreciation — the same
classification a Philippine Financial Reporting Standard would use without
transcribing that standard's own line items or their numbering, because this
session could not open the Financial and Sustainability Reporting Standards
Council's text (see "Sources"). No fact keys: nothing here was checked
against a taxonomy. `closing_style` is `retained_earnings`: this chart keeps
no separate current-year-result account, so the open year's result sits on
the income and expense accounts themselves (grouped as `E-RESULT` on the
balance sheet) until the close.

## On the invoice

**Section 113(B)**, as amended by Republic Act No. 11976 and read directly
this session, requires a VAT invoice to state that the seller is
VAT-registered, followed by the seller's Taxpayer Identification Number;
the total amount the purchaser pays with VAT shown as a separate item; "the
term 'VAT-exempt sale'" or "'zero-rated sale'" written or printed on the
invoice for those transactions; and, for a sale invoicing a mix of taxable,
exempt and zero-rated goods or services, a breakdown of the sale price
between the three. Section 237(A), as amended by the same Act, requires an
invoice at the point of a transaction valued at P500 or more (adjusted
every three years by the Consumer Price Index) and, for a VAT-registered
person, "regardless of the amount of the sale". **Numbering is
`sequential`**: Section 238 asks for an invoice "serially numbered", not, in
so many words, a series with no gap across a whole registration. **No legal
mentions are declared**: the two required sentences above ("VAT-exempt
sale", "zero-rated sale") are conditions on the tax lines themselves
(`vat_category` `E` and `G`) rather than a document-wide mention this
format's `documents.mentions` block would carry, and this session found no
further sentence a regulation requires beyond them. **No payment term is
declared**: this session found no provision of the Civil Code or the Tax
Code setting one between businesses in the absence of an agreement, and did
not look exhaustively enough to say there is none.

## Electronic invoicing

`einvoicing.profile`, `mandatory_from` and `obligation` are all left empty.
The Bureau of Internal Revenue operates the Electronic Invoicing/Receipting
System (EIS) under Sections 237 and 237-A of the Tax Code (Revenue
Regulations No. 8-2022): a covered taxpayer — initially large taxpayers,
e-commerce businesses and exporters of goods and services — issues a
structured electronic invoice and transmits sales data to the Bureau's own
platform, `eis.bir.gov.ph`, rather than exchanging a document with a buyer's
own access point. It is a clearance/reporting regime, the same shape as
`packs/mx/`'s CFDI, `packs/vn/`'s hóa đơn có mã and `packs/sa/`'s FATOORA,
and not an exchange built on EN 16931: no component of `packages/formats/`
writes the EIS's own JSON schema or talks to its API, so a document Ekwo
posts is not an Electronic Invoice within the Bureau's own meaning, and
`mandatory_from` with no `profile` would claim otherwise. By secondary
reporting this session could not verify against a primary Revenue
Memorandum Circular, mandatory compliance for the large-taxpayer/exporter
group is due to be reached by 31 December 2026 — close enough to this
pack's own `released_at` that a reviewer should check the current date
against the Bureau's own announcements before relying on this pack's silence.

## What this pack does not carry

- **Percentage tax (Section 116).** A non-VAT-registered person whose gross
  annual sales do not exceed the Section 109(CC) threshold pays 3% of gross
  quarterly sales on BIR Form No. 2551Q instead of VAT. This pack models
  only a VAT-registered company; percentage tax is out of scope entirely,
  by instruction, and is not a gap of what this session could read — it is
  a different regime a future pack, or a chart audience of this one, could
  carry.
- **Import VAT collected by the Bureau of Customs (Section 107).** Only
  value-added tax withheld on a service from a non-resident is carried; a
  company that imports goods needs a code this pack does not have, and item
  46 of BIR Form No. 2550Q (Importations) is not modelled.
- **The two-return timing of BIR Form No. 1600-VT and BIR Form No. 2550Q**
  (see `PH-P-RC` above and `docs/international.md`).
- **Input tax the law excludes from credit** (Section 110, entertainment
  expenses not directly connected to the trade and non-depreciable vehicles
  above a ceiling, by secondary reputation and not a primary text read this
  session): `PH-P-STD` assumes every standard-rated purchase is fully
  creditable.
- **The capital-goods amortisation schedule** (BIR Form No. 2550Q, Part V,
  Schedule 1 — input tax on capital goods exceeding P1,000,000 spread over
  the asset's useful life) and **the schedules for creditable VAT withheld
  by a government buyer and advance VAT payments on sugar/flour milling**
  (Schedules 3 and 4).
- **The CREATE MORE Act's zero-rating regime for IPA-registered
  export-oriented enterprises** (Republic Act No. 12066): a broader,
  registration-conditioned zero-rating of local purchases that is separate
  from the ordinary direct-exporter zero-rating this pack carries.
- **Expanded withholding income tax and withholding tax on compensation.**
  The chart carries payable accounts for both (`2140`, `2141`) because a
  Philippine company's books hold them, but no tax code posts to them: this
  pack's scope is value-added tax, and these are a different tax entirely.
- **Fixed assets.** No `assets.json`: this session found no capital
  allowance table it could read in the time available.
- **Bank formats.** Nothing checked says which formats Philippine banks
  send.

## Reviewing this pack

Open an issue titled "Review: Philippines". What a review is, and what it is
not, is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and
who may say what". The points a Philippine accountant should read first,
roughly in the order the author is least sure of them:

1. **Whether Section 114(A)'s later "beginning January 1, 2023" proviso
   truly supersedes its own earlier monthly-payment proviso**, against
   Revenue Memorandum Circular No. 5-2023's primary text, which this
   session read only through a secondary summary.
2. **The withholding mechanism `PH-P-RC` models** — its legal basis (the
   Revenue Regulations that first imposed it, not read here in primary
   text), and whether the immediate-credit simplification should instead be
   two documents.
3. **Whether Section 109(Q)'s P15,000 threshold is itself subject to the
   triennial Consumer Price Index adjustment** Section 109(CC) states for
   its own three-million-peso figure — this session read the two
   paragraphs as independent.
4. **Input tax the law excludes from credit** (Section 110), not modelled.
5. **The chart's own statements**, `PH-BS` and `PH-IS`, against a proper
   reading of the Philippine Financial Reporting Standard for Small
   Entities, once its text can be opened.
6. **`tax_point: invoice_if_issued`**, read from Section 113/237's own
   emphasis on the invoice as trigger rather than a single article stating
   the general rule in so many words.
