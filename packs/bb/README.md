# Barbados

Everything Barbados adds to Ekwo, as data: a chart of accounts, the journals,
the value added tax (VAT) rates and where each one posts, the boxes of a VAT
return, a statement of financial position and an income statement, and the way a
document is numbered. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on.

**Status: `community`.** Nobody who files a Barbados VAT return has reviewed it
against the law they apply. The figures are replayed against two months of books
by `tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

## Sources

Every rate, box and statement carries its own `legal_reference` and the key of
the text it rests on. The register in `pack.json` holds eight texts, all
published by the Barbados Revenue Authority except where said, and all opened on
17 October 2026:

| What | Text |
|---|---|
| Imposition of the tax, time of supply, taxable periods, returns, payment, refund of input tax, records | Value Added Tax Act, Cap. 87, consolidated text published by the Authority (`bb-vat-act`) |
| The particulars of a tax invoice, a credit note, a receipt; the records | Value Added Tax Regulations, 1996, Cap. 87A (`bb-vat-regs`) |
| 0 %, 7.5 %, 17.5 % and 22 %; the registration threshold | VAT rates and threshold page (`bra-vat-rates`) |
| The two series of two-month filing periods | What are the VAT filing periods? (`bra-filing-periods`) |
| Zero-rated items from 1 April 2022 | Policy Note P&F No. 003/2022 (`bra-zero-rated-2022`) |
| Who must register | Authority's registration page (`bra-who-registers`) |
| The portal | Authority's VAT page (`bra-vat-portal`) |
| Presentation of the statements | IFRS for SMEs, IASB (`iasb-ifrs-sme`) |

## What the pack carries

- **Twelve tax codes.** Sales: `BB-S-175` standard, `BB-S-175-INC` the same with
  the VAT already in the price (the Act requires a displayed price to include it,
  s. 7(4)), `BB-S-75` accommodation, `BB-S-22` telecommunications, `BB-S-0`
  export, `BB-S-Z` zero-rated at home, `BB-S-EX` exempt. Purchases: `BB-P-175`,
  `BB-P-75`, `BB-P-22`, `BB-P-175-IMP` (VAT paid to the Comptroller of Customs),
  `BB-P-EX`.
- **The return, `BB-VAT-RETURN`**, boxes 1 to 17, bimonthly or monthly, due the
  21st of the month after the period (s. 45(1) and 46(1) of the Act).
- **A chart of 118 accounts**, four digits, IFRS for SMEs in spirit; the return is
  settled on `2100` (payable) or `1172` (refundable), apart from the accounts the
  tax posts to. Not a legal chart: none was found.
- **A statement of financial position and an income statement** in the manner of
  IFRS for SMEs. VAT collected sits in current tax liabilities, VAT recoverable in
  receivables, unnetted.
- **Language**: English, the official language. No `i18n`.

## What the pack does not say yet

- **The box layout is the pack's own.** The Authority's VAT return form was not
  found online (returns are filed in its online services portal), so the boxes
  follow what the Act makes a return carry. A user who files by typing the totals
  into the portal reads the right numbers off the pack's boxes; a reviewer should
  align the labels with the portal's screens.
- **The rates rest on the rates page, not on the Act text read.** The
  consolidated Cap. 87 the Authority publishes still prints 15 % in s. 7(2) and
  (3) and 7½ % in s. 7(11). The 17.5 % standard rate and the 22 % rate on
  telecommunications come from the Authority's rates page; the amending
  Acts and Orders listed beside the consolidated text (for example the Value Added
  Tax (Amendment) Act, 2023-6) were not applied, and the dates from which each
  rate applies were not found. `valid_from` is therefore 1 April 2022 on every
  code, the date of the Authority's current zero-rated list.
- **The accommodation rate.** 7.5 % on the Act (s. 7(11)) and on the rates page.
  Secondary sources report 10 % for the sector since 1 January 2020. No official
  text read says so; a reviewer confirms the rate in force.
- **The registration threshold** ($200,000 of annual income, or monthly revenue
  above $16,666.67, on the Authority's pages) is the user's to apply: the pack does
  not check it. A rise to $350,000 reported for 1 October 2026 was not found in an
  official text.
- **Filing periods.** The Authority's table lists two series of two-month periods.
  The format anchors a bimonth on 1 January, which fits the series starting in
  January (Jan–Feb, Mar–Apr…); the series starting in December (Dec–Jan, Feb–Mar…)
  is not expressible, and neither is the weekend roll-forward of the due date.
- **Zero-rated and exempt supplies.** The pack carries three cases (an export, the
  First Schedule's list of 2022 by its examples, the financial service of the
  Second Schedule); it does not reproduce the schedules. Zero-rated importations
  (Third Schedule) are not modelled.
- **Input tax.** All tax on a business purchase is treated as recoverable.
  Section 49 (motor cars), the apportionment for a mix of taxable and exempt
  supplies, bad debts (s. 53) and tax paid in error (s. 54) are the user's.
- **Services bought from abroad.** Recorded in `not_taxed` as a gap, not as an
  exemption: how they are declared was not found.
- **Import base.** `BB-P-175-IMP` applies 17.5 % to the invoice value; the customs
  value (with duty) is the customs entry's.
- **Penalty and interest** on a late return or payment (s. 45(3), 46(4)) are not
  modelled.
- **The invoice's particulars** (reg. 2 of the Regulations) are not printed as
  mentions: no mention is conditional on the kind of supply.
- **Other levies**: corporation tax, National Insurance Scheme contributions, land
  tax, customs duty and excise are ordinary payable and expense accounts. No code,
  no return.
- **E-invoicing**: no obligation found (`obligation: none`).
