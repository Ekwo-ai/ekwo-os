# A key writes as the person who issued it

> Status: accepted

## Context

[0053](0053-the-mcp-server-acts-as-the-user.md) says the MCP server acts as the
user. Since [0062](0062-a-key-reaches-the-api.md) a machine key reaches the
API, and an assistant operated for somebody — a hosted MCP server answering
for a person who connected it — presents a key rather than a session.

A key is not a session: `auth.uid()` is null for it, by design, so the
policies that ask for a signed-in user answer no. Every write that took its
author from `auth.uid()` therefore recorded nobody. `audit_log` wrote
`api_key_id` beside a null `actor_id`; `enabled_by`, `invited_by`, `filed_by`,
`uploaded_by`, `unposted_by`, `recorded_by` and the rest stayed empty. The
trail said that a machine acted and never for whom, which is the opposite of
what 0053 promises an assistant does.

Two answers were possible: record the key as the actor and say so wherever a
key is issued, or record the person the key is a delegation from. The
amendment of [0006](0006-a-machine-key-is-a-narrow-caller.md) already made
that person part of the key: a key holds what its issuer still holds, at
every use (`key_holds()`).

## Decision

**A write through a key is recorded against the person who issued the key**
(`api_keys.created_by`). That person is who the write is for; the key is how
it arrived.

**One function says it.** `acting_user()` answers the signed-in user, or else
the issuer of the key presented in this transaction. Every place that recorded
`auth.uid()` as the author of a write calls it — `audit_record()`, the
functions that write `*_by` columns, the column defaults that did — and
`create_api_key()` drops its own copy of the same expression for it. A key the
installation issued itself, `created_by` null, is recorded against nobody, as
before; so is a direct connection of the installer.

**It attributes and never authorises.** `auth.uid()` is unchanged, and nothing
reads `acting_user()` to decide whether something may be done. What a key may
do is still `has_capability()`, through `key_holds()`: its own list, bounded by
what its issuer holds today. A key without `documents.write` creates no
document, whatever its issuer may do. A key withdrawn or expired is refused
when it is presented, and `current_api_key()`, which `acting_user()` reads,
ignores it as well, so it is recorded against nobody either.

**The key stays on the trail.** `audit_log.api_key_id` keeps naming the key, so
a row says both for whom and through what. A person who wants to know what an
assistant did on their behalf reads the rows that carry their id and a key.

**Ownership is not attribution.** `create_company()` and `import_company()`
take their owner from `auth.uid()` and keep doing so: who owns a company is a
membership, and a key does not choose it. The functions that demand a session —
`accept_invitation()`, `set_preferences()` — go on demanding one.

## Consequences

- 0053 holds for a hosted assistant connected through a key: what it writes is
  recorded as its user's, and it can do no more than its key and its user both
  allow.
- An issuer answers for the keys they issue. Withdrawing a key is how a person
  stops being the author of what it writes.
- A trail written before this release keeps its null `actor_id` on rows a key
  wrote; `api_key_id` and `api_keys.created_by` still say whose key it was.
- `tests/key_writes_as_its_issuer.test.ts` asks the database for any function
  that writes an author from `auth.uid()` and for any column default that does,
  so a second rule written tomorrow fails there.

## See also

- `supabase/migrations/20261007041207_a_key_writes_as_its_issuer.sql`
- [0006 A machine key is a narrow caller](0006-a-machine-key-is-a-narrow-caller.md)
- [0053 The MCP server acts as the user](0053-the-mcp-server-acts-as-the-user.md)
- [0062 A machine key reaches the API](0062-a-key-reaches-the-api.md)
- [`docs/machine-access.md`](../machine-access.md)
