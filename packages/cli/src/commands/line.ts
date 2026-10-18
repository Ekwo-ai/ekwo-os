/**
 * `ekwo line …` — the open lines of the receivable and payable accounts.
 *
 * `contacts suggest` and `contact set`: who a line that names nobody could be,
 * and naming it (decision 0070); `unnamed leave` and `unnamed undo`: leaving
 * it without a contact on purpose (decision 0072); `combinations suggest`,
 * `match` and `differences list`: what settles what, several lines matched in
 * one gesture, and a small difference booked with its reason (decision 0071).
 *
 * Each verb is a function of the core, which is the MCP tool of the same
 * name, which is the schema's function. The scores, the search, the accounts
 * and the refusals are the database's; a refusal is left to `output.ts` to
 * repeat word for word.
 */

import {
  leaveLineUnnamed,
  matchingDifferenceOptions,
  reconcileMany,
  reconcileWithDifference,
  resolveContact,
  setLineContact,
  suggestItemCombinations,
  suggestLineContacts,
  undoLeaveLineUnnamed,
} from '@ekwo-ai/core';
import { UsageError, rejectUnknownFlags, stringFlag, stringFlags, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, openBooks, uuidArg, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, line as print, note, pairs, step, table } from '../ui.js';

type Row = Record<string, unknown>;

const SUGGEST_FLAGS = [...BOOKS_FLAGS, 'line'] as const;
const SET_FLAGS = [...BOOKS_FLAGS] as const;
const COMBINATIONS_FLAGS = [...BOOKS_FLAGS, 'contact'] as const;
const MATCH_FLAGS = [...BOOKS_FLAGS, 'difference'] as const;
const LEAVE_FLAGS = [...BOOKS_FLAGS, 'reason'] as const;

const USAGE =
  'usage: ekwo line contacts suggest [--line <line>…] | ekwo line contact set <line> <contact> | ' +
  'ekwo line unnamed leave <line> --reason <text> | ekwo line unnamed undo <line> | ' +
  'ekwo line combinations suggest [--contact <contact>] | ekwo line match <line> <line>… [--difference <reason>] | ' +
  'ekwo line differences list';

const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

export async function lineCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  const [noun, verb] = args.positional;
  if (noun === 'contacts' && verb === 'suggest') return suggest(args, deps);
  if (noun === 'contact' && verb === 'set') return set(args, deps);
  if (noun === 'unnamed' && verb === 'leave') return leave(args, deps);
  if (noun === 'unnamed' && verb === 'undo') return undoLeave(args, deps);
  if (noun === 'combinations' && verb === 'suggest') return combinations(args, deps);
  if (noun === 'differences' && verb === 'list') return differences(args, deps);
  if (noun === 'match') return match(args, deps);
  throw new UsageError(USAGE);
}

async function suggest(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, SUGGEST_FLAGS);
  const lineIds = stringFlags(args, 'line').map((id) => uuidArg(id, 'the line'));
  const { backend, company } = await openBooks(args, deps);

  const result = (await suggestLineContacts(backend, {
    company_id: company.id,
    ...(lineIds.length === 0 ? {} : { line_ids: lineIds }),
  })) as { lines: Row[]; count: number; note: string };
  setResult(result);

  heading(`Lines that name nobody, in ${company.name}`);
  if (result.lines.length === 0) {
    note(dim('None that the evidence points at.'));
    return 0;
  }
  for (const found of result.lines) {
    print();
    step(`${text(found['label']) || dim('(no label)')}  ${text(found['amount'])} ${text(found['side'])}  ${dim(text(found['line_id']))}`);
    const candidates = (found['candidates'] ?? []) as Row[];
    table(
      [{ title: 'contact' }, { title: 'score' }, { title: 'method' }, { title: 'alternatives' }, { title: 'because' }],
      candidates.map((c) => [
        text(c['name']),
        text(c['score']),
        text(c['method']),
        text(c['alternatives']),
        dim(text(c['because'])),
      ]),
    );
  }
  print();
  note(dim(result.note));
  return 0;
}

async function set(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, SET_FLAGS);
  const lineId = uuidArg(args.positional[2], 'the line');
  const wanted = args.positional[3];
  if (wanted === undefined) throw new UsageError(`missing_argument: the contact was not given. ${USAGE}`);
  const { backend, company } = await openBooks(args, deps);
  const contact = await resolveContact(backend, company.id, wanted);

  const result = (await setLineContact(backend, { line_id: lineId, contact_id: contact.id })) as {
    entry_line: Row;
    note: string;
  };
  setResult(result);

  heading(`Line named, in ${company.name}`);
  pairs([
    ['line', `${text(result.entry_line['name'])}  ${dim(lineId)}`],
    ['contact', `${contact.name}  ${dim(contact.id)}`],
  ]);
  note(dim(result.note));
  return 0;
}

async function leave(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, LEAVE_FLAGS);
  const lineId = uuidArg(args.positional[2], 'the line');
  const reason = stringFlag(args, 'reason');
  if (reason === undefined) throw new UsageError(`missing_argument: --reason says why the line names nobody. ${USAGE}`);
  const { backend, company } = await openBooks(args, deps);

  const result = (await leaveLineUnnamed(backend, { line_id: lineId, reason })) as { left_unnamed: Row; note: string };
  setResult(result);
  heading(`Line left unnamed, in ${company.name}`);
  pairs([
    ['line', dim(lineId)],
    ['reason', text(result.left_unnamed['reason'])],
  ]);
  note(dim(result.note));
  return 0;
}

async function undoLeave(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, SET_FLAGS);
  const lineId = uuidArg(args.positional[2], 'the line');
  const { backend, company } = await openBooks(args, deps);

  const result = (await undoLeaveLineUnnamed(backend, { line_id: lineId })) as { removed: Row; note: string };
  setResult(result);
  heading(`Line proposed a contact again, in ${company.name}`);
  pairs([['line', dim(lineId)]]);
  note(dim(result.note));
  return 0;
}

async function combinations(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, COMBINATIONS_FLAGS);
  const wanted = stringFlag(args, 'contact');
  const { backend, company } = await openBooks(args, deps);
  const contact = wanted === undefined ? undefined : await resolveContact(backend, company.id, wanted);

  const result = (await suggestItemCombinations(backend, {
    company_id: company.id,
    ...(contact === undefined ? {} : { contact_id: contact.id }),
  })) as { proposals: Row[]; count: number; note: string };
  setResult(result);

  heading(`Open items that settle each other, in ${company.name}`);
  if (result.proposals.length === 0) {
    note(dim('No proposal.'));
    return 0;
  }
  table(
    [{ title: 'line' }, { title: 'amount' }, { title: 'kind' }, { title: 'lines' }, { title: 'total' }, { title: 'difference' }, { title: 'because' }],
    result.proposals.map((p) => [
      dim(text(p['line_id'])),
      `${text(p['amount'])} ${text(p['side'])}`,
      text(p['kind']),
      String(((p['line_ids'] as unknown[] | undefined) ?? []).length),
      text(p['total']),
      text(p['difference']),
      dim(text(p['because'])),
    ]),
  );
  print();
  note(dim(result.note));
  return 0;
}

async function match(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, MATCH_FLAGS);
  const lineIds = args.positional.slice(1).map((id) => uuidArg(id, 'a line'));
  if (lineIds.length < 2) throw new UsageError(`missing_argument: a matching names at least two lines. ${USAGE}`);
  const reason = stringFlag(args, 'difference');
  const { backend, company } = await openBooks(args, deps);

  const result = (
    reason === undefined
      ? await reconcileMany(backend, { line_ids: lineIds })
      : await reconcileWithDifference(backend, { line_ids: lineIds, reason })
  ) as { matching: Row; note: string };
  setResult(result);

  heading(`Lines matched, in ${company.name}`);
  pairs([
    ['letter', text(result.matching['matching_number'])],
    ['amount', text(result.matching['amount'])],
    ['difference', text(result.matching['difference'])],
    ...(result.matching['adjustment_entry_id'] ? [['difference entry', dim(text(result.matching['adjustment_entry_id']))] as [string, string]] : []),
  ]);
  note(dim(result.note));
  return 0;
}

async function differences(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, SET_FLAGS);
  const { backend, company } = await openBooks(args, deps);

  const result = (await matchingDifferenceOptions(backend, { company_id: company.id })) as {
    tolerance: { units: number; amount: string; currency_code: string } | null;
    reasons: Row[];
    note: string;
  };
  setResult(result);

  heading(`Differences a matching may book, in ${company.name}`);
  if (result.tolerance !== null) {
    pairs([['at most', `${result.tolerance.amount} ${result.tolerance.currency_code} (${result.tolerance.units} units)`]]);
  }
  table(
    [{ title: 'reason' }, { title: 'side' }, { title: 'account' }, { title: 'available' }, { title: 'because' }],
    result.reasons.map((r) => [
      text(r['reason']),
      text(r['side']),
      text(r['account_code']),
      text(r['available']),
      dim(text(r['because'])),
    ]),
  );
  note(dim(result.note));
  return 0;
}
