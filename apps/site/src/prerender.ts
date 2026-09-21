/**
 * The second half of the build: fill the template once per page and write it.
 *
 * It runs in Node, after `vite build` has compiled the stylesheet and written
 * `dist/index.html` with the fingerprinted link in it. That file is read back
 * as the template and then overwritten by the home page, which is why the
 * template is read before anything is written.
 *
 * It decides nothing. Which pages exist and what is on them is `renderPages()`;
 * this walks the list, makes the directories and writes the files.
 */

import { existsSync } from 'node:fs';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { readSiteData } from './data.js';
import { llmsFiles } from './llms.js';
import { document, renderPages, robots, siteOrigin, sitemap } from './render.js';
import { LANGUAGES } from './strings/index.js';

const siteRoot = join(dirname(fileURLToPath(import.meta.url)), '..');
const outDir = join(siteRoot, 'dist');

const template = await readFile(join(outDir, 'index.html'), 'utf8');
const data = await readSiteData();
const pages = renderPages(data);

// Where the site is served from is the build's to say: a fork, a preview and
// the published site are three addresses. Unset, no page claims one.
const origin = siteOrigin(process.env['SITE_URL']);

// What a model reads: llms.txt, llms-full.txt and each country's guide as
// Markdown, beside the pages they are made from (`llms.ts`).
// Written before the pages, so a page may ask whether they exist.
for (const strings of LANGUAGES) {
  for (const { file, text } of llmsFiles(data, strings, origin)) {
    const path = join(outDir, file);
    await mkdir(dirname(path), { recursive: true });
    await writeFile(path, text, 'utf8');
  }
}

// The summary for models is named in every head only once it is really there:
// Vite has copied `public/` into the output by now.
const llmsTxt = existsSync(join(outDir, 'llms.txt'));

for (const page of pages) {
  const path = join(outDir, page.file);
  await mkdir(dirname(path), { recursive: true });
  await writeFile(path, document(template, page, origin, { llmsTxt }), 'utf8');
}

await writeFile(join(outDir, 'robots.txt'), robots(origin), 'utf8');
if (origin !== undefined) {
  await writeFile(join(outDir, 'sitemap.xml'), sitemap(pages, origin), 'utf8');
}

console.log(`${pages.length} pages written to ${outDir}${origin === undefined ? '' : `, served from ${origin}`}`);
