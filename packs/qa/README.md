# Qatar

Everything Qatar adds to Ekwo, as data: a chart of accounts, the journals, the
two "not subject" tax codes that carry every sale and purchase a Qatari
business books, and the statement of financial position and statement of
profit or loss of IFRS Accounting Standards. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Qatari accountant can
disagree with a specific sentence rather than with the whole of it.

**Status: `community`.** Nobody who practises in Qatar has reviewed it. The
figures are replayed against a year of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

**Qatar has no value added tax in force.** So the pack has no
`tax_report.json`, no tax-clearing account, no
`tax_payable` / `tax_receivable` role. What a reviewer should know is that
this is a **current** state and not a permanent one — see "VAT and
e-invoicing: what to watch".

## Sources

The register in `pack.json` holds ten texts.

| What | Text | Where |
|---|---|---|
| No VAT law; the laws that are in force | General Tax Authority, list of tax laws | `gta.gov.qa/en/laws` |
| Income tax 10 %, exemptions, 5 % withholding tax, accrual accounting under international accounting standards (art. 6), accounting books (art. 12), tax year = 1 January – 31 December (art. 1) | Law No. 24 of 2018 (Income Tax Law) | `gta.gov.qa/assets/pdf/…Income Tax Law…` |
| Books to keep (art. 35), retention for ten years following the year (art. 36(1)) | Executive Regulations of the Income Tax Law, 2024 edition | `gta.gov.qa/assets/pdf/Income Tax Law EN 2024.pdf` |
| Excise tax | Law No. 25 of 2018 and its Executive Regulations, 2024 edition | `gta.gov.qa/assets/pdf/Excise Tax Law EN 2024.pdf` |
| Sugar-content excise on sweetened drinks, from 6 July 2026 | Law No. 2 of 2026 (General Tax Authority news item) | `gta.gov.qa/en/media-center/news/…` |
| Global minimum tax (15 %), fiscal years beginning on or after 1 January 2025 | Council of Ministers Resolution No. 2 of 2026 | `gta.gov.qa/assets/pdf/EN Qatar Pillar Two…pdf` |
| Financial year of twelve months (art. 182), balance sheet and profit and loss account to the auditor (art. 183) | Commercial Companies Law, Law No. 11 of 2015 | unofficial English translation, see below |
| 5 % GCC customs tariff | Invest Qatar, *Customs* | `invest.qa` |
| Draft e-invoicing law | EY Tax Alert on the Council of Ministers' decision of 6 May 2026 | `ey.com` |
| Where returns are filed | Dhareeba, the General Tax Authority's portal | `dhareeba.gov.qa` |

**Secondary sources.** The Commercial Companies Law is cited from an
unofficial English translation published by a law firm, and its amendment by
Law No. 8 of 2021 from secondary summaries. That no e-invoicing law has been
published rests on the absence of any report of publication, not on the
Official Gazette itself. The 6 May 2026 decision is cited through the EY alert,
not the Council's own release. The Commercial Code and Civil Code are not
cited.

## The chart of accounts, and why this one

Qatar prescribes no chart of accounts. The Income Tax Law
requires books and records kept in accordance with the laws of the State and
international accounting standards, and its Executive Regulations name the
general journal, the general ledger and the inventory book. So the chart is
written, not transcribed: four digits, flat, blocked by class so that each
range reaches one line of the two statements. 107 accounts, including the
ones a Qatari bookkeeper reaches for: income tax provision and income tax
paid in advance, withholding tax payable on payments to non-residents (and the
withholding credits receivable), excise tax, customs duties and other
government charges payable, an end-of-service gratuity payable and expense,
and commercial registration and licence fees.

The account names are English. Arabic is the language of the laws and
`defaults.language`, but this pack did not produce its own Arabic accounting
terminology: see [`i18n/README.md`](i18n/README.md).

## Taxes, and the absence they represent

Two codes, both at 0 %, both `not_subject`: `QA-S-NA` on every sale and
`QA-P-NA` on every purchase, domestic, exported or imported. Qatar signed the
Unified VAT Agreement of the GCC States (5 % standard rate, December 2015) but
has published no national VAT law; the General Tax Authority's list of tax
laws lists the VAT only as a regional agreement. There is only commentary
that one is expected (the IMF urged it in February 2026; the finance minister
has said Qatar plans it): none of that is law. `vat_category` is `O` and
`exemption_code` is null.

## What this pack does not carry (levies outside the pack)

- **Income tax** — Law No. 24 of 2018, art. 9: 10 % of taxable income. Income
  of Qatari natural persons and the Qatari share of wholly or partly Qatari
  companies is exempt, so in practice the tax falls on the non-Qatari share.
  A tax on the year's profit, filed on Dhareeba; the chart has the provision
  and the charge accounts, nothing computes it.
- **Withholding tax** — art. 9, clause 2: final 5 % on royalties, interest,
  commissions and fees for services performed wholly or partly in the State
  and paid to non-residents without a permanent establishment, subject to tax
  treaties. Accounts 2065, 1170 and 6475 exist for it; nothing computes it.
- **Global minimum tax** — Resolution No. 2 of 2026: 15 % top-up (income
  inclusion rule and domestic minimum top-up tax) for groups with consolidated
  revenue of EUR 750 million or more, fiscal years beginning on or after 1
  January 2025.
- **Excise tax** — Law No. 25 of 2018 (in force since 1 January 2019) on
  specified goods; Law No. 2 of 2026 moved sweetened drinks to a tier by sugar
  content from 6 July 2026. A levy on those goods, not an invoice tax.
- **Customs duty** — 5 % ad valorem on the CIF value of general goods under
  the GCC customs union, with higher and exempt categories (Invest Qatar; the
  General Authority of Customs tariff itself should be checked).
- **Zakat**, where it applies, and **social-insurance contributions**: not
  covered, no account or code.
- **`fixed_assets.json`**, **XBRL fact keys** and **bank formats**: none.

## The statements

`statements.json` carries a statement of financial position and a statement of
profit or loss on the minimum line items of IAS 1 (paragraph 54; current and
non-current presented separately, paragraph 60). The Income Tax Law points to
"international accounting standards" and the Commercial Companies Law, as read
through a translation, to internationally approved accounting principles; this
pack did not establish whether non-listed companies apply full IFRS Accounting
Standards or IFRS for SMEs, and models the presentation common to both. Other
comprehensive income is not modelled. IFRS 18, which replaces IAS 1 for periods
from 1 January 2027, is not modelled.

## Closing the year

`fiscal_year_default` is `calendar`. The Income Tax Law (art. 1) defines the
tax year as 1 January to 31 December and article 5 makes the accounting period
the tax year, with a different period possible only with the Authority's
approval. `closing_style` is `retained_earnings`.

## On the invoice

`numbering` is `free` and `number_format` is a proposal: this pack found no
Qatari tax-invoice regime, since there is no turnover tax. What the law fixes
is the retention of books, records and documents at the place of business for
ten years following the year to which they relate (Executive Regulations of
the Income Tax Law, art. 36(1)). No payment term or late-payment interest was
found. `tax_point` is `invoice_date`, a convention and not a rule. No mention
is declared: this pack found no text or established usage it could cite for a
mandatory invoice mention.

## VAT and e-invoicing: what to watch

On 6 May 2026 the Council of Ministers approved a **draft** law on electronic
invoicing and its implementing regulations. It still has to go through the
Shura Council and receive the Amir's assent, and there is no report of
its promulgation or publication in the Official Gazette. `einvoicing.obligation`
is therefore `none` and no profile is named. Commentary expects a phased start
from 1 January 2027, large taxpayers first: that is an expectation, not a date.
If the law is published, or a VAT law with it, this pack needs a new version:
real tax codes, a return, and the roles `tax_payable` and `tax_receivable`.

## Reviewing this pack

Open an issue titled "Review: Qatar". Points a Qatari accountant should read
first:

1. The Arabic account and statement terminology (none supplied).
2. Whether non-listed companies report under full IFRS or IFRS for SMEs, and
   the statement layout expected by the Ministry of Commerce and Industry.
3. Whether the chart should carry zakat and social-security accounts.
4. The state of the e-invoicing law and of any VAT law at the time of review.
5. The treaty and exemption treatment of the 5 % withholding tax.
6. The Commercial Companies Law references (read in translation).
