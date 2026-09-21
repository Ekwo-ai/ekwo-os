#!/usr/bin/env node
/**
 * Keeps the packs of the OHADA member States on one chart of accounts.
 *
 * Seventeen countries keep their books on the same plan, the SYSCOHADA révisé
 * annexed to the Acte uniforme relatif au droit comptable et à l'information
 * financière of 26 January 2017, and present them in the same balance sheet
 * and the same income statement. What differs from one to the next is the
 * tax: the rates, the declaration, the invoice. A pack is autonomous — the
 * compiler reads `packs/<cc>/` and nothing else, and `docs/decisions/0025-a-country-is-a-pack-of-data.md` rules out
 * a shared fragment the compiler would have to resolve — so the common part is
 * copied into every member, and this file is what does the copying and what
 * refuses a copy that has drifted.
 *
 * The source is `packs/ohada/`, a folder `listPacks()` does not read because
 * its name is not a country code:
 *
 * - `manifest.json` names the members, the files copied into each of them
 *   (`accounts.csv`, `statements.json`), the register entries
 *   every member cites, and the part of `pack.json` that belongs to the chart:
 *   the charts, the journals, the roles, the closing style;
 * - the files themselves. `accounts.csv` is copied as it is; the statement
 *   codes of `statements.json` take the member's country in front of them, for
 *   the reason `localised()` gives;
 * - `i18n/<lang>.json`, when an official version of the chart in that language
 *   has been transcribed: the sections that belong to the chart — `charts`,
 *   `accounts`, `journals`, `statement_lines` — are laid into the member's own
 *   `i18n/<lang>.json`, whose other sections (its taxes, its boxes, its
 *   mentions, its own name) stay the member's. The file is written into every
 *   member, and stays a partial, undeclared translation until the member
 *   covers the rest and lists the language in `languages`.
 *
 * Everything else in a member's `pack.json` — the country, the currency, the
 * language, the seed number, the invoice rules, the register entries of its
 * own tax law — is the member's, and this file never touches it.
 *
 *     node scripts/ohada-packs.mjs            # check: exit 1 on any drift
 *     node scripts/ohada-packs.mjs --write    # write the common part into every member
 *
 * A member written here still has to be compiled: `ekwo pack build <cc>`
 * afterwards, because the seed carries a checksum of the pack.
 *
 * `members` lists the seventeen States ahead of their packs. A member with no
 * folder yet is awaited and reported, not refused; a member with a folder and
 * no `pack.json` is refused.
 *
 * The check also refuses a pack that cites the SYSCOHADA register entry and
 * is not a member — a country copied by hand from another member rather than
 * added to the list, which would drift the first time the chart is corrected.
 */

import { existsSync } from 'node:fs';
import { mkdir, readFile, readdir, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const packs = join(root, 'packs');
const source = join(packs, 'ohada');
const write = process.argv.includes('--write');

const shared = JSON.parse(await readFile(join(source, 'manifest.json'), 'utf8'));

/**
 * A statement code is the primary key of `statement_templates`, across every
 * country, where an account, a tax or a journal is keyed by its country too.
 * Seventeen packs carrying `SYSCOHADA-BS` would be one row, the last seed
 * applied winning, so each member's copy carries its country in front of the
 * code — in `statements.json` and in the charts that name the statements.
 * The lines keep their codes: they are keyed by their statement.
 */
function localised(statements, prefix) {
  return {
    ...statements,
    statements: statements.statements.map((s) => ({ ...s, code: `${prefix}${s.code}` })),
  };
}

/** The sections of an i18n file that belong to the chart, and not to the member. */
const CHART_SECTIONS = ['charts', 'accounts', 'journals', 'statement_lines'];

/**
 * The member's translation with the chart's sections laid over it. A
 * statement line is keyed `<statement>:<line>`, and its statement takes the
 * member's country in front of it like the statement itself.
 */
function translated(own, common, prefix) {
  const out = { $schema: common.$schema, ...own, language: common.language };
  if (out.$schema === undefined) delete out.$schema;
  if (common.source && !out.source) out.source = common.source;
  for (const section of CHART_SECTIONS) {
    if (!common[section]) continue;
    out[section] =
      section === 'statement_lines'
        ? Object.fromEntries(Object.entries(common[section]).map(([key, label]) => [`${prefix}${key}`, label]))
        : structuredClone(common[section]);
  }
  return out;
}

/** The member's manifest with the common part laid over it, key by key. */
function merged(manifest, prefix) {
  const out = structuredClone(manifest);
  const { defaults, ...top } = shared.manifest;
  for (const [key, value] of Object.entries(top)) out[key] = structuredClone(value);
  out.charts = out.charts.map((c) => ({ ...c, statements: (c.statements ?? []).map((code) => `${prefix}${code}`) }));
  out.defaults = { ...out.defaults, ...structuredClone(defaults) };
  // The register: the shared entries first, in their order, replacing any
  // entry of the same key; the member's own entries after them, untouched.
  const keys = new Set(shared.sources.map((s) => s.key));
  const own = (out.certification?.sources ?? []).filter((s) => typeof s === 'string' || !keys.has(s.key));
  out.certification = { ...(out.certification ?? {}), sources: [...structuredClone(shared.sources), ...own] };
  return out;
}

const json = (value) => `${JSON.stringify(value, null, 2)}\n`;

const i18nDir = join(source, 'i18n');
const translations = existsSync(i18nDir)
  ? (await readdir(i18nDir)).filter((f) => f.endsWith('.json')).sort()
  : [];

const problems = [];
const awaited = [];
for (const cc of shared.members) {
  const dir = join(packs, cc);
  // A member listed ahead of its pack: the list is written once for the
  // seventeen, so that adding a country never edits a file another country's
  // pull request edits too. No folder at all is a pack still to come; a folder
  // without a manifest is a pack begun and broken.
  if (!existsSync(dir)) {
    awaited.push(cc);
    continue;
  }
  if (!existsSync(join(dir, 'pack.json'))) {
    problems.push(`packs/${cc}: named a member in packs/ohada/manifest.json and has no pack.json`);
    continue;
  }
  const manifest = JSON.parse(await readFile(join(dir, 'pack.json'), 'utf8'));
  const prefix = `${manifest.country}-`;
  const wanted = new Map();
  for (const file of shared.files) {
    const content = await readFile(join(source, file), 'utf8');
    wanted.set(file, file === 'statements.json' ? json(localised(JSON.parse(content), prefix)) : content);
  }
  wanted.set('pack.json', json(merged(manifest, prefix)));
  for (const file of translations) {
    const common = JSON.parse(await readFile(join(i18nDir, file), 'utf8'));
    const path = join(dir, 'i18n', file);
    const own = existsSync(path) ? JSON.parse(await readFile(path, 'utf8')) : null;
    wanted.set(join('i18n', file), json(translated(own, common, prefix)));
  }

  for (const [file, content] of wanted) {
    const path = join(dir, file);
    const current = existsSync(path) ? await readFile(path, 'utf8') : null;
    if (current === content) continue;
    if (write) {
      await mkdir(dirname(path), { recursive: true });
      await writeFile(path, content);
      console.log(`  wrote packs/${cc}/${file}`);
    } else {
      problems.push(
        file === 'pack.json'
          ? `packs/${cc}/pack.json: its charts, journals, roles or SYSCOHADA register entries differ from packs/ohada/manifest.json`
          : file.startsWith('i18n')
            ? `packs/${cc}/${file}: its ${CHART_SECTIONS.join(', ')} differ from packs/ohada/${file}`
            : `packs/${cc}/${file} is not the copy of packs/ohada/${file} this script writes`,
      );
    }
  }
}

// A pack on the chart that nobody listed.
const cited = new Set(shared.sources.map((s) => s.key));
for (const entry of await readdir(packs, { withFileTypes: true })) {
  if (!entry.isDirectory() || !/^[a-z]{2}$/.test(entry.name) || shared.members.includes(entry.name)) continue;
  const manifest = JSON.parse(await readFile(join(packs, entry.name, 'pack.json'), 'utf8'));
  const sources = manifest.certification?.sources ?? [];
  if (sources.some((s) => typeof s === 'object' && cited.has(s.key))) {
    problems.push(`packs/${entry.name} cites the SYSCOHADA register and is not a member: add it to packs/ohada/manifest.json`);
  }
}

if (problems.length > 0) {
  console.error('The OHADA packs have drifted from packs/ohada/:');
  for (const p of problems) console.error(`  ✗ ${p}`);
  console.error('\n  Edit packs/ohada/, then `node scripts/ohada-packs.mjs --write` and `ekwo pack build --all`.');
  process.exit(1);
}
const present = shared.members.length - awaited.length;
if (!write) console.log(`The ${present} OHADA packs carry the chart of packs/ohada/.`);
if (awaited.length > 0) console.log(`  awaited, listed and not yet written: ${awaited.join(', ')}`);
