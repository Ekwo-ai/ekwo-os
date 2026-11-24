/**
 * What this server needs of the database it is pointed at.
 *
 * An MCP client is installed by whoever wants an agent, and the database
 * it reaches was installed by whoever runs the books — two decisions, two
 * dates. So the server asks the schema its version before it answers anything.
 *
 * Down to the floor, `SCHEMA_MIN`, it answers in full: what a newer release
 * added is named in `SCHEMA_FEATURES` of the core and asked for only where the
 * schema has it. Below the floor, it still opens the installation, for
 * reading: a newer client never locks a person out of their own books behind
 * "update first". Every tool that writes is refused by name, with the command
 * that upgrades the database, and a read that reaches for what the schema
 * lacks is refused the same way rather than answered half. The alternative is
 * what an agent does with a missing column: it improvises, and the
 * improvisation is an accounting entry.
 *
 * Declared in `package.json` under `ekwo.schemaMin`, as a country pack
 * declares it in its manifest, and repeated here as a constant so a bundle
 * that never reads a manifest still carries it.
 */

import { schemaIsAtLeast } from '@ekwo-ai/core';
import { EkwoMcpError, type Backend } from './backend.js';

/** The oldest schema this server speaks to. */
export const SCHEMA_MIN = '0.19.0';

/** The version the migrations of that database define. */
export async function installedSchemaVersion(backend: Backend): Promise<string | undefined> {
  try {
    const rows = await backend.rpc<string>('ekwo_schema_version');
    const version = rows[0];
    return typeof version === 'string' ? version : undefined;
  } catch {
    // A database that has no such function is not an Ekwo database at this
    // version — which is exactly what the caller is about to say.
    return undefined;
  }
}

/** The command that brings a database back above the floor. */
export const UPGRADE_COMMAND = 'npx -y ekwo-os@latest migrate';

/** The version a database is at, and whether this server writes to it. */
export interface SchemaStatus {
  installed: string;
  /** Older than `SCHEMA_MIN`: opened for reading only. */
  belowFloor: boolean;
}

/**
 * The version of the database, and whether it is below the floor.
 *
 * A database that cannot answer at all is refused: `ekwo_schema_version()`
 * has existed since the first migration, so a silence means the schema is not
 * installed rather than that it is old.
 */
export async function readSchemaStatus(backend: Backend): Promise<SchemaStatus> {
  const installed = await installedSchemaVersion(backend);
  if (installed === undefined) {
    throw new EkwoMcpError(
      `schema_not_found: this database does not answer ekwo_schema_version(), so it does not carry the Ekwo schema. Run \`npx ekwo-os init\` against it first.`,
    );
  }
  return { installed, belowFloor: !schemaIsAtLeast(installed, SCHEMA_MIN) };
}

/**
 * The refusal of one tool on a database below the floor: a write, or a read
 * that asked for something the installed schema does not have.
 */
export function belowFloorRefusal(tool: string, installed: string, kind: 'write' | 'read'): EkwoMcpError {
  const what =
    kind === 'write'
      ? `${tool} writes, and this database is at ${installed}, below ${SCHEMA_MIN}, the oldest schema @ekwo-ai/mcp writes to. The tools that read still answer.`
      : `${tool} reads what schema ${SCHEMA_MIN} or newer has, and this database is at ${installed}. The other tools that read still answer.`;
  return new EkwoMcpError(`schema_too_old: ${what} Run \`${UPGRADE_COMMAND}\` against it to bring it up to date.`, {
    hint: 'Upgrading the database is the fix, never pinning this server: the schema moves forward only, and nothing in the books is lost by the upgrade.',
  });
}

/**
 * What Postgres or PostgREST says when a read asked for a column, a function
 * or a table the schema does not have.
 */
export const MISSING_OBJECT = /\b(column|function|relation|table) [^\s]+ does not exist|could not find the (function|column|table)|\b(42703|42883|42P01|PGRST20[024])\b/i;

/**
 * The strict check: refuses a database older than this server, and says
 * which way to fix it. The server itself opens such a database for reading
 * (`readSchemaStatus`); this is for a caller that only goes on above the floor.
 */
export async function assertSchemaSupported(backend: Backend): Promise<string> {
  const { installed, belowFloor } = await readSchemaStatus(backend);
  if (belowFloor) {
    throw new EkwoMcpError(
      `schema_too_old: this database is at ${installed} and @ekwo-ai/mcp needs ${SCHEMA_MIN} or newer. Run \`${UPGRADE_COMMAND}\` against it, then start this server again.`,
      {
        hint: 'Upgrading the database is the fix, never pinning this server: the schema moves forward only, and an older client would be reading rows that no longer mean what it thinks.',
      },
    );
  }
  return installed;
}
