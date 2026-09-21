# A pack upgrade is never silent

> Status: accepted

## Context

A company copies its pack at install time and books on those accounts for
years. A later pack version must reach it without overwriting what an
operator may have changed on purpose — an account renamed deliberately looks
exactly like one the pack renamed.

## Decision

**The difference is computed by natural key and falls under three rules:** an
addition is copied in; a validity that closes is applied; everything else is
listed and left where it is unless explicitly accepted. A row the company holds
and the pack does not is never removed.

**A new rate is a new tax plus a `valid_to` on the old one**, never an edit —
which is what makes the second rule sufficient.

**The recorded version moves only when nothing is left waiting.** A company
with an undecided difference has not finished upgrading; moving the number
would hide the difference at the next run. A patch release with an empty
difference does move the version.

**The rules live in the schema** — `pack_upgrade_diff()` and `pack_upgrade()`
— so an application, a module or an assistant gets the same answer as the CLI.
`ekwo pack status` is the read-only half. `pack_upgrade()` is `security
definer`, checks `company.write` first, and records itself in the audit trail.

**A used account does not move between statements.** Because codes and types
are frozen by use (see
[0009](0009-accounts-have-types-and-are-resolved-by-role.md)),
`pack_upgrade(…, apply => true)` refuses by name rather than move a booked
account to another line of a filed statement.

**Adding anything is a version.** A pack that grows without bumping its version
is a pack nobody can upgrade to; adding a tax is a minor version.

## Consequences

- `tests/pack_upgrade.test.ts` installs a company from the first published
  seeds, kept as fixtures, loads the current packs, and checks what an upgrade
  does — the first upgrade is the risk nobody can rehearse twice.
- `tests/e2e/lifecycle.test.ts` upgrades through `ekwo pack upgrade` before
  playing a year.

## See also

- `tests/pack_upgrade.test.ts`, `tests/fixtures/seeds-before-packs/`
- [0025 A country is a pack of data](0025-a-country-is-a-pack-of-data.md)
