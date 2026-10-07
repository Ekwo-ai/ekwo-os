/**
 * A shared instance keeps its tenants apart, through the MCP server
 * (decision 0065).
 *
 * The same two people as `tests/shared_instance.test.ts`, each with a company
 * of their own on one shared installation. The second one asks the MCP server
 * — in their own session, and through a machine key of their own company, the
 * way an agent connected to a hosted server asks — every tool it registers
 * that takes the id of a company or of a row, with the first person's ids and
 * with ids nobody holds. Both answers have to be the same; and what lists
 * companies lists only their own.
 *
 * The tools are read from `tools/list`, not listed here, so a tool added
 * tomorrow is asked too.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { handleHttpRequest, sqlBackend, type Backend } from '../../packages/mcp/src/index.js';
import { asUser, freshDatabase, one } from '../helpers/db.js';
import { newUser } from '../helpers/factory.js';
import { adapt, backendFor } from './helpers.js';

let db: PGlite;
let aliceCompany: string;
let bobCompany: string;
let bob: string;
let bobKey: string;
const alice: Record<string, string> = {};
const NOWHERE = '7d0f0b4e-0000-4000-8000-00000000abcd';

type Queryable = Parameters<typeof adapt>[0];

/** The server's backend with a machine key and nothing else: no `sub`, as over the API. */
function keyBackend(key: string): Backend {
  const client = adapt(db as unknown as Queryable, db);
  return sqlBackend(
    {
      ...client,
      async transaction(fn) {
        return client.transaction(async (tx) => {
          await tx.query(`select set_config('request.headers', $1, true)`, [JSON.stringify({ 'x-ekwo-api-key': key })]);
          await tx.query(`select ekwo_pre_request()`);
          return fn(tx);
        });
      },
    },
    { userId: '' },
  );
}

let rpcId = 0;
function request(method: string, params: Record<string, unknown> = {}): Request {
  rpcId += 1;
  return new Request('https://mcp.example.test/mcp', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json, text/event-stream' },
    body: JSON.stringify({ jsonrpc: '2.0', id: rpcId, method, params }),
  });
}

interface Tool {
  name: string;
  inputSchema: { properties?: Record<string, { type?: string | string[]; format?: string; enum?: unknown[] }>; required?: string[] };
}

async function toolsOf(backend: Backend): Promise<Tool[]> {
  const answer = (await (await handleHttpRequest(request('tools/list'), backend)).json()) as { result?: { tools?: Tool[] } };
  return answer.result?.tools ?? [];
}

/** What a tool answered, the ids in it replaced. */
async function called(backend: Backend, name: string, args: Record<string, unknown>, ids: readonly string[]): Promise<string> {
  const answer = (await (await handleHttpRequest(request('tools/call', { name, arguments: args }), backend)).json()) as {
    result?: { isError?: boolean; content?: { text?: string }[] };
    error?: { message: string };
  };
  const text = answer.error?.message ?? answer.result?.content?.map((part) => part.text ?? '').join('\n') ?? '';
  const scrubbed = ids.reduce((said, id) => said.split(id).join('<id>'), text);
  return `${answer.result?.isError === true || answer.error !== undefined ? 'error' : 'ok'} ${scrubbed}`;
}

/** A value for an argument the probe does not care about, from its type. */
function filler(name: string, spec: { type?: string | string[]; format?: string; enum?: unknown[] }): unknown {
  if (spec.enum !== undefined && spec.enum.length > 0) return spec.enum[0];
  const type = Array.isArray(spec.type) ? spec.type[0] : spec.type;
  if (spec.format === 'uuid' || name.endsWith('_id')) return NOWHERE;
  if (spec.format === 'date' || /date|from|to|as_of|period|start|end/.test(name)) return '2026-01-01';
  switch (type) {
    case 'number':
    case 'integer':
      return 1;
    case 'boolean':
      return false;
    case 'array':
      return [];
    case 'object':
      return {};
    default:
      return 'x';
  }
}

beforeAll(async () => {
  db = await freshDatabase();
  const country = (await one<{ country: string }>(db, `select country from chart_templates where is_default order by country limit 1`)).country;
  await db.query(`select share_instance(1)`);
  const aliceId = await newUser(db, 'alice@example.test');
  bob = await newUser(db, 'bob@example.test');
  aliceCompany = (await asUser(db, aliceId, () => one<{ id: string }>(db, `select id from create_company('Alice Atelier', $1)`, [country]))).id;
  bobCompany = (await asUser(db, bob, () => one<{ id: string }>(db, `select id from create_company('Bob', $1)`, [country]))).id;
  await asUser(db, aliceId, async () => {
    alice['contact_id'] = (
      await one<{ id: string }>(db, `insert into contacts (company_id, name, contact_type, country) values ($1, 'Alice''s customer', 'customer', $2) returning id`, [aliceCompany, country])
    ).id;
    alice['document_id'] = (
      await one<{ id: string }>(db, `insert into documents (company_id, doc_type, contact_id, document_date) values ($1, 'sale_invoice', $2, current_date) returning id`, [aliceCompany, alice['contact_id']])
    ).id;
    await db.query(
      `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price, account_id)
       select $1, $2, 10, 'Work', 1, 100,
              (select a.id from accounts a where a.company_id = $2 and a.account_type = 'income' order by a.code limit 1)`,
      [alice['document_id'], aliceCompany],
    );
    await db.query(`select post_document($1)`, [alice['document_id']]);
    alice['invitation_id'] = (await one<{ invitation_id: string }>(db, `select invitation_id from invite_member($1, 'dave@example.test')`, [aliceCompany])).invitation_id;
    alice['api_key_id'] = (await one<{ api_key_id: string }>(db, `select api_key_id from create_api_key($1, 'Alice''s key', '["documents.read"]'::jsonb, null)`, [aliceCompany])).api_key_id;
  });
  alice['company_id'] = aliceCompany;
  alice['entry_id'] = (await one<{ id: string }>(db, `select entry_id as id from documents where id = $1`, [alice['document_id']])).id;
  alice['account_id'] = (await one<{ id: string }>(db, `select id from accounts where company_id = $1 order by code limit 1`, [aliceCompany])).id;
  alice['journal_id'] = (await one<{ id: string }>(db, `select id from journals where company_id = $1 order by code limit 1`, [aliceCompany])).id;
  alice['fiscal_year_id'] = (await one<{ id: string }>(db, `select id from fiscal_years where company_id = $1 limit 1`, [aliceCompany])).id;
  alice['user_id'] = aliceId;
  alice['member_user_id'] = aliceId;
  bobKey = (
    await asUser(db, bob, () =>
      one<{ secret: string }>(
        db,
        `select * from create_api_key($1, 'Bob''s agent', (select to_jsonb(array_agg(capability)) from role_capabilities where role = 'client'), null)`,
        [bobCompany],
      ),
    )
  ).secret;
});

afterAll(async () => {
  await db.close();
});

for (const [way, backendOf] of [
  ['in their own session', () => backendFor(db, bob)],
  ['through a machine key of their own company', () => keyBackend(bobKey)],
] as const) {
  describe(`the other person, ${way}`, () => {
    it('reads their own company, and lists none of the other person’s', async () => {
      const backend = backendOf();
      const own = await called(backend, 'get_company', { company_id: bobCompany }, []);
      expect(own).toMatch(/^ok /);
      expect(own).toContain(bobCompany);
      // Listing names the person acting; through a key over SQL there is none,
      // and the tool says so. Over PostgREST a key lists its own company.
      for (const tool of ['list_companies', 'status']) {
        const listed = await called(backend, tool, {}, []);
        expect(listed).not.toContain(aliceCompany);
        expect(listed).not.toContain('Alice Atelier');
        if (way === 'in their own session') expect(listed).toContain(bobCompany);
      }
    });

    it('is answered by every tool about the other person’s company and rows as about ids nobody holds', async () => {
      const backend = backendOf();
      const tools = await toolsOf(backend);
      expect(tools.length).toBeGreaterThan(40);
      const differs: string[] = [];
      let probed = 0;
      for (const tool of tools) {
        const properties = tool.inputSchema.properties ?? {};
        const targets = Object.keys(properties).filter((name) => alice[name] !== undefined);
        if (targets.length === 0) continue;
        for (const target of targets) {
          const base: Record<string, unknown> = {};
          for (const name of tool.inputSchema.required ?? []) base[name] = filler(name, properties[name] ?? {});
          const id = alice[target] as string;
          const theirs = await called(backend, tool.name, { ...base, [target]: id }, [id, NOWHERE]);
          const nobodys = await called(backend, tool.name, { ...base, [target]: NOWHERE }, [id, NOWHERE]);
          probed += 1;
          if (theirs !== nobodys) differs.push(`${tool.name}.${target}: ${theirs.slice(0, 300)} / ${nobodys.slice(0, 300)}`);
          expect(theirs, `${tool.name}.${target}`).not.toContain('Alice Atelier');
        }
      }
      expect(probed).toBeGreaterThan(30);
      expect(differs).toEqual([]);
    });
  });
}
