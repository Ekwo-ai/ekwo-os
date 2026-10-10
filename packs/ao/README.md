# Angola

Everything Angola adds to Ekwo, as data: the Plano Geral de Contabilidade
(PGC) as the chart of accounts, the journals, the Imposto sobre o Valor
Acrescentado (IVA) at 14 %, 7 %, 5 % and 1 %, exports, exemptions and the
reverse charge on foreign services, the monthly periodic declaration (Modelo 7),
and the balance sheet and income statement of the PGC. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that an Angolan accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files an Angolan VAT return has reviewed it.
The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**Portuguese.** The labels of the chart, the journals, the taxes, the boxes and
the statements are in Portuguese, the language of the Diário da República.

## Sources

The register in `pack.json` holds seventeen texts. The ones this file leans on:

| What | Text | Where |
|---|---|---|
| Rates, exemptions, exports, withheld tax, return, exclusion and simplified regimes | Código do IVA (Lei n.º 7/19), as amended and republished by the Lei n.º 14/23 of 28 December 2023, arts. 11, 12, 15, 19, 21, 44, 60, 69.º-A, Anexos I to IV | `lex.ao`, `angolex.com` |
| The 5 % on industrial equipment; the exemption of mobile payments | Lei n.º 14/25 of 30 December 2025 (Orçamento Geral do Estado 2026), arts. 23 and 35 | `angolex.com` |
| The temporary 7 % on the basic basket, 2022-2023 | Lei n.º 32/21 (Orçamento Geral do Estado 2022), as summarised by PLMJ | `plmj.com` |
| The boxes of the return | Modelo 7, Declaração Periódica do IVA | `minfin.gov.ao` |
| Where it is filed; the SAF-T (AO) files | Portal do Contribuinte of the Administração Geral Tributária (AGT) | `portaldocontribuinte.minfin.gov.ao` |
| The chart | Decreto n.º 82/01 of 16 November 2001 (PGC); Decreto Presidencial n.º 180/19 (account 34.5, IVA) | `angolex.com`, `segcontas.co.ao`, `lex.ao` |
| Invoices and electronic invoicing | Decreto Presidencial n.º 71/25 of 20 March 2025 | `lex.ao` |
| The special consumption tax | Lei n.º 8/19 of 24 April 2019 | `lex.ao` |

**The law of 2023 prevails over the AGT page.** The IVA page of the Portal do
Contribuinte still describes the rules of 2019 (Cabinda at 2 %, the simplified
regime at 3 %). The Lei n.º 14/23 fixes 1 % for Cabinda and 7 % for the
simplified regime, and that is what the pack carries.

## The taxes

| Code | Rate | From | What |
|---|---|---|---|
| `AO-S-14` | 14 % | 2019-10-01 | General rate, art. 19 |
| `AO-S-7-HR` | 7 % | 2024-01-01 | Hotels and catering |
| `AO-S-7-SIMP` | 7 % | 2024-01-01 | Simplified regime (turnover Kz 25 M to under Kz 350 M) |
| `AO-S-5` | 5 % | 2024-01-01 | Foodstuffs and agricultural inputs of Anexos I and II |
| `AO-S-7-CB` | 7 % | 2022-01-01 to 2023-12-31 | The basic basket, closed when the 5 % replaced it |
| `AO-S-1-CAB` | 1 % | 2024-01-01 | Special regime of Cabinda |
| `AO-S-5-IND` | 5 % | 2026-01-01 | Industrial equipment of an approved manufacturer, Lei 14/25 art. 23 |
| `AO-S-EXP` | 0 | | Export, exempt with the right to deduct |
| `AO-S-EX`, `AO-S-EX-MOB` | 0 | | Exempt without the right to deduct; mobile payment platforms (2026) |
| `AO-S-NS` | 0 | | Outside the scope (art. 10) |

Purchases mirror them: stock, fixed assets, other goods and services land in
the matching fields of the return; there are also a non-deductible code, an
exempt purchase, an import collected by customs and the reverse charge of
art. 29.

**The simplified regime is a taxpayer's regime, not a product's rate.**
`AO-S-7-SIMP` exists so a company in that regime has a code that says what it
is, and is chosen by that company for all its supplies. Nothing selects it by
default. The 10 % input-tax allowance that regime carries, and the simplified
return it files, are not modelled. The exclusion regime (turnover under
Kz 25 M) has no VAT to charge and needs no code.

**The rates are not on the return.** The Modelo 7 has one line for supplies on
which tax was charged, whatever the rate; the five rates all post to fields 01
and 02.

## The return

`tax_report.json` carries the Modelo 7 of the general regime: quadro 9 fields
01 to 29, the sums 31 to 33, the credit of field 34, the tax payable of fields
35 and 37. Filing is monthly, by the last day of the month following (art. 44);
some commentaries say the last *working* day, which Ekwo's rule cannot see.
Boxes the pack carries and no code writes into — the cash-accounting regime
(3, 4), withheld tax (5 to 9, 26, 27) and adjustments (28, 29) — keep the form
whole. Field 36, the use of earlier credits, is a taxpayer's input and is not
carried, so field 37 equals field 35.

Two printings of the form circulate: the Diário da República specimen has
fields 26 and 27 as adjustments of withheld tax; a second printing calls them
adjustments notified by the AGT and adds a field 30. This pack follows the
first. The heading of part B of quadro 12 says «campo 04» for exports; as field
04 is a tax field in the sums, the pack reads it as the exempt-with-deduction
line, field 10.

## The chart

The PGC of Decreto n.º 82/01 is the legal chart: 238 accounts, the official
codes and names of classes 1 to 8 with the dots removed from the code (34.5.3.1
is `34531`). The VAT accounts come from the Decreto Presidencial n.º 180/19.
Two accounts are added where the plan leaves the level free: `7581` Arredondamentos
(rounding) and `3791` IVA de importação a pagar à alfândega. The account that
settles the return is `34561` (a pagar) or `34571` (a recuperar); tax is posted
on `34521` to `34523` (deductible) and `34531` (charged), so the settlement
account is never a posting account. Banks and insurers follow their own
regimes (IFRS for banks) and are not served by this chart.

## What the pack does not do

- **Electronic invoicing.** Decreto Presidencial n.º 71/25 makes it mandatory
  for the general and simplified regimes: from 1 January 2026 for large taxpayers
  and suppliers of the State, from 1 January 2027 for the others as announced by
  the tax administration. Each invoice is transmitted in real time to the AGT by
  software the AGT validates. That is clearance, not an exchange format;
  `einvoicing.obligation` is `none` and Ekwo does not connect to the AGT.
- **SAF-T (AO).** The monthly file of invoicing (and, if the supplier annex is
  not filed, of purchases) is due by the last day of the following month; a
  taxpayer under e-invoicing is relieved of it. Ekwo has no SAF-T (AO) export.
- **Special consumption tax (IEC, Lei n.º 8/19).** It is added to the invoice
  of alcoholic and sugared drinks, tobacco, vehicles, fuels and others, and the
  VAT is computed on a base that includes it. The rates differ by product
  (from 2 % to 50 %, Lei 16/21) and rest on no official table here, so no tax
  code is invented; a company posts the IEC to account `342` and enters it as
  a line of the invoice taxed at the VAT code.
- **Withheld tax** (art. 21 and 31: banks and insurers retain 50 %, public
  bodies retain on imports), the **cash-accounting regime** (art. 60), the
  **pro rata deduction**, the **margin scheme** and the **advances** of field 41
  are not modelled.
- **Statements.** The balance sheet and the income statement by nature follow
  the PGC model at the level of the chart; the cash-flow statement and the notes
  are not carried.

## For the reviewing accountant

1. The placement of `AO-S-EX-MOB` (field 11) and `AO-S-EXP` (field 10).
2. Whether the tax point `delivery_date` fits art. 11 for advances and invoices
   issued before delivery.
3. The 7 % start date of `AO-S-7-HR` (read as 1 January 2024 from the Lei 14/23).
4. The accounts `34561` and `34571` as the settlement accounts, against the
   numbering printed in the Decreto Presidencial n.º 180/19.
5. Whether the printing of the Modelo 7 followed here is the one the portal
   currently asks for.
