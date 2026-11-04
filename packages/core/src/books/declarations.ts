/**
 * The declarations read back: the VAT return of a period and the
 * recapitulative statement of European Union supplies.
 *
 * Each is one function of the schema — `vat_return()` and `ec_sales_list()`
 * — and both answer from what was posted. The form, its boxes and the cadence
 * a company files it on are country pack data the database reads; nothing of
 * a country is here. They lived in the MCP server until the command line
 * printed the same declarations, as `ekwo vat` and `ekwo ecsl`. Both prepare
 * figures; neither files anything.
 */

import { type Backend, type Row } from './backend.js';
import { moneyFields } from './format.js';
import { type PeriodArgs } from './reports.js';

export interface DeclarationArgs extends PeriodArgs {
  /**
   * The declaration form, where the installation carries several. For the
   * VAT return, left out means the form the company files; for the
   * statement, naming it has the period checked against the cadence the
   * company files it on.
   */
  report_code?: string | undefined;
}

/**
 * The boxes of the VAT return for a period, with their names, their order
 * of calculation and of printing, and the form they belong to.
 */
export async function vatReturn(backend: Backend, args: DeclarationArgs): Promise<unknown> {
  const rows = await backend.rpc<Row>('vat_return', {
    p_company_id: args.company_id,
    p_from: args.from,
    p_to: args.to,
    p_report_code: args.report_code ?? null,
  });
  const form = rows.find((row) => row['report_code'] !== null)?.['report_code'] ?? null;
  return {
    period: { from: args.from, to: args.to },
    report_code: form,
    boxes: moneyFields(rows, ['amount']),
    note:
      'A box flagged computed is a total the form derives from the others, following the plus and minus lists of the country pack, or the rate of one other box where the form states a line as a multiplication; hidden means the form does not print it. Everything else is summed from what the tax postings wrote on the ledger lines. Order by print_sequence to print the form the way its administration does, which is not always the order the boxes are worked out in.',
  };
}

/**
 * Who, in another Member State, was supplied without VAT over a period: one
 * line per customer VAT number and per nature, credit notes deducted, and how
 * many of those lines cannot be filed as they stand.
 */
export async function ecSalesList(backend: Backend, args: DeclarationArgs): Promise<unknown> {
  const rows = await backend.rpc<Row>('ec_sales_list', {
    p_company_id: args.company_id,
    p_from: args.from,
    p_to: args.to,
    p_report_code: args.report_code ?? null,
  });
  const undeclarable = rows.filter((row) => row['issue'] !== null);
  return {
    period: { from: args.from, to: args.to },
    lines: moneyFields(rows, ['amount']),
    undeclarable_lines: undeclarable.length,
    note:
      'One line per customer VAT number and per nature of supply — goods, services — summed from the posted ledger in the company currency, credit notes deducted. A line carrying an issue cannot be filed as it stands: no_vat_number means the customer has none recorded, vat_country_is_the_company_country means the number is not in another Member State. Report those separately instead of adding them into the total, and do not remove them from the figures. It prepares a statement; it files nothing.',
  };
}
