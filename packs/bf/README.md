# Burkina Faso

Everything Burkina Faso adds to Ekwo, as data: the value added tax of the
Code général des impôts, where each rate posts, the declaration it is filed on
and the sentences the Code puts on an invoice. The chart of accounts, the
journals and the two statements are the SYSCOHADA révisé shared by seventeen
countries, and they are not written here: they are copied from
[`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`, which the CI
runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XOF, the CFA franc of the BCEAO, at no decimal.

## Sources

| What | Text | Where |
|---|---|---|
| Rates, exemptions, tax point, deduction, invoices, the return | Loi n° 058-2017/AN du 20 décembre 2017 portant Code général des impôts | the official PDF of the DGI, `dgi.bf` |
| The 10 % rates (hébergement/restauration agréés, transports aériens nationaux), the exclusion of gas-oil from deduction, the 2-year refund window, the FEC (art. 564) | Loi de finances pour 2025, loi n° 042-2024/ALT du 26 décembre 2024 | `assembleenationale.bf` |
| The mentions of the facture normalisée | Instruction administrative du 7 octobre 2020 relative à la facture normalisée | `dgi.bf` |
| The frame of the rates | Directive n° 02/2009/CM/UEMOA, art. 29 nouveau | AIFO-UEMOA |
| Filing | eSINTAX, `esintax.bf` | DGI |

Two texts of the Code were read directly for this pack rather than taken from
the research fiche alone: the base law (`LOI-PORTANT-CODE-GENERAL-DES-IMPOTS-FINAL.pdf`,
which predates the 2025 amendments — art. 317 there still reads a single 18 %
rate) and the finance law for 2025 in full (`FU4cnAqfHyREj0BsvgaPYtIa7qTRtT8piMrO4EIN.pdf`),
whose articles 23, 31, 32, 33, 44 and 45 rewrite arts. 221, 317, 319, 329 and
564-566 of the base law, each cited by its own article number below. **The
finance law for 2026** (mentioned by the press as raising the *retenue de TVA*
from 20 % to 30 % and shortening the refund window to six months) is not
published in a source this pack could open, and nothing built on it.

## What the pack says

- **18 %** on everything taxable (art. 317, unchanged since the Code of 2017);
  **10 %** on hébergement and restauration by an approved hotel, restaurant or
  similar establishment, and on national air transport — both added to
  art. 317 by the finance law for 2025 (art. 31), in force from 1 January 2025.
  `supply_nature` on both: an unapproved restaurant or a non-hotel lodging
  charges 18 %. The 10 % on hotels already existed since 1 April 2020 under an
  earlier law this pack has not read directly; the 10 % on domestic flights is
  new to 2025 and sits outside the community list of art. 29 of the UEMOA
  directive read here, an apparent gap between the national choice and the
  text this pack cites for it.
- **Goods post to 4431, services to 4432** — the fait générateur of a delivery
  is the delivery itself, that of a service its performance (art. 315, 1° and
  2°), and the exigibility follows the same split (art. 316-1 and 316-2, first
  sentence): a service is taxed the month it is rendered, with no general cash
  basis. `documents.tax_point` is `invoice_if_issued` because an invoice
  issued before a delivery brings the tax forward (art. 316-1, second
  sentence) — the same displacement Senegal and Côte d'Ivoire's principal
  rules use, for the goods side only.
- **One narrow cash basis.** A redevable taxed under the *bénéfices non
  commerciaux* — typically a liberal profession — owes the tax on a service
  only when it is paid (art. 316-2, second sentence), not when it is
  performed. `BF-S-18-SRV-BNC` is `cash_basis`; invoiced, it waits on 4432;
  paid, it lands on 4431 with the goods tax, for lack of an account the
  chart keeps apart for a service tax in that particular wait — the same
  choice Côte d'Ivoire made for every one of its services, narrower here to
  the one case the law actually singles out.
- **Deduction** (art. 318 to 327): 4451, 4452 and 4454 by what was bought, all
  into DEDIMMO or DEDBS; the exclusions of art. 319 as non-deductible codes —
  vehicles of 3 to 9 seats, logement/hébergement (except site-security
  housing), réception/restaurant/spectacles/déplacement, decorative
  furniture, gifts over 10 000 F, and since the finance law for 2025 (art. 32)
  super, gas-oil and biocarburant, narrowed from every fuel the base law had
  excluded.
- **A service bought from a non-resident is self-assessed on the same
  return.** Art. 315, 4° and art. 316-4, second sentence, fix the fait
  générateur and the exigibility at the invoice's emission; art. 334-3
  autoliquidates the tax on the ordinary monthly declaration, with no separate
  form — unlike Senegal's *TVA pour compte* and Côte d'Ivoire's *TVA pour
  compte de tiers*, both filed apart. Nothing in art. 319 excludes it from
  deduction, so `BF-P-NR-18` is deductible in full: box TVANR and box DEDBS
  carry the same figure.
- **The return** is monthly for every real-regime taxpayer (art. 334-1), due
  by the 20th, including a *néant* declaration — the article this pack read
  directly settles a contradiction the research fiche flagged between the
  20th (the Code) and the 15th (a figure found only in the press, which this
  pack does not carry). Contribuables of the *régime simplifié d'imposition*
  and the *contribution des micro-entreprises* are exempt from VAT outright
  (art. 307, 1, a) and file none. No official model of the printed form was
  read, so the boxes of `tax_report.json` are named after what the articles
  require declared and deducted, never after a line number of the form
  itself.
- **The invoice** carries a number of an uninterrupted series (art. 562, 1°),
  the rate and amount of the tax or the word « exonéré » for an assujetti
  (art. 562, 4°), and — for a redevable of the DGE and the moyennes
  entreprises, since 1 January 2025 — a facture électronique certifiée
  through a SECeF, with its own identifier, an authentication code and a QR
  code (art. 564, 2°, created by the finance law for 2025, art. 44).

## What it does not say

- **The *retenue de TVA*.** A client of the DGE or a public accountant
  withholds the VAT a supplier invoiced, on top of the narrow case this pack
  does carry (art. 334-2 — a non-resident holder of a public contract, whose
  VAT is withheld by the paying body). The general mechanism is referred to in
  passing by the finance law for 2025 itself (the pieces a refund request must
  carry include "la quittance de paiement du montant des retenues de TVA"),
  which proves it exists, but no source this pack could open states which
  article creates it, at what rate, for which buyers, or by when it is repaid
  — the press puts the rate at 20 %, then 30 % from the finance law for 2026,
  neither text read here. The pack carries no tax for it and no box.
- **The withholding on a payment, art. 221.** 2 %, 5 % or 10 % of a sum paid
  to a teacher's vacation, an occasional manual worker, a public or
  quasi-public body, or an occasional intellectual service, withheld by the
  payer and reversed by the 20th of the month that follows (art. 222) — an
  income tax withheld at payment, which the core cannot express (`docs/international.md`).
- **The taxe de développement touristique** (art. 336 to 341): 200 to 1 000 F
  per person per night by a hotel's star rating, 2 000 or 3 000 F per air
  ticket by destination — an amount fixed in francs, not a percentage.
  `post_document()` refuses any tax whose `amount_type` is not `percent`
  (`unsupported_tax_amount_type`), so however precisely the six tariffs are
  written into the law, the pack carries no code for this tax
  (`docs/international.md`).
- **The prélèvement sur les billets d'avion internationaux** (art. 342 to
  347): a further fixed amount by destination and travel class, on
  international tickets only, filed on its own declaration. The same gap as
  the taxe de développement touristique, and not modelled either.
- **The FEC itself.** Compulsory since 1 January 2025 for the DGE and the
  moyennes entreprises, its rollout is still under way in September 2026 —
  the press describes SECeF devices going on sale from 7 September 2026 for
  the DGE, 2 November for the DME, 1 December for the rest — none of it read
  in an official text here. `einvoicing.profile` stays null: the FEC is not a
  profile of EN 16931, and the IFU has no ISO 6523 code.
- **Late-payment terms between businesses**: no Burkinabè text found.
