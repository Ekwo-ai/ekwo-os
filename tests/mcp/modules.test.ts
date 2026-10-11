/**
 * The module tools, over the protocol and against the real schema.
 *
 * What is checked here is the loader as much as the tools: a module that is
 * not installed is not offered, one that is installed is, and every tool name
 * is the prefix its `module.json` declares. The handlers themselves are thin —
 * the arithmetic is tested in `modules/fixed-assets/tests` — so what they are held to
 * is the shape a model receives.
 */

import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import {
  ENV,
  MODULE_TOOLSETS,
  buildServer,
  einvoiceTransportFrom,
  installedModules,
  type Backend,
  type ServerOptions,
} from '../../packages/mcp/src/index.js';
import { directoryTransport, einvoiceChecksum } from '@ekwo-ai/core';
import { packIssuing, packWithoutBrick, sale, seller } from '../../modules/einvoicing/tests/helpers.js';
import { book, declare, decimal, figures, goldenOf, taxCompany, type GoldenCompany } from '../../modules/corporate-tax/tests/helpers.js';
import { listModules } from '../../packages/cli/src/module/read.js';
import { asUser, freshDatabase, moduleCodes, one, repoRoot, rows } from '../helpers/db.js';
import { newCompany } from '../helpers/factory.js';
import { packWhere } from '../helpers/packs.js';
import { backendFor, record } from './helpers.js';
import { join } from 'node:path';

let db: PGlite;
let backend: Backend;
let companyId: string;
let ownerId: string;

async function connect(modules: readonly string[], as: Backend = backend, options: ServerOptions = {}): Promise<Client> {
  const client = new Client({ name: 'test', version: '0' });
  const [a, b] = InMemoryTransport.createLinkedPair();
  await Promise.all([buildServer(as, { ...options, modules }).connect(b), client.connect(a)]);
  return client;
}

async function call(client: Client, name: string, args: Record<string, unknown>): Promise<unknown> {
  const result = (await client.callTool({ name, arguments: args })) as {
    isError?: boolean;
    content: { text: string }[];
  };
  const text = result.content[0]?.text ?? '';
  if (result.isError === true) throw new Error(text);
  return JSON.parse(text);
}

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: 'BE', name: 'Outils SRL' }));
  await asUser(db, ownerId, async () => {
    await db.query(`select enable_module($1, 'assets')`, [companyId]);
    await db.query(`select enable_module($1, 'budgets')`, [companyId]);
  });
  await db.query(
    `insert into fiscal_years (company_id, name, start_date, end_date)
     values ($1, 'Exercice 2027', date '2027-01-01', date '2027-12-31')`,
    [companyId],
  );
  backend = backendFor(db, ownerId);
});

afterAll(async () => {
  await db.close();
});

describe('the loader', () => {
  it('offers nothing when no module is installed', async () => {
    const client = await connect([]);
    const names = (await client.listTools()).tools.map((tool) => tool.name);
    expect(
      names.filter((name) => /^(fixed_assets|assets|budgets|einvoicing|tax)_/.test(name)),
    ).toEqual([]);
    await client.close();
  });

  it('offers a module\'s tools under the prefix its manifest declares', async () => {
    const manifests = new Map(
      (await listModules(join(repoRoot, 'modules'))).map((module) => [
        module.manifest.code,
        module.manifest,
      ]),
    );
    const client = await connect(['assets', 'budgets', 'einvoicing', 'tax']);
    const names = (await client.listTools()).tools.map((tool) => tool.name);

    for (const toolset of MODULE_TOOLSETS) {
      const manifest = manifests.get(toolset.code);
      expect(manifest?.mcp?.prefix, `${toolset.code}/module.json declares no mcp prefix`).toBe(
        toolset.prefix,
      );
      for (const tool of toolset.tools) {
        expect(names).toContain(`${toolset.prefix}_${tool.verb}`);
      }
    }

    expect(names.filter((name) => name.startsWith('fixed_assets_')).sort()).toEqual([
      'fixed_assets_create',
      'fixed_assets_dispose',
      'fixed_assets_list',
      'fixed_assets_run_depreciation',
      'fixed_assets_schedule',
    ]);
    expect(names.filter((name) => name.startsWith('budgets_')).sort()).toEqual([
      'budgets_list',
      'budgets_upsert_lines',
      'budgets_variance',
    ]);
    expect(names.filter((name) => name.startsWith('einvoicing_')).sort()).toEqual([
      'einvoicing_issue',
      'einvoicing_list',
      'einvoicing_status',
      'einvoicing_validate',
    ]);
    expect(names.filter((name) => name.startsWith('tax_')).sort()).toEqual([
      'tax_adjustments',
      'tax_computations',
      'tax_declare_adjustment',
      'tax_declare_parameter',
      'tax_estimate',
      'tax_losses',
      'tax_parameters',
      'tax_record_computation',
    ]);
    // A module's prompts come with its tools, under the same prefix.
    const prompts = (await client.listPrompts()).prompts.map((prompt) => prompt.name);
    for (const toolset of MODULE_TOOLSETS) {
      for (const prompt of toolset.prompts ?? []) expect(prompts).toContain(`${toolset.prefix}_${prompt.name}`);
    }
    expect(prompts).toContain('tax_review_year');
    // The former `assets_*` names were removed in 0.11.0.
    expect(names.filter((name) => name.startsWith('assets_'))).toEqual([]);
    await client.close();
  });

  it('reads the installed modules off the registry, leaving a draft out', async () => {
    const codes = await moduleCodes();
    expect(await installedModules(backend)).toEqual(codes);
    await db.query(`update modules set status = 'draft' where code = 'budgets'`);
    expect(await installedModules(backend)).toEqual(codes.filter((code) => code !== 'budgets'));
    await db.query(`update modules set status = 'available' where code = 'budgets'`);
  });
});

describe('the fixed assets tools', () => {
  let client: Client;

  beforeAll(async () => {
    client = await connect(['assets', 'budgets']);
  });

  afterAll(async () => {
    await client.close();
  });

  it('create an asset, read its schedule, book it and dispose of it', async () => {
    const created = record(
      await call(client, 'fixed_assets_create', {
        company_id: companyId,
        code: 'IT-01',
        name: 'Portable',
        acquisition_date: '2026-01-01',
        cost: 3600,
        asset_account: '241000',
        depreciation_account: '241900',
        expense_account: '630200',
        category_code: 'it-equipment',
      }),
    );
    expect(created['asset_id']).toBeTruthy();

    const schedule = record(
      await call(client, 'fixed_assets_schedule', {
        company_id: companyId,
        asset_id: created['asset_id'],
      }),
    );
    const lines = schedule['lines'] as { amount: string }[];
    expect(lines.map((line) => line.amount)).toEqual(['1200.00', '1200.00', '1200.00']);

    const run = record(
      await call(client, 'fixed_assets_run_depreciation', {
        company_id: companyId,
        period_end: '2026-12-31',
      }),
    );
    expect((run['entries'] as { amount: string }[]).map((e) => e.amount)).toEqual(['1200.00']);

    const register = record(await call(client, 'fixed_assets_list', { company_id: companyId, at: '2026-12-31' }));
    expect(register['fixed_assets']).toEqual([
      {
        code: 'IT-01',
        name: 'Portable',
        category_code: 'it-equipment',
        acquisition_date: '2026-01-01',
        cost: '3600.00',
        accumulated: '1200.00',
        net_book_value: '2400.00',
        state: 'active',
      },
    ]);

    const disposal = record(
      await call(client, 'fixed_assets_dispose', {
        company_id: companyId,
        asset_id: created['asset_id'],
        disposal_date: '2027-01-10',
        proceeds: 2000,
        counterpart_account: '400000',
      }),
    );
    expect(disposal['entry_id']).toBeTruthy();

    const ledger = await rows<{ code: string; debit: string; credit: string }>(
      db,
      `select a.code, l.debit, l.credit from entry_lines l
         join accounts a on a.id = l.account_id where l.entry_id = $1 order by l.sequence`,
      [disposal['entry_id'] as string],
    );
    // 1 200 written off, 2 400 left, sold for 2 000: a loss of 400 on 663.
    expect(ledger).toEqual([
      { code: '241900', debit: '1200.00', credit: '0.00' },
      { code: '241000', debit: '0.00', credit: '3600.00' },
      { code: '400000', debit: '2000.00', credit: '0.00' },
      { code: '663000', debit: '400.00', credit: '0.00' },
    ]);
  });

  it('report the socle refusal rather than paraphrasing it', async () => {
    await db.query(`update companies set lock_date = date '2027-12-31' where id = $1`, [companyId]);
    await db.query(
      `select fixed_assets.create_fixed_asset($1, 'IT-02', 'Ecran', date '2027-01-01', 600,
              '241000', '241900', '630200', 'it-equipment')`,
      [companyId],
    );
    await expect(
      call(client, 'fixed_assets_run_depreciation', { company_id: companyId, period_end: '2027-12-31' }),
    ).rejects.toThrow(/period_locked/);
    await db.query(`update companies set lock_date = null where id = $1`, [companyId]);
  });
});

describe('the budgets tools', () => {
  let client: Client;
  let budgetId: string;

  beforeAll(async () => {
    client = await connect(['assets', 'budgets']);
    const budget = await one<{ id: string }>(
      db,
      `insert into budgets.budgets (company_id, code, name) values ($1, 'B2026', 'Budget 2026')
       returning id`,
      [companyId],
    );
    budgetId = budget.id;
  });

  afterAll(async () => {
    await client.close();
  });

  it('list the budgets, write lines and read the variance', async () => {
    const listed = record(await call(client, 'budgets_list', { company_id: companyId }));
    expect((listed['budgets'] as { code: string }[]).map((b) => b.code)).toEqual(['B2026']);

    const written = record(
      await call(client, 'budgets_upsert_lines', {
        company_id: companyId,
        budget_id: budgetId,
        lines: [
          {
            account_code: '630200',
            period_start: '2026-01-01',
            period_end: '2026-12-31',
            amount: 1500,
          },
        ],
      }),
    );
    expect(written).toEqual({ written: 1 });

    // Writing the same account and period again replaces the figure rather
    // than adding a second one: a revision of one line is not two lines.
    await call(client, 'budgets_upsert_lines', {
      company_id: companyId,
      budget_id: budgetId,
      lines: [
        {
          account_code: '630200',
          period_start: '2026-01-01',
          period_end: '2026-12-31',
          amount: 1000,
        },
      ],
    });

    const variance = record(
      await call(client, 'budgets_variance', {
        company_id: companyId,
        budget_id: budgetId,
        from: '2026-01-01',
        to: '2026-12-31',
      }),
    );
    // The depreciation booked above is 1 200 against a plan of 1 000.
    expect(variance['lines']).toEqual([
      { account_code: '630200', account_name: 'Dotations aux amortissements sur immobilisations corporelles', budget: '1000.00', actual: '1200.00', variance: '200.00' },
    ]);
  });

  it('refuse an account the company does not have, by name', async () => {
    await expect(
      call(client, 'budgets_upsert_lines', {
        company_id: companyId,
        budget_id: budgetId,
        lines: [
          { account_code: '999999', period_start: '2026-01-01', period_end: '2026-12-31', amount: 1 },
        ],
      }),
    ).rejects.toThrow(/unknown_account: 999999/);
  });
});

describe('the electronic invoicing tools', () => {
  let folder: string;

  beforeAll(async () => {
    folder = await mkdtemp(join(tmpdir(), 'ekwo-mcp-einvoicing-'));
  });

  afterAll(async () => {
    await rm(folder, { recursive: true, force: true });
  });

  it('check, issue, send through the folder the server was given, and follow it', async () => {
    const s = await seller(db, packIssuing('peppol-bis-3'), 'Seller over MCP');
    const documentId = await sale(db, s);
    const client = await connect(['einvoicing'], s.backend, { einvoiceTransport: directoryTransport(folder) });

    const checked = (await call(client, 'einvoicing_validate', { document_id: documentId, include_file: true })) as Record<string, unknown>;
    expect(checked).toMatchObject({ profile: 'peppol-bis-3', violations: [], sendable: true });
    expect(checked['checksum']).toBe(einvoiceChecksum(checked['file'] as string));

    const issued = (await call(client, 'einvoicing_issue', { document_id: documentId, send: true })) as {
      issue: { checksum: string };
      transmission: { id: string; state: string; reference: string; channel: string };
    };
    expect(issued.issue.checksum).toBe(checked['checksum']);
    expect(issued.transmission).toMatchObject({ state: 'submitted', channel: 'self' });
    expect(await readFile(join(folder, issued.transmission.reference), 'utf8')).toBe(checked['file']);

    const status = (await call(client, 'einvoicing_status', { document_id: documentId, refresh: true })) as Record<string, unknown>;
    expect(status['state']).toBe('submitted');
    const listed = (await call(client, 'einvoicing_list', { company_id: s.companyId })) as { count: number; transmissions: { id: string }[] };
    expect(listed.transmissions.map((t) => t.id)).toEqual([issued.transmission.id]);
    await client.close();
  });

  it('refuse to send with no transport, and a profile without a brick, by name', async () => {
    const s = await seller(db, packIssuing('peppol-bis-3'), 'Seller without a folder');
    const client = await connect(['einvoicing'], s.backend);
    await expect(call(client, 'einvoicing_issue', { document_id: await sale(db, s), send: true })).rejects.toThrow(/no_transport/);
    await client.close();

    const unwritten = await seller(db, packWithoutBrick(), 'Seller without a brick');
    const other = await connect(['einvoicing'], unwritten.backend);
    await expect(call(other, 'einvoicing_validate', { document_id: await sale(db, unwritten) })).rejects.toThrow(/format_without_brick/);
    await other.close();
  });

  it('take their folder from the environment, and none when it is unset', () => {
    expect(einvoiceTransportFrom({})).toBeUndefined();
    expect(einvoiceTransportFrom({ [ENV.einvoiceDirectory]: '  ' })).toBeUndefined();
    expect(einvoiceTransportFrom({ [ENV.einvoiceDirectory]: folder })).toMatchObject({ channel: 'self', service: null });
  });
});

describe('the corporate income tax tools', () => {
  // A worked example that declares parameters, an account and an amount, so
  // every way in is used; the figure it must reach is the pack's own.
  const declaresEverything = (company: GoldenCompany): boolean =>
    Object.keys(company.parameters ?? {}).length > 0 &&
    (company.adjustments ?? []).some((a) => a.account !== undefined) &&
    (company.adjustments ?? []).some((a) => a.amount !== undefined);
  const pack = packWhere('a worked example of corporate tax declaring parameters, an account and an amount', (p) =>
    p.corporateTax !== null && goldenOf(p).companies.some(declaresEverything),
  );
  const golden = goldenOf(pack);
  const company = golden.companies.find(declaresEverything) as GoldenCompany;

  it('declare what the worked example declares, and reach its figure to the cent', async () => {
    const fixture = await taxCompany(db, pack.manifest.country, company.name, golden.fiscal_year);
    for (const entry of company.entries) await book(db, fixture.companyId, entry);
    await declare(db, fixture, { losses: company.losses ?? [] });
    const client = await connect(['tax'], backendFor(db, fixture.ownerId));
    const year = { company_id: fixture.companyId, fiscal_year_id: fixture.fiscalYearId };

    const asked = record(await call(client, 'tax_parameters', year))['parameters'] as { code: string; declared: boolean }[];
    expect(asked.length).toBe(pack.corporateTax?.parameters.length);
    expect(asked.every((p) => !p.declared)).toBe(true);

    for (const [code, value] of Object.entries(company.parameters ?? {})) {
      await call(client, 'tax_declare_parameter', { ...year, code, value });
    }
    // A second answer replaces the first rather than standing beside it.
    const [firstCode, firstValue] = Object.entries(company.parameters ?? {})[0] as [string, boolean | string];
    await call(client, 'tax_declare_parameter', { ...year, code: firstCode, value: firstValue, note: 'Said again.' });
    const answered = record(await call(client, 'tax_parameters', year))['parameters'] as {
      code: string;
      declared: boolean;
      value: boolean | string | null;
      note: string | null;
    }[];
    for (const [code, value] of Object.entries(company.parameters ?? {})) {
      const answer = answered.find((p) => p.code === code);
      expect(answer?.declared, code).toBe(true);
      expect(typeof value === 'boolean' ? answer?.value : decimal(answer?.value as string), code).toBe(
        typeof value === 'boolean' ? value : decimal(value),
      );
    }
    expect(answered.find((p) => p.code === firstCode)?.note).toBe('Said again.');

    for (const adjustment of company.adjustments ?? []) {
      await call(client, 'tax_declare_adjustment', {
        ...year,
        rule_code: adjustment.rule,
        ...(adjustment.account === undefined ? {} : { account_code: adjustment.account }),
        ...(adjustment.amount === undefined ? {} : { amount: adjustment.amount }),
        ...(adjustment.parameters === undefined ? {} : { parameters: adjustment.parameters }),
      });
    }
    const adjustments = record(await call(client, 'tax_adjustments', year)) as {
      rules: { code: string; legal_reference: string; declared: { account_code: string | null; amount: string | null }[] }[];
      not_in_force: unknown[];
    };
    for (const adjustment of company.adjustments ?? []) {
      const rule = adjustments.rules.find((r) => r.code === adjustment.rule);
      expect(rule?.legal_reference, adjustment.rule).toBeTruthy();
      expect(
        rule?.declared.some((d) =>
          adjustment.account === undefined
            ? decimal(d.amount) === decimal(adjustment.amount)
            : d.account_code === adjustment.account,
        ),
        adjustment.rule,
      ).toBe(true);
    }
    expect(adjustments.not_in_force).toEqual([]);

    const estimate = record(await call(client, 'tax_estimate', year)) as {
      estimated_tax: string;
      lines: { kind: string; code: string | null; base: string | null; rate: string | null; amount: string | null }[];
    };
    const worked = `\n${company.why}\n${company.expected.computation.join('\n')}\n`;
    expect(estimate.lines.map(figures), worked).toEqual(company.expected.lines.map(figures));
    expect(decimal(estimate.estimated_tax), worked).toBe(decimal(company.expected.tax));

    const kept = record(await call(client, 'tax_record_computation', year));
    const computations = record(await call(client, 'tax_computations', year))['computations'] as {
      id: string;
      version: number;
      status: string;
      tax: string;
    }[];
    expect(computations.map((c) => ({ id: c.id, version: c.version, status: c.status, tax: decimal(c.tax) }))).toEqual([
      { id: kept['computation_id'], version: 1, status: 'estimate', tax: decimal(company.expected.tax) },
    ]);

    const before = record(await call(client, 'tax_losses', { company_id: fixture.companyId }))['losses'] as unknown[];
    expect(before.length).toBe((company.losses ?? []).length);
  }, 120_000);

  it('refuse, by name, an adjustment with both an account and an amount, and a parameter the country does not ask', async () => {
    const fixture = await taxCompany(db, pack.manifest.country, `${company.name} bis`, golden.fiscal_year);
    const client = await connect(['tax'], backendFor(db, fixture.ownerId));
    const year = { company_id: fixture.companyId, fiscal_year_id: fixture.fiscalYearId };
    const withAccount = (company.adjustments ?? []).find((a) => a.account !== undefined);
    await expect(
      call(client, 'tax_declare_adjustment', {
        ...year,
        rule_code: withAccount?.rule,
        account_code: withAccount?.account,
        amount: '10.00',
      }),
    ).rejects.toThrow(/account_or_amount/);
    await expect(
      call(client, 'tax_declare_parameter', { ...year, code: 'no_such_parameter', value: true }),
    ).rejects.toThrow(/unknown_tax_parameter/);
  }, 120_000);

  it('offer a checklist that names its tools and the company', async () => {
    const client = await connect(['tax']);
    const prompt = await client.getPrompt({
      name: 'tax_review_year',
      arguments: { company_id: companyId, fiscal_year_id: companyId },
    });
    const text = (prompt.messages[0]?.content as { text: string }).text;
    expect(text).toContain(companyId);
    for (const tool of ['tax_parameters', 'tax_adjustments', 'tax_estimate', 'tax_losses', 'tax_computations']) {
      expect(text).toContain(tool);
    }
    await client.close();
  });
});
