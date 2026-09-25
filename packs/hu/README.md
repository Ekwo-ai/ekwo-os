# Hungary

Everything Hungary adds to Ekwo, as data: a chart of accounts built on the
structure the accounting law prescribes for the balance sheet and the income
statement, the journals, the VAT rates and where each one posts, the boxes of
the periodic VAT return, the mérleg and the eredménykimutatás of the
accounting law, and the sentences the law puts on an invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Hungarian accountant or
adótanácsadó reading the pack can disagree with a specific sentence rather
than with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a quarter of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language: `hu`.** The pack's own labels are written in Hungarian, which is
also the language of every text in the register below; no second language
file is declared.

## Sources, and how they were read

Every rate, box, mention and statement line carries its own `legal_reference`
and names the entry of `certification.sources` its article is in. The
register holds thirteen texts.

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, reverse charge, deduction, invoice particulars, tax point, numbering | 2007. évi CXXVII. törvény az általános forgalmi adóról (Áfa tv.) | net.jogtar.hu |
| Books, the mérleg and the eredménykimutatás, the monetary unit | 2000. évi C. törvény a számvitelről | net.jogtar.hu |
| The cadence of the VAT return | 2017. évi CL. törvény az adózás rendjéről (Art.), 2. melléklet I./B./3. pont | net.jogtar.hu |
| Payment term of a debt with no agreement | 2013. évi V. törvény (Ptk.), 6:130. § | net.jogtar.hu |
| Cash rounding to the nearest 5 forint | 2008. évi III. törvény | net.jogtar.hu |
| The boxes and their instructions | 2665 számú áfabevallás és kitöltési útmutatója (2026) | Nemzeti Adó- és Vámhivatal (NAV) |
| Overview pages confirming rates, the small-business threshold, the real-time invoice-data obligation | nav.gov.hu | NAV |
| Where the real-time invoice data is filed | Online Számla | NAV |
| Code lists | EN 16931, UNCL5305, VATEX, EAS | European Commission / OpenPeppol |

**`net.jogtar.hu` is the consolidated text this pack reads, not `njt.hu`.**
Hungary's own Nemzeti Jogszabálytár (njt.hu) is the government's primary
publication of a consolidated text; every attempt to reach it from the
network this pack was written on timed out. `net.jogtar.hu` is the
Wolters Kluwer Hatályos Jogszabályok Gyűjteménye, prepared with the Ministry
of Justice and the register a Hungarian practitioner opens daily; it answered
every request made of it, but its own extraction by this pack's tooling broke
off partway through several long statutes — the Áfa tv. past roughly its
sixty-fourth paragraph on more than one attempt, and the Ptk. before its
Sixth Book (Hatodik könyv), where payment terms are fixed. Two consequences,
named article by article below rather than smoothed over: a handful of
articles (142. §, 124–125. §, 6:130. §) are sourced through concordant
professional secondary literature rather than through a direct reading of
their own text on `net.jogtar.hu`, and njt.hu should be the first thing a
reviewer checks from a network where it answers.

## The chart of accounts, and why this one

**Hungary prescribes no numbered chart of accounts.** Article 14 of the
accounting law obliges every undertaking to draw up, in writing, its own
accounting policy and — fitted to it — its own account plan (számlarend); the
law fixes no national list of account codes, unlike France's PCG or Belgium's
PCMN. What it does fix, in article 22 and the 1. számú melléklet, is the
structure the mérleg (balance sheet) must be presented in — version "A" or
"B" — and, in article 71 and the 2. számú melléklet, one of the two versions
the eredménykimutatás (income statement) may take by nature of expense
(összköltség eljárás, this pack's choice) or by function (forgalmi költség
eljárás, the other one, not modelled).

So this pack's `accounts.csv` is its own convention, built to read onto those
two structures cleanly and not a text to cite on its own: the leading digit
of every code is the letter of the mérleg or the eredménykimutatás heading it
belongs to — `1` A) Befektetett eszközök, `2` B) Forgóeszközök, `3` C) Aktív
időbeli elhatárolások, `4` D) Saját tőke, `5` E) Céltartalékok, `6` F)
Kötelezettségek, `7` G) Passzív időbeli elhatárolások, `8`–`9` the lines of
the 2. számú melléklet. A reviewer should read the *statement lines* against
the law and the *account codes* against nothing but internal consistency —
this is said once here, following the same pattern already used by
`packs/at`, `packs/it` and `packs/pl` for a country whose own law prescribes
no chart.

**The result of the year sits directly in equity, with no mérleg szerinti
eredmény account of its own.** Before the 2016 reform that transposed
Directive 2013/34/EU, the balance sheet carried a distinct line, mérleg
szerinti eredmény, computed from the year's profit after a proposed dividend;
since then the eredménykimutatás's own last line, adózott eredmény (profit
after tax), is what the balance sheet's equity heading D) VII shows directly,
and a dividend decided in a later year is booked in the year of that
decision rather than restating the year it was earned in. That is a
current-year result sitting on the balance sheet until the shareholders'
meeting disposes of it — the same shape France's 120/129 is, and the reason
this pack declares `closing_style: result_accounts` rather than
`retained_earnings`, with accounts `4710` (profit) and `4720` (loss) as the
two the style requires.

## The currency, and its rounding

**`HUF` is added to `00_currencies.sql` at two decimal places, following ISO
4217** — the same list every currency of this repository is read from, list
one as SIX Financial Information publishes it. That is not the same claim as
"the forint is used with two decimals in Hungary": the last fillér coin (the
50 filléres piece) was withdrawn from circulation on 30 September 1999, no
subdivision of the forint has circulated since, and the accounting law's own
article 20 (2) requires the figures of an annual financial statement to be
stated in whole thousands of forints (or millions, above a 100-billion-forint
balance sheet total) — never in fillér. What the forint still has, and what
this pack does carry, is a **cash-rounding rule**: since the 1- and
2-forint coins were withdrawn, 2008. évi III. törvény requires the *total* of
a cash payment — never an individual line — to be rounded to the nearest 5
forint (0.01–2.49 down to 0, 2.50–4.99 up to 5, 5.01–7.49 down to 5,
7.50–9.99 up to 10), a difference the law itself excludes from the VAT base.
`defaults.cash_rounding_unit` is `5` for that reason; `rounding_method` is
`half_up`, the value every neighbouring pack in this repository declares,
absent a Hungarian rule that says otherwise.

## The taxes

Fifteen codes: three positive rates (27%, 18%, 5%), four zero-rated or
exempt sale codes, a domestic reverse charge on each side, and five
purchase-side codes for the deduction and for the three shapes of
self-assessment this pack carries.

**27% is the highest standard VAT rate in the European Union** (Áfa tv. 82. §
(1)). The two reduced rates are narrower than a simple "food and books"
reading: 18% (82. § (3), 3/A. számú melléklet) reaches milk and dairy
products other than raw milk, bakery products, and catering/accommodation
services; 5% (82. § (2), 3. számú melléklet) reaches raw milk itself, a
narrower list of staple foods, medicines, books, and district heating, among
others. `HU-S-18` and `HU-S-5` each carry `conditions: ["supply_nature"]`
rather than trying to enumerate every position of an annex in a `description`
field.

**The domestic reverse charge modelled is construction-assembly work subject
to a building permit or a notification procedure** (Áfa tv. 142. § (1) b),
the paragraph this pack's own reading of a private reproduction of the
consolidated text and the NAV 2665 guide's own footnotes agree on). Article
142 names nine more categories this pack does not carry — the forced sale of
a distrained asset, the sale of specified scrap and waste metals and
materials (6. számú melléklet), the sale of a building or building land
under an option for taxation, the sale of an asset pledged as security in
enforcement, transactions of a taxpayer under insolvency, greenhouse-gas
emission quota sales, and the sale of specified cereals, oilseeds
(6/A. számú melléklet) and steel products (6/B. számú melléklet) — because no
source consulted while writing this pack gave a fully citable, internally
consistent letter-by-letter list for all of them: one source found while
researching this pack cites a "142. § (1) k)" the private reproduction this
pack read does not carry. A reviewer extending this list should read
article 142 directly on njt.hu or net.jogtar.hu rather than trust either
secondary source alone.

**Three shapes of self-assessment, one simplified deduction box.** A service
received from a supplier established in another Member State
(`HU-P-EUDL-27`), from a supplier established outside the Union
(`HU-P-FOREIGN-27`), and a domestic reverse-charge purchase
(`HU-P-RC-27`) each book their own output-side self-assessed tax to their
own box (`18B`, `27`, `29`) — but their *deductible* leg all land on one box,
`64`, alongside the ordinary domestic purchases (`HU-P-27`, `HU-P-18`,
`HU-P-5`). The 2665 return in fact spreads the deductible side over several
rows (64., 65., 66. and 68. sor, which the guide's own formula sums into row
109) rather than one; which of those four rows each shape of self-assessment
belongs on could not be confirmed from the pages of the guide this pack's
research reached. Coarsening every deductible amount onto `64` keeps the
ledger and the golden's figures correct — the deduction right itself is not
in question, only which printed row states it — and is flagged here rather
than guessed at row level. See "Before this pack is `reviewed`" below.

**The passenger-car block is not sourced to the law's own text.** `Áfa tv.
124. § (1) d)` denies the deduction of VAT on the acquisition of a
passenger car (persongépkocsi, tariff heading 8703) outright, with the
exceptions of `125. §` (resale, taxi, driving-school and some leased
vehicles) left unmodelled; both articles are cited from concordant
professional literature, not from a direct reading of net.jogtar.hu, whose
extraction of the Áfa tv. broke off before reaching them.

## The return

`HU-AFA-2665` is the 2665 form for the 2026 filing periods, as read from its
own kitöltési útmutató. Three things about it are worth knowing before
reading the boxes themselves.

**Row 36 prints a base and a tax column under one row number, and a `total`
box cannot hold two formulas.** The guide's own words are explicit — "Ebben a
sorban kell összesíteni adóalap és adó bontásban a 01-35. és 110. sorokban
található részösszegeket" ("this row sums, split into base and tax, the
partial totals found in rows 01–35 and 110") — so this pack, following the
Italian pack's `VE30C2`/`VE30C3` convention of a letter suffix where the
schema's colon qualifier cannot reach (a colon separates a box from its
*kind*, not two different totals under one box), spells the two columns
`36ALAP` and `36ADO`. Row `110` (domestic sales taxed at a genuine 0% rate
under 82. § (4)) is not modelled: no source consulted gave a citable account
of which supplies that domestic zero rate actually reaches, beyond a NAV
2026 change note about prescription medicines from 1 September 2026 that
arrived too late in the research for this pack's `released_at` and whose own
underlying article was not confirmed.

**Box `85`, the return's final settlement line, is modelled as one signed
total rather than as a pair.** The guide names row 85 "visszaigényelhető
[…] adó" (reclaimable […] tax) and describes conditions under which part of
a negative balance can actually be reclaimed rather than only carried
forward — conditions this pack does not model, the same way `packs/pl`
leaves its own carry-forward and refund-election boxes unposted. Whether the
form prints a *separate* row for a positive ("fizetendő", payable) balance
could not be confirmed from the pages of the guide reached during research.
Rather than invent a row number for it, this pack follows the shape
`packs/at`'s own Kennzahl 095 already uses in this repository — one signed
total, a surplus coming out negative — and says so here rather than silently
assuming it. **This is the single largest fact a reviewer should verify
before this pack moves past `community`.**

**No `deadline` is declared, and no `period_default` is proposed.** The 2665
guide states three different deadlines for three different cadences — the
20th of the following month for a monthly or a quarterly filer, but the
25th of *February* of the following year for an annual filer, which is more
than one calendar month past the period's end and fits none of
`tax_report.json`'s three deadline rules, the same shape `packs/at` and
`packs/it` already met and left undeclared rather than approximate. Which
cadence a company files on is itself not one answer the law gives everybody:
`Art.` 2. melléklet I./B./3. pont sets it from a threshold on the
*company's own* VAT balance and turnover two years prior, not from a rule
every new filer starts under — the same reasoning `packs/at` and `packs/lu`
already apply to their own thresholded cadences.

## Invoices

- **Numbering**: `gapless_per_year`. Áfa tv. 169. § (1) b) requires a
  serial number that is unique, **continuous and gap-free** — stricter than
  Austria's own uniqueness-only reading of its UStG — and a numbering
  program has to guarantee that automatically.
- **Tax point**: `earliest_of_delivery_or_payment` — completion of the
  supply is the principle (55. § (1)), displaced to the date of receipt for
  any part paid in advance (59. §). The special rule for continuous supplies
  (58. §) is not modelled, the same gap `packs/at` and `packs/fr` each note
  for their own continuous-supply articles.
- **Payment terms**: 30 days by default (Ptk. 6:130. §), up to 60 unless the
  longer term is not manifestly unfair to the creditor given the contract's
  subject. See "Sources, and how they were read" above: this article's own
  text was not read directly.
- **Mentions**: fordított adózás for the reverse charge, and the wording of
  the small-business exemption (alanyi adómentesség) — 20 000 000 forints for
  2026, up from 18 000 000 in 2025 and rising by statute to 22 000 000 in
  2027 and 24 000 000 in 2028.

### E-invoicing and Online Számla

`einvoicing.obligation` is `none`: at this pack's `released_at`, no statute
obliges a Hungarian company to exchange a structured electronic invoice built
on the semantic model of EN 16931 with its counterparties, and a paper or PDF
invoice is unaffected by anything below. What *is* mandatory since
4 January 2021 is a third and different thing this format has no field for:
**real-time transaction reporting to the tax administration, running beside
an invoice that stays entirely between the parties.** Every invoice an Áfa
tv.-governed transaction requires must have its data reported to NAV's
Online Számla system — instantly, in XML, with no human step, when a
billing program issues it; the day after issue if hand-written and the VAT
charged reaches 500 000 forints, within four calendar days otherwise. This
is neither of the two shapes `docs/international.md` already tracks for
Poland's KSeF and Italy's SdI: those are **clearance** — the invoice itself
is not issued, or not received, until the state's own system has processed
it. Online Számla is **audit reporting** — the invoice is issued and
received exactly as it would be anywhere without such a system, and NAV only
receives a copy of its data, afterwards, for compliance purposes. See "From
Hungary" in [`docs/international.md`](../../docs/international.md) for the
gap this opens in the core.

`vat_scheme` is `9910`, Hungary's EAS code on the Peppol identifier list, kept
so a company that *does* choose to trade over Peppol can be addressed; `
party_scheme` is left null, because no ISO 6523 scheme for the Hungarian
company register number (cégjegyzékszám) could be confirmed and Hungarian
companies carry no compulsory network address between themselves.

## Before this pack is `reviewed`

A reviewer should look at these first, in roughly the order they matter:

1. **Box `85`**, modelled as one signed settlement line rather than a
   confirmed pair — the single largest unverified assumption of this pack,
   see "The return" above.
2. **The deductible-VAT box `64`**, coarsened from what the return's own
   109. sor formula shows is at least four rows (64., 65., 66., 68. sor).
3. **Article 142. § (1)**, read through a private reproduction of the
   consolidated text rather than net.jogtar.hu or njt.hu directly, with one
   letter ("k)") the NAV 2665 guide itself seems to cite and this pack's own
   source for the article's text does not carry.
4. **Ptk. 6:130. §** and **Áfa tv. 124–125. §**, sourced from concordant
   professional literature rather than a direct reading of net.jogtar.hu,
   which broke off before reaching either.
5. **The row-08 exemption's exact letter** (`HU-S-EXEMPT`, commercial
   property leasing) — Áfa tv. 86. § (1) is confirmed as the paragraph
   the NAV 2665 guide cites for this row, but the specific point letter for
   real-estate leasing was not confirmed from the law's own text.
6. **Row `110`** (a domestic 0% rate under 82. § (4)) is entirely
   unmodelled — see "The return" above.
7. **Six categories of article 142. § (1)** this pack does not model at
   all (distrained assets, scrap and waste metals, an optioned building or
   building-land sale, pledged-asset enforcement sales, insolvency sales,
   emission quotas, and specified cereals/oilseeds/steel products) — see
   "The taxes" above.
