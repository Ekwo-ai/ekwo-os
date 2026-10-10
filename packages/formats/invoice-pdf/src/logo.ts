/**
 * The logo: a PNG, or an RGB or grey JPEG, embedded opaque. A CMYK JPEG is
 * refused: the output intent of the file is sRGB, and says nothing of what
 * CMYK values mean.
 *
 * A PNG with an alpha channel is flattened on white — the page it is drawn on —
 * before it goes into the file: each pixel takes the colour it would show on
 * paper, and the soft mask is dropped. The logo looks the same, and the file
 * draws nothing transparent, which every PDF/A part accepts and which prints
 * the same on every printer.
 */

import { PDFName, PDFRawStream, PDFRef, decodePDFRawStream, type PDFDocument, type PDFImage } from 'pdf-lib';
import { InvoicePdfError } from './errors.js';

const bytesOf = (data: Uint8Array | ArrayBuffer): Uint8Array => (data instanceof Uint8Array ? data : new Uint8Array(data));

/** Replaces the image of `ref` and its soft mask by the same pixels laid on white. */
function flattenOnWhite(doc: PDFDocument, ref: PDFRef): void {
  const image = doc.context.lookup(ref);
  if (!(image instanceof PDFRawStream)) return;
  const maskRef = image.dict.get(PDFName.of('SMask'));
  if (!(maskRef instanceof PDFRef)) return;
  const mask = doc.context.lookup(maskRef);
  if (!(mask instanceof PDFRawStream)) return;
  // pdf-lib decodes every PNG to 8 bits a component: RGB here, one byte of alpha in the mask.
  const rgb = decodePDFRawStream(image).decode();
  const alpha = decodePDFRawStream(mask).decode();
  const flat = new Uint8Array(rgb.length);
  for (let pixel = 0; pixel < alpha.length; pixel++) {
    const a = alpha[pixel] as number;
    for (let c = 0; c < 3; c++) {
      const i = pixel * 3 + c;
      flat[i] = Math.round(((rgb[i] as number) * a + 255 * (255 - a)) / 255);
    }
  }
  const dict = image.dict;
  doc.context.assign(
    ref,
    doc.context.flateStream(flat, {
      Type: 'XObject',
      Subtype: 'Image',
      Width: dict.get(PDFName.of('Width')),
      Height: dict.get(PDFName.of('Height')),
      ColorSpace: 'DeviceRGB',
      BitsPerComponent: 8,
    }),
  );
  doc.context.delete(maskRef);
}

/** Embeds the logo, refusing what is neither a PNG nor an RGB or grey JPEG; a PNG's transparency is flattened on white. */
export async function embedLogo(doc: PDFDocument, logo: Uint8Array | ArrayBuffer): Promise<PDFImage> {
  const bytes = bytesOf(logo);
  const png = bytes[0] === 0x89 && bytes[1] === 0x50 && bytes[2] === 0x4e && bytes[3] === 0x47;
  const jpeg = bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff;
  if (!png && !jpeg) throw new InvoicePdfError('unsupported_logo', 'the logo is neither a PNG nor a JPEG');
  let image: PDFImage;
  try {
    image = png ? await doc.embedPng(bytes) : await doc.embedJpg(bytes);
    // Written into the file now, so that it can be looked at, and its mask replaced, before the file is saved.
    await image.embed();
  } catch (error) {
    throw new InvoicePdfError(
      'unsupported_logo',
      `the logo cannot be read as a ${png ? 'PNG' : 'JPEG'}: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
  const written = doc.context.lookup(image.ref);
  if (written instanceof PDFRawStream && written.dict.get(PDFName.of('ColorSpace')) === PDFName.of('DeviceCMYK')) {
    // The sRGB output intent of the file does not say what CMYK values mean.
    throw new InvoicePdfError('unsupported_logo', 'the logo is a CMYK JPEG; pass it as an RGB JPEG or a PNG');
  }
  if (png) flattenOnWhite(doc, image.ref);
  return image;
}
