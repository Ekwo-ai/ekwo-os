/**
 * This release reads a project at the schema floor.
 *
 * `SCHEMA_MIN` is the oldest schema the packages read, and since 26 October
 * 2026 it is not the number of the release: it moves only when a migration is
 * breaking (`docs/releasing.md`, step 3). A number nobody checks is a number
 * written on faith, so this file builds the database a project at the floor
 * really has — the migrations, the modules and the seeds of the tag
 * `v<SCHEMA_MIN>`, taken from git, not reconstructed — and runs the packages
 * of this checkout against it:
 *
 * - every object `SCHEMA_FEATURES` names is missing there and present here,
 *   so the list says exactly what a project at the floor lacks;
 * - every function the core, the CLI and the MCP server call by name exists
 *   there, unless a feature names it;
 * - a first session over the MCP server — a contact, a draft, its lines
 *   replaced, the draft posted — works there, and every read-only tool
 *   answers without a column, a function or a table the schema lacks;
 * - what a feature brings is refused by name there, never by Postgres.
 *
 * A change that breaks one of those fails here. The fix is to name what it
 * reads in `SCHEMA_FEATURES`, or to raise the floor on purpose, to the version
 * of the migration that made it necessary.
 *
 * The tag has to be in the clone: the CI job `schema-floor` checks out the
 * full history. A shallow clone without it skips this file, unless
 * `EKWO_SCHEMA_FLOOR_REQUIRED` is set, in which case a missing tag fails it.
 */

import { execFileSync } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { mkdir, readFile, readdir, rename, rm, stat } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  SCHEMA_FEATURES,
  SCHEMA_MIN,
  approveDocument,
  columns,
  compareSchemaVersions,
  createApiKey,
  getCompany,
  setAgentPosting,
  supports,
  type SchemaFeature,
} from '../packages/core/src/index.js';
import { buildServer } from '../packages/mcp/src/index.js';
import { freshDatabase, one, repoRoot, rows } from './helpers/db.js';
import { DEMO_OWNER, demoCompanyId } from './helpers/factory.js';
import { backendFor } from './mcp/helpers.js';

const TAG = `v${SCHEMA_MIN}`;

/** Whether this clone has the tag of the floor. */
function hasTag(): boolean {
  try {
    execFileSync('git', ['rev-parse', '--verify', '--quiet', `${TAG}^{commit}`], { cwd: repoRoot, stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

const READY = hasTag();
if (!READY && process.env['EKWO_SCHEMA_FLOOR_REQUIRED'] !== undefined) {
  throw new Error(`schema_floor_tag_missing: ${TAG} is not in this clone. Fetch the tags (git fetch --tags) to prove the floor.`);
}

/**
 * The files of the tag a database is built from, extracted once per commit
 * and kept beside the schema images of the run.
 */
async function checkoutOfTheFloor(): Promise<string> {
  const commit = execFileSync('git', ['rev-parse', `${TAG}^{commit}`], { cwd: repoRoot, encoding: 'utf8' }).trim();
  const base = process.env['EKWO_TEST_SCHEMA_DIR'] ?? join(tmpdir(), 'ekwo-test-schema');
  const dir = join(base, `checkout-${TAG}-${commit.slice(0, 12)}`);
  if (await stat(dir).catch(() => undefined)) return dir;
  const partial = `${dir}.${process.pid}.${randomUUID()}`;
  await mkdir(partial, { recursive: true });
  const archive = execFileSync(
    'git',
    ['archive', '--format=tar', commit, 'supabase/migrations', 'supabase/seed', 'modules', 'tests/helpers/supabase-shim.sql'],
    { cwd: repoRoot, maxBuffer: 1 << 30 },
  );
  execFileSync('tar', ['-x', '-C', partial], { input: archive });
  // Two workers extracting at once both finish; the first rename wins and the
  // other copy is identical.
  await rename(partial, dir).catch(async () => rm(partial, { recursive: true, force: true }));
  return dir;
}

/** The name of every function the packages call by name, with the file it is called in. */
async function functionsCalled(): Promise<Map<string, string>> {
  const called = new Map<string, string>();
  const walk = async (dir: string): Promise<void> => {
    for (const entry of await readdir(dir, { withFileTypes: true })) {
      const path = join(dir, entry.name);
      if (entry.isDirectory()) await walk(path);
      else if (entry.name.endsWith('.ts')) {
        const source = await readFile(path, 'utf8');
        for (const match of source.matchAll(/\brpc(?:Void)?(?:<[^>()]*>)?\(\s*'([a-z_][a-z0-9_]*)'/g)) {
          if (!called.has(match[1] as string)) called.set(match[1] as string, path.slice(repoRoot.length + 1));
        }
      }
    }
  };
  for (const pkg of ['core', 'cli', 'mcp']) await walk(join(repoRoot, 'packages', pkg, 'src'));
  return called;
}

async function columnExists(db: PGlite, qualified: string): Promise<boolean> {
  const [table, column] = qualified.split('.');
  const found = await one<{ found: boolean }>(
    db,
    `select exists (select 1 from information_schema.columns
                     where table_schema in ('public', 'ekwo') and table_name = $1 and column_name = $2) as found`,
    [table, column],
  );
  return found.found;
}

async function functionExists(db: PGlite, name: string): Promise<boolean> {
  return (await one<{ found: boolean }>(db, `select exists (select 1 from pg_proc where proname = $1) as found`, [name])).found;
}

/** What Postgres says when a client asked for something this schema does not have. */
const MISSING_OBJECT = /\b(column|function|relation|table) [^\s]+ does not exist|\b(42703|42883|42P01|PGRST20[02])\b/;

const FEATURES = Object.entries(SCHEMA_FEATURES) as Array<[SchemaFeature, (typeof SCHEMA_FEATURES)[SchemaFeature]]>;

describe.runIf(READY)(`a project at the schema floor (${TAG})`, () => {
  let floor: PGlite;
  let current: PGlite;
  let client: Client;
  let companyId: string;

  beforeAll(async () => {
    floor = await freshDatabase({ root: await checkoutOfTheFloor() });
    current = await freshDatabase();
    companyId = await demoCompanyId(floor);
    const server = buildServer(backendFor(floor, DEMO_OWNER));
    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
    client = new Client({ name: 'schema-floor', version: '0.0.0' });
    await Promise.all([client.connect(clientTransport), server.connect(serverTransport)]);
  }, 600_000);

  afterAll(async () => {
    await client?.close();
    await floor?.close();
    await current?.close();
  });

  /** The answer of a tool, parsed, and whether it was a refusal. */
  async function call(name: string, args: Record<string, unknown>): Promise<{ isError: boolean; text: string; value: unknown }> {
    const answer = (await client.callTool({ name, arguments: args })) as {
      isError?: boolean;
      content: Array<{ type: string; text?: string }>;
    };
    const text = answer.content.map((c) => c.text ?? '').join('\n');
    let value: unknown = text;
    try {
      value = JSON.parse(text);
    } catch {
      // Prose, not JSON: kept as it is.
    }
    return { isError: answer.isError === true, text, value };
  }

  it('is the version the floor names', async () => {
    const at = await one<{ version: string }>(floor, `select ekwo_schema_version() as version`);
    expect(at.version).toBe(SCHEMA_MIN);
  });

  describe('SCHEMA_FEATURES', () => {
    it('names only what is newer than the floor', () => {
      for (const [feature, { since }] of FEATURES) {
        expect(compareSchemaVersions(since, SCHEMA_MIN), `${feature} since ${since}`).toBe(1);
        expect(supports(SCHEMA_MIN, feature)).toBe(false);
      }
    });

    it.each(FEATURES)('%s is missing at the floor and present in this release', async (_feature, objects) => {
      for (const column of objects.columns) {
        expect(await columnExists(floor, column), `${column} at the floor`).toBe(false);
        expect(await columnExists(current, column), `${column} in this release`).toBe(true);
      }
      for (const fn of objects.functions) {
        expect(await functionExists(floor, fn), `${fn}() at the floor`).toBe(false);
        expect(await functionExists(current, fn), `${fn}() in this release`).toBe(true);
      }
    });
  });

  it('has every function the packages call by name, but those of a feature', async () => {
    const ofAFeature = new Set<string>(FEATURES.flatMap(([, objects]) => [...objects.functions]));
    const missing: string[] = [];
    for (const [fn, file] of await functionsCalled()) {
      if (ofAFeature.has(fn)) continue;
      if (!(await functionExists(floor, fn))) missing.push(`${fn}() — ${file}`);
    }
    expect(missing, 'called by this release, absent at the floor and named by no feature').toEqual([]);
  });

  it('has every column the core reads by name, but those of a feature', async () => {
    // The lists of `columns.ts` are what the reads of the core ask for. Each
    // name has to be a column of some table or view at the floor; a name only
    // a newer schema has belongs to a feature, which `onSocle()` leaves out.
    const ofAFeature = new Set<string>(FEATURES.flatMap(([, objects]) => objects.columns.map((c) => c.split('.')[1] as string)));
    const atTheFloor = new Set(
      (await rows<{ name: string }>(floor, `select distinct column_name as name from information_schema.columns where table_schema in ('public', 'ekwo')`)).map(
        (r) => r.name,
      ),
    );
    const missing: string[] = [];
    for (const [list, names] of Object.entries(columns) as Array<[string, readonly string[]]>) {
      if (!Array.isArray(names)) continue;
      for (const entry of names) {
        const name = entry.split('::')[0] as string;
        if (!ofAFeature.has(name) && !atTheFloor.has(name)) missing.push(`${list}: ${name}`);
      }
    }
    expect(missing, 'read by this release, absent at the floor and named by no feature').toEqual([]);
  });

  describe('over the MCP server, as the owner of a company', () => {
    let contactId: string;
    let documentId: string;

    it('books a first invoice the way a first session does', async () => {
      const company = await call('get_company', { company_id: companyId });
      expect(company.isError, company.text).toBe(false);

      const accounts = await call('list_accounts', { company_id: companyId, include_all: true });
      expect(accounts.isError, accounts.text).toBe(false);

      const contact = await call('create_contact', { company_id: companyId, name: 'Floor Customer', contact_type: 'customer' });
      expect(contact.isError, contact.text).toBe(false);
      contactId = String((contact.value as { contact?: { id?: string }; id?: string }).contact?.id ?? (contact.value as { id?: string }).id);

      const product = await rows<{ code: string }>(floor, `select code from products where company_id = $1 and code is not null order by code limit 1`, [companyId]);
      const line = { product_code: product[0]?.code, quantity: 1 };

      // Below 0.21.0 there is no `create_document()`: the header and its lines
      // go in two statements, as they did at the floor.
      const draft = await call('create_document', {
        company_id: companyId,
        doc_type: 'sale_invoice',
        contact_id: contactId,
        document_date: '2026-03-15',
        lines: [line],
      });
      expect(draft.isError, draft.text).toBe(false);
      documentId = String((draft.value as { id?: string; document?: { id?: string } }).document?.id ?? (draft.value as { id?: string }).id);
      expect((await rows(floor, `select 1 from document_lines where document_id = $1`, [documentId])).length).toBe(1);

      // And no `replace_document_lines()` either.
      const replaced = await call('update_document_lines', { document_id: documentId, lines: [line, { ...line, quantity: 2 }] });
      expect(replaced.isError, replaced.text).toBe(false);
      expect((await rows(floor, `select 1 from document_lines where document_id = $1`, [documentId])).length).toBe(2);

      const posted = await call('post_document', { document_id: documentId });
      expect(posted.isError, posted.text).toBe(false);
      const state = await one<{ state: string }>(floor, `select state from documents where id = $1`, [documentId]);
      expect(state.state).toBe('posted');
    });

    it('answers every read-only tool without reaching for what the schema lacks', async () => {
      const entry = await rows<{ id: string; number: string | null }>(
        floor,
        `select id, entry_number::text as number from entries where company_id = $1 order by created_at limit 1`,
        [companyId],
      ).catch(() => rows<{ id: string; number: string | null }>(floor, `select id, null as number from entries where company_id = $1 limit 1`, [companyId]));
      const year = await rows<{ id: string; start_date: string; end_date: string }>(
        floor,
        `select id, start_date::text, end_date::text from fiscal_years where company_id = $1 order by start_date limit 1`,
        [companyId],
      );
      const known: Record<string, unknown> = {
        company_id: companyId,
        document_id: documentId,
        contact_id: contactId,
        entry_id: entry[0]?.id,
        fiscal_year_id: year[0]?.id,
        date_from: year[0]?.start_date,
        date_to: year[0]?.end_date,
        from: year[0]?.start_date,
        to: year[0]?.end_date,
        period_start: year[0]?.start_date,
        period_end: year[0]?.end_date,
      };

      const { tools } = await client.listTools();
      const reads = tools.filter((tool) => tool.annotations?.readOnlyHint === true);
      expect(reads.length).toBeGreaterThan(10);

      const answered: string[] = [];
      const reachedForMissing: string[] = [];
      for (const tool of reads) {
        const properties = (tool.inputSchema.properties ?? {}) as Record<string, unknown>;
        const args = Object.fromEntries(
          Object.keys(properties).filter((key) => known[key] !== undefined).map((key) => [key, known[key]]),
        );
        const answer = await call(tool.name, args);
        if (MISSING_OBJECT.test(answer.text)) reachedForMissing.push(`${tool.name}: ${answer.text.slice(0, 300)}`);
        else if (!answer.isError) answered.push(tool.name);
      }
      expect(reachedForMissing, 'read-only tools that asked the floor for something it does not have').toEqual([]);
      // The reads a project is opened with answer, not merely fail politely.
      expect(answered).toEqual(expect.arrayContaining(['list_companies', 'get_company', 'list_accounts', 'search_contacts', 'get_document']));
    });

    it('refuses what a newer schema brought by name, saying which version it needs', async () => {
      const backend = backendFor(floor, DEMO_OWNER);
      await expect(approveDocument(backend, { document_id: documentId })).rejects.toThrow(
        /^schema_too_old_for: approve_document\(\) needs schema 0\.21\.0 \(agent_posting\), and this database is at /,
      );
      await expect(setAgentPosting(backend, { company_id: companyId, agent_posting: 'review_only' })).rejects.toThrow(
        /^schema_too_old_for: writing companies\.agent_posting needs schema 0\.21\.0/,
      );
      await expect(
        createApiKey(backend, { company_id: companyId, name: 'floor', capabilities: ['books.read'], posting_mode: 'autopilot' }),
      ).rejects.toThrow(/^schema_too_old_for: a key in autopilot needs schema 0\.21\.0/);
    });

    it('reads a company without the setting the floor does not have', async () => {
      const company = (await getCompany(backendFor(floor, DEMO_OWNER), { company_id: companyId })) as { company: Record<string, unknown> };
      expect(company.company['id']).toBe(companyId);
      expect('agent_posting' in company.company).toBe(false);
    });
  });
});
