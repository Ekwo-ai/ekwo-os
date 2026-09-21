# A machine key is a caller narrower than a person

> Status: accepted

## Context

A script has no browser to sign in with. Handing it the `service_role` key
gives it every company and every table; creating a fake user puts a password
in a crontab and makes the audit trail say a person acted.

## Decision

**An `api_keys` row belongs to one company, carries an explicit list of
capabilities, expires when told to, and is stored as a sha256.** Nobody mints
a key stronger than themselves: every capability on it must be one the issuer
holds, which is also why revoking a person's capability revokes it from the
keys they issued.

**A key authenticates per transaction.** The holder calls
`use_api_key(secret)` at the start of a transaction; it puts the key's
fingerprint in `ekwo.api_key` transaction-locally and `has_capability()`
answers for it. Exchanging a key for a GoTrue session would need a fake user
per key or a token-minting service — a second secret to hold. Forging the
setting buys nothing: it holds a hash readable only by somebody who already
holds `members.manage` and could issue a key.

**A key is not a session.** `auth.uid()` stays null, so policies that ask for
a signed-in user rather than a capability — reference tables, the company row
— stay closed to it. Because PostgREST runs each request in its own
transaction, a key is for a client holding a connection (the self-hosted
route of the MCP server).

**A key is never the installer.** See
[0005](0005-a-guard-answers-true-or-false.md): `is_installer()` is false
whenever `ekwo.api_key` is set.

## Consequences

Known limits of a caller that cannot read `companies` or `fiscal_years`:

- functions that read the company row as the caller (rounding by company,
  per-company filing calendars) do not work for a key;
- a key has no portfolio and cannot export a company;
- `post_entry()` run by a key finds no financial year; the posted-entry guard
  accepts a null year and refuses only a wrong one.

Deciding what of `companies` a key may read is an open question, recorded
rather than patched per function.

## See also

- `tests/api_keys.test.ts`
- [0004 A permission is a capability](0004-a-permission-is-a-capability.md)
- [0040 A portfolio is what the caller may read](0040-a-portfolio-is-what-the-caller-may-read.md)
