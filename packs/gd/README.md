# Grenada

Everything Grenada adds to Ekwo, as data: a chart of accounts, the journals,
the value added tax (VAT) rates and where each one posts, the boxes of a VAT
return, a statement of financial position and an income statement, and the way a
document is numbered. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on.

**Status: `community`.** Nobody who files a Grenadian VAT return has reviewed it
against the law they apply. The figures are replayed against two months of books
by `tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

## Sources

Every rate, box and statement carries its own `legal_reference` and the key of
the text it rests on. The register in `pack.json` holds six texts, all opened on
17 October 2026:

| What | Text |
|---|---|
| Imposition and rates (s. 8), registration (s. 9), reverse charge on imported services (s. 22), net amount (s. 32), input tax credits (s. 33 and 34), invoices and notes (s. 37 and 39), return (s. 44), payment (s. 46), refunds (s. 49), Schedules One to Four | Value Added Tax Act, Cap. 333A, consolidated text published by the Parliament of Grenada (`gd-vat-act`) |
| Registration threshold of $300,000, late fee of the return, suspension regime for imports | Value Added Tax (Amendment) Act, 2015, Act 21 of 2015 (`gd-vat-amend-2015`) |
| Electricity consumption at 7.5 % (regulation 4A) | Value Added Tax (Amendment) Regulations, 2023, S.R.O. 6 of 2023 (`gd-vat-regs-2023`) |
| The online service the return is filed through | Ministry of Finance news release on GTAX, 26 January 2024 (`gd-gtax-release`) and the tax portal (`gd-tax-portal`) |
| Presentation of the statements | IFRS for SMEs, IASB (`iasb-ifrs-sme`) |

## What the pack carries

- **Twelve tax codes.** Sales: `GD-S-15` standard, `GD-S-15-INC` the same with the
  VAT already in the price, `GD-S-10` hotel or holiday accommodation and dive
  activity, `GD-S-7.5` electricity, `GD-S-0` export, `GD-S-Z` zero-rated at
  home, `GD-S-EX` exempt. Purchases: `GD-P-15`, `GD-P-10`, `GD-P-7.5`,
  `GD-P-15-IMP` (VAT paid to the Comptroller of Customs), `GD-P-EX`.
- **The return, `GD-VAT-RETURN`**, boxes 1 to 17, monthly, due the 20th of the
  month after the period (s. 44(1) and s. 46(1) of the Act).
- **A chart of 118 accounts**, four digits, IFRS for SMEs in spirit; the return is
  settled on `2100` (payable) or `1172` (refundable), apart from the accounts the
  tax posts to. Not a legal chart: none was found.
- **A statement of financial position and an income statement** in the manner of
  IFRS for SMEs. VAT collected sits in current tax liabilities, VAT recoverable in
  receivables, unnetted.
- **Language**: English, the official language. No `i18n`.
- **Currency**: the East Caribbean dollar (`XCD`, two decimals), shared with the
  other members of the Eastern Caribbean Currency Union.

## What the pack does not say yet

- **The box layout is the pack's own.** The monthly return as it appears in the
  Division's online service (G-TAX) was not found as a text; the boxes follow what
  the Act makes the net amount carry (s. 32). A reviewer should align the labels
  with the screens of the portal. The Division's own site (`ird.gd`) did not answer
  during the session.
- **Amendments after 2015.** The Act is read as published by the Parliament, with
  Act 21 of 2015 and the 2023 Regulations. The principal Regulations (S.R.O. 41 of
  2009) were not found as a text; their lists (zero-rated foods, the dive package,
  prescribed exempt supplies) are therefore not reproduced. The 2023 amending
  Regulations carry two serial numbers in the same document (S.R.O. 6 and "No. 2
  of 2023"); the pack cites the former.
- **Rate on sweetened beverages.** Secondary sources give 20 % on sweetened drinks
  from 2023 under a Fifth Schedule of the Regulations; the Ministry's fact sheet
  could not be opened and no code is carried. Such a sale is the user's to
  account for with their accountant.
- **Electricity relief.** A distributor's fact sheet speaks of a temporary relief
  from 1 August to 31 December 2026 for the non-fuel part of the bill; no official
  text was read and the pack keeps 7.5 %. The first 99 kWh of a household are
  zero-rated by the Third Schedule (`GD-S-Z`).
- **The 10 % rate** applies to hotel or holiday accommodation (s. 8(3)(b)) and,
  "to the extent provided in the Regulations", to the dive activity of a dive
  package (s. 8(3)(c)); the pack does not decide which supplies qualify.
  Accommodation occupied for more than forty-five days under a tenancy is exempt
  unless the supplier chooses to tax it (Fourth Schedule, paragraph (2)).
- **The registration threshold** ($300,000 a year, s. 9(2) as amended) is the
  user's to apply; the pack does not check it.
- **Zero-rated and exempt supplies.** The pack carries three cases (an export, the
  Third Schedule by its examples, the Fourth Schedule by its examples); it does
  not reproduce the schedules. Imports under the suspension regime of s. 66A are
  not modelled.
- **Input tax.** All tax on a business purchase is treated as recoverable. The
  denials of s. 33 (passenger vehicles, entertainment, clubs, private use) and the
  apportionment of a mixed acquisition (s. 34(3)) are the user's.
- **Services bought from abroad.** s. 22 has the recipient reverse charge the VAT in
  some cases; the declaration line was not found. Recorded in `not_taxed` as a
  gap, not as an exemption.
- **Import base.** `GD-P-15-IMP` applies 15 % to the invoice value; the customs
  value (with duty and freight) is the customs entry's.
- **Penalty and interest** on a late return (s. 44(3)), late payment (20 %,
  s. 46(3)) and unpaid tax (s. 68) are not modelled.
- **Refunds.** The pack reports box 17; the carry-forward and the refund rules of
  s. 49 are applied by the Comptroller.
- **Other taxes**: the Act's special regimes (gambling, vending machines, travel
  agents, going concerns) and the other levies (income tax, social security
  contributions, customs duty, petrol tax) are ordinary payable and expense
  accounts. No code, no return.
- **E-invoicing**: no obligation found (`obligation: none`).
