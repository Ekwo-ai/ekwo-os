import { gzipSync } from 'node:zlib';
import { describe, expect, it } from 'vitest';
import { packsDir, repoRootDir, type PackDescription } from '../../../packages/cli/src/index.js';
import { familiesOf, readSiteData, regionsOf, waitingOf, worldOf, type SiteData } from '../src/data.js';
import { renderPages, type RenderedPage } from '../src/render.js';
import { LANGUAGES, SOURCE } from '../src/strings/index.js';
import { PICKERS } from '../src/pages/Compare.js';
import m49 from '../src/data/regions.json' with { type: 'json' };

/**
 * The site at fifty countries, and at two hundred.
 *
 * `packs/` holds a handful today; the site is written for the rest of the
 * world, and this is where that is checked rather than hoped. The packs here
 * are made up, in the test and nowhere else: each is a real description with
 * its code, its slug and its name swapped for those of a country that has no
 * pack yet, taken from the UN list the site groups by. Nothing is written to
 * `packs/`, and no country is named in this file.
 *
 * What is held: the number of pages grows by two per country — its page and
 * the page that sets it up — in place of the one a country with no pack has,
 * and never by one per pair; the comparison is one page whose weight grows by one column per
 * country; every list of countries stays grouped by region and links to every
 * pack.
 */

const data = await readSiteData();
const families = await familiesOf(packsDir(repoRootDir()));

/** `count` packs: the real ones, then made-up ones for countries that have none. */
function fakePacks(count: number): PackDescription[] {
  const taken = new Set(data.countries.map((country) => country.country));
  const names = new Intl.DisplayNames([SOURCE.lang], { type: 'region' });
  const free = Object.keys(m49.regions).filter((code) => !taken.has(code));
  const made = free.slice(0, Math.max(0, count - data.countries.length)).map((code, index) => {
    const model = data.countries[index % data.countries.length] as PackDescription;
    const name = names.of(code) ?? code;
    return { ...model, country: code, slug: code.toLowerCase(), name, nameI18n: { [SOURCE.lang]: name } };
  });
  return [...data.countries, ...made].slice(0, count);
}

function siteWith(count: number): { site: SiteData; pages: RenderedPage[] } {
  const countries = fakePacks(count);
  const site = {
    ...data,
    countries,
    regions: regionsOf(countries, SOURCE.lang),
    world: worldOf(countries, SOURCE.lang),
    waiting: waitingOf(countries, families, SOURCE.lang),
  };
  return { site, pages: renderPages(site) };
}

const bytes = (page: RenderedPage | undefined): number => Buffer.byteLength(page?.body ?? '');
const gzipped = (page: RenderedPage | undefined): number => gzipSync(page?.body ?? '').length;

describe('the site at fifty and at two hundred countries', () => {
  const sizes = [50, 200].map((count) => ({ count, ...siteWith(count) }));

  it('has one page per country, and never one per pair', () => {
    for (const { count, site, pages } of sizes) {
      expect(site.countries).toHaveLength(count);
      // Two per pack, and one for every country of the list without one: the
      // world is a fixed number of pages, whatever the packs. A pack may be for
      // a territory the M49 list does not carry (Taiwan): it has its pages and
      // leaves no country of the list without one.
      const world = Object.keys(m49.regions).length;
      const listed = site.countries.filter((country) => country.country in m49.regions).length;
      expect(site.waiting).toHaveLength(world - listed);
      expect(pages).toHaveLength(LANGUAGES.length * (2 * count + (world - listed) + data.docs.length + 9));
      expect(new Set(pages.map((page) => page.url)).size).toBe(pages.length);
      expect(pages.filter((page) => page.url.startsWith('/compare/'))).toHaveLength(1);
    }
  });

  it('offers every country in both pickers of the one comparison', () => {
    for (const { site, pages } of sizes) {
      const body = pages.find((page) => page.url === '/compare/')!.body;
      for (const picker of PICKERS) {
        const select = new RegExp(`<select id="${picker}"[^>]*>([\\s\\S]*?)</select>`).exec(body)![1]!;
        expect(select.split('<option ').length - 1).toBe(site.countries.length);
        expect(select.split('<optgroup ').length - 1).toBe(site.regions.length);
      }
    }
  });

  it('grows the comparison by one column per country, a few kilobytes each', () => {
    const [fifty, twoHundred] = sizes.map(({ pages }) => pages.find((page) => page.url === '/compare/'));
    const perCountry = (bytes(twoHundred) - bytes(fifty)) / 150;
    const perCountryGzipped = (gzipped(twoHundred) - gzipped(fifty)) / 150;
    // Linear, not quadratic: the page at two hundred is about four times the
    // page at fifty, never sixteen.
    expect(bytes(twoHundred) / bytes(fifty)).toBeLessThan(4.5);
    expect(perCountry).toBeLessThan(12_000);
    expect(perCountryGzipped).toBeLessThan(1_500);
  });

  it('lists every country, by region, on the index and from the home page', () => {
    for (const { site, pages } of sizes) {
      const index = pages.find((page) => page.url === '/countries/')!.body;
      const home = pages.find((page) => page.url === '/')!.body;
      for (const country of site.countries) {
        expect(index).toContain(`href="/countries/${country.slug}/"`);
        expect(home).toContain(`href="/countries/${country.slug}/"`);
      }
      const sections = index.split('data-filter-group').length - 1;
      expect(sections).toBe(site.regions.length);
      expect(site.regions.reduce((sum, region) => sum + region.countries.length, 0)).toBe(
        site.countries.length,
      );
    }
  });

  it('keeps the index and the home page far lighter than the comparison', () => {
    const { pages } = sizes[1]!;
    const compare = bytes(pages.find((page) => page.url === '/compare/'));
    for (const url of ['/', '/countries/', '/os/']) {
      expect(bytes(pages.find((page) => page.url === url))).toBeLessThan(compare);
    }
  });
});
