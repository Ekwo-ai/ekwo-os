/**
 * What a tool does to the books, said once, in its own definition.
 *
 * Every tool of this server is one of three: it **reads** (nothing changes),
 * it **adds** (a draft, a contact, a note, a setting — something a person can
 * look at, change back or leave unused), or it is **destructive** (it posts,
 * cancels, replaces, removes, or reaches outside the books — a key, a public
 * link, a file sent). The protocol carries that as two hints, `readOnlyHint`
 * and `destructiveHint`, and a client that reads them asks before the third
 * kind; one that ignores them works as before.
 *
 * The rule is held twice, and neither is a list kept beside the tools. The
 * type below makes a registration without its hints a compile error — see
 * `register` in `server.ts` — and `tests/mcp/surface.test.ts` reads what a
 * client is actually offered. `packages/mcp/TOOL_DESIGN.md` says how to choose.
 */

import type { ToolAnnotations } from '@modelcontextprotocol/sdk/types.js';

/** The three effects a tool can have, in increasing order of care. */
export const TOOL_EFFECTS = ['read', 'additive', 'destructive'] as const;

/** One of the effects above. */
export type ToolEffect = (typeof TOOL_EFFECTS)[number];

/**
 * The annotations a tool must carry: read-only, or a write that says whether
 * it destroys. Anything else the protocol allows (`idempotentHint`,
 * `openWorldHint`, `title`) may sit beside them.
 */
export type EffectAnnotations = ToolAnnotations &
  ({ readOnlyHint: true; destructiveHint?: never } | { readOnlyHint: false; destructiveHint: boolean });

/** What else a tool may say about itself, beside its effect. */
export interface EffectDetails {
  /** Calling it twice with the same arguments does what calling it once did. */
  idempotent?: boolean;
  /** It reaches something outside this database: a transport, a remote service. */
  openWorld?: boolean;
}

/** The protocol's hints for an effect. */
export function annotationsFor(effect: ToolEffect, details: EffectDetails = {}): EffectAnnotations {
  const openWorldHint = details.openWorld === true;
  if (effect === 'read') return { readOnlyHint: true, openWorldHint };
  return {
    readOnlyHint: false,
    destructiveHint: effect === 'destructive',
    ...(details.idempotent === undefined ? {} : { idempotentHint: details.idempotent }),
    openWorldHint,
  };
}

/**
 * The effect the hints of a tool say, or `undefined` when they say none —
 * which a tool of this server never does, and a test makes sure of.
 */
export function effectOf(annotations: ToolAnnotations | undefined): ToolEffect | undefined {
  if (annotations?.readOnlyHint === true) return 'read';
  if (annotations?.readOnlyHint !== false || typeof annotations.destructiveHint !== 'boolean') return undefined;
  return annotations.destructiveHint ? 'destructive' : 'additive';
}
