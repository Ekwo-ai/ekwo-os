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

**Two texts read as images.** The décret n° 23/10 and the circulaire n° 005
are scanned PDFs with no text layer; only their first pages and the passages
this pack cites were read back against the image, not the full text. **The
loi de finances rectificative n° 26/032 du 07 août 2026**, which a federation
of employers (FEC) reports as adding rates of 5 % and 1 % from 7 August 2026,
was not found as a primary text at any government URL tried on 21 September
2026 — only the FEC's account of a briefing by the DGI and the DGDA. Its own
publisher (the DGI) says the two rates were **not yet configured** in its own
systems (e-DEF, e-MCF, i-impôts) as of 17 September 2026. Neither rate is in
this pack: see *What it does not say*.

## What the pack says

- **16 %** on everything taxable (art. 35); **8 %** since 1 January 2023 (art.
  35, loi de finances n° 22/071, art. 30) on a closed tariff list of 24
  positions — meats, offal, frozen and salted fish, rice, sugars, infant
  milks, table water, iodised salt, household soap, matches — and on domestic
  air tickets, `supply_nature` because the pack cannot see the tariff
  position or the ticket's route by itself. **0 %** on exports (art. 35).
  **Exempt** operations of art. 15 and following, cited at the level of the
  principle: the list itself, amended piecemeal from 2010 to 2023 (only art.
  15-5 was read in a source that names its own amendment), was not
  reconstructed article by article. `CD-S-EXO` carries the reference to
  section 3 of the OL and no more; a reviewer should read art. 15 before
  relying on it.
- **Goods and services post apart** — 4431 and 4432 on the sale side, 4451,
  4452 and 4454 on the purchase side — as `packs/sn/` already does, because
  the chart has the accounts.
- **The rate itself has an uncertain start date.** OL 10/001 was signed 20
  August 2010; its own art. 78 gives it "dix-huit mois à dater de sa
  signature" to enter into force, without stating the day itself in the text
  read. `valid_from: "2010-08-20"` is the date the law was signed, not
  necessarily the date the 16 % rate first applied — a date that could be
  anywhere up to eighteen months later, and that no primary source read here
  confirms. The FEC briefing mentions an ordonnance-loi n° 001/2012 of 21
  September 2012 amending the tax, unread beyond its title (a scanned PDF).
  This is a caveat on the date, not on the rate: every secondary account read
  agrees the DRC has taxed at 16 % for well over a decade.
- **Import.** `CD-P-IMP-16` follows what the DGI itself says (§1 of the
  research this pack was built from): VAT at importation is liquidated by
  the Direction Générale des Douanes et Accises (DGDA), not the DGI, and
  deducted on the declaration of release for consumption. No article of OL
  10/001 fixing the exigibility or the deduction mechanism at import,
  separate from art. 35's rate, was identified in a source read directly.
- **The declaration** is monthly, due on the 15th of the month that follows,
  in duplicate, accompanied by payment; a nil declaration is compulsory in
  the absence of any operation (art. 60). Its boxes are named after what
  art. 60 and art. 35 make a taxpayer declare, **not after a printed form**:
  no model of the form, nor the numbering of its boxes, was found published.
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

## What it does not say

- **The two 2026 rates, 5 % and 1 %.** Reported only by the FEC, a
  federation of employers, relaying the DGI and the DGDA at a briefing on 17
  September 2026 — no primary text of the loi de finances rectificative n°
  26/032 du 07 août 2026 was found at any official URL tried. The DGI's own
  systems had not configured either rate as of the FEC's account. Adding a
  tax from a secondary source, to a rate the rate's own administration has
  not yet applied, is exactly the invented tax this pack refuses to carry;
  the day a primary text is read, `CD-S-5` (ciment) and `CD-S-1`
  (huile raffinée locale) belong here, at 4431, `supply_nature`.
- **The withholding of art. 53, al. 2** (OL 10/001, modified by the loi de
  finances n° 22/071, art. 32): mining companies withhold the VAT due to a
  state-owned supplier **when they pay its invoice**, on that supplier's
  account, and the Treasury does the same for suppliers of the State. This is
  a three-party withholding **on a payment**, not on an invoice — the exact
  gap `docs/international.md` already names for Senegal's *précompte* and
  Chad's art. 245, and for the same reason: the tax stays the seller's own
  debt, discharged by somebody else at a moment this socle's tax codes,
  fixed at the invoice, cannot see. No tax carries it here; the withheld
  amount is not modelled on either side of the transaction.
- **The facture normalisée as a clearance system**, not an e-invoicing
  profile. A DEF — physical or dematerialised — issues the invoice's
  authentication code and QR code as part of producing it, connected live to
  the DGI's own system (`sygdef.dgirdc.cd` for verification, an app «FACNO
  RDC»); a company without one uses the DGI's own e-UF application. This is
  a national clearance mechanism the einvoicing schema's EN 16931 profile
  field has no honest answer for, exactly as `packs/ci/` and `packs/td/`
  already found for the FNE and the FEN: `einvoicing.profile` stays empty
  because there is no profile to name, not because the obligation is
  unclear. `mandatory_from` stays empty too, in the same spirit as
  `packs/ci/`: the calendar a secondary source gives (1 December 2025, for
  every VAT-registered taxpayer) has no obligatory profile to attach a date
  to.
- **The current, article-by-article list of exemptions** (art. 15 and
  following). Only the 2023 amendment to art. 15-5 was read in a source that
  names its own text; the rest of the list, as amended from 2010 to 2026, was
  not reconstructed.
- **The full text of the 2010 ordonnance-loi's exclusions from the right to
  deduct**, if it has one — no article naming non-deductible purchases
  (company cars, gifts, and the like, as Senegal's art. 383 or Côte
  d'Ivoire's art. 372 do) was identified in a source read directly. This pack
  carries no non-deductible tax code for that reason, not because none
  exists.
- **The official boxes of the printed VAT return.** i-impôts is where they
  would be read; this pack was not built from a session there.
- **A liste annuelle des fournisseurs**, a livraison-à-soi-même declaration
  line and a deduction bar on an untraceable supplier all appear in the
  *projet* de loi de finances pour 2026 — a bill, not an adopted law at the
  date of this pack. None of the three is written here.
