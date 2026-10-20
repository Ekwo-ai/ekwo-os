# Saint Vincent and the Grenadines

Everything Saint Vincent and the Grenadines adds to Ekwo, as data: a chart of
accounts, the journals, the value added tax (VAT) rates and where each one posts,
the boxes of a VAT return, a statement of financial position and an income
statement, and the way a document is numbered. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on.

**Status: `community`.** Nobody who files a VAT return in the country has
reviewed it against the law they apply. The figures are replayed against two
months of books by `tests/golden.test.ts`, which proves the pack is coherent and
proves nothing about whether it is right.

## Sources

Every rate, box and statement carries its own `legal_reference` and the key of
the text it rests on. The register in `pack.json` holds seven texts, all opened on
20 October 2026:

| What | Text |
|---|---|
| Imposition and the rate by kind of supply (s. 8), reverse charge on imported services (s. 18), input tax credits (s. 29), invoices and receipts (s. 32 to 34), returns (s. 39), payment (s. 41), refunds (s. 44), zero-rated and exempt supplies (First to Fourth Schedules) | Value Added Tax Act, Cap. 445, revised edition 2009 (`vc-vat-act`) |
| The current rates (16 %, 11 %), filing and payment on the 15th, interest | Inland Revenue Department, page "Taxes" (`vc-ird-taxes`) |
| Registration threshold, VAT invoice and sales receipt, reverse charge | Inland Revenue Department, FAQ (`vc-ird-faqs`) |
| Nine foods and adult diapers zero-rated from 3 November 2025 | Cabinet decision of 29 October 2025 (`vc-cabinet-zero-rating-2025`) |
| The date of the 16 % rate, 1 May 2017 | Press report of the 2017 Budget Address (`vc-budget-2017-news`) |
| The administration's website | Inland Revenue Department (`vc-ird-portal`) |
| Presentation of the statements | IFRS for SMEs, IASB (`iasb-ifrs-sme`) |

## What the pack carries

- **Eleven tax codes.** Sales: `VC-S-16` standard, `VC-S-16-INC` the same with the
  VAT already in the price, `VC-S-11` accommodation, `VC-S-11-T` diving, tour and
  other tourist services, `VC-S-0` export, `VC-S-Z` zero-rated at home, `VC-S-EX`
  exempt. Purchases: `VC-P-16`, `VC-P-11`, `VC-P-16-IMP` (VAT paid to the
  Comptroller of Customs), `VC-P-EX`.
- **The return, `VC-VAT-RETURN`**, boxes 1 to 17, monthly, due the 15th of the
  month after the period (s. 39(1) and 41(1) of the Act, confirmed by the
  Department).
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

- **The Act in force was not read.** The only text of the Act the Department
  publishes is a scan of the revised edition of 2009 (issue 1/2009, with no text
  layer; it was read by optical character recognition). That edition says 15 percent
  and 10 percent; the Department's pages say 16 and 11 percent today. The amending
  instrument was not found, and `valid_from` 1 May 2017 for the new rates comes from
  a press report of the Budget Address. A reviewer should replace both with the
  amending Act.
- **The box layout is the pack's own.** The Department's return form was not read
  as a text; the boxes follow what the Act makes the tax payable carry. A reviewer
  should align the labels with the form, which is filed through the e-Tax service
  linked from the Department's site.
- **The rate of tourist services.** The Act (s. 8(3)(b)(iii)) names diving, marine or
  land tour services and the services a Minister's order prescribes at the reduced
  rate. The Department states 11 percent for accommodation only; the pack carries
  11 percent for tourist services on the strength of the press report that raised
  both rates together, and did not read the order. Restaurants have no reduced rate
  in the Act as read.
- **Registration threshold.** The Department's FAQ gives $300,000 of taxable sales in
  twelve months (the 2009 edition's own threshold, $120,000, is not the current one);
  hoteliers and promoters of public entertainment register whatever their sales. The
  user applies it; the pack does not check it.
- **Zero-rated and exempt supplies.** The pack carries the three cases (an export,
  the Third Schedule by its list, the Fourth Schedule by its list) and does not
  reproduce the schedules. The list of zero-rated foods has grown since 2009, the
  last time on 3 November 2025; whether a given supply is on it is the user's to
  check. The items of the Fourth Schedule beyond item 10 were not read.
- **Input tax.** All tax on a business purchase is treated as recoverable. The
  denials of s. 28 and the apportionment are the user's.
- **Services bought from abroad.** s. 18 and the Department's FAQ describe a reverse
  charge; the declaration line was not found. Recorded in `not_taxed` as a gap, not
  as an exemption.
- **Import base.** `VC-P-16-IMP` applies 16 % to the invoice value; the customs value
  (with duty and freight) is the customs entry's.
- **Interest and penalties** on a late return or unpaid tax (a penalty of 20 % of the
  unpaid tax, s. 41(3); interest of 1.5 % a month according to the Department) are
  not modelled.
- **Refunds.** The pack reports box 17; the carry-forward of a credit under $100 and
  the refund after three months of credit described by the Department are applied
  by the Comptroller.
- **Other taxes**: the other levies (income tax, withholding tax, the National
  Insurance Services contributions, excise, the climate resiliency levy, customs
  duty) are ordinary payable and expense accounts. No code, no return.
- **E-invoicing**: no obligation found (`obligation: none`).
