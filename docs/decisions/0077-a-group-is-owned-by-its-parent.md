# A group of companies is owned by its parent, and reads its members as the caller

> Status: accepted

## Context

A group that consolidates its companies needs the books of several companies
at once. Every row of Ekwo belongs to one company, and every policy asks
whether the caller is a member of it and holds the capability there
([0051](0051-a-module-has-its-own-schema.md) for a module: `module_enabled()`
and the module's own capability). A group is the first thing that spans
companies, so it has to say whose it is, and how the books of the others are
read.

Two answers were open. A group could stand above the companies, with members
of its own and a role that reads every company it holds — or it could belong to
one company and read the others with what the caller holds in each.

## Decision

**A group belongs to the company that consolidates it — its parent.** The
parent enables the module, owns the rows (`company_id`), and decides who sees
and writes them through `consolidation.read` and `consolidation.write`, held in
the parent. The parent is always in the perimeter, at 100 %, and is never a row
of `members`.

**A member is read as the caller, under its own row level security.** The
module grants nothing on a member company and holds no role that reads across
companies. Whoever puts a company in a group must hold `entries.read` there
(`consolidation_member_unreadable`, held by a trigger for every way in), and
whoever reads a group later is held to the same: `perimeter()` says, member by
member, whether the caller can read it, and `require_readable()` refuses by
name. A consolidation never comes out short of a company because somebody
could not see it.

**A membership is a period with its terms.** `entered_on` and `left_on`
(included, null while it stays), the method (`full`, `proportional`,
`equity`) and the percentage of interest. The integration rate is derived
from them in a generated column — 100, the interest, 0 — so it cannot disagree
with the method. Two periods of one company in one group never overlap; a
change of interest closes one and opens the next, and the perimeter of a past
date stays what it was.

**Nothing is written in a member.** Eliminations and adjustments, when they
come, are rows of the module's schema, never documents or entries of a member.

## Consequences

- An accountant who consolidates a group is a member of each company in it,
  with `entries.read` at least — which is what an accountant of a group is in
  practice, and what the presets already give.
- A member the caller cannot read is visible as such, rather than hidden: the
  row stays, with `readable = false`.
- An archive of the parent carries its groups and not their members, which
  name other companies of the installation by id.
- A company kept in another installation cannot be a member. Reading books
  across installations is a question for later, and this shape does not
  prevent it.

## Alternatives considered

- **A group with members of its own and a reading role across companies.**
  Rejected: it is a second way into a company's books beside its own
  membership, and the one place a company's policies would not decide who reads
  them.
- **A `security definer` reading of the members.** Rejected for the same
  reason: whoever holds `consolidation.read` in the parent would read the
  members' books without being a member of them.
- **A typed integration rate.** Rejected: it can disagree with its method, and
  nothing would say which one is right.

## See also

- `modules/consolidation/supabase/migrations/20261020051627_consolidation.sql`
- `modules/consolidation/tests/consolidation.test.ts`
- [0051](0051-a-module-has-its-own-schema.md) — A module has its own schema and posts through a function
- [0064](0064-a-key-writes-as-its-issuer.md) — A key writes as the person who issued it
