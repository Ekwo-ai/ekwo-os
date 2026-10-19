# Eswatini

Everything Eswatini adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 15 %, the zero rate and the exemptions of the two Schedules
of the Act, the monthly VAT return as the Act describes it, the statement of
financial position and the statement of profit or loss of an IFRS-based
presentation, and what the Act does with a service bought from abroad. The
format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on, so that an Eswatini
accountant reading the pack can disagree with a specific sentence rather than
with the whole of it.

**Status: `community`.** Nobody who files an Eswatini VAT return has reviewed
it. The figures are replayed against a month of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**English only.** English is the language of the Value Added Tax Act and of the
documents of the Eswatini Revenue Service ("the Authority"). The pack declares
`en` alone; siSwati (`ss`) is an official language of the country, but no
official tax text was found in it, so no translation is shipped. The currency
is the lilangeni (SZL, two decimals), pegged one to one to the South African
rand. The country is Eswatini, the name it took in 2018; the Act and the older
Authority texts still say Swaziland.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and beside
it the key of the text that article is in. The register in `pack.json` holds
nine texts, all opened while writing the pack:

| What | Text | Where |
|---|---|---|
| The charge to tax, time of supply, imported services, input tax, invoices, returns, the two Schedules | Value Added Tax Act, 2011 (Act No. 12 of 2011) | `ers.org.sz` |
| Input tax limits, reverse charge, aid-funded contracts | Value Added Tax Regulations (Legal Notice No. 52 of 2012) | `ers.org.sz` |
| The rate: 15 % from 1 August 2018 | Legal Notice No. 112 of 2018 | `ers.org.sz` |
| The registration threshold | VAT Registration page | `ers.org.sz` |
| The Schedules in the Authority's words | Zero Rated and Exempt Supplies pages | `ers.org.sz` |
| The fiscal-device rollout | e-Invoicing page | `ers.org.sz` |
| Where the return is filed | TaxEase | `taxease.ers.org.sz` |
| The accounting framework | IFRS jurisdiction profile of Eswatini | `ifrs.org` |

**The Act is the 2011 text.** The copy the Authority serves is the Act as
enacted. The Authority's own pages speak of "the VAT Amendment Act" and their
lists differ slightly from the Schedules of the PDF (the PDF exempts tap water
as well as sewage; the page lists sewage only, and adds printed matter
imported by post up to E100 a parcel). The pack follows the Act and says so.
The rate comes from the 2018 Legal Notice, not from the Act, which leaves it to
the Regulations (s. 24(3)). From 1 April 2012, when the tax replaced the sales
tax, to 31 July 2018 the rate was lower (14 %, per a court judgment of 2013);
no Authority text carrying that figure was opened, so the pack starts its
15 % codes on 1 August 2018 and carries nothing earlier.

## The chart of accounts, and why this one

There is no legal chart of accounts in Eswatini. This one is original: four
digits, blocked so that each range reaches one line of the statements, 147
accounts. Beyond a general IFRS-style chart it carries what an Eswatini
company owes: VAT output and input, the net VAT settlement account (1155 and
2110), import VAT at the border, PAYE, withholding tax, provident fund
contributions, and two cost accounts for VAT the law does not let a buyer
recover (6520 and 6530).

Only trade receivables, trade payables and the two VAT settlement accounts are
reconcilable. The bank, cash and suspense accounts are not.

## Taxes

| Code | Rate | What |
|---|---|---|
| `SZ-S-15` | 15 % | Standard-rated sale |
| `SZ-S-Z-EXP` | 0 % | Export of goods or services, international transport |
| `SZ-S-Z-DOM` | 0 % | Local zero-rated supply: maize meal, maize, beans, brown bread, milk, fresh fruit and vegetables, eggs, rice, vegetable oil, paraffin, fertilizers, seeds, pesticides, animal feed, prescription medicines, school text books |
| `SZ-S-EX` | exempt | Financial and insurance services, residential property and long lets, education, medical services, passenger transport, tap water and sewage |
| `SZ-P-15` | 15 % | Deductible purchase |
| `SZ-P-15-ND` | 15 % | Purchase whose input tax is blocked (entertainment, passenger automobiles); the tax goes to account 6530 |
| `SZ-P-Z`, `SZ-P-EX` | 0 % | Zero-rated and exempt purchases |
| `SZ-P-IMP` | 15 % | Import of goods, tax paid at the border and claimed |
| `SZ-P-RC-SVC` | 15 % | Imported service, tax self-charged and not recoverable |

Two choices carry the weight:

- **Zero-rated is not exempt.** A zero-rated supplier keeps its input tax; an
  exempt supplier does not. A company with both must apportion (s. 28(7)),
  which the pack does not do.
- **An imported service is not deductible here.** Section 3(c) charges the
  tax on imported services and section 16(3) makes the recipient declare and
  pay it within 30 days; section 16(4) lifts the duty for a taxable person
  with full deduction rights, who therefore posts nothing. `SZ-P-RC-SVC` is for
  the recipient who cannot recover the tax. Whether a partly exempt recipient
  recovers part of it is not clear from the text and is for the accountant.

## The return

Monthly (s. 31(1)). The pack carries rows grouped under the three figures
section 32(2) names — output tax, input tax, tax payable — in
`tax_report.json`, with value rows of its own for zero-rated exports and local
supplies, exempt supplies, standard-rated supplies and purchases, zero-rated
purchases, imports and imported services. The layout of the form on TaxEase was
not opened, so these rows are the pack's own and the box codes (`1S`, `2`, `3`…)
are internal labels, not form numbers.

**Deadline.** Section 32(1) gives 20 days after the end of the period, so the
pack carries day 20. Press reports on the Authority's 2025 notice that VAT
schedules must be submitted through TaxEase give the 27th of the month, and the
Authority's self-assessment page moves a deadline falling on a weekend or
public holiday to the last working day before it. No Authority text stating
the 27th was found; a company should confirm the day on TaxEase.

**Registration.** The Act leaves the annual threshold to a Gazette notice (s.
6(2)); the Authority's registration page states E900 000 of annual taxable
turnover, with voluntary registration below it. Older commentary says E500 000;
the pack follows the Authority and checks no threshold.

## Electronic invoicing: a fiscal-device regime, not an exchange

The Authority is rolling out electronic invoicing: a taxpayer issues invoices
through an approved electronic fiscal device or an approved vendor's software
and the data reaches the Authority's e-invoicing system. Trade press reports a
notice under sections 32, 51 and 75 of the Act (Legal Notice No. 111 of 2026,
in force 15 July 2026, phased by sector, real-time transmission, tax invoices
to show the buyer's TIN) and a Value Added Tax (Amendment) Bill, 2026 awaiting
assent that would bring non-resident suppliers of electronic services into
registration. Neither text was opened, so they are cited here and not in the
register.

This is clearance with the tax administration, not an exchange of a structured
document between two businesses. `einvoicing.profile` is null and `obligation`
is `none`. The core cannot call a fiscal device or print a fiscal code, so a
company on Ekwo issues the invoice through its approved device or vendor and
records the same document here.

## What this pack does not say yet, and why

- **The VAT return form.** Not opened; the rows are the pack's own.
- **The 27th against the 20th** as the filing day (above).
- **The 14 % rate of 2012 to 2018** and any 2018-2026 change of the
  Schedules: no Authority text opened.
- **Partial exemption** (s. 28(7)), the 50 % mobile telephone credit
  (regulation 7(3)), bad-debt relief, cash-basis accounting (s. 26), the zero
  rate on donor-funded contracts (regulation on aid-funded contracts) and the
  special rules for construction services (regulation 19).
- **Other taxes**: excise duty, income tax, PAYE, withholding tax and the
  presumptive tax have accounts but no tax code.
- **The exemption reason code (BT-121)**: Eswatini is outside the common system
  of VAT, so no VATEX code is carried.
- **Corporate income tax and fixed-asset allowances.**
- **A siSwati translation.**

## Reviewing this pack

An Eswatini accountant is asked to confirm: the 15 % effective date and the
earlier rate; the filing day (20 or 27); the registration threshold (E900 000);
the treatment of imported services for a partly exempt business; whether tap
water is exempt or only sewage; the zero-rated list against the Authority's
current page; the layout of the VAT return on TaxEase against the rows here;
the e-invoicing phase-in for the company's sector; and which statement tier
(full IFRS or IFRS for SMEs) the company reports under.
