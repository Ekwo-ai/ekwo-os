#!/usr/bin/env node
/**
 * `npx @ekwo-ai/mcp`, over stdio.
 *
 * Everything comes from the environment, because that is how an MCP client
 * launches a server: a command and a block of variables in
 * `claude_desktop_config.json` or `.mcp.json`. Nothing is read from a file
 * and nothing is written to one — a credential cache would save one paste and
 * turn the first accidental `git add .` into a disclosure.
 *
 * stdout belongs to the protocol. Anything this process has to say to a human
 * goes to stderr, or the client sees a parse error instead of a server.
 */

import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { SERVER_VERSION } from './server.js';
import { serverFromEnvironment } from './start.js';

async function main(): Promise<void> {
  const argument = process.argv[2];
  if (argument === '--help' || argument === '-h') {
    process.stderr.write(HELP);
    return;
  }
  if (argument === '--version' || argument === '-v') {
    process.stderr.write(`${SERVER_VERSION}\n`);
    return;
  }

  // With nothing configured it still starts, so a client can list the tools;
  // each call then says what to set. A key that is there and wrong — a
  // service_role key above all — is still refused here, before any transport.
  const { server, backend, summary } = await serverFromEnvironment(process.env);

  const shutdown = async (): Promise<void> => {
    await server.close().catch(() => {});
    await backend.close().catch(() => {});
    process.exit(0);
  };
  process.on('SIGINT', () => void shutdown());
  process.on('SIGTERM', () => void shutdown());

  await server.connect(new StdioServerTransport());
  process.stderr.write(`${summary}\n`);
}

const HELP = `ekwo-mcp — the Model Context Protocol server for Ekwo OS.

It speaks MCP over stdio and is started by a client, not by hand. Configure it
in claude_desktop_config.json or .mcp.json with:

  SUPABASE_URL            https://<ref>.supabase.co
  SUPABASE_ANON_KEY       the anon (publishable) key — never the service_role key
  EKWO_EMAIL              the user this agent acts as
  EKWO_PASSWORD           their password
  EKWO_ACCESS_TOKEN       an access token, instead of the two above

For a self-hosted database, without PostgREST in front of it:

  EKWO_DB_URL             postgresql://…
  EKWO_ACT_AS_USER_ID     the auth.users id this server acts for — required,
                          because a database connection is nobody

Row level security applies either way. This server has no privileges of its
own and refuses a service_role key.

Started with none of these, it still answers the client's list of tools, and
every tool call replies with what to set — nothing is connected until then.
`;

main().catch((error: unknown) => {
  process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
  process.exitCode = 1;
});
