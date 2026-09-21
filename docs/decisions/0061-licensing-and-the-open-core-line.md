# AGPL core, MIT formats, an operational paid line

> Status: accepted

## Context

An accounting core must not become somebody's closed service, while file-format
libraries are most useful when anyone can embed them.

## Decision

**AGPL-3.0 for the core; MIT for the format libraries.** The formats' value is
ubiquity — inside other software, a software house or an administration. The
core's value is that nobody can turn it into a closed service. Installing and
running it internally, modified or not, obliges the installer to nothing.

**A contributor licence agreement is mandatory**, so the project can change
its licence if it ever must.

**`ee/` lives in this repository, with its own licence.** A separate repository
would make every schema change a two-repository coordination.

**The line between free and paid is operational, not functional.** If it keeps
working when Ekwo disappears, it is free. Removing the footer attribution is
never sold: it is an attribution, not a toll. What is operated — transmission
through certified access points, deposits with an administration, credentials —
is in `ee/`; the proof it produces lives in the customer's database.

**No adapter imitating another product's API.** Nobody consumes an imitation
server; integrations read the real product. The route to national filing tools
is their official formats. A published field mapping costs a fraction of an
adapter and is more useful.

**Ekwo describes itself by what it does and the standards it follows**, not
against named products; `check:no-competitor-names` enforces it.

## Consequences

- Anyone may run and modify the core internally without obligation.
- Paid features never gate accounting functionality.

## See also

- [`LICENSE`](../../LICENSE), [`MANIFESTO.md`](../../MANIFESTO.md)
- [`mapping.md`](../mapping.md)
- [0048 Format libraries are MIT](0048-format-libraries-are-mit-one-package-per-format.md)
