# Guyana

Everything Guyana adds to Ekwo, as data: a chart of accounts, the journals, the
value-added tax (VAT) rate and where it posts, the lines of a VAT return, a
statement of financial position and an income statement, and the way a document
is numbered. The format is [`docs/packs.md`](../../docs/packs.md); this file says
where the content came from and which decisions it rests on.

**Status: `community`.** Nobody who files a Guyanese VAT return has reviewed it
against the law they apply. The figures are replayed against two months of books
by `tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

## Sources

Every rate, box and statement carries its own `legal_reference` and the key of
the text it rests on. The register in `pack.json` holds seven texts, all
published by the Guyana Revenue Authority (GRA) except the accounting standard,
and all opened on 18 October 2026:

| What | Text |
|---|---|
| Imposition of the tax (s. 9), registration, time of supply, zero rating and exemption, imports, input tax, returns, payment, refunds, invoices, Schedules I to IV | Value-Added Tax Act 2005, Act No. 10 of 2005, revised edition as amended up to (O) 6 of 2021 (`gy-vat-act`) |
| The rate (14 %, reg. 2), the registration threshold ($15,000,000, reg. 3) | Value-Added Tax Regulations 2005 as amended by Regulation 8 of 2016 (`gy-vat-regs`) |
| Zero-rated and exempt supplies as they stand today | Schedules I and II, list revised on 27 March 2026 (`gra-zero-exempt`) |
| The 21st as due date, the meaning of each line of the return | "Value Added Tax Return" page (`gra-vat-return`) and the printed form (`gra-vat-return-form`) |
| The portal | Optimal eServices (`gra-optimal`) |
| Presentation of the statements | IFRS for SMEs, IASB (`iasb-ifrs-sme`) |

## What the pack carries

- **Nine tax codes.** Sales: `GY-S-14` standard, `GY-S-14-INC` the same with the
  VAT already in the price, `GY-S-0` export, `GY-S-Z` zero-rated at home,
  `GY-S-EX` exempt. Purchases: `GY-P-14`, `GY-P-14-IMP` (VAT paid on entry of
  goods), `GY-P-0`, `GY-P-EX`. Guyana has one positive rate, 14 %, and a zero rate.
- **The return, `GY-VAT-RETURN`**, monthly, due the 21st of the month after the
  period. Its boxes carry the **line numbers of the GRA's return** (6 to 10, 14 to
  18, 20, 23 and 25), so that a user reads the same numbers on both.
- **A chart of 117 accounts**, four digits, IFRS for SMEs in spirit; the return is
  settled on `2100` (payable) or `1172` (refundable), apart from the accounts the
  tax posts to. Not a legal chart: none was found.
- **A statement of financial position and an income statement** in the manner of
  IFRS for SMEs. VAT collected sits in current tax liabilities, VAT recoverable in
  receivables, unnetted.
- **Language**: English, the official language. No `i18n`.
- **Currency**: the Guyanese dollar (`GYD`, two decimals).

## What the pack does not say yet

- **Due date: 21st or fifteen days?** The GRA's return page says the 21st of
  every month (next business day if a holiday). The revised Act read for this
  pack says, in s. 31(1), fifteen days after the end of the period. The pack
  follows the GRA's page, the current instruction, and a reviewer should settle
  which text governs.
- **Lines of the return not posted to.** Line 5 (credit from earlier months),
  lines 11 and 12 (VAT on purchases for mixed supplies), line 13 and line 19
  (adjustments of earlier periods), line 21 (major capital acquisitions) and
  line 22 are not modelled: the pack reads the books of the period only. Total
  input VAT (box 14) is therefore lines 9 and 10; lines 24 and 26 are not given.
  Credits are not carried forward by the return; the books carry them.
- **Mixed supplies.** The apportionment between taxable and exempt supplies
  (s. 25) and the GRA's partial exemption leaflet are the user's. All input tax on
  a purchase code is treated as creditable for taxable supplies.
- **Zero-rated and exempt supplies.** The pack carries one code for each case and
  does not reproduce the schedules, which the GRA amends often (the list read was
  revised on 27 March 2026). Whether a supply is on them is the user's.
- **The rate and the threshold** are fixed by regulations, subject to an
  affirmative resolution of the National Assembly (s. 9(1), Schedule IV): the
  Regulations read are those consolidated to January 2017 and were not checked for
  later changes. The registration threshold ($15,000,000 of taxable supplies, reg. 3) is
  the user's to apply: the pack does not check it.
- **Start date.** The Act leaves its commencement to a ministerial order that
  was not read: `valid_from` 1 January 2007 is an assumption to verify.
- **Services bought from abroad.** The Act has the recipient declare and pay the
  tax within twenty days (s. 9(2)(c), s. 22(2)). The GRA's guide to imported
  services was not opened. Recorded in `not_taxed` as a gap, not as an exemption.
- **Import base.** `GY-P-14-IMP` applies 14 % to the invoice value; the customs
  value (with insurance and freight, s. 20) is the customs entry's.
- **Interest and penalties**: interest at two per cent a month on unpaid tax
  (Schedule IV) and the penalty for a late return are not modelled.
- **Refunds.** The excess is carried forward and refundable after six consecutive
  periods (s. 35); the pack only reports box 23.
- **The invoice's particulars** (s. 28, Schedule III) are not printed as mentions.
- **Other levies**: income tax, corporation tax, National Insurance Scheme
  contributions, customs duty and excise are ordinary payable and expense
  accounts. No code, no return.
- **E-invoicing**: no obligation found (`obligation: none`).
