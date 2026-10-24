# Fiji

Everything Fiji adds to Ekwo, as data: a chart of accounts, the journals, value
added tax at 12.5 % (and the closed 15 % codes of 1 August 2023 to 31 July
2025), the zero rate and the exemptions, the VAT return IRS217 with its thirteen
boxes, and the statement of financial position and the statement of profit or
loss of an IFRS-based presentation. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and what it does not say yet.

**Status: `community`.** Nobody who files a Fiji VAT return has reviewed it. The
figures are replayed against a month of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

**English only.** English is the language of the Value Added Tax Act and of the
documents of the Fiji Revenue and Customs Service (FRCS). Fijian and Hindi are
also official languages; the pack declares `en` alone. The currency is the
Fijian dollar (FJD, two decimals).

## Sources

Eight texts, all from FRCS or the IFRS Foundation, in `pack.json`: the VAT
Guide (1 November 2023), the rate and tax-label page of FRCS (12.5 % from
1 August 2025), the return IRS217 and its instructions, the Tax Talk article on
the return lines, the IFRS profile of Fiji, IAS 1, and the FRCS portal. The text
of the Value Added Tax Act 1991 itself could not be opened from the machine this
pack was written on (the PacLII server refuses automated reads): the lists of
the First and Second Schedules are those the VAT Guide gives, and the
section numbers are those FRCS quotes.

## Decisions

- **The rate moved twice.** The file of countries said 15 %; FRCS now lists
  12.5 % (tax fraction 1/9) from 1 August 2025. `FJ-S-12.5` and `FJ-P-12.5`
  open on that date; `FJ-S-15` and `FJ-P-15` stay as closed codes
  (1 August 2023 to 31 July 2025) so older books stay readable.
- **The form is VAT-inclusive.** Box 1 and box 3 of IRS217 include the VAT. The
  engine posts exclusive bases, so the pack posts the exclusive supplies to box
  3a (not a box of the form) and rebuilds box 3 (= 3a + box 4) and box 1
  (= box 2 + box 3) as totals. Box 13 is signed: negative is the refund due.
- **One purchase line.** The form has no line for capital goods or for
  non-deductible purchases; capital goods go to box 7, and a purchase on which
  no input tax is claimed posts to no box.
- **Imports** go to box 8 (VAT invoiced by Customs).
- **Filing.** Monthly, quarterly or annual; due on or before the last day of the
  month following the period. Payment is due with the return.

## What the pack does not say yet

- **The Act and its Schedules** were not read at source (see above). Which
  supplies are zero-rated or exempt is the preparer's judgement within
  `FJ-S-ZR` and `FJ-S-EX`.
- **The 5 % tourism rate** that the FRCS rate table lists (label H – TST, from
  1 September 2026, tourism operators above FJ$2 million) is not modelled: the
  page gives no definition, and it is not clear whether it replaces or adds to
  the 12.5 %. A tourism operator needs its accountant here.
- **Reverse charge.** The instructions of box 7 mention it without defining it.
  No code is carried.
- **The 9 % rate** of before 1 August 2023 is not carried.
- **Payment basis.** FRCS allows it on approval; the pack accounts on the
  invoice basis.
- **Boxes 5, 9 and 11** (adjustments, apportionment) are declared and empty.
  The FJ$5 minimum of box 13 is not applied.
- **Input tax schedule**, required with the return, is not produced.
- **Other taxes** (income tax, PAYE, FNPF, excise, customs duties) are not in
  the pack beyond their liability accounts.
- **Statements.** No Fiji text prescribes a layout; the IFRS-style statements
  follow IAS 1 with expenses by nature.
- **E-invoicing.** None found, so `obligation` is `none`.
