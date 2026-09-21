# Reports read the ledger and know no country

> Status: accepted

## Context

A report computed from documents cannot tie back to the balance sheet, and a
report that joins carelessly lets unposted lines into a balance.

## Decision

**Posted entries are filtered in `WHERE`, never in a `LEFT JOIN` condition.** A
line whose entry is not posted survives an outer join with a null entry and
walks into the closing balance. The schema tests for this class of bug.

**The aged balance reads the ledger, not the invoices.** It buckets what is
still unmatched on reconcilable third-party accounts, by `date_maturity`, and
a test asserts that it ties to the balance sheet.

**Balances are cumulative from the beginning of the books.**
`trial_balance()` computes the opening balance of a period as the sum of
everything booked before it. There are no posted *à-nouveaux*: an opening
entry on top of a cumulative ledger would count a balance twice (see
[0031](0031-opening-and-closing-are-parameters.md)).

**`vat_return()` knows no country rule.** It sums `declaration_box` and
`box_amount` off the ledger lines and evaluates the totals a form declares as
data. Three repository-wide tests assert that no function of the schema, no
migration and no source file of the CLI, the MCP server or the core holds a
country code.

**One evaluator for totals.** A declaration form and a financial statement
derive totals the same way, in `evaluate_totals(values, formulas,
keep_zero)`, resolved by dependency rather than by print order (see
[0023](0023-declaration-boxes-are-data.md)).

## Consequences

- Every report ties back to the balance sheet by construction.
- A new country never requires a change to a report function.

## See also

- `tests/reporting.test.ts`, `tests/statements.test.ts`
- [0030 Charts and financial statements are data](0030-charts-and-financial-statements-are-data.md)
