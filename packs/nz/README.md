# New Zealand

Everything New Zealand adds to Ekwo, as data: a chart of accounts, the
journals, the goods and services tax and where each code posts, the GST
return, the statement of financial position and the statement of profit or
loss of a Tier 2 for-profit entity, and the sentences the law puts on a tax
invoice. The format is [`docs/packs.md`](../../docs/packs.md); this file says
which sources and decisions the content rests on, so that a New Zealand
accountant can disagree with a specific sentence rather than with the whole.

**Status: `community`.** Nobody who files a New Zealand GST return has
reviewed it. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right. The pack shares its chart shape and Peppol
specification with [`packs/au/`](../au/README.md). What the core cannot say
yet is in
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`,
and beside it the key of the text that article is in. The register in
`pack.json` holds nineteen texts.

**A limit worth stating plainly.** The operative numbers — the 15 % rate, the
$60,000 registration threshold, the $24 million mandatory-monthly and $500,000
six-monthly filing thresholds, the $2 million payments-basis threshold, the
due-date rule with its two calendar exceptions, and the $200/$1,000 taxable
supply information tiers — are those of IR375 (*GST guide: Working with GST*,
March 2026). The **exact subsection letters** of several provisions of the
Goods and Services Tax Act 1985 — ss. 19E–19N, s. 8(4B), s. 11(1)(mb),
s. 11(1)(m) — rest on secondary sources; the consolidated text on
`legislation.govt.nz` should be checked (see "Reviewing this pack").

| What | Text | Where |
|---|---|---|
| The charge, the rate, zero-rating, exempt supplies, imported services, tax periods, returns, attribution | Goods and Services Tax Act 1985 | `legislation.govt.nz/act/public/1985/0141` |
| The income year and the standard balance date | Income Tax Act 2007 | `legislation.govt.nz/act/public/2007/0097` |
| Who prepares financial statements, and when | Companies Act 1993, Part 11; Financial Reporting Act 2013 | `legislation.govt.nz` |
| The form of the statements | XRB A1, Tier 2 (NZ IFRS with reduced disclosure) | `xrb.govt.nz` |
| What each box of the return holds, filing frequency, due dates, taxable supply information | IR375, *GST guide: Working with GST* (March 2026) | `ird.govt.nz` |
| Electronic invoicing | PINT A-NZ Billing, OpenPeppol | `docs.peppol.eu` |

## The chart of accounts, and why this one

**New Zealand prescribes no chart of accounts.** Companies Act 1993, s. 194,
requires a company to keep accounting records that correctly record and
explain its transactions and would let financial statements be readily and
properly prepared and audited, and says nothing about a ledger. Section 201
requires a "large" company (Financial Reporting Act 2013, s. 45 — measured
against consolidated asset and revenue thresholds the Act and its regulations
set, or an FMC reporting entity) to prepare financial statements complying
with generally accepted accounting practice every year, and a company that is
not large only where its shareholders have not unanimously resolved out of the
obligation under s. 207I. Most New Zealand companies prepare no statutory
financial statements; their books still feed the income tax return and the
GST return.

So the chart is written, not transcribed:

- **Four digits, by class.** `1` assets, `2` liabilities, `3` equity, `4`
  revenue and other income, `5` goods and materials used, `6` other expenses,
  `7` finance costs, `8` income tax.
- **Flat.** No parent accounts; the grouping is done by the ranges of
  `statements.json`.
- **Cost and accumulated depreciation are adjacent**, `1630` and `1631`.
- **The accounts New Zealand law and practice ask about have names a New
  Zealand bookkeeper recognises**: KiwiSaver employer contributions, ACC
  levies, PAYE, resident withholding tax, Inland Revenue's own return balance,
  use-of-money interest.

163 accounts, all postable.

**Five GST accounts.** `2100` holds the GST on sales and `1150` the GST
credits on purchases. `2105` and `1152` hold the GST of documents accounted
for on the payments basis until they are paid. `2110` is the GST payable to
Inland Revenue and `1155` the refund due, both reconcilable, and no tax posts
to either — Box 15 nets them.

## Taxes

**One rate since 1 October 2010.** Section 8(1) has put GST at 15 % of the
value of a taxable supply since that day (12.5 % from 1 July 1989, and 10 %
from the tax's introduction on 1 October 1986). Neither earlier rate is
carried.

**Exempt is not zero-rated, and the difference is whether the supply appears
in the return at all.** IR375: "GST is not charged on exempt supplies, and
they're not included in your GST return... You do not show income from the
exempt supply in your GST return." So every exempt code (`NZ-S-EXEMPT-FIN`,
`NZ-S-EXEMPT-RES`) posts a `base` with **no box at all** — as `NZ-S-NOGST`
does for a sale outside the charge — while every zero-rated code posts to
Box 5 *and* Box 6, because a zero-rated supply is still a taxable supply at a
nil rate.

**Four ways a sale is zero-rated, each with its own code:** export of goods
(`NZ-S-ZERO-EXPORT`, s. 11(1)(a)), export of services to a person outside New
Zealand (`NZ-S-ZERO-SERVICES`, s. 11A(1)), the sale of a taxable activity as a
going concern (`NZ-S-ZERO-GOINGCONCERN`, s. 11(1)(m)), and the compulsory
zero-rating of land between two GST-registered parties (`NZ-S-ZERO-LAND`,
s. 11(1)(mb), in force from 1 April 2011). The two export codes carry
`vat_category` `G`, the two domestic zero-rated codes `Z`, per the table of
`docs/packs.md` under "What a tax says on the invoice". The rest of ss. 11 and
11A — international transport, fine metal, a handful of other named
supplies — is not carried.

**The imported-services reverse charge reaches the business that cannot claim
it back.** Section 8(4B) treats a registered recipient of imported services as
having supplied them to themselves, and charges GST, wherever the extent of
their taxable use is below 95 %. `NZ-P-RC-IMPORTED` is the code for that
recipient — the golden year books a property manager's software subscription
used for a residential letting, itself exempt — so the GST is self-charged
(Box 8) and lands on the account of the line. A recipient whose taxable use
reaches 95 % needs no code: s. 8(4B) does not reach the supply. **How a partly
creditable case between the two is reported on GST101A is open; see
"Reviewing this pack".**

**The payments basis is a regime of the business, carried as codes.** Section
20(3) lets a registered person under $2,000,000 of turnover account for GST
when a sale is paid rather than when it is invoiced; the core has no regime of
a company, so `NZ-S-GST-PAY` and `NZ-P-GST-PAY` sit beside the invoice-basis
codes. The golden year uses both once each, landing one period later than the
invoice basis would.

**No entertainment adjustment, no partial credit, no schedular-payment
withholding.** The GST output-tax adjustment tied to the 50 % of entertainment
expenditure not deductible for income tax is not carried; its section number
is unconfirmed, and entertainment should use `NZ-P-GST` until a reviewer
supplies the citation. Schedular-payment withholding tax is not a GST
mechanism, is not reported on GST101A, and is not carried.

## The statement

`tax_report.json` is form **GST101A**, the return a registered person who is
not liable for provisional tax files; a person who is files a form of the
**GST103 series**, which folds in a provisional income tax instalment and is
not carried.

**One GST-inclusive figure.** GST101A's Box 5 is "Total sales and income for
the period (**including GST** and any zero-rated supplies)", with no
GST-exclusive option. A standard-rated posting therefore grosses the value of
the supply to 115 % on the `base` posting itself and writes it into Box 5; a
zero-rated posting writes its value at 100 %, into Box 5 and Box 6 alike.
Box 11 is built the same way, at 115 % for a creditable standard-rated
purchase. Every box a posting prints in is a box GST101A itself carries.

**Box 8 and Box 12 are the ledger's own figure, not the form's worksheet
arithmetic.** GST101A instructs a filer to find the GST inside Box 5 by
"multiply the amount in Box 7 by three (3) and then divide by twenty-three
(23)". This pack keeps the per-transaction record, so the GST of every sale
posts straight to Box 8 and of every purchase to Box 12; the two methods agree
to the cent whenever every rate is 0 % or 15 %, because 3/23 of 115 % of a
value is exactly 15 % of it. `golden/expectations.json` states the
substitution. Box 8 (Box 12 on the purchase side) is also where
`settle_cash_basis_tax()` moves the payments-basis GST once a document is
paid.

**Box 15 is a subtraction, and a refund comes out negative.** The form prints
a positive figure and a tick box; the pack writes Box 10 minus Box 14.

**Three cadences declared, one default, and an anchoring the core cannot
express.** Section 15 gives every registered person a two-monthly taxable
period unless they elect monthly (s. 15A) or, under $500,000 of turnover in a
twelve-month period, six-monthly (s. 15B); s. 15C requires monthly above
$24 million. `period` lists `month`, `bimonth` and `half_year`;
`period_default` is `bimonth`. A New Zealand two-monthly period follows the
taxpayer's own balance date — IR375 gives a March balance date's periods as
"April-May, June-July, August-September, October-November, December-January,
February-March" — where the core's cadence is anchored to 1 January. The
golden year is therefore dated on the calendar year, and a company with the
ordinary 31 March balance date cannot yet be filed on this `bimonth` cadence.

**The deadline is the 28th, with two calendar exceptions this format cannot
carry.** IR375: "The due date is usually the 28th of the month following the
end of your taxable period, except for return periods ending: 30 November —
the due date is 15 January of the following year; 31 March — the due date is
7 May of the same year." The pack declares the 28th: correct for ten of the
twelve months, too early for the other two. The weekend-and-public-holiday
roll-forward is not carried either.

## The accounts

`statements.json` carries the statement of financial position and the
statement of profit or loss of a **Tier 2** for-profit entity under NZ IFRS
with the Reduced Disclosure Regime, which XRB A1 assigns to a reporting
entity that has no public accountability and elects reduced disclosure.

**The lines are NZ IAS 1's minimum items**, in the order New Zealand practice
prints them, classified current and non-current. Biological assets,
non-controlling interests and assets held for sale are not lines: the chart
has no account for them.

**GST is a receivable and a payable, not current tax.** Current tax in New
Zealand is income tax, so GST balances report among trade and other
receivables and payables.

**Expenses by nature.** NZ IAS 1 allows nature or function, and a small
company's ledger holds nature without any allocation.

**No fact keys.** `xbrl` and `taxonomy` are null on both statements.

## Closing the year

`fiscal_year_default` is `april`: the standard income year runs 1 April to
31 March, the ordinary balance date under the Income Tax Act 2007 and the
government's own fiscal year. A company may adopt another balance date; the
default is a proposal. The golden scenario uses a calendar year, for the
reason under "The statement".

`closing_style` is `retained_earnings`: the result goes straight into `3200
Retained earnings`. `3210 Dividends paid` sits beside it and is booked by
hand.

No income tax provision is booked by the close. The chart carries `8000` to
`8020`, `2300` and the deferred tax accounts so that it can be.

## On the invoice

**Taxable supply information replaced the tax invoice on 1 April 2023.** The
Taxation (Annual Rates for 2022–23, Platform Economy, and Remedial Matters)
Act 2022 rewrote ss. 19E to 19N of the GST Act. Per IR375: a supply of $200
or less needs only the seller's name or trade name, the date, a description
and the consideration; above $200 the seller's GST number is added; above
$1,000 a GST-registered buyer's name and one further identifying particular —
an address, a phone number, an email, a trading name, an NZBN or a website.
None of the three tiers asks for a document number.

**Numbering is `free`**, for that reason.

**Two mentions.** An export and an exempt supply each carry a sentence saying
why no GST is charged. A domestic zero-rated supply carries no mention of its
own: `applies_when` resolves `export` and `exempt` from the tax's
`treatment`, and a domestic zero-rated line already shows no GST.

**No payment term and no late payment interest.** No New Zealand statute sets
either between businesses in the absence of an agreement.

**The tax point is the earlier of the invoice and the first payment**
(s. 9(1)); `invoice_if_issued` is the closest word the format has. The
payments basis is carried as `cash_basis` on the taxes that use it.

## Electronic invoicing

The profile is `pint-aunz`, the PINT A-NZ Billing specification exchanged on
the Peppol network New Zealand shares with Australia. `obligation` is `none`:
no statute obliges a New Zealand business to send or receive an electronic
invoice, though central government agencies are increasingly asked to under
policy. `party_scheme` and `vat_scheme` are left **null**: a New Zealand party
is addressed by its NZBN and taxed on its IRD/GST number, but the ISO 6523 ICD
code of the NZBN on Peppol is not confirmed (the EAS code list at
`docs.peppol.eu` does not name it). A reviewer who can confirm it should add
it.

## What this pack does not carry

- **GST103 and the provisional tax instalment** folded into it.
- **The entertainment expenditure GST adjustment** — see "Taxes".
- **Schedular-payment withholding tax** on a contract payment (Income Tax
  Act 2007, sch. 4), including the no-notification rate: not a GST mechanism.
- **A partly creditable case of the imported-services reverse charge** — see
  "Taxes".
- **Adjustments** other than a credit note: the calculation-sheet adjustments
  of Box 9 and Box 13, change-in-use adjustments, the wash-up rule, and the
  apportionment of a purchase used partly for taxable and partly for exempt or
  private purposes.
- **Imported goods cleared through Customs**, assessed on an import entry and
  excluded from Box 11 by the form's own words.
- **The low-value imported goods rules** (NZD 1,000 or less) and the "listed
  services" rules for electronic marketplaces: obligations of an offshore
  supplier or a marketplace operator, not of the business this pack books.
- **GST groups and branches**, and the margin scheme for secondhand goods.
- **Fixed assets.** No `fixed_assets.json`.
- **Bank formats.** No statement format is declared.
- **myIR filing.** Submitting the return is a format library and a credential,
  not a pack.

## Reviewing this pack

Open an issue titled "Review: New Zealand". What a review is, and what it is
not, is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and
who may say what". Points a chartered accountant or a tax agent should read
first, roughly in the order the author is least sure of them:

1. **Every subsection letter this pack cites against the GST Act** —
   ss. 19E–19N, s. 8(4B), s. 11(1)(mb), s. 11(1)(m), s. 20(3) — should be
   checked against the consolidated text on `legislation.govt.nz`. See
   "Sources".
2. **The ISO 6523 ICD code for the NZBN** on Peppol, left null — see
   "Electronic invoicing".
3. **Box 5 and Box 11 grossed to 115 % on the posting itself**, instead of
   the form's own multiply-by-three-divide-by-23 worksheet arithmetic to
   reach Box 8 and Box 12 — see "The statement".
4. **The imported-services reverse charge modelled as wholly non-creditable**,
   with no partly-creditable case between 95 % and full non-creditability —
   see "Taxes".
5. **The `bimonth` cadence anchored to the calendar year** rather than to a
   company's own balance date, which is what New Zealand law requires — see
   "The statement".
6. **The 28th as the one declared deadline**, five weeks early for the period
   ending 30 November and three weeks early for the period ending 31 March.
7. **GST in trade and other receivables and payables**, rather than netted or
   under current tax.
8. **The chart's mapping onto NZ IAS 1's minimum line items**, especially
   right-of-use assets inside property, plant and equipment and the credit
   card inside financial liabilities.
9. **`numbering: free`**, which rests on ss. 19E–19N naming no document number
   among the particulars of taxable supply information.
