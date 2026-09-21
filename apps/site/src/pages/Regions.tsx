/**
 * The countries, by region: the one way this site lists them.
 *
 * A list of six countries reads as a column. A list of two hundred does not,
 * and the project is written for two hundred: so every place that lists the
 * packs — the index, the core page, the home page — lists them under the
 * region the United Nations places them in (`regionsOf()` in `data.ts`), with
 * a count beside each region and an anchor on it.
 *
 * Two shapes, one grouping:
 *
 * - `RegionList` is the menu itself: every pack with its code, its name and
 *   its status, two columns where there is room, a jump link per region and a
 *   field that narrows the list. The field is the inline script's; without it
 *   the list is whole and the browser's own find searches it.
 * - `RegionSummary` is the list in a sentence per region, every name a link,
 *   for a page where the countries are one argument among others.
 *
 * No country and no region is named here. The names are the packs' and the
 * platform's; the count is counted.
 */

import type { ReactNode } from 'react';
import type { PackDescription } from '../../../../packages/cli/src/index.js';
import type { Region } from '../data.js';
import type { Strings } from '../strings/index.js';
import { Filter, StatusPill } from './ui.js';

/** The anchor of a region, on `/countries/` and on any page that lists it. */
export function regionAnchor(region: Region): string {
  return `region-${region.code === '' ? 'other' : region.code}`;
}

/** What a region is called: the platform's name, or the strings' for the unplaced. */
export function regionName(region: Region, strings: Strings): string {
  return region.code === '' ? strings.regions.unplaced : region.name;
}

/** Everything a reader might type to find a country, lowercase, in one attribute. */
function searchText(country: PackDescription, region: string): string {
  return [country.slug, country.country, country.name, ...Object.values(country.nameI18n), region, country.currency]
    .join(' ')
    .toLowerCase();
}

/** The jump links: one per region, with its count. */
export function RegionJumps({ regions, strings }: { regions: Region[]; strings: Strings }): ReactNode {
  return (
    <nav aria-label={strings.regions.label} className="flex flex-wrap gap-2">
      {regions.map((region) => (
        <a
          key={region.code}
          href={`#${regionAnchor(region)}`}
          className="inline-flex items-center gap-2 rounded-pill border border-line bg-paper px-3 py-1.5 text-sm text-ink no-underline transition-colors duration-150 hover:border-brand hover:text-brand-deep"
        >
          {regionName(region, strings)}
          <span className="font-mono text-xs text-ink-faint">{region.countries.length}</span>
        </a>
      ))}
    </nav>
  );
}

/** The menu of countries, by region, with a field to narrow it. */
export function RegionList({
  regions,
  strings,
  heading = 'h2',
}: {
  regions: Region[];
  strings: Strings;
  /** The level the region names take on the page they are put in. */
  heading?: 'h2' | 'h3';
}): ReactNode {
  const Heading = heading;
  return (
    <div data-filter-scope>
      <RegionJumps regions={regions} strings={strings} />
      <div className="mt-5 max-w-sm">
        <Filter label={strings.regions.search} />
      </div>
      {regions.map((region) => {
        const name = regionName(region, strings);
        return (
          <section
            key={region.code}
            id={regionAnchor(region)}
            data-filter-group
            className="mt-10 scroll-mt-24"
          >
            <Heading className="flex items-baseline gap-3 text-xl">
              {name}
              <span className="font-mono text-xs font-normal text-ink-faint">
                {region.countries.length}
              </span>
            </Heading>
            <ul className="mt-3 grid border-t border-line sm:grid-cols-2 sm:gap-x-8 lg:grid-cols-3">
              {region.countries.map((country) => (
                <li key={country.slug} data-filter-item data-search={searchText(country, name)} className="border-b border-line">
                  <a
                    href={`/countries/${country.slug}/`}
                    className="flex items-center gap-3 py-3 no-underline transition-colors duration-150 hover:text-brand-deep"
                  >
                    <span className="font-mono text-sm text-ink-faint">{country.slug}</span>
                    <span className="min-w-0 truncate text-ink">{country.name}</span>
                    <span className="flex-1" />
                    <StatusPill status={country.certification.status} />
                  </a>
                </li>
              ))}
            </ul>
          </section>
        );
      })}
      <p data-filter-empty hidden className="mt-10 text-ink-faint">
        {strings.regions.noMatch}
      </p>
    </div>
  );
}

/** Every country, one line per region, each name a link to its page. */
export function RegionSummary({ regions, strings }: { regions: Region[]; strings: Strings }): ReactNode {
  return (
    <dl className="divide-y divide-line">
      {regions.map((region) => (
        <div key={region.code} className="grid gap-1 py-3 sm:grid-cols-[10rem_1fr] sm:gap-4">
          <dt className="text-sm">
            <a href={`/countries/#${regionAnchor(region)}`} className="text-ink no-underline hover:text-brand-deep">
              {regionName(region, strings)}
            </a>{' '}
            <span className="font-mono text-xs text-ink-faint">{region.countries.length}</span>
          </dt>
          <dd className="text-sm leading-relaxed text-ink-soft">
            {region.countries.map((country, index) => (
              <span key={country.slug}>
                {index > 0 ? ', ' : ''}
                <a href={`/countries/${country.slug}/`}>{country.name}</a>
              </span>
            ))}
          </dd>
        </div>
      ))}
    </dl>
  );
}
