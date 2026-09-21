import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { generateVatConsignment, type FiledBox } from '@ekwo-ai/vat-consignment';
import { filingReadiness, type Pack } from '../packages/cli/src/index.js';
import { freshDatabase, one, rows } from './helpers/db.js';
import { newCompany } from './helpers/factory.js';
import { replayScenario } from './helpers/golden-scenario.js';
import { allPacks, monthsOf } from './helpers/packs.js';

/**
 * The proof, pack by pack: a year of books becomes a declaration, the
 * declaration is frozen, the file is written and read back, and the settlement
 * empties the tax accounts.
 *
 * Every pack of this checkout walks as far as it can, and **how far it got is
 * the assertion**. A pack that names no file format files on a portal, which is
 * complete and free; a pack that names no account for what a return owes cannot
 * settle. Neither is a failure, and neither may be silent: the last block
 * prints what each pack can do and refuses a repository where nobody can do
 * each of the three.
 *
 * Nothing here names a country. What is checked of a pack comes from that
 * pack's own files — its golden year, its form, its cadence, its roles.
 */

/** The bricks this repository has, by the name a pack uses for the format. */
const WRITERS: Record<string, (boxes: FiledBox[], year: number, quarter: number) => string> = {
  'vat-consignment': (boxes, year, quarter) =>
    generateVatConsignment(boxes, {
      // A number of the schema's shape and of nobody's: ten digits, all nines.
      declarant: { vatNumber: '0999999999' },
      period: { year, quarter },
    }).file,
};

interface Box {
  box: string;
  kind: string;
  amount: string;
}

/** What a pack managed, which is what this file asserts on. */
interface Walk {
  slug: string;
  froze: boolean;
  wroteFile: boolean;
  settled: boolean;
}

const walked: Walk[] = [];

/** The packs with both a form and a year of books to file it from. */
const filers = allPacks.filter((pack) => pack.report !== null && pack.golden !== null);

/**
 * The period of the pack's own cadence that its golden year books the most in.
 * Reading it from the scenario rather than taking the first one keeps a nil
 * return out of a test whose subject is figures.
 */
function busiestPeriod(pack: Pack): { from: string; to: string; year: number; quarter: number } {
  const golden = pack.golden as NonNullable<Pack['golden']>;
  const cadence = pack.report?.period_default ?? 'month';
  const start = new Date(`${golden.fiscalYear.start}T00:00:00Z`);

  const span = monthsOf(cadence);
  const key = (date: Date): number => {
    const months = (date.getUTCFullYear() - start.getUTCFullYear()) * 12 +
      (date.getUTCMonth() - start.getUTCMonth());
    return Math.floor(months / span);
  };
  const counts = new Map<number, number>();
  for (const document of golden.documents) {
    const index = key(new Date(`${document.date}T00:00:00Z`));
    if (index < 0) continue;
    counts.set(index, (counts.get(index) ?? 0) + 1);
  }
  const busiest = [...counts.entries()].sort((a, b) => b[1] - a[1] || a[0] - b[0])[0]?.[0] ?? 0;

  const from = new Date(Date.UTC(start.getUTCFullYear(), start.getUTCMonth() + busiest * span, 1));
  const to = new Date(Date.UTC(from.getUTCFullYear(), from.getUTCMonth() + span, 0));
  const iso = (date: Date): string => date.toISOString().slice(0, 10);
  return {
    from: iso(from),
    to: iso(to),
    year: from.getUTCFullYear(),
    quarter: Math.floor(from.getUTCMonth() / 3) + 1,
  };
}

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
}, 300_000);

afterAll(async () => {
  await db?.close();
});

describe.each(filers.map((pack) => [pack.slug, pack] as const))(
  'the golden year of %s, filed',
  (slug, pack) => {
    const golden = pack.golden as NonNullable<Pack['golden']>;
    const ready = filingReadiness(pack);
    const period = busiestPeriod(pack);
    const walk: Walk = { slug, froze: false, wroteFile: false, settled: false };

    let companyId: string;
    let filingId: string;
    let boxes: Box[];

    beforeAll(async () => {
      // country-literal: every pack of the checkout is installed, each on its
      // own company, and the country is the pack's own.
      ({ companyId } = await newCompany(db, {
        country: pack.manifest.country,
        name: `${golden.name} — filing`,
        chart: golden.chart,
        language: golden.language,
        fiscalYear: golden.fiscalYear,
      }));
      await replayScenario(db, companyId, golden);
      walked.push(walk);
    }, 300_000);

    it('computes the return and freezes it, figure for figure', async () => {
      const filing = await one<{ id: string }>(
        db,
        `select id from prepare_filing($1, $2::date, $3::date)`,
        [companyId, period.from, period.to],
      );
      filingId = filing.id;
      boxes = await rows<Box>(
        db,
        `select box, kind, trim_scale(amount)::text as amount from tax_filing_boxes where filing_id = $1 order by box, kind`,
        [filingId],
      );
      const live = await rows<Box>(
        db,
        `select box, kind, trim_scale(amount)::text as amount from vat_return($1, $2::date, $3::date)
          where not hidden order by box, kind`,
        [companyId, period.from, period.to],
      );
      expect(boxes, `${slug} froze what the return answered`).toEqual(live);
      expect(boxes.length, `${slug} books something in its busiest period`).toBeGreaterThan(0);

      // Nothing has moved since, so the two agree and the drift is empty.
      await db.query(`select file_filing($1, $2)`, [filingId, `GOLDEN-${slug.toUpperCase()}`]);
      const drift = await rows(db, `select * from filing_drift($1)`, [filingId]);
      expect(drift, `${slug} drifts from its own freeze`).toEqual([]);
      walk.froze = true;
    });

    const itWritesTheFile = ready.fileFormat !== null && WRITERS[ready.fileFormat] !== undefined;
    (itWritesTheFile ? it : it.skip)(
      'writes the file its pack names, and it reads back the same figures',
      () => {
        const write = WRITERS[ready.fileFormat as string]!;
        const file = write(boxes as FiledBox[], period.year, period.quarter);
        const readBack = new Map(
          [...file.matchAll(/GridNumber="([0-9]{2})">(-?[0-9]+\.[0-9]{2})</g)].map(
            (match) => [match[1] as string, match[2] as string] as const,
          ),
        );
        const expected = new Map(
          boxes
            .filter((row) => Math.abs(Number(row.amount)) >= 0.005)
            .map((row) => [row.box.padStart(2, '0'), Number(row.amount).toFixed(2)] as const),
        );
        expect(readBack, `${slug}: the file is what was frozen`).toEqual(expected);
        walk.wroteFile = true;
      },
    );

    const itSettles = ready.taxPayable !== null;
    (itSettles ? it : it.skip)('settles, and its tax accounts go back to zero', async () => {
      await db.query(`select record_filing_outcome($1, 'accepted')`, [filingId]);
      const moved = await rows<{ account_id: string }>(
        db,
        `select account_id from filing_tax_movements($1)`,
        [filingId],
      );
      expect(moved.length, `${slug} moved a tax account in the period it filed`).toBeGreaterThan(0);

      await db.query(`select settle_filing($1)`, [filingId]);

      for (const account of moved) {
        const left = await one<{ balance: string }>(
          db,
          `select coalesce(sum(l.balance), 0)::text as balance
             from entry_lines l join entries e on e.id = l.entry_id
            where l.company_id = $1 and l.account_id = $2 and e.state = 'posted'
              and e.entry_date between $3::date and $4::date`,
          [companyId, account.account_id, period.from, period.to],
        );
        expect(Number(left.balance), `${slug} left a tax account with a balance`).toBeCloseTo(0, 2);
      }
      walk.settled = true;
    });
  },
);

describe('what this checkout can do, counted', () => {
  it('has at least one pack for each step of the chain, and says what each did', () => {
    // Printed, because the number is the point: this is the measure the card
    // asked for, and a run that improves it should show it.
    const summary = walked
      .map(
        (w) =>
          `${w.slug}: ${w.froze ? 'freezes' : '—'}, ${w.wroteFile ? 'writes a file' : 'no file'}, ` +
          `${w.settled ? 'settles' : 'no settlement'}`,
      )
      .join('\n  ');
    console.info(`  ${summary}`);

    expect(walked.length, 'a pack with a form and a golden year').toBeGreaterThan(0);
    expect(walked.every((w) => w.froze), 'every pack with a form freezes its return').toBe(true);
    expect(walked.some((w) => w.wroteFile), 'some pack writes its file').toBe(true);
    expect(walked.some((w) => w.settled), 'some pack settles its return').toBe(true);
    // The ratchet. Since 18 September 2026 one country walks the whole chain,
    // and a change that takes that away has to say so here rather than turn a
    // line of the summary quietly back into "no file".
    expect(
      walked.some((w) => w.froze && w.wroteFile && w.settled),
      'some pack freezes, writes its file and settles — the whole chain, in one country',
    ).toBe(true);
  });
});
