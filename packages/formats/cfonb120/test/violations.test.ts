import { describe, expect, it } from 'vitest';
import { readCfonb120 } from '../src/index.js';
import { file, statementRecords, type StatementSpec } from './build.js';

const codes = (content: string): string[] => readCfonb120(content).violations.map((violation) => violation.code);

/** Overwrite positions `from`… of one record, counted from 1 as the brochure counts. */
function overwrite(records: string[], which: number, from: number, value: string): string {
  const out = [...records];
  const record = out[which] as string;
  out[which] = record.slice(0, from - 1) + value + record.slice(from - 1 + value.length);
  return out.join('\r\n');
}

const simple: StatementSpec = {
  opening: 100_000n,
  movements: [
    { amount: 25_000n, label: 'UN' },
    { amount: -10_000n, label: 'DEUX' },
  ],
};
const records = statementRecords(simple);

describe('a statement that does not add up', () => {
  it('is returned as the bank wrote it, with the difference named and nothing corrected', () => {
    const read = readCfonb120(file({ ...simple, closing: 114_999n }));
    const statement = read.statements[0]!;
    expect(statement.balanced).toBe(false);
    expect(statement.closingBalance?.amount).toBe('1149.99');
    expect(statement.lines.map((line) => line.amount)).toEqual(['250.00', '-100.00']);
    expect(read.violations).toEqual([
      {
        code: 'balance_mismatch',
        statement: 1,
        message:
          'old balance 1000.00 plus movements 150.00 is 1150.00, and the statement closes at 1149.99: a difference of -0.01 EUR',
      },
    ]);
  });

  it('says so when a movement was lost on the way', () => {
    expect(codes(records.filter((_, index) => index !== 2).join('\n'))).toEqual(['balance_mismatch']);
  });

  it('says on which statement of the file the trouble is', () => {
    const read = readCfonb120(file(simple, { ...simple, opening: 115_000n, openingDate: '310326', closingDate: '300426', closing: 1n, movements: [] }));
    expect(read.violations.map((violation) => [violation.code, violation.statement])).toEqual([['balance_mismatch', 2]]);
  });
});

describe('figures and dates that are not', () => {
  it('reports an amount whose last character carries no sign, returns null, and checks no balance', () => {
    const read = readCfonb120(overwrite(records, 1, 104, '0'));
    expect(read.statements[0]!.lines[0]!.amount).toBeNull();
    expect(read.statements[0]!.balanced).toBeNull();
    expect(read.violations.map((violation) => [violation.code, violation.line])).toEqual([['invalid_amount', 1]]);
  });

  it('reports a balance that is not an amount', () => {
    const read = readCfonb120(overwrite(records, 0, 91, '          1000'));
    expect(read.statements[0]!.openingBalance).toBeNull();
    expect(read.violations.map((violation) => violation.code)).toEqual(['invalid_amount']);
  });

  it('reports the thirtieth of February', () => {
    const read = readCfonb120(overwrite(records, 1, 35, '300226'));
    expect(read.statements[0]!.lines[0]!.bookingDate).toBeNull();
    expect(read.violations.map((violation) => violation.code)).toEqual(['invalid_date', 'booking_date_missing']);
  });

  it('reports a movement booked outside its statement: after the old balance, up to the new one', () => {
    expect(codes(file({ ...simple, movements: [{ amount: 1n, bookingDate: '280226' }] }))).toEqual([
      'booking_date_outside_statement',
    ]);
    expect(codes(file({ ...simple, movements: [{ amount: 1n, bookingDate: '010426' }] }))).toEqual([
      'booking_date_outside_statement',
    ]);
    expect(codes(file({ ...simple, movements: [{ amount: 1n, bookingDate: '310326' }] }))).toEqual([]);
  });

  it('reads a year on two digits around the pivot it is given', () => {
    const old = file({ opening: 0n, openingDate: '311298', closingDate: '310199' });
    expect(readCfonb120(old).statements[0]!.id).toBe('1998-12-31/1999-01-31');
    expect(readCfonb120(old, { pivotYear: 100 }).statements[0]!.id).toBe('2098-12-31/2099-01-31');
  });
});
