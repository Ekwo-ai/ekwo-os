# Belgium

The format is [`docs/packs.md`](../../docs/packs.md). This file records what the
pack deliberately leaves out, and why, so that a Belgian accountant can
disagree with one line rather than with the whole pack.

**Status: `maintained`.** The figures are replayed against a year of books by
`tests/golden.test.ts`, which proves the pack is coherent and not that it is
right.

## Corporate income tax: what `corporate_tax.json` leaves out

The section carries what was read on an official page on 30 September 2026 —
the edition of the Income Tax Code 1992 for assessment year 2026, the
explanatory notes of return 275.1, the circular on the greening of mobility,
the prepayments page of SPF Finances and two laws in the Moniteur belge — and
nothing else. **Its figures are dated from assessment year 2026**, written
`"valid_from": "2025-12-31", "valid_on": "period_end"`: most of them applied
earlier, and the pack does not say so because nobody read the earlier
editions. A financial year before that is estimated at the ordinary rate, with
no reduced rate and no adjustment.

| Not carried | Why |
|---|---|
| The reduced rate and the disallowed expenses before assessment year 2026 | The start of each was not read on an official page. The 25 % rate is carried from the financial years opened on 1 January 2020, which the administration states. |
| The minimum director remuneration from assessment year 2027 | The law of 15 July 2026 replaces the 45 000 EUR of article 215, al. 3, 4° by an amount indexed every year, and the indexed figure was not read on an official page. The company declares whether the condition is met (`director_remuneration_condition_met`) and the pack carries no amount. |
| The basket of article 207 beyond losses | The limit of 1 000 000 EUR plus 70 % applies to the total of several carried-forward deductions; only earlier losses are computed. The exception for small companies in their first four periods (al. 6) is not applied. The 70 % was read for assessment year 2026 and is left open-ended: no later amendment was found, and none was read for 2027. |
| Car costs of a vehicle with no CO2 figure, the recalculated emission of a plug-in hybrid and the 50 % cap on its fuel | The company states the emission to use; the rest is not computed. |
| The declining deduction of zero-emission vehicles bought from 2027 (95 %, 90 %, 82,5 %, 75 %, 67,5 %) | Read in the circular, and not written yet: no financial year it applies to is open. |
| The prepayment rates of assessment years 2024, 2025 and 2026 | Only those of assessment year 2027 were read on the administration's page. The due dates are the statutory ones of a company whose year is the calendar year; the rule for another year was not read. |
| The separate assessments (article 219 and following, and article 219septies from assessment year 2027) | The section has no shape for one yet. |
| Meal vouchers, gifts to approved institutions, the non-deductible annual taxes of banks and insurers | Each needs a count or a ceiling the vocabulary of a rule does not carry. |
| Tax credits and withholding taxes set against the tax | `credits` is empty: the shape is published and no credit was cited. |

Nothing names the account `615200`, which holds restaurants (31 % refused) and
receptions (50 %) together, nor `664100`, which holds fines beside interest on
late payment: a company says which amount, or which account of its own, falls
under which rule.
