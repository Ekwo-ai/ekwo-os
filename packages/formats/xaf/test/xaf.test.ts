import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { BooksFileError, readXaf } from '../src/index.js';

const fixture = (name: string): string => readFileSync(new URL(`./fixtures/${name}`, import.meta.url), 'utf8');
const bytes = (text: string): Uint8Array => new TextEncoder().encode(text);

const V4 = fixture('books.v4.xaf');
const V32 = fixture('books.v32.xaf');

describe.each([
  ['4.0', V4],
  ['3.2', V32],
])('an audit file of version %s', (version, xml) => {
  const books = readXaf(xml);

  it('is recognised by its namespace, and says the currency of its books', () => {
    expect(books.version).toBe(version);
    expect(books.format).toBe('xaf');
    expect(books.currency).toBe('EUR');
    expect(books.violations).toEqual([]);
  });

  it('reads every transaction of every journal, with its journal, number, date and reference', () => {
    expect(books.entries.map((e) => [e.journal, e.journalName, e.number, e.date, e.reference, e.lines.length])).toEqual([
      ['VK', 'Sales', '2025001', '2025-01-15', 'INV-0001', 3],
      ['VK', 'Sales', '2025002', '2025-01-20', 'CRN-0001', 3],
      ['IK', 'Purchases', '2025101', '2025-01-22', 'A-17', 2],
      ['BNK', 'Bank', '2025201', '2025-01-28', 'INV-0001', 2],
    ]);
  });

  it('puts every amount on its side, a credit note included', () => {
    expect(books.entries[1]!.lines.map((l) => [l.account, l.debit, l.credit, l.contact])).toEqual([
      ['1300', '0.00', '121.00', 'C01'],
      ['8000', '100.00', '0.00', 'C01'],
      ['1500', '21.00', '0.00', null],
    ]);
  });

  it('keeps an amount in another currency, unsigned', () => {
    expect(books.entries[2]!.lines.map((l) => [l.currency, l.amountCurrency])).toEqual([
      ['USD', '100.00'],
      ['USD', '100.00'],
    ]);
  });

  it('takes the accounts with their type as written, and the parties by their code', () => {
    expect(books.accounts.map((a) => [a.code, a.name, a.type])).toContainEqual(['1300', 'Receivables', 'B']);
    expect(books.accounts.map((a) => a.code)).toHaveLength(7);
    expect(books.contacts.map((c) => [c.code, c.name, c.vatNumber, c.email])).toEqual([
      ['C01', 'Atelier Sirocco', 'XX0000000001', 'accounts@sirocco.example'],
      ['S02', 'Kestrel Joinery', null, null],
    ]);
  });

  it('returns the opening balance, and the day it opens on', () => {
    expect(books.opening.map((l) => [l.account, l.debit, l.credit])).toEqual([
      ['1100', '5000.00', '0.00'],
      ['0500', '0.00', '5000.00'],
    ]);
    expect(books.openingDate).toBe('2025-01-01');
  });
});

describe('what only version 3.2 carries', () => {
  it('keeps the matching key of a line', () => {
    const books = readXaf(V32);
    expect(books.entries[0]!.lines[0]!.matching).toBe('M1');
    expect(books.entries[3]!.lines[1]!.matching).toBe('M1');
  });

  it('opens on opBalDate where the file gives one', () => {
    expect(readXaf(V32.replace('<opBalDate>2025-01-01</opBalDate>', '<opBalDate>2025-02-01</opBalDate>')).openingDate).toBe('2025-02-01');
  });
});

describe('the encoding', () => {
  it('reads bytes as UTF-8, with or without a byte order mark', () => {
    expect(readXaf(bytes(V4)).entries).toHaveLength(4);
    expect(readXaf(new Uint8Array([0xef, 0xbb, 0xbf, ...bytes(V4)])).entries).toHaveLength(4);
  });

  it('reads Latin-1 when the declaration says so, and refuses bytes that are not what it says', () => {
    const latin = V4.replace('encoding="UTF-8"', 'encoding="ISO-8859-1"').replace('Kestrel Joinery', 'Kestrel Menuiserie é');
    const encoded = Uint8Array.from([...latin].map((c) => c.charCodeAt(0)));
    expect(readXaf(encoded).contacts[1]!.name).toBe('Kestrel Menuiserie é');
    const utf8Bytes = bytes(V4.replace('Kestrel Joinery', 'Kestrel é'));
    expect(() => readXaf(Uint8Array.from([...V4.replace('Kestrel Joinery', 'Kestrel é')].map((c) => c.charCodeAt(0))))).toThrow(/not UTF-8/);
    expect(() => readXaf(utf8Bytes, { encoding: 'iso-8859-1' })).toThrow(/never as somebody else says/);
  });
});

describe('what does not add up', () => {
  it('says a transaction does not balance, and returns it as written', () => {
    const books = readXaf(V4.replace('<amnt>210.00</amnt>', '<amnt>209.00</amnt>'));
    expect(books.violations.map((v) => v.rule)).toEqual(['balance', 'total_credit']);
    expect(books.entries[0]!.lines[2]!.credit).toBe('209.00');
  });

  it('holds the stated line count and the opening totals against the lines', () => {
    const books = readXaf(V4.replace('<linesCount>10</linesCount>', '<linesCount>11</linesCount>').replace('<totalCredit>5000.00</totalCredit>', '<totalCredit>5000.01</totalCredit>'));
    expect(books.violations.map((v) => v.rule).sort()).toEqual(['lines_count', 'total_credit']);
  });

  it('reads a negative amount as the other side', () => {
    const books = readXaf(V4.replace('<amnt>21.00</amnt>\n\t\t\t\t\t\t<amntTp>D</amntTp>', '<amnt>-21.00</amnt>\n\t\t\t\t\t\t<amntTp>C</amntTp>'));
    expect(books.entries[1]!.lines[2]!.debit).toBe('21.00');
    expect(books.violations).toEqual([]);
  });
});

describe('what is not an audit file', () => {
  it('refuses another root, another namespace, and a version it was not written against, by name', () => {
    expect(() => readXaf('<Document xmlns="urn:example"/>')).toThrow(expect.objectContaining({ code: 'not_an_auditfile' }));
    expect(() => readXaf('<auditfile xmlns="urn:example"/>')).toThrow(expect.objectContaining({ code: 'not_an_auditfile' }));
    expect(() => readXaf('<auditfile xmlns="http://www.auditfiles.nl/XAF/3.1"/>')).toThrow(expect.objectContaining({ code: 'unsupported_version' }));
  });

  it('refuses a DOCTYPE and an undeclared entity unread', () => {
    expect(() => readXaf('<!DOCTYPE a [<!ENTITY x "y">]><auditfile/>')).toThrow(expect.objectContaining({ code: 'doctype_forbidden' }));
    expect(() => readXaf(V4.replace('Design work', 'Design &work;'))).toThrow(expect.objectContaining({ code: 'undefined_entity' }));
  });

  it('refuses a side that is neither D nor C, an amount that is not a decimal, and a date that is not a day', () => {
    expect(() => readXaf(V4.replace('<amntTp>C</amntTp>', '<amntTp>K</amntTp>'))).toThrow(/D or C/);
    expect(() => readXaf(V4.replace('<amnt>1000.00</amnt>', '<amnt>1,000.00</amnt>'))).toThrow(BooksFileError);
    expect(() => readXaf(V4.replace('<trDt>2025-01-15</trDt>', '<trDt>2025-02-30</trDt>'))).toThrow(/calendar/);
  });

  it('refuses a file larger than the limit before reading it', () => {
    expect(() => readXaf(V4, { maxBytes: 100 })).toThrow(expect.objectContaining({ code: 'too_large' }));
  });
});
