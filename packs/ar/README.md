# Argentina

Everything Argentina adds to Ekwo, as data: a chart of accounts built around
the minimum disclosure of the Ley General de Sociedades, the journals, the
value added tax at its three positive rates with exports at tasa cero and the
exemptions of art. 7, the boxes of the monthly IVA declaration, a minimal
balance sheet and income statement, and the sentences an invoice needs. The
format is [`docs/packs.md`](../../docs/packs.md); this file says where the
content came from and which decisions it rests on, so that an Argentine
accountant reading the pack can disagree with a specific sentence rather than
with the whole of it.

**Status: `community`.** Nobody who files an Argentine return has reviewed
it. The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and proves nothing
about whether it is right.

**Language: `es`.** Every label of this pack is written in Spanish, which is
the language of the law it transcribes. No second language is declared: the
chart is original (see below) and has no official wording in any language to
carry as `i18n`, so a translation would be this pack's own words translated a
second time rather than a text somebody can check against a source. A
contributor is welcome to add `i18n/en.json` one section at a time without
declaring it, exactly as `docs/packs.md` describes.

## Ekwo does not issue an Argentine invoice

**An Argentine factura is a clearance document, and it exists only once ARCA
authorises it.** Resolución General (AFIP) 4291/2018: before handing the
document to the buyer, the issuer asks a web service of the Agencia de
Recaudación y Control Aduanero (ARCA, formerly AFIP — Decreto 953/2024) to
authorise it, which validates the data and returns a Código de Autorización
Electrónico (CAE); without it the document does not support the operation for
tax purposes. Resolución General (AFIP) 4290/2018 generalised the obligation
in 2018–2019 to essentially every taxpayer issuing invoices for the sale of
goods or services — responsables inscriptos, exentos and monotributistas
alike.

Ekwo writes no ARCA invoice XML, calls no web service and requests no CAE. So:

- `einvoicing` names **no profile and no date**, although the obligation
  exists. `profile` names a profile built on EN 16931 that a brick of
  `packages/formats/` writes, and a comprobante electrónico with CAE is
  neither; the format refuses an obligation with a date and no profile, and
  has no word for "valid only once a third party authorises it". Its legal
  reference says what the law requires and says in capitals that Ekwo neither
  generates, requests authorisation for, nor transmits comprobantes to ARCA.
  Declaring a profile anyway would have made the country page promise a
  writer brick and Peppol transmission Argentina does not have — Mexico,
  Vietnam, South Korea and Saudi Arabia leave the same fields empty for the
  same reason; see *From Argentina* in
  [`docs/international.md`](../../docs/international.md).
- Every document carries the mention `no_cae`: *this document does not carry
  ARCA's Código de Autorización Electrónico and is not valid as an invoice for
  tax purposes until authorised.*
- The number a document gets in Ekwo is the number of the accounting entry —
  correlative per journal, without a year in it (`numbering: gapless`) —
  and not the fiscal comprobante number, which only ARCA authorises through
  Resolución General 4291/2018.

What a company does today: request the CAE through ARCA's web service or its
own billing software, and record the operation in Ekwo. The format of this
repository cannot yet say "mandatory, by clearance"; see *What the core could
not say* below.

## Sources

Every rate, box, mention and statement carries its own `legal_reference` and
the key of the text it is in. The register in `pack.json` holds **12 texts**,
every one opened on 25 September 2026: the Ley de Impuesto al Valor Agregado
(texto ordenado 1997) and its Decreto Reglamentario 692/1998 on InfoLeg; the
Ley General de Sociedades 19.550 and the Código Civil y Comercial (Ley
26.994), also on InfoLeg; Decreto 953/2024, which dissolved AFIP and created
ARCA; Resoluciones Generales (AFIP) 4290/2018 and 4291/2018, on electronic
invoicing; Resolución General (ARCA) 5705/2025, which created the "IVA
Simple" system and Form F. 2051; Resolución General (AFIP) 4172/2017, the
Agenda General de Vencimientos; two ARCA portal pages (the IVA declaration and
the electronic-invoice subjects page); and the FACPCE, named as the source of
the professional accounting standards this pack does not transcribe.

## The chart of accounts

**Argentina prescribes no numbered chart of accounts.** The Código Civil y
Comercial, art. 321, asks only that bookkeeping be kept "on a uniform basis"
that allows individualising operations, and art. 322 lists the indispensable
records (diario; inventario y balances) without naming a single account. The
Ley General de Sociedades, arts. 63 and 64, is more specific about what a
statement has to show — current and non-current assets, current and
non-current liabilities, equity; revenue by type of activity, cost of sales,
administrative and selling expenses, financial and holding results — but
still names rubros, not accounts.

This pack's 128 accounts are therefore **original**: a convention of its own,
three to five digits deep depending on how far a rubro is broken down by
nature, in which the first digit is Activo (1), Pasivo (2), Patrimonio Neto
(3), Ingresos (4) or Costos y Gastos (5), and every block of three-digit
codes corresponds to exactly one line of `AR-ESP` or of `AR-ER`, so the chart
reads straight off the two statements it feeds; the four- and five-digit
accounts underneath a block — bienes de uso by nature with their own
amortización acumulada, bienes de cambio by stage, cargas sociales, gastos by
nature — are that block's own detail and do not move the statement line they
roll up to. The professional presentation
standard is the FACPCE's Resoluciones Técnicas — chiefly RT 8 (normas
generales de exposición) and RT 9 (normas particulares para entes
comerciales, industriales y de servicios) — but the Federación is a
professional body and not an organ of the State, and its text is not
transcribed here; a reviewer who holds the RT is the one who can say whether
this chart's rubros line up with theirs.

Four decisions:

- **The IVA accounts separate posting from settlement, on both sides.**
  `2131` *IVA Débito Fiscal* and `1151` *IVA Crédito Fiscal* are where every
  tax posts; `2132` *IVA a Pagar* and `1152` *IVA Saldo a Favor - Técnico* are
  the reconcilable settlement accounts `settle_filing()` carries the net of a
  period to, distinct from the posting accounts as the format requires.
- **The suspense account is `117`** *Partidas pendientes de imputación*, not
  reconcilable, and never the bank or the cash account.
- **`receivable` and `payable` name one subaccount each** — `1131` *Deudores
  por ventas - Mercado interno* and `2111` *Proveedores - Mercado interno* —
  although both headings (`113`, `211`) and every subaccount under them are
  reconcilable: the database itself requires an `asset_receivable` or
  `liability_payable` account to be reconcilable, whether or not it is a
  heading nothing is ever posted to.
- **The result of the year goes to `351` / `352`**, and the close carries it
  to `341` / `342` (`closing_style: result_accounts`), the same mechanism
  France uses (120/129): the result sits on its own line of the balance sheet
  until the asamblea decides its allocation (LGS arts. 68 and 70, not
  transcribed as a rule of this pack since no tax or statement line depends
  on it).

**No inflation adjustment, and no RECPAM.** Ley 27.468 reinstated *ajuste por
inflación contable* (art. 62, LGS, and RT 6 of the FACPCE) for a fiscal year
whose cumulative inflation crosses the thresholds the law sets, which
Argentina's has for every year this pack could check. That restatement
produces the *Resultado por Exposición al Cambio en el Poder Adquisitivo de
la Moneda* (RECPAM) — the gain or loss a company books from holding monetary
assets and liabilities while the currency loses value — as a line of its own
in the estado de resultados. Restating a chart of accounts for the loss of
purchasing power of the currency is a computation over a whole year of
balances, not a fact one document or one tax can carry, and `docs/packs.md`
has no mechanism for it anywhere in the format: this pack carries no RECPAM
account and no inflation adjustment, on any account, in any golden document;
see *From Argentina* in `docs/international.md`.

## Taxes

| Code | Rate | Scope | Treatment | Declaration boxes |
|---|---|---|---|---|
| `AR-S-21` | 21 % | sale | domestic | G21 / C21 |
| `AR-S-27` | 27 % | sale | domestic | G27 / C27 |
| `AR-S-105` | 10.5 % | sale | domestic | G105 / C105 |
| `AR-S-EXP` | 0 % | sale | export | GEXP |
| `AR-S-EXE` | — | sale | exempt | GEXE |
| `AR-P-21` | 21 % | purchase | domestic | PC21 / CF21 |
| `AR-P-27` | 27 % | purchase | domestic | PC27 / CF27 |
| `AR-P-105` | 10.5 % | purchase | domestic | PC105 / CF105 |
| `AR-P-EXE` | — | purchase | exempt | PCEXE |
| `AR-P-IMP` | 21 % | purchase | import | PCIMP / CFIMP |

**The general rate is 21 %** (Ley de Impuesto al Valor Agregado, art. 28,
first paragraph). **The increased rate, 27 %**, applies to metered gas,
electricity and water and to the other supplies of art. 3, inciso e), points
4 to 6, when sold outside a dwelling to a buyer who is a responsable
inscripto or a monotributista (art. 28, second paragraph) — this pack does
not condition the code on the buyer's registration or on the address, which
the bookkeeper still has to read off the invoice. **The reduced rate, 10.5 %**
— exactly half the general one — reaches the goods and services art. 28,
third and fourth paragraphs enumerate: live cattle and meat of the bovine and
ovine species, fresh fruit and vegetables, bulk honey, grains and dried
legumes, the works and services that obtain them, housing construction under
art. 3, inciso b), interest on loans from entities under Ley 21.526, certain
capital goods, passenger transport over 100 km, health-assistance services not
otherwise exempt, and the sale of newspapers, magazines and periodicals. This
pack transcribes the first paragraph of each rate and does not enumerate every
item of art. 28's four paragraphs as separate codes: a sale at 10.5 % or 27 %
is booked against the general code of the matching rate, and the bookkeeper
is the one who knows which paragraph the operation falls under.

**Exports are exempt with a right to recover the related credit** (art. 8,
inciso d), and art. 43): no débito fiscal is charged, and the crédito fiscal
that produced the exported goods or services may be offset against other
débito fiscal or, failing that, credited, refunded or transferred. This is
the exemption-with-recovery shape most packs model as a zero rate, and
`AR-S-EXP` does the same.

**Article 7 exempts a list of operations** — among others, books and similar
printed matter, postage stamps, ordinary natural water, common bread,
unadulterated milk to a final consumer or an exempt subject, medicines resold
by a pharmacy, education services, the services of an obra social or of
medicina prepaga, and international passenger and freight transport. This
pack transcribes the article generally in `AR-S-EXE` / `AR-P-EXE` and does not
carry a code per item of the list.

**Imports pay the tax with the despacho de importación** (art. 1, inciso c),
and art. 25): the amount is liquidated and paid together with the import
duties, at the rate of the domestic sale of the same good, and is computable
as crédito fiscal. `AR-P-IMP` carries the general rate; a good whose domestic
sale would be reduced or exempt pays the tax at that rate instead, which this
pack does not model as a separate code.

**Not here:** withholdings and perceptions of VAT, of Impuesto a las
Ganancias and of Ingresos Brutos, the digital-services tax on services
received from abroad, and the region-conditioned discount Mexico's border
decrees carry, which Argentina's law does not have an equivalent of; see
*What the core could not say* below.

## The declaration

`AR-IVA` is the monthly determination of the value added tax (Ley de
Impuesto al Valor Agregado, art. 27, first paragraph: the tax is liquidated
and paid by calendar month). Since the November 2025 tax period the return is
filed through "IVA Simple" and Form F. 2051, which replaced Forms F. 731, F.
810, F. 2082 and F. 2002 "IVA por Actividad" (Resolución General (ARCA)
5705/2025, arts. 2, 3 and 8). That portal reads the comprobantes ARCA has
already authorised and presents no numbered fields of its own, unlike the
forms it replaced — this pack's box codes (`G21`, `C21`, `CF21`…) are
therefore acronyms of its own over the substance the law fixes in arts. 11,
12 and 24, and not the wording of a screen this pack could not verify.

- `DEBFIS` sums the débito fiscal of every positive rate (art. 11): the tax
  applying the rate to the net price of every taxed sale.
- `CREDFIS` sums the crédito fiscal of every positive rate and of imports
  (art. 12): the tax the taxpayer's own suppliers charged, on purchases
  linked to taxed operations.
- `SALDOTEC` is `DEBFIS` minus `CREDFIS` — the **saldo técnico** of art. 24,
  first paragraph. A positive figure is owed; a negative one is a credit that
  the same article confines to offsetting the débito fiscal of a following
  period, and refunds it in no other way. Article 24's second paragraph
  carves out a second kind of balance — from retenciones, percepciones and
  other direct payments — which can be offset against other taxes or
  refunded; this pack does not liquidate that second balance at all, since
  the retentions and perceptions that produce it are out of its scope (see
  below), so `tax_receivable` here always means the confined, non-refundable
  saldo técnico and never the freely disponible one. The format has no way to
  state that restriction on a credit balance; see *From Argentina*.
- **Due date**: art. 27 gives no fixed day; the return and its balance are
  due on the schedule of the Agenda General de Vencimientos (Resolución
  General (AFIP) 4172/2017 and its amendments), one business day per C.U.I.T.
  termination that ARCA publishes and updates every year — hence
  `depends_on_taxpayer`.
- Article 27's third paragraph lets a taxpayer whose operations are
  exclusively agropecuarias opt for a quarterly cadence; this pack declares
  `period: ["month"]` only and does not model that option.

## The statements

`AR-ESP` (estado de situación patrimonial) and `AR-ER` (estado de resultados)
answer LGS arts. 63 and 64: assets split into current and non-current, by
rubro (cash and banks, investments, receivables, other receivables, tax
credits, inventory; non-current receivables, fixed assets, intangibles);
liabilities the same way (trade payables, payroll, tax liabilities, customer
advances, provisions; long-term debt); equity (capital, reserves, retained
earnings, result of the year); and an income statement carrying revenue by
activity, cost of sales, selling and administrative expenses, financial and
holding results, and the net result. `xbrl` is null everywhere: no Argentine
taxonomy is mapped by this pack. This is a minimal structure over those
rubros, not the full presentation of RT 8 and RT 9, which a professional
holding them is best placed to map.

## The golden year

A trading company, responsable inscripta, filing monthly, January to March
2026: 11 documents and 4 payments. It sells at 21 % with a partial credit
note against the same invoice, sells electricity to a shop at 27 %, sells
grain at 10.5 %, exports and is paid for it, sells books exempt under art. 7;
it buys merchandise at 21 %, buys electricity for its plant at 27 %,
buys agricultural inputs at 10.5 %, buys exempt technical books, and imports
merchandise with a despacho de importación at 21 %. One payment is left
unmatched, an advance from a customer with no invoice against it yet.

## What the core could not say

The Argentine section of
[`docs/international.md`](../../docs/international.md) states each of these
as a change to the core. In short:

1. **Clearance.** `einvoicing` can say "mandatory" only for an EN 16931
   profile, and has no way to say "valid only once ARCA authorises it"; the
   pack leaves the fields empty and says so in the reference, the fourth
   pack in this position after Mexico, Vietnam and South Korea (and the
   fifth counting Saudi Arabia).
2. **No inflation adjustment.** A restatement of a whole year of balances for
   the loss of purchasing power of the currency has no place in this format.
3. **Withholdings and perceptions.** IVA, Ganancias and provincial Ingresos
   Brutos each carry a withholding or a perception regime this pack does not
   model at all — not even the posting-timing gap Mexico and Senegal
   describe, since the core has no notion of a third party collecting a tax
   on the administration's behalf.
4. **A restricted credit balance.** `tax_receivable` cannot say that a credit
   is confined to offsetting a future débito fiscal and not refundable,
   which is exactly what the saldo técnico of art. 24 is.
5. **A rate conditioned on the buyer's registration and the address of the
   supply**, for the 27 % rate of art. 28, second paragraph — the bookkeeper
   picks the code, as for Mexico's border region.

## For a reviewer

The first things to read against practice: the choice to leave the chart
original rather than reaching for a software vendor's plan; the wiring of the
IVA accounts and of the saldo técnico role; the general transcription of
arts. 7 and 28 rather than one code per item of their lists; and whether the
minimal statements should give way to a mapping of RT 8 and RT 9 by a
professional who holds them.
