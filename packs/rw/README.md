# Rwanda

Everything Rwanda adds to Ekwo, as data: a chart of accounts, the journals,
value added tax at 18 %, a zero rate and exemptions, the Monthly VAT
Declaration Form, and the statement of financial position and the profit
and loss account of the IFRS for SMEs Accounting Standard. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content
came from and which decisions it rests on, so that a Rwandan accountant
reading the pack can disagree with a specific sentence rather than with the
whole of it.

**Status: `community`.** Nobody who files a Rwandan VAT return has reviewed
it. The figures are replayed against a month of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**English, with a French translation.** Rwanda's laws — the Value Added Tax
Law, the law governing companies, the law on tax procedures — are gazetted
trilingually, in Kinyarwanda, English and French, each an official text and
not a translation of the others. This pack is written in English and carries
a full French translation in `i18n/fr.json`, drawn from the French column of
those same gazettes wherever a label names a legal term (a tax, a box of the
return, an exempted supply); an account of the chart, which the gazette does
not name, is translated on the same terms `i18n/README.md` sets out for
Kenya's and Serbia's own second languages. No Kinyarwanda translation is
carried: the accounting vocabulary the gazette's Kinyarwanda column uses has
not been checked against the way a Rwandan bookkeeper actually speaks of a
ledger, and inventing that correspondence is a larger claim than a
translation of a legal term is. What the core could not say is written up in
[`docs/international.md`](../../docs/international.md) under "Rwanda". None
of it was patched for this pack's sake.

**Zero decimals.** The Rwandan franc (RWF) has no subunit in ordinary use,
so `currencies.decimal_places` is `0` and every amount in this pack and its
golden scenario is a whole number — `round_amount()` and the rate arithmetic
of the return both read that from `defaults.currency`.

## Sources

Every tax, box and statement line carries its own `legal_reference`, and
beside it the key of the text that article is in. The register in
`pack.json` holds eight texts, every one opened on 26 September 2026. The
ones the rest of this file leans on:

| What | Text | Where |
|---|---|---|
| The charge to tax, the rate, zero-rating, exemptions, imported services, the tax point, input tax, post-sale adjustments, the return, payment | Law N° 049/2023 of 05/09/2023 establishing value added tax, arts. 3, 4, 5, 7, 8, 12, 14, 17, 20, 25, 26, 28, 29 | `rra.gov.rw` |
| The electronic invoicing system (EIS/EBM) | Law N° 020/2023 of 31/03/2023 on tax procedures | `rra.gov.rw` |
| Accounting records, annual accounts, the balance sheet's compliance with international standards, audit | Law N° 007/2021 of 05/02/2021 governing companies, arts. 121 to 133 | `minicom.gov.rw` |
| The statement of financial position and the profit and loss account | ICPAR's adoption of the IFRS for SMEs Accounting Standard, under Law N° 11/2008 of 06/05/2008 | `ifac.org` |
| What each line of the return holds, filing and payment within 15 days | RRA Tax Handbook, 2nd edition, 2025; form RRA-VAT-DF1 | `rra.gov.rw`, `businessprocedures.rdb.rw` |

Kenya Law's difficulty serving a plain HTTPS request has no equivalent here:
every Rwandan gazette cited was read directly at the URL in the register.

## The chart of accounts, and why this one

**Rwanda prescribes no chart of accounts.** Law N° 007/2021 governing
companies, article 121 requires every company to keep accounting records;
article 122 requires annual accounts — a balance sheet, a profit and loss
account, cash flow statements, equity and a statement of changes; article
123 requires the balance sheet to comply with international standards, with
explanatory notes on significant policies, trends, risks and uncertainties.
The Institute of Certified Public Accountants of Rwanda (ICPAR), the
standard-setting body Law N° 11/2008 establishes, has adopted the IFRS
Accounting Standards for an entity with public accountability and the IFRS
for SMEs Accounting Standard for other entities. So the chart is written,
not transcribed, in the same shape as the Kenyan and Nigerian packs:

- **Four digits, by class**: `1` assets, `2` liabilities, `3` equity, `4`
  revenue and other income, `5` goods and materials, `6` other expenses, `7`
  finance costs, `8` income tax.
- **Flat**, every account a leaf, grouped by the ranges of `statements.json`.
- **The accounts a Rwandan company keeps by law or by market practice**:
  VAT input and output tax, import VAT owed to the Rwanda Revenue Authority
  (RRA) at the border, VAT withheld by a public institution pending offset,
  Rwanda Social Security Board (RSSB) and medical insurance contributions,
  Pay As You Earn (PAYE) payable, withholding tax payable, amounts due to
  directors and shareholders, and a cash-in-transit line for mobile money
  and card settlements — mobile money (MTN Mobile Money, Airtel Money) is how
  a large share of Rwandan retail is actually collected.

142 accounts, all postable. None was copied from a published chart.

**Four VAT accounts.** `2100` holds the output tax and `1150` the input tax:
the two the taxes post to. `2125` holds the import VAT shown on a customs
declaration until the Rwanda Revenue Authority at the border is paid. `2110`
and `1155` are where a filed return's balance lands — see below.

**Only three accounts are `reconcilable`**: `1100` (trade receivables),
`2000` (trade payables) and `2110`/`1155` (the VAT settlement accounts).
Every other control account — RSSB, medical insurance, PAYE, withholding
tax, import VAT, VAT withheld by a public institution, amounts due to
directors, the bank and cash accounts, the suspense account — is not, so a
bank statement can only ever letter a customer or a supplier line and
`auto_settle()` never mixes two accounts on one reconciliation.

## Taxes

**One statutory rate.** Article 4(b) fixes it at eighteen per cent; article
4(a) sets the zero rate for the goods and services article 7 lists.

**What a sale can be, and where it goes on the Monthly VAT Declaration
Form:**

| | Code | Box | Legal basis |
|---|---|---|---|
| Standard rate, domestic | `RW-S-18` | 5 | art. 4(b) |
| Zero-rated, export of goods | `RW-S-ZR-EXP` | 5, 20 | art. 7(1)(a) |
| Zero-rated, export of services | `RW-S-ZR-EXP-SVC` | 5, 20 | art. 7(1)(b) |
| Zero-rated, minerals sold domestically | `RW-S-ZR-MIN` | 5, 15 | art. 7(1)(c) |
| Exempt, unprocessed agricultural and livestock products | `RW-S-EX-AGRI` | 5, 10 | art. 8(1)(k) |

**Purchases:**

| | Code | Box | Legal basis |
|---|---|---|---|
| Standard rate, claimed | `RW-P-18` | 55, 60 | art. 17(1) |
| Standard rate, disallowed (passenger vehicle) | `RW-P-18-BL` | none | art. 20(a) |
| Import of goods | `RW-P-IMP` | 50, 60 | arts. 3(1)(b), 15, 16, 29(2) |
| Imported service, reverse charge, deductible | `RW-P-RC-FOREIGN` | 40, 65 | art. 14 |
| Imported service, reverse charge, disallowed | `RW-P-RC-FOREIGN-BL` | 40 | art. 14, 20 |

**Article 14 is Rwanda's own shape of a reverse charge, and it is not
modelled as a European one.** A taxpayer who acquires a service from a
person outside Rwanda "is considered to have received a taxable service and
an output tax from that person" (art. 14(1)); the output tax is payable on
the date of declaration for the period the service was delivered (art.
14(2)), and — unlike a European reverse charge, which is always
deductible on the same return it is charged on — the recipient may deduct it
as input tax **only if the service received is not available on the local
market** (art. 14(3)); a service is not considered available if there is no
one who can deliver an identical or similar one (RRA Tax Handbook, "What is
VAT Reverse Charge?"). `RW-P-RC-FOREIGN` books the deemed output liability
and the input claim on posting, netting to nothing on a wholly taxable
purchase, so both boxes 40 and 65 move together. `RW-P-RC-FOREIGN-BL` books
the same output liability alone: the input side is disallowed, and the VAT
becomes part of the cost of the line, the way `RW-P-18-BL` disallows a
passenger vehicle's input tax. **Whether a service is "available on the
local market" is not a fact this pack's ledger holds** — article 14(5) has
the taxpayer request the Ministry's authorisation to acquire an unavailable
service — so both reverse-charge codes carry `"conditions": ["supply_nature"]`,
which documents the question and answers nothing: a bookkeeper decides which
of the two codes a given imported service falls under, the way
[`docs/packs.md`](../../docs/packs.md) describes `conditions` doing for an
American resale certificate.

## The return

**Form RRA-VAT-DF1, filed monthly or quarterly by turnover.** Article 28(1)
declares the period a calendar month or a quarter of three months; article
28(2) puts a taxpayer with an annual turnover at or below FRW 200,000,000 on
the quarterly cadence, article 28(3) puts one above it on the monthly
cadence, and article 28(4) lets a taxpayer under the threshold opt into the
monthly cadence instead. Because the cadence follows a fact about the
company rather than a rule the law gives everybody, `tax_report.json`
declares both cadences and no `period_default` — the same reading
[`docs/packs.md`](../../docs/packs.md) gives Luxembourg's own eCDF return.
Article 28(2) and (3) set the declaration due within fifteen days of the end
of the period, and article 29(1) sets payment on the same day.

**Lines 5 to 70 are carried; lines 75, 76, 80, 90 and 95 are not, and every
gap is real.** Line 76, "Total amount of invoices to Public Institutions
(VAT Exclusive)", and line 80, "VAT Withholding retained by Public
Institutions", record a mechanism a public body executes as a third party to
the sale — article 3(3) obliges "a public procuring entity" to withhold VAT
on a tender payment and remit it directly, crediting the supplier — which a
`taxes.json` posting, always speaking of the two parties to one document,
cannot state; it is recorded in [`docs/international.md`](../../docs/international.md)
under "Rwanda", the way `docs/packs.md` describes Kenya's own withholding VAT
gap. Line 75, "Credit carried from Previous Month(Not already claimed)", is
period-to-period settlement rather than a figure a document posts. Lines 90
and 95 split line 70 between a refund claim and an amount due — an
administrative act of the e-Tax portal on the sign of one figure this pack
already carries in full at line 70, and not a second fact.

## What this pack does not carry

- **VAT withheld by a public institution under article 3(3).** See above.
- **The apportionment of input tax** of a taxpayer who is only partly
  taxable — this pack's golden company makes wholly taxable supplies.
- **eTIMS-style stock records.** The Electronic Invoicing System reports
  every EBM invoice to the Rwanda Revenue Authority in real time, which is
  a clearance and not a peer-to-peer exchange in the sense
  `einvoicing.profile` describes; see `pack.json`'s own `einvoicing.legal_reference`
  and [`docs/international.md`](../../docs/international.md) under "Rwanda".
- **Income tax withholding** other than VAT: out of scope of a VAT pack.
- **Fixed assets.** No `assets.json`: Rwanda's capital allowances are an
  income tax schedule, not a useful life the IFRS for SMEs Accounting
  Standard leaves to the entity.
- **Bank formats.** Nothing checked says which formats Rwandan banks send.
- **Filing itself.** The return is filed, and paid, on e-Tax; submitting it
  is a credential, not a pack.

## Reviewing this pack

Open an issue titled "Review: Rwanda". What a review is, and what it is not,
is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and who
may say what". The points a Rwandan chartered accountant should read first,
roughly in the order the author is least sure of them:

1. **`tax_point: earliest_of_delivery_or_payment`** against article 12(1),
   which is in fact a five-way earliest test — invoice issue, payment,
   removal or delivery of goods, delivery of a service, or a deregistration
   application — and not the two-way test the word names; see
   `pack.json`'s own reference and
   [`docs/international.md`](../../docs/international.md).
2. **The two reverse-charge codes and their `conditions`**, against how a
   Rwandan practitioner in fact tells an "available on the local market"
   service from one that is not, and whether the Ministry's article 14(5)
   authorisation is sought in practice before the deduction is taken.
3. **`RW-P-18-BL` reaching no box**, against whether the return's own
   detail sheet in fact expects a disallowed purchase to be listed there at
   zero-claim rather than omitted.
4. **The chart's mapping onto the statements**, especially amounts due to
   directors and shareholders among current borrowings, and the RSSB,
   medical insurance, PAYE and VAT accounts among trade and other payables.
5. **`numbering: sequential`**, which rests on the Electronic Invoicing
   System's own numbering rather than a no-gap rule stated for a Rwandan tax
   invoice apart from it.
6. **No `period_default`**, and whether a Rwandan practitioner would in fact
   expect this pack to propose the monthly cadence as the one most companies
   installing it will file on, turnover aside.
