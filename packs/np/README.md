# Nepal

Everything Nepal adds to Ekwo, as data: a chart of accounts, the journals, the
value-added tax at a flat 13 %, the zero rate and the exemption of the two
Schedules of the Act, the monthly VAT return as the Act describes it, the
statement of financial position and the statement of profit or loss of an
NFRS-based presentation, and what the Act does with a service bought from
outside Nepal. The format is [`docs/packs.md`](../../docs/packs.md); this file
says where the content came from and which decisions it rests on, so that a
Nepalese accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Status: `community`.** Nobody who files a Nepalese VAT return has reviewed it.
The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**English only.** The Act and the Department's forms exist in Nepali; no
translation of the chart and the return could be checked by a reader of Nepali,
so none is shipped and the pack declares `en` alone. The currency is the
Nepalese rupee (NPR, two decimals).

## Sources

Every tax, box and statement line carries its own `legal_reference`, and beside
it the key of the text that article is in. The register in `pack.json` holds
five texts:

| What | Text | Where |
|---|---|---|
| The charge, the rate, the time of supply, registration, the invoice, the deduction, the monthly return and payment, a service from outside Nepal | Value-Added Tax Act, 2052 (1996), English text as amended to the Financial Act, 2021 | `ird.gov.np`, through the Internet Archive |
| The current consolidated Act in Nepali, amended to the Economic Act, 2082 | The Department's page for the Act | `ird.gov.np` |
| The accounting framework | IFRS jurisdiction profile of Nepal | `ifrs.org` |
| The income year | Income Tax Act, 2058 (unofficial translation) | `ird.gov.np` |
| Where the Department publishes | Inland Revenue Department | `ird.gov.np` |

**The text read is not the current one.** The English file the Department used
to publish stops at the Financial Act, 2021. The Department's page for the
current consolidated text offers a Nepali PDF that its content server did not
send to the machine this pack was written on. The pack therefore states the
Act as of 2021; the Financial Acts of 2022 to 2025 and the Economic Act, 2082
are not read, and a rate, a threshold or a deadline they changed is a gap. The
thirteen percent rate is the one the text read gives, and the commentaries
published in 2026 still give it.

**The Schedules were not readable.** The file holds sections 1 to 44 and no
Schedule. Schedule 1 (exempt) and Schedule 2 (zero rate) are therefore not
transcribed. What the pack says about them — education, health and basic
agricultural products exempt, exports at zero — comes from secondary guides and
commentary and is marked as such in each `legal_reference` and in the golden.
The pack has one code for each treatment and no list of items.

## The chart of accounts, and why this one

There is no legal chart of accounts in Nepal. This one is original: four
digits, blocked so that each range reaches one line of the statements, 146
accounts. Beyond a general NFRS-for-SMEs chart it carries what a Nepalese
company owes: VAT output and input, the net VAT settlement account (1155 and
2110), import VAT at customs clearance, tax deducted at source, remuneration tax
and provident fund contributions, and one cost account for VAT the Rules do not
let a buyer deduct (6530).

Only trade receivables, trade payables and the two VAT settlement accounts are
reconcilable. The bank, cash and suspense accounts are not.

## Taxes

| Code | Rate | What |
|---|---|---|
| `NP-S-13` | 13 % | Standard-rated sale (s. 7(1)) |
| `NP-S-Z-EXP` | 0 % | Schedule 2, chiefly exports (s. 7(2)) |
| `NP-S-EX` | exempt | Schedule 1 (s. 5(3)) |
| `NP-P-13` | 13 % | Deductible purchase (s. 17(1)) |
| `NP-P-13-ND` | 13 % | Purchase whose input tax the Rules block or only partly allow (s. 17(2)); the tax goes to account 6530 |
| `NP-P-EX` | 0 % | Exempt purchase |
| `NP-P-IMP` | 13 % | Import of goods, tax paid at customs clearance and deducted (ss. 5(1)(b), 17(1)) |
| `NP-P-RC-SVC` | 13 % | Service from outside Nepal, tax assessed by the buyer and deducted (ss. 8(2), 17(5b)) |

Three choices carry the weight:

- **Zero-rated is not exempt.** A zero-rated supplier keeps its deduction; for
  an exempt one, s. 5(3) takes it away. A company with both must apportion
  (s. 17(3)), which the pack does not do.
- **A service from outside Nepal is deductible.** Section 8(2) makes the person
  who acquires it assess the tax and s. 17(5b) allows the deduction.
  `NP-P-RC-SVC` posts both, in boxes 1R and 2R.
- **The non-deductible code is a placeholder for the Rules.** Section 17(2)
  leaves the list of goods with no or partial deduction to the Value Added Tax
  Rules, 2053, which were not read. The code exists so a purchase can be booked
  once the accountant has decided; the pack lists no goods.

## The return

Monthly: section 18(1) has every taxpayer assess the tax each month and submit
the return within twenty-five days of the completion of the month, whether or
not a taxable transaction took place; section 18(2) lets prescribed taxpayers
file for a longer or shorter period. The pack carries rows grouped under the
figures the Act names — output tax, deduction, the net amount — in
`tax_report.json`. The electronic form was not opened, so these rows are the
pack's own and the box codes (`1S`, `2`, `3`…) are internal labels, not form
numbers.

**Deadline.** Day 25 of the month after the period. Nepal counts its months in
the Bikram Sambat calendar (Baisakh to Chaitra, 29 to 32 days, beginning in the
middle of a Gregorian month); the pack's periods are Gregorian, so the pack's
day 25 is an approximation, and a Nepalese company must confirm the real date
with its own calendar. Section 19(1) has the tax paid within the same twenty-five
days; the additional fee of ten percent a year of s. 19(2) is not modelled.

**Registration.** Section 10 requires registration within thirty days of the
tax being levied or the transaction starting; the thresholds sit in the Act and
the Rules as the Financial Acts amended them and were not verified, so the pack
checks none. A person who carries only exempt transactions need not register
(s. 10(3)).

## Fiscal year

The income year runs from the first of Shrawan to the last of Ashad
(tentatively 15 July to 14 July of the next year; Income Tax Act, 2058). The
format offers `july`, a year that begins on 1 July: the pack declares it and the
golden uses 1 July 2026 to 30 June 2027. A Nepalese company sets its first day
by hand. Income tax itself is not modelled.

## Electronic invoicing

Section 14A lets a taxpayer issue an electronic invoice with the Department's
approval, and lets the Department oblige named taxpayers to issue one linked to
its central invoice monitoring system. That is not a structured exchange
between businesses: `einvoicing.profile` is null and `obligation` is `none`.

## What this pack does not say yet, and why

- **The Schedules**, and with them the list of exempt and zero-rated items.
- **Everything the Financial Acts of 2022 to 2025 and the Economic Act, 2082
  changed**, including any new threshold.
- **The VAT Rules, 2053**: invoice particulars and serial number, the goods whose
  deduction is blocked, partial deduction, quarterly filers.
- **The return form** on the Department's portal.
- **The Bikram Sambat calendar** for periods and deadlines (above).
- **The time of supply.** Section 6(2) is the earliest of invoice, delivery or
  rendering, and payment; the closed vocabulary has a two-way earliest-of, so an
  invoice issued before both needs a manual look.
- **Partial deduction** (s. 17(3)), the recovery when a good leaves taxable use
  (s. 17(4)), damaged or lost goods (s. 16B), refunds (s. 24), special regimes.
- **Other taxes**: excise duty, customs duty, income tax, tax deducted at source
  and provident fund have accounts but no tax code.
- **The exemption reason code (BT-121)**: Nepal is outside the common system of
  VAT, so no VATEX code is carried.
- **A Nepali translation.**

## Reviewing this pack

A Nepalese accountant is asked to confirm: the 13 % rate and anything that
replaced the flat rate since 2021; Schedules 1 and 2 against the items the
golden uses (education, agriculture, health, exports); the filing day against
the Bikram Sambat month; the layout of the return on the portal against the rows
here; the goods of s. 17(2); the treatment of a service from outside Nepal for a
partly exempt business; and which fiscal-year start a company should use.
