# Chile

Everything Chile adds to Ekwo, as data: a plan of accounts of Ekwo's own
numbering (Chile prescribes none), the value added tax with its 19 % rate and
its two exemptions for exports, the exemption of an educational
establishment's own tuition income, the reverse charge on a service received
from a supplier not established in Chile, the fields of the Impuesto al Valor
Agregado section of the monthly Formulario 29, a minimal balance sheet and
income statement, and the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on.

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
from a range the Servicio de Impuestos Internos (SII) authorises in advance;
the document is valid the moment its issuer signs it, and sending it to the
SII is a separate, following step. The obligation reached every company on
1 February 2018, closing a rollout that began in November 2014.

Ekwo writes no DTE XML, requests no CAF and signs nothing. So:

- `einvoicing` names **no profile and no date**, although the obligation
  exists: `profile` is an EN 16931 profile a brick of `packages/formats/`
  writes, the DTE is neither, and the format refuses a date with no profile.
- Every document carries the mention `dte_not_issued`: *this document is not
  a DTE; only a DTE with the folio of an authorised CAF supports the
  transaction for tax purposes in Chile.*
- The number a document gets in Ekwo is the number of the accounting entry,
  not a CAF folio (`numbering: sequential`).

What a company does today: request its folios and sign its DTE through the
SII's own free portal or a certified software provider, and record the
transaction in Ekwo.

## Sources

Every rate, field, mention and statement carries its own `legal_reference`
and the key of the text it is in. The register in `pack.json` holds eight
texts: the consolidated Decreto Ley N° 825 published by the SII; article 74
of the Ley sobre Sociedades Anónimas; the electronic-invoice law and the
SII's announcement of its universal date; the thirty-day payment law; and the
Formulario 29's instructions and the printed form, both from the SII. The
thirty-day payment law is cited on `www.bcn.cl` (Ley Chile) and rests on
secondary legal literature; the statute itself should be checked.

## The chart of accounts

**Chile prescribes no chart of accounts.** The Código Tributario, art. 17,
asks only for "contabilidad fidedigna" kept in books the SII authorises — it
names no code and no account. Since 2009 most sociedades anónimas fiscalised
by the Comisión para el Mercado Financiero report under IFRS, whose text
belongs to the IFRS Foundation and is not reproduced here.

This pack's `accounts.csv` is therefore **Ekwo's own numbering**, classes 1
to 5 with no official correlate, built so that every account reaches a line
of the balance sheet or the income statement; it is the one `ekwo init`
proposes. It carries fixed assets and their accumulated depreciation by
nature, raw materials, work in progress, finished goods and merchandise as
separate lines of `Existencias`, other receivables and payables, the payroll
liabilities a Chilean employer withholds and remits — AFP, Isapre or
Fonasa, the mutual de seguridad and the Seguro de Cesantía — and expense
accounts by nature beside the two `Gastos de Administración y Ventas` and
`Costo de Ventas` a smaller company can post everything to instead.

Five decisions:

- **The IVA accounts follow the cash-basis pairs a services tax needs.**
  `2104` *IVA Débito Fiscal Servicios (Devengado no Percibido)* and `2102`
  *IVA Débito Fiscal* on the sale side, `1106` *IVA Crédito Fiscal Servicios
  (Devengado no Pagado)* and `1105` *IVA Crédito Fiscal* on the purchase
  side — see *Taxes* below.
- **The declaration settles to `2103` *IVA por Pagar*** (`tax_payable`) or,
  when a period's input credit exceeds its output tax, to `1107` *IVA
  Crédito Fiscal Remanente* (`tax_receivable`) — art. 26 of the D.L. N° 825
  carries that excess forward. Both are kept apart from the four posting
  accounts above and reconcilable, as the format requires.
- **The suspense account is `1150` *Partidas Pendientes de
  Identificación*.** No text asks for one; a debit balance is reported as an
  asset and a credit balance as a liability.
- **The result of the year goes to `3105` / `3106`**, and the close carries
  it to `3103` / `3104` (`closing_style: result_accounts`) — the shape art.
  74 of the Ley N° 18.046 implies: results stay unallocated until the
  shareholders' meeting acts on them.
- **No corrección monetaria account.** Since the 2015 reform of the Ley
  sobre Impuesto a la Renta (Ley N° 20.780, complemented by Ley N° 20.899),
  the inflation restatement that remains for tax purposes runs inside the
  renta líquida imponible of the annual Formulario 22, not through a monthly
  posting. Ekwo posts in nominal pesos; a company whose auditor still
  restates its books adds the account and the year-end entry itself.

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

**One country rule, split by the shape of the operation.** Art. 9°, letra
a), of the D.L. N° 825 devenga the tax on the date of the invoice or
receipt; art. 55 requires that invoice *at the same moment* as the delivery
of goods, and *at the moment the remuneration is collected or made
available* for a service. So this pack declares `documents.tax_point:
delivery_date`, matching the goods case, and gives the two services taxes
`cash_basis: true`.

**Exports are exempt, and the zero recovers through art. 36.** Art. 12,
letra D, exempts "the goods exported in their sale abroad"; art. 12, letra E,
N° 16, does the same for a service rendered to somebody with no domicile or
residence in Chile that the Servicio Nacional de Aduanas qualifies as an
export. The exporter recovers the VAT it paid on its purchases under art.
36 — which is why `CL-P-19-BIENES` and `CL-P-19-SERVICIOS` give ordinary
input credit on every purchase, and line 37 (Cód. 593) of the Formulario 29
is where the refund request is declared. That refund mechanism is outside
this pack.

**The reverse charge of art. 11, letra e).** A Chilean company that receives
a service from a supplier neither domiciled nor resident in Chile is itself
the taxpayer of the VAT on that service. `CL-P-FSR-19` books one `base`
posting and two `tax` postings, one debiting the crédito fiscal account and
box a domestic purchase would (`1105`, Cód. 520) and one, at `factor: -100`,
crediting the account and box a domestic sale's débito fiscal would (`2102`,
Cód. 502) — the self-assessed VAT nets to zero across the Formulario 29. It
carries no `vat_category`: no EN 16931 invoice exists to hold one.

**Withholding, specific taxes and partial credit are not here** — see *What
this pack does not transcribe*.

## The declaration

`CL-F29-IVA` is the Impuesto al Valor Agregado section of Formulario 29, the
monthly *Declaración Mensual y Pago Simultáneo de Impuestos*, filed and paid
through Tesorería or an authorised bank. This pack transcribes **only the
codes its own taxes feed** — Cód. 20 (exports), 142 (exempt), 502 and 538
(débito and its total), 520 and 537 (crédito and its total), 89 and 77 (the
amount payable and the credit carried forward) — out of the roughly one
hundred and forty the whole form carries.

- **The deadline is the 12th of the month following the one being
  declared** (art. 64, inciso primero). Filing and paying through the SII's
  internet channel gets an administrative extension — to the 20th with
  payment, the 28th without — but that is a resolution of the Servicio, and
  this pack declares the day art. 64 gives everybody.
- **No partial deduction is modelled.** Every purchase gives full input
  credit; a taxpayer with exempt sales of its own has to apply the
  proportionality of art. 23 N° 3, which this pack does not compute.

## The statements

`CL-BAL` (balance sheet) and `CL-RES` (income statement) answer art. 74 of
the Ley N° 18.046: a sociedad anónima's board presents its shareholders a
"balance general" and an "estado de ganancias y pérdidas" that must "clearly
reflect the company's financial position at the close of the year and the
profits obtained or losses suffered during it." Chile prescribes no line
structure outside IFRS, so this is a minimal structure of Ekwo's own,
grouped by current/non-current assets and liabilities and by gross,
operating, pre-tax and net profit. A sociedad de responsabilidad limitada or
an EIRL is bound by the Código Tributario's "contabilidad fidedigna" duty
rather than by art. 74, and can read this structure as the minimal answer to
it. `xbrl` is null everywhere: the SII's annual filings have their own
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

Each of these is a gap of the core rather than a choice of this pack (see
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet)):

1. **The DTE itself** — no XML, no CAF, no signature; see above.
2. **The rest of the Formulario 29.** Cambio de sujeto, the additional tax
   of arts. 37 and 42 (luxury goods, alcoholic and non-alcoholic drinks), the
   specific tax on diesel, retenciones and pagos provisionales mensuales of
   the Ley de la Renta, and the postponement-of-IVA regimes — none of it is a
   value added tax.
3. **The exporter's own refund of art. 36 and 27 bis**, requested on its own
   line of the Formulario 29 (Cód. 593).
4. **Proportional input credit** for a taxpayer with exempt sales of its
   own (art. 23 N° 3).
5. **A region conditioning a tax**, such as the free-trade zones (Zona Franca
   de Iquique and Punta Arenas): this pack's rate is uniform across
   continental Chile.
6. **Any retención de IVA** — Chile has none of general application.

## For a reviewer

The first things to read against practice: the choice of `delivery_date` as
the general tax point with `cash_basis` carrying the services exception; the
symmetric booking of the art. 11 e) reverse charge; whether the minimal
statements should give way to a mapping of a Chilean IFRS presentation by a
professional who holds it; and the day-12 deadline against the internet
extension a taxpayer who files electronically actually uses in practice.
