import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { BooksFileError, amount, readDate, readJournalReport } from '../src/index.js';

const fixture = (name: string): string => readFileSync(new URL(`./fixtures/${name}`, import.meta.url), 'utf8');

describe('a journal report saved as CSV', () => {
  const books = readJournalReport([fixture('journal-report.csv')], { dateOrder: 'dmy' });

  it('finds the header under the title rows and passes over the headings and totals', () => {
    expect(books.entries.map((e) => [e.number, e.journal, e.date, e.lines.length])).toEqual([
      ['101', 'Manual Journal', '2025-01-01', 2],
      ['102', 'Receivable Invoice', '2025-01-15', 3],
      ['103', 'Receive Money', '2025-01-28', 2],
    ]);
    expect(books.violations).toEqual([]);
  });

  it('reads amounts grouped by thousands in a comma-separated file', () => {
    expect(books.entries[1]!.lines.map((l) => [l.account, l.debit, l.credit])).toEqual([
      ['610', '1150.00', '0.00'],
      ['200', '0.00', '1000.00'],
      ['820', '0.00', '150.00'],
    ]);
  });

  it('names the accounts it saw, and claims no currency', () => {
    expect(books.accounts.map((a) => [a.code, a.name])).toEqual([
      ['090', 'Business Bank Account'],
      ['970', 'Owner Funds Introduced'],
      ['610', 'Accounts Receivable'],
      ['200', 'Sales'],
      ['820', 'Sales Tax'],
    ]);
    expect(books.currency).toBeNull();
  });
});

describe('the chart of accounts and the contacts beside the report', () => {
  it('takes the types of the chart, its codes kept as text, and the contacts', () => {
    const books = readJournalReport([fixture('chart.csv'), fixture('journal-report.csv'), fixture('contacts.csv')], { dateOrder: 'dmy' });
    expect(books.accounts.find((a) => a.code === '090')?.type).toBe('Bank');
    expect(books.contacts.map((c) => [c.name, c.vatNumber])).toEqual([
      ['Atelier Sirocco', 'XX0000000001'],
      ['Kestrel Joinery', null],
    ]);
  });
});

describe('dates', () => {
  it('refuses a date written in digits when nobody says in which order', () => {
    expect(() => readJournalReport([fixture('journal-report.csv')])).toThrow(/in which order/);
  });

  it('reads the order it is told, and a month in letters without being told', () => {
    expect(readDate('03/04/2026', 'dmy', 1)).toBe('2026-04-03');
    expect(readDate('03/04/2026', 'mdy', 1)).toBe('2026-03-04');
    expect(readDate('3 Apr 2026', undefined, 1)).toBe('2026-04-03');
    expect(readDate('Apr 3, 2026', undefined, 1)).toBe('2026-04-03');
    expect(readDate('2026-04-03', undefined, 1)).toBe('2026-04-03');
  });

  it('passes over what is not a date, and refuses what looks like one and is not', () => {
    expect(readDate('Total Sales', 'dmy', 1)).toBeNull();
    expect(() => readDate('31/02/2026', 'dmy', 1)).toThrow(/calendar/);
  });
});

describe('amounts', () => {
  it('reads the three ways a spreadsheet displays one, and refuses the ambiguous', () => {
    expect(amount('1,234.50', ',', 1)).toBe(1_234_500_000n);
    expect(amount('(12.00)', ',', 1)).toBe(-12_000_000n);
    expect(amount('1 234,50', ';', 1)).toBe(1_234_500_000n);
    expect(() => amount('1,23', ',', 1)).toThrow(BooksFileError);
    expect(() => amount('1.234,50', ';', 1)).toThrow(BooksFileError);
  });
});

describe('what is not a report', () => {
  it('refuses a report without the journal number that puts lines back into entries', () => {
    const noJournal = 'Date,Account Code,Debit,Credit\n2025-01-01,090,1.00,\n';
    expect(() => readJournalReport([noJournal])).toThrow(/Journal ID/);
  });

  it('refuses files none of which is a report', () => {
    expect(() => readJournalReport([fixture('chart.csv')])).toThrow(/no file is a report/);
  });

  it('says a journal does not balance', () => {
    const books = readJournalReport([fixture('journal-report.csv').replace(',,150.00', ',,149.00')], { dateOrder: 'dmy' });
    expect(books.violations.map((v) => v.rule)).toEqual(['balance']);
  });
});
