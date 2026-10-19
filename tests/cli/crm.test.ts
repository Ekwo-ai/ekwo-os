/**
 * `ekwo crm`: the crm module from a terminal.
 *
 * Each test runs the command as the signed-in owner, against a real Postgres
 * behind the instance's HTTP surface, and holds the one JSON document it
 * writes to the output contract. What the module decides is
 * `modules/crm/tests`; what is asked here is that the command line calls the
 * same functions as the MCP tools, names a contact by its name as well as by
 * its id, and carries the schema's refusals through word for word, on the
 * exit code of a refusal.
 */

import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { EXIT_REFUSED, EXIT_USAGE, run, validate, type OutputDocument } from '../../packages/cli/src/index.js';
import { asUser, freshDatabase, one, repoRoot, rows } from '../helpers/db.js';
import { newCompany, newUser } from '../helpers/factory.js';
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
let orgId: string;
let personId: string;
let pipelineId: string;
let stages: Record<string, string>;

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

async function contact(name: string, isCompany: boolean, parentId: string | null): Promise<string> {
  return (
    await one<{ id: string }>(
      pg,
      `insert into contacts (company_id, name, is_company, contact_type, parent_id)
       values ($1, $2, $3, 'other', $4) returning id`,
      [companyId, name, isCompany, parentId],
    )
  ).id;
}

beforeAll(async () => {
  schema = JSON.parse(await readFile(join(repoRoot, 'packages', 'cli', 'schema', 'output.1.json'), 'utf8')) as Row;
  pg = await freshDatabase();
  owner = await newUser(pg, 'owner@example.test');
  companyId = (await newCompany(pg, { name: 'Terminal Relations', ownerId: owner })).companyId;
  currency = (await one<{ currency_code: string }>(pg, `select currency_code from companies where id = $1`, [companyId]))
    .currency_code;
  orgId = await contact('Northwind Trading', true, null);
  personId = await contact('Ada Lovelace', false, orgId);
  await asUser(pg, owner, async () => {
    await pg.query(`select enable_module($1, 'crm')`, [companyId]);
    pipelineId = (
      await one<{ id: string }>(
        pg,
        `insert into crm.pipelines (company_id, name, slug) values ($1, 'Sales', 'sales') returning id`,
        [companyId],
      )
    ).id;
    const inserted = await rows<{ name: string; id: string }>(
      pg,
      `insert into crm.stages (company_id, pipeline_id, name, position, outcome) values
         ($1, $2, 'Lead', 1, 'open'), ($1, $2, 'Won', 2, 'won'), ($1, $2, 'Lost', 3, 'lost')
       returning name, id`,
      [companyId, pipelineId],
    );
    stages = Object.fromEntries(inserted.map((s) => [s.name, s.id]));
  });

  root = await mkdtemp(join(tmpdir(), 'ekwo-crm-'));
  instance = fakeSupabase(pg);
  instance.addUser(owner, 'owner@example.test', PASSWORD);
  expect(
    (await ekwo(['login', '--supabase-url', FAKE_URL, '--anon-key', ANON_KEY, '--email', 'owner@example.test', '--password', PASSWORD]))
      .exitCode,
  ).toBe(0);
  expect((await ekwo(['use', 'Terminal Relations'])).exitCode).toBe(0);
}, 300_000);

afterAll(async () => {
  await pg.close();
  await rm(root, { recursive: true, force: true });
});

describe('ekwo crm', () => {
  it('card set writes a card through upsert_card, naming the contact by its name', async () => {
    const set = await ekwo(['crm', 'card', 'set', 'Ada Lovelace', '--status', 'contacted', '--owner', 'sales', '--tag', 'fair', '--tag', 'event']);
    expect(set.command).toBe('crm card set');
    expect(set.exitCode).toBe(0);
    expect(set.data).toMatchObject({ card: { contact_id: personId, status: 'contacted', owner: 'sales', tags: ['fair', 'event'] } });
    expect((await ekwo(['crm', 'card', 'set', orgId, '--priority', 'high'])).exitCode).toBe(0);
  });

  it('search filters by text and by status', async () => {
    const byText = await ekwo(['crm', 'search', '--query', 'northwind']);
    expect(byText.command).toBe('crm search');
    expect((byText.data as { cards: { name: string }[] }).cards.map((c) => c.name).sort()).toEqual(['Ada Lovelace', 'Northwind Trading']);
    const byStatus = await ekwo(['crm', 'search', '--status', 'contacted']);
    expect(byStatus.data).toMatchObject({ count: 1, cards: [{ contact_id: personId, organisation_name: 'Northwind Trading' }] });
  });

  it('deal open, board and deal move: a won stage closes the deal and makes the organisation a customer', async () => {
    const opened = await ekwo(['crm', 'deal', 'open', pipelineId, 'Northwind Trading', '--title', 'Annual subscription', '--amount', '12000']);
    expect(opened.command).toBe('crm deal open');
    const deal = (opened.data as { deal: Row }).deal;
    expect(deal).toMatchObject({ stage_id: stages['Lead'], amount: '12000.00', currency_code: currency });

    const board = await ekwo(['crm', 'board', pipelineId]);
    expect(board.command).toBe('crm board');
    const [pipeline] = (board.data as { pipelines: Row[] }).pipelines;
    expect(pipeline).toMatchObject({ id: pipelineId, count: 1, totals: [{ currency_code: currency, amount: '12000.00', deals: 1 }] });

    const moved = await ekwo(['crm', 'deal', 'move', String(deal['id']), String(stages['Won'])]);
    expect(moved.command).toBe('crm deal move');
    expect(moved.data).toMatchObject({ deal: { closed_outcome: 'won' } });
    expect(await one(pg, `select contact_type from contacts where id = $1`, [orgId])).toEqual({ contact_type: 'customer' });

    const card = await ekwo(['crm', 'card', 'Northwind Trading']);
    expect(card.command).toBe('crm card');
    expect(card.data).toMatchObject({ contact: { id: orgId, contact_type: 'customer' }, deals: [] });
    const closed = await ekwo(['crm', 'board', '--closed']);
    expect((closed.data as { include_closed: boolean; pipelines: { count: number }[] })).toMatchObject({ include_closed: true, pipelines: [{ count: 1 }] });
  });

  it('log is idempotent on its source, and timeline reads it back by kind', async () => {
    const args = ['crm', 'log', 'Ada Lovelace', '--kind', 'email_in', '--subject', 'Re: the quote', '--source', 'mailbox', '--source-ref', '<reply@northwind.example>'];
    const first = await ekwo(args);
    const again = await ekwo(args);
    expect((again.data as { activity: Row }).activity['id']).toBe((first.data as { activity: Row }).activity['id']);
    const timeline = await ekwo(['crm', 'timeline', 'Ada Lovelace', '--kind', 'email_in']);
    expect(timeline.data).toMatchObject({ count: 1, activities: [{ kind: 'email_in', subject: 'Re: the quote' }] });
  });

  it('segments, join and leave', async () => {
    const segment = await asUser(pg, owner, () =>
      one<{ id: string }>(pg, `insert into crm.segments (company_id, kind, name, slug) values ($1, 'cohort', 'Fair 2026', 'fair-2026') returning id`, [companyId]),
    );
    expect((await ekwo(['crm', 'join', segment.id, 'Ada Lovelace'])).data).toMatchObject({ membership: { left_at: null } });
    expect((await ekwo(['crm', 'segments'])).data).toMatchObject({ count: 1, segments: [{ slug: 'fair-2026', members: 1 }] });
    expect((await ekwo(['crm', 'leave', segment.id, 'Ada Lovelace'])).exitCode).toBe(0);
    expect((await ekwo(['crm', 'segments'])).data).toMatchObject({ segments: [{ slug: 'fair-2026', members: 0 }] });
  });

  it('carries a refusal of the schema through by name, on the exit code of a refusal', async () => {
    const refused = await ekwo(['crm', 'deal', 'move', personId, String(stages['Lost'])]);
    expect(refused.exitCode).toBe(EXIT_REFUSED);
    expect(refused.error).toMatchObject({ kind: 'refusal', name: 'crm_unknown_deal' });
  });

  it('refuses a status the schema does not have, naming the ones it has', async () => {
    const bad = await ekwo(['crm', 'search', '--status', 'prospect']);
    expect(bad.exitCode).toBe(EXIT_USAGE);
    expect(bad.error?.message).toContain('in_discussion');
  });
});
