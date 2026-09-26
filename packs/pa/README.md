# Panamá

Everything Panama adds to Ekwo, as data: a chart of accounts organised on the
NIIF para las PYMES, the journals, the Impuesto de Transferencia de Bienes
Corporales Muebles y la Prestación de Servicios (ITBMS) at its general and
differentiated rates, an export relief and an exemption, the fields of
Formulario 430, a minimal balance sheet and income statement, and the
sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Panamanian accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

**Status: `community`.** Nobody who files a Panamanian return has reviewed
it. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**Language.** The pack's own labels are written in Spanish
(`defaults.language: "es"`), and `languages` is empty: no second wording is
declared yet. The Código Fiscal and the Formulario 430 have no official
English rendering, so an English label, the day one is contributed, would be
a translation Ekwo makes rather than a wording the law itself carries.

## Ekwo does not issue a Panamanian electronic invoice

**A Panamanian invoice belongs to the Sistema de Facturación Electrónica de
Panamá (SFEP), and it exists only once a Proveedor Autorizado Calificado
(PAC) or the Dirección General de Ingresos (DGI) has validated it.** The
obligation reached new taxpayers from 2022, government suppliers from
October 2023, independent professionals from 2024, and — under Resolución
N.° 201-6299 de 29 de julio de 2025, in force from 1 January 2026 — every
taxpayer above B/.36,000 of annual gross income or 100 monthly documents must
use a PAC exclusively. It is a clearance regime, like the CFDI of the Mexican
pack and the factura electrónica of the Colombian one, and not a peer-to-peer
exchange built on the semantic model of EN 16931.

Ekwo writes no XML of the Panamanian invoice, talks to no PAC or DGI endpoint
and computes no Código Único de Factura Electrónica (CUFE). So:

- `einvoicing` names **no profile and no date**, although the obligation
  exists. `profile` is a profile built on EN 16931 that a brick of
  `packages/formats/` writes (`peppol-bis-3`, `factur-x-en16931`, `xrechnung`,
  a PINT), and the Panamanian electronic invoice is none of them; the format
  also has no word for "valid only once a third party validates it". Its
  legal reference says what the phased obligation requires and says in
  capitals that Ekwo neither generates, computes the CUFE for, nor transmits
  a Panamanian electronic invoice.
- Every document carries the mention `sfep_not_cleared`: *this document is
  not an SFEP invoice; only the CUFE-carrying, validated invoice supports the
  operation for tax purposes.*
- The number a document gets in Ekwo is the consecutive of the accounting
  entry, and not the CUFE, which only a validation assigns.
- The Registro Único de Contribuyente (RUC) has no ISO 6523 scheme
  registered, so `party_scheme` and `vat_scheme` stay null, for the same
  reason as in the Mexican and Colombian packs.

What a company does today: validate the invoice through a PAC or the DGI's
free tool, and record the transaction in Ekwo. See *What the core could not
say* below.

## Sources

Every rate, box, mention and statement carries its own `legal_reference` and
the key of the text it is in. The register in `pack.json` holds fourteen
texts, every one opened on 26 September 2026: the Código Fiscal itself (Ley
8 de 1956) and the six laws that added or reformed article 1057-V — Ley 75 de
1976, Ley 61 de 2002, Ley 6 de 2005, Ley 49 de 2009, Ley 8 de 2010 and Ley 33
de 2010, all hosted by the DGI's own `Normativa` page; the DGI's
*Generalidades del ITBMS* and *Servicios exentos* pages; the Instructivo V6
and the Formulario 430 itself; the e-Tax 2.0 portal, where the return is
filed; the DGI's legal-basis page for electronic invoicing; and, for the
chart and the statements, the Colegio de Contadores Públicos Autorizados de
Panamá's own account of Resolución N.° 03-2010 of the Junta Técnica de
Contabilidad.

**One reading could not be verified against the primary Gaceta Oficial
text.** Resolución N.° 03-2010 de 28 de octubre de 2010, which the Junta
Técnica de Contabilidad used to adopt the NIIF para las PYMES, is cited here
through the Colegio de Contadores Públicos Autorizados de Panamá's own
article rather than through the Ministerio de Comercio e Industrias' Gaceta
Oficial text, which this pack's author could not locate online. A reviewer
who holds the primary text is asked to replace the citation.

## The chart of accounts

**Panama imposes no chart of accounts.** No statute or regulation found for
this pack fixes an account numbering for a Panamanian company; the Junta
Técnica de Contabilidad's Resolución N.° 03-2010 fixes only the reporting
*framework* — the NIIF para las PYMES — for a general-purpose financial
statement, the way Decreto 2420 de 2015 does in Colombia and the SAT's código
agrupador does in Mexico. This pack therefore uses, as its own catalogue, a
selection of 151 codes (headings included) grouped by the sections of that
framework — current and non-current assets, current and non-current
liabilities, equity, income and expense by function — exactly as the Mexican
and Colombian packs use their own reference numbering: the grouping is this
pack's own, not a legal obligation to use precisely this numbering.

Four decisions:

- **The ITBMS accounts split by posting side.** `240501` *ITBMS débito
  fiscal* is where a sale's tax posts, at any of the three rates; `139501`
  *ITBMS crédito fiscal* is where a deductible purchase's tax posts. Neither
  is the settlement account.
- **The declaration settles to `241501`** *ITBMS por pagar al Tesoro
  Nacional* (`tax_payable`) **or to `139502`** *ITBMS a favor del
  contribuyente* (`tax_receivable`) — both apart from the two accounts a tax
  posts to, and both reconcilable, the other two accounts clients (`130501`)
  and suppliers (`220501`) reconcile against — see the note on `reconcilable`
  in [`docs/packs.md`](../../docs/packs.md).
- **The suspense account is `280501`**, a dedicated *cuenta de orden* this
  pack's own catalogue carries for exactly this: nothing in the sources read
  names an official one.
- **`629905`**, under *Gastos de venta*, is the rounding account, for the
  same reason.

## The financial statements

`PA-NIIFPYME-ESF` (estado de situación financiera) and `PA-NIIFPYME-ERI`
(estado de resultado integral) are not a transcription of the full NIIF para
las PYMES presentation, whose disclosure notes belong to a professional who
prepares them. They group this pack's own catalogue by the sections sections
4 and 5 of that standard define — current and non-current assets and
liabilities, equity, revenue, cost of sales and expense by function — in an
abridged shape comparable to the one the Colombian pack uses for a Group 3
microempresa. A company that needs the full NIIF para las PYMES presentation
has a chart and a figure to start from, not a finished filing. `xbrl` is null
everywhere: no Panamanian taxonomy is mapped.

## Taxes

| Code | Rate | Treatment | Declaration fields |
|---|---|---|---|
| `PA-S-7` | 7 % | domestic sale (general) | 11 / 111 |
| `PA-S-10-ALC` | 10 % | domestic sale, bebidas alcohólicas | 13 / 131 |
| `PA-S-10-HOSP` | 10 % | domestic sale, hospedaje | 14 / 141 |
| `PA-S-15-TAB` | 15 % | domestic sale, tabaco | 15 / 151 |
| `PA-S-EXP` | 0 % | export | 16 |
| `PA-S-EXE` | 0 % | domestic sale, exempt (parágrafo 8) | 17 |
| `PA-S-NG` | 0 % | domestic sale, not subject (parágrafo 7) | 18 |
| `PA-P-7` | 7 % | domestic purchase, with credit | 222 / 223 |
| `PA-P-10` | 10 % | domestic purchase, with credit | 232 / 233 |
| `PA-P-15` | 15 % | domestic purchase, with credit | 242 / 243 |
| `PA-P-7-NOCRED` | 7 % | domestic purchase, without credit | 34 |
| `PA-P-EXE` | 0 % | domestic purchase, exempt | 39 |

**Panama is outside the common system of VAT.**
`supabase/seed/00_territories.sql` carries a row for `PA` with
`eu_vat_scope: none`. Consequently `exemption_code` stays null on every tax —
the VATEX list belongs to a system Panama is not in — the article goes in
`legal_reference` instead, the five `intracom_*` treatments are never used,
and `vat_category` is not declared, since the pack names no
`einvoicing.profile` (see above).

**Three rates share one word, `domestic`, because the ITBMS has no separate
vocabulary for "alcohol" or "tobacco".** What tells `PA-S-10-ALC` apart from
`PA-S-10-HOSP` — both taxed at 10 % — is the box each reaches: Formulario 430
carries the two on different casillas (13 and 14), because the numerals of
parágrafos 1 and 6 of article 1057-V that set them are different rules of
law, not one rate applied to two goods.

**Recoverable and not.** `PA-P-7-NOCRED` mirrors the Peruvian pack's
`PE-C-18-NOCRED`: a purchase taxed at 7 % but destined directly to an exempt
operation gives no credit (parágrafo 12), and the tax is booked with a
`tax_on_base` posting, which carries no account of its own and lands on the
cost of the line it taxes — Formulario 430's casilla 34 has no paired tax
casilla for exactly that reason.

**Not here:** the retention mechanisms the DGI has progressively widened
since 2016 (Resolución 201-8066 de 2023 and its predecessors, government and
large-taxpayer agents that withhold a share of the ITBMS invoiced to them,
credited through Anexo 95 of Formulario 430) and the income-tax withholding
on payments abroad. A company subject to either needs a professional's help
until a later version of this pack, or a dedicated retention pack, carries
them. See *What the core could not say*.

## The declaration

`PA-DGI-430` is Formulario 430, filed monthly by every company (Instructivo
V6, section B) — the pack proposes `month` as `period_default` for that
reason, and lists `quarter` beside it because a natural person who provides
independent professional services files quarterly instead, a fact about the
taxpayer this pack does not answer for everybody. The pack states
twenty-nine of the form's casillas: the ones its taxes actually reach.

The real Formulario 430 is considerably larger than what this pack declares.
Left out, and left for a company to add by hand when filing: returns and
discounts on sales and purchases (casillas 20, 201, 402, 403); the local
purchase / import split inside every rate bucket (22 and 221 against 222,
similarly for 10 % and 15 %); purchases apportioned between taxed and exempt
operations, which the form works out with a ratio this format has no
expression for (casillas 26 to 37, 41, 43, 47); the credit carried from the
prior period (casilla 51); withholding credits, with their own annex
(casilla 52); the export credit claimed through a Certificado con Poder
Cancelatorio rather than used directly (casilla 53); and the surcharge, fine
and interest a late filing draws (casillas 56 to 58). A company whose year
needs any of these has a base to start from, not a finished return.

- **Deadline.** `day_of_month_after_period`, day 15: the Código Fiscal,
  article 1057-V, parágrafo 11, charges a 10 % surcharge on a return with tax
  due filed more than fifteen days after the period ends, which fixes the
  ordinary filing day at the fifteenth of the following month.
- **Rounding.** Not declared: nothing read states the form is filed in a
  coarser unit than the cent of the balboa/US dollar.

## The golden year

A trading company, filing monthly, January to March 2026: twelve documents
and five payments. It sells general merchandise at 7 %, alcoholic beverages
at 10 %, a night's lodging at 10 %, cigarettes at 15 %, exports goods at 0 %,
and sells an exempt health service; it credits back part of the 7 % sale. It
buys general merchandise, drink supplies and cigarettes for resale with a
right to credit at each of the three rates, buys taxed medical supplies
destined directly to the exempt health service — without a right to credit —
and buys an exempt good outright. Two payments settle their invoice exactly,
one is an advance with no invoice to match, left open on purpose, and two
settle purchases, one of them the non-recoverable one, whose ITBMS stayed in
the cost paid.

Every figure of `golden/vat_return.json`, `golden/statements.json` and
`golden/trial_balance.json` was checked by hand against the scenario before
this pack was committed — not only replayed by `tests/golden.test.ts`.

## What the core could not say

The Panamanian section of
[`docs/international.md`](../../docs/international.md) states each of these
as a change to the core. In short:

1. **Clearance.** `einvoicing` can say "mandatory" only for a profile built
   on EN 16931, and has no way to say "valid only once a PAC or the DGI
   validates it"; the pack leaves the fields empty and says why in the
   reference, exactly as the Mexican and Colombian packs do.
2. **A service tax point with a third anchor.** `tax_point` names one word
   for the whole country; article 1057-V, parágrafo 2, gives goods two
   anchors (invoice or delivery, whichever comes first — `invoice_if_issued`)
   and services a different pair (completion of the service, or receipt of
   payment), which the closed vocabulary of this one column cannot both
   carry at once.
3. **A ratio the declaration itself computes.** The proportional credit of
   casillas 26 to 37, 43 and 47 divides one box by another; `tax_report.json`
   has `rate_of` for a rate applied to a box, and no operator for a box
   divided by a box.
4. **Withholding, on its own annex.** The retention mechanisms of ITBMS and
   the Anexo 95 credit they feed are a different mechanism from a tax a
   document posts, the same gap the Colombian pack states for ReteIVA.

## For a reviewer

The first things to read against practice: whether `PA-S-10-ALC` and
`PA-S-10-HOSP` should stay two codes at one rate, rather than one; the choice
of a dedicated `280501` for suspense and `629905` for rounding, where no
source read names an official account for either; whether `PA-P-7-NOCRED`
reads article 1057-V, parágrafo 12, correctly; and the citation of
Resolución N.° 03-2010 through a secondary source rather than the Gaceta
Oficial text — see *Sources* above.
