/**
 * An export of journal items: the list view of the lines of every entry,
 * saved as CSV, one row per line. It is what an ERP whose ledger is a table of
 * lines hands over when it is asked for its books — and beside it, from the
 * same export screen, the chart of accounts and the partners.
 *
 * The columns are found **by their names in the header**, under either of the
 * two spellings such an export uses: the label a person reads (`Journal Entry`,
 * `Account`, `Partner`, `Debit`) or the technical name of the field
 * (`move_id`, `account_id`, `partner_id`, `debit`). An account arrives as it
 * is displayed, its code and then its name (`400000 Customers`); a partner as
 * its name. Dates are ISO, amounts carry a point.
 *
 * It depends on nothing, reads no database and knows no chart of accounts.
 */

import { decode, headerKey, parseCsv, separatorOf } from './csv.js';
import { formatDecimal, parseDecimal, type DecimalMark } from './decimal.js';
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

/** The columns of the lines, each under the names the export may give it. */
export const JOURNAL_ITEM_COLUMNS = {
  number: ['number', 'move_name'],
  entry: ['journal entry', 'move_id', 'entry'],
  journal: ['journal', 'journal_id'],
  date: ['date'],
  account: ['account', 'account_id'],
  partner: ['partner', 'partner_id'],
  label: ['label', 'name'],
  reference: ['reference', 'ref'],
  debit: ['debit'],
  credit: ['credit'],
  currency: ['currency', 'currency_id'],
  amountCurrency: ['amount in currency', 'amount_currency'],
  companyCurrency: ['company currency', 'company_currency_id'],
  dueDate: ['due date', 'date_maturity'],
  matching: ['matching #', 'matching_number'],
  status: ['status', 'parent_state'],
} as const;

/** The columns of the chart of accounts exported beside them. */
export const ACCOUNT_COLUMNS = {
  code: ['code'],
  name: ['account name', 'name'],
  type: ['type', 'account_type'],
} as const;

/** The columns of the partners exported beside them. */
export const PARTNER_COLUMNS = {
  name: ['name', 'display name', 'display_name'],
  vat: ['tax id', 'vat'],
  registration: ['company id', 'company_registry'],
  email: ['email'],
  country: ['country/country code', 'country_id/code', 'country code'],
  reference: ['reference', 'ref'],
} as const;

type Spec = Record<string, readonly string[]>;
type Located<S extends Spec> = Partial<Record<keyof S, number>>;

function locate<S extends Spec>(keys: string[], spec: S): Located<S> {
  const at: Located<S> = {};
  for (const [column, names] of Object.entries(spec) as [keyof S, readonly string[]][]) {
    const found = keys.findIndex((key) => names.includes(key));
    if (found !== -1) at[column] = found;
  }
  return at;
}

interface Table {
  rows: { row: number; fields: string[] }[];
  keys: string[];
  marks: DecimalMark[];
  file: number;
}

function table(input: string | Uint8Array, options: ReadOptions, file: number): Table {
  const text = decode(input, options.encoding ?? DEFAULTS.encoding, options.maxBytes ?? DEFAULTS.maxBytes);
  const separator = separatorOf(text.split(/\r?\n/, 1)[0] ?? '');
  const rows = parseCsv(text, separator);
  const header = rows.shift();
  if (header === undefined) throw new BooksFileError('empty_file', `file ${file} is empty`);
  return { rows, keys: header.fields.map(headerKey), marks: separator === ',' ? ['.'] : ['.', ','], file };
}

/** What a file is, from its header: the lines, the chart, or the partners. */
function kindOf(keys: string[]): 'items' | 'accounts' | 'partners' | null {
  const has = (names: readonly string[]): boolean => keys.some((key) => names.includes(key));
  if (has(JOURNAL_ITEM_COLUMNS.debit) && has(JOURNAL_ITEM_COLUMNS.credit) && has(JOURNAL_ITEM_COLUMNS.account)) return 'items';
  if (has(ACCOUNT_COLUMNS.code) && has(ACCOUNT_COLUMNS.type)) return 'accounts';
  if (has(PARTNER_COLUMNS.name)) return 'partners';
  return null;
}

/**
 * Reads the files — the journal items, and optionally the chart of accounts
 * and the partners — in any order: each is recognised by its header, and a
 * file that is none of the three is refused by name.
 *
 * Lines belong to one entry when they share its number (`Number`, `move_name`)
 * or, without that column, its display name (`Journal Entry`, `move_id`). A
 * line whose entry is not posted is refused in `violations`: export the posted
 * entries, which is what books are made of.
 */
export function readJournalItems(inputs: readonly (string | Uint8Array)[], options: ReadOptions = {}): ImportedBooks {
  const tables = inputs.map((input, index) => table(input, options, index + 1));
  const kinds = tables.map((t) => ({ table: t, kind: kindOf(t.keys) }));
  for (const { table: t, kind } of kinds) {
    if (kind === null) {
      throw new BooksFileError('missing_column', `file ${t.file} is neither journal items (account, debit, credit), a chart of accounts (code, type) nor partners (name)`);
    }
  }
  const itemTables = kinds.filter((k) => k.kind === 'items').map((k) => k.table);
  if (itemTables.length === 0) throw new BooksFileError('missing_column', 'no file holds journal items: one needs an account, a debit and a credit column');

  const violations: Violation[] = [];
  const accounts = new Map<string, ImportedAccount>();
  const contacts = new Map<string, ImportedContact>();

  for (const t of kinds.filter((k) => k.kind === 'accounts').map((k) => k.table)) {
    const at = locate(t.keys, ACCOUNT_COLUMNS);
    for (const { fields } of t.rows) {
      const code = (fields[at.code as number] ?? '').trim();
      if (code === '') continue;
      const name = at.name === undefined ? '' : (fields[at.name] ?? '').trim();
      const type = at.type === undefined ? '' : (fields[at.type] ?? '').trim();
      accounts.set(code, { code, name: name === '' ? null : name, type: type === '' ? null : type });
    }
  }
  for (const t of kinds.filter((k) => k.kind === 'partners').map((k) => k.table)) {
    const at = locate(t.keys, PARTNER_COLUMNS);
    for (const { fields } of t.rows) {
      const cell = (column: keyof typeof PARTNER_COLUMNS): string => {
        const index = at[column];
        return index === undefined ? '' : (fields[index] ?? '').trim();
      };
      const name = cell('name');
      if (name === '') continue;
      const country = cell('country').toUpperCase();
      contacts.set(name, {
        code: name,
        name,
        vatNumber: cell('vat') === '' ? null : cell('vat'),
        registrationNumber: cell('registration') === '' ? null : cell('registration'),
        email: cell('email') === '' ? null : cell('email'),
        country: /^[A-Z]{2}$/.test(country) ? country : null,
      });
    }
  }

  // An account arrives as displayed, "code name". With the chart beside it the
  // display is matched whole; without, the code is what comes before the
  // first space.
  const displays = new Map([...accounts.values()].map((a) => [`${a.code} ${a.name ?? ''}`.trim(), a.code]));
  const accountOf = (display: string): string => {
    const known = displays.get(display);
    if (known !== undefined) return known;
    const space = display.indexOf(' ');
    return space === -1 ? display : display.slice(0, space);
  };

  const entries = new Map<string, ImportedEntry & { debits: bigint; credits: bigint }>();
  const currencies = new Set<string>();

  for (const t of itemTables) {
    const at = locate(t.keys, JOURNAL_ITEM_COLUMNS);
    const key = at.number ?? at.entry;
    if (key === undefined) {
      throw new BooksFileError('missing_column', `file ${t.file} names no entry for its lines: it needs a Number (move_name) or a Journal Entry (move_id) column`);
    }
    if (at.date === undefined) throw new BooksFileError('missing_column', `file ${t.file} has no Date column`);

    for (const { row, fields } of t.rows) {
      const cell = (column: keyof typeof JOURNAL_ITEM_COLUMNS): string => {
        const index = at[column];
        return index === undefined ? '' : (fields[index] ?? '').trim();
      };
      const amount = (column: keyof typeof JOURNAL_ITEM_COLUMNS): bigint => {
        const raw = cell(column);
        if (raw === '') return 0n;
        const value = parseDecimal(raw, t.marks);
        if (value === null) throw new BooksFileError('invalid_value', `"${raw}" in ${column} is not an amount`, row);
        return value;
      };

      const status = cell('status').toLowerCase();
      if (status !== '' && status !== 'posted') {
        violations.push({ rule: 'not_posted', message: `a line of an entry that is ${status}, not posted; export the posted entries only`, row });
        continue;
      }
      const number = (fields[key] ?? '').trim();
      const display = cell('account');
      if (number === '' || display === '') {
        violations.push({ rule: 'required', message: 'a line names no entry or no account and was left out', row });
        continue;
      }
      const date = isoDate(cell('date'), row);
      const account = accountOf(display);
      if (!accounts.has(account)) {
        const space = display.indexOf(' ');
        accounts.set(account, { code: account, name: space === -1 ? null : display.slice(space + 1).trim() || null, type: null });
      }
      const partner = cell('partner');
      if (partner !== '' && !contacts.has(partner)) {
        contacts.set(partner, { code: partner, name: partner, vatNumber: null, registrationNumber: null, email: null, country: null });
      }
      const companyCurrency = cell('companyCurrency');
      if (companyCurrency !== '') currencies.add(companyCurrency.toUpperCase());

      let debit = amount('debit');
      let credit = amount('credit');
      if (debit !== 0n && credit !== 0n) violations.push({ rule: 'one_side', message: 'a line carries both a debit and a credit', row });
      if (debit < 0n) {
        credit -= debit;
        debit = 0n;
      }
      if (credit < 0n) {
        debit -= credit;
        credit = 0n;
      }
      const currency = cell('currency').toUpperCase();
      const inCurrency = cell('amountCurrency') === '' ? null : amount('amountCurrency');
      const label = cell('label');
      const line: ImportedLine = {
        account,
        contact: partner === '' ? null : partner,
        label: label === '' ? null : label,
        debit: formatDecimal(debit),
        credit: formatDecimal(credit),
        currency: currency === '' ? null : currency,
        amountCurrency: inCurrency === null ? null : formatDecimal(inCurrency < 0n ? -inCurrency : inCurrency),
        dueDate: cell('dueDate') === '' ? null : isoDate(cell('dueDate'), row),
        matching: cell('matching') === '' ? null : cell('matching'),
      };

      let entry = entries.get(number);
      if (entry === undefined) {
        const journal = cell('journal');
        const reference = cell('reference');
        entry = {
          journal: journal === '' ? null : journal,
          journalName: journal === '' ? null : journal,
          number,
          date,
          reference: reference === '' ? null : reference,
          description: line.label,
          lines: [],
          row,
          debits: 0n,
          credits: 0n,
        };
        entries.set(number, entry);
      } else if (entry.date !== date) {
        violations.push({ rule: 'one_date', message: `entry ${number} is dated ${entry.date} on its first line and ${date} here`, row });
      }
      entry.lines.push(line);
      entry.debits += debit;
      entry.credits += credit;
    }
  }

  const read: ImportedEntry[] = [];
  for (const { debits, credits, ...entry } of entries.values()) {
    if (debits !== credits) {
      violations.push({
        rule: 'balance',
        message: `entry ${entry.number} has debit ${formatDecimal(debits)} and credit ${formatDecimal(credits)}`,
        row: entry.row,
      });
    }
    read.push(entry);
  }
  if (currencies.size > 1) {
    violations.push({ rule: 'one_currency', message: `the lines are in several company currencies (${[...currencies].join(', ')}); export one company at a time`, row: null });
  }

  return {
    format: 'journal-items',
    currency: currencies.size === 1 ? ([...currencies][0] as string) : null,
    accounts: [...accounts.values()],
    contacts: [...contacts.values()],
    entries: read,
    opening: [],
    violations,
  };
}

/** `YYYY-MM-DD`, or the same followed by a time, refusing anything else. */
function isoDate(value: string, row: number): string {
  const match = /^(\d{4})-(\d{2})-(\d{2})(?:[ T].*)?$/.exec(value);
  if (match === null) throw new BooksFileError('invalid_value', `"${value}" is not a date written YYYY-MM-DD`, row);
  const iso = `${match[1]}-${match[2]}-${match[3]}`;
  const parsed = new Date(`${iso}T00:00:00Z`);
  if (Number.isNaN(parsed.getTime()) || parsed.toISOString().slice(0, 10) !== iso) {
    throw new BooksFileError('invalid_value', `${value} is not a date of the calendar`, row);
  }
  return iso;
}
