/**
 * A certificate a buyer handed over, recorded and listed through the tools.
 *
 * `record_tax_certificate` writes a row of `contact_tax_certificates` — once
 * under a caller's reference — and `list_tax_certificates` reads them back
 * with the contact's name beside its id. Whether a sale posts under one is the
 * database's to decide, and `tests/buyer_certificate.test.ts` holds it to that.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { SCHEMA_FEATURES } from '../../packages/core/src/index.js';
import { readTools, writeTools, type Backend } from '../../packages/mcp/src/index.js';
import { freshDatabase } from '../helpers/db.js';
import { newCompany, newContact, type Fixture } from '../helpers/factory.js';
import { somePack } from '../helpers/packs.js';
import { backendFor, record } from './helpers.js';

const pack = somePack;

let db: PGlite;
let fx: Fixture;
let backend: Backend;
let buyer: string;
let other: string;

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: pack.manifest.country, name: 'Certificate tools' });
  backend = backendFor(db, fx.ownerId);
  buyer = await newContact(db, fx.companyId, { country: pack.manifest.country, name: 'Example Reseller' });
  other = await newContact(db, fx.companyId, { country: pack.manifest.country, name: 'Example Retailer' });
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('record_tax_certificate and list_tax_certificates', () => {
  // Read and written on a schema that says it has them
  // (`SCHEMA_FEATURES.buyer_certificates`). Until the release that brings
  // them redefines `ekwo_schema_version()`, this database says the version it
  // will be for these tests, and says its own again after them.
  let definition: string;
  beforeAll(async () => {
    const version = await db.query<{ definition: string }>(
      `select pg_get_functiondef('ekwo.ekwo_schema_version()'::regprocedure) as definition`,
    );
    definition = version.rows[0]!.definition;
    await db.query(
      `create or replace function ekwo.ekwo_schema_version() returns text language sql immutable as $$ select '${SCHEMA_FEATURES.buyer_certificates.since}'::text $$`,
    );
    backend = backendFor(db, fx.ownerId);
  });
  afterAll(async () => {
    await db.query(definition);
  });

  it('records a certificate once under a reference, and lists it with the name of its contact', async () => {
    const args = {
      company_id: fx.companyId,
      contact_id: buyer,
      reference: 'EXAMPLE-0001',
      valid_from: '2026-01-01',
      valid_to: '2026-12-31',
      client_ref: 'cert-1',
    };
    const first = record(await writeTools.recordTaxCertificate(backend, args));
    expect(first['certificate']).toMatchObject({
      contact_id: buyer,
      reference: 'EXAMPLE-0001',
      territory_code: null,
      valid_from: '2026-01-01',
      valid_to: '2026-12-31',
    });
    expect(first['replayed']).toBeUndefined();

    const again = record(await writeTools.recordTaxCertificate(backend, args));
    expect(again['replayed']).toBe(true);

    await writeTools.recordTaxCertificate(backend, {
      company_id: fx.companyId,
      contact_id: other,
      reference: 'EXAMPLE-0002',
      valid_from: '2026-03-01',
    });

    const all = record(await readTools.listTaxCertificates(backend, { company_id: fx.companyId }));
    expect(all['count']).toBe(2);
    const one = record(await readTools.listTaxCertificates(backend, { company_id: fx.companyId, contact_id: buyer }));
    expect(one['certificates']).toEqual([
      expect.objectContaining({ reference: 'EXAMPLE-0001', contact_name: 'Example Reseller' }),
    ]);
  });

  it('refuses a certificate that ends before it starts, in the database\'s words', async () => {
    await expect(
      writeTools.recordTaxCertificate(backend, {
        company_id: fx.companyId,
        contact_id: buyer,
        reference: 'EXAMPLE-0003',
        valid_from: '2026-06-30',
        valid_to: '2026-06-01',
      }),
    ).rejects.toThrow(/contact_tax_certificates_period/);
  });
});
