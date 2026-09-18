import { describe, expect, it } from 'vitest';
import { StatementFileError, readCfonb120 } from '../src/index.js';
import { file, statementRecords, type StatementSpec } from './build.js';

const simple: StatementSpec = {
  opening: 100_000n,
  movements: [{ amount: 25_000n, label: 'UN', complements: [{ qualifier: 'NPY', text: 'CLIENT EXEMPLE' }] }],
};
const records = statementRecords(simple);

function refusal(input: string | Uint8Array, options = {}): { code: string; record: number | null; message: string } {
  try {
    readCfonb120(input, options);
  } catch (error) {
    if (error instanceof StatementFileError) return { code: error.code, record: error.record, message: error.message };
    throw error;
  }
  throw new Error('the file was read');
}

const replaced = (which: number, record: string): string =>
  records.map((original, index) => (index === which ? record : original)).join('\n');

describe('a record of the wrong length', () => {
  it('is refused by name and by number: every position after it would be wrong', () => {
    expect(refusal(replaced(1, records[1]!.slice(0, 119)))).toMatchObject({ code: 'invalid_record_length', record: 2 });
    expect(refusal(replaced(1, `${records[1]!} `))).toMatchObject({ code: 'invalid_record_length', record: 2 });
  });

  it('is refused when trailing blanks were trimmed on the way: nothing is padded back', () => {
    expect(refusal(records.map((record) => record.trimEnd()).join('\n'))).toMatchObject({
      code: 'invalid_record_length',
      record: 1,
    });
  });

  it('is refused in a file without line breaks that is not a whole number of records', () => {
    expect(refusal(records.join('').slice(0, -1))).toMatchObject({ code: 'invalid_record_length', record: null });
  });

  it('is refused when the file is a CODA: 128 is not 120', () => {
    expect(refusal(`${'0'.repeat(127)}2\n`).code).toBe('invalid_record_length');
  });
});

describe('a record the format does not have', () => {
  it('is refused by name: 02, 03, 06, 08, letters', () => {
    for (const code of ['02', '03', '06', '08', 'XX', '  ']) {
      expect(refusal(replaced(1, code + records[1]!.slice(2)))).toMatchObject({ code: 'unknown_record', record: 2 });
    }
  });
});

describe('a record out of place', () => {
  it('refuses a movement, a complement or a new balance before any old balance', () => {
    expect(refusal(records.slice(1).join('\n'))).toMatchObject({ code: 'unexpected_record', record: 1 });
    expect(refusal(records.slice(2).join('\n')).code).toBe('unexpected_record');
    expect(refusal(records.slice(3).join('\n')).code).toBe('unexpected_record');
  });

  it('refuses a complement that follows no movement', () => {
    expect(refusal([records[0], records[2], records[3]].join('\n'))).toMatchObject({ code: 'unexpected_record', record: 2 });
  });

  it('refuses a second old balance before the new balance of the first', () => {
    expect(refusal([...records.slice(0, -1), ...records].join('\n')).code).toBe('unexpected_record');
  });

  it('refuses a file that stops before its new balance', () => {
    expect(refusal(records.slice(0, -1).join('\n')).code).toBe('incomplete_statement');
  });
});

describe('a record of another account in the middle of this one', () => {
  it('is refused: another account number, another branch, another bank', () => {
    const other = statementRecords({ ...simple, accountNumber: '0000000202B' })[1]!;
    expect(refusal(replaced(1, other))).toMatchObject({ code: 'inconsistent_record', record: 2 });
    expect(refusal(replaced(1, statementRecords({ ...simple, branchCode: '00002' })[1]!)).code).toBe('inconsistent_record');
    expect(refusal(replaced(3, statementRecords({ ...simple, bankCode: '99998' })[3]!)).code).toBe('inconsistent_record');
  });

  it('is refused: another currency, or another number of decimals — nothing is converted, and no scale is guessed', () => {
    expect(refusal(replaced(1, statementRecords({ ...simple, currency: 'USD' })[1]!)).code).toBe('inconsistent_record');
    expect(refusal(replaced(1, statementRecords({ ...simple, decimals: 3 })[1]!)).code).toBe('inconsistent_record');
  });

  it('refuses an old balance that names no account, or whose decimals are not a digit', () => {
    expect(refusal(file({ opening: 0n, accountNumber: '' })).code).toBe('incomplete_statement');
    const broken = records.map((record) => `${record.slice(0, 19)}X${record.slice(20)}`);
    expect(refusal(broken.join('\n')).code).toBe('incomplete_statement');
  });
});

describe('an encoding that cannot be read', () => {
  it('refuses EBCDIC, which the brochure describes and which is not text here', () => {
    // "01" in EBCDIC, and blanks.
    const ebcdic = Uint8Array.from({ length: 120 }, (_, index) => (index === 0 ? 0xf0 : index === 1 ? 0xf1 : 0x40));
    expect(refusal(ebcdic).code).toBe('unsupported_encoding');
  });

  it('refuses bytes that are not UTF-8, and reads them as ISO-8859-1 when told', () => {
    const accented = file({ ...simple, movements: [{ amount: 25_000n, label: 'RÈGLEMENT' }] });
    const bytes = Uint8Array.from([...accented].map((character) => character.charCodeAt(0)));
    expect(refusal(bytes).code).toBe('unsupported_encoding');
    expect(readCfonb120(bytes, { encoding: 'iso-8859-1' }).statements[0]!.lines[0]!.additionalInformation).toBe('RÈGLEMENT');
  });

  it('refuses a replacement character and a control character, and forgives a byte order mark and an end-of-file mark', () => {
    expect(refusal(file(simple).replace('UN', `U${String.fromCharCode(0xfffd)}`)).code).toBe('unsupported_encoding');
    expect(refusal(file(simple).replace('UN', `U${String.fromCharCode(9)}`)).code).toBe('unsupported_encoding');
    const wrapped = String.fromCharCode(0xfeff) + file(simple) + String.fromCharCode(0x1a);
    expect(readCfonb120(wrapped)).toEqual(readCfonb120(file(simple)));
  });

  it('refuses an empty file, and an HTML error page', () => {
    expect(refusal('').code).toBe('empty_file');
    expect(refusal('<html><body>Session expiree</body></html>').code).toBe('invalid_record_length');
  });
});

describe('a file that asks for memory', () => {
  it('is refused on its size before a record is read', () => {
    expect(refusal(file(simple), { maxBytes: 100 }).code).toBe('too_large');
  });

  it('reads twenty thousand movements within a bound', () => {
    const many: StatementSpec = {
      opening: 0n,
      movements: Array.from({ length: 20_000 }, () => ({ amount: 100n, complements: [{ qualifier: 'LIB', text: 'X' }] })),
    };
    const started = Date.now();
    const read = readCfonb120(file(many));
    expect(read.statements[0]!.lines).toHaveLength(20_000);
    expect(read.statements[0]!.closingBalance?.amount).toBe('20000.00');
    expect(read.statements[0]!.balanced).toBe(true);
    expect(Date.now() - started).toBeLessThan(5_000);
  });
});
