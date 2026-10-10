/**
 * What PDF/A-3b asks of the file beyond what is drawn: a colour space saying
 * what DeviceRGB means (the output intent), an identifier in the trailer, the
 * language of the catalogue, and an XMP packet that declares the part and the
 * conformance level and says what the document information dictionary says.
 *
 * Everything drawn is already within it: every font embedded, colours in
 * DeviceRGB, no transparency (a logo's alpha channel is flattened on white
 * before it is embedded). veraPDF's PDF/A-3b profile finds no failed rule in
 * the examples of this package — see the README for the run.
 */

import { PDFHexString, PDFName, PDFString, type PDFDocument } from 'pdf-lib';
import SRGB_ICC from './fonts/srgb-icc.js';
import { decodeBase64 } from './text.js';

/** The entries of the document information dictionary, which the XMP repeats. */
export interface ArchiveInfo {
  title: string;
  author: string | null;
  subject: string;
  creator: string;
  producer: string;
  date: Date;
}

const escapeXml = (s: string): string =>
  s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

/** The XMP packet of a PDF/A-3b file whose information dictionary holds `info`. */
export function xmpPacket(info: ArchiveInfo): string {
  const date = info.date.toISOString();
  const alt = (value: string): string => `<rdf:Alt><rdf:li xml:lang="x-default">${escapeXml(value)}</rdf:li></rdf:Alt>`;
  const author = info.author === null ? '' : `\n      <dc:creator><rdf:Seq><rdf:li>${escapeXml(info.author)}</rdf:li></rdf:Seq></dc:creator>`;
  return `<?xpacket begin="\u{feff}" id="W5M0MpCehiHzreSzNTczkc9d"?>
<x:xmpmeta xmlns:x="adobe:ns:meta/">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about="" xmlns:pdfaid="http://www.aiim.org/pdfa/ns/id/">
      <pdfaid:part>3</pdfaid:part>
      <pdfaid:conformance>B</pdfaid:conformance>
    </rdf:Description>
    <rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
      <dc:format>application/pdf</dc:format>
      <dc:title>${alt(info.title)}</dc:title>${author}
      <dc:description>${alt(info.subject)}</dc:description>
    </rdf:Description>
    <rdf:Description rdf:about="" xmlns:pdf="http://ns.adobe.com/pdf/1.3/">
      <pdf:Producer>${escapeXml(info.producer)}</pdf:Producer>
    </rdf:Description>
    <rdf:Description rdf:about="" xmlns:xmp="http://ns.adobe.com/xap/1.0/">
      <xmp:CreatorTool>${escapeXml(info.creator)}</xmp:CreatorTool>
      <xmp:CreateDate>${date}</xmp:CreateDate>
      <xmp:ModifyDate>${date}</xmp:ModifyDate>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
<?xpacket end="w"?>`;
}

/**
 * Writes the information dictionary and its XMP twin, the sRGB output intent,
 * the language and a stable identifier into `doc`.
 */
export function prepareForArchive(doc: PDFDocument, info: ArchiveInfo, locale: string, seed: string): void {
  doc.setTitle(info.title, { showInWindowTitleBar: true });
  if (info.author !== null) doc.setAuthor(info.author);
  doc.setSubject(info.subject);
  doc.setCreator(info.creator);
  doc.setProducer(info.producer);
  doc.setCreationDate(info.date);
  doc.setModificationDate(info.date);
  doc.setLanguage(locale);

  const xmp = new TextEncoder().encode(xmpPacket(info));
  const metadata = doc.context.stream(xmp, { Type: 'Metadata', Subtype: 'XML', Length: xmp.length });
  doc.catalog.set(PDFName.of('Metadata'), doc.context.register(metadata));

  const icc = decodeBase64(SRGB_ICC);
  const profile = doc.context.register(doc.context.flateStream(icc, { N: 3 }));
  const intent = doc.context.obj({
    Type: 'OutputIntent',
    S: 'GTS_PDFA1',
    OutputConditionIdentifier: PDFString.of('sRGB IEC61966-2.1'),
    Info: PDFString.of('sRGB IEC61966-2.1'),
    DestOutputProfile: profile,
  });
  doc.catalog.set(PDFName.of('OutputIntents'), doc.context.obj([doc.context.register(intent)]));

  // A stable identifier: the same document rendered twice is the same document.
  let h1 = 0x811c9dc5;
  let h2 = 0x01000193;
  for (let i = 0; i < seed.length; i++) {
    h1 = Math.imul(h1 ^ seed.charCodeAt(i), 0x01000193) >>> 0;
    h2 = Math.imul(h2 ^ seed.charCodeAt(seed.length - 1 - i), 0x811c9dc5) >>> 0;
  }
  const id = [h1, h2, (h1 ^ h2) >>> 0, Math.imul(h1, 31) >>> 0].map((n) => n.toString(16).padStart(8, '0')).join('');
  doc.context.trailerInfo.ID = doc.context.obj([PDFHexString.of(id), PDFHexString.of(id)]);
}
