import {
  isValidBelgianReference,
  isValidCreditorReference,
  isValidIban,
} from './checks.js';
import { formatAmount, parseAmount } from './decimal.js';
import { StatementFileError } from './errors.js';
import { decode, splitRecords } from './records.js';
import type {
  AccountIdentifier,
  CodaTransactionCode,
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

export { formatBelgianReference, isValidBelgianReference, isValidCreditorReference, isValidIban } from './checks.js';
export { StatementFileError, type StatementFileErrorCode } from './errors.js';
export type * from './types.js';

/** Every record of a CODA file is this long, the line break not counted. */
export const RECORD_LENGTH = 128;

const DEFAULTS = { maxBytes: 32 * 1024 * 1024, pivotYear: 80 };

// --- positions ---------------------------------------------------------------

/** Positions `from` to `to` of a record, counted from 1 and inclusive, as the standard writes them. */
function at(record: string, from: number, to: number = from): string {
  return record.slice(from - 1, to);
}

/** A zone as text: trailing and leading blanks gone, null when nothing is left. */
function zone(record: string | null, from: number, to: number): string | null {
  if (record === null) return null;
  const value = at(record, from, to).trim();
  return value === '' ? null : value;
}

// --- what the records are, before anything is made of them --------------------

interface Information {
  r31: string;
  r32: string | null;
  r33: string | null;
}

interface Movement {
  /** Where its 2.1 stands in the file, from 1. */
  record: number;
  r21: string;
  r22: string | null;
  r23: string | null;
  information: Information[];
}

interface Raw {
  /** Which record of the file opened it, from 1. */
  record: number;
  header: string;
  oldBalance: string | null;
  movements: Movement[];
  newBalance: string | null;
  free: string[];
  trailer: string | null;
  /** Records 1, 2.x, 3.x and 8: what the trailer counts. */
  counted: number;
}

function gather(records: string[]): Raw[] {
  const out: Raw[] = [];
  let current: Raw | null = null;
  let previous = '';

  const refuse = (index: number, message: string): never => {
    throw new StatementFileError('unexpected_record', message, index + 1);
  };

  records.forEach((record, index) => {
    const identification = at(record, 1);
    const article = at(record, 2);
    const kind = identification === '2' || identification === '3' ? identification + article : identification;

    if (kind === '0') {
      if (current) refuse(index, 'a header record, and the statement before it has no trailer record');
      if (at(record, 128) !== '2') {
        throw new StatementFileError(
          'unsupported_version',
          `the version code is "${at(record, 128)}", and this reader reads version 2 of the standard; version 1 is another lay-out under the same name`,
          index + 1,
        );
      }
      current = {
        record: index + 1,
        header: record,
        oldBalance: null,
        movements: [],
        newBalance: null,
        free: [],
        trailer: null,
        counted: 0,
      };
      previous = kind;
      return;
    }
    if (!['1', '21', '22', '23', '31', '32', '33', '4', '8', '9'].includes(kind)) {
      throw new StatementFileError(
        'unknown_record',
        identification === '2' || identification === '3'
          ? `record identification ${identification} with article code "${article}": the standard has articles 1, 2 and 3`
          : `record identification "${identification}": the standard has 0, 1, 2, 3, 4, 8 and 9`,
        index + 1,
      );
    }
    if (!current) return refuse(index, `a record ${kind} before any header record`);
    const statement: Raw = current;
    const movement = statement.movements[statement.movements.length - 1];
    const sameMovement = (): boolean =>
      movement !== undefined && at(record, 3, 10) === at(movement.r21, 3, 10);

    switch (kind) {
      case '1':
        if (previous !== '0') refuse(index, 'an old balance record that does not follow a header record');
        statement.oldBalance = record;
        break;
      case '21':
        if (!statement.oldBalance || statement.newBalance) {
          refuse(index, 'a movement record outside the old and the new balance');
        }
        statement.movements.push({ record: index + 1, r21: record, r22: null, r23: null, information: [] });
        break;
      case '22':
        if (previous !== '21' || !sameMovement()) refuse(index, 'a record 2.2 that does not follow its record 2.1');
        (movement as Movement).r22 = record;
        break;
      case '23':
        if ((previous !== '21' && previous !== '22') || !sameMovement()) {
          refuse(index, 'a record 2.3 that does not follow its record 2.1 or 2.2');
        }
        (movement as Movement).r23 = record;
        break;
      case '31':
        if (!movement || statement.newBalance || at(record, 3, 6) !== at(movement.r21, 3, 6)) {
          refuse(index, 'an information record that refers to no movement before it');
        }
        (movement as Movement).information.push({ r31: record, r32: null, r33: null });
        break;
      case '32':
      case '33': {
        const information = movement?.information[movement.information.length - 1];
        const follows = kind === '32' ? previous === '31' : previous === '31' || previous === '32';
        if (!information || !follows || at(record, 3, 10) !== at(information.r31, 3, 10)) {
          refuse(index, `a record 3.${kind[1]} that does not follow its record 3.1`);
        }
        if (kind === '32') (information as Information).r32 = record;
        else (information as Information).r33 = record;
        break;
      }
      case '8':
        if (!statement.oldBalance || statement.newBalance) {
          refuse(index, 'a new balance record without an old one, or a second one');
        }
        statement.newBalance = record;
        break;
      case '4':
        if (!statement.oldBalance) refuse(index, 'a free communication before the old balance');
        statement.free.push(record);
        break;
      case '9':
        if (!statement.oldBalance) refuse(index, 'a trailer record for a statement that has no old balance');
        statement.trailer = record;
        out.push(statement);
        current = null;
        break;
    }
    if (kind !== '4' && kind !== '9') statement.counted += 1;
    previous = kind;
  });

  if (current) {
    throw new StatementFileError(
      'incomplete_statement',
      `the statement that begins at record ${(current as Raw).record} has no trailer record: the file stops before its end`,
    );
  }
  return out;
}

// --- small readers -----------------------------------------------------------

/** `DDMMYY` to `YYYY-MM-DD`: null when the bank writes zeros, undefined when it is not a date. */
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

/** The thirty-seven positions of "account number and currency code", by the structure record 1 announces. */
function ownAccount(
  area: string,
  structure: string,
): { identifier: AccountIdentifier; currency: string | null } | null {
  const compact = (text: string): string => text.replace(/\s+/g, '').toUpperCase();
  const currency = (text: string): string | null => (/^[A-Z]{3}$/.test(text) ? text : null);
  switch (structure) {
    case '0':
      return {
        identifier: { kind: 'other', value: compact(area.slice(0, 12)), scheme: 'BBAN', issuer: null },
        currency: currency(area.slice(13, 16)),
      };
    case '1':
      return {
        identifier: { kind: 'other', value: compact(area.slice(0, 34)), scheme: 'BBAN', issuer: null },
        currency: currency(area.slice(34, 37)),
      };
    case '2':
      return { identifier: { kind: 'iban', value: compact(area.slice(0, 31)) }, currency: currency(area.slice(34, 37)) };
    case '3':
      return { identifier: { kind: 'iban', value: compact(area.slice(0, 34)) }, currency: currency(area.slice(34, 37)) };
    default:
      return null;
  }
}

/**
 * The counterparty's account, which comes "in the structure of the initial
 * payment" and announces nothing: an IBAN when it passes ISO 13616, else what
 * was written. The old domestic lay-out — twelve digits, a blank, a currency —
 * is recognised so that the currency is not read as part of the number.
 */
function otherAccount(area: string): AccountIdentifier | null {
  const domestic = /^([0-9]{12}) /.exec(area);
  const value = (domestic ? (domestic[1] as string) : area.slice(0, 34)).replace(/\s+/g, '').toUpperCase();
  if (value === '' || /^0+$/.test(value)) return null;
  if (isValidIban(value)) return { kind: 'iban', value };
  return { kind: 'other', value, scheme: null, issuer: null };
}

interface Communication {
  free: string | null;
  structured: { type: string; text: string } | null;
}

function communication(flag: string, text: string): Communication {
  if (flag === '1') {
    return { free: null, structured: { type: text.slice(0, 3), text: text.slice(3).trimEnd() } };
  }
  const free = text.trim();
  return { free: free === '' ? null : free, structured: null };
}

/** One record 2.1 with its 2.2 and 2.3, as fields. */
interface Parsed {
  movement: Movement;
  sequenceNumber: string;
  detailNumber: string;
  type: string;
  /** Thousandths, signed; null when the amount or its sign is unreadable. */
  amount: bigint | null;
  children: Parsed[];
}

function parse(movement: Movement): Parsed {
  const sign = at(movement.r21, 32);
  const unsigned = parseAmount(at(movement.r21, 33, 47));
  return {
    movement,
    sequenceNumber: at(movement.r21, 3, 6),
    detailNumber: at(movement.r21, 7, 10),
    type: at(movement.r21, 54),
    amount: unsigned === null || (sign !== '0' && sign !== '1') ? null : sign === '1' ? -unsigned : unsigned,
    children: [],
  };
}

// --- a statement -------------------------------------------------------------

function readStatement(raw: Raw, position: number, pivotYear: number, violations: Violation[]): Statement {
  const report = (code: ViolationCode, message: string, line?: number): void => {
    violations.push(
      line === undefined ? { code, message, statement: position } : { code, message, statement: position, line },
    );
  };
  const dayOf = (field: string, what: string, line?: number): string | null => {
    const value = day(field, pivotYear);
    if (value === undefined) {
      report('invalid_date', `${what} "${field}" is not a date (DDMMYY)`, line);
      return null;
    }
    return value;
  };

  const header = raw.header;
  const oldBalance = raw.oldBalance as string;

  // The account, which the old and the new balance both name.
  const structure = at(oldBalance, 2);
  const account = ownAccount(at(oldBalance, 6, 42), structure);
  if (account === null || account.identifier.value === '') {
    throw new StatementFileError(
      'incomplete_statement',
      account === null
        ? `the account structure is "${structure}", and the standard has 0, 1, 2 and 3`
        : 'the old balance record names no account: there is nothing to attach its lines to',
      raw.record + 1,
    );
  }
  if (raw.newBalance) {
    const again = ownAccount(at(raw.newBalance, 5, 41), structure);
    if (again?.identifier.value !== account.identifier.value || again.currency !== account.currency) {
      throw new StatementFileError(
        'inconsistent_record',
        `the old balance is of account ${account.identifier.value} ${account.currency ?? ''} and the new balance of ${again?.identifier.value ?? ''} ${again?.currency ?? ''}`.trimEnd(),
        raw.record + 1,
      );
    }
  }
  if (account.identifier.kind === 'iban' && !isValidIban(account.identifier.value)) {
    report('invalid_iban', `the account ${account.identifier.value} is written as an IBAN and fails its own check digits`);
  }
  if (account.currency === null) {
    report('currency_missing', 'the account zone carries no currency code: the amounts are returned without one');
  }

  // Balances.
  const balance = (
    type: 'OPBD' | 'CLBD',
    sign: string,
    figure: string,
    date: string,
    what: string,
  ): { balance: StatementBalance; scaled: bigint } | null => {
    const unsigned = parseAmount(figure);
    if (unsigned === null || (sign !== '0' && sign !== '1')) {
      report('invalid_amount', `the ${what} balance "${figure}" with sign "${sign}" is not fifteen digits and a sign of 0 or 1`);
      return null;
    }
    const scaled = sign === '1' ? -unsigned : unsigned;
    return {
      balance: { type, amount: formatAmount(scaled), currency: account.currency, date: dayOf(date, `the date of the ${what} balance`) },
      scaled,
    };
  };
  const opening = balance('OPBD', at(oldBalance, 43), at(oldBalance, 44, 58), at(oldBalance, 59, 64), 'old');
  const closing = raw.newBalance
    ? balance('CLBD', at(raw.newBalance, 42), at(raw.newBalance, 43, 57), at(raw.newBalance, 58, 63), 'new')
    : null;
  if (!raw.newBalance) {
    report(
      'closing_balance_missing',
      raw.movements.length === 0
        ? 'the file carries no new balance record, which is how the standard writes a day without movement: nothing is checked, and nothing is invented'
        : 'the file carries movements and no new balance record',
    );
  }

  // Movements, grouped by continuous sequence number.
  const groups: Parsed[][] = [];
  for (const movement of raw.movements) {
    const parsed = parse(movement);
    const group = groups[groups.length - 1];
    if (group && (group[0] as Parsed).sequenceNumber === parsed.sequenceNumber) group.push(parsed);
    else groups.push([parsed]);
  }

  const lines: StatementLine[] = [];
  let checkable = opening !== null && closing !== null;
  let totalsReadable = true;
  let movementTotal = 0n;
  let debitTotal = 0n;
  let creditTotal = 0n;

  const build = (
    parsed: Parsed,
    entry: number,
    part: { nth: number; count: number; whole: bigint } | null,
    fallback: Parsed | null,
  ): void => {
    const index = lines.length + 1;
    const { r21, r22, r23, information } = parsed.movement;
    const sign = at(r21, 32);
    if (sign !== '0' && sign !== '1') {
      report('invalid_direction', `movement ${parsed.sequenceNumber}/${parsed.detailNumber} is neither a credit nor a debit ("${sign}")`, index);
    } else if (parsed.amount === null) {
      report('invalid_amount', `the amount of movement ${parsed.sequenceNumber}/${parsed.detailNumber}, "${at(r21, 33, 47)}", is not fifteen digits`, index);
    }

    const said = communication(
      at(r21, 62),
      at(r21, 63, 115) + (r22 ? at(r22, 11, 63) : '') + (r23 ? at(r23, 83, 125) : ''),
    );
    const remittance: Remittance = { unstructured: said.free === null ? [] : [said.free], structured: [] };
    let mandateId: string | null = null;
    let returnReason = zone(r22, 114, 117);
    if (said.structured) {
      const { type, text } = said.structured;
      if (type === '101' || type === '102') {
        const digits = text.slice(0, 12);
        remittance.structured.push({ reference: digits, type: 'SCOR', issuer: 'BBA' });
        if (!isValidBelgianReference(digits)) {
          report(
            'invalid_structured_reference',
            `the structured communication "${digits}" is not twelve digits whose last two are the first ten modulo 97; it is returned as written`,
            index,
          );
        }
      } else if (type === '100') {
        const reference = text.trim().toUpperCase();
        remittance.structured.push({ reference, type: 'SCOR', issuer: 'ISO' });
        if (!isValidCreditorReference(reference)) {
          report(
            'invalid_structured_reference',
            `the creditor reference "${reference}" fails the check digits of ISO 11649; it is returned as written`,
            index,
          );
        }
      } else if (type === '127') {
        // Settlement date 6, type 1, scheme 1, paid or reason 1, creditor 35,
        // mandate 35, communication 62, type of R-transaction 1, reason 4.
        mandateId = text.slice(44, 79).trim() || null;
        const free = text.slice(79, 141).trim();
        if (free !== '') remittance.unstructured.push(free);
        returnReason = returnReason ?? (text.slice(142, 146).trim() || null);
      }
    }

    const details = information.map((item) => {
      const read = communication(
        at(item.r31, 40),
        at(item.r31, 41, 113) + (item.r32 ? at(item.r32, 11, 115) : '') + (item.r33 ? at(item.r33, 11, 100) : ''),
      );
      return read.structured
        ? { type: read.structured.type, text: read.structured.text }
        : { type: null, text: read.free ?? '' };
    });
    const typed = (type: string): string | null =>
      details.find((detail) => detail.type === type)?.text.slice(0, 70).trim() || null;
    const credit = parsed.amount !== null ? parsed.amount >= 0n : sign === '0';
    const counterparty: Counterparty = {
      name: zone(r23, 48, 82) ?? typed('001'),
      account: r23 ? otherAccount(at(r23, 11, 47)) : null,
      agentBic: zone(r22, 99, 109),
      // 008 names the ultimate creditor and 009 the ultimate debtor: the one
      // behind the counterparty is the creditor of money going out.
      ultimateName: typed(credit ? '009' : '008'),
    };

    const code = at(r21, 54, 61);
    const transactionCode: CodaTransactionCode | null = /^[0-9]{8}$/.test(code)
      ? { type: code.slice(0, 1), family: code.slice(1, 3), transaction: code.slice(3, 5), category: code.slice(5, 8) }
      : null;
    const bankReference = (record: string): string | null => {
      const value = zone(record, 11, 31);
      return value === null || /^0+$/.test(value) ? null : value;
    };
    const customerReference = zone(r22, 64, 98);
    const total = parsed.type === '1' || parsed.type === '2';
    const free = details.filter((detail) => detail.type === null && detail.text !== '').map((detail) => detail.text);

    const bookingDate =
      dayOf(at(r21, 116, 121), `the entry date of movement ${parsed.sequenceNumber}/${parsed.detailNumber}`, index) ??
      (fallback ? day(at(fallback.movement.r21, 116, 121), pivotYear) ?? null : null);
    if (bookingDate === null) {
      report('booking_date_missing', `movement ${parsed.sequenceNumber}/${parsed.detailNumber} has no entry date`, index);
    }

    lines.push({
      index,
      entry,
      detail: part?.nth ?? null,
      detailCount: part?.count ?? null,
      status: 'BOOK',
      booked: true,
      reversal: transactionCode?.transaction === '49' || transactionCode?.transaction === '99',
      bookingDate,
      valueDate:
        dayOf(at(r21, 48, 53), `the value date of movement ${parsed.sequenceNumber}/${parsed.detailNumber}`, index) ??
        (fallback ? day(at(fallback.movement.r21, 48, 53), pivotYear) ?? null : null),
      amount: parsed.amount === null ? null : formatAmount(parsed.amount),
      currency: account.currency,
      entryAmount: part ? formatAmount(part.whole) : null,
      bankReference: bankReference(r21) ?? (fallback ? bankReference(fallback.movement.r21) : null),
      entryReference: null,
      endToEndId: total ? null : customerReference,
      transactionId: null,
      instructionId: null,
      paymentInformationId: total ? customerReference : null,
      mandateId,
      counterparty: Object.values(counterparty).every((value) => value === null) ? null : counterparty,
      remittance,
      bankTransactionCode: transactionCode
        ? { domain: null, family: null, subFamily: null, proprietary: code, proprietaryIssuer: 'CODA' }
        : null,
      returnReason,
      instructedAmount: null,
      exchangeRate: null,
      additionalInformation: free.length === 0 ? null : free.join(' '),
      sequenceNumber: parsed.sequenceNumber,
      detailNumber: parsed.detailNumber,
      transactionCode,
      globalisationCode: at(r21, 125),
      structuredCommunication: said.structured,
      rTransactionType: zone(r22, 113, 113),
      categoryPurpose: zone(r22, 118, 121),
      purpose: zone(r22, 122, 125),
      information: details,
    });
  };

  groups.forEach((group, groupIndex) => {
    const entry = groupIndex + 1;
    const first = lines.length + 1;
    const head = group[0] as Parsed;

    // A movement the statement counts is the record with detail number 0000:
    // that is what the trailer adds up, and so what the balance moved by.
    if (head.detailNumber !== '0000') {
      for (const orphan of group) build(orphan, entry, null, null);
      return;
    }
    if (head.amount === null) {
      checkable = false;
      totalsReadable = false;
    } else {
      movementTotal += head.amount;
      if (head.amount < 0n) debitTotal -= head.amount;
      else creditTotal += head.amount;
    }
    const rest = group.slice(1);
    if (rest.length === 0) return build(head, entry, null, null);

    // Details of the movement; a type 9 is the detail of the type 7 before it.
    const level: Parsed[] = [];
    for (const detail of rest) {
      const parent = level[level.length - 1];
      if (detail.type === '9' && parent) parent.children.push(detail);
      else level.push(detail);
    }
    const sum = (items: Parsed[]): bigint | null =>
      items.every((item) => item.amount !== null)
        ? items.reduce((total, item) => total + (item.amount as bigint), 0n)
        : null;
    const detailed = sum(level);
    if (head.amount === null || detailed !== head.amount) {
      report(
        'batch_not_split',
        detailed === null || head.amount === null
          ? `the ${level.length} details of movement ${head.sequenceNumber} do not each carry a readable amount; it is kept as one line`
          : `the ${level.length} details of movement ${head.sequenceNumber} add up to ${formatAmount(detailed)} and the movement is ${formatAmount(head.amount)}; it is kept as one line`,
        first,
      );
      return build(head, entry, null, null);
    }
    const leaves: { parsed: Parsed; fallback: Parsed }[] = [];
    for (const item of level) {
      if (item.children.length === 0) leaves.push({ parsed: item, fallback: head });
      else if (sum(item.children) === item.amount) {
        for (const child of item.children) leaves.push({ parsed: child, fallback: item });
      } else {
        report(
          'batch_not_split',
          `the ${item.children.length} details of detail ${item.sequenceNumber}/${item.detailNumber} do not add up to it; it is kept as one line`,
          lines.length + leaves.length + 1,
        );
        leaves.push({ parsed: item, fallback: head });
      }
    }
    leaves.forEach((leaf, nth) =>
      build(
        leaf.parsed,
        entry,
        leaves.length === 1 ? null : { nth: nth + 1, count: leaves.length, whole: head.amount as bigint },
        leaf.fallback,
      ),
    );
  });

  // Old balance plus what moved is the new balance, or the file says so.
  const separateApplication = at(header, 84, 88);
  let balanced: boolean | null = null;
  if (separateApplication !== '00000') {
    report(
      'separate_application',
      `the code "separate application" is ${separateApplication}: this file is an extract of the account's movements, its balances are zeroed by the standard, and it proves nothing about the account`,
    );
  } else if (checkable && opening && closing) {
    const computed = opening.scaled + movementTotal;
    balanced = computed === closing.scaled;
    if (!balanced) {
      report(
        'balance_mismatch',
        `old balance ${opening.balance.amount} plus movements ${formatAmount(movementTotal)} is ${formatAmount(computed)}, and the statement closes at ${closing.balance.amount}: a difference of ${formatAmount(closing.scaled - computed)}${account.currency ? ` ${account.currency}` : ''}`,
      );
    }
  }

  // The trailer: what the bank says it wrote.
  const trailer = raw.trailer as string;
  const announced = at(trailer, 17, 22);
  if (!/^[0-9]{6}$/.test(announced) || Number(announced) !== raw.counted) {
    report(
      'record_count_mismatch',
      `the trailer announces ${announced.trim() || 'nothing'} records 1, 2, 3 and 8, and the file holds ${raw.counted}: records were lost, or added, on the way`,
    );
  }
  for (const [code, from, to, computed, what] of [
    ['debit_total_mismatch', 23, 37, debitTotal, 'debit'],
    ['credit_total_mismatch', 38, 52, creditTotal, 'credit'],
  ] as const) {
    const said = parseAmount(at(trailer, from, to));
    if (said === null || (totalsReadable && said !== computed)) {
      report(
        code,
        said === null
          ? `the ${what} total of the trailer, "${at(trailer, from, to)}", is not fifteen digits`
          : `the trailer announces a ${what} movement of ${formatAmount(said)} and the movements with detail number 0000 add up to ${formatAmount(computed)}`,
      );
    }
  }

  // Free communications: one text per continuous sequence number.
  const freeCommunications: string[] = [];
  let lastSequence: string | null = null;
  for (const record of raw.free) {
    const sequence = at(record, 3, 6);
    const text = at(record, 33, 112).trimEnd();
    if (sequence === lastSequence && freeCommunications.length > 0) {
      freeCommunications[freeCommunications.length - 1] += `\n${text}`;
    } else freeCommunications.push(text);
    lastSequence = sequence;
  }

  const createdAt = dayOf(at(header, 6, 11), 'the creation date');
  const coded = at(oldBalance, 126, 128);
  const paper = at(raw.newBalance ?? oldBalance, raw.newBalance ? 2 : 3, raw.newBalance ? 4 : 5);
  const balances = [opening?.balance, closing?.balance].filter(
    (item): item is StatementBalance => item !== undefined && item !== null,
  );
  return {
    id: `${(createdAt ?? opening?.balance.date ?? '0000').slice(0, 4)}-${coded}`,
    electronicSequenceNumber: /^[0-9]{3}$/.test(coded) && coded !== '000' ? String(Number(coded)) : null,
    legalSequenceNumber: null,
    createdAt,
    period: null,
    page: null,
    account: {
      identifier: account.identifier,
      currency: account.currency,
      name: zone(oldBalance, 91, 125),
      ownerName: zone(oldBalance, 65, 90),
      servicerBic: zone(header, 61, 71),
    },
    openingBalance: opening?.balance ?? null,
    closingBalance: closing?.balance ?? null,
    balances,
    lines,
    balanced,
    paperSequenceNumber: /^0*$/.test(paper.trim()) ? null : paper,
    duplicate: at(header, 17) === 'D',
    fileReference: zone(header, 25, 34),
    addressee: zone(header, 35, 60),
    holderIdentification: zone(header, 72, 82),
    separateApplication,
    freeCommunications,
  };
}

/**
 * Read a CODA file — a string, or the bytes as they came — into its
 * statements, their lines, and what does not add up.
 *
 * Throws a `StatementFileError` for what is not a readable CODA at all: a
 * record of the wrong length, an unknown record, a record out of place, an
 * encoding that is not the one announced. Everything else comes back, with the
 * trouble named in `violations` and nothing silently repaired: a new balance
 * that does not follow from the old one is returned as the bank wrote it, and
 * reported.
 */
export function readCoda(input: string | Uint8Array, options: ReadOptions = {}): StatementFile {
  const text = decode(input, options.encoding ?? 'utf-8', options.maxBytes ?? DEFAULTS.maxBytes);
  const records = splitRecords(text, RECORD_LENGTH);
  const violations: Violation[] = [];
  const statements = gather(records).map((raw, index) =>
    readStatement(raw, index + 1, options.pivotYear ?? DEFAULTS.pivotYear, violations),
  );
  return { format: 'coda', version: '2', namespace: 'coda.2', statements, violations };
}
