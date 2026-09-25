# Chile

Everything Chile adds to Ekwo, as data: a plan of accounts of Ekwo's own
numbering (Chile prescribes none), the value added tax with its 19 % rate and
its two exemptions for exports, the exemption of an educational
establishment's own tuition income, the reverse charge on a service received
from a supplier not established in Chile, the fields of the Impuesto al Valor
Agregado section of the monthly Formulario 29, a minimal balance sheet and
income statement, and the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Chilean accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Chilean return has reviewed it.
The figures are replayed against a quarter of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

## Ekwo does not issue a Chilean DTE

**A Chilean invoice is a Documento Tributario Electrónico (DTE), and a DTE
exists only with a folio drawn from a Código de Autorización de Folios
(CAF).** Decreto Ley N° 825, art. 54 (as it now reads after Ley N° 20.727):
every invoice, purchase invoice, dispatch guide, receipt and credit or debit
note is an electronic document, signed by the issuer, whose folio is taken
from a range the Servicio de Impuestos Internos (SII) authorises in advance —
the issuer assigns and uses the folio itself, inside that range, and sends
the signed document to the SII. That is closer to a continuous, near
real-time report of what was issued than to Mexico's clearance, where a
third party (a PAC) certifies the document *before* it exists: in Chile the
document is valid the moment its issuer signs it with a folio of an
authorised CAF, and reporting it to the SII is a separate, following step.
The obligation reached every company of the country on 1 February 2018,
closing a rollout that began in November 2014 for the largest taxpayers.

Ekwo writes no DTE XML, requests no CAF and signs nothing. So:

- `einvoicing` names **no profile and no date**, although the obligation
  exists. `profile` is a profile built on EN 16931 that a brick of
  `packages/formats/` writes, and the DTE is neither; the format refuses an
  obligation with a date and no profile, and has no word for "valid from the
  issuer's own signature, reported afterwards" — see *What the core could not
  say* below and Mexico's own pack, which leaves the same fields empty for
  the same reason.
- Every document carries the mention `dte_not_issued`: *this document is not
  a DTE; only a DTE with the folio of an authorised CAF supports the
  transaction for tax purposes in Chile.*
- The number a document gets in Ekwo is the number of the accounting entry,
  not a folio of a CAF, which only a range the SII authorised can supply
  (`numbering: sequential`).

What a company does today: request its folios and sign its DTE through the
SII's own free portal or a certified software provider, and record the
transaction in Ekwo.

## Sources

Every rate, field, mention and statement carries its own `legal_reference`
and the key of the text it is in. The register in `pack.json` holds eight
texts, every one opened on 25 September 2026: the consolidated Decreto Ley
N° 825 the SII itself publishes; article 74 of the Ley sobre Sociedades
Anónimas, also mirrored by the SII; the electronic-invoice law and the SII's
own announcement of its universal date; the thirty-day payment law; and the
Formulario 29's own instructions and the printed form, both from the SII.

Two notes for whoever checks the links. `www.bcn.cl`'s Ley Chile application
did not render for an automated request here — it needs a browser behind it,
the same limitation `docs/packs.md` already documents for Légifrance and
Riigi Teataja — so the thirty-day payment law is cited there and confirmed
independently through secondary legal literature rather than through a
second reading of the same page. `wwwmat.sat.gob.mx`-style mirrors are not
needed here: every SII page answered directly.

## The chart of accounts

**Chile prescribes no chart of accounts.** The Código Tributario, art. 17,
asks only for "contabilidad fidedigna" kept in books the SII authorises — it
names no code and no account. A company sets up whatever chart its own
management or its auditor wants, and since 2009 most sociedades anónimas
fiscalised by the Comisión para el Mercado Financiero report under IFRS,
whose text belongs to the IFRS Foundation and is not reproduced here.

This pack's `accounts.csv` is therefore **Ekwo's own numbering**, classes 1
to 5 with no official correlate, built so that every account reaches a line
of the balance sheet or the income statement below. Any company can install
a different chart of its own instead; this is the one `ekwo init` proposes.
Beyond the accounts a first invoice or payslip needs, it carries the detail
a trading or manufacturing company's books actually use day to day: fixed
assets and their accumulated depreciation by nature rather than in one
lump account, raw materials, work in progress, finished goods and
merchandise as separate lines of `Existencias`, the other receivables and
payables a company carries beside its customers and suppliers, the payroll
liabilities a Chilean employer withholds and remits — AFP, Isapre or
Fonasa, the mutual de seguridad and the Seguro de Cesantía — and expense
accounts by nature (remuneraciones, arriendos, honorarios, publicidad and
the rest) beside the two `Gastos de Administración y Ventas` and `Costo de
Ventas` a smaller company can post everything to instead.

Five decisions:

- **The IVA accounts follow the cash-basis pairs a services tax needs.**
  `2104` *IVA Débito Fiscal Servicios (Devengado no Percibido)* and `2102`
  *IVA Débito Fiscal* on the sale side, `1106` *IVA Crédito Fiscal Servicios
  (Devengado no Pagado)* and `1105` *IVA Crédito Fiscal* on the purchase
  side — see *Taxes* below for why services need a transition account and
  goods do not.
- **The declaration settles to `2103` *IVA por Pagar*** (`tax_payable`) or,
  when a period's input credit exceeds its output tax, to `1107` *IVA
  Crédito Fiscal Remanente* (`tax_receivable`) — art. 26 of the D.L. N° 825
  carries that excess forward to the following period. Both are kept apart
  from the four posting accounts above (`1105`, `1106`, `2102`, `2104`) and
  reconcilable, as the format requires: a control account a payment or a
  later declaration settles against has to be the one thing the postings of
  the period never touch themselves.
- **The suspense account is `1150` *Partidas Pendientes de
  Identificación*.** No text asks for one; a debit balance is reported as an
  asset and a credit balance as a liability, the same solution Mexico's pack
  uses for the same reason.
- **The result of the year goes to `3105` / `3106`**, and the close carries
  it to `3103` / `3104` (`closing_style: result_accounts`) — the shape art.
  74 of the Ley N° 18.046 implies, since the results it has the directors
  present to the shareholders' meeting are not yet allocated to retained
  earnings until that meeting acts on them.
- **No corrección monetaria account.** Until the 2015 reform of the Ley
  sobre Impuesto a la Renta (Ley N° 20.780, complemented by Ley N° 20.899),
  Chilean tax law required every non-monetary asset, liability and equity
  account to be restated once a year for inflation, with the net effect
  posted to a *corrección monetaria* result account of its own; a company
  reporting under IFRS in a non-hyperinflationary economy carries no such
  restatement in its financial books at all, and the mechanism that
  remains for tax purposes now runs inside the renta líquida imponible the
  annual Formulario 22 computes, not through a monthly posting this pack's
  documents or its Formulario 29 section reach. Ekwo posts what a document
  or a payment records as it happens, in nominal pesos, the same way every
  other pack in this repository does; a company whose auditor still
  restates its own books for inflation adds the account and the year-end
  entry itself, outside what this pack carries.

## Taxes

| Code | Rate | Treatment | Devengo |
|---|---|---|---|
| `CL-S-19-BIENES` | 19 % | domestic sale, goods | delivery (the general rule) |
| `CL-S-19-SERVICIOS` | 19 % | domestic sale, services | collection (`cash_basis`) |
| `CL-S-0-EXP-BIENES` | 0 % | export of goods, art. 12 D | invoice/delivery |
| `CL-S-0-EXP-SERVICIOS` | 0 % | export of services, art. 12 E N° 16 | invoice/delivery |
| `CL-S-EXE-EDU` | — | exempt, art. 13 N° 4 (education) | invoice/delivery |
| `CL-P-19-BIENES` | 19 % | domestic purchase, goods | delivery |
| `CL-P-19-SERVICIOS` | 19 % | domestic purchase, services | collection (`cash_basis`) |
| `CL-P-FSR-19` | 19 % | reverse charge, service from abroad, art. 11 e) | invoice |

**One country rule, split by the shape of the operation — exactly as
France's pack is.** Art. 9°, letra a), of the D.L. N° 825 devenga the tax, as
a general matter, on the date of the invoice or receipt; but art. 55 requires
that invoice to be issued *at the same moment* as the delivery of goods, and
*at the moment the remuneration is collected or made available* for a
service. So in the ordinary case the two dates coincide with the general
rule, and this pack declares `documents.tax_point: delivery_date` — matching
the goods case, which is the country's default operation — and gives the two
services taxes `cash_basis: true` instead of a second country-wide value the
format has no room for, the same solution `docs/packs.md` records for
France's own delivery-versus-collection split.

**Exports are exempt, not zero-rated in the strict sense, and the zero
recovers through art. 36.** Art. 12, letra D, exempts "the goods exported in
their sale abroad"; art. 12, letra E, N° 16, does the same for a service
rendered to somebody with no domicile or residence in Chile that the
Servicio Nacional de Aduanas qualifies as an export. Neither carries VAT
forward; what an exporter has instead is art. 36's right to recover the VAT
it paid on its own purchases and imports for that activity — which is why
`CL-P-19-BIENES` and `CL-P-19-SERVICIOS` give ordinary input credit on every
purchase regardless of what it is destined for, the way the law does, and
line 37 (Cód. 593) of the Formulario 29 is where the exporter's own refund
request is declared. That refund mechanism itself — the request, its
certificate, its own line of the form — is outside this pack: see *What this
pack does not transcribe*.

**The reverse charge of art. 11, letra e).** A Chilean company that receives
a service from a supplier neither domiciled nor resident in Chile is itself
the taxpayer of the VAT on that service — not the supplier, who issues no
document Chilean law governs. `CL-P-FSR-19` books this the way the framework
already books an EU intra-Community acquisition: one `base` posting and two
`tax` postings, one crediting the same account and box a domestic sale's
débito fiscal would (`2102`, Cód. 502) and one, at `factor: -100`, debiting
the crédito fiscal account and box a domestic purchase would (`1105`, Cód.
520) — so the self-assessed VAT appears in both the débitos and the créditos
of the Formulario 29, netting to zero, the same way the standard's own
Estonian intra-Community-acquisition example nets two sides of one
operation. It carries no `vat_category`: no invoice EN 16931 governs exists
to hold one, for the same reason `import` and `foreign_services_received`
carry none anywhere in this framework.

**Withholding, IEPS-style specific taxes, and partial credit are not here.**
Chile has no general VAT withholding regime comparable to Mexico's
retenciones — see *What this pack does not transcribe*.

## The declaration

`CL-F29-IVA` is the Impuesto al Valor Agregado section of Formulario 29, the
monthly *Declaración Mensual y Pago Simultáneo de Impuestos*, filed and paid
through Tesorería or an authorised bank. This pack transcribes **only the
seven codes its own taxes feed** — Cód. 20 (exports), 142 (exempt), 502 and
538 (débito and its total), 520 and 537 (crédito and its total), 89 and 77
(the amount payable and the credit carried forward) — out of the roughly one
hundred and forty the whole form carries for every tax and withholding it
declares at once. See *What this pack does not transcribe* for the rest.

- **The deadline is the 12th of the month following the one being
  declared** (art. 64, inciso primero). A taxpayer who declares and pays
  through the SII's own internet channel gets an administrative extension —
  to the 20th with payment, the 28th without — but that extension is a
  resolution of the Servicio, not the law's own answer to every taxpayer,
  and this pack declares the day art. 64 gives everybody, the same choice
  `docs/packs.md` records for the United Kingdom's own quarter.
- **No partial deduction is modelled.** Every purchase this pack's taxes
  reach gives full input credit, which is the ordinary case; a taxpayer with
  exempt sales of its own has to apply the proportionality the D.L. N° 825
  itself sets out (art. 23 N° 3), which this pack does not compute — the
  same limit Mexico's own pack states of its acreditamiento.

## The statements

`CL-BAL` (balance sheet) and `CL-RES` (income statement) answer art. 74 of
the Ley N° 18.046: a Chilean sociedad anónima's board presents its
shareholders a "balance general" and an "estado de ganancias y pérdidas"
that must "clearly reflect the company's financial position at the close of
the year and the profits obtained or losses suffered during it." Chile
prescribes no line structure for either statement outside IFRS, whose text
is not reproduced here — this is a minimal structure of Ekwo's own, grouped
by current/non-current assets and liabilities and by the usual subtotals of
gross, operating, pre-tax and net profit, on the plan of accounts above. A
sociedad de responsabilidad limitada or an EIRL is bound by the Código
Tributario's general "contabilidad fidedigna" duty rather than by art. 74
itself, and can read this same structure as the minimal answer to that
duty. `xbrl` is null everywhere: the SII's own annual filings have their own
formats, none mapped.

## The golden quarter

A trading company that also runs a small training line of business, January
to March 2026, filing monthly: twelve documents and four payments. It sells
goods at 19 %, sells a maintenance service at 19 % collected a month later,
credits back part of a goods sale, exports goods, exports a consulting
service, invoices a training course exempt as an educational establishment's
own docente income, and sells more goods in March with no payment recorded
against it; it buys goods at 19 %, receives a credit note for part of them,
buys a bookkeeping service at 19 % paid a month later, receives a software
subscription from a supplier established abroad under the reverse charge of
art. 11 e), and buys more goods in March with no payment recorded either. One
inbound payment is left unmatched, a customer advance with nothing to settle
yet.

Read by hand against the Formulario 29's own codes: January's Cód. 502 is
152 000 (190 000 from the January goods sale, less 38 000 from its credit
note — the January services sale waits in its transition account);
February's Cód. 502 is 266 000 (95 000 the services sale releases on
payment, plus 171 000 the reverse charge books on its own invoice date);
March's is 114 000, from that month's own goods sale alone. The same
reasoning holds on the crédito side, and every period's Cód. 89 or 77 is the
plain difference of the two totals, floored at zero.

## What this pack does not transcribe

The Chilean section of [`docs/international.md`](../../docs/international.md)
states each of these as a gap of the core rather than a choice of this pack.
In short:

1. **The DTE itself.** No component of `packages/formats/` writes a Chilean
   DTE's XML, requests a CAF or signs anything; see *Ekwo does not issue a
   Chilean DTE* above.
2. **The rest of the Formulario 29.** Cambio de sujeto, the additional tax
   of arts. 37 and 42 (luxury goods, alcoholic and non-alcoholic drinks), the
   specific tax on diesel, retenciones and pagos provisionales mensuales of
   the Ley de la Renta, and the postponement-of-IVA regimes the same form
   carries — none of it is a value added tax and none of it is transcribed.
3. **The exporter's own refund of art. 36 and 27 bis**, requested on its own
   line of the Formulario 29 (Cód. 593) rather than netted automatically
   against the ordinary input credit this pack already gives.
4. **Proportional input credit** for a taxpayer with exempt sales of its
   own (art. 23 N° 3).
5. **A region conditioning a tax**, such as the reduced rates or exemptions
   some Chilean free-trade zones (Zona Franca de Iquique and Punta Arenas)
   carry: this pack's rate is uniform across the whole of continental Chile.
6. **Any retención de IVA** a private party is made to withhold — Chile has
   none of general application comparable to Mexico's arts. 1°-A retenciones.

## For a reviewer

The first things to read against practice: the choice of `delivery_date` as
the general tax point with `cash_basis` carrying the services exception; the
symmetric booking of the art. 11 e) reverse charge; whether the minimal
statements should give way to a mapping of a Chilean IFRS presentation by a
professional who holds it; and the day-12 deadline against the internet
extension a taxpayer who files electronically actually uses in practice.
