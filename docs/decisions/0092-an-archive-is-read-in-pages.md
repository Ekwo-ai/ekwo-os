# An archive is read in pages

> Status: accepted

## Context

A copy of a company over the API was one call, `export_company()`, which
reads the manifest and every table in one statement
([0043](0043-a-company-leaves-with-its-books.md)). One statement is one
snapshot, which is what makes the archive whole: the lines agree with their
entries, the counters with the numbers they gave. It is also one request,
and a request has a clock — eight seconds for `authenticated` on a hosted
project, five minutes since `20261027073538` gave the archive functions their
own. A company of about 20 MB already came close to the first. A company of
ten years of entries, or of a few thousand pieces, meets the second: no clock
is long enough for every company, and a longer one keeps a connection of the
pool busy for as long.

Three ways out were weighed:

- **A direct connection** — a dedicated role, `pg_dump` of the company, or
  `export_company_table()` inside one `repeatable read` transaction, which is
  what `ekwo company export` does. One snapshot and no request clock; but it
  needs a connection string to the database, which a client of the API does
  not hold and should not.
- **Incremental copies** — a full copy, then only what changed. It needs to
  know what changed in every table, which `updated_at` columns do not say for
  all of them, and it still starts from one full copy of the whole company.
- **Pages** — the same archive, read as many short requests.

## Decision

**An archive can be read in pages, and is then the same archive.**
`export_company_outline(company)` answers the manifest before a row is read:
every table with the number of rows it holds for the company, no checksum.
`export_company_page(company, table, after, limit)` answers up to `limit` rows
of one table after a cursor: `lines`, the exact text of the data file for those
rows, and `after`, the cursor of the next page. A table ordered by its primary
key is paged on that key — no column of a primary key is null, so a row
comparison is the next page; the trail, whose primary key is an identity that
does not leave, is paged by position. The client appends the lines to the data
files and computes both checksums as it goes: `sha256` over the lines, and
`values_sha256` over the same lines with the canonical form of the few rows
whose form differs, which the page gives by their place.

**Each page is its own snapshot, and the archive is checked at both ends.**
The client asks the outline before the first page and after the last. A row
added or removed anywhere changes a count; every act that changes a posted
figure — a posting, a matching, a payment, a closing — writes a line on the
trail, which is a table of the archive and so a count too. Outlines that
differ are `archive_moved`, and the archive is read again. A table read with
fewer rows than its outline gave, the outlines agreeing, is
`export_incomplete`, as `export_company()` says it.

**The bytes are the ones `export_company()` writes.** The manifest is built in
one place, `company_archive_manifest()`, and the columns, decimals and order of
a table are read in one place, `company_archive_row_shape()`, which the reader
of the whole archive and the reader of a page both use. The format of the
archive does not change, and `import_company()` takes an archive read in pages
as it takes one read in one statement.

**`readCompanyArchive()` in `@ekwo-ai/core` is that client**, written once over
the `Backend` every surface brings: the MCP server and the command line over
SQL or PostgREST, a nightly copy over PostgREST.

## Consequences

- A page is short whatever the size of the company: five thousand rows by
  default, fifty thousand at most. Nothing in an archive read this way depends
  on a clock.
- The check at both ends sees what changes a count, and every act the trail
  records. A change it does not see — a draft edited in place between two
  pages — leaves an archive where that draft is either before or after the
  edit; the archive still imports, and that draft is what it was at one of the
  two moments. One statement, or one `repeatable read` transaction, remains
  the way to one snapshot, and the command line keeps it.
- A copy that meets `archive_moved` reads again. At night the books rarely
  move; a client that retries a few times and then says so is enough.
- Incremental copies are not decided here. Pages make the full copy of any
  company possible over the API; whether a copy should be smaller than the
  company is a question of storage, for later.

## See also

- [0043](0043-a-company-leaves-with-its-books.md) — the archive and its format, which pages do not change
- [0017](0017-an-append-only-audit-trail.md) — the trail, whose count says that an act happened
- [`docs/company-archive.md`](../company-archive.md) — the format, and reading in pages
- `supabase/migrations/20261029020000_an_archive_is_read_in_pages.sql`
- `tests/archive_in_pages.test.ts`
