/**
 * `ekwo company` — one company leaves an installation, and arrives in another.
 *
 *   ekwo company export <company> --out <dir>   write the archive of one company
 *   ekwo company import <dir>                   take an archive into this installation
 *
 * The archive is a directory: `manifest.json`, and one `data/<schema>.<table>.jsonl`
 * per table, one row per line. `docs/company-archive.md` is the format, and it
 * is written to be read without this CLI.
 *
 * **Exporting runs as a person, under row level security.** The connection the
 * CLI holds belongs to the owner of the database, for whom every company is
 * readable at once — which is exactly what `export_company_table()` refuses.
 * So the export happens inside one transaction that steps down to
 * `authenticated` and carries the claim of the member it acts for, the way
 * PostgREST would have: the schema judges that person, and the snapshot is one
 * snapshot, so the manifest and the rows cannot disagree.
 *
 * **The rows are never parsed here.** They are written as the database wrote
 * them and read back the same way, because a JSON parser that meets `1.50`
 * inside a jsonb column hands back `1.5`, and the checksum of a table is the
 * checksum of its bytes.
 *
 * **Importing is one call.** The files are checked against the manifest first —
 * a file damaged on the way is a finding of this CLI, not a refusal of the
 * books — then handed whole to `import_company()`, which takes all of it or
 * none of it.
 */

import { createHash } from 'node:crypto';
import { mkdir, readFile, readdir, writeFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import { rejectUnknownFlags, stringFlag, UsageError, type ParsedArgs } from '../args.js';
import { CONNECTION_FLAGS, openDatabase, type CommandDeps } from '../context.js';
import { setResult } from '../output.js';
import { isInteractive } from '../prompt.js';
import { asUser, first, type SqlClient } from '../sql.js';
import { bold, dim, heading, line, note, pairs, step, warn } from '../ui.js';

export const COMPANY_FLAGS = [...CONNECTION_FLAGS, 'out', 'as-user', 'owner', 'yes'] as const;

/** `public.accounts`. What a table of an archive may be called, and nothing else. */
const TABLE_NAME = /^[a-z_][a-z0-9_]*\.[a-z_][a-z0-9_]*$/;

export interface ArchiveTable {
  name: string;
  file: string;
  rows: number;
  sha256: string;
}

export interface ArchiveManifest {
  format: string;
  format_version: number;
  company: { id: string; name: string };
  tables: ArchiveTable[];
  files?: { transported: boolean; list: unknown[] };
  [key: string]: unknown;
}

export async function companyCommand(args: ParsedArgs, deps: CommandDeps = {}): Promise<number> {
  rejectUnknownFlags(args, COMPANY_FLAGS);
  const action = args.positional[0];

  if (action === undefined) throw new UsageError(`name a subcommand\n${usage()}`);
  if (action === 'help') {
    line(usage());
    return 0;
  }
  if (action !== 'export' && action !== 'import') {
    throw new UsageError(`unknown subcommand: company ${action}\n${usage()}`);
  }

  const { db } = await openDatabase(args, { interactive: isInteractive(), connect: deps.connect });
  try {
    return action === 'export' ? await exportCommand(db, args) : await importCommand(db, args);
  } finally {
    await db.close();
  }
}

// -------------------------------------------------------------------- export

async function exportCommand(db: SqlClient, args: ParsedArgs): Promise<number> {
  const given = args.positional[1];
  const out = stringFlag(args, 'out');
  if (out === undefined) throw new UsageError(`--out <dir> is required: where the archive is written\n${usage()}`);

  const company = await resolveCompany(db, given);
  const actor = await resolveExporter(db, stringFlag(args, 'as-user'), company.id);

  const dir = resolve(out);
  const held = await readdir(dir).catch(() => [] as string[]);
  if (held.length > 0) {
    throw new UsageError(`directory_not_empty: ${dir} holds ${held.length} entries. An archive is written into an empty directory.`);
  }
  await mkdir(join(dir, 'data'), { recursive: true });

  heading(`Exporting ${company.name}`);
  note(dim(`as ${actor}, under row level security`));

  const written = await db.transaction(async (tx) => {
    // One snapshot for the manifest and for every table.
    await tx.exec('set transaction isolation level repeatable read');
    await tx.query(`select set_config('request.jwt.claims', $1, true), set_config('ekwo.installing', '', true)`, [
      JSON.stringify({ sub: actor, role: 'authenticated' }),
    ]);
    await tx.exec('set local role authenticated');

    // The act goes on the trail of the company before anything is read, so the
    // trail the archive carries says it too.
    await tx.query(`select note_company_export($1)`, [company.id]);

    const row = await first<{ manifest: string }>(
      tx,
      `select export_company_manifest($1)::text as manifest`,
      [company.id],
    );
    if (row === undefined) throw new Error('export_company_manifest() answered nothing');
    const manifest = JSON.parse(row.manifest) as ArchiveManifest;

    let rowCount = 0;
    for (const table of manifest.tables) {
      if (!TABLE_NAME.test(table.name)) throw new Error(`archive_corrupt: ${table.name} is not the name of a table`);
      const rows = await tx.query<{ row: string }>(
        `select r::text as row from export_company_table($1, $2) as r`,
        [company.id, table.name],
      );
      const body = rows.map((r) => `${r.row}\n`).join('');
      // The database counted and hashed the same rows in the same snapshot. A
      // difference is a bug of this CLI or of the driver, and the archive is
      // not one to keep.
      if (rows.length !== table.rows || sha256(body) !== table.sha256) {
        throw new Error(`archive_corrupt: ${table.name} was read as ${rows.length} rows that do not match the manifest`);
      }
      await writeFile(join(dir, 'data', `${table.name}.jsonl`), body, 'utf8');
      rowCount += rows.length;
      if (rows.length > 0) step(`${table.name} ${dim(`${rows.length} rows`)}`);
    }
    await writeFile(join(dir, 'manifest.json'), `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');
    return { manifest, total: rowCount };
  });

  const files = written.manifest.files?.list.length ?? 0;
  line();
  pairs([
    ['archive', dir],
    ['tables', String(written.manifest.tables.length)],
    ['rows', String(written.total)],
    ['files listed', `${files}, not carried`],
  ]);
  if (files > 0) {
    warn(`${files} attachment file(s) are listed in manifest.json and are not in the archive: carry them from the storage bucket, by their path.`);
  }
  setResult({
    company: { id: company.id, name: company.name },
    actingAs: actor,
    out: dir,
    tables: written.manifest.tables.length,
    rows: written.total,
    files: { listed: files, transported: false },
  });
  line();
  return 0;
}

// -------------------------------------------------------------------- import

/** Reads an archive directory, checks it against its manifest, and returns it as one JSON text. */
export async function readArchive(dir: string): Promise<{ manifest: ArchiveManifest; text: string; rows: number }> {
  let manifestText: string;
  try {
    manifestText = await readFile(join(dir, 'manifest.json'), 'utf8');
  } catch {
    throw new UsageError(`not_an_archive: ${dir} holds no manifest.json`);
  }
  const manifest = JSON.parse(manifestText) as ArchiveManifest;
  if (manifest.format !== 'ekwo.company-archive' || !Array.isArray(manifest.tables)) {
    throw new UsageError(`not_an_archive: ${join(dir, 'manifest.json')} does not say it is an ekwo.company-archive`);
  }

  const parts: string[] = [];
  let rowCount = 0;
  for (const table of manifest.tables) {
    // The name is what locates the file; `file` is there for a reader, and a
    // path an archive chose is not one to open.
    if (!TABLE_NAME.test(table.name)) throw new Error(`archive_corrupt: ${table.name} is not the name of a table`);
    const body = await readFile(join(dir, 'data', `${table.name}.jsonl`), 'utf8').catch(() => undefined);
    if (body === undefined) throw new Error(`archive_corrupt: data/${table.name}.jsonl is listed in the manifest and missing`);
    if (sha256(body) !== table.sha256) {
      throw new Error(`archive_corrupt: data/${table.name}.jsonl does not have the checksum its manifest gives`);
    }
    const lines = body.split('\n').filter((l) => l.length > 0);
    if (lines.length !== table.rows) {
      throw new Error(`archive_corrupt: data/${table.name}.jsonl holds ${lines.length} rows and its manifest says ${table.rows}`);
    }
    rowCount += lines.length;
    parts.push(`${JSON.stringify(table.name)}:[${lines.join(',')}]`);
  }
  return { manifest, text: `{"manifest":${manifestText},"tables":{${parts.join(',')}}}`, rows: rowCount };
}

async function importCommand(db: SqlClient, args: ParsedArgs): Promise<number> {
  const given = args.positional[1];
  if (given === undefined) throw new UsageError(`name the directory of the archive\n${usage()}`);
  const dir = resolve(given);
  const actor = stringFlag(args, 'as-user');
  const owner = stringFlag(args, 'owner') ?? actor;

  const archive = await readArchive(dir);
  heading(`Importing ${archive.manifest.company.name}`);
  note(dim(`${archive.manifest.tables.length} tables, ${archive.rows} rows, checked against the manifest`));

  const call = async (): Promise<Record<string, unknown>> => {
    const row = await first<{ result: string }>(
      db,
      `select import_company($1::jsonb, $2)::text as result`,
      [archive.text, owner ?? null],
    );
    if (row === undefined) throw new Error('import_company() answered nothing');
    return JSON.parse(row.result) as Record<string, unknown>;
  };
  // Without --as-user this connection is the installer, which is one of the
  // two callers `import_company()` admits. With it, the schema judges that
  // person: an administrator of the installation, or a refusal.
  const result = actor === undefined ? await call() : await asUser(db, actor, call);

  const files = count(result['files_to_carry']);
  step(`${archive.manifest.company.name} is a company of this installation`);
  line();
  pairs([
    ['company', String(result['company_id'])],
    ['rows', String(result['rows'])],
    ['owner', owner ?? 'nobody yet'],
    ['files to carry', String(files)],
  ]);
  if (owner === undefined) {
    warn('No owner was named (--owner <uuid>): the company has no member yet. An administrator of the installation invites the first one.');
  }
  if (files > 0) {
    warn(`${files} attachment file(s) are listed in manifest.json and did not travel: copy them into the storage bucket under the same paths.`);
  }
  setResult({
    company: { id: String(result['company_id']), name: archive.manifest.company.name },
    rows: count(result['rows']),
    owner: owner ?? null,
    tables: result['tables'],
    files: { toCarry: files },
  });
  line();
  return 0;
}

// ------------------------------------------------------------------- helpers

/**
 * A count the database answered, as the JSON already carries it. Nothing is
 * converted here: a count that did not arrive as a number is no count.
 */
function count(value: unknown): number {
  return typeof value === 'number' ? value : 0;
}

function sha256(text: string): string {
  return createHash('sha256').update(text, 'utf8').digest('hex');
}

async function resolveCompany(db: SqlClient, given: string | undefined): Promise<{ id: string; name: string }> {
  const companies = await db.query<{ id: string; name: string }>(`select id, name from companies order by name`);
  if (given !== undefined) {
    const match = companies.find((c) => c.id === given || c.name === given);
    if (match === undefined) {
      throw new UsageError(
        `unknown company: ${given}. This installation holds: ${companies.map((c) => c.name).join(', ') || 'none'}`,
      );
    }
    return match;
  }
  const only = companies[0];
  if (companies.length !== 1 || only === undefined) {
    throw new UsageError(
      `name the company: this installation holds ${companies.length} — ` +
        companies.map((c) => `${c.name} (${c.id})`).join(', '),
    );
  }
  return only;
}

/**
 * Who the export is signed by: whoever `--as-user` names, or a member who
 * holds `company.export`, owners first. Nobody is invented — an archive says
 * who took it, and the audit trail of the company says it too.
 *
 * Read from the tables: `member_capabilities()` answers about somebody else
 * only to a member who manages the others, and this connection is nobody. It
 * is a guess at whom to act for; the judgement is `has_capability()`'s, inside
 * the export.
 */
async function resolveExporter(db: SqlClient, given: string | undefined, companyId: string): Promise<string> {
  if (given !== undefined) return given;
  const member = await first<{ user_id: string }>(
    db,
    `select m.user_id
       from company_members m
      where m.company_id = $1
        and not ('company.export' = any (m.capabilities_revoked))
        and ('company.export' = any (m.capabilities_granted)
             or exists (select 1 from role_capabilities rc
                         where rc.role = m.role and rc.capability = 'company.export'))
      order by (m.role = 'owner') desc, m.created_at
      limit 1`,
    [companyId],
  );
  if (member === undefined) {
    throw new Error(`no_exporter: no member of company ${companyId} holds company.export. Pass --as-user <uuid>.`);
  }
  return member.user_id;
}

function usage(): string {
  return `${bold('ekwo company')} — one company leaves an installation, and arrives in another.

  ekwo company export <company> --out <dir>   Write the archive of one company: manifest.json
                                              and one data/<table>.jsonl per table.
  ekwo company import <dir>                   Take an archive into this installation, whole or
                                              not at all. A company already here is refused.

  --out <dir>        Where the archive is written. Empty, or not there yet.
  --as-user <uuid>   export: the member the archive is read as, under row level security.
                     Defaults to an owner of the company. Needs company.export.
                     import: the administrator of the installation to act for. Defaults to
                     the installer, which this connection is.
  --owner <uuid>     import: who becomes the first owner. Members do not travel.
                     Defaults to --as-user.

  The files the attachments point at are listed in manifest.json and are not carried.
`;
}
