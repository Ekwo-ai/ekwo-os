# Benin

Everything Benin adds to Ekwo, as data: the value added tax of the Code
général des impôts, where each rate posts, the lines of the monthly return and
the electronic invoice. The chart of accounts, the journals and the two
statements are the SYSCOHADA révisé shared by seventeen countries, and they
are not written here: they are copied from
[`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`, which the CI
runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XOF, the CFA franc of the BCEAO, at no decimal.

## Sources

| What | Text | Where |
|---|---|---|
| Rates, exemptions, fait générateur, exigibilité, deduction, invoices, the return | Code général des impôts, loi n° 2021-15 du 23 décembre 2021, up to date at the loi de finances pour 2026 (loi n° 2025-22 du 8 décembre 2025) | the DGI's own PDF, `api.impots.bj` |
| What changed before 2026 | Code général des impôts, édition 2025 (loi n° 2024-34 du 12 décembre 2024) | `finances.bj` |
| The certified electronic billing machine (MECeF / e-MECeF) | Code général des impôts, art. 481-483; the e-MECeF portal | `e-mecef.impots.bj`, `gouv.bj` |
| Filing | e-Services Bénin (télédéclaration et télépaiement) | `e-services.impots.bj` |
| An old paper model of the monthly return, for the content of its lines | Formulaire TVA, DGID | hosted by `benin.eregulations.org` |
| The frame of the rate | Directive n° 02/2009/CM/UEMOA, art. 29 nouveau | AIFO-UEMOA |

## What the pack says

- **18 %** is the only positive rate of value added tax (art. 241): no
  reduced rate, where the UEMOA directive would allow one. Exports are
  exonerated *at a zero rate, with a right to deduct* (art. 230), on a box of
  their own, distinct from the exemptions of art. 229 that carry none.
- **A second positive rate, and it is not a rate of VAT.** Article 229-12
  exempts banking and insurance from VAT because they instead carry the taxe
  sur les activités financières et assurances (TAFA, art. 264 to 271) — 20 %
  on fire insurance, 5 % on transport insurance, 10 % everywhere else,
  including a commission or an interest a company earns on a loan or an
  advance to anybody, not only a bank (art. 264-2). `BJ-S-TAFA-10` posts its
  base to the VAT return's `EXO` box, like any other art. 229 exemption, and
  the tax itself to account 446 « État, autres taxes sur le chiffre
  d'affaires », outside `BJ-TVA` — art. 270-1 files it under the rules of
  VAT, on a form of its own this pack does not carry (the Senegalese gap,
  again).
- **A sale is taxed when the fait générateur happens, unless an invoice moves
  it forward, and a service moves further still.** Article 235-1 sets the fait
  générateur at delivery for goods (`d`) and at completion for a service or
  a construction contract (`b`, `c`); article 235-2 never lets it fall later
  than an invoice, wholly or in part — the country rule this pack calls
  `invoice_if_issued`. But article 236-1-b pushes exigibility itself to
  *encaissement* for every service, every construction contract and every
  public contract of the State, a local authority or a State-owned company: a
  service is taxed later than its invoice, not earlier. `BJ-S-18-SRV` is
  `cash_basis`, the same shape Côte d'Ivoire already carries: invoiced, the
  tax waits on 4432 « T.V.A. facturée sur prestations de services »; paid, it
  moves to 4431, whose heading « sur ventes » already covers the services sold
  of account 706. The golden scenario shows one service paid in full the
  month after its invoice and one paid by half.
- **Deduction** (art. 243 to 245): 4451, 4452 and 4454 by what was bought,
  all into box `DEDBS` or `DEDIMMO`; the exclusions of art. 247 (tourism
  vehicles, their fuel, lodging and entertainment, furniture, gifts over
  10 000 F) as a non-deductible code; the gasoil, oil and grease of
  construction and industrial machinery, deductible at 90 % for a BTP company
  since the finance law for 2026 (art. 247-2).
- **The return** carries what art. 259-1 says it carries — taxable and
  exempt turnover, gross tax, deductions, net tax or credit — named after
  that content and not after a printed form, whose current, online model
  could not be read (see below). It is monthly for everybody: no quarterly
  regime was found for Benin, unlike Senegal or Côte d'Ivoire. Due the 10th
  (art. 259-1), paid spontaneously with the return (art. 259-3).
- **The invoice** is a *facture normalisée*: a unique serial number and a
  date (art. 481-2-a), the rate or the word « exonéré » (art. 481-2-h), and,
  where it applies, the amount of the AIB and any other tax (art. 481-2-j).
  `documents.numbering` says `sequential` — the unique number the article
  asks for — and no more, because the number itself is not written by the
  seller: it comes from the certified billing machine (see *einvoicing*
  below).

## What it does not say

- **The MECeF/e-MECeF is a clearance model, and Ekwo issues nothing through
  one.** Article 482-1 makes every facture normalisée pass through a
  certified electronic billing machine — a physical unit or its dematerialised
  form, homologated by the DGI — which stamps it with its own device number
  (art. 481-2-k) and an electronic code (art. 481-2-l); without them the
  invoice does not exist, and the tax it carries is not deductible for the
  buyer (art. 244-1-d). `einvoicing.profile` names an EN 16931 profile a brick
  of `packages/formats/` writes, and no brick here generates, certifies or
  transmits anything to a MECeF or an e-MECeF, so `profile`, `mandatory_from`
  and `party_scheme` stay empty — the gap Mexico's CFDI and Côte d'Ivoire's
  FNE already name in `docs/international.md`.
- **The AIB (acompte sur impôt assis sur les bénéfices, art. 130 to 134) is
  not a value added tax and this pack carries none of it.** It is an advance
  on the *buyer's* own income tax, at 1 % of goods and works and 3 % of
  services bought from a supplier registered under the identifiant fiscal
  unique (art. 132-2-a, b), withheld by that supplier and imputable by the
  buyer against their future tax (art. 133). Two reasons stopped it here,
  not one: a purchase invoice already carries the VAT this pack does declare,
  on the very same net price the AIB is assessed on (art. 132-1-b) — one
  document line, one tax code, the compound-tax gap Mexico's stacked VAT and
  ISR withholding already names — and a third category of the AIB, on every
  payment made to a supplier by the State, a local authority or a company
  liable to corporate tax (art. 130-3), is withheld only when the *payment* is
  made, which is the Senegalese BRS's gap. Neither the AIB's own return, due
  by the 10th of the month after it was invoiced or withheld (art. 134-3), is
  a form this pack declares — a pack carries one form, the Senegalese gap.
- **The TVA withheld at source on sales to the State (art. 263) is a
  withholding on payment, the buyer's own office withholding it "au moment du
  paiement", and the deduction the supplier later claims runs on a *quittance*
  the buyer hands them (art. 244-1-c), not on the invoice.** The Senegalese
  précompte was close enough to model as a purchase-side tax because Senegal's
  law ties it to the sale itself; Benin's own text ties it to the office that
  pays, and this pack does not guess the timing it does not state plainly.
  Rates: 100 % for the smallest taxpayers of art. 229-1, 40 % for the rest.
- **A public contract taxes a delivery of goods on collection too.** Article
  236-1-b's cash-basis exigibility reaches "les marchés publics de l'État, des
  collectivités locales et des sociétés, établissements et offices de l'État"
  as a category of its own, beside services and construction — meaning a sale
  of goods to one of those buyers is cash-basis where an ordinary sale of
  goods is not. `conditions` has no word for a status of the buyer that
  changes a tax point (`buyer_status` only qualifies whether a tax applies,
  never when), so `BJ-S-18` stays the ordinary rule and this pack writes no
  separate code for a public buyer's purchase of goods.
- **The assujettissement threshold (art. 228)** is fixed by ministerial
  *arrêté*, not by the Code; the DGI's own page for it answered 404 on 21
  September 2026 and no other official copy was found.
- **The current online return.** `e-services.impots.bj` renders its form
  dynamically and was not read; only an older paper model survives on a
  third-party site, and this pack's boxes are named after art. 259-1's
  content rather than copied from either.
- **The exact article of the sanction for a missing facture normalisée** —
  ten times the evaded tax, a floor of 1 000 000 F per transaction, said on
  the government's own page but not traced to a numbered article in the 2026
  Code.
- **Late-payment terms between businesses**: no Beninese or UEMOA text found.
