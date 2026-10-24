import { describe, expect, it } from 'vitest';
import { ENGLISH_LABELS, INVOICE_LABELS, labelsFor, renderInvoicePdf } from '../src/index.js';
import { englishHeader, englishInvoice, greekInvoice, GREEK_LABELS } from './fixtures.js';

const KEYS = Object.keys(ENGLISH_LABELS).sort();
const UNITS = Object.keys(ENGLISH_LABELS.units).sort();

describe('the sets of words, one per language', () => {
  it.each(Object.entries(INVOICE_LABELS))('%s has every key and every unit of the English set, and nothing more', (_, labels) => {
    expect(Object.keys(labels).sort()).toEqual(KEYS);
    expect(Object.keys(labels.units).sort()).toEqual(UNITS);
    for (const [key, word] of Object.entries(labels)) {
      if (key !== 'units') expect(typeof word === 'string' && word.trim() !== '', key).toBe(true);
    }
  });

  it.each(Object.entries(INVOICE_LABELS))('%s numbers the pages with {page} and {pages}', (_, labels) => {
    expect(labels.page).toContain('{page}');
    expect(labels.page).toContain('{pages}');
  });

  it('prints nothing after a count where English prints nothing', () => {
    for (const labels of Object.values(INVOICE_LABELS)) {
      for (const [code, unit] of Object.entries(ENGLISH_LABELS.units)) {
        if (unit === '') expect(labels.units[code], code).toBe('');
      }
    }
  });
});

describe('labelsFor', () => {
  it('takes the whole tag, then its language, then English, and says which', () => {
    const [language] = Object.keys(INVOICE_LABELS).filter((l) => l !== 'en');
    expect(language).toBeDefined();
    expect(labelsFor(language)).toEqual({ language, labels: INVOICE_LABELS[language as string] });
    expect(labelsFor(`${String(language).toUpperCase()}-ZZ`).language).toBe(language);
    expect(labelsFor(`${String(language)}_zz`).language).toBe(language);
    expect(labelsFor('el')).toEqual({ language: 'en', labels: ENGLISH_LABELS });
    expect(labelsFor(null)).toEqual({ language: 'en', labels: ENGLISH_LABELS });
    expect(labelsFor('')).toEqual({ language: 'en', labels: ENGLISH_LABELS });
  });
});

describe('a document is printed in the words of its language', () => {
  it.each(Object.entries(INVOICE_LABELS).filter(([l]) => l !== 'en'))('%s, without the caller passing any word', async (language, labels) => {
    const rendered = await renderInvoicePdf(englishInvoice({ header: englishHeader({ language }) }));
    const text = rendered.text.flat().join('\n');
    expect(rendered.labelsLanguage).toBe(language);
    expect(rendered.title.startsWith(labels.invoice)).toBe(true);
    for (const key of ['billTo', 'dueDate', 'description', 'taxSummary', 'amountDue'] as const) {
      expect(text, key).toContain(labels[key]);
      if (labels[key] !== ENGLISH_LABELS[key]) expect(text, key).not.toContain(ENGLISH_LABELS[key]);
    }
    expect(text).toContain(labels.page.replace('{page}', '1').replace('{pages}', '1'));
  });

  it('takes the caller’s words over the set of the language', async () => {
    const [language] = Object.keys(INVOICE_LABELS).filter((l) => l !== 'en');
    const rendered = await renderInvoicePdf(englishInvoice({ header: englishHeader({ language }) }), { labels: { amountDue: 'Left to pay, in our words' } });
    const text = rendered.text.flat().join('\n');
    expect(text).toContain('Left to pay, in our words');
    expect(text).toContain(INVOICE_LABELS[language as string]?.billTo);
  });

  it('follows options.locale over the language of the document', async () => {
    const rendered = await renderInvoicePdf(englishInvoice({ header: englishHeader({ language: 'el' }) }), { locale: 'en-GB' });
    expect(rendered.labelsLanguage).toBe('en');
  });

  it('prints in English, and says so, where the package has no set for the language', async () => {
    const rendered = await renderInvoicePdf(greekInvoice(), { labels: GREEK_LABELS });
    expect(rendered.labelsLanguage).toBe('en');
    expect(rendered.text.flat()).toContain(ENGLISH_LABELS.deliveryDate);
  });
});
