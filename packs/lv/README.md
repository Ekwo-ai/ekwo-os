# Latvia

Everything Latvia adds to Ekwo, as data: a chart of accounts, the journals,
the PVN (VAT) rates and where each one posts, the boxes of the PVN
deklarācija, the bilance and the peļņas vai zaudējumu aprēķins of the annual
report, and the sentences the law puts on an invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Latvian accountant or zvērināts
revidents reading the pack can disagree with a specific sentence rather than
with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language: `lv`.** The pack's own labels are written in Latvian, which is
also the language of every text in the register below; no second language
file is declared.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and names the entry of `certification.sources` its article is in.

| What | Text | Publisher |
|---|---|---|
| PVN rates, exemptions, zero rate, reverse charge, registration threshold, tax period, invoice content | Pievienotās vērtības nodokļa likums | likumi.lv |
| The PVN deklarācija form and its annexes, filing procedure | Ministru kabineta 2013. gada 15. janvāra noteikumi Nr. 40 | likumi.lv |
| The line-by-line meaning of the form (row 40 through row 80) | VID metodiskais materiāls, updated 29.05.2026 | vid.gov.lv |
| Where the return is filed | Elektroniskā deklarēšanas sistēma (EDS) | eds.vid.gov.lv |
| Payment term, statutory default interest | Civillikums, Ceturtā daļa, 1668.² un 1765. pants | likumi.lv |
| Invoice numbering, structured e-invoicing (B2G and B2B), its dates | Grāmatvedības likums, 11. pants un pārejas noteikumi | likumi.lv |
| Chart of accounts (there is none), the balance sheet and income statement schemes | Gada pārskatu un konsolidēto gada pārskatu likums, 1. un 2. pielikums | likumi.lv |
| VAT category and exemption reason codes on an e-invoice | EN 16931, UNCL5305, VATEX | European Commission (docs.peppol.eu) |
| The ISO 6523 identifiers on a Peppol e-invoice | `0218` unified registration number, `0219` taxpayer registration code | docs.peppol.eu |

## The chart of accounts, and why this one

**Latvia prescribes no chart of accounts.** Grāmatvedības likuma 11. panta
pirmā daļa obliges every accounting entity to keep a set of internal
documents that includes its own "grāmatvedības kontu plāns", and nothing
more; there is no ministerial chart to transcribe.

What this pack does instead is follow the structure of the law that *is*
prescriptive: the balance sheet and income statement schemes of the Gada
pārskatu un konsolidēto gada pārskatu likuma 1. un 2. pielikums. Every
account is a four-digit, flat code (no parent, no heading), and the first
digit names the side of the scheme it belongs to:

- `1` Ilgtermiņa ieguldījumi (non-current assets, annex 1)
- `2` Apgrozāmie līdzekļi (current assets, annex 1)
- `3` Pašu kapitāls (equity, annex 1)
- `4` Uzkrājumi un ilgtermiņa kreditori (provisions and non-current
  liabilities, annex 1)
- `5` Īstermiņa kreditori (current liabilities, annex 1)
- `6`–`7` Ieņēmumi un izmaksas pēc to veida (revenue and expense items 1–8 of
  annex 2)
- `8` Finanšu ieņēmumi, finanšu izmaksas un uzņēmumu ienākuma nodoklis (items
  9–15 of annex 2)

`statements.json` maps each `code_range` straight onto its annex. Small and
micro companies are entitled by 56.–58. pantu to combine minor balance sheet
items into one line; this pack takes that same right, and presents each of
the annexes' top-level groups (I–IV of the assets side, the four blocks of
the liabilities side) as one statement line rather than every sub-item.

The two VAT posting accounts a rate uses (`5080` sales VAT, `2170` purchase
VAT, and their intra-Community pair `5085`/`2175`) are deliberately **not**
the accounts a company's PVN deklarācija is settled from: `5090`
(`tax_payable`) and `2180` (`tax_receivable`) are separate, reconcilable
accounts.

## The taxes

Nine codes. The standard rate is 21%, unchanged since 2013 (Pievienotās
vērtības nodokļa likuma 41. panta pirmās daļas 1. punkts). Two reduced
rates, both under 42. pantu: 12% (this pack's example is tourist
accommodation, 42. panta desmitā daļa — the article also covers medicines,
medical devices, infant food, district heating, wood fuel for households and,
since 1 January 2026, a list of fresh food staples) and 5% (books and press
in Latvian, Latgalian, Liivi or another EU/EEA/OECD official language, 42.
panta piektā un septītā daļa).

The zero rate (43. pants) is modelled for an export of goods (43. panta
pirmā daļa) and an intra-Community supply of goods (43. panta ceturtā daļa);
the freeport, new-means-of-transport, chain-transaction and humanitarian-aid
branches of the same article are not. The exemption (52. pants) is modelled
for the sale of used immovable property (52. panta pirmās daļas 24. punkts,
Directive 2006/112/EC art. 135(1)(j)); the same article's insurance and
financial-services exemptions (points 20–22) are not turned into a tax code.

The intra-Community acquisition of goods (5. panta pirmās daļas 3. punkts) is
modelled with three postings: a base, a payable leg and a fully offsetting
deductible leg, landing on boxes 50, 55 and 64.

A service bought from a supplier abroad — a software subscription, hosting,
an API — is supplied where the Latvian taxable person carries on its
business (19. panta pirmā daļa), and the recipient calculates and pays the
tax: 88. pants for a supplier that is a taxable person of another Member
State, 89. pants for one of a third country or territory. It declares it in
the return of the period in which the service was received (122. pants) and
deducts it as input tax (92. pants). Two codes carry it, because the
treatment differs even though the boxes do not: `LV-P-IC-SERV-21`
(`intracom_acquisition_services`, article 196 of Directive 2006/112/EC) and
`LV-P-3C-SERV-21` (`foreign_services_received`), both crediting the new
`5086` and declaring row 54 (added to `S`), and debiting the new `2156` and
declaring row 63 (added to 60). The golden year buys one of each. The chart
has no payable account for suppliers abroad, so a foreign supplier sits on
the trade payables with the others.

## The declaration

One form, `LV-PVN-DEKLARACIJA`, filed monthly or quarterly (115. pants —
monthly above a 50 000 euro threshold or for certain cross-border activity,
quarterly otherwise; this pack declares no `period_default`, because which
of the two applies is a fact about the company, not something the law
answers the same way for everybody). The deadline is the 20th of the month
following the period, in every case (118. panta pirmā daļa).

This pack models 22 of the form's boxes: the three taxable-base rows (41,
42, 42a for the law's 42.¹), the 0%-rate total and its two components (43,
45, 48a for the law's 48.¹), the exemption row (49), the intra-Community
acquisition base and its two tax rows (50, 55, 64), the reverse-charged
services rows (54, 63), the three tax rows on
domestic sales (52, 53, 53a for the law's 53.¹), the two deductible-input
rows this pack uses (60 as their sum, 62, 64), and the final rows (P, S, 70,
80). Row identifiers with a decimal point in the official form (42.¹, 48.¹,
53.¹) are written here as `42a`, `48a`, `53a`, because a box identifier in
this format is `[0-9A-Za-z]` only.

**Not modelled**, and left as a gap rather than guessed at: row 41.¹ (the
margin-scheme value for used goods, art works, collectors' items and
antiques), row 48.² (services whose place of supply is outside Latvia), the
freeport and new-means-of-transport rows (44, 46, 47), rows 56/56.¹ (reduced-rate intra-Community
acquisitions), row 57 and rows 66/67 (the non-deductible input proportion
and bad-debt corrections — meaning `(P)` in this pack is simply row 60, with
no proportion or correction applied), and the annexes PVN 1 through PVN 7,
which break the same figures down further but add no box this pack's taxes
post to.

## E-invoicing

`peppol-bis-3`, built on EN 16931, which is the standard Grāmatvedības
likuma 11. panta četrpadsmitā daļa itself names (LVS EN 16931-1:2017); the
law prescribes no single network, and a structured invoice may travel over
the state e-adrese or a commercial Peppol access point.

The obligation is genuinely two dates, not one, and this pack keeps only the
later, economy-wide one in `einvoicing.mandatory_from`:

- **B2G**, invoices to a budget institution, in force since 1 January 2025,
  with a grace period to 1 January 2026 for contracts concluded before 31
  December 2024 (pārejas noteikumu 9. punkts).
- **B2B**, invoices between two Latvia-registered companies that are not
  budget institutions, legislated but not yet in force: 1 January 2028
  (pārejas noteikumu 8. punkts, as amended 5 June 2025 — the date was
  originally 1 January 2026 and was pushed back by that amendment).

Structured-invoice **data reporting** to VID is a separate, later obligation
again: 1 January 2026 for B2G, 1 January 2028 for everyone else (pārejas
noteikumu 10. punkts). `country_defaults` carries no column for that third
date; it is recorded here so the three 2026/2028 dates can be told apart.

## What this pack does not do yet

- **Domestic reverse charge** (construction services, 142. panta ceturtā
  daļa; and the timber, mobile-phone/electronics and cereals regimes of
  143.¹–143.⁴) is not modelled: no tax code, no box.
- **The margin scheme** for used goods, art works, collectors' items and
  antiques (138. pants, row 41.¹) is not modelled.
- **The non-deductible input VAT proportion** (98. pants) and **bad-debt
  corrections** (67. rinda) are not modelled; `(P)` in this pack's
  `tax_report.json` is simply row 60.
- **Advance payments** are not specially handled: `documents.tax_point` is
  declared `delivery_date` (31. un 32. pantu), and Ekwo has no prepayment
  document through which a payment-first tax point could be exercised.
- **Corporate income tax on distributed profit** (Uzņēmumu ienākuma nodokļa
  likums) is out of scope of a PVN pack; account `8210` exists in the chart
  for the day a company distributes a dividend, and nothing in this pack
  computes what it should hold.

A qualified Latvian accountant or zvērināts revidents should read the rates,
the exemption and the declaration boxes above against the current law before
any company relies on this pack to file.
