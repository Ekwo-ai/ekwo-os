# South Africa

Everything South Africa adds to Ekwo, as data: a chart of accounts, the
journals, value-added tax and where each code posts, the VAT201 return, the
statement of financial position and the statement of comprehensive income of
the IFRS for SMEs Accounting Standard, and the sentences the law puts on a tax
invoice. The format is [`docs/packs.md`](../../docs/packs.md); this file says
where the content came from and which decisions it rests on, so that a South
African accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Status: `community`.** Nobody who files a South African VAT201 has reviewed
it. The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**This pack is written against Australia's and New Zealand's**: the same
shape of chart, a value-added tax the common system of the European Union does
not reach, and a return that reports a VAT-inclusive figure the engine grosses
up rather than a value it sums directly. What the core could not say is
written up in [`docs/international.md`](../../docs/international.md) under
"From South Africa". None of it was patched for this pack's sake.

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds thirteen texts, opened on 25 September 2026. The one gap
worth stating plainly: **South Africa keeps no official online consolidated
register of its own statutes**, unlike Legilux, Légifrance or Estonia's Riigi
Teataja — the Government Gazette is the sole medium of authentic publication
(Interpretation Act 33 of 1957) and no free government service republishes a
statute as amended, kept current. The Act itself is cited from Acts Online, a
long-established private consolidation cross-checked against SARS's own
guides wherever the two overlap; SARS's own guides, the VAT201 form and its
external guide, are read straight from sars.gov.za.

| What | Text | Where |
|---|---|---|
| The charge, the rate, zero-rating, exemptions, imported services, tax invoices, tax periods, returns | Value-Added Tax Act 89 of 1991 | `acts.co.za/value-added-tax-act-1991` |
| What each field of the return holds | VAT201, and SARS's *Guide for Completing the Value-Added Tax VAT201 Declaration* (GEN-ELEC-04-G01, Revision 11) | `sars.gov.za` |
| Zero-rated and exempt supplies, tax invoices, the payments basis | SARS, *VAT 404 – Guide for Vendors* | `sars.gov.za` |
| The 2025 rate increase and its reversal | Rates and Monetary Amounts and Amendment of Revenue Laws Bill, 2025, clause 13 | National Treasury media statement |
| Who prepares financial statements, and under which standard | Companies Act 71 of 2008, ss. 28 to 30; Companies Regulations, 2011, reg. 27 and 28 | `gov.za` |
| The form of the statements | IFRS for SMEs Accounting Standard, sections 4 and 5 | `ifrs.org` |
| No obligation to issue a structured electronic invoice | SARS Strategic Plan 2025/26–2029/30 and the VAT Modernisation programme | `sars.gov.za` |

## The chart of accounts, and why this one

**South Africa prescribes no chart of accounts.** The Companies Act 71 of
2008, s. 28, requires accurate and complete accounting records; s. 29 requires
annual financial statements that satisfy the financial reporting standard
applicable to the company. Companies Regulation 27(4) lets a company that is
not required to be audited (Regulation 28, by its public interest score)
prepare them under the IFRS for SMEs Accounting Standard, which the great
majority of South African private companies and close corporations are. So
the chart is written, not transcribed, on the same plan as `packs/au/` and
`packs/nz/`: four digits, flat, no parent accounts, cost and accumulated
depreciation adjacent, grouped by the ranges of `statements.json` so that each
range reaches one line item of IFRS for SMEs paragraph 4.2 or 5.5. 155
accounts, all postable, none copied from a published chart or a commercial
package's chart.

**Four VAT accounts.** `2100` holds VAT output (VAT charged on sales) and
`1150` VAT input (VAT paid on purchases and imports): the two the taxes post
to. `2105` and `1152` hold the VAT of documents accounted for on the payments
basis until they are paid. Neither `2100` nor `1150` is where the return's own
balance lands — see "Where the balance of the return lands" below.

## Taxes

**One positive rate, 15 %, since 1 April 2018.** Section 7(1) fixed it at 14 %
from the Act's commencement and moved it to 15 % from 1 April 2018; the 2025
Budget proposed 15,5 % from 1 May 2025, rising to 16 % from 1 April 2026, and
both were withdrawn by clause 13 of the Rates and Monetary Amounts and
Amendment of Revenue Laws Bill, 2025 before the first of the two dates
arrived, so the rate never in fact left 15 %. No code in this pack carries
15,5 % or 16 %: there was nothing to book at either rate on any date a South
African company could have posted an entry.

**Field 1 is VAT-inclusive, and there is no separate box for a purchase's
value.** Unlike Australia's BAS, which lets a filer choose to report GST
exclusive of GST, VAT201 Field 1 prints one VAT-inclusive figure with no
choice, the way New Zealand's GST101A does. The engine holds the VAT-exclusive
value of a line, so every sale-side `base` posting grosses it to the
VAT-inclusive figure the field asks for (`box_factor: 115`), and the tax
posting carries the real VAT amount rather than a reconstruction of Field 1 ×
15/115. On the purchase side, VAT201 asks for the deductible VAT amount
directly — "the permissible VAT amount of \[…\] supplied to you" — and for
nothing else, so every purchase-side `base` posting in this pack carries no
box at all: there is nothing on this return to report a purchase's value in.

**Zero-rated is not exempt, and the difference is the credit.** As in
Australia and New Zealand, a zero-rated supply is a taxable supply at a nil
charge — the credits on what went into it stay deductible (s. 11) — while an
exempt supply under s. 12 carries no output tax and lets no input tax on what
went into it be deducted (s. 17(1)):

| | VAT on the sale | Credits on what went into it | Code | Category |
|---|---|---|---|---|
| Zero-rated, domestic (s. 11(1)) | none | claimable | `ZA-S-ZERO` | Z |
| Zero-rated, exported goods (s. 11(1)(a)) | none | claimable | `ZA-S-EXPORT` | G |
| Exempt (s. 12) | none | not claimable | `ZA-S-EXEMPT` | E |

**Exported goods have their own box, Field 2A, apart from Field 2.** That is
not a subset the way Australia's G2 sits inside G1: Field 2 is "zero rate,
*excluding* goods exported" and Field 2A is "zero rate, *only* exported
goods", so the two boxes never carry the same rand.

**Three things a purchase can be besides a plain credit**, and none of them
has a box to report its value in, only the effect it has on an expense
account or on VAT output:

| Code | What it is | Where the VAT lands |
|---|---|---|
| `ZA-P-VAT-NC` | entertainment and a denied motor car, s. 17(2)(a) and (c) | the expense account (`tax_on_base`); no box |
| `ZA-P-VAT-ITS` | relates wholly to an exempt supply, s. 17(1) | the expense account (`tax_on_base`); no box |
| `ZA-P-RC-IMPORT` | an imported service not wholly for a taxable purpose, s. 7(1)(c) and s. 14 — self-assessed | the expense account (`tax_on_base`) **and** VAT output, Field 12 |

**The reverse charge on imported services is not a European one.** It is the
recipient itself that owes the VAT under s. 14(5), on whatever share of the
service was not wholly for a taxable purpose; there is no supplier relieved of
anything and no recapitulative statement, which is why the treatment carries
no `vat_category`. The golden year books a cloud subscription that partly
supports an exempt residential letting.

**The payments basis is a regime of the vendor, carried as codes.** Section
15(2) lets a natural person, a partnership of natural persons, a public
authority or a welfare organisation under the R2,5 million threshold account
for VAT when it is paid rather than when it is invoiced. The core has no
regime of a company, so the pack carries `ZA-S-VAT-CASH` and `ZA-P-VAT-CASH`
beside the invoice-basis codes, exactly as `packs/au/` and `packs/nz/` do;
nothing stops a company from mixing them, and a vendor that has made the
election should use nothing else. The golden year uses the sale-side one only,
to show where its VAT lands: on the transition account at the invoice's own
date, and in Field 4 only once the payment that settles it is reconciled — in
a *later* two-month period than the invoice, in the golden scenario, precisely
to exercise the timing this mechanism exists for.

## The return

`tax_report.json` is form VAT201, as SARS's external guide GEN-ELEC-04-G01
(Revision 11, effective 12 May 2025) describes it.

| Fields | How |
|---|---|
| 1, 1A, 2, 2A, 3 | bases, summed from the ledger and grossed to the VAT-inclusive figure the sale-side fields hold |
| 4, 4A, 12, 14, 14A, 15, 15A | taxes, summed from the ledger |
| 5, 6, 7, 8, 9 | declared and empty: this pack carries no code for the commercial-accommodation apportionment of s. 8(13) |
| 10, 11 | declared and empty: this pack carries no change-in-use or second-hand-goods notional-input-tax code |
| 16, 17, 18 | declared and empty: change in use, bad debts and the adjustments outside the ordinary invoice and credit-note flow |
| 13, 19, 20 | the form's own arithmetic |

**Field 4 is the ledger's own VAT, not a reconstruction.** VAT201's own
instruction is "Field 1 × (r / (100 + r))"; this pack posts the real amount
the engine already holds, which is the same figure at 15 %, the only rate this
pack carries — the way `packs/nz/` reads Box 8 of GST101A.

**Field 20 is a subtraction, and a refund comes out negative.** The form
prints a minus sign before a refund; the golden year's period 2026-B1, whose
VAT input from a capital purchase and a stock purchase outweighs its output
tax, comes to −3 600.00.

**Two cadences, out of six the law names, and no default.** Section 27
divides every vendor into Category A, B, C, D, E or F. This engine's cadences
are fixed to the calendar and anchored on 1 January; only Category B (ending
February, April, June, August, October, December) and Category C (every
calendar month) fall on that anchor. Category A is the same two-month grouping
offset by one month (ending January, March, May, July, September, November);
Category D and Category F are offset the same way, and Category F's periods
even cross a calendar year boundary (September to February); Category E
follows the vendor's own year of assessment, not the calendar year. None of
the four is expressible — see `docs/international.md`. `period_default` is
left out on purpose: s. 27(4) has the Commissioner assign a vendor to Category
A or B so as to keep the two roughly equal in number, which is not one answer
the law gives everybody, the same reason `packs/lu/` proposes no cadence of
its own.

**The deadline is the statutory one, not the eFiling one almost everyone
files on.** Section 28(1) sets the 25th of the month after the tax period;
SARS's own guide gives a vendor who files and pays through eFiling until the
*last business day* of that month instead, which this pack's single
`day_of_month_after_period` rule cannot also express — see
`docs/international.md`.

**Where the balance of the return lands.** `tax_payable` is `2110`, the VAT
payable to SARS, and `tax_receivable` is `1155`, the refund due. Both are
reconcilable, apart from `2100` and `1150`, where the taxes post.

## The accounts

`statements.json` carries the statement of financial position and the
statement of comprehensive income of the IFRS for SMEs Accounting Standard,
sections 4 and 5, approved for use in the Republic by the Financial Reporting
Standards Council under Companies Regulation 27.

**The lines are the paragraph 4.2 and 5.5 items**, in the order South African
practice prints them, split current and non-current under paragraphs 4.4 to
4.8, with "other current assets" and "net assets" as the additional lines
paragraph 4.3 allows. Biological assets (4.2(h)-(i)) and non-controlling
interests (4.2(q)) are not lines, because the chart holds no account for them.

**VAT and dividends tax are receivables and payables, not current tax.**
Paragraph 4.2(n) is about current tax, which in South Africa is income tax
under the Income Tax Act 58 of 1962; VAT output, VAT payable to SARS,
dividends tax withheld and employees' tax (PAYE) report among trade and other
receivables and payables instead.

**Dividends tax is never an income-statement expense.** The Income Tax Act,
s. 64E, imposes it on the *shareholder*; the company only withholds it from
the dividend it pays and remits it. `2090 Dividends tax withheld payable to
SARS` exists for a company to book the withholding by hand — this pack carries
no tax code for it — and no expense account for it exists, on purpose.

**Expenses by nature.** Paragraph 5.11 allows nature or function, and a small
company's ledger holds nature without any allocation.

**No fact keys.** Nothing here was verified against a taxonomy, so `xbrl` and
`taxonomy` are null on both statements.

## Closing the year

`closing_style` is `retained_earnings`: the result goes straight into `3200
Retained earnings`. IFRS for SMEs paragraph 4.12(f) names retained earnings as
a class of equity and asks for no separate current-year-result line. `3210
Dividends declared` sits beside it and is booked by hand.

No income tax provision is booked by the close. The chart carries `8000` to
`8020`, `2300`, `2310` and the deferred tax accounts so that it can be.

## On the invoice

**A tax invoice is a list of particulars, and a serial number is one of
them, but nothing requires it to be unbroken.** Section 20(4) requires a full
tax invoice above R5 000, s. 20(5) an abridged one below it — neither below
R50, where s. 20(1) requires none at all — and both a "serial number and the
date of issue" among their particulars (VAT 404, chapter 13). `numbering` is
therefore `sequential` rather than `gapless_per_year`: the Act asks for a
number, not for one with no gaps.

**No payment term and no late-payment interest specific to an invoice.** No
statute of general application fixes either between businesses; the
Prescribed Rate of Interest Act 55 of 1975 fixes a general fallback rate of
interest on any unpaid debt where the parties agreed none, which is not a term
the VAT Act or company law imposes on an invoice.

**The tax point is the earlier of the invoice and the first payment**
(s. 9(1)), the same rule as Australia's and New Zealand's. `invoice_date` is
the closest word the format has: right when the invoice comes first, wrong for
a deposit received before any invoice is issued.

**Two mentions.** An export and an exempt supply each carry a sentence naming
the article the zero rate or the exemption rests on, since South Africa is
outside the VATEX list of the European Union and carries no exemption reason
code of its own.

## Electronic invoicing

`obligation` is `none`: no provision of the VAT Act obliges a vendor to issue
or to accept a structured electronic invoice, and South Africa carries no
Peppol authority or network profile at the date of this pack. SARS's
Strategic Plan 2025/26–2029/30 and its VAT Modernisation programme describe a
multi-year, phased move towards real-time, transaction-level VAT reporting
with e-invoicing as a foundational pillar — piloted first with the largest
Category C vendors — but no bill amending the VAT Act to make any of it
mandatory had been introduced in Parliament at the date of this pack.

## What this pack does not carry

- **Categories A, D, E and F of the six VAT tax-period categories** — see
  "The return" above and `docs/international.md`.
- **The eFiling extension of the deadline** to the last business day of the
  month, which almost every vendor in fact files on.
- **Commercial accommodation** (Fields 5 to 9, s. 8(13)'s 60 % apportionment).
- **Change in use, the export of second-hand goods and notional input tax on
  second-hand goods bought from a non-vendor** (Fields 10 and 11, s. 18 and
  s. 20(8)).
- **Bad debts** (Field 17, s. 22) and the manual adjustments of Field 18
  outside the ordinary invoice and credit-note flow.
- **Importation of goods at the border as a document of its own.** `ZA-P-IMPORT-GOODS`
  and `-CAP` carry the mechanics, but no golden document exercises them:
  Ekwo has no customs declaration document, and a purchase invoice is not one.
- **Apportionment of input tax that relates partly to taxable and partly to
  exempt supplies** (s. 17(1)): `ZA-P-VAT-ITS` denies the whole of it, which is
  right only where the acquisition relates wholly to an exempt supply.
- **Dividends tax** (Income Tax Act, s. 64E) as a posted tax: `2090` exists to
  book the withholding by hand.
- **Employees' tax (PAYE), UIF, the Skills Development Levy and provisional
  tax** as anything but placeholder accounts: Ekwo has no payroll or income
  tax module.
- **Fixed assets.** No `assets.json`.
- **Bank formats.** No statement format is declared.

## Reviewing this pack

Open an issue titled "Review: South Africa". What a review is, and what it is
not, is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and
who may say what". Points a South African CA(SA) or tax practitioner should
read first, roughly in the order the author is least sure of them:

1. **Field 1's VAT-inclusive convention**, and whether every code in this pack
   grosses correctly to it — the point most worth a second reading, since a
   wrong `box_factor` would still balance the ledger.
2. **The imported-services reverse charge** (`ZA-P-RC-IMPORT`) as a single
   wholly-non-deductible code, when s. 7(1)(c) actually apportions by the
   extent the service is *not* for a taxable purpose.
3. **`ZA-P-VAT-ITS`** as a wholly-denied code for the same reason.
4. **The two tax-period categories carried**, B and C, and whether a vendor
   on Category A, D, E or F is told clearly enough that this pack does not fit
   their cadence.
5. **`numbering: sequential`** rather than `gapless_per_year`, resting on
   s. 20(4) naming a serial number and nothing about continuity.
6. **The chart's mapping onto IFRS for SMEs paragraph 4.2**, especially the
   suspense account inside trade receivables and payables and VAT among them
   rather than under current tax.
7. **`posted_edit_policy`**, left silent and so read as `reversal_only`: no
   article of South African company law was read for this pack to say whether
   a posted document could instead go back to draft while untouched.
