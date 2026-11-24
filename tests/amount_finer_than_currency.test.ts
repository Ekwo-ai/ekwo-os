import type { PGlite } from '@electric-sql/pglite';
import { readCamt053 } from '@ekwo-ai/camt053';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from './helpers/db.js';
import { installFixturePack } from './helpers/fixture-pack.js';
import { newContact, newUser } from './helpers/factory.js';

/**
 * An amount a caller writes as it is is refused when it is finer than its
 * currency (`20261124090000_an_amount_finer_than_its_currency_is_refused`).
 *
 * Since `20261123203000` a money column is a bare `numeric`: it keeps the
 * thousandth of a dinar the engine computed, and it would equally keep the
 * hundredth of a cent a caller sent. The engine rounds everything it writes
 * through `round_amount()`; what a caller writes straight into a table — a
 * line keyed on a draft entry, a statement line, a payment, the amount to
 * match — is held to the currency by `assert_amount_of_currency()`, which
 * refuses by name, `amount_finer_than_currency`, and never rounds.
 *
 * Proved here in a currency with two decimals, one with none and one with
 * three, each a fixture currency ISO 4217 never assigns: on every raw path an
 * amount finer than the currency is refused, an exact one passes, and trailing
 * zeros are not decimals.
 */

const TWO = { country: 'ZV', currency: 'ZVC', currencyName: 'Twoland unit', decimals: 2 };
const ZERO = { country: 'ZY', currency: 'ZYA', currencyName: 'Zeroland unit', decimals: 0 };
const THREE = { country: 'ZX', currency: 'ZXB', currencyName: 'Threeland unit', decimals: 3 };

/** An example IBAN of the standard's own documentation, which names no real account. */
const STATEMENT_IBAN = 'GB82WEST12345698765432';

interface Scenario {
  label: string;
  pack: typeof TWO;
  /** One decimal more than the currency has. */
  finer: string;
  /** At the decimals of the currency. */
  exact: string;
  /** The exact amount written with trailing zeros. */
  padded: string[];
}

const SCENARIOS: Scenario[] = [
  { label: 'two decimals', pack: TWO, finer: '12.345', exact: '12.34', padded: ['12.30', '12.300'] },
  { label: 'no decimals', pack: ZERO, finer: '12.5', exact: '12', padded: ['12.0', '12.00'] },
  { label: 'three decimals', pack: THREE, finer: '12.3456', exact: '12.345', padded: ['12.3450', '12.34500'] },
];

interface Books {
  companyId: string;
  ownerId: string;
  journalId: string;
  receivableId: string;
  expenseId: string;
  bankAccountId: string;
  contactId: string;
}

let db: PGlite;
const books = new Map<string, Books>();

beforeAll(async () => {
  db = await freshDatabase();
  for (const scenario of SCENARIOS) {
    await installFixturePack(db, scenario.pack);
    books.set(scenario.pack.currency, await booksIn(scenario.pack.country, scenario.pack.currency));
  }
}, 300_000);

afterAll(async () => {
  await db.close();
});

/** A company of a fixture country, its owner, its year, a bank account and a customer. */
async function booksIn(country: string, currency: string): Promise<Books> {
  const ownerId = await newUser(db, `owner-${country.toLowerCase()}@example.test`);
  const company = await one<{ id: string; journal: string; receivable: string }>(
    db,
    `insert into companies (name, country, fiscal_country, currency_code, language)
     select 'Example ' || $1, $1, $1, d.currency_code, d.language_default
       from country_defaults d where d.country = $1
     returning id, null::text as journal, null::text as receivable`,
    [country],
  );
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'owner')`, [
    company.id,
    ownerId,
  ]);
  await db.query(`select install_country_template($1, $2)`, [company.id, country]);
  await db.query(
    `insert into fiscal_years (company_id, name, start_date, end_date)
     values ($1, 'Year 2026', date '2026-01-01', date '2026-12-31')`,
    [company.id],
  );
  const ids = await one<{ journal: string; receivable: string; expense: string }>(
    db,
    `select c.miscellaneous_journal_id as journal, c.receivable_account_id as receivable,
            (select a.id from accounts a where a.company_id = c.id and a.account_type = 'expense'
              order by a.code limit 1) as expense
       from companies c where c.id = $1`,
    [company.id],
  );
  const bank = await one<{ id: string }>(
    db,
    `insert into bank_accounts (company_id, name, currency_code, iban, journal_id)
     values ($1, 'Current account', $2, $3,
             (select id from journals where company_id = $1 and journal_type = 'bank' order by code limit 1))
     returning id`,
    [company.id, currency, STATEMENT_IBAN],
  );
  const contactId = await newContact(db, company.id, { name: 'Example Customer', country });
  return {
    companyId: company.id,
    ownerId,
    journalId: ids.journal,
    receivableId: ids.receivable,
    expenseId: ids.expense,
    bankAccountId: bank.id,
    contactId,
  };
}

/** Runs as the owner, rolled back whatever happens, so every case starts from the same books. */
async function attempt(owner: string, sql: string, params: unknown[]): Promise<string | null> {
  return asUser(db, owner, async () => {
    await db.exec('begin');
    try {
      await db.query(sql, params);
      return null;
    } catch (error) {
      return (error as Error).message;
    } finally {
      await db.exec('rollback');
    }
  });
}

/** A draft entry of the company, as the owner, kept. */
async function draftEntry(b: Books): Promise<string> {
  return asUser(db, b.ownerId, async () =>
    (
      await one<{ id: string }>(
        db,
        `insert into entries (company_id, journal_id, entry_date, description)
         values ($1, $2, date '2026-03-02', 'keyed by hand') returning id`,
        [b.companyId, b.journalId],
      )
    ).id,
  );
}

const LINE = `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, contact_id)
              values ($1, $2, $3, $4, 'keyed', $5::numeric, $6::numeric, $7)`;

describe.each(SCENARIOS)('a currency with $label', (scenario) => {
  const b = (): Books => books.get(scenario.pack.currency)!;
  const amounts = (): string[] => [scenario.exact, ...scenario.padded];

  it('refuses a debit keyed on a draft entry finer than the currency, by name, and says how', async () => {
    const entry = await draftEntry(b());
    const message = await attempt(b().ownerId, LINE, [entry, b().companyId, b().expenseId, 10, scenario.finer, '0', null]);
    expect(message).toMatch(/^amount_finer_than_currency: entry_lines\.debit /);
    expect(message).toContain(`${scenario.pack.currency} is written with ${scenario.pack.decimals}`);
    expect(message).toContain(scenario.finer);
    // A credit is held to the same currency.
    expect(await attempt(b().ownerId, LINE, [entry, b().companyId, b().expenseId, 10, '0', scenario.finer, null])).toMatch(
      /^amount_finer_than_currency: entry_lines\.credit /,
    );
  });

  it('takes an exact debit, and the same written with trailing zeros', async () => {
    const entry = await draftEntry(b());
    for (const amount of amounts()) {
      expect(await attempt(b().ownerId, LINE, [entry, b().companyId, b().expenseId, 10, amount, '0', null]), amount).toBeNull();
    }
  });

  it('posts a balanced entry keyed at the decimals of the currency', async () => {
    // Larger than every amount below, so that matching one of them is not
    // refused for exceeding what is open.
    const large = `1${scenario.exact}`;
    const entry = await draftEntry(b());
    await asUser(db, b().ownerId, async () => {
      await db.query(LINE, [entry, b().companyId, b().receivableId, 10, `${large}${large.includes('.') ? '0' : '.0'}`, '0', b().contactId]);
      await db.query(LINE, [entry, b().companyId, b().receivableId, 20, '0', large, b().contactId]);
      await db.query(`select post_entry($1)`, [entry]);
    });
    const state = await one<{ state: string }>(db, `select state::text from entries where id = $1`, [entry]);
    expect(state.state).toBe('posted');
  });

  it('refuses an amount to match finer than the currency', async () => {
    const lines = await rows<{ id: string }>(
      db,
      `select l.id from entry_lines l join entries e on e.id = l.entry_id
        where e.company_id = $1 and e.state = 'posted' and l.account_id = $2 and l.matched_amount = 0
        order by l.debit desc limit 2`,
      [b().companyId, b().receivableId],
    );
    expect(lines).toHaveLength(2);
    const [a, c] = lines as [{ id: string }, { id: string }];
    expect(await attempt(b().ownerId, `select reconcile($1, $2, $3::numeric)`, [a.id, c.id, scenario.finer])).toMatch(
      /^amount_finer_than_currency: reconciliations\.amount /,
    );
    expect(await attempt(b().ownerId, `select reconcile($1, $2, $3::numeric)`, [a.id, c.id, scenario.padded[1]])).toBeNull();
  });

  it('refuses a statement line created by hand finer than the currency, and takes an exact one', async () => {
    const sql = `insert into bank_transactions (company_id, bank_account_id, sequence, transaction_date, amount, currency_code, state)
                 values ($1, $2, 1, date '2026-03-02', $3::numeric, $4, 'pending')`;
    expect(await attempt(b().ownerId, sql, [b().companyId, b().bankAccountId, scenario.finer, scenario.pack.currency])).toMatch(
      /^amount_finer_than_currency: bank_transactions\.amount /,
    );
    for (const amount of amounts()) {
      expect(await attempt(b().ownerId, sql, [b().companyId, b().bankAccountId, amount, scenario.pack.currency]), amount).toBeNull();
    }
  });

  it('refuses a statement entered by hand whose balance is finer than the currency', async () => {
    const sql = `insert into bank_statements (company_id, bank_account_id, statement_date, balance_start, balance_end_declared)
                 values ($1, $2, date '2026-03-31', $3::numeric, $4::numeric)`;
    expect(await attempt(b().ownerId, sql, [b().companyId, b().bankAccountId, scenario.finer, scenario.exact])).toMatch(
      /^amount_finer_than_currency: bank_statements\.balance_start /,
    );
    expect(await attempt(b().ownerId, sql, [b().companyId, b().bankAccountId, scenario.exact, scenario.finer])).toMatch(
      /^amount_finer_than_currency: bank_statements\.balance_end_declared /,
    );
    expect(await attempt(b().ownerId, sql, [b().companyId, b().bankAccountId, scenario.padded[0], scenario.padded[1]])).toBeNull();
  });

  it('refuses an imported statement line finer than the currency before writing anything, and imports an exact one', async () => {
    const file = (amount: string, closing: string) =>
      JSON.stringify(
        readCamt053(
          `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.053.001.08"><BkToCstmrStmt><GrpHdr><MsgId>M</MsgId></GrpHdr><Stmt><Id>S-${amount}</Id><Acct><Id><IBAN>${STATEMENT_IBAN}</IBAN></Id><Ccy>${scenario.pack.currency}</Ccy></Acct>` +
            `<Bal><Tp><CdOrPrtry><Cd>OPBD</Cd></CdOrPrtry></Tp><Amt Ccy="${scenario.pack.currency}">100</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2026-03-01</Dt></Dt></Bal>` +
            `<Bal><Tp><CdOrPrtry><Cd>CLBD</Cd></CdOrPrtry></Tp><Amt Ccy="${scenario.pack.currency}">${closing}</Amt><CdtDbtInd>CRDT</CdtDbtInd><Dt><Dt>2026-03-31</Dt></Dt></Bal>` +
            `<Ntry><Amt Ccy="${scenario.pack.currency}">${amount}</Amt><CdtDbtInd>CRDT</CdtDbtInd><Sts><Cd>BOOK</Cd></Sts><BookgDt><Dt>2026-03-02</Dt></BookgDt><BkTxCd/></Ntry>` +
            `</Stmt></BkToCstmrStmt></Document>`,
        ),
      );
    const before = await one<{ n: number }>(db, `select count(*)::int as n from bank_transactions where company_id = $1`, [b().companyId]);
    const sql = `select * from import_bank_statement($1, $2::jsonb)`;
    const refused = await attempt(b().ownerId, sql, [b().companyId, file(scenario.finer, `1${scenario.finer}`)]);
    expect(refused).toMatch(/^unreadable_statement_line: /);
    expect(refused).toContain(`more decimals than ${scenario.pack.currency} has`);
    const after = await one<{ n: number }>(db, `select count(*)::int as n from bank_transactions where company_id = $1`, [b().companyId]);
    expect(after.n).toBe(before.n);
    expect(await attempt(b().ownerId, sql, [b().companyId, file(scenario.exact, `1${scenario.exact}`)])).toBeNull();
  });

  it('refuses a payment finer than its currency, and takes an exact one', async () => {
    const sql = `insert into payments (company_id, direction, payment_date, amount, currency_code, contact_id, journal_id)
                 values ($1, 'inbound', date '2026-03-02', $2::numeric, $3, $4,
                         (select id from journals where company_id = $1 and journal_type = 'bank' order by code limit 1))`;
    expect(await attempt(b().ownerId, sql, [b().companyId, scenario.finer, scenario.pack.currency, b().contactId])).toMatch(
      /^amount_finer_than_currency: payments\.amount /,
    );
    for (const amount of amounts()) {
      expect(await attempt(b().ownerId, sql, [b().companyId, amount, scenario.pack.currency, b().contactId]), amount).toBeNull();
    }
  });

  it('refuses a stated tax finer than the currency of its document', async () => {
    const doc = (
      await one<{ id: string }>(
        db,
        `insert into documents (company_id, doc_type, contact_id, document_date)
         values ($1, 'purchase_invoice', $2, date '2026-03-02') returning id`,
        [b().companyId, b().contactId],
      )
    ).id;
    const sql = `insert into document_lines (document_id, company_id, sequence, name, quantity, unit_price, account_id, tax_id, stated_tax_amount)
                 values ($1, $2, 99, 'stated', 1, 1.23456, $3,
                         (select t.id from taxes t where t.company_id = $2 and t.amount > 0 and not t.price_include order by t.code limit 1),
                         $4::numeric)`;
    expect(await attempt(b().ownerId, sql, [doc, b().companyId, b().expenseId, scenario.finer])).toMatch(
      /^amount_finer_than_currency: document_lines\.stated_tax_amount /,
    );
    // A unit price finer than the currency is not an amount, and passes.
    expect(await attempt(b().ownerId, sql, [doc, b().companyId, b().expenseId, scenario.padded[0]])).toBeNull();
  });

  it('refuses a share capital finer than its currency', async () => {
    const sql = `update companies set share_capital = $2::numeric where id = $1`;
    expect(await attempt(b().ownerId, sql, [b().companyId, scenario.finer])).toMatch(
      /^amount_finer_than_currency: companies\.share_capital /,
    );
    expect(await attempt(b().ownerId, sql, [b().companyId, scenario.padded[1]])).toBeNull();
  });
});

describe('an amount in a currency that is not the company’s', () => {
  it('is held to its own currency, not to the company’s', async () => {
    // A line of the two-decimal company in the currency with none: 12.5 is a
    // fine amount of the company's currency and not one of the line's.
    const two = books.get(TWO.currency)!;
    const entry = await draftEntry(two);
    const sql = `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit, currency_code, amount_currency)
                 values ($1, $2, $3, 10, 'foreign', 10, 0, $4, $5::numeric)`;
    expect(await attempt(two.ownerId, sql, [entry, two.companyId, two.expenseId, ZERO.currency, '12.5'])).toMatch(
      /^amount_finer_than_currency: entry_lines\.amount_currency 12\.5 holds 1 decimals, and ZYA is written with 0/,
    );
    expect(await attempt(two.ownerId, sql, [entry, two.companyId, two.expenseId, ZERO.currency, '13'])).toBeNull();

    // And a line of the company with no decimals keeps the thousandths of
    // the currency that has three.
    const zero = books.get(ZERO.currency)!;
    const other = await draftEntry(zero);
    expect(await attempt(zero.ownerId, sql, [other, zero.companyId, zero.expenseId, THREE.currency, '1.234'])).toBeNull();
    expect(await attempt(zero.ownerId, sql, [other, zero.companyId, zero.expenseId, THREE.currency, '1.2345'])).toMatch(
      /^amount_finer_than_currency: entry_lines\.amount_currency /,
    );
  });
});

describe('what was written before', () => {
  it('is not judged by an update that leaves its amounts alone', async () => {
    const two = books.get(TWO.currency)!;
    const entry = await draftEntry(two);
    // A line written by a release before the guard: the installer passes, as
    // an archive being restored does.
    const line = await one<{ id: string }>(
      db,
      `insert into entry_lines (entry_id, company_id, account_id, sequence, name, debit, credit)
       values ($1, $2, $3, 10, 'older', 12.3456, 0) returning id`,
      [entry, two.companyId, two.expenseId],
    );
    expect(await attempt(two.ownerId, `update entry_lines set name = 'renamed' where id = $1`, [line.id])).toBeNull();
    expect(await attempt(two.ownerId, `update entry_lines set debit = 12.3457 where id = $1`, [line.id])).toMatch(
      /^amount_finer_than_currency: entry_lines\.debit /,
    );
    await db.query(`delete from entry_lines where id = $1`, [line.id]);
  });
});

describe('the modules', () => {
  it('attach the same guard to every amount they take from a caller', async () => {
    const triggers = await rows<{ table: string; args: string }>(
      db,
      `select n.nspname || '.' || c.relname as table,
              encode(t.tgargs, 'escape') as args
         from pg_trigger t
         join pg_class c on c.oid = t.tgrelid
         join pg_namespace n on n.oid = c.relnamespace
        where t.tgfoid = 'ekwo.amounts_of_currency_guard()'::regprocedure
          and n.nspname <> 'ekwo'
        order by 1`,
    );
    expect(triggers.map((t) => [t.table, t.args.split('\\000').filter(Boolean)])).toEqual([
      ['budgets.lines', ['company_id', 'amount']],
      ['contracts.contracts', ['company_id', 'total_value:currency_code']],
      ['crm.deals', ['company_id', 'amount:currency_code']],
      ['fixed_assets.disposals', ['company_id', 'proceeds']],
      ['fixed_assets.fixed_assets', ['company_id', 'cost', 'residual_value']],
    ]);
  });

  it('refuse a budget line and a deal finer than their currency', async () => {
    const three = books.get(THREE.currency)!;
    const writer = async (sql: string, params: unknown[]): Promise<string | null> => {
      await db.exec(`begin; select set_config('ekwo.installing', '', true);`);
      try {
        await db.query(sql, params);
        return null;
      } catch (error) {
        return (error as Error).message;
      } finally {
        await db.exec('rollback');
      }
    };
    const budget = `with b as (insert into budgets.budgets (company_id, code, name) values ($1, 'B', 'Budget') returning id)
                    insert into budgets.lines (budget_id, company_id, account_id, period_start, period_end, amount)
                    select b.id, $1, $2, date '2026-01-01', date '2026-12-31', $3::numeric from b`;
    expect(await writer(budget, [three.companyId, three.expenseId, '10.0001'])).toMatch(
      /^amount_finer_than_currency: lines\.amount 10\.0001 holds 4 decimals, and ZXB is written with 3/,
    );
    expect(await writer(budget, [three.companyId, three.expenseId, '10.001'])).toBeNull();

    const deal = `with p as (insert into crm.pipelines (company_id, name, slug) values ($1, 'Sales', 'sales') returning id),
                       s as (insert into crm.stages (company_id, pipeline_id, name, position) select $1, p.id, 'New', 1 from p returning id, pipeline_id)
                  insert into crm.deals (company_id, pipeline_id, stage_id, contact_id, title, amount, currency_code)
                  select $1, s.pipeline_id, s.id, $2, 'A deal', $3::numeric, $4 from s`;
    // A deal of the three-decimal company named in the currency with none.
    expect(await writer(deal, [three.companyId, three.contactId, '1500.5', ZERO.currency])).toMatch(
      /^amount_finer_than_currency: deals\.amount 1500\.5 holds 1 decimals, and ZYA is written with 0/,
    );
    expect(await writer(deal, [three.companyId, three.contactId, '1500.000', ZERO.currency])).toBeNull();
  });
});
