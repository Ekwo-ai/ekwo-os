# Canada

Everything Canada adds to Ekwo, as data: a chart of accounts, the journals,
the GST and the harmonized, provincial and Québec taxes that stack on it, the
federal GST/HST return, and a balance sheet and an income statement in the
shape Part II of the CPA Canada Handbook asks for. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from, which decisions it rests on, and what the core cannot say.

**Status: `community`.** Nobody who files a GST34 has reviewed it. The figures
are replayed against a year of books by `tests/golden.test.ts`, which proves
the pack is coherent and proves nothing about whether it is right.

## The one thing to understand before reading the taxes

The core cannot yet carry Canada's tax whole. Two administrations levy on the
same sale in Québec, and British Columbia, Saskatchewan and Manitoba levy a
retail sales tax of their own beside the federal one. The core takes **one
tax code per document line**: a `group` of two taxes is reserved and refused
by the compiler.

So the pack uses **one code per province, carrying the combined rate, split
at the posting.** `CA-QC-S-14975` is a single 14.975 % code whose two `tax`
postings are 5/14.975 of the tax to the GST/HST account and to line 103 of
the federal return, and 9.975/14.975 to the QST account and to no box (Revenu
Québec publishes the same 14.975 % single-step arithmetic). `box_factor` is
independent of `factor`, so line 103 gets 33.389 % of the tax. A second
declaration form is *not* expressible — see "What this pack cannot say".

## What is in it

| File | Holds |
|---|---|
| `accounts.csv` | 162 accounts, four digits, five blocks |
| `taxes.json` | 37 codes: thirteen on sales, thirteen on purchases, six zero-rated, exempt or out of scope, an import, a self-assessment |
| `tax_report.json` | form GST34, eighteen boxes |
| `statements.json` | balance sheet and income statement, ASPE short form |
| `golden/` | a year of an Ontario company, sixteen documents, seven payments, four quarters filed |
| `i18n/fr.json` | the whole pack in French |

## The rates, and where each comes from

Subsection 165(1) of the Excise Tax Act imposes 5 % on every taxable supply
made in Canada. Subsection 165(2) adds, on a supply made in a **participating
province**, tax at that province's rate — the definition of *tax rate* in
subsection 123(1) taking the rate prescribed for the province. A province that
is not participating may levy a sales tax of its own, and four of them do.

| Where the supply is made | Rate | What it is made of |
|---|---|---|
| Alberta, Northwest Territories, Nunavut, Yukon | 5 % | GST alone |
| Ontario | 13 % | HST — 5 federal, 8 provincial |
| Nova Scotia | 14 % | HST — 5 federal, 9 provincial, **since 1 April 2025** |
| New Brunswick, Newfoundland and Labrador, Prince Edward Island | 15 % | HST — 5 federal, 10 provincial |
| Québec | 14.975 % | GST 5 % + QST 9.975 %, side by side, neither in the other's base |
| British Columbia | 12 % | GST 5 % + PST 7 % |
| Saskatchewan | 11 % | GST 5 % + PST 6 % |
| Manitoba | 12 % | GST 5 % + RST 7 % |

Nova Scotia's provincial part fell from 10 points to 9 on 1 April 2025, as
the CRA's *Which GST/HST rate to charge* page states. Schedule VIII of the Act
still prints 8 % against every participating province, so the pack cites the
definition of *tax rate* — paragraph (a), the prescribed rate — and the CRA's
rate table, not the Schedule.

**Which province a supply is made in** is decided by Schedule IX and by the
New Harmonized Value-added Tax System Regulations, never by where the invoice
was addressed. Every standard-rate code says so with `applies_when.supply_in`,
and `post_document()` refuses a code whose province is not the one the
document resolves to. Each province and territory, and Canada itself (outside
the common system of VAT, for the reason `docs/packs.md` gives at step 0), has
a row in [`supabase/seed/00_territories.sql`](../../supabase/seed/00_territories.sql).

### Recoverable, and not

The GST and both parts of the HST are recoverable in full as an input tax
credit (subsection 169(1)); the QST through an input tax refund (section 199
of the Act respecting the Québec sales tax). The three retail sales taxes are
**not**: the purchase codes of British Columbia, Saskatchewan and Manitoba
post the federal share as `tax` to the recoverable account and line 106, and
the provincial share as **`tax_on_base`**, onto the accounts of the lines it
taxes. A press bought in Saskatchewan for $3,000 is capitalised at $3,180 on
account 1430 in `golden/`.

### Zero-rated, exempt, and outside

- **Zero-rated** — subsection 165(3): the rate is 0 % and the seller keeps
  every input tax credit behind the supply. Schedule VI, Part V, section 1 for
  goods the recipient exports, section 7 for a service supplied to a
  non-resident, and Part III, section 1 for basic groceries, which excludes
  alcohol, carbonated drinks, candy, chips, salted nuts and the rest.
- **Exempt** — Schedule V: no tax, and no credit on what was bought to make
  the supply. Part VII, section 1 for financial services; Part I, section 6
  for a residential lease of at least one month.
- **Outside the scope** — subsection 165(1) taxes a supply *made in Canada*,
  and section 142 says where a supply is made. A supply section 142 places
  outside Canada is not zero-rated and not exempt; nothing applies to it.

**No exemption reason code**: the VATEX list (BT-121 of EN 16931) names
articles of Directive 2006/112/EC; the article is in `legal_reference`.

Three codes name in `conditions` what the books do not answer: proof of
export under Schedule VI, Part V, section 1(e) (`transport_evidence`), a
non-resident customer (`buyer_status`), a basic grocery or not
(`supply_nature`).

## The return

Form **GST34**, code `CA-GST34`, eighteen boxes, transcribed from the *GST/HST
Return Working Copy*, which prints the arithmetic beside each total (hence
`plus` and `minus`). Line 101 is total sales and other revenue and every sale
posts its base there, taxed or not; line 103 is the tax collected and line 106
the input tax credits; 109 is the net tax of subsection 225(1); 405 is where a
self-assessment under section 218 lands; 114 and 115 are line 113 C
subtracted and added, each floored at zero. `golden/expectations.json` holds
the nine arithmetic claims of that sheet, checked by `tests/tax_report.test.ts`.

**Cadence.** Paragraph 245(2)(c) makes the reporting period *the fiscal
quarter of the registrant* unless an exception applies — the fiscal month
above a $6,000,000 threshold amount or on an election under section 246, the
fiscal year on an election under section 248 or for a charity or a listed
financial institution — so `period_default` is `quarter` (CRA by turnover:
annual under $1.5 million, quarterly to $6 million, monthly above). Other
cadences go in `company_filing_periods`.

**Deadline.** Paragraph 238(1)(b): within one month after the end of the
reporting period, which is `last_day_of_month_after_period`; paragraph
228(2)(b) makes the remittance due the same day.

**Filed on a portal.** No brick writes a GST34 file, so the pack names no
`file_format`. For reporting periods beginning on or after 1 January 2024,
every registrant other than a charity or a selected listed financial
institution **has to** file electronically — GST/HST NETFILE or the CRA
account — and a paper return draws a penalty.

## Invoices

Canada prescribes no invoice number. Section 3 of the Input Tax Credit
Information (GST/HST) Regulations asks for a list of facts, not a sequence:
under $100 the supplier's name, the date and the total; from $100 the
supplier's registration number and the tax; from $500 the recipient's name,
the terms of payment and a description of each supply. (Those thresholds were
$30 and $150 until 2024, c. 15, s. 141 raised them.) So `numbering` is `free`,
and `{CODE}-{NNNN}` is a convention, not a prescribed form.

`legal_payment_days` is left out: no Canadian statute sets a default term
between businesses. The federal Prompt Payment for Construction Work Act and
the provincial construction Acts reach construction only.

**The tax point is the invoice.** Subsection 168(1) makes the tax payable on
the earlier of payment and the day consideration becomes due; subsection
152(1) makes it due on the earliest of the first invoice, the invoice date,
the day it would have been issued but for undue delay, and the day payment is
required under a written agreement. Subsection 168(3) is the backstop: the
last day of the month following delivery.

**No electronic invoicing obligation**, federal or provincial, and no date
announced for one; section 2 of the Input Tax Credit Information Regulations
has accepted "any record contained in a computerized or electronic retrieval
or data storage system" since 1991. CanadaBuys, for suppliers to the federal
government, is procurement policy only. `party_scheme` and `vat_scheme` are
empty: nothing prescribes which identifier (business number, RT account, QST
number) a party is addressed by.

## The chart, and the statements

No statute prescribes a chart of accounts. What is prescribed is the standard:
section 71 of the Canada Business Corporations Regulations, 2001 requires
annual financial statements prepared in accordance with Canadian GAAP, and
section 70 defines that as the CPA Canada Handbook – Accounting, whose Part II
holds the accounting standards for private enterprises (ASPE).

So the chart is **original**: the common four-digit, five-block convention —
1000 assets, 2000 liabilities, 3000 equity, 4000 revenue, 5000 and above
expenses — with every block cut to reach exactly one line of the two
statements. **The labels are English**, there being no official chart in
either language; the French of a Québec set of books is in `i18n/fr.json`,
complete: 162 accounts, 37 taxes, 18 boxes, 37 statement lines.

The statements are the ASPE **short form** — Section 1521 for the balance
sheet, Section 1520 for the income statement, Section 1510 for the current
split, Section 3251 for equity. The Handbook is not freely available, so the
lines follow what those sections require and the names are ordinary Canadian
usage; `legal_reference` names the section on every line that has one.

**2250** (GST/HST payable to the Receiver General) and **1340** (refund
claimed) settle the return and nothing else; with accounts receivable and
payable they are the only `reconcilable` accounts.

## What this pack cannot say

Each of these is a limit of the core, not of Canadian law (see
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet)).

**One declaration form per pack, and Canada files two.** A Québec registrant
also files form **FPZ-500** with Revenu Québec (QST, input tax refunds, and
the federal figures again). The pack carries one `report`, the GST34, so the
QST reaches no box: accounts 2210 and 1335 are read to fill FPZ-500 by hand.
Likewise the British Columbia, Saskatchewan and Manitoba returns are filed
from accounts 2220, 2225 and 2230. `docs/decisions.md` reserves a `report`
field on a posting for two forms.

**`settle_filing()` sweeps every tax account, not the ones the form reaches.**
`filing_tax_movements()` takes every `tax_line` of the period, so settling a
GST34 clears the QST, the three provincial accounts and the customs account
into 2250, owed to the Receiver General alone — wrong in Québec, British
Columbia, Saskatchewan and Manitoba. A company there should not call
`settle_filing()`; `vat_return()` is correct either way.

**Line 101 is filed in whole dollars and the rest in cents.** `tax_report.json`
carries one `rounding`, so a filer rounds line 101 themselves.

**One deadline per form, and Canada has four.** `last_day_of_month_after_period`
is paragraph 238(1)(b), for monthly and quarterly filers. An annual filer has
three months under subparagraph 238(1)(a)(iii), six under subparagraph (i) if
a listed financial institution, and an individual with business income and a
31 December year end files by 15 June under subparagraph (ii) while remitting
by 30 April under paragraph 228(2)(a). Only the first is expressible.

**No province on a company.** `defaults.region` is null: no province is the
lawful default. Picking `CA-BC-S-12` rather than `CA-ON-S-13` is a human
decision; `post_document()` refuses the wrong one through `applies_when`.

**No real-property self-assessment.** Line 205 is declared and no code posts
to it (subsection 221(2), section 228(4)): Ekwo has no real-property purchase
document.

**No Quick Method, no simplified input tax credits, no public service body
rebate**: each turns on a fact about the filer the pack cannot know.

**No small-supplier or provincial registration threshold** (section 148:
$30,000; each province its own): the core keeps no registration column.

## Reviewing this pack

The most useful first passes, in order:

1. **The chart against ASPE.** Somebody with Part II of the Handbook open
   should read `statements.json` line by line.
2. **The split factors.** 33.389/66.611 for Québec, 41.667/58.333 for British
   Columbia and Manitoba, 45.455/54.545 for Saskatchewan. They are exact to
   the third decimal the column allows, and the last posting of each side
   takes the remainder, so the federal share is right to the cent on the
   figures in `golden/`. Check the rounding on an awkward base — $33.33 in
   Québec — against your own software.
3. **The Québec side.** The 9.975 % of section 16, the input tax refund of
   section 199, the 14.975 % single rate and form FPZ-500 rest on secondary
   and federal sources that restate them; they should be checked against
   `revenuquebec.ca` and `legisquebec.gouv.qc.ca`.
4. **Nova Scotia at 14 %.** If it is not 14 % where you file, one of us is out
   of date, and it matters more than anything else on this page.
