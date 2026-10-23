# Jordan

Everything Jordan adds to Ekwo, as data: a chart of accounts, the journals,
the general sales tax at 16 % with the reduced rates of 10 %, 5 %, 4 % and
2 %, zero-rated exports, exempt supplies and supplies outside the tax, the
tax on imported goods and the tax a recipient owes on an imported service, a
two-month return built line for line from the Income and Sales Tax
Department's own form, and the statement of financial position and the income
statement of IFRS. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on.

**Status: `community`.** Nobody who files a Jordanian sales tax return has
reviewed it. The figures are replayed against two months of books by
`tests/golden.test.ts`, which proves the pack is internally coherent and
proves nothing about whether it is right.

**Language.** `defaults.language` is `ar`, the language of the Department's
forms and tables. Every label is written in English, with `en.json` an exact
mirror rather than a second language, because no verified Arabic accounting
terminology is carried. See [`i18n/README.md`](i18n/README.md).

**Currency.** The Jordanian dinar has three decimals (1 dinar = 1 000 fils).
The return form itself is printed in dinars and fils.

## Sources

Every rate, line and rule carries the key of a register entry in
`pack.json`:

| Key | What it is |
|---|---|
| `gst-law` | The General Sales Tax Law No. 6 of 1994 as amended, the Department's updated English text (headed by Provisional Law No. 29 of 2009). Article 6 sets the general tax at 16 per cent. |
| `gst-schedules` | The Department's tables, in Arabic: the statements of goods at 10 %, 5 %, 4 % and 2 %, Schedules 2, 3 and 4. |
| `gst-return` | The general sales tax return, form CED:PR15.F12, updated 7 November 2022: lines 1 to 19 and their formula. |
| `ifrs-jordan-profile`, `ias-1` | The reporting framework behind the statements. |
| `istd-portal`, `istd-eservices`, `jofotara` | The Department's website, the electronic services where a return is filed, and the e-invoicing portal. |

The English text of the Law is a consolidation that lists amending laws only
up to 2004 and the provisional law of 2009. Everything newer — the reduced
rates above all — was read in the Department's Arabic tables. Those PDFs
come out of a text extractor with their Arabic reversed and their order
scrambled, and the lines they hold were identified, not proofread: a reader
of Arabic should check each item of the 10 %, 5 %, 4 % and 2 % statements
and of Schedules 2 to 4 before the codes are used for a real invoice.

## The chart of accounts, and why this one

No legal chart of accounts for Jordanian companies in general was found. The
chart is original: four digits, blocked so that each range reaches one line of
the statements (IAS 1, expenses by nature), 146 accounts. The accounts the
return depends on:

| Account | Role |
|---|---|
| 1150 | General tax input, debited by every deductible purchase |
| 1155 | Tax refundable by the Department, the settlement account of a credit return |
| 2100 | General tax output |
| 2110 | Tax payable to the Department, the settlement account of a debit return |
| 2125 | Tax on imported goods owed to Customs at the border |
| 2126 | Tax on imported services owed to the Department by the recipient |

The settlement accounts are separate from the posting accounts, which
`tests/filing_golden.test.ts` asks for, and are the only reconcilable tax
accounts.

## Taxes

24 codes, each with its article. A line names its code, never a rate:

- **Sales**: `JO-S-16`, `JO-S-10`, `JO-S-4`, `JO-S-5`, `JO-S-2`, then zero-rated exports
  `JO-S-ZR-EXP` (line 8), other zero-rated `JO-S-ZR` (line 7), exempt `JO-S-EX`
  (line 10), and `JO-S-NT` for supplies Article 10 leaves outside the tax (line 9).
- **Purchases**: the same rates as `JO-P-16`, `JO-P-10`, `JO-P-4`, `JO-P-5`, `JO-P-2`;
  `JO-P-16-NC` for a purchase of Schedule 4, whose tax joins the cost;
  `JO-P-ZR`, `JO-P-EX`.
- **Imports**: `JO-P-IMP-16`, `-10`, `-4`, `-5`, `-2` and `JO-P-IMP-0`, the tax paid at the
  border; `JO-P-RC-SVC` for a service received from abroad, which the recipient
  pays to the Department under Article 9(e), deducts on line 3 and owes apart
  from the return (Article 26(c)).

A sale of a capital asset takes the code of its rate; the form has no separate
line for it. Which goods are on which statement is the preparer's choice of
code; the pack does not list the goods.

## The return

`JO-GST` is filed every two months (`bimonth`, Article 16). Its boxes are the
lines of form CED:PR15.F12 with the form's own formula: the tax of lines
6 + 11 + 13, less the tax of lines 1 + 2 + 3 + 12; positive is payable (line
14), negative is the credit (line 15), carried forward or refunded.

The form prints the rates 16 %, 10 %, 4% and "other" on lines 2, 3 and 6;
5 % and 2 % are entered on the "other" row, which is why they share a box.

## The statements

`JO-IFRS-SFP` and `JO-IFRS-IS`, the same IFRS layout as the other packs of the
region, on this chart. No Jordanian text prescribing a layout for companies in
general was read.

## What this pack does not carry

- **The filing day.** The consolidated Law gives the period (two months) and
  leaves the day to the executive instructions (Instructions No. 2 of 2003 on
  returns and tax periods), which were not found in English; secondary
  sources say the end of the month following the period. `tax_report.json`
  therefore carries no `deadline`: nobody has read the text.
- **The registration threshold.** It is set by Regulation No. 81 of 2000, as
  amended, which was not found. Secondary sources give JOD 30 000 for services
  and JOD 75 000 for goods; they are not repeated in the pack.
- **The special tax** (Schedule 1) and its monthly return: not modelled.
- **Lines 1, 11, 12, 13, 16 to 19 of the return**: the carry-forward, the part
  of the input tax relating to exempt sales, the adjustments and the refund
  claims are declared and empty. They are the preparer's.
- **Line 4**, imports with deferred remittance, and the annexes of the form
  (sales invoice number ranges, the purchase invoices with the highest tax,
  the sales to the bodies of Articles 21 and 22).
- **The Aqaba Special Economic Zone**, which has its own returns.
- **Electronic invoicing.** JoFotara exists; the text that says who issues
  through it, from when and in what message was not read, and no brick of the
  formats package writes it. `obligation` is `none` for want of a text.
- **Tax invoice contents.** The executive instructions on invoices
  (Instructions No. 6 of 2003) were not found, so the pack carries no legal
  mention for an invoice.
- **Time of supply.** Article 9 is a three-way test for goods and a two-way
  one for services; the pack takes `earliest_of_delivery_or_payment`.

## Reviewing this pack

A Jordanian accountant should read, in this order: the reduced-rate
statements against `taxes.json`, the exempt and zero-rated schedules against
the three sales codes, the filing day, and the form against `tax_report.json`.
