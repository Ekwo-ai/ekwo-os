/**
 * The timeline: `/changes/`, and its head on the home page.
 *
 * Every item is `data.changes`, read from the changelog and the packs at build
 * time (`src/changes.ts`); this file only draws them. A country's sentence and
 * a release's are the language's, filled with the pack's name or the version;
 * an entry of the changelog is its own headline, as the changelog writes it.
 *
 * One line down the side, a dot per item, the day beside it. The whole page
 * is grouped by day; the home page shows the latest few with their day each.
 */

import type { ReactNode } from 'react';
import type { Change } from '../changes.js';
import type { SiteData } from '../data.js';
import { fill, type Strings } from '../strings/index.js';
import { Eyebrow, Footer, Masthead, Out, Secondary } from './ui.js';

/** How many items the home page shows. */
export const HOME_CHANGES = 8;

/** The page. */
export const CHANGES = '/changes/';

/** A day, written the language's way. */
export function dayOf(date: string, strings: Strings): string {
  return new Intl.DateTimeFormat(strings.lang, {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    timeZone: 'UTC',
  }).format(new Date(`${date}T00:00:00Z`));
}

/** What an item says, in one sentence. */
function Sentence({ change, strings }: { change: Change; strings: Strings }): ReactNode {
  const s = strings.changes;
  if (change.country !== null) {
    return (
      <>
        {change.country.first
          ? fill(s.newCountry, { country: change.country.name })
          : fill(s.countryVersion, { country: change.country.name, version: change.country.version })}
      </>
    );
  }
  if (change.version !== null) return <>{fill(s.release, { version: change.version })}</>;
  return <span dangerouslySetInnerHTML={{ __html: change.html ?? '' }} />;
}

/** One item: its kind, its sentence, where to read more. */
function Item({ change, strings, withDay }: { change: Change; strings: Strings; withDay: boolean }): ReactNode {
  const s = strings.changes;
  const strong = change.kind === 'country' || change.kind === 'release';
  return (
    <li data-change={change.kind} className="relative pb-7 pl-8 last:pb-0">
      <span
        aria-hidden
        className={`absolute top-[0.55rem] left-[-5px] h-[9px] w-[9px] rounded-pill ${strong ? 'bg-brand' : 'border border-brand-soft bg-bg'}`}
      />
      <p className="flex flex-wrap items-center gap-x-3 gap-y-1 text-[0.8125rem] text-ink-faint">
        {withDay ? (
          change.date === null ? (
            <span>{s.undated}</span>
          ) : (
            <time dateTime={change.date}>{dayOf(change.date, strings)}</time>
          )
        ) : null}
        <span className="inline-flex items-center rounded-pill bg-brand-fill px-2 py-0.5 text-xs text-ink-soft">
          {s.kinds[change.kind]}
        </span>
        {change.unreleased && change.date !== null ? <span>{s.unreleased}</span> : null}
      </p>
      <p className={`mt-1.5 ${strong ? 'font-medium text-ink' : 'text-ink-soft'}`}>
        <Sentence change={change} strings={strings} />{' '}
        {change.country !== null ? (
          <a href={change.href} className="text-sm whitespace-nowrap">
            {s.countryPage}
          </a>
        ) : (
          <Out href={change.href} className="text-sm whitespace-nowrap">
            {s.readMore}
          </Out>
        )}
      </p>
    </li>
  );
}

/** A list of items along one line. */
export function Timeline({
  changes,
  strings,
  withDay = true,
}: {
  changes: readonly Change[];
  strings: Strings;
  withDay?: boolean;
}): ReactNode {
  return (
    <ol className="ml-1 border-l border-line pt-1">
      {changes.map((change, index) => (
        <Item key={`${change.kind}-${change.href}-${index}`} change={change} strings={strings} withDay={withDay} />
      ))}
    </ol>
  );
}

/** The section of the home page: the latest few, and the way to the rest. */
export function LatestChanges({ data, strings }: { data: SiteData; strings: Strings }): ReactNode {
  const s = strings.changes;
  if (data.changes.length === 0) return null;
  return (
    <section className="mx-auto max-w-page px-5 py-20">
      <div className="grid gap-10 lg:grid-cols-[1fr_1.4fr]">
        <div>
          <Eyebrow>{s.eyebrow}</Eyebrow>
          <h2 className="mt-4 max-w-[16ch] text-[clamp(2rem,1.3rem+3vw,3.25rem)]">{s.homeTitle}</h2>
          <p className="mt-5 max-w-[40ch] text-lg text-ink-soft">{s.homeLead}</p>
          <div className="mt-8">
            <Secondary href={CHANGES}>{s.all}</Secondary>
          </div>
        </div>
        <Timeline changes={data.changes.slice(0, HOME_CHANGES)} strings={strings} />
      </div>
    </section>
  );
}

/** `/changes/`: every item, grouped by day. */
export function Changes({ data, strings }: { data: SiteData; strings: Strings }): ReactNode {
  const s = strings.changes;
  const days: { date: string | null; changes: Change[] }[] = [];
  for (const change of data.changes) {
    const last = days[days.length - 1];
    if (last !== undefined && last.date === change.date) last.changes.push(change);
    else days.push({ date: change.date, changes: [change] });
  }
  return (
    <>
      <Masthead measure="reading" strings={strings} data={data} />
      <main className="mx-auto max-w-reading px-5 pt-16 pb-4 sm:pt-24">
        <Eyebrow>{s.eyebrow}</Eyebrow>
        <h1 className="mt-4 text-[clamp(2.25rem,1.7rem+2.6vw,3.5rem)]">{s.heading}</h1>
        <p className="mt-5 text-lg text-ink-soft">{s.lead}</p>

        {days.map((day) => (
          <section key={day.date ?? 'undated'} className="mt-12">
            <h2 className="font-sans text-[0.6875rem] font-normal uppercase tracking-[0.16em] text-ink-faint">
              {day.date === null ? s.undated : <time dateTime={day.date}>{dayOf(day.date, strings)}</time>}
            </h2>
            <div className="mt-5">
              <Timeline changes={day.changes} strings={strings} withDay={false} />
            </div>
          </section>
        ))}

        <p className="mt-16 border-t border-line pt-6 text-sm text-ink-faint">{s.source}</p>
      </main>
      <Footer repository={data.repository} measure="reading" strings={strings} />
    </>
  );
}
