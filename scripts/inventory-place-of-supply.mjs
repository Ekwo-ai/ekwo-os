#!/usr/bin/env node
/**
 * Which sales without tax each country pack can book, and where each reports.
 *
 * A company sells services to businesses at home, in other Member States of
 * the European Union and outside it. Each of those sales is a different
 * operation in the law: an intra-Community supply, a service whose place of
 * supply is the customer's, an export of goods. Each lands on its own line of
 * the return and carries its own words on the invoice. A pack that has a code
 * for the service to a business in another Member State and none for the same
 * service to a business outside the European Union leaves its user without a
 * line to pick, and the defect, found once, is checked here on every pack.
 *
 * The script reads every pack — the checkout's `packs/` by default, or the
 * packs of a git ref with `--ref origin/main` — and prints one row per pack:
 *
 * - the territory and its VAT scope as the core records them
 *   (`supabase/seed/00_territories.sql`, read at the same ref, on the pack's
 *   `released_at`), with the parent territory where there is one;
 * - for each case, the sale codes found with the box of the return their base
 *   posts to, or `absent`:
 *   - intra-Community delivery of goods (`treatment` `intracom_goods`);
 *   - intra-Community service (`intracom_services`);
 *   - export of goods (`export`);
 *   - service outside the scope because its place of supply is abroad
 *     (`not_subject`): inside the European Union, the service to a taxable
 *     customer established outside it, category `O` of UNCL5305 with
 *     `VATEX-EU-O`; outside the European Union, a service supplied abroad;
 *   - exempt supplies for vessels and aircraft (`exempt` with an exemption
 *     code of article 148 of Directive 2006/112/EC, `VATEX-EU-148-*`). Outside
 *     the European Union there is no VATEX code to read, and the cell says so;
 * - the verdict of the rule `tests/place_of_supply_services.test.ts` holds
 *   every pack to: a pack whose country applies the common system of VAT in
 *   full and that has an intra-Community service code names the service to a
 *   customer outside the European Union too. `ok`, `open`, or `n/a` where the
 *   rule does not apply.
 *
 * Everything is read from the treatments, the categories and the exemption
 * codes the pack declares, never from a name: a name is in the pack's
 * language and a treatment is not.
 *
 *     node scripts/inventory-place-of-supply.mjs                    # the checkout
 *     node scripts/inventory-place-of-supply.mjs --ref origin/main  # a ref
 *     node scripts/inventory-place-of-supply.mjs --json
 *
 * Needs Node 22.18 or later: it imports the reader of the territories seed
 * from the command line's TypeScript source, so the script and `ekwo pack
 * check` read the table the same way.
 */

import { execFileSync } from 'node:child_process';
import { readdir, readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { euVatScopeOf, parseTerritorySeed, territoryOf } from '../packages/cli/src/pack/territories.ts';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');

/** A pack directory is a lower-case ISO code; `generic` and `ohada` are not packs of a country. */
const PACK = /^[a-z]{2}$/;

/** The cases, in the order of the table, each with how a sale tax is recognised as one. */
export const CASES = [
  { key: 'intracom_goods', title: 'Intra-Community delivery', is: (tax) => tax.treatment === 'intracom_goods' },
  { key: 'intracom_services', title: 'Intra-Community service', is: (tax) => tax.treatment === 'intracom_services' },
  { key: 'export_goods', title: 'Export of goods', is: (tax) => tax.treatment === 'export' },
  {
    key: 'services_abroad',
    title: 'Service supplied abroad (outside the European Union)',
    is: (tax) => tax.treatment === 'not_subject',
  },
  {
    key: 'vessels_aircraft',
    title: 'Vessels and aircraft (article 148)',
    is: (tax) => tax.treatment === 'exempt' && /^VATEX-EU-148/.test(tax.exemption_code ?? ''),
  },
];

/** Reads the files of one ref, or of the checkout when `ref` is null. */
function reader(ref) {
  if (ref === null) {
    return {
      async list() {
        const entries = await readdir(join(root, 'packs'), { withFileTypes: true });
        return entries.filter((e) => e.isDirectory() && PACK.test(e.name)).map((e) => e.name).sort();
      },
      async read(path) {
        try {
          return await readFile(join(root, path), 'utf8');
        } catch {
          return null;
        }
      },
    };
  }
  const git = (...args) => execFileSync('git', args, { cwd: root, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
  return {
    async list() {
      return git('ls-tree', '--name-only', `${ref}:packs`)
        .split('\n')
        .filter((name) => PACK.test(name))
        .sort();
    },
    async read(path) {
      try {
        return git('show', `${ref}:${path}`);
      } catch {
        return null;
      }
    },
  };
}

/** The boxes a sale tax's base posts to on an invoice, as the pack writes them. */
function boxesOf(tax) {
  const boxes = (tax.postings?.invoice ?? [])
    .filter((posting) => posting.type === 'base' && posting.box !== undefined && posting.box !== null)
    .flatMap((posting) => (Array.isArray(posting.box) ? posting.box : String(posting.box).split(',')))
    .map((box) => String(box).trim());
  return [...new Set(boxes)];
}

/**
 * What the rule asks of one row: `ok`, `open`, or `n/a`.
 *
 * The rule applies where the country is inside the common system of VAT in
 * full on the day the pack speaks of and the pack names an intra-Community
 * service. Article 44 of Directive 2006/112/EC puts the service to a taxable
 * person where that person is established, inside the European Union or
 * outside it: a pack that carries the first half of the article carries the
 * second.
 */
export function verdict(row) {
  if (row.eu_vat_scope !== 'full' || row.cases.intracom_services.length === 0) return 'n/a';
  return row.cases.services_abroad.length > 0 ? 'ok' : 'open';
}

/** One row of the inventory, from the parsed files of one pack. */
export function inventoryRow(slug, manifest, taxes, territories) {
  const country = String(manifest?.country ?? slug.toUpperCase());
  const released = /^\d{4}-\d{2}-\d{2}$/.test(String(manifest?.released_at ?? ''))
    ? manifest.released_at
    : new Date().toISOString().slice(0, 10);
  const territory = territoryOf(country, territories);
  const sales = (Array.isArray(taxes) ? taxes : []).filter((tax) => tax.scope === 'sale');
  const cases = {};
  for (const c of CASES) {
    cases[c.key] = sales.filter(c.is).map((tax) => ({ code: tax.code, boxes: boxesOf(tax) }));
  }
  const row = {
    pack: slug,
    country,
    parent: territory?.parent_code ?? null,
    eu_vat_scope: territory === null ? 'unknown' : euVatScopeOf(country, released, territories),
    released_at: released,
    cases,
  };
  return { ...row, verdict: verdict(row) };
}

/** The inventory of every pack of the checkout (`ref` null) or of a git ref. */
export async function inventory({ ref = null } = {}) {
  const files = reader(ref);
  const seed = await files.read('supabase/seed/00_territories.sql');
  if (seed === null) throw new Error('supabase/seed/00_territories.sql was not found');
  const territories = parseTerritorySeed(seed);
  const rows = [];
  for (const slug of await files.list()) {
    const manifest = await files.read(`packs/${slug}/pack.json`);
    if (manifest === null) continue;
    const taxes = await files.read(`packs/${slug}/taxes.json`);
    rows.push(inventoryRow(slug, JSON.parse(manifest), taxes === null ? [] : JSON.parse(taxes), territories));
  }
  return rows;
}

function cell(row, key) {
  const found = row.cases[key];
  if (found.length > 0) {
    return found.map((t) => `${t.code}${t.boxes.length > 0 ? ` (${t.boxes.join(', ')})` : ' (no box)'}`).join('; ');
  }
  if (key === 'vessels_aircraft' && row.eu_vat_scope !== 'full') return 'n/a (no VATEX code outside the European Union)';
  return 'absent';
}

function table(rows) {
  const head = ['Pack', 'Territory', 'VAT scope', ...CASES.map((c) => c.title), 'Rule'];
  const lines = [`| ${head.join(' | ')} |`, `|${head.map(() => '---').join('|')}|`];
  for (const row of rows) {
    const territory = row.parent === null ? row.country : `${row.country} (parent ${row.parent})`;
    lines.push(
      `| ${[row.pack, territory, row.eu_vat_scope, ...CASES.map((c) => cell(row, c.key)), row.verdict].join(' | ')} |`,
    );
  }
  return lines.join('\n');
}

async function main() {
  const args = process.argv.slice(2);
  const at = args.indexOf('--ref');
  const ref = at === -1 ? null : (args[at + 1] ?? null);
  if (at !== -1 && ref === null) throw new Error('--ref needs a git ref, for example origin/main');
  const rows = await inventory({ ref });
  if (args.includes('--json')) {
    process.stdout.write(`${JSON.stringify(rows, null, 2)}\n`);
    return;
  }
  process.stdout.write(`${table(rows)}\n`);
  const open = rows.filter((row) => row.verdict === 'open').map((row) => row.pack);
  process.stdout.write(
    `\n${rows.length} pack(s); the rule applies to ${rows.filter((r) => r.verdict !== 'n/a').length}, ` +
      `open on ${open.length}${open.length > 0 ? `: ${open.join(', ')}` : ''}.\n`,
  );
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  main().catch((error) => {
    process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
    process.exit(1);
  });
}
