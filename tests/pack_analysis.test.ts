import { cp, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { compilePack, REQUIRED_AGGREGATES, readPack } from '../packages/cli/src/index.js';
import { allPacks, packsRoot, packWhere, readSchemaEnum } from './helpers/packs.js';

// The `analysis` section of a pack: what `ekwo pack check` reads of it, what
// it refuses, and what it compiles to.
//
// The refusals are tried on a copy of a pack that carries the section, broken
// one way at a time. Nothing here names a country: the pack is whichever one
// carries the section, and what each refusal needs — a chart, an account, a
// rule — is read from that pack.

type Rule = Record<string, unknown>;
type Section = Record<string, unknown> & {
  charts?: string[];
  aggregates: (Record<string, unknown> & { code: string; rules: Rule[] })[];
};

const source = packWhere('that carries an analysis section', (pack) => pack.analysis !== null);

let dir: string;

beforeAll(async () => {
  dir = await mkdtemp(join(tmpdir(), 'ekwo-analysis-'));
  await cp(join(packsRoot, 'schema'), join(dir, 'schema'), { recursive: true });
  await cp(source.dir, join(dir, source.slug), { recursive: true });
});

afterAll(async () => {
  await rm(dir, { recursive: true, force: true });
});

const sectionPath = (): string => join(dir, source.slug, 'analysis.json');

/** Reads the copy with its section changed, and gives back what the reader said. */
async function broken(change: (section: Section) => void): Promise<string> {
  const original = await readFile(sectionPath(), 'utf8');
  const section = JSON.parse(original) as Section;
  change(section);
  await writeFile(sectionPath(), JSON.stringify(section), 'utf8');
  try {
    await readPack(source.slug, dir);
    return 'accepted';
  } catch (error) {
    return (error as Error).message;
  } finally {
    await writeFile(sectionPath(), original, 'utf8');
  }
}

describe('an analysis section', () => {
  it('defines the four aggregates every analysis starts from, each with the text it reads', () => {
    for (const pack of allPacks.filter((p) => p.analysis !== null)) {
      const codes = pack.analysis!.aggregates.map((a) => a.code);
      for (const required of REQUIRED_AGGREGATES) expect(codes, pack.slug).toContain(required);
      for (const aggregate of pack.analysis!.aggregates) {
        expect(aggregate.legal_reference.length, `${pack.slug} ${aggregate.code}`).toBeGreaterThan(10);
        // A pack someone maintains names where that text is read.
        if (pack.manifest.certification?.status !== 'community') {
          expect(aggregate.source, `${pack.slug} ${aggregate.code}`).not.toBeNull();
        }
      }
    }
  });

  it('only uses the aggregates of the closed list', () => {
    const published = readSchemaEnum('analysis_aggregate', 'code');
    expect(published).toEqual(expect.arrayContaining([...REQUIRED_AGGREGATES]));
    for (const pack of allPacks.filter((p) => p.analysis !== null)) {
      for (const aggregate of pack.analysis!.aggregates) expect(published).toContain(aggregate.code);
    }
  });

  it('is written for the default chart when it names none', () => {
    const chart = source.charts.find((c) => c.is_default)!;
    expect(source.analysis!.charts).toEqual([chart.code]);
  });

  it('compiles into the pack seed, rules and all, and a pack without one compiles to nothing of it', () => {
    const seed = compilePack(source);
    expect(seed).toContain('insert into analysis_templates');
    expect(seed).toContain('insert into analysis_rules');
    expect(seed).toContain('delete from analysis_rules r');
    const rules = source.analysis!.aggregates.reduce((n, a) => n + a.rules.length, 0) * source.analysis!.charts.length;
    const block = seed.slice(seed.indexOf('insert into analysis_rules'));
    const rows = block.slice(0, block.indexOf(') as v')).split('\n').filter((l) => l.startsWith(`    ('${source.manifest.country}'`));
    expect(rows).toHaveLength(rules);

    const silent = allPacks.find((p) => p.analysis === null)!;
    expect(compilePack(silent)).not.toContain('analysis_');
  });
});

describe('what `ekwo pack check` refuses of an analysis section', () => {
  it('reads the copy as it reads the pack', async () => {
    expect(await broken(() => undefined)).toBe('accepted');
  });

  it('an aggregate outside the closed list', async () => {
    const message = await broken((s) => {
      s.aggregates[0]!.code = 'ebitda';
    });
    expect(message).toMatch(/analysis\.json/);
  });

  it('one of the four every analysis starts from, left out', async () => {
    for (const required of REQUIRED_AGGREGATES) {
      const message = await broken((s) => {
        s.aggregates = s.aggregates.filter((a) => a.code !== required);
      });
      expect(message).toContain(`defines no ${required}`);
    }
  });

  it('an aggregate defined twice', async () => {
    const message = await broken((s) => {
      s.aggregates.push(JSON.parse(JSON.stringify(s.aggregates[0])) as Section['aggregates'][number]);
    });
    expect(message).toContain('is defined twice');
  });

  it('an aggregate with no article', async () => {
    const message = await broken((s) => {
      delete s.aggregates[0]!['legal_reference'];
    });
    expect(message).toMatch(/legal_reference/);
  });

  it('a rule that reaches no account of the chart', async () => {
    // A head of code no account of the chart starts with: every code of the
    // chart is read, and the first two-character head nobody uses is taken.
    const heads = new Set(source.accounts.map((a) => a.code.slice(0, 2)));
    const unused = Array.from({ length: 90 }, (_, i) => String(i + 10)).find((h) => !heads.has(h))!;
    const message = await broken((s) => {
      s.aggregates[0]!.rules.push({ kind: 'code_range', code_from: unused, code_to: unused });
    });
    expect(message).toContain(`code_range ${unused}..${unused} reaches no account of the chart`);
  });

  it('a rule missing what its kind needs', async () => {
    const message = await broken((s) => {
      s.aggregates[0]!.rules.push({ kind: 'code_range', code_from: source.accounts[0]!.code });
    });
    expect(message).toContain('a code_range rule names both code_from and code_to');
  });

  it('a rule of a kind no statement knows', async () => {
    const message = await broken((s) => {
      s.aggregates[0]!.rules.push({ kind: 'expression', code_from: '1' });
    });
    expect(message).toMatch(/analysis\.json/);
  });

  it('a chart the pack does not carry', async () => {
    const message = await broken((s) => {
      s.charts = ['no-such-chart'];
    });
    expect(message).toContain('no-such-chart is not a chart of this pack');
  });

  it('a source the register does not hold', async () => {
    const message = await broken((s) => {
      s.aggregates[0]!['source'] = 'no-such-source';
    });
    expect(message).toContain('no-such-source');
  });
});
