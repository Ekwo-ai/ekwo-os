/**
 * `/countries/` — the index the country pages hang under.
 *
 * It exists because the country pages moved out of the root to leave the
 * two-letter prefixes free for languages, and a directory that is a path
 * segment should answer when somebody trims the address bar back to it.
 *
 * It is the menu and nothing else: every pack, its status, and the invitation
 * for the rest of the world — by region, with a jump to each and a field that
 * narrows the list, because the menu is written to hold two hundred. The map is on the home page, where it is the
 * argument; here a reader already knows what they are looking for.
 */

import type { ReactNode } from 'react';
import type { SiteData } from '../data.js';
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

        <p className="mt-6 text-sm text-ink-faint">
          {strings.home.network.openInvite}{' '}
          <Out href={repository.file('docs/packs.md')}>{strings.home.network.guide}</Out>
        </p>

        <p className="mt-8 text-sm">
          <a href="/compare/">{strings.os.compare}</a>
        </p>
      </main>
      <Footer repository={repository} measure="page" strings={strings} />
    </>
  );
}
