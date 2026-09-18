import { ibanOf, isValidIban } from './checks.js';
import { formatAmount, parseSigned, parseUnsigned } from './decimal.js';
import { StatementFileError } from './errors.js';
import { decode, splitRecords } from './records.js';
import type {
  AccountIdentifier,
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

export { ibanOf, isValidIban, ribKey } from './checks.js';
export { StatementFileError, type StatementFileErrorCode } from './errors.js';
export type * from './types.js';

/** Every record of a CFONB 120 file is this long, the line break not counted. */
export const RECORD_LENGTH = 120;

const DEFAULTS = { maxBytes: 32 * 1024 * 1024, pivotYear: 80 };

// --- positions ---------------------------------------------------------------

/** Positions `from` to `to` of a record, counted from 1 and inclusive, as the brochure writes them. */
function at(record: string, from: number, to: number = from): string {
  return record.slice(from - 1, to);
}

/** A zone as text: blanks around it gone, null when nothing is left. */
function zone(record: string, from: number, to: number): string | null {
  const value = at(record, from, to).trim();
  return value === '' ? null : value;
}

// --- what the records are, before anything is made of them --------------------

interface Movement {
  record: number;
  r04: string;
  complements: string[];
}

interface Raw {
  /** Which record of the file opened it, from 1. */
  record: number;
  oldBalance: string;
  movements: Movement[];
  newBalance: string;
}

/**
 * Bank, branch, currency, decimals and account: zones B and D to H, which the
 * brochure says are identical in every record of one statement. Zone G is
 * reserved, and left out: a bank that writes something there is not another
 * account.
 */
function identity(record: string): string {
  return `${at(record, 3, 7)}|${at(record, 12, 20)}|${at(record, 22, 32)}`;
}

function gather(records: string[]): Raw[] {
  const out: Raw[] = [];
  let current: { record: number; oldBalance: string; movements: Movement[] } | null = null;
  let previous = '';

  records.forEach((record, index) => {
    const code = at(record, 1, 2);
    const refuse = (message: string): never => {
      throw new StatementFileError('unexpected_record', message, index + 1);
    };
    if (!['01', '04', '05', '07'].includes(code)) {
      throw new StatementFileError(
        'unknown_record',
        `record code "${code}": a statement of account has 01, 04, 05 and 07`,
        index + 1,
      );
    }
    if (code === '01') {
      if (current) refuse('an old balance, and the statement before it has no new balance');
      current = { record: index + 1, oldBalance: record, movements: [] };
    } else {
      if (!current) return refuse(`a record ${code} before any old balance`);
      if (identity(record) !== identity(current.oldBalance)) {
        throw new StatementFileError(
          'inconsistent_record',
          `bank, branch, currency, decimals and account are "${identity(record)}" here and "${identity(current.oldBalance)}" on the old balance of the statement: a record of another account, or of another currency, in the middle of this one`,
          index + 1,
        );
      }
      if (code === '04') current.movements.push({ record: index + 1, r04: record, complements: [] });
      else if (code === '05') {
        const movement = current.movements[current.movements.length - 1];
        if (!movement || (previous !== '04' && previous !== '05')) {
          return refuse('a complement that follows no movement');
        }
        movement.complements.push(record);
      } else {
        out.push({ ...current, newBalance: record });
        current = null;
      }
    }
    previous = code;
  });

  if (current) {
    throw new StatementFileError(
      'incomplete_statement',
      `the statement that begins at record ${(current as { record: number }).record} has no new balance: the file stops before its end`,
    );
  }
  return out;
}

// --- small readers -----------------------------------------------------------

/** `JJMMAA` to `YYYY-MM-DD`: null when blank or zeros, undefined when it is not a date. */
function day(field: string, pivotYear: number): string | null | undefined {
  if (field === '000000' || field.trim() === '') return null;
  if (!/^[0-9]{6}$/.test(field)) return undefined;
  const date = Number(field.slice(0, 2));
  const month = Number(field.slice(2, 4));
  const short = Number(field.slice(4, 6));
  const year = (short >= pivotYear ? 1900 : 2000) + short;
  if (month < 1 || month > 12 || date < 1) return undefined;
  const leap = (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
  const length = [31, leap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1] as number;
  if (date > length) return undefined;
  return `${year}-${field.slice(2, 4)}-${field.slice(0, 2)}`;
}

/** A counterparty's account: an IBAN when it passes ISO 13616, else what was written. */
function otherAccount(text: string | null): AccountIdentifier | null {
  if (text === null) return null;
  const value = text.replace(/\s+/g, '').toUpperCase();
  if (value === '') return null;
  if (isValidIban(value)) return { kind: 'iban', value };
  return { kind: 'other', value, scheme: null, issuer: null };
}

// --- a statement -------------------------------------------------------------

function readStatement(
  raw: Raw,
  position: number,
  options: { pivotYear: number; ibanCountry: string | null },
  violations: Violation[],
): Statement {
  const report = (code: ViolationCode, message: string, line?: number): void => {
    violations.push(
      line === undefined ? { code, message, statement: position } : { code, message, statement: position, line },
    );
  };
  const dayOf = (field: string, what: string, line?: number): string | null => {
    const value = day(field, options.pivotYear);
    if (value === undefined) {
      report('invalid_date', `${what} "${field}" is not a date (JJMMAA)`, line);
      return null;
    }
    return value;
  };

  const first = raw.oldBalance;
  const bankCode = at(first, 3, 7);
  const branchCode = at(first, 12, 16);
  const accountNumber = at(first, 22, 32).trim().toUpperCase();
  const currency = /^[A-Z]{3}$/.test(at(first, 17, 19)) ? at(first, 17, 19) : null;
  if (accountNumber === '' || !/^[0-9]$/.test(at(first, 20))) {
    throw new StatementFileError(
      'incomplete_statement',
      accountNumber === ''
        ? 'the old balance names no account: there is nothing to attach its lines to'
        : `the number of decimals is "${at(first, 20)}", which is not a digit: no amount of this statement can be read`,
      raw.record,
    );
  }
  const decimals = Number(at(first, 20));

  let identifier: AccountIdentifier = {
    kind: 'other',
    value: `${bankCode}${branchCode}${accountNumber}`.replace(/\s+/g, ''),
    scheme: null,
    issuer: null,
  };
  if (options.ibanCountry !== null) {
    const iban = ibanOf(options.ibanCountry, bankCode, branchCode, accountNumber);
    if (iban === null) {
      report(
        'invalid_iban',
        `bank code "${bankCode}", branch code "${branchCode}" and account number "${accountNumber}" do not make an IBAN in "${options.ibanCountry}": five digits, five digits, eleven letters or digits, and a country of two letters; the account is returned as written`,
      );
    } else identifier = { kind: 'iban', value: iban };
  }

  const balance = (
    type: 'OPBD' | 'CLBD',
    record: string,
    what: string,
  ): { balance: StatementBalance; scaled: bigint } | null => {
    const scaled = parseSigned(at(record, 91, 104));
    if (scaled === null) {
      report(
        'invalid_amount',
        `the ${what} balance "${at(record, 91, 104)}" is not thirteen digits and a last character that carries the sign ({ A–I, } J–R)`,
      );
      return null;
    }
    return {
      balance: {
        type,
        amount: formatAmount(scaled, decimals),
        currency,
        date: dayOf(at(record, 35, 40), `the date of the ${what} balance`),
      },
      scaled,
    };
  };
  const opening = balance('OPBD', raw.oldBalance, 'old');
  const closing = balance('CLBD', raw.newBalance, 'new');

  const lines: StatementLine[] = [];
  let checkable = opening !== null && closing !== null;
  let movementTotal = 0n;

  for (const movement of raw.movements) {
    const index = lines.length + 1;
    const record = movement.r04;
    const scaled = parseSigned(at(record, 91, 104));
    if (scaled === null) {
      checkable = false;
      report(
        'invalid_amount',
        `the amount of movement ${index}, "${at(record, 91, 104)}", is not thirteen digits and a last character that carries the sign ({ A–I, } J–R)`,
        index,
      );
    } else movementTotal += scaled;

    const bookingDate = dayOf(at(record, 35, 40), `the booking date of movement ${index}`, index);
    if (bookingDate === null) report('booking_date_missing', `movement ${index} has no booking date`, index);
    else if (
      (opening?.balance.date && bookingDate <= opening.balance.date) ||
      (closing?.balance.date && bookingDate > closing.balance.date)
    ) {
      report(
        'booking_date_outside_statement',
        `movement ${index} is booked on ${bookingDate}, and the statement runs after ${opening?.balance.date ?? '…'} and up to ${closing?.balance.date ?? '…'}`,
        index,
      );
    }

    // The complements, by qualifier. Zone 2b-M is positions 49 to 118; the
    // qualifiers that carry two zones cut it at 84.
    const complements = movement.complements.map((complement) => ({
      qualifier: at(complement, 46, 48),
      text: at(complement, 49, 118).trimEnd(),
      record: complement,
    }));
    const find = (qualifier: string): string | null =>
      complements.find((complement) => complement.qualifier === qualifier)?.record ?? null;
    const whole = (qualifier: string): string | null => {
      const complement = find(qualifier);
      return complement === null ? null : zone(complement, 49, 118);
    };
    const halves = (qualifier: string): [string | null, string | null] => {
      const complement = find(qualifier);
      return complement === null ? [null, null] : [zone(complement, 49, 83), zone(complement, 84, 118)];
    };

    const returnReason = ((): string | null => {
      const value = zone(record, 41, 42);
      return value === null || /^0+$/.test(value) ? null : value;
    })();
    const reversal = returnReason !== null;
    // Who is on the other side: the payer of money coming in, the beneficiary
    // of money going out — and the reverse on a rejected operation, where the
    // parties keep the roles they had in the original.
    const credit = scaled !== null && scaled >= 0n;
    const payer = credit !== reversal;
    const counterparty: Counterparty = {
      name: whole(payer ? 'NPY' : 'NBE'),
      account: otherAccount(halves(payer ? 'CPY' : 'CBE')[0]),
      agentBic: null,
      ultimateName: whole(payer ? 'NPO' : 'NBU'),
    };
    const [identifierValue, identifierType] = halves(payer ? 'IPY' : 'IBE');

    const remittance: Remittance = { unstructured: [], structured: [] };
    for (const complement of complements) {
      if (complement.qualifier === 'LIB' && complement.text.trim() !== '') {
        remittance.unstructured.push(complement.text.trim());
      }
    }
    const lcc = find('LCC');
    const lc2 = find('LC2');
    const client = `${lcc ? at(lcc, 49, 118) : ''}${lc2 ? at(lc2, 49, 118) : ''}`.trim();
    if (client !== '') remittance.unstructured.push(client);
    const structured = halves('LCS')[0];
    if (structured !== null) remittance.structured.push({ reference: structured, type: null, issuer: null });

    const [endToEndId, purpose] = halves('RCN');
    const [paymentInformationId, instructionId] = halves('REF');
    const mandate = find('RUM');

    let instructedAmount: StatementLine['instructedAmount'] = null;
    let exchangeRate: string | null = null;
    const origin = find('MMO');
    if (origin !== null) {
      const originCurrency = at(origin, 49, 51);
      const originAmount = parseUnsigned(at(origin, 53, 66));
      if (/^[A-Z]{3}$/.test(originCurrency) && /^[0-9]$/.test(at(origin, 52)) && originAmount !== null) {
        instructedAmount = { amount: formatAmount(originAmount, Number(at(origin, 52))), currency: originCurrency };
      }
      const rate = parseUnsigned(at(origin, 69, 79));
      if (/^[0-9]{2}$/.test(at(origin, 67, 68)) && rate !== null && rate !== 0n) {
        exchangeRate = formatAmount(rate, Number(at(origin, 67, 68)));
      }
    }

    const entryNumber = zone(record, 82, 88);
    const interbank = zone(record, 33, 34);
    lines.push({
      index,
      entry: index,
      detail: null,
      detailCount: null,
      status: 'BOOK',
      booked: true,
      reversal,
      bookingDate,
      valueDate: dayOf(at(record, 43, 48), `the value date of movement ${index}`, index),
      amount: scaled === null ? null : formatAmount(scaled, decimals),
      currency,
      entryAmount: null,
      bankReference: null,
      entryReference: null,
      endToEndId,
      transactionId: null,
      instructionId,
      paymentInformationId,
      mandateId: mandate === null ? null : zone(mandate, 49, 83),
      counterparty: Object.values(counterparty).every((value) => value === null) ? null : counterparty,
      remittance,
      bankTransactionCode:
        interbank === null
          ? null
          : { domain: null, family: null, subFamily: null, proprietary: interbank, proprietaryIssuer: 'CFONB' },
      returnReason,
      instructedAmount,
      exchangeRate,
      additionalInformation: zone(record, 49, 79),
      internalOperationCode: zone(record, 8, 11),
      interbankOperationCode: interbank,
      entryNumber: entryNumber === null || /^0+$/.test(entryNumber) ? null : entryNumber,
      commissionExempt: at(record, 89) === '1',
      unavailable: at(record, 90) === '1',
      referenceZone: zone(record, 105, 120),
      purpose,
      sequenceType: mandate === null ? null : zone(mandate, 84, 87),
      counterpartyIdentifier: identifierValue === null ? null : { value: identifierValue, type: identifierType },
      complements: complements.map(({ qualifier, text }) => ({ qualifier, text })),
    });
  }

  // Old balance plus what moved is the new balance, or the file says so.
  let balanced: boolean | null = null;
  if (checkable && opening && closing) {
    const computed = opening.scaled + movementTotal;
    balanced = computed === closing.scaled;
    if (!balanced) {
      report(
        'balance_mismatch',
        `old balance ${opening.balance.amount} plus movements ${formatAmount(movementTotal, decimals)} is ${formatAmount(computed, decimals)}, and the statement closes at ${closing.balance.amount}: a difference of ${formatAmount(closing.scaled - computed, decimals)}${currency ? ` ${currency}` : ''}`,
      );
    }
  }

  const balances = [opening?.balance, closing?.balance].filter(
    (item): item is StatementBalance => item !== undefined && item !== null,
  );
  return {
    id: `${opening?.balance.date ?? at(raw.oldBalance, 35, 40)}/${closing?.balance.date ?? at(raw.newBalance, 35, 40)}`,
    electronicSequenceNumber: null,
    legalSequenceNumber: null,
    createdAt: null,
    period: null,
    page: null,
    account: {
      identifier,
      currency,
      name: null,
      ownerName: null,
      servicerBic: null,
      bankCode,
      branchCode,
      accountNumber,
      decimals,
    },
    openingBalance: opening?.balance ?? null,
    closingBalance: closing?.balance ?? null,
    balances,
    lines,
    balanced,
  };
}

/**
 * Read a CFONB 120 file — a string, or the bytes as they came — into its
 * statements, their lines, and what does not add up.
 *
 * Throws a `StatementFileError` for what is not a readable CFONB 120 at all: a
 * record of the wrong length, an unknown record, a record out of place or of
 * another account, an encoding that is not the one announced. Everything else
 * comes back, with the trouble named in `violations` and nothing silently
 * repaired: a new balance that does not follow from the old one is returned as
 * the bank wrote it, and reported.
 */
export function readCfonb120(input: string | Uint8Array, options: ReadOptions = {}): StatementFile {
  const text = decode(input, options.encoding ?? 'utf-8', options.maxBytes ?? DEFAULTS.maxBytes);
  const records = splitRecords(text, RECORD_LENGTH);
  const violations: Violation[] = [];
  const settings = {
    pivotYear: options.pivotYear ?? DEFAULTS.pivotYear,
    ibanCountry: options.ibanCountry === undefined ? null : options.ibanCountry.toUpperCase(),
  };
  const statements = gather(records).map((raw, index) => readStatement(raw, index + 1, settings, violations));
  return { format: 'cfonb120', version: null, namespace: 'cfonb120', statements, violations };
}
