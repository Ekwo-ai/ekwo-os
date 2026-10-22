# A company is counted, never read

> Status: accepted

## Context

Whoever runs an installation for somebody else needs to know whether the books
are in use: whether contacts were created, invoices drafted or posted, a bank
statement brought in, and when the last thing was written. A host keeping an
instance alive answers support with it; an operator linked to a company by a
key decides with it whether an instance is still worth keeping.

The schema gave no way to ask. The answer was worked out table by table — with
a key that reads far more than counts, or with the `service_role` key, which
reads everything of every company — and it took an hour by hand for one
installation of three companies. Worse, it mixed what people made with what
the country pack lays down at creation: a thousand accounts, a few dozen taxes
and their postings, which are the same for every company of a country.

## Decision

**`usage_figures()` counts, and returns nothing else.** For every company the
caller is on, one row per figure: a name, a number of rows, and when the most
recent was created. No name, amount, label, document number or identifier
other than the company's own leaves the function. The list is public, in
`docs/usage-figures.md`, so that whoever is counted can read what is counted.

**What the pack lays down is not a figure.** Accounts, taxes, tax postings,
journals and declaration boxes are left out; members, invitations, contacts,
products, fiscal years, bank accounts and statements, payments, imports,
declarations, attachments, documents by type and state and entries by state
are in.

**Modules are counted without the socle naming one.** For each module enabled
on the company: `modules.<code>`, then one figure per table of its schema that
carries `company_id`. A table without it is reference data of the installation
([0051](0051-a-module-has-its-own-schema.md), rule 3), and is not counted.

**A member and a key of the company may ask, and nobody else.** It answers
`is_company_member()`, which holds for a signed-in member and for the holder of
a key of that company ([0062](0062-a-key-reaches-the-api.md)). No capability is
asked: a count is less than what any capability already reads. It is a
`security definer` function, read-only, so that it counts tables whose
policies would each ask a different capability, and runs in the read-only
transaction PostgREST opens for it.

## Consequences

- A host that keeps a key per linked company learns how each is used with one
  call per key, and stores counts rather than books.
- A company's figures change when the list does; adding a figure is a
  migration and a line of `docs/usage-figures.md`.
- The function sends nothing. An installation nobody calls with a key reports
  nothing to anybody.

## See also

- `supabase/migrations/20261022074713_a_company_is_counted_never_read.sql`
- `tests/usage_figures.test.ts`
- `docs/usage-figures.md`
- [0062](0062-a-key-reaches-the-api.md) — A machine key reaches the API, and is on its own company
