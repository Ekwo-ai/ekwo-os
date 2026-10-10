/**
 * The layout: one sober page design, A4 or Letter, as many pages as the lines
 * need, in the colour, typeface and logo position of the theme.
 *
 * Top of the first page, the seller — its logo, left or right, and its name —
 * and the title, the number, the dates and the references, closed by a rule
 * of the accent colour; under them the buyer and, where the goods went
 * elsewhere, the delivery address, each on a shaded panel. Then the lines,
 * under a band of column headings repeated on every page they run onto; the
 * tax summary, one row per tax as the books grouped it, with the sentence that
 * says why a group charges nothing; the totals, ending on a band with what is
 * still due, and beside them how to pay, framed; the note; and the legal
 * mentions the country requires, as the books gave them. Every page carries
 * the seller's identity and its number at the foot.
 *
 * Nothing printed is computed here. Every figure is a column of a view,
 * formatted by `Intl`; every sentence is a label of the caller or a row of the
 * books.
 */

import { PDFDocument, rgb, type PDFPage, type RGB } from 'pdf-lib';
import { prepareForArchive } from './archive.js';
import { InvoicePdfError } from './errors.js';
import { decimal, formatterFor, groupIban, isZero, type Formatter } from './format.js';
import { labelsWith } from './labels.js';
import { embedLogo } from './logo.js';
import { clean, refuseRightToLeft, typesetter, type Typesetter } from './text.js';
import { INK, resolveTheme } from './theme.js';
import type {
  DocumentHeaderRow,
  InvoiceLabels,
  InvoicePdfInput,
  InvoicePdfOptions,
  PageSize,
  RenderedInvoicePdf,
} from './types.js';

const SIZES: Record<PageSize, [number, number]> = { A4: [595.28, 841.89], Letter: [612, 792] };
const MARGIN = 48;

const MUTED = rgb(0.38, 0.38, 0.42);
const RULE = rgb(0.78, 0.78, 0.8);
const SHADE = rgb(0.94, 0.94, 0.95);

const BODY = 9;
const SMALL = 7.5;
const LEADING = 1.38;

const text = (value: unknown): string | null => {
  if (value === null || value === undefined) return null;
  const out = clean(String(value)).trim();
  return out === '' ? null : out;
};

interface Style {
  size?: number;
  bold?: boolean;
  color?: RGB;
}

/** Pages, a cursor running down them, and every string drawn on each. */
class Canvas {
  readonly pages: PDFPage[] = [];
  readonly drawn: string[][] = [];
  /** The page drawn on: the last one, except while the feet are drawn on every page at the end. */
  current = -1;
  y = 0;
  bottom = MARGIN;
  /** Drawn at the top of every page after the first: the table header of the lines, while they run. */
  continuation: (() => Promise<void>) | null = null;

  constructor(
    readonly doc: PDFDocument,
    readonly ts: Typesetter,
    readonly width: number,
    readonly height: number,
  ) {}

  get page(): PDFPage {
    const page = this.pages[this.current];
    if (page === undefined) throw new Error('no page');
    return page;
  }

  get left(): number {
    return MARGIN;
  }

  get right(): number {
    return this.width - MARGIN;
  }

  async newPage(): Promise<void> {
    this.pages.push(this.doc.addPage([this.width, this.height]));
    this.drawn.push([]);
    this.current = this.pages.length - 1;
    this.y = this.height - MARGIN;
    if (this.pages.length > 1 && this.continuation !== null) await this.continuation();
  }

  /** Room for `height` more points on this page, or a new page. */
  async ensure(height: number): Promise<void> {
    if (this.y - height < this.bottom) await this.newPage();
  }

  /** One line of text whose baseline is `baseline`, starting at `x` — or ending there, right-aligned. */
  async text(value: string, x: number, baseline: number, style: Style = {}, align: 'left' | 'right' = 'left'): Promise<number> {
    const size = style.size ?? BODY;
    const bold = style.bold ?? false;
    const runs = await this.ts.runs(value, bold);
    let width = 0;
    for (const run of runs) width += run.font.widthOfTextAtSize(run.text, size);
    let cursor = align === 'right' ? x - width : x;
    for (const run of runs) {
      this.page.drawText(run.text, { x: cursor, y: baseline, size, font: run.font, color: style.color ?? INK });
      cursor += run.font.widthOfTextAtSize(run.text, size);
    }
    if (value !== '') this.drawn[this.current]?.push(value);
    return width;
  }

  rule(y: number, from = this.left, to = this.right, color = RULE, thickness = 0.5): void {
    this.page.drawLine({ start: { x: from, y }, end: { x: to, y }, thickness, color });
  }

  shade(x: number, y: number, width: number, height: number, color: RGB = SHADE): void {
    this.page.drawRectangle({ x, y, width, height, color });
  }

  frame(x: number, y: number, width: number, height: number): void {
    this.page.drawRectangle({ x, y, width, height, borderColor: RULE, borderWidth: 0.6 });
  }
}

const lineHeight = (size: number): number => size * LEADING;

/** A block of lines, drawn from the cursor down; returns the height used. */
async function paragraph(
  canvas: Canvas,
  lines: readonly string[],
  x: number,
  top: number,
  style: Style = {},
): Promise<number> {
  const size = style.size ?? BODY;
  let y = top;
  for (const line of lines) {
    y -= lineHeight(size);
    await canvas.text(line, x, y + size * 0.28, style);
  }
  return top - y;
}

function titleOf(header: DocumentHeaderRow, labels: InvoiceLabels): string {
  const credit = header.doc_type === 'sale_credit_note';
  if (header.state === 'draft') return credit ? labels.draftCreditNote : labels.draftInvoice;
  return credit ? labels.creditNote : labels.invoice;
}

function filenameOf(header: DocumentHeaderRow): string {
  const kind = header.doc_type === 'sale_credit_note' ? 'credit-note' : 'invoice';
  const number = text(header.number);
  const safe = (number ?? '').replace(/[^\p{L}\p{N}._-]+/gu, '-').replace(/^-+|-+$/g, '');
  if (header.state === 'draft' || safe === '') return `draft-${kind}.pdf`;
  return `${kind}-${safe}.pdf`;
}

/** The lines of an address, in the order a letter is addressed, and the country by its name. */
function addressLines(
  f: Formatter,
  line1: unknown,
  line2: unknown,
  postalCode: unknown,
  city: unknown,
  region: unknown,
  country: unknown,
): string[] {
  const out: string[] = [];
  for (const value of [line1, line2]) {
    const t = text(value);
    if (t !== null) out.push(t);
  }
  const place = [text(postalCode), text(city)].filter((v): v is string => v !== null).join(' ');
  if (place !== '') out.push(place);
  const r = text(region);
  if (r !== null) out.push(r);
  const c = text(country);
  if (c !== null) out.push(f.country(c));
  return out;
}

function required(value: unknown, what: string): string {
  const t = text(value);
  if (t === null) throw new InvoicePdfError('missing_field', `the document has no ${what}`);
  return t;
}

/** Every string the document would print, refused at once if one of them reads right to left. */
function refuseRightToLeftAnywhere(input: InvoicePdfInput, labels: InvoiceLabels): void {
  const check = (value: unknown, where: string): void => {
    if (typeof value === 'string') refuseRightToLeft(value, where);
  };
  for (const [key, value] of Object.entries(input.header)) check(value, `document_header.${key}`);
  input.lines.forEach((line, i) => {
    for (const [key, value] of Object.entries(line)) check(value, `document_line_items[${i}].${key}`);
  });
  input.taxes.forEach((tax, i) => {
    for (const [key, value] of Object.entries(tax)) check(value, `document_tax_summary[${i}].${key}`);
  });
  (input.mentions ?? []).forEach((mention, i) => check(mention.text, `document_legal_mentions[${i}].text`));
  for (const [key, value] of Object.entries(labels)) check(value, `labels.${key}`);
}

interface Column {
  title: string;
  width: number;
  align: 'left' | 'right';
}

/**
 * Renders the PDF of a sale invoice or a sale credit note from the rows of
 * the four views. Refuses, with an {@link InvoicePdfError}, what it cannot
 * print honestly: another kind of document, a missing currency, a figure that
 * is not a decimal, a character no font has, text written right to left.
 */
export async function renderInvoicePdf(input: InvoicePdfInput, options: InvoicePdfOptions = {}): Promise<RenderedInvoicePdf> {
  const { header } = input;
  if (header.doc_type !== 'sale_invoice' && header.doc_type !== 'sale_credit_note') {
    throw new InvoicePdfError(
      'not_a_sale_document',
      `a ${String(header.doc_type)} is not a sale invoice or a sale credit note, which are what this package renders`,
    );
  }
  const labels = labelsWith(options.labels);
  refuseRightToLeftAnywhere(input, labels);

  const currency = required(header.currency_code, 'currency');
  const documentDate = required(header.document_date, 'date');
  const locale = options.locale ?? text(header.language) ?? 'en';
  const f = formatterFor(locale, currency);
  const amount = (value: unknown, what: string): string | null => {
    const d = decimal(value as string | null, what);
    return d === null ? null : f.amount(d);
  };
  const untaxed = amount(header.amount_untaxed, 'amount_untaxed');
  const tax = amount(header.amount_tax, 'amount_tax');
  const total = amount(header.amount_total, 'amount_total');
  if (untaxed === null || tax === null || total === null) {
    throw new InvoicePdfError('missing_field', 'the document has no total: amount_untaxed, amount_tax and amount_total are required');
  }

  // Unit prices may carry more decimals than the currency has; they are printed with all of them.
  const minor = new Intl.NumberFormat(f.locale, { style: 'currency', currency }).resolvedOptions().minimumFractionDigits ?? 2;
  const unitPriceFormats = new Map<number, Intl.NumberFormat>();
  const unitPrice = (value: string): string => {
    const decimals = Math.min(10, (value.split('.')[1] ?? '').replace(/0+$/, '').length);
    const digits = Math.max(minor, decimals);
    let format = unitPriceFormats.get(digits);
    if (format === undefined) {
      format = new Intl.NumberFormat(f.locale, { style: 'currency', currency, minimumFractionDigits: minor, maximumFractionDigits: digits });
      unitPriceFormats.set(digits, format);
    }
    return format.format(value as unknown as number);
  };

  const title = titleOf(header, labels);
  const number = header.state === 'draft' ? null : text(header.number);
  const fullTitle = number === null ? title : `${title} ${number}`;

  const theme = resolveTheme(options.theme);
  const doc = await PDFDocument.create();
  const seller = text(header.seller_legal_name) ?? text(header.seller_name);
  prepareForArchive(
    doc,
    {
      title: fullTitle,
      author: seller,
      subject: fullTitle,
      creator: '@ekwo-ai/invoice-pdf',
      producer: options.producer ?? '@ekwo-ai/invoice-pdf',
      date: options.date ?? new Date(),
    },
    f.locale,
    `${fullTitle}|${documentDate}|${text(header.document_id) ?? ''}`,
  );

  const ts = typesetter(doc, options.fonts ?? [], f.locale, theme.font);
  const [width, height] = SIZES[options.pageSize ?? 'A4'];
  const canvas = new Canvas(doc, ts, width, height);
  const contentWidth = canvas.right - canvas.left;

  // --- the foot of every page, measured first: it decides where the content stops
  const footParts = [
    seller,
    text(header.seller_legal_form),
    (() => {
      const capital = decimal(header.seller_share_capital as string | null, 'seller_share_capital');
      if (capital === null) return null;
      const capitalCurrency = text(header.seller_share_capital_currency) ?? currency;
      return `${labels.shareCapital} ${formatterFor(f.locale, capitalCurrency).amount(capital)}`;
    })(),
    text(header.seller_registration_number) === null ? null : `${labels.registrationNumber} ${text(header.seller_registration_number)}`,
    text(header.seller_vat_number) === null ? null : `${labels.vatNumber} ${text(header.seller_vat_number)}`,
  ].filter((v): v is string => v !== null);
  const footLines = await ts.wrap(footParts.join(' · '), SMALL, contentWidth - 90, false);
  canvas.bottom = MARGIN + footLines.length * lineHeight(SMALL) + 14;

  await canvas.newPage();

  // --- the seller, the title, the dates and references
  const leftWidth = contentWidth * 0.55;
  const rightWidth = contentWidth * 0.4;
  let leftY = canvas.y;
  let rightY = canvas.y;
  const logo = input.logo === undefined || input.logo === null ? null : await embedLogo(doc, input.logo);
  const sellerName = text(header.seller_name);
  if (logo !== null) {
    const scale = Math.min(170 / logo.width, 60 / logo.height, 1);
    const w = logo.width * scale;
    const h = logo.height * scale;
    if (theme.logoPosition === 'right') {
      canvas.page.drawImage(logo, { x: canvas.right - w, y: rightY - h, width: w, height: h });
      rightY -= h + 8;
    } else {
      canvas.page.drawImage(logo, { x: canvas.left, y: leftY - h, width: w, height: h });
      leftY -= h + 8;
    }
  }
  // Beside a logo the name is a line of the address; alone, it stands for the logo.
  const nameSize = logo !== null && theme.logoPosition === 'left' ? 11 : 16;
  if (sellerName !== null) {
    leftY -= await paragraph(canvas, await ts.wrap(sellerName, nameSize, leftWidth, true), canvas.left, leftY, { size: nameSize, bold: true });
  }
  const sellerLines: string[] = [];
  const legal = [text(header.seller_legal_name), text(header.seller_legal_form)].filter((v): v is string => v !== null).join(' ');
  if (legal !== '' && text(header.seller_legal_name) !== sellerName) sellerLines.push(legal);
  sellerLines.push(
    ...addressLines(f, header.seller_address_line1, header.seller_address_line2, header.seller_postal_code, header.seller_city, header.seller_region, header.seller_country),
  );
  for (const [label, value] of [
    [labels.vatNumber, header.seller_vat_number],
    [labels.registrationNumber, header.seller_registration_number],
    [labels.email, header.seller_email],
    [labels.phone, header.seller_phone],
    [labels.website, header.seller_website],
  ] as const) {
    const t = text(value);
    if (t !== null) sellerLines.push(`${label}: ${t}`);
  }
  const sellerScheme = text(header.seller_peppol_scheme);
  const sellerEndpoint = text(header.seller_peppol_identifier);
  if (sellerScheme !== null && sellerEndpoint !== null) sellerLines.push(`${labels.electronicAddress}: ${sellerScheme}:${sellerEndpoint}`);
  const wrappedSeller: string[] = [];
  for (const line of sellerLines) wrappedSeller.push(...(await ts.wrap(line, 8.5, leftWidth, false)));
  leftY -= 2 + (await paragraph(canvas, wrappedSeller, canvas.left, leftY - 2, { size: 8.5, color: MUTED }));

  const rightX = canvas.right - rightWidth;
  for (const line of await ts.wrap(title, 18, rightWidth, true)) {
    rightY -= lineHeight(18);
    await canvas.text(line, canvas.right, rightY + 5, { size: 18, bold: true, color: theme.accent }, 'right');
  }
  if (header.state === 'cancelled') {
    rightY -= lineHeight(10);
    await canvas.text(labels.cancelled, canvas.right, rightY + 3, { size: 10, bold: true, color: rgb(0.62, 0.12, 0.12) }, 'right');
  }
  rightY -= 6;
  const credit = header.doc_type === 'sale_credit_note';
  const meta: [string, string | null][] = [
    [labels.number, number],
    [labels.date, f.date(documentDate)],
    [labels.dueDate, text(header.due_date) === null || credit ? null : f.date(text(header.due_date) as string)],
    [labels.deliveryDate, text(header.delivery_date) === null ? null : f.date(text(header.delivery_date) as string)],
    [labels.taxPointDate, text(header.tax_point_date) === null ? null : f.date(text(header.tax_point_date) as string)],
    [labels.buyerReference, text(header.buyer_reference)],
    [labels.orderReference, text(header.order_reference)],
    [labels.contractReference, text(header.contract_reference)],
    [labels.projectReference, text(header.project_reference)],
    [labels.supplierReference, text(header.supplier_reference)],
  ];
  for (const [label, value] of meta) {
    if (value === null) continue;
    const valueLines = await ts.wrap(value, BODY, rightWidth * 0.58, true);
    for (const [i, line] of valueLines.entries()) {
      rightY -= lineHeight(BODY);
      if (i === 0) await canvas.text(label, rightX, rightY + 2.5, { color: MUTED });
      await canvas.text(line, canvas.right, rightY + 2.5, { bold: true }, 'right');
    }
  }
  canvas.y = Math.min(leftY, rightY) - 10;
  canvas.rule(canvas.y, canvas.left, canvas.right, theme.accent, 0.8);
  canvas.y -= 12;

  // --- the buyer, and where the goods went: each on a shaded panel, side by side
  const panelPad = 8;
  const partyWidth = contentWidth * 0.48;
  const partyText = partyWidth - 2 * panelPad;
  const buyerLines: string[] = addressLines(
    f,
    header.buyer_address_line1,
    header.buyer_address_line2,
    header.buyer_postal_code,
    header.buyer_city,
    header.buyer_region,
    header.buyer_country,
  );
  for (const [label, value] of [
    [labels.vatNumber, header.buyer_vat_number],
    [labels.registrationNumber, header.buyer_registration_number],
    [labels.email, header.buyer_email],
  ] as const) {
    const t = text(value);
    if (t !== null) buyerLines.push(`${label}: ${t}`);
  }
  const buyerScheme = text(header.buyer_peppol_scheme);
  const buyerEndpoint = text(header.buyer_peppol_identifier);
  if (buyerScheme !== null && buyerEndpoint !== null) buyerLines.push(`${labels.electronicAddress}: ${buyerScheme}:${buyerEndpoint}`);
  const delivery = addressLines(f, header.delivery_address_line1, null, header.delivery_postal_code, header.delivery_city, null, header.delivery_country);

  /** A party: its heading, its name in bold, its lines — measured, so that the panel is drawn under them first. */
  const party = async (heading: string, name: string | null, lines: readonly string[]): Promise<[string[], string[], string[]]> => {
    const wrapped: string[] = [];
    for (const line of lines) wrapped.push(...(await ts.wrap(line, BODY, partyText, false)));
    return [[heading], name === null ? [] : await ts.wrap(name, 10.5, partyText, true), wrapped];
  };
  const panels = [await party(labels.billTo, text(header.buyer_name), buyerLines)];
  if (delivery.length > 0) panels.push(await party(labels.deliverTo, null, delivery));
  const panelHeight =
    Math.max(...panels.map(([h, n, l]) => h.length * lineHeight(SMALL) + n.length * lineHeight(10.5) + l.length * lineHeight(BODY))) + 2 * panelPad;
  for (const [i, [heading, name, lines]] of panels.entries()) {
    const x = canvas.left + i * (contentWidth - partyWidth);
    canvas.shade(x, canvas.y - panelHeight, partyWidth, panelHeight);
    let y = canvas.y - panelPad;
    y -= await paragraph(canvas, heading, x + panelPad, y, { size: SMALL, bold: true, color: MUTED });
    y -= await paragraph(canvas, name, x + panelPad, y, { size: 10.5, bold: true });
    await paragraph(canvas, lines, x + panelPad, y);
  }
  canvas.y -= panelHeight + 16;

  // --- the lines
  const products = input.lines.filter((l) => (text(l.line_type) ?? 'product') === 'product');
  const anyDiscount = products.some((l) => {
    const d = decimal(l.discount_percent ?? null, 'discount_percent');
    return d !== null && !isZero(d);
  });
  const anyGross = products.some((l) => l.unit_price_includes_tax === true);
  const columns: Column[] = [
    { title: labels.description, width: 0, align: 'left' },
    { title: labels.quantity, width: 62, align: 'right' },
    { title: labels.unitPrice, width: 72, align: 'right' },
    ...(anyDiscount ? [{ title: labels.discount, width: 48, align: 'right' as const }] : []),
    { title: labels.taxRate, width: 46, align: 'right' },
    { title: labels.amount, width: 78, align: 'right' },
  ];
  const fixed = columns.slice(1).reduce((sum, c) => sum + c.width, 0);
  (columns[0] as Column).width = contentWidth - fixed;
  const pad = 5;
  const headerHeight = 18;

  // The headings of a table on a band of the accent colour.
  const headingStyle: Style = { size: SMALL, bold: true, color: theme.onAccent };
  const tableHeader = async (): Promise<void> => {
    canvas.shade(canvas.left, canvas.y - headerHeight, contentWidth, headerHeight, theme.accent);
    let x = canvas.left;
    for (const column of columns) {
      const lines = await ts.wrap(column.title, SMALL, column.width - 2 * pad, true);
      const label = lines[0] ?? '';
      await canvas.text(label, column.align === 'right' ? x + column.width - pad : x + pad, canvas.y - headerHeight + 6, headingStyle, column.align);
      x += column.width;
    }
    canvas.y -= headerHeight + 2;
  };
  const continuationHeading = async (): Promise<void> => {
    await canvas.text(fullTitle, canvas.left, canvas.y - BODY, { bold: true });
    canvas.y -= lineHeight(BODY) + 10;
  };

  await canvas.ensure(headerHeight + 40);
  await tableHeader();
  canvas.continuation = async () => {
    await continuationHeading();
    await tableHeader();
  };

  const descWidth = (columns[0] as Column).width - 2 * pad;
  for (const [index, line] of input.lines.entries()) {
    const kind = text(line.line_type) ?? 'product';
    const name = text(line.item_name) ?? '';
    if (kind === 'section' || kind === 'note') {
      const lines = await ts.wrap(kind === 'note' ? [name, text(line.item_description)].filter(Boolean).join('\n') : name, BODY, contentWidth - 2 * pad, kind === 'section');
      const style: Style = kind === 'section' ? { bold: true } : { color: MUTED };
      for (const l of lines) {
        await canvas.ensure(lineHeight(BODY) + 4);
        canvas.y -= lineHeight(BODY);
        await canvas.text(l, canvas.left + pad, canvas.y + 3, style);
      }
      canvas.y -= 4;
      continue;
    }
    const where = `document_line_items[${index}]`;
    const nameLines = await ts.wrap(name, BODY, descWidth, false);
    const detail = [text(line.seller_item_identifier), text(line.item_description)].filter((v): v is string => v !== null).join(' · ');
    const detailLines = detail === '' ? [] : await ts.wrap(detail, 8, descWidth, false);

    const quantity = decimal(line.quantity ?? null, `${where}.quantity`);
    const unit = text(line.unit_code);
    const unitLabel = unit === null ? '' : labels.units[unit.toUpperCase()] ?? unit;
    const price = decimal(line.unit_price ?? null, `${where}.unit_price`);
    const discount = decimal(line.discount_percent ?? null, `${where}.discount_percent`);
    const rate = decimal(line.vat_rate ?? null, `${where}.vat_rate`);
    const lineAmount = decimal(line.amount_untaxed ?? null, `${where}.amount_untaxed`);
    const cells = [
      quantity === null ? '' : `${f.quantity(quantity)}${unitLabel === '' ? '' : ` ${unitLabel}`}`,
      price === null ? '' : `${unitPrice(price)}${line.unit_price_includes_tax === true ? ' *' : ''}`,
      ...(anyDiscount ? [discount === null || isZero(discount) ? '' : f.rate(discount)] : []),
      rate === null ? '' : f.rate(rate),
      lineAmount === null ? '' : f.amount(lineAmount),
    ];
    const rowHeight = nameLines.length * lineHeight(BODY) + detailLines.length * lineHeight(8) + 7;
    // A row that does not fit on any page is split between its lines; otherwise it moves whole.
    if (rowHeight < canvas.height - MARGIN - canvas.bottom - 80) await canvas.ensure(rowHeight);
    canvas.y -= 3;
    for (const [i, l] of nameLines.entries()) {
      await canvas.ensure(lineHeight(BODY));
      canvas.y -= lineHeight(BODY);
      await canvas.text(l, canvas.left + pad, canvas.y + 2.5);
      if (i > 0) continue;
      let x = canvas.left + (columns[0] as Column).width;
      for (const [c, cell] of cells.entries()) {
        const column = columns[c + 1] as Column;
        if (cell !== '') await canvas.text(cell, x + column.width - pad, canvas.y + 2.5, {}, 'right');
        x += column.width;
      }
    }
    for (const l of detailLines) {
      await canvas.ensure(lineHeight(8));
      canvas.y -= lineHeight(8);
      await canvas.text(l, canvas.left + pad, canvas.y + 2, { size: 8, color: MUTED });
    }
    canvas.y -= 4;
    canvas.rule(canvas.y);
  }
  canvas.continuation = null;
  if (anyGross) {
    await canvas.ensure(lineHeight(SMALL) + 2);
    canvas.y -= lineHeight(SMALL);
    await canvas.text(`* ${labels.priceIncludesTax}`, canvas.left + pad, canvas.y + 2, { size: SMALL, color: MUTED });
  }
  canvas.y -= 10;

  // --- the tax summary, one row per tax as the books grouped it
  const groups: { name: string; rate: string; base: string; charged: string; reason: string }[] = [];
  for (const [index, row] of input.taxes.entries()) {
    const where = `document_tax_summary[${index}]`;
    const base = decimal(row.base_amount, `${where}.base_amount`);
    const charged = decimal(row.tax_charged, `${where}.tax_charged`);
    if (base === null || charged === null) throw new InvoicePdfError('missing_field', `${where} has no base_amount or tax_charged`);
    const rate = decimal(row.tax_rate ?? null, `${where}.tax_rate`);
    groups.push({
      name: text(row.tax_name) ?? text(row.tax_code) ?? text(row.vat_category) ?? '',
      rate: rate === null ? '' : f.rate(rate),
      base: f.amount(base),
      charged: f.amount(charged),
      reason: text(row.exemption_reason) ?? '',
    });
  }
  if (groups.length > 0) {
    const numberWidth = 90;
    const nameWidth = contentWidth - 3 * numberWidth;
    await canvas.ensure(lineHeight(BODY) + headerHeight + 30);
    canvas.y -= lineHeight(BODY);
    await canvas.text(labels.taxSummary, canvas.left, canvas.y + 2.5, { bold: true });
    canvas.y -= 4;
    canvas.shade(canvas.left, canvas.y - headerHeight, contentWidth, headerHeight, theme.accent);
    let x = canvas.left + nameWidth;
    for (const label of [labels.taxRate, labels.taxBase, labels.taxCharged]) {
      await canvas.text(label, x + numberWidth - pad, canvas.y - headerHeight + 6, headingStyle, 'right');
      x += numberWidth;
    }
    canvas.y -= headerHeight;
    for (const group of groups) {
      const names = await ts.wrap(group.name, BODY, nameWidth - 2 * pad, false);
      const reasons = group.reason === '' ? [] : await ts.wrap(group.reason, SMALL, contentWidth - 2 * pad, false);
      await canvas.ensure(names.length * lineHeight(BODY) + Math.min(reasons.length, 2) * lineHeight(SMALL) + 6);
      canvas.y -= 2;
      for (const [i, name] of names.entries()) {
        canvas.y -= lineHeight(BODY);
        await canvas.text(name, canvas.left + pad, canvas.y + 2.5);
        if (i > 0) continue;
        let cx = canvas.left + nameWidth;
        for (const value of [group.rate, group.base, group.charged]) {
          if (value !== '') await canvas.text(value, cx + numberWidth - pad, canvas.y + 2.5, {}, 'right');
          cx += numberWidth;
        }
      }
      for (const reason of reasons) {
        await canvas.ensure(lineHeight(SMALL));
        canvas.y -= lineHeight(SMALL);
        await canvas.text(reason, canvas.left + pad, canvas.y + 2, { size: SMALL, color: MUTED });
      }
      canvas.y -= 4;
      canvas.rule(canvas.y);
    }
    canvas.y -= 10;
  }

  // --- the totals and what is still due, on the right; how to pay, in a framed panel on their left
  const paid = decimal(header.amount_paid ?? null, 'amount_paid');
  const residual = decimal(header.amount_residual ?? null, 'amount_residual');
  const totals: [string, string, boolean][] = [
    [labels.totalUntaxed, untaxed, false],
    [labels.totalTax, tax, false],
    [labels.total, total, true],
  ];
  if (paid !== null && !isZero(paid)) totals.push([labels.amountPaid, f.amount(paid), false]);
  const totalsWidth = 230;
  const totalsX = canvas.right - totalsWidth;
  const totalsHeight = totals.length * lineHeight(10) + (residual === null ? 0 : 30);

  const payment: string[] = [];
  const paymentWidth = contentWidth - totalsWidth - 16;
  if (!credit) {
    for (const [label, value] of [
      [labels.paymentTerms, text(header.payment_terms)],
      [labels.dueDate, text(header.due_date) === null ? null : f.date(text(header.due_date) as string)],
      [labels.iban, text(header.payee_iban) === null ? null : groupIban(text(header.payee_iban) as string)],
      [labels.bic, text(header.payee_bic)],
      [labels.paymentReference, text(header.payment_reference)],
    ] as const) {
      if (value !== null) payment.push(...(await ts.wrap(`${label}: ${value}`, BODY, paymentWidth - 2 * panelPad, false)));
    }
  }
  const panel = payment.length === 0 ? 0 : lineHeight(BODY) * (payment.length + 1) + 2 + 2 * panelPad;
  // A panel taller than a page would be cut: its lines then flow under the totals instead.
  const framed = panel > 0 && panel < canvas.height - MARGIN - canvas.bottom - 80;

  await canvas.ensure(Math.max(totalsHeight, framed ? panel : 0) + 10);
  const top = canvas.y;
  if (framed) {
    canvas.frame(canvas.left, top - panel, paymentWidth, panel);
    let y = top - panelPad;
    y -= 2 + (await paragraph(canvas, [labels.payment], canvas.left + panelPad, y, { bold: true }));
    await paragraph(canvas, payment, canvas.left + panelPad, y);
  }
  for (const [label, value, strong] of totals) {
    canvas.y -= lineHeight(10);
    if (strong) canvas.rule(canvas.y + lineHeight(10) - 1, totalsX, canvas.right, INK, 0.6);
    await canvas.text(label, totalsX + pad, canvas.y + 3, { size: strong ? 10 : BODY, bold: strong, color: strong ? INK : MUTED });
    await canvas.text(value, canvas.right - pad, canvas.y + 3, { size: strong ? 10 : BODY, bold: strong }, 'right');
  }
  if (residual !== null) {
    canvas.y -= 30;
    canvas.shade(totalsX, canvas.y, totalsWidth, 22, theme.accent);
    const due: Style = { size: 10.5, bold: true, color: theme.onAccent };
    await canvas.text(credit ? labels.amountCredited : labels.amountDue, totalsX + pad, canvas.y + 7.5, due);
    await canvas.text(f.amount(residual), canvas.right - pad, canvas.y + 7.5, due, 'right');
  }
  canvas.y = Math.min(canvas.y, framed ? top - panel : canvas.y) - 18;

  // --- the note and the mentions, and how to pay when it did not fit a panel: blocks of text that flow from page to page
  const flow = async (lines: readonly string[], style: Style = {}): Promise<void> => {
    const size = style.size ?? BODY;
    for (const l of lines) {
      await canvas.ensure(lineHeight(size));
      canvas.y -= lineHeight(size);
      await canvas.text(l, canvas.left, canvas.y + size * 0.28, style);
    }
  };
  const heading = async (label: string): Promise<void> => {
    await canvas.ensure(lineHeight(BODY) * 3);
    await flow([label], { bold: true });
    canvas.y -= 2;
  };

  if (payment.length > 0 && !framed) {
    await heading(labels.payment);
    await flow(payment);
    canvas.y -= 12;
  }

  const note = text(header.note);
  if (note !== null) {
    await heading(labels.note);
    await flow(await ts.wrap(note, BODY, contentWidth, false));
    canvas.y -= 12;
  }

  const mentions = [...(input.mentions ?? [])]
    .map((m, i) => ({ text: text(m.text), sequence: Number(m.sequence ?? 0), code: text(m.code) ?? '', i }))
    .filter((m): m is { text: string; sequence: number; code: string; i: number } => m.text !== null)
    .sort((a, b) => a.sequence - b.sequence || a.code.localeCompare(b.code) || a.i - b.i);
  if (mentions.length > 0) {
    await canvas.ensure(lineHeight(SMALL) * 2 + 8);
    canvas.rule(canvas.y);
    canvas.y -= 4;
    for (const mention of mentions) {
      await flow(await ts.wrap(mention.text, SMALL, contentWidth, false), { size: SMALL, color: MUTED });
      canvas.y -= 3;
    }
  }

  // --- the foot of every page
  const pageCount = canvas.pages.length;
  for (let i = 0; i < pageCount; i++) {
    canvas.current = i;
    const top = MARGIN + footLines.length * lineHeight(SMALL) + 4;
    canvas.rule(top);
    let y = top;
    for (const l of footLines) {
      y -= lineHeight(SMALL);
      await canvas.text(l, canvas.left, y + 2, { size: SMALL, color: MUTED });
    }
    const pageLabel = labels.page.replace('{page}', String(i + 1)).replace('{pages}', String(pageCount));
    await canvas.text(pageLabel, canvas.right, top - lineHeight(SMALL) + 2, { size: SMALL, color: MUTED }, 'right');
  }

  const file = await doc.save({ useObjectStreams: false });
  return { file, filename: filenameOf(header), title: fullTitle, pageCount, text: canvas.drawn };
}

