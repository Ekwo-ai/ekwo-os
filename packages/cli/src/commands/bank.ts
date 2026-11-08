/**
 * `ekwo bank list` and `ekwo bank profile`.
 *
 * The bank accounts of the company, and the profile of each one's CSV
 * statements — the lay-out of its bank's export, kept on the account
 * (`bank_accounts.statement_profile`) so that `ekwo import csv` reads a file
 * of it without `--csv-profile`, whoever imports it. `listBankAccounts()` and
 * `setBankAccountStatementProfile()` of the core are the MCP server's
 * `list_bank_accounts` and `update_bank_account`; an import given a profile
 * keeps it on the account too, so this command is for describing the lay-out
 * before the first file, reading it, or correcting it.
 */

import {
  bankAccountStatementProfile,
  listBankAccounts,
  setBankAccountStatementProfile,
} from '@ekwo-ai/core';
import { UsageError, boolFlag, rejectUnknownFlags, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, openBooks, uuidArg, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, line, note, step, table } from '../ui.js';
import { readProfile } from './import.js';

const LIST_FLAGS = [...BOOKS_FLAGS, 'all'] as const;
const PROFILE_FLAGS = [...BOOKS_FLAGS, 'clear'] as const;

const USAGE = `usage: ekwo bank list [--all]
       ekwo bank profile <bank account id> [<file.json> | --clear]`;

const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

export async function bankCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  const action = args.positional[0];
  if (action === 'list') return list(args, deps);
  if (action === 'profile') return profile(args, deps);
  throw new UsageError(USAGE);
}

async function list(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, LIST_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const accounts = await listBankAccounts(backend, { company_id: company.id, include_inactive: boolFlag(args, 'all') });
  setResult({ bank_accounts: accounts, count: accounts.length });

  heading(`Bank accounts of ${company.name}`);
  if (accounts.length === 0) {
    note(dim('None. `ekwo init` registers the main one; the MCP server\'s create_bank_account adds others.'));
    return 0;
  }
  table(
    [{ title: 'name' }, { title: 'identifier' }, { title: 'currency' }, { title: 'csv profile' }, { title: 'id' }],
    accounts.map((account) => [
      text(account['name']),
      text(account['account_identifier'] ?? account['iban']),
      text(account['currency_code']),
      account['statement_profile'] === null || account['statement_profile'] === undefined ? dim('none') : 'kept',
      dim(text(account['id'])),
    ]),
  );
  return 0;
}

async function profile(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, PROFILE_FLAGS);
  const [, account, path] = args.positional;
  if (account === undefined) throw new UsageError(`missing_argument: the bank account.\n${USAGE}`);
  const clear = boolFlag(args, 'clear');
  if (clear && path !== undefined) throw new UsageError(`bad_argument: a profile file, or --clear, not both.\n${USAGE}`);
  const bankAccountId = uuidArg(account, 'the bank account');
  const given = path === undefined ? undefined : await readProfile(path);
  const { backend, company } = await openBooks(args, deps);

  if (given === undefined && !clear) {
    const kept = await bankAccountStatementProfile(backend, { company_id: company.id, bank_account_id: bankAccountId });
    setResult({ bank_account_id: bankAccountId, statement_profile: kept });
    heading(`The CSV profile of a bank account, in ${company.name}`);
    if (kept === null) note(dim('None kept. Give one: ekwo bank profile <account> <file.json>, or import a CSV with --csv-profile.'));
    else line(JSON.stringify(kept, null, 2));
    return 0;
  }

  const updated = await setBankAccountStatementProfile(backend, {
    company_id: company.id,
    bank_account_id: bankAccountId,
    statement_profile: clear ? null : (given ?? null),
  });
  setResult({ bank_account: updated });
  heading(`The CSV profile of ${text(updated['name'])}, in ${company.name}`);
  step(clear ? 'forgotten: a CSV of this account is imported with --csv-profile again' : 'kept: a CSV of this account is imported without --csv-profile');
  return 0;
}
