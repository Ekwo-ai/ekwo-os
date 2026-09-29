# An append-only audit trail surrounds the ledger

> Status: accepted

## Context

The ledger is immutable once posted and corrected by reversal. What sits
around it — the chart, journals, taxes and their accounts, bank accounts,
contacts, products, financial years, memberships and roles, the pack version
— decides how every future entry is booked. An auditor asking who changed the
VAT account on a tax, and when, needs an answer.

## Decision

**`audit_log` is one table, one generic trigger function and a trigger per
audited table.** It records who (`auth.uid()`, and the machine key if one was
presented), what (table, natural key, row before and after as `jsonb`,
operation), when, and the `company_id` row level security reads. It also
records acts: a document posted or cancelled, an entry posted or reversed, a
payment booked, matched or unmatched, a year closed or reopened, a pack
upgraded, a company exported or imported.

**The ledger lines are not copied.** Entries are immutable and corrected by a
visible act; the trail records the act of posting, not its content.

**Not `pgaudit`.** It is unavailable under PGlite, where the schema is tested,
and it writes to the Postgres log, which an application cannot query and a
self-hosted operator often cannot reach.

**No client rewrites the history — and that is the whole of the claim.**
Policies do not apply to the table owner, and `service_role` bypasses row
level security, so append-only is a trigger and not a policy. No role is
granted UPDATE, DELETE or TRUNCATE on `audit_log`; a `before update or delete`
trigger refuses the first two to any role a grant ever reaches, and a
statement trigger refuses TRUNCATE, which no row trigger sees. That holds for a
member, a machine key, `service_role` and any second login an operator
creates.

It does not hold for the owner of the database, and the schema does not say it
does. The owner of a table may disable its triggers, and a superuser may run
with `session_replication_role = replica`; PostgreSQL has no mechanism by
which a table binds its own owner. A trail its operator cannot edit is a copy
that has left the database — not something a trigger can give.

**A purge is bounded and recorded by the table, not by the function.**
`purge_audit_log(date)` — reachable by `service_role` only, no default
retention — puts the cutoff in `ekwo.audit_purge` and deletes. The guard lets
a row go only while that setting names a date written `YYYY-MM-DD`, not in
the future, for a row strictly older than it, and when the role deleting is
the owner of the table. A statement trigger after the delete writes
`audit_log_purged` with the cutoff, the number of rows and the login. So the
owner who sets the setting by hand instead of calling the function meets the
same cutoff and leaves the same line; switching the guard off by name leaves
the recorder on; only switching every trigger off leaves no trace, and that is
the limit stated above.

**`company_id` carries no foreign key.** The trail outlives the rows it
describes; a cascade would delete the record of a company's own deletion.

**The installer's bulk copy is not audited row by row.** Installing a pack
copies a thousand accounts; the `company_packs` row says it once.
`is_installer()` stands the trigger down for the runner only — a person, a key
and a psql session are all audited.

**Secrets are never copied.** `api_keys.key_hash` and
`company_invitations.token_hash` are replaced by null: a hash can be attacked
offline and the trail has more readers than those tables.

## Consequences

- `ekwo doctor` checks the trail is still what it claims: guard trigger
  present, row level security on, no write policy, `purge_audit_log`
  executable only by `service_role`.
- `tests/audit.test.ts` ends on two tests that pass because of what
  PostgreSQL is: the owner switching the guard off, and every trigger off. They
  are there so that the claim above cannot grow back into "owner included".
- Tamper-*evidence* against the owner — a hash chain whose head is kept off
  the database — is not built. It would detect an edit, not prevent one, and
  only against a head that had already left.
- A function that records its own line (such as `pack_upgrade()`) is `security
  definer`, since callers cannot execute `audit_record()`.

## See also

- `tests/audit.test.ts`
- [0028 A pack upgrade is never silent](0028-a-pack-upgrade-is-never-silent.md)
