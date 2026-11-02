/**
 * Which tools a client sees first, and how it finds the rest.
 *
 * A server that offers every tool at the handshake hands a model well over a
 * hundred descriptions before the first question — most of them about a
 * module or a report the session will never touch. So a host may ask for
 * **on demand** instead: the session starts with the tools of a first
 * session with a set of books (`CORE_TOOLS`), and two more — `search_tools`,
 * which finds a tool by what it does, and `load_tools`, which adds it. The
 * client is told the list changed and reads it again.
 *
 * **All** stays the default: a client that never re-reads its tool list, or
 * ignores the notification, sees every tool from the start, as it always did.
 * Nothing here is a permission: a tool not loaded yet is one call away, and
 * what a tool may do is still the database's to decide.
 */

import type { RegisteredTool } from '@modelcontextprotocol/sdk/server/mcp.js';
import { effectOf, type ToolEffect } from './effect.js';

/** How the tools of a session are offered. */
export const TOOL_LOADING = ['all', 'on_demand'] as const;

/** One of the two ways above. */
export type ToolLoading = (typeof TOOL_LOADING)[number];

/** The two tools that find and add the others, offered only on demand. */
export const LOADING_TOOLS = ['search_tools', 'load_tools'] as const;

/**
 * What an on-demand session starts with: the five steps of a first session
 * the server's instructions describe — who you are, which company, its
 * accounts and pack, a contact, a document posted and paid — and the three
 * reports a first question about the books usually asks for. A test keeps
 * every name here one the server offers.
 */
export const CORE_TOOLS = [
  'status',
  'list_companies',
  'get_company',
  'list_accounts',
  'describe_pack',
  'search_contacts',
  'create_contact',
  'list_documents',
  'get_document',
  'create_document',
  'post_document',
  'record_payment',
  'trial_balance',
  'general_ledger',
  'vat_return',
] as const;

/** The paragraph of the instructions an on-demand session adds. */
export const ON_DEMAND_INSTRUCTIONS =
  'This session starts with the tools of a first session; the others are loaded when you need them. search_tools finds a tool by what it does — a word of the task, such as "fixed asset", "contract" or "bank statement" — and says whether it reads, adds or destroys; load_tools adds the ones you name, and the tool list changes. A tool named in these instructions that you do not see is one load_tools away.';

/** One tool, as `search_tools` answers it. */
export interface FoundTool {
  name: string;
  title: string;
  effect: ToolEffect | null;
  loaded: boolean;
  /** The first sentence of its description. */
  summary: string;
}

const WORD = /[\p{L}\p{N}]+/gu;

function words(text: string): string[] {
  return (text.toLowerCase().match(WORD) ?? []).map((word) => word.replace(/s$/, ''));
}

function firstSentence(text: string): string {
  const end = text.search(/[.!?](\s|$)/);
  return end === -1 ? text : text.slice(0, end + 1);
}

/**
 * The tools that answer a query, best first: a word of the query found in
 * the name counts three, in the title two, in the description one. Without a
 * query, every tool, by name. Filtered by effect when one is given.
 */
export function searchTools(
  tools: ReadonlyMap<string, RegisteredTool>,
  query: string | undefined,
  effect: ToolEffect | undefined,
  limit: number,
): { tools: FoundTool[]; total: number } {
  const asked = [...new Set(words(query ?? ''))];
  const scored: { tool: FoundTool; score: number }[] = [];
  for (const [name, registered] of tools) {
    if ((LOADING_TOOLS as readonly string[]).includes(name)) continue;
    const found: FoundTool = {
      name,
      title: registered.title ?? name,
      effect: effectOf(registered.annotations) ?? null,
      loaded: registered.enabled,
      summary: firstSentence(registered.description ?? ''),
    };
    if (effect !== undefined && found.effect !== effect) continue;
    const inName = new Set(words(name.replace(/_/g, ' ')));
    const inTitle = new Set(words(found.title));
    const inDescription = new Set(words(registered.description ?? ''));
    let score = 0;
    for (const word of asked) {
      score += (inName.has(word) ? 3 : 0) + (inTitle.has(word) ? 2 : 0) + (inDescription.has(word) ? 1 : 0);
    }
    if (asked.length === 0 || score > 0) scored.push({ tool: found, score });
  }
  scored.sort((a, b) => b.score - a.score || a.tool.name.localeCompare(b.tool.name));
  return { tools: scored.slice(0, limit).map((entry) => entry.tool), total: scored.length };
}

/**
 * Adds the tools named, and says which were added, which were there already
 * and which this server does not have. Enabling a tool tells a connected
 * client that the list changed.
 */
export function loadTools(
  tools: ReadonlyMap<string, RegisteredTool>,
  names: readonly string[],
): { loaded: string[]; already_loaded: string[]; unknown: string[] } {
  const loaded: string[] = [];
  const already: string[] = [];
  const unknown: string[] = [];
  for (const name of [...new Set(names)]) {
    const tool = tools.get(name);
    if (tool === undefined) unknown.push(name);
    else if (tool.enabled) already.push(name);
    else {
      tool.enable();
      loaded.push(name);
    }
  }
  return { loaded, already_loaded: already, unknown };
}

/** Leaves the core and the two loading tools, and hides the others until loaded. */
export function startOnDemand(tools: ReadonlyMap<string, RegisteredTool>): void {
  const kept = new Set<string>([...CORE_TOOLS, ...LOADING_TOOLS]);
  for (const [name, tool] of tools) {
    if (!kept.has(name)) tool.disable();
  }
}
