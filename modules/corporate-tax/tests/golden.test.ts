import type { PGlite } from '@electric-sql/pglite';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { freshDatabase } from '../../../tests/helpers/db.js';
import { allPacks } from '../../../tests/helpers/packs.js';
import { book, declare, decimal, estimate, figures, goldenOf, taxCompany } from './helpers.js';

// The worked examples of every pack that carries a `corporate_tax` section.
//
// The expectation is not in this file. Each pack ships, beside its section,
// `golden/corporate_tax.json`: three fictitious companies — a small one with a
// profit under the reduced rate, a year that ends in a loss, a small one kept
// out of the reduced rate — with the books of a year, what each declares, and
// the tax somebody worked out by hand. The arithmetic is written there step
// by step, under `expected.computation`, in the words of the country: that is
// what a reviewer reads, and it is printed here when a figure disagrees.
//
// What this file proves is that `tax.estimate()` makes the same figures of
// the same books, line by line and to the cent, as a member of the company
// asking through row level security. A pack that gains a section is replayed
// without a line changing here.
//
// The six that exist today, by hand, so that a reader of this file has the
// arithmetic without opening the packs. All are the financial year 2025.
//
// Belgium — result before income tax, line 9903; assessment year 2026.
//
//   Atelier Lumen SRL, a small company within the conditions.
//     result      412 350,00 − 36 000,00 − 58 420,75 − 54 000,00 − 92 300,40
//                 − 24 118,30 − 4 172,75 − 8 412,60 − 250,00      = 134 675,20
//     restaurant  3 127,45 × 31 %               = 969,5095       →      969,51
//     reception   1 045,30 × 50 %                                =      522,65
//     fines       250,00 × 100 %, read on account 664100         =      250,00
//     car         120 − 0,5 × 1 × 110 = 65 % deductible;
//                 8 412,60 × 35 %                                =    2 944,41
//     base        134 675,20 + 969,51 + 522,65 + 250,00 + 2 944,41 = 139 361,77
//     tax         100 000,00 × 20 %                              =   20 000,00
//                 39 361,77 × 25 %              = 9 840,4425     →    9 840,44
//                                                          total =   29 840,44
//     The 25 000,00 of tax already booked sits below line 9903 and changes nothing.
//
//   Verger des Trois Tilleuls SRL, a year that ends in a loss.
//     result      120 000,00 − 48 000,00 − 31 250,80 − 45 000,00 − 22 400,00
//                 − 1 200,00                                     = −27 850,80
//     restaurant  1 200,00 × 31 %                                =      372,00
//     fiscal      −27 850,80 + 372,00                            = −27 478,80
//     base 0,00 · loss of the period 27 478,80 · tax 0,00
//
//   Comptoir Meuse Logistique SA, small and half held by another company.
//     result      4 850 000,00 − 250 000,00 − 1 100 000,00 − 2 200 000,00
//                 − 2 400,00                                     = 1 297 600,00
//     fines       2 400,00 × 100 %                → fiscal result 1 300 000,00
//     losses      1 500 000,00 of 2023 and 500 000,00 of 2024 available;
//                 limit 1 000 000 + 70 % × 300 000 = 1 210 000,00, all of it
//                 taken on 2023
//     base        1 300 000,00 − 1 210 000,00                    =   90 000,00
//     tax         reduced rate refused (held by companies); 90 000,00 × 25 %
//                                                                =   22 500,00
//
// France — net accounting result, line HN, the tax charge added back.
//
//   Menuiserie des Quais SAS, within the three conditions.
//     result      386 540,00 − 42 000,00 − 27 315,60 − 148 200,00 − 61 744,15
//                 − 480,00 − 9 800,00 − 12 000,00                =   85 000,25
//     tax charge  12 000,00 × 100 %, read on account 695000      =   12 000,00
//     fines       480,00 × 100 %, read on account 671200         =      480,00
//     excess depreciation, declared                              =    1 260,00
//     base        85 000,25 + 12 000,00 + 480,00 + 1 260,00      =   98 740,25
//     tax         42 500,00 × 15 %                               =    6 375,00
//                 56 240,25 × 25 %              = 14 060,0625    →   14 060,06
//                                                          total =   20 435,06
//
//   Librairie du Passage SARL, a year that ends in a loss.
//     result      95 000,00 − 36 000,00 − 58 250,30 − 24 465,13 − 9 000,00
//                                                                = −32 715,43
//     excess depreciation, declared 1 850,00     → fiscal result  −30 865,43
//     base 0,00 · loss of the period 30 865,43 · tax 0,00
//
//   Négoce Atlantique SAS, not held at 75 % by individuals.
//     result      6 200 000,00 − 3 100 000,00 − 1 250 000,00 − 450 000,00
//                 − 880,00                                       = 1 399 120,00
//     fines       880,00 × 100 %                  → fiscal result 1 400 000,00
//     losses      900 000,00 of 2023 and 600 000,00 of 2024 available;
//                 limit 1 000 000 + 50 % × 400 000 = 1 200 000,00: all of
//                 2023, then 300 000,00 of 2024
//     base        1 400 000,00 − 1 200 000,00                    =  200 000,00
//     tax         reduced rate refused (capital); 200 000,00 × 25 % = 50 000,00

const packs = allPacks.filter((pack) => pack.corporateTax !== null);

let db: PGlite;

beforeAll(async () => {
  db = await freshDatabase();
}, 300_000);

afterAll(async () => {
  await db.close();
});

describe('the packs that say how a profit is taxed', () => {
  it('are at least two, each with its worked examples', () => {
    expect(packs.length).toBeGreaterThanOrEqual(2);
    for (const pack of packs) {
      const golden = goldenOf(pack);
      expect(golden.companies.length, pack.slug).toBeGreaterThanOrEqual(3);
      // One of them ends the year below zero, and one is refused a rate.
      expect(
        golden.companies.some((c) => c.expected.lines.some((l) => l.kind === 'loss_of_period')),
        `${pack.slug}: no loss year`,
      ).toBe(true);
      expect(
        golden.companies.some((c) => c.expected.lines.some((l) => l.kind === 'rate_not_applied')),
        `${pack.slug}: no company outside the conditions of a rate`,
      ).toBe(true);
    }
  });
});

for (const pack of packs) {
  const golden = goldenOf(pack);

  describe(`${pack.manifest.name}: corporate income tax, to the cent`, () => {
    for (const company of golden.companies) {
      it(`${company.name} — ${company.ref}`, async () => {
        const fixture = await taxCompany(db, pack.manifest.country, company.name, golden.fiscal_year);
        for (const entry of company.entries) await book(db, fixture.companyId, entry);
        await declare(db, fixture, company);

        const lines = await estimate(db, fixture);
        const worked = `\n${company.why}\n${company.expected.computation.join('\n')}\n`;

        expect(lines.map(figures), worked).toEqual(company.expected.lines.map(figures));

        // A line that says why something was not applied says it in a word
        // the pack did not write: the parameter that stood in the way.
        for (const [index, expected] of company.expected.lines.entries()) {
          if (expected.note === undefined || expected.note === null) continue;
          expect(lines[index]?.name, worked).toBe(expected.note);
        }

        // The figure, under the only name an estimate gives it.
        const last = lines.at(-1);
        expect(last?.kind).toBe('estimated_tax');
        expect(last?.code).toBe(pack.corporateTax?.tax.code);
        expect(decimal(last?.amount), worked).toBe(decimal(company.expected.tax));

        // Every adjustment and every rate names the article it comes from.
        for (const line of lines.filter((l) => l.kind === 'adjustment' || l.kind === 'rate' || l.kind === 'loss_used')) {
          expect(line.legal_reference, `${line.kind} ${line.code ?? ''}`).toBeTruthy();
        }
      }, 120_000);
    }
  });
}
