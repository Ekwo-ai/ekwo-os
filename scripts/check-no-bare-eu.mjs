#!/usr/bin/env node
/**
 * The European Union is one zone among others, never the assumption.
 *
 * The core of this repository serves every country. A comment, a document, an
 * error message or a line of help that says "EU", "the Union" or
 * "intra-community" as if it were the default tells a reader in Kansas or in
 * Kuala Lumpur that the software was written for somebody else. So the core
 * says "European Union" in full, and what is only true inside it lives in a
 * pack (`zones` in `pack.json`) or on the page of the zone
 * (`docs/zones/european-union.md`).
 *
 * What fails: a tracked file, outside `packs/`, that contains a bare `EU`, the
 * words `the Union`, or `intra-community` naming no zone beside it, after normative identifiers are
 * set aside. What does not:
 *
 * - **Normative identifiers**, which are somebody else's words: `VATEX-EU-*`
 *   of the EN 16931 code lists, `EU` as an ISO 3166 style code in a table.
 *   They are removed from a line before it is read.
 * - **Files listed in ALLOWED below**, each with the reason it is allowed. A
 *   directory ends with a slash. The list is the whole exception: an entry
 *   that no longer matches anything is itself a failure, so it cannot go stale
 *   and quietly widen.
 * - **Generated and frozen files**: the seeds under `supabase/seed/` are the
 *   output of `packs/`, and a migration that already carries a release tag is
 *   never edited (the CI refuses it), so its comments cannot be swept.
 *
 * Run: `npm run check:no-bare-eu`.
 */

import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');

/**
 * Where a bare mention is allowed, and why. Exact path, or a directory when it
 * ends with `/`.
 */
const ALLOWED = [
  // Normative material published by somebody else, kept as it was published.
  ['packages/formats/peppol-ubl/test/', 'Peppol and CEN test material: the standard\'s own codelists, schematron and fixtures'],
  ['packages/formats/vat-consignment/test/', 'XSD schemas of a national administration, kept as published'],
  ['packages/formats/factur-x/test/', 'Factur-X and CII fixtures'],
  ['packages/cli/src/pack/vat-codes.ts', 'checks a pack against the VATEX list of EN 16931, whose codes are named VATEX-EU-*'],
  // Frozen history.
  ['CHANGELOG.md', 'a record of what was said at the time of each release'],
  ['docs/decisions/', 'decision records are historical and are not rewritten'],
  ['tests/fixtures/', 'frozen copies of seeds as they were before packs existed'],
  // Generated from the migrations, which are frozen.
  ['docs/schema.md', 'generated from the comments of the frozen migrations'],
  // This guard.
  ['scripts/check-no-bare-eu.mjs', 'says what it looks for'],
];

/** Files that are not text, or that are output. */
const SKIPPED = /\.(gif|mp4|png|jpe?g|svg|ico|pdf|woff2?|zip)$/i;
const SKIPPED_PREFIXES = ['packs/', 'supabase/seed/', 'package-lock.json'];

/**
 * Identifiers that are not prose: removed from a line before it is read. A
 * normative code keeps the two letters the standard gave it.
 */
const NORMATIVE = [
  /VATEX-EU(?:-[A-Z0-9]+)*/g,
  /vatex-eu(?:-[a-z0-9]+)*/g,
  // A legal citation: Regulation (EU) 2016/679, Directive (EU) 2018/1910.
  /\((?:EU)\)\s*(?:No\s*)?\d+\/\d+/g,
  // An npm keyword is a search term, not a sentence.
  /^\s*"intra-community",?\s*$/,
];

const BARE = [
  [/\bEU\b/, 'a bare "EU"'],
  [/\bthe Union\b/, '"the Union"'],
];

/**
 * "intra-community" is the name of a VAT treatment (`intracom_goods`) and of
 * the sentence of a standard, so it cannot be banned outright. It fails when
 * nothing within two lines says which zone it is about: the words "European
 * Union", a treatment identifier, a Member State, or the code list that
 * defines the phrase.
 */
const INTRA = /\bintra-?community\b/i;
const INTRA_QUALIFIED = /European Union|intracom_|Member State|UNCL5305|VATEX|EN 16931|EEA/;

const git = (...args) => execFileSync('git', args, { cwd: root, encoding: 'utf8' }).split('\n').filter(Boolean);

/** The migrations of the latest release tag: published, so never edited. */
function frozenMigrations() {
  try {
    const tag = git('describe', '--tags', '--abbrev=0')[0];
    if (tag === undefined) return new Set();
    return new Set(git('ls-tree', '-r', '--name-only', tag).filter((f) => /supabase\/migrations\/\d+.*\.sql$/.test(f)));
  } catch {
    return new Set();
  }
}

const frozen = frozenMigrations();
const used = new Set();
const allowedBy = (file) => {
  for (const [entry] of ALLOWED) {
    if (entry.endsWith('/') ? file.startsWith(entry) : file === entry) return entry;
  }
  return undefined;
};

const problems = [];
for (const file of git('ls-files')) {
  if (SKIPPED.test(file) || SKIPPED_PREFIXES.some((p) => file.startsWith(p))) continue;
  if (frozen.has(file)) continue;
  let text;
  try {
    text = readFileSync(join(root, file), 'utf8');
  } catch {
    continue;
  }
  const lines = text.split('\n');
  const hits = [];
  lines.forEach((line, index) => {
    let seen = line;
    for (const pattern of NORMATIVE) seen = seen.replace(pattern, '');
    for (const [pattern, what] of BARE) {
      if (pattern.test(seen)) hits.push(`${file}:${index + 1}: ${what}: ${line.trim().slice(0, 110)}`);
    }
    if (INTRA.test(seen)) {
      const near = lines.slice(Math.max(0, index - 2), index + 3).join(' ');
      if (!INTRA_QUALIFIED.test(near)) {
        hits.push(`${file}:${index + 1}: "intra-community" with no zone named beside it: ${line.trim().slice(0, 110)}`);
      }
    }
  });
  if (hits.length === 0) continue;
  const entry = allowedBy(file);
  if (entry !== undefined) used.add(entry);
  else problems.push(...hits);
}

// An exception that excepts nothing is a list that went stale.
for (const [entry] of ALLOWED) {
  if (used.has(entry)) continue;
  if (entry === 'scripts/check-no-bare-eu.mjs') continue;
  problems.push(`${entry}: allowed, but nothing in it needs the exception any more — remove the entry`);
}

if (problems.length > 0) {
  console.error('A bare "EU", "the Union" or "intra-community" in the core:\n');
  for (const problem of problems) console.error(`  ${problem}`);
  console.error(
    '\nWrite "European Union" in full, or move the sentence to the pack or to docs/zones/.\n' +
      'A normative identifier (VATEX-EU-*, an EN 16931 name) stays as published: add its file to ALLOWED\n' +
      'in scripts/check-no-bare-eu.mjs with the reason.',
  );
  process.exit(1);
}
console.log('No bare "EU", "the Union" or "intra-community" in the core.');
