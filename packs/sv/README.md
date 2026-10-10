# El Salvador

Everything El Salvador adds to Ekwo, as data: an original chart of accounts
built on the IFRS the country's accounting profession has adopted, the
journals, the Impuesto a la Transferencia de Bienes Muebles y a la Prestación
de Servicios (IVA) at 13% with its zero rate on exports and the exemptions of
the law, the boxes of the monthly return F07, a balance sheet and an income
statement, and the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md).

**Language: `es`.** Every label is written in Spanish, the language of the law
and of the Ministerio de Hacienda's forms. **Status: `community`.** Nobody who
files a Salvadoran return has reviewed it; the golden figures prove the pack is
coherent and prove nothing about whether it is right.

El Salvador is outside Directive 2006/112/EC:
`supabase/seed/00_territories.sql` gives `SV` `eu_vat_scope` `none` (no
`exemption_code`, no `intracom_*` treatment). The
currency is the US dollar (`USD`, two decimals, since 2001), already in
`00_currencies.sql`. Bitcoin is not modelled: Decreto Legislativo No. 199
(29 January 2025) made its acceptance voluntary and repealed paying taxes with
it.

## The tax

| Tax | Rate | Source |
|---|---|---|
| IVA, standard rate | 13% | Ley del IVA, art. 54 (D.L. No. 370 of 8 June 1995) |
| Exports of goods and services | 0% | arts. 74 and 75 |
| Exempt services (housing rent, education, public road passenger transport, …) | exempt | art. 46 |
| Exempt imports | exempt | art. 45 |

Eleven taxes: two sale codes at 13% (`SV-S-13-CCF` to a contributor with a
comprobante de crédito fiscal, `SV-S-13-FAC` to a final consumer with a
factura, reported in different boxes), `SV-S-EXE` (exempt), `SV-S-NS` (not
subject), three zero-rated export codes (goods outside Central America, goods
to the Central American region, services), `SV-P-13` (domestic purchase,
recoverable), `SV-P-13-IMP` (import settled at customs, recoverable),
`SV-P-13-SERVEXT` (service from a non-domiciled supplier, withheld and
recoverable) and `SV-P-0` (exempt or not-subject purchase).

**A service bought from a supplier abroad is an import of services.** Art. 14
says so in terms that cover a software subscription, hosting or an API:
*"existe importación o internación de servicios cuando la actividad que
generan los servicios se desarrolla en el exterior y son prestados a un
usuario domiciliado en el país que los utiliza en él, tales como: [...]
programas de computación"*. The buyer withholds 13 % of what it pays the
non-domiciled supplier (Código Tributario, art. 161) and pays it in with a
mandamiento de ingreso; art. 65 of the law makes that amount crédito fiscal
of the withholding agent *"siempre y cuando se declare y entere
íntegramente en el mismo período de emisión de los referidos documentos"*.
`SV-P-13-SERVEXT` books both halves in the same month: the credit debited to
`210502` and declared in boxes 77 (*Importaciones gravadas de servicios*) and
127 (*Crédito por importación de servicios*), which `PAGAR` and `REMAN` now
count; the withholding credited to the new `210506` *IVA retenido a sujetos no
domiciliados por pagar (13 %)*, paid with the mandamiento, outside the F07.
**A foreign supplier belongs on `210102` *Proveedores del exterior*,** set as
the contact's payable account; the golden scenario cannot name a contact's
account, so its supplier abroad lands on `210101`.

## The return: Formulario F07

Monthly (art. 93), filed on the Dirección General de Impuestos Internos (DGII)
portal, **even with no operations**, within the first ten **business** days of
the following month (art. 94), when withheld or perceived tax is also paid in.

Box numbers follow F07 version 13 (`PMHDC8215.pdf`); they must be checked
against the current form (version 14) before relying on them.

| Boxes | Content |
|---|---|
| 85, 86 | Domestic sales exempt / not subject |
| 90, 91, 94 | Exports of goods outside Central America / to Central America / of services |
| 95 → 135 | Sales with comprobante de crédito fiscal → output tax |
| 96 → 140 | Sales with factura → output tax |
| 105, 150 | Total sales, total output tax |
| 80 → 130 | Domestic purchases → input tax |
| 75 → 125 | Imports of goods → input tax |
| 77 → 127 | Imports of services → input tax (read from a version 14 sample of the form, not from the Ministry's copy) |
| `PAGAR`, `REMAN` | Tax payable / credit carried forward |

`PAGAR` and `REMAN` carry a mnemonic code: their box numbers are unconfirmed.

## What the format could not say

- **A deadline in business days.** The deadline rules know calendar days only;
  the pack uses `depends_on_taxpayer` rather than a date that would mark an
  on-time return late.
- **The e-invoicing obligation.** `mandatory` needs a `mandatory_from` date,
  which needs an EN 16931 profile; the DTE is not one. The fields stay empty.
- **Withholding and perception of IVA (Código Tributario, arts. 162 and 163).**
  Not modelled. A Gran Contribuyente buying from a non-large contributor
  withholds **1%** of the price excluding IVA on operations of **100 USD or
  more** (art. 162); a large-taxpayer importer, producer or distributor of the
  goods of art. 163 (alcoholic drinks, tobacco, snacks, soft drinks, fuel,
  spare parts, construction materials, cement, hardware) perceives **1%** on
  sales of 100 USD or more to non-large contributors for resale. Both are paid
  in with the return (art. 94) and recorded on the document. A tax code cannot
  test the threshold or the counterparty's class, so the chart carries the
  accounts (`210504`, `210505`, `110702`) for booking by hand; the F07 result
  does not net them. Art. 162-A (2% advance perceived by card acquirers) is
  documented only (`110703`).
- **Proportionality** (art. 66) and the carry-forward of last period's credit
  are not modelled; `REMAN` is computed per period.
- **Purchases from exempt or not-subject suppliers and excluded subjects**
  reach no box: their box numbers are unconfirmed.
- **Tax point.** Art. 8: earliest of document, delivery or payment; the pack
  uses `earliest_of_delivery_or_payment`.

## Electronic invoicing

Decreto Legislativo No. 487 (2022) added articles 119-A to 119-H to the Código
Tributario: a DTE is generated, signed and transmitted to the Ministerio de
Hacienda, and is deemed issued when the Administration grants the **sello de
recepción** (reception seal), which certifies transmission and reception
without validating the operation. Transitional article 12 lets the
Administration fix the start date taxpayer by taxpayer: there is **no single
date**; each contributor checks it on `factura.gob.sv`. The 1 July 2023 date
given by secondary sources for large taxpayers rests on no official
communiqué, so the pack states no date; nor does it cite a reported "DTE 2.0"
cut-over on 1 December 2026.

Ekwo does not sign, transmit or obtain the seal of any DTE. Every document
carries the mention `dte_seal_pending`. The number of a document in Ekwo is the
number of the accounting entry, not the control number or generation code of
the DTE.

## The chart of accounts

El Salvador prescribes no catalogue of accounts. The Consejo de Vigilancia de
la Profesión de Contaduría Pública y Auditoría (CVPCPA) fixes the framework:
Resolution 462 of 18 March 2021 ratifies the IFRS for SMEs (Spanish 2015) and
full IFRS (Spanish 2020); the SME standard has applied since financial years
starting 1 January 2011 according to secondary sources. This chart is
**original**, with 157 accounts; every detail account reaches exactly one line
of `SV-NIIF-ESF` or `SV-NIIF-ER` (summary balance sheet and income statement;
there is no single legal format).

IVA is kept on four accounts: `210501` output and `210502` input are posting
accounts; `210503` (payable, `tax_payable`) and `110701` (credit,
`tax_receivable`) settle the return and are the only reconcilable accounts
besides customers and suppliers.

## Sources

The register in `pack.json` holds eight texts: the Ley del IVA, the Código
Tributario, Decreto Legislativo No. 487, the F07 form, the DGII boletín for
new contributors, the DGII online portal, the DTE site and CVPCPA Resolution
462. The Código Tributario copy cited pre-dates Decreto 487 and some later
reforms; arts. 162, 162-A and 163 should be checked in the current text.

## To have reviewed by a local accountant

The F07 box numbers (version 14), the numbers of the result boxes, the
treatment of purchases from exempt and excluded subjects, the 1 July 2023 date
of the first DTE group, and the current wording of arts. 162, 162-A and 163.
