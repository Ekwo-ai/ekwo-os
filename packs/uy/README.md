# Uruguay

Everything Uruguay adds to Ekwo, as data: a plan of accounts of Ekwo's own
numbering (Uruguay prescribes none), the value added tax with its 22 % basic
rate and its 10 % minimum rate, the two zero-rated exports — of goods and of
software services — the exemption of a real-estate rental, the fields of the
Impuesto al Valor Agregado section of the monthly Formulario 1376, a minimal
balance sheet and income statement, and the sentences an invoice needs. The
format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on, so that a Uruguayan
accountant reading the pack can disagree with a specific sentence rather than
with the whole of it.

**Status: `community`.** Nobody who files a Uruguayan return has reviewed it.
The figures are replayed against a quarter of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

## Ekwo does not issue a Uruguayan CFE

**A Uruguayan invoice is a Comprobante Fiscal Electrónico (CFE), and a CFE
exists only once it is signed by an authorised electronic issuer and carries
a Código de Autorización de Emisión (CAE) the Dirección General Impositiva
(DGI) grants by range.** Decreto N° 36/012, of 8 February 2012, and
Resolución DGI N° 798/012 fix that regime: e-Factura documents an operation
with another taxpayer, e-Ticket a sale to a final consumer, and both are
generated, signed and reported by the issuer itself — an authorisation of
numbering and a report that follows, closer to Chile's own DTE than to
Mexico's clearance by a third party (a PAC) before the document exists. The
obligation reached every taxpayer of the country in stages from 2012; since
1 January 2025 every taxpayer of the Impuesto al Valor Agregado, including
the reduced IVA mínimo regime, is an electronic issuer from the moment of
registration, with a short list of exceptions (small-scale farming, value
added in construction alone, non-resident income taxpayers, Monotributo and
Monotributo Social MIDES).

Ekwo writes no CFE XML, requests no CAE and signs nothing. So:

- `einvoicing` names **no profile**, although the obligation and its date
  exist and are declared (`obligation: mandatory`, `mandatory_from:
  2025-01-01`). `profile` is a profile built on EN 16931 that a brick of
  `packages/formats/` writes, and the CFE is neither; the format has no word
  for "signed by the issuer and reported to an administration under its own
  numbering authorisation" — see *What the core could not say* below and
  Chile's own pack, which reads the same way for the same reason.
- Every document carries the mention `cfe_not_issued`: *this document is not
  a CFE; only a CFE with a CAE supports the transaction for tax purposes in
  Uruguay.*
- The number a document gets in Ekwo is the number of the accounting entry,
  correlative by journal, not a number of a CAE, which only a range the DGI
  authorised can supply (`numbering: sequential`).

What a company does today: register as an electronic issuer with the DGI (or
with a certified software provider), obtain its CAE ranges, and record the
transaction in Ekwo.

## Sources

Every rate, field, mention and statement carries its own `legal_reference`
and the key of the text it is in. The register in `pack.json` holds ten
texts, every one opened on 26 September 2026: the **Texto Ordenado 2023**
(Decreto N° 101/024, of 4 April 2024), Título 10, in the version the DGI
itself keeps current — it replaced the 1996 Texto Ordenado after twenty-seven
years and renumbered every article, so this pack cites the 2023 numbering
throughout and not the 1996 one that most secondary literature still quotes;
the reglamentario Decreto N° 220/998, for the taxative list of service
exports and the detail of the exemptions Título 10 refers to it for; the Ley
N° 16.060, de Sociedades Comerciales, for the balance sheet and income
statement duty; the electronic-invoicing decree and two of the DGI's own
pages confirming the 2025 universal date; two DGI pages transcribing the
Formulario 1376; the DGI's own 2026 deadlines calendar; and the DGI's e-Factura
portal.

One note for whoever checks the links: the two Formulario 1376 pages are the
DGI's own written guides to its online PADI application, not a printable
form with pre-numbered boxes the way Chile's Formulario 29 is — the line
numbers this pack transcribes (8, 9, 11, 12, 14, 15, 16, 18, 19, 22, 43) are
the ones the DGI's own guides name in the running text (*"línea 8"*, *"línea
17"*, *"línea 27"*) and the ones the PADI screens themselves print beside
each field, confirmed against a training reproduction of those screens by a
university-adjacent accounting course (not cited in `certification.sources`,
because it is not itself an official text — only used here to read numbers
the DGI's own prose names but does not lay out as a table).

## The chart of accounts

**Uruguay prescribes no chart of accounts.** The Ley N° 16.060, art. 87, asks
the administrators of a company to formulate an inventory and a balance
general within four months of the close of the fiscal year, and art. 89
refers to "normas contables adecuadas" — today the International Financial
Reporting Standards the Decreto N° 291/014 adopts, or the simplified regime
that same decree opens to smaller companies — without naming a single code
or a single account, the same position Chile's own Código Tributario, art.
17, takes and for the same reason this pack gives it: an "adequate
accounting" duty that a chart of accounts satisfies rather than a chart the
law hands down.

This pack's `accounts.csv` is therefore **Ekwo's own numbering**, classes 1
to 5 with no official correlate, built so that every account reaches a line
of the balance sheet or the income statement below. Four decisions:

- **The IVA control accounts are three, not two.** `1105` *IVA Compras -
  Crédito Fiscal* and `2103` *IVA Ventas - Débito Fiscal* are where every
  invoice posts its tax; `2106` *IVA por Pagar* (`tax_payable`) and `1108`
  *IVA a Favor - Remanente* (`tax_receivable`) are where the Formulario 1376
  settles, kept apart from the two posting accounts and reconcilable, as the
  format requires — a control account a payment matches against has to be
  the one thing the postings of the period never touch themselves.
- **The suspense account is `1150` *Partidas Pendientes de
  Identificación*.** No text asks for one; a debit balance is reported as an
  asset and a credit balance as a liability, the solution Chile's and
  Mexico's own packs use for the same reason.
- **The result of the year goes to `3105` / `3106`**, and the close carries
  it to `3103` / `3104` (`closing_style: result_accounts`) — the shape art.
  87 of the Ley N° 16.060 implies, since the balance the administrators
  present to the company is not yet allocated until the company acts on it.
- **Payroll liabilities follow the Banco de Previsión Social (BPS)**, the
  single collecting body for Uruguayan social security: `2109` and `2110`
  keep the employee's and the employer's contributions apart, the way a
  Uruguayan payslip itself does, beside the ordinary provisions for
  aguinaldo (a thirteenth salary, Ley N° 12.840) and salario vacacional that
  every employer accrues.

## Taxes

| Code | Rate | Treatment | Box (sale / purchase) |
|---|---|---|---|
| `UY-S-22` | 22 % | domestic sale | base 12, tax 16 |
| `UY-S-10` | 10 % | domestic sale, minimum-rate good | base 11, tax 15 |
| `UY-S-0-EXP-BIENES` | 0 % | export of goods, art. 5° | base 9 |
| `UY-S-0-EXP-SERVICIOS` | 0 % | export of services, Decreto 220/998 art. 34.11.b) | base 9 |
| `UY-S-EXE-INMUEBLE` | — | exempt, art. 38.2.C) (real-estate rental) | base 8 |
| `UY-P-22` | 22 % | domestic purchase | tax 19 |
| `UY-P-10` | 10 % | domestic purchase, minimum-rate good | tax 19 |

**One general rule, no cash-basis exception.** Art. 3° of Título 10 presumes
the taxable event configured on the date of the invoice, "sin perjuicio de
las facultades de la Administración de fijar la misma, cuando existiera
omisión, anticipación o retardo en la facturación" — unlike Chile, where a
service's own devengo waits for collection, Uruguay ties every operation to
the invoice date by the same presumption, so this pack declares
`documents.tax_point: invoice_if_issued` for every tax and needs no
`cash_basis` posting anywhere.

**Exports are excluded from the territorial scope of the tax, not zero-rated
in the strict European sense, and the zero recovers through ordinary
input credit.** Art. 5° reads "no lo estarán aquellas exportaciones de
bienes … y no lo estarán aquellas exportaciones de servicios que determine
el Poder Ejecutivo" — an export never enters the base the tax is computed
on, rather than entering it and being relieved of the rate. What an exporter
keeps is the ordinary right of art. 14, inciso quinto, to deduct the tax
that integrates, directly or indirectly, the cost of what it exported — the
same mechanism `UY-P-22` and `UY-P-10` already give on every purchase,
regardless of what it is destined for, the way Chile's own pack reads its
art. 36. The list of what counts as an exported service is Decreto N°
220/998, art. 34, a taxative enumeration of twenty-seven numerals (call
centres, software, hotels for non-residents, international transport, and
more); this pack transcribes one, software development (numeral 11, literal
b), the golden scenario's own case.

**The minimum rate is a closed list of goods and services, not a lower rate
by nature.** Art. 36 names bread, fish, meat, rice, cereal flour, dairy,
common salt, sugar, yerba, coffee, tea, soap, cooking oils and, in a later
literal, hospitality services for lodging — this pack transcribes one line
of the list, rice (literal A), the golden scenario's own case, and gives no
general rule for "food" or "services" beyond what art. 36 actually names.

**Withholding and the pro-rata of mixed activities are not here.** Uruguay
has no general VAT withholding regime this pack transcribes, and a taxpayer
with both taxable and exempt sales apportions its input credit under a
mechanism the Formulario 1376 itself computes month by month — see *What
this pack does not transcribe*.

## The declaration

`UY-F1376-IVA` is the Impuesto al Valor Agregado section of the Formulario
1376, *IVA CEDE mensual*, filed monthly by the CEDE group and by the División
Grandes Contribuyentes through the DGI's PADI application. This pack
transcribes **eleven lines** — 8, 9, 11, 12 and 14 of the sales panel; 15, 16
and 18 of the same panel's own IVA column; 19, 43 and 22 of the
"Determinación de IVA" panel — out of a form that also carries advances of
IRAE, of the Impuesto al Patrimonio and of ICOSA, none of them value added
tax.

- **The deadline depends on the taxpayer.** The DGI fixes, in the calendar
  it publishes every year, a day between the 22nd and the 24th of the month
  following the one declared, by the last digit of the taxpayer's Registro
  Único Tributario (RUT) — this pack declares `depends_on_taxpayer` and cites
  the 2026 calendar, the same choice `docs/packs.md` records for France's own
  CA3.
- **Box 19 is a simplification of two official lines.** The Formulario 1376
  splits the period's deductible input credit between line 19 (attributable
  to taxable domestic sales) and line 27 (attributable to exports), through
  a monthly and cumulative proportion table the format has no formula for —
  see *What this pack does not transcribe*. This pack posts the whole of a
  period's input credit to line 19, which understates line 27 and
  overstates line 19 for a taxpayer that also exports, with no effect on the
  total credit or on the balance due, since both lines feed the same
  determination.
- **The carry-forward chain is not modelled beyond one remanente.** The
  official line 22 itself nets against excedentes de meses anteriores this
  pack does not carry from one period to the next; the golden scenario never
  runs a remanente into a second month, so the simplification is never
  exercised there.

## The statements

`UY-BAL` (balance sheet) and `UY-RES` (income statement) answer arts. 87 and
90 of the Ley N° 16.060: a company's administrators must formulate a balance
general and an estado de resultados that state clearly the position of the
company and the results of its ordinary and extraordinary operations.
Uruguay prescribes no line structure for either statement outside the
International Financial Reporting Standards, whose text is not reproduced
here — this is a minimal structure of Ekwo's own, grouped by current/fixed
assets and liabilities and by the usual subtotals of gross, operating,
pre-tax and net profit, on the plan of accounts above. `xbrl` is null
everywhere: the DGI's own filings carry no taxonomy this pack could map.

## The golden quarter

A trading company that also develops software and rents out a commercial
unit, January to March 2026, filing monthly: twelve documents and four
payments. It sells goods at the basic rate, sells rice at the minimum rate,
credits back part of a goods sale, exports grain, exports a custom software
development, rents out a commercial unit under the exemption of art. 38.2.C,
and sells more goods in March with no payment recorded against it; it buys
goods at the basic rate, receives a credit note for part of them, buys
bookkeeping services at the basic rate, buys rice for resale at the minimum
rate, and buys more goods in March with no payment recorded either. One
inbound payment is left unmatched, a customer advance with nothing to settle
yet.

Read by hand against the Formulario 1376's own lines: January's line 16
(IVA ventas, tasa básica) is 8 800 (11 000 from V1, less 2 200 from its
credit note V3); its line 15 (tasa mínima) is 1 600, from V2 alone. February
adds no domestic sale of its own (V4, V5 and V6 are all outside the base or
exonerated); March's line 16 is 10 560, from V7 alone. On the purchase side,
January's line 19 is 13 420 — C1's and C3's net credit (9 900 less 1 980 =
7 920) plus C2's own 5 500; February's is 5 000, from C4 alone; March's is
7 040, from C5 alone. Every period's line 43 or line 22 is the plain
difference of lines 18 and 19, floored at zero.

## What this pack does not transcribe

The Uruguayan section of
[`docs/international.md`](../../docs/international.md) states each of these
as a gap of the core rather than a choice of this pack. In short:

1. **The CFE itself.** No component of `packages/formats/` writes a
   Uruguayan CFE's XML, requests a CAE or signs anything; see *Ekwo does not
   issue a Uruguayan CFE* above.
2. **The rest of the Formulario 1376.** Advances of IRAE, of the Impuesto al
   Patrimonio and of ICOSA, the IRPF withholding on a sole trader's own
   drawings, and the certificate-of-credit and carry-forward chain of lines
   20 to 42 — none of it is value added tax and none of it is transcribed.
3. **The proportional split of input credit** between lines 19 and 27 of the
   official form, for a taxpayer that both sells domestically and exports —
   see *The declaration* above.
4. **The annual regime of the Formulario 2178**, filed by taxpayers outside
   the CEDE group and the División Grandes Contribuyentes, with monthly
   provisional advances and an annual settlement — a different form, on a
   different cadence, that this pack's single monthly report does not
   represent; see `docs/international.md`.
5. **Any withholding of VAT** a private party is made to practise, and the
   tax on digital services a foreign, non-resident supplier is itself made
   to register and pay (Ley N° 19.535, art. 4) — neither is a reverse charge
   the local buyer books, and this pack invents no posting for either
   without a verified mechanism to transcribe.
6. **The other twenty-six numerals of Decreto N° 220/998, art. 34** (export
   services beyond software development) and the other literals of arts. 36
   and 38 (minimum-rate goods and exemptions beyond rice and real-estate
   rental) — this pack transcribes one representative case of each, not the
   whole list.

## For a reviewer

The first things to read against practice: the choice of `invoice_if_issued`
as the single tax point, with no cash-basis exception anywhere; the
simplification of the official form's lines 19/27 split into a single line
19; the day-22-to-24 deadline against the calendar a CEDE taxpayer actually
reads for its own RUT; and whether the minimal statements should give way to
a mapping of a Uruguayan IFRS presentation by a professional who holds it.
