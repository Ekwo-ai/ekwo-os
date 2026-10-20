# Suriname

Everything Suriname adds to Ekwo, as data: a chart of accounts, the journals,
the value added tax (BTW, *belasting over de toegevoegde waarde*) rates and
where each one posts, the rubrics of the monthly BTW return, a balance sheet and
an income statement, and the way a document is numbered. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on.

**Status: `community`.** Nobody who files a Surinamese BTW return has reviewed
it against the law they apply. The figures are replayed against two months of
books by `tests/golden.test.ts`, which proves the pack is coherent and proves
nothing about whether it is right.

## Language

The files of the pack are written in **Dutch**, the language of the law, of the
return and of the Belastingdienst's pages, and `defaults.language` is `nl`. The
Wet BTW asks, in article 30, that the administration be kept in the Dutch
language. `i18n/en.json` is the English translation, declared in
`languages`; it has no official standing (see `i18n/README.md`).

## Sources

Every rate, box and statement carries its own `legal_reference` and the key of
the text it rests on. The register in `pack.json` holds nine texts, all opened
on 20 October 2026.

| What | Text |
|---|---|
| The law: scope, rate of 10 %, exemptions, time of supply, return, deduction, refund, threshold, invoices, ten-year retention | Wet Belasting over de Toegevoegde Waarde 2022, S.B. 2022 no. 121, current text (`sr-wet-btw`), and the law as the National Assembly publishes it (`sr-dna-wet`) |
| The rates of 0, 5 and 25 %, and Annexes 1 to 4 (zero-rated, exempt, 25 %, 5 %), in force on 1 January 2023 | Law of 30 December 2022, S.B. 2022 no. 148 (`sr-sb-2022-148`) |
| The boxes of the return, 1a to 4j, and the notes for filling them | Ministerial decision S.B. 2023 no. 31, the model return (`sr-model-aangifte`) |
| Whole amounts rounded down, a nil return, "on time" means before the 16th, corrections until the 15th | Belastingdienst, BTW-aangifte page (`sr-btw-aangifte`) |
| Registration threshold of SRD 1,000,000, invoice particulars | Belastingdienst brochure of 28 April 2025 (`sr-btw-brochure`) |
| The portal the return is filed on | Online Portaal (`sr-portaal`) |
| No statutory accounting framework; the presentation of the statements | IFRS Foundation profile of Suriname, 2016 (`sr-ifrs-profile`); IFRS for SMEs (`iasb-ifrs-sme`) |

## What the pack carries

- **Eighteen tax codes.** Sales: `SR-S-10` standard (10 %), `SR-S-10-INC` the
  same with the tax in the price (article 10 forbids a price without the tax
  to a consumer), `SR-S-05` fuel and international health insurance (5 %),
  `SR-S-25` large cars and motorcycles (25 %), `SR-S-00` zero-rated at home
  (Annex 1), `SR-S-EXP-G` export of goods, `SR-S-EXP-D` services to customers
  outside Suriname, `SR-S-EX` exempt (Annex 2). Purchases: `SR-P-10`,
  `SR-P-05`, `SR-P-25` deductible; `SR-P-10-ND` and `SR-P-25-ND` not
  deductible (article 14: food and drink, gifts, benefits in kind, passenger
  cars), whose tax is a cost; `SR-P-IMP-10`, `-05`, `-25` tax paid at customs;
  `SR-P-RC-10` services from a supplier outside Suriname (article 11,
  paragraph 2: the buyer declares and deducts the tax); `SR-P-EX` no BTW.
- **The return, `SR-BTW-AANGIFTE`**: the rubrics of the model return, monthly.
  1a, 1c, 1d, 2a, 2b, 3d, 4b, 4c and 4d are filled by the postings; 4a, 4f and
  4g are totals; 4j (to pay) and 4jTerug (to receive back) are the two outcomes
  of the form's 4j. Due before the 16th day of the following month, so the
  rule gives the 15th. In whole SRD.
- **A chart of 118 accounts**, four digits; the return is settled on `2100`
  (payable) or `1172` (refundable), apart from the accounts the tax posts to
  (`2101` to `2103` due, `1170`, `1171` and `1173` recoverable). Not a legal
  chart: none was found.
- **A balance sheet and an income statement** in the manner of IFRS for SMEs.
  No framework is compulsory in Suriname, so the layout is this pack's choice.
- **Currency**: the Surinamese dollar (`SRD`, two decimals).

## What the pack does not say yet

- **Annex 1 and Annex 2 are codes, not lists.** Which supplies are zero-rated or
  exempt is read from the annexes by the user, with their accountant; the pack
  carries one code for each case and does not reproduce the annexes. Annex 3
  (25 %) and Annex 4 (5 %) likewise. The form asks for a specification with
  rubric 1b, which the pack cannot produce.
- **Rubrics not filled by any code**: 1e (private use and withdrawals), 3a to 3c
  (reverse charge on import under a permit, article 11, paragraph 3, in force
  from 1 January 2024), 4e (turnover tax on stock held at the end of 2022), 4h
  and 4i (corrections of previous periods). The boxes of 1e, 3a to 3c and 4e
  exist and add into the totals, but nothing posts into them; 4h and 4i are not
  carried.
- **Rounding down.** The portal takes whole amounts and the Belastingdienst
  says to round down. The pack rounds to the unit; the direction cannot be
  expressed, so a user may differ by one dollar per rubric from what the portal
  expects.
- **Services to customers abroad** (`SR-S-EXP-D`) are coded as zero-rated under
  article 4, paragraph 2, points c, d and e, for the cases those points list.
  Whether another service is outside Suriname under the place-of-supply rules
  of article 9 was not worked through: that decision is the user's.
- **Deduction for mixed use** (article 15: apportionment between taxable and
  exempt supplies, ten-year and five-year adjustments on fixed assets) is not
  modelled; the pack treats all the tax on a business purchase as deductible,
  except the cases of article 14 that carry their own code.
- **The threshold.** A business with SRD 1,000,000 or less of taxable turnover
  in a calendar year is exempt from the obligations of the law (article 21) and
  cannot deduct. The pack does not check it; such a business may still ask to
  register.
- **Due date.** No text read says whether a 15th on a weekend or a public
  holiday moves; the rule does not move it. The returns of a month in which
  the portal is unavailable are the Belastingdienst's to extend by notice,
  which a rule cannot hold.
- **Interest and penalties** on late filing or payment (article 13, paragraph 5, and
  the penalty provisions) are not modelled.
- **Cash registers.** Sales to people who are not businesses may be recorded on
  a cash register with a consecutively numbered receipt showing the rate
  (article 27, paragraph 7, and article 28); Ekwo issues invoices, not
  receipts.
- **E-invoicing**: no obligation found (`obligation: none`); no Peppol
  authority for Suriname was looked for.
- **Other taxes**: income tax, wage tax, pension and social contributions,
  customs duty and excise are ordinary payable and expense accounts. No code,
  no return.
- **The Wetboek van Koophandel and the income tax law were not opened.** No
  legal chart of accounts or format for annual accounts is claimed.
