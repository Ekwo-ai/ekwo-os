# Guernsey

Everything Guernsey adds to Ekwo, as data: a British-style chart of accounts, the
journals, the two "not subject" tax codes that carry every sale and purchase a
Guernsey business books, and the balance sheet and profit and loss account in
the layout of FRS 102 Section 1A (small entities). The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Guernsey accountant can disagree
with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who practises in Guernsey has reviewed it. The
figures are replayed against a year of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

**No GST or VAT today.** Guernsey levies no value added tax, goods and services tax or general sales
tax. **The law is about to move**: on 2 October 2026 the States of Deliberation
voted (22 to 17, one abstention) for the principle of a GST of 3 % from 2029,
with a pathway to 4 % and then 5 % subject to an independent fiscal review
(Guernsey Press, 2 October 2026). No GST law is enacted, no rate is
promulgated and no start date is fixed in law, so this pack creates **no GST
code**. The vote is the pack's next expected change; see
[`docs/international.md`](../../docs/international.md#what-comes-next).

## Sources

`pack.json` registers ten texts:

| What | Text | Note |
|---|---|---|
| Accounting records, six-year retention, true and fair accounts, declared GAAP | Companies (Guernsey) Law, 2008 (guernseylegalresources.gg) | Cited from a law-firm summary (Walkers); section numbers are not cited and the Law itself should be checked. |
| Tax collected; company rates 0/10/20 %; online company return | Revenue Service pages (gov.gg/RevenueService/Companies, gov.gg/tax) | |
| No VAT/GST today; customs and Document Duty; social security rates | PwC worldwide tax summaries | |
| Domestic top-up tax from 1 January 2025 | Legal 500 | |
| The 2 October 2026 GST vote | Guernsey Press | The official resolution is on `statesvoting-records.gov.gg`; no gov.gg page on the GST exists yet. |
| FRS 102 Section 1A | Financial Reporting Council | Confirms Section 1A exists; the standard's text is not transcribed. |
| Filing portal | `my.gov.gg` | Requires a login; the portal the Revenue Service pages point to. |

## Chart of accounts

Guernsey prescribes none. The chart is the British one (four digits, fixed
assets first, then current assets, creditors, capital, income, cost of sales,
overheads) with every value-added-tax, PAYE/CIS and UK-specific account removed
and the tax accounts renamed for income tax and social security: 182
accounts, only trade debtors (`1100`) and trade creditors (`2100`)
reconcilable. There is no tax-clearing account.

## Taxes

Two codes, `GG-S-NA` and `GG-P-NA`, both `not_subject`, `kind: other`, rate 0,
`vat_category: O`, posting the base only. `valid_from` is `2000-01-01`, a
convenience the field needed and not a claim about when the absence began.

## What this pack does not carry

- **Income tax on companies** at 0 % / 10 % / 20 % (Income Tax (Guernsey) Law,
  1975), assessed on the year's profit and filed online at `my.gov.gg`. Account
  `2280` and the `8200` series exist so a company can book it; nothing computes
  it.
- **Pillar Two**: the domestic top-up tax (15 %) for in-scope multinational
  groups, from accounting periods starting on or after 1 January 2025.
- **Social security contributions** (employer and employee, Revenue Service).
- **Customs and excise duty**, and **Document Duty** on real property transfers.
- **Any GST**: none is enacted. When one is, it needs new codes, a return and
  settlement roles, written from the enacted law and not from the vote.
- **E-invoicing**: `obligation: none`; no mandate and no Peppol Authority found.
- `fixed_assets.json`, XBRL fact keys and bank formats.

## Statements

`statements.json` carries a balance sheet and a profit and loss account in the
layout of FRS 102 Section 1A (small entities), itself the Format 1 layout of
the United Kingdom's Companies Act regulations. **Guernsey law does not impose
it**: the Law asks for a true and fair view under declared GAAP (UK GAAP, US
GAAP or IFRS), so the layout is borrowed, and a company declaring IFRS would
present differently. Line `K.IV` carries the year's result not yet closed, so
the balance sheet ties on an open year.

## Documents

Numbering `free`; no payment term and no late-payment interest found (the UK
statute is not shown to extend to Guernsey); `tax_point: invoice_date` is a
convention, not a rule; no mandatory mention is declared, because no text found
imposes one.

## Reviewing this pack

Open an issue titled "Review: Guernsey". Points for a local accountant:

1. The Companies (Guernsey) Law, 2008 sections on records and accounts, which
   this pack cites only from a secondary summary.
2. Whether the Section 1A layout suits the GAAP Guernsey companies actually
   declare.
3. The 2 October 2026 resolution itself: wording, dates, zero-ratings
   (self-build, second-hand goods were reported), and whether a law follows.
4. Whether any Late Payment or invoice-content rule applies in Guernsey.
5. `fiscal_year_default: calendar`, chosen as the common year end.
