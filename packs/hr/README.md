# Croatia (`hr`)

Porez na dodanu vrijednost (PDV) at 25 %, 13 % and 5 %, the periodic
`Obrazac PDV`, and the electronic invoice that becomes mandatory between
businesses on 1 January 2026.

## Status: `community`

Written from the official texts listed below and checked for internal
consistency by the golden scenario (`ekwo pack check hr`). No accountant has
read it yet — the checklist at the end of this file is what to look at before
that changes.

## Sources

| What | Text | Publisher |
|---|---|---|
| VAT rates, exemptions, tax point | Zakon o porezu na dodanu vrijednost | Zakon.hr (Narodne novine, pročišćeni tekst) |
| Filing deadline moved to the last day of the month | Zakon o izmjenama i dopunama Zakona o PDV-u, NN 151/25 | Narodne novine |
| Mandatory B2B e-invoice from 1 January 2026 | Zakon o fiskalizaciji, NN 89/25 | Narodne novine |
| Mandatory B2G e-invoice since 2018/2019 | Zakon o elektroničkom izdavanju računa u javnoj nabavi, NN 94/18 | Narodne novine |
| 30-day default payment term | Zakon o rokovima ispunjenja novčanih obveza, NN 125/11 | Narodne novine |
| Statutory late-payment interest mechanism | Zakon o obveznim odnosima, čl. 29. | Zakon.hr |
| The periodic return itself | Obrazac PDV (obrazac u primjeni od veljače 2026.) | Porezna uprava |
| E-invoice format and channel | Fiskalizacija 2.0 — rječnik | Porezna uprava |

`ekwo pack check hr --links` opens every URL above; a `403` from Narodne
novine or Zakon.hr to a request with no browser behind it is not a wrong
pack, the way the framework's own docs already say of Légifrance.

## The chart of accounts, and why this one

Croatia has no state-mandated chart of accounts for ordinary companies —
Zakon o računovodstvu (čl. 8.) asks only for double-entry bookkeeping and
financial statements under HSFI or IFRS, and leaves the numbering to the
company. In practice almost every firm follows the "Računski plan za
poduzetnike" that RRiF (Hrvatska zajednica računovođa i financijskih
djelatnika) republishes every year — a work under RRiF's own copyright,
whose numbers and names this pack does not reproduce, exactly as
`packs/at/` does not reproduce the Austrian chamber's EKR.

`accounts.csv` is therefore an independent four-digit numbering: `0xxx`
non-current assets, `1xxx` current assets (receivables, inventory, cash and
the VAT control accounts), `4xxx` equity, `5xxx` provisions and long-term
liabilities, `6xxx` current liabilities, `7xxx` expenses, `8xxx` income,
`9xxx` off-balance. It carries only the eighteen account types the
framework itself defines, and reports through no chart-specific statement.

**`6400` (Obveza za PDV) never carries a tax line.** Output VAT — on a
domestic sale or on the self-assessed half of a reverse charge, an
intra-Community acquisition, an import or a service received from a
supplier without a Croatian establishment — posts to `6401`; input VAT,
including the deducted half of those same self-assessed transactions,
posts to `1400` (Pretporez). `6400` is `defaults.roles.tax_payable` alone,
the account `settle_filing()` clears the period's net into; `tax_receivable`
is left unset so a credit settles into that same account rather than a
second one this chart has no use for, which is the schema's own fallback
"for a chart that keeps one control account for both signs." A control
account that also carried the tax lines it settles would net a period's
movements into themselves and post an empty entry — see `packs/cz/`, split
the same way for the same reason.

**This pack ships no `statements.json`.** Every account falls back to
`packs/generic/`, the country-less framework that sums a balance sheet and
an income statement from account types alone (`IFRS-SME-BS`,
`IFRS-SME-IS`). Croatia does have an official, AOP-coded Bilanca and Račun
dobiti i gubitka (Pravilnik o strukturi i sadržaju godišnjih financijskih
izvještaja, filed to FINA as GFI-POD) — reproducing that line by line, AOP
code by AOP code, is real work this pack has chosen not to guess at rather
than ship a mapping nobody has checked against the actual Prilog. See
"Before this pack is `reviewed`" below.

## Single language

`languages` is empty, like `packs/pl/`. Every label — account names, tax
names, mentions, box names — is written once, in Croatian, which is the
pack's own `defaults.language`. Nothing here needed an English label that
could not be read directly from the law, so none was invented.

## The taxes

Eighteen codes. Three positive domestic rates (25 %, 13 %, 5 %, Zakon o
PDV čl. 38.), a domestic 0 % rate reserved by the law to solar-panel
installations on private homes (čl. 38. st. 6.), export (čl. 45.), the
intra-Community dispatch of goods and the general B2B place-of-supply rule
for services (čl. 41. and čl. 17.), one domestic reverse charge
(construction services, čl. 75. st. 3. t. a) — mirrored on both the sale
side, which reports only a base, and the purchase side, which self-assesses
and deducts in the same period), the residential-lease exemption (čl. 40.
st. 1. t. l), and — on the purchase side — the three intra-EU / third-country
self-assessment mechanisms the return keeps apart (intra-Community
acquisition of goods, a service received from an EU supplier under čl. 75.
st. 1. t. 6., a service received from a supplier established outside the
EU under čl. 75. st. 2.), import VAT assessed on the customs declaration
(čl. 32.), and the 50 % non-deductible share of the VAT on a passenger car
(čl. 61. st. 2.).

Every self-assessed purchase tax posts the same base into **two** boxes at
once — the output box of section II and the input box of section III — and
two `tax` postings, one to the output account (`6401`) in box II and one to
the input account (`1400`) in box III: the return states the tax as due and
deducts it in the same line, which is exactly what Croatian VAT does with a
reverse charge, and the two boxes are not a sum of one another so neither
can carry the amount alone (`docs/packs.md`, "A base is written once").

**Article numbers not yet pinned to a sub-point.** The general
self-assessment mechanism for an intra-Community acquisition of goods, and
several of the boxes of section I that this pack could source only to the
form's own user guide rather than to a specific article (I.2, I.5, I.6,
I.10), are cited at the paragraph level this pack could verify and no
finer. A local reviewer should tighten these before `reviewed`.

## The return: Obrazac PDV

Monthly by default (Zakon o PDV čl. 84. st. 1.); a taxpayer whose turnover
including VAT did not exceed €110,000 in the previous calendar year may
file quarterly instead (čl. 84. st. 2.), which is a fact about the company
and not something `period_default` proposes for everybody.

**Filed by the last day of the month following the period** — moved there
from the 20th by the law that took effect on 1 January 2026 (NN 151/25);
today's filing deadline is `last_day_of_month_after_period`, and a pack
built before that date would have said `day_of_month_after_period` with
`day: 20` instead.

Seventy-one boxes, transcribed from the form itself rather than from a
secondary summary: eleven base-only boxes of section I (exempt, zero-rated
and reverse-charged-out supplies), fifteen paired base/tax lines of section
II (output VAT, one pair per rate and per mechanism), fifteen paired
base/tax lines of section III (input VAT, mirroring II), and the final box
IV, `II − III`, which is what is owed — positive — or refundable —
negative. `floor_zero` is deliberately **not** set on IV: unlike Belgium's
71/72 pair, Croatia states the one figure with its sign, and a company in
credit settles into the same `6400` a company that owes money does.

**Not modelled**: sections V (the annual pro-rata deduction percentage),
VI (other information — acquisitions and disposals of immovable property,
vehicles and other non-current assets, services exchanged with
non-established persons, triangular transactions, cash accounting) and VII
(food donations, added to the form from 1 January 2026). None of the three
is a box the periodic liability is computed from; all three are
disclosure annexes of the same form, and belong in a filing brick rather
than in `tax_report.json`.

## E-invoicing

`einvoicing.profile` is `peppol-bis-3`: Croatia's own technical guidance
describes the domestic B2B/B2G eRačun as UBL 2.1 with a Croatian CIUS
extension (`HR-EXT`) over Peppol BIS Billing 3.0, which is itself built on
EN 16931 — unlike Italy's FatturaPA or Poland's KSeF FA(3), both proprietary
national schemas that the neighbouring packs of this repository leave
unnamed for exactly that reason. `mandatory_from` is 1 January 2026, the
day reception binds every VAT-registered taxpayer at once (Zakon o
fiskalizaciji, NN 89/25); issuance for a taxpayer outside the VAT system
only starts a year later and is not separately modelled. The older B2G-only
obligation, in force since 2018–2019 under a different law (NN 94/18) and
routed through FINA's own platform rather than an accredited intermediary,
is folded into the same `mandatory` word rather than given one of its own,
because the 2026 obligation already covers every company.

**Not modelled**: the Croatian CIUS extension (`HR-EXT`) itself, and the
exchange through an accredited "informacijski posrednik" or FINA's
platform — this pack names the base European profile and stops there,
exactly where `packages/formats/` stops. See `docs/international.md`,
"From Croatia".

## Before this pack is `reviewed`

1. The AOP-coded Bilanca and Račun dobiti i gubitka (Pravilnik o strukturi
   i sadržaju godišnjih financijskih izvještaja) are not mapped; this pack
   reports through `packs/generic/` only.
2. Several sub-point citations of section I of the return (I.2, I.5, I.6,
   I.10) and of the intra-Community acquisition of goods should be
   checked against the consolidated Zakon o PDV rather than this pack's
   secondary reading.
3. The quarterly-filing threshold (€110,000 of the previous year's VAT-
   inclusive turnover) and the small-business threshold (€60,000) change by
   law from time to time; both are cited to the article, not hardcoded
   into a check, but a reviewer should confirm the figure in force is
   still the one this pack states.
4. `HR-P-CAR-25` leaves the non-deductible 50 % off every box of the
   return, on the ledger account of the car alone; whether the return
   expects that half anywhere else (a control total, an annex) has not
   been verified against the form's own instructions.
5. Whether the Croatian CIUS extension (`HR-EXT`) changes anything a
   company using this pack would need to know beyond the base EN 16931
   profile.
