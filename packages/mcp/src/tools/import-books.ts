/**
 * The MCP tool `import_books`, and the sources it names.
 *
 * The readers are named after the file they read; a user looks for the
 * software the file came from. So besides the formats, the tool accepts the
 * name of the software whose export a reader was written against, and says
 * which export that is. A name is listed here only once its reader exists and
 * is tested, and the text says what is read — nothing else about the software.
 * `docs/compatibility.md` is the same list, for a person.
 */

import { BOOK_SOURCES, BOOK_SOURCE_DESCRIPTIONS, BooksError, NO_JOURNAL, OPENING, importBooks, type BookSource } from '@ekwo-ai/core';
import { z } from 'zod';
import type { Backend } from '../backend.js';
import { companyId, isoDate } from './read.js';

/** The software whose export a reader reads, by the name a user types. */
export const NAMED_SOURCES = {
  odoo: {
    reader: 'journal-items',
    export: 'the export of the Journal Items of Odoo (Accounting), as CSV, with its chart of accounts and its partners',
  },
  xero: {
    reader: 'journal-report',
    export: 'the Journal Report or the General Ledger Detail of Xero, saved as CSV, with its chart of accounts and its contacts',
  },
} as const satisfies Record<string, { reader: BookSource; export: string }>;

export const NAMED_SOURCE_KEYS = Object.keys(NAMED_SOURCES) as (keyof typeof NAMED_SOURCES)[];

/** The reader a source names: itself, or the one the software's export is read by. */
export function sourceOf(source: BookSource | keyof typeof NAMED_SOURCES): BookSource {
  return source in NAMED_SOURCES ? NAMED_SOURCES[source as keyof typeof NAMED_SOURCES].reader : (source as BookSource);
}

/**
 * The most text the tool takes, all files together, in KiB. The files travel
 * inside the conversation, and a model that has to repeat three megabytes of
 * CSV in a tool call truncates them or runs out of room long before the
 * database sees a line. The command line reads the same export from the disk,
 * through the same function, without a limit.
 */
export const MAX_TEXT_KIB = 256;

export const IMPORT_BOOKS_DESCRIPTION =
  "Takes over the books a user kept elsewhere — a FEC, an export of journal items, a journal report, a trial balance, or the export of " +
  NAMED_SOURCE_KEYS.join(' or ') +
  " by name — whole or not at all. Each file is read by the reader of its source; every account of the old chart is matched to one of this company's chart and every old journal to a journal of the company. The codes give a candidate (the same code, the same digits without the padding zeros, or the longest beginning of three digits or more), and what the files say of the old account — its type, its name, the side of its balance — is held against what the chart says the candidate is, never a country: only the same code, not contradicted, is `exact`; anything else is `suggested` with its reason, or `none`. Call it with dry_run first: it returns the correspondence proposed, the suggestions under mapping.suggested, what is unanswered, and — when everything is answered — what the database would write, rehearsed and rolled back. Show the user every suggested line and its reason first; nothing is posted while one is unconfirmed. Settle each by writing its code under mapping.accounts, or, once the user has read and approved them all, pass accept_suggestions. Every entry is posted through post_entry(); a trial balance becomes the opening entry. Imported lines carry no tax and feed no VAT box. The same files twice are refused. The files travel as text, up to " + MAX_TEXT_KIB + " KiB in all: a larger export is imported from the terminal with `ekwo import`, which reads it from the disk. Ask the user before the real call.";

export const ImportBooksInput = z.object({
  company_id: companyId,
  source: z
    .enum([...BOOK_SOURCES, ...NAMED_SOURCE_KEYS])
    .describe(
      'What the files are, never guessed from their content: ' +
        BOOK_SOURCES.map((source) => `\`${source}\` — ${BOOK_SOURCE_DESCRIPTIONS[source]}`).join('; ') +
        '. By the software that wrote them: ' +
        NAMED_SOURCE_KEYS.map((name) => `\`${name}\` reads ${NAMED_SOURCES[name].export} (the same as \`${NAMED_SOURCES[name].reader}\`)`).join('; ') +
        '. A bank statement is not books: it goes through import_bank_statement.',
    ),
  files: z
    .array(
      z.object({
        name: z.string().min(1).describe('The name the file had, kept on the record of the import.'),
        content: z.string().min(1).describe('The file itself, as text (UTF-8).'),
      }),
    )
    .min(1)
    .describe('The files of one source, in the order given. `journal-items` and `journal-report` take the chart of accounts and the parties beside the lines, each recognised by its header; the others take one file.'),
  mapping: z
    .object({
      accounts: z.record(z.string(), z.string().nullable()).optional().describe('Old account code → code of this company\'s chart.'),
      journals: z
        .record(z.string(), z.string().nullable())
        .optional()
        .describe(`Old journal → code of a journal of this company, or \`${OPENING}\` for the entries that are the opening balance. \`${NO_JOURNAL}\` stands for entries the source gives no journal.`),
    })
    .optional()
    .describe('The correspondence, as a previous call with dry_run returned it and the user completed it. What it answers wins over the proposal.'),
  dry_run: z.boolean().optional().describe('Show what would be written — the correspondence proposed, the entries, the numbers — and write nothing. Always first, and the user reads it before the real call.'),
  open_years: z.boolean().optional().describe('Open the fiscal years the entries fall in where the company has none, on the length and first day of its own. Off, such an entry is refused by name.'),
  opening_date: isoDate.optional().describe('For a trial balance: the first day of the fiscal year it opens. The file does not say it.'),
  allow_result_accounts: z.boolean().optional().describe('Let an opening balance carry income and expense accounts: books taken over in the middle of a year.'),
  keep_numbers: z.boolean().optional().describe('Post each entry under the number it had. Where the country forbids a hole in the sequence it takes the entries.import capability; left out, the journal draws the numbers and the old one is kept as the reference.'),
  date_order: z.enum(['dmy', 'mdy', 'ymd']).optional().describe('For `journal-report`: the order of a date written only in digits, which the file does not say.'),
  accept_suggestions: z
    .boolean()
    .optional()
    .describe('Take every account the proposal only suggested as the answer. Only after the user has read each suggested line and its reason, and said yes to all of them; left out, a suggestion stops the import.'),
});

/**
 * Books from another system, all of them or none, through `importBooks()` of
 * the core — the function `ekwo import` calls.
 */
export async function importBooksTool(
  backend: Backend,
  args: z.infer<typeof ImportBooksInput>,
): Promise<unknown> {
  const bytes = args.files.reduce((sum, file) => sum + Buffer.byteLength(file.content, 'utf8'), 0);
  if (bytes > MAX_TEXT_KIB * 1024) {
    throw new BooksError(
      `files_too_large: ${Math.ceil(bytes / 1024)} KiB of text, and this tool takes ${MAX_TEXT_KIB} KiB at most. Import it from the terminal, which reads the files from the disk and runs the same import: ${cliEquivalent(args)}`,
      {
        hint:
          'Sign in once with `npx -y ekwo-os@latest login`, and run it where the files are. ' +
          (args.mapping === undefined ? '' : 'Save the correspondence of this call as correspondence.json beside them first. ') +
          'The rehearsal, the correspondence and the refusals are the ones this tool gives; drop --dry-run for the real import.',
      },
    );
  }
  return importBooks(backend, {
    company_id: args.company_id,
    source: sourceOf(args.source),
    files: args.files,
    mapping: args.mapping,
    dry_run: args.dry_run,
    open_years: args.open_years,
    opening_date: args.opening_date,
    allow_result_accounts: args.allow_result_accounts,
    keep_numbers: args.keep_numbers,
    date_order: args.date_order,
    accept_suggestions: args.accept_suggestions,
  });
}

/** The `ekwo import` command that does what this call asked, from files on the disk. */
export function cliEquivalent(args: z.infer<typeof ImportBooksInput>): string {
  const quote = (value: string): string => (/^[\w@%+=:,./-]+$/.test(value) ? value : `'${value.replaceAll("'", "'\\''")}'`);
  return [
    'npx -y ekwo-os@latest import',
    args.source,
    ...args.files.map((file) => quote(file.name)),
    '--company',
    args.company_id,
    '--dry-run',
    ...(args.open_years === true ? ['--open-years'] : []),
    ...(args.opening_date === undefined ? [] : ['--opening-date', args.opening_date]),
    ...(args.allow_result_accounts === true ? ['--allow-result-accounts'] : []),
    ...(args.keep_numbers === true ? ['--keep-numbers'] : []),
    ...(args.date_order === undefined ? [] : ['--date-order', args.date_order]),
    ...(args.mapping === undefined ? ['--save-mapping', 'correspondence.json'] : ['--mapping', 'correspondence.json']),
  ].join(' ');
}
