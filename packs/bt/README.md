# Bhutan

Everything Bhutan adds to Ekwo, as data: a chart of accounts, the journals,
the Goods and Services Tax at 5 %, the zero rate and the exemptions of the
Schedules of the Act, the monthly GST return as the Act describes it, the
statement of financial position and the statement of profit or loss of an
IFRS-based presentation, and what the Act does with a service bought from
abroad. The format is [`docs/packs.md`](../../docs/packs.md); this file says
where the content came from and which decisions it rests on, so that a Bhutanese
accountant reading the pack can disagree with a specific sentence rather than
with the whole of it.

**Status: `community`.** Nobody who files a Bhutanese GST return has reviewed
it. The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**English only.** English is the language of the Goods and Services Tax Act and
of the Department's notices. Dzongkha (`dz`) is the national language, but no
translation of the chart and the return could be checked by a reader of it, so
none is shipped and the pack declares `en` alone. The currency is the ngultrum
(BTN, two decimals), pegged one to one to the Indian rupee.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and beside
it the key of the text that article is in. The register in `pack.json` holds
five texts, all opened while writing the pack:

| What | Text | Where |
|---|---|---|
| The charge to tax, liability, imports and imported services, exemptions, zero rating, input tax, the return, registration, the Schedules | Goods and Services Tax Act of Bhutan 2020, consolidated with the amendments of 2021, 2022 and 2025 | `drc.gov.bt` |
| The rate: 5 % from 1 January 2026 | GST Amendment Law 2025, as reported | `kpmg.com` |
| The income year and the online filing | Notification of 29 December 2025 on tax filing for income year 2025 | `drc.gov.bt` |
| Where returns are filed | RAMIS | `drc.gov.bt` |
| The accounting framework | IFRS jurisdiction profile of Bhutan | `ifrs.org` |

**The Act is in force from 1 January 2026.** Section 2 of the consolidated Act
sets the commencement on that date and says it does not apply retroactively.
Before it, Bhutan taxed goods and some services under a sales tax, and the GST
had been deferred more than once (2021, 2022). The pack carries none of that:
every code starts on 1 January 2026, and a company with books before that date
needs its accountant for the sales tax.

**The consolidation is not the authoritative text.** The Department publishes
it, and says that the original Act and the formal amendments prevail where they
differ. The pack follows the consolidation and cites the 5 % rate of Schedule I
as it reads there; the KPMG note is the second source for that figure.

## The chart of accounts, and why this one

There is no legal chart of accounts in Bhutan. This one is original: four
digits, blocked so that each range reaches one line of the statements, 146
accounts. Beyond a general IFRS-style chart it carries what a Bhutanese company
owes: GST output and input, the net GST settlement account (1155 and 2110),
import GST at customs clearance, personal income tax and tax withheld at source,
pension and provident fund contributions, and one cost account for GST the law
does not let a buyer recover (6530).

Only trade receivables, trade payables and the two GST settlement accounts are
reconcilable. The bank, cash and suspense accounts are not.

## Taxes

| Code | Rate | What |
|---|---|---|
| `BT-S-5` | 5 % | Standard-rated sale |
| `BT-S-Z-EXP` | 0 % | Goods exported, services to a customer outside Bhutan, international transport (Schedule V) |
| `BT-S-EX` | exempt | Residential lease, sale of residential premises, financial services, education, health, rice, edible oil, salt, sanitary products (Schedule IV) |
| `BT-P-5` | 5 % | Deductible purchase |
| `BT-P-5-ND` | 5 % | Purchase whose input tax is blocked (entertainment, club memberships, passenger vehicles); the tax goes to account 6530 |
| `BT-P-EX` | 0 % | Exempt purchase |
| `BT-P-IMP` | 5 % | Import of goods, tax paid at customs clearance and claimed |
| `BT-P-RC-SVC` | 5 % | Imported business-to-business service, tax self-charged and claimed |

Three choices carry the weight:

- **Zero-rated is not exempt.** A zero-rated supplier keeps its input tax (s.
  29); an exempt supplier does not (s. 27). A company with both must apportion
  (ss. 36-37), which the pack does not do.
- **There is no domestic zero rate.** Schedule V zero-rates only what is
  consumed outside Bhutan; the staples (rice, edible oil, salt) are exempt in
  Schedule IV, C, so there is no code for a local zero-rated sale.
- **An imported B2B service is deductible.** Section 14(3) makes the purchaser
  liable and section 33 treats it as incurring both output and input tax, with
  the credit allowed provided the output tax is accounted for. `BT-P-RC-SVC`
  posts both, in boxes 1R and 2R. A partly exempt buyer's apportionment is not
  modelled.

## The return

Monthly: the tax period is a calendar month unless the rules prescribe another
(definition of 'tax period'). The pack carries rows grouped under the figures
section 44 names — output tax, input tax credits, the net amount — in
`tax_report.json`. The form on RAMIS was not opened, so these rows are the
pack's own and the box codes (`1S`, `2`, `3`…) are internal labels, not form
numbers.

**Deadline.** Section 38 gives thirty days after the end of the period. The
schema offers a day of the month, not a count of days, so the pack carries day
30: exact for every month but January, where thirty days end on 2 March. A
company should confirm the day on RAMIS. Section 46 has the positive net amount
paid when the return is filed.

**Registration.** Schedule II sets the turnover threshold at Nu 5 000 000 a
year, and s. 57 asks for registration within thirty days when the previous
twelve months reach it, or half of it over six months. The pack checks no
threshold.

## Income year

The income year is the calendar year: the Department's notification of
29 December 2025 opens income tax returns for income year 2025 on 1 January 2026,
to 31 March 2026 for business and corporate income tax. The pack therefore
declares `calendar`. Income tax itself (corporate rate, business income tax,
personal income tax) is not modelled.

## Electronic invoicing

No Bhutanese statute obliges a business to exchange a structured electronic
invoice. `einvoicing.profile` is null and `obligation` is `none`. The Department
announced a GST regime for 2026 and its notices may add an invoicing rule; none
was readable.

## What this pack does not say yet, and why

- **The GST return form on RAMIS.** Not opened; the rows are the pack's own.
- **The filing day** (30 days against a fixed day; above).
- **The tax invoice particulars** (s. 209 sends them to the rules and
  regulations, not opened) and the **numbering** rule: the pack declares a
  sequential number, not a gapless one.
- **The time of supply.** Section 81 is the earlier of invoice and payment; the
  closed vocabulary has no such value, so `invoice_date` stands for it and an
  advance payment before the invoice needs a manual look.
- **Partial exemption** (ss. 36-37), adjustments (Chapter 14), bad-debt relief,
  special schemes and the rules on non-resident suppliers of electronic
  services to consumers (s. 14(4)).
- **The sales tax before 2026** and the transition rules (Schedule X).
- **Other taxes**: excise duty, customs duty, income tax, personal income tax
  withholding and the pension fund have accounts but no tax code.
- **The exemption reason code (BT-121)**: Bhutan is outside the common system
  of VAT, so no VATEX code is carried.
- **A Dzongkha translation.**

## Reviewing this pack

A Bhutanese accountant is asked to confirm: the 5 % rate and its date against
the authoritative Act and the amendment; the filing day (30 days or a fixed
day); the layout of the GST return on RAMIS against the rows here; the
exempt list of Schedule IV, C against the current Bhutan Trade Classification;
the treatment of imported services for a partly exempt business; and which
statement tier (BAS or BAS for SMEs) the company reports under.
