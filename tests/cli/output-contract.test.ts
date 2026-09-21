/**
 * The output contract, held against every command this CLI has.
 *
 * Two proofs. The first runs each command with `--json` — the command itself,
 * flags in and exit code out, against a real Postgres — and validates the one
 * document it wrote against `packages/cli/schema/output.1.json`. The list of
 * commands is read from the CLI, so a command added without a case here fails
 * the last test of the block rather than going unchecked.
 *
 * The second asks the database for something it refuses — a document dated
 * inside a locked period — and checks what a caller with nothing but a shell
 * would see: exit code 3, the name of the refusal in a field of its own, and
 * the sentence the database wrote, word for word.
 */

import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  COMMANDS,
  EXIT_ERROR,
  EXIT_REFUSED,
  EXIT_USAGE,
  UsageError,
  classify,
  execute,
  listModules,
  parseArgs,
  run,
  setResult,
  validate,
  type OutputDocument,
  type SqlClient,
} from '../../packages/cli/src/index.js';
import { ask, askSecret, confirm } from '../../packages/cli/src/prompt.js';
import { table } from '../../packages/cli/src/ui.js';
import { asUser, expectError, freshDatabase, repoRoot } from '../helpers/db.js';
import { newCompany, newContact, newDocument, newUser } from '../helpers/factory.js';
import { roleOf, somePack } from '../helpers/packs.js';
import { ANON_KEY, FAKE_URL, fakeSupabase } from './fake-supabase.js';
import { adapt, emptyDatabase, fakeFetch, makeAuthUser, type Queryable } from './helpers.js';

// The installation these tests make is in some country, named once.
const HOME = somePack.manifest.country;

// Never dialled: the connector below answers instead of the network driver.
const DB_URL = 'postgresql://postgres:secret@localhost:5432/postgres';

// An escape code, or a carriage return: colour, or a line redrawn in place.
const TERMINAL_TRICKS = new RegExp(`${String.fromCharCode(27)}|${String.fromCharCode(13)}`);

interface Captured {
  exitCode: number;
  stdout: string;
  stderr: string;
}

/** Runs something that prints, and keeps the two streams apart. */
async function capture(fn: () => Promise<number>): Promise<Captured> {
  const out = process.stdout.write.bind(process.stdout);
  const err = process.stderr.write.bind(process.stderr);
  let stdout = '';
  let stderr = '';
  process.stdout.write = ((chunk: string | Uint8Array) => {
    stdout += String(chunk);
    return true;
  }) as typeof process.stdout.write;
  process.stderr.write = ((chunk: string | Uint8Array) => {
    stderr += String(chunk);
    return true;
  }) as typeof process.stderr.write;
  try {
    return { exitCode: await fn(), stdout, stderr };
  } finally {
    process.stdout.write = out;
    process.stderr.write = err;
  }
}

let schema: Record<string, unknown>;

/** The whole standard output is one document, and the document is the schema's. */
function documentOf(captured: Captured): OutputDocument {
  const parsed = JSON.parse(captured.stdout) as OutputDocument;
  expect(validate(parsed, schema)).toEqual([]);
  expect(parsed.exitCode).toBe(captured.exitCode);
  expect(parsed.ok).toBe(captured.exitCode === 0);
  return parsed;
}

/** `data` has a shape per command, described under `$defs/data/<command>`. */
function expectData(document: OutputDocument): void {
  const shapes = (schema['$defs'] as Record<string, Record<string, unknown>>)['data'] ?? {};
  const shape = shapes[document.command] as Record<string, unknown> | undefined;
  expect(shape, `output.1.json describes no data for "${document.command}"`).toBeDefined();
  expect(document.data, `"${document.command}" answered no data`).toBeDefined();
  expect(validate(document.data, shape ?? {}, schema)).toEqual([]);
}

beforeAll(async () => {
  schema = JSON.parse(
    await readFile(join(repoRoot, 'packages', 'cli', 'schema', 'output.1.json'), 'utf8'),
  ) as Record<string, unknown>;
});

describe('every command answers --json with one document of the published shape', () => {
  let db: SqlClient;
  let root: PGlite;
  let adminUserId: string;
  let cwd: string;
  const seen = new Set<string>();

  /** A command closes its connection when it is done; the next one needs it open. */
  const connect = async (): Promise<SqlClient> => ({ ...db, close: async () => {} });

  async function json(argv: string[], deps: Parameters<typeof run>[1] = {}): Promise<OutputDocument> {
    const captured = await capture(() =>
      run([...argv, '--json', '--db-url', DB_URL], { connect, cwd, ...deps }),
    );
    const document = documentOf(captured);
    if (document.error === undefined) expectData(document);
    seen.add(document.command.split(' ')[0] as string);
    return document;
  }

  beforeAll(async () => {
    ({ db, pg: root } = await emptyDatabase());
    adminUserId = await makeAuthUser(db, 'first@example.test');
    cwd = await mkdtemp(join(tmpdir(), 'ekwo-output-'));
  });

  afterAll(async () => {
    await db.close().catch(() => {});
    await rm(cwd, { recursive: true, force: true });
  });

  it('init', async () => {
    const document = await json([
      'init',
      '--yes',
      '--country',
      HOME,
      '--org',
      'Example Group',
      '--company',
      'Example One',
      '--admin-user-id',
      adminUserId,
      '--fiscal-year',
      '2026',
      '--fiscal-year-start',
      '2026-01-01',
      '--language',
      somePack.languages[0] as string,
      '--chart',
      (somePack.charts.find((chart) => chart.is_default) ?? somePack.charts[0]!).code,
      ...(somePack.report?.periods[0] === undefined ? [] : ['--vat-period', somePack.report.periods[0]]),
    ]);
    expect(document.error).toBeUndefined();
    expect(document.exitCode).toBe(0);
    expect((document.data as { company: { country: string } }).company.country).toBe(HOME);

    // Straight after `init`, and before `migrate` has had a chance to paper
    // over it: an installer that leaves the modules out leaves an installation
    // `ekwo status` calls behind, exit code 1 — what the first run against a
    // real Supabase project found on 19 September 2026.
    const after = await json(['status']);
    expect((after.data as { pending: unknown[] }).pending).toEqual([]);
    expect(after.exitCode).toBe(0);
  });

  it('migrate', async () => {
    const document = await json(['migrate', '--yes']);
    expect(document.exitCode).toBe(0);
    expect((document.data as { applied: string[] }).applied).toEqual([]);
  });

  it('status', async () => {
    const document = await json(['status']);
    expect(document.exitCode).toBe(0);
    expect((document.data as { companies: unknown[] }).companies).toHaveLength(1);
  });

  it('doctor', async () => {
    const document = await json(['doctor']);
    // A finding is not an error: the code says a check found something, the
    // data says what, and `error` stays for what went wrong.
    expect(document.error).toBeUndefined();
    expect([0, EXIT_ERROR]).toContain(document.exitCode);
  });

  it('module list, migrate, enable and disable', async () => {
    const modules = await listModules();
    const first = modules[0]?.manifest.code;
    expect(first).toBeDefined();
    expect((await json(['module', 'list'])).command).toBe('module list');
    expect((await json(['module', 'migrate'])).exitCode).toBe(0);
    const enabled = await json(['module', 'enable', first as string]);
    expect(enabled.data).toMatchObject({ module: first, enabled: true });
    const disabled = await json(['module', 'disable', first as string]);
    expect(disabled.data).toMatchObject({ module: first, enabled: false });
  });

  it('pack list, check, build, status and upgrade', async () => {
    expect((await json(['pack', 'list'])).exitCode).toBe(0);
    // The committed seeds are the output of their packs, so a build writes
    // nothing here and a check finds nothing.
    const check = await json(['pack', 'check', '--all']);
    expect(check.data).toMatchObject({ action: 'check', stale: 0 });
    const build = await json(['pack', 'build', '--all']);
    expect((build.data as { files: { state: string }[] }).files.every((f) => f.state === 'unchanged')).toBe(true);
    // And so are the lists of packs outside packs/: nothing to write either.
    expect((build.data as { lists: { state: string }[] }).lists.every((l) => l.state === 'unchanged')).toBe(true);
    expect((await json(['pack', 'status'])).command).toBe('pack status');
    const upgrade = await json(['pack', 'upgrade', 'Example One']);
    expect(upgrade.data).toMatchObject({ company: { name: 'Example One' } });
  });

  it('register and unregister', async () => {
    const registry = fakeFetch(() => ({ status: 200, body: {} }));
    const registered = await json(
      ['register', '--yes', '--email', 'ops@example.test', '--registry-url', 'https://registry.example.test'],
      { fetchImpl: registry.fetchImpl as typeof globalThis.fetch },
    );
    expect(registered.data).toMatchObject({ registered: true, announced: true });
    const undone = await json(['unregister', '--yes']);
    expect(undone.data).toEqual({ registered: false, changed: true });
  });

  it('demo', async () => {
    // A company is already here and nobody said --yes: under --json there is
    // nobody to ask, so the answer is "not applied" and never a question.
    const held = await json(['demo']);
    expect(held.data).toEqual({ applied: false, reason: 'not_confirmed' });
    const applied = await json(['demo', '--yes']);
    expect(applied.data).toEqual({ applied: true });
  });

  it('company export and import', async () => {
    const out = join(cwd, 'archive');
    const exported = await json(['company', 'export', 'Example One', '--out', out]);
    expect(exported.exitCode).toBe(0);
    expect(exported.data).toMatchObject({
      company: { name: 'Example One' },
      actingAs: adminUserId,
      files: { transported: false },
    });
    // The company is still here, so taking it in is the books saying no — in
    // the same document, with the name of the refusal in a field of its own.
    const again = await json(['company', 'import', out]);
    expect(again.exitCode).toBe(EXIT_REFUSED);
    expect(again.error).toMatchObject({ kind: 'refusal', name: 'company_already_here', sqlstate: '23505' });
  });

  it('login, whoami, use and logout', async () => {
    // The commands that act as a person take no connection string: they sign
    // in to the instance, which here is the database above behind the two
    // HTTP surfaces the CLI speaks.
    const instance = fakeSupabase(root);
    instance.addUser(adminUserId, 'first@example.test', 'a password');
    const env = { EKWO_CONFIG_DIR: join(cwd, 'user-config') };
    const asPerson = async (argv: string[]): Promise<OutputDocument> => {
      const captured = await capture(() => run([...argv, '--json'], { fetchImpl: instance.fetchImpl, env, cwd }));
      const document = documentOf(captured);
      if (document.error === undefined) expectData(document);
      seen.add(document.command.split(' ')[0] as string);
      return document;
    };

    const login = await asPerson([
      'login', '--supabase-url', FAKE_URL, '--anon-key', ANON_KEY, '--email', 'first@example.test', '--password', 'a password',
    ]);
    expect(login.exitCode).toBe(0);
    const used = await asPerson(['use', 'Example One']);
    // The company an answer was rendered for is in the answer, where a caller
    // that keeps two sets of books looks before it believes the rest.
    expect(used.context).toMatchObject({ profile: 'default', instance: FAKE_URL, company: { name: 'Example One' } });
    const who = await asPerson(['whoami']);
    expect(who.context).toEqual(used.context);
    expect((who.data as { capabilities: string[] }).capabilities.length).toBeGreaterThan(0);
    // The verbs that keep books, each once, on the company `init` made. What
    // they do is `books.test.ts`; here it is the shape of what they answer.
    const sales = roleOf(somePack, 'sales');
    const contact = await asPerson(['contact', 'add', 'Client Example', '--ref', 'c-1']);
    expect(contact.exitCode).toBe(0);
    expect((await asPerson(['contact', 'list'])).exitCode).toBe(0);
    const draft = await asPerson(['doc', 'new', '--contact', 'Client Example', '--date', '2026-06-15', '--ref', 'd-1', '--line', `name=Work,price=100.00,account=${sales}`]);
    expect(draft.exitCode).toBe(0);
    expect((await asPerson(['doc', 'line', 'add', 'd-1', '--name', 'More', '--price', '20.00', '--account', sales])).command).toBe('doc line add');
    // The old name of the same verb answers with the same shape, under the words that were typed.
    const underAlias = await asPerson(['invoice', 'new', '--contact', 'Client Example', '--date', '2026-06-15', '--ref', 'd-alias', '--line', `name=Work,price=100.00,account=${sales}`]);
    expect(underAlias.command).toBe('invoice new');
    expect(underAlias.exitCode).toBe(0);
    expect((await asPerson(['post', 'd-1', '--dry-run'])).data).toMatchObject({ dry_run: true });
    expect((await asPerson(['post', 'd-1'])).exitCode).toBe(0);
    expect((await asPerson(['doc', 'list', '--unpaid'])).data).toMatchObject({ count: 1 });
    const shown = await asPerson(['doc', 'show', 'd-1']);
    const total = (shown.data as { document: { amount_total: string } }).document.amount_total;
    // An amount is a decimal string, never a JSON number: the rule of the
    // contract finally has a command that could break it.
    expect(total).toMatch(/^\d+\.\d+$/);
    const bank = await root.query<{ id: string }>(
      `insert into bank_accounts (company_id, name, currency_code, account_id, journal_id)
       select c.id, 'Bank', c.currency_code,
              (select id from accounts where company_id = c.id and account_type = 'asset_cash' order by code limit 1),
              (select id from journals where company_id = c.id and journal_type = 'bank' order by code limit 1)
         from companies c where c.name = 'Example One'
       returning id`,
    );
    const bankAccount = bank.rows[0]?.id as string;
    const statementLine = await root.query<{ id: string }>(
      `insert into bank_transactions (company_id, bank_account_id, transaction_date, amount, currency_code)
       select c.id, $1, date '2026-06-20', 50, c.currency_code from companies c where c.name = 'Example One' returning id`,
      [bankAccount],
    );
    expect((await asPerson(['match', statementLine.rows[0]?.id as string, 'd-1'])).exitCode).toBe(0);
    const paid = await asPerson(['payment', 'record', '--doc', 'd-1', '--amount', '70.00', '--date', '2026-06-30', '--bank-account', bankAccount, '--ref', 'p-1']);
    expect(paid.exitCode).toBe(0);
    for (const document of [contact, draft, shown, paid]) {
      expect(document.context).toEqual(used.context);
    }
    // The two verbs that undo: a posted invoice, and an entry keyed by hand.
    await asPerson(['doc', 'new', '--contact', 'Client Example', '--date', '2026-06-15', '--ref', 'd-2', '--line', `name=Mistake,price=30.00,account=${sales}`]);
    await asPerson(['post', 'd-2']);
    expect((await asPerson(['cancel', 'd-2'])).exitCode).toBe(0);
    const keyed = await root.query<{ id: string; company_id: string }>(
      `insert into entries (company_id, journal_id, entry_date, description)
       select c.id, c.miscellaneous_journal_id, date '2026-06-15', 'By hand' from companies c where c.name = 'Example One'
       returning id, company_id`,
    );
    const handId = keyed.rows[0]?.id as string;
    await root.query(
      `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
       values ($1, $2, (select account_id from bank_accounts where id = $3), 10, 5, 0),
              ($1, $2, account_id_by_code($2, $4), 20, 0, 5)`,
      [handId, keyed.rows[0]?.company_id, bankAccount, sales],
    );
    const numbered = await root.query<{ number: string }>(`select number from post_entry($1)`, [handId]);
    expect((await asPerson(['reverse', numbered.rows[0]?.number as string])).exitCode).toBe(0);

    expect((await asPerson(['logout'])).data).toMatchObject({ signedOut: true });
    // The commands that install act as nobody, and carry no such field.
    expect((await json(['status'])).context).toBeUndefined();
  });

  it('help and version', async () => {
    const help = documentOf(await capture(() => run(['--help', '--json'])));
    expectData(help);
    expect((help.data as { commands: string[] }).commands).toEqual([...COMMANDS]);
    const version = documentOf(await capture(() => run(['--version', '--json'])));
    expect(version.command).toBe('version');
    expectData(version);
    expect((version.data as { version: string }).version).toMatch(/^\d+\.\d+\.\d+/);
  });

  it('left no command out', () => {
    expect([...seen].sort()).toEqual([...COMMANDS].sort());
  });

  it('keeps the prose off the standard output, and writes it all the same', async () => {
    const captured = await capture(() => run(['status', '--json', '--db-url', DB_URL], { connect }));
    expect(() => JSON.parse(captured.stdout) as unknown).not.toThrow();
    expect(captured.stderr).toContain('Schema');
    // Not a terminal: no colour, nothing redrawn in place.
    expect(captured.stdout + captured.stderr).not.toMatch(TERMINAL_TRICKS);
  });

  it('prints for a person by default, and no JSON', async () => {
    const captured = await capture(() => run(['module', 'list', '--db-url', DB_URL], { connect }));
    expect(captured.exitCode).toBe(0);
    expect(captured.stdout).toMatch(/code\s+name\s+version\s+schema\s+migrations\s+state/);
    expect(captured.stdout).not.toContain('"ok"');
  });

  it('answers a wrong call with code 2, in the same document', async () => {
    const unknownFlag = await capture(() => run(['status', '--json', '--colour', '--db-url', DB_URL], { connect }));
    expect(unknownFlag.exitCode).toBe(EXIT_USAGE);
    expect(documentOf(unknownFlag).error).toMatchObject({ kind: 'usage' });

    const unknownCommand = await capture(() => run(['eject', '--json']));
    expect(unknownCommand.exitCode).toBe(EXIT_USAGE);
    expect(documentOf(unknownCommand).error?.message).toContain('unknown command: eject');

    // Refused before any flag is read, so `--json` is taken as it was typed.
    const unknownShort = await capture(() => run(['status', '-x', '--json']));
    expect(unknownShort.exitCode).toBe(EXIT_USAGE);
    expect(documentOf(unknownShort).error).toMatchObject({ kind: 'usage', message: 'unknown option: -x' });

    // Nothing to connect with and nobody to ask: a wrong call, not a failure.
    const noConnection = await capture(() => run(['status', '--json'], { connect }));
    expect(noConnection.exitCode).toBe(EXIT_USAGE);
    expect(documentOf(noConnection).error).toMatchObject({ kind: 'usage', name: 'missing_input' });
  });

  it('answers a database that does not answer with code 1', async () => {
    const down = await capture(() =>
      run(['status', '--json', '--db-url', DB_URL], {
        connect: async () => {
          throw Object.assign(new Error('connect ECONNREFUSED 127.0.0.1:5432'), { code: 'ECONNREFUSED' });
        },
      }),
    );
    expect(down.exitCode).toBe(EXIT_ERROR);
    const document = documentOf(down);
    expect(document.error).toMatchObject({ kind: 'technical', message: 'connect ECONNREFUSED 127.0.0.1:5432' });
    expect(document.error?.sqlstate).toBeUndefined();
  });

  it('answers a refusal with code 3 from a command that ships today', async () => {
    // `enable_module()` refuses anybody who may not manage the company. The
    // CLI acts for whoever `--as-user` names, so naming a stranger is the
    // shortest way to have a shipped command refused by the schema itself.
    const stranger = await makeAuthUser(db, 'stranger@example.test');
    const first = (await listModules())[0]?.manifest.code as string;

    const refused = await capture(() =>
      run(['module', 'enable', first, '--company', 'Example One', '--as-user', stranger, '--json', '--db-url', DB_URL], {
        connect,
      }),
    );
    expect(refused.exitCode).toBe(EXIT_REFUSED);
    const document = documentOf(refused);
    expect(document.error?.kind).toBe('refusal');
    expect(document.error?.message).toBe('not_allowed: enabling a module on this company needs company.write');
    expect(document.error?.name).toBe('not_allowed');
    expect(document.error?.sqlstate).toBe('42501');
    expect(refused.stderr).toContain(document.error?.message as string);
  });
});

describe('a refusal of the database', () => {
  let pg: PGlite;
  let db: SqlClient;
  let companyId: string;
  let documentId: string;
  let said: string;

  beforeAll(async () => {
    pg = await freshDatabase();
    db = adapt(pg as unknown as Queryable, pg);
    const fx = await newCompany(pg, { country: HOME });
    companyId = fx.companyId;
    const customer = await newContact(pg, fx.companyId, { name: 'Client Example' });
    documentId = await newDocument(pg, fx.companyId, {
      docType: 'sale_invoice',
      number: 'INV-LOCKED',
      contactId: customer,
      date: '2026-03-15',
      lines: [{ unitPrice: 100, accountCode: roleOf(somePack, 'sales'), taxCode: null }],
    });
    await pg.query(`update companies set lock_date = date '2026-03-31' where id = $1`, [fx.companyId]);
    // What the database says, asked directly: the words the CLI has to repeat.
    said = await expectError(pg, 'select post_document($1)', [documentId]);
  });

  afterAll(async () => {
    await pg.close();
  });

  /**
   * No command that ships today can reach a locked period — the first verb
   * that books arrives with a later card of the epic. So the refusal is
   * provoked through `execute()`, the one function every command runs under,
   * by a handler that does what that verb will do: call `post_document()`.
   */
  const post = (argv: string[]): Promise<Captured> =>
    capture(() =>
      execute(parseArgs(argv), argv.includes('--json'), async () => {
        await db.query('select post_document($1)', [documentId]);
        setResult({ posted: documentId });
        return 0;
      }),
    );

  it('ends on code 3 and names the refusal, in a field of its own', async () => {
    const refused = await post(['post', '--json']);
    expect(refused.exitCode).toBe(EXIT_REFUSED);
    const document = documentOf(refused);
    expect(document.ok).toBe(false);
    expect(document.data).toBeUndefined();
    expect(document.error?.kind).toBe('refusal');
    expect(document.error?.name).toBe('period_locked');
    expect(document.error?.sqlstate).toMatch(/^[0-9A-Z]{5}$/);
  });

  it('repeats the database word for word, to a program and to a person', async () => {
    expect(said).toMatch(/^period_locked:/);
    const machine = await post(['post', '--json']);
    expect(documentOf(machine).error?.message).toBe(said);

    const person = await post(['post']);
    expect(person.exitCode).toBe(EXIT_REFUSED);
    expect(person.stdout).toBe('');
    expect(person.stderr).toContain(said);
  });

  it('moved no date and posted nothing to get there', async () => {
    const { rows } = await pg.query<{ date: string; entries: number }>(
      `select d.document_date::text as date,
              (select count(*)::int from entries e where e.document_id = d.id) as entries
         from documents d where d.id = $1`,
      [documentId],
    );
    expect(rows[0]).toEqual({ date: '2026-03-15', entries: 0 });
  });

  it('reads a policy that says no as a refusal too', async () => {
    const stranger = await newUser(pg, 'stranger@example.test');
    const refused = await capture(() =>
      execute(parseArgs(['post', '--json']), true, async () => {
        await asUser(pg, stranger, () =>
          db.query(`insert into contacts (company_id, name) values ($1, 'Nobody')`, [companyId]),
        );
        return 0;
      }),
    );
    expect(refused.exitCode).toBe(EXIT_REFUSED);
    expect(documentOf(refused).error).toMatchObject({ kind: 'refusal', sqlstate: '42501' });
  });
});

describe('telling the three apart', () => {
  it('reads the exit code off the error, never off its wording', () => {
    expect(classify(new UsageError('unknown option: --x')).exitCode).toBe(EXIT_USAGE);
    expect(classify(Object.assign(new Error('period_locked: closed'), { code: '55006' })).exitCode).toBe(EXIT_REFUSED);
    expect(classify(Object.assign(new Error('violates check constraint'), { code: '23514' })).exitCode).toBe(EXIT_REFUSED);
    // A sentence that starts like a refusal and did not come from the
    // database is not one: the name is kept, the code is not promoted.
    const local = classify(new Error('module_not_migrated: run `ekwo module migrate` first'));
    expect(local.exitCode).toBe(EXIT_ERROR);
    expect(local.error).toMatchObject({ kind: 'technical', name: 'module_not_migrated' });
    // The software failing is not the books refusing.
    expect(classify(Object.assign(new Error('relation "x" does not exist'), { code: '42P01' })).exitCode).toBe(EXIT_ERROR);
    expect(classify(Object.assign(new Error('terminating connection'), { code: '08006' })).exitCode).toBe(EXIT_ERROR);
  });
});

describe('questions', () => {
  it('never wait on a pipe: a prompt reached with nobody to answer is a wrong call', async () => {
    // Vitest's stdin is not a terminal, which is exactly an agent's shell.
    expect(process.stdin.isTTY).not.toBe(true);
    await expect(ask('Anything?')).rejects.toThrow(/missing_input/);
    await expect(askSecret('A secret?')).rejects.toThrow(/missing_input/);
    await expect(confirm('Sure?')).rejects.toThrow(/missing_input/);
    const asked = await capture(() =>
      execute(parseArgs(['demo']), false, async () => ((await confirm('Sure?')) ? 0 : 1)),
    );
    expect(asked.exitCode).toBe(EXIT_USAGE);
  });
});

describe('a table', () => {
  it('pads every column to its widest cell and aligns numbers on the right', async () => {
    const printed = await capture(async () => {
      table(
        [{ title: 'account' }, { title: 'balance', align: 'right' }],
        [
          ['400000', '1210.00'],
          ['70', '-1000.00'],
        ],
      );
      return 0;
    });
    expect(printed.stdout.split('\n').slice(0, 3)).toEqual([
      '  account   balance',
      '  400000    1210.00',
      '  70       -1000.00',
    ]);
  });
});
