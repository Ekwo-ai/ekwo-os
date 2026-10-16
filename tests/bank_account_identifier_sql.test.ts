/**
 * The schema reads a bank account identifier the way the core does.
 *
 * `read_bank_account_identifier()` is what `create_bank_account()` asks, so a
 * web application calling the REST API gets the same canonical form as the
 * command line and the MCP server, which read with `readBankAccountIdentifier`
 * of `@ekwo-ai/core`. Two readers are two truths unless something holds them
 * together: this file runs both over the same inputs, scheme by scheme, and
 * expects the same identifier or the same refusal, word for word. A scheme
 * added to the registry and not to the function fails the first test.
 *
 * The identifiers are shapes that pass their check digit, not accounts.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { BANK_ACCOUNT_SCHEME_KEYS, readBankAccountIdentifier } from '@ekwo-ai/core';
import { freshDatabase } from './helpers/db.js';

/** One identifier each scheme accepts, as a person would type it. */
const VALID: Record<string, string> = {
  iban: 'be71 0961 2345 6769',
  'aba-routing-account': '021000021/123-456-789',
  'sort-code-account': '20-00-00 55779911',
  'bsb-account': '062-000 12345678',
  'ifsc-account': 'sbin0001234 123456789012',
  clabe: '032180000118359719',
  zengin: '0009-001-1234567',
  'transit-institution-account': '00012-003-1234567',
  'account-number': '  12-345   678  ',
};

/** What a person gets wrong: the last digit, a digit too many, too few, a letter, nothing. */
function variants(valid: string): string[] {
  const last = valid.trimEnd().slice(-1);
  const other = last === '9' ? '8' : '9';
  return [
    valid,
    valid.toUpperCase(),
    valid.trimEnd().slice(0, -1) + other,
    valid.trimEnd() + '1',
    valid.trimEnd() + '12345678901234567890',
    valid.slice(0, 6),
    valid.replace(/[0-9]/, 'X'),
    '',
    '   ',
    'x'.repeat(70),
  ];
}

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase({ seed: false, modules: false });
});

afterAll(async () => {
  await db.close();
});

async function sqlRead(scheme: string | null, raw: string): Promise<{ ok: true; identifier: string } | { ok: false; error: string }> {
  try {
    const result = await db.query<{ identifier: string }>(
      'select read_bank_account_identifier($1, $2) as identifier',
      [scheme, raw],
    );
    return { ok: true, identifier: String(result.rows[0]?.identifier) };
  } catch (error) {
    return { ok: false, error: (error as Error).message };
  }
}

describe('read_bank_account_identifier()', () => {
  it('knows every scheme the registry of the core knows', () => {
    expect(Object.keys(VALID).sort()).toEqual([...BANK_ACCOUNT_SCHEME_KEYS].sort());
  });

  for (const scheme of BANK_ACCOUNT_SCHEME_KEYS) {
    it(`reads ${scheme} as the core does, refusals included`, async () => {
      const valid = VALID[scheme] as string;
      expect(readBankAccountIdentifier(scheme, valid).ok).toBe(true);
      for (const raw of variants(valid)) {
        const core = readBankAccountIdentifier(scheme, raw);
        const sql = await sqlRead(scheme, raw);
        expect({ raw, ...sql }).toEqual(
          core.ok ? { raw, ok: true, identifier: core.identifier } : { raw, ok: false, error: core.error },
        );
      }
    });
  }

  it('reads a null scheme as a free-text account number, never as an IBAN', async () => {
    expect(await sqlRead(null, ' 12-345   678 ')).toEqual({ ok: true, identifier: '12-345 678' });
    expect(await sqlRead(null, 'BE71 0961 2345 6760')).toEqual({ ok: true, identifier: 'BE71 0961 2345 6760' });
  });

  it('refuses a scheme it does not read, by name', async () => {
    const core = readBankAccountIdentifier('no-such-scheme', '123');
    expect(await sqlRead('no-such-scheme', '123')).toEqual({ ok: false, error: core.ok ? '' : core.error });
  });
});
