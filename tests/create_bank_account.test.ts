/**
 * A bank account is created by `create_bank_account()`, under the rights of
 * the person who asks.
 *
 * Every call here runs as a member of the company — `backendFor` sets the role
 * and the claims — so what is checked is what a web application calling the
 * REST API gets: the identifier read in the scheme of the country's pack, the
 * journal and the ledger account the country template chose, the journal
 * pointing back, the same answer for the same account however it is spelled,
 * and each refusal by its name.
 *
 * Setting up books in a pack whose banks use an IBAN; the identifiers are
 * built for that pack's country and pass their check digits, they are not
 * accounts.
 */

import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { Backend, Row } from '../packages/mcp/src/index.js';
import { freshDatabase, rows } from './helpers/db.js';
import { newCompany, type Fixture } from './helpers/factory.js';
import { packWhere } from './helpers/packs.js';
import { backendFor, record } from './mcp/helpers.js';

const pack = packWhere('whose banks identify an account by IBAN', (p) => p.documents.bank_account_scheme === 'iban');
const country = pack.manifest.country;

/** An IBAN of the pack's country around a national number, with the check digits it needs. */
function ibanOf(national: string): string {
  const digits = [...`${national}${country}00`]
    .map((char) => (char >= 'A' ? String(char.charCodeAt(0) - 55) : char))
    .join('');
  let remainder = 0;
  for (const digit of digits) remainder = (remainder * 10 + Number(digit)) % 97;
  return `${country}${String(98 - remainder).padStart(2, '0')}${national}`;
}

const FIRST = ibanOf('000123456789');
const SECOND = ibanOf('000987654321');

let db: PGlite;
let company: Fixture;
let owner: Backend;
let viewer: Backend;
let stranger: Backend;

async function create(backend: Backend, args: Record<string, unknown>): Promise<Record<string, unknown>> {
  const [answer] = await backend.rpc<Row>('create_bank_account', { p_company_id: company.companyId, ...args });
  return record(answer);
}

beforeAll(async () => {
  db = await freshDatabase();
  company = await newCompany(db, { country, name: 'Example Bank Test' });
  const viewerId = crypto.randomUUID();
  await db.query(`insert into company_members (company_id, user_id, role) values ($1, $2, 'viewer')`, [
    company.companyId,
    viewerId,
  ]);
  owner = backendFor(db, company.ownerId);
  viewer = backendFor(db, viewerId);
  stranger = backendFor(db, (await newCompany(db, { country, name: 'Example Other' })).ownerId);
});

afterAll(async () => {
  await db.close();
});

describe('create_bank_account()', () => {
  it('reads the identifier in the scheme of the pack and wires the journal the template chose', async () => {
    const spelled = `${FIRST.slice(0, 4).toLowerCase()} ${FIRST.slice(4, 8)}-${FIRST.slice(8)}`;
    const answer = await create(owner, { p_account_identifier: spelled, p_bank_name: 'Example Bank' });
    expect(answer['created']).toBe(true);

    const account = record(answer['bank_account']);
    expect(account).toMatchObject({
      account_identifier: FIRST,
      account_scheme: 'iban',
      iban: FIRST,
      name: 'Example Bank',
      bank_name: 'Example Bank',
    });

    const [expected] = await rows<{ journal_id: string; code: string; default_account_id: string; currency_code: string }>(
      db,
      `select j.id as journal_id, j.code, j.default_account_id, c.currency_code
         from journals j join companies c on c.id = j.company_id
        where j.company_id = $1 and j.journal_type = 'bank' and j.active
        order by j.code limit 1`,
      [company.companyId],
    );
    expect(account['journal_id']).toBe(expected?.journal_id);
    expect(account['account_id']).toBe(expected?.default_account_id);
    expect(account['currency_code']).toBe(expected?.currency_code);
    expect(record(answer['journal'])['code']).toBe(expected?.code);

    const [journal] = await rows<{ bank_account_id: string }>(db, 'select bank_account_id from journals where id = $1', [
      expected?.journal_id,
    ]);
    expect(journal?.bank_account_id).toBe(account['id']);
  });

  it('answers the account that exists for the same identifier, however it is spelled', async () => {
    const again = await create(owner, { p_account_identifier: FIRST.toLowerCase(), p_name: 'Another name' });
    expect(again['created']).toBe(false);
    expect(record(again['bank_account'])['name']).toBe('Example Bank');
    expect(await rows(db, 'select id from bank_accounts where company_id = $1', [company.companyId])).toHaveLength(1);
  });

  it('refuses a second account under the name of the first', async () => {
    await expect(create(owner, { p_account_identifier: SECOND, p_name: 'example bank' })).rejects.toThrow(
      /bank_account_exists/,
    );
  });

  it('creates a second account under a name of its own, and leaves the journal pointing at the first', async () => {
    const first = await rows<{ id: string }>(db, 'select id from bank_accounts where account_identifier = $1', [FIRST]);
    const answer = await create(owner, { p_account_identifier: SECOND, p_name: 'Savings' });
    expect(answer['created']).toBe(true);
    const journalId = record(answer['bank_account'])['journal_id'];
    const [journal] = await rows<{ bank_account_id: string }>(db, 'select bank_account_id from journals where id = $1', [
      journalId,
    ]);
    expect(journal?.bank_account_id).toBe(first[0]?.id);
  });

  it('refuses an identifier that is missing or does not add up', async () => {
    await expect(create(owner, { p_account_identifier: '  ' })).rejects.toThrow(/missing_account_identifier/);
    const wrong = FIRST.slice(0, -1) + (FIRST.endsWith('9') ? '8' : '9');
    await expect(create(owner, { p_account_identifier: wrong })).rejects.toThrow(/invalid_bank_account/);
  });

  it('refuses a journal that is not a bank or a cash journal', async () => {
    const [sales] = await rows<{ id: string }>(
      db,
      `select id from journals where company_id = $1 and journal_type = 'sales' limit 1`,
      [company.companyId],
    );
    await expect(
      create(owner, { p_account_identifier: ibanOf('000555555555'), p_name: 'Wrong journal', p_journal_id: sales?.id }),
    ).rejects.toThrow(/not_a_bank_journal/);
  });

  it('says not_allowed to a member without bank.write, and unknown_company to a stranger', async () => {
    await expect(create(viewer, { p_account_identifier: ibanOf('000666666666') })).rejects.toThrow(
      /not_allowed.*bank\.write/,
    );
    await expect(create(stranger, { p_account_identifier: ibanOf('000777777777') })).rejects.toThrow(/unknown_company/);
    expect(await rows(db, 'select id from bank_accounts where company_id = $1', [company.companyId])).toHaveLength(2);
  });
});
