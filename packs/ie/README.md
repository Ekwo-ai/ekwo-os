# Ireland

Everything Ireland adds to Ekwo, as data: a chart of accounts, the journals,
the VAT rates with their history since the Value-Added Tax Consolidation Act
2010, where each one posts, the boxes of the VAT3 return, the balance sheet and
the profit and loss account of the small companies regime of the Companies Act
2014, and the sentences the law puts on an invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that an Irish accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files an Irish return has reviewed it
against the law they apply. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

## Sources

Every rate, box, mention and statement carries its own `legal_reference`, and
beside it the key of the text that article is in. The register in `pack.json`
holds thirty-six texts, and every one of them was opened on 21 September 2026 —
the statutes on the electronic Irish Statute Book and on the Law Reform
Commission's Revised Acts (the Value-Added Tax Consolidation Act 2010 there is
"updated to 1 January 2026" and "up to date with all changes known to be in
force" as of 17 September 2026), the guidance on revenue.ie. The ones the rest
of this file leans on:

| What | Text | Where |
|---|---|---|
| The charge, the rates, the reverse charges, deduction, invoices, the tax point, the return | Value-Added Tax Consolidation Act 2010, as revised — ss. 3, 12, 16, 34, 46, 53A, 59, 60, 66, 74, 76, 77, 80, 86 and Schedules 1 to 3 | `revisedacts.lawreform.ie/eli/2010/act/31` |
| Each change of rate since 2010 | Finance (No. 2) Act 2011 s. 3; Finance Act 2012 s. 87; Financial Provisions (Covid-19) (No. 2) Act 2020 s. 12; Finance Act 2020 s. 39; Finance (Covid-19 and Miscellaneous Provisions) Act 2022 s. 7; Finance Act 2023 s. 5; Finance Act 2025 ss. 71 and 73 | `irishstatutebook.ie` |
| The particulars of an invoice | Value-Added Tax Regulations 2010 (S.I. No. 639 of 2010), reg. 20 | `irishstatutebook.ie/eli/2010/si/639` |
| Which amount goes in which box of the VAT3 | How do you complete a VAT 3 return?, Revenue | `revenue.ie` |
| The filing date and the taxable periods | When VAT becomes payable, Revenue | `revenue.ie` |
| Postponed accounting, construction, cars | Revenue's Tax and Duty Manuals on each | `revenue.ie/en/tax-professionals/tdm` |
| The form and content of the accounts | Companies Act 2014, ss. 280A, 282, 291 and Schedule 3A (inserted by the Companies (Accounting) Act 2017) | `revisedacts.lawreform.ie/eli/2014/act/38` |
| The accounting standards behind them | FRS 102 (section 1A for small entities) and FRS 105, Financial Reporting Council | `frc.org.uk` |
| Payment terms and late payment | European Communities (Late Payment in Commercial Transactions) Regulations 2012 (S.I. No. 580 of 2012) | `irishstatutebook.ie/eli/2012/si/580` |
| Electronic invoicing | European Union (Electronic Invoicing in Public Procurement) Regulations 2019; Revenue's VAT Modernisation timeline | `irishstatutebook.ie`, `revenue.ie` |

The Companies Registration Office (`cro.ie`) is not in the register: its site
answers every request that has no browser behind it with a Cloudflare
challenge, and a link nobody could open is not written as if somebody had. The
Act it applies is there instead.

## The chart of accounts

**Ireland prescribes no chart of accounts.** Companies Act 2014, s. 282 asks
for adequate accounting records and names none; s. 291(3) asks the balance
sheet and the profit and loss account of a company in the small companies
regime to follow **Schedule 3A**, or Schedule 3 if it elects to. So the
statements are transcribed and the chart is written. It follows the four-digit
convention Irish practice shares with British practice — `0` fixed assets, `1`
current assets, `2` creditors within one year, `3` longer-term creditors,
provisions and capital, `4` income, `5` cost of sales, `6` distribution, `7`
administration, `8` finance and tax — and each block reaches one item of
Schedule 3A Format 1. 209 accounts, every one of them postable.

Schedule 3A is not the British Schedule 1, although both come from Directive
2013/34/EU, and the differences are in the statements rather than in a
footnote:

- **Called-up share capital not paid is a debtor** (item B.II.5), not item A
  at the head of the balance sheet.
- **Prepayments and accrued income are debtors** (B.II.6 and B.II.7), and
  **accruals and deferred income are creditors** (C.10 and C.11 within a year,
  F.10 and F.11 after). There is no item D or J to compute around, so net
  current assets are current assets less creditors within one year and
  nothing else.
- **The result of the year is a line of its own** (H.VI), beside the profit or
  loss brought forward (H.V). That is why the manifest declares the
  `result_accounts` closing style: the close carries the result onto account
  3450, and allocating it is a later entry. Note (8) of the format allows the
  two lines to be combined; the pack keeps them apart.
- **Eleven creditor items on each side of the year**, from debenture loans to
  deferred income, and three items of provisions, where the British small
  format has four creditor items and a single line of provisions.

The VAT accounts are five: `1140` input tax, `2200` output tax, `2205` the
output tax of an invoice on the moneys received basis until it is paid, and
the two control accounts a filed return is cleared into — `2210` VAT payable
to the Collector-General (`tax_payable`) and `1150` VAT repayable
(`tax_receivable`), both reconcilable so that the payment and the refund are
matched against them.

## The taxes

Thirty-nine codes. A code is a rate at a date, so the history is a list of
codes with `valid_to`, never an edit:

| Rate | Codes | Valid |
|---|---|---|
| Standard 21 % | `IE-S-21-2010`, `IE-P-21-2010` | 1 November 2010 (commencement of the Act, s. 125) to 31 December 2011 |
| Standard 23 % | `IE-S-23-2012`, `IE-P-23-2012` | 1 January 2012 (Finance Act 2012 s. 87) to 31 August 2020 |
| Standard 21 %, temporary | `IE-S-21-2020`, `IE-P-21-2020` | 1 September 2020 to 28 February 2021 (s. 46(1A)) |
| Standard 23 % | `IE-S-23`, `IE-P-23` and the codes built on it | since 1 March 2021 |
| Reduced 13.5 % | `IE-S-135`, `IE-P-135` | since 1 November 2010 |
| Second reduced 9 % | `IE-S-09`, `IE-P-09` | since 1 July 2011 (Finance (No. 2) Act 2011 s. 3) |
| 9 %, hospitality and tourism | `IE-S-09-HOSP-2020` | 1 November 2020 to 31 August 2023 (s. 46(1)(cb), Finance Acts 2020 and 2023) |
| 9 %, gas and electricity | `IE-S-09-ENERGY` | 1 May 2022 to 31 December 2030 (s. 46(1)(caa)) |
| 9 %, food, catering and hairdressing | `IE-S-09-FOOD` | since 1 July 2026 (Finance Act 2025 s. 71) |
| Livestock 4.8 % | `IE-S-048`, `IE-P-048` | since 1 November 2010 |
| Flat-rate addition 4.5 % | `IE-P-FRA-45` | since 1 January 2026 (Finance Act 2025 s. 73) |

The three 9 % reliefs are codes of their own although the rate is the same as
`IE-S-09`, so that a sale says which relief it was taxed under and the code
closes when the relief does. Rates before the 2010 Act (the 21.5 % of December
2008 to December 2009 among them) are not carried: they were charged under the
Value-Added Tax Act 1972, which this pack does not cite. Revenue's
historical-rates page is in the register for anyone extending it.

What each of the rest is for:

- **Zero rate, exempt, export, outside the scope** — `IE-S-00` (Schedule 2),
  `IE-S-EXEMPT` (Schedule 1, reason code `VATEX-EU-132`), `IE-S-EXPORT`
  (Schedule 2 paragraph 3), `IE-S-OUTSIDE`.
- **Intra-Community** — `IE-S-ICG` to E1 (Schedule 2 paragraph 1(1)),
  `IE-S-ICS` to ES1 (s. 34(a)); `IE-P-ICG-23` and `IE-P-ICG-135` to E2 and
  `IE-P-ICS-23` to ES2, with the tax self-accounted in T1 and T2.
- **A service from outside the Union** — `IE-P-FSR-23`: T1 and T2, and no box
  for the value, because ES2 is for services from other Member States.
- **Postponed accounting** — `IE-P-PA-23`: PA1, T1 and T2 (s. 53A, since
  1 January 2021).
- **Construction (RCT)** — `IE-S-RCT` for the subcontractor, who charges no
  VAT, and `IE-P-RCT-135` and `IE-P-RCT-23` for the principal contractor, who
  self-accounts in T1 and T2 (s. 16(3)).
- **The moneys received basis** — `IE-S-23-CASH` and `IE-S-135-CASH`, for a
  company Revenue has authorised under s. 80: the tax waits on account 2205
  and reaches T1 in the period the customer pays. Purchases stay on the
  invoice basis, as the section says nothing of them.
- **What cannot be deducted** — `IE-P-23-ND` and `IE-P-135-ND` (s. 60(2):
  food, drink, accommodation, entertainment, petrol, most cars), and
  `IE-P-23-CAR`, the qualifying business car of s. 59(2)(d), 20 % deductible.

## The VAT3 return

Nine boxes, as Revenue's guidance names them: T1 VAT on sales, T2 VAT on
purchases, T3 VAT payable and T4 VAT repayable (each the difference of the two
above it, floored at zero), E1 and E2 for goods to and from other Member
States, ES1 and ES2 for services, and PA1 for imports under postponed
accounting.

**The VAT3 has no box for the value of a domestic sale or purchase.** That
figure goes on the annual Return of Trading Details, broken down by rate, so
the base postings of the domestic taxes name no box at all. The RTD is a
second declaration with its own period — the company's accounting year — and a
pack carries one form, so it is not here; see below.

**The cadence the Act gives everybody is the one proposed.** A taxable period
is two months beginning on 1 January, 1 March, 1 May… (s. 2), which is the
format's `bimonth`, and the form proposes it. Beside it the form declares
`month` and `year` — the monthly return Revenue authorises on request and the
annual accounting period of s. 77. The golden scenario files on the two-month
periods of the Act.

**The deadline** is the 19th of the month after the period (s. 76(1): "within
9 days immediately after the 10th day"). Revenue grants four more days, to the
23rd, to a return filed and paid through ROS; the pack does not add them yet,
because `plus_days` on a day-of-month rule is not exercised by the repository's
filing-calendar test, and a deadline four days early is never a late return.

**The financial year** is proposed as the calendar year. That is a convenience
and not the law: Companies Act 2014, s. 288 lets the directors fix the year end,
and the first financial year may run up to eighteen months from incorporation.
An operator names the first day of the year where it is anything else.

## Invoices

Numbering is `sequential` (reg. 20(2)(b): "a sequential number, based on one or
more series, which uniquely identifies the invoice"), payment terms 30 days
(S.I. 580/2012, "relevant payment date"), and the tax point
`invoice_if_issued` (s. 74(1)(a) and (d)). Six mentions: the construction
reverse charge in Revenue's own words, the intra-Community supply of goods and
the reverse charge on services required by reg. 20(2)(e) and (f), the export,
the exemption, and late payment interest.

**E-invoicing is not mandatory between businesses in Ireland today**, and the
pack says so: `mandatory_from` is empty. Public buyers must accept an EN 16931
invoice (S.I. 258/2019). Revenue has announced a phased mandate — large
corporates from November 2028, cross-border traders from November 2029, the
ViDA requirements from July 2030 — and none of it is enacted. The profile
declared is Peppol BIS Billing 3.0, what Irish Peppol participants exchange;
`9935` is the Ireland VAT number in the Peppol address scheme list.

**Bank formats**: `camt.053`, the one statement format Ekwo reads that Irish
banks send. No payment format is declared, because Ekwo writes none.

## Out of scope

- The **Return of Trading Details**, the VIES statements of ss. 82 and 83, the
  intra-Community consignment stock and call-off rules, and the One-Stop Shop.
- The **four-monthly and six-monthly** periods. The format can say them since
  0.2.0; no text of the register sets them yet.
- The **other domestic reverse charges** of s. 16 (emission allowances, scrap
  metal, construction between connected persons, gas and electricity to a
  dealer, NAMA): one sentence on the invoice names the principal contractor,
  and these would name the recipient.
- **Margin schemes**, the travel agents' margin scheme, the retail schemes, the
  zero-rating authorisation of s. 56, VAT groups, and partial exemption.
- **Schedule 3** (medium and large companies) and **Schedule 3B** (micro
  companies under FRS 105), group accounts, and any XBRL taxonomy.
- **Relevant Contracts Tax itself** — the deduction a principal withholds from
  a subcontractor — which is an income-tax mechanism of Part 18 of the Taxes
  Consolidation Act 1997, not VAT; the chart carries its accounts and nothing
  posts to them automatically.
- Corporation tax, PAYE, PRSI and USC.

## What a reviewer should read first

1. **The chart's mapping to Schedule 3A**, and whether an Irish practitioner
   would book office and computer equipment and motor vehicles under A.II.4
   "Fixtures, fittings, tools and equipment", as this pack does.
2. **`IE-P-FSR-23`**: whether the value of a service received from outside the
   Union belongs in any box of the VAT3. Revenue's page names ES2 for the
   Union alone, so the pack reports it in none.
3. **PA1**, which asks for the customs value plus duty: the pack posts the
   supplier's invoice value, and the two differ.
4. **The 9 % codes**: whether keeping the three reliefs apart from `IE-S-09`
   is how an Irish bookkeeper would want to choose a rate.
5. **The moneys received basis** as two sale codes rather than a regime of the
   company, which the core does not record.
6. **The flat-rate addition** as a purchase tax posting to T2 on the invoice
   the purchaser holds.
7. **The construction reverse-charge sentence**, and whether the other
   reverse charges of s. 16 should have their own.
