/**
 * Machine keys: the ones a company issued, and issuing another.
 *
 * What the MCP tools `list_api_keys` and `create_api_key` answer and what
 * `ekwo key list` and `ekwo key create` print, from one place. A key's posting
 * mode is fixed here, when it is issued — `review` unless the person asks for
 * `autopilot` — and never at a call: the database ignores the mark a request
 * made with the key carries, and has no way to raise a key afterwards.
 */

import { type Backend, type Row } from './backend.js';
import * as columns from './columns.js';
import { only } from './shared.js';

/** How a key posts a document: as its company's setting says, or directly. */
export const KEY_POSTING = ['review', 'autopilot'] as const;
export type KeyPosting = (typeof KEY_POSTING)[number];

export interface ListApiKeysArgs {
  company_id: string;
  /** Also the ones withdrawn or expired. */
  include_withdrawn?: boolean;
}

export async function listApiKeys(backend: Backend, args: ListApiKeysArgs): Promise<unknown> {
  const keys = await backend.select<Row>({
    table: 'api_keys',
    columns: columns.API_KEY,
    where: [{ column: 'company_id', op: 'eq', value: args.company_id }],
    order: [{ column: 'created_at', ascending: false }],
  });

  const now = Date.now();
  const described = keys.map((key) => ({ ...key, state: apiKeyState(key, now) }));
  return {
    api_keys:
      args.include_withdrawn === true
        ? described
        : described.filter((key) => key.state === 'live'),
    note: 'The secret of a key exists only in the answer that created it. A key that is lost is withdrawn and issued again; so is a key wanted in another posting mode.',
  };
}

function apiKeyState(key: Row, now: number): string {
  if (key['revoked_at'] !== null && key['revoked_at'] !== undefined) return 'withdrawn';
  const expires = key['expires_at'];
  if (typeof expires === 'string' && Date.parse(expires) <= now) return 'expired';
  return 'live';
}

export interface CreateApiKeyArgs {
  company_id: string;
  name: string;
  capabilities: string[];
  expires_at?: string | null | undefined;
  /** Fixed for good. `autopilot` needs company.write, and a company that is not review_only. */
  posting_mode?: KeyPosting | undefined;
}

export async function createApiKey(backend: Backend, args: CreateApiKeyArgs): Promise<unknown> {
  const created = only(
    await backend.rpc<Row>('create_api_key', {
      p_company_id: args.company_id,
      p_name: args.name,
      p_capabilities: args.capabilities,
      p_expires_at: args.expires_at ?? null,
      p_posting_mode: args.posting_mode ?? 'review',
    }),
    'the key could not be issued',
  );
  return {
    api_key: created,
    note: 'The secret is in this answer and nowhere else — only its hash is stored. Show it to the user once, and tell them it cannot be read back.',
  };
}
