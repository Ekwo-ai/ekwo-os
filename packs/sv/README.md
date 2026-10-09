# El Salvador

Everything El Salvador adds to Ekwo, as data: an original chart of accounts
built on the IFRS the country's accounting profession has adopted, the
journals, the Impuesto a la Transferencia de Bienes Muebles y a la Prestación
de Servicios (IVA) at 13% with its zero rate on exports and the exemptions of
the law, the boxes of the monthly return F07, a balance sheet and an income
statement, and the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Salvadoran accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

**Language: `es`.** Every label is written in Spanish, the language of the law
and of the Ministerio de Hacienda's forms. **Status: `community`.** Nobody who
files a Salvadoran return has reviewed it; the golden figures prove the pack is
coherent and prove nothing about whether it is right.

El Salvador is outside the common system of VAT of Directive 2006/112/EC, so
`supabase/seed/00_territories.sql` carries a row for `SV` with `eu_vat_scope`
`none`: no `exemption_code`, no `intracom_*` treatment. The currency is the US
dollar (`USD`, two decimals; the country has used it since 2001), already in
`00_currencies.sql`, so no currency row is added. Bitcoin is not modelled: the
reform of the Bitcoin Law (Decreto Legislativo No. 199, approved 29 January
2025) made its acceptance voluntary and repealed the authorisation to pay taxes
with it, so every tax is paid in dollars.

## The tax

| Tax | Rate | Source |
|---|---|---|
| IVA, standard rate | 13% | Ley del IVA, art. 54 (D.L. No. 370 of 8 June 1995) |
| Exports of goods and services | 0% | arts. 74 and 75 |
| Exempt services (housing rent, education, public road passenger transport, …) | exempt | art. 46 |
| Exempt imports | exempt | art. 45 |

Ten taxes: two sale codes at 13% (`SV-S-13-CCF` to a contributor with a
comprobante de crédito fiscal, `SV-S-13-FAC` to a final consumer with a
factura), `SV-S-EXE` (exempt), `SV-S-NS` (not subject), three zero-rated export
codes (goods outside Central America, goods to the Central American region,
services), `SV-P-13` (domestic purchase, recoverable), `SV-P-13-IMP` (import
settled at customs, recoverable) and `SV-P-0` (exempt or not-subject purchase).
The two 13% sale codes exist because the return reports the two document types
in different boxes.

## The return: Formulario F07

Monthly (art. 93), filed through the Dirección General de Impuestos Internos
(DGII) online portal, **even with no operations**. The deadline is the first
ten **business** days of the following month (art. 94), which is also when the
tax withheld or perceived by withholding agents is paid in.

The pack declares the boxes below. Their numbers come from the F07 form
(version 13, `PMHDC8215.pdf` on the Ministerio de Hacienda's server) as quoted
by search extracts of it: **the form itself could not be opened directly** (the server answered 503
throughout the research) and the current version (14) was not reachable, so
every number must be checked against the live form before relying on it.

| Boxes | Content |
|---|---|
| 85, 86 | Domestic sales exempt / not subject |
| 90, 91, 94 | Exports of goods outside Central America / to Central America / of services |
| 95 → 135 | Sales with comprobante de crédito fiscal → output tax |
| 96 → 140 | Sales with factura → output tax |
| 105, 150 | Total sales, total output tax |
| 80 → 130 | Domestic purchases → input tax |
| 75 → 125 | Imports of goods → input tax |
| `PAGAR`, `REMAN` | Tax payable / credit carried forward |

`PAGAR` and `REMAN` are the two results the form prints, but their box numbers
could not be verified in a readable source; they carry a mnemonic code rather
than an invented number.

## What the format could not say

- **A deadline in business days.** The closed deadline rules know calendar days
  only. The pack uses `depends_on_taxpayer`, which computes no date, rather
  than a calendar day that would mark an on-time return late.
- **The e-invoicing obligation.** `einvoicing.obligation: mandatory` requires a
  `mandatory_from` date, and a date requires an EN 16931 profile, which the
  Salvadoran Documento Tributario Electrónico (DTE) is not. The fields stay
  empty, as for Mexico and Colombia; the obligation is documented below.
- **Withholding and perception of IVA (Código Tributario, arts. 162 and 163).**
  Not modelled. A large taxpayer (Gran Contribuyente) buying from a non-large
  contributor withholds **1%** of the price excluding IVA on operations of
  **100 USD or more** (art. 162); a large-taxpayer importer, producer or
  distributor of the goods listed in art. 163 (alcoholic drinks, tobacco,
  snacks, soft drinks, fuel, spare parts, construction materials, cement,
  hardware) perceives **1%** on sales of 100 USD or more to non-large
  contributors for resale. Both are paid in with the return (art. 94), and the
  document records the amount (arts. 162 and 163). A tax code applies to every
  line it is put on and cannot test the 100 USD threshold per operation or the
  counterparty's classification, so a code would post a wrong amount below the
  threshold; the Mexican withholding codes are exact only because their rate is
  unconditional. The chart carries the accounts (`210504`, `210505`, `110702`)
  for a company to book the amounts by hand, and the F07 result does not net
  them. Art. 162-A (a 2% advance perceived by card acquirers) is likewise
  documented only (`110703`).
- **Proportionality** (art. 66) when a period mixes taxable and exempt
  operations, and the carry-forward of last period's credit, are not modelled;
  `REMAN` is computed per period.
- **Purchases from exempt or not-subject suppliers and from excluded
  subjects** reach no box: their numbers were not verified.
- **Tax point.** Art. 8 makes the tax chargeable on the earliest of the
  document, the delivery or the payment; the closed vocabulary has no word for
  all three, so the pack uses `earliest_of_delivery_or_payment`.

## Electronic invoicing

Decreto Legislativo No. 487 (2022) added articles 119-A to 119-H to the Código
Tributario: a DTE is generated, signed and transmitted to the Ministerio de
Hacienda, and is deemed issued when the Administration grants the **sello de
recepción** (reception seal), which certifies transmission and reception
without validating the operation. Transitional article 12 lets the
Administration fix, taxpayer by taxpayer, the date from which each must issue
DTEs: there is **no single date**; the DGII notifies each contributor, who
checks it on `factura.gob.sv`. Press and vendor material give 1 July 2023 for
the first group (large taxpayers); no communiqué of the Administration was
opened to confirm it, so the pack states no date.

Ekwo does not sign, transmit or obtain the seal of any DTE. Every document
carries the mention `dte_seal_pending`. The number of a document in Ekwo is the
number of the accounting entry, not the control number or generation code of
the DTE. **A "DTE 2.0" cut-over on 1 December 2026 circulates in vendor
material; no text of the Ministerio de Hacienda confirming it was found, so the
pack does not cite it.**

## The chart of accounts

El Salvador prescribes no catalogue of accounts. The Consejo de Vigilancia de
la Profesión de Contaduría Pública y Auditoría (CVPCPA) fixes the framework:
Resolution 462 of 18 March 2021 ratifies the IFRS for SMEs (Spanish 2015) and
full IFRS (Spanish 2020); the SME standard has applied since financial years
starting 1 January 2011 according to secondary sources (the original 2009
resolution was not opened). This chart is **original**, with 157 accounts, and
every detail account reaches exactly one line of `SV-NIIF-ESF` or `SV-NIIF-ER`
(a summary balance sheet and income statement; there is no single legal
format).

The IVA position is kept on four accounts: `210501` output tax and `210502`
input tax are posting accounts; `210503` (payable, `tax_payable`) and `110701`
(credit, `tax_receivable`) settle the return and are the only reconcilable
accounts besides customers and suppliers.

## Sources

The register in `pack.json` holds eight texts, consulted on 9 October 2026: the Ley
del IVA, the Código Tributario, Decreto Legislativo No. 487, the F07 form (read
only through search extracts, see above), the
DGII boletín for new contributors, the DGII online portal, the DTE site and
CVPCPA Resolution 462. The Ley del IVA copy and the Código Tributario copy are
the versions published by the Legislative Assembly through government portals;
the Código Tributario text opened pre-dates Decreto 487 and some later reforms,
so articles 162, 162-A and 163 should be re-read in the current consolidated
text.

## To have reviewed by a local accountant

The F07 box numbers (version 14), the numbers of the result boxes, the
treatment of purchases from exempt and excluded subjects, the 1 July 2023 date
of the first DTE group, and the current wording of arts. 162, 162-A and 163.
