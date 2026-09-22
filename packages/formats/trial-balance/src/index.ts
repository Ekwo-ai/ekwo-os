/**
 * A trial balance, written as CSV: one row per account, a debit and a credit,
 * or a signed balance. It is the one thing every accounting package can print
 * and every spreadsheet can save, which is why it is the way in for books that
 * come from anywhere: the balances of the day the new books open on.
 *
 * It depends on nothing, reads no database and knows no chart of accounts: the
 * codes are the ones the file wrote, and saying which account of another chart
 * each of them becomes is the importer's business, not this reader's.
 */

import { decode, headerKey, parseCsv, separatorOf } from './csv.js';
import { formatDecimal, parseDecimal, type DecimalMark } from './decimal.js';
import { BooksFileError } from './errors.js';
import type { ImportedAccount, ImportedBooks, ImportedContact, ImportedLine, ReadOptions, Violation } from './types.js';

export * from './types.js';
export { BooksFileError, type BooksFileErrorCode } from './errors.js';

const DEFAULTS = { encoding: 'utf-8', maxBytes: 64 * 1024 * 1024 } as const;

/**
 * The columns this reader knows, each under the names it accepts in a header.
 * Compared without regard to case, and without the `*` some exports put on a
 * column that is required.
 */
export const TRIAL_BALANCE_COLUMNS = {
  account: ['account', 'account code', 'code'],
  name: ['name', 'account name'],
  debit: ['debit'],
  credit: ['credit'],
  balance: ['balance'],
  contact: ['contact', 'party'],
  contactName: ['contact name', 'party name'],
  label: ['label', 'description'],
} as const;

type Column = keyof typeof TRIAL_BALANCE_COLUMNS;

/**
 * Reads the file. A row carries its account and either a debit and a credit —
 * the totals a trial balance prints, which are netted: 100 in debit and 30 in
 * credit open at 70 in debit — or one signed `balance`, positive in debit.
 * A row that nets to zero opens nothing and is left out.
 *
 * A comma is read as the decimal mark only in a file whose fields are
 * separated by something else, where it cannot be a separator of thousands.
 */
export function readTrialBalance(input: string | Uint8Array, options: ReadOptions = {}): ImportedBooks {
  const text = decode(input, options.encoding ?? DEFAULTS.encoding, options.maxBytes ?? DEFAULTS.maxBytes);
  const firstLine = text.split(/\r?\n/, 1)[0] ?? '';
  const separator = separatorOf(firstLine);
  const rows = parseCsv(text, separator);
  const header = rows.shift();
  if (header === undefined) throw new BooksFileError('empty_file', 'the file is empty');

  const at = locate(header.fields);
  if (at.account === undefined) {
    throw new BooksFileError('missing_column', `the header names no account column; it needs one of: ${TRIAL_BALANCE_COLUMNS.account.join(', ')}`, header.row);
  }
  const signed = at.balance !== undefined;
  if (!signed && (at.debit === undefined || at.credit === undefined)) {
    throw new BooksFileError('missing_column', 'the header needs a debit and a credit column, or one signed balance column', header.row);
  }
  if (signed && (at.debit !== undefined || at.credit !== undefined)) {
    throw new BooksFileError('missing_column', 'the header has a balance column beside a debit or a credit one; keep one of the two ways, so that no amount is read twice', header.row);
  }
  if (rows.length === 0) throw new BooksFileError('empty_file', 'the file has a header and no row under it', header.row);

  const marks: DecimalMark[] = separator === ',' ? ['.'] : ['.', ','];
  const cell = (fields: string[], column: Column): string => {
    const index = at[column];
    return index === undefined ? '' : (fields[index] ?? '').trim();
  };
  const amount = (fields: string[], column: Column, row: number): bigint => {
    const raw = cell(fields, column);
    if (raw === '') return 0n;
    const value = parseDecimal(raw, marks);
    if (value === null) {
      throw new BooksFileError(
        'invalid_value',
        `"${raw}" in the ${column} column is not an amount this reader accepts: digits and one decimal mark${separator === ',' ? ' (a point, in a comma-separated file)' : ''}, no thousands separator, no currency sign`,
        row,
      );
    }
    return value;
  };

  const accounts = new Map<string, ImportedAccount>();
  const contacts = new Map<string, ImportedContact>();
  const opening: ImportedLine[] = [];
  const violations: Violation[] = [];
  let debits = 0n;
  let credits = 0n;

  for (const { row, fields } of rows) {
    const account = cell(fields, 'account');
    if (account === '') {
      violations.push({ rule: 'account_missing', message: 'a row names no account and was left out', row });
      continue;
    }
    const name = cell(fields, 'name');
    if (!accounts.has(account)) accounts.set(account, { code: account, name: name === '' ? null : name, type: null });

    const net = signed ? amount(fields, 'balance', row) : amount(fields, 'debit', row) - amount(fields, 'credit', row);
    if (net === 0n) continue;

    const contact = cell(fields, 'contact');
    if (contact !== '' && !contacts.has(contact)) {
      const contactName = cell(fields, 'contactName');
      contacts.set(contact, {
        code: contact,
        name: contactName === '' ? contact : contactName,
        vatNumber: null,
        registrationNumber: null,
        email: null,
        country: null,
      });
    }
    const label = cell(fields, 'label');
    opening.push({
      account,
      contact: contact === '' ? null : contact,
      label: label === '' ? null : label,
      debit: formatDecimal(net > 0n ? net : 0n),
      credit: formatDecimal(net < 0n ? -net : 0n),
      currency: null,
      amountCurrency: null,
      dueDate: null,
      matching: null,
    });
    if (net > 0n) debits += net;
    else credits -= net;
  }

  if (debits !== credits) {
    violations.push({
      rule: 'unbalanced',
      message: `the balance has debit ${formatDecimal(debits)} and credit ${formatDecimal(credits)}; an opening entry has to balance`,
      row: null,
    });
  }

  return {
    format: 'trial-balance',
    currency: null,
    accounts: [...accounts.values()],
    contacts: [...contacts.values()],
    entries: [],
    opening,
    violations,
  };
}

function locate(header: string[]): Partial<Record<Column, number>> {
  const keys = header.map(headerKey);
  const at: Partial<Record<Column, number>> = {};
  for (const [column, names] of Object.entries(TRIAL_BALANCE_COLUMNS) as [Column, readonly string[]][]) {
    const found = keys.findIndex((key) => names.includes(key));
    if (found !== -1) at[column] = found;
  }
  return at;
}
