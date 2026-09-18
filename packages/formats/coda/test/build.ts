/**
 * Writes CODA records position by position, from the lay-out of the standard
 * (annex I). Everything the tests read is written here: no file of a bank is
 * in this package, because a real one is somebody's account.
 *
 * It is a writer for tests and only that — it fills what the reader reads and
 * leaves the rest blank, which a bank would not.
 */

/** Left-justified, blank-filled, and an error rather than a silent cut. */
export function text(value: string, length: number): string {
  if (value.length > length) throw new Error(`"${value}" does not fit in ${length} positions`);
  return value.padEnd(length, ' ');
}

/** Right-justified, zero-filled. */
export function digits(value: number | bigint | string, length: number): string {
  const out = String(value).padStart(length, '0');
  if (out.length > length || !/^[0-9]*$/.test(out)) throw new Error(`"${value}" is not ${length} digits`);
  return out;
}

/** An IBAN with the check digits ISO 13616 gives it. */
export function iban(country: string, bban: string): string {
  const numeric = [...`${bban}${country}00`]
    .map((character) => (/[A-Z]/.test(character) ? String(character.charCodeAt(0) - 55) : character))
    .join('');
  return `${country}${String(98n - (BigInt(numeric) % 97n)).padStart(2, '0')}${bban}`;
}

/** Ten digits and the two the Belgian structured communication adds. */
export function belgianReference(ten: string): string {
  return ten + String(Number(BigInt(ten) % 97n) || 97).padStart(2, '0');
}

export interface InformationSpec {
  free?: string;
  structured?: { type: string; text: string };
}

export interface MovementSpec {
  sequence: number;
  detail?: number;
  reference?: string;
  /** Thousandths, signed from the holder's side. */
  amount: bigint;
  /** DDMMYY. */
  valueDate?: string;
  entryDate?: string;
  /** Eight digits: type, family, transaction, category. */
  code?: string;
  free?: string;
  structured?: { type: string; text: string };
  customerReference?: string;
  counterpartyBic?: string;
  rTransactionType?: string;
  reason?: string;
  categoryPurpose?: string;
  purpose?: string;
  /** The thirty-seven positions of the counterparty's account, or an account to write in the first thirty-four. */
  counterpartyAccount?: string;
  counterpartyCurrency?: string;
  counterpartyName?: string;
  globalisation?: string;
  information?: InformationSpec[];
}

export interface StatementSpec {
  created?: string;
  version?: string;
  bic?: string;
  addressee?: string;
  holderIdentification?: string;
  separateApplication?: string;
  duplicate?: boolean;
  fileReference?: string;
  structure?: '0' | '1' | '2' | '3';
  /** The thirty-seven positions, when the test writes them itself. */
  accountArea?: string;
  account?: string;
  currency?: string;
  paperSequence?: number;
  codedSequence?: number;
  opening: bigint;
  openingDate?: string;
  /** Left out, it is what the movements make it. */
  closing?: bigint;
  closingDate?: string;
  holder?: string;
  description?: string;
  movements?: MovementSpec[];
  free?: string[];
  /** No new balance record: the day without movement of the standard. */
  empty?: boolean;
  trailer?: { count?: number; debit?: bigint; credit?: bigint };
  last?: boolean;
}

export const ACCOUNT = iban('BE', '999000000101');
export const BIC = 'ZZZZBEB1';

function accountArea(spec: StatementSpec): string {
  if (spec.accountArea !== undefined) return text(spec.accountArea, 37);
  const account = spec.account ?? ACCOUNT;
  const currency = spec.currency ?? 'EUR';
  switch (spec.structure ?? '2') {
    case '0':
      return text(`${text(account, 12)} ${text(currency, 3)}`, 37);
    case '2':
      return text(account, 31) + text('', 3) + text(currency, 3);
    default:
      return text(account, 34) + text(currency, 3);
  }
}

function signed(amount: bigint): string {
  return (amount < 0n ? '1' : '0') + digits(amount < 0n ? -amount : amount, 15);
}

function movementRecords(spec: MovementSpec, paperSequence: number, hasInformation: boolean): string[] {
  const head = digits(spec.sequence, 4) + digits(spec.detail ?? 0, 4);
  const communication = spec.structured
    ? text(spec.structured.type + spec.structured.text, 149)
    : text(spec.free ?? '', 149);
  const needs23 =
    spec.counterpartyAccount !== undefined ||
    spec.counterpartyName !== undefined ||
    communication.slice(106).trim() !== '';
  const needs22 =
    needs23 ||
    communication.slice(53, 106).trim() !== '' ||
    [spec.customerReference, spec.counterpartyBic, spec.rTransactionType, spec.reason, spec.categoryPurpose, spec.purpose].some(
      (value) => value !== undefined,
    );
  const link = hasInformation ? '1' : '0';
  const out = [
    '21' +
      head +
      text(spec.reference ?? '', 21) +
      signed(spec.amount) +
      (spec.valueDate ?? '000000') +
      (spec.code ?? '00150000') +
      (spec.structured ? '1' : '0') +
      communication.slice(0, 53) +
      (spec.entryDate ?? '050326') +
      digits(paperSequence, 3) +
      (spec.globalisation ?? '0') +
      (needs22 ? '1' : '0') +
      ' ' +
      link,
  ];
  if (needs22) {
    out.push(
      '22' +
        head +
        communication.slice(53, 106) +
        text(spec.customerReference ?? '', 35) +
        text(spec.counterpartyBic ?? '', 11) +
        '   ' +
        text(spec.rTransactionType ?? '', 1) +
        text(spec.reason ?? '', 4) +
        text(spec.categoryPurpose ?? '', 4) +
        text(spec.purpose ?? '', 4) +
        (needs23 ? '1' : '0') +
        ' ' +
        link,
    );
  }
  if (needs23) {
    const account = spec.counterpartyAccount ?? '';
    out.push(
      '23' +
        head +
        (account.length === 37 ? account : text(account, 34) + text(spec.counterpartyCurrency ?? '', 3)) +
        text(spec.counterpartyName ?? '', 35) +
        communication.slice(106) +
        '0' +
        ' ' +
        link,
    );
  }
  return out;
}

function informationRecords(
  movement: MovementSpec,
  spec: InformationSpec,
  detail: number,
  last: boolean,
): string[] {
  const head = digits(movement.sequence, 4) + digits(detail, 4);
  const communication = spec.structured
    ? text(spec.structured.type + spec.structured.text, 268)
    : text(spec.free ?? '', 268);
  const needs33 = communication.slice(178).trim() !== '';
  const needs32 = needs33 || communication.slice(73, 178).trim() !== '';
  const link = last ? '0' : '1';
  const out = [
    '31' +
      head +
      text(movement.reference ?? '', 21) +
      (movement.code ?? '00150000') +
      (spec.structured ? '1' : '0') +
      communication.slice(0, 73) +
      text('', 12) +
      (needs32 ? '1' : '0') +
      ' ' +
      link,
  ];
  if (needs32) out.push('32' + head + communication.slice(73, 178) + text('', 10) + (needs33 ? '1' : '0') + ' ' + link);
  if (needs33) out.push('33' + head + communication.slice(178) + text('', 25) + '0' + ' ' + link);
  return out;
}

/** The records of one statement, header to trailer. */
export function statementRecords(spec: StatementSpec): string[] {
  const paper = spec.paperSequence ?? 42;
  const area = accountArea(spec);
  const movements = spec.movements ?? [];
  const records: string[] = [
    '0' +
      '0000' +
      (spec.created ?? '060326') +
      '999' +
      '05' +
      (spec.duplicate ? 'D' : ' ') +
      text('', 7) +
      text(spec.fileReference ?? '', 10) +
      text(spec.addressee ?? 'ATELIER EXEMPLE', 26) +
      text(spec.bic ?? BIC, 11) +
      text(spec.holderIdentification ?? '00999000123', 11) +
      ' ' +
      (spec.separateApplication ?? '00000') +
      text('', 16) +
      text('', 16) +
      text('', 7) +
      (spec.version ?? '2'),
    '1' +
      (spec.structure ?? '2') +
      digits(paper, 3) +
      area +
      signed(spec.opening) +
      (spec.openingDate ?? '040326') +
      text(spec.holder ?? 'ATELIER EXEMPLE', 26) +
      text(spec.description ?? 'COMPTE A VUE', 35) +
      digits(spec.codedSequence ?? 42, 3),
  ];
  let debit = 0n;
  let credit = 0n;
  let total = 0n;
  let nextDetail = new Map<number, number>();
  for (const movement of movements) {
    const detail = movement.detail ?? 0;
    if (detail === 0) {
      total += movement.amount;
      if (movement.amount < 0n) debit -= movement.amount;
      else credit += movement.amount;
    }
    const information = movement.information ?? [];
    records.push(...movementRecords(movement, paper, information.length > 0));
    let informationDetail = Math.max(nextDetail.get(movement.sequence) ?? 0, detail) + 1;
    information.forEach((item, index) => {
      records.push(...informationRecords(movement, item, informationDetail, index === information.length - 1));
      informationDetail += 1;
    });
    nextDetail = nextDetail.set(movement.sequence, informationDetail - 1);
  }
  const free = spec.free ?? [];
  if (!spec.empty) {
    records.push(
      '8' +
        digits(paper, 3) +
        area +
        signed(spec.closing ?? spec.opening + total) +
        (spec.closingDate ?? '050326') +
        text('', 64) +
        (free.length > 0 ? '1' : '0'),
    );
  }
  free.forEach((communication, index) => {
    records.push(
      '4' + ' ' + digits(index + 1, 4) + '0000' + text('', 22) + text(communication, 80) + text('', 15) +
        (index === free.length - 1 ? '0' : '1'),
    );
  });
  const counted = records.filter((record) => /^[1238]/.test(record)).length;
  records.push(
    '9' +
      text('', 15) +
      digits(spec.trailer?.count ?? counted, 6) +
      digits(spec.trailer?.debit ?? debit, 15) +
      digits(spec.trailer?.credit ?? credit, 15) +
      text('', 75) +
      (spec.last === false ? '1' : '2'),
  );
  for (const record of records) {
    if (record.length !== 128) throw new Error(`a record of ${record.length} characters: ${record}`);
  }
  return records;
}

export function file(...statements: StatementSpec[]): string {
  return (
    statements
      .flatMap((statement, index) => statementRecords({ last: index === statements.length - 1, ...statement }))
      .join('\r\n') + '\r\n'
  );
}
