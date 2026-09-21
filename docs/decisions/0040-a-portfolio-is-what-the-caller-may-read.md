# A portfolio is what the caller may read

> Status: accepted

## Context

A firm keeping many companies in one installation asks one question of all of
them: what falls due in the next fortnight, and what moved after it was
filed.

## Decision

**No firm object, no client list, no `tenant_id`.** The portfolio is the set
of companies on which the caller holds `filings.read`, at the moment of the
call. `portfolio_upcoming_filings(from, to)` and
`portfolio_filings_touched_since(from, to)` answer it. The same sentence
serves the accountant of forty companies, the person running one, and a group
keeping three.

**`security invoker`, with one filter in the open.** Row level security
settles which declarations are read, not which companies are walked:
`companies` admits any member and the instance administrator. The list is
filtered on `has_capability(id, 'filings.read')`, so a company whose
declarations the caller may not see is absent rather than shown as "nothing
started". The instance administrator therefore has an empty portfolio unless
also a member.

**Silence is not an output.** Every company of the portfolio appears in every
answer at least once, with a `reason` from a closed vocabulary
(`no_deadline_rule`, `nothing_due`, `no_form`); on the second reading, `filed`
says how many declarations were looked at.

**The window is on the due date**, not the period start: the function asks the
per-company calendar for enough past periods to cover the longest extension,
and keeps rows due in the window. A period with no date is kept while the
month after it overlaps the window.

**Built on the per-company functions**, in a lateral join, never beside them.

## Consequences

- The per-company function is inlined by the planner; the heavy call
  (`filing_drift()`) runs only for disturbed declarations.
- Known limits: a machine key and `service_role` have no portfolio (neither
  reads `companies` as a member); a form filed in another country than the
  company's may find no deadline; periods follow the calendar year.

## See also

- `tests/filing_portfolio.test.ts`
- [0038 A deadline is a rule of the country](0038-a-deadline-is-a-rule-of-the-country.md)
- [`firms.md`](../firms.md)
