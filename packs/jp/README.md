# Japan

Everything Japan adds to Ekwo, as data: a chart of accounts, the journals, the
consumption tax and the local consumption tax and where each code posts, the
general-method consumption tax return with its schedules 付表1-3 and 付表2-3,
the balance sheet and the income statement of the Ordinance on Company
Accounting, and the sentences a qualified invoice needs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a 税理士 reading the pack can
disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Japanese consumption tax return has
reviewed it. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**This is the first pack of Asia**, and the first whose own labels are not in a
Latin script. The pack is written in Japanese — accounts, journals, taxes, the
boxes of the return and the statement lines carry the wording a Japanese
bookkeeper reads — and `i18n/en.json` gives all of it in English. The legal
references are written in English with the Japanese title of each text, so that
a reviewer on either side can follow them. What the core could not say is
written up in [`docs/international.md`](../../docs/international.md) under
"Japan". None of it was patched for this pack's sake.

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds twenty-four texts, all opened on 21 September 2026. The laws
and orders were read in their consolidated text on e-Gov (the Consumption Tax
Act as amended to Act No. 12 of 2026); the return was read in the NTA's guide
to filling it in, because the form itself is published as an image; the 2026
reform of the transitional deduction was read in the NTA's leaflet, because
e-Gov does not consolidate an amendment into the supplementary provisions of an
amending act.

| What | Text | Where |
|---|---|---|
| The tax, the rates, exports, non-taxable supplies, the reverse charge, deduction, the return, the qualified invoice | 消費税法 (Act No. 108 of 1988) | `laws.e-gov.go.jp/law/363AC0000000108` |
| The accumulation method, the rounding once per invoice and per rate, services to non-residents | 消費税法施行令 (Cabinet Order No. 360 of 1988), arts. 17, 46, 62, 70-10 | `laws.e-gov.go.jp/law/363CO0000000360` |
| The local consumption tax: 22/78 of the national tax | 地方税法, art. 72-83 | `laws.e-gov.go.jp/law/325AC0000000226` |
| The 80 % transitional deduction, and its 2026 revision to 70, 50 and 30 % | 平成28年法律第15号, supplementary provisions arts. 52 and 53; NTA, 令和８年度税制改正について | e-Gov; `nta.go.jp` |
| The rates since 2014 and their national and local split | NTA, Tax Answer No. 6303 and *Consumption Tax — Basic Knowledge* No. 10 | `nta.go.jp` |
| The rates before 2014 | the supplementary provisions of the 1994 and 2012 amending acts, as e-Gov prints them with the Act (the fractions 3/103, 4/105 and 6.3/108) | e-Gov |
| What each line of the return holds | NTA, 消費税及び地方消費税の申告書（一般用）の書き方 (November 2025), and the 記載要領 of 付表1-3 and 2-3 | `nta.go.jp` |
| Interim returns, the individual's deadline, the 95 % rule | Ministry of Finance, 消費税に関する基本的な資料 | `mof.go.jp` |
| The rounding of the taxable amount and of the tax | 国税通則法, arts. 118 and 119 | e-Gov |
| The form of the statements | 会社計算規則, arts. 72 to 94 | `laws.e-gov.go.jp/law/418M60000010013` |
| Electronic invoicing | JP PINT 1.1.3 (OpenPeppol, Japan Peppol Authority); the EAS list; the Digital Agency's JP PINT page | `docs.peppol.eu`, `digital.go.jp` |
| The registration number | 適格請求書発行事業者公表サイト — T followed by thirteen digits | `invoice-kohyo.nta.go.jp` |

## The chart of accounts, and why this one

**Japan prescribes no chart of accounts.** The 会社計算規則 prescribes the
sections of the balance sheet of a 株式会社 — assets, liabilities, net assets
(art. 73) — their divisions (arts. 74 to 76) and the main items of each, and the
divisions and results of the income statement (arts. 88 to 94). Everything
below those items is left to "an appropriate name".

So the chart is written, not transcribed. Four digits by class — `1` assets, `2`
liabilities, `3` net assets, `4` revenue and gains, `5` cost of sales, `6`
selling and administrative expenses, `7` non-operating and extraordinary
expenses, `8` income taxes — flat, every account postable, the ranges cut so
that each reaches one item of the Ordinance. The names are the ones Japanese
bookkeeping uses: 売掛金, 仮払消費税等, 繰越利益剰余金. 125 accounts. None was
copied from a published chart, official or commercial.

**Tax-exclusive books, and four consumption tax accounts.** The ledger keeps
the tax apart from the price (税抜経理): `2170` 仮受消費税等 holds the tax on
sales and `1470` 仮払消費税等 the tax on purchases, the two the taxes post to.
`2175` holds the import consumption tax owed to customs until it is paid.
`2160` 未払消費税等 and `1475` 未収消費税等 are where a filed return's net lands —
the `tax_payable` and `tax_receivable` roles, both reconcilable and apart from
the accounts the taxes post to. Until then, the balance sheet nets 仮受 and 仮払
on the line 未払消費税等.

**The result goes straight to 繰越利益剰余金** (`closing_style:
retained_earnings`): the Ordinance has no line for the result of the year on
the balance sheet; it is part of その他利益剰余金 (art. 76(5)), and what a general
meeting then does with it is not part of a close.

## Taxes

**One code carries the national and the local tax.** A qualified invoice
states one 消費税額等 per rate (消費税法 art. 57-4(1)(v)) — the consumption tax
of art. 29 (7.8 %, 6.24 % at the reduced rate) and the local consumption tax of
地方税法 art. 72-83 (22/78 of it) together, 10 % and 8 %. So the rate of a code
is the combined one, the tax is computed and rounded once per invoice and per
rate as 消費税法施行令 art. 70-10 requires, and two postings share it out 78/22.
The 78 % is the national tax the return asks for; the 22 % is the local share,
kept on a working box, marked （計算用）, because the return works the local tax out from the
national one rather than printing it.

**The return is computed by accumulation (積上げ計算).** The law gives two
ways: multiply the period's tax-inclusive sales by 100/110 and then by 7.8 %
(割戻し計算, the one the NTA's guide illustrates), or add up the tax on the
qualified invoices issued and multiply by 78/100 (積上げ計算, Act art. 45(5) and
Order art. 62). For purchases the accumulation is the rule (Order art. 46(1)).
A ledger that holds the tax of each invoice produces the second, so the pack
takes it on both sides. A business that computes its sales by 割戻し gets a
figure a few yen away, and so does one whose 積上げ is truncated once on the
period total rather than once per invoice.

**Rounding: down.** 消費税法施行令 art. 70-10 requires the fraction of a yen to
be dealt with once per invoice and per rate and lets the business choose how;
JP PINT asks only that the result lie between the floor and the ceiling. The
pack declares `rounding_method: down` — truncation, which is how the State
itself rounds the taxable amount and the tax (国税通則法 arts. 118 and 119) and
how the NTA's schedules are filled in — and it is the first pack to do so. A
business that rounds half up changes one word.

**The rates since 1989.** Each is a code with a validity, never an edit:

| Codes | Rate | National / local | From | To |
|---|---|---|---|---|
| `JP-S-3`, `JP-P-3` | 3 % | 3 / — | 1989-04-01 | 1997-03-31 |
| `JP-S-5`, `JP-P-5` | 5 % | 4 / 1 | 1997-04-01 | 2014-03-31 |
| `JP-S-8`, `JP-P-8` | 8 % | 6.3 / 1.7 | 2014-04-01 | 2019-09-30 |
| `JP-S-10`, `JP-P-10` and the others | 10 % | 7.8 / 2.2 | 2019-10-01 | — |
| `JP-S-8R`, `JP-P-8R` and the others | 8 % reduced | 6.24 / 1.76 | 2019-10-01 | — |

The former rates post to the former-rate columns of 付表1-1 and 2-1 (boxes
`F11X`, `F2X`, `G10X`). The codes without a rate (exports, non-taxable supplies)
start on 1 October 2019: their earlier history was not traced.

**Not in the pack, deliberately: the food rate of 1 %.** On 15 September 2026
the Cabinet adopted an outline lowering the rate on food to 1 % from 1 April
2027 to 31 March 2029; the NTA and the Ministry of Finance publish it with the
words "if the bill is passed". A rate that is not law is not a code. The day it
is enacted, `JP-S-8R` and its siblings get a `valid_to` of 2027-03-31 and a
1 % code starts the next day.

**The reduced rate.** Food and drink other than alcohol and eating out, and
newspapers published at least twice a week on subscription (別表第一), at 8 %;
the qualified invoice has to say which items are at the reduced rate
(art. 57-4(1)(iii)), which is a mark on the line a renderer prints.

**Exports and non-taxable supplies are different things.** An export (art. 7)
is exempt and keeps the right to deduct; it is reported at 付表2-3 ②. A
non-taxable supply (art. 6 and 別表第二: land, interest and insurance,
residential rent, medical care, education…) is not a taxable supply at all;
it is reported at ⑥, and it lowers the taxable sales ratio.

**The transitional deduction for purchases from non-registered businesses.**
Since 1 October 2023 a purchase gives a deduction only on a qualified invoice.
A purchase from a business that is not a qualified invoice issuer — a small
business under the 10 million yen threshold (art. 9) that did not register —
still gives part of it under the 2016 act's supplementary provisions, and the
2026 reform changed the schedule: 80 % until 30 September 2026, then 70 % until
30 September 2028, 50 % until 30 September 2030, 30 % until 30 September 2031,
nothing after, and the cap per supplier falls from 1 billion to 100 million yen.
Eight codes, `JP-P-10-NQ80` to `JP-P-8R-NQ30`, each with its validity; the line
carries what was paid, tax included, because such a supplier states no tax, and
the non-deductible share lands on the account of the line.

**The reverse charge applies to the business that does not deduct in full.**
A business-to-business electronic service from a foreign business, and a
performance by a foreign entertainer, are 特定課税仕入れ: the buyer owes the
tax (arts. 4 and 5) and deducts it. But for as long as the 2015 act's
transitional measure lasts, a business whose taxable sales ratio is 95 % or
more treats them as not having happened. `JP-P-RC-10` is therefore for the
business below 95 %, and it posts both sides: the base to 付表1-3 ①-2 and
付表2-3 ⑬, the tax owed to ②, the tax deducted to ⑭. That business is also the
one whose deduction is apportioned, which the pack does not compute (see "The
95 % rule is assumed" below), so the code is right on the tax owed and
overstates the tax deducted. The golden year does not use it: its company is
above 95 %, where the purchase is simply not taxed.

**Imports** carry the tax customs assesses: `JP-P-IMP-10` and `-8R` post it
to 仮払消費税等 and to `2175`, owed to customs, rather than to the supplier.

## The return

`JP-CT-KAKUTEI` is the 消費税及び地方消費税の申告書（一般用）: the 第一表, and the
lines of 付表1-3 and 2-3 it is transferred from, fifty boxes in all. Each says
which line of the NTA's guide it transcribes.

- **Filed once a year, within two months.** The taxable period is the business
  year of a company (art. 19(1)(ii)); it can be shortened to three months or one
  month by notification. The pack says `year`, `quarter` and `month`, proposes
  `year`, and declares a deadline of the 28th of the second month after the
  period — the law says two months, which the vocabulary cannot say, and the
  28th is never later.
- **Interim returns are out.** A business whose tax for the previous year
  exceeded 480,000 yen pays one, three or eleven interim instalments on that
  figure (art. 42). They are a separate form filed on last year's figure; what
  they paid is entered at ⑩ and ㉑, which the pack declares and leaves empty.
- **The 95 % rule is assumed.** Line ④ is the whole of the tax on purchases
  where taxable sales are 500 million yen or less and the taxable sales ratio
  is 95 % or more (art. 30(2)). Below that it is apportioned, by the individual
  or the proportional method (個別対応方式, 一括比例配分方式), which the pack does
  not compute: for a company below 95 %, line ④ would be the full deduction,
  and too high. This is a gap of the core, written down in
  docs/international.md. The golden company is kept above 95 % (95.8 %), where
  the full deduction is the law.
- **The truncations of the form are not applied.** The 課税標準額 is truncated
  to the thousand yen, ⑨ and ⑳ to the hundred. The pack reports the yen.
- **The local tax is summed, not multiplied.** The form computes ⑳ as ⑱ ×
  22/78. The pack adds up the 22 % shares of each invoice (working boxes `LS`,
  `LP`, `LR`); the golden year gives 18,223 yen of local refund where the form
  would give ⑰ × 22/78 = 18,223.1, truncated.

The simplified method (簡易課税, art. 37), the 20 % special measure for
businesses that became taxable by registering and the 30 % one that replaces
it for individuals in 2027 and 2028 are other forms or other lines; none is
carried.

## The statements

`JP-KSK-BS` and `JP-KSK-PL` are the balance sheet and the income statement of
a 株式会社 under the 会社計算規則, with the Ordinance's own items and results:
売上総利益 (art. 89), 営業利益 (art. 90), 経常利益 (art. 91), 税引前当期純利益
(art. 92), 当期純利益 (art. 94). Accumulated depreciation is deducted from each
asset and the net shown, as art. 79(2) allows. 株式引受権 has no account in the
chart and no line. No `xbrl` key: nothing was verified against a taxonomy.

## The qualified invoice

What the law asks a qualified invoice to state (art. 57-4(1)), and what the
pack does with it:

| Particular | Where it is |
|---|---|
| The issuer's name and registration number (T and thirteen digits) | the company; the number is its tax identifier — nothing in the pack |
| The date of the supply | the document |
| What was supplied, marking the reduced-rate items | the lines; the mark is the renderer's (see docs/international.md) |
| The total per rate, and the rate | the tax groups of the document |
| The 消費税額等 per rate, rounded once | the tax groups: the engine rounds once per code and per document |
| The recipient's name | the contact |

The rounding holds exactly as long as one rate is carried by one code on a
document; a document that mixes `JP-S-10` and `JP-S-10-INC` is rounded twice at
the same rate.

`einvoicing` names JP PINT with no obligation: no statute obliges a business to
exchange electronic invoices, and art. 57-4(5) lets a qualified invoice be an
electromagnetic record. A party is addressed by its corporate number (EAS
0188), and the seller's tax identifier is its registration number (EAS 0221).
JP PINT's category for the reduced rate is `AA`; the core accepts `S` only for a
taxed domestic supply, so the reduced codes carry `S`, and the gap is written
down.

## The golden year

A 株式会社 with a year to 31 March, April 2026 to March 2027, filing once: 16
documents and 5 payments, in whole yen. Every figure of `golden/vat_return.json`
was checked by hand against the postings; the ones worth reading first:

- S2 puts both rates on one invoice and rounds each once: 48,063 × 8 % =
  3,845.04 → 3,845; 28,140 × 10 % = 2,814.
- S3 takes 8/108 once out of 4,861 yen of tax-inclusive food: 360.07 → 360.
- P3 and P4 are the same freelancer either side of 1 October 2026: 80 %, then
  70 %, of the tax deducted.
- S6, a residential rent, is non-taxable and lowers the taxable sales ratio to
  2,064,529 / 2,154,529 = 95.8 %: still 95 % or more, so every deductible tax
  is deducted in full and a foreign electronic service would not be reverse
  charged.
- The year ends on a refund of 82,832 yen at ㉖: 64,609 of national tax (⑧) and
  18,223 of local tax (⑲).

A box is each posting's share of the tax, truncated on its own, so the boxes of
an invoice can come to a yen less than its tax; the ledger keeps the whole tax.

## For a reviewer, in this order

1. The accumulation method on both sides, and truncation as the rounding.
2. The 78/22 split per invoice instead of the form's ⑱ × 22/78.
3. The seven codes of the 2026 transitional schedule, read against the amending
   act itself, which this pack read only through the NTA's leaflet.
4. The reverse charge limited to the business below 95 %, and the full deduction
   assumed at ④: correct for the golden company (95.8 %), too high for any
   company below 95 %, which is exactly the one the reverse charge reaches.
5. The deadline of the 28th of the second month.
6. The proposal of an April year (`fiscal_year_default`): the law chooses nothing
   (法人税法 art. 13 leaves the business year to the articles); the pack proposes
   April because the State's own fiscal year starts then (財政法 art. 11), and
   says so rather than claiming it is the most common.
