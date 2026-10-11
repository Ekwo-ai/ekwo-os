/**
 * The tools of the modules, and the loader that puts them on the server.
 *
 * A module is a schema of its own, so its tools are named after it —
 * `fixed_assets_list`, `budgets_variance` — and a model reading a tool list
 * can tell which module answers for what. The prefix is in `module.json`, and
 * a test holds the tool names to it.
 *
 * **Nothing here decides what is installed.** `public.modules` does, and the
 * server asks it at startup: a module whose migrations have never run has no
 * row, so its tools are not offered, and a tool a model cannot use is worse
 * than a tool it cannot see. What the registry below carries is the other
 * half — the handlers this release knows how to write — and a module installed
 * in the database that this release has no handlers for is simply not exposed.
 *
 * **PostgREST has to be told.** A schema other than `public` is served only
 * once the project lists it under its exposed schemas, which no migration can
 * set. The refusal that comes back is a 406 about a profile, which says
 * nothing useful to a model, so every module tool turns it into the sentence
 * that names the setting.
 */

import { z } from 'zod';
import { EkwoMcpError, type Backend, type Filter, type Row } from '../backend.js';
import {
  TRANSMISSION_STATES,
  amountIn,
  decimal,
  einvoiceStatus,
  issueEinvoice,
  listEinvoiceTransmissions,
  money,
  moneyFields,
  validateEinvoice,
  type EinvoiceTransport,
} from '@ekwo-ai/core';
import { companyId, isoDate, uuid } from './read.js';

/** One module's tools, as the loader sees them. */
export interface ModuleToolset {
  /** The module code, and the key of `public.modules`. */
  code: string;
  /** Every tool of this module is `<prefix>_<verb>`. */
  prefix: string;
  /** The schema its objects live in, for the message when it is not exposed. */
  schema: string;
  tools: ModuleTool[];
  /** Its prompts, named `<prefix>_<name>` like its tools, offered with them. */
  prompts?: ModulePrompt[];
}

/** A checklist a module offers, filled in with the arguments the client passes. */
export interface ModulePrompt {
  name: string;
  title: string;
  description: string;
  /** Every argument is a string, described for the client. */
  args: Record<string, string>;
  text(args: Record<string, string>): string;
}

export interface ModuleTool {
  /** Without the prefix: `list`, `create`, `variance`. */
  verb: string;
  title: string;
  description: string;
  input: z.ZodObject<z.ZodRawShape>;
  readOnly: boolean;
  run(backend: Backend, args: Record<string, never>, context: ModuleToolContext): Promise<unknown>;
}

/**
 * What the host hands a module tool beside the backend: things that are not
 * in the database and never will be. Today one — the transport an electronic
 * invoice leaves through, built by whoever runs the server with what it
 * needs, so no credential ever reaches a tool or a model.
 */
export interface ModuleToolContext {
  einvoiceTransport?: EinvoiceTransport;
}

/**
 * A schema the project has not exposed answers with a profile error, which
 * reads like a bug in this server. It is a setting, so say which one.
 */
export async function inSchema<T>(schema: string, run: () => Promise<T>): Promise<T> {
  try {
    return await run();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    if (/profile|schema must be one of|PGRST106|acceptable/i.test(message)) {
      throw new EkwoMcpError(
        `schema_not_exposed: the \`${schema}\` schema is not served by this project's API. ` +
          `Add it in Supabase → Project Settings → API → Exposed schemas, or to \`[api] schemas\` ` +
          `in supabase/config.toml, and try again. ${message}`,
      );
    }
    throw error;
  }
}

// ---------------------------------------------------------------------------
// fixed assets — module code `assets`, schema `fixed_assets`
// ---------------------------------------------------------------------------

const FIXED_ASSETS: ModuleToolset = {
  code: 'assets',
  prefix: 'fixed_assets',
  schema: 'fixed_assets',
  tools: [
    {
      verb: 'list',
      title: 'Fixed assets',
      readOnly: true,
      description:
        'The register of fixed assets of a company at a date: what each one cost, what has been written off it and what is left. It reads what has been *booked*, so it ties back to the accumulated depreciation account on the balance sheet. An asset disposed of before that date is not in it.',
      input: z.object({
        company_id: companyId,
        at: isoDate.describe('The date to read the register at.'),
      }),
      async run(backend, args) {
        const at = args['at'] as unknown as string;
        const rows = await inSchema('fixed_assets', () =>
          backend.rpc<Row>('register', { p_company_id: args['company_id'], p_at: at }, 'fixed_assets'),
        );
        return {
          at,
          fixed_assets: rows.map((row) => ({
            ...row,
            cost: money(row['cost']),
            accumulated: money(row['accumulated']),
            net_book_value: money(row['net_book_value']),
          })),
        };
      },
    },
    {
      verb: 'create',
      title: 'Record a fixed asset',
      readOnly: false,
      description:
        'Creates a fixed asset and writes its depreciation schedule in one call. Give a `category_code` of the country pack — the categories are those of its `fixed_assets.json` — and the method, the duration and the coefficient come from it; anything you pass yourself wins over the category. The three accounts are the asset account, the accumulated depreciation account and the depreciation charge. Nothing is booked here: fixed_assets_run_depreciation is what posts.',
      input: z.object({
        company_id: companyId,
        code: z.string().min(1).describe('Your own reference for the asset. Unique in the company.'),
        name: z.string().min(1),
        acquisition_date: isoDate,
        cost: z.number().positive().describe('What it cost, excluding recoverable tax.'),
        asset_account: z.string().describe('Account code the asset itself sits on.'),
        depreciation_account: z.string().describe('Account code of the accumulated depreciation.'),
        expense_account: z.string().describe('Account code the depreciation charge lands on.'),
        category_code: z.string().optional().describe('A category of the country pack.'),
        duration_months: z.number().int().positive().optional(),
        method: z.enum(['straight_line', 'declining_balance']).optional(),
        coefficient: z.number().positive().optional().describe('Required by a declining balance.'),
        residual_value: z.number().min(0).optional(),
        in_service_date: isoDate.optional().describe('When it started being used, if not the day it was bought.'),
        description: z.string().optional(),
      }),
      async run(backend, args) {
        // A function returning a scalar comes back as the scalar, on either
        // backend: `opening_balance` is read the same way.
        const created = await inSchema('fixed_assets', () =>
          backend.rpc<string>(
            'create_fixed_asset',
            {
              p_company_id: args['company_id'],
              p_code: args['code'],
              p_name: args['name'],
              p_acquisition_date: args['acquisition_date'],
              p_cost: args['cost'],
              p_asset_account: args['asset_account'],
              p_depreciation_account: args['depreciation_account'],
              p_expense_account: args['expense_account'],
              p_category_code: args['category_code'] ?? null,
              p_duration_months: args['duration_months'] ?? null,
              p_method: args['method'] ?? null,
              p_coefficient: args['coefficient'] ?? null,
              p_residual_value: args['residual_value'] ?? 0,
              p_in_service_date: args['in_service_date'] ?? null,
              p_description: args['description'] ?? null,
            },
            'fixed_assets',
          ),
        );
        return { asset_id: created[0] ?? null };
      },
    },
    {
      verb: 'schedule',
      title: 'Depreciation schedule',
      readOnly: true,
      description:
        'The planned depreciation of one asset, period by period, with the amount, the accumulated total and the net book value after each one, and the entry that booked it where it has been booked. The schedule always sums to exactly the cost less the residual value: the last line takes the remainder.',
      input: z.object({ company_id: companyId, asset_id: uuid }),
      async run(backend, args) {
        const lines = await inSchema('fixed_assets', () =>
          backend.select<Row>({
            schema: 'fixed_assets',
            table: 'depreciation_lines',
            columns: [
              'sequence',
              'period_start',
              'period_end',
              'amount::text',
              'accumulated::text',
              'net_book_value::text',
              'entry_id',
              'posted_at',
            ],
            where: [
              { column: 'company_id', op: 'eq', value: args['company_id'] as unknown as string },
              { column: 'asset_id', op: 'eq', value: args['asset_id'] as unknown as string },
            ],
            order: [{ column: 'sequence' }],
          }),
        );
        return { lines };
      },
    },
    {
      verb: 'run_depreciation',
      title: 'Book the depreciation',
      readOnly: false,
      description:
        'Books every planned period that ends on or before a date, one ledger entry per period, through the socle\'s own posting function. It is idempotent: a period already booked is skipped, and the database refuses a second entry for it anyway. A closed financial year or a locked period refuses the posting — report the refusal, do not move the date.',
      input: z.object({
        company_id: companyId,
        period_end: isoDate.describe('Book everything up to and including this date.'),
      }),
      async run(backend, args) {
        const result = await inSchema('fixed_assets', () =>
          backend.rpc<{ entries: unknown[] }>(
            'run_depreciation',
            { p_company_id: args['company_id'], p_period_end: args['period_end'] },
            'fixed_assets',
          ),
        );
        return result[0] ?? { entries: [] };
      },
    },
    {
      verb: 'dispose',
      title: 'Dispose of a fixed asset',
      readOnly: false,
      description:
        'Takes an asset off the books on a date: clears its cost and its accumulated depreciation, books the proceeds against the account you name, and presents the result the way the country pack says — one gain or loss line, or the value sold and the proceeds in full. Run fixed_assets_run_depreciation first: a disposal is refused while a period that has already ended is still unbooked. There is no undo.',
      input: z.object({
        company_id: companyId,
        asset_id: uuid,
        disposal_date: isoDate,
        proceeds: z.number().min(0).default(0).describe('What it was sold for, excluding tax. Zero when it was scrapped.'),
        counterpart_account: z
          .string()
          .optional()
          .describe('Account code the proceeds are owed on. The receivable account of the company by default.'),
        contact_id: uuid.optional().describe('Who bought it.'),
      }),
      async run(backend, args) {
        const result = await inSchema('fixed_assets', () =>
          backend.rpc<string>(
            'dispose_fixed_asset',
            {
              p_asset_id: args['asset_id'],
              p_date: args['disposal_date'],
              p_proceeds: args['proceeds'] ?? 0,
              p_counterpart_account: args['counterpart_account'] ?? null,
              p_contact_id: args['contact_id'] ?? null,
            },
            'fixed_assets',
          ),
        );
        return { entry_id: result[0] ?? null };
      },
    },
  ],
};

// ---------------------------------------------------------------------------
// budgets
// ---------------------------------------------------------------------------

const BUDGETS: ModuleToolset = {
  code: 'budgets',
  prefix: 'budgets',
  schema: 'budgets',
  tools: [
    {
      verb: 'list',
      title: 'Budgets',
      readOnly: true,
      description:
        'The budgets of a company, with the financial year each one is for and whether it is a draft, approved or closed. Start here: budgets_variance needs a budget_id.',
      input: z.object({ company_id: companyId }),
      async run(backend, args) {
        const budgets = await inSchema('budgets', () =>
          backend.select<Row>({
            schema: 'budgets',
            table: 'budgets',
            columns: ['id', 'code', 'name', 'state', 'fiscal_year_id', 'notes'],
            where: [{ column: 'company_id', op: 'eq', value: args['company_id'] as unknown as string }],
            order: [{ column: 'code' }],
          }),
        );
        return { budgets };
      },
    },
    {
      verb: 'upsert_lines',
      title: 'Write budget lines',
      readOnly: false,
      description:
        'Adds lines to a budget: one figure per account and per period. State the amount the way a business says it out loud — an income and a cost are both positive — and the comparison flips the ledger, not you. A line already there for the same account and period is replaced.',
      input: z.object({
        company_id: companyId,
        budget_id: uuid,
        lines: z
          .array(
            z.object({
              account_code: z.string(),
              period_start: isoDate,
              period_end: isoDate,
              amount: z.number(),
              note: z.string().optional(),
            }),
          )
          .min(1),
      }),
      async run(backend, args) {
        const companyIdValue = args['company_id'] as unknown as string;
        const budgetIdValue = args['budget_id'] as unknown as string;
        const lines = args['lines'] as unknown as {
          account_code: string;
          period_start: string;
          period_end: string;
          amount: number;
          note?: string;
        }[];

        const codes = [...new Set(lines.map((line) => line.account_code))];
        const accounts = await backend.select<{ id: string; code: string }>({
          table: 'accounts',
          columns: ['id', 'code'],
          where: [
            { column: 'company_id', op: 'eq', value: companyIdValue },
            { column: 'code', op: 'in', value: codes },
          ],
        });
        const byCode = new Map(accounts.map((account) => [account.code, account.id]));
        const missing = codes.filter((code) => !byCode.has(code));
        if (missing.length > 0) {
          throw new EkwoMcpError(
            `unknown_account: ${missing.join(', ')} — not an account of this company. Use list_accounts to find the right code.`,
          );
        }

        return inSchema('budgets', async () => {
          for (const line of lines) {
            await backend.remove(
              'lines',
              [
                { column: 'budget_id', op: 'eq', value: budgetIdValue },
                { column: 'account_id', op: 'eq', value: byCode.get(line.account_code) as string },
                { column: 'period_start', op: 'eq', value: line.period_start },
                { column: 'period_end', op: 'eq', value: line.period_end },
              ],
              'budgets',
            );
          }
          const written = await backend.insert<Row>(
            'lines',
            lines.map((line) => ({
              budget_id: budgetIdValue,
              company_id: companyIdValue,
              account_id: byCode.get(line.account_code) as string,
              period_start: line.period_start,
              period_end: line.period_end,
              amount: line.amount,
              note: line.note ?? null,
            })),
            ['id'],
            'budgets',
          );
          return { written: written.length };
        });
      },
    },
    {
      verb: 'variance',
      title: 'Budget against ledger',
      readOnly: true,
      description:
        'What was planned against what was booked, per account, over a period. Both figures are in the sign a business states them in, and the variance is the actual less the plan — so a negative figure on an income account is revenue that did not arrive, and a positive one on a cost account is overspending. It reads posted entries of kind `normal`: a closing or appropriation entry is not what a period earned. A budget line is taken whole or not at all, so ask for a window that contains the periods the budget was written in.',
      input: z.object({
        company_id: companyId,
        budget_id: uuid,
        from: isoDate,
        to: isoDate,
      }),
      async run(backend, args) {
        const rows = await inSchema('budgets', () =>
          backend.rpc<Row>(
            'variance',
            {
              p_company_id: args['company_id'],
              p_budget_id: args['budget_id'],
              p_from: args['from'],
              p_to: args['to'],
            },
            'budgets',
          ),
        );
        return {
          from: args['from'],
          to: args['to'],
          lines: rows.map((row) => ({
            ...row,
            budget: money(row['budget']),
            actual: money(row['actual']),
            variance: money(row['variance']),
          })),
        };
      },
    },
  ],
};

// ---------------------------------------------------------------------------
// electronic invoicing — module code `einvoicing`, schema `einvoicing`
//
// The four functions of the core the command line calls too. Which format a
// document is written in is the profile of its company's country pack; which
// transport a file leaves through is the server's, set by whoever runs it
// (EKWO_EINVOICE_DIRECTORY for the folder that ships) and never by a model.
// ---------------------------------------------------------------------------

const documentId = uuid.describe('The posted sale invoice or credit note. list_documents finds it.');

const EINVOICING: ModuleToolset = {
  code: 'einvoicing',
  prefix: 'einvoicing',
  schema: 'einvoicing',
  tools: [
    {
      verb: 'validate',
      title: 'Check an electronic invoice',
      readOnly: true,
      description:
        'Writes the electronic invoice of a posted sale invoice or credit note, in the profile its company\'s country pack declares, and lists every rule of the format it breaks — as the format names them, word for word. Records nothing and sends nothing. A broken rule is fixed in the books (the customer\'s electronic address, a due date, a reference), never in the file. A profile no brick writes is refused as format_without_brick.',
      input: z.object({
        document_id: documentId,
        include_file: z.boolean().optional().describe('Hand the file back too. Left out, the answer is what is wrong with it.'),
      }),
      async run(backend, args) {
        return inSchema('einvoicing', () =>
          validateEinvoice(backend, {
            document_id: args['document_id'] as unknown as string,
            ...(args['include_file'] === undefined ? {} : { include_file: args['include_file'] as unknown as boolean }),
          }),
        );
      },
    },
    {
      verb: 'issue',
      title: 'Issue an electronic invoice',
      readOnly: false,
      description:
        'Writes the electronic invoice of a posted sale and keeps it — the exact file, its checksum and the rules it breaks; the same file twice is one issue. With send, also hands it to the transport this server is configured with and records what came back. A file that breaks a rule is kept and never sent (einvoice_not_sendable, with the rules); a document already on its way is refused (einvoice_already_sent). Submitted is not delivered: follow it with einvoicing_status. Ask the user before sending: a file that leaves is in a customer\'s hands.',
      input: z.object({
        document_id: documentId,
        send: z.boolean().optional().describe('Send it as well, through the configured transport. Left out, nothing leaves.'),
        include_file: z.boolean().optional().describe('Hand the file back too.'),
      }),
      async run(backend, args, context) {
        return inSchema('einvoicing', () =>
          issueEinvoice(
            backend,
            {
              document_id: args['document_id'] as unknown as string,
              ...(args['send'] === undefined ? {} : { send: args['send'] as unknown as boolean }),
              ...(args['include_file'] === undefined ? {} : { include_file: args['include_file'] as unknown as boolean }),
            },
            context.einvoiceTransport,
          ),
        );
      },
    },
    {
      verb: 'status',
      title: 'Where an electronic invoice stands',
      readOnly: false,
      description:
        'Everything known of the electronic invoice of one document: each file issued, each sending and every answer the service gave, verbatim. state is not_issued, issued, or the state of the latest sending: prepared, submitted, accepted_by_access_point, delivered, rejected or failed. With refresh, asks the configured transport again about the sending still open and records its answer. A rejected or failed document is sent again with einvoicing_issue.',
      input: z.object({
        document_id: documentId,
        refresh: z.boolean().optional().describe('Ask the transport again about the open sending, and record what it says.'),
      }),
      async run(backend, args, context) {
        return inSchema('einvoicing', () =>
          einvoiceStatus(
            backend,
            {
              document_id: args['document_id'] as unknown as string,
              ...(args['refresh'] === undefined ? {} : { refresh: args['refresh'] as unknown as boolean }),
            },
            context.einvoiceTransport,
          ),
        );
      },
    },
    {
      verb: 'list',
      title: 'Electronic invoices sent',
      readOnly: true,
      description:
        'Every sending of electronic invoices of a company, or of one document, latest first: the document, the file, the channel and the service, the reference it gave, the state and the last words the service said.',
      input: z.object({
        company_id: companyId,
        document_id: uuid.optional().describe('Only the sendings of this document.'),
        state: z.enum(TRANSMISSION_STATES).optional().describe('Only the sendings in this state.'),
        limit: z.number().int().min(1).max(500).optional().describe('At most this many. 100 by default.'),
      }),
      async run(backend, args) {
        return inSchema('einvoicing', () =>
          listEinvoiceTransmissions(backend, {
            company_id: args['company_id'] as unknown as string,
            ...(args['document_id'] === undefined ? {} : { document_id: args['document_id'] as unknown as string }),
            ...(args['state'] === undefined ? {} : { state: args['state'] as unknown as (typeof TRANSMISSION_STATES)[number] }),
            ...(args['limit'] === undefined ? {} : { limit: args['limit'] as unknown as number }),
          }),
        );
      },
    },
  ],
};

// ---------------------------------------------------------------------------
// corporate income tax — module code `tax`, schema `tax`
//
// The estimate is `tax.estimate()`, read as it is: every line already names
// its rule and its article, so nothing here explains a figure the database
// did not. What a company declares about itself is written by the person,
// through these tools, and the database checks it against its country's
// rules; a judgement is never worked out here from the books.
// ---------------------------------------------------------------------------

const fiscalYearId = uuid.describe('The financial year. get_company lists them.');

/** The country a company's corporate tax rules are read for, as `tax.estimate()` reads it. */
async function taxCountry(backend: Backend, company: string): Promise<string> {
  const rows = await backend.select<{ country: string | null; fiscal_country: string | null }>({
    table: 'companies',
    columns: ['country', 'fiscal_country'],
    where: [{ column: 'id', op: 'eq', value: company }],
  });
  const row = rows[0];
  if (row === undefined) throw new EkwoMcpError(`unknown_company: ${company}`);
  return (row.fiscal_country ?? row.country) as string;
}

/** The first and last day of one financial year of a company. */
async function fiscalYear(backend: Backend, company: string, year: string): Promise<{ start_date: string; end_date: string }> {
  const rows = await backend.select<{ start_date: string; end_date: string }>({
    table: 'fiscal_years',
    columns: ['start_date::text', 'end_date::text'],
    where: [
      { column: 'company_id', op: 'eq', value: company },
      { column: 'id', op: 'eq', value: year },
    ],
  });
  const row = rows[0];
  if (row === undefined) throw new EkwoMcpError(`unknown_fiscal_year: ${year} is not a financial year of this company`);
  return row;
}

const TAX: ModuleToolset = {
  code: 'tax',
  prefix: 'tax',
  schema: 'tax',
  tools: [
    {
      verb: 'estimate',
      title: 'Corporate income tax of a year',
      readOnly: true,
      description:
        'The corporate income tax of a financial year as the ledger stands on a day — the whole year when no day is given — line by line, each with its article: the accounting result the country pack starts from, every adjustment with its base and percentage, the losses of earlier years used, the taxable base, every rate with the slice it takes, a rate refused with the parameter in the way (`not_declared` or `not_met`), the credits, and `estimated_tax`. Reads and writes nothing. It is an estimate from what is booked and from a reading of the rules: never call it the tax due, never call it compliant, and say that the user\'s accountant checks it before anything is filed. During the year it is the tax on the year so far; it forecasts nothing. A rate refused as `not_declared` is a question for the user: tax_parameters, then tax_declare_parameter with their answer.',
      input: z.object({
        company_id: companyId,
        fiscal_year_id: fiscalYearId,
        at: isoDate.optional().describe('Read the ledger as it stands on this day. Left out, the whole year.'),
      }),
      async run(backend, args) {
        const rows = await inSchema('tax', () =>
          backend.rpc<Row>(
            'estimate',
            { p_company_id: args['company_id'], p_fiscal_year_id: args['fiscal_year_id'], p_at: args['at'] ?? null },
            'tax',
          ),
        );
        const lines: Row[] = moneyFields(rows, ['base', 'amount']).map((line) => ({ ...line, rate: decimal(line['rate']) }));
        return {
          fiscal_year_id: args['fiscal_year_id'],
          at: args['at'] ?? null,
          estimated_tax: lines.find((line) => line['kind'] === 'estimated_tax')?.['amount'] ?? null,
          lines,
        };
      },
    },
    {
      verb: 'parameters',
      title: 'What the company declares for its tax',
      readOnly: true,
      description:
        'The facts the country pack asks a company to declare for a financial year — a judgement (is it a small company, who holds its capital) or an amount (its turnover, what it paid its director) — each with its article, and the company\'s answer, or `declared: false`. A condition of a rate that is not declared is not met, so a reduced rate waits for these. Only the user answers them: ask, then tax_declare_parameter.',
      input: z.object({ company_id: companyId, fiscal_year_id: fiscalYearId }),
      async run(backend, args) {
        const company = args['company_id'] as unknown as string;
        const year = args['fiscal_year_id'] as unknown as string;
        const country = await taxCountry(backend, company);
        return inSchema('tax', async () => {
          const templates = await backend.select<Row>({
            schema: 'tax',
            table: 'parameter_templates',
            columns: ['code', 'name', 'name_i18n', 'value_type', 'legal_reference'],
            where: [{ column: 'country', op: 'eq', value: country }],
            order: [{ column: 'sequence' }, { column: 'code' }],
          });
          const declared = await backend.select<Row>({
            schema: 'tax',
            table: 'company_parameters',
            columns: ['code', 'value_boolean', 'value_amount::text', 'note'],
            where: [
              { column: 'company_id', op: 'eq', value: company },
              { column: 'fiscal_year_id', op: 'eq', value: year },
            ],
          });
          const byCode = new Map(declared.map((row) => [row['code'] as string, row]));
          return {
            fiscal_year_id: year,
            parameters: templates.map((template) => {
              const answer = byCode.get(template['code'] as string);
              return {
                ...template,
                declared: answer !== undefined,
                value: answer === undefined ? null : (answer['value_boolean'] ?? answer['value_amount']),
                note: answer?.['note'] ?? null,
              };
            }),
          };
        });
      },
    },
    {
      verb: 'declare_parameter',
      title: 'Declare a fact for the tax',
      readOnly: false,
      description:
        'Writes the company\'s answer to one parameter of tax_parameters for one financial year, replacing an earlier answer: `true` or `false` for a judgement, a decimal string for an amount. Write only what the user has stated, in their words — never a judgement you inferred from the books, which say nothing of who holds the capital or whether a condition is met. Ask before writing. The database refuses a code the country does not ask for (`unknown_tax_parameter`) and a value of the wrong kind (`tax_parameter_type`).',
      input: z.object({
        company_id: companyId,
        fiscal_year_id: fiscalYearId,
        code: z.string().min(1).describe('The code of the parameter, from tax_parameters.'),
        value: z
          .union([z.boolean(), z.string(), z.number()])
          .describe('true or false for a judgement; a decimal string such as "85000.00" for an amount.'),
        note: z.string().optional().describe('What the user said, or where the figure comes from.'),
      }),
      async run(backend, args) {
        const company = args['company_id'] as unknown as string;
        const year = args['fiscal_year_id'] as unknown as string;
        const code = args['code'] as unknown as string;
        const value = args['value'] as unknown as boolean | string | number;
        const values =
          typeof value === 'boolean'
            ? { value_boolean: value, value_amount: null }
            : { value_boolean: null, value_amount: amountIn(value) };
        const where: Filter[] = [
          { column: 'company_id', op: 'eq', value: company },
          { column: 'fiscal_year_id', op: 'eq', value: year },
          { column: 'code', op: 'eq', value: code },
        ];
        const columns = ['code', 'value_boolean', 'value_amount::text', 'note'];
        return inSchema('tax', async () => {
          const updated = await backend.update<Row>(
            'company_parameters',
            { ...values, note: args['note'] ?? null },
            where,
            columns,
            'tax',
          );
          const row =
            updated[0] ??
            (
              await backend.insert<Row>(
                'company_parameters',
                [{ company_id: company, fiscal_year_id: year, code, ...values, note: args['note'] ?? null }],
                columns,
                'tax',
              )
            )[0];
          return {
            fiscal_year_id: year,
            code,
            value: row?.['value_boolean'] ?? row?.['value_amount'] ?? null,
            note: row?.['note'] ?? null,
          };
        });
      },
    },
    {
      verb: 'adjustments',
      title: 'What the tax adds back or deducts',
      readOnly: true,
      description:
        'The adjustment rules of the country pack in force for a financial year — what each adds back to the accounting result or deducts from it, its percentage or the formula that works it out, the accounts the pack catches by itself, and its article — with what the company named under each: an account read from the ledger every time, for every year or for this one, or an amount stated for this year. The pack catches by itself only what a chart keeps on an account of its own; everything else counts only once it is named here, with tax_declare_adjustment. `not_in_force` lists what the company named under a rule that does not apply to this year.',
      input: z.object({ company_id: companyId, fiscal_year_id: fiscalYearId }),
      async run(backend, args) {
        const company = args['company_id'] as unknown as string;
        const year = args['fiscal_year_id'] as unknown as string;
        const country = await taxCountry(backend, company);
        const period = await fiscalYear(backend, company, year);
        return inSchema('tax', async () => {
          const rules = await backend.select<Row>({
            schema: 'tax',
            table: 'adjustment_rule_templates',
            columns: [
              'code',
              'name',
              'name_i18n',
              'direction',
              'percent::text',
              'formula',
              'account_rules',
              'legal_reference',
              'valid_from::text',
              'valid_to::text',
              'valid_on',
            ],
            where: [{ column: 'country', op: 'eq', value: country }],
            order: [{ column: 'sequence' }, { column: 'code' }],
          });
          // In force as `tax.in_force()` reads it: on the first or the last
          // day of the year, whichever the rule says its law is read on.
          const inForce = rules.filter((rule) => {
            const day = rule['valid_on'] === 'period_end' ? period.end_date : period.start_date;
            return (rule['valid_from'] as string) <= day && (rule['valid_to'] === null || (rule['valid_to'] as string) >= day);
          });
          const named = (
            await backend.select<Row>({
              schema: 'tax',
              table: 'adjustments',
              columns: ['id', 'rule_code', 'fiscal_year_id', 'account_id', 'amount::text', 'parameters', 'note'],
              where: [{ column: 'company_id', op: 'eq', value: company }],
            })
          ).filter((row) => row['fiscal_year_id'] === null || row['fiscal_year_id'] === year);
          const accountIds = [...new Set(named.map((row) => row['account_id']).filter((id): id is string => typeof id === 'string'))];
          const accounts =
            accountIds.length === 0
              ? []
              : await backend.select<{ id: string; code: string; name: string }>({
                  table: 'accounts',
                  columns: ['id', 'code', 'name'],
                  where: [{ column: 'id', op: 'in', value: accountIds }],
                });
          const byId = new Map(accounts.map((account) => [account.id, account]));
          const declaration = (row: Row) => {
            const account = typeof row['account_id'] === 'string' ? byId.get(row['account_id']) : undefined;
            return {
              id: row['id'],
              rule_code: row['rule_code'],
              account_code: account?.code ?? null,
              account_name: account?.name ?? null,
              amount: money(row['amount']),
              every_year: row['fiscal_year_id'] === null,
              parameters: row['parameters'],
              note: row['note'],
            };
          };
          const codes = new Set(inForce.map((rule) => rule['code']));
          return {
            fiscal_year_id: year,
            rules: inForce.map((rule) => ({
              ...rule,
              percent: decimal(rule['percent']),
              declared: named.filter((row) => row['rule_code'] === rule['code']).map(declaration),
            })),
            not_in_force: named.filter((row) => !codes.has(row['rule_code'])).map(declaration),
          };
        });
      },
    },
    {
      verb: 'declare_adjustment',
      title: 'Name what falls under an adjustment',
      readOnly: false,
      description:
        'Names what falls under one rule of tax_adjustments: an account, whose balance the estimate reads from the ledger every time — for every year, or for one — or an amount stated for one year. A rule whose percentage is a formula needs the parameters the formula names (`adjustment_parameter_missing` says which). Which expense falls under which rule is the user\'s call, or their accountant\'s: take the account and the amount from them, ask before writing, and run tax_estimate afterwards to show what moved. The database refuses a rule the country does not carry (`unknown_adjustment_rule`).',
      input: z.object({
        company_id: companyId,
        rule_code: z.string().min(1).describe('The code of the rule, from tax_adjustments.'),
        account_code: z.string().optional().describe('An account whose balance falls under the rule. Give this or amount.'),
        amount: z
          .union([z.string(), z.number()])
          .optional()
          .describe('An amount stated for one year, positive; the rule carries the direction. Give this or account_code.'),
        fiscal_year_id: fiscalYearId
          .optional()
          .describe('The financial year. Required with an amount; with an account, left out means every year.'),
        parameters: z
          .record(z.string(), z.union([z.string(), z.number(), z.boolean()]))
          .optional()
          .describe('What the formula of the rule reads, by the names it gives them.'),
        note: z.string().optional(),
      }),
      async run(backend, args) {
        const company = args['company_id'] as unknown as string;
        const accountCode = args['account_code'] as unknown as string | undefined;
        const amount = args['amount'] as unknown as string | number | undefined;
        if ((accountCode === undefined) === (amount === undefined)) {
          throw new EkwoMcpError('account_or_amount: name an account_code, or state an amount — one of the two.');
        }
        let accountId: string | null = null;
        if (accountCode !== undefined) {
          const accounts = await backend.select<{ id: string }>({
            table: 'accounts',
            columns: ['id'],
            where: [
              { column: 'company_id', op: 'eq', value: company },
              { column: 'code', op: 'eq', value: accountCode },
            ],
          });
          accountId = accounts[0]?.id ?? null;
          if (accountId === null) {
            throw new EkwoMcpError(
              `unknown_account: ${accountCode} — not an account of this company. Use list_accounts to find the right code.`,
            );
          }
        }
        const written = await inSchema('tax', () =>
          backend.insert<Row>(
            'adjustments',
            [
              {
                company_id: company,
                fiscal_year_id: args['fiscal_year_id'] ?? null,
                rule_code: args['rule_code'],
                account_id: accountId,
                amount: amount === undefined ? null : amountIn(amount),
                parameters: args['parameters'] ?? {},
                note: args['note'] ?? null,
              },
            ],
            ['id'],
            'tax',
          ),
        );
        return { adjustment_id: written[0]?.['id'] ?? null };
      },
    },
    {
      verb: 'losses',
      title: 'Losses carried forward',
      readOnly: true,
      description:
        'What is left of each loss of an earlier year, by the day its year ended: the loss, what final computations have used of it, and what remains for a later profit. The stock moves only when a computation is called final. How much of it a year may use is the country\'s limit, applied by tax_estimate.',
      input: z.object({
        company_id: companyId,
        before: isoDate.optional().describe('Only the losses of years that ended before this day.'),
      }),
      async run(backend, args) {
        const rows = await inSchema('tax', () =>
          backend.rpc<Row>('loss_stock', { p_company_id: args['company_id'], p_before: args['before'] ?? null }, 'tax'),
        );
        return { losses: moneyFields(rows, ['amount', 'used', 'remaining']) };
      },
    },
    {
      verb: 'record_computation',
      title: 'Keep an estimate',
      readOnly: false,
      description:
        'Keeps what tax_estimate says now as the next computation of the year, numbered, with its lines, so that it can be read again after the ledger moves. It stays an estimate: calling a computation final is the owner\'s act, outside this server, and only a final one names the tax due. Writes nothing to the ledger. Record only when the user asks.',
      input: z.object({
        company_id: companyId,
        fiscal_year_id: fiscalYearId,
        at: isoDate.optional().describe('Read the ledger as it stands on this day. Left out, the whole year.'),
      }),
      async run(backend, args) {
        const id = await inSchema('tax', () =>
          backend.rpc<string>(
            'record_computation',
            { p_company_id: args['company_id'], p_fiscal_year_id: args['fiscal_year_id'], p_at: args['at'] ?? null },
            'tax',
          ),
        );
        return { computation_id: id[0] ?? null };
      },
    },
    {
      verb: 'computations',
      title: 'Computations kept',
      readOnly: true,
      description:
        'The computations kept for a company, latest first, or for one financial year: the version, the day the ledger was read on, the accounting result, the taxable base, the loss of the year and the tax, and the status — `estimate`, `final` (called final by an owner; the only one whose tax is the tax due) or `superseded` (a final one withdrawn, kept).',
      input: z.object({
        company_id: companyId,
        fiscal_year_id: fiscalYearId.optional().describe('Only the computations of this financial year.'),
      }),
      async run(backend, args) {
        const where: Filter[] = [{ column: 'company_id', op: 'eq', value: args['company_id'] as unknown as string }];
        if (args['fiscal_year_id'] !== undefined) {
          where.push({ column: 'fiscal_year_id', op: 'eq', value: args['fiscal_year_id'] as unknown as string });
        }
        const computations = await inSchema('tax', () =>
          backend.select<Row>({
            schema: 'tax',
            table: 'computations',
            columns: [
              'id',
              'fiscal_year_id',
              'version',
              'status',
              'computed_at::text',
              'tax_code',
              'currency_code',
              'accounting_result::text',
              'taxable_base::text',
              'loss_of_period::text',
              'tax::text',
              'recorded_at',
              'finalised_at',
              'superseded_at',
            ],
            where,
            order: [{ column: 'recorded_at', ascending: false }, { column: 'version', ascending: false }],
          }),
        );
        return { computations };
      },
    },
  ],
  prompts: [
    {
      name: 'review_year',
      title: 'Where the corporate income tax of a year stands',
      description:
        'The estimate of a financial year, explained line by line, with what the company still has to declare — and nothing changed without asking.',
      args: {
        company_id: 'The company.',
        fiscal_year_id: 'The financial year, from get_company.',
      },
      text: ({ company_id, fiscal_year_id }) =>
        [
          `Where does the corporate income tax of company ${company_id} stand for the financial year ${fiscal_year_id}? Work through this in order and report what you find; change nothing without asking.`,
          '',
          '1. tax_parameters: the facts the country asks the company to declare. Name every one not declared yet, and ask the user for the answer. Never work one out from the books.',
          '2. tax_adjustments: the rules in force and what the company has named under each. Where the books carry an expense a rule speaks of and nothing is named, say so and ask; which account falls under which rule is the user\'s call, or their accountant\'s.',
          '3. tax_estimate: give the figure line by line — the accounting result, each adjustment with its article, the losses used, the taxable base, each rate and its slice, every rate refused and the parameter that stands in the way, the credits.',
          '4. tax_losses: what is left of the losses of earlier years.',
          '5. tax_computations: whether a computation was kept for the year, and whether one is final.',
          '',
          'Finish with the estimated tax, under that name, and what would change it. It is an estimate from what is booked and from a reading of the rules, not tax advice and not a return: say so, and suggest that the user\'s accountant checks it before anything is filed. Keep it with tax_record_computation only if the user asks.',
        ].join('\n'),
    },
  ],
};

/** Every module this release knows how to expose, by module code. */
export const MODULE_TOOLSETS: readonly ModuleToolset[] = [FIXED_ASSETS, BUDGETS, EINVOICING, TAX];

/** The toolsets for a set of installed module codes, in a fixed order. */
export function toolsetsFor(installed: readonly string[]): ModuleToolset[] {
  const wanted = new Set(installed);
  return MODULE_TOOLSETS.filter((toolset) => wanted.has(toolset.code));
}

/**
 * Which modules this installation carries.
 *
 * `public.modules` is the registry, and it is readable by anyone signed in —
 * it says what exists here, not what any company holds. A database that
 * predates the module framework has no such table, and the answer is then no
 * modules rather than an error.
 */
export async function installedModules(backend: Backend): Promise<string[]> {
  try {
    const rows = await backend.select<{ code: string; status: string }>({
      table: 'modules',
      columns: ['code', 'status'],
      order: [{ column: 'code' }],
    });
    return rows.filter((row) => row.status !== 'draft').map((row) => row.code);
  } catch {
    return [];
  }
}
