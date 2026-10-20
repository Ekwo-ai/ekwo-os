# Trinidad and Tobago

Everything Trinidad and Tobago adds to Ekwo, as data: a chart of accounts, the
journals, the value added tax (VAT) rate and where it posts, the boxes of a VAT
return, a statement of financial position and an income statement, and the way a
document is numbered. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on.

**Status: `community`.** Nobody who files a VAT return in Trinidad and Tobago has
reviewed it against the law they apply. The figures are replayed against two
months of books by `tests/golden.test.ts`, which proves the pack is coherent and
proves nothing about whether it is right.

## Sources

Every rate, box and statement carries its own `legal_reference` and the key of
the text it rests on. The register in `pack.json` holds four texts, all opened on
20 October 2026:

| What | Text |
|---|---|
| Charge and rate (s. 6 and 7), zero-rating (s. 8, Schedule 2), imports (s. 9 to 12), commercial supply (s. 14), place and time of supply (s. 16 and 17), registration (s. 20 and 21), tax periods and returns (s. 30 and 31), tax payable or refund due (s. 32 to 35), tax invoices and notes (s. 36 and 37), books (s. 38), interest and penalty (s. 54), exempt services (Schedule 1) | Value Added Tax Act, Chap. 75:06, unofficial version updated to 31 December 2016 (`tt-vat-act`) |
| The rate of 12.5 % today and the registration threshold of TT$600,000 | Inland Revenue Division, Value Added Tax page (`tt-ird-vat`) |
| The administration's website | Inland Revenue Division (`tt-ird-portal`) |
| Presentation of the statements | IFRS for SMEs, IASB (`iasb-ifrs-sme`) |

## What the pack carries

- **Eight tax codes.** Sales: `TT-S-125` standard, `TT-S-125-INC` the same with the
  VAT already in the price, `TT-S-0` export, `TT-S-Z` zero-rated at home
  (Schedule 2), `TT-S-EX` exempt (Schedule 1). Purchases: `TT-P-125`,
  `TT-P-125-IMP` (VAT paid to the Comptroller of Customs and Excise), `TT-P-EX`.
- **The return, `TT-VAT-RETURN`**, boxes 1 to 12, bimonthly or monthly, due 25
  days after the end of the period (s. 31(2) and 35(1)), which is the 25th of the
  next month.
- **A chart of 116 accounts**, four digits, IFRS for SMEs in spirit; the return is
  settled on `2100` (payable) or `1172` (refundable), apart from the accounts the
  tax posts to. Not a legal chart: none was found.
- **A statement of financial position and an income statement** in the manner of
  IFRS for SMEs. VAT collected sits in current tax liabilities, VAT recoverable in
  receivables, unnetted.
- **Language**: English, the official language. No `i18n`.
- **Currency**: the Trinidad and Tobago dollar (`TTD`, two decimals).

## What the pack does not say yet

- **The Act read is an unofficial version updated to 31 December 2016.** The
  Schedules, above all Schedule 2, have been amended often since, and the
  Minister may amend them by Order (s. 8(4)); the Act's own threshold for
  registration (TT$500,000, s. 21) is read from that version, while the Division's
  page gives TT$600,000 as of 1 January 2023. The pack does not reproduce the
  Schedules or check the threshold: the user does, against the current text.
- **Prescribed services.** The tax is charged on goods and on *prescribed
  services* only (s. 6(b), s. 14). Which services are prescribed was not read as a
  text; `TT-S-125` taxes whatever it is given, and a service that is not
  prescribed is the user's to put on `TT-S-EX`.
- **The box layout is the pack's own.** The Board's return form was not read as a
  text; the boxes follow what the Act makes the tax payable carry (s. 32). A
  reviewer should align the labels with the form.
- **Tax periods.** Category B is bimonthly (January–February…); category A is one
  month and then two-month periods starting in February, which the format cannot
  express; category C is fixed by the Board for the taxpayer (s. 30). The pack
  declares `bimonth` and `month` and no default.
- **Input tax.** All tax on a business purchase is treated as recoverable. The
  apportionment between commercial and other supplies (s. 34(3)) and the exclusion
  of purchases made for other than the business are the user's.
- **Services bought from abroad.** A supply by a non-resident is, as a rule,
  regarded as not taking place in the country (s. 16); no reverse charge was
  found. Recorded in `not_taxed` as a gap, not as an exemption.
- **Import base.** `TT-P-125-IMP` applies 12.5 % to the invoice value; the customs
  value (s. 12) is the customs entry's.
- **Rate history.** `valid_from` is 1 January 1990, the appointed day; the changes
  of the rate since then were not traced, and the pack carries 12.5 % throughout.
- **Time of supply.** `earliest_of_delivery_or_payment` leaves out the invoice
  date, which s. 17(1)(a) also makes a tax point.
- **Interest and penalties** on a late return or unpaid tax (8 % and 2 % a month,
  s. 54) are not modelled; neither is the interest on a late refund (s. 35(3)).
- **Other taxes**: corporation tax, business levy, National Insurance, customs
  duty and the financial services taxes are ordinary payable and expense
  accounts. No code, no return.
- **E-invoicing**: no obligation found (`obligation: none`).
