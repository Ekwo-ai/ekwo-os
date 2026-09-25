# Canada

Everything Canada adds to Ekwo, as data: a chart of accounts, the journals,
the goods and services tax and the harmonized, provincial and Québec taxes
that stack on it, where each code posts, the federal GST/HST return and its
boxes, and a balance sheet and an income statement in the shape Part II of the
CPA Canada Handbook asks for. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from, which decisions it rests on, and what the core could not be made to say,
so that a Canadian accountant reading the pack can disagree with a specific
sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a GST34 has reviewed it. The figures
are replayed against a year of books by `tests/golden.test.ts`, which proves
the pack is coherent and proves nothing about whether it is right.

## The one thing to understand before reading the taxes

Canada is the country this repository's `defaults.region` column was written
for, and it is the country whose tax the core cannot yet carry whole. Two
administrations levy on the same sale in Québec, and two more — British
Columbia, Saskatchewan, Manitoba — levy a retail sales tax of their own beside
the federal one. The core takes **one tax code per document line**: a `group`
of two taxes is reserved and refused by the compiler.

So the pack does what Canadian bookkeeping has settled on, and for the same
reason: **one code per province, carrying the combined rate, split at the
posting.** `CA-QC-S-14975` is a single 14.975 % code whose two `tax` postings
are 5/14.975 of the tax to the GST/HST account and to line 103 of the federal
return, and 9.975/14.975 to the QST account and to no box. Revenu Québec
publishes the same arithmetic in the same order — 9.975 % where a cash
register works the two taxes out in two steps, 14.975 % where it works them
out in one — so the combined code is the administration's own reading and not
a convenience of this pack.

The split is expressible because a tax may carry several `tax` postings with
different `factor`s, and because `box_factor` is independent of `factor`: line
103 gets 33.389 % of the tax and the ledger gets the same share on its own
account. What is *not* expressible is a second declaration form, and that is
the gap this pack cannot close — see "What this pack cannot say".

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
is not participating may levy a sales tax of its own under its own statute,
and four of them do.

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

Nova Scotia is the rate to watch: its provincial part fell from 10 points to 9
on 1 April 2025, and a pack or a piece of software still charging 15 % there
is a year out of date. The Canada Revenue Agency states the change in as many
words on its *Which GST/HST rate to charge* page, and publishes the whole
table on the rates page beside the calculator. Schedule VIII of the Act still
prints 8 % against every participating province, which is why this pack cites
the definition of *tax rate* — paragraph (a), the prescribed rate — and the
CRA's published table, and not the Schedule.

**Which province a supply is made in** is decided by Schedule IX and by the
New Harmonized Value-added Tax System Regulations, and never by where the
invoice was addressed. Every standard-rate code of this pack says so with
`applies_when.supply_in`, and `post_document()` refuses a code whose province
is not the one the document resolves to. Thirteen rows were added to
[`supabase/seed/00_territories.sql`](../../supabase/seed/00_territories.sql)
for that — one per province and territory — plus Canada itself, which is
outside the common system of VAT and needed a row for the reason
`docs/packs.md` gives at step 0.

### Recoverable, and not

The federal tax and the provincial part of the HST are recoverable in full:
subsection 169(1) gives a registrant an input tax credit for the tax that
becomes payable on what it acquires for its commercial activities, and it
makes no distinction between the two parts. The Québec sales tax is
recoverable too, from the other administration: section 199 of the Act
respecting the Québec sales tax gives an input tax refund on the same footing.

The three retail sales taxes are **not**. Neither the Excise Tax Act nor the
provincial statute gives a purchaser any credit for them, which is the whole
difference between a retail sales tax and a value added tax. So the purchase
codes of British Columbia, Saskatchewan and Manitoba split: the federal share
is a `tax` posting to the recoverable account and to line 106, and the
provincial share is a **`tax_on_base`** posting, which carries no account of
its own and lands on the accounts of the lines it taxes. A press bought in
Saskatchewan for $3,000 is capitalised at $3,180, which is what `golden/`
books and what the trial balance shows on account 1430.

### Zero-rated, exempt, and outside

Three different things, and the pack keeps them apart because the return does.

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

**No exemption reason code anywhere in this pack.** BT-121 of EN 16931 comes
from the VATEX list, whose codes name articles of Directive 2006/112/EC, and
Canada is outside the common system of VAT — `territories` says so and
`ekwo pack check` enforces it. The article each line is exempt or zero-rated
under is in `legal_reference` instead, which is what an invoice states here.

Three codes say in `conditions` which question the books do not answer: the
proof of export the supplier has to hold under Schedule VI, Part V, section
1(e) (`transport_evidence`), whether the customer is a non-resident
(`buyer_status`), and whether what was sold is a basic grocery or a bag of
chips (`supply_nature`). The word is the question and never the answer.

## The return

Form **GST34**, code `CA-GST34`, eighteen boxes, transcribed from the *GST/HST
Return Working Copy* — the sheet the CRA publishes with the arithmetic printed
beside each total, which is where `plus` and `minus` come from. Line 101 is
total sales and other revenue and every sale of this pack posts its base
there, taxed or not; line 103 is the tax collected and line 106 the input tax
credits; 109 is the net tax of subsection 225(1) written out; 405 is where a
self-assessment under section 218 lands; 114 and 115 are one figure and a
sign, so the pack states them as line 113 C subtracted and added, each floored
at zero.

`golden/expectations.json` holds the nine arithmetic claims of that sheet, and
`tests/tax_report.test.ts` compares them with the pack, which catches a typo
on either side that no golden figure would.

**Cadence.** Paragraph 245(2)(c) of the Act makes the reporting period *the
fiscal quarter of the registrant* in every case the two paragraphs before it
do not catch, and those two are the exceptions — the fiscal month above a
$6,000,000 threshold amount or on an election under section 246, the fiscal
year on an election under section 248 or for a charity or a listed financial
institution. So the form is filed on three cadences and the statute still
gives one of them to everybody who has asked for nothing: `period_default` is
`quarter`. The CRA describes the same thing administratively by turnover —
annual under $1.5 million, quarterly to $6 million, monthly above — and a
company that has decided otherwise says so through `company_filing_periods`,
not through the pack.

**Deadline.** Paragraph 238(1)(b): within one month after the end of the
reporting period, which is `last_day_of_month_after_period`, and paragraph
228(2)(b) makes the remittance due the same day.

**Filed on a portal.** No brick of this repository writes a GST34 file, so the
pack names no `file_format`. Since reporting periods beginning on or after
1 January 2024, every registrant other than a charity or a selected listed
financial institution **has to** file electronically — through GST/HST NETFILE
or through the CRA account — and a paper return draws a penalty.

## Invoices

Canada prescribes no invoice number. What the law asks of a document is
section 3 of the Input Tax Credit Information (GST/HST) Regulations, and it is
a list of facts and not a sequence: under $100 the supplier's name, the date
and the total; from $100 the supplier's registration number and the tax; from
$500 the recipient's name, the terms of payment and a description of each
supply. (Those two thresholds were $30 and $150 until 2024, c. 15, s. 141
raised them; a reader working from an older guide will find the old figures.)
So `numbering` is `free`, and `{CODE}-{NNNN}` is a convention this pack
proposes rather than a form anybody prescribes.

`legal_payment_days` is left out on purpose: no Canadian statute sets a
default term between businesses. The federal Prompt Payment for Construction
Work Act reaches federal construction contracts and nobody else, and the
provincial construction Acts reach construction. Writing 30 there would be a
custom presented as a rule.

**The tax point is the invoice**, and this is the one country page where that
is the principle and not a derogation. Subsection 168(1) makes the tax payable
on the earlier of the day the consideration is paid and the day it becomes
due, and subsection 152(1) makes it become due on the earliest of the day the
supplier first issues an invoice, the date of that invoice, the day they would
have issued it but for undue delay, and the day the recipient is required to
pay under a written agreement. Delivery is only the backstop: subsection
168(3) reaches the case where nothing has been paid or become due by the last
day of the month following the month of delivery.

**No electronic invoicing obligation**, federal or provincial, and no date
announced for one. Section 2 of the Input Tax Credit Information Regulations
has counted "any record contained in a computerized or electronic retrieval or
data storage system" as supporting documentation since 1991, so an electronic
invoice has been good enough for thirty-five years and compulsory never. What
*is* compulsory is filing the return electronically, and the two are not the
same thing. A supplier to the federal government invoices through the
CanadaBuys procurement system, which is procurement policy and binds nobody
else. `party_scheme` and `vat_scheme` are empty: nothing prescribes which of a
Canadian party's registration identifiers — the business number, the RT
account, the QST number — it would be addressed by on a network no statute
names.

## The chart, and the statements

There is no legal chart of accounts in Canada and no statute prescribes one.
What is prescribed is the standard: section 71 of the Canada Business
Corporations Regulations, 2001 requires annual financial statements to be
prepared in accordance with Canadian GAAP, and section 70 defines that as the
CPA Canada Handbook – Accounting, whose Part II holds the accounting standards
for private enterprises (ASPE).

So the chart is **original**. It follows the four-digit, five-block convention
Canadian bookkeeping software shares — 1000 assets, 2000 liabilities, 3000
equity, 4000 revenue, 5000 and above expenses — and every block of codes is
cut so that it reaches exactly one line of the two statements.

**The labels are English.** There is no official Canadian chart of accounts in
either official language to transcribe, so neither language could be called
the original. English is the pack's own language and the French of a Québec
set of books is in `i18n/fr.json`, complete: 162 accounts, 37 taxes, 18 boxes,
37 statement lines.

The statements are the **short form** ASPE asks for — Section 1521 for the
balance sheet, Section 1520 for the income statement, Section 1510 for the
current split, Section 3251 for equity. The Handbook is not free to read, so
the lines are the presentation those sections require and the names are
ordinary Canadian usage; `legal_reference` names the section on every line
that has one to name. A reviewer with the Handbook open is the most useful
first pass on this file.

Two accounts are the settlement of the return and nothing else: **2250**,
GST/HST payable to the Receiver General, and **1340**, the refund claimed from
it when a period ends in a credit. Both are `reconcilable`, both are apart
from the accounts the taxes post to, and nothing else in the chart is
reconcilable except accounts receivable and accounts payable.

## What this pack cannot say

Every one of these is a limit of the core and not of Canadian law, and each is
written up again in
[`docs/international.md`](../../docs/international.md) under "From Canada".

**One declaration form per pack, and Canada files two.** A registrant in
Québec files form **FPZ-500** with Revenu Québec for the same period as the
GST34 — the QST it collected, the input tax refunds it claims, and the federal
figures again, because Revenu Québec administers the GST in Québec. The pack
format reads `tax_report.json` as one object and `readPack` keeps one
`report`, so the pack carries GST34 and the QST reaches no box: the postings
of `CA-QC-S-14975` and `CA-QC-P-14975` put the provincial tax on accounts 2210
and 1335, and a Québec company reads those two accounts to fill FPZ-500 by
hand. The same is true of the three retail sales taxes: British Columbia,
Saskatchewan and Manitoba each take a return of their own, and accounts 2220,
2225 and 2230 are what a bookkeeper reads to file them. `docs/decisions.md`
already reserves the machinery — a `report` field exists on a posting for the
day a pack may declare two forms — and this is the country that needs it.

**`settle_filing()` sweeps every tax account, not the ones the form reaches.**
`filing_tax_movements()` selects the entry lines flagged `tax_line` over the
period, whatever box they carry, so settling a GST34 clears the QST accounts,
the three provincial accounts and the customs account into 2250, which is owed
to the Receiver General and to nobody else. For a company outside Québec,
British Columbia, Saskatchewan and Manitoba the answer is right; for one
inside them it moves a debt to the wrong administration. Until the settlement
reads the form's own boxes, a Québec company should not call `settle_filing()`
— the return itself, `vat_return()`, is correct either way, because the boxes
are what the postings name.

**Line 101 is filed in whole dollars and the rest in cents.** The working copy
prints a fixed `00` in the cents column of line 101 and nowhere else.
`tax_report.json` carries one `rounding` for the whole form, so the pack files
every box at the cent and a filer rounds line 101 themselves.

**One deadline per form, and Canada has four.** `last_day_of_month_after_period`
is paragraph 238(1)(b), which is the rule for a monthly and a quarterly filer.
An annual filer has three months under subparagraph 238(1)(a)(iii), six under
subparagraph (i) if they are a listed financial institution, and an individual
with business income and a 31 December year end files by 15 June under
subparagraph (ii) while still remitting by 30 April under paragraph 228(2)(a).
None of the three is expressible beside the first.

**No province on a company, and no rule that suggests a tax.**
`companies.region` and `contacts.region` exist and nothing reads them;
`defaults.region` is left null here, because no province is the lawful default
for a Canadian company and proposing one would be choosing a tax rate for
somebody the pack knows nothing about. Picking `CA-BC-S-12` rather than
`CA-ON-S-13` is a human decision in this pack, and `post_document()` refuses
the wrong one through `applies_when` rather than choosing the right one.

**No real-property self-assessment.** Line 205 is declared and no code posts
to it: subsection 221(2) relieves the supplier of a taxable supply of real
property to a registrant and section 228(4) makes the recipient account for
it, and Ekwo has no real-property purchase document to hang that on.

**No Quick Method, no simplified input tax credits, no public service body
rebate.** Each of the three is a different way of computing the net tax or the
credits from the same books, and each turns on a fact about the filer that the
pack cannot know. A company on the Quick Method reports GST-inclusive figures
on line 101 and applies a remittance rate, which the pack has no way to state.

**No provincial sales tax registration threshold, and no small-supplier
threshold.** Section 148 relieves a person whose taxable supplies stay under
$30,000 from registering, and each province sets its own. Whether a company is
registered is a fact about the company, and the core keeps no such column.

## Reviewing this pack

The most useful first passes, in order:

1. **The chart against ASPE.** The Handbook is not free to read and this pack
   could not quote it. Somebody with Part II open should read `statements.json`
   line by line.
2. **The split factors.** 33.389/66.611 for Québec, 41.667/58.333 for British
   Columbia and Manitoba, 45.455/54.545 for Saskatchewan. They are exact to
   the third decimal the column allows, and the last posting of each side
   takes the remainder, so the federal share is right to the cent on the
   figures in `golden/`. A reviewer should check the rounding on an awkward
   base — $33.33 in Québec — against what their own software produces.
3. **The Québec side.** `revenuquebec.ca` and `legisquebec.gouv.qc.ca` both
   refuse a request with no browser behind them — a plain 403 and a 502 — so
   the two Québec legal sources in the register carry their correct, current
   URLs and their content was read through search results and through the
   federal sources that restate it, not off the page itself. The 9.975 % of
   section 16, the input tax refund of section 199, the 14.975 % single rate
   and form FPZ-500 are all stated in the register on that footing.
   `docs/packs.md` records the same limit for Légifrance, and
   `ekwo pack check --links` will name both.
4. **Nova Scotia at 14 %.** If it is not 14 % where you file, one of us is out
   of date, and it matters more than anything else on this page.
