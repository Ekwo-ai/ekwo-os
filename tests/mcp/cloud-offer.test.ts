/**
 * The offer of a free Ekwo Cloud account, as the MCP server gives it.
 *
 * Once, in the instructions a client reads at the handshake, for the agent to
 * relay to its person after a first task — and in no tool result. The server
 * started from the environment gives it unless `EKWO_NO_CLOUD_OFFER` or `CI`
 * is set; a server built without asking for it, the hosted connector's, never
 * does.
 */

import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import { describe, expect, it } from 'vitest';
import { cloudSignupUrl, relayableCloudOffer } from '../../packages/core/src/index.js';
import {
  INSTRUCTIONS,
  buildServer,
  instructionsFor,
  type ServerOptions,
  unconfiguredBackend,
} from '../../packages/mcp/src/index.js';

async function connect(options: ServerOptions): Promise<Client> {
  const server = buildServer(unconfiguredBackend(new Error('not configured')), options);
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  const client = new Client({ name: 'test-client', version: '0.0.0' });
  await Promise.all([client.connect(clientTransport), server.connect(serverTransport)]);
  return client;
}

describe('the Cloud offer of the MCP server', () => {
  it('is one paragraph of the instructions, linking with src=mcp', async () => {
    const client = await connect({ offerCloud: true });
    const instructions = client.getInstructions() ?? '';
    expect(instructions.startsWith(INSTRUCTIONS)).toBe(true);
    expect(instructions.slice(INSTRUCTIONS.length).trim()).toBe(relayableCloudOffer());
    expect(instructions.split(cloudSignupUrl('mcp'))).toHaveLength(2);
    await client.close();
  });

  it('is in no tool description', async () => {
    const client = await connect({ offerCloud: true });
    const { tools } = await client.listTools();
    for (const tool of tools) expect(tool.description ?? '', tool.name).not.toContain('cloud.ekwo.ai/signup');
    await client.close();
  });

  it('is absent unless the server was started to give it, and follows the invitation to register', () => {
    expect(instructionsFor({})).toBe(INSTRUCTIONS);
    expect(instructionsFor({ offerCloud: false })).toBe(INSTRUCTIONS);
    const both = instructionsFor({ inviteToRegister: true, offerCloud: true });
    expect(both.indexOf('register --email')).toBeLessThan(both.indexOf(cloudSignupUrl('mcp')));
  });
});
