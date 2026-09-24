/**
 * The server over HTTP: the Streamable HTTP transport, stateless, in JSON.
 *
 * The requests below are the ones a remote client makes — `initialize`, then
 * `tools/list`, then a tool call — each one a separate HTTP request answered
 * by a server built for it and closed after it. They run against the real
 * schema in PGlite, through the backend a host hands in, so what is asserted
 * is what a person sees through a host: their companies, their role, and the
 * database's refusals.
 *
 * The PostgREST half — a person's token, or a key of Ekwo OS in its own
 * header — is asserted on the requests it would send, through a `fetch` of
 * the test's own: which headers are there, and which one must not be.
 */

import { createServer, type Server } from 'node:http';
import type { AddressInfo } from 'node:net';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  API_KEY_HEADER,
  SERVER_NAME,
  checkConnection,
  handleHttpRequest,
  handleNodeRequest,
  openHttpBackend,
  type Backend,
} from '../../packages/mcp/src/index.js';
import { freshDatabase } from '../helpers/db.js';
import { newCompany, newUser, type Fixture } from '../helpers/factory.js';
import { somePack } from '../helpers/packs.js';
import { backendFor } from './helpers.js';

const HOME = somePack.manifest.country;
const ORIGIN = 'https://mcp.example.test';

/** A JWT-shaped key with the given role claim. The signature is never checked. */
function keyWithRole(role: string): string {
  const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url');
  const payload = Buffer.from(JSON.stringify({ iss: 'supabase', role })).toString('base64url');
  return `${header}.${payload}.notasignature`;
}

/** A key of Ekwo OS in shape only, assembled so no literal here looks like one. */
const SOME_KEY = ['ekwo', 'a'.repeat(12), 'b'.repeat(64)].join('_');
const PUBLISHABLE = ['sb', 'publishable', 'test'].join('_');

let rpcId = 0;

function post(body: unknown, headers: Record<string, string> = {}): Request {
  return new Request(`${ORIGIN}/mcp`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json, text/event-stream',
      ...headers,
    },
    body: JSON.stringify(body),
  });
}

function call(method: string, params: Record<string, unknown> = {}): Request {
  rpcId += 1;
  return post({ jsonrpc: '2.0', id: rpcId, method, params });
}

const INITIALIZE = {
  protocolVersion: '2025-06-18',
  capabilities: {},
  clientInfo: { name: 'http-test', version: '0.0.0' },
};

interface RpcAnswer {
  result?: Record<string, unknown>;
  error?: { code: number; message: string };
}

async function answer(response: Response): Promise<RpcAnswer> {
  expect(response.headers.get('content-type') ?? '').toContain('application/json');
  return (await response.json()) as RpcAnswer;
}

function toolText(result: Record<string, unknown> | undefined): string {
  const content = (result?.['content'] ?? []) as { type: string; text?: string }[];
  return content.map((part) => part.text ?? '').join('\n');
}

let db: PGlite;
let fx: Fixture;
let asOwner: Backend;
let asAccountant: Backend;

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: HOME, name: 'Remote Books Ltd' });
  const accountant = await newUser(db, 'accountant@http.test');
  await db.query(
    `insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant')`,
    [fx.companyId, accountant],
  );
  asOwner = backendFor(db, fx.ownerId);
  asAccountant = backendFor(db, accountant);
});

afterAll(async () => {
  await db.close();
});

describe('one request, one answer', () => {
  it('answers initialize in JSON, under its own name, with no session', async () => {
    const response = await handleHttpRequest(call('initialize', INITIALIZE), asOwner);
    expect(response.status).toBe(200);
    // Stateless: nothing to come back to.
    expect(response.headers.get('mcp-session-id')).toBeNull();
    const { result } = await answer(response);
    expect((result?.['serverInfo'] as { name: string }).name).toBe(SERVER_NAME);
  });

  it('accepts the notification that follows, and says nothing', async () => {
    const response = await handleHttpRequest(
      post({ jsonrpc: '2.0', method: 'notifications/initialized' }),
      asOwner,
    );
    expect(response.status).toBe(202);
  });

  it('lists the tools, each request on a server of its own', async () => {
    const { result } = await answer(await handleHttpRequest(call('tools/list'), asOwner, { modules: [] }));
    const names = ((result?.['tools'] ?? []) as { name: string }[]).map((tool) => tool.name);
    for (const name of ['list_companies', 'trial_balance', 'create_document', 'post_document']) {
      expect(names).toContain(name);
    }
  });

  it('asks the database which modules there are when the host does not say', async () => {
    const { result } = await answer(await handleHttpRequest(call('tools/list'), asOwner));
    expect(((result?.['tools'] ?? []) as unknown[]).length).toBeGreaterThan(40);
  });

  it('reads the books as the person the host said, and gives their own role', async () => {
    const asked = { name: 'list_companies', arguments: {} };
    const owner = await answer(await handleHttpRequest(call('tools/call', asked), asOwner));
    const accountant = await answer(await handleHttpRequest(call('tools/call', asked), asAccountant));
    const mine = (payload: RpcAnswer) =>
      (JSON.parse(toolText(payload.result)) as { companies: { id: string; your_role: string }[] }).companies.find(
        (company) => company.id === fx.companyId,
      );
    expect(mine(owner)?.your_role).toBe('owner');
    // Two members see each other's rows; each is told their own role.
    expect(mine(accountant)?.your_role).toBe('accountant');
  });

  it('lets a refusal of the database through as a tool error', async () => {
    const stranger = backendFor(db, await newUser(db, 'stranger@http.test'));
    const { result } = await answer(
      await handleHttpRequest(
        call('tools/call', { name: 'get_company', arguments: { company_id: fx.companyId } }),
        stranger,
      ),
    );
    expect(result?.['isError']).toBe(true);
  });

  it('answers a batch in one response', async () => {
    rpcId += 2;
    const response = await handleHttpRequest(
      post([
        { jsonrpc: '2.0', id: rpcId - 1, method: 'ping' },
        { jsonrpc: '2.0', id: rpcId, method: 'ping' },
      ]),
      asOwner,
      { modules: [] },
    );
    const batch = (await response.json()) as unknown[];
    expect(batch).toHaveLength(2);
  });
});

describe('what is not a request of this server', () => {
  it('refuses to open a stream: it never speaks first', async () => {
    const response = await handleHttpRequest(new Request(`${ORIGIN}/mcp`, { method: 'GET' }), asOwner);
    expect(response.status).toBe(405);
    expect(response.headers.get('allow')).toBe('POST');
  });

  it('has no session to end', async () => {
    const response = await handleHttpRequest(new Request(`${ORIGIN}/mcp`, { method: 'DELETE' }), asOwner);
    expect(response.status).toBe(405);
  });

  it('says a body that is not JSON is not JSON', async () => {
    const response = await handleHttpRequest(
      new Request(`${ORIGIN}/mcp`, { method: 'POST', body: 'not json', headers: { 'Content-Type': 'application/json' } }),
      asOwner,
    );
    expect(response.status).toBe(400);
    expect((await answer(response)).error?.code).toBe(-32700);
  });
});

describe('a connection, before any network', () => {
  const base = { supabaseUrl: 'https://project.example.test', anonKey: PUBLISHABLE };

  it('takes a person or a key, one of the two', () => {
    expect(() => checkConnection({ ...base, accessToken: 'a-session' })).not.toThrow();
    expect(() => checkConnection({ ...base, apiKey: SOME_KEY })).not.toThrow();
    expect(() => checkConnection(base)).toThrow(/^missing_credentials:/);
    expect(() => checkConnection({ ...base, accessToken: 'a-session', apiKey: SOME_KEY })).toThrow(/^two_credentials:/);
  });

  it('refuses a service_role key in every slot', () => {
    const privileged = keyWithRole('service_role');
    expect(() => checkConnection({ ...base, anonKey: privileged, apiKey: SOME_KEY })).toThrow(/service_role/);
    expect(() => checkConnection({ ...base, accessToken: privileged })).toThrow(/service_role/);
    expect(() => checkConnection({ ...base, apiKey: privileged })).toThrow(/service_role/);
    expect(() => checkConnection({ ...base, apiKey: ['sb', 'secret', 'x'].join('_') })).toThrow(/service_role/);
  });

  it('answers a refused connection as a JSON-RPC error, not a crash', async () => {
    const response = await handleHttpRequest(call('tools/list'), { ...base, apiKey: keyWithRole('service_role') });
    expect(response.status).toBe(200);
    expect((await answer(response)).error?.message).toMatch(/service_role/);
  });
});

describe('over PostgREST', () => {
  interface Sent {
    url: string;
    headers: Headers;
  }

  /** A fetch that records what it was asked and answers an empty list. */
  function recorder(sent: Sent[], user: Record<string, unknown> = { id: 'u-1' }): typeof fetch {
    return (async (input: string | URL | Request, init?: RequestInit) => {
      const url = input instanceof Request ? input.url : String(input);
      const headers = new Headers(init?.headers ?? (input instanceof Request ? input.headers : undefined));
      sent.push({ url, headers });
      const body = url.includes('/auth/v1/user') ? user : [];
      return new Response(JSON.stringify(body), { status: 200, headers: { 'Content-Type': 'application/json' } });
    }) as typeof fetch;
  }

  it('sends a key of Ekwo OS in its own header, and no Authorization at all', async () => {
    const sent: Sent[] = [];
    const backend = await openHttpBackend(
      { supabaseUrl: 'https://project.example.test', anonKey: PUBLISHABLE, apiKey: SOME_KEY },
      { fetch: recorder(sent) },
    );
    expect(backend.actingAs).toBeUndefined();
    await backend.select({ table: 'companies', columns: ['id'] });
    await backend.close();
    expect(sent).toHaveLength(1);
    const [request] = sent;
    expect(request?.url).toContain('/rest/v1/companies');
    expect(request?.headers.get(API_KEY_HEADER)).toBe(SOME_KEY);
    expect(request?.headers.get('apikey')).toBe(PUBLISHABLE);
    expect(request?.headers.has('authorization')).toBe(false);
  });

  it('sends a person\'s token as the bearer, and no key', async () => {
    const sent: Sent[] = [];
    const backend = await openHttpBackend(
      { supabaseUrl: 'https://project.example.test', anonKey: PUBLISHABLE, accessToken: 'a-session-token' },
      { fetch: recorder(sent, { id: '00000000-0000-4000-8000-000000000001' }) },
    );
    expect(backend.actingAs).toBe('00000000-0000-4000-8000-000000000001');
    await backend.select({ table: 'companies', columns: ['id'] });
    await backend.close();
    const read = sent.find((request) => request.url.includes('/rest/v1/companies'));
    expect(read?.headers.get('authorization')).toBe('Bearer a-session-token');
    expect(read?.headers.has(API_KEY_HEADER.toLowerCase())).toBe(false);
  });
});

describe('under node:http', () => {
  let server: Server;
  let url: string;

  beforeAll(async () => {
    server = createServer((req, res) => {
      void handleNodeRequest(req, res, asOwner, { origin: ORIGIN, modules: [] });
    });
    await new Promise<void>((resolve) => server.listen(0, '127.0.0.1', resolve));
    url = `http://127.0.0.1:${(server.address() as AddressInfo).port}/mcp`;
  });

  afterAll(async () => {
    await new Promise<void>((resolve) => server.close(() => resolve()));
  });

  it('answers the same requests the same way', async () => {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Accept: 'application/json, text/event-stream' },
      body: JSON.stringify({ jsonrpc: '2.0', id: 1, method: 'tools/call', params: { name: 'list_companies', arguments: {} } }),
    });
    expect(response.status).toBe(200);
    const { result } = (await response.json()) as RpcAnswer;
    expect(toolText(result)).toContain('Remote Books Ltd');
  });

  it('refuses a GET there too', async () => {
    const response = await fetch(url);
    expect(response.status).toBe(405);
  });
});
