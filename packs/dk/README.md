# Denmark

Everything Denmark adds to Ekwo, as data: a chart of accounts, the journals,
the VAT rates and where each one posts, the boxes of the momsangivelse, the
balance sheet and the income statement of the annual report, and the
sentences the law puts on an invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file gives the sources and the
decisions, so that a Danish accountant can disagree with a specific sentence.

**Status: `community`.** Nobody has reviewed it against the law they apply.
The figures are replayed against a year of books by `tests/golden.test.ts`,
which proves the pack is coherent and proves nothing about whether it is
right.

## Sources

Every rate, box, mention and statement line carries its own `legal_reference`.
These are the texts the pack as a whole was built from; the full register,
with `consulted_on` dates, is `pack.json`'s `certification.sources`.

| What | Text | Where |
|---|---|---|
| The VAT rate, the exemptions, the export and intra-Union zero rate, the reverse charges, the tax point | Momsloven (bekendtgørelse af merværdiafgiftsloven), LBK nr 209 af 27/02/2024, as amended | `retsinformation.dk/eli/lta/2024/209` |
| Invoice content, numbering, the boxes of the momsangivelse and the special ledger accounts they come from | Momsbekendtgørelsen, BEK nr 1435 af 29/11/2023, as amended | `retsinformation.dk/eli/lta/2023/1435` |
| What each box of the momsangivelse means, in plain words | Skattestyrelsen's help texts for the VAT return | `dst.dk` (copy of the office's own wording), and `skat.dk/tastselverhverv` where it is filed |
| The chart of accounts, and the obligation to describe bookkeeping procedures instead of one | Bogføringsloven, LOV nr 700 af 24/05/2022 | `retsinformation.dk/eli/lta/2022/700` |
| The balance sheet and income statement schemes | Årsregnskabsloven, LBK nr 402 af 23/03/2026, bilag 2 | `retsinformation.dk/eli/lta/2026/402` |
| Payment terms and default interest | Renteloven, LBK nr 459 af 13/05/2014, as amended | `retsinformation.dk/eli/lta/2014/459` |
| E-invoicing to the public sector, NemHandel | Bekendtgørelse om elektronisk afregning med offentlige myndigheder, BEK nr 206 af 11/03/2011 | `retsinformation.dk/eli/lta/2011/206`; `erhvervsstyrelsen.dk` |
| Digital bookkeeping, the 2026 extension to sole traders | Erhvervsstyrelsen's own announcement | `erhvervsstyrelsen.dk` |
| The ISO 6523 identifiers, the VAT category and exemption reason codes | Peppol BIS Billing 3.0, UNCL5305, VATEX | `docs.peppol.eu` |

## The chart of accounts, and why this one

**Denmark prescribes no chart of accounts.** Bogføringslovens § 6 obliges a
bookkeeping-liable business that must file an annual report, or whose net
revenue has passed 300 000 kr. in each of two consecutive years, to write a
*description* of its procedures for registering transactions and keeping its
records — not to adopt a particular chart or numbering. There is no
statutory Danish chart to copy.

This chart is original. It is built around nine numeric classes, each tied to
one group of lines of årsregnskabslovens bilag 2:

- **1** fixed assets, **2** current assets, **3** equity, **4** provisions and
  non-current liabilities, **5** current liabilities, **6** revenue, **7**
  operating costs, **8** financial items and tax.
- **Flat.** Every account is a leaf; the statements group them by the
  `code_range` rules of `statements.json` (*Omsætningsaktiver* is class 2).
- **The special ledger accounts momsbekendtgørelsens § 76 requires**: input
  VAT, output VAT, the tax on purchases from abroad (§ 76, stk. 1, nr. 3-4),
  and the *value* of EU acquisitions and EU and export supplies (nr. 5-9).
  The first three are `2160`, `5160` and the pair `2170`/`5170`; the value
  accounts are why `6010`/`6020`/`6030` and `7020` stand apart from `6000` and
  `7010`, each serving as both the special and the ordinary revenue or cost
  account.

## Taxes

**Denmark has one VAT rate.** Momslovens § 33 sets it at 25 % of the tax base
and has done since 1992; there is no reduced rate, so `DK-S-25` and `DK-P-25`
are the only positive-rate codes.

| Code | What | Rate | Legal basis |
|---|---|---|---|
| `DK-S-25` / `DK-P-25` | Domestic sale and purchase | 25 % | § 33, § 37 |
| `DK-S-EU-GOODS-0` | Intra-Union supply of goods | 0 % | § 34, stk. 1, nr. 1 |
| `DK-S-EU-SERVICES-0` | Intra-Union B2B service, reverse-charged at destination | 0 % | § 16, stk. 1 |
| `DK-S-EXPORT-0` | Export outside the Union | 0 % | § 34, stk. 1, nr. 5 |
| `DK-S-EXEMPT-PROPERTY` | Letting of immovable property | exempt | § 13, stk. 1, nr. 8 |
| `DK-P-EU-GOODS` | Intra-Union acquisition of goods, self-assessed | 25 % | § 11, § 46, stk. 4 |
| `DK-P-EU-SERVICES` | Service received from another Member State, self-assessed | 25 % | § 16, stk. 1; § 46, stk. 1, nr. 3 |
| `DK-P-NONEU-SERVICES` | Service received from outside the Union, self-assessed | 25 % | § 16, stk. 1; § 46, stk. 1, nr. 3 |

**§ 16, stk. 1 does not distinguish the supplier's own country**: a B2B
service is taxed where the buyer is established, so `DK-P-EU-SERVICES` and
`DK-P-NONEU-SERVICES` are the same mechanism under two treatments:
`intracom_acquisition_services`, because the supplier's invoice carries the
Union's `K`/`VATEX-EU-IC` pairing, and `foreign_services_received`, because no
invoice EN 16931 governs exists to record a category for.

**One exemption is carried, chosen because it needs no fact a ledger lacks.**
Several of the twenty-two exempt activities of § 13 depend on a resale
certificate or a threshold crossed; the letting of immovable property (§ 13,
stk. 1, nr. 8) ordinarily does not. The landlord's option of § 51 (voluntary
registration on a commercial letting, which makes it taxable) is not
recorded: a letting always reads as exempt, and a company that has elected in
needs a positive-rate code of its own.

**The self-assessed taxes carry two `tax` postings, not one.** `DK-P-EU-GOODS`
and its two service siblings post the same amount twice: once to `2170`
(deductible, box `koebs`, the same box the domestic purchase tax posts to,
because momsbekendtgørelsens § 76, stk. 3 lets the two be pooled once
assessed) and once with `factor: -100` to `5170` (payable, box `eumoms` or
`ydmoms`). A fully deductible business nets to zero and still declares both
sides, as the return asks.

## The momsangivelse

`tax_report.json` carries the periodic return under the code `DK-MOMS`, with
the ten boxes momsbekendtgørelsens §§ 76 and 79 describe: `Salgsmoms`,
`Moms af varekøb i udlandet`, `Moms af ydelseskøb i udlandet med omvendt
betalingspligt`, `Købsmoms`, the total `Momstilsvar`, and rubrik A (varer,
ydelser), B (varer, ydelser) and C.

**The period is not one cadence.** Momslovens § 57 files a business monthly
above 50 million kr. of annual taxable turnover, quarterly between 5 and 50
million, and half-yearly below 5 million, so `tax_report.json` declares no
`period_default` and `ekwo init` asks. The golden scenario books a quarterly
filer, the middle and most common case.

**Rubrik B splits goods sold to other EU countries in two, and this pack
carries only the ordinary one.** Momsbekendtgørelsens § 79, stk. 1, nr. 3 and
4 distinguish an EU sale that has to be reported to the separate EU sales
list system (*EU-salg uden moms*) from one that does not — remote sales a
business is itself registered for abroad, new means of transport to a
private buyer, installation and assembly. `bvarer` carries the first
(`DK-S-EU-GOODS-0`); the second box is a gap, listed below.

**The deadline declared is the monthly one, and it is early for the other two
cadences.** `deadline` is one rule for the whole form: the monthly return is
due the 25th of the following month (§ 57, stk. 1, with an extension to
the 17th of the second month after for June), which fits
`day_of_month_after_period`; the quarterly and half-yearly returns are due
the first day of the *third* month after the period ends (§ 57, stk. 3 and
4), which no rule of this format can say. The pack declares the monthly day, never later than the law
and several weeks early for a quarterly or half-yearly filer (see
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet)).

## What a country outside no reduced rate still needs read carefully

`vat_category` and `exemption_code` follow the table of
[`docs/packs.md`](../../docs/packs.md#what-a-tax-says-on-the-invoice-treatment-category-and-reason)
throughout, because Denmark is inside the common system of VAT and its
`eu_vat_scope` is `full`: `G` and `VATEX-EU-G` for the export, `K` and
`VATEX-EU-IC` for every intra-Union code including the two purchase-side
ones, where the category recorded is the *supplier's* — and `E` with
`VATEX-EU-135-1` for the property exemption, the general code for an article
135(1) exemption where the VATEX list carries no code specific to letting.

## Electronic invoicing

`einvoicing.obligation` is `none`: no Danish statute obliges a company to
issue or receive an electronic invoice with another company. Only the public
sector is reached: a supplier to a Danish public authority sends the invoice
through Nemhandel, and the authority must be able to receive it — BEK nr. 206
af 11/03/2011, issued under the law on public payments, written in
`legal_reference` without changing the word. The format is OIOUBL by
the letter of that decree, and increasingly Peppol BIS Billing 3.0 with the
Danish CIUS in practice, which is what `profile` names. A proposal to
modernise the decree without moving this boundary was in public consultation
until 3 November 2025 and is not enacted at `released_at`.

**`party_scheme` and `vat_scheme` are the same code, 0184.** The Danish VAT
identifier is `DK` followed by the eight digits of the CVR number, so both
Peppol identifiers resolve to the same register entry.

## Digital bookkeeping, outside the pack

Bogføringslovens § 16 obliges a business that must file an annual report, or
whose net revenue has passed 300 000 kr. in each of two consecutive years, to
keep its books in a digital bookkeeping system — registered with
Erhvervsstyrelsen, or meeting the same requirements. It reached companies in
regnskabsklasse B, C and D from 1 January 2025, and reaches personally-owned
businesses and associations from 1 January 2026. Nothing in this pack
enforces it: the storage is already digital, and the *provider* a company
reports to Erhvervsstyrelsen (a field of the annual report, § 138 a) is
outside a chart, a tax or a declaration form.

## What this pack does not carry

- **The domestic reverse charge of § 46, stk. 1, nr. 7-11** — scrap metal,
  mobile phones, integrated circuits, games consoles, tablets, laptops, and
  gas or electricity resold for resale: no cited source states which box the
  self-assessed side of a domestic reverse charge lands in, so the codes are
  left out rather than guess one; a professional's reading is needed first.
- **Rubrik B — varer, ikke EU-salgsangivelse**, the second goods box
  described above.
- **Import VAT on goods declared to customs**, assessed by customs on the
  import declaration; the pack has no customs document to hang it on.
- **The frivillig registrering (voluntary registration) for letting of
  immovable property**, § 51, noted above under Taxes.
- **The fixed assets module.** No `fixed_assets.json`: depreciation under
  årsregnskabsloven is a matter of estimate (§ 43), not a statutory table.
- **The XBRL fact keys of the annual report** (Inline XBRL through
  Erhvervsstyrelsens *Regnskab Basis*): the taxonomy is not verified line by
  line, so `xbrl` and `taxonomy` are null on both statements.
- **The exact DKK amount of the fixed compensation for recovery costs**,
  rentelovens § 9 a, stk. 3 — the figure is delegated to a ministerial order
  not cited here, so `late_payment_reference` states the mechanism only.

## Closing the year

`closing_style` is `retained_earnings`: the result of the year lands
straight on `3090 Overført overskud eller underskud`, because bilag 2's
equity block has one line for it (skema 1, PASSIVER, EGENKAPITAL, V) and does
not keep this year's result apart from what earlier years left
undistributed.

## Reviewing this pack

Open an issue titled "Review: Denmark". What a review is, and what it is
not, is in [`docs/packs.md`](../../docs/packs.md) under "Certification, and
who may say what". The points a reviewer is most likely to disagree with:
the choice of § 13, stk. 1, nr. 8 as the pack's one exemption code rather
than another of the twenty-two; whether `foreign_services_received` is the
right treatment for a service bought from a non-Union supplier under § 16,
stk. 1 rather than a Danish-specific word; and the nine-class chart itself,
which is this pack's own convention and not a transcription of anything a
Danish bookkeeper would recognise by number on sight.
