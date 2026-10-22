/**
 * `ekwo contracts`: the contracts module from a terminal.
 *
 * Each test runs the command as the signed-in owner, against a real Postgres
 * behind the instance's HTTP surface, and holds the one JSON document it
 * writes to the output contract. What the module decides is
 * `modules/contracts/tests`; what is asked here is that the command line
 * calls the same functions as the MCP tools, names a contract by its number
 * and a party by its name, and carries the schema's refusals through word for
 * word, on the exit code of a refusal.
 */

import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { EXIT_REFUSED, EXIT_USAGE, run, validate, type OutputDocument } from '../../packages/cli/src/index.js';
import { asUser, freshDatabase, one, repoRoot } from '../helpers/db.js';
import { newCompany, newContact, newUser } from '../helpers/factory.js';
import { ANON_KEY, FAKE_URL, fakeSupabase, type FakeSupabase } from './fake-supabase.js';

const PASSWORD = 'correct horse battery staple';

type Row = Record<string, unknown>;

let pg: PGlite;
let schema: Row;
let instance: FakeSupabase;
let root: string;
let companyId: string;
let owner: string;
let currency: string;
let taxCode: string;

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

/** Runs a command as the owner, under --json, and holds the answer to the schema. */
async function ekwo(argv: string[]): Promise<OutputDocument> {
  const captured = await capture(() =>
    run([...argv, '--json'], { fetchImpl: instance.fetchImpl, env: { EKWO_CONFIG_DIR: join(root, 'config') } }),
  );
  const document = JSON.parse(captured.stdout) as OutputDocument;
  expect(validate(document, schema)).toEqual([]);
  expect(document.exitCode).toBe(captured.exitCode);
  if (document.error === undefined) {
    const shape = ((schema['$defs'] as Record<string, Row>)['data'] ?? {})[document.command];
    expect(shape, `output.1.json describes no data for "${document.command}"`).toBeDefined();
    expect(validate(document.data, shape as Row, schema)).toEqual([]);
  }
  return document;
}

beforeAll(async () => {
  schema = JSON.parse(await readFile(join(repoRoot, 'packages', 'cli', 'schema', 'output.1.json'), 'utf8')) as Row;
  pg = await freshDatabase();
  owner = await newUser(pg, 'owner@example.test');
  companyId = (await newCompany(pg, { name: 'Terminal Contracts', ownerId: owner })).companyId;
  currency = (await one<{ currency_code: string }>(pg, `select currency_code from companies where id = $1`, [companyId]))
    .currency_code;
  await newContact(pg, companyId, { name: 'Northwind Trading', type: 'customer' });
  taxCode = (
    await one<{ code: string }>(
      pg,
      `select code from taxes where company_id = $1 and applies_to in ('sale', 'both') and amount_type = 'percent'
        order by amount desc, sequence, code limit 1`,
      [companyId],
    )
  ).code;
  await asUser(pg, owner, async () => {
    await pg.query(`select enable_module($1, 'contracts')`, [companyId]);
  });

  root = await mkdtemp(join(tmpdir(), 'ekwo-contracts-'));
  instance = fakeSupabase(pg);
  instance.addUser(owner, 'owner@example.test', PASSWORD);
  expect(
    (await ekwo(['login', '--supabase-url', FAKE_URL, '--anon-key', ANON_KEY, '--email', 'owner@example.test', '--password', PASSWORD]))
      .exitCode,
  ).toBe(0);
  expect((await ekwo(['use', 'Terminal Contracts'])).exitCode).toBe(0);
}, 300_000);

afterAll(async () => {
  await pg.close();
  await rm(root, { recursive: true, force: true });
});

describe('ekwo contracts', () => {
  it('set, schedule, issue, deadlines, card and amend, the contract named by its number', async () => {
    const set = await ekwo([
      'contracts', 'set', 'CTR-7', '--contact', 'Northwind Trading', '--name', 'Hosting', '--kind', 'subscription',
      '--direction', 'sale', '--state', 'active', '--starts', '2026-01-01', '--ends', '2026-12-31',
      '--renewal', 'tacit', '--notice-days', '30',
    ]);
    expect(set.command).toBe('contracts set');
    const contract = (set.data as { contract: Row }).contract;
    expect(contract).toMatchObject({ number: 'CTR-7', currency_code: currency, renewal: 'tacit' });
    // A tacit renewal starts the day after the end; the day is read as the test double serialises it.
    expect(String(contract['renews_on'])).toMatch(/^2027-01-01/);

    const scheduled = await ekwo([
      'contracts', 'schedule', 'CTR-7', '--name', 'Hosting', '--price', '90', '--tax', taxCode,
      '--frequency', 'monthly', '--next', '2026-01-01',
    ]);
    expect(scheduled.command).toBe('contracts schedule');
    expect(scheduled.data).toMatchObject({ schedule: { name: 'Hosting', tax_code: taxCode } });

    const issued = await ekwo(['contracts', 'issue', '--on', '2026-03-01']);
    expect(issued.command).toBe('contracts issue');
    expect(issued.data).toMatchObject({ count: 3, on_date: '2026-03-01' });
    expect((await ekwo(['contracts', 'issue', '--on', '2026-03-01'])).data).toMatchObject({ count: 0 });

    const deadlines = await ekwo(['contracts', 'deadlines', '--kind', 'notice']);
    expect(deadlines.command).toBe('contracts deadlines');
    expect(deadlines.data).toMatchObject({ count: 1, deadlines: [{ contract_number: 'CTR-7', due_on: '2026-12-02' }] });

    const card = await ekwo(['contracts', 'card', 'CTR-7']);
    expect(card.command).toBe('contracts card');
    expect((card.data as { issues: unknown[] }).issues).toHaveLength(3);

    const amended = await ekwo(['contracts', 'amend', 'CTR-7', '--summary', 'More notice', '--from', '2026-03-01', '--changes', '{"notice_days": 60}']);
    expect(amended.command).toBe('contracts amend');
    expect(amended.data).toMatchObject({ amendment: { number: 1, kind: 'amendment' } });

    const listed = await ekwo(['contracts', 'list', '--templates']);
    expect(listed.command).toBe('contracts list');
    expect(listed.data).toMatchObject({ count: 1, contracts: [{ number: 'CTR-7' }], templates: [] });
  });

  it('from-template makes a draft, with the values given as key=value', async () => {
    const template = await asUser(pg, owner, () =>
      one<{ id: string }>(
        pg,
        `insert into contracts.templates (company_id, name, format, html, variables)
         values ($1, 'Licence', 'html', '<p>{{buyer}}</p>', '[{"key": "buyer", "label": "Buyer", "required": true}]') returning id`,
        [companyId],
      ),
    );
    const made = await ekwo([
      'contracts', 'from-template', template.id, 'Northwind Trading', '--number', 'CTR-8', '--direction', 'sale',
      '--kind', 'licence', '--starts', '2026-06-01', '--value', 'buyer=Northwind Trading',
    ]);
    expect(made.command).toBe('contracts from-template');
    expect(made.data).toMatchObject({ html: '<p>Northwind Trading</p>', contract: { number: 'CTR-8', state: 'draft' } });
  });

  it('carries a refusal of the schema through by name, on the exit code of a refusal', async () => {
    const refused = await ekwo(['contracts', 'set', 'CTR-7', '--state', 'draft']);
    expect(refused.exitCode).toBe(EXIT_REFUSED);
    expect(refused.error).toMatchObject({ kind: 'refusal', name: 'contracts_state_backwards' });
  });

  it('refuses a kind the schema does not have, naming the ones it has', async () => {
    const bad = await ekwo(['contracts', 'set', 'CTR-9', '--kind', 'lease']);
    expect(bad.exitCode).toBe(EXIT_USAGE);
    expect(bad.error?.message).toContain('subscription');
  });
});
