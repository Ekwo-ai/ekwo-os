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
and the key of the text it is in. The register in `pack.json` holds 39 texts:
the consolidated texts on the BOE (by ELI where the BOE gives one), the forms
and instructions on the Sede electrónica of the Agencia Tributaria, and the
ICAC pages.

## The chart of accounts

**Spain publishes a chart, and this is a selection of it.** Real Decreto
1514/2007, fourth part (*cuadro de cuentas*), with the official codes and
names. 220 accounts of groups 1 to 7, 162 of them postable: the two-digit
subgroups are headings, a three-digit account is postable unless the PGC gives
it four-digit subaccounts that the pack carries (4300, 4000, 4700, 4750…).
Groups 8 and 9 — income and expense recognised directly in equity — are left
out: the pack carries no statement of changes in equity for them to reach. The
PGC for SMEs (Real Decreto 1515/2007) uses the same codes.

- **Receivables and payables are the four-digit accounts.** `4300 Clientes
  (euros)` and `4000 Proveedores (euros)` are the roles, the level Spanish
  practice posts on; the foreign-currency subaccounts sit beside them.
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
on every line: the ICAC publishes a taxonomy (PGC2007), not mapped here.

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
art. 3). The domestic sale taxes (rates, temporary food rates, domestic
reverse charge, art. 20 exemptions) say `applies_when: { "supply_in": "ES" }`,
and `ES-CN`, `ES-CE` and `ES-ML` are outside the parent's tax: `post_document()`
refuses `ES-S-21` on a supply delivered in Las Palmas, which posts as
`ES-S-EXP`, as in the golden scenario. Where the place of supply is Spain but
the goods or the customer are abroad (art. 69 services to consumers, art. 68
distance sales under the threshold), the document says so in
`supply_territory_code`. Purchase taxes carry no condition: a foreign supplier
may lawfully charge Spanish VAT.

**Credit notes go where the form puts them.** A *factura rectificativa* issued
is declared with a minus sign in boxes 14 and 15, not netted into the rate
row; one received goes to boxes 40 and 41.

**What is not here, and why:**

- **Recargo de equivalencia** (5,2 %, 1,4 %, 0,5 %, 1,75 %): charged on the
  same line as VAT, and the core carries one tax per line. Its boxes (156–158,
  168–170, 16–26) are declared and empty so that box 27 is the form's formula.
- **IGIC and IPSI**, levied instead of VAT in the Canary Islands, Ceuta and
  Melilla: no tax here carries them.
- **Régimen especial del criterio de caja**: optional, and the PGC names no
  transition account for the deferred VAT. Its mention is carried.
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
6 010 121,04 € of turnover and in the other cases that article lists; due on
the 20th of the following month (art. 71.4). The fourth quarter (30 January)
and SII filers (thirty days) are not expressed: the deadline rule has one shape.

**Form 349** is what `ec_sales_list()` answers (keys E, S, and A/I on the
purchase side); no brick of `packages/formats` writes its file. **Form 390**,
the annual summary, is not transcribed.

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
| **B2B e-invoice** | Ley 18/2022, art. 12; Real Decreto 238/2026 | EN 16931 in UBL, CII, EDIFACT or Facturae. Twelve months after the ministerial order on the public solution for companies above 8 M€, twenty-four for the rest. Without that order there is no date, and `mandatory_from` is null |
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
6. **The 0 % row** (150/152): the 2026 instructions keep it; which supplies,
   if any, are at 0 % in 2026 is to be checked.

## Corporate income tax: what `corporate_tax.json` leaves out

The section rests on the consolidated Ley 27/2014 on the BOE (last update
published on 2 September 2026) and two pages of the Agencia Tributaria. It
starts from line C, *Resultado antes de impuestos*, so the tax charge (630)
never enters; it is booked on 6300, with 4752 for the debt and 4709 for a
refund. Rates are those of periods opened from 1 January 2025: 25 %, 15 % for
new entities, 24 % for reduced-size entities and the 21 % / 22 % scale for
micro-enterprises, each dated up to the law's final rates. What the company
states (previous turnover, reduced size, asset-holding, new entity) is its own
word; nothing checks it against the books.

| Not carried | Why |
|---|---|
| Set-off of negative tax bases (art. 26) | The limit is the larger of 70 % of the base and 1 000 000 €; `loss_carryforward` can only say 1 000 000 + 70 % of the excess, so the list is empty and a company that carries a loss is refused by name. Art. 26.3 and 26.4 (new entities, extinction, acquired companies) are not carried either. |
| Minimum net tax (art. 30.1) | A floor of 15 % (10 %, 18 % or a reduced percentage in some cases) of the base for entities of 20 million € of turnover or more and for tax groups. The section has no minimum. |
| The Complementary Tax (Ley 7/2024) | A tax on top of the tax, outside the vocabulary of the section. |
| Reserva de capitalización (art. 25) and reserva de nivelación (art. 105) | Depend on the company's own reserves and a five-year commitment. |
| Entertainment of clients and suppliers (art. 15.e) | Deductible up to 1 % of net turnover: a ceiling a rule of the section cannot say. |
| The other lines of art. 15 (retribution of equity, tax-haven services, intra-group debt for acquisitions, severance above the limit, impairment of holdings, interest limit of art. 16) | Each depends on facts or ceilings not in a flat rule. |
| Exemption of dividends and of gains on holdings (art. 21) | Not carried. |
| Depreciation tables, impairment, free depreciation and tax credits (art. 12, 13, 102, 35 onwards) | Not carried. `credits` is empty. |
| The proration of the first slice of the micro-enterprise scale | The law shares 50 000 € by days over 365; the section shares by months, so a short period is within a fraction of a percent. A full year is exact. |
| Cooperatives, non-profit entities (10 %), investment funds (1 %), credit institutions and hydrocarbon companies (30 %), and groups of tax consolidation | Other rates of art. 29 and special regimes. |
| Rates of periods opened before 2025 | Not carried. A year before 2025 is refused with `no_rate_in_force`. |

The instalments are the three of art. 40.1 and 40.2 at 18 % of the reference
tax (the gross tax of the last period whose deadline had passed, less
deductions, allowances and withholdings), in the first twenty days of April,
October and December, declared with no reader yet. Art. 40.3 (base of the
first 3, 9 or 11 months, compulsory above 6 million € of turnover) and art.
40.4 (the percentage the budget act may change) are not carried.

Four things for a Spanish tax adviser to read: the reading that the
micro-enterprise scale of 2027 and later and the 20 % rate of reduced-size
entities from 2029 are the text of art. 29.1 itself, because the transitional
provision stops there; the exclusion of asset-holding entities from the 24 %
rate (art. 101.1 and the manual of the Agencia Tributaria); the rate of a new
entity that is also a micro-enterprise; and the days against months
proration above.

## Fixed assets

`fixed_assets.json` carries how Spain depreciates a fixed asset and takes it
off the balance sheet. It rests on the consolidated Ley 27/2014 (art. 12, the
table of maximum linear coefficients, the constant-percentage method and the
intangibles) and the PGC (rules of recognition and measurement 2.ª, 5.ª and
6.ª).

- **Disposal is `net_result`**: PGC rule 2.ª, 3 books one gain or loss on 771 or
  671, and the abridged profit and loss account prints it as one line
  (670/671/672 and 770/771/772). The two accounts are the roles
  `asset_disposal_gain` and `asset_disposal_loss`.
- **The first-period prorata is practice, not text.** Neither the PGC nor art. 12
  says how to cut the first year; the section counts real days from entry into
  service, in straight line and in declining balance, and says so in its
  `legal_reference`.
- **Durations.** The PGC fixes four: goodwill ten years (presumed), capitalised
  development and software five years at most (presumed), other intangibles ten
  years when the life cannot be estimated. For tangible assets the law gives a
  maximum linear coefficient and maximum period per kind of element: a
  straight-line category proposes the shortest life within the coefficient
  (12 × 100 / coefficient months), and its `legal_reference` prints both. A
  constant-percentage category takes the maximum period and the factor of art.
  12.1.b (1.5, 2 or 2.5 by that period); buildings and furniture have none, as
  the article forbids it.
- **A category proposes, never imposes**: the useful life is the company's
  estimate (rule 2.ª, 2.1).

### Fixed assets: what `fixed_assets.json` leaves out

| Not carried | Why |
|---|---|
| Tax depreciation distinct from the book charge | One schedule per asset; a difference from the tax table (goodwill at ten years against the 1/20 limit of art. 12.2, a faster book life) is a tax adjustment outside the module. |
| The 11 % floor of the constant percentage (art. 12.1.b) | No field says a minimum rate. It does not bite on any category here (the lowest is 13.9 %, machinery). |
| Sum-of-digits method (art. 12.1.c) | The module has no such method. |
| Free depreciation (art. 12.3: R&D assets, assets of up to 300 € within 25 000 € a year, labour companies) and accelerated depreciation of other regimes | Outside the vocabulary of a category. |
| Depreciation plans agreed with the tax administration (art. 12.1.d) and justified depreciation (12.1.e) | Case by case, no table. |
| Separate depreciation of the components of an asset (rule 2.ª, 2.1) | The module has one asset, one duration. |
| Residual value, impairment and its reversal | Not a pack rule. |
| Threshold below which an asset is expensed | The module has no such field. |
| Revaluations and legal updates | Not carried. |
| Other element kinds of the art. 12 table (civil works, power plants, rolling stock, ships and aircraft, glassware, linen, moulds, audiovisual productions) | Unusual for a first company; a category can be added. |
| Investment property (accounts 220/221, 282) | Not carried (rule 4.ª). |
| Assets held for sale (rule 7.ª) | The module cannot stop depreciation on a reclassification. |
| Units of production | Refused by the module. |
| Day-by-day convention of the first period | Practice, not text (see above); a company that prorates by months sets `prorata = 'months'` on the asset. |

Declining-balance categories also inherit the module's switch to straight
line when it is the larger annuity, which art. 12.1.b (a constant percentage
on the remaining value) does not provide for; the schedule needs it to end.
