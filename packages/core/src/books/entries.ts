/**
 * Entries: the one act a caller performs on an entry it did not write through
 * a document — undoing it.
 *
 * `reverse_entry` carries the rules — which entries may be reversed, on which
 * date, the mirror, its number, the matching of the two — and this file calls
 * it. Nothing here inserts an `entries` or an `entry_lines` row.
 */

import { BooksError, type Backend, type Row } from './backend.js';
import * as columns from './columns.js';
import { entryLinesWithAccounts } from './documents.js';
import { moneyFields } from './format.js';
import { only } from './shared.js';

export interface ReverseEntryArgs {
  entry_id: string;
  /** The day the reversal is booked on. Left out: the original's, while its period is open. */
  date?: string | undefined;
}

/**
 * Undoes a posted entry through `reverse_entry()`: the mirror is written,
 * posted and matched against it in the database, in one statement. What comes
 * back is the reversal and its lines, read afterwards.
 */
export async function reverseEntry(backend: Backend, args: ReverseEntryArgs): Promise<unknown> {
  const reversal = only(
    await backend.rpc<Row>('reverse_entry', {
      p_entry_id: args.entry_id,
      ...(args.date === undefined ? {} : { p_date: args.date }),
    }),
    `entry ${args.entry_id} produced no reversal`,
  );
  const entry = only(
    moneyFields(
      await backend.select<Row>({
        table: 'entries',
        columns: [...columns.ENTRY, 'reversed_entry_id'],
        where: [{ column: 'id', op: 'eq', value: reversal['id'] as string }],
      }),
      ['total_debit', 'total_credit'],
    ),
    `the reversal of entry ${args.entry_id}`,
  );
  return {
    entry,
    entry_lines: await entryLinesWithAccounts(backend, entry['id'] as string),
    note: 'The reversal is posted, names the entry it undoes, and the two are matched. The original keeps its number and its lines: nothing posted is deleted.',
  };
}

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** The entry a person means: its id, or its number, which is unique in a company. */
export async function resolveEntry(backend: Backend, company: string, wanted: string): Promise<string> {
  if (UUID.test(wanted)) return wanted.toLowerCase();
  const found = await backend.select<{ id: string }>({
    table: 'entries',
    columns: ['id'],
    where: [
      { column: 'company_id', op: 'eq', value: company },
      { column: 'number', op: 'eq', value: wanted },
    ],
    limit: 1,
  });
  if (found[0] !== undefined) return found[0].id;
  throw new BooksError(`unknown_entry: no entry of this company has the number ${wanted}.`);
}
