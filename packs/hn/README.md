# Honduras

Everything Honduras adds to Ekwo, as data: an original chart of accounts
inspired by the IFRS for SMEs (NIIF para las PYMES) that the country's
standard-setter, the Junta Técnica de Normas de Contabilidad y de Auditoría
(JUNTEC), has adopted, the journals, the Impuesto Sobre Ventas (ISV) at its
general rate of 15 % and its 18 % rate, zero-rated exports and the general
exemptions of the law, the lines of the monthly Declaración Jurada del
Impuesto Sobre Ventas (form 201), a balance sheet and an income statement, and
the sentences an invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Honduran accountant can
disagree with a specific sentence rather than with the whole.

**Language: `es`.** Every label of this pack is written in Spanish, the
language of the law and of the Servicio de Administración de Rentas (SAR). No
second language is declared.

**Status: `community`.** Nobody who files a Honduran return has reviewed it.
The figures are replayed against a quarter of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

Honduras is outside the common system of VAT of Directive 2006/112/EC: no
`exemption_code`, no `intracom_*` treatment, and `vat_category` is not
declared on any tax of this pack, since it declares no e-invoicing profile.
Currency `HNL`, the Honduran lempira, two decimals.

## Invoicing: authorised numbering ranges, no electronic invoice

**No statute or SAR agreement makes electronic invoicing mandatory at
2026-10-09, and `einvoicing.obligation` is `none`.** The regime in force is
Acuerdo 481-2017 (Reglamento del Régimen de Facturación, Otros Documentos
Fiscales y Registro Fiscal de Imprentas), reformed by Acuerdos 609-2017,
725-2018 and 817-2018. Every taxpayer who transfers goods or provides services
issues a fiscal receipt, either pre-printed by a printer (*imprenta*)
authorised by the SAR or produced by a system registered as a *autoimpresor*.
The SAR assigns each range of invoices a *Código de Autorización de Impresión*
(CAI) with a last date of issue. A self-printing system can be digital, but it
is a variant of the same range-authorisation régimen and not an exchange of
structured documents between parties.

Ekwo is not a registered self-printing system and requests no CAI range. So
every document carries the mention `cai_not_issued`: *this document is not an
invoice authorised by the SAR; only an invoice from an authorised printer or a
registered self-printer supports the operation for tax purposes.* The number
the pack declares (`{CODE}-{NNNNNNNN}`) is the accounting entry number, not the
fiscal number inside a CAI range.

## Sources

Each rate, box and deadline cites an official text in
`certification.sources`:

- **Decreto-Ley 24 of 1963, Ley del Impuesto Sobre Ventas**, SEFIN consolidated
  text. That copy is *updated to 12 January 2004*, so it shows the old 12 % and
  15 % rates; it is cited for the articles the later reforms left alone
  (art. 3 base, art. 5-A tax point, art. 8 responsible parties and withholding
  agents, art. 11 declaration and payment within the first ten calendar days,
  art. 12 debit and credit, art. 15 exemptions, art. 6 last paragraph: exports
  at zero rate).
- **Decreto 278-2013** (La Gaceta 33,316, 30 December 2013, in force
  1 January 2014): art. 16 sets the general rate at 15 % and 18 % on alcoholic
  drinks, beer and cigarettes "as well as business-class air tickets"; art. 17
  rewrites the basic-basket list (Annex I); art. 18 rewrites the exempt
  services of art. 15(d).
- **SAR help for form 201** and the **SAR "Impuestos y Declaraciones" page**
  (ISV due the 10th, DMC due the 8th, withholding declarations), **Acuerdo
  SAR-236-2024** (Oficina Virtual) and the **Oficina Virtual** portal.
- **Acuerdo 481-2017** and the SAR invoicing page; the **Código de Comercio**
  (Decreto 73-50) and the **JUNTEC** model of financial statements.

The Oficina Virtual portal blocks automated link checks, so `pack check
--links` reports it unreachable; its address is the one the SAR's own pages
give.

## The chart of accounts

There is no statutory chart in Honduras: the Código de Comercio asks for
organised double-entry books, and the JUNTEC adopted the IFRS for SMEs, which
sets the content of statements, not account numbers. `accounts.csv` is
therefore this pack's own numbering, in Spanish, with 141 accounts. Honduran specifics: IHSS, RAP and INFOP employer
contributions, thirteenth-month (*aguinaldo*) and fourteenth-month salary,
municipal taxes, the *aportación solidaria*, the property tax.

The article numbers of the Código de Comercio on bookkeeping are not cited:
secondary sources disagree on them, and part of those provisions moved to the
JUNTEC framework with Decreto 189-2004.

Roles: `receivable` 1121, `payable` 2111, `tax_payable` 2132 (ISV por pagar,
reconcilable, distinct from the posting accounts 2131 and 1141),
`tax_receivable` 1142, `suspense` 119, `rounding` 544, `fx_gain` 462,
`fx_loss` 542. Only customers, suppliers and the two ISV settlement accounts
are reconcilable; neither the bank nor the cash account is.

## Taxes

All ten taxes start on 2014-01-01, the day Decreto 278-2013 took effect.

| Code | Rate | Form 201 line |
|---|---|---|
| `HN-V-15` | 15 % sale | Ventas en el mercado interno al 15 % |
| `HN-V-18` | 18 % sale | Ventas en el mercado interno al 18 % |
| `HN-V-EXP` / `HN-V-EXP-CA` | 0 %, export outside / inside Central America | the two Exportaciones lines |
| `HN-V-EXO` | exempt | Ventas exentas en el mercado interno |
| `HN-C-15` / `HN-C-18` | purchase with credit | Compras netas … and Crédito por compras |
| `HN-C-EXO` | purchase without credit | Compras exentas / exoneradas |
| `HN-C-IMP-15` / `-18` | import | Importaciones al 15 % / 18 % and their credit |

**The 18 % rate.** Art. 16 of Decreto 278-2013 names alcoholic drinks, beer,
cigarettes and business-class air tickets. It does not name carbonated or
soft drinks (the pre-2014 text of art. 6 only used them to define the price
base), so no code puts them at 18 %. Tobacco products other than cigarettes
were at the higher rate in the pre-2014 text but are not named by the 2013
reform; whether they follow cigarettes to 18 % is for a reviewer to settle.

**Earlier rates (12 % general, 15 % on alcohol and tobacco) are not
declared.** Documents dated before 2014 are outside the pack.

**Exemptions.** One exempt code covers art. 15 (Annex I basket, medicines,
education, health, banking, residential rent, rent of commercial premises
under L 5,000 a month, sale of real estate…). The sub-paragraph is cited in
the entry, not in the code. Food prepared for consumption is expressly taxed.
The exemption list has been amended since 2013 and the consolidated text is
older than that; a reviewer should check art. 15 against the current
Gaceta.

**Tax point.** `invoice_if_issued`: for goods the tax arises on the invoice
date or delivery (art. 5-A(a)); for services the earliest of invoice,
performance or payment (art. 5-A(b)), which the format cannot distinguish at
this level.

**A service bought from a supplier abroad carries no ISV in the buyer's
hands.** Art. 1 levies the tax on *"las ventas realizadas en todo el
territorio de la República"*, at import and at each stage of sale; the import
it taxes is the customs import of goods, and no article makes the Honduran
buyer liable for a service a non-domiciled supplier renders wholly from
abroad — a software subscription, hosting, an API. `pack.json` says so in
`not_taxed`, and such a purchase is booked with no tax code. The income tax
withheld on payments to non-residents (Income Tax Law, art. 5) is outside this
pack. The text read was the consolidated version of 2004 on the Secretaría
de Finanzas' site; the territorial rule for services that later reforms
added (art. 17, as reported by secondary sources: a service *partly*
performed in Honduras is performed there) was not read in an official copy,
and a reviewer should confirm that no reform since makes the buyer
self-assess.

## The declaration

`HN-SAR-201` is the monthly *Declaración Jurada del Impuesto Sobre Ventas*,
form 201, determinative, filed **only through the Oficina Virtual** (Acuerdo
SAR-236-2024), due **within the first ten calendar days of the following
month** (art. 11); the SAR moves the date to the next business day when the
10th is not one, which the deadline rule does not compute. The form has four
sections: A (sales), B (purchases, imports), C (credits) and D (settlement).
Boxes here are named after the form's lines; the official help does not number
them, so the pack's box codes are its own. Sections
A, B and the settlement total are modelled; section C is not: carried-over
surplus, payments made in the period, authorised compensation, credit
assignments and withheld tax are filled in by the Oficina Virtual and are not
posted by any document. `TOTAL` is therefore the figure *before* section C.

Taxpayers in the *grandes* and *medianos contribuyentes* categories (and
State institutions) must first file the **Declaración Mensual de Compras
(DMC)**, an informative return distinct from form 201, due the **8th** of each
month; section B of form 201 is then pre-filled from it. The format holds one
return per pack, so the DMC is documented here and not modelled.

**Withholding.** Art. 8 lets the tax authority designate withholding agents;
card issuers and acquirers withhold the ISV on sales paid by card (informative
return code 523 and determinative code 215, due within ten calendar days).
Large taxpayers also withhold 15 % on certain services under Acuerdo
DEI-215-2010. The pack posts no withholding tax; the amounts withheld by third
parties reach form 201 in section C, outside the pack. The list of services
of Acuerdo DEI-215-2010 is not stated here.

## The statements

`HN-EF-ESF` (statement of financial position, current / non-current) and
`HN-EF-ER` (income statement, expenses by nature) follow sections 4 and 5 of
the IFRS for SMEs. The JUNTEC publishes an official model of statements; the
pack's lines are not a transcription of it.

## The golden quarter

Fifteen documents and five payments over January–March 2026, replayed to the
cent: sales at 15 % and 18 %, a credit note, exports outside and inside Central
America, an exempt sale, purchases at 15 % and 18 %, an exempt purchase, a
purchase credit note and two imports at 15 % and 18 %. January settles at L 24
payable, February at L 30 payable, March at a surplus of L 360.

## What the core could not say

- No clearance or authorised-range model: the CAI regime and the
  *autoimpresor* registration are outside the format (see above).
- No second return (the DMC) and no section C of form 201.
- No withholding taxes (card-payment ISV withholding, 15 % withholding by
  large taxpayers).
- A date-shifting deadline (next business day) is not computable.
- The exporter's refund of the credit and the "exonerated" categories
  (diplomats, special regimes) have no tax code of their own.

## For a reviewer

A Honduran accountant should check: the scope of the 18 % rate (tobacco beyond
cigarettes, business-class tickets), the current wording of art. 15 and
Annex I, the Código de Comercio article numbers on bookkeeping, whether
section C and the DMC need modelling, and the account labels.
