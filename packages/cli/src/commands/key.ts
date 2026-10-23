/**
 * `ekwo key list` and `ekwo key create` — `listApiKeys()` and `createApiKey()`
 * of the core, which are the MCP server's `list_api_keys` and `create_api_key`.
 *
 * A key's posting mode is chosen here, once: `--autopilot` issues a key that
 * posts a document without an approval, and nothing raises a key afterwards —
 * a key wanted in another mode is issued again. The database decides who may
 * (`company.write`, never in a company that is `review_only`).
 */

import { createApiKey, listApiKeys, type KeyPosting } from '@ekwo-ai/core';
import { UsageError, boolFlag, rejectUnknownFlags, stringFlag, stringFlags, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, openBooks, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { bold, dim, heading, note, pairs, table, warn } from '../ui.js';

const LIST_FLAGS = [...BOOKS_FLAGS, 'all'] as const;
const CREATE_FLAGS = [...BOOKS_FLAGS, 'capability', 'expires', 'autopilot'] as const;

const USAGE =
  'usage: ekwo key list [--all] | ekwo key create <name> --capability <code>… [--expires <timestamp>] [--autopilot]';

export async function keyCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  const action = args.positional[0];
  if (action === 'list') return list(args, deps);
  if (action === 'create') return create(args, deps);
  throw new UsageError(USAGE);
}

async function list(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, LIST_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const result = (await listApiKeys(backend, {
    company_id: company.id,
    include_withdrawn: boolFlag(args, 'all'),
  })) as { api_keys: Record<string, unknown>[] };
  setResult(result);

  heading(`Machine keys of ${company.name}`);
  if (result.api_keys.length === 0) note(dim('None.'));
  else {
    table(
      [{ title: 'name' }, { title: 'posting' }, { title: 'state' }, { title: 'capabilities' }, { title: 'id' }],
      result.api_keys.map((k) => [
        String(k['name']),
        String(k['posting_mode']),
        String(k['state']),
        (k['capabilities'] as string[]).join(', '),
        dim(String(k['id'])),
      ]),
    );
  }
  return 0;
}

async function create(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, CREATE_FLAGS);
  const name = args.positional[1];
  if (name === undefined || name.length === 0) {
    throw new UsageError(`missing_argument: what the key is for. ${USAGE}`);
  }
  const capabilities = stringFlags(args, 'capability');
  if (capabilities.length === 0) {
    throw new UsageError(`missing_argument: --capability, once per capability the key holds. ${USAGE}`);
  }
  const posting: KeyPosting = boolFlag(args, 'autopilot') ? 'autopilot' : 'review';

  const { backend, company } = await openBooks(args, deps);
  const result = (await createApiKey(backend, {
    company_id: company.id,
    name,
    capabilities,
    expires_at: stringFlag(args, 'expires') ?? null,
    posting_mode: posting,
  })) as { api_key: Record<string, unknown> };
  setResult(result);

  const key = result.api_key;
  heading(`Key issued, in ${company.name}`);
  pairs([
    ['name', name],
    ['posting', posting === 'autopilot' ? bold('autopilot') + ' — posts without an approval, on the audit trail' : "review — as the company's agent_posting says"],
    ['expires', String(key['expires_at'] ?? 'never')],
    ['id', dim(String(key['api_key_id']))],
    ['secret', String(key['secret'])],
  ]);
  warn('The secret is shown once and cannot be read back. A key is never raised to autopilot afterwards: issue another.');
  return 0;
}
