/**
 * `ekwo vat` and `ekwo ecsl` — the declarations of a period read in a
 * terminal: `vatReturn()` and `ecSalesList()` of the core, which are the MCP
 * server's `vat_return` and `ec_sales_list`.
 *
 * The form, its boxes, the order its administration prints them in and the
 * cadence a company files it on are country pack data the database reads; a
 * period the company does not file that form on is refused there, by name.
 * Every figure is the database's and is printed as it came (decision 0056).
 * Both prepare figures; neither files anything.
 */

import { ecSalesList, vatReturn } from '@ekwo-ai/core';
import { UsageError, rejectUnknownFlags, stringFlag, type ParsedArgs } from '../args.js';
import { BOOKS_FLAGS, openBooks, required, type BooksDeps } from '../books.js';
import { setResult } from '../output.js';
import { dim, heading, note, table, warn } from '../ui.js';

type Row = Record<string, unknown>;

const DECLARATION_FLAGS = [...BOOKS_FLAGS, 'from', 'to', 'form'] as const;

const cell = (value: unknown): string => (value === null || value === undefined ? '' : String(value));

/**
 * A declaration covers a period the company files on, so both of its days
 * are asked for: neither is taken to be today.
 */
function declaration(args: ParsedArgs, usage: string): { from: string; to: string; form: string | undefined } {
  if (args.positional.length > 0) throw new UsageError(`too_many_arguments: ${args.positional.join(' ')}. ${usage}`);
  const from = required(stringFlag(args, 'from'), 'the first day of the period', `--from <YYYY-MM-DD>. ${usage}`);
  const to = required(stringFlag(args, 'to'), 'the last day of the period', `--to <YYYY-MM-DD>. ${usage}`);
  return { from, to, form: stringFlag(args, 'form') };
}

/**
 * Where the form puts a box on paper — where it is worked out, for a form
 * that prints in that order — then where it is worked out. Integers of the
 * pack, never amounts.
 */
const position = (box: Row, key: 'print_sequence' | 'sequence'): number => (box[key] as number | null | undefined) ?? 0;
const onPaper = (box: Row): number => (box['print_sequence'] as number | null | undefined) ?? position(box, 'sequence');
const printOrder = (a: Row, b: Row): number =>
  onPaper(a) - onPaper(b) || position(a, 'sequence') - position(b, 'sequence');

const VAT_USAGE = 'usage: ekwo vat --from <YYYY-MM-DD> --to <YYYY-MM-DD> [--form <report code>]';

export async function vatCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  rejectUnknownFlags(args, DECLARATION_FLAGS);
  const { from, to, form } = declaration(args, VAT_USAGE);
  const { backend, company } = await openBooks(args, deps);

  const result = (await vatReturn(backend, {
    company_id: company.id,
    from,
    to,
    ...(form === undefined ? {} : { report_code: form }),
  })) as { report_code: string | null; boxes: Row[] };
  setResult(result);

  heading(`VAT return of ${company.name}${result.report_code === null ? '' : `, ${result.report_code}`}, ${from} to ${to}`);
  const printed = result.boxes.filter((box) => box['hidden'] !== true).sort(printOrder);
  if (printed.length === 0) note(dim('The form has no box to print for this period.'));
  else {
    table(
      [{ title: 'box' }, { title: 'name' }, { title: 'kind' }, { title: 'amount', align: 'right' }, { title: '' }],
      printed.map((box) => [
        cell(box['box']), cell(box['name']), cell(box['kind']), cell(box['amount']),
        box['computed'] === true ? dim('computed') : '',
      ]),
    );
  }
  note(dim('In the order the form is printed. Summed from posted entries; a computed box is derived from the others by the form of the country pack.'));
  note(dim('It prepares figures; it files nothing.'));
  return 0;
}

const ECSL_USAGE = 'usage: ekwo ecsl --from <YYYY-MM-DD> --to <YYYY-MM-DD> [--form <report code>]';

export async function ecslCommand(args: ParsedArgs, deps: BooksDeps = {}): Promise<number> {
  rejectUnknownFlags(args, DECLARATION_FLAGS);
  const { from, to, form } = declaration(args, ECSL_USAGE);
  const { backend, company } = await openBooks(args, deps);

  const result = (await ecSalesList(backend, {
    company_id: company.id,
    from,
    to,
    ...(form === undefined ? {} : { report_code: form }),
  })) as { lines: Row[]; undeclarable_lines: number };
  setResult(result);

  heading(`Recapitulative statement of ${company.name}${form === undefined ? '' : `, ${form}`}, ${from} to ${to}`);
  if (result.lines.length === 0) note(dim('No supply to a customer in another Member State in the period.'));
  else {
    table(
      [
        { title: 'country' }, { title: 'VAT number' }, { title: 'nature' },
        { title: 'amount', align: 'right' }, { title: 'currency' }, { title: 'documents', align: 'right' },
        { title: 'customer' }, { title: 'issue' },
      ],
      result.lines.map((l) => [
        cell(l['vat_country']), cell(l['vat_number']), cell(l['nature']),
        cell(l['amount']), cell(l['currency_code']), cell(l['documents']),
        Array.isArray(l['contact_names']) ? l['contact_names'].join(', ') : '', cell(l['issue']),
      ]),
    );
  }
  if (result.undeclarable_lines > 0) {
    warn(
      `${result.undeclarable_lines} line${result.undeclarable_lines === 1 ? '' : 's'} cannot be filed as ${result.undeclarable_lines === 1 ? 'it stands' : 'they stand'}: see issue — no_vat_number is a customer with no VAT number recorded.`,
    );
  }
  if (form === undefined) note(dim('No --form was given: the period was not checked against the cadence the company files the statement on.'));
  note(dim('Posted sales, credit notes deducted, in the currency of the company. It prepares a statement; it files nothing.'));
  return 0;
}
