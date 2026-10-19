# Saint Kitts and Nevis

Everything Saint Kitts and Nevis (the Federation of Saint Christopher and Nevis)
adds to Ekwo, as data: a chart of accounts, the journals, the value added tax
(VAT) rates and where each one posts, the boxes of a VAT return, a statement of
financial position and an income statement, and the way a document is numbered.
The format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on.

**Status: `community`.** Nobody who files a VAT return in the Federation has
reviewed it against the law they apply. The figures are replayed against two
months of books by `tests/golden.test.ts`, which proves the pack is coherent and
proves nothing about whether it is right.

## Sources

Every rate, box and statement carries its own `legal_reference` and the key of
the text it rests on. The register in `pack.json` holds five texts, all opened on
19 October 2026:

| What | Text |
|---|---|
| Registration (s. 12), imposition and rates (s. 25 and 26), zero-rated and exempt supplies (s. 33 and 34, Second and Third Schedules), tax payable (s. 38), input tax deduction (s. 39 and 40), invoices and notes (s. 43 and 44), period and return (s. 45 and 46), payment (s. 50), refunds (s. 61) | Value Added Tax Act, 2010 (No. 3 of 2010) (`kn-vat-act`) |
| Reduced rates for accommodation, tour operators and restaurants (regulations 9 to 11) | Value Added Tax Regulations, 2011, S.R.O. No. 38 of 2011 (`kn-vat-regs-2011`) |
| The three rates and examples of zero-rated and exempt supplies | Inland Revenue Department, Introduction to VAT (`kn-ird-vat-intro`) |
| The administration's website | Inland Revenue Department (`kn-ird-portal`) |
| Presentation of the statements | IFRS for SMEs, IASB (`iasb-ifrs-sme`) |

## What the pack carries

- **Eleven tax codes.** Sales: `KN-S-17` standard, `KN-S-17-INC` the same with the
  VAT already in the price, `KN-S-10` accommodation, `KN-S-10-R` restaurant and
  tour operator, `KN-S-0` export, `KN-S-Z` zero-rated at home, `KN-S-EX` exempt.
  Purchases: `KN-P-17`, `KN-P-10`, `KN-P-17-IMP` (VAT paid to the Comptroller of
  Customs), `KN-P-EX`.
- **The return, `KN-VAT-RETURN`**, boxes 1 to 17, monthly, due the 15th of the
  month after the period (s. 45, 46(1) and 50 of the Act).
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

- **The box layout is the pack's own.** The Department's form VAT-01 was not read
  as a text; the boxes follow what the Act makes the tax payable carry (s. 38). A
  reviewer should align the labels with the form.
- **The standard rate.** The Act says 17 percent (s. 26(1)(a)), and the Department's
  introduction agrees. A secondary source speaks of a temporary cut to 13 % that
  ended on 1 July 2025; no official text for it was found, so the pack carries
  17 % from the start of the Act and does not model a period at another rate.
  A company with books dated in that window should check with its accountant.
- **Commencement.** The date the Act came into force was not read; `valid_from` is
  1 July 2010 and is to be confirmed.
- **The 10 % rate** applies, "to the extent provided in regulations", to
  accommodation, tour operators and restaurants (s. 26(1)(d); regulations 9 to 11);
  the pack does not decide which supplies qualify.
- **Registration thresholds** (s. 12): $150,000 of taxable supplies in twelve
  months, and $96,000 for the lease of commercial and time-share property and for
  prescribed professional services. The user applies them; the pack does not check
  them. Amendments after the version published on the National Information
  Agency's site, and any Order changing the thresholds (s. 12(18)), are not applied.
- **Zero-rated and exempt supplies.** The pack carries three cases (an export, the
  Second Schedule by its examples, the Third Schedule by its examples); it does not
  reproduce the schedules. Electricity and domestic water appear among the
  Department's examples of exempt supplies; whether a given supply is exempt is
  the user's to check against the Third Schedule and the regulations.
- **Input tax.** All tax on a business purchase is treated as recoverable. The
  denials and the apportionment of s. 40 are the user's.
- **Services bought from abroad.** s. 26(1)(b) and s. 11 have the person liable
  declare imported services and pay the tax within fifteen days after the tax
  period; the declaration line was not found. Recorded in `not_taxed` as a gap,
  not as an exemption.
- **Import base.** `KN-P-17-IMP` applies 17 % to the invoice value; the customs
  value (with duty and freight) is the customs entry's.
- **Interest and penalties** on a late return or unpaid tax (s. 42, 1.25 % a month
  or part of a month) are not modelled.
- **Refunds.** The pack reports box 17; the carry-forward and the refund rules of
  s. 61 are applied by the Comptroller.
- **Other taxes**: the Act's special regimes (gambling, second-hand goods, going
  concerns) and the other levies (income tax, social security contributions,
  customs duty, the Nevis Island Administration's own taxes) are ordinary payable
  and expense accounts. No code, no return.
- **E-invoicing**: no obligation found (`obligation: none`).
