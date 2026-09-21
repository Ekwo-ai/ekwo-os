# Guinea

Everything Guinea adds to Ekwo, as data: the value added tax of the Code
général des impôts, where each rate posts, the declaration it is filed on and
the sentences the Code puts on an invoice. The chart of accounts, the journals
and the two statements are the SYSCOHADA révisé shared by seventeen countries,
and they are not written here: they are copied from
[`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`, which the CI
runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden quarter proves the pack is coherent and nothing about whether it is
right. Currency GNF, the franc guinéen, at no decimal. Guinea belongs to
neither the UEMOA nor the CEMAC: its VAT is entirely national, with no
community directive to read alongside the Code.

## Sources

| What | Text | Where |
|---|---|---|
| Rates, exemptions, deduction, the two prélèvements, invoices, the return | Code général des impôts, loi ordinaire L/2021/032/AN du 4 juillet 2021, promulguée par décret D/2021/236/PRG/SGG du 21 juillet 2021, applicable depuis le 1er janvier 2022 | the copy hosted by ITIE Guinée, `itie-guinee.org` |
| The 10th of the month, the e-Tax/SAFIG platform, the deduction table, the refund rule | Loi de finances pour 2025, loi n° L/2024/023/CNT | `dgi.gov.gn` |
| Filing and payment | eTax Guinée | `etax.gov.gn` |

**The loi de finances pour 2025 is a scanned PDF with no text layer**, read
back page by page against the images (22 pages). **The projet de loi de
finances pour 2026** was read too, but a bill is not law: nothing it proposes
is in this pack. **The loi de finances pour 2016**, cited by a secondary,
unsourced claim that the rate once stood at 20 %, is a scan that could not be
read; the Code of 2022 fixes the rate at 18 % and this pack follows it. **The
lois de finances pour 2023, 2024 and 2026 (définitives) were not read**: only
what the 2025 law itself quotes from the 2024 one is in this pack.

## What the pack says

- **18 %** on everything taxable (art. 373-I), goods and services posting to
  separate accounts, 4431 and 4432, because the chart has them. **Zero rate**
  on direct exports and the services tied to them, international transport of
  goods and passengers, and maritime commerce, fishing and rescue vessel
  operations (art. 373-II) — `GN-S-EXP`, box `EXP`. A **separate, wider list**
  of exemptions without a stated right to deduct — food staples, pharmaceuticals,
  school books and supplies, medical care, approved teaching, residential
  leases, financial and insurance operations, among others (art. 362-I) —
  `GN-S-EXO`, box `EXO`. The distinction the Code itself draws, between an
  article that zero-rates and an article that exempts, is kept as two boxes
  rather than folded into one, as `packs/sn/` already does for its own export
  and exemption articles.
- **Imports are deductible on the customs bulletin** (art. 365-366): the tax is
  due at 18 % on release for consumption, and `GN-P-IMP-18` posts it straight
  to 4452 and box `DEDBS`, the same box ordinary domestic purchases reach,
  since the Code's own deduction table (art. 373 Sexies-V, loi de finances pour
  2025, art. 25) lists imports beside them rather than apart.
- **The prélèvement forfaitaire** (art. 251 à 255): the State, local
  authorities, public and mixed-economy bodies, telecom, mining, oil and
  banking or insurance companies withhold 10 % on a purchase of goods or
  services from a supplier not registered for VAT, 5 % on certain commissions
  — distributors, SIM cards, mobile money. The supplier charges no VAT at all,
  so `GN-P-WHT-10` and `GN-P-WHT-COM-5` carry `treatment: not_subject` and no
  box: this is an advance of income tax, not a line of the VAT return, exactly
  as Singapore's own withholding on interest and royalties reaches no box of
  its GST return.
- **The declaration** carries what art. 373 Sexies-III says it carries: the
  month's taxable and exempt operations, the regularisations, the tax
  collected, the tax deductible on imports, on goods delivered and on services
  performed. Its boxes are named after that content, **not after the printed
  form**, whose model and box numbers are published in no text found — as at
  Senegal and Chad. It is monthly (art. 366-II, 373 Sexies-I) and due on the
  **10th** of the following month, since the loi de finances pour 2025 (art. 13)
  moved it there from the 15th the 2022 Code had set; a nil return is
  compulsory (art. 373 Sexies-IV).
- **The invoice** carries a unique number in "une séquence chronologique et
  continue" (art. 383-VI-7°) and, in place of a rate, the reference to the
  article that zero-rates or exempts the operation (art. 383-VI-10°): the two
  mentions this pack declares.

## What it does not say

- **The seller's side of the 50 % VAT withholding.** Article 373 Ter makes a
  client who is the State, a local authority, a public or mixed-economy body,
  a telecom company, or a company that imports, stores, distributes or mines —
  buying from a VAT-registered seller — withhold 50 % of the tax the invoice
  shows and pay it to the Treasury directly; the seller still declares the
  full tax collected and takes the retained half back as a deduction the
  Code calls "Déduction de la retenue 50% TVA". This is the same three-party
  shape `docs/international.md` already names for Senegal's *précompte* and
  Côte d'Ivoire's *TVA pour compte de tiers* — a debt that stays the seller's
  while a third party remits it — under "The seller's side of a withholding by
  the buyer": no posting expresses a buyer's own remittance reaching the
  seller's books, and this pack carries no tax code for art. 373 Ter. A client
  invoiced under it still owes the full tax on paper; only the cash received
  and the deduction on the return differ from an ordinary sale, and neither is
  a fact the invoice's own lines can carry.
- **The general fait générateur of a domestic sale or service** — whether the
  tax is due on delivery, on the invoice, or on collection — was not isolated
  as its own article in the text read; `documents.tax_point` is therefore
  absent from this pack rather than guessed, unlike Senegal's or Côte
  d'Ivoire's, which cite one.
- **The water and electricity allowance** (art. 368): 20 000 GNF and 50 000 GNF
  taken off the taxable base of each monthly bill. A fixed amount off a base
  is not a rate, and the engine's taxes post a rate; the pack carries no code
  for it.
- **The proportional stamp duty on public contracts and business-to-business
  agreements** (art. 599, loi de finances pour 2025, art. 16): 1 %, 0,5 %,
  0,25 % or 0,10 % by bracket. It taxes the contract, not a stated line of the
  invoice, and whether it is in practice passed on as one was not found in any
  text read.
- **"TVA d'après les débits" (art. 366 bis) and "TVA sur marge" (art. 410 bis)**,
  the two remaining mentions art. 383-VI names, are options this pack has not
  read the substance of; it declares neither the mention nor the regime behind
  it.
- **The franchise below 1 000 000 000 GNF of turnover** (art. 359-360) is
  described in the Code as a threshold, but no article found says a franchised
  taxpayer may not show VAT on an invoice, unlike Senegal's *contribution
  globale unique* (art. 448-2): this pack carries no `small_business` mention.
- **The Déclaration Mensuelle Unique**, whose Excel model is published on
  `dgi.gov.gn`, was not opened; whether it carries the VAT return itself,
  beside it, or replaces its printed form was not verified.
- **The e-TVA/SAFIG API** (art. 383-V, loi de finances pour 2025, art. 27) has
  no published specification, format or deployment calendar: `einvoicing`
  carries the obligation's legal basis and nothing else.
