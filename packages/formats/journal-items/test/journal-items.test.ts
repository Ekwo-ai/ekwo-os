import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { BooksFileError, readJournalItems } from '../src/index.js';

const fixture = (name: string): string => readFileSync(new URL(`./fixtures/${name}`, import.meta.url), 'utf8');

describe('journal items exported under their labels', () => {
  const books = readJournalItems([fixture('journal-items.csv')]);

  it('gathers the lines of one entry by its number, in the order of the file', () => {
    expect(books.entries.map((e) => [e.number, e.journal, e.date, e.lines.length])).toEqual([
      ['MISC/2025/01/0001', 'Miscellaneous Operations', '2025-01-01', 2],
      ['INV/2025/00001', 'Customer Invoices', '2025-01-15', 3],
      ['BILL/2025/01/0001', 'Vendor Bills', '2025-01-20', 2],
    ]);
    expect(books.violations).toEqual([]);
  });

  it('reads the code of an account out of its display, and the rest as its name', () => {
    expect(books.entries[1]!.lines.map((l) => [l.account, l.debit, l.credit])).toEqual([
      ['400000', '1210.00', '0.00'],
      ['700000', '0.00', '1000.00'],
      ['451000', '0.00', '210.00'],
    ]);
    expect(books.accounts.find((a) => a.code === '700000')?.name).toBe('Services');
  });

  it('keeps the partner, the reference, the due date and the matching mark', () => {
    const receivable = books.entries[1]!.lines[0]!;
    expect([receivable.contact, receivable.dueDate, receivable.matching]).toEqual(['Atelier Sirocco', '2025-02-14', 'P1']);
    expect(books.entries[2]!.reference).toBe('A-17');
    expect(books.contacts.map((c) => c.name)).toEqual(['Atelier Sirocco', 'Verger du Moulin']);
  });

  it('keeps an amount in another currency, unsigned, and the company currency the file states', () => {
    const payable = books.entries[2]!.lines[0]!;
    expect([payable.currency, payable.amountCurrency]).toEqual(['USD', '100.00']);
    expect(books.currency).toBe('EUR');
  });
});

describe('the chart and the partners exported beside the lines', () => {
  const books = readJournalItems([fixture('partners.csv'), fixture('journal-items.csv'), fixture('accounts.csv')]);

  it('recognises each file by its header, in any order, and takes the types of the chart', () => {
    expect(books.entries).toHaveLength(3);
    expect(books.accounts.find((a) => a.code === '400000')?.type).toBe('Receivable');
  });

  it('takes the details of a partner from the partners file', () => {
    const partner = books.contacts.find((c) => c.name === 'Atelier Sirocco');
    expect([partner?.vatNumber, partner?.email, partner?.country]).toEqual(['XX0000000001', 'accounts@sirocco.example', null]);
  });
});

describe('journal items exported for re-import, under the technical names', () => {
  it('reads move_name, account_id and the other field names', () => {
    const books = readJournalItems([fixture('journal-items-technical.csv')]);
    expect(books.entries.map((e) => [e.number, e.lines.map((l) => [l.account, l.debit, l.credit])])).toEqual([
      ['MISC/2025/02/0001', [['610000', '15.50', '0.00'], ['550000', '0.00', '15.50']]],
    ]);
  });
});

describe('what does not add up, and what is not an export of journal items', () => {
  it('refuses a line of an entry that is not posted, in violations', () => {
    const books = readJournalItems([fixture('journal-items.csv').replace(/"Posted"$/m, '"Draft"')]);
    expect(books.violations.map((v) => v.rule)).toContain('not_posted');
  });

  it('says an entry does not balance', () => {
    const books = readJournalItems([fixture('journal-items.csv').replace('"0.0","1000.0"', '"0.0","999.0"')]);
    expect(books.violations.map((v) => v.rule)).toEqual(['balance']);
  });

  it('refuses a file it cannot recognise, and a set of files with no lines', () => {
    expect(() => readJournalItems(['"Colour","Size"\n"red","L"\n'])).toThrow(BooksFileError);
    expect(() => readJournalItems([fixture('accounts.csv')])).toThrow(/no file holds journal items/);
  });

  it('refuses lines that name no entry, and a date that is not ISO', () => {
    expect(() => readJournalItems(['"Date","Account","Debit","Credit"\n"2025-01-01","1 A","1","0"\n'])).toThrow(/names no entry/);
    expect(() => readJournalItems([fixture('journal-items.csv').replace('"2025-01-15"', '"15/01/2025"')])).toThrow(/YYYY-MM-DD/);
  });
});
