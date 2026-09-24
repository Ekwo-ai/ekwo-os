/**
 * A transaction journal saved as CSV: the report a ledger prints of every
 * transaction it posted, one after the other, each line of a transaction on a
 * row of its own. Such a ledger exports its reports to a spreadsheet and not
 * to CSV; the spreadsheet is saved as CSV, and that file is what this reads —
 * beside it, the list of accounts, exported and saved the same way.
 *
 * What sets this report apart from a journal report that numbers its journals
 * is that **nothing on a line names the transaction it belongs to**: a
 * transaction is the rows that follow each other under one date, one type and
 * one number. So the report is read in order:
 *
 * - a row with an account and a date **starts** a transaction — unless it
 *   repeats the date, the type and the number of the transaction just before,
 *   which some layouts print on every line;
 * - a row with an account and no date **continues** the transaction above it;
 * - a row with no account — the total of a transaction, a blank row, the total
 *   of the report, a footer — **ends** it.
 *
 * The header is the first row that names a date, an account, a debit and a
 * credit; the title rows above it are passed over. Columns are found by their
 * names, never by their position.
 *
 * A date written in digits in an order nobody can read off the digits —
 * `03/04/2026` — is read in the order the caller names, and refused without
 * one: which order a report uses follows the region of the company, and the
 * file does not say it.
 *
 * It depends on nothing, reads no database and knows no chart of accounts.
 */

import { decode, headerKey, parseCsv, separatorOf } from './csv.js';
import { formatDecimal } from './decimal.js';
import { BooksFileError } from './errors.js';
import type {
  ImportedAccount,
  ImportedBooks,
  ImportedContact,
  ImportedEntry,
  ImportedLine,
  ReadOptions,
  Violation,
} from './types.js';

export * from './types.js';
export { BooksFileError, type BooksFileErrorCode } from './errors.js';

const DEFAULTS = { encoding: 'utf-8', maxBytes: 256 * 1024 * 1024 } as const;

/** The order of day, month and year in a date written only in digits. */
export type DateOrder = 'dmy' | 'mdy' | 'ymd';

export interface TransactionJournalOptions extends ReadOptions {
  /** How a date written only in digits is to be read. Required when the report writes one; never guessed. */
  dateOrder?: DateOrder;
}

/** The columns of the report, each under the names it may carry. */
export const JOURNAL_COLUMNS = {
  date: ['date', 'transaction date'],
  type: ['transaction type', 'type'],
  number: ['num', 'no.', 'no', 'number', 'ref no.'],
  name: ['name'],
  customer: ['customer full name', 'customer'],
  vendor: ['vendor', 'supplier'],
  employee: ['employee'],
  memo: ['memo/description', 'memo', 'description'],
  accountNumber: ['account #', 'account number', 'account no.'],
  account: ['account', 'account full name', 'account name'],
  debit: ['debit'],
  credit: ['credit'],
} as const;

/** The columns of the list of accounts. */
export const ACCOUNT_LIST_COLUMNS = {
  account: ['account', 'full name', 'account full name', 'account name', 'name'],
  number: ['account #', 'account number', 'number'],
  type: ['type', 'account type'],
} as const;

type Spec = Record<string, readonly string[]>;

function locate<S extends Spec>(keys: string[], spec: S): Partial<Record<keyof S, number>> {
  const at: Partial<Record<keyof S, number>> = {};
  for (const [column, names] of Object.entries(spec) as [keyof S, readonly string[]][]) {
    const found = keys.findIndex((key) => names.includes(key));
    if (found !== -1) at[column] = found;
  }
  return at;
}

const has = (keys: string[], names: readonly string[]): boolean => keys.some((key) => names.includes(key));

interface Sheet {
  file: number;
  separator: string;
  rows: { row: number; fields: string[] }[];
}

function isJournalHeader(keys: string[]): boolean {
  return (
    has(keys, JOURNAL_COLUMNS.date) &&
    (has(keys, JOURNAL_COLUMNS.account) || has(keys, JOURNAL_COLUMNS.accountNumber)) &&
    has(keys, JOURNAL_COLUMNS.debit) &&
    has(keys, JOURNAL_COLUMNS.credit)
  );
}

function isAccountListHeader(keys: string[]): boolean {
  return has(keys, ACCOUNT_LIST_COLUMNS.account) && has(keys, ACCOUNT_LIST_COLUMNS.type) && !has(keys, JOURNAL_COLUMNS.debit);
}

/** A transaction as it is being read: its key, and whether a row has ended it. */
interface Open {
  key: string;
  entry: ImportedEntry & { debits: bigint; credits: bigint };
}

/**
 * Reads the files — the journal, and optionally the list of accounts — in any
 * order, each recognised by its header.
 */
export function readTransactionJournal(inputs: readonly (string | Uint8Array)[], options: TransactionJournalOptions = {}): ImportedBooks {
  const sheets: Sheet[] = inputs.map((input, index) => {
    const text = decode(input, options.encoding ?? DEFAULTS.encoding, options.maxBytes ?? DEFAULTS.maxBytes);
    // The title rows above the header may hold no separator at all, or one
    // inside quotes only ("January 1-31, 2025"), so the separator is read from
    // the first line that holds one outside quotes.
    const firstWithSeparator = text.split(/\r?\n/).find((line) => /[,;\t]/.test(line.replace(/"[^"]*"/g, ''))) ?? '';
    const separator = separatorOf(firstWithSeparator);
    return { file: index + 1, separator, rows: parseCsv(text, separator) };
  });

  const violations: Violation[] = [];
  const accounts = new Map<string, ImportedAccount>();
  const contacts = new Map<string, ImportedContact>();
  /** The list of accounts, by the name a line displays: its number where the list gives one, and its type. */
  const listed = new Map<string, { number: string | null; type: string | null }>();
  const journals: { sheet: Sheet; headerAt: number }[] = [];

  for (const sheet of sheets) {
    if (sheet.rows.length === 0) throw new BooksFileError('empty_file', `file ${sheet.file} is empty`);
    const journalAt = sheet.rows.findIndex((r) => isJournalHeader(r.fields.map(headerKey)));
    if (journalAt !== -1) {
      journals.push({ sheet, headerAt: journalAt });
      continue;
    }
    const listAt = sheet.rows.findIndex((r) => isAccountListHeader(r.fields.map(headerKey)));
    if (listAt === -1) {
      throw new BooksFileError(
        'missing_column',
        `file ${sheet.file} is neither a journal (a header with Date, Account, Debit and Credit) nor a list of accounts (Account, Type)`,
      );
    }
    const at = locate((sheet.rows[listAt] as { fields: string[] }).fields.map(headerKey), ACCOUNT_LIST_COLUMNS);
    for (const { fields } of sheet.rows.slice(listAt + 1)) {
      const cell = (column: keyof typeof ACCOUNT_LIST_COLUMNS): string => {
        const index = at[column];
        return index === undefined ? '' : (fields[index] ?? '').trim();
      };
      const name = cell('account');
      const type = cell('type');
      // A row with a name and no type is a heading or a footer of the list.
      if (name === '' || type === '') continue;
      listed.set(name, { number: cell('number') === '' ? null : cell('number'), type });
    }
  }
  if (journals.length === 0) {
    throw new BooksFileError('missing_column', 'no file is a journal: one needs a header row with Date, Account, Debit and Credit');
  }

  const entries: (ImportedEntry & { debits: bigint; credits: bigint })[] = [];
  for (const { sheet, headerAt } of journals) {
    const header = sheet.rows[headerAt] as { row: number; fields: string[] };
    const at = locate(header.fields.map(headerKey), JOURNAL_COLUMNS);
    let open: Open | null = null;

    for (const { row, fields } of sheet.rows.slice(headerAt + 1)) {
      const cell = (column: keyof typeof JOURNAL_COLUMNS): string => {
        const index = at[column];
        return index === undefined ? '' : (fields[index] ?? '').trim();
      };
      const accountName = cell('account');
      const accountNumber = cell('accountNumber');
      if (accountName === '' && accountNumber === '') {
        // A total, a blank row, the total of the report, a footer: the
        // transaction above is over.
        open = null;
        continue;
      }
      const date = readDate(cell('date'), options.dateOrder, row);
      if (date === null && cell('date') !== '') {
        violations.push({ rule: 'required', message: `"${cell('date')}" stands where the date of a line is, and the line was left out`, row });
        continue;
      }

      const type = cell('type');
      const number = cell('number');
      if (date !== null) {
        const key = `${date}\u0000${type}\u0000${number}`;
        if (open === null || open.key !== key) {
          const memo = cell('memo');
          const entry = {
            journal: type === '' ? null : type,
            journalName: type === '' ? null : type,
            number: number === '' ? null : number,
            date,
            reference: number === '' ? null : number,
            description: memo === '' ? null : memo,
            lines: [],
            row,
            debits: 0n,
            credits: 0n,
          };
          entries.push(entry);
          open = { key, entry };
        }
      } else if (open === null) {
        violations.push({ rule: 'no_transaction', message: 'a line with no date follows no dated line of the same transaction, and was left out', row });
        continue;
      }
      const entry = open.entry;

      let debit = amount(cell('debit'), sheet.separator, row);
      let credit = amount(cell('credit'), sheet.separator, row);
      if (debit !== 0n && credit !== 0n) violations.push({ rule: 'one_side', message: 'a line carries both a debit and a credit', row });
      if (debit < 0n) {
        credit -= debit;
        debit = 0n;
      }
      if (credit < 0n) {
        debit -= credit;
        credit = 0n;
      }

      const onList = listed.get(accountName);
      const code = accountNumber !== '' ? accountNumber : (onList?.number ?? accountName);
      if (!accounts.has(code)) {
        accounts.set(code, { code, name: accountName === '' ? null : accountName, type: onList?.type ?? null });
      }
      const party = [cell('name'), cell('customer'), cell('vendor'), cell('employee')].find((value) => value !== '') ?? '';
      if (party !== '' && !contacts.has(party)) {
        contacts.set(party, { code: party, name: party, vatNumber: null, registrationNumber: null, email: null, country: null });
      }
      const label = cell('memo');
      const line: ImportedLine = {
        account: code,
        contact: party === '' ? null : party,
        label: label === '' ? null : label,
        debit: formatDecimal(debit),
        credit: formatDecimal(credit),
        currency: null,
        amountCurrency: null,
        dueDate: null,
        matching: null,
      };
      entry.lines.push(line);
      entry.debits += debit;
      entry.credits += credit;
    }
  }

  const read: ImportedEntry[] = [];
  for (const { debits, credits, ...entry } of entries) {
    if (debits !== credits) {
      const name = [entry.journal, entry.number].filter((part) => part !== null).join(' ') || 'a transaction';
      violations.push({
        rule: 'balance',
        message: `${name} of ${entry.date} has debit ${formatDecimal(debits)} and credit ${formatDecimal(credits)}`,
        row: entry.row,
      });
    }
    read.push(entry);
  }
  if (read.length === 0) throw new BooksFileError('empty_file', 'the journal holds no dated line');

  return {
    format: 'transaction-journal',
    // A report prints amounts in the currency of the company and does not say which.
    currency: null,
    accounts: [...accounts.values()],
    contacts: [...contacts.values()],
    entries: read,
    opening: [],
    violations,
  };
}

const MONTHS = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];

/**
 * A date, or null for a cell that is not one. A cell that looks like a date
 * and is not a day of the calendar is refused, never passed over.
 */
export function readDate(value: string, order: DateOrder | undefined, row: number): string | null {
  let y: number;
  let m: number;
  let d: number;
  let match: RegExpExecArray | null;
  if (value === '') return null;
  if ((match = /^(\d{4})-(\d{2})-(\d{2})(?:[ T].*)?$/.exec(value)) !== null) {
    [y, m, d] = [Number(match[1]), Number(match[2]), Number(match[3])];
  } else if ((match = /^(\d{1,2})[ -]([A-Za-z]{3,9})[ -](\d{4})$/.exec(value)) !== null) {
    const month = MONTHS.indexOf((match[2] as string).slice(0, 3).toLowerCase());
    if (month === -1) return null;
    [y, m, d] = [Number(match[3]), month + 1, Number(match[1])];
  } else if ((match = /^([A-Za-z]{3,9}) (\d{1,2}),? (\d{4})$/.exec(value)) !== null) {
    const month = MONTHS.indexOf((match[1] as string).slice(0, 3).toLowerCase());
    if (month === -1) return null;
    [y, m, d] = [Number(match[3]), month + 1, Number(match[2])];
  } else if ((match = /^(\d{1,4})[/.-](\d{1,2})[/.-](\d{1,4})$/.exec(value)) !== null) {
    if (order === undefined) {
      throw new BooksFileError(
        'invalid_value',
        `"${value}" is a date written in digits, and nothing in the file says in which order; name it (dateOrder: 'dmy', 'mdy' or 'ymd')`,
        row,
      );
    }
    const [a, b, c] = [Number(match[1]), Number(match[2]), Number(match[3])];
    [y, m, d] = order === 'dmy' ? [c, b, a] : order === 'mdy' ? [c, a, b] : [a, b, c];
    if (y < 100) y += 2000;
  } else {
    return null;
  }
  const iso = `${String(y).padStart(4, '0')}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
  const parsed = new Date(`${iso}T00:00:00Z`);
  if (Number.isNaN(parsed.getTime()) || parsed.toISOString().slice(0, 10) !== iso) {
    throw new BooksFileError('invalid_value', `"${value}" is not a date of the calendar`, row);
  }
  return iso;
}

/**
 * An amount as a spreadsheet displays it once saved as CSV. In a file
 * separated by commas the decimal mark is a point and a comma can only group
 * thousands, three digits at a time (`1,234.50`). In a file separated by a
 * semicolon or a tab the decimal mark is whichever of the two the number
 * carries once, and thousands may only be grouped by a space. A negative is a
 * minus or brackets. Anything else — a currency symbol included — is refused.
 */
export function amount(raw: string, separator: string, row: number): bigint {
  let value = raw.replace(/[  ]/g, ' ').trim();
  if (value === '') return 0n;
  let negative = false;
  if (value.startsWith('(') && value.endsWith(')')) {
    negative = true;
    value = value.slice(1, -1).trim();
  }
  if (value.startsWith('-')) {
    negative = !negative;
    value = value.slice(1).trim();
  }
  let normalised: string | null = null;
  if (separator === ',') {
    if (/^\d{1,3}(,\d{3})+(\.\d+)?$/.test(value) || /^\d+(\.\d+)?$/.test(value)) normalised = value.replace(/,/g, '');
  } else {
    const grouped = value.replace(/ (?=\d{3}(\D|$))/g, '');
    if (/^\d+([.,]\d+)?$/.test(grouped)) normalised = grouped.replace(',', '.');
  }
  if (normalised === null) {
    throw new BooksFileError('invalid_value', `"${raw}" is not an amount this reader accepts`, row);
  }
  const [whole, fraction = ''] = normalised.split('.') as [string, string?];
  if (fraction.length > 6) throw new BooksFileError('invalid_value', `"${raw}" has more than six decimals`, row);
  const units = BigInt(whole) * 1_000_000n + BigInt(fraction.padEnd(6, '0') || '0');
  return negative ? -units : units;
}
