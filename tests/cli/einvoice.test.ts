/**
 * `ekwo einvoice`: the electronic invoice of a posted sale, from a terminal.
 *
 * Each test runs the command as a signed-in accountant, against a real
 * Postgres behind the instance's two HTTP surfaces, and holds the one JSON
 * document it writes to the output contract. What the module decides — the
 * format, the rules, the states — is `modules/einvoicing/tests`; what is
 * asked here is that the command line carries it through word for word, ends
 * on the exit code the contract gives, and sends only where it was told to.
 */

import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { EXIT_ERROR, EXIT_REFUSED, EXIT_USAGE, run, validate, type OutputDocument } from '../../packages/cli/src/index.js';
import { freshDatabase, one, repoRoot } from '../helpers/db.js';
import { packIssuing, packWithoutBrick, sale, seller, type Seller } from '../../modules/einvoicing/tests/helpers.js';
import { ANON_KEY, FAKE_URL, fakeSupabase, type FakeSupabase } from './fake-supabase.js';

const PASSWORD = 'correct horse battery staple';

type Row = Record<string, unknown>;

let pg: PGlite;
let schema: Row;
let instance: FakeSupabase;
let root: string;
let s: Seller;

async function capture(fn: () => Promise<number>): Promise<{ exitCode: number; stdout: string; stderr: string }> {
  const out = process.stdout.write.bind(process.stdout);
  const err = process.stderr.write.bind(process.stderr);
  let stdout = '';
  let stderr = '';
  process.stdout.write = ((chunk: string | Uint8Array) => ((stdout += String(chunk)), true)) as typeof process.stdout.write;
  process.stderr.write = ((chunk: string | Uint8Array) => ((stderr += String(chunk)), true)) as typeof process.stderr.write;
  try {
    return { exitCode: await fn(), stdout, stderr };
  } finally {
    process.stdout.write = out;
    process.stderr.write = err;
  }
}

/** Runs a command as the accountant, under --json, and holds the answer to the schema. */
async function ekwo(argv: string[], env: Record<string, string> = {}): Promise<OutputDocument> {
  const captured = await capture(() =>
    run([...argv, '--json'], { fetchImpl: instance.fetchImpl, env: { EKWO_CONFIG_DIR: join(root, 'config'), ...env } }),
  );
  const document = JSON.parse(captured.stdout) as OutputDocument;
  expect(validate(document, schema)).toEqual([]);
  expect(document.exitCode).toBe(captured.exitCode);
  if (document.data !== undefined) {
    const shape = ((schema['$defs'] as Record<string, Row>)['data'] ?? {})[document.command];
    expect(shape, `output.1.json describes no data for "${document.command}"`).toBeDefined();
    expect(validate(document.data, shape as Row, schema)).toEqual([]);
  }
  return document;
}

const numberOf = async (documentId: string): Promise<string> =>
  (await one<{ number: string }>(pg, `select number from documents where id = $1`, [documentId])).number;

beforeAll(async () => {
  schema = JSON.parse(await readFile(join(repoRoot, 'packages', 'cli', 'schema', 'output.1.json'), 'utf8')) as Row;
  pg = await freshDatabase();
  s = await seller(pg, packIssuing('peppol-bis-3'), 'Terminal Seller');
  root = await mkdtemp(join(tmpdir(), 'ekwo-einvoice-'));
  instance = fakeSupabase(pg);
  const email = (await one<{ email: string }>(pg, `select email from auth.users where id = $1`, [s.accountantId])).email;
  instance.addUser(s.accountantId, email, PASSWORD);
  expect(
    (await ekwo(['login', '--supabase-url', FAKE_URL, '--anon-key', ANON_KEY, '--email', email, '--password', PASSWORD])).exitCode,
  ).toBe(0);
  expect((await ekwo(['use', 'Terminal Seller'])).exitCode).toBe(0);
}, 300_000);

afterAll(async () => {
  await pg.close();
  await rm(root, { recursive: true, force: true });
});

describe('ekwo einvoice', () => {
  it('validate writes the file, says it breaks nothing, records nothing, and writes it where --out says', async () => {
    const documentId = await sale(pg, s);
    const out = join(root, 'checked.xml');
    const checked = await ekwo(['einvoice', 'validate', await numberOf(documentId), '--out', out]);
    expect(checked.exitCode).toBe(0);
    expect(checked.data).toMatchObject({ document_id: documentId, profile: 'peppol-bis-3', violations: [], sendable: true, written_to: out });
    expect((checked.data as Row)['file']).toBeUndefined();
    expect(await readFile(out, 'utf8')).toContain('<Invoice ');
    expect(await one(pg, `select count(*)::int as n from einvoicing.issues where document_id = $1`, [documentId])).toEqual({ n: 0 });
  });

  it('a file that breaks a rule is a check that found something: exit 1, the rules in the document', async () => {
    const documentId = await sale(pg, s, { contactId: s.unreachableId });
    const checked = await ekwo(['einvoice', 'validate', documentId]);
    expect(checked.exitCode).toBe(EXIT_ERROR);
    expect(checked.error).toBeUndefined();
    expect((checked.data as { violations: { code: string }[] }).violations.map((v) => v.code)).toContain('PEPPOL-EN16931-R010');

    // Kept all the same, and refused at the door by the database: exit 3, by name.
    expect((await ekwo(['einvoice', 'issue', documentId])).exitCode).toBe(EXIT_ERROR);
    const refused = await ekwo(['einvoice', 'issue', documentId, '--send', '--to', join(root, 'never')]);
    expect(refused.exitCode).toBe(EXIT_REFUSED);
    expect(refused.error).toMatchObject({ kind: 'refusal', name: 'einvoice_not_sendable' });
    expect(refused.error?.message).toContain('PEPPOL-EN16931-R010');
  });

  it('issue --send --to writes it to the folder, status --refresh reads the receipt, list shows the sending', async () => {
    const documentId = await sale(pg, s);
    const folder = join(root, 'outgoing');
    const number = await numberOf(documentId);

    // Kept first, sent after: the same file is the same issue.
    const kept = await ekwo(['einvoice', 'issue', number]);
    expect(kept.exitCode).toBe(0);
    expect(kept.data).toMatchObject({ transmission: null, sendable: true });

    const sent = await ekwo(['einvoice', 'issue', number, '--send', '--to', folder]);
    expect(sent.exitCode).toBe(0);
    const data = sent.data as { issue: Row; transmission: Row };
    expect(data.issue['id']).toBe((kept.data as { issue: Row }).issue['id']);
    expect(data.transmission).toMatchObject({ state: 'submitted', channel: 'self', service: null });
    const reference = String(data.transmission['reference']);
    expect(await readFile(join(folder, reference), 'utf8')).toContain(number);

    // Sent again while on its way: the database says no, and nothing leaves twice.
    const twice = await ekwo(['einvoice', 'issue', number, '--send', '--to', folder]);
    expect(twice.exitCode).toBe(EXIT_REFUSED);
    expect(twice.error?.name).toBe('einvoice_already_sent');

    const words = 'Delivered to the buyer’s access point — «OK»';
    await writeFile(join(folder, `${reference}.delivered`), words);
    // The folder, from the environment this time.
    const followed = await ekwo(['einvoice', 'status', number, '--refresh'], { EKWO_EINVOICE_DIRECTORY: folder });
    expect(followed.exitCode).toBe(0);
    expect(followed.data).toMatchObject({ state: 'delivered' });
    const events = ((followed.data as { transmissions: { events: Row[] }[] }).transmissions[0]?.events ?? []).map((e) => e['message']);
    expect(events).toContain(words);

    const listed = await ekwo(['einvoice', 'list', '--doc', number]);
    expect(listed.data).toMatchObject({ count: 1, transmissions: [{ state: 'delivered', reference }] });
    expect((await ekwo(['einvoice', 'list', '--state', 'rejected', '--doc', number])).data).toMatchObject({ count: 0 });
  });

  it('is called wrong without a verb, with --to and no --send, and with a state that does not exist', async () => {
    expect((await ekwo(['einvoice'])).exitCode).toBe(EXIT_USAGE);
    const documentId = await sale(pg, s);
    const stray = await ekwo(['einvoice', 'issue', documentId, '--to', join(root, 'stray')]);
    expect(stray.exitCode).toBe(EXIT_USAGE);
    expect(stray.error?.name).toBe('bad_flags');
    expect((await ekwo(['einvoice', 'list', '--state', 'lost'])).error?.name).toBe('bad_value');
    // Sending with nowhere to send to is refused before anything is recorded.
    const nowhere = await ekwo(['einvoice', 'issue', documentId, '--send']);
    expect(nowhere.error?.name).toBe('no_transport');
    expect(await one(pg, `select count(*)::int as n from einvoicing.issues where document_id = $1`, [documentId])).toEqual({ n: 0 });
  });

  it('names a profile no brick writes, and writes nothing in its place', async () => {
    const other = await seller(pg, packWithoutBrick(), 'Unwritten Seller');
    const email = (await one<{ email: string }>(pg, `select email from auth.users where id = $1`, [other.accountantId])).email;
    instance.addUser(other.accountantId, email, PASSWORD);
    const env = { EKWO_EMAIL: email, EKWO_PASSWORD: PASSWORD, SUPABASE_URL: FAKE_URL, SUPABASE_ANON_KEY: ANON_KEY };
    const refused = await ekwo(['einvoice', 'validate', await sale(pg, other), '--company', 'Unwritten Seller'], env);
    expect(refused.error?.name).toBe('format_without_brick');
    expect(refused.error?.message).toContain(String(other.pack.documents.einvoice_profile));
  });
});
