# Jersey

Everything Jersey adds to Ekwo, as data: a British-style chart of accounts with
the accounts of the goods and services tax (GST), the journals, 17 tax codes, the
eight-box GST return of Revenue Jersey, and the balance sheet and profit and loss
account in the layout of FRS 102 Section 1A (small entities). The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came from
and which decisions it rests on, so that a Jersey accountant can disagree with a
specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who practises in Jersey has reviewed it. The
figures are replayed against a year of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

## The tax

GST, under the Goods and Services Tax (Jersey) Law 2007, administered by Revenue
Jersey.

| Code family | Treatment | Return boxes |
|---|---|---|
| `JE-S-SR`, `JE-S-SR-INC` | Standard rate 5 % (from 1 June 2011), the second with the GST inside the price | 1, 6 |
| `JE-S-ZR-EXP`, `-INTL`, `-ISE`, `-DW`, `-RX` | Zero-rated: exports, international services (Schedule 6, para. 5), remitted supplies to an International Services Entity, dwellings, prescription medicines | 1, 2 |
| `JE-S-ES` | Exempt (Schedule 5, Groups 1 to 8) | none |
| `JE-S-NS` | Outside the scope of GST | none |
| `JE-P-TX`, `-BL`, `-ZR`, `-ES`, `-NR` | Purchases from Jersey suppliers: taxed, not recoverable, zero-rated, exempt, supplier charging no GST | 4, 7 |
| `JE-P-IMP` | Import with GST paid to Customs | 5, 7 |
| `JE-P-IMP-DEF`, `JE-P-RC` | Import with GST deferred by an approved customs trader; service received from abroad (reverse charge) | 5, 6, 7 |

There is no reduced rate (Law art. 8(1); Revenue Jersey, GST taxed on goods and
services). Jersey is outside the United Kingdom VAT system, so a sale between
Jersey and the United Kingdom carries no UK VAT.

## The return

Revenue Jersey's return has eight boxes: 1 total sales excluding GST (zero-rated
included), 2 zero-rated and remitted sales, 3 sales subject to GST (1 − 2), 4
purchases and expenses excluding imports, 5 total value of imports, 6 GST on
sales, 7 GST on purchases, 8 amount payable or refundable (6 − 7). It is quarterly
and due no later than the last day of the month after the quarter (30 April for
January to March), online. The pack declares the quarter only; other cadences the
registration letter may set are not modelled.

## Assumptions, to be confirmed

- **Deferred imports and reverse-charged services.** Revenue Jersey says the
  value goes in box 5. It does not say how the GST appears in boxes 6 and 7; the
  pack self-assesses it in both, net nil.
- **Box 4** holds every purchase from a Jersey supplier, exempt and untaxed ones
  included; the page says "business costs from Jersey suppliers".
- **Box 1** leaves exempt supplies out ("taxable sales including zero-rated").
- **The 3 % period** (6 May 2008 to 31 May 2011, then 5 %) is carried by no code: the
  generic golden test asks a pack with two positive rates, closed ones included, to
  exercise two of them in a 2026 scenario, which a closed code cannot do. The dates
  come from the research brief and no page that could be opened states them; the
  5 % is art. 8(1) of the Law. A business keeping pre-June 2011 books needs a closed
  code added once that test counts only the rates in force.
- **Tax point** `invoice_date` is a convention; the rule was not read.
- `fiscal_year_default: calendar` is a usage, not a legal requirement.

## What this pack does not carry

- **International Services Entities**: an ISE pays an annual fee instead of
  accounting for GST (Law arts. 56A to 66, GST (ISE) Regulations 2008). Only the
  supplier's zero-rated "remitted supply" to an ISE is modelled.
- **Overseas retailers' sales to Jersey consumers**: from 1 July 2023 a retailer
  selling goods dispatched from abroad to private individuals in Jersey registers
  above £300,000 in twelve months and charges GST at the point of sale; imported
  parcels over £60 carry GST at the border (Revenue Jersey, Overseas retailers'
  GST guidance notes). Documented, not a separate code.
- **Partial exemption**, penalties, surcharges and the registration regime
  (£300,000 of taxable supplies in twelve months).
- **Income tax on companies** (0 % standard, 10 % financial services, 20 %
  utilities and Jersey property income, up to 20 % for large retailers), **social
  security contributions**, **stamp duty** and the **global minimum tax** of the
  Multinational Corporate Income Tax (Jersey) Law 2025. Account `2280` and the
  `8200` series exist for the income tax a company books.
- **E-invoicing**: `obligation: none`; no mandate or Peppol Authority found.
- `fixed_assets.json`, XBRL fact keys and bank formats.

## Sources

`pack.json` registers twelve texts, consulted on 10 October 2026.

| What | Status |
|---|---|
| GST Law 2007 (jerseylaw.je) | Opened, first 100,000 characters: art. 8, 33, 34, headings of Schedules 5 and 6. The schedules' paragraphs were not read in full. |
| Revenue Jersey pages: return, what is taxed, registration, overseas retailers, supplies from outside Jersey, ISE supplies, records and invoices | Opened |
| Companies (Jersey) Law 1991 | **Not opened**; duties cited from a Walkers summary (opened): ten-year retention of records, accounts under declared GAAP. Article numbers are not cited. |
| Company income tax rates | gov.je "Moving to Jersey: money and tax", opened |
| Partial exemption booklet (PDF) | Could not be read as text; not cited |
| States Assembly P.100/2022 on the 5 % rate | 403; not cited |
| FRS 102 | Opened (Section 1A exists; the text was not read) |
| Portal | `gov.je/pages/login.aspx` opened: it lists one.gov.je and CAESAR; the GST return page itself is not behind a URL that could be opened |

## Chart of accounts

Jersey prescribes none. The chart is the British one used by `packs/gg` with the
United Kingdom VAT, PAYE and CIS accounts absent and the GST accounts added:
`1140` input tax, `2210` output tax, `2215` import GST owed to Customs, and the
settlement accounts `2230` (payable) and `1145` (refundable) of a filed return.
187 accounts; reconcilable: `1100`, `2100`, `2230`, `1145`.

## Statements

A balance sheet and a profit and loss account in the FRS 102 Section 1A Format 1
layout. **Jersey law does not impose it**: the Companies (Jersey) Law 1991 asks
for accounts under declared generally accepted accounting principles (UK GAAP or
IFRS in practice). Line `K.IV` carries the year's result not yet closed.

## Reviewing this pack

Open an issue titled "Review: Jersey". Points for a local accountant: the
assumptions above; the Schedule 5 and 6 paragraphs in full; the 3 % period; the
Companies Law articles; whether the 20 % retail rate and the other rates match the
Income Tax Law; the tax point rule.
