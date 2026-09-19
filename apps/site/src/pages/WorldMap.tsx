/**
 * The world, with the countries that have a pack filled in.
 *
 * The map is the argument, so it is drawn the way the argument runs: every
 * country on earth is there, the handful with a pack are in the accent, and
 * **every other one is a link to the guide for writing theirs**. A map that
 * showed only what is covered would say "a European tool with a few
 * neighbours"; this one says the target is the whole of it, and that each grey
 * shape is an opening.
 *
 * The geometry is Natural Earth, public domain, simplified and projected once
 * into `src/data/world.json` — the attribution is in `apps/site/README.md`. The
 * colouring is `packs/`, read at build time. No country is named in this file.
 *
 * Accessibility, and the same thing as working without scripting: the shapes
 * are links with accessible names, and the list underneath is the map in words
 * — the covered countries by name and status, and the count of the rest. A
 * reader who cannot use the picture loses nothing but the picture.
 */

import type { ReactNode } from 'react';
import type { Repository, WorldMap as WorldMapData } from '../data.js';
import type { Strings } from '../strings/index.js';
import { StatusPill } from './ui.js';

export function WorldMap({
  world,
  repository,
  strings,
}: {
  world: WorldMapData;
  repository: Repository;
  strings: Strings;
}): ReactNode {
  const s = strings.home.world;
  const covered = world.countries.filter((country) => country.pack !== null);
  const open = world.countries.length - covered.length;
  const write = repository.file('docs/packs.md');

  return (
    <div>
      <div className="relative overflow-hidden rounded-xl border border-line bg-paper shadow-lift">
        <svg
          viewBox={`0 0 ${world.width} ${world.height}`}
          className="block h-auto w-full"
          role="img"
          aria-labelledby="map-title map-desc"
        >
          <title id="map-title">The countries Ekwo has a pack for</title>
          <desc id="map-desc">
            {covered.length} of {world.countries.length} countries have a country pack in this
            repository. Every other country links to the guide for writing one. The same
            information is listed in text below the map.
          </desc>

          {/* Land nobody has a two-letter code for. Drawn so the map is whole. */}
          {world.other.map((path, index) => (
            <path key={`other-${index}`} d={path} className="fill-line/60" />
          ))}

          {world.countries.map((country) =>
            country.pack === null ? (
              <a
                key={country.code}
                href={write}
                rel="noreferrer"
                className="[&>path]:hover:fill-brand-fill [&>path]:focus-visible:fill-brand-fill"
              >
                <title>{`${country.name} — open, be the first to write the pack`}</title>
                <path
                  d={country.path}
                  className="fill-line stroke-bg transition-[fill] duration-150"
                  strokeWidth={0.5}
                />
              </a>
            ) : (
              <a key={country.code} href={`/countries/${country.pack.slug}/`}>
                <title>{`${country.name} — ${country.pack.status}`}</title>
                <path
                  d={country.path}
                  className="fill-brand stroke-bg transition-[fill] duration-150 hover:fill-brand-deep"
                  strokeWidth={0.5}
                />
              </a>
            ),
          )}
        </svg>
      </div>

      <div className="mt-6 flex flex-wrap items-center gap-x-6 gap-y-3 text-sm">
        <span className="inline-flex items-center gap-2">
          <span className="h-3 w-3 rounded-sm bg-brand" aria-hidden />
          <span className="text-ink-soft">
            {covered.length} {s.written}
          </span>
        </span>
        <span className="inline-flex items-center gap-2">
          <span className="h-3 w-3 rounded-sm bg-line" aria-hidden />
          <span className="text-ink-soft">
            {open} {s.open}
          </span>
        </span>
      </div>

      {/* The map in words. It is not a fallback: it is the same thing, listed. */}
      <ul className="mt-6 flex flex-wrap gap-2">
        {covered.map((country) => (
          <li key={country.code}>
            <a
              href={`/countries/${country.pack!.slug}/`}
              className="inline-flex items-center gap-2 rounded-pill border border-line bg-paper px-3 py-1.5 text-sm no-underline transition-colors duration-150 hover:border-brand"
            >
              <span className="text-ink">{country.name}</span>
              <StatusPill status={country.pack!.status} />
            </a>
          </li>
        ))}
      </ul>
    </div>
  );
}
