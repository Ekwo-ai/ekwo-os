import { decode, headerKey, parseCsv, type CsvRow } from './csv.js';
import { formatAmount, parseAmount, type NumberMarks } from './decimal.js';
import { StatementFileError } from './errors.js';
import type {
  AccountIdentifier,
  ColumnRef,
  CsvStatementColumns,
  CsvStatementProfile,
  ReadOptions,
  Statement,
  StatementBalance,
  StatementFile,
  StatementLine,
  Violation,
  ViolationCode,
} from './types.js';

export { StatementFileError, type StatementFileErrorCode } from './errors.js';
export { parseCsv, type CsvRow } from './csv.js';
export type * from './types.js';

const DEFAULTS = { maxBytes: 32 * 1024 * 1024 };
const PIVOT_YEAR = 80;

// --- the profile, checked before the file is read ------------------------------

type Role = keyof CsvStatementColumns;

/** Every role, in the order a message lists them. */
const ROLES: readonly Role[] = [
  'date',
  'valueDate',
  'amount',
  'debit',
  'credit',
  'fee',
  'currency',
  'counterparty',
  'counterpartyAccount',
  'description',
  'reference',
  'balance',
];

interface DateReader {
  pattern: RegExp;
  /** Where the year, the month and the day are among the groups, and how many digits the year has. */
  year: number;
  month: number;
  day: number;
  shortYear: boolean;
}

/** `DD/MM/YYYY` and its kind into a regular expression, or a refusal that says what is missing. */
function dateReader(format: string): DateReader {
  const tokens = format.match(/YYYY|YY|MM|DD|[^YMD]+|[YMD]+/g) ?? [];
  const separated = tokens.some((token) => !/^(YYYY|YY|MM|DD)$/.test(token));
  const order: ('year' | 'month' | 'day')[] = [];
  let shortYear = false;
  let source = '';
  for (const token of tokens) {
    if (token === 'YYYY' || token === 'YY') {
      order.push('year');
      shortYear = token === 'YY';
      source += token === 'YYYY' ? '([0-9]{4})' : '([0-9]{2})';
    } else if (token === 'MM' || token === 'DD') {
      order.push(token === 'MM' ? 'month' : 'day');
      source += separated ? '([0-9]{1,2})' : '([0-9]{2})';
    } else if (/^[YMD]+$/.test(token)) {
      throw new StatementFileError('invalid_profile', `dateFormat "${format}": "${token}" is none of DD, MM, YYYY and YY`);
    } else {
      source += token.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    }
  }
  const once = (part: 'year' | 'month' | 'day'): number => {
    const found = order.filter((item) => item === part).length;
    if (found !== 1) {
      throw new StatementFileError('invalid_profile', `dateFormat "${format}" names the ${part} ${found === 0 ? 'nowhere' : `${found} times`}: it is written with DD, MM and YYYY (or YY)`);
    }
    return order.indexOf(part) + 1;
  };
  return {
    pattern: new RegExp(`^${source}(?:[ T].*)?$`),
    year: once('year'),
    month: once('month'),
    day: once('day'),
    shortYear,
  };
}

/** A cell as `YYYY-MM-DD`: null when empty, undefined when it is not a date of the profile's format. */
function readDate(cell: string, reader: DateReader): string | null | undefined {
  const text = cell.trim();
  if (text === '') return null;
  const match = reader.pattern.exec(text);
  if (match === null) return undefined;
  let year = Number(match[reader.year]);
  if (reader.shortYear) year += year >= PIVOT_YEAR ? 1900 : 2000;
  const month = Number(match[reader.month]);
  const day = Number(match[reader.day]);
  if (month < 1 || month > 12 || day < 1) return undefined;
  const leap = (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
  const length = [31, leap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1] as number;
  if (day > length) return undefined;
  return `${String(year).padStart(4, '0')}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
}

function checkProfile(profile: CsvStatementProfile): void {
  const refuse = (message: string): never => {
    throw new StatementFileError('invalid_profile', message);
  };
  if (profile === null || typeof profile !== 'object') refuse('no profile: a CSV is read with the profile of its columns');
  if (typeof profile.delimiter !== 'string' || [...profile.delimiter].length !== 1) {
    refuse(`delimiter "${String(profile.delimiter)}": one character, the one between two fields`);
  }
  if (profile.delimiter === '"' || profile.delimiter === '\n' || profile.delimiter === '\r') {
    refuse('the delimiter cannot be a quote or a line break');
  }
  if (profile.decimalSeparator !== '.' && profile.decimalSeparator !== ',') {
    refuse(`decimalSeparator "${String(profile.decimalSeparator)}": "." or ","`);
  }
  const thousands = profile.thousandsSeparator ?? '';
  if (thousands === profile.decimalSeparator || /[0-9+\-()]/.test(thousands) || [...thousands].length > 1) {
    refuse(`thousandsSeparator "${thousands}": one character that is not the decimal mark, a digit or a sign`);
  }
  if (profile.encoding !== undefined && !['utf-8', 'iso-8859-1', 'windows-1252'].includes(profile.encoding)) {
    refuse(`encoding "${String(profile.encoding)}": utf-8, iso-8859-1 or windows-1252`);
  }
  if (profile.sign !== undefined && profile.sign !== 'as-written' && profile.sign !== 'inverted') {
    refuse(`sign "${String(profile.sign)}": as-written or inverted`);
  }
  for (const count of ['skipRows', 'skipFooterRows'] as const) {
    const value = profile[count];
    if (value !== undefined && (!Number.isInteger(value) || value < 0)) refuse(`${count} ${String(value)}: a whole number, 0 or more`);
  }
  if (typeof profile.dateFormat !== 'string' || profile.dateFormat === '') refuse('no dateFormat: say how a date is written, as DD/MM/YYYY');
  const columns = profile.columns;
  if (columns === null || typeof columns !== 'object') refuse('no columns: say at least which column is the date and which the amount');
  for (const role of Object.keys(columns)) {
    if (!(ROLES as readonly string[]).includes(role)) refuse(`columns.${role}: no such role; the roles are ${ROLES.join(', ')}`);
  }
  if (columns.date === undefined) refuse('columns.date: the date of a movement is required');
  const hasAmount = columns.amount !== undefined;
  const hasSides = columns.debit !== undefined || columns.credit !== undefined;
  if (hasAmount === hasSides) {
    refuse(
      hasAmount
        ? 'columns: an amount, or a debit and a credit — not both'
        : 'columns: no amount — name the amount column, or the debit and the credit columns',
    );
  }
  for (const role of ROLES) {
    const value = columns[role];
    if (value === undefined) continue;
    for (const ref of Array.isArray(value) ? value : [value]) {
      if (typeof ref === 'number') {
        if (!Number.isInteger(ref) || ref < 1) refuse(`columns.${role}: position ${ref} — positions count from 1`);
      } else if (typeof ref !== 'string' || ref.trim() === '') {
        refuse(`columns.${role}: a header, or a position counted from 1`);
      } else if (profile.header === false) {
        refuse(`columns.${role}: "${ref}" is a header, and the profile says the file has none — name it by its position`);
      }
    }
  }
}

/** Every column the profile names, as an index into a row, from 0. */
function locate(header: string[] | null): (ref: ColumnRef) => number {
  const keys = header?.map(headerKey) ?? [];
  return (ref) => {
    if (typeof ref === 'number') return ref - 1;
    const key = headerKey(ref);
    const first = keys.indexOf(key);
    if (first < 0) {
      throw new StatementFileError(
        'missing_column',
        `no column "${ref}" in the header; it has ${header?.map((cell) => `"${cell.trim()}"`).join(', ') ?? 'none'}`,
        null,
      );
    }
    if (keys.indexOf(key, first + 1) >= 0) {
      throw new StatementFileError('missing_column', `the header holds "${ref}" twice: name the one meant by its position`);
    }
    return first;
  };
}

// --- small readers -------------------------------------------------------------

/** ISO 7064 MOD 97-10 over a string of digits and letters (A = 10 … Z = 35). */
function mod97(text: string): number {
  let remainder = 0;
  for (const character of text) {
    const code = character.charCodeAt(0);
    const value = code >= 65 ? code - 55 : code - 48;
    remainder = (value > 9 ? remainder * 100 + value : remainder * 10 + value) % 97;
  }
  return remainder;
}

/** ISO 13616: move four characters to the end, letters to numbers, mod 97 is 1. */
export function isValidIban(iban: string): boolean {
  if (!/^[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}$/.test(iban)) return false;
  return mod97(iban.slice(4) + iban.slice(0, 4)) === 1;
}

/** An account as given: an IBAN when it passes ISO 13616, else what was written. */
function identifierOf(text: string | null | undefined): AccountIdentifier | null {
  const value = (text ?? '').replace(/\s+/g, '').toUpperCase();
  if (value === '') return null;
  if (isValidIban(value)) return { kind: 'iban', value };
  return { kind: 'other', value: (text ?? '').replace(/\s+/g, ''), scheme: null, issuer: null };
}

/** Lines `0 … count-1` of the text gone, and how many lines that was. */
function dropLines(text: string, count: number): string {
  let at = 0;
  for (let i = 0; i < count; i += 1) {
    const next = text.slice(at).search(/\r\n|\n|\r/);
    if (next < 0) return '';
    at += next + (text.slice(at + next, at + next + 2) === '\r\n' ? 2 : 1);
  }
  return text.slice(at);
}

// --- the reader ------------------------------------------------------------------

interface Movement {
  row: number;
  bookingDate: string | null;
  valueDate: string | null;
  amount: bigint | null;
  fee: bigint | null;
  currency: string | null;
  counterparty: string | null;
  counterpartyAccount: string | null;
  description: string[];
  reference: string | null;
  balance: bigint | null;
}

/**
 * Read a statement exported as CSV — a string, or the bytes as they came —
 * with the profile of its columns, into one statement, its lines, and what
 * does not add up.
 *
 * Throws a `StatementFileError` for what cannot be read at all: a profile that
 * describes no statement, a header without a column the profile names, an
 * encoding that is not the one named, a quote never closed. Everything else
 * comes back, with the trouble named in `violations` and nothing silently
 * repaired: a running balance that does not follow from the row before is
 * returned as the file wrote it, and reported.
 */
export function readCsvStatement(
  input: string | Uint8Array,
  profile: CsvStatementProfile,
  options: ReadOptions = {},
): StatementFile {
  checkProfile(profile);
  const dates = dateReader(profile.dateFormat);
  const marks: NumberMarks = { decimal: profile.decimalSeparator, thousands: profile.thousandsSeparator ?? '' };
  const inverted = profile.sign === 'inverted';
  const skipRows = profile.skipRows ?? 0;

  const text = decode(input, profile.encoding ?? 'utf-8', options.maxBytes ?? DEFAULTS.maxBytes);
  if (text.trim() === '') throw new StatementFileError('empty_file', 'the file is empty');
  const parsed = parseCsv(dropLines(text, skipRows), profile.delimiter).map(
    (row): CsvRow => ({ row: row.row + skipRows, fields: row.fields }),
  );
  const header = profile.header === false ? null : (parsed.shift()?.fields ?? null);
  const body = parsed.slice(0, Math.max(0, parsed.length - (profile.skipFooterRows ?? 0)));
  const at = locate(header);
  const columns = profile.columns;
  const index = Object.fromEntries(
    ROLES.filter((role) => role !== 'description' && columns[role] !== undefined).map((role) => [role, at(columns[role] as ColumnRef)]),
  ) as Partial<Record<Exclude<Role, 'description'>, number>>;
  const describedBy = (columns.description === undefined ? [] : Array.isArray(columns.description) ? columns.description : [columns.description]).map(at);
  const feeLabel = index.fee !== undefined && header !== null ? (header[index.fee]?.trim() || null) : null;
  if (body.length === 0) {
    throw new StatementFileError('empty_file', header === null ? 'no row to read' : 'a header and no row under it');
  }

  const violations: Violation[] = [];
  const report = (code: ViolationCode, message: string, where: { line?: number; row?: number } = {}): void => {
    violations.push({ code, message, statement: 1, ...where });
  };
  const cell = (row: CsvRow, role: Exclude<Role, 'description'>): string | null => {
    const position = index[role];
    if (position === undefined) return null;
    const value = (row.fields[position] ?? '').trim();
    return value === '' ? null : value;
  };
  const amountOf = (row: CsvRow, role: 'amount' | 'debit' | 'credit' | 'fee' | 'balance'): bigint | null | undefined => {
    const value = cell(row, role);
    if (value === null) return null;
    const parsedAmount = parseAmount(value, marks);
    if (parsedAmount === null) {
      report(
        'invalid_amount',
        `row ${row.row}: the ${role} "${value}" is not an amount written with "${marks.decimal}" for decimals${marks.thousands === '' ? '' : ` and "${marks.thousands}" between thousands`}`,
        { row: row.row },
      );
      return undefined;
    }
    return parsedAmount;
  };
  const dateOf = (row: CsvRow, role: 'date' | 'valueDate'): string | null => {
    const value = cell(row, role);
    if (value === null) return null;
    const read = readDate(value, dates);
    if (read === undefined) {
      report('invalid_date', `row ${row.row}: the ${role === 'date' ? 'date' : 'value date'} "${value}" is not a date written ${profile.dateFormat}`, {
        row: row.row,
      });
      return null;
    }
    return read;
  };
  const signed = (value: bigint | null | undefined): bigint | null | undefined =>
    value === null || value === undefined || !inverted ? value : -value;

  // 1. Every row as a movement, in the order of time.
  const ordered = profile.newestFirst === true ? [...body].reverse() : body;
  const movements: Movement[] = [];
  let unreadable = false;
  for (const row of ordered) {
    let amount: bigint | null | undefined;
    if (index.amount !== undefined) amount = signed(amountOf(row, 'amount'));
    else {
      const debit = amountOf(row, 'debit');
      const credit = amountOf(row, 'credit');
      const abs = (value: bigint): bigint => (value < 0n ? -value : value);
      amount =
        debit === undefined || credit === undefined
          ? undefined
          : debit === null && credit === null
            ? null
            : (credit === null ? 0n : abs(credit)) - (debit === null ? 0n : abs(debit));
    }
    if (amount === null) report('invalid_amount', `row ${row.row}: no amount`, { row: row.row });
    if (amount === null || amount === undefined) unreadable = true;
    const fee = signed(amountOf(row, 'fee'));
    if (fee === undefined) unreadable = true;
    const balance = signed(amountOf(row, 'balance'));
    movements.push({
      row: row.row,
      bookingDate: dateOf(row, 'date'),
      valueDate: dateOf(row, 'valueDate'),
      amount: amount ?? null,
      fee: fee ?? null,
      currency: cell(row, 'currency')?.toUpperCase() ?? null,
      counterparty: cell(row, 'counterparty'),
      counterpartyAccount: cell(row, 'counterpartyAccount'),
      description: describedBy.map((position) => (row.fields[position] ?? '').trim()).filter((value) => value !== ''),
      reference: cell(row, 'reference'),
      balance: balance ?? null,
    });
  }

  // 2. The currency of the account, and the rows of another balance.
  const named = options.currency === undefined ? null : options.currency.trim().toUpperCase();
  const written = [...new Set(movements.map((movement) => movement.currency).filter((value): value is string => value !== null))];
  let kept = movements;
  let currency = named;
  if (named !== null) {
    kept = movements.filter((movement) => {
      if (movement.currency === null || movement.currency === named) return true;
      report('other_currency', `row ${movement.row} is in ${movement.currency}, and the account in ${named}: another balance, left out`, {
        row: movement.row,
      });
      return false;
    });
  } else if (written.length === 1) currency = written[0] as string;
  else if (written.length > 1) {
    report(
      'mixed_currencies',
      `the rows are in ${written.join(', ')}, and no currency was named for the account: name it, and the rows of the others are left out`,
    );
  }

  // 3. The lines: one per movement, two for a movement with a fee.
  const lines: StatementLine[] = [];
  kept.forEach((movement, entryIndex) => {
    const counterparty =
      movement.counterparty === null && movement.counterpartyAccount === null
        ? null
        : { name: movement.counterparty, account: identifierOf(movement.counterpartyAccount), agentBic: null, ultimateName: null };
    const split = movement.fee !== null && movement.fee !== 0n;
    const base = (amount: bigint | null, detail: number | null, additionalInformation: string | null): StatementLine => ({
      index: lines.length + 1,
      entry: entryIndex + 1,
      detail,
      detailCount: split ? 2 : null,
      status: 'BOOK',
      booked: true,
      reversal: false,
      bookingDate: movement.bookingDate,
      valueDate: movement.valueDate,
      amount: amount === null ? null : formatAmount(amount),
      currency: movement.currency ?? currency,
      entryAmount: null,
      bankReference: movement.reference,
      entryReference: null,
      endToEndId: null,
      transactionId: null,
      instructionId: null,
      paymentInformationId: null,
      mandateId: null,
      counterparty,
      remittance: { unstructured: movement.description, structured: [] },
      bankTransactionCode: null,
      returnReason: null,
      instructedAmount: null,
      exchangeRate: null,
      additionalInformation,
      row: movement.row,
      rowBalance: movement.balance === null ? null : formatAmount(movement.balance),
    });
    lines.push(base(movement.amount, split ? 1 : null, null));
    if (split) lines.push(base(movement.fee, 2, feeLabel));
  });
  for (const line of lines) {
    if (line.bookingDate === null && line.detail !== 2) {
      report('booking_date_missing', `row ${line.row} has no date`, { line: line.index, row: line.row });
    }
  }

  // 4. The balances: declared by the caller, or carried by the running
  //    balance; every running balance follows from the one before.
  const movedBy = (movement: Movement): bigint | null =>
    movement.amount === null ? null : movement.amount + (movement.fee ?? 0n);
  const declared = (value: string | undefined, what: string): bigint | null => {
    if (value === undefined) return null;
    const parsedValue = parseAmount(value, { decimal: '.', thousands: '' });
    if (parsedValue === null) {
      throw new StatementFileError('invalid_profile', `${what} "${value}": a decimal string, as 1250.00 or -40.10`);
    }
    return parsedValue;
  };
  const declaredOpening = declared(options.openingBalance, 'openingBalance');
  const declaredClosing = declared(options.closingBalance, 'closingBalance');

  let balanced: boolean | null = null;
  const fail = (message: string, where: { line?: number; row?: number } = {}): void => {
    balanced = false;
    report('balance_mismatch', message, where);
  };
  // A row that writes no balance carries the one before it forward.
  let running: bigint | null = null;
  let chainChecked = false;
  for (const movement of kept) {
    const moved = movedBy(movement);
    if (running !== null && moved !== null && movement.balance !== null) {
      chainChecked = true;
      if (running + moved !== movement.balance) {
        fail(
          `row ${movement.row}: the balance before it ${formatAmount(running)} plus its movement ${formatAmount(moved)} is ${formatAmount(running + moved)}, and the row writes ${formatAmount(movement.balance)}: a difference of ${formatAmount(movement.balance - (running + moved))}`,
          { row: movement.row },
        );
      }
    }
    running = movement.balance ?? (running !== null && moved !== null ? running + moved : null);
  }
  const first = kept[0];
  const firstMoved = first === undefined ? null : movedBy(first);
  const runningOpening = first?.balance != null && firstMoved !== null ? first.balance - firstMoved : null;
  const runningClosing = kept[kept.length - 1]?.balance ?? null;
  if (declaredOpening !== null && runningOpening !== null && declaredOpening !== runningOpening) {
    fail(`the opening balance declared, ${formatAmount(declaredOpening)}, is not the ${formatAmount(runningOpening)} the first row's running balance implies`);
  }
  if (declaredClosing !== null && runningClosing !== null && declaredClosing !== runningClosing) {
    fail(`the closing balance declared, ${formatAmount(declaredClosing)}, is not the ${formatAmount(runningClosing)} the last row writes`);
  }
  const opening = declaredOpening ?? runningOpening;
  const closing = declaredClosing ?? runningClosing;
  if (opening !== null && closing !== null && !unreadable) {
    const total = kept.reduce((sum, movement) => sum + (movedBy(movement) ?? 0n), 0n);
    if (opening + total !== closing) {
      fail(
        `opening balance ${formatAmount(opening)} plus movements ${formatAmount(total)} is ${formatAmount(opening + total)}, and the statement closes at ${formatAmount(closing)}: a difference of ${formatAmount(closing - (opening + total))}${currency ? ` ${currency}` : ''}`,
      );
    } else if (balanced === null) balanced = true;
  } else if (chainChecked && balanced === null) balanced = true;

  // 5. The statement.
  const days = kept.map((movement) => movement.bookingDate).filter((day): day is string => day !== null).sort();
  const from = days[0] ?? null;
  const to = days[days.length - 1] ?? null;
  const balanceOf = (type: 'OPBD' | 'CLBD', amount: bigint | null): StatementBalance | null =>
    amount === null ? null : { type, amount: formatAmount(amount), currency, date: type === 'CLBD' ? to : null };
  const openingBalance = balanceOf('OPBD', opening);
  const closingBalance = balanceOf('CLBD', closing);
  const statement: Statement = {
    id: `${from ?? '…'}/${to ?? '…'}`,
    electronicSequenceNumber: null,
    legalSequenceNumber: null,
    createdAt: null,
    period: { from, to },
    page: null,
    account: {
      identifier: identifierOf(options.account) ?? { kind: 'other', value: '', scheme: null, issuer: null },
      currency,
      name: null,
      ownerName: null,
      servicerBic: null,
    },
    openingBalance,
    closingBalance,
    balances: [openingBalance, closingBalance].filter((item): item is StatementBalance => item !== null),
    lines,
    balanced,
  };
  return { format: 'csv', version: null, namespace: 'csv', statements: [statement], violations };
}
