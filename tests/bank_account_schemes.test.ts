/**
 * A bank account is not an IBAN.
 *
 * The registry of `@ekwo-ai/core` is the one place that knows how each way of
 * identifying an account is read and checked, and a pack names the way its
 * banks use. Three things have to stay true together: the registry reads what
 * it claims to, the schema of a pack accepts exactly the keys the registry has,
 * and every pack that names a scheme names one the registry knows.
 *
 * The identifiers below are shapes that pass their check digit, not accounts.
 */

import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import {
  BANK_ACCOUNT_SCHEME_KEYS,
  FALLBACK_BANK_ACCOUNT_SCHEME,
  bankAccountScheme,
  readBankAccountIdentifier,
} from '@ekwo-ai/core';
import { allPacks, packsRoot } from './helpers/packs.js';

const read = (scheme: string | null, raw: string) => readBankAccountIdentifier(scheme, raw);

describe('the registry of bank account schemes', () => {
  it('reads an IBAN with its check digits, spaces and case ignored', () => {
    expect(read('iban', 'be71 0961 2345 6769')).toEqual({
      ok: true,
      scheme: 'iban',
      identifier: 'BE71096123456769',
    });
    const wrong = read('iban', 'BE71 0961 2345 6760');
    expect(wrong.ok).toBe(false);
  });

  it('reads a routing number and an account number as two parts', () => {
    expect(read('aba-routing-account', '021000021 123456789')).toEqual({
      ok: true,
      scheme: 'aba-routing-account',
      identifier: '021000021 123456789',
    });
    // Separators are only separators.
    expect(read('aba-routing-account', '021000021/123-456-789')).toMatchObject({
      ok: true,
      identifier: '021000021 123456789',
    });
    const wrong = read('aba-routing-account', '021000022 123456789');
    expect(wrong.ok).toBe(false);
  });

  it('reads a sort code and an account number', () => {
    expect(read('sort-code-account', '20-00-00 55779911')).toEqual({
      ok: true,
      scheme: 'sort-code-account',
      identifier: '200000 55779911',
    });
    expect(read('sort-code-account', '20-00-00 5577').ok).toBe(false);
  });

  it('reads a BSB, an IFSC, a CLABE and a Zengin account', () => {
    expect(read('bsb-account', '062-000 12345678')).toMatchObject({ ok: true, identifier: '062000 12345678' });
    expect(read('ifsc-account', 'sbin0001234 123456789012')).toMatchObject({
      ok: true,
      identifier: 'SBIN0001234 123456789012',
    });
    expect(read('clabe', '032180000118359719')).toMatchObject({ ok: true, identifier: '032180000118359719' });
    expect(read('clabe', '032180000118359710').ok).toBe(false);
    expect(read('zengin', '0009-001-1234567')).toMatchObject({ ok: true, identifier: '0009 001 1234567' });
    expect(read('transit-institution-account', '00012-003-1234567')).toMatchObject({
      ok: true,
      identifier: '00012 003 1234567',
    });
  });

  it('never falls back to an IBAN: no scheme is a free-text account number', () => {
    expect(bankAccountScheme(null)?.key).toBe(FALLBACK_BANK_ACCOUNT_SCHEME);
    expect(bankAccountScheme(undefined)?.key).toBe(FALLBACK_BANK_ACCOUNT_SCHEME);
    expect(read(null, '  12-345 678  ')).toEqual({
      ok: true,
      scheme: FALLBACK_BANK_ACCOUNT_SCHEME,
      identifier: '12-345 678',
    });
    expect(read(null, '   ').ok).toBe(false);
    expect(bankAccountScheme(null)?.prompt).not.toMatch(/iban/i);
  });

  it('refuses a scheme it does not know rather than borrowing another', () => {
    expect(bankAccountScheme('made-up')).toBeUndefined();
    const refused = read('made-up', '1234');
    expect(refused.ok).toBe(false);
    expect(refused.ok ? '' : refused.error).toMatch(/unknown_bank_account_scheme/);
  });
});

describe('the schemes a pack may declare', () => {
  it('are exactly the keys of the registry', async () => {
    const schema = JSON.parse(await readFile(join(packsRoot, 'schema', 'pack.1.json'), 'utf8')) as {
      $defs: { bank: { properties: { account_scheme: { enum: string[] } } } };
    };
    expect([...schema.$defs.bank.properties.account_scheme.enum].sort()).toEqual(
      [...BANK_ACCOUNT_SCHEME_KEYS].sort(),
    );
  });

  it('are known to the registry in every pack that declares one', () => {
    for (const pack of allPacks) {
      const declared = pack.documents.bank_account_scheme;
      if (declared === null) continue;
      expect(bankAccountScheme(declared), `${pack.slug} declares ${declared}`).toBeDefined();
    }
  });
});
