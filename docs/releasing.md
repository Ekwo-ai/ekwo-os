# `docs/releasing.md` — how a release is cut

A release of Ekwo OS is one tag carrying the migrations, the country packs and
the npm packages together. There is no "down": a database that has run a
migration cannot be walked back, so every release moves forward, and the
version a database answers with is what a client decides on.

The criteria for `1.0.0` — what the 1.x line promises and the proofs required
before the tag — are in [`road-to-1.0.md`](road-to-1.0.md).

## What has to move

Each step below fails a test or the build when it is skipped: a release that
is half done is worse than one that is not cut.

1. **The schema version.** A migration
   `supabase/migrations/<YYYYMMDDHHMMSS>_schema_version_<x_y_z>.sql` that
   redefines `ekwo_schema_version()` to return the new number, and does nothing
   else. Bump it when the release adds anything a package reads — a table, a
   column, a function. `tests/cli/schema-version.test.ts` carries the numbers
   written out by hand; move them in the same commit.

2. **The package versions**, in every workspace manifest:

   ```sh
   npm version <x.y.z> --workspaces --include-workspace-root --no-git-tag-version
   npm install --package-lock-only
   npm ci     # this must pass before anything else is run
   ```

   Then check the dependency ranges between workspaces, `SERVER_VERSION` in
   `packages/mcp/src/server.ts` and `packages/mcp/server.json`; tests keep each
   equal to the manifest.

3. **The schema floor.** `ekwo.schemaMin` in the manifests of `ekwo-os`,
   `@ekwo-ai/core` and `@ekwo-ai/mcp`, and `SCHEMA_MIN` in each package's
   `src/schema.ts`. Raise it when the packages read something an older database
   does not have; the packages refuse a database below it by name and say to
   run `ekwo migrate`.

4. **The changelog.** `[Unreleased]` becomes `## [x.y.z] — YYYY-MM-DD` under
   [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), with a fresh empty
   `[Unreleased]` above it. Read `git log` against it before closing the
   section.

5. **The generated files.** `npm run docs:schema` and `npm run inventory`; the
   CI compares both with what the generators produce.

6. **The checks.**

   ```sh
   npm run typecheck && npm test && npm run build
   node scripts/check-no-private-data.mjs
   node packages/cli/dist/bin.js --version    # prints the new number
   ```

7. **The end-to-end run, against a real Supabase project.** The test suite
   runs on PGlite; this run covers what PGlite does not — the published binary
   over a pooler, PostgREST and its grants, real JWTs, a hosted project's roles
   and extensions, and a machine key read by PostgREST.

   ```sh
   npm run build
   npm run e2e:supabase                    # one country; see the variables below
   npm run e2e:supabase -- --multi-country # two companies in two countries
   ```

   It reads everything from the environment and writes no secret anywhere:
   `EKWO_DB_URL`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`,
   `SUPABASE_SERVICE_ROLE_KEY`, `EKWO_E2E_COUNTRY` (no default — a default
   country is a chart nobody chose), and where a pack needs them
   `EKWO_E2E_CHART`, `EKWO_E2E_LANGUAGE`, `EKWO_E2E_FISCAL_YEAR_START`,
   `EKWO_E2E_VAT_PERIOD`. **Set `EKWO_E2E_PREVIOUS=ekwo-os@<last tag>`** so the
   run upgrades an installation, which is what users actually do.
   `EKWO_E2E_LOAD_DOCUMENTS` adds the load paths of [`load.md`](load.md).

   The project has to be empty and one nobody minds losing: the script installs,
   books and closes a year, and deletes nothing on its own. `--reset` empties it
   so a failed run can be replayed — for a throwaway project and nothing else.
   It is not in the CI: it costs money, and a shared project would be one two
   releases install into at once. Run it with several packs, including ones with
   a non-calendar year and a non-monthly return.

## Cutting it

1. Open a pull request with all of the above. The CI job *Migrations are
   additive* refuses a published migration that was modified or deleted.
2. Merge it.
3. Tag `main`, annotated, and push the tag:

   ```sh
   git tag -a v<x.y.z> -m "Ekwo OS v<x.y.z>"
   git push origin v<x.y.z>
   ```

   A tag is never moved and never deleted. It starts the **Release** workflow,
   see *npm* below.
4. Publish a GitHub Release on that tag, with the changelog section as its
   body.

## npm

The libraries are published as `@ekwo-ai/*` and the command line as `ekwo-os`
(installed, its binary is `ekwo`). Publishing comes with the tag, so every
version on npm is a version whose source can be read. The workflow
`.github/workflows/release.yml` publishes through npm **trusted publishing**
(GitHub OIDC, no npm token), with a **provenance** statement linking each
tarball to the commit and the run that built it.

### One-time setup, on npmjs.com

For each public package (the list is `npm run release:publish`): open
`https://www.npmjs.com/package/<name>/access`, add a *Trusted Publisher* of
type **GitHub Actions** naming this repository and the workflow file
`release.yml`. A package never published before is published once by hand
(`npm login --auth-type=web`, then `npm run release:publish -- --for-real` on
the tag) before its trusted publisher can be set.

### Releasing

Pushing the tag runs `npm ci`, the typecheck, the build and
`npm run release:publish -- --for-real`. A version the registry already holds
is skipped, so a run that stopped half way is simply re-run. A package's npm
page then shows *Built and signed on GitHub Actions*, and
`npm audit signatures` verifies it.

**Dry run, on any branch**: *Actions → Release → Run workflow* with *Publish
for real* unticked, or locally `npm run build && npm run release:publish`. A
real publish needs a `v*` tag; the script refuses one from a pull request, a
dirty tree or an untagged HEAD, and publishes in dependency order.

## The MCP registry

`@ekwo-ai/mcp` is listed on the official MCP registry under `ai.ekwo/mcp`,
described by `packages/mcp/server.json`. The registry reads `mcpName` from the
**published** manifest, so this step comes after npm. The `ai.ekwo` namespace
is proved by a DNS TXT record on `ekwo.ai`. On every release, from
`packages/mcp`:

```sh
mcp-publisher validate
mcp-publisher login dns --domain ekwo.ai --private-key "<key>"
mcp-publisher publish
```

## After a release

`[Unreleased]` is empty and the next change starts a new section under it. A
published migration is never edited, not even a comment: it has run on
databases nobody here controls, and a correction is a new file.

## Names that change before 1.0

Ekwo keeps books in every country its packs cover — value added tax, goods and
services tax, sales tax, or none. A few names in the schema, the MCP server and
the command line still carry the vocabulary of value added tax, which is one
régime among several. They are renamed before 1.0 so that a name says what a
thing does in every country. This section is the announcement: nothing below is
renamed yet, and each row says what to call once it is.

### The policy

- **Breaking changes stop before the release candidate.** Every rename on this
  list ships, alias included, in a minor release of 0.x; `1.0.0-rc.1` carries
  the new names only, and from there the names are stable.
- **A renamed name keeps answering for at least one minor release.** The new
  name arrives in a release whose changelog lists the old one under
  *Deprecated*; the old one does the same thing until it is listed under
  *Removed*, at the earliest one minor release later and at the latest before
  `1.0.0-rc.1`. An MCP tool is registered under both names and says in its
  description which one to call; a SQL function keeps its former name as a
  wrapper over the new one; a column is kept in step with its successor; a
  command-line flag is accepted under both spellings.
- **The fixed assets module set the pattern.** Its tools were `assets_*` until
  0.10.0, answered under both names in 0.10.0, and are `fixed_assets_*` only
  from 0.11.0.

### The periodic tax return

`vat_return` computes the periodic return of every country — a VAT return, a
GST return, a sales tax return — from the boxes of the country's form. Its name
becomes `tax_return`.

| Today | Becomes | Where |
|---|---|---|
| `vat_return(company, from, to, …)` | `tax_return(company, from, to, …)` | SQL function, and the REST call `/rpc/vat_return` |
| `vat_return` | `tax_return` | MCP tool |
| `EkwoClient.vatReturn()`, type `VatReturnRow` | `EkwoClient.taxReturn()`, `TaxReturnRow` | `@ekwo-ai/core` |
| `--vat-period <cadence>` | `--return-period <cadence>`; `--filing-period <form>=<cadence>` is unchanged | `ekwo init` |
| refusal `unknown_vat_period` | `unknown_filing_period` | `ekwo init` |

The arguments, the result and what the function computes stay as they are.

### Tax numbers and tax categories

| Today | Becomes | Where |
|---|---|---|
| `companies.vat_number`, `contacts.vat_number` | `tax_number` | columns, and the `vat_number` field of `create_contact`, `search_contacts`, `update_company_profile`, `get_company` and `list_companies` |
| `--vat <number>` | `--tax-number <number>` | `ekwo contact add`, `ekwo contact list` |
| `country_defaults.vat_scheme` | `tax_number_scheme` | column: the electronic address scheme a party is reached by through its tax number |
| `taxes.vat_category`, `tax_templates.vat_category`, `document_lines.vat_category` | `tax_category` | columns: the category code of the e-invoicing standards (UNCL5305) |
| `document_lines.vat_rate` | `tax_rate` | column: the percentage frozen on the line when it is posted |
| `vatBalance`, type `DescribedVatBalance` | `taxBalance`, `DescribedTaxBalance` | `ekwo pack describe --json`, the command line's library |

### Former names already superseded

Two columns and one pack field have had a successor since 0.4.0 and are still
kept for older readers. They are removed before `1.0.0-rc.1`.

| Today | Read instead |
|---|---|
| `companies.vat_period` | `company_filing_periods`, one cadence per declaration of the company |
| `country_defaults.vat_period_default` | `tax_report_templates.period_default`, the cadence each form proposes |
| `defaults.vat_period` in a pack's `manifest.json` | `period_default` in the pack's `tax_report.json` |

### Names that stay

Some names belong to one region or one country because the thing they name
does. They stay as they are:

- `ec_sales_list` and `ec_sales_list()` produce the recapitulative statement of
  supplies inside the European Union, a declaration that exists there only;
  `territories.eu_vat_scope`, `eu_vat_from`, `eu_vat_to`, `vat_prefix`,
  `eu_vat_scope_of()` and `vat_prefix_of()` describe membership of the
  European Union's VAT area.
- `generate_fec` and `fec_lines()` write the *Fichier des Écritures
  Comptables*, a file format defined by one country, under its own name — as a
  bank statement reader is called `camt.053` or `coda`.
