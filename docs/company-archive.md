# The archive of one company

A firm keeps the books of N companies in one installation, and each of them
belongs to somebody. `export_company()` writes one company out, whole, in a
format that needs nothing of Ekwo to be read; `import_company()` takes it into
another installation, where it is a living company again — same identifiers,
same numbers, same locks, same trail.

This page is the format, and what the two ends check. The reasons are in
[`decisions.md`](decisions.md), under 18 September 2026.

## The shape

```
archive/
├── manifest.json                    what this is, what it needs, what it holds
└── data/
    ├── public.companies.jsonl       one file per table, named <schema>.<table>
    ├── public.accounts.jsonl
    ├── …
    └── budgets.lines.jsonl          a module's tables beside the socle's
```

A directory, not a container: `tar` or `zip` it to move it. `ekwo company
export` writes it; `export_company(company)` answers the same thing as one JSON
document, `{"manifest": {…}, "tables": {"public.accounts": [ … ], …}}`, which is
what `import_company()` takes.

### A data file

[JSON Lines](https://jsonlines.org): one row per line, one JSON object per row,
UTF-8, a line feed after every row including the last. An empty table is an
empty file.

- **Keys are the column names** of [`schema.md`](schema.md), every column of
  the table, generated ones included — `entries.is_balanced`,
  `entry_lines.balance`, `documents.amount_residual` are there for a reader and
  ignored by an import, which lets the database compute them again.
- **A decimal is a string**: `"debit": "1210.00"`, `"sale_price": "12.345678"`.
  `1210.00` is a valid JSON number and most parsers hand it back as a float; an
  archive of a ledger must not depend on which. Integers and booleans are JSON
  numbers and booleans.
- **A date is `YYYY-MM-DD`; a timestamp is ISO 8601 in UTC**, whatever the time
  zone of the session that exported.
- **An array column is a JSON array, a `jsonb` column is its value**, as
  stored. That value may hold decimals as JSON numbers — it is the company's
  own data, a bank's raw line for one — so *a tool that rewrites an archive
  must not parse and print the rows*: `1.50` would come back `1.5` and the
  checksum of the file with it. The CLI copies lines; it never parses them.
- **Rows are in primary key order**, so two exports of the same books are the
  same bytes.

### `manifest.json`

```json
{
  "format": "ekwo.company-archive",
  "format_version": 1,
  "exported_at": "2026-09-18T11:02:44.120+00:00",
  "exported_by": "8a0c…",
  "socle_version": "0.3.0",
  "origin_instance": "5f1e…",
  "company": { "id": "…", "name": "…", "country": "…", "fiscal_country": "…", "currency_code": "…" },
  "packs":   [ { "country": "…", "version": "1.2.0", "chart_code": "…" } ],
  "modules": [ { "code": "budgets", "version": "1.0.0" } ],
  "tables":  [ { "name": "public.accounts", "file": "data/public.accounts.jsonl", "rows": 355, "sha256": "…" } ],
  "excluded": [ { "name": "public.api_keys", "reason": "A credential of the installation it was issued in. …" } ],
  "files": { "transported": false,
             "list": [ { "attachment_id": "…", "storage_path": "…", "file_name": "…",
                         "mime_type": "…", "byte_size": 48213, "checksum": "…" } ] }
}
```

| Field | What it says |
|---|---|
| `format`, `format_version` | What this is. A reader that does not know the version refuses. |
| `socle_version`, `packs`, `modules` | What an installation needs to take the company in: a socle at least that recent, each pack at least at the version the company copied, each module the company had on. |
| `origin_instance`, `exported_at`, `exported_by` | Where it came from, when, and the member who took it. Written on the audit trail of the company on both sides. |
| `tables` | Every table carried, in the order an import fills them, with its row count and **the sha256 of the data file, byte for byte**. `shasum -a 256 data/*.jsonl` checks an archive without Ekwo. |
| `excluded` | Every table of a company that stays behind, with the reason. |
| `files` | The files the attachments point at. **They are not in the archive** — see below. |

## What travels

Everything the database holds about the company:

| | Tables |
|---|---|
| The company and its settings | `companies`, `company_packs`, `company_modules`, `company_filing_periods`, `matching_settings` |
| The chart and what books on it | `fiscal_years`, `accounts`, `journals`, `taxes`, `tax_postings`, `analytic_axes`, `analytic_values`, `products` |
| Third parties | `contacts`, `contact_patterns` |
| The ledger | `entries`, `entry_lines`, `entry_line_analytics`, and the counters that number it: `journal_sequences`, `matching_sequences` |
| Documents and money | `documents`, `document_lines`, `payments`, `reconciliations` |
| The bank | `bank_accounts`, `bank_statements`, `bank_transactions`, and which lines each statement lists in `bank_statement_lines` |
| Declarations | `tax_filings`, the figures each was frozen with in `tax_filing_boxes`, and the proof each one went in `tax_filing_deposits` |
| Pieces | `attachments` — the rows |
| The trail | `audit_log` of the company |
| Modules | `assets.assets`, `assets.depreciation_lines`, `assets.disposals`, `budgets.budgets`, `budgets.lines` |

## What does not, and why

| Table | Why it stays |
|---|---|
| `company_members` | Who may read a company is decided where it lives. The users of one installation do not exist in another. |
| `company_invitations` | A pending invitation is a token of this installation and the address of a person who has not agreed to be anywhere else. |
| `api_keys` | A credential of the installation it was issued in. A key that worked in two places would be a secret nobody can withdraw. |
| `document_shares` | A shared link is a secret and points at this installation. It stays valid there and means nothing elsewhere. |
| `user_preferences` | Belongs to a person, not to a company. |

**The people stay; their trace travels.** `created_by`, `uploaded_by`,
`filed_by`, `sent_by`, `enabled_by` and the `actor_id` of the audit trail hold
the identifier of a user of the first installation. None of them is a foreign
key. They arrive unchanged: they say that *somebody* did it and let two acts of
the same person be recognised as such, and they name nobody in the new
installation. The archive carries no name and no address for them — the firm's
staff are not the client's data.

**The bytes of the attachments are not carried.** They live in a storage
bucket, not in the database, and an export that runs under row level security
inside Postgres cannot read them. `manifest.files.list` says which files to
move — path, size, checksum as recorded — and the rows of `attachments` arrive
pointing at the same paths. Until the files are copied under those paths, a
piece opens to a missing file. This is the one thing a person still has to do
by hand, and both commands say so when they end.

**Reference data is not carried either**: currencies, territories, the packs'
templates, the modules. The manifest says what is needed and the import refuses
by name when it is not there.

## Leaving

```sh
ekwo company export "Atelier Lune" --out ./atelier-lune
```

or, from an application, `select export_company(<company>)` as a signed-in
member. Three conditions, all checked by the database:

1. **`company.export`**, held by the `owner` and `client` presets.
2. **Row level security applies to the caller.** `service_role` and the owner
   of the database are refused: for them every company is readable at once,
   and whoever holds such a role has `pg_dump`. The CLI's connection is the
   database owner's, so it steps down to `authenticated` inside one
   transaction and carries the claim of the member it acts for (`--as-user`,
   an owner by default).
3. **The archive is whole.** Each table is counted as the caller and counted
   again by a definer function that answers a number and nothing else; a
   difference is `export_incomplete`, by table. A member whose `bank.read` was
   revoked does not leave with books that have no bank in them. A module turned
   off with rows in it stops the export too, until it is turned back on.

**One snapshot.** `export_company()` reads the manifest and every table in one
statement. `export_company_manifest()` and `export_company_table()` are stable
and read the snapshot of whatever calls them: called one after the other — to
stream a large company, as the CLI does — they belong in one `repeatable read`
transaction, or the tables may disagree with each other and with the manifest.

An export is recorded: `export_company()` and the CLI write `company_exported`
on the audit trail of the company, with who did it. It is a record and not a
control — the export reads nothing its caller could not read table by table.

`company_archive_unclassified()` has to be empty. A table that belongs to a
company and is neither exported nor excluded stops every export, by name — see
*Adding a table* below.

## Arriving

```sh
ekwo company import ./atelier-lune --owner <user id>
```

or `select import_company(<archive>::jsonb, <owner>)`. **The installer, or an
administrator of the installation** — the two who may call `create_company()`.
It is one call and one transaction: everything arrives or nothing does.

Refused before a row is written:

| Refusal | When |
|---|---|
| `not_instance_admin` | The caller may not create a company here. |
| `not_an_archive`, `unknown_archive_version` | The manifest is not one this installation reads. |
| `socle_too_old`, `pack_missing`, `pack_too_old`, `module_missing`, `module_too_old` | This installation is behind what the company needs. Migrate, then import. |
| `company_already_here` | Identifiers are kept, so the company is here or it is not. **This is also what a second run meets**: an import never merges. |
| `archive_corrupt` | A table does not have the row count or the checksum its manifest gives, or its rows do not all have the same columns. |
| `unknown_table`, `unknown_column` | The archive holds something this installation would have to drop in silence. |
| `foreign_row` | A row says it is of another company than the one the manifest names. |

The rows are then inserted as they are — not replayed through `post_entry()`,
which would draw new numbers and new dates — with the user triggers of the
tables being filled switched off for the length of the transaction and the
foreign keys left on. **This takes a lock on those tables: bookkeeping in the
other companies of the installation waits until the import ends.** Seconds for
an ordinary company; choose the moment for a large one.

And checked afterwards, which is what the triggers would have guaranteed:

| Refusal | What was found |
|---|---|
| `foreign_row` | A row hung itself on a parent of another company, or a reference points into a company that was already here. Asked of every foreign key between exported tables, read from the catalogue. |
| `unbalanced_entry` | An entry does not agree with its lines, or a posted one does not balance. |
| `matching_mismatch` | A line says it is matched for another amount than its matchings add up to. |
| `counter_behind` | A journal has not counted up to a number it already used, or the matching to a letter; the next one would collide. |
| `overlapping_years` | Two financial years of the company overlap. |

Not checked, and believed as an opening balance is: the totals of a document
against its lines, the computed balance of a statement, the figures a
declaration was frozen with. None of them lets a row reach another company.

What arrives with the company: its lock dates and its closed years, so what was
shut is shut; its counters, so the next number is the next number; its
declarations in the state they were in, frozen ones frozen. What is new: the
first owner (`p_owner_user_id`, or the caller), and one line on the trail,
`company_imported`, which is where the new installation's own testimony
starts — everything before it is what the archive said.

## Adding a table

A table belongs to a company when it carries `company_id`, or a foreign key
leads from it to `companies`, directly or through another such table.
`company_scoped_tables()` reads that from the catalogue. The day a migration
adds one, `tests/company_archive.test.ts` fails and every export refuses, until
the table says which it is:

```sql
-- in the socle
insert into company_archive_registry (table_name, disposition, load_order)
values ('mandates', 'exported', 64);

insert into company_archive_registry (table_name, disposition, reason)
values ('sessions', 'excluded', 'Who is signed in here is not something a company owns.');
```

`load_order` is the order an import fills the tables in. A reference to a table
that loads later, or to the same table, is filled in a second pass and has to
be nullable. A table with no `company_id` names the column and the table that
lead to one (`via_column`, `via_table`).

A module answers for its own tables with a function in its own schema, looked
up the way `can_disable()` is:

```sql
create function assets.archive_tables()
returns table (table_name text, disposition text, reason text,
               via_column text, via_table text, load_order integer) …
```

An operator who added a table of their own beside Ekwo's classifies it with a
row in `company_archive_registry`, the same way.
