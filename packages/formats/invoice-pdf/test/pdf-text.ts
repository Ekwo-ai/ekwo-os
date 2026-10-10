/**
 * The text a reader of the PDF extracts, read out of the file itself: each
 * string shown on a page, decoded through the ToUnicode map of its font. A
 * test that compares figures with this compares what is printed, not what
 * the renderer says it printed.
 *
 * It reads what this package writes — `<hex> Tj` in a Type 0 font with a
 * ToUnicode map — and nothing else: it is a test helper, not a PDF reader.
 */

import { PDFArray, PDFDict, PDFDocument, PDFName, PDFRawStream, decodePDFRawStream, type PDFStream } from 'pdf-lib';

const decode = (stream: PDFStream): string =>
  new TextDecoder('latin1').decode(stream instanceof PDFRawStream ? decodePDFRawStream(stream).decode() : stream.getContents());

/** Glyph code → text, from the `bfchar` and `bfrange` sections of a ToUnicode CMap. */
function toUnicode(cmap: string): Map<number, string> {
  const map = new Map<number, string>();
  const utf16 = (hex: string): string => {
    const units: number[] = [];
    for (let i = 0; i < hex.length; i += 4) units.push(parseInt(hex.slice(i, i + 4), 16));
    return String.fromCharCode(...units);
  };
  for (const section of cmap.matchAll(/beginbfchar([\s\S]*?)endbfchar/g)) {
    for (const [, code, text] of (section[1] ?? '').matchAll(/<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>/g)) {
      map.set(parseInt(code as string, 16), utf16(text as string));
    }
  }
  for (const section of cmap.matchAll(/beginbfrange([\s\S]*?)endbfrange/g)) {
    for (const [, from, to, start] of (section[1] ?? '').matchAll(/<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>/g)) {
      const first = utf16(start as string);
      for (let code = parseInt(from as string, 16), i = 0; code <= parseInt(to as string, 16); code++, i++) {
        map.set(code, first.slice(0, -1) + String.fromCharCode(first.charCodeAt(first.length - 1) + i));
      }
    }
  }
  return map;
}

/** Every string shown on each page, in the order it is shown. */
export async function pdfText(file: Uint8Array): Promise<string[][]> {
  const doc = await PDFDocument.load(file, { updateMetadata: false });
  return doc.getPages().map((page) => {
    const fonts = page.node.Resources()?.lookup(PDFName.of('Font'), PDFDict);
    const maps = new Map<string, Map<number, string>>();
    const mapOf = (name: string): Map<number, string> => {
      let map = maps.get(name);
      if (map === undefined) {
        const font = fonts?.lookup(PDFName.of(name), PDFDict);
        const cmap = font?.lookup(PDFName.of('ToUnicode'));
        map = cmap instanceof PDFRawStream ? toUnicode(decode(cmap)) : new Map();
        maps.set(name, map);
      }
      return map;
    };
    const contents = page.node.Contents();
    const streams: PDFStream[] = [];
    if (contents instanceof PDFArray) {
      for (let i = 0; i < contents.size(); i++) streams.push(contents.lookup(i) as PDFStream);
    } else if (contents !== undefined) {
      streams.push(contents);
    }
    const out: string[] = [];
    for (const stream of streams) {
      let font = '';
      let shown = '';
      for (const [, name, hex, end] of decode(stream).matchAll(/\/(\S+)\s+[\d.]+\s+Tf|<([0-9A-Fa-f]*)>\s*Tj|\b(ET)\b/g)) {
        if (name !== undefined) font = name;
        else if (hex !== undefined) {
          const map = mapOf(font);
          for (let i = 0; i < hex.length; i += 4) shown += map.get(parseInt(hex.slice(i, i + 4), 16)) ?? '\u{fffd}';
        } else if (end !== undefined && shown !== '') {
          out.push(shown);
          shown = '';
        }
      }
    }
    return out;
  });
}
