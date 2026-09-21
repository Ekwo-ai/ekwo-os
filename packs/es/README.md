# Spain

Everything Spain adds to Ekwo, as data: a selection of the Plan General de
Contabilidad, the journals, the VAT rates with their history and where each one
posts, the boxes of form 303, the abridged balance sheet and profit and loss
account of the PGC, and the sentences the invoicing regulation puts on an
invoice. The format is [`docs/packs.md`](../../docs/packs.md); this file says
where the content came from and which decisions it rests on, so that a Spanish
accountant reading the pack can disagree with a specific sentence rather than
with the whole of it.

**Status: `community`.** Nobody has reviewed it against the law they apply. The
figures are replayed against a year of books by `tests/golden.test.ts`, which
proves the pack is coherent and proves nothing about whether it is right.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`
and the key of the text it is in. The register in `pack.json` holds 36 texts,
every one opened on 21 September 2026: the consolidated texts on the BOE (by
ELI where the BOE gives one), the forms and instructions on the Sede
electrónica of the Agencia Tributaria, and the ICAC pages.

The BOE answers `200` for a page that does not exist and says so only in the
title (`Error 404`), so a link checker that reads status codes alone will call
a wrong ELI good. Every URL of the register was checked by its title.

## The chart of accounts

**Spain publishes a chart, and this is a selection of it.** Real Decreto
1514/2007, fourth part (*cuadro de cuentas*), with the official codes and
names. 220 accounts of groups 1 to 7, 162 of them postable: the two-digit
subgroups are headings, a three-digit account is postable unless the PGC gives
it four-digit subaccounts that the pack carries (4300, 4000, 4700, 4750…).
Groups 8 and 9 — income and expense recognised directly in equity — are left
out, because the pack carries no statement of changes in equity for them to
reach. The PGC for SMEs (Real Decreto 1515/2007) uses the same codes.

Two deliberate choices:

- **Receivables and payables are the four-digit accounts.** `4300 Clientes
  (euros)` and `4000 Proveedores (euros)` are the roles, because that is the
  level Spanish practice posts on, and the foreign-currency subaccounts sit
  beside them.
- **The VAT accounts are the PGC's.** `472` input VAT, `477` output VAT, and
  the balance of the period is settled to `4750` when it is owed and to `4700`
  when it is a credit — the two accounts the PGC's own *definiciones y
  relaciones contables* use for that entry.

## The statements

**The State publishes the mapping.** The abridged balance sheet and profit and
loss account of the PGC's third part carry a column *N.º cuentas* that names
the accounts each line is made of. The pack transcribes that column line by
line: no range is inferred. Where one account appears on both sides (551,
5523, 5524, 5525), the rule is split by side, a debit balance being an asset
and a credit balance a liability. Accounts 678 and 778 do not appear in the
abridged profit and loss account and the pack carries neither. `xbrl` is null
on every line: the ICAC publishes a taxonomy (PGC2007) and nobody has mapped
it here.

## Taxes

A code is a rate at a date. The pack carries:

| Rate | In force | 303 boxes |
|---|---|---|
| 21 % | from 1.9.2012 | 07 / 09 |
| 18 % | 1.7.2010 – 31.8.2012 | 07 / 09 |
| 10 % | from 1.9.2012 | 04 / 06 |
| 8 % | 1.7.2010 – 31.8.2012 | 04 / 06 |
| 4 % | from 1.1.1995 | 01 / 03 |
| 0 % food (temporary) | 1.1.2023 – 30.9.2024 | 150 / 152 |
| 5 % oils and pasta (temporary) | 1.1.2023 – 30.9.2024 | 153 / 155 |
| 2 % food and olive oil (temporary) | 1.10.2024 – 31.12.2024 | 165 / 167 |
| 7,5 % seed oils and pasta (temporary) | 1.10.2024 – 31.12.2024 | 153 / 155 |

The temporary food rates follow Real Decreto-ley 20/2022, art. 72 (as amended
by Real Decreto-ley 8/2023), and Real Decreto-ley 4/2024, art. 1; the boxes
follow the Agencia Tributaria's 2024 instructions for form 303. The temporary
rates on electricity and gas (2021–2024) are not transcribed.

Beside them: intra-Community supplies of goods and services (box 59, and the
keys E and S of form 349), exports including shipments to the Canary Islands,
Ceuta and Melilla (box 60), the domestic reverse charge of art. 84.Uno.2.º
(box 122 on the sale, 12/13 and 28/29 on the purchase), intra-Community
acquisitions (10/11 and 36/37), services from suppliers outside the Union
(12/13 and 28/29), imports assessed by customs (32/33), capital goods (30/31)
and the 50 % presumption for passenger cars of art. 95.Tres.2.ª.

**Spanish VAT stops at the Canary Islands, Ceuta and Melilla** (Ley 37/1992,
art. 3). Since version 0.2.0 the domestic sale taxes — the rates, the
temporary food rates, the domestic reverse charge and the exemptions of art.
20 — say `applies_when: { "supply_in": "ES" }`, and the reference table marks
`ES-CN`, `ES-CE` and `ES-ML` as outside the parent's tax. So `post_document()`
refuses `ES-S-21` on a supply delivered in Las Palmas, and the same sale posts
as `ES-S-EXP`, which is what the golden scenario does with its Canarian
customer. Where the place of supply is Spain and the goods or the customer are
abroad — a service to a consumer under art. 69, a distance sale under the
threshold of art. 68 — the document says so in `supply_territory_code`, and
the refusal names that column. The purchase taxes carry no condition: a
foreign supplier may lawfully charge Spanish VAT.

**Credit notes go where the form puts them.** A *factura rectificativa* issued
is declared with a minus sign in boxes 14 and 15, not netted into the rate
row; one received goes to boxes 40 and 41.

**What is not here, and why:**

- **Recargo de equivalencia.** A wholesaler selling to a retailer in the
  scheme charges VAT and the surcharge (5,2 %, 1,4 %, 0,5 %, 1,75 %) on the
  same line. The core carries one tax per line and refuses `group`, so the
  surcharge cannot be posted. Its boxes (156–158, 168–170, 16–26) are declared
  and empty so that box 27 is the form's own formula.
- **IGIC and IPSI.** The Canary Islands, Ceuta and Melilla are outside the
  territory of Spanish VAT (Ley 37/1992, art. 3) and levy IGIC and IPSI
  instead, which no tax here carries.

- **Régimen especial del criterio de caja.** Optional, and the PGC names no
  transition account for the deferred VAT. Not modelled; its mention is.
- **The simplified regime (módulos)**, agriculture, travel agencies, second-hand
  goods, the prorrata, and the foral territories (Basque Country, Navarre).

## Form 303

The regime-general page, the additional information boxes 59, 60, 120, 122,
123 and 124, and the result: 27, 45, 46, 64, 66, 69 and 71 as the form prints
them, with the boxes that are no ledger figure (76, 77, 78) declared and fed
by nothing. The form is the one of Orden HAC/819/2024, in force from the third
quarter of 2024; Orden HAC/27/2026 replaced its annex from the second quarter
of 2026 without changing any box transcribed here.

Filed quarterly by default (Reglamento del IVA, art. 71.3), monthly above
6 010 121,04 € of turnover and for the other cases the same article lists. Due
on the 20th of the following month (art. 71.4). The same article gives the
fourth quarter until 30 January and the SII filers thirty days; the deadline
rule has one shape for all periods and cannot say either.

**Form 349** (recapitulative statement) is what `ec_sales_list()` answers: the
treatments give the keys E (goods), S (services) and A/I on the purchase side.
No brick of `packages/formats` writes its file. **Form 390**, the annual
summary, is not transcribed; it is a different form with its own boxes.

## Invoices

- **Numbering**: correlative within each series (Real Decreto 1619/2012,
  art. 6.1.a); rectifying invoices in a series of their own.
- **Tax point**: the earlier of delivery and payment (Ley 37/1992, art. 75.Uno
  and 75.Dos).
- **Payment terms**: 30 days by default, 60 at most (Ley 3/2004, art. 4).
- **Mentions**: *inversión del sujeto pasivo* (art. 6.1.m), the exemption
  article (art. 6.1.j), *régimen especial del criterio de caja* (art. 6.1.p).

### E-invoicing, SII and VERI*FACTU

Three different obligations, and none of them is an e-invoicing profile the
core can write today.

| Obligation | Text | Who, and from when |
|---|---|---|
| **B2B e-invoice** | Ley 18/2022, art. 12; Real Decreto 238/2026 | EN 16931 in UBL, CII, EDIFACT or Facturae. Twelve months after the ministerial order on the public solution for companies above 8 M€, twenty-four for the rest. The order was not found in the BOE on 21 September 2026, so there is no date, and `mandatory_from` is null |
| **SII** — invoice records sent to the Agencia Tributaria within four days | Real Decreto 596/2016; Reglamento del IVA, art. 62.6 | Everyone on a monthly return, since 1 July 2017; optional for others |
| **VERI*FACTU** — certified invoicing software | Real Decreto 1007/2023, as amended by Real Decreto-ley 15/2025 | Corporate income taxpayers before 1 January 2027, everyone else before 1 July 2027 |

`einvoicing.profile` is null because no brick writes a Spanish invoice yet;
the identifier scheme is `9920`, the Agencia Tributaria's NIF, for both the
party and the VAT number.

## What a reviewer should look at first

1. **Box 28 for the 50 % car** (`ES-P-21-VEH`): the full base is declared and
   half the tax. Whether the base should be limited to the deductible share is
   not settled by the instructions.
2. **Credit notes in 14/15 and 40/41** rather than netted in the rate rows —
   and whether an intra-Community acquisition's credit note belongs there too.
3. **Box 59 for intra-Community services** and 120 for other services not
   subject in Spain: the line between the two.
4. **The account types** of 407, 438 and 555, and 551 split by side.
5. **Numbering `gapless_per_year`**: one series per year is common practice
   and not a requirement of the regulation.
6. **The 0 % row** (150/152): the 2026 instructions keep it; which supplies
   are at 0 % in 2026, if any, was not established.
