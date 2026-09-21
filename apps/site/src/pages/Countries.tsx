/**
 * `/countries/` — the index the country pages hang under.
 *
 * It exists because the country pages moved out of the root to leave the
 * two-letter prefixes free for languages, and a directory that is a path
 * segment should answer when somebody trims the address bar back to it.
 *
 * It is the menu and nothing else: every pack, its status, every other country
 * folded under one line and leading to its page, and the invitation
 * for the rest of the world — by region, with a jump to each and a field that
 * narrows the list, because the menu is written to hold two hundred. The map is on the home page, where it is the
 * argument; here a reader already knows what they are looking for.
 */

import type { ReactNode } from 'react';
import { countryUrl, type SiteData, type WaitingCountry } from '../data.js';
import type { Strings } from '../strings/index.js';
import { RegionList } from './Regions.js';
import { Eyebrow, Footer, Masthead, Out } from './ui.js';

export function Countries({ data, strings }: { data: SiteData; strings: Strings }): ReactNode {
  const { repository } = data;
  const s = strings.countries;
  return (
    <>
      <Masthead measure="page" strings={strings} data={data} current="countries" />
      <main className="mx-auto max-w-page px-5 py-16">
        <Eyebrow>{s.eyebrow}</Eyebrow>
        <h1 className="mt-4 max-w-reading text-[clamp(2.25rem,1.7rem+2.6vw,3.25rem)]">{s.title}</h1>
        <p className="mt-5 max-w-reading text-lg text-ink-soft">{s.lead}</p>

        <div className="mt-10">
          <RegionList regions={data.regions} strings={strings} />
        </div>

        <OtherCountries data={data} strings={strings} />

        <p className="mt-6 text-sm text-ink-faint">
          {strings.home.network.openInvite}{' '}
          <Out href={repository.file('docs/packs.md')}>{strings.home.network.guide}</Out>
        </p>

        <p className="mt-8 flex flex-wrap gap-x-6 gap-y-2 text-sm">
          <a href="/compare/">{strings.os.compare}</a>
          <a href="/multi-country/">{strings.multi.countriesLink}</a>
        </p>
      </main>
      <Footer repository={repository} measure="page" strings={strings} />
    </>
  );
}

/**
 * Every country with no pack, by region, folded: a reader looking for theirs
 * finds it — the browser's own find opens the fold — and the menu above stays
 * the packs.
 */
function OtherCountries({ data, strings }: { data: SiteData; strings: Strings }): ReactNode {
  const s = strings.waiting;
  if (data.waiting.length === 0) return null;
  const names = new Intl.DisplayNames([strings.lang], { type: 'region' });
  const byRegion = new Map<string, WaitingCountry[]>();
  for (const country of data.waiting) {
    byRegion.set(country.region, [...(byRegion.get(country.region) ?? []), country]);
  }
  const regions = [...byRegion]
    .map(([code, countries]) => ({ code, name: code === '' ? strings.regions.unplaced : (names.of(code) ?? code), countries }))
    .sort((a, b) => (a.code === '' ? 1 : b.code === '' ? -1 : a.name.localeCompare(b.name, strings.lang)));

  return (
    <details className="mt-10 rounded-lg border border-line bg-paper px-5 py-4" data-waiting-list>
      <summary className="cursor-pointer text-ink">
        <span className="font-medium">{s.listTitle}</span>{' '}
        <span className="font-mono text-sm text-ink-faint">{data.waiting.length}</span>
      </summary>
      <p className="mt-3 max-w-reading text-sm text-ink-faint">{s.listLead}</p>
      <dl className="mt-3 divide-y divide-line">
        {regions.map((region) => (
          <div key={region.code} className="grid gap-1 py-3 sm:grid-cols-[10rem_1fr] sm:gap-4">
            <dt className="text-sm text-ink">{region.name}</dt>
            <dd className="text-sm leading-relaxed text-ink-soft">
              {region.countries.map((country, index) => (
                <span key={country.code}>
                  {index > 0 ? ', ' : ''}
                  <a href={countryUrl(country.slug)}>{country.name}</a>
                </span>
              ))}
            </dd>
          </div>
        ))}
      </dl>
    </details>
  );
}
