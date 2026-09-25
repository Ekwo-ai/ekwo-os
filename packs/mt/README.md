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
regulations are all enacted with an authoritative English text — English is
not a translation here, it is one of the two languages the law itself is
written in. This pack carries no Maltese labels: nobody who reads Maltese has
checked a wording of this pack's own, and inventing one would be worse than
leaving it out. `packs/mt/i18n/` does not exist for that reason, the same
choice `packs/ie/` and `packs/gb/` made.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` names ten texts. The Value Added Tax Act, the Commercial Code, the
Companies Act and the GAPSME regulations were read article by article, in the
full consolidated text `legislation.mt` (the Ministry for Justice's official
portal) serves — the Act carries amendments up to Act III of 2026 and the
Eighth Schedule up to the same, so the text read is the one in force on the
day this pack was released. The VAT Return's box numbers and layout are
transcribed from a specimen of the form itself, issued by the Office of the
Commissioner for Revenue.

**`cfr.gov.mt` and `mtca.gov.mt`** (Malta's tax administration, renamed from
the Commissioner for Revenue to the Malta Tax and Customs Administration)
refused every automated request made of them while writing this pack —
Cloudflare protection, not a wrong URL. Where this pack could not read a page
of theirs directly, it says so at the point that matters (the scope of box 2
of the VAT Return, the exact wording of the online-filing mandate) rather than
silently filling the gap from a secondary source.

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
other — because it is the layout GAPSME's own text lists first and the one
this pack's author saw used in practice; a chart for the vertical layout
would be a different, equally valid pack.

The VAT accounts are four: `1140` input VAT, `2200` output VAT, and the two
control accounts a filed return is cleared into — `2210` VAT payable to the
Commissioner for Revenue (`tax_payable`) and `1150` VAT recoverable from the
Commissioner for Revenue (`tax_receivable`), both reconcilable and both apart
from the accounts the taxes post to, so that a payment or a refund is matched
against the control account and not against the account a document posted to.

## The taxes

Twenty-six codes, sales and purchases together. Malta charges one standard
rate and three reduced rates, all set by one article and one Schedule, so
there is no history of superseded rates to carry the way Ireland's or the
United Kingdom's packs do — only the day the 12% rate was added.

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
`domestic_reverse_charge` code: nothing in the register read while writing it
evidences a Maltese equivalent of Ireland's construction-industry or the
United Kingdom's gas-and-electricity domestic reverse charge, and a rule not
found in the text is not invented. What Malta does have, in full, is the
ordinary EU mechanism for a purchase from elsewhere: `MT-P-ICG` and
`MT-P-ICG-CAPITAL` for an intra-Community acquisition of goods, `MT-P-ICS` for
a service received from a supplier in another Member State, and `MT-P-FSR`
for one received from outside the Union — each self-assessed on one box pair
and deducted on another, per the VAT Return's own layout (see below).

## The VAT Return

Forty-five boxes, transcribed from a specimen of the form itself — this pack's
authors could not reach the Office of the Commissioner for Revenue's own
explanatory guide (see *Sources*), so every box's purpose is read from its own
printed label and from the printed arithmetic beside it, never guessed.

**The cadence the Act gives everybody is the one proposed.** A tax period is
three calendar months beginning immediately after the preceding one ends
(art. 17(2)), the format's `quarter`, and the form proposes it. Article 17(3)
lets the Minister prescribe a different period for a class of persons by
regulation; no text read while writing this pack names such a regulation, so
no second cadence is declared. The golden scenario files on two such quarters.

**The deadline is not declared.** Article 27(1) sets it at the fifteenth day
of the *second* month following the month the tax period ends in — six weeks
after a quarter closes, not four. The specimen VAT Return this pack transcribes
confirms it exactly: a period ending 31 January 2024 carries a printed due
date of 15 March 2024. The format's `deadline` rule `day_of_month_after_period`
can only place a day in the month immediately after a period ends; there is no
way to say "the month after that" without adding a fixed number of days, and a
fixed number of days does not reproduce "the 15th" across quarters of
different lengths (an April 15th-plus-thirty lands on May 15th, but a July
15th-plus-thirty lands on August 14th). This is a gap of the socle, not of
Malta's law, and it is recorded in `docs/international.md` rather than worked
around with a wrong date.

**Box 2 is not posted to.** "Supplies of Goods and Services where Place of
Supply is outside Malta - EU and Non EU" sits beside box 1 on the form; this
pack could not confirm, from a source it could open, which of its treatments
beyond the intra-Community case already carried by box 1 the Commissioner
means the box to hold, and declares the box without a tax code that targets
it rather than guess. See `docs/international.md`.

**Boxes 40, 41 and 44** ("Adj in favour of Dept", "Adj in your favour",
"Excess Credit B/F") are manual entries a filer makes by hand and a balance
carried from an earlier return; no ledger fact produces them, no code of this
pack posts to them, and the golden scenario never needs one to be non-zero.

## Invoices

Numbering is `sequential` (Twelfth Schedule [art. 50(5)], item 3: "a
sequential number, based on one or more series, which uniquely identifies the
invoice"), payment terms 30 days (Commercial Code, Title II-A), and the tax
point `earliest_of_delivery_or_payment` (Fourth Schedule [art. 8], item 3: the
earlier of the chargeable event and a payment). The Fourth Schedule brings
the date forward again to that of a tax invoice issued by the 15th of the
following month; this pack does not model that second derogation, the way
`cash_basis` models one on a tax that departs from the general rule — none of
this pack's taxes claims to.

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
- The **online-filing portal's own field names and validation**, which live
  behind Cloudflare and were not read directly.
- **Domestic reverse charges**, because none was found in the register — if
  Malta has one this pack does not yet know of it, it belongs here and not
  invented.
- **Margin schemes** (Fourteenth Schedule: second-hand goods, travel agents,
  investment gold's option for taxation), **VAT groups**, and **partial
  exemption** under the Tenth Schedule beyond the plain right to deduct.
- **Corporate tax, social security and the annual declaration** a
  small-undertaking registration under article 11 files instead of this VAT
  Return.
- **IFRS statements**, for an entity GAPSME does not reach, and the
  **vertical layout** of the GAPSME balance sheet, which this pack does not
  carry beside the horizontal one.

## What a reviewer should read first

1. **Box 2's scope**, and whether a Maltese bookkeeper would ever need a tax
   code that targets it.
2. **The 12% items**, and whether keeping all four apart from a single
   generic services rate is how Maltese practice would choose a code.
3. **`MT-P-FSR`**, whose value the VAT Return reports in box 4/11 rather than
   in a box of its own — the same reading Ireland's pack gives its own
   services-from-outside-the-Union tax, on the ground that the specimen
   return gives no separate box either.
4. **The filing deadline gap**, and whether the socle should grow a second
   month offset before this pack declares one.
5. **The GAPSME layout choice** (horizontal over vertical), and whether
   Maltese practice reaches for the other one more often.
