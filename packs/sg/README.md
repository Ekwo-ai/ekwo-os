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
`pack.json` holds twenty-four texts, and every one of them was opened on
21 September 2026: the statutes on Singapore Statutes Online, IRAS's pages and
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

142 accounts, all postable. None was copied from a published chart; Odoo's
`l10n_sg` was used afterwards to check that no account a Singapore tax posts to
is missing, never as a model.

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
- **Fixed assets.** No `assets.json`: SFRS leave the useful life to the entity,
  and the capital allowances are an income tax table.
- **Bank formats.** Nothing checked says which formats Singapore banks send.
- **Filing.** The return is filed on myTax Portal; submitting it is a credential
  and a format, not a pack.

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
