import jsQRModule from 'jsqr';
import { describe, expect, it } from 'vitest';
import { encodeQr, type QrErrorCorrection, type QrMatrix } from '../src/qr.js';

// A CommonJS module whose types say `export default`: the function is the module itself, or its default.
type Decoder = (data: Uint8ClampedArray, width: number, height: number, options?: { inversionAttempts?: string }) => { data: string; version: number } | null;
const jsQR: Decoder = ((jsQRModule as unknown as { default?: Decoder }).default ?? jsQRModule) as unknown as Decoder;

/** The matrix as the pixels of an image, four pixels a module and a quiet zone of four modules, read back by a decoder that shares nothing with the encoder. */
function decode(matrix: QrMatrix): { data: string; version: number } | null {
  const scale = 4;
  const side = (matrix.size + 8) * scale;
  const pixels = new Uint8ClampedArray(side * side * 4).fill(255);
  for (let y = 0; y < matrix.size; y++) {
    for (let x = 0; x < matrix.size; x++) {
      if (!matrix.modules[y]?.[x]) continue;
      for (let dy = 0; dy < scale; dy++) {
        for (let dx = 0; dx < scale; dx++) {
          const at = (((y + 4) * scale + dy) * side + (x + 4) * scale + dx) * 4;
          pixels[at] = pixels[at + 1] = pixels[at + 2] = 0;
        }
      }
    }
  }
  const found = jsQR(pixels, side, side, { inversionAttempts: 'dontInvert' });
  return found === null ? null : { data: found.data, version: found.version };
}

// Links in the shapes the authorities print: a query string, a path with an identifier, characters to escape.
const TEXTS = [
  'https://verify.invalid/check?id=INV-1&date=01-01-2027&total=121.00',
  'https://portal.invalid/ABCDEFGHIJKLMNOPQRSTUVWXYZ/share/0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcd',
  'https://verify.invalid/q?n=Caf%C3%A9+%26+Co&amount=1.234,56',
  'x',
];

describe('encodeQr', () => {
  for (const level of ['L', 'M', 'Q', 'H'] as QrErrorCorrection[]) {
    for (const text of TEXTS) {
      it(`writes ${JSON.stringify(text.slice(0, 40))} at level ${level} so that a decoder reads it back`, () => {
        const matrix = encodeQr(text, level);
        expect(matrix.errorCorrection).toBe(level);
        expect(matrix.size).toBe(matrix.version * 4 + 17);
        expect(decode(matrix)).toEqual({ data: text, version: matrix.version });
      });
    }
  }

  it('takes the smallest version that holds the text, up to the ones that carry their version number', () => {
    expect(encodeQr('x'.repeat(14), 'M').version).toBe(1);
    expect(encodeQr('x'.repeat(15), 'M').version).toBe(2);
    for (const length of [200, 400, 900]) {
      const text = `https://verify.invalid/${'a1'.repeat(length / 2)}`;
      const matrix = encodeQr(text, 'M');
      expect(matrix.version).toBeGreaterThanOrEqual(7);
      expect(decode(matrix)?.data).toBe(text);
    }
  });

  it('writes the text as UTF-8', () => {
    const text = 'https://verify.invalid/?name=Ωμέγα Ünïcode';
    expect(decode(encodeQr(text))?.data).toBe(text);
  });

  it('gives the same matrix for the same text', () => {
    expect(encodeQr(TEXTS[0] as string)).toEqual(encodeQr(TEXTS[0] as string));
  });

  it('refuses a level the standard does not have and a text no version holds', () => {
    expect(() => encodeQr('x', 'X' as QrErrorCorrection)).toThrow(/L, M, Q or H/);
    expect(() => encodeQr('x'.repeat(3000), 'H')).toThrow(/do not fit/);
  });
});
