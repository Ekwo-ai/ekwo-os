/**
 * The `crm` module, for every surface.
 *
 * Each verb is one function of the `crm` schema, called here once, so the MCP
 * server's `crm_*` tools and `ekwo crm …` run the very same thing. Nothing is
 * decided in this file: which statuses, kinds and outcomes exist, what a patch
 * may name, what a won deal does — the schema holds all of it, and refuses by
 * name (`crm_<code>: …`). What is here is the call, the arguments in the names
 * the functions take, and amounts read back as the decimal strings Postgres
 * holds.
 */

import { BooksError, type Backend, type Row } from '../books/backend.js';
import { amountIn, money } from '../books/format.js';

/** The schema the module lives in, and the code of `public.modules`. */
export const CRM_SCHEMA = 'crm';

/** The keys `crm.upsert_card()` accepts in its patch. The function refuses any other, by name. */
export interface CrmCardPatch {
  status?: string;
  priority?: string;
  owner?: string | null;
  job_title?: string | null;
  linkedin_url?: string | null;
  source?: string | null;
  tags?: string[];
  no_outbound?: boolean;
  custom?: Record<string, unknown>;
}

export interface CrmSearchArgs {
  company_id: string;
  query?: string | undefined;
  /** A `crm.relationship_status`; the database refuses one it does not have. */
  status?: string | undefined;
  segment_id?: string | undefined;
  stage_id?: string | undefined;
  country?: string | undefined;
  language?: string | undefined;
  owner?: string | undefined;
  no_outbound?: boolean | undefined;
  active_since?: string | undefined;
  inactive_since?: string | undefined;
  limit?: number | undefined;
}

export interface CrmTimelineArgs {
  company_id: string;
  contact_id?: string | undefined;
  deal_id?: string | undefined;
  since?: string | undefined;
  /** `crm.activity_kind` values; the database refuses one it does not have. */
  kinds?: string[] | undefined;
  limit?: number | undefined;
}

export interface CrmLogActivityArgs {
  company_id: string;
  contact_id: string;
  /** A `crm.activity_kind`. */
  kind: string;
  subject?: string | undefined;
  body?: string | undefined;
  deal_id?: string | undefined;
  actor?: string | undefined;
  occurred_at?: string | undefined;
  link?: string | undefined;
  payload?: Record<string, unknown> | undefined;
  source?: string | undefined;
  source_ref?: string | undefined;
}

export interface CrmOpenDealArgs {
  company_id: string;
  pipeline_id: string;
  contact_id: string;
  title: string;
  amount?: string | number | undefined;
  /** Left out, `crm.open_deal()` takes the company's own currency. */
  currency_code?: string | undefined;
  expected_on?: string | undefined;
  external_url?: string | undefined;
  owner?: string | undefined;
}

const orNull = <T>(value: T | undefined): T | null => (value === undefined ? null : value);

async function call(backend: Backend, fn: string, args: Record<string, unknown>): Promise<Row[]> {
  return backend.rpc<Row>(fn, args, CRM_SCHEMA);
}

async function callOne(backend: Backend, fn: string, args: Record<string, unknown>): Promise<Row> {
  const [row] = await call(backend, fn, args);
  if (row === undefined || row === null) throw new BooksError(`crm_no_answer: ${CRM_SCHEMA}.${fn} answered nothing`);
  return row;
}

/** A deal as the table holds it, its amount a decimal string. */
function deal(row: Row): Row {
  return { ...row, amount: money(row['amount']) };
}

/** `crm.search_cards()`: the cards of a company, every filter optional. */
export async function crmSearch(backend: Backend, args: CrmSearchArgs): Promise<{ cards: Row[]; count: number }> {
  const cards = await call(backend, 'search_cards', {
    p_company_id: args.company_id,
    p_query: orNull(args.query),
    p_status: orNull(args.status),
    p_segment_id: orNull(args.segment_id),
    p_stage_id: orNull(args.stage_id),
    p_country: orNull(args.country),
    p_language: orNull(args.language),
    p_owner: orNull(args.owner),
    p_no_outbound: orNull(args.no_outbound),
    p_active_since: orNull(args.active_since),
    p_inactive_since: orNull(args.inactive_since),
    p_limit: args.limit ?? 50,
  });
  return { cards, count: cards.length };
}

/** `crm.card_of()`: one contact as one object, exactly as the function builds it. */
export async function crmCard(backend: Backend, args: { company_id: string; contact_id: string }): Promise<Row> {
  return callOne(backend, 'card_of', { p_company_id: args.company_id, p_contact_id: args.contact_id });
}

/** `crm.segment_tree()`: every segment, in tree order, with its members now. */
export async function crmSegments(backend: Backend, args: { company_id: string }): Promise<{ segments: Row[]; count: number }> {
  const segments = await call(backend, 'segment_tree', { p_company_id: args.company_id });
  return { segments, count: segments.length };
}

/** `crm.board()`: one pipeline, or all of them, stage by stage. */
export async function crmBoard(
  backend: Backend,
  args: { company_id: string; pipeline_id?: string | undefined; include_closed?: boolean | undefined },
): Promise<Row> {
  return callOne(backend, 'board', {
    p_company_id: args.company_id,
    p_pipeline_id: orNull(args.pipeline_id),
    p_include_closed: args.include_closed ?? false,
  });
}

/** `crm.timeline()`: the activities of a contact or of a deal, latest first. */
export async function crmTimeline(backend: Backend, args: CrmTimelineArgs): Promise<{ activities: Row[]; count: number }> {
  const activities = await call(backend, 'timeline', {
    p_company_id: args.company_id,
    p_contact_id: orNull(args.contact_id),
    p_deal_id: orNull(args.deal_id),
    p_since: orNull(args.since),
    p_kinds: orNull(args.kinds),
    p_limit: args.limit ?? 50,
  });
  return { activities, count: activities.length };
}

/** `crm.upsert_card()`: the card created, or changed field by field. */
export async function crmUpsertCard(
  backend: Backend,
  args: { company_id: string; contact_id: string; patch: CrmCardPatch | Record<string, unknown> },
): Promise<{ card: Row }> {
  const card = await callOne(backend, 'upsert_card', {
    p_company_id: args.company_id,
    p_contact_id: args.contact_id,
    p_patch: args.patch,
  });
  return { card };
}

/** `crm.log_activity()`: one activity, written once per `(source, source_ref)`. */
export async function crmLogActivity(backend: Backend, args: CrmLogActivityArgs): Promise<{ activity: Row }> {
  const activity = await callOne(backend, 'log_activity', {
    p_company_id: args.company_id,
    p_contact_id: args.contact_id,
    p_kind: args.kind,
    p_subject: orNull(args.subject),
    p_body: orNull(args.body),
    p_deal_id: orNull(args.deal_id),
    p_actor: orNull(args.actor),
    p_occurred_at: orNull(args.occurred_at),
    p_link: orNull(args.link),
    p_payload: orNull(args.payload),
    p_source: orNull(args.source),
    p_source_ref: orNull(args.source_ref),
  });
  return { activity };
}

/** `crm.join_segment()`: in, or back in, with the membership remembered. */
export async function crmJoinSegment(
  backend: Backend,
  args: { company_id: string; segment_id: string; contact_id: string; added_by?: string | undefined; note?: string | undefined },
): Promise<{ membership: Row }> {
  const membership = await callOne(backend, 'join_segment', {
    p_company_id: args.company_id,
    p_segment_id: args.segment_id,
    p_contact_id: args.contact_id,
    p_added_by: orNull(args.added_by),
    p_note: orNull(args.note),
  });
  return { membership };
}

/** `crm.leave_segment()`: out, the membership kept with the day it ended. */
export async function crmLeaveSegment(
  backend: Backend,
  args: { company_id: string; segment_id: string; contact_id: string },
): Promise<{ membership: Row }> {
  const membership = await callOne(backend, 'leave_segment', {
    p_company_id: args.company_id,
    p_segment_id: args.segment_id,
    p_contact_id: args.contact_id,
  });
  return { membership };
}

/** `crm.open_deal()`: a deal at the first open stage of its pipeline. */
export async function crmOpenDeal(backend: Backend, args: CrmOpenDealArgs): Promise<{ deal: Row }> {
  const row = await callOne(backend, 'open_deal', {
    p_company_id: args.company_id,
    p_pipeline_id: args.pipeline_id,
    p_contact_id: args.contact_id,
    p_title: args.title,
    p_amount: args.amount === undefined ? null : amountIn(args.amount),
    p_currency_code: orNull(args.currency_code),
    p_expected_on: orNull(args.expected_on),
    p_external_url: orNull(args.external_url),
    p_owner: orNull(args.owner),
  });
  return { deal: deal(row) };
}

/** `crm.move_deal()`: to another stage; a won or lost one closes it. */
export async function crmMoveDeal(
  backend: Backend,
  args: { company_id: string; deal_id: string; stage_id: string },
): Promise<{ deal: Row }> {
  const row = await callOne(backend, 'move_deal', {
    p_company_id: args.company_id,
    p_deal_id: args.deal_id,
    p_stage_id: args.stage_id,
  });
  return { deal: deal(row) };
}
