/**
 * `ekwo mcp` is the MCP server of `@ekwo-ai/mcp`, started from the command
 * line: the same `runStdio()` as `ekwo-mcp`, with the same flags — and so the
 * same session posting, `--autopilot` or `--review`.
 *
 * The server here is connected to an in-memory client instead of stdio, with
 * nothing configured: what is under test is that the command line hands the
 * server its arguments and nothing else, and that the server comes up in the
 * mode they ask for.
 */

import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import { describe, expect, it } from 'vitest';
import { npxArguments } from '../../packages/cli/src/commands/mcp.js';
import { run } from '../../packages/cli/src/index.js';
import { runStdio, serverFromEnvironment } from '../../packages/mcp/src/index.js';

/** `ekwo <argv>` with the server on an in-memory transport: its exit code, what it said, and a client on it. */
async function ekwoMcp(argv: string[]): Promise<{ exitCode: number; said: string; client: Client }> {
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  const client = new Client({ name: 'test-client', version: '0.0.0' });
  let said = '';
  const exitCode = await run(argv, {
    runMcp: (args) => runStdio(args, { env: {}, transport: serverTransport, log: (text) => void (said += text) }),
  });
  if (exitCode === 0) await client.connect(clientTransport);
  return { exitCode, said, client };
}

describe('ekwo mcp', () => {
  it('starts in autopilot with --autopilot', async () => {
    const { exitCode, said, client } = await ekwoMcp(['mcp', '--autopilot']);
    expect(exitCode).toBe(0);
    expect(said).toMatch(/Agents post in AUTOPILOT in this session/);
    await client.close();
  });

  it('starts in review with --review, and as each company says with neither', async () => {
    const review = await ekwoMcp(['mcp', '--review']);
    expect(review.said).toMatch(/Agents post in review in this session/);
    await review.client.close();
    const neither = await ekwoMcp(['mcp']);
    expect(neither.said).toMatch(/each company's agent_posting/);
    await neither.client.close();
  });

  it('is the server of ekwo-mcp: the same tools', async () => {
    const { client } = await ekwoMcp(['mcp']);
    const viaCli = (await client.listTools()).tools.map((tool) => tool.name).sort();
    await client.close();

    const { server } = await serverFromEnvironment({});
    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
    const direct = new Client({ name: 'test-client', version: '0.0.0' });
    await Promise.all([direct.connect(clientTransport), server.connect(serverTransport)]);
    expect(viaCli).toEqual((await direct.listTools()).tools.map((tool) => tool.name).sort());
    await direct.close();
  });

  it('refuses --autopilot and --review together, before anything starts', async () => {
    const errors: string[] = [];
    const write = process.stderr.write.bind(process.stderr);
    process.stderr.write = ((chunk: string | Uint8Array) => (errors.push(String(chunk)), true)) as typeof process.stderr.write;
    try {
      const { exitCode } = await ekwoMcp(['mcp', '--autopilot', '--review']);
      expect(exitCode).toBe(1);
    } finally {
      process.stderr.write = write;
    }
    expect(errors.join('')).toMatch(/conflicting_arguments/);
  });

  it('without the server installed beside it, asks npx for the one of its own release, with the same arguments', () => {
    expect(npxArguments(['--autopilot'], '0.19.0')).toEqual(['-y', '@ekwo-ai/mcp@0.19.0', '--autopilot']);
  });
});
