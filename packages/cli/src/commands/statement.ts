/**
 * `ekwo statement` — the financial statements read in a terminal:
 * `listStatements()` and `financialStatement()` of the core, which are the
 * MCP server's `list_statements` and `financial_statement`.
 *
 * Without a code it lists the schemes the company can be presented on; with
 * one, it prints that balance sheet or income statement for the period, line
 * by line in the order the scheme prints them, and names every account no
 * line catches. The scheme, its lines and its rules are country pack data, or
 * the generic framework by account type; every figure is the database's and
 * is printed as it came (decision 0056). It prepares figures; it files
 * nothing.
 */

import { financialStatement, listStatements } from '@ekwo-ai/core';
import { UsageError, rejectUnknownFlags, stringFlag, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, openBooks, required, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { bold, dim, heading, note, table, warn } from '../ui.js';

type Row = Record<string, unknown>;

const LIST_FLAGS = [...BOOKS_FLAGS, 'at'] as const;
const STATEMENT_FLAGS = [...BOOKS_FLAGS, 'from', 'to'] as const;

const USAGE = 'usage: ekwo statement [--at <YYYY-MM-DD>] | ekwo statement <code> --from <YYYY-MM-DD> --to <YYYY-MM-DD>';

const cell = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

/**
 * How deep a line sits under the lines it adds up to, read from the parent
 * codes of the scheme — the layout of the page, never a figure.
 */
function depths(lines: Row[]): Map<string, number> {
  const parent = new Map(lines.map((l) => [cell(l['line_code']), cell(l['parent_code'])]));
  const depth = new Map<string, number>();
  for (const code of parent.keys()) {
    let level = 0;
    const seen = new Set([code]);
    for (let up = parent.get(code); up && parent.has(up) && !seen.has(up); up = parent.get(up)) {
      seen.add(up);
      level += 1;
    }
    depth.set(code, level);
  }
  return depth;
}

export async function statementCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  if (args.positional.length > 1) throw new UsageError(`too_many_arguments: ${args.positional.slice(1).join(' ')}. ${USAGE}`);
  const code = args.positional[0];
  return code === undefined ? await listCommand(args, deps) : await printCommand(code, args, deps);
}

async function listCommand(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, LIST_FLAGS);
  const at = stringFlag(args, 'at');
  const { backend, company } = await openBooks(args, deps);

  const result = (await listStatements(backend, { company_id: company.id, at })) as { statements: Row[] };
  setResult(result);

  heading(`Financial statements of ${company.name}${at === undefined ? '' : `, in force at ${at}`}`);
  if (result.statements.length === 0) {
    note(dim('No statement applies to this company: its country pack declares none and the generic framework is not seeded.'));
    return 0;
  }
  table(
    [{ title: 'code' }, { title: 'name' }, { title: 'kind' }, { title: 'framework' }, { title: 'country' }, { title: '' }],
    result.statements.map((s) => [
      cell(s['code']), cell(s['name']), cell(s['kind']), cell(s['framework']), cell(s['country']),
      s['is_default'] === true ? dim('default') : '',
    ]),
  );
  note(dim('default: a scheme the chart of accounts of this company reports on. No country: the generic framework by account type, which fits any chart.'));
  note(dim('ekwo statement <code> --from <date> --to <date> prints one.'));
  return 0;
}

async function printCommand(code: string, args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, STATEMENT_FLAGS);
  // A statement covers a period the caller names: neither day is taken to be today.
  const from = required(stringFlag(args, 'from'), 'the first day of the period', `--from <YYYY-MM-DD>. ${USAGE}`);
  const to = required(stringFlag(args, 'to'), 'the last day of the period', `--to <YYYY-MM-DD>. ${USAGE}`);
  const { backend, company } = await openBooks(args, deps);

  const result = (await financialStatement(backend, { company_id: company.id, statement_code: code, from, to })) as {
    lines: Row[];
    unmapped_accounts: Row[];
  };
  setResult(result);

  heading(`${code} of ${company.name}, ${from} to ${to}`);
  if (result.lines.length === 0) note(dim(`The scheme ${code} has no line: see ekwo statement for the codes of this company.`));
  else {
    const depth = depths(result.lines);
    table(
      [{ title: 'line' }, { title: 'name' }, { title: 'amount', align: 'right' }],
      result.lines.map((l) => {
        const name = `${'  '.repeat(depth.get(cell(l['line_code'])) ?? 0)}${cell(l['name'])}`;
        const total = l['is_total'] === true;
        return [cell(l['line_code']), total ? bold(name) : name, total ? bold(cell(l['amount'])) : cell(l['amount'])];
      }),
    );
  }
  if (result.unmapped_accounts.length > 0) {
    warn(
      `${result.unmapped_accounts.length} account${result.unmapped_accounts.length === 1 ? '' : 's'} with a balance ${result.unmapped_accounts.length === 1 ? 'falls' : 'fall'} on no line of ${code}, so the statement does not tie out:`,
    );
    table(
      [{ title: 'account' }, { title: 'name' }, { title: 'type' }, { title: 'balance', align: 'right' }],
      result.unmapped_accounts.map((a) => [cell(a['account_code']), cell(a['account_name']), cell(a['account_type']), cell(a['balance'])]),
    );
  }
  note(dim('In the order the scheme prints its lines; a total in bold is derived from the lines under it. Summed from posted entries.'));
  note(dim('It prepares figures; it files nothing.'));
  return 0;
}
