/**
 * The visual invoice, carrying its Factur-X XML.
 *
 * This package does not import `@ekwo-ai/factur-x`: a brick depends on no
 * other brick, so that each can be taken alone. The caller hands over the
 * function that does the embedding — `embedFacturX` of
 * `@ekwo-ai/factur-x/pdf`, or any function of the same shape — and the CII XML
 * it wrote for the same document. The PDF is rendered here, then given to it
 * unchanged.
 *
 * What makes the rendered PDF acceptable to it: every font is embedded (as a
 * subset), nothing is drawn with transparency, the colours are DeviceRGB under
 * an sRGB output intent, and the trailer carries an identifier. The embedding
 * adds the XML, the PDF/A-3 declaration and its XMP packet. No validator of
 * PDF/A is run here.
 */

import { renderInvoicePdf } from './render.js';
import type { InvoicePdfInput, InvoicePdfOptions, RenderedInvoicePdf } from './types.js';

/** The Factur-X profiles, under the names `@ekwo-ai/factur-x` gives them. */
export type FacturXProfile = 'minimum' | 'basic-wl' | 'basic' | 'en16931' | 'extended';

/** The shape of `embedFacturX` of `@ekwo-ai/factur-x/pdf`. */
export type EmbedFacturX = (
  pdf: Uint8Array,
  xml: string,
  options: { profile?: FacturXProfile; title?: string; creator?: string; producer?: string; date?: Date },
) => Promise<Uint8Array>;

export interface FacturXPdfOptions extends InvoicePdfOptions {
  /** The CII XML of the same document. */
  xml: string;
  /** The guideline the XML was written to. Defaults to `en16931`. */
  profile?: FacturXProfile;
  /** `embedFacturX` of `@ekwo-ai/factur-x/pdf`. */
  embed: EmbedFacturX;
}

/** Renders the PDF and hands it, with the XML, to `options.embed`. The result is a PDF/A-3 with its CII inside. */
export async function renderFacturXPdf(input: InvoicePdfInput, options: FacturXPdfOptions): Promise<RenderedInvoicePdf> {
  const { xml, profile, embed, ...rest } = options;
  const rendered = await renderInvoicePdf(input, rest);
  const file = await embed(rendered.file, xml, {
    profile: profile ?? 'en16931',
    title: rendered.title,
    creator: '@ekwo-ai/invoice-pdf',
    producer: options.producer ?? '@ekwo-ai/invoice-pdf',
    ...(options.date === undefined ? {} : { date: options.date }),
  });
  return { ...rendered, file };
}
