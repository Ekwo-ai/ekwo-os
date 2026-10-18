/**
 * Opening a set of books and closing a year, through the tools.
 *
 * The point here is that the three write tools are a thin call on the schema
 * functions: the refusals a model sees are the database's own words, and the
 * entries that appear are the ones `close_fiscal_year` wrote.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { writeTools, type Backend } from '../../packages/mcp/src/index.js';
import { freshDatabase, one } from '../helpers/db.js';
import { newCompany, newContact, newDocument, type Fixture } from '../helpers/factory.js';
import { backendFor, ledgerOfEntry, record } from './helpers.js';

let db: PGlite;
let fx: Fixture;
let backend: Backend;
let year2026: string;

beforeEach(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: 'BE', name: 'Closing SRL' });
  backend = backendFor(db, fx.ownerId);
  year2026 = (
    await one<{ id: string }>(
      db,
      `select id from fiscal_years where company_id = $1 and name = 'Exercice 2026'`,
      [fx.companyId],
    )
  ).id;
});

afterEach(async () => {
  await db.close();
});

describe('opening_balance', () => {
  it('posts the trial balance of the previous system', async () => {
    const answer = record(
      await writeTools.openingBalance(backend, {
        company_id: fx.companyId,
        fiscal_year_id: year2026,
        lines: [
          { account_code: '550000', debit: '20000.00' },
          { account_code: '100000', credit: '20000.00', label: 'Capital' },
        ],
      }),
    );
    const entry = record(answer['entry']);
    expect(entry['entry_date']).toBe('2026-01-01');
    expect(entry['state']).toBe('posted');
    expect(entry['total_debit']).toBe('20000.00');
    expect(await ledgerOfEntry(db, entry['id'] as string)).toEqual([
      { code: '550000', debit: '20000.00', credit: '0.00' },
      { code: '100000', debit: '0.00', credit: '20000.00' },
    ]);
  });

  it('opens on the day of the takeover, with the open items as documents', async () => {
    const customer = await newContact(db, fx.companyId, { type: 'customer', name: 'Atelier Sirocco' });
    const answer = record(
      await writeTools.openingBalance(backend, {
        company_id: fx.companyId,
        fiscal_year_id: year2026,
        opening_date: '2026-07-01',
        allow_result_accounts: true,
        lines: [
          { account_code: '550000', debit: '20000.00' },
          { account_code: '400000', debit: '1210.00' },
          { account_code: '700000', credit: '9000.00' },
          { account_code: '100000', credit: '12210.00' },
        ],
        items: [
          {
            doc_type: 'sale_invoice',
            number: 'F2026-0101',
            contact_id: customer,
            amount: '1210.00',
            document_date: '2026-06-15',
            due_date: '2026-07-15',
            payment_reference: '+++090/9337/55493+++',
          },
        ],
      }),
    );
    expect(record(answer['entry'])['entry_date']).toBe('2026-07-01');
    expect(answer['documents']).toEqual([
      expect.objectContaining({
        doc_type: 'sale_invoice',
        number: 'F2026-0101',
        payment_reference: '+++090/9337/55493+++',
        document_date: '2026-06-15',
        due_date: '2026-07-15',
        amount_total: '1210.00',
        state: 'posted',
      }),
    ]);
  });

  it('hands the refusal of the database back, word for word', async () => {
    await expect(
      writeTools.openingBalance(backend, {
        company_id: fx.companyId,
        fiscal_year_id: year2026,
        lines: [
          { account_code: '550000', debit: '20000.00' },
          { account_code: '100000', credit: '19000.00' },
        ],
      }),
    ).rejects.toThrow(/opening_unbalanced/);
  });
});

describe('close_fiscal_year and reopen_fiscal_year', () => {
  async function trade(): Promise<void> {
    const customer = await newContact(db, fx.companyId, { type: 'customer' });
    const document = await newDocument(db, fx.companyId, {
      docType: 'sale_invoice',
      contactId: customer,
      date: '2026-03-03',
      lines: [{ unitPrice: 5000, taxCode: 'BE-S-21', accountCode: '700000' }],
    });
    await writeTools.postDocument(backend, { document_id: document });
  }

  it('closes a year and says where the result went', async () => {
    await trade();
    const answer = record(
      await writeTools.closeFiscalYear(backend, { fiscal_year_id: year2026 }),
    );
    const close = record(answer['close']);
    expect(close['closing_style']).toBe('appropriation_accounts');
    expect(close['result']).toBe('5000.00');
    expect(close['result_kind']).toBe('profit');
    expect(await ledgerOfEntry(db, close['appropriation_entry_id'] as string)).toEqual([
      { code: '693000', debit: '5000.00', credit: '0.00' },
      { code: '140000', debit: '0.00', credit: '5000.00' },
    ]);
  });

  it('refuses to close twice, and re-opens what it closed', async () => {
    await trade();
    await writeTools.closeFiscalYear(backend, { fiscal_year_id: year2026 });
    await expect(
      writeTools.closeFiscalYear(backend, { fiscal_year_id: year2026 }),
    ).rejects.toThrow(/fiscal_year_already_closed/);

    const undone = record(
      await writeTools.reopenFiscalYear(backend, { fiscal_year_id: year2026 }),
    );
    expect((record(undone['reopen'])['reversal_entry_ids'] as string[]).length).toBe(2);
    expect(
      await one<{ is_closed: boolean }>(db, `select is_closed from fiscal_years where id = $1`, [
        year2026,
      ]),
    ).toEqual({ is_closed: false });
  });

  it('closes a closed year for good, after which reopening is refused', async () => {
    await trade();
    const closed = record(await writeTools.closeFiscalYear(backend, { fiscal_year_id: year2026 }));
    // What the country asks next comes with the close, from the pack.
    expect(record(closed['final_close'])).toHaveProperty('required');

    const final = record(
      await writeTools.closeFiscalYearFinally(backend, { fiscal_year_id: year2026 }),
    );
    expect(record(final['final_close'])['finally_closed_at']).toBeTruthy();
    await expect(
      writeTools.reopenFiscalYear(backend, { fiscal_year_id: year2026 }),
    ).rejects.toThrow(/fiscal_year_finally_closed/);
  });
});
