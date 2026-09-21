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

**Append-only is a trigger, not a policy.** Policies do not apply to the table
owner, and `service_role` bypasses row level security. A `before update or
delete` trigger that raises holds for everyone. The one exception is
`purge_audit_log(date)`: reachable by `service_role` only, it takes the cutoff
it is given (no default retention) and writes its own row saying how many rows
it dropped.

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
- A function that records its own line (such as `pack_upgrade()`) is `security
  definer`, since callers cannot execute `audit_record()`.

## See also

- `tests/audit.test.ts`
- [0028 A pack upgrade is never silent](0028-a-pack-upgrade-is-never-silent.md)
