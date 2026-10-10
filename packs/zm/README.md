# Zambia

Everything Zambia adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 16 %, the zero rate and exemptions, the monthly VAT return
as the Zambia Revenue Authority describes it, the statement of financial
position and the statement of profit or loss of an IFRS-based presentation, and
what section 8 of the Act does with a service bought from abroad. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Zambian accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Zambian VAT return has reviewed it.
The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**English only.** English is the official language of the Value Added Tax Act
and of every document of the Zambia Revenue Authority ("the Authority"). This
pack declares `en` alone. The currency is the Zambian kwacha (ZMW, two
decimals, the rebased kwacha).

## Sources

Every tax, box and statement line carries its own `legal_reference`, and beside
it the key of the text that article is in. The register in `pack.json` holds ten
texts:

| What | Text | Where |
|---|---|---|
| The charge to tax, the rate, time of supply, returns, input tax | Value Added Tax Act, Chapter 331, ss. 7 to 19 | `parliament.gov.zm` |
| The 2023 amendment: imported services, e-invoicing, input tax evidence | Practice Note No. 1/2024 (Act No. 27 of 2023, S.I. No. 60 of 2023) | `zra.org.zm` |
| What is exempt and what is zero-rated, group by group | VAT Liability Guide | `zra.org.zm` |
| The rate, registration threshold, filing, the five boxes of the return | VAT Guide | `zra.org.zm` |
| The filing and payment day | Payment Due Dates | `zra.org.zm` |
| Water and sewerage zero-rated from 1 January 2026 | S.I. No. 95 of 2025 | `zambialii.org` |
| Smart Invoice, its penalties and its solutions | Smart Invoice FAQs; available solutions | `zra.org.zm` |
| Where the return is filed | ZRA Tax Online | `portal.zra.org.zm` |
| The accounting framework | ZICA, Financial Reporting | `zica.co.zm` |

**The consolidated Act is an old edition.** The copy the Parliament of
Zambia serves still prints the rate as seventeen and a half per centum "unless
the Minister, by statutory order, determines a lower rate" (s. 9(3)), still
gives the First and Second Schedules as lists of exemptions and zero-ratings
(since moved to the Exemption Order and the Zero-Rating Order), and gives twenty-one
days for a return. The 16 % rate, the two Orders and the eighteenth of the month
are taken from the Authority's own guides and its due-dates page, which are
later. The amendments of 2023 are cited from the Authority's practice note, not
from a consolidated Act. The statutory order that fixed 16 % is not cited; the
earliest date the pack evidences is 2012.

The water change rests on budget analyses and on the title and date of
Statutory Instrument No. 95 of 2025; it should be confirmed against the
instrument itself. `zambialii.org` and `zra.org.zm` block automated link
checks, so `ekwo pack check zm --links` may report them unreachable.

## The chart of accounts, and why this one

There is no legal chart of accounts in Zambia. This one is original: four
digits, blocked so that each range reaches one line of the statements, 147
accounts. Beyond a general IFRS-style chart it carries what a Zambian company
owes: VAT output and input, the net VAT settlement account, import VAT at the
border, PAYE, NAPSA contributions, skills development levy, withholding tax,
insurance premium levy, excise duty and turnover tax payable, and two cost
accounts for VAT the law does not let a buyer recover (6520 and 6530).

Only trade receivables, trade payables and the two VAT settlement accounts
(1155 and 2110) are reconcilable. The bank, cash and suspense accounts are not.

## Taxes

| Code | Rate | What |
|---|---|---|
| `ZM-S-16` | 16 % | Standard-rated sale |
| `ZM-S-Z-EXP` | 0 % | Export of goods, services rendered outside Zambia, international freight |
| `ZM-S-Z-DOM` | 0 % | Local zero-rated supply (medical supplies and drugs, agricultural inputs and the other lines of the Zero-Rating Order) |
| `ZM-S-Z-WATER` | 0 % | Mains water and sewerage, from 1 January 2026 |
| `ZM-S-EX` | exempt | Health, education, residential property, financial and insurance services |
| `ZM-S-EX-WATER` | exempt | Mains water and sewerage, 1 January 2024 to 31 December 2025 (closed) |
| `ZM-P-16` | 16 % | Deductible purchase |
| `ZM-P-16-ND` | 16 % | Purchase whose input tax is blocked; the tax goes to account 6530 |
| `ZM-P-Z`, `ZM-P-EX` | 0 % | Zero-rated and exempt purchases |
| `ZM-P-IMP` | 16 % | Import of goods, tax paid at the border and claimed in box 3 |
| `ZM-P-RC-SVC` | 16 % | Imported service, tax self-charged and not recoverable |

Two choices carry the weight:

- **Water moved from exempt to zero-rated on 1 January 2026.** Both codes exist,
  the older one closed on 31 December 2025, so a document is taxed by its date.
- **An imported service is not deductible.** Section 8(5), as substituted by Act
  No. 27 of 2023, makes the recipient pay the tax, and section 8(7) excludes the
  corresponding input tax from section 18. The pack posts the tax to output (box
  1R) and to the cost account 6520. A cross-border *electronic* service is
  instead taxed by the non-resident supplier on its own invoice, who registers in
  Zambia; that purchase takes `ZM-P-16`.

**Temporary zero rate on imported fuel (not carried).** Zambia zero-rated VAT on
imports of petrol and diesel for three months from 1 April 2026, extended from
1 July to 30 September, and press reports say the VAT zero rate continues
until December 2026 while excise returned in October. No statutory instrument
is cited for the legal text, the scope or the closing date, so the pack adds
no code for it, rather than one with a guessed end date. A company importing
fuel in that window picks `ZM-P-IMP` and corrects the rate by hand, or adds a
dated code once the instrument is confirmed.

## The return

Monthly. The Authority's VAT Guide describes the return through five numbered
boxes — 1 output VAT, 2 input VAT on domestic purchases, 3 input VAT on imports,
4 total input VAT, 5 tax payable or repayable. The pack carries those five, in
`tax_report.json`, plus value rows of its own (zero-rated exports and local
supplies, exempt supplies, standard-rated supplies and purchases, zero-rated
purchases, imported services). The layout of the screen on ZRA Tax Online may
differ from these rows.

**Deadline.** Day 18 of the month after the period. The Authority's due-dates
page puts the payment of an electronically submitted return on the 18th of every
month, and the VAT Guide gives eighteen days for a return of ten or more
transactions, which must be filed electronically; fewer than ten may be filed
manually within five days. Taxpayers file nil returns. The consolidated Act's
twenty-one days is overtaken.

**Registration.** Compulsory when taxable supplies exceed K800,000 in twelve
consecutive months or K200,000 in three, per the VAT Guide; the pack does not
check a threshold.

## Electronic invoicing: Smart Invoice is a clearance, not an exchange

Smart Invoice is the Authority's electronic invoicing system, a legal
requirement under section 7A of the Act (penalties of K40,000, K80,000 and
K120,000 or imprisonment for a first, second and later offence). It applies to
every VAT-registered taxpayer; compliance was due from 1 July 2024, a grace
period ran to 30 September 2024 and penalties run from 1 October 2024 (dates
from the Authority's announcements and trade commentary, not from a statutory
text). Input tax is claimable only against an invoice from the approved system
(s. 18(3), as substituted); trade sources date the practical restriction to
1 January 2025 or 1 January 2026 and disagree, so the pack does not model it.
An accounting package connects through a certified invoicing system and the
Virtual Sales Data Controller.

This is real-time clearance by the tax administration, not an exchange of a
structured document between two businesses. `einvoicing.profile` is null and
`obligation` is `none`. The socle cannot call the Virtual Sales Data Controller,
receive a fiscal code or print the QR code, so a company on Ekwo issues the
invoice in Smart Invoice and records the same document here.

## Other taxes, documented and not computed

- **Insurance premium levy**: 5 % of insurance premiums, return and payment on
  the 18th of every month (Authority's due-dates page and VAT Liability Guide).
  Insurance is VAT-exempt but bears this levy; a company that writes insurance
  keeps it in account 2165.
- **Excise duty** on local production: payment on the 15th of the following
  month; kept in account 2170. Not a line tax.
- **Turnover tax, PAYE, skills development levy, withholding tax**: monthly,
  each with its own day (turnover tax the 14th, withholding the 14th, PAYE and
  skills development levy the 10th). Accounts exist; no tax code.

## What this pack does not carry

- Over-claim adjustments, bad-debt relief, the partial-exemption
  apportionment (a business with taxable and exempt supplies recovers only the
  taxable share of its input tax) and the retention of VAT by appointed
  agents.
- The VAT "LPO" mechanism, by which a privileged person buys standard-rated
  supplies at 0 % against a local purchase order; the golden carries no such
  document.
- The Zero-Rating Order and the Exemption Order are long. `ZM-S-Z-DOM` and
  `ZM-S-EX` stand for all their groups; the group is named in the invoice line.
- The exemption reason code (BT-121): Zambia is outside the common system, so
  no VATEX code is carried.
- Corporate income tax, provisional tax and fixed-asset allowances.

## Reviewing this pack

A Zambian accountant is asked to confirm: the 16 % effective date; the
treatment of imported services as non-deductible (s. 8(7)); the water
zero-rating against Statutory Instrument No. 95 of 2025; the layout of the VAT
return on ZRA Tax Online against the five boxes here; the fuel import window;
the Smart Invoice date from which input tax needs a Smart Invoice; and the
turnover thresholds of the ZICA tiers (K20 million).
