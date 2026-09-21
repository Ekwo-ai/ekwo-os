# Senegal

Everything Senegal adds to Ekwo, as data: the value added tax of the Code
général des impôts, where each rate posts, the declaration it is filed on and
the sentences the Code puts on an invoice. The chart of accounts, the journals
and the two statements are the SYSCOHADA révisé shared by seventeen countries,
and they are not written here: they are copied from
[`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`, which the CI
runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XOF, the CFA franc of the BCEAO, at no decimal.

## Sources

| What | Text | Where |
|---|---|---|
| Rates, exemptions, tax point, deduction, précompte, invoices, the return | Loi n° 2012-31 du 31 décembre 2012 portant Code général des impôts | the official PDF of the Ministry of Finance, `apimfb.finances.gouv.sn` |
| The 10 % rate extended to every service of an approved tourist accommodation | Loi n° 2015-06 du 23 mars 2015, art. 34 | `vie-publique.sn` |
| Electronic invoicing (art. 447-II), the précompte of public bodies restored (art. 372) | Loi de finances pour 2025, loi n° 2025-02 du 6 janvier 2025 | `apimfb.finances.gouv.sn` |
| The 15th of the month | DGID, calendrier des déclarations | `dgid.sn` |
| Filing | SENTAX, compulsory for the large-taxpayer office from 1 September 2026 | `sentax.dgid.sn` |
| The frame of the rates | Directive n° 02/2009/CM/UEMOA, art. 29 nouveau | AIFO-UEMOA |

**No consolidated edition of the Code later than 2013 is published by the
administration.** The state of each article was rebuilt from the 2013 text and
the amending laws the ministry publishes; a privately annotated edition of
October 2025 served only to date each paragraph, and is not in the register.

## What the pack says

- **18 %** on everything taxable (art. 369, al. 1); **10 %** on the services of
  an approved tourist accommodation, restaurant included (art. 369, al. 2) —
  `supply_nature`, because a restaurant that is not such an establishment
  charges 18 %. Exports are *exempt with a right to deduct* (art. 361, 14) and
  380 a), not zero-rated, and the other exemptions of art. 361 have their own
  box, which is what the statement of exemptions of art. 449-2 is drawn from.
- **Goods and services post apart** — 4431 and 4432 on the sale side, 4451,
  4452 and 4454 on the purchase side — because the chart has the accounts. A
  service is taxed when it is performed (art. 362-3): there is no general cash
  basis in Senegal and no option for it, so no tax here is `cash_basis`.
- **The précompte** (art. 372): the buyers the article names — the State and
  public bodies, water, electricity and telephone concessions, construction
  firms of the large-taxpayer office, cement and oil distributors for transport
  — withhold the whole tax, pay the supplier the price before tax, deduct what
  they withheld and pay it over on a separate declaration. `SN-P-18-PC` is that
  purchase: 4452 in debit, 4478 in credit, the supplier owed the net.
- **The tax a foreign supplier owes** (*TVA pour compte*, art. 355-3) is owed by
  the buyer and, since the finance law for 2021, deductible only where the
  service transfers know-how (art. 383 f). Two codes, one deductible and one
  not.
- **The declaration** carries what art. 449-4 says it carries: the taxable and
  exempt operations, the tax, the deductions, the credit. Its boxes are named
  after that content, **not after the printed form**, whose model is fixed by a
  note of the director general and is not published. It is due on the 15th
  (art. 363-1, 449-1). Monthly under the *réel normal*, quarterly under the
  *réel simplifié* (art. 449-3): the cadence follows the regime, so the pack
  proposes none.
- **The invoice** carries a unique number « basé sur une séquence chronologique
  et continue » (art. 447-I-5), the reference to the article of an exemption,
  of the TVA pour compte, and — for a taxpayer under the *contribution globale
  unique* — no tax at all (art. 448-2).

## What it does not say

- **The printed return.** Nothing public gives its boxes; SENTAX and the
  taxpayer's space are where they can be read.
- **The précompte on the supplier's side.** The supplier's tax falls due when
  it is paid (art. 362-5 b) and is paid by the buyer, not by them; how the
  supplier's books clear it is written in no text found, and the pack does not
  guess it.
- **The declaration of précompte and the TVA pour compte** are filed apart from
  the return, and a pack carries one form (`docs/international.md`). The TVA
  pour compte has a box here, said to be a transcription; the précompte waits
  on 4478 with none.
- **Electronic invoicing**: the Code has required it since 2025 (art. 447-II),
  and no order has fixed its format, its platform or its date.
- **The BRS** (art. 200), 5 % of a service invoice withheld from a supplier who
  is not on the real regime, is an income tax, withheld on the payment rather
  than charged on the invoice; the core has no withholding on a payment.
- **Late-payment terms between businesses**: no Senegalese or UEMOA text found.
