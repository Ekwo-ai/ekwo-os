# Ethiopia

Everything Ethiopia adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 15 %, zero rate and exempt supplies under the Value Added
Tax Proclamation No. 1341/2024, the monthly VAT declaration, and a statement
of financial position and a profit and loss statement drawn from the IFRS for
SMEs Accounting Standard. The format is [`docs/packs.md`](../../docs/packs.md);
this file says where the content came from and which decisions it rests on.

**Status: `community`.** Nobody who files an Ethiopian VAT return has reviewed
it. The golden figures prove the pack is coherent and prove nothing about
whether it is right.

**English only.** The published English texts of the Proclamation and the
Regulation are the sources, and Ethiopia keeps no official chart of accounts
in any language. Amharic labels for the main accounts and boxes would be a
welcome addition (an `i18n` file for the Amharic language); none is shipped.
Ethiopia is outside the common system of VAT of Directive
2006/112/EC, so the territory row carries `eu_vat_scope` `none`. The currency
is the birr (`ETB`, two decimals).

## Sources

Nine texts are in the register of `pack.json`; the Ministry of Finance PDF of
the Proclamation is cited as the official copy. The **box layout of the
monthly declaration is this pack's own**: each box says what it holds and the
article it comes from, not a printed line number. A local accountant should
compare it with the form on the e-Tax portal.

| What | Text |
|---|---|
| Rate, zero rate, exemptions, threshold, time of supply, credit, refunds, returns, withholding | Value Added Tax Proclamation No. 1341/2024, arts. 8, 9, 10, 12, 21, 29, 30, 48 to 51, 52, 58, 59, 62 |
| Implementation | Council of Ministers VAT Regulation No. 570/2025 |
| Electricity and water | Ministry of Finance directive of 5 September 2024 |
| Electronic invoicing | Directive No. 1142/2026, Proclamation No. 1434/2026 (secondary summary) |
| Financial reporting | Financial Reporting Proclamation No. 847/2014, art. 5 (IFRS Foundation profile) |
| Where the return is filed | e-Tax portal, `etax.mor.gov.et` |

Article numbers follow a plain-text edition of the Proclamation and differ
from the numbering some commentaries use (the rate is in art. 8(2), the
2,000,000 birr registration threshold in art. 12(2)). The zero-rated and
exempt lists are summarised from the Proclamation's articles and from
secondary commentary, and each tax cites "Schedule 1" or "Schedule 2" without
a paragraph number; Schedules 1 to 3 themselves should be checked.

## The chart of accounts

There is no legal chart in Ethiopia. The Financial Reporting Proclamation
requires IFRS Accounting Standards for public interest entities and the IFRS
for SMEs Accounting Standard for the others, supervised by the Accounting and
Auditing Board of Ethiopia (AABE). The chart is original: 142 four-digit
accounts blocked so that each range reaches one line of the two statements,
with the accounts an Ethiopian company keeps: input and output VAT, import VAT
owed to Customs at the border, withholding tax, pension contributions and
employment income tax. Only trade receivables, trade payables and the two VAT
settlement accounts (1155, 2110) are reconcilable. The VAT settlement
accounts are distinct from the accounts the taxes post to (1150, 2100, 2125).

**Fiscal year.** The statutory tax year runs from 1 Hamle to 30 Sene
(8 July to 7 July), and a body's tax year is its accounting year. The pack's
closed vocabulary offers `calendar`, `april`, `july` and `october`; `july` is
the nearest, starting on 1 July instead of 8 July. A company that keeps a
calendar-year accounting period can choose `calendar` at installation; whether
the Ministry of Revenues accepts that for a given taxpayer is a point for a
local accountant.

## Taxes

| Code | What | Rate |
|---|---|---|
| `ET-S-15` / `ET-P-15` | Sale, deductible purchase | 15 % |
| `ET-P-15-BL` | Purchase with input tax disallowed (passenger vehicles, entertainment, clubs; art. 30) | 15 %, cost |
| `ET-S-ZR-EXP`, `-EXPSVC`, `-INTL` | Zero-rated: export of goods, of services, international transport (Schedule 1) | 0 % |
| `ET-S-EX-FIN`, `-RES`, `-UTIL` | Exempt: financial services, residential rent, the first 200 kWh / 15 m³ per month | exempt |
| `ET-P-EX` | Purchase of an exempt supply | exempt |
| `ET-P-IMP` | Import, VAT paid at Customs and credited | 15 % |
| `ET-P-RC-15` | Reverse charged supply: a service from a supplier outside Ethiopia, accounted for and credited by the recipient | 15 % |

**A service bought from a supplier abroad is a reverse charged supply.** A
software subscription, hosting or an API billed by a person outside Ethiopia
with no fixed place of business there, to a registered person, is a reverse
charged supply (art. 6(1)): VAT at 15 % is imposed on it (art. 8(1)(c)), the
liability arises at the time of the supply and is accounted for by the
recipient (art. 8(8)), who prepares a recipient-created tax invoice
(art. 52(4)). Art. 2 makes that VAT the recipient's output tax and the
supply a *creditable acquisition*, so art. 29(1) credits it as input tax in
the same period, to the extent the service is used for taxable supplies.
`ET-P-RC-15` books both halves: output VAT credited to `2100` and declared in
the pack's own box `RC` (value and VAT), which box 5 now adds; input VAT
debited to `1150` and declared in box 6. A B2C remote service is the foreign
supplier's to charge (arts. 24(2)(c) and 25, and Regulation No. 570/2025), not a posting of
the buyer.

The turnover tax was abolished by Proclamation No. 1395/2025 (8 July 2025) and
is not modelled. Registration is compulsory above 2,000,000 birr of annual
turnover (art. 12(2)); that threshold is a registration test, not a tax code.

## The return

`ET-VAT`, monthly. Boxes: taxable sales (1), zero-rated sales (2), exempt
sales (3), total sales (4), output VAT (5), taxable purchases and imports (6),
exempt purchases (7), total purchases (8), input VAT (9) and the net figure
(10), and a box of this pack's own, `RC`, for reverse charged supplies
received. The return is due on or before the last day of the month after the
period (art. 58), and the tax is payable by the same date (art. 59).

**The calendar trap.** The accounting period is a month of the Ethiopian
calendar, and Nehase (August) and Pagumen, the short thirteenth month, are
aggregated into one period. The pack computes deadlines on Gregorian months,
so the true due date and the period boundaries differ by several days.
Period boundaries and the combined Nehase and Pagumen period are the
company's to set when it closes a period.

## What this pack does not carry

- **Withholding of VAT by public bodies (art. 62).** A government buyer keeps
  50 % of the VAT on a registered supplier's invoice and remits it to the
  authority. The supplier's invoice is for the full amount, the cash received is
  lower, and the withheld part is a payment to the supplier's account with the
  authority. The core has no tax-withheld-by-buyer posting; book it by hand on
  the VAT settlement account.
- **Credit carried forward and refunds (arts. 48 to 51).** Box 10 is the month's
  figure alone; a prior-month credit, the refund after six periods, and the
  refund for mostly zero-rated suppliers are not tracked.
- **Non-resident digital suppliers registered under Regulation No. 570/2025**
  charging VAT to consumers: a supplier-side regime, not the buyer's.
- **Mixed supplies** (credit apportioned between taxable and exempt supplies).
- **A quantity-tiered tax.** The 200 kWh and 15 m³ allowance has its own
  exempt code; the core cannot split a bill by quantity.
- **Electronic invoicing.** See below.

## Electronic invoicing

Directive No. 1142/2026 (June 2026) requires an invoice to be registered in
real time on the Ministry of Revenues platform, which returns an Invoice
Registration Number and a QR code; Proclamation No. 1434/2026 (in force
30 July 2026) raises the penalties. As of 9 October 2026 no nationwide go-live
date or rollout schedule was published, and fiscal cash registers remain in
use. This is a clearance, not an exchange of a structured document, and the
pack says `einvoicing.obligation: none`. The gap is in
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

## Reviewing this pack

A local accountant should check: the box layout against the form on the e-Tax
portal; the Schedule 1 and Schedule 2 lists; the fiscal-year choice; the
electricity and water tiers; and whether the 2025 amendments to the Regulation
changed any treatment cited here.
