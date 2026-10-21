# Djibouti

Everything Ekwo carries for Djibouti is data: a chart of accounts for commercial
enterprises, the value added tax (TVA) at 10 % and a zero rate, five exemptions coded, a
monthly TVA return, and a balance sheet and an income statement. The format is in
[`docs/packs.md`](../../docs/packs.md); this file says where each line comes from and what
the pack does not do, so that a Djiboutian accountant can argue with one sentence rather
than with the whole.

**Status: `community`.** No accountant has reviewed this pack. The figures are recomputed
from five months of books by `tests/golden.test.ts` — the expected figures were worked out
by hand first — which proves the pack agrees with itself and not that it is right in law.

**French only.** The chart, the taxes, the boxes and the statements are written in French,
`defaults.language: "fr"`, the language of the law. Arabic, the other official language, is
not offered: no Arabic wording of the return could be read. The currency is the Djibouti
franc (DJF), with no decimal.

**The rate is 10 %, not 7 %.** The VAT law of 2008 (loi n°43/AN/08/6ème L, article 19) set
the standard rate at 7 %, and the 2008 guide and its form still say 7 %. The Code général
des impôts 2016 (article 187) says 10 %, and marks the change as coming from the finance
law of 2015, which was not read. The pack is written from the Code.

## Sources

Four entries in `certification.sources`:

| Key | Text | Where |
|---|---|---|
| `cgi` | Code général des impôts 2016, the VAT chapter (articles 171 to 211) read in full | `budget.gouv.dj` |
| `vat-law` | Loi n°43/AN/08/6ème L creating the TVA (original text, rate 7 %) | `journalofficiel.dj` |
| `vat-guide` | The Ministry's TVA guide, with the monthly return and its lines 1 to 22 (2008) | `ministere-finances.dj` |
| `mof-portal` | The Ministry of Finance; no online filing service was found | `ministere-finances.dj` |

Every tax and every box carries, in its `legal_reference`, the article it rests on.

## Taxes

| Code | Rate | What |
|---|---|---|
| `DJ-S-10` | 10 % | Standard rate on sales (article 187, 1) |
| `DJ-S-ZERO-EXPORT` | 0 % | Exports and services linked to exports or transit (article 187, 2 a, b) |
| `DJ-S-ZERO-TRANSPORT` | 0 % | International passenger transport, ship and aircraft supply (articles 180 a, 187, 2 c) |
| `DJ-S-EXEMPT-AGRI` | exempt | Unprocessed produce sold directly by farmers, herders, fishers (article 176, 1) |
| `DJ-S-EXEMPT-BANK` | exempt | Banking and insurance operations (article 176, 2) |
| `DJ-S-EXEMPT-HOUSING` | exempt | Bare land and premises, dwellings let to the tenant (article 176, 6, 7) |
| `DJ-S-EXEMPT-NONPROFIT` | exempt | Disinterested non-profit bodies, outside competitive sectors (article 176, 4) |
| `DJ-S-EXEMPT-PRESS` | exempt | Newspapers and periodicals, advertising excluded (article 176, 3) |
| `DJ-P-10` | 10 % | Deductible purchases (articles 188, 189) |
| `DJ-P-10-NODEDUCT` | 10 % | Purchase whose tax is not deductible: lodging, catering, reception, passenger vehicles (articles 190, 191); the tax goes to account 8315 |

Zero-rated is not exempt: a zero-rated supplier keeps its deduction, an exempt one does
not (article 188). The registration threshold is DJF 50 million of annual turnover, with
lawyers, notaries, consultants and accountants registered whatever their turnover
(article 174); the pack checks no threshold.

## The return

Article 206 makes the TVA a monthly declared tax, paid with the return, with a nil return
when nothing was taxable; article 207 sets the deadline at the 20th of the month after, or
the next working day. Amounts are rounded to the nearest franc. The form (2008 guide) has
22 lines; the pack carries lines 5, 6, 7, 8, 10, 16, 19 and 20 as the boxes `TAX10`,
`ZERO`, `EXEMPT`, `TURNOVER`, `INPUT`, `CREDIT`, `PAYABLE`, `EXCESS`. The current form was
not found online, so the numbering is the 2008 one.

## The chart of accounts

No national chart of accounts could be read in an open source. The 150 accounts are this
pack's own grouping, four digits, built so that each range reaches one line of the
statements: 1 current assets, 2 non-current assets, 3 current liabilities, 4 non-current
liabilities, 5 equity, 6 income, 7 to 9 expenses. A Djiboutian accountant must compare it
with local practice before a company keeps its books on it. Only trade receivables, trade
payables and the two TVA settlement accounts are reconcilable.

## Electronic invoicing

None found: article 208 lists the mentions of the invoice (taxpayer numbers of both
parties, series number, quantities, amounts excluding tax, rate and amount of TVA, total).
`einvoicing.profile` is null and `obligation` is `none`.

## What this pack does not say yet, and why

- **The finance laws after 2016.** The text read is the Code of 2016; the rate and the
  exemptions may have moved since. The finance law of 2015, which raised the rate, was not read.
- **The hotel regime.** Hotel services outside the TVA fall under a separate tax on
  services (TPS, articles 212 to 214); it is not coded.
- **Zero rate during construction** (article 187, 2 f: new hotel, property and processing
  investments) needs a commitment and a quote visaed by the administration; not coded.
- **Services from non-residents**: no reverse-charge rule was found in the text read.
- **The time of supply of services.** Tax on services falls due when the price is
  collected (article 183) or on debit by authorisation; the pack posts on the invoice date.
- **Lines 2 to 4, 9, 11 to 15, 17, 18, 21, 22 of the form**, the carry-forward of a credit and
  refunds (articles 196 to 203).
- **Import TVA at customs**, the tax on electricity above DJF 50 000 per bill, mixed
  taxpayers' prorata (article 192) and the margin scheme.
- **Free zones**, the investment code, income tax, patente and other taxes.
- **Arabic** wording.

## For a Djiboutian accountant to read first

The rate and exemptions in force after 2016, the form currently filed, the chart against
local practice, the treatment of hotels (TVA or TPS), and whether declarations are filed on paper or online.
