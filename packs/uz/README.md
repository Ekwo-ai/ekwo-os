# Uzbekistan

Everything Ekwo carries for Uzbekistan is data: the chart of accounts of the
national accounting standard No. 21 as it stands since 1 January 2025, the value
added tax at 12 % and 0 % with a few exemptions, a monthly VAT return, and a
balance sheet and an income statement. The format is in
[`docs/packs.md`](../../docs/packs.md); this file says where each line comes
from and what the pack does not do, so that an Uzbek accountant can argue with one
sentence rather than with the whole.

**Status: `community`.** No bookkeeper or auditor has read this pack. The
figures are recomputed from a year of books by `tests/golden.test.ts`, which
proves the pack agrees with itself and not that it is right in law.

**Language.** The pack is written in Uzbek (`defaults.language: "uz"`), in the
Cyrillic script, because the texts it was checked against were read in that
edition: the chart of accounts as registered by the Ministry of Justice and the
Tax Code on Lex.uz. The Latin script is the one the Republic uses in law today;
a Latin edition of every label is welcome, as is a Russian one. `i18n/en.json` is
a working translation. Names of accounts, taxes, boxes and statement lines are
Uzbek; every `legal_reference` quotes the Uzbek text.

## Sources

| For | Text | Where |
|---|---|---|
| VAT: payers, exemptions, base, rate, period, zero rate, credit, return and payment | Tax Code of 30 December 2019, articles 237–274 (section VIII, VAT), and article 47 (invoice); edition carrying the amendments marked for 12 December 2026 | Lex.uz, read in the Russian-interface page whose text is Uzbek |
| Chart of accounts | National accounting standard No. 21 and its instruction, approved by order No. 191 of the Minister of Economy and Finance of 14 November 2024, registered by the Ministry of Justice as No. 3593 on 27 December 2024, in force from 1 January 2025 | the registered text, as published as a PDF by buxgalter.uz |
| Statements | National accounting standard No. 1, order No. 130 of 14 June 2024, registered No. 3544 | Lex.uz (the page carries the order; the annex with the text is in Uzbek and was not read) |
| Filing | State Tax Committee | soliq.uz |

## What the pack says

- **VAT 12 %** (article 258, first part, from 1 January 2023): `UZ-S-12` for
  sales, `UZ-P-12` for purchases.
- **VAT 0 %** (article 258, second part, and chapter 36): export of goods
  (article 260, `UZ-S-ZERO-EXPORT`) and services tied to international transport
  (article 263, `UZ-S-ZERO-TRANSPORT`). Processing services (article 262) and the
  cases of article 264 are not coded.
- **Exempt supplies** (chapter 33, articles 243–246): two are coded as examples,
  education services (article 243, item 10, `UZ-S-EXEMPT-EDU`) and banking and
  other financial services (articles 243 item 27 and 244, `UZ-S-EXEMPT-FINANCIAL`).
  The rest of the list is not coded; add the one a case needs, with its article.
  A payer with both taxable and exempt supplies keeps separate records
  (article 268) and credits only part of its input tax; **that proration is not
  modelled**.
- **Services from a non-resident** (`UZ-P-12-NR`): the buyer, as tax agent,
  accrues the tax (article 255) and credits it once paid (article 266, item 4).
  The tax is posted to `6413` and the credit waits on `4413`; moving it to `4411`
  and into the `INPUT` box in the month of payment is a manual entry.
- **Return** `UZ-VAT`: monthly (article 259), due on the 20th of the following
  month, with the payment (article 273).
- **Tax point**: delivery date. Article 242 takes the earlier of the invoice date
  and the shipment date for goods, and the date of the document confirming the
  service for services; the format holds one trigger, so the earlier-of rule is
  only written down.
- **Invoice**: article 47 requires the invoice, as a rule, as an electronic
  document in the information system of electronic invoices.

## What the pack does not do — read before relying on it

1. **The boxes are not the lines of the official form.** The act that approves the
   VAT return and its line numbers was not read. The boxes are named after the
   articles of the Code (`TAXABLE`, `ZERO`, `EXEMPT`, `TURNOVER`, `INPUT`,
   `CREDIT`, `PAYABLE`, `EXCESS`) and compute what article 272 computes. Carrying
   them to the form is for the accountant. Article 273 also puts the purchase
   and sales registers into the return; they are not produced.
2. **The chart is the official one, with six accounts of the pack's own.** The
   accounts of chapters 1 to 4 (321 accounts, 0100 to 9910) are copied from the
   registered text. Chapter 5 (off-balance accounts) is left out. The instruction
   keeps input VAT in `4410` and the debt to the budget in `6410`, both "by type
   of tax"; the pack gives that analytic accounting its own codes: `4411` input
   VAT, `4412` settlement receivable, `4413` input VAT on non-resident services
   awaiting payment, `6411` output VAT, `6412` settlement payable, `6413` VAT
   accrued as tax agent. The settlement accounts are separate from the posting
   accounts because `tests/filing_golden.test.ts` requires it.
   `6990` stands for the suspense role and `9430` for rounding.
3. **Statements are assembled, not an official form.** The balance sheet and the
   income statement group the chart by its chapters and sections; the annex of
   standard No. 1 with the approved forms was not read. That standard is itself
   replaced from 1 January 2027 by the national financial reporting standard
   No. 1 (order No. 392 of 23 July 2026, registered No. 3923); the pack still
   follows the standard in force when it was written.
4. **Import VAT** (collected by customs, article 273 third part), the **VAT
   registration regime** of sole traders above one billion sum of turnover
   (article 237), the **turnover tax** of small taxpayers and the **tax on
   non-resident electronic services** (article 279) are not modelled.
5. **Fixed amounts and later changes.** The Tax Code carries amendments marked for
   entry into force on 12 December 2026 (for instance in article 239); they were
   not read and may change a rule above.
6. **Electronic invoices.** The state system is a clearance channel the core does
   not have; `einvoicing.profile` is empty and the number the system assigns is
   not read back.
7. **No bank statement format** is declared: none of the formats the core reads
   was confirmed for Uzbek banks.

## To be read by an Uzbek accountant

Everything in 1–5 above, the exemption list, the tax agent mechanism for
non-residents, and the choice of accounts for the roles (`4010`, `6010`, `5110`,
`5010`, `9020`, `9140`, `8720`).
