/**
 * A QR code encoder, ISO/IEC 18004, with no dependency: byte mode, the four
 * error correction levels, versions 1 to 10 — enough for a verification URL
 * of up to 213 bytes at level M, which is what a fiscalisation regime prints
 * on an invoice.
 *
 * Nothing here is drawn: {@link encodeQr} returns the matrix of modules, and
 * the layout draws it in vectors. Where the data does not fit, it is refused,
 * never cut; and the level asked for is the level written, never raised.
 */

import { InvoicePdfError } from './errors.js';

export type QrErrorCorrection = 'L' | 'M' | 'Q' | 'H';

export interface QrCode {
  /** 1 to 10. */
  version: number;
  errorCorrection: QrErrorCorrection;
  /** The mask pattern applied, 0 to 7. */
  mask: number;
  /** Modules per side, without the quiet zone: 21 + 4 × (version − 1). */
  size: number;
  /** `modules[y][x]`, `true` for a dark module, row 0 at the top. */
  modules: boolean[][];
}

export interface QrOptions {
  /** The smallest version tried. Defaults to 1. */
  minVersion?: number;
  /** The largest version tried. Defaults to 10, the largest this encoder writes. */
  maxVersion?: number;
  /** A mask pattern, 0 to 7, instead of the one with the lowest penalty. */
  mask?: number;
}

const MAX_VERSION = 10;

/** The two bits of each level in the format information (table 12). */
const LEVEL_BITS: Record<QrErrorCorrection, number> = { L: 1, M: 0, Q: 3, H: 2 };

/**
 * Per version and level, the error correction codewords of each block and the
 * number of blocks (table 9).
 */
const BLOCKS: Record<QrErrorCorrection, readonly (readonly [number, number])[]> = {
  L: [[7, 1], [10, 1], [15, 1], [20, 1], [26, 1], [18, 2], [20, 2], [24, 2], [30, 2], [18, 4]],
  M: [[10, 1], [16, 1], [26, 1], [18, 2], [24, 2], [16, 4], [18, 4], [22, 4], [22, 5], [26, 5]],
  Q: [[13, 1], [22, 1], [18, 2], [26, 2], [18, 4], [24, 4], [18, 6], [22, 6], [20, 8], [24, 8]],
  H: [[17, 1], [28, 1], [22, 2], [16, 4], [22, 4], [28, 4], [26, 5], [26, 6], [24, 8], [28, 8]],
};

/** The row and column coordinates of the centres of the alignment patterns (annex E). */
const ALIGNMENT: readonly (readonly number[])[] = [
  [],
  [6, 18],
  [6, 22],
  [6, 26],
  [6, 30],
  [6, 34],
  [6, 22, 38],
  [6, 24, 42],
  [6, 26, 46],
  [6, 28, 50],
];

const sizeOf = (version: number): number => 17 + 4 * version;

/** The modules left for codewords once every function pattern and the version information are placed. */
function rawDataModules(version: number): number {
  let modules = (16 * version + 128) * version + 64;
  if (version >= 2) {
    const count = Math.floor(version / 7) + 2;
    modules -= (25 * count - 10) * count - 55;
    if (version >= 7) modules -= 36;
  }
  return modules;
}

const totalCodewords = (version: number): number => Math.floor(rawDataModules(version) / 8);

function blocksOf(version: number, level: QrErrorCorrection): readonly [number, number] {
  const entry = BLOCKS[level][version - 1];
  if (entry === undefined) throw new RangeError(`version ${version}`);
  return entry;
}

const dataCodewords = (version: number, level: QrErrorCorrection): number => {
  const [ec, blocks] = blocksOf(version, level);
  return totalCodewords(version) - ec * blocks;
};

// ---------------------------------------------------------------- Reed-Solomon over GF(256), x^8 + x^4 + x^3 + x^2 + 1

function multiply(x: number, y: number): number {
  let z = 0;
  for (let i = 7; i >= 0; i--) {
    z = (z << 1) ^ ((z >>> 7) * 0x11d);
    z ^= ((y >>> i) & 1) * x;
  }
  return z;
}

/** The generator polynomial of `degree`, (x − α⁰)(x − α¹)…, highest coefficient (always 1) left out. */
function generator(degree: number): number[] {
  const result = new Array<number>(degree).fill(0);
  result[degree - 1] = 1;
  let root = 1;
  for (let i = 0; i < degree; i++) {
    for (let j = 0; j < degree; j++) {
      result[j] = multiply(result[j] ?? 0, root);
      if (j + 1 < degree) result[j] = (result[j] ?? 0) ^ (result[j + 1] ?? 0);
    }
    root = multiply(root, 0x02);
  }
  return result;
}

/** The error correction codewords of a block: the remainder of its data by the generator. */
export function reedSolomon(data: readonly number[], degree: number): number[] {
  const divisor = generator(degree);
  const result = new Array<number>(degree).fill(0);
  for (const byte of data) {
    const factor = byte ^ (result.shift() ?? 0);
    result.push(0);
    for (let i = 0; i < degree; i++) result[i] = (result[i] ?? 0) ^ multiply(divisor[i] ?? 0, factor);
  }
  return result;
}

// ---------------------------------------------------------------- BCH codes of the format and version information

/** The 15 bits of the format information of a level and a mask, masked by 101010000010010. */
export function formatBits(level: QrErrorCorrection, mask: number): number {
  const data = (LEVEL_BITS[level] << 3) | mask;
  let rem = data;
  for (let i = 0; i < 10; i++) rem = (rem << 1) ^ ((rem >>> 9) * 0x537);
  return ((data << 10) | rem) ^ 0x5412;
}

/** The 18 bits of the version information, from version 7. */
export function versionBits(version: number): number {
  let rem = version;
  for (let i = 0; i < 12; i++) rem = (rem << 1) ^ ((rem >>> 11) * 0x1f25);
  return (version << 12) | rem;
}

// ---------------------------------------------------------------- the codewords

/** The data codewords of byte mode: mode, count, bytes, terminator, padding. */
function encodeData(bytes: Uint8Array, version: number, level: QrErrorCorrection): number[] {
  const capacity = dataCodewords(version, level) * 8;
  const bits: number[] = [];
  const push = (value: number, length: number): void => {
    for (let i = length - 1; i >= 0; i--) bits.push((value >>> i) & 1);
  };
  push(0b0100, 4);
  push(bytes.length, version <= 9 ? 8 : 16);
  for (const byte of bytes) push(byte, 8);
  push(0, Math.min(4, capacity - bits.length));
  push(0, (8 - (bits.length % 8)) % 8);
  for (let pad = 0xec; bits.length < capacity; pad ^= 0xec ^ 0x11) push(pad, 8);
  const out: number[] = [];
  for (let i = 0; i < bits.length; i += 8) out.push(bits.slice(i, i + 8).reduce((acc, bit) => (acc << 1) | bit, 0));
  return out;
}

/** The data split into blocks, each followed by its error correction, interleaved (8.6). */
function interleave(data: readonly number[], version: number, level: QrErrorCorrection): number[] {
  const [ec, count] = blocksOf(version, level);
  const total = totalCodewords(version);
  const shortBlocks = count - (total % count);
  const shortLength = Math.floor(total / count);
  const blocks: { data: number[]; ec: number[] }[] = [];
  for (let i = 0, k = 0; i < count; i++) {
    const length = shortLength - ec + (i < shortBlocks ? 0 : 1);
    const slice = data.slice(k, k + length);
    k += length;
    blocks.push({ data: slice, ec: reedSolomon(slice, ec) });
  }
  const out: number[] = [];
  for (let i = 0; i <= shortLength - ec; i++) {
    for (const block of blocks) {
      const codeword = block.data[i];
      if (codeword !== undefined) out.push(codeword);
    }
  }
  for (let i = 0; i < ec; i++) for (const block of blocks) out.push(block.ec[i] ?? 0);
  return out;
}

// ---------------------------------------------------------------- the matrix

class Matrix {
  readonly modules: boolean[][];
  readonly reserved: boolean[][];

  constructor(readonly size: number) {
    this.modules = Array.from({ length: size }, () => new Array<boolean>(size).fill(false));
    this.reserved = Array.from({ length: size }, () => new Array<boolean>(size).fill(false));
  }

  set(x: number, y: number, dark: boolean): void {
    const row = this.modules[y];
    const reserved = this.reserved[y];
    if (row === undefined || reserved === undefined) return;
    row[x] = dark;
    reserved[x] = true;
  }

  dark(x: number, y: number): boolean {
    return this.modules[y]?.[x] ?? false;
  }

  isReserved(x: number, y: number): boolean {
    return this.reserved[y]?.[x] ?? false;
  }
}

function drawFinder(m: Matrix, cx: number, cy: number): void {
  for (let dy = -4; dy <= 4; dy++) {
    for (let dx = -4; dx <= 4; dx++) {
      const x = cx + dx;
      const y = cy + dy;
      if (x < 0 || y < 0 || x >= m.size || y >= m.size) continue;
      const ring = Math.max(Math.abs(dx), Math.abs(dy));
      m.set(x, y, ring !== 2 && ring !== 4);
    }
  }
}

function drawFormat(m: Matrix, level: QrErrorCorrection, mask: number): void {
  const bits = formatBits(level, mask);
  const bit = (i: number): boolean => ((bits >>> i) & 1) === 1;
  const size = m.size;
  // Around the finder at the top left.
  for (let i = 0; i <= 5; i++) m.set(8, i, bit(i));
  m.set(8, 7, bit(6));
  m.set(8, 8, bit(7));
  m.set(7, 8, bit(8));
  for (let i = 9; i < 15; i++) m.set(14 - i, 8, bit(i));
  // The copy, split between the two other finders.
  for (let i = 0; i < 8; i++) m.set(size - 1 - i, 8, bit(i));
  for (let i = 8; i < 15; i++) m.set(8, size - 15 + i, bit(i));
  m.set(8, size - 8, true); // the dark module
}

function drawFunctionPatterns(m: Matrix, version: number): void {
  const size = m.size;
  for (let i = 0; i < size; i++) {
    m.set(6, i, i % 2 === 0);
    m.set(i, 6, i % 2 === 0);
  }
  drawFinder(m, 3, 3);
  drawFinder(m, size - 4, 3);
  drawFinder(m, 3, size - 4);
  const centres = ALIGNMENT[version - 1] ?? [];
  const last = centres.length - 1;
  centres.forEach((cy, i) => {
    centres.forEach((cx, j) => {
      if ((i === 0 && j === 0) || (i === 0 && j === last) || (i === last && j === 0)) return; // under a finder
      for (let dy = -2; dy <= 2; dy++) {
        for (let dx = -2; dx <= 2; dx++) m.set(cx + dx, cy + dy, Math.max(Math.abs(dx), Math.abs(dy)) !== 1);
      }
    });
  });
  drawFormat(m, 'M', 0); // reserves the area; written again once the mask is chosen
  if (version >= 7) {
    const bits = versionBits(version);
    for (let i = 0; i < 18; i++) {
      const dark = ((bits >>> i) & 1) === 1;
      const a = size - 11 + (i % 3);
      const b = Math.floor(i / 3);
      m.set(a, b, dark);
      m.set(b, a, dark);
    }
  }
}

/** The codewords placed two columns at a time, up then down, from the bottom right (8.7.3). */
function placeCodewords(m: Matrix, codewords: readonly number[]): void {
  const size = m.size;
  let i = 0;
  for (let right = size - 1; right >= 1; right -= 2) {
    if (right === 6) right = 5; // the vertical timing pattern
    const upward = ((right + 1) & 2) === 0;
    for (let v = 0; v < size; v++) {
      const y = upward ? size - 1 - v : v;
      for (let j = 0; j < 2; j++) {
        const x = right - j;
        if (m.isReserved(x, y)) continue;
        const codeword = codewords[i >>> 3];
        // The remainder bits after the last codeword stay light.
        const row = m.modules[y];
        if (row !== undefined) row[x] = codeword !== undefined && ((codeword >>> (7 - (i & 7))) & 1) === 1;
        i++;
      }
    }
  }
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

/** Applies a mask to the data modules; applying it twice takes it off. */
function applyMask(m: Matrix, mask: number): void {
  const condition = MASKS[mask];
  if (condition === undefined) throw new RangeError(`mask ${mask}`);
  for (let y = 0; y < m.size; y++) {
    const row = m.modules[y];
    if (row === undefined) continue;
    for (let x = 0; x < m.size; x++) if (!m.isReserved(x, y) && condition(x, y)) row[x] = !row[x];
  }
}

/** The penalty of a masked symbol (8.8.2): runs, blocks, finder-like patterns, balance. */
export function penalty(modules: readonly (readonly boolean[])[]): number {
  const size = modules.length;
  const at = (x: number, y: number): boolean => modules[y]?.[x] ?? false;
  let score = 0;
  const finderLike = [true, false, true, true, true, false, true];
  for (let line = 0; line < size; line++) {
    for (const horizontal of [true, false]) {
      const get = (k: number): boolean => (horizontal ? at(k, line) : at(line, k));
      // N1: five or more modules of one colour in a row, 3 + the excess.
      let run = 1;
      for (let k = 1; k <= size; k++) {
        if (k < size && get(k) === get(k - 1)) run++;
        else {
          if (run >= 5) score += 3 + (run - 5);
          run = 1;
        }
      }
      // N3: 1:1:3:1:1 with four light modules on either side (or the edge), 40 each.
      for (let k = 0; k + 7 <= size; k++) {
        if (!finderLike.every((dark, d) => get(k + d) === dark)) continue;
        const lightBefore = [1, 2, 3, 4].every((d) => k - d < 0 || !get(k - d));
        const lightAfter = [0, 1, 2, 3].every((d) => k + 7 + d >= size || !get(k + 7 + d));
        if (lightBefore) score += 40;
        if (lightAfter) score += 40;
      }
    }
  }
  // N2: every 2 × 2 block of one colour, 3 each.
  let dark = 0;
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      if (at(x, y)) dark++;
      if (x + 1 < size && y + 1 < size) {
        const c = at(x, y);
        if (at(x + 1, y) === c && at(x, y + 1) === c && at(x + 1, y + 1) === c) score += 3;
      }
    }
  }
  // N4: 10 for every 5 % the dark modules are away from half.
  const total = size * size;
  score += Math.floor(Math.abs(dark * 20 - total * 10) / total) * 10;
  return score;
}

/**
 * The QR code of `data`, in byte mode — a string is written as UTF-8 — at the
 * level asked, in the smallest version from 1 to 10 that holds it. Refuses data
 * that no version up to `maxVersion` holds at that level.
 */
export function encodeQr(data: string | Uint8Array, errorCorrection: QrErrorCorrection, options: QrOptions = {}): QrCode {
  if (LEVEL_BITS[errorCorrection] === undefined) {
    throw new InvoicePdfError('invalid_value', `${String(errorCorrection)} is not a QR error correction level: L, M, Q or H`);
  }
  const minVersion = options.minVersion ?? 1;
  const maxVersion = options.maxVersion ?? MAX_VERSION;
  if (!Number.isInteger(minVersion) || !Number.isInteger(maxVersion) || minVersion < 1 || maxVersion > MAX_VERSION || minVersion > maxVersion) {
    throw new InvoicePdfError('invalid_value', `QR versions ${minVersion} to ${maxVersion}: this encoder writes versions 1 to ${MAX_VERSION}`);
  }
  if (options.mask !== undefined && (!Number.isInteger(options.mask) || options.mask < 0 || options.mask > 7)) {
    throw new InvoicePdfError('invalid_value', `${options.mask} is not a QR mask pattern: 0 to 7`);
  }
  const bytes = typeof data === 'string' ? new TextEncoder().encode(data) : data;
  let version = minVersion;
  // Mode (4 bits) and count, then the bytes.
  const bitsNeeded = (v: number): number => 4 + (v <= 9 ? 8 : 16) + bytes.length * 8;
  while (bitsNeeded(version) > dataCodewords(version, errorCorrection) * 8) {
    if (version === maxVersion) {
      throw new InvoicePdfError(
        'invalid_value',
        `${bytes.length} bytes do not fit in a QR code of version ${maxVersion} at level ${errorCorrection}, the largest this encoder writes`,
      );
    }
    version++;
  }

  const codewords = interleave(encodeData(bytes, version, errorCorrection), version, errorCorrection);
  const m = new Matrix(sizeOf(version));
  drawFunctionPatterns(m, version);
  placeCodewords(m, codewords);

  let mask = options.mask ?? -1;
  if (mask < 0) {
    let best = Infinity;
    for (let candidate = 0; candidate < 8; candidate++) {
      applyMask(m, candidate);
      drawFormat(m, errorCorrection, candidate);
      const score = penalty(m.modules);
      if (score < best) {
        best = score;
        mask = candidate;
      }
      applyMask(m, candidate);
    }
  }
  applyMask(m, mask);
  drawFormat(m, errorCorrection, mask);
  return { version, errorCorrection, mask, size: m.size, modules: m.modules };
}
