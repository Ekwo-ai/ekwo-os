import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { repoRootDir } from '../../../packages/cli/src/index.js';
import { readSiteData } from '../src/data.js';
import { DOCS, LLMS_FULL, LLMS_LEFT_OUT } from '../src/data/docs.js';
import { countryGuide, guideMarkdownUrl } from '../src/guide.js';
import { LLMS_FULL_TXT, LLMS_TXT, llmsFiles, llmsFullTxt, llmsTxt } from '../src/llms.js';
import { renderPages } from '../src/render.js';
import { SOURCE } from '../src/strings/index.js';
import { setUpUrl } from '../src/pages/SetUp.js';

/**
 * What a model is served: `llms.txt`, `llms-full.txt` and the guide of each
 * country as Markdown.
 *
 * The claims are about coverage and about what may never be said, not about a
 * country: every pack gets a guide with its own command and its own codes,
 * every article is in the index, and no file tells an assistant Ekwo is an
 * accounting service or that a pack is certified. A pack added tomorrow is
 * checked by the same loop.
 */

const data = await readSiteData();
const ORIGIN = 'https://example.org';
const index = llmsTxt(data, SOURCE, ORIGIN);
const full = llmsFullTxt(data, SOURCE, ORIGIN);

describe('llms.txt', () => {
  it('is the shape llmstxt.org describes: a title, a blockquote, then lists under headings', () => {
    const lines = index.split('\n');
    expect(lines[0]).toBe('# Ekwo OS');
    expect(lines[2]?.startsWith('> ')).toBe(true);
    expect(index).toMatch(/\n## Optional\n/);
    // Every link is absolute when the build has an origin.
    for (const [, href] of index.matchAll(/\]\(([^)]+)\)/g)) expect(href).toMatch(/^https:\/\//);
  });

  it('points at the guide of every country, and at every article of the documentation', () => {
    for (const country of data.countries) expect(index).toContain(`${ORIGIN}${guideMarkdownUrl(country)}`);
    for (const article of data.docs.filter((a) => a.parent === null && !LLMS_LEFT_OUT.includes(a.slug))) {
      expect(index).toContain(`(${ORIGIN}${article.url})`);
    }
  });
});

describe('llms-full.txt', () => {
  it('carries every article it names, whole, and the guide of every country', () => {
    for (const slug of LLMS_FULL) {
      expect(DOCS.some((doc) => doc.slug === slug), `${slug} is not an article`).toBe(true);
      const article = data.docs.find((a) => a.slug === slug);
      expect(full).toContain(`${ORIGIN}${article?.url}`);
    }
    for (const country of data.countries) {
      expect(full).toContain(countryGuide(country, data.repository, SOURCE, { base: ORIGIN }).trim());
    }
  });

  it('starts with what an assistant must read first', async () => {
    const agents = await readFile(join(repoRootDir(), 'AGENTS.md'), 'utf8');
    expect(LLMS_FULL[0]).toBe('agents');
    expect(agents).toMatch(/## What you must never do/);
    expect(full.indexOf('What you must never do')).toBeLessThan(full.indexOf('## Commands'));
  });
});

describe('the guide of a country', () => {
  it('carries its own command, its own codes and the professional who should check it', () => {
    for (const country of data.countries) {
      const guide = countryGuide(country, data.repository, SOURCE);
      expect(guide).toContain(`${data.repository.installCommand} --country ${country.country}\n`);
      if (country.invoicing.salesAccount !== null) expect(guide).toContain(`account=${country.invoicing.salesAccount}`);
      for (const tax of country.invoicing.saleTaxes) expect(guide).toContain(`\`${tax.code}\``);
      expect(guide).toContain(`qualified professional in ${country.name}`);
      // A choice the installer refuses to make without a terminal is on the scripted line.
      if (country.charts.length > 1) expect(guide).toContain('--chart ');
      if (country.languages.length > 1) expect(guide).toContain('--language ');
      if (country.fiscalYearDefault === null) expect(guide).toContain('--fiscal-year-start YYYY-MM-DD \\');
    }
  });

  it('is shown on the set-up page, which links to its Markdown', () => {
    const pages = renderPages(data);
    for (const country of data.countries) {
      const page = pages.find((p) => p.url === setUpUrl(country));
      expect(page?.body).toContain(`href="${guideMarkdownUrl(country)}"`);
      expect(page?.body).toContain('ekwo post invoice-1 --dry-run');
    }
  });
});

describe('what no file served to a model says', () => {
  it('never calls Ekwo an accounting service, a pack certified, or a return compliant', () => {
    for (const { file, text } of llmsFiles(data, SOURCE, ORIGIN)) {
      if (file === LLMS_FULL_TXT) continue; // carries the repository's own files, checked where they are written
      expect(text, file).not.toMatch(/(?<!not )\b(an|the|our) accounting service\b/i);
      expect(text, file).not.toMatch(/certified by Ekwo|Ekwo[- ]certified/i);
      expect(text, file).not.toMatch(/\bguarantee[sd]? (compliance|that)\b/i);
    }
    expect(llmsFiles(data, SOURCE).map((f) => f.file)).toContain(LLMS_TXT);
  });
});
