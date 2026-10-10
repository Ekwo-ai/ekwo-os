# Kuwait

Everything Kuwait adds to Ekwo, as data: a chart of accounts, the journals, the
two "not subject" tax codes that carry every sale and purchase a Kuwaiti
business books, and the statement of financial position and income statement
of full IFRS. The format is [`docs/packs.md`](../../docs/packs.md); this file
says where the content came from, so that a Kuwaiti accountant can disagree
with a specific sentence.

**Status: `community`.** Nobody who practises in Kuwait has reviewed it. The
figures are replayed against a year of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

This is a jurisdiction **without a turnover tax**: no
`tax_report.json`, no `tax_payable`/`tax_receivable` role, no tax-clearing
account, and a `vat_return.json` golden whose boxes are empty.

## Sources

| What | Text | Where |
|---|---|---|
| No VAT, no excise law; none in the 2026-2030 fiscal plan | VATupdate, 24 July 2026 (secondary) | `vatupdate.com` |
| Domestic minimum top-up tax: Decree-Law No. 157 of 2024, Ministerial Decision No. 55 of 2025 | KPMG Kuwait (secondary) | `kpmg.com/kw` |
| Full IFRS for all companies; IFRS for SMEs not adopted | IFRS Foundation, Jurisdictional Profile: Kuwait (2016) | `ifrs.org` |
| Keeping the books: journal and inventory book ten years, correspondence and documents five years | Commercial Law, Decree-Law No. 68 of 1980, articles 31-32 | `lawskw.com` (reproduction of the Gazette text) |
| Where a taxpayer registers and files | Ministry of Finance, Tax Services System | `mof.gov.kw` |

The absence of a VAT rests on secondary sources, not on an official Ministry
text. The Commercial Law is cited from a legal-information reproduction, not
the Official Gazette. Law No. 46 of 2006, Law No. 19 of 2000, Decree No. 3 of
1955 and Law No. 2 of 2008 are cited, not quoted. The IFRS profile dates from
2016 and should be checked against the current Ministerial Decrees.

## The chart of accounts

Kuwait prescribes no chart. This one has four digits, flat, blocked so
that every range reaches one line of the statements, 113 accounts. It carries
the charges a Kuwaiti company books: provisions for income tax, zakat, the
National Labour Support Tax and the KFAS contribution (2060-2063), the 5%
contract retention awaiting a tax clearance (2064), social security
contributions and the end-of-service indemnity provision (2330, 6024). Only
trade receivables and trade payables are `reconcilable`. Names are in English
(see `i18n/README.md`); `defaults.language` is `ar`.

## Taxes

`KW-S-NA` and `KW-P-NA`, `not_subject`, rate 0, `vat_category` `O`, `base`
postings only. The 2025 reform is **not** a VAT: Decree-Law No. 157 of 2024
creates a 15% domestic minimum top-up tax for in-scope multinational groups
(fiscal years opened from 1 January 2025), replacing income tax, zakat and the
National Labour Support Tax for them.

## Not modelled

Income tax of 15% on foreign corporate bodies (Decree No. 3 of 1955, Law No. 2
of 2008); the 5% retention on contract payments; zakat 1% (Law No. 46 of 2006);
National Labour Support Tax 2.5% (Law No. 19 of 2000); KFAS contribution 1%;
the domestic minimum top-up tax; GCC customs duties; social security
contributions; payroll. None has a tax code.

## Statements, year, invoice, e-invoicing

`KW-IFRS-SFP` and `KW-IFRS-IS`, built on the IAS 1 headings; no statement of
other comprehensive income (no OCI account in the chart). `fiscal_year_default`
is `calendar`: the Companies Law (No. 1 of 2016) leaves the year to the
articles; calendar is the usual choice.
`numbering` is `free`; retention periods are those of Commercial Law article
32. `tax_point: invoice_date` is a convention, not a rule. No mention is
declared: no text found requires one. `einvoicing.obligation` is `none`, with
no Peppol Authority for Kuwait found.

## Reviewing this pack

A local accountant should check: (1) the Arabic terminology, supplied by nobody
yet; (2) articles 31-32 of the Commercial Law against the Gazette; (3) that no
VAT or selective-tax law has been promulgated since 10 October 2026; (4) the
scope of the end-of-service indemnity and social security accounts; (5) the
default interest rule for commercial debts; (6) the IFRS decrees, with the
current Ministry of Commerce text.
