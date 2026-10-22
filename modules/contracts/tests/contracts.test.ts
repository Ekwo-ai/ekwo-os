import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from '../../../tests/helpers/db.js';
import { newCompany, newContact } from '../../../tests/helpers/factory.js';
import {
  CONTRACT_AMENDMENT_KINDS,
  CONTRACT_DIRECTIONS,
  CONTRACT_FREQUENCIES,
  CONTRACT_KINDS,
  CONTRACT_RENEWALS,
  CONTRACT_STATES,
  CONTRACT_TEMPLATE_FORMATS,
} from '@ekwo-ai/core';

// `contracts` keeps what a company agreed with a party of its books, and turns
// the periods its schedules say are due into draft documents of the socle.
// The taxes, the currency and the accounts are the company's, read where they
// stand: the test names a country only to book somewhere.

let db: PGlite;
let companyId: string;
let ownerId: string;
let customerId: string;
let supplierId: string;
let saleTax: string;
let purchaseTax: string;
let currency: string;

async function taxOf(company: string, scope: 'sale' | 'purchase'): Promise<string> {
  return (
    await one<{ code: string }>(
      db,
      `select code from taxes
        where company_id = $1 and applies_to in ($2::tax_scope, 'both') and amount_type = 'percent' and active
          and valid_from <= date '2026-01-01' and (valid_to is null or valid_to >= date '2026-12-31')
        order by amount desc, sequence, code limit 1`,
      [company, scope],
    )
  ).code;
}

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: 'BE', name: 'Agreements SRL' }));
  customerId = await newContact(db, companyId, { name: 'Northwind Trading', type: 'customer' });
  supplierId = await newContact(db, companyId, { name: 'Contoso Hosting', type: 'supplier' });
  saleTax = await taxOf(companyId, 'sale');
  purchaseTax = await taxOf(companyId, 'purchase');
  currency = (await one<{ currency_code: string }>(db, `select currency_code from companies where id = $1`, [companyId]))
    .currency_code;
  await asUser(db, ownerId, async () => {
    await db.query(`select enable_module($1, 'contracts')`, [companyId]);
  });
});

afterAll(async () => {
  await db.close();
});

describe('a sales contract', () => {
  let contractId: string;
  let scheduleId: string;

  it('is created in the company’s currency, and moves forward only', async () => {
    await asUser(db, ownerId, async () => {
      const created = await one<Record<string, unknown>>(
        db,
        `select * from contracts.upsert_contract($1, 'CTR-0001', $2)`,
        [
          companyId,
          {
            contact_id: customerId,
            name: 'Support and hosting',
            kind: 'subscription',
            direction: 'sale',
            starts_on: '2026-01-31',
            ends_on: '2026-12-30',
            notice_days: 90,
            total_value: '12000.00',
            analysis: { risk_level: 'low' },
          },
        ],
      );
      contractId = created['id'] as string;
      expect(created).toMatchObject({
        state: 'draft',
        currency_code: currency,
        renewal: 'none',
        total_value: '12000.00',
      });

      const signed = await one<Record<string, unknown>>(
        db,
        `select * from contracts.upsert_contract($1, 'CTR-0001', '{"state": "signed", "signed_on": "2026-01-20"}')`,
        [companyId],
      );
      expect(signed['id']).toBe(contractId);
      const back = await expectError(db, `select contracts.upsert_contract($1, 'CTR-0001', '{"state": "draft"}')`, [
        companyId,
      ]);
      expect(back).toMatch(/^contracts_state_backwards:/);
      const unknown = await expectError(db, `select contracts.upsert_contract($1, 'CTR-0001', '{"colour": "blue"}')`, [
        companyId,
      ]);
      expect(unknown).toMatch(/^contracts_unknown_field: a contract has no field colour/);
    });
  });

  it('takes a schedule with its tax by code, and refuses a tax the company does not have', async () => {
    await asUser(db, ownerId, async () => {
      const schedule = await one<Record<string, unknown>>(
        db,
        `select *, next_on::text as next_on from contracts.upsert_schedule($1, $2, null, $3)`,
        [
          companyId,
          contractId,
          {
            name: 'Hosting',
            quantity: '2',
            unit_code: 'C62',
            unit_price: '500',
            tax_code: saleTax,
            frequency: 'monthly',
            next_on: '2026-01-31',
            indexation: { index: 'a consumer price index', formula: 'P = P0 x I / I0', base: '100', next_on: '2027-01-01' },
          },
        ],
      );
      scheduleId = schedule['id'] as string;
      expect(schedule).toMatchObject({ unit_price: '500.000000', auto_post: false, next_on: '2026-01-31' });

      const refused = await expectError(db, `select contracts.upsert_schedule($1, $2, null, $3)`, [
        companyId,
        contractId,
        { name: 'Other', unit_price: '1', frequency: 'monthly', next_on: '2026-01-31', tax_code: 'NO-SUCH-TAX' },
      ]);
      expect(refused).toMatch(/^contracts_unknown_tax:/);
    });
  });

  it('issues once per period, a draft with its contract reference, and moves next_on', async () => {
    await asUser(db, ownerId, async () => {
      const issued = await rows<{ document_id: string; period_start: string; period_end: string; posted: boolean }>(
        db,
        `select document_id, period_start::text, period_end::text, posted from contracts.issue_due($1, date '2026-03-15')`,
        [companyId],
      );
      // From the 31st, the month-end is kept: January, February, March.
      expect(issued.map((i) => [i.period_start, i.period_end])).toEqual([
        ['2026-01-31', '2026-02-27'],
        ['2026-02-28', '2026-03-30'],
      ]);
      expect(issued.every((i) => i.posted === false)).toBe(true);

      const documents = await rows<Record<string, unknown>>(
        db,
        `select d.doc_type::text, d.state::text, d.contract_reference, d.currency_code, d.contact_id, d.document_date::text,
                d.amount_untaxed, l.quantity, l.unit_price, (select code from taxes t where t.id = l.tax_id) as tax_code,
                l.account_id is not null as has_account
           from documents d join document_lines l on l.document_id = d.id
          where d.id = any($1) order by d.document_date`,
        [issued.map((i) => i.document_id)],
      );
      expect(documents).toHaveLength(2);
      for (const document of documents) {
        expect(document).toMatchObject({
          doc_type: 'sale_invoice',
          state: 'draft',
          contract_reference: 'CTR-0001',
          currency_code: currency,
          contact_id: customerId,
          amount_untaxed: '1000.00',
          tax_code: saleTax,
          has_account: true,
        });
      }

      const schedule = await one<{ next_on: string }>(db, `select next_on::text from contracts.schedules where id = $1`, [
        scheduleId,
      ]);
      expect(schedule.next_on).toBe('2026-03-31');

      // The same day again issues nothing, and so does an earlier one.
      expect(await rows(db, `select * from contracts.issue_due($1, date '2026-03-15')`, [companyId])).toEqual([]);
      expect(await rows(db, `select * from contracts.issue_due($1, date '2026-02-01')`, [companyId])).toEqual([]);

      // The next month keeps to the last day of the month.
      const april = await rows<{ period_start: string }>(
        db,
        `select period_start::text from contracts.issue_due($1, date '2026-03-31')`,
        [companyId],
      );
      expect(april.map((a) => a.period_start)).toEqual(['2026-03-31']);
      expect(
        await rows(db, `select 1 from contracts.issues where schedule_id = $1`, [scheduleId]),
      ).toHaveLength(3);
    });
  });

  it('is refused a second document for one period by the socle itself', async () => {
    await asUser(db, ownerId, async () => {
      const refused = await expectError(
        db,
        `insert into documents (company_id, doc_type, contact_id, document_date, currency_code, client_ref)
         values ($1, 'sale_invoice', $2, date '2026-01-31', $3, 'contracts:' || $4 || ':2026-01-31')`,
        [companyId, customerId, currency, scheduleId],
      );
      expect(refused).toMatch(/duplicate key|client_ref/);
    });
  });

  it('shows its notice, its end, its next issue and its indexation in the deadlines', async () => {
    await asUser(db, ownerId, async () => {
      const deadlines = await rows<{ kind: string; due_on: string }>(
        db,
        `select kind, due_on::text from contracts.deadlines where contract_id = $1 order by due_on, kind`,
        [contractId],
      );
      // No renewal: notice is due 90 days before the day after the end.
      expect(deadlines).toEqual([
        { kind: 'next_issue', due_on: '2026-04-30' },
        { kind: 'notice', due_on: '2026-10-02' },
        { kind: 'end', due_on: '2026-12-30' },
        { kind: 'indexation', due_on: '2027-01-01' },
      ]);
    });
  });

  it('is amended, and the amendment applies to its schedule', async () => {
    await asUser(db, ownerId, async () => {
      const amendment = await one<Record<string, unknown>>(
        db,
        `select number, kind::text, effective_on::text from contracts.amend($1, $2, 'New hosting price', date '2026-05-01', $3)`,
        [companyId, contractId, { notes: 'Price raised by agreement', schedules: { [scheduleId]: { unit_price: '550' } } }],
      );
      expect(amendment).toMatchObject({ number: 1, kind: 'amendment', effective_on: '2026-05-01' });
      const schedule = await one<{ unit_price: string }>(db, `select unit_price from contracts.schedules where id = $1`, [
        scheduleId,
      ]);
      expect(schedule.unit_price).toBe('550.000000');
      const refused = await expectError(db, `select contracts.amend($1, $2, 'Renewed', date '2027-01-01', p_kind => 'renewal')`, [
        companyId,
        contractId,
      ]);
      expect(refused).toMatch(/^contracts_bad_amendment:/);
    });
  });

  it('keeps its party once it has issued', async () => {
    await asUser(db, ownerId, async () => {
      const refused = await expectError(db, `select contracts.upsert_contract($1, 'CTR-0001', $2)`, [
        companyId,
        { contact_id: supplierId },
      ]);
      expect(refused).toMatch(/^contracts_already_issued:/);
    });
  });

  it('reads whole in card_of', async () => {
    await asUser(db, ownerId, async () => {
      const card = (await one<{ card: Record<string, unknown> }>(db, `select contracts.card_of($1, $2) as card`, [
        companyId,
        contractId,
      ])).card;
      expect(card['contract']).toMatchObject({ number: 'CTR-0001', state: 'active' });
      expect(card['contact']).toMatchObject({ id: customerId });
      expect((card['schedules'] as unknown[]).length).toBe(1);
      expect((card['amendments'] as unknown[]).length).toBe(1);
      expect((card['issues'] as unknown[]).length).toBe(3);
      const listed = await rows<{ number: string; next_kind: string }>(
        db,
        `select number, next_kind from contracts.list_contracts($1, p_direction => 'sale')`,
        [companyId],
      );
      expect(listed).toEqual([{ number: 'CTR-0001', next_kind: 'next_issue' }]);
    });
  });
});

describe('a purchase contract', () => {
  it('issues purchase invoices to its supplier, and books them when auto_post says so', async () => {
    await asUser(db, ownerId, async () => {
      const contract = await one<{ id: string }>(db, `select id from contracts.upsert_contract($1, 'SUP-0001', $2)`, [
        companyId,
        {
          contact_id: supplierId,
          name: 'Data centre space',
          kind: 'service',
          direction: 'purchase',
          state: 'active',
          starts_on: '2026-01-01',
        },
      ]);
      await db.query(`select contracts.upsert_schedule($1, $2, null, $3)`, [
        companyId,
        contract.id,
        {
          name: 'Rack',
          unit_price: '300',
          tax_code: purchaseTax,
          frequency: 'quarterly',
          next_on: '2026-01-01',
          auto_post: true,
        },
      ]);
      const issued = await rows<{ document_id: string; period_end: string; posted: boolean }>(
        db,
        `select document_id, period_end::text, posted from contracts.issue_due($1, date '2026-04-01')`,
        [companyId],
      );
      expect(issued.map((i) => [i.period_end, i.posted])).toEqual([
        ['2026-03-31', true],
        ['2026-06-30', true],
      ]);
      const documents = await rows<{ doc_type: string; state: string; contract_reference: string; contact_id: string }>(
        db,
        `select doc_type::text, state::text, contract_reference, contact_id from documents where id = any($1)`,
        [issued.map((i) => i.document_id)],
      );
      expect(documents).toEqual([
        { doc_type: 'purchase_invoice', state: 'posted', contract_reference: 'SUP-0001', contact_id: supplierId },
        { doc_type: 'purchase_invoice', state: 'posted', contract_reference: 'SUP-0001', contact_id: supplierId },
      ]);
    });
  });
});

describe('a tacit renewal', () => {
  it('renews for the length of the term that ends, and records it as a renewal', async () => {
    await asUser(db, ownerId, async () => {
      const contract = await one<{ id: string; renews_on: string }>(
        db,
        `select id, renews_on::text from contracts.upsert_contract($1, 'CTR-0002', $2)`,
        [
          companyId,
          {
            contact_id: customerId,
            name: 'Annual licence',
            kind: 'licence',
            direction: 'sale',
            state: 'active',
            starts_on: '2025-01-01',
            ends_on: '2025-12-31',
            renewal: 'tacit',
            notice_days: 30,
          },
        ],
      );
      expect(contract.renews_on).toBe('2026-01-01');
      const notice = await one<{ due_on: string }>(
        db,
        `select due_on::text from contracts.deadlines where contract_id = $1 and kind = 'notice'`,
        [contract.id],
      );
      expect(notice.due_on).toBe('2025-12-02');

      const changes = await rows<{ change: string; ends_on: string }>(
        db,
        `select change, ends_on::text from contracts.roll_forward($1, date '2027-02-01') where contract_id = $2`,
        [companyId, contract.id],
      );
      expect(changes).toEqual([
        { change: 'renewed', ends_on: '2026-12-31' },
        { change: 'renewed', ends_on: '2027-12-31' },
      ]);
      const after = await one<{ state: string; ends_on: string; renews_on: string }>(
        db,
        `select state::text, ends_on::text, renews_on::text from contracts.contracts where id = $1`,
        [contract.id],
      );
      expect(after).toEqual({ state: 'active', ends_on: '2027-12-31', renews_on: '2028-01-01' });
      const history = await rows<{ number: number; kind: string; effective_on: string }>(
        db,
        `select number, kind::text, effective_on::text from contracts.amendments where contract_id = $1 order by number`,
        [contract.id],
      );
      expect(history).toEqual([
        { number: 1, kind: 'renewal', effective_on: '2026-01-01' },
        { number: 2, kind: 'renewal', effective_on: '2027-01-01' },
      ]);
    });
  });

  it('expires a contract that does not renew', async () => {
    await asUser(db, ownerId, async () => {
      await db.query(`select contracts.upsert_contract($1, 'CTR-0003', $2)`, [
        companyId,
        {
          contact_id: customerId,
          name: 'One season',
          kind: 'one_time',
          direction: 'sale',
          state: 'active',
          starts_on: '2026-01-01',
          ends_on: '2026-03-31',
        },
      ]);
      const changes = await rows<{ number: string; change: string }>(
        db,
        `select number, change from contracts.roll_forward($1, date '2026-04-01') where number = 'CTR-0003'`,
        [companyId],
      );
      expect(changes).toEqual([{ number: 'CTR-0003', change: 'expired' }]);
    });
  });
});

describe('a template', () => {
  it('makes a draft contract with its schedule, its variables in place, and refuses a missing one', async () => {
    await asUser(db, ownerId, async () => {
      const template = await one<{ id: string }>(
        db,
        `insert into contracts.templates (company_id, name, category, format, html, variables, schedule)
         values ($1, 'Support agreement', 'services', 'html', '<p>Between {{seller}} and {{buyer}}, from {{start}}.</p>',
                 $2, $3) returning id`,
        [
          companyId,
          JSON.stringify([
            { key: 'seller', label: 'Seller', required: true },
            { key: 'buyer', label: 'Buyer', required: true },
            { key: 'start', label: 'Start', required: false, default_value: 'the first day' },
          ]),
          JSON.stringify([{ name: 'Support', unit_price: '250', frequency: 'monthly', tax_code: saleTax }]),
        ],
      );
      const missing = await expectError(
        db,
        `select contracts.from_template($1, $2, $3, 'CTR-0010', 'sale', 'service', date '2026-06-01', '{"seller": "Us"}')`,
        [companyId, template.id, customerId],
      );
      expect(missing).toMatch(/^contracts_missing_variable: .*buyer/);

      const made = (
        await one<{ made: Record<string, unknown> }>(
          db,
          `select contracts.from_template($1, $2, $3, 'CTR-0010', 'sale', 'service', date '2026-06-01',
                                          '{"seller": "Us", "buyer": "Them"}') as made`,
          [companyId, template.id, customerId],
        )
      ).made;
      expect(made['html']).toBe('<p>Between Us and Them, from the first day.</p>');
      expect(made['contract']).toMatchObject({ number: 'CTR-0010', state: 'draft', template_id: template.id });
      expect(made['schedules']).toMatchObject([{ name: 'Support', next_on: '2026-06-01', frequency: 'monthly' }]);
    });
  });
});

describe('capabilities', () => {
  it('refuse a viewer the writing, and a member without contracts.issue the issuing, by name', async () => {
    const viewer = crypto.randomUUID();
    const keeper = crypto.randomUUID();
    await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [
      companyId,
      viewer,
    ]);
    await db.query(
      `insert into company_members (company_id, user_id, role, capabilities_revoked)
       values ($1, $2, 'accountant', array['contracts.issue'])`,
      [companyId, keeper],
    );
    await asUser(db, viewer, async () => {
      expect(await rows(db, `select * from contracts.list_contracts($1)`, [companyId])).not.toEqual([]);
      const refused = await expectError(db, `select contracts.upsert_contract($1, 'CTR-0099', '{}')`, [companyId]);
      expect(refused).toMatch(/^contracts_not_allowed: writing a contract needs contracts\.write/);
    });
    await asUser(db, keeper, async () => {
      const refused = await expectError(db, `select * from contracts.issue_due($1, date '2026-12-31')`, [companyId]);
      expect(refused).toMatch(/^contracts_not_allowed: .*contracts\.issue/);
      const direct = await expectError(
        db,
        `insert into contracts.issues (company_id, contract_id, schedule_id, document_id, period_start, period_end)
         select company_id, contract_id, schedule_id, document_id, period_start + 1, period_end
           from contracts.issues where company_id = $1 limit 1`,
        [companyId],
      );
      expect(direct).toMatch(/row-level security/);
    });
  });
});

describe('another company', () => {
  let other: { companyId: string; ownerId: string };

  beforeAll(async () => {
    other = await newCompany(db, { country: 'BE', name: 'Voisine SRL' });
    await asUser(db, other.ownerId, async () => {
      await db.query(`select enable_module($1, 'contracts')`, [other.companyId]);
    });
  });

  it('reads nothing of this company, and is told so by name', async () => {
    await asUser(db, other.ownerId, async () => {
      for (const table of ['templates', 'contracts', 'schedules', 'issues', 'amendments', 'deadlines']) {
        expect(await rows(db, `select * from contracts.${table} where company_id = $1`, [companyId])).toEqual([]);
      }
      const refused = await expectError(db, `select * from contracts.issue_due($1, date '2026-12-31')`, [companyId]);
      expect(refused).toMatch(/^contracts_module_not_enabled:/);
    });
  });

  it('cannot have its contact named by a contract of this one', async () => {
    const stranger = await newContact(db, other.companyId, { name: 'Somebody Else' });
    await asUser(db, ownerId, async () => {
      const refused = await expectError(db, `select contracts.upsert_contract($1, 'CTR-0050', $2)`, [
        companyId,
        { contact_id: stranger, name: 'Wrong', kind: 'other', direction: 'sale' },
      ]);
      expect(refused).toMatch(/foreign key/i);
    });
  });
});

describe('the module', () => {
  it('classifies every table it holds for the archive of a company', async () => {
    const classified = await rows<{ table_name: string }>(
      db,
      `select table_name from contracts.archive_tables() order by table_name`,
    );
    const tables = await rows<{ relname: string }>(
      db,
      `select c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
        where n.nspname = 'contracts' and c.relkind = 'r' order by c.relname`,
    );
    expect(classified.map((t) => t.table_name)).toEqual(tables.map((t) => t.relname));
    expect(await rows(db, `select * from company_archive_unclassified() where table_schema = 'contracts'`)).toEqual([]);
  });

  it.each([
    ['contract_kind', CONTRACT_KINDS],
    ['direction', CONTRACT_DIRECTIONS],
    ['contract_state', CONTRACT_STATES],
    ['renewal', CONTRACT_RENEWALS],
    ['frequency', CONTRACT_FREQUENCIES],
    ['amendment_kind', CONTRACT_AMENDMENT_KINDS],
    ['template_format', CONTRACT_TEMPLATE_FORMATS],
  ] as const)('contracts.%s is the list the core exports', async (type, words) => {
    const { values } = await one<{ values: string[] }>(db, `select enum_range(null::contracts.${type})::text[] as values`);
    expect(values).toEqual([...words]);
  });
});
