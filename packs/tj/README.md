# Tajikistan

Everything Ekwo carries for Tajikistan is data: the Ministry of Finance's chart
of accounts for business entities, the value added tax at 14 % (13 % from 2027),
its two reduced rates, the zero rate and the exemptions, a monthly VAT return,
and a balance sheet and an income statement. The format is in
[`docs/packs.md`](../../docs/packs.md); this file says where each line comes
from and what the pack does not do, so that a Tajik accountant can argue with
one sentence rather than with the whole.

**Status: `community`.** No bookkeeper or auditor has read this pack. The
figures are recomputed from a year of books by `tests/golden.test.ts`, which
proves the pack agrees with itself and not that it is right in law.

**Language.** The pack is written in Russian (`defaults.language: "ru"`): the
Tax Code and the Ministry's order were read in their Russian edition, and Russian
is the language of business in the Republic beside the state language, Tajik.
Names of accounts, taxes, boxes and statement lines are Russian; every
`legal_reference` quotes the Russian text. `i18n/en.json` is a working
translation. There is **no `tg` (Tajik) translation yet**: a Tajik-speaking
reviewer is welcome to add one.

## Sources

| For | Text | Where |
|---|---|---|
| VAT rates, reduced rates, zero rate, exemptions, tax point, credit, reverse charge, invoice, return, period | Tax Code of 23 December 2021, No. 1844, edition of 17 December 2025 (Law No. 2210), articles 244–279 and 397 | andoz.tj (Russian text) |
| Chart of accounts | Order of the Minister of Finance of 27 May 2011, No. 41, appendix 1 | base.spinform.ru (copy of the text) |
| Accounting law | Law of 25 March 2011, No. 702 | andoz.tj |
| Statements | IFRS Accounting Standards | ifrs.org |
| Filing | Tax Committee under the Government | andoz.tj |

## What the pack says

- **Standard rate** (article 264(1)(1) with article 397(4)): 14 % from
  1 January 2024 to 31 December 2026, 13 % from 1 January 2027. Both are coded
  and dated: `TJ-S-14` / `TJ-P-14` end on 2026-12-31, `TJ-S-13` / `TJ-P-13` start on
  2027-01-01. The 15 % that some summaries still quote is the Code's own text
  before the transitional rule of article 397(4), not a rate in force.
- **Reduced rates** (article 264(1)(2)): 7 % for construction works, hotel
  services and catering (`TJ-S-7`); 5 % for domestic agricultural products,
  education and sanatorium medical services (`TJ-S-5`), without the right to credit.
- **Zero rate** (articles 264(2), 254): export of goods (`TJ-S-ZERO-EXPORT`), except the
  list of article 254(1) (precious metals, primary aluminium, ores, cotton…), which
  is exempt, not zero-rated (article 251(3)).
- **Exemptions** (article 251(2), article 252): real estate (`TJ-S-EXEMPT-REALESTATE`),
  financial services (`TJ-S-EXEMPT-FINANCIAL`) and international transport
  (`TJ-S-EXEMPT-INTL-TRANSPORT`) are coded as examples. The other items of
  article 251 are not coded; add the one a case needs, with its article.
- **Reverse charge** (article 260): services of a foreign supplier without a
  place of business in Tajikistan. The tax agent withholds the VAT and pays it
  with its return **without the right to credit** (article 260(4)): `TJ-P-14-NR`
  posts it to `55310` (non-recoverable VAT) against the VAT account `22321`.
- **Return** `TJ-VAT`: monthly (article 273), due on the 15th of the following
  month (article 272(1)). The quarterly return of foreign suppliers of remote
  services to individuals (article 273(2), due on the 20th) is not expressed.
- **Tax point** (article 256): the invoice date, and where no invoice is issued the
  delivery. Declared as `invoice_if_issued`.
- **Registration** (article 245): a person whose total income over a period of up
  to 12 consecutive months exceeds 1.0 million somoni is a VAT payer. The format
  has no field for the threshold; it is written here and in nothing else.

## What the pack does not do — read before relying on it

1. **The boxes are not the lines of the official form.** The form of the VAT
   return and its instruction are approved by the finance authority (article
   272(4)) and could not be read from an open source. The boxes are named after
   the articles of the Code and compute what articles 264–266 compute. Carrying
   them to the form's lines is for the accountant.
2. **The chart is transcribed only to account 33300.** The text of the order
   (appendix 1) was readable for sections 1–3 (assets, liabilities, equity) as far
   as `33300` and then stops behind a paywall: `33400` (minority interest) and
   sections IV–VI (operating income, operating expenses, non-operating income
   and expenses) were **not** read. The accounts of those sections in this pack —
   `44xxx` income, `55xxx` expenses, `66xxx` non-operating — follow the
   doubled-digit pattern of sections 1–3 (`10`/`11`, `22`, `33`), which is a guess,
   not the order's numbering. The pack's own accounts, all flagged in
   `charts[0].legal_reference`, are those, plus `10541`, `10542` (separate posting
   and settlement accounts for VAT recoverable), `22321`, `22322` (collected and
   settlement VAT, which `tests/filing_golden.test.ts` requires to differ) and
   `22590` (suspense). A Tajik accountant should replace them by the order's own
   codes for sections IV–VI.
3. **Statements are assembled, not an official form.** The balance sheet and the
   income statement are built from the sections of the chart and IAS 1. The approved
   forms and the small-business rules were not read.
4. **Reduced-rate payers.** Article 266 allows the credit "when the standard rate
   is used"; a payer on 7 % or 5 % does not credit input VAT, and `PAYABLE` adds the
   tax of those boxes to the standard tax before the credit. A mixed payer's
   allocation (article 266(5)) is not modelled. Input VAT of such a payer should be
   posted to an expense with no tax code.
5. **Advances and regular services** (article 256(3)–(6)) make the tax point the
   advance or the invoice of the month; the core's tax point cannot express an
   advance as a third trigger. Imports (customs VAT), excise tax, tax on turnover
   and the special regimes (patent, single tax) are not modelled.
6. **Electronic invoices.** Article 269(3) and (5) make the VAT invoice an
   electronic document issued online and kept in the tax authorities' database.
   That is a state system, not an EN 16931 exchange: `einvoicing.profile` is empty
   and the date the obligation began was not read.
7. **No bank statement format** is declared.
8. **Dates of the reduced rates.** `TJ-S-7` and `TJ-S-5` start on 2025-02-11, the
   date of the law (No. 2143) in whose wording the text was read; the day the rates
   began in the Code before it was not established.

## To be read by a Tajik accountant

Everything in 1–5 above, the exemption list, the reverse-charge handling and the
account groupings of sections IV–VI.
