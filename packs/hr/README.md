# Croatia (`hr`)

Porez na dodanu vrijednost (PDV) at 25 %, 13 % and 5 %, the periodic
`Obrazac PDV`, and the electronic invoice that becomes mandatory between
businesses on 1 January 2026.

## Status: `community`

Checked for internal consistency by the golden scenario (`ekwo pack check
hr`). No accountant has read it yet — see the checklist at the end.

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
novine or Zakon.hr to an automated request does not mean the link is wrong.

## The chart of accounts, and why this one

Croatia has no state-mandated chart of accounts for ordinary companies —
Zakon o računovodstvu (čl. 8.) asks only for double-entry bookkeeping and
financial statements under HSFI or IFRS, and leaves the numbering to the
company. In practice almost every firm follows the "Računski plan za
poduzetnike" that RRiF (Hrvatska zajednica računovođa i financijskih
djelatnika) republishes every year — a work under RRiF's own copyright,
whose numbers and names this pack does not reproduce.

`accounts.csv` is therefore an independent four-digit numbering: `0xxx`
non-current assets, `1xxx` current assets (receivables, inventory, cash and
the VAT control accounts), `4xxx` equity, `5xxx` provisions and long-term
liabilities, `6xxx` current liabilities, `7xxx` expenses, `8xxx` income,
`9xxx` off-balance, reported through the chart-specific statements below.

**`6400` (Obveza za PDV) never carries a tax line.** Output VAT — on a
domestic sale or on the self-assessed half of a reverse charge, an
intra-Community acquisition, an import or a service received from a
supplier without a Croatian establishment — posts to `6401`; input VAT,
including the deducted half of those same self-assessed transactions,
posts to `1400` (Pretporez). `6400` is `defaults.roles.tax_payable` alone,
the account `settle_filing()` clears the period's net into; `tax_receivable`
is left unset so a credit settles into that same account.

**`statements.json` carries the skraćeni (abridged) Bilanca and Račun
dobiti i gubitka** that Zakon o računovodstvu čl. 19. st. 4. lets a mikro or
mali poduzetnik file instead of the full, numbered Prilog I of the
Pravilnik o strukturi i sadržaju godišnjih financijskih izvještaja (NN
95/16, 144/20, 158/23) — the same annex FINA compiles into its GFI-POD form.
The abridged statements stop at the lettered and Roman-numeral positions
(`HR-PSFI-BS`, `HR-PSFI-IS`) rather than the two hundred-odd AOP line items
of the full form, each carrying its own AOP code in `legal_reference`. A
mikro poduzetnik may go shorter still, to the lettered positions alone; this
pack keeps the Roman numerals too, closer to the statutory Prilog. See
"Before this pack is `reviewed`" below.

## Single language

`languages` is empty. Every label — account names, tax names, mentions, box
names — is written once, in Croatian, which is the pack's own
`defaults.language`.

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
deducts it in the same line, and the two boxes are not a sum of one another
so neither can carry the amount alone (`docs/packs.md`, "A base is written
once").

The intra-Community acquisition of goods and boxes I.2, I.5, I.6 and I.10
are cited at paragraph level, partly to the form's user guide rather than to
a specific article; see the checklist below.

## The return: Obrazac PDV

Monthly by default (Zakon o PDV čl. 84. st. 1.); a taxpayer whose turnover
including VAT did not exceed €110,000 in the previous calendar year may
file quarterly instead (čl. 84. st. 2.), which is a fact about the company
and not something `period_default` proposes for everybody.

**Filed by the last day of the month following the period** — moved there
from the 20th by the law that took effect on 1 January 2026 (NN 151/25);
the deadline is `last_day_of_month_after_period`.

Seventy-one boxes: eleven base-only boxes of section I (exempt, zero-rated
and reverse-charged-out supplies), fifteen paired base/tax lines of section
II (output VAT, one pair per rate and per mechanism), fifteen paired
base/tax lines of section III (input VAT, mirroring II), and the final box
IV, `II − III`, which is what is owed — positive — or refundable —
negative. `floor_zero` is deliberately **not** set on IV: Croatia states the
one figure with its sign, and a company in credit settles into the same
`6400` a company that owes money does.

**Not modelled**: sections V (the annual pro-rata deduction percentage),
VI (other information — acquisitions and disposals of immovable property,
vehicles and other non-current assets, services exchanged with
non-established persons, triangular transactions, cash accounting) and VII
(food donations, added to the form from 1 January 2026). None is a box the
periodic liability is computed from; all three are disclosure annexes.

## E-invoicing

`einvoicing.profile` is `peppol-bis-3`: Croatia's own technical guidance
describes the domestic B2B/B2G eRačun as UBL 2.1 with a Croatian CIUS
extension (`HR-EXT`) over Peppol BIS Billing 3.0, which is itself built on
EN 16931. `mandatory_from` is 1 January 2026, the day reception binds every
VAT-registered taxpayer at once (Zakon o fiskalizaciji, NN 89/25); issuance
for a taxpayer outside the VAT system only starts a year later and is not
separately modelled. The older B2G-only obligation (NN 94/18, since
2018–2019) is folded into the same `mandatory` word.

**Not modelled**: the Croatian CIUS extension (`HR-EXT`) itself, and the
exchange through an accredited "informacijski posrednik" or FINA's
platform — this pack names the base European profile only.

## Before this pack is `reviewed`

1. The abridged Bilanca and Račun dobiti i gubitka (`statements.json`) have
   not been checked by a local reviewer line by line against the Pravilnik's
   Prilog I; positions this chart has no account for (dugoročna potraživanja,
   rezerve fer vrijednosti, manjinski interes, udjeli u povezanim društvima
   i zajedničkim pothvatima) read zero rather than being guessed at.
2. Several sub-point citations of section I of the return (I.2, I.5, I.6,
   I.10) and of the intra-Community acquisition of goods should be
   checked against the consolidated Zakon o PDV.
3. The quarterly-filing threshold (€110,000 of the previous year's VAT-
   inclusive turnover) and the small-business threshold (€60,000) change by
   law from time to time; confirm the figures in force.
4. `HR-P-CAR-25` leaves the non-deductible 50 % off every box of the
   return, on the ledger account of the car alone; whether the return
   expects that half anywhere else (a control total, an annex) has not
   been verified against the form's own instructions.
5. Whether the Croatian CIUS extension (`HR-EXT`) changes anything a
   company using this pack would need to know beyond the base EN 16931
   profile.
