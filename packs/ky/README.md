# Cayman Islands

Everything the Cayman Islands add to Ekwo, as data: a chart of accounts, the
journals, the two "not subject" tax codes that carry every sale and purchase a
Cayman business books, and a statement of financial position and an income
statement in the style of IFRS for SMEs. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on.

**Status: `community`.** Nobody who practises in the Cayman Islands has
reviewed it. The golden scenario proves the pack is coherent, not that it is
right.

## Sources

| What | Text | Where |
|---|---|---|
| Proper books of account, true and fair view, five-year retention (s. 59) | Companies Act (2026 Revision) | `legislation.gov.ky` (PDF) |
| Import duty charged on goods in Schedule 1 (s. 3), duty-free goods, package tax | Customs Tariff Act (2026 Revision) | `legislation.gov.ky` (PDF) |
| "The Cayman Islands does not have direct taxes" | Tax Information Authority FAQs | `ditc.ky` |
| No new taxes in the 2026-2027 budget | KPMG Tax News Flash, 7 January 2026 | `kpmg.com` |
| No VAT; import duty, stamp duty | PwC Worldwide Tax Summaries | `taxsummaries.pwc.com` |
| Presentation of the statements | IFRS for SMEs (IASB) | `ifrs.org` |
| Where reporting obligations are filed | DITC Portal | `ditcportal.secure.ky` |

The absence of VAT is established from the Tax Information Authority's
statement that there are no direct taxes, the budget alert and PwC's summary;
the Customs Tariff Act shows the border duty is the transaction-level levy. No
Cayman statute *saying* "there is no VAT" exists to cite, since a tax that was
never enacted has no repeal.

## The chart of accounts

No chart is prescribed. Companies Act s. 59 requires proper books (contracts
and invoices included) that give a true and fair view, kept at least five
years, and nothing more. No reporting framework is imposed either, so the
chart is original and IFRS-inspired: four digits, `1` assets, `2` liabilities,
`3` equity, `4` revenue and other income, `5` cost of sales, `6` operating
expenses. It is flat; `statements.json` groups by code range. 106 accounts.
There is no tax account of any kind: no sales tax to collect, and no income
tax to provision or defer. Accounts exist for what a Cayman company does book:
customs duty on purchased goods (5025), government fees and levies payable,
registered office and corporate services fees, work permit fees, annual
regulatory and filing fees, pension contributions.

## Taxes

Two codes, both 0 % and `not_subject`: `KY-S-NA` on sales and `KY-P-NA` on
purchases, `vat_category` `O`, base postings only, no `tax_report.json`, no
settlement account and no `tax_payable` / `tax_receivable` roles. There is no
VAT, GST or general sales tax, and no income, corporate, capital gains or
payroll tax; the 2026-2027 budget created none.

## Levies left out of the pack

- **Import (customs) duty**, charged on the CIF value under the Customs Tariff
  Act, s. 3 and Schedule 1: 22 % for most headings, other rates (0 %, 12 %,
  17 %, 27 %, 29.5 %, 42 % and more) for others, with duty-free goods in
  Schedule 2 and a package tax in Schedule 3. It depends on the tariff
  heading of the goods, not on the invoice line, so it is booked as a cost of
  the goods (account 5025) and not through a tax code.
- **Stamp duty** (about 7.5 % on property transfers per secondary sources; the
  Stamp Duty Act itself should be checked).
- **Work permit and licence fees, pension contributions.** Fees are booked
  to expense accounts; no payroll or pension module exists.
- **Pillar Two / global minimum tax.** The status of any Cayman domestic
  minimum tax was not established from an official source; secondary sources
  disagree. Check before assuming none applies to large groups.
- **Economic substance, CRS, FATCA and country-by-country reporting**, filed
  through the DITC Portal. These are information filings, not tax returns;
  Ekwo produces none of them.

## The statements

`KY-IFRS-SME-SFP` and `KY-IFRS-SME-IS`, labelled framework `IFRS-SME`:
statement of financial position (current and non-current assets and
liabilities, equity) and a single income statement. No format is mandated;
IFRS for SMEs is chosen as the commonest reference for a private company, and
there is no tax expense line. `xbrl` is null: no filing taxonomy was
verified.

## Closing the year

`fiscal_year_default` is `calendar`: the law fixes no year end, and calendar
is the simplest default. `closing_style` is `retained_earnings`.

## On the invoice

`numbering` is `free`; `payment_terms` has no statutory term or late interest
that was found; `tax_point` is `invoice_date`, a commercial convention and
not a rule, since there is no tax to become chargeable. No `mentions`: no
text read requires any on an invoice. See `pack.json` for each reference.

## Electronic invoicing

`obligation` is `none`: no statute read requires it and no Peppol Authority
for the Cayman Islands is known; this should be confirmed against the
OpenPeppol list of authorities.

## What this pack does not carry

Customs duty and stamp duty as modules, payroll, fixed-asset schedules, XBRL
keys, bank statement formats.

## Reviewing this pack

Open an issue titled "Review: Cayman Islands". A local accountant should
confirm: that no other levy on transactions exists; the current customs duty
rates for the goods the business imports; whether a domestic minimum tax or
other new regime applies to the company; that IFRS for SMEs (or full IFRS) is
the framework clients use; and the Peppol position.
