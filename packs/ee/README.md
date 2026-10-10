# Estonia

Everything Estonia adds to Ekwo, as data: a chart of accounts, the journals,
the VAT rates and where each one posts, the boxes of form KMD, the balance
sheet and the income statement of the annual report, and the sentences the law
puts on an invoice. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on, so that
an Estonian accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply. The
figures are replayed against a year of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`.
These are the texts the pack as a whole was built from.

| What | Text | Where |
|---|---|---|
| VAT rates, reverse charge, deduction limits, invoice particulars, the return | Käibemaksuseadus (KMS), consolidated | `riigiteataja.ee`, act 130122025021; official English translation 530122025010 |
| Form KMD and its completion instructions | Rahandusministri 10.06.2014 määrus nr 17 „Käibedeklaratsiooni vorm“, annex 1, in the wording of määrus nr 20 of 14.05.2025, in force 01.07.2025 | `riigiteataja.ee/aktilisa/1300/5202/5008/RAM_m17_lisa1.pdf`; the Tax and Customs Board publishes the same form, and an English edition, at `emta.ee` |
| Chart of accounts, internal rules, the statement schemes | Raamatupidamise seadus (RPS) § 8, § 11 and annexes 1 and 2 | `riigiteataja.ee`, act 110072025003; annex 1 in the wording of the Act of 18.09.2024, in force 01.07.2025 |
| How the schemes are presented | Raamatupidamise Toimkonna juhend RTJ 2, „Nõuded informatsiooni esitusviisile raamatupidamise aastaaruandes“ | `fin.ee`, and annex 2 to rahandusministri 22.12.2017 määrus nr 105 |
| E-invoicing | RPS § 7¹ (7), in force 01.07.2025, and the Ministry of Finance's page on source documents and e-invoices | `riigiteataja.ee`, same act; `fin.ee` |
| Where a declared period's balance lands | KMS § 27 (1), § 29 (1) and § 34 (1), with the Ministry of Finance's commentary of January 2026 | `riigiteataja.ee`, same act; `fin.ee` |
| Payment term, late-payment interest, recovery costs | Võlaõigusseadus § 82¹, § 113 and § 113¹ | `riigiteataja.ee`, act 120062026018 |
| The ISO 6523 identifiers on an e-invoice | Peppol code list of participant identifier schemes: `0191` Company code, `9931` Estonia VAT number | `docs.peppol.eu/poacc/billing/3.0/codelist/eas/` |

## The chart of accounts, and why this one

**Estonia prescribes no chart of accounts.** RPS § 8 obliges every accounting
entity to draw up its own, and § 11 obliges everyone but a micro-undertaking to
describe it in written internal rules. There is nothing to copy from a
statute, and nothing that could be called *the* Estonian chart.

This chart follows the convention Estonian software and bookkeepers share:

- **Four digits, four classes.** `1` assets, `2` liabilities **and equity
  together**, `3` income, `4` expenses. Equity has no class of its own.
- **Flat.** No parent accounts. A two- or three-digit account is a summary
  line rather than a posting account; every account here is a leaf, and the
  grouping is done by the `code_range` rules of `statements.json`.
- **Blocks that follow the statutory schemes.** Each range of codes maps onto
  one line of annex 1 or annex 2, so the balance sheet and the income statement
  are readable straight off the chart.

The chart is written for this pack. It is not a copy of any published chart.

**One deliberate departure.** Estonian practice numbers input VAT inside the
class-2 VAT group — `2310` output, `2311` input. The pack keeps those codes but
gives `2311` the account **type** `asset_current`, because it is a claim on the
tax authority and the type is what the core reads. The balance sheet splits
both VAT accounts by side: a debit balance is a prepaid tax, a credit balance
a tax payable.

## Taxes

A code is a rate at a date, and a new rate is a new code with a `valid_to` on
the old one. The pack therefore carries the standard rate three times:

| Rate | In force | Box on today's form |
|---|---|---|
| 20 % | 01.07.2009 – 31.12.2023 | 1¹ |
| 22 % | 01.01.2024 – 30.06.2025 | 1² |
| 24 % | from 01.07.2025 | 1 |

**The 24 % has no end date.** The reversion to 22 % on 1 January 2029 was
enacted by the Security Tax Act and then repealed with that Act.

The accommodation rate moved the other way: 9 % until 31.12.2024, 13 % from
01.01.2025, and the pack carries both. The press rate moved twice — 9 %, then
5 % from 01.08.2022, then 9 % again from 01.01.2025 — and the 5 % codes are
here because a cash-accounting taxable person may still reach them through the
transitional rule of KMS § 46 (2⁷) until the end of 2026: `EE-S-05-AJA` for
the seller and `EE-P-05-AJA` for the buyer, whose input VAT at 5 % is
deductible under § 29 (1) and goes to box 5 like every other domestic rate.

**The 50 % car restriction** is KMS § 30 (3), not § 30 (4): subsection 4 is the
list of exceptions, and subsection 7 is the two-year rule. It is 50 % of the
input VAT with no monetary cap, and it covers the car, its lease, and the goods
and services bought for it. It is modelled as a `tax` posting at 50 % onto the
input VAT account, and a `tax_on_base` posting at 50 % that lands the other
half on the accounts of the lines it taxes, because a share nobody gets back
is part of what the thing cost.

## Form KMD

`tax_report.json` carries the form in force since 1 July 2025.

**The box identifiers are transliterated.** The form numbers its boxes with
superscripts and with dots, and the pack format allows only letters and digits.
So `1¹ 1² 2¹ 2² 4¹` are written `1a 1b 2a 2b 4a`, and `3.1 3.1.1 3.2 3.2.1 5.1
5.2 5.3 5.4 6.1 7.1` are written `31 311 32 321 51 52 53 54 61 71`. Every box
names its printed identifier in the first words of its `legal_reference`.

**Every box of this pack is a box of the form.** The form nests — it asks for
the same amount in a box, in the memo box inside it and sometimes in a third —
so a posting names every box it prints in:

| A tax on | Names boxes | Printed identifiers |
|---|---|---|
| an intra-Community acquisition of goods | `1`, `6`, `61` | 1, 6, 6.1 |
| a service received from another Member State | `1`, `6` | 1, 6 |
| an acquisition under the § 41¹ arrangement | `1`, `7`, `71` | 1, 7, 7.1 |
| a service received from outside the Union | `1`, `7` | 1, 7 |
| an intra-Community supply of goods | `3`, `31`, `311` | 3, 3.1, 3.1.1 |
| a service supplied to another Member State | `3`, `31` | 3, 3.1 |
| an export | `3`, `32` | 3, 3.2 |
| input VAT on an import, a fixed asset or a car | `5` and the box for that kind | 5 and 5.1 to 5.4 |

**Boxes 6, 6.1, 7, 7.1 and 9 are informational**, in the instructions' own
words: their amounts are already inside box 1, or in box 9's case deliberately
outside it, and they feed no total. Box 9 is the trap worth naming — the
instructions say that a seller's § 41¹ turnover goes in box 9 and **not** in
box 1.

**Box 4 is summed from the ledger, not computed.** The form derives it
arithmetically — 24 % of box 1, 9 % of box 2, and so on — and the pack format
has no expression language. Each document's VAT is already rounded, so the sum
can differ from a percentage of the period total by a cent or two.

**Boxes 10 and 11** are declared and nothing posts to them. They carry the
year-end recalculations of KMS § 32 and § 30 (7), which are a bookkeeper's
entry and not a consequence of a document.

**Where a filed return's balance lands.** `defaults.roles` names `2370` for
`tax_payable` (under *Maksuvõlad*, range 2320–2399) and `1211` for
`tax_receivable` (under *Maksude ettemaksed ja tagasinõuded*, 1210–1219), two
reconcilable accounts only `settle_filing()` posts to. KMS § 29 (1) makes the
amount to pay output VAT less deductible input VAT, § 27 (1) makes it payable
by the twentieth of the following month, and § 34 (1) has an excess refunded
under the Taxation Act (the Ministry's commentary: MKS §§ 105 to 107, within
sixty days). Both are in practice settled through the Tax and Customs Board's
prepayment account; the core matches the money against the account.

**Electronic invoicing is owed on request.** `einvoicing.obligation` is
`on_request`: since 1 July 2025, RPS § 7¹ (7) lets a buyer registered as an
e-invoice recipient require one, and the Ministry of Finance says no general
B2B obligation exists and no date is planned, so `mandatory_from` is empty.
The public sector's obligation, in force since 2019, is not a B2B rule.

## Closing the year

`closing_style` is `result_accounts`: the result lands on `2980 Aruandeaasta
kasum (kahjum)` until the shareholders decide, because the statutory balance
sheet keeps it apart from `Eelmiste perioodide jaotamata kasum (kahjum)`. One
line holds both signs, so the manifest names `2980` as profit and loss account.

**No tax provision is booked, deliberately.** Estonia taxes distributed
profit, not earned profit. Tax on a distribution belongs to the future `tax`
module; `4990 Tulumaks` and `2360 Tulumaksukohustis` let one be booked by hand.

## What this pack does not carry

- **KMD INF**, the annex listing invoices of 1 000 euros or more per partner
  per period: a list of documents, which the pack format cannot describe.
- **The KMS § 44 cash-accounting scheme**: it applies to a whole taxable
  person, not to a tax; parallel tax codes would be a claim not supported.
- **The car counts of boxes 5.3 and 5.4**: a box here is a monetary amount.
- **Earlier versions of form KMD**: `vat_return()` takes the form in force at
  the end of the period; the 20 % and 22 % codes serve documents and credit
  notes, which the current form has boxes for.
- **The fixed assets module**: usual depreciation durations come from guidance
  rather than from a text, and this pack cites texts.
- **The XBRL fact keys of the annual report.** See below.

## The annual report, and why the statements carry no fact keys

Annual reports are filed to the Estonian Business Register in XBRL, against
the `et-gaap` taxonomy (`xbrl.eesti.ee`, EUPL), whose primary statements are
plain, non-dimensional concepts such as `et-gaap:CashAndCashEquivalents`. The
core's fact-key format cannot hold such a key — it expects a metric plus at
least one lower-case dimension member, and a dotted taxonomy version where the
Estonian one is a date — so `xbrl` and `taxonomy` are null on both statements
(see [`docs/international.md`](../../docs/international.md)). The line codes
follow the order of the statutory annexes, for a future `xbrl-ee` brick.

## Reviewing this pack

Open an issue titled "Review: Estonia". What a review is, and what it is not,
is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who may
say what". The points a reviewer is most likely to disagree with: the
informational boxes; the box a service received from outside the Union is
declared in; the invoice mention and tax treatment of an intra-Community
supply of services; and the two settlement accounts `2370` and `1211`, where
a reviewer who books the return against the prepayment account would name one
account for both.
