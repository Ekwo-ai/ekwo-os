# Guatemala

Everything Guatemala adds to Ekwo, as data: an original chart of accounts
built on the NIIF for SMEs the country's accounting profession has adopted,
the journals, the Impuesto al Valor Agregado (IVA) at its single rate with
exports and the general exemptions of the law, the fields of the monthly
Formulario SAT-2237, a balance sheet and an income statement, and the
sentences an invoice needs. The format is [`docs/packs.md`](../../docs/packs.md);
this file says where the content came from and which decisions it rests on,
so that a Guatemalan accountant reading the pack can disagree with a specific
sentence rather than with the whole of it.

It is the sixth pack of Latin America, after Mexico, Chile, Colombia, Peru
and Argentina, and the first of Central America. **Language: `es`.** Every
label of this pack is written in Spanish, the language of the law and of the
Superintendencia de Administración Tributaria's (SAT) own forms. No second
language is declared: Guatemala prescribes no catalogue of accounts (see
below), so the chart is this pack's own and has no official wording in any
other language to carry as `i18n` — a translation would be this pack's own
words translated a second time, not a text a reader can check against a
source. A contributor is welcome to add `i18n/en.json` one section at a time,
exactly as `docs/packs.md` describes.

**Status: `community`.** Nobody who files a Guatemalan return has reviewed
it. The figures are replayed against a quarter of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

Guatemala is outside the common system of VAT of Directive 2006/112/EC, so
`supabase/seed/00_territories.sql` carries a row for `GT` with `eu_vat_scope`
`none`: no `exemption_code`, no `intracom_*` treatment, and `vat_category` is
not declared on any tax of this pack, since it declares no e-invoicing
profile — see [What a tax says on the invoice](../../docs/packs.md#what-a-tax-says-on-the-invoice-treatment-category-and-reason).
`GTQ` (Guatemalan quetzal, two decimals) is added to `00_currencies.sql`.

## Ekwo does not issue a Guatemalan Documento Tributario Electrónico

**A Guatemalan invoice is a Documento Tributario Electrónico (DTE), and it
exists only once a Certificador authorised by the SAT — or the SAT itself —
has certified it.** Acuerdo de Directorio Número 13-2018 created the Régimen
de Factura Electrónica en Línea (FEL): the issuer generates the DTE, signs it
and transmits it to a Certificador, which validates the rules of the régimen
and applies its own certification before the document exists as a
comprobante for tax purposes — a clearance model, not a direct exchange
between the two parties to the sale. Adoption was staged by each taxpayer's
volume of invoicing and reached every taxpayer of the country, including
those of the Régimen de Pequeño Contribuyente, by March 2023.

Ekwo writes no DTE XML, talks to no Certificador and certifies nothing with
the SAT. So:

- `einvoicing` names **no profile and no date**, although the obligation
  exists in substance. `profile` names a profile built on EN 16931 that a
  brick of `packages/formats/` writes and transmits over Peppol, and the
  Guatemalan DTE is neither; the format has no word for "valid only once a
  Certificador has certified it". Mexico, Peru and Argentina leave the same
  fields empty for the same reason; see *From Guatemala* in
  [`docs/international.md`](../../docs/international.md).
- Every document carries the mention `dte_not_issued`: *this document is not
  a Documento Tributario Electrónico; only the certified one supports the
  operation for tax purposes.*
- The number a document gets in Ekwo is the number of the accounting entry,
  correlative per journal (`numbering: gapless`), and not the number of
  authorisation (a UUID) the Certificador assigns to the DTE itself, nor the
  serie-número the issuer's own system carries.

What a company does today: issue the DTE through a certified billing system
or the SAT's own free facility, and record the transaction in Ekwo. See
*What the core could not say* below.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and the key of the text it is in. The register in `pack.json` holds ten
texts, every one opened on 26 September 2026: the consolidated Ley del
Impuesto al Valor Agregado (Decreto Número 27-92) on the Congreso's own
legislative repository; Decreto Número 4-2012, which reformed the régimen of
Pequeño Contribuyente and the documentation of the crédito fiscal, on the
same repository; the current Reglamento of the IVA law, Acuerdo Gubernativo
Número 5-2013, on the Ministerio de Finanzas Públicas — it replaced Acuerdo
Gubernativo Número 311-97, which this pack does **not** cite, since it was
superseded before this pack's `released_at`; the Código de Comercio de
Guatemala (Decreto Número 2-70), also on the Congreso's repository; the
Colegio de Contadores Públicos y Auditores de Guatemala's own resolution
adopting the NIIF for SMEs; and four pages of the SAT's own portal — the
Cumplimiento Tributario guidance on the monthly IVA declaration, the
Declaraguate filing portal, the Acuerdo de Directorio that creates the FEL
régime, the eFactura information page, and the Pequeño Contribuyente page of
the Libro Electrónico Tributario.

## The chart of accounts

**Guatemala prescribes no catalogue of accounts: the Código de Comercio,
art. 368, requires only that a merchant keep organised, double-entry
accounting under generally accepted accounting principles, and establish, at
least once a year, its financial situation through a balance sheet and a
profit and loss statement signed by the merchant and the accountant.** Those
principles are, since a resolution of the Asamblea General Extraordinaria of
the Colegio de Contadores Públicos y Auditores de Guatemala of 29 June 2010,
published in the Diario de Centro América on 13 July 2010, the NIIF for
SMEs — mandatory from 1 January 2011. This pack's chart is therefore
**original**, the way Argentina's is: it follows its own numbering, current
and non-current, and every block of codes corresponds to a line of
`GT-EF-ESF` or `GT-EF-ER`. It carries 141 accounts.

Two decisions:

- **The IVA control accounts are split into four accounts of this pack's
  own**: `2131` "IVA - Débito Fiscal" and `1141` "IVA - Crédito Fiscal" are
  posting accounts, credited or debited by every sale or purchase; `2132`
  "IVA por Pagar" and `1142` "IVA - Crédito Fiscal por Cobrar" are the
  settlement accounts of the monthly declaration, reconcilable, and distinct
  from the posting accounts as [Ajout 25/09 (2)](../../docs/packs.md) of the
  format's own notes requires. A Guatemalan company ordinarily keeps this
  position on fewer accounts; this pack keeps posting and settlement apart
  because the format asks the two to be different accounts.
- **Only the customer, supplier and IVA-settlement accounts are
  `reconcilable`.** The core's own constraint requires every account typed
  `asset_receivable` or `liability_payable` to be reconcilable, which this
  chart limits to the trade accounts of customers (`1121`-`1123`) and
  suppliers (`2111`-`2113`); every allowance, deposit or advance account
  that is not itself a trade balance is typed `asset_current` or
  `liability_current` instead, never `asset_receivable` or
  `liability_payable`, precisely so that it is not swept into that
  constraint.
- **The result of the year waits on the balance sheet for the shareholders'
  meeting that allocates it** (`closing_style: result_accounts`, accounts
  `351`/`352`), rather than closing straight into retained earnings: the
  Código de Comercio's rules on sociedades (arts. 132 and following) make
  the distribution of utilidades a decision of the junta general, not an
  automatic year-end entry, the same shape Argentina and France use for the
  same reason.

## Taxes

| Code | Rate | Treatment | Declaration fields |
|---|---|---|---|
| `GT-V-12` | 12 % | domestic sale | VG, DF |
| `GT-V-EXP` | 0 % | export of goods and services | VEXP |
| `GT-V-EXO` | — | exempt sale (art. 7) | VEXO |
| `GT-C-12` | 12 % | domestic purchase, with credit | CG, CF |
| `GT-C-12-NOCRED` | 12 %, non-deductible | purchase destined to an exempt sale | CNOCRED, tax on cost |
| `GT-C-EXO` | — | purchase from an exempt or non-taxed supplier | CEXO |
| `GT-C-IMP-12` | 12 % | import, with credit | IMP, CFIMP |

**One rate, one law.** Decreto Número 27-92, art. 10, sets a single tarifa of
twelve per cent (12 %) on the base imponible, always included in the price —
Guatemala has never split this into several positive rates the way Peru's
IGV and Impuesto de Promoción Municipal do.

**The non-deductible purchase, `GT-C-12-NOCRED`.** Art. 16, first paragraph
(reformed by art. 14 of Decreto Número 80-2000), ties the crédito fiscal to
an acquisition applied to a gravado act or an operación afecta; contrario
sensu, a purchase destined to an exempt or non-taxed sale generates no
crédito fiscal and the tax paid becomes part of the cost of what was bought.
The Formulario SAT-2237 has no casilla of its own for that tax, which this
pack mirrors with a `tax_on_base` posting that carries no box.

**Tax point.** Art. 4, numeral 1: for a sale of goods, the tax is paid on
the date the factura is issued, or on the date of actual delivery when
delivery precedes the invoice; for a service, on the date the factura is
issued or, if none was issued, on the date the remuneration is received.
Art. 34 requires the factura to be issued at the moment of delivery or, for
a service, at the moment the remuneration is received, so issuance and the
principle coincide in practice — `tax_point` is declared `invoice_if_issued`.

**Documentation of the crédito fiscal.** Art. 18, reformed by art. 8 of
Decreto Número 4-2012, requires a factura, factura especial, nota de débito
or crédito, or the receipt of an import's duties, issued to the taxpayer's
name and NIT, indicating the item bought, registered in the libro de
compras of art. 37 and in the accounting.

## The declaration

`GT-SAT-2237` is the Formulario SAT-2237, Declaración Jurada y Pago Mensual
del IVA — Régimen General, filed monthly through the Agencia Virtual SAT or
Declaraguate. **It has no numbered casillas of a printed form: the fields
are named sections of an electronic form**, so this pack gives each an
acronym of its own with the field's exact name — `VG`/`DF` for taxed sales
and their tax, `VEXP` for exports, `VEXO` for exempt sales, `CG`/`CF` for
purchases with a credit, `CNOCRED` for purchases without one, `CEXO` for
non-taxed purchases, `IMP`/`CFIMP` for imports, `TOTAL` for the result of
the period. Mexico's own declaration met the same shape and made the same
choice — see its README.

**Due date**: `last_day_of_month_after_period`. Art. 40 requires the
declaration and the payment "dentro del mes calendario siguiente al del
vencimiento de cada período impositivo": the law opens the whole of the
following calendar month rather than fixing one day inside it, and — unlike
Peru's or Mexico's calendar staggered by the last digit of a taxpayer number
— nothing in Guatemalan law narrows that further.

## The statements

`GT-EF-ESF` (Estado de Situación Financiera) and `GT-EF-ER` (Estado de
Resultados) answer art. 368 of the Código de Comercio, read together with
the NIIF for SMEs the Colegio de Contadores Públicos y Auditores adopted.
The balance sheet presents current and non-current assets and liabilities,
which is how section 4 of the NIIF for SMEs orders the statement when an
entity does not present by liquidity; the income statement groups expenses
by nature (sueldos, honorarios, arrendamientos…), which section 5 of the
same standard allows as an alternative to a by-function presentation. `xbrl`
is null everywhere: no fact-key taxonomy of a Guatemalan filing is mapped
here.

## The golden quarter

A trading company, January to March 2026, filing monthly: thirteen
documents and five payments. It sells at 12 % with a partial return, sells
to a university exempt under arts. 8-9, exports twice; it buys at 12 % with
a full credit, buys furniture destined to the exempt sale (no credit, art.
16), buys from an exempt cooperative twice, imports merchandise once,
receives one purchase credit note, and settles four of the invoices while
leaving one collection unmatched, on account. Every figure of
`golden/vat_return.json` was checked by hand against the postings before the
runner confirmed it: January owes 19.20 (96.00 débito fiscal less 76.80
crédito fiscal), February owes 9.60 (a purchase credit note reversing more
crédito fiscal than the period's own débito fiscal), and March carries a
remanente de crédito fiscal of 144.00 (240.00 débito fiscal less 144.00 and
240.00 of domestic and import crédito fiscal) — a negative result Guatemala
carries forward rather than floors at zero (arts. 19, 21 and 22).

## What the core could not say

1. **Clearance.** `einvoicing` can only say "mandatory, from this date, this
   profile"; it has no way to say "valid only once a Certificador has
   certified it". The pack leaves the fields empty and says so in the
   reference, like Mexico's CFDI, Peru's comprobante electrónico and
   Argentina's comprobante with CAE.
2. **The Régimen de Pequeño Contribuyente, a tax this pack does not
   declare.** Art. 47, reformed by art. 15 of Decreto Número 4-2012, taxes a
   taxpayer whose annual sales or services do not exceed Q.150,000.00 at
   five per cent (5 %) of gross monthly income, in substitution of the
   régimen general's débito-menos-crédito mechanism, filed on the
   Formulario SAT-2046. It is not a rate of the IVA this format can express
   as a `tax` of `kind: "vat"` beside the twelve per cent: the factura a
   Pequeño Contribuyente issues generates no crédito fiscal at all for the
   buyer (art. 49, reformed), so the 5 % is a turnover tax in the place of
   the IVA rather than a rate of it, and a company under this régimen keeps
   no débito/crédito fiscal ledger for the core to post to. This pack
   documents the régimen here and in
   [`docs/international.md`](../../docs/international.md) rather than
   inventing a tax code for it.
3. **The Régimen especial de devolución de crédito fiscal a los
   exportadores** (art. 25): a cash refund of 75 % or 60 % of an exporter's
   crédito fiscal, paid by the Banco de Guatemala outside the declaration
   itself. It is an administrative refund mechanism, not a rate, an
   exemption or a box of the declaration, and this pack carries none of it.
4. **Regional or sectoral rates this pack does not carry**: none is known
   at `released_at` — Guatemala's IVA is the one national rate of art. 10,
   with no equivalent of Peru's Amazonía region or Argentina's provincial
   Ingresos Brutos.
5. **A deadline that Guatemalan law does not stagger by taxpayer**, unlike
   Peru's or Mexico's calendars keyed to the last digit of a tax number:
   art. 40 simply opens the whole of the month that follows the period.

## For a reviewer

The first things to read against practice: the split of the IVA position
into four accounts (`1141`/`1142`/`2131`/`2132`) and whether it matches how
a Guatemalan firm actually keeps its ledger; the choice of
`invoice_if_issued` over a `cash_basis` tax; the treatment of
`GT-C-12-NOCRED`; whether the acronyms chosen for the SAT-2237's named
fields read naturally to someone who fills the form every month; and
whether the current/non-current presentation of `GT-EF-ESF` should give way
to a fuller NIIF-mapped statement.
