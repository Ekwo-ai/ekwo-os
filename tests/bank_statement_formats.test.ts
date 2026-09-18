import { describe, expect, it } from 'vitest';
import { writeTools } from '../packages/mcp/src/index.js';
import { allPacks } from './helpers/packs.js';

/**
 * A pack names the statement formats the banks of its country send. Until the
 * first reader was written every one of those names pointed at nothing, and
 * only a comment on the column said so: a client offering an import from that
 * list would have offered eight formats and read none.
 *
 * This is the ledger of that debt. A format a pack names is either **read** —
 * `import_bank_statement` takes it — or **owed**, by name, below. A pack that
 * names a new one fails here until somebody writes the reader or writes the
 * debt down; a reader that ships fails here until its line is struck off.
 *
 * What it is not: the `pack check` guard that would tell a pack author the
 * same thing at the keyboard. That belongs to the command line and is not
 * written yet.
 */

const READ: readonly string[] = writeTools.STATEMENT_FORMATS;

/** Named by a pack, read by nothing. Each is a brick to write. */
const OWED = ['bai2', 'camt.052', 'csv', 'mt940', 'ofx'];

const named = [...new Set(allPacks.flatMap((pack) => pack.documents.bank_statement_formats))].sort();

describe('the statement formats the packs name', () => {
  it('are each read, or owed by name', () => {
    const unaccounted = named.filter((format) => !READ.includes(format) && !OWED.includes(format));
    expect(unaccounted).toEqual([]);
  });

  it('owe nothing that is read, and nothing no pack names', () => {
    expect(OWED.filter((format) => READ.includes(format))).toEqual([]);
    expect(OWED.filter((format) => !named.includes(format))).toEqual([]);
  });

  it('read nothing no pack names: a reader exists because a bank sends the file', () => {
    expect(READ.filter((format) => !named.includes(format))).toEqual([]);
  });
});
