/**
 * The guard that refuses a named product, on a repository built to carry one.
 *
 * `scripts/check-no-competitor-names.mjs` is copied into a throwaway git
 * repository, as the conflict marker test does, because it resolves the tree
 * it reads from its own location. What runs is the file itself, byte for byte,
 * the way the hygiene job runs it.
 *
 * The name is built from pieces: writing it out would put it in a file the
 * guard tracks, and the test would fail the thing it is testing.
 */

import { execFile } from 'node:child_process';
import { cp, mkdir, mkdtemp, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { promisify } from 'node:util';
import { afterAll, describe, expect, it } from 'vitest';
import { repoRoot } from './helpers/db.js';

const run = promisify(execFile);

const GUARD = join('scripts', 'check-no-competitor-names.mjs');

/** The refused names, and the published migration that keeps the first. */
const NAME = ['O', 'd', 'o', 'o'].join('');
const OTHERS = [
  ['X', 'e', 'r', 'o'].join(''),
  ['Q', 'u', 'i', 'c', 'k', 'B', 'o', 'o', 'k', 's'].join(''),
  ['P', 'e', 'n', 'n', 'y', 'l', 'a', 'n', 'e'].join(''),
];
/** A name refused as a whole word only, and one made of two common words. */
const WORD = ['S', 'a', 'g', 'e'].join('');
const PAIR = [['E', 'x', 'a', 'c', 't'].join(''), ['O', 'n', 'l', 'i', 'n', 'e'].join('')] as const;
const FROZEN = 'supabase/migrations/20260912074712_country_packs.sql';

/** Directories to remove when the suite is done. */
const made: string[] = [];

interface Result {
  code: number;
  stdout: string;
  stderr: string;
}

async function runGuard(cwd: string): Promise<Result> {
  return run('node', [GUARD], { cwd }).then(
    ({ stdout, stderr }) => ({ code: 0, stdout, stderr }),
    (error: Error & { code?: number; stdout?: string; stderr?: string }) => ({
      code: error.code ?? 1,
      stdout: error.stdout ?? '',
      stderr: error.stderr ?? '',
    }),
  );
}

/**
 * A git repository holding the given files, staged, with the guard copied in;
 * `untracked` are written and left alone.
 */
async function guardOver(
  files: Record<string, string>,
  untracked: Record<string, string> = {},
): Promise<Result> {
  const dir = await mkdtemp(join(tmpdir(), 'ekwo-names-'));
  made.push(dir);
  await run('git', ['init', '-q', '-b', 'main'], { cwd: dir });

  await mkdir(join(dir, 'scripts'), { recursive: true });
  await cp(join(repoRoot, GUARD), join(dir, GUARD));

  for (const [name, text] of Object.entries({ ...files, ...untracked })) {
    await mkdir(dirname(join(dir, name)), { recursive: true });
    await writeFile(join(dir, name), text, 'utf8');
    if (name in files) await run('git', ['add', name], { cwd: dir });
  }
  await run('git', ['add', GUARD], { cwd: dir });

  return runGuard(dir);
}

afterAll(async () => {
  for (const dir of made) await rm(dir, { recursive: true, force: true });
});

describe('what the guard refuses', () => {
  it('names the file and the line, whatever the case', async () => {
    const result = await guardOver({
      'README.md': ['# Title', '', `An alternative to ${NAME}.`, ''].join('\n'),
      'docs/mapping.md': `| a | ${NAME.toLowerCase()} |\n`,
      'src/strings.ts': `export const x = '${NAME.toUpperCase()}';\n`,
    });

    expect(result.code).toBe(1);
    expect(result.stderr).toContain('README.md:3');
    expect(result.stderr).toContain('docs/mapping.md:1');
    expect(result.stderr).toContain('src/strings.ts:1');
    expect(result.stderr).toContain('3 line(s)');
  });

  it('refuses every name on its list, not only the first', async () => {
    const result = await guardOver({
      'docs/international.md': OTHERS.map((name) => `As ${name} does.`).join('\n') + '\n',
    });

    expect(result.code).toBe(1);
    for (const [index] of OTHERS.entries()) expect(result.stderr).toContain(`docs/international.md:${index + 1}`);
    expect(result.stderr).toContain(`${OTHERS.length} line(s)`);
  });

  it('refuses a name that is a word only as that word, and a name of two words only as the pair', async () => {
    const [first, second] = PAIR;
    const result = await guardOver({
      'docs/words.md': [
        `Exported from ${WORD} 50.`,
        `See ${WORD.toLowerCase()}.example for the file.`,
        `Exported from ${first} ${second}.`,
        `A file of ${first.toLowerCase()}-${second.toLowerCase()}.`,
        `The ${first.toLowerCase()}${second.toLowerCase()}.example help centre.`,
        '',
      ].join('\n'),
      // The same letters inside other words, and each word of the pair alone.
      'docs/prose.md': [
        `The u${WORD.toLowerCase()} of the command, and its mes${WORD.toLowerCase()}.`,
        `An ${first.toLowerCase()} amount, and a copy kept ${second.toLowerCase()}.`,
        '',
      ].join('\n'),
    });

    expect(result.code).toBe(1);
    for (const line of [1, 2, 3, 4, 5]) expect(result.stderr).toContain(`docs/words.md:${line}`);
    expect(result.stderr).not.toContain('docs/prose.md');
    expect(result.stderr).toContain('5 line(s)');
  });

  it('refuses a migration that is not on the frozen list', async () => {
    const result = await guardOver({
      'supabase/migrations/20990101000000_later.sql': `-- as ${NAME} does\n`,
    });

    expect(result.code).toBe(1);
    expect(result.stderr).toContain('20990101000000_later.sql:1');
  });

  it('refuses a path that carries the name', async () => {
    const result = await guardOver({ [`docs/${NAME.toLowerCase()}.md`]: 'nothing\n' });

    expect(result.code).toBe(1);
    expect(result.stderr).toContain('(the path itself)');
  });
});

describe('what the guard deliberately leaves alone', () => {
  it('the published migration on the frozen list, and an untracked file', async () => {
    const result = await guardOver(
      { [FROZEN]: `-- where ${NAME} landed\n`, 'README.md': 'nothing wrong\n' },
      { 'NOTES.md': `${NAME}\n` },
    );

    expect(result.code, result.stderr).toBe(0);
    expect(result.stdout).toContain('No refused product name');
  });
});

describe('the files that declare what is read', () => {
  const ALLOWED = [
    'docs/compatibility.md',
    'packages/cli/src/commands/import.ts',
    'packages/mcp/src/tools/import-books.ts',
    'packages/formats/journal-items/README.md',
    'packages/formats/journal-report/README.md',
    'packages/formats/transaction-journal/README.md',
    'packages/formats/xaf/README.md',
  ];

  it('may name the product whose export is read, and only those exact paths may', async () => {
    const files = Object.fromEntries(ALLOWED.map((path) => [path, `Reads the export of ${NAME}.\n`]));
    const result = await guardOver(files);
    expect(result.code, result.stderr).toBe(0);
  });

  it('still refuses the name everywhere else, next to them and inside them', async () => {
    const result = await guardOver({
      'docs/compatibility.md': `Reads the export of ${NAME}.\n`,
      'README.md': `Reads the export of ${NAME}.\n`,
      'packs/xx/README.md': `${NAME}\n`,
      'site/index.html': `${NAME}\n`,
      'docs/decisions/0099-imports.md': `${NAME}\n`,
      'docs/compatibility-notes.md': `${NAME}\n`,
      'packages/formats/journal-items/src/index.ts': `${NAME}\n`,
      'packages/formats/journal-report/README.md.bak': `${NAME}\n`,
      'packages/cli/src/commands/import.test.ts': `${NAME}\n`,
    });
    expect(result.code).toBe(1);
    for (const path of [
      'README.md:1',
      'packs/xx/README.md:1',
      'site/index.html:1',
      'docs/decisions/0099-imports.md:1',
      'docs/compatibility-notes.md:1',
      'packages/formats/journal-items/src/index.ts:1',
      'packages/formats/journal-report/README.md.bak:1',
      'packages/cli/src/commands/import.test.ts:1',
    ]) {
      expect(result.stderr).toContain(path);
    }
    expect(result.stderr).not.toContain('docs/compatibility.md:');
    expect(result.stderr).toContain('8 line(s)');
  });
});

describe('this repository', () => {
  it('names no refused product outside the frozen migrations', async () => {
    const result = await runGuard(repoRoot);
    expect(result.code, result.stderr).toBe(0);
  });
});
