# Machine access over the API

A script has no browser to sign in with. It gets an `api_keys` row: one
company, an explicit list of capabilities, an expiry if you want one, and a
secret stored as a sha256 that nobody can read back. This page is how that key
reaches the database through the REST API of a Supabase project, which is the
only way in for anything that cannot hold a Postgres connection — a scheduled
function, a job on a host with no `psql`, a page in a browser.

The alternatives are the two this exists to avoid. A password of a real person
makes the audit trail say a person acted. The `service_role` key bypasses every
row level security policy, so whatever holds it answers for every company of
the installation.

## What the caller sends

Two headers, on an ordinary PostgREST request.

```sh
curl "https://YOURREF.supabase.co/rest/v1/companies?select=id,name" \
  -H "apikey: <the publishable key>" \
  -H "X-Ekwo-Api-Key: <the secret of the key>"
```

- **`apikey`** is the project's publishable key, the one the dashboard shows as
  *anon* or *publishable*. It is what lets the request past the gateway, and it
  is not a credential of this schema: on its own it reaches nothing, because
  `anon` holds no privilege on any table.
- **`X-Ekwo-Api-Key`** is the secret `create_api_key()` returned, once, when
  somebody minted the key. It is the credential.

Not `Authorization`: PostgREST reads the role out of that header and fails a
request whose value it cannot parse as a JWT, before any function of this
schema runs. Two doors, two names.

The same two headers work on `/rpc/…`:

```sh
curl -X POST "https://YOURREF.supabase.co/rest/v1/rpc/export_company" \
  -H "apikey: <the publishable key>" \
  -H "X-Ekwo-Api-Key: <the secret of the key>" \
  -H "Content-Type: application/json" \
  -d '{"p_company_id": "<the company>"}'
```

## What happens on the other side

PostgREST calls one function at the start of every request's transaction, named
by `pgrst.db_pre_request` on its login role. Here that is
`public.ekwo_pre_request()`:

1. it reads `X-Ekwo-Api-Key` off `request.headers`. No header, and it returns
   having done nothing — which is every request a person makes;
2. it presents the key, which checks the hash and refuses one that is unknown,
   withdrawn or expired. A refusal here fails the whole request;
3. only then it moves the request off `anon` and onto `authenticated`, whose
   grants row level security is written against.

`auth.uid()` stays null through all of it. A key is not a session: the policies
that ask for a signed-in user still answer no, and what the caller may do is
decided by `has_capability()`, which consults the key's own list and what the
person who issued it holds today. The role is the door; the capabilities are
the rooms.

**The pre-request writes nothing**, and it cannot. PostgREST opens a GET — and
an RPC whose function is not volatile — inside a **read-only transaction**, so
anything the hook wrote would fail the request it was presented for, with a
message about an UPDATE nobody asked for. It sets two configuration values and
stops. The use of a key is therefore recorded on the requests that may write,
and `api_keys.last_used_at` is a floor rather than a ceiling: a key read from
every night and never written with will carry an old date, or none.

The work itself is unaffected. `export_company()` is volatile, so PostgREST
runs it in a read-write transaction and it writes `company_exported` on the
audit trail as it always did.

## What a key may read and write

Its own company, and what its capabilities name — as far as the person who
issued it still holds them.

- **The company it was minted on.** Since
  [decision 0062](decisions/0062-a-key-reaches-the-api.md) a key is *on* that
  company, so the rows that describe it are readable: the `companies` row, the
  members, the modules it has on, its filing periods, its matching settings and
  its audit trail. That is what the narrowest member of that company reads, and
  nothing of any other company — `api_keys.company_id` is one company and there
  is no second one to name. A key that no longer reaches any capability there
  is not on the company either, and reads none of this.
- **Everything else asks a capability.** `entries.read` for the ledger,
  `documents.write` to draft, `entries.post` to post, `company.export` to
  leave with the books. A key is never wider than the person who issued it,
  and that is checked twice: `create_api_key()` refuses a capability the
  issuer does not hold, and at every use `key_holds()` asks whether the issuer
  still holds it on that company. A key the installation issued itself —
  `created_by` null — is bounded by its list alone.
- **The reference data of the installation** — currencies, charts of accounts,
  taxes, the boxes of the declaration forms, the statement schemes — is
  readable by any caller this installation knows, which includes the holder
  of a live key that still reaches something.

## Backing a company up

The case this was built for, and the one place a key needs more than it looks.

An archive is whole or it is not written. `export_company()` refuses when the
caller may read fewer rows than a table holds, and it names the table and the
two counts — so a key carrying `company.export` alone is refused on the first
table it cannot see. A key that backs a company up carries the capabilities of
the preset a person would export under, which is `client`: the reads, plus
`documents.deposit` and `company.export`.

```sql
select * from create_api_key(
  '<the company>',
  'Nightly backup',
  (select jsonb_agg(capability) from role_capabilities where role = 'client'),
  null
);
```

The secret comes back once. What is stored is its sha256, and the audit trail
of every act the key performs records `api_key_id` beside a null `actor_id`, so
the trail says a machine acted and which one.

A backup key issued from somebody's session is that person's delegation: the
day they leave the company, or move to a preset that no longer reads what the
archive carries, the next backup is refused. Issue it from an owner who is
staying, and issue it again from their successor when that changes: the old
key is then revoked, not left to fail.

## Checking the installation is set up for it

The setting lives on the `authenticator` role and is configuration of the API,
not of the schema. The migration writes it where it is allowed to; a managed
project may refuse, and then a key in the header is simply never read.

`ekwo doctor` reports it under *api keys over the API*, and prints what to run:

```sql
alter role authenticator set pgrst.db_pre_request = 'public.ekwo_pre_request';
notify pgrst, 'reload config';
```

Both statements are run by a role that may write the settings of
`authenticator`. Nothing else is affected: a key presented on a direct
connection with `use_api_key()` works either way, which is what the command
line and the MCP server do.

## Withdrawing one

`revoke_api_key(id)`, which needs `members.manage`, and there is no
un-withdraw. `api_keys.last_used_at` says when the key was last presented, so a
key nobody uses is visible before it is a problem.

**Withdrawing a person's right withdraws it from their keys.** A key holds a
capability only while the person who issued it holds it on that company, and
that is worked out at every call — by `key_holds()`, which `has_capability()`
asks — never copied onto the key when the right changes. So:

- a capability revoked from the issuer, by `capabilities_revoked` or by a move
  to a narrower preset, is gone from their keys on the next call;
- an issuer removed from the company leaves keys that reach nothing there, not
  even the company row;
- a right given back to the issuer is given back to their keys, because
  nothing was written down when it went.

What each key really reaches is readable, for whoever may read the keys:

```sql
select name, prefix, capability, reaches
  from api_key_reach
 where company_id = '<the company>'
 order by name, capability;
```

`api_key_reach` calls the function `has_capability()` calls, so it cannot
disagree with what a request will be answered. `ekwo doctor` lists every live
key whose list goes beyond its issuer under *keys beyond their issuer*, with
the capabilities it no longer reaches: revoke it and issue a new one from
somebody who holds what it needs, or give the issuer the rights back.

**A deleted account keeps bounding its keys while its membership stays.**
`company_members` has no foreign key to `auth.users`, on purpose
([decision 0001](decisions/0001-one-installation-is-one-customer.md)), so
deleting a person from Supabase Auth leaves their membership rows — and a key
they issued is still bounded by those rows, which may hold everything it
carries. `ekwo doctor` reports such a row under *company members*. Removing it
(`remove_member()`) is what withdraws the keys; deleting the account alone
does not.

## See also

- [0006 A machine key is a narrow caller](decisions/0006-a-machine-key-is-a-narrow-caller.md)
- [0062 A machine key reaches the API](decisions/0062-a-key-reaches-the-api.md)
- [0004 A permission is a capability](decisions/0004-a-permission-is-a-capability.md)
- [`company-archive.md`](company-archive.md) — what an archive carries
