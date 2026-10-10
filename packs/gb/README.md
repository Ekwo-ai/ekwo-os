# United Kingdom

Everything the United Kingdom adds to Ekwo, as data: a chart of accounts, the
journals, the VAT rates and where each one posts, the nine boxes of the VAT
Return, the balance sheet and the profit and loss account of the small
companies regime, the usual lives of a fixed asset, and the sentences the law
puts on an invoice. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on.

**Status: `community`.** Nobody who files a British return has reviewed it
against the law they apply. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

What the core cannot yet say precisely for the United Kingdom is listed in
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

## Sources

Every rate, box, mention, statement and asset category carries its own
`legal_reference`, and beside it the key of the text that article is in. The
register in `pack.json` holds thirty-two texts. The ones the rest of this file
leans on:

| What | Text | Where |
|---|---|---|
| The charge, the rates, zero-rating, exemption, the reverse charge on services from abroad, input tax | Value Added Tax Act 1994 | `legislation.gov.uk/ukpga/1994/23` |
| The return, the prescribed accounting period, the particulars of an invoice | Value Added Tax Regulations 1995 (S.I. 1995/2518), regs. 13 to 16 and 25 | `legislation.gov.uk/uksi/1995/2518` |
| Which amount goes in which of the nine boxes | How to fill in and submit your VAT Return (VAT Notice 700/12), HMRC | `gov.uk/guidance/how-to-fill-in-and-submit-your-vat-return-vat-notice-70012` |
| The construction reverse charge | VATA 1994 s. 55A and S.I. 2019/892, with HMRC's guidance | `legislation.gov.uk/uksi/2019/892` |
| Postponed VAT accounting | Complete your VAT Return to account for import VAT, HMRC | `gov.uk/guidance/complete-your-vat-return-to-account-for-import-vat` |
| Business entertainment | Value Added Tax (Input Tax) Order 1992 (S.I. 1992/3222), art. 5 | `legislation.gov.uk/uksi/1992/3222` |
| The form and content of the accounts | Companies Act 2006 s. 396; S.I. 2008/409 Schedule 1 for the small companies regime, S.I. 2008/410 Schedule 1 otherwise | `legislation.gov.uk` |
| The accounting standards behind them | FRS 102 and FRS 105, Financial Reporting Council | `frc.org.uk` |
| Payment terms and late payment | Late Payment of Commercial Debts (Interest) Act 1998, ss. 4, 5A and 6 | `legislation.gov.uk/ukpga/1998/20` |
| Rounding | VATREC12010 and VATREC12020, HMRC VAT Trader Records manual | `gov.uk/hmrc-internal-manuals/vat-trader-records` |
| Electronic invoicing | Promoting electronic invoicing across UK businesses and the public sector — consultation response, 26 November 2025 | `gov.uk` |

## The chart of accounts, and why this one

**The United Kingdom prescribes no chart of accounts.** Companies Act 2006,
s. 396 requires a balance sheet and a profit and loss account complying with
regulations as to their *form and content*, and those regulations prescribe
the **formats of the statements** — Schedule 1 to S.I. 2008/409 for a small
company, to S.I. 2008/410 for everyone else. Neither says a word about a
nominal ledger. This chart follows the convention British bookkeepers share:

- **Four digits, ten classes.** `0` fixed assets, `1` current assets, `2`
  creditors due within one year, `3` creditors due later, provisions, accruals
  and the capital and reserves, `4` turnover and other income, `5` cost of
  sales, `6` distribution costs, `7` administrative expenses, `8` finance costs
  and tax. There is no class per statement caption and no legal code.
- **Flat.** No parent accounts. Every account is a leaf and the grouping is done
  by the `code_range` rules of `statements.json`: each block was cut so that it
  maps onto exactly one item of Balance Sheet Format 1 or of Profit and Loss
  Account Format 1.
- **Cost and accumulated depreciation are adjacent.** `0120` plant and
  machinery and `0121` its accumulated depreciation, so a single range reaches
  the net book value the format prints.

190 accounts, all of them postable. The chart is written for this pack and is
not a copy of any published one; the conventions above are.

**One thing to look at twice.** Input VAT (`1140`) reports as an *other debtor*
and output VAT (`2200`) as an *other creditor*, because Format 1 has no line of
its own for tax. A British balance sheet usually nets the two in the notes;
this pack keeps them apart in the ledger, as a VAT account under VAT Notice
700/21 needs. The `2210` VAT control account is where `settle_filing()`
carries the net of a filed return that owes HMRC money; a return that ends in a
credit goes to `1145`, see "Where a filed return's balance lands" below. No tax
posts to either.

## Taxes

A code is a rate at a date, and a new rate is a new code with a `valid_to` on
the old one. The standard rate therefore appears four times:

| Rate | In force | Why it changed |
|---|---|---|
| 17.5 % | 1 September 1994 – 30 November 2008 | the rate when the Act itself came into force (s. 101(1)) |
| 15 % | 1 December 2008 – 31 December 2009 | S.I. 2008/3020, whose end date the Finance Act 2009, s. 9 moved from 30 November to 31 December 2009 |
| 17.5 % | 1 January 2010 – 3 January 2011 | the 2008 Order ceased and s. 2(1) applied again |
| 20 % | from 4 January 2011 | Finance (No. 2) Act 2010, s. 3 |

The temporary hospitality rates are here too — 5 % from 15 July 2020 under
S.I. 2020/728 as extended to 30 September 2021 by the Finance Act 2021, s. 92,
then 12.5 % to 31 March 2022 under s. 93 of the same Act — because a credit note
on a supply of that period has to find its rate.

**Zero-rated and exempt are two codes and not one.** On the return they share
box 6 and neither carries output tax, but only a zero-rated supply carries a
right to deduct the input tax attributable to it. `GB-S-00` and `GB-S-EXEMPT`
stay apart so that the distinction survives into whatever computes a partial
exemption; the pack itself computes none.

**Four ways a British buyer taxes themselves:**

| Tax | Mechanism | Boxes |
|---|---|---|
| `GB-P-20-DRC-CIS`, `GB-P-05-DRC-CIS` | construction reverse charge, VATA s. 55A | 1, 4, 7 — and **not** 6 |
| `GB-P-20-PVA` | postponed VAT accounting on an import of goods | 1, 4, 7 |
| `GB-P-20-RCS` | service received from a supplier established abroad, VATA s. 8 | 1, 4, **6 and 7 at once** |
| `GB-P-20-ENT` | business entertainment: not a self-charge, a block | 7 only; the tax follows the account of the line |

**No intra-Community tax, on either side.** Since 1 January 2021 a supply from
Great Britain to a member State is an export and an arrival from one is an
import. The `territories` table has `GB` inside the common system of VAT from
1 January 1973 to **31 December 2020**, the end of the transition period of the
Withdrawal Agreement and not the day of withdrawal.

**Northern Ireland is deliberately out of scope.** The same table carries `XI`
as a territory of `GB`, in the common system for **goods only** since 1 January
2021 and identified under the `XI` prefix, with the article of the Windsor
Framework that says so. Boxes 2, 8 and 9 of the return are about that trade and
nothing else; they are declared, and nothing posts to them.

The format can express it: a tax may say
`"applies_when": { "seller_in": "XI" }`, a company may record the territory it
is established in, and `ekwo pack check` holds such a tax to the rules of a
territory the common system reaches for **goods alone**. What is missing is the
transcription itself, a body of law a British accountant should put their name
to. Until then, this pack is Great Britain's return and boxes 2, 8 and 9 stay
empty.

**Business entertainment is a `tax_on_base` posting at 100 %.** Art. 5 of the
Input Tax Order excludes the whole of the tax from credit, so it lands on the
account of the line it taxes — `7330` in the golden year, which ends up holding
720 for a 600 invoice.

## The return

`tax_report.json` is the VAT Return as it stands since 1 January 2021, when
boxes 2, 8 and 9 became about Northern Ireland alone.

**Box 5 is a subtraction, and a repayment comes out negative.** VAT Notice
700/12: deduct the number in box 4 from the number in box 3 and enter the
difference. A repayment period therefore reports a negative box 5 where the
printed form shows a positive figure and which way it goes. In the golden year
the third quarter, which carries only a credit note, comes to −400.00.

**Every box of this pack is a box of the form, and one tax names two of
them.** VAT Notice 700/12 asks for the value of a service received from a
supplier established abroad in box 6 (outputs) and in box 7 (inputs). The
posting names `["6", "7"]` and the amount is reported in each. The rule is in
[`docs/packs.md`](../../docs/packs.md), "A base is written once, and printed as
often as the form likes".

**Box 1 is summed from the ledger and not computed:** what reaches it is the
output tax the documents actually posted, each already rounded once, the closer
figure to what a VAT account under Notice 700/21 shows.

**Boxes 2, 8 and 9 are declared and empty**, for the Northern Ireland reason
above. Box 3 and box 5 are the two arithmetics the notice states; every other
box is summed from the ledger.

**The cadence.** Regulation 25(1) of the VAT Regulations 1995 makes the
prescribed accounting period three months **for everybody**; a month is
allowed on application and a year under the annual accounting scheme. That is
a default the law gives without knowing anything about the company, so
`defaults.vat_period` would read `quarter`. It does not: the core proposes a
cadence only for a form filed on one, and `tests/tax_report.test.ts` holds that
as an invariant over every pack. The British form is filed on three, so this
pack proposes nothing, `ekwo init` asks, and the gap is written up in
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).
A British company that has asked HMRC for nothing files quarterly.

**Where a filed return's balance lands.** `defaults.roles` names `2210` for
`tax_payable` and `1145` for `tax_receivable`. VATA 1994 s. 25(2) nets the
period's input tax against its output tax, and s. 25(3) makes an excess of
credit a *VAT credit* the Commissioners pay to the trader: a claim on HMRC, an
asset. Carrying it on the debit side of `2210` would print a negative creditor
under Format 1, so the repayment has an account of its own under *other
debtors* (C.II.3), like input VAT. Both are reconcilable.

**Making Tax Digital is out of scope and is not a gap.** Every VAT-registered
business must keep digital records and file through functional compatible
software under S.I. 2018/261. Submitting to HMRC's API is a format library and
a credential, not a pack: the boxes of a return are here and the envelope is
not.

## The accounts

`statements.json` carries Balance Sheet Format 1 and Profit and Loss Account
Format 1 of Schedule 1 to S.I. 2008/409 — the **small companies regime**, which
is what the overwhelming majority of British companies file. Every line code is
the format's own letter or numeral and every name is the format's own wording.
Three decisions a reviewer should weigh.

**Items 15 to 18 do not exist.** The extraordinary items were removed when the
formats were amended, so the numbering runs 1 to 14 and then 19 and 20. The
pack keeps the numbers the format keeps, because a line 15 that meant item 19
would mislead anybody holding the Schedule.

**Item F takes the whole of item J.** Note 5 to Section B puts the accruals and
deferred income *falling due within one year* into net current assets. The
pack format does not split a line by maturity, so the whole of item J is
treated as current and deducted at F. For a small company whose accruals are
current the figure is right; for one carrying long-term deferred income it is
not, and the fix is two accounts and two lines.

**`NET` is not an item of Format 1.** A British balance sheet prints a net
assets figure above the capital and reserves; the two agree only once the year
is closed. In the golden year they come to 22 330.00 and 0.00 respectively, and
the difference is the 22 330.00 of line 20.

**No fact keys.** Companies House takes small company accounts in iXBRL against
taxonomies the Financial Reporting Council publishes; `xbrl` and `taxonomy` are
null on both statements. A wrong key is worse than no key.

## Closing the year

`closing_style` is `retained_earnings`: the result goes straight into `3400
Profit and loss account`, the reserve item K.V of the balance sheet. Format 1
has no "profit for the year" item, so the manifest names no
`current_year_result_profit` and no `current_year_result_loss`. `3410 Dividends
paid` sits beside the reserve and is booked by hand.

**No tax provision is booked by the close.** Corporation tax is an expense of
item 13 and a creditor of item E.4; the chart carries `8200` and `2280` so that
it can be booked.

## Fixed assets

`fixed_assets.json` is the part of this pack that is most plainly **practice
rather than law**. The United Kingdom has no legal or fiscal table of useful
lives: FRS 102, Section 17 asks an entity to estimate the life of its own
asset, and capital allowances never touch the accounting charge. Every category
cites FRS 102 and says the duration is common practice. The exceptions are
goodwill and other intangibles, where FRS 102 caps the life at ten years when it
cannot be reliably estimated.

Disposal is `net_result`: FRS 102 recognises the difference between the proceeds
and the carrying amount in profit or loss as one figure.

## On the invoice

`documents.mentions` carries four sentences and each cites the article that
requires it; `documents.references` carries one citation per rule — the
numbering under reg. 14(1)(a) of the VAT Regulations 1995, the payment term
under s. 4 of the Late Payment of Commercial Debts (Interest) Act 1998, the tax
point under s. 6 of the VAT Act 1994.

**One sentence covers two reverse charges.** `applies_when` has a single
`reverse_charge` condition, and the United Kingdom has two mechanisms behind it:
s. 55A for construction services supplied here, and s. 8 for a service received
from a supplier established abroad. The pack prints one sentence and names both
articles in its legal reference.

**Numbering is `sequential`, not gapless.** Regulation 14(1)(a) requires "a
sequential number based on one or more series which uniquely identifies" the
document: uniqueness and a series, not the absence of a hole. A retailer may
issue a less detailed invoice where the consideration does not exceed £250
(reg. 16), a rendering decision and not a field of this format.

**The tax point is a derogation and says so.** Section 6 of the Act puts the
basic tax point at the removal of the goods or the performance of the service,
and s. 6(4) and (5) displace it to the invoice where one is issued within
fourteen days, or to an earlier payment. `invoice_date` is right for the
ordinary business-to-business case and is not the principle; the reference
says so.

**Payment terms.** 30 days is the default of s. 4(2H) of the Late Payment of
Commercial Debts (Interest) Act 1998 where the parties agreed no payment day,
and s. 4(2E) is the 60-day ceiling on what two businesses may agree. The rate of
statutory interest is set by order under s. 6 and is deliberately not a number in
this pack; the fixed recovery sums of s. 5A — £40, £70 and £100 by band — are in
the reference.

## Rounding, and prices that include the tax

`rounding_method` is `half_up`, half away from zero at the two decimals of
sterling, applied once per tax group. VATREC12010 records the concession of
VAT Notice 700 §17.5 that lets an **invoice trader** round the VAT payable
*down*; VATREC12020 says the concession is "not appropriate for retailers", and
lists rounding up and down to the nearest penny among what a retailer may do.
`half_up` is therefore right for a retailer and permitted for an invoice
trader; a company on the concession changes one field.

**Prices that include the tax are the unfinished part of this pack.**
`GB-S-20-INC` carries `price_include: true`, and the core has no gross-to-net
computation: it adds the tax on top of the price instead of taking one sixth
out of it. The golden scenario books such a sale on purpose, with a `why` that
says so. Until the core reads the column, a British retailer enters net prices.

## What this pack does not carry

- **Northern Ireland** — no `XI` identification, no intra-Community tax,
  nothing in boxes 2, 8 and 9. See above.
- **Making Tax Digital submission** — the API, the credentials and the
  digital-links obligations.
- **The VAT schemes** (flat rate, cash accounting, annual accounting, margin,
  retail, Tour Operators' Margin Scheme) — each a regime of a whole taxable
  person rather than a property of a tax.
- **Partial exemption** — exempt supplies keep their own codes so that a
  calculation is possible; there is no de minimis test.
- **The Construction Industry Scheme deduction** — `2230` is in the chart for
  the 20 % or 30 % withheld; the monthly CIS return is not a VAT return.
- **Corporation tax, capital allowances and the CT600.**
- **The medium and large formats** of S.I. 2008/410, the Format 2 profit and
  loss account by nature, and the notes to the accounts.
- **iXBRL for Companies House.**

## Reviewing this pack

Open an issue titled "Review: United Kingdom". What a review is, and what it is
not, is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who
may say what".

No tax of this pack carries an `exemption_code`: the VATEX list applies only
where the common system of VAT does, and every exemption states its article in
`legal_reference` instead. The categories come from UNCL5305, a UN/CEFACT list,
and `G` there is *free export item, VAT not charged* — goods leaving the
territory of whoever levies the tax, which is exactly what s. 30(6) zero-rates.

Eight points a reviewer holding an ICAEW or ACCA practising certificate should
look at first:

1. **Which boxes each self-charge fills** (the four-row table above, from VAT
   Notice 700/12 and HMRC's guidance). That a construction purchase goes in
   box 7 and not box 6, while a service received from abroad goes in both 6
   and 7, is the distinction most worth a second reading.
2. **Whether the installer should ask at all.** A reviewer who reads
   reg. 25(1) as giving every British company a quarterly default would want
   the installer to stop asking — an argument for the core, not this pack.
3. **The reduced rate as one code.** Schedule 7A has many Groups, added at
   different dates, and the pack carries one 5 % code running from 11 May 2001,
   the day s. 29A was inserted. A supply under a Group added later is accepted
   on dates when the Group did not yet exist; dating the Groups means a code
   per Group.
4. **Item F and the whole of item J.** See "The accounts".
5. **The chart's mapping onto Format 1.** Every account reaches a line, and
   only the suspense account reaches two (debtor in debit, creditor in credit).
   *Which* line is a judgement everywhere else, especially for the VAT accounts
   and for administrative expenses, since Format 1 classifies by function.
6. **The fixed asset durations**, every one of which is practice and says so.
7. **The historical rates**, which matter only for a credit note on an old
   supply.
8. **The two settlement accounts.** `2210` for what a return owes and `1145`
   for a VAT credit. A reviewer who keeps one VAT control account for both
   signs would remove `tax_receivable`, and the settlement then carries a
   credit to `2210` too.

## Corporate income tax: what `corporate_tax.json` leaves out

The section rests on the Corporation Tax Acts of 2009 and 2010, HMRC's rates
and allowances and its guidance on marginal relief, and the Business Income
Manual. The computation starts from item 20 of the profit and loss account,
because Format 1 as this pack carries it prints no result before tax, and adds
the tax charge of accounts 8200 to 8220 back. The rates are written as slices:
19 % to £50,000, 26.5 % from £50,000 to £250,000 (marginal relief at 3/200
written as a rate, which is exactly the law's arithmetic only where the
augmented profits equal the taxable profits) and 25 % beyond. All three apply
only to a company that says it has a twelve-month period, no associated
company, no close-investment-holding status and no such distribution; any other
company is taxed at 25 % and the estimate says which condition failed.

| Not carried | Why |
|---|---|
| Division of the £50,000 and £250,000 limits by the number of associated companies plus one (CTA 2010 s. 18D) | A threshold is a number in the pack, and a company's count of associated companies is not one the section can divide by. A company with associated companies is taxed at 25 % on everything, which is too high below the divided limits. |
| Reduction of the limits for a period under twelve months | The Act says "proportionately reduced", not by days or by months. The pack's month proration would be an approximation, so a period that is not twelve months is taxed at 25 %. |
| Marginal relief where the augmented profits exceed the taxable profits | The relief is F × (U − A) × N / A; the slices above are the same arithmetic only where A = N. The company declares that they are equal, and without it the main rate applies. |
| The deductions allowance of a group, and its reduction for a short period (CTA 2010 ss. 269ZR, 269ZS, 269ZW(3)) | The floor of the loss limit is one figure, £5,000,000, for a company on its own. |
| The restriction applies to trading losses carried forward and to profits of the same kind (ss. 269ZB, 269ZF) | Losses are set against the fiscal result as a whole; earlier losses of other kinds, and trading losses of periods before 1 April 2017, are not told apart. |
| Fines: an account | The chart has no account for fines, so `fines-penalties` applies to an amount the company declares. |
| Capital allowances, and the depreciation of distribution assets (6500) | The company declares the allowances it claims; the pack computes none. Account 6500 does not say which kind of asset it holds, so its depreciation is declared too; intangible amortisation (7670, 7680) is not added back. |
| Deduction of qualifying charitable donations, group relief, R&D relief, the patent box, the rules on interest | Not modelled. |
| Prepayments: the quarterly instalments of large companies and the date nine months and one day after the period | The instalments of a large company are shares of the tax of the period itself, which neither method of the section says; `prepayments` is empty. |
| Tax credits | `credits` is empty: no credit was cited. |
| Companies that are not UK-resident, and ring-fence profits | The rates are those of s. 18A and s. 18B, which exclude ring-fence profits. |
