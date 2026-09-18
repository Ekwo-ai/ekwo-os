/**
 * The one way a document arrives already posted, and what it is afterwards.
 *
 * Nobody inserts a posted document or a posted entry: the guards refuse it to
 * everybody. `import_company()` is how books kept elsewhere arrive, and it
 * needs no exemption from them — it switches the triggers of the tables it
 * fills off, by name, for the time of the load. These tests hold the three
 * things that arrangement has to guarantee, and one it has to be able to show:
 *
 *   1. the guards are back on afterwards — after a load that succeeded and
 *      after one that failed;
 *   2. what arrived is frozen like everything else, for the administrator who
 *      loaded it too;
 *   3. **the archive wins over the tax of the day.** The invoice is posted at
 *      one rate, the tax moves afterwards, the company leaves: the archive
 *      carries a tax at the new rate and a line frozen at the old one, and the
 *      line that arrives is the old one — the contradiction a load that went
 *      through a draft would have resolved the wrong way.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Pack } from '../packages/cli/src/index.js';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { exportAs, importAs, reseal, type Archive } from './helpers/company-archive.js';
import { newCompany, newContact, newDocument, newInstanceAdmin, newUser, taxId } from './helpers/factory.js';
import { packWhere, roleOf } from './helpers/packs.js';

const GUARDS = ['documents_guard_posted', 'document_lines_00_guard_posted', 'entries_guard_posted', 'entry_lines_guard_posted'];

type PackTax = Pack['taxes'][number];
const standardOf = (pack: Pack): PackTax | undefined =>
  pack.taxes
    .filter((tax) => tax.scope === 'sale' && tax.treatment === 'domestic' && tax.amount_type === 'percent' && tax.rate > 0 && tax.valid_to === null && !tax.price_include)
    .sort((x, y) => y.rate - x.rate)[0];

let a: PGlite;
let b: PGlite;
let pack: Pack;
let standard: PackTax;
let companyId: string;
let documentId: string;
let adminOfB: string;
let ownerInB: string;
let archive: string;
let posted: { line: unknown; totals: unknown };

const read = async (db: PGlite) => ({
  line: await one(db, `select vat_category, vat_rate::text, amount_untaxed::text from document_lines where document_id = $1`, [documentId]),
  totals: await one(db, `select state, amount_untaxed::text, amount_tax::text, amount_total::text from documents where id = $1`, [documentId]),
});

const guardsOf = (db: PGlite) =>
  rows<{ tgname: string; tgenabled: string }>(
    db,
    `select tgname, tgenabled from pg_trigger where tgname = any ($1) order by tgname`,
    [GUARDS],
  );

beforeAll(async () => {
  pack = packWhere('charges a standard rate on an ordinary sale', (p) => standardOf(p) !== undefined);
  standard = standardOf(pack) as PackTax;
  a = await freshDatabase();
  b = await freshDatabase();

  const company = await newCompany(a, { country: pack.manifest.country, name: 'Leaves with a frozen line' });
  companyId = company.companyId;
  await a.query(`insert into auth.users (id, email) values ($1, 'owner@archive.test') on conflict do nothing`, [company.ownerId]);
  const contact = await newContact(a, companyId, { country: pack.manifest.country });
  documentId = await newDocument(a, companyId, {
    docType: 'sale_invoice',
    contactId: contact,
    lines: [{ unitPrice: 200, taxCode: standard.code, accountCode: roleOf(pack, 'sales') }],
  });
  await a.query(`select post_document($1)`, [documentId]);
  posted = await read(a);

  // The rate moves after the invoice was issued. The line does not.
  await a.query(`update taxes set amount = $2 where id = $1`, [await taxId(a, companyId, standard.code), standard.rate + 1]);
  expect(await read(a)).toEqual(posted);

  archive = await exportAs(a, company.ownerId, companyId);
  adminOfB = await newInstanceAdmin(b);
  ownerInB = await newUser(b);
}, 300_000);

afterAll(async () => {
  await a?.close();
  await b?.close();
});

describe('a company that arrives with documents already posted', () => {
  it('carries a tax and a line that disagree, which is the point', () => {
    const tables = (JSON.parse(archive) as { tables: Record<string, Record<string, unknown>[]> }).tables;
    const tax = (tables['public.taxes'] ?? []).find((row) => row['code'] === standard.code);
    const line = (tables['public.document_lines'] ?? []).find((row) => row['document_id'] === documentId);
    expect(Number(tax?.['amount'])).toBe(standard.rate + 1);
    expect(Number(line?.['vat_rate'])).toBe(standard.rate);
  });

  it('leaves the guards on after a load that fails', async () => {
    const broken = JSON.parse(archive) as Archive;
    // A line that names an account the archive does not carry, sealed again so
    // that the manifest agrees: what refuses it is the database, in the middle
    // of the load, after the guards were switched off.
    (broken.tables['public.document_lines'] as Record<string, unknown>[])[0]!['account_id'] = '00000000-0000-4000-8000-000000000000';
    for (const table of Object.keys(broken.tables)) await reseal(b, broken, table);
    const message = await asUser(b, adminOfB, () => expectError(b, `select import_company($1::jsonb, $2)`, [JSON.stringify(broken), ownerInB]));
    expect(message).not.toMatch(/archive_corrupt/);
    expect(message).toMatch(/foreign key|foreign_row|violates/);
    expect(await rows(b, `select 1 from companies where id = $1`, [companyId])).toEqual([]);
    expect((await guardsOf(b)).map((guard) => guard.tgenabled)).toEqual(GUARDS.map(() => 'O'));
  });

  it('keeps the line it was posted with, against the tax of the day', async () => {
    await importAs(b, adminOfB, archive, ownerInB);
    expect(await read(b)).toEqual(posted);
    const tax = await one<{ amount: string }>(b, `select amount::text from taxes where company_id = $1 and code = $2`, [companyId, standard.code]);
    expect(Number(tax.amount)).toBe(standard.rate + 1);
    // And the breakdown reads the line, so the invoice is whole.
    const summary = await one<{ tax_rate: string; tax_amount: string }>(
      b,
      `select tax_rate::text, tax_amount::text from document_tax_summary where document_id = $1`,
      [documentId],
    );
    expect(Number(summary.tax_rate)).toBe(standard.rate);
    expect(summary.tax_amount).toBe((posted.totals as { amount_tax: string }).amount_tax);
  });

  it('leaves the guards on after a load that succeeds', async () => {
    const guards = await guardsOf(b);
    expect(guards.map((guard) => guard.tgname)).toEqual([...GUARDS].sort());
    expect(guards.every((guard) => guard.tgenabled === 'O')).toBe(true);
  });

  it('is frozen afterwards, for the owner it was given to and for the administrator who loaded it', async () => {
    await b.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'owner') on conflict do nothing`, [companyId, adminOfB]);
    for (const who of [ownerInB, adminOfB]) {
      for (const statement of [
        `update document_lines set quantity = 9 where document_id = $1`,
        `delete from document_lines where document_id = $1`,
        `update documents set amount_total = 1 where id = $1`,
        `update documents set state = 'draft' where id = $1`,
        `delete from documents where id = $1`,
      ]) {
        const message = await asUser(b, who, () => expectError(b, statement, [documentId]));
        expect(message, statement).toMatch(/^document_posted\b/);
      }
    }
    expect(await read(b)).toEqual(posted);
  });

  it('and so is the entry that arrived with it', async () => {
    const entry = (await one<{ entry_id: string }>(b, `select entry_id from documents where id = $1`, [documentId])).entry_id;
    const before = await rows(b, `select account_id, debit::text, credit::text from entry_lines where entry_id = $1 order by sequence`, [entry]);
    expect(before.length).toBeGreaterThan(0);
    for (const who of [ownerInB, adminOfB]) {
      for (const statement of [
        `update entry_lines set name = 'rewritten' where entry_id = $1`,
        `delete from entry_lines where entry_id = $1`,
        `update entries set state = 'draft' where id = $1`,
        `delete from entries where id = $1`,
      ]) {
        const message = await asUser(b, who, () => expectError(b, statement, [entry]));
        expect(message, statement).toMatch(/^entry_posted\b/);
      }
    }
    expect(await rows(b, `select account_id, debit::text, credit::text from entry_lines where entry_id = $1 order by sequence`, [entry])).toEqual(before);
  });
});
