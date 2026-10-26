# Vanuatu

Everything Vanuatu adds to Ekwo, as data: a chart of accounts, the journals, the
value added tax (VAT) at 15 %, the zero rate and the exemptions, the monthly (or
three-monthly) VAT return, form CT 205, with its boxes, and the statement of
financial position and the statement of profit or loss of an IFRS-based
presentation. The format is [`docs/packs.md`](../../docs/packs.md); this file says
where the content came from and what it does not say yet.

**Status: `community`.** Nobody who files a Vanuatu VAT return has reviewed it.
The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**English only.** The Act and the form are in English; Bislama, English and French
are the official languages, and the Department publishes the return in the three.
The pack declares `en` alone and carries no Bislama or French translation of the
chart or the statements. The currency is the vatu (VUV), which has **no decimals**:
every amount of the pack is a whole number. The tax year is the calendar year, so
the fiscal year default is `calendar`.

## Sources

Nine entries in `pack.json`, all read at source on the site of the Department of
Customs and Inland Revenue: the Value Added Tax Act [Cap. 247] (Consolidated
Edition 2020), the VAT return form CT 205, the introduction to VAT, the notice of
the change of the rate to 15 %, the brochure *Filing your VAT Return*, the VAT
registration application, the Tax Administration Act No. 37 of 2018, IAS 1 and the
Department's portal. The rate (section 11), the registration threshold (section 12),
the periods (section 15), the return and its date (section 16), the accounting
basis (section 17), the time of supply (section 5) and the Schedules of exempt and
zero-rated supplies were read in the Act; the boxes and the 7.6667 divisor in the
form; the 1 January 2018 date of the 15 % rate in the Department's notice. The
Department's site answers on two host names (`vanuatucustoms.gov.vu` and
`customsinlandrevenue.gov.vu`); the URLs are those that were reachable when read.

## Decisions

- **The form is VAT-inclusive.** Box 5 is the total sales and income including VAT,
  box 6 the zero-rated supplies, box 7 the taxable sales (box 5 less box 6) and
  box 8 the VAT collected, box 7 divided by 7.6667 (15/115, or 3/23). The engine
  posts exclusive bases, so the pack posts the exclusive taxable sales to box 7a
  (not a box of the form) and rebuilds box 7 (= 7a + box 8) and box 5 (= boxes 6 +
  7) as totals. The purchases side is the same: box 11a (not a box of the form),
  box 12.
- **Imports** carry the VAT paid to Customs into box 13; box 11 excludes them, as
  the form says. The value on which Customs charged the VAT goes to box 13a, which
  is not a box of the form.
- **Exempt sales have no box.** The form asks for total sales and zero-rated
  supplies only; an exempt supply is not a taxable supply and the pack posts it to
  no box. `VU-S-EX` is a tax code with no posting.
- **Box 16 is signed:** negative is the VAT refund, positive the VAT to pay. Boxes 9
  and 14, the adjustments, are declared and empty. Boxes 17 to 19 are the pay-in
  slip (the payment, the late payment penalty, the total) and not boxes of the
  return.
- **The tax point is the invoice** where one is issued (section 5(1): the earliest
  of the invoice and a payment).
- **The deadline** is the 27th of the month after the period (section 16(1)(b)).
- **The rate is carried from 1 January 2018**, the date the Department gives for
  the increase from 12.5 % to 15 %; earlier periods at 12.5 % are not in the data.

## What the pack does not say yet

- **The payments basis.** Section 17 lets the registered person account on an
  invoice basis or a payments basis, and a person who elects nothing is deemed to
  be on the payments basis. The engine models the invoice basis only, and a payment
  received before the invoice (section 5(1)(b)) is not brought forward.
- **Three-monthly returns.** A person under VT 8 million of taxable supplies who
  applies is a Category B person with three-month periods ending in months the
  Director chooses (section 15(1)(b)). The pack declares the `quarter` cadence
  anchored on January–March; other quarters (February–April…) cannot be declared.
  This is a gap of the core, not of the pack.
- **The deadline's rollover.** The 27th moves to the next working day, and the
  return of a period ending 30 November is due on 5 January (section 16(1)); the
  pack declares day 27 and does not compute either.
- **Registration.** The threshold is VT 4 million of taxable supplies in 12 months
  (section 12), within 21 days of becoming liable; it is not a control of the pack.
- **Services bought from abroad.** No reverse charge was found in the texts read and
  the form has no box for it, so no code is carried; the place-of-supply rule
  (section 7) should be read by a local professional.
- **Adjustments** (boxes 9 and 14), bad debts (section 23), credit and debit notes
  (section 22), groups of companies (section 45), deposits, going concerns and
  apportionment of mixed-use purchases are the preparer's.
- **Which supplies are zero-rated or exempt** within `VU-S-ZR` and `VU-S-EX` is the
  preparer's judgement, and the conditions of Schedule 3 (proof of export, a
  certificate for an international organisation) are not controls of the pack.
- **Penalties and interest** are not computed. The Department states a late filing
  penalty of VT 30,000 (individual) or VT 50,000 (entity) plus VT 3,000 or
  VT 5,000 a day, a late payment penalty of 5 % and late payment interest of 20 %
  a year, daily; they are recorded here, not in the data.
- **E-invoicing.** No structured e-invoice standard was found; `obligation` is `none`.
- **Other taxes** (income tax where it exists, business licence fees, withholding on
  non-residents, the VNPF contributions of employees, customs duties) are not in the
  pack beyond their liability accounts.
- **Statements.** No text read prescribes a layout or a framework; the IFRS-style
  statements follow IAS 1 with expenses by nature. A local professional should say
  which framework Vanuatu companies use.
- **Bislama and French.** No translation of the chart or the statements.
