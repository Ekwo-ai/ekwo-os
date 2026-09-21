import { describe, expect, it } from 'vitest';
import { readSiteData } from '../src/data.js';
import { AI_CRAWLERS, document, renderPages, robots, sitemap } from '../src/render.js';
import { countryDescription, countryName, countrySummary, jsonLd, type Node } from '../src/seo.js';
import { LANGUAGES, SOURCE, prefixOf } from '../src/strings/index.js';

/**
 * What a page says about itself to a machine: its title and description, the
 * same page in every language, the robots it lets in and the schema.org graph
 * it carries.
 *
 * Like `site.test.ts`, every expectation comes from the data — the packs, the
 * documentation, the manifest — and none from a country somebody remembered.
 */

const data = await readSiteData();
const pages = renderPages(data);
const indexed = pages.filter((page) => page.noindex !== true);
const ORIGIN = 'https://site.example';
const TEMPLATE = '<html lang="en"><head><!--head--></head><body><!--body--></body></html>';

/** The graph a page carries, parsed, or null when it carries none. */
function graphIn(html: string): Node[] | null {
  const scripts = [...html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)];
  if (scripts.length === 0) return null;
  expect(scripts).toHaveLength(1);
  const parsed = JSON.parse(scripts[0]![1] as string) as { '@context': string; '@graph': Node[] };
  expect(parsed['@context']).toBe('https://schema.org');
  return parsed['@graph'];
}

const ofType = (graph: Node[], type: string): Node[] =>
  graph.filter((node) => node['@type'] === type || (Array.isArray(node['@type']) && node['@type'].includes(type)));

describe('the title and description of every page', () => {
  it('is unique to the page, among the pages a search engine sees', () => {
    for (const key of ['title', 'description'] as const) {
      const seen = new Map<string, string>();
      for (const page of indexed) {
        expect(seen.get(page[key]), `${page.url} shares its ${key} with ${seen.get(page[key])}`).toBeUndefined();
        seen.set(page[key], page.url);
      }
    }
  });

  it('says something, and fits a result line', () => {
    for (const page of indexed) {
      expect(page.title.length, page.url).toBeGreaterThan(10);
      expect(page.title.length, `${page.url}: ${page.title}`).toBeLessThanOrEqual(70);
      expect(page.description.length, page.url).toBeGreaterThanOrEqual(50);
      expect(page.description, page.url).not.toMatch(/\{\w+\}/);
      expect(page.title, page.url).not.toMatch(/\{\w+\}/);
    }
  });

  it('names each country in the language of the page, with what its pack carries', () => {
    for (const strings of LANGUAGES) {
      for (const country of data.countries) {
        const page = pages.find((p) => p.url === `/${prefixOf(strings)}countries/${country.slug}/`)!;
        const name = countryName(country, strings.lang);
        expect(page.title).toContain(name);
        expect(page.description).toBe(countryDescription(country, strings));
        expect(page.description).toContain(country.currency);
        for (const declaration of country.declarations) expect(page.description).toContain(declaration.name);
        // The sentence the page opens with is on the page, where a reader and a model both find it.
        expect(page.body).toContain(countrySummary(country, strings).replace(/&/g, '&amp;').replace(/</g, '&lt;'));
      }
    }
  });

  it('never calls Ekwo a service', () => {
    // Ekwo is software a business installs; the words that would make it a
    // regulated profession are kept out of every page and every head.
    for (const page of pages) {
      const text = `${page.title} ${page.description} ${page.body}`.toLowerCase();
      expect(text, page.url).not.toContain('accounting service');
      expect(text, page.url).not.toContain('bookkeeping service');
    }
  });
});

describe('the same page in every language', () => {
  it('is named by each language and a default, once the site has an address', () => {
    for (const page of pages) {
      const html = document(TEMPLATE, page, ORIGIN);
      for (const strings of LANGUAGES) {
        expect(html).toContain(
          `<link rel="alternate" hreflang="${strings.lang}" href="${ORIGIN}/${prefixOf(strings)}${page.route.slice(1)}" />`,
        );
      }
      expect(html).toContain(`hreflang="x-default" href="${ORIGIN}/${prefixOf(SOURCE)}${page.route.slice(1)}"`);
      expect(document(TEMPLATE, page)).not.toContain('hreflang');
    }
  });
});

describe('the structured data', () => {
  it('is one graph per indexed page, only once the site has an address, every reference resolved', () => {
    for (const page of pages) {
      expect(graphIn(document(TEMPLATE, page)), page.url).toBeNull();
      const graph = graphIn(document(TEMPLATE, page, ORIGIN));
      if (page.noindex === true) {
        expect(graph, page.url).toBeNull();
        continue;
      }
      expect(graph, page.url).not.toBeNull();
      const ids = new Set(graph!.map((node) => node['@id']));
      for (const node of graph!) {
        expect(node['@type'], page.url).toBeDefined();
        expect(String(node['@id']).startsWith(ORIGIN), page.url).toBe(true);
      }
      // A reference is an object with nothing but an `@id`; each points at a node of the graph.
      const refs = JSON.stringify(graph).matchAll(/\{"@id":"([^"]+)"\}/g);
      for (const ref of refs) expect(ids.has(ref[1]), `${page.url} refers to ${ref[1]}`).toBe(true);
      expect(ofType(graph!, 'Organization')).toHaveLength(1);
      expect(ofType(graph!, 'WebSite')).toHaveLength(1);
      const webpage = ofType(graph!, 'WebPage');
      expect(webpage).toHaveLength(1);
      expect(webpage[0]!['url']).toBe(ORIGIN + page.url);
      expect(webpage[0]!['name']).toBe(page.title);
    }
  });

  it('describes the software on the home page: free, its licence, its source', () => {
    for (const strings of LANGUAGES) {
      const home = pages.find((page) => page.url === `/${prefixOf(strings)}`)!;
      const graph = graphIn(document(TEMPLATE, home, ORIGIN))!;
      const [app] = ofType(graph, 'SoftwareApplication');
      expect(app).toBeDefined();
      expect(app!['isAccessibleForFree']).toBe(true);
      expect(app!['license']).toBe(`https://spdx.org/licenses/${data.repository.spdx}.html`);
      expect(app!['applicationCategory']).toBe('BusinessApplication');
      expect(app!['operatingSystem']).toBeTruthy();
      expect(String(app!['description'])).toContain(String(data.countries.length));
      const [source] = ofType(graph, 'SoftwareSourceCode');
      expect(source!['codeRepository']).toBe(data.repository.url);
      expect(ofType(graph, 'Organization')[0]!['sameAs']).toContain(data.repository.url);
    }
  });

  it('makes each country pack a dataset, from its pack and nothing else', () => {
    for (const strings of LANGUAGES) {
      for (const country of data.countries) {
        const page = pages.find((p) => p.url === `/${prefixOf(strings)}countries/${country.slug}/`)!;
        const graph = graphIn(document(TEMPLATE, page, ORIGIN))!;
        const [set] = ofType(graph, 'Dataset');
        expect(set, country.slug).toBeDefined();
        expect(set!['version']).toBe(country.version);
        expect(set!['description']).toBe(countrySummary(country, strings));
        expect((set!['spatialCoverage'] as Node)['identifier']).toBe(country.country);
        expect(set!['citation']).toHaveLength(country.certification.sources.length);
        expect((set!['citation'] as Node[]).map((c) => c['url'])).toEqual(
          country.certification.sources.map((source) => source.url),
        );
        const trail = ofType(graph, 'BreadcrumbList')[0]!['itemListElement'] as Node[];
        expect(trail.at(-1)!['item']).toBe(ORIGIN + page.url);
      }
    }
  });

  it('makes each article of the documentation a technical article, sourced to its file', () => {
    for (const article of data.docs) {
      const page = pages.find((p) => p.url === article.url)!;
      const [tech] = ofType(graphIn(document(TEMPLATE, page, ORIGIN))!, 'TechArticle');
      expect(tech!['headline']).toBe(page.title);
      expect(tech!['isBasedOn']).toBe(data.repository.file(article.source));
    }
  });

  it('carries no FAQ, since the site has none', () => {
    for (const page of indexed) {
      expect(ofType(graphIn(document(TEMPLATE, page, ORIGIN))!, 'FAQPage'), page.url).toHaveLength(0);
    }
  });

  it('cannot be closed early by a string of the data', () => {
    const script = jsonLd([{ '@type': 'Thing', name: '</script><script>alert(1)</script>' }]);
    expect(script.match(/<\/script>/g)).toHaveLength(1);
    expect(JSON.parse(script.replace(/^<script[^>]*>|<\/script>$/g, ''))['@graph'][0].name).toBe(
      '</script><script>alert(1)</script>',
    );
  });
});

describe('what the crawlers are told', () => {
  it('lets every crawler in, and names the assistants’ crawlers so a later rule cannot shut them out', () => {
    const text = robots(ORIGIN);
    expect(text).not.toMatch(/Disallow:\s*\S/);
    for (const agent of AI_CRAWLERS) expect(text).toContain(`User-agent: ${agent}\n`);
    // The named group ends on its rule, as a group must.
    const group = text.slice(text.indexOf(`User-agent: ${AI_CRAWLERS[0]}`));
    expect(group).toMatch(new RegExp(`User-agent: ${AI_CRAWLERS.at(-1)}\\nAllow: /`));
  });

  it('lists every page a search engine may show, the country pages and the docs among them', () => {
    const map = sitemap(pages, ORIGIN);
    for (const page of indexed) expect(map).toContain(`<loc>${ORIGIN}${page.url}</loc>`);
    for (const country of data.countries) expect(map).toContain(`${ORIGIN}/countries/${country.slug}/`);
  });

  it('names the summary for models only when the build found it', () => {
    const page = indexed[0]!;
    expect(document(TEMPLATE, page, ORIGIN)).not.toContain('/llms.txt');
    expect(document(TEMPLATE, page, ORIGIN, { llmsTxt: true })).toContain(
      '<link rel="alternate" type="text/markdown" href="/llms.txt" title="llms.txt" />',
    );
  });
});
