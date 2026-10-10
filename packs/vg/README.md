# British Virgin Islands

Everything the British Virgin Islands add to Ekwo, as data: a chart of accounts, the journals, the two "not subject" tax codes that carry every sale and purchase, and the balance sheet and income statement a company fills its annual financial return from. The format is [`docs/packs.md`](../../docs/packs.md); this file says where the content came from, so that a local accountant can disagree with a specific sentence rather than with the whole.

**Status: `community`.** Nobody who practises in the Virgin Islands has reviewed it. The golden scenario replays a year of books and proves the pack is coherent, not that it is right.

**A jurisdiction with no tax on sales.** This pack declares no periodic return: no `tax_report.json`, no `tax_payable` / `tax_receivable` roles, no tax-settlement account. `vat_return.json` in the golden carries the fiscal year with empty `boxes`.

## Sources

The register (`certification.sources`):

| What | Text |
|---|---|
| Taxes administered: payroll tax, stamp duty, self-drive motor vehicle tax, hotel accommodation tax, land and house tax, liquor licence, cheque duty, service charges; no tax on sales | Inland Revenue Department, `gov.vg/inland-revenue-department` |
| "The BVI does not levy VAT or sales tax"; companies generally exempt from income tax; payroll tax 2% / 6% employer, 8% employee, above USD 10,000; social security and NHI; stamp duty; land and house tax; no Pillar Two announcement | Deloitte, *British Virgin Islands Highlights 2025* |
| Financial return: balance sheet and income statement, unaudited, nine months, no mandated framework, exemptions, five-year retention by the registered agent | Maples; Mourant; Vistra (practitioner notes on BVI Business Companies Act s. 98A and the Financial Return Order 2023) |
| Online registration and mandatory e-filing of payroll, self-drive and hotel tax returns from 1 December 2023 | Orbitax; `eregisterfortax.gov.vg` named as the registration portal |
| The statutes | `laws.gov.vg` (statute index) |

The statutes themselves (BVI Business Companies Act 2004, ss. 98 and 98A; the Financial Return Order 2023 and its schedule of lines; the Payroll Taxes Act 2004; the Income Tax Act) and the P6 21-day deadline rest on the Inland Revenue Department page and the summaries above; they should be checked against `laws.gov.vg`. Every `legal_reference` says which source applies.

## No VAT, GST or sales tax

The Inland Revenue Department lists the taxes it administers and none is a tax on sales; Deloitte (2025) states the territory levies no VAT or sales tax. Income tax is legislated but at a zero rate. `VG-S-NA` (sales) and `VG-P-NA` (purchases) are therefore `not_subject`, `kind: other`, rate 0, `vat_category: O`, base posting only. No exemption code or VATEX: the list names articles of an EU directive.

## Chart of accounts

No chart is prescribed. This one is original: 107 accounts, four digits, blocked so each range reaches one line of an IFRS for SMEs balance sheet and income statement. It is inspired by IFRS only in that sense; no framework is imposed. It carries payroll-related liabilities (payroll tax withheld and employer share, social security and NHI) and an income-tax expense account (6470) that stays at nil for a typical BVI company but serves foreign or deferred taxes. Only trade debtors and trade creditors are reconcilable.

## The statements

`VG-FR-BS` and `VG-FR-IS` are laid out in the IFRS for SMEs form and match the contents of the financial return (assets, liabilities, equity; revenue, cost of sales, gross profit, operating expenses, other expenses, income tax expense, net income). BVI Business Companies Act 2004 s. 98A with the Financial Return Order 2023, in force 1 January 2023, has a company that is not exempt give its registered agent an unaudited return within nine months of its year end. Exempt: listed companies, regulated financial entities, companies filing tax returns with financial statements at the Inland Revenue Department, companies in liquidation. The return is not filed with the Registrar or published. The pack does not generate the return's prescribed form, only the two statements it is built from.

## Year end and invoices

`fiscal_year_default` is `calendar` (the default of s. 98A for a company that has not told its registered agent otherwise, per the summaries). `numbering` is `free`; `tax_point: invoice_date` is a **convention, not a rule** (no turnover tax exists to define one); `payment_terms` carry no statutory days or interest (nothing found, which is not proof of absence). No invoice mention is declared: none was found that a text or established usage imposes. `einvoicing.obligation` is `none`: no mandate found and no Peppol Authority seen for the territory.

## Not modelled (outside the pack, no tax code)

- **Payroll tax** (Payroll Taxes Act 2004): employer 2% (Class 1) or 6% (Class 2), employee 8% withheld by the employer, on remuneration above USD 10,000 a year; monthly P6 return, reported as due within 21 days of month end; filed electronically.
- **Social security and National Health Insurance contributions** (employer 4.5% / employee 4%; NHI 3.75% each, capped), as reported by Deloitte.
- **Stamp duty** on property transactions (12%, or 4% for a Belonger, as reported by Deloitte), land and house tax, hotel accommodation tax.
- **Customs import duty**, ad valorem.
- **Corporate and personal income tax**: rate zero.
- **Pillar Two global minimum tax**: Deloitte (2025) reports no announced implementation; other sources conflict, so its status is unverified.

## Reviewing this pack

Open an issue titled "Review: British Virgin Islands". A local accountant should read first: the Order's schedule against `VG-FR-*`; the payroll class thresholds and rates against the Act; the nine-month rule and exemptions against s. 98A; the retention period under s. 98; whether the status of Pillar Two legislation has changed; whether an e-invoicing mandate has appeared.
