/**
 * A bank statement file into `import_bank_statement()`.
 *
 * The four bricks that read a statement — `camt053`, `coda`, `cfonb120`,
 * `csv-statement` — return the same shape, and the schema's `import_bank_statement()` takes it.
 * What is here is the part both surfaces need: picking the brick by the format
 * the caller names, never by the content, and the checksum and the size of the
 * file the statement records as its source. It lived in the MCP server until
 * the command line imported statements too, as `ekwo import camt.053 <file>`.
 */

import { createHash } from 'node:crypto';
import { StatementFileError, readCamt053 } from '@ekwo-ai/camt053';
import { StatementFileError as Cfonb120FileError, readCfonb120 } from '@ekwo-ai/cfonb120';
import { StatementFileError as CodaFileError, readCoda } from '@ekwo-ai/coda';
import {
  StatementFileError as CsvFileError,
  readCsvStatement,
  type CsvStatementProfile,
} from '@ekwo-ai/csv-statement';
import type { StatementFormat } from '../bank.js';
import { BooksError, type Backend, type Row } from './backend.js';

/** What each format is delivered as, for the attachment the caller may have stored. */
const STATEMENT_MIME_TYPES: Record<StatementFormat, string> = {
  'camt.053': 'application/xml',
  coda: 'text/plain',
  cfonb120: 'text/plain',
  csv: 'text/csv',
};

export type { CsvStatementProfile } from '@ekwo-ai/csv-statement';

/**
 * What a reader needs and a file does not say. Each is for the formats it
 * names, and ignored by the others.
 */
export interface StatementReadOptions {
  /** `cfonb120`, which names no country: the country the account is held in. Never guessed. */
  ibanCountry?: string | undefined;
  /** `csv`, required: the profile of the file's columns. */
  profile?: CsvStatementProfile | undefined;
  /** `csv`, which names no account: the IBAN or identifier of the account the file is of. */
  account?: string | undefined;
  /** `csv`: the ISO 4217 currency of the account; rows of another currency are left out, and said. */
  currency?: string | undefined;
  /** `csv`: the opening balance the bank declares, as a decimal string, when the file carries no running balance. */
  openingBalance?: string | undefined;
  /** `csv`: the closing balance the bank declares, the same way. */
  closingBalance?: string | undefined;
}

export interface ImportStatementFileArgs {
  company_id: string;
  format: StatementFormat;
  /** The file as text (UTF-8). */
  content: string;
  file_name?: string | undefined;
  storage_path?: string | undefined;
  bank_account_id?: string | undefined;
  /** Only for `cfonb120`, which names no country: the country the account is held in. Never guessed. */
  iban_country?: string | undefined;
  /** Only for `csv`, and required for it: the profile of the file's columns. */
  csv_profile?: CsvStatementProfile | undefined;
  /** Only for `csv`: the opening balance the bank declares, when the file has no running balance. */
  opening_balance?: string | undefined;
  /** Only for `csv`: the closing balance the bank declares, the same way. */
  closing_balance?: string | undefined;
}

/** The options as they are given: the country alone, as before, or every option. */
function optionsOf(options: string | StatementReadOptions | undefined): StatementReadOptions {
  return typeof options === 'string' ? { ibanCountry: options } : (options ?? {});
}

/**
 * Reads a statement file with the brick of its format, and nothing else: no
 * database. A file the brick cannot read is refused by name.
 *
 * The third argument is the options; a string there is the country of a
 * `cfonb120`, as it always was. A `csv` is read only with a profile, and is
 * refused `csv_profile_required` without one: the file does not say which
 * column is what, and the profile is never guessed here.
 */
export function readStatementFile(format: StatementFormat, content: string, options?: string | StatementReadOptions | undefined) {
  const { ibanCountry, profile, ...csv } = optionsOf(options);
  if (format === 'csv' && profile === undefined) {
    throw new BooksError('csv_profile_required: a CSV is read with the profile of its columns, and none was given', {
      code: 'csv_profile_required',
      hint: 'Nothing was imported. Give the profile — the delimiter, the date format, the decimal mark and which column is the date and the amount — as @ekwo-ai/csv-statement describes it.',
    });
  }
  try {
    if (format === 'coda') return readCoda(content);
    if (format === 'cfonb120') return readCfonb120(content, ibanCountry === undefined ? {} : { ibanCountry });
    if (format === 'csv') {
      return readCsvStatement(content, profile as CsvStatementProfile, {
        ...(csv.account === undefined ? {} : { account: csv.account }),
        ...(csv.currency === undefined ? {} : { currency: csv.currency }),
        ...(csv.openingBalance === undefined ? {} : { openingBalance: csv.openingBalance }),
        ...(csv.closingBalance === undefined ? {} : { closingBalance: csv.closingBalance }),
      });
    }
    return readCamt053(content);
  } catch (error) {
    if (
      error instanceof StatementFileError ||
      error instanceof CodaFileError ||
      error instanceof Cfonb120FileError ||
      error instanceof CsvFileError
    ) {
      throw new BooksError(`unreadable_statement_file: ${error.message}`, {
        code: error.code,
        hint: `Nothing was imported. The file is not a ${format} this server can read; the message says what stopped it.`,
      });
    }
    throw error;
  }
}

/** What a statement file holds, counted: for a dry run, which writes nothing and asks nothing. */
export function describeStatementFile(
  format: StatementFormat,
  content: string,
  options?: string | StatementReadOptions | undefined,
): Record<string, unknown> {
  const file = readStatementFile(format, content, options);
  return {
    format,
    version: file.version,
    statements: file.statements.length,
    lines: file.statements.reduce((sum, statement) => sum + statement.lines.length, 0),
    accounts: [...new Set(file.statements.map((statement) => statement.account.identifier.value))],
    violations: file.violations,
  };
}

/**
 * Reads the file and imports its statements. A file the brick cannot read is
 * refused with nothing written; what reads and does not add up comes back in
 * `violations` beside what was imported.
 */
export async function importStatementFile(backend: Backend, args: ImportStatementFileArgs): Promise<Record<string, unknown>> {
  const file = readStatementFile(args.format, args.content, {
    ibanCountry: args.iban_country,
    ...(args.format === 'csv' ? await csvOptions(backend, args) : {}),
  });
  const bytes = Buffer.from(args.content, 'utf8');
  const source = {
    file_name: args.file_name ?? null,
    checksum: `sha256:${createHash('sha256').update(bytes).digest('hex')}`,
    byte_size: bytes.byteLength,
    mime_type: STATEMENT_MIME_TYPES[args.format],
    storage_path: args.storage_path ?? null,
  };
  const statements = await backend.rpc<Row>('import_bank_statement', {
    p_company_id: args.company_id,
    p_file: file,
    p_source: source,
    ...(args.bank_account_id !== undefined ? { p_bank_account_id: args.bank_account_id } : {}),
  });
  return {
    format: args.format,
    version: file.version,
    version_verified: 'versionVerified' in file ? file.versionVerified : null,
    checksum: source.checksum,
    statements,
    violations: file.violations,
    note: 'A statement is not an entry: every imported line waits as `pending`, and nothing was booked or paid. Importing the same file again creates nothing; a statement that overlaps an earlier one imports only what is new (`lines_known` is the rest). `warnings` names a missing statement — an opening balance that is not the previous closing one — which is signalled and never refused.',
  };
}

/**
 * What a CSV does not say and the account does: its identifier and its
 * currency. A CSV names no account, so it is imported into the one the caller
 * names (`bank_account_id`), and the statement carries that account's IBAN —
 * or the identifier its bank gives it — and currency, read from the account
 * itself rather than asked twice.
 */
async function csvOptions(backend: Backend, args: ImportStatementFileArgs): Promise<StatementReadOptions> {
  // Refused before the database is asked anything.
  if (args.csv_profile === undefined) readStatementFile('csv', args.content);
  if (args.bank_account_id === undefined) {
    throw new BooksError('csv_bank_account_required: a CSV names no account, so it is imported into the one named by bank_account_id', {
      code: 'csv_bank_account_required',
      hint: 'Nothing was imported. Name the bank account the file is of (list them with the bank accounts of the company).',
    });
  }
  const [account] = await backend.select<Row>({
    table: 'bank_accounts',
    columns: ['id', 'iban', 'account_identifier', 'currency_code'],
    where: [
      { column: 'id', op: 'eq', value: args.bank_account_id },
      { column: 'company_id', op: 'eq', value: args.company_id },
    ],
  });
  if (account === undefined) {
    throw new BooksError(`unknown_bank_account: ${args.bank_account_id} is not a bank account of this company`);
  }
  const identifier = [account['iban'], account['account_identifier'], account['id']].find(
    (value): value is string => typeof value === 'string' && value.trim() !== '',
  );
  return {
    profile: args.csv_profile,
    account: identifier,
    currency: typeof account['currency_code'] === 'string' ? account['currency_code'].trim() : undefined,
    openingBalance: args.opening_balance,
    closingBalance: args.closing_balance,
  };
}
