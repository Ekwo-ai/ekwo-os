# Colombia

Everything Colombia adds to Ekwo, as data: a chart of accounts built on the
nomenclature of the Plan Único de Cuentas, the journals, the value added tax
(impuesto sobre las ventas — IVA) at its general and reduced rates, an export
exemption and an exclusion, the fields of Formulario 300, a minimal balance
sheet and income statement, and the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Colombian accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

**Status: `community`.** Nobody who files a Colombian return has reviewed it.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language.** The pack's own labels are written in Spanish (`defaults.language:
"es"`), and `languages` is empty: no second wording is declared yet. The two
official reference texts this pack builds its statements on — Decreto 2650 de
1993 and Decreto 2706 de 2012 — have no English translation of their own, so
an English label, the day one is contributed, would be a translation Ekwo
makes rather than a wording the law itself carries; the accounts and boxes
below are numbered and named exactly as those decrees number and name them.

## Ekwo does not issue a Colombian electronic invoice

**A Colombian invoice is a factura electrónica de venta, and it exists only
once the DIAN has validated it.** Estatuto Tributario, art. 616-1, and
Resolución DIAN 000165 de 2023: before it can be issued, the document is sent
to the DIAN — or to an authorised technology provider — for validación previa,
which checks it against the technical annex and assigns the Código Único de
Factura Electrónica (CUFE), a 96-character cryptographic digest. It is a
clearance regime, like the CFDI of the Mexican pack, and not a peer-to-peer
exchange built on the semantic model of EN 16931.

Ekwo writes no UBL XML of the Colombian invoice, talks to no DIAN endpoint and
computes no CUFE. So:

- `einvoicing` names **no profile and no date**, although the obligation
  exists. `profile` is a profile built on EN 16931 that a brick of
  `packages/formats/` writes (`peppol-bis-3`, `factur-x-en16931`, `xrechnung`,
  a PINT), and the Colombian factura electrónica is none of them; the format
  also has no word for "valid only once a third party validates it". Its
  legal reference says what the law requires and says in capitals that Ekwo
  neither generates, computes the CUFE for, nor transmits a Colombian
  electronic invoice.
- Every document carries the mention `cufe_not_assigned`: *this document is
  not an electronic invoice; only the DIAN-validated invoice, carrying its
  CUFE, supports the operation for tax purposes.*
- The number a document gets in Ekwo is the consecutive of the accounting
  entry — a real requirement of art. 617, literal d), and of the numbering
  ranges Resolución 000165 authorises — and not the CUFE, which only a
  validation assigns.
- The Número de Identificación Tributaria (NIT) has no ISO 6523 scheme
  registered, so `party_scheme` and `vat_scheme` stay null, for the same
  reason as in the Mexican pack.

What a company does today: validate the invoice through the DIAN's free
service or an authorised technology provider, and record the transaction in
Ekwo. See *What the core could not say* below.

## Sources

Every rate, box, mention and statement carries its own `legal_reference` and
the key of the text it is in. The register in `pack.json` holds ten texts,
every one opened on 25 September 2026: the DIAN's own compilation of the
Estatuto Tributario Nacional; Decreto 1625 de 2016, the Decreto Único
Reglamentario that fixes the tax calendar; Formulario 300 and its
instructivo; Resolución DIAN 000165 de 2023 and its Anexo Técnico of
Documento Equivalente Electrónico; the DIAN's own pages on validación previa
and on the tax calendar; and, for the chart and the statements, Decreto 2650
de 1993 (Superintendencia de Sociedades), Decreto 2420 de 2015 and Decreto
2706 de 2012 (Función Pública — Gestor Normativo).

The DIAN's `normograma.dian.gov.co` and the Función Pública `gestornormativo`
are the two consolidated legal databases of the Colombian government; this
register cites them the way the Mexican pack cites the Cámara de Diputados
and the SAT.

## The chart of accounts

**Colombia does not, since 2015, impose a single chart of accounts on every
company.** Decreto 2650 de 1993 made the Plan Único de Cuentas (PUC)
compulsory for every merchant, but Ley 1314 de 2009 and Decreto 2420 de 2015
converged Colombian accounting to the International Financial Reporting
Standards: a preparer of Groups 1 and 2 defines its own chart, and the
Consejo Técnico de la Contaduría Pública has said it is not competent to rule
on whether Decreto 2650 remains in force for anyone else. What has not
changed is practice: almost every Colombian accounting package, and the
DIAN's own reporting of información exógena, still keys its accounts to the
PUC numbering. This pack uses that numbering as its own catalogue — a
selection of 129 codes, headings included — exactly as the Mexican pack uses
the SAT's código agrupador: the identity of code and of name is the
association, not a legal obligation to use precisely this numbering.

Selected: cash, banks, customers, sundry debtors, the IVA control accounts,
inventory, the usual fixed assets and their accumulated depreciation,
suppliers, payroll provisions, retained earnings and the current year's
result apart from it, revenue by kind, the direct costs and purchases of a
trading company, and the general expenses it needs. Left out: the sector and
related-party variants the PUC carries for financial, insurance and
cooperative entities (which keep their own charts by special legislation),
the manufacturing cost classes 7, and the cuentas de orden of classes 8 and 9,
which are memorandum accounts outside any financial statement.

Four decisions:

- **The IVA accounts split generated from descontable, and by rate.** `2408`
  *Impuesto sobre las ventas por pagar* is the heading; `240805` and `240810`
  are where a sale's tax posts, at the general rate and at 5 %; `240815` and
  `240820` are where a deductible purchase's tax posts. None of the four is
  the settlement account.
- **The declaration settles to `240825`** *Saldo a pagar impuesto sobre las
  ventas* (`tax_payable`) **or to `135520`** *Sobrantes en liquidación privada
  de impuestos* (`tax_receivable`) — the PUC's own account for a surplus a
  taxpayer's private return determines, which is what a period ending in
  credit is. Both are apart from the four accounts a tax posts to and both are
  reconcilable, the other two accounts clients (`1305`) and suppliers
  (`2205`) reconcile against — see the note on `reconcilable` in
  [`docs/packs.md`](../../docs/packs.md).
- **The suspense account is `2815`** *Ingresos recibidos para terceros*: the
  PUC carries no dedicated compte d'attente, and this is the closest official
  account to money held for somebody else's classification.
- **`429581`** *Ajuste al peso*, under *Ingresos — Diversos*, is the rounding
  account: the PUC names it for exactly this.

## The financial statements

`CO-DECRETO2649-ESF` (estado de situación financiera) and
`CO-DECRETO2649-ER` (estado de resultado integral) are not a transcription of
the full NIIF presentation of Groups 1 and 2, whose disclosure notes and
disaggregation belong to a professional who prepares them. They read the PUC
classes and groups the way Decreto 2650, art. 4, itself defines them — classes
1, 2 and 3 make the balance sheet, classes 4, 5 and 6 the income statement —
in the abridged shape Decreto 2706 de 2012 prescribes for a Group 3
microempresa: one line per group, four subtotals, and a single result. A
company that needs the full statement of Groups 1 or 2 has a chart and a
figure to start from, not a finished filing. `xbrl` is null everywhere: no
Colombian taxonomy is mapped.

## Taxes

| Code | Rate | Treatment | Declaration fields |
|---|---|---|---|
| `CO-S-19` | 19 % | domestic sale | 28 / 59 |
| `CO-S-5` | 5 % | domestic sale (art. 468-1) | 27 / 58 |
| `CO-S-EXE` | 0 % | domestic sale, exento (art. 477) | 35 |
| `CO-S-EXP` | 0 % | export (art. 481, lit. a) | 30 |
| `CO-S-EXC` | — | excluido (art. 424) | 39 |
| `CO-P-19` | 19 % | domestic purchase, goods | 51 / 72 |
| `CO-P-19-SERV` | 19 % | domestic purchase, services | 53 / 75 |
| `CO-P-5` | 5 % | domestic purchase, goods (art. 468-1) | 50 / 71 |
| `CO-P-EXC` | — | excluded/exempt/untaxed purchase | 54 |

**Exento is not excluido, and the format tells the two apart by treatment.**
A bien exento (art. 477 — the pack's example is fresh milk, tariff heading
04.01) is taxed at zero and still gives its producer the right to deduct and
recover the input tax (art. 489): the pack declares it `domestic` at `rate:
0`, `vat_category: Z` — the same shape as a British zero-rated good. A bien
excluido (art. 424 — the pack's example is potatoes, a canasta familiar
product in its natural state) does not cause the tax at all and gives no
right to deduct anything paid to produce it (art. 491): the pack declares it
`treatment: exempt`, `vat_category: E`, which is the only bucket of the
format's closed vocabulary that matches "no tax, no deduction". Getting the
two the wrong way round would have been the easiest mistake this pack could
make, so it is written out here for whoever reviews it next.

**Colombia is outside the common system of VAT.** `supabase/seed/00_territories.sql`
carries a row for `CO` with `eu_vat_scope: none`. Consequently `exemption_code`
stays null on every tax — the VATEX list belongs to a system Colombia is not
in — the article goes in `legal_reference` instead, the five `intracom_*`
treatments are never used, and `vat_category` is declared even though no
column of the format requires it (the pack names no `einvoicing.profile`):
purely for the reader, the way the Mexican pack does.

**Goods and services split on the purchase side, not on the sale side.**
Formulario 300 asks for the taxable base of a sale at one rate in a single
box regardless of what was sold (27 or 28), but splits a national purchase
into bienes (50, 51) and servicios (52, 53) — and the corresponding
descontable boxes (71, 72 against 74, 75). That is why `CO-P-19` and
`CO-P-19-SERV` are two codes at the same 19 % rate rather than one: the box a
purchase reaches depends on what was bought, not on its rate, and one tax
carries one box.

**Not here:** the retention regimes — ReteIVA (a 15 % withholding of the IVA
already invoiced, Estatuto Tributario arts. 437-1 and 437-2), ReteFuente
(income-tax withholding, a different tax base entirely) and ICA (Impuesto de
Industria y Comercio, a municipal tax with a rate set by each of Colombia's
more than one thousand municipalities) — and the 100 % self-withholding on
services received from a non-domiciled supplier (art. 437-2, numeral 3),
which Formulario 300 itself declares through casilla 78 as a *retención
asumida*, i.e. computed and paid through the separate retention mechanism
(Formulario 350) that this pack does not model. A company that practises any
of the three needs a professional's help until a later version of this pack,
or a dedicated retention pack, carries them. See *What the core could not
say*.

## The declaration

`CO-VAT-300` is Formulario 300, filed bimonthly or four-monthly depending on
the taxpayer's revenue in the preceding year (Estatuto Tributario, art. 600)
— a fact about the company the pack cannot answer for everybody, so it
declares no `period_default`, the same reasoning as the Luxembourg pack. The
pack states nineteen of the form's boxes: the ones its taxes actually reach.
The prior-period carry-forward (casilla 84), third-party withholdings
(85, 78), penalties (87) and the refund/offset control section (90–93) are
not modelled — they depend on facts outside a single period's ledger, a
figure from a previous declaration, a certificate a customer issued, an
amount the taxpayer computes — and are left for the company to add by hand
when filing, exactly as the boxes a form asks for and a ledger cannot answer
are left everywhere else in this repository.

- **Rounding.** The instructivo of Formulario 300 states it directly: every
  box is rounded to the nearest thousand pesos. `rounding.unit: 1000`, cited
  to the instructivo and to Estatuto Tributario, art. 868.
- **Deadline.** `depends_on_taxpayer`: Decreto 1625 de 2016 assigns the day by
  the last digit of the NIT, and reassigns the actual dates every year through
  the decree that fixes the following year's tax calendar.

## The golden year

A trading company (comercializadora), filing bimonthly, January to April
2026: twelve documents and five payments. It sells general merchandise at
19 %, roasted coffee at 5 %, potatoes excluded from the tax, exports goods
exempt with a right to refund, and sells fresh milk exempt with the same
right; it credits back part of the 19 % sale. It buys general merchandise and
roasted coffee for resale, a warehousing service at the general rate — which
lands in the services box rather than the goods one — and potatoes excluded.
One payment matches its invoice exactly, one settles an export, one pays a
supplier, one is an advance with no invoice to match, left open on purpose,
and the second bimonthly period is deliberately built so its purchases
outweigh its sales, to exercise a saldo a favor (casilla 83) rather than only
a saldo a pagar.

Every figure of `golden/vat_return.json`, `golden/statements.json` and
`golden/trial_balance.json` was checked by hand against the scenario before
this pack was committed — not only replayed by `tests/golden.test.ts`.

## What the core could not say

The Colombian section of [`docs/international.md`](../../docs/international.md)
states each of these as a change to the core. In short:

1. **Clearance.** `einvoicing` can say "mandatory" only for a profile built on
   EN 16931, and has no way to say "valid only once the DIAN validates it";
   the pack leaves the fields empty and says why in the reference, exactly as
   the Mexican pack does for the CFDI.
2. **A retention paid on a different form.** Casilla 78 of Formulario 300 is
   fed by a withholding computed and paid through the separate retention
   return (Formulario 350), which this repository has no second declaration
   for.
3. **A municipal tax the core has no place for.** ICA is a value set by each
   municipality, in the hundreds — the same reason American sales tax rates
   are not in a pack.
4. **Two forms this pack does not carry**: Formulario 350 (retenciones) and
   the información exógena that keys accounts to the PUC's grouping.

## For a reviewer

The first things to read against practice: the split between a bien exento
(art. 477) and a bien excluido (art. 424), and whether `domestic` at zero
against `exempt` is the right pair for it; the choice of `2815` for suspense
and `429581` for rounding, where the PUC names no dedicated account for
either; the goods/services split of the purchase-side taxes against boxes 71,
72, 74 and 75; and whether the abridged Decreto 2706 statements should give
way to a mapping of the full NIIF presentation by a professional who holds
it.
