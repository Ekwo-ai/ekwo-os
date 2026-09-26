# Ghana

Everything Ghana adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 15 % with the National Health Insurance Levy (NHIL) and the
Ghana Education Trust Fund Levy (GETFund Levy) at 2.5 % each on the same
value, zero rate, relief and exemption, the monthly standard VAT return
(form DT 0135), and the statement of financial position and the statement of
profit or loss of the IFRS for SMEs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Ghanaian accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Ghanaian VAT return has reviewed
it. The figures are replayed against a month of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**Law of 1 January 2026 only.** The pack carries the Value Added Tax Act, 2025
(Act 1151), which came into force on 1 January 2026 and repealed the Value
Added Tax Act, 2013 (Act 870) and its twelve amending Acts (s. 73). Every tax
is `valid_from` 2026-01-01. Books of 2025 and before — VAT at 15 % computed
on a value that already included the NHIL, the GETFund Levy and the 1 %
COVID-19 Health Recovery Levy, the levies not deductible, the 3 % VAT Flat
Rate Scheme — are not what this pack posts; see "The reform of 2026" below.

**English only.** English is the official language of Ghana and every text
cited here is in English.

What the core could not say is written up in
[`docs/international.md`](../../docs/international.md) under "From Ghana".
None of it was patched for this pack's sake.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and
beside it the key of the text that article is in. The register in `pack.json`
holds twelve texts, every one opened on 26 September 2026. The ones the rest
of this file leans on:

| What | Text | Where |
|---|---|---|
| Charge, rate, exemption, zero rate, relief, time of supply, invoice, value, input tax, returns | Value Added Tax Act, 2025 (Act 1151), ss. 1–3, 35–39, 43, 44, 49, 50, 59, 60, 72, 73, 75 and the First to Third Schedules | `gra.gov.gh` (scanned PDF of the gazetted Act) |
| The levies on the same value, the 20 % and the fractions, the abolition of the flat rate, the COVID-19 field to ignore, VAT withholding | GRA Administrative Guideline GRA/AG/25/002 of 31 December 2025 | `gra.gov.gh` |
| The reform in one page: threshold, COVID-19 levy abolished, levies recoupled and deductible, flat rate abolished | GRA, *Notice to all VAT registered taxpayers* | `gra.gov.gh` |
| The boxes of the return | Form DT 0135 ver 1.5, *Monthly Standard VAT Return*, and its completion notes | `gra.gov.gh` |
| Where the return is filed; the Certified Invoicing System | GRA Taxpayers' Portal; GRA, *E-VAT* | `taxpayersportal.com`, `gra.gov.gh` |
| Accounting records and financial statements under IFRS | Companies Act, 2019 (Act 992), s. 127 and the Sixth Schedule | `gipc.gov.gh` |
| IFRS and IFRS for SMEs adopted by the Institute | ICAG publication; IFRS Foundation jurisdiction profile | `icagh.org`, `ifrs.org` |

Act 1151 and the Guideline are published by GRA as scanned images, with no
text layer: every section cited was read page by page from the image.

## The reform of 2026, and what this pack does with it

Until 31 December 2025 a Ghanaian standard-rate supply bore four charges in
cascade: the NHIL (2.5 %), the GETFund Levy (2.5 %) and the COVID-19 Health
Recovery Levy (1 %) on the value, then VAT at 15 % on the value *including*
those levies — 21.9 % in all, the three levies a cost the buyer could not
deduct. The 2026 budget announced the end of that arrangement, and the Value
Added Tax Act, 2025 enacted it from 1 January 2026:

- **The COVID-19 Health Recovery Levy is abolished.** GRA's notice says so in
  as many words, and the Guideline (§ 15.6) tells taxpayers to ignore the
  COVID-19 field of the invoice and of the return still in use, "since the
  Covid-19 levy Act has been repealed". It is not in this pack as a tax; line
  iv of the form is carried empty.
- **The NHIL and the GETFund Levy are recoupled.** They stay at 2.5 % each,
  are charged on the same value as the VAT and not in its base (Guideline,
  § 6.0 and § 15.3; Act 1151, s. 44(1)(a) takes all three out of the value),
  and are deducted as input tax. The total is 20 %, and the Guideline's
  appendix gives the fractions a tax-inclusive price is read with: 1/6 for
  the whole, 1/8 for the VAT, 1/48 for each levy.
- **The VAT Flat Rate Scheme is abolished** (notice; Guideline § 15.2): the
  3 % scheme for retailers and the 5 % scheme for real estate developers
  both, the flat-rate taxpayers above GH₵750,000 converted to the standard
  rate. There is no flat-rate code in this pack and no flat-rate input on
  its return.
- **The registration threshold for goods is GH₵750,000** (s. 6(1)(b)); a
  supplier of services registers whatever its turnover (s. 6(1)(a)). The
  threshold is a fact about the company and not a tax, so the pack says it
  here and nowhere else.

## How three charges become one code

The stacked levies are modelled the way `packs/ca/` models Québec and
`packs/in/` models the CGST and the SGST: **one tax code at the total rate,
several `tax` postings with a `factor` each.** `GH-S-20` is a single 20 %
code whose postings put 75 % of the tax (15/20) on account 2100 and in box 3,
12.5 % (2.5/20) on account 2101 and on line ii, and 12.5 % on account 2102
and on line iii. `GH-P-20` and `GH-P-IMP` do the same on the input side,
into three input accounts (1150, 1151, 1152) and one box each, 14 or 17. The
factors are exact — 75, 12.5 and 12.5 — so a value in whole cedis splits
without a remainder.

A value that does not is the one place the model and the Guideline part:
on 333.33, the engine rounds the 20 % once (66.67) and gives the last
posting the remainder, so the GETFund account receives 8.34, while GRA reads
each charge on the value (VAT 50.00, NHIL 8.33, GETFund 8.33 — 66.66) and
box iii, computed at 12.5 % of the rounded tax, says 8.33. The golden
scenario carries that invoice on purpose (INV-002). The difference is one
cent per awkward invoice, on the GETFund account and not on the return; see
`docs/international.md`.

## What is in it

| File | Holds |
|---|---|
| `pack.json` | the register of sources, the roles, the journals, the chart, the numbering and time-of-supply rules, the e-invoicing statement |
| `accounts.csv` | 154 accounts in four digits |
| `taxes.json` | 11 codes: 6 on sales, 5 on purchases |
| `tax_report.json` | form DT 0135, lines i to iv and boxes 1 to 25 |
| `statements.json` | statement of financial position, statement of profit or loss |
| `golden/` | a month of books of an Accra trading company, 14 documents and 4 payments |

The taxes:

| Code | Rate | What | Boxes |
|---|---|---|---|
| `GH-S-20` | 20 % | standard-rate sale — VAT 15, NHIL 2.5, GETFund 2.5 | i, 3, ii, iii |
| `GH-S-ZR-EXP` | 0 % | export of goods, Second Schedule § 2(1) | 4 |
| `GH-S-ZR-DOM` | 0 % | domestic zero rate — sanitary towels, textiles to 2028, free zones | 4 |
| `GH-S-RELIEF` | 0 % | relief supply, Third Schedule — embassies, international agencies | 5 |
| `GH-S-EX` | 0 % | exempt supply, First Schedule | 7 |
| `GH-S-NS-SVC` | 0 % | service supplied outside Ghana, s. 42 | — |
| `GH-P-20` | 20 % | standard-rate local purchase, all three charges deductible | 12, 14 |
| `GH-P-20-BL` | 20 % | motor vehicle, input tax disallowed by s. 50 | — |
| `GH-P-ZR` | 0 % | zero-rated purchase | — |
| `GH-P-EX` | 0 % | exempt purchase | — |
| `GH-P-IMP` | 20 % | import of goods, VAT and levies paid at customs | 15, 17 |

## The return

Act 1151 fixes the tax period at one calendar month for everybody (s. 72), and
the return and the payment are due by the **last working day of the
following month** (s. 59(5), s. 60(1)). The form GRA still publishes is DT
0135 ver 1.5, *VAT, NHIL, GETFund and COVID-19 standard rate return*; it is
filed on the Taxpayers' Portal. No form redrawn for Act 1151 is published on
the GRA forms page as of 26 September 2026, so the pack carries DT 0135 with
the adaptations the reform requires, each said on its box:

- line iv (COVID-19 levy) carried and never posted to;
- box 1 kept as the form prints it (i + ii + iii + iv), no longer the base of
  box 3;
- boxes 9 to 11 (inputs from flat-rate suppliers) left out, the scheme being
  abolished;
- box 14 and box 17 holding the VAT *and* the two levies, which are now
  deductible;
- boxes 18 to 20 (withholding VAT credits) and 26 (credit brought forward)
  left out: they come from certificates and from last month, not from a
  posting;
- boxes 24 and 25 computed on the output VAT and levies together (a hidden
  total, `OUT`), not on box 3 alone.

The deadline rule is `last_day_of_month_after_period`: the calendar day, not
the working day. A month ending on a weekend or a public holiday brings the
Ghanaian date forward, which Ekwo does not see.

## What this pack does not do

- **E-VAT, the Certified Invoicing System.** Act 1151, s. 43(2), requires a
  taxable person to issue every tax invoice through a Certified Invoicing
  System integrated with the Commissioner-General's; GRA's E-VAT signs it with
  the Commissioner-General's signature, a QR code and a time stamp. This is a
  clearance with the tax administration, not an exchange between two
  businesses, and Ekwo does not connect to it: an invoice drafted in Ekwo is
  still to be issued through E-VAT or a certified system. `einvoicing` says
  `obligation: none` for that reason, and the gap is in
  `docs/international.md`.
- **VAT withholding.** An appointed withholding agent withholds 7 % of the
  taxable value at payment (s. 56; Guideline § 12.1) and remits it by the
  15th of the following month on a return of its own; the supplier claims
  the certificate as a credit in box 20. Neither side is a tax on a
  document: accounts 1156 (credits received) and 2130 (VAT withheld as an
  agent) are there to book it by hand.
- **Import of services.** Since 2026 an imported service is taxed only to
  the extent it is used other than to make taxable supplies (s. 72,
  "import of services"), is declared on a separate service import
  declaration and paid within twenty-one days (s. 61). A fully taxable
  business owes nothing on it; a business with exempt supplies apportions
  (Guideline § 10.3). No code carries it.
- **Apportionment** of input tax for a business with both taxable and exempt
  supplies (s. 52 and the Fifth Schedule): box 23 is box 22.
- **The Communications Service Tax and excise duty** charged into the value
  before the VAT (Guideline § 15.3): they belong to their own Acts; account
  2135 holds the CST where a company collects it.
- **The upfront payment** of 20 % by an unregistered importer (s. 17) and the
  tourism levy of the Tourism Act, 2011 (s. 44(1)(a)(iv)): outside a
  registered company's documents; accounts 1157 and 2165 are there.
- **The reconnaissance and prospecting relief** (Third Schedule § 9) is
  given by refund (Guideline § 15.8): the sale is at `GH-S-20`.

## The chart of accounts, and why this one

**Ghana prescribes no chart of accounts.** The Companies Act, 2019 (Act 992),
s. 127, asks for proper accounting records and for financial statements
prepared in compliance with the IFRS adopted by the Institute of Chartered
Accountants, Ghana — which adopted the IFRS in 2007 and the IFRS for SMEs in
2010. The chart is written, not transcribed, in the shape of the other
anglophone African packs: four digits, 1 assets, 2 liabilities, 3 equity, 4
income, 5 cost of sales, 6 to 8 expenses, each range reaching one line of
the statements. What makes it Ghanaian: separate output and input accounts
for the VAT, the NHIL and the GETFund Levy; one settlement account on each
side (2110 payable, 1155 refundable) that the return is cleared into and
that alone, with the customers and the suppliers, is reconcilable; import VAT
and levies owed to GRA Customs (2125); SSNIT first-tier and second-tier
pension contributions; PAYE.

## The statements

The Companies Act, s. 127(5), names five statements and prescribes no layout;
the Sixth Schedule asks for the IFRS classification. The pack carries the
two the format has room for — the statement of financial position and the
statement of profit or loss (expenses by nature) — with the minimum line
items of the IFRS for SMEs, sections 4 and 5. A full-IFRS company expands
them under IAS 1.

## To be read by a Ghanaian accountant

1. **The return.** Whether GRA's portal has redrawn DT 0135 for Act 1151 —
   and where it puts the levies, which the printed form folds into box 1 —
   and whether boxes 24 and 25 on the output VAT *and* the levies is how the
   portal computes the net.
2. **The rounding of the split** on a value that does not divide (INV-002),
   against what a certified invoicing system prints.
3. **The Schedules.** Which of the First Schedule exemptions a customer's
   business actually meets; this pack carries one exempt code for all of
   them.
4. **Export of services.** Whether a service supplied from Ghana and used
   abroad is outside the Tax (as this pack reads s. 42(4)) or zero-rated.
5. **The chart and the statements** against what a Ghanaian SME files.
