import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from '../../../tests/helpers/db.js';
import { allPacks } from '../../../tests/helpers/packs.js';
import type { Pack } from '../../../packages/cli/src/index.js';
import { book as bookEntry, decimal, earn, share, spend, taxCompany, taxPacks, thresholdRate } from './helpers.js';

// The two steps after the estimate: the provision entry, and the plan of
// prepayments. Nothing here expects a country: a test takes the first pack
// that carries what it needs — a schedule of shares, a surcharge — and works
// its expectation out from that pack's own figures.

const packs = taxPacks(allPacks);
const YEAR = { name: 'Year 2025', start: '2025-01-01', end: '2025-12-31' };
const NEXT = { name: 'Year 2026', start: '2026-01-01', end: '2026-12-31' };
const YEARS = [YEAR, NEXT];

type Section = NonNullable<Pack['corporateTax']>;
type Schedule = Section['prepayments'][number];

/** The prepayment schedule of a pack in force for a financial year, read the way the pack says. */
function scheduleFor(pack: Pack, year: { start: string; end: string }): Schedule | undefined {
  return pack.corporateTax?.prepayments.find((p) => {
    const day = p.valid_on === 'period_end' ? year.end : year.start;
    return p.valid_from <= day && (p.valid_to === null || p.valid_to === undefined || p.valid_to >= day);
  });
}

/** The first pack, and the first of the two years, whose schedule has this method. */
function withMethod(
  method: Schedule['method'],
  years: (typeof YEAR)[] = YEARS,
): { pack: Pack; year: typeof YEAR; schedule: Schedule } {
  for (const pack of packs) {
    for (const year of years) {
      const schedule = scheduleFor(pack, year);
      if (schedule?.method === method) return { pack, year, schedule };
    }
  }
  throw new Error(`no pack carries a ${method} schedule for 2025 or 2026`);
}

/** The day of an instalment in a calendar year, the last of the month where the month is shorter. */
function dueIn(year: string, month: number, day: number): string {
  const last = new Date(Date.UTC(Number(year), month, 0)).getUTCDate();
  return `${year}-${String(month).padStart(2, '0')}-${String(Math.min(day, last)).padStart(2, '0')}`;
}

/** Cents of a decimal string. */
const cents = (amount: string): bigint => {
  const [whole, fraction = ''] = amount.split('.');
  return BigInt(`${whole as string}${fraction.padEnd(2, '0').slice(0, 2)}`);
};
const text = (value: bigint): string => {
  const raw = value.toString().padStart(3, '0');
  return decimal(`${raw.slice(0, -2)}.${raw.slice(-2)}`) as string;
};
const millionths = (percent: number): bigint => BigInt(Math.round(percent * 1_000_000));

interface PlanLine {
  sequence: number;
  kind: string;
  code: string | null;
  due_date: string | null;
  base: string | null;
  rate: string | null;
  amount: string | null;
  paid: string | null;
}

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
}, 300_000);

afterAll(async () => {
  await db.close();
});

const plan = (
  fixture: { ownerId: string; companyId: string; fiscalYearId: string },
  at: string | null = null,
  tax: string | null = null,
): Promise<PlanLine[]> =>
  asUser(db, fixture.ownerId, () =>
    rows<PlanLine>(
      db,
      `select sequence, kind, code, due_date::text, base::text, rate::text, amount::text, paid::text
         from tax.prepayment_plan($1, $2, $3::date, $4::numeric) order by sequence`,
      [fixture.companyId, fixture.fiscalYearId, at, tax],
    ),
  );

const pay = (fixture: { ownerId: string; companyId: string; fiscalYearId: string }, on: string, amount: string) =>
  asUser(db, fixture.ownerId, () =>
    db.query(`insert into tax.prepayments (company_id, fiscal_year_id, paid_on, amount) values ($1, $2, $3::date, $4::numeric)`, [
      fixture.companyId,
      fixture.fiscalYearId,
      on,
      amount,
    ]),
  );

// --------------------------------------------------------------- the provision

describe('the provision', () => {
  // A pack whose reduced rate asks something nobody declares here: the whole
  // profit goes to the ordinary rate, and every profit is taxed.
  const pack = packs.find((p) => (thresholdRate(p.corporateTax!, YEAR)?.conditions.length ?? 0) > 0)!;
  const section = pack.corporateTax as Section;
  const country = pack.manifest.country;

  const record = (fixture: { ownerId: string; companyId: string; fiscalYearId: string }, at: string | null = null) =>
    asUser(db, fixture.ownerId, async () =>
      (await one<{ id: string }>(db, `select tax.record_computation($1, $2, $3::date) as id`, [fixture.companyId, fixture.fiscalYearId, at])).id,
    );
  const book = (userId: string, computation: string) =>
    asUser(db, userId, async () => (await one<{ entry: string | null }>(db, `select tax.book_provision($1) as entry`, [computation])).entry);
  const taxOf = async (computation: string): Promise<bigint> =>
    cents((await one<{ tax: string }>(db, `select tax::text from tax.computations where id = $1`, [computation])).tax);
  const linesOf = (entry: string) =>
    rows<{ account: string; debit: string; credit: string }>(
      db,
      `select a.code as account, l.debit::text, l.credit::text
         from entry_lines l join accounts a on a.id = l.account_id
        where l.entry_id = $1 order by l.sequence`,
      [entry],
    );

  it('books the difference with what the charge carries, and a later computation only what moved', async () => {
    const fixture = await taxCompany(db, country, 'Provision', YEAR);

    await earn(db, pack, fixture.companyId, '2025-03-01', '10000.00');
    const march = await record(fixture, '2025-03-31');
    const first = await book(fixture.ownerId, march);
    expect(first).not.toBeNull();
    const tax1 = await taxOf(march);
    expect(tax1 > 0n).toBe(true);

    // On the pack's accounts, on the day the computation read up to, under the module.
    expect(
      await one(db, `select entry_date::text, module_code, module_ref, state::text from entries where id = $1`, [first]),
    ).toEqual({ entry_date: '2025-03-31', module_code: 'tax', module_ref: `provision:${march}`, state: 'posted' });
    expect((await linesOf(first as string)).map((l) => [l.account, decimal(l.debit), decimal(l.credit)])).toEqual([
      [section.accounts.expense, text(tax1), '0'],
      [section.accounts.payable, '0', text(tax1)],
    ]);

    // Asked again, the same entry.
    expect(await book(fixture.ownerId, march)).toBe(first);

    // More profit: only the increase.
    await earn(db, pack, fixture.companyId, '2025-06-01', '20000.00');
    const june = await record(fixture, '2025-06-30');
    const second = await book(fixture.ownerId, june);
    const tax2 = await taxOf(june);
    expect((await linesOf(second as string)).map((l) => [l.account, decimal(l.debit), decimal(l.credit)])).toEqual([
      [section.accounts.expense, text(tax2 - tax1), '0'],
      [section.accounts.payable, '0', text(tax2 - tax1)],
    ]);

    // Less profit: the charge comes down, the other way round.
    await spend(db, pack, fixture.companyId, '2025-09-01', '25000.00');
    const year = await record(fixture);
    const third = await book(fixture.ownerId, year);
    const tax3 = await taxOf(year);
    expect(tax3 < tax2).toBe(true);
    expect((await linesOf(third as string)).map((l) => [l.account, decimal(l.debit), decimal(l.credit)])).toEqual([
      [section.accounts.payable, text(tax2 - tax3), '0'],
      [section.accounts.expense, '0', text(tax2 - tax3)],
    ]);

    // Nothing moved since: nothing to book.
    const again = await record(fixture);
    expect(await book(fixture.ownerId, again)).toBeNull();

    // The charge of the year is the tax of the year, and the estimate did not move.
    const charge = await one<{ balance: string }>(
      db,
      `select coalesce(sum(l.debit - l.credit), 0)::text as balance
         from entry_lines l join entries e on e.id = l.entry_id
        where e.company_id = $1 and e.state = 'posted' and l.account_id = account_id_by_code($1, $2)`,
      [fixture.companyId, section.accounts.expense],
    );
    expect(cents(charge.balance)).toBe(tax3);
    expect(await taxOf(again)).toBe(tax3);
  });

  it('counts a charge the company booked itself, and books the rest', async () => {
    const fixture = await taxCompany(db, country, 'Booked by hand', YEAR);
    await earn(db, pack, fixture.companyId, '2025-03-01', '50000.00');
    const computation = await record(fixture);
    const tax = await taxOf(computation);
    // A third of it booked by hand, against the payable account.
    const third = tax / 3n;
    await bookEntry(db, fixture.companyId, {
      date: '2025-06-30',
      description: 'Tax charge, by hand',
      lines: [
        { account: section.accounts.expense, debit: text(third) },
        { account: section.accounts.payable, credit: text(third) },
      ],
    });
    const entry = await book(fixture.ownerId, computation);
    const lines = await linesOf(entry as string);
    expect(decimal(lines[0]?.debit)).toBe(text(tax - third));
  });

  it('follows the latest computation of a year, and never a withdrawn one', async () => {
    const fixture = await taxCompany(db, country, 'Latest', YEAR);
    await earn(db, pack, fixture.companyId, '2025-03-01', '10000.00');
    const first = await record(fixture);
    const second = await record(fixture);
    const refused = await asUser(db, fixture.ownerId, () => expectError(db, `select tax.book_provision($1)`, [first]));
    expect(refused).toMatch(/^computation_not_latest:/);

    await asUser(db, fixture.ownerId, async () => {
      await db.query(`select tax.finalise_computation($1)`, [second]);
      await db.query(`select tax.withdraw_computation($1)`, [second]);
    });
    const withdrawn = await asUser(db, fixture.ownerId, () => expectError(db, `select tax.book_provision($1)`, [second]));
    expect(withdrawn).toMatch(/^computation_superseded:/);
  });

  it('needs tax.write, and is not there for a stranger', async () => {
    const fixture = await taxCompany(db, country, 'Rights', YEAR);
    await earn(db, pack, fixture.companyId, '2025-03-01', '10000.00');
    const computation = await record(fixture);

    const viewer = crypto.randomUUID();
    await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [fixture.companyId, viewer]);
    expect(await asUser(db, viewer, () => expectError(db, `select tax.book_provision($1)`, [computation]))).toMatch(
      /^not_allowed: booking the provision of the tax needs tax\.write/,
    );

    const stranger = crypto.randomUUID();
    expect(await asUser(db, stranger, () => expectError(db, `select tax.book_provision($1)`, [computation]))).toMatch(
      /^unknown_computation:/,
    );

    const entries = await rows(db, `select 1 from entries where company_id = $1 and module_code = 'tax'`, [fixture.companyId]);
    expect(entries).toEqual([]);
  });
});

// ------------------------------------------------------------ instalment days

describe('the day of an instalment', () => {
  const day = async (basis: string, month: number, dayOf: number, start: string, end: string): Promise<string | null> =>
    (
      await one<{ d: string | null }>(db, `select tax.instalment_date($1, $2, $3, $4::date, $5::date)::text as d`, [
        basis,
        month,
        dayOf,
        start,
        end,
      ])
    ).d;

  it('is a month of the calendar or a month of the year, and the last day of a short month', async () => {
    expect(await day('calendar', 4, 10, '2025-01-01', '2025-12-31')).toBe('2025-04-10');
    // A year that opens in July: April is the April of the next calendar year.
    expect(await day('calendar', 4, 10, '2025-07-01', '2026-06-30')).toBe('2026-04-10');
    expect(await day('calendar', 12, 20, '2025-07-01', '2026-06-30')).toBe('2025-12-20');
    // The fourth month of that same year.
    expect(await day('fiscal', 4, 10, '2025-07-01', '2026-06-30')).toBe('2025-10-10');
    expect(await day('calendar', 2, 31, '2025-01-01', '2025-12-31')).toBe('2025-02-28');
    // A short year has no September.
    expect(await day('calendar', 9, 15, '2025-01-01', '2025-06-30')).toBeNull();
  });
});

// ----------------------------------------------- shares of a reference tax

describe('a plan of shares of the tax of the year before', () => {
  // The year before is the one every pack carries rates for.
  const { pack, year, schedule } = withMethod('share_of_reference_tax', [NEXT]);
  const country = pack.manifest.country;
  const before = YEAR;
  const instalments = [...schedule.instalments].sort((a, b) => a.month - b.month || a.sequence - b.sequence);

  async function twoYears(name: string): Promise<{ ownerId: string; companyId: string; fiscalYearId: string; previousId: string }> {
    const fixture = await taxCompany(db, country, name, before);
    await db.query(`insert into fiscal_years (company_id, name, start_date, end_date) values ($1, $2, $3::date, $4::date)`, [
      fixture.companyId,
      year.name,
      year.start,
      year.end,
    ]);
    const current = await one<{ id: string }>(db, `select id from fiscal_years where company_id = $1 and start_date = $2::date`, [
      fixture.companyId,
      year.start,
    ]);
    return { ...fixture, fiscalYearId: current.id, previousId: fixture.fiscalYearId };
  }

  it('takes each share of the final tax of the year before, on its day, and counts what was paid towards it', async () => {
    const fixture = await twoYears('Shares');
    await earn(db, pack, fixture.companyId, `${before.start.slice(0, 4)}-03-01`, '2000000.00');
    const reference = await asUser(db, fixture.ownerId, async () => {
      const id = (await one<{ id: string }>(db, `select tax.record_computation($1, $2) as id`, [fixture.companyId, fixture.previousId])).id;
      await db.query(`select tax.finalise_computation($1)`, [id]);
      return (await one<{ tax: string }>(db, `select tax::text from tax.computations where id = $1`, [id])).tax;
    });
    expect(Number(reference)).toBeGreaterThan(schedule.exempt_up_to ?? 0);

    // Paid five days before the first instalment, and once after the last.
    const first = instalments[0]!;
    const firstDay = dueIn(year.start.slice(0, 4), first.month, first.day);
    const early = new Date(`${firstDay}T00:00:00Z`);
    early.setUTCDate(early.getUTCDate() - 5);
    await pay(fixture, early.toISOString().slice(0, 10), '100.00');
    await pay(fixture, year.end, '7.00');

    const lines = await plan(fixture);
    expect(lines[0]).toMatchObject({ kind: 'reference_tax', code: before.name });
    expect(decimal(lines[0]?.amount)).toBe(decimal(reference));

    const planned = lines.filter((l) => l.kind === 'instalment');
    expect(
      planned.map((l) => [l.code, l.due_date, decimal(l.rate), decimal(l.amount), decimal(l.paid)]),
    ).toEqual(
      instalments.map((i, index) => [
        String(i.sequence),
        dueIn(year.start.slice(0, 4), i.month, i.day),
        decimal(String(i.share_percent)),
        decimal(share(reference, i.share_percent as number)),
        index === 0 ? '100' : '0',
      ]),
    );
    const total = lines.find((l) => l.kind === 'total');
    expect(decimal(total?.amount)).toBe(
      text(instalments.reduce((sum, i) => sum + cents(share(reference, i.share_percent as number)), 0n)),
    );
    expect(decimal(total?.paid)).toBe('100');
    expect(lines.at(-1)).toMatchObject({ kind: 'paid_late', due_date: year.end });
    expect(decimal(lines.at(-1)?.paid)).toBe('7');
  });

  it('asks nothing where the reference is within the exemption, and takes a reference the company states', async () => {
    const fixture = await twoYears('Stated');
    const stated = schedule.exempt_up_to === null ? '1000.00' : String(schedule.exempt_up_to);
    const lines = await plan(fixture, null, stated);
    expect(lines[0]).toMatchObject({ kind: 'reference_tax', code: 'stated' });
    if (schedule.exempt_up_to !== null) {
      expect(lines[1]?.kind).toBe('exempt');
      expect(lines.filter((l) => l.kind === 'instalment').map((l) => decimal(l.amount))).toEqual(instalments.map(() => '0'));
    }
  });

  it('refuses by name a year whose year before was never called final', async () => {
    const fixture = await twoYears('No reference');
    expect(
      await asUser(db, fixture.ownerId, () =>
        expectError(db, `select * from tax.prepayment_plan($1, $2)`, [fixture.companyId, fixture.fiscalYearId]),
      ),
    ).toMatch(/^no_reference_tax:/);
  });
});

// ------------------------------------------------------- against a surcharge

describe('a plan against a surcharge on what was not paid in advance', () => {
  const { pack, year, schedule } = withMethod('surcharge_on_shortfall');
  const country = pack.manifest.country;
  const instalments = [...schedule.instalments].sort((a, b) => a.month - b.month || a.sequence - b.sequence);
  const calendarYear = year.start.slice(0, 4);
  const TAX = '100000.00';
  const surcharge = share(TAX, schedule.surcharge_percent as number);

  /** The same amount at each open instalment that covers what is left, rounded up to the cent. */
  function each(left: bigint, open: typeof instalments): bigint {
    const credits = open.reduce((sum, i) => sum + millionths(i.credit_percent as number), 0n);
    const scaled = left * 100n * 1_000_000n;
    return (scaled + credits - 1n) / credits;
  }

  it('spreads one amount over the instalments that leaves no surcharge', async () => {
    const fixture = await taxCompany(db, country, 'Surcharge', year);
    const lines = await plan(fixture, null, TAX);
    expect(lines.slice(0, 2).map((l) => [l.kind, decimal(l.amount)])).toEqual([
      ['tax', decimal(TAX)],
      ['surcharge', decimal(surcharge)],
    ]);
    const expected = text(each(cents(surcharge), instalments));
    expect(
      lines.filter((l) => l.kind === 'instalment').map((l) => [l.due_date, decimal(l.rate), decimal(l.amount)]),
    ).toEqual(instalments.map((i) => [dueIn(calendarYear, i.month, i.day), decimal(String(i.credit_percent)), expected]));
    expect(decimal(lines.at(-1)?.amount)).toBe('0');
    expect(lines.at(-1)?.kind).toBe('surcharge_left');
  });

  it('counts what was paid in time, and asks the rest of the instalments still to come', async () => {
    const fixture = await taxCompany(db, country, 'Paid in part', year);
    const first = instalments[0]!;
    const firstDay = dueIn(calendarYear, first.month, first.day);
    await pay(fixture, firstDay, '10000.00');

    const after = new Date(`${firstDay}T00:00:00Z`);
    after.setUTCDate(after.getUTCDate() + 1);
    const lines = await plan(fixture, after.toISOString().slice(0, 10), TAX);
    const planned = lines.filter((l) => l.kind === 'instalment');
    expect(decimal(planned[0]?.amount)).toBe('0');
    expect(decimal(planned[0]?.paid)).toBe('10000');

    // What the payment earned, then the rest over the others.
    const earned = (cents('10000.00') * millionths(first.credit_percent as number)) / 100_000_000n;
    const rest = cents(surcharge) - earned;
    const open = instalments.slice(1);
    const amount = each(rest > 0n ? rest : 0n, open);
    const cap = (cents(TAX) - cents('10000.00')) / BigInt(open.length);
    const expected = amount < cap ? amount : cap;
    expect(planned.slice(1).map((l) => decimal(l.amount))).toEqual(open.map(() => text(expected)));
  });

  it('never asks more than the tax, and says what surcharge is left when the time is too short', async () => {
    const last = instalments.at(-1)!;
    if ((last.credit_percent as number) >= (schedule.surcharge_percent as number)) return;
    const fixture = await taxCompany(db, country, 'Too late', year);
    const lines = await plan(fixture, dueIn(calendarYear, last.month, last.day), TAX);
    const planned = lines.filter((l) => l.kind === 'instalment');
    expect(decimal(planned.at(-1)?.amount)).toBe(decimal(TAX));
    const earned = share(TAX, last.credit_percent as number);
    expect(decimal(lines.at(-1)?.amount)).toBe(text(cents(surcharge) - cents(earned)));
  });

  it('plans from the latest computation of the year, and refuses a year that has none', async () => {
    const fixture = await taxCompany(db, country, 'From a computation', year);
    expect(
      await asUser(db, fixture.ownerId, () =>
        expectError(db, `select * from tax.prepayment_plan($1, $2)`, [fixture.companyId, fixture.fiscalYearId]),
      ),
    ).toMatch(/^no_computation:/);
    await earn(db, pack, fixture.companyId, `${calendarYear}-02-01`, '80000.00');
    const computation = await asUser(db, fixture.ownerId, async () =>
      (await one<{ id: string }>(db, `select tax.record_computation($1, $2) as id`, [fixture.companyId, fixture.fiscalYearId])).id,
    );
    const tax = (await one<{ tax: string }>(db, `select tax::text from tax.computations where id = $1`, [computation])).tax;
    const lines = await plan(fixture);
    expect(lines[0]).toMatchObject({ kind: 'tax', code: 'version 1' });
    expect(decimal(lines[0]?.amount)).toBe(decimal(tax));
  });
});

// ------------------------------------------------------------ what is refused

describe('a plan the pack cannot make', () => {
  it('is refused by name where the pack carries no prepayment for the year', async () => {
    const pack = packs.find((p) => YEARS.every((y) => scheduleFor(p, y) === undefined));
    expect(pack, 'a pack with no prepayment schedule').toBeDefined();
    const fixture = await taxCompany(db, (pack as Pack).manifest.country, 'No schedule', YEAR);
    expect(
      await asUser(db, fixture.ownerId, () =>
        expectError(db, `select * from tax.prepayment_plan($1, $2, null, 1000)`, [fixture.companyId, fixture.fiscalYearId]),
      ),
    ).toMatch(/^no_prepayment_rules:/);
  });

  it('keeps a payment in advance at the decimals of the currency, and above zero', async () => {
    const fixture = await taxCompany(db, (packs[0] as Pack).manifest.country, 'Decimals', YEAR);
    expect(
      await asUser(db, fixture.ownerId, () =>
        expectError(db, `insert into tax.prepayments (company_id, fiscal_year_id, paid_on, amount) values ($1, $2, date '2025-04-01', 0.001)`, [
          fixture.companyId,
          fixture.fiscalYearId,
        ]),
      ),
    ).toMatch(/prepayment_not_positive|tax_prepayments_amount_positive/);
  });
});
