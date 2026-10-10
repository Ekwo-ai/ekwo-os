/**
 * Writes the sample PDFs of this directory from the fixtures of the test
 * suite: an English invoice with a logo, a Greek one with Greek words for the
 * layout, and the English one again as Factur-X, its CII inside. Every name
 * and number in them is invented.
 *
 *   npm run examples
 */

import { writeFile } from 'node:fs/promises';
import { generateCiiXml } from '@ekwo-ai/factur-x';
import { embedFacturX } from '@ekwo-ai/factur-x/pdf';
import { renderFacturXPdf, renderInvoicePdf } from '../src/index.js';
import { englishCii, englishInvoice, GREEK_LABELS, greekInvoice, pngLogo } from '../test/fixtures.js';

const date = new Date('2026-03-31T12:00:00Z');

const english = await renderInvoicePdf(englishInvoice({ logo: pngLogo() }), { date });
await writeFile(new URL('./invoice-english.pdf', import.meta.url), english.file);

const greek = await renderInvoicePdf(greekInvoice(), { labels: GREEK_LABELS, date });
await writeFile(new URL('./invoice-greek.pdf', import.meta.url), greek.file);

const xml = generateCiiXml(englishCii(), { profile: 'en16931' });
const facturX = await renderFacturXPdf(englishInvoice({ logo: pngLogo() }), { xml, profile: 'en16931', embed: embedFacturX, date });
await writeFile(new URL('./invoice-english-factur-x.pdf', import.meta.url), facturX.file);

for (const [name, rendered] of [
  ['invoice-english.pdf', english],
  ['invoice-greek.pdf', greek],
  ['invoice-english-factur-x.pdf', facturX],
] as const) {
  console.log(`${name}: ${rendered.pageCount} page(s), ${rendered.file.byteLength} bytes`);
}
