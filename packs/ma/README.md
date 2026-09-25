# Morocco

Everything Morocco adds to Ekwo, as data: the value added tax of the Code
général des impôts, where each rate posts, the declaration it is filed on and
the chart of accounts of the Code général de normalisation comptable (CGNC).

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden two months prove the pack is internally coherent and nothing about
whether it is right. Currency MAD, the dirham, at two decimals.

## Sources

| What | Text | Where |
|---|---|---|
| Rates, exemptions, deduction, fait générateur, périodicité, art. 115 | Code général des impôts, édition 2026 | `finances.gov.ma` |
| The six sections of the return (A to F) and the télédéclaration | Guide de la Télé déclaration TVA (SIMPL-TVA) | `portail.tax.gov.ma` |
| The 2024-2026 convergence of the rates | Note synthétique des mesures fiscales, loi de finances pour 2026 (loi n° 50-25) | `finances.gov.ma` |
| The chart of accounts, the two statements | Code général de normalisation comptable (CGNC), rendu obligatoire par le dahir n° 1-92-138 du 25 décembre 1992 (loi n° 9-88) | `befec.ma` (miroir du texte, l'éditeur officiel n'en publie pas de lien stable) |

**The full text of the 2026 Code could not be read directly for this pack**:
the PDF the Direction générale des Impôts publishes is too large for the
tools available here to extract, and every attempt returned no content. What
this pack says of articles 91, 92, 95, 96, 99, 101, 104, 106 and 115 was
cross-checked across several independent professional commentaries that agree
with each other and, where they disagree, the disagreement is written below
rather than resolved by guessing. **A reviewer with access to the consolidated
Code should read this pack's `taxes.json` and `tax_report.json` against it
before it is relied on.**

## What the pack says

- **Two rates only, at the date of this pack**: **20 %** (art. 99-A, the
  standard rate) and **10 %** (art. 99-B, restauration and a list of other
  operations, with or without a right to deduction). The rates of **7 %** and
  **14 %** that the Code carried for decades were phased out by the
  convergence calendar the finance laws for 2024, 2025 and 2026 (laws
  n° 55-23, 60-24 and 50-25) ran in three steps on named sectors — transport,
  electricity, water, refined sugar among them — each moved to 10 % or 20 %.
  Every source read for this pack agrees that by 2026 article 99 states only
  the two rates above; **the exact sector-by-sector table the convergence
  produced could not be verified line by line**, so the pack carries one
  domestic tax at each of the two rates and does not attempt the list of what
  used to sit at 7 % or 14 %.
- **Exports are exempt with a right to deduct** (art. 92-I-1°), proved by the
  transport document — `transport_evidence` — and not zero-rated as a domestic
  sale would be. A domestic exemption *without* a right to deduct (art. 91-I,
  bread) is the other shape, and the two are not interchangeable: `pack check`
  refuses a `deduction` box fed by an `exempt` tax.
- **One deductible VAT account for charges (34552) and one for fixed assets
  (34551)** (art. 101, art. 104), because the return's section E separates
  them and a chart that posted both to one code could not tell the two boxes
  apart. **One non-deductible tax** for a passenger vehicle (art. 106-II): the
  tax stays on the cost of the vehicle rather than reaching a box, the shape a
  `tax_on_base` posting exists for.
- **A prestataire not established in Morocco and without a fiscal
  representative** (art. 115): the Moroccan buyer, where it is itself taxable,
  declares the base, computes the tax and deducts it in the same return —
  `foreign_services_received`, base and tax and deduction all under one code,
  netting to zero in the ledger and appearing in both the exigible and the
  deductible section of the return, the way the SIMPL-TVA guide describes
  section C.
- **The return has no numbered boxes to read**: the paper bordereau, if one is
  still printed, was not found, and SIMPL-TVA presents six sections (A to F)
  instead of a grid. The boxes this pack declares are named after those six
  sections — `CA20`, `TVA20`, `DEDIMMO`… — and not after a printed form.
- **Monthly for a turnover of 1 000 000 DH or more, quarterly below it**
  (art. 108); the cadence follows the company's own turnover, so the pack
  proposes none, the way it does in every country where the same is true. The
  return and the payment are due before the end of the month that follows the
  period — `last_day_of_month_after_period` — but **the article that fixes
  that deadline exactly (108 gives the periodicity, not necessarily the
  deposit date itself) could not be pinned down from the text**, and a reader
  who has the consolidated Code to hand should confirm it.
- **The fait générateur is encaissement by default** (art. 95); a taxpayer may
  opt for *les débits*, invoicing standing in for collection from the moment
  the option is filed. The pack reads `invoice_if_issued`, which is the
  derogation and not the rule — the golden scenario does not model the option
  itself, only its ordinary rule.
- **The chart of accounts is the CGNC's own numbering** — classes 1 to 5 for
  the balance sheet, 6 and 7 for the income statement — but **this pack's
  `accounts.csv` groups several official postes of the passif circulant
  (fournisseurs, personnel, organismes sociaux, État, associés, autres
  créanciers, régularisation) into one statement line**, where the modèle
  normal keeps them apart. A company that needs the finer split opens the
  divisionnaire accounts the CGNC already numbers; the statement line that
  reaches them is the coarser one until a reviewer redraws it.

## What it does not say

- **Which products and services sit at which of the two rates.** Article 99-B
  names a list — restauration, transport, banking, a number of regulated
  professions and, since the 2024-2026 reform, several formerly 7 % or 14 %
  goods — that this pack does not reproduce item by item: only the two rates
  themselves and one illustrative 10 % tax (restauration) are declared. A
  company selling something else at 10 % adds the code once its own reading
  of article 99-B is settled.
- **Electronic invoicing.** The principle is already in the law: article
  145-IX of the Code général des impôts, introduced by the finance law for
  2018 and accelerated by the finance law for 2024, requires a taxpayer to
  adopt a computerised invoicing system meeting technical criteria the
  administration sets, on terms a *décret d'application* fixes. As of this
  pack, no such decree is published in the Bulletin officiel: the professional
  press reported, in April 2026, a draft transmitted to the Secretariat
  General of the Government and a deployment the Director General of Taxes
  announced would start with large B2B taxpayers during 2026, with no
  threshold, no date and no technical format (UBL, CII and Factur-X are
  guesses the press makes, not a published cahier des charges) fixed by a
  published text. `einvoicing.obligation` is `none` and stays that way until a
  decree is.
- **SIMPL-TVA's other declarations** — the relevé des déductions in XML, the
  retenue à la source, the état des opérations d'autoliquidation de
  l'article 125 (an *optional* self-assessment on purchases from suppliers
  out of scope or exempt without deduction, distinct from the art. 115 case
  this pack does carry) — are files the DGI's own cahier des charges describes
  and this pack does not attempt: they are additional filings around the
  return, not the return itself.
- **The taxe professionnelle, the taxe de services communaux and any income
  tax (IS, IR)** are out of scope: this pack is VAT and the chart of accounts
  that books it, nothing else.
- **Late-payment interest between businesses.** No Moroccan text setting a
  default rate or indemnity, the way `documents.late_payment_reference` of
  other packs cites one, was found.
