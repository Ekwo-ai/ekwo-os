# Bangladesh

Everything Bangladesh adds to Ekwo, as data: a chart of accounts, the journals,
value added tax (VAT) at 15 % with the truncated rates of the Third Schedule,
supplementary duty (SD) stacked under the VAT, zero rate and exemption, the
Mushak 9.1 return, and the statement of financial position and the statement
of profit or loss of the IFRS. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content comes
from and which decisions it rests on.

**Status: `community`.** Nobody who files a Bangladeshi VAT return has reviewed
it. `tests/golden.test.ts` replays a quarter of books, which proves the pack is
coherent, not that it is right.

**Law of 1 July 2026 only.** Every tax and the return are `valid_from`
2026-07-01, the day the Finance Act, 2026 (Act No. 96 of 2026, gazetted on
30 June 2026) came into force. The rates are those of the Authentic English
Text of the Value Added Tax and Supplementary Duty Act, 2012 published on
5 November 2025, which already carries the Finance Ordinance, 2025. Earlier
periods are not posted, apart from the closed rate codes listed below.

**English, with a Bengali working translation.** The Act has an Authentic
English Text and the Mushak forms are published in English and in Bengali.
`i18n/bn.json` translates every label and is listed in `languages`; it is the
pack's own working translation, not an official text; see `i18n/README.md`.

What the core cannot say yet is in
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

## Sources

Every tax, box and statement line carries its own `legal_reference` and the
key of the text it is in. The register in `pack.json` holds ten texts:

| What | Text | Where |
|---|---|---|
| Rate, zero rate, exemption, input tax, withholding, supplementary duty, return, Schedules | The Value Added Tax and Supplementary Duty Act, 2012, Authentic English Text (S.R.O. No. 440-Law/2025/326-Mushak of 5 November 2025) | `bdlaws.minlaw.gov.bd` |
| The reform of 1 July 2026 | The Finance Act, 2026 (Act No. 96 of 2026) | `nbr.gov.bd` (Bengali only) |
| What the Finance Act, 2026 changed in VAT | PwC, *Finance Act, 2026: Key Amendments* | `pwc.com` |
| The draft ordinance of 28 September 2026 | Press report of the Cabinet approval | `vatupdate.com` |
| The boxes of the return | IVAS user guide for Form Mushak-9.1 (114 pages) | `vat.gov.bd` |
| Where the return is filed | eVAT Services | `vat.gov.bd` |
| VAT withheld at source, construction at 10 % | ICAB summary of the VDS Guidelines, 2025 | `icab.org.bd` |
| Books of account | The Companies Act, 1994, s. 181 | `basis.org.bd` (copy) |
| IFRS in Bangladesh | IFRS Foundation jurisdiction profile | `ifrs.org` |

Section 64 and the other VAT amendments of the Finance Act, 2026 rest on PwC's
summary of the Act as enacted; the Bengali statute itself should be checked.
The boxes follow the notes of the portal's user guide for Mushak 9.1.

## The return, and the quarterly rule

**The rule retained: quarterly.** Section 64(1), as substituted by the Finance
Act, 2026 with effect from 1 July 2026, has every registered or enlisted person
file the return **within 15 days of the end of every three tax periods**; a tax
period stays one calendar month. Filing for each month remains allowed, due by
the last day of the following month (PwC). Government, semi-government and
autonomous bodies, banks, insurers and filers of a nil return have 20 days. The
Finance Bill's monthly advance of one third of the previous quarter's tax was
not enacted: the payment falls due with the return (s. 45(2)). The return is
filed on the eVAT portal. The report declares `period: ["quarter", "month"]`,
`period_default: "quarter"`, and a deadline of the 15th of the month after the
period; the monthly option's later deadline is left to the company's calendar.

**The draft ordinance.** On 28 September 2026 the Cabinet approved, subject to
vetting by the Legislative and Parliamentary Affairs Division, a draft *Value
Added Tax and Supplementary Duty (Amendment) Ordinance, 2026* that would amend
section 64 to restore the return for **each tax period** within 15 days (20 days
for the bodies above and for nil returns), the 15th rolling to the next working
day if it is a holiday. Until it is gazetted, the rule in force is modelled. If
it is, the change is one line of `tax_report.json` (`period_default` back to
`month`); the boxes, the deadline day and every tax stay as they are.

**Mushak 9.1 and 9.1.1.** Manufacturers, service providers and traders who
take input tax credit file Mushak 9.1; every other registered person (a trader
without credit, a commercial importer supplying under final settlement, a
trader paying VAT on actual value addition) files **Mushak 9.1.1**, which
allows no credit. The pack carries 9.1 only. A turnover-tax enlistee pays 4 %
of turnover (s. 63; the sector amounts the Finance Act, 2026 allows are not
yet notified) and files Mushak 9.2; neither is carried.

**The boxes** are the notes of the portal's form. A note with three columns
puts the value (a), the supplementary duty (b) and the VAT (c) of a supply on
one line, so the box of a column is the note number plus a letter: `4a`, `4b`,
`4c`. Carried: notes 1 to 4, 7 and 8 and their total 9 on the supply side;
10, 12, 14 to 16, 19 and 20 and their total 23 on the input side; adjustments
27 and 31; and the results 34 (net VAT), 36 (net SD) and 65 (credit carried
forward). Two things are the pack's own: box `9i`, the VAT on imported
services that the form adds into note 9(c) from the sub-form of note 15, and
the reading that a credit note issued goes to note 31 (VAT) and note 39 (SD)
and leaves note 4 showing the original supply, as the portal's guide
describes them. Not carried: notes 5 and 6 (goods on the maximum retail price,
specific VAT), 11, 13, 17, 18, 21, 22, 24 to 26, 29, 30, 32, 38, 40, the
payment parts 8 and 9 (notes 41 to 64) and the Mushak 18.6 account balance.

## Supplementary duty, stacked under the VAT

SD is charged once, on the supply, at the rate of the Second Schedule (s. 55);
the VAT is then charged on the value **including** the duty (s. 15(3), s. 32,
s. 57(b)). A sale of 2,000 at SD 5 % therefore carries SD 100 and VAT 15 % of
2,100 = 315. On the buyer's side the duty is **not creditable** (s. 46(1)(k)):
the VAT is, the duty is a cost.

**One tax code at the total rate, two `tax` postings with a `factor` each.**
For a duty of *s* % the total is *s* + 15 × (1 + *s*/100) per cent of the value
before duty:

| Code | SD | Total rate | SD share | VAT share |
|---|---|---|---|---|
| `BD-S-15-SD5` | 5 % | 20.75 % | 24.096 % | 75.904 % |
| `BD-S-15-SD10` | 10 % | 26.5 % | 37.736 % | 62.264 % |
| `BD-S-15-SD30` | 30 % | 49.5 % | 60.606 % | 39.394 % |

The SD goes to account 2101 and box `4b`; the VAT to 2100 and `4c`. Purchases
(`BD-P-15-SD5`, `-SD10`, `-SD30`) put the duty share on the account of the
line (`tax_on_base`, no box) and the VAT share on 1150 and `14b`. The Second
Schedule lists many more rates; any rate is one more code built the same way.

**The limit of the model.** The two shares do not terminate, a posting factor
holds three decimals, and the engine rounds the total tax once and gives the
last posting the remainder. On the golden values the result is exact; on a
large invoice the duty can differ from *s* % of the value by a few paisa
(1 taka = 100 paisa), the VAT taking the difference. A core that taxed one line
with several taxes, each on its own base, would remove it.

## Rates

| Code | Rate | What |
|---|---|---|
| `BD-S-15` / `BD-P-15` | 15 % | standard rate (s. 15(3)); online sales since 1 July 2025 |
| `BD-S-15-SDn` / `BD-P-15-SDn` | 20.75 / 26.5 / 49.5 % | SD at 5, 10, 30 % with the VAT on top |
| `BD-S-5` / `BD-P-5` | 5 % | Third Schedule, Table 1 |
| `BD-S-7.5` / `BD-P-7.5` | 7.5 % | Table 2; also a trader's purchase |
| `BD-S-10` / `BD-P-10` | 10 % | Table 3 — construction since 1 July 2025 |
| `BD-S-5-ADV-DIGITAL` | 5 % | digital advertising from 1 July 2026 (15 % before) |
| `BD-S-TRADE-7.5` / `-3` / `-2` / `-1.5` | 7.5 / 3 / 2 / 1.5 % | trader at the local trading stage; medicine; petroleum; certain wholesale (paragraphs (3) and (4)) |
| `BD-S-ZR-EXP`, `BD-S-ZR-DEEMED`, `BD-P-ZR` | 0 % | zero rate (ss. 21–24) |
| `BD-S-EX`, `BD-P-EX` | 0 % | exempt, First Schedule |
| `BD-P-IMP-15` | 15 % | import, VAT paid to Customs |
| `BD-P-RC-15` | 15 % | imported service, reverse charge (s. 20) |
| `BD-P-NC-TURNOVER`, `BD-P-NC-UNREG` | — | no credit: turnover-tax supplier, unregistered supplier |

**Closed codes, dated.** `BD-S-7.5-CONSTR` and `BD-P-7.5-CONSTR` (construction
at 7.5 %) and `BD-S-5-ONLINE` (sales of goods online at 5 %) end on
30 June 2025. They open on 1 July 2019, the date the Finance Act, 2019
substituted the three schedules; the registers hold no earlier proof of the
start. Digital advertising before 1 July 2026 is covered by `BD-S-15`. The
Finance Ordinance, 2025 also took from the National Board of Revenue the power
to exempt by special order.

**Not carried as codes:** land developers (2 %) and real estate (2 % and
4.5 % by size, paragraph (3)), the specific amounts of Table 4 (including
jewellers' VAT per *bhori* from the Finance Act, 2026), goods taxed on the
maximum retail price, and the 2.4 % medicine trading rate that the Value Added
Tax and Supplementary Duty (Amendment) Ordinance, 2025 replaced by 3 %.

## What this pack does not do

- **VAT withheld at source (VDS, s. 49).** The withholding entity deducts the
  VAT at payment and reports it as an increasing adjustment (note 24); the
  supplier claims the certificate as a decreasing adjustment (note 29) in the
  period of payment or the next six (s. 50). Not a tax on a document: accounts
  1152 and 2130 book it by hand, notes 24 and 29 are entered on the portal.
- **Electronic fiscal devices** (EFD, SDC), being rolled out to some twenty
  sectors, report sales from the till; Ekwo does not connect to one.
  `einvoicing` says `obligation: none`: no statute obliges two businesses to
  exchange a structured invoice, and there is no Peppol authority.
- **Advance tax (AT) at import** (note 30, s. 48) and the 7.5 % advance tax of
  a commercial importer: entered by hand as a decreasing adjustment; account
  1151 holds it.
- **The Mushak 18.6 account and the payment parts** (notes 41 to 64: interest,
  fines, treasury challans): the portal computes them.
- **Turnover tax, Mushak 9.2**, and **Mushak 9.1.1**: see above.
- **Debit notes** (notes 26 and 38), the **tax invoice** (Mushak 6.3) and its
  numbering, the **time of supply** beyond the nearest vocabulary value (s. 33(1)
  is the earliest of supply, invoice, receipt of the consideration and own use;
  the vocabulary has a two-way earliest-of).
- **Exempt and mixed businesses**: no apportionment; box 23b is the sum of the
  input VAT posted.

## The chart of accounts, and why this one

**Bangladesh prescribes no chart of accounts.** The Companies Act, 1994 (s. 181)
asks for proper books that give a true and fair view; the Financial Reporting
Act, 2015 set up the Financial Reporting Council, which adopted the IFRS
Accounting Standards without modification in November 2020 for public interest
entities, and the IFRS for SMEs for those that are not publicly traded. The
chart is written, not transcribed: four digits, 1 assets, 2 liabilities,
3 equity, 4 income, 5 cost of sales, 6 to 8 expenses, each range reaching one
line of the statements. What makes it Bangladeshi: output VAT (2100),
supplementary duty payable (2101) and the VAT on imported services (2102)
apart; input VAT (1150), advance tax at import (1151) and withholding
certificates (1152) apart; one settlement account on each side (2110 payable,
1155 refundable), the only ones with the customers and suppliers that are
reconcilable; the VAT, SD and duties owed to Customs (2125); VAT withheld at
source (2130); turnover tax; provident fund; workers' profit participation and
welfare funds. The fiscal year default is July, as the government's financial
year and the Finance Act follow.

## The statements

The statement of financial position and the statement of profit or loss,
expenses by nature, with the minimum line items of the IFRS for SMEs,
sections 4 and 5; a full-IFRS entity expands them under IAS 1. No Bangladeshi
text prescribes the layout.

## What is in it

| File | Holds |
|---|---|
| `pack.json` | the register of sources, the roles, the journals, the chart, the numbering and time-of-supply rules, the e-invoicing statement |
| `accounts.csv` | 154 accounts in four digits |
| `taxes.json` | 31 codes: 17 on sales, 14 on purchases |
| `tax_report.json` | form Mushak 9.1: 34 boxes |
| `statements.json` | statement of financial position, statement of profit or loss |
| `i18n/bn.json` | every label in Bengali |
| `golden/` | a quarter of books of a Dhaka company, 19 documents and 4 payments |

## The golden scenario

July to September 2026, 19 documents, every figure worked out by hand: a
standard sale (100,000 → VAT 15,000); one sale each at SD 5, 10 and 30 % where
the VAT stands on the value plus the duty (2,000 → 100 + 315; 5,000 → 500 +
825; 2,000 → 600 + 390); a construction service at 10 %, a trader's sale at
7.5 %, an export at zero rate and an exempt sale of books; two credit notes
(the VAT to note 31 and the duty to note 39); purchases at 15 %, with SD (the
duty a cost, 400 on 4,000, the VAT 660 on 4,400), from a trader, at an
import (9,000 paid to Customs), a reverse-charged imported service (6,000 both
ways), an exempt, a zero-rated and an unregistered-supplier purchase; and a
supplier credit note (note 27). The quarter comes to **33,530** of output VAT
(9c), **26,160** of input VAT (23b), adjustments of 300 and 1,582.50, **6,087.50**
of net VAT (34) and **1,150** of net SD (36).

## To be read by a Bangladeshi accountant

1. **The periodicity.** That section 64 as enacted reads as PwC summarises it
   (a return every three tax periods, the monthly return optional, payment with
   the return), and whether the ordinance approved on 28 September 2026 has
   been gazetted since.
2. **Digital advertising at 5 %**: the effective date, the service code and
   whether it applies from 1 July 2026 to all digital media.
3. **The credit note treatment** (VAT to note 31, SD to note 39, note 4 left as
   filed) and the supplier credit note on note 27.
4. **Whether note 14(a) includes the supplementary duty** on a purchase.
5. **The closing dates** of the 7.5 % construction and 5 % online codes, and
   the 2019 opening date, which is the pack's own.
6. **The time of supply** (s. 33(1)) against `earliest_of_delivery_or_payment`.
7. **The chart and the statements** against what a Bangladeshi company files
   with the Registrar of Joint Stock Companies.
