# Uganda

Everything Uganda adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 18 %, zero rate and exempt, the monthly VAT return (form
DT-2031), the statement of financial position and the profit and loss account
of the IFRS for SMEs Accounting Standard, and what sections 4(c) and 5(c) of
the Act do with a service bought from abroad. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Ugandan accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Ugandan VAT return has reviewed
it. The figures are replayed against a month of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**English only.** English is the sole official language the Value Added Tax
Act, the Tax Procedures Code Act and form DT-2031 are published in; the
Companies Act, 2012, s. 150(1) itself requires books of account to be kept in
English. This pack declares `en` alone.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and
beside it the key of the text that article is in. The register in
`pack.json` holds eight texts, every one opened on 26 September 2026. The
ones the rest of this file leans on:

| What | Text | Where |
|---|---|---|
| The charge to tax, the rate, zero-rating, exemptions, time of supply, input tax, invoices, returns | Value Added Tax Act, Chapter 349, ss. 4, 5, 14, 17, 19, 23, 24, 28, 29, 31, 34, 78 | `ulii.org` |
| Which goods and services are exempt or zero-rated | Value Added Tax Act, Second and Third Schedules | `ulii.org` |
| Electronic receipting and invoicing (EFRIS) | Tax Procedures Code Act, Chapter 343, s. 92 | `ulii.org` |
| Books of account, true and fair view | Companies Act, 2012, ss. 150, 152 | `ulii.org` |
| The statement of financial position and the profit and loss account | ICPAU, information paper on the adoption of IFRS, IFRS for SMEs and IPSAS in Uganda | `icpau.co.ug` |
| The current rate, registration, filing and EFRIS in plain language | URA, *A Simplified Guide — Value Added Tax* | `thetaxman.ura.go.ug` |
| What each row of the return holds | Form DT-2031, Monthly Value Added Tax Return, revision 07/2018 | `ura.go.ug` |

ULII's site (`ulii.org`) refuses a plain HTTPS request with no browser behind
it and returns 403; every Act cited here was instead read from the PDF
Laws.Africa serves for ULII, reached through `media.ulii.org`, which is not
browser-gated. `ekwo pack check ug --links` will report the three `ulii.org`
URLs as unreachable for the same reason: it is the publisher, not a wrong
pack. `etax.ura.go.ug`, the portal the return is filed on, did not answer a
connection from the machine this pack was written on either; that is recorded
rather than worked around.

**The consolidated Value Added Tax Act text this pack read is the version "as
at 31 December 2000".** ULII's own collection note lists outstanding
amendments through 2024 that a later, "as at 31 December 2023" consolidation
applies and this pack's copy does not; ULII's own site could not be reached to
compare the two. Every section this pack cites — the charge to tax (s. 4), who
pays it (s. 5), time of supply (s. 14), taxable supply and exempt supply
(ss. 18, 19), input tax (s. 28), tax invoices (s. 29), returns (s. 31), due
date for payment (s. 34), and the Minister's power to set the rate (s. 78) —
reads the same in every secondary source consulted (URA's own guidance, PwC,
RSM, Baker McKenzie) and none of those sources describes any of them as
renumbered or repealed, which is why this pack treats the 2000 text as
structurally current for those provisions. The Second and Third Schedules are
a different matter — see "What this pack does not carry" below.

## The chart of accounts, and why this one

**Uganda prescribes no chart of accounts.** Companies Act, 2012, s. 150(1)
requires every company to keep proper books of accounts sufficient to give a
true and fair view of its affairs, and s. 152(1) requires the balance sheet
and profit and loss account themselves to give that true and fair view. The
Institute of Certified Public Accountants of Uganda, the standard-setting body
the Accountants Act, 2013 recognises, has applied the IFRS Accounting
Standards without modification since 1998 and has adopted the IFRS for SMEs
Accounting Standard for an entity with no public accountability. So the chart
is written, not transcribed, in the same shape as the Kenyan, Nigerian and
South African packs:

- **Four digits, by class**: `1` assets, `2` liabilities, `3` equity, `4`
  revenue and other income, `5` goods and materials, `6` other expenses, `7`
  finance costs, `8` income tax.
- **Flat**, every account a leaf, grouped by the ranges of `statements.json`.
- **The accounts a Ugandan company keeps by law or by market practice**: VAT
  input and output tax, import VAT owed to URA at the border, NSSF
  contributions payable, withholding tax payable, local service tax payable,
  VAT withheld by an appointed agent, amounts due to directors, and a
  cash-in-transit line for mobile money settlements — MTN Mobile Money and
  Airtel Money are how much of Ugandan retail is actually collected.

140 accounts, all postable. None was copied from a published chart.

**Four VAT accounts.** `2100` holds the output tax and `1150` the input tax:
the two the taxes post to. `2125` holds the import VAT charged at the border
until the customs declaration is settled. `2110` and `1155` are where a filed
return's balance lands — see below.

**Only three accounts are `reconcilable`**: `1100` (trade receivables), `2000`
(trade payables) and `2110`/`1155` (the VAT settlement accounts). Every other
control account — NSSF, withholding tax, local service tax, VAT withheld by an
agent, import VAT, amounts due to directors, the bank and cash accounts, the
suspense account — is not, so a bank statement can only ever letter a customer
or a supplier line and `auto_settle()` never mixes two accounts on one
reconciliation.

## Taxes

**One statutory rate, set by order and not by the Act.** Section 78(2) lets
the Minister fix the rate by statutory order, subject to Parliament confirming
it within three months; the Value Added Tax (Rate of Tax) Order, 2005
(Statutory Instrument 2005 No. 51), made 8 June 2005 and in force from 1 July
2005, fixed it at eighteen per cent — where it has stood since. This pack
could not open an official gazette copy of the Order itself (see "Sources"
above on ULII's 403); the rate and its date are corroborated by URA's own
guidance and by three independent secondary summaries (PwC, RSM, ICNL), none
of which disagrees.

**What a supply can be, and where it goes on form DT-2031:**

| | Code | Box | Legal basis |
|---|---|---|---|
| Standard rate, sale | `UG-S-18` | 4 | s. 4(a), s. 24(1) |
| Zero-rated, export | `UG-S-Z-EXP` | 2 | Third Schedule, ¶ 1(a) |
| Zero-rated, domestic (drugs and medicines) | `UG-S-Z-DOM` | 1 | Third Schedule, ¶ 1(c) |
| Exempt (residential lease) | `UG-S-EX` | 3 | Second Schedule, ¶ 1(f) |

**Purchases:**

| | Code | Boxes | Legal basis |
|---|---|---|---|
| Standard rate, claimed | `UG-P-18` | 13, 20 | s. 28(1) |
| Zero-rated | `UG-P-Z` | 11 | s. 24(4) |
| Exempt (insurance) | `UG-P-EX` | none | Second Schedule, ¶ 1(d) |
| Import of goods | `UG-P-IMP` | 15, 20 | ss. 4(b), 5(b), 17, 23 |
| Imported service, reverse charge | `UG-P-RC-SVC` | 9(i), 21(i) | ss. 4(c), 5(c) |

**Sections 4(c) and 5(c) are not a European reverse charge, and form
DT-2031 reports them on their own two rows, gross.** A person who receives an
imported service is charged the tax directly under section 4(c) and pays it
under section 5(c); the return does not fold this into the ordinary
standard-rated rows, and it does not reduce the self-charge to nothing the way
Kenya's section 10(2)(b) does for a fully-creditable buyer. Instead Section C,
row 9(i) carries the self-charged output tax and Section D, row 21(i) carries
the matching claim, so both the Total Tax Charged (row 10) and the Total Input
Tax (row 22) move by the same amount on a wholly taxable purchase — netting to
nothing on the final Section H calculation, but visible, gross, on both sides
of the return. `UG-P-RC-SVC` is modelled with two independent `tax` postings
for exactly that reason, rather than the single posting with a `-100` factor
Kenya's pack uses for its own different mechanism.

## The return

**Form DT-2031, one form, filed monthly.** Section 1(1) defines "tax period"
as the calendar month; nothing else has been prescribed, so `tax_report.json`
carries `month` alone. Section 31(1) sets the return due, and section
34(1)(a) makes the tax payable on the same day, fifteen days after the end of
the period — the form's own header repeats the same rule in as many words.

**This pack carries rows 1 to 4, 8, 9(i), 10, 11, 13, 15, 20, 21(i) and 22, and
the final net calculation of Section H; the rest of the form is not carried,
and every gap is real:**

- **Rows 5 to 7 and 14, 16, 19** report VAT *deemed* on an own-use application,
  a gift, or a sale or purchase of a capital asset — a fact the ledger of an
  ordinary trading company does not carry, and one the form's own formulas for
  rows 8, 10, 20 and 22 already cancel out when nothing was deemed.
- **Row 9(ii) to 9(v) and 21(ii) to 21(iv)** are adjustments for VAT deferred at
  importation, tax charged or claimed on bad debts, and a change of accounting
  basis — period-to-period corrections, not a figure this pack's golden
  scenario has occasion to post.
- **Rows 17 and 18** (administrative expenses and capital goods bought) are
  rows the form itemises separately from row 13 for a company's own analysis;
  this pack does not carry a tax code that posts to them on their own, so an
  administrative or capital purchase at the standard rate is carried under
  `UG-P-18` and row 13 like any other, which is short of what the printed form
  itemises but not short of what it totals.
- **Section E** (rows 23 to 28) exists only for a taxpayer holding investment
  trader status under the Income Tax Act — a status this pack's golden company
  does not hold.
- **Section F** (rows 29 to 33), the apportionment of input tax credit between
  taxable and exempt use, is not carried for the reason `docs/packs.md` gives
  Singapore's Tourist Refund Scheme: this pack's `tax_report.json` vocabulary
  is a list to add, a list to subtract, or a rate of one box, and section F's
  own formula divides one sum of boxes by another sum of boxes — a ratio of a
  ratio no `total` box here can state. Row 20 and row 22 are therefore the
  figures a wholly taxable business, like this pack's golden company, in fact
  files.
- **Section G** (VAT withheld payable and creditable) is the record of a
  third-party withholding agent's deductions — see "Withholding VAT" below.

## Withholding VAT

**Not modelled by a tax code.** The Value Added Tax Act empowers the
Commissioner General to appoint withholding VAT agents, who deduct a share of
the taxable value of a supply and remit it directly to URA rather than to the
seller, crediting the seller's account; form DT-2031, Section G-I and G-II
record what a company paid as such an agent and what was withheld from it as
a supplier. Modelling an agent who is neither the seller nor the buyer of the
document being posted is beyond what a `taxes.json` posting, which always
speaks of the two parties to one document, can state. It is recorded in
[`docs/international.md`](../../docs/international.md) under "Uganda".

## Electronic invoicing: EFRIS is a clearance, not an exchange

`einvoicing.obligation` is `none` and `profile` is null, and that reads oddly
next to a country where an electronic invoice has in substance been
compulsory for VAT-registered businesses since January 2021. The reason is in
the words: Ekwo's vocabulary asks whether a statute obliges two *businesses*
to exchange a *structured invoice* — a Peppol BIS, a Factur-X, a PINT —
between themselves. Uganda's Tax Procedures Code Act, s. 92 does something
else. It lets URA designate, by notice in the Gazette, the taxpayers for whom
it becomes mandatory to issue an e-invoice or e-receipt, or to employ an
electronic fiscal device linked to URA's own centralised invoicing and
receipting system (EFRIS). The buyer receives whatever document the seller
always sent it; what changed is that the seller's own invoice is now cleared
with URA first, or generated on a device already linked to it. There is no
profile to name and no ISO 6523 scheme a party is addressed by, because
nothing is exchanged between the two businesses that a Peppol-shaped
vocabulary would recognise. This is recorded at length in `pack.json`'s own
`einvoicing.legal_reference` and in
[`docs/international.md`](../../docs/international.md) under "Uganda"; the
socle was not changed to fit it.

## What this pack does not carry

- **EFRIS as a clearance mechanism.** See above.
- **Withholding VAT.** See above.
- **The apportionment of input tax** of a partly exempt business (form
  DT-2031, Section F) and any de minimis rule around it.
- **Investment trader status** (form DT-2031, Section E) under the Income Tax
  Act.
- **Deemed supplies** — own-use application, gifts, and the deemed VAT on a
  sale or purchase of a capital asset (form DT-2031, rows 5 to 7, 14, 16, 19).
- **An offset brought forward from a previous month, and the five-million-
  shilling refund threshold** of form DT-2031, Section H: `NET` is the figure
  before either is applied, and Value Added Tax Act, s. 42 governs a refund.
- **The Second and Third Schedules beyond the paragraphs this pack cites.**
  Both schedules have been amended by Finance Acts and VAT Amendment Acts more
  than once since the 2000 text this pack read was printed — secondary
  guidance, for instance, describes the zero-rating of drugs and medicines as
  now qualified "manufactured in Uganda", a qualification the base text this
  pack could verify does not carry. `UG-S-Z-DOM` and `UG-P-Z` are written
  against the paragraph as this pack could read it, and a reviewer should
  check the current wording of Third Schedule, paragraph 1(c) before relying
  on either code for a general zero-rated purchase.
- **The registration threshold.** Not a fact `pack.json` states — Ekwo never
  decides who has to register — but worth recording here because it moved
  during the writing of this pack: the Value Added Tax (Amendment) Act, 2026
  raised it from Shs 150 million to Shs 250 million of annual taxable turnover,
  effective 1 July 2026.
- **Income tax withholding** other than VAT (Income Tax Act, s. 119 and
  following): out of scope of a VAT pack.
- **Fixed assets.** No `assets.json`: Uganda's capital allowances are an
  income tax table (Income Tax Act, Second Schedule), not a useful-life the
  IFRS for SMEs Accounting Standard leaves to the entity.
- **Bank formats.** Nothing checked says which formats Ugandan banks send.
- **Filing itself.** The return is filed on e-Tax; submitting it is a
  credential, not a pack.

## Reviewing this pack

Open an issue titled "Review: Uganda". What a review is, and what it is not,
is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who may
say what". The points a Ugandan chartered accountant should read first,
roughly in the order the author is least sure of them:

1. **The Second and Third Schedule paragraphs this pack cites**, against the
   text as amended to date — this pack could only verify the "as at 31
   December 2000" wording; see "What this pack does not carry" above.
2. **`tax_point: earliest_of_delivery_or_payment`** against s. 14(1), which is
   in fact a three-way earliest test — delivery, payment, or invoice issue —
   and not the two-way test the word names; see `pack.json`'s own reference.
3. **Sections 4(c)/5(c) modelled with two gross postings reaching rows 9(i)
   and 21(i)**, against how a Ugandan practitioner actually completes those
   two rows for a wholly taxable purchase.
4. **`UG-P-EX` posting no box at all**, against whether form DT-2031's
   underlying schedules in fact expect an exempt purchase to be listed
   somewhere this pack's reading of the printed form did not find.
5. **The chart's mapping onto the statements**, especially amounts due to
   directors and the VAT, NSSF, withholding tax and local service tax accounts
   among trade and other payables.
6. **`numbering: sequential`**, which rests on the serial-number requirement of
   the Fourth Schedule rather than a no-gap rule stated anywhere for a Ugandan
   tax invoice.
7. **`period_default: month`**, which is section 1(1)'s definition of "tax
   period" rather than a cadence any Ugandan business has been observed to
   choose otherwise.
