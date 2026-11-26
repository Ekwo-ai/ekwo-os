/**
 * `ekwo rates fetch` — the day's exchange rates of a published series, into
 * the instance-wide rows of `currency_rates`.
 *
 * An instance-wide row (no `company_id`) is units of a currency for one unit
 * of the instance reference currency, `instance.reference_currency`. A source
 * quotes against its own base, so each quote is divided by the source's quote
 * of the reference currency, in Postgres `numeric` and rounded to the eight
 * decimals the column keeps; when the reference is the base, the published
 * figures are written as they are. A reference the source does not quote is
 * refused by name, never replaced by another currency.
 *
 * Idempotent, and careful with what is already there:
 *   - a day already fetched again changes nothing;
 *   - a rate already recorded for that currency and day — typed by hand, or
 *     from another series — is kept unless `--overwrite`, and the audit trail
 *     keeps the value it replaced;
 *   - a day the source did not publish (a weekend, a holiday) writes nothing
 *     and says so: no rate is carried forward into the table.
 *
 * Instance-wide rows are written by nobody through the API, so the command
 * connects as the owner of the database, like `migrate`. It holds no
 * schedule: the operator runs it daily from cron, a CI job or a hosted service.
 * A document keeps the rate it was booked at, and a company closes at its own
 * rate (`ekwo close rate`): nothing written here changes either.
 */

import { boolFlag, rejectUnknownFlags, stringFlag, UsageError, type ParsedArgs } from '../args.js';
import { CONNECTION_FLAGS, openDatabase, type CommandDeps } from '../context.js';
import { setResult } from '../output.js';
import { RATE_SOURCES, type RateSource } from '../fx-sources/index.js';
import { first, scalar, type SqlClient } from '../sql.js';
import { dim, heading, note, skipped, step, warn } from '../ui.js';

export const RATES_FLAGS = [...CONNECTION_FLAGS, 'source', 'date', 'overwrite', 'reference-currency'] as const;

export const RATES_USAGE =
  'usage: ekwo rates fetch [--source <name>] [--date <YYYY-MM-DD>] [--overwrite] [--reference-currency <code>]';

export interface RatesDeps extends CommandDeps {
  fetchImpl?: typeof globalThis.fetch | undefined;
}

interface Quoted {
  currency_code: string;
  rate: string;
  known: boolean;
}

interface Stored {
  rate: string;
  source: string | null;
}

export async function ratesCommand(args: ParsedArgs, deps: RatesDeps = {}): Promise<number> {
  rejectUnknownFlags(args, RATES_FLAGS);
  const [action, ...extra] = args.positional;
  if (action !== 'fetch' || extra.length > 0) throw new UsageError(RATES_USAGE);

  const names = Object.keys(RATE_SOURCES);
  const sourceName = stringFlag(args, 'source') ?? (names[0] as string);
  const source = RATE_SOURCES[sourceName];
  if (source === undefined) {
    throw new UsageError(`unknown_rate_source: "${sourceName}"; the sources are ${names.join(', ')}. ${RATES_USAGE}`);
  }
  const date = stringFlag(args, 'date');
  if (date !== undefined && !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    throw new UsageError(`bad_date: --date takes YYYY-MM-DD, got "${date}". ${RATES_USAGE}`);
  }
  const named = stringFlag(args, 'reference-currency')?.toUpperCase();
  const overwrite = boolFlag(args, 'overwrite');

  const { db } = await openDatabase(args, { interactive: false, connect: deps.connect });
  try {
    const { reference, toRecord } = await referenceCurrency(db, named);
    const published = await source.fetch(date, deps.fetchImpl ?? globalThis.fetch);

    heading(`Rates of ${published.date}, ${source.publisher}`);
    const summary = {
      source: source.name,
      base: source.base,
      reference_currency: reference,
      date: published.date,
      published: Object.keys(published.rates).length > 0,
    };
    if (!summary.published) {
      skipped(`${source.name} published no rates for ${published.date}: nothing written, and no earlier rate carried forward.`);
      if (toRecord) note(dim(`The instance reference currency is recorded with the first rates written; ${reference} is not recorded yet.`));
      setResult({ ...summary, written: [], overwritten: [], unchanged: [], kept: [], unknown: [] });
      return 0;
    }

    const quotes = await toReference(db, source, published.rates, reference, published.date);
    const result = await db.transaction(async (tx) => {
      // Operating, not installing: the audit trail skips what the
      // installation writes to set itself up, and a rate replaced here has to
      // be kept there. For this transaction only.
      await tx.query(`select set_config('ekwo.installing', '', true)`);
      if (toRecord) await tx.query('update instance set reference_currency = $1 where id = 1', [reference]);
      return record(tx, source, published.date, quotes, overwrite);
    });
    if (toRecord) step(`instance reference currency recorded: ${reference}`);

    step(`${result.written.length} written, ${result.unchanged.length} already there`);
    for (const row of result.overwritten) {
      step(`${row.currency_code} ${row.previous_rate} → ${row.rate} (was ${row.previous_source ?? 'typed by hand'})`);
    }
    if (result.kept.length > 0) {
      warn(
        `${result.kept.length} rate(s) of ${published.date} already recorded differently, kept: ` +
          result.kept.map((row) => `${row.currency_code} ${row.rate} (${source.name} quotes ${row.quoted})`).join(', ') +
          '. --overwrite replaces them; the audit trail keeps the old value.',
      );
    }
    if (result.unknown.length > 0) {
      note(dim(`Not known to this installation, left out: ${result.unknown.join(', ')}.`));
    }
    note(dim(`Units of each currency for one ${reference}. Source terms: ${source.terms}`));
    setResult({ ...summary, ...result });
    return 0;
  } finally {
    await db.close();
  }
}

/**
 * The instance reference currency, named once and then held to.
 *
 * Null until the operator names it with `--reference-currency`, which records
 * it on the instance row with the first rates written — a run that writes
 * nothing records nothing; afterwards the flag may repeat it, never change it.
 */
async function referenceCurrency(
  db: SqlClient,
  named: string | undefined,
): Promise<{ reference: string; toRecord: boolean }> {
  const hasColumn = await scalar<boolean>(
    db,
    `select exists (select 1 from information_schema.columns
                     where table_schema = current_schema() and table_name = 'instance'
                       and column_name = 'reference_currency')`,
  );
  if (hasColumn !== true) {
    throw new UsageError('schema_too_old_for: rates fetch needs instance.reference_currency; run `ekwo migrate` first.');
  }
  const instance = await first<{ reference_currency: string | null }>(
    db,
    'select reference_currency::text as reference_currency from instance where id = 1',
  );
  if (instance === undefined) throw new UsageError('no_instance: this database has no instance row yet; run `ekwo init` first.');

  const recorded = instance.reference_currency;
  if (recorded !== null) {
    if (named !== undefined && named !== recorded) {
      throw new UsageError(
        `instance_reference_currency_differs: the instance-wide rates are against ${recorded}, not ${named}; ` +
          'its rows would be read in the wrong base, so it is not changed here.',
      );
    }
    return { reference: recorded, toRecord: false };
  }
  if (named === undefined) {
    throw new UsageError(
      'instance_reference_currency_unset: name the currency the instance-wide rates are against, once, with ' +
        '--reference-currency <code>.',
    );
  }
  const known = await scalar<boolean>(db, 'select exists (select 1 from currencies where code = $1)', [named]);
  if (known !== true) throw new UsageError(`unknown_currency: ${named} is not a currency of this installation.`);
  return { reference: named, toRecord: true };
}

/**
 * The source's quotes, as units of each currency for one unit of `reference`.
 * The base is quoted at 1 against itself; the reference is left out, its rate
 * against itself being 1 by definition.
 */
async function toReference(
  db: SqlClient,
  source: RateSource,
  rates: Record<string, string>,
  reference: string,
  date: string,
): Promise<Quoted[]> {
  const quotes: Record<string, string> = { ...rates, [source.base]: '1' };
  const pivot = quotes[reference];
  if (pivot === undefined) {
    throw new UsageError(
      `reference_currency_not_quoted: ${source.name} quotes against ${source.base} and publishes no rate of ${reference} ` +
        `for ${date}, so its rates cannot be stated against ${reference}. No rate was written.`,
    );
  }
  return db.query<Quoted>(
    `select q.key as currency_code,
            round(q.value::numeric / $2::numeric, 8)::text as rate,
            exists (select 1 from currencies c where c.code = q.key) as known
       from jsonb_each_text($1::jsonb) q
      where q.key <> $3
      order by q.key`,
    [JSON.stringify(quotes), pivot, reference],
  );
}

async function record(
  tx: SqlClient,
  source: RateSource,
  date: string,
  quotes: Quoted[],
  overwrite: boolean,
): Promise<{
  written: { currency_code: string; rate: string }[];
  overwritten: { currency_code: string; rate: string; previous_rate: string; previous_source: string | null }[];
  unchanged: string[];
  kept: { currency_code: string; rate: string; quoted: string; source: string | null }[];
  unknown: string[];
}> {
  const result = {
    written: [] as { currency_code: string; rate: string }[],
    overwritten: [] as { currency_code: string; rate: string; previous_rate: string; previous_source: string | null }[],
    unchanged: [] as string[],
    kept: [] as { currency_code: string; rate: string; quoted: string; source: string | null }[],
    unknown: [] as string[],
  };
  for (const quote of quotes) {
    const code = quote.currency_code;
    if (!quote.known) {
      result.unknown.push(code);
      continue;
    }
    const stored = await first<Stored>(
      tx,
      `select rate::text as rate, source from currency_rates
        where company_id is null and currency_code = $1 and rate_date = $2`,
      [code, date],
    );
    if (stored === undefined) {
      await tx.query(
        'insert into currency_rates (currency_code, rate_date, rate, source) values ($1, $2, $3::numeric, $4)',
        [code, date, quote.rate, source.name],
      );
      result.written.push({ currency_code: code, rate: quote.rate });
    } else if (stored.rate === quote.rate) {
      result.unchanged.push(code);
    } else if (overwrite) {
      await tx.query(
        `update currency_rates set rate = $3::numeric, source = $4
          where company_id is null and currency_code = $1 and rate_date = $2`,
        [code, date, quote.rate, source.name],
      );
      result.overwritten.push({ currency_code: code, rate: quote.rate, previous_rate: stored.rate, previous_source: stored.source });
    } else {
      result.kept.push({ currency_code: code, rate: stored.rate, quoted: quote.rate, source: stored.source });
    }
  }
  return result;
}
