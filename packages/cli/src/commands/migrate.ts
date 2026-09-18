/**
 * `ekwo migrate` — bring an existing installation up to this release.
 *
 * It shows the gap before it closes it, so an operator sees what is about to
 * run. The reference seeds are re-applied too: they are idempotent, and a new
 * release that adds an account to a chart would otherwise leave every
 * installation one row short.
 *
 * **The modules this release carries are migrated too, by default.** A module
 * is a schema whose tables are empty and whose row level security is on until
 * a company enables it, so there is nothing to ask before creating them — and
 * a module whose schema is half there is the state nobody can reason about.
 * `--no-modules` leaves them alone, which is also what to pass before running
 * `supabase db push`: the Supabase CLI knows the socle's files and not a
 * module's, so it would report them as history it has no file for.
 */

import { boolFlag, rejectUnknownFlags, type ParsedArgs } from '../args.js';
import { migrationsDir, seedDir } from '../bundle.js';
import { CONNECTION_FLAGS, openDatabase, type CommandDeps } from '../context.js';
import { applyMigrations, listMigrations, migrationGap } from '../migrations.js';
import { applyModuleMigrations } from './module.js';
import { allModuleMigrations, listModules } from '../module/read.js';
import { isInteractive } from '../prompt.js';
import { applySeeds } from '../seeds.js';
import { schemaIsInstalled } from '../bootstrap.js';
import { syncSchemaVersion } from '../status.js';
import { setResult } from '../output.js';
import { bold, dim, heading, line, note, skipped, step, warn } from '../ui.js';

export const MIGRATE_FLAGS = [...CONNECTION_FLAGS, 'skip-seeds', 'no-modules', 'yes'] as const;

/**
 * The line to print before a migration runs.
 *
 * There is no "down" migration in this repository and there never will be:
 * undoing a schema change on a database holding a year of entries is a
 * restore, not a script. Which makes the snapshot the only way back, and an
 * operator who reads this after the fact has already not taken one.
 */
export function snapshotRecommendation(): void {
  line();
  warn(
    `Take a snapshot first. Migrations move forward only — there is no ${bold('down')} — so a ` +
      'restore is the way back.',
  );
  note(dim('  Supabase: Database → Backups, or `supabase db dump -f before-upgrade.sql`.'));
  note(dim('  Self-hosted: `pg_dump` the database this connection points at.'));
  line();
}

export async function migrateCommand(args: ParsedArgs, deps: CommandDeps = {}): Promise<number> {
  rejectUnknownFlags(args, MIGRATE_FLAGS);
  const interactive = !boolFlag(args, 'yes') && isInteractive();
  const { db } = await openDatabase(args, { interactive, connect: deps.connect });

  try {
    const migrations = await listMigrations(migrationsDir());
    const modules = boolFlag(args, 'no-modules') ? [] : await listModules();
    // A module's versions live in the same history, so they are not "unknown"
    // — they are simply not the socle's. The gap is computed against both.
    const gap = await migrationGap(db, [...migrations, ...allModuleMigrations(modules)]);

    heading('Migrations');
    note(dim(`${gap.applied.length} applied, ${gap.pending.length} pending`));

    if (gap.unknown.length > 0) {
      warn(
        `${gap.unknown.length} migration(s) in this database are not in this release — ` +
          'it was installed by a newer version. Upgrade the CLI before migrating.',
      );
      for (const version of gap.unknown) note(dim(`  ${version}`));
      setResult({ applied: [], pending: gap.pending.map((m) => m.file), unknown: gap.unknown });
      return 1;
    }

    const applied: string[] = [];
    const seeds: string[] = [];
    let moduleMigrations = 0;
    let schemaVersion: string | undefined;

    if (gap.pending.length === 0) {
      skipped('nothing to apply');
    } else {
      for (const migration of gap.pending) note(dim(`pending  ${migration.file}`));
      snapshotRecommendation();
      await applyMigrations(db, migrations, (migration) => {
        applied.push(migration.file);
        step(migration.file);
      });
    }

    if (modules.length > 0) {
      moduleMigrations = await applyModuleMigrations(db, modules, { heading: true });
    }

    if (!boolFlag(args, 'skip-seeds')) {
      heading('Reference data');
      await applySeeds(db, seedDir(), (seed) => {
        seeds.push(seed.file);
        step(seed.file);
      });
      note(dim('Seeds are idempotent; re-applying them adds what a new release added.'));
    }

    if (await schemaIsInstalled(db)) {
      const version = await syncSchemaVersion(db);
      schemaVersion = version;
      if (version !== undefined) {
        heading('Version');
        step(`instance.schema_version is now ${version}`);
      }
    }

    setResult({
      alreadyApplied: gap.applied.length,
      applied,
      moduleMigrations,
      seeds,
      schemaVersion: schemaVersion ?? null,
    });
    line();
    return 0;
  } finally {
    await db.close();
  }
}
