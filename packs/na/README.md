# Namibia

Everything Namibia adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 15 %, the zero rate and the exemptions, import VAT and
imported services, the VAT 2 return row by row, and the statement of financial
position and the statement of profit or loss of an IFRS-based presentation. The
format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on, so that a Namibian
accountant reading the pack can disagree with a specific sentence rather than
with the whole of it.

**Status: `community`.** Nobody who files a Namibian VAT return has reviewed
it. The figures are replayed against two months of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**English only.** English is the official language of Namibia and the language
of the Value-Added Tax Act, 2000 and of every form of the Namibia Revenue
Agency (NamRA). The pack declares `en` alone.

## Sources

Every tax, row and statement carries its own `legal_reference`, and beside it
the key of the text that article is in. The register in `pack.json` holds
eight texts:

| What | Text | Where |
|---|---|---|
| The charge at 15 %, time of supply, zero rate (Schedule III), exemptions (Schedule IV), imports, input tax, tax invoices (Schedule VI), tax periods, returns | Value-Added Tax Act, 2000 (Act No. 10 of 2000), annotated consolidation | `lac.org.na` |
| The N$1 000 000 registration threshold, N$1 000 cash sales without a tax invoice, imported services within 20 days | Value-Added Tax Amendment Act, 2024 (Act No. 5 of 2024), Government Gazette No. 8443 | `archive.gazettes.africa` |
| The return, row by row | Return for Value Added Tax, form VAT 2 | `namra.org.na` |
| The 15 % rate, the 25th-day due date, input tax that cannot be claimed | NamRA VAT brochure and general tax information brochure | `itas.namra.org.na`, `namra.org.na` |
| Where the return is filed | Integrated Tax Administration System (ITAS) | `itas.namra.org.na` |
| The currency | ISO 4217 list one | `six-group.com` |
| The accounting framework | IFAC member profile of Namibia | `ifac.org` |

The Act was read in the annotated consolidation of the Legal Assistance Centre
(the Act as amended up to Act 14 of 2022); the Amendment Act, 2024 was read in
the Gazette. The Companies Act, 2004 is named in the chart and the statements
as the source of the duty to keep accounts, from IFAC's profile and not from its
text, which the pack did not open.

## The rate, the schedules and what the pack carries

- **15 %** (s. 6(1)): `NA-S-15`, `NA-S-15-CAP` (capital goods sold),
  `NA-P-15`, `NA-P-15-CAP`, `NA-P-15-ND` (input tax refused by s. 19(2):
  passenger vehicles, entertainment, petroleum not wholly for business, club
  subscriptions) and the three import codes.
- **Zero rate** (s. 9, Schedule III): `NA-S-Z-EXP` for exports and
  `NA-S-Z` for the local zero-rated supplies — maize meal and mahango, fuel,
  residential electricity, water and telecommunications, bread, beans, cooking
  oil, sugar, fresh milk, livestock, funeral services, sanitary pads and the
  rest of the Schedule. The Schedule is long and changes with the Finance
  Acts, so one code stands for all of it and the accountant checks the item.
- **Exempt** (s. 10, Schedule IV): `NA-S-EX` and `NA-P-EX` — financial
  services, dwellings let under a lease, education, public transport,
  medical and paramedical services and the rest of the Schedule. A supply the
  Act zero-rates is never exempt (s. 10(2)).
- Every code starts on 2024-01-01. That is the earliest day the pack claims,
  not the history of the rule.

## Currency: the Namibia dollar only

The Namibia dollar (`NAD`, ISO 4217 numeric 516, two decimals) is the pack's
currency and the only one it declares. The South African rand circulates in
Namibia at par with it, and ISO 4217 lists it under Namibia as well, but a rand
is a foreign currency for the books: account 1030 holds a rand account beside
the Namibia dollar current account on 1010, and a document in rand is a
foreign-currency document like any other.

## The return: VAT 2

NamRA's VAT 2 is a grid: the rows (8 trading sales, 9 capital goods sold, 10
output adjustments; 13 local purchases, 14 capital goods purchased locally, 15
imported purchases, 16 imported capital goods, 17 input adjustments) against
three columns — exempt, zero-rated and 15 % — and, for the 15 % column, the tax.
The pack gives a box to every cell a posting writes into (`8`, `8Z`, `8E`, `13`,
`13Z`, `13E`…), and totals for row 12 (output tax, block 5), row 19 (input tax,
block 6) and block 7 (amount due or repayable). The column totals of rows 11
and 18 are sums of boxes the pack already holds and are not repeated. The
form asks whole Namibia dollars and ignores cents; the pack reports cents.

The due date is the 25th of the month after the end of the tax period
(s. 24(1)). The tax period is two months, Category A (ending January, March,
May…) or B (ending February, April, June…), as the Commissioner decides
(s. 23). The pack's `bimonth` is anchored on January–February, which is
Category B; Category A is not expressible by the format and a Category A
taxpayer files by hand on the period of their own.

## What this pack does not say yet, and why

- **The registration threshold.** The Amendment Act, 2024 raises the compulsory
  registration level of s. 15 from N$500 000 to **N$1 000 000** of taxable
  supplies in twelve months, but its section 7 makes it commence on a date the
  Minister fixes by notice in the Gazette. The NamRA brochure the pack read
  still says N$500 000, and the news that NamRA announced the N$1 million figure
  reached the pack only through secondary sites. No official notice with a
  commencement date was found. A pack carries no registration threshold, so
  nothing is wrong in the data, but a person deciding whether to register should
  read the Gazette notice, not this file.
- **Imported services on the form.** The Act makes the recipient pay the tax
  (s. 6(2)(c)) by an import declaration within 20 days following the month of
  the import (s. 14(2) as amended, once commenced) and makes it input tax. The
  VAT 2 does not say where an import of services is declared. The pack puts it
  on row 15, *Imported purchases*, with the tax owed to NamRA on account 2125
  until the declaration is paid. **That placement is an assumption** for a
  Namibian accountant to confirm.
- **Electronic invoicing.** No Namibian statute or notice the pack could open
  requires a structured e-invoice, so `obligation` is `none`. Trade and tax
  press report a project connecting taxpayers to NamRA's ITAS, first dated April
  2026, then moved to a phased rollout over the 2026/27 to 2028/29 budget years
  without a fixed date. Nothing official about a profile, a platform or a date
  was found, so none is carried. The tax invoice of Schedule VI (the words "tax
  invoice", the supplier's name, address and VAT registration number, a serial
  number and a date, the recipient, a description, the quantity, the tax charged
  and the consideration with and without tax) is not checked by Ekwo, and a
  registered supplier needs no tax invoice for a cash sale up to N$1 000 once the
  Amendment Act, 2024 commences (N$100 before).
- **Time of supply.** Section 7(1) makes the earlier of invoice and payment the
  time of supply; the special rules of s. 7(2) to (8) are not modelled.
- **Input tax apportionment.** Where a business makes taxable and exempt
  supplies, s. 19(3) allows only part of the input tax on mixed costs
  (A × B/C, with no restriction when B/C exceeds 0.90). Ekwo does not compute
  this; the accountant adjusts row 17 by hand.
- **Other lines of the form.** The adjustments of rows 10 and 17 other than credit
  notes (bad debts, change of use, deemed supplies) are not posted by any tax
  of this pack and are entered by hand.
- **Corporate income tax, PAYE and the other taxes.** Not modelled: this pack is
  VAT and the books.
- **Refunds and the amount payable.** A negative block 7 is a refund claimed
  under s. 38; the pack does not model interest or penalties.

## Points a Namibian accountant should read first

1. The N$500 000 / N$1 000 000 threshold and the Gazette notice that fixes the
   commencement of the Amendment Act, 2024.
2. Row 15 for imported services, and the VAT import account arrangements
   (s. 14(1)(c)) that move the due date of import VAT to the 20th.
3. That Schedule III and IV, read here in the consolidation to Act 14 of 2022,
   still list what the code descriptions say.
4. The annotated consolidation is a reading aid: the Government Gazette is the
   text.
