/**
 * A CSV is not a format: it is a table, and every bank, payment service and
 * card issuer lays its own out. What makes one readable is a **profile** — which
 * column is the date, which the amount, how a date and a number are written —
 * and the profile is data the caller gives, never something this reader knows
 * about a bank. One reader, one profile per lay-out.
 *
 * What comes out is a statement as the other readers return it: an account, two
 * balances and lines. It is, field for field, the shape `@ekwo-ai/camt053`
 * declares for itself, so whatever takes one takes the other; what only a CSV
 * says comes after, under names of its own.
 *
 * Every amount is a **decimal string**, signed from the account holder's side:
 * money in is positive, money out is negative, an overdrawn balance is
 * negative. No figure of a statement passes through a `number`.
 */

// --- the profile ---------------------------------------------------------------

/**
 * A column: its header, as written (compared without the blanks around it and
 * without regard to case), or its position counted **from 1**. A position is the
 * only way to name a column of a file without a header row.
 */
export type ColumnRef = string | number;

/** How the bytes are decoded. Never guessed: every sequence of bytes is valid Latin-1. */
export type Encoding = 'utf-8' | 'iso-8859-1' | 'windows-1252';

/**
 * Which column says what. `date` is required, and the amount is one of two
 * lay-outs: one signed `amount` column, **or** a `debit` and a `credit` column
 * (one of them may be left out when the file has only the other).
 */
export interface CsvStatementColumns {
  /** The day the movement was booked. Required. */
  date: ColumnRef;
  /** The value date, when the file has one besides the booking date. */
  valueDate?: ColumnRef;
  /** One signed amount. Positive is money in, unless the profile says `sign: 'inverted'`. */
  amount?: ColumnRef;
  /** Money out, written without a sign or with one: either way it is taken out. */
  debit?: ColumnRef;
  /** Money in, written without a sign or with one: either way it is put in. */
  credit?: ColumnRef;
  /**
   * A fee taken on the movement, in its own column, as a payment service
   * writes it beside the gross amount. A row with a fee that is not zero
   * becomes **two lines**: the gross amount, then the fee, each matched on its
   * own (the gross amount to the invoice it pays, the fee to a charge). Leave it
   * out when `amount` already names the net column.
   */
  fee?: ColumnRef;
  /** The currency of each row, as an ISO 4217 code. */
  currency?: ColumnRef;
  /** The name of the other party. */
  counterparty?: ColumnRef;
  /** The account of the other party: an IBAN, or a number as written. */
  counterpartyAccount?: ColumnRef;
  /** The text of the movement. Several columns are kept in order, each a text of its own. */
  description?: ColumnRef | ColumnRef[];
  /** A reference the bank or the service gives the movement — a transaction id — and keeps the same in every export. */
  reference?: ColumnRef;
  /** The balance of the account after the row, as a running balance column writes it. */
  balance?: ColumnRef;
}

/**
 * The lay-out of one export. Built once for an account — by hand, or by a
 * person in front of a preview — and kept with it: the next file of the same
 * account is read with the same profile.
 */
export interface CsvStatementProfile {
  /** The character between two fields: `,`, `;`, a tab, `|`… One character. */
  delimiter: string;
  /** Default `utf-8`, fatally: a byte that is not UTF-8 is refused, never replaced. */
  encoding?: Encoding;
  /** Lines before the header row (or before the first row, when there is no header): a title, an account line. Default 0. */
  skipRows?: number;
  /** Whether the first row read is a header. Default true. Without one, every column is named by its position. */
  header?: boolean;
  /** Rows at the end that are not movements: a total, a closing line. Default 0. */
  skipFooterRows?: number;
  /**
   * How a date is written, with `DD`, `MM` and `YYYY` (or `YY`) and the
   * characters between them as they stand: `DD/MM/YYYY`, `MM/DD/YYYY`,
   * `YYYY-MM-DD`, `DD.MM.YY`, `YYYYMMDD`. Where the parts are separated, a day
   * or a month of one digit is read too. A time after the date, past a blank
   * or a `T`, is left aside. `YY` at or above 80 is 19YY, under it 20YY.
   */
  dateFormat: string;
  /** The decimal mark of the amounts: `.` or `,`. */
  decimalSeparator: '.' | ',';
  /** The mark grouping thousands, when the file writes one: a blank, `.`, `,`, `'`, a non-breaking space. Default none. */
  thousandsSeparator?: string;
  /**
   * `as-written` (default): a positive amount is money in. `inverted`: a
   * positive amount is money out — as a card statement writes a purchase.
   * Applies to `amount`, `fee` and `balance`, never to `debit` and `credit`,
   * whose column already says the direction.
   */
  sign?: 'as-written' | 'inverted';
  /** The file lists the newest row first. The lines come back oldest first either way. Default false. */
  newestFirst?: boolean;
  columns: CsvStatementColumns;
}

/**
 * What the caller knows and the file does not say. A CSV names no account and,
 * often, no currency and no balance: they are given here, never guessed.
 */
export interface ReadOptions {
  /** Refuse a larger file unread. Default 32 MiB. */
  maxBytes?: number;
  /**
   * The account the file is of: an IBAN, or the identifier the bank gives it.
   * The file names none, so without this the statement's account is empty and
   * an import has nothing to match it to.
   */
  account?: string;
  /**
   * The ISO 4217 currency of the account. With a `currency` column, the rows in
   * another currency are another balance — a payment service keeps one per
   * currency — and are left out, each reported as `other_currency`.
   */
  currency?: string;
  /** The opening balance the bank declares for the period, read from elsewhere (its own statement, its app). Signed, as written: `1250.00`, `-40.10`. */
  openingBalance?: string;
  /** The closing balance the bank declares, the same way. */
  closingBalance?: string;
}

// --- what is read ---------------------------------------------------------------

export type AccountIdentifier =
  | {
      kind: 'iban';
      /** Without spaces, upper case. */
      value: string;
    }
  | {
      kind: 'other';
      /** As given, without spaces. Empty when the caller named no account. */
      value: string;
      scheme: string | null;
      issuer: string | null;
    };

export interface StatementAccount {
  /** What the caller named in `account`: an IBAN when it passes ISO 13616, else `other`. */
  identifier: AccountIdentifier;
  /** `currency` of the options, else the one currency every row wrote; null when neither says. */
  currency: string | null;
  /** Always null: a CSV names no account and no holder. */
  name: string | null;
  ownerName: string | null;
  servicerBic: string | null;
}

export interface StatementBalance {
  /** `OPBD` for the opening balance, `CLBD` for the closing one. */
  type: string;
  /** Signed: a debit balance is negative. */
  amount: string;
  currency: string | null;
  /** `YYYY-MM-DD`. The closing balance is dated on the last line; the opening one on nothing the file says, so null. */
  date: string | null;
}

export interface StructuredReference {
  reference: string;
  type: string | null;
  issuer: string | null;
}

export interface Remittance {
  /** The `description` columns, one text each, the empty ones left out. */
  unstructured: string[];
  /** Always empty: a CSV says nothing of a structured reference. */
  structured: StructuredReference[];
}

export interface Counterparty {
  name: string | null;
  account: AccountIdentifier | null;
  /** Always null. */
  agentBic: string | null;
  ultimateName: string | null;
}

export interface BankTransactionCode {
  domain: string | null;
  family: string | null;
  subFamily: string | null;
  proprietary: string | null;
  proprietaryIssuer: string | null;
}

export interface StatementLine {
  /** Position among the statement's lines, from 1, oldest first. */
  index: number;
  /** Which row of movements the line comes from, from 1: a row with a fee makes two lines of one entry. */
  entry: number;
  /** 1 for the gross amount and 2 for the fee of a row that has one; null otherwise. */
  detail: number | null;
  /** 2 on both lines of a row with a fee; null otherwise. */
  detailCount: number | null;
  /** `BOOK`: an export lists what moved the account. */
  status: string;
  booked: boolean;
  /** Always false: a CSV does not say a movement is a return. */
  reversal: boolean;
  bookingDate: string | null;
  valueDate: string | null;
  /** Signed: positive is money in. Null when the file's figure is unreadable. */
  amount: string | null;
  currency: string | null;
  /** Always null. */
  entryAmount: string | null;
  /** The `reference` column. */
  bankReference: string | null;
  entryReference: string | null;
  endToEndId: string | null;
  transactionId: string | null;
  instructionId: string | null;
  paymentInformationId: string | null;
  mandateId: string | null;
  counterparty: Counterparty | null;
  remittance: Remittance;
  bankTransactionCode: BankTransactionCode | null;
  returnReason: string | null;
  instructedAmount: { amount: string; currency: string } | null;
  exchangeRate: string | null;
  /** On the fee line of a row, the header of the fee column as the file writes it; null otherwise. */
  additionalInformation: string | null;

  // --- what only a CSV says ---

  /** The row of the file the line was read from, counted from 1 over every line of the file. */
  row: number;
  /** The running balance the row wrote, when the profile names a `balance` column. */
  rowBalance: string | null;
}

export interface Statement {
  /**
   * A CSV gives a statement no identifier. This one is made of the days of
   * its first and last line, `2026-03-01/2026-03-31`: the same file always
   * makes the same one.
   */
  id: string;
  /** Always null: a CSV numbers no statement. */
  electronicSequenceNumber: string | null;
  legalSequenceNumber: string | null;
  createdAt: string | null;
  /** The days of the first and the last line. */
  period: { from: string | null; to: string | null } | null;
  page: { number: string; last: boolean } | null;
  account: StatementAccount;
  /**
   * The opening balance the caller declared, else the one the running balance
   * of the first row implies (its balance less its movement), else null.
   */
  openingBalance: StatementBalance | null;
  /** The closing balance the caller declared, else the running balance of the last row, else null. */
  closingBalance: StatementBalance | null;
  balances: StatementBalance[];
  lines: StatementLine[];
  /**
   * Opening balance plus the movements equals closing balance, and every
   * running balance follows from the one before: true, false, or null when
   * there is nothing to check it against. False is reported as
   * `balance_mismatch` and **never corrected**.
   */
  balanced: boolean | null;
}

export interface Violation {
  /** A stable token, for a caller that branches on it. */
  code: ViolationCode;
  /** What is wrong, in a sentence. */
  message: string;
  /** Which statement of the file, from 1: a CSV holds one. */
  statement: number;
  /** Which line of that statement (`StatementLine.index`), where there is one. */
  line?: number;
  /** Which row of the file, from 1, where there is one. */
  row?: number;
}

export type ViolationCode =
  | 'balance_mismatch'
  | 'invalid_amount'
  | 'invalid_date'
  | 'booking_date_missing'
  /** A row in another currency than the account's, left out. */
  | 'other_currency'
  /** Rows in several currencies, and no `currency` named to choose the account's. */
  | 'mixed_currencies';

export interface StatementFile {
  format: 'csv';
  /** Always null: a CSV has no version. */
  version: string | null;
  /** `csv`. The word is XML's and is kept because it is the key under which `@ekwo-ai/camt053` says the same thing. */
  namespace: string;
  statements: Statement[];
  violations: Violation[];
}
