import { describe, expect, it } from 'vitest';
import { readCoda } from '../src/index.js';
import { file, statementRecords, type StatementSpec } from './build.js';
import { golden } from './scenario.js';

const codes = (content: string): string[] => readCoda(content).violations.map((violation) => violation.code);

/** Overwrite positions `from`… of one record, counted from 1 as the standard counts. */
function overwrite(records: string[], which: number, from: number, value: string): string {
  const out = [...records];
  const record = out[which] as string;
  out[which] = record.slice(0, from - 1) + value + record.slice(from - 1 + value.length);
  return out.join('\r\n');
}

const simple: StatementSpec = {
  opening: 1_000_000n,
  movements: [
    { sequence: 1, reference: 'REF1', amount: 250_000n, free: 'UN' },
    { sequence: 2, reference: 'REF2', amount: -100_000n, free: 'DEUX' },
  ],
};

describe('a statement that does not add up', () => {
  it('is returned as the bank wrote it, with the difference named and nothing corrected', () => {
    const read = readCoda(file({ ...simple, closing: 1_149_990n }));
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

  it('says so when a movement was lost on the way: the balance, the count and the total all disagree', () => {
    const records = statementRecords(simple).filter((record) => !record.startsWith('2100020000'));
    expect(codes(records.join('\n'))).toEqual(['balance_mismatch', 'record_count_mismatch', 'debit_total_mismatch']);
  });
});

describe('the trailer record', () => {
  it('is held against what the file holds: records 1, 2, 3 and 8', () => {
    expect(codes(file({ ...simple, trailer: { count: 9 } }))).toEqual(['record_count_mismatch']);
    expect(readCoda(file({ ...simple, trailer: { count: 9 } })).violations[0]!.message).toMatch(
      /announces 000009 records 1, 2, 3 and 8, and the file holds 4/,
    );
  });

  it('is held against the movements with detail number 0000, debit and credit apart', () => {
    expect(codes(file({ ...simple, trailer: { debit: 100_001n } }))).toEqual(['debit_total_mismatch']);
    expect(codes(file({ ...simple, trailer: { credit: 0n } }))).toEqual(['credit_total_mismatch']);
  });

  it('counts a total once: its details are not in the totals, and the golden statement agrees with its own', () => {
    expect(codes(file(golden))).toEqual([]);
  });
});

describe('a total whose details do not add up to it', () => {
  const broken: StatementSpec = {
    opening: 0n,
    movements: [
      { sequence: 1, reference: 'LOT', amount: -920_000n, code: '10101000' },
      { sequence: 1, detail: 1, amount: -500_000n, code: '50101000', counterpartyName: 'PERSONNE EXEMPLE A' },
      { sequence: 1, detail: 2, amount: -419_990n, code: '50101000', counterpartyName: 'PERSONNE EXEMPLE B' },
    ],
  };

  it('stays one line, and the balance still holds', () => {
    const read = readCoda(file(broken));
    expect(read.statements[0]!.lines.map((line) => [line.amount, line.detail])).toEqual([['-920.00', null]]);
    expect(read.statements[0]!.balanced).toBe(true);
    expect(read.violations).toEqual([
      {
        code: 'batch_not_split',
        statement: 1,
        line: 1,
        message: 'the 2 details of movement 0001 add up to -919.99 and the movement is -920.00; it is kept as one line',
      },
    ]);
  });

  it('keeps a detail whole when its own details do not add up to it', () => {
    const read = readCoda(
      file({
        opening: 0n,
        movements: [
          { sequence: 1, amount: 260_000n, code: '20150000' },
          { sequence: 1, detail: 1, amount: 100_000n, code: '60150000' },
          { sequence: 1, detail: 2, amount: 160_000n, code: '70150000' },
          { sequence: 1, detail: 3, amount: 120_000n, code: '90150000' },
          { sequence: 1, detail: 4, amount: 30_000n, code: '90150000' },
        ],
      }),
    );
    expect(read.statements[0]!.lines.map((line) => line.amount)).toEqual(['100.00', '160.00']);
    expect(read.violations.map((violation) => [violation.code, violation.line])).toEqual([['batch_not_split', 2]]);
  });

  it('takes a single detail for the movement itself, with what the detail says', () => {
    const read = readCoda(
      file({
        opening: 0n,
        movements: [
          { sequence: 1, reference: 'TOTAL', amount: 100_000n, code: '20150000' },
          { sequence: 1, detail: 1, amount: 100_000n, code: '60150000', counterpartyName: 'CLIENT EXEMPLE' },
        ],
      }),
    );
    expect(read.statements[0]!.lines).toHaveLength(1);
    expect(read.statements[0]!.lines[0]).toMatchObject({
      amount: '100.00',
      detail: null,
      detailCount: null,
      bankReference: 'TOTAL',
      counterparty: { name: 'CLIENT EXEMPLE' },
    });
    expect(read.violations).toEqual([]);
  });
});

describe('a structured communication that fails its own check', () => {
  it('is returned as written and signalled, never corrected', () => {
    const read = readCoda(
      file({ opening: 0n, movements: [{ sequence: 1, amount: 1_000n, structured: { type: '101', text: '202600010705' } }] }),
    );
    expect(read.statements[0]!.lines[0]!.remittance.structured[0]!.reference).toBe('202600010705');
    expect(read.violations).toMatchObject([{ code: 'invalid_structured_reference', statement: 1, line: 1 }]);
  });

  it('holds an ISO 11649 reference to its check digits too', () => {
    expect(
      codes(file({ opening: 0n, movements: [{ sequence: 1, amount: 1_000n, structured: { type: '100', text: 'RF19539007547034' } }] })),
    ).toEqual(['invalid_structured_reference']);
  });

  it('knows that a remainder of zero is written 97', () => {
    // 0000000097 is a multiple of 97.
    expect(
      codes(file({ opening: 0n, movements: [{ sequence: 1, amount: 1_000n, structured: { type: '101', text: '000000009797' } }] })),
    ).toEqual([]);
    expect(
      codes(file({ opening: 0n, movements: [{ sequence: 1, amount: 1_000n, structured: { type: '101', text: '000000009700' } }] })),
    ).toEqual(['invalid_structured_reference']);
  });
});

describe('figures and dates that are not', () => {
  const records = statementRecords(simple);

  it('reports an amount that is not fifteen digits, returns null, and checks no balance', () => {
    const read = readCoda(overwrite(records, 2, 33, '00000000002500A0'.slice(0, 15)));
    expect(read.statements[0]!.lines[0]!.amount).toBeNull();
    expect(read.statements[0]!.balanced).toBeNull();
    expect(read.violations.map((violation) => violation.code)).toEqual(['invalid_amount']);
  });

  it('reports a sign that is neither credit nor debit', () => {
    expect(codes(overwrite(records, 2, 32, '7'))).toEqual(['invalid_direction']);
  });

  it('reports the thirtieth of February', () => {
    const read = readCoda(overwrite(records, 2, 116, '300226'));
    expect(read.statements[0]!.lines[0]!.bookingDate).toBeNull();
    expect(read.violations.map((violation) => violation.code)).toEqual(['invalid_date', 'booking_date_missing']);
  });

  it('reports an account written as an IBAN that fails its check digits, as written', () => {
    const read = readCoda(file({ ...simple, account: 'BE00999000000101' }));
    expect(read.statements[0]!.account.identifier).toEqual({ kind: 'iban', value: 'BE00999000000101' });
    expect(read.violations.map((violation) => violation.code)).toEqual(['invalid_iban']);
  });

  it('reports an account zone without a currency, and invents none', () => {
    const read = readCoda(file({ ...simple, currency: '   ' }));
    expect(read.statements[0]!.openingBalance?.currency).toBeNull();
    expect(read.violations.map((violation) => violation.code)).toEqual(['currency_missing']);
  });

  it('reads a year on two digits around the pivot it is given', () => {
    expect(readCoda(file({ ...simple, openingDate: '311299' })).statements[0]!.openingBalance?.date).toBe('1999-12-31');
    expect(readCoda(file({ ...simple, openingDate: '311279' })).statements[0]!.openingBalance?.date).toBe('2079-12-31');
    expect(
      readCoda(file({ ...simple, openingDate: '311299' }), { pivotYear: 100 }).statements[0]!.openingBalance?.date,
    ).toBe('2099-12-31');
  });
});

describe('what is not a whole statement', () => {
  it('reads a day without movement — header, old balance, trailer — and invents no new balance', () => {
    const read = readCoda(file({ opening: 1_000_000n, empty: true }));
    expect(read.statements[0]).toMatchObject({ closingBalance: null, balanced: null, lines: [] });
    expect(read.violations.map((violation) => violation.code)).toEqual(['closing_balance_missing']);
  });

  it('says that a separate application is an extract, and checks nothing on its zeroed balances', () => {
    const read = readCoda(
      file({
        opening: 0n,
        closing: 0n,
        separateApplication: '01500',
        movements: [
          { sequence: 1, detail: 1, amount: 100_000n, code: '60150000' },
          { sequence: 1, detail: 2, amount: 160_000n, code: '60150000' },
        ],
      }),
    );
    expect(read.statements[0]!.balanced).toBeNull();
    expect(read.statements[0]!.lines.map((line) => line.amount)).toEqual(['100.00', '160.00']);
    expect(read.violations.map((violation) => violation.code)).toEqual(['separate_application']);
  });

  it('says on which statement of the file the trouble is', () => {
    const read = readCoda(
      file(simple, { ...simple, codedSequence: 43, opening: 1_150_000n, closing: 1n }),
    );
    expect(read.violations.map((violation) => [violation.code, violation.statement])).toEqual([['balance_mismatch', 2]]);
  });
});
