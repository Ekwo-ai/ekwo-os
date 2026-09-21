# `docs/releasing.md` — how a release is cut

A release of Ekwo OS is one tag carrying the migrations, the country packs and
the npm packages together. There is no "down": a database that has run a
migration cannot be walked back, so every release is forward, and the version
a database answers with is what a client decides on.

`v0.2.0`, on 14 September 2026, is the first published release. `0.1.0` was the
first schema of this repository and was never tagged.

## What has to move, and in which order

Nothing below is optional. Each step fails a test or the build when it is
skipped, which is deliberate: a release that is half done is worse than one
that is not cut.

1. **The schema version.** A migration
   `supabase/migrations/<YYYYMMDDHHMMSS>_schema_version_<x_y_z>.sql` that
   redefines `ekwo_schema_version()` to return the new number, keeping the
   comment and ending with the revoke every migration ends with. It is the
   only thing that migration does. `instance.schema_version` follows on its
   own: the column default and `init_instance()` both call the function, and
   `ekwo migrate` writes it back onto an installation that already exists.

   Bump it when the release adds anything a package of this release reads — a
   table, a column, a function. A release that touches no schema keeps the
   number and needs no migration.

   `tests/cli/schema-version.test.ts` writes the three numbers out by hand —
   `RELEASE`, `PREVIOUS` and `BUMP`, the name of the migration that carries
   nothing else — because a test that asks the code what it says proves
   nothing. Move them in the same commit.

2. **The package versions.** Every workspace manifest, the private root
   included:

   ```sh
   npm version <x.y.z> --workspaces --include-workspace-root --no-git-tag-version
   npm install --package-lock-only
   npm ci     # this must pass before anything else is run
   ```

   Check the dependency ranges between the workspaces afterwards —
   `@ekwo-ai/core` on `@ekwo-ai/fec`, `ekwo-os` on `@ekwo-ai/core`,
   `@ekwo-ai/mcp` on both and on the three statement readers,
   `@ekwo-ai/camt053`, `@ekwo-ai/coda` and `@ekwo-ai/cfonb120` — and the
   formatting of the manifests, which npm rewrites. The final `npm install`
   `npm version` runs on its own fails until those ranges name the new number,
   because a workspace at `0.3.0` no longer answers a range of `^0.2.0` and npm
   goes looking on the registry for a package that is not there.

   `SERVER_VERSION` in `packages/mcp/src/server.ts` follows the manifest, for
   the reason `SCHEMA_MIN` does: a bundle that ships no manifest still has to
   say what it is in the MCP handshake. A test keeps the two equal.

   `packages/mcp/server.json` follows it too — its `version` and the
   `version` of its npm package — because it is what the MCP registry lists.
   `tests/mcp/surface.test.ts` keeps it equal to the manifest, and its `name`
   equal to `mcpName`.

3. **The schema floor.** `ekwo.schemaMin` in the manifests of `ekwo-os`,
   `@ekwo-ai/core` and `@ekwo-ai/mcp`, and the `SCHEMA_MIN` constant in each
   package's `src/schema.ts`. A test keeps the manifest and the constant
   equal, and another refuses a floor newer than the schema the release
   defines.

   Raise it when the packages of the release read something an older database
   does not have. It is a floor, not the version: a release that adds nothing
   a package reads leaves it where it is. The MCP server refuses a database
   below it by name, and says to run `ekwo migrate`.

4. **The changelog.** `CHANGELOG.md` follows
   [Keep a Changelog](https://keepachangelog.com/en/1.1.0/): `[Unreleased]`
   becomes `## [x.y.z] — YYYY-MM-DD`, a fresh empty `[Unreleased]` goes above
   it, and a link reference at the bottom points at the release. Group the
   entries Added / Changed / Removed / Fixed / Security, once each. Read
   `git log` against it before you close the section; what shipped without a
   line is what nobody will find later.

5. **The generated documentation.** `npm run docs:schema`, because the version
   migration changes a function body and `docs/schema.md` is the output of the
   migrations. `npm run inventory` is in the list below for the same reason:
   `packages/cli/assets/expected-objects.json` carries the objects this
   release defines and the privileges it grants on them, and it travels inside
   the published package for `ekwo doctor` to read. CI compares both committed
   files with what the generators produce.

6. **The checks.**

   ```sh
   npm run typecheck && npm test && npm run build
   node scripts/check-no-private-data.mjs
   node packages/cli/dist/bin.js --version    # prints the new number
   ```

7. **The end-to-end run, against a real project.** `tests/e2e/` proves the
   whole story against PGlite — the same release installed through the CLI and
   the way `supabase db push` and `psql -f` do, compared row by row, then a
   company brought from 1.0.0 through an opening balance, two invoices, the VAT
   return, both financial statements, a close, a re-opening and a close again.
   PGlite is real Postgres and four things it is not, and they are the four
   that break a release:

   - the published binary, over a pooler connection string;
   - PostgREST — a function that exists and was never granted to
     `authenticated` passes every test in this repository and answers
     "permission denied" to the first user;
   - GoTrue, so row level security judged on a real JWT rather than on a
     session variable a test set;
   - the extensions, roles and defaults a hosted project has.

   ```sh
   npm run build
   npm run e2e:supabase
   ```

   It reads everything from the environment and writes no secret anywhere:

   | Variable | What |
   |---|---|
   | `EKWO_DB_URL` | the pooler connection string of the project |
   | `SUPABASE_URL` | `https://<ref>.supabase.co` |
   | `SUPABASE_ANON_KEY` | the anon key — what a real client sends |
   | `SUPABASE_SERVICE_ROLE_KEY` | used once, by `ekwo init`, to create the administrator |
   | `EKWO_E2E_COUNTRY` | the pack to install. No default: a default country is a chart of accounts nobody chose |
   | `EKWO_E2E_CHART` / `EKWO_E2E_LANGUAGE` | required whenever the pack carries more than one of either — `ekwo init` refuses to pick for you when there is nobody to ask, which is the right answer and the first thing this script found |
   | `EKWO_E2E_FISCAL_YEAR_START` | required for a pack that names no month to open the year on (GB): the first day of the 2026 year |
   | `EKWO_E2E_VAT_PERIOD` | required for a pack whose periodic return is filed monthly or quarterly depending on the company (LU): `month` or `quarter` |
   | `EKWO_E2E_ADMIN_EMAIL` / `EKWO_E2E_ADMIN_PASSWORD` | the administrator it creates and signs in as |
   | `EKWO_E2E_PREVIOUS` | optional: install that release first, so the run upgrades an installation instead of creating one. Left out, those steps are skipped rather than passed |
   | `EKWO_E2E_LOAD_DOCUMENTS` | optional: multiply the books to that many documents and time the six hot paths, over SQL and over PostgREST |

   **Point `EKWO_E2E_PREVIOUS` at the last tag.** It is the only way the run
   exercises what a user will actually do. It takes a path to a built binary of
   an older checkout:

   ```sh
   git worktree add /tmp/prev v0.2.0
   (cd /tmp/prev && npm ci && npm run build)
   EKWO_E2E_PREVIOUS=/tmp/prev/packages/cli/dist/bin.js npm run e2e:supabase
   ```

   From `0.4.1` on the CLI is on npm, and `ekwo-os@<x.y.z>` works in the same
   variable — the script runs it with `npx --package` from an empty directory,
   because from inside this repository the workspace called `ekwo-os` answers
   for the name and `npx` finds no `ekwo` to run. A release older than that was
   never published under that name, so for those the path is the only form
   that works.

   **The last run: 19 September 2026**, on a throwaway project in `eu-west-3`
   (Postgres 17.6, session pooler `aws-1`), deleted afterwards. Every pack,
   each upgraded from `ekwo-os@0.4.1` on npm, `--reset` between runs: BE, EE,
   FR, GB (year opening 1 April), LU (quarterly) and US all green, 21 steps
   each. What it found and what was fixed: `ekwo init` left the modules out, so
   `ekwo status` called a fresh installation sixteen migrations behind; the
   script posted a New York sales tax on a supply it placed nowhere, found no
   purchase tax in a pack whose purchase tax is not recoverable, and asked a
   quarterly filer for a yearly return; `npx ekwo-os@…` ran from the
   repository found no binary; the load steps timed the return of an empty
   month. At 10 000 documents (FR, 90 000 ledger lines) every path is inside
   its budget over SQL, the slowest being `suggest_contacts` at 1.1 s; over
   PostgREST `suggest_contacts` is OVER, at 15 s — one HTTP call per bank line,
   167 of them, from a client in Belgium. The project had self sign-up turned
   off and PostgREST's row cap raised to 100 000 through the Management API.

   **Read the times, not only the marks.** Every step of the table carries how
   long it took and the run carries its total. What is worth noticing is which
   step holds the release: a migration set that doubled since the last tag, a
   first query waiting on a cold project, a close that got slower as the ledger
   grew. A number that moved between two releases is the question; the total on
   its own answers nothing.

   **The project has to be empty, and has to be one nobody minds losing.** The
   script installs an instance, an administrator and a company, books into them
   and closes a financial year, so it refuses a database that already holds an
   `instance` row. It deletes nothing on its own: what is left behind is the
   evidence. It is not in the CI and never will be — it costs money, and a
   shared throwaway project would be a project two releases install into at
   once.

   **`--reset` empties the project so a failed run can be replayed.** It drops
   the module schemas, `public` and `supabase_migrations`, and recreates the
   schema with the default privileges a Supabase project has. Since
   `20260914151207` the migrations no longer need that — they grant their own
   rights, by name — and the reset restores the defaults anyway, on purpose: a
   real project has them, and a reset that left them out would be a reset that
   quietly stopped exercising what that migration does about them. What the run
   should then find is the revoke working, which is the step named "the
   anonymous role reaches no table". Before all this, a reset that forgot the
   defaults left an installation `ekwo doctor` called healthy and PostgREST
   answered `permission denied for table companies` on.

   ```sh
   npm run e2e:supabase -- --reset
   ```

   It is as destructive as it sounds and it is deliberately not an `ekwo`
   command: an installer that can empty a database is one somebody points at
   the wrong connection string. For a throwaway project and nothing else.

## Cutting it

1. Open a pull request with all of the above. The CI job *Migrations are
   additive* compares the branch against `main` and, on a push, against the
   latest tag: a published migration that was modified or deleted fails the
   build whatever route it took.
2. Merge it.
3. Tag `main`, annotated, and push the tag:

   ```sh
   git tag -a v<x.y.z> -m "Ekwo OS v<x.y.z>"
   git push origin v<x.y.z>
   ```

   The tag is what the additive-migrations job compares against from then on,
   which is why it is never moved and never deleted.
4. Publish a GitHub Release on that tag, with the changelog section of the
   version as its body.

## npm

The packages live on npm under the `ekwo-ai` organisation, and the command line
as `ekwo-os`. Publishing is part of the release and comes after the tag, so a
version on npm is always a version someone can read the source of:

```sh
npm run build
npm run release:publish                 # the plan, and a dry run of every pack
npm login --auth-type=web               # a person, in a browser: no token lives here
npm run release:publish -- --for-real   # on the tag
```

`scripts/publish.mjs` **reads the list from the workspaces**: whatever is a
workspace and is not `private` is published, after every package of this
repository it depends on. The list used to be written here by hand, and a brick
was once in the repository and not in it. For real, the script refuses a
working tree that is not clean and a HEAD that no tag names, and it skips a
version the registry already holds — so a run that stopped half way is simply
run again.

The order is the dependency order: a package is published after everything it
depends on. The root workspace is `private` and is never published.

**The command line is `ekwo-os` on npm and `ekwo` once installed.** The
registry refuses the unscoped name `ekwo` as too close to two existing
packages, which a scoped name is never judged for — so the fourteen libraries
went out as `@ekwo-ai/*` at `0.4.0` and the CLI followed at `0.4.1` under the
name of the repository. `npx ekwo-os init` runs it without installing anything;
`npm install -g ekwo-os` puts a binary called `ekwo` on the path, and every
example that starts with `ekwo ` assumes that.

An account with two-factor authentication on writes is asked to approve each
`npm publish` in a browser, and the script needs a real terminal for that: npm
only waits for the approval when it has one, and ends on `EOTP` when it does
not. Count one approval per package. The approval page offers to stop asking
for five minutes; on the `0.4.1` run that did not carry from one package to the
next, and fifteen packages were fifteen approvals. An approval that is not
given in time ends the run on a 404 from the registry's `done` address — run
the script again, it skips what is already there.

## The MCP registry

`@ekwo-ai/mcp` is described to the official registry
(registry.modelcontextprotocol.io) by `packages/mcp/server.json`, under the
name `ai.ekwo/mcp`. The registry holds metadata only; the package stays on npm,
and the registry proves the two belong together by reading `mcpName` out of the
**published** manifest — so this step comes after `npm`, never before, and a
version published without `mcpName` (0.4.1 and older) cannot be listed.

The `ai.ekwo` namespace is proved by a TXT record on the apex of `ekwo.ai` —
not on a sub-label, where the registry does not look — set once. It needs
OpenSSL 3: the `openssl` of macOS is LibreSSL and has no Ed25519, so there use
`$(brew --prefix openssl@3)/bin/openssl`.

```sh
openssl genpkey -algorithm Ed25519 -out ekwo-mcp-registry.pem   # kept out of this repository
echo "ekwo.ai. IN TXT \"v=MCPv1; k=ed25519; p=$(openssl pkey -in ekwo-mcp-registry.pem -pubout -outform DER | tail -c 32 | base64)\""
```

Then, on every release, from `packages/mcp`:

```sh
brew install mcp-publisher        # or the binary from the registry's GitHub releases
mcp-publisher validate
mcp-publisher login dns --domain ekwo.ai \
  --private-key "$(openssl pkey -in ekwo-mcp-registry.pem -noout -text | grep -A3 'priv:' | tail -n +2 | tr -d ' :\n')"
mcp-publisher publish
```

The registry is in preview: its own documentation warns that data may be
reset before general availability. Check the listing after a publish with
`curl 'https://registry.modelcontextprotocol.io/v0/servers?search=ai.ekwo'`.

## After a release

`[Unreleased]` is empty and the next change starts a new section under it. A
published migration is never edited from `v0.2.0` on — not to fix a typo in a
comment, not to correct a value. It has run on databases nobody here controls,
and the correction is a new file.
