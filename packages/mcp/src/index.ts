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
  type Backend,
  type Filter,
  type Order,
  type Row,
  type SelectQuery,
} from './backend.js';
export { ENV, isServiceRoleKey, openBackend, readConfig, type Config } from './config.js';
export { amountIn, decimal, money, moneyFields, type Decimal } from '@ekwo-ai/core';
export { connect, sqlBackend, type SqlBackendOptions, type SqlClient } from './sql.js';
export { API_KEY_HEADER, postgrestBackend, type PostgrestBackendOptions } from './postgrest.js';
export {
  checkConnection,
  handleHttpRequest,
  handleNodeRequest,
  openHttpBackend,
  type HttpConnection,
  type HttpHandlerOptions,
} from './http.js';
export { SERVER_NAME, SERVER_VERSION, buildServer, type ServerOptions } from './server.js';
export { SCHEMA_MIN, assertSchemaSupported, installedSchemaVersion } from './schema.js';
export { serverFromEnvironment, type Started } from './start.js';
export { isMissingConfiguration, unconfiguredBackend } from './unconfigured.js';
export * as readTools from './tools/read.js';
export * as writeTools from './tools/write.js';
export {
  MODULE_TOOLSETS,
  installedModules,
  toolsetsFor,
  type ModuleTool,
  type ModuleToolset,
} from './tools/modules.js';
