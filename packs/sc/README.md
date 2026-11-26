# Seychelles

The pack of Seychelles. Its sources, its taxes and its declaration are in
[`pack.json`](pack.json), [`taxes.json`](taxes.json) and
[`tax_report.json`](tax_report.json); its page on
[ekwo.ai](https://ekwo.ai/countries/sc/) prints them.

## What the core could not say

**One signed figure for lines 10 and 11.** The Seychelles Revenue Commission's VAT
return prints the VAT due in box 10A and the VAT credit in box 11B, only one of
the two filled. The pack carries one total, box `10`, which is output tax minus
input tax credit: positive is line 10, negative is line 11. The refund claim and
the credit carried to the next period (line 8) are not postings of the format.

**Two dates for the same return.** The Revenue Law (Amendment) Act 2023 gives the
21st of the month for a return furnished in person and the 23rd through the Tax
Portal, which a large business must use. The format holds one day; the pack keeps
the 23rd.

**A threshold that moved.** The Schedules of 2014 set the registration threshold
at SCR 3,000,000; the Commission's notice on S.I. 97 of 2024 gives SCR 2,000,000.
The pack does not model registration; the README says which text was read.

**No reverse charge, no adjustments.** The text of the Act itself was not found, only
the Schedules, the form and the Commission's brochures, so the tax assessed on services
bought from abroad, the input tax apportionment of a mixed taxpayer and the adjustments
of lines 3 and 7 are left to the preparer.
