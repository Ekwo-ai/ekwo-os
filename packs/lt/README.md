# Lithuania

Everything Lithuania adds to Ekwo, as data: a chart of accounts, the journals,
the PVM (VAT) rates and where each one posts, the boxes of declaration form
FR0600, the balance sheet and the income statement, and the sentences the law
puts on an invoice. The format is [`docs/packs.md`](../../docs/packs.md); this
file says where the content came from and which decisions it rests on, so that
a Lithuanian accountant reading the pack can disagree with a specific sentence
rather than with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right. **Language: `lt`.** Lithuania prescribes no chart of accounts (see
below); every label in this pack is written in Lithuanian.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`.
These are the texts the pack as a whole rests on; the full register, with
URLs and consultation dates, is `pack.json`'s `certification.sources`.

| What | Text | Where |
|---|---|---|
| PVM rates, exemptions, the reverse charge, deduction limits, the tax point | Pridėtinės vertės mokesčio įstatymas (PVMĮ), Nr. IX-751, and the VMI's own article-by-article commentary | `vmi.lt` (commentary PDF, updated 2026-09-23); consolidated law text at `e-seimas.lrs.lt/portal/legalAct/lt/TAD/TAIS.163423` |
| Form FR0600 and its completion instructions | VMI viršininko 2004-03-01 įsakymas Nr. VA-29, and its explanatory memo KM1739 | `e-seimas.lrs.lt/portal/legalAct/lt/TAD/TAIS.229389`; `vmi.lt` (KM1739 PDF) |
| Chart of accounts, general accounting rules | Finansinės apskaitos įstatymas (FAĮ), Nr. IX-574 | `e-seimas.lrs.lt`, consolidated edition from 2025-05-01 |
| The AVNT indicative chart of accounts | „Pavyzdinis sąskaitų planas“, patvirtintas AVNT direktoriaus 2015-04-13 įsakymu Nr. VAS-15 | `avnt.lt` |
| The statutory balance sheet and income statement schemes | Verslo apskaitos standartai VAS 2 „Balansas“ and VAS 3 „Pelno (nuostolių) ataskaita“ | `avnt.lrv.lt` — see "Reviewing this pack" |
| Payment term, late-payment interest, recovery costs | Mokėjimų, atliekamų pagal komercinius sandorius, vėlavimo prevencijos įstatymas, Nr. IX-1873 | `e-seimas.lrs.lt`, consolidated edition from 2017-07-01 |
| E-invoicing (B2G) | Viešųjų pirkimų įstatymo 22 straipsnio 3 dalis; Finansinės apskaitos įstatymo 6 straipsnio 4 dalis | `e-seimas.lrs.lt` |
| The ISO 6523 identifiers, EN 16931, UNCL5305, VATEX | Peppol code lists, published by the European Commission | `docs.peppol.eu` |

## The chart of accounts, and why this one

**Lithuania prescribes no chart of accounts for a private company.** FAĮ
article 2(3) defines a chart of accounts as simply "the list of accounts an
entity uses", and article 8(1) leaves the number, composition and form of
accounting registers to the entity itself. Article 12(5)(2) reserves a
*mandatory* general chart for public-sector entities only; for everyone else,
article 12(6)(1) has AVNT publish a **non-mandatory, indicative** chart of
accounts, which Lithuanian accounting practice widely follows.

This pack's chart follows that indicative chart's **class structure** —
`1` non-current assets, `2` current assets, `3` equity, `4` payables and
liabilities, `5` income, `6` expenses (the AVNT plan's classes `7`–`9`, for
management accounting, and `0`, for off-balance items, are not carried here) —
but the account numbers themselves are this pack's own, each assigned to
reach a line of `LT-VAS-BS` or `LT-VAS-IS`. A reviewer with the AVNT plan
should check this chart against it account by account.

**Flat.** No parent accounts: every account here is a leaf, and the grouping
is done by the `code_range` rules of `statements.json`.

**PVM held apart, split by side.** `2210` (pirkimo PVM — input) and `4400`
(pardavimo PVM — output) are kept separate rather than netted, which is what
`4430` (`tax_payable`) and `2200` (`tax_receivable`) exist for: the balance a
filed FR0600 return settles to, apart from the accounts the taxes post to and
reconcilable.

## Taxes

A code is a rate at a date, and a new rate is a new code with a `valid_to` on
the old one. **2026-01-01 rewrote the reduced-rate structure of PVMĮ article
19(3)**, in force on the day this pack is released:

| Rate | Applies to | In force |
|---|---|---|
| 21 % | everything not listed below | from 2009-09-01 (raised from 19 %) |
| 12 % (new) | accommodation, scheduled passenger transport, access to art and culture institutions and events | from 2026-01-01 |
| 9 % (retired) | the same three categories, plus district heating and books/non-periodical publications, under the pre-2026 wording | until 2025-12-31 |
| 5 % | medicines and medical devices (since 2004), technical aid devices for the disabled (since 2013), newspapers and magazines (since 2019/2021), and — new from 2026-01-01 — printed and electronic books and non-periodical informational publications | from 2004-01-01, category by category |

**`LT-S-09` and `LT-P-09` intentionally approximate their `valid_from`.** The
9 % rate covered several categories that entered it at different dates over
more than a decade; `valid_from` marks the earliest date confirmed rather
than a category-specific date. Likewise, `LT-S-05` / `LT-P-05` model the
**current** (2026-01-01 onward) scope of the 5 % rate as a single code; an
earlier period would need one code per category, which this pack does not
provide.

**The 96-article domestic reverse charge** (`LT-S-PM` / `LT-P-PM`) covers
construction works (PVMĮ 96 straipsnio 1 dalies 3 punktas, in force since
2015-07-01 with no end date) and ferrous/non-ferrous metal waste and scrap
(96 straipsnio 1 dalies 4 punktas). **Form FR0600 gives the buyer no
taxable-value box for this case**: the seller alone declares the value, in
box 12; the buyer declares only the self-assessed tax, in box 33. `LT-P-PM`
therefore carries no `base` posting at all, a feature of this form and not an
omission.

**Box 25 is gross, box 35 is net.** FR0600 asks for the *full* purchase VAT
incurred in box 25 and the *actually deductible* share in box 35 — the two
differ whenever a restriction applies. `LT-P-REPR` (representation costs,
50 % deductible under the box 35 instructions) and `LT-P-ND` (entertainment
costs that do not qualify as representation expenses under income-tax law,
0 % deductible) both post the full amount to box 25 and only the deductible
share to box 35, through a second `tax` posting with `factor: 0` (no ledger
effect) that exists purely to carry the box 35 figure.

## Form FR0600

`tax_report.json` carries the declaration in the wording of VMI's KM1739
explanatory memo, including the new field **29A**, added from 2026-01-01 for
the 12 % rate by VMI viršininko 2025-12-22 įsakymas Nr. VA-129.

**No `period_default`.** Secondary sources agree the ordinary period for a
legal entity is the calendar month, with a quarterly election available under
a turnover threshold; the primary text was not confirmed. This pack declares
`period: ["month", "quarter", "half_year"]` with no proposed default: the
cadence follows a fact about the company rather than one answer the law gives
everybody.

**One box, both directions.** Box 36 carries the amount payable *or*
refundable with a sign; `LT-FR0600`'s box 36 therefore carries no
`floor_zero`.

**Tax boxes summed, not computed.** Boxes 29, 29A, 30, 31, 32, 33 and 34 are
declared `kind: "tax"` and summed from what the documents' postings actually
wrote, not computed as a rate applied to a base box: the pack format carries
no expression language, and the VAT the documents posted is the closer figure
to what a real ledger holds.

## The tax point

PVMĮ article 14(1)–(2) makes the tax point the day the PVM invoice is issued,
and only where none is issued falls back to the earliest of delivery or
payment. **The pack format's closed vocabulary of five words has none that
names exactly this rule** — `invoice_date` says "the invoice fixes it, and
nothing displaces it", which is not quite true (a residual no-invoice branch
exists), while `invoice_if_issued` says the opposite shape (supply is the
principle, invoice is the derogation). This pack declares `invoice_date`,
because a Lithuanian PVM payer issues an invoice for practically every supply
(article 80 requires one), and documents the full two-branch rule in
`documents.references.tax_point.legal_reference`. See
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet)
for the gap this leaves in the core vocabulary.

## Electronic invoicing

**Mandatory for the public sector, not between companies.** Since
2024-09-01, a public procuring entity must accept and process electronic
invoices submitted through SABIS (which replaced the earlier "E. sąskaita"
system), and — where an invoice does not conform to EN 16931 — will accept it
*only* through that system (Viešųjų pirkimų įstatymo 22 straipsnio 3 dalis;
Finansinės apskaitos įstatymo 6 straipsnio 4 dalis). No statute obliging
electronic invoicing between two private companies was found as of this
pack's `released_at`, so `einvoicing.obligation` is `none`. `profile` still
names `peppol-bis-3`, the format SABIS itself exchanges; `party_scheme` and
`vat_scheme` are left null, because whether SABIS addresses a Lithuanian
party by a four-digit ISO 6523 scheme is not confirmed.

## What this pack does not carry

- **i.SAF and i.VAZ**, the invoice and waybill registers of the i.MAS system
  (VMI viršininko 2016-09-28 įsakymas Nr. VA-119): a **reporting channel**
  that changes no posting, no box and no rate, which the pack format does not
  describe.
- **Triangulation** (FR0600 box 22): no tax code reaches it, though the box
  is declared for completeness.
- **The margin scheme** (box 16: travel agents, second-hand goods, art and
  antiques) and **self-supply for private use or self-constructed fixed
  assets** (boxes 14 and 15).
- **Import VAT** (boxes 26 and 27) and the **mixed-activity deduction
  proportion** (box 28). The golden scenario has no import and no mixed
  activity.
- **The XBRL / iXBRL fact keys of the annual report** (filed through the
  Centre of Registers, JADIS): no verifiable per-line mapping, so `xbrl` and
  `taxonomy` are left null; a wrong key is worse than no key.
- **The fixed assets module.** There is no `fixed_assets.json`.

## Reviewing this pack

Open an issue titled "Review: Lithuania". What a review is, and what it is
not, is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and
who may say what". The points a reviewer is most likely to disagree with: the
account-by-account content of the AVNT indicative chart (this chart follows
its classes, not its accounts), the statutory line labels of VAS 2 and VAS 3,
which should be checked against the standards' own text, the
`period_default` gap on the FR0600 declaration, and the `tax_point` word
chosen for PVMĮ article 14.
