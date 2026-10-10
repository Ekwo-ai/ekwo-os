# Central African Republic

Everything the Central African Republic adds to Ekwo, as data: the value
added tax of the Code général des impôts, where each rate posts, the
declaration it is filed on and the sentences the Code puts on an invoice. The
chart of accounts, the journals and the two statements are the SYSCOHADA
révisé shared by seventeen countries, and they are not written here: they are
copied from [`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`,
which the CI runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XAF, the CFA franc of the BEAC, at no decimal, CEMAC zone.

## Sources

| What | Text | Where |
|---|---|---|
| Rates, exemptions, deduction, invoice mentions, the return | Code Général des Impôts 2017, mise à jour 2023, édition officielle de la DGID | `finances.gouv.cf` |
| The frame of the rates and of facture mentions | Directive CEMAC n° 11/22-CEMAC-UEAC-010A-CM-38 du 10 novembre 2022 | `sgg.cg` |

**The pack rests on the 2023 edition of the CGI alone.** No promulgated loi
de finances for 2025 or 2026 is in the register; a document headed « PROJET
DE LOI DE FINANCES 2025 » (`finances.gouv.cf`, no law number, no date) is
cited only where the pack says it relies on a draft. A rate or an exemption
changed since 2023 would not appear here.

## What the pack says

- **19 %** on everything taxable (art. 257, in the wording of the loi de
  finances pour 2019 — the article itself carries no earlier date, and no
  change since has been found). **5 %** on a closed list by tariff number:
  04.01 (milks and creams), 07.01 to 07.14 (vegetables, roots and tubers),
  38.08 (insecticides and pesticides, excluding approved agricultural
  inputs), 94.02.10.19 (other medico-surgical furniture), 49.01.91.00
  (non-school books), 02 (meat and poultry), 94.02.10.11 (dentists' chairs).
  **Taxable base is rounded down to the nearest thousand CFA francs**
  (art. 256) before the rate applies — the pack does not model that rounding
  step itself, it is a fact for a local accountant to confirm against the
  engine's own rounding.
- **Goods and services post apart** — 4431 and 4432 on the sale side, 4451,
  4452 and 4454 on the purchase side — because the chart has the accounts.
  No fait générateur article (the equivalent of art. 141-142 elsewhere in the
  zone) was found in the 2023 CGI, so no tax here is `cash_basis`.
- **The 5 % list is wider than the CEMAC closed list.** Directive n° 11/22
  (art. 22-2 c) limits an optional reduced rate to six tariff numbers — milks
  04.01/04.02, bakery 19.05.90, rice 10.06, flour 11.01.00.10, fertiliser,
  pesticides 38.08. The Central African list keeps pesticides and milk but
  adds vegetables (07.01-07.14), books, meat and medical/dental furniture,
  none of which the directive's list covers. This pack transcribes the
  national CGI as written — a member state's own law, not the community
  directive, is what a taxpayer is charged — and records the gap here.
- **No surtax on the VAT.** No centimes additionnels or similar surtax was
  found in the 2023 CGI. `CF-S-19` and `CF-S-19-SRV` post the whole 19 % to a
  single account, with no split.
- **Exports at zero rate and exempt operations** each have their own box,
  `EXP` and `EXO`, both conditioned on the CGI 2023 art. 249 list of exempt
  operations — see *What it does not say* for the doubt over which version of
  that article is currently in force.
- **Deduction** (art. 276): the tax is recoverable, split by kind of purchase
  into `DEDIMMO` (immobilisations, 4451) and `DEDBS` (biens et services, 4452
  or 4454), with no article found restricting a specific category. Credit is
  reportable 12 months — without limit for exporters and investors above 100
  million FCFA — and refundable after three consecutive months of credit.
- **The declaration** is monthly for the real regime (art. 275 bis), due and
  paid by the 15th of the month following, with a compulsory « NÉANT »
  filing when there is no operation (art. 275 bis 2). Its boxes are named
  after what art. 275 bis makes a taxpayer declare, not after the printed
  form, whose name and box numbers are not published.
- **The invoice** carries, per art. 268: the seller's name, address and NIF;
  the date; the nature of the operation; the rate, the price excluding tax
  and the corresponding VAT; the customer's name, address and NIF; a number
  taken from a continuous series. Art. 269 requires a partly-taxable seller to
  keep the taxable and non-taxable shares apart.

**A service bought from a supplier abroad: `CF-P-NR-19`.** For intangible
services — licences, data processing and the supply of information, consulting
— *"la taxe sur la valeur ajoutée est applicable en Centrafrique lorsque le
prestataire est établi dans un pays étranger et le bénéficiaire en
Centrafrique"* (CGI, art. 250-2-b), and without an accredited representant the
tax is paid *"par la personne cliente pour le compte de la personne n'ayant
pas en Centrafrique un établissement stable"* (art. 250 bis), at 19 % (art.
257). The tax owed is credited to `4478` and declared in the new box `TVAPC`,
which the total of the tax due adds; the same amount is debited to `4454` and
deducted in `DEDBS` the same month. The golden year buys one such
subscription. SYSCOHADA has no account for suppliers abroad, so the supplier
sits on `4011` with the others. Art. 259 lists the documents that support a
deduction without naming this tax; the pack follows the CEMAC directive, art.
22, which waives the invoice conditions for foreign suppliers, and a reviewer
should confirm that the DGID applies it.

## What it does not say

- **The 15-day deadline of art. 275 bis contradicts art. 275 bis 1** in the
  same 2023 CGI edition, which sets a quarterly filing, also « for the real
  regime », due the 15th of the month after the quarter. No text says which
  taxpayers each article addresses. This pack keeps the monthly reading of
  art. 275 bis; `tax_report.json`'s `deadline` therefore rests on one of two
  articles that disagree, for a reviewer to settle.
- **The précompte of art. 166 bis, 166 bis 1 and 166 bis 5** — 3 % of the
  price including VAT, excluding VAT itself, withheld by a designated buyer
  (public bodies, real-regime companies, ONGs, projects…) on local purchases,
  services, rents and imports, with dispensations (water and electricity,
  Charte des investissements companies, rents under 50 000 FCFA/month). The
  seller must issue an invoice showing the withheld amount distinctly
  (art. 166 bis 5). This is an income-tax withholding at payment, a
  three-party mechanism (buyer, seller, treasury) the core's VAT-return
  engine cannot express. No tax code models it here.
- **The VAT withholding at source of art. 273 bis (loi de finances 2008)** —
  10 % of the price excluding tax, withheld by client companies a ministerial
  order designates — and the Treasury accountant's withholding of the VAT
  invoiced by suppliers of the State and local authorities (art. 275 bis,
  amended by the unadopted 2025 draft). The order and its list of companies
  are not in the register, and a base on the price rather than the tax is too
  unusual to model from a summary. Neither is carried here.
- **The margin-based VAT withholding of art. 256 bis** (loi de finances 2021,
  wholesale distributors of drinks and cigarettes) and **the 15 % final
  withholding of art. 166 bis 1** on service fees paid abroad are both out of
  scope for the same reason: withheld at payment, or an income tax rather
  than a VAT on an invoice line.
- **The 2025 draft finance law's reverse charge for non-resident suppliers**,
  found only in the unadopted « PROJET DE LOI DE FINANCES 2025 »: not
  modelled. The rule in force — the client pays for a supplier with no
  representant (art. 250 bis) — is `CF-P-NR-19`, above.
- **The e-Tax portal**, reported by the press as launched around 24 March
  2025 for télédéclaration and télépaiement, has no official URL or
  specification in the register; the `portail` source points to the
  Ministry's site, `finances.gouv.cf`. `pack.json`'s `einvoicing` fields stay
  empty. The only invoicing obligation in the 2023 CGI, art. 271, is a retail
  cash-register receipt (« machine à bande enregistreuse »), not a normalised
  or electronic invoice, and not a clearance system between businesses.
- **The printed VAT return's own boxes.** Art. 275 bis says what must be
  declared, never the form's name or box numbers; this pack's boxes are named
  after that content.
- **Sango**, the country's second official language alongside French, is not
  confirmed by an official source in the register; the pack is written in
  French, as every OHADA member is.
- **Which version of art. 249 is in force.** The 2023 CGI edition lists one
  set of exemptions; the unadopted 2025 draft cites, and would replace, a
  different, older-looking art. 249 with a twelve-point list. This pack
  follows the 2023 edition, the only one whose entry into force is
  established, and does not anticipate the draft.
- **Late-payment terms between businesses**: no Central African or CEMAC text
  found.
