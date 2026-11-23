/**
 * Statements a country pack inherits from a framework pack.
 *
 * Most countries that report under IFRS for SMEs prescribe no table of
 * captions of their own: the standard lists the minimum line items, and the
 * framework pack `packs/generic` already writes them once, by account type,
 * for any chart. A pack of such a country declares
 *
 * ```json
 * { "inherit": "IFRS-SME",
 *   "statements": [{ "code": "XX-IFRS-SME-SFP", "kind": "balance_sheet" }],
 *   "overrides": [{ "statement": "XX-IFRS-SME-SFP", "line": "A-NC-FIX", "name": "…" }] }
 * ```
 *
 * and gets the framework's lines and rules under its own statement codes,
 * changed only where it says so. The resolution happens here, when the pack is
 * read, and nowhere else: what `ekwo pack check` validates and what
 * `ekwo pack build` writes into the seed is the resolved file, so the database
 * sees ordinary statements and no migration knows inheritance exists.
 *
 * Nothing here knows a country or a framework by name. The family is the
 * `inherit` field of the pack, the framework is whichever pack declares that
 * code in its manifest.
 */
import type { Issue } from './schema.js';

type Json = Record<string, unknown>;

/** A framework pack as inheritance needs it: its code and its raw `statements.json`. */
export interface InheritableFramework {
  code: string;
  statements: Json[];
}

/** The fields of a line an override may give; `code` is the line it names. */
const LINE_FIELDS = [
  'parent',
  'name',
  'sequence',
  'sign',
  'plus',
  'minus',
  'xbrl',
  'legal_reference',
  'source',
  'rules',
] as const;

/**
 * `statements.json` with its inheritance resolved, and what was wrong with it.
 *
 * A file that declares no `inherit` comes back as it is, except that one
 * carrying `overrides` or a statement without lines is refused: both only
 * mean something against a framework. The output has no `inherit` and no
 * `overrides`, only statements with their lines — the shape every pack had
 * before, which the rest of the reader and the compiler take unchanged.
 */
export function resolveInheritedStatements(
  raw: Json,
  framework: InheritableFramework | null,
): { raw: Json; issues: Issue[] } {
  const issues: Issue[] = [];
  const family = typeof raw['inherit'] === 'string' ? (raw['inherit'] as string) : null;
  const statements = (Array.isArray(raw['statements']) ? raw['statements'] : []) as Json[];
  const overrides = (Array.isArray(raw['overrides']) ? raw['overrides'] : []) as Json[];

  if (family === null) {
    for (const statement of statements) {
      if (!Array.isArray(statement['lines'])) {
        issues.push({
          path: `statements.json ${String(statement['code'])}`,
          message: 'has no lines. A statement without lines inherits them, and this file declares no "inherit"',
        });
      }
    }
    if (overrides.length > 0) {
      issues.push({
        path: 'statements.json overrides',
        message: 'override the lines of an inherited statement, and this file declares no "inherit"',
      });
    }
    return { raw, issues };
  }

  if (framework === null) {
    issues.push({
      path: 'statements.json inherit',
      message: `${family} is not the code of a framework pack of this repository`,
    });
    return { raw: { statements: statements.filter((s) => Array.isArray(s['lines'])) }, issues };
  }

  // Each statement without lines takes the framework's statement of its kind,
  // under the pack's code and with whatever the pack says of it on top.
  const inherited = new Map<string, Json[]>();
  const resolved = statements.map((statement) => {
    if (Array.isArray(statement['lines'])) return statement;
    const code = String(statement['code']);
    const kind = String(statement['kind']);
    const candidates = framework.statements.filter((s) => s['kind'] === kind);
    if (candidates.length !== 1) {
      issues.push({
        path: `statements.json ${code}`,
        message:
          candidates.length === 0
            ? `${framework.code} has no ${kind} to inherit; write its lines`
            : `${framework.code} has ${candidates.length} statements of kind ${kind}, and inheritance takes the one`,
      });
      return { ...statement, lines: [] };
    }
    const source = candidates[0] as Json;
    const lines = ((source['lines'] ?? []) as Json[]).map((line) => structuredClone(line));
    inherited.set(code, lines);
    const header = Object.fromEntries(Object.entries(source).filter(([key]) => key !== 'code' && key !== 'lines'));
    return { ...header, ...statement, code, lines };
  });

  // The overrides, in the order written. Each one names an inherited
  // statement, and either a line it carries or a line it does not.
  const touched = new Set<string>();
  overrides.forEach((override, index) => {
    const where = `statements.json overrides[${index}]`;
    const statement = String(override['statement']);
    const lines = inherited.get(statement);
    if (lines === undefined) {
      issues.push({
        path: where,
        message: `${statement} is not a statement of this file that inherits from ${framework.code}`,
      });
      return;
    }
    const added = override['add'] as Json | undefined;
    if (added !== undefined) {
      const code = String(added['code']);
      if (lines.some((line) => line['code'] === code)) {
        issues.push({
          path: where,
          message: `${statement} already carries a line ${code}; change it with "line": "${code}" rather than adding it`,
        });
        return;
      }
      lines.push(structuredClone(added));
      return;
    }
    const code = String(override['line']);
    const line = lines.find((l) => l['code'] === code);
    if (line === undefined) {
      issues.push({
        path: where,
        message:
          `${code} is not a line of ${statement} as inherited from ${framework.code} ` +
          `(${lines.map((l) => String(l['code'])).join(', ')}); add it with "add" instead`,
      });
      return;
    }
    const key = `${statement}:${code}`;
    if (touched.has(key)) {
      issues.push({ path: where, message: `${key} is overridden twice; say it in one override` });
      return;
    }
    touched.add(key);
    const fields = LINE_FIELDS.filter((field) => field in override);
    if (fields.length === 0) {
      issues.push({ path: where, message: `changes nothing of ${key}; give the fields it takes instead` });
      return;
    }
    for (const field of fields) line[field] = structuredClone(override[field]);
  });

  return { raw: { statements: resolved }, issues };
}
