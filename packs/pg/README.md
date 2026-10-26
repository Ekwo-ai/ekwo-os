# Papua New Guinea

Everything Papua New Guinea adds to Ekwo, as data: a chart of accounts, the
journals, the goods and services tax (GST) at 10 %, the zero rate and the
exemptions, the monthly GST return, form G1, with its sixteen lines, and the
statement of financial position and the statement of profit or loss of an
IFRS-based presentation. The format is [`docs/packs.md`](../../docs/packs.md);
this file says where the content came from and what it does not say yet.

**Status: `community`.** Nobody who files a Papua New Guinea GST return has
reviewed it. The figures are replayed against a month of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**English only.** The forms are in English. English, Tok Pisin and Hiri Motu are
official languages; the pack declares `en` alone. The currency is the kina (PGK,
two decimals).

## Sources

Five texts, in `pack.json`: the IRC's form G1 (effective 24 January 2016) with its
notes, the IRC's fact sheet on section 65A of the GST Act, a guide to GST written
by a professional firm, IAS 1 and the IRC portal. The text of the Goods and
Services Tax Act 2003 itself could not be opened from the machine this pack was
written on (PacLII and the IRC site answer 403 to an automated read): the
lists of exempt and zero-rated supplies are those the notes of form G1 give, and
no section number is quoted from the Act except section 65A, as the IRC quotes it.
The 10 % rate and the 21st-day deadline are stated by the IRC fact sheet; the
registration threshold (K250,000) and the extra zero-rated supplies come from the
professional firm's guide only.

## Decisions

- **The sales side of G1 is GST-inclusive.** Line 1 includes the GST; line 5, the
  taxable sales, is line 1 less lines 2 and 3 (line 4); line 6, the output
  debits, is line 5 divided by eleven. The engine posts exclusive bases, so the
  pack posts the exclusive taxable sales to box 5a (not a line of the form) and
  rebuilds line 5 (= 5a + line 6) and line 1 (= lines 4 + 5) as totals.
- **The purchases side declares the GST only.** Line 8 is the GST paid on
  business inputs; the exclusive bases go to boxes 8a (local) and 8b (imports),
  which are not lines of the form.
- **Imports** carry their GST paid at the border into line 8 (note 4). Line 7 is
  for approved entities whose import GST is deferred and is declared and empty.
- **Line 16, the section 65A credit**, is subtracted in line 15, as the IRC fact
  sheet does in its example (GST payable K250, section 65A payment K1,000,
  refundable K750). The order of lines 15 and 16 on the printed form is not
  clear in the text extracted from the PDF.
- **Monthly return, due on the 21st** of the month after the tax period (IRC fact
  sheet). The guide read says returns are lodged monthly; the pack does not model
  a longer period.
- **Rates carried from 1 January 2024.** The texts read state 10 % without a
  history; no code is valid before that date.

## What the pack does not say yet

- **The Act and its Schedules** were not read at source (see above). Which
  supplies are zero-rated or exempt is the preparer's judgement within
  `PG-S-ZR` and `PG-S-EX`. The guide lists zero-rated supplies to resource
  companies, approved charities and foreign aid providers that the form does not;
  they are not named in the tax codes.
- **Registration** above K250,000 of taxable supplies, and any period longer than
  a month for small taxpayers, are facts of secondary sources, not controls of the
  pack.
- **Apportionment** of the GST paid on inputs used for both exempt and taxable
  sales (note 5, line 9) and the GST of private use (note 6, line 10) are the
  preparer's: both boxes are declared and empty.
- **Sales by province** (page 2 of the form, one row per province) are not
  produced.
- **Employee benefits** (note 1: meals at 30 kina a fortnight and the cost of the
  other benefits, included in line 1) and the exempt motor vehicle and housing
  benefits are not modelled.
- **Cars** (note 7) carry no input credit: `PG-P-10-NC` is a code the preparer
  chooses, nothing detects a car.
- **Section 65A withholding**: the G2, G4, G5 and G6 remittance forms are not
  modelled; line 16 is declared and empty.
- **Services bought from abroad.** The guide says reverse charge provisions exist
  for certain supplies from outside the country; the form has no line for them and
  no code is carried.
- **Refund claims** need a supplier listing attached to the return (IRC fact
  sheet); it is not produced.
- **Cash or invoice basis, tax point.** Not stated by the texts read; the pack
  uses the invoice date.
- **Penalties and interest** are not computed. **Other taxes** (income tax, salary
  and wages tax, withholding taxes, superannuation, excise, customs duties) are
  not in the pack beyond their liability accounts.
- **Statements.** No text read prescribes a layout; the IFRS-style statements follow
  IAS 1 with expenses by nature.
- **E-invoicing.** None found, so `obligation` is `none`.
