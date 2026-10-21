# Lao PDR

Everything Ekwo carries for the Lao People's Democratic Republic is data: a chart of
accounts for commercial enterprises, the value added tax at 10 % and 0 % with four
exemptions coded, a monthly VAT return, and a balance sheet and an income statement.
The format is in [`docs/packs.md`](../../docs/packs.md); this file says where each line
comes from and what the pack does not do, so that a Lao accountant can argue with one
sentence rather than with the whole.

**Status: `community`.** No bookkeeper or auditor has read this pack. The figures are
recomputed from a year of books by `tests/golden.test.ts`, which proves the pack agrees
with itself and not that it is right in law.

**Sources are thin, and this pack says so.** The Law on Value Added Tax No. 48/NA of
2018 is published in Lao only; it was not read in Lao. The rate, the exemptions, the
return date and the input-tax rules are taken from law-firm and tax-summary readings of
it, which cite its articles (DFDL, Tilleke & Gibbins, PwC), and from the summary page of
the Lao Trade Portal. Every `legal_reference` says "as summarised by" where that is the
case. A Lao reader with the Lao text must confirm each article number.

**Language.** The pack is written in English (`defaults.language: "en"`), the language
of the sources read. Lao, the official language, is not carried yet: a Lao reader is
needed for `i18n/lo.json`.

## Sources

| For | Text | Where |
|---|---|---|
| VAT: rate, exports, exemptions, return, input tax, refund | Law on Value Added Tax (Amended) No. 48/NA, 20 June 2018, as summarised | laotradeportal.gov.la, dfdl.com |
| VAT rate back to 10 % | Ordinance of the President No. 003/PDT, 19 March 2024, as reported | tilleke.com |
| VAT: exports, exemptions, three-month rule, services from abroad | Worldwide Tax Summaries, Lao PDR | taxsummaries.pwc.com |
| Statements | IFRS for SMEs, on which the Lao financial reporting standards for non-public interest entities rest | ifrs.org |
| Administration | Ministry of Finance (Tax Department, Accounting Department) | mof.gov.la |

## What the pack says

- **VAT 10 %** (article 17), `LA-S-10` for sales, `LA-P-10` for purchases. The rate was
  7 % from January 2022 and restored to 10 % by the Ordinance of 19 March 2024; the pack
  carries 10 % from that date.
- **VAT 0 %**: export of goods (`LA-S-ZERO-EXPORT`). Exports of natural resources that
  are not finished goods stay at 10 % (PwC) and are not coded apart.
- **Exempt operations** (article 12): unprocessed agricultural products, seeds,
  fertilisers and agricultural equipment (`LA-S-EXEMPT-AGRI`); education
  (`LA-S-EXEMPT-EDUCATION`); medical goods and services and health insurance
  (`LA-S-EXEMPT-HEALTH`); interest and financial transactions of commercial banks
  (`LA-S-EXEMPT-BANKING`). The rest of the list (international transport, goods for
  embassies, and others) is not coded. Add the one a case needs, with its article.
- **Return** `LA-VAT`: monthly, due the 15th of the following month (article 30(1),
  as summarised by DFDL).
- **Services from abroad** (`LA-P-10-NR`): the payer withholds 10 % on fees paid to an
  overseas provider (PwC).
- **Input tax** (`LA-P-10`): creditable on a proper invoice if claimed within three
  months (articles 22 to 24).

## What the pack does not do — read before relying on it

1. **The return date is not confirmed.** DFDL reads article 30 as the 15th of the
   following month. PwC records that the monthly excise return moved from the 15th to
   the 20th; whether VAT moved with it was not found. Check the Tax Department's
   current notice.
2. **The registration threshold** is not carried. PwC says enterprises with a tax
   identification number are registered automatically, except micro enterprises; the
   threshold for the latter was not found. A company outside the VAT system should not
   use the VAT codes.
3. **The boxes are not the lines of the official form.** The form and the electronic
   channel could not be read. Boxes are named after the operations (`TAXABLE`, `ZERO`,
   `EXEMPT`, `TURNOVER`, `INPUT`, `CREDIT`, `PAYABLE`, `EXCESS`).
4. **The chart is the pack's own grouping.** The Ministry of Finance's enterprise plan
   (the 1992 Lao general accounting plan) and the decision that now approves it could
   not be read. Classes and codes follow the items of an IFRS for SMEs balance sheet and
   income statement; the VAT accounts `1541`, `1542`, `1543`, `3431`, `3432`, `3433`
   (separate posting and settlement accounts, which the filing tests require) are the
   pack's. An accountant must check it against the official plan.
5. **Statements are assembled, not an official form.** The official Lao forms were not
   read.
6. **Time of supply.** The Lao text was not read; delivery date is an assumption.
7. **Input tax deducted on the invoice**, and not checked against the "proper invoice"
   and three-month conditions; non-deductible items of article 24 (personal computers,
   telephones, personal expenses) are not blocked by the pack.
8. **Refunds** (article 28): not modelled; DFDL notes the process is unclear in practice.
9. **Invoices.** The regulation on the VAT invoice was not read; the numbering is an
   example. No electronic exchange with the administration is modelled, so `einvoicing`
   is empty.
10. **Import VAT** (paid at importation, article 30(2)), **excise tax**, **profit tax**,
    **income tax** and **social security** are not modelled; `3410`, `3420` and `3440` are
    placeholder accounts.
11. **No bank statement format** is declared. **Lao** is not carried (see above).
12. **The Tax Department's own site** could not be reached from the machine that wrote
    this pack, so the portal source is the Ministry of Finance.

## To be read by a Lao accountant

Everything in 1–9 above, the account groupings, the exemptions coded, and the Lao
wording.

## The golden year

`golden/scenario.json` is a company with five monthly returns, checked by hand at 10 %:
January taxable sales 50 000 000 (tax 5 000 000), an export of 20 000 000, purchases
30 000 000 (tax 3 000 000), so 2 000 000 payable; February sales 30 000 000 less a return
of 7 500 000, so 22 500 000 (tax 2 250 000), tuition 3 000 000 exempt, input tax
1 000 000, so 1 250 000 payable; March only a purchase of 40 000 000 (tax 4 000 000), so
4 000 000 refundable; April taxable 20 000 000 (tax 2 000 000), an export of 15 000 000,
input tax 800 000, so 1 200 000 payable; May seeds 12 000 000, exempt. Amounts are
fictitious, in kip (LAK, no decimals); the contacts are named as plainly fictitious.
