#!/usr/bin/env node
/**
 * The periodic return of one company, as the signed-in user.
 *
 * The command line has no verb for a return yet. The return itself is
 * `vat_return()`, a function of the schema; this script asks for it the way
 * an assistant does, through the published MCP server `@ekwo-ai/mcp`, over
 * stdio, as the person named — never as the owner of the database.
 *
 *   node vat-return.mjs <email> "<company name>" <from> <to>
 *
 * Reads SUPABASE_URL, SUPABASE_ANON_KEY and EKWO_PASSWORD from the
 * environment, like the server. EKWO_DB_URL is left out on purpose: with it
 * the server would connect as the owner, and row level security would not be
 * what answered.
 *
 * It prints the boxes the form prints, in the order the form prints them.
 * It computes nothing: every amount is the one the database returned.
 */

import { spawn } from 'node:child_process';

const [email, companyName, from, to] = process.argv.slice(2);
if (email === undefined || companyName === undefined || from === undefined || to === undefined) {
  process.stderr.write('usage: node vat-return.mjs <email> "<company name>" <from> <to>\n');
  process.exit(2);
}

const env = { ...process.env, EKWO_EMAIL: email };
delete env.EKWO_DB_URL;
delete env.SUPABASE_SERVICE_ROLE_KEY;

const server = spawn('npx', ['-y', '@ekwo-ai/mcp'], { env, stdio: ['pipe', 'pipe', 'pipe'] });

let buffer = '';
let said = '';
const waiting = new Map();
server.stderr.on('data', (chunk) => {
  said += chunk;
});
// A server that stops before answering — a refused sign-in, a package that
// did not install — says why on its stderr; that is what gets printed.
server.on('exit', () => {
  for (const settle of waiting.values()) settle({ error: { message: said.trim() || 'the MCP server stopped' } });
  waiting.clear();
});
server.stdin.on('error', () => {});
server.stdout.on('data', (chunk) => {
  buffer += chunk;
  let end;
  while ((end = buffer.indexOf('\n')) >= 0) {
    const line = buffer.slice(0, end).trim();
    buffer = buffer.slice(end + 1);
    if (line === '') continue;
    const message = JSON.parse(line);
    waiting.get(message.id)?.(message);
  }
});

let nextId = 1;
function request(method, params) {
  const id = nextId++;
  return new Promise((resolve, reject) => {
    waiting.set(id, (message) => {
      if (message.error !== undefined) reject(new Error(message.error.message));
      else resolve(message.result);
    });
    server.stdin.write(`${JSON.stringify({ jsonrpc: '2.0', id, method, params })}\n`);
  });
}

async function tool(name, args) {
  const result = await request('tools/call', { name, arguments: args });
  const text = result.content?.[0]?.text ?? '';
  if (result.isError === true) throw new Error(text);
  return JSON.parse(text);
}

try {
  await request('initialize', {
    protocolVersion: '2025-06-18',
    capabilities: {},
    clientInfo: { name: 'vat-return.mjs', version: '1' },
  });
  server.stdin.write(`${JSON.stringify({ jsonrpc: '2.0', method: 'notifications/initialized' })}\n`);

  const listed = await tool('list_companies', {});
  const companies = Array.isArray(listed) ? listed : listed.companies ?? [];
  const company = companies.find((c) => c.name === companyName);
  if (company === undefined) throw new Error(`no company named ${companyName} is visible to you`);

  const answer = await tool('vat_return', { company_id: company.id, from, to });
  const boxes = answer.boxes
    .filter((b) => b.hidden !== true)
    .sort((a, b) => a.print_sequence - b.print_sequence);

  process.stdout.write(`\n${company.name} — ${answer.report_code}, ${from} to ${to}\n\n`);
  const width = Math.max(...boxes.map((b) => b.amount.length));
  for (const b of boxes) {
    const name = b.name.length > 52 ? `${b.name.slice(0, 51)}…` : b.name;
    process.stdout.write(`  ${b.box.padEnd(4)} ${b.amount.padStart(width)}  ${name}\n`);
  }
  process.stdout.write('\n  Prepared, not filed: the figures are the ledger\'s; filing is yours.\n\n');
} catch (error) {
  process.stderr.write(`${error.message}\n`);
  process.exitCode = 1;
} finally {
  server.kill();
}
