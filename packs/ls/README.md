# Lesotho

Everything Lesotho adds to Ekwo, as data: a chart of accounts, the journals,
value added tax and where each code posts, a monthly VAT return, the statement
of financial position and the statement of comprehensive income of the IFRS for
SMEs Accounting Standard, and the sentences the law puts on an invoice. The
format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on, so that a Lesotho accountant
can disagree with a specific sentence rather than with the whole.

**Status: `community`.** Nobody who files a Lesotho VAT return has reviewed it.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is right.

## Sources

Every tax, box, mention and statement line carries its own `legal_reference`
and the key of the text it is in; `pack.json` lists them with the date each was
read (19 October 2026).

- **The Value Added Tax Act, 2001** (Act No. 9 of 2001), as Revenue Services
  Lesotho (RSL) publishes it. It is the **2001 text**: the amending Act No. 6
  of 2003, listed beside it on the RSL site, was not read, so any later change
  to the exemptions or to the input-tax credit rules is not in this pack.
- **The rates are not in the Act.** Section 19(3) leaves them to regulations,
  at most four rates including zero. The pack read two Gazette notices:
  Legal Notice No. 18 of 2020 (electricity 9 %, telecommunications 15 %, from
  1 April 2020) and Legal Notice No. 30 of 2021 (electricity 10 %, from
  1 April 2021). The consolidated Value Added Tax Regulations, 2003 (Legal
  Notice No. 95 of 2003) were **not** read; RSL's own page of tax rates carries
  the rest: 15 % on other goods and services, 0 % on exports and basic
  commodities.
- **The portal**: RSL eTax, listed on the RSL site.
- **The accounts**: the Companies Act, 2011 and the IFRS for SMEs, as the IFRS
  Foundation's jurisdiction profile for Lesotho summarises them (the text of
  section 95 itself was not read).

## Taxes

| Code | Rate | Scope | Reads |
|---|---|---|---|
| `LS-S-VAT`, `LS-P-VAT` | 15 % | sale, purchase | the standard rate, and telecommunications, which is also 15 % |
| `LS-S-VAT-ELEC`, `LS-P-VAT-ELEC` | 10 % | sale, purchase | electricity, since 1 April 2021 |
| `LS-S-ZERO`, `LS-P-ZERO` | 0 % | sale, purchase | basic commodities named in the regulations |
| `LS-S-EXPORT` | 0 % | sale | exports, s. 19(2) |
| `LS-S-EXEMPT`, `LS-P-EXEMPT` | 0 % | sale, purchase | the exempt supplies of s. 6(2) |
| `LS-P-VAT-NC` | 15 % | purchase | VAT the vendor does not claim; it stays in the cost |
| `LS-P-IMPORT-GOODS` | 15 % | purchase | goods cleared by customs |
| `LS-P-RC-IMPORT-SERVICES` | 15 % | purchase | imported services, self-assessed and not claimed |
| `LS-S-NOT-SUBJECT`, `LS-P-NOT-SUBJECT` | 0 % | sale, purchase | outside the scope of VAT |

Every code is dated from 1 April 2021, the day of the last rate change in the
texts read. The earlier standard rate (14 % before 2018, reported as 15 % from
1 April 2018 by second-hand sources only) and the electricity rates of 8 % and
9 % are not carried.

## The return

`LS-VAT`: a monthly return (the tax period is a calendar month, s. 1), filed
within twenty days after the end of the period (s. 27(1)); the tax is due the
same day (s. 37(1)(a)). The boxes — 13 of them, from supplies at each rate and
the output tax to the input tax and the net — follow the structure of
s. 20(1), output tax A less input tax B. **The numbering is the pack's own**:
the form RSL prescribes under s. 27(2) was not found in a text the pack could
read, so a vendor must carry the figures to the RSL eTax form by name, not by
number.

## The accounts

An original chart of 156 accounts, four digits, blocked so that each range
reaches one line of Section 4.2 and Section 5.5 of the IFRS for SMEs. There is
no legal chart in Lesotho. The statements are the IFRS for SMEs statement of
financial position and statement of comprehensive income (expenses by nature).
A financial institution applies full IFRS and needs more than this pack.

## Electronic invoicing

The Value Added Tax (E-Invoicing) Regulations, 2026 (Legal Notice No. 25 of
2026) came into operation on 1 April 2026: an invoice is issued from an
accredited Electronic Billing System, carries a QR code and is registered on
RSL's invoice data system (the Lekuka portal). This is a clearance model, which
a pack cannot carry; `obligation` is `none`, there is no Peppol profile. The
date from which each vendor must connect and the penalties were not read in the
regulations; second-hand sources speak of 1 August 2026, which is not a source.

## What this pack does not carry

- **The registration threshold**: RSL states M850,000 per annum (its pages for
  registration and its FAQ). One of the sources found elsewhere speaks of
  M2,000,000; the pack does not model the threshold.
- **The 2026 additions to the zero rate** (imported fresh produce and cooking
  oil, by an RSL public notice read only through a search result): the list of
  basic commodities is in the regulations, not copied here.
- **Residential rent**: not among the exempt supplies of s. 6(2) in the 2001
  text; it is not offered as exempt. A later amendment may differ.
- **The cash method of accounting** (s. 21) and the tax on a change of method.
- **The credit restrictions of s. 23** are the vendor's to apply; `LS-P-VAT-NC`
  is the code for a purchase that is not claimed.
- **Sesotho labels**: `languages` is empty. No verified Sesotho translation of
  the chart, the taxes or the statements was available.
- **Corporate income tax, withholding taxes, fixed-asset schedules, payroll**:
  no pack file. RSL lists 10 % for manufacturing and commercial farming
  companies and 25 % for others on its rates page; the Income Tax Act was not
  read.
- **A mixed taxpayer** (partial exemption) and **bad debts** (s. 26).
- The Loti is pegged to the South African rand at par; Ekwo's exchange rates
  are the user's to enter.

## Reviewing this pack

A Lesotho accountant should read first: the rate table above against the
current consolidated Regulations; the amended s. 6 and s. 23 of the Act; the
box names against the RSL eTax form; the e-invoicing connection date; and the
treatment of the standard-rate history before April 2021.
