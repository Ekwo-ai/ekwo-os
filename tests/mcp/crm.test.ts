/**
 * The crm tools, over the protocol and against the real schema.
 *
 * What the module decides — a card's fields, a merge, who may write — is
 * `modules/crm/tests`. What is asked here is that a model reaches it whole:
 * the toolset is offered only where `ekwo.modules` carries the module, each
 * tool calls its function and hands back what the function returned, and a
 * refusal of the schema reaches the model under its own name. The currency is
 * the company's, read and never named.
 */

import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { BooksError, SCHEMA_FEATURES, crmDealOfDocument } from '../../packages/core/src/index.js';
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
  it('is offered where ekwo.modules carries crm, under its prefix, and not otherwise', async () => {
    expect(await installedModules(backend)).toContain('crm');
    const names = (await client.listTools()).tools.map((tool) => tool.name);
    expect(names.filter((name) => name.startsWith('crm_')).length).toBe(15);
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

  it('hands over a contact as the vCard the schema writes', async () => {
    const answer = await call('crm_contact_vcard', { company_id: companyId, contact_id: personId });
    expect(answer['media_type']).toBe('text/vcard');
    const lines = String(answer['vcard']).split('\r\n');
    expect(lines[0]).toBe('BEGIN:VCARD');
    expect(lines).toContain('FN:Ada Lovelace');
    expect(lines).toContain('ORG:Northwind Trading');
    expect(lines).toContain('EMAIL;TYPE=INTERNET:ada@northwind.example');
    expect(lines).toContain(`UID:urn:uuid:${personId}`);
    await expect(
      call('crm_contact_vcard', { company_id: companyId, contact_id: segmentId }),
    ).rejects.toThrow(/crm_unknown_contact/);
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
    // A status the schema does not have is refused before the call, and the tool says which exist.
    await expect(call('crm_search', { company_id: companyId, status: 'prospect' })).rejects.toThrow(/status/);
    const tools = (await client.listTools()).tools;
    const search = tools.find((tool) => tool.name === 'crm_search');
    expect(JSON.stringify(search?.inputSchema)).toContain('in_discussion');
    expect(tools.find((tool) => tool.name === 'crm_log_activity')?.description).toContain('email_out');
  });

  it('offers a morning checklist that names its tools and the company', async () => {
    const prompt = await client.getPrompt({ name: 'crm_morning_review', arguments: { company_id: companyId, quiet_days: '10' } });
    const text = (prompt.messages[0]?.content as { text: string }).text;
    expect(text).toContain(companyId);
    expect(text).toContain('10 days');
    for (const tool of ['crm_search', 'crm_board', 'crm_card', 'crm_timeline']) expect(text).toContain(tool);
  });
});

describe('a quote a deal carries', () => {
  // `accept_document` is asked of a schema that says it has it
  // (`SCHEMA_FEATURES.quote_answer`). Until the release that brings it
  // redefines `ekwo_schema_version()`, this database says the version it will
  // be, and says its own again after.
  let definition: string;
  beforeAll(async () => {
    definition = (
      await one<{ definition: string }>(db, `select pg_get_functiondef('ekwo.ekwo_schema_version()'::regprocedure) as definition`)
    ).definition;
    await db.query(
      `create or replace function ekwo.ekwo_schema_version() returns text language sql immutable as $$ select '${SCHEMA_FEATURES.quote_answer.since}'::text $$`,
    );
  });
  afterAll(async () => {
    await db.query(definition);
  });

  it('is attached with crm_attach_document, and accept_document wins the deal with no other call', async () => {
    const buyer = await contact('Contoso Partners', true, null, null);
    const quote = (
      await one<{ id: string }>(
        db,
        `insert into documents (company_id, doc_type, contact_id, document_date) values ($1, 'sale_quote', $2, '2026-06-15') returning id`,
        [companyId, buyer],
      )
    ).id;
    const opened = record((await call('crm_open_deal', { company_id: companyId, pipeline_id: pipelineId, contact_id: buyer, title: 'Fit-out' }))['deal']);
    const linked = record((await call('crm_attach_document', { company_id: companyId, deal_id: opened['id'], document_id: quote }))['link']);
    expect(linked).toMatchObject({ deal_id: opened['id'], document_id: quote });

    const accepted = await call('accept_document', { document_id: quote, accepted_by: 'The buyer' });
    expect(record(accepted['document'])['quote_status']).toBe('accepted');

    const board = await call('crm_board', { company_id: companyId, pipeline_id: pipelineId, include_closed: true });
    const deals = ((board['pipelines'] as Record<string, unknown>[])[0]?.['stages'] as { name: string; deals: Record<string, unknown>[] }[])
      .find((stage) => stage.name === 'Won')?.deals;
    expect(deals?.find((deal) => deal['id'] === opened['id'])).toMatchObject({
      closed_outcome: 'won',
      documents: [expect.objectContaining({ id: quote, quote_status: 'accepted' })],
    });
    expect((await one<{ t: string }>(db, `select contact_type::text as t from contacts where id = $1`, [buyer])).t).toBe('customer');

    // Read from the document's side, the won deal is there, which crm_card no longer lists.
    expect(await call('crm_deal_of_document', { company_id: companyId, document_id: quote })).toEqual({
      available: true,
      deal: {
        id: opened['id'],
        title: 'Fit-out',
        amount: null,
        currency_code: null,
        stage: { id: stages['Won'], name: 'Won', outcome: 'won' },
        closed_at: expect.any(String),
        closed_outcome: 'won',
      },
    });

    await call('crm_detach_document', { company_id: companyId, document_id: quote });
    await expect(call('crm_detach_document', { company_id: companyId, document_id: quote })).rejects.toThrow(/crm_document_not_attached/);
    expect(await call('crm_deal_of_document', { company_id: companyId, document_id: quote })).toEqual({ available: true, deal: null });
  });

  it('refuses with crm_deal_of_document a document of another company, and reads nothing where the function is absent', async () => {
    const other = await newCompany(db, { name: 'Ailleurs SA' });
    const foreign = (
      await one<{ id: string }>(
        db,
        `insert into documents (company_id, doc_type, document_date) values ($1, 'sale_quote', '2026-06-15') returning id`,
        [other.companyId],
      )
    ).id;
    await expect(call('crm_deal_of_document', { company_id: companyId, document_id: foreign })).rejects.toThrow(/crm_unknown_document/);

    // A database whose crm module has not received the read: absent, never an error.
    await db.query(`alter function crm.deal_of_document(uuid, uuid) rename to deal_of_document_hidden`);
    try {
      expect(await call('crm_deal_of_document', { company_id: companyId, document_id: foreign })).toEqual({ available: false, deal: null });
    } finally {
      await db.query(`alter function crm.deal_of_document_hidden(uuid, uuid) rename to deal_of_document`);
    }
  });
});

describe('crmDealOfDocument over PostgREST', () => {
  // PostgREST answers PGRST202 for a function its cache does not hold: the
  // read is absent there, and any other refusal still reaches the caller.
  const refusing = (error: Error) =>
    ({
      mode: 'postgrest',
      actingAs: undefined,
      rpc: () => Promise.reject(error),
    }) as unknown as Backend;
  const args = { company_id: crypto.randomUUID(), document_id: crypto.randomUUID() };

  it('is absent where the function is not in the schema cache', async () => {
    const missing = new BooksError(
      'Could not find the function crm.deal_of_document(p_company_id, p_document_id) in the schema cache',
      { code: 'PGRST202' },
    );
    expect(await crmDealOfDocument(refusing(missing), args)).toEqual({ deal: null, available: false });
  });

  it('hands any other refusal back', async () => {
    const refused = new BooksError('crm_not_allowed: reading the deal of a document needs crm.read', { code: '42501' });
    await expect(crmDealOfDocument(refusing(refused), args)).rejects.toThrow(/crm_not_allowed/);
  });
});
