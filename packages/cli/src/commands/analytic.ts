/**
 * `ekwo analytic axes` and `ekwo analytic report` — `listAnalyticAxes()` and
 * `analyticReport()` of the core, which are the MCP server's
 * `list_analytic_axes` and `analytic_report`.
 *
 * The report is `analytic_report()` of the schema: the result of each value
 * of one axis, read from the posted ledger, and the part of the income
 * statement no share of the axis reaches. Every figure is the database's and
 * is printed as it came (decision 0056).
 */

import { analyticReport, listAnalyticAxes } from '@ekwo-ai/core';
import { UsageError, rejectUnknownFlags, stringFlag, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, openBooks, required, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, note, table } from '../ui.js';

type Row = Record<string, unknown>;

const AXES_FLAGS = [...BOOKS_FLAGS] as const;
const REPORT_FLAGS = [...BOOKS_FLAGS, 'axis', 'from', 'to'] as const;

const text = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

export async function analyticCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  const action = args.positional[0];
  if (action === 'axes') return axes(args, deps);
  if (action === 'report') return report(args, deps);
  throw new UsageError('usage: ekwo analytic axes | ekwo analytic report --axis <code> --from <YYYY-MM-DD> --to <YYYY-MM-DD>');
}

async function axes(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, AXES_FLAGS);
  const { backend, company } = await openBooks(args, deps);
  const result = (await listAnalyticAxes(backend, { company_id: company.id })) as { axes: (Row & { values: Row[] })[] };
  setResult(result);

  heading(`Analytic axes of ${company.name}`);
  if (result.axes.length === 0) note(dim('None.'));
  for (const axis of result.axes) {
    note(`${text(axis['code'])} ${dim(text(axis['name']))}${axis['active'] === false ? dim(' (retired)') : ''}`);
    table(
      [{ title: 'code' }, { title: 'name' }, { title: 'active' }],
      axis.values.map((value) => [text(value['code']), text(value['name']), value['active'] === false ? 'no' : 'yes']),
      '    ',
    );
  }
  return 0;
}

async function report(args: ParsedArgs, deps: BooksDeps): Promise<number> {
  rejectUnknownFlags(args, REPORT_FLAGS);
  const axis = required(stringFlag(args, 'axis'), 'the analytic axis', '--axis <code>');
  const from = required(stringFlag(args, 'from'), 'the first day of the period', '--from <YYYY-MM-DD>');
  const to = required(stringFlag(args, 'to'), 'the last day of the period', '--to <YYYY-MM-DD>');
  const { backend, company } = await openBooks(args, deps);

  const result = (await analyticReport(backend, { company_id: company.id, axis, from, to })) as {
    axis: Row;
    values: Row[];
    unassigned: Row | null;
    note: string;
  };
  setResult(result);

  heading(`Result by ${text(result.axis['code'])}, ${from} to ${to}, in ${company.name}`);
  const rows = result.values.map((value) => [text(value['code']), text(value['name']), text(value['income']), text(value['expense']), text(value['result'])]);
  if (result.unassigned !== null) {
    rows.push([dim('unassigned'), '', text(result.unassigned['income']), text(result.unassigned['expense']), text(result.unassigned['result'])]);
  }
  table(
    [
      { title: 'value' },
      { title: 'name' },
      { title: 'income', align: 'right' },
      { title: 'expense', align: 'right' },
      { title: 'result', align: 'right' },
    ],
    rows,
  );
  note(dim(result.note));
  return 0;
}
