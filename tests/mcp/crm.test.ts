/**
 * The crm tools, over the protocol and against the real schema.
 *
 * What the module decides — a card's fields, a merge, who may write — is
 * `modules/crm/tests`. What is asked here is that a model reaches it whole:
 * the toolset is offered only where `public.modules` carries the module, each
 * tool calls its function and hands back what the function returned, and a
 * refusal of the schema reaches the model under its own name. The currency is
 * the company's, read and never named.
 */

import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { buildServer, installedModules, type Backend } from '../../packages/mcp/src/index.js';
import { asUser, freshDatabase, one, rows } from '../helpers/db.js';
import { newCompany } from '../helpers/factory.js';
import { backendFor, record } from './helpers.js';

let db: PGlite;
let backend: Backend;
let companyId: string;
let ownerId: string;
let currency: string;
let orgId: string;
let personId: string;
let pipelineId: string;
let stages: Record<string, string>;
let segmentId: string;
let client: Client;

async function connect(modules: readonly string[]): Promise<Client> {
  const next = new Client({ name: 'test', version: '0' });
  const [a, b] = InMemoryTransport.createLinkedPair();
  await Promise.all([buildServer(backend, { modules }).connect(b), next.connect(a)]);
  return next;
}

async function call(name: string, args: Record<string, unknown>): Promise<Record<string, unknown>> {
  const result = (await client.callTool({ name, arguments: args })) as {
    isError?: boolean;
    content: { text: string }[];
  };
  const text = result.content[0]?.text ?? '';
  if (result.isError === true) throw new Error(text);
  return record(JSON.parse(text));
}

async function contact(name: string, isCompany: boolean, parentId: string | null, email: string | null): Promise<string> {
  return (
    await one<{ id: string }>(
      db,
      `insert into contacts (company_id, name, is_company, contact_type, parent_id, email)
       values ($1, $2, $3, 'other', $4, $5) returning id`,
      [companyId, name, isCompany, parentId, email],
    )
  ).id;
}

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { name: 'Relations Outils' }));
  currency = (await one<{ currency_code: string }>(db, `select currency_code from companies where id = $1`, [companyId]))
    .currency_code;
  orgId = await contact('Northwind Trading', true, null, null);
  personId = await contact('Ada Lovelace', false, orgId, 'ada@northwind.example');

  await asUser(db, ownerId, async () => {
    await db.query(`select enable_module($1, 'crm')`, [companyId]);
    pipelineId = (
      await one<{ id: string }>(
        db,
        `insert into crm.pipelines (company_id, name, slug) values ($1, 'Sales', 'sales') returning id`,
        [companyId],
      )
    ).id;
    const inserted = await rows<{ name: string; id: string }>(
      db,
      `insert into crm.stages (company_id, pipeline_id, name, position, outcome) values
         ($1, $2, 'Lead', 1, 'open'), ($1, $2, 'Proposal', 2, 'open'),
         ($1, $2, 'Won', 3, 'won'), ($1, $2, 'Lost', 4, 'lost')
       returning name, id`,
      [companyId, pipelineId],
    );
    stages = Object.fromEntries(inserted.map((s) => [s.name, s.id]));
    const parent = await one<{ id: string }>(
      db,
      `insert into crm.segments (company_id, kind, name, slug) values ($1, 'taxonomy', 'Trade', 'trade') returning id`,
      [companyId],
    );
    segmentId = (
      await one<{ id: string }>(
        db,
        `insert into crm.segments (company_id, parent_id, kind, name, slug)
         values ($1, $2, 'segment', 'Retail', 'retail') returning id`,
        [companyId, parent.id],
      )
    ).id;
  });

  backend = backendFor(db, ownerId);
  client = await connect(['crm']);
});

afterAll(async () => {
  await client.close();
  await db.close();
});

describe('the crm toolset', () => {
  it('is offered where public.modules carries crm, under its prefix, and not otherwise', async () => {
    expect(await installedModules(backend)).toContain('crm');
    const names = (await client.listTools()).tools.map((tool) => tool.name);
    expect(names.filter((name) => name.startsWith('crm_')).length).toBe(11);
    expect(names.filter((name) => name.startsWith('crm_') === false && /^crm/.test(name))).toEqual([]);
    expect((await client.listPrompts()).prompts.map((p) => p.name)).toContain('crm_morning_review');

    const without = await connect(['budgets']);
    const offered = (await without.listTools()).tools.map((tool) => tool.name);
    expect(offered.filter((name) => name.startsWith('crm_'))).toEqual([]);
    await without.close();
  });

  it('carries a relationship from a first card to a won deal, and the contact becomes a customer', async () => {
    const card = await call('crm_upsert_card', {
      company_id: companyId,
      contact_id: personId,
      patch: { status: 'contacted', owner: 'sales-desk', tags: ['fair'] },
    });
    expect(card['card']).toMatchObject({ status: 'contacted', owner: 'sales-desk', tags: ['fair'] });
    await call('crm_upsert_card', { company_id: companyId, contact_id: orgId, patch: { priority: 'high' } });

    const joined = await call('crm_join_segment', {
      company_id: companyId,
      segment_id: segmentId,
      contact_id: personId,
      added_by: 'sales-desk',
    });
    expect(joined['membership']).toMatchObject({ segment_id: segmentId, contact_id: personId, left_at: null });

    const opened = await call('crm_open_deal', {
      company_id: companyId,
      pipeline_id: pipelineId,
      contact_id: orgId,
      title: 'Annual subscription',
      amount: 12000,
    });
    const deal = opened['deal'] as Record<string, unknown>;
    // The first open stage, in the company's own currency, the amount a decimal string.
    expect(deal).toMatchObject({ stage_id: stages['Lead'], amount: '12000.00', currency_code: currency, closed_at: null });

    const board = await call('crm_board', { company_id: companyId, pipeline_id: pipelineId });
    const [pipeline] = board['pipelines'] as Record<string, unknown>[];
    const lead = ((pipeline?.['stages'] ?? []) as Record<string, unknown>[])[0];
    expect(lead).toMatchObject({
      name: 'Lead',
      count: 1,
      totals: [{ currency_code: currency, amount: '12000.00', deals: 1 }],
    });
    expect(pipeline?.['totals']).toEqual([{ currency_code: currency, amount: '12000.00', deals: 1 }]);

    const moved = await call('crm_move_deal', { company_id: companyId, deal_id: deal['id'], stage_id: stages['Won'] });
    expect(moved['deal']).toMatchObject({ stage_id: stages['Won'], closed_outcome: 'won' });

    const whole = await call('crm_card', { company_id: companyId, contact_id: orgId });
    expect(whole['contact']).toMatchObject({ id: orgId, contact_type: 'customer' });
    // card_of lists the open deals: the won one has left them.
    expect(whole['deals']).toEqual([]);
    expect((whole['activities'] as { kind: string }[]).map((a) => a.kind)).toContain('system');

    // Closed, it is on the board only when asked for.
    const open = await call('crm_board', { company_id: companyId, pipeline_id: pipelineId });
    expect((open['pipelines'] as { count: number }[])[0]?.count).toBe(0);
    const all = await call('crm_board', { company_id: companyId, include_closed: true });
    const won = ((all['pipelines'] as Record<string, unknown>[])[0]?.['stages'] as Record<string, unknown>[]).find(
      (stage) => stage['outcome'] === 'won',
    );
    expect((won?.['deals'] as Record<string, unknown>[])[0]).toMatchObject({
      id: deal['id'],
      contact_name: 'Northwind Trading',
      closed_outcome: 'won',
    });
  });

  it('logs an activity read from elsewhere once, however many times it is read', async () => {
    const args = {
      company_id: companyId,
      contact_id: personId,
      kind: 'email_in',
      subject: 'Re: the quote',
      source: 'mailbox',
      source_ref: '<quote-reply@northwind.example>',
    };
    const first = await call('crm_log_activity', args);
    const again = await call('crm_log_activity', { ...args, subject: 'changed' });
    expect((again['activity'] as { id: string }).id).toBe((first['activity'] as { id: string }).id);
    expect(again['activity']).toMatchObject({ subject: 'Re: the quote' });
    expect(
      await rows(db, `select id from crm.activities where source = 'mailbox' and company_id = $1`, [companyId]),
    ).toHaveLength(1);
  });

  it('searches by text and by status, and reads the segments and the timeline', async () => {
    const byText = await call('crm_search', { company_id: companyId, query: 'northwind' });
    expect((byText['cards'] as { name: string }[]).map((c) => c.name).sort()).toEqual(['Ada Lovelace', 'Northwind Trading']);
    const byStatus = await call('crm_search', { company_id: companyId, status: 'contacted' });
    expect(byStatus).toMatchObject({ count: 1, cards: [{ contact_id: personId, segments: ['retail'] }] });

    const tree = await call('crm_segments', { company_id: companyId });
    expect((tree['segments'] as Record<string, unknown>[]).map((s) => [s['slug'], s['depth'], s['members']])).toEqual([
      ['trade', 0, 0],
      ['retail', 1, 1],
    ]);

    const timeline = await call('crm_timeline', { company_id: companyId, contact_id: personId, kinds: ['email_in'] });
    expect(timeline).toMatchObject({ count: 1, activities: [{ kind: 'email_in', subject: 'Re: the quote' }] });

    const left = await call('crm_leave_segment', { company_id: companyId, segment_id: segmentId, contact_id: personId });
    expect((left['membership'] as { left_at: string | null }).left_at).not.toBeNull();
    const after = await call('crm_segments', { company_id: companyId });
    expect((after['segments'] as { slug: string; members: number }[]).find((s) => s.slug === 'retail')?.members).toBe(0);
  });

  it('hands the schema\'s refusals to the model under their own names', async () => {
    await expect(
      call('crm_upsert_card', { company_id: companyId, contact_id: personId, patch: { colour: 'blue' } }),
    ).rejects.toThrow(/crm_unknown_field/);
    await expect(call('crm_timeline', { company_id: companyId })).rejects.toThrow(/crm_bad_timeline/);
    await expect(
      call('crm_board', { company_id: companyId, pipeline_id: segmentId }),
    ).rejects.toThrow(/crm_unknown_pipeline/);
    await expect(
      call('crm_log_activity', { company_id: companyId, contact_id: personId, kind: 'note', source_ref: 'x' }),
    ).rejects.toThrow(/crm_bad_activity/);
    // A status the schema does not have is Postgres's refusal, not a list kept here.
    await expect(call('crm_search', { company_id: companyId, status: 'prospect' })).rejects.toThrow(/relationship_status/);
  });

  it('offers a morning checklist that names its tools and the company', async () => {
    const prompt = await client.getPrompt({ name: 'crm_morning_review', arguments: { company_id: companyId, quiet_days: '10' } });
    const text = (prompt.messages[0]?.content as { text: string }).text;
    expect(text).toContain(companyId);
    expect(text).toContain('10 days');
    for (const tool of ['crm_search', 'crm_board', 'crm_card', 'crm_timeline']) expect(text).toContain(tool);
  });
});
