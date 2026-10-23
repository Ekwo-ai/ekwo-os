/**
 * From an environment to a server, without the transport.
 *
 * `bin.ts` connects the result to stdio; the tests connect it to an in-memory
 * client. Keeping the two apart is what lets the "nothing configured" start be
 * tested exactly as a client meets it, without spawning a process.
 */

import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { FISCAL_SYSTEM_ENV, cloudOfferSilenced, directoryTransport, parseFiscalSystem, registrationInvitation, type EinvoiceTransport, type FiscalSystem } from '@ekwo-ai/core';
import type { Backend, Row } from './backend.js';
import { ENV, openBackend, readConfig } from './config.js';
import { assertSchemaSupported } from './schema.js';
import { buildServer } from './server.js';
import { installedModules } from './tools/modules.js';
import { postingOf } from './tools/read.js';
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
  const fiscalSystem = fiscalSystemFrom(env);
  const posting = await postingSummary(backend);
  return {
    server: buildServer(backend, {
      modules,
      inviteToRegister,
      offerCloud: !cloudOfferSilenced(env),
      ...(einvoiceTransport === undefined ? {} : { einvoiceTransport }),
      ...(fiscalSystem === undefined ? {} : { fiscalSystem }),
    }),
    backend,
    summary:
      `ekwo-mcp: connected over ${config.mode === 'sql' ? 'a direct Postgres connection' : 'PostgREST as the signed-in user'}` +
      `, schema ${schemaVersion}` +
      `${modules.length > 0 ? `, modules: ${modules.join(', ')}` : ''}` +
      `${einvoiceTransport === undefined ? '' : `, electronic invoices to the folder ${env[ENV.einvoiceDirectory]?.trim() ?? ''}`}` +
      `. ${posting}`,
  };
}

/**
 * How this session posts, said once at start-up: review, autopilot, or each
 * company's setting — and the companies where autopilot is refused. A read
 * that fails says nothing more than the choice: it is information, and never
 * stops a server from starting.
 */
export async function postingSummary(backend: Backend): Promise<string> {
  const choice = backend.agent?.posting;
  const said =
    choice === 'autopilot'
      ? 'Agents post in AUTOPILOT in this session: without an approval, each posting on the audit trail'
      : choice === 'review'
        ? 'Agents post in review in this session: only drafts a person approved'
        : "Agents post as each company's agent_posting says (review unless it says autopilot)";
  if (choice !== 'autopilot') return said;
  try {
    const companies = await backend.select<Row>({ table: 'companies', columns: ['id', 'name'], order: [{ column: 'name' }] });
    const refused = (await postingOf(backend, companies)).companies
      .filter((company) => company['posting_mode'] === 'autopilot_forbidden')
      .map((company) => String(company['name']));
    return refused.length === 0 ? said : `${said}; refused in ${refused.join(', ')}, which allow review only`;
  } catch {
    return said;
  }
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
 * The invoicing system fiscal records are chained by, from the JSON of
 * `EKWO_FISCAL_SYSTEM`. Unset, `einvoicing_fiscalise` asks for it by name; set
 * and malformed, the server refuses to start rather than chain records under
 * a system nobody described.
 */
export function fiscalSystemFrom(env: NodeJS.ProcessEnv): FiscalSystem | undefined {
  const value = env[FISCAL_SYSTEM_ENV]?.trim();
  return value === undefined || value === '' ? undefined : parseFiscalSystem(value);
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
