# One installation belongs to one customer

> Status: accepted

## Context

A multi-tenant accounting database carries a `tenant_id` on every table and
the permanent risk that one customer reads another's books. Ekwo OS is
installed by each customer on their own Supabase project, so the question is
what an installation knows about itself and who administers it.

## Decision

**`instance` is a single row.** Primary key `1` plus a check constraint, so a
second row is impossible rather than unusual. It holds a locally generated
`instance_id`, the organisation's name, its country, the edition, the schema
version and the install date. The instance *is* the tenant: there is no
`tenant_id` anywhere in the schema. What remains inside an instance is several
companies and several people with different rights — the normal case is a
firm with its clients — which is `company_id` and row level security.

**Registering with Ekwo is opt-in and never a condition of use.**
`contact_email` and `registered_at` are empty on a fresh install; only
`register_instance()` writes them, nothing in the repository reads them, and
`unregister_instance()` clears them. `instance_id` is not a licence key: no
code path checks it and no feature depends on it.

**`edition` records who operates the installation and gates nothing.**
`community` when the customer runs it, `cloud` when Ekwo does. Gating an
accounting feature on a column would make the open core a demo.

**The instance-level role has its own table.** `instance_admins` is keyed on
the user alone; a company role is keyed by (company, user). Making
`company_members.company_id` nullable to hold an instance role would break its
key. `member_role` still carries `instance_admin` so an interface renders one
list of roles, and `company_members` refuses it by check constraint.

**An instance administrator creates companies and invites members, and that is
all.** They cannot read a ledger they were not invited to; a test asserts it.

**The first user to ask takes the instance.** `claim_instance_admin()` is open
while there is no administrator and closed afterwards — the same bootstrap the
first member of a company gets — so no installer has to hold a password.

**Users live in the customer's own Supabase Auth.** `company_members.user_id`
and `instance_admins.user_id` hold an `auth.users.id` of the customer's
project, matched against `auth.uid()` in every policy. Ekwo holds no account
and no directory.

**The foreign key onto `auth.users` is on `instance_admins` and deliberately
not on `company_members`.** An administrator is necessarily a signed-in user.
A company membership may exist before its person has an account (an
invitation), which a foreign key would forbid. A deleted auth user therefore
leaves an orphan membership, which grants nothing and which `ekwo doctor`
reports without deleting it (see [0052](0052-the-installer-needs-only-node-and-a-customer-project.md)).
Outside Supabase the schema needs an `auth.users` table; the test shim shows
the two columns that are enough.

**Reading the instance row is for people on this installation** — a member of
at least one company, or an administrator. On a shared project, "anyone with a
valid token" would tell a stranger which organisation runs there.

## Consequences

- Cross-customer leakage is structurally impossible, and every policy only has
  to reason about companies and capabilities.
- Nothing about an installation depends on a relationship with Ekwo.
- A member of a company can read the instance name and the user ids of its
  administrators; nothing of another company.

## See also

- `tests/instance.test.ts`, `tests/helpers/supabase-shim.sql`
- [0002 The surface is closed, not merely empty](0002-the-surface-is-closed-not-merely-empty.md)
- [0004 A permission is a capability](0004-a-permission-is-a-capability.md)
