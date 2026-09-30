# A machine key is a caller narrower than a person

> Status: accepted
>
> Amended 2026-09-30 by `20260930103815`: the issuer is consulted at every
> use of a key, not only when it is issued. Until then the sentence below
> about revoking a person's capability was written and not implemented.

## Context

A script has no browser to sign in with. Handing it the `service_role` key
gives it every company and every table; creating a fake user puts a password
in a crontab and makes the audit trail say a person acted.

## Decision

**An `api_keys` row belongs to one company, carries an explicit list of
capabilities, expires when told to, and is stored as a sha256.** Nobody mints
a key stronger than themselves: every capability on it must be one the issuer
holds.

**A key is a delegation from a person, and it holds only what that person
still holds.** At use, a key holds a capability on a company when the company
is its company, the capability is on its list, *and* the person who issued it
(`api_keys.created_by`) holds that capability there now. The third condition
is computed at the moment of the call by `key_holds()`, never kept in a
column a trigger maintains: a role changes, an adjustment is revoked, an
account disappears, and a maintained copy drifts from each of them. Computing
at the call is the same answer [0040](0040-a-portfolio-is-what-the-caller-may-read.md)
gives for a portfolio. So revoking a person's capability revokes it from the
keys they issued, a person who leaves a company takes their keys' reach with
them, and giving the right back gives it back to the keys.

A key the installation issued itself — `created_by` null, no person signed
in — is bounded by its list alone. That is the same rule: the installation is
its issuer, and does not lose rights. A key issued while another key is
presented records the person behind that key, so a key cannot mint a key that
answers to nobody.

**One brick decides a person's rights.** `member_holds(member, capability)` —
revoked beats granted, granted beats the preset — is what `has_capability()`
asks for a member, what `key_holds()` asks for the issuer of a key, and what
`member_capabilities()` lists. There is no second copy of the rule for the key
path to fall out of step with, which is how the gap this amends came about.

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

**A key can stop working without being touched.** A nightly backup whose key
was issued by somebody who has since left the company, or been moved to a
narrower preset, is refused on the next run: the key keeps its list and loses
what its issuer lost. That is intended. `api_key_reach` shows, per key and per
capability, what each key really reaches — it calls `key_holds()`, the
function `has_capability()` calls, so the two cannot disagree — and
`ekwo doctor` lists the live keys that go beyond their issuer under *keys
beyond their issuer*. The remedy is a key issued again by somebody who holds
what it needs, and the old one revoked.

**A deleted account still bounds its keys while its membership remains.**
`company_members` has no foreign key to `auth.users`
([0001](0001-one-installation-is-one-customer.md)), so an account deleted
from Supabase Auth leaves its memberships, and those keep bounding the keys
the person issued. `ekwo doctor` reports such a membership under *company
members*; removing the row is what withdraws the keys.

**It costs a lookup.** `has_capability()` for a key reads the issuer's
membership as well as the key; for a member it calls `member_holds()` where
the rule used to be written inline. Both bricks are PL/pgSQL, which keeps its
plans for the session, because a SQL function holding a sub-select is not
inlined and was parsed again at every call.

## See also

- `tests/api_keys.test.ts`, `tests/api_key_over_postgrest.test.ts`,
  `tests/api_key_issuer_ceiling.test.ts`
- [`docs/machine-access.md`](../machine-access.md)
- [0062 A machine key reaches the API](0062-a-key-reaches-the-api.md)
- [0004 A permission is a capability](0004-a-permission-is-a-capability.md)
- [0040 A portfolio is what the caller may read](0040-a-portfolio-is-what-the-caller-may-read.md)
