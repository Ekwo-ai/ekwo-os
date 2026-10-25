# Kiribati

Everything Kiribati adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 12.5 %, the zero rate and the exemptions, the quarterly VAT
return RET 020 with its sixteen boxes, and the statement of financial position
and the statement of profit or loss of an IFRS-based presentation. The format
is [`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and what it does not say yet.

**Status: `community`.** Nobody who files a Kiribati VAT return has reviewed it.
The figures are replayed against a quarter of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**English only.** The forms are in English; the return instruction is written in
Gilbertese with the English terms. Gilbertese is an official language and the
pack declares `en` alone. The currency is the Australian dollar (AUD, two
decimals), the legal tender of Kiribati.

## Sources

Eight texts, all from the Kiribati Tax Division (Ministry of Finance and
Economic Development) or the IFRS Foundation, in `pack.json`: the Guidelines &
Obligations of VAT Registered Businesses, the sheet of exempt and zero-rated
supplies (August 2024), the form RET 020 and its instruction, the Taxpayer's
Obligation pamphlet (January 2026), the VAT page, IAS 1 and the portal. The text
of the Value Added Tax Act 2013 itself could not be opened from the machine this
pack was written on (the PacLII server refuses the connection and the Ministry's
old address answers 404): the lists of exempt and zero-rated supplies are those
the Tax Division's sheet gives, and the section numbers are those it quotes.

## Decisions

- **The form is VAT-inclusive on both sides.** Boxes 1, 4, 8 and 10 of RET 020
  include the VAT. The engine posts exclusive bases, so the pack posts the
  exclusive sales to box 4a and the exclusive purchases to box 10a (not boxes of
  the form) and rebuilds boxes 4 (= 4a + box 5), 10 (= 10a + box 11), 1 (boxes
  2 + 3 + 4) and 8 (boxes 9 + 10) as totals. Box 16 is signed: negative is the
  VAT credit.
- **Exempt sales are in box 1.** The instruction of box 1 includes the zero-rated
  and the exempt sales; boxes 2 and 3 take them out of box 4.
- **Quarterly only.** The guidelines and the pamphlet give one cadence, the
  quarter, due within 15 days after its end; the pack declares the 15th of the
  following month.
- **Imports** go to box 12 (VAT paid to Customs); the instruction keeps them out
  of box 8.
- **Rates carried from 1 January 2024.** The documents read are dated 2024 to
  2026 and state 12.5 %; no earlier rate history was read, so no code is valid
  before that date.

## What the pack does not say yet

- **The Act and its Schedules** were not read at source (see above). Which
  supplies are zero-rated or exempt is the preparer's judgement within
  `KI-S-ZR` and `KI-S-EX`.
- **Registration** at $100,000 of sales is a fact of the guidelines, not a
  control of the pack.
- **Apportionment** of input tax when part of the sales is exempt (80 % and 20 %
  thresholds of the sheet) is the preparer's: the pack posts every standard-rated
  purchase to box 11.
- **Box 9** receives the exclusive value of non-creditable purchases, where the
  form asks for the amount paid; for a purchase with VAT that is not claimed the
  figure is understated by the VAT.
- **Boxes 6, 13 and 14** (adjustments, VAT withheld by the Government, credits of
  earlier returns) are declared and empty.
- **Services bought from abroad.** The texts read do not say how the recipient
  accounts for them: no code is carried. Foreign suppliers file a simplified
  return of their own, which is not modelled.
- **Cash or invoice basis, tax point.** Not stated by the texts read; the pack
  uses the invoice date.
- **Penalties and interest** ($30 a month of late filing, 15 % on late payment,
  15 % a year of interest) are not computed.
- **Other taxes** (income tax, PAYE, withholding tax, provident fund, excise,
  customs duties) are not in the pack beyond their liability accounts.
- **Statements.** No Kiribati text prescribes a layout; the IFRS-style statements
  follow IAS 1 with expenses by nature.
- **E-invoicing.** None found, so `obligation` is `none`.
