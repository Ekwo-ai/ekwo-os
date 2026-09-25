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
they repeal. The standard rate is unchanged at the move, 7.5 %, so a company
whose books straddle the two regimes sees no change in the figure; the
reforms are elsewhere, in what is zero-rated and what is exempt, and in the
registration and filing rules. `released_at` is 2026-09-25, after the new law
took effect, so this pack does not carry the pre-2026 Act at all — a pack that
needs it will add a `valid_to` on every tax and a second one from `2026-01-01`.

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

**One thing this pack's research could not open, and it is named rather than
papered over: the return as TaxPro-Max shows it today.** The Nigeria Revenue
Service (until the Nigeria Revenue Service (Establishment) Act 2025, the
Federal Inland Revenue Service) has accepted no manual VAT return since June
2021; every VAT return is filed on TaxPro-Max, an online portal, and this
pack's research found no public specimen of its screens — only vendor guides
describing a "sales schedule" upload that appears to work from values stated
net of VAT. The only printed form this research could find, Form VAT 002, is
dated 2020, is stated inclusive of VAT in a way that does not obviously match
what the portal does today, and its own worked example still carries the 5 %
rate the Finance Act 2019 superseded. Rather than transcribe that form's box
numbers as if they were the portal's, `tax_report.json` numbers its own boxes
against the statutory description of Nigeria Tax Administration Act 2025,
s. 22(3) — output tax, input tax, VAT payable — the way `packs/sa/` numbers a
return that is itself a screen. **A reviewer who files a real return on
TaxPro-Max should check the boxes against what the portal shows**, and correct
`tax_report.json`'s box numbers if they differ; the underlying figures — what
counts as a standard-rated, zero-rated, exempt or imported supply, and how
much VAT it carries — do not depend on which box they are printed in.

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
  the Development Levy of Nigeria Tax Act 2025, s. 59, apart from VAT — this
  pack carries no code for computing either of the last two, see "What this
  pack does not do" below.

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
zero percent. This pack carries the domestic list as one code, `NG-S-ZR-DOM`,
and the export case as another, `NG-S-ZR-EXPORT`, because the invoice mention
and the golden scenario read differently even though both post to the same
box of the return.

**Exempt, and the one place it stops being an ordinary opposite of
zero-rated.** Section 185 exempts a shorter, more particular list — land and
buildings, money and securities, government licences, baby products, locally
manufactured sanitary towels, and, notably, **oil and gas exports**, which are
exempt rather than zero-rated: an exporter of crude oil or gas charges no VAT
on the export and deducts none of its own input tax against it, unlike an
exporter of anything else.

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

## The VAT return

**Monthly, and only monthly.** Nigeria Tax Administration Act 2025, s. 22(1):
no cadence but the calendar month exists for the VAT return, unlike Belgium's
or Ireland's choice of a longer period on request.

**Due, filed and paid on the 21st day of the month after the period.**
Section 22(1) for the return; s. 49(1) sets the same day for payment. A
different obligation, on a different person, falls due on the fourteenth: s.
154(4), for VAT a government body or an appointed collector has withheld at
source — this pack does not model it, see below.

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
this chart's own account blocks rather than reproducing every sub-item the
Schedule lists. A company preparing statutory accounts in full detail should
treat these two as the skeleton and add the sub-analysis the Schedule and its
notes ask for.

## What this pack does not do

- **VAT the government withholds at source.** Nigeria Tax Act 2025, s. 154,
  and its own return, FIRS Form 006, apply to a government body or an
  appointed collector that withholds VAT from a payment instead of paying it
  to the supplier gross. This is a different declaration on a different
  cadence (the 14th, not the 21st) from a different filer, and this pack
  carries no tax code or box for it.
- **Proportional input tax deduction.** Section 155(4)'s proviso restricts the
  deduction, where a purchase serves both taxable and non-taxable supplies, to
  the taxable proportion. The socle has no column for a partly-deductible
  tax — the same gap `packs/sa/tax_report.json` records for Saudi Arabia's own
  proportional-deduction rule (Implementing Regulations, Articles 51–52).
- **Petroleum products, renewable energy equipment, CNG, LPG and other gaseous
  hydrocarbons.** Nigeria Tax Act 2025, Eleventh Schedule, paragraph 1, leaves
  the charging and collection of VAT on these items to a Ministerial order
  this pack's research found none of — the rate could be 7.5 %, zero, or
  nothing at all on any given day, by an instrument outside the Act. Rather
  than guess, this pack carries no tax code for them.
- **Companies Income Tax and the Development Levy themselves.** This pack's
  chart carries the accounts a company would post them to (2310, 2320, 8200,
  8230) and its statements carry the line they land on, but computing what is
  owed — the rates, the allowances, the small-company 0 % band — is a
  different chapter of the Nigeria Tax Act this pack does not carry.
- **Electronic invoicing and the Electronic Fiscal System.** The FIRS
  Merchant-Buyer Solution is a clearance platform, not an EN 16931 profile any
  brick of `packages/formats` writes, and the wider Electronic Fiscal System
  of Nigeria Tax Act 2025, s. 157, and Nigeria Tax Administration Act 2025,
  s. 23, awaits regulations this pack's research found none of. See
  `pack.json`'s `einvoicing` block and this pack's section of
  [`docs/international.md`](../../docs/international.md).
- **Bank statement and payment file formats.** This pack's research did not
  establish which formats Nigerian banks issue and accept as a market
  practice reliable enough to cite, so `pack.json` declares no `bank` section
  rather than guess between `mt940`, `camt.053` and `csv`.

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
