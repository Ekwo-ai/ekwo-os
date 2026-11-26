/**
 * The rate of a currency for a company on a day, read in one place.
 *
 * `exchange_rate_on()` answers the company's own rate of the day, otherwise
 * the installation's rate of the last day on or before it, both legs of that
 * same day, converted from the instance reference currency to the company's;
 * and refuses by name a day further back than its bound. `create_document()`
 * proposes it to a new document in another currency that names no rate, and
 * keeps a rate given by hand.
 *
 * Nothing here names a country or a currency: the company's currency is its
 * pack's, and the two others are taken from `currencies`.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { asUser, freshDatabase, one, rows } from './helpers/db.js';
import { allPacks } from './helpers/packs.js';
import { newCompany, newContact, type Fixture } from './helpers/factory.js';

const pack = allPacks[0]!;
const home = pack.manifest.defaults.currency;

let db: PGlite;
let fx: Fixture;
/** The installation's reference currency, and a third one, neither the company's. */
let reference: string;
let foreign: string;

interface Answer {
  rate: string;
  rate_date: string;
  source: string | null;
  origin: string;
}

async function refusal(call: Promise<unknown>): Promise<string> {
  try {
    await call;
  } catch (error) {
    return (error as Error).message;
  }
  throw new Error('expected a refusal');
}

/** What the reader answers, as the company's owner. */
async function rateOn(currency: string, day: string, extra = ''): Promise<Answer[]> {
  return asUser(db, fx.ownerId, () =>
    rows<Answer>(
      db,
      `select rate::text, rate_date::text, source, origin from exchange_rate_on($1, $2, $3::date${extra})`,
      [fx.companyId, currency, day],
    ),
  );
}

/** An instance-wide rate, written as `ekwo rates fetch` does: by the owner of the database. */
async function instanceRate(currency: string, day: string, rate: string, source = 'series'): Promise<void> {
  await db.query(`insert into currency_rates (currency_code, rate_date, rate, source) values ($1, $2::date, $3::numeric, $4)`, [
    currency,
    day,
    rate,
    source,
  ]);
}

async function nameReference(code: string): Promise<void> {
  await db.query(`update instance set reference_currency = $1 where id = 1`, [code]);
}

beforeEach(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: pack.manifest.country, name: 'Trader' });
  const others = await rows<{ code: string }>(db, `select code from currencies where code <> $1 order by code limit 2`, [home]);
  reference = others[0]!.code;
  foreign = others[1]!.code;
});

afterEach(async () => {
  await db.close();
});

describe('exchange_rate_on', () => {
  it('converts the installation rates of the last day on or before, both legs of that day', async () => {
    await nameReference(reference);
    // The company's currency is quoted on the 2nd and the 4th, the foreign one
    // on the 2nd, 3rd and 4th... and on the 5th only the foreign one: the 5th
    // has one leg and is passed over for the 4th.
    await instanceRate(home, '2027-03-02', '2.00000000');
    await instanceRate(foreign, '2027-03-02', '3.00000000');
    await instanceRate(foreign, '2027-03-03', '3.10000000');
    await instanceRate(home, '2027-03-04', '3.00000000');
    await instanceRate(foreign, '2027-03-04', '1.00000000');
    await instanceRate(foreign, '2027-03-05', '9.00000000');

    expect(await rateOn(foreign, '2027-03-06')).toEqual([
      // 1 / 3, in numeric, at the eight decimals a stored rate keeps.
      { rate: '0.33333333', rate_date: '2027-03-04', source: 'series', origin: 'instance' },
    ]);
    // On or before: the 3rd reads the 2nd, the day both legs are quoted.
    expect(await rateOn(foreign, '2027-03-03')).toEqual([
      { rate: '1.50000000', rate_date: '2027-03-02', source: 'series', origin: 'instance' },
    ]);
  });

  it('takes a leg in the reference currency as one', async () => {
    await nameReference(home);
    await instanceRate(foreign, '2027-03-01', '1.08450000');
    expect(await rateOn(foreign, '2027-03-02')).toEqual([
      { rate: '1.08450000', rate_date: '2027-03-01', source: 'series', origin: 'instance' },
    ]);

    // The reference itself, for a company kept in another currency: one over
    // the quote of the company's currency.
    await nameReference(foreign);
    await instanceRate(home, '2027-03-01', '4.00000000');
    expect(await rateOn(foreign, '2027-03-02')).toEqual([
      { rate: '0.25000000', rate_date: '2027-03-01', source: 'series', origin: 'instance' },
    ]);
  });

  it('prefers the company’s own rate of the day', async () => {
    await nameReference(reference);
    await instanceRate(home, '2027-03-01', '2.00000000');
    await instanceRate(foreign, '2027-03-01', '3.00000000');
    await asUser(db, fx.ownerId, () =>
      db.query(
        `insert into currency_rates (company_id, currency_code, rate_date, rate, source) values ($1, $2, date '2027-03-01', 1.4, 'typed')`,
        [fx.companyId, foreign],
      ),
    );
    expect(await rateOn(foreign, '2027-03-01')).toEqual([
      { rate: '1.40000000', rate_date: '2027-03-01', source: 'typed', origin: 'company' },
    ]);
    // Of that day only: the next day is the installation's.
    expect(await rateOn(foreign, '2027-03-02')).toEqual([
      { rate: '1.50000000', rate_date: '2027-03-01', source: 'series', origin: 'instance' },
    ]);
  });

  it('refuses a rate older than its bound by name, and answers nothing when it is not required', async () => {
    await nameReference(home);
    await instanceRate(foreign, '2027-03-01', '1.10000000');
    expect((await rateOn(foreign, '2027-03-06'))[0]?.rate_date).toBe('2027-03-01');
    expect(await refusal(rateOn(foreign, '2027-03-07'))).toMatch(/^exchange_rate_missing: /);
    expect(await rateOn(foreign, '2027-03-07', ', p_required => false')).toEqual([]);
    expect((await rateOn(foreign, '2027-03-07', ', p_max_age_days => 6'))[0]?.rate).toBe('1.10000000');
    expect(await refusal(rateOn(foreign, '2027-03-07', ', p_max_age_days => -1'))).toMatch(/^exchange_rate_max_age_invalid: /);
  });

  it('reads no installation rate while the installation names no reference currency', async () => {
    await instanceRate(foreign, '2027-03-01', '1.10000000');
    expect(await refusal(rateOn(foreign, '2027-03-01'))).toMatch(/^exchange_rate_missing: /);
  });
});

describe('a new document in another currency', () => {
  async function create(header: Record<string, unknown>): Promise<string> {
    const contact = await newContact(db, fx.companyId, { name: 'Abroad', country: null });
    return asUser(db, fx.ownerId, async () =>
      (
        await one<{ create_document: string }>(db, `select create_document($1::jsonb, '[]'::jsonb)`, [
          JSON.stringify({
            company_id: fx.companyId,
            doc_type: 'sale_invoice',
            contact_id: contact,
            document_date: '2027-03-08',
            currency_code: foreign,
            ...header,
          }),
        ])
      ).create_document,
    );
  }

  async function storedRate(id: string): Promise<string> {
    return (await one<{ rate: string }>(db, `select exchange_rate::text as rate from documents where id = $1`, [id])).rate;
  }

  it('takes the reader’s rate of its accounting day when none is given, and keeps it', async () => {
    await nameReference(home);
    await instanceRate(foreign, '2027-03-05', '1.25000000');
    await instanceRate(foreign, '2027-03-08', '1.30000000');
    // The accounting date is the day it is booked on, and the rate's.
    const id = await create({ accounting_date: '2027-03-07' });
    expect(await storedRate(id)).toBe('1.25000000');

    // A rate written afterwards for that day changes nothing stored.
    await instanceRate(foreign, '2027-03-07', '1.40000000');
    expect(await storedRate(id)).toBe('1.25000000');
  });

  it('keeps a rate given by hand', async () => {
    await nameReference(home);
    await instanceRate(foreign, '2027-03-08', '1.30000000');
    expect(await storedRate(await create({ exchange_rate: '1.11' }))).toBe('1.11000000');
  });

  it('refuses by name, once the installation reads published rates, a day with none close enough', async () => {
    await nameReference(home);
    await instanceRate(foreign, '2027-02-01', '1.30000000');
    expect(await refusal(create({}))).toMatch(/^exchange_rate_missing: /);
  });

  it('is created as before on an installation that names no reference currency', async () => {
    await instanceRate(foreign, '2027-03-08', '1.30000000');
    expect(await storedRate(await create({}))).toBe('1.00000000');
  });

  it('keeps the company’s currency at one', async () => {
    await nameReference(reference);
    expect(await storedRate(await create({ currency_code: home }))).toBe('1.00000000');
  });
});
