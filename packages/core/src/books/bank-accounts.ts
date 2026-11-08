/**
 * The bank accounts of a company, read and changed outside a statement.
 *
 * `create_bank_account()` of the schema creates one; what is here is the rest
 * both surfaces need — the list, and the profile of an account's CSV
 * statements (`bank_accounts.statement_profile`), the lay-out of its bank's
 * export, described once on the account for every member and every way in.
 * The MCP server's `list_bank_accounts` and `update_bank_account` and the
 * command line's `ekwo bank` call these, and `importStatementFile()` reads and
 * keeps the profile through them.
 */

import { StatementFileError as CsvFileError, checkCsvStatementProfile, type CsvStatementProfile } from '@ekwo-ai/csv-statement';
import { BooksError, type Backend, type Filter, type Row } from './backend.js';
import * as columns from './columns.js';

export interface ListBankAccountsArgs {
  company_id: string;
  /** Default false. */
  include_inactive?: boolean | undefined;
}

/**
 * The bank accounts of a company, by name, with the journal and the ledger
 * account behind each and the profile of its CSV statements — left out of the
 * row on a schema that does not keep one.
 */
export async function listBankAccounts(backend: Backend, args: ListBankAccountsArgs): Promise<Row[]> {
  return backend.select<Row>({
    table: 'bank_accounts',
    columns: [...columns.BANK_ACCOUNT],
    where: [
      { column: 'company_id', op: 'eq', value: args.company_id },
      ...(args.include_inactive === true ? [] : ([{ column: 'active', op: 'eq', value: true }] satisfies Filter[])),
    ],
    order: [{ column: 'name' }],
  });
}

/** A profile as a row holds it: an object, or nothing. */
export function profileOf(value: unknown): CsvStatementProfile | null {
  return value !== null && typeof value === 'object' && !Array.isArray(value) ? (value as CsvStatementProfile) : null;
}

/** One bank account of the company, or the refusal that names it. */
export async function bankAccountOf(backend: Backend, companyId: string, bankAccountId: string, select: string[]): Promise<Row> {
  const [account] = await backend.select<Row>({
    table: 'bank_accounts',
    columns: select,
    where: [
      { column: 'id', op: 'eq', value: bankAccountId },
      { column: 'company_id', op: 'eq', value: companyId },
    ],
  });
  if (account === undefined) {
    throw new BooksError(`unknown_bank_account: ${bankAccountId} is not a bank account of this company`, { code: 'unknown_bank_account' });
  }
  return account;
}

/**
 * The profile of the CSV statements kept on a bank account, `null` when
 * nobody has described them yet — and on a schema without the column, which
 * keeps none.
 */
export async function bankAccountStatementProfile(
  backend: Backend,
  args: { company_id: string; bank_account_id: string },
): Promise<CsvStatementProfile | null> {
  const account = await bankAccountOf(backend, args.company_id, args.bank_account_id, ['id', 'statement_profile']);
  return profileOf(account['statement_profile']);
}

export interface SetStatementProfileArgs {
  company_id: string;
  bank_account_id: string;
  /** The profile of the account's CSV statements; `null` forgets it. */
  statement_profile: CsvStatementProfile | null;
}

/**
 * Keeps — or, with `null`, forgets — the profile of a bank account's CSV
 * statements, outside an import: for a person who describes the lay-out
 * before the first file, or corrects it. A profile no file could be read with
 * is refused `invalid_profile`, as the reader would refuse it; a schema
 * without the column refuses by name, `schema_too_old_for`.
 */
export async function setBankAccountStatementProfile(backend: Backend, args: SetStatementProfileArgs): Promise<Row> {
  if (args.statement_profile !== null) {
    try {
      checkCsvStatementProfile(args.statement_profile);
    } catch (error) {
      if (error instanceof CsvFileError) {
        throw new BooksError(`invalid_profile: ${error.message}`, {
          code: 'invalid_profile',
          hint: 'Nothing was changed. The profile is described in the README of @ekwo-ai/csv-statement.',
        });
      }
      throw error;
    }
  }
  await bankAccountOf(backend, args.company_id, args.bank_account_id, ['id']);
  const [account] = await backend.update<Row>(
    'bank_accounts',
    { statement_profile: args.statement_profile },
    [
      { column: 'id', op: 'eq', value: args.bank_account_id },
      { column: 'company_id', op: 'eq', value: args.company_id },
    ],
    [...columns.BANK_ACCOUNT],
  );
  if (account === undefined) {
    throw new BooksError('not_allowed: changing a bank account of this company needs bank.write', { code: 'not_allowed' });
  }
  return account;
}
