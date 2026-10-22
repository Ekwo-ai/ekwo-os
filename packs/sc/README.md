# Seychelles

Everything Ekwo carries for Seychelles is data: a chart of 146 accounts, the value
added tax (VAT) at 15 % with its zero-rated and exempt supplies, the monthly return in
the numbering of the Seychelles Revenue Commission's form (lines 1 to 11), and a
statement of financial position and a statement of profit or loss. The format is in
[`docs/packs.md`](../../docs/packs.md); this file says where each line comes from and
what the pack does not do, so that a Seychelles accountant can argue with one sentence
rather than with the whole.

**Status: `community`.** No bookkeeper or auditor has read this pack. The figures are
recomputed from a month of books by `tests/golden.test.ts`, which proves the pack agrees
with itself and not that it is right in law.

**What was read, and what was not.** The Schedules of the Value Added Tax Act as
substituted by S.I. 4 of 2014 (copy in the Supplement to the Official Gazette hosted by
the World Trade Organization), the Commission's VAT return and its instructions, the
Business Activity Statement, the Revenue Law (Amendment) Act 2023, the Commission's VAT
brochures and its notice on the registration threshold. **The sections of the Act itself
were not found**: neither the rules on the time of supply, on the VAT invoice, on input tax
apportionment nor on the tax assessed on services bought from abroad could be cited, and
nothing later than the 2023 Act and the 2024 threshold notice was searched. A Seychelles
reader must confirm that the Third Schedule still reads 15 % and that the return form is
the current version (the Commission has introduced a return per tax; the VAT return read
here dates from January 2023).

**Language.** The chart, the taxes and the journals are in English. Seychellois Creole and
French, the other official languages, are not carried.

## Sources

| For | Text | Where |
|---|---|---|
| Rate 15 %, exempt supplies, zero-rated supplies, threshold in force in 2014 | Value Added Tax (Amendment of Schedules) Regulations 2014 (S.I. 4 of 2014) | wto.org (Gazette copy) |
| Return: lines, columns, instructions | Value Added Tax Return | src.gov.sc |
| Due dates 21st and 23rd | Revenue Law (Amendment) Act 2023, sections 3 and 20 | src.gov.sc |
| Threshold SCR 2,000,000 | SRC guidance on S.I. 97 of 2024 | src.gov.sc |
| Zero-rated, exempt, input tax in plain words | SRC VAT brochure | src.gov.sc |
| Payment | Business Activity Statement | src.gov.sc |
| Statements | IAS 1 (no Seychelles text prescribing a layout was found) | ifrs.org |

## What the pack says

1. **One rate: 15 %** (`SC-S-15`, Third Schedule). The sale of a capital asset has its own
   code (`SC-S-15-CAP`, line 1.3) because the form counts it apart.
2. **Zero-rated** (Second Schedule): exports and the services to a person outside Seychelles
   (`SC-S-ZR-EXP`, line 1.1), and the other zero-rated supplies — animal feed, duty free
   shops, port services (`SC-S-ZR`, line 1.2). One code carries each list; which item applies
   is the preparer's judgement.
3. **Exempt** (Part II of the First Schedule, `SC-S-EX`, line 2): financial services of banks
   and bureaux de change, education, certain insurance premiums, hospital and medical
   services, fresh bread, public utilities, residential letting, the transfer of immovable
   property, and others. The exempt supply gives no right to deduct.
4. **Input tax as the form splits it**: imported goods (line 5.1), goods and services bought
   locally (5.2), capital goods (5.3); the purchases on which the credit is not allowed (line
   6, value only; `SC-P-15-NC` adds the VAT to the cost). Imported VAT sits on `2125` until
   paid.
5. **The return** (`SC-VAT`): monthly, by the 23rd through the Tax Portal (the 21st in
   person), with the total output tax (line 4), the input tax credit (line 9) and one signed
   figure for lines 10 and 11.
6. **The chart** is original (the texts read prescribe none): four digits, grouped over the
   ranges of the statements, with the accounts a Seychelles company keeps — INMBT withheld,
   social security, the Tourism Marketing Tax and PAYG withholding payable (the taxes the
   Business Activity Statement lists).
7. **The statements**: a statement of financial position and a statement of profit or loss
   with expenses by nature, in the IAS 1 manner.

## What the pack does not do — read before relying on it

1. **The Act is not cited.** See above. The rate and the Schedules come from the 2014
   regulation, the form and the Commission's pages.
2. **Adjustments (lines 3 and 7), the credit carried forward (line 8) and the refund claim**
   are declared and empty.
3. **No reverse charge** on services bought from abroad: no text read says how it works.
4. **Registration and quarterly filing.** A voluntary registrant files and pays quarterly
   (Business Activity Statement); the pack models the monthly filer only. The registration
   threshold is SCR 2,000,000 on the Commission's notice and was SCR 3,000,000 in the 2014
   text; the pack does not test it.
5. **Input tax apportionment** of a taxpayer making taxable and exempt supplies is not
   modelled.
6. **The other taxes of the Business Activity Statement** (INMBT, PAYG, excise, Tourism
   Marketing Tax) have accounts and no tax code.
7. **No e-invoicing** was found in the texts read; `obligation` is `none` for want of a text.
8. **Corporate income tax** is not modelled.

An accountant in Seychelles should check this pack against the Act and the Commission's
current forms before a first return.
