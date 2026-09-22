/**
 * The FEC read back: the file this package writes, and the one any French
 * accounting package hands over when it is asked for the books of a year.
 *
 * The columns are found **by their names in the header**, which the arrêté
 * makes mandatory, and not by position: the variants of the text — the one of
 * a cash-basis taxpayer adds four columns, one variant carries a `Montant` and
 * a `Sens` instead of `Debit` and `Credit` — differ in what they add, never in
 * the names of what they share. The separator is the one the header uses, a
 * tab or a vertical bar, the two the text allows. The dates are `AAAAMMJJ`;
 * an amount has a comma or a point as its decimal mark, and nothing else.
 */

import { formatDecimal, parseDecimal } from './decimal.js';
import { BooksFileError } from './errors.js';
import { decode } from './text.js';
import type {
  ImportedAccount,
  ImportedBooks,
  ImportedContact,
  ImportedEntry,
  ImportedLine,
  ReadOptions,
  Violation,
} from './types.js';

export type {
  Encoding,
  ImportedAccount,
  ImportedBooks,
  ImportedContact,
  ImportedEntry,
  ImportedLine,
  ReadOptions,
  Violation,
} from './types.js';
export { BooksFileError, type BooksFileErrorCode } from './errors.js';

const DEFAULTS = { encoding: 'utf-8', maxBytes: 256 * 1024 * 1024 } as const;

/** The columns an entry cannot be read without. `Debit`/`Credit` or `Montant`/`Sens` come on top. */
const REQUIRED = ['JournalCode', 'EcritureNum', 'EcritureDate', 'CompteNum'] as const;

/**
 * Reads a FEC. Entries are the lines that share a `JournalCode` and an
 * `EcritureNum`, in the order the file first names them; each line keeps its
 * sub-ledger party (`CompAuxNum`, `CompAuxLib`), its currency amount
 * (`Montantdevise`, `Idevise`) and its reconciliation mark (`EcritureLet`).
 *
 * What does not add up comes back in `violations`, and the entry comes back
 * as the file wrote it: an entry that does not balance, a line with both a
 * debit and a credit, an entry spread over two dates. Nothing is corrected.
 */
export function readFec(input: string | Uint8Array, options: ReadOptions = {}): ImportedBooks {
  const text = decode(input, options.encoding ?? DEFAULTS.encoding, options.maxBytes ?? DEFAULTS.maxBytes);
  const lines = text.split(/\r\n|\n|\r/);
  while (lines.length > 0 && lines[lines.length - 1] === '') lines.pop();
  const headerLine = lines[0];
  if (headerLine === undefined || headerLine.trim() === '') throw new BooksFileError('empty_file', 'the file is empty');

  const separator = headerLine.includes('\t') ? '\t' : headerLine.includes('|') ? '|' : null;
  if (separator === null) {
    throw new BooksFileError('missing_column', 'the header is separated by neither a tab nor a vertical bar, the two separators the FEC allows', 1);
  }
  const header = headerLine.split(separator).map((cell) => cell.trim());
  const at = (name: string): number | undefined => {
    const index = header.findIndex((cell) => cell.toLowerCase() === name.toLowerCase());
    return index === -1 ? undefined : index;
  };
  for (const name of REQUIRED) {
    if (at(name) === undefined) throw new BooksFileError('missing_column', `the header has no ${name} column`, 1);
  }
  const bySides = at('Debit') !== undefined && at('Credit') !== undefined;
  const bySense = at('Montant') !== undefined && at('Sens') !== undefined;
  if (!bySides && !bySense) {
    throw new BooksFileError('missing_column', 'the header has neither Debit and Credit nor Montant and Sens', 1);
  }
  if (lines.length < 2) throw new BooksFileError('empty_file', 'the file has a header and no line under it', 1);

  const accounts = new Map<string, ImportedAccount>();
  const contacts = new Map<string, ImportedContact>();
  const entries = new Map<string, ImportedEntry & { debits: bigint; credits: bigint }>();
  const violations: Violation[] = [];

  for (let index = 1; index < lines.length; index += 1) {
    const row = index + 1;
    const raw = lines[index] as string;
    if (raw.trim() === '') continue;
    const fields = raw.split(separator);
    const cell = (name: string): string => {
      const position = at(name);
      return position === undefined ? '' : (fields[position] ?? '').trim();
    };
    const amount = (name: string): bigint => {
      const value = cell(name);
      if (value === '') return 0n;
      const parsed = parseDecimal(value, ['.', ',']);
      if (parsed === null) throw new BooksFileError('invalid_value', `"${value}" in ${name} is not an amount`, row);
      return parsed;
    };

    const journal = cell('JournalCode');
    const number = cell('EcritureNum');
    const date = fecDate(cell('EcritureDate'), 'EcritureDate', row);
    const account = cell('CompteNum');
    if (journal === '' || number === '' || account === '') {
      violations.push({ rule: 'required', message: 'a line lacks its JournalCode, EcritureNum or CompteNum and was left out', row });
      continue;
    }

    let debit: bigint;
    let credit: bigint;
    if (bySides) {
      debit = amount('Debit');
      credit = amount('Credit');
    } else {
      const value = amount('Montant');
      const sense = cell('Sens').toUpperCase();
      if (sense !== 'D' && sense !== 'C' && sense !== '+1' && sense !== '-1') {
        throw new BooksFileError('invalid_value', `"${cell('Sens')}" in Sens is none of D, C, +1, -1`, row);
      }
      const isDebit = sense === 'D' || sense === '+1';
      debit = isDebit ? value : 0n;
      credit = isDebit ? 0n : value;
    }
    if (debit !== 0n && credit !== 0n) {
      violations.push({ rule: 'one_side', message: 'a line carries both a debit and a credit', row });
    }
    // A negative amount is the other side, which is how a reversal is written
    // where the software does not flip it.
    if (debit < 0n) {
      credit -= debit;
      debit = 0n;
    }
    if (credit < 0n) {
      debit -= credit;
      credit = 0n;
    }

    if (!accounts.has(account)) {
      const name = cell('CompteLib');
      accounts.set(account, { code: account, name: name === '' ? null : name, type: null });
    }
    const party = cell('CompAuxNum');
    if (party !== '' && !contacts.has(party)) {
      const name = cell('CompAuxLib');
      contacts.set(party, {
        code: party,
        name: name === '' ? party : name,
        vatNumber: null,
        registrationNumber: null,
        email: null,
        country: null,
      });
    }

    const foreign = cell('Idevise');
    const foreignAmount = cell('Montantdevise');
    let amountCurrency: string | null = null;
    if (foreign !== '' && foreignAmount !== '') {
      const parsed = amount('Montantdevise');
      amountCurrency = formatDecimal(parsed < 0n ? -parsed : parsed);
    }
    const label = cell('EcritureLib');
    const line: ImportedLine = {
      account,
      contact: party === '' ? null : party,
      label: label === '' ? null : label,
      debit: formatDecimal(debit),
      credit: formatDecimal(credit),
      currency: foreign === '' ? null : foreign.toUpperCase(),
      amountCurrency,
      dueDate: null,
      matching: cell('EcritureLet') === '' ? null : cell('EcritureLet'),
    };

    const key = `${journal}\u0000${number}`;
    let entry = entries.get(key);
    if (entry === undefined) {
      const reference = cell('PieceRef');
      const journalName = cell('JournalLib');
      entry = {
        journal,
        journalName: journalName === '' ? null : journalName,
        number,
        date,
        reference: reference === '' ? null : reference,
        description: line.label,
        lines: [],
        row,
        debits: 0n,
        credits: 0n,
      };
      entries.set(key, entry);
    } else if (entry.date !== date) {
      violations.push({
        rule: 'one_date',
        message: `entry ${journal} ${number} is dated ${entry.date} on its first line and ${date} here; it is booked on the first`,
        row,
      });
    }
    entry.lines.push(line);
    entry.debits += debit;
    entry.credits += credit;
  }

  const read: ImportedEntry[] = [];
  for (const { debits, credits, ...entry } of entries.values()) {
    if (debits !== credits) {
      violations.push({
        rule: 'balance',
        message: `entry ${entry.journal} ${entry.number} has debit ${formatDecimal(debits)} and credit ${formatDecimal(credits)}`,
        row: entry.row,
      });
    }
    read.push(entry);
  }

  return {
    format: 'fec',
    // The FEC is kept in the currency of the books and never says which one.
    currency: null,
    accounts: [...accounts.values()],
    contacts: [...contacts.values()],
    entries: read,
    opening: [],
    violations,
  };
}

/** `AAAAMMJJ` to `YYYY-MM-DD`, refusing a date that does not exist. */
function fecDate(value: string, column: string, row: number): string {
  const match = /^(\d{4})(\d{2})(\d{2})$/.exec(value);
  if (match === null) throw new BooksFileError('invalid_value', `"${value}" in ${column} is not a date written AAAAMMJJ`, row);
  const iso = `${match[1]}-${match[2]}-${match[3]}`;
  const parsed = new Date(`${iso}T00:00:00Z`);
  if (Number.isNaN(parsed.getTime()) || parsed.toISOString().slice(0, 10) !== iso) {
    throw new BooksFileError('invalid_value', `${value} in ${column} is not a date of the calendar`, row);
  }
  return iso;
}
