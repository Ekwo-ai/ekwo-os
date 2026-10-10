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
[`i18n/README.md`](i18n/README.md).

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds eleven texts.

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

`einvoice.nat.gov.tw` blocks automated requests, so `ekwo pack check tw
--links` reports it unreachable; the platform's role is stated in
電子發票實施作業要點.

## The chart of accounts

**Taiwan has an official, coded chart.** 商業會計項目表, issued under article
27 of the Business Accounting Act, gives a four-to-six-digit code, a Chinese
name and an official English name to every item a business's books might
carry. Article 27 itself says a business may add to or reduce its accounting
items as actually needed (「商業得視實際需要增減之」), which is the license
this chart's abridgement rests on: every code, every Chinese name and every
English name in `accounts.csv` is transcribed unabridged from the official
table — nothing renamed, nothing renumbered — and the table's several hundred
items for hedge accounting, biological assets, construction contracts and
fair-value-through-other-comprehensive-income instruments are simply not
copied in. 130 accounts, flat (no `parent`): `statements.json` groups them by
code range, the way the table itself groups its own level-one and level-two
items.

**The one account this table does not provide** is `6135`, a rounding
account: form 401 prints every box in whole New Taiwan dollars
("金額單位：新臺幣元") over a ledger kept to the cent, and
`defaults.roles.rounding` needs a code the official table has no reason to
carry. It is the only invented line of this chart.

**Four tax control accounts are the table's own**: `1268 進項稅額` (input
tax) and `1269 留抵稅額` (the tax credit carried forward) on the asset side;
`2194 應付營業稅` (business tax payable) and `2204 銷項稅額` (output tax) on
the liability side.

## Taxes

**One positive rate: 5%.** Article 10 lets the Executive Yuan set the rate of
a general-method taxpayer anywhere from 5% to 10%, and it has stood at 5%
since the value-added system itself took effect on 1 April 1986 (Ministry of
Finance, 財政史料陳列室 archive). A reviewer should confirm no intervening
Executive Yuan order has changed it.

**Higher rates exist, and none of them is this pack's `TW-S-5`.** Articles
11 to 13 tax a bank's or an insurer's core business at 2% or 5% on gross
receipts, a nightclub or a themed restaurant at 15%, a hostess bar or a tea
room offering companionship at 25%, and a small-scale entity at 1% (or 0.1%
for a wholesale agricultural consignee) — each a different taxpayer
classification filed on a different form, none modelled here.

**Services bought from a foreign entity (article 36).** A software
subscription, hosting or an API sold by a foreign enterprise with no fixed
place of business in Taiwan puts the business tax on the purchaser, who
computes it on the payment and pays it by the 15th of the following period —
*except* a general-method taxpayer whose purchased services are used solely
for its taxable business, which is exempted and books such a purchase with
no tax code. `TW-P-36-5-NC` carries the case where the tax is due: 5 % paid
on its own, outside form 401 (whose box 74, 購買國外勞務, is a memo line), a
cost of the line (`tax_on_base`) and a liability on `2195` 應付稅捐－其他. A
business that also makes exempt supplies pays the proportion the Ministry of
Finance determines, whose formula is not sourced here: the
line then carries that payable share, computed by the bookkeeper. A foreign
supplier sits on `2171` 應付帳款 with the others.

**The zero rate keeps the deduction; an exemption does not.** Article 7
zero-rates the export of goods (`TW-S-0-GOODS`) and, on a separate item, a
service related to export or used abroad (`TW-S-0-SVC`) — kept apart because
they answer two different items of one article, even though they post to the
same boxes. Article 8 exempts a closed list outright (`TW-S-EXO-LAND` for
land, `TW-S-EXO-FIN` for the financial and insurance operations of a licensed
business).

**Form 401 is the return of a taxpayer with no exempt sale that period, and
this pack's exempt codes carry no box for exactly that reason.** The form's
own printed note says so: 「本申報書適用專營應稅及零稅率之營業人填報。如營業
人申報當期（月）之銷售額包括有免稅、特種稅額計算銷售額者，請改用（403）申報
書申報。」— a taxpayer whose period includes an exempt or special-tax-
calculation sale files form 403 instead. The exempt codes carry their invoice
treatment, EN 16931 category and legal reference, and name no box of
`TW-401`; form 403 is not modelled (see "What this pack does not carry").

**Deduction, and the two columns form 401 keeps apart.** A purchase of
ordinary goods or expenses (`TW-P-5`) posts to the 進貨及費用 column, boxes
44 and 45; a purchase of a fixed asset (`TW-P-5-FA`) posts to the 固定資產
column, boxes 46 and 47 — kept apart because the deduction total (box 107)
and the refund cap (box 113) are both worked out from the two columns added
together. Article 19 denies the deduction on an entertainment purchase or one
that benefits an employee personally (`TW-P-5-NC`): the tax lands on the cost
of the line as a `tax_on_base` posting, and reaches no box.

**An import is assessed and paid at Customs, not invoiced by the supplier.**
Article 41 has Customs levy the business tax at clearance, and article 15
lets the importer deduct it on the strength of the customs tax payment
certificate (海關代徵營業稅繳納證). `TW-P-IMP-5` books the deductible tax at
boxes 44/45, and a second `tax` posting at `factor: -100` carries it to
`2195`, the account kept for a tax owed to somebody who is not the seller.
Form 401's further breakdown of boxes 44/45 by voucher type is not modelled:
the ledger records no fact about which physical document backs a deduction.

**Two codes carry no tax at all**: `TW-P-EXO` for a purchase from a supplier
who charges none (an exempt business, or a small-scale entity), and `TW-P-NA`
— the counterpart of `TW-S-NA` — for an outlay that is not consideration for
a supply, such as a statutory duty paid to the tax authority.

## The return

`TW-401` is 營業人銷售額與稅額申報書（401）, the general tax calculation
method form — fifteen boxes, read from the government's own PDF.

- **Filed every two months, within fifteen days.** Article 35 makes the
  bimonthly period the rule and lets a taxpayer that sells only at the zero
  rate ask to file monthly instead; this pack proposes `bimonth`.
- **A box printed twice.** Box 101 (本期銷項稅額合計) carries the same figure
  as box 22, so both are named on the one `tax` posting of `TW-S-5`. Box 107
  (得扣抵進項稅額合計) is a genuine total: 45+47.
- **The prior period's credit is not carried in.** Box 110 (小計) is printed
  as 7+8 — this period's deductible tax (box 107) plus the credit carried in
  from the previous period's return (box 108). Box 108 is not a fact this
  period's ledger holds, so this pack declares box 110 as box 107 alone and
  leaves box 108 undeclared; boxes 111 and 112 are computed from that
  subtotal, which understates a carried-forward credit by exactly what box
  108 would have added.
- **Box 113 is a rate of one box plus another box.** The refund cap
  (得退稅限額合計) is printed as ③×5%+⑩, which the format cannot say in one
  line. A hidden working box, `TWZR5`, carries the rate alone, and box 113 is
  declared as the sum of `TWZR5` and box 110.
- **Boxes 114 and 115 are not computed.** Box 114 (本期應退稅額) is the lesser
  of boxes 112 and 113, and the format has no minimum operator; both are left
  undeclared and a reader compares 112 and 113 by hand.
- **Two memo boxes are not used**: box 73 (進口免稅貨物) and box 74
  (購買國外勞務) feed no total and no tax code posts to them.

## The statements

`TW-BAA-BS` and `TW-BAA-IS` are the balance sheet and the income statement
商業會計處理準則 articles 14 and 32 prescribe — current and non-current
assets and liabilities, share capital, capital surplus, retained earnings
(or an accumulated deficit) and treasury shares on one side; operating
revenue, operating costs, operating expenses, non-operating income and
expense, and income tax expense on the other, down to the net profit or loss
of the period. Article 32's list also carries continuing and discontinued
operations and other comprehensive income, which this chart has no line for
and this statement does not print.

**One income-statement line nets income against expense, because the article
prints it that way.** Article 32 item 4, 「營業外收益及費損」, is one line for
non-operating income and expense together, and the official chart does not
split cleanly by `account_type` either: `7151` (interest expense) and `7182`
(foreign exchange loss) sit in the same 71xx range as their income
counterparts. One `code_range` line over 71–72 prints a net expense positive
and a net gain negative — what `NI` then subtracts.

No `xbrl` key on either statement: nothing was verified against a filing
taxonomy.

## Closing the year

`fiscal_year_default` is `calendar`: 所得稅法 article 23 makes the calendar
year the accounting year of every business, departing from it only with the
tax authority's approval.

`closing_style` is `retained_earnings`: article 14 of 商業會計處理準則 lists
「保留盈餘（或累積虧損）」as one equity item, with no separate line for the
current year's result — the result closes straight to `3351 累積盈虧`.

## On the invoice

**Numbering is allocated by the state, not chosen by the business.**
統一發票使用辦法 gives a uniform invoice's number two letters (字軌) and eight
digits, and the tax authority allocates the letters and the ranges within
them, separately for each two-month filing period. `numbering: "gapless"` is
the closer of the format's two words (no hole is tolerated inside an
allocated range), but no value in the schema says the range itself is handed
to the business each period — see [what the packs do not say
yet](../../docs/international.md#what-the-packs-do-not-say-yet).

**No statutory payment term, and no statutory late-payment interest** was
found fixing either in the absence of an agreement; `legal_payment_days` and
`late_payment_reference` are both null.

**`tax_point` is `invoice_date`.** Article 32, paragraph 1 has a business
issue a uniform invoice when the tax obligation arises under article 16 — in
principle the day the goods are delivered or the service is completed — and
article 33 conditions the buyer's deduction on holding that invoice. The
closed list of deferred-issuance arrangements article 32 carries is not
modelled separately.

**Two mentions, one for the zero rate and one for an exemption**, each
citing the article of the Business Tax Act that grants it.

## Electronic invoicing

`profile` is null and `obligation` is `none` — a null answer to a
European-shaped question, not a statement that Taiwan has little electronic
invoicing: the opposite is true. No Peppol Authority is registered for
Taiwan and no EN 16931 profile applies, because Taiwan's own system, 電子發票
(the electronic Government Uniform Invoice, eGUI), is a government-run
clearance platform (財政部電子發票整合服務平台): the seller submits the
invoice, the platform numbers it out of the state-allocated 字軌 range,
records it for both parties' tax filings and enters it into the national
invoice lottery. The format has no field for a state party taking part in
the issuance itself; see [what the packs do not say
yet](../../docs/international.md#what-the-packs-do-not-say-yet).

## What this pack does not carry

- **The special-rate regimes of articles 11 to 13** — a different taxpayer
  classification filed on a different form (403 or a simplified
  assessment), none a rate a general-method taxpayer applies.
- **Form 403**, the return for a taxpayer whose sales are not exclusively
  taxable and zero-rated: its box layout was not confirmed against an
  official Ministry of Finance publication.
- **The small-scale entity threshold's two figures**, NT$100,000 a month for
  goods and NT$50,000 for services, raised from 1 January 2025 under article
  26 — cited in the register, not modelled, since there is no small-scale
  tax code.
- **The Ministry of Finance's proportion under article 36** for a business
  that concurrently makes exempt supplies: `TW-P-36-5-NC` (above, *Services
  bought from a foreign entity*) takes the amount it is given, and the share
  is the bookkeeper's to compute; for the same reason the golden year, whose
  company sells exempt land, buys no such service.
- **Fixed-asset depreciation (`assets.json`)**: the Ministry of Finance's
  useful-life schedules are a tax computation, not an accounting convention,
  and no accounting table was invented.
- **Bank formats.** No statement format is declared.
- **Excise duties** — 菸酒稅, 貨物稅, 特種貨物及勞務稅 — owed on specific
  goods beside business tax, not on turnover.

## Reviewing this pack

Open an issue titled "Review: Taiwan". What a review is, and what it is not,
is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who
may say what". Points a Taiwanese accountant or a 記帳士／會計師 should read
first:

1. **Whether the 5% rate has held without interruption since 1 April 1986.**
2. **The chart's abridgement of 商業會計項目表** — whether the hundred and
   thirty items kept are the ones a general trading company's books actually
   need.
3. **The boxes this pack could not compute** — 108 (the prior period's
   carried-forward credit) and 114/115 (the lesser of two boxes) — against
   what a Taiwanese practice does to keep a company's running credit balance
   correct period to period.
4. **Whether `TW-S-EXO-FIN` and the article 36 gap are read correctly**,
   and whether a company would in practice ever file form 401 once an exempt
   sale, however occasional, enters a period.
5. **The numbering finding under "On the invoice"** — whether `gapless` is
   the least misleading of the format's two words for a number range the
   state, not the business, allocates.
