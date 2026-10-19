# Malaysia

Everything Malaysia adds to Ekwo, as data: a chart of accounts, the journals,
the Sales Tax and Service Tax codes of the Sales Tax Act 2018 and the Service
Tax Act 2018 and where each one posts, the SST-02 return, an original balance
sheet and income statement, and what the law of this country says an invoice
and an electronic invoice must carry. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Malaysian accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

**Status: `community`.** Nobody who files a Malaysian SST-02 return has
reviewed this pack against the law they apply. The figures are replayed
against a year of books by `tests/golden.test.ts`, which proves the pack is
internally coherent and proves nothing about whether it is right.

## Sales Tax and Service Tax are not a value added tax

Malaysia is outside the common system of VAT (`supabase/seed/00_territories.sql`
carries `MY` with `eu_vat_scope: none`) and levies no value added tax of its
own either. It levies two single-stage taxes instead — Sales Tax on the
manufacture or importation of taxable goods, Service Tax on a taxable service —
and **neither Act contains a mechanism for a registered buyer to deduct the tax
a supplier charged them**. Every code of this pack is therefore
`kind: sales_tax` and `recoverable: false`: a purchase tax lands on the cost of
the line it taxes by a `tax_on_base` posting, and nowhere in this chart is
there an input-tax asset account. What a Sales Tax registered manufacturer has
instead of a credit is a set of **exemptions at the point of purchase** —
`MY-P-RAWMAT-EXEMPT`, below — which relieve a raw material of the tax rather
than refunding it afterwards.

## Sources

Every rate, item, statement line and document rule carries its own
`legal_reference`, and beside it the key of the text that article is in. The
register in `pack.json` holds thirteen texts. The ones the rest of this file
leans on:

| What | Text | Where |
|---|---|---|
| The charge, the registration threshold, the rate and the export relief | Sales Tax Act 2018 (Act 806) | `lom.agc.gov.my` |
| The charge, the registration threshold, the rate and imported services | Service Tax Act 2018 (Act 807) | `lom.agc.gov.my` |
| Which goods are taxed at 5 %, 10 % or not at all | Guide on Sales Tax Rates for Various Goods, RMCD | `mysst.customs.gov.my` |
| The 1 July 2025 rate revision and Service Tax scope expansion | Ministry of Finance press release | `mof.gov.my` |
| The parts and item numbers of form SST-02 | RMCD's own SST-02 return guidelines | `mysst.customs.gov.my` |
| Financial statements comply with approved accounting standards | Companies Act 2016 (Act 777), s. 245 | `ssm.com.my` |
| MFRS and MPERS, the standards s. 245 points to | Malaysian Accounting Standards Board | `masb.org.my` |
| The duty to issue an electronic invoice | Income Tax Act 1967, s. 82C, and the 2024 Rules | `hasil.gov.my` |
| The phased mandatory dates and the MyInvois validation flow | LHDNM e-Invoice Guideline | `hasil.gov.my` |
| The Peppol channel and its identifier scheme | PINT MY, OpenPeppol / MDEC | `docs.peppol.eu` |

Several rules rest on RMCD's prose guides rather than on the primary text: the
numbered provisions of the Sales Tax (Rates of Tax) Order 2018 and the Sales
Tax (Goods Exempted From Sales Tax) Order 2018, the Service Tax Regulations
2018's First Schedule at the current 2025 scope, and the SST-02 items that
compute the amount of tax due. MASB's own MFRS and MPERS paragraphs are served
to registered users only. Every rule built on one of these says so in its own
`legal_reference`, and the primary text should be checked.

## The chart of accounts, and why this one

**Malaysia prescribes no chart of accounts.** Companies Act 2016, section 245
requires a company's financial statements to comply with the approved
accounting standards — MFRS, which converges with IFRS, or MPERS, which
converges with the IFRS for SMEs Accounting Standard, both issued by MASB —
and neither standard prescribes a ledger.

The chart uses four-digit accounts, one class per leading digit, no parent
accounts, with the accounts a Malaysian company's books actually hold: Sales
Tax and Service Tax payable kept on **three separate posting accounts** (`2100`
output Sales Tax, `2101` output Service Tax, `2102` self-assessed Service Tax
on an imported service) and a **fourth, distinct settlement account** (`2110`)
that a filed SST-02 return clears to — the posting accounts are never
reconcilable, `2110` is. EPF, SOCSO and EIS contributions and the HRD Corp
levy have their own accounts. 142 accounts, all of them postable.

**There is no input tax account anywhere in this chart**, for the reason given
above: neither Malaysian tax is a value added tax.

## Taxes

Fifteen codes: seven on the sale side, eight on the purchase side.

| Code | Rate | What it shows |
|---|---|---|
| `MY-S-RED` | 5 % | the reduced Sales Tax rate, item 11(a) |
| `MY-S-STD` | 10 % | the standard Sales Tax rate, item 11(b), and the code the golden year's credit note reverses |
| `MY-SVT-FB` | 6 % | the rate the Ministry of Finance kept for food and beverage, telecommunication, parking and logistics when the general rate rose |
| `MY-SVT-STD` | 8 % | the general Service Tax rate since 1 March 2024 |
| `MY-S-ZERO` | 0 % | export relief under Sales Tax Act 2018, s. 41 |
| `MY-S-EXEMPT` | 0 % | a Schedule B good — outside the definition of taxable goods entirely, not a taxable supply relieved |
| `MY-SVT-EXEMPT` | 0 % | a service outside the First Schedule of the Service Tax Regulations 2018 |
| `MY-P-RED`, `MY-P-STD` | 5 %, 10 % | the buyer's side: a cost, never a claim |
| `MY-P-IMPORT` | 10 % | Sales Tax charged by RMCD at the point of import, on the customs declaration — a cost, and no box of SST-02 |
| `MY-P-RAWMAT-EXEMPT` | 0 % | Schedule C: a registered manufacturer's raw material, bought free of tax against a CJ(P) certificate, item 19 |
| `MY-P-SVT-FB`, `MY-P-SVT-STD` | 6 %, 8 % | the buyer's side of Service Tax: a cost |
| `MY-P-SVT-IMPORT` | 8 % | Service Tax Act 2018, s. 26A: an imported taxable service, self-assessed on **form SST-02A**, which this pack does not carry |
| `MY-P-EXEMPT` | 0 % | the ordinary untaxed purchase — a donation in the golden year |

**A single representative code stands for a rate, not a rate engine.** The
general 8 % Service Tax rate reaches professional, consultancy, management,
IT, employment and credit-card services, and — since 1 July 2025 — leasing and
rental and financial services, each in the Ministry of Finance's own account
with its own registration threshold (RM500,000 general, RM1,000,000 for
leasing and financial services, RM1,500,000 for construction and private
healthcare). This pack carries one 8 % sale code and one 8 % purchase code and
does not model construction, private healthcare or education, which the same
expansion taxes at 6 % under their own thresholds: a threshold is a running
total across a year, which is a feed and not a pack.

**`MY-P-SVT-IMPORT` posts a liability and reaches no box of SST-02.** Section
26A of the Service Tax Act 2018 makes a person in Malaysia who acquires an
imported taxable service account for the tax themselves, on **form SST-02A**,
a separate return this pack does not carry — `docs/packs.md` states plainly
that a pack carries one form. The postings book the cost (`tax_on_base`) and
the liability (a `tax` posting to `2102`, the negative `factor` flipping the
ledger side) and stop there. Its treatment is `foreign_services_received` —
a service bought from a supplier not established in Malaysia, the recipient
accounting for the tax. A software subscription, hosting or an API billed
from abroad is exactly this case, and the golden year buys one. **A foreign
supplier** sits on the trade payables with the others: the chart has no
separate account for suppliers abroad.

**`MY-P-IMPORT` is the same shape for goods.** Sales Tax on an import is
assessed by the Royal Malaysian Customs Department on the customs declaration,
like a customs duty, and is never a line of SST-02, which is a registered
person's own return of what they sold. Both purchase-side import codes cost
the buyer and settle with nobody's periodic return.

## The return

**SST-02, the joint return of Sales Tax and Service Tax**, filed bimonthly
(Sales Tax Act 2018 and Service Tax Act 2018, each s. 26) and due, with
payment, by the last day of the month following the taxable period. A
filing carries that date (`tax_filings.due_date`), and the debt its settlement
posts matures on it.

**Settling SST-02 clears `2100` and `2101`, never `2102`.** The settlement of a
return clears the tax its form carries, and no box of SST-02 carries the
self-assessed Service Tax of `MY-P-SVT-IMPORT`. `2102` keeps it after SST-02 is
settled. It is owed to RMCD on **form SST-02A**, which this pack does not carry:
the pack schema has one declaration form per pack (`tax_report.json`). Once
SST-02A is filed, write one entry yourself, dated on the day of payment: debit
`2102` with the tax the form declares, credit the bank account the payment
leaves from, or credit an RMCD payable if you settle it later. The golden year
leaves 80.00 on `2102` for January–February 2026, the tax on its one imported
service.

**The item numbers this pack states are a mixture of two kinds of confidence.**
Items 11(a) to 11(c), 18(a), 18(b)(ii), 18(d) and 19 are RMCD's own, read from
its guidelines. Items 11(d) (the general 8 % band) and every item that computes
the **amount of tax** from a value already declared (12(a) to 12(d), and the
total 12) are this pack's own placement: the arithmetic — a percentage of the
value already on the return — is not in doubt, RMCD's own item numbers for it
are not confirmed. A reviewer with the live SST-02 form open should check
every box code before relying on it; the pack's `legal_reference` says so at
each one.

**Bad debt relief, the credit-note deduction item, penalties and a carried
credit are not modelled.** SST-02 carries items for all four; this pack
reverses a credit note by negating the same item the invoice filled
(`box_factor: -100`, the pattern every pack of this repository uses), which is
not what RMCD's own item 13 does, and carries no penalty or prepayment line at
all.

## The chart of accounts becomes the statements

`MY-BS` and `MY-IS` in `statements.json` are original: they group this chart's
own accounts by the code ranges `accounts.csv` gives them — current and
non-current, receivables and payables split from other balances — the
classification MFRS 101 and MPERS Section 4 both use, without transcribing
either standard's own line items or paragraph numbers (see "Sources"). No
`xbrl` fact keys: nothing here was verified against a Malaysian filing
taxonomy.

`closing_style` is `retained_earnings`: the Companies Act prescribes no
current-year-result account, so net income closes straight to `3200 Retained
earnings`.

## On the invoice

**Numbering is `sequential`.** The Sales Tax Regulations 2018 and the Service
Tax Regulations 2018 prescribe the particulars an invoice states, a serial
number among them. This rule rests on RMCD's prose description of those
regulations, so the pack records that a number is required and not, in so
many words, that the series may carry no gap; the regulations themselves
should be checked.

**The tax point is one value for two different rules, and fits neither
exactly.** Sales Tax falls due at sale, disposal or first use of the goods —
closer to delivery; Service Tax falls due generally at payment, or twelve
months after the invoice if no payment comes first — closer to payment. There
is one `documents.tax_point` per country, so this pack declares
`earliest_of_delivery_or_payment`, the closest of the five values to both
halves and exact for neither.

**Electronic invoicing is mandatory, phased by turnover, and is a
pre-issuance clearance.** Income Tax Act 1967, s. 82C, with the Income Tax
(Issuance of Electronic Invoice) Rules 2024, phases the duty in by annual
turnover or revenue, and the pack carries the calendar as data in
`einvoicing.fiscalisation.mandatory_from`, one step per threshold:

| From | Bound when the annual turnover or revenue is above |
|---|---|
| 1 August 2024 | RM100,000,000 |
| 1 January 2025 | RM25,000,000 |
| 1 July 2025 | RM5,000,000 |
| 1 January 2026 | RM1,000,000 |

`einvoicing.mandatory_from` keeps the first of these, the day the duty first
bound anyone. The exemption threshold below which a taxpayer need not yet
comply has been raised twice since — to RM1,000,000 in December 2025 and to
RM3,000,000 by version 4.8 of LHDNM's own guideline, dated 30 August 2026,
§ 1.6.1(e) — and `fiscalisation.exemption` carries it as a dated history. Only
the RM3,000,000 threshold is an entry, from 30 August 2026, the date of the
guideline that states it. The RM1,000,000 threshold, which the Cabinet
decided on 6 December 2025 for the phase of 1 January 2026, is reported by the
press and by advisers; no text of LHDNM or of the Ministry of Finance stating
it was found, so it is not an entry and no date is invented. The books do not say
a company's turnover, so `ekwo einvoice fiscalisation` counts every posted
sale from 1 August 2024 and says which threshold holds; whether a company is
bound, and from which step, is the company's and its accountant's to say.

MyInvois validates an invoice **before** it reaches the buyer: LHDNM returns a
Unique Identifier Number, the moment of validation and the link of the QR code
the invoice carries, and the invoice is not legally the taxpayer's without
them. The pack declares this as a `clearance` regime in format `myinvois`: the
link is `returned` by the authority, and the supplier may cancel and the buyer
reject a validated invoice within `PT72H`, 72 hours of its validation, each
with a reason. The `einvoicing` module records each submission and each answer
(`ekwo einvoice clearance`, `einvoicing_clearance`) and refuses a cancellation
or a rejection after the window; a posted sale without a validation is named
by the status. A posted sale is written as the MyInvois document by
`@ekwo-ai/myinvois` through the ordinary path of issue (`ekwo einvoice
issue`, `einvoicing_issue`), as below. One thing remains: **Ekwo does not call
MyInvois** — the signature of a version 1.1 document, the submission and its
authentication are the host's (see
[`docs/international.md`](../../docs/international.md#from-malaysia)). The
profile is `myinvois`, the document submitted to the MyInvois API directly —
PINT MY, through a Peppol access point, is the other channel and not the one
declared — and the scheme is `0230`, the SSM number.

## MyInvois

The document of a posted sale is written from the three views of the books,
from what the books hold of both parties, and from two attributes this pack
gives in `einvoicing.fiscalisation`. Nothing in the books decides them, so
the pack states them with their source:

- **`tax_attributes`: the tax type of each tax**, in LHDNM's list (MyInvois
  SDK, *Tax Types*). `01` Sales Tax for `MY-S-RED`, `MY-S-STD` and the Sales
  Tax a purchase bears (`MY-P-RED`, `MY-P-STD`, `MY-P-IMPORT`); `02` Service
  Tax for `MY-SVT-FB`, `MY-SVT-STD`, `MY-P-SVT-FB`, `MY-P-SVT-STD` and
  `MY-P-SVT-IMPORT`. The SDK lists `06` *Not Applicable* and `E` *Tax
  exemption* without saying when each applies; it ties `E` to the "Details of
  Tax Exemption", mandatory where an exemption applies, with "special
  exemption as per gazette orders" among its examples. Read with the Acts, `E`
  is given where an Act or an order made under it exempts goods from a tax
  that would otherwise reach them — `MY-S-ZERO` (section 41, goods proved
  exported), `MY-S-EXEMPT` (the Goods Exempted From Sales Tax Order 2018),
  `MY-P-RAWMAT-EXEMPT` (Schedule C, against a certificate) — and `06` where
  no tax reaches the supply at all: `MY-SVT-EXEMPT` and `MY-P-EXEMPT`. Where
  the reading could go either way, `E` is the more cautious: it makes the
  document state the reason of the exemption, which `06` leaves unsaid.
  Each tax under `E` carries its `exemption_reason`, the "Details of Tax
  Exemption" the document states: the provision this pack already cites for
  it, in one sentence. A line whose exemption rests on something of its own —
  the buyer's exemption certificate number, a gazette order — says so in its
  own `attributes` (`exemption_reason`), which win over the tax's; the
  breakdown then states the reasons of its lines.
- **`line_attributes`: the classification of every line**, `022` *Others*,
  the entry of LHDNM's list of classification codes for what none of its
  named cases is. The SDK does not call it a default. A line that is one of
  the named cases — a computer or a smartphone (`003`), a motor vehicle
  (`025`), a repair (`030`) — says so in its own `attributes`
  (`myinvois_classification`, one code or several separated by commas), or in
  those of the product it sells, which a line filled in from it takes; the
  code is checked against LHDNM's list when the document is written, and a
  code outside it is reported (`CV302`).

From the books, by what each column already means:

| MyInvois | Read from |
|---|---|
| TIN of each party | `identifiers.TIN` of the company and of the contact |
| BRN | `registration_number`, or `identifiers.NRIC`, `PASSPORT`, `ARMY` for a person |
| SST and tourism tax registration of the supplier | `identifiers.SST`, `identifiers.TTX` of the company — `NA` where it is not registered, as the SDK asks |
| SST registration of the buyer | `identifiers.SST` of the contact; `NA` where the books hold none |
| MSIC code and business activity description | `activity_code` and `activity_description` of the company |
| Telephone of each party | `phone` of the company and of the contact |
| State | `region`: a state code `01`–`16`, or its name |
| Payment mode | the payment means of the document, where its code means a mode of LHDNM's list |
| Document a credit note adjusts | the invoice it credits, with the Unique Identifier Number recorded when LHDNM validated it |
| Moment of issuance | the moment the document is written |

What a sale of this pack's golden year gives, once both parties are complete:
a sale under `01`, `02`, `06` or `E` carries no violation, the reason of an
exemption being the tax's or the line's; a credit note is reported until the invoice
it credits has been validated (`input:adjusts`); a document in another
currency is reported until the books publish its rate to the ringgit
(`input:exchange_rate`).

**The validation link and the QR code.** LHDNM answers a valid document
with its Unique Identifier Number (`uuid`), the moment of validation
(`dateTimeValidated`) and a long ID (`longId`), and the issuer builds the
link the e-Invoice carries as a QR code: `{envbaseurl}/{uuid}/share/{longId}`,
`myinvois.hasil.gov.my` in production and `preprod.myinvois.hasil.gov.my` in
the sandbox (MyInvois SDK, FAQ). `clearance.verification` is therefore
`computed`, and `clearance.verification_url` gives both: a validation recorded
with the answer of the Get Document API (`ekwo einvoice clearance <document>
validated --identifier <uuid> --validated-at <time> --detail answer.json`,
`--environment test` for the sandbox) gets its link built. The PDF of the
validated sale (`ekwo doc pdf`) then carries the QR code of that link, the
Unique Identifier Number and the moment of validation (`clearance.printed`),
under the words of the invoice labels.

**No withholding tax.** Income Tax Act 1967, s. 107A and s. 109 impose
withholding on payments to a non-resident — contract payments, interest,
royalties, technical fees. This pack carries none: the SST codes and the
withholding codes are two different questions. It stays on the list below.

## Language

`defaults.language` is `ms`, Bahasa Malaysia, the national language under
article 152 of the Federal Constitution. **The labels themselves are written
in English.** Malaysian statutory financial reporting is conducted in
English — the Companies Act 2016 is enacted in English, MASB publishes MFRS
and MPERS in English, and RMCD's own SST-02 guidelines and forms this pack
transcribes are the English versions of a bilingual administration — and no
official Bahasa Malaysia chart of accounts or SST-02 exists for this pack to
transcribe instead. No second `i18n/` file is declared: a Bahasa Malaysia
translation is future work and welcome, one file, one contributor, per
`docs/packs.md`, "Languages".

## What this pack does not carry

- **Every Service Tax group's own rate and threshold.** One 8 % code and one
  6 % code stand for a First Schedule with many more groups than this pack
  transcribes — construction, private healthcare, education and the groups the
  2025 expansion added each keep their own rate and their own threshold.
- **Form SST-02A**, the return for an imported taxable service.
  `MY-P-SVT-IMPORT` books the cost and the liability and reaches no box, so
  settling SST-02 leaves `2102` alone; an entry the company writes clears it
  once SST-02A is paid (see "The return"). A second form needs the pack
  schema to carry more than one `tax_report.json`.
- **Confirmed item numbers of SST-02 for the amount of tax due**, named above:
  the pack's own placement, not a confirmed reading of the form.
- **Bad debt relief, the credit-note deduction item (13), penalties, interest
  and a carried-forward credit** — SST-02 items this pack declares nowhere.
- **Group relief and the B2B exemption facility**, items 18(c)(1) and 18(c)(2)
  of the return, under which a Service Tax registered person may buy from
  another without the tax applying a second time.
- **Withholding tax** on a payment to a non-resident, Income Tax Act 1967,
  ss. 107A and 109.
- **The call to MyInvois.** The document is written and the clearance
  recorded, not made: the signature and the submission are the host's.
- **The reason of an exemption** for `MY-S-ZERO`, `MY-S-EXEMPT` and
  `MY-P-RAWMAT-EXEMPT`, which MyInvois asks under `E`: no text read for this
  pack prescribes the sentence, so none is declared.
- **A classification per line** other than `022`, named above.
- **The day the RM1,000,000 exemption threshold took effect**, in December
  2025: no text this pack cites dates it, so it is not an entry of
  `fiscalisation.exemption`.
- **A Malay-language translation of the pack's own labels.**

## Reviewing this pack

Open an issue titled "Review: Malaysia". What a review is, and what it is not,
is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who may
say what".

Points a reviewer familiar with Malaysian SST practice should look at first:

1. **The item numbers of SST-02**, all of them, against the live form: this
   pack states items 11(a) to 11(d), 12(a) to 12(d) and 12 with the least
   confidence of anything it carries.
2. **Whether the general 8 % code should instead be several**, one per Service
   Tax group and its own threshold, before this pack is used by a company that
   provides more than one kind of taxable service.
3. **Whether `MY-P-RAWMAT-EXEMPT`'s `conditions: buyer_status` is the right
   word** for an approval the Director General grants, rather than a status
   the buyer simply has.
4. **The tax point approximation**, `earliest_of_delivery_or_payment`, against
   the primary text of both Acts' charging sections.
5. **Whether `MY-S-EXEMPT` and `MY-SVT-EXEMPT` should be `not_subject` or
   `exempt`.** This pack reads a Schedule B good and an out-of-scope service as
   outside the tax entirely; a reviewer who reads the Acts' own definitions
   differently would want `exempt` and, if a reason is available, a citation to
   the relieving Order at the line instead.
