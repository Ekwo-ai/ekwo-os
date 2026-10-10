# Paraguay

Everything Paraguay adds to Ekwo, as data: an original chart of accounts built
on the minimum content the Ley del Comerciante and the Código Civil require
of a balance and a profit-and-loss account, the journals, the Impuesto al
Valor Agregado (IVA) with its two rates, its export and exemption codes, the
fields of the monthly Formulario N.° 120, a balance sheet and an income
statement, and the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says which decisions the
content rests on, so that a Paraguayan accountant can disagree with a
specific sentence rather than with the whole of it.

Language: Spanish (`es`), the language of the law and of the DNIT's own
forms. No official chart of accounts exists to carry a second wording of.

**Status: `community`.** Nobody who files a Paraguayan return has reviewed
it. `tests/golden.test.ts` replays the figures against a quarter of books,
which proves the pack is coherent and nothing about whether it is right.

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
and crédito of the operation. The obligation is phased in group by group
(pilot, voluntary, mandatory); general resolutions (among them N.° 95/2021)
add groups, and from January 2026 it reaches government suppliers and the
groups added for 2026 and 2027. It is a clearance model: the SIFEN validates
the DTE, before or after delivery depending on the approval model.

Ekwo writes no XML of a DTE, signs nothing digitally and talks to no SIFEN
endpoint. So:

- `einvoicing` names **no profile and no date**: `profile` is an EN 16931
  profile written by `packages/formats/` and sent over Peppol, which the DTE
  is not. Its legal reference says what the rules require and that Ekwo
  neither generates, signs nor transmits one.
- Every document carries the mention `dte_not_issued`: *this document is not
  a Documento Tributario Electrónico; only the one approved by the SIFEN, or
  a timbrado sales voucher, supports the operation for tax purposes.*
- The number a document gets in Ekwo is the number of the accounting entry,
  correlative per journal (`numbering: gapless`), not the
  timbrado-establecimiento-punto de expedición-número of the sales voucher.

What a company does today: issue the DTE through e-Kuatia, e-Kuatia'í or its
own SIFEN-compliant system, and record the transaction in Ekwo.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and the key of the text it is in. The register in `pack.json` holds eight
texts: Ley N.° 6.380/2019; Ley N.° 1.034/1983, Del Comerciante; the Código
Civil, Ley N.° 1.183/1985; and from the DNIT, the instructivo of the
Formulario N.° 120, Versión 4, the IVA page (Marangatú), the Manual Técnico
of the SIFEN (section 4.2, legal basis), the e-Kuatia page and the page on
Resolución General N.° 38/2020, the Calendario Perpetuo de Vencimientos.

## The chart of accounts

**Paraguay prescribes no catalogue of accounts.** Ley N.° 1.034/1983, art.
75, only requires every merchant above a capital threshold to keep
"indispensably a libro Diario and a libro Inventario"; art. 82 fixes what the
libro Inventario must show — the patrimonial situation at the start of
operations and, at each close, the patrimonial situation with the "cuadro
demostrativo de ganancias y pérdidas" — without naming an account. For a
sociedad anónima, Código Civil art. 1079 adds that the ordinary assembly
considers the "balance y cuenta de ganancias y pérdidas". The chart is
therefore **original**: a three- to five-digit numbering where every block of
codes corresponds directly to a line of `PY-ESP` or of `PY-ER`.

Four decisions:

- **The IVA control accounts are split into four**: `2031` "IVA Débito
  Fiscal" and `1041` "IVA Crédito Fiscal" are posting accounts; `2032` "IVA a
  Pagar" (`tax_payable`, reconcilable) and `1042` "IVA Saldo a Favor del
  Contribuyente" (`tax_receivable`, reconcilable) are the settlement accounts
  the monthly declaration carries its net to.
- **Only the customer, supplier and IVA-settlement accounts are
  `reconcilable`**, including the trade headings and documents
  receivable/payable of groups `102` and `201`.
- **The suspense account is `106` "Partidas pendientes de imputación".**
  Neither text names one; it is read on both sides by the statement rule
  that splits it.
- **The result of the year is kept apart in `351`/`352` until the assembly
  allocates it**, per art. 1079 — "hasta que la asamblea resuelva su
  afectación" — so `closing_style` is `result_accounts`.

## Taxes

| Code | Rate | Treatment | Declaration fields |
|---|---|---|---|
| `PY-V-10` | 10 % | domestic sale | 10/22; credit note 37/42 (Rubro 3, inciso e) |
| `PY-V-5` | 5 % | domestic sale (canasta básica, inmuebles, medicamentos, pecuarios, vivienda) | 151/157; credit note 34/42 (Rubro 3, inciso e) |
| `PY-V-EXP` | 0 % | export of goods | 14 |
| `PY-V-EXO` | — | exempt sale (art. 100) | 12 (credit note: same box, negative) |
| `PY-C-10` | 10 % | domestic purchase, with input tax credit | 35/38; credit note 15/23 (Rubro 1, inciso h) |
| `PY-C-5` | 5 % | domestic purchase, with input tax credit | 32/38; credit note 155/159 (Rubro 1, inciso j) |
| `PY-C-10-NOCRED` | 10 %, non-deductible | purchase destined to an exempt sale | 59, tax on cost (65) |
| `PY-C-5-NOCRED` | 5 %, non-deductible | purchase destined to an exempt sale | 60, tax on cost (66) |
| `PY-C-EXO` | — | domestic purchase, not taxed | 62; credit note 17 (Rubro 1, inciso k) |
| `PY-C-10-EXT` | 10 % | service from a supplier abroad, used in Paraguay, 100 % withheld by the buyer | 35 / 38; credit note 15/23 |

**The 5 % rate does not distinguish agricultural products in their natural
state.** Ley N.° 6.380/2019, art. 90, sets 5 % for five different incisos —
a), housing rentals; b), real estate; c), the canasta familiar; d),
agricultural, horticultural, fruit and livestock products; e) and f),
livestock derivatives and medicines. The Formulario N.° 120 gives inciso d)
its own boxes (150/156), since their export carries no right to a crédito
fiscal refund under art. 101; `PY-V-5` and `PY-C-5` declare the other
incisos, on 151/157 and 32/38.

**Tax point.** Ley N.° 6.380/2019, art. 83, numeral 1: the first of delivery
or rendering of the service, collection of the full price or of a partial
payment, or the expiry of the term set for payment. The first two are
`earliest_of_delivery_or_payment`; the third is not represented. Art. 92
requires the voucher when the obligation is born (except art. 83, numerals 4
to 6), so a company relying on the third leg alone will see this pack's tax
point lag its real one.

**Non-deductible purchases** (`PY-C-10-NOCRED`, `PY-C-5-NOCRED`). Art. 89,
numeral 1, ties the input tax credit to a purchase affected, directly or
indistinctly, to a taxed operation; art. 91 turns the IVA of a purchase
destined to an exempt or out-of-scope sale into a cost or expense for the
Impuesto a la Renta Empresarial. The form has boxes for both base and IVA
(59/65 at 10 %, 60/66 at 5 %), so these codes use a `tax_on_base` posting
that carries a box.

**A service bought from a supplier abroad is taxed through a 100 %
withholding that becomes the buyer's credit.** Ley N.° 6380/2019, art. 84,
numeral 1: *"la asistencia técnica y los demás servicios realizados en el
exterior se considerarán desarrollados en el territorio nacional, cuando
sean utilizados o aprovechados en el país"* — a software subscription,
hosting or an API used by the company is taxed. The obligation is born on
payment or on the due date, whichever comes first (art. 83, numeral 6).
Decreto N.° 3107/2019 makes whoever pays a supplier domiciled abroad a
withholding agent (art. 35, numeral 6) for 100 % of the IVA (art. 41), and
the law counts *"las retenciones o percepciones del impuesto efectuadas a los
beneficiarios radicados en el exterior"* in the IVA Crédito (art. 88,
numeral 3). `PY-C-10-EXT` books both halves in the same month: the credit
debited to `1041` and declared with the purchases at 10 % (boxes 35 and 38),
the withholding credited to `2034` *Retenciones a pagar*. The withholding is
documented by a comprobante de retención through Tesakã and paid as a
withholding agent, outside Formulario N.° 120, so it reaches no box here; and
Ekwo dates it on the document rather than on the payment. Digital services
paid by card are a different mechanism: the card issuer collects the IVA
(art. 97) and, for a taxpayer, that perception is also IVA Crédito. **A
foreign supplier belongs on `2012` *Proveedores del exterior*,** set as the
contact's payable account; the golden scenario cannot name a contact's
account, so its supplier abroad lands on `2011`.

## The declaration

`PY-F120` is the Formulario N.° 120, filed monthly on the Sistema de Gestión
Tributaria Marangatú. The pack names the casillas its tax codes need (see
*Taxes*) plus 43/44/45/47/48/50, which determine the result of the period.

A credit note is declared on the side of the form the instructivo gives it.
**A credit note issued to a customer** goes to Rubro 3, inciso e): its base to
casilla 34 (5 %) or 37 (10 %), its IVA to casilla 42, which casilla 43 adds to
the crédito fiscal. **A credit note received from a supplier** goes to Rubro 1:
casillas 15/23 at 10 % (inciso h), 155/159 at 5 % (inciso j), 17 for an exempt
purchase (inciso k); casilla 44 adds 23 and 159 to the débito fiscal. In the
ledger both reverse the original posting on `2031` or `1041`.

**Not declared**: the Anexo del Exportador and the Hoja de Cálculo (casillas
148 to 220), the proportional recovery of IVA Crédito attributable to exports
(art. 101); the last six months of accumulated sales (Rubro 2); the
carry-forward of a prior saldo a favor into casillas 46/51; and retenciones
and percepciones suffered (casillas 52 and 169).

**Due date**: `depends_on_taxpayer`. Resolución General N.° 38/2020, the
Calendario Perpetuo de Vencimientos, assigns each taxpayer a fixed day of the
following month, from the 7th to the 25th, by the last digit of the RUC
(excluding its verification digit).

## The statements

`PY-ESP` (Estado de situación patrimonial) and `PY-ER` (Estado de resultados)
answer Ley N.° 1.034/1983, art. 82, and, for a sociedad anónima, Código
Civil, art. 1079 — neither prescribes a rubro beyond the ones these lines
name. `xbrl` is null everywhere: no Paraguayan filing taxonomy is mapped.

## The golden quarter

A trading company, January to March 2026, filing monthly: thirteen documents
and five payments. It sells at 10 % with a partial return, sells at 5 %
(medicines), sells one exempt line (a recognised training service), exports
once; it buys at 10 % and at 5 % with a full credit, buys a good destined to
the exempt sale (no credit, art. 89), buys from an exempt supplier once,
receives one purchase credit note, subscribes to a cloud service from a
supplier abroad and withholds its IVA in full, and settles three of the
invoices while leaving one payment unmatched, on account.

## What the core could not say

Clearance ("valid only once the SIFEN has validated it"); the Anexo del
Exportador's proportional attribution (art. 101, casillas 148 to 220), a
turnover ratio rather than a document's postings; a deadline shifted by a
digit of the RUC; the third leg of the tax point (art. 83, numeral 1, inciso
c); the agricultural products of art. 90, inciso d) (casillas 150/156, and
152 on export); retenciones and percepciones of the IVA, and the
carry-forward of a prior saldo a favor.

## For a reviewer

The first things to read against practice: the four IVA accounts opened
under `104`/`203` and whether their split matches how a Paraguayan firm
keeps its ledger; `earliest_of_delivery_or_payment` over the unrepresented
third leg of art. 83; the treatment of `PY-C-10-NOCRED` and `PY-C-5-NOCRED`;
folding every 5 % inciso other than agricultural products in their natural
state into one pair of codes and boxes; and whether the chart's original
numbering reads the way a Paraguayan accountant would expect.
