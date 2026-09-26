# India

Everything India adds to Ekwo, as data: a chart of accounts, the journals, the
goods and services tax in its three layers — central, State or Union territory,
integrated — where each code posts, the boxes of FORM GSTR-3B, and a balance
sheet and a statement of profit and loss in the form of Schedule III to the
Companies Act, 2013. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from, which decisions it rests on, and what
the core could not be made to say, so that an Indian chartered accountant
reading the pack can disagree with a specific sentence rather than with the
whole of it.

**Status: `community`.** Nobody who files a GSTR-3B has reviewed it. The
figures are replayed against a year of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

## The one thing to understand before reading the taxes

A supply in India is taxed by two governments or by one, and which it is
depends on where the supplier is registered and where the place of supply
is. Section 8 of the Integrated Goods and Services Tax Act makes a supply
**intra-State** where the two are in the same State or Union territory: the
Centre levies the central tax (CGST) and the State the State tax (SGST) — the
Union territory tax (UTGST) in a Union territory without a legislature — each
at half the rate. Section 7 makes it **inter-State** where they are not, and
on imports and supplies outside India: the Centre alone levies the integrated
tax (IGST) at the whole rate.

The core takes one tax code per document line. So the pack does what the
Canadian pack does for GST and QST: **one code per rate and per layer,
carrying the whole rate, split at the posting.** `IN-S-18-INTRA` is a single
18 % code whose two `tax` postings are 50 % of the tax each — to Output CGST
and column 4 of line 3.1(a), to Output SGST/UTGST and column 5.
`IN-S-18-INTER` is one posting to Output IGST and column 3. The two halves
are exact halves in law as well as in the ledger: every Central Tax (Rate)
notification prints the integrated rate divided by two.

Which of the two a line may carry is not left to the bookkeeper's memory:
every intra-State code says `applies_when.supply_vs_seller: same` and every
inter-State code `other`, and `post_document()` refuses the wrong one. That
needs three facts the core already knows how to hold:

- **the company's territory is the State of its GSTIN** — `IN-KA` for a
  Karnataka registration (GSTIN prefix 29). Each GSTIN is a distinct person
  for GST (Explanation 1 to section 8), so a company registered in two States
  keeps two sets of books, one per registration;
- **each Indian customer and supplier has a territory**, its State;
- **the place of supply**, `supply_territory` on the document, where it is not
  the buyer's State — goods delivered to a third party's warehouse elsewhere,
  or a service whose place of supply section 12 of the IGST Act puts
  somewhere else.

Thirty-six rows were added to `territories` for it, one per State and Union
territory under ISO 3166-2:IN as revised in 2023. There are **not** thirty-six
sets of tax codes: the SGST code is the same code in every State, and what
changes from one State to the next is the account holder, not the rate.

## What is in it

| File | Holds |
|---|---|
| `accounts.csv` | 164 accounts, four digits, blocks cut to the lines of Schedule III |
| `taxes.json` | 41 codes: 6 rates × {sale, purchase} × {intra, inter}, blocked credit, zero-rated, nil, exempt, non-GST, reverse charge, import of goods and of services |
| `tax_report.json` | FORM GSTR-3B, tables 3.1, 4, 5 and 6.1 (tax payable), 34 boxes |
| `statements.json` | Schedule III, Division I: Balance Sheet (Part I) and Statement of Profit and Loss (Part II) |
| `golden/` | FY 2026-27 of a Karnataka company: 15 documents, 6 payments, 12 monthly returns |

## The rates, and where each comes from

The rate structure changed twice in the year before this pack was written,
and both changes are in it.

| Rate | CGST + SGST | In force | Source |
|---|---|---|---|
| 5 % | 2.5 + 2.5 | from 1 July 2017 | Schedule I, Notification No. 9/2025-Integrated Tax (Rate) |
| 12 % | 6 + 6 | 1 July 2017 – **21 September 2025** | Notification No. 1/2017, superseded by No. 9/2025, which has no 12 % schedule |
| 18 % | 9 + 9 | from 1 July 2017 | Schedule II, and the residual rate of entry 639 |
| 28 % | 14 + 14 | 1 July 2017 – **31 January 2026** | Schedule VII of No. 9/2025 kept it for pan masala and tobacco; they moved to 40 % on 1 February 2026 |
| 40 % | 20 + 20 | from **22 September 2025** | Schedule III of No. 9/2025 |
| 3 % | 1.5 + 1.5 | from 1 July 2017 | Schedule IV (gold, silver, jewellery) |

Notification No. 9/2025-Integrated Tax (Rate) of 17 September 2025, in force
from 22 September 2025, replaced the four-slab structure of 2017 (5, 12, 18,
28 %) by a merit rate of 5 %, a standard rate of 18 % and a demerit rate of
40 %. A new rate is a new code and a closed validity on the old one, never an
edit, so the 12 % and 28 % codes are in the pack with a `valid_to` and a
document dated before the change keeps its code. The rates of services are
in Notification No. 11/2017-Central Tax (Rate) as amended the same day; they
use the same codes, because a code here is a rate and a layer, not a
tariff heading.

**Not carried:** 0.25 % (rough diamonds, Schedule V) and 1.5 % (Schedule VI):
they apply to so few traders that a code nobody picks is a code somebody picks
by mistake. Each is one pair of codes to add. The 5 % rate "without input tax
credit" of some services (hotel accommodation, beauty services) is the 5 %
code; that the supplier may not take credit is a condition on the supplier's
purchases, not on this line.

**Compensation cess.** The GST (Compensation to States) Act, 2017 levied a
cess on top of GST on tobacco, pan masala, aerated drinks, coal and motor
vehicles. It was brought to nil on everything but tobacco and pan masala from
22 September 2025, and on those from 1 February 2026, when an additional
excise duty on tobacco and a Health and National Security Cess on pan masala
took its place. The chart keeps an input and an output cess account for the
books of earlier years; no code posts to them.

### Zero-rated, nil-rated, exempt, non-GST

Four different things in Indian law, four codes, four lines of GSTR-3B:

| Code | What | GSTR-3B |
|---|---|---|
| `IN-S-ZR-LUT` | export, or supply to an SEZ, under bond or Letter of Undertaking — IGST Act s. 16 | 3.1(b) |
| `IN-S-NIL` | goods or services taxed at nil by the rate notifications | 3.1(c) |
| `IN-S-EXEMPT` | exempt under s. 11 CGST Act (Notifications 2/2017 and 12/2017) | 3.1(c) |
| `IN-S-NONGST` | alcoholic liquor, the five petroleum products of s. 9(2) | 3.1(e) |

A zero-rated supply keeps the credit behind it (s. 16(2) IGST Act); a nil-rated
or exempt one loses the common credit attributable to it under s. 17(2) and
rules 42–43, which this pack does not compute (see below).

**Export on payment of IGST** — the other route of s. 16(3), where the
exporter charges integrated tax and claims it back — is not carried. It would
need an export code with a positive rate, and the invoice endorsement the rule
requires for it differs from the one for a supply under LUT; the core prints a
mention per treatment and cannot tell the two exports apart.

### Reverse charge

`IN-P-RCM-{5,18}-{INTRA,INTER}` for the supplies of s. 9(3) and 9(4) CGST Act —
goods transport agency (5 %), advocate's legal services, director's services,
security services and the rest of Notification 13/2017-Central Tax (Rate) —
and `IN-P-IMPORT-SERVICES-18` for a service from a supplier outside India
(s. 5(3) IGST Act, Notification 10/2017-Integrated Tax (Rate)). The recipient
books the tax twice: owed, on line 3.1(d), and credited, in Table 4(A)(3) or
4(A)(2). The supplier is paid the price alone. The reverse-charge tax is paid
in **cash** — s. 49(4) lets the credit ledger pay only output tax, and s.
2(82) keeps reverse-charge tax out of it — which is why the three RCM
accounts are kept apart from the three output accounts.

### Blocked credit

`IN-P-18-INTRA-BLOCKED` and `-INTER-BLOCKED` for the supplies of s. 17(5) —
passenger cars and their repair, food, catering, club memberships, works
contracts for immovable property, personal consumption. The tax is part of
the cost (`tax_on_base`), and since the change of Table 4 in 2022 it is still
shown in 4(A)(5) and reversed in 4(B)(1); a pair of `tax` postings on the
input account, in and straight back out, prints it in both rows and leaves
the account at zero.

### Imports of goods

`IN-P-IMPORT-GOODS-{5,18}`: the IGST is assessed on the bill of entry under s.
3(7) of the Customs Tariff Act and paid to customs, not to the seller. The tax
posts to Input IGST (Table 4(A)(1)) and to account 2270, which the customs
payment clears; the base on the line must be the value customs assessed the
tax on (assessable value plus basic customs duty), not the seller's price.
Basic customs duty itself is not a GST and has no code.

## The return: FORM GSTR-3B

Rule 61 of the CGST Rules: monthly, by the **20th** of the following month.
Under the Quarterly Return Monthly Payment scheme (proviso to s. 39(1);
aggregate turnover up to five crore rupees, opted into), quarterly, by the
**22nd or 24th** of the month after the quarter according to the State, with
the tax of the first two months paid in FORM GST PMT-06 by the 25th. The
pack declares `period: [month, quarter]`, proposes `month`, and gives the
monthly deadline — the quarterly one is a second deadline the format cannot
hold beside the first.

Boxes carried (ids are the table references without dots, because a box id
is alphanumeric):

| Box | GSTR-3B |
|---|---|
| `31a`, `31aIGST`, `31aCGST`, `31aSGST` | 3.1(a) outward taxable supplies — value, IGST, CGST, SGST/UTGST |
| `31b` | 3.1(b) zero-rated — value |
| `31c` | 3.1(c) nil-rated and exempted — value |
| `31d`, `31dIGST`, `31dCGST`, `31dSGST` | 3.1(d) inward supplies liable to reverse charge |
| `31e` | 3.1(e) non-GST outward supplies |
| `4A1IGST`, `4A2IGST`, `4A3*`, `4A5*` | 4(A) ITC available: import of goods, import of services, reverse charge, all other ITC |
| `4B1*` | 4(B)(1) ITC reversed — rules 38, 42, 43 and s. 17(5) |
| `4CIGST`, `4CCGST`, `4CSGST` | 4(C) net ITC, totals |
| `5EXINTER`, `5EXINTRA`, `5NGINTER`, `5NGINTRA` | 5 exempt, nil, composition and non-GST inward supplies |
| `61IGST`, `61CGST`, `61SGST` | 6.1 tax payable per head, totals |
| `NETDUE`, `NETCRED` | hidden: net of all heads, what the period settles to |

The settlement account is **2280 GST payable — electronic liability ledger**,
distinct from every posting account; a period that ends in credit goes to
**1650 GST — electronic credit and cash ledger balance**.

**Set-off is not computed.** Section 49(5) fixes the order in which credit of
each head pays each head: IGST credit first against IGST, then CGST and SGST;
CGST credit against CGST then IGST; SGST credit against SGST then IGST; never
CGST against SGST or the reverse; and reverse-charge tax only in cash. The
portal does that head by head in Table 6.1. `NETDUE`/`NETCRED` are the same
arithmetic without the order — all heads of 6.1 less all heads of 4(C). They
agree with the portal whenever no head is short; when one is, the portal asks
for cash on that head while credit is carried forward on another, and the
pack's figure understates the cash. That arithmetic is a formula of its own,
which the format has no word for (see `docs/international.md`).

**Not carried:** 3.1.1 (supplies through e-commerce operators under s. 9(5)),
3.2 (inter-State supplies to unregistered persons, by State — the core has no
box keyed by a territory), 4(A)(4) (Input Service Distributor), 4(B)(2) and
4(D), 5.1 (interest and late fee), 6.1 columns 3 to 10 (how each head was
paid), 6.2 (TDS/TCS credit), and the cess column everywhere.

**Not carried at all: FORM GSTR-1**, the statement of outward supplies invoice
by invoice (s. 37, rule 59), due on the 11th of the following month for a
monthly filer and the 13th for a quarterly one. It is a list of invoices by
GSTIN of the recipient, not a set of boxes. Nor FORM GSTR-9 (annual), GSTR-2B
(the auto-drafted statement of credit a recipient reconciles against), or the
composition returns CMP-08 and GSTR-4.

## Invoices

- **Numbering**: rule 46(b) — consecutive, up to sixteen characters, unique
  for a financial year. Declared `gapless`, `{CODE}-{NNNN}`, never restarting:
  the core's `_per_year` counters restart in January, and an Indian financial
  year starts on 1 April.
- **Tax point**: `invoice_date`, s. 12 and s. 13 CGST Act. The payment branch
  (advances for services) needs a prepayment document Ekwo does not have.
- **Posted documents**: `reversal_only` — credit and debit notes under s. 34,
  records kept 72 months under s. 36, and the non-disableable audit trail the
  Companies (Accounts) Rules require since 1 April 2023.
- **Mention**: the export endorsement of rule 46 for supplies under LUT. The
  other particulars of rule 46 — GSTIN, place of supply with State name and
  code, HSN or SAC code, the reverse-charge statement — are data of a party or
  a line, not sentences, and the core has no HSN field.
- **E-invoicing** (rule 48(4), Notification 10/2023-Central Tax): compulsory
  since 1 August 2023 for a person whose aggregate turnover exceeded five crore
  rupees in any financial year from 2017-18. The invoice is prepared with the
  particulars of FORM GST INV-01 and registered on the Invoice Registration
  Portal, which returns an IRN and a signed QR code; an invoice such a person
  issues otherwise "shall not be treated as an invoice" (rule 48(5)). Ekwo
  writes no INV-01 JSON and talks to no IRP, so `einvoicing` names no profile
  and no date, and the obligation is written in its `legal_reference`. The
  e-way bill for goods moved above ₹50,000 is outside the pack for the same
  reason.

## The chart, and the statements

There is no legal chart of accounts in India. The chart is original, in the
ledger-and-group style Indian bookkeeping software shares, and each block of
four-digit codes lands on exactly one line of Schedule III:

| Codes | Schedule III line |
|---|---|
| 1000–1099 | PPE — tangible assets (cost and accumulated depreciation) |
| 1100–1149 · 1150–1179 · 1180–1199 | Intangible assets · Capital WIP · Intangibles under development |
| 1200–1249 · 1250–1269 · 1270–1299 · 1300–1399 | Non-current investments · DTA · Long-term loans and advances · Other non-current assets |
| 1400 · 1450 · 1500 · 1550 · 1600 · 1700 blocks | Current investments · Inventories · Trade receivables · Cash · Short-term loans and advances (input GST here) · Other current assets |
| 2000–2099 · 2100–2199 · 2200–2399 · 2400–2499 | Trade payables · Short-term borrowings · Other current liabilities (output and RCM GST here) · Short-term provisions |
| 2500–2799 | Non-current liabilities, four lines |
| 3000–3499 | Share capital · Reserves and surplus · Share warrants · Share application money |
| 4000–4499 · 4500–4999 | Revenue from operations · Other income |
| 5000–5699 · 6000–6999 | Materials · Stock-in-trade · Changes in inventories · Employee benefits · Finance costs · D&A · Other expenses |
| 7000 · 7100 · 8000–8099 | Exceptional · Extraordinary · Current and deferred tax |

Labels are English: Schedule III and the GST forms are printed in English for
a company, and no official chart exists in Hindi to transcribe, so the pack
declares no second language.

The statements are **Division I** — a company applying the Accounting
Standards under the Companies (Accounting Standards) Rules, 2006. Division II
(Ind AS, for listed companies and those above the Ind AS thresholds) is not
carried; nor are the Notes, the comparatives, the Statement of Changes in
Equity, the cash flow statement, or lines XII–XVI of the Statement of Profit
and Loss (discontinuing operations, earnings per share). The financial year
is April to March (`fiscal_year_default: april`), s. 2(41) of the Companies
Act.

## What this pack cannot say

- **TDS and TCS under GST** (s. 51 and s. 52 CGST Act) and **under the
  Income-tax Act** (TDS on payments to contractors and professionals, TCS on
  sales): the core has no withholding on a payment. Accounts 1630, 1640,
  2300, 2305 and 2310 exist for the manual entries.
- **Rules 42 and 43**: the reversal of common credit in proportion to exempt
  turnover is a proportion recomputed every period, which no box can state.
- **Rule 37 and s. 16(2)(aa)**: credit taken only if the supplier has
  reported the invoice (GSTR-2B), and reversed if the supplier is not paid
  within 180 days. The ledger does not know what the supplier filed.
- **The composition levy** (s. 10): a composition taxpayer charges no tax,
  pays a percentage of turnover and files CMP-08 and GSTR-4. Not carried.
- **Two forms, one cadence each**: QRMP's quarterly deadline and GSTR-1's
  11th/13th, beside GSTR-3B's 20th.
- **E-invoicing and e-way bills**: clearance through a government portal.
- **Place-of-supply rules** themselves (ss. 10–13 IGST Act): the pack
  refuses a code that contradicts the place of supply recorded on the
  document; it does not work out the place of supply.

## Reviewing this pack

Every tax and every box cites its section, rule or table, and the register in
`pack.json` gives where each text is read — the CBIC Tax Information Portal
for the Acts and Rules, the CBIC compilation of FORM GSTR-3B, Notification
No. 9/2025-Integrated Tax (Rate) for the rates, the GST Council for the
e-invoicing notification, the ICAI's reproduction of Schedule III. The golden
year is small enough to check by hand: its April return is 150,000.00 of
taxable value, 9,000.00 in each of the three tax columns, 8,200.00 of credit,
18,800.00 to pay.

What a chartered accountant should read first:

1. whether the SGST code being the same code in every State, with the State
   carried by the company's territory, is how an Indian practice keeps books;
2. the 4(A)/4(B) treatment of blocked credit under the current Table 4;
3. the import-of-goods posting through a customs clearing account;
4. whether 5 % and 18 % are enough reverse-charge rates, and whether the
   0.25 % and 1.5 % rates are worth carrying;
5. the Schedule III mapping of the GST balances: input GST under
   short-term loans and advances, output and RCM GST under other current
   liabilities.
