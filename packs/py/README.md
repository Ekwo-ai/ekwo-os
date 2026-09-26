# Paraguay

Everything Paraguay adds to Ekwo, as data: an original chart of accounts built
on the minimum content the Ley del Comerciante and the Código Civil require
of a balance and a profit-and-loss account, the journals, the Impuesto al
Valor Agregado (IVA) with its two rates, its export and exemption codes, the
fields of the monthly Formulario N.° 120, a balance sheet and an income
statement, and the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content
came from and which decisions it rests on, so that a Paraguayan accountant
reading the pack can disagree with a specific sentence rather than with the
whole of it.

Language: Spanish (`es`), the language of the law and of the DNIT's own
forms. No official chart of accounts exists in any language for this pack to
carry a second wording of.

**Status: `community`.** Nobody who files a Paraguayan return has reviewed
it. The figures are replayed against a quarter of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

Paraguay is outside the common system of VAT of Directive 2006/112/EC, so
`supabase/seed/00_territories.sql` carries a row for `PY` with `eu_vat_scope`
`none`: no `exemption_code`, no `intracom_*` treatment, and `vat_category` is
not required since this pack declares no e-invoicing profile — see
[What a tax says on the invoice](../../docs/packs.md#what-a-tax-says-on-the-invoice-treatment-category-and-reason).

## Ekwo does not issue a Paraguayan comprobante de venta

**A Paraguayan sales voucher is, for a growing share of taxpayers, a
Documento Tributario Electrónico (DTE) of the Sistema Integrado de
Facturación Electrónica Nacional (SIFEN), whose public brand is e-Kuatia, and
it exists only once its signed XML has been validated by the DNIT.** Decreto
N.° 7.795/2017 creates the SIFEN and, in its article 2°, defines the DTE as
the document issued by an electronic invoicer with a digital signature,
formally validated by the tax administration, that supports the IVA débito
and crédito of the operation. The administration phases the obligation in
through a pilot stage, a voluntary-adhesion stage and a mandatory stage,
group by group; successive general resolutions (among them N.° 95/2021) have
incorporated further groups, and from January 2026 the obligation reaches
government suppliers and the groups the DNIT has added for 2026 and 2027.
This is a clearance model — the SIFEN validates the DTE, before or after its
delivery to the recipient depending on the approval model chosen, and not a
direct exchange between the two parties to the sale.

Ekwo writes no XML of a DTE, signs nothing digitally and talks to no SIFEN
endpoint. So:

- `einvoicing` names **no profile and no date**, although the obligation
  exists and is expanding. `profile` is a profile built on EN 16931 that a
  brick of `packages/formats/` writes and transmits over Peppol, and the
  Paraguayan DTE is neither; the format has no word for "valid only once the
  SIFEN has validated it". Its legal reference says what the rules require
  and says in as many words that Ekwo neither generates, signs nor transmits
  one. Peru, Argentina and Mexico leave the profile empty for the same
  reason.
- Every document carries the mention `dte_not_issued`: *this document is not
  a Documento Tributario Electrónico; only the one approved by the SIFEN, or
  a timbrado sales voucher, supports the operation for tax purposes.*
- The number a document gets in Ekwo is the number of the accounting entry,
  correlative per journal (`numbering: gapless`), and not the
  timbrado-establecimiento-punto de expedición-número that the DNIT or the
  issuer's own SIFEN system assigns to the sales voucher itself.

What a company does today: issue the DTE through e-Kuatia, e-Kuatia'í or its
own SIFEN-compliant system, and record the transaction in Ekwo.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and the key of the text it is in. The register in `pack.json` holds eight
texts, every one opened on 26 September 2026: Ley N.° 6.380/2019 on the
DNIT's own legislation pages; Ley N.° 1.034/1983, Del Comerciante, on the
Congress's own archive (BACN); the Código Civil, Ley N.° 1.183/1985, hosted
by CONATEL; the DNIT's own instructivo of the Formulario N.° 120, Versión 4;
the DNIT's IVA page, which names the Marangatú system the declaration is
filed through; the DNIT's own Manual Técnico of the SIFEN, whose section 4.2
gives the system's legal basis; the DNIT's e-Kuatia page; and the DNIT's own
page on Resolución General N.° 38/2020, the Calendario Perpetuo de
Vencimientos.

## The chart of accounts

**Paraguay prescribes no catalogue of accounts of any kind.** Ley N.°
1.034/1983, art. 75, only requires every merchant above a capital threshold
to keep "indispensably a libro Diario and a libro Inventario"; art. 82 fixes
what the libro Inventario must show — the patrimonial situation at the start
of operations and, at the close of each exercise, the patrimonial situation
together with the "cuadro demostrativo de ganancias y pérdidas" — without
naming a single account. For a sociedad anónima, the Código Civil, art.
1079, adds that the ordinary assembly must consider the "balance y cuenta de
ganancias y pérdidas" of the exercise. This pack's chart is therefore
**original**: a three- to five-digit numbering of this pack's own, where
every block of codes corresponds directly to a line of `PY-ESP` or of
`PY-ER`, following the same method Argentina's pack used for the same
reason.

Four decisions:

- **The IVA control accounts are split into four accounts of this pack's
  own**: `2031` "IVA Débito Fiscal" and `1041` "IVA Crédito Fiscal" are
  posting accounts; `2032` "IVA a Pagar" (`tax_payable`, reconcilable) and
  `1042` "IVA Saldo a Favor del Contribuyente" (`tax_receivable`,
  reconcilable) are the settlement accounts the monthly declaration carries
  its net to. Ordinary Paraguayan bookkeeping often keeps fewer accounts than
  this; this pack keeps the posting accounts and the settlement accounts
  apart because the two have to be distinct accounts in Ekwo — see
  [Ajout 25/09 (2)](../../docs/packs.md) on the format side.
- **Only the customer, supplier and IVA-settlement accounts are
  `reconcilable`.** The headings and the documents receivable/payable of
  groups `102` and `201` are reconcilable too, because they are trade
  accounts of customers and suppliers, exactly the family the 25 September
  rule means.
- **The suspense account is `106` "Partidas pendientes de imputación".**
  Neither text names an account meant for items awaiting classification;
  this one is read on both sides by the statement rule that splits it.
- **The result of the year is kept apart in `351`/`352` until the assembly
  allocates it**, per art. 1079's own wording — "hasta que la asamblea
  resuelva su afectación" — so `closing_style` is `result_accounts`, the
  shape France's pack uses for the same reason.

## Taxes

| Code | Rate | Treatment | Declaration fields |
|---|---|---|---|
| `PY-V-10` | 10 % | domestic sale | 10/22, 15/23 (credit note) |
| `PY-V-5` | 5 % | domestic sale (canasta básica, inmuebles, medicamentos, pecuarios, vivienda) | 151/157, 16/20 (credit note) |
| `PY-V-EXP` | 0 % | export of goods | 14 |
| `PY-V-EXO` | — | exempt sale (art. 100) | 12, 17 (credit note) |
| `PY-C-10` | 10 % | domestic purchase, with input tax credit | 35/38 (credit note: same boxes, negative) |
| `PY-C-5` | 5 % | domestic purchase, with input tax credit | 32/38 (credit note: same boxes, negative) |
| `PY-C-10-NOCRED` | 10 %, non-deductible | purchase destined to an exempt sale | 59, tax on cost (65) |
| `PY-C-5-NOCRED` | 5 %, non-deductible | purchase destined to an exempt sale | 60, tax on cost (66) |
| `PY-C-EXO` | — | domestic purchase, not taxed | 62 |

**The 5 % rate does not distinguish agricultural products in their natural
state from the pack's other 5 % goods.** Ley N.° 6.380/2019, art. 90, sets 5
% for five different incisos — a), housing rentals; b), real estate; c), the
canasta familiar; d), agricultural, horticultural, fruit and livestock
products; e) and f), livestock derivatives and medicines — and the
Formulario N.° 120 gives inciso d) its own boxes (150/156) because an export
of those specific goods carries no right to a crédito fiscal refund under
art. 101. `PY-V-5` and `PY-C-5` declare the other incisos, on boxes 151/157
and 32/38; a pack that needed to model the export of agricultural products in
their natural state would need a further code posting to 150/156 and to the
Anexo del Exportador — see *What the core could not say*.

**Tax point.** Ley N.° 6.380/2019, art. 83, numeral 1, fixes the hecho
imponible at the first of three events: delivery or the rendering of the
service; collection of the full price or of a partial payment; or the expiry
of the term set for payment. The first two are `earliest_of_delivery_or_payment`
in this format's vocabulary; the third — a term expiring with neither
delivery nor collection — has no word of its own and is not represented,
because no vocabulary word in this format captures "or the expiry of a
payment term, whichever is earliest still". Art. 92 further requires the
sales voucher to be issued exactly when the obligation is born (except for
the supply, import and foreign-service cases of art. 83, numerals 4 to 6),
so a company relying on that third leg alone will see this pack's tax point
lag its real one until a payment term actually expires.

**The non-deductible purchases, `PY-C-10-NOCRED` and `PY-C-5-NOCRED`.** Art.
89, numeral 1, ties the input tax credit to the purchase being affected,
directly or indistinctly, to a taxed operation; art. 91 turns the IVA of a
purchase destined to an exempt or out-of-scope sale into a cost or an
expense for the Impuesto a la Renta Empresarial. The Formulario N.° 120 has
boxes for both the base and the IVA of such a purchase (59/65 at 10 %,
60/66 at 5 %), which this pack mirrors with a `tax_on_base` posting that
carries a box, unlike Peru's equivalent code, whose form has no box for the
tax itself.

## The declaration

`PY-F120` is the Formulario N.° 120, filed monthly on the Sistema de Gestión
Tributaria Marangatú. Its fields are casillas rather than numbered boxes of
a printed form; this pack names the ones its own tax codes need — 10/22 and
151/157 for the two rates of domestic sales, 15/23 and 16/20 for their
adjustments, 12 and 17 for exempt sales and their adjustments, 14 for
exports, 32/35/38 for purchases with a direct credit, 59/60/65/66 for
purchases destined to exempt sales, 62 for exempt purchases, and
43/44/45/47/48/50, the boxes that determine the result of the period. A
credit note received on a purchase declares a negative amount on the same
boxes as the original invoice (32/35/38) rather than on the Rubro 3, inciso
e) boxes (34/37/42): that inciso's own instructivo describes it, inconsistently
with the rest of Rubro 3, as concerning "ventas ya declaradas" (sales already
declared) rather than purchases, and this pack does not state a box whose
own official wording it cannot resolve — see *What the core could not say*.

**Not declared**: the Anexo del Exportador and the Hoja de Cálculo (casillas
148 to 220), through which an exporter recovers, period by period, the IVA
Crédito attributable to its exports (art. 101) — a proportional-attribution
mechanism this format has no primitive for, since it depends on a ratio of
the company's own turnover rather than on a single document's postings; the
casillas of the last six months of accumulated sales (Rubro 2); the
carry-forward of a prior period's saldo a favor into casillas 46/51; and the
retenciones and percepciones a company may have suffered (casillas 52 and
169). See *What the core could not say*.

**Due date**: `depends_on_taxpayer`. Resolución General N.° 38/2020, the
Calendario Perpetuo de Vencimientos, assigns each taxpayer a fixed day of the
month that follows the period, from the 7th to the 25th, by the last digit
of the RUC (excluding its verification digit) — a rule this pack cannot
compute without that digit.

## The statements

`PY-ESP` (Estado de situación patrimonial) and `PY-ER` (Estado de resultados)
answer Ley N.° 1.034/1983, art. 82, and, for a sociedad anónima, Código
Civil, art. 1079 — neither of which prescribes a rubro beyond the ones this
pack's lines name. `xbrl` is null everywhere: no fact-key taxonomy of a
Paraguayan filing is mapped here.

## The golden quarter

A trading company, January to March 2026, filing monthly: twelve documents
and five payments. It sells at 10 % with a partial return, sells at 5 %
(medicines), sells one exempt line (a recognised training service), exports
once; it buys at 10 % and at 5 % with a full credit, buys a good destined to
the exempt sale (no credit, art. 89), buys from an exempt supplier once,
receives one purchase credit note, and settles three of the invoices while
leaving one payment unmatched, on account. Every figure of
`golden/vat_return.json` was checked by hand against the postings before the
runner confirmed it.

## What the core could not say

1. **Clearance.** `einvoicing` can only say "mandatory, from this date, this
   profile"; it has no way to say "valid only once the SIFEN has validated
   it". The pack leaves the fields empty and says so in the reference, like
   Peru's, Argentina's and Mexico's.
2. **The Anexo del Exportador's proportional attribution** (art. 101,
   casillas 148 to 220): the credit an exporter recovers on purchases it
   cannot attribute directly to an export is a share of the company's own
   turnover ratio, not a fact any single document's postings carry.
3. **A deadline shifted by a digit of the RUC**, the same shape Peru's and
   Argentina's packs met with their own per-taxpayer schedules.
4. **The third leg of the tax point** — the expiry of a payment term with
   neither delivery nor collection (art. 83, numeral 1, inciso c) — has no
   word in this format's `tax_point` vocabulary.
5. **The agricultural products of art. 90, inciso d)**, whose export carries
   a different crédito fiscal treatment (art. 101) than the rest of the 5 %
   rate, and whose own casillas (150/156, and 152 on export) this pack does
   not declare — see *Taxes*, above.
6. **Retenciones and percepciones of the IVA**, and the carry-forward of a
   prior period's saldo a favor, both outside the scope of a tax code or an
   exemption this format can state.
7. **Casillas 34, 37 and 42 of Rubro 3** (crédito fiscal por ajustes,
   inciso e): the instructivo's own text describes them as concerning
   "ventas ya declaradas" inside a rubro otherwise about compras, which this
   pack cannot resolve into a purchase credit note without guessing at a
   mechanism its source does not clearly state. A purchase credit note is
   declared instead as a negative amount on the same boxes as the original
   purchase (32/35/38) — see *Taxes*, above.

## For a reviewer

The first things to read against practice: the four IVA accounts opened
under `104`/`203` and whether their split matches how a Paraguayan firm
actually keeps its ledger; the choice of `earliest_of_delivery_or_payment`
over a third, unrepresented leg of art. 83; the treatment of
`PY-C-10-NOCRED` and `PY-C-5-NOCRED`; the decision to fold every 5 % inciso
other than agricultural products in their natural state into one pair of
codes and boxes; and whether the original numbering of the chart reads the
way a Paraguayan accountant would expect it to.
