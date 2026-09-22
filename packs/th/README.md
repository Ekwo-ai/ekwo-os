# Thailand

Everything Thailand adds to Ekwo, as data: a chart of accounts, the journals,
the value added tax of the Revenue Code with its zero rate and its exemptions,
a self-assessment on services bought from abroad, two withholding taxes, the
monthly return, and a balance sheet and income statement grouped by this
chart's own account ranges. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Thai accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Thai VAT return has reviewed it.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**This is the first pack of mainland Southeast Asia.** What the core could
not say is written up in [`docs/international.md`](../../docs/international.md)
under "Thailand", including one correction to this repository's own
documentation that cost real time to find — read it before copying this
pack's `statements.json` as a model.

## Sources

Every tax, box and mention carries its own `legal_reference`, and beside it
the key of the text that article is in. The register in `pack.json` holds
nine texts, all opened on 22 September 2026: the Revenue Code in the Revenue
Department's own English translation, the Department's guidance pages on the
value added tax, withholding tax and Specific Business Tax, the Royal Gazette
text of the decree that currently reduces the rate, and the RD e-Filing
portal.

| What | Text | Where |
|---|---|---|
| The rate, the zero rate, exemptions, the small-business threshold | Revenue Code, sections 80, 80/1, 81, 81/1 | `rd.go.th/english/37732.html` — read directly |
| Self-assessment on a service bought from abroad | Revenue Code, section 83/6 | `rd.go.th/english/37735.html` — read directly |
| The particulars of a tax invoice | Revenue Code, section 86/4 | `rd.go.th/english/37741.html` — read directly |
| Registration threshold, form VAT 30 and its deadline, form VAT 36 | Revenue Department, VAT guidance | `rd.go.th/english/6043.html` |
| Withholding on a payment to a company, a payment to an individual | Revenue Department guidance | `rd.go.th/english/6044.html`, `6045.html` |
| Specific Business Tax | Revenue Department guidance | `rd.go.th/english/6042.html` |
| The Royal Decree currently reducing the rate to 7 % | Royal Gazette text (No. 799, B.E. 2568) | `rd.go.th/fileadmin/user_upload/kormor/newlaw/dc799.pdf` |
| Where form VAT 30 is filed electronically | RD e-Filing | `efiling.rd.go.th` |

**Four sections could not be read at all this session**, and each says so at
the point it matters: sections 78 and 78/1 (time of supply), 82/3 and 82/5
(the right to credit input tax and what it excludes) returned a server error
on every attempt; the Royal Decree PDFs (No. 799 and No. 807) are Thai text in
embedded fonts that resisted extraction twice. None of the figures in this
pack rest on a guess at what those texts say — where a rule needed one of
them, the pack states the closest thing a secondary reading gives and marks
the gap, rather than the article itself.

## The chart of accounts, and why this one

**Thailand prescribes no chart of accounts.** What this session could verify
is that the Federation of Accounting Professions issues Thai Financial
Reporting Standards, including one for entities that are not publicly
accountable, and that the Department of Business Development administers the
Accounting Act B.E. 2543 (2000), which requires a business to keep accounts
and file financial statements — neither text, nor the standard's own
paragraphs, could be opened this session. So the chart is written, not
transcribed: four digits by class, the numbering the sibling Asian packs
(Singapore, Japan) use — `1` assets, `2` liabilities, `3` equity, `4` revenue,
`5` cost of sales, `6` operating expenses, `7` finance items, `8` income tax —
with the accounts a value-added-tax-registered Thai company's books hold:
output and input value added tax, the VAT payable or refundable account a
filed return settles to, withholding tax payable on a supplier's invoice, a
withholding-tax-certificate asset for tax withheld *from* the company's own
sales (creditable against annual corporate income tax, common Thai practice
this session did not verify against a text), the Social Security Fund, a
provident fund, and a legal reserve, common to a Thai company though this
session did not read the Civil and Commercial Code provision that requires
one. 173 accounts, all postable. None was copied from a published chart.

**Five value added tax accounts.** `2100` holds the output tax and `1150` the
input tax — the two the taxes post to. `2110` and `1155` are where a filed
return's balance lands: `tax_payable` and `tax_receivable`, apart from the
posting accounts and both reconcilable, so a payment to the Revenue
Department and a refund from it are each matched against their own account.
`2140` holds withholding tax the company owes the Revenue Department on what
it paid a supplier.

## Taxes

**One combined rate, one posting.** Section 80 sets the rate at 10 %; a Royal
Decree — currently No. 799, B.E. 2568 — reduces it to 6.3 % national plus
0.7 % local tax, 7 % combined, the way it has continuously since 1997 by a
secondary account this session could not verify against the Royal Gazette
itself (see "Sources" and `docs/international.md`). `TH-S-STD` and
`TH-P-STD` carry that 7 % as one rate and one posting: nothing read this
session shows a Thai return asking the two shares to be told apart, unlike
Japan's national and local consumption tax, which is why they are not split
here the way Japan's are.

**Exports and international services are zero-rated, separately.**
`TH-S-ZR-EXP` is an export of goods under section 80/1(1); `TH-S-ZR-SVC` is a
service performed in Thailand and used abroad, or international transport,
under section 80/1(2) and (3). Both report their value in box `SZ` and carry
no tax.

**An exemption under section 81 carries no box.** `TH-S-EX` and `TH-P-EX` —
residential rental is the example the golden year uses — report a base and
nothing else: nothing read this session shows form VAT 30 asking for the
value of an exempt supply the way Singapore's form GST F5 does at its box 3,
and a business exempt under section 81 is, for that activity, outside the
value added tax system rather than a registrant reporting a nil-rated line —
which section 81/1's own separate small-business threshold (600,000 baht by
statute, 1.8 million baht by the Royal Decree section 81/1 itself
authorises) confirms.

**Self-assessment on a service bought from abroad.** `TH-P-RC` is section
83/6: a service performed abroad and used in Thailand, where the payer
remits value added tax on form VAT 36. It posts the value to box `RC`, the
self-assessed tax to box `OT` (credited, mirroring the way Singapore's
`SG-P-RC-9` flips a purchase-side posting with `factor: -100` to read as a
liability rather than an asset), and the same amount to box `IT` as an
immediate credit. **This overstates how fast the credit is available**: the
law remits VAT 36 within seven days of payment and credits it on form VAT 30
of that month or the next, a two-form timing this pack does not model — see
`docs/international.md`.

**Two withholding taxes, chosen so neither shares a line with value added
tax.** `TH-P-WHT-SVC-3` withholds 3 % on a fee paid to a small consultant who
is not registered for value added tax (Revenue Department guidance, form
CIT 53 / ภ.ง.ด.53); `TH-P-WHT-RENT-5` withholds 5 % on rent paid to an
individual landlord, itself exempt from value added tax under section 81
(form PND 3 / ภ.ง.ด.3). A fee that is *both* value added tax-able and subject
to withholding — the ordinary case for a domestic company's professional
fees — needs two postings on one payment that this pack's tax codes do not
compose on a single document line; it is not carried, and is named again
below. Both rates and their sections (3 tredecim, the departmental
instruction that actually fixes them) rest on the Revenue Department's
summary pages, not on the instruction itself, which this session did not
read; `valid_from` is 1 January of the golden scenario's year and is not a
verified commencement date.

## The return

`TH-VAT-30` is this pack's own transcription of form VAT 30 (ภ.พ.30), filed
every month. **Its box codes — `SB`, `SZ`, `OT`, `PB`, `RC`, `IT`, `NET` — are
not the form's own printed item numbers.** The Revenue Department's English
guidance names what the form covers by topic (taxable person, tax base, tax
calculation, refund…) and not its printed wording, which this session could
not read; the boxes here are the mechanics that page confirms the form has,
under short codes this pack invented rather than numbers it could not verify.
**The first thing for a reviewer with a specimen return in hand to check.**

**The deadline is exact.** Fifteen days after the end of the month, at an
Area Revenue Branch Office or through RD e-Filing (`rd-vat-guide`, read
directly). This session could not confirm or rule out an extended deadline
for electronic filing, which several other countries in this repository
grant; none is declared.

**`NET` is not floored to zero.** A negative figure is a refund or a credit
carried forward — section 84 of the Revenue Code was not read this session,
so which of the two, or whether the taxpayer chooses, is not modelled beyond
the figure itself.

## The statements

`TH-BS` and `TH-IS` are original: lines grouped by the code ranges this
chart's own numbering gives its accounts — current and non-current, revenue
and cost of sales, operating expenses and depreciation — the same
classification a Thai standard would use without transcribing that
standard's own line items or their numbering, because this session could not
open the Federation of Accounting Professions' text (see "Sources"). No fact
keys: nothing here was checked against a taxonomy. `closing_style` is
`retained_earnings`: a Thai balance sheet, on what this session could read,
keeps no separate current-year-result line the way Belgium's appropriation
accounts do, so the open year's result sits on `E-RESULT` until the close.

## On the invoice

**Section 86/4**, read directly this session, lists eight particulars a tax
invoice states: the words "tax invoice", the issuer's identity and tax
identification number, the buyer's name and address, a serial number of the
invoice and, if any, its book, a description, the value added tax shown
separately from the value of the goods or services, the date, and anything
else the Director-General prescribes. **Numbering is `sequential`**: the
section asks for an identifying number, not, in so many words, a series with
no gap. **No legal mentions are declared**: nothing read this session shows
section 86/4 or a regulation beside it requiring a specific sentence on a
zero-rated or exempt line, unlike Singapore's GST (General) Regulations,
reg. 11(3). **No payment term is declared**: this session found no Revenue
Code or Civil and Commercial Code provision setting one between businesses in
the absence of an agreement, and did not look exhaustively enough to say
there is none.

## Electronic invoicing

`einvoicing.obligation` is `none` and `profile` is `null`. The Revenue
Department runs e-Tax Invoice & e-Receipt (`etax.rd.go.th`), a system a
business submits its tax invoice data to — not built on Peppol, and not
something this session could verify as mandatory for any class of taxpayer:
the portal renders through client-side script the tools available here could
not execute. `none` states only that no statute obliging it was found, not
that none exists — the first thing for a reviewer to check directly on the
portal.

## What this pack does not carry

- **Section 82/5**, the list of input tax excluded from credit (entertainment
  expenses and passenger cars, by reputation and not by a text read this
  session): `TH-P-STD` assumes full creditability.
- **The two-form timing of section 83/6** (VAT 36 within seven days, credited
  the same or the next month): `TH-P-RC` claims the credit immediately.
- **A fee that is both value-added-tax-able and subject to withholding on one
  line**: the two withholding codes are chosen so neither needs it, which is
  not the ordinary case for a domestic professional fee.
- **Specific Business Tax** (sections 91/2, 91/6): banking, finance, life
  insurance, pawnbroking and commercial real estate file a different return
  (ภธ.40) at different rates, entirely outside this pack.
- **Import value added tax collected by Thai Customs.** Only a self-assessed
  service from abroad is carried; a company that imports goods needs a code
  this pack does not have.
- **The exact printed boxes of form VAT 30**, its Thai wording, and the exact
  Royal Decree chain that sets the 7 % rate (see "Sources").
- **Sections 78, 78/1, 82/3**, read only through secondary guidance after a
  server error on every direct attempt.
- **A Thai financial reporting standard's own line items.**
- **Fixed assets.** No `assets.json`: this session found no capital allowance
  table it could read in the time available.
- **Bank formats.** Nothing checked says which formats Thai banks send.

## Reviewing this pack

Open an issue titled "Review: Thailand". What a review is, and what it is
not, is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and
who may say what". The points a Thai accountant should read first, roughly in
the order the author is least sure of them:

1. **The Royal Decree chain that sets the rate at 7 %** — decree number, date
   and Gazette citation — against `rd.go.th/fileadmin/user_upload/kormor/newlaw/dc799.pdf`
   directly: this session's tools could not extract its text.
2. **Sections 78, 78/1, 82/3 and 82/5** against their primary text, which
   returned a server error on every attempt this session made.
3. **The two-form timing of section 83/6**, and whether `TH-P-RC` should
   instead be split into two documents to match it.
4. **The withholding rates and their commencement dates**, read here from
   summary pages rather than the departmental instruction that sets them.
5. **Whether a section 81 exemption should carry a box** of form VAT 30 —
   this pack assumes not, from the absence of one in what it could read.
6. **The chart's own statements**, `TH-BS` and `TH-IS`, against a proper
   reading of the Thai Financial Reporting Standard for entities that are
   not publicly accountable, once its text can be opened.
7. **`tax_point: earliest_of_delivery_or_payment`**, the closest of five
   closed values to what secondary guidance gives for sections 78 and 78/1.
8. **`numbering: sequential`**, which rests on section 86/4 alone.
