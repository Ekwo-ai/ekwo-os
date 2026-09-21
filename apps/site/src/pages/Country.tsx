/**
 * One country: the whole of what its pack says, and where it stops.
 *
 * Every value on this page is `describePack()`, which is `packs/<cc>/` read and
 * nothing else. Where the pack is silent the page says so in words — "not
 * declared in the pack", "no reader yet" — because a reader deciding whether
 * Ekwo can keep their books needs the holes more than the totals, and because
 * an absent row is indistinguishable from a row nobody thought to add.
 *
 * It used to be one long column of everything, which is how a page becomes
 * documentation. The reading order now has a shape: what this country is, in a
 * card; what its pack carries, in rows with room to breathe; where the open
 * core stops; and the reading list folded away behind a `<details>` that opens
 * without scripting, since it is the longest part and the least often wanted.
 *
 * The country's name is shown in the languages the pack publishes it in. That
 * is the one translated thing here, because it is the one thing the pack
 * translates.
 */

import type { ReactNode } from 'react';
import type { PackDescription } from '../../../../packages/cli/src/index.js';
import type { Repository, SiteData } from '../data.js';
import { fill, type Strings } from '../strings/index.js';
import { statusRows } from './rows.js';
import { SetUpButton } from './SetUp.js';
import { Card, Eyebrow, Field, Footer, Masthead, Mono, NotYet, Out, StatusPill } from './ui.js';

export function Country({
  country,
  data,
  strings,
}: {
  country: PackDescription;
  data: SiteData;
  strings: Strings;
}): ReactNode {
  const { repository } = data;
  const s = strings.country;
  const translations = Object.entries(country.nameI18n).filter(([, name]) => name !== country.name);

  return (
    <>
      <Masthead measure="page" strings={strings} data={data} current="countries" />
      <main className="mx-auto max-w-page px-5 py-14">
        <div className="flex flex-wrap items-center gap-3">
          <Eyebrow>{s.eyebrow}</Eyebrow>
          <StatusPill status={country.certification.status} />
        </div>
        <h1 className="mt-4 text-[clamp(2.25rem,1.7rem+2.6vw,3.5rem)]">{country.name}</h1>
        {translations.length === 0 ? null : (
          <p className="mt-3 text-ink-faint">
            {translations.map(([language, name], index) => (
              <span key={language}>
                {index > 0 ? ' · ' : ''}
                {name} <span className="text-ink-faint/70">({language})</span>
              </span>
            ))}
          </p>
        )}

        <Card className="mt-8 p-6">
          <dl className="grid grid-cols-2 gap-x-6 gap-y-5 text-sm sm:grid-cols-4">
            <Field label={s.code}>
              <Mono>{country.country}</Mono>
            </Field>
            <Field label={s.currency}>
              <Mono>{country.currency}</Mono>
            </Field>
            <Field label={s.version}>
              <Mono>{country.version}</Mono>
            </Field>
            <Field label={s.lastChecked}>
              {country.certification.lastConsultedOn ?? <NotYet>{s.noDay}</NotYet>}
            </Field>
          </dl>
        </Card>

        <div className="mt-8">
          <SetUpButton country={country} strings={strings} />
        </div>

        <StatusTable country={country} repository={repository} strings={strings} />
        <Boundary country={country} strings={strings} />
        <Sources country={country} strings={strings} />
        <SetUpButton country={country} strings={strings} band />

        <nav className="mt-14 flex flex-wrap gap-x-6 gap-y-2 text-sm">
          <Out href={repository.dir(`packs/${country.slug}`)}>{s.packFiles}</Out>
          <Out href={repository.file('docs/packs.md')}>{s.writeYours}</Out>
          <a href={`/compare/?a=${country.slug}`}>{s.compare}</a>
        </nav>
      </main>
      <Footer repository={repository} measure="page" strings={strings} />
    </>
  );
}

/**
 * The status rows: a label, what it is asking, and the answer.
 *
 * A description list and not a table, because on this page there is one column
 * of values and a `<dl>` can stack: on a phone the label sits above its answer
 * and the page reads in one direction. A two-column table at 400px either
 * squeezes both halves to nothing or scrolls sideways, and a reader who has to
 * drag a row to see whether their country has a deadline will not do it.
 */
function StatusTable({
  country,
  repository,
  strings,
}: {
  country: PackDescription;
  repository: Repository;
  strings: Strings;
}): ReactNode {
  return (
    <section className="mt-16">
      <Eyebrow>{strings.country.carries}</Eyebrow>
      <dl className="mt-5">
        {statusRows(strings).map((row) => (
          <div
            key={row.key}
            id={row.key}
            className="grid scroll-mt-24 gap-x-10 gap-y-2 border-t border-line py-6 sm:grid-cols-[2fr_3fr]"
          >
            <dt>
              <span className="font-medium text-ink">{row.label}</span>
              <span className="mt-1 block text-sm leading-snug text-ink-faint">{row.hint}</span>
            </dt>
            <dd className="text-ink-soft">{row.cell(country, repository)}</dd>
          </div>
        ))}
      </dl>
    </section>
  );
}

/**
 * Where the open core stops, for this country, line by line.
 *
 * The rows come from the pack: a declaration it declares, a profile it imposes,
 * a bank format it names. The rule applied to them is the one in `ee/README.md`
 * — writing and validating a file is free, handing it to somebody else is
 * operated — and this page states it rather than deciding it.
 */
function Boundary({
  country,
  strings,
}: {
  country: PackDescription;
  strings: Strings;
}): ReactNode {
  const s = strings.country;
  return (
    <section className="mt-20">
      <Eyebrow>{s.boundaryEyebrow}</Eyebrow>
      <h2 className="mt-4 text-2xl">{s.boundaryTitle}</h2>
      <p className="mt-3 max-w-reading text-ink-soft">{s.boundaryLead}</p>
      <div className="mt-8 grid gap-4 sm:grid-cols-2">
        {country.boundary.map((row) => (
          <Card key={`${row.kind}-${row.subject}`} className="p-6">
            <div className="flex flex-wrap items-center gap-2">
              <Mono>{row.subject}</Mono>
              <span className="text-xs text-ink-faint">{row.kind.replace(/_/g, ' ')}</span>
            </div>
            <p className="mt-4 text-sm text-ink-soft">
              <span className="mb-1 block text-[0.6875rem] uppercase tracking-[0.12em] text-ink-faint">
                {s.free}
              </span>
              {row.free}
            </p>
            <p className="mt-4 text-sm text-ink-soft">
              <span className="mb-1 block text-[0.6875rem] uppercase tracking-[0.12em] text-ink-faint">
                {s.operated}
              </span>
              {row.operated === null ? <NotYet>{s.nothingOperated}</NotYet> : row.operated}
            </p>
          </Card>
        ))}
      </div>
    </section>
  );
}

/**
 * The texts the pack was built from, folded away.
 *
 * A pack says where the law is and never what it says, so this is a reading
 * list with a date on each entry: the day somebody opened it. It is the honest
 * measure of how current a country pack is, and it is why the head of the page
 * can say "last checked" at all. It is also fifteen links on some packs, which
 * is most of the page's length and almost never what somebody came for — so it
 * is a `<details>`, which opens with scripting off and is summarised by its
 * count either way.
 */
function Sources({
  country,
  strings,
}: {
  country: PackDescription;
  strings: Strings;
}): ReactNode {
  const s = strings.country;
  const sources = country.certification.sources;
  return (
    <section className="mt-20">
      <Eyebrow>{s.sourcesEyebrow}</Eyebrow>
      {sources.length === 0 ? (
        <p className="mt-4">
          <NotYet>{s.noSources}</NotYet>
        </p>
      ) : (
        <details className="group mt-4">
          <summary className="inline-flex list-none items-center gap-2 rounded-pill border border-line bg-paper px-4 py-2 text-sm text-ink transition-colors duration-150 hover:border-brand">
            <span aria-hidden className="text-brand-deep transition-transform duration-150 group-open:rotate-90">
              ›
            </span>
            {fill(s.sourcesSummary, { count: sources.length })}
          </summary>
          <ul className="mt-5 divide-y divide-line border-y border-line text-sm">
            {sources.map((source) => (
              <li key={source.key} className="py-3.5">
                <Out href={source.url}>{source.title}</Out>
                <p className="mt-1 text-xs text-ink-faint">
                  {source.publisher} · {source.kind} · read {source.consulted_on}
                </p>
              </li>
            ))}
          </ul>
        </details>
      )}
    </section>
  );
}
