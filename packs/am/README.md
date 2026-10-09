# Հայաստան (Armenia)

Community pack, not reviewed by an Armenian accountant. Chart of accounts in
Armenian (copied from the Armenian text of Order No. 353-N), with an English
working translation in `i18n/en.json`. VAT at 20 %, a zero rate, exemptions, and
the monthly *unified VAT and excise tax calculation* of the State Revenue
Committee, with the boxes of lines 7, 8.1, 12, 13, 16, 17, 18, 19.1, 21 and 23.

Armenia is not in the European Union; it is a member of the Eurasian Economic
Union (EAEU). No EU VAT category, VATEX code or intra-community treatment
applies, and none is used.

## Sources

Every rate, box and deadline cites an official text in `certification.sources`:

- Tax Code of the Republic of Armenia, Law HO-165-N of 4 October 2016
  (consolidated Armenian text, `arlis.am/hy/acts/199704`; an English translation
  is `arlis.am/en/acts/205620`): articles 56, 60, 63-65, 67-72, 75 and 254-258.
- Order No. 298-N of 30 December 2016 of the Chairman of the State Revenue
  Committee: the form of the unified VAT and excise tax calculation and its
  filling instructions (the text read is the incorporated version in force from
  1 April 2023).
- Order No. 353-N of 17 April 2012 of the Minister of Finance: the chart of
  accounts and its application instruction.
- Order No. 1016-N of 21 November 2012: the chart for small and medium
  organisations (not carried here, see below).
- Law on Accounting of 4 December 2019.
- The File Online portal (`file-online.taxservice.am`) and `src.am`.

## Chart of accounts, and why these accounts

The chart is the national one: Order No. 353-N, which replaced the 2000 chart
(Order No. 319). 182 accounts of its classes 1 to 7 and three off-balance
accounts of class 9, at the second order (three digits) and the third order
(four digits). Class 8 (management accounting) is left to the company. The
chart is *exemplary and not mandatory* (section I of its instruction), and a
company may add accounts with free codes — which is what this pack does for the
five accounts below, because the official chart has no account for them:

| Code | Account | Why |
|---|---|---|
| 2261 | Input VAT on acquisitions in Armenia | posting account under 226 |
| 2262 | Input VAT on imports | posting account under 226 |
| 52431 | Output VAT on supplies | posting account under 5243 |
| 5319 | Suspense account | the chart has none |
| 7291 | Rounding differences | the chart has none |

The accounts the declaration is settled on are the official 2253 (VAT receivable,
`tax_receivable`) and 5243 (VAT payable, `tax_payable`), both `reconcilable`;
the postings land on the child accounts above, so the settlement account is
never a posting account. Only the customers (221), the suppliers (521) and the
two VAT settlement accounts are `reconcilable`; the bank (2521) and the cash
(2511) are not.

The small and medium organisations chart (Order No. 1016-N) keeps the structure
of Order No. 353-N with fewer accounts. It is not carried as a second chart
because its text was not transcribed; a company on it can use the accounts of
this chart that exist in both.

Year-end closing uses `result_accounts`: 331 (profit or loss) is the closing
account of the official chart, 343 (net profit or loss of the year) takes the
result and 342 holds the retained earnings.

## Taxes

| Code | Rate | Source | Box |
|---|---|---|---|
| `AM-S-20` | 20 % | Tax Code art. 63(1) | 7 (adjusting invoice: 8.1) |
| `AM-S-0-EXPORT` | 0 % | art. 65(2) points 1-2 | 12 |
| `AM-S-0-SERVICES` | 0 % | art. 65(2) points 4 and 11 | 12 |
| `AM-S-EXEMPT` | exempt | art. 64(2) | 13 |
| `AM-P-20` | 20 % | art. 71(1) point 1 | 18 (adjusting: 19.1) |
| `AM-P-IMPORT` | 20 % | art. 71(1) points 2-3 | 17 |

The exempt tax stands for the whole list of article 64(2); it is not a list of
fifty taxes. A company with an unusual exempt activity should check the point it
relies on.

**The 115 million AMD threshold is not a tax.** A VAT payer is an organisation
or individual entrepreneur whose sales turnover exceeded AMD 115 million in the
previous year, or who registers (article 59). The *turnover tax*
(articles 254-258) is a special regime for resident commercial entities under
the same AMD 115 million: a turnover taxpayer is not a VAT payer, and the Ekwo
core has no regime that replaces VAT with a tax on turnover. The pack therefore
covers the VAT payer; a company on turnover tax installs it and posts no VAT
(no `AM-*` tax on its documents).

## The declaration

`tax_report.json` carries section 1 (VAT) of the *unified calculation*. Section 2
(excise) is not carried. The reporting period is the calendar month (article 69;
a quarterly period applies only to a non-resident without a permanent
establishment) and the filing is due **on or before the 20th of the month
following** (article 75(1)). Amounts are filled in whole drams (instruction
point 4), so the rounding unit is 1.

| Box | Meaning |
|---|---|
| 7A / 7B | base / VAT of transactions at 20 % |
| 81A / 81B | adjusting tax invoices issued, reduction (line 8.1) |
| 12A | base of zero-rate transactions |
| 13A | base of exempt transactions |
| 16A / 16B | total VAT credit (the output side) |
| 17A / 17B | value / VAT of goods imported |
| 18A / 18B | value / VAT of goods and services acquired in Armenia |
| 191A / 191B | adjusting invoices received, reduction (line 19.1) |
| 21A | total VAT debit (the input side) = 17B + 18B − 19.1B |
| 23A / 23B | VAT payable to / refundable from the State budget |

A box id is the form's line number with the box letter appended (`7B` is line 7,
box B; `81A` is line 8, sub-line 1, box A). Lines 8.2, 9 (the 16.67 % calculated
rate, which applies where the taxpayer failed to charge VAT, article 63(2)), 10,
11, 14, 15, 20 and 22 are not carried: they are corrections and cases the core
cannot post.

## Electronic invoicing

Settlement documents are issued in electronic form (article 56(3)), and tax
invoices are issued and confirmed by electronic signature in the State Revenue
Committee's electronic settlement documents system (articles 66-68), reached
through File Online. A tax invoice is not issued for exempt or zero-rate
transactions (article 67(1) points 2-3): a *tax bill* is. The system is a State
clearance system and not an EN 16931 exchange, so `profile`, `party_scheme` and
`vat_scheme` are empty — and `einvoicing.obligation` is **left out** on
purpose: the manifest accepts `obligation: mandatory` only with a
`mandatory_from`, and a `mandatory_from` only with a profile that says what
becomes obligatory. Online cash registers (e-HDM) are outside the core.

Recent changes, read from the amendment history of the Tax Code and from
secondary sources, to be confirmed by a local accountant:

- Law HO-234-N of 6 May 2026 (listed in the amendment history of the Tax Code):
  the rate used to convert a foreign-currency invoice is the Central Bank rate of
  the **previous working day** from 1 July 2026. The consolidated text retrieved
  still shows the 16:00 same-day wording of article 16(2). The core takes the
  rate from the document, so the pack does not carry it.
- Law HO-309-N of 3 July 2026: the settlement document is issued before the goods
  are supplied and at the completion of work or services from 1 September 2026;
  the extension of electronic cash registers applies mostly from 1 January 2027.
- A special regime for gold (Law HO-200-N of 26 June 2023 amended article 88 of
  the Code): not read in detail, and nothing in this pack models it.

## What the core does not do

- The State clearance system (issue, electronic signature and confirmation of tax
  invoices) and the e-HDM registers.
- An e-invoicing obligation without a profile, as above.
- Non-deductible input VAT on purchases used for exempt transactions
  (article 72(1) point 2): the core has no partial-deduction mechanism, so the
  accountant posts those purchases without input VAT by hand.
- VAT on services bought from a non-resident without an establishment, borne by
  the Armenian recipient who issues the tax invoice on the supplier's behalf
  (articles 56(7) and 70(2)-(3); lines 10 and 11 of the form). No reverse-charge
  tax is declared.
- The 16.67 % calculated rate (line 9) and the adjustment lines 8.2, 15, 20, 22.
- The turnover tax regime (articles 254-258) and excise (section 2 of the form).
- Conversion of foreign-currency invoices at the previous working day's rate.
- Statutory financial statements: `statements.json` carries a balance sheet and an
  income statement as *summary layouts* that group the classes of the chart
  (IFRS presentation, Law on Accounting); they are not forms approved for filing.

## To be reviewed by a local accountant

The Armenian wording written by the contributor (the names of the five added
accounts, of the taxes, boxes and statement lines, and the legal references);
the exempt list of article 64(2); the tax point (`invoice_if_issued` approximates
article 56(4), which ties the document to the supply and to completion of work);
the version of the return form in force today (the text read is the 2023
incorporation); the status of HO-234-N and HO-309-N; the payment deadline of the
VAT (the filing deadline is verified, a payment on the same day is reported by
secondary sources only).

## Checking the pack

    node packages/cli/dist/bin.js pack build am
    node packages/cli/dist/bin.js pack check --all
