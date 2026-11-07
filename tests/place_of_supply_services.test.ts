import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { packsDir, readTerritories } from '../packages/cli/src/index.js';
import {
  inventory,
  inventoryRow,
  type InventoryRow,
  type InventoryTax,
} from '../scripts/inventory-place-of-supply.mjs';

/**
 * A service to a taxable customer outside the European Union has a code
 * wherever the service to a customer of another Member State has one.
 *
 * Article 44 of Directive 2006/112/EC puts a service to a taxable person
 * where that person is established, in another Member State or outside the
 * European Union alike. The first half is an intra-Community service, with
 * its category `K`, its line of the return and the European statement of
 * services; the second is outside the scope of the seller's VAT, category
 * `O`, on another line and in no statement. A pack that carries only the
 * first leaves its user picking the code of a service inside the European
 * Union for a customer it
 * does not describe, or the export of goods for a sale that is not one. The
 * defect was found on one pack and was on twenty-two.
 *
 * The rule is read by `scripts/inventory-place-of-supply.mjs`, the inventory
 * replayed before every wave, so the inventory and this test cannot disagree:
 * a pack whose country is inside the common system of VAT in full (the row of
 * `territories` on the pack's `released_at`) and that names a sale with
 * treatment `intracom_services` names a sale with treatment `not_subject`.
 *
 * The packs are corrected wave by wave, so the rule holds every pack and lists
 * the ones still open by name. The list only shrinks: a pack that becomes
 * right has to leave it, and a pack that is not on it is refused.
 */

// country-literal: the packs still open on 6 November 2026, from the inventory; each wave removes its own
const STILL_OPEN = new Set([
  'at', 'bg', 'cy', 'cz', 'ee', 'fi', 'gr', 'hr',
  'hu', 'it', 'lt', 'mt', 'pl', 'pt', 'ro',
]);

const rows = await inventory();

async function packFiles(slug: string): Promise<{ manifest: { country?: string; released_at?: string }; taxes: InventoryTax[] }> {
  const dir = join(packsDir(), slug);
  return {
    manifest: JSON.parse(await readFile(join(dir, 'pack.json'), 'utf8')),
    taxes: JSON.parse(await readFile(join(dir, 'taxes.json'), 'utf8')),
  };
}

describe('a service to a taxable customer outside the European Union', () => {
  it('reads every pack of the repository', () => {
    expect(rows.length).toBeGreaterThan(0);
    expect(rows.some((row) => row.verdict === 'ok'), 'at least one pack carries the code the rule asks for').toBe(true);
  });

  it('is named by every pack inside the common system of the European Union that names an intra-Community service', () => {
    const refused = rows
      .filter((row) => row.verdict === 'open' && !STILL_OPEN.has(row.pack))
      .map(
        (row) =>
          `${row.pack}: ${row.cases.intracom_services.map((t) => t.code).join(', ')} and no sale with treatment not_subject`,
      );
    expect(refused, 'a pack that has an intra-Community service code and no code for the same service outside the European Union').toEqual([]);
  });

  it('keeps on the list of open packs only the packs still open', () => {
    const verdicts = new Map(rows.map((row) => [row.pack, row.verdict]));
    const stale = [...STILL_OPEN]
      .filter((pack) => verdicts.get(pack) !== 'open')
      .map((pack) => `${pack}: ${verdicts.get(pack) ?? 'no such pack'}`);
    expect(stale, 'remove these packs from STILL_OPEN: the rule now holds for them, or no longer applies').toEqual([]);
  });

  it('refuses a pack that loses the code, and accepts it back', async () => {
    const territories = await readTerritories(join(packsDir(), '..'));
    const right = rows.find((row) => row.verdict === 'ok') as InventoryRow;
    const { manifest, taxes } = await packFiles(right.pack);

    // The broken fixture: the same pack without its sales outside the scope.
    const broken = taxes.filter((tax) => !(tax.scope === 'sale' && tax.treatment === 'not_subject'));
    expect(broken.length).toBeLessThan(taxes.length);
    expect(inventoryRow(right.pack, manifest, broken, territories).verdict).toBe('open');

    expect(inventoryRow(right.pack, manifest, taxes, territories).verdict).toBe('ok');
  });

  it('does not apply where the country is outside the common system of the European Union, or names no intra-Community service', async () => {
    const territories = await readTerritories(join(packsDir(), '..'));
    const right = rows.find((row) => row.verdict === 'ok') as InventoryRow;
    const { manifest, taxes } = await packFiles(right.pack);
    const noService = taxes.filter((tax) => !(tax.scope === 'sale' && tax.treatment === 'intracom_services'));
    expect(inventoryRow(right.pack, manifest, noService.filter((t) => t.treatment !== 'not_subject'), territories).verdict).toBe('n/a');

    const outside = rows.find((row) => row.eu_vat_scope === 'none') as InventoryRow;
    expect(outside, 'a pack outside the common system').toBeDefined();
    const files = await packFiles(outside.pack);
    expect(inventoryRow(outside.pack, files.manifest, files.taxes, territories).verdict).toBe('n/a');
  });
});
