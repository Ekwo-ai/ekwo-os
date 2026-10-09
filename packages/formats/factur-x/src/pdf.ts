/**
 * PDF side of Factur-X: attach the CII XML to a PDF as `factur-x.xml` with
 * `AFRelationship /Alternative`, declare the document as PDF/A-3 in XMP, and
 * read the XML back from an existing Factur-X / ZUGFeRD file, and read the
 * invoice it holds (`readFacturX`).
 *
 * Only this module depends on `pdf-lib`; import it from `@ekwo-ai/factur-x/pdf`.
 */
import {
  AFRelationship,
  PDFArray,
  PDFDict,
  PDFDocument,
  PDFHexString,
  PDFName,
  PDFRawStream,
  PDFString,
  decodePDFRawStream,
} from 'pdf-lib';
import { type ReceivedCiiFile, readCii } from './cii-read.js';
import { InvoiceFileError } from './errors.js';
import type { ReadOptions } from './received.js';
import type { Profile } from './types.js';
import { buildXmpMetadata } from './xmp.js';

export const FACTURX_FILENAME = 'factur-x.xml';
/** File name used by ZUGFeRD 2.x documents; accepted when reading. */
export const ZUGFERD_FILENAME = 'zugferd-invoice.xml';
/** File name ZUGFeRD 2.1 and later give the XML of their XRECHNUNG profile; accepted when reading. */
export const XRECHNUNG_FILENAME = 'xrechnung.xml';

export interface EmbedOptions {
  /** Defaults to `"basic"`. Must match the guideline used for the XML. */
  profile?: Profile;
  title?: string;
  creator?: string;
  producer?: string;
  /** Timestamp for the attachment and the XMP packet. Defaults to now. */
  date?: Date;
}

/**
 * Returns a copy of `pdf` carrying `xml` as `factur-x.xml`.
 *
 * The visual PDF itself is left untouched: fonts, colour profiles and output
 * intents are the responsibility of the producer of the original file. Strict
 * PDF/A-3 validators may still flag those; the invoice data is embedded and
 * readable, which is what e-invoicing platforms check.
 */
export async function embedFacturX(
  pdf: Uint8Array | ArrayBuffer,
  xml: string,
  options: EmbedOptions = {},
): Promise<Uint8Array> {
  const profile = options.profile ?? 'basic';
  const date = options.date ?? new Date();
  const doc = await PDFDocument.load(pdf, { updateMetadata: false });

  await doc.attach(new TextEncoder().encode(xml), FACTURX_FILENAME, {
    mimeType: 'text/xml',
    description: 'Factur-X invoice data (CII)',
    creationDate: date,
    modificationDate: date,
    afRelationship: AFRelationship.Alternative,
  });

  const xmp = new TextEncoder().encode(buildXmpMetadata({ profile, ...options, date }));
  const stream = doc.context.stream(xmp, { Type: 'Metadata', Subtype: 'XML', Length: xmp.length });
  doc.catalog.set(PDFName.of('Metadata'), doc.context.register(stream));

  if (options.title) doc.setTitle(options.title);
  if (options.creator) doc.setCreator(options.creator);
  doc.setProducer(options.producer ?? '@ekwo-ai/factur-x');
  doc.setModificationDate(date);

  return doc.save({ useObjectStreams: false });
}

export interface ExtractedInvoice {
  filename: string;
  xml: string;
}

const WANTED: ReadonlySet<string> = new Set([FACTURX_FILENAME, ZUGFERD_FILENAME, XRECHNUNG_FILENAME]);

/** The bytes of the first embedded file of the PDF whose name is one of {@link WANTED}. */
async function embeddedInvoice(pdf: Uint8Array | ArrayBuffer): Promise<{ filename: string; bytes: Uint8Array } | null> {
  const doc = await PDFDocument.load(pdf, { updateMetadata: false, ignoreEncryption: true });
  const names = doc.catalog.lookupMaybe(PDFName.of('Names'), PDFDict);
  const embedded = names?.lookupMaybe(PDFName.of('EmbeddedFiles'), PDFDict);
  if (!embedded) return null;

  for (const [name, spec] of walkNameTree(doc, embedded)) {
    if (!WANTED.has(name)) continue;
    const ef = spec.lookupMaybe(PDFName.of('EF'), PDFDict);
    const candidate = ef?.lookup(PDFName.of('UF')) ?? ef?.lookup(PDFName.of('F'));
    if (!(candidate instanceof PDFRawStream)) continue;
    return { filename: name, bytes: decodePDFRawStream(candidate).decode() };
  }
  return null;
}

/**
 * Reads the embedded invoice XML (`factur-x.xml`, `zugferd-invoice.xml` or
 * `xrechnung.xml`) from a PDF. Returns `null` when the file carries none.
 */
export async function extractFacturX(pdf: Uint8Array | ArrayBuffer): Promise<ExtractedInvoice | null> {
  const found = await embeddedInvoice(pdf);
  return found === null ? null : { filename: found.filename, xml: new TextDecoder('utf-8').decode(found.bytes) };
}

/** What {@link readFacturX} returns: the invoice read from the XML, and the name the XML was attached under. */
export interface ReceivedFacturX extends ReceivedCiiFile {
  /** `factur-x.xml`, `zugferd-invoice.xml` or `xrechnung.xml`. */
  filename: string;
}

/**
 * Reads a received Factur-X or ZUGFeRD PDF: finds the CII XML attached to it
 * and reads it with {@link readCii}, into the shape the UBL reader of
 * `@ekwo-ai/peppol-ubl` returns too. The PDF itself is the caller's already,
 * and is not returned again.
 *
 * Rejects with an {@link InvoiceFileError}: `too_large` for a file over
 * `maxBytes`, before it is opened; `not_a_pdf` for bytes `pdf-lib` cannot open
 * as a PDF; `no_embedded_invoice` for a PDF without the XML; and every code of
 * {@link readCii} for the XML. Nothing `pdf-lib` throws escapes as anything
 * else.
 */
export async function readFacturX(pdf: Uint8Array | ArrayBuffer, options: ReadOptions = {}): Promise<ReceivedFacturX> {
  const bytes = pdf instanceof Uint8Array ? pdf : new Uint8Array(pdf);
  const maxBytes = options.maxBytes ?? 64 * 1024 * 1024;
  if (bytes.byteLength > maxBytes) {
    throw new InvoiceFileError('too_large', `the file is ${bytes.byteLength} bytes, over the limit of ${maxBytes}`);
  }
  // A PDF opens with its %PDF- header (ISO 32000-1, 7.5.2), which readers
  // accept within the first kilobyte; asked here so that the refusal of a
  // file that is not one says so before anything is parsed.
  const head = new TextDecoder('latin1').decode(bytes.subarray(0, 1024));
  if (!head.includes('%PDF-')) {
    throw new InvoiceFileError('not_a_pdf', 'the file is not a PDF: it has no %PDF- header');
  }
  let found: { filename: string; bytes: Uint8Array } | null;
  try {
    found = await embeddedInvoice(bytes);
  } catch (error) {
    throw new InvoiceFileError(
      'not_a_pdf',
      `the PDF could not be opened: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
  if (found === null) {
    throw new InvoiceFileError(
      'no_embedded_invoice',
      `the PDF carries no ${[...WANTED].join(', ')}: it is not a Factur-X or ZUGFeRD invoice`,
    );
  }
  return { ...readCii(found.bytes, options), filename: found.filename };
}

/** Yields `[fileName, fileSpecification]` pairs of an EmbeddedFiles name tree. */
function* walkNameTree(doc: PDFDocument, node: PDFDict): Generator<[string, PDFDict]> {
  const names = node.lookupMaybe(PDFName.of('Names'), PDFArray);
  if (names) {
    for (let i = 0; i + 1 < names.size(); i += 2) {
      const spec = names.lookup(i + 1);
      if (!(spec instanceof PDFDict)) continue;
      const text = (o: unknown) => (o instanceof PDFString || o instanceof PDFHexString ? o.decodeText() : undefined);
      const name = text(spec.lookup(PDFName.of('UF'))) ?? text(spec.lookup(PDFName.of('F'))) ?? text(names.lookup(i)) ?? '';
      yield [name, spec];
    }
  }
  const kids = node.lookupMaybe(PDFName.of('Kids'), PDFArray);
  if (kids) {
    for (let i = 0; i < kids.size(); i++) {
      const kid = kids.lookupMaybe(i, PDFDict);
      if (kid) yield* walkNameTree(doc, kid);
    }
  }
}
