# The Gambia

Everything The Gambia adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 15 %, the zero rate on exports and one exempt code, a monthly
VAT return in the shape the Gambia Revenue Authority describes it, and the
statement of financial position and statement of profit or loss of an
IFRS-based presentation. The format is [`docs/packs.md`](../../docs/packs.md);
this file says where the content came from and which decisions it rests on, so
that a Gambian accountant reading the pack can disagree with a specific
sentence rather than with the whole of it.

**Status: `community`.** Nobody who files a Gambian VAT return has reviewed it.
The figures are replayed against a month of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

**A thinly sourced pack.** The Gambia publishes little online. The Income and
Value Added Tax Act, 2012 and the prescribed VAT return form could not be found
or opened, so every rule below rests on the Authority's own plain-language
guidance (a VAT brochure and a FAQ page). What those texts do not say is left
out and listed under "What this pack does not carry"; nothing was guessed.

**English only.** English is the official language of The Gambia. The currency
is the dalasi (GMD, two decimals).

## Sources

Every tax, box and statement line carries its own `legal_reference`, and beside
it the key of the text it is in. The register in `pack.json` holds four texts:

| What | Text | Where |
|---|---|---|
| Rate, zero rate, exempt supplies, registration thresholds, monthly return and its day, import VAT, refunds | Value Added Tax Brochure (`vat-brochure`) | `gra.gm` |
| The same rules, as questions and answers; where to file and pay | Domestic Taxes FAQs (`gra-domestic-faqs`) | `gra.gm` |
| The Authority's electronic services (kind `portal`) | Online Services (`gra-online-services`) | `gra.gm` |
| The accounting framework | IFRS Foundation jurisdiction profile (`ifrs-gambia`) | `ifrs.org` |

**No text of the law is cited.** The brochure itself says it "is not intended
as an exhaustive explanation or replacement of VAT laws". The law it refers to
is the Income and Value Added Tax Act, 2012 (in force from January 2013); this
pack never quotes it. A secondary guide names the same Act and the same rate,
and a third-party tracker gives a registration threshold of D1,000,000 that
contradicts the Authority's D2,000,000; the Authority's figure is used and
second-hand sites are not sources.

## The chart of accounts, and why this one

There is no legal chart of accounts in The Gambia. This one is original: four
digits, blocked so that each range reaches one line of the statements, 141
accounts. Beyond a general IFRS-style chart it keeps what a Gambian VAT filer
needs: VAT output (2100) and input (1150) kept apart from the net VAT payable to
(2110) or refundable by (1155) the Authority after a return, import VAT owed to
the Authority at the border (2125), withholding tax, PAYE and social security
contributions payable. The names of the social-security accounts are generic:
the sources say nothing about the scheme, its rates or its institution.

## Taxes

Six codes, all in the Authority's brochure.

| Code | Rate | What |
|---|---|---|
| `GM-S-15` | 15 % | Standard-rated sale |
| `GM-S-Z-EXP` | 0 % | Export of goods or services |
| `GM-S-EX` | 0 % | Exempt sale (basic foods, agriculture, education, medicines, medical services, life and health insurance, residential rent, domestic transport, small electricity and water consumption) |
| `GM-P-15` | 15 % | Deductible purchase |
| `GM-P-EX` | 0 % | Exempt purchase |
| `GM-P-IMP` | 15 % | VAT paid on imported goods, claimed as input tax |

The brochure shows the VAT element of a VAT-inclusive price (price / 115 x 15);
Ekwo computes on a price excluding VAT, which gives the same figure.

## The return

Monthly, filed and paid by the **15th of the following month**, even when there
is nothing to declare (brochure §§ 10 and 13; the FAQ words it "15 days after
month end"). The pack's `deadline` rule is `day_of_month_after_period`, day 15.
Returns are submitted at a Domestic Taxes Department office and paid there or at
a partner bank (brochure § 11); the only `portal` entry is the Authority's
online-services page, which does not itself describe a VAT filing function.

**The boxes are the pack's own.** The prescribed form could not be opened, so
the box numbers (`ZE`, `EX`, `1S`, 1 to 5) are a presentation of output tax,
input tax and the balance, not the numbering of a GRA form.

## Electronic invoicing

None modelled (`obligation: none`). The sources speak only of VAT-inclusive
invoices and receipts. That no source was found is not proof that no e-invoicing
or clearance system exists.

## What this pack does not carry

- **The Act.** The text of the Income and Value Added Tax Act, 2012 and its
  amendments (the Authority commissioned a revision of the Act in 2024).
- **The prescribed return form** and its box numbering.
- **Services bought from abroad.** The brochure is silent; the Act may charge the
  recipient. Because `ekwo pack check` demands a purchase tax or a `not_taxed`
  entry, `pack.json` carries a `not_taxed` entry whose text says plainly that it
  records a gap and not a legal conclusion. A reverse-charge code should be added
  once the Act is read.
- **Blocked input tax** (entertainment, vehicles...), partial exemption and the
  apportionment of input tax between taxable and exempt supplies.
- **Time of supply** and the exact invoice contents: `earliest_of_delivery_or_payment`
  is the family default and is not sourced to Gambian text.
- **Withholding tax on contracts** (10 % resident, 15 % non-resident, per the
  FAQ), corporate income tax, PAYE, social security, and any other tax: documented
  nowhere in the pack's computations.
- **Registration thresholds** (D2,000,000 compulsory, D1,000,000 voluntary, per
  tax year) and de-registration: stated in the source texts, not enforced.
- **Refunds** (diplomats, NGOs, three consecutive months of credit, exporters).
- **A legal statement format.** The statements are an original IFRS-based
  presentation. The IFRS Foundation profile (June 2016) says IFRS is required for
  banks and permitted for other companies and that SMEs may use the IFRS for
  SMEs; the Gambia Institute of Chartered Accountants was created by a 2013 Act
  and its current standards should be confirmed with it.

## Reviewing this pack

A Gambian accountant should read first: the exempt list (the brochure's summary,
not the Schedule), the registration thresholds, the treatment of imported
services, the time of supply, what input tax is blocked, and whether the return
form's boxes can be mapped onto the pack's. A correction is a change to the JSON
files in this folder.
