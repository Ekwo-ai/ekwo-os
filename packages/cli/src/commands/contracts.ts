/**
 * `ekwo contracts list | card | set | schedule | issue | deadlines | amend |
 * from-template` — the `contracts` module from a terminal.
 *
 * Each verb is one function of the core — `contractsList()`,
 * `contractsCard()`, `contractsUpsert()`, `contractsSchedule()`,
 * `contractsIssueDue()`, `contractsDeadlines()`, `contractsAmend()`,
 * `contractsFromTemplate()` — which the MCP server calls for the
 * `contracts_*` tool of the same name, and each of those is one function of
 * the `contracts` schema. Nothing is decided here: a kind, a state or a
 * rhythm is checked against the words of the schema's enums as the core
 * lists them, and everything else is refused by the database, by name. What
 * a terminal adds is a contract named by its number as well as by its id, a
 * party named by its name, and a table to read.
 */

import {
  CONTRACT_DEADLINE_KINDS,
  CONTRACT_DIRECTIONS,
  CONTRACT_FREQUENCIES,
  CONTRACT_KINDS,
  CONTRACT_RENEWALS,
  CONTRACT_STATES,
  CONTRACTS_SCHEMA,
  contractsAmend,
  contractsCard,
  contractsDeadlines,
  contractsFromTemplate,
  contractsIssueDue,
  contractsList,
  contractsSchedule,
  contractsUpsert,
  resolveContact,
  type Backend,
} from '@ekwo-ai/core';
import { UsageError, boolFlag, numberFlag, rejectUnknownFlags, stringFlag, stringFlags, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, given, openBooks, required, today, uuidArg, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, line, note, pairs, step, table } from '../ui.js';

type Row = Record<string, unknown>;

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const LIST_FLAGS = [...BOOKS_FLAGS, 'state', 'direction', 'contact', 'query', 'limit', 'templates'] as const;
const CARD_FLAGS = [...BOOKS_FLAGS] as const;
const SET_FLAGS = [
  ...BOOKS_FLAGS, 'contact', 'name', 'kind', 'direction', 'state', 'signed', 'starts', 'ends', 'renews', 'renewal',
  'notice-days', 'currency', 'value', 'notes',
] as const;
const SCHEDULE_FLAGS = [
  ...BOOKS_FLAGS, 'schedule', 'name', 'description', 'product', 'quantity', 'unit', 'price', 'tax', 'frequency',
  'next', 'until', 'auto-post',
] as const;
const ISSUE_FLAGS = [...BOOKS_FLAGS, 'on'] as const;
const DEADLINES_FLAGS = [...BOOKS_FLAGS, 'from', 'to', 'kind'] as const;
const AMEND_FLAGS = [...BOOKS_FLAGS, 'summary', 'from', 'changes', 'version', 'signed', 'file'] as const;
const TEMPLATE_FLAGS = [...BOOKS_FLAGS, 'number', 'direction', 'kind', 'starts', 'value', 'name'] as const;

const USAGE =
  'usage: ekwo contracts list [--state <state> --direction sale|purchase --contact <contact> --query <text> --limit <n> --templates]' +
  ' | ekwo contracts card <contract>' +
  ' | ekwo contracts set <number> [--contact <contact> --name --kind <kind> --direction sale|purchase --state <state> --signed --starts --ends --renews --renewal none|tacit --notice-days <n> --currency --value --notes]' +
  ' | ekwo contracts schedule <contract> [--schedule <id>] [--name --description --product <code> --quantity --unit --price --tax <code> --frequency <frequency> --next <date> --until <date> --auto-post yes|no]' +
  ' | ekwo contracts issue [--on <date>]' +
  ' | ekwo contracts deadlines [--from <date> --to <date> --kind <kind>…]' +
  ' | ekwo contracts amend <contract> --summary <text> --from <date> [--changes <json> --version --signed <date> --file <attachment-id>]' +
  ' | ekwo contracts from-template <template-id> <contact> --number <number> --direction sale|purchase --kind <kind> --starts <date> [--value key=value… --name]' +
  ` — <kind> is ${CONTRACT_KINDS.join('|')}; <state> is ${CONTRACT_STATES.join('|')}; <frequency> is ${CONTRACT_FREQUENCIES.join('|')}; a deadline <kind> is ${CONTRACT_DEADLINE_KINDS.join('|')}`;

/** A word of one of the schema's enums, refused here with the list rather than guessed at. */
function oneOf<T extends string>(values: readonly T[], value: string | undefined, flag: string): T | undefined {
  if (value === undefined) return undefined;
  if (!(values as readonly string[]).includes(value)) {
    throw new UsageError(`bad_value: --${flag} is one of ${values.join(', ')}, got "${value}".`);
  }
  return value as T;
}

const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

/** A contract by its id, or by its number in the company. */
async function contractOf(backend: Backend, company: string, wanted: string | undefined): Promise<{ id: string; number: string }> {
  if (wanted === undefined) throw new UsageError(`missing_argument: the contract, by number or id. ${USAGE}`);
  const found = await backend.select<{ id: string; number: string }>({
    schema: CONTRACTS_SCHEMA,
    table: 'contracts',
    columns: ['id', 'number'],
    where: [
      { column: 'company_id', op: 'eq', value: company },
      UUID.test(wanted) ? { column: 'id', op: 'eq', value: wanted.toLowerCase() } : { column: 'number', op: 'eq', value: wanted },
    ],
    limit: 1,
  });
  const contract = found[0];
  if (contract === undefined) {
    throw new UsageError(`contracts_unknown_contract: no contract "${wanted}" in this company. ekwo contracts list shows them.`);
  }
  return contract;
}

function jsonFlag(args: ParsedArgs, name: string): Record<string, unknown> | undefined {
  const raw = stringFlag(args, name);
  if (raw === undefined) return undefined;
  let parsed: unknown;
  try {
    parsed = JSON.parse(raw);
  } catch {
    throw new UsageError(`bad_json: --${name} is a JSON object.`);
  }
  if (typeof parsed !== 'object' || parsed === null || Array.isArray(parsed)) {
    throw new UsageError(`bad_json: --${name} is a JSON object.`);
  }
  return parsed as Record<string, unknown>;
}

export async function contractsCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  const action = args.positional[0];
  if (action === 'list') return list(args, deps);
  if (action === 'card') return card(args, deps);
  if (action === 'set') return set(args, deps);
  if (action === 'schedule') return schedule(args, deps);
  if (action === 'issue') return issue(args, deps);
  if (action === 'deadlines') return deadlines(args, deps);
  if (action === 'amend') return amend(args, deps);
  if (action === 'from-template') return fromTemplate(args, deps);
  throw new UsageError(USAGE);
}

async function list(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, LIST_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const wantedContact = stringFlag(args, 'contact');
  const contact = wantedContact === undefined ? undefined : await resolveContact(backend, company.id, wantedContact);
  const result = await contractsList(backend, given({
    company_id: company.id,
    state: oneOf(CONTRACT_STATES, stringFlag(args, 'state'), 'state'),
    direction: oneOf(CONTRACT_DIRECTIONS, stringFlag(args, 'direction'), 'direction'),
    contact_id: contact?.id,
    query: stringFlag(args, 'query'),
    limit: numberFlag(args, 'limit'),
    templates: boolFlag(args, 'templates') ? true : undefined,
  }));
  setResult(result);

  heading(`Contracts of ${company.name}`);
  if (result.contracts.length === 0) note(dim('None.'));
  else {
    table(
      [{ title: 'number' }, { title: 'name' }, { title: 'party' }, { title: 'side' }, { title: 'state' }, { title: 'ends' }, { title: 'next' }, { title: 'id' }],
      result.contracts.map((c) => [
        text(c['number']),
        text(c['name']),
        text(c['contact_name']),
        text(c['direction']),
        text(c['state']),
        text(c['ends_on']),
        c['next_deadline'] === null ? '' : `${text(c['next_kind'])} ${text(c['next_deadline'])}`,
        dim(text(c['id'])),
      ]),
    );
  }
  if (result.templates !== undefined) {
    line();
    heading('Templates');
    if (result.templates.length === 0) note(dim('None.'));
    else {
      table(
        [{ title: 'template' }, { title: 'category' }, { title: 'format' }, { title: 'id' }],
        result.templates.map((t) => [text(t['name']), text(t['category']), text(t['format']), dim(text(t['id']))]),
      );
    }
  }
  return 0;
}

async function card(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, CARD_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const contract = await contractOf(backend, company.id, args.positional[1]);
  const result = await contractsCard(backend, { company_id: company.id, contract_id: contract.id });
  setResult(result);

  const c = (result['contract'] ?? {}) as Row;
  const party = (result['contact'] ?? {}) as Row;
  heading(`${text(c['number'])} — ${text(c['name'])} ${dim(text(c['id']))}`);
  pairs([
    ['party', text(party['name'])],
    ['side', text(c['direction'])],
    ['kind', text(c['kind'])],
    ['state', text(c['state'])],
    ['term', `${text(c['starts_on'])} → ${c['ends_on'] === null ? 'open-ended' : text(c['ends_on'])}`],
    ['renewal', `${text(c['renewal'])}${c['notice_days'] === null ? '' : `, ${text(c['notice_days'])} days' notice`}`],
    ['value', c['total_value'] === null ? '' : `${text(c['total_value'])} ${text(c['currency_code'])}`],
  ]);
  const schedules = (result['schedules'] ?? []) as Row[];
  if (schedules.length > 0) {
    line();
    table(
      [{ title: 'schedule' }, { title: 'quantity', align: 'right' }, { title: 'price', align: 'right' }, { title: 'tax' }, { title: 'every' }, { title: 'next' }, { title: 'id' }],
      schedules.map((s) => [text(s['name']), text(s['quantity']), text(s['unit_price']), text(s['tax_code']), text(s['frequency']), text(s['next_on']), dim(text(s['id']))]),
    );
  }
  const issues = (result['issues'] ?? []) as Row[];
  if (issues.length > 0) {
    line();
    table(
      [{ title: 'period' }, { title: 'document' }, { title: 'state' }, { title: 'total', align: 'right' }, { title: 'id' }],
      issues.map((i) => [
        `${text(i['period_start'])} → ${text(i['period_end'])}`,
        text(i['number']),
        text(i['state']),
        `${text(i['amount_total'])} ${text(i['currency_code'])}`,
        dim(text(i['document_id'])),
      ]),
    );
  }
  const deadlinesOf = (result['deadlines'] ?? []) as Row[];
  if (deadlinesOf.length > 0) step(`deadlines: ${deadlinesOf.map((d) => `${text(d['kind'])} ${text(d['due_on'])}`).join(', ')}`);
  return 0;
}

async function set(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, SET_FLAGS);
  const number = args.positional[1];
  if (number === undefined) throw new UsageError(`missing_argument: the number of the contract. ${USAGE}`);
  const notice = numberFlag(args, 'notice-days');
  const { backend, company } = await openBooks(args, deps);
  const wantedContact = stringFlag(args, 'contact');
  const contact = wantedContact === undefined ? undefined : await resolveContact(backend, company.id, wantedContact);
  const patch: Row = given({
    contact_id: contact?.id,
    name: stringFlag(args, 'name'),
    kind: oneOf(CONTRACT_KINDS, stringFlag(args, 'kind'), 'kind'),
    direction: oneOf(CONTRACT_DIRECTIONS, stringFlag(args, 'direction'), 'direction'),
    state: oneOf(CONTRACT_STATES, stringFlag(args, 'state'), 'state'),
    signed_on: stringFlag(args, 'signed'),
    starts_on: stringFlag(args, 'starts'),
    ends_on: stringFlag(args, 'ends'),
    renews_on: stringFlag(args, 'renews'),
    renewal: oneOf(CONTRACT_RENEWALS, stringFlag(args, 'renewal'), 'renewal'),
    notice_days: notice,
    currency_code: stringFlag(args, 'currency'),
    total_value: stringFlag(args, 'value'),
    notes: stringFlag(args, 'notes'),
  });
  const result = await contractsUpsert(backend, { company_id: company.id, number, patch });
  setResult(result);

  heading('Contract');
  step(`${text(result.contract['number'])} ${dim(text(result.contract['id']))}: ${Object.keys(patch).join(', ') || 'nothing'} set`);
  pairs([
    ['state', text(result.contract['state'])],
    ['currency', text(result.contract['currency_code'])],
  ]);
  return 0;
}

async function schedule(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, SCHEDULE_FLAGS);
  const scheduleFlag = stringFlag(args, 'schedule');
  const scheduleId = scheduleFlag === undefined ? undefined : uuidArg(scheduleFlag, '--schedule');
  const autoPost = args.flags.has('auto-post') ? boolFlag(args, 'auto-post') : undefined;
  const patch: Row = given({
    name: stringFlag(args, 'name'),
    description: stringFlag(args, 'description'),
    product_code: stringFlag(args, 'product'),
    quantity: stringFlag(args, 'quantity'),
    unit_code: stringFlag(args, 'unit'),
    unit_price: stringFlag(args, 'price'),
    tax_code: stringFlag(args, 'tax'),
    frequency: oneOf(CONTRACT_FREQUENCIES, stringFlag(args, 'frequency'), 'frequency'),
    next_on: stringFlag(args, 'next'),
    until: stringFlag(args, 'until'),
    auto_post: autoPost,
  });
  const { backend, company } = await openBooks(args, deps);
  const contract = await contractOf(backend, company.id, args.positional[1]);
  const result = await contractsSchedule(backend, given({
    company_id: company.id,
    contract_id: contract.id,
    schedule_id: scheduleId,
    patch,
  }));
  setResult(result);

  heading('Schedule');
  step(`${contract.number}: ${text(result.schedule['name'])} ${dim(text(result.schedule['id']))}`);
  pairs([
    ['every', text(result.schedule['frequency'])],
    ['next', text(result.schedule['next_on'])],
    ['price', text(result.schedule['unit_price'])],
    ['tax', text(result.schedule['tax_code'])],
  ]);
  return 0;
}

async function issue(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, ISSUE_FLAGS);
  const onDate = stringFlag(args, 'on') ?? today();
  const { backend, company } = await openBooks(args, deps);
  const result = await contractsIssueDue(backend, { company_id: company.id, on_date: onDate });
  setResult({ ...result, on_date: onDate });

  heading(`Issued on ${onDate}`);
  if (result.issued.length === 0) note(dim('Nothing was due.'));
  else {
    table(
      [{ title: 'contract' }, { title: 'period' }, { title: 'booked' }, { title: 'document' }],
      result.issued.map((i) => [
        text(i['contract_number']),
        `${text(i['period_start'])} → ${text(i['period_end'])}`,
        i['posted'] === true ? 'yes' : 'draft',
        dim(text(i['document_id'])),
      ]),
    );
  }
  return 0;
}

async function deadlines(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, DEADLINES_FLAGS);
  const kinds = stringFlags(args, 'kind').map(
    (kind) => oneOf(CONTRACT_DEADLINE_KINDS, kind, 'kind') as (typeof CONTRACT_DEADLINE_KINDS)[number],
  );
  const { backend, company } = await openBooks(args, deps);
  const result = await contractsDeadlines(backend, given({
    company_id: company.id,
    from: stringFlag(args, 'from'),
    to: stringFlag(args, 'to'),
    kinds: kinds.length === 0 ? undefined : kinds,
  }));
  setResult(result);

  heading(`Deadlines of ${company.name}`);
  if (result.deadlines.length === 0) note(dim('None.'));
  else {
    table(
      [{ title: 'day' }, { title: 'what' }, { title: 'contract' }, { title: 'name' }],
      result.deadlines.map((d) => [text(d['due_on']), text(d['kind']), text(d['contract_number']), text(d['contract_name'])]),
    );
  }
  return 0;
}

async function amend(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, AMEND_FLAGS);
  const summary = required(stringFlag(args, 'summary'), 'what changes', '--summary <text>');
  const from = required(stringFlag(args, 'from'), 'from when it holds', '--from <date>');
  const file = stringFlag(args, 'file');
  const { backend, company } = await openBooks(args, deps);
  const contract = await contractOf(backend, company.id, args.positional[1]);
  const result = await contractsAmend(backend, given({
    company_id: company.id,
    contract_id: contract.id,
    summary,
    effective_on: from,
    changes: jsonFlag(args, 'changes'),
    kind: boolFlag(args, 'version') ? ('version' as const) : undefined,
    signed_on: stringFlag(args, 'signed'),
    attachment_id: file === undefined ? undefined : uuidArg(file, '--file'),
  }));
  setResult(result);

  heading('Amendment');
  step(`${contract.number} #${text(result.amendment['number'])} (${text(result.amendment['kind'])}) from ${text(result.amendment['effective_on'])}: ${summary}`);
  return 0;
}

async function fromTemplate(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, TEMPLATE_FLAGS);
  const templateId = uuidArg(args.positional[1], 'the template');
  const values: Record<string, string> = {};
  for (const pair of stringFlags(args, 'value')) {
    const at = pair.indexOf('=');
    if (at <= 0) throw new UsageError(`bad_value: --value is key=value, got "${pair}".`);
    values[pair.slice(0, at)] = pair.slice(at + 1);
  }
  const number = required(stringFlag(args, 'number'), 'the number of the contract', '--number <number>');
  const direction = oneOf(CONTRACT_DIRECTIONS, required(stringFlag(args, 'direction'), 'the side', '--direction sale|purchase'), 'direction') as (typeof CONTRACT_DIRECTIONS)[number];
  const kind = oneOf(CONTRACT_KINDS, required(stringFlag(args, 'kind'), 'the kind', `--kind ${CONTRACT_KINDS.join('|')}`), 'kind') as (typeof CONTRACT_KINDS)[number];
  const startsOn = required(stringFlag(args, 'starts'), 'the first day', '--starts <date>');
  const { backend, company } = await openBooks(args, deps);
  const contact = await resolveContact(backend, company.id, required(args.positional[2], 'the other party', '<contact>'));
  const result = await contractsFromTemplate(backend, given({
    company_id: company.id,
    template_id: templateId,
    contact_id: contact.id,
    number,
    direction,
    kind,
    starts_on: startsOn,
    values,
    name: stringFlag(args, 'name'),
  }));
  setResult(result);

  const made = (result['contract'] ?? {}) as Row;
  heading('Contract, from a template');
  step(`${text(made['number'])} — ${text(made['name'])} ${dim(text(made['id']))}, a draft with ${contact.name}`);
  const html = result['html'];
  if (typeof html === 'string') {
    line();
    note(html);
  }
  return 0;
}
