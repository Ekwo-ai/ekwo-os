/**
 * Two countries, side by side, without a line of JavaScript.
 *
 * The choice is made by following a link, because a `<select>` that filters a
 * table needs scripting and this site has none. So every unordered pair of
 * packs gets its own page — `/compare/<a>-<b>/` — and `/compare/` is the
 * matrix of links to them. The pages are generated from `listPacks()`, so a
 * new pack adds a row, a column and its pairs with nothing edited here.
 *
 * The rows are `STATUS_ROWS`, the same list the country page prints in one
 * column. That is the point of the comparison: the two pages cannot answer the
 * same question differently, because it is asked once.
 */

import type { ReactNode } from 'react';
import type { PackDescription } from '../../../../packages/cli/src/index.js';
import type { Repository, SiteData } from '../data.js';
import { fill, type Strings } from '../strings/index.js';
import { statusRows, type StatusRow } from './rows.js';
import { Footer, Masthead, Out } from './ui.js';

/** The unordered pairs of a list, in the order the list gives them. */
export function pairsOf<T>(items: readonly T[]): [T, T][] {
  const pairs: [T, T][] = [];
  for (let i = 0; i < items.length; i += 1) {
    for (let j = i + 1; j < items.length; j += 1) {
      pairs.push([items[i] as T, items[j] as T]);
    }
  }
  return pairs;
}

/** The path of one comparison, from the two slugs. */
export function comparePath(left: PackDescription, right: PackDescription): string {
  return `compare/${left.slug}-${right.slug}/`;
}

/** `/compare/` — every pair there is, as a matrix of links. */
export function CompareIndex({ data, strings }: { data: SiteData; strings: Strings }): ReactNode {
  const { countries, repository } = data;
  const s = strings.compare;
  return (
    <>
      <Masthead measure="page" strings={strings} data={data} current="countries" />
      <main className="mx-auto max-w-page px-5 py-12">
        <h1 className="text-3xl font-semibold tracking-tight">{s.heading}</h1>
        <p className="mt-3 max-w-reading text-ink-faint">
          {s.lead}
        </p>

        {countries.length < 2 ? (
          <p className="mt-8 text-ink-faint">
            {s.onlyOne}
          </p>
        ) : (
          <div className="mt-8 overflow-x-auto">
            <table className="border-collapse text-sm">
              <caption className="sr-only">
                {s.caption}
              </caption>
              <thead>
                <tr>
                  <td />
                  {countries.map((country) => (
                    <th
                      key={country.slug}
                      scope="col"
                      className="px-2 pb-2 text-center font-mono text-xs font-normal text-ink-faint"
                    >
                      {country.slug}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {countries.map((row) => (
                  <tr key={row.slug} className="border-t border-line">
                    <th
                      scope="row"
                      className="py-1.5 pr-4 text-left font-normal whitespace-nowrap"
                    >
                      <span className="font-mono text-xs text-ink-faint">{row.slug}</span>{' '}
                      <span className="text-ink">{row.name}</span>
                    </th>
                    {countries.map((column) => (
                      <td key={column.slug} className="px-2 py-1.5 text-center">
                        {row.slug === column.slug ? (
                          <span className="text-ink-faint" aria-hidden="true">
                            ·
                          </span>
                        ) : (
                          <a
                            href={`/${
                              row.slug < column.slug
                                ? comparePath(row, column)
                                : comparePath(column, row)
                            }`}
                            aria-label={`Compare ${row.name} with ${column.name}`}
                          >
                            compare
                          </a>
                        )}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </main>
      <Footer repository={repository} measure="page" strings={strings} />
    </>
  );
}

/** `/compare/<a>-<b>/` — the status table in two columns. */
export function ComparePair({
  left,
  right,
  data,
  strings,
}: {
  left: PackDescription;
  right: PackDescription;
  data: SiteData;
  strings: Strings;
}): ReactNode {
  const { repository } = data;
  const s = strings.compare;
  return (
    <>
      <Masthead measure="page" strings={strings} data={data} current="countries" />
      <main className="mx-auto max-w-page px-5 py-12">
        <p className="font-mono text-sm text-ink-faint">
          {left.slug} · {right.slug}
        </p>
        <h1 className="mt-1 text-3xl font-semibold tracking-tight">
          {left.name} and {right.name}
        </h1>
        <p className="mt-3 text-sm">
          <a href="/compare/">{s.everyPair}</a>
        </p>

        {/*
          Three columns on a screen with room, and three stacked blocks on a
          phone. A comparison is genuinely tabular, so it stays a `<table>` and
          keeps its semantics wherever the columns fit; below that the cells go
          to `display: block` and each carries the country's name, because a
          value with its column header off-screen says nothing.

          Scrolling it sideways instead was the first version, and it was worse
          than cramped: the height of a row is set by its tallest cell, so a
          long legal reference in the column you could not see left a blank
          band in the column you could, and the page looked broken.
        */}
        <div className="mt-10 sm:overflow-x-auto">
          <table className="w-full border-collapse text-sm sm:min-w-3xl">
            <thead className="hidden sm:table-header-group">
              <tr className="border-b border-line text-left">
                <th scope="col" className="w-1/4 pb-3 pr-6 text-xs uppercase tracking-wide font-normal text-ink-faint">
                  {s.carries}
                </th>
                <Head country={left} />
                <Head country={right} />
              </tr>
            </thead>
            <tbody className="block sm:table-row-group">
              {statusRows(strings).map((row) => (
                <tr
                  key={row.key}
                  id={row.key}
                  className="block border-t border-line align-top sm:table-row"
                >
                  <th
                    scope="row"
                    className="block pt-4 pr-6 text-left font-normal sm:table-cell sm:py-4"
                  >
                    <span className="font-medium text-ink">{row.label}</span>
                    <span className="mt-0.5 block text-xs leading-snug text-ink-faint">{row.hint}</span>
                  </th>
                  <Cell country={left} row={row} repository={repository} />
                  <Cell country={right} row={row} repository={repository} />
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <nav className="mt-12 flex flex-wrap gap-x-6 gap-y-2 text-sm">
  
        </nav>
      </main>
      <Footer repository={repository} measure="page" strings={strings} />
    </>
  );
}

function Head({ country }: { country: PackDescription }): ReactNode {
  return (
    <th scope="col" className="w-[37.5%] pb-3 pr-6 text-left font-normal">
      <a href={`/countries/${country.slug}/`} className="font-medium text-ink">
        {country.name}
      </a>
      <span className="mt-0.5 block font-mono text-xs text-ink-faint">{country.slug}</span>
    </th>
  );
}

function Cell({
  country,
  row,
  repository,
}: {
  country: PackDescription;
  row: StatusRow;
  repository: Repository;
}): ReactNode {
  return (
    <td className="block pt-2 pb-1 pr-6 last:pb-4 sm:table-cell sm:py-4 sm:pb-4">
      {/* The column header, repeated where the header row is not shown. */}
      <span className="mb-0.5 block text-xs uppercase tracking-wide text-ink-faint sm:hidden">
        {country.name}
      </span>
      {row.cell(country, repository)}
    </td>
  );
}
