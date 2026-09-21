# Guinea-Bissau

Everything Guinea-Bissau adds to Ekwo, as data: the value added tax of the
Código do IVA, where each rate posts, the declaration it is filed on and the
sentences the law puts on an invoice. The chart of accounts, the journals and
the two statements are the SYSCOHADA révisé shared by seventeen countries, and
they are not written here: they are copied from
[`packs/ohada/`](../ohada/README.md) by `scripts/ohada-packs.mjs`, which the CI
runs to refuse a copy that has drifted. Edit them there.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The golden year proves the pack is coherent and nothing about whether it is
right. Currency XOF, the CFA franc of the BCEAO, at no decimal.

**A recent tax.** Guinea-Bissau's IVA is not the country's first turnover tax
— the Imposto Geral sobre Vendas e Serviços (IGV, Lei n.º 16/97) taxed a
single rate of 19% before it — but the Código do IVA itself (Lei n.º 4/2022,
published 25 February 2022) only took effect on **1 January 2025**, fixed by
Despacho n.º 130/GMF/2024. Every rate and every rule below post-dates that
day.

## Sources

| What | Text | Where |
|---|---|---|
| Rates, exemptions, deduction, regimes, the declaration, invoicing obligations | Lei n.º 4/2022 — Código do IVA, full text | `kontaktu.mef.gw`, the DGCI's own portal, read directly (its DNS did not resolve through this session's `WebFetch`; a forced resolution over `curl` served the page) |
| The 1 January 2025 entry into force | Despacho n.º 130/GMF/2024, 31 October 2024 | `mef.gw` |
| Invoice content, numbering, series, the QR code, the simplified invoice | Despacho MF n.º 1/2023 — Regulamento das Faturas, taken under art. 29.º, n.º 3 of the Código do IVA | `kontaktu.mef.gw` |
| The frame of the rates | Directive n° 02/2009/CM/UEMOA, art. 29 nouveau | AIFO-UEMOA |
| The ACI, an income-tax advance withheld on payment, not modelled here | Lei n.º 6-A/95, updated to January 2021 | `kontaktu.mef.gw` |

## What the pack says

- **19%** on everything taxable outside the Anexo I list (art. 18.º, n.º 1,
  b), **10%** on the ten headings of the Anexo I — rice, flour and bread;
  agricultural inputs; solar equipment; computer equipment; funeral services;
  passenger transport; newspapers and cultural, educational and recreational
  activities; fire-fighting equipment; the services of a jurisconsulto or a
  solicitador; restaurant, hotel and tourism services (art. 18.º, n.º 1, a,
  and Anexo I) — and **0%** on exports, which are an exemption of art. 15.º
  with a right to deduct (art. 20.º, n.º 2, a), a rate and not the reason.
  Internal exemptions without that right — medicines of the Anexo II list,
  therapeutic health care, recognised schooling, domestic gas, unremunerated
  financial and insurance operations, residential real estate outside hotel
  accommodation — have their own box (art. 13.º and, for imports, the
  symmetrical art. 14.º); art. 13.º, n.º 2 forbids any exemption the Code does
  not itself provide.
- **Goods and services post apart** — 4431 and 4432 on the sale side, 4451,
  4452 and 4454 on the purchase side — because the chart has the accounts, as
  Senegal and Côte d'Ivoire already do. The tax point is the invoice: art.
  11.º sets the principle (delivery, performance or import), and art. 12.º
  moves it to the invoice's own date once art. 29.º requires one — which is
  the ordinary case — or to an earlier payment. No provision read taxes a
  service on its collection, so no tax here is `cash_basis`.
- **Deduction** (art. 19.º to 23.º): the tax due or paid to another régime
  normal assujetti, the tax self-assessed under art. 7.º and the tax paid at
  import are all deductible on the operations art. 20.º names; art. 21.º
  excludes travel, hospitality and entertainment expenses of the taxpayer and
  its staff, passenger vehicles and their fuel, pleasure boats, helicopters,
  aircraft and motorcycles and their fuel, luxury expenses and goods outside
  lawful commerce — `GW-P-19-ND` posts that share as a cost, never a
  deduction. A partial pro rata (art. 23.º) exists for a taxpayer who mixes
  taxed and exempt-without-right operations; no golden document needs it, so
  it is not built.
- **A foreign supplier's services** (art. 7.º, n.º 1): a supplier with no
  seat, establishment or fiscal representative (art. 33.º) in Guinea-Bissau
  leaves the buyer as the assujetti. Unlike Senegal's TVA pour compte, the
  Código do IVA does not exclude this tax from deduction — art. 19.º, n.º 1,
  b) names it among what is deductible in the general terms — so
  `GW-P-NR-19` is fully deductible, reversed through 4478 like Côte d'Ivoire's
  own TVA pour compte de tiers.
- **The retention of art. 7.º**, Guinea-Bissau's own mechanism and the one
  this pack gives most weight to: a régime normal buyer must withhold the
  *entire* tax invoiced by (a) a régime simplificado supplier or (b) a régime
  normal supplier the DGCI's director general has listed as "de risco" (n.º
  3). The buyer pays the supplier net of that tax, remits it directly to the
  DGCI on a field of its own monthly declaration (n.º 4, `IVARET` here), and
  the supplier's invoice carries "IVA – Retido" (n.º 5). Case (b) turns on an
  administrative list this pack has no way to read — it is not built, the
  same limitation Senegal and Côte d'Ivoire record for their own
  discretionary désignations. Case (a) is `GW-P-5-RETIDO`: the régime
  simplificado's flat 5% (art. 38.º) gives the buyer no right to deduct at
  all (art. 39.º) — so the whole tax lands on the cost of what was bought,
  exactly as `GW-P-19-ND` does — and on top of that non-deductibility the
  buyer, rather than paying it to the supplier, owes it straight to the
  state. Two facts the ledger cannot see stack on one code: `tax_on_base` adds
  the tax to the purchase's own account, and a `tax` leg at 4478 moves the
  same amount out of what is owed to the supplier.
- **The declaration** (art. 31.º) is due, for the régime normal, by the 15th
  of the month following the operations, even without any (n.º 1 and n.º 3);
  its model is approved by the DGCI's director general and was not found
  published, so every box here is named after what art. 31.º, n.º 2 says the
  declaration carries — the tax due or the credit, and what was used to
  compute it — never after a printed form. A credit carries forward
  indefinitely (art. 24.º, n.º 1) and, past twelve months and above 1,000,000
  FCFA, may be turned into a tax credit note for compensation (art. 24.º,
  n.º 2).
- **The invoice** is pre-authorised by the DGCI before it exists: a sequential
  number from 1 to 9,999,999,999 the DGCI itself attributes, prefixed by the
  mode of emission (`K-` Kontaktu, `I-` taxpayer software, `T-` approved
  printer, `C-` contingency) and carrying one of six series (A domestic
  sales, B exports, C imports, D credit notes, E contingency, F transport
  guides) — Despacho MF n.º 1/2023, art. 7.º and 11.º. A QR code and the
  DGCI's authorisation URL are compulsory on every invoice; `numbering` is
  declared `gapless` because the rule forbids a gap or a repeat, never
  `gapless_per_year`, since nothing resets the count each year.

## What it does not say

- **The régime simplificado's own declaration.** Its 5% (art. 38.º) is filed
  on a *separate* quarterly return (art. 42.º) — due the last business day of
  April, July, October and January, with a purchases-and-sales annex — that
  this pack does not build: one company keeps one declaration form here, and
  the golden company is a régime normal one. Only the retention its régime
  normal *buyers* perform is modelled, via `GW-P-5-RETIDO` and the `IVARET`
  box of the régime normal's own monthly form.
- **The "risco" désignation** of art. 7.º, n.º 3, b): a discretionary list
  kept by the DGCI's director general, which no public text this pack read
  publishes and no `conditions` vocabulary of the schema names (it turns on
  the *seller's* own standing, not the buyer's).
- **The printed form itself.** Nothing public gives its boxes or its model
  name; Kontaktu and the taxpayer's own space on it are presumably where they
  are read.
- **The ACI** (Adiantamento por Conta da Contribuição Industrial, Lei n.º
  6-A/95): 3% on payments to a supplier's normal invoice, 7% on payments by
  the Treasury, withheld by the buyer as "substituto fiscal" and credited
  against Contribuição Industrial — an income tax withheld on the payment,
  which the core cannot express, and whose survival past the IVA's own entry
  into force was not confirmed by any text read.
- **The additional 30% import surcharge** (art. 6.º of Lei n.º 4/2022 itself,
  not of the Código it approves) on the customs value of imports by a
  taxpayer the DGCI has listed as a non-declarant — a second discretionary
  list, and a tax computed on the customs value rather than on a supply this
  pack's documents carry.
- **Electronic invoicing in the EN 16931 sense.** The Despacho MF n.º 1/2023
  regime is a pre-authorisation and QR-verification system, not a structured
  exchange format, so `einvoicing.profile` stays null even though every
  invoice is, in substance, already cleared by the administration before it
  is issued.
- **Late-payment terms between businesses**: no Guinea-Bissau or UEMOA text
  found sets one.
- **A Portuguese wording of the pack's own sections** (`pack_name`, taxes, the
  declaration's boxes, the legal mentions — all in the wording of the
  Código do IVA and of the Despacho MF n.º 1/2023, both official texts in
  Portuguese, Guinea-Bissau's official language). `packs/ohada/README.md`
  invites exactly this, undeclared, with the chart falling back to French.
  It is not built: the seed compiler reads any `i18n/<lang>.json` on disk and
  writes its keys into `name_i18n` and every `text_i18n`, and the test suite
  (`tests/languages.test.ts`) then requires those keys to match
  `languages` exactly — so an *undeclared* file breaks the build the moment
  it exists, regardless of how partial it is. Declaring `pt` the ordinary way
  would in turn require translating every one of the 1,358 SYSCOHADA
  accounts, which no official Portuguese edition of the chart exists to
  translate from (`packs/ohada/README.md`, *Languages*) — exactly the
  invented-translation this pack refuses to produce. The compiler does not
  yet have a middle case for a partial, undeclared i18n file; this is a gap
  of the core, not of this pack's data.
