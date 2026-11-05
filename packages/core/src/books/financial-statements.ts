/**
 * The financial statements read back: which schemes a company can be
 * presented on, and a balance sheet or an income statement on one of them.
 *
 * Each is one function of the schema — `available_statements()`, then
 * `financial_statement()` with `unmapped_accounts()` — and the scheme, its
 * lines and the rules that say which accounts each line catches are country
 * pack data, or the generic framework by account type; nothing of a country
 * is here. They lived in the MCP server until the command line printed the
 * same statements, as `ekwo statement`. They prepare figures; they file
 * nothing.
 */

import { type Backend, type Row } from './backend.js';
import { moneyFields } from './format.js';
import { type PeriodArgs } from './reports.js';

export interface ListStatementsArgs {
  company_id: string;
  /** The day to read the schemes in force at, YYYY-MM-DD. Left out: today. */
  at?: string | undefined;
}

/**
 * The schemes of the company's country and chart of accounts, and the
 * generic framework that fits any chart, with the ones its chart reports on
 * marked as the default.
 */
export async function listStatements(backend: Backend, args: ListStatementsArgs): Promise<unknown> {
  const rows = await backend.rpc<Row>('available_statements', {
    p_company_id: args.company_id,
    p_at: args.at ?? null,
  });
  return {
    statements: rows,
    note:
      rows.length === 0
        ? 'No statement applies to this company. Its country pack declares none and the generic framework has not been seeded.'
        : 'is_default marks the schemes the chart of accounts of this company reports on. The ones with no country are the generic framework by account type, which fits any chart.',
  };
}

export interface FinancialStatementArgs extends PeriodArgs {
  /** The scheme, by its code, from `listStatements()`. */
  statement_code: string;
}

/**
 * Every line of the scheme for the period, nil included, in the order it is
 * printed, and the accounts of the company no line of it catches.
 */
export async function financialStatement(backend: Backend, args: FinancialStatementArgs): Promise<unknown> {
  const [lines, unmapped] = await Promise.all([
    backend.rpc<Row>('financial_statement', {
      p_company_id: args.company_id,
      p_statement_code: args.statement_code,
      p_from: args.from,
      p_to: args.to,
    }),
    backend.rpc<Row>('unmapped_accounts', {
      p_company_id: args.company_id,
      p_statement_code: args.statement_code,
      p_from: args.from,
      p_to: args.to,
    }),
  ]);

  return {
    period: { from: args.from, to: args.to },
    statement_code: args.statement_code,
    lines: moneyFields(lines, ['amount']),
    unmapped_accounts: moneyFields(unmapped, ['balance']),
    note:
      'Every line of the scheme is returned, nil included, in the order it is printed; a line flagged is_total is derived from the others. ' +
      (unmapped.length === 0
        ? 'No account of this company falls outside the scheme, so it ties out.'
        : 'unmapped_accounts lists accounts this scheme catches on no line — say so rather than presenting a statement that does not tie out.'),
  };
}
