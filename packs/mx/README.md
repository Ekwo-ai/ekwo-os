# Mexico

Everything Mexico adds to Ekwo, as data: a chart of accounts built on the SAT
grouping code, the journals, the value added tax with its cash-basis timing,
the border-region rate and the two withholdings a company applies, the fields
of the monthly IVA declaration of a *persona moral*, a minimal balance sheet
and income statement, and the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Mexican accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

It is the first pack of Latin America. The sections below follow the order a
pack of the region will need — chart, electronic invoice, tax, declaration,
statements — and the last one lists what the core could not say, most of
which the next country of the region will meet again.

**Status: `community`.** Nobody who files a Mexican return has reviewed it.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

## Ekwo does not issue a Mexican invoice

**A Mexican invoice is a CFDI, and a CFDI exists only once it is stamped.**
Código Fiscal de la Federación, article 29: the issuer sends the XML of the
Anexo 20 to the SAT or to an authorised certification provider (PAC, article
29 Bis) *before* issuing it; the PAC validates it, assigns the fiscal folio
(UUID) and adds the SAT's digital seal. A printed representation only
"presumes the existence" of the voucher (fraction V).

Ekwo writes no Anexo 20 XML, talks to no PAC and stamps nothing. So:

- `einvoicing` names **no profile and no date**, although the obligation
  exists. `profile` is a profile built on EN 16931 that a brick of
  `packages/formats/` writes, and the CFDI is neither; the format refuses an
  obligation with a date and no profile, and has no word for "valid only once
  a third party certifies it". Its legal reference says what the law requires
  and says in capitals that Ekwo neither generates, stamps nor transmits a
  CFDI. Declaring `cfdi-4.0` would have made the country page promise a
  writer brick and Peppol transmission for Mexico — Spain and Côte d'Ivoire
  leave the profile empty for the same reason.
- Every document carries the mention `cfdi_not_stamped`: *this document is not
  a CFDI; only the stamped CFDI supports the transaction for tax purposes.*
- The number a document gets in Ekwo is the number of the accounting entry,
  not the fiscal folio, which only the SAT assigns (`numbering: sequential`).

What a company does today: stamp the CFDI with a PAC or with the SAT's free
service, and record the transaction in Ekwo. The format of this repository
cannot yet say "mandatory, by clearance"; see *What the core could not say*.

## Sources

Every rate, field, mention and statement carries its own `legal_reference` and
the key of the text it is in. The register in `pack.json` holds **23 texts**,
every one opened on 21 September 2026:

- the consolidated federal laws on the Cámara de Diputados site (LIVA, its
  Reglamento, CFF, LISR, Código de Comercio, LGSM);
- the *Resolución Miscelánea Fiscal para 2026* and its Anexo 24 on the SAT's
  normative minisite;
- the three border-region decrees and the 2013 compiling decree in the Diario
  Oficial de la Federación;
- the SAT pages that publish the filling guides of the *IVA personas morales*
  and *IVA retenciones* declarations, the CFDI 4.0 XSD and catalogue XSD, and
  the portal pages for the declaration, the DIOT, the Anexo 20, the payment
  complement and the PACs;
- the CINIF, for the NIF, named and not transcribed.

Two notes for whoever checks the links. `www.sat.gob.mx` answers `403` to a
request without a browser for its portal pages; the same pages are served on
`wwwmat.sat.gob.mx`, which is where the register points, and every one was
checked by its title (a wrong path there answers `404`). `omawww.sat.gob.mx`
serves the Anexo 20 page over plain HTTP only, which the register refuses. The
guides themselves are PDF files behind a query string with several
parameters; the register points at the page that links each one, and the
Diario Oficial notes by their `codigo` alone, which the DOF redirects to the
dated note.

## The chart of accounts

**Mexico prescribes no chart; it prescribes a grouping code.** Anexo 24 of the
RMF, section A (a), publishes the *código agrupador de cuentas del SAT*, and
rules 2.8.1.5 and 2.8.1.6 require every company keeping electronic accounts
to associate each account of its own catalogue with a first-level subaccount
of that code and to send the catalogue and a monthly trial balance to the SAT.

The pack uses the grouping code itself as the catalogue: **280 codes, 197 of
them postable**, with the official numbers and names of the 2026 Anexo 24.
The rubros (`100`, `100.01`, `200`…) and the major accounts (`101`, `102`…)
are headings; the first-level subaccounts (`101.01`, `102.01`…) are where
entries post. The association the SAT asks for
is then the identity, and a company that needs a finer account opens a
second-level subaccount under the code — which the SAT leaves to it.

Selected: cash, banks, customers, sundry debtors, prepayments, the tax
accounts, inventory, the usual fixed assets and their depreciation, suppliers,
the payroll provisions, the withheld taxes, equity, revenue by tax treatment,
costs, the general expenses a trading or services company books, and the
financing result. Left out: sector accounts (railways, aircraft, biological
assets), the related-party variants beyond customers and suppliers, groups
602 to 606 (selling, administrative and manufacturing expenses, which repeat
most of the subaccounts of 601 — 84 under 602, 82 under 603 and 604), and the
memorandum accounts (800).

Four decisions:

- **The IVA accounts are the SAT's cash-basis pairs.** `209.01` *IVA
  trasladado no cobrado* and `208.01` *IVA trasladado cobrado* on the sale
  side, `119.01` *IVA pendiente de pago* and `118.01` *IVA acreditable pagado*
  on the purchase side. The grouping code is built for the timing of the law,
  and the pack's cash-basis taxes move the tax from the first to the second
  when the invoice is collected or paid.
- **The declaration settles to `213.01` *IVA por pagar*** (`tax_payable`) or to
  `113.01` *IVA a favor* (`tax_receivable`). A balance in favour is a claim on
  the administration under LIVA article 6: credited against the following
  months or refunded.
- **The suspense account is `121.01` *Otros activos a corto plazo*.** The
  grouping code has no suspense account; a debit balance is reported as an
  asset and a credit balance on line 218, other current liabilities.
- **The result of the year goes to `305.01` / `305.02`**, and the close carries
  it to `304.01` / `304.02` (`closing_style: result_accounts`).

## The electronic invoice, in detail

| What | Where |
|---|---|
| Issuer: RFC, name, tax regime (*régimen fiscal*) | CFF art. 29-A, fr. I; catalogue `c_RegimenFiscal` |
| SAT folio, SAT seal, issuer seal | CFF art. 29-A, fr. II; assigned at stamping |
| Place (postal code) and date of issue | CFF art. 29-A, fr. III |
| Receiver: RFC, name, postal code of tax domicile, tax regime, **use of the CFDI** | CFF art. 29-A, fr. IV; RMF 2026 rule 2.7.1.29; catalogue `c_UsoCFDI` |
| Goods or services with the SAT's product and unit keys | CFF art. 29-A, fr. V |
| Taxes transferred **by rate**, taxes withheld | CFF art. 29-A, fr. VII (a) |
| Payment in one instalment (PUE) or deferred (PPD), form of payment | CFF art. 29-A, fr. VII (b) and (c); RMF 2026 rule 2.7.1.32 (payment complement) |
| Cancellation only with the receiver's acceptance | CFF art. 29-A, fourth paragraph; RMF 2026 rule 2.7.1.35 for the exceptions |

These are fields of the CFDI XML, not sentences. The pack carries them in this
table and in the legal references; the core has no column for the use of the
CFDI or the tax regime of a party (see the gaps below). The mentions it does
print are the stamping warning, the PPD sentence for a cash-basis line, the
export article and the exempt articles.

## Taxes

| Code | Rate | Treatment | In force | Declaration fields |
|---|---|---|---|---|
| `MX-S-16` | 16 % | domestic, on collection | from 1.1.2010 | G16 / C16 |
| `MX-S-8-RF` | 8 % | border region, on collection | 1.1.2019 – 31.12.2026 | GRF / CRF |
| `MX-S-16-RET4` | 16 %, 4 % withheld by the customer | road freight | from 1.1.2010 | G16 / C16 / RET |
| `MX-S-0` | 0 % | art. 2o.-A | from 1.1.2010 | G0O |
| `MX-S-EXP` | 0 % | export, art. 29 | from 1.1.2010 | G0E |
| `MX-S-EXE` | — | exempt, arts. 9, 15, 20 | from 1.1.2010 | EXE |
| `MX-S-NOBJ` | — | not subject, art. 4o.-A | from 1.1.2010 | NOB |
| `MX-P-16` | 16 % | creditable on payment | from 1.1.2010 | P16 / A16 |
| `MX-P-8-RF` | 8 % | border region, on payment | 1.1.2019 – 31.12.2026 | PRF / ARF |
| `MX-P-16-RET23` | 16 %, two thirds withheld | fees, rent, commissions from individuals | from 1.1.2010 | P16 / A16 |
| `MX-P-16-RET4` | 16 %, 4 % withheld | road freight received | from 1.1.2010 | P16 / A16 |
| `MX-P-IMP-16` | 16 % | import, paid with the *pedimento* | from 1.1.2010 | PIM / AIM |
| `MX-P-0` | 0 % | | from 1.1.2010 | P0 |
| `MX-P-EXE` | — | exempt | from 1.1.2010 | PEX |

The 16 % rate dates from the reform of LIVA article 1o. published on
7 December 2009; the 15 % before it is not transcribed.

**The tax falls due on collection.** LIVA articles 11, 17 and 22 make the
tax due when the consideration is actually collected, and article 5o.,
fraction III, makes it creditable only once paid. The 16 % and 8 % taxes are
therefore `cash_basis`, the country's `tax_point` is `payment_date`, and the
golden year shows an invoice collected half in the next month (V2) and a
supplier paid two months late (C4).

**The border region.** The 8 % is not a rate of the law: it is the credit of
50 % of the 16 % rate granted by the decrees of the northern (DOF 31-12-2018,
article Décimo Primero) and southern (DOF 30-12-2020, article Décimo) border
regions, to a business registered in the SAT's list of beneficiaries, for
goods delivered or services rendered in its establishments in the region.
Both decrees run until 31 December 2026 (DOF 31-12-2025), which is the
`valid_to`; an extension is a new code, never an edit. The regions are lists
of municipalities, not states, and the pack cannot condition the code on
them: the bookkeeper chooses it.

**Withholding, and why it is on the invoice.** A *persona moral* withholds
two thirds of the IVA an individual charges it for professional services,
rent or commissions (LIVA art. 1o.-A, fr. II (a) and (d); RLIVA art. 3o.,
fr. I), and 4 % of the value of road freight (fr. II (c); RLIVA art. 3o.,
fr. II). The pack carries both as a purchase tax whose third posting sends
the withheld share to `216.10` *Impuestos retenidos de IVA*, where it waits
for the separate *IVA retenciones* declaration, and the freight case on the
sale side, where the carrier's withheld 4 % lands in the field *IVA
retenido*. Three limits, all written in the taxes themselves:

- the law withholds **on payment**, and a cash-basis tax in this format takes
  exactly one tax posting, so the withholding codes are booked on the invoice
  date instead;
- two thirds is written `-66.667 %`, the precision the format stores, and the
  withholding drifts by a cent from 1 500 pesos of tax upwards;
- the **ISR** withheld on the same payments (10 %, LISR articles 106 and 116)
  cannot sit on the same line, because a line carries one tax.

**Not here:** IEPS (the special tax on production and services), the import
of intangibles and services from non-residents (LIVA art. 24, fr. II, III and
V), the proportional crediting of articles 5o., fraction V, and 5o.-B for a
business with exempt activities, the *RESICO* and the other regimes of individuals,
and every ISR computation.

## The declaration

`MX-IVA-PM` is the monthly *pago definitivo* of IVA of a *persona moral*,
filed on the SAT's platform "Presenta tu declaración de pagos definitivos de
IVA del ejercicio 2024 en adelante". It has no numbered lines: the fields are
named, and the pack gives each an acronym of its own (`G16`, `C16`, `P16`,
`A16`, `RET`, `CAC`, `SAF`…) with the field's exact name. The sections are the
guide's: *IVA a cargo*, *IVA acreditable*, *Determinación*.

- The form computes the tax fields as value × rate; the pack posts the tax
  the ledger recorded, which is the same figure to the rounding of each CFDI.
  The two "not collected / not paid because of the incentive" fields are the
  one place the pack writes the multiplication (`rate: 8`).
- *Cantidad a cargo* = total IVA due − IVA withheld − creditable IVA − other
  amounts in favour + other amounts due. The guide's sentence omits the
  creditable IVA; LIVA article 5o.-D subtracts it and the section shows the
  field right above.
- The fields fed by working papers (the adjustment of article 5o.-A, other
  amounts, a balance in favour brought forward) are declared and fed by
  nothing.
- **Due date**: article 5o.-D says the 17th of the following month; article
  5.1 of the 2013 compiling decree moves it by one to five working days
  according to the sixth digit of the RFC, except for the taxpayers it lists.
  The rule is therefore `depends_on_taxpayer`.
- The SAT pre-fills the declaration from the CFDI it stamped. The values Ekwo
  computes are what to compare them with, not a substitute for them.

**Not transcribed**: the *IVA retenciones* declaration (a second form, filed
with the same monthly payment), the **DIOT** (LIVA art. 32, fr. VIII; RMF rule
4.5.1: a statement per supplier, due during the following month), the
electronic accounting files of Anexo 24 (catalogue and trial balance in XML),
and the annual declaration.

## The statements

`MX-SAT-ESF` (balance sheet) and `MX-SAT-ER` (income statement) answer LGSM
article 172, (C) and (D): a statement of the financial position at year end
and a statement of the results, "duly explained and classified". Their lines
are the major accounts of the grouping code under its own rubros — current
and non-current assets and liabilities, equity; revenue, costs, expenses,
comprehensive financing result — with the subtotals of gross, operating,
pre-tax and net profit. That is a minimal structure the SAT publishes, not
the presentation of NIF B-6 and NIF B-3, whose text belongs to the CINIF and
is not reproduced here. `xbrl` is null everywhere: the SAT's annual
declaration and the ISSIF have their own formats, none mapped.

## The golden year

A trading company, *persona moral*, filing monthly, January to April 2026:
16 documents and 11 payments. It sells at 16 % with one invoice collected in
halves, sells from a Tijuana establishment at 8 %, exports, sells at 0 % and
takes back part of it, invoices freight to a customer who withholds 4 %,
leaves one invoice uncollected; it buys at 16 %, rents premises from an
individual and withholds two thirds, imports with a *pedimento*, buys at 8 %
and pays two months later, receives freight and withholds 4 %, buys exempt
and 0 % goods, receives a credit note and pays an advance with no invoice.

Credit notes carry non-cash-basis taxes on purpose: the scenario format
refuses to match a refund to a credit note, and a cash-basis credit note
nobody matches would wait on its transition account for ever.

## What the core could not say

The Mexican section of [`docs/international.md`](../../docs/international.md)
states each of these as a change to the core. In short:

1. **Clearance.** `einvoicing` can say "mandatory" only for a profile, and
   has no way to say "valid only once a third party certifies it"; the
   country page promises a writer brick and Peppol for any declared profile.
   The pack therefore leaves the fields empty and says it in the reference.
2. **Withholding.** A cash-basis tax takes one tax posting; a withholding due
   on payment cannot be one. Two thirds cannot be stored exactly. VAT and ISR
   withholding cannot share a line.
3. **Zero and exempt on collection.** A cash-basis tax needs a tax posting, so
   a 0 % or exempt value is declared on the invoice date, not on collection.
4. **A region that is a list of municipalities**, and a condition on the
   seller (registered in the list of beneficiaries) the five words of
   `conditions` do not have.
5. **Two more forms**: *IVA retenciones* and the DIOT.
6. **The CFDI data of a party**: tax regime, postal code of the tax domicile,
   use of the CFDI.
7. **A deadline shifted in working days** by a digit of the taxpayer's RFC.

## For a reviewer

The first things to read against practice: the selection of the grouping
code; the cash-basis wiring through 209.01/208.01 and 119.01/118.01; the
sign and place of the freight withholding in *IVA retenido*; the formula of
*Cantidad a cargo*; the end date of the border-region codes; and whether the
minimal statements should give way to a mapping of NIF B-6 and B-3 by a
professional who holds them.
