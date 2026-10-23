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
import { ENV, sessionPostingFlag } from './config.js';
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

  // How this session posts, as a person chooses it for one session of a
  // coding agent: --autopilot, or --review. The flag is the variable, so a
  // client that can only pass variables chooses the same way.
  const posting = sessionPostingFlag(process.argv.slice(2));
  if (posting !== undefined) process.env[ENV.agentPosting] = posting;

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

How this session posts a document — review or autopilot:

  --autopilot             post directly in every company whose agent_posting
                          is review or autopilot; refused, autopilot_forbidden,
                          where it is review_only. Every posting is on the
                          audit trail, with this session.
  --review                post only what a person approved, whatever the
                          company's setting.
  EKWO_AGENT_POSTING      autopilot or review: the same, as a variable.

  Without either, each company's agent_posting decides (review by default).

Optional:

  EKWO_NO_REGISTER_INVITE 1 leaves the invitation to register out of the
                          instructions of an unregistered installation
  EKWO_NO_CLOUD_OFFER     1 leaves the offer of a free Ekwo Cloud account
                          out of the instructions (so does CI)

Row level security applies either way. This server has no privileges of its
own and refuses a service_role key.

Started with none of these, it still answers the client's list of tools, and
every tool call replies with what to set — nothing is connected until then.
`;

main().catch((error: unknown) => {
  process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
  process.exitCode = 1;
});
