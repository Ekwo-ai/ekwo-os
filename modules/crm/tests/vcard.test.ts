import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one } from '../../../tests/helpers/db.js';
import { newCompany } from '../../../tests/helpers/factory.js';

// `crm.contact_vcard()` gives one contact as the text of a vCard 3.0, built
// from the socle's contact and the module's card, for an address book. The
// country written is the contact's own code, read back from the row, never
// named here.

let db: PGlite;
let companyId: string;
let ownerId: string;
let orgId: string;
let personId: string;
let bareId: string;
let country: string;

async function vcard(contact: string): Promise<string> {
  return asUser(db, ownerId, async () =>
    (await one<{ v: string }>(db, `select crm.contact_vcard($1, $2) as v`, [companyId, contact])).v,
  );
}

/** The lines of a vCard, folded lines joined again (RFC 2425 §5.8.1). */
function unfold(text: string): string[] {
  return text.replace(/\r\n /g, '').split('\r\n').slice(0, -1);
}

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: 'BE', name: 'Relations SRL' }));
  country = (await one<{ country: string }>(db, `select country from companies where id = $1`, [companyId])).country;

  orgId = (
    await one<{ id: string }>(
      db,
      `insert into contacts (company_id, name, is_company, contact_type, email, phone,
                             address_line1, address_line2, postal_code, city, country, notes)
       values ($1, 'Northwind; Trading, Ltd', true, 'other', 'hello@northwind.example', '+00 100 200',
               '1 Harbour Road', 'Building B', '1000', 'Port Town', $2, 'Met at the fair.' || chr(10) || 'Call back in spring.')
       returning id`,
      [companyId, country],
    )
  ).id;
  personId = (
    await one<{ id: string }>(
      db,
      `insert into contacts (company_id, name, is_company, contact_type, parent_id, email)
       values ($1, 'Ada Lovelace', false, 'other', $2, 'ada@northwind.example') returning id`,
      [companyId, orgId],
    )
  ).id;
  bareId = (
    await one<{ id: string }>(
      db,
      `insert into contacts (company_id, name, is_company, contact_type)
       values ($1, 'Grace Hopper', false, 'other') returning id`,
      [companyId],
    )
  ).id;

  await asUser(db, ownerId, async () => {
    await db.query(`select enable_module($1, 'crm')`, [companyId]);
    await db.query(
      `select crm.upsert_card($1, $2, '{"job_title": "Head of purchasing", "linkedin_url": "https://profiles.example/ada"}')`,
      [companyId, personId],
    );
  });
});

afterAll(async () => {
  await db.close();
});

describe('contact_vcard', () => {
  it('gives an organisation as one, its values escaped and its address whole', async () => {
    const text = await vcard(orgId);
    expect(text.endsWith('\r\n')).toBe(true);
    expect(unfold(text)).toEqual([
      'BEGIN:VCARD',
      'VERSION:3.0',
      'FN:Northwind\\; Trading\\, Ltd',
      'N:;;;;',
      'ORG:Northwind\\; Trading\\, Ltd',
      'X-ABShowAs:COMPANY',
      'EMAIL;TYPE=INTERNET:hello@northwind.example',
      'TEL:+00 100 200',
      `ADR;TYPE=WORK:;;1 Harbour Road\\nBuilding B;Port Town;;1000;${country}`,
      'NOTE:Met at the fair.\\nCall back in spring.',
      `UID:urn:uuid:${orgId}`,
      'END:VCARD',
    ]);
  });

  it('gives a person their organisation, its address, and the title and profile of their card', async () => {
    expect(unfold(await vcard(personId))).toEqual([
      'BEGIN:VCARD',
      'VERSION:3.0',
      'FN:Ada Lovelace',
      'N:Ada Lovelace;;;;',
      'ORG:Northwind\\; Trading\\, Ltd',
      'TITLE:Head of purchasing',
      'EMAIL;TYPE=INTERNET:ada@northwind.example',
      `ADR;TYPE=WORK:;;1 Harbour Road\\nBuilding B;Port Town;;1000;${country}`,
      'URL:https://profiles.example/ada',
      `UID:urn:uuid:${personId}`,
      'END:VCARD',
    ]);
  });

  it('writes only what the books hold, for a contact with neither card nor organisation', async () => {
    expect(unfold(await vcard(bareId))).toEqual([
      'BEGIN:VCARD',
      'VERSION:3.0',
      'FN:Grace Hopper',
      'N:Grace Hopper;;;;',
      `UID:urn:uuid:${bareId}`,
      'END:VCARD',
    ]);
  });

  it('folds a line past 75 octets without cutting a character', async () => {
    const long = 'Ünïcödé '.repeat(20).trim();
    await db.query(`update contacts set notes = $2 where id = $1`, [bareId, long]);
    const text = await vcard(bareId);
    const raw = text.split('\r\n').slice(0, -1);
    for (const line of raw) expect(Buffer.byteLength(line, 'utf8')).toBeLessThanOrEqual(75);
    expect(raw.some((line) => line.startsWith(' '))).toBe(true);
    expect(unfold(text)).toContain(`NOTE:${long}`);
  });

  it('refuses a contact of another company by name', async () => {
    const other = await newCompany(db, { country: 'BE', name: 'Elsewhere SRL', ownerId });
    const stranger = (
      await one<{ id: string }>(
        db,
        `insert into contacts (company_id, name, is_company, contact_type) values ($1, 'Someone Else', false, 'other') returning id`,
        [other.companyId],
      )
    ).id;
    await asUser(db, ownerId, async () => {
      expect(await expectError(db, `select crm.contact_vcard($1, $2)`, [companyId, stranger])).toMatch(/crm_unknown_contact/);
    });
  });

  it('needs the module on the company', async () => {
    const other = await newCompany(db, { country: 'BE', name: 'Without CRM SRL' });
    const someone = (
      await one<{ id: string }>(
        db,
        `insert into contacts (company_id, name, is_company, contact_type) values ($1, 'Nobody', false, 'other') returning id`,
        [other.companyId],
      )
    ).id;
    await asUser(db, other.ownerId, async () => {
      expect(await expectError(db, `select crm.contact_vcard($1, $2)`, [other.companyId, someone])).toMatch(/crm_module_not_enabled/);
    });
  });
});
