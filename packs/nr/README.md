# Nauru

Everything Nauru adds to Ekwo, as data: a chart of accounts, the journals, the
two "not subject" tax codes that carry every sale and purchase a Nauruan
business books, and the statement of financial position and statement of
profit or loss on the lines of IAS 1. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Nauruan accountant can
disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who practises in Nauru has reviewed it. The
figures are replayed against a year of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

**Nauru has no general consumption tax in force that this research found.**
So the pack has no `tax_report.json`, no tax-clearing account and no
`tax_payable` / `tax_receivable` role, and `golden/vat_return.json` has empty
`boxes`. This is a current state, not a permanent one.

## Sources

| What | Text | Where |
|---|---|---|
| The taxes the Nauru Revenue Office administers; the rates of the business taxes and of the telecommunications tax | NRO, *Legislation administered by the NRO* | `naurufinance.info/nro-administered-legislation/` |
| Tax year 1 July to 30 June; quarterly instalments; annual business profits tax return within three months of the year; monthly withholding return within 15 days | NRO, *Key dates* | `naurufinance.info/nro-key-dates/` |
| Services tax applies to non-resident independent service providers, withheld by the payer at 20 % | NRO, *Employment and Services Tax Q & A Guide 2022-2023* | `naurufinance.info/wp-content/uploads/2023/08/QA-Employment-and-Services-Tax-2022-23.pdf` |
| Where returns are filed (FMIS portal, forms, contacts) | NRO | `naurufinance.info/nauru-revenue-office/` |

All four are the Revenue Office's own pages and guide, i.e. official guidance,
not the statutes. **The statutes themselves were not read**: the official
legislation database (`ronlaw.gov.nr`) could not be searched and the
consolidated Acts published by the Revenue Office could not be extracted. Every
rate above is therefore the Revenue Office's summary of the Act, and the
current regulation schedules (the Business Tax Act schedule was amended again
by a regulation gazetted on 28 June 2024) were not read.

## Why no code for the Employment and Services Tax

The "services" part of the Employment and Services Tax Act 2014 was checked
because a services tax could have been a sales tax. According to the Revenue
Office's guide it is not: the payer withholds it from the fee at the time it
pays, on **non-resident** independent service providers (20 %, with an annual
tax-free threshold of 20,000 dollars for those contracted directly to the
Government), and pays it over by the 15th of the following month. It is an
income tax collected at the source of payment, not a tax a supplier adds to
its customer's invoice and recovers on the other side. It is outside the pack,
like the other taxes below.

## Taxes left out of the pack

- Business profits tax, small business tax (2.5 % of gross revenue of a
  non-resident individual up to 250,000 dollars) and non-resident tax (20 %
  on interest, royalties and insurance premiums) — Business Tax Act 2016.
- Employment and services tax — Employment and Services Tax Act 2014.
- Telecommunications service tax, 10 % of the gross sales of telecommunication
  services by a service provider — Telecommunications Service Tax Act 2009. It
  is confined to one sector; the core has no way to model a turnover tax with
  a return for one sector only, and it is not in the pack.
- Customs duty: it exists, but this research found no sourced tariff.
- Gaming licences (Gaming Act 2011), social contributions and any tax of the
  OECD global minimum tax kind: not researched.

The chart carries accounts to hold them (business profits tax provision and
instalments, tax withheld and payable, other government charges payable) and
no tax code.

## The chart, the statements and the year

Nauru prescribes no chart of accounts that this research found: the chart is
written, not transcribed (107 accounts, four digits). The statements follow
IAS 1; which accounting framework a Nauruan company must apply is **not
established** here. `defaults.fiscal_year_default` is `july` because the
Revenue Office's tax year runs from 1 July to 30 June; the financial year a
company's constitution or the Corporations Act sets was not verified (the
Corporations Act on the legislation database is the 1972 Act; whether a 2021
Act exists could not be confirmed).

## Language and currency

The currency is the Australian dollar, Nauru's legal tender. English is the
language of the laws and of the pack. Nauruan (Dorerin Naoero) is not
supplied: an imprecise translation of accounting terms is worse than an honest
gap, so `languages` is empty.

## What this pack does not say yet

- Nothing on record-keeping duties and retention periods.
- Nothing on the Corporations Act's accounts and annual-return rules.
- Nothing on e-invoicing: none found, no Peppol authority.
- No customs tariff; no payment-term or late-interest rule.

## What a local accountant should read first

1. That Nauru has no general consumption tax (Revenue Office list of Acts).
2. The current Schedule 1 of the Business Tax Act (rates by turnover band) and
   the Employment and Services Tax schedules.
3. The accounting framework and financial year a company must use.
