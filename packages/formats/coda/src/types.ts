/**
 * What a statement is once it has been read: an account, two balances and
 * lines. The shape is declared here and imported from nowhere — it names no
 * table and no ledger. It is, field for field, the shape `@ekwo-ai/camt053`
 * declares for itself, so whatever takes one takes the other; what only CODA
 * says comes after, under names of its own.
 *
 * Every amount is a **decimal string**, signed from the account holder's side:
 * money in is positive, money out is negative, an overdrawn balance is
 * negative. No figure of a statement passes through a `number`.
 */

/**
 * How an account is identified, which the file says itself (record 1,
 * position 2): an IBAN, or a domestic number that is not one.
 */
export type AccountIdentifier =
  | {
      kind: 'iban';
      /** As written, without spaces, upper case. */
      value: string;
    }
  | {
      kind: 'other';
      /** As written, without spaces. */
      value: string;
      /** `BBAN` when the file says the number is a domestic one; null for a counterparty's, which says nothing. */
      scheme: string | null;
      issuer: string | null;
    };

export interface StatementAccount {
  identifier: AccountIdentifier;
  /** The ISO currency code of the account zone. Null when the zone leaves it blank. */
  currency: string | null;
  /** Record 1, "account description". */
  name: string | null;
  /** Record 1, "name of the account holder". */
  ownerName: string | null;
  /** Record 0, "BIC of the bank holding the account". */
  servicerBic: string | null;
}

export interface StatementBalance {
  /** `OPBD` for the old balance (record 1), `CLBD` for the new one (record 8). */
  type: string;
  /** Signed: a debit balance is negative. */
  amount: string;
  /** The currency of the account zone; null when the file leaves it blank. */
  currency: string | null;
  /** `YYYY-MM-DD`. */
  date: string | null;
}

export interface StructuredReference {
  /** Twelve digits for a Belgian structured communication, `RF…` for an ISO 11649 one — bare, as a camt.053 carries it. */
  reference: string;
  /** `SCOR`. */
  type: string | null;
  /** `BBA` for communication types 101 and 102, `ISO` for type 100. */
  issuer: string | null;
}

export interface Remittance {
  /** The free communication, the pieces of records 2.1, 2.2 and 2.3 put back together. */
  unstructured: string[];
  structured: StructuredReference[];
}

export interface Counterparty {
  name: string | null;
  account: AccountIdentifier | null;
  /** Record 2.2, "BIC of the counterparty's bank". */
  agentBic: string | null;
  /** Information record of type 008 (money out) or 009 (money in). */
  ultimateName: string | null;
}

export interface BankTransactionCode {
  /** Always null: CODA has its own code list, not the ISO 20022 one. */
  domain: string | null;
  family: string | null;
  subFamily: string | null;
  /** The eight digits of the transaction code, as written. */
  proprietary: string | null;
  /** `CODA`. */
  proprietaryIssuer: string | null;
}

/** The eight positions of a CODA transaction code, apart. */
export interface CodaTransactionCode {
  /** 0 simple, 1 and 2 totals, 3 simple with detail, 5 to 9 details. */
  type: string;
  family: string;
  transaction: string;
  category: string;
}

export interface StatementLine {
  /** Position among the statement's lines, from 1. */
  index: number;
  /** Which movement of the statement this line comes from, from 1: one per continuous sequence number. */
  entry: number;
  /**
   * When the movement was a total split into its details: which one this is,
   * from 1, and out of how many. Both null when the line is the whole movement.
   */
  detail: number | null;
  detailCount: number | null;
  /** `BOOK`: a coded statement carries booked movements and nothing else. */
  status: string;
  booked: boolean;
  /** Transaction 49 or 99 of its family: a correction or cancellation entry. */
  reversal: boolean;
  /** Record 2.1, "entry date". */
  bookingDate: string | null;
  /** Record 2.1, "value date"; null when the bank writes 000000. */
  valueDate: string | null;
  /** Signed: positive is money in. Null when the file's figure is unreadable. */
  amount: string | null;
  currency: string | null;
  /** Signed amount of the whole movement when this line is one part of it. */
  entryAmount: string | null;
  /**
   * Record 2.1, "reference number of the bank" — which the standard calls
   * purely informative, and which a bank may change without notice. Null when
   * blank or all zeros.
   */
  bankReference: string | null;
  /** Always null: CODA numbers a movement by its position, which is `sequenceNumber`. */
  entryReference: string | null;
  /** Record 2.2, "customer reference", on a simple movement or a detail. */
  endToEndId: string | null;
  transactionId: string | null;
  instructionId: string | null;
  /** Record 2.2, "customer reference", on a total (types 1 and 2). */
  paymentInformationId: string | null;
  /** The mandate reference of a structured communication of type 127. */
  mandateId: string | null;
  counterparty: Counterparty | null;
  remittance: Remittance;
  bankTransactionCode: BankTransactionCode | null;
  /** Record 2.2, "ISO reason return code", else the reason of a type 127 communication. */
  returnReason: string | null;
  /** Always null: a CODA reports in the currency of the account. */
  instructedAmount: { amount: string; currency: string } | null;
  exchangeRate: string | null;
  /** The free text of the information records (3) of the movement, joined. */
  additionalInformation: string | null;

  // --- what only CODA says ---

  /** "Continuous sequence number", as written. */
  sequenceNumber: string;
  /** "Detail number", as written: `0000` for the movement itself. */
  detailNumber: string;
  transactionCode: CodaTransactionCode | null;
  /** Position 125 of record 2.1, as written; `0` when the record opens or closes no globalisation. */
  globalisationCode: string;
  /** A structured communication, as written, whether or not this reader decodes its type. */
  structuredCommunication: { type: string; text: string } | null;
  /** Record 2.2: 1 reject, 2 return, 3 refund, 4 reversal, 5 cancellation. */
  rTransactionType: string | null;
  categoryPurpose: string | null;
  purpose: string | null;
  /** Every information record (3) of the movement: its communication type, or null when free, and its text. */
  information: { type: string | null; text: string }[];
}

export interface Statement {
  /**
   * CODA gives a statement no identifier. This one is made of what it does
   * give: the year of the creation date and the sequence number of the coded
   * statement, `2026-042`. The same file always makes the same one.
   */
  id: string;
  /** Record 1, "sequence number of the coded statement of account": restarts at 001 each year. */
  electronicSequenceNumber: string | null;
  /**
   * Always null. The number of the paper statement is in `paperSequenceNumber`:
   * the standard lets a bank write a Julian date or zeros there, so it is not
   * offered as a number whose holes mean a missing statement.
   */
  legalSequenceNumber: string | null;
  /** Record 0, "creation date", by day. */
  createdAt: string | null;
  /** Always null: the dates of the two balances are what CODA gives. */
  period: { from: string | null; to: string | null } | null;
  page: { number: string; last: boolean } | null;
  account: StatementAccount;
  openingBalance: StatementBalance | null;
  closingBalance: StatementBalance | null;
  balances: StatementBalance[];
  lines: StatementLine[];
  /**
   * Old balance plus the movements equals new balance: true, false, or null
   * when it could not be checked. False is reported as `balance_mismatch` and
   * **never corrected**.
   */
  balanced: boolean | null;

  // --- what only CODA says ---

  paperSequenceNumber: string | null;
  /** Record 0, position 17: the bank says this file is a duplicate of one it already sent. */
  duplicate: boolean;
  /** Record 0, "file reference as determined by the bank". */
  fileReference: string | null;
  /** Record 0, "name addressee". */
  addressee: string | null;
  /** Record 0, "identification number of the account holder", as written. */
  holderIdentification: string | null;
  /** Record 0, code "separate application": `00000` is every movement of the account. */
  separateApplication: string;
  /** The free communications (record 4), one text per communication. */
  freeCommunications: string[];
}

export interface Violation {
  /** A stable token, for a caller that branches on it. */
  code: ViolationCode;
  /** What is wrong, in a sentence. */
  message: string;
  /** Which statement of the file, from 1. */
  statement: number;
  /** Which line of that statement (`StatementLine.index`), where there is one. */
  line?: number;
}

export type ViolationCode =
  | 'balance_mismatch'
  | 'closing_balance_missing'
  | 'currency_missing'
  | 'record_count_mismatch'
  | 'debit_total_mismatch'
  | 'credit_total_mismatch'
  | 'separate_application'
  | 'invalid_amount'
  | 'invalid_direction'
  | 'invalid_date'
  | 'booking_date_missing'
  | 'invalid_iban'
  | 'invalid_structured_reference'
  | 'batch_not_split';

export interface StatementFile {
  format: 'coda';
  /** The version code of the header record: `2`. */
  version: string;
  /**
   * What was read, under one name: `coda.2`. The word is XML's and is kept
   * because it is the key under which `@ekwo-ai/camt053` says the same thing.
   */
  namespace: string;
  statements: Statement[];
  violations: Violation[];
}

export interface ReadOptions {
  /** Refuse a larger file unread. Default 32 MiB. */
  maxBytes?: number;
  /**
   * How bytes are decoded. Default `utf-8`, fatally — which reads ASCII, the
   * character set of the standard. `iso-8859-1` is said, never guessed.
   * Ignored when the input is already a string.
   */
  encoding?: 'utf-8' | 'iso-8859-1';
  /**
   * CODA writes a year on two digits. `YY` at or above this is 19YY, under it
   * 20YY. Default 80: version 2 of the standard has no file from before 1980
   * and this reader will need another look in 2080.
   */
  pivotYear?: number;
}
