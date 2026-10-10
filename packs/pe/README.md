# Peru

Everything Peru adds to Ekwo, as data: a chart of accounts built on the Plan
Contable General Empresarial, the journals, the Impuesto General a las Ventas
(IGV) with its export and exemption codes, the fields of the monthly
Formulario Virtual N.° 621, a balance sheet and an income statement, and the
sentences an invoice needs. The format is [`docs/packs.md`](../../docs/packs.md);
this file says which sources and decisions the content rests on. Language:
Spanish (`es`), the language of the law, of the PCGE and of SUNAT's forms.

**Status: `community`.** Nobody who files a Peruvian return has reviewed it.
`tests/golden.test.ts` replays a quarter of books, which proves the pack is
coherent and nothing about whether it is right.

Peru is outside Directive 2006/112/EC: `supabase/seed/00_territories.sql`
carries `PE` with `eu_vat_scope` `none` — no `exemption_code`, no
`intracom_*` treatment, and no `vat_category` since no e-invoicing profile is
declared (see
[What a tax says on the invoice](../../docs/packs.md#what-a-tax-says-on-the-invoice-treatment-category-and-reason)).

## Ekwo does not issue a Peruvian comprobante de pago

**A Peruvian invoice is a comprobante de pago electrónico, and it exists only
once SUNAT or an Operador de Servicios Electrónicos (OSE) has validated it.**
The Reglamento de Comprobantes de Pago (Resolución de Superintendencia
N.° 007-99/SUNAT) recognises only the documents it lists; the electronic ones
of the Sistema de Emisión Electrónica (SEE) are signed and sent to SUNAT or an
OSE for validation before or immediately after issue — a clearance model.
Resolución de Superintendencia N.° 155-2017/SUNAT and its extensions
designated electronic issuers by income or exports, and by 2022–2023 reached
practically every taxpayer of the Régimen General, MYPE Tributario and
Especial.

Ekwo writes no comprobante XML, talks to no OSE and validates nothing. So:

- `einvoicing` names **no profile and no date**, although the obligation
  exists: `profile` is an EN 16931 profile sent over Peppol, which the
  comprobante is not, and the format cannot say "valid only once validated".
  The legal reference states the rule and that Ekwo neither generates, sends
  nor validates one.
- Every document carries the mention `cpe_not_issued`: *this document is not
  an electronic payment voucher; only the validated one supports the
  operation for tax purposes.*
- A document's number in Ekwo is the entry number, correlative per journal
  (`numbering: gapless`), not the comprobante's serie-correlativo.

A company issues the comprobante through its own SEE system, a free SUNAT
facility or an OSE, and records the transaction in Ekwo.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and the key of its text. The register in `pack.json` holds thirteen texts: the
consolidated VAT and Excise Tax Act and its Appendix II; its Reglamento; the
Ley de Tributación Municipal; Ley N.° 32387; the consolidated Código
Tributario; the Reglamento de Comprobantes de Pago; Resolución
N.° 002-2019-EF/30, which approves the PCGE; the Ley General de Sociedades;
the SUNAT's filling guide of the Formulario Virtual N.° 621 and its access
page; the SUNAT's notice of the 2026 filing calendar; and Resolución de
Superintendencia N.° 155-2017/SUNAT on electronic issuers.

## The chart of accounts

**Peru prescribes no company-level catalogue: the Plan Contable General
Empresarial (PCGE) lists major accounts (two digits) and subaccounts down to
five digits, which a company extends as it needs.** This pack selects 174
codes of the PCGE 2019, with official numbers and names, from elements 1 to 7,
for a trading company. Left out: manufacturing, agricultural,
financial-instrument and biological-asset accounts, and elements 8 and 9
(optional management balances and cost accounting).

Four decisions:

- **The IGV account 40111 "IGV – Cuenta propia" is split into four
  subaccounts of this pack's own**, one digit deeper than the PCGE: `401111`
  output tax and `401112` input tax credit (posting accounts), `401113` the
  monthly settlement when it is a debt (`tax_payable`, reconcilable) and
  `401114` when it is a credit balance (`tax_receivable`, reconcilable).
  Ordinary Peruvian bookkeeping uses 40111 alone; Ekwo needs posting and
  settlement accounts to be distinct. The IGV position is the sum of the four.
  A fifth, `401115`, holds the input tax on services from non-residents until
  it is paid, and the PCGE's own `40113` *IGV – Servicios prestados por no
  domiciliados* holds the tax owed on them — see *Services used in Peru and
  supplied by a non-resident*.
- **Only the customer, supplier and IGV-settlement accounts are
  `reconcilable`.** The `account_templates_third_party_reconcilable`
  constraint requires every `asset_receivable` or `liability_payable` account
  to be reconcilable, so the headings and bills receivable/payable of groups
  12 and 42 are too.
- **The suspense account is `1699` "Otras cuentas por cobrar diversas".**
  The PCGE has no account for items awaiting classification; the statement
  rule splits this one by side.
- **The result of the year closes straight into retained earnings, `5911` /
  `5921`.** The PCGE 2019 has no current-year-result account apart from `591`
  Utilidades no distribuidas / `592` Pérdidas acumuladas, so `closing_style`
  is `retained_earnings`.

## Taxes

| Code | Rate | Treatment | Declaration fields |
|---|---|---|---|
| `PE-V-18` | 18 % | domestic sale | 100/101, 102/103 (credit note) |
| `PE-V-EXP` | 0 % | export | 106 |
| `PE-V-EXO` | — | exempt sale (Apéndices I y II) | 105 |
| `PE-C-18` | 18 % | domestic purchase, with input tax credit | 107/108 |
| `PE-C-18-NOCRED` | 18 %, non-deductible | domestic purchase destined to a non-taxed sale | 113, tax on cost |
| `PE-C-EXO` | — | domestic purchase, not taxed | 120 |
| `PE-C-18-NODOM` | 18 % | service supplied by a non-resident, used in Peru | none in the month — paid on Formulario 1662, credited once paid |

**The combined 18 % is one tax code, not two.** The IGV (art. 17 of the
consolidated VAT Act) and the Impuesto de Promoción Municipal (art. 76 of the
Ley de Tributación Municipal) are levied on the same operations by the same
rules, and SUNAT collects and prints them as a single 18 %; the format cannot
stack two taxes on one line (`group` is not yet read by the core).

**The split changes every year from 2026, the total does not.** Ley N.° 32387
(16 June 2025) lowers the IGV from 16 % and raises the IPM from 2 %, keeping
the sum at 18 %: 15.5 % + 2.5 % in 2026, down to 14 % + 4 % by 2029.
`valid_from` is 1 January 2026; "16 % + 2 %" is the rate before that date.

**Tax point.** IGV Act, art. 4°: for goods, the earlier of issuing the
comprobante and delivery; for a service, the earlier of issuing it and
collecting the fee. The Reglamento requires issue at delivery, or at or
before completion of a service, so `tax_point` is `invoice_if_issued`. Not
captured: a service collected before its comprobante is issued, which moves
the tax point to collection; no code declares `cash_basis`.

**The non-deductible purchase, `PE-C-18-NOCRED`.** Art. 18°, inciso b), of
the IGV Act ties the credit to a purchase destined to a taxed sale; otherwise
its IGV becomes cost under art. 69°. Form 621 has a box for the base (113)
and none for the tax, hence a `tax_on_base` posting with no box.

**Services used in Peru and supplied by a non-resident.** A software
subscription, hosting or an API billed from abroad is a *utilización de
servicios en el país* (IGV Act, art. 1°, inciso b); art. 3°, inciso d)),
and the Peruvian user is the taxpayer (art. 9°). The obligation is born when
the supplier's invoice is entered in the Registro de Compras or the fee is
paid, whichever comes first (art. 4°, inciso c)). The user pays the tax on
its own, with the boleta of Formulario Virtual N.° 1662, not through
Formulario 621, and art. 21° allows the credit *"únicamente cuando el
Impuesto correspondiente hubiera sido pagado"*; art. 6°, numeral 11, of the
Reglamento places it in the period in which the invoice and the payment
document are both entered. `PE-C-18-NODOM` books both halves at 18 %: the
tax owed credited to `40113`, the credit debited to `401115`, awaiting
application, and no box of Formulario 621 in the month of the invoice. When
the tax is paid, the bookkeeper moves the amount from `401115` to `401112`
by a manual entry and declares it in boxes 107 and 108 of that period's
return — the format cannot date a box on a payment that is not the
document's, the same limit `packs/ar/` documents. The chart carries no
account for suppliers abroad (group 42 is not split by residence), so a
foreign supplier sits on `4212` with the others.

## The declaration

`PE-SUNAT-621` is the Formulario Virtual N.° 621, IGV Renta Mensual, filed
monthly on Sunat Operaciones en Línea. Its casillas declared here: 100/101
taxed sales, 102/103 discounts and returns on sales, 106 exports, 105 sales
not taxed, 107/108 purchases with a credit, 113 purchases without one, 120
purchases not taxed, and 140, the result — *impuesto resultante o saldo a
favor*, positive when owed, negative when a credit carried forward. **Not
declared**: the casillas of the IVAP (rice), the Régimen de Amazonía, a
Convenio de Estabilidad, percepciones and retenciones received (171, 179,
326…), the saldo a favor of a prior period (145/184) and the saldo a favor
del exportador (305/347).

**Due date**: `depends_on_taxpayer`. Under the Código Tributario SUNAT's
yearly calendar staggers the day by the last digit of the RUC; the pack does
not compute it.

## The statements

`PE-EF-ESF` (Estado de Situación Financiera) and `PE-EF-ER` (Estado de
Resultados, by nature) answer art. 223 of the Ley General de Sociedades:
statements under the country's generally accepted principles, the NIIF
adopted by the Consejo Normativo de Contabilidad. Lines are PCGE major
accounts, current/non-current, as a Peruvian balance sheet is read; the
income statement is by nature (elements 6 and 7), not by function (accounts
94 to 96, not carried). `xbrl` is null everywhere.

## The golden quarter

A trading company, January to March 2026, filing monthly: thirteen documents
and five payments. It sells at 18 % with a partial return, exports twice,
sells one exempt line (books, Apéndice I); it buys at 18 % with a full
credit, buys a good destined to the exempt sale (no credit, art. 18°,
inciso b)), buys from an exempt supplier twice, receives one purchase credit
note, subscribes to a cloud service from a non-resident (IGV left awaiting
payment on `401115`), and settles four invoices while leaving one payment
unmatched, on account.

## What the core could not say

1. **Clearance.** `einvoicing` cannot say "valid only once SUNAT or an OSE
   has validated it"; the fields stay empty and the reference says so.
2. **Regional and sectoral regimes not carried**: the Amazonía reduced rates
   (Ley N.° 27037), the IVAP on rice, and detracciones, percepciones and
   retenciones of the IGV — collection mechanisms with their own accounts,
   casillas and forms, none expressible as a tax code.
3. **A deadline shifted by a digit of the RUC.**
4. **The saldo a favor of a prior period** is not carried through a box:
   `401113`/`401114` hold the running IGV position, and casillas 145/184 are
   not declared.
5. **Export services under Apéndice V**: its eight assimilated operations and
   service list are not enumerated; `PE-V-EXP` declares the ordinary export
   and the article, not the detail.

## For a reviewer

Read first against practice: the four IGV subaccounts under `40111` and
whether they match how a Peruvian firm keeps its ledger; `invoice_if_issued`
rather than `cash_basis` for a service collected before its comprobante; the
treatment of `PE-C-18-NOCRED`; the 2026 split of the 18 % under Ley
N.° 32387; and whether `PE-EF-ESF` should give way to a fuller NIIF-mapped
statement.
