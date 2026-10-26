# Samoa

Everything Samoa adds to Ekwo, as data: a chart of accounts, the journals, the
value added goods and services tax (VAGST) at 15 %, the zero rate and the
exemptions, the two-monthly VAGST return, form VAGST 001, with its fifteen
boxes, and the statement of financial position and the statement of profit or
loss of an IFRS-based presentation. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and what it does not say yet.

**Status: `community`.** Nobody who files a Samoan VAGST return has reviewed it.
The figures are replayed against two months of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**English only.** The forms and the Act are in English (the Ministry's notices
are bilingual). English and Samoan are official languages; the pack declares
`en` alone and carries no Samoan translation of the chart or the statements.
The currency is the tala (WST, two decimals). The tax year is the calendar year
(Income Tax Act 2012, section 2), so the fiscal year default is `calendar`.

## Sources

Eight entries in `pack.json`, all read at source on the Ministry of Revenue site
(`revenue.gov.ws`): the Value Added Goods and Services Tax Act 2015, form
VAGST 001, the Ministry's due-date notice for March 2025, the VAGST registration
form IR31, the Tax Administration Act 2012, the Income Tax Act 2012, IAS 1 and the
Ministry's portal. The rate (section 8), the periods (section 29), the return and
payment date (sections 41 and 42), the time of supply (section 15), the input tax
credit (section 26) and the two Schedules of exempt and zero-rated supplies were
read in the Act; the boxes and the 7.66667 divisor in the form.

## Decisions

- **The form is VAGST-inclusive.** Box 3 is the total sales including VAGST, box
  4 the zero-rated supplies, box 5 the taxable sales (box 3 less box 4) and box 6
  the VAGST collected, box 5 divided by 7.66667 (15/115). The engine posts
  exclusive bases, so the pack posts the exclusive taxable sales to box 5a (not a
  box of the form) and rebuilds box 5 (= 5a + box 6) and box 3 (= boxes 4 + 5) as
  totals. The purchases side is the same: box 9a (not a box of the form), box 10.
- **Imports** carry the VAGST paid to the Customs Service into box 11, "tax
  adjustments, including VAGST paid to Customs"; box 9 excludes it. The customs
  value goes to box 11a, which is not a box of the form.
- **Exempt sales have no box.** The form asks for total sales and zero-rated
  supplies only; an exempt supply is not a taxable supply and the pack posts it to
  no box. `WS-S-EX` is a tax code with no posting.
- **Box 13 and box 15 are signed:** negative is the VAGST credit, positive the
  VAGST to pay. Box 14, the credit brought forward, is declared and empty and
  subtracted in box 15 as the form says.
- **The tax point is the invoice** where one is issued (section 15(1): the earlier
  of the invoice and the first payment).
- **The two-month period** is declared as a `bimonth` (see below). The deadline is
  15 working days after the end of the period (section 41(1)); the Ministry's own
  notice gives 22 April 2025 for February–March. That count depends on public
  holidays, so the pack declares `depends_on_taxpayer` and no day of the month.
- **Rates carried from 1 January 2015**, the year of the Act, as an approximation:
  the commencement date was not read, and the texts give no other rate.

## What the pack does not say yet

- **Category A periods.** The Act (section 29) puts a registered person in
  Category A (two-month periods ending in January, March, May, July, September,
  November) or Category B (ending in February, April, June, August, October,
  December). The pack format anchors a `bimonth` on January–February, which is
  Category B; a Category A taxpayer's periods (December–January, February–March…)
  cannot be declared. This is a gap of the core, not of the pack. A Category C
  (shorter periods for a person who fails to comply) is not modelled either.
- **Registration.** Section 9(2) sets the registration threshold at *at least*
  $130,000 of taxable supplies in 12 months; the actual figure and voluntary
  registration are not controls of the pack.
- **Tax point on payment first and input credit on payment.** A payment received
  before the invoice brings the supply forward (section 15(1)(b)), and the input
  tax credit is allowed in the period in which the input tax is *paid*
  (section 26(2)): the engine models neither, only the invoice date.
- **Services bought from abroad.** The registered recipient is liable under
  section 8(1)(c) and prepares a recipient-created tax invoice (section 19(3));
  the form has no box for it and a fully taxable person owes and recovers the
  same amount, so no code is carried. A partly exempt person's partial credit
  (section 19(2)) is not modelled.
- **Tax adjustments** (boxes 7 and 11): adjustment events, bad debts, private or
  exempt use (section 20), second-hand goods (section 21), vouchers (section 22),
  lay-by sales (section 23) are the preparer's; both boxes are declared and
  partly empty.
- **Which supplies are zero-rated or exempt** within `WS-S-ZR` and `WS-S-EX` is
  the preparer's judgement, and the conditions of Schedule 3 (28 days for an
  export, proof for a service used abroad) are not controls of the pack.
- **Penalties and interest** are not computed. The Ministry's March 2025 notice
  states late filing fees of $300 per return for a company or trust and $100 for
  a sole trader, late payment interest of 8.7 % and a late payment penalty of
  10 % of the tax payable; they are recorded here, not in the data.
- **Tax Invoice Monitoring System.** The Ministry's TIMS (point-of-sale devices
  reporting sales) is not modelled; no structured e-invoice standard was found,
  so `obligation` is `none`.
- **Other taxes** (income tax, salary and wages tax, withholding taxes, excise,
  customs duties) are not in the pack beyond their liability accounts; no
  National Provident Fund rule is carried, the account is a generic
  superannuation account.
- **Statements.** No text read prescribes a layout or a framework; the IFRS-style
  statements follow IAS 1 with expenses by nature. A Samoan professional should
  say which framework Samoan companies use.
- **Samoan language.** No translation of the chart or the statements.
