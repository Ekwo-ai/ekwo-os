# Solomon Islands

Everything Solomon Islands adds to Ekwo, as data: a chart of accounts, the
journals, the **goods tax** (10 % on prescribed locally manufactured goods,
15 % on imported goods, rice at zero) and the **sales tax** (10 % on fourteen
kinds of service), the monthly Goods Tax Return, form GT4, the monthly Sales
Tax Return, form ST4, and the statement of financial position and the statement
of profit or loss of an IFRS-based presentation. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and what it does not say yet.

**Status: `community`.** Nobody who files a Solomon Islands goods tax or sales
tax return has reviewed it. The figures are replayed against a month of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**No VAT.** Solomon Islands has no value added tax today: it has two
single-stage taxes without input credit, so no purchase is ever deducted and the
returns declare only what the taxpayer collected. A VAT is under preparation
(the press reports a VAT Bill 2025 before a parliamentary committee); no enacted
text was read, so the pack carries none. When it commences, this pack changes.

**English only.** The forms and the Acts are in English, the official language.
The currency is the Solomon Islands dollar (SBD, two decimals). The tax year is
the calendar year.

## Sources

Eight entries in `pack.json`, all read at source on the site of the Inland
Revenue Division (`ird.gov.sb`): the Goods Tax Act (Cap. 122) and the Order of
2019 that substituted its Second Schedule, the Sales Tax Act (Cap. 125) with its
Schedule One, forms GT4 and ST4 (revised August 2025, formerly GT3 and ST3) with
their instructions, IAS 1 and the portal. The two Acts are the reprints in force
on 5 February 2024 (Sales Tax Act) and 1 March 1996 (Goods Tax Act); the rates of
the goods tax are those of the Order of 2019.

## Decisions

- **Two returns, one report.** A pack carries one periodic form. Boxes G1 to G9
  are form GT4, boxes S1 to S4 form ST4, and box T is their sum, not a line of
  either form. A company registered for one tax leaves the other's boxes empty.
  Both returns are due on the same day, so one payment settles the single
  settlement account 2110.
- **No input credit.** Neither Act gives a purchaser a credit: the goods tax is in
  the price a wholesaler charges, and the sales tax a purchaser pays joins the
  cost (`SB-P-ST10`, `SB-P-0`). The tax accounts are 2100 (goods tax collected)
  and 2105 (sales tax collected); account 2110 is the settlement account.
- **Goods tax** is stated on the wholesale invoice (section 75) and charged on
  the sale value at the rate of the Second Schedule. The pack takes the invoiced
  amount as the sale value; the valuation rules of the instructions (retail sales
  by a manufacturer, own use, 130 % of cost) are the preparer's.
- **Rice** is declared in box G3 at zero. Form GT4 and its instructions tax it at
  zero percent; the Second Schedule (Order of 2019) still says 5 %. The pack
  follows the current form, and a reader who finds the 5 % applied should say so.
- **Monthly returns, due on the 30th** of the month after the sales (forms GT4
  and ST4, Sales Tax Act section 14). In February the 30th does not exist: the
  rule gives no date shift, and the preparer files by the last day.

## What the pack does not say yet

- **Sales tax at an amount per unit.** Overseas and domestic air tickets ($10
  each), video hire ($2 a tape), movie tickets (50 cents), the casino entrance
  fee ($5) and petroleum and diesel (10 cents a litre) are in Schedule One but a
  tax code here is a percentage: they are not carried.
- **Hairdressers, barbers and beauty parlours**: the Act says $5, the August 2025
  instructions say 10 %. The texts differ and the item is not carried.
- **Goods tax on imports** is paid by the importer to Customs at the port of
  entry; it is not a line of the return and the pack has no code for it (the
  goods tax in the cost is `SB-P-0`).
- **Quoting certificates**, the minimum wholesale value, goods tax on goods
  applied to own use or given away, and the refund of tax on bad debts (Goods Tax
  Act section 47) are not modelled.
- **Credit sales of goods** may pay sixty days after the month (section 42); the
  pack applies the thirty-day rule.
- **Registration** (manufacturers, wholesalers and vendors of Schedule One
  services): no threshold was found on the pages read, so the pack controls none.
- **Services bought from abroad.** The Acts and forms read give no line for them;
  recorded in `not_taxed`.
- **Other taxes** (income tax, PAYE, National Provident Fund, stamp duty, customs
  and excise duties) are not in the pack beyond their liability accounts.
- **Penalties and interest** are not computed.
- **Statements.** No text read prescribes a layout; the IFRS-style statements
  follow IAS 1 with expenses by nature.
- **E-invoicing.** None found, so `obligation` is `none`.
