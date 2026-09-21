# Gabon

Everything Gabon adds to Ekwo, as data: the value added tax and the
contribution spéciale de solidarité (CSS) of the Code général des impôts,
where each rate posts, the declaration it is filed on and the sentence the
law puts on an invoice. The chart of accounts, the journals and the two
statements are the SYSCOHADA révisé shared by seventeen countries, and they
are not written here: they are copied from [`packs/ohada/`](../ohada/README.md)
by `scripts/ohada-packs.mjs`, which the CI runs to refuse a copy that has
drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XAF, the CFA franc of the BEAC, at no decimal.

## Sources

| What | Text | Where |
|---|---|---|
| Rates (art. 221), exemptions (art. 210), territoriality of digital services (art. 211 ter), the non-resident digital-platform regime (art. 248 septies to nonies), electronic invoicing (art. P-832 ter), the 10 % late-payment penalty (art. P-1000) | Loi n° 002/2026 du 17 juillet 2026 portant loi de finances rectificative de l'année 2026 (LFR 2026), Journal officiel n° 123 bis | fac-similé du JO hébergé par `directinfosgabon.com` |
| Fait générateur and exigibility (art. 212, 213), invoicing (art. 234 to 237), deduction exclusions (art. 224, 225), the retenue à la source on non-residents (art. 240), the CSS (textes fiscaux non codifiés, art. 13 to 34) | Code général des impôts, édition 2019 | reproduction hébergée par `africa-laws.org` |
| The declaration portal | e-Tax Gabon (SIGIGA e-contribuable) | `e-tax.dgi.ga` |
| The floor of a reduced VAT rate, and how a précompte or a surtax fits the common system | Directive CEMAC portant harmonisation des législations en matière de TVA du 10 novembre 2022 | `sgg.cg` |

**No edition of the Code later than 2019, consolidated or not, is published
by an administration this pack could reach.** `dgi.ga`, `gouvernement.ga` and
the page the DGI names for its e-invoicing system, `dgi.ga/e-fact/`, all
refused the connection on 21 September 2026. The loi de finances pour 2026
itself (loi n° 041/2025 du 29 décembre 2025, JO n° 96 quater), which created
several of the articles the LFR 2026 rewrites, was not found either — only a
secondary summary of it (Deloitte, 9 April 2026) was read, and is cited
nowhere in `taxes.json`, `tax_report.json` or `pack.json`. Every article of
the 2019 Code cited here was checked, one by one, against the full text of
the LFR 2026 — the only text more recent that could be read — to confirm the
LFR 2026 does not rewrite it; where it does, the LFR 2026 wording is what is
cited.

## What the pack says

- **Four positive rates** (art. 221 nouveau, LFR 2026): **18 %** the norm;
  **10 %** on pièces détachées automobiles, essieux automobiles, carreaux de
  construction and pointes; **5 %** on journaux et magazines importés and eau
  minérale importée; **3 %** on fer à béton fabriqué au Gabon, a rate the LFR
  2026 created on 17 July 2026 and that sits **under the 5 % floor** the
  CEMAC directive sets for a reduced rate (art. 22, 2°, c)) — a gap this pack
  records rather than corrects. **Zero-rated**: exports, international
  transport, fuel supply and maintenance of aircraft and ships on
  international traffic, and services whose place of taxation is outside
  Gabon (`GA-S-0-EXP`, `GA-S-0-SRV`). **Exempt** (art. 210 nouveau): a list of
  first-necessity goods, insurance, school books and periodicals, electric
  vehicles and, conditionally, gasoil for industrial fishing (`GA-S-EXO`).
- **A service is taxed at collection** (art. 213 nouveau, LF 2015): unlike
  goods, whose tax is due on delivery, a service's tax waits at 4432 until
  the invoice is paid, then moves to 4431 — `GA-S-18-SRV` carries
  `cash_basis: true`, on the model of `packs/ci/`.
- **Deduction excludes** (art. 224, 225): lodging, hospitality, catering,
  entertainment and passenger transport (except for the professionals of
  those activities), petroleum products other than fixed industrial fuel,
  goods given away or sold far under price, and — the last bullet of art.
  224 — services available in Gabon rendered by a foreign provider, which
  art. 240 already makes the client's own liability, retenue à la source, to
  pay over on the provider's behalf. `GA-P-NR-18-ND` folds that retained tax
  into the cost of the service, `GA-P-18-ND` folds in the excluded domestic
  charges and the vehicles and equipment of art. 225.
- **The contribution spéciale de solidarité (CSS)**, 1 % of a base that
  excludes VAT and the CSS itself (art. 25, 24 nouveau of the textes fiscaux
  non codifiés), applies to nearly every operation a VAT-registered company
  makes, once its own turnover reaches 30 000 000 FCFA (art. 14). It is a tax
  of its own, the way the OHADA README asks of a surtax the return and the
  administration keep apart, posted to account 446 (`GA-CSS-S`, `GA-CSS-P`) —
  see *What it does not say* for what this pack leaves out of it.
- **The declaration** is monthly, even with nothing to declare (mention
  « NEANT »), due on the 20th of the following month (art. 237); exporters
  attach their customs references. Nothing found gives a quarterly régime
  for an ordinary taxpayer — only the simplified régime of a non-resident
  digital platform files quarterly (art. 248 octies), which this pack does
  not model. The boxes of `tax_report.json` follow what a return has to
  carry in substance, not an official numbering: no text found publishes the
  imprimé's own boxes, the same gap `packs/sn/` records for Sénégal.
- **The invoice** carries the assujetti's name, address and NIF, the rate,
  the price before tax and the corresponding tax, and the client's own
  identification if it is an assujetti (art. 234 to 236) — nothing found
  requires citing the article of an exemption, unlike Sénégal's art. 447-I-5.
  The CSS's own text (textes fiscaux non codifiés, art. 28) is more precise
  and asks, product by product, for the mention « exonérée » or « prise en
  charge Etat » where it applies.
- **Electronic invoicing** is mandatory (art. P-832 ter, LFR 2026) through a
  homologated device or an equivalent document, and since art. 223 nouveau
  only the tax on such a document is deductible. No official text read gives
  a starting date, a technical profile or the device's own numbering — the
  DGI's own page for it, `dgi.ga/e-fact/`, could not be reached from this
  pack's research. `einvoicing.mandatory_from` and `.profile` stay null, on
  the model of `packs/sn/` and `packs/ci/`.

## What it does not say

- **The CSS's own retenue à la source.** Art. 26, alinéa 3 of the textes
  fiscaux non codifiés has a client who is itself assujetti to VAT withhold
  the CSS a supplier invoices and pay it over directly, for the supplier's
  account; alinéa 2 does the same for the State, local authorities, public
  establishments and State companies. This pack does not model either
  direction of that withholding — `GA-CSS-S` posts as though the seller
  collected the CSS in cash, `GA-CSS-P` as though the buyer simply bore a
  non-recoverable cost — because the ledger effect of a tax withheld and
  remitted by someone else on the taxpayer's behalf is a "retenue au
  paiement" the core does not carry, one of the gaps `docs/international.md`
  names.
- **The précompte de TVA of the État** (art. 239): the Trésor public
  withholds 40 % of the VAT it owes a supplier on a public contract and pays
  it directly to the DGI, handing the supplier a quittance. This is exactly
  the case Sénégal's own README could not model from the supplier's side
  either — here the text is fuller (a fixed 40 %, a quittance), but the same
  "retenue au paiement" gap applies, and this pack does not guess how the
  supplier's books show a receivable paid by proxy.
- **The golden year cannot combine a VAT code and a CSS code on one
  document line.** In practice the two sit side by side on the same invoice
  line, both computed on the same base; `golden/scenario.json`'s `lines`
  carries one `tax` per line, so `GA-CSS-S` and `GA-CSS-P` are defined and
  compile but are not exercised by the golden year — a "taxe sur taxe" case
  the brief this pack was built from names as one the core does not yet
  carry.
- **The threshold to become an assujetti.** Art. 208 (not rewritten by the
  LFR 2026) sets it at 150 000 000 FCFA — 500 000 000 FCFA for forestry — a
  figure this pack's own research first read as 60 000 000 FCFA from a
  secondary source (PwC, last reviewed 6 August 2026) later found to
  contradict the CGI article actually read. The higher figure is the one
  read directly in the official-adjacent text; the lower one is not cited
  anywhere in this pack. A registration threshold has no field in this
  pack's schema either way.
- **Excise duties** (droits d'accises, art. 250, 251) on beer, wine,
  champagne and tobacco, and the environmental tax on packaging (textes
  fiscaux non codifiés, art. 20): both real but not systematic on an
  ordinary invoice, and neither is in the golden year.
- **The real-estate VAT régime** for a property developer (art. 248 quater
  and following) is a separate mechanism this pack does not model.
- **The declaration's own box numbers.** SENTAX-style detail exists for
  Sénégal; nothing equivalent for Gabon's e-Tax was reachable.
