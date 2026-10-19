/**
 * The analytic plan, and the result of each of its values.
 *
 * `analytic_report()` of the schema reads the posted ledger and gives, for
 * each value of one axis, the income, the expense, the result and the
 * movement of the fixed assets — a parent with the subtotal of the values
 * below it, its own amount in the `direct_` columns — with one more row for
 * the part no share of the axis reaches, and one for the total (decision
 * 0076). This file finds the axis by its code, calls the function, and puts
 * the unassigned and the total rows beside the values rather than among
 * them. It adds nothing up: the subtotals and the total are the database's,
 * and a sum worked out here would be a second answer (decision 0056).
 */

import { BooksError, type Backend, type Row } from './backend.js';
import { moneyFields } from './format.js';

const MONEY = [
  'income',
  'expense',
  'result',
  'fixed_assets',
  'direct_income',
  'direct_expense',
  'direct_result',
  'direct_fixed_assets',
];

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export interface ListAnalyticAxesArgs {
  company_id: string;
}

export interface AnalyticReportArgs {
  company_id: string;
  /** The axis, by its code or its id. */
  axis: string;
  from: string;
  to: string;
}

/**
 * The axes of a company, each with its values, in the order of their codes.
 * `required_on` says which lines must carry the axis whole at posting: none,
 * expense, income or result.
 */
export async function listAnalyticAxes(backend: Backend, args: ListAnalyticAxesArgs): Promise<unknown> {
  const [axes, values] = await Promise.all([
    backend.select<Row>({
      table: 'analytic_axes',
      columns: ['id', 'code', 'name', 'active', 'required_on'],
      where: [{ column: 'company_id', op: 'eq', value: args.company_id }],
      order: [{ column: 'code' }],
    }),
    backend.select<Row>({
      table: 'analytic_values',
      columns: ['id', 'axis_id', 'code', 'name', 'parent_id', 'active'],
      where: [{ column: 'company_id', op: 'eq', value: args.company_id }],
      order: [{ column: 'code' }],
    }),
  ]);
  return {
    axes: axes.map((axis) => ({
      ...axis,
      values: values
        .filter((value) => value['axis_id'] === axis['id'])
        .map(({ axis_id: _axis, ...value }) => value),
    })),
    count: axes.length,
  };
}

/** The axis a caller named, by code or by id, or the refusal that says which exist. */
async function axisOf(backend: Backend, company: string, axis: string): Promise<Row> {
  const rows = await backend.select<Row>({
    table: 'analytic_axes',
    columns: ['id', 'code', 'name'],
    where: [
      { column: 'company_id', op: 'eq', value: company },
      UUID.test(axis) ? { column: 'id', op: 'eq', value: axis } : { column: 'code', op: 'eq', value: axis },
    ],
  });
  const found = rows[0];
  if (found === undefined) {
    throw new BooksError(
      `unknown_analytic_axis: no analytic axis "${axis}" in this company. list_analytic_axes (ekwo analytic axes) names the ones that exist.`,
    );
  }
  return found;
}

export async function analyticReport(backend: Backend, args: AnalyticReportArgs): Promise<unknown> {
  const axis = await axisOf(backend, args.company_id, args.axis);
  const rows = moneyFields(
    await backend.rpc<Row>('analytic_report', {
      p_company_id: args.company_id,
      p_axis_id: axis['id'],
      p_from: args.from,
      p_to: args.to,
    }),
    MONEY,
  );
  const only = (kind: string): Row | null => {
    const row = rows.find((r) => r['row_kind'] === kind);
    return row === undefined ? null : Object.fromEntries(MONEY.map((key) => [key, row[key]]));
  };

  return {
    period: { from: args.from, to: args.to },
    axis,
    values: rows.filter((row) => row['row_kind'] === 'value').map(({ row_kind: _kind, ...row }) => row),
    unassigned: only('unassigned'),
    total: only('total'),
    note:
      'Read from the posted ledger, closing entry left out, in the company\'s currency: income on the income accounts, expense on the expense accounts, result the difference, and fixed_assets the net movement of the fixed-asset accounts (debit less credit, ordinary entries only), beside the result and never in it. A value with others below it (parent_id, level) holds the subtotal of all of them; its own amount alone is in the direct_ columns. unassigned is the part no share of this axis reaches, and total the whole period: the direct_ amounts of the values and unassigned add up to total, and so do the values of level 0 and unassigned.',
  };
}
