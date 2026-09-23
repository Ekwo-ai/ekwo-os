# A machine key reaches the API, and is on its own company

> Status: accepted

## Context

[0006](0006-a-machine-key-is-a-narrow-caller.md) minted the key and wrote down
what it could not do. A key is presented with `use_api_key()`, which sets
`ekwo.api_key` transaction-locally, and PostgREST runs every request in its own
transaction — so a key could never be presented for the work a REST call does.
That left the key for "a client holding a connection", which is the MCP server
self-hosted and the command line.

Everything operated for somebody else is the other shape: a scheduled backup, a
report on a cron, a function on a host with no psql. Those had two ways in and
both are worse than the key the schema already mints — a password of a real
person, which makes the audit trail say a person acted, or the `service_role`
key, which bypasses every policy and answers for every company of the
installation.

The same decision left a question open, in as many words: "Deciding what of
`companies` a key may read is an open question, recorded rather than patched
per function."

## Decision

**A key travels in `X-Ekwo-Api-Key`, and PostgREST reads it.**
`ekwo_pre_request()` is set as `pgrst.db_pre_request` on the `authenticator`
role, so it runs at the start of every request's transaction, which is exactly
where `use_api_key()` was missing. No header, no effect: a request that carries
none is the request it was before. The name is ours and not `Authorization`,
which PostgREST reads the role out of and fails on before any function of ours
runs.

**Presenting a key moves the request off `anon`.** `anon` holds no privilege on
any table ([0003](0003-the-schema-grants-its-own-rights.md)), so the grant
refuses before row level security gets to decide, and a key that cannot reach a
table cannot be narrowed by a policy either. The pre-request therefore does
`set_config('role', 'authenticated', true)` — on the line *after* the key has
been proven, never before. Three things make that sound:

- it is not a definer function, because PostgreSQL refuses `set role` inside
  one, so the privilege check is the ordinary one: the session user is
  `authenticator`, which is a member of `authenticated`. A session that is a
  member of neither is refused by the server, not by us;
- **it writes nothing.** PostgREST opens a GET, and an RPC whose function is
  not volatile, inside a read-only transaction, so a hook that wrote would fail
  the request it was presented for. `use_api_key()` records the use when the
  transaction may write and skips it when it may not, which makes
  `api_keys.last_used_at` a floor and never a ceiling. This was found against a
  real project and could not have been found anywhere else: a test opens the
  transaction it asks for, and none of ours had asked for a read-only one;
- `present_api_key()` raises on a key that is unknown, withdrawn or expired,
  and a raise in a pre-request fails the whole request;
- `authenticated` is not a person. `auth.uid()` stays null, so every policy
  that asks for a signed-in user still answers no, and what the caller may do
  is `has_capability()`, which has answered for a key since the keys landed.
  The role is the door; the capabilities are the rooms.

**A key of a company is on that company.** `is_company_member()` answers true
for the company the presented key belongs to, and every policy that asks it
follows without being rewritten — `companies`, `company_members`,
`company_modules`, `company_filing_periods`, `matching_settings`, `audit_log`,
and `module_enabled()` for a module's tables. This is the open question of 0006
answered: a key reads the rows that *describe* the company it was minted for,
which is the company it can already read the ledger of. It reads nothing of any
other, because `api_keys.company_id` is one company and there is no second one
to name.

Stated so it can be objected to: whatever its capabilities, a key reads its
company's row, its members, its modules, its filing periods, its matching
settings and its audit trail. That is what the narrowest member of that company
reads. Everything with a capability keeps asking for it.

**Reference data answers a caller this installation knows.** Eighteen tables of
the socle and two of the assets module asked `auth.uid() is not null`, which
reads "somebody signed in" and was right while a person was the only caller.
They now ask `is_known_caller()` — a signed-in user, or the holder of a live
key. They hold no customer data: a chart of accounts and a currency are the
same rows on every installation. A caller that cannot read `modules` cannot be
told which tables an archive carries, which is how an export refused a key that
held `company.export` over a list of module codes.

**`anon` gains five functions, and no table.** `ekwo_pre_request()` and
`present_api_key()` are the door, and both answer `void` — `use_api_key()` is
not granted and must not be, because it returns the row with `key_hash` in it.
`api_key_company()` and `is_known_caller()` are policy helpers of the same kind
as the eight of 0002: without a key presented they answer the same nothing
`auth.uid()` gives. `installed_schema_version()` is granted and answers `anon`
with zero rows, so the screen that checks a pasted key can call it and a
scanner learns nothing.

**The setting is configuration, not schema.** The migration writes
`pgrst.db_pre_request` where it is allowed to and says so when it is not; a
database with no `authenticator` role has no PostgREST in front of it and skips
it. `ekwo doctor` reports the state and prints the two statements, so a key
that is silently never read is a thing somebody is told about rather than
discovers.

## What a reviewer should look for

A guard written one way holds for a key and the same guard written the other
way does not, and the two look alike:

```sql
if not is_installer() and not has_capability(p_company_id, 'company.write') then  -- holds
if auth.uid() is not null and not has_capability(p_company_id, 'company.write') then  -- does not
```

The second reads "check the caller, unless there is nobody to check", and it
was true while a null `auth.uid()` meant the installer on a direct connection.
A key presented over the API is `authenticated` with a null `auth.uid()`, so
that condition is false, the raise never happens, and whoever holds any key of
the company walks past it. `is_installer()` is false whenever `ekwo.api_key` is
set — *a key is never the installer*, from
[0005](0005-a-guard-answers-true-or-false.md) and
[0006](0006-a-machine-key-is-a-narrow-caller.md) — so the first asks the
question of a key too.

`20260913102115` moved the guards to `is_installer()` for this reason, one
release before a key could reach the API. **One was written afterwards and
copied the older phrasing from its neighbours**: `pack_upgrade()`, which is
definer, is executable by `authenticated`, asks for `company.write`, and with
`p_apply` moves a company onto another version of its country pack — the chart
of accounts, the taxes and where each one posts, the boxes of the declaration
form. A key holding nothing but `entries.read` was answered. `20260923140000`
closes it.

Every guard was then swept, against the bodies the database holds rather than
the migrations that wrote them: a function is republished, and only its last
definition runs. Seven functions test whether `auth.uid()` is null and six were
right — two raise when it is null, one demands a user *before* allowing, and
three ask the question in the direction that makes a key a caller rather than
an absence. `tests/guards_a_key_meets.test.ts` holds that list against the
database, so a guard written the skipping way tomorrow fails there instead of
being found a year later.

## Consequences

- The three limits 0006 listed are lifted for a key that reaches the API: it
  reads `companies`, so rounding by company and the per-company filing calendar
  work, it has a portfolio of one company, and it can export.
- An archive is whole or it is not written, so a key that exports needs the
  capabilities to *read* what the archive carries, not only `company.export`.
  The preset a person exports under is `client`, and a key for a backup carries
  what it carries. The refusal names the table and the two counts.
- A person signed in who also presents a key holds both: `has_capability()`
  prefers the member's answer and falls back to the key's. A bearer credential
  is usable by whoever bears it, which is what makes it one.
- The audit trail already recorded `api_key_id` beside a null `actor_id`. It
  now records it for work done over the API too, which is where most of it will
  happen.

## See also

- `tests/api_key_over_postgrest.test.ts`, `tests/hardening.test.ts`,
  `tests/grants.test.ts`
- [0002 The surface is closed, not merely empty](0002-the-surface-is-closed-not-merely-empty.md)
- [0006 A machine key is a narrow caller](0006-a-machine-key-is-a-narrow-caller.md)
- [0043 A company leaves with its books](0043-a-company-leaves-with-its-books.md)
