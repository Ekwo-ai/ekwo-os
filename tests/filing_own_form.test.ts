import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { filingReadiness, type Pack, type PackTax } from '../packages/cli/src/index.js';
import { freshDatabase, one, rows } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { replayScenario } from './helpers/golden-scenario.js';
import { allPacks } from './helpers/packs.js';

/**
 * A return settles the tax of its own form, and knows the day it is due.
 *
 * A pack may book a tax on a liability of its own and print it in no box of
 * its form — a tax the buyer self-assesses on a service bought from abroad, a
 * withholding, a provincial tax beside a federal one — because another return
 * declares it. Settling the periodic return used to carry that liability into
 * the debt of the return all the same, which then owed more than its boxes
 * said. What is proved below, on every pack whose golden year books such a
 * tax in a period it files:
 *
 *   1. what the settlement clears on the accounts that tax books is the tax
 *      of the form alone — the lines of that tax stay where they were posted;
 *   2. the filing carries the due date the pack's rule gives, and the debt
 *      the settlement posts matures on it.
 *
 * Nothing here names a country: the taxes, the period and the accounts come
 * from each pack's own files.
 */

/** A tax that no posting prints in any box: declared somewhere else, if at all. */
function onNoForm(tax: PackTax): boolean {
  const postings = [...tax.postings.invoice, ...tax.postings.credit_note];
  return postings.length > 0 && postings.every((p) => p.boxes.length === 0);
}

/** The accounts a tax books its own amount on. */
function taxAccounts(tax: PackTax): string[] {
  const postings = [...tax.postings.invoice, ...tax.postings.credit_note];
  return [...new Set(postings.filter((p) => p.type === 'tax' && p.account !== null).map((p) => p.account as string))];
}

interface Case {
  pack: Pack;
  /** Every tax of the pack that no posting prints in a box. */
  taxes: PackTax[];
  period: { from: string; to: string };
}

/** Every pack whose golden year books, in a period it files, a tax its form never prints. */
const cases: Case[] = allPacks.flatMap((pack) => {
  if (pack.report === null || pack.golden === null || filingReadiness(pack).taxPayable === null) return [];
  const offForm = pack.taxes.filter((t) => onNoForm(t) && taxAccounts(t).length > 0);
  for (const document of pack.golden.documents) {
    if (!offForm.some((t) => document.lines.some((l) => l.tax === t.code))) continue;
    const period = pack.golden.periods.find((p) => p.from <= document.date && document.date <= p.to);
    if (period !== undefined) return [{ pack, taxes: offForm, period: { from: period.from, to: period.to } }];
  }
  return [];
});

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
}, 300_000);

afterAll(async () => {
  await db?.close();
});

it('finds a pack that books a tax its form does not print, so the rule is exercised', () => {
  expect(cases.length).toBeGreaterThan(0);
});

describe.each(cases.map((c) => [c.pack.slug, c] as const))('the golden year of %s, settled', (slug, c) => {
  const golden = c.pack.golden as NonNullable<Pack['golden']>;
  let companyId: string;
  let filingId: string;

  beforeAll(async () => {
    // country-literal: each pack of the checkout that books such a tax, on its
    // own company, and the country is the pack's own.
    ({ companyId } = await newCompany(db, {
      country: c.pack.manifest.country,
      name: `${golden.name} — its own form`,
      chart: golden.chart,
      language: golden.language,
      fiscalYear: golden.fiscalYear,
    }));
    await replayScenario(db, companyId, golden);
    const filing = await one<{ id: string }>(db, `select id from prepare_filing($1, $2::date, $3::date)`, [
      companyId,
      c.period.from,
      c.period.to,
    ]);
    filingId = filing.id;
    await db.query(`select file_filing($1, $2)`, [filingId, `OWN-FORM-${slug.toUpperCase()}`]);
  }, 300_000);

  it('carries the due date of its pack’s rule', async () => {
    const dates = await one<{ due: string | null; rule: string | null }>(
      db,
      `select f.due_date::text as due, filing_deadline(f.company_id, f.report_code, f.period_end)::text as rule
         from tax_filings f where f.id = $1`,
      [filingId],
    );
    expect(dates.due, `${slug} due date`).toBe(dates.rule);
    const rule = c.pack.report?.deadline?.rule ?? null;
    if (rule !== null && rule !== 'depends_on_taxpayer') {
      expect(dates.due, `${slug} names a rule, so the filing has a date`).not.toBeNull();
    }
  });

  it('clears the tax of its form and leaves the tax no box prints where it was posted', async () => {
    const codes = c.taxes.map((t) => t.code);
    const accounts = [...new Set(c.taxes.flatMap(taxAccounts))];

    // On each account those taxes book: what the tax lines of the period sum
    // to, and what the lines of those taxes sum to. The settlement clears the
    // difference and nothing else.
    const expected = await rows<{ code: string; on_form: string; off_form: string }>(
      db,
      `select a.code,
              coalesce(sum(l.balance) filter (where t.code is null or not t.code = any($4::text[])), 0)::text as on_form,
              coalesce(sum(l.balance) filter (where t.code = any($4::text[])), 0)::text as off_form
         from declared_lines($1, $2::date, $3::date) l
         join entries e  on e.id = l.entry_id and e.state = 'posted'
         join accounts a on a.id = l.account_id
         left join taxes t on t.id = l.tax_id
        where l.tax_line and a.code = any($5::text[])
        group by a.code order by a.code`,
      [companyId, c.period.from, c.period.to, codes, accounts],
    );
    expect(
      expected.some((e) => Number(e.off_form) !== 0),
      `${slug} books those taxes in the period it files`,
    ).toBe(true);

    await db.query(`select record_filing_outcome($1, 'accepted')`, [filingId]);
    const moved = await rows<{ code: string; balance: string }>(
      db,
      `select a.code, m.balance::text as balance
         from filing_tax_movements($1) m join accounts a on a.id = m.account_id`,
      [filingId],
    );
    for (const e of expected) {
      const balance = moved.find((m) => m.code === e.code)?.balance ?? '0';
      expect(Number(balance), `${slug} settles ${e.code} with the tax of its form alone`).toBeCloseTo(
        Number(e.on_form),
        2,
      );
    }

    // A period whose only tax is one the form does not print has nothing to
    // settle, and says so rather than posting the other return's tax.
    if (moved.length === 0) {
      await expect(db.query(`select settle_filing($1)`, [filingId])).rejects.toThrow(/nothing_to_settle/);
      return;
    }

    const net = await one<{ net: string }>(
      db,
      `select coalesce(sum(balance), 0)::text as net from filing_tax_movements($1)`,
      [filingId],
    );
    const entry = await one<{ id: string }>(
      db,
      Number(net.net) > 0
        ? `select (settle_filing($1, 'carry_forward')).id as id`
        : `select (settle_filing($1)).id as id`,
      [filingId],
    );

    // Each of those accounts keeps, in the period, exactly what those taxes
    // booked on it.
    for (const e of expected) {
      const left = await one<{ balance: string }>(
        db,
        `select coalesce(sum(l.balance), 0)::text as balance
           from entry_lines l
           join entries e  on e.id = l.entry_id and e.state = 'posted'
           join accounts a on a.id = l.account_id
          where l.company_id = $1 and a.code = $2
            and (l.declared_on between $3::date and $4::date or e.id = $5)`,
        [companyId, e.code, c.period.from, c.period.to, entry.id],
      );
      expect(Number(left.balance), `${slug} leaves ${e.code} with what the form does not print`).toBeCloseTo(
        Number(e.off_form),
        2,
      );
    }

    // And the debt matures on the day the return is due.
    const roles = c.pack.manifest.defaults.roles;
    const debt = await rows<{ maturity: string | null; due: string | null }>(
      db,
      `select l.date_maturity::text as maturity, f.due_date::text as due
         from entry_lines l
         join accounts a on a.id = l.account_id
         join tax_filings f on f.settlement_entry_id = l.entry_id
        where l.entry_id = $1 and a.code = any($2::text[])`,
      [entry.id, [roles['tax_payable'], roles['tax_receivable']].filter((r) => typeof r === 'string')],
    );
    for (const d of debt) expect(d.maturity, `${slug} debt matures on the due date`).toBe(d.due);
  });
});
