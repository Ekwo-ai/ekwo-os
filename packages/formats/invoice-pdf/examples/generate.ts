/**
 * Writes the two sample PDFs of this directory from the fixtures of the test
 * suite: an English invoice with a logo, and a Greek one with Greek words for
 * the layout. Every name and number in them is invented.
 *
 *   npm run examples
 */

import { writeFile } from 'node:fs/promises';
import { renderInvoicePdf } from '../src/index.js';
import { englishInvoice, GREEK_LABELS, greekInvoice, pngLogo } from '../test/fixtures.js';

const date = new Date('2026-03-31T12:00:00Z');

const english = await renderInvoicePdf(englishInvoice({ logo: pngLogo() }), { date });
await writeFile(new URL('./invoice-english.pdf', import.meta.url), english.file);

const greek = await renderInvoicePdf(greekInvoice(), { labels: GREEK_LABELS, date });
await writeFile(new URL('./invoice-greek.pdf', import.meta.url), greek.file);

console.log(`invoice-english.pdf: ${english.pageCount} page(s), ${english.file.byteLength} bytes`);
console.log(`invoice-greek.pdf: ${greek.pageCount} page(s), ${greek.file.byteLength} bytes`);
