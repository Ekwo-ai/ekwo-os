/**
 * The first minutes of an agent with this server, as a client meets them.
 *
 * An agent reads the instructions of the handshake before it calls anything,
 * and then reads the descriptions of the tools to decide what to call next.
 * Both name tools in prose, and prose is where a renamed tool goes stale
 * without anything failing. So every tool, prompt and refusal named in the
 * instructions is checked against what this server actually offers, and the
 * path of a first session — company, settings, codes, contact, draft, post —
 * is checked link by link in the descriptions.
 *
 * The invitation to register is checked here too: one line in the
 * instructions and one field of `status`, only where the server was started to
 * give it, and never otherwise.
 */

import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  BooksError,
  NO_SUCH_COMPANY,
  REGISTER_INVITE_ENV,
  companyCurrency,
  REGISTRATION_INVITATION,
  registerInviteSilenced,
  registrationInvitation,
  relayableInvitation,
} from '../../packages/core/src/index.js';
import {
  INSTRUCTIONS,
  buildServer,
  explain,
  instructionsFor,
  shouldInviteToRegister,
  type Backend,
  type ServerOptions,
} from '../../packages/mcp/src/index.js';
import { freshDatabase } from '../helpers/db.js';
import { newCompany, type Fixture } from '../helpers/factory.js';
import { somePack } from '../helpers/packs.js';
import { backendFor } from './helpers.js';

let db: PGlite;
let fx: Fixture;
let backend: Backend;
const clients: Client[] = [];

async function connect(options: ServerOptions = {}): Promise<Client> {
  const server = buildServer(backend, options);
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  const client = new Client({ name: 'first-session', version: '0.0.0' });
  await Promise.all([client.connect(clientTransport), server.connect(serverTransport)]);
  clients.push(client);
  return client;
}

beforeAll(async () => {
  db = await freshDatabase();
  fx = await newCompany(db, { country: somePack.manifest.country, name: 'First Session Ltd' });
  backend = backendFor(db, fx.ownerId);
});

afterAll(async () => {
  for (const client of clients) await client.close();
  await db.close();
});

/** Words written like a tool name: lower case, joined by underscores. */
function snakeWords(text: string): string[] {
  return [...new Set(text.match(/\b[a-z]+(?:_[a-z]+)+\b/g) ?? [])];
}

describe('the instructions of the handshake', () => {
  it('are what a client receives', async () => {
    const client = await connect();
    expect(client.getInstructions()).toBe(INSTRUCTIONS);
  });

  it('name only tools, prompts, arguments and refusals that exist', async () => {
    const client = await connect();
    const { tools } = await client.listTools();
    const { prompts } = await client.listPrompts();
    const toolNames = new Set(tools.map((tool) => tool.name));
    const promptNames = new Set(prompts.map((prompt) => prompt.name));
    const argumentNames = new Set(
      tools.flatMap((tool) => Object.keys((tool.inputSchema.properties ?? {}) as Record<string, unknown>)),
    );

    const unknown = snakeWords(INSTRUCTIONS).filter(
      (word) =>
        !toolNames.has(word) &&
        !promptNames.has(word) &&
        !argumentNames.has(word) &&
        // A refusal is named so the agent knows its sentence comes with it.
        explain(`${word}: x`).hint === undefined,
    );
    expect(unknown).toEqual([]);
  });

  it('give a first session in order, from the company to the posting', () => {
    const order = ['list_companies', 'get_company', 'list_accounts', 'search_contacts', 'create_document', 'post_document'];
    const positions = order.map((name) => INSTRUCTIONS.indexOf(name));
    for (const position of positions) expect(position).toBeGreaterThanOrEqual(0);
    expect([...positions].sort((a, b) => a - b)).toEqual(positions);
  });

  it('say how to read a tax return and how to correct what is posted', () => {
    expect(INSTRUCTIONS).toContain('vat_return');
    expect(INSTRUCTIONS).toContain('prepare_vat_return');
    expect(INSTRUCTIONS).toContain('cancel_document');
    expect(INSTRUCTIONS).toContain('reverse_entry');
    expect(INSTRUCTIONS).toContain('files nothing');
  });

  it('name refusals that each come with what to do next', () => {
    for (const refusal of ['period_locked', 'entry_unbalanced', 'document_total_mismatch', 'reversal_date_needed']) {
      expect(INSTRUCTIONS).toContain(refusal);
      expect(explain(`${refusal}: x`).hint, refusal).toBeDefined();
    }
  });

  it('carry no invitation unless the server was started to give one', () => {
    expect(INSTRUCTIONS).not.toContain('register');
    expect(instructionsFor({ inviteToRegister: false })).toBe(INSTRUCTIONS);
  });
});

describe('the descriptions, read as a path', () => {
  // Each tool of a first session says what to call after it.
  const NEXT: Record<string, string[]> = {
    list_companies: ['get_company'],
    get_company: ['list_accounts'],
    search_contacts: ['create_contact', 'create_document'],
    create_contact: ['create_document'],
    create_document: ['post_document', 'update_document_lines'],
    post_document: ['get_document', 'record_payment', 'cancel_document'],
  };

  it('point each step at the next one, and the next one exists', async () => {
    const client = await connect();
    const { tools } = await client.listTools();
    const byName = new Map(tools.map((tool) => [tool.name, tool.description ?? '']));
    for (const [tool, nexts] of Object.entries(NEXT)) {
      expect(byName.has(tool), tool).toBe(true);
      for (const next of nexts) {
        expect(byName.get(tool), `${tool} → ${next}`).toContain(next);
        expect(byName.has(next), next).toBe(true);
      }
    }
  });
});

describe('a refusal of the core names what to call instead', () => {
  it('for a company nobody can see, on the command line and here alike', async () => {
    const nobody = '00000000-0000-4000-8000-000000000000';
    const refused = await companyCurrency(backend, nobody).catch((error: unknown) => error);
    expect(refused).toBeInstanceOf(BooksError);
    expect((refused as BooksError).message).toMatch(/^not_found: company/);
    expect((refused as BooksError).hint).toBe(NO_SUCH_COMPANY);
    expect(NO_SUCH_COMPANY).toContain('list_companies');
  });
});

describe('the invitation to register', () => {
  it('is silenced by its variable, and by nothing else', () => {
    expect(registerInviteSilenced({})).toBe(false);
    expect(registerInviteSilenced({ [REGISTER_INVITE_ENV]: '' })).toBe(false);
    expect(registerInviteSilenced({ [REGISTER_INVITE_ENV]: '0' })).toBe(false);
    expect(registerInviteSilenced({ [REGISTER_INVITE_ENV]: 'false' })).toBe(false);
    expect(registerInviteSilenced({ [REGISTER_INVITE_ENV]: '1' })).toBe(true);
    expect(registerInviteSilenced({ [REGISTER_INVITE_ENV]: 'yes' })).toBe(true);
  });

  it('is given only to an installation that is not registered', () => {
    expect(registrationInvitation(null, {})).toBe(REGISTRATION_INVITATION);
    expect(registrationInvitation('2026-10-05', {})).toBeNull();
    expect(registrationInvitation(undefined, {})).toBeNull();
    expect(registrationInvitation(null, { [REGISTER_INVITE_ENV]: '1' })).toBeNull();
  });

  it('says what it gives, what it sends, the command and how to silence it', () => {
    const invitation = REGISTRATION_INVITATION;
    expect(invitation.gives.length).toBeGreaterThan(0);
    expect(invitation.command).toContain('register --email');
    expect(invitation.sends).toContain('No ledger data');
    expect(invitation.silence).toContain(REGISTER_INVITE_ENV);
    expect(invitation.text).toMatch(/optional/);
  });

  it('is one paragraph of the instructions when the server is started to give it', async () => {
    const client = await connect({ inviteToRegister: true });
    const instructions = client.getInstructions() ?? '';
    expect(instructions.startsWith(INSTRUCTIONS)).toBe(true);
    expect(instructions.slice(INSTRUCTIONS.length).trim()).toBe(relayableInvitation());
    expect(instructions.match(/register --email/g)).toHaveLength(1);
    expect(relayableInvitation()).toContain('once');
  });

  it('is a field of status, null unless the server was started to give it', async () => {
    const read = async (client: Client): Promise<{ registered: boolean | null; invitation: unknown }> => {
      const result = await client.callTool({ name: 'status', arguments: {} });
      const payload = JSON.parse((result.content as { text: string }[])[0]?.text ?? '{}') as {
        registration: { registered: boolean | null; invitation: unknown };
      };
      return payload.registration;
    };
    const quiet = await read(await connect());
    expect(quiet.invitation).toBeNull();

    // A fresh installation is not registered, and its members may read that.
    const inviting = await read(await connect({ inviteToRegister: true }));
    expect(inviting).toEqual({ registered: false, invitation: REGISTRATION_INVITATION });
  });

  it('is decided at start from the instance row and the environment', async () => {
    expect(await shouldInviteToRegister(backend, {})).toBe(true);
    expect(await shouldInviteToRegister(backend, { [REGISTER_INVITE_ENV]: '1' })).toBe(false);

    await db.query(`update instance set contact_email = 'ops@example.test', registered_at = now()`);
    try {
      expect(await shouldInviteToRegister(backend, {})).toBe(false);
    } finally {
      await db.query('update instance set contact_email = null, registered_at = null');
    }
  });
});
