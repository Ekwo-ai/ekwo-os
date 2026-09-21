import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { repoRootDir } from '../../../packages/cli/src/index.js';
import { readSiteData } from '../src/data.js';
import { renderPages } from '../src/render.js';
import {
  changesOfChangelog,
  changesOfPacks,
  datesOfLines,
  githubAnchor,
  timeline,
} from '../src/changes.js';
import { CHANGES, HOME_CHANGES } from '../src/pages/Changes.js';

/**
 * The timeline is read, never written: every item comes from the changelog or
 * from a pack, and a pack that lands is on it with nothing edited.
 */

const data = await readSiteData();
const pages = renderPages(data);
const byUrl = new Map(pages.map((page) => [page.url, page]));
const changelog = await readFile(join(repoRootDir(), 'CHANGELOG.md'), 'utf8');

const FIXTURE = [
  '# Changelog',
  '',
  '## [Unreleased]',
  '',
  '### Added',
  '',
  '- **Something new.** And what it does,',
  '  on two lines.',
  '',
  '### Fixed',
  '',
  '- **Something `broken`, mended:** and how.',
  '',
  '## [1.2.0] — 2030-01-02',
  '',
  '### Security',
  '',
  '- **A hole closed.**',
  '- no headline here, so no item',
  '',
].join('\n');

describe('the changelog, read', () => {
  it('makes a release of every version heading and an item of every entry with a headline', () => {
    const items = changesOfChangelog(FIXTURE, 'https://x.example/CHANGELOG.md');
    expect(items.map((item) => item.kind)).toEqual(['feature', 'fix', 'release', 'fix']);
    expect(items[0]!.html).toBe('Something new.');
    expect(items[1]!.html).toBe('Something <code>broken</code>, mended');
    expect(items[2]).toMatchObject({ version: '1.2.0', date: '2030-01-02', unreleased: false });
    expect(items[3]).toMatchObject({ date: '2030-01-02', href: 'https://x.example/CHANGELOG.md#120--2030-01-02' });
  });

  it('dates an unreleased entry by git where it can, and leaves it undated where it cannot', () => {
    const undated = changesOfChangelog(FIXTURE, '');
    expect(undated[0]).toMatchObject({ date: null, unreleased: true });
    const dated = changesOfChangelog(FIXTURE, '', new Map([[7, '2030-01-05']]));
    expect(dated[0]).toMatchObject({ date: '2030-01-05', unreleased: true });
    expect(dated[1]!.date).toBeNull();
  });

  it('reads the day of a line from git blame', () => {
    const sha = 'a'.repeat(40);
    const zero = '0'.repeat(40);
    const porcelain = [
      `${sha} 1 1 1`,
      'committer-time 1893456000',
      '\tfirst line',
      `${zero} 2 2 1`,
      '\tnot committed',
      `${sha} 3 3 1`,
      '\tthird line',
    ].join('\n');
    const dates = datesOfLines(porcelain);
    expect(dates.get(1)).toBe('2030-01-01');
    expect(dates.has(2)).toBe(false);
    expect(dates.get(3)).toBe('2030-01-01');
  });

  it('links to the anchor GitHub gives the heading', () => {
    expect(githubAnchor('[Unreleased]')).toBe('unreleased');
    expect(githubAnchor('[0.4.1] — 2026-09-18')).toBe('041--2026-09-18');
  });

  it('puts every release of the repository on the timeline', () => {
    const versions = [...changelog.matchAll(/^## \[(\d+\.\d+\.\d+)\]/gm)].map((match) => match[1]);
    expect(versions.length).toBeGreaterThan(0);
    const shown = data.changes.filter((change) => change.kind === 'release').map((change) => change.version);
    expect(shown.sort()).toEqual([...versions].sort());
  });
});

describe('the packs, read', () => {
  it('puts every dated pack on the timeline, linked to its page', () => {
    for (const country of data.countries) {
      if (country.releasedAt === null) continue;
      const item = data.changes.find(
        (change) => change.country?.slug === country.slug && change.date === country.releasedAt,
      );
      expect(item, country.slug).toBeDefined();
      expect(item!.href).toBe(`/countries/${country.slug}/`);
    }
  });

  it('shows a pack that lands tomorrow, with nothing edited', () => {
    const model = data.countries[0]!;
    const landed = { ...model, slug: 'zz', version: '0.1.0', releasedAt: '2099-01-01' };
    const items = timeline(changesOfPacks([...data.countries, landed]), []);
    expect(items[0]).toMatchObject({ kind: 'country', date: '2099-01-01', href: '/countries/zz/' });
    expect(items[0]!.country!.first).toBe(true);
  });

  it('says a country arrived only on a day git gives, and a new version on the day the pack gives', () => {
    const model = data.countries[0]!;
    const later = { ...model, version: '2.3.0', releasedAt: '2099-02-01' };
    expect(changesOfPacks([later]).map((item) => item.country!.first)).toEqual([false]);
    const both = changesOfPacks([later], new Map([[later.slug, '2098-01-01']]));
    expect(both.map((item) => [item.date, item.country!.first])).toEqual([
      ['2099-02-01', false],
      ['2098-01-01', true],
    ]);
  });
});

describe('the timeline on the site', () => {
  it('is newest first, the undated unreleased entries ahead of everything', () => {
    const dates = data.changes.map((change) => change.date ?? '9999-99-99');
    expect([...dates].sort().reverse()).toEqual(dates);
  });

  it('has a page with every item, and the home page shows the latest few', () => {
    const page = byUrl.get(CHANGES)!.body;
    expect(page.split('data-change=').length - 1).toBe(data.changes.length);
    const home = byUrl.get('/')!.body;
    expect(home.split('data-change=').length - 1).toBe(Math.min(HOME_CHANGES, data.changes.length));
    expect(home).toContain(`href="${CHANGES}"`);
  });

  it('is linked from the foot of every page', () => {
    for (const page of pages) expect(page.body, page.url).toContain(`href="${CHANGES}"`);
  });
});
