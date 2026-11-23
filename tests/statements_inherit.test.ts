/**
 * A pack whose country prescribes no statement format inherits the
 * framework's statements (`"inherit"` in `statements.json`) and overrides the
 * lines where it differs. The resolution is done when the pack is read, so the
 * seed carries ordinary statements and no migration knows about it.
 *
 * Every expectation here is read from the framework pack itself: which lines
 * it carries and which kinds of statement it offers.
 */
import { cp, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { resolveInheritedStatements, type InheritableFramework } from '../packages/cli/src/pack/inherit.js';
import { GENERIC_PACK, readPack } from '../packages/cli/src/pack/read.js';
import { allPacks, packsRoot } from './helpers/packs.js';

type Json = Record<string, unknown>;

const frameworkManifest = JSON.parse(await readFile(join(packsRoot, GENERIC_PACK, 'pack.json'), 'utf8')) as Json;
const frameworkStatements = (
  JSON.parse(await readFile(join(packsRoot, GENERIC_PACK, 'statements.json'), 'utf8')) as { statements: Json[] }
).statements;
const framework: InheritableFramework = { code: String(frameworkManifest['code']), statements: frameworkStatements };

/** The framework's balance sheet, one of its lines that is not a total, and one that is. */
const sheet = frameworkStatements.find((s) => s['kind'] === 'balance_sheet')!;
const sheetLines = sheet['lines'] as Json[];
const leaf = sheetLines.find((l) => l['is_total'] !== true)!;
const total = sheetLines.find((l) => l['is_total'] === true)!;

/** A file that inherits the balance sheet under its own code, with these overrides. */
function inheriting(overrides: Json[] = []): Json {
  return {
    inherit: framework.code,
    statements: [{ code: 'TEST-SFP', kind: 'balance_sheet', name: 'Statement of financial position' }],
    overrides,
  };
}

function resolvedLines(raw: Json): Json[] {
  const statements = raw['statements'] as Json[];
  return statements[0]!['lines'] as Json[];
}

describe('a statements.json that inherits', () => {
  it('takes every line of the framework statement of its kind, under its own code', () => {
    const { raw, issues } = resolveInheritedStatements(inheriting(), framework);
    expect(issues).toEqual([]);
    const statement = (raw['statements'] as Json[])[0]!;
    expect(statement['code']).toBe('TEST-SFP');
    expect(statement['kind']).toBe('balance_sheet');
    expect(resolvedLines(raw)).toEqual(sheetLines);
    expect(raw).not.toHaveProperty('inherit');
    expect(raw).not.toHaveProperty('overrides');
  });

  it('keeps what the pack says of the statement, and the framework says the rest', () => {
    const { raw } = resolveInheritedStatements(inheriting(), framework);
    const statement = (raw['statements'] as Json[])[0]!;
    expect(statement['name']).toBe('Statement of financial position');
    expect(statement['result_in_progress']).toBe(sheet['result_in_progress']);
    expect(statement['legal_reference']).toBe(sheet['legal_reference']);
  });

  it('never changes the framework it read', () => {
    const before = JSON.stringify(frameworkStatements);
    resolveInheritedStatements(
      inheriting([{ statement: 'TEST-SFP', line: leaf['code'], name: 'A caption of the country' }]),
      framework,
    );
    expect(JSON.stringify(frameworkStatements)).toBe(before);
  });

  it('renames a line and changes only the fields it gives', () => {
    const { raw, issues } = resolveInheritedStatements(
      inheriting([{ statement: 'TEST-SFP', line: leaf['code'], name: 'A caption of the country' }]),
      framework,
    );
    expect(issues).toEqual([]);
    const line = resolvedLines(raw).find((l) => l['code'] === leaf['code'])!;
    expect(line).toEqual({ ...leaf, name: 'A caption of the country' });
  });

  it('adds a line, and a total adds it once its plus says so', () => {
    const added = { code: 'X-NEW', parent: total['code'], name: 'A line of the country', sequence: 1, rules: [] };
    const { raw, issues } = resolveInheritedStatements(
      inheriting([
        { statement: 'TEST-SFP', add: added },
        { statement: 'TEST-SFP', line: total['code'], plus: [...(total['plus'] as string[]), 'X-NEW'] },
      ]),
      framework,
    );
    expect(issues).toEqual([]);
    const lines = resolvedLines(raw);
    expect(lines).toContainEqual(added);
    expect(lines.find((l) => l['code'] === total['code'])!['plus']).toContain('X-NEW');
    expect(lines).toHaveLength(sheetLines.length + 1);
  });

  it('refuses an override that names no line of the inherited statement', () => {
    const { issues } = resolveInheritedStatements(
      inheriting([{ statement: 'TEST-SFP', line: 'NOT-A-LINE', name: 'Anything' }]),
      framework,
    );
    expect(issues).toHaveLength(1);
    expect(issues[0]!.message).toContain(`NOT-A-LINE is not a line of TEST-SFP as inherited from ${framework.code}`);
  });

  it('refuses adding a line the framework already carries', () => {
    const { issues } = resolveInheritedStatements(
      inheriting([{ statement: 'TEST-SFP', add: { code: leaf['code'], name: 'Again' } }]),
      framework,
    );
    expect(issues.map((i) => i.message).join('\n')).toContain(`already carries a line ${String(leaf['code'])}`);
  });

  it('refuses an override of a statement that inherits nothing', () => {
    const { issues } = resolveInheritedStatements(
      inheriting([{ statement: 'OTHER', line: leaf['code'], name: 'Anything' }]),
      framework,
    );
    expect(issues[0]!.message).toContain('OTHER is not a statement of this file that inherits');
  });

  it('refuses an override that changes nothing, and a line overridden twice', () => {
    const once = { statement: 'TEST-SFP', line: leaf['code'], name: 'Once' };
    expect(
      resolveInheritedStatements(inheriting([{ statement: 'TEST-SFP', line: leaf['code'] }]), framework).issues[0]!
        .message,
    ).toContain('changes nothing');
    expect(resolveInheritedStatements(inheriting([once, once]), framework).issues[0]!.message).toContain(
      'overridden twice',
    );
  });

  it('refuses a framework nobody declares, and statements without lines or overrides without inherit', () => {
    expect(resolveInheritedStatements(inheriting(), null).issues[0]!.message).toContain(
      'is not the code of a framework pack',
    );
    const { issues } = resolveInheritedStatements(
      { statements: [{ code: 'TEST-SFP', kind: 'balance_sheet' }], overrides: [{ statement: 'TEST-SFP', line: 'A' }] },
      framework,
    );
    expect(issues.map((i) => i.message)).toEqual([
      expect.stringContaining('declares no "inherit"'),
      expect.stringContaining('declares no "inherit"'),
    ]);
  });

  it('refuses inheriting a kind the framework does not carry', () => {
    const kinds = new Set(frameworkStatements.map((s) => s['kind']));
    const absent = ['balance_sheet', 'income_statement', 'cash_flow', 'allocation'].find((k) => !kinds.has(k))!;
    const { issues } = resolveInheritedStatements(
      { inherit: framework.code, statements: [{ code: 'TEST-X', kind: absent }] },
      framework,
    );
    expect(issues[0]!.message).toContain(`has no ${absent} to inherit`);
  });

  it('leaves a file that inherits nothing exactly as it was', () => {
    const own = { statements: [{ ...sheet, code: 'OWN' }] };
    expect(resolveInheritedStatements(own, framework)).toEqual({ raw: own, issues: [] });
  });
});

/** The packs of this checkout whose `statements.json` inherits, with the file as written. */
const inheritors = (
  await Promise.all(
    allPacks.map(async (pack) => {
      const path = join(packsRoot, pack.slug, 'statements.json');
      const raw = JSON.parse(await readFile(path, 'utf8').catch(() => '{}')) as Json;
      return { pack, raw };
    }),
  )
).filter(({ raw }) => typeof raw['inherit'] === 'string');

describe('the packs that inherit', () => {
  it('are there, or the tests below prove nothing', () => {
    expect(inheritors.length).toBeGreaterThan(1);
  });

  for (const { pack, raw } of inheritors) {
    const own = new Set(
      (raw['statements'] as Json[]).filter((s) => !Array.isArray(s['lines'])).map((s) => String(s['code'])),
    );

    it(`${pack.slug}: every inherited line is proved by the pack's own golden`, async () => {
      const golden = JSON.parse(await readFile(join(packsRoot, pack.slug, 'golden', 'statements.json'), 'utf8')) as {
        statements: { code: string; lines: Record<string, string> }[];
      };
      for (const statement of pack.statements.filter((s) => own.has(s.code))) {
        const expected = golden.statements.find((g) => g.code === statement.code);
        expect(expected, `${statement.code} in golden/statements.json`).toBeDefined();
        expect(Object.keys(expected!.lines).sort()).toEqual(statement.lines.map((l) => l.code).sort());
      }
    });

    it(`${pack.slug}: carries the framework's lines and rules where it overrides nothing`, () => {
      const overridden = new Set(
        ((raw['overrides'] ?? []) as Json[]).map((o) => `${String(o['statement'])}:${String(o['line'] ?? '')}`),
      );
      for (const statement of pack.statements.filter((s) => own.has(s.code))) {
        const source = frameworkStatements.find((f) => f['kind'] === statement.kind)!;
        for (const line of source['lines'] as Json[]) {
          const resolved = statement.lines.find((l) => l.code === line['code']);
          expect(resolved, `${statement.code}.${String(line['code'])}`).toBeDefined();
          if (overridden.has(`${statement.code}:${String(line['code'])}`)) continue;
          expect(resolved!.name).toBe(line['name']);
          expect(resolved!.rules.map((r) => r.account_type)).toEqual(
            ((line['rules'] ?? []) as Json[]).map((r) => r['account_type']),
          );
        }
      }
    });
  }

  it('ekwo pack check refuses an override that names a line the inherited statement does not carry', async () => {
    const { pack, raw } = inheritors[0]!;
    const statement = (raw['statements'] as Json[]).find((s) => !Array.isArray(s['lines']))!;
    const dir = await mkdtemp(join(tmpdir(), 'ekwo-inherit-'));
    try {
      for (const folder of ['schema', GENERIC_PACK, pack.slug]) {
        await cp(join(packsRoot, folder), join(dir, folder), { recursive: true });
      }
      const edited = {
        ...raw,
        overrides: [
          ...((raw['overrides'] ?? []) as Json[]),
          { statement: statement['code'], line: 'NOT-A-LINE', name: 'Anything' },
        ],
      };
      await writeFile(join(dir, pack.slug, 'statements.json'), JSON.stringify(edited), 'utf8');
      const message = await readPack(pack.slug, dir).then(
        () => '',
        (e: Error) => e.message,
      );
      expect(message).toContain(`NOT-A-LINE is not a line of ${String(statement['code'])} as inherited from`);
    } finally {
      await rm(dir, { recursive: true, force: true });
    }
  });
});
