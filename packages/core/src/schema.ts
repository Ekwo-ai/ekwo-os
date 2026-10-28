/**
 * The schema version this package is written against.
 *
 * A country pack declares `schema_min` in its manifest, and for the same
 * reason a published npm package has to: the rows it reads and the functions
 * it calls are a contract with a version of the database, and installing a
 * newer client against an older database is the one upgrade order nobody
 * plans for. The number is declared in `package.json` under `ekwo.schemaMin`
 * and repeated here as a constant, so a bundler that never reads a manifest
 * still carries it; a test keeps the two equal.
 *
 * Forward only. A release of Ekwo is a tag carrying migrations, packs and
 * packages together; there is no "down" migration and there never will be,
 * because undoing a schema change on a database with a year of entries in it
 * is not a script, it is a restore.
 *
 * ## A floor, not the release number
 *
 * `SCHEMA_MIN` is the oldest schema this package still reads, and it is not
 * the version of the release that carries it. Until 0.21.0 the two moved
 * together, at every release: on 26 October 2026 a person invited to a project
 * at 0.19.0 was shown nothing but "Your project needs an update", for a
 * release whose migrations had added one column and two functions, none of
 * which the screens they were opening read.
 *
 * So the floor moves only when a migration is **breaking** for what this
 * package does on an older database: a table or a column renamed or dropped,
 * a function whose arguments or answer changed, a right taken away that a
 * call relied on. A migration that adds something is not a reason. What this
 * package reads or calls that is newer than the floor is named in
 * `SCHEMA_FEATURES` below, with the version that introduced it, and is asked
 * for only on a schema that has it (`supports()`): the column is left out of
 * the read, the older route is taken, or the call is refused by name with
 * `schema_too_old_for`, saying which version it needs.
 *
 * `tests/schema_floor.test.ts` is the proof of the number: it builds a
 * database from the migrations and seeds of the tag `v<SCHEMA_MIN>` and runs
 * the reads of this release against it. A change that stops reading a project
 * at the floor fails there, and the fix is either `SCHEMA_FEATURES` or a
 * higher floor — said in the changelog under **Changed**, with the migration
 * that made it necessary. `docs/releasing.md` carries the rule.
 */

/** The oldest schema `@ekwo-ai/core` reads. */
export const SCHEMA_MIN = '0.19.0';

/** `-1`, `0` or `1`, comparing two `major.minor.patch` versions numerically. */
export function compareSchemaVersions(left: string, right: string): number {
  const parse = (version: string): number[] =>
    version
      .trim()
      .split('.')
      .map((part) => Number.parseInt(part, 10));
  const a = parse(left);
  const b = parse(right);
  for (let index = 0; index < Math.max(a.length, b.length); index += 1) {
    const one = a[index] ?? 0;
    const other = b[index] ?? 0;
    if (Number.isNaN(one) || Number.isNaN(other)) {
      throw new Error(`bad_schema_version: ${left} and ${right} are not both major.minor.patch`);
    }
    if (one !== other) return one < other ? -1 : 1;
  }
  return 0;
}

/** Whether a database at `installed` is new enough for a package needing `minimum`. */
export function schemaIsAtLeast(installed: string, minimum: string): boolean {
  return compareSchemaVersions(installed, minimum) >= 0;
}

/**
 * What a schema newer than the floor brought that a client reads or calls.
 *
 * One entry per thing a person can do or see, named after it, with the
 * version of the schema that introduced it and the objects it is made of:
 * the columns a read leaves out below that version (`table.column`), and the
 * functions a call needs. The objects are what `onSocle()` acts on — a read
 * of `companies` on a schema without `companies.agent_posting` simply does not
 * ask for the column, and a call of `approve_document()` there is refused by
 * name — so a feature listed here is never half there.
 *
 * A feature older than the floor has nothing left to say and is removed when
 * the floor passes it. Nothing is listed here on faith either:
 * `tests/schema_floor.test.ts` checks that every object below is missing at
 * the floor and present in this release.
 */
export const SCHEMA_FEATURES = {
  /**
   * The administration a declaration is paid to, named in the company's own
   * language where the pack gives its name in several
   * (`20261023160200_a_payee_is_named_in_the_company_language`).
   */
  tax_payee_name_i18n: {
    since: '0.20.0',
    columns: ['country_defaults.tax_payee_name_i18n'],
    functions: [],
  },
  /**
   * A draft and its lines written in one statement, so a line the database
   * refuses leaves nothing half done
   * (`20261023160600_a_draft_changes_its_lines_in_one_statement`). Below it,
   * the core writes a draft in two statements, as it did before.
   */
  documents_in_one_statement: {
    since: '0.21.0',
    columns: [],
    functions: ['create_document', 'replace_document_lines'],
  },
  /**
   * How an agent posts in a company — review, autopilot or review only — and
   * the approval of a draft by a person
   * (`20261023174709_an_agent_posts_in_the_mode_its_company_chose`). Below
   * it, nothing holds an agent's posting back, there is no setting to read
   * and no approval to give, and a machine key has no posting mode.
   */
  agent_posting: {
    since: '0.21.0',
    columns: ['companies.agent_posting', 'api_keys.posting_mode'],
    functions: ['approve_document', 'agent_posting_mode', 'document_version'],
  },
  /**
   * The archive of a company read in pages, each a short request
   * (`20261029020000_an_archive_is_read_in_pages`, decision 0092). Below it,
   * `readCompanyArchive()` is refused by name; `export_company()` reads the
   * whole archive in one statement there, as it always did.
   */
  archive_in_pages: {
    since: '0.25.0',
    columns: [],
    functions: ['export_company_outline', 'export_company_page'],
  },
} as const satisfies Record<string, { since: string; columns: readonly string[]; functions: readonly string[] }>;

export type SchemaFeature = keyof typeof SCHEMA_FEATURES;

/**
 * Whether a database at `installed` has `feature`.
 *
 * A version that is unknown — no row came back, or one that is not
 * `major.minor.patch` — is answered `false`: a feature is offered on a schema
 * known to have it, never on a guess.
 */
export function supports(installed: string | null | undefined, feature: SchemaFeature): boolean {
  if (installed === null || installed === undefined || installed.trim().length === 0) return false;
  try {
    return schemaIsAtLeast(installed.trim(), SCHEMA_FEATURES[feature].since);
  } catch {
    return false;
  }
}

/**
 * The features of `SCHEMA_FEATURES` a database at `installed` lacks, in the
 * order they are declared: what a screen greys, and what `ekwo migrate` would
 * bring.
 */
export function missingFeatures(installed: string | null | undefined): SchemaFeature[] {
  return (Object.keys(SCHEMA_FEATURES) as SchemaFeature[]).filter((feature) => !supports(installed, feature));
}
