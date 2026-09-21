/**
 * What `/multi-country/` claims, and the file each claim rests on.
 *
 * The words are the language's (`strings.multi`, by the same keys); this file
 * carries what a translation must not touch: the icon, and the **proof** — a
 * path in this repository that is the reason the line says what it says.
 * `tests/site.test.ts` fails if a path does not exist, and if a key has no
 * words or words have no key.
 *
 * Two lists, and nothing between them. `SHIPPED` is what a function, a
 * migration, a command or a tool does today. `LATER` is what a business in
 * several countries will look for and not find: `planned` where the repository
 * says it is coming, and `notYet` where it does not — said so, with no date.
 * A `notYet` links to the file that states the gap where one does; where
 * nothing in the repository mentions it at all, there is nothing to link to.
 */

export interface Audience {
  key: string;
  icon: string;
}

export interface ShippedClaim {
  key: string;
  icon: string;
  proof: string;
}

export interface LaterClaim {
  key: string;
  status: 'planned' | 'notYet';
  /** Where the repository says it is coming; null for what nothing mentions yet. */
  proof: string | null;
}

/** Who the page is for, in the order the page speaks to them. */
export const AUDIENCES: Audience[] = [
  { key: 'group', icon: 'building' },
  { key: 'firm', icon: 'briefcase' },
  { key: 'expand', icon: 'rocket' },
];

export const SHIPPED: ShippedClaim[] = [
  { key: 'companies', icon: 'database', proof: 'docs/firms.md' },
  { key: 'create', icon: 'packageOpen', proof: 'packages/mcp/src/tools/write.ts' },
  { key: 'currency', icon: 'coins', proof: 'supabase/migrations/20260912112132_cash_basis_vat_and_fx.sql' },
  { key: 'roles', icon: 'users', proof: 'supabase/migrations/20260911120000_core_companies.sql' },
  { key: 'portfolio', icon: 'calendarClock', proof: 'supabase/migrations/20260918130000_every_company_somebody_keeps.sql' },
  { key: 'tools', icon: 'terminal', proof: 'packages/mcp/src/server.ts' },
  { key: 'archive', icon: 'download', proof: 'docs/company-archive.md' },
  { key: 'describe', icon: 'globe', proof: 'packages/cli/src/commands/pack.ts' },
];

export const LATER: LaterClaim[] = [
  { key: 'consolidation', status: 'planned', proof: 'docs/international.md' },
  { key: 'intercompany', status: 'notYet', proof: null },
  { key: 'revaluation', status: 'notYet', proof: 'supabase/migrations/20260912112132_cash_basis_vat_and_fx.sql' },
  { key: 'teams', status: 'notYet', proof: 'docs/firms.md' },
];
