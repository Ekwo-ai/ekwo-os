# Denmark

Everything Denmark adds to Ekwo, as data: a chart of accounts, the journals,
the VAT rates and where each one posts, the boxes of the momsangivelse, the
balance sheet and the income statement of the annual report, and the
sentences the law puts on an invoice. The format is
[`docs/packs.md`](../../docs/packs.md); this file says where the content came
from and which decisions it rests on, so that a Danish accountant reading the
pack can disagree with a specific sentence rather than with the whole of it.

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
| What each box of the momsangivelse means, in plain words | Skattestyrelsen's help texts for the VAT return | `dst.dk` (archived copy of the office's own wording), and `skat.dk/tastselverhverv` where it is filed |
| The chart of accounts, and the obligation to describe bookkeeping procedures instead of one | Bogføringsloven, LOV nr 700 af 24/05/2022 | `retsinformation.dk/eli/lta/2022/700` |
| The balance sheet and income statement schemes | Årsregnskabsloven, LBK nr 402 af 23/03/2026, bilag 2 | `retsinformation.dk/eli/lta/2026/402` |
| Payment terms and default interest | Renteloven, LBK nr 459 af 13/05/2014, as amended | `retsinformation.dk/eli/lta/2014/459` |
| E-invoicing to the public sector, NemHandel | Bekendtgørelse om elektronisk afregning med offentlige myndigheder, BEK nr 206 af 11/03/2011 | `retsinformation.dk/eli/lta/2011/206`; `erhvervsstyrelsen.dk` |
| Digital bookkeeping, the 2026 extension to sole traders | Erhvervsstyrelsen's own announcement | `erhvervsstyrelsen.dk` |
| The ISO 6523 identifiers, the VAT category and exemption reason codes | Peppol BIS Billing 3.0, UNCL5305, VATEX | `docs.peppol.eu` |

Retsinformation.dk is a single-page application: a plain fetch of a law's
`/eli/lta/...` URL returns an empty shell, and the text has to be read from
the PDF the same page links, `retsinformation.dk/api/pdf/<id>`, or read live
in a browser.

## The chart of accounts, and why this one

**Denmark prescribes no chart of accounts.** Bogføringslovens § 6 obliges a
bookkeeping-liable business that must file an annual report, or whose net
revenue has passed 300 000 kr. in each of two consecutive years, to write a
*description* of its procedures for registering transactions and keeping its
records — not to adopt a particular chart, and not to number an account a
particular way. There is therefore nothing to copy from a statute, and
nothing that could be called *the* Danish chart, the way there is none for
Estonia.

This chart is original. It is built around nine numeric classes, each tied to
one group of lines of årsregnskabslovens bilag 2:

- **1** fixed assets, **2** current assets, **3** equity, **4** provisions and
  non-current liabilities, **5** current liabilities, **6** revenue, **7**
  operating costs, **8** financial items and tax.
- **Flat.** No parent accounts: every account here is a leaf, and the
  grouping the balance sheet and the income statement need is done by the
  `code_range` rules of `statements.json`. A reader who wants the balance
  sheet's *Omsætningsaktiver* reads class 2 straight off the chart.
- **The special ledger accounts momsbekendtgørelsens § 76 requires.** The
  executive order names nine accounts a VAT-registered business must be able
  to produce: one for input VAT, one for output VAT, one for the tax on
  purchases from abroad (§ 76, stk. 1, nr. 3-4), and separate ones for the
  *value* of EU acquisitions and EU and export supplies (nr. 5-9). The first
  three are `2160`, `5160` and the pair `2170`/`5170`; the value accounts are
  the point of having `6010`/`6020`/`6030` and `7020` apart from `6000` and
  `7010` in the first place — the special account and the ordinary revenue or
  cost account are the same account here, because nothing in the executive
  order asks for a fourth ledger.

## Taxes

**Denmark has one VAT rate.** Momslovens § 33 sets it at 25 % of the tax base
and has done since 1992; there is no reduced rate, which makes `DK-S-25` and
`DK-P-25` the only positive-rate codes this pack carries, and is a fact of
Danish law rather than a gap of this pack.

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

**§ 16, stk. 1 does not distinguish the supplier's own country.** The general
B2B place-of-supply rule — the service is taxed where the buyer is
established — applies whether the supplier sits in Stockholm or in London,
which is why `DK-P-EU-SERVICES` and `DK-P-NONEU-SERVICES` are the same
mechanism under two treatments: the first is `intracom_acquisition_services`
because the supplier's own invoice carries the Union's `K`/`VATEX-EU-IC`
pairing, the second `foreign_services_received` because no invoice EN 16931
governs exists to record a category for.

**One exemption is carried, and it is chosen for what it is not conditioned
on.** § 13 lists twenty-two exempt activities, several of which this pack
could not state without a fact no ledger holds — a resale certificate, a
threshold crossed. The letting of immovable property (§ 13, stk. 1, nr. 8) is
not one of them in the ordinary case, which is why it is the one this pack
carries. What it does not carry is the landlord's option: § 51 lets a
landlord register voluntarily for VAT on a commercial letting, which turns
the same supply taxable. Nothing in the ledger records whether that election
was made, so this pack always reads a letting as exempt; a company that has
elected in needs a positive-rate code of its own, which is a company decision
this pack does not anticipate.

**The self-assessed taxes carry two `tax` postings, not one.** `DK-P-EU-GOODS`
and its two service siblings post the same amount twice: once to `2170`
(deductible, box `koebs`, the same box the domestic purchase tax posts to,
because momsbekendtgørelsens § 76, stk. 3 lets the two be pooled once
assessed) and once with `factor: -100` to `5170` (payable, box `eumoms` or
`ydmoms`). A fully deductible business nets to zero on the ledger and still
declares both the payable and the deductible side, because the return asks
for both.

## The momsangivelse

`tax_report.json` carries the periodic return under the code `DK-MOMS`, with
the ten boxes momsbekendtgørelsens §§ 76 and 79 describe: `Salgsmoms`,
`Moms af varekøb i udlandet`, `Moms af ydelseskøb i udlandet med omvendt
betalingspligt`, `Købsmoms`, the total `Momstilsvar`, and rubrik A (varer,
ydelser), B (varer, ydelser) and C.

**The period is not one cadence.** Momslovens § 57 files a business monthly
above 50 million kr. of annual taxable turnover, quarterly between 5 and 50
million, and half-yearly below 5 million — three cadences with no single
answer the law gives everybody, which is why `tax_report.json` declares no
`period_default` and `ekwo init` asks. The golden scenario books a company
that files quarterly, the middle and most common case.

**Rubrik B splits goods sold to other EU countries in two, and this pack
carries only the ordinary one.** Momsbekendtgørelsens § 79, stk. 1, nr. 3 and
4 distinguish an EU sale that has to be reported to the separate EU sales
list system (*EU-salg uden moms*) from one that does not — remote sales a
business is itself registered for abroad, new means of transport to a
private buyer, installation and assembly. `bvarer` carries the first, the
ordinary case of `DK-S-EU-GOODS-0`; the second box is a gap, listed below.

**The deadline declared is the monthly one, and it is early for the other two
cadences.** `deadline` in this format is one rule for the whole form, and
Denmark's three cadences do not share a shape: the monthly return is due the
25th of the following month (§ 57, stk. 1, with an extension to the 17th of
the second month after for June), which fits `day_of_month_after_period`;
the quarterly and half-yearly returns are due the first day of the *third*
month after the period ends (§ 57, stk. 3 and 4) — two months out, not one,
which none of the three closed rules this format offers can say. The pack
declares the monthly day, which is never later than the law and several
weeks early for a quarterly or half-yearly filer — the same choice the
Australian pack makes for its own monthly/quarterly split, and the one
`docs/international.md` already names as a gap under "From Australia";
Denmark's own section adds that its version of the gap is wider still, a
full extra month rather than a week.

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

`einvoicing.obligation` is `none`. No Danish statute obliges a company to
issue or receive an electronic invoice in its dealings with another company.
The obligation that exists reaches the public sector alone: a supplier to a
Danish public authority has to send the invoice through Nemhandel, the
shared infrastructure, and the authority has to be able to receive it — BEK
nr. 206 af 11/03/2011, issued under the law on public payments. That is the
case `docs/packs.md` says is written in `legal_reference` and does not
change the word. The format is OIOUBL by the letter of that decree, and
increasingly Peppol BIS Billing 3.0 with the Danish CIUS in practice, which
is what `profile` names; a proposal to modernise the decree without moving
this boundary was in public consultation until 3 November 2025 and had not
been enacted at the time this pack was written.

**`party_scheme` and `vat_scheme` are the same code, 0184.** Denmark has no
VAT number apart from the CVR number: the Danish VAT identifier is `DK`
followed by the eight digits of the CVR number, so both Peppol identifiers
this pack could name resolve to the same register entry.

## Digital bookkeeping, outside the pack

Bogføringslovens § 16 obliges a business that must file an annual report, or
whose net revenue has passed 300 000 kr. in each of two consecutive years, to
keep its books in a digital bookkeeping system — registered with
Erhvervsstyrelsen, or meeting the same requirements on its own. The
obligation reached companies in regnskabsklasse B, C and D from 1 January
2025, and reaches personally-owned businesses and associations from
1 January 2026. Nothing in this pack enforces it: Ekwo's own storage already
is digital, and which *provider* a company reports to Erhvervsstyrelsen (a
new field of the annual report, § 138 a) is outside the scope of a chart of
accounts, a tax or a declaration form.

## What this pack does not carry

- **The domestic reverse charge of § 46, stk. 1, nr. 7-11** — scrap metal,
  mobile phones, integrated circuits, games consoles, tablets, laptops, and
  gas or electricity resold for resale. These are anti-fraud measures for a
  narrow set of B2B wholesale goods, and this pack found no source stating
  plainly which box of the momsangivelse the self-assessed side lands in for
  a domestic (not cross-border) reverse charge, as opposed to the
  cross-border ones this pack does carry. Rather than guess a box, the codes
  are left out; a company that needs them needs a professional's reading
  first.
- **Rubrik B — varer, ikke EU-salgsangivelse**, the second goods box
  described above.
- **Import VAT on goods declared to customs**, which is assessed by customs
  on the import declaration and not self-assessed the way an intra-Union
  acquisition is; the pack has no customs document to hang it on.
- **The frivillig registrering (voluntary registration) for letting of
  immovable property**, § 51, noted above under Taxes.
- **The fixed assets module.** There is no `assets.json`: the usual
  depreciation practice under årsregnskabsloven is a matter of estimate
  (§ 43) rather than a table a statute sets out, and this pack cites texts.
- **The XBRL fact keys of the annual report.** Danish annual reports are
  filed in Inline XBRL through Erhvervsstyrelsens *Regnskab Basis*, against a
  taxonomy this pack has not verified line by line; `xbrl` and `taxonomy`
  are left null on both statements rather than guessed.
- **The exact DKK amount of the fixed compensation for recovery costs**,
  rentelovens § 9 a, stk. 3 — the text delegates the figure to a ministerial
  order this pack has not traced, so `late_payment_reference` states the
  mechanism and not a number.

## Closing the year

`closing_style` is `retained_earnings`: the result of the year lands
straight on `3090 Overført overskud eller underskud`, because bilag 2's
equity block has one line for it (skema 1, PASSIVER, EGENKAPITAL, V) and not
two — unlike Belgium's appropriation accounts or France's separate
current-year-result line, Denmark's own scheme does not keep this year's
result apart from what earlier years left undistributed.

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
