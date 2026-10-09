# Nicaragua

Everything Nicaragua adds to Ekwo, as data: an original chart of accounts built
on the NIIF for SMEs that the country's accounting profession has adopted, the
journals, the Impuesto al Valor Agregado (IVA) at its single rate of 15 % with
the 0 % rate on exports and the exemptions of the law, the fields of the monthly
IVA return, a balance sheet and an income statement, and the sentences an
invoice needs. The format is [`docs/packs.md`](../../docs/packs.md); this file
says where the content came from and which decisions it rests on, so that a
Nicaraguan accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Language: `es`.** Every label of this pack is written in Spanish, the language
of the law and of the Dirección General de Ingresos (DGI). No second language
is declared: Nicaragua prescribes no catalogue of accounts, so the chart is this
pack's own and has no official wording in another language to carry as `i18n`.

**Status: `community`.** Nobody who files a Nicaraguan return has reviewed it.
The figures are replayed against a quarter of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

Nicaragua is outside the common system of VAT of Directive 2006/112/EC, so
`supabase/seed/00_territories.sql` carries a row for `NI` with `eu_vat_scope`
`none`: no `exemption_code` (the three taxes that declare a `vat_category` set
it to `null`) and no `intracom_*` treatment. `NIO` (Nicaraguan córdoba, two
decimals) is added to `00_currencies.sql`.

## The monthly return is due on the 5th, not on the 15th

**The filing date of the IVA return is the fifth calendar day of the month that
follows the period; the fifteenth is the payment date of the taxpayers that are
neither "principales" nor "grandes contribuyentes".** This is the opposite of
what most accountancy web pages and fiscal calendars say, and the pack's
deadline follows the text:

- Ley No. 822, art. 139, numeral 1, as amended by Ley No. 987 of 27 February
  2019 (La Gaceta No. 41 of 28 February 2019), says the IVA is paid "a más
  tardar el quinto día calendario subsiguiente al período gravado".
- The Reglamento (Decreto No. 01-2013), art. 97, numeral 2, letter c), as
  amended by Decreto No. 08-2019 (La Gaceta No. 53 of 15 March 2019), says "la
  declaración del IVA debe realizarse a más tardar el quinto día calendario del
  mes siguiente al período gravado".
- The same Reglamento, art. 98, numeral 3, splits the payment: the fifth day for
  the principal and large taxpayers, "los demás contribuyentes podrán realizar
  su pago hasta el día quince (15) del mes siguiente". Large taxpayers also make
  an advance payment on the first fortnight (art. 98, numeral 4).
- The text before the reform said fifteen days, and the DGI's Disposición
  Administrativa General No. 04-2013 (still on the web, and the origin of the
  "15th" every calendar repeats) was written against it.

So `tax_report.json` declares `day_of_month_after_period` with `day: 5`. The
format holds one date per return and has no word for "the payment of some filers
is ten days later"; the 15th is written in the rule's `legal_reference`. The
DGI's own site refused every automated request from the machine this pack was
written on, so no current DGI notice could be read to confirm the 2019 reform has
not itself been replaced: **this is the first point for a local accountant to
check.** The text of the law and of the Reglamento was read in a private
compilation of La Gaceta (see Sources).

## Electronic invoicing: none is mandatory

`einvoicing.obligation` is `none`, `profile` and `mandatory_from` are null. A
Nicaraguan invoice is either a printed invoice carrying the *pie de imprenta
fiscal* of a printer the DGI has authorised, or one issued by a computerised
billing system the DGI has authorised for that taxpayer (Disposición Técnica
No. 09-2007, under articles 81 and 126(4) of the Código Tributario). Such a
system is an authorisation to use software; it is neither a structured format nor
a clearance regime, and the printed copy remains the document. The DGI's
Plan Estratégico Institucional 2022-2026 says it will develop an electronic
invoicing system, and a project funded by the Inter-American Development Bank was
announced in 2016: an announced project is not a statute, and this pack found no
open source for a resolution that imposes electronic invoicing on anybody.
Commercial pages that say otherwise were not corroborated. The DGI's web servers
could not be read, so re-check before relying on this.

Every document therefore carries the mention `dgi_invoice_not_authorized`: an
Ekwo document supports the operation for tax purposes only if the company's
billing system is itself authorised by the DGI.

## Sources

Eight texts are in the register of `pack.json`, each opened on 9 October 2026
unless noted: the Ley de Concertación Tributaria (Ley No. 822) with its reforms
and its Reglamento (a private compilation of La Gaceta, since the official
repository of the Asamblea Nacional serves only plain `http` and the original,
unreformed text); the DGI's Disposición Administrativa General No. 04-2013 (the
pre-reform deadlines); the Disposición Técnica No. 09-2007 (computerised
billing); the Plan de Arbitrios of Managua (Decreto No. 10-91); two pages on the
Colegio de Contadores Públicos de Nicaragua (CCPN) and its adoption of the NIIF
for SMEs; and the DGI's VET portal and Plan Estratégico, whose servers refused
every automated request, so the portal page could not be read and the plan was
read as a search-engine excerpt. The pack states this in the title of those two
entries.

## The chart of accounts

**Nicaragua prescribes no catalogue of accounts.** The profession's body, the
CCPN, sets accounting standards: by a resolution of 30 May 2010 it adopted the
NIIF for SMEs for annual periods beginning after 1 July 2011, and the Nicaraguan
generally accepted principles (PCGA) remain accepted in practice. This pack's
chart is therefore original, with its own four-digit numbering; every block of
codes corresponds to a line of `NI-EF-ESF` or `NI-EF-ER`. It carries 141
accounts, named for Nicaraguan practice: INSS and INATEC contributions, the
*treceavo mes* (aguinaldo), vacation and seniority-indemnity accruals, the
IVA, IR and municipal-tax control accounts.

Two decisions:

- **The IVA control accounts are split into four.** `2131` "IVA - Débito fiscal"
  and `1141` "IVA - Crédito fiscal" are posting accounts; `2132` "IVA por pagar"
  and `1142` "IVA - Saldo a favor por cobrar" are the settlement accounts of the
  monthly return, reconcilable, and distinct from the posting accounts, which the
  format requires.
- **Only customers, suppliers and the IVA settlement accounts are
  `reconcilable`.** Never the bank, the cash or the suspense account.

The manifest names every role the neighbouring packs name (receivable, payable,
suspense, rounding, retained earnings and loss, the two current-year results,
sales, purchase, bank, cash, `fx_gain`, `fx_loss`, `tax_payable`,
`tax_receivable`) and `fiscal_year_default: calendar`: the ordinary fiscal
period runs from 1 January to 31 December (Ley No. 822, art. 50), and the
Administración Tributaria may authorise special periods, which this pack does
not model.

## The taxes

One national tax, no regional or sectoral rate in force. The 7 % rate on
electricity of Ley No. 971 ended in 2020 and is not modelled.

| Code | Rate | Treatment | Return boxes | Reference |
|---|---|---|---|---|
| `NI-V-15` | 15 % | domestic sale | `VG` / `DF` | Ley 822, arts. 107, 109, 114 |
| `NI-V-EXP` | 0 % | export | `VEXP` | art. 109 (zero rate, not an exemption) |
| `NI-V-EXO` | 0 % | exempt sale | `VEXO` | arts. 111, 127, 136 |
| `NI-C-15` | 15 % | purchase, creditable | `CG` / `CF` | arts. 116-119 |
| `NI-C-15-NOCRED` | 15 % | purchase, not creditable | `CNOCRED` | art. 120 |
| `NI-C-EXO` | 0 % | exempt or untaxed purchase | `CEXO` | arts. 127, 136 |
| `NI-C-IMP-15` | 15 % | import | `IMP` / `CFIMP` | arts. 107, 128-130 |

The export is **a taxable supply at 0 %**, not an exempt one (art. 107, numeral
3, lists exports among the taxed acts), so the IVA paid on its inputs stays
creditable and a surplus can be offset or refunded (arts. 121, 140).

Exemptions are declared as **one code for the whole of articles 127 and 136**,
as the neighbouring Central American packs do: the objective exemptions of
article 127 are lists drawn by ministerial agreements and published in La
Gaceta, which this pack did not transcribe, and the exact numeral of an exempt
supply belongs in the entry, not in the code.

## The return

`NI-DGI-IVA`: monthly, filed through the DGI's Ventanilla Electrónica Tributaria
(VET). The VET's own screens and field numbers were not readable (see above), so
the boxes carry **acronyms of this pack's own** and the name of the concept the
law has the taxpayer declare, never invented field numbers. `TOTAL` is the
débito fiscal minus the crédito fiscal (art. 117); a negative result is a
surplus carried to the following periods (art. 140).

## Statements

`NI-EF-ESF` (statement of financial position) and `NI-EF-ER` (income statement
by function) follow sections 4 and 5 of the NIIF for SMEs. Nicaragua imposes no
statement layout of its own.

## What the core could not say

None of these is patched in the core; each is also written up in
[`docs/international.md`](../../docs/international.md) under *From Nicaragua*.

- **Taxes on turnover that are not invoice taxes.** The *pago mínimo definitivo*
  (Ley 822, art. 61: 3 % for large, 2 % for principal and 1 % for other
  taxpayers, on gross income; the monthly advance of the annual IR) and the
  Impuesto Municipal sobre Ingresos (IMI: 1 % of gross monthly income under the
  Plan de Arbitrios — Decreto No. 455 outside Managua, Decreto No. 10-91 in
  Managua — declared monthly to the alcaldía by the 15th) are levied on turnover,
  not on an invoice line. They are not VAT codes, and this pack adds none. The
  chart has the accounts (`1143`, `2134`, `2137`, `5312`, `551`) so that a
  company can book them.
- **Withholdings.** Nicaragua has withholdings of IR at source, declared and
  paid by the 5th calendar day of the following month (Reglamento, art. 44 as
  amended in 2019). The format has no withholding mechanism at the line of a
  tax; the accounts `1144`, `2135` and `2136` exist, and the amounts are booked
  by hand. Whether and when IVA itself is withheld was not researched, and no
  rule for it is modelled.
- **Proportional credit** (art. 121). A company with taxable and exempt supplies
  credits only the proportional part of IVA that cannot be assigned to either.
  The pack offers the two extremes (`NI-C-15` and `NI-C-15-NOCRED`) and no
  ratio.
- **The refund procedure** for zero-rated exports (art. 140) is an
  administrative claim, not a rate or a box.
- **Tax point.** The law takes the first of the invoice, the payment and the
  delivery (arts. 125, 133); the format's `invoice_if_issued` takes the invoice.
- **Two payment dates for one return**, and the advance payment of large
  taxpayers (see above).
- **No fiscal e-invoice and no clearance**: nothing in Ekwo talks to the DGI.

## Where a Nicaraguan accountant should look first

1. The filing date (5th) and its relation to the payment date (15th), after the
   2019 reform, against the DGI's current notices and the VET calendar.
2. The 1 % IMI rate outside Managua: the original Plan de Arbitrios (Decreto No.
   455) set 2 %, and the reductions to 1 % come from later reforms this pack read
   only through secondary summaries.
3. Whether the *pago mínimo definitivo* and the IR/IVA withholding accounts match
   how a company in the reader's municipality and taxpayer category books them.
4. The chart of accounts, which is an original construction.
5. The exemption lists of article 127, which are ministerial and were not
   transcribed.
