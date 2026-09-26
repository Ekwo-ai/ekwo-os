# China

Everything the People's Republic of China adds to Ekwo, as data: a chart of
accounts from the Accounting Standards for Business Enterprises, the journals,
the value-added tax (增值税) of the VAT Law in force since 1 January 2026 and
where each code posts, the main table of the general taxpayer's VAT and
surcharges return, and the balance sheet (会企01表) and income statement
(会企02表) of the Ministry of Finance's 2019 formats. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Chinese accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Chinese VAT return has reviewed
it. The figures are replayed against a quarter of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**This pack is written in Simplified Chinese** (`defaults.language: "zh"`),
the language of every law, regulation, notice and form it transcribes;
`i18n/en.json` gives all of it in English. No administration publishes an
official English version of any of those texts, so every English label is this
pack's own translation — see [`i18n/README.md`](i18n/README.md). The language
code is the same `zh` the Taiwan pack uses for Traditional Chinese: the format
has a two-letter language and no script subtag, which is noted in
[`docs/international.md`](../../docs/international.md) under "From China".

## Ekwo does not issue a Chinese invoice

A Chinese invoice (发票) is not a document a seller's software produces. Since
1 December 2024 the fully digitalised electronic invoice (数电发票) is issued
nationwide on the tax authority's own electronic invoice service platform
(国家税务总局公告2024年第11号): the platform assigns its twenty-digit number,
grants each taxpayer a monthly invoicing limit, identifies the person issuing
it, delivers it to the buyer's tax digital account, and the buyer confirms
there which invoices it will deduct. A correction is a red-letter invoice,
issued on the same platform. It is a real-time clearance model of the State's,
and the pack format has no word for it: `einvoicing.obligation` is `none`
because no statute requires an EN 16931 or Peppol invoice between businesses,
which is the question that field asks.

What this means in practice: the invoice is issued on the platform (through
the electronic tax bureau, or a certified channel), and the document in Ekwo
is the booking of it. The number Ekwo gives a document is an internal
reference; the platform's invoice number is a fact to record beside it, and
the core has no field for it yet. Nor can Ekwo know which purchase invoices
the buyer has confirmed for deduction on the platform — the ones line 12 of
the return is built from — so the input tax of a period is the input tax
booked in it, and a company that confirms an invoice in a later month has to
date its booking accordingly.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and
beside it the key of the text that article is in. The register in `pack.json`
holds fifteen texts, all opened on 26 September 2026: the VAT Law and its
Implementing Regulations (国务院令第826号); the two notices that carry the
reliefs and their administration into 2026 (财政部 税务总局公告2026年第10号,
国家税务总局公告2026年第4号); the return (its page on the 12366 service
platform, 国家税务总局公告2021年第20号 which issued it, and 国家税务总局公告2026年第6号
which adjusted its instructions to the Law); the electronic tax bureau; the
digital-invoice notice; the accounts appendix of the 2006 Application
Guidance; the VAT accounting rules (财会〔2016〕22号); the 2019 statement
formats (财会〔2019〕6号); and the three texts of the surcharges.

Two of them are served by a publisher other than their author: the 2006
Application Guidance is read on the Ministry of Commerce's legal database,
which reproduces the Ministry of Finance notice in full (the Ministry of
Finance's own site does not serve the appendix), and the digital-invoice
notice on www.gov.cn. The electronic tax bureau answers a script with a
challenge page and no content; it is the address the State Taxation
Administration's home page links to.

## The chart of accounts

`accounts.csv` holds 156 accounts. The four-digit first-level accounts and
their names are those of the appendix to the Application Guidance of the
Accounting Standards for Business Enterprises (《企业会计准则——应用指南》,
财会〔2006〕18号, 附录《会计科目和主要账务处理》), less the accounts that only a
bank, an insurer, a securities firm or an oil and gas producer keeps
(1003 to 1031, 1111, 1201 to 1212, 1301 to 1321, 1431 to 1461, 1541, 1611,
1623, 1631–1632, 2002 to 2021, 2111, 2251 to 2314, 2601 to 2621, 3001 to
3202, 4102, 6011 to 6041, 6061, 6201 to 6203, 6411 to 6542, 6604
and 6901), and less the three available-for-sale and held-to-maturity
accounts (1501 to 1503) that the 2017 financial-instruments standard
replaced. One name differs from the appendix: 6403 is 税金及附加, the name
财会〔2016〕22号 gave 营业税金及附加 when the business tax was abolished.

The appendix says outright that its numbers are for reference and that an
enterprise sets its own detail accounts and codes. This pack therefore adds
detail accounts in two ways, both marked by a six- or eight-digit code:

- **Where a text names them.** The details of 应付职工薪酬, 盈余公积, 利润分配
  and 所得税费用 are the ones the appendix lists for those accounts. The
  details of 应交税费 are the ones 财会〔2016〕22号 prescribes for a general
  taxpayer (应交增值税, 未交增值税, 预交增值税, 待抵扣进项税额, 待认证进项税额,
  待转销项税额, 增值税留抵税额, 简易计税, 转让金融商品应交增值税, 代扣代交增值税),
  followed by the other taxes an ordinary company accrues.
- **Where only a practice exists.** The expense details of 销售费用, 管理费用 and
  财务费用 are this pack's choice, except 研究费用 and 无形资产摊销 under 管理费用,
  which 财会〔2019〕6号 names because the 研发费用 line of the income statement
  is read from them. Three first-level accounts introduced by later standards
  have no code in the 2006 appendix, and carry the one most Chinese charts
  give them: 6115 资产处置损益, 6117 其他收益, 6702 信用减值损失.

**The columns of 应交增值税.** 财会〔2016〕22号 gives a general taxpayer one
detail account, 应交增值税, kept with ten columns (专栏): 进项税额, 销项税额抵减,
已交税金, 转出未交增值税, 减免税款, 出口抵减内销产品应纳税额, 销项税额, 出口退税,
进项税额转出, 转出多交增值税. A ledger account has no columns, so each column is
an account of its own, 22210101 to 22210110. They sit beside 222101 rather
than under it, because a chart row with children is a heading that nothing
posts to, and 222101 itself is the one VAT account the same rule gives a
small-scale taxpayer ("小规模纳税人只需在'应交税费'科目下设置'应交增值税'明细科目"),
which the small-scale codes post to. A reviewer may prefer a second chart for
small-scale taxpayers; see below.

Which account plays which role:

| Role | Account | Why |
|---|---|---|
| receivable / payable | 1122 应收账款 / 2202 应付账款 | the only two reconcilable accounts besides the VAT settlement |
| tax_payable / tax_receivable | 222102 未交增值税 | the month-end transfer of 财会〔2016〕22号 moves what is owed, or overpaid, from 应交增值税 to 未交增值税; its sign says which. It is distinct from every account a tax posts to, and reconcilable |
| retained_earnings (both signs) | 410406 利润分配—未分配利润 | |
| current_year_result_profit / _loss | 4103 本年利润 | the appendix closes income and expense into 本年利润, then 本年利润 into 利润分配 — `closing_style: result_accounts` |
| fx_gain / fx_loss | 660303 财务费用—汇兑损益 | a non-financial enterprise books exchange differences in finance expenses; one account for both signs |
| rounding | 660399 财务费用—其他 | no text provides for one |
| suspense | 2241 其他应付款 | no text provides for one |
| asset_disposal_gain / _loss | 6115 资产处置损益 | 财会〔2019〕6号, 利润表 note 8 |

The fiscal year is the calendar year (`fiscal_year_default: calendar`): the
Accounting Law fixes the accounting year from 1 January to 31 December.

## Taxes

`taxes.json` carries 23 codes, all from 1 January 2026, the day the VAT Law
(中华人民共和国增值税法) replaced the Interim Regulations (article 38). The
13 %, 9 % and 6 % rates are the same numbers the Interim Regulations applied
since 1 April 2019, but a code is a rate *under a text*, and this pack
transcribes the Law and nothing before it: a company opening books for 2025
or earlier has no code here to post them with.

| Code | Rate | Article | Line of the return |
|---|---|---|---|
| CN-S-13-G | 13 % | Law art. 10 (1), goods | 2, 11 |
| CN-S-13-S | 13 % | Law art. 10 (1), processing/repair/replacement, leasing of movables | 3, 11 |
| CN-S-9-G | 9 % | Law art. 10 (2), the goods of its four sub-items | 2, 11 |
| CN-S-9-S | 9 % | Law art. 10 (2), transport, postal, basic telecom, construction, immovable property | 3, 11 |
| CN-S-6 | 6 % | Law art. 10 (3), other services and intangibles | 3, 11 |
| CN-S-0-EXP-G | 0 % | Law art. 10 (4), art. 33; Regulations art. 8, 47 | 7 |
| CN-S-0-EXP-S | 0 % | Law art. 10 (5); Regulations art. 9 | 7 |
| CN-S-EXO-G | exempt | Law art. 24 | 9 |
| CN-S-EXO-S | exempt | Law art. 24; 公告2026年第10号 二（二）2 | 10 |
| CN-S-3-SIMPLE | 3 % | Law art. 11; 公告2026年第10号 三（三） | 5, 21 |
| CN-S-NA | — | Law art. 6 | none |
| CN-S-SS-3 | 3 % | Law art. 8, 9, 11 (small-scale) | none — other form |
| CN-S-SS-1 | 1 % | 公告2026年第10号 三（三）6, until 31 December 2027 | none — other form |
| CN-P-13 / -9 / -6 / -3 / -1 | as charged | Law art. 16; Regulations art. 11, 12 | 12 |
| CN-P-6-ND / CN-P-13-ND | not deductible | Law art. 22 (5), (4) | none (cost of the line) |
| CN-P-FS-6 | 6 %, withheld | Law art. 15; Regulations art. 12 (3) | 12 |
| CN-P-EXO / CN-P-NA | — | Law art. 23–24 / art. 6 | none |

**The 1 % small-scale rate is valid.** The prompt that started this pack asked
whether the temporary reduction survived the Law. It does: 财政部 税务总局公告
2026年第10号 第三条第（三）项第6点 keeps it from 1 January 2026 to 31 December
2027 for every small-scale transaction taxable at 3 % except the sale or
lease of immovable property and the transfer of land use rights, and
国家税务总局公告2026年第4号 第四条 requires the invoice to be issued at 1 %. Both
CN-S-SS-1 and its purchase counterpart CN-P-1 carry `valid_to: 2027-12-31`.
The same notice sets the small-scale threshold (起征点) at 100 000 yuan of
monthly sales or 300 000 of quarterly sales until the same date; a threshold
is a total over a period, which no tax code can hold (`conditions:
seller_threshold` says so).

**The zero rate is a refund procedure.** An exporter charges no VAT, reports
the sale on line 7, and then claims the input tax back through a separate
declaration of export refund (出口退（免）税申报), at a refund rate the State
Council sets product by product (出口退税率), by the exemption-credit-refund
method (免抵退) for a producer or the exemption-refund method (免退) for a
trading company (Regulations art. 47). Neither the refund rates, nor the
免抵退 computation that fills line 15 of the return, nor the refund
declaration, nor the account 应收出口退税款 that 财会〔2016〕22号 creates for it
are in this pack.

**The withheld VAT of a foreign supplier.** CN-P-FS-6 books the service at
its price, the input tax the buyer may deduct on the strength of the tax
payment certificate (line 12), and the same amount owed to the tax office on
222110 代扣代交增值税, so the two net to nothing on the supplier's balance. The
withholding is declared and paid separately from the buyer's own return;
this pack models only the buyer's side of it, and at 6 % only — a withheld
13 % or 9 % is the same shape and has no code yet.

**What is not a code here**: import VAT (collected by Customs on a customs
payment book, then deducted on line 12; no customs clearing account is
modelled), the input tax computed at 9 % on the purchase price of
agricultural products bought on a purchase invoice (Regulations art. 12 (4)),
the 5 % levy rate of the simplified method on immovable property, the
immediate-refund regimes (即征即退), the input tax transferred out
(进项税额转出, line 14), and consumption tax.

## The surcharges: a tax on the tax

Three levies are assessed on the VAT and consumption tax a taxpayer actually
pays, and declared on lines 39 to 41 of the same return:

| Levy | Rate | Text |
|---|---|---|
| 城市维护建设税 urban maintenance and construction tax | 7 % in a city district, 5 % in a county town or town, 1 % elsewhere | 中华人民共和国城市维护建设税法 art. 4 |
| 教育费附加 education surcharge | 3 % | 征收教育费附加的暂行规定 |
| 地方教育附加 local education surcharge | 2 % | 财综〔2010〕98号 |

None of them is a tax on an invoice line: their base is the VAT *paid* for a
period, after deductions, reliefs and refunds, so they cannot be a code of
`taxes.json`. The format could compute them as a rate of line 24 — a `rate`
and a `rate_of` — and this pack does not, for two reasons: the rate of the
first depends on where the taxpayer is, which is not a fact the pack knows,
and reliefs for small taxpayers apply to all three, which this pack has not
transcribed. They are booked by hand: debit 6403 税金及附加, credit 222112,
222113 and 222114. See docs/international.md, "From China".

## The declaration

`tax_report.json` is the main table of 增值税及附加税费申报表（一般纳税人适用）,
column 一般项目, 本月数. It declares seventeen of its forty-one lines: the bases
of lines 2, 3, 5, 7, 9 and 10, the taxes of lines 11, 12 and 21, and the totals
1, 8, 17, 18, 19, 20, 24 and 34. The form's own formulas are kept, with three
readings a reviewer should check:

- **Line 18** is "17 if 17 is below 11, else 11". The format has no minimum,
  and line 18 is computed as 11 − 19, where line 19 is 11 − 17 floored at zero:
  the same figure.
- **Line 17** is 12 + 13 − 14 − 15 + 16. Line 13, the credit carried in from the
  previous period, is what the previous return came to, and `vat_return()`
  evaluates one period from its own ledger; lines 14 to 16 come from
  procedures this pack does not model. Line 17 is therefore line 12 alone, and
  a company carrying a credit has to add it on the portal.
- **Line 34** is 24 − 28 − 29. No code of this pack books a prepayment, so it
  comes to line 24.

The schedules (附列资料一 to 五) and the surcharge lines are not modelled.
Small-scale taxpayers file a different return, 增值税及附加税费申报表（小规模纳税人适用）;
a pack declares one form, and the small-scale codes therefore report on no
box. A company on the small-scale regime can book with this pack but not
compute its return with it.

**When.** The Law (art. 30) lets the tax office set the period at ten days,
fifteen days, a month or a quarter, according to the tax owed; the
Regulations (art. 43) reserve the quarter to small-scale taxpayers and a few
financial institutions. The form therefore lists `month` and `quarter` and
proposes neither. The return and the tax are due within fifteen days of the
end of the period (`day_of_month_after_period`, day 15); the tax
administration's yearly calendar moves the day when it falls on a holiday,
which the rule does not know. The return is filed on the electronic tax
bureau, whether or not there were sales, as the form's own header says.

**The tax point** is the earliest of payment and of the right to payment,
and the invoice date where an invoice is issued first (Law art. 28). The
vocabulary offers `earliest_of_delivery_or_payment`, which is the first half;
the invoice branch is written in the reference.

## The statements

`statements.json` carries the balance sheet (资产负债表, 会企01表) and the income
statement (利润表, 会企02表) of attachment 2 of 财会〔2019〕6号, for a
non-financial enterprise applying the 2017 financial-instruments and revenue
standards and the 2018 leases standard. The notice allows an enterprise to
leave out items it has no business for, and this pack leaves out the lines
its chart has no account for (listed in each statement's reference). The
form numbers no line, so the line codes (A01, L09, R20…) are this pack's own.

Three readings follow the texts rather than the account codes:

- 应收账款 and 预收账款, 应付账款 and 预付账款 are split by the side of their
  balance, as note 16 of the notice reads the payables.
- The debit balance of an 应交税费 account is presented under 其他流动资产, and
  the credit balance of 待转销项税额 under 其他流动负债, as 财会〔2016〕22号
  requires. Because the columns of 应交增值税 are accounts here, a period that
  has not been settled shows its input tax as an asset and its output tax as a
  liability, where a Chinese ledger would net them inside 应交增值税; once the
  return is settled into 未交增值税 the two agree.
- 研发费用 is read from the 研究费用 and 无形资产摊销 details of 管理费用, and
  管理费用 is printed without them.

## The golden quarter

`golden/scenario.json` is the first quarter of 2026 of a general taxpayer
filing monthly: thirteen documents and four payments. Its figures were worked
out by hand before they were generated:

| Period | Lines | Why |
|---|---|---|
| January | 1 = 70 000.00, 2 = 50 000.00, 3 = 20 000.00, 11 = 7 700.00, 12 = 3 900.00, 19 = 24 = 34 = 3 800.00 | a 13 % sale, a 6 % service, a 13 % purchase; a meal whose VAT is not deductible |
| February | 1 = 3 = 8 000.00, 7 = 40 000.00, 8 = 10 = 30 000.00, 11 = 720.00, 12 = 620.00, 19 = 100.00 | an export, an exempt technology contract, a 9 % freight service, a withheld foreign service, a 1 % small-scale invoice |
| March | 1 = 2 = 5 000.00, 11 = 250.00, 12 = 1 170.00, 18 = 250.00, 20 = 920.00, 19 = 0 | a credit note on a sale and on a purchase, a 9 % sale of produce, a fixed asset: a credit carried forward |

The income statement for the quarter shows 153 000.00 of revenue, 13 060.00 of
administrative expenses and a net profit of 139 940.00; the balance sheet,
the year being open, shows assets exceeding liabilities by that profit.

## What this pack does not carry

- **Clearance.** Issuing, numbering, delivering and confirming invoices on the
  State's platform (above).
- **The small-scale return**, the schedules of the general return, the carried
  credit, the prepayments, the export refund, and the surcharges.
- **A second chart.** 小企业会计准则 (财会〔2011〕17号), the Accounting Standards
  for Small Enterprises, has its own chart and its own statements and is what
  most small companies keep their books on. It would be a second chart of
  this pack, and it is not written yet.
- **Income tax, individual income tax withheld, stamp tax, property and land
  taxes**: accounts exist, codes and declarations do not.
- **Provinces.** Nothing in the VAT differs by province; the urban
  maintenance and construction tax does, by where the taxpayer is.

## For a reviewer

The points most worth a Chinese accountant's time, in order:

1. Whether line 7 is right for zero-rated cross-border services under the
   免抵退 method, and line 10 for exempt services, after the 2026 adjustment
   of the instructions.
2. The reading of lines 17, 18 and 34, and whether a monthly filer would
   rather see line 13 declared as an input.
3. Whether the columns of 应交增值税 should be accounts at all, or whether a
   reviewer prefers input and output tax on 222101 itself.
4. The four codes this pack gave accounts the 2006 appendix does not number
   (6115, 6117, 6702, and the expense details).
5. The export and non-deductible codes, against a real 附列资料（一）and（二）.
