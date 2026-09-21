# The surface is closed, not merely empty

> Status: accepted

## Context

Postgres grants EXECUTE on a new function to PUBLIC, and Supabase exposes the
functions of `public` as RPC endpoints. Without further care every function of
the schema is callable without signing in. Row level security makes such a
call return an empty set, which is safe and still wrong.

## Decision

**EXECUTE is revoked from PUBLIC and from `anon`** and granted to
`authenticated` and `service_role`. `alter default privileges … revoke execute
on functions from public` does not close a function created later — PostgreSQL
merges the stored default with the built-in one — so **every migration that
adds a function ends with** `revoke execute on all functions in schema public
from public;` (from PUBLIC, never from `anon`, which holds explicit grants).

**`anon` executes only the policy helpers** — `company_role`,
`is_company_member`, `can_write_company`, `is_company_owner`,
`is_instance_admin`, `is_any_company_member`, `company_has_no_member`,
`instance_has_no_admin`, `module_enabled`, `has_capability` — and one
deliberate function, `shared_document()` (see
[0042](0042-a-document-is-shared-by-a-link.md)). Policies call the helpers on
behalf of whoever asks, and without EXECUTE an anonymous SELECT would raise
instead of returning nothing. They answer only about `auth.uid()`, which is
null for `anon`, so what they give away is the word *no*. The list is asserted
by name in `tests/hardening.test.ts` and `tests/grants.test.ts`; an addition is
a decision somebody argues for.

**A select policy follows every insert policy.** `insert … returning` is
checked against the select policies too, and PostgREST always returns the row.
An administrator creating a company would otherwise see the row created and an
error returned — "violates row-level security" on a row that was written,
which points at the wrong policy. `companies_select` and
`company_members_select` therefore admit the instance administrator.

**`instance_admins` is not readable by every signed-in user.** Self sign-up is
on by default on a Supabase project, so a signed-in stranger is ordinary.
Administrators are visible to members of a company, to administrators and to
oneself. Disabling public sign-ups is a project setting the schema cannot
reach, so `ekwo init` prints it and the installation guide states it.

## Consequences

- A function added by a future migration starts closed.
- An operator who wants anonymous access to something has to write a grant and
  a test, in the open.

## See also

- [0003 The schema grants its own rights](0003-the-schema-grants-its-own-rights.md)
- [0005 A guard answers true or false](0005-a-guard-answers-true-or-false.md)
- `tests/hardening.test.ts`, `tests/grants.test.ts`
