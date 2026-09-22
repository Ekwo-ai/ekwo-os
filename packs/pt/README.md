# Portugal

Everything Portugal adds to Ekwo, as data: a selection of the SNC's Código de
Contas, the journals, the VAT rates of the mainland and of the two autonomous
regions with where each one posts, the boxes of the Declaração Periódica do
IVA, the Balanço and the Demonstração dos Resultados, and the sentences the
Código do IVA puts on an invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Portuguese accountant reading
the pack can disagree with a specific sentence rather than with the whole of
it.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

## Sources, and a real limit on how far they were read

Every rate, box, mention and statement line carries its own `legal_reference`
and the key of the text it is in. The register in `pack.json` holds the
consolidated articles of the Código do IVA and of the RITI as the Autoridade
Tributária serves them on `info.portaldasfinancas.gov.pt` — every one of
those pages was opened and its text read on 22 September 2026 — and the
decrees, portarias and leis that set the rest, on `diariodarepublica.pt` and
on the sites of the Comissão de Normalização Contabilística.

**A citation is not always a page this pack's own tools could read.** The
Diário da República Eletrónico renders its detailed pages in JavaScript, which
the tools available while writing this pack could not execute, and several of
the Comissão de Normalização Contabilística's own PDFs — the Código de Contas
of Portaria n.º 1011/2009 among them — are scans with no text layer. Where
that happened, the citation is still the real text: its existence and its
title were confirmed independently, through the Diário da República's own
search and through more than one professional source that quotes it, and the
account codes, the box numbers and the wording below rest on that
corroboration rather than on a machine reading the primary PDF end to end. A
reviewer with a browser open on the same page will find every sentence this
pack claims; what did not happen is a script confirming it first. This is the
same limit the Spanish pack's `README.md` records for the BOE, and it is
recorded here rather than left silent for the same reason.

## The chart of accounts

**Portugal publishes a chart, and this is a selection of it.** Decreto-Lei
n.º 158/2009 approves the Sistema de Normalização Contabilística; Portaria
n.º 1011/2009 approves its Código de Contas, eight classes deep. This pack
carries the accounts a trading company's day-to-day books actually use — the
two- and three-digit headings of every class, the customer, supplier and VAT
control accounts at the level Portuguese practice posts on, the usual
tangible and intangible fixed-asset accounts with their accumulated
depreciation and impairment, and the ordinary income and expense accounts of
a Demonstração dos Resultados por naturezas. It is not a transcription of
every four- and five-digit subaccount the portaria carries, the way the
Spanish pack's 220 accounts are not every account of the PGC either: a
reviewer who needs a subaccount this pack does not carry adds it under the
heading that already exists.

Two deliberate choices:

- **The VAT control accounts are account 243's subaccounts.** `2432 IVA -
  Dedutível` and `2433 IVA - Liquidado` are where the tax postings land;
  `2436 IVA - A pagar` and `2437 IVA - A recuperar` are where the period's
  net settles, mirroring the pair every other European pack in this
  repository keeps apart for the same reason: a company owing the state and
  a company waiting on a refund are not the same fact.
- **Class 8 keeps its own accounts.** The SNC does not close the year's
  result into an equity account the way the French or the Spanish charts do;
  it keeps `81 Resultado líquido do período` as its own account, which is
  what `defaults.roles.current_year_result_profit` and
  `current_year_result_loss` both point to, and `closing_style:
  "result_accounts"` reads it as sitting on the balance sheet until the
  shareholders decide what to do with it — the same shape as the French
  120/129, on one account instead of two because the SNC's own balance can
  run either way on it.

## The statements

The Balanço and the Demonstração dos Resultados por naturezas follow Portaria
n.º 220/2015. Their captions are the ones every SNC balance sheet and income
statement prints — ATIVO NÃO CORRENTE, ATIVO CORRENTE, CAPITAL PRÓPRIO,
PASSIVO NÃO CORRENTE, PASSIVO CORRENTE on one side, the by-nature income
statement down to Resultado líquido do período on the other — but the exact
account-by-account mapping the portaria's own annexes print could not be read
from its PDF (see above), so the `code_range` rules below each line are this
pack's own placement of the accounts it carries, not a transcription of a
column the portaria prints. `xbrl` is null on every line: the SNC files no
public taxonomy this pack could map it against.

## Taxes

A code is a rate at a place. The pack carries three schedules of the same
three rates — reduced, intermediate, standard — one per territory the Código
do IVA lets set its own:

| Territory | Reduced | Intermediate | Standard | In force since |
|---|---|---|---|---|
| Mainland | 6 % | 13 % | 23 % | 1.1.2011 |
| Azores | 4 % | 9 % | 16 % | 1.7.2021 |
| Madeira | 5 % (→ 4 % from 1.10.2024) | 12 % | 22 % | 1.4.2012 |

Article 18.º, n.º 3 of the Código do IVA lets the legislative assembly of
each autonomous region set rates of its own under the Lei das Finanças das
Regiões Autónomas; the Azorean rates are Decreto Legislativo Regional n.º
15-A/2021/A, the Madeiran ones Lei n.º 14-A/2012 and, for the 2024 change to
the reduced rate, Decreto Legislativo Regional n.º 6/2024/M, art. 21.º.

**The national declaration has one row per rate, not one per territory.** The
Declaração Periódica do IVA does not ask which region a filer belongs to: a
company established in the Azores reports its 16 % sales in the same "taxa
normal" row (campo 3/4) a mainland company reports its 23 % sales in. So the
three schedules share the same boxes, and what tells them apart is
`applies_when.supply_in`, on the territory rows `PT-20` (Azores) and `PT-30`
(Madeira) added to the framework's own `territories` table for this pack —
not `outside_parent_tax`, because Union VAT reaches both regions exactly as
it reaches the mainland; they are not the Canary Islands. **What the format
cannot say is the opposite: a mainland-rate tax carries no restriction, so
nothing in the engine refuses `PT-S-23` on a document a company established
in the Azores posts.** `docs/international.md` records this under Portugal:
the vocabulary of `applies_when` names a place a tax applies *in* and has no
word for "everywhere but this place", which is exactly the shape three
overlapping rate schedules in one country need.

**Beside the rates:** intra-Community supplies and acquisitions of goods and
services, exports, the domestic reverse charge of art. 2.º, n.º 1 (waste,
scrap, construction services and the goods of the Código's Anexo I), a
service received from a supplier outside the Union, an import assessed by
customs, and the exclusions from the right to deduct of art. 21.º
(passenger vehicles, fuel, travel and entertainment expenses), modelled as a
wholly non-deductible tax rather than declared on the return at all, because
nothing in the Declaração Periódica do IVA reports what art. 21.º excludes.

**What is not here, and why:**

- **The regime of small retailers, the flat-rate scheme for farmers, and
  every regime that turns on a threshold of turnover or a sector this pack's
  ledger cannot see** — the same limit `docs/packs.md`'s `conditions` field
  documents for every pack in this repository.
- **A rectified base for a credit note.** The Declaração Periódica do IVA
  reports a monthly or quarterly *regularização* — campo 40 in favour of the
  taxable person, campo 41 in favour of the State — but nothing found while
  building this pack confirms whether that box also carries the base the
  credit note corrects, the way Spain's 14/15 do. This pack declares only the
  tax amount in 40/41 and no base; a credit note's taxable amount is
  therefore not separately visible on the return this pack produces.
- **The final boxes of the form.** Portuguese practice describes fields in
  the 90s that sum the liquidated and the deductible sides and state the
  result, but this pack could not confirm their exact numbers against the
  official form (see "Sources" above); `91`, `92` and `93` are this pack's
  own numbering of that arithmetic, not a transcription, and say so in their
  own `legal_reference`.

## Invoices

- **Numbering**: sequential within a series communicated in advance to the
  Autoridade Tributária (Decreto-Lei n.º 28/2019); a series restarting every
  calendar year is common practice and not a requirement of the decree.
- **Tax point**: the supply, or its invoice when one is issued within the
  legal deadline — Código do IVA, art. 7.º for the principle, art. 8.º for
  the derogation that in practice governs almost every operation, because
  art. 29.º requires an invoice for almost every one.
- **Payment terms**: 30 days by default (Decreto-Lei n.º 62/2013, art. 4.º).

### Certified software, ATCUD, the QR code and SAF-T (PT) — four obligations, no e-invoicing profile

None of the four is a structured invoice exchanged between two businesses,
which is what `einvoicing.profile` and `einvoicing.obligation` describe, and
this is exactly why the section declares `obligation: "none"` rather than
naming a profile that does not exist yet:

| Obligation | Text | What it is |
|---|---|---|
| **Certified invoicing software** | Decreto-Lei n.º 28/2019 | A company above the legal threshold must issue documents through software certified by the Autoridade Tributária. A certification regime, not a document format |
| **ATCUD** | Portaria n.º 195/2020 | A unique code per document, drawn from a series communicated in advance, printed on the document itself |
| **QR code** | Portaria n.º 195/2020 | Printed on every invoice and every other fiscally relevant document since 1 January 2022 |
| **SAF-T (PT)** | Portaria n.º 302/2016 and the decrees it amends | A standardised file of the period's invoices, submitted to the Autoridade Tributária, not sent to the customer |

All four are a company proving its books to the State, not a company
exchanging a document with another company — the same distinction the
Spanish pack's README draws for the SII and VERI\*FACTU, and the reason
neither pack's `einvoicing` section carries them. `docs/international.md`
keeps the gap this leaves: nothing in `packages/formats` writes a SAF-T (PT)
file or checks an ATCUD sequence, and a company using this pack still needs
software of its own for both.

**Business-to-government e-invoicing is a different, narrower obligation.**
Decreto-Lei n.º 111-B/2017 transposes Directive 2014/55/EU for public
contracts: obligatory for contracting authorities since April 2019, for
large companies since January 2021, and — after the extension Lei n.º
73-A/2025 (Orçamento do Estado para 2026) granted — for micro, small and
medium-sized undertakings and for the remaining contracting entities from 1
January 2027. Nothing in this repository writes that format either.

## What a reviewer should look at first

1. **The final boxes of the form** (91, 92, 93 above) — this pack's own
   numbering of the arithmetic the law requires, not a confirmed
   transcription of the printed form.
2. **Credit notes in campo 40/41 with no base** — whether the form in fact
   carries no base column there, or this pack missed one.
3. **The account-to-line mapping of the Balanço and the Demonstração dos
   Resultados** — built from the captions every SNC statement prints, not
   from a machine reading of Portaria n.º 220/2015's own annexes.
4. **The domestic reverse charge, on both the sale and the purchase side**
   (`PT-S-ISP`, `PT-P-ISP-23`) — the operations it covers (art. 2.º, n.º 1,
   alíneas i), j) and l)) and the boxes each side declares.
5. **`PT-P-EXC-23`**, the art. 21.º exclusion from the right to deduct —
   whether every expense this pack lists (vehicles, fuel, travel,
   entertainment) belongs on one tax code or several, given the exceptions
   art. 21.º, n.º 2 itself carries.
6. **The Azores and Madeira schedules** — read against the mainland-rate
   restriction the "Taxes" section above states as a gap: nothing here stops
   a mainland-rate tax from being posted on a document established in either
   region.
