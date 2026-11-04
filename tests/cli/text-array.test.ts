/**
 * `readTextArray`: a Postgres text array read the same from every client,
 * whether it arrives decoded or as its literal.
 */

import { describe, expect, it } from 'vitest';
import { InventoryError, readTextArray } from '../../packages/cli/src/inventory.js';

describe('readTextArray', () => {
  it('keeps an array as it is', () => {
    expect(readTextArray(['a', 'b'])).toEqual(['a', 'b']);
  });

  it('reads the literal into the same array', () => {
    expect(readTextArray('{a,b}')).toEqual(readTextArray(['a', 'b']));
  });

  it('reads an empty literal as no labels', () => {
    expect(readTextArray('{}')).toEqual([]);
  });

  it('keeps a comma, a quote and a backslash inside a quoted element', () => {
    expect(readTextArray('{"one, two","say \\"hi\\"","back\\\\slash",plain}')).toEqual([
      'one, two',
      'say "hi"',
      'back\\slash',
      'plain',
    ]);
  });

  it('keeps an empty quoted element and a quoted "NULL", drops a bare NULL', () => {
    expect(readTextArray('{"",NULL,"NULL"}')).toEqual(['', 'NULL']);
  });

  it('refuses what is not an array literal, by name', () => {
    expect(() => readTextArray('a,b')).toThrow(InventoryError);
  });
});
