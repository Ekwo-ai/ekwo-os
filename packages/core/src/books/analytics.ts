/**
 * The analytic plan, and the result of each of its values.
 *
 * `analytic_report()` of the schema reads the posted ledger and gives, for
 * each value of one axis, the income, the expense and the result, with one
 * more row for the part of the income statement no share of the axis
 * reaches (decision 0075). This file finds the axis by its code, calls the
 * function, and puts the unassigned row beside the others rather than among
 * them. It adds nothing up: the rows add up to the income statement because
 * the database says they do, and a total worked out here would be a second
 * answer (decision 0056).
 */

import { BooksError, type Backend, type Row } from './backend.js';
import { moneyFields } from './format.js';

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

/** The axes of a company, each with its values, in the order of their codes. */
export async function listAnalyticAxes(backend: Backend, args: ListAnalyticAxesArgs): Promise<unknown> {
  const [axes, values] = await Promise.all([
    backend.select<Row>({
      table: 'analytic_axes',
      columns: ['id', 'code', 'name', 'active'],
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
    ['income', 'expense', 'result'],
  );
  const unassigned = rows.find((row) => row['analytic_value_id'] === null) ?? null;

  return {
    period: { from: args.from, to: args.to },
    axis,
    values: rows.filter((row) => row['analytic_value_id'] !== null),
    unassigned:
      unassigned === null
        ? null
        : { income: unassigned['income'], expense: unassigned['expense'], result: unassigned['result'] },
    note:
      'Read from the posted ledger, closing entry left out, in the company\'s currency: income on the income accounts, expense on the expense accounts, result the difference. unassigned is the part of the income statement no share of this axis reaches, so the values and unassigned add up to the result of the period. Values that nest are each on their own row with their parent_id; a total per parent is a sum of rows, not a figure of its own.',
  };
}
