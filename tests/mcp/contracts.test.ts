/**
 * The contracts tools, over the protocol and against the real schema.
 *
 * What the module decides — which period is due, what a renewal extends to,
 * who may issue — is `modules/contracts/tests`. What is asked here is that a
 * model reaches it whole: the toolset is offered only where `public.modules`
 * carries the module, each tool calls its function and hands back what the
 * function returned, and a refusal of the schema reaches the model under its
 * own name. The currency and the tax are the company's, read and never named.
 */

import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { buildServer, installedModules, type Backend } from '../../packages/mcp/src/index.js';
import { asUser, freshDatabase, one } from '../helpers/db.js';
import { newCompany, newContact } from '../helpers/factory.js';
import { backendFor, record } from './helpers.js';

let db: PGlite;
let backend: Backend;
let companyId: string;
let ownerId: string;
let currency: string;
let customerId: string;
let taxCode: string;
let templateId: string;
let client: Client;

async function connect(modules: readonly string[]): Promise<Client> {
  const next = new Client({ name: 'test', version: '0' });
  const [a, b] = InMemoryTransport.createLinkedPair();
  await Promise.all([buildServer(backend, { modules }).connect(b), next.connect(a)]);
  return next;
}

async function call(name: string, args: Record<string, unknown>): Promise<Record<string, unknown>> {
  const result = (await client.callTool({ name, arguments: args })) as {
    isError?: boolean;
    content: { text: string }[];
  };
  const text = result.content[0]?.text ?? '';
  if (result.isError === true) throw new Error(text);
  return record(JSON.parse(text));
}

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { name: 'Contrats Outils' }));
  currency = (await one<{ currency_code: string }>(db, `select currency_code from companies where id = $1`, [companyId]))
    .currency_code;
  customerId = await newContact(db, companyId, { name: 'Northwind Trading', type: 'customer' });
  taxCode = (
    await one<{ code: string }>(
      db,
      `select code from taxes where company_id = $1 and applies_to in ('sale', 'both') and amount_type = 'percent'
        order by amount desc, sequence, code limit 1`,
      [companyId],
    )
  ).code;
  await asUser(db, ownerId, async () => {
    await db.query(`select enable_module($1, 'contracts')`, [companyId]);
    templateId = (
      await one<{ id: string }>(
        db,
        `insert into contracts.templates (company_id, name, category, format, html, variables, schedule)
         values ($1, 'Maintenance', 'services', 'html', '<p>For {{buyer}}</p>',
                 '[{"key": "buyer", "label": "Buyer", "required": true}]', $2) returning id`,
        [companyId, JSON.stringify([{ name: 'Maintenance', unit_price: '80', frequency: 'monthly', tax_code: taxCode }])],
      )
    ).id;
  });
  backend = backendFor(db, ownerId);
  client = await connect(['contracts']);
});

afterAll(async () => {
  await client.close();
  await db.close();
});

describe('the contracts toolset', () => {
  it('is offered where public.modules carries contracts, under its prefix, and not otherwise', async () => {
    expect(await installedModules(backend)).toContain('contracts');
    const names = (await client.listTools()).tools.map((tool) => tool.name);
    expect(names.filter((name) => name.startsWith('contracts_')).length).toBe(8);
    const without = await connect(['budgets']);
    const offered = (await without.listTools()).tools.map((tool) => tool.name);
    expect(offered.filter((name) => name.startsWith('contracts_'))).toEqual([]);
    await without.close();
  });

  it('carries a contract from its writing to the drafts it issues', async () => {
    const written = await call('contracts_upsert', {
      company_id: companyId,
      number: 'CTR-1',
      patch: {
        contact_id: customerId,
        name: 'Hosting',
        kind: 'subscription',
        direction: 'sale',
        state: 'active',
        starts_on: '2026-01-01',
        ends_on: '2026-12-31',
        notice_days: 60,
      },
    });
    const contract = written['contract'] as Record<string, unknown>;
    expect(contract).toMatchObject({ number: 'CTR-1', currency_code: currency, state: 'active' });

    const scheduled = await call('contracts_schedule', {
      company_id: companyId,
      contract_id: contract['id'],
      patch: { name: 'Hosting', unit_price: '120', tax_code: taxCode, frequency: 'monthly', next_on: '2026-01-01' },
    });
    expect(scheduled['schedule']).toMatchObject({ name: 'Hosting', frequency: 'monthly' });

    const due = await call('contracts_deadlines', { company_id: companyId, kinds: ['next_issue', 'notice'] });
    expect((due['deadlines'] as { kind: string; due_on: string }[]).map((d) => [d.kind, d.due_on])).toEqual([
      ['next_issue', '2026-01-01'],
      ['notice', '2026-11-02'],
    ]);

    const issued = await call('contracts_issue_due', { company_id: companyId, on_date: '2026-02-15' });
    expect(issued['count']).toBe(2);
    const again = await call('contracts_issue_due', { company_id: companyId, on_date: '2026-02-15' });
    expect(again['count']).toBe(0);

    const card = await call('contracts_card', { company_id: companyId, contract_id: contract['id'] });
    expect((card['issues'] as { state: string }[]).map((i) => i.state)).toEqual(['draft', 'draft']);

    const amended = await call('contracts_amend', {
      company_id: companyId,
      contract_id: contract['id'],
      summary: 'Ends a month later',
      effective_on: '2026-03-01',
      changes: { ends_on: '2027-01-31' },
    });
    expect(amended['amendment']).toMatchObject({ number: 1, kind: 'amendment' });

    const listed = await call('contracts_list', { company_id: companyId, templates: true });
    expect((listed['contracts'] as { number: string }[]).map((c) => c.number)).toEqual(['CTR-1']);
    expect((listed['templates'] as { name: string }[]).map((t) => t.name)).toEqual(['Maintenance']);
  });

  it('makes a draft of a template, with the clauses filled in', async () => {
    const made = await call('contracts_from_template', {
      company_id: companyId,
      template_id: templateId,
      contact_id: customerId,
      number: 'CTR-2',
      direction: 'sale',
      kind: 'service',
      starts_on: '2026-06-01',
      values: { buyer: 'Northwind Trading' },
    });
    expect(made['html']).toBe('<p>For Northwind Trading</p>');
    expect(made['contract']).toMatchObject({ number: 'CTR-2', state: 'draft' });
  });

  it('hands the schema\'s refusals to the model under their own names', async () => {
    await expect(
      call('contracts_upsert', { company_id: companyId, number: 'CTR-1', patch: { colour: 'blue' } }),
    ).rejects.toThrow(/contracts_unknown_field/);
    await expect(
      call('contracts_from_template', {
        company_id: companyId,
        template_id: templateId,
        contact_id: customerId,
        number: 'CTR-3',
        direction: 'sale',
        kind: 'service',
        starts_on: '2026-06-01',
      }),
    ).rejects.toThrow(/contracts_missing_variable/);
  });
});
