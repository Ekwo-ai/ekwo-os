/**
 * `/countries/` — the index the country pages hang under.
 *
 * It exists because the country pages moved out of the root to leave the
 * two-letter prefixes free for languages, and a directory that is a path
 * segment should answer when somebody trims the address bar back to it.
 *
 * It is the menu and nothing else: every pack, its status, and the invitation
 * for the rest of the world. The map is on the home page, where it is the
 * argument; here a reader already knows what they are looking for.
 */

import type { ReactNode } from 'react';
import type { SiteData } from '../data.js';
import type { Strings } from '../strings/index.js';
import { Eyebrow, Footer, Masthead, Out, StatusPill } from './ui.js';

export function Countries({ data, strings }: { data: SiteData; strings: Strings }): ReactNode {
  const { countries, repository } = data;
  const s = strings.countries;
  return (
    <>
      <Masthead measure="reading" strings={strings} data={data} current="countries" />
      <main className="mx-auto max-w-reading px-5 py-16">
        <Eyebrow>{s.eyebrow}</Eyebrow>
        <h1 className="mt-4 text-[clamp(2.25rem,1.7rem+2.6vw,3.25rem)]">{s.title}</h1>
        <p className="mt-5 text-lg text-ink-soft">{s.lead}</p>

        <ul className="mt-10 divide-y divide-line border-y border-line">
          {countries.map((country) => (
            <li key={country.slug}>
              <a
                href={`/countries/${country.slug}/`}
                className="flex items-center gap-3 py-3.5 no-underline transition-colors duration-150 hover:text-brand-deep"
              >
                <span className="font-mono text-sm text-ink-faint">{country.slug}</span>
                <span className="text-ink">{country.name}</span>
                <span className="flex-1" />
                <StatusPill status={country.certification.status} />
              </a>
            </li>
          ))}
        </ul>

        <p className="mt-6 text-sm text-ink-faint">
          {strings.home.network.openInvite}{' '}
          <Out href={repository.file('docs/packs.md')}>{strings.home.network.guide}</Out>
        </p>

        <p className="mt-8 text-sm">
          <a href="/compare/">{strings.os.compare}</a>
        </p>
      </main>
      <Footer repository={repository} measure="reading" strings={strings} />
    </>
  );
}
