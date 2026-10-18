# Belgium

The format is [`docs/packs.md`](../../docs/packs.md). This file records what the
pack deliberately leaves out, and why, so that a Belgian accountant can
disagree with one line rather than with the whole pack.

**Status: `proven`.** The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent. On the 2025 books of a Belgian SA, imported from another system, the pack
reproduces to the euro every line of the income statement it filed with the
National Bank of Belgium (abridged model), and 25 of the 34 non-empty lines of
its balance sheet; the nine others carry one reclassification the accountant
made by hand. Its VAT returns were not tested: those books carry no VAT code.
`certification.evidence` in [`pack.json`](pack.json) says it scope by scope.
It proves the cases that company uses, not every regime of the country, and
no accountant has reviewed the pack.

## The VAT return: a purchase is printed by its nature and by who owes the tax

Grids 81, 82 and 83 hold every purchase by its nature — *le montant (TVA
déductible non comprise) des achats* — wherever the supplier is; grids 86, 87
and 88 say, besides, that the declarant owes the tax (Intervat help, cadre
III). An intra-Community acquisition of goods is therefore printed in 86 and
81, and a service received from another Member State in 88 and 82: since pack
1.17.1, `BE-P-ICG-21` and `BE-P-ICS-21` name both boxes on their base.

| Not carried | Why |
|---|---|
| The second grid of `BE-P-CC-21` and `BE-P-IMP-21` (87) | Works and imports may be goods, services or investment: the code does not say which of 81, 82 or 83, and a code per nature is not written yet. |
| An acquisition of investment goods or of goods for 82 | `BE-P-ICG-21` prints in 81, the grid of goods bought for resale or production. |
| The credit notes of 86 and 88 in 85 | The help gives 84 to them and 85 to *the other* operations of the frame: they stay in 84 only. |

## Corporate income tax: what `corporate_tax.json` leaves out

The section rests on the edition of the Income Tax Code 1992 for assessment
year 2026, the explanatory notes of return 275.1, the circular on the greening
of mobility, the prepayments page of SPF Finances and two laws in the Moniteur
belge, and nothing else. **Its figures are dated from assessment year 2026**,
written `"valid_from": "2025-12-31", "valid_on": "period_end"`: most of them
applied earlier, but earlier editions are not carried. A financial year before that is estimated at the ordinary rate, with
no reduced rate and no adjustment.

| Not carried | Why |
|---|---|
| The reduced rate and the disallowed expenses before assessment year 2026 | The start of each is not established from an official source. The 25 % rate is carried from the financial years opened on 1 January 2020, which the administration states. |
| The minimum director remuneration from assessment year 2027 | The law of 15 July 2026 replaces the 45 000 EUR of article 215, al. 3, 4° by an amount indexed every year, and the indexed figure is not carried. The company declares whether the condition is met (`director_remuneration_condition_met`) and the pack carries no amount. |
| The basket of article 207 beyond losses | The limit of 1 000 000 EUR plus 70 % applies to the total of several carried-forward deductions; only earlier losses are computed. The exception for small companies in their first four periods (al. 6) is not applied. The 70 % is carried for assessment year 2026 and left open-ended; it should be checked for 2027. |
| Car costs of a vehicle with no CO2 figure, the recalculated emission of a plug-in hybrid and the 50 % cap on its fuel | The company states the emission to use; the rest is not computed. |
| The declining deduction of zero-emission vehicles bought from 2027 (95 %, 90 %, 82,5 %, 75 %, 67,5 %) | Stated in the circular, and not written yet: no financial year it applies to is open. |
| The prepayment rates of assessment years 2024, 2025 and 2026 | Only those of assessment year 2027 are carried, from the administration's page. The due dates are the statutory ones of a company whose year is the calendar year; another year is not covered. |
| The separate assessments (article 219 and following, and article 219septies from assessment year 2027) | The section has no shape for one yet. |
| Meal vouchers, gifts to approved institutions, the non-deductible annual taxes of banks and insurers | Each needs a count or a ceiling the vocabulary of a rule does not carry. |
| Tax credits and withholding taxes set against the tax | `credits` is empty: the shape is published and no credit was cited. |

Nothing names the account `615200`, which holds restaurants (31 % refused) and
receptions (50 %) together, nor `664100`, which holds fines beside interest on
late payment: a company says which amount, or which account of its own, falls
under which rule.

## The analysis: what `analysis.json` reads

Since 1.20.0 the pack says which of its accounts make the aggregates of an
analysis ([`docs/analysis.md`](../../docs/analysis.md)). The balance-sheet
aggregates take exactly the accounts of the same rubrics of the abbreviated
model: `total_assets` is rubric 20/58, `equity` 10/15, `cash` 54/58,
`trade_receivables` 40, `trade_payables` 44, `long_term_debt` 17, and
`current_liabilities` 42/48 with 492/3.

| Choice | Why |
|---|---|
| `current_assets` leaves out rubric 29, the receivables due after more than a year | The schema prints 29 among the current assets; a current ratio asks what turns into cash within the year, and 29 does not. Everything else of 29/58 is taken: 3, 40/41, 50/53, 54/58, 490/1. |
| `net_result` is rubric 9904, classes 60 to 67 and 70 to 77 | The transfers to and from untaxed reserves (68, 78) and the appropriations (69, 79) move a result that is already made; they are not part of what the year earned. |
| `financial_result` is 75/76 less 65/66 | The two rubrics the income statement of the pack prints as financial. |
| Only the `default` chart | The chart of associations has accounts of its own, and nobody has written its analysis yet. |

## Fiscalisation / e-reporting

Belgium has one obligation in force on invoices between businesses, one
announced, and one distinct regime for cash registers. None of them asks for
a hash, a chain or a QR code on an invoice.

| Obligation | Text | Who, and from when | Channel |
|---|---|---|---|
| **B2B structured e-invoice** | Loi du 6 février 2024, Code de la TVA art. 53, § 2bis (`facturation-electronique`) | Taxable persons established in Belgium, between each other, since **1 January 2026** | Peppol BIS 3 over the Peppol network, the pack's `einvoicing` profile `peppol-bis-3`; another EN 16931 format by agreement of the parties |
| **E-reporting of invoice data** — *announced, no text in force* | None in force on 18 October 2026. The Council of Ministers approved a preliminary draft law amending the VAT Code on 18 July 2026, on the proposal of the Minister of Finance; the minister's answer quoted in avis n° 123/2025 of the Data Protection Authority, point 29 (`apd-avis-123-2025`), sets out the plan; the e-invoicing FAQ (`e-reporting-faq`) says it « doit encore être transposée en droit belge » | Announced from **1 January 2028**, for operations in Belgium between taxable persons subject to the e-invoicing obligation, reported by the supplier and by the customer (announcement of 18 July 2026). It transmits the mandatory data of the structured invoice — art. 5 of arrêté royal n° 1 (`ar-1`) — and replaces the annual customer listing of art. 53quinquies of the Code (`code-tva`). It needs a derogation of the Council of the EU under art. 395 of the VAT Directive (same avis) | « Near real-time » (FAQ). No published text names the channel; the structured Peppol invoice is the announced technical basis (same avis). The five-corner model, with the administration as the fifth corner, appears in professional commentary and in no official text read |
| **Intra-Community reporting (ViDA)** | The ViDA directive, as summarised by the FAQ and the same avis | Intra-Community operations, by **1 July 2030** at the latest | Not specified yet |
| **Certified cash register (SCE / GKS)** — *a distinct fiscalisation* | Arrêté royal du 30 décembre 2009, as amended by the arrêté royal du 25 mai 2026 (`ar-caisse-horeca-2026`), on VAT Code art. 53octies | Horeca establishments the regime covers. SCE 2.0 from **1 July 2026** for newly obliged establishments; systems registered 2014–2017 by 1 July 2027, 2018–2021 by 1 July 2028, 2022 to 30 June 2026 by 1 January 2029 (art. 5) | A fiscal data module and a VAT signing card sign every till receipt, and the data go to SPF Finances. A cash register is a device on the counter, outside what a ledger issues: the pack names the regime and does not carry it |

**What the pack declares.** `einvoicing.fiscalisation` is a reporting
regime: format `be-ereporting` (Peppol UBL is the announced basis; no brick
writes it yet, and the core refuses a report by name, `format_without_brick`),
`submission.mode` `batch`, and one scope reported, `invoices_between_taxable_persons`,
by the supplier and by the customer. The obligation is **announced, not in
force**: `announced_from` 2028-01-01, `announced_by` the Council of Ministers
on the proposal of the Minister of Finance, `announced_on` 2026-07-18, and no
`mandatory_from` until a law is published in the Moniteur belge — so
`ekwo einvoice fiscalisation` counts no sale as missing a report. The press
release of 18 July 2026 answered 403 and was not read; its date is the one
reported by professional bodies, and the plan itself is read in avis
n° 123/2025, point 29. **It declares no hash, no QR code and no mention.** The
law of 6 February 2024 and article 5 of arrêté royal n° 1, which lists what an
invoice carries, require none, and the announced reporting transmits data the
invoice already carries. The digital signature of a till receipt belongs to
the cash register regime above, and stays there.
