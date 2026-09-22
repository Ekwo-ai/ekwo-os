# Saudi Arabia

Everything the Kingdom adds to Ekwo, as data: a chart of accounts, the
journals, the 15 % value added tax with its zero-rated and exempt supplies and
its reverse charge, the VAT return ZATCA's portal asks for, the statement of
financial position and the income statement of the IFRS for SMEs Accounting
Standard, and the sentences the law puts on a tax invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Saudi accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Saudi VAT return has reviewed it.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**The law here is Arabic, and this pack is English.** ZATCA's own English
translation of the Implementing Regulations carries the warning that the
Arabic version supersedes it; [`i18n/README.md`](i18n/README.md) says what that
changed, and names the two places where the two versions were found to differ.

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds sixteen texts, every one of them opened on 22 September 2026.
The four the rest of this file leans on most:

| What | Text | Where |
|---|---|---|
| The rate | نظام ضريبة القيمة المضافة — the VAT Law, Royal Decree No. M/113, consolidated Arabic text | `zatca.gov.sa` |
| Zero rating, exemptions, deduction, the reverse charge, imports, invoices, tax periods and returns | Implementing Regulations of the VAT Law, eighth edition (English), with the Arabic tenth edition of April 2025 beside it and the guideline to the November 2024 amendments | `zatca.gov.sa` |
| The fields of the return | Guideline on Imports and Exports under VAT Provisions (fields 8 and 9, in words) and the simplified Arabic filing guideline (the sales screen, fields 1 to 5) | `zatca.gov.sa` |
| FATOORA | E-invoicing Regulation of 4 December 2020, the Governor's Decision No. (62738), and the Electronic Invoice XML Implementation Standard v1.2 | `zatca.gov.sa` |

**Three things this pack's research could not open, and they are named rather
than papered over.**

- **An English text of the VAT Law.** The Authority's VAT Law page links one
  bilingual PDF, and that link returns an error page. The Law is therefore
  cited from ZATCA's consolidated Arabic text, and Article 2(2) is quoted in
  Arabic in `SA-S-SR`.
- **`laws.boe.gov.sa`**, the Bureau of Experts' official gazette of Saudi
  legislation, refused every connection from this research pass. Every law
  cited here is cited from ZATCA's own publication of it.
- **The return itself.** It is a screen of the ZATCA portal, not a form: the
  official User Guide to the Submit VAT Return service shows it only as
  screenshots, and the field labels could not be read as text. What could be
  read is the numbering — see "The return" below.

## The chart of accounts, and why this one

**There is no legal chart of accounts in the Kingdom**, as far as this pack's
research could establish. Neither ZATCA nor SOCPA publishes one; what SOCPA
publishes is the framework — the IFRS Accounting Standards, the IFRS for SMEs
Accounting Standard for a small or medium-sized entity, and standards of its
own where IFRS does not reach, zakat being the named case. That is an absence
of evidence and not a citable denial, and `pack.json` says so at the chart's
own `legal_reference` rather than naming an article that does not exist.

- **Four digits, by class**: `1` assets, `2` liabilities, `3` equity, `4`
  revenue and other income, `5` cost of sales, `6` other expenses, `7` finance
  costs, `8` zakat and income tax.
- **Flat**, every account a leaf, grouped by the ranges of `statements.json`.
- **The accounts a Saudi company actually keeps**: VAT input and output tax,
  the amount payable to and refundable by ZATCA, import VAT owed to Saudi
  Customs, withholding tax payable and withholding tax suffered, GOSI
  contributions, an end-of-service benefits provision, and **zakat apart from
  income tax** — the two are assessed on one company at once, on the shares
  held respectively by Saudi and GCC persons and by others, and the income
  statement keeps them on two lines for that reason.

115 accounts, all postable. None was copied from a published chart.

## Taxes

**One positive rate, 15 %.** VAT Law, Article 2(2), as amended by Royal Order
No. A/638 dated 15 Shawwal 1441H. The rate was 5 % from 1 January 2018;
Article 79(10) of the Implementing Regulations is the transitional rule that
decides which rate a supply straddling 1 July 2020 takes, and `valid_from` on
every tax of this pack is that day. A pack that needs the 5 % period will add
the codes for it with a `valid_to`, never by editing these.

**What a sale can be, and where it lands on the return:**

| | Code | Field | Article |
|---|---|---|---|
| Standard-rated | `SA-S-SR` | 1, tax in 1 | Law, art. 2(2) |
| Export of goods | `SA-S-ZR-EXP` | 4 | IR, art. 32 |
| Services to a customer outside the Council | `SA-S-ZR-SVC` | 4 | IR, art. 33 |
| International transport | `SA-S-ZR-TRANSPORT` | 3 | IR, art. 34 |
| Qualifying medicines and medical goods | `SA-S-ZR-MED` | 3 | IR, art. 35 |
| First supply of an investment metal | `SA-S-ZR-METAL` | 3 | IR, art. 36 |
| Financial services on an implicit margin | `SA-S-EX-FIN` | 5 | IR, art. 29 |
| Lease of residential real estate | `SA-S-EX-RESI` | 5 | IR, art. 30(1)(b) |
| Transfer of ownership of real estate | `SA-S-EX-REALESTATE` | 5 | IR, art. 30(1)(a) |
| Outside the scope | `SA-S-OS` | none | IR, art. 17 and 22–28 |

**What a purchase can be:**

| | Code | Fields |
|---|---|---|
| Standard-rated, deductible | `SA-P-SR` | 7 |
| Entertainment or catering — input tax blocked | `SA-P-BL-ENT` | none |
| Restricted motor vehicle — input tax blocked | `SA-P-BL-CAR` | none |
| Zero-rated | `SA-P-ZR` | 10 |
| Exempt | `SA-P-EX` | 11 |
| Supplier not registered | `SA-P-NR` | none |
| Import, VAT paid at Customs | `SA-P-IMP` | 8 |
| Import, VAT paid through the return | `SA-P-IMP-RC` | 9 |
| Services from a non-resident, reverse charge | `SA-P-RC-SVC` | 9 |

**Two decisions in this table are worth reading twice.**

*Field 9 nets to zero.* The guideline on imports and exports says the portal
"automatically treats the Input Tax as deductible on the supply" in field 9, so
a taxable person deducting in full owes nothing on the line. The two tax
postings of `SA-P-RC-SVC` and `SA-P-IMP-RC` reproduce exactly that: the output
tax is credited to 2100 and the same amount debited to 1150, and the two cancel
in the box while both stand in the ledger. The guideline's own example is a
bank deducting 70 %, which enters the non-deductible share in the field's
adjustment column — a column this format has no room for, and a case this pack
does not carry, because it carries no proportional deduction at all.

*Import VAT is owed to Customs, not to the supplier.* `SA-P-IMP` credits 2105,
the amount owed to Saudi Customs under Article 43(3), and not the supplier's
account: the exporter in the other country never charged it.

## The return

`tax_report.json` carries sixteen numbered fields. **Their numbering is
sourced and their names are this pack's own English.** The simplified Arabic
filing guideline reproduces the sales screen with its fields numbered 1 to 5
and glosses each of them; the guideline on imports and exports names fields 8
and 9 in words — "VAT shall be included in Field 9 of the VAT return instead of
Field 8, which includes VAT paid to ZATCA". Fields 6, 7, 10 to 16 take the
place that numbering leaves them and a name built on Article 62(2) of the
Implementing Regulations, which lists what a return must disclose. **A reviewer
who files a real return should check the labels before anything else in this
pack.**

- **Monthly or quarterly, and the pack does not choose.** Article 58: monthly
  above 40,000,000 riyals of annual taxable supplies in the previous twelve
  months, three months for everybody else. Because the cadence turns on the
  taxpayer's own turnover, `period_default` is deliberately absent and `ekwo
  init` asks.
- **Due the last day of the month after the period**, for the return
  (Article 62(1)) and for the payment (Article 59(1)) alike.
- **Field 2 exists and nothing posts to it.** Private education and private
  healthcare supplied to Saudi citizens have a line of their own on the return
  and reason codes of their own on the invoice (VATEX-SA-EDU, VATEX-SA-HEA,
  with the buyer's National ID made mandatory). This pack could not open the
  instrument that grants the regime or the conditions on it, so it carries the
  field and no tax that posts there.
- **Field 14 says 15,000 riyals**, not the 5,000 the English Regulations still
  print: the Arabic tenth edition of April 2025 and the filing guideline both
  say 15,000, and the Arabic is what the English defers to.

## FATOORA, and what Ekwo does not do

Electronic invoicing is obligatory, and **`einvoicing.profile`,
`mandatory_from` and `obligation` are all empty**. That is not an oversight,
and the reason is in `pack.json` at length. In short: FATOORA is a clearance
regime. Since the Integration phase began on 1 January 2023, wave by wave, a
Tax Invoice between businesses is transmitted to ZATCA, which verifies it and
"shall insert the Cryptographic Stamp only on the Invoices and Notes which
fulfil the aforesaid controls ... prior to sharing them with the customers" —
an invoice ZATCA has not stamped is not one the seller may hand over. A
Simplified Tax Invoice is instead reported within 24 hours of generation. The
document is XML, or PDF/A-3 with the XML embedded, written against ZATCA's own
UBL 2.1 subset, signed with an ECDSA key, chained by a hash to the invoice
before it, and carrying a QR code.

No brick of `packages/formats/` writes that XML, signs it, chains it or talks
to ZATCA's API. **A document issued from Ekwo is not an Electronic Invoice**,
and `mandatory_from` with a profile would claim it was. `packs/mx/`,
`packs/vn/` and `packs/kr/` reached the same conclusion for the same kind of
regime; Saudi Arabia is the fourth, and
[`docs/international.md`](../../docs/international.md) says what the core would
need to stop the four of them going on saying nothing.

## What this pack does not carry

- **Zakat and income tax.** Both are assessed by ZATCA on the company itself,
  on separate bases, and neither touches a VAT box. The chart carries the
  accounts and the income statement the two lines; the rates and the base are
  another pack's work.
- **The Real Estate Transaction Tax**, 5 % since Royal Decree No. M/84 came
  into force on 10 April 2025. It is why a transfer of real estate is exempt
  from VAT rather than taxed, and `SA-S-EX-REALESTATE` says so — but RETT is
  declared on its own ZATCA service and nothing of it lands on the VAT return.
- **Withholding tax on payments to non-residents.** The chart carries 2120 and
  1157 for it; the rates are the Income Tax Law's and this pack's research did
  not open that text.
- **Proportional deduction** (Articles 51 and 52), the capital assets
  adjustment (Article 52), the profit margin method for eligible used goods
  (Article 48), the cash accounting basis (Article 46, open on
  application to a taxable person whose annual taxable supplies stay under
  5,000,000 riyals), and the tax group
  (Articles 10 to 12).
- **Private education and private healthcare to citizens**, for the reason
  field 2 gives.
- **Arabic labels, although ZATCA publishes them.** There is no `i18n/ar.json`:
  a translation file the manifest does not declare is compiled into the seed
  and then refused by `tests/languages.test.ts`, and declaring Arabic would
  demand a wording for 115 accounts no authority names and for two invoice
  mentions this pack wrote itself — where Article 53(5) requires the details it
  lists to be printed in Arabic. [`i18n/README.md`](i18n/README.md) carries the
  ten tax labels ZATCA does publish in Arabic, sourced line by line, for
  whoever fills the file in.

## Registration, for context

Mandatory above 375,000 riyals of annual supplies, optional above 187,500 —
the thresholds ZATCA states on its registration service, which Articles 3 and 7
of the Implementing Regulations take from Articles 50(2) and 51(3) of the
Common VAT Agreement. The pack carries no rule about them: registration is a
fact about the company, and `SA-P-NR` is the only tax that depends on it.

## Why there is no Gulf folder

The Kingdom is the second pack of the Gulf, after `packs/ae/`, and four more
are expected. They do not share a folder the way the seventeen OHADA packs
share `packs/ohada/`, and
[`docs/international.md`](../../docs/international.md) sets out the evidence
under "From Saudi Arabia": what the Common VAT Agreement harmonises is
vocabulary and structure, and what `packs/ohada/` copies is a chart of accounts
and two financial statements, which the Agreement does not have and the six
States do not share.
