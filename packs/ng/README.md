# Nigeria

Everything Nigeria adds to Ekwo, as data: a chart of accounts, the journals,
the 7.5 % value added tax with its zero-rated and exempt supplies, the VAT
return the Nigeria Revenue Service asks for, and the statement of financial
position and the statement of profit or loss the Companies and Allied Matters
Act asks a company's directors to prepare. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Nigerian accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

**Status: `community`.** Nobody who files a Nigerian VAT return has reviewed
it. The figures are replayed against a scenario of documents and payments by
`tests/golden.test.ts`, which proves the pack is internally coherent and
proves nothing about whether it is right.

**This pack is written for the law in force from 1 January 2026** — the
Nigeria Tax Act 2025 and the Nigeria Tax Administration Act 2025, both signed
26 June 2025 — and not for the Value Added Tax Act, Cap. V1, LFN 2004, that
they repeal. The standard rate is unchanged at the move, 7.5 %; the reforms
are in what is zero-rated and what is exempt, and in the registration and
filing rules. The pre-2026 Act is not carried; carrying it would need a
`valid_to` on every tax and a second one from `2026-01-01`.

**Language: `en`.** English is the language of the two Acts and of every text
this pack cites; Nigeria has no other official language of legislation, so
there is no second wording to carry in `i18n/`.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and
beside it the key of the text that article is in. The register in `pack.json`
holds seven texts; the four this file leans on most:

| What | Text | Where |
|---|---|---|
| VAT: the rate, the base, zero rating, exemptions, invoices, time of supply | Nigeria Tax Act 2025 (Act No. 7 of 2025), Chapter Six and Chapter Eight, Part IV | `tat.gov.ng` (Official Gazette No. 117, Vol. 112, 26 June 2025) |
| Registration, returns, filing deadlines, the small-business exemption | Nigeria Tax Administration Act 2025 (Act No. 5 of 2025), Chapter Two | `tat.gov.ng` (same Gazette) |
| The most recent public specimen of the return | Form VAT 002 and its explanatory notes | `firs.gov.ng` |
| The chart and the two statements | Companies and Allied Matters Act 2020, s. 374, 377, 378 and the First Schedule | `cac.gov.ng` |

**The boxes of the return are this pack's own numbering.** The Nigeria
Revenue Service (until the Nigeria Revenue Service (Establishment) Act 2025,
the Federal Inland Revenue Service) has accepted no manual VAT return since
June 2021; every VAT return is filed on TaxPro-Max, an online portal with no
public specimen of its screens. The only printed form, Form VAT 002, is dated
2020, is stated inclusive of VAT, and its own worked example still carries the
5 % rate the Finance Act 2019 superseded. `tax_report.json` therefore numbers
its own boxes against the statutory description of Nigeria Tax Administration
Act 2025, s. 22(3) — output tax, input tax, VAT payable. **A reviewer who
files a real return on TaxPro-Max should check the boxes against what the
portal shows**, and correct `tax_report.json`'s box numbers if they differ;
the underlying figures — what counts as a standard-rated, zero-rated, exempt
or imported supply, and how much VAT it carries — do not depend on which box
they are printed in.

## The chart of accounts, and why this one

**There is no legal chart of accounts in Nigeria.** Companies and Allied
Matters Act 2020, s. 378(1) requires a company's financial statements to
comply with the First Schedule to the Act "so far as applicable" for their
form and content, and with the accounting standards the Financial Reporting
Council of Nigeria lays down under its own Act of 2011 — IFRS Accounting
Standards for a public interest entity, the IFRS for SMEs Standard otherwise.
Neither prescribes a nominal ledger, only a balance sheet and profit and loss
account format (the First Schedule's Format 1, which this chart's two
statements follow) and a set of recognition and measurement standards.

- **Four digits**, blocked so that each range reaches one line of the First
  Schedule Format 1 balance sheet or profit and loss account.
- **200 accounts**, all postable, none copied from a published chart.
- **The accounts a Nigerian company actually keeps**: VAT recoverable and
  payable apart from the settlement account the return is paid or refunded
  through, VAT paid to the Nigeria Customs Service on import, Pay As You Earn,
  Pension Reform Act and National Housing Fund contributions, the Nigeria
  Social Insurance Trust Fund and Industrial Training Fund levies, withholding
  tax credit notes and withholding tax payable, and Companies Income Tax and
  the Development Levy of Nigeria Tax Act 2025, s. 59, apart from VAT — no
  VAT code computes either of the last two, see "What this pack does not do".

## Taxes

**One positive rate, 7.5 %.** Nigeria Tax Act 2025, s. 147. The rate is
unchanged from the Finance Act 2019, which raised it from 5 % with effect from
1 February 2020.

**Zero-rated, in two shapes.** Section 186 rates a long list of domestic
supplies at zero percent — basic food items, medical and pharmaceutical
products, educational books and materials, fertilisers and other listed
agricultural inputs, live cattle, goats, sheep and poultry, electricity
generated for or transmitted on the national grid, medical services and
equipment, and tuition from nursery to tertiary level — and separately rates
exported goods (other than oil and gas), services and incorporeal property at
zero percent. The domestic list is one code, `NG-S-ZR-DOM`, and the export
case another, `NG-S-ZR-EXPORT`, because the invoice mention reads differently
even though both post to the same box of the return.

**Exempt, and the one place it stops being an ordinary opposite of
zero-rated.** Section 185 exempts a shorter, more particular list — land and
buildings, money and securities, government licences, baby products, locally
manufactured sanitary towels, and, notably, **oil and gas exports**, which are
exempt rather than zero-rated: an exporter of crude oil or gas charges no VAT
on the export and deducts none of its own input tax against it.

**Imports.** Section 149 sets the value an import is taxed on — the price paid
plus non-VAT duties, charges and the cost of getting the goods to the port or
point of entry — and s. 155(3) makes the importer pay the VAT to the Service,
in practice to the Nigeria Customs Service at the border, before the goods are
released. `NG-P-IMP` posts the tax there rather than adding it to the amount
owed to the foreign supplier, who is never owed Nigerian VAT at all.

**A small business charges no VAT.** Nigeria Tax Administration Act 2025,
s. 22(4), read with the definition in s. 202: a business earning ≤
₦100,000,000 gross turnover a year, with total fixed assets ≤ ₦250,000,000,
is not required to register, charge VAT or file returns — unless it provides
professional services, which are never a small business regardless of
turnover, or unless it opts in under s. 22(5). `NG-P-NR` carries a purchase
from such a supplier: no tax charged, nothing on any box.

**A purchase from a supplier abroad: the buyer withholds the VAT.** A
software subscription, hosting or an API billed from outside Nigeria by a
non-resident that charged no VAT is still taxable, and Nigeria Tax Act 2025,
s. 150(2), puts it on the buyer: *"the taxable person to whom the supply is
made in Nigeria shall withhold the VAT due on the supply and remit it to the
Service"* — unless a collector the Service appointed under s. 150(3) already
collected it (s. 150(4)), in which case the purchase is an ordinary
`NG-P-SR` one. The amount withheld is remitted with a schedule by the 14th
of the following month (s. 154(3)–(4)), and s. 155(4) deducts input tax on
any taxable supply, *"including services"*, in the period of the supply.
`NG-P-NRS` books both halves at 7.5 %: input tax debited to `1140` and
declared in box `IS` (a line of this pack's own, which box 9 adds), the
withholding credited to the new `2160` and remitted outside the return. The
chart has no payable account for suppliers abroad, so a foreign supplier
sits on `2100` with the others.

## The VAT return

**Monthly, and only monthly.** Nigeria Tax Administration Act 2025, s. 22(1):
no cadence but the calendar month exists for the VAT return.

**Due, filed and paid on the 21st day of the month after the period.**
Section 22(1) for the return; s. 49(1) sets the same day for payment. A
different obligation, on a different person, falls due on the fourteenth: s.
154(4), for VAT a government body or an appointed collector has withheld at
source — not modelled, see below — and for the VAT a buyer withholds on a
supply from a non-resident (`NG-P-NRS`, above).

**A negative box 10 is a credit or a refund, never floored at zero.** Section
155(1): output tax in excess of input tax is remitted; input tax in excess of
output tax is carried forward as a credit against future months, or, under
s. 155(2), refunded on request.

## The statements

Companies and Allied Matters Act 2020, s. 377(2)(b) and (c) require a balance
sheet and a profit and loss account among the financial statements a
company's directors prepare each year; s. 378(1) makes them comply with the
First Schedule "so far as applicable". `NG-CAMA-BS` and `NG-CAMA-IS` follow
the First Schedule's Format 1 — the vertical balance sheet headed A to M, and
the function-of-expense profit and loss account — summarised to the level of
this chart's own account blocks. A company preparing statutory accounts in
full detail should treat these two as the skeleton and add the sub-analysis
the Schedule and its notes ask for.

## What this pack does not do

- **VAT the government withholds at source** (Nigeria Tax Act 2025, s. 154,
  and its own return, FIRS Form 006): a different declaration on a different
  cadence (the 14th, not the 21st) from a different filer; no tax code or box.
- **Proportional input tax deduction.** Section 155(4)'s proviso restricts the
  deduction, where a purchase serves both taxable and non-taxable supplies, to
  the taxable proportion; the socle has no column for a partly-deductible tax.
- **Petroleum products, renewable energy equipment, CNG, LPG and other gaseous
  hydrocarbons.** Nigeria Tax Act 2025, Eleventh Schedule, paragraph 1, leaves
  the charging and collection of VAT on these items to a Ministerial order,
  none of which is cited here; the pack carries no tax code for them.
- **The Development Levy.** The chart carries the accounts it posts to (2320,
  8230) and the statements the line it lands on, but it is not computed: see
  "Corporate income tax" below. The income tax itself is estimated from
  `corporate_tax.json`.
- **Electronic invoicing and the Electronic Fiscal System.** The FIRS
  Merchant-Buyer Solution is a clearance platform, not an EN 16931 profile any
  brick of `packages/formats` writes, and the wider Electronic Fiscal System
  of Nigeria Tax Act 2025, s. 157, and Nigeria Tax Administration Act 2025,
  s. 23, awaits regulations. See `pack.json`'s `einvoicing` block and
  [`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet).
- **Bank statement and payment file formats.** No market practice for the
  formats Nigerian banks issue and accept is established, so `pack.json`
  declares no `bank` section.

## Points a Nigerian accountant should check first

- The box numbers of `tax_report.json` against what TaxPro-Max actually
  prints, as explained under "Sources" above.
- Whether the Eleventh Schedule suspension of VAT on petroleum products, CNG
  and LPG is in effect for the period being booked, and at what rate, if any.
- The exact wording "basic food items" and the other defined terms of Nigeria
  Tax Act 2025, s. 188 take in practice, where a golden scenario's own
  wording ("assorted pharmaceutical products") is this pack's illustration
  and not a term of art.
- Whether a given company is still within the small-business turnover and
  fixed-asset thresholds, which move only by regulation and not by this pack.

## Corporate income tax: what `corporate_tax.json` leaves out

The section carries the Nigeria Tax Act 2025 (Official Gazette No. 117,
26 June 2025) and nothing else. It starts from line `PBT` of `NG-CAMA-IS`,
and every entry is dated from 1 January 2026, the commencement of the Act:
**a financial year opened before that date has no rate in the section, and
the module refuses it by name rather than estimate it.**

| Not carried | Why |
|---|---|
| The regime of the Companies Income Tax Act, Cap. C21, LFN 2004, as amended by the Finance Acts (0 % up to N25,000,000 of turnover, 20 % to N100,000,000, 30 % above), and the tertiary education tax | The Act was repealed from 1 January 2026 (Nigeria Tax Act 2025, s. 195(c)). The figures are not carried, and the section has nothing for financial years 2025 and before. |
| Which regime governs the profits of the financial year 2025 | Nigeria Tax Act 2025, s. 22(1), takes the profits of the accounting period *immediately preceding* the year of assessment, and a year of assessment is a calendar year (s. 202). Read literally, the profits of 2025 are those of the year of assessment 2026; no transitional rule is cited. This is a reading for a Nigerian adviser, and the section dates by the first day of the financial year. |
| The Development Levy, 4 % of the assessable profits (s. 59) | A separate levy with its own base, not the tax of the section: the module computes one tax per company. Booked on accounts 8230 and 2320, below line `PBT`. |
| The minimum effective tax rate of 15 % (s. 57) | A top-up of the tax, computed on the tax itself and on the development levy, for groups of at least EUR 750 million and companies of N50,000,000,000 of turnover and above. The section has no shape for a tax on the tax. |
| The reduction of the rate to 25 % (s. 56, proviso) | Conditional on an order of the President not cited here; the standard rate is 30 %. |
| Capital allowances (s. 27, First Schedule, Part I) | The rates and the pools are not carried; the company declares the amount under `capital-allowances`. |
| Amortisation of intangible assets, impairment and the other items of s. 21 (capital expenditure, private expense, payments to a connected person outside the transfer pricing rules, expenses on which VAT was not charged…) | Account 7670 and 7680 are not added back by themselves, the treatment of intangibles not being carried; the others depend on facts only the company knows. The company names an account or states an amount against `depreciation`, `fines-penalties` or `unrealised-exchange-loss`. |
| Unrealised exchange gains | Section 21(g) refuses the deduction of an unrealised difference; whether an unrealised gain is taxed is not established. |
| Losses limited to the trade in which they arose (s. 27(6)(b)) and losses incurred before 2026 | The module keeps one stock of losses per company. The treatment of a loss of the Companies Income Tax Act era under the new Act is not established: the third worked example assumes it carries. |
| Prepayments and payment dates | None in a form the section can hold: `prepayments` is empty. |
| Tax credits (priority sector, economic development incentive) | `credits` is empty: no credit was cited. |
| Companies taxed apart (petroleum, insurance, free zones, non-residents) | Different parts of the Act with their own bases. |

The small-company rate is written as a rate with conditions and no threshold:
the module applies the first rate with no threshold whose conditions are met
to the whole base, so a company that declares a turnover and fixed assets
within the two limits is taxed at 0 % and any other at 30 %. A company that
declares neither is not a small company for the estimate, which says
`not_declared`.

## Fixed assets

`fixed_assets.json` carries how a Nigerian company depreciates a fixed asset and
takes it off the balance sheet. It rests on IFRS for SMEs (third edition,
2025), Sections 17, 18 and 19, and on the IFRS Foundation's profile of
Nigeria, which records that the Financial Reporting Council adopted that
Standard for small and medium-sized entities without modification.

- **Disposal is `net_result`.** Section 17, paragraphs 17.27 to 17.30, put the
  difference between the net proceeds and the carrying amount in profit or loss
  as one figure; the profit and loss account (Format 1, items 6 and 11) prints a
  gain and a loss, which are the roles `asset_disposal_gain` (4230) and
  `asset_disposal_loss` (7690).
- **The first-period prorata is practice, not text.** Paragraph 17.20 starts the
  charge when the asset is available for use and says nothing of how to cut the
  first year; the section counts real days from that day, in straight line and
  in declining balance. A company that counts whole months sets
  `prorata = 'months'` on the asset.
- **Durations are practice.** Nigeria has no legal or fiscal table of useful
  lives for the accounting charge. The only figure in a text is the ten
  years of goodwill and of an intangible whose life cannot be established
  (paragraphs 19.34 and 18.20), which is a ceiling and not an estimate. Every
  other category says in its `legal_reference` that its duration is common
  practice. A category proposes, never imposes.
- **Capital allowances are not the charge.** They are a tax computation under
  the Nigeria Tax Act 2025 and no category borrows their rates.

### Fixed assets: what `fixed_assets.json` leaves out

| Not carried | Why |
|---|---|
| Capital allowances (initial and annual allowances, pools) | A tax computation distinct from the book charge. The module keeps one schedule per asset. |
| A declining-balance category | Paragraph 17.22 allows the method but no Nigerian text or rate is cited, and a coefficient would be invented. An asset can still be set up in declining balance by hand. |
| Separate depreciation of major components (paragraph 17.16) | The module has one asset and one duration. |
| Residual value, impairment (Section 27) and its reversal | Not a pack rule. |
| Revaluation model (paragraphs 17.15B to 17.15D) | Not carried; the module has no revaluation. |
| Threshold below which an item is expensed | Set by the company's policy; no Nigerian text cited. |
| Construction-in-progress (account 0170) | Not depreciated until available for use. |
| Investment property, assets held for sale, leased assets (Section 20) | Not carried; the module cannot stop depreciation on a reclassification. |
| Units of production | Refused by the module. |
