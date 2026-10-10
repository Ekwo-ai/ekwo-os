# Fix 0039 — the file of a declaration is read as a declaration

## The gap

`tax_filing_deposits` asks `filings.read` (select) and `filings.write` (write),
but the two files it names — `sent_file_id` and `acknowledgement_id`, rows of
`attachments` — were read through `documents.read` and written through
`documents.write`, like every attachment. A member whose `filings.read` was
withdrawn and who kept `documents.read` saw no deposit and still read the
declaration sent and the administration's receipt (within their own company).

## The migration

`supabase/migrations/20261010203452_a_filing_file_is_read_as_a_filing.sql`

- New function `attachment_is_filing_deposit_file(uuid)` — `sql`, `stable`,
  `security definer`, `search_path = public, pg_temp`; granted to
  `authenticated` and `service_role`, revoked from `public` and `anon`.
  Two `exists` on `tax_filing_deposits`, each served by the existing indexes
  `tax_filing_deposits_sent_file_idx` / `tax_filing_deposits_acknowledgement_idx`,
  joined to `tax_filings` to apply `may_know_of_company()` (decision 0065).
  Definer because a policy reads other tables under the caller's policies: a
  plain `exists` in the policy would see no deposit for exactly the member
  without `filings.read`, and let the file through as an ordinary one.
- A "filing file" is an attachment with `entity_type = 'tax_filing'` (where
  the files of a deposit are uploaded, before the deposit names them) **or**
  one a deposit names (the trigger of `20261007113412` does not constrain its
  `entity_type`).

### Policies before

```sql
attachments_select  for select
  using (company_id = any ((select companies_with_capability('documents.read'))::uuid[]))
attachments_write   for all
  using (company_id = any ((select companies_with_capability('documents.write'))::uuid[]))
  with check (has_capability(company_id, 'documents.write'))
```
(`20260913083216`, rewritten to the InitPlan form by `20260918141627`.)

### Policies after

```sql
attachments_select  for select using (
  case when entity_type = 'tax_filing' or attachment_is_filing_deposit_file(id)
       then company_id = any ((select companies_with_capability('filings.read'))::uuid[])
       else company_id = any ((select companies_with_capability('documents.read'))::uuid[])
  end)
attachments_write   for all using (
  case when entity_type = 'tax_filing' or attachment_is_filing_deposit_file(id)
       then company_id = any ((select companies_with_capability('filings.write'))::uuid[])
       else company_id = any ((select companies_with_capability('documents.write'))::uuid[])
  end)
  with check (case … then has_capability(company_id, 'filings.write')
                     else has_capability(company_id, 'documents.write') end)
```

Untouched: `attachments_deposit` (insert on the company itself, `documents.deposit`)
and `attachments_select_own_deposit` (a depositor reads back their own pieces).

## Tests

- `tests/filing_deposits.test.ts`, new block *the files of a declaration are
  read as a declaration*:
  - a viewer with `filings.read` revoked reads the ordinary invoice attachment
    and none of the deposit's files (sent file, receipt, and a receipt pinned
    on a document but named by a deposit), and no deposit;
  - a viewer with `filings.read` reads all four;
  - a machine key with `documents.read` reads only the invoice file; with
    `documents.read` + `filings.read`, all four;
  - an accountant with `filings.write` revoked cannot upload a file onto a
    declaration nor delete a deposit's file, and still uploads a document file.
  - Counter-check: without the migration, three of these four tests fail.
- `tests/client_preset.test.ts`: the "scanner" (viewer, `documents.deposit`
  granted, `documents.read` revoked) now also has `filings.read` revoked —
  otherwise it rightly reads the filing receipt of the fixture under the new rule.
- `tests/shared_instance.test.ts` caught a cross-tenant answer of the first
  draft of the helper (true for another tenant's file id); fixed with
  `may_know_of_company()`.

Results (VITEST_MAX_FORKS=4, targeted files):

| File | Tests |
|---|---|
| filing_deposits | 13 passed |
| client_preset | 34 passed |
| shared_instance | 52 passed |
| capabilities | 17 passed |
| rls | 12 passed |
| api_keys | 26 passed |
| api_key_issuer_ceiling | 12 passed |
| guards_a_key_meets | 5 passed |
| key_writes_as_its_issuer | 8 passed |
| bank_statement_import | 34 passed |
| posted_document | 31 passed |
| schema | 14 passed |
| filing_proofs | 14 passed |
| grants | 16 passed |
| cli/catalogue | 15 passed |
| company_archive | 1186 passed |

`npm run typecheck`: clean. `check:no-private-data`, `check:rounding`,
`check:no-country-literals`, `check:no-conflict-markers`, `check:no-bare-eu`,
`check:no-competitor-names`, `check:ohada`: all pass.

## Records

- `docs/decisions/0039-a-deposit-is-an-event.md`: the open item is replaced by
  the rule as it holds, naming `20261010203452`.
- `CHANGELOG.md`: `### Security` added under `## [Unreleased]`, after `### Fixed`.
- `docs/schema.md` and `packages/cli/assets/expected-objects.json` regenerated
  (`npm run docs:schema`, `npm run inventory`), both compared by CI.
