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

The rate is the Code's 18 %. **The projet de loi de finances pour 2026** is a
bill, not law: nothing it proposes is in this pack. **The lois de finances pour
2023, 2024 and 2026 (définitives) are not transcribed**: only what the 2025 law
itself quotes from the 2024 one is in this pack, and a reviewer should check
them.

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
  rather than folded into one.
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
  box: this is an advance of income tax, not a line of the VAT return.
- **The declaration** carries what art. 373 Sexies-III says it carries: the
  month's taxable and exempt operations, the regularisations, the tax
  collected, the tax deductible on imports, on goods delivered and on services
  performed. Its boxes are named after that content, **not after the printed
  form**, whose model and box numbers are published in no text found. It is monthly (art. 366-II, 373 Sexies-I) and due on the
  **10th** of the following month, since the loi de finances pour 2025 (art. 13)
  moved it there from the 15th the 2022 Code had set; a nil return is
  compulsory (art. 373 Sexies-IV).
- **The invoice** carries a unique number in "une séquence chronologique et
  continue" (art. 383-VI-7°) and, in place of a rate, the reference to the
  article that zero-rates or exempts the operation (art. 383-VI-10°): the two
  mentions this pack declares.

**A service bought from a supplier abroad: `GN-P-NR-18`.** Guinea has a
reverse charge in the European sense. Services are taxed in Guinea when the
customer is established there (CGI, art. 361 Quater-I); when a taxable person
established outside Guinea supplies one to a taxable person registered for VAT
in Guinea, the customer is liable (*"auto liquidation"*, art. 373 Bis-II), and
it deducts the tax once it *"a été acquittée par le preneur"* (art.
375-I-1-d). The tax owed is credited to `4478` and declared in the new box
`TVAPC`, which the total of the tax due adds; the same amount is debited to
`4454` and deducted in `DEDBS` the same month, paid with the same return. The
golden year buys one such subscription. SYSCOHADA has no account for suppliers
abroad, so the supplier sits on `4011` with the others. A customer not
registered for VAT pays the tax only failing a fiscal representative (art. 373
Quinquies-VI).

## What it does not say

- **The seller's side of the 50 % VAT withholding.** Article 373 Ter makes a
  client who is the State, a local authority, a public or mixed-economy body,
  a telecom company, or a company that imports, stores, distributes or mines —
  buying from a VAT-registered seller — withhold 50 % of the tax the invoice
  shows and pay it to the Treasury directly; the seller still declares the
  full tax collected and takes the retained half back as a deduction the
  Code calls "Déduction de la retenue 50% TVA". The debt stays the seller's
  while a third party remits it, and no posting expresses a buyer's own remittance reaching the
  seller's books, and this pack carries no tax code for art. 373 Ter. A client
  invoiced under it still owes the full tax on paper; only the cash received
  and the deduction on the return differ from an ordinary sale, and neither is
  a fact the invoice's own lines can carry (see
  [`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet)).
- **The general fait générateur of a domestic sale or service** — whether the
  tax is due on delivery, on the invoice, or on collection — is not found as an
  article of its own in the Code; `documents.tax_point` is therefore absent
  from this pack rather than guessed.
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
  the two remaining mentions art. 383-VI names, are options whose substance
  this pack does not transcribe; it declares neither the mention nor the regime behind
  it.
- **The franchise below 1 000 000 000 GNF of turnover** (art. 359-360) is
  described in the Code as a threshold, but no article found says a franchised
  taxpayer may not show VAT on an invoice: this pack carries no `small_business` mention.
- **The Déclaration Mensuelle Unique**, whose Excel model is published on
  `dgi.gov.gn`, is not modelled; whether it carries the VAT return itself,
  beside it, or replaces its printed form is for a reviewer to confirm.
- **The e-TVA/SAFIG API** (art. 383-V, loi de finances pour 2025, art. 27) has
  no published specification, format or deployment calendar: `einvoicing`
  carries the obligation's legal basis and nothing else.
