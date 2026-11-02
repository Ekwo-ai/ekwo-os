import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import { ToolListChangedNotificationSchema } from '@modelcontextprotocol/sdk/types.js';
import { afterEach, describe, expect, it } from 'vitest';
import {
  CORE_TOOLS,
  ENV,
  LOADING_TOOLS,
  MODULE_TOOLSETS,
  buildServer,
  serverFromEnvironment,
  toolLoadingFrom,
  type Backend,
  type FoundTool,
  type ServerOptions,
} from '../../packages/mcp/src/index.js';

/**
 * A session can start with the tools of a first session and load the others
 * when it needs them (`EKWO_MCP_TOOLS=on_demand`). Listing, searching and
 * loading touch no database, so the backend here is never called.
 */

const nobody = {} as Backend;
const everyModule = MODULE_TOOLSETS.map((toolset) => toolset.code);
const open: Client[] = [];

async function connected(options: ServerOptions): Promise<{ client: Client; changes: () => number }> {
  const server = buildServer(nobody, options);
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  const client = new Client({ name: 'test-client', version: '0.0.0' });
  let changes = 0;
  client.setNotificationHandler(ToolListChangedNotificationSchema, () => {
    changes += 1;
  });
  await Promise.all([client.connect(clientTransport), server.connect(serverTransport)]);
  open.push(client);
  return { client, changes: () => changes };
}

async function call<T>(client: Client, name: string, args: Record<string, unknown>): Promise<T> {
  const result = await client.callTool({ name, arguments: args });
  expect(result.isError, JSON.stringify(result.content)).not.toBe(true);
  return JSON.parse((result.content as { text: string }[])[0]?.text ?? 'null') as T;
}

afterEach(async () => {
  await Promise.all(open.splice(0).map((client) => client.close()));
});

describe('every tool from the start, the default', () => {
  it('offers no tool to search or load: there is nothing left to find', async () => {
    const { client } = await connected({ modules: everyModule });
    const names = (await client.listTools()).tools.map((tool) => tool.name);
    for (const name of LOADING_TOOLS) expect(names).not.toContain(name);
    for (const name of CORE_TOOLS) expect(names).toContain(name);
    expect(names.length).toBeGreaterThan(100);
  });
});

describe('tools on demand', () => {
  it('starts with the tools of a first session and the two that find the others', async () => {
    const { client } = await connected({ modules: everyModule, tools: 'on_demand' });
    const names = (await client.listTools()).tools.map((tool) => tool.name).sort();
    expect(names).toEqual([...CORE_TOOLS, ...LOADING_TOOLS].sort());
  });

  it('says so in the instructions', async () => {
    const { client } = await connected({ tools: 'on_demand' });
    expect(client.getInstructions()).toContain('search_tools');
    const { client: whole } = await connected({});
    expect(whole.getInstructions()).not.toContain('search_tools');
  });

  it('finds a tool by the words of a task, with what it does to the books', async () => {
    const { client } = await connected({ modules: everyModule, tools: 'on_demand' });
    const found = await call<{ tools: FoundTool[]; total: number }>(client, 'search_tools', { query: 'fixed asset' });
    expect(found.tools[0]?.name.startsWith('fixed_assets_')).toBe(true);
    const create = found.tools.find((tool) => tool.name === 'fixed_assets_create');
    expect(create).toMatchObject({ effect: 'destructive', loaded: false });
    expect(create?.summary.length ?? 0).toBeGreaterThan(10);
    // A tool already in the session says so.
    const ledger = await call<{ tools: FoundTool[] }>(client, 'search_tools', { query: 'general ledger' });
    expect(ledger.tools.find((tool) => tool.name === 'general_ledger')).toMatchObject({ effect: 'read', loaded: true });
  });

  it('filters by effect, and lists everything without a query', async () => {
    const { client } = await connected({ modules: everyModule, tools: 'on_demand' });
    const destructive = await call<{ tools: FoundTool[]; total: number }>(client, 'search_tools', { effect: 'destructive', limit: 200 });
    expect(destructive.tools.length).toBe(destructive.total);
    expect(destructive.tools.every((tool) => tool.effect === 'destructive')).toBe(true);
    expect(destructive.tools.map((tool) => tool.name)).toContain('post_document');
    const all = await call<{ total: number }>(client, 'search_tools', {});
    const { client: whole } = await connected({ modules: everyModule });
    expect(all.total).toBe((await whole.listTools()).tools.length);
  });

  it('loads what it is asked for, and the client is told the list changed', async () => {
    const { client, changes } = await connected({ modules: everyModule, tools: 'on_demand' });
    const answer = await call<{ loaded: string[]; already_loaded: string[]; unknown: string[] }>(client, 'load_tools', {
      names: ['journal_book', 'crm_search', 'get_company', 'no_such_tool'],
    });
    expect(answer).toEqual({ loaded: ['journal_book', 'crm_search'], already_loaded: ['get_company'], unknown: ['no_such_tool'] });
    await expect.poll(changes).toBeGreaterThan(0);
    const names = (await client.listTools()).tools.map((tool) => tool.name);
    expect(names).toContain('journal_book');
    expect(names).toContain('crm_search');
    expect(names).not.toContain('crm_board');
    // A second time loads nothing more.
    const again = await call<{ loaded: string[] }>(client, 'load_tools', { names: ['journal_book'] });
    expect(again.loaded).toEqual([]);
  });

  it('starts with tools every installation has: the socle carries each of them', async () => {
    const { client } = await connected({});
    const socle = (await client.listTools()).tools.map((tool) => tool.name);
    for (const name of CORE_TOOLS) expect(socle, name).toContain(name);
  });
});

describe(`${ENV.tools}`, () => {
  it('chooses on demand, all, or nothing — and refuses anything else by name', () => {
    expect(toolLoadingFrom({})).toBeUndefined();
    expect(toolLoadingFrom({ [ENV.tools]: 'on_demand' })).toBe('on_demand');
    expect(toolLoadingFrom({ [ENV.tools]: ' all ' })).toBe('all');
    expect(() => toolLoadingFrom({ [ENV.tools]: 'some' })).toThrow(/^bad_tool_loading: /);
  });

  it('reaches the server started from the environment, configured or not', async () => {
    const started = await serverFromEnvironment({ [ENV.tools]: 'on_demand' });
    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
    const client = new Client({ name: 'test-client', version: '0.0.0' });
    await Promise.all([client.connect(clientTransport), started.server.connect(serverTransport)]);
    open.push(client);
    const names = (await client.listTools()).tools.map((tool) => tool.name).sort();
    expect(names).toEqual([...CORE_TOOLS, ...LOADING_TOOLS].sort());
  });
});
