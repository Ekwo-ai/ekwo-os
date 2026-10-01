# Singapore

Everything Singapore adds to Ekwo, as data: a chart of accounts, the journals,
the goods and services tax with its three rates since 2007 and where each code
posts, the GST return F5, the statement of financial position and the income
statement of SFRS for Small Entities, withholding on interest and royalties
paid abroad, and the sentences the law puts on a tax invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Singapore accountant reading
the pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Singapore GST return has reviewed
it. The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**This is the first pack of Asia**, and it is written to be the model for the
next ones in the region: the same shape of chart as the Australian pack, a
return whose boxes are all bases and taxes the ledger already holds, a Peppol
profile of the PINT family, and a README that says out loud which text was read
and which could not be. Malaysia, whose SST returns and MyInvois e-invoicing
differ in kind, should copy the structure of this file and not its content.
What the core could not say is written up in
[`docs/international.md`](../../docs/international.md) under "Singapore". None
of it was patched for this pack's sake.

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds twenty-eight texts. Twenty-four were opened on
21 September 2026, the four of the corporate income tax section on 1 October
2026 (see below): the statutes on Singapore Statutes Online, IRAS's pages and
e-Tax Guide on iras.gov.sg, the Peppol specification on docs.peppol.eu. The ones
the rest of this file leans on:

| What | Text | Where |
|---|---|---|
| The rates, zero-rating, exempt supplies, the reverse charge, customer accounting, time of supply | Goods and Services Tax Act 1993, ss. 11, 14, 16, 21, 22, 38A and the Fourth Schedule | `sso.agc.gov.sg/Act/GSTA1993` |
| The tax invoice, the simplified invoice, disallowed input tax, returns and their due date, rounding, customer accounting thresholds, price display | GST (General) Regulations, regs. 11, 13, 26, 27, 52, 59, 66A to 66C, 77 | `sso.agc.gov.sg/SL/GSTA1993-RG1` |
| What each box of the return holds | IRAS, *Completing GST returns*, boxes 1 to 21 | `iras.gov.sg` |
| Accounting records, financial statements, audit exemption | Companies Act 1967, ss. 199, 201, 205C | `sso.agc.gov.sg/Act/CoA1967` |
| Withholding on payments to non-residents | Income Tax Act 1947, s. 45; IRAS, *Types of payment and withholding tax rates* | `sso.agc.gov.sg`, `iras.gov.sg` |
| Electronic invoicing | IRAS, *GST InvoiceNow Requirement* and its e-Tax Guide (second edition, 9 March 2026); PINT SG Billing v1.4.1; the Peppol EAS list | `iras.gov.sg`, `docs.peppol.eu` |

**One text could not be read, and it matters.** SFRS for Small Entities is
published by the Accounting Standards Committee under ACRA on
`asc.acra.gov.sg`, which serves the standards to Singapore IP addresses only —
ACRA's own page says so, because the standards are based on IFRS Accounting
Standards and the IFRS Foundation's copyright requires it. Every request from
here got a 403. The statements are therefore built on what ACRA's page does
say — that the SFRS Standards are based on the IFRS Accounting Standards — and
their paragraph numbers are those of the IFRS for SMEs Accounting Standard. The
register cites ACRA's page and not the standard, since a link nobody opened is
worse than none. Checking those paragraph numbers is the first thing on the
reviewer's list below.

SSO serves a statute as a table of contents and loads its sections by script,
which refuses a request with no browser behind it. Each provision cited here was
read through the provision view (`?ProvIds=pr16-` and so on), which is served
whole.

`ekwo pack check sg --links` found twenty of the twenty-four answering on the
day of writing. The four that did not are the four SSO texts, which answer a
browser and return 403 to the checker; each was opened in a browser-like client
the same day.

## The chart of accounts, and why this one

**Singapore prescribes no chart of accounts.** The Companies Act 1967, s. 199,
requires records that sufficiently explain a company's transactions and let true
and fair statements be prepared, kept for five years; s. 201 requires financial
statements that comply with the Accounting Standards; s. 205C exempts a small
company from audit but not from preparing them. So the chart is written, not
transcribed:

- **Four digits, by class**, the same classes as the Australian pack: `1`
  assets, `2` liabilities, `3` equity, `4` revenue and other income, `5` goods
  and materials, `6` other expenses, `7` finance costs, `8` income tax.
- **Flat**, every account a leaf, grouped by the ranges of `statements.json`.
- **Cost and accumulated depreciation adjacent** — leasehold property,
  renovation, plant, equipment, computers, furniture, motor vehicles and
  right-of-use assets — since freehold is the exception in Singapore.
- **The accounts a Singapore company keeps by law**: CPF contributions payable,
  the Skills Development Levy and the foreign worker levy, withholding tax
  payable to IRAS, import GST owed to Singapore Customs, amounts due to
  directors, share capital as one line since shares have no par value.

142 accounts, all postable. None was copied from a published chart.

**Five GST accounts, and why five.** `2100` holds the output tax and `1150` the
input tax: the two the taxes post to. `2125` holds the import GST shown on an
import permit until Singapore Customs is paid. `2110` and `1155` are where a
filed return's balance lands — see below.

## Taxes

**Three rates, one code each.** Section 16 of the Act charges 7 % from 1 July
2007 to 31 December 2022, 8 % in 2023 and 9 % from 1 January 2024, and IRAS
gives the same periods. Every rated code exists three times — `-7`, `-8`, `-9` —
with a `valid_to` on the first two, so a return for 2022 still gives the answer
it gave then. The earlier rates — 3 % from 1 April 1994, 4 % in 2003, 5 % from 2004 to
June 2007 — are not carried: nothing before 1 July 2007 is. The reverse charge starts on
1 January 2020 and customer accounting on 1 January 2019, so their codes start
then.

**What a supply can be, and where it goes on the F5:**

| | Codes | Box | Category |
|---|---|---|---|
| Standard-rated | `SG-S-SR-*`, `SG-S-SR-INC-*` (price with GST in it, as reg. 77 requires prices to be displayed) | 1, GST in 6 | S |
| Zero-rated export of goods, s. 21(1) | `SG-S-ZR-EXP` | 2 | G |
| Zero-rated international service, s. 21(3) | `SG-S-ZR-INTL` | 2 | G |
| Exempt: financial services, residential property (Fourth Schedule) | `SG-S-ES-FIN`, `SG-S-ES-RES` | 3 | E |
| Out of scope | `SG-S-OS` | none | O |
| Customer accounting, supplier side (s. 38A) | `SG-S-CA` | 1, nothing in 6 | AE |

**Purchases:**

| | Codes | Boxes |
|---|---|---|
| Standard-rated, claimed | `SG-P-TX-*` | 5, 7 |
| Input tax disallowed — motor cars, club fees, staff medical, family benefits (regs. 26, 27) | `SG-P-BL-*` | none; the GST lands on the line |
| Zero-rated from a registered supplier (international freight) | `SG-P-ZR` | 5 |
| Exempt, and from an unregistered supplier | `SG-P-ES`, `SG-P-NR` | none |
| Import with GST paid to Singapore Customs | `SG-P-IMP-*` | 5, 7; the GST waits on 2125 |
| Import with GST suspended (MES, A3PL) | `SG-P-IMP-SUSP` | 5, 9 |
| Reverse charge, claimable / not claimable | `SG-P-RC-*`, `SG-P-RC-NC-*` | 1, 14, 5, GST in 6, and in 7 only when claimable |
| Customer accounting, customer side | `SG-P-CA-*` | 1, 5, GST in 6 and 7 |
| Withholding on interest (15 %) and royalties (10 %) paid abroad | `SG-P-WHT-INT-15`, `SG-P-WHT-ROY-10` | none: the withholding form, not the F5 |

**The reverse charge reaches only a business that cannot claim all its input
tax.** Section 14(1) makes a GST-registered recipient account for GST on
services from abroad, and on low-value goods from 1 January 2023, only where it
is not entitled to credit for the full amount of its input tax — a bank, a
company letting residential property, an investment holding company. A fully
taxable business accounts for nothing. So the pack carries the two ends of it:
`SG-P-RC-*` for what the business uses to make taxable supplies, whose GST it
claims back in box 7, and `SG-P-RC-NC-*` for what serves its exempt supplies,
whose GST is a cost. What serves both needs the apportionment of regs. 28 to 30,
which no code holds. The golden year books a trading company that also lets a
flat, which is exactly the business the rule reaches.

**Customer accounting is a domestic reverse charge.** On mobile phones, memory
cards and off-the-shelf software above $10,000 sold to a GST-registered business
customer, the customer accounts for the GST (s. 38A, regs. 66A to 66C). The
supplier's invoice shows no GST and says why; the supplier reports the value in
box 1 and nothing in box 6; the customer reports the value in boxes 1 and 5 and
the GST in 6 and 7. That is category `AE`, treatment `domestic_reverse_charge`,
on both sides.

**Import GST is owed to Customs, not to the supplier.** `SG-P-IMP-*` sits on the
foreign supplier's invoice: the value goes to box 5 and the line, the input tax
to 1150 and box 7, and the same amount to `2125`, which is matched when the
import permit is paid. The supplier is owed the value alone. The GST is computed
on the value of the line; Customs computes it on the value plus duties, and IRAS
asks the two to be reconciled where they differ.

**Withholding is on the purchase.** Section 45 of the Income Tax Act 1947 makes
a payer of interest or royalties to a non-resident deduct tax and pay it to IRAS
by the 15th of the second month after payment. The two codes post the tax to
`2140` at the rates IRAS gives — 15 % and 10 %, before any treaty — so the
non-resident is owed the rest. The form they are declared on is not the F5, so
they reach no box. They are dated from 1 January 2026: the day each rate started
is not carried.

**Every base is a value without GST**, as boxes 1, 2, 3 and 5 ask.

## The return

`tax_report.json` is form GST F5 as IRAS describes it box by box on
*Completing GST returns*, boxes 1 to 17. Boxes 18 to 21 belong to the Import GST
Deferment Scheme and appear only on the return of an approved importer; they are
not carried.

| Boxes | How |
|---|---|
| 1, 2, 3, 5, 9, 14 | bases, summed from the ledger |
| 6, 7 | taxes, summed from the ledger |
| 4, 8 | the form's own arithmetic, stated in `golden/expectations.json` |
| 10, 11, 12, 13, 15, 16, 17 | declared and empty |

**Box 13 is revenue, not a tax base.** It is the period's revenue from the
profit and loss account, and IRAS accepts a best estimate. No tax posts to it;
see `docs/international.md`.

**Box 8 is a subtraction, and a refund comes out negative.** In the golden year
the March quarter, with a large import, comes to −1,305.00. The rule of
s. 41(7) that a net amount under $5 is zero is not applied.

**Three cadences, one default.** Reg. 52(2) makes a quarter the period for
everybody; reg. 52(3) lets the Comptroller allow months, three months that are
not a quarter, or six months. So `period` lists `month`, `quarter` and
`half_year`, and `period_default` is `quarter`. A Singapore quarter follows the
month the financial year ends in — February to April for a January year end —
and an Ekwo quarter always starts in January; see `docs/international.md`.

**The deadline is exact.** The return and the payment are due on the last day of
the month after the period (reg. 52(5), reg. 59(1)), whatever the cadence.

**Where the balance of a return lands.** `tax_payable` is `2110`, the GST payable
to IRAS, and `tax_receivable` is `1155`, the refund due. Both are reconcilable
and no tax posts to either; they are kept apart so that a payment to IRAS and
a refund from IRAS are each matched against their own account.

## The accounts

`statements.json` carries the statement of financial position and the income
statement of SFRS for Small Entities, with the paragraph numbers of the IFRS for
SMEs Accounting Standard, for the reason given under "Sources". The lines are the
minimum items of Section 4 and Section 5, split current and non-current, with
expenses by nature, which a small company's ledger holds without an allocation.
A company on SFRS(I) or FRS keeps the same books and presents more.

**GST is a receivable and a payable, not current tax.** Current tax is income
tax; the GST accounts, CPF and the levies are presented among trade and other
receivables and payables.

**No fact keys.** ACRA takes financial statements in XBRL through BizFinx, and
nothing here was checked against that taxonomy, so `xbrl` and `taxonomy` are
null.

## Closing the year

`fiscal_year_default` is `calendar`, and it is a proposal and nothing more: a
Singapore company chooses its financial year end, and the golden year uses the
calendar year because the Act dates its rates by calendar year. `closing_style`
is `retained_earnings`: a Singapore balance sheet has no current-year result
line. `3210 Dividends paid` sits beside retained earnings and is booked by hand.
No income tax provision is booked by the close; `8000` to `8020` and `2300` are
there for it.

## On the invoice

**The tax invoice is a list of particulars** (reg. 11(1)): the words "tax
invoice", an identifying number, the date, the supplier's name, address and GST
registration number, the customer's name and address, a description, the
amount excluding tax per item, the total excluding tax, the rate and the tax
as a separate amount, the total including tax, and the SGD equivalents of an
invoice in another currency. A simplified invoice (reg. 13) is allowed up to
$1,000 including GST, and cannot carry zero-rated or exempt lines.

**Numbering is `sequential`.** The particulars ask for an identifying number,
not a gapless series.

**Three mentions.** A zero-rated line and an exempt line each carry a sentence,
because reg. 11(3) makes an invoice distinguish them; a customer accounting
invoice carries the statement reg. 11(4)(b) requires. The words "tax invoice"
are the document's title and not a mention, as in the Australian pack.

**No payment term and no late payment interest** are declared: the pack found
no Singapore statute setting either between businesses, and did not look long
enough to say there is none.

**The tax point is the earlier of the invoice and the first payment**
(s. 11(2)), delivery playing no part, which `invoice_date` states whenever the
invoice comes first.

## Electronic invoicing

The profile is `pint-sg`, PINT SG Billing, the Peppol specification of
InvoiceNow, the network IMDA runs as the Singapore Peppol Authority. A party is
addressed by its UEN under ICD `0195`. The GST registration number has no ISO
6523 scheme of its own, so `vat_scheme` is empty.

`obligation` is `none`, and that needs saying carefully. No statute obliges a
business to send an electronic invoice to another. What exists is the **GST
InvoiceNow Requirement**: a GST-registered business transmits the data of its
invoices to IRAS through InvoiceNow — for companies registering voluntarily
within six months of incorporation from 1 November 2025, for every new voluntary
registrant from 1 April 2026, as a condition of registration, and for everybody
else in phases from 1 April 2028 to 1 April 2031, by amendments the e-Tax Guide
says are still to be enacted. It is a report to the tax administration and not
an exchange between businesses, and the vocabulary of `obligation` has no word
for it. Every date is in the pack's legal reference and the gap in
`docs/international.md`.

**PINT SG has its own GST categories** — SR, ZR, ES33, ESN33, OS, NG, SRCA-S,
SRCA-C, SRRC and others — and `vat_category` holds UNCL5305 letters of at most
two characters. Each tax carries the UNCL5305 letter its treatment requires and
names its PINT SG code in its legal reference, for a renderer to map.

## What this pack does not carry

- **The rates before 1 July 2007**, and the transitional rules for supplies
  spanning a rate change (ss. 39 to 39F).
- **The apportionment of input tax** of a partly exempt business (regs. 28 to
  36), and the de minimis rule.
- **The cash accounting scheme** (regs. 67 to 76), open to businesses the
  Comptroller approves; a regime of the business, as in Australia.
- **The Gross Margin Scheme, the Discounted Sale Price Scheme, the Tourist
  Refund Scheme, bad debt relief**, and the Import GST Deferment Scheme with its
  boxes 18 to 21.
- **The overseas vendor registration regime** and the electronic marketplace
  boxes 15 and 16: this pack is for a business established in Singapore.
- **Deemed supplies** — gifts over $200, business assets put to private use.
- **Box 13 and the exchange gains of box 3**, which are not documents.
- **Fixed assets.** No `fixed_assets.json`: SFRS leave the useful life to the entity,
  and the capital allowances are an income tax table.
- **Bank formats.** Nothing checked says which formats Singapore banks send.
- **Filing.** The return is filed on myTax Portal; submitting it is a credential
  and a format, not a pack.

## Fixed assets

`fixed_assets.json` is the part of this pack that is most plainly **practice
rather than law**. Singapore has no legal or fiscal table of accounting useful
lives, and the text of SFRS for Small Entities could not be opened (see
"Sources"), so no paragraph of it is quoted: every category says in as many
words that its duration is common practice. What was read is IRAS's side: the
Explanatory Notes to Form C for YA 2026 list the capital allowances of the
Income Tax Act 1947 — s. 19 over the prescribed tax useful life, s. 19A(1) over
three years, s. 19A(2) to (4) in one year for computers and prescribed
automation equipment, s. 19A(10A) in one year for items of no more than $5,000
each — and IRAS's audit write-up says the depreciation of the financial
statements is added back in the tax computation. Capital allowances are a tax
computation and never the accounting charge, so none of them is a category.

- **Prorata:** months, from the month the asset is brought into use, for the
  straight line and the declining balance alike; real days in the year; no cap;
  the switch to the straight line stays on. This is practice, not a quoted rule.
- **Disposal:** `net_result`. The statements print gains on disposal as one
  income line and losses as one expense line (paragraphs 5.9 and 5.11(a), cited
  as `statements.json` cites them), on accounts 4750 and 6960.
- **Categories:** nine, all straight line. Goodwill ten years, software and
  licences, renovation, office equipment, furniture and motor vehicles five,
  computers three, plant and machinery ten, leasehold property thirty (a
  placeholder for the lease term).

### Fixed assets: what `fixed_assets.json` leaves out

| Not carried | Why |
|---|---|
| Capital allowances (ss. 19, 19A, the one-, two- and three-year write-offs, balancing allowances and charges) | A tax computation distinct from the book charge; the module keeps one schedule per asset. The prescribed tax useful lives were not read. |
| Accelerated or enhanced allowances, the $5,000 low-value expensing | Outside the vocabulary of a category. |
| Threshold below which an asset is expensed in the accounts | No field, and no official text read. |
| Components of an asset | One asset, one duration. |
| Revaluation, impairment, residual value | Not a pack rule. |
| Right-of-use assets and investment property | Their life is the lease term or fair value, not a category. |
| Units of production | Refused by the module. |

## Corporate income tax: what `corporate_tax.json` leaves out

The section carries what was read on an IRAS document on 1 October 2026 — the
explanatory notes of Form C for year of assessment (YA) 2026, IRAS' examples of
the tax exemptions, the e-Tax Guide on unabsorbed items and IRAS' write-up on
audits of family-owned companies — and nothing else. **The Income Tax Act
itself could not be opened for this section**: Singapore Statutes Online
answered 403 to every request. The articles cited are therefore the ones IRAS
prints in those documents (ss. 15(1)(c), 15(1)(k), 19/19A, 37), and the
sections of the Act that charge the 17 % rate and grant the two exemptions are
cited by name and not by number.

**How the year is dated.** Singapore assesses the income of the financial year
that ends in the year before the YA, so the financial year 2025 of a company
whose year is the calendar year is the basis period of YA 2026. Every entry
reads its validity on the last day of the year (`valid_on: period_end`), and a
`valid_from` of 1 January 2019 means *financial years closing from that day*,
which is YA 2020, the year the current exemptions begin. The 17 % rate is dated
from 1 January 2018 (YA 2019, the earliest year in which it was read); the
adjustments and the loss rule from 1 January 2025 (YA 2026, the edition of the
notes that was read). A financial year before those dates is estimated with
what the dates leave: no rule at all for losses — a company carrying one is
refused by name — and no adjustment. Nothing is closed: no year after YA 2026
was read, and the entries stay open-ended.

**The exemptions are written as the tax on each slice.** The partial tax
exemption exempts 75 % of the first 10 000 and 50 % of the next 190 000 of the
normal chargeable income; the exemption for new start-up companies, 75 % of the
first 100 000 and 50 % of the next 100 000, for each of the first three
consecutive years of assessment. Taxed at 17 %, what is left of a slice is
taxed at 17 % × 25 % = 4,25 % or 17 % × 50 % = 8,5 %. That is the same
multiplication IRAS prints (its example: 10 000 at 75 % and 190 000 at 50 % is
an exempt amount of 102 500, and 600 000 taxed on 497 500), written slice by
slice. One difference remains and is stated here: IRAS rounds the exempt
amount to the dollar in its own examples (51 765 at 50 % is 25 883), where the
estimate keeps the cent, so a base that is not a whole number of dollars can
differ from the assessment by a few cents. The two schemes are exclusive and
the company says which one it meets, in the parameter `new_start_up_company`;
**a company that has not declared it is taxed at 17 % on everything**, and the
estimate says `not_declared`.

| Not carried | Why |
|---|---|
| The 50 % CIT Rebate of YA 2026 (capped at S$40,000), and the CIT Rebate Cash Grant of S$2,000 | Read in the explanatory notes of Form C. The rebate is a percentage of the tax, capped, and reduced by the grant; a `credit` is an amount the company states and cannot be a share of the computed tax, so the estimate is too high by up to S$40,000 for YA 2026. The company can apply the rebate to the estimate by hand. |
| The shareholding test for losses | The test (50 % or more of the shares held by the same persons at two dates) is read, and it depends on the shareholders on dates the books do not hold. The company records in `tax.losses` only the losses that pass it; the waiver of s. 37(16) is for the Comptroller. |
| Unabsorbed capital allowances, and donations | Their own stocks, with their own rules (donations lapse after five years). Only trade losses are in the stock of the module. The capital allowances of the year are a deduction the company states; the pool of assets that gives them is not computed. |
| The 250 % deduction for approved donations | The multiplier is printed in an example of the notes (S$1,920 × 2.5 = S$4,800); the period it applies to, and the ceiling at the chargeable income, were not read. |
| Depreciation of right-of-use assets (6210) and amortisation of intangible assets (6220) | The source names depreciation expenses; leases and intangible assets were not read. Only account 6200 is added back. |
| Business cars (Q-plated, RU-plated) | Only the private cars of s. 15(1)(k) were read on an IRAS document. The cap for business cars registered before 1 April 1998 was not. |
| Other expenses the Act refuses: fines, private and domestic expenses, entertainment, club subscriptions | No fixed percentage was read; IRAS' write-up says private expenses are not deductible and gives no share. The company has no rule to name for them and should have its adviser state the adjustment. |
| Exempt and non-trade income: one-tier dividends, foreign-sourced income, gains exempt under s. 13W, income at a concessionary rate | Each has its own conditions and several are taxed at another rate. The estimate treats the whole profit before income tax as chargeable income at the normal rate. |
| Estimated chargeable income, and the instalments that follow | The ECI instalment plan was not read, and `prepayments` has no shape for it: it is empty. |
| Loss carry-back relief | The guide read describes a claim of a loss of the current year against the income of the preceding years; the module only carries a loss forward. |
| Tax on a short or long basis period, and the first years of a new company | The notes attribute the profit of a first long period to two YAs; the estimate reads the financial year it is asked for. |

Nothing names account 6380, which holds the expenses of private cars beside
those of vehicles that may be deducted: a company states the amount, or an
account of its own that holds nothing else.

## Reviewing this pack

Open an issue titled "Review: Singapore". What a review is, and what it is not,
is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who may
say what". The points a Singapore chartered accountant should read first,
roughly in the order the author is least sure of them:

1. **The statements against the SFRS for Small Entities text**, which could not
   be opened from outside Singapore: every paragraph number is the IFRS for
   SMEs numbering.
2. **Box 5 on a reverse charge that is not claimable.** IRAS lists imported
   services subject to reverse charge among taxable purchases and disallowed
   expenses outside box 5; `SG-P-RC-NC-*` reports the value in box 5.
3. **Box 1 and box 5 on the customer side of customer accounting**, which follow
   IRAS's page; and the supplier's box 1 with nothing in box 6.
4. **Import GST on the supplier's invoice**, computed on the line and not on the
   permit value, and waiting on 2125.
5. **The two withholding codes**, their rates before any treaty, and their
   dating from 2026.
6. **`half_year` in the cadences**, for the six-month periods of reg. 52(3)(a)(iii).
7. **The PINT SG code named on each tax**, and `vat_scheme` left empty.
8. **`numbering: sequential`**, which rests on reg. 11(1)(b).
9. **The chart's mapping** onto the statements, especially amounts due to
   directors among current borrowings and the GST, CPF and levy accounts among
   trade and other payables.
10. **The fixed asset durations and the monthly prorata**, every one of which is
    practice and says so; and the prescribed tax useful lives of s. 19, not read.
