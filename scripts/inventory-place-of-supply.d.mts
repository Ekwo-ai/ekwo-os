/** Types for the inventory of the sales without tax, so `tests/` can import it. */
import type { Territory } from '../packages/cli/src/pack/territories.ts';

/** A sale tax as the inventory reads it from `taxes.json`. */
export interface InventoryTax {
  code: string;
  scope?: string;
  treatment?: string;
  vat_category?: string | null;
  exemption_code?: string | null;
  postings?: { invoice?: { type: string; box?: string | string[] | null }[] };
}

export interface InventoryCase {
  key: 'intracom_goods' | 'intracom_services' | 'export_goods' | 'services_abroad' | 'vessels_aircraft';
  title: string;
  is: (tax: InventoryTax) => boolean;
}

export type InventoryVerdict = 'ok' | 'open' | 'n/a';

export interface InventoryRow {
  pack: string;
  country: string;
  parent: string | null;
  eu_vat_scope: 'full' | 'goods' | 'none' | 'unknown';
  released_at: string;
  cases: Record<InventoryCase['key'], { code: string; boxes: string[] }[]>;
  verdict: InventoryVerdict;
}

export const CASES: InventoryCase[];
export function verdict(row: Omit<InventoryRow, 'verdict'>): InventoryVerdict;
export function inventoryRow(
  slug: string,
  manifest: { country?: string; released_at?: string },
  taxes: InventoryTax[],
  territories: Territory[],
): InventoryRow;
export function inventory(options?: { ref?: string | null }): Promise<InventoryRow[]>;
