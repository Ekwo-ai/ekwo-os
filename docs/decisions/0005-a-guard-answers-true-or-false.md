# A guard answers true or false, and reads as the schema

> Status: accepted

## Context

A permission check written `if not can_write_company(c) then raise` does
nothing when the helper answers NULL: `not NULL` is NULL and `if` does not
branch on it. In a policy NULL is harmless (`USING (NULL)` admits nothing); in
a `security definer` function it is an open door. Helpers built on
`company_role()` — NULL for a non-member — or on
`current_setting('…', true)` — NULL when a setting was never set — have this
shape.

## Decision

**Every boolean helper answers `true` or `false`, never NULL.**
`has_capability()`, `is_company_owner()`, `can_write_company()` and
`is_installer()` are written so. `tests/hardening.test.ts` calls every boolean
helper as a stranger, and `tests/fresh_session.test.ts` loads a database into
a second instance and asks every argument-less boolean function from a
session where nothing was ever set: a new helper that can answer NULL fails
the build. A test harness that prepares its session cannot test the session
nobody prepared, which is why that second instance exists.

**Guards are written defensively as well** — `is not true` rather than
`not` — so they hold whatever a helper answers.

**The installation itself is named, not inferred.** Guards once exempted "no
session" to let migrations and seeds run, which also exempted a machine key
and `service_role` (both have no `auth.uid()`). `is_installer()` is true only
when the runner set `ekwo.installing` on its own connection, and false when
there is a session or a key. A PostgREST caller cannot set a GUC, and a key
has one set for it, so neither can be the installer.

**A `security definer` function checks its caller on its first line**, and is
included in the sweep of `tests/client_preset.test.ts`. A definer function
that skips the check is a way to act in somebody else's company.

**A guard reads as the schema, not as the caller.** A guard that asks "is the
company still there?" under the caller's row level security is answered *no
row* by whoever cannot read `companies` — a machine key — and "no row" must
never be the answer that lets an act through. Guards on posted rows are
therefore `security definer`.

**A flag in a session setting is not a privilege.** A custom GUC is writable by
any session that can call `set_config`, so it cannot say "this function is
running" for a function that runs as its caller. Where the schema needs to let
exactly one act through, it uses a row written by a definer function in the
same transaction (see [0016](0016-a-correction-is-one-gesture.md)), or judges
the facts the act leaves behind (see
[0014](0014-a-posted-entry-is-immutable.md)).

**`service_role` bypasses row level security by its platform's design.** It
does not bypass a function that raises, which is why the rules of an
installation live in functions.

## Consequences

- Every helper and guard added later is covered by the sweeps without being listed.
- A definer function without a caller check fails review and the client-preset sweep.

## See also

- `tests/hardening.test.ts`, `tests/fresh_session.test.ts`,
  `tests/client_preset.test.ts`
- [0004 A permission is a capability](0004-a-permission-is-a-capability.md)
- [0006 A machine key is a narrow caller](0006-a-machine-key-is-a-narrow-caller.md)
