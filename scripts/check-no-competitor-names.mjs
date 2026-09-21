#!/usr/bin/env node
/**
 * Refuses a commit that names another accounting product the project has
 * decided never to name.
 *
 * Ekwo describes itself by what it does and by the standards it follows —
 * EN 16931, the FEC, the texts of each country — and not against a named
 * product. On 21 September 2026 every such mention was taken out of the code,
 * the documentation, the pack READMEs and the site; this guard keeps it that
 * way, because a comparison is the easiest sentence to write and the hardest
 * to notice in review.
 *
 * Run with `npm run check:no-competitor-names`; the CI's *hygiene* job runs it
 * on every push and every pull request.
 *
 * **Only files git tracks are read**, from `git ls-files`, as the conflict
 * marker guard does: a scratch file or a build output is outside the question
 * by construction.
 *
 * **The names are built from pieces rather than written out**, so this file
 * does not contain the word it refuses and needs no exemption for itself. A
 * guard with an exception for its own directory stops covering the day
 * somebody puts a real mention there.
 *
 * **Published migrations are the one exception, and the list is frozen.** A
 * migration that has been released has run on databases this project does not
 * control; the CI refuses any edit to it, and a comment is not worth a new
 * migration. The files below carried a mention before the rule existed and
 * keep it. Nothing is ever added to this list: a new file with a mention is
 * written without it.
 */

import { execFile } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { promisify } from 'node:util';

const run = promisify(execFile);
const root = join(dirname(fileURLToPath(import.meta.url)), '..');

/** The names refused, matched without regard to case. */
const NAMES = [['o', 'd', 'o', 'o'].join('')];

/** Published migrations that carried a mention before the rule; frozen. */
const PUBLISHED_BEFORE_THE_RULE = new Set(['supabase/migrations/20260912074712_country_packs.sql']);

const pattern = new RegExp(NAMES.join('|'), 'i');

/** Every path git tracks, relative to the root of the working tree. */
async function trackedFiles() {
  const { stdout } = await run('git', ['ls-files', '-z'], {
    cwd: root,
    maxBuffer: 64 * 1024 * 1024,
  });
  return stdout.split('\0').filter((path) => path !== '');
}

const found = [];

for (const path of await trackedFiles()) {
  if (PUBLISHED_BEFORE_THE_RULE.has(path)) continue;
  // A file git cannot hand back as UTF-8 is an image, a font or an archive.
  const text = await readFile(join(root, path), 'utf8').catch(() => null);
  if (text === null) continue;

  // The path is read as well as the text: a file named after the product is
  // a mention too.
  if (pattern.test(path)) found.push(`${path}  (the path itself)`);
  const lines = text.split('\n');
  for (const [index, line] of lines.entries()) {
    if (pattern.test(line)) found.push(`${path}:${index + 1}  ${line.trim().slice(0, 120)}`);
  }
}

if (found.length > 0) {
  console.error('Another product is named in files this repository tracks:\n');
  for (const hit of found) console.error(`  ${hit}`);
  console.error(
    `\n${found.length} line(s). Say what Ekwo does, or which standard it follows,\n` +
      '  without naming another product.',
  );
  process.exit(1);
}

console.log('No refused product name in any tracked file.');
