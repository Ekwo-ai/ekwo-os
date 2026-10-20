# Kyrgyz Republic

Everything Ekwo carries for Kyrgyzstan is data: a chart of accounts after the
Government's chart for business entities, the value added tax at 12 % and 0 %
with its exemptions, a monthly VAT return, and a balance sheet and an income
statement. The format is in [`docs/packs.md`](../../docs/packs.md); this file
says where each line comes from and what the pack does not do, so that a
Kyrgyz accountant can argue with one sentence rather than with the whole.

**Status: `community`.** No bookkeeper or auditor has read this pack. The
figures are recomputed from a year of books by `tests/golden.test.ts`, which
proves the pack agrees with itself and not that it is right in law.

**Language.** The pack is written in Russian (`defaults.language: "ru"`):
Russian is an official language of the Republic beside Kyrgyz, and the texts
this pack was checked against — the Tax Code and the Government resolution —
were read in their Russian edition. Names of accounts, taxes, boxes and
statement lines are Russian; every `legal_reference` quotes the Russian text.
`i18n/en.json` is a working translation. There is **no `ky` translation yet**:
a Kyrgyz-speaking reviewer is welcome to add one.

## Sources

| For | Text | Where |
|---|---|---|
| VAT rates, zero rate, exemptions, tax period, deadline, credit, refund, invoice | Tax Code of 18 January 2022, No. 3 (edition of 6 August 2026), articles 178, 252–330 | cbd.minjust.gov.kg (the official database renders in JavaScript; the text was read in a legal-database copy of the same edition) |
| Chart of accounts | Government resolution No. 231 of 7 October 2010 and its Instruction on the chart | prg.kz (copy), see below |
| Statements | IFRS Accounting Standards | ifrs.org |
| Filing | State Tax Service | sti.gov.kg |

## What the pack says

- **VAT 12 %** (article 254(1)), code `KG-S-12` for sales, `KG-P-12` for purchases.
- **VAT 0 %** (article 254(2)): export of goods (article 303, `KG-S-ZERO-EXPORT`)
  and international transport (article 304, `KG-S-ZERO-TRANSPORT`). Articles 302,
  305 and 306 are not coded.
- **Exempt supplies** (article 264 refers to articles 265–296): two are coded as
  examples, books and periodicals in the state language (article 276,
  `KG-S-EXEMPT-BOOKS`) and housing and land (article 265, `KG-S-EXEMPT-REALESTATE`).
  The other exemptions are not coded; add the one a case needs, with its article.
- **Services from a non-resident** (`KG-P-12-NR`): the place of supply is
  Kyrgyzstan for the services of article 263(4); the buyer, as tax agent, pays the
  VAT and credits it only once paid, on an invoice issued to itself (article
  315(3)(4)). The tax is posted to `3433` and the credit waits on `1543`; moving
  it to `1541` and into the `INPUT` box in the month of payment is a manual entry.
- **Return** `KG-VAT`: monthly (article 313), due on the 25th of the following
  month (article 319). Taxpayers served by the specialised unit of the tax
  service file by the last day of that month: the format holds one day, so the
  25th is carried and this exception is only written down.
- **Tax point**: delivery date (article 261(1)).

## What the pack does not do — read before relying on it

1. **The boxes are not the lines of the official form.** The text of the act that
   approves the VAT return, and its line numbers, could not be read from any open
   source. The boxes are named after the articles of the Code (`TAXABLE`, `ZERO`,
   `EXEMPT`, `TURNOVER`, `INPUT`, `CREDIT`, `PAYABLE`, `EXCESS`) and compute what
   article 314(2) computes. Carrying them to the form's lines is for the accountant.
2. **The chart is checked, not transcribed.** The Instruction to resolution No. 231
   is behind a login in the legal databases found; the codes were taken from a
   published course on that chart (groups 1000–9000; for example 1110 cash,
   1210 bank in national currency, 1410 receivables, 1540 VAT recoverable,
   3110 payables, 3430 VAT payable, 5300 retained earnings, 6110 revenue, 7100–7200
   cost of sales). The pack's **own** sub-accounts, absent from that material, are:
   `1541`, `1542`, `1543`, `3431`, `3432`, `3433` (separate posting and settlement
   accounts for VAT, which `tests/filing_golden.test.ts` requires), `3699`
   (suspense), `6290` (exchange gains), `7610` (exchange losses), `7690`
   (rounding) and `9610`. The groups below the first level (for example 2110–2160,
   7510–7590, 8110–8490) are this pack's grouping, to be confirmed against the
   Instruction by a Kyrgyz accountant.
3. **Statements are assembled, not an official form.** The balance sheet and the
   income statement are built from the sections of the chart and IFRS (IAS 1). The
   approved forms and the small-business rules were not read.
4. **Sales tax is not modelled.** Kyrgyzstan also levies a sales tax
   (article 308 excludes it from the VAT base) under special regimes; this pack
   has no code for it, and `3450` is only a placeholder account.
5. **Import VAT, EAEU supplies, advance payments and VAT-registration regimes** are
   not modelled; the core's tax point cannot express an advance as a third trigger.
6. **Electronic invoices.** Article 178 requires the invoice as an electronic
   document in the tax service's invoice system (ESF), with a paper invoice only in
   cases set by the Cabinet of Ministers. Issuing into that state system is a
   clearance channel the core does not have; `einvoicing.profile` is empty and the
   invoice number the system assigns is not read back.
7. **No bank statement format** is declared: none of the formats the core reads was
   confirmed for Kyrgyz banks.
8. **The registration threshold and the special regimes** (single tax, patent) are
   not described.

## To be read by a Kyrgyz accountant

Everything in 1–5 above, the exemption list, the tax agent mechanism for
non-residents, and the account groupings.
