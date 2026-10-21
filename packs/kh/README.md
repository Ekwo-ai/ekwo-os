# Cambodia

Everything Cambodia adds to Ekwo, as data: a chart of accounts, the journals,
the value added tax of Sub-Decree 49 (2024) with its zero rate and its
exemption, a self-assessment on services bought from a non-resident, the
monthly return, and a balance sheet and income statement grouped by this
chart's own account ranges. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Cambodian accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

**Status: `community`.** Nobody who files a Cambodian VAT return has reviewed
it. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right. What the core cannot yet say for Cambodia is in
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

## Sources

Every tax, box and mention carries its own `legal_reference`, and beside it
the key of the text that sentence rests on. The register in `pack.json` holds
four texts, all published by the General Department of Taxation (GDT) of the
Ministry of Economy and Finance, and **all four are scanned images, in Khmer
only**: no text layer, no English version of the VAT texts.

| What | Text | Where |
|---|---|---|
| The rate, the credit, the invoice, the place and time of supply, the records, the reverse charge | Sub-Decree No. 49 ANKr.BK of 11 March 2024 on the Value Added Tax, 15 pages | `tax.gov.kh` document `1adcafd1-44a6-4875-b3e7-349a693b7c9c` |
| The law the sub-decree implements | Law on Taxation, NS/RKM/0523/004 of 16 May 2023 | `tax.gov.kh` document `816f7e7b-e4be-4d8f-a789-e587b92dbe2e` |
| The duty to keep accounts | Law on Accounting and Auditing, NS/RKM/4016/006 of 11 April 2016 | `tax.gov.kh` document `1cce400f-e948-4724-9712-65c3bab4fc06` |
| The due dates, e-filing, the library of texts | GDT portal | `tax.gov.kh/en` |

**What was read, and what was not.** The sub-decree was read page by page as
images: articles 3, 4, 11 to 17, 19 to 25, 28 to 30 and 32 were read in full
or in part. The Law on Taxation (an 11 MB scan) and the Law on Accounting and
Auditing were **not read**: their titles and dates are those of the GDT's own
list. Consequently the rate rests on the sub-decree (article 30(2)), the
list of zero-rated and exempt supplies rests on nothing this pack could read,
and the pack says so on the codes concerned. The English-language "Tax Types
Briefly" page of the GDT for VAT links to two documents that turned out to be
training announcements, not a VAT summary; nothing is taken from them.

## The chart of accounts, and why this one

**No Cambodian chart of accounts could be read.** The Law on Accounting and
Auditing obliges an enterprise to keep accounts and prepare financial
statements, and a national accounting body exists, but no chart or statement
layout is published in a form this pack could read. The chart is written, not
transcribed: four digits by class — `1` assets, `2` liabilities, `3` equity,
`4` revenue, `5` cost of sales, `6` operating expenses, `7` finance items, `8`
income tax — with the accounts a VAT-registered Cambodian company's books
hold. 173 accounts, none copied from a published chart. The labels are in
Khmer, written for this pack; English is in `i18n/en.json`.

**Taxes named by the GDT that have an account.** Tax on income (`2150`,
`8000`), tax on immovable property (`6310`), signboard tax (`6320`), tax on
means of transportation (`6330`), withholding tax (`2140`), the advance tax
on dividend distribution (`2090`), and the National Social Security Fund
(`2160`, `6010`). The names are those of the GDT's list of tax types; no
rate of any of them is carried.

**Five value added tax accounts.** `2100` holds the output tax and `1150` the
input tax — the two the taxes post to. `2110` and `1155` are where a filed
return's balance lands (`tax_payable`, `tax_receivable`), reconcilable and
apart from the posting accounts.

**Riel and dollar.** The currency is the riel (`KHR`, no minor unit, so every
amount is a whole number). Cambodian businesses also quote and bank in US
dollars; accounts `1030` and `1040` hold foreign-currency banks. Which currency
a return is expressed in, and the conversion rate to use, was not read.

## Taxes

Six codes, all of the value added tax.

- **`KH-S-STD`, 10 %.** Article 30(2) of the sub-decree gives the tax on a
  tax-inclusive price as 1/11, which is a rate of 10 %. The pack's
  `valid_from` is the date of the sub-decree, 11 March 2024: the rate is
  older, but no earlier text was read.
- **`KH-S-ZR-EXP`, 0 %.** Article 29(1)(e) names sales exported at 0 % and the
  records that support them. Which supplies qualify is in the Law on
  Taxation, not read; the code is for a supply the user knows to be zero-rated
  and carries `conditions`.
- **`KH-S-EX`, exempt.** Article 29(1) keeps exempt supplies apart in the
  records. No exemption is named by this pack: the list was not read.
- **`KH-P-STD`, 10 %, creditable.** Articles 11 and 19: the tax paid on goods
  and services bought for taxable supplies is deductible on the original tax
  invoice.
- **`KH-P-EX`.** A purchase with no deductible value added tax.
- **`KH-P-RC`.** Article 23(3): a service supplied in Cambodia by a
  non-resident with no establishment there is taxed in the hands of the
  taxable recipient. The tax is posted on the output and input accounts in
  the same period, net nil.

## The return

`KH-VAT`, monthly. Article 29(1)(a) has the taxpayer keep a monthly VAT
account: total output tax, total input tax, and the tax payable or the excess
credit carried forward or refunded. The boxes (`SB`, `SZ`, `OT`, `PB`, `RC`,
`IT`, `NET`) are the pack's own names for those mechanics: the form of the
GDT's e-filing portal was not readable, so its numbering and Khmer wording are
not reproduced. **The deadline** is the 20th of the following month: the GDT
home page, read on 21 October 2026, shows for the period September 2026 a due
date of 20 October for a manual return and **25 October for an online one**.
A taxpayer filing online has until the 25th; the pack declares the earlier
date, and the provision behind the two dates was not read. A negative `NET`
is kept as a figure and not floored.

## The statements

`KH-BS` and `KH-IS` are original: lines grouped by the code ranges this
chart's own numbering gives its accounts. No fact keys. `closing_style` is
`retained_earnings`.

## On the invoice

Article 21 of the sub-decree: a taxable person issues a **tax invoice** to a
buyer who is a registered taxable person and an ordinary invoice to any other
buyer; the buyer may require it; the original or a copy is kept; the form is
fixed by a prakas of the Minister, **not read**. Article 25(1)(a): the supply
takes place when the invoice is required, or issued if earlier, and the
invoice is due at the latest seven days after delivery or performance (or
after payment, if payment comes first); `tax_point` is
`earliest_of_delivery_or_payment`, the closest value, and the seven days are a
gap of the vocabulary. **Numbering is `sequential`.** Article 29(2): records
are kept for ten years. No payment term is declared.

## Electronic invoicing

`einvoicing.obligation` is `none` and `profile` is `null`. The GDT runs
e-filing and an e-Tax portal, and the sub-decree refers to the Law on
Electronic Commerce of 2019 and to a VAT on e-commerce transactions; nothing
read obliges a taxpayer to issue an electronic invoice. `none` states only
that no obliging text was read, not that none exists.

## What this pack does not carry

- **The list of zero-rated and exempt supplies** (Law on Taxation, not read).
- **The non-deductible input tax of article 13**: accommodation, meals and
  entertainment; passenger vehicles of up to ten seats unless the taxpayer
  sells or hires them; petroleum products unless the taxpayer sells them.
  `KH-P-STD` assumes full deductibility; a purchase in those categories must
  be booked on an expense account with no tax code.
- **The apportionment of article 15** for a taxpayer making taxable and
  non-taxable supplies, and the annual adjustment of articles 16 to 18.
- **Excess credit** (article 20): its carry-forward or refund is not modelled.
- **Import VAT** collected by Customs (article 32): only the self-assessed
  service from a non-resident is carried.
- **VAT on e-commerce** supplied by non-residents to consumers (article 4(2),
  a simplified registration).
- **Registration thresholds** and the regime of small taxpayers (the Prakas on
  the classification of taxpayers): not read.
- **The printed boxes of the monthly return** and the Khmer wording of its
  form.
- **Withholding tax, tax on income, salary tax and the other taxes** of the
  GDT's list: accounts exist, no tax code does.
- **Fixed assets** and **bank formats**: nothing was checked.

## Reviewing this pack

Open an issue titled "Review: Cambodia". What a review is, and what it is not,
is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who may
say what". The points a Cambodian accountant should read first, roughly in the
order the author is least sure of them:

1. **The Khmer labels** of the chart, the journals, the statements and the
   boxes: written for this pack, never checked by a native accountant.
2. **The rate, the zero rate and the exemptions** against the Law on Taxation
   of 2023.
3. **The due date**: 20th manual, 25th online, and the law behind it.
4. **The printed form of the monthly return**, to rename the boxes.
5. **Article 13 and article 15** (credit excluded or prorated), the first
   thing a real company's books will hit.
6. **`tax_point` and `numbering`**, which rest on article 25 and 21 alone.
7. **The treatment of riel and dollar** in books and in the return.
