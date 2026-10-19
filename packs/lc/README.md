# Saint Lucia

Everything Saint Lucia adds to Ekwo, as data: a chart of accounts, the journals,
the value added tax (VAT) rates and where each one posts, the boxes of a VAT
return, a statement of financial position and an income statement, and the way a
document is numbered. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on.

**Status: `community`.** Nobody who files a Saint Lucian VAT return has reviewed it
against the law they apply. The figures are replayed against two months of books
by `tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

## Sources

Every rate, box and statement carries its own `legal_reference` and the key of
the text it rests on. The register in `pack.json` holds six texts, all opened on
19 October 2026:

| What | Text |
|---|---|
| Imposition (s. 9), registration (s. 12), zero-rated and exempt supplies (s. 16 and 17), imports (s. 22 to 28), tax payable and input tax deduction (s. 29 to 31), interest (s. 33), invoices and credit notes (s. 34 and 35), return (s. 36 to 38), payment (s. 46), refunds (s. 57), First and Second Schedules | Value Added Tax Act, Cap. 15.42 (Act No. 7 of 2012), as published by the Government of Saint Lucia (`lc-vat-act`) |
| The standard rate of 12.5 % (s. 10(1), as amended by S.I. 101 of 2016) | Revised text of section 10, Attorney General's Chambers (`lc-vat-rate`) |
| 7 % on tourism accommodation, 10 % on restaurant food and beverages, water sports, tours and attractions | Value Added Tax (Rate of Tax) (Tourism Sector Goods and Services) Order, 2020, S.I. 188 of 2020, Extraordinary Gazette of 23 November 2020 (`lc-tourism-order-2020`) |
| The form, the 21-day deadline and the office the return goes to | Ministry of Finance service page "File VAT Return" (`lc-vat-return-service`) and "VAT registration" (`lc-vat-portal`) |
| Presentation of the statements | IFRS for SMEs, IASB (`iasb-ifrs-sme`) |

## What the pack carries

- **Twelve tax codes.** Sales: `LC-S-12.5` standard, `LC-S-12.5-INC` the same with
  the VAT already in the price, `LC-S-10` restaurant food and beverages, water
  sports, tours and attractions, `LC-S-7` tourism accommodation, `LC-S-0` export,
  `LC-S-Z` zero-rated at home, `LC-S-EX` exempt. Purchases: `LC-P-12.5`,
  `LC-P-10`, `LC-P-7`, `LC-P-12.5-IMP` (VAT paid to the Comptroller of Customs),
  `LC-P-EX`.
- **The return, `LC-VAT-RETURN`**, boxes 1 to 17, monthly, due the 21st of the
  month after the period (s. 37(1) and s. 46(1)(a) of the Act).
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

- **The box layout is the pack's own.** The Value Added Tax Remittance Form and
  Return of the Inland Revenue Department was not found as a text; the boxes
  follow what the Act makes the tax payable carry (s. 29). A reviewer should align
  the labels with the form. The department's own site (`irdstlucia.gov.lc`) showed
  no VAT pages during the session, and the e-filing portal (`efiling.govt.lc`) is a
  login page: neither is cited.
- **Amendments to the Schedules.** The Act is read in its 2012 enactment. The
  Minister amends the First and Third Schedules by Order (for instance S.I. 84 of
  2023, and temporary zero-ratings of building materials); none is applied, so the
  lists behind `LC-S-Z` and `LC-S-EX` may be out of date. The revised numbering
  (Cap. 15.42) was taken from the Order of 2020.
- **The registration threshold.** The enactment says EC$180,000 (s. 12) and the
  Ministry's registration page says the same; a secondary source quotes
  EC$400,000 from the department. The pack does not check the threshold: it is the
  user's to confirm with the Inland Revenue Department.
- **Tourism rates.** The 7 % and 10 % lists are those of S.I. 188 of 2020; the
  pack does not decide which supplies qualify, nor what a hotel is for the
  purpose of the Act (s. 10(5)). Whether the Order has been amended since 2020 was
  not established.
- **Zero-rated and exempt supplies.** The pack carries three cases (an export, the
  First Schedule by its examples, the Second Schedule by its examples); it does
  not reproduce the schedules.
- **Input tax.** All tax on a business purchase is treated as recoverable. The
  denials of s. 31 (passenger vehicles, entertainment, private use) and the
  allocation of a mixed use (s. 30) are the user's.
- **Services bought from abroad.** s. 9(1)(b) and 28 have the recipient pay the
  tax on an import of services, with an import declaration; the declaration line
  was not found. Recorded in `not_taxed` as a gap, not as an exemption.
- **Import base.** `LC-P-12.5-IMP` applies 12.5 % to the invoice value; the customs
  value (with duty and freight) is the customs entry's.
- **Interest and penalties** on late payment (1.25 % a month, s. 33; 10 %, s. 47(4))
  and the penalty for a late return (s. 89) are not modelled.
- **Refunds.** The pack reports box 17; the carry-forward and the refund rules of
  s. 57 are applied by the Comptroller.
- **Other taxes**: the Act's special regimes and the other levies (income tax,
  National Insurance Corporation contributions, customs duty, excise) are ordinary
  payable and expense accounts. No code, no return.
- **E-invoicing**: no obligation found (`obligation: none`).
