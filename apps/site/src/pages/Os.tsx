/**
 * `/os/` — the core somebody installs.
 *
 * This was the home page until the home page became Ekwo itself. It keeps what
 * it was: one sentence, one command, and the countries, with nothing stacked
 * around them. A reader who arrives here has already decided to look at the
 * software, so the page's whole job is to be out of the way.
 *
 * The sentence is the first line of `README.md`, read at build time rather than
 * copied, so the page and the repository cannot come to say different things.
 */

import type { ReactNode } from 'react';
import type { SiteData } from '../data.js';
import type { Strings } from '../strings/index.js';
import { RegionSummary } from './Regions.js';
import { Command, Eyebrow, Footer, Masthead, Out } from './ui.js';

export function Os({ data, strings }: { data: SiteData; strings: Strings }): ReactNode {
  const { repository } = data;
  const s = strings.os;
  return (
    <>
      <Masthead measure="reading" strings={strings} data={data} current="os" />
      <main className="mx-auto max-w-reading px-5 pt-16 pb-4 sm:pt-24">
        <Eyebrow>{s.eyebrow}</Eyebrow>
        <h1 className="mt-4 text-[clamp(2.5rem,1.8rem+3vw,3.75rem)]">Ekwo&nbsp;OS</h1>

        <p
          className="mt-6 text-lg leading-relaxed text-ink-soft"
          dangerouslySetInnerHTML={{ __html: data.positioningHtml }}
        />

        <div className="mt-9">
          <Command>{repository.installCommand}</Command>
        </div>

        <nav aria-label="Project" className="mt-6 flex flex-wrap gap-x-6 gap-y-2 text-sm">
          <Out href={repository.url}>{s.source}</Out>
          <Out href={repository.packageUrl}>{s.npm}</Out>
          <a href="/compare/">{s.compare}</a>
        </nav>

        {/* The masthead links here, so the anchor clears the sticky header. */}
        <nav aria-labelledby="countries-heading" className="mt-16 scroll-mt-24" id="countries">
          <h2 id="countries-heading" className="text-[0.6875rem] uppercase tracking-[0.16em] text-ink-faint">
            {s.countries}
          </h2>
          <div className="mt-3 border-y border-line">
            <RegionSummary regions={data.regions} strings={strings} />
          </div>
          <p className="mt-4 text-sm text-ink-faint">
            {s.missing}{' '}
            <Out href={repository.file('docs/packs.md')}>{s.guide}</Out>
          </p>
          <p className="mt-8 border-t border-line pt-6 text-sm text-ink-faint">{s.tested}</p>
        </nav>
      </main>
      <Footer repository={repository} measure="reading" strings={strings} />
    </>
  );
}
