# Malta

Everything Malta adds to Ekwo, as data: a chart of accounts, the journals, the
VAT rates of the Value Added Tax Act (Chapter 406) with their legal references,
where each one posts, the boxes of the VAT Return, the balance sheet and the
income statement of the GAPSME accounting framework, and the sentences the law
puts on an invoice. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on, so that
a Maltese accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Status: `community`.** Nobody who files a Maltese return has reviewed it
against the law they apply. The figures are replayed against a year of books
by `tests/golden.test.ts`, which proves the pack is coherent and proves
nothing about whether it is right.

**Language: English.** Maltese and English are both official languages of
Malta, and the Value Added Tax Act, the Companies Act and the GAPSME
regulations are all enacted with an authoritative English text. This pack
carries no Maltese labels: nobody who reads Maltese has checked a wording of
this pack's own, so `packs/mt/i18n/` does not exist.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` names ten texts. The statutes are cited in the consolidated text
of `legislation.mt` (the Ministry for Justice's official portal), with the Act
and its Eighth Schedule amended up to Act III of 2026. The VAT Return's box
numbers and layout are transcribed from a specimen of the form itself, issued
by the Office of the Commissioner for Revenue (now the Malta Tax and Customs
Administration).

| What | Text | Where |
|---|---|---|
| The charge, the rate, exemptions, deduction, invoices, the tax point, the return | Value Added Tax Act (Cap. 406) — arts. 4, 8, 9, 17, 19, 20, 23, 27, 30, 50 and the Second to Twelfth Schedules | `legislation.mt/eli/cap/406` |
| The 12% rate | Value Added Tax Act (Amendment of Eighth Schedule) Regulations, 2023 (Legal Notice 231 of 2023) | `legislation.mt/eli/ln/2023/231` |
| Payment terms and late payment | Commercial Code (Cap. 13), Title II-A, inserted by Legal Notice 272 of 2012 | `legislation.mt/eli/cap/13` |
| The accounting framework | Companies Act (Cap. 386), art. 167; Accountancy Profession (GAPSME) Regulations (S.L. 281.05), Section 4 | `legislation.mt/eli/cap/386`, `legislation.mt/eli/sl/281.5` |
| The VAT Return's boxes | A specimen VAT Return, Office of the Commissioner for Revenue | see `cfr-vat-return` in `pack.json` |

## The chart of accounts

**Malta prescribes no chart of accounts.** Companies Act (Cap. 386), art.
167(1) asks for accounts that give a true and fair view under generally
accepted accounting principles and practice, and names none. A qualifying
small or medium-sized entity reports under GAPSME (S.L. 281.05) by default,
unless its board resolves to use IFRS as adopted by the EU or the entity
exceeds GAPSME's own size thresholds, in which case IFRS applies (regulations
4 and 5). So the statements are transcribed from GAPSME's own balance sheet
and income statement formats, and the chart is written to read straight off
them: `0` non-current assets, `1` current assets, `2` current liabilities,
`3` equity, `4` non-current liabilities, `5` income, `6` cost of sales, `7`
distribution and administrative expenses, `8` finance income, finance costs
and tax. 148 accounts, every one of them postable.

**GAPSME offers a horizontal layout and a vertical layout of the balance
sheet** (§4.13), an entity's own choice. This pack transcribes the
**horizontal** one — assets on one side, equity and liabilities on the
other — the layout GAPSME's own text lists first.

The VAT accounts are four: `1140` input VAT, `2200` output VAT, and the two
control accounts a filed return is cleared into — `2210` VAT payable to the
Commissioner for Revenue (`tax_payable`) and `1150` VAT recoverable from the
Commissioner for Revenue (`tax_receivable`), both reconcilable and both apart
from the accounts the taxes post to.

## The taxes

Twenty-six codes, sales and purchases together. Malta charges one standard
rate and three reduced rates, all set by one article and one Schedule, so
there is no history of superseded rates — only the day the 12% rate was added.

| Rate | What it is for | Since |
|---|---|---|
| Standard 18% | Every taxable supply the Eighth Schedule does not name | 1 May 2004 (accession) |
| Reduced 7% | Licensed tourist accommodation (item 1); the use of sporting facilities (item 11) | 1 May 2004 |
| Reduced 12% | Custody and management of securities; management of credit and credit guarantees; short-term hire of a pleasure boat (five weeks or less); regulated care of the human body, including a health studio (items 12–15) | 1 January 2024 (Legal Notice 231 of 2023) |
| Reduced 5% | Electricity, printed matter and e-books, the importation of works of art and antiques, minor repairs, domestic care services, admission to museums and the like (items 2–10) | 1 May 2004 |
| Exempt with credit ("zero-rated" in substance) | Exports outside the EU, food for human consumption, pharmaceutical goods, and the rest of Part One of the Fifth Schedule | 1 May 2004 |
| Exempt without credit | Insurance, credit and financial services, letting of immovable property, health, education, and the rest of Part Two of the Fifth Schedule | 1 May 2004 |

`MT-S-EXPORT`, `MT-S-FOOD` and `MT-S-PHARMA` are three codes of one rate: the
Act itself is a list of what is exempt with credit, not a single rule, and a
document should say which item it was supplied under. The same is true of
`MT-S-INSURANCE`, `MT-S-FINANCE`, `MT-S-LETTING` and `MT-S-EDUCATION` on the
exempt-without-credit side.

**Reverse charges are self-assessed, not domestic.** This pack carries no
`domestic_reverse_charge` code: no Maltese domestic reverse charge was found
in the register. What Malta does have is the ordinary EU mechanism for a
purchase from elsewhere: `MT-P-ICG` and `MT-P-ICG-CAPITAL` for an
intra-Community acquisition of goods, `MT-P-ICS` for a service received from a
supplier in another Member State, and `MT-P-FSR` for one received from outside
the Union — each self-assessed on one box pair and deducted on another, per
the VAT Return's own layout.

## The VAT Return

Forty-five boxes, transcribed from a specimen of the form itself; each box's
purpose is read from its printed label and the printed arithmetic beside it.

**The cadence proposed is the Act's.** A tax period is three calendar months
beginning immediately after the preceding one ends (art. 17(2)), the format's
`quarter`. Article 17(3) lets the Minister prescribe a different period for a
class of persons by regulation; none is cited, so no second cadence is
declared. The golden scenario files on two such quarters.

**The deadline is not declared.** Article 27(1) sets it at the fifteenth day
of the *second* month following the month the tax period ends in — six weeks
after a quarter closes, not four. The specimen VAT Return confirms it: a
period ending 31 January 2024 carries a printed due date of 15 March 2024. The
format's `day_of_month_after_period` can only place a day in the month
immediately after a period ends, and a fixed number of days does not
reproduce "the 15th" across quarters of different lengths. This is a gap of
the core, not of Malta's law; see
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

**Box 2 is not posted to.** "Supplies of Goods and Services where Place of
Supply is outside Malta - EU and Non EU" sits beside box 1 on the form; which
treatments beyond the intra-Community case already carried by box 1 it is
meant to hold is not confirmed, so the box is declared without a tax code
that targets it.

**Boxes 40, 41 and 44** ("Adj in favour of Dept", "Adj in your favour",
"Excess Credit B/F") are manual entries a filer makes by hand and a balance
carried from an earlier return; no code of this pack posts to them.

## Invoices

Numbering is `sequential` (Twelfth Schedule [art. 50(5)], item 3: "a
sequential number, based on one or more series, which uniquely identifies the
invoice"), payment terms 30 days (Commercial Code, Title II-A), and the tax
point `earliest_of_delivery_or_payment` (Fourth Schedule [art. 8], item 3: the
earlier of the chargeable event and a payment). The Fourth Schedule brings
the date forward again to that of a tax invoice issued by the 15th of the
following month; this pack does not model that second derogation.

**E-invoicing is not mandatory between businesses in Malta today**, and the
pack says so: `obligation` is `none` and `mandatory_from` is empty. The EU's
VAT in the Digital Age package will require it for cross-border
business-to-business supplies from 1 July 2030; Malta's tax administration has
signalled work on a national regime ahead of that date, and no legal notice
had set one at the day this pack was released.

**Bank formats**: `camt.053`, the one statement format Ekwo reads that
Maltese banks send. No payment format is declared, because Ekwo writes none.

## Out of scope

- The **exact scope of box 2** of the VAT Return, beyond the intra-Community
  case box 1 already carries (see above).
- The **online-filing portal's own field names and validation**.
- **Domestic reverse charges**, because none was found in the register.
- **Margin schemes** (Fourteenth Schedule: second-hand goods, travel agents,
  investment gold's option for taxation), **VAT groups**, and **partial
  exemption** under the Tenth Schedule beyond the plain right to deduct.
- **Corporate tax, social security and the annual declaration** a
  small-undertaking registration under article 11 files instead of this VAT
  Return.
- **IFRS statements**, for an entity GAPSME does not reach, and the
  **vertical layout** of the GAPSME balance sheet.

## What a reviewer should read first

1. **Box 2's scope**, and whether a Maltese bookkeeper would ever need a tax
   code that targets it.
2. **The 12% items**, and whether keeping all four apart from a single
   generic services rate is how Maltese practice would choose a code.
3. **`MT-P-FSR`**, whose value the VAT Return reports in box 4/11 rather than
   in a box of its own, on the ground that the specimen return gives no
   separate box.
4. **The filing deadline gap**, and whether the core should grow a second
   month offset before this pack declares one.
5. **The GAPSME layout choice** (horizontal over vertical), and whether
   Maltese practice reaches for the other one more often.
