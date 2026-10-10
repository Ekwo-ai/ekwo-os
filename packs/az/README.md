# Azerbaijan

Everything Azerbaijan adds to Ekwo is data: a chart of accounts taken from the
published national chart (three-digit accounts, 155 rows), the value added tax
(ƏDV) at 18 %, the zero rate and the exemptions of the Tax Code, the monthly
ƏDV return laid out on the lines of the official 2026 form, and a balance sheet
and an income statement drawn from the chart. The format is described in
[`docs/packs.md`](../../docs/packs.md); this file says where each line comes
from and which decisions it rests on, so that an Azerbaijani accountant can
challenge a single sentence rather than the whole pack.

**Status: `community`.** No accountant or auditor has read this pack yet. The
figures are replayed by `tests/golden.test.ts` over a quarter of books and
checked by hand against an independent calculation; that proves internal
consistency, not legal correctness.

**The pack is written in Azerbaijani** (`defaults.language: "az"`): the Tax
Code, the State Tax Service's form and booklets, and the chart of accounts are
all official Azerbaijani texts. `i18n/en.json` is a working translation for
English-speaking readers, not an official English version of any of them (see
[`i18n/README.md`](i18n/README.md)).

## Sources

Every rate, box and deadline cites a text in `certification.sources`.

| Key | Text | Read through |
|---|---|---|
| `tax-code` | Tax Code of the Republic of Azerbaijan | e-qanun.az (the page serves a script shell that an automated fetch cannot read; the articles below were read through the next two entries) |
| `tax-code-extract` | Tax Code, articles 164 and 165 as currently worded | customs.gov.az PDF |
| `vat-booklet` | ƏDV information booklet, 2025 | taxes.gov.az PDF |
| `filing-deadlines` | Table of payment and filing deadlines | taxes.gov.az |
| `vat-return-form` | ƏDV return, 2026 form, approved by order No. 2617140100317700 of 3 April 2026 | taxes.gov.az spreadsheet |
| `tax-faq-2026` | Questions and answers on the 2026 amendments (articles 155.1-1, 165.5) | taxes.gov.az PDF |
| `e-services` | State Tax Service e-services (declaration and electronic invoice reception) | taxes.gov.az |
| `accounting-law` | Law on Accounting | frc.az |
| `nas-status` | Ministry of Finance page marking the commercial National Accounting Standards as repealed | maliyye.gov.az |
| `chart-muhasib`, `chart-e-muhasib` | The chart of accounts as reproduced by two private accounting portals | muhasib.az, e-muhasib.az |

The e-taxes.gov.az portal itself refused automated access (HTTP 403), so the
filing portal is cited through the State Tax Service's own e-services page.

## The chart of accounts, and why this one

The chart is the three-digit national chart (classes 1 to 9: long-term assets,
short-term assets, capital, long-term and short-term liabilities, income,
expenses, profits, profit tax), in the wording of the published list, including
account 226 "ƏDV sub-uçot hesabı" and the dashed sub-accounts 414-1, 501-1 and
515-1.

Two points need a local accountant's confirmation:

- **The legal reference.** The chart is commonly attributed to the Ministry of
  Finance order İ-38 of 18 April 2006 (annex 2 of National Accounting Standard
  No. 1). A secondary source confirms the order and date; the Ministry's own
  site now lists the commercial-organisation national standards as repealed, and
  the Law on Accounting requires IFRS (or IFRS for SMEs) without prescribing a
  numbered chart. The chart is therefore declared as the one entities keep
  using in practice, not as a statute currently in force. No official page
  serving the chart text could be opened; the wording comes from two private
  portals that reproduce it, and they differ in a few places (accounts 194–195
  and 415/516 appear in only one); this pack follows the muhasib.az list (which
  has 414-1 and 515-1) and leaves those four out.
- **Five accounts are the pack's own.** The chart has one VAT account on each
  side (241 recoverable taxes, 521 tax liabilities). To keep the settlement
  account distinct from the accounts the taxes post to, 241 and 521 stay as the
  `tax_receivable` / `tax_payable` settlement accounts (the only `reconcilable`
  tax accounts) and the sub-accounts 2411, 2412, 2413, 5211 and 5212 carry the
  postings. Dashed sub-accounts are the national convention for this.

`reconcilable` is true for 211 (customers), 531 (suppliers) and the two VAT
settlement accounts only. Banks, cash, the suspense account (545) and the VAT
deposit sub-account 226 are not reconcilable: 226 is not a bank account a
statement can be matched against, it is a balance held with the tax authority.

Roles: `receivable` 211, `payable` 531, `bank` 223, `cash` 221, `sales` 601,
`purchase` 701, `retained_earnings` 343, `fx_gain` 611, `fx_loss` 731,
`rounding` 731, `suspense` 545, `tax_payable` 521, `tax_receivable` 241.

## Taxes

| Code | Rate | Source |
|---|---|---|
| `AZ-S-18` | 18 % sale, **on the cash basis** | Tax Code art. 161; booklet |
| `AZ-S-0` | 0 % sale (international transport, art. 165.1.4) | Tax Code art. 165.1 |
| `AZ-S-EXPORT` | 0 % export of goods (art. 165.1.3) | Tax Code art. 165.1.3 |
| `AZ-S-EXEMPT` | exempt: paid education (art. 164) | Tax Code art. 164.1; booklet |
| `AZ-P-18` | 18 % purchase, deductible when paid | Tax Code art. 175.1; booklet |
| `AZ-P-IMPORT` | 18 % import | Tax Code art. 161; booklet |
| `AZ-P-EXEMPT` | exempt purchase | Tax Code art. 164.1 |

**ƏDV is due when the sale is paid.** The booklet fixes the time of a taxable
operation as the time of payment (cash received, funds credited to the bank
account, receipt printed by the cash register, mutual set-off); each instalment
of a part payment is a separate operation. The pack declares
`documents.tax_point: payment_date`, and the sale and domestic purchase taxes
use the pack's cash-basis mechanism: VAT waits on 5212 (output) or 2413 (input)
until the invoice is paid, then moves to 5211 or 2411 pro rata to the
payment, and reaches the return box in the month of the payment. Zero-rate and
exempt sales are not on the cash basis in this pack: their base reaches the
return on the invoice date, an approximation of the form's "amount received"
column (see the gaps below).

**The registration threshold** is 200 000 AZN of taxable operations over any
12 consecutive months (art. 155.1). Since 1 January 2026 the turnover of
retail trade and of services to persons not registered with the tax
authority, when paid by POS terminal, counts at 0.5 (art. 155.1-1; official
2026 FAQ). Registration is a company status, not a tax: the pack does not
compute the threshold.

## The declaration

`tax_report.json` is the monthly return, due by the **20th of the month
following the period**, filed on e-taxes.gov.az (art. 177.2; the State Tax
Service's table of deadlines: "Hesabat ayından sonrakı ayın 20-dən gec
olmayaraq (20/I-XII)"). The lines come from the 2026 form approved on
3 April 2026:

| Box | Form line | Meaning |
|---|---|---|
| `301R`, `301T` | 301 | operations taxed at 18 %: amount received excluding VAT, VAT |
| `302R` | 302 | zero-rated operations |
| `303R` | 303 | exempt operations |
| `305R`, `305T` | 305 | totals of lines 301 to 303 and of the VAT column |
| `308B`, `308T` | 308 | amount paid by non-cash means on received electronic invoices, deductible VAT |
| `310B`, `310T` | 310 | amount paid on imports, VAT paid on import |
| `317T` | 317 | total deductible VAT |
| `326` | 326 | payable to the budget (305 − 317, floored at zero) |
| `327` | 327 | refundable from the budget (317 − 305, floored at zero) |

The form's other lines are not modelled; see below.

## Electronic invoice

Between VAT payers the **electronic tax invoice (e-qaimə-faktura)** is
obligatory, issued on the State Tax Service's system (e-taxes.gov.az), and the
buyer deducts VAT only on a received electronic invoice (booklet; art. 175.1).
It is a state-clearance system that does not follow EN 16931 or Peppol, so
`einvoicing.profile` and the identifier schemes are null. `obligation` and
`mandatory_from` are left out: no official text opened here gives the date the
obligation began. From 2026 a recurring service needs one invoice per calendar
month (art. 71-1.1.3-2); this rests on secondary sources only, because the
article's text was not found on an official page.

## Services bought from a non-resident

A software subscription, hosting or an API billed by a non-resident not
registered for VAT in Azerbaijan is taxed in the hands of the buyer: art. 169.1
of the Tax Code makes every VAT-registered person a tax agent for those
services, art. 169.3 has it calculate VAT at 18 % (art. 173.1) on the amount
payable to the non-resident, and art. 169.4 has it pay that VAT with the
return of the month, the payment document standing for the electronic tax
invoice of art. 175 so that the same amount is offset. Since 1 January 2020
the operation occurs when the amount is paid to the non-resident, and the tax
is declared and offset in the return of that month. `AZ-P-18-NONRES` books
both halves: the tax calculated, credited to the new `5213` and declared in
line 306.1 (which line 326 adds), the offset, debited to `2411` and declared
in line 312 (inside line 317). Unlike the domestic purchase codes it is not
cash-based — a cash-basis tax takes one posting, and this one has two — so a
bookkeeper whose payment falls in another month dates the document on the
payment.

## What this pack cannot do

- **VAT deposit account (ƏDV depozit hesabı, art. 175).** A buyer may deduct
  input VAT only if, within one business day of paying the supplier, the VAT
  part was paid by non-cash transfer into the supplier's *VAT deposit account*
  (and the price into the supplier's bank account). The engine has no
  destination-specific payment rule: it deducts when the invoice is paid, and
  cannot check that the VAT part went to the deposit account. Account 226 exists
  in the chart for the holder's side, and it is not reconcilable. A user must
  keep this check outside the books.
- **"ƏDV geri al" (art. 165.5, extended in 2026).** A consumer-side refund of
  17.5 % of the VAT paid by card and 5 % in cash on certain services. It is a
  mechanism between consumer and State; no tax is created for it, and the
  seller's side (return lines 319.2–319.4) is not modelled.
- **Real-time clearance of electronic invoices**, the monthly invoice for
  recurring services, and the simplified tax regime (a turnover tax that is not
  VAT) are outside the engine.
- **Partial deduction.** Art. 175.2–175.4 restrict deduction (exempt-only
  activity, mixed activity pro rata, entertainment). The form carries them as
  lines 313–315; the pack has no partly-recoverable tax for them.
- **Payment-dated tax on non-resident services.** `AZ-P-18-NONRES` (below)
  dates the tax on the document; the law dates it on the payment to the
  non-resident.
- **Agricultural trade margin (301.2, 301-2)**, increases and decreases of
  turnover (318–324), receivables movements (307), and the annexes to the
  return.
- **A 20 % line.** The 2026 form carries a line "ƏDV-nə 20 faiz dərəcə ilə
  tutulan əməliyyatlar" between lines 304 and 305; no source opened here says
  which operations it covers, so no tax was created for it.
- **Weekend deadlines.** A deadline falling on a non-working day moves to the
  next working day; the pack does not compute this.
- **Zero-rate and exempt bases** reach the return on the invoice date, not on
  collection.

## Checking this pack

`tests/golden.test.ts` replays the scenario in `golden/` — seven sales
documents (18 % paid in full, 18 % paid in two parts, export, exempt, a
zero-rated transport, a credit note, a sale never collected), five purchases
(paid in full, part paid, import, exempt, never paid) and a payment on account —
and compares the three monthly returns, the two statements and the trial balance
with figures worked out independently. The 18 % sale never collected and the
purchase never paid stay on 5212 and 2413 and appear in no return.
