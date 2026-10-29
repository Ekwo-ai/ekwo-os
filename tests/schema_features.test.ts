/**
 * `SCHEMA_FEATURES`, `supports()`, and what `onSocle()` does with them.
 *
 * `tests/schema_floor.test.ts` runs the packages against a real database at
 * the floor. This file holds the decisions themselves to account, without a
 * database: which version has which feature, and what a backend asks for, or
 * refuses, depending on the version its database answers — including the
 * answer nobody plans for, no answer at all.
 */

import { describe, expect, it } from 'vitest';
import {
  SCHEMA_FEATURES,
  SCHEMA_MIN,
  backendSupports,
  missingFeatures,
  onSocle,
  supports,
  type Backend,
  type SelectQuery,
} from '../packages/core/src/index.js';

describe('supports()', () => {
  it('answers from the version that introduced the feature', () => {
    expect(supports('0.20.0', 'tax_payee_name_i18n')).toBe(true);
    expect(supports('0.19.0', 'tax_payee_name_i18n')).toBe(false);
    expect(supports('0.21.0', 'agent_posting')).toBe(true);
    expect(supports('0.22.3', 'agent_posting')).toBe(true);
    expect(supports('0.20.9', 'agent_posting')).toBe(false);
  });

  it('never offers a feature on a version it cannot read', () => {
    for (const unknown of [null, undefined, '', '  ', 'next']) {
      expect(supports(unknown, 'tax_payee_name_i18n')).toBe(false);
    }
  });

  it('lists what a version lacks, in the order the features are declared', () => {
    expect(missingFeatures(SCHEMA_MIN)).toEqual(Object.keys(SCHEMA_FEATURES));
    expect(missingFeatures('0.20.0')).toEqual(['documents_in_one_statement', 'agent_posting', 'create_bank_account']);
    expect(missingFeatures('0.21.0')).toEqual(['create_bank_account']);
    expect(missingFeatures('0.25.0')).toEqual([]);
  });
});

/** A backend that records what it was asked and answers `version` for the marker. */
function recorder(version: string | Error): { inner: Backend; selects: SelectQuery[]; calls: string[] } {
  const selects: SelectQuery[] = [];
  const calls: string[] = [];
  const inner: Backend = {
    mode: 'sql',
    actingAs: undefined,
    async rpc<T>(fn: string): Promise<T[]> {
      calls.push(fn);
      if (fn === 'ekwo_schema_version') {
        if (version instanceof Error) throw version;
        return [version] as T[];
      }
      return [];
    },
    async rpcVoid(fn: string): Promise<void> {
      calls.push(fn);
    },
    async select<T>(query: SelectQuery): Promise<T[]> {
      selects.push(query);
      return [];
    },
    async insert<T>(): Promise<T[]> {
      return [];
    },
    async update<T>(): Promise<T[]> {
      return [];
    },
    async remove(): Promise<void> {},
    async close(): Promise<void> {},
  };
  return { inner, selects, calls };
}

const socle = async (): Promise<string> => 'ekwo';

describe('onSocle() on a database older than a feature', () => {
  it('leaves the columns of the feature out of a read, whatever their spelling', async () => {
    const { inner, selects } = recorder('0.20.0');
    const backend = onSocle(inner, socle);
    await backend.select({ table: 'companies', columns: ['id', 'agent_posting', 'name'] });
    await backend.select({ table: 'api_keys', columns: ['id', 'posting_mode::text', 'mode:posting_mode'] });
    // country-literal: `id` is the column of every table, not a country.
    expect(selects.map((s) => s.columns)).toEqual([['id', 'name'], ['id']]);
  });

  it('asks a table no feature touches without asking the version', async () => {
    const { inner, selects, calls } = recorder('0.20.0');
    const backend = onSocle(inner, socle);
    await backend.select({ table: 'accounts', columns: ['id', 'code'] });
    // country-literal: `id` is the column of every table, not a country.
    expect(selects[0]?.columns).toEqual(['id', 'code']);
    expect(calls).toEqual([]);
  });

  it('asks the version once, and only for a read that names a column of a feature', async () => {
    const { inner, calls } = recorder('0.20.0');
    const backend = onSocle(inner, socle);
    await backend.select({ table: 'companies', columns: ['name'] });
    expect(calls).toEqual([]);
    await backend.select({ table: 'companies', columns: ['name', 'agent_posting'] });
    await backend.select({ table: 'companies', columns: ['name', 'agent_posting'] });
    expect(calls.filter((c) => c === 'ekwo_schema_version')).toHaveLength(1);
  });

  it('leaves a module schema alone', async () => {
    const { inner, selects } = recorder('0.20.0');
    const backend = onSocle(inner, socle);
    await backend.select({ table: 'companies', schema: 'contracts', columns: ['id', 'agent_posting'] });
    // country-literal: `id` is the column of every table, not a country.
    expect(selects[0]?.columns).toEqual(['id', 'agent_posting']);
  });

  it('refuses a call and a write of the feature by name', async () => {
    const { inner, calls } = recorder('0.20.0');
    const backend = onSocle(inner, socle);
    await expect(backend.rpc('approve_document', { p_document_id: 'x' })).rejects.toThrow(
      /^schema_too_old_for: approve_document\(\) needs schema 0\.21\.0 \(agent_posting\), and this database is at 0\.20\.0/,
    );
    await expect(backend.update('companies', { agent_posting: 'review' }, [])).rejects.toThrow(
      /^schema_too_old_for: writing companies\.agent_posting/,
    );
    expect(calls).not.toContain('approve_document');
    expect(await backendSupports(backend, 'tax_payee_name_i18n')).toBe(true);
    expect(await backendSupports(backend, 'documents_in_one_statement')).toBe(false);
  });
});

describe('onSocle() on a database that does not say its version', () => {
  it('asks for everything, as this release always did, and asks again next time', async () => {
    const { inner, selects, calls } = recorder(new Error('permission denied for function ekwo_schema_version'));
    const backend = onSocle(inner, socle);
    await backend.select({ table: 'companies', columns: ['id', 'agent_posting'] });
    await backend.rpc('approve_document', { p_document_id: 'x' });
    // country-literal: `id` is the column of every table, not a country.
    expect(selects[0]?.columns).toEqual(['id', 'agent_posting']);
    expect(calls).toContain('approve_document');
    expect(calls.filter((c) => c === 'ekwo_schema_version').length).toBeGreaterThan(1);
    expect(await backend.schemaVersion()).toBeUndefined();
    expect(await backendSupports(backend, 'agent_posting')).toBe(true);
  });

  it('takes a backend that is not built by onSocle() to be at this release', async () => {
    const { inner } = recorder('0.19.0');
    expect(await backendSupports(inner, 'agent_posting')).toBe(true);
  });
});
