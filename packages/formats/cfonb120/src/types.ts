/**
 * What a statement is once it has been read: an account, two balances and
 * lines. The shape is declared here and imported from nowhere — it names no
 * table and no ledger. It is, field for field, the shape `@ekwo-ai/camt053`
 * declares for itself, so whatever takes one takes the other; what only
 * CFONB 120 says comes after, under names of its own.
 *
 * Every amount is a **decimal string**, signed from the account holder's side:
 * money in is positive, money out is negative, an overdrawn balance is
 * negative. No figure of a statement passes through a `number`.
 */

/**
 * How an account is identified. A CFONB 120 carries a bank code, a branch code
 * and an account number, and neither an IBAN nor a country: the identifier is
 * `other`, the three joined, unless the caller names the country
 * (`ibanCountry`) — then it is the IBAN those three make there.
 */
export type AccountIdentifier =
  | {
      kind: 'iban';
      /** Without spaces, upper case. */
      value: string;
    }
  | {
      kind: 'other';
      /** Bank code, branch code and account number, twenty-one characters; or a counterparty's account as written. */
      value: string;
      scheme: string | null;
      issuer: string | null;
    };

export interface StatementAccount {
  identifier: AccountIdentifier;
  /** Zone E of the records: the ISO 4217 code. */
  currency: string | null;
  /** Always null: the format names no account and no holder. */
  name: string | null;
  ownerName: string | null;
  servicerBic: string | null;

  // --- what only CFONB 120 says ---

  bankCode: string;
  branchCode: string;
  accountNumber: string;
  /** Zone F: how many of an amount's digits are decimals, as the records of this statement say. */
  decimals: number;
}

export interface StatementBalance {
  /** `OPBD` for the old balance (record 01), `CLBD` for the new one (record 07). */
  type: string;
  /** Signed: a debit balance is negative. */
  amount: string;
  currency: string | null;
  /** `YYYY-MM-DD`. */
  date: string | null;
}

export interface StructuredReference {
  /** The `LCS` complement: the structured remittance of the payment, as written. */
  reference: string;
  /** Always null: the complement carries the reference and not its type. */
  type: string | null;
  issuer: string | null;
}

export interface Remittance {
  /** The `LIB` complements, one each, then `LCC` and `LC2` put back into the one text they were cut from. */
  unstructured: string[];
  structured: StructuredReference[];
}

export interface Counterparty {
  /** `NPY` for money in, `NBE` for money out — and the other way round on a rejected operation. */
  name: string | null;
  /** `CPY` or `CBE`, by the same rule. */
  account: AccountIdentifier | null;
  /** Always null. */
  agentBic: string | null;
  /** `NPO` or `NBU`, by the same rule. */
  ultimateName: string | null;
}

export interface BankTransactionCode {
  /** Always null: CFONB has its own code list, not the ISO 20022 one. */
  domain: string | null;
  family: string | null;
  subFamily: string | null;
  /** Zone 2-I, the two characters of the interbank operation code. */
  proprietary: string | null;
  /** `CFONB`. */
  proprietaryIssuer: string | null;
}

export interface StatementLine {
  /** Position among the statement's lines, from 1. */
  index: number;
  /** The same: a CFONB 120 movement is never split. */
  entry: number;
  /** Always null. */
  detail: number | null;
  detailCount: number | null;
  /** `BOOK`: by its definition the statement "shows accounting entries only". */
  status: string;
  booked: boolean;
  /** A reject code is present (zone 2-K): the operation comes back. */
  reversal: boolean;
  /** Zone 2-J. */
  bookingDate: string | null;
  /** Zone 2-L. */
  valueDate: string | null;
  /** Signed: positive is money in. Null when the file's figure is unreadable. */
  amount: string | null;
  currency: string | null;
  entryAmount: string | null;
  /**
   * Always null. The format has **no reference the bank gives a movement**:
   * `entryNumber` is a cheque or remittance number or zeros, and the `REF`
   * complement carries the payer's references, not the bank's.
   */
  bankReference: string | null;
  entryReference: string | null;
  /** `RCN`, first zone. */
  endToEndId: string | null;
  transactionId: string | null;
  /** `REF`, second zone. */
  instructionId: string | null;
  /** `REF`, first zone. */
  paymentInformationId: string | null;
  /** `RUM`, first zone. */
  mandateId: string | null;
  counterparty: Counterparty | null;
  remittance: Remittance;
  bankTransactionCode: BankTransactionCode | null;
  /** Zone 2-K, the reject code, as written; null when blank or zeros. */
  returnReason: string | null;
  /** `MMO`: the amount and currency of origin, unsigned and unconverted. */
  instructedAmount: { amount: string; currency: string } | null;
  /** `MMO`: the rate, with the decimals the complement announces. */
  exchangeRate: string | null;
  /** Zone 2-M, the label the bank gives the movement. */
  additionalInformation: string | null;

  // --- what only CFONB 120 says ---

  /** Zone 2-C, the bank's own operation code. */
  internalOperationCode: string | null;
  /** Zone 2-I. */
  interbankOperationCode: string | null;
  /** Zone 2-O: a cheque, remittance or voucher number; null when zeros. */
  entryNumber: string | null;
  /** Zone 2-P is `1`: exempt from the account movement commission. */
  commissionExempt: boolean;
  /** Zone 2-Q is `1`: booked, and not available yet. */
  unavailable: boolean;
  /** Zone 2-S. */
  referenceZone: string | null;
  /** `RCN`, second zone. */
  purpose: string | null;
  /** `RUM`, second zone: OOFF, FRST, RCUR, FNAL. */
  sequenceType: string | null;
  /** `IPY` or `IBE`: the identifier of the counterparty and what kind of identifier it is. */
  counterpartyIdentifier: { value: string; type: string | null } | null;
  /** Every complement (record 05) of the movement, in order: its qualifier and its seventy positions, as written. */
  complements: { qualifier: string; text: string }[];
}

export interface Statement {
  /**
   * CFONB 120 gives a statement no identifier and no number. This one is made
   * of what it does give: the dates of its two balances,
   * `2026-02-28/2026-03-31`. The same file always makes the same one.
   */
  id: string;
  /** Always null: the format numbers no statement. */
  electronicSequenceNumber: string | null;
  legalSequenceNumber: string | null;
  createdAt: string | null;
  /** Always null: the dates of the two balances are what the format gives. */
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
  | 'invalid_amount'
  | 'invalid_date'
  | 'booking_date_missing'
  | 'booking_date_outside_statement'
  | 'invalid_iban';

export interface StatementFile {
  format: 'cfonb120';
  /** Null: the brochure has an edition (July 2004, completed in March 2010) and the file does not say which it follows. */
  version: string | null;
  /**
   * What was read, under one name: `cfonb120`. The word is XML's and is kept
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
   * character set of the brochure. `iso-8859-1` is said, never guessed.
   * Ignored when the input is already a string.
   */
  encoding?: 'utf-8' | 'iso-8859-1';
  /**
   * The format writes a year on two digits. `YY` at or above this is 19YY,
   * under it 20YY. Default 80.
   */
  pivotYear?: number;
  /**
   * Two letters. When given, every account of the file is returned as the
   * IBAN its bank code, branch code and account number make **in that
   * country**. Left out, nothing is assumed and the identifier is `other`:
   * the format carries no country, and the same lay-out serves several.
   */
  ibanCountry?: string;
}
