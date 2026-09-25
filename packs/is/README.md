# Iceland

Everything Iceland adds to Ekwo, as data: a chart of accounts written for the
minimum structure Reglugerð nr. 696/2019 gives a balance sheet and an income
statement, the journals, the value added tax (virðisaukaskattur, VSK) codes
and where each one posts, the boxes of the periodic return RSK 10.01, and what
the invoicing rules of Lög nr. 50/1988 require. The format is
[`docs/packs.md`](../../docs/packs.md); this file records what the pack
deliberately leaves out and why, so that an Icelandic bookkeeper or
accountant reading it can disagree with one line rather than with the whole
of it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against two months of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

**Language: `is`, with no second one shipped.** The pack's own labels are
written in Icelandic, the only official language of every source this pack
reads. `pack.json` declares no `languages`: see
[`i18n/README.md`](i18n/README.md) for why an English file is not shipped in
this version.

## Iceland is outside the common system of VAT, and inside the EEA

Iceland is a member of the European Free Trade Association and, through the
Agreement on the European Economic Area, of the internal market — which is
why it has adopted the Union's accounting directive (see below) — but Annex
IX of the EEA Agreement does not carry Directive 2006/112/EC: Iceland has
never acceded to the Union and levies its own VSK under Lög nr. 50/1988,
unrelated to the common system. This pack therefore reads
[`docs/packs.md`](../../docs/packs.md#what-a-tax-says-on-the-invoice-treatment-category-and-reason)
the way `packs/ch/` does: `exemption_code` is null on every tax (the VATEX
list belongs to a system Iceland is not in) and the article is in
`legal_reference` instead; the five `intracom_*` treatments are never used —
there is no intra-Community acquisition to or from a country outside the
Union, VSK on an imported good is assessed at the border like a third
country's, not deferred like a Member State's. `IS` is added to
`supabase/seed/00_territories.sql` with `eu_vat_scope = 'none'`, exactly as
`docs/packs.md`'s "adding a country" guide asks of a country outside the
common system.

## Sources

Every rate, box and mention carries its own `legal_reference` and names the
entry of `certification.sources` its article is in. The register holds twelve
texts; the two load-bearing ones were read article by article:

| What | Text | Publisher |
|---|---|---|
| Rates, exemptions, exports, self-assessment, filing periods and deadlines, invoice numbering, late-payment surcharge | Lög nr. 50/1988 um virðisaukaskatt | Alþingi |
| The two-month filing period and its exceptions | Reglugerð nr. 667/1995 | Fjármála- og efnahagsráðuneytið |
| Invoice form requirements, continuous numbering | Reglugerð nr. 50/1993 | Fjármála- og efnahagsráðuneytið |
| The boxes of the return and their exact wording | RSK 10.01 (eyðublað) | Skatturinn |
| Worked examples of the return, the delivery rule, import VAT | Leiðbeiningar um virðisaukaskatt, rsk_1119 | Skatturinn |
| The minimum structure of the balance sheet and the income statement | Reglugerð nr. 696/2019 | Atvinnuvega- og nýsköpunarráðuneytið, undir heimild 6. gr. laga nr. 3/2006 |
| Default payment term, default interest | Lög nr. 38/2001 og Lög nr. 8/2015 | Alþingi |
| B2G electronic invoicing | Reglugerð nr. 44/2019 | Fjármála- og efnahagsráðuneytið |
| Import VAT collection | Tollalög nr. 88/2005 | Alþingi |

Lög nr. 50/1988 was read in its current consolidated text on althingi.is —
articles 1–2 (scope and exemptions), 12 (zero-rated turnover), 13 (the
delivery rule), 14 (the rates), 15–16 (input tax and its restriction), 20
(invoicing), 24 (periods and deadlines), 28 (surcharge and default interest)
and 35 (self-assessment of VAT on services bought from abroad) — together
with the worked examples of `rsk_1119` (19th edition, 2022) and the RSK 10.01
specimen form for the exact wording of every box.

## The chart of accounts, and why this one

**Iceland prescribes no chart of accounts.** Lög nr. 3/2006 um ársreikninga,
6. gr., leaves the presentation of a balance sheet and an income statement to
a regulation; Reglugerð nr. 696/2019 (which implements Directive 2013/34/EU,
via the amending Lög nr. 73/2016) fixes the *minimum structure* those two
statements must show — fastafjármunir before veltufjármunir on the assets
side, eigið fé, langtímaskuldir and skammtímaskuldir on the other, and an
income statement of twelve lines by nature of expense — and takes no position
on account numbers. This pack's chart is original, written directly against
that structure the way `packs/ch/` is written against Art. 959/959b of the
Swiss Code of Obligations: a reader will find a similar shape to whatever
convention an Icelandic accountant already uses, and different account
numbers throughout.

Four-digit codes, one range per item of the regulation's article 3 (balance
sheet) or article 5 (income statement), so that every account reaches exactly
one statement line by the head of its code — see `statements.json` for the
exact ranges. VSK control accounts (innskattur/útskattur per rate, the
self-assessed and import codes) sit inside the ordinary short-term
receivable/payable ranges, `1600`–`1699` and `2500`–`2699`, because the
regulation gives them no line of their own.

`closing_style` is `retained_earnings`: article 3, 3. tölul. gives no separate
"result of the year" item the way Belgium's appropriation accounts do, so the
result closes straight into `2090`, óráðstafað eigið fé.

Per the "Ajout 25/09 — comptes lettrables" rule, only `1500` (viðskiptakröfur),
`1501`, `2410`–`2411` (viðskiptaskuldir) and the two VSK settlement accounts —
`1690` (tax_receivable) and `2590` (tax_payable), each distinct from every
account a tax posts to — are `reconcilable`. Neither the bank (`1910`), the
cash drawer (`1900`) nor the suspense account (`2650`) is.

## The taxes

Ten codes. Five on the sale side: the standard rate (24 %), the reduced rate
(11 %), an export of goods (Art. 12, 1. tölul., zero-rated with full input
deduction — this pack's "taux zéro/export" case), a sale of services to a
foreign business with no establishment here (Art. 12, 2. tölul., the same
zero rating extended to services), and a real property lease (Art. 2, 3. mgr.,
genuinely exempt with **no** input deduction — this pack's "exonération" case,
and the opposite of the two zero-rated codes in exactly the way Art. 2 and
Art. 12 are opposites in the law itself: RSK 10.01's own instructions for
reitur C state, in as many words, that an Art. 2 exemption is never reported
there).

Five on the purchase side: the standard and reduced rates (input deduction,
Art. 15–16), a non-deductible purchase used for the exempt letting above
(`tax_on_base`, Art. 16 — no box, because the amount becomes part of the cost
of the line it taxes, not a figure the return asks for), the self-assessment
of VSK on a service bought from a supplier with no establishment here (Art.
35 — a genuinely non-EU mechanic, since Iceland has no domestic reverse
charge the way several EU States have one for construction or gold), and an
import of goods (VSK collected by customs under Tollalög nr. 88/2005,
independently of this return — only the resulting input deduction appears,
on RSK 10.01 exactly as `packs/ch/` books its own import VAT: the tax posting
carries no `base`).

**RSK 10.01 carries no dedicated box for a self-assessed or reverse-charged
amount** the way the Swiss form's Ziffer 383 or the British return's box 1
does. Reading the form's own eight boxes (A–H) literally, `IS-P-FOREIGN-24`
posts the self-assessed amount into `D` (útskattur) exactly as an ordinary
output tax, and its matching input deduction into `E` (innskattur) exactly as
an ordinary input tax — which is what Art. 35 asks of a taxpayer with full
deduction rights, and is this pack's own reading of a form that does not
spell the mechanic out box by box. A reviewer who reads Art. 35 differently,
or who finds a Skatturinn ruling that assigns it a different box, should
correct this first.

`exemption_code` is null on every tax, for the reason given above.
`vat_category` is filled in anyway, the way `packs/ch/` and `packs/gb/` fill
it in: UNCL5305 is a UN/CEFACT list, not an EU one, and it reads the same
whether or not `einvoicing.profile` asks for it — this pack declares none.

## The return's boxes are lettered, not numbered

RSK 10.01 prints reitur `A` through `H`, and this pack's `tax_report.json`
carries those same eight letters as its box identifiers rather than
inventing numbers: `A`/`B` the two rates' turnover, `C` the zero-rated
turnover only, `D`/`E` the output and input tax totals, `F` their difference,
`G` the late-payment surcharge (see below) and `H` the final balance.

**`G` is declared and never posted to.** It is Skatturinn's own web-filing
system that computes a surcharge from the day payment actually reaches the
Treasury (Art. 28: 1 % per day up to 10 %, then ordinary default interest
after a month), a fact this pack's engine has no way to know when it books a
document. `H` is still declared as `F + G`, which resolves to `F` alone in
every golden document this pack replays.

## Filing: two months, due the fifth day of the second month after

`period_default` is `bimonth`: Art. 24, 1. mgr., gives one answer to
everybody — six two-month periods anchored on January — and the two named
exceptions (a monthly period for a taxpayer with a material input surplus,
an annual one under a turnover threshold, both granted on request) are
authorisations against that rule rather than a second rule of their own,
exactly the reasoning `packs/be/` and `packs/fr/` give for proposing `month`.

**No `deadline` is declared**, and that is a gap in the format rather than in
this pack's reading of the law — see
[`docs/international.md`](../../docs/international.md#from-iceland).

## What this pack does not model, and why

**Farmers' and forestry operators' half-yearly period** (Art. 24, um
sérreglur um landbúnað: 1 September and 1 March, not the calendar half-years
`half_year` anchors on). A sixth cadence with its own anchor months is
outside the six the format already carries.

**The refund schemes of Art. 42–43** (residential construction and repair,
a partial refund of VSK already paid) are a different mechanism —
a cash refund outside the periodic return — that this pack's golden scenario
does not exercise.

**The reduced-rate list of Art. 14, 2. mgr.** is long — this pack's
`legal_reference` reproduces it in full on `IS-S-11`, but only one item
(matvæli, food) is exercised in the golden scenario. A reviewer checking a
specific item (gisting, farþegaflutningur, bækur…) should read the article
itself rather than assume the golden proves each one individually — it
proves the 11 % code, not every good it applies to.

**Discounts, bad debts and the other reductions of "lækkun skattskyldrar
veltu"** (rsk_1119, bls. 25) are not modelled as their own tax code: this
pack's golden scenario exercises a credit note instead, which is the
document Ekwo already has a shape for.

## Before this pack is `reviewed`

1. **The self-assessment boxes for `IS-P-FOREIGN-24`** — this pack's own
   reading of an RSK 10.01 that has no dedicated line, above, is the first
   thing to check against practice or a Skatturinn ruling.
2. **The chart**, read by someone who books Icelandic VSK daily: which
   accounts a small íslenskt einkahlutafélag will miss, and whether the VSK
   control accounts inside `1600`–`1699` / `2500`–`2699` match how a
   bookkeeper actually separates them.
3. **The reduced-rate list on `IS-S-11`** — confirm every item transcribed
   from Art. 14, 2. mgr. against the consolidated text, not this pack's
   reading of a secondary description of it.
4. **`documents.numbering: "gapless"`** — confirm Reglugerð nr. 50/1993 does
   not in practice require a fresh sequence each year, which this pack reads
   it as not requiring.
5. **`legal_payment_days: 0`** — confirm this reads Lög nr. 38/2001 and Lög
   nr. 8/2015 correctly: absent an agreed term, no statute fixes a default
   number of days, and default interest instead starts a month after a
   demand for payment, which is not the same answer the EU's Late Payment
   Directive's own default gives and does not, by itself, bind Iceland
   outside the term-length ceiling Lög nr. 8/2015 sets when a term **is**
   agreed.
