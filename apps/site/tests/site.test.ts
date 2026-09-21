import { existsSync } from 'node:fs';
import { readdir, readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { listPacks, packsDir, repoRootDir } from '../../../packages/cli/src/index.js';
import { readSiteData } from '../src/data.js';
import { document, renderPages, robots, siteOrigin, sitemap } from '../src/render.js';
import { statusRows } from '../src/pages/rows.js';
import { HANDED_TO_THE_APPLICATION, SUPABASE_HREF } from '../src/pages/ui.js';
import { PICKERS } from '../src/pages/Compare.js';
import { DOCS, FORMATS_DIR } from '../src/data/docs.js';
import { CLAUDE_CODE_TOOLS, MCP_PREFIX } from '../src/demo.js';
import { AUTOMATION, CAPABILITIES, PLANNED_MODULES } from '../src/data/capabilities.js';
import { AUDIENCES, LATER, SHIPPED } from '../src/data/multicountry.js';
import { FOUNDATIONS, MODELS, NOT_LISTED } from '../src/data/ecosystem.js';
import { LANGUAGES, SOURCE, fill, prefixOf } from '../src/strings/index.js';
import { ICON_NAMES } from '../src/pages/icons.js';
import m49 from '../src/data/regions.json' with { type: 'json' };
import { llmsFiles } from '../src/llms.js';
import { HONEYPOT, SIGNUP, SIGNUP_FORM, THANKS, setUpCommand, setUpUrl } from '../src/pages/SetUp.js';

/**
 * The site is generated, and this is what says so.
 *
 * Every claim below is about the shape of the site rather than about a country:
 * that there is a page per pack the packs directory holds, that each carries
 * every row of the status table, that no link points at a page that was not
 * built, and — the one that would rot first — that no country is written into
 * the source of `apps/site` at all. A pack landing tomorrow has to get its
 * page, its comparisons, its shape on the map and its row in the menu without
 * a line of `apps/site` or of this file being edited.
 *
 * It renders rather than builds: `renderPages()` is what `vite build` writes to
 * disk, so testing it is testing what ships, and the suite does not need Vite
 * to have run.
 */

const data = await readSiteData();
const pages = renderPages(data);
const slugs = await listPacks(packsDir());
const byUrl = new Map(pages.map((page) => [page.url, page]));
const root = repoRootDir();

const HOME = '/';
const OS = '/os/';
const MANIFESTO = '/manifesto/';
const COMPARE = '/compare/';
const COUNTRIES = '/countries/';
const MULTI = '/multi-country/';
const DOCS_INDEX = '/docs/';
const ROWS = statusRows(SOURCE);

describe('the pages that exist', () => {
  it('is two per pack, one per country without one and one per article, plus the nine pages of the site, for every language', () => {
    // Per pack: its page and the page that sets it up. Per other country: its
    // page saying where it stands.
    expect(pages.length).toBe(
      LANGUAGES.length * (2 * slugs.length + data.waiting.length + data.docs.length + 9),
    );
    expect(new Set(pages.map((page) => page.url)).size).toBe(pages.length);
  });

  it('publishes the source language at the root, and every other under its prefix', () => {
    expect(prefixOf(SOURCE)).toBe('');
    for (const strings of LANGUAGES) {
      if (strings === SOURCE) continue;
      expect(prefixOf(strings)).toBe(`${strings.lang}/`);
    }
  });

  it('keeps the two-letter prefixes free for languages', () => {
    // A country page under `/<cc>/` would collide with the language prefix of
    // the same two letters, which is most of the countries a European ledger
    // meets first. Nothing at the root may be two letters but a language.
    const languages = new Set(LANGUAGES.map((strings) => strings.lang));
    // `/os/` is the core's page and is two letters. It is also the code of a
    // language nobody has translated this into, and if somebody ever does, the
    // page moves rather than the translation: that is the whole point of
    // keeping the rest of the space clear, so it is written down here and not
    // discovered later.
    const taken = new Set(['os']);
    for (const page of pages) {
      const first = page.url.split('/')[1] ?? '';
      if (/^[a-z]{2}$/.test(first) && !taken.has(first)) {
        expect(languages.has(first), `${page.url} takes a language prefix`).toBe(true);
      }
    }
  });

  it('gives every pack of the repository a page of its own', () => {
    for (const slug of slugs) {
      const page = byUrl.get(`${COUNTRIES}${slug}/`);
      expect(page, `packs/${slug} has no page`).toBeDefined();
      expect(page!.file).toBe(`countries/${slug}/index.html`);
    }
  });

  it('builds the home page, the core page, the manifesto, the docs and the index of comparisons', () => {
    for (const url of [HOME, OS, MANIFESTO, DOCS_INDEX, COMPARE, COUNTRIES, MULTI]) {
      expect(byUrl.get(url), `${url} was not built`).toBeDefined();
    }
  });

  it('compares any two packs on one page, never on a page per pair', () => {
    expect(pages.filter((page) => page.url.startsWith(COMPARE)).map((page) => page.url)).toEqual([COMPARE]);
    const body = byUrl.get(COMPARE)!.body;
    for (const picker of PICKERS) {
      const select = new RegExp(`<select id="${picker}"[^>]*>([\\s\\S]*?)</select>`).exec(body);
      expect(select, `${picker} is not drawn`).not.toBeNull();
      const options = [...select![1]!.matchAll(/<option value="([a-z]{2})"/g)].map((m) => m[1]);
      expect([...options].sort()).toEqual([...slugs].sort());
    }
    // Every row carries one cell per pack, and every pack has the two rules
    // that show its cells when it is picked.
    for (const slug of slugs) {
      expect(body.split(`<td role="cell" data-c="${slug}"`).length - 1).toBe(ROWS.length);
      for (const picker of PICKERS) {
        expect(body).toContain(`#${picker} option[value="${slug}"]:checked`);
      }
    }
  });

  it('shows two different packs before anybody picks', () => {
    const body = byUrl.get(COMPARE)!.body;
    const chosen = PICKERS.map(
      (picker) =>
        new RegExp(`<select id="${picker}"[\\s\\S]*?<option value="([a-z]{2})" selected`).exec(body)?.[1],
    );
    expect(chosen[0]).toBeDefined();
    expect(chosen[1]).toBeDefined();
    expect(chosen[0]).not.toBe(chosen[1]);
  });

  it('gives every page a title and a description of its own', () => {
    const titles = pages.map((page) => page.title);
    expect(new Set(titles).size).toBe(titles.length);
    for (const page of pages) {
      expect(page.title.length).toBeGreaterThan(0);
      expect(page.description.length).toBeGreaterThan(0);
    }
  });
});

/**
 * The rule the whole site rests on, checked where it can actually be broken.
 *
 * Reading the rendered HTML for a country code cannot work: the map carries the
 * name of every country on earth, and ordinary English prose contains the
 * letters of a pack slug — "Talk to us" is not a hard-coded country. So the
 * check is on the *source*: no file of `apps/site/src` may contain a pack slug
 * as a quoted string or the name of a country a pack describes.
 */
describe('no country is written into the site', () => {
  const skip = new Set(['world.json', 'regions.json', 'icons', 'fonts']);

  async function sources(dir: string): Promise<string[]> {
    const out: string[] = [];
    for (const entry of await readdir(dir, { withFileTypes: true })) {
      if (skip.has(entry.name)) continue;
      const path = join(dir, entry.name);
      if (entry.isDirectory()) out.push(...(await sources(path)));
      else if (/\.(ts|tsx|css|html)$/.test(entry.name)) out.push(path);
    }
    return out;
  }

  it('names no pack slug and no country in any source file', async () => {
    const files = await sources(join(root, 'apps', 'site', 'src'));
    expect(files.length).toBeGreaterThan(5);
    for (const file of files) {
      const text = await readFile(file, 'utf8');
      for (const slug of slugs) {
        for (const quoted of [`'${slug}'`, `"${slug}"`, `/${slug}/`]) {
          expect(text.includes(quoted), `${file} writes ${quoted}`).toBe(false);
        }
      }
      for (const country of data.countries) {
        expect(text.includes(country.name), `${file} names ${country.name}`).toBe(false);
        // As a word: `STATUS_ROWS` carries the letters of a country code and
        // is not a country.
        const code = new RegExp(`\\b${country.country}\\b`);
        expect(code.test(text), `${file} writes ${country.country}`).toBe(false);
      }
    }
  });

  it('links to every pack from the home page, and to no country that is neither a pack nor waiting for one', () => {
    const body = byUrl.get(HOME)!.body;
    const linked = new Set(
      [...body.matchAll(/href="\/countries\/([a-z]{2})\/"/g)].map((match) => match[1] as string),
    );
    for (const slug of slugs) expect(linked.has(slug), slug).toBe(true);
    const waiting = new Set(data.waiting.map((country) => country.slug));
    for (const slug of linked) expect(slugs.includes(slug) || waiting.has(slug), slug).toBe(true);
  });
});

/**
 * A translation is published complete, or it is not published.
 *
 * A half-translated site is worse than an English one, because a reader cannot
 * tell which half they are getting. The shape is a type, so a missing key is
 * already a compile error; this is the same rule at runtime, where a key added
 * to the source after a translation was written would otherwise sit unnoticed.
 */
describe('every language', () => {
  const keys = (value: unknown, path = ''): string[] => {
    if (value === null || typeof value !== 'object') return [path];
    if (Array.isArray(value)) return value.flatMap((item, i) => keys(item, `${path}[${i}]`));
    return Object.entries(value).flatMap(([k, v]) => keys(v, path === '' ? k : `${path}.${k}`));
  };
  const source = keys(SOURCE).sort();

  it('says everything the source says, and nothing it does not', () => {
    for (const strings of LANGUAGES) {
      expect(keys(strings).sort(), `${strings.lang} does not match the source`).toEqual(source);
    }
  });

  it('names itself, and answers to a language tag', () => {
    for (const strings of LANGUAGES) {
      expect(strings.lang).toMatch(/^[a-z]{2}(-[A-Za-z0-9]+)*$/);
      expect(strings.languageName.length).toBeGreaterThan(0);
    }
    expect(new Set(LANGUAGES.map((s) => s.lang)).size).toBe(LANGUAGES.length);
  });

  it('names a row of the status table for every row the site draws', () => {
    for (const strings of LANGUAGES) {
      expect(statusRows(strings).length).toBe(ROWS.length);
    }
  });
});

describe('the home page', () => {
  const home = () => byUrl.get(HOME)!;

  it('draws every country on earth, and links the uncovered ones to the guide', () => {
    const body = home().body;
    // The map is the world, not the coverage: it draws the countries of
    // the Natural Earth layer whether or not a pack exists, so it holds more
    // shapes than there are packs, and never fewer than the world has.
    expect(data.world.countries.length).toBeGreaterThan(slugs.length);
    expect(data.world.countries.length).toBeGreaterThan(150);
    // Never more shapes coloured than packs; fewer where a country is too
    // small to be drawn at this scale, which the list under the map names.
    expect(data.world.covered).toBeLessThanOrEqual(slugs.length);
    expect(body).toContain(data.repository.file('docs/packs.md'));
  });

  it('has exactly one heading, and it says the same thing to everybody', () => {
    const body = home().body;
    expect((body.match(/<h1/g) ?? []).length).toBe(1);
    // The words that turn are decoration: the accessible name of the heading
    // is the stable sentence, and nothing announces itself as it changes.
    expect(body).toContain(SOURCE.home.hero.titleAccessible);
    expect(body).not.toContain('aria-live');
    // Every word of the rotation is in the HTML, so it costs no request and
    // needs no script; all but the first are hidden from the accessible tree.
    for (const word of SOURCE.home.hero.titleWords) expect(body).toContain(word);
  });

  it('prints only counters it counted', () => {
    for (const counter of data.counters) {
      expect(counter.value).toBeGreaterThan(0);
      expect(Number.isInteger(counter.value)).toBe(true);
      expect(home().body).toContain(`>${counter.value}<`);
    }
    // The size of the test suite is the number a reader would find most
    // persuasive and the one that cannot be counted honestly at build time.
    expect(data.counters.some((counter) => counter.label === 'tests')).toBe(false);
  });

  it('shows a transcript replayed from a pack of this repository', () => {
    expect(data.demo).not.toBeNull();
    expect(slugs).toContain(data.demo!.slug);
    // Every command shown is one the command line documents.
    // The command line tab types commands that exist; the agent tab calls
    // tools the MCP server registers. An earlier draft showed `ekwo doc post`
    // and `ekwo vat return`, and neither is a command.
    const commands = data.demo!.cli.filter((line) => line.kind === 'command');
    expect(commands.length).toBeGreaterThan(2);
    for (const line of commands) expect(line.text.startsWith('ekwo ')).toBe(true);
    const calls = data.demo!.agent.filter((line) => line.kind === 'command');
    expect(calls.length).toBeGreaterThan(2);
    // The agent stops and asks before anything is booked. That is the claim.
    expect(data.demo!.agent.some((line) => line.kind === 'ask')).toBe(true);
  });

  it('names no model or foundation twice, and keeps every source it cites', () => {
    for (const row of [MODELS, FOUNDATIONS]) {
      const names = row.map((mark) => mark.name);
      expect(new Set(names).size).toBe(names.length);
      for (const mark of row) {
        expect(mark.source.startsWith('https://')).toBe(true);
        expect(home().body).toContain(mark.name);
      }
    }
    // Alphabetical, so that nobody is featured by being first. It is the rule
    // of the models row only: the foundations row leads with what Ekwo installs
    // on, which is an order that says something rather than ranking anybody.
    const models = MODELS.map((mark) => mark.name);
    expect([...models].sort((a, b) => a.localeCompare(b))).toEqual(models);
    // What was asked for and left out is written down, and stays off the page.
    expect(NOT_LISTED.length).toBeGreaterThan(0);
    for (const entry of NOT_LISTED) expect(home().body).not.toContain(entry.name);
  });

  it('names the models under the buttons of the hero, once', () => {
    const body = home().body;
    const heroEnd = body.indexOf('</section>', body.indexOf('<h1'));
    const hero = body.slice(0, heroEnd);
    const below = body.slice(heroEnd);
    const models = SOURCE.home.hero.models;

    // One button leads, to the form; the installation sits beside it. The
    // manifesto is not a third: it is reached from the docs and the foot of
    // the home page.
    const buttons = [...hero.matchAll(/<a href="([^"]+)" class="([^"]+)">([^<]+)<\/a>/g)]
      .map(([, href = '', classes = '', text = '']) => ({ href, classes, text }))
      .filter((button) => button.classes.includes('rounded-pill'))
      .map(({ href, classes, text }) => ({ href, solid: classes.includes('bg-brand-solid'), text }));
    expect(buttons).toEqual([
      { href: SIGNUP, solid: true, text: SOURCE.home.hero.start },
      { href: '/os/', solid: false, text: SOURCE.home.hero.install },
    ]);
    expect(hero).not.toContain('href="/manifesto/"');
    expect(body).toContain('href="/manifesto/"');

    // The row: after the buttons, a list named by its label, every model in
    // it by name, and the small print under it.
    const row = hero.slice(hero.indexOf('data-hero-models'));
    expect(row.length).toBeLessThan(hero.length);
    expect(row).toContain(models.label);
    expect(row).toMatch(/<ul aria-labelledby="hero-models"/);
    for (const mark of MODELS) expect(row).toContain(`>${mark.name}<`);
    expect(row).toContain(models.any);
    expect(row).toContain(models.ownership);

    // Further down the page explains it and does not list the models again.
    expect(below).toContain(SOURCE.home.models.title);
    expect(below).not.toContain(models.label);
    for (const mark of MODELS) expect(below).not.toContain(`>${mark.name}<`);
  });

  it('carries the marks it claims to, and no icon it has no file for', () => {
    for (const mark of [...MODELS, ...FOUNDATIONS]) {
      if (mark.icon === null) continue;
      expect(data.icons[mark.icon], `no icon file for ${mark.name}`).toBeDefined();
    }
  });
});

/**
 * The documentation is the repository's own files, rendered.
 *
 * What would rot first: a file listed here and moved in the repository, a
 * heading a slice starts at renamed, a link written for GitHub that lands on a
 * page this site does not have, and a format library added without an article.
 */
describe('the documentation', () => {
  const docPages = pages.filter((page) => page.url.startsWith(DOCS_INDEX) || page.url === MANIFESTO);

  it('renders every file it lists, from a file that exists', () => {
    for (const doc of DOCS) {
      expect(existsSync(join(root, doc.source)), `${doc.slug}: ${doc.source} does not exist`).toBe(true);
      const article = data.docs.find((entry) => entry.slug === doc.slug);
      expect(article, `${doc.slug} was not rendered`).toBeDefined();
      expect(article!.html.length, `${doc.slug} rendered nothing`).toBeGreaterThan(200);
      expect(byUrl.get(article!.url), `${article!.url} was not built`).toBeDefined();
    }
  });

  it('keeps the manifesto at the address it always had, as one of the articles', () => {
    const manifesto = data.docs.find((entry) => entry.source === 'MANIFESTO.md');
    expect(manifesto?.url).toBe(MANIFESTO);
    expect(byUrl.get(DOCS_INDEX)!.body).toContain(`href="${MANIFESTO}"`);
  });

  it('gives every format library an article of its own', async () => {
    const dirs = (await readdir(join(root, FORMATS_DIR), { withFileTypes: true }))
      .filter((entry) => entry.isDirectory() && existsSync(join(root, FORMATS_DIR, entry.name, 'README.md')))
      .map((entry) => entry.name);
    expect(dirs.length).toBeGreaterThan(3);
    for (const dir of dirs) {
      expect(byUrl.get(`${DOCS_INDEX}formats/${dir}/`), `${dir} has no article`).toBeDefined();
    }
  });

  it('titles every listed article in every language, and notes only articles that exist', () => {
    for (const strings of LANGUAGES) {
      for (const doc of DOCS) expect(strings.docs.articles[doc.slug], `${doc.slug} has no title`).toBeDefined();
      for (const slug of Object.keys(strings.docs.notes)) {
        expect(DOCS.some((doc) => doc.slug === slug), `a note for ${slug}, which is not an article`).toBe(true);
      }
    }
  });

  it('draws one heading per page, whatever the file had', () => {
    for (const page of docPages) {
      expect((page.body.match(/<h1/g) ?? []).length, `${page.url} has more than one <h1>`).toBe(1);
    }
  });

  it('never sends a link written for GitHub to a relative address here', () => {
    for (const page of docPages) {
      for (const match of page.body.matchAll(/href="([^"]*)"/g)) {
        const href = match[1] as string;
        expect(
          /^(https?:|mailto:|\/|#)/.test(href),
          `${page.url} links to ${href}, which is relative to nothing on this site`,
        ).toBe(true);
      }
    }
  });

  it('links a heading of another article to the article that carries it', () => {
    // The command line's reference is cut out of the same README as the
    // installation guide, and each links into the other.
    for (const page of docPages) {
      for (const match of page.body.matchAll(/href="(\/docs\/[^"#]+\/)#([^"]+)"/g)) {
        const target = data.docs.find((entry) => entry.url === match[1]);
        expect(target, `${page.url} links to ${match[1]}`).toBeDefined();
        // A heading, or an anchor the file writes itself, as the schema does.
        expect(
          target!.html.includes(`id="${match[2]}"`),
          `${page.url} links to #${match[2]}, which ${match[1]} does not carry`,
        ).toBe(true);
      }
    }
  });

  it('gives every block of code a way to be copied, and ships it hidden', () => {
    let blocks = 0;
    for (const page of docPages) {
      const pres = (page.body.match(/<pre>/g) ?? []).length;
      const wrapped = (page.body.match(/<div class="code-block" data-code><pre>/g) ?? []).length;
      const buttons = page.body.match(/<button[^>]*data-copy-code[^>]*>/g) ?? [];
      expect(wrapped, `${page.url}: a <pre> is not in a copyable box`).toBe(pres);
      expect(buttons.length, `${page.url}: a block has no copy button`).toBe(pres);
      for (const button of buttons) {
        // A control that cannot work is not drawn: the script reveals it.
        expect(button).toContain('hidden');
        expect(button).toContain(`aria-label="${SOURCE.docs.copy}"`);
      }
      expect(page.body).not.toContain('<!--copy-->');
      blocks += pres;
    }
    expect(blocks).toBeGreaterThan(10);
  });

  it('says in every article which file it was rendered from, and links to it', () => {
    for (const article of data.docs) {
      const body = byUrl.get(article.url)!.body;
      expect(body).toContain(article.source);
      expect(body).toContain(data.repository.file(article.source));
    }
  });
});

describe('the header', () => {
  it('carries the docs, the repository and Supabase on every page, each with a name', () => {
    for (const page of pages) {
      expect(page.body).toContain(`href="${DOCS_INDEX}"`);
      expect(page.body).toContain(`href="${data.repository.url}"`);
      expect(page.body).toContain(`href="${SUPABASE_HREF}"`);
      expect(page.body).toContain(SOURCE.nav.github);
      expect(page.body).toContain(SOURCE.nav.supabase);
    }
    expect(data.icons['github'], 'no GitHub mark in src/icons').toBeDefined();
    expect(data.icons['supabase'], 'no Supabase mark in src/icons').toBeDefined();
  });
});

describe('the Claude Code session', () => {
  it('call only tools the MCP server registers, and Claude Code tools that exist', async () => {
    const server = await readFile(join(root, 'packages', 'mcp', 'src', 'server.ts'), 'utf8');
    const lines = data.demo!.claude;
    expect(lines).not.toBeNull();
    {
      const calls = lines!.filter((line) => line.kind === 'tool');
      expect(calls.length).toBeGreaterThan(2);
      for (const call of calls) {
        if (call.text.startsWith(MCP_PREFIX)) {
          const tool = call.text.slice(MCP_PREFIX.length).split(/\s/)[0] as string;
          expect(server, `${tool} is not a tool of the MCP server`).toMatch(
            new RegExp(`registerTool\\(\\s*'${tool}'`),
          );
        } else {
          const tool = call.text.split('(')[0] as string;
          expect(CLAUDE_CODE_TOOLS as readonly string[], `${tool} is not a Claude Code tool`).toContain(tool);
        }
      }
    }
  });

  it('plays one prompt, in one window', () => {
    const body = byUrl.get(HOME)!.body;
    const panel = body.slice(body.indexOf('data-panel="claude"'));
    expect((panel.match(/rounded-pill bg-line/g) ?? []).length, 'more than one window').toBe(3);
    expect((panel.match(/cc-thinking/g) ?? []).length).toBe(1);
    expect(panel).toContain(data.demo!.claude![0]!.text);
  });

  it('opens on what the person typed, once, and nothing else is typed', () => {
    const lines = data.demo!.claude!;
    expect(lines[0]!.kind).toBe('prompt');
    expect(lines.filter((line) => line.kind === 'prompt')).toHaveLength(1);
    // The prompt is in the page whole, for a reader with no motion and no script.
    const body = byUrl.get(HOME)!.body;
    expect(body).toContain(data.demo!.claude![0]!.text);
  });

  it('plays nothing for a reader who asked for less motion', async () => {
    const css = await readFile(join(repoRootDir(), 'apps/site/src/styles.css'), 'utf8');
    const reduced = css.slice(css.indexOf('.cc-line'));
    expect(reduced).toMatch(/prefers-reduced-motion: reduce\)\s*\{[^@]*\.cc-char[^}]*animation:\s*none/);
    expect(reduced).toMatch(/\.cc-caret,\s*\.cc-thinking\s*\{\s*display:\s*none/);
  });

  it('books nothing on the way in, and asks before it would', () => {
    const lines = data.demo!.claude!;
    // Drafts only: no posting call, and the human is asked at the end.
    expect(lines.some((line) => line.text.includes('post_document'))).toBe(false);
    expect(lines.some((line) => line.text.includes(`${MCP_PREFIX}create_document`))).toBe(true);
    expect(lines.at(-1)!.kind).toBe('ask');
  });
});

describe('what the site says is in the box', () => {
  it('points every tile at something that exists in this repository', () => {
    for (const item of [...CAPABILITIES, ...AUTOMATION, ...PLANNED_MODULES]) {
      expect(existsSync(join(root, item.proof)), `${item.title}: ${item.proof} does not exist`).toBe(
        true,
      );
    }
  });

  it('draws no glyph with a currency in it', () => {
    for (const name of ICON_NAMES) {
      expect(/receipt|dollar|euro|pound|currency|banknote|bitcoin/i.test(name), `${name} draws a currency`).toBe(false);
    }
  });

  it('draws every tile with an icon the registry answers to', () => {
    for (const item of [...CAPABILITIES, ...AUTOMATION, ...PLANNED_MODULES]) {
      expect(ICON_NAMES, `${item.title} asks for the icon ${item.icon}`).toContain(item.icon);
    }
  });

  it('fills every row of the grid, three to a row on a wide screen', () => {
    // A family with a short last row reads as something missing.
    const families = new Set(CAPABILITIES.map((item) => item.family));
    for (const family of families) {
      const count = CAPABILITIES.filter((item) => item.family === family).length;
      expect(count % 3, `${family} has ${count} tiles`).toBe(0);
    }
  });

  it('says shipped or planned, and nothing else', () => {
    for (const item of [...CAPABILITIES, ...AUTOMATION]) {
      expect(['shipped', 'planned']).toContain(item.status);
    }
    // Both words are used: a grid where everything ships is a grid nobody wrote
    // honestly, and one where nothing does is not a product.
    const all = [...CAPABILITIES, ...AUTOMATION, ...PLANNED_MODULES];
    expect(all.some((item) => item.status === 'shipped')).toBe(true);
    expect(all.some((item) => item.status === 'planned')).toBe(true);
  });
});

describe('the page for several countries', () => {
  const body = () => byUrl.get(MULTI)!.body;

  it('rests every claim of what works today on a file that exists', () => {
    for (const claim of SHIPPED) {
      expect(existsSync(join(root, claim.proof)), `${claim.key}: ${claim.proof} does not exist`).toBe(true);
      expect(body()).toContain(data.repository.file(claim.proof));
    }
    for (const claim of LATER) {
      if (claim.proof === null) continue;
      expect(existsSync(join(root, claim.proof)), `${claim.key}: ${claim.proof} does not exist`).toBe(true);
    }
  });

  it('has words for every claim and every reader, and no words for a claim that is not made', () => {
    for (const strings of LANGUAGES) {
      const m = strings.multi;
      expect(Object.keys(m.audiences).sort()).toEqual(AUDIENCES.map((a) => a.key).sort());
      expect(Object.keys(m.shipped).sort()).toEqual(SHIPPED.map((c) => c.key).sort());
      expect(Object.keys(m.later).sort()).toEqual(LATER.map((c) => c.key).sort());
    }
    for (const icon of [...AUDIENCES, ...SHIPPED].map((item) => item.icon)) {
      expect(ICON_NAMES, `${icon} is not in the registry`).toContain(icon);
    }
  });

  it('counts what it says it has, from the packs', () => {
    expect(body()).toContain(
      fill(SOURCE.multi.today, {
        countries: data.countries.length,
        currencies: new Set(data.countries.map((country) => country.currency)).size,
        languages: data.languages.length,
      }),
    );
  });

  it('offers an address to write to, and no price, form or sign-up', () => {
    expect(body()).toContain('href="mailto:');
    expect(body()).not.toMatch(/<form|<input|€|\$\d|sign up|per month/i);
  });

  it('is linked from the home page and from the foot of every page', () => {
    for (const page of pages) expect(page.body, `${page.url} does not link it`).toContain(`href="${MULTI}"`);
  });
});

describe('a country page', () => {
  it('carries every row of the status table, and the pack version', () => {
    for (const country of data.countries) {
      const body = byUrl.get(`${COUNTRIES}${country.slug}/`)!.body;
      for (const row of ROWS) {
        expect(body, `${country.slug} is missing the row ${row.key}`).toContain(row.label);
      }
      expect(body).toContain(country.name);
      expect(body).toContain(country.version);
    }
  });

  it('says in words what the pack does not carry, rather than leaving it out', () => {
    for (const country of data.countries) {
      const body = byUrl.get(`${COUNTRIES}${country.slug}/`)!.body;
      const silences = [
        country.declarations.some((declaration) => declaration.deadline === null),
        country.declarations.some((declaration) => declaration.file.byHand),
        country.einvoicing === null || country.einvoicing.obligation === null,
        country.vatBalance.payable === null,
        country.vatBalance.receivable === null,
        country.bankStatementFormats.some((format) => !format.read),
        country.certification.reviewedBy === null,
      ];
      if (silences.some(Boolean)) expect(body).toContain('not');
    }
  });

  it('names the sources it was built from, with the day each was read', () => {
    for (const country of data.countries) {
      const body = byUrl.get(`${COUNTRIES}${country.slug}/`)!.body;
      for (const source of country.certification.sources) {
        expect(body).toContain(source.url);
        expect(body).toContain(source.consulted_on);
      }
    }
  });

  it('links to the pack it describes and to the guide for writing a new one', () => {
    for (const country of data.countries) {
      const body = byUrl.get(`${COUNTRIES}${country.slug}/`)!.body;
      expect(body).toContain(data.repository.dir(`packs/${country.slug}`));
      expect(body).toContain(data.repository.file('docs/packs.md'));
    }
  });
});

/**
 * Setting Ekwo up: a button on every country page, two ways in, one form.
 *
 * The form is read by the host when the site is deployed, so what is checked
 * is what the host needs to find in the prerendered page — its name, the
 * attribute that declares it, the trap for robots — and that it works without
 * a script: a plain POST to a page that exists.
 */
describe('setting Ekwo up', () => {
  const forms = pages.filter((page) => page.body.includes('<form'));
  /** Whether one `<tag …>` carries every attribute given, in whatever order React wrote them. */
  const hasTag = (body: string, tag: string, attributes: string[]): boolean =>
    [...body.matchAll(new RegExp(`<${tag}\\b[^>]*>`, 'g'))].some((match) =>
      attributes.every((attribute) => match[0].includes(attribute)),
    );

  it('puts the button at the head and at the foot of every country page, named after the country', () => {
    for (const country of data.countries) {
      const body = byUrl.get(`${COUNTRIES}${country.slug}/`)!.body;
      const label = fill(SOURCE.setup.action, { country: country.name });
      expect(body.split(`href="${setUpUrl(country)}"`).length - 1, country.slug).toBe(2);
      expect(body.split(label).length - 1, country.slug).toBeGreaterThanOrEqual(2);
    }
  });

  it('gives every country the command with its own code, on a flag the installer has', async () => {
    const init = await readFile(join(root, 'packages', 'cli', 'src', 'commands', 'init.ts'), 'utf8');
    expect(init).toMatch(/INIT_FLAGS = \[[\s\S]*'country'/);
    for (const country of data.countries) {
      const body = byUrl.get(setUpUrl(country))!.body;
      expect(body).toContain(`data-copy="${setUpCommand(data.repository.installCommand, country)}"`);
      expect(setUpCommand(data.repository.installCommand, country)).toMatch(/ --country [A-Z]{2}$/);
      expect(body).toContain('href="/docs/install/"');
    }
  });

  it('carries the form on every country\'s page, on the page of a country with no pack and on the page for any country, and nowhere else', () => {
    const expected = [
      ...data.countries.map(setUpUrl),
      ...data.waiting.map((country) => `${COUNTRIES}${country.slug}/`),
      SIGNUP,
    ].sort();
    expect(forms.map((page) => page.url).sort()).toEqual(expected);
  });

  it('declares the form to the host, with its trap for robots, and posts it without a script', () => {
    for (const page of forms) {
      const body = page.body;
      expect(body.match(/<form /g), page.url).toHaveLength(1);
      expect(body).toContain(`name="${SIGNUP_FORM}"`);
      expect(body).toContain('data-netlify="true"');
      expect(body).toContain(`data-netlify-honeypot="${HONEYPOT}"`);
      expect(hasTag(body, 'input', [`name="${HONEYPOT}"`])).toBe(true);
      expect(hasTag(body, 'input', ['type="hidden"', 'name="form-name"', `value="${SIGNUP_FORM}"`])).toBe(true);
      expect(body).toContain('method="POST"');
      expect(body).toContain(`action="${THANKS}"`);
      expect(byUrl.has(THANKS)).toBe(true);
    }
  });

  it('asks for an address and consent, and makes the rest optional', () => {
    for (const page of forms) {
      const body = page.body;
      expect(hasTag(body, 'input', ['type="email"', 'name="email"', 'required'])).toBe(true);
      expect(hasTag(body, 'input', ['type="checkbox"', 'name="consent"', 'required'])).toBe(true);
      expect(hasTag(body, 'input', ['name="company"', 'required'])).toBe(false);
      expect(hasTag(body, 'textarea', ['name="message"', 'required'])).toBe(false);
      for (const field of ['email', 'company', 'country', 'profile', 'message', 'consent', 'page']) {
        expect(body, `${page.url} lacks ${field}`).toContain(`name="${field}"`);
      }
      expect(body).toContain(SOURCE.setup.privacy);
      expect(body).not.toMatch(/€|\$\d|per month/i);
    }
  });

  it('sends the country of the page without asking, and asks for it where there is none', () => {
    for (const country of data.countries) {
      const body = byUrl.get(setUpUrl(country))!.body;
      expect(hasTag(body, 'input', ['type="hidden"', 'name="country"', `value="${country.country}"`])).toBe(true);
      expect(hasTag(body, 'select', ['name="country"'])).toBe(false);
    }
    const any = byUrl.get(SIGNUP)!.body;
    expect(hasTag(any, 'select', ['name="country"', 'required'])).toBe(true);
    for (const country of data.countries) expect(any).toContain(`value="${country.country}"`);
  });

  it('keeps the page a sent form lands on out of search engines and of the sitemap', () => {
    const thanks = byUrl.get(THANKS)!;
    expect(thanks.noindex).toBe(true);
    const template = '<html lang="en"><head><!--head--></head><body><!--body--></body></html>';
    expect(document(template, thanks)).toContain('<meta name="robots" content="noindex" />');
    const waiting = new Set(data.waiting.map((country) => `${COUNTRIES}${country.slug}/`));
    for (const page of pages) {
      if (page.url === THANKS || waiting.has(page.url)) continue;
      expect(document(template, page), page.url).not.toContain('noindex');
    }
    expect(sitemap(pages, 'https://site.example')).not.toContain(THANKS);
  });

  it('is reached from the header of every page and from the home page', () => {
    for (const page of pages) expect(page.body, page.url).toContain(`href="${SIGNUP}"`);
  });
});

describe('a country with no pack', () => {
  const taken = new Set(data.countries.map((country) => country.country));
  const waitingUrl = (slug: string): string => `${COUNTRIES}${slug}/`;
  const hasTag = (body: string, tag: string, attributes: string[]): boolean =>
    [...body.matchAll(new RegExp(`<${tag}\\b[^>]*>`, 'g'))].some((match) =>
      attributes.every((attribute) => match[0].includes(attribute)),
    );

  it('has a page for every country of the list that no pack claims, and for no other', () => {
    const expected = Object.keys(m49.regions).filter((code) => !taken.has(code)).sort();
    expect(data.waiting.map((country) => country.code).sort()).toEqual(expected);
    for (const country of data.waiting) {
      expect(slugs).not.toContain(country.slug);
      const page = byUrl.get(waitingUrl(country.slug));
      expect(page, `${country.code} has no page`).toBeDefined();
      // Named by the platform, never by this repository.
      expect(country.name).toBe(new Intl.DisplayNames([SOURCE.lang], { type: 'region' }).of(country.code));
      expect(page!.title).toBe(fill(SOURCE.waiting.title, { country: country.name }));
      const heading = fill(SOURCE.waiting.heading, { country: country.name }).replace(/&/g, '&amp;');
      expect(page!.body).toContain(heading);
    }
  });

  it('keeps those pages out of search engines and of the sitemap', () => {
    const template = '<html lang="en"><head><!--head--></head><body><!--body--></body></html>';
    const map = sitemap(pages, 'https://site.example');
    for (const country of data.waiting) {
      const page = byUrl.get(waitingUrl(country.slug))!;
      expect(page.noindex).toBe(true);
      expect(document(template, page)).toContain('<meta name="robots" content="noindex" />');
      expect(map).not.toContain(`<loc>https://site.example${page.url}</loc>`);
    }
  });

  it('is where the map and the list of countries lead', () => {
    const home = byUrl.get(HOME)!.body;
    const index = byUrl.get(COUNTRIES)!.body;
    const drawn = data.world.countries.filter((shape) => shape.pack === null && shape.waiting !== null);
    expect(drawn.length).toBeGreaterThan(data.countries.length);
    for (const shape of drawn) expect(home).toContain(`href="${shape.waiting}"`);
    for (const country of data.waiting) expect(index).toContain(`href="${waitingUrl(country.slug)}"`);
  });

  it('asks with the signup form of every other page, the country already on it', () => {
    const fields = (body: string): string[] =>
      [...new Set([...body.matchAll(/<(?:input|select|textarea)\b[^>]*name="([^"]+)"/g)].map((m) => m[1] as string))].sort();
    const signup = fields(byUrl.get(SIGNUP)!.body);
    for (const country of data.waiting) {
      const body = byUrl.get(waitingUrl(country.slug))!.body;
      expect(hasTag(body, 'form', [`name="${SIGNUP_FORM}"`, 'data-netlify="true"', `action="${THANKS}"`])).toBe(true);
      expect(hasTag(body, 'input', ['type="hidden"', 'name="country"', `value="${country.code}"`])).toBe(true);
      expect(hasTag(body, 'input', ['type="hidden"', 'name="page"', `value="${waitingUrl(country.slug)}"`])).toBe(true);
      // The host keeps one list of fields per form name: not one more, not one fewer.
      expect(fields(body)).toEqual(signup);
    }
  });

  it('says where it stands from the repository, and offers the two other ways forward', () => {
    let inProgress = 0;
    for (const country of data.waiting) {
      const body = byUrl.get(waitingUrl(country.slug))!.body;
      const status = body.slice(body.indexOf('data-waiting-status'));
      if (country.family === null) {
        expect(status).toContain(`>${SOURCE.waiting.notStarted}<`);
      } else {
        inProgress += 1;
        expect(country.family.members).toContain(country.code);
        expect(existsSync(join(root, country.family.file))).toBe(true);
        expect(status).toContain(`>${SOURCE.waiting.inProgress}<`);
        expect(status).toContain(country.family.file);
      }
      expect(body).toContain(`#adding-a-country-in-a-day`);
      expect(body).toContain(`packs/${country.slug}/`);
      expect(body).toMatch(/href="mailto:[^"?]+\?subject=/);
    }
    // A member of a shared manifest with no folder is the only `in progress`.
    const expected = data.waiting.filter((country) => country.family !== null).length;
    expect(inProgress).toBe(expected);
  });
});

describe('the links between pages', () => {
  // Linked to, deliberately not built: the host hands them to the application.
  const handedOver = new Set<string>(Object.values(HANDED_TO_THE_APPLICATION));

  it('hands over only addresses that are not pages of the site', () => {
    const built = new Set(pages.map((page) => page.url));
    for (const href of handedOver) expect(built.has(href), `${href} is a page here`).toBe(false);
    // The way in to the application is on every page.
    for (const page of pages) expect(page.body).toContain(`href="${HANDED_TO_THE_APPLICATION.login}"`);
  });

  it('point at pages that were built', () => {
    // A page may also link to a file the build writes beside it for a model.
    const built = new Set([
      ...pages.map((page) => page.url),
      ...LANGUAGES.flatMap((strings) => llmsFiles(data, strings).map((file) => `/${file.file}`)),
    ]);
    for (const page of pages) {
      // The query is read by the page, not served: `/compare/?a=…` is `/compare/`.
      for (const match of page.body.matchAll(/href="(\/[^"#?]*)"/g)) {
        const href = match[1] as string;
        if (handedOver.has(href)) continue;
        expect(built.has(href), `${page.url} links to ${href}, which is not built`).toBe(true);
      }
    }
  });
});

describe('the document a visitor receives', () => {
  const template =
    '<!doctype html>\n<html lang="en">\n<head><!--head--></head>\n<body><!--body--></body>\n</html>\n';

  it('declares its language, its title and its description, once each', () => {
    for (const page of pages) {
      const html = document(template, page);
      expect(html).toContain(`<html lang="${page.lang}">`);
      // The map draws a <title> per country, so the count is of the head's.
      const head = html.slice(0, html.indexOf('</head>'));
      expect(head.match(/<title>/g)?.length).toBe(1);
      expect(html).toContain('name="description"');
      expect(html).toContain('property="og:title"');
    }
  });

  it('carries scripts that parse', () => {
    // Both scripts are written inside template literals, where a `\n` meant
    // for a regular expression becomes a line break and the whole script — the
    // theme buttons with it — stops at a syntax error nobody sees.
    const html = document(template, pages[0]!);
    const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map((match) => match[1] as string);
    expect(scripts).toHaveLength(2);
    for (const code of scripts) expect(() => new Function(code)).not.toThrow();
  });

  it('refuses a template that has lost either slot, not just both', () => {
    expect(() => document('<html></html>', pages[0]!)).toThrow(/carries no <!--head-->/);
    expect(() => document('<head><!--head--></head>', pages[0]!)).toThrow(/carries no <!--body-->/);
  });

  it('puts the page in as text, not as a replacement pattern', () => {
    const awkward = { ...pages[0]!, title: "A $& and a $' and a $`" };
    expect(document(template, awkward)).toContain("<title>A $&amp; and a $' and a $`</title>");
  });

  /**
   * The site loads nothing from anywhere else and needs nothing to be read.
   *
   * One inline script exists and is the copy button; it is small, it is last,
   * and the page is complete without it. What is refused is a `src` — a page
   * about owning your own data must not tell a third party who read it.
   */
  it('fetches nothing from anywhere else', () => {
    for (const page of pages) {
      const html = document(template, page);
      expect(html).not.toContain('<script src');
      // An `xmlns` is a name and not an address; what is refused is fetching.
      expect(/(?:src|href)="http:/.test(html)).toBe(false);
      // Nothing is fetched from another origin: no stylesheet, no font, no
      // image, no script. The only absolute links are the ones a reader
      // follows on purpose, and those are anchors.
      expect(/<(?:link|img|script|iframe)[^>]+(?:src|href)="https?:/.test(html)).toBe(false);
      // Two: the one that stamps the theme before the first paint, and the
      // one at the end of the body that works the buttons.
      expect(html.match(/<script>/g)?.length ?? 0).toBeLessThanOrEqual(2);
    }
  });
});

describe('where the site is served from', () => {
  const TEMPLATE = '<html lang="en"><head><!--head--></head><body><!--body--></body></html>';

  it('claims no address when the build gives none', async () => {
    const pages = renderPages(await readSiteData());
    for (const page of pages) {
      const html = document(TEMPLATE, page);
      expect(html).not.toContain('rel="canonical"');
      expect(html).not.toContain('og:url');
    }
    expect(robots(undefined)).not.toContain('Sitemap:');
  });

  it('names every page at the address the build gives, once', async () => {
    const pages = renderPages(await readSiteData());
    const origin = siteOrigin(' https://site.example/ ');
    expect(origin).toBe('https://site.example');
    for (const page of pages) {
      const html = document(TEMPLATE, page, origin);
      expect(html).toContain(`<link rel="canonical" href="https://site.example${page.url}" />`);
      expect(html.match(/rel="canonical"/g)).toHaveLength(1);
    }
    const map = sitemap(pages, origin as string);
    const indexed = pages.filter((page) => page.noindex !== true);
    expect(map.match(/<loc>/g)).toHaveLength(indexed.length);
    for (const page of pages) {
      expect(map.includes(`<loc>https://site.example${page.url}</loc>`), page.url).toBe(page.noindex !== true);
    }
    expect(robots(origin)).toContain('Sitemap: https://site.example/sitemap.xml');
  });

  it('refuses an address that is not an origin, and treats an empty one as none', () => {
    expect(siteOrigin(undefined)).toBeUndefined();
    expect(siteOrigin('  ')).toBeUndefined();
    expect(() => siteOrigin('site.example')).toThrow(/SITE_URL/);
    expect(() => siteOrigin('https://site.example/path')).toThrow(/SITE_URL/);
  });
});

describe('a reader who asked for less motion', () => {
  it('is still shown the first word of the heading', async () => {
    const css = await readFile(join(repoRootDir(), 'apps/site/src/styles.css'), 'utf8');
    const reduced = css.slice(css.lastIndexOf('@media (prefers-reduced-motion: reduce)'));
    // Every turning word is taken out, and the first one is put back. The rule
    // that only did the first half left a heading that read "set free." alone.
    expect(reduced).toMatch(/\.hero-word\s*\{[^}]*display:\s*none/);
    expect(reduced).toMatch(/\.hero-word:first-child\s*\{[^}]*display:\s*block/);
  });
});

describe('an address this site does not have', () => {
  it('is handed to the application instead of answered with a 404, and shadows no page', async () => {
    const rules = (await readFile(join(repoRootDir(), 'apps/site/public/_redirects'), 'utf8'))
      .split('\n')
      .filter((line) => line.trim() !== '' && !line.startsWith('#'));
    expect(rules).toHaveLength(2);
    const [from, to, status] = (rules[rules.length - 1] as string).trim().split(/\s+/);
    expect(from).toBe('/*');
    expect(to).toMatch(/^https:\/\/[^/]+\/:splat$/);
    // No "!": a forced rule would replace the pages of the site themselves.
    expect(status).toBe('302');
  });

  it('sends the old page of a pair to the comparison, with one rule, before the last', async () => {
    const rules = (await readFile(join(repoRootDir(), 'apps/site/public/_redirects'), 'utf8'))
      .split('\n')
      .filter((line) => line.trim() !== '' && !line.startsWith('#'));
    const [from, to, status] = (rules[0] as string).trim().split(/\s+/);
    // A placeholder, so it holds for every pair there ever was or will be.
    expect(from).toBe(`${COMPARE}:pair`);
    expect(to).toBe(`${COMPARE}?pair=:pair`);
    expect(status).toBe('301');
    // It shadows nothing: no page is built under the comparison.
    expect(pages.filter((page) => page.url.startsWith(COMPARE) && page.url !== COMPARE)).toEqual([]);
  });
});


describe('the mark', () => {
  /** The midrib, held back from both tips. Two strokes at one weight is the whole drawing. */
  const MIDRIB = 'M8.2 15.8 15.8 8.2';

  it('is the leaf, in the header of every page and in the favicon, drawn the same way', async () => {
    for (const page of pages) {
      expect(page.body, `no mark in ${page.url}`).toContain(MIDRIB);
    }
    const favicon = await readFile(join(repoRootDir(), 'apps/site/public/favicon.svg'), 'utf8');
    expect(favicon).toContain(MIDRIB);
  });

  it('is never green: the leaf takes the cobalt accent on both grounds', async () => {
    const favicon = await readFile(join(repoRootDir(), 'apps/site/public/favicon.svg'), 'utf8');
    // The two accents of the default palette, and nothing else coloured.
    expect(favicon).toContain('#2f5fe0');
    expect(favicon).toContain('#7ea2ff');
    const colours = favicon.match(/#[0-9a-f]{3,8}/gi) ?? [];
    expect(new Set(colours)).toEqual(new Set(['#2f5fe0', '#7ea2ff']));
    // In the pages the mark inherits, so it carries no colour of its own.
    const source = await readFile(join(repoRootDir(), 'apps/site/src/pages/Logo.tsx'), 'utf8');
    expect(source).not.toMatch(/#[0-9a-f]{3,8}/i);
    expect(source).toContain('currentColor');
  });
});

describe('a reader who has chosen nothing', () => {
  it('is shown cobalt, because the bare set is cobalt and gold is reached by attribute', async () => {
    const css = await readFile(join(repoRootDir(), 'apps/site/src/styles.css'), 'utf8');
    const base = css.slice(css.indexOf('@theme static'), css.indexOf("[data-palette='cobalt'][data-theme='night']"));
    expect(base).toContain('--color-brand: #2f5fe0');
    expect(css).toContain("[data-palette='gold']:not([data-theme='night'])");
    const source = await readFile(join(repoRootDir(), 'apps/site/src/render.tsx'), 'utf8');
    expect(source).toContain("p === 'gold' ? 'gold' : 'cobalt'");
  });

  it('follows their system, because nothing is stamped until they pick a side', async () => {
    const source = await readFile(join(repoRootDir(), 'apps/site/src/render.tsx'), 'utf8');
    const boot = source.slice(source.indexOf('const THEME_SCRIPT'), source.indexOf('`.trim();'));
    // The one blocking script sets the palette always and the theme never —
    // stamping a value at load would freeze the page on whatever was true then.
    expect(boot).toContain("d.setAttribute('data-js', '')");
    expect(boot).toContain("if (t === 'night' || t === 'day') d.setAttribute('data-theme', t)");
    expect(boot).not.toContain('prefers-color-scheme');
  });

  it('still gets the two buttons, which key off data-js and not off a stamped theme', async () => {
    const css = await readFile(join(repoRootDir(), 'apps/site/src/styles.css'), 'utf8');
    expect(css).toContain(':root[data-js] [data-controls]');
    expect(css).not.toContain(':root[data-theme] [data-controls]');
  });
});

/**
 * What Ekwo says it is.
 *
 * Open source data infrastructure — schemas, rules as data, tools — for
 * businesses and their accountants, and never an accounting service. In some
 * countries keeping the books of others or giving tax advice is a regulated
 * profession, so the site that presents the software must not read as an offer
 * of either, and the page that says so is one click from every page.
 */
describe('what Ekwo says it is', () => {
  const DISCLAIMER = '/disclaimer/';

  it('publishes the disclaimer as a page of its own, from DISCLAIMER.md', () => {
    const article = data.docs.find((entry) => entry.source === 'DISCLAIMER.md');
    expect(article?.url).toBe(DISCLAIMER);
    expect(byUrl.get(DISCLAIMER), `${DISCLAIMER} was not built`).toBeDefined();
  });

  it('links to it from the foot of every page, on this site rather than on GitHub', () => {
    for (const page of pages) {
      const footer = /<footer[\s\S]*<\/footer>/.exec(page.body)?.[0] ?? '';
      expect(footer, `${page.url} has no link to the disclaimer`).toContain(`href="${DISCLAIMER}"`);
      expect(footer).not.toContain('DISCLAIMER.md');
      expect(footer, `${page.url} does not say who stands behind the name`).toContain(data.repository.legal);
    }
    // One address, the one the disclaimer gives.
    expect(data.repository.legal).toMatch(/contact@ekwo\.ai$/);
  });

  it('says what the project is not, and what the user stays responsible for', async () => {
    const text = await readFile(join(root, 'DISCLAIMER.md'), 'utf8');
    expect(text).toMatch(/open source data infrastructure/);
    expect(text).toMatch(/not an accounting firm/);
    for (const heading of [
      'What Ekwo does not provide',
      'Your books, your filings, your deadlines',
      'Software you can change',
      'No warranty, no liability',
      'European Union',
      'United Kingdom',
      'United States',
      'OHADA member States',
      'Names and trademarks',
    ]) {
      expect(text, `DISCLAIMER.md has no section "${heading}"`).toContain(heading);
    }
    // The dated version is what tells a reader which text applied when.
    expect(text).toMatch(/Version \d+\.\d+ — \d{1,2} [A-Z][a-z]+ \d{4}/);
  });

  it('never presents itself as an accounting service', () => {
    // The pages the site writes itself. The decisions and the changelog are
    // records of what was said at the time, and are not rewritten.
    const own = pages.filter((page) => !page.url.includes(DOCS_INDEX) && !page.url.endsWith('/changes/'));
    expect(own.length).toBeGreaterThan(slugs.length);
    for (const phrase of [
      /independent accounting, in every country/i,
      /answerable when a return is late/i,
      /AI does the bookkeeping/i,
      /\bcompliance, in the open\b/i,
    ]) {
      for (const page of own) {
        expect(page.body, `${page.url} says ${phrase}`).not.toMatch(phrase);
      }
    }
    expect(byUrl.get(HOME)!.body).toContain('data infrastructure');
  });
});
