# Mongolia

Everything Ekwo carries for Mongolia is data: a chart of accounts for business
entities, the value added tax at 10 % and 0 % with two exemptions coded, a
monthly VAT return, and a balance sheet and an income statement. The format is
in [`docs/packs.md`](../../docs/packs.md); this file says where each line comes
from and what the pack does not do, so that a Mongolian accountant can argue
with one sentence rather than with the whole.

**Status: `community`.** No bookkeeper or auditor has read this pack. The figures
are recomputed from a year of books by `tests/golden.test.ts`, which proves the
pack agrees with itself and not that it is right in law.

**Language.** The pack is written in Mongolian (`defaults.language: "mn"`); the
names of accounts, taxes, boxes and statement lines are Mongolian, and the
`legal_reference` fields cite the articles of the law by number. The Mongolian
wording is a working translation by the pack's contributor and wants a native
reader. `i18n/en.json` carries English names. The VAT law was read in the
unofficial English translation published on legalinfo.mn; the Mongolian text
governs.

## Sources

| For | Text | Where |
|---|---|---|
| VAT rates, zero rate, exemptions, input tax, return, receipts | Law on Value Added Tax, 9 July 2015 (revised edition), articles 7, 11–17 | legalinfo.mn (unofficial English translation) |
| Books and statements | Law on Accounting, 2015 | legalinfo.mn |
| Forms and instructions for business entities | Minister of Finance order No. 347 of 5 December 2017 | legalinfo.mn |
| Statements | IFRS Accounting Standards | ifrs.org |
| Filing | Mongolian Tax Authority | mta.gov.mn |

## What the pack says

- **VAT 10 %** (article 11.1), code `MN-S-10` for sales, `MN-P-10` for purchases.
- **VAT 0 %** (article 12.1): export of goods declared to customs (12.1.1,
  `MN-S-ZERO-EXPORT`) and international passenger and cargo transport (12.1.2,
  `MN-S-ZERO-TRANSPORT`). The other items of article 12.1 are not coded.
- **Exempt supplies** (article 13): sale of residential premises (13.1.7,
  `MN-S-EXEMPT-RESIDENTIAL`) and banking services (13.5.2, `MN-S-EXEMPT-BANKING`)
  are coded as examples; the rest of the list is not. Add the one a case needs,
  with its article.
- **Return** `MN-VAT`: monthly, filed and paid by the 10th of the following month
  (article 16.1).
- **Input tax** (article 14): deductible when shown on the invoice (14.5); the
  exclusions of 14.6 (passenger cars, personal use, exempt activities) and the
  apportionment of 14.9 are for the accountant.
- **Registration**: mandatory at annual sales of 50 million tugrik (articles 4.1.8
  and 5.2). The pack describes no threshold rule; a company below it is not a
  VAT payer and should not use the VAT codes.

## What the pack does not do — read before relying on it

1. **The boxes are not the lines of the official form.** The approved VAT return
   and its line numbers could not be read from an open source. The boxes are named
   after the articles (`TAXABLE`, `ZERO`, `EXEMPT`, `TURNOVER`, `INPUT`, `CREDIT`,
   `PAYABLE`, `EXCESS`). Carrying them to the form is for the accountant.
2. **The chart is the pack's own grouping.** The annex of the Minister of Finance
   order that lists the accounts for business entities could not be read in a
   machine-readable text. The classes (1 current assets, 2 non-current assets, 3
   current liabilities, 4 non-current liabilities, 5 equity, 6 income, 7–9
   expenses) and every code are this pack's, not transcribed from the annex; the
   accounts `1541`, `1542`, `1543`, `3431`, `3432`, `3433` (separate posting and
   settlement accounts for VAT, which the filing tests require), `3699`, `6290`,
   `7610`, `7690` and `9610` were added by the pack. A Mongolian accountant must
   check the chart against the order before a company keeps its books on it.
3. **Statements are assembled, not an official form.** The balance sheet and the
   income statement are built from the chart's classes and IAS 1. The forms
   approved by the Ministry of Finance, and the IFRS-for-SMEs presentation that
   smaller entities follow, were not read.
4. **A change of the VAT law is announced for 1 January 2027.** A consultancy's
   2026 tax update reports amendments to the VAT law that would extend the filing
   and payment deadlines by about ten days, and a draft revision of the law was
   consulted in 2025. The final texts were not found on legalinfo.mn when the pack
   was written; the pack carries the 10th (article 16.1 of the 2015 law) until a
   reader confirms the new date.
5. **Receipts and invoices (ebarimt).** Article 17 has each VAT payer issue a receipt
   for every sale and send the data to the state's integrated system within three
   days, and VAT invoices between payers within a week. Sending to that system is a
   clearance channel the core does not have; `einvoicing.profile` is empty.
6. **Petrol and diesel** (rate set by the Government between 0 and 10 %, article
   11.3), **import VAT**, the **incentive refund** (15.2.1), **fixed-asset input tax
   spread over 5 or 10 years** (14.1.5) and **advance payments** are not modelled.
7. **Corporate income tax, personal income tax and social insurance** are not
   modelled; `3410`, `3420` and `3530` are placeholder accounts.
8. **No bank statement format** is declared.
9. **Services from a non-resident** (`MN-P-10-NR`). Articles 7.2.5 and 16.1.2 make
   such supplies taxable and have the VAT withheld and paid when there is no
   customs declaration, but the English translation does not say whether the
   non-resident or the Mongolian recipient withholds. The pack models the recipient
   accounting for the tax (posted to `3433`, credit waiting on `1543`, moved to
   `1541` by a manual entry once paid) — a reading to be confirmed against the
   Mongolian text.

## To be read by a Mongolian accountant

Everything in 1–4 and 9 above, the account groupings, the exemptions coded, and
the Mongolian wording.

## The golden year

`golden/scenario.json` is a company with five monthly returns, checked by hand at
10 %: January sales 50 000 (tax 5 000) and an export of 20 000, purchases 30 000
(tax 3 000), so 2 000 payable; February net taxable sales 22 500 after a return of
7 500 (tax 2 250), exempt 3 000, input tax 1 000, so 1 250 payable; March only a
purchase of 40 000 (tax 4 000), so 4 000 refundable; April taxable 20 000 (tax
2 000), zero-rated 15 000, input tax 800, so 1 200 payable; May exempt 12 000 only.
