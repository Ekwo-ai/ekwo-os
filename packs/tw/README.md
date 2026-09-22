# Taiwan

Everything Taiwan adds to Ekwo, as data: a chart of accounts, the journals,
the value-added business tax (加值型營業稅) and where each code posts, the
general-method return (form 401) and its boxes, the balance sheet and the
income statement of the Business Accounting Act, and the two sentences the
law puts on an invoice. The format is [`docs/packs.md`](../../docs/packs.md);
this file says where the content came from and which decisions it rests on,
so that a Taiwanese accountant reading the pack can disagree with a specific
sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Taiwanese business tax return has
reviewed it. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**This pack is written in Traditional Chinese** (`defaults.language: "zh"`),
the language of the Business Tax Act, the Business Accounting Act and form
401; `i18n/en.json` gives all of it in English, official where an official
English wording exists and this pack's own translation everywhere else — see
[`i18n/README.md`](i18n/README.md). What the core could not say is written up
in [`docs/international.md`](../../docs/international.md) under "From
Taiwan". None of it was patched for this pack's sake.

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds eleven texts, all opened on 22 September 2026.

| What | Text | Where |
|---|---|---|
| The tax, its rate, the zero rate, exemptions, deduction, imports, the general-method return | 加值型及非加值型營業稅法 (Business Tax Act) | `law.moj.gov.tw`, ELI `pcode=G0340080` |
| The accounting year | 所得稅法 (Income Tax Act), article 23 | `law.moj.gov.tw`, `pcode=G0340003` |
| That an accounting item may be added to or reduced as actually needed | 商業會計法 (Business Accounting Act), article 27 | `law.moj.gov.tw`, `pcode=J0080009` |
| The balance sheet (article 14) and the income statement (article 32) | 商業會計處理準則 (Regulations Governing Business Entity Accounting Handling) | `law.moj.gov.tw`, `pcode=J0080010` |
| The chart of accounts itself, code by code | 商業會計項目表（112年度及以後適用版本） | `gcis.nat.gov.tw/F/t70492_p` |
| The boxes of the return, read from the printed form | 營業人銷售額與稅額申報書（401、403及404）A4格式 | `etax.nat.gov.tw`, PDF form |
| The numbering of a uniform invoice, by an administratively-allocated 字軌 and range | 統一發票使用辦法 (Uniform Invoice Using Method) | `law.moj.gov.tw`, `pcode=G0340082` |
| Electronic uniform invoices, defined and how they are transmitted | 電子發票實施作業要點 | `law-out.mof.gov.tw`, `id=FL041411` |
| Where the government's own electronic-invoice platform sits | 財政部電子發票整合服務平台 | `einvoice.nat.gov.tw` |
| The small-scale entity threshold, raised from 1 January 2025 | 財政部稅務入口網公告 | `etax.nat.gov.tw` |
| Where the return is filed | 財政部稅務入口網 | `etax.nat.gov.tw` |

Form 401 itself is a fillable PDF rather than a text page; this pack read it
by downloading and parsing it programmatically (the government's own posted
copy), not by a printed facsimile someone else typed up. The 商業會計項目表
runs to several hundred items over forty-two pages, of which this chart
transcribes a working subset — see "The chart of accounts" below.
`einvoice.nat.gov.tw` itself returns HTTP 403 to a request with no browser
behind it (`ekwo pack check tw --links` records it), the way `packs/hk/`'s
own `elegislation.gov.hk` does; its identity and its role are corroborated
by 電子發票實施作業要點, which names the platform in the text this pack did
read, rather than by rendering the platform's own home page.

## The chart of accounts

**Taiwan does have an official, coded chart** — unlike `packs/jp/`,
`packs/hk/` or `packs/sg/`, each written from scratch because their own
countries prescribe none. 商業會計項目表, issued under article 27 of the
Business Accounting Act, gives a four-to-six-digit code, a Chinese name and
an official English name to every item a business's books might carry, from
`1111 庫存現金 Cash on hand` to instruments no company this pack's golden
year needs. Article 27 itself says a business may add to or reduce its
accounting items as actually needed (「商業得視實際需要增減之」), which is the
license this chart's abridgement rests on: every code, every Chinese name and
every English name in `accounts.csv` is transcribed unabridged from the
official table — nothing renamed, nothing renumbered — and the table's
several hundred items for hedge accounting, biological assets, construction
contracts and fair-value-through-other-comprehensive-income instruments this
pack's companies do not need are simply not copied in. 130 accounts, flat (no
`parent`): `statements.json` groups them by code range, the way the table
itself already groups its own level-one and level-two items.

**The one account this table does not provide** is `6135`, a rounding
account: form 401's own header prints every box in whole New Taiwan dollars
("金額單位：新臺幣元") over a ledger this pack still keeps to the cent (the
New Taiwan dollar carries two decimals at ISO 4217, whatever a shop's cash
register rounds a total to), and `defaults.roles.rounding` needs a code the
official table has no reason to carry. It is the only invented line of this
chart, and it is named as such here.

**Two tax control accounts are the table's own**: `1268 進項稅額` (input
tax, or business tax paid) and `1269 留抵稅額` (the tax credit carried
forward, or excess business tax paid) on the asset side; `2194 應付營業稅`
(business tax payable) and `2204 銷項稅額` (output tax, or business tax
received) on the liability side — the table names all four for exactly the
purpose this pack puts them to.

## Taxes

**One positive rate: 5%.** Article 10 lets the Executive Yuan set the rate of
a general-method taxpayer anywhere from 5% to 10%, and it has stood at 5%
since the value-added system itself took effect on 1 April 1986 (Ministry of
Finance, 財政史料陳列室 archive); this pack has not traced every Executive
Yuan order since then confirming no intervening change, and a reviewer should
hold `TW-S-5`'s rate against the Ministry's own table before relying on it
for a period this pack's release predates. `tests/golden.test.ts`'s own
assertion that a golden scenario exercises "more than one rate" is gated on a
pack that has one to exercise (the fix `packs/hk/README.md` records under
"From Hong Kong"); Taiwan's general method genuinely has one rate, and this
pack is not asked to invent a second.

**Higher rates exist, and none of them is this pack's `TW-S-5`.** Articles
11 to 13 tax a bank's or an insurer's core business at 2% or 5% on gross
receipts rather than value added, a nightclub or a themed restaurant at 15%,
a hostess bar or a tea room offering companionship at 25%, and a small-scale
entity under the article 13 threshold at 1% (or 0.1% for a wholesale
agricultural consignee) — none deducts input tax the way a general-method
taxpayer does, each is a different taxpayer classification filed on a
different form, and none is modelled here. See "What this pack does not
carry".

**The zero rate keeps the deduction; an exemption does not.** Article 7
zero-rates the export of goods (`TW-S-0-GOODS`) and, on a separate item, a
service related to export or a service supplied within Taiwan but used
abroad (`TW-S-0-SVC`) — kept apart the way `packs/jp/` keeps its own
export-of-goods and export-of-services codes apart, because they answer two
different items of one article even though they post to the same boxes.
Article 8 exempts a long, closed list outright (`TW-S-EXO-LAND` for land,
`TW-S-EXO-FIN` for the financial and insurance operations of a licensed
business); the two behave differently on the ledger side by nothing this
pack computes — the difference is entirely in whether form 401 can be filed
at all that period, which is the next paragraph.

**Form 401 is the return of a taxpayer with no exempt sale that period, and
this pack's exempt codes carry no box for exactly that reason.** The form's
own printed note says so: 「本申報書適用專營應稅及零稅率之營業人填報。如營業
人申報當期（月）之銷售額包括有免稅、特種稅額計算銷售額者，請改用（403）申報
書申報。」— a taxpayer whose period includes an exempt or special-tax-
calculation sale files form 403 instead. This pack carries `TW-S-EXO-LAND`
and `TW-S-EXO-FIN` for their invoice treatment, their EN 16931 category and
their legal reference — a company still needs to book an exempt sale
correctly whichever form the period is filed on — and their `base` posting
names no box of `TW-401`, because form 403's own box layout could not be
confirmed against an official Ministry of Finance publication (only a
reproduction of unclear provenance was found). See "What this pack does not
carry".

**Deduction, and the two columns form 401 keeps apart.** A purchase of
ordinary goods or expenses (`TW-P-5`) posts to the 進貨及費用 column, boxes
44 and 45; a purchase of a fixed asset (`TW-P-5-FA`) posts to the 固定資產
column, boxes 46 and 47 — kept apart because the deduction total (box 107)
and the refund cap (box 113) are both worked out from the two columns added
together, and the printed form itself never merges them into one. Article 19
denies the deduction on an entertainment purchase or one that benefits an
employee personally (`TW-P-5-NC`): the tax is not carried on the deductible
input-tax account at all, but lands on the cost of the line as a
`tax_on_base` posting, and reaches no box.

**An import is assessed and paid at Customs, not invoiced by the supplier.**
Article 41 has Customs levy the business tax on an imported good at
clearance, under the Customs Act, and article 15 still lets the importer
deduct it once paid — on the strength of the customs authority's own tax
payment certificate (海關代徵營業稅繳納證) rather than a uniform invoice.
`TW-P-IMP-5` books the deductible tax the way `TW-P-5` does, at the same
boxes 44/45, and a second `tax` posting at `factor: -100` removes it from
what is owed to the supplier and carries it to `2195`, the account this
pack's chart keeps for a tax owed to somebody who is not the seller. Form 401
keeps a further breakdown of boxes 44/45 by voucher type — 三聯式發票,
二聯式發票, 載有稅額之其他憑證, 海關代徵營業稅繳納證 each have their own pair
of boxes on the printed form — which this pack does not model: the ledger
has no fact recording which physical document backs a deduction, only the
tax code and the account, and every code that reaches boxes 44/45 in this
pack reaches the same pair regardless.

**Two codes round out the postings that carry no tax at all**: `TW-P-EXO`
for a purchase from a supplier who charges none (an exempt business, or a
small-scale entity under the 1% method), and `TW-P-NA` — the purchase-side
counterpart of `TW-S-NA` — for an outlay that is not consideration for a
supply of goods or services to begin with, such as a statutory duty paid
straight to the tax authority.

## The return

`TW-401` is 營業人銷售額與稅額申報書（401）, the general tax calculation
method form — fifteen boxes, read box by box from the government's own PDF
(parsed programmatically; see "Sources").

- **Filed every two months, within fifteen days.** Article 35 makes the
  bimonthly period (January–February, March–April, and so on) the rule for
  everybody and lets a taxpayer that sells only at the zero rate ask to file
  monthly instead, once approved and for at least a year; this pack proposes
  `bimonth` because that is the answer the article gives everybody, the way
  `packs/be/` and `packs/fr/` propose their own monthly rule for the same
  reason.
- **One rate, one box each side, and a box printed twice.** Box 101 (本期銷
  項稅額合計) carries the same figure as box 22 under its own code — the form
  prints the output tax total once under a circled mark and once under a
  three-digit code the calculation section reads — so both boxes are named
  on the one `tax` posting of `TW-S-5`, on the pattern `docs/packs.md`
  describes for the Estonian KMD's box 6.1/6/1. Box 107 (得扣抵進項稅額合計)
  is a genuine total: 45+47, the two purchase columns added together.
- **The prior period's credit is not carried in, and this pack says so on
  the box rather than inventing a figure.** Box 110 (小計) is printed as
  7+8 — this period's deductible tax (box 107) plus the credit carried in
  from the *previous* period's own return (box 108). `vat_return()`
  evaluates one period at a time, from the ledger it replays, and box 108 is
  not a fact that period's ledger holds — it is what a different return, for
  a different period, already came to. This pack declares box 110 as box 107
  alone and leaves box 108 undeclared, the gap `packs/gq/README.md` already
  names for its own box 027; downstream, boxes 111 and 112 (tax payable and
  credit reported this period) are computed honestly from that incomplete
  subtotal, which understates a company's carried-forward credit exactly as
  much as box 108 would have added to it.
- **A box that is a rate of one box plus another box, which this format
  cannot say in one line.** Box 113 (得退稅限額合計), the refund a zero-rated
  exporter may claim, is printed as ③×5%+⑩ — a percentage of the zero-rated
  sales base *and* another box added on, on the same line. `docs/packs.md`
  is explicit that a box takes a rate applied to one other box, or a
  plus/minus list, never both together. This pack adds one working box,
  `TWZR5`, `hidden: true`, carrying the rate alone — the same device
  `packs/jp/` already uses for its own local-tax share — so that box 113
  can still be declared as the sum of `TWZR5` and box 110.
- **A box this pack does not compute at all: 應退稅額, the lesser of two
  others.** Box 114 (本期應退稅額) is printed "如12>13則為13，13>12則為12" —
  whichever of box 112 and box 113 is the smaller — and box 115 depends on
  it in turn. Nothing in `tax_report_box`'s vocabulary (`plus`, `minus`,
  `rate`/`rate_of`, `floor_zero`) computes a minimum of two boxes; this pack
  leaves both undeclared rather than approximate one, and a reader compares
  112 and 113 by hand. Unlike box 108's gap, this is not a fact the ledger
  is missing — it is an operator the format does not have.
- **Two memo boxes this pack does not use at all**: box 73 (進口免稅貨物,
  the value of duty-free imports) and box 74 (購買國外勞務, the value of
  services purchased from abroad) are informational lines the form carries
  beside the tax calculation and feed no total this pack computes; no tax
  code of this pack posts to either.

## The statements

`TW-BAA-BS` and `TW-BAA-IS` are the balance sheet and the income statement
商業會計處理準則 articles 14 and 32 prescribe — current and non-current
assets and liabilities, share capital, capital surplus, retained earnings
(or an accumulated deficit) and treasury shares on one side; operating
revenue, operating costs, operating expenses, non-operating income and
expense, and income tax expense on the other, down to the net profit or loss
of the period. Article 32's own list also carries continuing and
discontinued operations and other comprehensive income, which this chart's
130 accounts have no line for and this statement does not print.

**One income-statement line nets an income type against an expense type,
because the article prints it that way.** Article 32 item 4,
「營業外收益及費損」, is one line for non-operating income *and* expense
together, not two — and the official chart itself will not split cleanly by
`account_type` either: `7151` (interest expense) and `7182` (foreign
exchange loss) sit inside the same 71xx range as their income counterparts
on the government's own table. This statement keeps the article's own
shape: one `code_range` line over 71–72, its sign read so that a net expense
prints positive and a net non-operating gain prints negative — what `NI`
below then subtracts.

No `xbrl` key on either statement: nothing was verified against a filing
taxonomy.

## Closing the year

`fiscal_year_default` is `calendar`: 所得稅法 article 23 makes the calendar
year (1 January to 31 December) the accounting year of every business,
departing from it only with the tax authority's approval for an established
custom or a seasonal business.

`closing_style` is `retained_earnings`: article 14 of 商業會計處理準則 lists
「保留盈餘（或累積虧損）」as one equity item, with no separate line for the
current year's own result the way `packs/fr/`'s 120/129 or `packs/be/`'s
693/793 carry — the result closes straight to `3351 累積盈虧`, the official
table's own account for it.

## On the invoice

**Numbering is administratively allocated, not chosen by the business, and
this format's vocabulary only reaches part of that.** 統一發票使用辦法 gives
a uniform invoice's number two letters (字軌, a "word-rail" prefix) and eight
digits, and the tax authority — not the business — allocates the letters and
the ranges of numbers within them, separately for each two-month filing
period. `numbering: "gapless"` is the closer of the format's two words (no
hole is tolerated inside an allocated range), but no value in the schema
says "the range itself is handed to the business by the state each period",
which is a stronger fact than any country's `gapless_per_year` describes —
Belgium's or France's own numbering is at least a sequence the business
itself keeps unbroken. This is written up under "From Taiwan" in
`docs/international.md`.

**No statutory payment term, and no statutory late-payment interest.** No
provision of the Business Tax Act or of the general civil law was found
fixing either in the absence of an agreement between the parties, the way
`packs/be/` cites its own 2002 act; `legal_payment_days` and
`late_payment_reference` are both left null rather than guessed.

**`tax_point` is `invoice_date`.** Article 32, paragraph 1 has a business
entity issue a uniform invoice at the time the tax obligation arises under
article 16 — in principle the day the goods are delivered or the service is
completed — and article 33 conditions the buyer's own deduction on holding
that invoice; in practice a general-method taxpayer's invoice date and its
tax point coincide on the occasion the law requires the invoice for, outside
the closed list of deferred-issuance arrangements (deferred-payment sales,
certain transport and utility trades) article 32 itself carries and this
pack does not model separately.

**Two mentions, one for the zero rate and one for an exemption**, each
citing the article of the Business Tax Act that grants it.

## Electronic invoicing

`profile` is null and `obligation` is `none` — a null reading of a European-
shaped question and not a statement that Taiwan has little electronic
invoicing: the opposite is true. No Peppol Authority is registered for
Taiwan and no EN 16931 profile — `peppol-bis-3`, `factur-x-en16931`,
`xrechnung`, a PINT — applies here, because Taiwan's own system, 電子發票
(the electronic Government Uniform Invoice, eGUI), is not a bilateral
exchange format between a seller and a buyer's own systems at all: it is a
government-run clearance and authentication platform
(財政部電子發票整合服務平台) that a seller submits an invoice to, which
issues the invoice its own serial number out of the state-allocated 字軌
range, records it for the seller's and the buyer's own tax filings, and
enters every invoice's number into a nationwide consumer lottery
(統一發票夾) that has nothing resembling it in this format at all. None of
`einvoicing.profile`, `.obligation` or `.mandatory_from` was built to
describe a state party inserting itself into the invoice's own issuance
rather than merely receiving a copy of it, which is why this field reads
`none` on a country whose electronic-invoicing infrastructure is, by most
measures, more mature than several countries whose packs declare a Peppol
profile. Written up in full under "From Taiwan" in
[`docs/international.md`](../../docs/international.md).

## What this pack does not carry

- **The special-rate regimes of articles 11 to 13** — a bank's or an
  insurer's gross-receipts tax at 2% or 5%, a nightclub's or a themed
  restaurant's 15%, a hostess bar's or a tea room's 25%, a small-scale
  entity's 1% (or a wholesale agricultural consignee's 0.1%) — each a
  different taxpayer classification filed on a different form (403 or a
  simplified assessment), none a rate a general-method taxpayer such as this
  pack's golden company ever applies itself.
- **Form 403**, the return for a taxpayer whose sales are not exclusively
  taxable and zero-rated. Its box layout could not be confirmed against an
  official Ministry of Finance publication in this session; see "Taxes"
  above.
- **The small-scale entity threshold's own two figures**, NT$100,000 a
  month for the sale of goods and NT$50,000 for the sale of services,
  raised from 1 January 2025 under article 26 — cited for context in the
  source register, and not modelled, because this pack carries no
  small-scale tax code at all.
- **The pro-rata reverse charge of article 36** on a service bought from a
  foreign entity with no fixed place of business in Taiwan. A general-method
  taxpayer whose purchased services are used solely for its own taxable
  operations is exempt from the self-assessment article 36 otherwise
  imposes; one with a concurrent exempt operation owes it on a proportion
  "決定" (set) by the Ministry of Finance, whose formula this pack's
  research could not source. Rather than assume the wholly-taxable case —
  which the golden company's own exempt land sale would make inaccurate —
  this pack carries no code for article 36 at all. Form 401's own box 74
  (購買國外勞務) is the memo line such a purchase would otherwise be
  reported against.
- **Assets.json.** No fixed-asset depreciation module: this pack could not
  verify a Taiwanese accounting convention for useful lives distinct from
  the Ministry of Finance's own depreciation schedules for income-tax
  purposes, which are a tax computation and not an accounting one, and
  declined to invent a table.
- **Bank formats.** No statement format is declared.
- **Excise duties** — tobacco and alcohol tax (菸酒稅), the commodity tax
  (貨物稅) on a closed list of goods, the specifically-selected goods and
  services tax on luxury real estate (特種貨物及勞務稅) — are real duties a
  Taiwanese business may owe beside business tax, on specific goods rather
  than on turnover generally, the same way no VAT pack in this repository
  models the excise duty its own country also charges beside VAT.

## Reviewing this pack

Open an issue titled "Review: Taiwan". What a review is, and what it is not,
is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who
may say what". Points a Taiwanese accountant or a 記帳士／會計師 should read
first:

1. **Whether the 5% rate has held without interruption since 1 April 1986** —
   this pack cites the rate's own introduction and has not traced every
   Executive Yuan order since.
2. **The chart's abridgement of 商業會計項目表** — whether the hundred and
   thirty items kept are the ones a general trading company's books actually need,
   against the several hundred this pack left out.
3. **The boxes this pack could not compute** — 108 (the prior period's
   carried-forward credit) and 114/115 (the lesser of two boxes) — against
   whatever a Taiwanese practice actually does to keep a company's running
   credit balance correct period to period outside this pack's own figures.
4. **Whether `TW-S-EXO-FIN` and the article 36 gap are read correctly**,
   and whether a company this pack's community expects to install it for
   would in practice ever file form 401 at all once an exempt sale, however
   occasional, enters a period.
5. **The numbering finding under "On the invoice"** — whether `gapless` is
   the least misleading of the format's two words for a number range the
   state, not the business, allocates.
