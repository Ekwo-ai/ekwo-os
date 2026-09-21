# France

The format is [`docs/packs.md`](../../docs/packs.md). This file records what the
pack deliberately leaves out of form 3310-CA3, and why, so that a French
accountant can disagree with one line rather than with the whole return.

**Status: `maintained`.** The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and not that it is
right.

## Debt: the numbering of form 3310-CA3

**The metropolitan 2,1 % is declared on line T6, not on line 13.** On the
form in force — 3310-CA3, cerfa n° 10963*31, and its notice 3310-NOT-SD —
line 13 is *Anciens taux*, and the continental 2,1 % goes on line **T6**,
*Opérations réalisées en France continentale au taux de 2,1 %*. The pack
posts `FR-S-021` to a box it calls `13`. Since version 1.15.0 the label of
that box says so, in both languages; its identifier stays `13`, because an
identifier is immutable once published and a label is not.

The same is true of frame A, and of one line of frame B. The pack names its
boxes after a version of the form that preceded the one in force. The
amounts are the right ones; these identifiers are not the ones printed:

| Pack box | Printed on the form in force | Line |
|---|---|---|
| `01` | A1 | Ventes, prestations de services |
| `03` | B2 | Acquisitions intracommunautaires |
| `2A` | A3 | Achats de prestations de services réalisés auprès d'un assujetti non établi en France (art. 283-2) |
| `3A` | A4 | Importations (autres que les produits pétroliers) |
| `3C` | B4 | Achats de biens ou de prestations de services réalisés auprès d'un assujetti non établi en France (art. 283-1) |
| `04` | E1 | Exportations hors UE |
| `05` | E2 | Autres opérations non imposables |
| `06` | F2 | Livraisons intracommunautaires à destination d'une personne assujettie |
| `13` | T6 | Opérations réalisées en France continentale au taux de 2,1 % |
| `28` | TD | TVA due (ligne 16 – ligne 23); the form's own line 28 is TD less the energy excise credit X5, the same amount when there is none |

Every other box of the pack — `08`, `09`, `9B`, `10`, `11`, `15`, `5B`, `16`,
`17`, `19`, `20`, `21`, `22`, `2C`, `23`, `24`, `25`, `26`, `27` — carries the
identifier the form in force prints. One further point goes with the table:
an autoliquidated import posts its tax to line `08`, where the form in force
has lines **I1 to I6** for it.

The fix is a new version of the form beside the old one, the old closed with
a `valid_to` and the new opened with a `valid_from`, which needs a pack to hold
more than one form. It is not an edit of this one.

## The overseas departments

Article 296, 1°, of the CGI taxes Guadeloupe, Martinique and La Réunion at
**8,5 %** (standard) and **2,1 %** (reduced, for the operations of articles
278-0 bis to 279-0 bis A and 298 octies). Article 294, 1, makes VAT
provisionally **not applicable in French Guiana and Mayotte**. The
administration's commentary is BOI-TVA-GEO-20 and BOI-TVA-GEO-20-10
(`bofip.impots.gouv.fr`).

Since pack version 1.15.0 the pack carries, for each of `GP`, `MQ` and `RE`:

| Code | What |
|---|---|
| `FR-S-085-<dept>` | sale at 8,5 %, CA3 line 10 |
| `FR-S-085-ENC-<dept>` | service at 8,5 %, VAT on collection, line 10 |
| `FR-S-021-<dept>` | sale at 2,1 %, line 11 |
| `FR-P-085-<dept>` | purchase at 8,5 %, line 20 |
| `FR-P-085-ENC-<dept>` | purchase of services at 8,5 %, deductible on payment, line 20 |
| `FR-P-085-I-<dept>` | fixed asset at 8,5 %, line 19 |
| `FR-P-021-<dept>` | purchase at 2,1 %, line 20 |

Each code names its department in `applies_when.supply_in`, so the engine
refuses it for an operation located anywhere else. Three codes per rate and not
one, because `applies_when` has no disjunction: "Guadeloupe, Martinique or La
Réunion" is not something the format can say, and each department is a row of
`territories` already.

**French Guiana and Mayotte carry no code, and that is the law, not a gap.** An
operation located there is outside French VAT altogether. What the pack cannot
do is *refuse* a metropolitan code for such an operation: `FR-S-20` names no
territory, and a condition cannot say "not in GF". The core work on
territories that sit outside their parent's tax is where that belongs;
[`docs/international.md`](../../docs/international.md) says so under France.

Not carried either: the special DOM rates of lines **T1** (1,75 %) and **T2**
(1,05 %), and the imports into a department,
which the customs administration pre-fills on lines **I1 to I6**.

`FR-P-021`, the metropolitan purchase at 2,1 %, arrived with the same version:
the sale side had it and the purchase side did not.

## Form 3310-CA3, line by line

Compared with the form in force, millésime 2026 (cerfa n° 10963*31) and its
notice 3310-NOT-SD, on 21 September 2026.

### Lines the pack carries since 1.15.0

`10` and `11` (the overseas departments, above); `17`, the intra-Community
acquisition tax already inside line 16, which the autoliquidation posting now
names beside `08`; `24`, the deductible import tax already inside line 23,
which the import posting names beside `20`; `27`, line 25 less line 26. And
six lines nothing in the pack posts to, declared so that the totals are the
form's and the declarant can fill them: **15** and **5B** (inside 16), **21**,
**22** and **2C** (inside 23), and **26**.

### Lines not carried, and why

| Line | Why not |
|---|---|
| A2 | other taxable operations — self-supplies and the like, no document of the pack produces one |
| A5, E5, E6 | suspensive tax and customs regimes |
| B1, F4, F5, P1, P2, 2E | petroleum products, for a TICPE payer |
| B3, F3 | electricity, gas, heat and cold, a regime of its own |
| B5, F8 | regularisations the notice asks never to net against the other lines |
| E3 | distance sales taxable in another Member State, declared through the One-Stop Shop |
| E4 | imports other than petroleum products, pre-filled by the customs administration |
| F1, F6 | non-taxable intra-Community acquisitions and purchases under franchise |
| F7 | sales by a taxable person not established in France, a return filed by that person |
| F9 | internal operations of a single taxable person (article 256 C) |
| T1, T2 | the special DOM rates of 1,75 % and 1,05 % |
| TC, T3, T4, T5 | Corsica, article 297 |
| T7 | withholding of VAT on authors' rights |
| I1 to I6 | see above |
| 18 | operations to Monaco, which the pack does not tell apart |
| 22A | a percentage, not an amount |
| TD | the pack's `28` is line 16 less line 23, which is TD; without the energy excise lines, TD and 28 are the same amount |
| X1 to Z5, M1 to M9 | the energy excise, declared on the same form |
| AA, AB, Y6 | VAT group consolidation (article 1693 ter) |
| 29, 32 | the assimilated taxes of annex 3310-A, and the total that adds them |

Line **14** of earlier versions of the form is not on the form in
force: the rates it used to gather from an annex are lines T1 to T7 now.
