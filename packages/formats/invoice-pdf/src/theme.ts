/**
 * The theme: an accent colour, a typeface, the side of the logo — the few
 * things a customer's own invoice sets, so that a theme can one day be read
 * from one. One sober default.
 */

import { rgb, type RGB } from 'pdf-lib';
import { InvoicePdfError } from './errors.js';
import type { ExtraFont, InvoiceTheme } from './types.js';

/** A dark slate blue, the Noto Sans the package embeds, the logo on the left. */
export const DEFAULT_THEME = {
  accent: '#1F3A5F',
  font: 'Noto Sans',
  logoPosition: 'left',
} as const satisfies Required<InvoiceTheme>;

export interface ResolvedTheme {
  accent: RGB;
  /** White on a dark accent, ink on a light one. */
  onAccent: RGB;
  /** A font of the caller's, tried before the embedded ones; null for Noto Sans. */
  font: ExtraFont | null;
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
  const font = theme?.font ?? DEFAULT_THEME.font;
  return {
    accent: colour,
    onAccent: onWhite >= onInk ? WHITE : INK,
    font: font === 'Noto Sans' ? null : font,
    logoPosition: position,
  };
}
