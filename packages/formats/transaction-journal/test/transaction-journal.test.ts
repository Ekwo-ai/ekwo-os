import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { BooksFileError, amount, readDate, readTransactionJournal } from '../src/index.js';

const fixture = (name: string): string => readFileSync(new URL(`./fixtures/${name}`, import.meta.url), 'utf8');
const JOURNAL = fixture('journal.csv');

describe('a transaction journal saved as CSV, each transaction closed by its total', () => {
  const books = readTransactionJournal([JOURNAL], { dateOrder: 'mdy' });

  it('finds the header under the title rows, and puts the rows that follow a dated one into its transaction', () => {
    expect(books.entries.map((e) => [e.journal, e.number, e.date, e.lines.length])).toEqual([
      ['Journal Entry', '1', '2025-01-01', 2],
      ['Invoice', '1001', '2025-01-15', 3],
      ['Credit Memo', '1002', '2025-01-20', 3],
      ['Bill', 'A-17', '2025-01-22', 2],
      ['Payment', null, '2025-01-28', 2],
    ]);
    expect(books.violations).toEqual([]);
  });

  it('reads amounts grouped by thousands, and a credit note on its own sides', () => {
    expect(books.entries[1]!.lines.map((l) => [l.account, l.debit, l.credit])).toEqual([
      ['1200', '1150.00', '0.00'],
      ['4000', '0.00', '1000.00'],
      ['2200', '0.00', '150.00'],
    ]);
    expect(books.entries[2]!.lines.map((l) => [l.account, l.debit, l.credit])).toEqual([
      ['1200', '0.00', '115.00'],
      ['4000', '100.00', '0.00'],
      ['2200', '15.00', '0.00'],
    ]);
  });

  it('takes the account number as the code, the name beside it, the party and the memo of each line', () => {
    expect(books.accounts.map((a) => [a.code, a.name])).toContainEqual(['1200', 'Accounts Receivable (A/R)']);
    expect(books.contacts.map((c) => c.name)).toEqual(['Atelier Sirocco', 'Kestrel Joinery']);
    expect(books.entries[3]!.lines[0]!).toMatchObject({ contact: 'Kestrel Joinery', label: 'Paper' });
    expect(books.entries[3]!.reference).toBe('A-17');
  });

  it('claims no currency: the report prints the company\'s and does not name it', () => {
    expect(books.currency).toBeNull();
  });
});

describe('the list of accounts beside the journal', () => {
  it('gives each account its type, whatever the order of the files', () => {
    const books = readTransactionJournal([fixture('account-list.csv'), JOURNAL], { dateOrder: 'mdy' });
    expect(books.accounts.find((a) => a.code === '1200')?.type).toBe('Accounts receivable (A/R)');
    expect(books.accounts.find((a) => a.code === '4000')?.type).toBe('Income');
  });
});

describe('a layout that prints the date, the type and the number on every line', () => {
  const books = readTransactionJournal([fixture('journal-repeated.csv')], { dateOrder: 'dmy' });

  it('keeps one transaction while they repeat, reads a semicolon file with a decimal comma, and a byte order mark', () => {
    expect(books.entries.map((e) => [e.journal, e.date, e.lines.length])).toEqual([
      ['Invoice', '2025-01-15', 3],
      ['Payment', '2025-01-28', 2],
    ]);
    expect(books.entries[0]!.lines[0]!.debit).toBe('1150.00');
    expect(books.violations).toEqual([]);
  });

  it('uses the name of an account as its code when the report gives no number', () => {
    expect(books.entries[1]!.lines.map((l) => l.account)).toEqual(['Checking', 'Accounts Receivable (A/R)']);
  });
});

describe('dates and amounts', () => {
  it('refuses a date written in digits when nobody says in which order', () => {
    expect(() => readTransactionJournal([JOURNAL])).toThrow(/in which order/);
  });

  it('reads the order it is told, and refuses a day that is not in the calendar', () => {
    expect(readDate('01/15/2025', 'mdy', 1)).toBe('2025-01-15');
    expect(readDate('15/01/2025', 'dmy', 1)).toBe('2025-01-15');
    expect(readDate('Jan 15, 2025', undefined, 1)).toBe('2025-01-15');
    expect(readDate('TOTAL', 'mdy', 1)).toBeNull();
    expect(() => readDate('02/30/2025', 'mdy', 1)).toThrow(/calendar/);
  });

  it('reads the ways a spreadsheet displays an amount, and refuses a currency symbol and the ambiguous', () => {
    expect(amount('1,234.50', ',', 1)).toBe(1_234_500_000n);
    expect(amount('(12.00)', ',', 1)).toBe(-12_000_000n);
    expect(amount('1 234,50', ';', 1)).toBe(1_234_500_000n);
    expect(() => amount('$1,234.50', ',', 1)).toThrow(BooksFileError);
    expect(() => amount('1,23', ',', 1)).toThrow(BooksFileError);
  });

  it('reads a negative amount as the other side', () => {
    const books = readTransactionJournal([JOURNAL.replace(',,,,Atelier Sirocco,Sales tax,2200,Sales Tax Payable,,150.00', ',,,,Atelier Sirocco,Sales tax,2200,Sales Tax Payable,(150.00),')], { dateOrder: 'mdy' });
    expect(books.entries[1]!.lines[2]!).toMatchObject({ debit: '0.00', credit: '150.00' });
    expect(books.violations).toEqual([]);
  });
});

describe('what does not add up, and what is not a journal', () => {
  it('says a transaction does not balance, and returns it as written', () => {
    const books = readTransactionJournal([JOURNAL.replace('Sales Tax Payable,,150.00', 'Sales Tax Payable,,149.00')], { dateOrder: 'mdy' });
    expect(books.violations.map((v) => v.rule)).toEqual(['balance']);
    expect(books.violations[0]!.message).toContain('Invoice 1001');
  });

  it('sets aside a line that follows no dated line', () => {
    const orphan = 'Date,Account,Debit,Credit\n,Checking,1.00,\n01/01/2025,Checking,1.00,\n01/01/2025,Equity,,1.00\n';
    const books = readTransactionJournal([orphan], { dateOrder: 'mdy' });
    expect(books.violations.map((v) => v.rule)).toEqual(['no_transaction']);
    expect(books.entries).toHaveLength(1);
  });

  it('refuses files none of which is a journal, and a file it cannot recognise', () => {
    expect(() => readTransactionJournal([fixture('account-list.csv')])).toThrow(/no file is a journal/);
    expect(() => readTransactionJournal(['Colour,Size\nred,L\n'])).toThrow(BooksFileError);
  });

  it('refuses bytes that are not UTF-8 unless told they are Latin-1', () => {
    const latin = Uint8Array.from([...JOURNAL.replace('Kestrel Joinery', 'Kestrel Menuiserie é')].map((c) => c.charCodeAt(0)));
    expect(() => readTransactionJournal([latin], { dateOrder: 'mdy' })).toThrow(/not UTF-8/);
    expect(readTransactionJournal([latin], { dateOrder: 'mdy', encoding: 'iso-8859-1' }).contacts[1]!.name).toBe('Kestrel Menuiserie é');
  });
});
