import { formatScaled, parseUnsigned, signedText } from './decimal.js';
import { StatementFileError } from './errors.js';
import type {
  AccountIdentifier,
  BankTransactionCode,
  Counterparty,
  ReadOptions,
  Remittance,
  Statement,
  StatementBalance,
  StatementFile,
  StatementLine,
  Violation,
  ViolationCode,
} from './types.js';
import { parseXml, type XmlElement } from './xml.js';

export { StatementFileError, type StatementFileErrorCode } from './errors.js';
export type * from './types.js';

/**
 * The versions of camt.053 this package's tests hold against the schema ISO
 * publishes for each: a fixture per version validates, and is read. Another
 * version of the same message is still read — the elements this package takes
 * have kept their names since 2009 — and reported as `version_not_verified`.
 */
export const VERIFIED_VERSIONS: readonly string[] = [
  '02',
  '03',
  '04',
  '05',
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12',
  '13',
  '14',
];

const NAMESPACE = /^urn:iso:std:iso:20022:tech:xsd:camt\.053\.001\.([0-9]{2})$/;

const DEFAULTS = { maxBytes: 32 * 1024 * 1024, maxDepth: 64, maxElements: 2_000_000 };

// --- walking the tree ------------------------------------------------------

function child(parent: XmlElement | undefined, name: string): XmlElement | undefined {
  if (!parent) return undefined;
  for (const candidate of parent.children) {
    if (candidate.name === name && candidate.namespace === parent.namespace) return candidate;
  }
  return undefined;
}

function children(parent: XmlElement | undefined, name: string): XmlElement[] {
  if (!parent) return [];
  return parent.children.filter(
    (candidate) => candidate.name === name && candidate.namespace === parent.namespace,
  );
}

function descend(parent: XmlElement | undefined, ...path: string[]): XmlElement | undefined {
  let current = parent;
  for (const name of path) current = child(current, name);
  return current;
}

/** The trimmed text at a path, or null when absent or empty. */
function text(parent: XmlElement | undefined, ...path: string[]): string | null {
  const value = descend(parent, ...path)?.text.trim();
  return value === undefined || value === '' ? null : value;
}

// --- small readers ---------------------------------------------------------

const DAY = /^([0-9]{4})-([0-9]{2})-([0-9]{2})(?:Z|[+-][0-9]{2}:[0-9]{2})?$/;
const DAY_TIME = /^([0-9]{4})-([0-9]{2})-([0-9]{2})T[0-9]{2}:[0-9]{2}:[0-9]{2}(?:\.[0-9]+)?(?:Z|[+-][0-9]{2}:[0-9]{2})?$/;

/**
 * The day of an ISO date or date-time, **as written**. `2026-03-31T23:30:00+02:00`
 * is 31 March: the bank wrote that day, and moving it to UTC would book it on
 * another. `undefined` when the text is not a date.
 */
function day(raw: string): string | undefined {
  const match = DAY.exec(raw) ?? DAY_TIME.exec(raw);
  if (!match) return undefined;
  const year = Number(match[1]);
  const month = Number(match[2]);
  const date = Number(match[3]);
  if (month < 1 || month > 12 || date < 1) return undefined;
  const leap = (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
  const length = [31, leap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1] as number;
  if (date > length) return undefined;
  return `${match[1]}-${match[2]}-${match[3]}`;
}

/** A `Dt | DtTm` choice, or a bare date or date-time element. */
function rawDate(element: XmlElement | undefined): string | null {
  if (!element) return null;
  return text(element, 'Dt') ?? text(element, 'DtTm') ?? (element.text.trim() || null);
}

/** ISO 13616: move four characters to the end, letters to numbers, mod 97 is 1. */
export function isValidIban(iban: string): boolean {
  if (!/^[A-Z]{2}[0-9]{2}[A-Za-z0-9]{1,30}$/.test(iban)) return false;
  const rearranged = (iban.slice(4) + iban.slice(0, 4)).toUpperCase();
  let remainder = 0;
  for (const character of rearranged) {
    const code = character.charCodeAt(0);
    const value = code >= 65 ? code - 55 : code - 48;
    remainder = (value > 9 ? remainder * 100 + value : remainder * 10 + value) % 97;
  }
  return remainder === 1;
}

function accountIdentifier(id: XmlElement | undefined): AccountIdentifier | null {
  const iban = text(id, 'IBAN');
  if (iban !== null) return { kind: 'iban', value: iban.replace(/\s+/g, '').toUpperCase() };
  const other = child(id, 'Othr');
  const value = text(other, 'Id');
  if (value === null) return null;
  return {
    kind: 'other',
    value,
    scheme: text(other, 'SchmeNm', 'Cd') ?? text(other, 'SchmeNm', 'Prtry'),
    issuer: text(other, 'Issr'),
  };
}

function bic(agent: XmlElement | undefined): string | null {
  const institution = child(agent, 'FinInstnId');
  return text(institution, 'BICFI') ?? text(institution, 'BIC');
}

/** A party's name: directly under it until version 06, under `Pty` or `Agt` after. */
function partyName(party: XmlElement | undefined): string | null {
  return (
    text(party, 'Nm') ?? text(party, 'Pty', 'Nm') ?? text(party, 'Agt', 'FinInstnId', 'Nm')
  );
}

function bankTransactionCode(code: XmlElement | undefined): BankTransactionCode | null {
  if (!code) return null;
  const out: BankTransactionCode = {
    domain: text(code, 'Domn', 'Cd'),
    family: text(code, 'Domn', 'Fmly', 'Cd'),
    subFamily: text(code, 'Domn', 'Fmly', 'SubFmlyCd'),
    proprietary: text(code, 'Prtry', 'Cd'),
    proprietaryIssuer: text(code, 'Prtry', 'Issr'),
  };
  return Object.values(out).every((value) => value === null) ? null : out;
}

function remittance(information: XmlElement | undefined): Remittance {
  const out: Remittance = { unstructured: [], structured: [] };
  for (const free of children(information, 'Ustrd')) {
    const value = free.text.trim();
    if (value !== '') out.unstructured.push(value);
  }
  for (const structured of children(information, 'Strd')) {
    const creditor = child(structured, 'CdtrRefInf');
    const reference = text(creditor, 'Ref');
    if (reference === null) continue;
    out.structured.push({
      reference,
      type: text(creditor, 'Tp', 'CdOrPrtry', 'Cd') ?? text(creditor, 'Tp', 'CdOrPrtry', 'Prtry'),
      issuer: text(creditor, 'Tp', 'Issr'),
    });
  }
  return out;
}

interface Signed {
  /** Hundred-thousandths, signed. */
  scaled: bigint;
  text: string;
  currency: string | null;
}

/** `Amt` and its `CdtDbtInd`, signed from the account holder's side. */
function signedAmount(amount: XmlElement | undefined, direction: string | null): Signed | null {
  if (!amount || (direction !== 'CRDT' && direction !== 'DBIT')) return null;
  const scaled = parseUnsigned(amount.text);
  if (scaled === null) return null;
  const negative = direction === 'DBIT';
  return {
    scaled: negative ? -scaled : scaled,
    text: signedText(amount.text, negative),
    currency: amount.attributes['Ccy'] ?? null,
  };
}

// --- a statement -----------------------------------------------------------

function readStatement(
  stmt: XmlElement,
  position: number,
  version: string,
  violations: Violation[],
): Statement {
  const report = (code: ViolationCode, message: string, line?: number): void => {
    violations.push(
      line === undefined
        ? { code, message, statement: position }
        : { code, message, statement: position, line },
    );
  };
  const dayOf = (element: XmlElement | undefined, what: string, line?: number): string | null => {
    const raw = rawDate(element);
    if (raw === null) return null;
    const value = day(raw);
    if (value === undefined) {
      report('invalid_date', `${what} "${raw}" is not a date`, line);
      return null;
    }
    return value;
  };

  const id = text(stmt, 'Id');
  const acct = child(stmt, 'Acct');
  const identifier = accountIdentifier(child(acct, 'Id'));
  if (id === null || identifier === null) {
    throw new StatementFileError(
      'incomplete_statement',
      `statement ${position} has no ${id === null ? 'identifier' : 'account identifier'}: there is nothing to attach its lines to`,
    );
  }
  if (identifier.kind === 'iban' && !isValidIban(identifier.value)) {
    report(
      'invalid_iban',
      `the account ${identifier.value} is written as an IBAN and fails its own check digits`,
    );
  }

  // Balances.
  const balances: StatementBalance[] = [];
  const scaledBalances = new Map<StatementBalance, bigint>();
  for (const bal of children(stmt, 'Bal')) {
    const type = text(bal, 'Tp', 'CdOrPrtry', 'Cd') ?? text(bal, 'Tp', 'CdOrPrtry', 'Prtry') ?? '';
    const signed = signedAmount(child(bal, 'Amt'), text(bal, 'CdtDbtInd'));
    if (signed === null || signed.currency === null) {
      report(
        'invalid_amount',
        `the ${type || 'unnamed'} balance "${child(bal, 'Amt')?.text.trim() ?? ''}" is not an amount with a direction and a currency`,
      );
      continue;
    }
    const balance: StatementBalance = {
      type,
      amount: signed.text,
      currency: signed.currency,
      date: dayOf(child(bal, 'Dt'), `the date of the ${type} balance`),
    };
    balances.push(balance);
    scaledBalances.set(balance, signed.scaled);
  }
  const openingBalance =
    balances.find((balance) => balance.type === 'OPBD') ??
    balances.find((balance) => balance.type === 'PRCD') ??
    null;
  const closingBalance = balances.find((balance) => balance.type === 'CLBD') ?? null;
  if (!openingBalance) {
    report('opening_balance_missing', 'the statement carries no opening booked balance (OPBD or PRCD)');
  }
  if (!closingBalance) {
    report('closing_balance_missing', 'the statement carries no closing booked balance (CLBD)');
  }

  const accountCurrency =
    text(acct, 'Ccy') ?? openingBalance?.currency ?? closingBalance?.currency ?? null;
  let checkable = openingBalance !== null && closingBalance !== null;
  for (const balance of [openingBalance, closingBalance]) {
    if (balance && accountCurrency !== null && balance.currency !== accountCurrency) {
      report(
        'balance_currency_mismatch',
        `the ${balance.type} balance is in ${balance.currency} and the account in ${accountCurrency}`,
      );
      checkable = false;
    }
  }

  // Lines.
  const lines: StatementLine[] = [];
  let movement = 0n;
  const bankReferences = new Map<string, number>();
  const entryReferences = new Map<string, number>();

  children(stmt, 'Ntry').forEach((ntry, entryIndex) => {
    const entry = entryIndex + 1;
    const first = lines.length + 1;
    const direction = text(ntry, 'CdtDbtInd');
    const status = text(ntry, 'Sts', 'Cd') ?? text(ntry, 'Sts', 'Prtry') ?? text(ntry, 'Sts') ?? '';
    const booked = status === 'BOOK';
    const reversal = text(ntry, 'RvslInd') === 'true' || text(ntry, 'RvslInd') === '1';
    const amount = signedAmount(child(ntry, 'Amt'), direction);
    const entryBankReference = text(ntry, 'AcctSvcrRef');
    const entryReference = text(ntry, 'NtryRef');

    if (direction !== 'CRDT' && direction !== 'DBIT') {
      report('invalid_direction', `entry ${entry} is neither a credit nor a debit ("${direction ?? ''}")`, first);
    } else if (amount === null) {
      report('invalid_amount', `the amount of entry ${entry}, "${child(ntry, 'Amt')?.text.trim() ?? ''}", is not an amount`, first);
    }
    if (amount === null) {
      if (booked) checkable = false;
    } else {
      if (accountCurrency !== null && amount.currency !== accountCurrency) {
        report(
          'foreign_currency_entry',
          `entry ${entry} is in ${amount.currency ?? 'no currency'} and the account in ${accountCurrency ?? 'none'}; it is reported, not converted`,
          first,
        );
        if (booked) checkable = false;
      } else if (booked) {
        movement += amount.scaled;
      }
    }

    for (const [reference, seen, code, what] of [
      [entryBankReference, bankReferences, 'duplicate_bank_reference', 'bank reference'],
      [entryReference, entryReferences, 'duplicate_entry_reference', 'entry reference'],
    ] as const) {
      if (reference === null) continue;
      const earlier = seen.get(reference);
      if (earlier === undefined) seen.set(reference, entry);
      else report(code, `entries ${earlier} and ${entry} carry the same ${what}, ${reference}`, first);
    }

    const bookingDate = dayOf(child(ntry, 'BookgDt'), `the booking date of entry ${entry}`, first);
    const valueDate = dayOf(child(ntry, 'ValDt'), `the value date of entry ${entry}`, first);
    if (booked && child(ntry, 'BookgDt') === undefined) {
      report('booking_date_missing', `entry ${entry} has no booking date`, first);
    }

    // The transactions under the entry, and whether they can stand for it.
    const details = children(ntry, 'NtryDtls').flatMap((block) => children(block, 'TxDtls'));
    const batchCount = children(ntry, 'NtryDtls')
      .map((block) => text(block, 'Btch', 'NbOfTxs'))
      .find((count) => count !== null);
    if (batchCount !== undefined && details.length > 0 && Number(batchCount) !== details.length) {
      report(
        'batch_count_mismatch',
        `entry ${entry} announces ${batchCount} transactions and details ${details.length}`,
        first,
      );
    }

    let parts: Signed[] | null = null;
    if (details.length >= 2 && amount !== null) {
      const read = details.map((detail) =>
        signedAmount(
          child(detail, 'Amt') ?? descend(detail, 'AmtDtls', 'TxAmt', 'Amt'),
          text(detail, 'CdtDbtInd') ?? direction,
        ),
      );
      const whole = read.every((part) => part !== null && part.currency === amount.currency);
      const sum = whole ? (read as Signed[]).reduce((total, part) => total + part.scaled, 0n) : null;
      if (whole && sum === amount.scaled) {
        parts = read as Signed[];
      } else {
        report(
          'batch_not_split',
          whole
            ? `the ${details.length} transactions of entry ${entry} add up to ${formatScaled(sum as bigint)} and the entry is ${amount.text}; it is kept as one line`
            : `the ${details.length} transactions of entry ${entry} do not each carry an amount in ${amount.currency ?? 'the entry currency'}; it is kept as one line`,
          first,
        );
      }
    }

    const build = (detail: XmlElement | undefined, part: Signed | null, nth: number | null): void => {
      const lineAmount = part ?? amount;
      const refs = child(detail, 'Refs');
      const parties = child(detail, 'RltdPties');
      const agents = child(detail, 'RltdAgts');
      // Who is on the other side: the debtor of money coming in, the creditor
      // of money going out — and the reverse when the entry undoes an earlier
      // one, where the parties keep the roles they had in the original.
      const credit = lineAmount !== null ? lineAmount.scaled >= 0n : direction === 'CRDT';
      const side = credit !== reversal ? 'Dbtr' : 'Cdtr';
      const account = accountIdentifier(descend(parties, `${side}Acct`, 'Id'));
      const counterparty: Counterparty = {
        name: partyName(child(parties, side)),
        account,
        agentBic: bic(child(agents, `${side}Agt`)),
        ultimateName: partyName(child(parties, `Ultmt${side}`)),
      };
      const index = lines.length + 1;
      if (account?.kind === 'iban' && !isValidIban(account.value)) {
        report(
          'invalid_iban',
          `the counterparty account ${account.value} is written as an IBAN and fails its own check digits`,
          index,
        );
      }
      const amountDetails = child(detail, 'AmtDtls') ?? child(ntry, 'AmtDtls');
      const instructed = descend(amountDetails, 'InstdAmt', 'Amt');
      const instructedCurrency = instructed?.attributes['Ccy'];
      lines.push({
        index,
        entry,
        detail: nth,
        detailCount: nth === null ? null : details.length,
        status,
        booked,
        reversal,
        bookingDate,
        valueDate,
        amount: lineAmount?.text ?? null,
        currency: lineAmount?.currency ?? null,
        entryAmount: nth === null ? null : (amount?.text ?? null),
        bankReference: text(refs, 'AcctSvcrRef') ?? entryBankReference,
        entryReference,
        endToEndId: text(refs, 'EndToEndId'),
        transactionId: text(refs, 'TxId'),
        instructionId: text(refs, 'InstrId'),
        paymentInformationId: text(refs, 'PmtInfId'),
        mandateId: text(refs, 'MndtId'),
        counterparty: Object.values(counterparty).every((value) => value === null)
          ? null
          : counterparty,
        remittance: remittance(child(detail, 'RmtInf')),
        bankTransactionCode:
          bankTransactionCode(child(detail, 'BkTxCd')) ?? bankTransactionCode(child(ntry, 'BkTxCd')),
        returnReason: text(detail, 'RtrInf', 'Rsn', 'Cd') ?? text(detail, 'RtrInf', 'Rsn', 'Prtry'),
        instructedAmount:
          instructed && instructedCurrency !== undefined && parseUnsigned(instructed.text) !== null
            ? { amount: signedText(instructed.text, false), currency: instructedCurrency }
            : null,
        exchangeRate:
          text(amountDetails, 'InstdAmt', 'CcyXchg', 'XchgRate') ??
          text(amountDetails, 'TxAmt', 'CcyXchg', 'XchgRate') ??
          text(amountDetails, 'CntrValAmt', 'CcyXchg', 'XchgRate'),
        additionalInformation: text(detail, 'AddtlTxInf') ?? text(ntry, 'AddtlNtryInf'),
      });
    };

    if (parts) details.forEach((detail, nth) => build(detail, (parts as Signed[])[nth] as Signed, nth + 1));
    else build(details.length === 1 ? details[0] : undefined, null, null);
  });

  // Opening plus what was booked is the closing, or the file says so.
  let balanced: boolean | null = null;
  if (checkable && openingBalance && closingBalance) {
    const opening = scaledBalances.get(openingBalance) as bigint;
    const closing = scaledBalances.get(closingBalance) as bigint;
    const computed = opening + movement;
    balanced = computed === closing;
    if (!balanced) {
      report(
        'balance_mismatch',
        `opening ${openingBalance.amount} plus booked entries ${formatScaled(movement)} is ${formatScaled(computed)}, and the statement closes at ${closingBalance.amount}: a difference of ${formatScaled(closing - computed)} ${closingBalance.currency}`,
      );
    }
  }

  const pagination = child(stmt, 'StmtPgntn');
  const period = child(stmt, 'FrToDt');
  if (!VERIFIED_VERSIONS.includes(version)) {
    report(
      'version_not_verified',
      `camt.053.001.${version} is read, and is not a version this package is tested against`,
    );
  }

  return {
    id,
    electronicSequenceNumber: text(stmt, 'ElctrncSeqNb'),
    legalSequenceNumber: text(stmt, 'LglSeqNb'),
    createdAt: text(stmt, 'CreDtTm'),
    period: period
      ? {
          from: dayOf(child(period, 'FrDtTm'), 'the start of the period'),
          to: dayOf(child(period, 'ToDtTm'), 'the end of the period'),
        }
      : null,
    page: pagination
      ? {
          number: text(pagination, 'PgNb') ?? '',
          last: ['true', '1'].includes(text(pagination, 'LastPgInd') ?? ''),
        }
      : null,
    account: {
      identifier,
      currency: text(acct, 'Ccy'),
      name: text(acct, 'Nm'),
      ownerName: text(acct, 'Ownr', 'Nm'),
      servicerBic: bic(child(acct, 'Svcr')),
    },
    openingBalance,
    closingBalance,
    balances,
    lines,
    balanced,
  };
}

/**
 * Read a camt.053 file — a string, or the bytes as they came — into its
 * statements, their lines, and what does not add up.
 *
 * Throws a `StatementFileError` for what is not a readable camt.053 at all.
 * Everything else comes back, with the trouble named in `violations` and
 * nothing silently repaired: a closing balance that does not follow from the
 * opening one is returned as the bank wrote it, and reported.
 */
export function readCamt053(input: string | Uint8Array, options: ReadOptions = {}): StatementFile {
  const root = parseXml(input, {
    maxBytes: options.maxBytes ?? DEFAULTS.maxBytes,
    maxDepth: options.maxDepth ?? DEFAULTS.maxDepth,
    maxElements: options.maxElements ?? DEFAULTS.maxElements,
  });
  const match = NAMESPACE.exec(root.namespace);
  if (root.name !== 'Document' || !match) {
    throw new StatementFileError(
      'not_a_statement',
      `the document element is <${root.name}> in "${root.namespace}", not a camt.053 Document`,
    );
  }
  if (match[1] === '01') {
    throw new StatementFileError(
      'unsupported_version',
      'camt.053.001.01 is another message under the same name — other elements for the message, the balances and the account — and is refused rather than half read',
    );
  }
  const message = child(root, 'BkToCstmrStmt');
  const stmts = children(message, 'Stmt');
  if (stmts.length === 0) {
    throw new StatementFileError('incomplete_statement', 'the file holds no statement (Stmt)');
  }
  const version = match[1] as string;
  const violations: Violation[] = [];
  const statements = stmts.map((stmt, index) => readStatement(stmt, index + 1, version, violations));
  return {
    namespace: root.namespace,
    version,
    versionVerified: VERIFIED_VERSIONS.includes(version),
    messageId: text(message, 'GrpHdr', 'MsgId'),
    createdAt: text(message, 'GrpHdr', 'CreDtTm'),
    statements,
    violations,
  };
}
