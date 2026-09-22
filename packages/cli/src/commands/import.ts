/**
 * `ekwo import <source> <files…>` — books or statements from elsewhere.
 *
 * One command for every source, and a source is a reader of
 * `packages/formats/`: `importBooks()` of the core for books — the MCP
 * server's `import_books` — and `importStatementFile()` for a bank statement —
 * its `import_bank_statement`. This file reads the files from the disk, reads
 * and writes the correspondence the user keeps beside them, and prints what
 * came back. Which account a code becomes is proposed by the core and decided
 * by the user; what is written, and whether it may be, is the database's.
 */

import { readFile, writeFile } from 'node:fs/promises';
import { basename } from 'node:path';
import {
  BOOK_SOURCES,
  STATEMENT_FORMATS,
  importBooks,
  describeStatementFile,
  importStatementFile,
  type BookSource,
  type ImportMapping,
  type StatementFormat,
} from '@ekwo-ai/core';
import { UsageError, boolFlag, rejectUnknownFlags, stringFlag, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, openBooks, uuidArg, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, line, note, pairs, step, table, warn } from '../ui.js';

type Row = Record<string, unknown>;

const IMPORT_FLAGS = [
  ...BOOKS_FLAGS,
  'dry-run',
  'mapping',
  'save-mapping',
  'open-years',
  'opening-date',
  'allow-result-accounts',
  'keep-numbers',
  'encoding',
  'date-order',
  'bank-account',
  'iban-country',
] as const;

const ENCODINGS = ['utf-8', 'iso-8859-1', 'iso-8859-15'] as const;
const DATE_ORDERS = ['dmy', 'mdy', 'ymd'] as const;

const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

/**
 * The software whose export a reader reads, by the name a user types. The
 * readers are named after the file; a user looks for where it came from. A
 * name is listed only once its reader exists and is tested, and it says what
 * is read and nothing else. The MCP tool carries the same list
 * (`packages/mcp/src/tools/import-books.ts`), and a test keeps the two equal;
 * `docs/compatibility.md` is the same list for a person.
 */
export const NAMED_SOURCES = {
  odoo: { reader: 'journal-items', export: 'the export of the Journal Items of Odoo (Accounting), as CSV, with its chart of accounts and its partners' },
  xero: { reader: 'journal-report', export: 'the Journal Report or the General Ledger Detail of Xero, saved as CSV, with its chart of accounts and its contacts' },
} as const satisfies Record<string, { reader: BookSource; export: string }>;

export const IMPORT_USAGE = `usage: ekwo import <source> <file>… [--dry-run] [--mapping <file>] [--save-mapping <file>]
  books:      ${BOOK_SOURCES.join(', ')}
  by name:    ${Object.entries(NAMED_SOURCES).map(([name, { reader }]) => `${name} (= ${reader})`).join(', ')}
  statements: ${STATEMENT_FORMATS.join(', ')}
${Object.entries(NAMED_SOURCES).map(([name, { export: what }]) => `  ${name}: reads ${what}.`).join('\n')}
See docs/compatibility.md.`;

export async function importCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  rejectUnknownFlags(args, IMPORT_FLAGS);
  const [source, ...paths] = args.positional;
  if (source === undefined) throw new UsageError(IMPORT_USAGE);
  if (paths.length === 0) throw new UsageError(`missing_argument: the files to import.\n${IMPORT_USAGE}`);

  if ((STATEMENT_FORMATS as readonly string[]).includes(source)) {
    return importStatements(args, deps, source as StatementFormat, paths);
  }
  const named = NAMED_SOURCES[source as keyof typeof NAMED_SOURCES]?.reader;
  if (named !== undefined) return importBookFiles(args, deps, named, paths);
  if (!(BOOK_SOURCES as readonly string[]).includes(source)) {
    throw new UsageError(`unknown_source: ${source}.\n${IMPORT_USAGE}`);
  }
  return importBookFiles(args, deps, source as BookSource, paths);
}

async function importBookFiles(args: ParsedArgs, deps: BooksDeps, source: BookSource, paths: string[]): Promise<number> {
  for (const flag of ['bank-account', 'iban-country']) {
    if (args.flags.has(flag)) throw new UsageError(`bad_flag: --${flag} is for a bank statement, and ${source} is books.`);
  }
  const encoding = oneOf(stringFlag(args, 'encoding'), ENCODINGS, '--encoding');
  const dateOrder = oneOf(stringFlag(args, 'date-order'), DATE_ORDERS, '--date-order');
  const mappingPath = stringFlag(args, 'mapping');
  const savePath = stringFlag(args, 'save-mapping');
  const mapping = mappingPath === undefined ? undefined : await readMapping(mappingPath);
  const files = await Promise.all(paths.map(async (path) => ({ name: basename(path), content: new Uint8Array(await readFile(path)) })));
  const dryRun = boolFlag(args, 'dry-run');

  const { backend, company } = await openBooks(args, deps);
  const result = (await importBooks(backend, {
    company_id: company.id,
    source,
    files,
    mapping,
    dry_run: dryRun,
    open_years: boolFlag(args, 'open-years'),
    opening_date: stringFlag(args, 'opening-date'),
    allow_result_accounts: boolFlag(args, 'allow-result-accounts'),
    keep_numbers: boolFlag(args, 'keep-numbers'),
    encoding,
    date_order: dateOrder,
  })) as Row;

  if (savePath !== undefined) {
    await writeFile(savePath, `${JSON.stringify(result['mapping'], null, 2)}\n`, 'utf8');
  }
  setResult({ ...result, ...(savePath === undefined ? {} : { mapping_saved_to: savePath }) });

  const read = (result['read'] ?? {}) as Row;
  heading(`${dryRun ? 'Rehearsed' : 'Imported'} ${source}, in ${company.name}`);
  pairs([
    ['read', `${text(read['entries'])} entries, ${text(read['lines'])} lines, ${text(read['opening_lines'])} opening lines`],
    ['accounts', `${text(read['accounts'])} in the files`],
    ['parties', text(read['contacts'])],
  ]);

  const accounts = (result['accounts'] ?? []) as Row[];
  if (accounts.length > 0) {
    line();
    table(
      [{ title: 'old account' }, { title: 'name' }, { title: 'becomes' }, { title: 'how' }],
      accounts.map((account) => [text(account['source']), text(account['name']), text(account['target']) || '—', text(account['basis'])]),
    );
  }
  const journals = ((result['mapping'] ?? {}) as Row)['journals'] as Record<string, string | null> | undefined;
  if (journals !== undefined && Object.keys(journals).length > 0) {
    line();
    table([{ title: 'old journal' }, { title: 'becomes' }], Object.entries(journals).map(([from, to]) => [from, to ?? '—']));
  }

  const violations = (result['violations'] ?? []) as Row[];
  for (const violation of violations) {
    warn(`${violation['row'] === null ? '' : `row ${text(violation['row'])}: `}${text(violation['message'])}`);
  }
  const refusals = (result['refusals'] ?? []) as string[];
  for (const refusal of refusals) warn(refusal);

  const written = result['result'] as Row | null;
  if (written !== null && written !== undefined) {
    line();
    pairs([
      ['entries', text(written['entries'])],
      ['numbers', written['first_number'] === null ? '—' : `${text(written['first_number'])} … ${text(written['last_number'])}`],
      ['opening', text(written['opening_number']) || '—'],
      ['debit', text(written['total_debit'])],
      ['credit', text(written['total_credit'])],
      ['parties', `${text(written['contacts_created'])} created, ${text(written['contacts_found'])} found`],
    ]);
    for (const year of (written['fiscal_years_opened'] ?? []) as Row[]) {
      step(`fiscal year ${text(year['name'])} opened, ${text(year['start_date'])} to ${text(year['end_date'])}`);
    }
  }
  if (savePath !== undefined) step(`correspondence saved to ${savePath}; answer what is empty and give it back with --mapping`);
  line();
  note(dim(text(result['note'])));
  return refusals.length > 0 ? 1 : 0;
}

async function importStatements(args: ParsedArgs, deps: BooksDeps, format: StatementFormat, paths: string[]): Promise<number> {
  for (const flag of ['mapping', 'save-mapping', 'open-years', 'opening-date', 'allow-result-accounts', 'keep-numbers', 'date-order', 'encoding']) {
    if (args.flags.has(flag)) throw new UsageError(`bad_flag: --${flag} is for books, and ${format} is a bank statement.`);
  }
  const bankAccount = stringFlag(args, 'bank-account');
  const ibanCountry = stringFlag(args, 'iban-country');
  const dryRun = boolFlag(args, 'dry-run');
  const files = await Promise.all(paths.map(async (path) => ({ name: basename(path), content: await readFile(path, 'utf8') })));

  const { backend, company } = await openBooks(args, deps);
  const results: Row[] = [];
  heading(`${dryRun ? 'Read' : 'Imported'} ${format}, in ${company.name}`);
  for (const file of files) {
    if (dryRun) {
      // A statement changes nothing that a rehearsal could show beyond what
      // the file holds: it books nothing, and the same file twice is a no-op.
      // So a dry run reads the file and does not ask the database.
      const read = describeStatementFile(format, file.content, ibanCountry);
      results.push({ file: file.name, ...read });
      step(`${file.name}: ${text(read['statements'])} statement(s), ${text(read['lines'])} line(s)`);
      continue;
    }
    const result = await importStatementFile(backend, {
      company_id: company.id,
      format,
      content: file.content,
      file_name: file.name,
      bank_account_id: bankAccount === undefined ? undefined : uuidArg(bankAccount, '--bank-account'),
      iban_country: ibanCountry,
    });
    results.push({ file: file.name, ...result });
    for (const statement of (result['statements'] ?? []) as Row[]) {
      step(`${file.name}: statement ${text(statement['reference'] ?? statement['id'])}, ${text(statement['lines_imported'])} line(s) imported`);
    }
    for (const violation of (result['violations'] ?? []) as Row[]) warn(`${file.name}: ${text(violation['message'])}`);
  }
  setResult({
    source: format,
    dry_run: dryRun,
    files: results,
    note: dryRun
      ? 'Nothing was written. The files were read; the database was not asked.'
      : 'A statement books nothing: every line waits as pending, for `ekwo match <line> <document>`. The same file again creates nothing.',
  });
  line();
  note(dim(dryRun ? 'Nothing was written. The files were read; the database was not asked.' : 'Every line waits as pending. Settle one with `ekwo match <line> <document>`.'));
  return 0;
}

function oneOf<T extends string>(value: string | undefined, allowed: readonly T[], flag: string): T | undefined {
  if (value === undefined) return undefined;
  if (!(allowed as readonly string[]).includes(value)) throw new UsageError(`bad_value: ${flag} is one of ${allowed.join(', ')}, got "${value}".`);
  return value as T;
}

async function readMapping(path: string): Promise<Partial<ImportMapping>> {
  let parsed: unknown;
  try {
    parsed = JSON.parse(await readFile(path, 'utf8'));
  } catch (error) {
    throw new UsageError(`bad_mapping: ${path} is not a JSON file: ${(error as Error).message}`);
  }
  if (typeof parsed !== 'object' || parsed === null || Array.isArray(parsed)) {
    throw new UsageError(`bad_mapping: ${path} must hold one JSON object, as --save-mapping writes it.`);
  }
  const mapping = parsed as Record<string, unknown>;
  for (const key of ['accounts', 'journals'] as const) {
    const part = mapping[key];
    if (part === undefined) continue;
    if (typeof part !== 'object' || part === null || Array.isArray(part)) throw new UsageError(`bad_mapping: "${key}" must be an object of old code → new code.`);
    for (const [from, to] of Object.entries(part)) {
      if (to !== null && typeof to !== 'string') throw new UsageError(`bad_mapping: "${key}.${from}" must be a code or null.`);
    }
  }
  return mapping as Partial<ImportMapping>;
}
