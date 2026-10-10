# Bermuda

Everything Bermuda adds to Ekwo, as data: a chart of accounts, the journals, the
two "not subject" tax codes that carry every sale and purchase a Bermuda
business books, and a balance sheet and income statement presented in the manner
of IFRS for SMEs. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on.

**Status: `community`.** Nobody who practises in Bermuda has reviewed it. The
figures are replayed against a year of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

**Like Hong Kong, this is a pack for a jurisdiction with no tax on sales.**
Bermuda, a British Overseas Territory, levies no value added tax, goods and
services tax or general sales tax. The pack follows the format of
[`packs/hk`](../hk/README.md): two `not_subject` codes, no `tax_report.json`, no
tax-settlement roles. Currency: the Bermudian dollar (BMD, two decimals), issued
at par with the US dollar.

## Sources

The register in `pack.json` holds five texts, consulted on 10 October 2026.

| What | Text | Opened? |
|---|---|---|
| Records of account kept five years (s. 83); financial statements and the GAAP named in the notes (s. 84, s. 84(1A)) | Companies Act 1981, consolidated text published by the Bermuda Monetary Authority | Yes, ss. 83 and 84 read in full |
| No VAT or sales tax; payroll tax tiers; customs duty; land tax | PwC, *Worldwide Tax Summaries — Bermuda* (last reviewed 19 February 2026) | Yes |
| Corporate income tax: 15 %, from 1 January 2025, Bermuda constituent entities of large groups | EY, *Bermuda Corporate Income Tax* | Yes |
| The statements' layout | IFRS for SMEs Accounting Standard (IFRS Foundation) | Yes |
| Where payroll tax is filed | e-Tax portal of the Office of the Tax Commissioner, `www.etax.gov.bm` | **No** |

**Every `gov.bm` address failed to resolve from the machine that wrote this
pack** (`www.gov.bm`, `gov.bm`, `test.gov.bm`, `www.etax.gov.bm`: DNS error, on
several attempts). The e-Tax URL comes from a search-result snippet, not from
the portal, and `consulted_on` for that entry records the day the address was
looked up, not read. The Government's pre-budget report, the 2026 Customs
Tariff, the Payroll Tax Act 1995 and the Corporate Income Tax Act 2023 were
therefore not opened in their own words: the facts about them below rest on
the secondary sources above and on press reports, and say so.

## Why there is no sales tax in the pack

PwC's Worldwide Tax Summaries (last reviewed 19 February 2026) states: "There is
no VAT or sales tax in Bermuda." A search on 10 October 2026 found no
enacted or proposed general consumption tax; the 2026-27 budget material read
(the pre-budget report as summarised by search results, and press coverage of
the 2026 Customs Tariff and Payroll Tax amendments) proposes none. The Fiscal
Responsibility Panel's reports were not opened. If a general sales tax, GST or
VAT is ever enacted, this pack must be reworked, not extended.

`BM-S-NA` and `BM-P-NA` are `kind: other`, rate 0, `vat_category: O`, with a
`base` posting only. `valid_from` is 2000-01-01, a convenience date and not the
date from which no tax existed.

## What Bermuda charges instead, and the pack does not model

None of these carries a tax code: each is a levy on payroll, on the border or
on a group's profit, not on an invoice line.

- **Customs duty on imports** — Customs Tariff Act 1970, the 2026 Tariff. Rates
  run from 0 % to 33.5 % by tariff line, 25 % being the most common (PwC;
  press coverage of the Customs Tariff Amendment Act 2026, which lowers some
  rates). Paid by the importer on the customs entry. The chart carries
  `5025 Customs duty on imports` and `2071 Customs duty payable`. The 2026
  Tariff itself was not opened.
- **Payroll tax** — Payroll Tax Act 1995, an employer portion and an employee
  portion, filed quarterly with the Office of the Tax Commissioner and paid by
  the 15th of the month after the quarter (15 January, 15 April, 15 July, 15
  October). The employer tiers PwC lists are 1 % below BMD 200,000 of annual
  payroll, then 2.5 %, 5.25 %, 7.5 % and 10 % above BMD 1 million;
  remuneration is capped at BMD 1,000,000 per person. For 2026/27 the rate for
  employers under BMD 200,000 was cut to 0.5 % from 1 April 2026; the Payroll
  Tax Rates Amendment Act 2026 restores 1 % from Q4 2026 (passed by the House
  of Assembly on 11 September and the Senate on 14 September 2026 according to
  Bloomberg Tax and Orbitax — the date of assent was not found, and the PwC
  tiers above predate the amendment). Accounts: `2070 Payroll tax payable`,
  `6025 Payroll tax — employer portion`.
- **Corporate income tax** — Corporate Income Tax Act 2023, 15 %, applying to
  Bermuda constituent entities of multinational groups with consolidated
  revenue of EUR 750 million or more, for fiscal years beginning on or after 1
  January 2025 (EY; assented 27 December 2023 per a PwC summary). It is
  administered by the Bermuda Corporate Income Tax Agency, which is also the
  channel for the global minimum ("Pillar Two") tax; ordinary Bermuda
  companies are outside it. Accounts: `2060`, `1160`, `6470`.
- **Land tax**, **stamp duty** and **social insurance and health insurance
  contributions** exist (PwC lists land tax and stamp duty; the contribution
  rates were not researched). Accounts exist for land tax and contributions;
  nothing computes any of them.

## The chart of accounts

Bermuda prescribes none. Companies Act 1981 s. 83 requires proper records of
sums received and expended, of all sales and purchases of goods and of assets
and liabilities, kept five years from preparation (s. 83(5)); s. 84 requires
the directors to lay financial statements before the general meeting. The
chart is original: four digits by class, flat, 111 accounts, derived from the
Hong Kong chart's structure with the local levies in place of Hong Kong's.
Only trade debtors (`1100`) and trade creditors (`2000`) are `reconcilable`.
There is no tax-clearing account.

## The statements

`BM-IFRS-SME-SFP` (statement of financial position) and `BM-IFRS-SME-IS`
(income statement), in the manner of IFRS for SMEs. **This is a choice of the
pack.** Section 84(1A) lets a company use Bermudian GAAP or another
jurisdiction's, provided the notes identify it; many Bermuda companies report
under IFRS or US GAAP. Section 84(1)(a) also asks for a statement of retained
earnings and a statement of cash flows, which the pack does not produce.
`xbrl` is null.

## Closing the year

`fiscal_year_default` is `calendar`; no text read fixes a Bermuda company's
year end. Payroll tax runs on calendar quarters while the Government's
financial year runs 1 April to 31 March.

## On the invoice

`numbering: free`; `tax_point: invoice_date` is a **convention, not a rule**
(there is no tax to have a point). No mention is declared: no text read
requires one on an invoice. No payment term or late-payment interest statute
was found (not an exhaustive search; the legislation site was not read).

## Electronic invoicing

`obligation: none`. No mandate was found and no Bermuda Peppol Authority turned
up in searches; the OpenPeppol list of authorities was not opened.

## Reviewing this pack

Open an issue titled "Review: Bermuda". A local accountant should read first:

1. The 2026/27 payroll tax rates and the Amendment Act's date of assent and
   effective quarter (all `gov.bm` pages were unreachable here).
2. Whether the IFRS for SMEs layout is the right default against IFRS or US GAAP.
3. Whether `calendar` is the right year-end default.
4. The chart's grouping of payroll tax, social insurance and pension accounts.
5. The e-Tax portal address.
