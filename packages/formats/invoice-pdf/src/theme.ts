/**
 * The theme: an accent colour, a typeface, the side of the logo — the few
 * things a customer's own invoice sets, so that a theme can one day be read
 * from one. One sober default.
 */

import { rgb, type RGB } from 'pdf-lib';
import { InvoicePdfError } from './errors.js';
import FRAUNCES_SEMIBOLD from './fonts/fraunces-semibold.js';
import INTER_BOLD from './fonts/inter-bold.js';
import INTER_REGULAR from './fonts/inter-regular.js';
import { decodeBase64 } from './text.js';
import type { ExtraFont, InvoiceCredit, InvoiceTheme } from './types.js';

/** A dark slate blue, the elegant pair the package embeds, the logo on the left. */
export const DEFAULT_THEME = {
  accent: '#1F3A5F',
  logoPosition: 'left',
  typeface: 'elegant',
} as const satisfies Required<Omit<InvoiceTheme, 'font' | 'headingFont'>>;

/**
 * The credit the Ekwo surfaces print under the foot — the command line, the
 * MCP server, Ekwo Cloud — kept here so they print the same one. A caller of
 * the package passes it, or its own, or none.
 */
export const EKWO_CREDIT = { text: 'Ekwo.ai', url: 'https://ekwo.ai' } as const satisfies InvoiceCredit;

/** The typefaces a theme may name, each a text font and a heading font, or null for Noto Sans. */
export const TYPEFACES = ['classic', 'elegant'] as const;

function typefaceFonts(name: (typeof TYPEFACES)[number]): { font: ExtraFont | null; heading: ExtraFont | null } {
  if (name === 'classic') return { font: null, heading: null };
  return {
    font: { regular: decodeBase64(INTER_REGULAR), bold: decodeBase64(INTER_BOLD) },
    heading: { regular: decodeBase64(FRAUNCES_SEMIBOLD) },
  };
}

export interface ResolvedTheme {
  accent: RGB;
  /** White on a dark accent, ink on a light one. */
  onAccent: RGB;
  /** A font of the caller's or of the typeface, tried before the embedded ones; null for Noto Sans. */
  font: ExtraFont | null;
  /** The font of the title, the names and the headings; null draws them in `font`. */
  heading: ExtraFont | null;
  logoPosition: 'left' | 'right';
}

/** The colour of the text; render.ts draws with the same. */
export const INK = rgb(0.1, 0.1, 0.12);
const WHITE = rgb(1, 1, 1);

export function resolveTheme(theme: InvoiceTheme | undefined): ResolvedTheme {
  const accent = theme?.accent ?? DEFAULT_THEME.accent;
  const match = /^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i.exec(accent);
  if (match === null) throw new InvoicePdfError('invalid_value', `theme.accent "${accent}" is not a colour written #rrggbb`);
  const [r, g, b] = match.slice(1).map((hex) => parseInt(hex, 16) / 255) as [number, number, number];
  // The text on the accent is white or ink, whichever contrasts more with it (WCAG 2 contrast ratio).
  const luminance = (c: RGB): number => {
    const linear = (v: number): number => (v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4);
    return 0.2126 * linear(c.red) + 0.7152 * linear(c.green) + 0.0722 * linear(c.blue);
  };
  const colour = rgb(r, g, b);
  const l = luminance(colour);
  const onWhite = 1.05 / (l + 0.05);
  const onInk = (l + 0.05) / (luminance(INK) + 0.05);
  const position = theme?.logoPosition ?? DEFAULT_THEME.logoPosition;
  if (position !== 'left' && position !== 'right') {
    throw new InvoicePdfError('invalid_value', `theme.logoPosition "${String(position)}" is neither left nor right`);
  }
  const typeface = theme?.typeface ?? DEFAULT_THEME.typeface;
  if (!(TYPEFACES as readonly string[]).includes(typeface)) {
    throw new InvoicePdfError('invalid_value', `theme.typeface "${String(typeface)}" is not one of ${TYPEFACES.join(', ')}`);
  }
  const pair = typefaceFonts(typeface);
  const font = theme?.font;
  return {
    accent: colour,
    onAccent: onWhite >= onInk ? WHITE : INK,
    font: font === undefined ? pair.font : font === 'Noto Sans' ? null : font,
    heading: theme?.headingFont ?? pair.heading,
    logoPosition: position,
  };
}
