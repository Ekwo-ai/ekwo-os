/**
 * The analytic plan through the tools: `list_analytic_axes` and
 * `analytic_report`, as a member signed in under row level security.
 *
 * What the report says is `tests/analytics.test.ts`; here it is that the tool
 * finds an axis by its code, puts the unassigned part beside the values
 * rather than among them, refuses an axis the company does not have by name,
 * and answers a viewer as it answers an accountant.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { readTools, type Backend } from '../../packages/mcp/src/index.js';
import { freshDatabase, one } from '../helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from '../helpers/factory.js';
import { packWhere, roleOf } from '../helpers/packs.js';
import { backendFor, list, record } from './helpers.js';

let db: PGlite;
let company: Fixture;
let accountant: Backend;
let viewer: Backend;

beforeAll(async () => {
  const pack = packWhere('names a sales account', (p) => typeof p.manifest.defaults.roles['sales'] === 'string');
  db = await freshDatabase();
  company = await newCompany(db, { country: pack.manifest.country, name: 'By activity, through the tools' });
  const accountantId = crypto.randomUUID();
  const viewerId = crypto.randomUUID();
  await db.query(
    `insert into company_members (company_id, user_id, role) values ($1, $2, 'accountant'), ($1, $3, 'viewer')`,
    [company.companyId, accountantId, viewerId],
  );
  accountant = backendFor(db, accountantId);
  viewer = backendFor(db, viewerId);

  const axis = await one<{ id: string }>(
    db,
    `insert into analytic_axes (company_id, code, name) values ($1, 'PROJECT', 'Project') returning id`,
    [company.companyId],
  );
  const value = await one<{ id: string }>(
    db,
    `insert into analytic_values (company_id, axis_id, code, name) values ($1, $2, 'ALPHA', 'Alpha') returning id`,
    [company.companyId, axis.id],
  );
  const customer = await newContact(db, company.companyId, { country: pack.manifest.country });
  const invoice = await newDocument(db, company.companyId, {
    docType: 'sale_invoice',
    contactId: customer,
    date: '2026-03-10',
    lines: [
      { name: 'Alpha', unitPrice: 400, accountCode: roleOf(pack, 'sales'), taxCode: null },
      { name: 'Nobody', unitPrice: 100, accountCode: roleOf(pack, 'sales'), taxCode: null },
    ],
  });
  await db.query(
    `insert into document_line_analytics (company_id, document_line_id, analytic_value_id)
     select $1, l.id, $3 from document_lines l where l.document_id = $2 and l.name = 'Alpha'`,
    [company.companyId, invoice, value.id],
  );
  await db.query(`select post_document($1)`, [invoice]);
}, 180_000);

afterAll(async () => {
  await db.close();
});

describe('list_analytic_axes', () => {
  it('names each axis with its values', async () => {
    const answer = record(await readTools.listAnalyticAxes(viewer, { company_id: company.companyId }));
    const axes = list(answer['axes']);
    expect(axes.map((axis) => axis['code'])).toEqual(['PROJECT']);
    expect(list(axes[0]!['values']).map((value) => value['code'])).toEqual(['ALPHA']);
    expect(axes[0]!['required_on']).toBe('none');
  });
});

describe('analytic_report', () => {
  it('finds the axis by its code and puts the unassigned part and the total beside the values', async () => {
    const answer = record(
      await readTools.analyticReport(accountant, { company_id: company.companyId, axis: 'PROJECT', from: '2026-01-01', to: '2026-12-31' }),
    );
    expect(record(answer['axis'])['code']).toBe('PROJECT');
    expect(list(answer['values']).map((value) => [value['code'], value['income'], value['expense'], value['result']])).toEqual([
      ['ALPHA', '400.00', '0.00', '400.00'],
    ]);
    expect(answer['unassigned']).toEqual({
      income: '100.00',
      expense: '0.00',
      result: '100.00',
      fixed_assets: '0.00',
      direct_income: '100.00',
      direct_expense: '0.00',
      direct_result: '100.00',
      direct_fixed_assets: '0.00',
    });
    expect(record(answer['total'])['result']).toBe('500.00');
    expect(list(answer['values'])[0]).toMatchObject({ level: 0, direct_result: '400.00' });
  });

  it('answers a viewer as it answers an accountant', async () => {
    const args = { company_id: company.companyId, axis: 'PROJECT', from: '2026-01-01', to: '2026-12-31' };
    expect(await readTools.analyticReport(viewer, args)).toEqual(await readTools.analyticReport(accountant, args));
  });

  it('refuses an axis the company does not have, by name', async () => {
    await expect(
      readTools.analyticReport(accountant, { company_id: company.companyId, axis: 'NOWHERE', from: '2026-01-01', to: '2026-12-31' }),
    ).rejects.toThrow(/unknown_analytic_axis/);
  });
});
