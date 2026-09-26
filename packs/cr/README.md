# Costa Rica

Everything Costa Rica adds to Ekwo, as data: a chart of accounts built on the
minimum content the Código de Comercio sets for the year-end books, the
journals, the Impuesto sobre el Valor Agregado (IVA) at its general and
reduced rates, an export exemption with full credit, an ordinary exemption
without it, the fields of the monthly IVA declaration, a minimal balance
sheet and income statement, and the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Costa Rican accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

**Status: `community`.** Nobody who files a Costa Rican return has reviewed
it. The figures are replayed against a month of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**Language.** The pack's own labels are written in Spanish (`defaults.language:
"es"`), and `languages` is empty: no second wording is declared yet. The
Código de Comercio and the Ley del Impuesto al Valor Agregado have no official
English translation, so an English label, the day one is contributed, would be
a translation Ekwo makes rather than a wording the law itself carries.

## Ekwo does not issue a Costa Rican electronic invoice

**A Costa Rican invoice is a comprobante electrónico, and it exists only once
the Ministerio de Hacienda has validated it.** The Reglamento de Comprobantes
Electrónicos para Efectos Tributarios (Decreto 44739-H) and the Resolución
General MH-DGT-RES-0027-2024 require every comprobante — built to the Anexos y
Estructuras version 4.4, obligatory since 1 September 2025 — to be signed and
transmitted to the Ministry's system before it can be delivered to the buyer.
The system validates it, assigns the fifty-digit clave numérica and returns an
acceptance, partial-acceptance or rejection message. It is a clearance regime,
like the CFDI of the Mexican pack or the factura electrónica of the Colombian
one, and not a peer-to-peer exchange built on the semantic model of EN 16931.

Ekwo writes no XML of the version 4.4 comprobante, talks to no Hacienda
endpoint and computes no clave numérica. So:

- `einvoicing` names **no profile and no date**, although the obligation
  exists. `profile` is a profile built on EN 16931 that a brick of
  `packages/formats/` writes (`peppol-bis-3`, `factur-x-en16931`, `xrechnung`,
  a PINT), and the Costa Rican comprobante is none of them; the format also
  has no word for "valid only once a third party validates it".
- Every document carries the mention `clave_no_asignada`: *this document is
  not an electronic voucher; only the voucher validated by Hacienda, carrying
  its clave numérica, supports the operation for tax purposes.*
- The number a document gets in Ekwo is the consecutive of the accounting
  entry and not the clave numérica, which only Hacienda's validation assigns.
- The cédula jurídica or física has no ISO 6523 scheme registered, so
  `party_scheme` and `vat_scheme` stay null, for the same reason as in the
  Mexican and Colombian packs.

What a company does today: issue the comprobante through a certified
technology provider or Hacienda's own free tool, and record the transaction in
Ekwo. See *What the core could not say* below.

## Sources

Every rate, box, mention and statement carries its own `legal_reference` and
the key of the text it is in. The register in `pack.json` holds eight texts,
every one opened on 26 September 2026: the Ley del Impuesto sobre el Valor
Agregado (Ley 6826, reformada por la Ley 9635) and its Reglamento (Decreto
41779-H), from the Sistema Costarricense de Información Jurídica (SCIJ) — the
consolidated legal database of the Costa Rican government; the Código de
Comercio (Ley 3284), also from SCIJ; the Resolución MH-DGT-RES-0033-2025 on
the IVA declaration forms, read from the Alcance a La Gaceta that publishes
it in full, Anexo included; the Reglamento and the Resolución on comprobantes
electrónicos; the TRIBU-CR portal page; and the Colegio de Contadores
Públicos de Costa Rica's own page on the NIIF for SMEs, cited but not
transcribed (see *The chart of accounts* below).

## The IVA declaration changed platform while this pack was written

Until 6 October 2025, the monthly return was filed on a platform called ATV
using form D-104. Resolución MH-DGT-RES-0033-2025 replaced both: the only
platform is now TRIBU-CR, and the general-regime form is simply named
**"Impuesto al Valor Agregado"** in its own Anexo 1 — not "D-104", not
"Formulario 150" (a number several accounting blogs use informally for the
system's internal identifier, which does not appear in the resolución
itself). `tax_report.json` names its fields exactly as Anexo 1 does — "Total
ventas a 13%", "Monto de impuesto a 13%", "Impuesto determinado", "Saldo a
favor" — because the form carries no box **numbers**, only these names; a
reader comparing this pack against the live TRIBU-CR form should look for the
label, not a number.

## The chart of accounts

**Costa Rica does not impose a chart of accounts on any company.** The
Código de Comercio, art. 251, only requires that the accounting records allow
the operations and the financial position to be known "de forma fácil, clara
y precisa", without needing to be legalised by anybody; art. 258 fixes the
minimum **content** asserted at each year-end close — a Balance de
Comprobación, an Estado de Ganancias y Pérdidas, a Balance General de
Situación and, for a company, an Estado de superávit — and nothing about how
accounts are numbered. The professional framework is the NIIF and the NIIF
for SMEs, adopted by the Colegio de Contadores Públicos de Costa Rica (CCPA),
a professional body and not a organ of the State; its text and the IASB's
belong to them and are not transcribed here, exactly as the Argentine pack
does with the FACPCE's Resoluciones Técnicas.

This pack's chart is therefore **original**: a numbering of its own, three to
five digits, where each group of codes corresponds to one line of
`CR-CCOM-ESF` or of `CR-CCOM-ER`, so the accounts read directly onto those two
schemes. 126 accounts: cash, banks, customers, sundry debtors, the IVA control
accounts split by rate (crédito fiscal 13/4/2/1%, débito fiscal 13/4/2/1%,
separate from the settlement account), inventory, the usual fixed assets and
their accumulated depreciation, suppliers, the payroll provisions a Costa
Rican employer carries (CCSS charges, aguinaldo, vacaciones, cesantía),
retained earnings apart from the current year's result, revenue by kind, the
direct costs and purchases of a trading company, and the general expenses it
needs.

Two decisions:

- **The IVA control accounts split by rate on both sides, and the settlement
  account is apart from all eight of them.** `2131`-`2134` are where a sale's
  tax posts (13%, 4%, 2%, 1%); `1151`-`1154` are where a deductible purchase's
  tax posts, at the same four rates. `2135`, *IVA por pagar* (`tax_payable`),
  and `1155`, *IVA saldo a favor* (`tax_receivable`), are the two the monthly
  declaration settles to, and are the only two of the group that are
  `reconcilable` — see the note on `reconcilable` in
  [`docs/packs.md`](../../docs/packs.md).
- **The suspense account is `117`**, *Partidas pendientes de imputación*: the
  chart being original, there is no official account to defer to, and the
  name is chosen to read as a working, temporary line and nothing else — the
  same role AR's own original chart gives its `117`.

## The financial statements

`CR-CCOM-ESF` (Balance General de Situación) and `CR-CCOM-ER` (Estado de
Ganancias y Pérdidas) are not a transcription of a full NIIF presentation,
whose disclosure notes and disaggregation belong to a professional who
prepares them. They read the chart's own groups the way the Código de
Comercio's art. 258 names the two statements it requires, in the abridged
shape a small trading company needs: one line per group, three subtotals and
a single result. `xbrl` is null everywhere: no Costa Rican taxonomy is
mapped, and none is imposed by the State.

## Taxes

| Code | Rate | Treatment | Declaration fields |
|---|---|---|---|
| `CR-S-13` | 13% | domestic sale, general | Total/Monto de impuesto a 13% |
| `CR-S-4` | 4% | domestic sale — private health services | Total/Monto de impuesto a 4% |
| `CR-S-2` | 2% | domestic sale — medicines | Total/Monto de impuesto a 2% |
| `CR-S-1` | 1% | domestic sale — Canasta Básica Tributaria | Total/Monto de impuesto a 1% |
| `CR-S-EXP` | 0% | export, full credit | Total ventas exentas con derecho a crédito pleno |
| `CR-S-EXE` | 0% | exempt, no credit — books | Total ventas exentas sin derecho a crédito |
| `CR-P-13` | 13% | domestic purchase, recoverable | Total importe/Impuesto soportado a 13% |
| `CR-P-2` | 2% | domestic purchase, recoverable | Total importe/Impuesto soportado a 2% |
| `CR-P-EXE` | 0% | exempt purchase, not recoverable | Bienes y servicios exentos |

**An export is not an ordinary exemption, and the Reglamento tells the two
apart by the right to credit.** The general rule of art. 30, numeral 1, of
the Reglamento is that only a taxable, non-exempt sale gives its seller the
right to deduct the IVA paid on what fed it; numeral 2 of the same article
carves out a short list of exceptions that keep that right despite being
exempt — among them the exportations of numeral 1 of art. 8 of the Law,
sales to the Caja Costarricense de Seguro Social, sales to Zona Franca
beneficiaries. This pack's `CR-S-EXP` is that exception: `treatment: export`,
posted to "Total ventas exentas con derecho a crédito pleno". An ordinary
exemption that is **not** on that list — this pack's example is the sale of
books, Reglamento art. 11, numeral 4, inciso b) — falls under the general
rule instead: `treatment: exempt`, posted to "Total ventas exentas sin
derecho a crédito", and its purchase-side mirror, `CR-P-EXE`, is declared
`recoverable: false`. Getting the two the wrong way round would have been the
easiest mistake this pack could make, so it is written out here for whoever
reviews it next.

**Costa Rica is outside the common system of VAT.** `supabase/seed/00_territories.sql`
carries a row for `CR` with `eu_vat_scope: none`. Consequently `exemption_code`
stays null on every tax — the VATEX list belongs to a system Costa Rica is not
in — the article goes in `legal_reference` instead, and the five `intracom_*`
treatments are never used. `vat_category` is left out entirely: unlike the
Mexican and Colombian packs, this one names no `einvoicing.profile`, and the
column is documentary only where a profile is named — see the treatment table
of [`docs/packs.md`](../../docs/packs.md).

**Two transitional rates are not modelled.** Between 2019 and 2022, several
sectors moved to their final rate through intermediate steps of 0.5% and 3%
(Reglamento, Transitorios), which is why TRIBU-CR's own form still offers
them as options. Both expired before this pack's `released_at`, and a pack
transcribes the law in force, not its history — see
[`docs/international.md`](../../docs/international.md) if a company still
needs to file a corrective return for a period when they applied.

## The declaration

`CR-IVA` reads Anexo 1 of Resolución MH-DGT-RES-0033-2025, "Impuesto al Valor
Agregado", the form of the Régimen Tradicional. Filed monthly — Reglamento,
art. 24, "el período del impuesto es de un mes calendario" — with no choice
of cadence, so `period_default: month`. Deadline the fifteenth calendar day
of the following month (Resolución, art. 4, referring to art. 27 of the Law;
Reglamento, art. 40).

This pack declares the fields its taxes reach: the base and the tax at each
of the four rates, the two exempt-sale totals, the debit they add up to, the
purchase-side base and credit at 13% and 2%, and `Impuesto determinado` /
`Saldo a favor`, exactly the pair Colombia's Formulario 300 calls casilla 82
and 83. **Not modelled**: the proportionality mechanism of the form's section
II and III (a business with both taxed and exempt sales credits only the
share of its input tax that the proportion allows, computed provisionally
each month and settled definitively in December), the special régimen for
used goods, the special régimen for agriculture, the tax on casinos and games
of chance, the deferred payment of tax on credit sales, the self-assessment
("autorrepercusión") of tax on services bought from a non-domiciled supplier,
and the refund of IVA on card-paid private health services. Every one of them
depends on a fact a single period's ledger cannot answer by itself — a
proportion carried from prior months, a special registration, a card
payment's own record — the same reasoning Colombia's pack gives for the boxes
it leaves for the company to complete by hand.

## The golden month

A trading company, filing monthly, January 2026: nine documents and four
payments. It sells general merchandise at 13%, a private health service at
4%, medicines at 2%, a Canasta Básica Tributaria product at 1%, exports
specialty coffee exempt with full credit, and sells books exempt without it;
it credits back part of the 13% sale. It buys general merchandise and
medicines for resale, both with the right to deduct, and buys books for
resale, exempt and non-deductible. One payment matches a sale exactly, one
collects the export, one pays a supplier, and one is a customer's advance
with no invoice to match, left open on purpose, the way a real ledger holds
one.

Every figure of `golden/vat_return.json`, `golden/statements.json` and
`golden/trial_balance.json` was checked by hand against the scenario before
this pack was committed — not only replayed by `tests/golden.test.ts`. By
hand: `V13` net of the credit note is ₡450,000 and `T13` is ₡58,500; `DEBITO`
is ₡70,500 (₡58,500 + ₡8,000 + ₡3,000 + ₡1,000); `CFTOTAL` is ₡40,600
(₡39,000 + ₡1,600); `Impuesto determinado` is ₡29,900 and `Saldo a favor` is
zero.

## What the core could not say

The Costa Rican section of [`docs/international.md`](../../docs/international.md)
states each of these as a change to the core. In short:

1. **Clearance.** `einvoicing` can say "mandatory" only for a profile built on
   EN 16931, and has no way to say "valid only once Hacienda validates it";
   the pack leaves the fields empty and says why in the reference, exactly as
   the Mexican and Colombian packs do.
2. **Proportional credit.** A tax's `recoverable` flag is binary; TRIBU-CR's
   own form computes a provisional proportion every month and a definitive
   one every December for a business that mixes taxed and exempt sales. This
   pack models only the two ends of that spectrum — wholly recoverable,
   wholly not — and a mixed business needs a professional's proportion until
   the core can hold one.
3. **A form this pack does not carry**: the Régimen Especial de Bienes Usados
   and the Régimen Especial Agropecuario each file their own form (Anexos 2,
   3 and 4 of the same Resolución), which this repository has no second
   declaration for.

## For a reviewer

The first things to read against practice: the choice of books (Reglamento,
art. 11, numeral 4, inciso b) as the example of an exemption with no right to
credit, against export as the example of one that keeps it, and whether that
pair is the clearest one to teach the distinction; the field names of
`tax_report.json` against the live TRIBU-CR form, since the form carries no
box numbers to check them against, only labels; the choice of `117` and its
name for the suspense account, where no official chart names one; and
whether the abridged Código de Comercio statements should give way to a
mapping of the full NIIF presentation by a professional who holds it.
