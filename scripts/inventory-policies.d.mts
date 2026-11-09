/** Types for the inventory of the row level security policies, so `tests/` can import it. */
import type { PGlite } from '@electric-sql/pglite';

export type ExpressionVerdict = 'per row' | 'once' | '-';

/** What one expression of a policy asks, and how often. */
export interface ExpressionReading {
  verdict: ExpressionVerdict;
  /** The calls asked again for every row: `has_capability(company_id)`. */
  perRow: string[];
  /** Calls with no column, outside a sub-select: `is_known_caller()`. */
  bare: string[];
}

export interface PolicyRow {
  schema: string;
  table: string;
  policy: string;
  command: 'SELECT' | 'INSERT' | 'UPDATE' | 'DELETE' | 'ALL';
  using: ExpressionReading;
  withCheck: ExpressionReading;
}

/** A node of the tree `nodeToString()` writes, as plain objects. */
export type NodeTree = { node: string; [field: string]: unknown } | NodeTree[] | string | null;

export function parseNodeTree(text: string): NodeTree;
export function classifyExpression(
  tree: NodeTree | undefined,
  nameOf: ((oid: number) => string) & { column?: (attnum: number) => string },
): ExpressionReading;
export function policyInventory(db: PGlite): Promise<PolicyRow[]>;
export function inventory(): Promise<PolicyRow[]>;
export function policyKey(row: Pick<PolicyRow, 'schema' | 'table' | 'policy'>): string;
