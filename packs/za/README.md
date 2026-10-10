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

What the core cannot yet say is listed in
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds thirteen texts. **South Africa keeps no official online
consolidated register of its own statutes**: the Government Gazette is the
sole medium of authentic publication (Interpretation Act 33 of 1957). The Act
is therefore cited from Acts Online, a private consolidation; SARS's guides,
the VAT201 form and its external guide are cited from sars.gov.za.

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
the chart is written, not transcribed: four digits, flat, no parent accounts, cost and accumulated
depreciation adjacent, grouped by the ranges of `statements.json` so that each
range reaches one line item of IFRS for SMEs paragraph 4.2 or 5.5. 155
accounts, all postable.

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
value.** VAT201 Field 1 prints one VAT-inclusive figure with no choice. The
engine holds the VAT-exclusive
value of a line, so every sale-side `base` posting grosses it to the
VAT-inclusive figure the field asks for (`box_factor: 115`), and the tax
posting carries the real VAT amount rather than a reconstruction of Field 1 ×
15/115. On the purchase side, VAT201 asks for the deductible VAT amount
directly — "the permissible VAT amount of \[…\] supplied to you" — and for
nothing else, so every purchase-side `base` posting in this pack carries no
box at all: there is nothing on this return to report a purchase's value in.

**Zero-rated is not exempt, and the difference is the credit.** A zero-rated
supply is a taxable supply at a nil
charge — the credits on what went into it stay deductible (s. 11) — while an
exempt supply under s. 12 carries no output tax and lets no input tax on what
went into it be deducted (s. 17(1)):

| | VAT on the sale | Credits on what went into it | Code | Category |
|---|---|---|---|---|
| Zero-rated, domestic (s. 11(1)) | none | claimable | `ZA-S-ZERO` | Z |
| Zero-rated, exported goods (s. 11(1)(a)) | none | claimable | `ZA-S-EXPORT` | G |
| Exempt (s. 12) | none | not claimable | `ZA-S-EXEMPT` | E |

**Exported goods have their own box, Field 2A, apart from Field 2.** Field 2
is "zero rate,
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
beside the invoice-basis codes; nothing stops a company from mixing them, and a vendor that has made the
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
pack carries.

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
the four is expressible — see
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).
`period_default` is left out on purpose: s. 27(4) has the Commissioner assign
a vendor to Category A or B so as to keep the two roughly equal in number,
which is not one answer the law gives everybody.

**The deadline is the statutory one, not the eFiling one almost everyone
files on.** Section 28(1) sets the 25th of the month after the tax period;
SARS's own guide gives a vendor who files and pays through eFiling until the
*last business day* of that month instead, which this pack's single
`day_of_month_after_period` rule cannot also express.

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

**No fact keys.** The pack carries no taxonomy, so `xbrl` and `taxonomy` are
null on both statements.

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
(s. 9(1)). `invoice_date` is
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
  "The return" above.
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
- **Fixed assets**: only what `fixed_assets.json` carries — see "Fixed assets: what `fixed_assets.json` leaves out" below.
- **Bank formats.** No statement format is declared.

## Corporate income tax: what `corporate_tax.json` leaves out

The section rests on SARS's published rates of tax for companies and small
business corporations, their archive, and the Tax Guide for Small Businesses
2025/2026, and on nothing else.
It starts from line 8, profit before income tax, of `ZA-IFRSSME-PL`, so the
tax charge on 8000 to 8020 never enters the computation. The company rate of
27 % is dated from the years of assessment ending on or after 31 March 2023,
the small business corporation tables from those ending on or after
1 April 2025: a year before that is estimated at 27 % with no reduced band.

| Not carried | Why |
|---|---|
| The set-off of an assessed loss (section 20) | The law lets a company set off the **higher** of R1 million and 80 % of its taxable income before the set-off. The module's limit is a floor plus a share of the profit *above* it (`floor` and `percent_above`), which is another formula, so `loss_carryforward` is empty rather than approximated. A company that carries a loss is refused by name; losses of the year are still recorded. |
| Provisional tax (Fourth Schedule) | Two payments — the first within six months of the start of the year, the second no later than the last day of the year — each a share of the company's **own estimate** of the year. `prepayments` knows only a share of a reference year's tax, or a surcharge on a shortfall; neither says that. The third top-up payment after the year end is not carried either. |
| The small business corporation bands before the year ending 1 April 2025 | The table of the year ending 1 April 2023 to 31 March 2024 is the same; the table of the year in between is not carried and should be checked. |
| The R18 848 and R57 698 of the SARS table | SARS prints whole rands; the section computes the 7 % band to the cent, 18 847,50, and so differs from the printed table by up to 50 cents. |
| The exception for personal services in a small business corporation | A company with three or more full-time employees may exceed the 20 % of personal service income. The company states the percentage it reaches after the exception; the pack does not test it. |
| Short years of assessment | The pack cites no text on how the bands or the R20 million ceiling are reduced for a year of less than twelve months, so `up_to_prorata` is `none`. |
| Other disallowed expenses (entertainment, donations, motor vehicles, leave pay, section 23(m)) and the allowances of section 12E(1A), 12B, 12C and 12I | Not carried from an official page, or each needs a ceiling or a count the vocabulary of a rule does not carry. |
| Dividends tax, capital gains, turnover tax, the ring-fencing of section 20A, mining and other special regimes | Outside the module. |
| Tax credits, foreign tax rebates | `credits` is empty: the shape is published and no credit was cited. |

Interest on late payment of tax (`7030`) is added back from its account
(section 23(d), (e) and (g), as SARS's guide groups them) — a local tax
practitioner should confirm that the account never holds anything the Act
allows. Fines are added back by the company's own statement, because section
23(o) refuses only those imposed for an unlawful activity and no account holds
nothing else.

## Fixed assets

`fixed_assets.json` carries how a South African company depreciates a fixed
asset in its books and takes it off the balance sheet. It rests on Sections
17, 18 and 19 of the IFRS for SMEs Standard (2015 text, as the
IFRS Foundation publishes it; the edition updated in February 2025 applies from
1 January 2027) and in SARS Interpretation Note 47 (Issue 5) with its Annexure.

- **Disposal is `net_result`**: IFRS for SMEs 17.28 and 17.30 take one gain or
  loss, the difference between the net proceeds and the carrying amount, to
  profit or loss. The two accounts are the roles `asset_disposal_gain` (4750)
  and `asset_disposal_loss` (6960).
- **The first-period prorata is practice, not text.** Paragraph 17.20 starts
  depreciation when the asset is available for use but does not say how to cut
  the first year; the section counts whole months, in straight line and in
  declining balance, and says so in its `legal_reference`. No cap, and the
  switch to the straight line is kept.
- **Durations are practice.** South Africa has no table of useful lives for the
  books: the entity estimates them (17.18, 17.21). Goodwill is ten years, the
  ceiling of paragraph 19.23 when the life cannot be established. Where the
  Annexure to Interpretation Note 47 lists the asset for the tax allowance
  (personal computers three years, furniture and fittings six, passenger cars
  five, delivery vehicles four), the category takes the same figure and says it
  is a habit, not a rule. Buildings (fifty years), plant and machinery (ten)
  and leasehold improvements (ten) rest on no official figure.
- **A category proposes, never imposes.** The wear-and-tear allowance of
  section 11(e) is a tax computation and is never the accounting charge.

### Fixed assets: what `fixed_assets.json` leaves out

| Not carried | Why |
|---|---|
| The wear-and-tear allowance of section 11(e), its Annexure periods and its diminishing-value method, as a schedule distinct from the book charge | The module keeps one schedule per asset. A company whose books and tax returns differ carries the difference as a tax adjustment outside the module. |
| Other tax allowances (section 12B, 12C, 12E, 13 and 13quin, and the like) | Tax computations outside the vocabulary of a category. |
| Declining-balance categories | IFRS for SMEs names the method but gives no usual rate; the diminishing-value method of Interpretation Note 47 is a tax method. |
| Components of an asset (17.16) | The module has one asset, one duration. |
| Residual value, impairment (Section 27) and revaluation | Not a pack rule. |
| Right-of-use assets (account 1670) | Section 20 of the standard, not carried. |
| Threshold below which an asset is expensed | No official text is cited, and the module has no such field. |
| Units of production | Refused by the module. |
| Day-by-day convention of the first period | Practice, not text; a company that prorates in days sets `prorata = 'days'` on the asset. |
| Depreciation of assets held for sale, and capital work in progress (account 1680) | The module cannot stop depreciation on a reclassification. |

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
7. **`posted_edit_policy`**, left silent and so read as `reversal_only`: the
   pack cites no article of South African company law on whether
   a posted document could instead go back to draft while untouched.
