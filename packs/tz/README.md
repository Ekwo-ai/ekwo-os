# Tanzania

Everything Tanzania adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 18 %, zero rate and exempt, the monthly VAT return, the
statement of financial position and the profit and loss account of the IFRS
for SMEs Accounting Standard, and the reverse charge the Value Added Tax Act
puts on a service bought from abroad. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Tanzanian accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

**Status: `community`.** Nobody who files a Tanzanian VAT return has reviewed
it. The figures are replayed against a month of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**English only.** The Value Added Tax Act and the Companies Act are both
enacted in English, and no Swahili edition of either could be verified for
this pack; Companies Act, 2002, s. 151(1) does let a company keep its books
in English or Swahili, but neither statute publishes the accounting
vocabulary itself in Swahili the way this pack would need to transcribe
labels from. Rather than invent Swahili wording nobody has published, this
pack declares `en` alone. What the core could not say is written up in
[`docs/international.md`](../../docs/international.md) under "Tanzania".
None of it was patched for this pack's sake.

**Mainland Tanzania only.** Tanzania Zanzibar administers its own value added
tax law and its own revenue authority; this pack is the Value Added Tax Act
(Cap. 148), which by its own terms (s. 2(1), the definitions of "resident"
and "Zanzibar input tax") governs Mainland Tanzania. A Zanzibar pack, should
one be written, would be a different set of files under `packs/`.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and
beside it the key of the text that article is in. The register in
`pack.json` holds six texts, every one opened on 26 September 2026. The ones
the rest of this file leans on:

| What | Text | Where |
|---|---|---|
| The charge to tax, the rate, zero-rating, the reverse charge on imported services, time of supply, input tax, returns, tax invoices | Value Added Tax Act (Cap. 148), ss. 3, 4, 5, 6, 8, 15, 17, 55, 55A, 61A, 66, 67, 68, 86 | `mof.go.tz` |
| Which goods and services are exempt | Value Added Tax Act, First Schedule | `mof.go.tz` |
| Accounting records, financial statements | Companies Act, 2002 (Cap. 212), ss. 151, 153, 154 | `tanzlii.org` / `laws.africa` |
| The rate, the registration threshold, filing by the 20th | TRA, *Value Added Tax (VAT)* | `tra.go.tz` |
| Electronic fiscal devices | TRA, *Know about Electronic Fiscal Devices (EFD)* | `tra.go.tz` |
| Where a return is filed | IDRAS, the Integrated Domestic Revenue Administration System | `gateway.tra.go.tz` |
| NBAA's adoption of IFRS and the IFRS for SMEs Accounting Standard | IFAC, Tanzania country profile | `ifac.org` |

The Value Added Tax Act was read from the Ministry of Finance's own PDF, the
Government Printer's edition of Chapter 148, Revised Edition 2019 (the
mirror `tra.go.tz` also serves stopped resolving while this pack was
written). The Companies Act, 2002 was read from TanzLII's Laws.Africa
edition, current to 1 July 2016 with later amendments noted but not yet
applied to the text; none of the amendments listed touches ss. 151-154.

## The chart of accounts, and why this one

**Tanzania prescribes no chart of accounts.** Companies Act, 2002, s. 151(1)
requires every company to keep proper books of account sufficient to
disclose the company's financial position and to enable a balance sheet,
profit and loss account and cash flow statement that comply with the Act;
s. 154(1) requires each of those to give a true and fair view; s. 154(2)
requires them to comply with requirements the Minister or the National Board
of Accountants and Auditors prescribes, having regard to generally accepted
principles of accounting. NBAA, the standard-setting body the Auditors and
Accountants (Registration) Act recognises, has adopted the IFRS
Accounting Standards and, for a commercial entity with no public
accountability, the IFRS for SMEs Accounting Standard. So the chart is
written, not transcribed, in the same shape as the Kenyan, Singaporean and
Australian packs:

- **Four digits, by class**: `1` assets, `2` liabilities, `3` equity, `4`
  revenue and other income, `5` goods and materials, `6` other expenses, `7`
  finance costs, `8` income tax.
- **Flat**, every account a leaf, grouped by the ranges of `statements.json`.
- **The accounts a Tanzanian company keeps by law or by market practice**:
  NSSF contributions payable, Workers Compensation Fund contributions
  payable, the Skills Development Levy, withholding tax payable to TRA,
  import VAT owed to TRA at the border, amounts due to directors, and a
  cash-in-transit line for mobile money and card settlements — mobile money
  (M-Pesa, Tigo Pesa, Airtel Money) is how much of Tanzanian retail is
  actually collected.

142 accounts, all postable. None was copied from a published chart.

**Four VAT accounts.** `2100` holds the output tax and `1150` the input tax:
the two the taxes post to. `2125` holds the import VAT shown on a customs
entry until TRA at the border is paid. `2110` and `1155` are where a filed
return's balance would land — this pack's golden scenario computes the
return but does not post it, so neither account moves in the golden figures.

**Only three accounts are `reconcilable`**: `1100` (trade receivables),
`2000` (trade payables) and `2110`/`1155` (the VAT settlement accounts).
Every other control account — NSSF, the Workers Compensation Fund, the
Skills Development Levy, withholding tax, import VAT, amounts due to
directors, the bank and cash accounts, the suspense account — is not, so a
bank statement can only ever letter a customer or a supplier line and
`auto_settle()` never mixes two accounts on one reconciliation.

## Taxes

**One statutory rate.** Section 5(1) fixes it at eighteen per cent of the
value of the supply or import; s. 5(2) sets zero-rated supplies at nil.

**What a supply can be, and where it goes on this pack's own numbering of
the return** (see "The return" below for why the numbering is this pack's
own):

| | Code | Box | Legal basis |
|---|---|---|---|
| Standard rate, sale | `TZ-S-18` | 1 | s. 5(1) |
| Zero-rated, export of goods | `TZ-S-ZR-EXP` | 2 | s. 55(1) |
| Zero-rated, export of services | `TZ-S-ZR-SVC` | 2 | s. 61A |
| Zero-rated, locally manufactured goods to Zanzibar | `TZ-S-ZR-ZNZ` | 2 | s. 55A |
| Exempt, health care services | `TZ-S-EX-HEALTH` | 3 | First Schedule, Part I, item 10(1) |

**Purchases:**

| | Code | Box | Legal basis |
|---|---|---|---|
| Standard rate, claimed | `TZ-P-18` | 7, 12 | s. 68(1) |
| Standard rate, disallowed (entertainment, club membership, passenger vehicles) | `TZ-P-18-BL` | none | s. 68(3) |
| Exempt (insurance) | `TZ-P-EX` | 8 | First Schedule, Part I, item 13 |
| Import of goods | `TZ-P-IMP` | 9, 12 | ss. 8, 68(1)(c) |
| Imported service, reverse charge | `TZ-P-RC-IMPSVC` | 5, 10, 12 | s. 2(1) def. of "taxable supply" (b); ss. 4(c), 68(1)(a) |

**Section 55A — a zero rate that is neither a domestic sale nor an ordinary
export.** Goods supplied by a local manufacturer to a taxable person
registered under Zanzibar's own value added tax law are zero-rated if they
leave Mainland Tanzania without being used or enjoyed there — the same
shape s. 55(1) gives an export outside the United Republic, applied instead
to a movement inside the United Republic but across the Mainland/Zanzibar
VAT frontier. `TZ-S-ZR-ZNZ` declares `treatment: "export"` for that reason;
the gap between this and a supply to a genuinely foreign buyer is recorded
in [`docs/international.md`](../../docs/international.md) under "Tanzania".

**The reverse charge on an imported service reaches both an output box and
an input box, unlike Kenya's section 10.** The definition of "taxable
supply" at s. 2(1)(b) makes the purchaser's acquisition of an imported
service itself a taxable supply; s. 4(c) makes the purchaser the person
liable; and s. 68(1)(a) with s. 68(2) makes the same amount both the
purchaser's output tax and its input tax, claimable once the output side is
accounted for in the same return. `TZ-P-RC-IMPSVC` therefore posts a deemed
output entry to box 5 and the matching claim to box 10 — both boxes are
declared, and a wholly taxable purchase nets to zero on `13`, the return's
own bottom line.

## The return

**Filed monthly, on the twentieth of the following month.** Section 2(1)
defines a tax period as a calendar month; s. 66(1) requires the return by
the twentieth day after the end of the period, whether or not an amount is
payable; s. 66(7) rolls that day forward to the next working day when it
falls on a weekend or a public holiday; s. 67(3)(a) makes payment due the
same day.

**This pack's box numbers are its own, not TRA's.** The paper return this
research started from, form ITX 240.02.B, no longer resolves at the
`tra.go.tz` URL that used to serve it, and no public specification of the
on-screen field layout of TRA's current electronic return — filed through
the IDRAS portal — could be independently verified. Rather than guess at a
field numbering this pack's author could not check, `tax_report.json`
numbers its own thirteen boxes directly after what ss. 66 to 68 of the Act
themselves describe: standard, zero-rated and exempt sales; the deemed
output and input of an imported service; standard, exempt and imported
purchases; the totals of each side; and the net amount of s. 67. A reviewer
who can check IDRAS's current screen against this numbering is asked to,
under "Reviewing this pack" below.

**Negative net amounts are declared and computed, not carried forward or
refunded.** Section 67(4) sends a negative net amount to s. 81 (carried
forward) or s. 82 (refunded without carry-forward, where half or more of
turnover or input tax relates to zero-rated supplies); this pack's golden
scenario, heavy with an import and a wholly zero-rated foreign trade in the
same month, in fact produces one — box `13` comes to a negative figure in
`golden/vat_return.json` — but nothing in `tax_report.json` carries the
period-to-period carry-forward or refund application themselves, the same
way `docs/packs.md` describes Singapore's Tourist Refund Scheme boxes as
declared and empty.

**Partial input tax credit is not carried.** Section 70 apportions input
tax between taxable and exempt use for a partly exempt business; this
pack's golden company is wholly taxable, and the formula itself was not
read closely enough to state as a `tax_report.json` box.

## Withholding VAT

**Not in this pack.** The Value Added Tax Act, as amended by the Finance
Act, 2025 with effect from 1 July 2025, requires a designated withholding
agent — the Ministry of Finance, a government institution retaining its own
source revenue, or a VAT-registered person the Commissioner General appoints
— to withhold part of the VAT on a standard-rated supply when paying the
supplier, and to remit it directly to TRA, issuing the supplier a VAT
Withholding Tax Certificate. This is a mechanism a third party to the sale
executes, on rates set by government appointment rather than by the two
parties to the document being posted, the same reason Kenya's withholding
VAT agents are not in `packs/ke/`. It is recorded in
[`docs/international.md`](../../docs/international.md) under "Tanzania".
The consolidated Cap. 148 R.E. 2019 text this pack was read from predates
the amendment, so its exact section number could not itself be checked
against the Act.

## A reduced rate on cashless retail, not yet in force

**Not in this pack.** A further Finance Act, 2025 amendment provides that,
from 1 September 2025, a standard-rated supply to a person in Mainland
Tanzania who is not VAT-registered is taxed at sixteen per cent rather than
eighteen when paid through a bank or an electronic payment system the
Commissioner General approves — an incentive to reduce cash retail, not a
change to the general rate of s. 5(1). Commentary available when this pack
was written reported the Commissioner General's implementing notice, which
would set the eligibility and scope of the approved payment systems, as not
yet issued. A rate a business cannot yet rely on is exactly the kind of
provision [`docs/packs.md`](../../docs/packs.md) says does not belong in a
pack until it is administratively settled; this pack carries the eighteen
per cent of s. 5(1) alone.

## Electronic invoicing: the fiscal device is a clearance, not an exchange

`einvoicing.obligation` is `none` and `profile` is null, and that reads
oddly next to a country where a tax invoice has to be machine-generated by
law. The reason is in the words: Ekwo's vocabulary asks whether a statute
obliges two *businesses* to exchange a *structured invoice* — a Peppol BIS,
a Factur-X, a PINT — between themselves. Tanzania's Value Added Tax Act, s.
86(1) does something else. It requires a registered person to generate, no
later than the day the tax becomes payable, a serially numbered true and
correct tax invoice through an electronic fiscal device (EFD) or, since
2020, a virtual fiscal device (VFD) — the software channel that connects
directly to TRA's Electronic Fiscal Device Management System without a
physical device. The device or VFD channel reports the transaction to TRA
in real time; the buyer receives whatever document the seller always sent
it, and what changed is that the seller's own device clears the invoice
with TRA first. There is no profile to name and no ISO 6523 scheme a party
is addressed by, because nothing is exchanged between the two businesses
that a Peppol-shaped vocabulary would recognise. This is recorded at length
in `pack.json`'s own `einvoicing.legal_reference` and in
[`docs/international.md`](../../docs/international.md) under "Tanzania";
the socle was not changed to fit it.

## What this pack does not carry

- **EFD/VFD clearance.** See above.
- **Withholding VAT.** See above.
- **The reduced sixteen per cent rate on cashless B2C retail.** See above.
- **Partial input tax credit** of a partly exempt business (s. 70) and any
  apportionment formula it sets.
- **Carry-forward and refund of a negative net amount** (ss. 81 to 85):
  period-to-period settlement, not a figure any document posts.
- **Duty-free sales to a tourist or visitor** (s. 55(2)): a licensed
  duty-free vendor's own documentary evidence requirement, narrower than
  the export and Zanzibar zero rates this pack does carry.
- **Income tax withholding** other than VAT: out of scope of a VAT pack.
- **Fixed assets.** No `assets.json`: capital allowances are an income tax
  table (the Income Tax Act's own schedule), not a useful-life the IFRS for
  SMEs Accounting Standard leaves to the entity.
- **Bank formats.** Nothing checked says which formats Tanzanian banks send.
- **Filing itself.** The return is filed on IDRAS; submitting it is a
  credential, not a pack.

## Reviewing this pack

Open an issue titled "Review: Tanzania". What a review is, and what it is
not, is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and
who may say what". The points a Tanzanian accountant should read first,
roughly in the order the author is least sure of them:

1. **`tax_report.json`'s box numbers against the current IDRAS return
   screen**, since no public specification of TRA's on-screen field layout
   could be verified when this pack was written — see "The return" above.
2. **`tax_point: earliest_of_delivery_or_payment`** against s. 15, which is
   in fact a three-way earliest test — invoice issued, consideration
   received, or the time of supply — and not the two-way test the word
   names; see `pack.json`'s own reference and
   [`docs/international.md`](../../docs/international.md).
3. **`TZ-S-ZR-ZNZ` declared `treatment: "export"`**, against whether a
   Tanzanian practitioner reads a supply to a Zanzibar-registered taxable
   person as closer to a domestic zero rate than to an export.
4. **The reverse charge posting both an output and an input box**, against
   how a Tanzanian company in fact completes its return for an imported
   service — this pack reads ss. 2(1)(b), 4(c) and 68 as requiring both
   sides on the face of the return, not a claim-only box the way Kenya's
   section 10 is read.
5. **The chart's mapping onto the statements**, especially amounts due to
   directors and the VAT, NSSF, Workers Compensation Fund and Skills
   Development Levy accounts among trade and other payables.
6. **`numbering: sequential`**, which rests on the serial numbering an
   electronic fiscal device itself assigns (s. 86(1)) rather than a no-gap
   rule stated anywhere for a company's own document series.
7. **`period_default: month`**, which is section 2(1)'s definition rather
   than a cadence any Tanzanian business has been observed to choose
   otherwise.
