# Turkmenistan

Everything Ekwo carries for Turkmenistan is data: a chart of accounts for
commercial organisations, the value added tax at 15 % and 0 % with three
exemptions coded, a monthly VAT return, and a balance sheet and an income
statement. The format is in [`docs/packs.md`](../../docs/packs.md); this file says
where each line comes from and what the pack does not do, so that a Turkmen
accountant can argue with one sentence rather than with the whole.

**Status: `community`.** No bookkeeper or auditor has read this pack. The figures
are recomputed from a year of books by `tests/golden.test.ts`, which proves the
pack agrees with itself and not that it is right in law.

**Language.** The pack is written in Russian (`defaults.language: "ru"`): the Tax
Code was read in Russian on the website of the Mejlis, and the national standard
only in an unofficial Russian translation. Turkmen, the state language, is not
carried yet: names of accounts, taxes, boxes and statement lines are in Russian,
with English in `i18n/en.json`. A Turkmen reader is needed for `i18n/tk.json`.
The `legal_reference` fields cite articles by number.

## Sources

| For | Text | Where |
|---|---|---|
| VAT: payers, rate, zero rate, exemptions, invoices, input tax, return and payment | Tax Code of Turkmenistan (new edition), articles 95–113; article 30 (the tax return) | mejlis.gov.tm |
| Statements | National Financial Reporting Standard for small and medium-sized entities, Minister of Finance order No. 57-Ö of 1 April 2013 as amended by order No. 117-Ö of 16 September 2015 (unofficial translation) | fineconomic.gov.tm |
| Statements | IFRS for SMEs | ifrs.org |
| Filing | State tax service of the Ministry of Finance and Economy, electronic tax | tax.gov.tm |

## What the pack says

- **VAT 15 %** (article 103), code `TM-S-15` for sales, `TM-P-15` for purchases.
- **VAT 0 %** (article 105): export of goods other than natural gas, oil and their
  products, declared to customs (`TM-S-ZERO-EXPORT`), and international passenger
  and cargo transport (`TM-S-ZERO-TRANSPORT`). The other items of article 105 —
  handling and transit of exported goods, refuelling of foreign ships and aircraft,
  duty-free shops, diplomatic missions, own-grown agricultural products,
  hydrocarbon contractors — are not coded.
- **Exempt operations** (article 106, part 1): medicines and medical products
  (`TM-S-EXEMPT-MEDICINES`), education services (`TM-S-EXEMPT-EDUCATION`) and
  insurance and reinsurance (`TM-S-EXEMPT-INSURANCE`) are coded as examples; the
  rest of the list (food products, public catering, carpets, passenger transport
  and so on) is not. Add the one a case needs, with its article. The invoice then
  reads « Без налога на добавленную стоимость » (article 107, part 5).
- **Return** `TM-VAT`: monthly for legal entities (article 104, part 1), filed by
  the 20th of the following month (article 111, part 1); payment by the 25th
  (part 3). The Ministry may set other dates for certain categories, up to thirty
  days later (part 6); the pack carries the general dates.
- **Tax agent for a foreign supplier** (article 108, part 2): a resident company
  that pays a foreign person not registered in Turkmenistan calculates and withholds
  the VAT. Code `TM-P-15-NR`.

## What the pack does not do — read before relying on it

1. **Who is a VAT payer.** Article 95 part 2 says that legal entities of **private
   ownership** and individual entrepreneurs under the simplified regime are not VAT
   payers; the Central Bank and hydrocarbon contractors (for oil operations) are
   not either. The pack describes no registration rule: a company outside the
   payers should not use the VAT codes. Whether the text applies as written to a
   given company, and how the regime is applied in practice, is for the accountant.
2. **The boxes are not the lines of the official form.** The return form is
   approved by the Ministry of Finance and Economy (article 30, part 1) and could
   not be read from an open source. The boxes are named after the articles
   (`TAXABLE`, `ZERO`, `EXEMPT`, `TURNOVER`, `INPUT`, `CREDIT`, `PAYABLE`,
   `EXCESS`). Carrying them to the form is for the accountant.
3. **The chart is the pack's own grouping.** The standard chart of accounts of
   Turkmenistan, and the order that approves it, could not be read. The classes
   (1 current assets, 2 non-current assets, 3 current liabilities, 4 non-current
   liabilities, 5 equity, 6 income, 7–9 expenses) and every code are this pack's,
   built on the list of items that paragraph 58 of the national standard asks to
   present; the VAT accounts `1541`, `1542`, `1543`, `3431`, `3432`, `3433`
   (separate posting and settlement accounts, which the filing tests require),
   `3699`, `6290`, `7610`, `7690` and `9610` are the pack's. A Turkmen accountant
   must check the chart against the official one before a company keeps its books
   on it.
4. **Statements are assembled, not an official form.** The balance sheet and the
   income statement are built from the chart's classes and the items the standard
   lists (paragraphs 58 and 64 onward). The official forms were not read.
5. **Input tax is deducted on payment, the pack deducts on the invoice.** Article
   110, part 1 counts as creditable the tax *paid* to suppliers in the period, on
   the invoice and the proof of payment (part 2); fixed assets above 10 000 manat
   are credited over two years (part 3). `TM-P-15` posts the input tax when the
   purchase is booked and the box `INPUT` follows the booking date. A company that
   has not paid a supplier at the month end must correct the box by hand.
6. **Time of supply.** Article 109 places the operation in the period of shipment
   or completion; long-term contracts (over three months) are recognised by
   volume performed each period, and own consumption and shortages have their own
   rules. The format carries `delivery_date` only.
7. **The tax invoice.** Article 107, part 4 requires a tax invoice (*налоговая
   счёт-фактура*) in the form set by the Ministry, within five days of shipment.
   The form and its numbering are not in the pack; the document number is an
   example. No exchange with the administration is modelled, so `einvoicing` is
   empty. Declarations may be sent as an electronic document by agreement with the
   tax office (article 30, part 2); the electronic channel is the State Tax
   Service's personal account (`tax.gov.tm`), not modelled.
8. **Non-resident reporting.** The payer who pays non-residents also files a
   monthly report of those payments by the 20th (article 111, part 2). The form is
   the Ministry's and the report is not produced. `TM-P-15-NR` posts the withheld
   tax to `3433`, with the credit waiting on `1543`; the entry to `1541` after
   payment is manual.
9. **Fixed state prices**, **import VAT** (article 96) and **the calculated rate
   for prices that include VAT** (article 103, part 2: 15/115) are not modelled.
10. **Corporate income tax, personal income tax and social contributions** are not
    modelled; `3410`, `3420` and `3530` are placeholder accounts.
11. **No bank statement format** is declared. **Turkmen** is not carried (see
    above).
12. **The Tax Code is read as published on the Mejlis site**, whose edition lists
    amendments up to the laws of 30 November 2024 and 30 September 2025. The text
    of the 2025 amendment to article 105 is cited on that page without its
    publication reference; a later change is possible.

## To be read by a Turkmen accountant

Everything in 1–8 above, the account groupings, the exemptions coded, and the
Russian and Turkmen wording.

## The golden year

`golden/scenario.json` is a company with five monthly returns, checked by hand at
15 %: January taxable sales 50 000 (tax 7 500), an export of 20 000, purchases
30 000 (tax 4 500), so 3 000 payable; February sales 30 000 less a return of 7 500,
so 22 500 (tax 3 375), education fees 3 000 exempt, input tax 1 500, so 1 875
payable; March only a purchase of 40 000 (tax 6 000), so 6 000 refundable; April
taxable 20 000 (tax 3 000), international transport 15 000 at zero, input tax
1 200, so 1 800 payable; May medicines 12 000, exempt. Amounts are fictitious, in
manat (TMT, two decimals); the contacts are named as plainly fictitious.
