/**
 * `ekwo mcp [--autopilot|--review]` — the MCP server of `@ekwo-ai/mcp`, over
 * stdio, started from this command line: the same server as `ekwo-mcp`, with
 * the same flags and the same environment, and no second one carried here.
 *
 * This CLI holds one runtime dependency from outside this repository on
 * purpose (`tests/cli/package.test.ts`), and the server brings several. So
 * the server is not a dependency: where `@ekwo-ai/mcp` is installed beside
 * this CLI, its `runStdio()` runs in this process; where it is not — `npx
 * ekwo-os mcp` — the same package, at the version of this CLI, is started with
 * `npx`, on this process's standard streams and environment.
 *
 * stdout belongs to the protocol: nothing here writes to it, and there is no
 * `--json` document.
 */

import { spawn } from 'node:child_process';

/** `runStdio()` of `@ekwo-ai/mcp`. */
export type RunMcp = (argv: readonly string[]) => Promise<unknown>;

export interface McpDeps {
  /** The server to run instead of the installed one, for a test. */
  runMcp?: RunMcp;
}

export const MCP_PACKAGE = '@ekwo-ai/mcp';

/** `version` is this CLI's: the server fetched with `npx` is the one released with it. */
export async function mcpCommand(argv: readonly string[], version: string, deps: McpDeps = {}): Promise<number> {
  const run = deps.runMcp ?? (await installedServer());
  if (run === undefined) return serverThroughNpx(npxArguments(argv, version));
  try {
    await run(argv);
    return 0;
  } catch (error) {
    process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
    return 1;
  }
}

/** `runStdio` of the `@ekwo-ai/mcp` installed beside this CLI, if one is. */
async function installedServer(): Promise<RunMcp | undefined> {
  // A name in a variable, so the compiler does not resolve the package this
  // CLI deliberately does not depend on.
  const name: string = MCP_PACKAGE;
  try {
    const loaded = (await import(name)) as { runStdio?: RunMcp };
    return typeof loaded.runStdio === 'function' ? loaded.runStdio : undefined;
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === 'ERR_MODULE_NOT_FOUND') return undefined;
    throw error;
  }
}

/** What `npx` is asked to run: the server at the version of this CLI, with the same arguments. */
export function npxArguments(argv: readonly string[], version: string): string[] {
  return ['-y', `${MCP_PACKAGE}@${version}`, ...argv];
}

function serverThroughNpx(args: string[]): Promise<number> {
  const windows = process.platform === 'win32';
  const child = spawn(windows ? 'npx.cmd' : 'npx', args, {
    stdio: 'inherit',
    env: process.env,
    shell: windows,
  });
  // The client stops the server by stopping this process.
  const forward = (signal: NodeJS.Signals) => () => void child.kill(signal);
  process.on('SIGINT', forward('SIGINT'));
  process.on('SIGTERM', forward('SIGTERM'));
  return new Promise((resolve) => {
    child.on('error', (error) => {
      process.stderr.write(`ekwo mcp: could not start ${MCP_PACKAGE} with npx: ${error.message}\n`);
      resolve(1);
    });
    child.on('exit', (code, signal) => resolve(code ?? (signal === null ? 1 : 0)));
  });
}
