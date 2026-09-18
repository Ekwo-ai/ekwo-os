#!/usr/bin/env node
/**
 * The end-to-end test, against a real Supabase project.
 *
 * `tests/e2e/` proves the whole story against PGlite: real Postgres, real
 * constraints, no network. Four things it cannot reach, and they are the four
 * that break a release:
 *
 *   - the published `ekwo` binary, run the way a stranger runs it, against a
 *     connection string through the Supabase pooler;
 *   - PostgREST, which is what every client actually talks to — a function
 *     that exists but was never granted to `authenticated` passes every test
 *     in this repository and answers "permission denied" to the first user;
 *   - GoTrue, and therefore row level security judged on a real JWT rather
 *     than on a session variable a test set;
 *   - the extensions, roles and defaults a hosted project has and a bare
 *     Postgres does not.
 *
 * So this script is not run by the CI and never will be: it costs money and it
 * needs a project nobody minds losing. It is run by hand, once, before a
 * release is tagged.
 *
 * ---------------------------------------------------------------------------
 * What it needs, all from the environment and nothing from a file:
 *
 *   EKWO_DB_URL                 the pooler connection string of the project
 *   SUPABASE_URL                https://<ref>.supabase.co
 *   SUPABASE_ANON_KEY           the anon key — what a real client sends
 *   SUPABASE_SERVICE_ROLE_KEY   used once, by `ekwo init`, to create the admin
 *   EKWO_E2E_COUNTRY            the pack to install. No default: a default
 *                               country is a chart of accounts nobody chose
 *   EKWO_E2E_CHART              optional, and required in practice for a
 *                               country whose pack carries several charts:
 *                               `ekwo init` refuses to pick one when there is
 *                               nobody to ask, which is the right answer and
 *                               the first thing this script found
 *   EKWO_E2E_LANGUAGE           optional, and required for the same reason
 *                               when the pack declares more than one language
 *                               for its labels
 *   EKWO_E2E_ADMIN_EMAIL        the administrator this run creates and signs
 *   EKWO_E2E_ADMIN_PASSWORD     in as, to exercise PostgREST as a person
 *   EKWO_E2E_PREVIOUS           optional: the release to install first, so
 *                               that the run upgrades an installation instead
 *                               of creating one. Left out, those steps are
 *                               reported as skipped rather than passed. Two
 *                               forms: a path to an already-built `bin.js` of
 *                               an older checkout, which is what to use while
 *                               the packages are not on npm —
 *
 *                                 git worktree add /tmp/prev v0.2.0
 *                                 (cd /tmp/prev && npm ci && npm run build)
 *                                 EKWO_E2E_PREVIOUS=/tmp/prev/packages/cli/dist/bin.js
 *
 *                               — or an npm spec such as `ekwo-os@0.2.0` once
 *                               they are. They are not today — `npm view ekwo`
 *                               answers 404 — so the path is the only form
 *                               that works, and will be until the packages are
 *                               published
 *
 *   EKWO_E2E_LOAD_DOCUMENTS     optional: a number of documents. Set, the run
 *                               ends by multiplying the books it has just
 *                               posted to that volume and timing the six hot
 *                               paths of `scripts/load/hot-paths.mjs` — as the
 *                               owner over SQL and as the signed-in member
 *                               over PostgREST. See "The load steps" below
 *
 *   npm run build && npm run e2e:supabase
 *
 * `--reset` empties the project first — see below. It is the only flag.
 *
 * It writes no secret anywhere and prints none: the connection string, the
 * keys and the password never reach the output, not even masked, because a
 * mask in a terminal recording is still a length and a prefix.
 *
 * ---------------------------------------------------------------------------
 * It refuses a project that is not empty.
 *
 * A throwaway project is a project with nothing in it. This one installs an
 * instance, an administrator and a company, books into them and closes a
 * financial year; run against books that matter it would be a disaster with a
 * pass/fail table at the end. So the first thing it does is ask whether
 * `public.instance` holds a row, and stop if it does. There is no flag to get
 * past that. Create another project.
 *
 * It also deletes nothing on its own — not on success and not on failure. What
 * is left behind is the evidence, and a second run against it is refused.
 *
 * ---------------------------------------------------------------------------
 * `--reset` is how a failed run is replayed.
 *
 * A run that fails halfway leaves an instance row, so the guard refuses the
 * next one — which is right, and useless while a script is being written. The
 * flag drops the module schemas the installation declares, then `public`, then
 * `supabase_migrations`, and recreates `public` with the grants a Supabase
 * project has. It is exactly as destructive as it sounds: everything in the
 * database is gone, and the only thing standing between it and a set of books
 * is the person typing it.
 *
 * **It is for a throwaway project and nothing else.** It is deliberately not
 * an `ekwo` command: an installer that can empty a database is an installer
 * somebody runs against the wrong connection string one day. It prints what it
 * dropped, and it leaves Supabase's own schemas — `auth` included, so the
 * administrator this script created is still there and is found again rather
 * than duplicated.
 *
 * ---------------------------------------------------------------------------
 * The load steps.
 *
 * `tests/load/` checks the *shape* of the plans on PGlite and breaks the build
 * on it. It reports times too, and they are times on Postgres compiled to
 * WebAssembly: good for seeing a trend, no good for a sentence in the README.
 * The times that mean something are taken here, against a real Postgres,
 * through a real pooler and a real PostgREST — from the same six definitions
 * and the same generator, so the two runs measure one thing.
 *
 * With `EKWO_E2E_LOAD_DOCUMENTS=10000` (or `100000`) the run ends with:
 *
 *   - the sale and the purchase posted above — by the engine, through
 *     PostgREST — copied to that many documents over five financial years,
 *     five hundred contacts and a month of bank statement, then `analyze`.
 *     `scripts/load/books.mjs` says what a copy is and why it is not a fake;
 *   - each path three times over SQL as the owner of the database, median
 *     kept;
 *   - each path three times over PostgREST as the administrator this run
 *     signed in — row level security, JSON and HTTP included, which is what a
 *     person waits for.
 *
 * One thing to know before reading the second column: a hosted project caps a
 * PostgREST response at 1 000 rows unless its API settings say otherwise, so
 * the entries file of a year comes back truncated and its time is the time of
 * the first thousand lines. Raise the cap on the throwaway project, or read
 * that row as a lower bound.
 *
 * A path over its budget is **reported, not failed**: the row says `OVER`, and
 * the run goes on. A budget is a line somebody drew before measuring, and the
 * first real measure is what it is to be redrawn against.
 *
 * These steps have **never been run**: like the rest of this script they need
 * a throwaway project, and none has been available since they were written.
 * What they call — the generator, the six definitions — is what the CI runs
 * on PGlite on every push; what is untested is the wiring in this file.
 */

import { spawn } from 'node:child_process';
import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const repoRoot = fileURLToPath(new URL('..', import.meta.url));
const reset = process.argv.slice(2).includes('--reset');
const cliBin = `${repoRoot}packages/cli/dist/bin.js`;

const SALE_BASE = 1000;
const PURCHASE_BASE = 400;
const SALE_DATE = '2026-03-15';
const PURCHASE_DATE = '2026-04-20';
const FISCAL_YEAR = 2026;

/**
 * Half up on the absolute value, at the currency's decimals.
 *
 * The same rule as `packages/*\/src/rounding.ts`, written out again rather than
 * imported: this script has to run from an unpacked tarball where the
 * TypeScript sources are not there to import. `tests/rounding.test.ts` is what
 * keeps the copies honest; this one is checked by the run itself, since a
 * disagreement with the ledger shows up as a failed row in the table.
 */
function round(value, decimals) {
  const factor = 10 ** decimals;
  const scaled = Math.abs(value) * factor;
  const rounded = Math.round(scaled + Number.EPSILON * scaled);
  return (value < 0 ? -rounded : rounded) / factor + 0;
}

const results = [];
let failed = 0;

async function step(name, fn) {
  if (failed > 0) {
    results.push({ name, outcome: 'skipped', detail: 'an earlier step failed' });
    return undefined;
  }
  // Each step is timed, because over a pooler and a hosted PostgREST what
  // matters about a release is not the total but which step holds it: a
  // migration set that doubled, a first query waiting on a cold project, a
  // close that got slower as the ledger grew.
  const started = Date.now();
  try {
    const detail = await fn();
    results.push({ name, outcome: 'pass', detail: detail ?? '', ms: Date.now() - started });
    return detail;
  } catch (error) {
    failed += 1;
    results.push({ name, outcome: 'FAIL', detail: error.message, ms: Date.now() - started });
    return undefined;
  }
}

function skip(name, why) {
  results.push({ name, outcome: 'skipped', detail: why });
}

function required(name) {
  const value = process.env[name];
  if (value === undefined || value === '') {
    throw new Error(`${name} is not set. See the header of this file for the list.`);
  }
  return value;
}

/** Runs the published binary and fails on a non-zero exit. */
function run(args, env) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [cliBin, ...args], {
      env: { ...process.env, ...env, NO_COLOR: '1' },
      stdio: ['ignore', 'pipe', 'pipe'],
    });
    let out = '';
    child.stdout.on('data', (chunk) => {
      out += chunk;
    });
    child.stderr.on('data', (chunk) => {
      out += chunk;
    });
    child.on('error', reject);
    child.on('close', (code) => {
      if (code === 0) resolve(out);
      else reject(new Error(`ekwo ${args[0]} exited ${code}: ${out.trim().split('\n').slice(-3).join(' / ')}`));
    });
  });
}

/** PostgREST, as the signed-in person and never as the service role. */
function api(supabaseUrl, anonKey, token) {
  const headers = {
    apikey: anonKey,
    Authorization: `Bearer ${token}`,
    'Content-Type': 'application/json',
  };
  const call = async (method, path, body, extra = {}) => {
    const answer = await fetch(`${supabaseUrl}/rest/v1${path}`, {
      method,
      headers: { ...headers, ...extra },
      ...(body === undefined ? {} : { body: JSON.stringify(body) }),
    });
    const text = await answer.text();
    if (!answer.ok) throw new Error(`${method} ${path} → ${answer.status} ${text.slice(0, 300)}`);
    return text === '' ? null : JSON.parse(text);
  };
  return {
    select: (path) => call('GET', path),
    insert: async (table, row) => {
      const written = await call('POST', `/${table}`, row, { Prefer: 'return=representation' });
      return written[0];
    },
    rpc: (fn, args) => call('POST', `/rpc/${fn}`, args),
  };
}

async function main() {
  const dbUrl = required('EKWO_DB_URL');
  const supabaseUrl = required('SUPABASE_URL');
  const anonKey = required('SUPABASE_ANON_KEY');
  const serviceRoleKey = required('SUPABASE_SERVICE_ROLE_KEY');
  const country = required('EKWO_E2E_COUNTRY').toUpperCase();
  const adminEmail = required('EKWO_E2E_ADMIN_EMAIL');
  const adminPassword = required('EKWO_E2E_ADMIN_PASSWORD');
  const previous = process.env['EKWO_E2E_PREVIOUS'];
  const chart = process.env['EKWO_E2E_CHART'];
  const chartFlag = chart === undefined ? [] : ['--chart', chart];
  const language = process.env['EKWO_E2E_LANGUAGE'];
  const languageFlag = language === undefined ? [] : ['--language', language];

  if (!existsSync(cliBin)) {
    throw new Error(`${cliBin} is not built. Run \`npm run build\` first.`);
  }

  const { connect } = await import(`${repoRoot}packages/cli/dist/index.js`);

  // ---- The guard, before anything is written ------------------------------
  const db = await connect(dbUrl);
  try {
    const installed = await db.query(
      `select count(*)::int as n from information_schema.tables
        where table_schema = 'public' and table_name = 'instance'`,
    );
    const claimed =
      installed[0]?.n > 0 && (await db.query('select count(*)::int as n from instance'))[0]?.n > 0;

    if (claimed && !reset) {
      throw new Error(
        'this database already holds an instance row. This script installs, books and ' +
          'closes a financial year, so it runs only against an empty, throwaway project. ' +
          'Pass --reset to empty this one first — which drops everything in it — or point ' +
          'EKWO_DB_URL at another project.',
      );
    }

    if (reset) {
      const startedReset = Date.now();
      const dropped = [];
      if (installed[0]?.n > 0) {
        const modules = await db.query(
          `select schema_name from information_schema.schemata s
            where exists (select 1 from modules m where m.schema_name = s.schema_name)`,
        ).catch(() => []);
        for (const row of modules) {
          await db.exec(`drop schema if exists ${row.schema_name} cascade;`);
          dropped.push(row.schema_name);
        }
      }
      // Dropping `public` takes Supabase's own default privileges with it —
      // they live in `pg_default_acl`, keyed by the schema — and until
      // `20260914151207` nothing in `supabase/migrations` put them back. Leave
      // them out and the reinstall succeeded, `ekwo doctor` was happy, and the
      // first PostgREST read answered "permission denied for table companies",
      // which is what the run of 14 September 2026 found.
      //
      // The schema grants its own rights now, so the reset no longer has to
      // restore them for the install to work. It still does, and deliberately:
      // a real project *has* them, and a reset that left them out would be a
      // reset that quietly stopped exercising the thing the migration does
      // about them. `20260914151207` revokes `anon` and `authenticated` from
      // the three lines below, on its way past, and the run should find the
      // publishable key refused on every table afterwards — which is the step
      // named "the anonymous role reaches no table" further down.
      await db.exec(`
        drop schema if exists public cascade;
        drop schema if exists supabase_migrations cascade;
        create schema public;
        alter schema public owner to postgres;
        grant usage on schema public to postgres, anon, authenticated, service_role;
        grant create on schema public to postgres, service_role;
        alter default privileges in schema public
          grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema public
          grant all on sequences to postgres, anon, authenticated, service_role;
        alter default privileges in schema public
          grant all on functions to postgres, anon, authenticated, service_role;
      `);
      dropped.push('public', 'supabase_migrations');
      results.push({
        name: '--reset emptied the project',
        outcome: 'pass',
        detail: `dropped ${dropped.join(', ')}`,
        ms: Date.now() - startedReset,
      });
    }
  } finally {
    await db.close();
  }

  // ---- 1. Install ---------------------------------------------------------
  /** The pack version the company held before this release touched it. */
  let heldBefore;

  const installEnv = {
    EKWO_DB_URL: dbUrl,
    SUPABASE_URL: supabaseUrl,
    SUPABASE_SERVICE_ROLE_KEY: serviceRoleKey,
  };

  if (previous === undefined) {
    skip('install at the previous release', 'EKWO_E2E_PREVIOUS names none');
    skip('ekwo migrate from the previous release', 'EKWO_E2E_PREVIOUS names none');
    skip('the pack the previous release held', 'EKWO_E2E_PREVIOUS names none');
  } else {
    const built = previous.includes('/') && existsSync(previous);
    await step(`install at ${built ? 'the previous checkout' : previous}`, async () => {
      const [command, head] = built
        ? [process.execPath, [previous]]
        : ['npx', ['--yes', previous]];
      const out = await new Promise((resolve, reject) => {
        const child = spawn(
          command,
          [...head, 'init', '--country', country, ...chartFlag, ...languageFlag,
            '--org', 'End To End', '--company', 'End To End',
            '--fiscal-year', String(FISCAL_YEAR), '--admin-email', adminEmail,
            '--admin-password', adminPassword, '--yes'],
          { env: { ...process.env, ...installEnv, NO_COLOR: '1' }, stdio: ['ignore', 'pipe', 'pipe'] },
        );
        let text = '';
        child.stdout.on('data', (chunk) => { text += chunk; });
        child.stderr.on('data', (chunk) => { text += chunk; });
        child.on('error', reject);
        child.on('close', (code) =>
          code === 0 ? resolve(text) : reject(new Error(`exited ${code}: ${text.trim().split('\n').slice(-3).join(' / ')}`)));
      });
      const applied = /(\d+) applied/.exec(out);
      return `installed${applied === null ? '' : `, ${applied[1]} migration(s)`}`;
    });

    // What the company copied before anything of this release ran. It is the
    // figure the upgrade has to move, and the only moment it can be read.
    await step('the pack the previous release held', async () => {
      const held = await connect(dbUrl);
      try {
        const rows = await held.query(
          'select version from company_packs order by installed_at limit 1',
        );
        heldBefore = rows[0]?.version;
        if (heldBefore === undefined) throw new Error('the installation copied no pack');
        return `company_packs says ${heldBefore}`;
      } finally {
        await held.close();
      }
    });

    await step('ekwo migrate from the previous release', async () => {
      const out = await run(['migrate', '--yes'], installEnv);
      const applied = /(\d+) applied, (\d+) pending/.exec(out);
      return `schema brought to this release${applied === null ? '' : `, ${applied[2]} migration(s) were pending`}`;
    });

    // Before the installer runs again, because `ekwo init` calls
    // `install_country_template` a second time and that moves the version on
    // its own. Run after it, this step would pass without ever being the
    // thing that upgraded anything.
    await packUpgradeStep();
  }

  await step('ekwo init', async () => {
    const out = await run(
      ['init', '--country', country, ...chartFlag, ...languageFlag, '--org', 'End To End',
        '--company', 'End To End', '--fiscal-year', String(FISCAL_YEAR),
        '--admin-email', adminEmail, '--admin-password', adminPassword, '--yes'],
      installEnv,
    );
    const applied = /(\d+) applied/.exec(out);
    return `installed${applied === null ? '' : `, ${applied[1]} migration(s) applied`}`;
  });

  await step('ekwo init is idempotent', async () => {
    await run(['init', '--country', country, ...chartFlag, ...languageFlag, '--org', 'End To End',
      '--company', 'End To End', '--fiscal-year', String(FISCAL_YEAR),
      '--admin-email', adminEmail, '--admin-password', adminPassword, '--yes'], installEnv);
    return 'a second run created nothing';
  });

  await step('ekwo status', async () => {
    const out = await run(['status'], installEnv);
    if (/pending/i.test(out) && !/0 pending/i.test(out)) throw new Error('migrations still pending');
    return 'no pending migration';
  });

  if (previous === undefined) await packUpgradeStep();

  await step('ekwo doctor', async () => {
    // `doctor` prints "No problems." or "N problem(s)", and warnings beside
    // them. A warning is not a failure: an installation with no bank account
    // yet is the ordinary state of one this script just made.
    const out = await run(['doctor'], installEnv);
    const problems = /([1-9]\d*) problem/.exec(out);
    if (problems !== null) throw new Error(out.trim().slice(-400));
    const warnings = /(\d+) warning/.exec(out);
    return `no problem${warnings === null || warnings[1] === '0' ? '' : `, ${warnings[1]} warning(s)`}`;
  });


  /**
   * `ekwo pack upgrade`, judged on what `company_packs` says afterwards.
   *
   * The command prints "already the version this installation holds" when the
   * difference is empty, which is also what it prints when it has nothing to
   * do — so the claim worth checking is the state: a company left on an older
   * pack than the installation holds is one whose next invoice is booked by
   * last year's rules, and `ekwo pack status` would report it as behind for
   * ever.
   */
  async function packUpgradeStep() {
    await step('ekwo pack upgrade', async () => {
      await run(['pack', 'upgrade', 'End To End', '--apply', '--yes'], installEnv);
      const after = await connect(dbUrl);
      try {
        const rows = await after.query(
          `select cp.version as held, p.version as available
             from company_packs cp join country_packs p on p.country = cp.country`,
        );
        const row = rows[0];
        if (row === undefined) throw new Error('the installation copied no pack');
        if (row.held !== row.available) {
          throw new Error(`the company holds ${row.held} and the installation ${row.available}`);
        }
        return heldBefore === undefined || heldBefore === row.held
          ? `at ${row.held}, the version this installation holds`
          : `${heldBefore} to ${row.held}`;
      } finally {
        await after.close();
      }
    });
  }

  // ---- 2. As a real person, through GoTrue and PostgREST ------------------
  // The token is held here and never returned from the step: what a step
  // returns is what the table prints, and an access token is a secret with an
  // hour to live.
  let token;
  const signedIn = await step('sign in through GoTrue', async () => {
    const answer = await fetch(`${supabaseUrl}/auth/v1/token?grant_type=password`, {
      method: 'POST',
      headers: { apikey: anonKey, 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: adminEmail, password: adminPassword }),
    });
    if (!answer.ok) throw new Error(`GoTrue answered ${answer.status}`);
    const body = await answer.json();
    if (typeof body.access_token !== 'string') throw new Error('no access token');
    token = body.access_token;
    return 'a real JWT, as a real client gets one';
  });
  if (signedIn === undefined) return report();

  const rest = api(supabaseUrl, anonKey, token);

  // The publishable key on its own, with no Authorization header: what a
  // visitor to the website holds. Before `20260914151207` this answered `[]`
  // on every table, because the project's default privileges gave `anon` the
  // read and row level security emptied it. The surface should be closed and
  // not merely empty, so it answers 401/403 now — and PostgREST is the only
  // place that can be checked, which is why it is checked here.
  await step('the anonymous role reaches no table', async () => {
    const refused = [];
    for (const table of ['companies', 'entries', 'entry_lines', 'documents', 'audit_log']) {
      const answer = await fetch(`${supabaseUrl}/rest/v1/${table}?select=id&limit=1`, {
        headers: { apikey: anonKey },
      });
      const body = await answer.text();
      if (answer.ok) {
        throw new Error(
          `GET /${table} as anon answered ${answer.status} ${body.slice(0, 200)} — it should be refused`,
        );
      }
      refused.push(`${table} ${answer.status}`);
    }
    return refused.join(', ');
  });

  let installation;
  const setup = await step('read the installation over PostgREST', async () => {
    const companies = await rest.select('/companies?select=id,currency_code,fiscal_country');
    const company = companies[0];
    if (company === undefined) throw new Error('the signed-in user sees no company');
    const years = await rest.select(`/fiscal_years?company_id=eq.${company.id}&select=id,start_date,end_date`);
    const year = years[0];
    if (year === undefined) throw new Error('no financial year');
    const currencies = await rest.select(`/currencies?code=eq.${company.currency_code}&select=decimal_places`);
    const defaults = await rest.select(
      `/country_defaults?country=eq.${company.fiscal_country}` +
        '&select=bank_account_code,receivable_code,retained_earnings_code,sales_account_code,purchase_account_code',
    );
    installation = {
      company,
      year,
      decimals: Number(currencies[0].decimal_places),
      defaults: defaults[0],
    };
    return `${company.fiscal_country} in ${company.currency_code}, ${year.start_date} to ${year.end_date}`;
  });
  if (setup === undefined) return report();
  const { company, year, decimals, defaults } = installation;

  /** The plain standard-rate tax of the pack, on one side. */
  async function simpleTax(scope) {
    // Two foreign keys join `taxes` to `tax_postings` — one on the id and one
    // on the pair (id, company_id) — so PostgREST refuses to guess which
    // embedding is meant, and rightly. Two reads rather than a constraint
    // name in this file: a name is a thing that changes.
    const taxes = await rest.select(
      `/taxes?company_id=eq.${company.id}&applies_to=in.(${scope},both)&treatment=eq.domestic` +
        '&amount_type=eq.percent&amount=gt.0&order=amount.desc,code.asc' +
        '&select=id,code,amount,cash_basis',
    );
    if (taxes.length === 0) {
      throw new Error(`${company.fiscal_country} offers no domestic ${scope} tax at all`);
    }
    const ids = taxes.map((t) => t.id).join(',');
    const all = await rest.select(
      `/tax_postings?tax_id=in.(${ids})&document_kind=eq.invoice` +
        '&select=tax_id,posting_type,declaration_box,declaration_boxes,box_factor_percent,factor_percent',
    );
    for (const tax of taxes) {
      if (tax.cash_basis === true) continue;
      const postings = all.filter((p) => p.tax_id === tax.id);
      const taxPostings = postings.filter((p) => p.posting_type === 'tax');
      const onBase = postings.filter((p) => p.posting_type === 'tax_on_base');
      if (taxPostings.length === 1 && onBase.length === 0) return { ...tax, postings };
    }
    throw new Error(`${company.fiscal_country} offers no plain ${scope} tax at the standard rate`);
  }

  await step('open the financial year', async () => {
    const entry = await rest.rpc('opening_balance', {
      p_company_id: company.id,
      p_fiscal_year_id: year.id,
      p_lines: [
        { account_code: defaults.bank_account_code, debit: '12000.00', credit: '0' },
        { account_code: defaults.receivable_code, debit: '3630.00', credit: '0' },
        { account_code: defaults.retained_earnings_code, debit: '0', credit: '15630.00' },
      ],
    });
    if (typeof entry !== 'string') throw new Error('opening_balance returned no entry');
    return '15630.00 carried in';
  });

  const ledger = {};

  async function invoice(docType, scope, base, date, accountCode) {
    const tax = await simpleTax(scope);
    const contact = await rest.insert('contacts', {
      company_id: company.id,
      name: docType === 'sale_invoice' ? 'A customer' : 'A supplier',
      contact_type: docType === 'sale_invoice' ? 'customer' : 'supplier',
      country: company.fiscal_country,
    });
    const accounts = await rest.select(
      `/accounts?company_id=eq.${company.id}&code=eq.${accountCode}&select=id`,
    );
    const document = await rest.insert('documents', {
      company_id: company.id,
      doc_type: docType,
      contact_id: contact.id,
      document_date: date,
    });
    await rest.insert('document_lines', {
      document_id: document.id,
      company_id: company.id,
      sequence: 10,
      name: 'Line',
      quantity: 1,
      unit_price: base,
      tax_id: tax.id,
      account_id: accounts[0].id,
    });
    await rest.rpc('post_document', { p_document_id: document.id });

    const vat = round((base * Number(tax.amount)) / 100, decimals);
    for (const posting of tax.postings) {
      if (posting.declaration_box === null) continue;
      const source = posting.posting_type === 'base' ? base : vat;
      const kind = posting.posting_type === 'base' ? 'base' : 'tax';
      // Every box the posting prints in, which is what vat_return() sums the
      // line into. Almost always the one box `declaration_box` names.
      for (const box of posting.declaration_boxes ?? [posting.declaration_box]) {
        const key = `${box}|${kind}`;
        ledger[key] =
          (ledger[key] ?? 0) + round((source * Number(posting.box_factor_percent)) / 100, decimals);
      }
    }
    return { vat, documentId: document.id };
  }

  const sale = await step('post a sale invoice through PostgREST', async () => {
    const booked = await invoice('sale_invoice', 'sale', SALE_BASE, SALE_DATE, defaults.sales_account_code);
    return `${SALE_BASE.toFixed(decimals)} + ${booked.vat.toFixed(decimals)} VAT`;
  });
  await step('post a purchase invoice through PostgREST', async () => {
    const booked = await invoice(
      'purchase_invoice', 'purchase', PURCHASE_BASE, PURCHASE_DATE, defaults.purchase_account_code,
    );
    return `${PURCHASE_BASE.toFixed(decimals)} + ${booked.vat.toFixed(decimals)} VAT`;
  });
  if (sale === undefined) return report();

  await step('the VAT return is the one the pack asks for', async () => {
    const boxes = await rest.rpc('vat_return', {
      p_company_id: company.id,
      p_from: year.start_date,
      p_to: year.end_date,
    });
    const produced = boxes
      .filter((b) => b.kind !== 'total')
      .map((b) => `${b.box}|${b.kind}=${Number(b.amount).toFixed(decimals)}`)
      .sort();
    const expected = Object.entries(ledger)
      .filter(([, amount]) => amount !== 0)
      .map(([key, amount]) => `${key}=${amount.toFixed(decimals)}`)
      .sort();
    if (produced.join(' ') !== expected.join(' ')) {
      throw new Error(`ledger boxes: ${produced.join(' ')} — expected ${expected.join(' ')}`);
    }
    const totals = boxes.filter((b) => b.kind === 'total');
    if (totals.length === 0) throw new Error('the form derived no total');
    return `${produced.join(' ')} | ${totals.map((t) => `${t.box}=${Number(t.amount).toFixed(decimals)}`).join(' ')}`;
  });

  const schemes = await step('both financial statements come back', async () => {
    const available = await rest.rpc('available_statements', { p_company_id: company.id });
    const defaultsOnly = available.filter((s) => s.is_default);
    const wanted = defaultsOnly.filter((s) => s.kind === 'balance_sheet' || s.kind === 'income_statement');
    if (wanted.length < 2) throw new Error(`only ${wanted.length} default scheme(s)`);
    for (const scheme of wanted) {
      const lines = await rest.rpc('financial_statement', {
        p_company_id: company.id,
        p_statement_code: scheme.code,
        p_from: year.start_date,
        p_to: year.end_date,
      });
      if (lines.length === 0) throw new Error(`${scheme.code} printed nothing`);
      const orphans = await rest.rpc('unmapped_accounts', {
        p_company_id: company.id,
        p_statement_code: scheme.code,
        p_from: year.start_date,
        p_to: year.end_date,
      });
      if (orphans.length > 0) {
        throw new Error(`${scheme.code} leaves ${orphans.map((o) => o.account_code).join(', ')} off the scheme`);
      }
    }
    return wanted.map((s) => s.code).join(', ');
  });
  if (schemes === undefined) return report();

  const expectedResult = SALE_BASE - PURCHASE_BASE;

  await step('close the financial year', async () => {
    const closed = await rest.rpc('close_fiscal_year', { p_fiscal_year_id: year.id });
    if (closed.result !== expectedResult.toFixed(decimals)) {
      throw new Error(`result ${closed.result}, expected ${expectedResult.toFixed(decimals)}`);
    }
    return `${closed.result} ${closed.result_kind}, style ${closed.closing_style}`;
  });

  await step('re-open it', async () => {
    const undone = await rest.rpc('reopen_fiscal_year', { p_fiscal_year_id: year.id });
    if (!Array.isArray(undone.reversal_entry_ids) || undone.reversal_entry_ids.length === 0) {
      throw new Error('nothing was reversed');
    }
    return `${undone.reversal_entry_ids.length} entry(ies) reversed`;
  });

  await step('close it again, on the same result', async () => {
    const closed = await rest.rpc('close_fiscal_year', { p_fiscal_year_id: year.id });
    if (closed.result !== expectedResult.toFixed(decimals)) {
      throw new Error(`result ${closed.result} the second time`);
    }
    return closed.result;
  });

  await step('the audit trail recorded the acts', async () => {
    const written = await rest.select(
      `/audit_log?company_id=eq.${company.id}&select=action&order=id.asc`,
    );
    const actions = new Set(written.map((row) => row.action));
    for (const wanted of ['document_posted', 'fiscal_year_closed', 'fiscal_year_reopened']) {
      if (!actions.has(wanted)) throw new Error(`no ${wanted} in the trail`);
    }
    return `${written.length} rows`;
  });

  // ---- The load steps -------------------------------------------------------
  const volume = process.env['EKWO_E2E_LOAD_DOCUMENTS'];
  if (volume === undefined || volume === '') {
    skip('the six hot paths at volume', 'EKWO_E2E_LOAD_DOCUMENTS names no volume');
  } else {
    await loadSteps({ connect, dbUrl, rest, company, year, documents: Number(volume) });
  }

  report();
}

/** Median of three, in milliseconds. The first run pays for a cold cache. */
async function medianOfThree(fn) {
  const times = [];
  let answer;
  for (let run = 0; run < 3; run += 1) {
    const started = performance.now();
    answer = await fn();
    times.push(performance.now() - started);
  }
  times.sort((a, b) => a - b);
  return { ms: Math.round(times[1]), answer };
}

async function loadSteps({ connect, dbUrl, rest, company, year, documents }) {
  const { multiplyBooks, bankStatementMonth, checkCoherence } = await import('./load/books.mjs');
  const { hotPaths } = await import('./load/hot-paths.mjs');
  if (!Number.isInteger(documents) || documents < 1) {
    throw new Error('EKWO_E2E_LOAD_DOCUMENTS is a number of documents');
  }

  const db = await connect(dbUrl);
  try {
    let scope;
    const loaded = await step(`multiply the books to ${documents} documents`, async () => {
      await multiplyBooks(db, { companyId: company.id, documents, years: 5, contacts: 500, seed: 41 });
      const statement = await bankStatementMonth(db, {
        companyId: company.id,
        lines: Math.max(10, Math.round(documents / 5 / 12)),
        seed: 41,
      });
      const wrong = await checkCoherence(db, company.id);
      if (wrong.length > 0) throw new Error(wrong.join('; '));
      // Without statistics every time below is the time of a guessed plan.
      await db.exec('analyze;');

      const busiest = await db.query(
        `select l.account_id from entry_lines l join accounts a on a.id = l.account_id
          where l.company_id = $1 group by l.account_id, a.code
          order by count(*) desc, a.code limit 1`,
        [company.id],
      );
      // A declaration period inside the year. `vat_return()` refuses a whole
      // period of the wrong cadence, so the first of these it accepts is kept.
      const periods = await db.query(
        `select $1::date::text as start,
                ($1::date + interval '3 months' - interval '1 day')::date::text as quarter,
                ($1::date + interval '1 month' - interval '1 day')::date::text as month`,
        [year.start_date],
      );
      let periodTo;
      for (const candidate of [periods[0].quarter, periods[0].month, year.end_date]) {
        try {
          await db.query(`select count(*) from vat_return($1, $2::date, $3::date)`, [
            company.id, year.start_date, candidate,
          ]);
          periodTo = candidate;
          break;
        } catch (error) {
          if (!String(error.message).includes('wrong_declaration_period')) throw error;
        }
      }
      scope = {
        companyId: company.id,
        yearFrom: year.start_date,
        yearTo: year.end_date,
        periodFrom: year.start_date,
        periodTo,
        accountId: busiest[0].account_id,
        statementId: statement.statementId,
      };
      const lines = await db.query(`select count(*)::int as n from entry_lines where company_id = $1`, [
        company.id,
      ]);
      return `${lines[0].n} ledger lines, declaration period ${year.start_date} to ${periodTo}`;
    });
    if (loaded === undefined) return;

    const verdict = (ms, budget) => `${ms} ms of ${budget}${ms > budget ? ' — OVER' : ''}`;

    for (const path of hotPaths(scope)) {
      await step(`${path.key}, as the owner over SQL`, async () => {
        const { ms, answer } = await medianOfThree(() => db.query(path.sql, path.params));
        return `${verdict(ms, path.budgetMs)}, ${answer[0].rows} rows`;
      });
    }

    for (const path of hotPaths(scope)) {
      await step(`${path.key}, as a member over PostgREST`, async () => {
        let call;
        if (path.rpc.perTransactionOf === undefined) {
          call = async () => (await rest.rpc(path.rpc.fn, path.rpc.args)).length;
        } else {
          const lines = await rest.select(
            `/bank_transactions?statement_id=eq.${path.rpc.perTransactionOf}&select=id&order=sequence.asc`,
          );
          call = async () => {
            let suggestions = 0;
            for (const line of lines) {
              suggestions += (await rest.rpc(path.rpc.fn, { p_transaction_id: line.id })).length;
            }
            return suggestions;
          };
        }
        const { ms, answer } = await medianOfThree(call);
        return `${verdict(ms, path.budgetMs)}, ${answer} rows`;
      });
    }
  } finally {
    await db.close();
  }
}

function report() {
  const width = Math.max(...results.map((r) => r.name.length));
  process.stdout.write('\n');
  let total = 0;
  for (const row of results) {
    const mark = row.outcome === 'pass' ? 'pass   ' : row.outcome === 'FAIL' ? 'FAIL   ' : 'skipped';
    total += row.ms ?? 0;
    const time = row.ms === undefined ? '      ' : `${(row.ms / 1000).toFixed(1)}s`.padStart(6);
    process.stdout.write(`${mark} ${time}  ${row.name.padEnd(width)}  ${row.detail}\n`);
  }
  const passed = results.filter((r) => r.outcome === 'pass').length;
  const skipped = results.filter((r) => r.outcome === 'skipped').length;
  process.stdout.write(
    `\n${passed} passed, ${failed} failed, ${skipped} skipped, ${(total / 1000).toFixed(1)}s\n`,
  );
  process.exitCode = failed > 0 ? 1 : 0;
}

main().catch((error) => {
  process.stderr.write(`${error.message}\n`);
  process.exitCode = 1;
});
