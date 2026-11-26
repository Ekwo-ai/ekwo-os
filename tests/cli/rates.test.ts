/**
 * `ekwo rates fetch`: a published series into the instance-wide rows of
 * `currency_rates`, against the instance reference currency.
 *
 * Offline: the European Central Bank's files are served by a fake fetch, from
 * XML written to the format the ECB documents and serves (the daily file with
 * single quotes, the 90-day and historical files with double quotes). The
 * rates in them are round illustrative figures, not published ones.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { run, type OutputDocument, type SqlClient } from '../../packages/cli/src/index.js';
import { ECB_90_DAYS, ECB_DAILY, ECB_HISTORY, ecb, parseEcbXml } from '../../packages/cli/src/rates/ecb.js';
import { freshDatabase } from '../helpers/db.js';
import { adapt, type Queryable } from './helpers.js';

const DB_URL = 'postgresql://postgres:secret@localhost:5432/postgres';
const BASE = ecb.base;
/** Not a currency any installation knows: the command leaves it out. */
const UNKNOWN = 'ZZZ';
/** A currency the fixture never quotes, and the installation knows. */
const NOT_QUOTED = 'XOF';

const envelope = (cubes: string): string =>
  `<?xml version="1.0" encoding="UTF-8"?><gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref"><gesmes:subject>Reference rates</gesmes:subject><gesmes:Sender><gesmes:name>European Central Bank</gesmes:name></gesmes:Sender><Cube>${cubes}</Cube></gesmes:Envelope>`;

const DAILY = `<?xml version="1.0" encoding="UTF-8"?>
<gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref">
	<gesmes:subject>Reference rates</gesmes:subject>
	<gesmes:Sender>
		<gesmes:name>European Central Bank</gesmes:name>
	</gesmes:Sender>
	<Cube>
		<Cube time='2026-03-03'>
			<Cube currency='USD' rate='1.2500'/>
			<Cube currency='GBP' rate='0.85000'/>
			<Cube currency='JPY' rate='150.00'/>
			<Cube currency='${UNKNOWN}' rate='2.0000'/>
		</Cube>
	</Cube>
</gesmes:Envelope>`;

const NINETY_DAYS = envelope(
  '<Cube time="2026-03-03"><Cube currency="USD" rate="1.2500"/><Cube currency="GBP" rate="0.85000"/><Cube currency="JPY" rate="150.00"/><Cube currency="' +
    UNKNOWN +
    '" rate="2.0000"/></Cube>' +
    '<Cube time="2026-03-02"><Cube currency="USD" rate="1.2000"/><Cube currency="GBP" rate="0.84000"/><Cube currency="JPY" rate="148.00"/></Cube>',
);

const HISTORY = envelope(
  '<Cube time="2026-03-03"><Cube currency="USD" rate="1.2500"/><Cube currency="GBP" rate="0.85000"/></Cube>' +
    '<Cube time="2026-03-02"><Cube currency="USD" rate="1.2000"/><Cube currency="GBP" rate="0.84000"/></Cube>' +
    '<Cube time="2026-02-27"><Cube currency="USD" rate="1.1000"/><Cube currency="GBP" rate="0.80000"/></Cube>',
);

const served: string[] = [];
const fetchImpl = (async (url: string | URL | Request): Promise<Response> => {
  const asked = String(url);
  served.push(asked);
  const body = { [ECB_DAILY]: DAILY, [ECB_90_DAYS]: NINETY_DAYS, [ECB_HISTORY]: HISTORY }[asked];
  return body === undefined ? new Response('', { status: 404 }) : new Response(body, { status: 200 });
}) as typeof globalThis.fetch;

let pg: PGlite;
let db: SqlClient;
const connect = async (): Promise<SqlClient> => ({ ...db, close: async () => {} });

async function rates(...argv: string[]): Promise<OutputDocument> {
  const write = process.stdout.write.bind(process.stdout);
  const err = process.stderr.write.bind(process.stderr);
  let stdout = '';
  process.stdout.write = ((chunk: string | Uint8Array) => {
    stdout += String(chunk);
    return true;
  }) as typeof process.stdout.write;
  process.stderr.write = (() => true) as typeof process.stderr.write;
  try {
    await run(['rates', 'fetch', ...argv, '--json', '--db-url', DB_URL], { connect, fetchImpl });
  } finally {
    process.stdout.write = write;
    process.stderr.write = err;
  }
  return JSON.parse(stdout) as OutputDocument;
}

async function stored(date: string): Promise<Record<string, { rate: string; source: string | null }>> {
  const rows = await db.query<{ currency_code: string; rate: string; source: string | null }>(
    `select currency_code::text, rate::text, source from currency_rates
      where company_id is null and rate_date = $1 order by currency_code`,
    [date],
  );
  return Object.fromEntries(rows.map((row) => [row.currency_code, { rate: row.rate, source: row.source }]));
}

async function reference(): Promise<string | null> {
  const [row] = await db.query<{ code: string | null }>('select reference_currency::text as code from instance where id = 1');
  return row?.code ?? null;
}

beforeAll(async () => {
  pg = await freshDatabase();
  db = adapt(pg as unknown as Queryable, pg);
  await db.query(`insert into instance (id, organization_name) values (1, 'Example Installation') on conflict (id) do nothing`);
});

afterAll(async () => {
  await pg.close();
});

beforeEach(async () => {
  served.length = 0;
  await db.query('update instance set reference_currency = null where id = 1');
  await db.query('delete from currency_rates where company_id is null');
});

describe('the ECB files', () => {
  it('reads the daily file, quoted with single quotes, and the others, quoted with double quotes', () => {
    expect(parseEcbXml(DAILY)).toEqual([
      { date: '2026-03-03', rates: { USD: '1.2500', GBP: '0.85000', JPY: '150.00', [UNKNOWN]: '2.0000' } },
    ]);
    expect(parseEcbXml(NINETY_DAYS).map((day) => day.date)).toEqual(['2026-03-03', '2026-03-02']);
  });

  it('refuses a file with no day in it, rather than reading it as a day without rates', () => {
    expect(() => parseEcbXml('<html>maintenance</html>')).toThrow(/rates_source_unreadable/);
  });
});

describe('ekwo rates fetch', () => {
  it('refuses until the instance reference currency is named, and writes nothing', async () => {
    const refused = await rates();
    expect(refused.error).toMatchObject({ kind: 'usage', name: 'instance_reference_currency_unset' });
    expect(served).toEqual([]);
    expect(await stored('2026-03-03')).toEqual({});
  });

  it('writes the latest day as published when the reference is the base of the source', async () => {
    const fetched = await rates('--reference-currency', BASE);
    expect(fetched.exitCode).toBe(0);
    expect(served).toEqual([ECB_DAILY]);
    expect(fetched.data).toMatchObject({
      source: 'ecb',
      base: BASE,
      reference_currency: BASE,
      date: '2026-03-03',
      published: true,
      unknown: [UNKNOWN],
    });
    expect(await reference()).toBe(BASE);
    expect(await stored('2026-03-03')).toEqual({
      GBP: { rate: '0.85000000', source: 'ecb' },
      JPY: { rate: '150.00000000', source: 'ecb' },
      USD: { rate: '1.25000000', source: 'ecb' },
    });
  });

  it('states every rate against a reference the source quotes, through the base', async () => {
    const fetched = await rates('--reference-currency', 'USD');
    expect(fetched.exitCode).toBe(0);
    // One USD is 1 / 1.25 of the base, 0.85 / 1.25 pound, 150 / 1.25 yen.
    expect(await stored('2026-03-03')).toEqual({
      [BASE]: { rate: '0.80000000', source: 'ecb' },
      GBP: { rate: '0.68000000', source: 'ecb' },
      JPY: { rate: '120.00000000', source: 'ecb' },
    });
  });

  it('changes nothing when the same day is fetched again', async () => {
    await rates('--reference-currency', BASE);
    const again = await rates();
    expect(again.data).toMatchObject({ written: [], overwritten: [], kept: [], unchanged: ['GBP', 'JPY', 'USD'] });
  });

  it('keeps a rate typed by hand for the day, and replaces it only with --overwrite, the trail keeping the old one', async () => {
    await db.query('update instance set reference_currency = $1 where id = 1', [BASE]);
    await db.query(
      `insert into currency_rates (currency_code, rate_date, rate, source) values ('USD', '2026-03-03', 1.3, 'typed by hand')`,
    );

    const kept = await rates();
    expect(kept.exitCode).toBe(0);
    expect(kept.data).toMatchObject({
      kept: [{ currency_code: 'USD', rate: '1.30000000', quoted: '1.25000000', source: 'typed by hand' }],
    });
    expect((await stored('2026-03-03'))['USD']).toEqual({ rate: '1.30000000', source: 'typed by hand' });

    const replaced = await rates('--overwrite');
    expect(replaced.data).toMatchObject({
      overwritten: [{ currency_code: 'USD', rate: '1.25000000', previous_rate: '1.30000000', previous_source: 'typed by hand' }],
      kept: [],
    });
    expect((await stored('2026-03-03'))['USD']).toEqual({ rate: '1.25000000', source: 'ecb' });
    const [trail] = await db.query<{ old_rate: string; new_rate: string }>(
      `select (old_values->>'rate') as old_rate, (new_values->>'rate') as new_rate from audit_log
        where table_name = 'currency_rates' and operation = 'update' order by id desc limit 1`,
    );
    expect(Number(trail?.old_rate)).toBe(1.3);
    expect(Number(trail?.new_rate)).toBe(1.25);
  });

  it('reads a day of the last ninety from the 90-day file, and an older one from the whole history', async () => {
    await db.query('update instance set reference_currency = $1 where id = 1', [BASE]);
    expect((await rates('--date', '2026-03-02')).data).toMatchObject({ date: '2026-03-02', published: true });
    expect(served).toEqual([ECB_90_DAYS]);
    expect((await stored('2026-03-02'))['USD']).toEqual({ rate: '1.20000000', source: 'ecb' });

    served.length = 0;
    expect((await rates('--date', '2026-02-27')).data).toMatchObject({ date: '2026-02-27', published: true });
    expect(served).toEqual([ECB_90_DAYS, ECB_HISTORY]);
    expect((await stored('2026-02-27'))['GBP']).toEqual({ rate: '0.80000000', source: 'ecb' });
  });

  it('writes nothing for a day the source did not publish, and carries no rate forward', async () => {
    const weekend = await rates('--date', '2026-02-28', '--reference-currency', BASE);
    expect(weekend.exitCode).toBe(0);
    expect(weekend.data).toMatchObject({ date: '2026-02-28', published: false, written: [] });
    expect(await stored('2026-02-28')).toEqual({});
    // A run that writes nothing records no reference either.
    expect(await reference()).toBeNull();
  });

  it('refuses a reference the source does not quote, by name, and writes nothing', async () => {
    const refused = await rates('--reference-currency', NOT_QUOTED);
    expect(refused.error).toMatchObject({ kind: 'usage', name: 'reference_currency_not_quoted' });
    expect(await stored('2026-03-03')).toEqual({});
    expect(await reference()).toBeNull();
  });

  it('refuses to change the reference once it is recorded', async () => {
    await rates('--reference-currency', BASE);
    const refused = await rates('--reference-currency', 'USD');
    expect(refused.error).toMatchObject({ kind: 'usage', name: 'instance_reference_currency_differs' });
    expect(await reference()).toBe(BASE);
  });

  it('refuses a source it does not know', async () => {
    const refused = await rates('--source', 'nowhere', '--reference-currency', BASE);
    expect(refused.error).toMatchObject({ kind: 'usage', name: 'unknown_rate_source' });
  });
});
