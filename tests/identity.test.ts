/**
 * The one key no surface accepts, read where there is no `Buffer`.
 *
 * `isServiceRoleKey()` decoded the payload of a JWT with `Buffer` inside a
 * `try`. In Node that works; in a browser — where a web application built on
 * `@ekwo-ai/core` asks the same question about the same pasted key — the
 * identifier is not defined, the call raised, and the `catch` answered *no*.
 * A guard that answers no when it cannot tell is not a guard, so these tests
 * run the interesting half with the global taken away.
 *
 * Nothing key-shaped is written down here: the segments are encoded at run
 * time, through `btoa`, which is in Node and in every browser and is not the
 * thing under test.
 */

import { afterEach, describe, expect, it, vi } from 'vitest';
import { isServiceRoleKey } from '../packages/core/src/index.js';

/** One segment of a JWT: JSON, base64url, unpadded. */
function segment(value: unknown): string {
  return btoa(JSON.stringify(value)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

/** A JWT-shaped key carrying a role claim. No signature is ever checked. */
function keyWithRole(role: string): string {
  return [segment({ alg: 'HS256', typ: 'JWT' }), segment({ iss: 'supabase', role }), 'nosig'].join(
    '.',
  );
}

/** What a browser has: no `Buffer`, and a `ReferenceError` for anything that asks. */
function withoutBuffer<T>(body: () => T): T {
  const had = Object.prototype.hasOwnProperty.call(globalThis, 'Buffer');
  const kept = (globalThis as Record<string, unknown>).Buffer;
  delete (globalThis as Record<string, unknown>).Buffer;
  try {
    expect(typeof (globalThis as Record<string, unknown>).Buffer).toBe('undefined');
    return body();
  } finally {
    if (had) (globalThis as Record<string, unknown>).Buffer = kept;
  }
}

afterEach(() => {
  vi.unstubAllGlobals();
});

describe('recognising a service_role key', () => {
  it('reads both shapes Supabase has issued', () => {
    expect(isServiceRoleKey(keyWithRole('service_role'))).toBe(true);
    expect(isServiceRoleKey('sb_secret_abcdef')).toBe(true);
  });

  it('lets a publishable key through, in both shapes', () => {
    expect(isServiceRoleKey(keyWithRole('anon'))).toBe(false);
    expect(isServiceRoleKey('sb_publishable_abcdef')).toBe(false);
  });

  it('is not confused by something that is not a key at all', () => {
    expect(isServiceRoleKey('')).toBe(false);
    expect(isServiceRoleKey('a-long-password')).toBe(false);
    // Two dots and three pieces, and neither of these is presenting a token.
    expect(isServiceRoleKey('postgresql://someone@db.example.test:5432/postgres')).toBe(false);
    expect(isServiceRoleKey('correct.horse.battery')).toBe(false);
  });

  it('asks the header whether this is a token at all', () => {
    const payload = segment({ role: 'service_role' });
    expect(isServiceRoleKey(`${segment({ alg: 'HS256' })}.${payload}.nosig`)).toBe(true);
    // No `alg`: whatever this is, it is not a JWT presenting itself as one.
    expect(isServiceRoleKey(`${segment({ typ: 'JWT' })}.${payload}.nosig`)).toBe(false);
    expect(isServiceRoleKey(`nonsense.${payload}.nosig`)).toBe(false);
  });
});

describe('in a browser, where there is no Buffer', () => {
  it('still reads the payload rather than answering no', () => {
    const service = keyWithRole('service_role');
    const anon = keyWithRole('anon');
    withoutBuffer(() => {
      expect(isServiceRoleKey(service)).toBe(true);
      expect(isServiceRoleKey(anon)).toBe(false);
    });
  });

  it('gives the same answers as in Node, key for key', () => {
    const keys = [
      keyWithRole('service_role'),
      keyWithRole('anon'),
      keyWithRole('authenticated'),
      'sb_secret_abcdef',
      'sb_publishable_abcdef',
      'a-long-password',
    ];
    const inNode = keys.map(isServiceRoleKey);
    const inBrowser = withoutBuffer(() => keys.map(isServiceRoleKey));
    expect(inBrowser).toEqual(inNode);
  });
});

describe('a payload that cannot be read', () => {
  // The shape is the claim. A key with three segments is presented as a JWT,
  // and one whose middle segment says nothing readable is a claim this
  // function cannot clear — so it does not clear it. The cost is an
  // unusable key turned away with a sentence about service_role.
  it('is refused rather than cleared, when the key is shaped like a JWT', () => {
    expect(isServiceRoleKey(`${segment({ alg: 'none' })}.!!!not-base64url!!!.nosig`)).toBe(true);
    expect(isServiceRoleKey(`${segment({ alg: 'none' })}.${btoa('not json at all')}.nosig`)).toBe(
      true,
    );
    expect(isServiceRoleKey(`${segment({ alg: 'none' })}.${segment(42)}.nosig`)).toBe(true);
    expect(isServiceRoleKey(`${segment({ alg: 'none' })}.${segment(null)}.nosig`)).toBe(true);
  });

  it('is refused in a browser too, which is where it was cleared before', () => {
    const key = `${segment({ alg: 'none' })}.!!!not-base64url!!!.nosig`;
    expect(withoutBuffer(() => isServiceRoleKey(key))).toBe(true);
  });

  it('takes a padded segment, which `Buffer` also took', () => {
    // `btoa` pads and a JWT does not; a key that arrives padded is still a key.
    const padded = btoa(JSON.stringify({ role: 'service_role' }));
    expect(padded.endsWith('=')).toBe(true);
    expect(isServiceRoleKey(`${segment({ alg: 'none' })}.${padded}.nosig`)).toBe(true);
  });
});
