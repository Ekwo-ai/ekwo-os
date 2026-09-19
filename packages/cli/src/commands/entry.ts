/**
 * `ekwo reverse` — a posted entry undone by its mirror.
 *
 * `reverseEntry()` of the core is the MCP server's `reverse_entry`, which is
 * `reverse_entry()` of the schema: the mirror is written, posted and matched
 * against the original in the database. Which entries may be reversed and on
 * which day is the database's to say, and a refusal is left to `output.ts` to
 * repeat word for word. An entry a document wrote is undone with the document:
 * `ekwo cancel`.
 */

import { resolveEntry, reverseEntry } from '@ekwo-ai/core';
import { rejectUnknownFlags, stringFlag, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, openBooks, required, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, line, note } from '../ui.js';
import { printEntry } from './document.js';

type Row = Record<string, unknown>;

const REVERSE_FLAGS = [...BOOKS_FLAGS, 'date'] as const;

const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

export async function reverseCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  rejectUnknownFlags(args, REVERSE_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const entryId = await resolveEntry(backend, company.id, required(args.positional[0], 'the entry to reverse', '<entry>'));
  // No date given is not today: the database takes the entry's own day while
  // its period is open, and refuses by name when it is not.
  const date = stringFlag(args, 'date');

  const result = (await reverseEntry(backend, { entry_id: entryId, date })) as Row;
  setResult({ entry_id: entryId, ...result });

  heading(`Reversed, in ${company.name}`);
  printEntry(result);
  line();
  note(dim(text(result['note'])));
  return 0;
}
