# A company is archived before it leaves

> Status: accepted

## Context

Nothing in the schema said how a company ends. `companies` had no state but
"here", and the policy `companies_delete` let an owner run
`delete from companies`. Thirty-nine foreign keys cascade from that table, so
one statement erased the whole books — entries, documents, the bank, the
declarations and their proofs — with no confirmation and no export first.

Two different endings exist in practice. A company that stopped trading keeps
its books for the period its country's law sets: nothing more is posted, and
everything stays readable and exportable. A company that should never have
existed — a test, a mistake, a duplicate — goes entirely. A client of the
core (a screen, the command line, an agent over MCP) needs both, judged once,
in the database.

## Decision

**A company is archived by its owner, and restored by its owner.**
`companies.archived_at` is the state: null while the books are kept, a moment
once they are closed. `archive_company()` and `unarchive_company()` set and
clear it; both are idempotent, answer the row and write `company_archived` or
`company_unarchived` on the trail. The column is written by nobody else: a
trigger refuses a hand-written change (`company_archive_not_a_column`).

**An archived company is read-only for the ledger.** The three capability
guards that already judge every path to a posted entry, a booked document and
a closed or re-opened year (migration `20260913083216_capabilities`) ask
one question more and refuse with `company_archived`. Posting a payment or an
entry of a module goes through the same transition and meets the same
refusal. Reading, `export_company()`, the members and the profile stay as
they were.

**Deleting is a function, signed with the name of the company.**
`delete_company(company, confirm_name)` is the act of the owner. It refuses
a name that is not the company's exactly (`company_name_mismatch`), a company
another member still reaches (`company_has_other_members`) and a company a
live machine key is scoped to (`company_has_live_keys`). Then it deletes the
row and lets the foreign keys do the rest, with the user triggers of the
company's tables off for that transaction, as `import_company()` has them.

**The function is the only way out.** The policy `companies_delete` is
dropped and the `delete` privilege on `companies` is taken back from
`authenticated` and `service_role`.

**The trail outlives the company.** `audit_log.company_id` is no foreign
key: the rows the trail holds about a deleted company stay, and the last one
is `company_deleted`, with the name and the country.

## Consequences

- Archiving is not a prerequisite of deleting: an owner may delete a live
  company alone, once its name is typed and nobody else is in it.
- Archiving is the owner's decision, not a capability an accountant may be
  granted, for the reason decision 0043 gives the right to leave.
- A client offers the export before the deletion; the core does not demand
  one, because an archive taken elsewhere cannot be proven to it.

## See also

- [0043](0043-a-company-leaves-with-its-books.md) — a company leaves with its books
- `supabase/migrations/20261020121427_a_company_is_archived_before_it_leaves.sql`
- `tests/company_lifecycle.test.ts`
