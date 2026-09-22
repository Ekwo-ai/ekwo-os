import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { BooksFileError, generateFec, readFec, type FecLine } from '../src/index.js';

const sample = readFileSync(new URL('./fixtures/sample.fec.txt', import.meta.url), 'utf8');

describe('readFec on a whole year', () => {
  const books = readFec(sample);

  it('gathers the lines that share a journal and a number into one entry, in the order of the file', () => {
    expect(books.entries.map((e) => [e.journal, e.number, e.date, e.lines.length])).toEqual([
      ['AN', '1', '2025-01-01', 2],
      ['VE', '1', '2025-01-15', 3],
      ['AC', '1', '2025-01-20', 3],
      ['AC', '2', '2025-01-25', 2],
      ['BQ', '1', '2025-01-30', 2],
    ]);
    expect(books.violations).toEqual([]);
  });

  it('keeps the piece reference, the label, and the side and amount of every line as decimal strings', () => {
    const sale = books.entries[1]!;
    expect(sale.reference).toBe('F-001');
    expect(sale.description).toBe('Facture F-001');
    expect(sale.lines.map((l) => [l.account, l.debit, l.credit])).toEqual([
      ['411000', '1200.00', '0.00'],
      ['706000', '0.00', '1000.00'],
      ['445710', '0.00', '200.00'],
    ]);
  });

  it('names the sub-ledger party of a line, and lists each party once', () => {
    expect(books.entries[1]!.lines[0]!.contact).toBe('C0001');
    expect(books.contacts.map((c) => [c.code, c.name])).toEqual([
      ['C0001', 'Atelier Sirocco'],
      ['F0001', 'Verger du Moulin'],
      ['F0002', 'Kestrel Joinery'],
    ]);
  });

  it('keeps a foreign currency and its amount, and the reconciliation mark', () => {
    const foreign = books.entries[3]!.lines[0]!;
    expect([foreign.currency, foreign.amountCurrency]).toEqual(['USD', '100.00']);
    expect(books.entries[4]!.lines[1]!.matching).toBe('A');
  });

  it('lists the chart the file uses, with its labels, and claims no currency', () => {
    expect(books.accounts.map((a) => a.code)).toEqual(['512000', '101000', '411000', '706000', '445710', '606100', '445660', '401000']);
    expect(books.accounts[0]!.name).toBe('Banque');
    expect(books.currency).toBeNull();
    expect(books.opening).toEqual([]);
  });
});

describe('what this package writes, it reads back', () => {
  it('returns the entries generateFec was given, line for line', () => {
    const lines: FecLine[] = [
      { journalCode: 'OD', journalLib: 'Opérations diverses', ecritureNum: 'OD1', ecritureDate: '2026-03-31', compteNum: '6061', compteLib: 'Eau', pieceRef: 'P1', pieceDate: '2026-03-31', ecritureLib: 'Relevé', debit: '12.34', credit: '0', validDate: '2026-03-31' },
      { journalCode: 'OD', journalLib: 'Opérations diverses', ecritureNum: 'OD1', ecritureDate: '2026-03-31', compteNum: '4011', compteLib: 'Fournisseur', compAuxNum: 'F9', compAuxLib: 'Kestrel Joinery', pieceRef: 'P1', pieceDate: '2026-03-31', ecritureLib: 'Relevé', debit: '0', credit: '12.34', validDate: '2026-03-31' },
    ];
    for (const options of [{}, { fieldSeparator: '\t' as const, decimalSeparator: '.' as const, newline: '\n' as const }]) {
      const read = readFec(generateFec(lines, options));
      expect(read.violations).toEqual([]);
      expect(read.entries).toHaveLength(1);
      expect(read.entries[0]!.lines.map((l) => [l.account, l.contact, l.debit, l.credit])).toEqual([
        ['6061', null, '12.34', '0.00'],
        ['4011', 'F9', '0.00', '12.34'],
      ]);
    }
  });
});

describe('the variants of the text', () => {
  it('reads Montant and Sens instead of Debit and Credit', () => {
    const file = [
      'JournalCode|JournalLib|EcritureNum|EcritureDate|CompteNum|CompteLib|CompAuxNum|CompAuxLib|PieceRef|PieceDate|EcritureLib|Montant|Sens|EcritureLet|DateLet|ValidDate|Montantdevise|Idevise',
      'OD|Divers|7|20260102|471000|Attente|||X|20260102|Transfert|10,00|D|||20260102||',
      'OD|Divers|7|20260102|512000|Banque|||X|20260102|Transfert|10,00|C|||20260102||',
    ].join('\r\n');
    const read = readFec(file);
    expect(read.entries[0]!.lines.map((l) => [l.debit, l.credit])).toEqual([
      ['10.00', '0.00'],
      ['0.00', '10.00'],
    ]);
  });

  it('reads a file written in ISO 8859-15 when told so, and refuses it read as UTF-8', () => {
    const bytes = Uint8Array.from(Buffer.from(sample, 'latin1'));
    expect(() => readFec(bytes)).toThrow(/not UTF-8/);
    expect(readFec(bytes, { encoding: 'iso-8859-15' }).entries[0]!.journalName).toBe('À-nouveaux');
  });
});

describe('what does not add up, and what is not a FEC', () => {
  it('says an entry does not balance, and returns it as written', () => {
    const file = sample.replace('0,00|1000,00|||20250115', '0,00|999,00|||20250115');
    const read = readFec(file);
    expect(read.violations.map((v) => v.rule)).toEqual(['balance']);
    expect(read.violations[0]!.message).toContain('VE 1');
    expect(read.entries[1]!.lines[1]!.credit).toBe('999.00');
  });

  it('refuses a header without its separator or a column it needs, by name', () => {
    expect(() => readFec('JournalCode,EcritureNum\n')).toThrow(/tab nor a vertical bar/);
    expect(() => readFec('JournalCode|EcritureNum|EcritureDate|Debit|Credit\nA|1|20260101|1|0\n')).toThrow(/CompteNum/);
  });

  it('refuses a date that is not AAAAMMJJ or not a day of the calendar', () => {
    expect(() => readFec(sample.replace('|20250115|411000', '|2025-01-15|411000'))).toThrow(BooksFileError);
    expect(() => readFec(sample.replace('|20250115|411000', '|20250230|411000'))).toThrow(/calendar/);
  });
});
