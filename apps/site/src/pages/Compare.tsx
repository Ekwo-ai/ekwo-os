/**
 * Two countries, side by side, on one page, without a line of JavaScript.
 *
 * The first version gave every unordered pair its own page, `/compare/<a>-<b>/`.
 * That is n(n-1)/2 pages and an n×n matrix of links to them: fifteen at six
 * countries, 1,225 at fifty, 19,900 at two hundred — for a project whose whole
 * argument is that the rest of the world is coming. So there is one page now.
 *
 * It carries every country's column once, and two native `<select>`s choose
 * which two are shown. The choosing is CSS: a `<select>` marks its chosen
 * `<option>` as `:checked`, and `:has()` lets the table ask the picker which
 * one that is. The rules are one pair per pack, generated below from the same
 * list as the columns, so a pack added to `packs/` adds a column, an option and
 * its two rules with nothing edited here. The page and the stylesheet grow by
 * one column per country, never by one per pair.
 *
 * A `<select>` rather than a radio per country because at two hundred a radio
 * group is a wall; the select groups the countries by region (`<optgroup>`),
 * answers to typing the first letters of a name, and is the control every
 * phone already knows how to draw.
 *
 * Where `:has()` is not understood, nothing is hidden: every column is shown,
 * one under the other, each under its country's name, and a sentence says so.
 * That is long, and it is correct. The inline script adds only what a static
 * page cannot do: it reads `?a=` and `?b=` — and `?pair=`, which is where
 * `public/_redirects` sends the addresses of the old pair pages — to set the
 * two pickers, and writes the choice back into the address so it can be sent.
 *
 * The rows are `STATUS_ROWS`, the same list the country page prints in one
 * column: the two pages cannot answer the same question differently, because
 * it is asked once.
 */

import type { ReactNode } from 'react';
import type { PackDescription } from '../../../../packages/cli/src/index.js';
import type { Region, Repository, SiteData } from '../data.js';
import type { Strings } from '../strings/index.js';
import { statusRows, type StatusRow } from './rows.js';
import { regionName } from './Regions.js';
import { Footer, Masthead } from './ui.js';

/** The two pickers, by the id the rules and the script find them by. */
export const PICKERS = ['compare-a', 'compare-b'] as const;

/**
 * The rules that show the two columns picked, and nothing else.
 *
 * Two per pack: shown first when the first picker holds it, second when the
 * second does. `order` places the cell in its row, so the table reads in the
 * order the reader picked rather than the order of the packs. A slug is two
 * lowercase letters, which is what makes it safe to write into a selector.
 */
export function compareRules(countries: readonly PackDescription[]): string {
  const rules = countries.flatMap((country) =>
    PICKERS.map(
      (picker, index) =>
        `.compare:has(#${picker} option[value="${country.slug}"]:checked) [data-c="${country.slug}"]{display:block;order:${index + 1}}`,
    ),
  );
  return `@supports selector(:has(*)){${rules.join('')}}`;
}

/** `/compare/` — any two countries, picked on the page. */
export function Compare({ data, strings }: { data: SiteData; strings: Strings }): ReactNode {
  const { countries, regions, repository } = data;
  const s = strings.compare;
  const [first, second] = countries;
  return (
    <>
      <Masthead measure="page" strings={strings} data={data} current="countries" />
      <main className="mx-auto max-w-page px-5 py-12">
        <h1 className="text-3xl font-semibold tracking-tight">{s.heading}</h1>
        <p className="mt-3 max-w-reading text-ink-faint">{s.lead}</p>

        {first === undefined || second === undefined ? (
          <p className="mt-8 text-ink-faint">{s.onlyOne}</p>
        ) : (
          <div className="compare mt-8" data-compare>
            <style dangerouslySetInnerHTML={{ __html: compareRules(countries) }} />
            <div className="grid gap-4 sm:grid-cols-2">
              <Picker id={PICKERS[0]} label={s.first} regions={regions} chosen={first} strings={strings} />
              <Picker id={PICKERS[1]} label={s.second} regions={regions} chosen={second} strings={strings} />
            </div>
            <p className="compare-fallback mt-6 text-sm text-ink-faint">{s.everyColumn}</p>

            {/*
              A comparison is genuinely tabular, so it stays a `<table>`; each
              row is laid out as a grid so the two cells picked can be placed
              by `order`, and the roles are written out because a browser that
              sees a row drawn as a grid may otherwise stop calling it one.
              Below the width of three columns the cells stack, each carrying
              its country's name, since a value with its column header
              off-screen says nothing.
            */}
            <table role="table" className="compare-table mt-10 w-full border-collapse text-sm">
              <thead role="rowgroup" className="compare-head">
                <tr role="row" className="compare-row border-b border-line text-left">
                  <th role="columnheader" scope="col" className="pb-3 text-xs uppercase tracking-wide font-normal text-ink-faint">
                    {s.carries}
                  </th>
                  {countries.map((country) => (
                    <Head key={country.slug} country={country} />
                  ))}
                </tr>
              </thead>
              <tbody role="rowgroup" className="block">
                {statusRows(strings).map((row) => (
                  <tr key={row.key} role="row" id={row.key} className="compare-row border-t border-line align-top">
                    <th role="rowheader" scope="row" className="pt-4 pb-1 text-left font-normal sm:py-4">
                      <span className="font-medium text-ink">{row.label}</span>
                      <span className="mt-0.5 block text-xs leading-snug text-ink-faint">{row.hint}</span>
                    </th>
                    {countries.map((country) => (
                      <Cell key={country.slug} country={country} row={row} repository={repository} />
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

/** One picker: every pack, grouped by region, one of them chosen. */
function Picker({
  id,
  label,
  regions,
  chosen,
  strings,
}: {
  id: string;
  label: string;
  regions: Region[];
  chosen: PackDescription;
  strings: Strings;
}): ReactNode {
  return (
    <label className="block">
      <span className="text-[0.6875rem] uppercase tracking-[0.12em] text-ink-faint">{label}</span>
      <select
        id={id}
        name={id}
        defaultValue={chosen.slug}
        className="mt-1.5 block w-full rounded-sm border border-line bg-paper px-3 py-2.5 text-base text-ink focus:border-brand-soft focus:outline-none"
      >
        {regions.map((region) => (
          <optgroup key={region.code} label={regionName(region, strings)}>
            {region.countries.map((country) => (
              <option key={country.slug} value={country.slug}>
                {country.name}
              </option>
            ))}
          </optgroup>
        ))}
      </select>
    </label>
  );
}

function Head({ country }: { country: PackDescription }): ReactNode {
  return (
    <th role="columnheader" scope="col" data-c={country.slug} className="pb-3 text-left font-normal">
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
    <td role="cell" data-c={country.slug}>
      {/* The column header, repeated where the header row is not shown. */}
      <span className="compare-label">
        {country.name}
      </span>
      {row.cell(country, repository)}
    </td>
  );
}
