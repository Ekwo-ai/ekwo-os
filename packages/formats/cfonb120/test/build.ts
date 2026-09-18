/**
 * Writes CFONB 120 records position by position, from the tables of the
 * brochure (chapter 3) and of its 2010 complement. Everything the tests read
 * is written here: no file of a bank is in this package, because a real one is
 * somebody's account.
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

/** Fourteen positions, the sign written over the last digit. */
export function signed(amount: bigint): string {
  const unsigned = digits(amount < 0n ? -amount : amount, 14);
  const last = Number(unsigned.charAt(13));
  return unsigned.slice(0, 13) + (amount < 0n ? '}JKLMNOPQR' : '{ABCDEFGHI').charAt(last);
}

export interface ComplementSpec {
  qualifier: string;
  /** The seventy positions, or the first zone of two. */
  text: string;
  /** The second zone, from position 84. */
  second?: string;
}

export interface MovementSpec {
  /** Minor units, signed from the holder's side. */
  amount: bigint;
  /** JJMMAA. */
  bookingDate?: string;
  valueDate?: string;
  label?: string;
  internalCode?: string;
  interbankCode?: string;
  rejectCode?: string;
  entryNumber?: number;
  exempt?: string;
  unavailable?: string;
  reference?: string;
  complements?: ComplementSpec[];
}

export interface StatementSpec {
  bankCode?: string;
  branchCode?: string;
  accountNumber?: string;
  currency?: string;
  decimals?: number;
  opening: bigint;
  openingDate?: string;
  /** Left out, it is what the movements make it. */
  closing?: bigint;
  closingDate?: string;
  movements?: MovementSpec[];
}

export const BANK = '99999';
export const BRANCH = '00001';
export const ACCOUNT = '0000000101A';

function prefix(code: string, spec: StatementSpec, internal = ''): string {
  return (
    code +
    text(spec.bankCode ?? BANK, 5) +
    text(internal, 4) +
    text(spec.branchCode ?? BRANCH, 5) +
    text(spec.currency ?? 'EUR', 3) +
    String(spec.decimals ?? 2) +
    ' ' +
    text(spec.accountNumber ?? ACCOUNT, 11)
  );
}

export function statementRecords(spec: StatementSpec): string[] {
  const movements = spec.movements ?? [];
  const total = movements.reduce((sum, movement) => sum + movement.amount, 0n);
  const records = [
    prefix('01', spec) + '  ' + (spec.openingDate ?? '280226') + text('', 50) + signed(spec.opening) + text('', 16),
  ];
  for (const movement of movements) {
    const interbank = text(movement.interbankCode ?? '05', 2);
    const booked = movement.bookingDate ?? '050326';
    records.push(
      prefix('04', spec, movement.internalCode ?? '') +
        interbank +
        booked +
        text(movement.rejectCode ?? '', 2) +
        (movement.valueDate ?? booked) +
        text(movement.label ?? '', 31) +
        '  ' +
        digits(movement.entryNumber ?? 0, 7) +
        text(movement.exempt ?? '0', 1) +
        text(movement.unavailable ?? '0', 1) +
        signed(movement.amount) +
        text(movement.reference ?? '', 16),
    );
    for (const complement of movement.complements ?? []) {
      records.push(
        prefix('05', spec, movement.internalCode ?? '') +
          interbank +
          booked +
          text('', 5) +
          text(complement.qualifier, 3) +
          (complement.second === undefined
            ? text(complement.text, 70)
            : text(complement.text, 35) + text(complement.second, 35)) +
          '  ',
      );
    }
  }
  records.push(
    prefix('07', spec) +
      '  ' +
      (spec.closingDate ?? '310326') +
      text('', 50) +
      signed(spec.closing ?? spec.opening + total) +
      text('', 16),
  );
  for (const record of records) {
    if (record.length !== 120) throw new Error(`a record of ${record.length} characters: ${record}`);
  }
  return records;
}

export function file(...statements: StatementSpec[]): string {
  return statements.flatMap((statement) => statementRecords(statement)).join('\r\n') + '\r\n';
}
