# Ecuador

Everything Ecuador adds to Ekwo, as data: an original chart of accounts built
on the classification the NIIF prescribe, the journals, the value added tax
(impuesto al valor agregado — IVA) at its general rate and at tarifa cero,
an export exemption and a sale to the State that keeps its right to a tax
credit, nineteen fields of Formulario 104, a summarised balance sheet and
income statement, and the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md).

**Status: `community`.** Nobody who files an Ecuadorian return has reviewed
it. `tests/golden.test.ts` replays a year of books, which proves the pack is
coherent, not that it is right.

**Language.** Labels are in Spanish (`defaults.language: "es"`); `languages`
is empty. The chart is original, so there is no official text in another
language to translate against.

## The chart of accounts is original

**Ecuador does not impose a chart of accounts on every company.** Ley de
Régimen Tributario Interno (LRTI), art. 20, requires double-entry
bookkeeping, in Spanish, in United States dollars, "tomando en consideración
los principios contables de general aceptación" — in practice full NIIF or
NIIF for SMEs, adopted by the Superintendencia de Compañías, Valores y Seguros
for the companies it supervises. Art. 21 makes those statements the basis for
both the tax declarations and the filing with the Superintendencia. Neither
article numbers a company's accounts.

The chart follows the NIIF classification, coded in five classes (1 to 5) so
that every posting account reaches exactly one line of `EC-NIIF-ESF` or
`EC-NIIF-ER`. A company on a different numbering need not renumber: only the
accounts a role or a tax posting names must exist under this pack's codes.
The Superintendencia's own chart-of-accounts document is not cited and its
numbering is not copied.

## Sources

Every rate, box, mention and statement carries its own `legal_reference` and
the key of its text. The register in `pack.json` holds eight texts: the Ley
de Régimen Tributario Interno and its extract on the obligation to keep
accounts (arts. 19 to 21); Decreto Ejecutivo No. 198 of 15 March 2024, which
set the general rate at 15 %; the Reglamento para la Aplicación de la LRTI;
the official Formulario 104 (the IVA declaration) and its filling guide; the
Reglamento de Comprobantes de Venta, Retención y Documentos Complementarios;
the SRI's page on electronic invoicing; and the SRI en línea filing portal.

## Taxes

| Code | Rate | Treatment | Declaration fields |
|---|---|---|---|
| `EC-S-15` | 15 % | domestic sale | 401 / 421 |
| `EC-S-0` | 0 % | domestic sale, sin derecho a crédito (arts. 55-56) | 403 |
| `EC-S-0-PUBLICO` | 0 % | domestic sale to the State, con derecho a crédito (art. 57) | 405 |
| `EC-S-EXP` | 0 % | export of goods (art. 55.14) | 407 |
| `EC-P-15` | 15 % | domestic purchase, goods and services | 500 / 520 |
| `EC-P-15-FIJO` | 15 % | domestic purchase, fixed assets | 501 / 521 |
| `EC-P-0` | 0 % | domestic purchase | 507 |
| `EC-P-15-IMPSERV` | 15 % | import of a service from a non-resident, 100 % withheld by the buyer | 503 / 523 / 731 |

**Tarifa cero is not one bucket; the pack tells its two halves apart by
treatment.** LRTI arts. 55 and 56 tax a long list of goods and services —
basic foodstuffs in their natural state, medicine, books, education, health,
domestic transport, and more — at zero. Art. 66, inciso primero, numeral 3,
takes the right to a tax credit away from whoever produces or sells them: no
output tax, no input credit. `EC-S-0` declares that as the `exempt`
treatment, category `E`, with bread (`pan`, art. 55, numeral 1) as example.
Art. 66, its following unnumbered article and art. 57 carve out named
exceptions that keep the credit: a sale to an exporter who will re-export the
goods, a sale to the State and its public enterprises, a receptive tourism
package, urban public passenger transport. `EC-S-0-PUBLICO` covers that half
— `domestic` at `rate: 0`, `vat_category: Z` — with a sale to a gobierno
autónomo descentralizado.

**Ecuador is outside the common system of VAT.** `supabase/seed/00_territories.sql`
carries `EC` with `eu_vat_scope: none`: `exemption_code` stays null (the
article goes in `legal_reference`), the `intracom_*` treatments are never
used, and `vat_category` on sale-side taxes is for the reader only, since no
`einvoicing.profile` is named.

**Goods and services do not split on Formulario 104.** One pair of boxes
(500/520, or 501/521 for a fixed asset) carries a domestic purchase of a good
or a service at the general rate, so `EC-P-15` serves both.

**A service bought from a supplier abroad is an import of services.** A
software subscription, hosting or an API billed by a non-resident is one in
the sense of LRTI art. 70, third paragraph. The buyer issues a *liquidación
de compra de bienes y prestación de servicios*, withholds **all** of the IVA
as a withholding agent (art. 63), and takes the same IVA as crédito
tributario (art. 66). The SRI's instructions for Formulario 104 (September
2017) put the import in boxes 503 and 523 and say: *"Recuerde consignar en
la casilla 731 la totalidad del impuesto que debió ser retenido en estos
pagos"*. `EC-P-15-IMPSERV` books exactly that, in the same month: the
credit debited to `2.1.04.02` and declared in 523, which box 564 now adds,
and the withholding credited to `2.1.03.02` *Retenciones en la fuente de IVA
por pagar* and declared in 731. The withholding is paid with the return
whatever the balance of boxes 601/602, since a withholding is never offset by
the withholder's own credit. **A foreign supplier belongs on `2.1.01.02`
*Proveedores del exterior*,** set as the contact's payable account; the
golden scenario cannot name a contact's account, so its supplier abroad
lands on `2.1.01.01`. Box 731 is the only withholding box this pack
declares; the withholding regimes below remain outside it.

**Not here: the withholding regimes.** Neither of Ecuador's two withholding
mechanisms is modelled:

- **Retención en la fuente de IVA** — a buyer designated a withholding agent
  withholds 10, 20, 30, 50, 70 or 100 per cent of the IVA a supplier invoiced
  (Resolución NAC-DGERCGC20-00000061 and its successors) and remits it
  directly to the SRI on a separate return (Formulario 103, which this
  repository does not carry).
- **Retención en la fuente del impuesto a la renta** — a percentage of a
  payment withheld against the recipient's income tax (currently
  Resolución NAC-DGERCGC26-00000009), a different tax altogether from the
  IVA this pack declares.

A company subject to either needs a professional, or a dedicated withholding
pack.

## The declaration

`EC-IVA-104` is Formulario 104, filed monthly by the general rule of LRTI
art. 67; a taxpayer who sells *exclusively* tarifa-cero or non-taxed goods
and services, or is subject to full IVA withholding, files half-yearly — a
fact about the company, so no `period_default` is declared. The pack states
thirteen of the form's boxes: the ones its taxes reach.

- **The liquidation chain is simplified.** The deferred tax on sales on
  credit of a month or more (casilleros 480 to 486) and the carry-forward of
  unused credit (casilleros 605 to 619) are not modelled: `EC-IVA-104`
  compares generated tax (box 429) with deductible tax (box 564) for the
  period. Deferred sales and credit carried forward must be tracked by hand.
- **The proportionality factor of art. 66 is simplified.** A taxpayer who
  cannot attribute a purchase directly to a taxed sale or to a tarifa-cero
  sale with no right to credit must prorate its input tax by a yearly factor
  from the previous year's sales (LRTI art. 66, inciso segundo, and RALRTI
  arts. 153 and 157). Box `564` takes the full input tax of boxes 520 and
  521, correct only where every purchase is directly attributable (true of
  the golden scenario); otherwise a professional computes the factor.
- **Rounding.** None declared: the SRI's guide gives no unit coarser than
  cents.
- **Deadline.** `depends_on_taxpayer`: the Reglamento para la Aplicación de
  la LRTI, art. 158, assigns the day by the ninth digit of the Registro
  Único de Contribuyentes (RUC), between the 10th and the 28th of the
  following month.

## The golden year

A trading company (comercializadora), filing monthly, January and February
2026: twelve documents and five payments. It sells general merchandise at
15 %, bread at tarifa cero with no right to credit, office supplies to a
municipal government at tarifa cero with a right to credit, and exports
goods at tarifa cero; it credits back part of the 15 % sale. It buys general
merchandise and bread for resale, a computer as a fixed asset, all at the
general rate except the bread; it credits back part of a purchase, and in February subscribes to a cloud
service from a non-resident, with the IVA withheld in full (boxes 503, 523
and 731). The first
period ends owing tax (box 601); the second period is built so its purchases
outweigh its sales, to exercise box 602 (crédito tributario, saldo a favor)
rather than only box 601.

## What the core could not say

See [`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

1. **Clearance.** `einvoicing` can say "mandatory" only for a profile built
   on EN 16931, and has no way to say "valid only once the SRI validates it
   and assigns a clave de acceso"; the pack leaves the fields empty and says
   why in the reference.
2. **A tax point that differs by document, at the taxpayer's election.** LRTI
   art. 61 gives goods one rule (delivery or payment, whichever comes first)
   and services a different one (the taxpayer chooses between the service
   being rendered and the payment); the closed vocabulary of `tax_point`
   cannot say the second.
3. **Two withholding regimes on a separate return.** Retención en la fuente
   de IVA and de impuesto a la renta are both computed and remitted apart
   from the declaration this pack models.
4. **A proportionality factor for input tax.** LRTI art. 66, inciso segundo,
   prorates a mixed taxpayer's credit by a factor the core does not compute;
   this pack's box 564 takes the simpler full-credit case.
5. **A deferred tax point for sales on credit**, and a **carry-forward of
   unused credit tributario** from one period to the next: both are boxes of
   the real Formulario 104 this pack does not populate.

## For a reviewer

The first things to read against practice: the split between `EC-S-0` (sin
derecho, the ordinary case) and `EC-S-0-PUBLICO` (con derecho, the named
exceptions of arts. 57 and 66); the original chart, rather than the
Superintendencia's numbering; the tax point declared as `delivery_date` against the services
branch of art. 61 that it does not cover; and whether the abridged NIIF
statements should give way to a full presentation by a professional who
holds one.
