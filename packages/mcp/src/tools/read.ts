/**
 * The reading half.
 *
 * Every one of these is a query the signed-in user could have run themselves;
 * nothing here widens what they may see. The reports come from the schema's
 * own functions — `trial_balance`, `general_ledger`, `aged_balance`,
 * `vat_return`, `fec_lines` — rather than from sums computed here, because a
 * second implementation of a balance is a second answer to the same question.
 */

import {
  checkFec,
  fecFileName,
  fromQueryRow,
  generateFec as renderFec,
  type FecQueryRow,
} from '@ekwo-ai/fec';
import { z } from 'zod';
import { EkwoMcpError, type Backend, type Filter, type Row } from '../backend.js';
import { DOC_TYPES, columns, money, moneyFields, namesOf, onlyVisible as only } from '@ekwo-ai/core';

// Moved to the core with the writing half they are read back by; exported
// from here under the names they always had.
export { getDocument, listDocuments, searchContacts } from '@ekwo-ai/core';

export const uuid = z.string().uuid();
export const isoDate = z
  .string()
  .regex(/^\d{4}-\d{2}-\d{2}$/, 'a calendar date, as YYYY-MM-DD');

export const companyId = uuid.describe('The company to work in. Ask list_companies if unsure.');

// ---------------------------------------------------------------------------
// Companies and their settings
// ---------------------------------------------------------------------------

export const ListCompaniesInput = z.object({});

export async function listCompanies(backend: Backend): Promise<unknown> {
  const companies = await backend.select<Row>({
    table: 'companies',
    columns: ['id', 'name', 'country', 'fiscal_country', 'vat_number', 'currency_code'],
    order: [{ column: 'name' }],
  });
  // Your role, and only yours. `company_members` shows every member of a
  // company one is on, so an unfiltered read would give whichever member's
  // role came last. A key of Ekwo OS is nobody's member: it has no role, and
  // says so with null rather than borrowing one.
  const roles =
    backend.actingAs === undefined
      ? []
      : await backend.select<{ company_id: string; role: string }>({
          table: 'company_members',
          columns: ['company_id', 'role'],
          where: [{ column: 'user_id', op: 'eq', value: backend.actingAs }],
        });
  const mine = new Map(roles.map((row) => [row.company_id, row.role]));
  return {
    companies: companies.map((company) => ({
      ...company,
      your_role: mine.get(company['id'] as string) ?? null,
    })),
  };
}

export const GetCompanyInput = z.object({ company_id: companyId });

export async function getCompany(
  backend: Backend,
  args: z.infer<typeof GetCompanyInput>,
): Promise<unknown> {
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

// ---------------------------------------------------------------------------
// Reference data
// ---------------------------------------------------------------------------

export const ListAccountsInput = z.object({
  company_id: companyId,
  code_prefix: z.string().min(1).optional().describe('Only accounts whose code starts with this, e.g. "70".'),
  account_type: z.string().min(1).optional().describe('One of the eighteen account types, e.g. asset_receivable.'),
  search: z.string().min(1).optional().describe('Case-insensitive match on the account name.'),
  in_use_from: isoDate
    .optional()
    .describe('Narrows the movements to entries on or after this date. References and pinned accounts are not dated and stay in.'),
  in_use_to: isoDate.optional().describe('The other end of that period.'),
  include_all: z
    .boolean()
    .optional()
    .describe('Return the whole chart instead of the accounts in use. Use it when a search over the working chart found nothing.'),
  include_deprecated: z
    .boolean()
    .optional()
    .describe('Include deprecated accounts. A deprecated account is never in use, so this returns the whole chart.'),
  limit: z.number().int().min(1).max(2000).optional(),
});

/**
 * The account ids `accounts_in_use()` gives back.
 *
 * A function returning `setof uuid` arrives as a list of strings over
 * PostgREST and as a list of one-column rows over Postgres, the same split
 * `member_capabilities` has. Both are read here.
 */
async function accountsInUse(
  backend: Backend,
  args: { company_id: string; in_use_from?: string | undefined; in_use_to?: string | undefined },
): Promise<string[]> {
  const rows = await backend.rpc<unknown>('accounts_in_use', {
    p_company_id: args.company_id,
    p_from: args.in_use_from ?? null,
    p_to: args.in_use_to ?? null,
  });
  return rows
    .map((row) =>
      typeof row === 'string'
        ? row
        : ((row as Record<string, unknown>)['accounts_in_use'] as string | undefined),
    )
    .filter((id): id is string => typeof id === 'string');
}

export async function listAccounts(
  backend: Backend,
  args: z.infer<typeof ListAccountsInput>,
): Promise<unknown> {
  const where: Filter[] = [{ column: 'company_id', op: 'eq', value: args.company_id }];
  if (args.code_prefix !== undefined) where.push({ column: 'code', op: 'ilike', value: `${args.code_prefix}%` });
  if (args.account_type !== undefined) where.push({ column: 'account_type', op: 'eq', value: args.account_type });
  if (args.search !== undefined) where.push({ column: 'name', op: 'ilike', value: `%${args.search}%` });
  if (args.include_deprecated !== true) where.push({ column: 'deprecated', op: 'eq', value: false });

  // A country pack is a transcription of the regulation — three hundred
  // accounts in Belgium, a thousand in Luxembourg — and a company works with a
  // few dozen of them. The default is therefore the working chart the schema
  // computes, and the whole thing is one flag away. Asking for deprecated
  // accounts is asking for the whole chart by definition: a deprecated account
  // is never in use.
  const wholeChart = args.include_all === true || args.include_deprecated === true;
  let scope: 'in_use' | 'whole_chart' = 'whole_chart';
  if (!wholeChart) {
    scope = 'in_use';
    const ids = await accountsInUse(backend, args);
    if (ids.length === 0) {
      return {
        accounts: [],
        count: 0,
        scope,
        note: 'No account of this company is in use yet. Pass include_all to see the whole chart.',
      };
    }
    where.push({ column: 'id', op: 'in', value: ids });
  }

  const accounts = await backend.select<Row>({
    table: 'accounts',
    columns: columns.ACCOUNT,
    where,
    order: [{ column: 'code' }],
    limit: args.limit ?? 200,
  });
  return {
    accounts,
    count: accounts.length,
    scope,
    note:
      scope === 'in_use'
        ? 'The accounts this company works with: moved, referenced by its settings, held by a module, or pinned. Pass include_all for the whole chart — any account of it may still be booked on.'
        : 'The whole chart of the company.',
  };
}

export const SearchContactsInput = z.object({
  company_id: companyId,
  query: z.string().min(1).optional().describe('Case-insensitive match on the contact name.'),
  contact_type: z.enum(['customer', 'supplier', 'both', 'employee', 'other']).optional(),
  vat_number: z.string().min(1).optional().describe('Exact match, e.g. BE0123456749.'),
  limit: z.number().int().min(1).max(200).optional(),
});

// ---------------------------------------------------------------------------
// Documents
// ---------------------------------------------------------------------------

export const ListDocumentsInput = z.object({
  company_id: companyId,
  doc_type: z.enum(DOC_TYPES).optional(),
  state: z.enum(['draft', 'posted', 'cancelled']).optional(),
  payment_state: z.enum(['not_paid', 'partially_paid', 'paid', 'overpaid', 'reversed']).optional(),
  contact_id: uuid.optional(),
  from: isoDate.optional().describe('Earliest document date.'),
  to: isoDate.optional().describe('Latest document date.'),
  unpaid: z.boolean().optional().describe('True: posted and still owed — not paid, or partially.'),
  limit: z.number().int().min(1).max(200).optional(),
});

export const GetDocumentInput = z.object({ document_id: uuid });

// ---------------------------------------------------------------------------
// Bank
// ---------------------------------------------------------------------------

export const ListBankTransactionsInput = z.object({
  company_id: companyId,
  bank_account_id: uuid.optional(),
  state: z.enum(['pending', 'reconciled', 'ignored', 'all']).optional().describe('Defaults to pending: what still has to be dealt with.'),
  from: isoDate.optional(),
  to: isoDate.optional(),
  limit: z.number().int().min(1).max(200).optional(),
});

export async function listBankTransactions(
  backend: Backend,
  args: z.infer<typeof ListBankTransactionsInput>,
): Promise<unknown> {
  const where: Filter[] = [{ column: 'company_id', op: 'eq', value: args.company_id }];
  const state = args.state ?? 'pending';
  if (state !== 'all') where.push({ column: 'state', op: 'eq', value: state });
  if (args.bank_account_id !== undefined) where.push({ column: 'bank_account_id', op: 'eq', value: args.bank_account_id });
  if (args.from !== undefined) where.push({ column: 'transaction_date', op: 'gte', value: args.from });
  if (args.to !== undefined) where.push({ column: 'transaction_date', op: 'lte', value: args.to });

  const [transactions, bankAccounts] = await Promise.all([
    backend.select<Row>({
      table: 'bank_transactions',
      columns: columns.BANK_TRANSACTION,
      where,
      order: [{ column: 'transaction_date', ascending: false }],
      limit: args.limit ?? 50,
    }),
    backend.select<Row>({
      table: 'bank_accounts',
      columns: columns.BANK_ACCOUNT,
      where: [{ column: 'company_id', op: 'eq', value: args.company_id }],
      order: [{ column: 'name' }],
    }),
  ]);

  return { transactions, count: transactions.length, bank_accounts: bankAccounts };
}

// ---------------------------------------------------------------------------
// Reports
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Products
// ---------------------------------------------------------------------------

export const SearchProductsInput = z.object({
  company_id: companyId,
  query: z.string().min(1).optional().describe('Matches the code, the name or the description.'),
  kind: z.enum(['service', 'goods']).optional(),
  include_inactive: z.boolean().optional().describe('Default false: a retired product is hidden.'),
  limit: z.number().int().min(1).max(200).optional(),
});

export async function searchProducts(
  backend: Backend,
  args: z.infer<typeof SearchProductsInput>,
): Promise<unknown> {
  const where: Filter[] = [{ column: 'company_id', op: 'eq', value: args.company_id }];
  if (args.kind !== undefined) where.push({ column: 'kind', op: 'eq', value: args.kind });
  if (args.include_inactive !== true) where.push({ column: 'active', op: 'eq', value: true });

  const products = await backend.select<Row>({
    table: 'products',
    columns: columns.PRODUCT,
    where,
    order: [{ column: 'code' }],
    limit: args.limit ?? 100,
  });

  // The filter on the text is applied here rather than in three `ilike`
  // clauses, because neither backend offers an OR and a second round trip per
  // column would be the alternative.
  const needle = args.query?.toLowerCase();
  const matching =
    needle === undefined
      ? products
      : products.filter((product) =>
          [product['code'], product['name'], product['description']]
            .filter((value): value is string => typeof value === 'string')
            .some((value) => value.toLowerCase().includes(needle)),
        );

  return { products: matching };
}

export const ListBankAccountsInput = z.object({
  company_id: companyId,
  include_inactive: z.boolean().optional().describe('Default false.'),
});

export async function listBankAccounts(
  backend: Backend,
  args: z.infer<typeof ListBankAccountsInput>,
): Promise<unknown> {
  const accounts = await backend.select<Row>({
    table: 'bank_accounts',
    columns: columns.BANK_ACCOUNT,
    where: [
      { column: 'company_id', op: 'eq', value: args.company_id },
      ...(args.include_inactive === true
        ? []
        : ([{ column: 'active', op: 'eq', value: true }] satisfies Filter[])),
    ],
    order: [{ column: 'name' }],
  });
  return {
    bank_accounts: accounts,
    note:
      accounts.length === 0
        ? 'This company has no bank account. create_bank_account adds one; until then a payment books on the default account of its journal.'
        : undefined,
  };
}

// ---------------------------------------------------------------------------
// Members and invitations
// ---------------------------------------------------------------------------

export const ListApiKeysInput = z.object({
  company_id: companyId,
  include_withdrawn: z.boolean().optional().describe('Also the ones withdrawn or expired. Default false.'),
});

export async function listApiKeys(
  backend: Backend,
  args: z.infer<typeof ListApiKeysInput>,
): Promise<unknown> {
  const keys = await backend.select<Row>({
    table: 'api_keys',
    columns: columns.API_KEY,
    where: [{ column: 'company_id', op: 'eq', value: args.company_id }],
    order: [{ column: 'created_at', ascending: false }],
  });

  const now = Date.now();
  const described = keys.map((key) => ({ ...key, state: apiKeyState(key, now) }));
  return {
    api_keys:
      args.include_withdrawn === true
        ? described
        : described.filter((key) => key.state === 'live'),
    note: 'The secret of a key exists only in the answer that created it. A key that is lost is withdrawn and issued again.',
  };
}

function apiKeyState(key: Row, now: number): string {
  if (key['revoked_at'] !== null && key['revoked_at'] !== undefined) return 'withdrawn';
  const expires = key['expires_at'];
  if (typeof expires === 'string' && Date.parse(expires) <= now) return 'expired';
  return 'live';
}

export const GetPreferencesInput = z.object({
  company_id: uuid
    .optional()
    .describe('Resolve the language chain against this company. Left out, only what the user themselves chose is returned.'),
});

export async function getPreferences(
  backend: Backend,
  args: z.infer<typeof GetPreferencesInput>,
): Promise<unknown> {
  const [stored] = await backend.select<Row>({
    table: 'user_preferences',
    columns: columns.USER_PREFERENCES,
    limit: 1,
  });

  const chain = await backend.rpc<unknown>('preferred_languages', {
    p_company_id: args.company_id ?? null,
  });
  const languages = (chain[0] ?? []) as string[] | Record<string, unknown>;

  return {
    preferences: stored ?? null,
    languages: Array.isArray(languages) ? languages : (languages['preferred_languages'] ?? []),
    note: 'Every preference may be null, and null is an answer: take the company\u2019s, then the country pack\u2019s. A label is picked with label_for(name, name_i18n, languages), in that order.',
  };
}

export const ListInvitationsInput = z.object({
  company_id: companyId,
  include_settled: z
    .boolean()
    .optional()
    .describe('Also the ones already accepted or withdrawn. Default false.'),
});

export async function listInvitations(
  backend: Backend,
  args: z.infer<typeof ListInvitationsInput>,
): Promise<unknown> {
  const invitations = await backend.select<Row>({
    table: 'company_invitations',
    columns: columns.INVITATION,
    where: [{ column: 'company_id', op: 'eq', value: args.company_id }],
    order: [{ column: 'created_at', ascending: false }],
  });

  const now = Date.now();
  const described = invitations.map((invitation) => ({
    ...invitation,
    state: invitationState(invitation, now),
  }));

  return {
    invitations:
      args.include_settled === true
        ? described
        : described.filter((invitation) => invitation.state === 'pending'),
    note: 'The token is shown once, when the invitation is issued, and is never readable afterwards. A lost one is replaced by inviting the same address again.',
  };
}

export const ListSharesInput = z.object({
  company_id: companyId,
  document_id: uuid.optional().describe('Only the links onto this document. Left out, the whole company.'),
  include_withdrawn: z
    .boolean()
    .optional()
    .describe('Also the ones withdrawn or expired. Default false.'),
});

export async function listShares(
  backend: Backend,
  args: z.infer<typeof ListSharesInput>,
): Promise<unknown> {
  const where: Filter[] = [{ column: 'company_id', op: 'eq', value: args.company_id }];
  if (args.document_id !== undefined) {
    where.push({ column: 'document_id', op: 'eq', value: args.document_id });
  }

  const shares = await backend.select<Row>({
    table: 'document_shares',
    columns: columns.DOCUMENT_SHARE,
    where,
    order: [{ column: 'created_at', ascending: false }],
  });

  const now = Date.now();
  const described = shares.map((share) => ({ ...share, state: shareState(share, now) }));
  return {
    shares:
      args.include_withdrawn === true
        ? described
        : described.filter((share) => share.state === 'live'),
    note: 'The token of a link exists only in the answer that created it. A link that is lost is withdrawn and made again.',
  };
}

/** Live, expired or withdrawn — three states off two columns. */
function shareState(share: Row, now: number): string {
  if (share['revoked_at'] !== null && share['revoked_at'] !== undefined) return 'withdrawn';
  const expires = share['expires_at'];
  if (typeof expires === 'string' && Date.parse(expires) <= now) return 'expired';
  return 'live';
}

/** Pending, expired, accepted or withdrawn — four states off three columns. */
function invitationState(invitation: Row, now: number): string {
  if (invitation['accepted_at'] !== null && invitation['accepted_at'] !== undefined) return 'accepted';
  if (invitation['revoked_at'] !== null && invitation['revoked_at'] !== undefined) return 'withdrawn';
  const expires = Date.parse(String(invitation['expires_at']));
  return Number.isNaN(expires) || expires > now ? 'pending' : 'expired';
}

export const TrialBalanceInput = z.object({
  company_id: companyId,
  from: isoDate,
  to: isoDate,
});

export async function trialBalance(
  backend: Backend,
  args: z.infer<typeof TrialBalanceInput>,
): Promise<unknown> {
  const rows = await backend.rpc<Record<string, unknown>>('trial_balance', {
    p_company_id: args.company_id,
    p_from: args.from,
    p_to: args.to,
  });
  const accounts = moneyFields(rows, ['opening_balance', 'debit', 'credit', 'closing_balance']);
  const total = (key: string): string =>
    accounts.reduce((sum, row) => sum + Number(row[key] ?? 0), 0).toFixed(2);

  return {
    period: { from: args.from, to: args.to },
    accounts,
    totals: { debit: total('debit'), credit: total('credit') },
  };
}

export const GeneralLedgerInput = z.object({
  company_id: companyId,
  from: isoDate,
  to: isoDate,
  account_code: z.string().min(1).optional().describe('The account to detail, by its code, e.g. "400000".'),
  account_ids: z.array(uuid).optional().describe('The accounts to detail, by id. Leave both out for every account.'),
});

export async function generalLedger(
  backend: Backend,
  args: z.infer<typeof GeneralLedgerInput>,
): Promise<unknown> {
  let ids = args.account_ids ?? null;
  if (args.account_code !== undefined) {
    const accounts = await backend.select<{ id: string }>({
      table: 'accounts',
      columns: ['id'],
      where: [
        { column: 'company_id', op: 'eq', value: args.company_id },
        { column: 'code', op: 'eq', value: args.account_code },
      ],
    });
    ids = [...(ids ?? []), ...accounts.map((account) => account.id)];
    if (ids.length === 0) {
      throw new EkwoMcpError(`not_found: no account ${args.account_code} in this company.`);
    }
  }

  const rows = await backend.rpc<Record<string, unknown>>('general_ledger', {
    p_company_id: args.company_id,
    p_from: args.from,
    p_to: args.to,
    p_account_ids: ids,
  });

  return {
    period: { from: args.from, to: args.to },
    lines: moneyFields(rows, ['debit', 'credit', 'running_balance']),
    count: rows.length,
  };
}

export const AgedBalanceInput = z.object({
  company_id: companyId,
  at: isoDate.optional().describe('The day to age at. Defaults to today.'),
  group: z.enum(['receivable', 'payable']).optional(),
});

export async function agedBalance(
  backend: Backend,
  args: z.infer<typeof AgedBalanceInput>,
): Promise<unknown> {
  const rows = await backend.rpc<Record<string, unknown>>('aged_balance', {
    p_company_id: args.company_id,
    p_at: args.at ?? new Date().toISOString().slice(0, 10),
    p_group: args.group ?? 'receivable',
  });
  return {
    at: args.at ?? new Date().toISOString().slice(0, 10),
    group: args.group ?? 'receivable',
    rows: moneyFields(rows, ['not_due', 'days_1_30', 'days_31_60', 'days_61_90', 'days_over_90', 'total']),
  };
}

export const VatReturnInput = z.object({
  company_id: companyId,
  from: isoDate,
  to: isoDate,
  report_code: z
    .string()
    .optional()
    .describe(
      'Which declaration form, when the country files more than one (BE-VAT-PERIODIC, FR-CA3). Leave it out and the periodic return of the company country is used.',
    ),
});

export async function vatReturn(
  backend: Backend,
  args: z.infer<typeof VatReturnInput>,
): Promise<unknown> {
  const rows = await backend.rpc<Record<string, unknown>>('vat_return', {
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

export const EcSalesListInput = z.object({
  company_id: companyId,
  from: isoDate,
  to: isoDate,
  report_code: z
    .string()
    .optional()
    .describe(
      'Which recapitulative statement form, when the installation carries one and you are filing it. Name it and the period is checked against the cadence this company files that statement on, which is not the cadence of its periodic return in most countries. Leave it out to read the figures without any period being refused.',
    ),
});

export async function ecSalesList(
  backend: Backend,
  args: z.infer<typeof EcSalesListInput>,
): Promise<unknown> {
  const rows = await backend.rpc<Record<string, unknown>>('ec_sales_list', {
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

export const PortfolioUpcomingFilingsInput = z.object({
  from: isoDate.describe('First day a return may fall due on. Go back a few days to catch what is already late.'),
  to: isoDate.describe('Last day a return may fall due on.'),
});

export async function portfolioUpcomingFilings(
  backend: Backend,
  args: z.infer<typeof PortfolioUpcomingFilingsInput>,
): Promise<unknown> {
  const rows = await backend.rpc<Record<string, unknown>>('portfolio_upcoming_filings', {
    p_from: args.from,
    p_to: args.to,
  });
  const companies = new Set(rows.map((row) => row['company_id']));
  return {
    window: { from: args.from, to: args.to },
    companies: companies.size,
    filings: rows,
    note:
      rows.length === 0
        ? 'You hold filings.read on no company of this installation, so there is no portfolio to read. It is not the same as nothing being due: a company you could read would be listed even with nothing to say.'
        : 'One row per period falling due in the window, across every company you hold filings.read on, and at least one row per company. state and filing_id are the declaration already prepared or sent for that period; both empty means nothing has been started. A row without a due_date says why in reason: no_deadline_rule — the country pack names no day for this form, usually because the schedule depends on who is filing, so the period is listed and the date has to come from the administration; nothing_due — the company files, and nothing of it falls in this window; no_form — the installation carries no return for the fiscal country of the company. Never read a missing date as "not due". It reads a calendar; it prepares and files nothing.',
  };
}

export const PortfolioFilingsTouchedSinceInput = z.object({
  from: isoDate.optional().describe('Only declarations whose period ends on or after this day.'),
  to: isoDate.optional().describe('Only declarations whose period starts on or before this day.'),
});

export async function portfolioFilingsTouchedSince(
  backend: Backend,
  args: z.infer<typeof PortfolioFilingsTouchedSinceInput>,
): Promise<unknown> {
  const rows = await backend.rpc<Record<string, unknown>>('portfolio_filings_touched_since', {
    p_from: args.from ?? null,
    p_to: args.to ?? null,
  });
  const touched = rows.filter((row) => row['filing_id'] !== null);
  return {
    companies: new Set(rows.map((row) => row['company_id'])).size,
    touched: touched.length,
    filings: touched,
    untouched: rows
      .filter((row) => row['filing_id'] === null)
      .map((row) => ({
        company_id: row['company_id'],
        company_name: row['company_name'],
        filed: row['filed'],
      })),
    note:
      rows.length === 0
        ? 'You hold filings.read on no company of this installation, so nothing was looked at.'
        : 'filings lists every declaration that has gone and whose period received entries afterwards, latest first, with the company named: entries is how many posted entries carrying a declaration box landed in it, boxes_moved how many filed figures now disagree with the ledger. An entry that moves no figure is still listed. untouched names the companies that were looked at and had nothing to report, with how many filed declarations were examined — filed 0 means the company has sent none, which is different news. Whether a change calls for a corrective is a judgement for whoever keeps the books; this reads, and changes nothing.',
  };
}

export const ListStatementsInput = z.object({
  company_id: companyId,
  at: isoDate
    .optional()
    .describe('The day to read the schemes in force at. Defaults to today.'),
});

export async function listStatements(
  backend: Backend,
  args: z.infer<typeof ListStatementsInput>,
): Promise<unknown> {
  const rows = await backend.rpc<Record<string, unknown>>('available_statements', {
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

export const FinancialStatementInput = z.object({
  company_id: companyId,
  statement_code: z
    .string()
    .min(1)
    .describe('Which scheme, from list_statements (BE-BNB-ABBR-BS, FR-2050, IFRS-SME-BS).'),
  from: isoDate,
  to: isoDate,
});

export async function financialStatement(
  backend: Backend,
  args: z.infer<typeof FinancialStatementInput>,
): Promise<unknown> {
  const [lines, unmapped] = await Promise.all([
    backend.rpc<Record<string, unknown>>('financial_statement', {
      p_company_id: args.company_id,
      p_statement_code: args.statement_code,
      p_from: args.from,
      p_to: args.to,
    }),
    backend.rpc<Record<string, unknown>>('unmapped_accounts', {
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

export const GenerateFecInput = z.object({
  company_id: companyId,
  from: isoDate,
  to: isoDate,
});

export async function generateFec(
  backend: Backend,
  args: z.infer<typeof GenerateFecInput>,
): Promise<unknown> {
  const rows = await backend.rpc<FecQueryRow>('fec_lines', {
    p_company_id: args.company_id,
    p_from: args.from,
    p_to: args.to,
  });
  const lines = rows.map(fromQueryRow);
  const violations = checkFec(lines);
  const file = renderFec(lines);

  const company = only(
    await backend.select<Row>({
      table: 'companies',
      columns: ['id', 'name', 'registration_number', 'fiscal_country'],
      where: [{ column: 'id', op: 'eq', value: args.company_id }],
    }),
    `company ${args.company_id}`,
  );

  const siren = String(company['registration_number'] ?? '').replace(/\D/g, '');
  let filename: string | null = null;
  let filename_note: string | null = null;
  if (siren.length === 9) {
    filename = fecFileName(siren, args.to);
  } else {
    filename_note =
      'No filename: the FEC name is built from a nine-digit SIREN, and this company has no such registration number.';
  }

  return {
    period: { from: args.from, to: args.to },
    lines: lines.length,
    violations,
    filename,
    filename_note,
    file,
  };
}

// ---------------------------------------------------------------------------
// describe_pack
// ---------------------------------------------------------------------------

export const DescribePackInput = z.object({
  country: z
    .string()
    .length(2)
    .optional()
    .describe('ISO 3166-1 alpha-2, upper case. Left out, every pack this installation holds.'),
});

/**
 * Where a country's rules come from, and how much anyone has read them.
 *
 * The pack is the transcription of a régime — a chart of accounts, the taxes
 * and the boxes of the return — and a transcription is only worth what its
 * sources are worth. `certification_status` says whether a named professional
 * has read it, and `sources` is the register the pack declares: the texts it
 * was built from, each with the publisher that serves it, an absolute link and
 * the day somebody opened it.
 *
 * It answers a question that used to have no answer here: shown a rate or a
 * grid, where is the text it comes from. The article itself is on the tax and
 * on the box — `legal_reference` — and `source_key` there names which of these
 * entries it is in.
 */
export async function describePack(
  backend: Backend,
  args: z.infer<typeof DescribePackInput>,
): Promise<unknown> {
  const where: Filter[] =
    args.country === undefined ? [] : [{ column: 'country', op: 'eq', value: args.country.toUpperCase() }];
  const packs = await backend.select<Row>({
    table: 'country_packs',
    columns: columns.COUNTRY_PACK,
    where,
    order: [{ column: 'country' }],
  });

  if (packs.length === 0) {
    return {
      packs: [],
      count: 0,
      note:
        args.country === undefined
          ? 'This installation holds no country pack. Its seeds have not been applied.'
          : `No pack is loaded for ${args.country.toUpperCase()}. A company of that country cannot be installed until its seed has run.`,
    };
  }

  return {
    packs,
    count: packs.length,
    note:
      'certification_status is what somebody claims, not a certificate: community means nobody has read it, maintained means the maintainers keep it current and nobody has reviewed it, reviewed means the named professional in certified_by read it on certified_at. `sources` is the register the pack declares — each entry is a text, its official publisher, an absolute link and the day it was opened — and it holds no copy of the law itself. A tax and a box of the declaration each carry their own article in legal_reference and name the register entry it is in; a link that no longer answers is the register being stale, never the rule being wrong.',
  };
}

// ---------------------------------------------------------------------------
// status
// ---------------------------------------------------------------------------

export const StatusInput = z.object({});

export async function status(backend: Backend): Promise<unknown> {
  const version = await backend.rpc<string>('ekwo_schema_version');
  const instance = await backend.select<Row>({ table: 'instance', columns: columns.INSTANCE });
  const companies = await backend.select<Row>({
    table: 'companies',
    columns: ['id', 'name', 'country', 'currency_code'],
    order: [{ column: 'name' }],
  });

  return {
    schema_version: version[0] ?? null,
    connection: { mode: backend.mode, acting_as: backend.actingAs ?? null },
    instance: instance[0] ?? null,
    companies,
    note:
      backend.mode === 'postgrest'
        ? 'Reading and writing as the signed-in user, over PostgREST. Row level security decides what is visible.'
        : 'Reading and writing over a direct Postgres connection, with the claims and the role of the user this server acts for.',
  };
}

/** Re-exported so the write tools can format the same way. */
export { money };

// ---------------------------------------------------------------------------
// The audit trail
// ---------------------------------------------------------------------------

export const ReadAuditLogInput = z.object({
  company_id: companyId,
  table: z
    .string()
    .optional()
    .describe(
      'One table of the schema: accounts, journals, taxes, tax_postings, contacts, products, bank_accounts, companies, fiscal_years, company_members, company_packs, api_keys, documents, payments, entries, reconciliations.',
    ),
  record_key: z
    .string()
    .optional()
    .describe('The natural key of one row — an account code, a tax code, an invoice number.'),
  actor_id: uuid.optional().describe('Only what this user changed. Their auth.users id.'),
  action: z
    .string()
    .optional()
    .describe(
      'One act: document_posted, document_cancelled, entry_posted, entry_reversed, payment_posted, payment_reconciled, payment_unreconciled, fiscal_year_closed, fiscal_year_reopened, pack_upgraded.',
    ),
  operation: z.enum(['insert', 'update', 'delete']).optional(),
  from: isoDate.optional().describe('Earliest date, inclusive.'),
  to: isoDate.optional().describe('Latest date, inclusive — the whole of that day.'),
  limit: z.number().int().min(1).max(200).optional(),
});

export async function readAuditLog(
  backend: Backend,
  args: z.infer<typeof ReadAuditLogInput>,
): Promise<unknown> {
  const where: Filter[] = [{ column: 'company_id', op: 'eq', value: args.company_id }];
  if (args.table !== undefined) where.push({ column: 'table_name', op: 'eq', value: args.table });
  if (args.record_key !== undefined) where.push({ column: 'record_key', op: 'eq', value: args.record_key });
  if (args.actor_id !== undefined) where.push({ column: 'actor_id', op: 'eq', value: args.actor_id });
  if (args.action !== undefined) where.push({ column: 'action', op: 'eq', value: args.action });
  if (args.operation !== undefined) where.push({ column: 'operation', op: 'eq', value: args.operation });
  if (args.from !== undefined) where.push({ column: 'occurred_at', op: 'gte', value: args.from });
  // A date names a day, not the instant it begins: `to: 2026-06-15` has to
  // include everything that happened that afternoon.
  if (args.to !== undefined) {
    where.push({ column: 'occurred_at', op: 'lt', value: nextDay(args.to) });
  }

  const entries = await backend.select<Row>({
    table: 'audit_log',
    columns: columns.AUDIT_LOG,
    where,
    order: [{ column: 'occurred_at', ascending: false }, { column: 'id', ascending: false }],
    limit: args.limit ?? 50,
  });

  return {
    changes: entries,
    count: entries.length,
    note: 'Append-only. Nothing writes this trail but the database itself, and nothing removes a row from it.',
  };
}

/** The day after an ISO date, so a range on a timestamp can end on a day. */
function nextDay(date: string): string {
  const day = new Date(`${date}T00:00:00Z`);
  day.setUTCDate(day.getUTCDate() + 1);
  return day.toISOString().slice(0, 10);
}
