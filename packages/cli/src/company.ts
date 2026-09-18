/**
 * The company a name or an id refers to, among those a caller can see.
 *
 * A name is what a person types and a uuid is what a script passes, so both
 * are accepted; an ambiguous name is refused rather than resolved to the first
 * match, because working on the wrong company is not a mistake anybody
 * notices the same day. The list is whatever the caller was allowed to read —
 * every company for the installer's connection, the ones row level security
 * lets through for a person — so a company somebody was never invited to is
 * simply unknown, which is also all they should learn about it.
 */

import { UsageError } from './args.js';

export function matchCompany<C extends { id: string; name: string }>(companies: readonly C[], wanted: string): C {
  const asked = wanted.toLowerCase();
  const matches = companies.filter((c) => c.id === asked || c.name.toLowerCase() === asked);
  if (matches.length === 0) {
    throw new UsageError(
      `unknown_company: no company called ${wanted}. This installation has: ${
        companies.length === 0 ? 'none' : companies.map((c) => c.name).join(', ')
      }`,
    );
  }
  if (matches.length > 1) {
    throw new UsageError(
      `ambiguous_company: ${matches.length} companies are called ${wanted}. Name one by its id: ${matches
        .map((c) => c.id)
        .join(', ')}`,
    );
  }
  return matches[0] as C;
}
