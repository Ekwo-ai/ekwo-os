# The road to Ekwo OS 1.0

Ekwo OS is released as minors today — `0.2.0` was the first tag, and every
release since has been additive. Version `1.0.0` is a promise of stability,
and [decision 0059](decisions/0059-releases-and-schema-versions.md) says it is
made only when it can be kept. This page is what that promise covers, what it
leaves to other promises, and the evidence that has to exist before the tag.
Each proof below is a checkable item with the place its evidence will live, so
anybody can follow the road and see how far along it is.

There is no date on this page. The tag is cut when every proof is in.

## 1. What 1.0 promises for the whole 1.x line

From `1.0.0` to the last `1.x`, an installation, a script, an agent or an
integration written against one release keeps working against every later 1.x
release. A change that would break any of the ten promises below is a `2.0.0`.

1. **The schema is additive.** Within 1.x a migration adds — tables, columns,
   functions, enum values, indexes, policies — and never drops or renames a
   public object, never narrows a column's type, and never removes an enum
   value. A function gains a parameter only with a default, so every existing
   call keeps its meaning. The CI job *Migrations are additive* already
   refuses a published migration that was edited or deleted; before 1.0 it
   gains a second comparison, of the public objects of the release against
   those of the latest tag, read from the inventory `npm run inventory`
   generates (`packages/cli/assets/expected-objects.json`).
2. **Functions keep their names and their named errors.** A function of the
   public schema keeps its name, its arguments and the shape of what it
   returns. A refusal keeps its name — the prefix the database raises, such as
   `period_locked:` or `entry_unbalanced:` — and its SQLSTATE, so a caller that
   reads them today reads them throughout 1.x. New refusals may appear for new
   cases; an existing one keeps its meaning.
3. **`ekwo migrate` upgrades from any published version.** An installation of
   any published release, from `0.2.0` on, reaches the latest 1.x with one
   `npx -y ekwo-os@latest migrate`. Migrations move forward only — there is
   no `down` — so this one path is the whole upgrade story.
4. **Posted figures never change on upgrade.** A posted entry is immutable
   ([0014](decisions/0014-a-posted-entry-is-immutable.md)), a posted document
   is frozen ([0015](decisions/0015-a-posted-document-is-frozen.md)) and a
   filed declaration is frozen
   ([0037](decisions/0037-a-filed-declaration-is-frozen.md)). A migration never
   rewrites a posted amount, and a newer country pack reaches a company only
   when somebody runs `ekwo pack upgrade --apply` for it
   ([0028](decisions/0028-a-pack-upgrade-is-never-silent.md)). The trial
   balance, the tax returns and the financial statements of books kept before
   an upgrade read the same after it.
5. **MCP tools keep their names and arguments.** A tool of `@ekwo-ai/mcp`
   keeps its name, its required arguments and the meaning of each. New
   optional arguments and new tools may arrive in any minor. A tool that is
   renamed keeps its former name as a deprecated alias for the rest of 1.x, as
   the fixed assets tools did when they moved from `assets_*` to
   `fixed_assets_*`.
6. **The CLI keeps its verbs and flags.** Every `ekwo` command and flag of
   1.0 keeps working, with the same meaning. The `--json` document keeps the
   shape published as
   [`packages/cli/schema/output.1.json`](../packages/cli/schema/output.1.json),
   and the exit codes keep theirs: `0` success, `1` a failure or a finding,
   `2` a wrong call, `3` the books declined
   ([0054](decisions/0054-the-command-line-output-contract.md)).
7. **The pack format is `pack.1.json`.** A country pack valid against
   [`packs/schema/pack.1.json`](../packs/schema/pack.1.json) installs on every
   1.x release. The format may gain optional fields; a field that becomes
   required is a `pack.2.json`, and the format number travels in each pack's
   `$schema`.
8. **The module format is `module.1.json`.** The same promise for a module
   described by [`modules/schema/module.1.json`](../modules/schema/module.1.json):
   a module that installs on 1.0 installs on every later 1.x.
9. **Company archives travel forward.** An archive written by
   `ekwo company export` on any 1.x release imports into any later 1.x
   release with `ekwo company import`. Its format is
   `ekwo.company-archive`, `format_version` 1
   ([`company-archive.md`](company-archive.md)); a table a module renames
   since is read under its name of today, through the module's
   `archive_former_names()`, as the fixed assets archives already are. The
   checksums of an archive stay readable with `shasum` alone, on any machine.
10. **Security fixes follow a published policy.** Reports go through the
    private channel in [`SECURITY.md`](../SECURITY.md), with an
    acknowledgement within three working days and a fix, or a reason, within
    thirty days for anything that crosses row level security or lets a
    posting bypass the ledger's rules. The latest 1.x minor receives every
    security fix; since an upgrade within 1.x is additive, `ekwo migrate` is
    the way a fix reaches an installation. Once `2.0.0` is published, the last
    1.x minor keeps receiving security fixes for twelve months.

## 2. What carries its own promise

Some parts of Ekwo move at the pace of the world they describe, and each says
for itself what it promises. The core's version number makes no claim about
them beyond the formats above.

- **Country pack content, by status.** A pack has its own semver
  ([`packs.md`](packs.md#versions-and-what-a-company-holds)): a label is a
  patch, an account, a tax or a box is a minor, a new declaration form or
  statement framework is a major. What its content is worth is said by its
  status ([0026](decisions/0026-certification-names-a-reviewer.md)):
  `community` — contributed, not yet read by an accountant; `maintained` —
  kept current by the maintainers, not yet read by an accountant; `reviewed`
  — read by a named professional, with the name and the date in the manifest.
  Tax rules change by law, in every country, and a pack follows them in its
  own versions.
- **Modules.** Each module has its own semver and a status of `draft`,
  `available` or `deprecated` ([`modules.md`](modules.md)). A module's tables,
  functions and tools are promised by its own major version, and its format
  by `module.1.json`.
- **Format libraries.** The packages under
  [`packages/formats/`](../packages/formats/README.md) are MIT and follow the
  formats they write or read. When an administration or a standards body
  publishes a new version of a format — an XBRL taxonomy, an e-invoicing
  syntax, a statement layout — the library follows it, and its own version
  says whether a direct user of the library has something to change.
- **Hosted services.** What Ekwo operates — the hosted MCP server, backups,
  the managed edition — is described in
  [`cloud-services.md`](cloud-services.md) and governed by its own terms.
  Ekwo OS needs none of them, and that holds for every 1.x release.

## 3. The proofs required before the 1.0.0 tag

Each item is done when its evidence is published where it says.

- [ ] **A. The CI is green on every supported platform.** The supported
  versions of Postgres (the majors a Supabase project runs) and of Node (from
  the `>=20` the CLI and the MCP server declare) are written down on this page,
  and every one of them is a required job of `.github/workflows/ci.yml`.
  Today the suite runs on PGlite — Postgres 17 — under Node 22, with Node 24
  informative. *Evidence: the CI matrix, and a green run on the release
  candidate's commit.*
- [ ] **B. A real upgrade from every published version.** On a real hosted
  project, `scripts/e2e-supabase.mjs` with `EKWO_E2E_PREVIOUS` installs each
  published release — `ekwo-os@<version>` from npm from `0.4.1` on, a build of
  the tag before that — and upgrades it to the release candidate with
  `ekwo migrate`. The books kept under the previous release give the same trial
  balance, tax return and financial statements after the upgrade (promise 4).
  *Evidence: one entry per version in [`releasing.md`](releasing.md), under the
  end-to-end run.*
- [ ] **C. The full end-to-end run for every kind of tax.** The end-to-end
  run against a real project — install or upgrade, sign in through Supabase
  Auth, open a year, post a sale and a purchase through PostgREST, the tax
  return the pack asks for, both financial statements, a machine key over
  HTTP, close, re-open, close again, the audit trail — is 21 steps when it
  upgrades and 18 when it installs fresh. It passes, all green, for at least
  one pack of each kind of tax a pack charges on a sale
  ([0020](decisions/0020-one-tax-engine-several-kinds-of-tax.md)) — `vat`,
  `gst` and `sales_tax` — and for a pack whose standard rate splits into a
  national and a local share. *Evidence: the runs in [`releasing.md`](releasing.md),
  with the pack of each.*
- [ ] **D. The six hot paths at volume, on a real project.** The six reads of
  [`load.md`](load.md#the-six-paths) — general ledger, trial balance, aged
  receivables, tax return, entries file, contact suggestions — timed at
  10,000 and at 100,000 documents on a real hosted project, as the owner over
  SQL and as a member over PostgREST, each inside its budget.
  *Evidence: the report and its findings in [`load.md`](load.md).*
- [ ] **E. Every export validated by the official tools of its format.**
  For each format family Ekwo writes, the file produced from a pack's golden
  year passes the validator its publisher provides:
  - ledger audit files — the checker the tax administration publishes for its
    entries file or audit file;
  - financial statements in XBRL — the taxonomy of the filing authority and
    its validation rules;
  - e-invoices — the EN 16931 validation artefacts, the Peppol BIS rules for
    UBL, and the profile checks of hybrid PDF invoices;
  - tax returns and recapitulative statements — the XSD or file specification
    the administration publishes, and its test service where it offers one.

  *Evidence: a "Validated against" section in the README of each library
  under [`packages/formats/`](../packages/formats/README.md), naming the tool,
  its version and the result.*
- [ ] **F. At least three packs at status `reviewed`.** Each read by a named
  external professional, authorised in that country, whose name and date are
  in the pack's manifest — and the three from at least two continents.
  *Evidence: `status: reviewed` in `packs/<cc>/pack.json`, and the table of
  packs in [`packs.md`](packs.md#the-packs-of-this-checkout).*
- [ ] **G. Real books, kept and filed.** At least three real companies, in at
  least two countries, keep their books in Ekwo for a full quarter and file
  their tax returns from Ekwo's figures; and a past financial year of a real
  company is replayed in Ekwo and gives the figures of an official filing that
  was accepted. The companies are not named. *Evidence: a section of this
  page, with the countries, the packs, the kind of filing and what was found.*
- [ ] **H. An external security review of the release candidate.** An
  independent reviewer reads the published release candidate against the
  threat model of [`SECURITY.md`](../SECURITY.md). *Evidence: the report,
  published, with every finding fixed or answered.*
- [ ] **I. The international gaps closed or named.** Every open line of the
  gap table in [`international.md`](international.md#what-an-international-core-needs-and-does-not-have)
  — the revaluation of open items in a foreign currency, cash accounting as a
  ledger, stacked taxes on one line, the cash-flow statement — and of
  [What the packs do not say yet](international.md#what-the-packs-do-not-say-yet)
  is either closed or listed below as a known limit of 1.0.
  *Evidence: a "Known limits of 1.0" section on this page.*

## 4. Until the release candidate

Every release between now and the candidate stays additive, and anything that
moves on the way to 1.0 is written down where a reader will look.

**How to follow.**

- [`CHANGELOG.md`](../CHANGELOG.md) — every release, with what changed under
  *Changed* and *Removed*, including each name that moves before 1.0.
- This page — each proof is ticked, with a link to its evidence, as it lands.
- The [issues](https://github.com/Ekwo-ai/ekwo-os/issues) of the repository —
  where each piece of work is discussed in the open.

**How to take part.** The proofs above are ones a community makes, and every
one of them is open to you:

- **Review the pack for your country.** If you keep books or advise on tax
  for a living — in Lagos, Lima, Lyon or Kuala Lumpur — read the chart, the
  taxes and the declaration boxes against the rules you apply every day. Open
  an issue titled "Review: <country>"; [`CONTRIBUTING.md`](../CONTRIBUTING.md)
  says how, and a review signed with your name is what moves a pack to
  `reviewed`.
- **Run Ekwo on your books.** Install it on a Supabase project of your own,
  bring a year over with `ekwo import`, and compare its figures with the ones
  you filed. Proof G is made of exactly that.
- **Validate an export.** If you know the official checker of a format in your
  country, run it on what Ekwo writes and tell what it says.
- **Report.** What broke, what you expected, what a pack does not say yet: a
  precise issue is a contribution, and a vulnerability goes privately through
  [`SECURITY.md`](../SECURITY.md).

1.0 is the moment Ekwo OS says "build on this". Every review, every run on
real books and every report brings it closer.
