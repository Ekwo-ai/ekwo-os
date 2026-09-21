# Niger

Everything Niger adds to Ekwo, as data: the value added tax of the Code
général des impôts, where each rate posts, the declaration it is filed on and
the certified invoice (SECeF). The chart of accounts, the journals and the two
statements are the SYSCOHADA révisé shared by seventeen countries, and they
are not written here: they are copied from [`packs/ohada/`](../ohada/README.md)
by `scripts/ohada-packs.mjs`, which the CI runs to refuse a copy that has
drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XOF, the CFA franc of the BCEAO, at no decimal.

## Sources

| What | Text | Where |
|---|---|---|
| Fait générateur, exigibilité, the 19 % rate, filing dates, invoice mentions, deduction | Code général des impôts, edition 2012 — **repealed 1 January 2026** by ordinance n° 2025-22 of 14 July 2025, whose consolidated text could not be loaded (impots.gouv.ne "en maintenance", expired certificate) | `niger.eregulations.org` (read in full, 353 pages) |
| The 10 % and 5 % rates, and their extension | Ordonnance n° 2024-001 du 4 janvier 2024 (loi de finances 2024) | `finances.gouv.ne` |
| Export exemption (2025 wording) | Ordonnance n° 2024-59 du 31 décembre 2024 (loi de finances 2025) | `finances.gouv.ne` |
| Exemptions (art. 322 nouveau), exclusions of deduction (art. 339 nouveau), export exemption (2026 wording) | Ordonnance n° 2025-44 du 31 décembre 2025 (loi de finances 2026) | `finances.gouv.ne` |
| The certified invoice (SECeF) | Arrêté n° 473/MF/DGI/DL/CFI/DIV.L du 20 novembre 2020, obligation from 31 August 2021 | `finances.gouv.ne` (DGI communiqué) |
| The dematerialised platform | e-SECeF | `esecef.impots.gouv.ne` |
| The frame of the rates | Directive n° 02/2009/CM/UEMOA, art. 29 nouveau | AIFO-UEMOA |

**No consolidated edition of the new 2026 Code is published.** Every rate and
every obligation this pack states either comes straight from a finance law
(2024, 2025 or 2026) or from the repealed 2012 Code where a finance law does
not touch the point — the general rate, the fait générateur, the filing
calendar and the mentions of an invoice. Where a 2012 article is cited, the
article number of the new Code was not seen; the reading is corroborated,
never assumed, by what a later finance law does say (it re-writes the
articles of rates, exemptions and deduction, never those of the fait
générateur or the calendar).

## What the pack says

- **19 %** the normal rate since the 2012 Code (art. 226, al. 1), unmoved by
  the finance laws for 2025 and 2026, which rewrite the exemptions and the
  exclusions of deduction and leave the rate article alone. **10 %** on
  terrestrial transport of persons and goods, and on hosting and catering
  (loi de finances 2024, art. 226 nouveau) — `supply_nature`. **5 %** on a
  list of staples (sugar, edible oil, animal feed, manufactured milk, maize,
  millet, sorghum, rice and wheat flour) and on computer equipment for
  technical and vocational teaching, excluding consumables — sugar and oil
  were already at 5 % in 2012, the rest is the 2024 law's own addition, and
  the list read may be incomplete (a page break in the source).
- **Goods and services post apart** — 4431 and 4432 on the sale side, 4451,
  4452 and 4454 on the purchase side — because the chart has the accounts.
- **The fait générateur is the supply** — delivery for goods, completion for
  a service (art. 223) — **displaced by an earlier invoice**: "the finding of
  the fait générateur cannot come after the invoicing", and an advance,
  partial statement or partial invoice makes the tax due (art. 223, 224).
  `invoice_if_issued` says exactly that.
- **Exports** are exempt with a right to deduct (loi de finances 2026, art.
  322-7° nouveau); the other exemptions of art. 322 — agriculture, food
  staples, medicine, teaching, bare-property leases, water and electricity
  within the social tranches, and a dozen more — share one box, for lack of
  a seen article 802 that would let an invoice cite each in turn.
- **Exclusions of deduction** (loi de finances 2026, art. 339 nouveau):
  hosting, receptions, catering and shows; vehicles that carry persons;
  gifts over 20,000 F CFA excluding tax. Each is its own non-deductible
  code, its tax added to the cost of what was bought — corroborated by the
  same principle, without the figures, in articles 229 to 231 of the 2012
  Code. A transport service bought for the business is not in this list and
  stays deductible.
- **The declaration** carries what art. 256 says it carries: the total of
  operations, the detail of taxable operations, the deductible tax and the
  net tax due — its boxes are named after that content, **not after the
  printed form**, which was not found. Monthly, due the 15th of the
  following month (art. 254, 257); quarterly for the régime réel simplifié,
  due the 15th of April, July, October and January (art. 255, 257).
- **The certified invoice.** Since 31 August 2021, every taxpayer of the
  régime réel normal or simplifié issues invoices through a Système
  électronique certifié de facturation (SECeF), carrying a machine number
  (NIM), a SECeF/DGI code and a QR code (arrêté n° 473/2020); e-SECeF is its
  dematerialised form.
- **The invoice** carries the pre-tax price, the rate and amount of the tax,
  the seller's identity (name, address, RCCM, bank references, NIF) and the
  buyer's (name, address, NIF) — art. 251 of the 2012 Code. The new Code's
  own article (802, by the renvoi of its art. 23) was not read.

## What it does not say

- **The new Code's article numbers.** Every 2012 citation above may carry a
  different number in the Code in force since 1 January 2026; the site that
  would confirm it was unreachable at the date of this pack.
- **The précompte ISB**, an advance on the tax on profits charged on top of
  many domestic and public-sector invoices (arts. 90, 92 of the new Code):
  its 2026 rate was not found (2 %, 4 % or 7 % under the 2012 Code, on a
  different base). No tax carries it, and no figure here would not be
  invented.
- **The taxe sur les paiements en numéraire** (TPN, loi de finances 2026,
  art. 394 decies to noniesdecies): 1 % of cash payments over 100,000 F CFA,
  collected by the seller and due, like the VAT, the 15th. It is triggered
  by how an amount is paid rather than by what is invoiced — the gap
  `docs/international.md` already names for a withholding on a payment.
- **The retenue de conformité fiscale** (loi de finances 2025, art. 49 ter to
  octies): 10 % of the price withheld by public payers from a supplier not
  in order with the administration. Withheld on payment, not invoiced —
  the same gap.
- **Non-recoverable VAT above 2,000,000 F CFA paid other than through a
  banking channel** (loi de finances 2026): a condition of how the invoice
  was settled, decided after it is issued, which no tax code here can carry.
- **The printed VAT return and its box numbers.** Nothing public gives them;
  the telefiling platform is named in a secondary source only ("e-SISIC")
  and its URL was not verified, so it is not in the register.
- **A reverse charge on services received from a non-resident.** Senegal and
  Côte d'Ivoire have one; no Nigerien text was found that says the same, so
  none is written here — it may exist and simply not have been read.
- **A general numbering article, the way Senegal or Côte d'Ivoire have one.**
  No text found says, in so many words, that a Nigerien invoice carries a
  chronological and gapless number (unlike Senegal's art. 447-I-5 or Côte
  d'Ivoire's Livre de procédures fiscales, art. 145). `documents.numbering`
  rests instead on the certified-invoicing arrêté (n° 473/2020): since
  31 August 2021 every invoice of a régime réel taxpayer is numbered by the
  SECeF system itself (NIM and SECeF/DGI code). It says what a certified
  invoice carries, not that every invoice, at every date, must be numbered
  in a series — the engine needs one value regardless, and this is the
  closest sourced one.
- **Late-payment terms between businesses**: not researched.
- **The TAFI** (banking and finance tax, 18 % per the 2026 law's exposé des
  motifs) and **the droits d'accises**: sector- and product-specific taxes
  outside a general chart of accounts.
