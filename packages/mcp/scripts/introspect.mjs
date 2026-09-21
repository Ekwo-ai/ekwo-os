#!/usr/bin/env node
/**
 * Starts the server the way a directory does — no environment, over stdio —
 * and asks it for its tools.
 *
 *   node packages/mcp/scripts/introspect.mjs                      # dist/bin.js
 *   node packages/mcp/scripts/introspect.mjs docker run -i --rm ekwo-mcp
 *
 * Exits non-zero unless the handshake completes, `tools/list` answers, and a
 * tool call comes back as a `not_configured` error rather than a crash. This
 * is the check the registries run, done before they run it.
 */

import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';

const packageRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const [command, ...args] =
  process.argv.length > 2 ? process.argv.slice(2) : [process.execPath, join(packageRoot, 'dist', 'bin.js')];

// Only what a process needs to run at all: nothing that could configure it.
const env = { PATH: process.env.PATH ?? '' };

const client = new Client({ name: 'ekwo-introspect', version: '0.0.0' });
await client.connect(new StdioClientTransport({ command, args, env, stderr: 'inherit' }));

const { tools } = await client.listTools();
if (tools.length === 0) throw new Error('tools/list answered with no tool');

const result = await client.callTool({ name: 'status', arguments: {} });
const text = result.content.map((part) => (part.type === 'text' ? part.text : '')).join('\n');
if (result.isError !== true || !text.startsWith('not_configured:')) {
  throw new Error(`status without a database should answer not_configured, and answered: ${text}`);
}

await client.close();
process.stdout.write(`${client.getServerVersion()?.name} ${client.getServerVersion()?.version}: ${tools.length} tools listed without a database\n`);
