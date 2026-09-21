/**
 * The timeline of what changed, read from the repository and never written.
 *
 * Two sources, each dated by the repository itself:
 *
 * - **`CHANGELOG.md`.** Every `## [x.y.z] — <date>` is a release, dated by its
 *   heading, and every entry under it — a bullet opening on a sentence in bold —
 *   is a change of that day: `### Fixed` and `### Security` are fixes, the
 *   other sections features. The sentence in bold is the entry's own headline,
 *   so the timeline says what the changelog says. Entries under
 *   `## [Unreleased]` have no date in the file; they take the day git says
 *   their line was last written (`datesOfLines`), and none where git cannot
 *   say, which a shallow clone cannot.
 * - **The packs.** `describePack()` gives each its version and `releasedAt`,
 *   the day the pack says its reading of the law is true. A pack at its first
 *   version is a new country; any other is that country's pack at a new
 *   version, and its arrival is the day git says its manifest was added, where
 *   git can say it. Nothing is placed at a guess.
 *
 * So a country merged tomorrow is on the timeline of the next build, with
 * nothing here edited. Everything in this file is pure: `data.ts` reads the
 * files and asks git, and hands the text and the dates in.
 */

import { marked } from 'marked';
import type { PackDescription } from '../../../packages/cli/src/index.js';

export type ChangeKind = 'country' | 'feature' | 'fix' | 'release';

export interface Change {
  kind: ChangeKind;
  /** `YYYY-MM-DD`, or null for an unreleased entry git could not date. */
  date: string | null;
  /** Not in a release yet: said beside the date. */
  unreleased: boolean;
  /** An entry's headline as HTML, its inline code kept. Null for a country or a release, whose sentence is the language's. */
  html: string | null;
  /** The country, for a pack. */
  country: { slug: string; name: string; version: string; first: boolean } | null;
  /** The version, for a release. */
  version: string | null;
  /** Where the change is told in full: a heading of the changelog, or a country page. */
  href: string;
}

/** The versions a pack is published at first. */
const FIRST_VERSIONS = new Set(['0.1.0', '1.0.0']);

/** The sections of Keep a Changelog that are fixes; every other one is a feature. */
const FIX_SECTIONS = new Set(['Fixed', 'Security']);

/**
 * The anchor GitHub gives a heading: lowercased, every character that is not
 * a letter, a digit, a space, a hyphen or an underscore dropped, and each
 * space a hyphen. `[0.4.1] — 2026-09-18` becomes `041--2026-09-18`.
 */
export function githubAnchor(heading: string): string {
  return heading
    .trim()
    .toLowerCase()
    .replace(/[^\p{L}\p{N} _-]/gu, '')
    .replace(/ /g, '-');
}

/**
 * Every release and every entry of a changelog in the Keep a Changelog shape.
 *
 * `lineDates` answers, for the number of a line (from 1), the day it was
 * written; it is asked only for unreleased entries.
 */
export function changesOfChangelog(
  text: string,
  changelogUrl: string,
  lineDates: ReadonlyMap<number, string> = new Map(),
): Change[] {
  const lines = text.split('\n');
  const out: Change[] = [];
  let release: { version: string | null; date: string | null; href: string } | null = null;
  let section = '';

  const entry = (start: number): void => {
    // The bullet runs to the next bullet, heading or blank line.
    let end = start + 1;
    while (end < lines.length && /^\s+\S/.test(lines[end] as string)) end += 1;
    const body = lines.slice(start, end).join(' ').replace(/\s+/g, ' ');
    const bold = /^- \*\*(.+?)\*\*/.exec(body);
    if (bold === null || release === null) return;
    const headline = (bold[1] as string).trim().replace(/[:,]$/, '');
    const unreleased = release.version === null;
    out.push({
      kind: FIX_SECTIONS.has(section) ? 'fix' : 'feature',
      date: unreleased ? lineDates.get(start + 1) ?? null : release.date,
      unreleased,
      html: marked.parseInline(headline, { async: false }),
      country: null,
      version: null,
      href: release.href,
    });
  };

  lines.forEach((line, index) => {
    const heading = /^## (\[([^\]]+)\](?:\s+—\s+(\d{4}-\d{2}-\d{2}))?)\s*$/.exec(line);
    if (heading !== null) {
      const name = heading[2] as string;
      const href = `${changelogUrl}#${githubAnchor(heading[1] as string)}`;
      if (name.toLowerCase() === 'unreleased') {
        release = { version: null, date: null, href };
      } else {
        release = { version: name, date: heading[3] ?? null, href };
        out.push({
          kind: 'release',
          date: release.date,
          unreleased: false,
          html: null,
          country: null,
          version: name,
          href,
        });
      }
      section = '';
      return;
    }
    const sub = /^### (\w+)/.exec(line);
    if (sub !== null) {
      section = sub[1] as string;
      return;
    }
    if (line.startsWith('- **')) entry(index);
  });
  return out;
}

/**
 * What the packs say about themselves: a new country, or a new version of one.
 *
 * A pack at its first version is a new country, on the day it names. A pack
 * past it is that country at its current version, on that day — and, where
 * `arrivals` knows the day its manifest first entered the repository, a new
 * country on that day too. Without it (a clone with no history) the arrival of
 * a country already past its first version is simply not shown.
 */
export function changesOfPacks(
  countries: readonly PackDescription[],
  arrivals: ReadonlyMap<string, string> = new Map(),
): Change[] {
  const change = (country: PackDescription, date: string, first: boolean): Change => ({
    kind: 'country',
    date,
    unreleased: false,
    html: null,
    country: { slug: country.slug, name: country.name, version: country.version, first },
    version: null,
    href: `/countries/${country.slug}/`,
  });
  return countries.flatMap((country) => {
    const first = FIRST_VERSIONS.has(country.version);
    const out: Change[] = [];
    if (country.releasedAt !== null) out.push(change(country, country.releasedAt, first));
    const arrived = arrivals.get(country.slug);
    if (!first && arrived !== undefined) out.push(change(country, arrived, true));
    return out;
  });
}

/**
 * Both, newest first.
 *
 * An undated unreleased entry is newer than anything released, so it comes
 * first. On one day the countries come before the entries of the changelog,
 * and the release before its own entries; otherwise the order of the sources
 * is kept.
 */
export function timeline(packs: Change[], changelog: Change[]): Change[] {
  const rank: Record<ChangeKind, number> = { country: 0, release: 1, feature: 2, fix: 2 };
  return [...packs, ...changelog]
    .map((change, index) => ({ change, index }))
    .sort((a, b) => {
      const da = a.change.date ?? '9999-99-99';
      const db = b.change.date ?? '9999-99-99';
      if (da !== db) return da < db ? 1 : -1;
      const ra = rank[a.change.kind];
      const rb = rank[b.change.kind];
      return ra !== rb ? ra - rb : a.index - b.index;
    })
    .map(({ change }) => change);
}

/**
 * The day each line of a file was last written, from `git blame --porcelain`.
 *
 * Keyed by line number from 1, in UTC. A line not committed yet has no day.
 */
export function datesOfLines(porcelain: string): Map<number, string> {
  const times = new Map<string, string>();
  const dates = new Map<number, string>();
  let sha = '';
  let line = 0;
  for (const row of porcelain.split('\n')) {
    const head = /^([0-9a-f]{40}) \d+ (\d+)/.exec(row);
    if (head !== null) {
      sha = head[1] as string;
      line = Number(head[2]);
      continue;
    }
    const time = /^committer-time (\d+)$/.exec(row);
    if (time !== null) {
      times.set(sha, new Date(Number(time[1]) * 1000).toISOString().slice(0, 10));
      continue;
    }
    if (row.startsWith('\t')) {
      const date = /^0+$/.test(sha) ? undefined : times.get(sha);
      if (date !== undefined) dates.set(line, date);
    }
  }
  return dates;
}
