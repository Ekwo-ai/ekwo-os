#!/usr/bin/env node
/**
 * The walkthrough of docs/start-with-claude.md, run for real.
 *
 * The guide tells a person to install Ekwo OS into an empty Supabase project,
 * to connect the published MCP server to Claude, and then to ask for things in
 * words. This script does exactly that, with a script standing where Claude
 * stands: it starts `npx -y @ekwo-ai/mcp` over stdio with the configuration
 * block of the guide — the four variables and nothing else — and calls the
 * tools Claude would call for the sentences the guide suggests. Two companies
 * in two countries — the second created with `create_company`, then chosen
 * in the terminal with `ekwo login` and `ekwo use` — the books of each taken
 * over from a trial balance an earlier ledger exported.
 *
 *   node docs/demo/start-with-claude/walkthrough.mjs            # init, then the rest
 *   node docs/demo/start-with-claude/walkthrough.mjs --no-init  # the project is installed already
 *   node docs/demo/start-with-claude/walkthrough.mjs --no-company
 *
 * `--no-company` takes the other road of the guide: `ekwo init --no-company`,
 * then `ekwo company new` for each company, `ekwo company list`, and the rest
 * as above — the assistant finds both companies already there.
 *
 * Needs, from the environment and nothing from a file:
 *
 *   EKWO_DB_URL                 the pooler connection string (init only)
 *   SUPABASE_SERVICE_ROLE_KEY   used once by init to create the administrator,
 *                               and never handed to the MCP server: the secret
 *                               key (sb_secret_…) or the legacy service_role
 *   SUPABASE_URL                https://<ref>.supabase.co
 *   SUPABASE_ANON_KEY           the publishable key (sb_publishable_…) or the
 *                               legacy anon key
 *   EKWO_EMAIL / EKWO_PASSWORD  the administrator init creates, whom the MCP
 *                               server then signs in as
 *   EKWO_VERSION                optional: the release to run, `latest` otherwise
 *
 * **Only on a project nobody minds losing.** It installs, creates a company,
 * and posts two opening entries; delete the project afterwards. It prints no
 * secret, and every amount it prints is one the database returned.
 */

import { spawn, spawnSync } from 'node:child_process';
import { mkdtempSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const version = process.env['EKWO_VERSION'] ?? 'latest';

/**
 * The two companies. The first is the one `ekwo init` creates; the second is
 * asked of the assistant afterwards, the way the guide shows. Each arrives with
 * the trial balance its earlier ledger exported, and one of them with the
 * correspondence its owner answered after the rehearsal.
 */
const COMPANIES = [
  {
    country: 'EE',
    name: 'Põhjatuul OÜ',
    language: 'en',
    fiscal_year_start: null,
    books: 'ee-trial-balance.csv',
    mapping: null,
    bank: '1010',
    customer: 'Lõuna Pagarid',
    tax: 'EE-S-24',
    period: { from: '2026-01-01', to: '2026-01-31' },
  },
  {
    country: 'GB',
    name: 'Harbourlight Ledger Ltd',
    language: null,
    fiscal_year_start: '2026-01-01',
    books: 'gb-trial-balance.csv',
    mapping: 'gb-mapping.json',
    bank: '1300',
    customer: 'Harbourlight Studio',
    tax: 'GB-S-20',
    period: { from: '2026-01-01', to: '2026-03-31' },
  },
];
const OPENING_DATE = '2026-01-01';
const YEAR = { from: '2026-01-01', to: '2026-12-31' };

const results = [];
let server;

// Every `npx` runs from an empty directory: from inside this repository the
// workspace of the same name answers for the package, and has no binary to run.
const outside = mkdtempSync(join(tmpdir(), 'ekwo-walkthrough-'));
process.on('exit', () => rmSync(outside, { recursive: true, force: true }));
function record(step, ok, detail = '') {
  results.push({ step, ok, detail });
  process.stdout.write(`${ok ? 'pass' : 'FAIL'}  ${step}${detail === '' ? '' : ` — ${detail}`}\n`);
}

function need(name) {
  const value = process.env[name];
  if (value === undefined || value === '') {
    process.stderr.write(`${name} is not set. See the head of this file.\n`);
    process.exit(2);
  }
  return value;
}

// ---- 1. npx ekwo-os init -----------------------------------------------------

const noCompany = process.argv.includes('--no-company');

/** The published command line, from the empty directory, with the environment given. */
function ekwo(args, env = process.env) {
  const run = spawnSync('npx', ['-y', `ekwo-os@${version}`, ...args], { cwd: outside, env, encoding: 'utf8' });
  // What a failure said is its last lines: the refusal comes after the steps.
  const said = `${run.stdout}${run.stderr}`.trim().split('\n').filter((l) => l.trim() !== '').slice(-2).join(' | ');
  let json = null;
  try {
    json = JSON.parse(run.stdout);
  } catch {}
  return { status: run.status, json, said };
}

/** The flags that describe one company, for `init` and for `company new` alike. */
function companyFlags(company) {
  const flags = ['--country', company.country, '--fiscal-year', '2026'];
  if (company.language !== null) flags.push('--language', company.language);
  if (company.fiscal_year_start !== null) flags.push('--fiscal-year-start', company.fiscal_year_start);
  return flags;
}

if (!process.argv.includes('--no-init')) {
  const [first] = COMPANIES;
  const flags = [
    '--org', 'Northwind Books',
    '--admin-email', need('EKWO_EMAIL'),
    // Without a terminal the installer takes the password as a flag only.
    // The project is a throwaway one, and the line is never printed.
    '--admin-password', need('EKWO_PASSWORD'),
    '--yes',
    ...(noCompany ? ['--no-company'] : ['--company', first.name, ...companyFlags(first)]),
  ];
  // The connection string and the key travel in the environment the
  // installer reads.
  need('EKWO_DB_URL');
  need('SUPABASE_SERVICE_ROLE_KEY');
  const init = ekwo(['init', ...flags]);
  record(
    `npx ekwo-os init${noCompany ? ' --no-company' : ''}`,
    init.status === 0,
    init.status !== 0 ? init.said : noCompany ? 'no company, no country' : `${first.country}, ${first.name}`,
  );
  if (init.status !== 0) finish();

  if (noCompany) {
    // `--no-company` refuses a flag that describes a company, before the
    // database is touched.
    const refused = ekwo(['init', '--no-company', '--country', first.country, '--yes']);
    record('init --no-company --country is refused', refused.status === 2, refused.said.slice(0, 140));
    for (const company of COMPANIES) {
      const made = ekwo(['company', 'new', company.name, ...companyFlags(company), '--yes', '--json']);
      const c = made.json?.data?.company ?? made.json?.company;
      record(`ekwo company new "${company.name}"`, made.status === 0, made.status !== 0 ? made.said : `${c?.country ?? '?'}, ${c?.currency ?? '?'}`);
    }
    const list = ekwo(['company', 'list', '--json']);
    const listed = list.json?.data?.companies ?? list.json?.companies ?? [];
    record('ekwo company list', list.status === 0 && COMPANIES.every((c) => listed.some((l) => l.name === c.name && l.country === c.country)), `${listed.length} companies`);
  }
}

// ---- 2. The MCP server, started the way Claude starts it ----------------------

// The block of the guide, and nothing else: no connection string, no
// service_role key. PATH and HOME are what a client hands any command it runs.
const env = {
  PATH: process.env['PATH'] ?? '',
  HOME: process.env['HOME'] ?? '',
  SUPABASE_URL: need('SUPABASE_URL'),
  SUPABASE_ANON_KEY: need('SUPABASE_ANON_KEY'),
  EKWO_EMAIL: need('EKWO_EMAIL'),
  EKWO_PASSWORD: need('EKWO_PASSWORD'),
};
server = spawn('npx', ['-y', `@ekwo-ai/mcp@${version}`], { cwd: outside, env, stdio: ['pipe', 'pipe', 'pipe'] });

let buffer = '';
let said = '';
const waiting = new Map();
server.stderr.on('data', (chunk) => {
  said += chunk;
});
server.on('exit', () => {
  for (const settle of waiting.values()) settle({ error: { message: said.trim() || 'the MCP server stopped' } });
  waiting.clear();
});
server.stdin.on('error', () => {});
server.stdout.on('data', (chunk) => {
  buffer += chunk;
  let end;
  while ((end = buffer.indexOf('\n')) >= 0) {
    const line = buffer.slice(0, end).trim();
    buffer = buffer.slice(end + 1);
    if (line === '') continue;
    const message = JSON.parse(line);
    waiting.get(message.id)?.(message);
  }
});

let nextId = 1;
function request(method, params) {
  const id = nextId++;
  return new Promise((resolve, reject) => {
    waiting.set(id, (message) => {
      waiting.delete(id);
      if (message.error !== undefined) reject(new Error(message.error.message));
      else resolve(message.result);
    });
    server.stdin.write(`${JSON.stringify({ jsonrpc: '2.0', id, method, params })}\n`);
  });
}

/** A tool call; a refusal comes back as `{ refused: text }` rather than thrown. */
async function tool(name, args) {
  const result = await request('tools/call', { name, arguments: args });
  const text = result.content?.[0]?.text ?? '';
  if (result.isError === true) return { refused: text };
  return JSON.parse(text);
}

function finish() {
  const failed = results.filter((r) => !r.ok).length;
  process.stdout.write(`\n${results.length - failed} passed, ${failed} failed\n`);
  server?.kill();
  process.exit(failed === 0 ? 0 : 1);
}

try {
  await request('initialize', {
    protocolVersion: '2025-06-18',
    capabilities: {},
    clientInfo: { name: 'start-with-claude walkthrough', version: '1' },
  });
  server.stdin.write(`${JSON.stringify({ jsonrpc: '2.0', method: 'notifications/initialized' })}\n`);

  const { tools } = await request('tools/list', {});
  const names = new Set(tools.map((t) => t.name));
  record('the server lists import_books', names.has('import_books'), `${tools.length} tools`);

  const status = await tool('status', {});
  record('"Is Ekwo connected?" — status', status.refused === undefined, status.refused ?? `schema ${status.schema_version ?? status.schema?.version ?? '?'}`);

  // ---- 3. "List my companies", and the second country asked for -------------

  let listed = await tool('list_companies', {});
  const byName = () => new Map((listed.companies ?? []).map((c) => [c.name, c]));
  for (const company of COMPANIES) {
    if (byName().has(company.name)) continue;
    const created = await tool('create_company', {
      name: company.name,
      country: company.country,
      fiscal_year: 2026,
      ...(company.language === null ? {} : { language: company.language }),
      ...(company.fiscal_year_start === null ? {} : { fiscal_year_start: company.fiscal_year_start }),
    });
    record(`"Create ${company.name} in ${company.country}" — create_company`, created.refused === undefined, created.refused ?? '');
    listed = await tool('list_companies', {});
  }
  for (const company of COMPANIES) {
    const found = byName().get(company.name);
    record(`list_companies shows ${company.name}`, found !== undefined && found.country === company.country, found === undefined ? 'missing' : `${found.country}, ${found.currency_code}, ${found.your_role ?? ''}`);
    company.id = found?.id;
  }
  if (COMPANIES.some((c) => c.id === undefined)) finish();

  // ---- 3b. The same companies from the terminal: login, use, whoami ----------

  // The command line keeps a session in a configuration directory of its own,
  // outside any repository; this one is thrown away with `outside`.
  const configDir = join(outside, 'config');
  const cli = (args, extra = {}) => {
    const run = spawnSync('npx', ['-y', `ekwo-os@${version}`, ...args, '--json'], {
      cwd: outside,
      env: { PATH: env.PATH, HOME: env.HOME, EKWO_CONFIG_DIR: configDir, ...extra },
      encoding: 'utf8',
    });
    let json = null;
    try {
      json = JSON.parse(run.stdout);
    } catch {}
    return { status: run.status, json, said: `${run.stdout}${run.stderr}`.trim().split('\n')[0] };
  };
  const login = cli(['login', '--supabase-url', env.SUPABASE_URL, '--anon-key', env.SUPABASE_ANON_KEY, '--email', env.EKWO_EMAIL, '--yes'], {
    EKWO_PASSWORD: env.EKWO_PASSWORD,
  });
  record('ekwo login', login.status === 0, login.status === 0 ? 'session kept in a throwaway directory' : login.said);
  const second = COMPANIES[1];
  // Without the address and the password in the environment: with them, the
  // environment is who you are and there is no profile to keep a company in.
  const use = cli(['use', second.name]);
  record(`ekwo use "${second.name}"`, use.status === 0, use.status === 0 ? '' : use.said);
  const who = cli(['whoami']);
  const inUse = JSON.stringify(who.json ?? {}).includes(second.id);
  record('ekwo whoami names it as the company in use', who.status === 0 && inUse, who.status === 0 ? (inUse ? second.name : 'another company') : who.said);

  // ---- 4. "Import my books" — rehearsal, correspondence, import -------------

  for (const company of COMPANIES) {
    const file = { name: company.books, content: readFileSync(join(here, company.books), 'utf8') };
    const base = { company_id: company.id, source: 'trial-balance', files: [file], opening_date: OPENING_DATE };

    const first = await tool('import_books', { ...base, dry_run: true });
    const unmapped = first.unmapped_accounts ?? [];
    const bases = (first.accounts ?? []).map((a) => `${a.source} ${a.name} → ${a.target ?? '?'} (${a.basis}${a.match ? `, ${a.match}` : ''})${a.reason ? ` — ${a.reason}` : ''}`);
    record(
      `${company.country}: dry run, nothing given`,
      first.refused === undefined && first.dry_run === true,
      first.refused ?? `${first.read?.opening_lines} lines read; ${unmapped.length === 0 ? 'every account proposed' : `unanswered: ${unmapped.join(', ')}`}`,
    );
    for (const line of bases) process.stdout.write(`      ${line}\n`);

    const mapping = company.mapping === null ? undefined : JSON.parse(readFileSync(join(here, company.mapping), 'utf8'));

    // Answering only what was left open, and trusting the rest, is the
    // mistake the guide warns about: the same digits in two charts are not
    // the same account. A suggestion is not an answer, so the rehearsal has
    // to refuse it.
    if (mapping !== undefined && unmapped.length > 0) {
      const onlyGaps = { accounts: Object.fromEntries(unmapped.map((code) => [code, mapping.accounts[code]])) };
      const trusting = await tool('import_books', { ...base, mapping: onlyGaps, dry_run: true });
      const said = trusting.refused ?? (trusting.refusals ?? []).join(' | ');
      record(`${company.country}: dry run trusting every proposal is refused`, said !== '', said.split('\n')[0].slice(0, 160) || 'accepted');
    }
    // The company with no correspondence file is the one whose every
    // suggestion the guide reads and accepts.
    const withMapping = { ...base, ...(mapping === undefined ? { accept_suggestions: true } : { mapping }) };
    const second = await tool('import_books', { ...withMapping, dry_run: true });
    record(
      `${company.country}: dry run${mapping === undefined ? ' accepting the suggestions read' : ' with the answered correspondence'}`,
      second.refused === undefined && (second.refusals ?? []).length === 0 && second.result !== null,
      second.refused ?? ((second.refusals ?? []).join(' | ') || 'rehearsed by the database and rolled back'),
    );

    const real = await tool('import_books', withMapping);
    record(`${company.country}: import`, real.refused === undefined, real.refused ?? `${real.result?.lines} lines posted as the opening entry of ${OPENING_DATE}`);

    const again = await tool('import_books', withMapping);
    record(`${company.country}: the same file twice is refused`, again.refused !== undefined && /import_already_done/.test(again.refused), (again.refused ?? 'accepted').split('\n')[0].slice(0, 120));
  }

  // ---- 5. "What is in the bank, and does the balance add up?" ---------------

  for (const company of COMPANIES) {
    const tb = await tool('trial_balance', { company_id: company.id, ...YEAR });
    const rows = tb.accounts ?? [];
    const bank = rows.find((r) => r.account_code === company.bank);
    const moved = rows.filter((r) => Number(r.debit) !== 0 || Number(r.credit) !== 0);
    // Added here only to say whether the two columns agree; every figure is the database's.
    const debit = moved.reduce((sum, r) => sum + Number(r.debit), 0).toFixed(2);
    const credit = moved.reduce((sum, r) => sum + Number(r.credit), 0).toFixed(2);
    record(
      `${company.country}: "what is in the bank?" — trial_balance`,
      tb.refused === undefined && bank !== undefined && debit === credit,
      tb.refused ?? `${company.bank} ${bank?.account_name}: ${bank?.closing_balance}; ${moved.length} accounts moved, debit ${debit} = credit ${credit}`,
    );

    // Imported lines carry no tax: the return of the period is empty, and
    // saying so is the point of asking for it before anything is booked.
    const before = await tool('vat_return', { company_id: company.id, ...company.period });
    record(`${company.country}: vat_return after the import alone`, before.refused === undefined && (before.boxes ?? []).every((b) => Number(b.amount) === 0), before.refused ?? `${(before.boxes ?? []).length} box(es), all zero: imported lines feed none`);
  }

  // ---- 6. "Invoice them, post it, and prepare my return" ---------------------

  for (const company of COMPANIES) {
    const found = await tool('search_contacts', { company_id: company.id, query: company.customer });
    const contact = (found.contacts ?? found)[0];
    record(`${company.country}: the imported customer is found`, contact?.id !== undefined, contact?.name ?? found.refused ?? 'none');
    if (contact?.id === undefined) continue;

    const draft = await tool('create_document', {
      company_id: company.id,
      doc_type: 'sale_invoice',
      contact_id: contact.id,
      document_date: company.period.from.replace(/-01$/, '-15'),
      client_ref: `walkthrough-${company.country}`,
      lines: [{ name: 'Consulting', quantity: '1', unit_price: '1000.00', tax_code: company.tax }],
    });
    const document = draft.document ?? draft;
    record(`${company.country}: create_document`, draft.refused === undefined, draft.refused ?? `total ${document.amount_total}`);
    if (draft.refused !== undefined) continue;

    const posted = await tool('post_document', { document_id: document.id });
    record(`${company.country}: post_document`, posted.refused === undefined, posted.refused ?? (posted.entry?.number ?? posted.document?.number ?? posted.number ?? 'posted'));

    const vat = await tool('vat_return', { company_id: company.id, ...company.period });
    const shown = (vat.boxes ?? []).filter((b) => b.hidden !== true && Number(b.amount) !== 0).sort((a, b) => a.print_sequence - b.print_sequence);
    record(`${company.country}: vat_return for ${company.period.from} to ${company.period.to}`, vat.refused === undefined && shown.length > 0, vat.refused ?? `${vat.report_code}`);
    for (const b of shown) process.stdout.write(`      ${b.box.padEnd(5)} ${b.amount.padStart(10)}  ${b.name.slice(0, 60)}\n`);
  }
} catch (error) {
  record('the walkthrough', false, error.message.split('\n')[0]);
}
finish();
