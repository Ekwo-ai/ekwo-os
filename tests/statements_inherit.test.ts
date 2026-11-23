/**
 * A pack whose country prescribes no statement format inherits the
 * framework's statements (`"inherit"` in `statements.json`) and overrides the
 * lines where it differs. The resolution is done when the pack is read, so the
 * seed carries ordinary statements and no migration knows about it.
 *
 * Every expectation here is read from the framework pack itself: which lines
 * it carries and which kinds of statement it offers.
 */
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import { resolveInheritedStatements, type InheritableFramework } from '../packages/cli/src/pack/inherit.js';
import { GENERIC_PACK } from '../packages/cli/src/pack/read.js';
import { packsRoot } from './helpers/packs.js';

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
