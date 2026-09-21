# The schema grants its own rights

> Status: accepted

## Context

A Supabase project carries default privileges on `public` — `grant all` on
tables, sequences and functions to `anon`, `authenticated` and
`service_role`. A schema that relies on them borrows its security from the
project. That gives `anon`, the role behind the publishable key any visitor
holds, INSERT, UPDATE and DELETE on every ledger table, with row level
security as the only layer. It is also an unwritten dependency: the defaults
live in `pg_default_acl`, keyed by schema, so dropping and recreating `public`
leaves an installation that migrates cleanly, looks healthy, and answers
`permission denied for table companies` to the first PostgREST read.

## Decision

**Every table, view and function is granted by name, in the migration that
creates it**, beside the compulsory `revoke execute … from public`. No
wildcard grant (`grant all on all tables`) and no `alter default privileges`
as the mechanism: both are how an object added later becomes writable by a
role nobody thought about. Ekwo's own default privilege granting EXECUTE on
future functions to `authenticated` is revoked.

**A grant and a policy are two halves of one sentence.** `authenticated` may
attempt exactly the verbs the policies of that table are prepared to judge: a
table with a policy `for all` gets the four verbs; one with a select policy
only — reference tables a pack installs, tables written only by a
`security definer` function, `audit_log` — gets SELECT. `anon` holds nothing
on any table, view or sequence. `service_role` gets what a person gets and no
more: it bypasses row level security, so its grants are its only limit.

**DELETE is granted where deleting is bookkeeping.** Deleting a draft entry,
document or payment is ordinary; deleting a posted one is refused by the
guards of the posted state. On `audit_log`, INSERT, UPDATE and DELETE are
withheld as a statement of intent beside the trigger that refuses them.

**A grant decides which verbs may be attempted; a policy decides on which rows
they succeed.** Which companies a role sees stays row level security.

## Consequences

- The `grants` section of `packages/cli/assets/expected-objects.json` is
  generated from a freshly migrated database and committed; the CI
  regenerates it and refuses a diff, so a migration that forgets its grants is
  caught before merge.
- `tests/grants.test.ts` asserts the doctrine (`anon` reaches no table, a
  grant says what the policies say, a trigger function is callable by nobody)
  and replays a pack's golden year as `authenticated` on a database where the
  roles start with nothing; removing one grant stops the year.
- The test harness supplies no default privileges, so every test is also a
  test of the grants.
- `ekwo doctor` checks a live database: a missing grant or an extra grant to
  `anon` is a problem, an extra grant to `authenticated` or a surviving
  default privilege is a warning.
- A function that must write where its caller cannot (for example to the
  audit trail) is `security definer` and checks its caller on its first line.

## See also

- [0002 The surface is closed, not merely empty](0002-the-surface-is-closed-not-merely-empty.md)
- [0058 `ekwo doctor` compares against a generated inventory](0058-doctor-compares-against-a-generated-inventory.md)
- `scripts/generate-expected-objects.mjs`, `tests/grants.test.ts`
