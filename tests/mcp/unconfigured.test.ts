/**
 * The server started with nothing configured.
 *
 * Directories that index MCP servers, and every client the moment a server is
 * added, start the package with an empty environment and ask for its tools.
 * The server has to answer that, and then answer every tool call with what to
 * set — without connecting anywhere. What is wrong rather than missing, a
 * `service_role` key above all, is still refused before a transport exists.
 */

import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import type { CallToolResult } from '@modelcontextprotocol/sdk/types.js';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { ENV, SERVER_NAME, serverFromEnvironment } from '../../packages/mcp/src/index.js';

/** A JWT-shaped key with the given role claim. Signature is never checked. */
function keyWithRole(role: string): string {
  const payload = Buffer.from(JSON.stringify({ iss: 'supabase', role })).toString('base64url');
  return `eyJhbGciOiJIUzI1NiJ9.${payload}.notasignature`;
}

async function connected(env: NodeJS.ProcessEnv): Promise<Client> {
  const { server } = await serverFromEnvironment(env);
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  const client = new Client({ name: 'test-client', version: '0.0.0' });
  await Promise.all([client.connect(clientTransport), server.connect(serverTransport)]);
  return client;
}

function text(result: CallToolResult): string {
  return result.content.map((part) => (part.type === 'text' ? part.text : '')).join('\n');
}

describe('with an empty environment', () => {
  let client: Client;

  beforeAll(async () => {
    client = await connected({});
  });

  afterAll(async () => {
    await client.close();
  });

  it('completes the handshake under its own name', () => {
    expect(client.getServerVersion()?.name).toBe(SERVER_NAME);
  });

  it('lists the socle tools, and no module tool', async () => {
    const { tools } = await client.listTools();
    const names = tools.map((tool) => tool.name);
    for (const name of ['status', 'list_companies', 'create_document', 'post_document', 'vat_return']) {
      expect(names).toContain(name);
    }
    // Which modules an installation carries is read from its database; with
    // none, none is offered.
    expect(names.some((name) => name.startsWith('assets_') || name.startsWith('budgets_'))).toBe(false);
  });

  it('answers the prompts and the resource templates, which need no database to describe', async () => {
    const { prompts } = await client.listPrompts();
    expect(prompts.length).toBeGreaterThan(0);
    const { resourceTemplates } = await client.listResourceTemplates();
    expect(resourceTemplates.length).toBeGreaterThan(0);
  });

  it('answers a read with what to configure, as a tool error', async () => {
    const result = (await client.callTool({ name: 'status', arguments: {} })) as CallToolResult;
    expect(result.isError).toBe(true);
    const message = text(result);
    expect(message).toMatch(/^not_configured: /);
    expect(message).toContain('missing_configuration');
    for (const variable of [ENV.supabaseUrl, ENV.anonKey, ENV.email, ENV.password, ENV.accessToken, ENV.dbUrl, ENV.actAsUserId]) {
      expect(message).toContain(variable);
    }
    expect(message).toContain('npx ekwo-os init');
  });

  it('answers a write the same way, and books nothing', async () => {
    const result = (await client.callTool({
      name: 'post_document',
      arguments: { document_id: '11111111-1111-4111-8111-111111111111' },
    })) as CallToolResult;
    expect(result.isError).toBe(true);
    expect(text(result)).toMatch(/^not_configured: /);
  });
});

describe('with part of a configuration', () => {
  it('starts, and says which half is missing', async () => {
    const client = await connected({
      [ENV.supabaseUrl]: 'https://abcdefghijklmnopqrst.supabase.co',
      [ENV.anonKey]: keyWithRole('anon'),
    });
    const result = (await client.callTool({ name: 'list_companies', arguments: {} })) as CallToolResult;
    expect(result.isError).toBe(true);
    expect(text(result)).toContain('missing_credentials');
    await client.close();
  });

  it('starts without the user a database connection would act for, and connects nowhere', async () => {
    const client = await connected({ [ENV.dbUrl]: 'postgresql://nobody@127.0.0.1:1/none' });
    const result = (await client.callTool({ name: 'status', arguments: {} })) as CallToolResult;
    expect(result.isError).toBe(true);
    expect(text(result)).toContain('missing_act_as_user');
    await client.close();
  });
});

describe('what is wrong rather than missing', () => {
  it('still refuses a service_role key before anything starts', async () => {
    await expect(
      serverFromEnvironment({
        [ENV.supabaseUrl]: 'https://abcdefghijklmnopqrst.supabase.co',
        [ENV.anonKey]: keyWithRole('service_role'),
        [ENV.email]: 'you@example.test',
        [ENV.password]: 'a-long-password',
      }),
    ).rejects.toThrow(/service_role/);
  });

  it('still refuses a service_role key passed as the access token', async () => {
    await expect(
      serverFromEnvironment({
        [ENV.supabaseUrl]: 'https://abcdefghijklmnopqrst.supabase.co',
        [ENV.anonKey]: keyWithRole('anon'),
        [ENV.accessToken]: keyWithRole('service_role'),
      }),
    ).rejects.toThrow(/service_role/);
  });

  it('still refuses a user id that is not a uuid', async () => {
    await expect(
      serverFromEnvironment({ [ENV.dbUrl]: 'postgresql://nobody@127.0.0.1:1/none', [ENV.actAsUserId]: 'not-a-uuid' }),
    ).rejects.toThrow(/bad_act_as_user/);
  });
});
