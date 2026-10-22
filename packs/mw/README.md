# Malawi

Everything Malawi adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 17.5 % (16.5 % up to 29 December 2025), the zero rate and
exemptions of the two Schedules of the Act, the monthly VAT return, the
statement of financial position and the statement of profit or loss of an
IFRS-based presentation, and what the Act does with a service bought from
abroad. The format is [`docs/packs.md`](../../docs/packs.md); this file says
where the content came from and which decisions it rests on, so that a
Malawian accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Status: `community`.** Nobody who files a Malawian VAT return has reviewed it.
The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**English only.** English is the language of the Value Added Tax Act and of the
documents of the Malawi Revenue Authority ("the Authority"). This pack declares
`en` alone. The currency is the Malawian kwacha (MWK, two decimals).

## Sources

Every tax, box and statement line carries its own `legal_reference`, and beside
it the key of the text that article is in. The register in `pack.json` holds
six texts:

| What | Text | Where |
|---|---|---|
| The charge to tax, imports and imported services, deduction of input tax, returns, the two Schedules | Value Added Tax Act, Chapter 42:02, consolidated to 31 December 2014 | `media.malawilii.org` |
| The rate of 17.5 % from 30 December 2025 | Public Notice, new tax measures for the mid-year budget review | `mra.mw` |
| Rate, schedules, invoices, the 25th-day deadline (older brochure) | Understanding VAT | `elibrary.mra.mw` |
| Where taxpayers register and file | the Authority's site | `mra.mw` |
| Real-time invoicing | EIS portal | `eis-portal.mra.mw` |
| The accounting framework | IFRS Foundation, Jurisdictional Profile: Malawi | `ifrs.org` |

**The consolidated Act is an old edition, and this is the weak point of the
pack.** The copy of the Act that could be read is the 2014 consolidation. It
prints the rate as 16.5 %, a registration threshold of K10,000,000, and
Schedules from before the amendments of the following years. The rate of
17.5 % is taken from the Authority's own public notice (the Value Added Tax
(Amendment) Act, 2025 is listed in the Authority's library, but its text is
behind a login and was not read). Amendments between 2015 and 2025 to the First
and Second Schedules, to the threshold (trade commentary reports K25,000,000 from
2021, which no official text read here confirms) and to the sections cited could
not be checked. A Malawian accountant must confirm each Schedule item before a
supply is coded to a zero rate or an exemption.

## The chart of accounts, and why this one

There is no legal chart of accounts in Malawi. This one is original: four
digits, blocked so that each range reaches one line of the statements, 147
accounts. Beyond a general IFRS-style chart it carries what a Malawian company
owes: VAT output and input, the net VAT settlement account, import VAT at the
border, PAYE, pension contributions, withholding tax, excise duty and other
levies payable, and a cost account (6530) for VAT the Act does not let a buyer
recover. Pension and levy accounts are generic: the rates and the bodies were not
sourced.

Only trade receivables, trade payables and the two VAT settlement accounts
(1155 and 2110) are reconcilable. The bank, cash and suspense accounts are not.

## Taxes

| Code | Rate | What |
|---|---|---|
| `MW-S-17.5` | 17.5 % | Standard-rated sale, from 30 December 2025 |
| `MW-S-16.5` | 16.5 % | Standard-rated sale up to 29 December 2025 (closed) |
| `MW-S-Z-EXP` | 0 % | Export of goods and services (Second Schedule, items 1 and 2) |
| `MW-S-Z-DOM` | 0 % | Local zero-rated supply (fertilizers, pharmaceutical products and the other items of the Second Schedule) |
| `MW-S-EX` | exempt | The First Schedule: unprocessed food, water, books, petroleum, education, banking and life insurance, medical services, residential rentals |
| `MW-P-17.5`, `MW-P-16.5` | 17.5 % / 16.5 % | Deductible purchase, by date |
| `MW-P-17.5-ND` | 17.5 % | Purchase whose input tax is blocked (motor vehicles, entertainment); the tax goes to account 6530 |
| `MW-P-Z`, `MW-P-EX` | 0 % | Zero-rated and exempt purchases |
| `MW-P-IMP` | 17.5 % | Import of goods, tax paid on the customs entry and deducted |
| `MW-P-RC-SVC` | 17.5 % | Imported service, tax self-charged by the receiver and deducted |

Two choices carry the weight:

- **The rate moved on 30 December 2025.** Both codes exist, the older one
  closed on 29 December 2025, so a document is taxed by its date. The Authority's
  notice says "effective from 30th December, 2025"; trade commentary dates it
  31 December or 1 January, and a business that invoiced on those days should
  confirm the day with the Authority.
- **An imported service is taxed and deducted.** Section 7(1)(c) charges VAT on
  the supply of an imported service and section 8(c) makes the receiver pay it;
  section 30(1) lets a taxable person deduct VAT on goods and services imported
  and used in the business. The pack posts the output tax (row 1R) and the input
  tax (row 2) side by side, so they cancel in the amount payable. Where the
  service is exempt, or the buyer makes exempt supplies, s. 30(3) and s. 32
  restrict the deduction; the pack does not apportion.

The Authority's 2026/27 notices on sugar exports (VAT applies and is refunded on
proof of export) and other changes of the budget are not carried.

## The return

Monthly (s. 34(1)). The Act says what the return states — the VAT payable, the
input tax credit or refund claimed, and what is prescribed — but the prescribed
form and its numbered boxes could not be opened: the Authority's site is a
script-driven application, and its forms library asks for a login. The rows of
`tax_report.json` are therefore this pack's own: value rows for exports, local
zero-rated supplies, exempt supplies, standard-rated supplies, imported services,
zero-rated purchases, local purchases and imports, then output VAT, input VAT and
the amount payable or repayable. Their numbers do not claim to be the numbers of
the Authority's form.

**Deadline.** Day 25 of the month after the period, for the return and the
payment (s. 34(4) and (6); the Authority's brochure says the same). The
Commissioner General may extend it on application (s. 34(5)).

**Registration.** Compulsory above a turnover set by the Act at K10,000,000 a
year (s. 11(1)) and revisable by Order of the Minister (s. 11(2)); a later
threshold is reported by trade commentary only. The pack does not check a
threshold.

## Electronic invoicing: a clearance, not an exchange

Section 25 of the Act (2014 text) has a taxable person issue an electronic
fiscal device generated tax invoice or a prescribed tax invoice. The Authority
now runs an Electronic Invoicing System (EIS) with a point-of-sale management
portal, which replaces fiscal devices. The Authority's own notices on the start
date, the taxpayers concerned and the penalties could not be read; trade
commentary reports a transition ending on 31 January 2026 and mandatory use
from 1 May 2026, and that invoices from fiscal devices stop supporting an input
tax claim. The pack relies on none of it.

This is real-time clearance by the tax administration, not an exchange of a
structured document between two businesses. `einvoicing.profile` is null and
`obligation` is `none`. The socle cannot call the EIS or print a fiscal code, so
a company on Ekwo issues the invoice through its approved system and records the
same document here.

## What this pack does not carry

- Corporate income tax, PAYE, the new levy on transfers, the minimum alternate
  tax and the other measures of the 2025/26 mid-year budget: no tax code, and
  no source read beyond the Authority's one-page notice.
- Partial-exemption apportionment (s. 32), adjustments (s. 29), relief
  supplies (s. 23, Third Schedule), deemed supplies and the VAT on foreign
  digital services reported by commentary as effective in April 2026.
- The Second Schedule items deleted by Act No. 23 of 2011 and anything changed
  since 2014; `MW-S-Z-DOM` and `MW-S-EX` stand for all their items, and the item
  is named in the invoice line.
- The exemption reason code (BT-121): Malawi is outside the common system, so
  no VATEX code is carried.

## Reviewing this pack

A Malawian accountant is asked to confirm: the 17.5 % effective day; the
current First and Second Schedules; the registration threshold; the numbered
boxes of the VAT return against the Authority's portal; the deduction of VAT on
imported services; the EIS start date and the date from which input tax needs
an EIS invoice; and the grouping of accounts against the format ICAM members
use under IFRS for SMEs.
