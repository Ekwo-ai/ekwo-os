/**
 * The bookkeeping verbs: a contact, an invoice and its lines, posting, a
 * payment, a statement line matched, and the list of what is still owed.
 *
 * Each test runs the command — flags or a JSON document in, one JSON document
 * and an exit code out — as a signed-in person, against a real Postgres behind
 * the instance's two HTTP surfaces. Every expectation about a figure is read
 * back from the database, because the claim under test is that the command
 * line has no figure of its own.
 */

import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { EXIT_REFUSED, EXIT_USAGE, run, validate, type OutputDocument } from '../../packages/cli/src/index.js';
import { expectError, freshDatabase, one, repoRoot, rows } from '../helpers/db.js';
import { newCompany, newUser } from '../helpers/factory.js';
import { roleOf, somePack } from '../helpers/packs.js';
import { ANON_KEY, FAKE_URL, fakeSupabase, type FakeSupabase } from './fake-supabase.js';

const HOME = somePack.manifest.country;
const SALES = roleOf(somePack, 'sales');
const PASSWORD = 'correct horse battery staple';

type Row = Record<string, unknown>;

let pg: PGlite;
let schema: Row;
let instance: FakeSupabase;
let root: string;
let owner: string;
let viewer: string;
let companyId: string;
let otherCompanyId: string;
let bankAccountId: string;

async function capture(fn: () => Promise<number>): Promise<{ exitCode: number; stdout: string; stderr: string }> {
  const out = process.stdout.write.bind(process.stdout);
  const err = process.stderr.write.bind(process.stderr);
  let stdout = '';
  let stderr = '';
  process.stdout.write = ((chunk: string | Uint8Array) => ((stdout += String(chunk)), true)) as typeof process.stdout.write;
  process.stderr.write = ((chunk: string | Uint8Array) => ((stderr += String(chunk)), true)) as typeof process.stderr.write;
  try {
    return { exitCode: await fn(), stdout, stderr };
  } finally {
    process.stdout.write = out;
    process.stderr.write = err;
  }
}

type Answer = OutputDocument & { stderr: string };

/** Runs a command as one of the two people, under --json, and holds the answer to the schema. */
async function ekwo(argv: string[], options: { as?: 'owner' | 'viewer'; stdin?: unknown } = {}): Promise<Answer> {
  const env = { EKWO_CONFIG_DIR: join(root, options.as ?? 'owner') };
  const captured = await capture(() =>
    run([...argv, '--json'], {
      fetchImpl: instance.fetchImpl,
      env,
      ...(options.stdin === undefined ? {} : { stdin: JSON.stringify(options.stdin) }),
    }),
  );
  const document = JSON.parse(captured.stdout) as OutputDocument;
  expect(validate(document, schema)).toEqual([]);
  expect(document.exitCode).toBe(captured.exitCode);
  if (document.error === undefined) {
    const shape = ((schema['$defs'] as Record<string, Row>)['data'] ?? {})[document.command];
    expect(shape, `output.1.json describes no data for "${document.command}"`).toBeDefined();
    expect(validate(document.data, shape as Row, schema)).toEqual([]);
  }
  return { ...document, stderr: captured.stderr };
}

const count = async (table: string): Promise<number> =>
  (await one<{ n: number }>(pg, `select count(*)::int as n from ${table} where company_id = $1`, [companyId])).n;

beforeAll(async () => {
  schema = JSON.parse(await readFile(join(repoRoot, 'packages', 'cli', 'schema', 'output.1.json'), 'utf8')) as Row;
  pg = await freshDatabase();
  owner = await newUser(pg, 'owner@example.test');
  viewer = await newUser(pg, 'viewer@example.test');
  companyId = (await newCompany(pg, { country: HOME, name: 'Example One', ownerId: owner })).companyId;
  otherCompanyId = (await newCompany(pg, { country: HOME, name: 'Example Two', ownerId: owner })).companyId;
  await pg.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [companyId, viewer]);
  // A bank account on whatever the pack's chart calls cash, through whatever it calls the bank book.
  bankAccountId = (
    await one<{ id: string }>(
      pg,
      `insert into bank_accounts (company_id, name, currency_code, account_id, journal_id)
       select c.id, 'Bank', c.currency_code,
              (select id from accounts where company_id = c.id and account_type = 'asset_cash' order by code limit 1),
              (select id from journals where company_id = c.id and journal_type = 'bank' order by code limit 1)
         from companies c where c.id = $1
       returning id`,
      [companyId],
    )
  ).id;

  root = await mkdtemp(join(tmpdir(), 'ekwo-books-'));
  instance = fakeSupabase(pg);
  instance.addUser(owner, 'owner@example.test', PASSWORD);
  instance.addUser(viewer, 'viewer@example.test', PASSWORD);
  for (const who of ['owner', 'viewer'] as const) {
    const signedIn = await ekwo(
      ['login', '--supabase-url', FAKE_URL, '--anon-key', ANON_KEY, '--email', `${who}@example.test`, '--password', PASSWORD],
      { as: who },
    );
    expect(signedIn.exitCode).toBe(0);
  }
});

afterAll(async () => {
  await pg.close();
  await rm(root, { recursive: true, force: true });
});

describe('before a company is in use', () => {
  it('no verb picks one: it is a wrong call, and the document says the company is null', async () => {
    const answer = await ekwo(['doc', 'list']);
    expect(answer.exitCode).toBe(EXIT_USAGE);
    expect(answer.error?.name).toBe('no_company');
    expect(answer.context).toMatchObject({ company: null });
    // --company is enough for one command.
    const once = await ekwo(['doc', 'list', '--company', 'Example One']);
    expect(once.exitCode).toBe(0);
    expect(once.context?.company).toEqual({ id: companyId, name: 'Example One' });
  });
});

describe('the verbs', () => {
  let contactId: string;
  let documentId: string;
  let rehearsed: Row;

  beforeAll(async () => {
    expect((await ekwo(['use', 'Example One'])).exitCode).toBe(0);
    expect((await ekwo(['use', 'Example One'], { as: 'viewer' })).exitCode).toBe(0);
  });

  it('contact add creates one contact, and the same --ref a second time creates none', async () => {
    const created = await ekwo(['contact', 'add', 'Client Example', '--country', HOME, '--email', 'ap@client.example.test', '--ref', 'crm-42']);
    expect(created.exitCode).toBe(0);
    expect(created.context?.company?.id).toBe(companyId);
    const contact = (created.data as { contact: Row }).contact;
    contactId = contact['id'] as string;
    expect(contact).toMatchObject({ name: 'Client Example', client_ref: 'crm-42' });
    expect((await one<Row>(pg, `select company_id from contacts where id = $1`, [contactId]))['company_id']).toBe(companyId);
    expect((created.data as Row)['replayed']).toBeUndefined();

    const again = await ekwo(['contact', 'add', 'Client Example', '--country', HOME, '--ref', 'crm-42']);
    expect(again.data).toMatchObject({ replayed: true, contact: { id: contactId } });
    expect(await count('contacts')).toBe(1);

    const listed = await ekwo(['contact', 'list', '--query', 'client']);
    expect((listed.data as { contacts: Row[] }).contacts.map((c) => c['id'])).toEqual([contactId]);
  });

  it('reads a JSON document on the standard input, and refuses a field nobody defined', async () => {
    const created = await ekwo(['contact', 'add', '--stdin'], { stdin: { name: 'Supplier "Quoted", Ltd', contact_type: 'supplier' } });
    expect((created.data as { contact: Row }).contact).toMatchObject({ name: 'Supplier "Quoted", Ltd', contact_type: 'supplier' });

    const typo = await ekwo(['contact', 'add', '--stdin'], { stdin: { name: 'Typo', vat_numbr: 'X' } });
    expect(typo.exitCode).toBe(EXIT_USAGE);
    expect(typo.error?.name).toBe('unknown_field');
    expect(await count('contacts')).toBe(2);
  });

  it('doc new writes a draft whose totals are the database\'s', async () => {
    const created = await ekwo([
      'doc', 'new', '--contact', 'client', '--date', '2026-06-15', '--ref', 'job-7',
      '--line', `name=Audit\\, first half,price=1500.00,account=${SALES}`,
    ]);
    expect(created.exitCode).toBe(0);
    const document = (created.data as { document: Row }).document;
    documentId = document['id'] as string;
    const held = await one<Row>(
      pg,
      `select state, amount_untaxed::text, amount_tax::text, amount_total::text, currency_code, contact_id from documents where id = $1`,
      [documentId],
    );
    expect(document).toMatchObject({ doc_type: 'sale_invoice', document_date: '2026-06-15', client_ref: 'job-7', ...held });
    expect(held['state']).toBe('draft');
    expect(held['contact_id']).toBe(contactId);
    expect(typeof document['amount_total']).toBe('string');
    const line = await one<Row>(pg, `select name, unit_price::text as unit_price from document_lines where document_id = $1`, [documentId]);
    expect(line['name']).toBe('Audit, first half');
    expect((created.data as { lines: Row[] }).lines[0]).toMatchObject(line);
  });

  it('creates once under one --ref, and finishes a creation a dropped connection cut in two', async () => {
    const before = await count('documents');
    const again = await ekwo(['doc', 'new', '--contact', contactId, '--date', '2026-06-15', '--ref', 'job-7', '--line', `name=Audit,price=1500.00,account=${SALES}`]);
    expect(again.data).toMatchObject({ replayed: true, document: { id: documentId } });
    expect(await count('documents')).toBe(before);
    expect((again.data as { lines: Row[] }).lines).toHaveLength(1);

    // The header went in and the lines did not: what a cut between the two inserts leaves.
    const half = await one<{ id: string }>(
      pg,
      `insert into documents (company_id, doc_type, contact_id, document_date, currency_code, client_ref)
       select $1, 'sale_invoice', $2, date '2026-06-16', currency_code, 'job-8' from companies where id = $1 returning id`,
      [companyId, contactId],
    );
    const finished = await ekwo(['doc', 'new', '--stdin'], {
      stdin: { contact_id: contactId, document_date: '2026-06-16', client_ref: 'job-8', lines: [{ name: 'Review', unit_price: '200.00', account_code: SALES }] },
    });
    expect(finished.data).toMatchObject({ replayed: true, document: { id: half.id } });
    expect((finished.data as { lines: Row[] }).lines).toHaveLength(1);
    expect(await count('documents')).toBe(before + 1);
  });

  it('doc line add puts one more line at the end, found by the reference of the draft', async () => {
    const added = await ekwo(['doc', 'line', 'add', 'job-7', '--name', 'Travel', '--amount', '250.00', '--account', SALES]);
    expect(added.command).toBe('doc line add');
    const lines = (added.data as { lines: Row[] }).lines;
    expect(lines.map((l) => l['name'])).toEqual(['Audit, first half', 'Travel']);
    const held = await one<{ total: string }>(pg, `select amount_total::text as total from documents where id = $1`, [documentId]);
    expect((added.data as { document: Row }).document['amount_total']).toBe(held.total);
  });

  it('ekwo invoice is an alias of ekwo doc, and creates exactly the same draft', async () => {
    const lineFlag = `name=Alias,price=400.00,account=${SALES}`;
    const underDoc = await ekwo(['doc', 'new', '--contact', contactId, '--date', '2026-06-20', '--ref', 'alias-doc', '--line', lineFlag]);
    const underInvoice = await ekwo(['invoice', 'new', '--contact', contactId, '--date', '2026-06-20', '--ref', 'alias-invoice', '--line', lineFlag]);

    expect(underDoc.exitCode).toBe(0);
    expect(underInvoice.exitCode).toBe(0);
    // The label repeats the words that were typed; everything else matches.
    expect(underDoc.command).toBe('doc new');
    expect(underInvoice.command).toBe('invoice new');

    const shapeOf = (answer: OutputDocument): Row => {
      const document = (answer.data as { document: Row }).document;
      const { id, number, client_ref: _ref, created_at, updated_at, ...rest } = document;
      return rest;
    };
    expect(shapeOf(underInvoice)).toEqual(shapeOf(underDoc));

    // And the totals the database wrote are the same on both.
    const totals = await rows<{ total: string }>(
      pg,
      `select amount_total::text as total from documents where client_ref in ('alias-doc', 'alias-invoice') order by client_ref`,
    );
    expect(totals).toHaveLength(2);
    expect(totals[0]!.total).toBe(totals[1]!.total);
  });

  it('refuses an account that does not exist with code 2, before anything is written', async () => {
    const before = await count('documents');
    const answer = await ekwo(['doc', 'new', '--contact', contactId, '--line', 'name=Wrong,price=10.00,account=no-such-account']);
    expect(answer.exitCode).toBe(EXIT_USAGE);
    expect(answer.error).toMatchObject({ kind: 'usage', name: 'unknown_account_code' });
    expect(await count('documents')).toBe(before);

    const malformed = await ekwo(['doc', 'new', '--contact', contactId, '--line', 'Audit 1 500 @21']);
    expect(malformed.exitCode).toBe(EXIT_USAGE);
    expect(malformed.error?.name).toBe('bad_line');
  });

  it('post --dry-run shows the entry posting would write, and writes nothing', async () => {
    const entriesBefore = await count('entries');
    const answer = await ekwo(['post', documentId, '--dry-run']);
    expect(answer.exitCode).toBe(0);
    rehearsed = answer.data as Row;
    expect(rehearsed['dry_run']).toBe(true);
    expect((rehearsed['entry_lines'] as Row[]).length).toBeGreaterThanOrEqual(2);
    expect(await count('entries')).toBe(entriesBefore);
    expect((await one<Row>(pg, `select state, entry_id, number from documents where id = $1`, [documentId]))).toEqual({
      state: 'draft',
      entry_id: null,
      number: null,
    });
  });

  it('post writes that entry, line for line and under that number', async () => {
    const answer = await ekwo(['post', documentId]);
    expect(answer.exitCode).toBe(0);
    const entry = (answer.data as { entry: Row }).entry;
    const written = await rows<Row>(
      pg,
      `select a.code as account_code, l.debit::text as debit, l.credit::text as credit
         from entry_lines l join accounts a on a.id = l.account_id where l.entry_id = $1 order by l.sequence`,
      [entry['id']],
    );
    expect((rehearsed['entry_lines'] as Row[]).map((l) => ({ account_code: l['account_code'], debit: l['debit'], credit: l['credit'] }))).toEqual(written);
    expect((rehearsed['entry'] as Row)['number']).toBe(entry['number']);
    expect((answer.data as { entry_lines: Row[] }).entry_lines.map((l) => l['debit'])).toEqual(written.map((l) => l['debit']));
  });

  it('a locked period is exit code 3, word for word — posting for real and rehearsing alike', async () => {
    const locked = await ekwo(['doc', 'new', '--contact', contactId, '--date', '2026-03-15', '--ref', 'locked', '--line', `name=Late,price=100.00,account=${SALES}`]);
    const lockedId = (locked.data as { document: Row }).document['id'] as string;
    await pg.query(`update companies set lock_date = date '2026-03-31' where id = $1`, [companyId]);
    try {
      const said = await expectError(pg, 'select post_document($1)', [lockedId]);
      expect(said).toMatch(/^period_locked:/);
      for (const argv of [['post', 'locked'], ['post', 'locked', '--dry-run']]) {
        const refused = await ekwo(argv);
        expect(refused.exitCode).toBe(EXIT_REFUSED);
        expect(refused.error).toMatchObject({ kind: 'refusal', name: 'period_locked', message: said });
        expect(refused.error?.sqlstate).toMatch(/^[0-9A-Z]{5}$/);
        expect(refused.stderr).toContain(said);
        // The refusal names the company it was given for.
        expect(refused.context?.company?.id).toBe(companyId);
      }
      // No date was moved and nothing was posted to get there.
      expect(await one<Row>(pg, `select document_date::text as d, state from documents where id = $1`, [lockedId])).toEqual({ d: '2026-03-15', state: 'draft' });
    } finally {
      await pg.query(`update companies set lock_date = null where id = $1`, [companyId]);
    }
  });

  it('a person who may only read is refused by the policy, and that is code 3 too', async () => {
    const before = await count('contacts');
    const refused = await ekwo(['contact', 'add', 'Not Allowed'], { as: 'viewer' });
    expect(refused.exitCode).toBe(EXIT_REFUSED);
    expect(refused.error).toMatchObject({ kind: 'refusal', sqlstate: '42501' });
    expect(await count('contacts')).toBe(before);
    // Reading is theirs.
    expect((await ekwo(['doc', 'list'], { as: 'viewer' })).exitCode).toBe(0);
  });

  it('doc list --unpaid is what is posted and still owed', async () => {
    const unpaid = await ekwo(['doc', 'list', '--unpaid', '--since', '2026-06-01']);
    expect((unpaid.data as { documents: Row[] }).documents.map((d) => d['id'])).toEqual([documentId]);
    const early = await ekwo(['doc', 'list', '--unpaid', '--until', '2026-05-31']);
    expect((early.data as { documents: Row[] }).documents).toEqual([]);
    const shown = await ekwo(['doc', 'show', documentId]);
    expect((shown.data as { entry: Row }).entry['id']).toBeTruthy();
  });

  it('payment record --doc reads who and which way off the open item, and settles that document', async () => {
    const owed = await one<{ total: string }>(pg, `select amount_total::text as total from documents where id = $1`, [documentId]);
    const paid = await ekwo(['payment', 'record', '--doc', documentId, '--amount', owed.total, '--date', '2026-06-30', '--bank-account', bankAccountId, '--ref', 'bank-1']);
    expect(paid.exitCode).toBe(0);
    expect((paid.data as { payment: Row }).payment).toMatchObject({ direction: 'inbound', contact_id: contactId, amount: owed.total, client_ref: 'bank-1' });
    expect((paid.data as { matched: Row[] }).matched).toHaveLength(1);
    expect(await one<Row>(pg, `select payment_state, amount_residual::text as open from documents where id = $1`, [documentId])).toEqual({
      payment_state: 'paid',
      open: (await one<{ z: string }>(pg, `select 0::numeric(16,2)::text as z`)).z,
    });

    const again = await ekwo(['payment', 'record', '--doc', documentId, '--amount', owed.total, '--date', '2026-06-30', '--bank-account', bankAccountId, '--ref', 'bank-1']);
    // The same reference: the first payment is the answer, though nothing is open any more.
    expect(again.data).toMatchObject({ replayed: true, payment: { id: (paid.data as { payment: Row }).payment['id'] } });
    expect(await count('payments')).toBe(1);

    // Another reference would be another payment, and there is nothing left to pay.
    const other = await ekwo(['payment', 'record', '--doc', documentId, '--amount', owed.total, '--bank-account', bankAccountId, '--ref', 'bank-1b']);
    expect(other.exitCode).toBe(EXIT_USAGE);
    expect(other.error?.name).toBe('nothing_open');
    expect(await count('payments')).toBe(1);
  });

  it('records once under one --ref', async () => {
    const first = await ekwo(['payment', 'record', '--contact', contactId, '--direction', 'inbound', '--amount', '10.00', '--date', '2026-06-30', '--bank-account', bankAccountId, '--ref', 'bank-2', '--no-match']);
    expect(first.exitCode).toBe(0);
    const again = await ekwo(['payment', 'record', '--contact', contactId, '--direction', 'inbound', '--amount', '10.00', '--date', '2026-06-30', '--bank-account', bankAccountId, '--ref', 'bank-2', '--no-match']);
    expect(again.data).toMatchObject({ replayed: true, payment: { id: (first.data as { payment: Row }).payment['id'] } });
    expect(await count('payments')).toBe(2);
    expect(await count('entries')).toBe(3);
  });

  it('match settles a statement line against a document, through settle_from_statement()', async () => {
    await ekwo(['doc', 'new', '--contact', contactId, '--date', '2026-07-01', '--ref', 'job-9', '--line', `name=Retainer,price=300.00,account=${SALES}`]);
    const posted = await ekwo(['post', 'job-9']);
    expect(posted.exitCode).toBe(0);
    const invoice = await one<{ id: string; total: string }>(pg, `select id, amount_total::text as total from documents where client_ref = 'job-9'`);
    const statementLine = await one<{ id: string }>(
      pg,
      `insert into bank_transactions (company_id, bank_account_id, transaction_date, amount, currency_code)
       select $1, $2, date '2026-07-05', $3::numeric, currency_code from companies where id = $1 returning id`,
      [companyId, bankAccountId, invoice.total],
    );
    const matched = await ekwo(['match', statementLine.id, 'job-9']);
    expect(matched.exitCode).toBe(0);
    expect((matched.data as { transaction: Row }).transaction).toMatchObject({ id: statementLine.id, state: 'reconciled', amount: invoice.total });
    expect((await one<Row>(pg, `select payment_state from documents where id = $1`, [invoice.id]))['payment_state']).toBe('paid');

      // A second time there is nothing open on the document to settle.
    const twice = await ekwo(['match', statementLine.id, 'job-9']);
    expect(twice.exitCode).toBe(EXIT_USAGE);
    expect(twice.error?.name).toBe('nothing_open');
  });

  it('cancel undoes a posted invoice with the credit note that names it; a paid one is code 3', async () => {
    await ekwo(['doc', 'new', '--contact', contactId, '--date', '2026-07-10', '--ref', 'job-10', '--line', `name=Mistake,price=120.00,account=${SALES}`]);
    await ekwo(['post', 'job-10']);
    const invoice = await one<{ id: string; number: string }>(pg, `select id, number from documents where client_ref = 'job-10'`);

    const cancelled = await ekwo(['cancel', 'job-10']);
    expect(cancelled.exitCode).toBe(0);
    expect(cancelled.command).toBe('cancel');
    const data = cancelled.data as { undone_by: string; why: string; cancelled: Row; credit_note: Row };
    // The country of this company keeps a posted document as it was posted —
    // or says nothing, which reads the same — so the choice was the credit
    // note, and the answer says so and why.
    expect(data.undone_by).toBe('credit_note');
    expect(data.why).toMatch(/^posted_edit_reversal_only\b/);
    expect(data.cancelled).toMatchObject({ id: invoice.id, number: invoice.number, state: 'cancelled', payment_state: 'reversed' });
    expect(data.credit_note).toMatchObject({ reversed_document_id: invoice.id, state: 'posted', document_date: '2026-07-10' });

    const twice = await ekwo(['cancel', invoice.number]);
    expect(twice.exitCode).toBe(EXIT_REFUSED);
    expect(twice.error).toMatchObject({ kind: 'refusal', name: 'document_already_cancelled' });

    // Paid: the payment is unmatched first, by whoever decides it.
    const paid = await ekwo(['cancel', documentId]);
    expect(paid.exitCode).toBe(EXIT_REFUSED);
    expect(paid.error?.name).toBe('document_paid');
    expect((await one<Row>(pg, `select state from documents where id = $1`, [documentId]))['state']).toBe('posted');
  });

  it('cancel puts the invoice back to draft where the country allows it, and says so; --credit asks for the note', async () => {
    // The policy is stated here, for this database only: the test is about the
    // choice, not about which country allows it.
    const before = await one<{ policy: string | null }>(pg, `select posted_edit_policy as policy from country_defaults where country = $1`, [HOME]);
    await pg.query(`update country_defaults set posted_edit_policy = 'unpost_if_untouched' where country = $1`, [HOME]);
    try {
      await ekwo(['doc', 'new', '--contact', contactId, '--date', '2026-07-11', '--ref', 'job-11', '--line', `name=Typo,price=90.00,account=${SALES}`]);
      await ekwo(['post', 'job-11']);
      const posted = await one<{ id: string; number: string; entry_id: string }>(pg, `select id, number, entry_id from documents where client_ref = 'job-11'`);

      const undone = await ekwo(['cancel', 'job-11']);
      expect(undone.exitCode).toBe(0);
      const data = undone.data as { undone_by: string; why: unknown; draft: Row; unposting: Row };
      expect(data.undone_by).toBe('draft');
      expect(data.why).toBeNull();
      expect(data.draft).toMatchObject({ id: posted.id, state: 'draft', number: null, entry_id: null });
      expect(data.unposting).toMatchObject({ entry_id: posted.entry_id, entry_number: posted.number, number_returned: true });
      expect(await rows(pg, `select 1 from entries where id = $1`, [posted.entry_id])).toEqual([]);

      // Posted again, the same number; and this time the credit note is asked for.
      await ekwo(['post', 'job-11']);
      expect((await one<Row>(pg, `select number from documents where id = $1`, [posted.id]))['number']).toBe(posted.number);
      const noted = await ekwo(['cancel', 'job-11', '--credit']);
      expect(noted.exitCode).toBe(0);
      expect(noted.data).toMatchObject({ undone_by: 'credit_note', why: 'A credit note was asked for.' });
      expect((await one<Row>(pg, `select state from documents where id = $1`, [posted.id]))['state']).toBe('cancelled');

      // The text a person reads names the way it took.
      await ekwo(['doc', 'new', '--contact', contactId, '--date', '2026-07-11', '--ref', 'job-12', '--line', `name=Typo,price=45.00,account=${SALES}`]);
      await ekwo(['post', 'job-12']);
      const human = await capture(() => run(['cancel', 'job-12'], { fetchImpl: instance.fetchImpl, env: { EKWO_CONFIG_DIR: join(root, 'owner') } }));
      expect(human.exitCode).toBe(0);
      expect(human.stdout).toMatch(/Back to draft/);
    } finally {
      await pg.query(`update country_defaults set posted_edit_policy = $2 where country = $1`, [HOME, before.policy]);
    }
  });

  it('reverse undoes an entry by its number, and asks for a date the locked period cannot give', async () => {
    const keyed = await one<{ id: string }>(
      pg,
      `insert into entries (company_id, journal_id, entry_date, description)
       select id, miscellaneous_journal_id, date '2026-07-12', 'By hand' from companies where id = $1 returning id`,
      [companyId],
    );
    await pg.query(
      `insert into entry_lines (entry_id, company_id, account_id, sequence, debit, credit)
       values ($1, $2, $3, 10, 40, 0), ($1, $2, account_id_by_code($2, $4), 20, 0, 40)`,
      [keyed.id, companyId, (await one<{ id: string }>(pg, `select account_id as id from bank_accounts where id = $1`, [bankAccountId])).id, SALES],
    );
    const number = (await one<{ number: string }>(pg, `select number from post_entry($1)`, [keyed.id])).number;

    await pg.query(`update companies set lock_date = date '2026-07-31' where id = $1`, [companyId]);
    try {
      const needed = await ekwo(['reverse', number]);
      expect(needed.exitCode).toBe(EXIT_REFUSED);
      expect(needed.error?.name).toBe('reversal_date_needed');
    } finally {
      await pg.query(`update companies set lock_date = null where id = $1`, [companyId]);
    }

    const reversed = await ekwo(['reverse', number, '--date', '2026-08-01']);
    expect(reversed.exitCode).toBe(0);
    expect(reversed.command).toBe('reverse');
    expect((reversed.data as { entry: Row }).entry).toMatchObject({ reversed_entry_id: keyed.id, entry_date: '2026-08-01', state: 'posted' });

    // An entry a document wrote is undone with the document.
    const ofInvoice = await one<{ number: string }>(pg, `select e.number from entries e join documents d on d.entry_id = e.id where d.id = $1`, [documentId]);
    const refused = await ekwo(['reverse', ofInvoice.number]);
    expect(refused.exitCode).toBe(EXIT_REFUSED);
    expect(refused.error?.name).toBe('entry_of_a_document');
  });

  it('never reaches a company its answer does not name', async () => {
    const elsewhere = await ekwo(['doc', 'list', '--company', 'Example Two']);
    expect(elsewhere.context?.company).toEqual({ id: otherCompanyId, name: 'Example Two' });
    expect((elsewhere.data as { documents: Row[] }).documents).toEqual([]);
  });
});
