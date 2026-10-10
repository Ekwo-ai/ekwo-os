import { PDFDict, PDFDocument, PDFName, PDFRawStream } from 'pdf-lib';
import { describe, expect, it } from 'vitest';
import { ENGLISH_LABELS, InvoicePdfError, renderInvoicePdf, type InvoicePdfInput } from '../src/index.js';
import { englishHeader, englishInvoice, GREEK_LABELS, greekInvoice, longInvoice, pngLogo, thaiInvoice } from './fixtures.js';

const all = (text: string[][]): string => text.flat().join('\n');

/** The base names of the fonts the PDF embeds, and whether each carries its font file. */
async function fontsOf(file: Uint8Array): Promise<{ name: string; embedded: boolean }[]> {
  const doc = await PDFDocument.load(file);
  const out: { name: string; embedded: boolean }[] = [];
  for (const [, object] of doc.context.enumerateIndirectObjects()) {
    if (!(object instanceof PDFDict) || object.get(PDFName.of('Type')) !== PDFName.of('FontDescriptor')) continue;
    out.push({
      name: String(object.get(PDFName.of('FontName'))),
      embedded: object.lookup(PDFName.of('FontFile2')) instanceof PDFRawStream,
    });
  }
  return out;
}

async function imagesOf(file: Uint8Array): Promise<number> {
  const doc = await PDFDocument.load(file);
  let n = 0;
  for (const [, object] of doc.context.enumerateIndirectObjects()) {
    if (object instanceof PDFRawStream && object.dict.get(PDFName.of('Subtype')) === PDFName.of('Image')) n++;
  }
  return n;
}

async function refusal(run: () => Promise<unknown>): Promise<InvoicePdfError> {
  try {
    await run();
  } catch (error) {
    expect(error).toBeInstanceOf(InvoicePdfError);
    return error as InvoicePdfError;
  }
  throw new Error('expected a refusal');
}

const money = (locale: string, currency: string, value: string): string =>
  new Intl.NumberFormat(locale, { style: 'currency', currency }).format(value as unknown as number);
const day = (locale: string, iso: string): string =>
  new Intl.DateTimeFormat(locale, { dateStyle: 'medium', timeZone: 'UTC' }).format(new Date(`${iso}T00:00:00Z`));

describe('an English invoice', () => {
  it('prints the seller, the buyer, the lines, the taxes, the totals, the payment and the mentions, on one A4 page', async () => {
    const rendered = await renderInvoicePdf(englishInvoice());
    expect(rendered.pageCount).toBe(1);
    expect(rendered.filename).toBe('invoice-INV-2026-0042.pdf');
    expect(rendered.title).toBe('Invoice INV-2026-0042');
    const text = all(rendered.text);
    for (const expected of [
      'Invoice',
      'INV-2026-0042',
      'Example Consulting',
      'Fictional Customer GmbH',
      'Teststraße 10',
      'Consulting days',
      'Advisory work, March',
      'VAT 21%',
      '2 days',
      money('en', 'EUR', '950.00'),
      money('en', 'EUR', '2601.50'),
      day('en', '2026-03-31'),
      day('en', '2026-04-30'),
      'IBAN: IE29 AIBK 9311 5212 3456 78',
      'Electronic address: 9930:DE123456789',
      'Late payment interest is charged at the statutory rate.',
      'Page 1 of 1',
    ]) {
      expect(text).toContain(expected);
    }
    // The country by its name in the language of the document, from Intl.
    expect(text).toContain(new Intl.DisplayNames(['en'], { type: 'region' }).of('DE'));
    // The total due is the last line of the totals, and says so.
    expect(rendered.text[0]).toContain(ENGLISH_LABELS.amountDue);

    const doc = await PDFDocument.load(rendered.file);
    expect(doc.getPageCount()).toBe(1);
    expect(doc.getPage(0).getSize()).toEqual({ width: 595.28, height: 841.89 });
    expect(doc.getTitle()).toBe('Invoice INV-2026-0042');
    expect(doc.getAuthor()).toBe('Example Consulting Limited');
  });

  it('prints the mentions in their order, and the reason a tax group charges nothing under it', async () => {
    const input = englishInvoice({
      taxes: [
        { tax_name: 'Reverse charge', vat_category: 'AE', tax_rate: '0', base_amount: '2150.00', tax_charged: '0.00', exemption_reason: 'Reverse charge: the customer accounts for the tax.' },
      ],
    });
    const text = (await renderInvoicePdf(input)).text[0] ?? [];
    expect(text).toContain('Reverse charge: the customer accounts for the tax.');
    const first = text.indexOf('A mention the country requires on every invoice.');
    const second = text.indexOf('Late payment interest is charged at the statutory rate.');
    expect(first).toBeGreaterThan(-1);
    expect(second).toBeGreaterThan(first);
  });

  it('embeds every font it draws with, as a subset, and declares an sRGB output intent', async () => {
    const rendered = await renderInvoicePdf(englishInvoice());
    const fonts = await fontsOf(rendered.file);
    expect(fonts.length).toBeGreaterThan(0);
    for (const font of fonts) {
      expect(font.embedded, font.name).toBe(true);
      expect(font.name).toMatch(/^\/NotoSans/);
    }
    const doc = await PDFDocument.load(rendered.file);
    expect(doc.catalog.get(PDFName.of('OutputIntents'))).toBeDefined();
    // A subset: a page of text weighs kilobytes, not the megabyte of the fonts.
    expect(rendered.file.byteLength).toBeLessThan(120_000);
  });

  it('prints a logo when it is given one, and the name of the seller alone when it is not', async () => {
    const without = await renderInvoicePdf(englishInvoice());
    const withLogo = await renderInvoicePdf(englishInvoice({ logo: pngLogo() }));
    expect(await imagesOf(without.file)).toBe(0);
    expect(await imagesOf(withLogo.file)).toBe(1);
    expect(all(without.text)).toContain('Example Consulting');
    expect(all(withLogo.text)).toContain('Example Consulting');
  });

  it('refuses a logo that is neither a PNG nor a JPEG', async () => {
    const gif = new TextEncoder().encode('GIF89a not really');
    expect((await refusal(() => renderInvoicePdf(englishInvoice({ logo: gif })))).code).toBe('unsupported_logo');
  });

  it('lays out on Letter when asked', async () => {
    const rendered = await renderInvoicePdf(englishInvoice(), { pageSize: 'Letter' });
    expect((await PDFDocument.load(rendered.file)).getPage(0).getSize()).toEqual({ width: 612, height: 792 });
  });

  it('prints a unit through the labels, and the code itself when the labels have no word for it', async () => {
    const lines = englishInvoice().lines.map((l) => (l.item_name === 'Travel' ? { ...l, unit_code: 'XYZ' } : l));
    const text = all((await renderInvoicePdf(englishInvoice({ lines }), { labels: { units: { DAY: 'd' } } })).text);
    expect(text).toContain('2 d');
    expect(text).toContain('1 XYZ');
  });
});

describe('a credit note and a draft', () => {
  it('titles a credit note as one, ends on what is credited, and gives no payment instructions', async () => {
    const rendered = await renderInvoicePdf(
      englishInvoice({ header: englishHeader({ doc_type: 'sale_credit_note', number: 'CN-2026-0003' }) }),
    );
    const text = all(rendered.text);
    expect(rendered.filename).toBe('credit-note-CN-2026-0003.pdf');
    expect(rendered.title).toBe('Credit note CN-2026-0003');
    expect(text).toContain('Credit note');
    expect(text).toContain(ENGLISH_LABELS.amountCredited);
    expect(text).not.toContain(ENGLISH_LABELS.amountDue);
    expect(text).not.toContain('IBAN');
  });

  it('titles a draft as one, without a number', async () => {
    const rendered = await renderInvoicePdf(englishInvoice({ header: englishHeader({ state: 'draft', number: null }) }));
    expect(rendered.title).toBe('Draft invoice');
    expect(rendered.filename).toBe('draft-invoice.pdf');
  });

  it('says a cancelled document is cancelled', async () => {
    const rendered = await renderInvoicePdf(englishInvoice({ header: englishHeader({ state: 'cancelled' }) }));
    expect(rendered.text[0]).toContain(ENGLISH_LABELS.cancelled);
  });
});

describe('another language and another script', () => {
  it('writes a Greek invoice with the caller’s words, Intl’s amounts and dates, and English for the words not given', async () => {
    const rendered = await renderInvoicePdf(greekInvoice(), { labels: GREEK_LABELS });
    const text = all(rendered.text);
    for (const expected of [
      'Τιμολόγιο',
      'ΤΙΜ-2026-7',
      'Παράδειγμα Συμβουλευτική',
      'Φανταστικός Πελάτης Α.Ε.',
      'Ημέρες συμβουλευτικής',
      '2 ημέρες',
      'Σελίδα 1 από 1',
      money('el', 'EUR', '1900.00'),
      money('el', 'EUR', '2666.00'),
      day('el', '2026-03-31'),
      new Intl.DisplayNames(['el'], { type: 'region' }).of('GR') as string,
      ENGLISH_LABELS.deliveryDate,
    ]) {
      expect(text).toContain(expected);
    }
    expect(rendered.filename).toBe('invoice-ΤΙΜ-2026-7.pdf');
  });

  it('writes amounts with the minor units of the currency, whatever they are', async () => {
    const header = englishHeader({ currency_code: 'JPY', amount_untaxed: '2150', amount_tax: '215', amount_total: '2365', amount_residual: '2365' });
    const text = all((await renderInvoicePdf(englishInvoice({ header, taxes: [] }))).text);
    expect(text).toContain(money('en', 'JPY', '2365'));
    expect(text).not.toContain(`${money('en', 'JPY', '2365')}.00`);
  });

  it('draws Thai with the embedded Noto Sans Thai, beside Latin on the same page', async () => {
    const rendered = await renderInvoicePdf(thaiInvoice());
    expect(all(rendered.text)).toContain('บริษัท ลูกค้าสมมติ จำกัด');
    const names = (await fontsOf(rendered.file)).map((f) => f.name);
    expect(names.some((n) => n.includes('NotoSansThai'))).toBe(true);
    expect(names.some((n) => n.startsWith('/NotoSans-Regular'))).toBe(true);
  });

  it('refuses a character no font has, by name, rather than print an empty box', async () => {
    const input = englishInvoice({ header: englishHeader({ buyer_name: '株式会社テスト' }) });
    const error = await refusal(() => renderInvoicePdf(input));
    expect(error.code).toBe('glyph_not_covered');
    expect(error.message).toContain('U+682A');
  });

  it('refuses text written right to left rather than draw it reversed', async () => {
    const arabic = await refusal(() => renderInvoicePdf(englishInvoice({ header: englishHeader({ buyer_name: 'شركة تجريبية' }) })));
    expect(arabic.code).toBe('right_to_left_text');
    expect(arabic.message).toContain('document_header.buyer_name');
    const hebrew = await refusal(() => renderInvoicePdf(englishInvoice(), { labels: { invoice: 'חשבונית' } }));
    expect(hebrew.code).toBe('right_to_left_text');
    expect(hebrew.message).toContain('labels.invoice');
  });

  it('refuses a font of options.fonts it cannot read', async () => {
    const error = await refusal(() => renderInvoicePdf(englishInvoice(), { fonts: [{ regular: new Uint8Array([1, 2, 3, 4]) }] }));
    expect(error.code).toBe('unsupported_font');
  });
});

describe('a long invoice', () => {
  it('runs 200 lines onto several pages, repeats the column headings, and numbers every page', async () => {
    const rendered = await renderInvoicePdf(longInvoice(200));
    expect(rendered.pageCount).toBeGreaterThan(3);
    expect((await PDFDocument.load(rendered.file)).getPageCount()).toBe(rendered.pageCount);
    for (const [i, page] of rendered.text.entries()) {
      expect(page, `page ${i + 1}`).toContain(`Page ${i + 1} of ${rendered.pageCount}`);
      expect(page, `page ${i + 1}`).toContain(ENGLISH_LABELS.description);
    }
    // Every line, once, in its order.
    const items = rendered.text.flat().filter((t) => /^Item \d+$/.test(t));
    expect(items).toEqual(Array.from({ length: 200 }, (_, i) => `Item ${i + 1}`));
    // The totals come after the last line.
    const last = rendered.text[rendered.pageCount - 1] ?? [];
    expect(last.indexOf(ENGLISH_LABELS.amountDue)).toBeGreaterThan(last.indexOf('Item 200'));
  }, 60_000);

  it('wraps a long description inside its column', async () => {
    const long = 'word '.repeat(120).trim();
    const lines = [{ item_name: 'One line', item_description: long, quantity: '1', unit_price: '1.00', amount_untaxed: '1.00' }];
    const rendered = await renderInvoicePdf(englishInvoice({ lines }));
    const pieces = rendered.text.flat().filter((t) => /^(word ?)+$/.test(t));
    expect(pieces.length).toBeGreaterThan(3);
    expect(pieces.join(' ').split(' ').length).toBe(120);
  });
});

describe('what it refuses', () => {
  it('refuses a document a seller does not issue', async () => {
    const input: InvoicePdfInput = englishInvoice({ header: englishHeader({ doc_type: 'purchase_invoice' }) });
    expect((await refusal(() => renderInvoicePdf(input))).code).toBe('not_a_sale_document');
  });

  it('refuses a document without a currency, and a figure that is not a decimal', async () => {
    expect((await refusal(() => renderInvoicePdf(englishInvoice({ header: englishHeader({ currency_code: '' }) })))).code).toBe('missing_field');
    expect((await refusal(() => renderInvoicePdf(englishInvoice({ header: englishHeader({ amount_total: '12,50' }) })))).code).toBe('invalid_value');
  });

  it('refuses a language tag Intl does not accept', async () => {
    expect((await refusal(() => renderInvoicePdf(englishInvoice(), { locale: 'not a tag' }))).code).toBe('invalid_language');
  });
});
