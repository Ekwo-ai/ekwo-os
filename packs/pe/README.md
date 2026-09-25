# Peru

Everything Peru adds to Ekwo, as data: a chart of accounts built on the Plan
Contable General Empresarial, the journals, the Impuesto General a las Ventas
(IGV) with its export and exemption codes, the fields of the monthly
Formulario Virtual N.° 621, a balance sheet and an income statement, and the
sentences an invoice needs. The format is [`docs/packs.md`](../../docs/packs.md);
this file says where the content came from and which decisions it rests on,
so that a Peruvian accountant reading the pack can disagree with a specific
sentence rather than with the whole of it.

It is the second pack of Latin America, after Mexico. Language: Spanish
(`es`), which is the language of the law, of the Plan Contable General
Empresarial and of the SUNAT's own forms.

**Status: `community`.** Nobody who files a Peruvian return has reviewed it.
The figures are replayed against a quarter of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

Peru is outside the common system of VAT of Directive 2006/112/EC, so
`supabase/seed/00_territories.sql` carries a row for `PE` with `eu_vat_scope`
`none`: no `exemption_code`, no `intracom_*` treatment, and `vat_category` is
not required since this pack declares no e-invoicing profile — see
[What a tax says on the invoice](../../docs/packs.md#what-a-tax-says-on-the-invoice-treatment-category-and-reason).

## Ekwo does not issue a Peruvian comprobante de pago

**A Peruvian invoice is a comprobante de pago electrónico, and it exists only
once SUNAT or an Operador de Servicios Electrónicos (OSE) has validated it.**
The Reglamento de Comprobantes de Pago (Resolución de Superintendencia
N.° 007-99/SUNAT) only recognises the documents it lists as comprobantes de
pago, and the electronic ones of the Sistema de Emisión Electrónica (SEE) are
generated, signed and sent to SUNAT or to an OSE for validation before or
immediately after issue — a clearance model, not a direct exchange between
the two parties to the sale. Resolución de Superintendencia N.° 155-2017/SUNAT
and its successive extensions designated electronic issuers automatically by
their annual income or exports, and between 2022 and 2023 reached practically
every taxpayer of the Régimen General, the Régimen MYPE Tributario and the
Régimen Especial.

Ekwo writes no XML of a comprobante de pago electrónico, talks to no OSE and
validates nothing with SUNAT. So:

- `einvoicing` names **no profile and no date**, although the obligation
  exists in substance. `profile` is a profile built on EN 16931 that a brick
  of `packages/formats/` writes and transmits over Peppol, and the Peruvian
  comprobante de pago electrónico is neither; the format has no word for
  "valid only once SUNAT or an OSE has validated it". Its legal reference
  says what the rules require and says in as many words that Ekwo neither
  generates, sends nor validates one. Spain, Côte d'Ivoire and Mexico leave
  the profile empty for the same reason.
- Every document carries the mention `cpe_not_issued`: *this document is not
  an electronic payment voucher; only the validated one supports the
  operation for tax purposes.*
- The number a document gets in Ekwo is the number of the accounting entry,
  correlative per journal (`numbering: gapless`), and not the serie-correlativo
  that SUNAT or the issuer's own system assigns to the comprobante itself.

What a company does today: issue the comprobante de pago electrónico through
its own SEE system, a free SUNAT facility or an OSE, and record the
transaction in Ekwo. See *What the core could not say* below.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and the key of the text it is in. The register in `pack.json` holds thirteen
texts, every one opened on 25 September 2026: the consolidated VAT and
Excise Tax Act and its Appendix II on the SUNAT's own legislation pages; the
Reglamento of the same Act, on the Congress's document library; the
Ley de Tributación Municipal, on the same library; Ley N.° 32387, on the
Diario Oficial El Peruano's own search system; the consolidated Código
Tributario and the Reglamento de Comprobantes de Pago, both on SUNAT;
Resolución N.° 002-2019-EF/30, which approves the Plan Contable General
Empresarial, on El Peruano; the Ley General de Sociedades, on the Congress's
digital archive; the SUNAT's own filling guide of the Formulario Virtual
N.° 621 and its access page; the SUNAT's notice of the 2026 filing calendar;
and Resolución de Superintendencia N.° 155-2017/SUNAT on electronic issuers.

## The chart of accounts

**Peru prescribes no catalogue of accounts at company level: the Plan
Contable General Empresarial (PCGE) is a catalogue of major accounts (two
digits) and subaccounts down to five digits, with its own dynamics, that a
company extends with further digits as it needs.** This pack selects 174
codes of the PCGE 2019, with their official numbers and names, from
elements 1 to 7 — cash and receivables, inventories, fixed assets,
liabilities, equity, expenses by nature and income — chosen for a trading
company. Left out: the manufacturing, agricultural, financial-instrument and
biological-asset accounts the PCGE also carries, and elements 8 and 9
(intermediate management balances and analytical cost accounting), which are
optional refinements the presentation below does not need.

Four decisions:

- **The IGV control account, 40111 "IGV – Cuenta propia", is split into four
  subaccounts of this pack's own**, one digit deeper than the PCGE goes:
  `401111` for the output tax a sale posts (a posting account), `401112` for
  the input tax credit a purchase posts (a posting account), `401113` for
  the amount the monthly declaration settles when it is a debt
  (`tax_payable`, reconcilable) and `401114` for the amount it settles when
  it is a credit balance (`tax_receivable`, reconcilable). In ordinary
  Peruvian bookkeeping a single account, 40111, carries all of it; this pack
  keeps the posting accounts and the settlement accounts apart because the
  two have to be distinct accounts in Ekwo (see
  [Ajout 25/09 (2)](../../docs/packs.md) on the format side, and this is the
  same shape Slovakia's pack met on its own single-account 343). Every
  company may still read its IGV position as the sum of the four.
- **Only the customer, supplier and IGV-settlement accounts are
  `reconcilable`.** Peru's `account_templates_third_party_reconcilable`
  constraint requires every account typed `asset_receivable` or
  `liability_payable` to be reconcilable, so the headings and the bills
  receivable/payable of groups 12 and 42 are reconcilable too — they are
  trade accounts of customers and suppliers, which is exactly the family
  the constraint and the 25 September rule both mean.
- **The suspense account is `1699` "Otras cuentas por cobrar diversas".**
  The PCGE carries no account meant for items awaiting classification; this
  one is read on both sides by the statement rule that splits it.
- **The result of the year closes straight into retained earnings, `5911` /
  `5921`.** The PCGE 2019 keeps no separate current-year-result account
  apart from `591` Utilidades no distribuidas / `592` Pérdidas acumuladas,
  so `closing_style` is `retained_earnings`, the shape the United Kingdom and
  the United States use for the same reason.

## Taxes

| Code | Rate | Treatment | Declaration fields |
|---|---|---|---|
| `PE-V-18` | 18 % | domestic sale | 100/101, 102/103 (credit note) |
| `PE-V-EXP` | 0 % | export | 106 |
| `PE-V-EXO` | — | exempt sale (Apéndices I y II) | 105 |
| `PE-C-18` | 18 % | domestic purchase, with input tax credit | 107/108 |
| `PE-C-18-NOCRED` | 18 %, non-deductible | domestic purchase destined to a non-taxed sale | 113, tax on cost |
| `PE-C-EXO` | — | domestic purchase, not taxed | 120 |

**The combined 18 % is one tax code, not two.** The IGV proper (art. 17 of
the consolidated VAT Act) and the Impuesto de Promoción Municipal (art. 76 of
the Ley de Tributación Municipal) are two different taxes levied on the same
operations by the same rules, and SUNAT collects and prints them as a single
18 % on the comprobante — the format has no way to stack two taxes on one
line (`group` is reserved and not yet read by the core), which matches
practice anyway.

**The split between the two changes every year from 2026, the total does
not.** Ley N.° 32387 (16 June 2025) reduces the IGV from 16 % and raises the
IPM from 2 % on a schedule that keeps the sum at 18 % throughout: 15.5 % + 2.5
% in 2026, down to 14 % + 4 % by 2029. This pack's `valid_from` is
1 January 2026, at 18 %; a reader who has only ever seen "16 % + 2 %" is
reading the rate that applied before that date.

**Tax point.** IGV Act, art. 4°: for a sale of goods, the obligation is born
when the comprobante is issued or the good is delivered, whichever comes
first; for a service, when the comprobante is issued or the fee is collected,
whichever comes first. The Reglamento de Comprobantes de Pago requires the
comprobante to be issued at delivery, or at or before the completion of a
service, so issuance and the principle nearly always coincide in practice —
`tax_point` is declared `invoice_if_issued`. What this does not capture: a
service collected before its comprobante is issued, which would move the tax
point to the date of collection and which no code of this pack declares as
`cash_basis`.

**The non-deductible purchase, `PE-C-18-NOCRED`.** Art. 18°, inciso b), of
the IGV Act ties the input tax credit to the purchase being destined to a
taxed sale; a purchase destined to an exempt or an out-of-scope sale carries
no credit and its IGV becomes part of the cost, under art. 69° of the same
Act. The Formulario Virtual N.° 621 has a box for the base of such a purchase
(113) and none for the IGV itself, which the pack mirrors with a
`tax_on_base` posting that carries no box.

## The declaration

`PE-SUNAT-621` is the Formulario Virtual N.° 621, IGV Renta Mensual, filed
monthly on Sunat Operaciones en Línea. Its fields are casillas rather than
numbered boxes of a printed form, and this pack names the ones the IGV
itself needs: 100/101 taxed sales, 102/103 discounts and returns on sales,
106 exports, 105 sales not taxed, 107/108 purchases with a credit, 113
purchases without one, 120 purchases not taxed, and 140, the result of the
period — *impuesto resultante o saldo a favor*, positive when owed and
negative when it is a credit balance carried forward. **Not declared**: the
casillas of the IVAP (rice), of the Régimen de Amazonía, of a Convenio de
Estabilidad, of percepciones and retenciones received (171, 179, 326…), of
the saldo a favor of a prior period (145/184) and of the saldo a favor del
exportador (305/347) — see *What the core could not say*.

**Due date**: `depends_on_taxpayer`. The Código Tributario lets SUNAT set a
general calendar that in practice staggers the day within the month by the
last digit of the taxpayer's RUC; the exact day is published in a yearly
resolution and is not a rule this pack can compute.

## The statements

`PE-EF-ESF` (Estado de Situación Financiera) and `PE-EF-ER` (Estado de
Resultados, by nature) answer art. 223 of the Ley General de Sociedades,
which requires financial statements prepared under the generally accepted
accounting principles of the country — the NIIF the Consejo Normativo de
Contabilidad has adopted. Their lines are the major accounts of the PCGE
selection, presented current/non-current rather than by PCGE element, which
is how a Peruvian balance sheet is actually read; the income statement keeps
the PCGE's own by-nature presentation (elements 6 and 7) rather than the
by-function reclassification a company would do with accounts 94 to 96,
which this pack does not carry. `xbrl` is null everywhere: no fact-key
taxonomy of a Peruvian filing is mapped here.

## The golden quarter

A trading company, January to March 2026, filing monthly: twelve documents
and five payments. It sells at 18 % with a partial return, exports twice,
sells one exempt line (books, Apéndice I); it buys at 18 % with a full
credit, buys a good destined to the exempt sale (no credit, art. 18°,
inciso b)), buys from an exempt supplier twice, receives one purchase credit
note, and settles four of the invoices while leaving one payment
unmatched, on account. Every figure of `golden/vat_return.json` was checked
by hand against the postings before the runner confirmed it; see the
worked figures in the pull request that introduced this pack.

## What the core could not say

1. **Clearance.** `einvoicing` can only say "mandatory, from this date, this
   profile"; it has no way to say "valid only once SUNAT or an OSE has
   validated it". The pack leaves the fields empty and says so in the
   reference, like Mexico's CFDI.
2. **Regional and sectoral rates this pack does not carry**: the Amazonía
   region's reduced rates (Ley N.° 27037), the IVAP on rice, detracciones,
   percepciones and retenciones of the IGV — three separate administrative
   collection mechanisms with their own accounts, their own casillas and
   their own forms, none of which is a rate or an exemption a tax code of
   this format can state.
3. **A deadline shifted by a digit of the RUC**, the same shape Mexico's
   pack met with its own sixth-digit rule.
4. **The saldo a favor of a prior period** is not carried forward through a
   box: `401113`/`401114` hold the running IGV position on the ledger, and
   casillas 145/184 of the real form, which restate that same carry-forward
   inside the declaration itself, are not declared.
5. **Export services under Apéndice V**, whose eight assimilated operations
   and service list this pack does not enumerate: `PE-V-EXP` declares the
   ordinary export of goods and services and the article, not the detail.

## For a reviewer

The first things to read against practice: the four IGV subaccounts opened
under `40111` and whether their split matches how a Peruvian firm actually
keeps its ledger; the choice of `invoice_if_issued` over a `cash_basis` tax
for a service collected before its comprobante; the treatment of
`PE-C-18-NOCRED`; the split of the 18 % rate from 2026 under Ley N.° 32387;
and whether the current/non-current presentation of `PE-EF-ESF` should give
way to a fuller NIIF-mapped statement.
