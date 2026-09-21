# Under load, the plan is the assertion, not the clock

> Status: accepted

## Context

Indexes existing proves nothing when every test books a handful of documents:
Postgres plans fifteen rows the same way with or without them. The question is
whether the schema holds with tens of thousands of invoices.

## Decision

**The build breaks on the shape of a plan, never on a time.** A time on a
shared runner under WebAssembly Postgres is noise; a test that fails on it gets
re-run until green. What is stable over deterministic data is whether a hot
path reaches `entry_lines` through an index or walks it. Times are reported
next to a budget and no `expect()` reads them.

**"Does not appear", not "appears".** The assertion is that no sequential scan
of a large table occurs in a hot path — not that a given index wins, which
depends on statistics.

**Several companies, or the test forbids the right plan.** With one company a
sequential scan is correct; the load instance holds five.

**The volume is a copy of what the engine posted.** Each company books its
pack's golden year through the real functions; that year is cloned by SQL with
new identifiers and dates shifted by whole years, column lists read from the
catalogue. The copy skips triggers, so afterwards every foreign key is
re-checked by anti-join, every entry for balance, and one more document is
posted through the engine. A test fails by name if the engine writes to a
table the generator does not know.

**Plans are read with `auto_explain`** and nested statements, because `EXPLAIN`
of a function call sees only a function scan.

**Each path is measured twice, as owner and as member.** Measuring only as the
database owner hides row level security.

**A policy asks once per statement.** A `stable` function is a promise to the
planner, not a cache: `has_capability()` with a column argument runs per row,
and being `security definer` it cannot be inlined. Policies on large tables
compare `company_id` with `(select companies_with_capability(…))`, evaluated
once; that function lists candidate companies (memberships, the key's company)
and asks `has_capability()` about each, so there is still one definition of who
may do what. As a bonus the planner can use the policy to find rows. Policies
that combine the test with another condition, reach the company through a
parent, or belong to modules stay per-row; `with check` clauses are untouched.

**A filter that no index serves is fixed with a column, not with copies.**
Where functions filter declaration lines on a date spread over two tables, the
fix is one stored, indexed column written where the tax point is written, and
one shared predicate — not a union duplicated in each function.

## Consequences

- A regression that turns an index scan into a full scan fails the build; a slow runner does not.
- Row level security costs are measured, not assumed.

## See also

- [`load.md`](../load.md), `tests/load/`
- [0004 A permission is a capability](0004-a-permission-is-a-capability.md)
