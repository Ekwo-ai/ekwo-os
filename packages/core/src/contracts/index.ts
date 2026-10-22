/**
 * The `contracts` module, for every surface.
 *
 * Each verb is one function of the `contracts` schema, called here once, so
 * the MCP server's `contracts_*` tools and `ekwo contracts …` run the very
 * same thing. Nothing is decided in this file: which fields a patch may name,
 * which period is due, what a renewal extends to — the schema holds it, and
 * refuses by name (`contracts_<code>: …`). The words of its enums are
 * repeated below to be shown, and a test holds them to the schema.
 */

import { BooksError, type Backend, type Row } from '../books/backend.js';

/** The schema the module lives in, and the code of `public.modules`. */
export const CONTRACTS_SCHEMA = 'contracts';

// The words of the schema's enums, in the order the migration declares them.
// The enums of the `contracts` schema stay the source: a test in
// `modules/contracts/tests` reads each one with `enum_range()` and holds
// these lists to it.

/** `contracts.contract_kind`: what a contract is about. */
export const CONTRACT_KINDS = ['service', 'licence', 'subscription', 'usage', 'one_time', 'other'] as const;
export type ContractKind = (typeof CONTRACT_KINDS)[number];

/** `contracts.direction`: which side the company is on. */
export const CONTRACT_DIRECTIONS = ['sale', 'purchase'] as const;
export type ContractDirection = (typeof CONTRACT_DIRECTIONS)[number];

/** `contracts.contract_state`: where a contract stands; it moves forward only. */
export const CONTRACT_STATES = [
  'draft', 'sent', 'negotiation', 'signed', 'active', 'expired', 'terminated', 'cancelled',
] as const;
export type ContractState = (typeof CONTRACT_STATES)[number];

/** `contracts.renewal`: what happens at the end. */
export const CONTRACT_RENEWALS = ['none', 'tacit'] as const;
export type ContractRenewal = (typeof CONTRACT_RENEWALS)[number];

/** `contracts.frequency`: how often a schedule issues. */
export const CONTRACT_FREQUENCIES = ['weekly', 'monthly', 'quarterly', 'yearly'] as const;
export type ContractFrequency = (typeof CONTRACT_FREQUENCIES)[number];

/** `contracts.amendment_kind`: a version of the text, an amendment, or a tacit renewal. */
export const CONTRACT_AMENDMENT_KINDS = ['version', 'amendment', 'renewal'] as const;
export type ContractAmendmentKind = (typeof CONTRACT_AMENDMENT_KINDS)[number];

/** `contracts.template_format`: how a template holds its clauses. */
export const CONTRACT_TEMPLATE_FORMATS = ['html', 'docx'] as const;
export type ContractTemplateFormat = (typeof CONTRACT_TEMPLATE_FORMATS)[number];

/** The keys `contracts.upsert_contract()` accepts in its patch. It refuses any other, by name. */
export const CONTRACT_FIELDS = [
  'contact_id', 'name', 'kind', 'direction', 'state', 'signed_on', 'starts_on', 'ends_on', 'renews_on', 'renewal',
  'notice_days', 'currency_code', 'total_value', 'attachment_id', 'template_id', 'notes', 'analysis', 'attributes',
] as const;

/** The keys `contracts.upsert_schedule()` accepts in its patch. */
export const CONTRACT_SCHEDULE_FIELDS = [
  'sequence', 'product_id', 'product_code', 'name', 'description', 'quantity', 'unit_code', 'unit_price', 'tax_code',
  'frequency', 'next_on', 'until', 'indexation', 'auto_post',
] as const;

/** The kinds of row `contracts.deadlines` holds. */
export const CONTRACT_DEADLINE_KINDS = ['notice', 'renewal', 'end', 'next_issue', 'indexation'] as const;
export type ContractDeadlineKind = (typeof CONTRACT_DEADLINE_KINDS)[number];

export interface ContractsListArgs {
  company_id: string;
  state?: ContractState | undefined;
  direction?: ContractDirection | undefined;
  contact_id?: string | undefined;
  query?: string | undefined;
  limit?: number | undefined;
  /** Also list the templates of the company, the active ones. */
  templates?: boolean | undefined;
}

export interface ContractsDeadlinesArgs {
  company_id: string;
  /** On or after this day. */
  from?: string | undefined;
  /** On or before this day. */
  to?: string | undefined;
  contract_id?: string | undefined;
  kinds?: ContractDeadlineKind[] | undefined;
}

export interface ContractsAmendArgs {
  company_id: string;
  contract_id: string;
  summary: string;
  effective_on: string;
  changes?: Record<string, unknown> | undefined;
  kind?: Exclude<ContractAmendmentKind, 'renewal'> | undefined;
  signed_on?: string | undefined;
  attachment_id?: string | undefined;
}

export interface ContractsFromTemplateArgs {
  company_id: string;
  template_id: string;
  contact_id: string;
  number: string;
  direction: ContractDirection;
  kind: ContractKind;
  starts_on: string;
  values?: Record<string, string> | undefined;
  name?: string | undefined;
}

const orNull = <T>(value: T | undefined): T | null => (value === undefined ? null : value);

async function call(backend: Backend, fn: string, args: Record<string, unknown>): Promise<Row[]> {
  return backend.rpc<Row>(fn, args, CONTRACTS_SCHEMA);
}

async function callOne(backend: Backend, fn: string, args: Record<string, unknown>): Promise<Row> {
  const [row] = await call(backend, fn, args);
  if (row === undefined || row === null) {
    throw new BooksError(`contracts_no_answer: ${CONTRACTS_SCHEMA}.${fn} answered nothing`);
  }
  return row;
}

/** `contracts.list_contracts()`: the contracts, each with its nearest deadline; and the templates when asked. */
export async function contractsList(
  backend: Backend,
  args: ContractsListArgs,
): Promise<{ contracts: Row[]; count: number; templates?: Row[] }> {
  const contracts = await call(backend, 'list_contracts', {
    p_company_id: args.company_id,
    p_state: orNull(args.state),
    p_direction: orNull(args.direction),
    p_contact_id: orNull(args.contact_id),
    p_query: orNull(args.query),
    p_limit: args.limit ?? 50,
  });
  if (args.templates !== true) return { contracts, count: contracts.length };
  const templates = await call(backend, 'list_templates', { p_company_id: args.company_id, p_include_inactive: false });
  return { contracts, count: contracts.length, templates };
}

/** `contracts.card_of()`: one contract as one object, exactly as the function builds it. */
export async function contractsCard(backend: Backend, args: { company_id: string; contract_id: string }): Promise<Row> {
  return callOne(backend, 'card_of', { p_company_id: args.company_id, p_contract_id: args.contract_id });
}

/** `contracts.upsert_contract()`: the contract of that number, created or changed field by field. */
export async function contractsUpsert(
  backend: Backend,
  args: { company_id: string; number: string; patch: Record<string, unknown> },
): Promise<{ contract: Row }> {
  const contract = await callOne(backend, 'upsert_contract', {
    p_company_id: args.company_id,
    p_number: args.number,
    p_patch: args.patch,
  });
  return { contract };
}

/** `contracts.upsert_schedule()`: a schedule added to a contract, or changed. */
export async function contractsSchedule(
  backend: Backend,
  args: { company_id: string; contract_id: string; schedule_id?: string | undefined; patch: Record<string, unknown> },
): Promise<{ schedule: Row }> {
  const schedule = await callOne(backend, 'upsert_schedule', {
    p_company_id: args.company_id,
    p_contract_id: args.contract_id,
    p_schedule_id: orNull(args.schedule_id),
    p_patch: args.patch,
  });
  return { schedule };
}

/** `contracts.issue_due()`: every period that has come, one draft document each. */
export async function contractsIssueDue(
  backend: Backend,
  args: { company_id: string; on_date: string },
): Promise<{ issued: Row[]; count: number }> {
  const issued = await call(backend, 'issue_due', { p_company_id: args.company_id, p_on_date: args.on_date });
  return { issued, count: issued.length };
}

/** `contracts.deadlines`: the dates the running contracts ask somebody to act on, soonest first. */
export async function contractsDeadlines(
  backend: Backend,
  args: ContractsDeadlinesArgs,
): Promise<{ deadlines: Row[]; count: number }> {
  const deadlines = await backend.select<Row>({
    schema: CONTRACTS_SCHEMA,
    table: 'deadlines',
    columns: ['contract_id', 'contract_number', 'contract_name', 'direction', 'contact_id', 'schedule_id', 'kind', 'due_on'],
    where: [
      { column: 'company_id', op: 'eq', value: args.company_id },
      ...(args.from === undefined ? [] : [{ column: 'due_on', op: 'gte' as const, value: args.from }]),
      ...(args.to === undefined ? [] : [{ column: 'due_on', op: 'lte' as const, value: args.to }]),
      ...(args.contract_id === undefined ? [] : [{ column: 'contract_id', op: 'eq' as const, value: args.contract_id }]),
      ...(args.kinds === undefined ? [] : [{ column: 'kind', op: 'in' as const, value: args.kinds }]),
    ],
    order: [{ column: 'due_on' }, { column: 'contract_number' }, { column: 'kind' }],
  });
  return { deadlines, count: deadlines.length };
}

/** `contracts.amend()`: what changes and from when, applied and numbered in the contract's history. */
export async function contractsAmend(backend: Backend, args: ContractsAmendArgs): Promise<{ amendment: Row }> {
  const amendment = await callOne(backend, 'amend', {
    p_company_id: args.company_id,
    p_contract_id: args.contract_id,
    p_summary: args.summary,
    p_effective_on: args.effective_on,
    p_changes: args.changes ?? {},
    p_kind: args.kind ?? 'amendment',
    p_signed_on: orNull(args.signed_on),
    p_attachment_id: orNull(args.attachment_id),
  });
  return { amendment };
}

/** `contracts.from_template()`: a draft contract, its schedule and its clauses with the values in place. */
export async function contractsFromTemplate(backend: Backend, args: ContractsFromTemplateArgs): Promise<Row> {
  return callOne(backend, 'from_template', {
    p_company_id: args.company_id,
    p_template_id: args.template_id,
    p_contact_id: args.contact_id,
    p_number: args.number,
    p_direction: args.direction,
    p_kind: args.kind,
    p_starts_on: args.starts_on,
    p_values: args.values ?? {},
    p_name: orNull(args.name),
  });
}
