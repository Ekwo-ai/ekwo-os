# The installer needs only Node and the customer's project

> Status: accepted

## Context

An open-core promise is judged at installation: who owns the project, what
must be installed first, where the secrets go, and how to leave.

## Decision

**Ekwo provisions no Supabase project and pays for none.** The customer
creates it; `npx ekwo init` connects to it. Creating projects under an
Ekwo-held token would make every Community installation depend on an Ekwo
account and billing relationship.

**The CLI requires Node and nothing else** — not the Supabase CLI, not Docker,
not psql. It opens a Postgres connection and applies the SQL itself.

**The migration history is Supabase's.** `ekwo migrate` writes
`supabase_migrations.schema_migrations` with the same columns, `version` being
the filename's timestamp, so `supabase db push` and `ekwo migrate` are
interchangeable in both directions.

**Each migration is applied whole, in one transaction with its history row.**
A failure leaves neither half a schema nor a lying history row. Consequently
no migration may open a transaction of its own. `statements` is recorded by a
small parser (dollar quoting, `E''` escapes, nested comments) and never
executed, so a parser bug cannot break an installation.

**Migrations move forward only.** There is no `down`; `ekwo migrate`
recommends a snapshot before applying anything. A published migration is never
edited — the CI measures that against the latest release tag — and an inexact
comment in one is corrected in documentation.

**The first administrator is created through GoTrue, not SQL.** The CLI holds
a connection, not a session: `auth.uid()` is null and row level security is
bypassed rather than satisfied. Writing `auth.users` by hand produces an
account that looks right and cannot sign in. This is the only reason the
`service_role` key is ever asked for, and `--admin-user-id` avoids it.

**Where a guard lives in a function, the CLI satisfies it rather than going
round it**, setting `request.jwt.claims` for the administrator it acts for, as
PostgREST would.

**Secrets are not written by the installer.** The database password and
`service_role` key come from a flag, the environment or a masked prompt and are
forgotten; `ekwo.json` holds only what is safe to commit. (The signed-in
session of the bookkeeping commands is a separate, documented file — see
[0055](0055-the-command-line-acts-as-a-signed-in-person.md).)

**Few runtime dependencies**: the Postgres driver and the project's own core.
Argument parsing and prompts are written in the package, because everything the
CLI is handed is a secret.

**Connection strings are asked for, not derived.** The pooler host carries a
generation prefix the region does not determine; both candidates are tried and
the one that answers is printed. The direct host may be IPv6-only and hang
rather than fail, so without a region the CLI asks for the string the dashboard
shows.

**There is no `eject`.** The data is already in the customer's database, the
schema is AGPL-3.0 in this repository, and `supabase db push` keeps working
without the CLI. The help says so.

**The demo seed is its own command** and asks before adding a fictional company
to an installation that already holds one; `init` and `migrate` never apply it.

**Four things are printed, not checked**, at the end of a successful
`ekwo init` and in the guide, with a test keeping both identical: disable self
sign-up, keep a second administrator, keep the `service_role` key off machines
that do not need it, read `DISCLAIMER.md` before filing. They are project
settings no connection string reaches, and checking them would require a
management token able to change them.

**Unattended runs refuse to choose.** With several charts or languages and
nobody to ask, `ekwo init` names the flag to pass.

## Consequences

- A customer can install, operate and leave without any Ekwo account.
- Contributors must write migrations that run inside one transaction.

## See also

- [`packages/cli/README.md`](../../packages/cli/README.md)
- [0057 Two install paths, one installation](0057-two-install-paths-one-installation.md)
