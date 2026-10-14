/**
 * The open items that go with a trial balance, written as CSV: one row per
 * invoice or credit note still open on the day the balance is drawn up — its
 * number, the party, the amount still open, the day it was issued, the day it
 * falls due, the reference a payment of it will quote.
 *
 * It is the aged balance every package prints beside its trial balance. The
 * trial balance says what the receivable account holds; this says who owes
 * it, under which number. Like the balance, it reads no database and knows no
 * chart: whatever takes it decides which account an item falls on.
 */

import { decode, headerKey, parseCsv, separatorOf } from './csv.js';
import { formatDecimal, parseDecimal, type DecimalMark } from './decimal.js';
import { BooksFileError } from './errors.js';
import type { Decimal, ImportedContact, IsoDate, ReadOptions, Violation } from './types.js';

const DEFAULTS = { encoding: 'utf-8', maxBytes: 64 * 1024 * 1024 } as const;

/** What an open item is, in the words of the documents it becomes. */
export const OPEN_ITEM_TYPES = ['sale_invoice', 'sale_credit_note', 'purchase_invoice', 'purchase_credit_note'] as const;
export type OpenItemType = (typeof OPEN_ITEM_TYPES)[number];

/** One invoice or credit note still open on the day the balance is drawn up. */
export interface ImportedOpenItem {
  type: OpenItemType;
  number: string;
  /** The `code` of an {@link ImportedContact}. */
  contact: string;
  /** What is still open of it, never negative: the type says the side. */
  amount: Decimal;
  /** The day it was issued. */
  documentDate: IsoDate;
  dueDate: IsoDate | null;
  /** The reference a payment of it quotes — a structured one where the country has them. */
  paymentReference: string | null;
  /** On a purchase, the supplier's own number. */
  supplierReference: string | null;
  label: string | null;
  /** The row of the file, from 1, for a message. */
  row: number;
}

export interface ImportedOpenItems {
  items: ImportedOpenItem[];
  contacts: ImportedContact[];
  violations: Violation[];
}

/** The columns this reader knows, each under the names it accepts in a header. */
export const OPEN_ITEM_COLUMNS = {
  type: ['type', 'document type'],
  number: ['number', 'document number', 'invoice number'],
  contact: ['contact', 'party'],
  contactName: ['contact name', 'party name'],
  amount: ['amount', 'open amount', 'amount open'],
  documentDate: ['document date', 'issue date', 'date'],
  dueDate: ['due date'],
  paymentReference: ['payment reference', 'structured reference'],
  supplierReference: ['supplier reference'],
  label: ['label', 'description'],
} as const;

type Column = keyof typeof OPEN_ITEM_COLUMNS;

const REQUIRED: Column[] = ['type', 'number', 'contact', 'amount', 'documentDate'];

/**
 * Reads the file. A date is written `YYYY-MM-DD` and nothing else: a day
 * written in digits only is read differently on each side of an ocean, and is
 * refused rather than guessed. An amount is positive; the type says the side.
 * A row that lacks a value the item needs comes back as a violation and is
 * left out, so that nothing is booked from a list that does not read whole.
 */
export function readOpenItems(input: string | Uint8Array, options: ReadOptions = {}): ImportedOpenItems {
  const text = decode(input, options.encoding ?? DEFAULTS.encoding, options.maxBytes ?? DEFAULTS.maxBytes);
  const firstLine = text.split(/\r?\n/, 1)[0] ?? '';
  const separator = separatorOf(firstLine);
  const rows = parseCsv(text, separator);
  const header = rows.shift();
  if (header === undefined) throw new BooksFileError('empty_file', 'the file is empty');

  const keys = header.fields.map(headerKey);
  const at: Partial<Record<Column, number>> = {};
  for (const [column, names] of Object.entries(OPEN_ITEM_COLUMNS) as [Column, readonly string[]][]) {
    const found = keys.findIndex((key) => names.includes(key));
    if (found !== -1) at[column] = found;
  }
  for (const column of REQUIRED) {
    if (at[column] === undefined) {
      throw new BooksFileError('missing_column', `the header names no ${OPEN_ITEM_COLUMNS[column][0]} column; it needs one of: ${OPEN_ITEM_COLUMNS[column].join(', ')}`, header.row);
    }
  }
  if (rows.length === 0) throw new BooksFileError('empty_file', 'the file has a header and no row under it', header.row);

  const marks: DecimalMark[] = separator === ',' ? ['.'] : ['.', ','];
  const cell = (fields: string[], column: Column): string => {
    const index = at[column];
    return index === undefined ? '' : (fields[index] ?? '').trim();
  };
  const date = (fields: string[], column: Column, row: number): IsoDate | null => {
    const raw = cell(fields, column);
    if (raw === '') return null;
    const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(raw);
    const day = match === null ? null : new Date(`${raw}T00:00:00Z`);
    if (day === null || Number.isNaN(day.getTime()) || day.toISOString().slice(0, 10) !== raw) {
      throw new BooksFileError('invalid_value', `"${raw}" in the ${OPEN_ITEM_COLUMNS[column][0]} column is not a day written YYYY-MM-DD`, row);
    }
    return raw;
  };

  const items: ImportedOpenItem[] = [];
  const contacts = new Map<string, ImportedContact>();
  const violations: Violation[] = [];

  for (const { row, fields } of rows) {
    if (fields.every((field) => field.trim() === '')) continue;
    const missing = REQUIRED.filter((column) => cell(fields, column) === '');
    if (missing.length > 0) {
      violations.push({
        rule: 'item_incomplete',
        message: `an open item has no ${missing.map((column) => OPEN_ITEM_COLUMNS[column][0]).join(', ')} and was left out`,
        row,
      });
      continue;
    }
    const type = cell(fields, 'type');
    if (!(OPEN_ITEM_TYPES as readonly string[]).includes(type)) {
      throw new BooksFileError('invalid_value', `"${type}" in the type column is not one of ${OPEN_ITEM_TYPES.join(', ')}`, row);
    }
    const raw = cell(fields, 'amount');
    const amount = parseDecimal(raw, marks);
    if (amount === null || amount <= 0n) {
      throw new BooksFileError(
        'invalid_value',
        `"${raw}" in the amount column is not a positive amount: the type of the item says its side, never a sign`,
        row,
      );
    }

    const contact = cell(fields, 'contact');
    if (!contacts.has(contact)) {
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
    const optional = (column: Column): string | null => {
      const value = cell(fields, column);
      return value === '' ? null : value;
    };
    items.push({
      type: type as OpenItemType,
      number: cell(fields, 'number'),
      contact,
      amount: formatDecimal(amount),
      documentDate: date(fields, 'documentDate', row) as IsoDate,
      dueDate: date(fields, 'dueDate', row),
      paymentReference: optional('paymentReference'),
      supplierReference: optional('supplierReference'),
      label: optional('label'),
      row,
    });
  }

  return { items, contacts: [...contacts.values()], violations };
}
