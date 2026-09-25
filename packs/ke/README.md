# Kenya

Everything Kenya adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 16 %, zero rate and exempt, the monthly VAT 3 return, the
statement of financial position and the profit and loss account of the IFRS
for SMEs Accounting Standard, and what section 10 of the Act does with a
service bought from abroad. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Kenyan accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Kenyan VAT return has reviewed it.
The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**English only.** Kenya keeps no official chart of accounts in any language,
and neither the Value Added Tax Act nor ICPAK's illustrative IFRS for SMEs
statements have a Swahili edition to transcribe labels from — Kiswahili is an
official language of Kenya, but its accounting vocabulary has not been
standardised the way, say, Estonian or Korean company law has. Rather than
invent Swahili labels nobody has published, this pack declares `en` alone.
What the core could not say is written up in
[`docs/international.md`](../../docs/international.md) under "Kenya". None of
it was patched for this pack's sake.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and
beside it the key of the text that article is in. The register in
`pack.json` holds nine texts, every one opened on 25 September 2026. The ones
the rest of this file leans on:

| What | Text | Where |
|---|---|---|
| The charge to tax, the rate, zero-rating, imported services, time of supply, input tax, records, returns | Value Added Tax Act (Cap. 476), ss. 5, 6, 7, 10, 12, 17, 19, 22, 42, 43, 44 | `new.kenyalaw.org` |
| Which goods and services are zero-rated or exempt | Value Added Tax Act, First and Second Schedules | `new.kenyalaw.org` |
| Electronic tax invoices | Tax Procedures Act (Cap. 469B), s. 23A | `new.kenyalaw.org` |
| The roll-out of electronic tax invoicing, 2020 to 2021 | Value Added Tax (Electronic Tax Invoice) Regulations, 2020 (L.N. 189/2020) | `kra.go.ke` |
| Accounting records, financial statements | Companies Act (Cap. 486), ss. 628, 636 to 638 | `new.kenyalaw.org` |
| The statement of financial position and the profit and loss account | ICPAK, illustrative IFRS for SMEs financial statements | `icpak.com` |
| What each row of the return holds, filing and payment by the 20th, eTIMS on-boarding | KRA, *Value Added Tax (VAT)*; form VAT 3 workbook | `kra.go.ke` |

Kenya Law's site (`new.kenyalaw.org`) refuses a plain HTTPS request with no
browser behind it and returns 403; every Act cited here was instead read from
the PDF it serves at `.../source.pdf` on the same URL, which is not
browser-gated. `ekwo pack check ke --links` will report those four law URLs as
unreachable for the same reason: it is the publisher, not a wrong link.

## The chart of accounts, and why this one

**Kenya prescribes no chart of accounts.** Companies Act, s. 628(1) requires
every company to keep proper accounting records, s. 628(3)(b) requires them to
comply with the prescribed financial accounting standards, and s. 638 requires
a balance sheet and a profit and loss account that give a true and fair view
under those same standards. ICPAK, the standard-setting body the Accountants
Act, 2008 recognises, has adopted the IFRS for SMEs Accounting Standard for an
entity with no public accountability. So the chart is written, not
transcribed, in the same shape as the Singaporean and Australian packs:

- **Four digits, by class**: `1` assets, `2` liabilities, `3` equity, `4`
  revenue and other income, `5` goods and materials, `6` other expenses, `7`
  finance costs, `8` income tax.
- **Flat**, every account a leaf, grouped by the ranges of `statements.json`.
- **Land and buildings, not leasehold property**, since a Kenyan trading
  company more often owns its premises than leases them; a leasehold
  improvements line sits beside it for the company that does lease.
- **The accounts a Kenyan company keeps by law or by market practice**: NSSF
  and SHIF contributions payable, the NITA training levy, withholding tax
  payable to KRA, import VAT owed to KRA at the border, amounts due to
  directors, and a cash-in-transit line for M-Pesa and card settlements —
  mobile money is how most Kenyan retail is actually collected.

134 accounts, all postable. None was copied from a published chart.

**Four VAT accounts.** `2100` holds the output tax and `1150` the input tax:
the two the taxes post to. `2125` holds the import VAT shown on a customs
entry until KRA at the border is paid. `2110` and `1155` are where a filed
return's balance lands — see below.

**Only three accounts are `reconcilable`**: `1100` (trade receivables), `2000`
(trade payables) and `2110`/`1155` (the VAT settlement accounts). Every other
control account — NSSF, SHIF, the NITA levy, withholding tax, import VAT,
amounts due to directors, the bank and cash accounts, the suspense account —
is not, so a bank statement can only ever letter a customer or a supplier line
and `auto_settle()` never mixes two accounts on one reconciliation.

## Taxes

**One statutory rate.** Section 5(2)(b) fixes it at sixteen per cent; section
6(1) lets the Cabinet Secretary vary it by an order in the Gazette, by up to a
quarter either way, and that power has been used repeatedly on specific
petroleum products — most recently an 8 % rate from 16 April to 14 October
2026 (Legal Notice No. 69 and No. 70 of 2026). `tax_report.json` carries the
row form VAT 3 gives that variation (rows 2 and 8), declared and empty,
because a rate an order changes every few months is exactly the kind of feed
[`docs/packs.md`](../../docs/packs.md) says does not belong in a pack — this
pack carries the sixteen per cent of the Act and nothing an order has not made
permanent.

**What a supply can be, and where it goes on form VAT 3:**

| | Code | Box | Legal basis |
|---|---|---|---|
| Standard rate, sale | `KE-S-16` | 1 | s. 5(2)(b) |
| Zero-rated, domestic (LPG) | `KE-S-ZR-DOM` | 3 | Second Schedule, Part A, ¶ 27 |
| Zero-rated, export of goods | `KE-S-ZR-EXP` | 3 | Second Schedule, Part A, ¶ 1 |
| Zero-rated, export of services | `KE-S-EXP-SVC` | 3 | Second Schedule, Part A, ¶ 23 |
| Exempt, financial services | `KE-S-EX-FIN` | 4 | First Schedule, Part II, ¶ 1(b) |

**Purchases:**

| | Code | Boxes | Legal basis |
|---|---|---|---|
| Standard rate, claimed | `KE-P-16` | 7, 12 | s. 17(1) |
| Standard rate, disallowed (cars, entertainment) | `KE-P-16-BL` | none | s. 17(4) |
| Zero-rated | `KE-P-ZR` | 9 | s. 7(2) |
| Exempt (insurance) | `KE-P-EX` | 10 | First Schedule, Part II, ¶ 2 |
| Import of goods | `KE-P-IMP` | 7, 12 | ss. 5(5), 14, 22 |
| Imported service, reverse charge | `KE-P-RC-IMPSVC` | 15 | s. 10 |

**Section 10 is not a European reverse charge, and it is not modelled as
one on the return.** A registered person who buys an imported service is
"deemed to have made a taxable supply to himself" (s. 10(1)); the output tax
falls due immediately (s. 10(3)), and the person raises a Self-Assessment
payment on iTax and remits it directly to KRA rather than through the output
side of form VAT 3. What comes back onto the return is only the input claim,
at Section O row 15. `KE-P-RC-IMPSVC` therefore books the deemed output
liability and the input claim on posting, so the net ledger effect matches the
law, but sends only the claim to a box — the way form VAT 3 itself is laid
out, and not a European `domestic_reverse_charge` shape.

## The return

**Form VAT 3, one workbook, filed monthly.** Section 2(1) defines a tax period
as one calendar month "or such other period as may be prescribed"; nothing
else has been prescribed, so `tax_report.json` carries `month` alone. Section
44(1) sets the return due, and section 19(2) lets payment follow it, on the
twentieth day after the end of the period.

**Rows 1 to 15 and row 20 are carried; rows 16 to 19 and 21 to 28 are not, and
both gaps are real.** Row 18, "Less: Non-Deductible Input VAT", is stated on
the form as `17 - (((1+2+3)/5)*17)` — an apportionment of input tax between
taxable and exempt turnover as a ratio of a ratio, which `tax_report.json`'s
plus/minus/rate vocabulary cannot express (a `rate` box takes one other box,
never an expression over five of them). Row 19 is declared as `14 + 15` alone,
which is the figure a wholly taxable business — the golden company here — in
fact files; a partly exempt one needs an apportionment this pack does not
compute. Rows 21 to 28 (credit brought forward, withholding VAT credits,
payments already made, credit and debit adjustment vouchers, the net credit
carried forward) are period-to-period settlement, not a figure any document
posts, in the same way `docs/packs.md` describes Singapore's Tourist Refund
Scheme boxes as declared and empty.

## Withholding VAT

**Not in this pack.** Appointed withholding VAT agents deduct a percentage of
the taxable value of a supply and remit it directly to KRA, crediting the
supplier's account — a mechanism a third party to the sale executes, on a rate
Parliament has changed more than once (most recently down to 2 % in 2023).
Modelling an agent who is neither the seller nor the buyer of the document
being posted is beyond what a `taxes.json` posting, which always speaks of the
two parties to one document, can state. It is recorded in
[`docs/international.md`](../../docs/international.md) under "Kenya".

## Electronic invoicing: eTIMS is a clearance, not an exchange

`einvoicing.obligation` is `none` and `profile` is null, and that reads
oddly next to a country where an electronic tax invoice has in substance been
compulsory since September 2023. The reason is in the words: Ekwo's
vocabulary asks whether a statute obliges two *businesses* to exchange a
*structured invoice* — a Peppol BIS, a Factur-X, a PINT — between themselves.
Kenya's Tax Procedures Act, s. 23A does something else. It requires a business
to generate its invoice through KRA's own system (an ETR device, the OSCU or
VSCU software, or the free eTIMS Lite channels), which validates it against
the seller's stock records and — since the Finance Act, 2023 and the Tax Laws
(Amendment) Act, 2024 — disallows the expense for income tax if it was not so
generated. The buyer receives whatever document the seller always sent it;
what changed is that the seller's own system now clears the invoice with KRA
first. There is no profile to name and no ISO 6523 scheme a party is
addressed by, because nothing is exchanged between the two businesses that a
Peppol-shaped vocabulary would recognise. This is recorded at length in
`pack.json`'s own `einvoicing.legal_reference` and in
[`docs/international.md`](../../docs/international.md) under "Kenya"; the
socle was not changed to fit it.

## What this pack does not carry

- **eTIMS as a clearance mechanism.** See above.
- **Withholding VAT.** See above.
- **The apportionment of input tax** of a partly exempt business (form VAT 3,
  rows 16 to 18) and any de minimis rule around it.
- **The Cabinet Secretary's temporary rate orders** under s. 6(1) — currently
  an 8 % rate on specified petroleum products — which move every few months
  and are not pack data for the reason given under "Taxes".
- **Income tax withholding** other than VAT (s. 35 of the Income Tax Act):
  out of scope of a VAT pack.
- **Fixed assets.** No `assets.json`: capital allowances are an income tax
  table (the Second Schedule to the Income Tax Act), not a useful-life the
  IFRS for SMEs Accounting Standard leaves to the entity.
- **Bank formats.** Nothing checked says which formats Kenyan banks send.
- **Filing itself.** The return is filed, and self-assessment payments for
  imported services are registered, on iTax; submitting either is a
  credential, not a pack.

## Reviewing this pack

Open an issue titled "Review: Kenya". What a review is, and what it is not, is
in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who may
say what". The points a Kenyan chartered accountant should read first,
roughly in the order the author is least sure of them:

1. **`tax_point: earliest_of_delivery_or_payment`** against s. 12(1), which is
   in fact a four-way earliest test — delivery, a supervising consultant's
   certificate, invoice issue, or payment — and not the two-way test the word
   names; see `pack.json`'s own reference and
   [`docs/international.md`](../../docs/international.md).
2. **Section 10 modelled as a reverse charge that reaches only box 15**,
   against how a Kenyan practitioner actually reports a Self-Assessment
   payment for an imported service.
3. **`KE-P-16-BL` reaching no box**, against whether form VAT 3's own
   General Rated Purchases detail sheet in fact expects a disallowed
   purchase to be listed there at zero-claim rather than omitted.
4. **Row 19 as `14 + 15` alone**, and whether a wholly taxable golden company
   is the only case worth carrying without the apportionment of rows 16 to 18.
5. **The chart's mapping onto the statements**, especially amounts due to
   directors among current borrowings and the VAT, NSSF, SHIF and NITA
   accounts among trade and other payables.
6. **`numbering: sequential`**, which rests on a serial-number requirement in
   the Tax Procedures Act rather than a no-gap rule stated anywhere for a
   Kenyan tax invoice.
7. **`period_default: month`**, which is section 2(1)'s definition rather
   than a cadence any Kenyan business has been observed to choose otherwise.
