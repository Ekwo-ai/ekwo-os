# Ecuador

Everything Ecuador adds to Ekwo, as data: an original chart of accounts built
on the classification the NIIF prescribe, the journals, the value added tax
(impuesto al valor agregado — IVA) at its general rate and at tarifa cero,
an export exemption and a sale to the State that keeps its right to a tax
credit, nineteen fields of Formulario 104, a summarised balance sheet and
income statement, and the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that an Ecuadorian accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

**Status: `community`.** Nobody who files an Ecuadorian return has reviewed
it. The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language.** The pack's own labels are written in Spanish
(`defaults.language: "es"`), and `languages` is empty: no second wording is
declared yet. Ecuador's own chart is original (see below), so there is no
official text in another language to translate against.

## The chart of accounts is original

**Ecuador does not impose a chart of accounts on every company.** Ley de
Régimen Tributario Interno (LRTI), art. 20, requires double-entry
bookkeeping, in Spanish, in United States dollars, "tomando en consideración
los principios contables de general aceptación" — in current practice, full
NIIF or NIIF for SMEs, which the Superintendencia de Compañías, Valores y
Seguros adopted for the companies it supervises. Art. 21 makes those same
financial statements the basis for both the tax declarations and the filing
with the Superintendencia. Neither article, nor any other text found for this
pack, numbers a company's accounts.

This chart is therefore original, the way the United States' and the United
Kingdom's are: it follows the classification of asset, liability, equity,
income and expense the NIIF prescribe, coded in five classes (1 to 5) so that
every posting account reaches exactly one line of `EC-NIIF-ESF` or
`EC-NIIF-ER`. A company that already keeps its books on a different numbering
is not asked to renumber anything: only the account a role or a tax posting
names has to exist under the code this pack gives it.

## Sources

Every rate, box, mention and statement carries its own `legal_reference` and
the key of the text it is in. The register in `pack.json` holds eight texts,
all opened on 26 September 2026: the Ley de Régimen Tributario Interno and
its extract on the obligation to keep accounts (arts. 19 to 21); Decreto
Ejecutivo No. 198 of 15 March 2024, which set the general rate at 15 %; the
Reglamento para la Aplicación de la LRTI; the official Formulario 104 (the
IVA declaration) and its filling guide; the Reglamento de Comprobantes de
Venta, Retención y Documentos Complementarios; the SRI's own page on
electronic invoicing; and the SRI en línea filing portal.

The Superintendencia de Compañías' own chart-of-accounts document
(`appscvsmovil.supercias.gob.ec`) could not be opened from where this pack was
written — the connection was refused — so this pack does not cite it and does
not copy its numbering: see *What the core could not say* below and the
reasoning above for why an original chart was the honest choice instead.

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

**Tarifa cero is not one bucket, and the format tells the two halves of it
apart by treatment.** LRTI arts. 55 and 56 tax a long list of goods and
services — basic foodstuffs in their natural state, medicine, books,
education, health, domestic transport, and more — at zero. Art. 66, inciso
primero, numeral 3, then takes the ordinary right to a tax credit away from
whoever produces or sells them: no output tax, no input credit either. That
is exactly the shape the format's `exempt` treatment and `E` category are
for, so `EC-S-0` declares it that way, with bread (`pan`) as the pack's
example — the plainest case of art. 55, numeral 1. The same article 66, its
own following unnumbered article and art. 57 then carve out named exceptions
that keep the credit: a sale to an exporter who will re-export the goods, a
sale to the State and its public enterprises, a receptive tourism package,
urban public passenger transport. `EC-S-0-PUBLICO` is the pack's example of
that second half — `domestic` at `rate: 0`, `vat_category: Z`, the same shape
as a British zero-rated good — with a sale to a gobierno autónomo
descentralizado. Getting the two the wrong way round would have been the
easiest mistake this pack could make, so it is written out here for whoever
reviews it next.

**Ecuador is outside the common system of VAT.** `supabase/seed/00_territories.sql`
carries a row for `EC` with `eu_vat_scope: none`. Consequently `exemption_code`
stays null on every tax — the VATEX list belongs to a system Ecuador is not
in — the article goes in `legal_reference` instead, the five `intracom_*`
treatments are never used, and `vat_category` is declared on the sale-side
taxes purely for the reader, the way the Mexican and Colombian packs do,
since no `einvoicing.profile` is named.

**Goods and services do not split on either side of Formulario 104.** Unlike
the Colombian and Peruvian forms, a single pair of boxes (500/520, or 501/521
for a fixed asset) carries a domestic purchase of either a good or a service
at the general rate: the box a purchase reaches depends on whether it is a
fixed asset, not on what was bought. `EC-P-15` therefore serves a purchased
service as much as a purchased good.

**Not here: the withholding regimes.** Ecuador layers two withholding
mechanisms on top of the taxes above, and neither is modelled:

- **Retención en la fuente de IVA** — a buyer designated a withholding agent
  withholds 10, 20, 30, 50, 70 or 100 per cent of the IVA a supplier invoiced
  (Resolución NAC-DGERCGC20-00000061 and its successors) and remits it
  directly to the SRI on a separate return (Formulario 103, which this
  repository does not carry).
- **Retención en la fuente del impuesto a la renta** — a percentage of a
  payment withheld against the recipient's income tax (currently
  Resolución NAC-DGERCGC26-00000009), a different tax altogether from the
  IVA this pack declares.

A company subject to either needs a professional's help, or a dedicated
withholding pack, until a later version carries them. See *What the core
could not say* below.

## The declaration

`EC-IVA-104` is Formulario 104, filed monthly by the general rule of LRTI
art. 67; a taxpayer who sells *exclusively* tarifa-cero or non-taxed goods
and services, or who is subject to full IVA withholding, files it
half-yearly instead — a fact about the company the pack cannot answer for
everybody, so it declares no `period_default`, the same reasoning as the
Colombian and Luxembourg packs. The pack states thirteen of the form's
boxes: the ones its taxes actually reach.

- **The liquidation chain is simplified.** The real Formulario 104 carries a
  box for tax generated on a sale on credit of a month or more, deferred to
  the instalment in which it is collected (casilleros 480 to 486), and a
  carry-forward of unused tax credit from one period to the next (casilleros
  605 to 619). Neither is modelled: `EC-IVA-104` compares the whole period's
  generated tax (box 429) against the whole period's deductible tax (box
  564) and stops there. A company that sells on deferred terms, or that
  carries a credit balance into the next period, needs to track that by hand
  until a later version of this pack does.
- **The proportionality factor of art. 66 is simplified.** A taxpayer who
  cannot attribute a purchase directly to a taxed sale or to a tarifa-cero
  sale with no right to credit must prorate its input tax by a factor set
  each year from the previous year's sales (LRTI art. 66, inciso segundo,
  and RALRTI arts. 153 and 157). This pack's box `564` takes the full input
  tax of boxes 520 and 521 instead, which is correct only where every
  purchase can be attributed directly to what it produced — true of the
  golden scenario, where each purchase is a specific line of merchandise,
  but not of every real company. A company that cannot attribute its
  purchases directly needs a professional to compute the factor by hand.
- **Rounding.** No rounding unit is declared: the SRI's own guide gives no
  coarser unit than the currency's own cents.
- **Deadline.** `depends_on_taxpayer`: the Reglamento para la Aplicación de
  la LRTI, art. 158, assigns the day by the ninth digit of the Registro
  Único de Contribuyentes (RUC), between the 10th and the 28th of the
  following month.

## The golden year

A trading company (comercializadora), filing monthly, January and February
2026: eleven documents and five payments. It sells general merchandise at
15 %, bread at tarifa cero with no right to credit, office supplies to a
municipal government at tarifa cero with a right to credit, and exports
goods at tarifa cero; it credits back part of the 15 % sale. It buys general
merchandise and bread for resale, a computer as a fixed asset, all at the
general rate except the bread; it credits back part of a purchase. The first
period ends owing tax (box 601); the second period is built so its purchases
outweigh its sales, to exercise box 602 (crédito tributario, saldo a favor)
rather than only box 601.

Every figure of `golden/vat_return.json`, `golden/statements.json` and
`golden/trial_balance.json` was checked by hand against the scenario before
this pack was committed — not only replayed by `tests/golden.test.ts`.

## What the core could not say

The Ecuadorian section of
[`docs/international.md`](../../docs/international.md) states each of these
as a change to the core. In short:

1. **Clearance.** `einvoicing` can say "mandatory" only for a profile built
   on EN 16931, and has no way to say "valid only once the SRI validates it
   and assigns a clave de acceso"; the pack leaves the fields empty and says
   why in the reference, exactly as the Mexican and Colombian packs do.
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
exceptions of arts. 57 and 66); the choice to make the chart original rather
than reach for a numbering this pack could not verify from an official
source; the tax point declared as `delivery_date` against the services
branch of art. 61 that it does not cover; and whether the abridged NIIF
statements should give way to a full presentation by a professional who
holds one.
