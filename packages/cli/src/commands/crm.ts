/**
 * `ekwo crm search | card | card set | segments | board | timeline | log |
 * join | leave | deal open | deal move` — the `crm` module from a terminal.
 *
 * Each verb is one function of the core — `crmSearch()`, `crmCard()`,
 * `crmUpsertCard()`, `crmSegments()`, `crmBoard()`, `crmTimeline()`,
 * `crmLogActivity()`, `crmJoinSegment()`, `crmLeaveSegment()`,
 * `crmOpenDeal()`, `crmMoveDeal()` — which the MCP server calls for the
 * `crm_*` tool of the same name, and each of those is one function of the
 * `crm` schema. Nothing is decided here: a status, a priority or a kind is
 * checked against the words of the schema's enums as the core lists them —
 * a test holds those lists to the schema — and everything else is refused by
 * the database, by name. What a terminal adds is a contact named by its name as well as by its id,
 * and a table to read.
 */

import {
  CRM_ACTIVITY_KINDS,
  CRM_PRIORITIES,
  CRM_RELATIONSHIP_STATUSES,
  crmBoard,
  crmCard,
  crmJoinSegment,
  crmLeaveSegment,
  crmLogActivity,
  crmMoveDeal,
  crmOpenDeal,
  crmSearch,
  crmSegments,
  crmTimeline,
  crmUpsertCard,
  resolveContact,
  type Backend,
} from '@ekwo-ai/core';
import { UsageError, boolFlag, numberFlag, rejectUnknownFlags, stringFlag, stringFlags, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, given, openBooks, required, uuidArg, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, line, note, pairs, step, table } from '../ui.js';

type Row = Record<string, unknown>;

const STATUSES = CRM_RELATIONSHIP_STATUSES.join('|');
const PRIORITIES = CRM_PRIORITIES.join('|');
const KINDS = CRM_ACTIVITY_KINDS.join('|');

const SEARCH_FLAGS = [
  ...BOOKS_FLAGS, 'query', 'status', 'segment', 'stage', 'country', 'language', 'owner', 'no-outbound',
  'active-since', 'inactive-since', 'limit',
] as const;
const CARD_FLAGS = [...BOOKS_FLAGS] as const;
const CARD_SET_FLAGS = [
  ...BOOKS_FLAGS, 'status', 'priority', 'owner', 'tag', 'job-title', 'linkedin', 'source', 'no-outbound', 'custom',
] as const;
const SEGMENTS_FLAGS = [...BOOKS_FLAGS] as const;
const BOARD_FLAGS = [...BOOKS_FLAGS, 'closed'] as const;
const TIMELINE_FLAGS = [...BOOKS_FLAGS, 'deal', 'since', 'kind', 'limit'] as const;
const LOG_FLAGS = [
  ...BOOKS_FLAGS, 'kind', 'subject', 'body', 'deal', 'actor', 'at', 'link', 'source', 'source-ref',
] as const;
const SEGMENT_FLAGS = [...BOOKS_FLAGS, 'by', 'note'] as const;
const LEAVE_FLAGS = [...BOOKS_FLAGS] as const;
const DEAL_OPEN_FLAGS = [...BOOKS_FLAGS, 'title', 'amount', 'currency', 'expected', 'url', 'owner'] as const;
const DEAL_MOVE_FLAGS = [...BOOKS_FLAGS] as const;

const USAGE =
  'usage: ekwo crm search [--query --status <status> --segment --stage --country --language --owner --no-outbound yes|no --active-since --inactive-since --limit]' +
  ' | ekwo crm card <contact>' +
  ' | ekwo crm card set <contact> [--status <status> --priority <priority> --owner --tag <tag>… --job-title --linkedin --source --no-outbound yes|no --custom <json>]' +
  ' | ekwo crm segments' +
  ' | ekwo crm board [<pipeline-id>] [--closed]' +
  ' | ekwo crm timeline <contact> [--deal <deal-id> --since <moment> --kind <kind>… --limit <n>]' +
  ' | ekwo crm log <contact> --kind <kind> [--subject --body --deal --actor --at --link --source --source-ref]' +
  ' | ekwo crm join <segment-id> <contact> [--by --note]' +
  ' | ekwo crm leave <segment-id> <contact>' +
  ' | ekwo crm deal open <pipeline-id> <contact> --title <title> [--amount --currency --expected --url --owner]' +
  ' | ekwo crm deal move <deal-id> <stage-id>' +
  ` — <status> is ${STATUSES}; <priority> is ${PRIORITIES}; <kind> is ${KINDS}`;

/** A word of one of the schema's enums, refused here with the list rather than guessed at. */
function oneOf<T extends string>(values: readonly T[], value: string | undefined, flag: string): T | undefined {
  if (value === undefined) return undefined;
  if (!(values as readonly string[]).includes(value)) {
    throw new UsageError(`bad_value: --${flag} is one of ${values.join(', ')}, got "${value}".`);
  }
  return value as T;
}

const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

/** A tri-state switch: left out is no filter, `yes` or `no` is one. */
function optionalSwitch(args: ParsedArgs, name: string): boolean | undefined {
  return args.flags.has(name) ? boolFlag(args, name) : undefined;
}

/** A contact by id, or by its name or part of it, refused when it is several. */
async function contactOf(backend: Backend, company: string, wanted: string | undefined): Promise<{ id: string; name: string }> {
  if (wanted === undefined) throw new UsageError(`missing_argument: the contact, by name or id. ${USAGE}`);
  return resolveContact(backend, company, wanted);
}

export async function crmCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  const action = args.positional[0];
  if (action === 'search') return search(args, deps);
  if (action === 'card') return args.positional[1] === 'set' ? cardSet(args, deps) : card(args, deps);
  if (action === 'segments') return segments(args, deps);
  if (action === 'board') return board(args, deps);
  if (action === 'timeline') return timeline(args, deps);
  if (action === 'log') return log(args, deps);
  if (action === 'join') return join(args, deps);
  if (action === 'leave') return leave(args, deps);
  if (action === 'deal' && args.positional[1] === 'open') return dealOpen(args, deps);
  if (action === 'deal' && args.positional[1] === 'move') return dealMove(args, deps);
  throw new UsageError(USAGE);
}

async function search(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, SEARCH_FLAGS);
  const segment = stringFlag(args, 'segment');
  const stage = stringFlag(args, 'stage');
  const { backend, company } = await openBooks(args, deps);
  const result = await crmSearch(backend, given({
    company_id: company.id,
    query: stringFlag(args, 'query'),
    status: oneOf(CRM_RELATIONSHIP_STATUSES, stringFlag(args, 'status'), 'status'),
    segment_id: segment === undefined ? undefined : uuidArg(segment, '--segment'),
    stage_id: stage === undefined ? undefined : uuidArg(stage, '--stage'),
    country: stringFlag(args, 'country'),
    language: stringFlag(args, 'language'),
    owner: stringFlag(args, 'owner'),
    no_outbound: optionalSwitch(args, 'no-outbound'),
    active_since: stringFlag(args, 'active-since'),
    inactive_since: stringFlag(args, 'inactive-since'),
    limit: numberFlag(args, 'limit'),
  }));
  setResult(result);

  heading(`Cards of ${company.name}`);
  if (result.cards.length === 0) note(dim('None.'));
  else {
    table(
      [{ title: 'name' }, { title: 'organisation' }, { title: 'status' }, { title: 'priority' }, { title: 'owner' }, { title: 'last activity' }, { title: 'segments' }, { title: 'id' }],
      result.cards.map((c) => [
        text(c['name']),
        text(c['organisation_name']),
        text(c['status']),
        text(c['priority']),
        text(c['owner']),
        text(c['last_activity_at']),
        Array.isArray(c['segments']) ? (c['segments'] as string[]).join(', ') : '',
        dim(text(c['contact_id'])),
      ]),
    );
  }
  return 0;
}

async function card(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, CARD_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const contact = await contactOf(backend, company.id, args.positional[1]);
  const result = await crmCard(backend, { company_id: company.id, contact_id: contact.id });
  setResult(result);

  const who = (result['contact'] ?? {}) as Row;
  const organisation = result['organisation'] as Row | null;
  const theCard = result['card'] as Row | null;
  heading(`${text(who['name'])} ${dim(text(who['id']))}`);
  pairs([
    ['type', text(who['contact_type'])],
    ...(organisation === null || organisation === undefined ? [] : [['organisation', text(organisation['name'])] as [string, string]]),
    ['e-mail', text(who['email'])],
    ['country', text(who['country'])],
  ]);
  if (theCard === null || theCard === undefined) note(dim('No card yet: ekwo crm card set <contact> creates one.'));
  else {
    pairs([
      ['status', text(theCard['status'])],
      ['priority', text(theCard['priority'])],
      ['owner', text(theCard['owner'])],
      ['tags', Array.isArray(theCard['tags']) ? (theCard['tags'] as string[]).join(', ') : ''],
      ['no outbound', text(theCard['no_outbound'])],
      ['last activity', text(theCard['last_activity_at'])],
    ]);
  }
  const segmentsIn = (result['segments'] ?? []) as Row[];
  if (segmentsIn.length > 0) step(`segments: ${segmentsIn.map((s) => text(s['slug'])).join(', ')}`);
  const deals = (result['deals'] ?? []) as Row[];
  if (deals.length > 0) {
    line();
    table(
      [{ title: 'open deal' }, { title: 'stage' }, { title: 'amount', align: 'right' }, { title: 'currency' }, { title: 'expected' }, { title: 'id' }],
      deals.map((d) => [text(d['title']), text(d['stage']), text(d['amount']), text(d['currency_code']), text(d['expected_on']), dim(text(d['id']))]),
    );
  }
  const activities = (result['activities'] ?? []) as Row[];
  if (activities.length > 0) {
    line();
    table(
      [{ title: 'when' }, { title: 'kind' }, { title: 'subject' }],
      activities.map((a) => [text(a['occurred_at']), text(a['kind']), text(a['subject'])]),
    );
  }
  return 0;
}

async function cardSet(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, CARD_SET_FLAGS);
  const patch: Row = given({
    status: oneOf(CRM_RELATIONSHIP_STATUSES, stringFlag(args, 'status'), 'status'),
    priority: oneOf(CRM_PRIORITIES, stringFlag(args, 'priority'), 'priority'),
    owner: stringFlag(args, 'owner'),
    job_title: stringFlag(args, 'job-title'),
    linkedin_url: stringFlag(args, 'linkedin'),
    source: stringFlag(args, 'source'),
    no_outbound: optionalSwitch(args, 'no-outbound'),
  });
  const tags = stringFlags(args, 'tag');
  if (tags.length > 0) patch['tags'] = tags;
  const custom = stringFlag(args, 'custom');
  if (custom !== undefined) {
    let parsed: unknown;
    try {
      parsed = JSON.parse(custom);
    } catch {
      throw new UsageError('bad_custom: --custom is a JSON object, such as \'{"segment_size": "large"}\'.');
    }
    patch['custom'] = parsed;
  }
  if (Object.keys(patch).length === 0) {
    throw new UsageError(`missing_argument: nothing to set. ${USAGE}`);
  }
  const { backend, company } = await openBooks(args, deps);
  const contact = await contactOf(backend, company.id, args.positional[2]);
  const result = await crmUpsertCard(backend, { company_id: company.id, contact_id: contact.id, patch });
  setResult(result);

  heading('Card');
  step(`${contact.name} ${dim(contact.id)}: ${Object.keys(patch).join(', ')} set`);
  pairs([
    ['status', text(result.card['status'])],
    ['priority', text(result.card['priority'])],
    ['owner', text(result.card['owner'])],
  ]);
  return 0;
}

async function segments(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, SEGMENTS_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const result = await crmSegments(backend, { company_id: company.id });
  setResult(result);

  heading(`Segments of ${company.name}`);
  if (result.segments.length === 0) note(dim('None.'));
  else {
    table(
      [{ title: 'segment' }, { title: 'kind' }, { title: 'members', align: 'right' }, { title: 'id' }],
      result.segments.map((s) => [
        `${'  '.repeat(Number(s['depth'] ?? 0))}${text(s['name'])} ${dim(text(s['slug']))}`,
        text(s['kind']),
        text(s['members']),
        dim(text(s['id'])),
      ]),
    );
  }
  return 0;
}

async function board(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, BOARD_FLAGS);
  const wanted = args.positional[1];
  const pipelineId = wanted === undefined ? undefined : uuidArg(wanted, 'the pipeline');
  const { backend, company } = await openBooks(args, deps);
  const result = await crmBoard(backend, given({
    company_id: company.id,
    pipeline_id: pipelineId,
    include_closed: boolFlag(args, 'closed'),
  }));
  setResult(result);

  const pipelines = (result['pipelines'] ?? []) as Row[];
  if (pipelines.length === 0) {
    heading(`Pipelines of ${company.name}`);
    note(dim('None. A pipeline is created by the company; modules/crm/README.md shows a first one.'));
    return 0;
  }
  for (const pipeline of pipelines) {
    heading(`${text(pipeline['name'])} ${dim(text(pipeline['id']))}`);
    const rows: string[][] = [];
    for (const stage of (pipeline['stages'] ?? []) as Row[]) {
      const totals = ((stage['totals'] ?? []) as Row[]).map((t) => `${text(t['amount'])} ${text(t['currency_code'])}`).join(', ');
      rows.push([`${text(stage['position'])}. ${text(stage['name'])}`, text(stage['outcome']), text(stage['count']), totals, dim(text(stage['id']))]);
      for (const deal of (stage['deals'] ?? []) as Row[]) {
        const amount = deal['amount'] === null ? '' : `${text(deal['amount'])} ${text(deal['currency_code'])}`;
        rows.push([`   ${text(deal['title'])} — ${text(deal['contact_name'])}`, text(deal['expected_on']), '', amount, dim(text(deal['id']))]);
      }
    }
    table([{ title: 'stage / deal' }, { title: 'outcome / expected' }, { title: 'deals', align: 'right' }, { title: 'amount', align: 'right' }, { title: 'id' }], rows);
  }
  return 0;
}

async function timeline(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, TIMELINE_FLAGS);
  const deal = stringFlag(args, 'deal');
  const kinds = stringFlags(args, 'kind').map((kind) => oneOf(CRM_ACTIVITY_KINDS, kind, 'kind') as (typeof CRM_ACTIVITY_KINDS)[number]);
  const { backend, company } = await openBooks(args, deps);
  const contact = args.positional[1] === undefined && deal !== undefined
    ? undefined
    : await contactOf(backend, company.id, args.positional[1]);
  const result = await crmTimeline(backend, given({
    company_id: company.id,
    contact_id: contact?.id,
    deal_id: deal === undefined ? undefined : uuidArg(deal, '--deal'),
    since: stringFlag(args, 'since'),
    kinds: kinds.length === 0 ? undefined : kinds,
    limit: numberFlag(args, 'limit'),
  }));
  setResult(result);

  heading(`What happened${contact === undefined ? '' : ` with ${contact.name}`}`);
  if (result.activities.length === 0) note(dim('Nothing.'));
  else {
    table(
      [{ title: 'when' }, { title: 'kind' }, { title: 'subject' }, { title: 'actor' }],
      result.activities.map((a) => [text(a['occurred_at']), text(a['kind']), text(a['subject']), text(a['actor'])]),
    );
  }
  return 0;
}

async function log(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, LOG_FLAGS);
  const kind = oneOf(CRM_ACTIVITY_KINDS, required(stringFlag(args, 'kind'), 'what happened', `--kind ${KINDS}`), 'kind') as (typeof CRM_ACTIVITY_KINDS)[number];
  const deal = stringFlag(args, 'deal');
  const { backend, company } = await openBooks(args, deps);
  const contact = await contactOf(backend, company.id, args.positional[1]);
  const result = await crmLogActivity(backend, given({
    company_id: company.id,
    contact_id: contact.id,
    kind,
    subject: stringFlag(args, 'subject'),
    body: stringFlag(args, 'body'),
    deal_id: deal === undefined ? undefined : uuidArg(deal, '--deal'),
    actor: stringFlag(args, 'actor'),
    occurred_at: stringFlag(args, 'at'),
    link: stringFlag(args, 'link'),
    source: stringFlag(args, 'source'),
    source_ref: stringFlag(args, 'source-ref'),
  }));
  setResult(result);

  heading('Activity');
  step(`${text(result.activity['kind'])} with ${contact.name}, ${text(result.activity['occurred_at'])} ${dim(text(result.activity['id']))}`);
  return 0;
}

async function join(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, SEGMENT_FLAGS);
  const segmentId = uuidArg(args.positional[1], 'the segment');
  const { backend, company } = await openBooks(args, deps);
  const contact = await contactOf(backend, company.id, args.positional[2]);
  const result = await crmJoinSegment(backend, given({
    company_id: company.id,
    segment_id: segmentId,
    contact_id: contact.id,
    added_by: stringFlag(args, 'by'),
    note: stringFlag(args, 'note'),
  }));
  setResult(result);
  heading('Segment');
  step(`${contact.name} is in ${dim(segmentId)} since ${text(result.membership['joined_at'])}`);
  return 0;
}

async function leave(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, LEAVE_FLAGS);
  const segmentId = uuidArg(args.positional[1], 'the segment');
  const { backend, company } = await openBooks(args, deps);
  const contact = await contactOf(backend, company.id, args.positional[2]);
  const result = await crmLeaveSegment(backend, { company_id: company.id, segment_id: segmentId, contact_id: contact.id });
  setResult(result);
  heading('Segment');
  step(`${contact.name} left ${dim(segmentId)} on ${text(result.membership['left_at'])}; the membership is kept`);
  return 0;
}

async function dealOpen(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, DEAL_OPEN_FLAGS);
  const pipelineId = uuidArg(args.positional[2], 'the pipeline');
  const title = required(stringFlag(args, 'title'), 'the title of the deal', '--title <title>');
  const { backend, company } = await openBooks(args, deps);
  const contact = await contactOf(backend, company.id, args.positional[3]);
  const result = await crmOpenDeal(backend, given({
    company_id: company.id,
    pipeline_id: pipelineId,
    contact_id: contact.id,
    title,
    amount: stringFlag(args, 'amount'),
    currency_code: stringFlag(args, 'currency'),
    expected_on: stringFlag(args, 'expected'),
    external_url: stringFlag(args, 'url'),
    owner: stringFlag(args, 'owner'),
  }));
  setResult(result);
  heading('Deal');
  const amount = result.deal['amount'] === null ? '' : `, ${text(result.deal['amount'])} ${text(result.deal['currency_code'])}`;
  step(`${title} with ${contact.name}${amount} ${dim(text(result.deal['id']))}`);
  return 0;
}

async function dealMove(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, DEAL_MOVE_FLAGS);
  const dealId = uuidArg(args.positional[2], 'the deal');
  const stageId = uuidArg(args.positional[3], 'the stage');
  const { backend, company } = await openBooks(args, deps);
  const result = await crmMoveDeal(backend, { company_id: company.id, deal_id: dealId, stage_id: stageId });
  setResult(result);
  heading('Deal');
  const closed = result.deal['closed_outcome'];
  step(`${text(result.deal['title'])} is at ${dim(stageId)}${closed === null || closed === undefined ? '' : `, closed ${text(closed)}`}`);
  return 0;
}
