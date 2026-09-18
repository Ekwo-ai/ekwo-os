import { describe, expect, it } from 'vitest';
// @ts-expect-error — a plain script of the repository, with no types of its own
import { publishOrder, staleRanges, workspaces } from '../scripts/publish.mjs';

/**
 * What a release publishes is read from the workspaces. The list used to be
 * written by hand in `docs/releasing.md`, and a brick was once in the
 * repository and not in the list.
 */

interface Entry {
  name: string;
  version: string;
  directory: string;
  needs: string[];
}

describe('what a release publishes', () => {
  const order = publishOrder() as Entry[];

  it('is every workspace that is not private, and nothing else', () => {
    const expected = (workspaces() as { pkg: { name: string; private?: boolean } }[])
      .filter(({ pkg }) => pkg.private !== true)
      .map(({ pkg }) => pkg.name)
      .sort();
    expect(order.map((entry) => entry.name).sort()).toEqual(expected);
    expect(new Set(order.map((entry) => entry.name)).size).toBe(order.length);
    expect(order.length).toBeGreaterThan(0);
  });

  it('puts a package after every package of this repository it depends on', () => {
    const position = new Map(order.map((entry, index) => [entry.name, index]));
    for (const entry of order) {
      for (const needed of entry.needs) {
        expect(position.get(needed), `${entry.name} needs ${needed}`).toBeLessThan(
          position.get(entry.name) as number,
        );
      }
    }
    // Not vacuous: something here does depend on something else.
    expect(order.some((entry) => entry.needs.length > 0)).toBe(true);
  });

  it('holds no range on one of its own packages that the repository no longer satisfies', () => {
    expect(staleRanges()).toEqual([]);
  });
});
