# Macao

Everything Macao adds to Ekwo, as data: a chart of accounts, the journals, the
two "not subject" tax codes that carry every sale and purchase a Macao business
books, the balance sheet and the income statement of the General Financial
Reporting Standards, and the Chinese, Portuguese and English wording of all of
it. The format is [`docs/packs.md`](../../docs/packs.md); this file says where
the content came from and which decisions it rests on, so that a Macao
accountant reading the pack can disagree with a specific sentence rather than
with the whole of it.

**Status: `community`.** Nobody who practises in Macao has reviewed it. The
figures are replayed against a year of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

**No tax on turnover.** Macao has none, so this pack has no
`tax_report.json`, no tax-clearing account and no `tax_payable` /
`tax_receivable` role; the golden's `vat_return.json` carries the year with
empty `boxes`.

**The pack is written in Chinese (Traditional)** — `defaults.language` is `zh`,
with the official Portuguese and English declared in `languages`
(`i18n/pt.json`, `i18n/en.json`; see [`i18n/README.md`](i18n/README.md)). Both
are covered label for label, as `ekwo pack check` requires.

## Sources

| What | Text | Where |
|---|---|---|
| The tax laws the territory has; books, accounts and invoices as a taxpayer's duty (art. 36(2)); accounts organised to the accounting standards presumed true (art. 97(2)); in force 1 January 2026 | Lei n.º 24/2024, **Código Fiscal** (Boletim Oficial n.º 53/2024) | `bo.dsaj.gov.mo/bo/i/2024/53/lei24.asp`; Government announcement of 7 January 2026 at `gov.mo/pt/noticias/809035/` |
| Complementary income tax exemption limit | Lei n.º 13/2025 (2026 budget), art. 22 | `bo.dsaj.gov.mo/bo/i/2025/52/lei13.asp` |
| Mercantile books: duty (art. 38), form and currency (art. 46), keeping (art. 49) | Decreto-Lei n.º 40/99/M, Código Comercial | `bo.dsaj.gov.mo/bo/i/99/31/codcompt/codcom0001.asp` |
| The selective consumption tax | Lei n.º 4/99/M and its table | `bo.dsaj.gov.mo/bo/i/99/50/lei04.asp` |
| Who applies which accounting standards; "properly organised accounts" | Regulamento Administrativo n.º 25/2005 and n.º 42/2020 | `bo.dsaj.gov.mo` |
| The standards, their model statements, the 2028 timetable | Professional Accountants Committee: *Guia para a Aplicação das NSRF* (Aviso n.º 2/2024/CPC); 2024 work report | `cpc.gov.mo` |
| Group A filing window, five-year record keeping, signature by an accountant | Financial Services Bureau (DSF), *Profits Tax — Group A* | `dsf.gov.mo/en/tax/tax_introduction/profits_tax_a` |
| Where a return is filed | DSF electronic services | `tax.fi.dsf.gov.mo` |
| No Peppol Authority | OpenPeppol, *Peppol Authorities* | `peppol.org/about/peppol-authorities/` |

**What the texts settle:**

- The code is the **Código Fiscal** (Fiscal Code), not "Código Tributário". It
  is Lei n.º 24/2024, and it says (art. 36(2)(2)) that a taxpayer must hold,
  write up and keep its books, tax-relevant documents, financial statements,
  contracts and invoices — it does not itself prescribe a retention period for
  them. The Código Comercial does.
- Mercantile books and documents are kept **five years** from the last entry
  (Código Comercial, art. 49(1), as amended by Lei n.º 16/2009); the DSF page
  says five years too. The ten-year figure is the original 1999 text. The art.
  46 rule is that values may be stated in any currency provided they are also
  stated in patacas (art. 46(2)).
- The MOP 600,000 exemption limit of Lei n.º 13/2025, art. 22, is fixed "for
  the income of the 2025 economic year" (declared in 2026), with 12 % applying
  to the income above it. It is renewed by each budget law; it is not a
  standing rule, and it is a tax parameter, not something this pack models.
- The DSF's English pages call the complementary income tax *Profits Tax*;
  the Portuguese name is the *imposto complementar de rendimentos*.
- The standards' timetable (2015 or 2021 IFRS suite, and from when) is set
  out under "The statements".

## No tax on turnover, checked

The Código Fiscal lists the taxes it brings together: the industrial
contribution, professional tax, urban property contribution, complementary
income tax, stamp tax, property transfer and inheritance taxes, tourism tax,
consumption tax and motor vehicle tax. None is a value added tax, a goods and
services tax or a general sales tax. **Macao has no general tax on sales.**

**Two codes, both at 0 %, both `not_subject`:** `MO-S-NA` on every sale and
`MO-P-NA` on every purchase — domestic, exported or imported, because no tax
on turnover applies differently to any of them. `vat_category` is `O`,
`exemption_code` stays null (the VATEX list names articles of a European
directive that does not reach a Macao seller).

**The selective consumption tax is not a general tax** and is not modelled. Lei
n.º 4/99/M taxes the products of its table when produced in or brought into the
territory; after the amendments by Lei n.º 8/2008, 7/2009, 11/2011 and 9/2015
only two groups have products subject to it: spirits of 30 % alcohol or more
(10 % ad valorem on the CIF value plus MOP 20 per litre) and tobacco (specific
amounts per unit or kilogram). The beer-and-wine group and the fuel group
carry a note that no product is subject. It is the importer's or producer's
duty on those goods, not a tax an invoice line carries.

## Levies left out of the pack

None has a tax code, a box or an account of its own beyond an expense account.

- **Complementary income tax** (Lei n.º 21/78/M; "Profits Tax" on the DSF's
  English pages): Group A (organised accounts) files Form M/1 between April
  and July, signed by the taxpayer and by the responsible accountant, and
  keeps its books for five years (DSF). Exemption limit and 12 % rate above it
  for 2025 income: Lei n.º 13/2025, art. 22. The ordinary table (3–12 %) rests
  on secondary sources; the statute itself should be checked. The pack provides
  `2060 Provision for complementary tax` and `6470 Complementary tax charge`.
- **Stamp tax** (Lei n.º 17/88/M, amended by the Código Fiscal's law);
  **industrial contribution** ("business tax", Lei n.º 15/77/M),
  **professional tax** (Lei n.º 2/78/M), **urban property contribution** (Lei
  n.º 19/78/M), **tourism tax** (Lei n.º 19/96/M), **motor vehicle tax**: named
  by the Código Fiscal, not modelled. Accounts `6115` and
  `6205` take the expense.
- **Social security**: the Social Security Fund's mandatory contributions are a
  fixed monthly amount per employee, split between employer and employee
  (MOP 90, of which 60 employer, according to secondary sources; the Fund's
  guide should be checked). `2050` and `6020` carry them; no rate is encoded.
- **Gaming levies, customs duties, the global minimum tax (Pillar Two).** No
  Macao statute for the last is cited; its status should be checked. None is modelled.

## The chart of accounts, and why this one

Macao prescribes no chart (Código Comercial, art. 38 and 46 say how books are
kept, not what they contain). The chart is written, not transcribed: four
digits by class (`1` assets … `6` operating expenses), flat, ranges chosen so
that each reaches one line of the model statements. It carries 109 accounts.
Only `1100` (customers) and `2000` (suppliers) are `reconcilable`; bank, cash
and suspense are not. `1030 Foreign currency bank account` is where a Hong
Kong dollar account goes: the Hong Kong dollar circulates widely in Macao, the
pack documents it and builds no mechanics for it (the core handles another
currency; the Código Comercial only asks that amounts also be stated in
patacas).

## The statements

Two tiers exist. Regulamento Administrativo n.º 25/2005, art. 4, applies the
IFRS-based **Financial Reporting Standards** to concessionaires, insurers,
institutions under the financial-system regime, offshore institutions and
public limited companies and partnerships limited by shares, and lets an entity
bound by special law to keep organised accounts choose between them and the
**General Financial Reporting Standards** (一般財務報告準則; *Normas Sucintas de
Relato Financeiro*, NSRF) for each whole year. The Professional Accountants
Committee, which since Regulamento Administrativo n.º 42/2020 sets the
standards, republished the NSRF unchanged and moved the Financial Reporting
Standards from the 2015 to the 2021 IFRS suite by Aviso n.º 2/2024/CPC
(adopted 18 December 2024): mandatory from **1 January 2028**, optional from
1 January 2026. The Committee's report gives new criteria for the
IFRS tier (public limited companies above MOP 100 million revenue and 100
employees, plus concessionaires and regulated financial institutions); these
criteria rest on the report, and the notice itself should be checked.

**The pack takes the NSRF balance sheet and income statement**, in the order of
the Committee's model financial statements, because they are the framework any
company can use. An entity under the IFRS tier presents more (a statement of
comprehensive income, cash flows, notes); this pack does not model them. The
current year's result is on its own line until allocated, where the model puts
it inside retained results. Foreign-exchange gains are read as other income and
losses as finance costs; a Macao accountant should confirm.

`closing_style` is `retained_earnings`; `fiscal_year_default` is `calendar`
(the budget laws speak of an economic year; that a Group A taxpayer may choose
another year end should be confirmed).

## On the invoice

- **Numbering is `free`.** No text cited prescribes invoice numbering.
- **No payment term, no late-payment interest.** Default-interest rules of
  general civil law are not covered and should be checked.
- **No mention.** No text found imposes a taxpayer number or any other mention
  on an invoice; the pack would rather say so than invent one.
- **`tax_point` is `invoice_date`, a convention** — see
  [what the packs do not say yet](../../docs/international.md#what-the-packs-do-not-say-yet).
- **E-invoicing: `none`.** No mandate; no Peppol
  Authority for Macao.

## Reviewing this pack

A Macao accountant should check: the line mapping of the statements against
Annex III of the standards (the model's line order was followed; the annex's
own Chinese captions should be compared); the reading of exchange differences;
the standards' scope criteria from 2028; whether `calendar` is the right
default; the account names in Chinese and Portuguese; and the absence of any
invoice mention.
