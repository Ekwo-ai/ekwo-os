/**
 * `ekwo line contacts suggest` and `ekwo line contact set` — who an open line
 * on a receivable or payable account that names nobody could be, and naming
 * it (decision 0070).
 *
 * `suggestLineContacts()` and `setLineContact()` of the core, which are the
 * MCP server's `suggest_line_contacts` and `set_line_contact`, which are the
 * schema's functions of the same names. The scores, the evidence and the
 * refusals are the database's; a refusal is left to `output.ts` to repeat
 * word for word.
 */

import { resolveContact, setLineContact, suggestLineContacts } from '@ekwo-ai/core';
import { UsageError, rejectUnknownFlags, stringFlags, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, openBooks, uuidArg, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, line as print, note, pairs, step, table } from '../ui.js';

type Row = Record<string, unknown>;

const SUGGEST_FLAGS = [...BOOKS_FLAGS, 'line'] as const;
const SET_FLAGS = [...BOOKS_FLAGS] as const;

const USAGE =
  'usage: ekwo line contacts suggest [--line <line>…] | ekwo line contact set <line> <contact>';

const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

export async function lineCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  const [noun, verb] = args.positional;
  if (noun === 'contacts' && verb === 'suggest') return suggest(args, deps);
  if (noun === 'contact' && verb === 'set') return set(args, deps);
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
