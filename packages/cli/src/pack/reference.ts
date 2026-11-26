/**
 * The two reference tables every country shares, written from the packs.
 *
 * `currencies` and `territories` are one table each for the whole
 * installation: a company in Ghana and a company in Belgium read the same
 * rows. They used to be two hand-written seeds, `supabase/seed/00_currencies.sql`
 * and `supabase/seed/00_territories.sql`, and every pull request that added a
 * country appended its currency to the first and its territory to the second.
 * Two countries written in parallel then conflicted on the last lines of two
 * files neither of them owned.
 *
 * So a country declares its rows in its own folder, `packs/<cc>/reference.json`,
 * and the two seeds are build artefacts of the whole set, the way the lists of
 * `pack/lists.ts` are: `ekwo pack build` writes them, `ekwo pack check` refuses
 * one that is not what the packs say, and the CI runs the check. A hand edit
 * to either seed is therefore refused the same way a hand edit to a country
 * seed is.
 *
 * Who declares what is a rule, not a choice, so that two packs never both
 * claim a row and a reviewer can tell from a code alone which folder holds it:
 *
 * - **A currency belongs to the pack of the country its ISO 4217 code begins
 *   with.** ISO 4217 builds an alphabetic code from the ISO 3166-1 code of the
 *   issuing country and one letter: `GHS` is Ghana's, `USD` the United
 *   States'. A code whose first two letters are no pack's country — the euro,
 *   the CFA francs, the East Caribbean dollar — is a currency of a monetary
 *   union and belongs to `packs/generic/`. A pack that keeps its books in a
 *   currency another pack declares declares nothing: it names it in
 *   `defaults.currency`, and the check holds it to a row that exists.
 * - **A territory belongs to the pack of the country it lies in**, following
 *   `parent_code` up to a country that has a pack: the Canary Islands are in
 *   `packs/es/`, Guernsey in `packs/gg/` because Guernsey has a pack of its
 *   own. A territory under no pack's country belongs to `packs/generic/`.
 *
 * The generated text keeps the result of the hand-written seeds: the same
 * rows, the same values, the same conflict rules — currencies are inserted
 * once and left alone, territories written again on conflict — and the same
 * file names, so an installer of any version applies them unchanged. What it
 * does not keep is the order of the rows, which is now the order of the packs
 * (`generic` first, then by slug) and, within a pack, the order its file
 * declares. The order of an insert carries no meaning: each table is written
 * by one statement, so a territory may come before its parent.
 */

import { existsSync } from 'node:fs';
import { readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { bool, date, text } from './compile.js';
import { GENERIC_PACK, PackError, listPacks, packsDir, readSchema, repoRootDir, seedOutputDir } from './read.js';
import { validate, type Issue } from './schema.js';

/** One row of `currencies`, as `reference.json` writes it. */
export interface ReferenceCurrency {
  comment?: string[];
  code: string;
  name: string;
  symbol: string;
  decimal_places: number;
}

/** One row of `territories`, as `reference.json` writes it. Every column of the table. */
export interface ReferenceTerritory {
  comment?: string[];
  code: string;
  code_source: 'iso_3166_1' | 'iso_3166_2' | 'eu' | 'named';
  name: string;
  parent_code: string | null;
  eu_vat_scope: 'full' | 'goods' | 'none';
  eu_vat_from: string | null;
  eu_vat_to: string | null;
  vat_prefix: string | null;
  outside_parent_tax: boolean;
  legal_reference: string;
}

/** `packs/<slug>/reference.json`. */
export interface ReferenceFile {
  comment?: { currencies?: string[]; territories?: string[] };
  currencies?: ReferenceCurrency[];
  territories?: ReferenceTerritory[];
}

/** The reference data of a checkout: every pack's file, `generic` first and then by slug. */
export interface ReferenceData {
  packs: { slug: string; country: string | null; file: ReferenceFile }[];
}

/** The two seed files this module writes, by name. They keep the names they had when they were written by hand. */
export const CURRENCY_SEED = '00_currencies.sql';
export const TERRITORY_SEED = '00_territories.sql';

const REFERENCE_FILE = 'reference.json';

async function readJsonFile(path: string): Promise<unknown> {
  const raw = await readFile(path, 'utf8');
  try {
    return JSON.parse(raw);
  } catch (error) {
    throw new PackError(`pack_unreadable: ${path} — ${(error as Error).message}`);
  }
}

/**
 * Reads every `reference.json` of a checkout and refuses what a seed could not
 * be built from: a file that does not match the schema, a code two packs
 * declare, a row declared by a pack it does not belong to, a parent nobody
 * declares, a pack whose own country or currency has no row.
 *
 * Each refusal names the file and the code, so a contributor reads in one line
 * which folder to change.
 */
export async function readReference(dir = packsDir()): Promise<ReferenceData> {
  const schema = await readSchema(dir);
  const defs = (schema['$defs'] ?? {}) as Record<string, Record<string, unknown>>;
  const issues: string[] = [];
  const packs: ReferenceData['packs'] = [];
  const defaultCurrency = new Map<string, string>();

  for (const slug of [GENERIC_PACK, ...(await listPacks(dir))]) {
    let country: string | null = null;
    if (slug !== GENERIC_PACK) {
      const manifest = (await readJsonFile(join(dir, slug, 'pack.json'))) as {
        country?: string;
        defaults?: { currency?: string };
      };
      country = manifest.country ?? null;
      if (manifest.defaults?.currency !== undefined) defaultCurrency.set(slug, manifest.defaults.currency);
    }
    const path = join(dir, slug, REFERENCE_FILE);
    const file = existsSync(path) ? ((await readJsonFile(path)) as ReferenceFile) : {};
    const found: Issue[] = validate(file, defs['reference'] ?? {}, schema, REFERENCE_FILE);
    issues.push(...found.map((issue) => `packs/${slug}/${issue.path}: ${issue.message}`));
    packs.push({ slug, country, file });
  }
  if (issues.length > 0) throw new PackError(`reference_invalid:\n  ${issues.join('\n  ')}`);

  const countries = new Map(packs.filter((p) => p.country !== null).map((p) => [p.country as string, p.slug]));

  // Every code once, whichever table.
  const currencyOwner = new Map<string, string>();
  const territoryOwner = new Map<string, string>();
  const territories = new Map<string, ReferenceTerritory>();
  for (const { slug, file } of packs) {
    for (const currency of file.currencies ?? []) {
      const other = currencyOwner.get(currency.code);
      if (other !== undefined) issues.push(`currency ${currency.code} is declared by packs/${other} and packs/${slug}`);
      currencyOwner.set(currency.code, slug);
    }
    for (const territory of file.territories ?? []) {
      const other = territoryOwner.get(territory.code);
      if (other !== undefined) issues.push(`territory ${territory.code} is declared by packs/${other} and packs/${slug}`);
      territoryOwner.set(territory.code, slug);
      territories.set(territory.code, territory);
    }
  }

  // Each row in the folder the rule above names.
  for (const [code, slug] of currencyOwner) {
    const expected = countries.get(code.slice(0, 2)) ?? GENERIC_PACK;
    if (slug !== expected) {
      issues.push(
        `currency ${code} is declared by packs/${slug}; it belongs to packs/${expected}, ` +
          `the pack of the country its ISO 4217 code begins with` +
          (expected === GENERIC_PACK ? ' (none here, so the currency of no single country)' : ''),
      );
    }
  }
  for (const [code, slug] of territoryOwner) {
    const territory = territories.get(code) as ReferenceTerritory;
    if (territory.parent_code !== null && !territories.has(territory.parent_code)) {
      issues.push(`territory ${code} (packs/${slug}) names the parent ${territory.parent_code}, which no pack declares`);
      continue;
    }
    if (territory.outside_parent_tax && territory.parent_code === null) {
      issues.push(`territory ${code} (packs/${slug}) is outside its parent's tax and has no parent`);
    }
    const expected = ownerOf(code, territories, countries);
    if (slug !== expected) {
      issues.push(
        `territory ${code} is declared by packs/${slug}; it belongs to packs/${expected}, ` +
          'the pack of the country it lies in, following parent_code',
      );
    }
  }

  // What every pack reads from the two tables is there.
  for (const { slug, country } of packs) {
    if (country !== null && !territories.has(country)) {
      issues.push(`packs/${slug}: its country ${country} has no row in territories — declare it in packs/${slug}/${REFERENCE_FILE}`);
    }
    const currency = defaultCurrency.get(slug);
    if (currency !== undefined && !currencyOwner.has(currency)) {
      issues.push(
        `packs/${slug}: defaults.currency ${currency} has no row in currencies — declare it in ` +
          `packs/${countries.get(currency.slice(0, 2)) ?? GENERIC_PACK}/${REFERENCE_FILE}`,
      );
    }
  }

  if (issues.length > 0) throw new PackError(`reference_invalid:\n  ${issues.join('\n  ')}`);
  return { packs };
}

/** The pack a territory belongs to: the first country up its `parent_code` chain that has a pack. */
function ownerOf(code: string, territories: Map<string, ReferenceTerritory>, countries: Map<string, string>): string {
  const seen = new Set<string>();
  let current: string | null = code;
  while (current !== null && !seen.has(current)) {
    seen.add(current);
    const slug = countries.get(current);
    if (slug !== undefined) return slug;
    current = territories.get(current)?.parent_code ?? null;
  }
  return GENERIC_PACK;
}

/** Every territory of the checkout, in seed order. What `pack/territories.ts` reads instead of parsing SQL. */
export function territoriesOf(data: ReferenceData): ReferenceTerritory[] {
  return data.packs.flatMap((p) => p.file.territories ?? []);
}

/** Every currency of the checkout, in seed order. */
export function currenciesOf(data: ReferenceData): ReferenceCurrency[] {
  return data.packs.flatMap((p) => p.file.currencies ?? []);
}

function commentLines(lines: readonly string[] | undefined, indent = ''): string[] {
  return (lines ?? []).map((line) => (line === '' ? `${indent}--` : `${indent}-- ${line}`));
}

const RULE = `-- ${'-'.repeat(75)}`;

function generatedNotice(table: string): string[] {
  return [
    '--',
    `-- Generated from packs/*/${REFERENCE_FILE}, do not edit. A country declares its`,
    `-- ${table} in its own folder and runs \`ekwo pack build\`; \`ekwo pack check --all\``,
    '-- refuses a seed that is not the exact output of the packs, and the CI runs it.',
    '-- Who declares which row is written in packages/cli/src/pack/reference.ts.',
  ];
}

/** `00_currencies.sql`. Inserted once and never overwritten: an installation keeps a symbol it changed. */
export function compileCurrencySeed(data: ReferenceData): string {
  const out = [
    '-- Ekwo OS — currencies. ISO 4217 list one, the currencies the packs keep their',
    '-- books in.',
    ...generatedNotice('currency'),
    '--',
    '-- A currency nobody corrects is inserted once and left alone: on conflict, the',
    '-- row an installation already has is kept.',
    '',
  ];
  const sections = data.packs.filter((p) => (p.file.currencies ?? []).length > 0 || (p.file.comment?.currencies ?? []).length > 0);
  out.push(...sections.flatMap((p) => (p.file.comment?.currencies ?? []).length > 0 ? [...commentLines(p.file.comment?.currencies), ''] : []));
  out.push('insert into currencies (code, name, symbol, decimal_places) values');
  const rows: string[] = [];
  for (const p of sections) {
    const currencies = p.file.currencies ?? [];
    if (currencies.length === 0) continue;
    rows.push(`  -- packs/${p.slug}/${REFERENCE_FILE}`);
    currencies.forEach((c) => {
      rows.push(...commentLines(c.comment, '  '));
      rows.push(`  (${text(c.code)}, ${text(c.name)}, ${text(c.symbol)}, ${c.decimal_places}),`);
    });
  }
  out.push(...withoutLastComma(rows));
  out.push('on conflict (code) do nothing;');
  return `${out.join('\n')}\n`;
}

/** `00_territories.sql`. Every column written again on conflict, so a correction reaches an installation. */
export function compileTerritorySeed(data: ReferenceData): string {
  const out = [
    '-- Ekwo OS — territories. Every place a pack names, and how far the common system',
    '-- of VAT of the European Union reaches it.',
    ...generatedNotice('territories'),
    '--',
    '-- Reference data of the framework, read by `ec_sales_list()` through',
    '-- `territory_of()`, `is_eu_member()`, `eu_vat_scope_of()` and `vat_prefix_of()`,',
    '-- and by `post_document()` to judge a tax that names a territory. The table, the',
    '-- functions and the argument for why this is data and not code are in the',
    '-- migration `20260915181000_territories.sql`; this file is the rows.',
    '--',
    '-- It upserts, where the currencies do nothing. This list changes — a State',
    '-- accedes, a State leaves, a territory moves from one paragraph of article 6 of',
    '-- Directive 2006/112/EC to another — and re-applying this file is how that',
    '-- correction reaches an installation that already exists, which is the rule the',
    '-- seed README states for every country pack. So every column is written again',
    '-- on conflict.',
    '--',
    '-- One statement writes every row, so a territory may come before its parent:',
    '-- the foreign key on parent_code is checked when the statement ends.',
    '',
  ];
  const generic = data.packs.find((p) => p.slug === GENERIC_PACK);
  if ((generic?.file.comment?.territories ?? []).length > 0) {
    out.push(RULE, ...commentLines(generic?.file.comment?.territories), RULE, '');
  }
  out.push(
    'insert into territories (code, code_source, name, parent_code, eu_vat_scope, eu_vat_from, eu_vat_to, vat_prefix, outside_parent_tax, legal_reference) values',
  );
  const rows: string[] = [];
  for (const p of data.packs) {
    const territories = p.file.territories ?? [];
    if (territories.length === 0) continue;
    rows.push('', `  -- packs/${p.slug}/${REFERENCE_FILE}`);
    if (p.slug !== GENERIC_PACK) rows.push(...commentLines(p.file.comment?.territories, '  '));
    for (const t of territories) {
      if ((t.comment ?? []).length > 0) rows.push('  --', ...commentLines(t.comment, '  '), '  --');
      rows.push(
        `  (${text(t.code)}, ${text(t.code_source)}, ${text(t.name)}, ${text(t.parent_code)}, ` +
          `${text(t.eu_vat_scope)}, ${date(t.eu_vat_from)}, ${date(t.eu_vat_to)}, ${text(t.vat_prefix)}, ` +
          `${bool(t.outside_parent_tax)},\n   ${text(t.legal_reference)}),`,
      );
    }
  }
  out.push(...withoutLastComma(rows));
  out.push(
    'on conflict (code) do update set',
    '  code_source        = excluded.code_source,',
    '  name               = excluded.name,',
    '  parent_code        = excluded.parent_code,',
    '  eu_vat_scope       = excluded.eu_vat_scope,',
    '  eu_vat_from        = excluded.eu_vat_from,',
    '  eu_vat_to          = excluded.eu_vat_to,',
    '  vat_prefix         = excluded.vat_prefix,',
    '  outside_parent_tax = excluded.outside_parent_tax,',
    '  legal_reference    = excluded.legal_reference;',
  );
  return `${out.join('\n')}\n`;
}

/** The comma after the last tuple of a list is the one SQL does not want. */
function withoutLastComma(rows: string[]): string[] {
  for (let index = rows.length - 1; index >= 0; index -= 1) {
    const row = rows[index] as string;
    if (row.endsWith('),')) {
      rows[index] = row.slice(0, -1);
      break;
    }
  }
  return rows;
}

/** One generated reference seed: its file under `supabase/seed/`, and what this run found or did. */
export interface GeneratedReferenceSeed {
  file: string;
  state: 'written' | 'unchanged' | 'stale';
}

/**
 * Compares the two reference seeds with what the packs say and, with `write`,
 * rewrites the ones that differ. Throws a `PackError` when the packs
 * themselves disagree — a code declared twice, a row in the wrong folder.
 */
export async function referenceSeeds(write: boolean, root = repoRootDir()): Promise<GeneratedReferenceSeed[]> {
  const data = await readReference(packsDir(root));
  const results: GeneratedReferenceSeed[] = [];
  for (const [file, sql] of [
    [CURRENCY_SEED, compileCurrencySeed(data)],
    [TERRITORY_SEED, compileTerritorySeed(data)],
  ] as const) {
    const path = join(seedOutputDir(root), file);
    const current = await readFile(path, 'utf8').catch(() => undefined);
    if (current === sql) {
      results.push({ file, state: 'unchanged' });
      continue;
    }
    if (write) await writeFile(path, sql, 'utf8');
    results.push({ file, state: write ? 'written' : 'stale' });
  }
  return results;
}
