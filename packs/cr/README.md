# Costa Rica

Everything Costa Rica adds to Ekwo, as data: a chart of accounts built on the
minimum content the Código de Comercio sets for the year-end books, the
journals, the Impuesto sobre el Valor Agregado (IVA) at its general and
reduced rates, an export exemption with full credit, an ordinary exemption
without it, the fields of the monthly IVA declaration, a minimal balance
sheet and income statement, and the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md).

**Status: `community`.** Nobody who files a Costa Rican return has reviewed
it. `tests/golden.test.ts` replays the figures against a month of books, which
proves the pack is coherent, not that it is right.

**Language.** Labels are in Spanish (`defaults.language: "es"`); `languages`
is empty. The Código de Comercio and the IVA law have no official English
translation, so an English label would be Ekwo's, not the law's.

## Ekwo does not issue a Costa Rican electronic invoice

**A Costa Rican invoice is a comprobante electrónico, valid only once the
Ministerio de Hacienda has validated it.** The Reglamento de Comprobantes
Electrónicos para Efectos Tributarios (Decreto 44739-H) and the Resolución
General MH-DGT-RES-0027-2024 require every comprobante — Anexos y Estructuras
version 4.4, obligatory since 1 September 2025 — to be signed and sent to the
Ministry's system before delivery; the system assigns the fifty-digit clave
numérica and returns an acceptance, partial-acceptance or rejection. It is a
clearance regime, not an EN 16931 exchange. Ekwo writes no version 4.4 XML,
talks to no Hacienda endpoint and computes no clave numérica. So:

- `einvoicing` names **no profile and no date**, although the obligation
  exists: `profile` is an EN 16931 profile written by `packages/formats/`.
- Every document carries the mention `clave_no_asignada`: *this document is
  not an electronic voucher; only the voucher validated by Hacienda, carrying
  its clave numérica, supports the operation for tax purposes.*
- A document's number is the consecutive of the entry, not the clave numérica.
- The cédula jurídica or física has no ISO 6523 scheme, so `party_scheme` and
  `vat_scheme` stay null.

A company issues the comprobante through a certified technology provider or
Hacienda's free tool, and records the transaction in Ekwo.

## Sources

Every rate, box, mention and statement carries its `legal_reference` and the
key of its text. The register in `pack.json` holds eight texts: the Ley del
Impuesto sobre el Valor Agregado (Ley 6826, reformada por la Ley 9635), its
Reglamento (Decreto 41779-H) and the Código de Comercio (Ley 3284), from the
Sistema Costarricense de Información Jurídica (SCIJ); the Resolución
MH-DGT-RES-0033-2025 on the IVA forms, with its Anexo, in an Alcance a La
Gaceta; the Reglamento and the Resolución on comprobantes electrónicos; the
TRIBU-CR portal page; and the Colegio de Contadores Públicos de Costa Rica's
page on the NIIF for SMEs, cited but not transcribed.

## The IVA declaration and its platform

Until 6 October 2025 the monthly return was filed on ATV with form D-104.
Resolución MH-DGT-RES-0033-2025 replaced both: the platform is now TRIBU-CR,
and the general-regime form is named **"Impuesto al Valor Agregado"** in its
Anexo 1 — not "D-104", not "Formulario 150" (an informal name absent from the
resolución). The form has no box **numbers**, so `tax_report.json` uses Anexo
1's labels — "Total ventas a 13%", "Monto de impuesto a 13%", "Impuesto
determinado", "Saldo a favor"; match labels, not numbers.

## The chart of accounts

**Costa Rica imposes no chart of accounts.** The Código de Comercio, art.
251, requires records showing operations and financial position "de forma
fácil, clara y precisa", with no legalisation; art. 258 fixes the minimum
**content** at each year-end close — a Balance de Comprobación, an Estado de
Ganancias y Pérdidas, a Balance General de Situación and, for a company, an
Estado de superávit — and nothing about numbering. The NIIF and NIIF for
SMEs, adopted by the Colegio de Contadores Públicos de Costa Rica (CCPA), a
professional body, are not transcribed here.

The chart is therefore **original**: three to five digits, each group
matching one line of `CR-CCOM-ESF` or `CR-CCOM-ER`. 126 accounts: cash,
banks, customers, sundry debtors, IVA control accounts by rate (crédito
fiscal and débito fiscal at 13/4/2/1%), inventory, fixed assets and
depreciation, suppliers, a Costa Rican employer's payroll provisions (CCSS
charges, aguinaldo, vacaciones, cesantía), retained earnings apart from the
current result, revenue by kind, a trading company's direct costs and
purchases, and general expenses. Two decisions:

- **IVA control accounts by rate on both sides; settlement apart.**
  `2131`-`2134` take a sale's tax (13%, 4%, 2%, 1%), `1151`-`1154` a
  deductible purchase's tax at the same rates. `2135`, *IVA por pagar*
  (`tax_payable`), and `1155`, *IVA saldo a favor* (`tax_receivable`), are
  what the declaration settles to, and the only `reconcilable` ones — see
  [`docs/packs.md`](../../docs/packs.md).
- **The suspense account is `117`**, *Partidas pendientes de imputación*,
  named to read as a temporary working line; no official chart names one.

## The financial statements

`CR-CCOM-ESF` (Balance General de Situación) and `CR-CCOM-ER` (Estado de
Ganancias y Pérdidas) are not a full NIIF presentation: they read the chart's
groups as art. 258 names the two statements, abridged for a small trading
company — one line per group, three subtotals, one result. `xbrl` is null: no
Costa Rican taxonomy is mapped, and the State imposes none.

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
| `CR-P-NODOM-13` | 13% | service or intangible from a non-domiciled supplier, self-assessed | Total importe/Impuesto soportado a 13%, Débito por autorepercusión del impuesto |

**An export is not an ordinary exemption.** Under art. 30, numeral 1, of the
Reglamento, only a taxable, non-exempt sale gives the right to deduct input
IVA; numeral 2 lists exempt operations that keep it — among them the
exportations of numeral 1 of art. 8 of the Law, sales to the Caja
Costarricense de Seguro Social, sales to Zona Franca beneficiaries. `CR-S-EXP`
is that exception (`treatment: export`, "Total ventas exentas con derecho a
crédito pleno"). The sale of books, Reglamento art. 11, numeral 4, inciso b),
follows the general rule (`treatment: exempt`, "Total ventas exentas sin
derecho a crédito"), and its purchase-side twin `CR-P-EXE` is `recoverable:
false`.

**A service bought from a supplier abroad is taxed in the buyer's hands.**
A software subscription, hosting or an API billed by a supplier with no
domicile in Costa Rica carries no Costa Rican IVA on its invoice, and the Law,
art. 4, second and third paragraphs, makes the recipient that is an IVA
taxpayer the contribuyente: the *inversión del sujeto pasivo*, which the
Reglamento defines in art. 1, inciso 30), and organises in art. 25, second
paragraph, inciso 1) — the buyer issues the electronic purchase voucher and
charges itself the tax. `CR-P-NODOM-13` books both halves at 13%: the credit
debited to `1151` and declared with the other purchases at 13% (the
voucher is a purchase like any other), and the tax owed credited to `2131`
and declared in the field *Débito por autorepercusión del impuesto* of
section IV, which Resolución MH-DGT-RES-0033-2025 adds to the tax of the
period before the credit is taken off. For a business with only taxed sales
the two cancel in the same month; the proportionality rule of art. 34 of the
Reglamento, which this pack does not apply, would cut the credit and not the
debit. A digital service paid by card to a foreign platform on which the
card issuer already collected the IVA (art. 30 of the Law) takes no such
entry. **A foreign supplier belongs on `2112` *Proveedores del exterior*,**
set as the contact's payable account; the golden scenario cannot name a
contact's account, so its supplier abroad lands on `2111`.

**Costa Rica is outside the common system of VAT**
(`supabase/seed/00_territories.sql`: `CR`, `eu_vat_scope: none`).
`exemption_code` stays null (the article goes in `legal_reference`), the
`intracom_*` treatments are unused, and `vat_category` is left out, being
documentary only where an `einvoicing.profile` is named — see
[`docs/packs.md`](../../docs/packs.md).

**Two transitional rates are not modelled**: 0.5% and 3% (Reglamento,
Transitorios, 2019-2022), still offered by the TRIBU-CR form, expired before
`released_at`. Corrective returns for those periods are out of scope — see
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

## The declaration

`CR-IVA` reads Anexo 1 of Resolución MH-DGT-RES-0033-2025, the form of the
Régimen Tradicional. Monthly, with no choice — Reglamento, art. 24, "el
período del impuesto es de un mes calendario" — so `period_default: month`;
due the fifteenth calendar day of the following month (Resolución, art. 4,
referring to art. 27 of the Law; Reglamento, art. 40).

Declared: base and tax at the four rates, the two exempt-sale totals, the
debit they sum to, purchase base and credit at 13% and 2%, the *Débito por
autorepercusión del impuesto*, and `Impuesto determinado` / `Saldo a favor`.
**Not modelled**, as each needs a fact one period's ledger cannot give: the
proportionality of the form's sections II and III (mixed taxed and exempt
sales credit only the allowed share, provisionally monthly, definitively in
December), the special régimenes for used goods and for agriculture, the tax
on casinos and games of chance, deferred payment on credit sales, and the IVA
refund on card-paid private health services.

## The golden month

A trading company, January 2026: eleven documents, four payments. It sells
general merchandise at 13%, a private health service at 4%, medicines at 2%,
a Canasta Básica Tributaria product at 1%, exports specialty coffee (exempt,
full credit) and sells books (exempt, no credit); it credits back part of the
13% sale. It buys merchandise and medicines (deductible) and books (exempt,
non-deductible), and subscribes to a cloud service from a supplier abroad,
self-assessed. One payment matches a sale, one collects the export, one pays
a supplier, one is a customer's advance left open on purpose.

`V13` net of the credit note is ₡450,000 and `T13` ₡58,500; `DEBITO` ₡70,500
(₡58,500 + ₡8,000 + ₡3,000 + ₡1,000); `CFTOTAL` ₡53,600 (₡52,000, of which
₡13,000 on the service from abroad, + ₡1,600); `AUTOREP` ₡13,000; `Impuesto
determinado` ₡29,900 (₡70,500 − ₡53,600 + ₡13,000); `Saldo a favor` zero.

## What the core could not say

See [`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

1. **Clearance.** `einvoicing` says "mandatory" only for an EN 16931 profile
   and cannot say "valid only once Hacienda validates it"; the fields stay
   empty, with the reason in the reference.
2. **Proportional credit.** `recoverable` is binary; the TRIBU-CR form
   computes a monthly provisional and a December definitive proportion for
   mixed businesses. The pack models only fully or not recoverable; a mixed
   business needs a professional's proportion.
3. **Forms not carried**: the Régimen Especial de Bienes Usados and the
   Régimen Especial Agropecuario file their own forms (Anexos 2, 3 and 4 of
   the same Resolución).

## For a reviewer

Check against practice: books (Reglamento, art. 11, numeral 4, inciso b) as
the exemption without credit against export as the one with it, and whether
that pair teaches the distinction best; the labels of `tax_report.json`
against the live TRIBU-CR form, which has no box numbers; `117` and its name
as suspense account; and whether the abridged Código de Comercio statements
should give way to a full NIIF mapping by a professional who holds it.
