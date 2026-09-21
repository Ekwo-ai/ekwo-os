# The command line acts as a signed-in person

> Status: accepted

## Context

`--db-url` is the owner of the database: `auth.uid()` is null and no policy
applies. That is right for installing and wrong for anything that touches a
ledger.

## Decision

**Bookkeeping commands sign in and go through PostgREST with the user's own
token**, where row level security is satisfied rather than imitated. Commands
that connect as the owner (`init`, `migrate`, `status`, `doctor`) say so when
they connect.

**The session is a file in the user's configuration directory.**
`$EKWO_CONFIG_DIR`, else `$XDG_CONFIG_HOME/ekwo`, else `~/.config/ekwo`; two
files at `0600` in a `0700` directory — `profiles.json` (what a dashboard
already shows) and `credentials.json` (the two tokens) — written by rename, so
a rotated refresh token is never half-written. A `.git` in the directory or
above is `config_dir_in_repository`. Never kept: a password, a database
password, a `service_role` key.

**Written on `fetch`, not on the platform's client library.** Every package the
CLI loads could read the password it is handed; the exchange is a few requests,
tested against a real Postgres behind a stand-in for the HTTP surfaces,
rotation and lost tokens included.

**The environment first, whole, and without a file.** `EKWO_ACCESS_TOKEN`
without the instance beside it is `missing_configuration`, never a fallback to
a profile; a command run this way reads and writes no profile.

**No company is ever picked on the user's behalf**, not even the only one;
`--company` or `ekwo use` chooses, and signing in as someone else drops it.
Company resolution is shared (`company.ts`): by id or name,
case-insensitively, an unknown one being a usage error.

**Exit codes of these refusals.** Nobody to act as (`not_signed_in`,
`unknown_profile`, `session_expired`) and a `service_role` key are 2; a wrong
password is 1 (`sign_in_failed`). Errors from PostgREST carry the database's
`code`, so code 3 works over this route unchanged.

## Consequences

- Not in the operating system's keychain (a native dependency with a view on
  the token); `ekwo logout` and the environment are the ways to keep nothing.
- File modes mean nothing on Windows; a home directory that is itself a
  repository is refused, and `EKWO_CONFIG_DIR` is the way out.
- No self-hosted route without PostgREST, no sign-in other than address and
  password, and no use of machine keys from the CLI yet.
- Two concurrent renewals may make the slower one sign in again; there is no
  lock file.

## See also

- [`packages/cli/README.md`](../../packages/cli/README.md), `tests/cli/`
- [0054 The command line output contract](0054-the-command-line-output-contract.md)
