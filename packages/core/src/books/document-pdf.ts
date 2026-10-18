/**
 * The PDF of a sale invoice or credit note, for every surface at once.
 *
 * The command line (`ekwo doc pdf`) and the MCP server (`render_invoice_pdf`)
 * call this with their own `Backend`, acting as the person signed in. It reads
 * the four views a document is printed from — `document_header`,
 * `document_line_items`, `document_tax_summary`, `document_legal_mentions` —
 * and hands the rows to `@ekwo-ai/invoice-pdf`, which renders them and knows
 * nothing of a database. Here is what only a client can do: read the views,
 * fetch the logo the company names by URL, apply the accent colour and the
 * side of the logo the company chose, and, when asked, write the CII of
 * the same document with the Factur-X adapter of the e-invoicing formats and
 * embed it, so that the PDF is a Factur-X invoice.
 *
 * Nothing is recorded. A posted document reproduces from the books; the copy
 * that was sent to a customer is another thing, and keeping it is not done
 * here.
 */

import { embedFacturX } from '@ekwo-ai/factur-x/pdf';
import {
  InvoicePdfError,
  renderFacturXPdf,
  renderInvoicePdf,
  type DocumentHeaderRow,
  type DocumentLegalMentionRow,
  type DocumentLineRow,
  type DocumentTaxRow,
  type FiscalQr,
  type InvoiceLabels,
  type InvoicePdfInput,
  type InvoiceTheme,
  type PageSize,
} from '@ekwo-ai/invoice-pdf';
import { EINVOICE_FORMATS, type EinvoiceViolation } from '../einvoicing/formats.js';
import type { FiscalRegime } from '../einvoicing/fiscalisation.js';
import { readEinvoiceSource } from '../einvoicing/issue.js';
import { BooksError, type Backend, type Row } from './backend.js';
import { onlyVisible } from './shared.js';

/** Every column of `document_header`, dates and figures as the text the database holds. */
const HEADER = [
  'document_id', 'company_id', 'doc_type', 'state', 'payment_state', 'number', 'supplier_reference',
  'document_date::text', 'accounting_date::text', 'due_date::text', 'delivery_date::text', 'currency_code',
  'amount_untaxed::text', 'amount_tax::text', 'amount_total::text', 'amount_paid::text', 'amount_residual::text',
  'payment_terms', 'payment_means_code', 'payment_reference', 'buyer_reference', 'order_reference',
  'contract_reference', 'project_reference', 'note', 'payee_iban', 'payee_bic',
  'seller_name', 'seller_legal_name', 'seller_legal_form', 'seller_vat_number', 'seller_registration_number',
  'seller_address_line1', 'seller_address_line2', 'seller_postal_code', 'seller_city', 'seller_country',
  'seller_region', 'seller_email', 'seller_phone', 'seller_website', 'seller_logo_url',
  'seller_share_capital::text', 'seller_share_capital_currency', 'seller_activity_code', 'seller_activity_scheme',
  'document_template',
  'buyer_id', 'buyer_name', 'buyer_vat_number', 'buyer_registration_number', 'buyer_address_line1',
  'buyer_address_line2', 'buyer_postal_code', 'buyer_city', 'buyer_country', 'buyer_region', 'buyer_email',
  'country', 'number_format', 'numbering_gapless', 'legal_payment_days', 'late_payment_reference', 'tax_point_rule',
  'einvoice_profile', 'einvoice_mandatory_from::text', 'party_scheme', 'vat_scheme',
  'language', 'tax_point_date::text', 'delivery_address_line1', 'delivery_postal_code', 'delivery_city',
  'delivery_country', 'seller_peppol_scheme', 'seller_peppol_identifier', 'buyer_peppol_scheme',
  'buyer_peppol_identifier',
];

/** Every column of `document_line_items`. */
const LINES = [
  'document_line_id', 'document_id', 'company_id', 'sequence', 'line_type', 'item_name', 'item_description',
  'seller_item_identifier', 'product_id', 'product_kind', 'quantity::text', 'unit_code', 'unit_price::text',
  'discount_percent::text', 'amount_untaxed::text', 'tax_id', 'vat_category', 'vat_rate::text', 'account_id',
  'tax_treatment', 'tax_exemption_code', 'tax_cash_basis', 'unit_price_includes_tax', 'amount_incl_tax::text',
];

/** Every column of `document_tax_summary`. */
const TAXES = [
  'document_id', 'company_id', 'doc_type', 'tax_id', 'tax_code', 'tax_name', 'vat_category', 'tax_rate::text',
  'base_amount::text', 'tax_amount::text', 'tax_charged::text', 'exemption_code', 'exemption_reason',
  'legal_reference',
];

/** Every column of `document_legal_mentions`. */
const MENTIONS = [
  'document_id', 'company_id', 'country', 'code', 'applies_when', 'language', 'text', 'text_i18n', 'sequence',
  'legal_reference',
];

/** The four views of one document. */
export async function readDocumentForPdf(
  backend: Backend,
  documentId: string,
): Promise<Omit<InvoicePdfInput, 'logo'>> {
  const header = onlyVisible(
    await backend.select<Row>({
      table: 'document_header',
      columns: HEADER,
      where: [{ column: 'document_id', op: 'eq', value: documentId }],
    }),
    `document ${documentId}`,
  );
  const where = [{ column: 'document_id', op: 'eq' as const, value: documentId }];
  const [lines, taxes, mentions] = await Promise.all([
    backend.select<Row>({ table: 'document_line_items', columns: LINES, where, order: [{ column: 'sequence' }] }),
    backend.select<Row>({ table: 'document_tax_summary', columns: TAXES, where, order: [{ column: 'tax_code' }] }),
    backend.select<Row>({
      table: 'document_legal_mentions',
      columns: MENTIONS,
      where,
      order: [{ column: 'sequence' }, { column: 'code' }],
    }),
  ]);
  return {
    header: header as unknown as DocumentHeaderRow,
    lines: lines as unknown as DocumentLineRow[],
    taxes: taxes as unknown as DocumentTaxRow[],
    mentions: mentions as unknown as DocumentLegalMentionRow[],
  };
}

/**
 * The accent colour and the side of the logo the company chose, as the
 * brick's theme; a column left null keeps the brick's default.
 */
export async function readInvoiceTheme(backend: Backend, companyId: string): Promise<InvoiceTheme> {
  const [company] = await backend.select<Row>({
    table: 'companies',
    columns: ['invoice_accent_color', 'invoice_logo_position'],
    where: [{ column: 'id', op: 'eq', value: companyId }],
  });
  const accent = company?.['invoice_accent_color'];
  const side = company?.['invoice_logo_position'];
  return {
    ...(typeof accent === 'string' ? { accent } : {}),
    ...(side === 'left' || side === 'right' ? { logoPosition: side } : {}),
  };
}

/**
 * The fiscal QR code of a document, or why it has none. Its country's regime
 * is read as the socle compiled it from the pack, in `country_defaults`; the
 * URL is the one the brick wrote into the document's last record of kind
 * `alta` in `einvoicing.fiscal_chain`; the size is the smallest the regime
 * allows, the quiet zone the one it recommends. Nothing is made up: without a
 * record there is no URL, and the PDF is rendered without a code.
 */
export async function readFiscalQr(
  backend: Backend,
  documentId: string,
  country: string | null,
): Promise<{ qr: FiscalQr } | { skipped: string }> {
  if (country === null) return { skipped: 'none' };
  const [defaults] = await backend.select<{ einvoice_fiscalisation: FiscalRegime | null }>({
    table: 'country_defaults',
    columns: ['einvoice_fiscalisation'],
    where: [{ column: 'country', op: 'eq', value: country }],
  });
  const regime = defaults?.einvoice_fiscalisation ?? null;
  if (regime === null || regime.qr === null || regime.qr === undefined) return { skipped: 'none' };
  const modules = await backend
    .select<{ code: string; status: string }>({ table: 'modules', columns: ['code', 'status'], where: [{ column: 'code', op: 'eq', value: 'einvoicing' }] })
    .catch(() => []);
  if (!modules.some((row) => row.status !== 'draft')) {
    return { skipped: 'the country prints a fiscal QR code, and the einvoicing module that keeps the records is not installed here' };
  }
  const [record] = await backend.select<{ verification_url: string | null; mode: string }>({
    schema: 'einvoicing',
    table: 'fiscal_chain',
    columns: ['verification_url', 'mode'],
    where: [
      { column: 'document_id', op: 'eq', value: documentId },
      { column: 'kind', op: 'eq', value: 'alta' },
    ],
    order: [{ column: 'seq', ascending: false }],
    limit: 1,
  });
  if (record === undefined || record.verification_url === null) {
    return { skipped: 'no fiscal record yet: einvoicing_fiscalise (ekwo einvoice fiscalise) chains one, and its QR code is printed from then on' };
  }
  const level = regime.qr.error_correction;
  if (level !== 'L' && level !== 'M' && level !== 'Q' && level !== 'H') {
    throw new BooksError(`invoice_pdf_unrenderable: the country pack asks for a QR code at error correction level ${level}, which is not L, M, Q or H.`);
  }
  const quiet = regime.qr.quiet_zone_mm;
  return {
    qr: {
      content: record.verification_url,
      errorCorrection: level,
      sizeMm: regime.qr.size_mm.min,
      quietZoneMm: quiet === null ? null : (quiet.recommended ?? quiet.min),
      label: regime.qr.label,
      mention: regime.mention.find((mention) => mention.modes.includes(record.mode as never))?.text ?? null,
    },
  };
}

/** What a logo fetch may be handed: the global `fetch`, or a test's. */
export type LogoFetch = (url: string, init: { signal: AbortSignal; redirect: 'follow' | 'error' }) => Promise<{
  ok: boolean;
  status: number;
  arrayBuffer(): Promise<ArrayBuffer>;
}>;

const LOGO_MAX_BYTES = 2 * 1024 * 1024;
const LOGO_TIMEOUT_MS = 10_000;

/**
 * Why a logo URL is not fetched, or null when it may be. Only `http` and
 * `https`, and never a host that names this machine or a private network: the
 * URL is a value a member of the company typed, and the server that fetches it
 * may be somebody else's.
 */
export function logoUrlRefusal(url: string): string | null {
  let parsed: URL;
  try {
    parsed = new URL(url);
  } catch {
    return 'it is not a URL';
  }
  if (parsed.protocol !== 'https:' && parsed.protocol !== 'http:') return `${parsed.protocol} is not http or https`;
  const host = parsed.hostname.toLowerCase().replace(/^\[|\]$/g, '');
  if (host === 'localhost' || host.endsWith('.localhost') || host.endsWith('.local') || host.endsWith('.internal')) {
    return `${host} is a local name`;
  }
  const v4 = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/.exec(host);
  if (v4 !== null) {
    const [a, b] = [Number(v4[1]), Number(v4[2])];
    if (a === 0 || a === 10 || a === 127 || (a === 169 && b === 254) || (a === 172 && b >= 16 && b <= 31) || (a === 192 && b === 168) || (a === 100 && b >= 64 && b <= 127)) {
      return `${host} is a private or local address`;
    }
  }
  if (host.includes(':') && (host === '::1' || host === '::' || /^f[cd]/.test(host) || /^fe[89ab]/.test(host) || host.startsWith('::ffff:'))) {
    return `${host} is a private or local address`;
  }
  return null;
}

/**
 * The bytes of the logo at `url`, or why there are none. A logo that cannot be
 * had is not a reason to refuse an invoice: the PDF is rendered with the
 * company's name instead, and the reason is said.
 */
export async function fetchLogo(url: string, fetchImpl: LogoFetch): Promise<{ bytes: Uint8Array } | { skipped: string }> {
  const refusal = logoUrlRefusal(url);
  if (refusal !== null) return { skipped: `the logo URL is not fetched: ${refusal}` };
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), LOGO_TIMEOUT_MS);
  try {
    const response = await fetchImpl(url, { signal: controller.signal, redirect: 'error' });
    if (!response.ok) return { skipped: `the logo URL answered ${response.status}` };
    const bytes = new Uint8Array(await response.arrayBuffer());
    if (bytes.byteLength > LOGO_MAX_BYTES) return { skipped: `the logo is ${bytes.byteLength} bytes, over ${LOGO_MAX_BYTES}` };
    const png = bytes[0] === 0x89 && bytes[1] === 0x50 && bytes[2] === 0x4e && bytes[3] === 0x47;
    const jpeg = bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff;
    if (!png && !jpeg) return { skipped: 'the logo is neither a PNG nor a JPEG' };
    return { bytes };
  } catch (error) {
    return { skipped: `the logo could not be fetched: ${error instanceof Error ? error.message : String(error)}` };
  } finally {
    clearTimeout(timer);
  }
}

export interface DocumentPdfArgs {
  document_id: string;
  /** Embed the CII of the document (Factur-X, EN 16931 profile): the PDF becomes a PDF/A-3 Factur-X invoice. */
  factur_x?: boolean | undefined;
  page_size?: PageSize | undefined;
  /** The words of the layout in the document's language; what is left out is English. */
  labels?: Partial<InvoiceLabels> | undefined;
}

export interface DocumentPdf {
  document_id: string;
  doc_type: string;
  number: string | null;
  state: string | null;
  language: string | null;
  filename: string;
  title: string;
  media_type: 'application/pdf';
  byte_size: number;
  page_count: number;
  /** `embedded`, `none` (the company names no logo), or why the one it names was not used. */
  logo: string;
  /** `printed`, `none` (the country's regime prints no QR code, or it has none), or why the one it asks for is not there. */
  fiscal_qr: string;
  /** Null without --factur-x; otherwise the rules of EN 16931 the embedded XML breaks, as the e-invoicing adapter names them. */
  factur_x: { profile: 'en16931'; violations: EinvoiceViolation[] } | null;
  file: Uint8Array;
}

/**
 * Renders the PDF of a sale invoice or credit note from the views, and
 * records nothing. With `factur_x`, the document must be a posted sale: the
 * CII is written from the books by the same adapter `einvoicing` uses, its
 * broken rules are returned, and the XML is embedded all the same — a check
 * that found something, which the caller reports.
 */
export async function renderDocumentPdf(
  backend: Backend,
  args: DocumentPdfArgs,
  deps: { fetch?: LogoFetch | undefined } = {},
): Promise<DocumentPdf> {
  const input: InvoicePdfInput = await readDocumentForPdf(backend, args.document_id);
  const { header } = input;

  let logo = 'none';
  const url = typeof header.seller_logo_url === 'string' ? header.seller_logo_url.trim() : '';
  if (url !== '') {
    if (deps.fetch === undefined) logo = 'the logo URL is not fetched: no fetch was given';
    else {
      const fetched = await fetchLogo(url, deps.fetch);
      if ('bytes' in fetched) {
        input.logo = fetched.bytes;
        logo = 'embedded';
      } else logo = fetched.skipped;
    }
  }

  const fiscal = await readFiscalQr(backend, args.document_id, typeof header.country === 'string' ? header.country : null);
  if ('qr' in fiscal) input.fiscalQr = fiscal.qr;

  const options = {
    theme: await readInvoiceTheme(backend, String(header.company_id)),
    ...(args.page_size === undefined ? {} : { pageSize: args.page_size }),
    ...(args.labels === undefined ? {} : { labels: args.labels }),
    producer: '@ekwo-ai/core',
  };

  let factur: DocumentPdf['factur_x'] = null;
  let rendered;
  try {
    if (args.factur_x === true) {
      if (header.state !== 'posted') {
        throw new BooksError(
          `document_not_posted: ${String(header.doc_type)} ${String(header.number ?? args.document_id)} is ${String(header.state)}, and a Factur-X invoice is written from a posted document only.`,
          { hint: 'post_document (ekwo post <document>) books it; without --factur-x the PDF of a draft is rendered and titled as one.' },
        );
      }
      const format = EINVOICE_FORMATS['factur-x-en16931'];
      if (format === undefined) throw new BooksError('format_without_brick: no brick writes factur-x-en16931 in this release.');
      const written = format.write(await readEinvoiceSource(backend, args.document_id));
      factur = { profile: 'en16931', violations: written.violations };
      rendered = await renderFacturXPdf(input, { ...options, xml: written.content, profile: 'en16931', embed: embedFacturX });
    } else {
      rendered = await renderInvoicePdf(input, options);
    }
  } catch (error) {
    if (error instanceof InvoicePdfError) {
      throw new BooksError(`invoice_pdf_unrenderable: ${error.message}`);
    }
    throw error;
  }

  return {
    document_id: args.document_id,
    doc_type: String(header.doc_type),
    number: (header.number as string | null | undefined) ?? null,
    state: (header.state as string | null | undefined) ?? null,
    language: (header.language as string | null | undefined) ?? null,
    filename: rendered.filename,
    title: rendered.title,
    media_type: 'application/pdf',
    byte_size: rendered.file.byteLength,
    page_count: rendered.pageCount,
    logo,
    fiscal_qr: 'qr' in fiscal ? 'printed' : fiscal.skipped,
    factur_x: factur,
    file: rendered.file,
  };
}
