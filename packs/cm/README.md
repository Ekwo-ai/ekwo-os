# Cameroon

Everything Cameroon adds to Ekwo, as data: the value added tax of the Code
général des impôts, where each rate posts, the declaration it is filed on
and the sentences the Code puts on an invoice. The chart of accounts, the
journals and the two statements are the SYSCOHADA révisé shared by seventeen
countries, and they are not written here: they are copied from
[`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`, which the
CI runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XAF, the CFA franc of the BEAC, at no decimal.

## Sources

| What | Text | Where |
|---|---|---|
| Rates, exemptions, deduction, invoices, the return | Code Général des Impôts, édition 2026 version française | the official PDF of the DGI, `impots.cm` |
| The rate, in plain language | La Taxe sur la Valeur Ajoutée (TVA) : ce que vous devez savoir | the fiche of the DGI, `impots.cm` |
| The reduced rate of 10 %, e-invoicing, taxation in real time | Circulaire n° 008/MINFI/DGI/LRI/L du 2 mars 2026 | `impots.cm` |
| The frame of the rates | Directive CEMAC portant harmonisation de la TVA (10 novembre 2022) | `sgg.cg` |
| Filing | Harmony, télédéclaration et télépaiement | `teledeclaration-dgi.cm` |

**No text was found for the fait générateur article** (the equivalent of
art. 141 of other codes of the zone): the CGI 2026 read for this pack covers
the rate (art. 142), the deduction (art. 143) and the invoice (art. 150), never
the date the tax falls due. `documents.tax_point` is left at `invoice_if_issued`
by convention with the other OHADA packs, not from a cited article — see
`documents.references.tax_point` in `pack.json`.

## What the pack says

- **17,5 % principal, plus 10 % of it as communal additional centimes (CAC)**
  — art. 142 (1) a) for the principal, Livre de fiscalité locale art. C 82 and
  C 83 (1) for the CAC — a displayed rate of **19,25 %**. The chart has no
  account for a communal surtax, so this pack routes it to **4422** « Impôts
  et taxes pour les collectivités publiques », apart from 4431/4432 where the
  principal lands, and into its own declaration box `CAC`, because C 83 makes
  it a distinct levy affected to the communes rather than the State. This is
  **not** the stacked-tax gap Côte d'Ivoire's README names for the AIRSI (`"a
  tax computed on another tax is a group, which the core does not carry"`):
  the AIRSI is computed on a base that already includes another tax (the VAT),
  which no single tax entry can express; the CAC is a fixed 10 % of the VAT
  amount *of the same tax entry*, split across two postings by `factor` — the
  same mechanism `CI-P-18-95` already uses to send 95 % of one tax to a
  recoverable account and 5 % to the cost of the line. `CM-S-1925` (goods, to
  4431) and `CM-S-1925-SRV` (services, to 4432) both carry it; `CM-S-10`, the
  reduced rate, does not — see *What it does not say*.
  **`rate` is the displayed 19,25 %, not the 17,5 % principal**, and the
  postings split it 90,909 % / 9,091 % (≈ 10/11 and 1/11, the three decimals
  `factor_percent` allows) rather than declaring the principal at 100 % and
  the CAC as a second `factor: 10` of it. The two are the same legal amount,
  but not the same figure once rounded: `document_tax_summary.tax_charged`
  (`supabase/migrations/20260918141605…`) rounds the whole computation once,
  and `post_document()`'s postings round `tax_amount` once and then share it
  out, the last posting of a side taking the remainder
  (`20260921145425…`) — the ledger and the invoice agree exactly only when
  the postings' factors sum to 100. A 17,5 % tax with a `factor: 10` CAC sums
  its side to 110 and rounds twice (`round(round(base × 17,5 %) × 1,10)`
  against the invoice's `round(base × 19,25 %)`), which can move a
  single-franc CAC entry by one franc — caught on `V6` of the golden
  (base 1 003, an amount that does not round evenly) before it shipped.
- **Goods and services post apart** — 4431 and 4432 on the sale side — because
  the chart has the accounts, as in `packs/sn/` and `packs/ci/`. No fait
  générateur article was found for services, so no tax here is `cash_basis`.
- **The reduced rate of 10 %** (art. 142 (1) a) and (3), loi de finances pour
  2026) applies to the sale of a social home to an individual for a first home
  under fiscal quitus, to the interest of the mortgage that finances it, and to
  its rental by a public or semi-public developer — this pack's golden only
  exercises the sale. Whether the CAC also applies to it is not settled: art.
  C 83 speaks of the CAC of "le taux général" and the circular of 2 March 2026
  describes only a "taux réduit de 10 %" without saying whether the 10 % CAC
  reaches it. `CM-S-10` therefore carries **no** CAC, rather than guess an
  11 % nobody wrote down.
- **Exports at zero rate** (art. 142 (4)) and **exempt operations of art. 128**
  each have their own box, `EXP` and `EXO`.
- **Deduction** (art. 143): the tax and its CAC are both recoverable — the
  fiche TVA confirms the 19,25 % is deducted as one figure — so the purchase
  taxes carry `rate: 19,25` and a single, plain posting (`factor` left at its
  default of 100) to one account, 4451/4452/4454 by kind of purchase, in one
  declaration box each (`DEDIMMO`, `DEDBS`) — not a 17,5 % rate with a
  `factor: 110`, which would round the deduction twice for the same reason
  the sale side does not. The pack does not split a recoverable CAC apart from
  ordinary recoverable VAT: unlike the invoiced tax, a deductible asset has no
  communal destination to keep apart, and the chart has no account for one
  either.
- **The declaration** carries what art. 152 says it carries — base by rate,
  tax due, deductions — under boxes named after that content and not after an
  official form, whose name and box numbers were not found. Due on the 15th
  of the month following (art. 152; fiche TVA), monthly.

## What it does not say

- **The withholding of VAT at payment** (art. 149 (2), 143). A buyer the law
  designates — the State, decentralised bodies, public and para-public
  companies, some non-profits and listed private companies — withholds the
  whole tax **when it pays the invoice**, against an attestation the DGI's
  system generates, which lets the supplier offset what was withheld. The
  invoice itself is unaffected (it is raised for the full amount); only the
  cash collected changes, at settlement, which `post_document`'s invoice and
  credit-note postings cannot reach — the same *retenue au paiement* gap the
  brief names and Senegal's *précompte* runs into for the supplier's side.
- **Non-VAT withholdings that sit on the same invoice**: the 2 % (or 2,2 %
  with CAC, 5 %, 10 %) advance of income tax withheld by a public buyer
  (art. 21), the 2 %–14 % *précompte sur achats* a seller collects from its
  own customers (art. 21 (3)), and the 5 % (+ CAC) withheld on fees paid to a
  person domiciled in Cameroon (art. 92 bis). These are income tax, not VAT;
  the core's tax mechanism feeds a VAT return, and none of these has one.
- **Suivi électronique de la facturation / taxation en temps réel** (Livre des
  procédures fiscales, art. L 8 bis and, since the loi de finances 2026, art.
  L 8 sexies): mandatory for designated sectors and every company of the
  Direction des grandes entreprises, and — since 2025 — a condition of VAT and
  corporate-tax deduction (art. 143 (1) b), 8 bis (2)). No arrêté fixing its
  format, its platform or a general rollout date is published: `einvoicing`
  stays empty, as Côte d'Ivoire's FNE does for the same reason — Ekwo neither
  generates, transmits nor certifies a document through it.
- **The formulaire's own boxes.** Art. 152 says what the declaration must
  carry, never its name or its box numbering; `tax_report.json` names boxes by
  content, as `packs/sn/` and `packs/ci/` do for the same gap.
- **Import VAT.** The fiche found only that the CAC applies to imports "comme
  aux importations" (art. C 82/C 83); no article on the fait générateur or the
  deduction of import VAT itself was located, so this pack carries no import
  tax code rather than borrow Senegal's or Côte d'Ivoire's article for a text
  that was not read here.
- **Excise duties** (art. 142 (1) b), 2 % to 50 % on the goods of annexe II,
  themselves carrying a 5 % CAC) are out of scope: a golden document taxed
  on a base that already includes another tax is the stacked-tax gap this pack
  avoids by not modelling excise at all, not by improvising a second posting.
- **Late-payment terms between businesses**: no Cameroonian or CEMAC text
  found.
