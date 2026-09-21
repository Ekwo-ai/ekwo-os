/**
 * The site as a model reads it: `llms.txt`, `llms-full.txt`, and the guide of
 * each country as Markdown.
 *
 * `llms.txt` follows llmstxt.org: a title, a blockquote, a paragraph, then
 * lists of links under `##` headings, the last of them "Optional". It is an
 * index. `llms-full.txt` is the text: the articles of `LLMS_FULL`, whole and
 * as Markdown, then the set-up guide of every country.
 *
 * Nothing here is written for the occasion. The positioning is the first line
 * of `README.md`, the articles are the repository's files as `data.ts` read
 * them, the countries are `describePack()`, and the guides are `guide.ts` — the
 * text the set-up pages show. A pack added to `packs/` is in all three files
 * the next build, and a sentence changed in a README is too.
 *
 * `origin` is the build's (`SITE_URL`). Without one the links are paths, which
 * is right for a preview and still readable.
 */

import type { DocArticle, SiteData } from './data.js';
import { LLMS_FULL, LLMS_LEFT_OUT, LLMS_OPTIONAL, TOPICS } from './data/docs.js';
import { countryGuide, guideMarkdownUrl } from './guide.js';
import { descriptionOf, titleOf } from './pages/Docs.js';
import { fill, prefixOf, type Strings } from './strings/index.js';

/** The files this module writes, from the root of the output. */
export const LLMS_TXT = 'llms.txt';
export const LLMS_FULL_TXT = 'llms-full.txt';

/** One file of the output, as a path and its text. */
export interface TextFile {
  file: string;
  text: string;
}

/** Everything a model is served, for one language. */
export function llmsFiles(data: SiteData, strings: Strings, origin = ''): TextFile[] {
  const at = prefixOf(strings);
  return [
    { file: `${at}${LLMS_TXT}`, text: llmsTxt(data, strings, origin) },
    { file: `${at}${LLMS_FULL_TXT}`, text: llmsFullTxt(data, strings, origin) },
    ...data.countries.map((country) => ({
      file: `${at}${guideMarkdownUrl(country).slice(1)}`,
      text: countryGuide(country, data.repository, strings, { base: origin }),
    })),
  ];
}

/** The index. */
export function llmsTxt(data: SiteData, strings: Strings, origin = ''): string {
  const at = `${origin}/${prefixOf(strings)}`;
  const link = (article: DocArticle): string =>
    `- [${titleOf(article, strings)}](${origin}${article.url}): ${descriptionOf(article, strings)}`;
  // A format library is listed under its parent's article, not on its own.
  const listed = data.docs.filter((article) => article.parent === null && !LLMS_LEFT_OUT.includes(article.slug));

  const out: string[] = [
    '# Ekwo OS',
    '',
    `> ${plain(data.positioningMarkdown)}`,
    '',
    fill(strings.llms.about, {
      agents: `${at}docs/agents/`,
      repository: data.repository.url,
      full: `${at}${LLMS_FULL_TXT}`,
    }),
    '',
    `## ${strings.llms.countriesHeading}`,
    '',
    ...data.countries.map(
      (country) =>
        `- [${fill(strings.setup.guide.title, { country: country.name })}](${origin}${guideMarkdownUrl(country)}): ` +
        fill(strings.llms.country, {
          country: country.name,
          version: country.version,
          status: country.certification.status,
        }),
    ),
    '',
    `## ${strings.llms.docsHeading}`,
    '',
  ];
  const main = TOPICS.filter((topic) => !LLMS_OPTIONAL.includes(topic));
  for (const topic of main) out.push(...listed.filter((a) => a.topic === topic).map(link));
  out.push('', `## ${strings.llms.optionalHeading}`, '');
  for (const topic of LLMS_OPTIONAL) out.push(...listed.filter((a) => a.topic === topic).map(link));
  return `${out.join('\n')}\n`;
}

/** The text, whole. */
export function llmsFullTxt(data: SiteData, strings: Strings, origin = ''): string {
  const out: string[] = ['# Ekwo OS', '', fill(strings.llms.fullNote, { repository: data.repository.url }), ''];
  for (const slug of LLMS_FULL) {
    const article = data.docs.find((a) => a.slug === slug);
    if (article === undefined) throw new Error(`LLMS_FULL names "${slug}", which is not an article of the documentation`);
    out.push(
      '---',
      '',
      `# ${titleOf(article, strings)}`,
      '',
      fill(strings.llms.source, {
        file: data.repository.file(article.source),
        page: `${origin}${article.url}`,
      }),
      '',
      demote(article.markdown),
      '',
    );
  }
  for (const country of data.countries) {
    out.push('---', '', countryGuide(country, data.repository, strings, { base: origin }).trim(), '');
  }
  return `${out.join('\n').trim()}\n`;
}

/**
 * The positioning line without its Markdown links' targets kept inline: a
 * blockquote of llms.txt is one sentence, and a link there is noise.
 */
function plain(markdown: string): string {
  return markdown.replace(/\[([^\]]+)\]\([^)]+\)/g, '$1');
}

/**
 * Every heading one level down, outside code: each article sits under a `#`
 * of `llms-full.txt`, so its own `#` would read as a new article.
 */
function demote(markdown: string): string {
  let fenced = false;
  return markdown
    .split('\n')
    .map((line) => {
      if (/^(```|~~~)/.test(line)) fenced = !fenced;
      return !fenced && /^#{1,5} /.test(line) ? `#${line}` : line;
    })
    .join('\n');
}
