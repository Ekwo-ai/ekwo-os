# Brunei Darussalam

Everything Brunei Darussalam adds to Ekwo, as data: a chart of accounts, the
journals, the two "not subject" tax codes that carry every sale and purchase a
Brunei business books, the balance sheet and income statement of the Brunei
Darussalam Accounting Standards, and the numbering rule the Income Tax Act puts
on a receipt. The format is [`docs/packs.md`](../../docs/packs.md); this file
says where the content came from and which decisions it rests on, so that a
Brunei accountant reading the pack can disagree with a specific sentence
rather than with the whole of it. The model is the Hong Kong pack, the other
jurisdiction in this repository with no tax on sales.

**Status: `community`.** Nobody who practises in Brunei Darussalam has
reviewed it. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**Language: English.** The English text of a written law is authentic; the
Malay text prevails if the two conflict (not verified against a statute in
this research, which read the English texts only). The pack's labels, chart
and statements are in English.

## Sources

Eleven texts, opened on 10 October 2026, are registered in `pack.json`:

| What | Text |
|---|---|
| Companies taxed at 18.5 %; withholding tax 2.5 % / 10 %; 1 % tax on approved exports; the duty to issue printed, serially numbered receipts and keep 7 years of records (s. 56A) | Income Tax Act (Chapter 35), 2021 Edition, B.L.R.O. 1/2024 |
| What the receipt duty covers in practice (invoices, delivery orders, official receipts); electronic records accepted | Revenue Division, Public Ruling PR No. 01/2021, *Keeping of Books of Accounts* |
| Taxes the Revenue Division administers; petroleum tax at 55 %; the company threshold | Revenue Division, *Income Tax*, *Corporate Tax* FAQ, *Stamp Duty* |
| Customs and excise duties restructured from 1 April 2017 | Ministry of Finance, press release |
| The balance sheet and income statement of non-public interest entities | BDAS NON-PIE (Brunei Darussalam Accounting Standards Council) |
| IFRS for entities with public accountability from 1 January 2014 | BDASC Notice No. 1/2014; *FAQs on BDAS* |
| No Peppol Authority | OpenPeppol, *Peppol Authorities* |
| Where returns are filed | One Common Portal (`ocp.mofe.gov.bn`) |

Not opened, and therefore not cited as authority: the Companies Act
(Chapter 39), the Record Keeping (Business) Act (Chapter 249) — its server
returned an error for the PDF; a search summary says its section 5 repeats the
printed, serially numbered receipt duty with a five-year retention period, the
longer seven-year period of the Income Tax Act being the one this pack uses —
the Accounting Standards Act (Chapter 267; the BDASC notices still call it the
Accounting Standards Order, 2010), whose PDF has no text layer, the Excise
Duties Order 2012 and the Stamp Act (Chapter 34). A Brunei accountant should
confirm them.

## No tax on sales: checked on 10 October 2026

Brunei Darussalam has no value added tax, goods and services tax or general
sales tax. The Revenue Division of the Ministry of Finance and Economy lists,
under "Type of Taxes", income tax, withholding tax and stamp duty; its
corporate tax FAQ names only the tax on companies' chargeable income; and the
Income Tax Act contains no tax on supplies. Secondary summaries found in the
same research agree. No announced project to introduce one was found. No
official statement ruling one out was found either, and a reviewer should
treat "no plan" as the absence of an announcement and nothing more.

**Two codes, both at 0 %, both `not_subject`:** `BN-S-NA` on every sale and
`BN-P-NA` on every purchase, with postings of the base only. There is no
declaration (`tax_report.json` does not exist), no VAT settlement account and
no `tax_payable` / `tax_receivable` role, as in Hong Kong. `vat_category` is
`O` and no exemption code is set.

## What is levied instead, and not modelled

All of these are outside the pack: no tax code carries them.

- **Corporate income tax** — 18.5 % of chargeable income of companies
  incorporated or registered under the Companies Act (Cap. 39), from the year
  of assessment 2015 (Income Tax Act s. 35(1)(f)); only 25 % of the first
  $100,000 and 50 % of the next $150,000 is charged (s. 35(4), Revenue
  Division); sole proprietorships and partnerships registered as business
  names are not taxed (Revenue Division FAQ). Returns are due by 30 June.
- **Petroleum income tax** — 55 %, Income Tax (Petroleum) Act (Cap. 119).
- **Withholding tax on payments to non-residents** — 2.5 % on the income of
  s. 9(4), 10 % on royalties and the payments of s. 9(5), 10 % on a
  non-resident director's remuneration (s. 35(2), (2A), (2B)). The chart
  carries a payable account, `2065`; the tax is not computed.
- **Tax on approved exports** — 1 % of the gross proceeds of approved exports
  (s. 8A). It is an income tax on the approved exporter, assessed under the
  Act; no invoice line carries it, so the export sale in the golden uses
  `BN-S-NA` like any other.
- **Excise and customs duties** — on specified goods, at the border (Excise
  Duties Order 2012 and Customs Import Duties Order, amended with effect from
  1 April 2017). Chart account `5020` books freight; duty goes to the cost of
  the goods.
- **Stamp duty** — on instruments (Stamp Act, Cap. 34); expense account `6205`.
- **Employee retirement contributions** (TAP, SCP) — account `2050` exists;
  rates and rules were not researched.
- **Pillar Two** — no Brunei measure could be confirmed in this research.

## The chart of accounts

Brunei prescribes no chart of accounts. The Income Tax Act requires sufficient
records (s. 56A(1)(a)); the Revenue Division's ruling asks for records that
let a true and fair profit and loss account and balance sheet be prepared. The
chart is written, not transcribed: four digits by class, flat, blocked by the
ranges `statements.json` reads, 106 accounts, adapted from the Hong Kong
pack's layout with Brunei names. Only trade debtors (`1100`) and trade
creditors (`2000`) are `reconcilable`. It carries no tax-clearing account.

## The statements

BDAS NON-PIE (BDAS 1, paragraphs 1.1 and 1.19 to 1.28) asks for a balance
sheet, an income statement, notes and a cash flow statement. `statements.json`
carries the balance sheet and the income statement, classifying expenses by
nature and showing current tax assets, tax liabilities, finance costs and tax
expense on their own lines as paragraphs 1.19 and 1.22 require. **The cash flow
statement (BDAS 18) is not carried.** The standard does not say which
framework it derives from, so this pack does not claim one; its structure
(separate income statement, no other comprehensive income) is why the model is
the Hong Kong SME statements. The BDASC FAQ says entities without public accountability are
"encouraged to adopt" IFRS, and no adoption of IFRS for SMEs was found, so a company reporting under full IFRS ties into the same two
statements by account range but would present a statement of comprehensive
income this pack does not.

`fiscal_year_default` is `calendar`: no text consulted fixes a year end. The
income tax year of assessment follows the basis period of the accounts.

## On the invoice

**Numbering is `sequential`, not `free`.** Section 56A(1)(b) of the Income Tax
Act requires "a printed receipt serially numbered for every sum received" and
a retained duplicate, on pain of an offence (s. 56A(5)); the Revenue
Division's ruling reads this as covering sales invoices, delivery orders and
official receipts. The Act says nothing about gaps, so it is not `gapless`.
The text says "printed": the ruling accepts electronic records, but does not
say a software-generated number satisfies the receipt duty. Records are kept
7 years from the year of assessment (s. 56A(1)(a)), in Malay or English
(ruling, 4.1.5).

**`tax_point` is `invoice_date` — a convention, not a rule.** There is no
turnover tax whose point of chargeability the field could name.

**No mentions.** No text consulted requires a particular sentence on an
invoice; the ruling lists the particulars an invoice should carry (number,
date, names and addresses, description, quantity, price, total), which the
document already prints. If the customer pays in cash the ruling asks the
invoice to show the payment and its date; the format has no condition for that.

**No payment term, no late-payment interest** in the texts consulted.

## E-invoicing

`obligation: none`. No Peppol Authority is listed for Brunei Darussalam
(OpenPeppol, 10 October 2026) and no mandate was found; this is an absence in
the sources read, not proof.

## What this pack does not carry

The cash flow statement; any tax computation; customs and excise duty; XBRL
(`xbrl` is null); the Malay translation of the labels.

## Reviewing this pack

A Brunei accountant should confirm: that a software-generated number satisfies
the "printed" receipt duty; the Record Keeping (Business) Act obligations; the
current withholding tax rates and what s. 9(5) covers; that the 18.5 % rate and
the threshold are current; the BDAS statement lines; and whether any GST
project has been announced since 10 October 2026.
