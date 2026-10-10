# DR Congo

Everything the Democratic Republic of the Congo adds to Ekwo, as data: the
value added tax of the Ordonnance-loi n° 10/001 du 20 août 2010, where each
rate posts, the declaration it is filed on and the sentences the text puts on
an invoice. The chart of accounts, the journals and the two statements are the
SYSCOHADA révisé shared by seventeen countries, and they are not written
here: they are copied from [`packs/ohada/`](../ohada/README.md) by
`scripts/ohada-packs.mjs`, which the CI runs to refuse a copy that has
drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency CDF, the franc congolais, at two decimals — neither UEMOA nor
CEMAC.

## Sources

| What | Text | Where |
|---|---|---|
| The 16 % rate, the exemptions, the deduction, the declaration | Ordonnance-loi n° 10/001 du 20 août 2010 portant institution de la taxe sur la valeur ajoutée | `leganet.cd` |
| The 8 % reduced rate, the invoice number, the DEF/facture normalisée obligation | Loi de finances n° 22/071 du 28 décembre 2022 pour l'exercice 2023, art. 29 à 35 | copie ABC50 |
| The facture normalisée, the dispositif électronique fiscal (DEF), the sanctions | Décret n° 23/10 du 03 mars 2023 | `dgi.gouv.cd` |
| The dispensation of the facture normalisée, the obligation on the buyer to demand one | Circulaire ministérielle n° 005/CAB/MIN/FINANCES/2024 du 30 décembre 2024 | `dgi.gouv.cd` |
| The mandatory mentions, a reading list of the texts above | Extraits des dispositions légales (DGI) | `dgi.gouv.cd` |
| Filing | I-IMPOTS | `i-impots.dgirdc.cd` |

The décret n° 23/10 and the circulaire n° 005 are relied on only for the
passages cited; their full text should be checked. **The loi de finances
rectificative n° 26/032 du 07 août 2026**, reported by a federation of
employers (FEC) to add rates of 5 % and 1 % from 7 August 2026, is not in the
register as a primary text: see *What it does not say*.

## What the pack says

- **16 %** on everything taxable (art. 35); **8 %** since 1 January 2023 (art.
  35, loi de finances n° 22/071, art. 30) on a closed tariff list of 24
  positions — meats, offal, frozen and salted fish, rice, sugars, infant
  milks, table water, iodised salt, household soap, matches — and on domestic
  air tickets, `supply_nature` because the pack cannot see the tariff
  position or the ticket's route by itself. **0 %** on exports (art. 35).
  **Exempt** operations of art. 15 and following, cited at the level of the
  principle: the list, amended piecemeal from 2010 to 2023, is not
  reconstructed article by article. `CD-S-EXO` carries the reference to
  section 3 of the OL and no more; a reviewer should read art. 15 before
  relying on it.
- **Goods and services post apart** — 4431 and 4432 on the sale side, 4451,
  4452 and 4454 on the purchase side — because the chart has the accounts.
- **The rate itself has an uncertain start date.** OL 10/001 was signed 20
  August 2010; its own art. 78 gives it "dix-huit mois à dater de sa
  signature" to enter into force, without stating the day itself.
  `valid_from: "2010-08-20"` is the date the law was signed, not necessarily
  the date the 16 % rate first applied, which may be up to eighteen months
  later. An ordonnance-loi n° 001/2012 of 21 September 2012 amending the tax
  is known by its title only. The caveat is on the date, not on the rate.
- **Import.** `CD-P-IMP-16`: VAT at importation is liquidated by the
  Direction Générale des Douanes et Accises (DGDA), not the DGI, and deducted
  on the declaration of release for consumption. This rests on the DGI's own
  account; no article of OL 10/001 fixing the exigibility or the deduction
  mechanism at import, separate from art. 35's rate, is cited.
- **The declaration** is monthly, due on the 15th of the month that follows,
  in duplicate, accompanied by payment; a nil declaration is compulsory in
  the absence of any operation (art. 60). Its boxes are named after what
  art. 60 and art. 35 make a taxpayer declare, **not after a printed form**,
  whose model and box numbering are not published.
- **The invoice.** OL 10/001, art. 58 (as amended by the loi de finances for
  2023, art. 33), requires a *facture normalisée* produced by a *dispositif
  électronique fiscal* (DEF) — physical (Unité de Facturation + Module de
  Contrôle de Facturation) or dematerialised (e-UF, e-MCF) — or a document
  standing in for one; a decree of 3 March 2023 sets the technical detail,
  and a circular of 30 December 2024 makes the client's acceptance of only a
  facture normalisée a condition too. `documents.mentions` carries the two
  legal references a document can hold by itself, `exempt` and `export`; the
  DEF-specific mentions (its own identification number, an authentication
  code, a QR code) are not legal *sentences* a mention can hold — they are
  outputs of a device this socle does not model. See *What it does not say*.

**A service bought from a supplier abroad: `CD-P-NR-16-ND`.** A service is
taxed in the DRC when *"le service rendu, le droit cédé ou l'objet loué, sont
utilisés ou exploités au pays"* (ordonnance-loi n° 10/001, art. 22-3), and
when the supplier domiciled abroad appointed no representant the tax *"[est]
payée[] par la personne cliente"* (art. 23). Art. 38-1 allows a deduction only
on an invoice *"dûment délivré[e] par un assujetti et mentionnant son numéro
impôt"*, which a supplier abroad never issues: this pack reads the tax as not
deductible. The tax owed is credited to `4478` and declared in the new box
`TVAPC`; with no deduction, the same amount lands on the cost of the service
(`tax_on_base`), as `SN-P-NR-18-ND` does in the Senegalese pack. The golden
year buys one such subscription. SYSCOHADA has no account for suppliers
abroad, so the supplier sits on `4011` with the others. Later finance laws
were not searched for a rule admitting the deduction; a reviewer should
confirm the reading.

## What it does not say

- **The two 2026 rates, 5 % and 1 %.** Reported only by the FEC, relaying the
  DGI and the DGDA at a briefing on 17 September 2026, which also said the
  DGI's systems had not yet configured either rate. A tax is not carried
  from a secondary source; once the primary text of the loi de finances
  rectificative n° 26/032 is in the register, `CD-S-5` (ciment) and `CD-S-1`
  (huile raffinée locale) belong here, at 4431, `supply_nature`.
- **The withholding of art. 53, al. 2** (OL 10/001, modified by the loi de
  finances n° 22/071, art. 32): mining companies withhold the VAT due to a
  state-owned supplier **when they pay its invoice**, on that supplier's
  account, and the Treasury does the same for suppliers of the State. This is
  a three-party withholding **on a payment**, not on an invoice
  (`docs/international.md`): the tax stays the seller's own debt, discharged
  by somebody else at a moment this socle's tax codes, fixed at the invoice,
  cannot see. No tax carries it here; the withheld amount is not modelled on
  either side of the transaction.
- **The facture normalisée as a clearance system**, not an e-invoicing
  profile. A DEF — physical or dematerialised — issues the invoice's
  authentication code and QR code as part of producing it, connected live to
  the DGI's own system (`sygdef.dgirdc.cd` for verification, an app «FACNO
  RDC»); a company without one uses the DGI's own e-UF application.
  `einvoicing.profile` stays empty because there is no EN 16931 profile to
  name, and `mandatory_from` too: the calendar a secondary source gives
  (1 December 2025, for every VAT-registered taxpayer) has no profile to
  attach a date to.
- **The current, article-by-article list of exemptions** (art. 15 and
  following), as amended from 2010 to 2026; only the 2023 amendment to
  art. 15-5 is cited.
- **The 2010 ordonnance-loi's exclusions from the right to deduct**, if it
  has one — no article naming non-deductible purchases (company cars, gifts,
  and the like) is cited. This pack carries no non-deductible tax code for
  that reason, not because none exists.
- **The official boxes of the printed VAT return**, readable on i-impôts.
- **A liste annuelle des fournisseurs**, a livraison-à-soi-même declaration
  line and a deduction bar on an untraceable supplier all appear in the
  *projet* de loi de finances pour 2026 — a bill, not an adopted law. None of
  the three is written here.
