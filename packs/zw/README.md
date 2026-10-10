# Zimbabwe

Everything Zimbabwe adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 15.5 % (and the 15 % it replaced, closed on 31 December
2025), the zero rate and the exemptions, import VAT and imported services, the
VAT 7 return line by line, and the statement of financial position and the
statement of profit or loss of an IFRS-based presentation. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Zimbabwean accountant reading
the pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Zimbabwean VAT return has reviewed
it. The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**English only.** English is the language of the Value Added Tax Act and of
every form and notice of the Zimbabwe Revenue Authority (ZIMRA). The pack
declares `en` alone.

## Sources

Every tax, line and statement carries its own `legal_reference`, and beside it
the key of the text that article is in. The register in `pack.json` holds
fourteen texts:

| What | Text | Where |
|---|---|---|
| The charge, time of supply, zero rate, exemptions, imports, imported services, input tax, tax invoices, registration, tax periods, currency of payment | Value Added Tax Act [Chapter 23:12], consolidated to Act 13 of 2023 | `eregulations.zidainvest.com` |
| The 15.5 % rate, the fiscal tax invoice, the 2026 changes to zero rating and exemptions, imported services in US dollars, TIN and QR code on an invoice | Finance Act, 2025 (Act No. 7 of 2025), Part III | `veritaszim.net` |
| The return, line by line | VAT 7 Return (DTF 98, issue 3, 5 September 2023) | `zimra.co.zw` |
| The rate change by category | Public Notice No. 7 of 2026 | `zimra.co.zw` |
| Return on the 10th, payment on the 15th; input tax only on a valid fiscal tax invoice | Public Notice No. 11 of 2026 (Statutory Instrument 81 of 2025) | `zimra.co.zw` |
| TaRMS/FDMS integration and the input lines still filled by hand | Public Notice No. 63 of 2025 | `zimra.co.zw` |
| Buyer details on a fiscal tax invoice | Public Notice No. 30 of 2025 | `zimra.co.zw` |
| What a fiscal device sends, signs and prints | Fiscal Device Gateway API Specification v7.2 | `zimra.co.zw` |
| Where the return is filed; where an invoice is validated | TaRMS Self-Service Portal; FDMS validation portal | `mytaxselfservice.zimra.co.zw`, `fdms.zimra.co.zw` |
| Exempt goods | Statutory Instrument 15 of 2024 (First Schedule to the VAT (General) Regulations) | `veritaszim.net` |
| The currency | Statutory Instrument 60 of 2024; ISO 4217 list one | `veritaszim.net`, `six-group.com` |
| The accounting framework | IFAC member profile of Zimbabwe | `ifac.org` |

**The consolidated Act is to Act 13 of 2023**; the amendments of the Finance
Act, 2025 rest on that Act's own words, and nothing rests on the 2024 Finance
Acts. Points a reviewer should check against the primary text: the 15 % rate
from 1 January 2023 rests on ZIMRA's notice on the 2026 change, not on the
Finance (No. 2) Act, 2022; the list of exempt basic goods (maize meal, standard
bread, fresh milk, salt, cooking oil and others, according to commentary) must
be checked against Statutory Instrument 15 of 2024 itself; Statutory Instrument
81 of 2025 rests on ZIMRA's notices. No Reserve Bank page is cited.

## Currency: ZWG, US dollars, and how to choose

Zimbabwe runs a multi-currency system. The Zimbabwe Gold (ZiG, ISO 4217 `ZWG`,
numeric 924, two decimals) has been the local currency since 5 April 2024
(Statutory Instrument 60 of 2024, section 44D of the Reserve Bank of Zimbabwe
Act); the US dollar is used alongside it, by law until 2030 according to the
announcements of the Reserve Bank and the Treasury, and in practice for most of
what an SME invoices. Statutory Instrument 81 of 2025 reads every reference to
the Zimbabwe dollar in the revenue Acts as a reference to the local currency.

The pack carries `ZWG` as the default because it is the country's currency, not
because a company should keep its books in it. **The functional currency is the
company's choice under IAS 21**, and many Zimbabwean companies now report in
US dollars. `ekwo init` asks the currency and offers `ZWG` first; answer `USD`,
or pass `--currency USD`, to keep the books in dollars. A document in the other
currency is then a foreign-currency document, revalued through the exchange gain
and loss accounts (4700, 6950). The chart has a ZWG current account (1010) and
a US dollar nostro foreign currency account (1030) side by side, plus 1035 for
other currencies and 1045 for petty cash in dollars; 4040 and 4050 hold sales
and services invoiced in foreign currency if a company wants them apart.

**What the tax law says about currency.** Section 38(4) and (4a) of the Value
Added Tax Act: tax received in foreign currency is paid to ZIMRA in that foreign
currency; tax on a supply paid in local currency may be paid in local currency
or in foreign currency; import VAT is paid in foreign currency (s. 38(4)(b)); and
from 1 January 2026 the tax on imported services is paid in US dollars (s. 13(6),
inserted by the Finance Act, 2025). Part V of the VAT 7 return therefore splits
sales, purchases and the amount payable between foreign currency and local
currency. **The pack cannot compute Part V**: a box adds up postings, and the
socle has no box filtered on the currency of the document. A company dealing in
both currencies takes Part V from its documents by currency. This is recorded
as a gap of the socle.

## The chart of accounts

There is no legal chart of accounts in Zimbabwe. This one is original: four
digits, blocked so that each range reaches one line of the statements, 157
accounts. Beyond a general IFRS-style chart it carries what a Zimbabwean company
owes: VAT output and input tax, the net VAT settlement accounts (1155 and
2110), import VAT owed at the border (2125), VAT withheld by a customer
appointed as an agent (1165, credited on line 33 of the return) and VAT this
company withholds as an agent (2165), PAYE and AIDS levy, NSSA and ZIMDEF,
withholding tax, intermediated money transfer tax, digital services withholding
tax, and the input tax s. 16(2) blocks (6530).

Only trade receivables, trade payables and the two VAT settlement accounts are
reconcilable. The bank, cash and suspense accounts are not.

## Taxes

| Code | Rate | What | VAT 7 line |
|---|---|---|---|
| `ZW-S-15.5` | 15.5 % | Standard-rated sale, from 1 January 2026 | 9 (credit notes 18) |
| `ZW-S-15` | 15 % | Standard-rated sale, 1 January 2023 – 31 December 2025 (closed) | 9 (18) |
| `ZW-S-15-T` | 15 % | From 2026: a supply made in 2025 but accounted for in 2026, or a credit or debit note on it | 9 (18) |
| `ZW-S-Z-EXP` | 0 % | Exports, international transport, services to a non-resident abroad (s. 10(1)(a), (2)) | 10(a) |
| `ZW-S-Z-DOM` | 0 % | Local zero rate: gold to the Reserve Bank or a bank, gold coins, the services of s. 10(2) | 10 |
| `ZW-S-EX` | exempt | Financial services, residential letting, passenger transport, education, medical, the First Schedule goods, and from 2026 agricultural goods and medicines (s. 11) | 12 |
| `ZW-P-15.5` / `ZW-P-15` | 15.5 % / 15 % | Deductible local purchase (15 % closed on 31 December 2025) | 21 (credit notes 29) |
| `ZW-P-15-T` | 15 % | From 2026: a 2025 purchase accounted for in 2026, or a note received on it | 21 (29) |
| `ZW-P-15.5-CAP` | 15.5 % | Local capital good | 24(a) |
| `ZW-P-15.5-ND` | 15.5 % | Entertainment and the other blocks of s. 16(2); tax to 6530 | — |
| `ZW-P-Z`, `ZW-P-EX` | 0 % | Zero-rated and exempt local purchases | 21(a), 25 |
| `ZW-P-IMP` | 15.5 % | Import of goods, VAT paid to customs, held on 2125 | 23 |
| `ZW-P-IMP-CAP` | 15.5 % | Import of a capital good | 24 |
| `ZW-P-RC-SVC` | 15.5 % | Imported service: output on line 13, input in the TaRMS field "VAT on imported services" | 13 / IMS |

Choices that carry weight:

- **The rate is 15.5 % from 1 January 2026, not 2025.** The Finance Act, 2025
  (Act No. 7 of 2025, s. 34) changed the Schedule to Chapter IV of the Finance
  Act from 1 January 2026, and ZIMRA's Public Notice No. 7 of 2026 confirms it.
  The 15 % codes are kept, closed on 31 December 2025, so a document is taxed by
  its own date. A supply whose time of supply fell in 2025 but is declared in
  2026 keeps 15 %, and so does a credit or debit note issued in 2026 on a 2025
  supply: the codes `ZW-S-15-T` and `ZW-P-15-T`, open from 1 January 2026, carry
  that case (Public Notice No. 7 of 2026, item 2). ZIMRA's notice explains how
  to gross the value up on the TaRMS return, which is configured at 15.5 %; the
  pack reports the tax as booked and leaves the gross-up to the filer.
- **The 2026 zero-rating changes.** Section 37 of the Finance Act, 2025 repealed
  the zero rate of prescribed agricultural goods (s. 10(1)(g)), of prescribed
  medicines (s. 10(1)(j)) and of designated tourist facilities (s. 10(2)(q)), and
  narrowed the going-concern zero rate to a transfer to the Public Service
  Pension Fund. Section 38 made agricultural goods and medicines exempt (s.
  11(k), (l)) and added rural electrification (s. 11(m)). The pack has no dated
  2025 code for those zero rates; a company that sold them in 2025 books them
  under `ZW-S-Z-DOM`.
- **An imported service is deductible.** Unlike Zambia, Zimbabwe makes the tax
  a recipient pays on an imported service input tax (s. 2(1), "input tax",
  (a)(iii), inserted by Act 3 of 2019). The pack posts it on both sides. Section
  13(1) also lets the recipient declare and pay it within thirty days, on the
  imported-services variant of the VAT 7; the pack shows it on the period's
  return.
- **Credit notes have their own lines.** The VAT 7 declares debit and credit
  notes as adjustments (line 18 for sales, line 29 for purchases), not netted
  against line 9 or 21, and the pack posts them there. The form asks the
  consideration including VAT; the pack's value row is net of VAT, so the
  consideration is the value plus the tax.

## The return: VAT 7

The boxes are the lines of the VAT 7 form (Part II output tax, Part III input
tax, Part IV the amount payable), with their numbers: 9, 10, 10(a), 12, 13, 18,
20 (total output tax [A]), 21, 21(a), 23, 24, 24(a), 25, 29, 30 (total input tax
[B]) and 34 (A − B). One row, `IMS`, is not on the 2023 paper form: it is the
TaRMS field "VAT on Imported Services" that Public Notice No. 63 of 2025 says is
filled by hand.

Not posted by any tax, entered on the return by hand: lines 14 to 17 and 19
(sale in execution of a debt, change of use, bad debts recovered, motoring
fringe benefits), 22, 23(b), 24(b) (diplomats), 25(a) (exempt imports), 26 to 28,
33 (VAT withheld by appointed agents, on certificates), 35 to 39 (penalty,
interest, credit brought forward) and the whole of Part V (by currency, above).

**Periods.** Section 27 of the Act: Category C files monthly (compulsory above
US$240,000 of taxable supplies in twelve months, or on request); Categories A
and B file every two months; Category D is for farmers. The pack declares
`month` and `bimonth` and no default, so `ekwo init` asks. **Category A cannot
be expressed**: the format's two-month period runs January–February, March–April
(Category B), while Category A runs December–January, February–March. A
Category A operator files on periods the socle does not yet build.

**Deadline.** The 10th of the month after the period for the return, the 15th
for the payment (Statutory Instrument 81 of 2025, ZIMRA Public Notice No. 11 of
2026), replacing the 25th of s. 28(1). The format holds one day; the pack
carries the 10th.

**Registration.** Compulsory when taxable supplies exceed US$25,000 in twelve
months (s. 23(1)(a), as amended by Act 13 of 2023); the pack does not check a
threshold.

## Fiscalisation (FDMS): outside the pack, a gap of the socle

Since 1 January 2026 a tax invoice under the Value Added Tax Act **is** a fiscal
tax invoice: printed by a fiscal device the Commissioner approved (an electronic
tax register, fiscal printer, signature device, fuel device, or a virtual
fiscal device — a software application), whose details were transmitted to
ZIMRA's Fiscalisation Data Management System (FDMS) and show "Valid" on the
FDMS validation portal (s. 2(1) as substituted by the Finance Act, 2025, s. 35).
Input tax is claimed only on such invoices, which TaRMS now pulls from the FDMS
(Public Notices No. 63 of 2025 and No. 11 of 2026), and a tax clearance
certificate is refused to an operator who does not fiscalise.

What it requires, from ZIMRA's Fiscal Device Gateway API Specification v7.2:

- **A registered device.** `registerDevice` with the device ID and an
  activation key, and a certificate signing request; every later call is mutual
  TLS with the device certificate.
- **Fiscal days.** `getConfig`, then `openDay`; receipts are sent one by one
  while the day is open; `closeDay` with a signed day summary (Z report).
- **Each receipt signed and submitted.** `submitReceipt` carries the receipt
  type (`FiscalInvoice`, `CreditNote`, `DebitNote`), the ISO currency, a
  receipt counter per day and a global number since activation, the accounting
  system's own invoice number (unique per taxpayer), the buyer (name and TIN
  required if a buyer is sent; VAT number, address, phone and e-mail optional),
  the lines, the taxes, the payments and a SHA-256 device signature. A credit
  or debit note references the original receipt, is in the same currency,
  within twelve months, and cannot exceed it.
- **What the printed invoice shows.** The label "FISCAL TAX INVOICE" (or
  "CREDIT NOTE", "DEBIT NOTE"), the seller's name, TIN, VAT number, branch
  address and contacts, the buyer block, the receipt counter and global number,
  the fiscal day, the device serial number and device ID, the date and time,
  the lines with their tax, and a **QR code**: ZIMRA's verification URL followed
  by the device ID (10 digits), the date (ddMMyyyy), the global number (10
  digits) and the first 16 characters of an MD5 hash of the device signature,
  also printed as text.

Ekwo has none of this: no device certificate, no fiscal day, no signature, no
call to the FDMS, no QR code. `einvoicing.obligation` is `none` because no
statute requires an exchange between businesses; fiscalisation is a reporting
obligation to the tax administration, and Peppol has nothing to do with it. A
Zimbabwean company on Ekwo issues the fiscal tax invoice from its fiscal device
or certified software and records the same document in Ekwo. Every Ekwo
document therefore carries the mention `not_a_fiscal_tax_invoice`, which says so
to the buyer. What the socle would need: a virtual fiscal device module that
holds the device certificate, opens and closes fiscal days, signs and submits
each posted sale and credit note, keeps the counters, and stores and prints the
FDMS signature and QR code.

## The fiscal tax invoice, field by field

Section 20(4) of the Act, with paragraphs (h) and (i) added from 1 January 2026,
and the buyer details of Public Notice No. 30 of 2025:

| Particular | Where Ekwo has it |
|---|---|
| The words "fiscal tax invoice" | Printed by the fiscal device only; Ekwo prints the opposite mention |
| Supplier's name, address, registration (VAT) number | Company name, address, VAT number |
| Supplier's TIN (BP number) | Company registration number, if the company enters its TIN there |
| Supplier's telephone and e-mail | Company phone and e-mail |
| Buyer's name and address | Contact name and address |
| Buyer's TIN and VAT number | Contact registration number and VAT number |
| Buyer's contact details (e-mail) | Contact e-mail |
| **Buyer's telephone** | **Not in the document view: a gap of the socle** — the contact has a phone, the invoice view does not carry it |
| Serial number and date of issue | Document number and date |
| Description, quantity, value, tax and consideration | Document lines and totals |
| QR code or authentication code; device serial number; fiscal day; receipt numbers | **Not carried: produced by the fiscal device** |

There is no dedicated TIN field: Zimbabwe's TIN (the former BP number, ten
digits on the FDMS) and VAT number (nine digits) are two identifiers, and the
pack maps the TIN onto the registration number. That mapping is a convention of
this pack, not something the socle validates.

## Other taxes, documented and not computed

- **Corporate income tax**: 24 % of taxable income plus the AIDS levy of 3 % of
  the tax (an effective 24.72 %), paid in quarterly payment dates (QPDs).
  Accounts 8000, 8005 and 1355. Not computed; the rates should be checked
  against the Income Tax Act [Chapter 23:06].
- **Intermediated money transfer tax (IMTT)**: 2 % on electronic transfers,
  withheld by the bank; the cost goes to 6455. Not a tax code.
- **PAYE, AIDS levy on PAYE, NSSA contributions, ZIMDEF levy**: accounts 2150,
  2155, 2160, 6030, 6040. Payroll is outside the pack.
- **Withholding taxes**: on payments to non-residents, and the withholding
  under s. 80 of the Income Tax Act on a payment to a supplier who does not
  produce a valid tax clearance certificate (30 %, as commonly reported — to be
  checked). Account 2140.
- **VAT withholding by appointed agents** (a share of the VAT, on
  certificates, line 33): accounts 1165 and 2165; not posted by a tax code.
- **Digital services withholding tax** (s. 13A and the Second Schedule, Finance
  Act, 2025): withheld by the bank on payments to non-resident platforms; the
  remitted cost is a purchase, account 2178 for an intermediary.
- **Stamp duty**, **excise duty**, **export taxes on unbeneficiated minerals**
  (ss. 12B to 12J): accounts 6485 and 2170; not computed.

## Financial statements

Companies and Other Business Entities Act [Chapter 24:31]: accounting records
and annual financial statements. The Public Accountants and Auditors Board
prescribes IFRS Accounting Standards for publicly accountable entities and the
IFRS for SMEs Accounting Standard for eligible entities (Statutory Instrument
137 of 2026, replacing Statutory Instrument 41 of 2019, per IFAC). The two
statements, `ZW-PAAB-SFP` and `ZW-PAAB-IS`, are a statement of financial
position and a statement of profit or loss by nature of expense, IAS 1 / sections 4 and 5 of IFRS for SMEs. No
statutory layout exists. Hyperinflation accounting (IAS 29), which Zimbabwean
companies applied for years, is not modelled.

**Financial year.** The pack's default is the calendar year, a usage and not a
rule; `ekwo init --fiscal-year` takes another.

## The golden

One month, August 2026, of a Harare company in Category C, in the company's
currency: two standard-rated sales, an export, an exempt letting, a credit note
at 15.5 % and a rebate at 15 % on 2025 deliveries, a local purchase, an exempt
bank charge, an import with VAT at the border, an imported service, a blocked entertainment cost, a capital good, a purchase
credit note, three matched payments and one advance left open. The return comes
to total output tax 4,360.00, total input tax 13,175.00, a refund of 8,815.00.

The golden format has no document currency, so it cannot show one invoice in
US dollars and another in ZWG: the scenario runs in the company's currency and
the revenue account 4050 stands for a foreign-currency service.

## What this pack does not carry

- Part V of the VAT 7 (by currency) and the currency of payment rules of s. 38.
- Fiscalisation (above).
- The buyer's telephone on the invoice.
- Category A tax periods.
- The payment deadline (15th) beside the return deadline (10th).
- Partial exemption: s. 16(1) apportions input tax by intended use (with the
  90 % de minimis); the pack has fully deductible and fully blocked codes.
- The deferment of import VAT on capital goods (s. 12A), the auctioneer regime,
  the special return of s. 29, and the export taxes.
- A five-way time of supply (s. 8(1)); the format's nearest value is
  `earliest_of_delivery_or_payment`.

## Reviewing this pack

A Zimbabwean accountant (ICAZ member) is asked to confirm: the list of exempt
goods in Statutory Instrument 15 of 2024 and its 2025 and 2026 amendments; the
classification of agricultural goods and medicines after 1 January 2026;
whether imported services are declared on the period's return or on the
separate thirty-day declaration in practice; the treatment of credit notes on
lines 18 and 29 against TaRMS's automatic credit-note management; the rule for
choosing between ZWG and US dollar books, and the use of Part V; the 30 %
withholding without a tax clearance certificate; and the IFRS for SMEs
thresholds.
