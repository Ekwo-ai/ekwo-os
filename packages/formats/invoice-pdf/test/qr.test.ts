/**
 * The QR encoder against vectors published for ISO/IEC 18004, then the
 * symbol it writes for a verification URL, module by module.
 */

import { describe, expect, it } from 'vitest';
import { encodeQr, InvoicePdfError } from '../src/index.js';
import { formatBits, penalty, reedSolomon, versionBits } from '../src/qr.js';

const bits = (value: number, length: number): string => value.toString(2).padStart(length, '0');

describe('the published vectors', () => {
  it('computes the error correction of "HELLO WORLD" at 1-M as the worked example of the standard does', () => {
    // The 16 data codewords of "HELLO WORLD" in alphanumeric mode, version 1-M, and their 10 error correction codewords.
    const data = [32, 91, 11, 120, 209, 114, 220, 77, 67, 64, 236, 17, 236, 17, 236, 17];
    expect(reedSolomon(data, 10)).toEqual([196, 35, 39, 119, 235, 215, 231, 226, 93, 23]);
  });

  it('writes the 32 format information strings of the table of the standard', () => {
    const table: Record<'L' | 'M' | 'Q' | 'H', string[]> = {
      L: ['111011111000100', '111001011110011', '111110110101010', '111100010011101', '110011000101111', '110001100011000', '110110001000001', '110100101110110'],
      M: ['101010000010010', '101000100100101', '101111001111100', '101101101001011', '100010111111001', '100000011001110', '100111110010111', '100101010100000'],
      Q: ['011010101011111', '011000001101000', '011111100110001', '011101000000110', '010010010110100', '010000110000011', '010111011011010', '010101111101101'],
      H: ['001011010001001', '001001110111110', '001110011100111', '001100111010000', '000011101100010', '000001001010101', '000110100001100', '000100000111011'],
    };
    for (const level of ['L', 'M', 'Q', 'H'] as const) {
      expect(table[level].map((_, mask) => bits(formatBits(level, mask), 15))).toEqual(table[level]);
    }
  });

  it('writes the version information of versions 7 to 10 as the table of the standard', () => {
    expect([7, 8, 9, 10].map((v) => bits(versionBits(v), 18))).toEqual([
      '000111110010010100',
      '001000010110111100',
      '001001101010011001',
      '001010010011010011',
    ]);
  });
});

describe('a verification URL', () => {
  const url = 'https://example.com/verify?id=A-0001&total=121.00';

  it('is the symbol an independent encoder writes, and an independent decoder reads back', () => {
    // Version 4-M, mask 2: checked module by module against another encoder
    // given the same version and mask, and decoded back to the URL by a reader.
    const expected = [
      '#######...##..#...####.#..#######',
      '#.....#...##...#..#.....#.#.....#',
      '#.###.#.##.#..###..###..#.#.###.#',
      '#.###.#.#.###..#..#.......#.###.#',
      '#.###.#.#.##.####...#.###.#.###.#',
      '#.....#.#.....#....#.##...#.....#',
      '#######.#.#.#.#.#.#.#.#.#.#######',
      '........#.#...#.#..###..#........',
      '#.#####..#.##.#..#.##.#...#####..',
      '###.##..#...##..##.###.#..##.####',
      '#.###.##.#.#.#####..##...##.#.#..',
      '######.####..#.#.######..##.###..',
      '...#.####.....#.#..##..#.#.###...',
      '####...###.###.#..#..#.####...###',
      '####..###.#.#..####.###..###..##.',
      '...#...##.##.###..#..##..##...#..',
      '.##..###.##.#..#.#.....###.###..#',
      '.##..#...#.##...#.##...#..##.####',
      '#..#..#.##....###.#.#.#..#.##.#..',
      '#.#.#..#....#.#.#...##..#..#####.',
      '.#...##..####.....##.....#..##.##',
      '###.#...#.#...####..#.###.#...#.#',
      '#..##.#.#####.#...##..#.##.##.##.',
      '#..###..##.#.#..#..###...#....##.',
      '#....######.#.#.##.#..########...',
      '........##.#..#..#####..#...#.#.#',
      '#######...########..##.##.#.#.#..',
      '#.....#.#.#.#.##.#####.##...####.',
      '#.###.#.#.####..#..#....######...',
      '#.###.#.#..#.#.#..#..##.##..#.###',
      '#.###.#.#....#####.......###.##..',
      '#.....#..#..##.#..#..##.....#.#..',
      '#######.#.#.#..###....####.#...#.',
    ];
    const code = encodeQr(url, 'M');
    expect([code.version, code.size, code.mask, code.errorCorrection]).toEqual([4, 33, 2, 'M']);
    expect(code.modules.map((row) => row.map((dark) => (dark ? '#' : '.')).join(''))).toEqual(expected);
  });

  it('carries its format information twice, and both copies say the level and the mask', () => {
    const code = encodeQr(url, 'M');
    const at = (x: number, y: number): number => (code.modules[y]?.[x] === true ? 1 : 0);
    const n = code.size;
    let first = 0;
    let second = 0;
    // Bit i of each copy, in the positions of figure 25.
    const firstCopy = (i: number): [number, number] => (i <= 5 ? [8, i] : i === 6 ? [8, 7] : i === 7 ? [8, 8] : i === 8 ? [7, 8] : [14 - i, 8]);
    const secondCopy = (i: number): [number, number] => (i < 8 ? [n - 1 - i, 8] : [8, n - 15 + i]);
    for (let i = 0; i < 15; i++) {
      first |= at(...firstCopy(i)) << i;
      second |= at(...secondCopy(i)) << i;
    }
    expect(first).toBe(formatBits('M', code.mask));
    expect(second).toBe(first);
    expect(at(8, n - 8)).toBe(1); // the dark module
  });

  it('takes the mask of the lowest penalty', () => {
    const scores = [0, 1, 2, 3, 4, 5, 6, 7].map((mask) => penalty(encodeQr(url, 'M', { mask }).modules));
    expect(encodeQr(url, 'M').mask).toBe(scores.indexOf(Math.min(...scores)));
  });
});

describe('versions and levels', () => {
  it('takes the smallest version that holds the data at the level asked, and never raises the level', () => {
    expect(encodeQr('a'.repeat(14), 'M').version).toBe(1);
    expect(encodeQr('a'.repeat(15), 'M').version).toBe(2);
    expect(encodeQr('a'.repeat(213), 'M').version).toBe(10);
    expect(encodeQr('a'.repeat(17), 'L').errorCorrection).toBe('L');
  });

  it('writes the version information from version 7', () => {
    const code = encodeQr('a'.repeat(110), 'M'); // 106 bytes is the most version 6-M holds
    expect(code.version).toBe(7);
    const at = (x: number, y: number): number => (code.modules[y]?.[x] === true ? 1 : 0);
    let below = 0;
    let right = 0;
    for (let i = 0; i < 18; i++) {
      below |= at(Math.floor(i / 3), code.size - 11 + (i % 3)) << i;
      right |= at(code.size - 11 + (i % 3), Math.floor(i / 3)) << i;
    }
    expect([below, right]).toEqual([versionBits(7), versionBits(7)]);
  });

  it('writes a string as UTF-8', () => {
    expect(encodeQr('é'.repeat(7), 'M').version).toBe(1); // 14 bytes
    expect(encodeQr('é'.repeat(8), 'M').version).toBe(2); // 16 bytes
  });

  it('refuses what version 10 does not hold, an unknown level and a mask out of range', () => {
    for (const run of [
      () => encodeQr('a'.repeat(214), 'M'),
      () => encodeQr('a', 'X' as 'M'),
      () => encodeQr('a', 'M', { mask: 8 }),
      () => encodeQr('a', 'M', { maxVersion: 11 }),
    ]) {
      expect(run).toThrow(InvoicePdfError);
    }
    expect(() => encodeQr('a'.repeat(214), 'M')).toThrow(/214 bytes do not fit/);
  });
});
