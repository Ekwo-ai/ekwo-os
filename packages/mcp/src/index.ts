/**
 * The server as a library.
 *
 * Exported so the tests can call every tool handler directly against a real
 * Postgres — the same functions the protocol calls — and so another host can
 * mount this server on a transport of its own instead of shelling out to
 * `npx`.
 */

export {
  EkwoMcpError,
  explain,
  socleCode,
  type AgentSession,
  type Backend,
  type Filter,
  type Order,
  type Row,
  type SelectQuery,
  type SessionPosting,
} from './backend.js';
export { ENV, isServiceRoleKey, openBackend, readConfig, sessionPostingFlag, sessionPostingFrom, type Config } from './config.js';
export { amountIn, decimal, money, moneyFields, type Decimal } from '@ekwo-ai/core';
export { connect, sqlBackend, type SqlBackendOptions, type SqlClient } from './sql.js';
export { AGENT_HEADER, AGENT_SESSION_HEADER, API_KEY_HEADER, postgrestBackend, type PostgrestBackendOptions } from './postgrest.js';
export {
  checkConnection,
  handleHttpRequest,
  handleNodeRequest,
  openHttpBackend,
  type HttpConnection,
  type HttpHandlerOptions,
} from './http.js';
export {
  INSTRUCTIONS,
  SERVER_NAME,
  SERVER_VERSION,
  buildServer,
  instructionsFor,
  type ServerOptions,
} from './server.js';
export { SCHEMA_MIN, assertSchemaSupported, installedSchemaVersion } from './schema.js';
export { einvoiceTransportFrom, postingSummary, serverFromEnvironment, shouldInviteToRegister, type Started } from './start.js';
export { STDIO_HELP, runStdio, type StdioOptions } from './stdio.js';
export { isMissingConfiguration, unconfiguredBackend } from './unconfigured.js';
export * as readTools from './tools/read.js';
export * as writeTools from './tools/write.js';
export {
  MODULE_TOOLSETS,
  installedModules,
  toolsetsFor,
  type ModulePrompt,
  type ModuleTool,
  type ModuleToolContext,
  type ModuleToolset,
} from './tools/modules.js';
