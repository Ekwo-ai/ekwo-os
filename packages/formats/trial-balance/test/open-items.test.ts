import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { readOpenItems } from '../src/index.js';

const fixture = (name: string): string => readFileSync(new URL(`./fixtures/${name}`, import.meta.url), 'utf8');

describe('the open items beside a trial balance', () => {
  const read = readOpenItems(fixture('open-items.csv'));

  it('reads one item per row, with its number, its dates and its reference', () => {
    expect(read.items.map((item) => [item.type, item.number, item.contact, item.amount, item.documentDate, item.dueDate, item.paymentReference])).toEqual([
      ['sale_invoice', 'F2025-0412', 'C0001', '1200.00', '2025-12-12', '2026-01-11', '+++090/9337/55493+++'],
      ['sale_invoice', 'F2025-0431', 'C0001', '300.00', '2025-12-28', '2026-01-27', '+++090/9337/55594+++'],
      ['sale_invoice', 'F2025-0433', 'C0002', '250.50', '2025-12-30', null, null],
      ['purchase_invoice', 'A-2025-118', 'F0001', '900.00', '2025-12-20', '2026-01-19', 'VM-5521'],
    ]);
    expect(read.violations).toEqual([]);
  });

  it('keeps each party once, under the code the balance names it by', () => {
    expect(read.contacts.map((contact) => [contact.code, contact.name])).toEqual([
      ['C0001', 'Atelier Sirocco'],
      ['C0002', 'Brume et Fils'],
      ['F0001', 'Verger du Moulin'],
    ]);
  });

  it('leaves out a row that lacks what an item needs, and says so', () => {
    const partial = readOpenItems('type,number,contact,amount,date\nsale_invoice,,C1,10.00,2026-01-01\n');
    expect(partial.items).toEqual([]);
    expect(partial.violations).toEqual([{ rule: 'item_incomplete', message: 'an open item has no number and was left out', row: 2 }]);
  });

  it('refuses a day not written YYYY-MM-DD, a sign on the amount and a type it does not know', () => {
    expect(() => readOpenItems('type,number,contact,amount,date\nsale_invoice,F1,C1,10.00,01/02/2026\n')).toThrow(/YYYY-MM-DD/);
    expect(() => readOpenItems('type,number,contact,amount,date\nsale_invoice,F1,C1,10.00,2026-02-30\n')).toThrow(/YYYY-MM-DD/);
    expect(() => readOpenItems('type,number,contact,amount,date\nsale_invoice,F1,C1,-10.00,2026-01-01\n')).toThrow(/positive amount/);
    expect(() => readOpenItems('type,number,contact,amount,date\ninvoice,F1,C1,10.00,2026-01-01\n')).toThrow(/not one of sale_invoice/);
  });

  it('refuses a header without a column an item needs', () => {
    expect(() => readOpenItems('type,number,contact,amount\nsale_invoice,F1,C1,10.00\n')).toThrow(/no document date column/);
  });
});
