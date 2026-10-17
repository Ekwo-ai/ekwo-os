# Dominica

Everything Dominica adds to Ekwo, as data: a chart of accounts, the journals,
the value added tax (VAT) rates and where each one posts, the boxes of a VAT
return, a statement of financial position and an income statement, and the way a
document is numbered. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on.

**Status: `community`.** Nobody who files a Dominican VAT return has reviewed it
against the law they apply. The figures are replayed against two months of books
by `tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

## Sources

Every rate, box and statement carries its own `legal_reference` and the key of
the text it rests on. The register in `pack.json` holds eight texts, all
published by the Government of the Commonwealth of Dominica (the Inland Revenue
Division and the Laws of Dominica site) except where said, and all opened on
17 October 2026:

| What | Text |
|---|---|
| Imposition of the tax (s. 9), time of supply, zero rating and exemption, input tax, tax period, returns, payment, refunds, records, Schedules I and II | Value Added Tax Act, 2005, Act 7 of 2005, as enacted (`dm-vat-act`) |
| The 10 % rate for the dive activity of a dive package (s. 9(1)(d)) | Value Added Tax (Amendment) Act, 2006, Act 4 of 2006 (`dm-vat-amend-2006`) |
| The 10 % rate on accommodation (reg. 5), time and place of supply, value | Value Added Tax Regulations, 2006, S.R.O. 9 of 2006 (`dm-vat-regs`) |
| 15 % and 10 %, the 20th as due date, penalty and interest | Division's VAT page (`ird-vat`) |
| Who registers, threshold, zero-rated and exempt supplies in plain words, returns and tax periods | Guide to Registration for VAT, 2018 (`ird-vat-registration-guide`) |
| Carry forward and refund of excess input tax | Guide to Filing VAT Claims and Applications for Refund (`ird-vat-refund-guide`) |
| The portal | Tax eFiling (`ird-efiling`) |
| Presentation of the statements | IFRS for SMEs, IASB (`iasb-ifrs-sme`) |

## What the pack carries

- **Ten tax codes.** Sales: `DM-S-15` standard, `DM-S-15-INC` the same with the
  VAT already in the price, `DM-S-10` accommodation and dive activity, `DM-S-0`
  export, `DM-S-Z` zero-rated at home, `DM-S-EX` exempt. Purchases: `DM-P-15`,
  `DM-P-10`, `DM-P-15-IMP` (VAT paid to the Comptroller of Customs), `DM-P-EX`.
- **The return, `DM-VAT-RETURN`**, boxes 1 to 15, monthly, due the 20th of the
  month after the period (s. 31, 32 and 41 of the Act).
- **A chart of 117 accounts**, four digits, IFRS for SMEs in spirit; the return is
  settled on `2100` (payable) or `1172` (refundable), apart from the accounts the
  tax posts to. Not a legal chart: none was found.
- **A statement of financial position and an income statement** in the manner of
  IFRS for SMEs. VAT collected sits in current tax liabilities, VAT recoverable in
  receivables, unnetted.
- **Language**: English, the official language. No `i18n`.
- **Currency**: the East Caribbean dollar (`XCD`, two decimals), shared with the
  other members of the Eastern Caribbean Currency Union.

## What the pack does not say yet

- **The box layout is the pack's own.** The Division's monthly VAT return form
  was not found online (returns are filed in its Tax eFiling service; the
  forms page lists only the registration form VAT-001 and refund forms). The boxes
  follow what the Act makes a return carry. A reviewer should align the labels
  with the screens of the portal.
- **Amendments.** The Act is read as enacted, with Act 4 of 2006 and the
  Regulations. Acts 17 of 2008, 8 of 2014 and 12 of 2015 and the Regulations of
  2013 and 2016, listed on the Division's VAT page, were not applied (Acts 8 of 2014
  and 12 of 2015 could not be read as text). The rates (15 %, 10 %) were checked on
  the Division's VAT page, which is current; the schedules may have moved.
- **The 10 % rate** applies "to the extent provided in regulations" (s. 9(1)(c)):
  reg. 5 limits it to accommodation by a hotel, guest house, inn or similar
  establishment and to furnished lets, not to a renter in a private home. The pack
  does not decide which supplies qualify. The dive activity rate (s. 9(1)(d))
  relies on a dive package being split; the regulation text for it was not found.
- **The registration threshold** ($250,000 of annual taxable supplies, or taxable
  supplies above $62,500 over three months with $250,000 expected, in the
  Division's guide) is the user's to apply: the pack does not check it.
- **Zero-rated and exempt supplies.** The pack carries three cases (an export,
  Schedule I by its examples, Schedule II by its examples); it does not reproduce
  the schedules. Exempt imports (Schedule III) are not modelled.
- **Input tax.** All tax on a business purchase is treated as recoverable.
  The apportionment for a mix of taxable and exempt supplies and the disallowance
  rules (s. 26), post-sale adjustments and bad debts (s. 27) are the user's.
- **Services bought from abroad.** The Act taxes them at 15 % and has the recipient
  pay within 20 days of the period (s. 9(1)(b), s. 23); the declaration form was not
  found. Recorded in `not_taxed` as a gap, not as an exemption.
- **Import base.** `DM-P-15-IMP` applies 15 % to the invoice value; the customs
  value (with duty and freight) is the customs entry's.
- **Penalty and interest** on a late return ($100 a month), late payment (10 %,
  s. 41(4)) and unpaid tax (1 % a month, s. 28) are not modelled.
- **Cash accounting and the refund process.** Refunds follow the Division's
  six-period rule; the pack only reports box 15.
- **The invoice's particulars** (s. 29 and the Regulations) are not printed as
  mentions.
- **Other levies**: income tax, social security contributions, customs duty and
  excise are ordinary payable and expense accounts. No code, no return.
- **E-invoicing**: no obligation found (`obligation: none`).
