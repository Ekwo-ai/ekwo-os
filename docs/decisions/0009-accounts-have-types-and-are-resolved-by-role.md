# Accounts have types and are resolved by role

> Status: accepted

## Context

With five account types (asset, liability, equity, income, expense), the aged
balance, reconcilability and the mapping to statements live in code patterns
on account codes. `411` means *customers* on the French chart and
*recoverable VAT* on the Belgian one, so a pattern that works in one country
books to the wrong account in another.

## Decision

**Eighteen account types.** `asset_receivable`, `liability_payable` and their
siblings make the aged balance, reconcilability and statement mapping
computable from data.

**The balance-sheet group is derived.** `internal_group` and
`carries_forward` are generated columns over `account_type`; neither can drift
from the type.

**A receivable or payable account that is not reconcilable is refused by a
check constraint.** Without matching there is no residual, no aged balance and
no audit-file letter.

**Accounts are resolved by role, never by code prefix.** Order: the
contact's override, then the company default; `tax_postings.account_id` does
the same for tax. `LIKE '411%' ORDER BY code LIMIT 1` is how a customer debit
ends up on a VAT account.

**The account of a document line is resolved in the database; the tax is
not.** Most specific first: the line, the product, the company default
(`default_sales_account_id` / `default_purchase_account_id`), the country
model (`country_defaults.sales_account_code` / `purchase_account_code`). It
runs in a trigger on `document_lines` so every client — MCP server, PostgREST,
psql — gets the same answer; a product line with no account is forbidden, so
a null account can only mean "resolve it". A null *tax* means no tax at all,
which is a real answer, so nothing fills it in.

**A code and a type are frozen by the first use.** Statement rules and
declaration boxes reach accounts by code, so renumbering a used account would
move a booked year to another line of a filed statement. A trigger refuses a
change of code (`account_code_frozen`) or type (`account_type_frozen`) once
the account carries a ledger line, is named by a tax posting or plays a role.
Label, translations, notes, parent, `reconcilable`, `deprecated` and `pinned`
stay editable. An account given the wrong code is deprecated and replaced.

**Mapping by code range is presentation, and presentation is allowed.** The
rule against choosing an account *to post to* by prefix is about posting.
Statement schemes and filing taxonomies map by ranges of the legal chart, and
refusing that would mean hand-listing hundreds of codes per country.

## Consequences

- `pack_upgrade(…, apply => true)` refuses rather than move a used account
  between statements.
- A published column that nothing read (`country_defaults.sales_account_code`,
  `purchase_account_code`, `currency_code`) was given a reader rather than
  deleted: deleting a published column is irreversible.

## See also

- [0028 A pack upgrade is never silent](0028-a-pack-upgrade-is-never-silent.md)
- [0030 Charts and financial statements are data](0030-charts-and-financial-statements-are-data.md)
- `tests/line_defaults.test.ts`
