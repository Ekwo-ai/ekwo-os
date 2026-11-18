import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { asUser, expectError, freshDatabase, one, rows } from '../../../tests/helpers/db.js';
import { newCompany } from '../../../tests/helpers/factory.js';
import { somePack } from '../../../tests/helpers/packs.js';

// The deal carries the commercial status; the quote carries its dated facts.
// A deal carries documents through `crm.deal_documents`, and the answer
// recorded on a quote it carries moves it, in the database: accepted wins it,
// declined loses it once no other quote of it is alive, undone opens it again.

const HOME = somePack.manifest.country;

let db: PGlite;
let companyId: string;
let ownerId: string;
let pipelineId: string;
let stages: Record<string, string>;

async function contact(company: string, name: string): Promise<string> {
  return (
    await one<{ id: string }>(
      db,
      `insert into contacts (company_id, name, is_company, contact_type) values ($1, $2, true, 'other') returning id`,
      [company, name],
    )
  ).id;
}

async function quote(company: string, contactId: string, dueDate: string | null = null): Promise<string> {
  return (
    await one<{ id: string }>(
      db,
      `insert into documents (company_id, doc_type, contact_id, document_date, due_date)
       values ($1, 'sale_quote', $2, '2026-06-15', $3) returning id`,
      [company, contactId, dueDate],
    )
  ).id;
}

/** A deal of the sales pipeline at Proposal, carrying the quotes given. */
async function dealWith(
  contactId: string,
  quotes: string[],
  pipeline = pipelineId,
  stage: string | null | undefined = stages['Proposal'],
): Promise<string> {
  return asUser(db, ownerId, async () => {
    const deal = (
      await one<{ id: string }>(db, `select id from crm.open_deal($1, $2, $3, 'Annual subscription', 12000)`, [
        companyId,
        pipeline,
        contactId,
      ])
    ).id;
    if (stage !== null && stage !== undefined) await db.query(`select crm.move_deal($1, $2, $3)`, [companyId, deal, stage]);
    for (const document of quotes) await db.query(`select crm.attach_document($1, $2, $3)`, [companyId, deal, document]);
    return deal;
  });
}

const dealOf = (deal: string) =>
  one<{ stage_id: string; closed_outcome: string | null }>(db, `select stage_id, closed_outcome::text from crm.deals where id = $1`, [deal]);

const answer = (sql: string, document: string) => asUser(db, ownerId, () => db.query(sql, [document]));

beforeAll(async () => {
  db = await freshDatabase();
  ({ companyId, ownerId } = await newCompany(db, { country: HOME, name: 'Quotes SRL' }));
  await asUser(db, ownerId, async () => {
    await db.query(`select enable_module($1, 'crm')`, [companyId]);
    pipelineId = (
      await one<{ id: string }>(db, `insert into crm.pipelines (company_id, name, slug) values ($1, 'Sales', 'sales') returning id`, [
        companyId,
      ])
    ).id;
    const inserted = await rows<{ name: string; id: string }>(
      db,
      `insert into crm.stages (company_id, pipeline_id, name, position, outcome) values
         ($1, $2, 'Lead', 1, 'open'), ($1, $2, 'Qualified', 2, 'open'), ($1, $2, 'Proposal', 3, 'open'),
         ($1, $2, 'Won', 4, 'won'), ($1, $2, 'Lost', 5, 'lost')
       returning name, id`,
      [companyId, pipelineId],
    );
    stages = Object.fromEntries(inserted.map((s) => [s.name, s.id]));
  });
});

afterAll(async () => {
  await db.close();
});

describe('a quote accepted', () => {
  it('wins the deal that carries it, and makes the party a customer', async () => {
    const party = await contact(companyId, 'Northwind Trading');
    const document = await quote(companyId, party);
    const deal = await dealWith(party, [document]);

    await answer(`select accept_document($1, 'The buyer')`, document);

    expect(await dealOf(deal)).toEqual({ stage_id: stages['Won'], closed_outcome: 'won' });
    expect((await one<{ contact_type: string }>(db, `select contact_type::text from contacts where id = $1`, [party])).contact_type).toBe(
      'customer',
    );
    const moved = await one<{ payload: Record<string, unknown> }>(
      db,
      `select payload from crm.activities where deal_id = $1 and subject = 'moved to Won'`,
      [deal],
    );
    expect(moved.payload).toMatchObject({ document_id: document, answer: 'accepted', outcome: 'won' });
  });

  it('opens the deal again where it was when the acceptance is undone', async () => {
    const party = await contact(companyId, 'Contoso Partners');
    const document = await quote(companyId, party);
    const deal = await dealWith(party, [document], pipelineId, stages['Qualified']);

    await answer(`select accept_document($1)`, document);
    expect((await dealOf(deal)).closed_outcome).toBe('won');
    await answer(`select undo_document_answer($1)`, document);
    expect(await dealOf(deal)).toEqual({ stage_id: stages['Qualified'], closed_outcome: null });
  });
});

describe('a quote declined', () => {
  it('leaves the deal open while another quote of it is alive, and loses it with the last', async () => {
    const party = await contact(companyId, 'Fabrikam Industries');
    const first = await quote(companyId, party);
    const second = await quote(companyId, party);
    const deal = await dealWith(party, [first, second]);

    await answer(`select decline_document($1)`, first);
    expect(await dealOf(deal)).toEqual({ stage_id: stages['Proposal'], closed_outcome: null });

    await answer(`select decline_document($1)`, second);
    expect(await dealOf(deal)).toEqual({ stage_id: stages['Lost'], closed_outcome: 'lost' });
  });

  it('loses the deal when the other quote has expired', async () => {
    const party = await contact(companyId, 'Tailspin Toys');
    const expired = await quote(companyId, party, '2020-01-31');
    const live = await quote(companyId, party);
    const deal = await dealWith(party, [expired, live]);

    await answer(`select decline_document($1)`, live);
    expect((await dealOf(deal)).closed_outcome).toBe('lost');
  });
});

describe('what moves nothing', () => {
  it('a sent quote, an expired one, and a quote no deal carries', async () => {
    const party = await contact(companyId, 'Litware');
    const sent = await quote(companyId, party);
    const deal = await dealWith(party, [sent]);
    await db.query(`update documents set sent_at = now() where id = $1`, [sent]);
    expect(await dealOf(deal)).toEqual({ stage_id: stages['Proposal'], closed_outcome: null });

    const alone = await quote(companyId, party);
    await answer(`select accept_document($1)`, alone);
    expect(await dealOf(deal)).toEqual({ stage_id: stages['Proposal'], closed_outcome: null });
  });

  it('a pipeline with no won stage: the fact is on the quote, the deal stays, nothing fails', async () => {
    const party = await contact(companyId, 'Adventure Works');
    const open = await asUser(db, ownerId, async () => {
      const pipeline = (
        await one<{ id: string }>(db, `insert into crm.pipelines (company_id, name, slug) values ($1, 'Hiring', 'hiring') returning id`, [
          companyId,
        ])
      ).id;
      const stage = (
        await one<{ id: string }>(
          db,
          `insert into crm.stages (company_id, pipeline_id, name, position, outcome) values ($1, $2, 'Talking', 1, 'open') returning id`,
          [companyId, pipeline],
        )
      ).id;
      return { pipeline, stage };
    });
    const document = await quote(companyId, party);
    const deal = await dealWith(party, [document], open.pipeline, null);

    await answer(`select accept_document($1)`, document);
    expect(await dealOf(deal)).toEqual({ stage_id: open.stage, closed_outcome: null });
    expect((await one<{ accepted_at: string | null }>(db, `select accepted_at from documents where id = $1`, [document])).accepted_at).not.toBeNull();
  });

  it('a company that has not enabled the module: the quote carries its fact, and that is all', async () => {
    const other = await newCompany(db, { country: HOME, name: 'No Relations SA', ownerId });
    const party = await contact(other.companyId, 'Wingtip');
    const document = await quote(other.companyId, party);
    await answer(`select accept_document($1)`, document);
    expect((await one<{ s: string }>(db, `select quote_status(d) as s from documents d where id = $1`, [document])).s).toBe('accepted');
  });
});

describe('the link', () => {
  it('holds a document on one deal only, of the same company', async () => {
    const party = await contact(companyId, 'Proseware');
    const document = await quote(companyId, party);
    const deal = await dealWith(party, [document]);
    const another = await dealWith(party, []);
    await asUser(db, ownerId, async () => {
      // The same pair again is the link already kept.
      await db.query(`select crm.attach_document($1, $2, $3)`, [companyId, deal, document]);
      expect(await expectError(db, `select crm.attach_document($1, $2, $3)`, [companyId, another, document])).toMatch(
        /^crm_document_in_another_deal: /,
      );
      expect(await expectError(db, `select crm.attach_document($1, $2, $3)`, [companyId, deal, crypto.randomUUID()])).toMatch(
        /^crm_unknown_document: /,
      );
      await db.query(`select crm.detach_document($1, $2)`, [companyId, document]);
      expect(await expectError(db, `select crm.detach_document($1, $2)`, [companyId, document])).toMatch(/^crm_document_not_attached: /);
      await db.query(`select crm.attach_document($1, $2, $3)`, [companyId, another, document]);
    });
    // A document of another company fails on the composite key, whoever writes.
    const other = await newCompany(db, { country: HOME, name: 'Elsewhere SA' });
    const foreign = await quote(other.companyId, await contact(other.companyId, 'Foreign'));
    expect(
      await expectError(db, `insert into crm.deal_documents (company_id, deal_id, document_id) values ($1, $2, $3)`, [companyId, deal, foreign]),
    ).toMatch(/foreign key/);
  });

  it('is read on the card and on the board, with the status the socle derives', async () => {
    const party = await contact(companyId, 'Coho Winery');
    const document = await quote(companyId, party);
    const deal = await dealWith(party, [document]);
    await db.query(`update documents set sent_at = now() where id = $1`, [document]);

    const card = await asUser(db, ownerId, () => one<{ card: { deals: { id: string; documents: Record<string, unknown>[] }[] } }>(
      db,
      `select crm.card_of($1, $2) as card`,
      [companyId, party],
    ));
    const onCard = card.card.deals.find((d) => d.id === deal);
    expect(onCard?.documents).toEqual([expect.objectContaining({ id: document, doc_type: 'sale_quote', quote_status: 'sent' })]);

    const board = await asUser(db, ownerId, () =>
      one<{ board: { pipelines: { stages: { deals: { id: string; documents: Record<string, unknown>[] }[] }[] }[] } }>(
        db,
        `select crm.board($1, $2) as board`,
        [companyId, pipelineId],
      ),
    );
    const onBoard = board.board.pipelines[0]?.stages.flatMap((s) => s.deals).find((d) => d.id === deal);
    expect(onBoard?.documents).toEqual([expect.objectContaining({ id: document, quote_status: 'sent' })]);
  });
});

describe('a database without the module', () => {
  it('accepts and declines a quote with no error', async () => {
    const bare = await freshDatabase({ modules: false });
    try {
      const fx = await newCompany(bare, { country: HOME });
      const party = (
        await bare.query<{ id: string }>(`insert into contacts (company_id, name, contact_type) values ($1, 'Bare', 'other') returning id`, [
          fx.companyId,
        ])
      ).rows[0]!.id;
      const document = (
        await bare.query<{ id: string }>(
          `insert into documents (company_id, doc_type, contact_id, document_date) values ($1, 'sale_quote', $2, '2026-06-15') returning id`,
          [fx.companyId, party],
        )
      ).rows[0]!.id;
      await asUser(bare, fx.ownerId, () => bare.query(`select accept_document($1)`, [document]));
      const status = await bare.query<{ s: string }>(`select quote_status(d) as s from documents d where id = $1`, [document]);
      expect(status.rows[0]?.s).toBe('accepted');
      expect((await bare.query(`select 1 from pg_namespace where nspname = 'crm'`)).rows).toHaveLength(0);
    } finally {
      await bare.close();
    }
  });
});
