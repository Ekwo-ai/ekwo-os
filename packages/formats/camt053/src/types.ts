/**
 * What a statement is once it has been read: an account, two balances and
 * lines. The shape is declared here and imported from nowhere — it names no
 * table, no ledger and no country, so anything that keeps books can take it.
 *
 * Every amount is a **decimal string**, signed from the account holder's side:
 * money in is positive, money out is negative, an overdrawn balance is
 * negative. No figure of a statement passes through a `number`.
 */

/**
 * How an account is identified. ISO 20022 gives a choice and so does this
 * type: an IBAN (ISO 13616) **or** anything else — a domestic account number,
 * a routing number and an account, whatever the bank's country uses. Half the
 * world has no IBAN, and a reader that only returned one would read half the
 * statements.
 */
export type AccountIdentifier =
  | {
      kind: 'iban';
      /** As written, without spaces, upper case. */
      value: string;
    }
  | {
      kind: 'other';
      /** `Othr/Id`, as written. */
      value: string;
      /** `SchmeNm/Cd` (an ISO external code such as `BBAN`) or `SchmeNm/Prtry`. */
      scheme: string | null;
      /** `Othr/Issr`, who assigned it. */
      issuer: string | null;
    };

export interface StatementAccount {
  identifier: AccountIdentifier;
  /** `Acct/Ccy`. Null when the bank does not say; the balances still do. */
  currency: string | null;
  name: string | null;
  ownerName: string | null;
  /** BIC of the institution servicing the account, when given. */
  servicerBic: string | null;
}

export interface StatementBalance {
  /**
   * `Tp/CdOrPrtry/Cd` — `OPBD` opening booked, `CLBD` closing booked, `PRCD`
   * previous closing, `ITBD` interim, `CLAV` closing available… — or the
   * proprietary label when the bank uses one.
   */
  type: string;
  /** Signed: a debit balance is negative. */
  amount: string;
  currency: string;
  /** The day, `YYYY-MM-DD`, as the bank wrote it — no timezone is applied. */
  date: string | null;
}

export interface StructuredReference {
  /** `CdtrRefInf/Ref`: the creditor reference itself. */
  reference: string;
  /** `CdtrRefInf/Tp/CdOrPrtry/Cd`, usually `SCOR`; or the proprietary label. */
  type: string | null;
  /** `CdtrRefInf/Tp/Issr`: who defined the reference — `ISO` for an RF one. */
  issuer: string | null;
}

export interface Remittance {
  /** Every `RmtInf/Ustrd`, in order. Free text: what a person typed. */
  unstructured: string[];
  /** Every `RmtInf/Strd/CdtrRefInf` that carries a reference, in order. */
  structured: StructuredReference[];
}

export interface Counterparty {
  name: string | null;
  account: AccountIdentifier | null;
  /** BIC of the counterparty's bank, when given. */
  agentBic: string | null;
  /** The ultimate debtor or creditor behind the counterparty, when named. */
  ultimateName: string | null;
}

export interface BankTransactionCode {
  /** ISO 20022 external code set: domain, family, sub-family. */
  domain: string | null;
  family: string | null;
  subFamily: string | null;
  /** The bank's own code, and who issued the code list. */
  proprietary: string | null;
  proprietaryIssuer: string | null;
}

export interface StatementLine {
  /** Position among the statement's lines, from 1. */
  index: number;
  /** Position of the `Ntry` this line comes from, from 1. */
  entry: number;
  /**
   * When the entry was a batch split into its transactions: which one this is,
   * from 1, and out of how many. Both null when the line is the whole entry.
   */
  detail: number | null;
  detailCount: number | null;
  /**
   * `BOOK`, `PDNG`, `INFO`, `FUTR`, or the proprietary label. Only booked
   * entries move the balance, and only they are counted in the balance check.
   */
  status: string;
  booked: boolean;
  /** `RvslInd`: this entry reverses an earlier one. */
  reversal: boolean;
  /** `BookgDt`, `YYYY-MM-DD`. Falls back to nothing: a missing date is reported. */
  bookingDate: string | null;
  /** `ValDt`, `YYYY-MM-DD`. */
  valueDate: string | null;
  /** Signed: positive is money in. Null when the file's figure is unreadable. */
  amount: string | null;
  currency: string | null;
  /** Signed amount of the whole entry when this line is one part of it. */
  entryAmount: string | null;
  /**
   * The bank's own reference for this movement: the transaction's
   * `Refs/AcctSvcrRef`, else the entry's `AcctSvcrRef`. Unique per movement at
   * a given bank when present — and optional in the schema, so it may be null.
   */
  bankReference: string | null;
  /** `NtryRef`: unique within the statement, by the message definition. */
  entryReference: string | null;
  /** As written — including the placeholder `NOTPROVIDED` when the bank writes it. */
  endToEndId: string | null;
  transactionId: string | null;
  instructionId: string | null;
  paymentInformationId: string | null;
  mandateId: string | null;
  counterparty: Counterparty | null;
  remittance: Remittance;
  bankTransactionCode: BankTransactionCode | null;
  /** `RtrInf/Rsn`: why a payment came back — ISO code or proprietary label. */
  returnReason: string | null;
  /**
   * `AmtDtls/InstdAmt`: what was ordered, in the currency it was ordered in,
   * unsigned as the file writes it. The line's `amount` stays what moved on
   * the account; nothing is converted here.
   */
  instructedAmount: { amount: string; currency: string } | null;
  /** `AmtDtls/…/CcyXchg/XchgRate`, as written. */
  exchangeRate: string | null;
  /** `AddtlTxInf`, else `AddtlNtryInf`. */
  additionalInformation: string | null;
}

export interface Statement {
  /** `Stmt/Id`. */
  id: string;
  electronicSequenceNumber: string | null;
  legalSequenceNumber: string | null;
  /** `CreDtTm`, as written. */
  createdAt: string | null;
  /** `FrToDt`, by day. */
  period: { from: string | null; to: string | null } | null;
  /** `StmtPgntn`, from version 03 on: a statement delivered in several files. */
  page: { number: string; last: boolean } | null;
  account: StatementAccount;
  /** `OPBD`, else `PRCD`. */
  openingBalance: StatementBalance | null;
  /** `CLBD`. */
  closingBalance: StatementBalance | null;
  /** Every `Bal`, in file order, including the two above. */
  balances: StatementBalance[];
  lines: StatementLine[];
  /**
   * Opening balance plus booked entries equals closing balance: true, false,
   * or null when it could not be checked (a balance missing, a figure
   * unreadable, an entry in another currency). False is reported as
   * `balance_mismatch` and **never corrected**.
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
  | 'version_not_verified'
  | 'balance_mismatch'
  | 'opening_balance_missing'
  | 'closing_balance_missing'
  | 'balance_currency_mismatch'
  | 'foreign_currency_entry'
  | 'invalid_amount'
  | 'invalid_direction'
  | 'invalid_date'
  | 'booking_date_missing'
  | 'invalid_iban'
  | 'duplicate_bank_reference'
  | 'duplicate_entry_reference'
  | 'batch_not_split'
  | 'batch_count_mismatch';

export interface StatementFile {
  /** The namespace of the document element: the version that was read. */
  namespace: string;
  /** `02`, `08`… — the last part of the message identifier. */
  version: string;
  /** Whether this package's tests hold that version against its schema. */
  versionVerified: boolean;
  /** `GrpHdr/MsgId`. */
  messageId: string | null;
  /** `GrpHdr/CreDtTm`, as written. */
  createdAt: string | null;
  statements: Statement[];
  violations: Violation[];
}

export interface ReadOptions {
  /** Refuse a larger file unread. Default 32 MiB. */
  maxBytes?: number;
  /** Refuse deeper nesting. Default 64; the deepest path of the schema is under 20. */
  maxDepth?: number;
  /** Refuse more elements. Default 2,000,000. */
  maxElements?: number;
}
