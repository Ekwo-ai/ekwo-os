# France

The format is [`docs/packs.md`](../../docs/packs.md). This file records what the
pack deliberately leaves out of form 3310-CA3, and why, so that a French
accountant can disagree with one line rather than with the whole return.

**Status: `proven`.** The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent. On the 2025 books of a French SAS under the simplified regime, imported from
another system, the pack reproduces to the euro every amount of the bilan and
the compte de résultat of the liasse fiscale 2033 it filed: 33 lines, read
through the 2050 to 2052 forms. Its CA3 returns were not tested: neither the
filed returns nor any VAT posting are in those books.
`certification.evidence` in [`pack.json`](pack.json) says it scope by scope.
It proves the cases that company uses, not every regime of the country, and
no accountant has reviewed the pack.

## Debt: the numbering of form 3310-CA3

**The metropolitan 2,1 % is declared on line T6, not on line 13.** On the
form in force — 3310-CA3, cerfa n° 10963*31, and its notice 3310-NOT-SD —
line 13 is *Anciens taux*, and the continental 2,1 % goes on line **T6**,
*Opérations réalisées en France continentale au taux de 2,1 %*. The pack
posts `FR-S-021` to a box it calls `13`. Since version 1.15.0 the label of
that box says so, in both languages; its identifier stays `13`, because an
identifier is immutable once published and a label is not.

The same is true of frame A, and of one line of frame B. The pack names its
boxes after a version of the form that preceded the one in force. The
amounts are the right ones; these identifiers are not the ones printed:

| Pack box | Printed on the form in force | Line |
|---|---|---|
| `01` | A1 | Ventes, prestations de services |
| `03` | B2 | Acquisitions intracommunautaires |
| `2A` | A3 | Achats de prestations de services réalisés auprès d'un assujetti non établi en France (art. 283-2) |
| `3A` | A4 | Importations (autres que les produits pétroliers) |
| `3C` | B4 | Achats de biens ou de prestations de services réalisés auprès d'un assujetti non établi en France (art. 283-1) |
| `04` | E1 | Exportations hors UE |
| `05` | E2 | Autres opérations non imposables |
| `06` | F2 | Livraisons intracommunautaires à destination d'une personne assujettie |
| `13` | T6 | Opérations réalisées en France continentale au taux de 2,1 % |
| `28` | TD | TVA due (ligne 16 – ligne 23); the form's own line 28 is TD less the energy excise credit X5, the same amount when there is none |

Every other box of the pack — `08`, `09`, `9B`, `10`, `11`, `15`, `5B`, `16`,
`17`, `19`, `20`, `21`, `22`, `2C`, `23`, `24`, `25`, `26`, `27` — carries the
identifier the form in force prints. One further point goes with the table:
an autoliquidated import posts its tax to line `08`, where the form in force
has lines **I1 to I6** for it.

The fix is a new version of the form beside the old one, the old closed with
a `valid_to` and the new opened with a `valid_from`, which needs a pack to hold
more than one form. It is not an edit of this one.

## The overseas departments

Article 296, 1°, of the CGI taxes Guadeloupe, Martinique and La Réunion at
**8,5 %** (standard) and **2,1 %** (reduced, for the operations of articles
278-0 bis to 279-0 bis A and 298 octies). Article 294, 1, makes VAT
provisionally **not applicable in French Guiana and Mayotte**. The
administration's commentary is BOI-TVA-GEO-20 and BOI-TVA-GEO-20-10
(`bofip.impots.gouv.fr`).

Since pack version 1.15.0 the pack carries, for each of `GP`, `MQ` and `RE`:

| Code | What |
|---|---|
| `FR-S-085-<dept>` | sale at 8,5 %, CA3 line 10 |
| `FR-S-085-ENC-<dept>` | service at 8,5 %, VAT on collection, line 10 |
| `FR-S-021-<dept>` | sale at 2,1 %, line 11 |
| `FR-P-085-<dept>` | purchase at 8,5 %, line 20 |
| `FR-P-085-ENC-<dept>` | purchase of services at 8,5 %, deductible on payment, line 20 |
| `FR-P-085-I-<dept>` | fixed asset at 8,5 %, line 19 |
| `FR-P-021-<dept>` | purchase at 2,1 %, line 20 |

Each code names its department in `applies_when.supply_in`, so the engine
refuses it for an operation located anywhere else. Three codes per rate and not
one, because `applies_when` has no disjunction: "Guadeloupe, Martinique or La
Réunion" is not something the format can say, and each department is a row of
`territories` already.

**French Guiana and Mayotte carry no code, and that is the law, not a gap.** An
operation located there is outside French VAT altogether. What the pack cannot
do is *refuse* a metropolitan code for such an operation: `FR-S-20` names no
territory, and a condition cannot say "not in GF". The core work on
territories that sit outside their parent's tax is where that belongs (see
[`docs/international.md`](../../docs/international.md#what-the-packs-do-not-say-yet)).

Not carried either: the special DOM rates of lines **T1** (1,75 %) and **T2**
(1,05 %), and the imports into a department,
which the customs administration pre-fills on lines **I1 to I6**.

`FR-P-021`, the metropolitan purchase at 2,1 %, is carried since the same
version.

## Form 3310-CA3, line by line

Against the form in force, millésime 2026 (cerfa n° 10963*31), and its
notice 3310-NOT-SD.

### Lines the pack carries since 1.15.0

`10` and `11` (the overseas departments, above); `17`, the intra-Community
acquisition tax already inside line 16, which the autoliquidation posting now
names beside `08`; `24`, the deductible import tax already inside line 23,
which the import posting names beside `20`; `27`, line 25 less line 26. And
six lines nothing in the pack posts to, declared so that the totals are the
form's and the declarant can fill them: **15** and **5B** (inside 16), **21**,
**22** and **2C** (inside 23), and **26**.

### Lines not carried, and why

| Line | Why not |
|---|---|
| A2 | other taxable operations — self-supplies and the like, no document of the pack produces one |
| A5, E5, E6 | suspensive tax and customs regimes |
| B1, F4, F5, P1, P2, 2E | petroleum products, for a TICPE payer |
| B3, F3 | electricity, gas, heat and cold, a regime of its own |
| B5, F8 | regularisations the notice asks never to net against the other lines |
| E3 | distance sales taxable in another Member State, declared through the One-Stop Shop |
| E4 | imports other than petroleum products, pre-filled by the customs administration |
| F1, F6 | non-taxable intra-Community acquisitions and purchases under franchise |
| F7 | sales by a taxable person not established in France, a return filed by that person |
| F9 | internal operations of a single taxable person (article 256 C) |
| T1, T2 | the special DOM rates of 1,75 % and 1,05 % |
| TC, T3, T4, T5 | Corsica, article 297 |
| T7 | withholding of VAT on authors' rights |
| I1 to I6 | see above |
| 18 | operations to Monaco, which the pack does not tell apart |
| 22A | a percentage, not an amount |
| TD | the pack's `28` is line 16 less line 23, which is TD; without the energy excise lines, TD and 28 are the same amount |
| X1 to Z5, M1 to M9 | the energy excise, declared on the same form |
| AA, AB, Y6 | VAT group consolidation (article 1693 ter) |
| 29, 32 | the assimilated taxes of annex 3310-A, and the total that adds them |

Line **14** of earlier versions of the form is not on the form in
force: the rates it used to gather from an annex are lines T1 to T7 now.

## VAT schemes and form 3517-S (CA12)

`vat_schemes.json` declares three schemes, and a company records the one it
is on from the first day of a financial year; nothing chooses it.

| Scheme | Forms | Text |
|---|---|---|
| `normal` — régime réel normal | `FR-CA3`, monthly by default, quarterly where the annual tax is under 4 000 € | CGI, art. 287, 1 and 2 |
| `simplified` — régime réel simplifié | `FR-CA12`, yearly, and two instalments | CGI, art. 302 septies A and 287, 3 |
| `franchise` — franchise en base | none; sales carry no VAT and the `small_business` mention | CGI, art. 293 B and 293 E |

The option of a simplified filer for the normal scheme, and of a franchise
for paying VAT (art. 293 F), are recorded as what they lead to: the company
states the scheme it is on. The ceilings are those in force on 1 January
2026, read on the DILA fiches F23566 and F21746 (`sp-regime-simplifie`,
`sp-franchise-en-base`); the CGI on Légifrance, BOFiP and impots.gouv.fr did
not answer on the day the scheme was written, and the form was read in its
2026 edition (`ca12`, cerfa n° 11417*27). A reviewer should check each
ceiling against the article itself.

**The CA12 restates the CA3.** The taxes of the pack post for the CA3; the
CA12 reads those postings (`reads_postings_of`) and adds them up over the
year, line by line: 02 ← 04, 03 ← 05, 04 ← 06, 5A ← 08, 06 ← 09, 6C ← 9B,
07 ← 10, 08 ← 11, 09 ← 13, 20 ← 20 and 23 ← 19. Line 30 holds the
instalments due for the year, paid or not, as the form asks (« acomptes payés
et/ou restant dus »); 33, 34 and 35 the balance; 57 the base of the next
year's instalments, line 16 less lines 11, 12 and 22.

**Instalments.** 55 % in July and 40 % in December of line 57 of the previous
year's CA12, none where that base is under 1 000 € (CGI, art. 287, 3). The day
of the month depends on the taxpayer, so an instalment is listed with its
month and no date. A company in its first year on the scheme, with no CA12 of
the year before, gets a plan whose base is unknown (`no_base`).

**Not carried yet:**

| What | Why |
|---|---|
| Lines AA, AB, AC (purchases where the buyer owes the tax) | the pack's reverse-charge postings print their tax in the rate lines of the CA3, which the CA12 restates in 5A to 09; telling them apart needs postings of their own |
| Lines 01, 3A, 3B, 4B, 4D, 5B, 9A, 2E | franchise purchases, distance sales, petroleum products, energy: nothing in the pack posts there |
| Section IV, the assimilated taxes, and the energy excise frame (X5, Y5, Z5, 54 to 56) | taxes of their own, not VAT |
| Lines 50 to 52 and the refund frame | a decision of the filer on a credit, entered by hand |
| The deadline, the second working day after 1 May | the closed vocabulary of deadline rules counts days in the month after the period, and a working-day shift needs a calendar; `upcoming_filings()` lists the CA12 without a date |
| CA12E, for a financial year that is not the calendar year | a `year` cadence is anchored on 1 January |
| The franchise ceilings of lawyers, authors and performers (50 000 € and 35 000 €) | a ceiling per profession is not in the vocabulary of `activity` |
| The goods and services split of a ceiling | the ledger does not split turnover by activity, so `vat_scheme_ceilings_crossed()` compares each ceiling with the whole turnover and can only over-warn |

## Accounts added in 1.17.2 for books taken over from elsewhere

A FEC of a French company read in October 2026 used three accounts the chart
did not carry. Each joins the chart at the six digits the pack pads its
accounts to, under the three-digit heading of the plan.

| Account | Plan account | Source |
|---|---|---|
| `101300` Capital souscrit — appelé, versé | 1013 | Plan de comptes of règlement ANC n° 2014-03, art. 1121-1, version 2025 ([anc.gouv.fr](https://www.anc.gouv.fr/files/anc/files/1_Normes_fran%C3%A7aises/Plans%20comptables/Plan-de-comptes-PCG-2025.pdf)) — 1011, 1012 and 1013 split account 101 by what has been called and paid; `101000` stays for a company that does not split it. |
| `442100` Prélèvements à la source (impôt sur le revenu), under `442` Contributions, impôts et taxes recouvrés pour le compte de l'État | 4421 | Règlement ANC n° 2018-02 du 6 juillet 2018, PCG art. 944-44 — 4421 is credited with the tax withheld from pay by the debit of 421 « Personnel — Rémunérations dues », and debited when it is paid to the State. |
| `699100` Produits — Crédit d'impôt recherche, under `699` Produits — Reports en arrière des déficits | 699 | The plan has no account for the research tax credit: 699 is the account the plan gives to carry-back. BOI-BIC-RICI-10-10-50, § 510 (source `boi-bic-rici-10-10-50`) records the credit « au débit du compte 444 « État - impôt sur les bénéfices » et par le crédit du compte 699 « Produits - Crédit d'impôt recherche » », in line with the position the ANC took in January 2011 to book it as a reduction of the tax. A subdivision of 695 is used by some ledgers; the pack follows the administration's text. |

The research tax credit is not taxable income (same paragraph): the rule
`research-tax-credit` of `corporate_tax.json` deducts the balance of
`699100` from the result the estimate starts from. Both 699 and 695 sit on
line HK of form 2052, so the income statement is unchanged by the choice.

## Corporate income tax: what `corporate_tax.json` leaves out

The section carries only rules cited to an official source. A rule that is missing makes an estimate too high or too low
by something a reader can name; these are the ones to name.

| Not carried | Why |
|---|---|
| The ceilings on the depreciation of passenger vehicles (CGI art. 39, 4: 30 000, 20 300, 18 300 and 9 900 € by CO2 band, with different bands for WLTP and NEDC registrations and by year of acquisition) | The excess depends on two figures of each vehicle — its price and its emission — and the formula vocabulary of a rule takes one. The company declares the excess under `excess-depreciation`. |
| The account of fines since the 2025 chart | The pack's chart still carries `671200`; règlement ANC n° 2022-06 moves fines to `6582` for financial years opened from 1 January 2025. The rule `fines-penalties` names the account the chart has, and a company that books on another names it in `tax.adjustments`. |
| An account for the annual taxes on vehicles | The chart carries none (`63514` in the plan), so `vehicle-taxes` applies to what the company names. The rule is dated from 1 January 2024, the version of CGI art. 39, 1, 4° cited; the same taxes were non-deductible before under art. 213. |
| The social contribution of 3,3 % (CGI art. 235 ter ZC) and the exceptional contribution on the profits of large companies | Both are a tax on the tax, above a turnover of 7 630 000 € and of 1 billion € respectively. The section has no shape for one yet. |
| Carry-back of a loss (CGI art. 220 quinquies) | An option, not a rule: nothing computes it. |
| Rounding of the base and of the tax to the euro | No rule cited. The estimate is kept at the cent. |
| Tax credits | `credits` is empty: the shape is published and no credit was cited. The research tax credit booked on `699100` is taken out of the taxable result (`research-tax-credit`); what it then pays of the tax is not computed. |
| Excess interest, personal benefits, non-deductible provisions (form 2058-A, lines SU, XZ, WD, WI) | No flat rule could be cited for any of them. |

The instalments are the four of CGI art. 1668 at a quarter of the reference
tax each. The order in which a company whose year is not the calendar year
pays them, and the large-company rule for the last one, are in the legal
reference and not in the data; nothing reads the schedule yet.

## The analysis: what `analysis.json` reads

Since 1.19.0 the pack says which of its accounts make the aggregates of an
analysis ([`docs/analysis.md`](../../docs/analysis.md)). Each aggregate
mirrors a line of the liasse where one exists, and takes exactly the accounts
the pack's own form 2050 or 2052 puts on it, side included: `total_assets` is
CO, `equity` DL, `current_assets` CJ, `cash` CF, `trade_receivables` BX,
`trade_payables` DX, `revenue` FJ, `net_result` HN, `financial_result` GV,
`income_tax` HK.

| Choice | Why |
|---|---|
| `revenue` takes 73 beside 70 | Line FJ, the net turnover, adds the partial income of long-term contracts. |
| `income_tax` is 695 to 699, not class 69 | 691 is the employees' share of the profit, which line HJ prints apart. |
| `equity` is 100 to 108 and 11 to 14, without 109 | 109, the capital subscribed and not called, is printed among the assets (AA). |
| `trade_receivables` is 411 to 418 with 491, not class 41 | 419, the advances received from customers, is a debt (DW); 491 is the impairment of customers BX deducts. |
| `trade_payables` is 401, 403 and 408 | 404 and 405 are the suppliers of fixed assets (DZ), and 4091 the advances paid to suppliers, an asset (BV). |
| `cash` is 51 in debit and 52 to 58 | Line CF. A bank account in credit is a bank overdraft, among the debts of line DU, and `current_liabilities` takes it. |
| `current_liabilities` is 401 to 408, 4191, 42 to 47 in credit, 487 and 51 in credit | Lines DW to EB, and the bank overdrafts of DU. 519 is not in the chart; a bank account in credit stands for it. |
| `long_term_debt` is 16 and 17 | The borrowings and the debts related to participations. |

## Fiscalisation / e-reporting

The reform has two halves: the e-invoice between businesses, and the
**e-reporting** of what that invoice does not carry — sales to private
customers, international operations, and the payment of services. Both go
through a *plateforme agréée* (PA, an approved platform) chosen by the company;
the State keeps the directory and the concentrator. A separate regime, older,
governs cash software.

| Obligation | Text | Who, and from when | Channel |
|---|---|---|---|
| **B2B e-invoice** | CGI art. 289 bis; ordonnance n° 2021-1190 (`facturation-electronique`); loi de finances rectificative pour 2022, art. 26; loi de finances pour 2024, art. 91; loi de finances pour 2026, art. 123; décret n° 2022-1299 and arrêté du 7 octobre 2022, amended by décret n° 2024-266 and by the décret n° 2026-677 and arrêté of 27 July 2026 | Between taxable persons established in France. Reception by every company from **1 September 2026**; issuing from **1 September 2026** for large companies, intermediate-sized companies and single VAT groups (CGI art. 256 C), from **1 September 2027** for small and medium companies and micro-enterprises | A PA, in Factur-X, UBL or CII (`specifications-externes`); the pack's `einvoicing` profile is `factur-x-en16931` |
| **E-reporting of transaction data** | CGI art. 290, I (established) and II (not established); CGI annex II art. 242 nonies M (data) and O (frequency); annex IV art. 41 septies D, L and M; BOI-TVA-DECLA-20-30-50 (`boi-tva-decla-20-30-50`) | Sales to non-taxable persons (B2C), totalled per day by category and rate; B2B operations with persons not established in France, invoice by invoice; purchases from non-established suppliers. Exempt operations of art. 261 to 261 E are out. Same dates as issuing, by size (BOI § 10); a non-established company liable as customer from 1 September 2027 whatever its size | A structured XML file through the PA (annex IV art. 41 septies L; BOI-TVA-DECLA-20-30-50-30 § 20–30), at the frequency below |
| **E-reporting of payment data** | CGI art. 290 A; annex II art. 242 nonies P; annex IV art. 41 septies P; BOI-TVA-DECLA-20-30-60 (`boi-tva-decla-20-30-60`) | Services whose VAT is due on collection, and down payments, outside reverse charge — on e-invoices (the status « Encaissée ») and on reported transactions. Same dates | Through the PA: the invoice's lifecycle status, or a payment report |
| **Secured cash software** — *a distinct fiscalisation* | CGI art. 286, I, 3° bis; BOI-TVA-DECLA-30-10-30 (`boi-tva-decla-30-10-30`) | Since 1 January 2018, a taxable person recording sales to private customers in cash software or a cash system | Nothing is transmitted: the software meets conditions of inalterability, security, retention and archiving, proven by a certificate or the publisher's attestation. The pack names the regime and does not carry it |

The frequency follows the company's VAT regime (annex II art. 242 nonies O and
P, III; annex IV art. 41 septies M and P; `frequences-e-reporting`). A period
without any operation sends nothing, and the count is per PA.

| VAT regime | Transaction data | Payment data |
|---|---|---|
| Réel normal, monthly (CGI art. 287, 2) | Three times a month — 1st–10th, 11th–20th, 21st–end — within ten days of each | Monthly, within ten days of the month's end |
| Réel normal, quarterly | Monthly, within ten days | Monthly, within ten days |
| Réel simplifié (art. 298 bis, 302 septies A) | Monthly, between the 25th and the end of the following month | Same |
| Franchise en base (art. 293 B) and flat-rate refund (art. 298 quater, 298 quinquies) | Every calendar two-month period, between the 25th and the end of the following month | Same |

**What the pack declares.** `einvoicing.fiscalisation` is a reporting
regime: format `fr-ereporting` (the transaction and payment flows of the
external specifications; no brick writes it yet, and the core refuses a report
by name, `format_without_brick`), `submission.mode` `batch` through the
`accredited_platform`, with the eight cadences of the table above — `who` is
`real_normal_monthly`, `real_normal_quarterly`, `real_simplified` or
`franchise_or_flat_rate_refund`, `data` is `transactions` or `payments`, each
with its article. `mandatory_from` is 1 September 2026 for `large`,
`intermediate` and `single_vat_groups`, 1 September 2027 for `small_medium`,
`micro` and `non_established_liable`. Three scopes are reported:
`sales_to_non_taxable_persons` and `payments_received_on_services` by the
supplier, `operations_with_non_established_persons` by the supplier and the
customer. **It declares no hash, no QR code and no mention.** Articles 290 and
290 A of the CGI, their decrees and the BOFiP comment (BOI-TVA-DECLA-20-30-50
and -60) require none: the data leave as a file through the PA. The four
mentions the reform adds to the invoice itself — the customer's SIREN, the
category of the operation, the option for VAT on debits, the delivery address
— sit in annex II art. 242 nonies A, among the invoice's mentions, and are
outside this block.
