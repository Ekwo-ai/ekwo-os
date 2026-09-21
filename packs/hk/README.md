# Hong Kong

Everything Hong Kong adds to Ekwo, as data: a chart of accounts, the journals,
the two "not subject" tax codes that carry every sale and purchase a Hong Kong
business books, the statement of financial position and the income statement
of the SME-FRF & SME-FRS, and the one sentence the law puts on a business
document. The format is [`docs/packs.md`](../../docs/packs.md); this file says
where the content came from and which decisions it rests on, so that a Hong
Kong accountant reading the pack can disagree with a specific sentence rather
than with the whole of it.

**Status: `community`.** Nobody who practises in Hong Kong has reviewed it.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**This pack is a deliberate edge case.** Every other pack in this repository
carries a value added tax, a goods and services tax or a sales tax, and every
one of `tax_report.json`'s readers and every assertion of the golden test
runner was written against that assumption. Hong Kong has none — no VAT, no
GST, no general sales tax, at any level of government, ever — which is exactly
why it was chosen: it is the pack that finds out whether the core actually
means what it says when it calls a periodic return optional. What it found is
written up in [`docs/international.md`](../../docs/international.md) under
"From Hong Kong". None of it was patched for this pack's sake.

## Sources

Every tax and statement line carries its own `legal_reference`, and beside it
the key of the text that sentence rests on. The register in `pack.json` holds
ten texts, consulted on 21 September 2026:

| What | Text | Where |
|---|---|---|
| No VAT, no GST, no general sales tax, ever; the territorial charge to profits tax, s. 14 | Inland Revenue Ordinance (Cap. 112) | `elegislation.gov.hk/hk/cap112` |
| The two-tiered profits tax rates, the $2,000,000 threshold, the year of assessment | Inland Revenue Department, *Profits Tax*, *Two-tiered Profits Tax Rates Regime* | `ird.gov.hk` |
| Keeping business records for not less than seven years, s. 51C | Inland Revenue Department, *Keeping Business Records* | `ird.gov.hk/eng/tax/bus_rke.htm` |
| Business registration and the Business Registration Number | Business Registration Ordinance (Cap. 310); Inland Revenue Department, *Business Registration* | `elegislation.gov.hk/hk/cap310`, `ird.gov.hk` |
| The duty to keep accounting records and to prepare true and fair financial statements | Companies Ordinance (Cap. 622), Part 9 | `elegislation.gov.hk/hk/cap622` |
| What the Annual Return to the Companies Registry does and does not carry | Companies Registry, *Annual Returns of Local Private Companies* | `cr.gov.hk` |
| The SME-FRF & SME-FRS, and what a company reporting under it presents | HKICPA, Members' Handbook, Volume II | `hkicpa.org.hk` |
| Where a return is actually filed | Inland Revenue Department, *Electronic Services* (eTAX Business Tax Portal) | `ird.gov.hk/eng/ese` |

`elegislation.gov.hk` serves its text through a viewer this environment could
not render past its home page — a JavaScript reader with no plain-text
fallback this pack's author found, after trying a script fetch, a headless
render and a text-proxy render, all three. The two ordinances are cited at the
level this pack could actually confirm: Cap. 112 by the sections the Inland
Revenue Department's own pages quote directly (s. 14, s. 51C), and Cap. 622 at
the level of Part 9, whose existence and subject are standard company-law
knowledge but whose individual section numbers this pack has not re-read
against the primary text in this session. A Hong Kong company secretary or
CPA is the right person to confirm the exact subsections before this pack
moves past `community`; see "Reviewing this pack".

## The chart of accounts, and why this one

**Hong Kong prescribes no chart of accounts.** Companies Ordinance (Cap. 622),
Part 9 requires every company to keep accounting records sufficient to give a
true and fair view of its transactions, and requires its directors to prepare
financial statements that give a true and fair view — and, unlike a small
British or Australian company, a Hong Kong company gets no exemption from
audit for being small: every company, however small, is audited. What a
private company *can* be exempted from is the full weight of Hong Kong
Financial Reporting Standards: a company that is not a "specified body", stays
under the SME-FRF's size test and has the unanimous written agreement of its
shareholders may report under SME-FRS instead (Hong Kong Institute of
Certified Public Accountants). Neither framework prescribes a chart, only the
statements this pack's `statements.json` carries.

So the chart is written, not transcribed:

- **Four digits, by class**, `1` assets, `2` liabilities, `3` equity, `4`
  revenue and other income, `5` cost of sales, `6` operating expenses — the
  order a trial balance is read in, and nothing else.
- **Flat.** No parent accounts. `statements.json` groups them by code range,
  the same way the British and Australian packs do, because there is no legal
  code to group by instead.
- **No tax-clearing account of any kind.** Every other pack in this
  repository carries an account or two for output tax collected and input tax
  paid; this chart has none, because there is no tax a sale or a purchase ever
  collects or pays. That absence is the chart's most Hong Kong-specific fact.
- **The accounts a Hong Kong bookkeeper actually reaches for**: Mandatory
  Provident Fund contributions payable — every employer has to run one for
  its staff — provisional profits tax paid and profits tax recoverable, a
  provision for profits tax, and business registration and licence fees as
  their own line, rather than folded into "other expenses".

104 accounts, all postable except the parents `statements.json` groups by
range. None of them was copied from a published chart, and no commercial
package's chart was used as a model.

## Taxes, and the absence they represent

**Two codes, both at 0 %, both `not_subject`.** `HK-S-NA` on every sale and
`HK-P-NA` on every purchase — domestic, exported, imported, it makes no
difference, because there is no turnover tax to apply differently to any of
them. Hong Kong Trade and public sources agree on the fact this pack rests on:
Hong Kong has never levied a value added tax, a goods and services tax or a
general tax on the sale of goods or the supply of services, and a proposal for
one, put to a five-month public consultation in 2006, was withdrawn. What a
Hong Kong business pays instead is profits tax, on the whole year's net
profit, assessed once, under the Inland Revenue Ordinance, section 14 — not a
tax any invoice line carries, collects or is credited against.

**No exemption code, no VATEX.** `vat_category` is `O`, outside the scope of
any tax the EN 16931 category list has a letter for, and `exemption_code`
stays null on both codes: the VATEX list names articles of Directive
2006/112/EC, which does not reach a Hong Kong seller, so there is no article
for the field to cite.

**No dutiable-commodities module.** Hong Kong is a free port under Basic Law,
article 114, and charges no customs tariff — but the Dutiable Commodities
Ordinance (Cap. 109) does charge excise duty on four commodities: liquor,
tobacco, hydrocarbon oil and methyl alcohol. That is a duty on those specific
goods, not a general transaction tax any invoice line can carry a code for,
and this pack does not model it — the same way no VAT pack in this repository
models the excise duty on alcohol or tobacco its own country also charges
beside VAT.

## No declaration form: `tax_report.json` does not exist

This is the finding the pack exists to produce, and it is written up in full,
with the exact assertions it breaks and why, in
[`docs/international.md`](../../docs/international.md) under "From Hong
Kong". In short: `docs/packs.md` already says a pack declares a periodic
return only where its country files one ("If the pack declares a periodic
return, name `tax_payable`" — a conditional, not a requirement), and the core
function `vat_return()` already has a documented branch for a country with no
row in `tax_report_templates` at all: it returns the ledger's own boxes and no
total, gracefully, because none of this pack's postings name a box for it to
find. What had not caught up, until this pack found it, was two assertions of
the shared test suite that assumed every pack in this repository has always
had a real return to file: `tests/tax_report.test.ts`'s "accepts the packs of
this repository as they are" read `pack.report!.boxes` on a pack whose
`report` is `null`, and `tests/golden.test.ts`'s "exercises both directions,
more than one rate, and a credit note" asserted `rates.size` is greater than
one, which no scenario of an honestly-priced Hong Kong pack can ever satisfy.
Both are documented in full, with the fix each got, in
`docs/international.md`; this pack does not invent a tax rate to make either
one green.

`tax_payable` and `tax_receivable` are correspondingly left out of
`defaults.roles`: there is no filed declaration for either to carry the net
of.

## The statements

`statements.json` carries the statement of financial position and the income
statement a company reporting under SME-FRS presents, current and non-current
assets and liabilities, no revaluation reserve — SME-FRS keeps property, plant
and equipment at cost — and **no statement of comprehensive income**: SME-FRS
carries no item of other comprehensive income under its own measurement rules,
so nothing would ever print below the profit for the year, and the standard
asks for an income statement and not the second, wider statement. `xbrl` is
null throughout: Hong Kong has no iXBRL filing regime for private-company
accounts of the kind this repository's `xbrl` key would otherwise verify
against — see "What this pack does not carry".

## Closing the year

`fiscal_year_default` is `april`: no statute fixes a Hong Kong company's
accounting reference date, and a company is free to choose any year end at
all. `april` is declared because a great many Hong Kong SMEs align their books
with the government's own year of assessment, 1 April to 31 March, for
administrative convenience — a convention this pack states as one, not a rule
it found in a text; a large share of Hong Kong companies, particularly ones
with an overseas parent, close on 31 December instead.

`closing_style` is `retained_earnings`: SME-FRS's statement of financial
position carries no current-year-result line of the French or Belgian kind,
so the result goes straight to `3200 Retained profits`.

## On the invoice

**Numbering is `free`.** No Hong Kong statute conditions anything on an
invoice number, because no Hong Kong statute is a VAT-invoicing statute. What
every business has to do instead is keep sufficient records — in English or
Chinese, for not less than seven years — to have its assessable profits
readily ascertained (Inland Revenue Ordinance, s. 51C), on pain of a fine of
up to $100,000; that is a duty about what is kept, not about how a document
already issued is numbered.

**No payment term and no late-payment interest.** No Hong Kong statute sets
either. The United Kingdom's Late Payment of Commercial Debts (Interest) Act
1998, which several other packs of this repository cite, was never extended
to Hong Kong.

**One mention: the Business Registration Number.** Every person carrying on a
business has to register within one month of starting and to display the
certificate (Business Registration Ordinance, Cap. 310); the ordinance does
not itself require the number on an invoice, so this pack states the mention
as ordinary commercial practice and not as a numbering rule — see "From Hong
Kong" for what that distinction is doing in a field the format built for a
VAT country.

**`tax_point` is `invoice_date`, and it is a convention here, not a rule.**
The field names the day a country's general rule makes its own turnover tax
chargeable. Hong Kong has no such tax and no such rule; `invoice_date` is
declared as the closest general commercial convention, not read from a text —
another gap "From Hong Kong" sets out.

## Electronic invoicing

`obligation` is `none` and `profile` is null: no statute obliges a Hong Kong
business to send or accept an electronic invoice, and no Peppol Authority is
listed for Hong Kong — unlike Singapore's InvoiceNow or Australia and New
Zealand's PINT A-NZ, Hong Kong has not joined the network as of this pack's
writing. `party_scheme` and `vat_scheme` are null for the same reason as the
rest of this pack: there is no VAT identifier for either to carry.

## What this pack does not carry

- **Profits tax as a module.** The two-tiered rates (8.25 % / 16.5 % for a
  corporation, 7.5 % / 15 % for an unincorporated business, on the first and
  the remaining assessable profits over $2,000,000, Inland Revenue
  (Amendment) (No. 3) Ordinance 2018, from the year of assessment 2018/19) are
  cited here and in the source register for context only. Profits tax is
  charged once a year on the whole business's net profit after a computation
  this pack's ledger does not attempt — allowances, adjustments, the
  distinction between a capital and a trading receipt — and it is not a tax
  any invoice line, base or box in this repository's sense could carry.
  `2060 Provision for Hong Kong profits tax` and `6470 Hong Kong profits tax
  charge` exist so a company can book the year end provision; nothing computes
  it.
- **Stamp duty**, on the transfer of shares or Hong Kong immovable property:
  a duty on specific documents and transactions, not a general transaction
  tax.
- **Dutiable-commodities excise** on liquor, tobacco, hydrocarbon oil and
  methyl alcohol — see "Taxes, and the absence they represent".
- **Salaries tax and the Mandatory Provident Fund as a payroll module.** The
  chart carries the accounts a payroll would post to; nothing computes a
  payroll.
- **`assets.json`.** No fixed-asset depreciation module: this pack could not
  verify a Hong Kong accounting convention for useful lives distinct from the
  Inland Revenue Department's own depreciation allowances, which are a tax
  computation and not an accounting one, and declined to invent a table.
- **XBRL fact keys**, on either statement: not attached to any taxonomy this
  pack could verify.
- **Bank formats.** No statement format is declared.

## Reviewing this pack

Open an issue titled "Review: Hong Kong". What a review is, and what it is
not, is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and
who may say what". Points a CPA, a company secretary or a solicitor should
read first:

1. **The exact sections of Companies Ordinance (Cap. 622), Part 9** this pack
   cites at the Part level rather than by subsection — the duty to prepare
   true and fair financial statements, the directors' report, the auditor's
   report, and the SME-FRF's own size-test figures, which this pack believes
   are two of three of revenue, total assets and employees each not exceeding
   $100 million / $100 million / 100, increased by the Companies (Amendment)
   Ordinance 2018, but did not re-verify against the primary text in this
   session. See "Sources".
2. **Whether `fiscal_year_default: april` is the right convention to
   propose**, against `calendar`, given how common a 31 December year end
   also is among Hong Kong companies with an overseas parent.
3. **The chart's grouping of MPF, provisional profits tax and the profits tax
   provision** into "trade and other payables" and "current tax liabilities"
   respectively, against how a Hong Kong CPA firm's working papers actually
   split them.
4. **Whether a Peppol Authority for Hong Kong has since been announced.** This
   pack's `obligation: none` and empty `profile` reflect what this pack's
   author found in September 2026; e-invoicing policy moves faster than a
   community pack is re-read.
5. **The two socle gaps** under "From Hong Kong" in `docs/international.md` —
   whether the fix each proposes is the right one, before anybody applies it.
