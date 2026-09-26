# Bolivia

Everything Bolivia adds to Ekwo, as data: a chart of accounts built on the
Código de Comercio and the Normas de Contabilidad Generalmente Aceptadas, the
journals, the Impuesto al Valor Agregado (IVA) with its export and tasa cero
codes, the fields of the Formulario 200 mensual, a balance general and an
estado de resultados, and the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Bolivian accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

Language: Spanish (`es`), the language of the law and of the Formulario 200.

**Status: `community`.** Nobody who files a Bolivian IVA return has reviewed
it. The figures are replayed against a quarter of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

Bolivia is outside the common system of VAT of Directive 2006/112/EC, so
`supabase/seed/00_territories.sql` carries a row for `BO` with `eu_vat_scope`
`none`: no `exemption_code`, no `intracom_*` treatment, and `vat_category` is
not required since this pack declares no e-invoicing profile — see
[What a tax says on the invoice](../../docs/packs.md#what-a-tax-says-on-the-invoice-treatment-category-and-reason).
This pack still fills `vat_category` where a value is free to give, the way
Peru's and Argentina's do.

## The IVA is calculated "por dentro": the effective rate is not 13 %

**Ley N.° 843, art. 5° — the tax "forms an integral part of the net price of
the sale […] and is invoiced together with it, that is, it is not shown
separately."** A Bolivian invoice states one total, and that total already
holds the tax; art. 15° then applies the "13 %" to that same total, not to a
price computed without the tax first. On an invoice of 1.000,00 Bs, the
débito fiscal is **130,00 Bs, exactly 13 % of the 1.000,00 Bs facturados** —
never 13 % of a base of 870,00 Bs, which would give 113,10 Bs. This is
confirmed by the Formulario 200's own instructions, casilla 39: "Débito
Fiscal correspondiente a: (C13 \* 13 %)", where C13 is "el importe total
Facturado."

`docs/packs.md`'s `price_include` field is built for exactly this shape — a
price the seller keys in that already holds the tax, the way a British or
Australian retail price does — except that its formula there **removes the
tax by dividing the gross by `1 + rate/100`** (`tax = gross - gross /
(1.13)`), which is the ordinary gross-up of a rate stated on the *net* price.
Applying that formula with `rate: 13` would compute a tax of 13/113 of the
gross (11,50 %), not the 13/87 (14,94 %) that Bolivian law actually charges
on the gross. So this pack declares `price_include: true` with an **effective
rate of `14.9425`** — the four decimals `tax_templates.rate` can hold of
13/87 = 14,942528735632…% — which makes the same formula land on the right
number: `tax = gross - gross / 1.149425 = gross × 0,13000…`, to the cent, for
every invoice this pack's golden quarter uses. The gap between 14,9425 and
the exact fraction is under two ten-millionths of the gross, far below a cent
on any invoice a real business would issue.

**BO-V-13 and BO-C-13 both use this effective rate**, on the sale side and on
the purchase side: the Formulario 200 computes the crédito fiscal the same
way it computes the débito fiscal, casilla 114 being "(C26+C27+C28) \* 13 %"
of the *compra facturada*, not of a net price. `BO-V-EXP` and `BO-V-CERO` are
zero-rated, so the gross/net distinction never arises for them.

**Casilla 13 and casilla 26 want the gross figure, and the engine's `base`
posting always holds the net one.** A `base` posting is, by construction, the
net amount that lands on the revenue or expense account (`docs/packs.md`,
"What a tax says, and where its postings land") — the opposite of what the
Formulario 200 asks these two boxes to hold. Rather than declare a box the
form does not carry, this pack posts the net amount to a hidden bookkeeping
box of its own (`BASE13`, `BASE26` — not casillas of the form, and said so in
their own `legal_reference`) and declares the real casillas 13 and 26 as
**totals**: casilla 13 = `BASE13 + 39`, casilla 26 = `BASE26 + 114`. That is
the "second base is a sum" pattern of `docs/packs.md` (the base and the tax
of one operation, added back together), read in the direction the ledger
actually produces the figures rather than the direction the form prints them
in — the two ways of getting to 13 % of a gross figure agree to the cent, and
`ekwo pack check`'s dependency check accepts a total computed from boxes
declared after it.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and the key of the text it is in. The register in `pack.json` holds eleven
texts, every one opened on 26 September 2026: Ley N.° 843 and the Código
Tributario Boliviano (Ley N.° 2492), both on the Servicio de Impuestos
Nacionales' own legislation pages; the Reglamento del IVA (Decreto Supremo
N.° 21530), on LexiVox's compilation of the Gaceta Oficial; the Ley del Libro
y la Lectura (Ley N.° 366) and the tasa cero del transporte internacional de
carga (Ley N.° 3249); the Código de Comercio, on the OAS's own mirror of the
Bolivian text; the Resolución CTNAC N.° 01/2012, through a professional
firm's summary of the accounting framework it establishes; the Formulario 200
v.5 Extendido and the Calendario Tributario 2026, both on the SIN's own site;
the Resolución Normativa de Directorio N.° 102100000011 (Sistema de
Facturación); and the SIN's own Oficina Virtual as the filing portal.

## The chart of accounts

**Bolivia prescribes no numbered chart of accounts.** The Código de Comercio
(Decreto Ley N.° 14379), art. 36°, asks only that every merchant keep
accounting "suited to the nature, importance and organisation of the
business" on a uniform basis, and art. 37° lists the indispensable books —
Diario, Mayor, de Inventario y Balances — without naming a single account.
Art. 331° requires the annual memoria of a sociedad anónima to contain the
balance general and the estado de resultados, again without prescribing
lines. The technical framework is the fourteen Normas de Contabilidad
Generalmente Aceptadas that the Consejo Técnico Nacional de Auditoría y
Contabilidad (CTNAC) of the Colegio de Auditores o Contadores Públicos de
Bolivia issues, with the NIIF (IFRS) adopted as a supplementary framework by
Resolución CTNAC N.° 01/2012 — a professional body's own resolution, not a
State organ's, and its text is not transcribed here.

This pack's 130 accounts are therefore **original**: a convention of its own,
up to five digits deep, in which the first digit is Activo (1), Pasivo (2),
Patrimonio (3), Ingresos (4) or Costos y Gastos (5), and every block of
three-digit codes corresponds to exactly one line of `BO-EF-BG` or of
`BO-EF-ER`, so the chart reads straight off the two statements it feeds — the
same shape Argentina's pack settled on for the same reason, and for the same
absence of an official chart.

Four decisions:

- **The IVA accounts separate posting from settlement, on both sides.**
  `2131` *IVA Débito Fiscal* and `1151` *IVA Crédito Fiscal* are where every
  tax posts; `2132` *IVA por Pagar* and `1152` *IVA Saldo a Favor del
  Contribuyente* are the reconcilable settlement accounts distinct from the
  posting accounts, as [Ajout 25/09 (2)](../../docs/packs.md) requires.
  Ordinary Bolivian bookkeeping often keeps a single control account for
  IVA; this pack keeps the four apart because the format requires the
  settlement account to be a different one from the accounts the tax posts
  to.
- **Only the customer, supplier and IVA-settlement accounts are
  `reconcilable`.** `113`/`1131`/`1132`/`1133` and `211`/`2111`/`2112`/`2113`
  are reconcilable because the database requires every `asset_receivable` or
  `liability_payable` account to be, whether or not it is a heading nothing
  is posted to directly; `1134`, the allowance for doubtful accounts, is
  typed `asset_current` rather than `asset_receivable` for exactly that
  reason — it is not itself a party's account, and reconciling it against a
  bank statement would raise `reconcile_account_mismatch`
  ([Ajout 25/09](../../docs/packs.md) on `camt.053`, which this pack does not
  declare, but the same rule holds regardless).
- **The suspense account is `117`** *Partidas pendientes de imputación*, not
  reconcilable, and never the bank or the cash account.
- **The result of the year sits on its own line until the junta decides its
  allocation, `350`/`351`/`352`, and the close carries it to `340`/`341`/
  `342`** (`closing_style: result_accounts`), the same mechanism Argentina
  and France use: the Código de Comercio names no appropriation account of
  its own, so the result is neither swept straight into retained earnings
  nor routed through an appropriation account the law describes.

## Taxes

| Code | Rate | Treatment | Declaration fields |
|---|---|---|---|
| `BO-V-13` | 13 % por dentro (effective 14,9425) | domestic sale | 13 (via `BASE13`), 39 |
| `BO-V-EXP` | 0 % | export, credit kept | 14 |
| `BO-V-CERO` | 0 % | zero rate, no credit (Ley 366 books) | 15 |
| `BO-C-13` | 13 % por dentro (effective 14,9425) | domestic purchase, credit | 26 (via `BASE26`), 114 |
| `BO-C-13-NOCRED` | 13 % por dentro, non-recoverable | purchase feeding a zero-rate, no-credit sale | none — see below |

**`BO-V-EXP` and `BO-V-CERO` are both zero-rated and both named "tasa cero"
in casual usage, and the Formulario 200 still tells them apart with two
different boxes, for one reason: only the export keeps the right to a
crédito fiscal.** Ley N.° 843, art. 11°, liberates an export from the débito
fiscal and lets the exporter keep computing crédito fiscal on the purchases
behind it, with a CEDEIM refund (Decreto Supremo N.° 25465) for what is not
absorbed by domestic sales — casilla 26's own instructions say so explicitly
("incluyendo las compras vinculadas a exportación de bienes y operaciones
exentas"). Ley N.° 366, art. 8°, zero-rates the sale of books but in the same
sentence denies the crédito fiscal on it, and the invoice has to carry the
words "TASA CERO - SIN DERECHO A CREDITO FISCAL, LEY N.° 366" — the mirror of
what casilla 26's instructions exclude ("Excepto compras destinadas a
actividades gravadas con tasa cero"). This pack reads that second exclusion
as `treatment: exempt` and not `export`, because exempt is the vocabulary
`docs/packs.md` reserves for a sale that carries no crédito fiscal right on
what feeds it, which is exactly the Ley N.° 366 shape and exactly the
opposite of the export's.

**`BO-C-13-NOCRED` has no box, because the Formulario 200 has none for it.**
A purchase taxed at the general rate but destined exclusively to a Ley N.°
366 sale loses its crédito fiscal (art. 8° of Ley N.° 843, read against
casilla 26's own exclusion) and the tax facturado becomes part of the cost of
the line, the same shape Peru's `PE-C-18-NOCRED` and Slovakia's non-deductible
codes use — a `base` posting with no box and a `tax_on_base` posting at
100 %, both landing on the line's own account. Unlike Peru's casilla 113,
Bolivia's form carries no casilla at all for this purchase: it does not
enter the crédito fiscal computation and it does not enter casilla 11
(compras totales), which this pack does not declare because nothing in the
Formulario 200's own formulas reads it.

**The Impuesto a las Transacciones (IT) is not a code of this pack.** Ley
N.° 843, Título VI (arts. 72° to 79°), levies a 3 % tax on the gross income
of virtually every economic activity, cumulative at every stage — it is not
a credit-invoice tax like the IVA, has no input-tax mechanism of its own, and
art. 77° lets the annual Impuesto sobre las Utilidades de las Empresas (IUE)
be used, in full, as a pago a cuenta against the IT determined month by
month, until it is exhausted — a credit against a *different* annual tax,
settled outside the monthly document-by-document computation this format's
`taxes.json` and `tax_report.json` express. Modelling it as a `tax` code
would either invent a recoverability rule Ley N.° 843 does not state or
misrepresent a 3 % charge on gross revenue as a VAT-like deduction it is not.
The IT is declared and paid on its own Formulario 400, which this pack does
not carry; account `2134` *Impuesto a las Transacciones (IT) por pagar*
exists in the chart for a company that computes and posts it by hand — see
*What the core could not say*.

## The declaration

`BO-SIN-200` is the Formulario 200, filed monthly on the Oficina Virtual of
the Servicio de Impuestos Nacionales, an authorised financial institution or
a colecturía. This pack's boxes are the Formulario 200 v.5 **Extendido**'s,
which desagregates exportaciones (14), tasa cero (15) and operaciones no
gravadas (505, not declared here) from the general casilla 13; the
**Resumido** version of the same form folds all three into casilla 13 alone.
Declared: 13, 14, 15, 26, 39, 1002, 114, 1004, 909 (impuesto determinado a
favor del Fisco) and 693 (diferencia a favor del contribuyente). **Not
declared**: casilla 16 (retiros y consumos particulares), 17/18 and 27/28
(devoluciones and descuentos, folded instead into a `box_factor: -100`
reduction of the same box the credit note's invoice used), 55 and 30
(reintegros and conciliaciones), 11 and 31 and casilla 1003 (compras no
discriminables and their proportional crédito fiscal, art. 8° of Decreto
Supremo N.° 21530), and the whole of Rubro 3 (deuda tributaria por mora),
Rubro 6 (formas de pago), Rubro 7 (permutas) and Rubro 8 (pagos SIGMA del
sector público) — none of them a rate, a box or an exemption this format's
`tax_report.json` can state; see *What the core could not say*.

**Due date**: `depends_on_taxpayer`. Ley N.° 2492, art. 78°, lets the
Administración Tributaria set the form and the deadline by regulation; in
practice the SIN staggers the IVA's due date between the 13th and the 22nd
of the following month by the last digit of the taxpayer's NIT, published
each year in its own calendario tributario. The exact day depends on each
taxpayer's NIT and is not a rule this pack can compute.

## The statements

`BO-EF-BG` (Balance General) and `BO-EF-ER` (Estado de Resultados) answer
art. 331° of the Código de Comercio, which requires the memoria anual of a
sociedad anónima to contain both — without prescribing their lines. Their
presentation (current/non-current assets and liabilities; income by nature)
follows the NIIF adopted as a supplementary framework by the Resolución
CTNAC N.° 01/2012, the closest thing to a State-sanctioned model Bolivia
publishes. `xbrl` is null everywhere: no fact-key taxonomy of a Bolivian
filing is mapped here.

## The golden quarter

A trading company, January to March 2026, filing monthly: eleven documents
and five payments. It sells at 13 % por dentro with a partial return, sells
one export, sells one Ley N.° 366 zero-rate book sale; it buys at 13 % with
full credit, buys a service (alquiler) with full credit, buys packaging
destined exclusively to the book sale with no credit, and buys again at 13 %
in the closing month, leaving a saldo a favor del contribuyente. Four
payments settle a document exactly (one of them net of a purchase credit
note); one is an advance with no invoice yet, left open and unreconciled.
Every figure of `golden/vat_return.json`, `golden/trial_balance.json` and
`golden/statements.json` was checked by hand against the postings — the
"por dentro" arithmetic above, worked line by line — before the golden test
runner confirmed it.

## What the core could not say

1. **Clearance-adjacent e-invoicing.** `einvoicing` can only say "mandatory,
   from this date, this profile"; it has no way to say "valid only once the
   SIN's Sistema de Facturación has issued the daily code (CUFD) the document
   is built from." The pack leaves the fields empty and says so in the
   reference, like Peru's and Mexico's clearance systems.
2. **The Impuesto a las Transacciones**, for the reasons given above — a
   cascading tax on gross income whose credit runs the other way, into an
   annual income tax, rather than into itself. See `docs/international.md`.
3. **The Impuesto sobre las Utilidades de las Empresas (IUE)**, Bolivia's
   corporate income tax, is not computed by this pack — no country's pack
   computes an income tax — but its declared fiscal-year closing (31
   December for a trading company, under the schedule Decreto Supremo N.°
   24051, art. 39°, sets by economic sector) is what `defaults.
   fiscal_year_default: "calendar"` reads.
4. **A deadline that runs off the last digit of the NIT**, the same shape
   Peru's and Mexico's packs meet with their own last-digit rules.
5. **Compras no discriminables and their proportional crédito fiscal**
   (Decreto Supremo N.° 21530, art. 8°, casillas 31 and 1003 of the
   Formulario 200): a purchase serving both taxed and untaxed activities at
   once, apportioned by a formula this pack's postings do not carry.
6. **Ekwo does not issue a Factura, Nota Fiscal o Documento Equivalente.**
   Every document of this pack carries the `factura_not_issued` mention for
   that reason; a company still has to issue its real tax document through
   its own Sistema de Facturación modality and record the operation in Ekwo
   separately.

## For a reviewer

The first things to read against practice: the effective rate 14,9425 and
whether it reproduces 13 % of the facturado to the cent on figures larger
than this pack's golden quarter; the `BASE13`/`BASE26` reconstruction of
casillas 13 and 26 from the net base and the tax, against how a Bolivian
accountant actually reads those two casillas; the choice of `exempt` over
`export` for the Ley N.° 366 zero rate; the treatment of `BO-C-13-NOCRED`
with no casilla at all; and whether the chart's 130 accounts, invented for
lack of an official one, match how a Bolivian trading company actually keeps
its books.
