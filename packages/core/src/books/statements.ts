/**
 * A bank statement file into `import_bank_statement()`.
 *
 * The three bricks that read a statement — `camt053`, `coda`, `cfonb120` —
 * return the same shape, and the schema's `import_bank_statement()` takes it.
 * What is here is the part both surfaces need: picking the brick by the format
 * the caller names, never by the content, and the checksum and the size of the
 * file the statement records as its source. It lived in the MCP server until
 * the command line imported statements too, as `ekwo import camt.053 <file>`.
 */

import { createHash } from 'node:crypto';
import { StatementFileError, readCamt053 } from '@ekwo-ai/camt053';
import { StatementFileError as Cfonb120FileError, readCfonb120 } from '@ekwo-ai/cfonb120';
import { StatementFileError as CodaFileError, readCoda } from '@ekwo-ai/coda';
import type { StatementFormat } from '../bank.js';
import { BooksError, type Backend, type Row } from './backend.js';

/** What each format is delivered as, for the attachment the caller may have stored. */
const STATEMENT_MIME_TYPES: Record<StatementFormat, string> = {
  'camt.053': 'application/xml',
  coda: 'text/plain',
  cfonb120: 'text/plain',
};

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
}

/**
 * Reads a statement file with the brick of its format, and nothing else: no
 * database. A file the brick cannot read is refused by name.
 */
export function readStatementFile(format: StatementFormat, content: string, ibanCountry?: string | undefined) {
  try {
    if (format === 'coda') return readCoda(content);
    if (format === 'cfonb120') return readCfonb120(content, ibanCountry === undefined ? {} : { ibanCountry });
    return readCamt053(content);
  } catch (error) {
    if (
      error instanceof StatementFileError ||
      error instanceof CodaFileError ||
      error instanceof Cfonb120FileError
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
export function describeStatementFile(format: StatementFormat, content: string, ibanCountry?: string | undefined): Record<string, unknown> {
  const file = readStatementFile(format, content, ibanCountry);
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
  const file = readStatementFile(args.format, args.content, args.iban_country);
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
