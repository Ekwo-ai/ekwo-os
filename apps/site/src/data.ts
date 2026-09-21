/**
 * Everything the site shows, read from the repository at build time.
 *
 * This is the only file that touches the disk, and it is the whole answer to
 * "where does that number on the page come from". Nothing below is written
 * down: the countries are the folders of `packs/`, in the order `listPacks()`
 * gives them; what each of them says is `describePack()`, the same object
 * `ekwo pack describe --json` prints; the documentation, the manifesto among
 * it, is the repository's own Markdown; the
 * counters are counted; the transcript on the home page is a real year of
 * books; and the links are built from the command line's own manifest.
 *
 * There is no country in this file, no currency, no language and no count. A
 * pack added to `packs/` gets a page, a row in the menu, a shape on the map and
 * a place in every comparison without a line of this site being edited — which
 * is the whole test, and `tests/site.test.ts` is where it is applied.
 */

import { readFile, readdir } from 'node:fs/promises';
import { existsSync, statSync } from 'node:fs';
import { join, posix } from 'node:path';
import { marked } from 'marked';
import {
  describePack,
  listPacks,
  packsDir,
  readPack,
  repoRootDir,
  type PackDescription,
} from '../../../packages/cli/src/index.js';
import { buildDemo, type Demo } from './demo.js';
import { renderMarkdown, type Heading, type Slice } from './markdown.js';
import { DOCS, FORMATS_DIR, FORMATS_TOPIC, type DocSource, type Topic } from './data/docs.js';
import { SOURCE } from './strings/index.js';
import world from './data/world.json' with { type: 'json' };
import m49 from './data/regions.json' with { type: 'json' };

/** The branch a link into the repository points at. */
const BRANCH = 'main';

/** Where the repository is published, and what a reader can open there. */
export interface Repository {
  url: string;
  packageName: string;
  installCommand: string;
  packageUrl: string;
  license: string;
  file: (path: string) => string;
  dir: (path: string) => string;
  /** Where somebody proposing a country pack opens an issue. */
  newPackIssue: string;
}

/** One number the page prints, and the short word under it. */
export interface Counter {
  value: number;
  label: string;
  /** What was counted, for a reader who wonders. */
  note: string;
}

/** One country on the map: its shape, and what this repository has for it. */
export interface MapCountry {
  code: string;
  name: string;
  path: string;
  /** The pack, where one exists. Null is most of the world, and is the point. */
  pack: { slug: string; status: string } | null;
}

export interface WorldMap {
  width: number;
  height: number;
  countries: MapCountry[];
  /** Land ISO gives no two-letter code to. Drawn, never interactive. */
  other: string[];
  covered: number;
}

/**
 * A part of the world, and the packs written for it.
 *
 * The grouping is what keeps a list of two hundred countries readable: the
 * menu, the index and the map all print countries under their region rather
 * than in one column. `code` is the United Nations M49 code of the region,
 * which is also what the platform's region names answer to, so the name is
 * translated with nothing written here.
 */
export interface Region {
  /** M49, such as `150`; the empty string for a country the list does not place. */
  code: string;
  /** In the language rendered; empty for the unplaced, which the strings name. */
  name: string;
  countries: PackDescription[];
}

/** One page of the documentation: a Markdown file of the repository, rendered. */
export interface DocArticle {
  /** The key the strings title it by; `formats/<dir>` for a format library. */
  slug: string;
  topic: Topic;
  /** Where it is published. */
  url: string;
  /** The file it is rendered from, from the root of the repository. */
  source: string;
  /** The article this one is listed under, for the format libraries. */
  parent: string | null;
  /** The file's own title, with its inline code kept, where it has one. */
  titleHtml: string | null;
  title: string | null;
  summary: string;
  html: string;
  headings: Heading[];
}

/** Everything one build of the site needs. */
export interface SiteData {
  countries: PackDescription[];
  /** The same packs, by region: every pack in exactly one, no region empty. */
  regions: Region[];
  /** Every page of the documentation, the manifesto among them, in the order they are listed. */
  docs: DocArticle[];
  positioningHtml: string;
  repository: Repository;
  counters: Counter[];
  world: WorldMap;
  demo: Demo | null;
  /** Brand marks, by basename, as the `d` of a single path. */
  icons: Record<string, string>;
  /** Distinct languages the packs publish, and the charts they carry. */
  languages: string[];
}

export async function readSiteData(): Promise<SiteData> {
  const root = repoRootDir();
  const dir = packsDir(root);
  const slugs = await listPacks(dir);
  const packs = await Promise.all(slugs.map((slug) => readPack(slug, dir)));
  const countries = packs.map((pack) => describePack(pack));

  const readme = await readFile(join(root, 'README.md'), 'utf8');
  const cli = JSON.parse(await readFile(join(root, 'packages', 'cli', 'package.json'), 'utf8')) as {
    name: string;
    repository?: { url?: string };
    license?: string;
  };
  const repository = repositoryOf(cli);

  const languages = [...new Set(countries.flatMap((country) => country.languages))].sort();

  return {
    countries,
    regions: regionsOf(countries, SOURCE.lang),
    docs: await readDocs(root, repository),
    positioningHtml: await marked.parseInline(positioningLine(readme)),
    repository,
    counters: await countersOf(root, countries, languages),
    world: worldOf(countries, SOURCE.lang),
    demo: await buildDemo(packs, dir),
    icons: await readIcons(root),
    languages,
  };
}

/**
 * The numbers on the home page, each counted rather than remembered.
 *
 * What is deliberately absent is the size of the test suite. It is the number
 * a reader would find most persuasive and it is the one that cannot be counted
 * honestly here: grepping for `it(` gives 2110 where the runner reports 2643,
 * because a table-driven test is one `it(` and many cases. A number that is
 * twenty per cent wrong in the direction that flatters is not a number to put
 * on a home page, so the count is of test *files*, which is exact.
 */
async function countersOf(
  root: string,
  countries: PackDescription[],
  languages: string[],
): Promise<Counter[]> {
  const formats = (await readdir(join(root, 'packages', 'formats'), { withFileTypes: true })).filter(
    (entry) => entry.isDirectory(),
  ).length;

  const server = await readFile(join(root, 'packages', 'mcp', 'src', 'server.ts'), 'utf8');
  const tools = server.split('registerTool').length - 1;

  const sources = new Set(
    countries.flatMap((country) => country.certification.sources.map((source) => source.url)),
  ).size;

  return [
    { value: countries.length, label: 'countries', note: 'one pack each, written as data' },
    { value: languages.length, label: 'languages', note: 'charts and labels translated in the packs' },
    { value: formats, label: 'legal formats', note: 'written or read, as independent libraries' },
    { value: tools, label: 'tools an agent can call', note: 'the same ones a person uses' },
    { value: sources, label: 'texts of law cited', note: 'each with the day it was last opened' },
  ];
}

/**
 * The map: every country there is, with its pack where one exists.
 *
 * The geometry is Natural Earth, which is in the public domain, simplified and
 * projected once and committed as `data/world.json`; the colouring is the
 * packs. A country nothing here covers is drawn all the same and links to the
 * guide for writing a pack, which is the message rather than an omission.
 */
export function worldOf(countries: PackDescription[], lang: string): WorldMap {
  const byCode = new Map(countries.map((country) => [country.country, country]));
  // The geometry ships abbreviated and sometimes outdated labels — a country
  // renamed in 2019 still under its old name, "Bosnia and Herz.", "Dem. Rep.
  // Congo". On a public page a country's name being wrong or truncated is a
  // visible fault, and the list of territories is not a subject to be casual
  // about. So the geometry supplies the shape and the ISO code, and the NAME
  // comes from the platform's own region names, in the language being rendered
  // — which is also what will translate them when there is a second language.
  const regions = new Intl.DisplayNames([lang], { type: 'region' });
  const shapes = Object.entries(world.countries).map(([code, shape]) => {
    const pack = byCode.get(code);
    return {
      code,
      // A country with a pack is named by the pack — that is the word it chose
      // for itself — and every other one by the region list.
      name: pack?.name ?? regions.of(code) ?? shape.name,
      path: shape.d,
      pack: pack === undefined ? null : { slug: pack.slug, status: pack.certification.status },
    } satisfies MapCountry;
  });
  shapes.sort((a, b) => a.name.localeCompare(b.name));
  return {
    width: world.width,
    height: world.height,
    countries: shapes,
    other: world.other,
    covered: shapes.filter((shape) => shape.pack !== null).length,
  };
}

/**
 * The packs, grouped by the region the United Nations places their country in.
 *
 * The table is `data/regions.json`, copied once from the M49 list of the UN
 * Statistics Division, the same way the map is copied once from Natural Earth:
 * it is data about the world, not about this repository, and it names every
 * country whether or not a pack exists. A country the list does not place goes
 * to one group at the end rather than being guessed into a region.
 *
 * Regions are in alphabetical order of their name, and so are the countries
 * within each — the order a reader scans a list in, and the order a
 * `<select>` answers typing in. Exported because the test groups made-up packs with
 * it to see the site hold at two hundred countries.
 */
export function regionsOf(countries: readonly PackDescription[], lang: string): Region[] {
  const names = new Intl.DisplayNames([lang], { type: 'region' });
  const table = m49.regions as Record<string, string>;
  const byCode = new Map<string, PackDescription[]>();
  for (const country of countries) {
    const code = table[country.country] ?? '';
    byCode.set(code, [...(byCode.get(code) ?? []), country]);
  }
  const regions = [...byCode].map(([code, members]) => ({
    code,
    name: code === '' ? '' : (names.of(code) ?? code),
    countries: members.sort((a, b) => a.name.localeCompare(b.name, lang)),
  }));
  return regions.sort((a, b) =>
    a.code === '' ? 1 : b.code === '' ? -1 : a.name.localeCompare(b.name, lang),
  );
}

/**
 * The brand marks, as the single path each `simple-icons` file carries.
 *
 * Found from the repository root and not from `import.meta.url`: this module is
 * bundled into `.prerender/` before it runs, so its own URL is the build's and
 * not the source's — which is why the first build rendered every pill as a word
 * with no mark beside it, and said nothing about it.
 */
async function readIcons(root: string): Promise<Record<string, string>> {
  const dir = join(root, 'apps', 'site', 'src', 'icons');
  const out: Record<string, string> = {};
  if (!existsSync(dir)) return out;
  for (const name of (await readdir(dir)).filter((file) => file.endsWith('.svg'))) {
    const svg = await readFile(join(dir, name), 'utf8');
    const path = /\sd="([^"]+)"/.exec(svg);
    if (path !== null) out[name.replace(/\.svg$/, '')] = path[1] as string;
  }
  return out;
}

/**
 * The documentation: the files `data/docs.ts` lists, plus one article per
 * format library, each rendered from the repository as it stands.
 *
 * Two passes, because a link can point at a heading of another article: the
 * first finds which article carries which heading, the second renders with
 * every link resolved against that. A link to a file that is an article goes
 * to the article; a link to anything else in the repository goes to GitHub,
 * where it works — a directory to its tree, a file to its blob.
 */
async function readDocs(root: string, repository: Repository): Promise<DocArticle[]> {
  const formats = (await readdir(join(root, FORMATS_DIR), { withFileTypes: true }))
    .filter((entry) => entry.isDirectory() && existsSync(join(root, FORMATS_DIR, entry.name, 'README.md')))
    .map((entry) => entry.name)
    .sort();

  const listed: (DocSource & { parent: string | null })[] = [];
  for (const doc of DOCS) {
    listed.push({ ...doc, parent: null });
    if (doc.source === `${FORMATS_DIR}/README.md`) {
      for (const name of formats) {
        listed.push({
          slug: `formats/${name}`,
          topic: FORMATS_TOPIC,
          source: `${FORMATS_DIR}/${name}/README.md`,
          parent: doc.slug,
        });
      }
    }
  }

  const texts = new Map<string, string>();
  for (const doc of listed) {
    if (!texts.has(doc.source)) texts.set(doc.source, await readFile(join(root, doc.source), 'utf8'));
  }
  const urlOf = (doc: DocSource): string => doc.url ?? `/docs/${doc.slug}/`;
  const render = (doc: DocSource, resolveLink: (href: string) => string) =>
    renderMarkdown(texts.get(doc.source) as string, {
      ...(doc.section === undefined ? {} : { slice: doc.section as Slice }),
      resolveLink,
      source: doc.source,
    });

  // First pass: which headings each article carries.
  const carried = new Map(listed.map((doc) => [doc, new Set(render(doc, (href) => href).headings.map((h) => h.id))]));

  const articleFor = (source: string, anchor: string): DocSource | undefined => {
    const candidates = listed.filter((doc) => doc.source === source);
    return anchor === ''
      ? candidates[0]
      : (candidates.find((doc) => carried.get(doc)?.has(anchor)) ?? candidates[0]);
  };

  const resolverFor = (source: string) => (href: string): string => {
    if (/^[a-z][a-z0-9+.-]*:/i.test(href) || href.startsWith('//') || href.startsWith('/')) return href;
    const hash = href.indexOf('#');
    const path = hash === -1 ? href : href.slice(0, hash);
    const anchor = hash === -1 ? '' : href.slice(hash + 1);
    const suffix = anchor === '' ? '' : `#${anchor}`;
    const target = path === '' ? source : posix.normalize(posix.join(posix.dirname(source), path)).replace(/\/$/, '');
    if (target.startsWith('..')) return href;

    const isDir = existsSync(join(root, target)) && statSync(join(root, target)).isDirectory();
    const file = isDir ? posix.join(target, 'README.md') : target;
    const article = articleFor(file, anchor);
    if (article !== undefined) return `${urlOf(article)}${suffix}`;
    return `${isDir ? repository.dir(target) : repository.file(target)}${suffix}`;
  };

  return listed.map((doc) => {
    const rendered = render(doc, resolverFor(doc.source));
    return {
      slug: doc.slug,
      topic: doc.topic,
      url: urlOf(doc),
      source: doc.source,
      parent: doc.parent,
      titleHtml: rendered.titleHtml,
      title: rendered.title,
      summary: rendered.summary,
      html: rendered.html,
      headings: rendered.headings,
    };
  });
}

/**
 * The sentence the `/os/` page opens with: the first line of `README.md` under
 * its title. Read rather than copied, so the site and the repository cannot
 * come to say different things about what Ekwo OS is.
 */
export function positioningLine(readme: string): string {
  const lines = readme.split('\n');
  const title = lines.findIndex((line) => line.startsWith('# '));
  if (title === -1) throw new Error('README.md carries no title, so it has no first line under one');
  for (const line of lines.slice(title + 1)) {
    if (line.trim() !== '') return line.trim();
  }
  throw new Error('README.md says nothing under its title; the page has no sentence to show');
}

/** The links of the site, from the manifest of the package a reader installs. */
function repositoryOf(cli: {
  name: string;
  repository?: { url?: string };
  license?: string;
}): Repository {
  const declared = cli.repository?.url ?? '';
  const url = declared.replace(/^git\+/, '').replace(/\.git$/, '');
  if (!url.startsWith('https://')) {
    throw new Error(
      `packages/cli/package.json declares no https repository (got ${JSON.stringify(declared)}), ` +
        'and every link of this site is built from it',
    );
  }
  return {
    url,
    packageName: cli.name,
    installCommand: `npx ${cli.name} init`,
    packageUrl: `https://www.npmjs.com/package/${cli.name}`,
    // The manifest carries the SPDX identifier, whose `-only` says "this version
    // and no later one". A reader knows the licence by its name, so the page
    // prints the name; the identifier stays where tools read it.
    license: (cli.license ?? 'AGPL-3.0-only').replace(/-only$/, ''),
    file: (path) => `${url}/blob/${BRANCH}/${path}`,
    dir: (path) => `${url}/tree/${BRANCH}/${path}`,
    newPackIssue: `${url}/issues/new/choose`,
  };
}
