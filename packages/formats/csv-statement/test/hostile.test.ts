import { describe, expect, it } from 'vitest';
import { readCsvStatement, StatementFileError, type CsvStatementProfile } from '../src/index.js';

const profile: CsvStatementProfile = {
  delimiter: ',',
  dateFormat: 'YYYY-MM-DD',
  decimalSeparator: '.',
  columns: { date: 'Date', amount: 'Amount' },
};

/** The code a read is refused with, or `read` when it is not refused. */
function refusal(run: () => unknown): string {
  try {
    run();
    return 'read';
  } catch (error) {
    if (error instanceof StatementFileError) return error.code;
    throw error;
  }
}

describe('a file that is not a statement this profile reads', () => {
  it('is refused by name when it is empty, or a header and nothing under it', () => {
    expect(refusal(() => readCsvStatement('', profile))).toBe('empty_file');
    expect(refusal(() => readCsvStatement('\n\n', profile))).toBe('empty_file');
    expect(refusal(() => readCsvStatement('Date,Amount\n', profile))).toBe('empty_file');
  });

  it('is refused when a quote is never closed', () => {
    expect(refusal(() => readCsvStatement('Date,Amount\n2026-01-01,"12.00\n', profile))).toBe('malformed_csv');
  });

  it('is refused when its header lacks a column the profile names, saying which it has', () => {
    try {
      readCsvStatement('Booked,Value\n2026-01-01,1.00\n', profile);
      expect.unreachable();
    } catch (error) {
      expect(error).toBeInstanceOf(StatementFileError);
      expect((error as StatementFileError).code).toBe('missing_column');
      expect((error as StatementFileError).message).toBe('no column "Date" in the header; it has "Booked", "Value"');
    }
    expect(refusal(() => readCsvStatement('Date,Amount,amount\n2026-01-01,1,2\n', profile))).toBe('missing_column');
  });

  it('is refused when it is a spreadsheet, a PDF or bytes of another encoding', () => {
    const zip = Uint8Array.from([0x50, 0x4b, 0x03, 0x04, 0x14, 0x00, 0x06, 0x00]);
    expect(refusal(() => readCsvStatement(zip, profile))).toBe('unsupported_encoding');
    expect(refusal(() => readCsvStatement(Uint8Array.from([0x44, 0x61, 0x74, 0x65, 0xe9, 0x0a]), profile))).toBe('unsupported_encoding');
    expect(refusal(() => readCsvStatement('Date,Amount\n2026-01-01,�1\n', profile))).toBe('unsupported_encoding');
  });

  it('is refused unread when it is over the limit', () => {
    expect(refusal(() => readCsvStatement('Date,Amount\n2026-01-01,1.00\n', profile, { maxBytes: 10 }))).toBe('too_large');
  });

  it('reads a camt.053 or a CODA as nothing it can take: refused, not half read', () => {
    expect(refusal(() => readCsvStatement('<?xml version="1.0"?><Document><BkToCstmrStmt/></Document>', profile))).toBe('missing_column');
  });
});

describe('a profile that describes no statement', () => {
  const refused = (changed: Partial<CsvStatementProfile> | Record<string, unknown>): string =>
    refusal(() => readCsvStatement('Date,Amount\n2026-01-01,1.00\n', { ...profile, ...changed } as CsvStatementProfile));

  it('is refused before the file is read', () => {
    expect(refused({ delimiter: '' })).toBe('invalid_profile');
    expect(refused({ delimiter: ';;' })).toBe('invalid_profile');
    expect(refused({ delimiter: '"' })).toBe('invalid_profile');
    expect(refused({ decimalSeparator: ' ' })).toBe('invalid_profile');
    expect(refused({ thousandsSeparator: '.', decimalSeparator: '.' })).toBe('invalid_profile');
    expect(refused({ dateFormat: 'DD/MM' })).toBe('invalid_profile');
    expect(refused({ dateFormat: 'DD/MM/YYYY/YYYY' })).toBe('invalid_profile');
    expect(refused({ dateFormat: 'D/M/Y' })).toBe('invalid_profile');
    expect(refused({ encoding: 'utf-16' })).toBe('invalid_profile');
    expect(refused({ sign: 'negative' })).toBe('invalid_profile');
    expect(refused({ skipRows: -1 })).toBe('invalid_profile');
    expect(refused({ columns: { amount: 'Amount' } })).toBe('invalid_profile');
    expect(refused({ columns: { date: 'Date' } })).toBe('invalid_profile');
    expect(refused({ columns: { date: 'Date', amount: 'Amount', debit: 'Out' } })).toBe('invalid_profile');
    expect(refused({ columns: { date: 0, amount: 2 } })).toBe('invalid_profile');
    expect(refused({ columns: { date: 'Date', amount: 'Amount', colour: 'Red' } })).toBe('invalid_profile');
    expect(refused({ header: false })).toBe('invalid_profile');
  });

  it('is refused when a declared balance is not a decimal string', () => {
    expect(refusal(() => readCsvStatement('Date,Amount\n2026-01-01,1.00\n', profile, { openingBalance: '1,000.00' }))).toBe('invalid_profile');
  });
});

describe('amounts that are not amounts', () => {
  const amount = (cell: string, marks: Partial<CsvStatementProfile> = {}): string | null => {
    const read = readCsvStatement(`Date;Amount\n2026-01-01;${cell}\n`, { ...profile, delimiter: ';', ...marks });
    return read.statements[0]!.lines[0]!.amount;
  };

  it('are reported, never read one way or another', () => {
    expect(amount('12.00 EUR')).toBeNull();
    expect(amount('1e3')).toBeNull();
    expect(amount('1.2.3')).toBeNull();
    expect(amount('1,234.00')).toBeNull();
    expect(amount('12,34', { thousandsSeparator: ',' })).toBeNull();
  });

  it('are read with every sign a bank writes', () => {
    expect(amount('-12.00')).toBe('-12.00');
    expect(amount('+12.00')).toBe('12.00');
    expect(amount('12.00-')).toBe('-12.00');
    expect(amount('(12.00)')).toBe('-12.00');
    expect(amount('.5')).toBe('0.50');
    expect(amount('0.123')).toBe('0.123');
    expect(amount("1'234.50", { thousandsSeparator: "'" })).toBe('1234.50');
  });
});
