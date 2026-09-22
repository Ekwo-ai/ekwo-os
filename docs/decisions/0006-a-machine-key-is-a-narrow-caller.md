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

**A key is not a session**, and that part holds: `auth.uid()` is null for one,
so a policy that asks for a signed-in user answers no, and what a key may do is
`has_capability()` and nothing else.

**The rest was the open question, and it has been answered.**
[0062](0062-a-key-reaches-the-api.md) makes a key reach the API through a
header, and makes it *on* the company it was minted for. So these limits, which
this record listed as known, are lifted:

- ~~functions that read the company row as the caller (rounding by company,
  per-company filing calendars) do not work for a key~~;
- ~~a key has no portfolio and cannot export a company~~ — its portfolio is
  that one company, and it exports it with the capabilities to read what the
  archive carries;
- ~~`post_entry()` run by a key finds no financial year~~; it reads
  `fiscal_years` through the same capability a member does.

What remains true of "a client holding a connection" is that it is still a way
in, not the only one: `use_api_key()` on a direct connection is what the MCP
server and the command line use, unchanged.

## See also

- `tests/api_keys.test.ts`, `tests/api_key_over_postgrest.test.ts`
- [0062 A machine key reaches the API](0062-a-key-reaches-the-api.md)
- [0004 A permission is a capability](0004-a-permission-is-a-capability.md)
- [0040 A portfolio is what the caller may read](0040-a-portfolio-is-what-the-caller-may-read.md)
