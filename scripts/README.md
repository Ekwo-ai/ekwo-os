# `scripts/` — repository hygiene

| Script | Purpose | Runs in CI |
|---|---|---|
| `check-no-private-data.mjs` | Refuses the build if any file mentions a term from its deny list (customer and company names of the maintainers' own installations). Keep the list current; extend it before adding a seed or a fixture | yes |
| `check-no-competitor-names.mjs` | Refuses the build if a tracked file names a competing product the project has decided never to name. Published migrations that predate the rule are listed in the script and frozen | yes |
| `generate-schema-doc.mjs` | Rewrites `docs/schema.md` from `supabase/migrations/`, splicing `docs/schema.intro.md` at the top. Needs Node 22.18+ or 24 (it imports a `.ts` file directly) | no — run it and commit the result |
| `generate-expected-objects.mjs` | Rewrites `packages/cli/assets/expected-objects.json`: every table, column, view, function, policy, trigger and type this release defines, and under `grants` which of `anon`, `authenticated` and `service_role` may reach each of them. `ekwo doctor` compares a live database against it. Same Node requirement as above | yes — it regenerates and refuses a diff |
| `e2e-supabase.mjs` | Installs, books a year, files the VAT return and closes it — against a **real, empty** Supabase project, through the published binary, GoTrue and PostgREST. Refuses a database that already holds an `instance` row. With `EKWO_E2E_LOAD_DOCUMENTS` it ends by multiplying those books and timing the six hot paths, over SQL and over PostgREST | no, and never: it costs money and needs a throwaway project |
| `ohada-packs.mjs` | Copies the chart, the journals, the roles, the two statements and the chart's translations (`packs/ohada/i18n/`, when there are any) the OHADA member States share from `packs/ohada/` into each member pack (`--write`), and without the flag refuses a member whose copy has drifted. `packs/ohada/README.md` is how a country is added | yes — the check |
| `publish.mjs` | Publishes the packages to npm in the order their dependencies impose. The list is **read from the workspaces**, never written down: whatever is a workspace and is not `private` goes, after everything of this repository it depends on. Says what it would do by default (`npm publish --dry-run` of each); `--for-real` refuses a dirty tree, a HEAD no tag names and a session nobody logged in to, and skips a version the registry already holds | no — a person runs it, logged in as themselves |
| `load/books.mjs` | Books at volume: clones the year a company really posted — documents, entries, ledger lines, payments, matchings — to any number of documents over several financial years, with invented contacts and a month of bank statement. Deterministic, no real data, no country. Not a command: a module `tests/load/` and `e2e-supabase.mjs` import | through `tests/load/` |
| `load/hot-paths.mjs` | The six reads a set of books is judged on, each with its SQL call, its PostgREST call and its budget, and the reader of `auto_explain` plans that finds a sequential scan of a large table. `docs/load.md` is the long form | through `tests/load/` |

```sh
npm run check:no-private-data
npm run docs:schema
npm run inventory
npm run build && npm run e2e:supabase   # by hand, before a release is tagged
npm run build && npm run release:publish              # the plan, nothing sent
npm run build && npm run release:publish -- --for-real   # on the tag, after `npm login`
```

A third check, that no published migration is modified or deleted, is a job
of the CI workflow itself (`.github/workflows/ci.yml`).
