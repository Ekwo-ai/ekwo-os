import { describe, expect, it } from 'vitest';
import { StatementFileError, readCoda } from '../src/index.js';
import { file, statementRecords, type StatementSpec } from './build.js';

const simple: StatementSpec = {
  opening: 1_000_000n,
  movements: [{ sequence: 1, reference: 'REF1', amount: 250_000n, free: 'UN', counterpartyName: 'CLIENT EXEMPLE' }],
};
const records = statementRecords(simple);

function refusal(input: string | Uint8Array, options = {}): { code: string; record: number | null; message: string } {
  try {
    readCoda(input, options);
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
    expect(refusal(replaced(2, records[2]!.slice(0, 127)))).toMatchObject({ code: 'invalid_record_length', record: 3 });
    expect(refusal(replaced(2, `${records[2]!} `))).toMatchObject({ code: 'invalid_record_length', record: 3 });
  });

  it('is refused in a file without line breaks that is not a whole number of records', () => {
    expect(refusal(records.join('').slice(0, -1))).toMatchObject({ code: 'invalid_record_length', record: null });
  });
});

describe('a record the standard does not have', () => {
  it('is refused by name: identification 5, 6, 7, a letter', () => {
    for (const identification of ['5', '6', '7', 'X']) {
      expect(refusal(replaced(2, identification + records[2]!.slice(1)))).toMatchObject({ code: 'unknown_record', record: 3 });
    }
  });

  it('is refused by name: article 4 of a movement record', () => {
    expect(refusal(replaced(2, `24${records[2]!.slice(2)}`)).message).toMatch(/article code "4"/);
  });
});

describe('a record out of place', () => {
  it('refuses a 2.3 whose 2.1 is another movement', () => {
    const moved = records.map((record) => (record.startsWith('23') ? `2300020000${record.slice(10)}` : record));
    expect(refusal(moved.join('\n'))).toMatchObject({ code: 'unexpected_record' });
  });

  it('refuses a movement before the old balance, and after the new one', () => {
    expect(refusal([records[0], records[2], records[1], ...records.slice(3)].join('\n')).code).toBe('unexpected_record');
    const last = records.length - 1;
    expect(refusal([...records.slice(0, last), records[2], records[last]].join('\n')).code).toBe('unexpected_record');
  });

  it('refuses a file that begins in the middle', () => {
    expect(refusal(records.slice(1).join('\n'))).toMatchObject({ code: 'unexpected_record', record: 1 });
  });

  it('refuses a file that stops before its trailer record', () => {
    expect(refusal(records.slice(0, -1).join('\n')).code).toBe('incomplete_statement');
  });

  it('refuses a second header before the trailer of the first', () => {
    expect(refusal([...records.slice(0, -1), ...records].join('\n')).code).toBe('unexpected_record');
  });
});

describe('another format under the same name, or under none', () => {
  it('refuses version 1 of the standard', () => {
    expect(refusal(file({ ...simple, version: '1' })).code).toBe('unsupported_version');
  });

  it('refuses a new balance that is of another account than the old one', () => {
    const other = records.map((record) => (record.startsWith('8') ? record.replace('000101', '000102') : record));
    expect(refusal(other.join('\n')).code).toBe('inconsistent_record');
  });

  it('refuses an account structure the standard does not have', () => {
    expect(refusal(replaced(1, `17${records[1]!.slice(2)}`)).code).toBe('incomplete_statement');
  });

  it('refuses an empty file, and an HTML error page', () => {
    expect(refusal('').code).toBe('empty_file');
    expect(refusal('\r\n\r\n').code).toBe('empty_file');
    expect(refusal('<html><body>Session expired</body></html>').code).toBe('invalid_record_length');
  });
});

describe('an encoding that cannot be read', () => {
  it('refuses bytes that are not UTF-8, and says how to read ISO-8859-1', () => {
    const bytes = new TextEncoder().encode(file(simple));
    bytes[200] = 0xe9;
    expect(refusal(bytes)).toMatchObject({ code: 'unsupported_encoding' });
    expect(refusal(bytes).message).toMatch(/iso-8859-1/);
    expect(() => readCoda(bytes, { encoding: 'iso-8859-1' })).not.toThrow();
  });

  it('refuses EBCDIC, which is not text in either encoding', () => {
    const ebcdic = Uint8Array.from({ length: 128 }, () => 0xf0);
    expect(refusal(ebcdic).code).toBe('unsupported_encoding');
    expect(refusal(ebcdic, { encoding: 'iso-8859-1' }).code).toBe('unknown_record');
  });

  it('refuses a replacement character: the file was already decoded wrongly by someone', () => {
    const broken = file({ ...simple, holder: `ATELIER EXEMPL${String.fromCharCode(0xfffd)}` });
    expect(refusal(broken).code).toBe('unsupported_encoding');
  });

  it('refuses a control character, and forgives a byte order mark and an end-of-file mark', () => {
    expect(refusal(file(simple).replace('UN', `U${String.fromCharCode(0)}`)).code).toBe('unsupported_encoding');
    const wrapped = String.fromCharCode(0xfeff) + file(simple) + String.fromCharCode(0x1a);
    expect(readCoda(wrapped)).toEqual(readCoda(file(simple)));
  });
});

describe('a file that asks for memory', () => {
  it('is refused on its size before a record is read', () => {
    expect(refusal(file(simple), { maxBytes: 100 }).code).toBe('too_large');
    expect(refusal(new Uint8Array(101), { maxBytes: 100 }).code).toBe('too_large');
  });

  it('reads ten thousand movements, whose sequence number wraps, within a bound', () => {
    const many: StatementSpec = {
      opening: 0n,
      movements: Array.from({ length: 10_000 }, (_, index) => ({ sequence: (index % 9999) + 1, amount: 1_000n })),
    };
    const started = Date.now();
    const read = readCoda(file(many));
    expect(read.statements[0]!.lines).toHaveLength(10_000);
    expect(read.statements[0]!.balanced).toBe(true);
    expect(read.violations).toEqual([]);
    expect(Date.now() - started).toBeLessThan(5_000);
  });
});
