/**
 * The server before anybody has told it where the books are.
 *
 * An MCP client lists a server's tools the moment it is added, and so do the
 * directories that index servers — they start the package with no
 * environment and ask for `tools/list`. A server that exits on a missing
 * variable shows up there as "failed to start", and in Claude Desktop as a red
 * dot with the reason buried in a log file. So when the connection is simply
 * *absent*, the server starts anyway, offers its tools, and every call answers
 * with what to set and where. Nothing is connected and nothing is guessed:
 * there is no default database, and no tool pretends to have read one.
 *
 * Only absence is forgiven. A `service_role` key or a malformed user id is a
 * configuration somebody wrote, and it is refused at start as before.
 */

import { ENV } from './config.js';
import { EkwoMcpError, type Backend } from './backend.js';

/**
 * The refusals of `readConfig` that mean "nothing, or not enough, was set".
 * Everything else it raises is a value that is there and wrong.
 */
const ABSENT = ['missing_configuration', 'missing_credentials', 'missing_act_as_user'] as const;

/** Whether a configuration error only says that something is missing. */
export function isMissingConfiguration(error: unknown): boolean {
  if (!(error instanceof EkwoMcpError)) return false;
  return ABSENT.some((code) => error.message.startsWith(`${code}:`));
}

const HINT =
  `Add the variables to the "env" block of this server in claude_desktop_config.json or .mcp.json, then restart the client. ` +
  `Recommended: ${ENV.supabaseUrl}, ${ENV.anonKey} (the anon key, never the service_role key) and either ${ENV.email} with ${ENV.password} or ${ENV.accessToken}. ` +
  `Self-hosted without PostgREST: ${ENV.dbUrl} and ${ENV.actAsUserId}. ` +
  'No database yet: `npx ekwo-os init` installs the schema into a Supabase project or a Postgres. ' +
  'Tell the user this; do not retry the call.';

/**
 * A backend that refuses every call with the reason the server has none.
 *
 * `mode` says `postgrest` because that is the route the message recommends;
 * no call reaches the point where it is read.
 */
export function unconfiguredBackend(reason: Error): Backend {
  const refuse = (): Promise<never> =>
    Promise.reject(
      new EkwoMcpError(`not_configured: this server has no connection to an Ekwo database yet. ${reason.message}`, {
        code: 'not_configured',
        hint: HINT,
      }),
    );
  return {
    mode: 'postgrest',
    actingAs: undefined,
    rpc: refuse,
    rpcVoid: refuse,
    select: refuse,
    insert: refuse,
    update: refuse,
    remove: refuse,
    close: () => Promise.resolve(),
  };
}
