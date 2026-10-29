import { createHash, randomUUID } from 'node:crypto';
import { openAsBlob } from 'node:fs';
import { mkdir, readFile, readdir, rename, stat, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { dirname, join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { PGlite, type Extensions, type PGliteOptions } from '@electric-sql/pglite';
import { FORMER_SOCLE_SCHEMA, SOCLE_SCHEMA, socleMarkerInCatalogue, socleNamed } from '../../packages/core/src/books/socle-names.ts';

const here = dirname(fileURLToPath(import.meta.url));
export const repoRoot = join(here, '..', '..');
const migrationsDir = join(repoRoot, 'supabase', 'migrations');
const seedDir = join(repoRoot, 'supabase', 'seed');
const modulesDir = join(repoRoot, 'modules');
/**
 * The Supabase shim, applied before the migrations. Exported because
 * `tests/grants.test.ts` builds a database by hand, starting from roles that
 * hold nothing at all, to prove the migrations are the only thing that grants.
 */
export const shimPath = join(here, 'supabase-shim.sql');

/** Where a checkout keeps what a database is built from. */
function treeOf(root: string): { migrations: string; seed: string; modules: string; shim: string } {
  if (root === repoRoot) return { migrations: migrationsDir, seed: seedDir, modules: modulesDir, shim: shimPath };
  return {
    migrations: join(root, 'supabase', 'migrations'),
    seed: join(root, 'supabase', 'seed'),
    modules: join(root, 'modules'),
    shim: join(root, 'tests', 'helpers', 'supabase-shim.sql'),
  };
}

export interface Options {
  /** Apply `supabase/seed/*.sql` after the migrations. Default true. */
  seed?: boolean;
  /**
   * Apply `modules/<folder>/supabase/migrations/*.sql` after the socle's, and
   * the country seeds those modules compiled. Default true — a module is a
   * schema whose tables are empty until a company enables it, so a database
   * that carries them is the ordinary one.
   */
  modules?: boolean;
  /**
   * PGlite extensions to make loadable. `tests/load/` asks for `auto_explain`,
   * which is how the plan of a statement inside a function body is read; no
   * other test needs one, and a contrib module nobody loads costs nothing.
   */
  extensions?: Extensions;
  /**
   * Socle migrations to leave out, by file name: the database is then the one
   * an installation held before they were published, and an upgrade test
   * applies them itself, on books written by the schema as it was.
   */
  withoutMigrations?: string[];
  /**
   * SQL run after the migrations and the modules, before the seeds. A layout
   * built without the latest migrations still loads today's seeds, and a seed
   * may write a column one of those migrations adds: the caller adds it here,
   * where that layout keeps the socle.
   */
  beforeSeeds?: string;
  /**
   * Another checkout to build from — its migrations, modules, seeds and shim
   * — instead of this one. `tests/schema_floor.test.ts` builds the database
   * of the tag at the schema floor this way, and runs this release against it.
   */
  root?: string;
}

/** Files applied, in order, by `freshDatabase`. */
export async function migrationFiles(root = repoRoot): Promise<string[]> {
  return (await readdir(treeOf(root).migrations)).filter((f) => f.endsWith('.sql')).sort();
}

export async function seedFiles(root = repoRoot): Promise<string[]> {
  return (await readdir(treeOf(root).seed)).filter((f) => f.endsWith('.sql')).sort();
}

export interface ModuleFile {
  /** `assets` */
  code: string;
  /** `20260913080114_assets.sql` */
  file: string;
  path: string;
  /** `20260913080114` */
  version: string;
}

export interface ModuleFolder {
  /** `assets`, the code its manifest gives. */
  code: string;
  /** `fixed-assets`, the folder under `modules/`. */
  folder: string;
  /** `fixed_assets`, the pack section it compiles its seeds under, if any. */
  section: string | null;
}

/**
 * The module folders this checkout carries, with what each manifest says, in
 * the order the folders sort. The folder is named after what the module is,
 * and the code is the key it was published under: they may differ.
 */
export async function moduleFolders(root = repoRoot): Promise<ModuleFolder[]> {
  const modulesDir = treeOf(root).modules;
  const entries = await readdir(modulesDir, { withFileTypes: true }).catch(() => []);
  const out: ModuleFolder[] = [];
  for (const entry of entries.filter((e) => e.isDirectory() && e.name !== 'schema').sort((a, b) => a.name.localeCompare(b.name))) {
    const manifest = JSON.parse(await readFile(join(modulesDir, entry.name, 'module.json'), 'utf8')) as {
      code: string;
      pack?: { section: string };
    };
    out.push({ code: manifest.code, folder: entry.name, section: manifest.pack?.section ?? null });
  }
  return out;
}

/** The module codes this checkout carries, sorted. */
export async function moduleCodes(root = repoRoot): Promise<string[]> {
  return (await moduleFolders(root)).map((m) => m.code).sort();
}

/**
 * Every module migration of this checkout, ordered by version.
 *
 * The order is global rather than per module, because they share one history
 * table with the socle and a module may one day depend on another. A duplicate
 * version anywhere is what `modules.test.ts` refuses.
 */
export async function moduleMigrationFiles(root = repoRoot): Promise<ModuleFile[]> {
  const out: ModuleFile[] = [];
  for (const { code, folder } of await moduleFolders(root)) {
    const dir = join(treeOf(root).modules, folder, 'supabase', 'migrations');
    const exists = await stat(dir).catch(() => undefined);
    if (exists === undefined) continue;
    for (const file of (await readdir(dir)).filter((f) => f.endsWith('.sql')).sort()) {
      out.push({ code, file, path: join(dir, file), version: file.slice(0, 14) });
    }
  }
  return out.sort((a, b) => a.version.localeCompare(b.version));
}

/** The pack seeds a module compiled: `supabase/seed/modules/<section>/*.sql`. */
export async function moduleSeedFiles(root = repoRoot): Promise<ModuleFile[]> {
  const out: ModuleFile[] = [];
  for (const { code, section } of await moduleFolders(root)) {
    if (section === null) continue;
    const dir = join(treeOf(root).seed, 'modules', section);
    const exists = await stat(dir).catch(() => undefined);
    if (exists === undefined) continue;
    for (const file of (await readdir(dir)).filter((f) => f.endsWith('.sql')).sort()) {
      out.push({ code, file, path: join(dir, file), version: file.slice(0, 14) });
    }
  }
  return out;
}

/**
 * Every PGlite a test opens, opened here.
 *
 * `close()` stops Postgres but keeps the WebAssembly module — and with it the
 * whole heap of the database, 300 MB and more once a schema is loaded — for as
 * long as the object is reachable. A test holds its database in a `let` that a
 * `describe` closes over, so a file that opens one per pack kept every one of
 * them until the file ended: ec_sales_list.test.ts reached 10 GB in one
 * worker. The `close()` of a database opened here lets go of the module once
 * Postgres has stopped, so a closed database weighs nothing, whoever still
 * points at it.
 */
export async function openDatabase(options: PGliteOptions = {}): Promise<PGlite> {
  const db = new PGlite(options);
  await db.waitReady;
  const close = db.close.bind(db);
  db.close = async () => {
    await close();
    open.delete(db);
    Object.assign(db, { mod: undefined, fs: undefined });
  };
  open.add(db);
  return db;
}

const open = new Set<PGlite>();

/** The databases opened in this file that nobody closed; `tests/setup.ts` reads it. */
export function stillOpen(): PGlite[] {
  return [...open];
}

/**
 * A brand new in-memory Postgres with the whole schema applied.
 *
 * PGlite is Postgres compiled to WebAssembly, so the migrations run against
 * the real planner and the real constraints — no Docker, no stub.
 *
 * The migrations, the modules and the seeds are replayed once per set of
 * options and per content of those files, not once per call: the first call
 * builds the database and writes its data directory to disk
 * (`schemaImage`), and every call after it — in this file or in any other
 * worker of the run — starts a new Postgres on a copy of that directory. A
 * replay takes seconds and leaves the heap of the worker swollen; a load
 * takes a few hundred milliseconds, and what each test gets is the same
 * database, from the same files.
 *
 * Nothing here grants `anon` or `authenticated` anything. It used to: the
 * shim carried the default privileges of a Supabase project and this function
 * ended with a `grant … on all tables in schema public`, so a test that read a
 * table as a signed-in user proved nothing about whether the schema had ever
 * granted the read. Since `20260914151207` the migrations declare their own
 * privileges by name, and the only thing between a role and a table in these
 * tests is a `grant` somebody wrote.
 */
export async function freshDatabase(options: Options = {}): Promise<PGlite> {
  const image = await schemaImage(options);
  const db = await openDatabase({
    loadDataDir: await openAsBlob(image),
    ...(options.extensions === undefined ? {} : { extensions: options.extensions }),
  });

  // This connection is the installer, and says so. `is_installer()` is what
  // the guards read instead of "auth.uid() is null", so a test that arranges
  // a fixture as the owner keeps working and a test that puts a session or a
  // machine key on the connection stops being the installer for its duration.
  // A setting lives in the session, not in the data directory: it is set on
  // every database, loaded or built.
  await db.exec(`select set_config('ekwo.installing', 'on', false);`);

  await followSocle(db);

  return db;
}

/**
 * The socle first on the path of this connection, wherever it is.
 *
 * A test writes its SQL unqualified — `select … from companies` — and the
 * socle lives in `ekwo` since `20261028040000` (decision 0090): a data
 * directory carries the objects, not the path of the connection that built
 * it, so every database opened from one asks here. An image built before the
 * move (`tests/schema_floor.test.ts`) has no marker in `ekwo` and keeps
 * `public`.
 */
/**
 * A migration file read for the socle's schema of the day, as `ekwo migrate`
 * reads one (`socleNamed`): a file published before the move names
 * `public.`, and a test that replays it on a database where the socle is in
 * `ekwo` gets it with `ekwo.` in its place.
 */
export async function readMigration(db: PGlite, file: string, root = repoRoot): Promise<string> {
  return socleNamed(await readFile(join(root, 'supabase', 'migrations', file), 'utf8'), await socleSchemaIn(db));
}

/** `readMigration`, run. */
export async function replayMigration(db: PGlite, file: string, root = repoRoot): Promise<void> {
  await db.exec(await readMigration(db, file, root));
}

/** Any published SQL file — a module's migration or seed — read the same way, and run. */
export async function replaySql(db: PGlite, path: string): Promise<void> {
  await db.exec(socleNamed(await readFile(path, 'utf8'), await socleSchemaIn(db)));
}

/**
 * What `ekwo module` does once a module's migrations have run: every module
 * function without a path of its own gets one, its schema then the socle's
 * (`ekwo.module_functions_follow_the_socle()`, `20261028040000`). Nothing on
 * a database before the move, where the function is not there.
 */
export async function moduleFunctionsFollowTheSocle(db: PGlite): Promise<void> {
  const present = await db.query<{ there: boolean }>(
    `select to_regprocedure('ekwo.module_functions_follow_the_socle(text)') is not null as there`,
  );
  if (present.rows[0]?.there !== true) return;
  await db.query(`select ekwo.module_functions_follow_the_socle(m.schema_name) from ekwo.modules m`);
}

export async function followSocle(db: PGlite): Promise<void> {
  await db.exec(`
    select set_config('search_path',
                      case when to_regprocedure('ekwo.ekwo_schema_version()') is null then 'public'
                           else 'ekwo, public' end,
                      false);`);
}

/**
 * The data directory of a database built with these options, as a tar file,
 * built if this run has not built it yet.
 *
 * Its name is a hash of the options that change the data and of every file
 * the build reads, so an edited migration or seed is a new image and never a
 * stale one. The directory is the run's (`tests/global-setup.ts` makes it and
 * removes it); outside a run, the system's temporary directory. Two workers
 * that build the same image at once both write it, each to its own file, and
 * the rename that publishes it is atomic: the loser's copy is identical.
 */
/** `ekwo` once the marker is there, `public` until then — the question every client asks. */
export async function socleSchemaOf(db: PGlite): Promise<string> {
  return socleSchemaIn(db);
}

async function socleSchemaIn(db: PGlite): Promise<string> {
  const found = await socleMarkerInCatalogue(async (sql, params) => (await db.query<Record<string, unknown>>(sql, params)).rows, SOCLE_SCHEMA);
  return found ? SOCLE_SCHEMA : FORMER_SOCLE_SCHEMA;
}

export async function schemaImage(options: Options = {}): Promise<string> {
  const root = options.root ?? repoRoot;
  const tree = treeOf(root);
  const leftOut = new Set(options.withoutMigrations ?? []);
  const migrations = (await migrationFiles(root)).filter((f) => !leftOut.has(f)).map((f) => join(tree.migrations, f));
  const moduleMigrations =
    options.modules === false ? [] : (await moduleMigrationFiles(root)).map((m) => m.path);
  const seeds = options.seed === false ? [] : (await seedFiles(root)).map((f) => join(tree.seed, f));
  const moduleSeeds =
    options.seed === false || options.modules === false ? [] : (await moduleSeedFiles(root)).map((m) => m.path);
  // The order is the build's: the modules after the socle and before the
  // seeds, because a module migration may reference `public.companies` or
  // `public.accounts`, and a module's country seed writes its own reference
  // tables, which have to exist first.
  const files = [tree.shim, ...migrations, ...moduleMigrations, ...seeds, ...moduleSeeds];

  const hash = createHash('sha256');
  for (const file of files) {
    hash.update(relative(root, file)).update('\0').update(await readFile(file)).update('\0');
  }
  if (options.beforeSeeds !== undefined) hash.update('beforeSeeds\0').update(options.beforeSeeds);
  const dir = process.env.EKWO_TEST_SCHEMA_DIR ?? join(tmpdir(), 'ekwo-test-schema');
  const image = join(dir, `${hash.digest('hex').slice(0, 24)}.tar`);
  if (await stat(image).catch(() => undefined)) return image;

  const db = await openDatabase();
  try {
    // A module's file names the socle `public.`, as published; once the
    // socle's own migrations have moved it to `ekwo` the file is read for
    // that schema, as `ekwo migrate` reads it (`socleNamed`).
    const moduleFiles = new Set([...moduleMigrations, ...moduleSeeds]);
    const lastModuleMigration = moduleMigrations.at(-1);
    const firstSeed = [...seeds, ...moduleSeeds][0];
    for (const file of files) {
      if (file === firstSeed && options.beforeSeeds !== undefined) await db.exec(options.beforeSeeds);
      try {
        const published = await readFile(file, 'utf8');
        const sql = moduleFiles.has(file) ? socleNamed(published, await socleSchemaIn(db)) : published;
        await db.exec(sql);
        if (file === lastModuleMigration) await moduleFunctionsFollowTheSocle(db);
      } catch (error) {
        throw new Error(`${relative(root, file)} failed: ${(error as Error).message}`);
      }
    }
    // A data directory written after a checkpoint opens without replaying
    // the write-ahead log.
    await db.exec('checkpoint');
    const dump = await db.dumpDataDir('none');
    await mkdir(dir, { recursive: true });
    const partial = `${image}.${process.pid}.${randomUUID()}`;
    await writeFile(partial, new Uint8Array(await dump.arrayBuffer()));
    await rename(partial, image);
  } finally {
    await db.close();
  }
  return image;
}

/** Single scalar from a query. */
export async function one<T = Record<string, unknown>>(
  db: PGlite,
  sql: string,
  params: unknown[] = [],
): Promise<T> {
  const result = await db.query<T>(sql, params);
  const row = result.rows[0];
  if (row === undefined) throw new Error(`no row returned by: ${sql}`);
  return row;
}

export async function rows<T = Record<string, unknown>>(
  db: PGlite,
  sql: string,
  params: unknown[] = [],
): Promise<T[]> {
  return (await db.query<T>(sql, params)).rows;
}

/** Run a block as a signed-in Supabase user, then drop back to the owner. */
export async function asUser<T>(
  db: PGlite,
  userId: string,
  fn: () => Promise<T>,
  role = 'authenticated',
): Promise<T> {
  await db.exec(
    `select set_config('request.jwt.claims', '${JSON.stringify({ sub: userId, role })}', false);
     select set_config('ekwo.installing', '', false);
     set role ${role};`,
  );
  try {
    return await fn();
  } finally {
    await db.exec(
      `reset role;
       select set_config('request.jwt.claims', '', false);
       select set_config('ekwo.installing', 'on', false);`,
    );
  }
}

/** Assert that a statement raises, and return the message. */
export async function expectError(db: PGlite, sql: string, params: unknown[] = []): Promise<string> {
  try {
    await db.query(sql, params);
  } catch (error) {
    return (error as Error).message;
  }
  throw new Error(`expected an error from: ${sql}`);
}

/**
 * Run a block with one trigger of one table switched off, then switch it back.
 *
 * For the tests that stand on a floor nothing reaches any more: a check
 * constraint or a read-time test that a guard published later now keeps
 * anybody from getting to. The guard is named, so the test says which rule it
 * stepped around and why; nothing in the schema does this.
 */
export async function withoutTrigger<T>(db: PGlite, table: string, trigger: string, fn: () => Promise<T>): Promise<T> {
  await db.exec(`alter table ${table} disable trigger ${trigger}`);
  try {
    return await fn();
  } finally {
    await db.exec(`alter table ${table} enable trigger ${trigger}`);
  }
}
