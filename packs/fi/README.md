# Finland

Everything Finland adds to Ekwo, as data: a chart of accounts, the journals,
the VAT rates and where each one posts, the boxes of the periodic VAT return
(VSRALVKV, filed on OmaVero), the balance sheet and the income statement of
the annual accounts, and the sentences the law puts on an invoice. The format
is [`docs/packs.md`](../../docs/packs.md); this file says where the content
came from and which decisions it rests on, so that a Finnish accountant
reading the pack can disagree with a specific sentence rather than with the
whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

## Sources

Every rate, box, mention and statement line carries its own
`legal_reference`. These are the texts the pack as a whole was built from,
all consulted on 2026-09-25.

| What | Text | Where |
|---|---|---|
| VAT rates, exemptions, deduction, invoicing, the return | Arvonlisäverolaki (AVL) 1501/1993, consolidated | `finlex.fi/fi/laki/ajantasa/1993/19931501` |
| The 25,5 % rate | Laki 462/2024, voimaan 1.9.2024 | `finlex.fi` |
| The 24 % rate it replaced | Laki 706/2012, voimaan 1.1.2013 | `finlex.fi/fi/laki/alkup/2012/20120706` |
| The reduced-rate reform | Laki 691/2024 (14 %, voimaan 1.1.2025) ja laki 1358/2025 (13,5 %, voimaan 1.1.2026); laki 921/2024 (Yleisradion maksu, voimaan 1.1.2026) | `finlex.fi` |
| Form VSRALVKV and its box list | Verohallinto, data file description A86/200/2016, version 1.10 (27.2.2026) | `vero.fi/contentassets/.../vsralvkv_290824.pdf` |
| When the return is filed and paid | Laki oma-aloitteisten verojen verotusmenettelystä 768/2016, and Verohallinto's own page | `finlex.fi/fi/lainsaadanto/2016/768`; `vero.fi/en/.../when-to-file-and-pay/` |
| Chart of accounts, no statutory chart | Kirjanpitolaki (KPL) 1336/1997, 2 luku 2 § | `finlex.fi/fi/laki/ajantasa/1997/19971336` |
| Balance sheet and income statement schemes | Kirjanpitoasetus (KPA) 1339/1997, 1 luku | `finlex.fi/fi/laki/ajantasa/1997/19971339` |
| Payment term, late-payment interest, recovery costs | Korkolaki 633/1982; laki kaupallisten sopimusten maksuehdoista 30/2013; laki saatavien perinnästä 513/1999 | `finlex.fi` |
| Electronic invoicing | Laki hankintayksiköiden ja elinkeinonharjoittajien sähköisestä laskutuksesta 241/2019 | `finlex.fi/fi/laki/ajantasa/2019/20190241` |
| Peppol identifiers | OpenPeppol, Electronic Address Scheme code list | `docs.peppol.eu/poacc/billing/3.0/codelist/eas/` |

Finlex's own English rendering of the AVL is explicitly labelled an
unofficial translation, and this pack did not verify how current it is
against the 2024–2026 rate changes; every citation above was read on the
Finnish consolidated text.

## The chart of accounts, and why this one

**Finland prescribes no chart of accounts.** Kirjanpitolaki 1336/1997,
2 luku 2 § obliges every accounting entity to hold, for each financial year,
its own clear and sufficiently itemised list of accounts (*tililuettelo*)
explaining what each one holds — there is nothing to copy from a statute, and
nothing that could be called *the* Finnish chart, exactly the position
[Estonia](../ee/README.md) is in.

What **is** prescribed is the *presentation* of the annual accounts:
Kirjanpitoasetus 1339/1997, 1 luku 1 § sets out the *kululajikohtainen*
income statement scheme (by nature of expense — turnover, change in
inventories, materials and services, personnel costs, depreciation, other
operating expenses, financial items, appropriations, taxes), 2 § offers an
alternative *toimintokohtainen* scheme (by function) that this pack does not
carry, and 6 § sets out the balance sheet scheme. This chart follows a
widely taught Finnish convention that lines the account classes up with that
very scheme, so the annual accounts read straight off the chart:

- **One digit, one class.** `1` assets, `2` liabilities and equity together,
  `3` turnover and other operating income, `4` materials and external
  services, `5` personnel costs, `6` depreciation, `7` other operating
  expenses, `8` financial income and expenses, `9` appropriations and taxes.
  This is not the French or Belgian shape: equity sits in class 2 beside
  liabilities, the way Estonia's chart does too.
- **Flat.** No parent accounts; a chart entity groups by the head of the
  code, and the ranges of `statements.json` do the grouping.
- **A simplified reading of the KPA schemes.** Kirjanpitoasetus 1339/1997
  itemises equity into eight lines (share capital, share premium,
  revaluation reserve, fair value reserve, several kinds of reserve,
  retained earnings, the result of the year, subordinated loans) and vieras
  pääoma into ten (bonds, convertible bonds, loans, pension loans, advances,
  trade payables, bills payable, payables to group and to participating
  undertakings, other payables). This chart carries one account per KPA line
  it actually needs and folds the rest — pääomalainat, rahoitusvekselit, and
  the finer split of receivables into long- and short-term — into the
  nearest line it does carry. `statements.json` still declares the KPA
  headings a real chart would use (`FI-KPA-BS:5` Tilinpäätössiirtojen
  kertymä, `FI-KPA-BS:6` Pakolliset varaukset, kept apart from `D` Vieras
  pääoma, exactly where KPA 1339/1997 1 luku 6 § puts them), so a chart that
  does need the finer lines has somewhere in the scheme to post to.
- **One VAT account swings sides.** `2450` (output VAT) and `2455` (input
  VAT) are declared with a fixed `type`, but a company that files monthly
  can end a month with either in the opposite balance from the one its type
  suggests. Both statement lines that could hold them — `FI-KPA-BS:2.2`
  Saamiset ja siirtosaamiset (assets) and `FI-KPA-BS:8` Vieras pääoma,
  lyhytaikainen (liabilities) — carry an explicit `account_code` rule for
  each account, split by `side`, the mechanism `docs/packs.md` describes
  under "A sign belongs to a line summed from the ledger". `1590` and `2460`
  do not swing: they are the settlement accounts `tax_receivable` and
  `tax_payable` name, written only by `settle_filing()`.

The chart is written for this pack. It is not a copy of any published
chart; the KPA schemes are, and the account-class convention is the one
taught in Finnish bookkeeping courses and used as the default by several
Finnish accounting packages.

## Taxes

A code is a rate at a date, and a new rate is a new code with a `valid_to`
on the old one, never an edit.

| Rate | In force | Covers |
|---|---|---|
| 25,5 % | from 1.9.2024 (laki 462/2024) | the general rule, AVL 84 § |
| 24 % | 1.1.2013–31.8.2024 (laki 706/2012) | the general rule before it, kept for old documents and credit notes |
| 13,5 % | from 1.1.2026 (laki 1358/2025) | food, restaurant and catering services, animal feed, passenger transport, accommodation, medicines, books, sport and cultural events, works of art, copyright compensation, and — since 1.1.2026 — the Yleisradio television and radio fund contribution (AVL 85 §) |
| 14 % | 1.1.2025–31.12.2025 (laki 691/2024) | the same list at its earlier rate |
| 10 % | since 1.1.2025 in this narrowed form | newspapers and magazines, on paper or supplied electronically, only (AVL 85 a §) — the rate itself is not new for this group; the surrounding groups moved to 13,5 %/14 % in 2025, leaving only this one behind |
| 0 % | AVL 70 §, 72 a–72 b § | export outside the European Union, intra-Community supply of goods and services |

**No rate history before 1.1.2013 is modelled.** The reduced-rate
categories that existed before the 2025 reform — when transport,
accommodation, books, medicines, culture and sport sat at 10 % and only
food, restaurant services and animal feed sat at 14 % — are not modelled
either: reconstructing that narrower 2013–2024 scope with confidence was
outside what this pass verified, and a wrong scope is worse than a missing
one. A pack that needs to book a document from before 1.1.2025 at a reduced
rate has a gap here, named rather than guessed at.

**The deduction restriction on passenger cars is all-or-nothing, not
partial.** AVL 114 § 1 momentti 5 kohta refuses the deduction entirely
unless the car is exclusively used for resale, hire, passenger transport or
driving instruction — there is no Belgian- or Estonian-style 50 %
apportionment in Finnish law. `FI-P-AUTO-ND` therefore carries a single
`tax_on_base` posting at 100 %, landing the whole VAT on the asset account,
and so does `FI-P-EDUSTUS` for entertainment costs (114 § 1 momentti
3 kohta), which is refused in full with no exception at all.

**The construction-industry reverse charge (AVL 8 c §, in force since
1.4.2011) is modelled on both sides**, `FI-S-RAKENNUS` and `FI-P-RAKENNUS`,
because it is the domestic case a Finnish company is most likely to meet
beside the intra-Union ones. **The scrap-metal reverse charge (AVL 8 d §)
shares the same boxes on the form (318/320) but is not modelled as a
separate code**: this pass did not verify its commencement date with
confidence, and a pack that posts to a box under an unverified date is
worse than one that names the gap.

## Form VSRALVKV — the periodic VAT return

`tax_report.json` carries the box list Verohallinto publishes in its data
file description for form VSRALVKV, filed on OmaVero. Two things about it
are worth knowing before reading the file.

**The Finnish return reports the tax, not the taxable value, for domestic
sales.** Boxes 301, 302 and 303 are each the verokannan mukainen vero — the
amount of tax charged at that rate — with no companion box for the value it
was charged on. This is unlike Belgium, France or Estonia, whose returns
report a base and a tax side by side for a domestic rate; a base posting on
`FI-S-255`, `FI-S-135` and the rest would have nowhere on this form to be
printed, so those taxes carry a `tax` posting only, no `base` posting at
all — the same shape `docs/packs.md` describes for a French purchase, whose
CA3 "carries no grid for the base of a purchase".

**Box 307 pools every rate's deductible input VAT into one figure.** There
is no per-rate deduction box on the purchase side: `FI-P-255`, `FI-P-135`,
`FI-P-10` and the self-assessed purchase taxes all post their deductible
share to the same box 307, exactly as Verohallinto's own reconciliation
formula treats it (`308 = 301+302+303+304+305+306+318 − 307`).

**Boxes 304 and 310 (VAT on imports of goods and their value) are declared
and nothing posts to them.** This pack does not model the import of goods
from outside the European Union: Finland has self-accounted import VAT
through the periodic return for VAT-registered importers since a reform
this pass did not independently verify a precise article and commencement
date for, and a box existing on the official form is evidence the mechanism
exists but not evidence of the article that governs it. The boxes are
declared for completeness of the form; whoever adds import VAT here should
verify AVL chapter 9 first.

**No deadline is declared.** Verohallinto's own guidance gives it as the
twelfth day of the *second* month following the period — a monthly period
ending in March falls due on 12 May — and the format's `deadline` rule
takes only a day of the month *immediately* following the period or the
last day of that month, neither of which can say "two months later, on a
fixed day". Leaving `deadline` out is not silence about the law: it is a
gap in what the pack format can currently say, recorded under
[`docs/international.md`](../../docs/international.md#from-finland).

**Filing period.** Laki oma-aloitteisten verojen verotusmenettelystä
768/2016, 11 § makes the calendar month the rule; 12 § lets a taxable
person whose annual turnover is at most 100 000 € apply for the calendar
quarter, and one whose turnover is at most 30 000 € apply for the calendar
year. `period_default` is `month`, the one answer the law gives everybody
before an election.

## Electronic invoicing

`einvoicing.obligation` is `on_request`, the same shape as
[Estonia's](../ee/README.md): laki 241/2019, 3 § obliges a public
contracting authority to receive and process an electronic invoice based
on a public procurement, phased in from 1.4.2019 for central government and
1.4.2020 for the rest; 4 §, applicable from 1.4.2020, gives **both** a
contracting authority **and an ordinary business** the right to request an
electronic invoice from the other — a national extension beyond the B2G
minimum Directive 2014/55/EU sets, and still a right to ask rather than a
standing obligation to issue one. The law names no syntax of its own: it
defers to the European standard EN 16931 and the syntaxes the European
Commission has published against it. `profile` is declared as
`peppol-bis-3` because it is one of those syntaxes and the one this pack's
format understands; Finvoice 3.0 (Finanssiala ry, the Finnish banks'
federation) and TEAPPSXML 3.0 are two more that Finnish businesses actually
exchange, and nothing found in this pass says either is deprecated in
favour of Peppol.

`party_scheme` is `0216`, the OVT code — the current Peppol participant
identifier scheme for Finland; the four schemes it replaced (`0037`,
`0212`, `0213`, `0215`) were withdrawn from the Peppol code list on
31.12.2024. `vat_scheme` is left null: unlike Belgium's `9925` or Germany's
`9930`, no ISO 6523 scheme dedicated to the Finnish VAT number was found in
the current Peppol code list.

## Closing the year

`closing_style` is `result_accounts`: the result of the year lands on
`2050 Tilikauden voitto (tappio)`, a balance-sheet account kept apart from
`2040 Edellisten tilikausien voitto (tappio)` — Kirjanpitoasetus 1339/1997,
1 luku 6 § lists them as two separate lines of oma pääoma (`A VI` and
`A VII`), the same shape France keeps 120 and 129 apart for. Finland keeps
one account for both signs of the year's result, because the balance sheet
has one line for it either way; the manifest names `2050` twice, as
`current_year_result_profit` and `current_year_result_loss`.

## What this pack does not carry

- **Import of goods from outside the European Union.** See above: boxes 304
  and 310 are declared, nothing posts to them.
- **The scrap-metal reverse charge (AVL 8 d §)** beside the modelled
  construction one, for the reason given above.
- **Reduced-rate history before 1.1.2025**, for the reason given above.
- **The cash-accounting turnover threshold (AVL 137 §).** Finland lets a
  taxable person with an annual turnover of at most 500 000 € (or one not
  subject to the Kirjanpitolaki, or entitled to draw up cash-basis accounts)
  time output VAT to the month collection falls in. It is a property of the
  *taxable person*, not of one tax among several, the same reason
  [Estonia's pack](../ee/README.md) gives for not modelling its own KMS
  § 44 — modelling it as a parallel set of tax codes would be a claim this
  pack cannot support.
- **Form KMD INF equivalent, and any recapitulative statement beyond the
  boxes of VSRALVKV itself.**
- **The fixed assets module.** There is no `assets.json`: Finnish usual
  depreciation durations by category come from guidance rather than from a
  single citable text, and this pack cites texts.
- **The XBRL taxonomy of the annual report**, filed to the Finnish Trade
  Register (PRH) under the ESEF/XBRL rules that apply to it. `statements.json`
  leaves `xbrl` and `taxonomy` null on both statements: no key was verified.
- **`documents.tax_point`.** AVL 15 § was read closely enough to confirm it
  exists and governs the chargeable event, and not closely enough to state
  with confidence which of the format's five words it is — in particular
  whether an advance payment displaces the general rule the way it does in
  several neighbouring packs. Left out rather than guessed at.

## Reviewing this pack

Open an issue titled "Review: Finland". What a review is, and what it is
not, is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and
who may say what". The points a reviewer is most likely to want to check
first: the exact scope of AVL 85 §'s 13,5 % list against a current reading
of the consolidated text, the VAT accounts' side-swinging statement rule,
`documents.tax_point` left undeclared, and the gaps named above.
