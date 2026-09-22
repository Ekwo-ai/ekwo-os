/**
 * A journal report, or a general ledger detail, saved as CSV: the report a
 * cloud accounting service prints of every journal it posted, one row per
 * line, with the number of the journal the line belongs to. Such a service
 * exports its reports to a spreadsheet and not to CSV; the spreadsheet is
 * saved as CSV, and that file is what this reads — beside it, the chart of
 * accounts and the contacts, which the same service exports as CSV directly.
 *
 * A report is laid out for a person: a few rows of title before the header,
 * rows that head a group or total it, rows of opening and closing balance. So
 * the header is **the first row that names a date, an account code, a debit
 * and a credit**, and a line is **a row whose date cell holds a date**; every
 * other row is a heading or a total and is passed over. Lines are gathered
 * into entries by their journal number, which the report has to carry.
 *
 * A date the report wrote as digits in an order nobody can read off the digits
 * — `03/04/2026` — is read in the order the caller names, and refused without
 * one: which order a report uses follows the region of the organisation, and
 * the file does not say it. A date with the month in letters, or in ISO, needs
 * no order.
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

export interface JournalReportOptions extends ReadOptions {
  /** How a date written only in digits is to be read. Required when the report writes one; never guessed. */
  dateOrder?: DateOrder;
}

/** The columns of the report, each under the names it may carry. */
export const REPORT_COLUMNS = {
  date: ['date'],
  journal: ['journal id', 'journal number', 'journal no.', 'journal no', 'journal #', 'journal'],
  source: ['source', 'source type'],
  accountCode: ['account code'],
  account: ['account', 'account name'],
  description: ['description'],
  narration: ['narration'],
  reference: ['reference'],
  contact: ['contact', 'contact name'],
  debit: ['debit'],
  credit: ['credit'],
} as const;

/** The columns of the chart of accounts. */
export const CHART_COLUMNS = {
  code: ['code', 'account code'],
  name: ['name', 'account name'],
  type: ['type', 'account type'],
} as const;

/** The columns of the contacts. */
export const CONTACT_COLUMNS = {
  name: ['contactname', 'contact name'],
  accountNumber: ['accountnumber', 'account number'],
  email: ['emailaddress', 'email address', 'email'],
  tax: ['taxnumber', 'tax number'],
  company: ['companynumber', 'company number'],
  country: ['pocountry', 'sacountry'],
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

interface Sheet {
  file: number;
  separator: string;
  rows: { row: number; fields: string[] }[];
}

const has = (keys: string[], names: readonly string[]): boolean => keys.some((key) => names.includes(key));

function isReportHeader(keys: string[]): boolean {
  return has(keys, REPORT_COLUMNS.date) && has(keys, REPORT_COLUMNS.accountCode) && has(keys, REPORT_COLUMNS.debit) && has(keys, REPORT_COLUMNS.credit);
}

/**
 * Reads the files — the report, and optionally the chart of accounts and the
 * contacts — in any order, each recognised by its header.
 */
export function readJournalReport(inputs: readonly (string | Uint8Array)[], options: JournalReportOptions = {}): ImportedBooks {
  const sheets: Sheet[] = inputs.map((input, index) => {
    const text = decode(input, options.encoding ?? DEFAULTS.encoding, options.maxBytes ?? DEFAULTS.maxBytes);
    // The title rows above the header may hold no separator at all, so the
    // separator is read from the first line that holds one.
    const firstWithSeparator = text.split(/\r?\n/).find((line) => /[,;\t]/.test(line)) ?? '';
    const separator = separatorOf(firstWithSeparator);
    return { file: index + 1, separator, rows: parseCsv(text, separator) };
  });

  const violations: Violation[] = [];
  const accounts = new Map<string, ImportedAccount>();
  const contacts = new Map<string, ImportedContact>();
  const reports: { sheet: Sheet; headerAt: number }[] = [];

  for (const sheet of sheets) {
    const headerAt = sheet.rows.findIndex((r) => isReportHeader(r.fields.map(headerKey)));
    if (headerAt !== -1) {
      reports.push({ sheet, headerAt });
      continue;
    }
    const header = sheet.rows[0];
    if (header === undefined) throw new BooksFileError('empty_file', `file ${sheet.file} is empty`);
    const keys = header.fields.map(headerKey);
    if (has(keys, CHART_COLUMNS.code) && has(keys, CHART_COLUMNS.type)) {
      const at = locate(keys, CHART_COLUMNS);
      for (const { fields } of sheet.rows.slice(1)) {
        const code = (fields[at.code as number] ?? '').trim();
        if (code === '') continue;
        const name = at.name === undefined ? '' : (fields[at.name] ?? '').trim();
        const type = at.type === undefined ? '' : (fields[at.type] ?? '').trim();
        accounts.set(code, { code, name: name === '' ? null : name, type: type === '' ? null : type });
      }
    } else if (has(keys, CONTACT_COLUMNS.name)) {
      const at = locate(keys, CONTACT_COLUMNS);
      for (const { fields } of sheet.rows.slice(1)) {
        const cell = (column: keyof typeof CONTACT_COLUMNS): string => {
          const index = at[column];
          return index === undefined ? '' : (fields[index] ?? '').trim();
        };
        const name = cell('name');
        if (name === '') continue;
        const country = cell('country').toUpperCase();
        contacts.set(name, {
          code: name,
          name,
          vatNumber: cell('tax') === '' ? null : cell('tax'),
          registrationNumber: cell('company') === '' ? null : cell('company'),
          email: cell('email') === '' ? null : cell('email'),
          country: /^[A-Z]{2}$/.test(country) ? country : null,
        });
      }
    } else {
      throw new BooksFileError(
        'missing_column',
        `file ${sheet.file} is neither a report (a header with Date, Account Code, Debit and Credit), a chart of accounts (Code, Type) nor contacts (ContactName)`,
      );
    }
  }
  if (reports.length === 0) {
    throw new BooksFileError('missing_column', 'no file is a report: one needs a header row with Date, Account Code, Debit and Credit');
  }

  const entries = new Map<string, ImportedEntry & { debits: bigint; credits: bigint }>();
  for (const { sheet, headerAt } of reports) {
    const header = sheet.rows[headerAt] as { row: number; fields: string[] };
    const at = locate(header.fields.map(headerKey), REPORT_COLUMNS);
    if (at.journal === undefined) {
      throw new BooksFileError(
        'missing_column',
        `the report in file ${sheet.file} carries no journal number, and without it its lines cannot be put back into entries. Add the Journal ID column to the report before exporting it`,
        header.row,
      );
    }
    for (const { row, fields } of sheet.rows.slice(headerAt + 1)) {
      const cell = (column: keyof typeof REPORT_COLUMNS): string => {
        const index = at[column];
        return index === undefined ? '' : (fields[index] ?? '').trim();
      };
      const date = readDate(cell('date'), options.dateOrder, row);
      if (date === null) continue; // a heading, a total, a balance: not a line
      const journal = cell('journal');
      const account = cell('accountCode');
      if (journal === '' || account === '') {
        violations.push({ rule: 'required', message: 'a dated line names no journal number or no account code and was left out', row });
        continue;
      }
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
      if (!accounts.has(account)) {
        const name = cell('account');
        accounts.set(account, { code: account, name: name === '' ? null : name, type: null });
      }
      const contact = cell('contact');
      if (contact !== '' && !contacts.has(contact)) {
        contacts.set(contact, { code: contact, name: contact, vatNumber: null, registrationNumber: null, email: null, country: null });
      }
      const label = cell('description');
      const line: ImportedLine = {
        account,
        contact: contact === '' ? null : contact,
        label: label === '' ? null : label,
        debit: formatDecimal(debit),
        credit: formatDecimal(credit),
        currency: null,
        amountCurrency: null,
        dueDate: null,
        matching: null,
      };
      let entry = entries.get(journal);
      if (entry === undefined) {
        const source = cell('source');
        const reference = cell('reference');
        const narration = cell('narration');
        entry = {
          journal: source === '' ? null : source,
          journalName: source === '' ? null : source,
          number: journal,
          date,
          reference: reference === '' ? null : reference,
          description: narration !== '' ? narration : line.label,
          lines: [],
          row,
          debits: 0n,
          credits: 0n,
        };
        entries.set(journal, entry);
      } else if (entry.date !== date) {
        violations.push({ rule: 'one_date', message: `journal ${journal} is dated ${entry.date} on its first line and ${date} here`, row });
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
        message: `journal ${entry.number} has debit ${formatDecimal(debits)} and credit ${formatDecimal(credits)}`,
        row: entry.row,
      });
    }
    read.push(entry);
  }
  if (read.length === 0) throw new BooksFileError('empty_file', 'the report holds no dated line');

  return {
    format: 'journal-report',
    // A report prints amounts in the currency of the organisation and does not say which.
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
 * A date, or null for a cell that is not one — which is how a heading or a
 * total row is told from a line. A cell that looks like a date and is not a
 * day of the calendar is refused, never passed over.
 */
export function readDate(value: string, order: DateOrder | undefined, row: number): string | null {
  let y: number;
  let m: number;
  let d: number;
  let match: RegExpExecArray | null;
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
 * minus or brackets. Anything else is refused.
 */
export function amount(raw: string, separator: string, row: number): bigint {
  let value = raw.replace(/[  ]/g, ' ').trim();
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
