import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { BooksFileError, readTrialBalance } from '../src/index.js';

const fixture = (name: string): string => readFileSync(new URL(`./fixtures/${name}`, import.meta.url), 'utf8');

describe('a trial balance written with a debit and a credit column', () => {
  const books = readTrialBalance(fixture('balance.csv'));

  it('opens one line per row that does not net to zero, on the side it nets to', () => {
    expect(books.opening.map((line) => [line.account, line.debit, line.credit])).toEqual([
      ['512000', '8400.00', '0.00'],
      ['411000', '1500.00', '0.00'],
      ['411000', '250.50', '0.00'],
      ['401000', '0.00', '900.00'],
      ['101000', '0.00', '5000.00'],
      ['120000', '0.00', '4250.50'],
    ]);
  });

  it('keeps the party a receivable or a payable is owed by', () => {
    expect(books.opening.filter((line) => line.contact !== null).map((line) => line.contact)).toEqual(['C0001', 'C0002', 'F0001']);
    expect(books.contacts.map((contact) => [contact.code, contact.name])).toEqual([
      ['C0001', 'Atelier Sirocco'],
      ['C0002', 'Brume et Fils'],
      ['F0001', 'Verger du Moulin'],
    ]);
  });

  it('lists every account it names, the one that nets to zero included', () => {
    expect(books.accounts.map((account) => account.code)).toContain('218300');
    expect(books.accounts.find((account) => account.code === '512000')?.name).toBe('Bank');
  });

  it('balances, says no currency and holds no entry', () => {
    expect(books.violations).toEqual([]);
    expect(books.currency).toBeNull();
    expect(books.entries).toEqual([]);
    expect(books.format).toBe('trial-balance');
  });
});

describe('a trial balance written with one signed balance', () => {
  it('reads a semicolon file with a comma as its decimal mark, positive in debit', () => {
    const books = readTrialBalance(fixture('balance-semicolon.csv'));
    expect(books.opening.map((line) => [line.account, line.debit, line.credit])).toEqual([
      ['512000', '8400.00', '0.00'],
      ['101000', '0.00', '8400.00'],
    ]);
  });

  it('refuses a comma in a comma-separated file, where it could be a separator of thousands', () => {
    expect(() => readTrialBalance('account,balance\n512000,"8,400"\n')).toThrow(BooksFileError);
  });
});

describe('what does not add up, and what is not a trial balance', () => {
  it('says the balance is off, and by how much, without correcting it', () => {
    const books = readTrialBalance('account,debit,credit\n512000,100.00,\n101000,,99.99\n');
    expect(books.violations.map((v) => v.rule)).toEqual(['unbalanced']);
    expect(books.violations[0]?.message).toContain('100.00');
    expect(books.violations[0]?.message).toContain('99.99');
  });

  it('refuses a header with no account column, by name', () => {
    expect(() => readTrialBalance('code of nothing,debit,credit\n1,2,3\n')).toThrow(/account column/);
  });

  it('refuses a debit column beside a balance column, which would read an amount twice', () => {
    expect(() => readTrialBalance('account,debit,credit,balance\n1,2,,2\n')).toThrow(/read twice/);
  });

  it('refuses an amount with a currency sign or a thousands separator', () => {
    for (const amount of ['€100', '1 000.00', '1e3']) {
      expect(() => readTrialBalance(`account;debit;credit\n512000;${amount};\n`)).toThrow(/not an amount/);
    }
  });

  it('refuses bytes that are not UTF-8 unless Latin-1 is said', () => {
    const bytes = Uint8Array.from(Buffer.from('account,name,debit,credit\n512000,Café,1.00,\n101000,Capital,,1.00\n', 'latin1'));
    expect(() => readTrialBalance(bytes)).toThrow(/not UTF-8/);
    expect(readTrialBalance(bytes, { encoding: 'iso-8859-1' }).accounts[0]?.name).toBe('Café');
  });

  it('refuses an empty file and a header with nothing under it', () => {
    expect(() => readTrialBalance('')).toThrow(BooksFileError);
    expect(() => readTrialBalance('account,debit,credit\n')).toThrow(/no row/);
  });
});
