/**
 * The lists of packs outside `packs/` are written from `packs/`.
 *
 * `supabase/config.toml`, the `psql -f` lines and the list of countries of the
 * README, `.github/CODEOWNERS` and the table of `docs/packs.md` each name every
 * pack, and each used to be edited by hand by the pull request that added one.
 * `ekwo pack build` writes them now and `ekwo pack check` refuses them stale —
 * see `packages/cli/src/pack/lists.ts`. This file holds the repository to it,
 * and pins what the generator does in a checkout made up for the purpose: which
 * blocks it writes, that it keeps an owner somebody wrote, and that a marker
 * gone missing is a refusal rather than a list nobody maintains any more.
 */

import { mkdir, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterEach, describe, expect, it } from 'vitest';
import { packLists } from '../packages/cli/src/pack/lists.js';
import { repoRoot } from './helpers/db.js';

describe('the lists of packs of this repository', () => {
  it('carry every generated block, and each says what packs/ says', async () => {
    const lists = await packLists(false, repoRoot);
    expect(lists.length).toBeGreaterThanOrEqual(5);
    for (const list of lists) {
      expect(list.state, `${list.file} generated:${list.block} — run \`ekwo pack build --all\``).toBe('unchanged');
    }
  });
});

describe('the generator, in a checkout of two packs', () => {
  let root: string;

  afterEach(async () => {
    await rm(root, { recursive: true, force: true });
  });

  /** Two made-up packs — `zz` declares the lower number — and the five files with their markers. */
  async function checkout(): Promise<void> {
    root = await mkdtemp(join(tmpdir(), 'ekwo-lists-'));
    const manifests: [string, Record<string, unknown>][] = [
      ['aa', { name: 'Alpha', seed_sequence: 42, defaults: { language: 'xa' }, languages: ['xb'], certification: { status: 'community' } }],
      ['zz', { name: 'Zeta', seed_sequence: 10, defaults: { language: 'xz' }, certification: { status: 'maintained' } }],
    ];
    for (const [slug, manifest] of manifests) {
      await mkdir(join(root, 'packs', slug), { recursive: true });
      await writeFile(join(root, 'packs', slug, 'pack.json'), JSON.stringify(manifest));
    }
    // Not a country: listPacks() does not read it, so no list names it.
    await mkdir(join(root, 'packs', 'generic'), { recursive: true });
    await mkdir(join(root, 'supabase', 'seed'), { recursive: true });
    for (const file of ['00_currencies.sql', '05_framework_generic.sql', '10_pack_zz.sql', '42_pack_aa.sql', '90_demo_company.sql']) {
      await writeFile(join(root, 'supabase', 'seed', file), '');
    }
    await writeFile(join(root, 'supabase', 'config.toml'), 'sql_paths = [\n# generated:seeds\n# /generated\n]\n');
    await writeFile(
      join(root, 'README.md'),
      'Ships: <!-- generated:countries --><!-- /generated -->.\n\n<!-- generated:seeds -->\n<!-- /generated -->\n',
    );
    await mkdir(join(root, 'docs'));
    await writeFile(join(root, 'docs', 'packs.md'), '<!-- generated:packs -->\n<!-- /generated -->\n');
    await mkdir(join(root, '.github'));
    await writeFile(
      join(root, '.github', 'CODEOWNERS'),
      '*   @org/everyone\n\n# generated:packs\n/packs/zz/   @someone   @org/everyone\n/packs/gone/  @nobody\n# /generated\n',
    );
  }

  it('finds every block stale, then writes each one from the packs', async () => {
    await checkout();
    expect((await packLists(false, root)).map((l) => l.state)).toEqual(Array(5).fill('stale'));
    expect((await packLists(true, root)).map((l) => l.state)).toEqual(Array(5).fill('written'));
    expect((await packLists(false, root)).map((l) => l.state)).toEqual(Array(5).fill('unchanged'));

    // The seeds the installer applies, in file-name order, the demo left out.
    const config = await readFile(join(root, 'supabase', 'config.toml'), 'utf8');
    expect(config).toBe(
      'sql_paths = [\n# generated:seeds\n' +
        '  "./seed/00_currencies.sql",\n  "./seed/05_framework_generic.sql",\n' +
        '  "./seed/10_pack_zz.sql",\n  "./seed/42_pack_aa.sql",\n' +
        '# /generated\n]\n',
    );
    const readme = await readFile(join(root, 'README.md'), 'utf8');
    expect(readme).toContain('<!-- generated:countries -->Alpha (`aa`) and Zeta (`zz`)<!-- /generated -->');
    expect(readme).toContain('psql "$DATABASE_URL" -f supabase/seed/42_pack_aa.sql\n```');
    expect(readme).not.toContain('90_demo_company.sql');

    const table = await readFile(join(root, 'docs', 'packs.md'), 'utf8');
    expect(table).toContain('| [`aa`](../packs/aa/) | Alpha | `42_pack_aa.sql` | xa, xb | `community` |');
    expect(table).toContain('| [`zz`](../packs/zz/) | Zeta | `10_pack_zz.sql` | xz | `maintained` |');
  });

  it('keeps the owner a line names, gives a new pack the owner of `*`, and drops a pack that is gone', async () => {
    await checkout();
    await packLists(true, root);
    const owners = await readFile(join(root, '.github', 'CODEOWNERS'), 'utf8');
    expect(owners).toContain('/packs/zz/              @someone   @org/everyone\n');
    expect(owners).toContain('/packs/aa/              @org/everyone\n');
    expect(owners).not.toContain('/packs/gone/');
    expect(owners.startsWith('*   @org/everyone\n\n# generated:packs\n')).toBe(true);
  });

  it('refuses a block whose markers are gone, and writes nothing into it', async () => {
    await checkout();
    await writeFile(join(root, 'docs', 'packs.md'), 'A table somebody deleted the markers of.\n');
    const lists = await packLists(true, root);
    expect(lists.find((l) => l.file === 'docs/packs.md')?.state).toBe('missing');
    expect(await readFile(join(root, 'docs', 'packs.md'), 'utf8')).toBe('A table somebody deleted the markers of.\n');
  });
});
