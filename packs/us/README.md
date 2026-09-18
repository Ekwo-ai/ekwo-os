# United States

Everything the United States adds to Ekwo, as data: a chart of accounts, the
journals, the sales and use taxes of three states and where each one posts, the
thirty-nine lines of one state's return, the balance sheet and the income
statement of Regulation S-X, the usual lives of a fixed asset, and what the law
of this country says an invoice must carry, which is nothing. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that an American accountant reading
the pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files an American return has reviewed it
against the law they apply. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**This is the first pack of a country with no value added tax**, and that is
most of what is interesting about it. The United Kingdom was the first pack
outside the European Union and still levied a VAT: a tax the buyer reclaims, on
a national form, under a national law. Here there is none of that. The tax is
levied by the states and by thousands of districts under them, the buyer never
gets a cent of it back, there is no national return and no legal chart of
accounts. What the core could not say precisely is written up in
[`docs/international.md`](../../docs/international.md) under "From the United
States". None of it was patched for this pack's sake: a gap the core has
is a core issue, and patching the core for one country is what the pack format
exists not to do.

## Sources

Every rate, box, statement line, document rule and asset category carries its
own `legal_reference`, and beside it the key of the text that article is in. The
register in `pack.json` holds twenty texts and every one of them was opened on
16 September 2026. The ones the rest of this file leans on:

| What | Text | Where |
|---|---|---|
| The form and order of the statements | Regulation S-X, 17 CFR part 210, rules 4-01, 5-02 and 5-03 | `ecfr.gov/current/title-17/part-210` |
| The accounting behind them | FASB Accounting Standards Codification | `asc.fasb.org` |
| What a tax year may be | Tax years, and Publication 538 | `irs.gov` |
| What MACRS is, and is not | Publication 946 | `irs.gov` |
| The California sales tax, the use tax, the exemptions and the return | Revenue and Taxation Code, division 2, part 1 | `leginfo.legislature.ca.gov` |
| What the 7.25 per cent is made of | Detailed Description of the Sales & Use Tax Rate, CDTFA | `cdtfa.ca.gov/taxes-and-fees/sut-rates-description.htm` |
| Which amount goes on which line | CDTFA-401-A and CDTFA-401-INST | `cdtfa.ca.gov/formspubs` |
| Every district and its rate | CDTFA-531-A2, Schedule A2 | `cdtfa.ca.gov/formspubs/cdtfa531a2.pdf` |
| The resale certificate | Regulation 1668, Sales for Resale | `cdtfa.ca.gov/lawguides/vol1/sutr/1668.html` |
| Economic nexus | South Dakota v. Wayfair, and CDTFA's guide to it | `supremecourt.gov`, `cdtfa.ca.gov/industry/wayfair.htm` |
| New York's combined rate, and its filing cadence | Tax Bulletins ST-825 and ST-275, Publication 718 | `tax.ny.gov` |
| A state with no sales tax | Sales tax in Oregon, Oregon Department of Revenue | `oregon.gov/dor` |
| Electronic invoicing | Digital Business Networks Alliance | `dbnalliance.org` |

One thing a reviewer should know about the register. The Codification at
`asc.fasb.org` serves its landing page to anybody and its content behind a free
registration, so what was read there is the identity of the text and not its
paragraphs. Every accounting rule this pack states is stated a second time by a
text that is open — Regulation S-X for the presentation, Publication 946 for
what the tax computation is — and where the two do not overlap the pack says
that the duration or the method is common practice rather than law.

## The chart of accounts, and why this one

**The United States prescribes no chart of accounts**, and no statute
prescribes the form of the accounts of a company that does not file with the
Securities and Exchange Commission. Nothing here could be transcribed from a
statute the way the Luxembourg chart was, and nothing could be mapped onto a
statutory format the way the British one was.

What does exist, and what this chart is laid out on, is **Regulation S-X**.
Rule 5-02 names the captions of a balance sheet and fixes their order; rule 5-03
does the same for the income statement; rule 4-01(a)(1) says financial
statements not prepared in accordance with generally accepted accounting
principles are presumed misleading. That is the form an American commercial
balance sheet takes whether or not the company is a registrant, and it is the
only published, openable text that says what the lines are.

The chart follows it:

- **Four digits, eight classes.** `1` assets, `2` liabilities, `3` equity,
  `4` revenue, `5` cost of sales, `6` operating expenses, `7` non-operating
  income and expense, `8` income taxes and the items below net income. It is
  the shape of an American general ledger.
- **Flat.** No parent accounts. Every account is a leaf and the grouping is
  done by the `code_range` rules of `statements.json`, each block cut so that
  it reaches exactly one caption of rule 5-02 or rule 5-03.
- **Cost and accumulated depreciation are far apart, not adjacent.** Rule 5-02
  gives accumulated depreciation a caption of its own — caption 14 for property
  and caption 16 for intangibles — so the pack keeps them in their own blocks
  and the statement prints the two lines the rule prints. That is the opposite
  of what the British pack does, and it is the rule's doing rather than a
  preference.

234 accounts, all of them postable.

**Two things to look at twice.** There is **no input tax account anywhere in
this chart**, and that is the whole difference between a sales tax and a value
added tax: a purchaser in the United States takes no credit for the tax charged
to them, so there is nothing to put on the asset side facing `2200` to `2206`.
And the sales tax a seller has collected sits on **four** accounts, one per
share the California return prints on a line of its own — state, county, local
and district. A company that sells in one state with no district tax uses one of
the four; the golden year uses all four.

## Taxes

Eleven codes: six on the sale side in California, one in New York, one in
Oregon, and three on the purchase side. Three states, chosen for what each one
shows and not for its size.

| Code | Rate | What it shows |
|---|---|---|
| `US-CA-S-725` | 7.25 % | the statewide base rate, split over three accounts of the chart |
| `US-CA-S-1075` | 10.75 % | the same sale where a district adds 3.50 %, which is the one share the form does not multiply out itself |
| `US-CA-S-RESALE` | 0 % | an exemption that turns on a certificate the buyer signed |
| `US-CA-S-FOOD` | 0 % | an exemption that turns on what was sold |
| `US-CA-S-GOV` | 0 % | an exemption that turns on who bought |
| `US-CA-S-SHIPPED` | 0 % | an exemption that turns on where the goods went |
| `US-NY-S-8875` | 8.875 % | a second state, whose return this pack does not carry |
| `US-OR-S-0` | 0 % | a state that levies no sales tax at all |
| `US-CA-P-725` | 7.25 % | the buyer's side: the tax is a cost and never a claim |
| `US-CA-P-USE-725` | 7.25 % | the buyer assesses the tax themselves, and it is still a cost |

**Every code says where it applies**, since 16 September 2026, and a bookkeeper
can no longer reach the wrong state's. `applies_when` on a tax names one
territory per party: `US-CA-S-725` wants a Californian seller and a Californian
delivery, `US-NY-S-8875` wants a delivery to New York, `US-OR-S-0` a delivery to
Oregon, and the two purchase codes want a Californian buyer. `post_document()`
refuses a document that contradicts one of them, by name, before anything
reaches the ledger — so the Californian rate on goods shipped to New York is now
an error and not a quiet 7.25 per cent on the wrong return. Where each party is
comes from `companies.territory_code`, `contacts.territory_code` and
`documents.supply_territory_code`, and the golden year sets all three.

Two codes deliberately say less than they could. `US-CA-S-SHIPPED` names the
seller and says nothing about where the goods went, because `applies_when` can
say that a party is in a place and not that a party is **not** in one — the
exemption is for a sale shipped *out of* California and the negation has no
word. `US-P-0` names nothing at all: it is the code for a purchase no state
taxes, and constraining it would refuse the out-of-state service it exists for.
Both are in [`docs/international.md`](../../docs/international.md).
| `US-P-0` | 0 % | the ordinary untaxed purchase, which no return hears about |

**`recoverable: false` on every one of them, and it is not decoration.** A
purchaser in the United States has no input tax credit: the Sales and Use Tax
Law contains no deduction of a tax paid against a tax collected, because the tax
is imposed once, on the retail sale, and not at each stage. So a purchase tax is
booked by a `tax_on_base` posting at the full amount, which lands it on the
accounts of the lines it taxes. In the golden year a 5,000.00 instrument bought
from an out-of-state seller is capitalised at 5,362.50, and 8,000.00 of stock
bought locally costs 8,580.00. That posting type was added for a Belgian car at
50 % and a French fuel bill at 80 %; this is the country it was described for,
and it is the first pack where it is the ordinary case rather than the exception.

**Use tax is the buyer charging themselves, and it is not a reverse charge.**
Section 6201 taxes the storage, use or consumption in California of property
bought from a retailer, and section 6202 makes the buyer liable for it until
somebody has paid it to the State. Where an out-of-state seller collected
nothing, the buyer declares it on line 2 of their own return. The pack says
`self_assessed` — a tax a buyer owes directly to an administration under that
administration's own law, and computes and declares themselves. It said
`domestic_reverse_charge` on the day it landed, because that was the only word
the vocabulary had for a liability sitting with the buyer, and the README had
to say in as many words that it was not article 196 of Directive 2006/112/EC.
The word arrived on 16 September 2026 and the pack no longer denies another
mechanism in order to describe its own: there is still no supplier exemption
behind it, no recapitulative statement, and nothing recovered at the other end,
and now the treatment says so rather than the prose.

**Three rates and no rate engine.** California has one statewide rate and, on
top of it, district taxes that CDTFA-531-A2 lists county by county and city by
city, at rates from 0.10 to 2.00 per cent, with effective and sunset dates that
move every quarter. This pack carries the statewide 7.25 per cent and **one**
district combination as a worked example — the City of Oakland, 3.50 per cent
under reporting code D10 effective 1 October 2025, which makes 10.75 per cent.
It carries no others and it never will: choosing between them is a question
about a delivery address, which is a feed and not a pack, and
`docs/international.md` has always said so.

**Two exemptions the pack states and cannot check — and now says so.** A sale
for resale is untaxed because the buyer gave the seller a resale certificate —
section 6091 presumes every receipt taxable until they do — and a seller has to
collect in a state where they have economic nexus, which since *South Dakota v.
Wayfair* is a threshold of sales into that state and not a warehouse in it.
California's is 500,000 dollars of sales in the preceding or current calendar
year. Both are facts about a document in a drawer and about a running total
across a year, and the pack carries the code a bookkeeper reaches for once the
answer is known. Since 16 September 2026 it also carries **which question** the
code answers, in `conditions`: `buyer_certificate` on `US-CA-S-RESALE`,
`seller_threshold` on `US-NY-S-8875`, and three more where the answer is
likewise not in the books — `supply_nature` on the food exemption, whose
carve-outs for hot, carbonated and alcoholic items no ledger holds,
`buyer_status` on the sale to the United States, and `transport_evidence` on the
sale shipped out of state. Five words and not one figure: there is no threshold
amount and no certificate number anywhere in this pack, because a field that
could carry the test would be a pack that executes. What is still nowhere is the
evidence itself — no place on a contact for a certificate and its validity, no
place anywhere for a rolling total per territory — and that stays on the list in
`docs/international.md`.

**The EN 16931 categories are the part of this pack that means least, and they
are now this pack's own choice.** The standard is European and the invoice of an
American company is governed by no standard at all. On the day the pack landed,
`ekwo pack check` required a category on every tax that could reach a sale: the
reason codes were already gone — that was the British fix and it works here —
but the category stayed, which was a European standard asking an American pack a
question nobody would read the answer to. Since 16 September 2026 the
requirement follows the invoice: it holds inside the common system, and outside
it where the pack declares an `einvoicing.profile` whose invoices carry BT-151.
This pack declares none, so the column is free.

It is still filled. `S` on a taxed sale, `E` on an exempt one and `O` on a sale
into Oregon are true statements about the operation — `S`, `E` and `O` come from
UNCL5305, a UN/CEFACT list, and a sale is taxed, or exempt, or outside the
scope, in California as in Belgium — and nothing is ever deleted from a pack.
What is free is not what is unchecked: a category this pack names is still held
to its treatment, its reason and its rate. What has changed is that these three
values are here because the pack means them, and no longer because a standard
the United States is not in demanded them.

## The return

There is **no national sales tax return**. A company that sells into several
states files one return per state, to that state's administration, on that
state's form and on that state's cadence. `tax_report.json` is California's:
**CDTFA-401-A, State, Local, and District Sales and Use Tax Return**, revision
1-26, thirty-nine boxes. New York's ST-100 and every other state's form are
absent, and the pack has no way to carry two.

Four things about it are worth knowing before reading the file.

**Lines 13, 14 and 15 are a rate of line 12, and line 16 is not.** The form
says: multiply line 12 by 0.06 for the state tax, by 0.0025 for the county tax,
by 0.01 for the local tax, and carry the district schedule's total to line 16.
The first three are said the way the form says them — `"rate": 6.0, "rate_of":
"12"` — which is a percentage and the box it applies to, and is still two named
fields and no expression. The fourth is not a rate of anything: a district tax
is owed on the sales made in that district and not on the period's whole taxable
total, so line 16 stays summed from the ledger, out of the `tax` posting the one
district code makes to it.

Until this pack's second version all four were summed from the ledger, out of
one posting per line whose share of the combined rate was that line's rate. The
two answers agreed to the cent in all three quarters of the golden year, and
they were never guaranteed to: the form multiplies a period's taxable total
once, the apportionment shared a tax that had been rounded document by document.
The form's own arithmetic is what the pack now carries, and the golden year did
not move by a cent when it changed. What the postings still do is split the
liability across the state, county and local accounts of the chart, which is a
question about the ledger and not about the return.

**Every sale is on line 1, and an untaxed sale is on line 1 twice.** Line 1 is
total sales, taxable and not; the deductions come afterwards, in Section A. So a
sale for resale posts its base to line 1 *and* to box 32, an exempt food sale to
line 1 and box 33, a federal sale to line 1 and box 35, and an interstate sale
to line 1 and box 36 — one `base` posting naming two boxes, neither of them a
sum of the other, which is the mechanism Estonia and the United Kingdom asked
for and which four American codes now use at once.

**The form prints line 11 on page 1 and computes it on page 3.** Line 11 is the
total of Sections A and B, which are printed two pages later. Every box of this
form therefore carries a `print_sequence` — where CDTFA prints it — beside the
`sequence` this pack declares it in, which is still the dependency order the
form was first transcribed in. Neither of them is the order the boxes are worked
out in: that is the boxes each one names, and it always was. `sequence` meaning
both at once was the Luxembourg gap, met for the third time here, and it is
closed.

**Boxes nothing posts to are declared all the same.** Line 18, excess tax
collected, is a figure a person establishes. Lines 20a to 20d are credits that
come off schedules this pack does not carry — and 20a in particular is Sections
C and D, the partial exemptions, a base multiplied by 0.05 or by 0.039375. That
shape is sayable now; what is missing is the eight deduction lines those sections
carry and the taxes that would reach them, which is a pack gap and no longer a
format one.
Lines 22, 24 and 25 are prepayments, penalty and interest, which are not ledger
figures. Line 34, nontaxable labor, line 37, sales tax included in line 1, line
38, other deductions, and the four lines of Section B are transactions this
pack's codes do not produce. A return with twenty-five boxes would not be
CDTFA-401-A, so they are declared and empty.

**The cadence.** Section 6452(a) makes the return quarterly for everybody, and
section 6455(a) lets the Department require another period, which is how a
monthly or an annual filer arrives. So California's law gives one default and
the form is filed on three cadences — the British case exactly, in another
language. The form says so itself: `period_default` is `quarter`, which is the
field a proposal belongs on now that a company records a cadence per
declaration rather than one named after the return. A company that has asked
CDTFA for nothing files quarterly, and `ekwo init` proposes that.

## The accounts

`statements.json` carries the balance sheet of rule 5-02 and the income
statement of rule 5-03, caption by caption, with the rule's own numbering as the
line codes and the rule's own wording as the names.

Three decisions a reviewer should weigh.

**Captions 15 to 17 of the income statement are reserved in the rule itself**
and are absent here for that reason, the way the British format's items 15 to 18
are. Captions 19, 20, 23, 24 and 25 — the noncontrolling-interest allocations
and the earnings per share — are not sums of ledger accounts and the pack does
not state them. Captions 27 and 31 of the balance sheet, redeemable preferred
stock and noncontrolling interests, are declared with an account each so that a
chart that needs them has somewhere to post.

**Accumulated depreciation is a line, not a deduction.** Rule 5-02 gives it
caption 14, so the statement prints property at cost on caption 13 and the
accumulated depreciation below it, negative, and total assets adds the two. A
reader who expects a net book value on one line is reading a different
presentation from the one the rule prescribes.

**Other comprehensive income is a caption this pack cannot fill honestly.**
Caption 21 of rule 5-03 is there and two accounts reach it, but
`close_fiscal_year()` closes every income account to retained earnings, and
generally accepted accounting principles close those two to accumulated other
comprehensive income instead. The gap is on the list; until it is closed, a
company with foreign currency translation adjustments should not use `8400` and
`8410`.

**No fact keys.** A registrant files in Inline XBRL against the taxonomy the
Financial Accounting Standards Board publishes, and nothing here was verified
against it, so `xbrl` and `taxonomy` are null on both statements. A wrong key is
worse than no key.

## Closing the year

`closing_style` is `retained_earnings`: net income goes straight into `3400
Retained earnings`. There is no current-year result account on an American
balance sheet — rule 5-02 has captions 27 to 31 under equity and not one of them
is "result of the year" — so the manifest names no `current_year_result_profit`
and no `current_year_result_loss`, which is what that style is for. It is the
same answer as the United Kingdom's and for the same structural reason, and it
is the opposite of France's, where 120 and 129 hold the result until a meeting
allocates it.

A dividend is not part of a close in any country: `3410 Dividends declared` sits
beside the reserve and is booked by hand.

**No tax provision is booked by the close either.** Federal and state income tax
are an expense of captions 11 and a liability of caption 20, and they are a
computation nobody can derive from the ledger — the difference between book
income and taxable income is the whole of American tax accounting. The chart
carries `8000` to `8030` and `2230` and `2235` so that it can be booked, and the
pack computes nothing.

## Fixed assets

`assets.json` is the part of this pack that is most plainly **practice rather
than law**, and it is worth saying why in one sentence: the United States has
two depreciation systems and they have nothing to do with each other.

The accounting one is the Codification, topic 360, which asks an entity to
allocate the depreciable amount over the useful life it estimates for its own
asset and prescribes no method and no table. The tax one is the Modified
Accelerated Cost Recovery System of Publication 946, with recovery periods of
three, five, seven, ten, fifteen, twenty, twenty-seven and a half and thirty-nine
years, a half-year convention, a mid-quarter convention, a mid-month convention
for real property, and a switch from double declining balance to the straight
line. **This section is the first and never the second**, and every category
says so in its own `legal_reference`. An American company that keeps books and
files a return keeps two figures for every asset it owns, and the module carries
one.

Disposal is `net_result`: topic 360 recognises the difference between the net
proceeds and the carrying amount in income as one figure, and rule 5-03 has no
caption for the two halves.

## On the invoice

**The United States requires nothing on an invoice.** No federal statute
prescribes a sentence, a number, a payment term or a delay, and California's
Sales and Use Tax Law prescribes none either. So `documents.mentions` is absent
— not empty for want of research, absent because there is nothing to print — and
`document_legal_mentions` returns nothing for an American invoice, which is
correct. Every pack before this one carried between one and six sentences that
an article of law requires; this one carries none, and that is the sharpest
contrast in the file.

**Numbering is `free`.** Regulation 14(1)(a) of the British VAT Regulations
requires a sequential number; article 5 of the Belgian royal decree number 1
requires a gapless one per year; the United States requires no number at all.
`{CODE}-{NNNN}` is a convention this pack proposes so that a renderer has
something to follow, and a company may do anything else.

**There is no legal payment term, and the Prompt Payment Act is not one.**
`legal_payment_days` is absent and so is `documents.references.payment_terms`,
because there is no article to cite: business-to-business payment terms in the
United States are what the contract says. The Prompt Payment Act binds **federal
agencies** paying their own contractors and says nothing about two companies
trading with each other, and extending it to a country default would be
inventing a rule. `late_payment_reference` is absent for the same reason:
interest on a late commercial debt is a matter of contract and of state law, and
there is no national rate.

**The tax point is the transaction and not the invoice.** Section 6051 taxes the
retail sale and section 6201 the use of the property, so `tax_point` is
`delivery_date`. There is no invoice-date derogation of the kind the European
VAT directives grant, and a company that invoices a month after delivery still
reports the sale in the quarter of the delivery.

**`documents.references` carries two entries and not three.** Numbering and the
tax point are answered; payment terms are not declared, so they cite nothing.
That is what "fill in what exists and leave empty what does not" looks like in
this format, and a reader who asks this pack for a payment term is told the
value is missing rather than given Belgium's thirty days.

**Electronic invoicing is not obligatory and there is no national profile.**
Nothing in American law compels anybody to issue or receive one, and no date has
been set. The Digital Business Networks Alliance runs an open exchange network
for business documents that its members join voluntarily, and naming it as this
country's profile would report an industry initiative as a legal requirement. So
`profile` and `mandatory_from` are both empty, and the reason is in the legal
reference. `party_scheme` and `vat_scheme` are empty too: there is no VAT
identifier in a country with no VAT, and nothing prescribes which registration
identifier an American party is addressed by.

## The fiscal year

An American tax year is the calendar year, **or** a fiscal year ending on the
last day of any month except December, **or** a 52-53-week year that varies
between 52 and 53 weeks and need not end on the last day of a month at all. The
Internal Revenue Service publishes all three, and the last is what most American
retail keeps.

The golden scenario is a 52-week year, 28 June 2026 to 26 June 2027, which is
364 days ending on the last Saturday of June. It works: `fiscal_years` has taken
arbitrary bounds since the schema was written. What does not work is
`defaults.fiscal_year_default`, whose vocabulary is `calendar`, `april`, `july`
and `october` — four opening months, where the law allows twelve and then allows
a year that does not begin on the first of a month at all. The pack declares
`calendar`, which is the ordinary American corporate answer, and the gap is on
the list.

The scenario also shows what falls out of it: California's reporting period is
the calendar quarter, so a 52-week year contains **three** whole quarters and two
stubs. The opening stub carries one sale on purpose, so that the golden holds a
document that is in both statements and in no return it files.

## What this pack does not carry

- **Forty-seven other states.** Forty-five states and the District of Columbia
  levy a sales tax; this pack carries two of them and one that does not. The
  other forty-five are not a gap in the pack, they are the next forty-five packs
  — or, more honestly, the thing that says an American localisation is a
  different shape of problem from a European one.
- **Any other state's return.** New York's ST-100 is named in the register and
  is not modelled; the New York tax posts to the ledger and to no box. It now
  says which state it belongs to and is refused on a Californian delivery, which
  is half the answer — the other half is a pack carrying a list of forms with a
  territory on each, and a pack carries one form.
- **District rates by address.** One worked combination, and the rest is a feed.
- **Local sales taxes below the state that are not California districts** —
  Alaska's boroughs, Colorado's home-rule cities, Louisiana's parishes, each
  administering its own tax and collecting it itself.
- **Streamlined Sales and Use Tax Agreement** membership, its simplified return
  and its certified service providers.
- **Federal and state income tax**, the Form 1120 series, the schedules that
  reconcile book income to taxable income, and MACRS.
- **Sales tax on services**, which a growing number of states levy and
  California does not.
- **Marketplace facilitator rules**, which move the duty to collect from the
  seller to the platform.
- **Inline XBRL for the Securities and Exchange Commission**, and the
  Regulation S-X articles other than article 5 — a bank reports on article 9 and
  an insurance company on article 7.

## Reviewing this pack

Open an issue titled "Review: United States". What a review is, and what it is
not, is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who
may say what".

Eight points a reviewer holding a CPA licence should look at first, roughly in
the order the author is least sure of them:

1. **Lines 13 to 16, and what they are each a rate of.** The pack states lines
   13, 14 and 15 as 6.00, 0.25 and 1.00 per cent of line 12, as the instructions
   do, and leaves line 16 summed from the district postings because a district
   tax is not owed on the period's whole taxable total. A reviewer who files
   CDTFA-401-A will know whether line 17 then still ties to the sales tax payable
   account of the ledger, which apportions the same tax document by document —
   the form is filed in whole dollars, which may be the whole answer.
2. **Whether `quarter` is the right proposal.** Section 6452(a) reads as a
   default given to everybody and section 6455(a) as the Department's power to
   direct otherwise, which is what `period_default` states. A reviewer who reads
   the monthly regime as the rule for anyone above a threshold would want the
   field empty and `ekwo init` to ask, which is the Luxembourg answer.
3. **Whether use tax belongs on the same four accounts as sales tax.** The
   pack posts both to `2200` to `2204`, because the return combines them on
   lines 13 to 15 and the liability is to one administration. A practice that
   keeps a separate use tax accrual would want a fifth account and five
   postings.
4. **Whether a credit note belongs in Section B.** The pack reverses the boxes
   the invoice filled. The form has line 3 of Section B, returned taxable
   merchandise, which is a deduction in the period of the return rather than a
   reversal. For a sale and a return in the same quarter the two give the same
   figure; across a quarter boundary they do not, and the golden year crosses
   one on purpose.
5. **Where each account reaches on the balance sheet.** Every account reaches a
   line — `ekwo pack check` refuses a chart where one reaches none — and only
   the suspense account reaches two. *Which* caption is a judgement, especially
   for the sales tax accounts, for unearned finance income on caption 5, and for
   everything that falls into selling, general and administrative because rule
   5-03 classifies by function.
6. **The fixed asset durations**, every one of which is practice and says so,
   and the goodwill category, which is the private company accounting
   alternative of topic 350 and is wrong for a public business entity.
7. **Whether California's use tax is one operation or two.** The core gained
   `self_assessed` for it on 16 September 2026, which ends the European word for
   an American mechanism. What the word cannot settle is the split: section
   6202(a) says the buyer's liability is not extinguished until the tax has been
   paid to the State **or to a retailer who collects it**, and this pack puts
   the first case on `US-CA-P-USE-725` (`self_assessed`, declared on line 2) and
   the second on `US-CA-P-725` (`domestic`, the seller's reimbursement, invisible
   to the return). A reviewer who files these returns will know whether that is
   the split a California practitioner recognises, or whether a purchase on
   which the seller collected is itself a use tax the pack is calling a sales
   tax.
8. **The three states.** California, New York and Oregon were chosen for what
   they demonstrate: a form that splits the rate, a form that combines it, and
   no form at all. A reviewer who files in Texas or in Washington will know
   whether a fourth shape exists that none of the three shows.
