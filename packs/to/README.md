# Tonga

Everything Tonga adds to Ekwo, as data: a chart of accounts, the journals, the
Consumption Tax (CT) at 15 %, the zero rate and the exemptions, the monthly CT
return, form CT206, with its boxes 5 to 18, and the statement of financial
position and the statement of profit or loss of an IFRS-based presentation. The
format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and what it does not say yet.

**Status: `community`.** Nobody who files a Tongan CT return has reviewed it.
The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**English only.** The Act, the Orders and the forms are in English (Tongan and
English are the languages of the Kingdom; the Ministry also publishes a Tongan
version of some texts). The pack declares `en` alone and carries no Tongan
translation of the chart or the statements. The currency is the paʻanga (TOP,
two decimals). The Ministry's forms and the Act's examples print amounts as
`$`. The fiscal year default is `calendar`.

## Sources

Eight entries in `pack.json`. Read at source: the Consumption Tax Act 2003
(Cap. 26.02, 2016 Revised Edition, from the Tonga trade portal), form CT206 and
the CT overview page on the Ministry of Revenue and Customs site
(`revenue.gov.to`), the Consumption Tax Regulations 2005 as revised in 2012 with
the Orders-in-Council in its endnotes, and the Consumption Tax Order 2013 (both
through an archived copy of the Ministry's former site), IAS 1 and the Ministry's
portal. The rate (section 5(3)), the period (section 2), the return and payment
date (sections 21 and 22), the time of supply (section 9), the tax fraction
(section 11), the input tax credit (section 17) and the invoice (section 18) were
read in the Act; the boxes and the 7.6667 divisor in the form.

PacLII, which publishes the Act, answers 403 to an automated read; the Act was
read from the trade portal copy.

## Decisions

- **The form is CT-inclusive.** Box 5 is the total taxable supplies including CT,
  box 6 the zero-rated supplies included in it, box 7 the taxable supplies (box 5
  less box 6) and box 8 the CT collected, box 7 divided by 7.6667 (15/115). The
  engine posts exclusive bases, so the pack posts the exclusive taxable sales to
  box 7a (not a box of the form) and rebuilds box 7 (= 7a + box 8) and box 5
  (= boxes 6 + 7) as totals. The purchases side is the same: box 11a (not a box
  of the form), box 12.
- **Imports** carry the CT paid to Customs into box 13; box 11 excludes it. The
  value on which it is levied goes to box 13a, which is not a box of the form.
- **Exempt sales have no box.** The form prints a line for them, without a number,
  and says not to include them in box 5 or 6; `TO-S-EX` is a tax code with no
  posting.
- **Box 18 is signed:** negative is the CT credit, positive the CT to pay. Boxes 9
  and 14 (tax adjustments) and box 16 (credit brought forward) are declared and
  empty: they are the preparer's.
- **The period is the month** (section 2: from 1 October 2005, a Consumption Tax
  period is a month commencing on the first day of each month; before that, two
  months). The return and the payment are due within 28 days after the end of the
  period (sections 21(1) and 22(1)), which is the 28th of the following month for
  every month of the year: the deadline is declared as `day_of_month_after_period`
  with day 28.
- **The tax point is the invoice** where one is issued (section 9(1): the earlier
  of the invoice and the first payment).
- **Rates carried from 1 October 2005**, the date from which the period is a month
  (the 15 % rate is in force since 1 April 2005 according to the Ministry's page).
- **Zero-rated and exempt supplies are fixed by Order** (section 5(3)(a)), not by
  a schedule of the Act. The pack carries the lists of the Order-in-Council of
  31 March 2005 (exempt: health, dental and nursing, education, financial
  services, public transport, residential land lease; zero-rated: exports,
  international transport, a going concern, domestic electricity, the first
  20 cubic metres of water a month) and the zero rate of the Consumption Tax
  Order 2013 for fishing and aquaculture.

## What the pack does not say yet

- **Orders in force today.** The Orders were read in the Regulations of the 2012
  edition and in the Order of 2013. Later Orders (the Government Gazette carries
  exemptions for specific imports and projects, 2014 to 2020) were not read one
  by one and some of the 2005 lists may have been amended; a Tongan accountant
  should confirm the lists against the Orders in force.
- **Registration.** Section 6 sets the threshold at TOP 100,000 of taxable supplies
  in 12 months, with voluntary registration below it (section 6(4)); neither is a
  control of the pack.
- **Tax point on payment first.** A payment received before the invoice brings the
  supply forward (section 9(1)(b)); the engine models only the invoice date.
- **Services bought from abroad.** Section 15 treats the recipient as making a
  taxable supply only to the extent it uses the service for exempt supplies,
  personal use or entertainment; the form has no box for it, so no code is carried
  and the case of a partly exempt person is not modelled.
- **Credits that are barred** (section 17(4) and (5): passenger vehicles,
  petroleum products, entertainment, exempt or private use) are the preparer's
  judgement, carried by `TO-P-15-NC`; the Ministry's page adds electricity,
  insurance and water as claims not allowed, which the pack does not enforce.
- **Refunds and carry-forward** (section 24): the credit is carried forward in
  box 16 by the preparer; the refund application is not modelled.
- **Penalties and interest** are not computed; the figures were not read.
- **Electronic sales register.** The Revenue Services Administration (Electronic
  Sales Register System) Regulations 2022 were not read; no structured e-invoice
  standard was found, so `obligation` is `none`.
- **Other taxes** (income tax, PAYE, withholding taxes, excise, customs duties,
  the retirement fund) are not in the pack beyond their liability accounts.
- **Statements.** No text read prescribes a layout or a framework; the IFRS-style
  statements follow IAS 1 with expenses by nature. A Tongan professional should
  say which framework Tongan companies use.
- **Tongan language.** No translation of the chart or the statements.
