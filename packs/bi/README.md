# Burundi

Everything Ekwo carries for Burundi is data: a chart of accounts for commercial
enterprises, the value added tax (TVA) at 18 %, an intermediate rate of 10 % and a zero
rate, six exemptions coded, a monthly TVA return, and a balance sheet and an income
statement. The format is in [`docs/packs.md`](../../docs/packs.md); this file says where
each line comes from and what the pack does not do, so that a Burundian accountant can
argue with one sentence rather than with the whole.

**Status: `community`.** No accountant has reviewed this pack. The figures are recomputed
from five months of books by `tests/golden.test.ts` — the expected figures were worked out
by hand first — which proves the pack agrees with itself and not that it is right in law.

**French only.** The chart, the taxes, the boxes and the statements are written in French,
`defaults.language: "fr"`, the language of the law and of the national accounting plan.
Kirundi is not offered: no official Kirundi wording of the return could be read. The
currency is the Burundi franc (BIF), with no decimal.

## Sources

Four entries in `certification.sources`:

| Key | Text | Where |
|---|---|---|
| `vat-law` | Loi n°1/10 du 16 novembre 2020 modifying the loi n°1/12 du 29 juillet 2013, itself a revision of the loi n°1/02 du 17 février 2009 instituting the TVA. The file is the amended law in full, read page by page. | `obr.bi`, Lois et règlements |
| `tax-procedures-guide` | The OBR taxpayer's guide, which recalls the loi n°1/18 du 6 septembre 2013 on tax procedures | `obr.bi` |
| `ebms` | The page of the electronic invoicing system EBMS | `obr.bi` |
| `obr-portal` | The tax administration, and its online filing service Umutangakori | `obr.bi` |

Every tax and every box carries, in its `legal_reference`, the article it rests on.

## Taxes

| Code | Rate | What |
|---|---|---|
| `BI-S-18` | 18 % | Standard rate on sales (article 19) |
| `BI-S-10` | 10 % | Intermediate rate: agricultural inputs, agricultural products processed in Burundi, listed foodstuffs, hotel establishments (article 19) |
| `BI-S-ZERO-EXPORT` | 0 % | Exports and similar operations (article 19) |
| `BI-S-ZERO-TRANSPORT` | 0 % | International transport (article 19) |
| `BI-S-EXEMPT-AGRI` | exempt | Unprocessed agricultural products sold by their producers (article 10 k) |
| `BI-S-EXEMPT-HEALTH` | exempt | Health, life and sickness insurance, medical care (article 10 a, g) |
| `BI-S-EXEMPT-EDUCATION` | exempt | School and university education (article 10 h) |
| `BI-S-EXEMPT-HOUSING` | exempt | Dwellings, unbuilt land, residential and some other leases (article 10 d, e, f) |
| `BI-S-EXEMPT-FINANCE` | exempt | Credit, exchange, securities, banking investments (article 10 b) |
| `BI-S-EXEMPT-TRANSPORT` | exempt | Road transport of persons (article 10 n) |
| `BI-P-18`, `BI-P-10` | 18 %, 10 % | Deductible purchases (articles 20 to 22) |
| `BI-P-18-NODEDUCT` | 18 % | Purchase whose tax is not deductible: lodging, reception, catering, travel (article 21 b); the tax goes to account 8315 |
| `BI-P-18-NR` | 18 % | Service of a non-resident without a representative: the buyer withholds and pays the tax (article 54), posted to a waiting account until paid (article 22 c) |

Zero-rated is not exempt: a zero-rated supplier keeps its deduction, an exempt one does
not (article 21 a). The pack does not apportion a mixed taxpayer (article 23 leaves the
prorata to a ministerial ordinance).

## The return

Article 52 fixes the tax period at one month, and the return at the fifteenth day after
the period; article 54 has the net tax paid when the return is filed. Article 24 carries a
credit forward to the next return; three consecutive credits allow a refund claim in the
following month (article 28: refund within 90 days). The boxes are named after the
operations of the law (`TAX18`, `TAX10`, `ZERO`, `EXEMPT`, `TURNOVER`, `INPUT`, `CREDIT`,
`PAYABLE`, `EXCESS`); the official form was not found in an open source, so they are not
the lines of the form. The return is filed online on the OBR's Umutangakori portal.

## The chart of accounts

Article 51 of the law requires books kept as the Burundian national accounting plan (PCN)
and the Code de commerce provide. The PCN (created by decree 100/319 of 1974 on the
model of the OCAM plan, revised in 2012) could not be read in an open source. The 150
accounts are therefore this pack's own grouping, four digits, built so that each range
reaches one line of the statements: 1 current assets, 2 non-current assets, 3 current
liabilities, 4 non-current liabilities, 5 equity, 6 income, 7 to 9 expenses. A Burundian
accountant must compare it with the PCN before a company keeps its books on it. Only
trade receivables, trade payables and the two TVA settlement accounts are reconcilable.

## Electronic invoicing

Article 47 obliges every taxpayer to use an approved electronic billing machine; the OBR
runs the EBMS system, to which own software is interfaced, and article 244 of the 2025-2026
finance law is cited on its page. That obliges invoicing through a device linked to the
administration; it is not a structured exchange between businesses. `einvoicing.profile`
is null and `obligation` is `none`; the link to EBMS is not modelled.

## What this pack does not say yet, and why

- **The ministerial ordinances.** The law leaves to ordinances the registration
  threshold (articles 37 and 41), the list of foodstuffs at 10 %, the operations
  assimilated to exports, the limits of the health and education exemptions, the prorata
  and the refund threshold. None was read; the pack checks no threshold. Sources found
  while writing disagree on the current threshold (BIF 100 million in older material,
  BIF 25 million in 2026 commentary): the figure is a gap, not a statement.
- **The time of supply of services.** Tax on services falls due when the price is
  collected (article 12 b), or on invoicing by option with the administration's agreement
  (article 12 e); the pack posts on the invoice date, and `tax_point` is the delivery date.
- **Import TVA at customs** (article 54): paid at clearance, not modelled.
- **The return form** and its box numbers.
- **The PCN** and the official statement forms (see above).
- **Clearance by EBMS**, and the later finance laws (2025-2026 and after) that may have
  changed a rate or a threshold: the text read is the one of 2020.
- **Income tax, the fixed-rate regimes of small taxpayers, excise and other taxes.**
- **Kirundi** wording.

## For a Burundian accountant to read first

The ordinances above, the registration threshold in force, the chart against the PCN,
the allocation of a hotel's supplies between 10 % and 18 %, and the deadline in practice
on the Umutangakori portal.
