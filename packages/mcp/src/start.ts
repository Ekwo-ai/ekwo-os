/**
 * From an environment to a server, without the transport.
 *
 * `bin.ts` connects the result to stdio; the tests connect it to an in-memory
 * client. Keeping the two apart is what lets the "nothing configured" start be
 * tested exactly as a client meets it, without spawning a process.
 */

import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { directoryTransport, registrationInvitation, type EinvoiceTransport } from '@ekwo-ai/core';
import type { Backend } from './backend.js';
import { ENV, openBackend, readConfig } from './config.js';
import { assertSchemaSupported } from './schema.js';
import { buildServer } from './server.js';
import { installedModules } from './tools/modules.js';
import { isMissingConfiguration, unconfiguredBackend } from './unconfigured.js';

export interface Started {
  server: McpServer;
  backend: Backend;
  /** One line for stderr: how this server is connected, or why it is not. */
  summary: string;
}

export async function serverFromEnvironment(env: NodeJS.ProcessEnv = process.env): Promise<Started> {
  let config;
  try {
    config = readConfig(env);
  } catch (error) {
    if (!isMissingConfiguration(error)) throw error;
    // Nothing to connect to: the tools are offered, and each call says what
    // to set. The socle's tools only — which modules an installation carries
    // is a question for a database this server does not have.
    const reason = error as Error;
    const backend = unconfiguredBackend(reason);
    return {
      server: buildServer(backend),
      backend,
      summary: `ekwo-mcp: started without a database — every tool will answer with what to configure. ${reason.message}`,
    };
  }

  const backend = await openBackend(config);
  // Before anything else: a database older than this server is refused by
  // name rather than answered from wrong assumptions.
  const schemaVersion = await assertSchemaSupported(backend);
  // What this installation carries, from the registry table. A database that
  // predates the module framework answers with nothing, and the socle's own
  // tools are all a client then sees.
  const modules = await installedModules(backend);
  const inviteToRegister = await shouldInviteToRegister(backend, env);
  const einvoiceTransport = einvoiceTransportFrom(env);
  return {
    server: buildServer(backend, {
      modules,
      inviteToRegister,
      ...(einvoiceTransport === undefined ? {} : { einvoiceTransport }),
    }),
    backend,
    summary:
      `ekwo-mcp: connected over ${config.mode === 'sql' ? 'a direct Postgres connection' : 'PostgREST as the signed-in user'}` +
      `, schema ${schemaVersion}` +
      `${modules.length > 0 ? `, modules: ${modules.join(', ')}` : ''}` +
      `${einvoiceTransport === undefined ? '' : `, electronic invoices to the folder ${env[ENV.einvoiceDirectory]?.trim() ?? ''}`}`,
  };
}

/**
 * The transport electronic invoices leave through, from the environment: the
 * folder of `EKWO_EINVOICE_DIRECTORY`, the one transport this release ships.
 * Unset, files are issued and kept and sending is refused by name. A network
 * transport is handed to `buildServer()` by the host that operates it, the
 * same way.
 */
export function einvoiceTransportFrom(env: NodeJS.ProcessEnv): EinvoiceTransport | undefined {
  const directory = env[ENV.einvoiceDirectory]?.trim();
  return directory === undefined || directory === '' ? undefined : directoryTransport(directory);
}

/**
 * True when the instance row says the installation is not registered with
 * Ekwo and the environment did not silence the invitation. A row this user
 * may not read, or a read that fails, gives no invitation: it is a courtesy,
 * and a courtesy never stops a server from starting.
 */
export async function shouldInviteToRegister(backend: Backend, env: NodeJS.ProcessEnv): Promise<boolean> {
  try {
    const rows = await backend.select<{ registered_at: string | null }>({
      table: 'instance',
      columns: ['registered_at::text'],
    });
    const row = rows[0];
    return row !== undefined && registrationInvitation(row.registered_at, env) !== null;
  } catch {
    return false;
  }
}
