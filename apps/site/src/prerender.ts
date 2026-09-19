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

import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { readSiteData } from './data.js';
import { document, renderPages, robots, siteOrigin, sitemap } from './render.js';

const siteRoot = join(dirname(fileURLToPath(import.meta.url)), '..');
const outDir = join(siteRoot, 'dist');

const template = await readFile(join(outDir, 'index.html'), 'utf8');
const data = await readSiteData();
const pages = renderPages(data);

// Where the site is served from is the build's to say: a fork, a preview and
// the published site are three addresses. Unset, no page claims one.
const origin = siteOrigin(process.env['SITE_URL']);

for (const page of pages) {
  const path = join(outDir, page.file);
  await mkdir(dirname(path), { recursive: true });
  await writeFile(path, document(template, page, origin), 'utf8');
}

await writeFile(join(outDir, 'robots.txt'), robots(origin), 'utf8');
if (origin !== undefined) {
  await writeFile(join(outDir, 'sitemap.xml'), sitemap(pages, origin), 'utf8');
}

console.log(`${pages.length} pages written to ${outDir}${origin === undefined ? '' : `, served from ${origin}`}`);
