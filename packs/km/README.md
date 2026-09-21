# Comoros

Everything the Comoros add to Ekwo, as data: the *taxe sur la consommation*
(TC) of the Code général des impôts, where each rate posts, the declaration
it is filed on and the sentences the Code puts on an invoice. The chart of
accounts, the journals and the two statements are the SYSCOHADA révisé shared
by seventeen countries, and they are not written here: they are copied from
[`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`, which the
CI runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden month proves the pack is coherent and nothing about whether it is
right. Currency KMF, the Comorian franc, at no decimal.

**The Comoros have no value added tax and belong to no monetary union.**
Neither the UEMOA nor the CEMAC harmonises a tax here: `packs/ohada/README.md`
harmonises only the chart of accounts. What this pack carries is a *taxe sur
la consommation* — an indirect tax on imports, on buy-resell and production
activities, and on services (CGI art. 139) — which does not work like a VAT:
the tax a supplier charges on a local purchase is nobody's to deduct, and the
only credit the law gives is the tax paid in customs at import, imputable and
never refundable.

## Sources

| What | Text | Where |
|---|---|---|
| Rates, base, exemptions, declaration, invoice mentions | Code général des impôts de l'Union des Comores, édition 2023 (à jour de la LFR 2022 et de la LF 2023) | AGID, `dgi.gouv.km`, lu par une copie Wayback — le domaine ne résout plus en DNS le jour de ce pack |
| The declaration form's columns and lines | Déclaration mensuelle et unifiée de la TC et de la TS | AGID, lue par une copie Wayback |
| The 2026 deadline for compulsory e-filing | Loi de finances pour 2024, art. L.4 du livre de procédures fiscales modifié | copie déposée par les Comores à l'OMC dans leur dossier d'accession |

**No later law of finances was read.** The CGI 2023 is up to date with the
LFR 2022 and the LF 2023; the loi de finances pour 2024 was read only for its
provision on e-filing. The lois de finances 2025, 2026 and any loi de finances
rectificative of either year were not found online and were not read: any
change they made to art. 152 is not in this pack.

## What the pack says

- **10 %** is the general rate of art. 152 (`KM-S-10` for goods, `KM-S-10-SRV`
  for services). Five rates apply to a named activity: **3 %** on the supply
  of water and electricity (`KM-S-03-UTIL`) and on inter-island transport
  tickets (`KM-S-03-TRANSPORT`); **5 %** on catering, banking and fixed
  telephony (`KM-S-05-SRV`) and on international transport tickets
  (`KM-S-05-TRANSPORT-INTL`); **7.5 %** on mobile top-ups
  (`KM-S-075-MOBILE`); **25 %** on casinos (`KM-S-25-CASINO`); and **0 %** on
  a fixed list of staples — meat, poultry, fresh or frozen fish, plain rice,
  flour, sugar, medicines, infant formula (arrêté n° 17-065/MFB/CAB du 19
  septembre 2017) — which is `KM-S-00`, a rate of art. 152 and not an
  exemption of art. 141. Every pair of codes that shares a rate (the two 3 %,
  the two 5 %) shares its box on the declaration and differs only in the
  account it posts to and the article it cites, exactly as `packs/sn/`
  already splits goods from services at one rate.
- **The official return has one `Exonérés` column, not two.** Nothing on the
  form distinguishes a genuine exemption of art. 141 (`KM-S-EXO`) from a
  first-necessity sale taxed at nought (`KM-S-00`) or from an export
  (`KM-S-EXPORT`): all three post to the same box `EXO`. The pack keeps them
  as three codes, because the treatment each carries — `exempt`, `domestic`,
  `export` — governs the invoice mention and not the return, and a reader who
  wants to know why a line pays no tax should not have to guess from one
  shared box.
- **The 15 % column of the official form has no base in the CGI 2023 read for
  this pack.** Article 152 knows six rates — 0, 3, 5, 7.5, 10, 25 % — and the
  form prints a seventh. Whatever introduced it is not in the loi de finances
  pour 2024 either, the one later text this pack read. It is not written
  here: a tax invented to fill a form column would be the very thing this
  project refuses to do.
- **The tax a local supplier charges is a cost, never a claim on the
  administration.** No article organises a deduction of the TC paid on a
  domestic purchase, unlike a VAT; `KM-P-10` posts it with `tax_on_base`,
  exactly as `packs/us/` posts a sales tax reimbursement nobody gets back.
- **The tax paid in customs at import is an acompte, not the same thing as a
  deduction.** Art. 150 lets it offset the TC due on the resale that follows,
  and forbids in as many words that "la régularisation" ever end in a refund.
  `KM-P-IMP-10` posts it to 4452 and to the box `ACPT`, which the return's
  own line 3 already names; the excess a month leaves unused sits in `CRED`
  (line 6) until a later month absorbs it, because nothing here can be turned
  into cash.
- **A service bought from a supplier with no establishment in the Comoros is
  self-assessed by the buyer** (art. 149, in the wording of the LFR 2020 and
  the LFR 2022) — `KM-P-NR-10`, `treatment: foreign_services_received`. What
  the article does not say is whether that self-assessed tax is deductible;
  the pack assumes it is not, on the same ground as a domestic purchase, and
  posts it the same way: cost plus a liability to 4478.
- **The invoice** carries what art. 148 lists — issuer and buyer identity and
  NIF, date, serial number, the nature and quantity of what was supplied, the
  amount before tax, the TC rate and amount, the amount including tax — and
  the sentence the article prints in full: a TC missing from an invoice is
  read as included in the price. `mentions.no_tax_mentioned` carries that
  sentence on every invoice, `always`, because the closed vocabulary of
  `applies_when` has no value for "the tax is missing from this document."
  Whether the invoice actually omits it is not something this pack's rendered
  mention can test.
- **No article fixing the fait générateur (delivery, payment or invoicing)
  was found.** `tax_point` is declared `invoice_if_issued` because art. 148
  is the one article that makes an invoice compulsory at every operation; it
  is a choice made for want of a better one; a Comorian tax adviser should
  confirm or correct it.
- **Numbering** follows only what art. 148 asks for — a serial number — and
  not the continuous, gapless sequence Senegal's Code makes explicit: the
  pack declares `sequential`, the weaker of the two, rather than overclaim a
  continuity requirement the text does not state.

## What it does not say

- **The 15 % rate of the official form.** No base found; see above.
- **The lois de finances 2025 and 2026, and any LFR of either year.** Not
  found online; art. 152 and art. 141 may have moved since the LF 2023.
- **The date each current rate of art. 152 took effect.** The article was
  amended by the LF 2018, 2019, 2020 and the LFR 2020; the CGI 2023 gives the
  list of amending laws and not a table of what each one changed. Every tax
  of this pack carries `valid_from: 2020-01-01`, the latest law in that list,
  which is an approximation and not a finding.
- **The call-termination annex tax** (50 KMF per minute on incoming calls,
  art. 152 in fine) does not attach to any sale invoice line and is not
  written here.
- **The *Acompte sur Impôt*** (10 % at import for an importer not registered
  with the DGME, per the IMF) is a customs-level levy on an income tax, not a
  line of a sales invoice, and its own article was not found.
- **The *Taxe sur les Rémunérations Extérieures*** and the 10 % withholding
  on rent (art. 111) both exist in the texts read but neither reaches an
  ordinary sales invoice: the first has no article isolated, the second
  appears on a rent receipt.
- **The crédit-bail exception to non-deductibility** (art. 141-16) is named
  in the exemption list but its mechanics — what is exempt, for whom, under
  what conditions — were not read in enough detail to post; `KM-P-10` does
  not carry a crédit-bail variant.
- **Where the self-assessed tax of `KM-P-NR-10` is declared.** No box was
  found for it: the form read for this pack carries only the import acompte
  on line 3.
- **The cash-register requirement** of art. 41-2 (turnover ≥ 20,000,000 KMF)
  names no format and no certified device, and the order that was meant to
  fix them was not found — nothing here models a fiscal device or a clearance
  flow, consistent with a secondary source that found none either.
- **Electronic filing.** Compulsory from 1 January 2026 for medium and large
  taxpayers (LF 2024), but no working teledeclaration portal or URL was
  found; `einvoicing` stays null throughout. The register's one `portal`
  entry (`agid`) is the administration's own website, where the CGI and the
  declaration form are published — not a filing platform: the deposit art.
  149 describes is still a paper one, "en double exemplaire", at a tax
  centre.
- **An official translation of the CGI or of the SYSCOHADA chart in Arabic or
  Shikomori.** The Constitution names French, Arabic and Shikomori as
  official languages, but the tax texts read for this pack are written only
  in French, and no official translation of either text was found in either
  language: `packs/km/i18n/` does not exist, on the same ground
  `packs/ohada/README.md` gives for Cameroon's English, Equatorial Guinea's
  Spanish and Guinea-Bissau's Portuguese.
