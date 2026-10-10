# Sri Lanka

Everything Sri Lanka adds to Ekwo, as data: a chart of accounts inspired by the
SLFRS, the journals, value added tax at 18 % with the 20.5 % rate of financial
services from 1 July 2026, zero rate on exports, exemption, the VAT return
filed through RAMIS e-Services (cages A, 0, B, 2, D, D1, I, 6, 5, 16 and 15),
and the statement of financial position and the statement of profit or loss of
the SLFRS for SMEs. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on, so that a
Sri Lankan accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Status: `community`.** Nobody who files a Sri Lankan VAT return has reviewed
it. The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**English only.** English is the language of the texts the Inland Revenue
Department (IRD) publishes for taxpayers. Sinhala (`si`) and Tamil (`ta`) are
official languages and the Sinhala text of the VAT Act prevails over the Tamil
one (s. 84), but no translation is shipped: a label in either language
deserves a native reader, and a partial file would only suggest otherwise. They
can be added under `i18n/` without touching the rest of the pack.

What the core could not say is written up in
[`docs/international.md`](../../docs/international.md) under "From Sri Lanka".
None of it was patched for this pack's sake.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and beside
it the key of the text that article is in. The register in `pack.json` holds
sixteen texts, every one opened on 9 October 2026. The ones the rest of this file
leans on:

| What | Text | Where |
|---|---|---|
| Rates by period, payment on the 20th, return at the end of the following month, monthly or quarterly period, thresholds | IRD, *Value Added Tax (VAT)* | `ird.gov.lk` |
| Charge, rates, time of supply, value of a supply, zero rating, exemption, invoice, return, payment | Value Added Tax Act, No. 14 of 2002, as amended to 2024 | `lankalaw.net` (see below) |
| Financial services at 20.5 %, services of non-residents, secured POS machines, thresholds kept | IRD notice SEC/PN/VAT/2026-03 of 3 July 2026 (Amendment Act No. 14 of 2026) | `ird.gov.lk` |
| The cages of the return and the schedules that feed them | IRD quick guide *How to file VAT* v3 and Circular 2011/07 | `ird.gov.lk` |
| The Tax Invoice specification and its postponement to 1 October 2026 | Gazettes 2481/22 and 2500/106 | `ird.gov.lk` |
| National e-Invoicing System | IRD notice SEC/PN/VAT/2026-03 of 4 May 2026 | `ird.gov.lk` |
| The Social Security Contribution Levy | SSCL Act No. 25 of 2022 consolidated to 9 April 2026; notice PN/SSCL/2026-04/1 | `ird.gov.lk` |
| Where the return is filed | RAMIS e-Services | `eservices.ird.gov.lk` |
| Accounting records and financial statements | Companies Act No. 7 of 2007, ss. 148–151; CA Sri Lanka; IFRS Foundation profile | `parliament.lk`, `slaasc.lk`, `ifrs.org` |

The IRD publishes no consolidation of the VAT Act after the one that stops in
2014. The sections cited here (2, 4, 5, 7, 8, 20, 21, 26, 83) were read in an
unofficial consolidation to 2024 and the rates were checked against the IRD page
on VAT; the amendments of 2025 and 2026 were read in the IRD's own notices. A
reviewer should check section numbers against the Gazette versions.

## Taxes

| Code | Rate | Cages | From / to |
|---|---|---|---|
| `LK-S-18` | 18 % | A, 0 | from 1 Jan 2024 |
| `LK-S-15` | 15 % | A, 0 | 1 Sep 2022 – 31 Dec 2023 (closed, for old books) |
| `LK-S-FIN-205` | 20.5 % | B, 2 | from 1 Jul 2026 |
| `LK-S-FIN-18` | 18 % | A, 0 | until 30 Jun 2026 (closed) |
| `LK-S-ZR-EXP` | 0 % | D | exports of goods (s. 7(1)(a)) |
| `LK-S-ZR-SVC` | 0 % | D1 | exports of services (s. 7(1)(b), (c)) |
| `LK-S-EX` | exempt | none | First Schedule, Part III |
| `LK-P-18`, `LK-P-15`, `LK-P-FIN-205` | 18 / 15 / 20.5 % | I, 6 | input tax |
| `LK-P-IMP` | 18 % | 5 | VAT paid at customs, owed to Sri Lanka Customs on 2125 |
| `LK-P-ZR`, `LK-P-EX` | 0 % | none | zero-rated and exempt purchases |

No code carries a VATEX or UNCL5305 category: Sri Lanka is outside the common
system and publishes no such list, so `vat_category` is empty and the article is
in each `legal_reference`.

**Financial services.** Since taxable periods commencing on 1 July 2026 they bear
20.5 % and, by Item 25 of Part II of the First Schedule to the SSCL Act, no
SSCL. The VAT on financial services is computed on the value addition
attributable to them by the attributable method of Chapter IIIA, not on invoice
lines; the codes serve the fees a financial institution bills, and the
period-end computation stays outside the pack.

**Simplified VAT (SVAT).** Abolished with effect from 1 October 2025 by the Value
Added Tax (Amendment) Act No. 4 of 2025 and replaced by a Risk-Based Refund
Scheme (notice PN/VAT/2025-01). It is not modelled: no suspended supply, no SVAT
credit voucher, no cage for them. A book that spans the abolition and used the
scheme needs the old forms.

**Services of non-residents.** From 1 July 2026 VAT applies to services supplied
by non-residents through electronic platforms, with a registration threshold of
LKR 15 million a quarter or 60 million over twelve months, and no VAT on them
when the recipient is VAT-registered (new s. 25N). The supplier registers and
charges; the buyer has no reverse charge, so no purchase code exists for it.
The same is true of any other service bought from abroad: the Act charges
supplies made in Sri Lanka by a registered person and imports of goods
(s. 2(1)), and no section makes the Sri Lankan buyer account for the tax on a
service a non-resident supplies from abroad. `pack.json` says so in
`not_taxed`; such a purchase is booked with no tax code.

## The Social Security Contribution Levy (SSCL)

The SSCL (Act No. 25 of 2022) is **a levy on the seller's own liable turnover,
2.5 %, with its own quarterly return and no line on the invoice.** Three
readings of the text settle how it is modelled:

1. *Charge.* Section 3(1) charges the levy on the *liable turnover* of the
   taxable person for each quarter, at 2.5 %. Turnover is the sum receivable —
   not the amount collected — from the sales, the services or the real estate
   of the quarter, with VAT excluded by s. 3(3)(b). The Second Schedule takes
   85 % of the turnover of a manufacturer, 100 % of that of services and real
   estate, 25 % or 50 % of that of wholesale and retail sales (25 % for a
   registered distributor), and the value addition attributable to financial
   services, which the 20.5 % VAT now exempts from the levy. The levy is a cost of the seller; the invoice
   does not carry it.
2. *VAT base.* Section 5(1)(a) of the VAT Act fixes the value of a supply as
   the consideration *less any tax chargeable under this Act*. The SSCL is not
   chargeable under the VAT Act, so what a seller prices in to recover it is
   still inside the consideration and the VAT is charged on it. The invoice
   therefore shows one price, one VAT at 18 %, and nothing for the levy: there
   is no stacked posting to model, unlike the National Health Insurance Levy
   and the GETFund Levy in `packs/gh`, which are charged beside the VAT on the
   same value and are lines of the invoice and of the return.
3. *Return and payment.* Section 8 asks for a quarterly return on or before the
   20th day of the month after the quarter; s. 17 requires the levy of the first
   and second months to be paid on the 20th of the second and third month and
   that of the third month on the 20th after the quarter. It is accounted on an
   accrual basis (s. 16).

**What the pack does.** It does not create an invoice tax code for the levy:
adding a code would put the levy on the customer's invoice, which is not what the
law says. It gives the chart the two accounts the levy needs — `2130` *SSCL
payable* and `6700` *SSCL expense* — and leaves the quarterly accrual to a
journal entry the company posts. The return itself is a second declaration
(own form, own cadence, own deadline), and the core carries one declaration per
pack: written up in `docs/international.md`.

**Threshold.** The registration threshold of the SSCL is the one point on which
the sources disagree today, and the pack does not carry it. The consolidated Act
(IRD, 26 May 2026) holds the Amendment Act No. 10 of 2026, certified on 9 April
2026, which lowers it from LKR 15 million a quarter / 60 million over four
quarters to **LKR 9 million / 36 million for periods commencing on or after
1 July 2026** (s. 4(1)(d) and 5(1)(d); notice PN/SSCL/2026-04/1 of 16 April
2026). On 23 June 2026 the Government told Parliament it would not proceed with
the lowering of the VAT and SSCL thresholds "at this stage" (reported by the
press the same week, for instance
<https://adaderana.lk/news/cmqqjlpxp0001356q0fhkrp9y>); the IRD notice that followed, SEC/PN/VAT/2026-03 of
3 July 2026, confirms the VAT thresholds stay at 15 / 60 million and says
nothing of the SSCL ones. No gazette or amending Act on the SSCL threshold was
found after the announcement, so the statute still reads 9 / 36 million.
**This pack retains: the statute as written (9 / 36 million from 1 July 2026)
is the law until a text says otherwise, the announcement is a stated intention
that has not reached the Act, and a company between 9 and 15 million a quarter
should ask the IRD before relying on the old figure.** A local accountant should
confirm it.

## The return

The VAT return is filed on RAMIS e-Services (mandatory since 1 July 2025). The
quick guide ties cages A and 0, and B and 2, to Schedule 01 (output), D to
Schedule 06 (exports of goods), D1 to Schedule 07 (zero-rated services), I and 6
to Schedule 02 (local purchases), 4 and 5 to Schedule 03 (imports). The pack
carries those cages and these decisions:

- **A / 0 and B / 2.** The guide does not say what separates the two pairs. The
  pack puts the standard rate, and the 18 % of financial services before July
  2026, in A and 0, and the 20.5 % of financial services in B and 2. It is an
  assumption, and the one that matters most to a reviewer.
- **Totals.** `16` (net VAT payable, output less input, floored at zero) and
  `15` (excess input, carried forward or claimed under the Risk-Based Refund
  Scheme) come from Circular 2011/07, which describes an older layout of the
  form; the cage numbers are kept in the current e-form but could not be checked
  there. `OUT` and `IN` are hidden intermediate totals.
- **Not carried.** Cage 4 (VAT deferred on imports), cage 8 (disallowed input),
  the wholesale and retail deemed input of J4 / R3 (Schedule 05, not applicable
  from 1 June 2021) and the exempt-supply cage, which the quick guide does not
  name.
- **Dates.** The return is due on or before the **last day of the month after
  the taxable period** (s. 21(1)(b); IRD page on VAT); the tax is due earlier,
  on or before the **20th of the month following the period** (s. 26(1)), and a
  quarterly filer pays the first two months of the quarter on the 20th of the
  following two months. The core holds one deadline per return, so only the
  filing date is encoded; the payment date is here and in `docs/international.md`.
  The taxable period is a month for the persons the Act names and a quarter for
  everybody else, who may ask for monthly returns; no default is declared and
  `ekwo init` asks.

## E-invoicing and the Tax Invoice

- **No obligation is declared.** The National e-Invoicing System (Budget 2026)
  sends invoice data from the ERP to RAMIS through a Web API. On 4 May 2026 it is
  a pilot; phase 1 reaches export-oriented enterprises, phase 2 every
  VAT-registered person, and the full integration is expected by the end of 2026.
  The Amendment Act No. 14 of 2026 adds secured point-of-sale machines within
  three months of a date to be prescribed. Neither binds every taxpayer today,
  and Ekwo connects to neither: this is data transmission, not clearance, and
  not a Peppol exchange.
- **The Tax Invoice** specification of Gazette 2481/22 is in force since
  **1 October 2026** (it was due on 1 July; Gazette 2500/106 moved it): title
  "TAX INVOICE", nine-digit TIN of supplier and purchaser, serial number
  `YYMMM_QQQQ_XXXXX` of at most forty characters, dates as `MM/DD/YYYY`, value,
  VAT and total, only supplies subject to VAT. The mention `tax_invoice_title`
  carries the title. The pack's `number_format` writes the month as two digits
  because the numbering vocabulary has no three-letter month, so the format of
  the Gazette is not reproduced.

## Chart, calendar and statements

The chart has 155 accounts in four digits; no legal chart exists. Customers,
suppliers and the two VAT settlement accounts (`2110` payable, `1155`
refundable) are the only reconcilable accounts. The financial year defaults to
`april` because the year of assessment runs from 1 April to 31 March (Inland
Revenue Act No. 24 of 2017, s. 20(1)); a company may ask for another year-end
and many keep 31 December. Statements are the minimum lines of the IFRS for
SMEs, which the SLFRS for SMEs adopts; a full-SLFRS company expands them.

## What the golden does not exercise

The golden replays a month of a first financial period beginning on 1 July 2026,
because the generic test reads the rates in force at the first day of the year
and two positive rates are asked for: a year beginning on 1 April 2026 would see
18 % alone. The closed codes `LK-S-15` and `LK-S-FIN-18` therefore have no
document in it, and so have the year-end settlement of the SSCL accounts and the
non-resident services.

## For a local accountant to read

The assignment of cages A / B, the cage numbers 15 and 16, the SSCL threshold,
the VAT value of financial services, the time-of-supply rule (the vocabulary
cannot say "earliest of invoice, payment, due date and delivery"), and every
section number cited from an unofficial consolidation.
