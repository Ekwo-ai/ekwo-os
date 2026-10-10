# Mauritius

Everything Mauritius adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 15 %, the zero rate and the exemptions, the VAT 3 return
filed monthly or quarterly, the statement of financial position and the
statement of profit or loss in the IFRS style, and what section 14 of the Act
does with a service bought from abroad. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Mauritian accountant can
disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Mauritian VAT return has reviewed
it. The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and nothing about whether it is right.

**Languages.** The pack is written in English; French is declared in
`pack.json` and complete (`i18n/fr.json`). Where each wording comes from is in
[`i18n/README.md`](i18n/README.md). What the core cannot say yet is in
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

## Sources

Every tax, box and statement line carries its own `legal_reference`, and beside
it the key of the text that article is in. The register in `pack.json` holds
nine texts.

| What | Text | Where |
|---|---|---|
| The charge, the rate, time of supply, zero-rating, exemption, reverse charge, VAT invoice, e-invoicing, input tax, returns | Value Added Tax Act 1998, consolidated version up to May 2026 | `mra.mu` |
| The lines of the return and the notes for completing them | Form VAT 3 | `mra.mu` |
| Monthly and quarterly cadence, electronic filing and payment dates | MRA, VAT return page; VAT FAQ of September 2025 | `mra.mu` |
| The filing portal | MRA e-Services | `eservices.mra.mu` |
| Fiscal invoices, the platform, the invoice registration number and the QR code | Value Added Tax (E-invoicing) Regulations 2023, Government Notice No. 132 of 2023; MRA e-invoicing page | `mra.mu` |
| Financial reporting standards | Financial Reporting Act 2004, ss. 72 and 75; Financial Reporting Council framework page | `mauritiuslii.org`, `frc.govmu.org` |

## The chart of accounts

**Mauritius prescribes no chart of accounts.** The Financial Reporting Act 2004
gives the Financial Reporting Council the task of issuing standards consistent
with IFRS, and the Council's own framework page applies standards consistent
with IFRS to the other companies as well; a company that is not a public
interest entity may use IFRS for SMEs. The chart is therefore written, not
transcribed: four digits by class (`1` assets, `2` liabilities, `3` equity, `4` income, `5` goods, `6`
other expenses, `7` finance costs, `8` income tax), flat, grouped by the ranges
of `statements.json`. 146 accounts, all postable. It adds what a Mauritian
company keeps: PAYE, National Pension Fund and National Savings Fund, Contribution
Sociale Généralisée, the HRDC levy and the Corporate Social Responsibility fund,
import VAT owed to the Authority and VAT deferred on imported capital goods.

**Four VAT accounts.** `2100` holds the output tax and `1150` the input tax, the
two the taxes post to. `2125` holds the import VAT between the customs entry
and its payment. `2110` (payable) and `1155` (refundable) are where a filed
return's balance lands. Only `1100`, `2000`, `2110` and `1155` are
`reconcilable`; the bank, cash and suspense accounts are not.

## Taxes

Rate 15 % (section 10 and the Fourth Schedule). Registration is compulsory above
Rs 3 million of annual taxable turnover (Sixth Schedule, lowered from Rs 6
million on 1 October 2025); the pack models the tax of a registered person and
leaves registration out.

| | Code | Line | Legal basis |
|---|---|---|---|
| Standard rate, sale | `MU-S-15` | 1.4 | s. 10, Fourth Schedule |
| Zero rate, export of goods | `MU-S-ZR-EXPG` | 1.1 | Fifth Schedule, item 1 |
| Zero rate, export of services | `MU-S-ZR-EXPS` | 1.1 | Fifth Schedule, item 6(a), as amended from 9 August 2025 |
| Zero rate, local | `MU-S-ZR-DOM` | 1.2 | Fifth Schedule (rice, bread, medical services, public transport, hairdressing…) |
| Exempt | `MU-S-EX` | 3 | First Schedule |
| Purchase, claimed | `MU-P-15` | 6.6 | s. 21(1), (3)(a) |
| Capital goods, claimed | `MU-P-15-CAP` | 6.4 | s. 21(1) |
| Purchase, credit refused | `MU-P-15-BL` | 7 | s. 21(2) |
| Purchase from an unregistered supplier | `MU-P-NR` | 7 | s. 20(5) |
| Zero-rated purchase | `MU-P-ZR` | 6.5 | Fifth Schedule |
| Exempt purchase | `MU-P-EX` | 8.2 | First Schedule |
| Imports: goods, capital goods, zero-rated, exempt | `MU-P-IMP`, `-IMP-CAP`, `-IMP-ZR`, `-IMP-EX` | 6.3, 6.1, 6.2, 8.1 | s. 10(1)(b), s. 21(5)(b) |
| Service received from abroad | `MU-P-RC-SVC` | 1.4 and 6.6 | s. 14 |

**Medical services are zero-rated, not exempt.** Item 42 of the Fifth Schedule
zero-rates medical, hospital and dental services, so a clinic recovers its input
tax; education and banking are exempt (First Schedule, items 16 and 50). The
Finance (Miscellaneous Provisions) Act 2025 added hairdressing services (item
62, in force from 6 June 2025).

**Section 14 and the reverse charge.** A registered person who receives a
service performed or used in Mauritius from a supplier that belongs abroad and is
not VAT registered accounts for the output tax and claims it as input tax.
`MU-P-RC-SVC` books both legs and reports the value and the output tax on line
1.4, as the notes for completing form VAT 3 ask, and the input tax on line 6.6.
Since 1 January 2026 a foreign supplier of digital or electronic services
registers and charges Mauritian VAT itself (sections 14A and 14B); the purchase
is then an ordinary one, and section 21(2)(i) refuses the credit on it, which
`MU-P-15-BL` carries.

## The return

**Form VAT 3, monthly or quarterly.** `tax_report.json` declares `month` and
`quarter` and no default cadence, since the cadence depends on turnover: a
registered person whose annual turnover of taxable supplies does not exceed Rs 10
million files quarterly and may elect monthly by an irrevocable written notice;
above that amount the return is monthly (section 22(1A), the Second Schedule and
the VAT FAQ). `ekwo init` asks.

**The deadline is the electronic one.** Form VAT 3 and the FAQ print 20 days
after the end of the period. Where the return is filed and the tax paid
electronically, the Authority's page gives the end of the month following the
period (a quarterly return: the month following the quarter), and section 22(1)
makes electronic submission the rule, so the pack declares
`last_day_of_month_after_period`. The 20-day rule is written into the
`legal_reference`; the format holds a single date per return.

**Lines 1.1 to 11 are carried; lines 12 to 19 are not.** The excess brought
forward, adjustments, the repayment claim, the penalties and interest settle one
period against the next, or are assessments, and no document writes them. Lines
1.3 (supplies to exempt bodies or persons), 2 (VAT deferred on imported capital
goods) and 4 (penalty) are declared and empty. A monthly filer also uploads a
list of taxable supplies with invoice number and value (section 22(1C)); the
format cannot write that annex.

## Electronic invoicing: a fiscalisation, not an exchange

`einvoicing.obligation` is `none` and `profile` is null: Mauritius has no
Peppol profile and no structured-invoice standard. Section 20A of the Act and the Value Added Tax
(E-invoicing) Regulations 2023 oblige the businesses the Authority designates to
send each invoice, debit note and credit note in real time to the Invoice
Fiscalisation Platform from a certified Electronic Billing System and to print the
invoice registration number and the QR code the platform returns. The Authority's
roll-out table lists limited companies above Rs 100 million from 15 May 2024, and
the other taxpayers above Rs 100 million from 1 August 2025, Rs 80 million from 30
June 2026 and Rs 40 million from 1 September 2026. Ekwo does not call the
platform; a company in scope fiscalises through a certified billing system.

## What this pack does not carry

- **The fiscalisation of invoices** (above).
- **Apportionment of input tax** for a business with taxable and exempt supplies
  (section 21(3)(b)): line 10 reports the whole of line 9, column B.
- **Line 7 inclusive of VAT.** The notes ask for the value of refused purchases
  including VAT; the pack reports the value excluding VAT.
- **The Deferred Payment Scheme** for imported capital goods (line 2).
- **The earlier of invoice and payment** as tax point (section 5(1)); the
  vocabulary has `invoice_date`, which the pack declares.
- **Other levies**: the solidarity levy of section 53B is not a VAT code and is
  out of scope; the corporate income tax is not modelled.
- **Fixed assets and corporate tax sections**: none.
