/**
 * A QR code, ISO/IEC 18004, as a matrix of dark and light modules.
 *
 * What an invoice carries as a QR code is a link — the authority's
 * verification service, with what identifies the invoice — so this encodes
 * one mode only, bytes (UTF-8), at the error correction level the caller
 * names, in the smallest version from 1 to 40 that holds the text. The level
 * is never raised on the way: a country that prescribes one gets that one.
 * The mask is the one of the eight with the lowest penalty (ISO/IEC 18004,
 * section 7.8.3), so the same text always gives the same matrix.
 *
 * Nothing is drawn here: the matrix is handed to whoever draws the page.
 */

import type { QrErrorCorrection } from './types.js';

export type { QrErrorCorrection };

/** The modules of a QR code, `size` × `size`, row by row from the top; `true` is dark. */
export interface QrMatrix {
  version: number;
  size: number;
  errorCorrection: QrErrorCorrection;
  mask: number;
  modules: boolean[][];
}

/** The two bits of a level in the format information, section 7.9.1. */
const FORMAT_BITS: Record<QrErrorCorrection, number> = { L: 1, M: 0, Q: 3, H: 2 };

// Section 7.5.1, table 9: by level, then by version (index 0 unused).
const ECC_CODEWORDS_PER_BLOCK: Record<QrErrorCorrection, readonly number[]> = {
  L: [-1, 7, 10, 15, 20, 26, 18, 20, 24, 30, 18, 20, 24, 26, 30, 22, 24, 28, 30, 28, 28, 28, 28, 30, 30, 26, 28, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30],
  M: [-1, 10, 16, 26, 18, 24, 16, 18, 22, 22, 26, 30, 22, 22, 24, 24, 28, 28, 26, 26, 26, 26, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28],
  Q: [-1, 13, 22, 18, 26, 18, 24, 18, 22, 20, 24, 28, 26, 24, 20, 30, 24, 28, 28, 26, 30, 28, 30, 30, 30, 30, 28, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30],
  H: [-1, 17, 28, 22, 16, 22, 28, 26, 26, 24, 28, 24, 28, 22, 24, 24, 30, 28, 28, 26, 28, 30, 24, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30],
};
const ERROR_CORRECTION_BLOCKS: Record<QrErrorCorrection, readonly number[]> = {
  L: [-1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 4, 4, 4, 4, 4, 6, 6, 6, 6, 7, 8, 8, 9, 9, 10, 12, 12, 12, 13, 14, 15, 16, 17, 18, 19, 19, 20, 21, 22, 24, 25],
  M: [-1, 1, 1, 1, 2, 2, 4, 4, 4, 5, 5, 5, 8, 9, 9, 10, 10, 11, 13, 14, 16, 17, 17, 18, 20, 21, 23, 25, 26, 28, 29, 31, 33, 35, 37, 38, 40, 43, 45, 47, 49],
  Q: [-1, 1, 1, 2, 2, 4, 4, 6, 6, 8, 8, 8, 10, 12, 16, 12, 17, 16, 18, 21, 20, 23, 23, 25, 27, 29, 34, 34, 35, 38, 40, 43, 45, 48, 51, 53, 56, 59, 62, 65, 68],
  H: [-1, 1, 1, 2, 4, 4, 4, 5, 6, 8, 8, 11, 11, 16, 16, 18, 16, 19, 21, 25, 25, 25, 34, 30, 32, 35, 37, 40, 42, 45, 48, 51, 54, 57, 60, 63, 66, 70, 74, 77, 81],
};

const bit = (value: number, index: number): boolean => ((value >>> index) & 1) !== 0;

/** The modules left for data and error correction once the function patterns are drawn. */
function rawDataModules(version: number): number {
  let result = (16 * version + 128) * version + 64;
  if (version >= 2) {
    const alignments = Math.floor(version / 7) + 2;
    result -= (25 * alignments - 10) * alignments - 55;
    if (version >= 7) result -= 36;
  }
  return result;
}

function dataCodewords(version: number, level: QrErrorCorrection): number {
  return Math.floor(rawDataModules(version) / 8) - (ECC_CODEWORDS_PER_BLOCK[level][version] as number) * (ERROR_CORRECTION_BLOCKS[level][version] as number);
}

/** Multiplication in GF(2^8) modulo x^8 + x^4 + x^3 + x^2 + 1. */
function multiply(x: number, y: number): number {
  let z = 0;
  for (let i = 7; i >= 0; i--) {
    z = (z << 1) ^ ((z >>> 7) * 0x11d);
    z ^= ((y >>> i) & 1) * x;
  }
  return z & 0xff;
}

function reedSolomonDivisor(degree: number): number[] {
  const result = new Array<number>(degree).fill(0);
  result[degree - 1] = 1;
  let root = 1;
  for (let i = 0; i < degree; i++) {
    for (let j = 0; j < result.length; j++) {
      result[j] = multiply(result[j] as number, root);
      if (j + 1 < result.length) result[j] = (result[j] as number) ^ (result[j + 1] as number);
    }
    root = multiply(root, 0x02);
  }
  return result;
}

function reedSolomonRemainder(data: readonly number[], divisor: readonly number[]): number[] {
  const result = divisor.map(() => 0);
  for (const byte of data) {
    const factor = byte ^ (result.shift() as number);
    result.push(0);
    divisor.forEach((coefficient, i) => {
      result[i] = (result[i] as number) ^ multiply(coefficient, factor);
    });
  }
  return result;
}

/** The data codewords split into blocks, each followed by its error correction, interleaved (section 7.6). */
function withErrorCorrection(data: readonly number[], version: number, level: QrErrorCorrection): number[] {
  const blocks = ERROR_CORRECTION_BLOCKS[level][version] as number;
  const eccLength = ECC_CODEWORDS_PER_BLOCK[level][version] as number;
  const raw = Math.floor(rawDataModules(version) / 8);
  const shortBlocks = blocks - (raw % blocks);
  const shortLength = Math.floor(raw / blocks);
  const divisor = reedSolomonDivisor(eccLength);
  const all: number[][] = [];
  for (let i = 0, k = 0; i < blocks; i++) {
    const block = data.slice(k, k + shortLength - eccLength + (i < shortBlocks ? 0 : 1));
    k += block.length;
    const ecc = reedSolomonRemainder(block, divisor);
    if (i < shortBlocks) block.push(0);
    all.push([...block, ...ecc]);
  }
  const out: number[] = [];
  for (let i = 0; i < (all[0] as number[]).length; i++) {
    for (const [j, block] of all.entries()) {
      // The padding byte of a short block is not a codeword.
      if (i !== shortLength - eccLength || j >= shortBlocks) out.push(block[i] as number);
    }
  }
  return out;
}

function alignmentPositions(version: number, size: number): number[] {
  if (version === 1) return [];
  const count = Math.floor(version / 7) + 2;
  const step = Math.floor((version * 8 + count * 3 + 5) / (count * 4 - 4)) * 2;
  const result = [6];
  for (let position = size - 7; result.length < count; position -= step) result.splice(1, 0, position);
  return result;
}

const MASKS: readonly ((x: number, y: number) => boolean)[] = [
  (x, y) => (x + y) % 2 === 0,
  (_x, y) => y % 2 === 0,
  (x) => x % 3 === 0,
  (x, y) => (x + y) % 3 === 0,
  (x, y) => (Math.floor(x / 3) + Math.floor(y / 2)) % 2 === 0,
  (x, y) => ((x * y) % 2) + ((x * y) % 3) === 0,
  (x, y) => (((x * y) % 2) + ((x * y) % 3)) % 2 === 0,
  (x, y) => (((x + y) % 2) + ((x * y) % 3)) % 2 === 0,
];

class Grid {
  readonly modules: boolean[][];
  readonly fixed: boolean[][];

  constructor(
    readonly version: number,
    readonly size: number,
    readonly level: QrErrorCorrection,
  ) {
    this.modules = Array.from({ length: size }, () => new Array<boolean>(size).fill(false));
    this.fixed = Array.from({ length: size }, () => new Array<boolean>(size).fill(false));
  }

  set(x: number, y: number, dark: boolean): void {
    (this.modules[y] as boolean[])[x] = dark;
    (this.fixed[y] as boolean[])[x] = true;
  }

  functionPatterns(): void {
    for (let i = 0; i < this.size; i++) {
      this.set(6, i, i % 2 === 0);
      this.set(i, 6, i % 2 === 0);
    }
    for (const [cx, cy] of [[3, 3], [this.size - 4, 3], [3, this.size - 4]] as const) {
      for (let dy = -4; dy <= 4; dy++) {
        for (let dx = -4; dx <= 4; dx++) {
          const distance = Math.max(Math.abs(dx), Math.abs(dy));
          const x = cx + dx;
          const y = cy + dy;
          if (x >= 0 && x < this.size && y >= 0 && y < this.size) this.set(x, y, distance !== 2 && distance !== 4);
        }
      }
    }
    const positions = alignmentPositions(this.version, this.size);
    const last = positions.length - 1;
    for (const [i, cx] of positions.entries()) {
      for (const [j, cy] of positions.entries()) {
        if ((i === 0 && j === 0) || (i === 0 && j === last) || (i === last && j === 0)) continue;
        for (let dy = -2; dy <= 2; dy++) {
          for (let dx = -2; dx <= 2; dx++) this.set(cx + dx, cy + dy, Math.max(Math.abs(dx), Math.abs(dy)) !== 1);
        }
      }
    }
    this.formatBits(0);
    this.versionBits();
  }

  /** The level and the mask, twice, with their BCH code (section 7.9). */
  formatBits(mask: number): void {
    const data = (FORMAT_BITS[this.level] << 3) | mask;
    let remainder = data;
    for (let i = 0; i < 10; i++) remainder = (remainder << 1) ^ ((remainder >>> 9) * 0x537);
    const bits = ((data << 10) | remainder) ^ 0x5412;
    for (let i = 0; i <= 5; i++) this.set(8, i, bit(bits, i));
    this.set(8, 7, bit(bits, 6));
    this.set(8, 8, bit(bits, 7));
    this.set(7, 8, bit(bits, 8));
    for (let i = 9; i < 15; i++) this.set(14 - i, 8, bit(bits, i));
    for (let i = 0; i < 8; i++) this.set(this.size - 1 - i, 8, bit(bits, i));
    for (let i = 8; i < 15; i++) this.set(8, this.size - 15 + i, bit(bits, i));
    this.set(8, this.size - 8, true);
  }

  /** From version 7, the version and its Golay code, twice (section 7.10). */
  versionBits(): void {
    if (this.version < 7) return;
    let remainder = this.version;
    for (let i = 0; i < 12; i++) remainder = (remainder << 1) ^ ((remainder >>> 11) * 0x1f25);
    const bits = (this.version << 12) | remainder;
    for (let i = 0; i < 18; i++) {
      const a = this.size - 11 + (i % 3);
      const b = Math.floor(i / 3);
      this.set(a, b, bit(bits, i));
      this.set(b, a, bit(bits, i));
    }
  }

  /** The codewords in the zigzag of two-module columns, from the bottom right (section 7.7.3). */
  codewords(data: readonly number[]): void {
    let i = 0;
    for (let right = this.size - 1; right >= 1; right -= 2) {
      if (right === 6) right = 5;
      for (let vertical = 0; vertical < this.size; vertical++) {
        for (let j = 0; j < 2; j++) {
          const x = right - j;
          const upward = ((right + 1) & 2) === 0;
          const y = upward ? this.size - 1 - vertical : vertical;
          if (!(this.fixed[y] as boolean[])[x] && i < data.length * 8) {
            (this.modules[y] as boolean[])[x] = bit(data[i >>> 3] as number, 7 - (i & 7));
            i++;
          }
        }
      }
    }
  }

  /** Masking twice with the same pattern undoes it. */
  mask(index: number): void {
    const pattern = MASKS[index] as (x: number, y: number) => boolean;
    for (let y = 0; y < this.size; y++) {
      for (let x = 0; x < this.size; x++) {
        if (!(this.fixed[y] as boolean[])[x] && pattern(x, y)) {
          (this.modules[y] as boolean[])[x] = !(this.modules[y] as boolean[])[x];
        }
      }
    }
  }

  /** Section 7.8.3: runs, 2×2 blocks, finder-like patterns, and the balance of dark and light. */
  penalty(): number {
    const size = this.size;
    let result = 0;
    const at = (x: number, y: number): boolean => (this.modules[y] as boolean[])[x] as boolean;
    const line = (get: (i: number) => boolean): void => {
      let colour = false;
      let run = 0;
      const history = [0, 0, 0, 0, 0, 0, 0];
      const push = (length: number): void => {
        history.pop();
        history.unshift(history[0] === 0 ? length + size : length);
      };
      const patterns = (): number => {
        const n = history[1] as number;
        const core = n > 0 && history[2] === n && history[3] === n * 3 && history[4] === n && history[5] === n;
        return (core && (history[0] as number) >= n * 4 && (history[6] as number) >= n ? 1 : 0) +
          (core && (history[6] as number) >= n * 4 && (history[0] as number) >= n ? 1 : 0);
      };
      for (let i = 0; i < size; i++) {
        if (get(i) === colour) {
          run++;
          if (run === 5) result += 3;
          else if (run > 5) result++;
        } else {
          push(run);
          if (!colour) result += patterns() * 40;
          colour = get(i);
          run = 1;
        }
      }
      if (colour) {
        push(run);
        run = 0;
      }
      push(run + size);
      result += patterns() * 40;
    };
    for (let y = 0; y < size; y++) line((x) => at(x, y));
    for (let x = 0; x < size; x++) line((y) => at(x, y));
    for (let y = 0; y < size - 1; y++) {
      for (let x = 0; x < size - 1; x++) {
        const c = at(x, y);
        if (c === at(x + 1, y) && c === at(x, y + 1) && c === at(x + 1, y + 1)) result += 3;
      }
    }
    let dark = 0;
    for (const row of this.modules) for (const module of row) if (module) dark++;
    const total = size * size;
    result += (Math.ceil(Math.abs(dark * 20 - total * 10) / total) - 1) * 10;
    return result;
  }
}

/**
 * The QR code of `text`, its bytes in UTF-8, at `errorCorrection` (`M` by
 * default). Throws where the text does not fit version 40 at that level.
 */
export function encodeQr(text: string, errorCorrection: QrErrorCorrection = 'M'): QrMatrix {
  if (!(errorCorrection in FORMAT_BITS)) throw new Error(`a QR code is corrected at level L, M, Q or H, not ${String(errorCorrection)}`);
  const bytes = [...new TextEncoder().encode(text)];
  let version = 1;
  for (; version <= 40; version++) {
    const countBits = version <= 9 ? 8 : 16;
    if (4 + countBits + bytes.length * 8 <= dataCodewords(version, errorCorrection) * 8) break;
  }
  if (version > 40) throw new Error(`${bytes.length} bytes do not fit a QR code at level ${errorCorrection}`);

  // Mode, count, data, terminator, then the padding bytes of section 7.4.10.
  const bits: number[] = [];
  const append = (value: number, length: number): void => {
    for (let i = length - 1; i >= 0; i--) bits.push((value >>> i) & 1);
  };
  append(0b0100, 4);
  append(bytes.length, version <= 9 ? 8 : 16);
  for (const byte of bytes) append(byte, 8);
  const capacity = dataCodewords(version, errorCorrection) * 8;
  append(0, Math.min(4, capacity - bits.length));
  append(0, (8 - (bits.length % 8)) % 8);
  for (let pad = 0xec; bits.length < capacity; pad ^= 0xec ^ 0x11) append(pad, 8);
  const data: number[] = [];
  for (let i = 0; i < bits.length; i += 8) data.push(parseInt(bits.slice(i, i + 8).join(''), 2));

  const size = version * 4 + 17;
  const grid = new Grid(version, size, errorCorrection);
  grid.functionPatterns();
  grid.codewords(withErrorCorrection(data, version, errorCorrection));

  let best = 0;
  let lowest = Infinity;
  for (let mask = 0; mask < 8; mask++) {
    grid.mask(mask);
    grid.formatBits(mask);
    const penalty = grid.penalty();
    if (penalty < lowest) {
      best = mask;
      lowest = penalty;
    }
    grid.mask(mask);
  }
  grid.mask(best);
  grid.formatBits(best);
  return { version, size, errorCorrection, mask: best, modules: grid.modules };
}
