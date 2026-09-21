/**
 * The lists of packs that live outside `packs/`, written from `packs/`.
 *
 * A country is a folder. But four files of the repository also have to name it:
 * `supabase/config.toml`, which is what `supabase db reset` applies; the
 * `psql -f` lines of the README, which is what an operator installing by hand
 * copies; `.github/CODEOWNERS`, which is who has to have read a change to the
 * pack; and the table of packs in `docs/packs.md`, which is what a reader is
 * told the checkout carries. Each of them used to be edited by hand by every
 * pull request that added a country — four one-line conflicts per pack, and
 * one list or another quietly a country behind, like the installation guide
 * that promised "the four country packs" a week after the eleventh landed.
 *
 * So they are generated, the way a seed is: `ekwo pack build` writes them and
 * `ekwo pack check` refuses one that is not what the packs say. The pack is the
 * source, and adding a country is `packs/<cc>/` and one command.
 *
 * Only a **block** of each file is generated, between two markers, and the
 * rest is prose somebody wrote:
 *
 *     <!-- generated:<name> -->  …  <!-- /generated -->     in Markdown
 *     # generated:<name>         …  # /generated            in TOML and CODEOWNERS
 *
 * A marker that has gone missing is a refusal, not a block silently skipped:
 * the list would stop being maintained without anybody being told.
 *
 * Nothing here is written down per country. The seeds are the files the
 * installer applies (`listSeeds`), the packs are `listPacks()`, and what a
 * row says about a pack — its name, its seed, its languages, its status — is
 * read from its manifest, alone, so that one pack being rewritten next door
 * never stops another from being built.
 */

import { existsSync } from 'node:fs';
import { readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { listSeeds } from '../seeds.js';
import { seedFileName } from './compile.js';
import { declaredSeedSequences, listPacks, packsDir, repoRootDir, seedOutputDir } from './read.js';

/** One generated block: in which file, under which name, and how its markers are written. */
interface Block {
  file: string;
  name: string;
  style: 'markdown' | 'hash';
  /** The block's new body, from the current one and the whole file — CODEOWNERS keeps the owners it names. */
  render: (current: string, file: string) => string;
}

export interface GeneratedList {
  /** From the root of the repository. */
  file: string;
  block: string;
  state: 'written' | 'unchanged' | 'stale' | 'missing';
}

/** What a manifest says about itself that a list prints. Read on its own, as `declaredSeedSequences` does. */
interface ManifestSummary {
  slug: string;
  name: string;
  seed: string;
  languages: string[];
  status: string;
}

function markers(style: Block['style'], name: string): [string, string] {
  return style === 'markdown'
    ? [`<!-- generated:${name} -->`, '<!-- /generated -->']
    : [`# generated:${name}`, '# /generated'];
}

/** The text between a block's two markers, or null where either is missing. */
function bodyOf(text: string, block: Block): { start: number; end: number; body: string } | null {
  const [open, close] = markers(block.style, block.name);
  const at = text.indexOf(open);
  if (at < 0) return null;
  const start = at + open.length;
  const end = text.indexOf(close, start);
  if (end < 0) return null;
  return { start, end, body: text.slice(start, end) };
}

async function summaries(dir: string): Promise<ManifestSummary[]> {
  const slugs = await listPacks(dir);
  const declared = await declaredSeedSequences(dir);
  const out: ManifestSummary[] = [];
  for (const slug of slugs) {
    const manifest = JSON.parse(await readFile(join(dir, slug, 'pack.json'), 'utf8')) as {
      name?: string;
      languages?: string[];
      defaults?: { language?: string };
      certification?: { status?: string };
    };
    const own = manifest.defaults?.language;
    out.push({
      slug,
      name: manifest.name ?? slug,
      seed: seedFileName(slug, slugs, declared),
      languages: [...(own === undefined ? [] : [own]), ...(manifest.languages ?? []).filter((l) => l !== own)],
      status: manifest.certification?.status ?? 'none',
    });
  }
  return out;
}

/** Every block this repository generates from its packs, with the text each should hold. */
async function blocks(root: string): Promise<Block[]> {
  const dir = packsDir(root);
  const packs = await summaries(dir);
  const seeds = (await listSeeds(seedOutputDir(root))).map((s) => s.file);

  return [
    {
      // What `supabase db reset` applies. The same set the installer applies,
      // which `tests/e2e/install_parity.test.ts` compares row by row.
      file: 'supabase/config.toml',
      name: 'seeds',
      style: 'hash',
      render: () => `\n${seeds.map((f) => `  "./seed/${f}",`).join('\n')}\n`,
    },
    {
      // The by-hand install: one `psql -f` per reference seed, in the order
      // the installer applies them.
      file: 'README.md',
      name: 'seeds',
      style: 'markdown',
      render: () =>
        `\n\`\`\`sh\n${seeds.map((f) => `psql "$DATABASE_URL" -f supabase/seed/${f}`).join('\n')}\n\`\`\`\n`,
    },
    {
      file: 'README.md',
      name: 'countries',
      style: 'markdown',
      render: () => {
        const names = packs.map((p) => `${p.name} (\`${p.slug}\`)`);
        return names.length < 2 ? names.join('') : `${names.slice(0, -1).join(', ')} and ${names.at(-1)}`;
      },
    },
    {
      file: 'docs/packs.md',
      name: 'packs',
      style: 'markdown',
      render: () =>
        '\n| Pack | Country | Seed | Languages | Certification |\n|---|---|---|---|---|\n' +
        packs
          .map(
            (p) =>
              `| [\`${p.slug}\`](../packs/${p.slug}/) | ${p.name} | \`${p.seed}\` | ` +
              `${p.languages.join(', ') || '—'} | \`${p.status}\` |`,
          )
          .join('\n') +
        '\n',
    },
    {
      // Who reads a change to a pack. The owner a line names is kept — a
      // contributor who owns their pack wrote their handle there, and a
      // generator that reset it would take the review away from them. A pack
      // with no line yet gets the owner of everything else, the `*` line.
      file: '.github/CODEOWNERS',
      name: 'packs',
      style: 'hash',
      render: (current, file) => {
        const owners = new Map<string, string>();
        for (const line of current.split('\n')) {
          const match = /^\/packs\/([a-z]{2})\/\s+(\S.*)$/.exec(line.trim());
          if (match) owners.set(match[1] as string, (match[2] as string).trim());
        }
        return `\n${packs
          .map((p) => `${`/packs/${p.slug}/`.padEnd(23)} ${owners.get(p.slug) ?? defaultOwner(file)}`)
          .join('\n')}\n`;
      },
    },
  ];
}

/** The owner of the `*` line of a CODEOWNERS file: who owns what nothing more specific names. */
function defaultOwner(codeowners: string): string {
  for (const line of codeowners.split('\n')) {
    const match = /^\*\s+(\S.*)$/.exec(line.trim());
    if (match) return (match[1] as string).trim();
  }
  throw new Error('codeowners_no_default: .github/CODEOWNERS has no `*` line to give a new pack an owner');
}

/**
 * Compares every generated block with what the packs say, and with `write`
 * rewrites the ones that differ. Returns one line per block.
 */
export async function packLists(write: boolean, root = repoRootDir()): Promise<GeneratedList[]> {
  const results: GeneratedList[] = [];
  const texts = new Map<string, { before: string; after: string }>();

  for (const block of await blocks(root)) {
    const path = join(root, block.file);
    if (!texts.has(block.file)) {
      const text = existsSync(path) ? await readFile(path, 'utf8') : '';
      texts.set(block.file, { before: text, after: text });
    }
    const entry = texts.get(block.file) as { before: string; after: string };
    const found = bodyOf(entry.after, block);
    if (found === null) {
      results.push({ file: block.file, block: block.name, state: 'missing' });
      continue;
    }
    const body = block.render(found.body, entry.after);
    if (body === found.body) {
      results.push({ file: block.file, block: block.name, state: 'unchanged' });
      continue;
    }
    entry.after = entry.after.slice(0, found.start) + body + entry.after.slice(found.end);
    results.push({ file: block.file, block: block.name, state: write ? 'written' : 'stale' });
  }

  if (write) {
    for (const [file, { before, after }] of texts) {
      if (after !== before) await writeFile(join(root, file), after, 'utf8');
    }
  }
  return results;
}
