import type { Profile } from './types.js';

/** XMP `fx:ConformanceLevel` values, exact spelling required by readers. */
export const CONFORMANCE_LEVELS: Readonly<Record<Profile, string>> = {
  minimum: 'MINIMUM',
  'basic-wl': 'BASIC WL',
  basic: 'BASIC',
  en16931: 'EN 16931',
  extended: 'EXTENDED',
};

export interface XmpOptions {
  profile: Profile;
  /** `dc:title`, the `Title` of the document information dictionary. */
  title?: string;
  /** `dc:creator`, the `Author` of the document information dictionary. Defaults to {@link creator}. */
  author?: string;
  /** `dc:description`, the `Subject` of the document information dictionary. */
  subject?: string;
  /** `pdf:Keywords`, the `Keywords` of the document information dictionary. */
  keywords?: string;
  /** `xmp:CreatorTool`, the `Creator` of the document information dictionary. */
  creator?: string;
  /** `pdf:Producer`. */
  producer?: string;
  /** `xmp:ModifyDate`, and `xmp:CreateDate` unless {@link creationDate} is given. Defaults to now. */
  date?: Date;
  /** `xmp:CreateDate`, the `CreationDate` of the document information dictionary. Defaults to {@link date}. */
  creationDate?: Date;
}

function escapeXml(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

/**
 * XMP packet declaring a PDF/A-3 document with the Factur-X extension schema,
 * as required by the Factur-X specification (§ 6.2).
 *
 * PDF/A wants every entry of the document information dictionary to say the
 * same as its XMP counterpart; give the same values to both.
 */
export function buildXmpMetadata(options: XmpOptions): string {
  const modified = options.date ?? new Date();
  const date = modified.toISOString();
  const created = (options.creationDate ?? modified).toISOString();
  const title = escapeXml(options.title ?? 'Invoice');
  const creator = escapeXml(options.creator ?? '@ekwo-ai/factur-x');
  const author = options.author === undefined ? creator : escapeXml(options.author);
  const producer = escapeXml(options.producer ?? '@ekwo-ai/factur-x');
  const description =
    options.subject === undefined
      ? ''
      : `\n      <dc:description><rdf:Alt><rdf:li xml:lang="x-default">${escapeXml(options.subject)}</rdf:li></rdf:Alt></dc:description>`;
  const keywords = options.keywords === undefined ? '' : `\n      <pdf:Keywords>${escapeXml(options.keywords)}</pdf:Keywords>`;
  const property = (name: string, description: string) =>
    `<rdf:li rdf:parseType="Resource"><pdfaProperty:name>${name}</pdfaProperty:name><pdfaProperty:valueType>Text</pdfaProperty:valueType><pdfaProperty:category>external</pdfaProperty:category><pdfaProperty:description>${description}</pdfaProperty:description></rdf:li>`;
  return `<?xpacket begin="﻿" id="W5M0MpCehiHzreSzNTczkc9d"?>
<x:xmpmeta xmlns:x="adobe:ns:meta/">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <rdf:Description rdf:about="" xmlns:pdfaid="http://www.aiim.org/pdfa/ns/id/">
      <pdfaid:part>3</pdfaid:part>
      <pdfaid:conformance>B</pdfaid:conformance>
    </rdf:Description>
    <rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
      <dc:title><rdf:Alt><rdf:li xml:lang="x-default">${title}</rdf:li></rdf:Alt></dc:title>
      <dc:creator><rdf:Seq><rdf:li>${author}</rdf:li></rdf:Seq></dc:creator>${description}
    </rdf:Description>
    <rdf:Description rdf:about="" xmlns:pdf="http://ns.adobe.com/pdf/1.3/">
      <pdf:Producer>${producer}</pdf:Producer>${keywords}
    </rdf:Description>
    <rdf:Description rdf:about="" xmlns:xmp="http://ns.adobe.com/xap/1.0/">
      <xmp:CreatorTool>${creator}</xmp:CreatorTool>
      <xmp:CreateDate>${created}</xmp:CreateDate>
      <xmp:ModifyDate>${date}</xmp:ModifyDate>
    </rdf:Description>
    <rdf:Description rdf:about="" xmlns:pdfaExtension="http://www.aiim.org/pdfa/ns/extension/" xmlns:pdfaSchema="http://www.aiim.org/pdfa/ns/schema#" xmlns:pdfaProperty="http://www.aiim.org/pdfa/ns/property#">
      <pdfaExtension:schemas>
        <rdf:Bag>
          <rdf:li rdf:parseType="Resource">
            <pdfaSchema:schema>Factur-X PDFA Extension Schema</pdfaSchema:schema>
            <pdfaSchema:namespaceURI>urn:factur-x:pdfa:CrossIndustryDocument:invoice:1p0#</pdfaSchema:namespaceURI>
            <pdfaSchema:prefix>fx</pdfaSchema:prefix>
            <pdfaSchema:property>
              <rdf:Seq>
                ${property('DocumentFileName', 'name of the embedded XML invoice file')}
                ${property('DocumentType', 'INVOICE')}
                ${property('Version', 'The actual version of the Factur-X XML schema')}
                ${property('ConformanceLevel', 'The conformance level of the embedded Factur-X data')}
              </rdf:Seq>
            </pdfaSchema:property>
          </rdf:li>
        </rdf:Bag>
      </pdfaExtension:schemas>
    </rdf:Description>
    <rdf:Description rdf:about="" xmlns:fx="urn:factur-x:pdfa:CrossIndustryDocument:invoice:1p0#">
      <fx:DocumentType>INVOICE</fx:DocumentType>
      <fx:DocumentFileName>factur-x.xml</fx:DocumentFileName>
      <fx:Version>1.0</fx:Version>
      <fx:ConformanceLevel>${CONFORMANCE_LEVELS[options.profile]}</fx:ConformanceLevel>
    </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
<?xpacket end="w"?>`;
}
