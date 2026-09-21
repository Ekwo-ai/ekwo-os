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
const OTHERS = [['X', 'e', 'r', 'o'].join(''), ['Q', 'u', 'i', 'c', 'k', 'B', 'o', 'o', 'k', 's'].join('')];
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
    expect(result.stderr).toContain('docs/international.md:1');
    expect(result.stderr).toContain('docs/international.md:2');
    expect(result.stderr).toContain('2 line(s)');
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

describe('this repository', () => {
  it('names no refused product outside the frozen migrations', async () => {
    const result = await runGuard(repoRoot);
    expect(result.code, result.stderr).toBe(0);
  });
});
