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
a supplier charged them**, the whole difference from a value added tax and from
the Singapore and Thai packs beside this one. Every code of this pack is
therefore `kind: sales_tax` and `recoverable: false`: a purchase tax lands on
the cost of the line it taxes by a `tax_on_base` posting, exactly as it does in
`packs/us/`, and nowhere in this chart is there an input-tax asset account of
the kind `packs/sg/` and `packs/th/` carry. What a Sales Tax registered
manufacturer has instead of a credit is a set of **exemptions at the point of
purchase** — `MY-P-RAWMAT-EXEMPT`, below — which relieve a raw material of the
tax rather than refunding it afterwards.

## Sources

Every rate, item, statement line and document rule carries its own
`legal_reference`, and beside it the key of the text that article is in. The
register in `pack.json` holds thirteen texts, all of them opened on
25 September 2026. The ones the rest of this file leans on:

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

**What this session could not read as a primary, machine-readable text**, and
said so at the rule rather than pretending otherwise: the numbered provisions
of the Sales Tax (Rates of Tax) Order 2018 and the Sales Tax (Goods Exempted
From Sales Tax) Order 2018 (both served this session only as RMCD's own prose
guides, never as the Order's own gazetted text); the Service Tax Regulations
2018's First Schedule, group by group, at the current 2025 scope; the exact
item numbers of SST-02 that compute the amount of tax due on each rate band
and the totals that sum them (RMCD's own PDF guideline resisted extraction as
text, twice, from two different mirrors — the same failure mode
[`packs/th/`](../../docs/international.md#from-thailand) records for a Royal
Gazette PDF); and MASB's own MFRS and MPERS paragraphs, served to registered
users only. Every rule built on one of these is flagged in its own
`legal_reference`, not only here.

## The chart of accounts, and why this one

**Malaysia prescribes no chart of accounts.** Companies Act 2016, section 245
requires a company's financial statements to comply with the approved
accounting standards — MFRS, which converges with IFRS, or MPERS, which
converges with the IFRS for SMEs Accounting Standard, both issued by MASB —
and neither standard prescribes a ledger.

The chart follows the numbering the sibling Asian packs use — four digits, one
class per leading digit, no parent accounts — with the accounts a Malaysian
company's books actually hold: Sales Tax and Service Tax payable kept on
**three separate posting accounts** (`2100` output Sales Tax, `2101` output
Service Tax, `2102` self-assessed Service Tax on an imported service) and a
**fourth, distinct settlement account** (`2110`) that a filed SST-02 return
clears to — the posting accounts are never reconcilable, `2110` is, and the
two roles it fills (`tax_payable`, `tax_receivable`) are kept apart from the
role Sales Tax and Service Tax post to, exactly as the format's own note on
tax settlement accounts asks. EPF, SOCSO and EIS contributions and the HRD
Corp levy stand in for Singapore's CPF, the Skills Development Levy and the
foreign worker levy. 142 accounts, all of them postable.

**There is no input tax account anywhere in this chart**, for the reason given
above — the same sentence `packs/us/` opens its own chart section with, and
true for the same reason: neither Malaysian tax is a value added tax.

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
expansion taxes at 6 % under their own thresholds. The shape is exactly
`packs/us/`'s "one worked district combination and not the hundreds that
exist": a threshold is a running total across a year, which is a feed and not
a pack.

**`MY-P-SVT-IMPORT` posts a liability and reaches no box of SST-02.** Section
26A of the Service Tax Act 2018 makes a person in Malaysia who acquires an
imported taxable service account for the tax themselves, on **form SST-02A**,
a separate return this pack does not carry — `docs/packs.md` states plainly
that a pack carries one form. The postings book the cost (`tax_on_base`) and
the liability (a `tax` posting to `2102`, the negative `factor` flipping the
ledger side exactly as `US-CA-P-USE-725` does for California's use tax) and
stop there.

**`MY-P-IMPORT` is the same shape for goods.** Sales Tax on an import is
assessed by the Royal Malaysian Customs Department on the customs declaration,
like a customs duty, and is never a line of SST-02, which is a registered
person's own return of what they sold. Both purchase-side import codes cost
the buyer and settle with nobody's periodic return.

## The return

**SST-02, the joint return of Sales Tax and Service Tax**, filed bimonthly
(Sales Tax Act 2018 and Service Tax Act 2018, each s. 26) and due, with
payment, by the last day of the month following the taxable period.

**The item numbers this pack states are a mixture of two kinds of confidence.**
Items 11(a) to 11(c), 18(a), 18(b)(ii), 18(d) and 19 are RMCD's own, read from
its guidelines. Items 11(d) (the general 8 % band) and every item that computes
the **amount of tax** from a value already declared (12(a) to 12(d), and the
total 12) are this pack's own placement: the arithmetic — a percentage of the
value already on the return — is not in doubt, RMCD's own item numbers for it
could not be confirmed against a machine-readable text this session. A
reviewer with the live SST-02 form open should check every box code before
relying on it; the pack's `legal_reference` says so at each one.

**Bad debt relief, the credit-note deduction item, penalties and a carried
credit are not modelled.** SST-02 carries items for all four; this pack
reverses a credit note by negating the same item the invoice filled
(`box_factor: -100`, the pattern every pack of this repository uses), which is
not what RMCD's own item 13 does, and carries no penalty or prepayment line at
all — the same gap `packs/us/` names for CDTFA-401-A's lines 20a to 25.

## The chart of accounts becomes the statements

`MY-BS` and `MY-IS` in `statements.json` are original, like `packs/th/`'s: they
group this chart's own accounts by the code ranges `accounts.csv` gives them —
current and non-current, receivables and payables split from other balances —
the classification MFRS 101 and MPERS Section 4 both use, without transcribing
either standard's own line items or paragraph numbers, which this session
could not read (see "Sources"). No `xbrl` fact keys: nothing here was verified
against a Malaysian filing taxonomy.

`closing_style` is `retained_earnings`: the Companies Act prescribes no
current-year-result account, so net income closes straight to `3200 Retained
earnings`, the same answer `packs/sg/`, `packs/th/` and `packs/us/` give for
the same structural reason.

## On the invoice

**Numbering is `sequential`.** The Sales Tax Regulations 2018 and the Service
Tax Regulations 2018 prescribe the particulars an invoice states, a serial
number among them; this session could not read either regulation's own
numbered provision as a primary text, only RMCD's prose description of it, so
the pack records that a number is required and not, in so many words, that the
series may carry no gap.

**The tax point is one value for two different rules, and fits neither
exactly.** Sales Tax falls due at sale, disposal or first use of the goods —
closer to delivery; Service Tax falls due generally at payment, or twelve
months after the invoice if no payment comes first — closer to payment. There
is one `documents.tax_point` per country, so this pack declares
`earliest_of_delivery_or_payment`, the closest of the five values to both
halves and exact for neither; `docs/international.md` records the
approximation.

**Electronic invoicing is mandatory, phased by turnover, and is a
pre-issuance clearance the core cannot model.** Income Tax Act 1967, s. 82C,
with the Income Tax (Issuance of Electronic Invoice) Rules 2024, phases the
duty in from 1 August 2024 (above RM100 million) to 1 January 2026 (above
RM1 million), while the exemption threshold below which a taxpayer need not
yet comply has itself been raised twice since — to RM1,000,000 in December
2025 and to RM3,000,000 by version 4.8 of LHDNM's own guideline, dated
30 August 2026, four weeks before this pack's own `released_at`. The format
has no field for an exemption threshold that moves by administrative
guideline; this pack states the day the duty first bound anyone. More
fundamentally: MyInvois validates an invoice **before** it reaches the buyer —
LHDNM returns a Unique Identifier Number and a QR code, and the invoice is not
legally the taxpayer's without them. Ekwo has no document status for a step
that happens between posting and delivery and waits on an external answer;
`docs/international.md` records the gap under "From Malaysia", and this pack
declares the profile (`pint-my`) and the scheme (`0230`, the SSM number)
without attempting to model the UIN, the QR code, or the 72-hour rejection
window.

**No withholding tax.** Income Tax Act 1967, s. 107A and s. 109 impose
withholding on payments to a non-resident — contract payments, interest,
royalties, technical fees — which `packs/sg/` carries for its own country's
equivalent article. This pack carries none: the SST codes and the withholding
codes are two different questions, and the brief this pack was written to
scoped the second one out. It stays on the list below.

## Language

`defaults.language` is `ms`, Bahasa Malaysia, the national language under
article 152 of the Federal Constitution. **The labels themselves are written
in English.** Malaysian statutory financial reporting is conducted in
English — the Companies Act 2016 is enacted in English, MASB publishes MFRS
and MPERS in English, and RMCD's own SST-02 guidelines and forms this pack
transcribes are the English versions of a bilingual administration — and no
official Bahasa Malaysia chart of accounts or SST-02 exists for this pack to
transcribe instead. `packs/th/` faced the same choice in reverse and wrote its
own labels in Thai because that is the language its sources were in; this pack
writes English labels under an `ms` default for the same reason held up to a
mirror. No second `i18n/` file is declared: a Bahasa Malaysia translation is
future work and welcome, one file, one contributor, per `docs/packs.md`,
"Languages".

## What this pack does not carry

- **Every Service Tax group's own rate and threshold.** One 8 % code and one
  6 % code stand for a First Schedule with many more groups than this pack
  transcribes — construction, private healthcare, education and the groups the
  2025 expansion added each keep their own rate and their own threshold.
- **Form SST-02A**, the return for an imported taxable service. `MY-P-SVT-IMPORT`
  books the cost and the liability and reaches no box, as `packs/us/`'s
  `US-NY-S-8875` does for a state whose form it does not carry.
- **The item numbers of SST-02 that compute the amount of tax due**, named
  above, this session's own placement and not a confirmed reading of the form.
- **Bad debt relief, the credit-note deduction item (13), penalties, interest
  and a carried-forward credit** — SST-02 items this pack declares nowhere.
- **Group relief and the B2B exemption facility**, items 18(c)(1) and 18(c)(2)
  of the return, under which a Service Tax registered person may buy from
  another without the tax applying a second time.
- **Withholding tax** on a payment to a non-resident, Income Tax Act 1967,
  ss. 107A and 109.
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
