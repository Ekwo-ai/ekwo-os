# Botswana

Everything Botswana adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 14 %, the zero rate and exemptions of the Value Added Tax
Act, 2026, the VAT return built on the net VAT formula of section 55, the
statement of financial position and the statement of profit or loss of an
IFRS-based presentation, and the reverse charge on remote services. The format
is [`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Botswana accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Botswana VAT return has reviewed it.
The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**English only.** English is the language of the Act and of the documents of the
Botswana Unified Revenue Service ("BURS"). The currency is the pula (BWP, two
decimals).

## A new Act, in force since 1 July 2026

The Value Added Tax Act, 2026 (Act No. 15 of 2026) repealed and re-enacted the
former Value Added Tax Act (Cap. 50:03) with effect from 1 July 2026. Several
pages of the BURS site still describe the old regime (12 %, a P500 000
threshold); the Act, its schedules and the notices listed below are the
authority this pack follows. Every tax code starts on 1 July 2026: the pack does
not cover supplies made under the repealed Act, whose zero-rating list differed.

| What | Text |
|---|---|
| Rate (14 %), zero rate, exemption, registration, tax periods, input tax, return | Value Added Tax Act, 2026, ss. 7 to 9, 12, 31, 32, 54, 55, 65, 66, Schedules 1 to 5 |
| Regulations, remote services, government entities | S.I. 94, 73 and 74 of 2026 |
| Zero-rated foodstuffs | BURS public notice of 9 July 2026 |
| Medical services | BURS public notice of 30 July 2026 |
| Reverse charge reporting | BURS guidance note, September 2026 |
| Electronic billing | Tax Administration Act, 2026, ss. 15 and 100 |
| Where the return is filed | BURS e-Services (`eservices.burs.org.bw`) |
| The accounting framework | IFRS Foundation jurisdiction profile of Botswana |

## Taxes

| Code | Treatment | Source |
|---|---|---|
| `BW-S-14` | Sale at 14 % | s. 7(2)(b) |
| `BW-S-Z-EXP` | Zero-rated export of goods or services, international transport | Schedule 1, Parts I and II |
| `BW-S-Z-DOM` | Zero-rated domestic supplies: basic foodstuffs, LPG, fuel, prescription medicines, fertilisers, farm implements | Schedule 1, Part III |
| `BW-S-EX` | Exempt: financial services, residential lease over 45 days, education, public transport, public medical facilities | Schedule 2 |
| `BW-P-14`, `BW-P-14-ND` | Purchase at 14 %, deductible or denied (passenger vehicles, entertainment, club fees) | ss. 31, 32 |
| `BW-P-Z`, `BW-P-EX` | Zero-rated and exempt purchases | Schedules 1, 2 |
| `BW-P-IMP` | Import of goods, VAT paid at the border | s. 7(7), s. 66(3) |
| `BW-P-RC-SVC` | Remote service received, reverse charged and recovered | s. 7(1)(c), s. 55(1) |

## The return

A registered person files for each tax period within **28 days** of its end, and
pays by the same date (s. 65(1), s. 66(1)): the 28th of the following month.
Periods are one month (Category C: taxable supplies above P12 million, or by
authorisation or notice) or two months (Category A or B, allocated by BURS). The
boxes follow the formula (A + B) − C of s. 55(1): output tax plus reverse
charged VAT, less input tax credits.

## What this pack does not say yet, and why

- **The return form's own box numbers.** The approved form (VAT 002.1) cannot be
  downloaded and its e-Services version needs a login, so the boxes are this
  pack's own, named after the components of the s. 55(1) formula.
- **Category A periods.** They end in January, March, May…; Ekwo's `bimonth` is
  anchored on January (January–February) and fits Category B only. No default
  cadence is declared because it depends on the taxpayer.
- **Medical services.** Private medical services are taxable under the Act, but
  BURS suspended the charging of VAT on them on 30 July 2026 pending
  consultation. The pack has no code for them; ask the accountant how to book
  them until BURS decides. Only public medical facilities are exempt.
- **Electronic billing.** The Tax Administration Act, 2026, s. 15, obliges every
  taxpayer to issue invoices through a BURS-approved electronic billing system,
  with a P10 000 penalty a month for failure (s. 100). The start date is set by
  the Tax Administration Regulations, 2026, which this pack could not open;
  secondary commentary says about 1 April 2027. It is a reporting system to the
  administration, not an exchange network, so `einvoicing.obligation` is `none`
  and no profile is declared. Ekwo cannot send to it.
- **Partial deduction.** The 50 % denial on the repair of a passenger vehicle
  (s. 32(1)(b)), apportionment for mixed taxable and exempt use (s. 31), and
  the partial recovery of reverse charged VAT have no split code.
- **Time of supply.** The Act's rules are not in Ekwo's vocabulary; `tax_point`
  is the nearest value.
- **Southern African Customs Union.** Imports from Namibia, Lesotho, South
  Africa and Eswatini are taxed on entry like any other import; the pack
  documents this and models no special treatment.
- **Registration, non-resident suppliers, government entities.** Thresholds
  (P1 million; P500 000 for remote service suppliers), registration and the
  limited registration of government entities are documented, not enforced.
- **Penalties and interest** (1 % a month, Schedule 5) are not modelled.
- **Accounting framework.** Botswana has no legal chart of accounts. IFRS is
  the basis for public and non-exempt private companies; IFRS for SMEs is
  permitted for smaller entities, and the sources disagree on its exact status.

## Points a Botswana accountant should read first

1. The zero-rated foodstuffs list and the customs-heading conditions of Schedule 1.
2. The treatment of private medical services during the suspension.
3. The category (A, B, C) assigned to the company and the cadence chosen.
4. Reverse charge: the recipient-created tax invoice and the first reporting period.
5. Whether the chart's levy and contribution accounts match the company's payroll.
