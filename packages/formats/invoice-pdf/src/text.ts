/**
 * Text: which font draws which character, how wide a string is, where a line
 * breaks — and what is refused rather than drawn wrong.
 *
 * **Fonts.** Noto Sans (Latin, Greek, Cyrillic, and the Vietnamese and other
 * extended Latin it carries) and Noto Sans Thai are embedded in the package,
 * regular and bold, under the SIL Open Font License; a caller adds fonts for
 * any other script through `options.fonts`. Each character is drawn by the
 * first font that has a glyph for it, so a line may mix scripts. A character
 * no font has is refused by name, `glyph_not_covered`: a PDF with an empty box
 * where a customer's name should be is worse than no PDF.
 *
 * **Direction.** Text written right to left — Hebrew, Arabic, Syriac, Thaana,
 * N'Ko and the other scripts of the right-to-left blocks of Unicode — would
 * need the bidirectional algorithm and a mirrored layout, which this package
 * does not have. It is refused, `right_to_left_text`, and never drawn in the
 * reverse order.
 *
 * Every font is embedded as a subset, and only when a character of it is drawn.
 */

import fontkit from '@pdf-lib/fontkit';
import type { PDFDocument, PDFFont } from 'pdf-lib';
import { InvoicePdfError } from './errors.js';
import NOTO_SANS_BOLD from './fonts/noto-sans-bold.js';
import NOTO_SANS_REGULAR from './fonts/noto-sans-regular.js';
import NOTO_SANS_THAI_BOLD from './fonts/noto-sans-thai-bold.js';
import NOTO_SANS_THAI_REGULAR from './fonts/noto-sans-thai-regular.js';
import type { ExtraFont } from './types.js';

/** A character class of code point ranges, written as numbers so that the source holds no invisible character. */
function codePointClass(ranges: readonly (readonly [number, number])[], flags = ''): RegExp {
  const hex = (n: number): string => `\\u{${n.toString(16)}}`;
  return new RegExp(`[${ranges.map(([from, to]) => `${hex(from)}-${hex(to)}`).join('')}]`, `u${flags}`);
}

/** The blocks of Unicode whose scripts are written right to left. */
const RIGHT_TO_LEFT = codePointClass([
  [0x0590, 0x08ff],
  [0xfb1d, 0xfdff],
  [0xfe70, 0xfefe],
  [0x10800, 0x10fff],
  [0x1e800, 0x1efff],
]);

/** Characters that are drawn as nothing: controls, and the joiners and marks of direction. */
const INVISIBLE = codePointClass(
  [
    [0x0000, 0x0008],
    [0x000b, 0x001f],
    [0x007f, 0x009f],
    [0x200b, 0x200f],
    [0x202a, 0x202e],
    [0x2060, 0x2064],
    [0xfeff, 0xfeff],
  ],
  'g',
);

/** Spaces a font may not have, and that are drawn as a space where it does not. */
const SPACES = new Set([0x00a0, 0x2007, 0x2009, 0x202f]);

export function decodeBase64(text: string): Uint8Array {
  const binary = atob(text);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes;
}

const bytesOf = (data: Uint8Array | ArrayBuffer): Uint8Array => (data instanceof Uint8Array ? data : new Uint8Array(data));

interface Face {
  bytes: Uint8Array;
  covers: (codePoint: number) => boolean;
  embedded?: PDFFont;
}

interface Family {
  name: string;
  regular: Face;
  bold: Face;
}

function face(bytes: Uint8Array, name: string): Face {
  let font: ReturnType<typeof fontkit.create>;
  try {
    font = fontkit.create(bytes);
  } catch (error) {
    throw new InvoicePdfError('unsupported_font', `${name} cannot be read as a TrueType or OpenType font: ${error instanceof Error ? error.message : String(error)}`);
  }
  return { bytes, covers: (codePoint) => font.hasGlyphForCodePoint(codePoint) };
}

/** A piece of a line drawn in one font. */
export interface Run {
  text: string;
  font: PDFFont;
}

export interface Typesetter {
  /** The pieces of `text`, each with the font that draws it. Refuses what no font has and what reads right to left. */
  runs(text: string, bold: boolean): Promise<Run[]>;
  width(text: string, size: number, bold: boolean): Promise<number>;
  /** `text` broken into lines no wider than `width`; a paragraph break (`\n`) is kept. */
  wrap(text: string, size: number, width: number, bold: boolean): Promise<string[]>;
}

/** Removes what is drawn as nothing and turns tabs into spaces. */
export function clean(text: string): string {
  return text.replace(/\t/g, ' ').replace(/\r\n?/g, '\n').replace(INVISIBLE, '');
}

/** Refuses a string written right to left, naming the first such character. */
export function refuseRightToLeft(text: string, where: string): void {
  const found = RIGHT_TO_LEFT.exec(text);
  if (found !== null) {
    const codePoint = found[0].codePointAt(0) ?? 0;
    throw new InvoicePdfError(
      'right_to_left_text',
      `${where} holds "${found[0]}" (U+${codePoint.toString(16).toUpperCase().padStart(4, '0')}), a script written right to left, which this package does not lay out; it refuses rather than draw it reversed`,
    );
  }
}

/**
 * `first`, the typeface of the theme, is tried before the embedded fonts;
 * `extra`, the fonts of `options.fonts`, after them.
 */
export function typesetter(doc: PDFDocument, extra: readonly ExtraFont[], locale: string, first: ExtraFont | null = null): Typesetter {
  doc.registerFontkit(fontkit);
  const families: Family[] = [];
  if (first !== null) {
    const regular = face(bytesOf(first.regular), 'theme.font.regular');
    const bold = first.bold === undefined ? regular : face(bytesOf(first.bold), 'theme.font.bold');
    families.push({ name: 'theme.font', regular, bold });
  }
  const lazy = (base64: string, name: string): Face => {
    let built: Face | undefined;
    return {
      get bytes() {
        built ??= face(decodeBase64(base64), name);
        return built.bytes;
      },
      covers(codePoint) {
        built ??= face(decodeBase64(base64), name);
        return built.covers(codePoint);
      },
    };
  };
  families.push({ name: 'Noto Sans', regular: lazy(NOTO_SANS_REGULAR, 'Noto Sans'), bold: lazy(NOTO_SANS_BOLD, 'Noto Sans Bold') });
  families.push({
    name: 'Noto Sans Thai',
    regular: lazy(NOTO_SANS_THAI_REGULAR, 'Noto Sans Thai'),
    bold: lazy(NOTO_SANS_THAI_BOLD, 'Noto Sans Thai Bold'),
  });
  extra.forEach((font, index) => {
    const regular = face(bytesOf(font.regular), `options.fonts[${index}].regular`);
    const bold = font.bold === undefined ? regular : face(bytesOf(font.bold), `options.fonts[${index}].bold`);
    families.push({ name: `options.fonts[${index}]`, regular, bold });
  });

  const embed = async (f: Face): Promise<PDFFont> => {
    f.embedded ??= await doc.embedFont(f.bytes, { subset: true });
    return f.embedded;
  };

  const familyFor = (codePoint: number): Family | undefined => families.find((family) => family.regular.covers(codePoint));

  async function runs(text: string, bold: boolean): Promise<Run[]> {
    const out: { text: string; family: Family }[] = [];
    for (const char of clean(text)) {
      const codePoint = char.codePointAt(0) ?? 0;
      let family = familyFor(codePoint);
      let drawn = char;
      if (family === undefined && SPACES.has(codePoint)) {
        family = familyFor(0x20);
        drawn = ' ';
      }
      // A combining mark stays with the letter it sits on, in its font, when that font has it.
      const previous = out[out.length - 1];
      if (previous !== undefined && /\p{M}/u.test(char) && previous.family.regular.covers(codePoint)) family = previous.family;
      if (family === undefined) {
        refuseRightToLeft(char, 'the text');
        throw new InvoicePdfError(
          'glyph_not_covered',
          `"${char}" (U+${codePoint.toString(16).toUpperCase().padStart(4, '0')}) is in no embedded font and in no font of options.fonts; pass a font that has it`,
        );
      }
      if (previous !== undefined && previous.family === family) previous.text += drawn;
      else out.push({ text: drawn, family });
    }
    return Promise.all(out.map(async (run) => ({ text: run.text, font: await embed(bold ? run.family.bold : run.family.regular) })));
  }

  async function width(text: string, size: number, bold: boolean): Promise<number> {
    let total = 0;
    for (const run of await runs(text, bold)) total += run.font.widthOfTextAtSize(run.text, size);
    return total;
  }

  const Segmenter = (Intl as { Segmenter?: typeof Intl.Segmenter }).Segmenter;
  const words = Segmenter === undefined ? undefined : new Segmenter(locale, { granularity: 'word' });
  const graphemes = Segmenter === undefined ? undefined : new Segmenter(locale, { granularity: 'grapheme' });

  /** Where a line may break: after a space, or between two words of a script written without spaces. */
  const pieces = (paragraph: string): string[] =>
    words === undefined ? paragraph.split(/(?<= )/) : Array.from(words.segment(paragraph), (s) => s.segment);
  const characters = (piece: string): string[] =>
    graphemes === undefined ? Array.from(piece) : Array.from(graphemes.segment(piece), (s) => s.segment);

  async function wrap(text: string, size: number, maxWidth: number, bold: boolean): Promise<string[]> {
    const lines: string[] = [];
    for (const paragraph of clean(text).split('\n')) {
      let current = '';
      for (const piece of pieces(paragraph)) {
        const candidate = current + piece;
        if (current === '' || (await width(candidate.trimEnd(), size, bold)) <= maxWidth) {
          current = candidate;
        } else {
          lines.push(current.trimEnd());
          current = piece.trimStart();
        }
        // A word longer than the line is broken between its characters.
        while ((await width(current.trimEnd(), size, bold)) > maxWidth) {
          let head = '';
          for (const char of characters(current)) {
            if (head !== '' && (await width(head + char, size, bold)) > maxWidth) break;
            head += char;
          }
          lines.push(head);
          current = current.slice(head.length);
        }
      }
      lines.push(current.trimEnd());
    }
    return lines;
  }

  return { runs, width, wrap };
}
