#!/usr/bin/env node
/**
 * `npx @ekwo-ai/mcp`, over stdio: `runStdio()`, which `ekwo mcp` of the
 * command line runs as well.
 */

import { runStdio } from './stdio.js';

runStdio(process.argv.slice(2)).catch((error: unknown) => {
  process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
  process.exitCode = 1;
});
