/**
 * A company, read before anything is booked in it.
 *
 * What the MCP tool `get_company` and `ekwo company show` answer, word for
 * word: the company row, its financial years and whether each is closed, its
 * lock dates, its journals, the accounts that play the receivable, payable,
 * suspense and retained-earnings roles, its country packs, its members, and
 * what the person asking may do on it.
 */

import { type Backend, type Row } from './backend.js';
import * as columns from './columns.js';
import { onlyVisible as only } from './shared.js';

export async function getCompany(backend: Backend, args: { company_id: string }): Promise<unknown> {
  const company = only(
    await backend.select<Row>({
      table: 'companies',
      columns: columns.COMPANY,
      where: [{ column: 'id', op: 'eq', value: args.company_id }],
    }),
    `company ${args.company_id}`,
  );

  const [years, journals, accounts] = await Promise.all([
    backend.select<Row>({
      table: 'fiscal_years',
      columns: columns.FISCAL_YEAR,
      where: [{ column: 'company_id', op: 'eq', value: args.company_id }],
      order: [{ column: 'start_date' }],
    }),
    backend.select<Row>({
      table: 'journals',
      columns: columns.JOURNAL,
      where: [{ column: 'company_id', op: 'eq', value: args.company_id }],
      order: [{ column: 'code' }],
    }),
    backend.select<{ id: string; code: string; name: string }>({
      table: 'accounts',
      columns: ['id', 'code', 'name'],
      where: [
        {
          column: 'id',
          op: 'in',
          value: [
            company['receivable_account_id'],
            company['payable_account_id'],
            company['suspense_account_id'],
            company['retained_earnings_account_id'],
          ].filter((id): id is string => typeof id === 'string'),
        },
      ],
    }),
  ]);

  const byId = new Map(accounts.map((account) => [account.id, account]));
  const named = (key: string): unknown => {
    const id = company[key];
    return typeof id === 'string' ? (byId.get(id) ?? { id }) : null;
  };

  const packs = await backend.select<Row>({
    table: 'company_packs',
    columns: ['country', 'version', 'chart_code', 'installed_at'],
    where: [{ column: 'company_id', op: 'eq', value: args.company_id }],
    order: [{ column: 'country' }],
  });

  // Who is on the books, and what the person asking may actually do. A role
  // is a preset here and nothing more: the capabilities are the answer, and
  // a tool that reported the role alone would be reporting the label rather
  // than the permission.
  const members = await backend.select<Row>({
    table: 'company_members',
    columns: ['user_id', 'role', 'capabilities_granted', 'capabilities_revoked', 'created_at::text'],
    where: [{ column: 'company_id', op: 'eq', value: args.company_id }],
  });
  // A function returning `setof text` comes back as a list of strings over
  // PostgREST and as a list of one-column rows over Postgres. Both are read
  // here, so the answer is the same list on either route.
  const mine = await backend.rpc<unknown>('member_capabilities', {
    p_company_id: args.company_id,
  });
  const capabilities = mine
    .map((row) =>
      typeof row === 'string'
        ? row
        : ((row as Record<string, unknown>)['member_capabilities'] as string | undefined),
    )
    .filter((code): code is string => typeof code === 'string');

  return {
    company,
    country_packs: packs,
    members,
    your_capabilities: capabilities,
    locks: {
      lock_date: company['lock_date'],
      tax_lock_date: company['tax_lock_date'],
      note: 'Nothing may be booked on or before lock_date; tax_lock_date additionally freezes anything carrying a VAT box.',
    },
    default_accounts: {
      receivable: named('receivable_account_id'),
      payable: named('payable_account_id'),
      suspense: named('suspense_account_id'),
      retained_earnings: named('retained_earnings_account_id'),
    },
    fiscal_years: years,
    journals,
  };
}
