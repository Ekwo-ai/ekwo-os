# A company leaves with its books

> Status: accepted

## Context

Several companies in one installation is the normal case, and `pg_dump` takes
the installation or nothing. Without a way to cut one company out, "the client
owns the books" depends on the goodwill of whoever runs the installation.

## Decision

**`export_company()` writes one company out; `import_company()` takes it into
another installation as a living company.** The format is rows: JSON Lines per
table and a manifest with versions and a sha256 per file. Not `pg_dump` (it
cannot cut one company out) and not SQL inserts (a script runs with its
restorer's rights and cannot be refused row by row). Decimals are strings;
`jsonb` is carried as stored, so tools copy lines and never parse them.

**What belongs to a company is read from the catalogue.** A table is the
company's when it carries `company_id` or a foreign key chain leads to
`companies`. `company_archive_registry` classifies each such table as
`exported` or `excluded` with a reason; an unclassified table fails a test
**and stops every export at run time**, by name — an operator's own table or a
foreign module is met with a refusal, not a silently incomplete archive. A
module answers through `<schema>.archive_tables()`.

**The right is its own, `company.export`, and the client holds it.** `owner`
and `client` hold it; `accountant` and `viewer` do not. A right to leave that
only the firm can exercise is a courtesy, not a right. A firm that must
withhold it revokes it per member, and that revocation is on the company's
audit trail.

**Under row level security, and whole or not written.** Export functions are
`security invoker`; roles that bypass row level security are refused (they
already have `pg_dump`). Each table is counted twice — as the caller and by a
definer function that answers a number — and a difference is
`export_incomplete`. Reads share one snapshot (stable functions in one
statement, or a repeatable-read transaction when streamed).

**An export is recorded** (`company_exported`), as a record, not a control.

**Identifiers are kept.** They are referenced from places no foreign key knows
(attachments, the trail, module tags). A second import is
`company_already_here`; an import never merges.

**People stay; their trace travels.** Members, invitations, keys and share
links are excluded. Actor columns are not foreign keys, so they arrive
unchanged and name nobody; no correspondence table carries staff names into
the archive.

**Rows are inserted, not replayed.** Replaying would draw new numbers and
restamp the trail. `import_company()` disables user triggers of the tables it
fills, by name, inside its own transaction (foreign keys stay on, and the lock
makes other writers wait), fills forward references in a second pass, and
turns them back on.

**The archive is not trusted.** Before writing: checksums, every row's
`company_id`, no unknown table or column. After: row counts through the
company, foreign keys staying inside it, entries agreeing with lines and
balanced, matchings agreeing, counters not behind used numbers, years not
overlapping. One failure and nothing stays. `import_company()` is `security
definer`, guarded like `create_company()`, and writes `company_imported` —
where the new installation's testimony starts.

## Consequences

- Attachment bytes live in storage and are listed, not carried.
- The archive is one `jsonb` call; very large companies need a staged load.
- A disabled module with rows stops the export; a machine key cannot export;
  a company cannot yet be removed; archives of an older schema import while
  every column still exists.

## See also

- [`company-archive.md`](../company-archive.md)
- `tests/company_archive.test.ts`, `tests/company_archive_refusals.test.ts`,
  `tests/posted_archive.test.ts`
