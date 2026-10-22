# Mauritanie (Mauritania)

Everything Mauritania adds to Ekwo, as data: the chart of accounts of the
national accounting plan, the journals, the value-added tax at 16 % with the
zero rate of exports and the exemptions of article 215, the monthly VAT return
as the Code describes it, the balance sheet and the results statement of the
plan, and the tax paid at customs on an import. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Mauritanian accountant reading
the pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Mauritanian VAT return has reviewed
it. The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**French only.** French and Arabic are the two languages the Code accepts for
accounts and declarations (art. L.15-4 and L.16-1). The chart of the national
plan is published in French and the pack follows it. No Arabic translation of
the chart and the return could be checked by a reader of Arabic, so none is
shipped and `languages` is empty. The currency is the ouguiya (MRU, two
decimals; the old MRO was divided by ten in 2018).

## Sources

Every tax, box and statement line carries its own `legal_reference`, and beside
it the key of the text that article is in. The register in `pack.json` holds
three texts:

| What | Text | Where |
|---|---|---|
| The charge, the threshold, the exemptions, the rate, the deduction, the credit, the monthly return, the invoice | Code général des impôts, January 2023 edition (law no. 2019-018 of 29 April 2019, updated to the 2022 finance law) | `finances.gov.mr` |
| The chart, the balance sheet, the results statement | Ordinance no. 82-180 of 24 December 1982 instituting the Plan comptable national, with the Plan comptable général annexed (Journal officiel, special issue 586, 2 March 1983) | `finances.gov.mr` |
| Where the administration publishes | Direction générale des Impôts | `impots.gov.mr` |

**The text read is not the current one.** The Code on the Ministry's site stops
at the finance law for 2022. The finance laws for 2023, 2024, 2025 and 2026 are
not read. A secondary guide published in 2026 mentions a 18 % rate for
telecommunications and a VAT on digital services supplied by non-residents;
neither could be found in an official text, so the pack states neither.

**The plan read is the first one.** The Journal officiel of March 1983 gives the
list of accounts and the models of statements. A law of 20 January 1999
(no. 99-009) revised the plan, and the Ministry's own order of 2022 on the
State's accounts cites it; its text could not be found, so the pack follows the
1982 list and any difference the 1999 revision made is a gap.

## The chart of accounts, and why this one

The national plan numbers its accounts: two digits for the principal accounts
(compulsory, classes 1 to 8), three or more for the subdivisions (indicative).
The pack keeps the numbers: 229 accounts, the principal two-digit accounts as
headers and a selection of subdivisions that is enough to keep the books of a
trading or services company and to draw the statements.

Additions of the pack, absent from the plan's list (the chart's
`legal_reference` says so): **4356**, the VAT credit to carry forward or to
claim back, so that the settlement account 4355 stays distinct from the accounts
where the tax is posted (4350 recoverable, 4357 collected); **4361**, the VAT
due at customs between the clearance and the payment; **5501** and **5502**, the
foreign-currency and foreign bank accounts; **6489**, rounding.

Only trade receivables (41), trade payables (40) and the two VAT settlement
accounts are reconcilable. The bank, cash and suspense accounts are not.

## Taxes

| Code | Rate | What |
|---|---|---|
| `MR-S-16` | 16 % | Sale at the standard rate (art. 230-1), posted to 4357 |
| `MR-S-Z-EXP` | 0 % | Export by a taxable person (art. 230-2) |
| `MR-S-EX` | exempt | Operation listed in art. 215 (the invoice says « Exonéré ») |
| `MR-P-16` | 16 % | Deductible purchase (arts. 231-232), posted to 4350 |
| `MR-P-16-ND` | 16 % | Purchase whose tax is not deductible (art. 233): the tax follows the cost to account 661 |
| `MR-P-EX` | 0 % | Exempt purchase |
| `MR-P-IMP` | 16 % | Import: tax paid at customs before the goods leave (art. 254) and deducted (art. 232) |

Choices that carry the weight:

- **The zero rate is not an exemption.** A zero-rated exporter deducts and can
  claim back its credit (arts. 231-2, 245-1-a, 246); an exempt operation takes
  the deduction away. A company with both must apportion (arts. 235-236), which
  the pack does not do.
- **The exempt code lists nothing.** Article 215 runs to some thirty items and a
  customs-nomenclature table; the pack has one code for the treatment and the
  golden uses three of its items (education, fresh vegetables). The accountant
  chooses the code line by line.
- **The non-deductible code is for the cases article 233 names**: receptions,
  cash payments above 200 000 MRU between professionals, an invoice without the
  supplier's tax identification number (NIF), tourism vehicles, furniture.
- **The threshold.** Only a taxpayer whose annual turnover reaches 3 000 000 MRU
  may charge the tax (art. 211-2); the pack checks nothing about it.

## The return

Monthly (art. 249-1): every taxable person files each month, with the payment,
a return in the prescribed form, and a « Néant » return for an empty month
(art. 250-1). The signed and stamped statement of deductions (art. 249-3) must
accompany it, or the deductions are reintegrated. The pack carries rows grouped
under the figures the Code names — tax due, tax deductible, balance — in
`tax_report.json`. The prescribed form was not found, so the box codes (`1S`,
`2`, `3`…) are internal labels, not form numbers.

**Deadline.** Day 15 of the month after the period (art. 250-1). The Code does
not say what happens when the 15th is not a working day.

**A credit** is imputed on the next returns (art. 244) and refunded only to
exporters and to a taxpayer who leaves the tax, on written request, for 100 000
MRU or more, with the last three returns in credit (arts. 245-246). The golden
month ends with a credit of 8 160 for that reason: an import of 40 000.

## Fiscal year

The calendar year. Article 50-3 has taxpayers close their accounts each year on
31 December, except on a sale or cessation of the business, and article 50-4 lets a
new business close its first balance sheet at the end of the following year; the
golden uses 1 January to 31 December 2026.

## Electronic invoicing

Article L.21 lists what the invoice says and article L.16-2 requires accounting
software approved by the administration; there is no structured electronic
invoice and no exchange network in the text read. `einvoicing.profile` is null
and `obligation` is `none`.

## What this pack does not say yet, and why

- **Everything the finance laws of 2023 to 2026 changed**, including any new rate.
- **The 1999 revision of the national plan** (above).
- **The return form** and the layout of the statement of deductions.
- **The time of supply of services.** Article 228-5 makes the tax on services
  chargeable when the price is collected, and article 228-7 on public contracts at
  each payment of the Treasury. The pack declares `delivery_date`, the principle for
  goods; a services sale is not held back until payment.
- **The rounding of the base** to the lower ten ouguiya (art. 226).
- **A service bought from a supplier abroad.** Services by non-residents under
  the withholding of article 132 are outside the tax (art. 214-1°); otherwise the
  foreign supplier's representative, or the client by a separate return, pays
  (art. 221). `pack.json` names it in `not_taxed`; the withholding is not modelled.
- **Partial deduction** (arts. 235-236), tax on the margin (art. 225), the option
  to pay on debits (art. 229), withholding by the State (art. 255), the
  convention regimes (art. 256).
- **Other taxes**: consumption tax, financial operations tax, income tax and
  social security have accounts but no tax code.
- **The statements as the plan gives them**: the gross, depreciation and net
  columns, the commitments, the financing table and the notes. The pack draws
  the balance sheet and the results statement by nature, in one column.
- **The reduced regimes** of the Code for small businesses.
- **An Arabic translation.**

## Reviewing this pack

A Mauritanian accountant is asked to confirm: the 16 % rate and anything the
finance laws since 2022 changed; the use of the 1982 plan against the 1999
revision; the filing day and the form; the exemptions the golden uses against
article 215; the treatment of a service bought from abroad; and whether services
are to be taxed on collection in the books.
