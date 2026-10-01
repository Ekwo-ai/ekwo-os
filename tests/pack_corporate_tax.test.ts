import { cp, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { compileCorporateTaxSeed, compileModuleSeeds, readPack } from '../packages/cli/src/index.js';
import { allPacks, packsRoot } from './helpers/packs.js';

// The `corporate_tax` section of a pack: what `ekwo pack check` reads of it,
// what it refuses, and what it compiles to.
//
// The refusals are tried on a copy of a pack that carries the section, broken
// one way at a time. Nothing here names a country: the pack is whichever one
// carries everything the refusals are about — a reduced rate with conditions,
// a judgement the company declares, a limit on losses, a prepayment schedule
// and a language to label them in. A country may have none of them.

type Section = Record<string, unknown> & {
  result: Record<string, unknown>;
  accounts: Record<string, unknown>;
  parameters: Record<string, unknown>[];
  adjustment_rules: Record<string, unknown>[];
  rates: (Record<string, unknown> & { conditions?: Record<string, unknown>[] })[];
  loss_carryforward: Record<string, unknown>[];
  prepayments: (Record<string, unknown> & { instalments: Record<string, unknown>[] })[];
};

const source = allPacks.find((pack) => {
  const section = pack.corporateTax;
  return (
    section !== null &&
    section.rates.some((rate) => rate.conditions.length > 0) &&
    section.parameters.some((parameter) => parameter.type === 'boolean') &&
    section.loss_carryforward[0]?.floor != null &&
    section.prepayments.length > 0 &&
    (pack.manifest.languages ?? []).length > 0
  );
});
if (source === undefined) throw new Error('no pack carries a corporate_tax section with everything the refusals are tried on');

let dir: string;

beforeAll(async () => {
  dir = await mkdtemp(join(tmpdir(), 'ekwo-corporate-tax-'));
  await cp(join(packsRoot, 'schema'), join(dir, 'schema'), { recursive: true });
  await cp(source.dir, join(dir, source.slug), { recursive: true });
});

afterAll(async () => {
  await rm(dir, { recursive: true, force: true });
});

const sectionPath = (): string => join(dir, source.slug, 'corporate_tax.json');

/** Reads the copy with its section changed, and gives back what the reader said. */
async function broken(change: (section: Section) => void): Promise<string> {
  const original = await readFile(sectionPath(), 'utf8');
  const section = JSON.parse(original) as Section;
  change(section);
  await writeFile(sectionPath(), JSON.stringify(section), 'utf8');
  try {
    await readPack(source!.slug, dir);
    return 'accepted';
  } catch (error) {
    return (error as Error).message;
  } finally {
    await writeFile(sectionPath(), original, 'utf8');
  }
}

describe('a corporate_tax section', () => {
  it('is read with the pack: every dated figure with its article and the day it is read on', () => {
    for (const pack of allPacks.filter((p) => p.corporateTax !== null)) {
      const section = pack.corporateTax!;
      const dated = [
        ...section.adjustment_rules,
        ...section.rates,
        ...section.loss_carryforward,
        ...section.prepayments,
        ...section.credits,
      ];
      expect(dated.length, pack.slug).toBeGreaterThan(0);
      for (const item of dated) {
        expect(item.legal_reference.length, `${pack.slug}: a figure with no article`).toBeGreaterThan(10);
        expect(item.valid_from, pack.slug).toMatch(/^\d{4}-\d{2}-\d{2}$/);
        expect(['period_start', 'period_end']).toContain(item.valid_on);
        // A figure a maintained pack carries names where its article is read.
        expect(item.source, `${pack.slug}: ${item.legal_reference}`).not.toBeNull();
      }
      for (const parameter of section.parameters) {
        expect(parameter.legal_reference.length, `${pack.slug} ${parameter.code}`).toBeGreaterThan(10);
      }
      // The status of a pack is never raised by writing a section.
      expect(pack.manifest.certification?.status, pack.slug).not.toBe('reviewed');
    }
  });

  it('carries its labels in every language the pack declares', () => {
    for (const pack of allPacks.filter((p) => p.corporateTax !== null)) {
      const section = pack.corporateTax!;
      for (const language of pack.manifest.languages ?? []) {
        expect(section.tax.name_i18n[language], `${pack.slug} ${language} tax`).toBeTruthy();
        for (const labelled of [...section.parameters, ...section.adjustment_rules, ...section.rates, ...section.credits]) {
          expect(labelled.name_i18n[language], `${pack.slug} ${language} ${labelled.code}`).toBeTruthy();
        }
      }
    }
  });

  it('compiles into a seed of the module, and into nothing of the pack seed', () => {
    for (const pack of allPacks) {
      const seeds = compileModuleSeeds(pack);
      expect(seeds.has('corporate_tax'), pack.slug).toBe(pack.corporateTax !== null);
      const sql = compileCorporateTaxSeed(pack);
      if (pack.corporateTax === null) {
        expect(sql).toBeUndefined();
        continue;
      }
      expect(sql).toBe(seeds.get('corporate_tax'));
      // Reference tables of the module, and no table that belongs to a company.
      const written = [...(sql ?? '').matchAll(/^insert into (\S+)/gm)].map((m) => m[1]);
      expect(written.every((table) => table?.startsWith('tax.') && table.endsWith('s')), written.join(', ')).toBe(true);
      expect(written).toContain('tax.country_rules');
      expect(written).toContain('tax.rate_templates');
      for (const company of ['company_parameters', 'adjustments', 'computations', 'losses']) {
        expect(written).not.toContain(`tax.${company}`);
      }
      // The same pack, the same bytes.
      expect(compileCorporateTaxSeed(pack)).toBe(sql);
    }
  });
});

describe('what `ekwo pack check` refuses of a corporate_tax section', () => {
  it('reads the copy as it reads the pack', async () => {
    expect(await broken(() => undefined)).toBe('accepted');
  });

  it('a result that is not a line of an income statement of the pack', async () => {
    expect(await broken((s) => { s.result['statement'] = 'NO-SUCH-STATEMENT'; })).toMatch(
      /corporate_tax\.json result\.statement: NO-SUCH-STATEMENT is not a statement of this pack/,
    );
    expect(await broken((s) => { s.result['line'] = 'NO-SUCH-LINE'; })).toMatch(
      /corporate_tax\.json result\.line: NO-SUCH-LINE is not a line of/,
    );
    const balanceSheet = source.statements.find((statement) => statement.kind === 'balance_sheet')!;
    expect(await broken((s) => { s.result['statement'] = balanceSheet.code; })).toMatch(
      /is a balance_sheet; the accounting result is a line of an income statement/,
    );
  });

  it('an account that is not in every chart', async () => {
    expect(await broken((s) => { s.accounts['payable'] = '000000'; })).toMatch(
      /corporate_tax\.json accounts\.payable: account 000000 is not in the chart/,
    );
  });

  it('a figure with no article, or with no day it applies from', async () => {
    expect(await broken((s) => { delete s.rates[0]!['legal_reference']; })).toMatch(/legal_reference/);
    expect(await broken((s) => { delete s.rates[0]!['valid_from']; })).toMatch(/valid_from/);
    expect(await broken((s) => { delete s.adjustment_rules[0]!['legal_reference']; })).toMatch(/legal_reference/);
    expect(await broken((s) => { s.adjustment_rules[0]!['source'] = 'no-such-source'; })).toMatch(
      /names the source no-such-source, which this pack's register does not carry/,
    );
  });

  it('a condition on something nobody declares, or asked the wrong way', async () => {
    const conditional = (s: Section): Record<string, unknown>[] =>
      s.rates.find((rate) => (rate.conditions ?? []).length > 0)!.conditions!;
    expect(await broken((s) => { conditional(s)[0]!['parameter'] = 'not_declared_anywhere'; })).toMatch(
      /a condition names not_declared_anywhere, which is not a parameter of this section/,
    );
    const boolean = source.corporateTax!.parameters.find((p) => p.type === 'boolean')!;
    expect(
      await broken((s) => { conditional(s).push({ parameter: boolean.code, test: 'at_least', amount: 1 }); }),
    ).toMatch(new RegExp(`at_least is asked of ${boolean.code}, which is declared as boolean`));
    expect(
      await broken((s) => { conditional(s).push({ parameter: boolean.code, test: 'is_true', waived_by: ['nobody'] }); }),
    ).toMatch(/waived_by names nobody, which is not a boolean parameter/);
    expect(await broken((s) => { conditional(s)[0]!['test'] = 'roughly'; })).toMatch(/conditions/);
  });

  it('a rule that says two things, or none', async () => {
    const withPercent = (s: Section): Record<string, unknown> =>
      s.adjustment_rules.find((rule) => rule['percent'] !== undefined)!;
    expect(
      await broken((s) => {
        withPercent(s)['formula'] = { yields: 'adjustment_percent', variable: 'x', intercept: 0, slope: 1 };
      }),
    ).toMatch(/a rule takes a percent or a formula, and exactly one of them/);
    expect(await broken((s) => { delete withPercent(s)['percent']; })).toMatch(
      /a rule takes a percent or a formula, and exactly one of them/,
    );
    expect(
      await broken((s) => {
        const rule = withPercent(s);
        delete rule['percent'];
        rule['formula'] = { yields: 'adjustment_percent', variable: 'x', intercept: 0, slope: 1 };
        rule['accounts'] = [{ kind: 'code_prefix', code_from: '6' }];
      }),
    ).toMatch(/a rule with a formula names no accounts/);
    expect(
      await broken((s) => { withPercent(s)['accounts'] = [{ kind: 'account_code', code_from: '000000' }]; }),
    ).toMatch(/account 000000 is not in the chart/);
    expect(
      await broken((s) => { withPercent(s)['accounts'] = [{ kind: 'code_prefix', code_from: '6', code_to: '7' }]; }),
    ).toMatch(/code_to belongs to a code_range and to nothing else/);
  });

  it('two answers for one day', async () => {
    expect(
      await broken((s) => {
        const rate = s.rates.find((r) => r['up_to'] === undefined || r['up_to'] === null)!;
        s.rates.push({ ...rate, valid_from: '2999-01-01' });
      }),
    ).toMatch(/overlaps the version valid from/);
    expect(
      await broken((s) => {
        const rate = s.rates[0]!;
        rate['valid_to'] = '1900-01-01';
      }),
    ).toMatch(/valid_to is before valid_from/);
    expect(
      await broken((s) => {
        s.loss_carryforward.push({ ...s.loss_carryforward[0]!, valid_from: '2999-01-01' });
      }),
    ).toMatch(/corporate_tax\.json loss_carryforward@2999-01-01: overlaps/);
  });

  it('a reduced rate with no ordinary one beside it', async () => {
    expect(
      await broken((s) => {
        s.rates = s.rates.filter((rate) => (rate.conditions ?? []).length > 0);
      }),
    ).toMatch(/no rate applies unconditionally to the whole base/);
  });

  it('half a limit on losses, and half a prepayment schedule', async () => {
    expect(await broken((s) => { s.loss_carryforward[0]!['percent_above'] = null; })).toMatch(
      /floor and percent_above go together/,
    );
    expect(
      await broken((s) => {
        for (const instalment of s.prepayments[0]!.instalments) {
          delete instalment['share_percent'];
          delete instalment['credit_percent'];
        }
      }),
    ).toMatch(/every instalment states its (share|credit)_percent/);
  });

  it('a label under a key the section does not carry', async () => {
    const language = (source.manifest.languages ?? [])[0]!;
    const path = join(dir, source.slug, 'i18n', `${language}.json`);
    const original = await readFile(path, 'utf8');
    const labels = JSON.parse(original) as { corporate_tax: Record<string, string> };
    labels.corporate_tax['rule:no-such-rule'] = 'A label of nothing';
    await writeFile(path, JSON.stringify(labels), 'utf8');
    try {
      await expect(readPack(source.slug, dir)).rejects.toThrow(/rule:no-such-rule is not a label of corporate_tax\.json/);
      // And a declared language that stops covering the section is named.
      delete labels.corporate_tax['rule:no-such-rule'];
      delete labels.corporate_tax['tax'];
      await writeFile(path, JSON.stringify(labels), 'utf8');
      await expect(readPack(source.slug, dir)).rejects.toThrow(/corporate_tax: 1 of \d+ missing: tax/);
    } finally {
      await writeFile(path, original, 'utf8');
    }
  });

  it('a section without the companies whose tax was worked out by hand', async () => {
    const path = join(dir, source.slug, 'golden', 'corporate_tax.json');
    const original = await readFile(path, 'utf8');
    await rm(path);
    try {
      await expect(readPack(source.slug, dir)).rejects.toThrow(/golden\/corporate_tax\.json: is missing/);
      // Two companies are not three.
      const golden = JSON.parse(original) as { companies: unknown[] };
      golden.companies = golden.companies.slice(0, 2);
      await writeFile(path, JSON.stringify(golden), 'utf8');
      await expect(readPack(source.slug, dir)).rejects.toThrow(/golden\/corporate_tax\.json/);
    } finally {
      await writeFile(path, original, 'utf8');
    }
  });
});
