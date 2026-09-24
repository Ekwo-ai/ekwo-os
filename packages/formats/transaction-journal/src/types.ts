/**
 * What a set of books is once it has been read out of the software that kept
 * them: accounts, parties, entries and an opening balance. The shape is
 * declared here and imported from nowhere — it names no table and no ledger.
 *
 * It is, field for field, the shape every reader of an accounting export in
 * this repository declares for itself (`@ekwo-ai/fec`, and the readers beside
 * this one), so whatever takes one takes the others. It is not a shared
 * abstraction: none imports another, and a reader that has nothing to say for
 * a part of it returns that part empty.
 *
 * Every amount is a **decimal string**, never negative: a line carries a debit
 * or a credit, and the side is the sign. No figure passes through a `number`.
 */

/** ISO 8601 calendar date, `YYYY-MM-DD`. */
export type IsoDate = string;

/** A fixed-point number, `1234.50`, never negative. */
export type Decimal = string;

/** One account of the chart the books were kept on, in the words of that software. */
export interface ImportedAccount {
  code: string;
  name: string | null;
  /** What the source calls its kind, verbatim. Null when it says nothing. */
  type: string | null;
}

/** A customer, a supplier or anybody else a line names. */
export interface ImportedContact {
  /** How the source identifies the party on a line: its code, or its name where it has no code. */
  code: string;
  name: string;
  vatNumber: string | null;
  registrationNumber: string | null;
  email: string | null;
  /** ISO 3166-1 alpha-2, when the source writes one. Never inferred. */
  country: string | null;
}

export interface ImportedLine {
  /** The account code in the source's chart. */
  account: string;
  /** The `code` of an {@link ImportedContact}, or null. */
  contact: string | null;
  label: string | null;
  debit: Decimal;
  credit: Decimal;
  /** A foreign currency the line was in, when the source says so. */
  currency: string | null;
  /** The amount in that currency, never negative. */
  amountCurrency: Decimal | null;
  dueDate: IsoDate | null;
  /** The reconciliation mark the source put on the line, as written. */
  matching: string | null;
}

export interface ImportedEntry {
  /** The journal code in the source, or null when it has none. */
  journal: string | null;
  journalName: string | null;
  /** The entry's number in the source. */
  number: string | null;
  date: IsoDate;
  reference: string | null;
  description: string | null;
  lines: ImportedLine[];
  /** The row of the file the entry starts on, from 1, for a message. */
  row: number | null;
}

export interface Violation {
  rule: string;
  message: string;
  /** The row of the file, from 1, or null for a rule about the whole file. */
  row: number | null;
}

export interface ImportedBooks {
  /** Which reader: `transaction-journal` here. */
  format: string;
  /** The currency the file says its amounts are in. Null when it says none: never guessed. */
  currency: string | null;
  accounts: ImportedAccount[];
  contacts: ImportedContact[];
  entries: ImportedEntry[];
  /** A trial balance: one line per account, to become the opening entry of a year. */
  opening: ImportedLine[];
  violations: Violation[];
}

export type Encoding = 'utf-8' | 'iso-8859-1';

export interface ReadOptions {
  /**
   * How bytes are decoded. Default `utf-8`, fatally: bytes that are not UTF-8
   * are refused by name, never read as something else. A spreadsheet that
   * saves in Latin-1 is said to be so, because every sequence of bytes is
   * valid Latin-1 and a guess would always succeed.
   */
  encoding?: Encoding;
  /** Refused beyond this many bytes, before anything is read. Default 256 MiB. */
  maxBytes?: number;
}
