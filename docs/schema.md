# Schema

The reference half of this document is generated from the migrations, so it
cannot drift from what the database actually holds. Regenerate it with
`node scripts/generate-schema-doc.mjs`.

## Shape

One installation belongs to one customer. That is why there is no `tenant_id`
anywhere: the instance is the tenant, and `instance` records it in a single
row written by the installer.

```
instance                                 one row: who installed it, where, which edition
instance_admins                          instance administrators
companies ─┬─ company_members            who may read or write, in four presets
           ├─ fiscal_years               periods, open or closed
           ├─ accounts                   chart of accounts, eighteen types
           ├─ journals ── journal_sequences
           ├─ contacts                   customers, suppliers, employees
           ├─ taxes ── tax_postings      ledger account and VAT box, per tax
           ├─ entries ── entry_lines     the ledger; the lines carry the truth
           ├─ documents ── document_lines invoices, credit notes, quotes
           ├─ payments                   money in and out
           ├─ reconciliations            bilateral matching, by amount
           ├─ bank_accounts ── bank_statements ── bank_transactions
           ├─ analytic_axes ── analytic_values ── entry_line_analytics
           └─ attachments                files, polymorphic
```

Reference data sits outside any company: `currencies`, `currency_rates`, and
the four template tables plus `country_defaults` that
`install_country_template()` copies into a new company.

## Six rules the schema enforces

1. **Amounts are positive.** `entry_lines` refuses a negative debit or credit
   and refuses a line carrying both. A reversal flips the side.
2. **A posted entry balances.** A check constraint on `entries`, with
   `total_debit` and `total_credit` maintained from the lines by trigger.
3. **Totals are derived.** `document_lines.amount_untaxed` is generated;
   document and entry totals are maintained by trigger; `documents.amount_paid`
   is recomputed from the matching on the third-party lines. Nothing is keyed
   in.
4. **A locked period refuses writes.** Triggers on `entries` and
   `entry_lines` consult `companies.lock_date`, `companies.tax_lock_date` and
   `fiscal_years.is_closed`. Matching stays allowed.
5. **A third-party account is reconcilable.** A check constraint refuses an
   `asset_receivable` or `liability_payable` account that is not.
6. **Every table has row level security.** At instance level, a row in
   `instance_admins` creates companies and invites members. Per company, `company_members` gives `viewer` read, `client`
   read and the right to hand a piece over, `accountant` write, and `owner`
   administration of the company and its members. An
   instance administrator can see the list of companies and invite people
   into them; they cannot read a ledger they were not invited to.
7. **The instance row is a singleton.** A primary key of `1` and a check
   constraint make a second row impossible, not merely unusual.

## Registration is opt-in

`instance.contact_email` and `instance.registered_at` are empty on a fresh
install. Nothing writes them unless the operator calls `register_instance()`,
nothing in this repository reads them, and `unregister_instance()` puts them
back. Community works unregistered, forever. `instance.edition` records
whether Ekwo operates the installation; it gates nothing here.

## Account types

Eighteen values, grouped by the prefix before the first underscore, which is
what `internal_group` derives:

| Group | Types |
|---|---|
| `asset` | `asset_receivable`, `asset_cash`, `asset_current`, `asset_prepayments`, `asset_fixed`, `asset_non_current` |
| `liability` | `liability_payable`, `liability_credit_card`, `liability_current`, `liability_non_current` |
| `equity` | `equity`, `equity_retained` |
| `income` | `income`, `income_other` |
| `expense` | `expense`, `expense_direct_cost`, `expense_depreciation` |
| `off_balance` | `off_balance` |

`carries_forward` is generated too: true for everything except the income and
expense types.

## How a tax lands

A tax says how much. Its postings say where.

For each tax and each document kind (`invoice` or `credit_note`), `tax_postings`
holds at most one `base` posting and any number of `tax` postings. Each one
carries a `factor_percent`, a ledger account (for tax postings) and a
`declaration_box` with its own `box_factor_percent` — and, beside it,
`declaration_boxes`, every box the form prints that one amount in. It is almost
always the single box `declaration_box` names, and it is longer on a form that
shows one figure in boxes that are not sums of one another.

`post_document()` applies them:

- the base amount goes to the account of the document line, and picks up the
  box of the base posting — one line and one box, whatever the form does with
  the figure afterwards: `vat_return()` is what reads the list and sums the
  line into each box of it;
- for each tax posting, `round(tax x |factor| / 100, 2)` goes to that
  posting's account — on the same side as the base when `factor_percent` is
  positive, on the opposite side when it is negative;
- the declaration box receives `round(tax x box_factor / 100, 2)`,
  independently of which side the ledger amount landed on.

A Belgian intra-community purchase of goods at 21 % is therefore four rows:

| kind | type | factor | account | box | box factor |
|---|---|---|---|---|---|
| invoice | base | 100 | — | 86 | 100 |
| invoice | tax | 100 | 411000 recoverable | 59 | 100 |
| invoice | tax | −100 | 451000 payable | 55 | 100 |

which books `604 debit 1000 / 411 debit 210 / 451 credit 210 / 440 credit 1000`,
fills boxes 86, 59 and 55, and leaves the supplier owed 1 000. The ledger and
the return say the same thing, because they are the same rows.

## Posting a document

`post_document(document_id)` in order:

1. refuses a document that is already posted, cancelled, empty, or a quote;
2. refuses a tax that is not in force on the accounting date, or a
   fixed-amount tax;
3. checks the period is open;
4. writes one base line per `(account, tax)` pair;
5. writes the tax lines, grouping the basis per tax and rounding once;
6. writes the third-party counterpart as the difference of everything above,
   with `date_maturity` from the due date or the contact's payment terms;
7. raises if that counterpart disagrees with the document total by more than
   half a cent — the ledger is right by construction, so the header is what is
   wrong;
8. numbers and posts the entry, and points the document at it.


## Tables

| Table | Purpose |
|---|---|
| [`account_templates`](#account_templates) | Reference charts of accounts, one set per country. |
| [`accounts`](#accounts) | Chart of accounts, one per company. |
| [`analytic_axes`](#analytic_axes) | Analytic dimensions: cost centre, project, activity. |
| [`analytic_values`](#analytic_values) | Values of an axis, optionally hierarchical. |
| [`api_keys`](#api_keys) | Machine access to one company. Hashed at rest, scoped to an explicit list of capabilities, and never wider than the person who issued it. |
| [`attachments`](#attachments) | Files attached to any record. `entity_type` is constrained rather than free text. |
| [`audit_log`](#audit_log) | Append-only record of every change to the configuration and reference data of a company, and of the acts that change the state of a document, a payment, a financial year or a pack. Written by trigger, never by a client; no update and no delete, for anyone. |
| [`bank_accounts`](#bank_accounts) | Bank and card accounts, each mapped to a ledger account and a journal. |
| [`bank_statement_lines`](#bank_statement_lines) | Which lines a statement lists. A line is stored once, in bank_transactions, under the first statement that brought it; a later statement that overlaps the first lists the same line here instead of duplicating it, and its closing balance is proved over the list. |
| [`bank_statements`](#bank_statements) | Imported statements. `is_consistent` compares the declared closing balance with the sum of the lines. |
| [`bank_transactions`](#bank_transactions) | Statement lines. `amount` is signed; `raw` keeps whatever the source sent. |
| [`book_imports`](#book_imports) | One row per set of books taken over by import_books(): which reader, the checksum of the files, how many entries and lines, and the numbers they were posted under. The same files twice in one company are refused by the unique checksum. |
| [`capabilities`](#capabilities) | Everything a member may be allowed to do, one row per code. Seeded by this migration for the core; a module adds its own with `area` set to the module code. |
| [`chart_templates`](#chart_templates) | Charts of accounts a country offers, from the `charts` list of packs/<cc>/pack.json. One of them is the default `ekwo init` installs when nobody names one. |
| [`companies`](#companies) | Legal entities kept in this instance. One instance may hold several. |
| [`company_archive_registry`](#company_archive_registry) | What an archive of one company does with each table of the socle that belongs to a company: `exported`, or `excluded` with the reason. A table of a company that is not named here stops every export. Modules answer for their own tables through `<schema>.archive_tables()`. |
| [`company_filing_periods`](#company_filing_periods) | How often this company files each declaration it is subject to: one row per form of tax_report_templates, and no row where nothing has been recorded. A company files its periodic return on one cadence and its recapitulative statement on another, and the second is not derivable from the first in any country read so far. |
| [`company_invitations`](#company_invitations) | Pending and past invitations into a company. The token is handed over once and kept only as a sha256 hash. |
| [`company_members`](#company_members) | Who may read or write a company. A role is a preset resolved through `role_capabilities`: `owner` administers, `accountant` books, `viewer` reads, `client` reads and hands pieces over. |
| [`company_modules`](#company_modules) | Modules enabled on a company, and the settings that company keeps for each. Written by enable_module() and disable_module() and by nothing else: there is no write policy. |
| [`company_packs`](#company_packs) | Which version of which country pack a company copied. A company may hold two: a foreign VAT registration is one. |
| [`contact_patterns`](#contact_patterns) | How a counterparty shows up on this company's statements: one row per learned or declared motif, of four closed kinds. Read by suggest_contacts(), written by confirm_contact(). The core still chooses no contact for anybody — it answers with candidates and says why. |
| [`contacts`](#contacts) | Third parties. `contact_type` is explicit rather than two hidden counters. |
| [`country_defaults`](#country_defaults) | Which template account plays which role, per country. |
| [`country_packs`](#country_packs) | Country packs loaded in this installation, with their version and certification. |
| [`currencies`](#currencies) | ISO 4217 currencies known to this instance. |
| [`currency_rates`](#currency_rates) | Dated exchange rates. A document stores the rate it used; this table is the history. |
| [`document_lines`](#document_lines) | Document lines in a table, not JSON: EN 16931 needs a VAT category per line and the FEC needs the detail. |
| [`document_shares`](#document_shares) | Public links onto a document. The token is handed over once and kept only as a sha256; the link is withdrawn by revoking it, never by editing it. |
| [`document_unpostings`](#document_unpostings) | Every posted document put back to draft by unpost_document(): the entry that was taken away, its number, journal and day, and whether the number went back to the counter. Written by unpost_document() and by nothing else — no role may insert — so the guards read a row here, written in the same transaction, as the one exception to "a posted document does not go back to draft" and "a posted entry is not deleted". |
| [`documents`](#documents) | Sales and purchase invoices, credit notes, quotes and orders. `state` is the document, `payment_state` the settlement. |
| [`entries`](#entries) | Journal entries. A document and its entry are two layers joined by a foreign key. |
| [`entry_line_analytics`](#entry_line_analytics) | Analytic split of a ledger line. One row per value, share in percent. |
| [`entry_lines`](#entry_lines) | Ledger lines. Amounts are always positive; a reversal flips the side, it never negates. |
| [`fiscal_years`](#fiscal_years) | Accounting periods. An exercise is an object, not two integers on the company. |
| [`instance`](#instance) | The installation itself. Exactly one row. Registration with Ekwo is optional and empty by default. |
| [`instance_admins`](#instance_admins) | Instance administrators: they create companies and invite members. One row per user, keyed on auth.users of the customer's own Supabase project. |
| [`journal_sequences`](#journal_sequences) | Counter behind next_entry_number(). One row per journal and year. |
| [`journal_templates`](#journal_templates) |  |
| [`journals`](#journals) | Books of entry. The code is the first segment of every entry number. |
| [`legal_mention_templates`](#legal_mention_templates) | The sentences a country requires on an invoice, and the closed condition that says when each applies. Reference data filled by a pack, never copied into a company. |
| [`matching_sequences`](#matching_sequences) |  |
| [`matching_settings`](#matching_settings) | What this company considers close enough. Every column is nullable and null means the shipped answer, which lives in matching_policy_of() and nowhere else — so a reader always gets a number and a company that never had an opinion has no row. |
| [`modules`](#modules) | One row per module this installation carries, written by the module's own first migration. The registry is a table, not code. |
| [`payments`](#payments) | Money in and out. Amounts are positive; `direction` carries the sign. |
| [`products`](#products) | What a document line is filled in from: code, name, unit, price, account and tax. Not stock: no quantity on hand and no valuation. |
| [`reconciliations`](#reconciliations) | One row per pairing of a debit with a credit. Full matching is the sum of partials. |
| [`role_capabilities`](#role_capabilities) | What each preset holds. A role is never tested by a policy; it is resolved here into capabilities. |
| [`statement_line_rules`](#statement_line_rules) | How an account of a company reaches a line. Presentation maps by range of the legal chart; choosing an account to post to by prefix stays forbidden, and is a different question. |
| [`statement_line_templates`](#statement_line_templates) | The lines of a statement, in the order it prints them, and the plus/minus lists a total is computed from. |
| [`statement_templates`](#statement_templates) | Financial statements per framework, from packs/<cc>/statements.json and packs/generic/. Reference data: never copied into a company. |
| [`tax_filing_boxes`](#tax_filing_boxes) | The figures as they were filed, one row per box. Frozen at filing and never recomputed: this is what the administration holds. |
| [`tax_filing_deposits`](#tax_filing_deposits) | One row per send of a declaration, with what came back: the deposit number, the outcome, the administration's own words, and the two files — what was sent and the receipt. A rejected declaration is sent again, so a declaration has as many deposits as it took. |
| [`tax_filings`](#tax_filings) | One row per declaration of a period: what was filed, when, under which reference, and in which state. The figures are in tax_filing_boxes and they are frozen — this table exists so that "what did we declare" is a question with an answer. |
| [`tax_posting_templates`](#tax_posting_templates) |  |
| [`tax_postings`](#tax_postings) | Where a tax lands: ledger account and VAT-return box, per tax and per document kind. |
| [`tax_report_box_templates`](#tax_report_box_templates) | The boxes of a declaration form, and the plus/minus lists a total is computed from. Read by vat_return(). |
| [`tax_report_templates`](#tax_report_templates) | Declaration forms per country, from packs/<cc>/tax_report.json. Reference data: a form is not customisable, so it is never copied into a company. |
| [`tax_templates`](#tax_templates) | Reference taxes per country, with their period of validity. |
| [`taxes`](#taxes) | VAT and similar taxes, with temporal validity and a legal reference. |
| [`territories`](#territories) | The territories of the common system of value added tax: the Member States with the day each became bound, the United Kingdom with the day it stopped being, Northern Ireland, and the territories articles 6 and 7 of Directive 2006/112/EC take out of the system or put into it. Framework data filled by the release, like currencies — no company owns a row and no country pack writes one. A territory this table does not carry is outside the common system, which is the answer for every third country. |
| [`user_preferences`](#user_preferences) | What one person prefers, across every company they are a member of. Every column is nullable and none has a default: null means "take the company's answer, then the pack's". |

### `account_templates`

Reference charts of accounts, one set per country.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `country` | `character(2)` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `account_type` | `account_type` | not null |
| `reconcilable` | `boolean` | not null |
| `parent_code` | `text` |  |
| `sequence` | `integer` | not null |
| `name_i18n` | `jsonb` | not null — Label by language, from packs/<cc>/i18n/. The pack's own language stays in `name`. |
| `statement_hint` | `text` | Free note: the statement line this account is meant for. Read by nothing — the rules of a statement decide — and kept so a chart can carry the intent. |
| `chart_code` | `text` | not null — Which chart of the country this account belongs to. Part of the natural key: two charts of one country may carry the same code with different meanings. |

Constraints:

- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `CHECK (((account_type <> ALL (ARRAY['asset_receivable'::account_type, 'liability_payable'::account_type])) OR reconcilable))`
- `PRIMARY KEY (id)`

### `accounts`

Chart of accounts, one per company.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `account_type` | `account_type` | not null |
| `internal_group` | `text` | generated — asset \| liability \| equity \| income \| expense \| off_balance, derived from account_type. |
| `carries_forward` | `boolean` | generated |
| `reconcilable` | `boolean` | not null — Whether entry lines on this account may be matched against each other. |
| `currency_code` | `character(3)` |  |
| `parent_id` | `uuid` |  |
| `deprecated` | `boolean` | not null |
| `notes` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `name_i18n` | `jsonb` | not null — Label by language, copied from the template at install. `name` holds the language the company chose. |
| `statement_hint` | `text` | Free note: the statement line this account is meant for. Read by nothing — the rules of a statement decide — and kept so a chart can carry the intent. |
| `pinned` | `boolean` | not null — Whether this account belongs to the working chart of the company whatever the ledger says. Set by install_country_template() on everything it wires, and by an operator afterwards. Display only: pinning restricts nothing. |

Constraints:

- `CHECK (((account_type <> ALL (ARRAY['asset_receivable'::account_type, 'liability_payable'::account_type])) OR reconcilable))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, code)`

### `analytic_axes`

Analytic dimensions: cost centre, project, activity.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `active` | `boolean` | not null |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `PRIMARY KEY (id)`
- `UNIQUE (company_id, code)`

### `analytic_values`

Values of an axis, optionally hierarchical.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `axis_id` | `uuid` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `parent_id` | `uuid` |  |
| `active` | `boolean` | not null |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `PRIMARY KEY (id)`
- `UNIQUE (axis_id, code)`

### `api_keys`

Machine access to one company. Hashed at rest, scoped to an explicit list of capabilities, and never wider than the person who issued it.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `name` | `text` | not null |
| `prefix` | `text` | not null — The readable head of the secret. It identifies a key without being one. |
| `key_hash` | `text` | not null |
| `capabilities` | `text[]` | not null — Exactly what this key may do. Not a role: a machine has a job, not a job title. |
| `created_by` | `uuid` | auth.users.id of whoever issued it. No foreign key, for the same reason company_members has none. |
| `created_at` | `timestamp with time zone` | not null |
| `expires_at` | `timestamp with time zone` |  |
| `last_used_at` | `timestamp with time zone` |  |
| `revoked_at` | `timestamp with time zone` |  |

Constraints:

- `CHECK (((expires_at IS NULL) OR (expires_at > created_at)))`
- `CHECK ((cardinality(capabilities) > 0))`
- `PRIMARY KEY (id)`
- `UNIQUE (key_hash)`

### `attachments`

Files attached to any record. `entity_type` is constrained rather than free text.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `entity_type` | `text` | not null |
| `entity_id` | `uuid` | not null |
| `file_name` | `text` | not null |
| `mime_type` | `text` |  |
| `byte_size` | `bigint` |  |
| `storage_path` | `text` | not null |
| `checksum` | `text` |  |
| `uploaded_by` | `uuid` | Who filed it. Defaults to the caller; a deposit is refused unless it says the caller. |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((entity_type = ANY (ARRAY['company'::text, 'contact'::text, 'document'::text, 'entry'::text, 'payment'::text, 'bank_statement'::text, 'bank_transaction'::text, 'fiscal_year'::text, 'tax_filing'::text])))`
- `CHECK (((byte_size IS NULL) OR (byte_size >= 0)))`
- `PRIMARY KEY (id)`

### `audit_log`

Append-only record of every change to the configuration and reference data of a company, and of the acts that change the state of a document, a payment, a financial year or a pack. Written by trigger, never by a client; no update and no delete, for anyone.

| Column | Type | Notes |
|---|---|---|
| `id` | `bigint` | not null |
| `occurred_at` | `timestamp with time zone` | not null |
| `actor_id` | `uuid` | auth.uid() at the time of the change. Null when the change came from a machine key or from a direct connection. |
| `api_key_id` | `uuid` | The machine key presented in the transaction, when one was. |
| `company_id` | `uuid` | The company the change belongs to, and what row level security reads. No foreign key: the trail outlives the row it describes. |
| `table_name` | `text` | not null |
| `record_id` | `uuid` |  |
| `record_key` | `text` | not null — The natural key of the row — an account code, a country, a user id — so a deleted row is still identifiable. |
| `operation` | `audit_operation` | not null |
| `action` | `text` | The business act this change is, when it is one. Null for an ordinary edit. |
| `old_values` | `jsonb` | The row before, as jsonb. Null on an insert. Secrets are replaced by null, never stored twice. |
| `new_values` | `jsonb` | The row after, as jsonb. Null on a delete. |

Constraints:

- `CHECK (((length(table_name) > 0) AND (length(record_key) > 0)))`
- `PRIMARY KEY (id)`

### `bank_accounts`

Bank and card accounts, each mapped to a ledger account and a journal.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `name` | `text` | not null |
| `iban` | `text` |  |
| `bic` | `text` |  |
| `bank_name` | `text` |  |
| `currency_code` | `character(3)` | not null |
| `account_id` | `uuid` |  |
| `journal_id` | `uuid` |  |
| `active` | `boolean` | not null |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `PRIMARY KEY (id)`

### `bank_statement_lines`

Which lines a statement lists. A line is stored once, in bank_transactions, under the first statement that brought it; a later statement that overlaps the first lists the same line here instead of duplicating it, and its closing balance is proved over the list.

| Column | Type | Notes |
|---|---|---|
| `company_id` | `uuid` | not null |
| `statement_id` | `uuid` | not null |
| `transaction_id` | `uuid` | not null |
| `position` | `integer` | not null — Where the line stands in this statement, from 1 — which is not where it stood in another. |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `PRIMARY KEY (statement_id, transaction_id)`

### `bank_statements`

Imported statements. `is_consistent` compares the declared closing balance with the sum of the lines.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `bank_account_id` | `uuid` | not null |
| `name` | `text` |  |
| `statement_date` | `date` | not null |
| `balance_start` | `numeric(16,2)` | not null |
| `balance_end_declared` | `numeric(16,2)` | not null |
| `balance_end_computed` | `numeric(16,2)` | not null |
| `is_consistent` | `boolean` | generated |
| `state` | `bank_statement_state` | not null |
| `source` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `statement_ref` | `text` | The identifier the bank gave the statement (Stmt/Id of a camt.053). With the account and the closing date it is what makes a replayed statement the same statement. Null on a statement entered by hand. |
| `sequence_number` | `numeric(18,0)` | The bank's own numbering of the statements of this account — the legal sequence number where the format has one, else the electronic one. A hole in it is a statement nobody imported; `bank_statement_continuity` shows it. |
| `period_start` | `date` | The day the statement opens on: the date of its opening balance, else the start of its period, else its first line. `statement_date` is the day it closes on. |
| `source_format` | `text` | What the statement was read from, as the reader named it — camt.053.001.08. Null on a statement entered by hand. |
| `source_file_name` | `text` | The name of the file the statement was first imported from, when the caller gave one. |
| `source_checksum` | `text` | The checksum of the file the statement was first imported from, as the caller computed it — the core never sees the bytes. Kept so that the file can be recognised later; not what makes an import idempotent, because the same statement arrives in files that differ by a timestamp. |

Constraints:

- `PRIMARY KEY (id)`

### `bank_transactions`

Statement lines. `amount` is signed; `raw` keeps whatever the source sent.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `statement_id` | `uuid` |  |
| `bank_account_id` | `uuid` | not null |
| `sequence` | `integer` | not null |
| `transaction_date` | `date` | not null |
| `value_date` | `date` |  |
| `amount` | `numeric(16,2)` | not null |
| `currency_code` | `character(3)` | not null |
| `description` | `text` |  |
| `counterpart_name` | `text` |  |
| `counterpart_iban` | `text` |  |
| `reference` | `text` |  |
| `structured_reference` | `text` |  |
| `contact_id` | `uuid` |  |
| `entry_id` | `uuid` |  |
| `state` | `bank_transaction_state` | not null |
| `raw` | `jsonb` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `import_key` | `text` | What makes an imported line the same line when its statement is replayed or overlapped: `ref:` and a digest when the bank gave the movement a reference, `fp:` and a digest of everything the statement says about it, with its occurrence among identical lines, when it did not. Unique per bank account, and written by import_bank_statement() only. Null on a line entered by hand. |

Constraints:

- `PRIMARY KEY (id)`

### `book_imports`

One row per set of books taken over by import_books(): which reader, the checksum of the files, how many entries and lines, and the numbers they were posted under. The same files twice in one company are refused by the unique checksum.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `source` | `text` | not null — The reader the files were read with — fec, trial-balance, journal-items, journal-report — as the caller named it. |
| `checksum` | `text` | not null — sha256 of the files read, in the order given, as the caller computed it. Unique per company, which is what refuses the same import twice. |
| `file_names` | `text[]` | not null |
| `entry_count` | `integer` | not null |
| `line_count` | `integer` | not null |
| `first_number` | `text` | Number of the first entry the import posted, and last_number of the last: the range to read, or to reverse, afterwards. |
| `last_number` | `text` |  |
| `opening_number` | `text` | Number of the opening entry the import posted through opening_balance(), when the files carried a trial balance. |
| `created_by` | `uuid` |  |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((checksum ~ '^sha256:[0-9a-f]{64}$'::text))`
- `CHECK (((entry_count >= 0) AND (line_count >= 0)))`
- `CHECK ((source ~ '^[a-z0-9][a-z0-9.-]{0,39}$'::text))`
- `PRIMARY KEY (id)`

### `capabilities`

Everything a member may be allowed to do, one row per code. Seeded by this migration for the core; a module adds its own with `area` set to the module code.

| Column | Type | Notes |
|---|---|---|
| `code` | `text` | not null |
| `area` | `text` | not null — What the code belongs to — a table family of the core, or the code of a module. |
| `description` | `text` | not null |

Constraints:

- `CHECK ((code ~ '^[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*$'::text))`
- `PRIMARY KEY (code)`

### `chart_templates`

Charts of accounts a country offers, from the `charts` list of packs/<cc>/pack.json. One of them is the default `ekwo init` installs when nobody names one.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `code` | `text` | not null — Immutable once published. `default` on the chart a country shipped before this table existed. |
| `name` | `text` | not null |
| `name_i18n` | `jsonb` | not null |
| `is_default` | `boolean` | not null |
| `audience` | `text` | Who keeps books on this chart — companies, nonprofits, a profession. Free text from the pack: the core does nothing with it, an installer shows it. |
| `statements` | `text[]` | not null — Codes of the financial statements this chart reports on. Empty means the generic framework by account type is all there is. |
| `certification_status` | `pack_certification` | How much this chart in particular has been read, when it differs from the pack as a whole. Null means the pack's own status stands. |
| `legal_reference` | `text` |  |
| `source_key` | `text` | Key of the entry in country_packs.sources where this chart's legal_reference can be read. Null where the pack names none. |

Constraints:

- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `PRIMARY KEY (country, code)`

### `companies`

Legal entities kept in this instance. One instance may hold several.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `name` | `text` | not null |
| `legal_name` | `text` |  |
| `legal_form` | `text` |  |
| `country` | `character(2)` | not null |
| `fiscal_country` | `character(2)` | not null — Country whose VAT rules apply; differs from `country` for a foreign VAT registration. |
| `vat_number` | `text` |  |
| `registration_number` | `text` |  |
| `address_line1` | `text` |  |
| `address_line2` | `text` |  |
| `postal_code` | `text` |  |
| `city` | `text` |  |
| `email` | `text` |  |
| `phone` | `text` |  |
| `website` | `text` |  |
| `currency_code` | `character(3)` | not null |
| `lock_date` | `date` | Accounting lock: nothing may be booked on or before this date. |
| `tax_lock_date` | `date` |  |
| `receivable_account_id` | `uuid` |  |
| `payable_account_id` | `uuid` |  |
| `suspense_account_id` | `uuid` |  |
| `rounding_account_id` | `uuid` |  |
| `retained_earnings_account_id` | `uuid` |  |
| `sales_journal_id` | `uuid` |  |
| `purchase_journal_id` | `uuid` |  |
| `miscellaneous_journal_id` | `uuid` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `default_sales_account_id` | `uuid` | Income account a sales line falls back to when it names none. Wired from country_defaults.sales_account_code at install. |
| `default_purchase_account_id` | `uuid` | Expense account a purchase line falls back to when it names none. Wired from country_defaults.purchase_account_code at install. |
| `language` | `character(2)` | not null — Language this company keeps its books in. Chosen at install; decides which label of name_i18n lands in accounts.name. |
| `region` | `text` | Province or state, ISO 3166-2 without the country prefix: QC, BC, CA. Null in a country that taxes uniformly. |
| `trade_name` | `text` | The name the company trades under, when it is not the statutory one. A renderer shows this and keeps legal_name for the footer. |
| `logo_url` | `text` | Where the logo is, as a URL or a storage path. The core stores no file: an accounting schema that held binaries would be backing up images with the ledger. |
| `share_capital` | `numeric(16,2)` | Capital to be stated on documents where the law requires it. Null where it does not, which is not zero. |
| `share_capital_currency` | `character(3)` | Currency the capital is expressed in. Filled with the company's own currency when it is left empty, and never with a currency written into the schema. |
| `activity_code` | `text` | The company's activity in the register of its country — NACE, APE, SIC. Text, because the registers are not numbers and not the same length. |
| `activity_scheme` | `text` | Which register activity_code belongs to. A code without its scheme cannot be looked up. |
| `default_bank_account_id` | `uuid` | The account a customer is asked to pay into. It fills documents.payee_iban (BT-84) when a sales document names none. |
| `document_template` | `text` | A code the renderer interprets. The core never reads it: what a document looks like is not an accounting question. |
| `vat_period` | `declaration_period` | Deprecated by company_filing_periods, and derived from it: how often this company files its country's periodic return, which is one of the several declarations it is subject to. Null means nothing has been recorded, which is not an error and not a cadence. Write the table; this column is written from it, and a write here is recorded there. |
| `territory_code` | `text` | Territory of `territories` this company is established in for tax, where the country is not precise enough: US-CA for a Californian filer, XI for a Northern Irish one. Null everywhere the country is the answer, which is every country of the common system of VAT — the resolution then reads fiscal_country. Distinct from `region`, which is a province code without a prefix and answers a different question. |
| `peppol_scheme` | `text` | Scheme of the electronic address this company receives and sends under (EN 16931 BT-34-1): a code of the Electronic Address Scheme list, e.g. 0088 for a GLN. A fact of the company's registration with its access point, never derived from its VAT or registration number. Null together with peppol_identifier. |
| `peppol_identifier` | `text` | The electronic address itself (EN 16931 BT-34), in the scheme peppol_scheme names. |

Constraints:

- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `CHECK ((currency_code ~ '^[A-Z]{3}$'::text))`
- `CHECK (((peppol_scheme IS NULL) = (peppol_identifier IS NULL)))`
- `CHECK ((fiscal_country ~ '^[A-Z]{2}$'::text))`
- `CHECK (((share_capital IS NULL) OR (share_capital_currency IS NOT NULL)))`
- `CHECK (((share_capital IS NULL) OR (share_capital >= (0)::numeric)))`
- `PRIMARY KEY (id)`

### `company_archive_registry`

What an archive of one company does with each table of the socle that belongs to a company: `exported`, or `excluded` with the reason. A table of a company that is not named here stops every export. Modules answer for their own tables through `<schema>.archive_tables()`.

| Column | Type | Notes |
|---|---|---|
| `table_schema` | `text` | not null |
| `table_name` | `text` | not null |
| `disposition` | `text` | not null |
| `reason` | `text` | Why the table stays behind. Required on an excluded table; on an exported one, what a reader should know about it. |
| `via_column` | `text` | For a table with no `company_id`: the column that leads to one that has it. |
| `via_table` | `text` | The table `via_column` points at, schema included. It carries `company_id`. |
| `load_order` | `integer` | The order an import fills the tables in. A reference that points forward, or at its own table, is filled in a second pass and has to be nullable. |

Constraints:

- `CHECK ((disposition = ANY (ARRAY['exported'::text, 'excluded'::text])))`
- `CHECK (((disposition = 'exported'::text) OR (length(COALESCE(reason, ''::text)) >= 20)))`
- `CHECK (((disposition = 'excluded'::text) OR (load_order IS NOT NULL)))`
- `CHECK (((via_column IS NULL) = (via_table IS NULL)))`
- `PRIMARY KEY (table_schema, table_name)`

### `company_filing_periods`

How often this company files each declaration it is subject to: one row per form of tax_report_templates, and no row where nothing has been recorded. A company files its periodic return on one cadence and its recapitulative statement on another, and the second is not derivable from the first in any country read so far.

| Column | Type | Notes |
|---|---|---|
| `company_id` | `uuid` | not null |
| `report_code` | `text` | not null — The form, by the code tax_report_templates gives it. Not a foreign key: the form is keyed on (country, code) and a company may file a form of a country that is not its own. A trigger refuses a code no form of this installation carries. |
| `period` | `declaration_period` | not null — How often this company files that form. Not null: a row that recorded nothing would say the same thing as no row, in a second way. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((length(report_code) > 0))`
- `PRIMARY KEY (company_id, report_code)`

### `company_invitations`

Pending and past invitations into a company. The token is handed over once and kept only as a sha256 hash.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `email` | `text` | not null — The address the invitation is for, lower-cased. accept_invitation() refuses anyone signed in with another. |
| `role` | `member_role` | not null |
| `capabilities_granted` | `text[]` | not null — Capabilities the new member holds on top of their preset, written onto company_members when the invitation is accepted. |
| `token_hash` | `text` | not null |
| `invited_by` | `uuid` | auth.users.id of whoever issued it. No foreign key, for the same reason company_members has none. |
| `created_at` | `timestamp with time zone` | not null |
| `expires_at` | `timestamp with time zone` | not null |
| `accepted_at` | `timestamp with time zone` |  |
| `accepted_by` | `uuid` |  |
| `revoked_at` | `timestamp with time zone` |  |

Constraints:

- `CHECK (((accepted_at IS NULL) = (accepted_by IS NULL)))`
- `CHECK ((email = lower(email)))`
- `CHECK ((email ~~ '%_@_%'::text))`
- `CHECK ((expires_at > created_at))`
- `PRIMARY KEY (id)`
- `UNIQUE (token_hash)`

### `company_members`

Who may read or write a company. A role is a preset resolved through `role_capabilities`: `owner` administers, `accountant` books, `viewer` reads, `client` reads and hands pieces over.

| Column | Type | Notes |
|---|---|---|
| `company_id` | `uuid` | not null |
| `user_id` | `uuid` | not null |
| `role` | `member_role` | not null |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `capabilities_granted` | `text[]` | not null — Capabilities this member holds beyond their preset. |
| `capabilities_revoked` | `text[]` | not null — Capabilities this member does not hold whatever their preset says. A revoke wins over a grant and over a role. |

Constraints:

- `CHECK ((role <> 'instance_admin'::member_role))`
- `PRIMARY KEY (company_id, user_id)`

### `company_modules`

Modules enabled on a company, and the settings that company keeps for each. Written by enable_module() and disable_module() and by nothing else: there is no write policy.

| Column | Type | Notes |
|---|---|---|
| `company_id` | `uuid` | not null |
| `module_code` | `text` | not null |
| `enabled_at` | `timestamp with time zone` | not null |
| `enabled_by` | `uuid` |  |
| `settings` | `jsonb` | not null — Per-company settings of the module, in its own vocabulary. The socle never reads inside this object. |

Constraints:

- `PRIMARY KEY (company_id, module_code)`

### `company_packs`

Which version of which country pack a company copied. A company may hold two: a foreign VAT registration is one.

| Column | Type | Notes |
|---|---|---|
| `company_id` | `uuid` | not null |
| `country` | `character(2)` | not null |
| `version` | `text` | not null |
| `installed_at` | `timestamp with time zone` | not null |
| `upgraded_at` | `timestamp with time zone` | Last time `install_country_template` or `ekwo pack upgrade` moved this company to another version. |
| `chart_code` | `text` | not null — Chart of the pack this company copied. `ekwo status` prints it, and `ekwo pack upgrade` compares against the same chart. |

Constraints:

- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `CHECK ((version ~ '^[0-9]+\.[0-9]+\.[0-9]+$'::text))`
- `PRIMARY KEY (company_id, country)`

### `contact_patterns`

How a counterparty shows up on this company's statements: one row per learned or declared motif, of four closed kinds. Read by suggest_contacts(), written by confirm_contact(). The core still chooses no contact for anybody — it answers with candidates and says why.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `contact_id` | `uuid` | not null |
| `kind` | `contact_pattern_kind` | not null |
| `value` | `text` | The account identifier as the statement wrote it, the spelling of the name, or the keyword. Null exactly when the kind is amount_range. An account identifier is not assumed to be an IBAN: half the world does not have one, and the scheme it is written in is a question the rest of this schema cannot answer yet. |
| `exclude_words` | `text[]` | Words that disqualify a line the keyword would otherwise claim. Only a description_keyword carries them. |
| `amount_min` | `numeric(16,2)` |  |
| `amount_max` | `numeric(16,2)` |  |
| `amount_typical` | `numeric(16,2)` | The amount most often seen inside the band. Never a condition — it orders two candidates that are otherwise equal. |
| `currency_code` | `character(3)` |  |
| `usage_count` | `integer` | not null — How many times this motif has been in front of a decision. |
| `success_count` | `integer` | not null — How many of those decisions confirmed the contact it names. |
| `confidence` | `numeric(4,3)` | not null — success + 1 over usage + 2 — the two counters and nothing else. A motif nobody has used yet is worth 0.5 and says so, instead of claiming certainty from one lucky match. |
| `last_matched_at` | `timestamp with time zone` |  |
| `source` | `contact_pattern_source` | not null — declared by a person, or learned from a confirmation. |
| `active` | `boolean` | not null — A motif turned off without being forgotten. An inactive motif is never read; its counters stay, so turning it back on does not restart the learning. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (((confidence >= (0)::numeric) AND (confidence <= (1)::numeric)))`
- `CHECK (
CASE kind
    WHEN 'amount_range'::contact_pattern_kind THEN ((value IS NULL) AND (exclude_words IS NULL) AND (amount_min IS NOT NULL) AND (amount_max IS NOT NULL) AND (currency_code IS NOT NULL) AND (amount_min <= amount_max))
    WHEN 'description_keyword'::contact_pattern_kind THEN ((value IS NOT NULL) AND (amount_min IS NULL) AND (amount_max IS NULL) AND (amount_typical IS NULL) AND (currency_code IS NULL))
    ELSE ((value IS NOT NULL) AND (exclude_words IS NULL) AND (amount_min IS NULL) AND (amount_max IS NULL) AND (amount_typical IS NULL) AND (currency_code IS NULL))
END)`
- `CHECK ((success_count >= 0))`
- `CHECK ((success_count <= usage_count))`
- `CHECK ((usage_count >= 0))`
- `PRIMARY KEY (id)`

### `contacts`

Third parties. `contact_type` is explicit rather than two hidden counters.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `name` | `text` | not null |
| `contact_type` | `contact_type` | not null |
| `is_company` | `boolean` | not null |
| `parent_id` | `uuid` | Billing parent; commercial_entity() walks to the root. |
| `vat_number` | `text` |  |
| `registration_number` | `text` |  |
| `auxiliary_code` | `text` | Sub-ledger code, exported as CompAuxNum in the FEC. |
| `email` | `text` |  |
| `phone` | `text` |  |
| `address_line1` | `text` |  |
| `address_line2` | `text` |  |
| `postal_code` | `text` |  |
| `city` | `text` |  |
| `country` | `character(2)` |  |
| `language` | `character(2)` |  |
| `currency_code` | `character(3)` |  |
| `payment_terms_days` | `smallint` | not null |
| `receivable_account_id` | `uuid` |  |
| `payable_account_id` | `uuid` |  |
| `iban` | `text` |  |
| `bic` | `text` |  |
| `peppol_scheme` | `text` | Scheme of the electronic address this party is reached at (EN 16931 BT-49-1): a code of the Electronic Address Scheme list. A fact of the party's registration, never derived from its VAT or registration number. |
| `peppol_identifier` | `text` | The electronic address itself (EN 16931 BT-49), in the scheme peppol_scheme names. |
| `active` | `boolean` | not null |
| `notes` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `region` | `text` | Province or state of the party, ISO 3166-2 without the country prefix. Canadian tax follows the buyer's province, not the seller's. |
| `territory_code` | `text` | Territory of `territories` this party is in, where its country is not precise enough. Null resolves to `country`. |
| `name_words` | `text[]` | generated — Every word of the name, lowercased and deduplicated by significant_words(). Generated. Read by suggest_contacts() to set aside, with one array operator, the contacts whose name shares no word with a statement line — before it scores the ones that do. |
| `client_ref` | `text` | A reference chosen by whoever created the row, unique per company where given. It exists so a caller that repeats a creation after a dropped connection finds the first one instead of making a second. It means nothing to the books. |

Constraints:

- `CHECK (((client_ref IS NULL) OR ((client_ref = btrim(client_ref)) AND ((length(client_ref) >= 1) AND (length(client_ref) <= 200)))))`
- `CHECK (((country IS NULL) OR (country ~ '^[A-Z]{2}$'::text)))`
- `CHECK (((parent_id IS NULL) OR (parent_id <> id)))`
- `CHECK ((payment_terms_days >= 0))`
- `PRIMARY KEY (id)`

### `country_defaults`

Which template account plays which role, per country.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `name` | `text` | not null |
| `currency_code` | `character(3)` | not null |
| `receivable_code` | `text` | not null |
| `payable_code` | `text` | not null |
| `suspense_code` | `text` |  |
| `rounding_code` | `text` |  |
| `retained_earnings_code` | `text` |  |
| `sales_account_code` | `text` |  |
| `purchase_account_code` | `text` |  |
| `bank_account_code` | `text` |  |
| `sales_journal_code` | `text` | not null |
| `purchase_journal_code` | `text` | not null |
| `misc_journal_code` | `text` | not null |
| `cash_account_code` | `text` | Ledger account behind the cash journal of this country, from the pack of that country. |
| `language_default` | `character(2)` | Language `ekwo init` offers for a company of this country, before the company row exists — like currency_code, and for the same reason. |
| `rounding_method` | `rounding_method` | not null — How a country rounds an amount, from the pack. Read by rounding_of() and applied by round_amount(), which is the only function of the schema that names a method. A pack that says nothing about rounding gets this column's own default, not a country's. |
| `cash_rounding_unit` | `numeric(8,4)` | not null — The smallest coin a cash total is rounded to when it is not the cent — 0.05 in Switzerland, 0.05 in the Netherlands for cash. **Declared, no reader yet**: no cash-payment path exists in the socle, so nothing rounds a total to it. Zero means the cent, which is what both packs declare. |
| `closing_style` | `closing_style` | Which of the three mechanisms close_fiscal_year() follows for a company of this country. Null until the pack says; there is no default, because a default would be one country's answer given to every other. |
| `current_year_result_profit_code` | `text` | Account the result of the year lands on when the year is profitable. Belgium 693, France 120. Null where the result goes straight to retained earnings. |
| `current_year_result_loss_code` | `text` | Same, for a loss. Belgium 793, France 129. Both countries keep a profit and a loss apart, so this is a pair and not one account. |
| `retained_earnings_loss_code` | `text` | Retained earnings account for an accumulated loss, where the chart keeps one apart from the profit account. Belgium 141, France 119. Null falls back to retained_earnings_code. |
| `opening_journal_code` | `text` | Code of the journal the opening and the year-end entries are booked on, from the pack. Null until the pack names one, and then nothing opens or closes: there is no code written into the schema to fall back on. |
| `numbering_gapless` | `boolean` | True where the law forbids a hole in the sequence of invoice numbers. Null until the pack says so. |
| `number_format` | `text` | Pattern of a document number: {CODE}, {YYYY} or {YY}, {MM}, {NNNN} zero-padded to as many N as are written, with literal text between them. Read by nothing yet; next_entry_number() produces CODE/YYYY/NNNN. |
| `legal_payment_days` | `integer` | Payment term the law sets in the absence of an agreement, in days. Not a company's own terms, which are documents.payment_terms. |
| `late_payment_reference` | `text` | Where the interest rate and the recovery indemnity for a late payment come from, in one sentence a renderer can print or an accountant can follow. |
| `tax_point_rule` | `text` | When the tax becomes chargeable under this country's general rule, in a closed vocabulary: invoice_date (the invoice fixes it), delivery_date (the supply fixes it), payment_date (collection fixes it), invoice_if_issued (the supply is the principle and an invoice displaces it where the country requires one — Belgium art. 17 and 22bis, Luxembourg art. 24), earliest_of_delivery_or_payment (whichever came first — Estonia KMS § 11 lg 1). A tax that departs from the country rule says so itself, with cash_basis. tax_point_of() is the only function that reads this column. |
| `einvoice_profile` | `text` | The structured invoice this country expects: peppol-bis-3, factur-x-en16931, xrechnung, a PINT profile. Null where electronic invoicing is not a thing. |
| `einvoice_mandatory_from` | `date` | The day the obligation starts. Where reception and emission start on different days, this is reception, which is what binds every company at once. |
| `party_scheme` | `text` | The Electronic Address Scheme (EAS) code under which a party of this country is usually *addressed* on the network — the scheme of an electronic address, BT-34-1 and BT-49-1. Four characters; the pack carries the value and the core never guesses one. It is a default an application may propose, not the address of anybody: that is companies.peppol_scheme and contacts.peppol_scheme. And it is not the scheme a registration number is written in (BT-30-1, BT-47-1), which has to be an ISO 6523 ICD: several EAS codes are not. |
| `vat_scheme` | `text` | The Electronic Address Scheme (EAS) code under which a party of this country is addressed by its VAT number, where the network allows it. Distinct from party_scheme: a company is addressed by its registration number or by its VAT number, and they are not the same identifier. Not an ISO 6523 ICD in general — the VAT schemes of the EAS list are outside that standard. |
| `bank_statement_formats` | `text[]` | Statement formats a bank of this country sends — coda, camt.053, cfonb120 — from the pack. **Read by clients, not by the socle**: import_bank_statement() takes what a format reader returned and does not ask which format it came from, so this list is what a client offers, and a name in it is a promise only where a reader exists. camt.053 has one; the others are owed, by name, in tests/bank_statement_formats.test.ts. |
| `payment_formats` | `text[]` | Payment file formats a bank of this country accepts — pain.001, cfonb160 — from the pack. **Declared, no reader yet**: the socle writes no payment file. Same shape as bank_statement_formats, and it will be read by the same phase. |
| `fiscal_year_default` | `text` | Month the financial year usually opens on: calendar, april, july, october. A default offered, never imposed — fiscal_years holds what a company actually keeps. |
| `fx_gain_code` | `text` | Account a realised exchange gain is booked on, from the pack. Null until the pack names one, and then a matching that realises a gain is refused rather than booked somewhere plausible. |
| `fx_loss_code` | `text` | The same for a realised loss. A pair, because every chart in scope keeps the gain and the loss apart. |
| `asset_disposal_gain_code` | `text` | Net-result disposal: the account a gain on the disposal of a fixed asset lands on (Belgium 763). Null under the gross style, and null until a pack names one. |
| `asset_disposal_loss_code` | `text` | Net-result disposal: the account a loss lands on (Belgium 663). Left empty where the chart keeps one account for both signs, and then the gain account answers for both. |
| `asset_disposal_proceeds_code` | `text` | Gross disposal: the income account the proceeds of a sale are booked on in full (France 775). Null under the net-result style. |
| `asset_disposal_value_code` | `text` | Gross disposal: the charge account the net book value of the asset sold is booked on in full (France 675). Null under the net-result style. |
| `name_i18n` | `jsonb` | not null — The country's own name by language, from packs/<cc>/i18n/. `name` holds it in English, which is what a country pack manifest is written in. |
| `languages` | `text[]` | not null — Languages this country pack publishes every label in, the language of the pack itself first. An installer offers them; nothing in the schema restricts a company to them. |
| `opening_entry_label` | `text` | Wording the computed opening lines of an export carry, from the pack, in the language the administration of this country reads. Null falls back to a neutral English label: the format fixes no wording, so there is no wrong answer to guess at. |
| `vat_period_default` | `declaration_period` | Deprecated by tax_report_templates.period_default, which asks the same question of the form rather than of the country. Kept because it is published and still written by the pack compiler, with the value of the periodic return's own default; a country that files two periodic returns has two answers and this column can hold one, which is why the form is now the place. Read nothing new from here. |
| `numbering_legal_reference` | `text` | The article requiring a sequential, uniquely identifying invoice number, and the shape of that number where the country prescribes one. Covers numbering_gapless and number_format together: both answer the same article. |
| `numbering_source_key` | `text` | Key of the entry in country_packs.sources where numbering_legal_reference can be read. Null where the pack names none. |
| `payment_terms_legal_reference` | `text` | The article setting legal_payment_days in the absence of an agreement. Distinct from late_payment_reference, which says where the interest and the recovery indemnity come from and is written to be printed. |
| `payment_terms_source_key` | `text` | Key of the entry in country_packs.sources where payment_terms_legal_reference can be read. Null where the pack names none. |
| `tax_point_legal_reference` | `text` | The article fixing tax_point_rule. Where the value is a derogation rather than the country's principle, the reference says which, so a reader is not left believing the pack read the wrong article. |
| `tax_point_source_key` | `text` | Key of the entry in country_packs.sources where tax_point_legal_reference can be read. Null where the pack names none. |
| `einvoice_legal_reference` | `text` | The text making einvoice_profile obligatory from einvoice_mandatory_from. Where reception and emission start on different days, the emission calendar is written out here; where a country has several registration identifiers, this is where the ones party_scheme could not hold are named. |
| `einvoice_source_key` | `text` | Key of the entry in country_packs.sources where einvoice_legal_reference can be read. Null where the pack names none. |
| `tax_payable_code` | `text` | The account that carries what a filed declaration owes to the administration, once the tax accounts of the period have been cleared into it (FR 445510, LU 461412, GB 2210). It has to be an account apart from the ones the taxes themselves post to, and reconcilable, because the payment is matched against it. Null until a pack names one, and then settling refuses by name. |
| `tax_receivable_code` | `text` | The same account for a period that ends in a credit, where the chart keeps the two apart (FR 445670). Null falls back to tax_payable_code, for a chart that keeps one control account whose sign says which way it goes. |
| `posted_edit_policy` | `text` | Whether this country lets a posted document go back to draft: reversal_only (a credit note, cancel_document(), and nothing else) or unpost_if_untouched (also unpost_document(), while the document was not sent, not settled, not declared, its period open and, where numbering is gapless, its number the last drawn). Null where the pack says nothing, read as reversal_only. posted_edit_policy() is the only function that reads it. |
| `posted_edit_policy_legal_reference` | `text` | The article behind posted_edit_policy, as the pack cites it. |
| `posted_edit_policy_source_key` | `text` | Key of the entry in the pack's source register where that article is read. |
| `einvoice_obligation` | `text` | Whether a statute obliges companies of this country to exchange electronic invoices between themselves: mandatory (from einvoice_mandatory_from), on_request (a seller has to issue one when a buyer the law entitles to ask does; no date binds everybody) or none (no such statute at the day the pack was released). An obligation towards the public sector alone is said in einvoice_legal_reference. Null where the pack says nothing. |

Constraints:

- `CHECK ((cash_rounding_unit >= (0)::numeric))`
- `CHECK (
CASE einvoice_obligation
    WHEN 'mandatory'::text THEN (einvoice_mandatory_from IS NOT NULL)
    WHEN 'on_request'::text THEN (einvoice_mandatory_from IS NULL)
    WHEN 'none'::text THEN (einvoice_mandatory_from IS NULL)
    ELSE true
END)`
- `CHECK (((einvoice_obligation IS NULL) OR (einvoice_obligation = ANY (ARRAY['mandatory'::text, 'on_request'::text, 'none'::text]))))`
- `CHECK (((fiscal_year_default IS NULL) OR (fiscal_year_default = ANY (ARRAY['calendar'::text, 'april'::text, 'july'::text, 'october'::text]))))`
- `CHECK (((legal_payment_days IS NULL) OR (legal_payment_days >= 0)))`
- `CHECK (((party_scheme IS NULL) OR (party_scheme ~ '^[0-9]{4}$'::text)))`
- `CHECK (((posted_edit_policy IS NULL) OR (posted_edit_policy = ANY (ARRAY['reversal_only'::text, 'unpost_if_untouched'::text]))))`
- `CHECK (((tax_point_rule IS NULL) OR (tax_point_rule = ANY (ARRAY['invoice_date'::text, 'delivery_date'::text, 'payment_date'::text, 'invoice_if_issued'::text, 'earliest_of_delivery_or_payment'::text]))))`
- `CHECK (((vat_scheme IS NULL) OR (vat_scheme ~ '^[0-9]{4}$'::text)))`
- `PRIMARY KEY (country)`

### `country_packs`

Country packs loaded in this installation, with their version and certification.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `name` | `text` | not null |
| `version` | `text` | not null |
| `released_at` | `date` |  |
| `schema_min` | `text` |  |
| `certification_status` | `pack_certification` | not null — How much a pack has been read, printed by `ekwo init`: community (contributed, unread), maintained (by Ekwo, not yet reviewed), reviewed (by the professional named in certified_by). |
| `certified_by` | `text` | The professional who reviewed the pack. Only on a reviewed pack: maintaining is not reviewing. |
| `certified_at` | `date` |  |
| `checksum` | `text` | sha256 of the pack files, so a changed pack is visible without a diff. |
| `installed_at` | `timestamp with time zone` | not null |
| `sources` | `jsonb` | not null — Register of the texts this pack was built from, in the pack's own order: [{key, title, publisher, url, consulted_on, kind, reason_codes}]. `kind` is one of law, regulation, form, standard, portal, guidance. `reason_codes` is true on the one entry — at most one, and a `standard` — that publishes the list an exemption reason code of this country comes from; absent everywhere else. Written by the generated seed; never a copy of the text itself. |

Constraints:

- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `CHECK ((version ~ '^[0-9]+\.[0-9]+\.[0-9]+$'::text))`
- `PRIMARY KEY (country)`

### `currencies`

ISO 4217 currencies known to this instance.

| Column | Type | Notes |
|---|---|---|
| `code` | `character(3)` | not null |
| `name` | `text` | not null |
| `symbol` | `text` |  |
| `decimal_places` | `smallint` | not null — Decimals this currency is written with: 2 for the euro, 0 for the yen, 3 for the dinar. Read by rounding_of(), which is what every amount in the schema is rounded at. The columns that hold an amount are still numeric(16, 2), so a currency with more than two decimals is rounded right and stored short until they are widened. |
| `active` | `boolean` | not null |

Constraints:

- `CHECK ((code ~ '^[A-Z]{3}$'::text))`
- `CHECK (((decimal_places >= 0) AND (decimal_places <= 6)))`
- `PRIMARY KEY (code)`

### `currency_rates`

Dated exchange rates. A document stores the rate it used; this table is the history.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `currency_code` | `character(3)` | not null |
| `rate_date` | `date` | not null |
| `rate` | `numeric(18,8)` | not null |
| `source` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((rate > (0)::numeric))`
- `PRIMARY KEY (id)`
- `UNIQUE (currency_code, rate_date)`

### `document_lines`

Document lines in a table, not JSON: EN 16931 needs a VAT category per line and the FEC needs the detail.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `document_id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `sequence` | `integer` | not null |
| `line_type` | `document_line_type` | not null |
| `name` | `text` | not null |
| `quantity` | `numeric(16,4)` | not null |
| `unit_code` | `text` | not null |
| `unit_price` | `numeric(16,6)` | not null |
| `discount_percent` | `numeric(7,4)` | not null |
| `tax_id` | `uuid` |  |
| `account_id` | `uuid` |  |
| `vat_category` | `text` | EN 16931 BT-151 as the line carries it. Derived from the tax while the document is a draft and frozen when it is posted, so a pack upgrade that recategorises a tax cannot rewrite an invoice that has been sent. Never keyed. |
| `vat_rate` | `numeric(7,4)` | EN 16931 BT-152 as the line carries it: the percentage of the tax, derived while the document is a draft and frozen when it is posted, so a later change of rate cannot rewrite an invoice that has been sent. Null where the tax is not a percentage. Never keyed. |
| `amount_untaxed` | `numeric(16,2)` | quantity x unit_price less the discount, rounded once at the decimals of the document's currency. Written by a trigger on every insert and update, so it is derived and never keyed in. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `product_id` | `uuid` | The catalogue row this line was filled in from, when there was one. Nullable for ever: free text is how most invoices are written. |
| `description` | `text` | Item description, EN 16931 BT-154. `name` is BT-153. |
| `unit_price_includes_tax` | `boolean` | not null — The unit price of this line was quoted with the tax in it. Derived from the tax while the document is a draft and frozen when it is posted, like BT-151 and BT-152, so a later change to the tax cannot rewrite an invoice that has been sent. |
| `amount_incl_tax` | `numeric(16,2)` | quantity x unit_price less the discount, tax included, as the line was quoted. Null where the price excludes the tax, which is every line of every pack but a retail one. |

Constraints:

- `CHECK (((discount_percent >= (0)::numeric) AND (discount_percent < (100)::numeric)))`
- `CHECK (((NOT unit_price_includes_tax) OR (tax_id IS NOT NULL)))`
- `CHECK (((line_type <> 'product'::document_line_type) OR (account_id IS NOT NULL)))`
- `CHECK (((vat_category IS NULL) OR (vat_category ~ '^[A-Z]{1,2}$'::text)))`
- `PRIMARY KEY (id)`

### `document_shares`

Public links onto a document. The token is handed over once and kept only as a sha256; the link is withdrawn by revoking it, never by editing it.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `subject_kind` | `share_subject_kind` | not null |
| `document_id` | `uuid` |  |
| `token_hash` | `text` | not null — sha256 of the token, hex. The token itself is returned by share_document() and stored nowhere. |
| `expires_at` | `timestamp with time zone` | When the link stops answering. Null means it answers until it is revoked, which is a deliberate choice and not an oversight: an invoice is looked at years later. |
| `revoked_at` | `timestamp with time zone` | When the link was withdrawn. A withdrawn link answers exactly like one that never existed. |
| `created_by` | `uuid` | auth.users.id of whoever created it. No foreign key, for the same reason company_members has none. |
| `created_at` | `timestamp with time zone` | not null |
| `view_count` | `integer` | not null — How many times the document was read through this link. No address and no user agent: who opened it and from where is a log the application keeps, with the retention policy that goes with it. |
| `last_viewed_at` | `timestamp with time zone` |  |

Constraints:

- `CHECK (((expires_at IS NULL) OR (expires_at > created_at)))`
- `CHECK (((subject_kind = 'document'::share_subject_kind) = (document_id IS NOT NULL)))`
- `CHECK ((token_hash ~ '^[0-9a-f]{64}$'::text))`
- `CHECK ((view_count >= 0))`
- `PRIMARY KEY (id)`
- `UNIQUE (token_hash)`

### `document_unpostings`

Every posted document put back to draft by unpost_document(): the entry that was taken away, its number, journal and day, and whether the number went back to the counter. Written by unpost_document() and by nothing else — no role may insert — so the guards read a row here, written in the same transaction, as the one exception to "a posted document does not go back to draft" and "a posted entry is not deleted".

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `document_id` | `uuid` | not null |
| `doc_type` | `doc_type` | not null |
| `entry_id` | `uuid` | not null |
| `entry_number` | `text` | not null |
| `journal_id` | `uuid` | not null |
| `entry_date` | `date` | not null |
| `number_returned` | `boolean` | not null |
| `unposted_by` | `uuid` |  |
| `unposted_at` | `timestamp with time zone` | not null |
| `transaction_id` | `bigint` | not null |

Constraints:

- `PRIMARY KEY (id)`

### `documents`

Sales and purchase invoices, credit notes, quotes and orders. `state` is the document, `payment_state` the settlement.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `doc_type` | `doc_type` | not null |
| `state` | `doc_state` | not null |
| `payment_state` | `payment_state` | not null |
| `number` | `text` |  |
| `supplier_reference` | `text` | The supplier's own invoice number on a purchase. |
| `contact_id` | `uuid` | not null |
| `journal_id` | `uuid` |  |
| `document_date` | `date` | not null |
| `accounting_date` | `date` | Date the entry is booked on; defaults to document_date. |
| `due_date` | `date` |  |
| `currency_code` | `character(3)` | not null |
| `exchange_rate` | `numeric(18,8)` | not null — Units of the document currency for one unit of the company currency, as currency_rates states it. The ledger amount is the document amount divided by it. 1 when the document is in the company currency. |
| `buyer_reference` | `text` |  |
| `project_reference` | `text` |  |
| `contract_reference` | `text` |  |
| `order_reference` | `text` |  |
| `delivery_date` | `date` |  |
| `delivery_address_line1` | `text` |  |
| `delivery_postal_code` | `text` |  |
| `delivery_city` | `text` |  |
| `delivery_country` | `character(2)` |  |
| `payment_terms` | `text` |  |
| `payment_means_code` | `text` |  |
| `payment_reference` | `text` |  |
| `payee_iban` | `text` |  |
| `note` | `text` |  |
| `currency_code_tax` | `character(3)` |  |
| `amount_untaxed` | `numeric(16,2)` | not null |
| `amount_tax` | `numeric(16,2)` | not null |
| `amount_total` | `numeric(16,2)` | not null |
| `amount_paid` | `numeric(16,2)` | not null — Derived from reconciliations on the third-party lines of the document's entry: document_amount_paid(). Once the document is posted, any other figure is refused. |
| `amount_residual` | `numeric(16,2)` | generated |
| `reversed_document_id` | `uuid` |  |
| `entry_id` | `uuid` |  |
| `sent_at` | `timestamp with time zone` |  |
| `peppol_status` | `text` |  |
| `peppol_message_id` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `language` | `character(2)` | not null — The language this document is written in: its legal mentions, and whatever a renderer prints from the labels of the schema. Taken from the customer, else the company, else the country pack when the document is created, kept in step while it is a draft, and frozen the moment it is posted — a document already sent is not rewritten because its customer later changed preference. |
| `supply_territory_code` | `text` | Territory of `territories` the supply takes place in, where `delivery_country` is not precise enough — a delivery to US-CA and one to US-NY are both US. Null resolves to delivery_country, and then to the buyer's territory: a supply nobody said anything else about is delivered to the person who bought it. |
| `tax_point_date` | `date` | EN 16931 BT-7: the day the tax on this document falls due, which is not the day the entry is booked on. Given on the document it is kept — an e-invoice states its own tax point and a stated fact outranks a rule — and left null it is worked out by post_document() from the country rule and written back here. |
| `client_ref` | `text` | A reference chosen by whoever created the document, unique per company where given: the idempotency key of a creation. Not the document number, not the supplier's reference, and never printed. |
| `seller_territory_code` | `text` | The territory of the seller as post_document() resolved it when the document was posted — the company on a sale, the contact on a purchase, its territory_code or failing that its country. Written by posting, frozen with the document, given back to null when unpost_document() returns it to draft. Null on a draft and on a document posted before it was recorded. |
| `buyer_territory_code` | `text` | The territory of the buyer as post_document() resolved it when the document was posted. Frozen with the document; null on a draft. |
| `supply_territory_resolved` | `text` | The place of supply as post_document() resolved it when the document was posted: supply_territory_code, failing that delivery_country, failing that the buyer's territory. What the tax's territory conditions were judged against. Frozen with the document; null on a draft. |

Constraints:

- `CHECK (((client_ref IS NULL) OR ((client_ref = btrim(client_ref)) AND ((length(client_ref) >= 1) AND (length(client_ref) <= 200)))))`
- `CHECK (((state <> 'posted'::doc_state) OR (number IS NOT NULL)))`
- `CHECK ((exchange_rate > (0)::numeric))`
- `PRIMARY KEY (id)`

### `entries`

Journal entries. A document and its entry are two layers joined by a foreign key.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `journal_id` | `uuid` | not null |
| `fiscal_year_id` | `uuid` |  |
| `number` | `text` | CODE/YYYY/NNNN, assigned at posting. |
| `entry_date` | `date` | not null |
| `reference` | `text` |  |
| `description` | `text` |  |
| `state` | `entry_state` | not null |
| `document_id` | `uuid` |  |
| `reversed_entry_id` | `uuid` |  |
| `currency_code` | `character(3)` |  |
| `total_debit` | `numeric(16,2)` | not null — Derived from entry_lines by trigger; the lines are authoritative. |
| `total_credit` | `numeric(16,2)` | not null |
| `is_balanced` | `boolean` | generated |
| `posted_at` | `timestamp with time zone` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `kind` | `entry_kind` | not null — normal, opening or closing. Written by opening_balance(), close_fiscal_year() and reopen_fiscal_year(), and by nothing else. |
| `module_code` | `text` | Which module wrote this entry, or null for an entry of the socle. Set by post_module_entry(). |
| `module_ref` | `text` | What the entry is for, in the module's own words — `depreciation:2026-03` , `disposal:<uuid>`. Unique per company and module, which is what makes a module's posting idempotent. |

Constraints:

- `CHECK (((state <> 'posted'::entry_state) OR (number IS NOT NULL)))`
- `CHECK (((state <> 'posted'::entry_state) OR (total_debit = total_credit)))`
- `PRIMARY KEY (id)`

### `entry_line_analytics`

Analytic split of a ledger line. One row per value, share in percent.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `entry_line_id` | `uuid` | not null |
| `analytic_value_id` | `uuid` | not null |
| `percentage` | `numeric(7,3)` | not null |
| `amount` | `numeric(16,2)` |  |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (((percentage > (0)::numeric) AND (percentage <= (100)::numeric)))`
- `PRIMARY KEY (id)`
- `UNIQUE (entry_line_id, analytic_value_id)`

### `entry_lines`

Ledger lines. Amounts are always positive; a reversal flips the side, it never negates.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `entry_id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `account_id` | `uuid` | not null |
| `sequence` | `integer` | not null |
| `name` | `text` |  |
| `debit` | `numeric(16,2)` | not null |
| `credit` | `numeric(16,2)` | not null |
| `balance` | `numeric(16,2)` | generated |
| `currency_code` | `character(3)` |  |
| `amount_currency` | `numeric(16,2)` | The amount of this line in its own currency, written whenever that currency is not the company's. Positive like debit and credit; the side carries the sign. |
| `contact_id` | `uuid` |  |
| `date_maturity` | `date` |  |
| `tax_id` | `uuid` |  |
| `tax_line` | `boolean` | not null |
| `declaration_box` | `text` | VAT-return box this line feeds, copied from the tax posting that produced it. |
| `box_amount` | `numeric(16,2)` | Amount to report in that box, in the sign the form expects. A line of a cash-basis tax carries the amount with no box: it is computed when the document is posted and waits for the matching that names the box it is finally reported in. |
| `matching_number` | `text` | Reconciliation letter shared by matched lines. Exported as EcritureLet in the FEC. |
| `matched_amount` | `numeric(16,2)` | not null |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `posting_type` | `tax_posting_type` | Which tax posting wrote this line: base, tax, or tax_on_base, from tax_postings.posting_type. Null on a line no tax posting wrote — a counterpart, a payment, a closing line — and null on a line written before this column existed whose posting could not be identified beyond doubt; tax_id tells the two apart. It is what makes a base line and a tax_on_base line of the same tax on the same account distinguishable, which tax_id and tax_line together cannot do. |
| `tax_point_date` | `date` | The day the tax of this line fell due, from the document's tax point or, on the transfer that makes a cash-basis tax due, from the collection. It is the date vat_return() puts the figure in a period by. Null on a line no tax posting wrote and on every line written before this column existed: the entry's own date then answers, which is the reading the declaration always had. |

Constraints:

- `CHECK (((debit >= (0)::numeric) AND (credit >= (0)::numeric)))`
- `CHECK (((matched_amount >= (0)::numeric) AND (matched_amount <= abs((debit - credit)))))`
- `CHECK (((debit = (0)::numeric) OR (credit = (0)::numeric)))`
- `CHECK (((posting_type IS NULL) OR (tax_id IS NOT NULL)))`
- `PRIMARY KEY (id)`

### `fiscal_years`

Accounting periods. An exercise is an object, not two integers on the company.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `name` | `text` | not null |
| `start_date` | `date` | not null |
| `end_date` | `date` | not null |
| `is_closed` | `boolean` | not null |
| `closed_at` | `timestamp with time zone` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((end_date > start_date))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, start_date)`

### `instance`

The installation itself. Exactly one row. Registration with Ekwo is optional and empty by default.

| Column | Type | Notes |
|---|---|---|
| `id` | `smallint` | not null |
| `instance_id` | `uuid` | not null — Stable identifier of this installation, generated locally. Never a licence key. |
| `organization_name` | `text` | not null |
| `country` | `character(2)` | The country of the first company, when `ekwo init` created one with the installation. Null for an installation set up without a company. Informative: every company carries its own country, and nothing reads this one to decide anything. |
| `edition` | `instance_edition` | not null — community when you run it yourself, cloud when Ekwo operates it. Gates nothing in this repository. |
| `schema_version` | `text` | not null — Version of the schema at install, updated by migrations. |
| `installed_at` | `timestamp with time zone` | not null |
| `contact_email` | `text` | Opt-in only: an address to reach the operator. Empty unless they asked to register. |
| `registered_at` | `timestamp with time zone` | Opt-in only: when the operator registered with Ekwo. Empty means not registered, which is a supported state. |
| `updated_at` | `timestamp with time zone` | not null |
| `public_base_url` | `text` | Where this installation answers on the public internet, as an origin with no trailing slash — the base a shared document link is built on. Null where the operator has not said, and then a share returns its token with no URL. |

Constraints:

- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `CHECK (((public_base_url IS NULL) OR (public_base_url ~ '^https?://[^[:space:]]+$'::text)))`
- `CHECK (((registered_at IS NULL) OR (contact_email IS NOT NULL)))`
- `CHECK ((id = 1))`
- `PRIMARY KEY (id)`
- `UNIQUE (instance_id)`

### `instance_admins`

Instance administrators: they create companies and invite members. One row per user, keyed on auth.users of the customer's own Supabase project.

| Column | Type | Notes |
|---|---|---|
| `user_id` | `uuid` | not null — An auth.users.id in the customer's Supabase Auth. Ekwo holds no account and no directory. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `PRIMARY KEY (user_id)`

### `journal_sequences`

Counter behind next_entry_number(). One row per journal and year.

| Column | Type | Notes |
|---|---|---|
| `journal_id` | `uuid` | not null |
| `year` | `smallint` | not null — The period the counter belongs to: the year where the pattern carries one, and 0 where it does not and the series runs on. |
| `last_number` | `integer` | not null |

Constraints:

- `CHECK ((last_number >= 0))`
- `PRIMARY KEY (journal_id, year)`

### `journal_templates`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `country` | `character(2)` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `journal_type` | `journal_type` | not null |
| `sequence` | `integer` | not null |
| `name_i18n` | `jsonb` | not null — Label by language, from packs/<cc>/i18n/. The language the pack itself is written in stays in `name`. |

Constraints:

- `PRIMARY KEY (id)`
- `UNIQUE (country, code)`

### `journals`

Books of entry. The code is the first segment of every entry number.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `journal_type` | `journal_type` | not null |
| `default_account_id` | `uuid` |  |
| `suspense_account_id` | `uuid` | Where a bank line lands before it is allocated. |
| `bank_account_id` | `uuid` |  |
| `currency_code` | `character(3)` |  |
| `active` | `boolean` | not null |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `name_i18n` | `jsonb` | not null — Label by language, copied from the template at install. `name` holds the language the company chose, and a company may rename a journal without losing the other languages. |

Constraints:

- `CHECK ((code ~ '^[A-Z0-9]{2,8}$'::text))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, code)`

### `legal_mention_templates`

The sentences a country requires on an invoice, and the closed condition that says when each applies. Reference data filled by a pack, never copied into a company.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `country` | `character(2)` | not null |
| `code` | `text` | not null |
| `applies_when` | `text` | not null — One of nine conditions. A closed vocabulary and not an expression: a pack that could write a condition would be a pack that executes. |
| `text` | `text` | not null — The mention in the pack's own language. Other languages are in text_i18n, by language code. |
| `text_i18n` | `jsonb` | not null |
| `sequence` | `integer` | not null — Order the mentions are printed in. |
| `valid_from` | `date` | not null |
| `valid_to` | `date` |  |
| `legal_reference` | `text` | The article that requires this sentence. A mention without a source cannot be reviewed. |

Constraints:

- `CHECK ((applies_when = ANY (ARRAY['always'::text, 'reverse_charge'::text, 'intra_eu_goods'::text, 'intra_eu_services'::text, 'export'::text, 'exempt'::text, 'small_business'::text, 'late_payment'::text, 'cash_basis'::text])))`
- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))`
- `PRIMARY KEY (id)`
- `UNIQUE (country, code)`

### `matching_sequences`

| Column | Type | Notes |
|---|---|---|
| `company_id` | `uuid` | not null |
| `last_number` | `integer` | not null |

Constraints:

- `PRIMARY KEY (company_id)`

### `matching_settings`

What this company considers close enough. Every column is nullable and null means the shipped answer, which lives in matching_policy_of() and nowhere else — so a reader always gets a number and a company that never had an opinion has no row.

| Column | Type | Notes |
|---|---|---|
| `company_id` | `uuid` | not null |
| `name_threshold` | `numeric(4,3)` | How much of a name has to agree before a contact is proposed at all, between 0 and 1. |
| `amount_tolerance_units` | `integer` | How many smallest units of the currency two amounts may differ by and still be the same payment. Units, not cents: the currency says how much a unit is worth. |
| `sum_tolerance_units` | `integer` | The same, for a transaction that pays several documents at once, where each of them was rounded on its own. |
| `date_window_days` | `integer` | How far from a document a payment may sit and still be proposed for it. |
| `minimum_word_length` | `integer` | How long a word has to be to count as evidence of a name. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((amount_tolerance_units >= 0))`
- `CHECK ((date_window_days >= 0))`
- `CHECK ((minimum_word_length >= 1))`
- `CHECK (((name_threshold >= (0)::numeric) AND (name_threshold <= (1)::numeric)))`
- `CHECK ((sum_tolerance_units >= 0))`
- `PRIMARY KEY (company_id)`

### `modules`

One row per module this installation carries, written by the module's own first migration. The registry is a table, not code.

| Column | Type | Notes |
|---|---|---|
| `code` | `text` | not null |
| `name` | `text` | not null |
| `description` | `text` |  |
| `schema_name` | `text` | not null — The Postgres schema the module lives in. PostgREST only exposes it once it is listed in the API settings, which no migration can do — `ekwo module enable` prints the line to add. |
| `version` | `text` | not null |
| `status` | `module_status` | not null |
| `requires_socle_min` | `text` | Oldest socle migration version this module needs. Read by `ekwo module enable` against the migration history. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((code ~ '^[a-z][a-z0-9_]{1,30}$'::text))`
- `CHECK ((schema_name ~ '^[a-z][a-z0-9_]{1,30}$'::text))`
- `CHECK ((schema_name <> 'public'::text))`
- `PRIMARY KEY (code)`
- `UNIQUE (schema_name)`

### `payments`

Money in and out. Amounts are positive; `direction` carries the sign.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `direction` | `payment_direction` | not null |
| `payment_date` | `date` | not null |
| `amount` | `numeric(16,2)` | not null |
| `currency_code` | `character(3)` | not null |
| `contact_id` | `uuid` |  |
| `journal_id` | `uuid` | not null |
| `bank_account_id` | `uuid` |  |
| `entry_id` | `uuid` |  |
| `reference` | `text` |  |
| `memo` | `text` |  |
| `state` | `payment_state_t` | not null |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `exchange_rate` | `numeric(18,8)` | not null — Units of the payment currency for one unit of the company currency, as currency_rates states it. The ledger amount is the payment amount divided by it. 1 when the payment is in the company currency. |
| `client_ref` | `text` | A reference chosen by whoever recorded the payment, unique per company where given: the idempotency key of a creation. Not the bank's reference, which is `reference`. |

Constraints:

- `CHECK ((amount > (0)::numeric))`
- `CHECK (((client_ref IS NULL) OR ((client_ref = btrim(client_ref)) AND ((length(client_ref) >= 1) AND (length(client_ref) <= 200)))))`
- `CHECK ((exchange_rate > (0)::numeric))`
- `PRIMARY KEY (id)`

### `products`

What a document line is filled in from: code, name, unit, price, account and tax. Not stock: no quantity on hand and no valuation.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `code` | `text` | not null — The seller's own item identifier, EN 16931 BT-155. Unique in the company. |
| `name` | `text` | not null — Item name, EN 16931 BT-153, copied onto the line it fills in. |
| `description` | `text` | Item description, EN 16931 BT-154. |
| `kind` | `product_kind` | not null |
| `unit_code` | `text` | not null — Unit of measure, UN/ECE recommendation 20 (BT-130). C62 is "one". |
| `currency_code` | `character(3)` | not null |
| `sale_price` | `numeric(16,6)` | Suggested net unit price on a sale. A line may carry another. |
| `purchase_price` | `numeric(16,6)` |  |
| `sale_account_id` | `uuid` |  |
| `purchase_account_id` | `uuid` |  |
| `sale_tax_id` | `uuid` |  |
| `purchase_tax_id` | `uuid` |  |
| `active` | `boolean` | not null |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((length(btrim(code)) > 0))`
- `CHECK (((purchase_price IS NULL) OR (purchase_price >= (0)::numeric)))`
- `CHECK (((sale_price IS NULL) OR (sale_price >= (0)::numeric)))`
- `CHECK ((unit_code ~ '^[A-Z0-9]{1,3}$'::text))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, code)`

### `reconciliations`

One row per pairing of a debit with a credit. Full matching is the sum of partials.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `debit_line_id` | `uuid` | not null |
| `credit_line_id` | `uuid` | not null |
| `amount` | `numeric(16,2)` | not null |
| `matching_number` | `text` | not null |
| `matched_at` | `date` | not null |
| `created_at` | `timestamp with time zone` | not null |
| `fx_entry_id` | `uuid` | The entry that booked the realised exchange difference this matching revealed, or null. Written by reconcile() and read by unreconcile(), which reverses it. |
| `tax_transfer_entry_id` | `uuid` | Entry that moved the cash-basis tax this matching made due, when there was one. |

Constraints:

- `CHECK ((amount > (0)::numeric))`
- `CHECK ((debit_line_id <> credit_line_id))`
- `PRIMARY KEY (id)`
- `UNIQUE (debit_line_id, credit_line_id)`

### `role_capabilities`

What each preset holds. A role is never tested by a policy; it is resolved here into capabilities.

| Column | Type | Notes |
|---|---|---|
| `role` | `member_role` | not null |
| `capability` | `text` | not null |

Constraints:

- `PRIMARY KEY (role, capability)`

### `statement_line_rules`

How an account of a company reaches a line. Presentation maps by range of the legal chart; choosing an account to post to by prefix stays forbidden, and is a different question.

| Column | Type | Notes |
|---|---|---|
| `statement_code` | `text` | not null |
| `line_code` | `text` | not null |
| `sequence` | `integer` | not null — Order inside the line, and part of the key. Between two rules that both catch an account, the narrower one wins first, then this. |
| `rule_kind` | `text` | not null — account_code names one code; code_range and code_prefix compare the head of the code, so `40`..`41` takes 400000 and 411000 and stops at 42; account_type is what the generic framework is made of. |
| `code_from` | `text` |  |
| `code_to` | `text` |  |
| `account_type` | `account_type` |  |
| `balance_side` | `text` | not null — Which side of the account this line takes. `any` takes it whatever it holds; `debit` and `credit` split one account between two lines — a suspense account is a receivable when it is in debit and a payable when it is in credit. |

Constraints:

- `CHECK (
CASE rule_kind
    WHEN 'account_type'::text THEN ((account_type IS NOT NULL) AND (code_from IS NULL) AND (code_to IS NULL))
    WHEN 'code_range'::text THEN ((code_from IS NOT NULL) AND (code_to IS NOT NULL) AND (account_type IS NULL))
    ELSE ((code_from IS NOT NULL) AND (code_to IS NULL) AND (account_type IS NULL))
END)`
- `CHECK ((rule_kind = ANY (ARRAY['account_code'::text, 'code_range'::text, 'code_prefix'::text, 'account_type'::text])))`
- `CHECK ((balance_side = ANY (ARRAY['debit'::text, 'credit'::text, 'any'::text])))`
- `PRIMARY KEY (statement_code, line_code, sequence)`

### `statement_line_templates`

The lines of a statement, in the order it prints them, and the plus/minus lists a total is computed from.

| Column | Type | Notes |
|---|---|---|
| `statement_code` | `text` | not null |
| `code` | `text` | not null |
| `parent_code` | `text` | The line this one details, for a renderer that indents. Structure only: a parent that is a total says so with its plus list. |
| `name` | `text` | not null |
| `name_i18n` | `jsonb` | not null |
| `sequence` | `integer` | not null |
| `sign` | `smallint` | not null — Multiplies the debit-minus-credit balance so the line reads the way the scheme prints it: 1 on an asset or an expense, -1 on a liability, equity or income line. |
| `is_total` | `boolean` | not null |
| `plus_lines` | `text[]` | not null — Lines added into this total, by their code. Evaluated in `sequence` order, so a total may only name one computed before it. |
| `minus_lines` | `text[]` | not null |
| `xbrl_element` | `text` | What an XBRL filing writes for this line. The NBB CBSO taxonomy is dimensional, so the value is a fact key — a metric and its dimension members, `met:am1\|bas:m2` — and not an element name. Null where nothing is verified. |
| `legal_reference` | `text` |  |
| `source_key` | `text` | Key of the entry in country_packs.sources where this line's legal_reference can be read. Null where the pack names none. |

Constraints:

- `CHECK ((is_total OR ((plus_lines = '{}'::text[]) AND (minus_lines = '{}'::text[]))))`
- `CHECK ((sign = ANY (ARRAY[1, '-1'::integer])))`
- `PRIMARY KEY (statement_code, code)`

### `statement_templates`

Financial statements per framework, from packs/<cc>/statements.json and packs/generic/. Reference data: never copied into a company.

| Column | Type | Notes |
|---|---|---|
| `code` | `text` | not null — Immutable once published. A new version of a scheme is a new code with its own validity, the way a new VAT rate is a new tax code. |
| `country` | `character(2)` | Null on the generic framework, which reports by account type and fits any chart of any country. |
| `chart_code` | `text` | Null means every chart of the country. Filled when a statement only makes sense on one — a nonprofit scheme on a nonprofit chart. |
| `name` | `text` | not null |
| `name_i18n` | `jsonb` | not null |
| `kind` | `text` | not null — balance_sheet reads balances cumulative to the end of the period; income_statement and allocation read the movements of the period; cash_flow is declared and not yet produced. |
| `framework` | `text` |  |
| `valid_from` | `date` | not null |
| `valid_to` | `date` |  |
| `legal_reference` | `text` |  |
| `source_key` | `text` | Key of the entry in country_packs.sources where this statement's legal_reference can be read. Null where the pack names none. |

Constraints:

- `CHECK (((chart_code IS NULL) OR (country IS NOT NULL)))`
- `CHECK (((country IS NULL) OR (country ~ '^[A-Z]{2}$'::text)))`
- `CHECK ((kind = ANY (ARRAY['balance_sheet'::text, 'income_statement'::text, 'cash_flow'::text, 'allocation'::text])))`
- `CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))`
- `PRIMARY KEY (code)`

### `tax_filing_boxes`

The figures as they were filed, one row per box. Frozen at filing and never recomputed: this is what the administration holds.

| Column | Type | Notes |
|---|---|---|
| `filing_id` | `uuid` | not null |
| `box` | `text` | not null |
| `amount` | `numeric` | not null — The figure as it was filed, at the decimals of the company's currency or at the unit of the form where the form names a coarser one (tax_report_templates.rounding_unit). No scale on the column: a return in a currency without decimals freezes 1000000, not 1000000.00. |
| `kind` | `text` | not null — What this figure is on the form: the base of a rate, the tax on it, or a total the form computes. Part of the key, because a form is free to print a base and a tax on the same line and two of them have to be able to sit there. |

Constraints:

- `CHECK ((kind = ANY (ARRAY['base'::text, 'tax'::text, 'total'::text])))`
- `PRIMARY KEY (filing_id, box, kind)`

### `tax_filing_deposits`

One row per send of a declaration, with what came back: the deposit number, the outcome, the administration's own words, and the two files — what was sent and the receipt. A rejected declaration is sent again, so a declaration has as many deposits as it took.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `filing_id` | `uuid` | not null |
| `sequence` | `integer` | not null |
| `channel` | `filing_channel` | not null |
| `service` | `text` | The name of the transmission service, where one was used. Free text: the core records what was used and holds no list of what may be, which is what keeps it uncoupled from any provider. |
| `sent_at` | `timestamp with time zone` | not null |
| `sent_by` | `uuid` |  |
| `reference` | `text` |  |
| `outcome` | `tax_filing_state` |  |
| `outcome_at` | `timestamp with time zone` |  |
| `message` | `text` | What the administration answered, in its own words. Not summarised: a refusal is read to know what to change. |
| `sent_file_id` | `uuid` | The file that was sent, kept as an attachment of this declaration. Keeping it is what makes reopening a rejected declaration lossless — the core makes it possible and cannot impose it. |
| `acknowledgement_id` | `uuid` |  |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (((outcome IS NULL) OR (outcome = ANY (ARRAY['accepted'::tax_filing_state, 'rejected'::tax_filing_state, 'paid'::tax_filing_state]))))`
- `CHECK (((outcome IS NULL) = (outcome_at IS NULL)))`
- `PRIMARY KEY (id)`
- `UNIQUE (filing_id, sequence)`

### `tax_filings`

One row per declaration of a period: what was filed, when, under which reference, and in which state. The figures are in tax_filing_boxes and they are frozen — this table exists so that "what did we declare" is a question with an answer.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `report_code` | `text` | not null — The form, as the pack names it. A company may file the form of a country that is not its own, which is why this is a code and not a foreign key. |
| `period_start` | `date` | not null |
| `period_end` | `date` | not null |
| `state` | `tax_filing_state` | not null |
| `due_date` | `date` |  |
| `reference` | `text` | What the administration gave back — a deposit number, a receipt. Free text: every portal calls it something else. |
| `prepared_at` | `timestamp with time zone` | When the figures were last computed into this filing. A declaration with no lines is not an unprepared one: a period where nothing happened is filed nil, and that is an obligation rather than an omission. |
| `filed_at` | `timestamp with time zone` |  |
| `filed_by` | `uuid` |  |
| `supersedes_id` | `uuid` | The filing this corrective replaces, which moves to superseded. Nothing is ever overwritten: a declaration that went out stays as it went out. |
| `notes` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `settlement_entry_id` | `uuid` | The entry that cleared the tax accounts of this period into the debt towards the administration. One per declaration, enforced by a unique index: replaying the settlement is refused rather than doubling the debt. |
| `credit_treatment` | `tax_credit_treatment` | Set when the period ended in a credit, and only then: carried forward to the next declaration, or claimed back. |

Constraints:

- `CHECK ((((state = ANY (ARRAY['draft'::tax_filing_state, 'ready'::tax_filing_state])) = (filed_at IS NULL)) OR (state = 'superseded'::tax_filing_state)))`
- `CHECK ((period_start <= period_end))`
- `PRIMARY KEY (id)`

### `tax_posting_templates`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `tax_template_id` | `uuid` | not null |
| `document_kind` | `tax_document_kind` | not null |
| `posting_type` | `tax_posting_type` | not null |
| `factor_percent` | `numeric(7,3)` | not null |
| `account_code` | `text` |  |
| `declaration_box` | `text` |  |
| `box_factor_percent` | `numeric(7,3)` | not null |
| `sequence` | `integer` | not null |
| `report_code` | `text` | Declaration form the box belongs to (BE-VAT-PERIODIC, FR-CA3, CA-GST34…). Null means the periodic return of the country. |
| `declaration_boxes` | `text[]` | Every box this one amount is printed in, from packs/<cc>/taxes.json. Almost always the single box declaration_box names, which is the first of the list; several where the form prints one figure in boxes that are not sums of one another. A box that is a sum stays a total and is never named here. |

Constraints:

- `CHECK (
CASE posting_type
    WHEN 'tax'::tax_posting_type THEN (account_code IS NOT NULL)
    ELSE (account_code IS NULL)
END)`
- `CHECK (
CASE
    WHEN (declaration_box IS NULL) THEN (declaration_boxes IS NULL)
    ELSE ((declaration_boxes IS NOT NULL) AND (cardinality(declaration_boxes) >= 1) AND (declaration_boxes[1] = declaration_box))
END)`
- `PRIMARY KEY (id)`

### `tax_postings`

Where a tax lands: ledger account and VAT-return box, per tax and per document kind.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `tax_id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `document_kind` | `tax_document_kind` | not null |
| `posting_type` | `tax_posting_type` | not null |
| `factor_percent` | `numeric(7,3)` | not null — Accounting share. Positive keeps the base side, negative flips it (self-assessment). |
| `account_id` | `uuid` |  |
| `declaration_box` | `text` |  |
| `box_factor_percent` | `numeric(7,3)` | not null — Declaration share. Separate from factor_percent so a box always gets the sign the form expects. |
| `sequence` | `integer` | not null |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `report_code` | `text` | Declaration form the box belongs to. Copied from the template, and read by vat_return(company, from, to, report_code) to pick out the boxes of one form where a country files more than one. |
| `declaration_boxes` | `text[]` | Every box this one amount is printed in, copied from the template. The first is declaration_box, which is what the posting is known by; vat_return() sums the line into each box of the list. |

Constraints:

- `CHECK (
CASE posting_type
    WHEN 'tax'::tax_posting_type THEN (account_id IS NOT NULL)
    ELSE (account_id IS NULL)
END)`
- `CHECK (
CASE
    WHEN (declaration_box IS NULL) THEN (declaration_boxes IS NULL)
    ELSE ((declaration_boxes IS NOT NULL) AND (cardinality(declaration_boxes) >= 1) AND (declaration_boxes[1] = declaration_box))
END)`
- `PRIMARY KEY (id)`

### `tax_report_box_templates`

The boxes of a declaration form, and the plus/minus lists a total is computed from. Read by vat_return().

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `report_code` | `text` | not null |
| `box` | `text` | not null |
| `kind` | `text` | not null — base, tax or total. Not an enum: vat_return() has always answered in text, and a form that invents a fourth kind is a core change either way. |
| `name` | `text` | not null |
| `name_i18n` | `jsonb` | not null |
| `sequence` | `integer` | not null |
| `plus_boxes` | `text[]` | not null — Boxes added into this total. A bare code names the box whatever its kind, "08:tax" names one kind — the French CA3 carries both on one line. |
| `minus_boxes` | `text[]` | not null |
| `floor_zero` | `boolean` | not null — A negative total is reported as zero, the other side of the pair carrying it: Belgian 71/72, French 25/28. |
| `hidden` | `boolean` | not null — An intermediate total the form does not print. vat_return() returns it with this flag rather than dropping it, so a caller can check a total it cannot see. |
| `xml_element` | `text` |  |
| `legal_reference` | `text` |  |
| `valid_from` | `date` | Null means the validity of the form itself. Filled only when a box appears or disappears inside one version of a form. |
| `valid_to` | `date` |  |
| `source_key` | `text` | Key of the entry in country_packs.sources where this box's legal_reference can be read. Null where the pack names none. |
| `rate` | `numeric` | Percentage this box applies to the box named by rate_of_box. The one arithmetic a declaration form writes out; not an expression, and never a second way to say plus. |
| `rate_of_box` | `text` | The box the rate is applied to, bare or qualified with its kind (`12:total`), resolved the way a plus reference is. |
| `print_sequence` | `integer` | Where the administration prints this box, when that is not where the pack declares it. Null means the same as sequence: a form prints a subtotal above what it adds up, and the evaluation order is the dependencies and never this. |

Constraints:

- `CHECK (((kind = 'total'::text) OR ((plus_boxes = '{}'::text[]) AND (minus_boxes = '{}'::text[]))))`
- `CHECK ((kind = ANY (ARRAY['base'::text, 'tax'::text, 'total'::text])))`
- `CHECK (((rate IS NULL) OR (kind = 'total'::text)))`
- `CHECK (((rate_of_box IS NULL) OR (split_part(rate_of_box, ':'::text, 1) <> box)))`
- `CHECK (((rate IS NULL) = (rate_of_box IS NULL)))`
- `CHECK (((rate IS NULL) OR ((plus_boxes = '{}'::text[]) AND (minus_boxes = '{}'::text[]))))`
- `CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))`
- `PRIMARY KEY (country, report_code, box, kind)`

### `tax_report_templates`

Declaration forms per country, from packs/<cc>/tax_report.json. Reference data: a form is not customisable, so it is never copied into a company.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `code` | `text` | not null — BE-VAT-PERIODIC, FR-CA3. Immutable once published; a new version of a form is a new code with its own validity. |
| `name` | `text` | not null |
| `name_i18n` | `jsonb` | not null — Label by language. The pack format has no key for it yet, so it stays empty until i18n/ carries one. |
| `periods` | `declaration_period[]` | not null — Cadences this form is filed on, from packs/<cc>/tax_report.json. A list because one set of boxes may be filed monthly, quarterly or annually depending on turnover. No default: a pack that names none is refused by `ekwo pack check`. |
| `valid_from` | `date` | not null |
| `valid_to` | `date` |  |
| `legal_reference` | `text` |  |
| `is_periodic_return` | `boolean` | not null — True for the return a company files every month or quarter. vat_return() falls back to the one of the company's fiscal country. |
| `period_default` | `declaration_period` | Cadence this form is filed on unless the company has asked the administration for another, from packs/<cc>/tax_report.json. Null where the law makes the cadence depend on a fact about the company — turnover — because proposing one of several lawful answers there would be choosing a filing deadline for somebody the pack knows nothing about. Set where the law gives one answer to everybody, whatever else the form accepts. Read at install; never read by the return. |
| `deadline_rule` | `filing_deadline_rule` | How the filing date follows the end of the period. depends_on_taxpayer where the law assigns the day per filer and the pack cites the text; null where the pack says nothing. |
| `deadline_day` | `smallint` | Day of the month that follows the period. Filled exactly when the rule is day_of_month_after_period. |
| `deadline_plus_days` | `smallint` | Days added to the date the rule produces — the seven the United Kingdom grants for filing online, while the regulation still says the last day of the month. |
| `deadline_reference` | `text` | The text that sets the date, and the conditions on it: an extension that does not reach every filer is said here. |
| `deadline_source_key` | `text` | Key of the register entry that reference is in. |
| `file_format` | `text` | The file this form is deposited as, by the name of the brick that writes it — vat-consignment for the Belgian XML Intervat takes. Named after the format and never after the country. Null where no brick writes the form, which is most of them: filing by hand on a portal is how it is done until one exists. |
| `rounding_unit` | `numeric` | The unit the figures of this form are filed in, where it is coarser than the currency: 1 for a form filed in whole dollars over a ledger kept in cents. A power of ten. Null is the currency's own decimals, which is every form that says nothing. Read by filing_rounding() when a declaration is frozen; never by vat_return(), which answers the exact figures. |
| `rounding_reference` | `text` | The text that sets the unit — the instruction printed on the form, or the rule behind it. Filled exactly when rounding_unit is. |
| `rounding_source_key` | `text` | Key of the register entry that reference is in. |

Constraints:

- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `CHECK (
CASE deadline_rule
    WHEN 'day_of_month_after_period'::filing_deadline_rule THEN ((deadline_day >= 1) AND (deadline_day <= 31))
    WHEN 'last_day_of_month_after_period'::filing_deadline_rule THEN (deadline_day IS NULL)
    WHEN 'depends_on_taxpayer'::filing_deadline_rule THEN ((deadline_day IS NULL) AND (deadline_plus_days IS NULL) AND (deadline_reference IS NOT NULL))
    ELSE ((deadline_day IS NULL) AND (deadline_plus_days IS NULL) AND (deadline_reference IS NULL) AND (deadline_source_key IS NULL))
END)`
- `CHECK (((period_default IS NULL) OR (period_default = ANY (periods))))`
- `CHECK ((cardinality(periods) >= 1))`
- `CHECK ((((rounding_unit IS NULL) = (rounding_reference IS NULL)) AND ((rounding_source_key IS NULL) OR (rounding_reference IS NOT NULL))))`
- `CHECK (((rounding_unit IS NULL) OR ((rounding_unit > (0)::numeric) AND (rounding_unit = power((10)::numeric, round(log(rounding_unit)))))))`
- `CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))`
- `PRIMARY KEY (country, code)`

### `tax_templates`

Reference taxes per country, with their period of validity.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `country` | `character(2)` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `description` | `text` |  |
| `amount_type` | `tax_amount_type` | not null |
| `amount` | `numeric(12,4)` | not null |
| `applies_to` | `tax_scope` | not null |
| `treatment` | `tax_treatment` | not null |
| `valid_from` | `date` | not null |
| `valid_to` | `date` |  |
| `legal_reference` | `text` |  |
| `vat_category` | `text` | EN 16931 BT-118 / BT-151 category code the pack declares for this tax, as UNCL5305 writes it. |
| `exemption_code` | `text` |  |
| `sequence` | `integer` | not null |
| `tax_kind` | `tax_kind` | not null — vat, gst, sales_tax, withholding, other. A label for the reports, never an input to the calculation. |
| `recoverable` | `boolean` | not null — False when the buyer never gets the tax back: American sales tax, Canadian PST. Where it lands is said by a tax_on_base posting. |
| `jurisdiction` | `text` | ISO 3166-2 with the country prefix — CA-QC, US-CA — for a tax levied by a state. Null in Europe. |
| `price_include` | `boolean` | not null — The unit price of a line carrying this tax is the gross price. Compiled from the pack and copied onto the tax a company installs. |
| `cash_basis` | `boolean` | not null — The tax falls due when the invoice is paid rather than when it is issued, which is how France taxes services. post_document() books it on the transition account below and on no declaration box; reconcile() moves the settled share to the account and the box it is declared on. |
| `cash_basis_transition_account_code` | `text` | Account the tax waits on between the invoice and its payment, by code in the chart of this country. Only read when cash_basis is true. |
| `name_i18n` | `jsonb` | not null — Label by language, from packs/<cc>/i18n/. A translation of the same tax, never a different rate or a different rule. |
| `source_key` | `text` | Key of the entry in country_packs.sources where this tax's legal_reference can be read. Null where the pack names none. |
| `conditions` | `tax_condition[]` | not null — What this tax turns on that the ledger cannot see, from a closed vocabulary: buyer_certificate, buyer_status, transport_evidence, seller_threshold, supply_nature. It says what the question is, never how to answer it — there is no value, no operator and no expression here, and the article that sets a threshold or prescribes a certificate is in legal_reference. Written by the generated seed; read by nothing in the ledger. |
| `applies_seller_territory` | `text` | Territory the seller has to be in for this tax to apply, from `applies_when.seller_in` of the pack. Null means the tax says nothing about the seller. |
| `applies_buyer_territory` | `text` | Territory the buyer has to be in, from `applies_when.buyer_in`. Null means the tax says nothing about the buyer. |
| `applies_supply_territory` | `text` | Territory the supply has to take place in, from `applies_when.supply_in`. A sale is taxed where the goods are delivered, which is why this is not the same column as the buyer's. |
| `applies_supply_vs_seller` | `territory_relation` | Whether the supply has to lie inside the seller's territory (same) or outside it (other), from `applies_when.supply_vs_seller` of the pack. Null means the tax says nothing about it. |

Constraints:

- `CHECK (((NOT price_include) OR (amount_type = 'percent'::tax_amount_type)))`
- `CHECK (((vat_category IS NULL) OR (vat_category ~ '^[A-Z]{1,2}$'::text)))`
- `PRIMARY KEY (id)`
- `UNIQUE (country, code)`

### `taxes`

VAT and similar taxes, with temporal validity and a legal reference.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `description` | `text` |  |
| `amount_type` | `tax_amount_type` | not null |
| `amount` | `numeric(12,4)` | not null — Percentage (21.0000) or fixed amount, per amount_type. |
| `applies_to` | `tax_scope` | not null |
| `treatment` | `tax_treatment` | not null |
| `country` | `character(2)` |  |
| `valid_from` | `date` | not null |
| `valid_to` | `date` |  |
| `legal_reference` | `text` |  |
| `vat_category` | `text` | EN 16931 BT-118 / BT-151 category code, as UNCL5305 writes it: S, Z, E, AE, K, G, O, L, M. One or two capitals, never padded. |
| `exemption_code` | `text` |  |
| `price_include` | `boolean` | not null — The unit price of a line carrying this tax is the gross price: the engine takes the tax out of it per group rather than adding it on top. Only a percentage tax may say so. |
| `sequence` | `integer` | not null |
| `active` | `boolean` | not null |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |
| `tax_kind` | `tax_kind` | not null — vat, gst, sales_tax, withholding, other. A label for the reports, never an input to the calculation. |
| `recoverable` | `boolean` | not null — False when the buyer never gets the tax back. The ledger consequence is a tax_on_base posting, not this column. |
| `jurisdiction` | `text` | ISO 3166-2 with the country prefix, for a tax levied by a state. Null in Europe. |
| `cash_basis` | `boolean` | not null — The tax falls due when the invoice is paid rather than when it is issued. The share that has been settled is what reaches the declaration. |
| `cash_basis_transition_account_id` | `uuid` | Account the tax waits on between the invoice and its payment. Only read when cash_basis is true. |
| `name_i18n` | `jsonb` | not null — Label by language, copied from the template at install. `name` holds the language the company chose. |
| `applies_seller_territory` | `text` | Territory the seller has to be in for this tax to apply. post_document() refuses a document that contradicts it; it never chooses a tax for anybody. |
| `applies_buyer_territory` | `text` | Territory the buyer has to be in for this tax to apply. |
| `applies_supply_territory` | `text` | Territory the supply has to take place in for this tax to apply. |
| `applies_supply_vs_seller` | `territory_relation` | Whether the supply has to lie inside the seller's territory (same) or outside it (other). Read at the level of the seller: post_document() refuses a document whose seller is known only by a country, and one that contradicts the relation. |

Constraints:

- `CHECK (((country IS NULL) OR (country ~ '^[A-Z]{2}$'::text)))`
- `CHECK (((NOT price_include) OR (amount_type = 'percent'::tax_amount_type)))`
- `CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))`
- `CHECK (((vat_category IS NULL) OR (vat_category ~ '^[A-Z]{1,2}$'::text)))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, code)`

### `territories`

The territories of the common system of value added tax: the Member States with the day each became bound, the United Kingdom with the day it stopped being, Northern Ireland, and the territories articles 6 and 7 of Directive 2006/112/EC take out of the system or put into it. Framework data filled by the release, like currencies — no company owns a row and no country pack writes one. A territory this table does not carry is outside the common system, which is the answer for every third country.

| Column | Type | Notes |
|---|---|---|
| `code` | `text` | not null — ISO 3166-1 alpha-2 where the territory has one, ISO 3166-2 where only a subdivision code exists, XI for Northern Ireland, and a name of this table for the five territories of article 6 that no register codes. code_source says which. |
| `code_source` | `territory_code_source` | not null |
| `name` | `text` | not null |
| `parent_code` | `text` | The Member State this territory hangs off: the one it is part of, excluded from, or treated as part of. |
| `eu_vat_scope` | `eu_vat_scope` | not null — How much of the common system applied during the window below: all of it, supplies of goods only, or none. |
| `eu_vat_from` | `date` | First day the common system of VAT reached this territory. Null where it never did. |
| `eu_vat_to` | `date` | Last day it did. Null while it still does. A VAT date, not a membership one: the United Kingdom left the Union on 31 January 2020 and left the common system on 31 December 2020. |
| `vat_prefix` | `character(2)` | The prefix this territory's VAT identification numbers carry, when it differs from the code: EL for Greece, FR for Monaco, GB for the Isle of Man. Null when the two are the same. |
| `legal_reference` | `text` | not null — The text that puts this territory where it is — an accession treaty, an article of Directive 2006/112/EC, the Withdrawal Agreement. |
| `outside_parent_tax` | `boolean` | not null — True where the tax of the parent territory does not apply here, although the territory is part of it: the Canary Islands, Ceuta and Melilla for Spanish VAT, Büsingen and Heligoland for German VAT, Livigno and Campione d'Italia for Italian VAT. Read by territory_within_for_tax(), so a tax conditioned on the parent does not reach a party or a supply here. Independent from eu_vat_scope, which says how far the Union's common system reaches and is read by ec_sales_list(): Åland is outside the second and inside Finnish VAT. Set by the seed of territories with the text that excludes the territory in legal_reference, never by a pack. |

Constraints:

- `CHECK ((code ~ '^[A-Z]{2}(-[A-Z0-9]{1,12})?$'::text))`
- `CHECK (((parent_code IS NULL) OR (parent_code <> code)))`
- `CHECK (((NOT outside_parent_tax) OR (parent_code IS NOT NULL)))`
- `CHECK (((vat_prefix IS NULL) OR (vat_prefix ~ '^[A-Z]{2}$'::text)))`
- `CHECK (((eu_vat_scope = 'none'::eu_vat_scope) = (eu_vat_from IS NULL)))`
- `CHECK (((eu_vat_to IS NULL) OR ((eu_vat_from IS NOT NULL) AND (eu_vat_from <= eu_vat_to))))`
- `PRIMARY KEY (code)`

### `user_preferences`

What one person prefers, across every company they are a member of. Every column is nullable and none has a default: null means "take the company's answer, then the pack's".

| Column | Type | Notes |
|---|---|---|
| `user_id` | `uuid` | not null |
| `preferred_company_id` | `uuid` | The company an interface opens on. Cleared rather than kept when that company is deleted. |
| `language` | `text` | Language this person reads labels in. First in the list preferred_languages() builds. |
| `timezone` | `text` |  |
| `date_display_format` | `text` |  |
| `number_display_format` | `text` |  |
| `theme` | `text` | A client's business. The core stores it and interprets nothing. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (((language IS NULL) OR (language ~ '^[a-z]{2}(-[A-Za-z0-9]{2,8})?$'::text)))`
- `PRIMARY KEY (user_id)`

## Functions

| Function | Purpose |
|---|---|
| `accept_invitation(p_token text)` | Turns an invitation into a membership for the signed-in user, whose address has to be the one invited. Single use, and refused once expired. |
| `account_id_by_code(p_company_id uuid, p_code text)` | Account of a company by its code, or NULL. |
| `accounts_guard_frozen()` | Refuses a change of code or of account_type on an account that carries ledger lines, is named by a tax posting or plays a company role. The label, the translations, the parent, reconcilable, deprecated and pinned stay editable. |
| `accounts_in_use(p_company_id uuid, p_from date, p_to date)` | The accounts of a company that are in use: moved by a posted entry in the period — ever, when no period is given — or referenced by the configuration of the company — a role default, a contact override, a journal, a tax posting, a cash-basis transition, a bank account, a product — or held by a module the company has enabled, or pinned. Deprecated accounts are left out. A configuration reference is not dated; only the movement is. This is a reading: nothing here restricts what may be booked. |
| `aged_balance(p_company_id uuid, p_at date, p_group text)` | Ageing of what is still open, read from the ledger and from the matching, written at the decimals of the company's currency. Two groups, receivable and payable; anything else is refused by name. |
| `amount_text_format(p_rounding money_rounding)` | The to_char mask an amount of this currency is written with. Two decimals for the euro, none for the yen, three for the dinar. |
| `assert_may_export_company(p_company_id uuid)` | The two conditions of leaving: company.export on the company, and a caller that row level security applies to. Invoker, so `current_user` is the role that asked. |
| `assert_period_open(p_company_id uuid, p_date date, p_is_tax boolean)` | Raises when a date is protected by a lock date or a closed fiscal year. |
| `audit_changes()` | The generic audit trigger. One jsonb argument names the company column, the natural key, the columns to redact and the acts an insert or a delete stands for. |
| `audit_entry_posting()` | Records that an entry was posted, cancelled, or posted as the reversal of another. The lines themselves are not audited: a posted entry is immutable and is corrected by a reversal. |
| `audit_log_is_append_only()` | Refuses every update and every delete on audit_log, table owner included. purge_audit_log() sets ekwo.audit_purge for its own transaction, which is the one exception. |
| `audit_record(p_company_id uuid, p_table text, p_record_id uuid, p_record_key text, p_operation audit_operation, p_action text, p_old jsonb, p_new jsonb)` | Writes one row of the audit trail. Called by the triggers of this schema and by the functions that perform an act; never by a client. |
| `audit_state_change()` | Records the act a state column stands for — a document posted, a payment booked, a year closed — with the fields that identify the row and never the whole of it. |
| `auto_settle(p_company_id uuid, p_from date, p_to date, p_apply boolean)` | Walks the pending statement lines of a period and settles the ones a single piece of evidence identifies — a reference, or an exact amount with one candidate. Everything else comes back with the reason it was left: a combination, a partial payment, an internal transfer, nothing open that fits, or a refusal the database made, quoted. With p_apply false it changes nothing and says what it would do. |
| `available_statements(p_company_id uuid, p_at date)` | Statements a company may ask for: those of its country and chart, plus the generic framework. `is_default` marks the ones its chart declares. |
| `bank_statement_movement(p_statement_id uuid)` | The sum of the lines a statement lists or holds, each counted once. What balance_end_computed adds to balance_start. |
| `can_write_company(p_company_id uuid)` | Whether the current caller may write the books of a company. One capability, not a role, and false rather than NULL for a stranger. |
| `cancel_document(p_document_id uuid, p_date date)` | Undoes a posted invoice: writes its credit note — the same lines, taxes, accounts, contact, currency and rate — naming it in reversed_document_id, posts it through post_document(), matches the two entries and marks the invoice cancelled. Returns the credit note. Dated on the invoice's booking day while that period is open, and otherwise refused until a date is given (reversal_date_needed). Refused for a document that is not a posted invoice, is already cancelled or credited, or is settled in part or in full (unreconcile() first). |
| `catch_up_journal_sequence(p_journal_id uuid, p_date date, p_number text)` | Advances the counter of a journal to the counter inside a number that was written by hand, so the next automatic number continues the series. Definer, because nobody writes `journal_sequences` directly — and guarded like `next_entry_number()`: the installer, or entries.post on the company of the journal. |
| `claim_instance_admin(p_user_id uuid)` | Makes a user an instance administrator. The first claim is open; afterwards only an administrator may appoint one. |
| `close_fiscal_year(p_fiscal_year_id uuid)` | Closes a fiscal year: the result leaves the income statement the way the country model says, and every income and expense account goes back to zero. The entry that moves the result is `appropriation`, the one that empties the income statement is `closing`. The balance sheet needs no entry — the reports read the ledger from the beginning. The allocation decided by a meeting is never part of it. |
| `commercial_entity(p_contact_id uuid)` | Root of the contact parent chain; the entity a document is booked against. |
| `companies_default_capital_currency()` | A capital stated with no currency is stated in the company's own. The alternative was a literal in the schema, which is one country's answer given to every country. |
| `companies_vat_period_is_a_filing_period()` | Records a write to the deprecated companies.vat_period as what it is: how often this company files its country's periodic return. Everything written before this migration named that column and nothing else, and this is what keeps such a writer correct without it learning a table. |
| `companies_with_capability(p_capability text)` | The companies in which the current caller may do one named thing — the question has_capability() answers, asked once for all of them. It is what a row level security policy compares company_id against, inside a sub-select, so that the answer is worked out once per statement instead of once per row. |
| `company_archive_predicate(p_schema text, p_table text, p_alias text)` | The SQL condition that keeps the rows of one company in one table, with the company as `$1`. One place, read by the export, by the count and by the checks of an import. |
| `company_archive_row_count(p_company_id uuid, p_table text)` | How many rows one table holds for one company, whatever the caller may read of them. Definer, guarded by company.export, and it answers a number and nothing else: it is what lets an export notice that row level security handed it less than there is. |
| `company_archive_tables()` | The registry of the socle and what every installed module answers through `<schema>.archive_tables()`, as one list. Modules load after the socle. |
| `company_archive_unclassified()` | What stands between this installation and an honest archive: a table of a company nobody classified, a classification of a table that is gone, an exported table with no way to a company. Empty is the only answer an export accepts. |
| `company_filing_periods_mirror()` | Writes companies.vat_period from the row that records how often this company files its country's periodic return. The column is a mirror and never a second decision: it is written here, from the table, and only when the two differ. |
| `company_filing_periods_names_a_form()` | Refuses a filing cadence recorded against a form this installation does not carry. Raise, do not warn: a row nothing can resolve is a cadence nobody files on, and the guards that read it would simply never fire. |
| `company_role(p_company_id uuid)` | Role of the current user on a company, or NULL when they are not a member. |
| `company_scoped_tables()` | Every table that belongs to a company, read from the catalogue: it carries `company_id`, or a foreign key leads from it to `companies`, directly or through another such table. |
| `confirm_contact(p_transaction_id uuid, p_contact_id uuid)` | Attributes a statement line to a contact and learns from it: the account and the name as this bank writes them become motifs, and every motif that had named somebody else is charged a use without a success. Knowing who the money came from is not knowing what it pays — this function never touches a document and never reconciles anything. |
| `contacts_language_reaches_drafts()` | A customer who changes language changes the drafts addressed to them, and nothing else: a posted document keeps the language it was sent in. |
| `create_api_key(p_company_id uuid, p_name text, p_capabilities jsonb, p_expires_at timestamp with time zone)` | Issues a machine key on one company and returns the secret once. Only the hash is stored, and no capability can be put on a key that the person issuing it does not hold. |
| `create_company(p_name text, p_country character, p_currency_code character, p_language character, p_chart_code text, p_fiscal_year integer, p_fiscal_year_start date, p_owner_user_id uuid)` | Creates a company, makes the caller its first member, copies the country pack into it and opens its first financial year on the month that pack declares. An instance-level act, like the policy on companies. |
| `currency_of_bank_account()` | Fills a statement line's currency_code from its bank account, and from the company as a last resort. |
| `currency_of_company()` | Fills currency_code from the company when the caller named none. The one place the question is answered for a table that belongs to a company. |
| `currency_unit(p_rounding money_rounding)` | The smallest amount a currency has: a cent in the euro, a yen in the yen. A tolerance is written as a fraction of this rather than as a fraction of a cent. |
| `current_api_key()` | The key presented in this transaction, or nothing. What a client reads back to know what it may do. |
| `declaration_period_months(p_period declaration_period)` | How many months a cadence lasts: 1, 2, 3, 4, 6 or 12. Every function that works out a period reads this number rather than a list of names, so a cadence added to the type is a line here and nowhere else. |
| `declaration_period_of(p_from date, p_to date)` | The cadence a pair of dates is a whole one of — month, bimonth, quarter, four_month, half_year, year, each anchored on 1 January — or null when the two dates are not a filing period at all. |
| `declaration_period_start(p_period declaration_period, p_day date)` | The first day of the period of this cadence a day falls in, anchored on 1 January: a bimonth starts in January, March, May, July, September or November, a four-month period in January, May or September, a half-year in January or July. |
| `default_statement_code(p_company_id uuid, p_kind text, p_at date)` | The statement of a kind this company reports on: one its chart declares, else one of its country, else the generic framework. Null when it has none of that kind. The one place that choice is made, so two readers cannot disagree about which balance sheet is the company's. |
| `disable_module(p_company_id uuid, p_code text)` | Disables a module on a company, unless the module says it still holds data — `<schema>.can_disable(company)` returning a sentence refuses, returning null allows. Nothing the module wrote is deleted. Needs company.write. |
| `document_amount_paid(p_document_id uuid)` | What a document has been settled by: the matched amounts on the third-party lines of its entry, in the document's currency. The one definition — documents_refresh_amount_paid() writes it and documents_guard_posted() accepts no other figure. |
| `document_lines_amount_untaxed()` | Derives a line's amounts from its quantity, price and discount, rounded once at the decimals of the document's currency: the net, the gross where the price includes the tax, and the snapshot of whether it does. |
| `document_lines_guard_posted()` | Once a document has left draft, its lines are the lines that were issued: no insert, no delete, no column changed. Refuses document_posted, by name, to everybody. |
| `document_lines_refresh_totals()` | After a line of a draft moves: shares out the base of every tax group quoted with its tax in it, then refreshes the three totals of the document. A document that is no longer a draft keeps the totals it was posted, or loaded, with. |
| `document_lines_snapshot_tax()` | Writes BT-151 and BT-152 on a line from its tax for as long as the document is a draft. Once it is not, document_lines_guard_posted() refuses any change to the line, these two columns included. |
| `document_share_refusal(p_document documents)` | Why this document may not be shared, or null when it may. Sales only, never cancelled, never an unposted invoice, always numbered. |
| `document_territory(p_document_id uuid, p_party text)` | The territory of one party to a document: seller, buyer or supply. The seller is the company on a sale and the contact on a purchase, each resolving to its own territory_code and failing that to its country. The supply is the document's supply_territory_code, failing that its delivery_country (BG-15), failing that the buyer's territory. Null where none of those was ever recorded. |
| `documents_allocate_included_tax(p_document_id uuid)` | Turns the gross of every tax group quoted with the tax in it into a base: the tax rounded once on the group (BR-CO-14), the base the gross less that tax, shared over the lines in proportion to their gross with the remainder on the last. Refuses a group that is half inclusive, by name. |
| `documents_default_payee_iban()` | A sales document with no payee IBAN takes the company's default bank account. A purchase document never does: the payee there is somebody else. |
| `documents_guard_language()` | Fills documents.language from the customer, then the company, then the country pack when a document is created, keeps a draft in step with the customer it is addressed to, and refuses document_language_frozen on anything that is no longer a draft. |
| `documents_guard_posted()` | Once a document has left draft: it is not deleted, no column moves but the closed list of what happens to a document after it is issued — amount_paid (to the figure the matching gives, and no other), payment_state, sent_at, peppol_status, peppol_message_id — and its state has two ways out. Posted to cancelled, taken by cancel_document(): held to a posted credit note of the matching type that names it, carries its total and settles it in full, for a caller holding documents.post (document_cancelled_by_hand otherwise). Posted to draft, taken by unpost_document(): held to the row it records in document_unpostings for this document and its entry in the same transaction, with nothing moving but the state, the entry and what posting derived. Refuses document_posted, by name, to everybody else. Becoming posted is held to what post_document() writes — a posted entry built for this document, booked on its day, that gave it its number — document_posted_by_hand otherwise; and nobody inserts a document that is already posted (document_born_posted). |
| `documents_refresh_amount_paid(p_document_id uuid)` | Recomputes what a document has been settled by, from the matched amounts on its third-party lines. |
| `documents_refresh_payment_state()` | Derives payment_state from amount_paid against amount_total: not_paid, partially_paid, paid, overpaid — and reversed for a document cancelled after it was posted and settled in full by its credit note. Never keyed. |
| `ec_sales_list(p_company_id uuid, p_from date, p_to date, p_report_code text)` | The recapitulative statement of intra-Community supplies for a period: one line per customer VAT identification number and per nature — goods, services, and whatever the treatment vocabulary gains next — summed from the posted ledger in the company's currency, credit notes deducted. The country of a line is the prefix the customer's numbers carry, read from `territories`, so a Greek customer is listed under EL. A supply that cannot be declared comes back with the reason in `issue` rather than being left out. Name the form in p_report_code to have the period checked against the cadence this company files **that statement** on, which is not the cadence of its periodic return in any country read so far; name none and nothing is refused. A supply is a base line of the tax: a line a `tax_on_base` posting wrote is a cost and is left out. No country rule lives in this function. |
| `ekwo_schema_version()` | Schema version of the installed release. Bumped by a migration, never by hand. |
| `enable_module(p_company_id uuid, p_code text, p_settings jsonb)` | Enables a module on a company, and updates its settings when it is already enabled. Needs company.write, checked here because the table has no write policy. |
| `entries_guard_kind()` | Keeps entries.kind on `normal` outside the three functions that open and close a year. A label any client may set is a label a statement cannot be built on. |
| `entries_guard_module()` | Keeps the module tag of an entry honest: a module the company holds, never posted on insert, never moved afterwards. |
| `entries_guard_posted()` | Once an entry has left draft: its state does not change and no column moves (entry_posted); it is not deleted, but for the entry of a document unpost_document() has put back to draft, recorded in document_unpostings in the same transaction and pointed at by no document any more; nobody inserts one that is already posted (entry_born_posted). Becoming posted is held to what post_entry() produces, read on the row and in the counter — an instant it was posted at, no financial year but the one its date falls in, at least one line, an open period, and, where the country numbers without a hole and the caller does not hold entries.import, the number the counter of its journal has just delivered: entry_posted_by_hand otherwise. |
| `entries_refresh_totals()` | Keeps the totals of a draft entry in step with its lines. A posted entry keeps the totals it was posted, or loaded, with. |
| `entry_lines_guard_posted()` | Once an entry has left draft, its lines are the lines that were posted: no insert, no delete, and no column changed but the two the matching writes, matching_number and matched_amount. Refuses entry_posted, by name, to everybody. |
| `eu_vat_scope_of(p_code text, p_on date)` | How much of the common system of VAT applied to a territory on a day: all of it, supplies of goods only, or none. A territory this table does not carry answers none, which is the right answer for every third country. |
| `evaluate_totals(p_values jsonb, p_formulas jsonb, p_rounding money_rounding, p_keep_zero boolean)` | Works out the totals of a declaration form or of a financial statement — a plus/minus list, or a rate applied to one other key — in the order they depend on each other. The one place that calculation lives: vat_return() and financial_statement() both call it. |
| `export_company(p_company_id uuid)` | The whole archive as one document, read in one snapshot: `manifest`, and `tables` keyed by table name. It is what `import_company()` takes, and it writes `company_exported` on the audit trail. A large company is better read table by table, which is what the CLI does; this is the same rows in one answer. |
| `export_company_manifest(p_company_id uuid)` | What an archive of this company is: the format and its version, the socle, the packs and the modules an installation needs to take it in, every table with its row count and the sha256 of its rows, the tables left behind with the reason, and the list of the files the attachments point at — which the archive does not carry. |
| `export_company_table(p_company_id uuid, p_table text)` | The rows of one table for one company, one JSON object each, in primary key order: decimals as text, timestamps in UTC. Runs as its caller, needs company.export, refuses when the caller may read fewer rows than the table holds, and refuses while any table of a company is unclassified. Stable, so it reads the snapshot of the statement that calls it: called table after table, it needs a repeatable read transaction around the calls for the tables to agree with each other and with the manifest — which is what the CLI opens — or use export_company(), which is one statement. |
| `export_company_tables(p_company_id uuid)` | Every exported table of one company as one object, keyed by table name. The `tables` half of export_company(). |
| `fec_lines(p_company_id uuid, p_from date, p_to date)` | The eighteen columns of the French FEC for a period: the opening balances of the financial year first, computed and never posted, then its movements in chronological order. The entries the close wrote are left out — the file carries the income statement in its ordinary lines, and the result reaches the balance sheet in the opening lines of the year that follows. |
| `file_filing(p_filing_id uuid, p_reference text, p_filed_at timestamp with time zone, p_channel filing_channel, p_service text)` | Records that a declaration has gone, with the reference the administration gave back, and keeps the send as a row of tax_filing_deposits. It asks that the figures were computed, not that there are any: a period where nothing happened is filed nil. A rejected declaration may be sent again — it was never received — and the second send is a second deposit, not a corrective. |
| `filing_deadline(p_company_id uuid, p_report_code text, p_period_end date)` | When a period closed on this date has to be declared, under the rule the pack carries. Null where the pack declares none, and null where it declares depends_on_taxpayer — a country whose schedule depends on the filer, not a country without deadlines. |
| `filing_drift(p_filing_id uuid)` | Box by box and kind by kind, what the ledger says now — at the unit the form is filed in — against what was filed, for the figures where the two disagree. Empty is the answer everybody wants; anything else is either a corrective to file or an entry in the wrong period. |
| `filing_period(p_company_id uuid, p_report_code text)` | How often this company files that declaration, or null when it has not been recorded. Null is not a cadence and not an error: the books are kept the same either way, and a guard that reads it refuses nothing. |
| `filing_rounding(p_company_id uuid, p_report_code text)` | How a figure of this form is written when it is frozen for this company: the currency's decimals and the country's method, coarsened to the unit of the form where the form names one. The only reader of tax_report_templates.rounding_unit. |
| `filing_tax_movements(p_filing_id uuid)` | The tax accounts a declared period moved and by how much, on the same window and the same tax-point rule the return read, net of what an earlier settlement of the same period already carried. What settle_filing() clears — the whole period the first time, the difference on a corrective — and what anybody can read before it does. |
| `filings_touched_since(p_company_id uuid, p_from date, p_to date)` | Declarations that have gone and whose period the ledger moved afterwards: how many entries carrying a declaration box landed in it, when the last one did, and how many of the filed figures now disagree. An entry that changes no figure is still listed — it was posted into a period that had been declared, and that is the fact being reported. |
| `financial_statement(p_company_id uuid, p_statement_code text, p_from date, p_to date)` | One financial statement of a company for a period: each line summed from the accounts its rules catch, then the totals evaluated in the order the scheme declares them. No country rule lives in this function. |
| `financial_statement_of_kind(p_company_id uuid, p_kind text, p_from date, p_to date)` | One financial statement of a company by kind — balance_sheet, income_statement, allocation, cash_flow — for a caller that does not know which scheme its country pack carries. Resolves through default_statement_code() at the end date of the period, then answers as financial_statement() does, with the code it chose in the first column. |
| `fiscal_year_at(p_company_id uuid, p_date date)` | Fiscal year covering a date, or NULL. |
| `fiscal_year_bounds(p_country character, p_year integer, p_start date, OUT start_date date, OUT end_date date)` | The first and last day of a financial year opening in a given calendar year, on the month the country pack declares — or on a day the caller names. Raises rather than assuming January. |
| `fiscal_years_guard_closed()` | Refuses a hand-written change to is_closed. A column any client may flip is not a lock. |
| `format_number(p_format text, p_code text, p_date date, p_number integer)` | One document number, rendered from the pattern the country pack declares. Raises rather than guessing at a token it does not know. |
| `general_ledger(p_company_id uuid, p_from date, p_to date, p_account_ids uuid[])` | Posted lines of a period per account, with the balance carried forward from before the period. |
| `has_capability(p_company_id uuid, p_capability text)` | Whether the current caller may do one named thing in one company — a signed-in member by their preset and their adjustments, or a machine key by its own list. Revoked beats granted, and a non-member holding no key holds nothing. |
| `has_opening_entry(p_fiscal_year_id uuid)` | Whether a fiscal year already carries an opening entry that still stands — an imported balance or the re-opening of the year before. |
| `import_bank_statement(p_company_id uuid, p_file jsonb, p_source jsonb, p_bank_account_id uuid)` | Writes what a format reader read out of a bank file into bank_statements and bank_transactions, and nothing else: no entry, no payment, no matching. Idempotent on import_key — a replayed file imports nothing, an overlapping statement imports what is new and lists the rest. Refuses, by name and before writing anything: an account the company does not have (unknown_bank_account), a statement that does not add up (unbalanced_statement) or has no balances, a booked line it cannot hold as it is (unreadable_statement_line), a currency that is not the account's, and the same statement with other balances (statement_conflict). Signals and does not refuse: an opening balance that is not the previous closing one, a hole in the bank's numbering. One row per statement of the file; the whole file is imported or none of it. |
| `import_books(p_company_id uuid, p_books jsonb, p_dry_run boolean, p_open_years boolean, p_allow_result_accounts boolean)` | Takes over books read from another system, whole or not at all: the fiscal years they need (p_open_years), their parties, every entry posted through post_entry() and a trial balance through opening_balance(). Account codes arrive already translated into the company's chart. p_dry_run does all of it and rolls it back, so the answer and the refusals are the real ones. The same files twice are refused (import_already_done). |
| `import_company(p_archive jsonb, p_owner_user_id uuid)` | Takes in the archive `export_company()` wrote: one company, whole, with its identifiers, its numbers, its locks and its trail. The installer or an administrator of the installation only. Rows are inserted with the user triggers of the filled tables off for the length of the transaction, foreign keys on, and the result is checked — ownership of every row, no reference into another company, balance, matching, counters — before anything stays. A company already here is refused. `p_owner_user_id`, or the caller, becomes its first owner. |
| `import_fiscal_year_for(p_company_id uuid, p_date date)` | The fiscal year a date falls in, opened when there is none as a year of the same length and on the same first day as the company's earliest one. Called by import_books() when the caller asks for years to be opened. |
| `init_instance(p_organization_name text, p_country character, p_edition instance_edition)` | Records the installation. Called once, by the installer. Leaves the registration fields empty. |
| `install_country_template(p_company_id uuid, p_country character, p_language character, p_chart_code text)` | Copies one chart of a country pack into a company in one language, with the country's journals and taxes, wires the default roles, pins the accounts it wired, and records the pack version and the chart in company_packs. A tax posting is copied with every declaration box it prints in. |
| `installed_schema_version()` | The schema version this installation runs, and its edition. Definer, so a signed-in account that is on no company yet can still tell an instance behind its schema from one it may not read the row of — which is the same silence otherwise. Nothing else of the instance row comes with it. |
| `invite_member(p_company_id uuid, p_email text, p_role member_role, p_capabilities jsonb, p_valid_for interval)` | Invites an address into a company and returns the token once. Only the hash is stored; re-inviting the same address revokes the pending invitation. |
| `is_any_company_member()` | Whether the current user belongs to at least one company of this installation. |
| `is_company_owner(p_company_id uuid)` | Whether the current user is on the owner preset of a company. False, never NULL, for somebody who is not a member — a guard written as `if not is_company_owner(…)` has to fire for a stranger. |
| `is_eu_member(p_code text, p_on date)` | True when the whole of the common system of VAT applied to the territory on that day: every Member State, and Monaco, whose transactions article 7(1) treats as French. False for Northern Ireland, which is inside the system for goods alone, and false for a State from the day it left. |
| `is_installer()` | Whether the caller is the installation itself — the migration runner, the seeds, the CLI — rather than a person or a machine key. Set by the runner on its own connection; a session or a key can never be it, and neither can a connection where the setting was never made: the answer is false there, never NULL, because the guards negate it. |
| `is_instance_admin()` | Whether the current user administers this installation. |
| `label_for(p_name text, p_i18n jsonb, p_languages text[])` | The label in the first language of the list that has one, and the row's own name when none of them does. The only place a translated label is chosen. |
| `legal_mention_treatments(p_applies_when text)` | The tax treatments a condition of legal_mention_templates.applies_when covers, or null for a condition that is not about a treatment (always, late_payment, cash_basis, small_business). The one place that says so: document_legal_mentions reads it to print the sentence, document_tax_summary to give a VAT group its reason. |
| `locale_of_country_pack()` | Fills a company's currency and language from the pack of its fiscal country when the caller named neither. A pack that says nothing leaves them null, and NOT NULL refuses the row. |
| `lock_filed_period(p_filing_id uuid)` | Carries the tax lock to the end of the period a declaration covers, so nothing more falls into it. Forward only, refused on a declaration that has not gone, and refused while the period still has tax accounts to clear — because the lock would then refuse the very entry that clears them. Returns the lock date the company ends up with. Nobody is obliged to call it: a period left open is a period filings_touched_since() reports on. |
| `match_reversal(p_entry_id uuid, p_reversal_id uuid)` | Matches every reconcilable line of a posted entry against the line of its posted reversal — or of the credit note of its document — on the same account and the other side, through reconcile(). Returns how many matchings it made. Written for reverse_entry() and cancel_document(). |
| `matching_policy_of(p_company_id uuid)` | The five numbers, for this company: its own where it has an opinion, the shipped ones otherwise. The only function that carries a default. |
| `member_capabilities(p_company_id uuid, p_user_id uuid)` | The capabilities one member effectively holds on one company, preset and adjustments resolved. Reading another member's needs members.manage. |
| `module_enabled(p_company_id uuid, p_code text)` | The helper a module's row level security policies call: this module is enabled on this company and the caller is a member of it. One call, and the answer to a stranger is no. |
| `module_entry_id(p_company_id uuid, p_module_code text, p_ref text)` | The entry a module already posted under a reference, or null. What a module reads before deciding it has work to do. |
| `module_is_enabled(p_company_id uuid, p_code text)` | Whether a module is enabled on a company, regardless of who is asking. Definer so a policy on company_modules cannot recurse into it. |
| `module_settings(p_company_id uuid, p_code text)` | The settings a company keeps for one of its modules, or null when the module is not enabled. The socle never looks inside the object. |
| `next_entry_number(p_journal_id uuid, p_date date)` | Next number for a journal, on the pattern the country pack declares. Atomic: the counter row is locked, not the journal. Definer, because the counter is infrastructure and nobody writes it by hand. |
| `next_matching_number(p_company_id uuid)` | Next reconciliation letter for a company, as A0001. Definer, for the same reason as next_entry_number. |
| `note_company_export(p_company_id uuid)` | Writes `company_exported` on the audit trail. Called by `export_company()` and by `ekwo company export` before they read. A record of the act, not a control: a member can always read, table by table, what they may read. Definer because nobody writes the trail; guarded by company.export. |
| `number_counter(p_format text, p_number text)` | The counter inside a number, read back through the pattern it was written with, or null when the number does not follow that pattern. What lets an import advance the sequence it interrupted. |
| `numbering_rules(p_company_id uuid, OUT number_format text, OUT numbering_gapless boolean)` | What the country of a company says about its document numbers: the pattern, and whether the law forbids a hole. The only function that reads either column. |
| `open_items(p_company_id uuid, p_contact_id uuid, p_as_of date)` | Third-party lines with something still open, with the document behind each and the references it carries. Where there is no document — the debt of a declaration, an entry keyed by hand — the entry's own reference answers. Read by the matching, and by anybody asking what is still owed. |
| `opening_balance(p_company_id uuid, p_fiscal_year_id uuid, p_lines jsonb, p_allow_result_accounts boolean)` | Posts a trial balance from a previous system as the opening entry of a fiscal year. Balance-sheet accounts only, unless the caller allows the others. |
| `opening_journal_id(p_company_id uuid)` | The journal the opening and year-end entries go on, named by the pack of this company's country. Null when the pack names none, and the callers refuse rather than guessing at a code. |
| `pack_upgrade(p_company_id uuid, p_country character, p_apply boolean)` | Moves a company to the country pack version this installation holds: additions copied in, closed validities applied, everything else listed and left alone unless the caller asks for it. Records what it did in the audit trail. The recorded version moves only when nothing is left waiting. Definer, because the line it records goes through audit_record(), which no client may call; the caller still needs company.write on the company. |
| `pack_upgrade_diff(p_company_id uuid, p_country character)` | What separates a company from the country pack this installation now holds, by natural key, each difference carrying the rule that decides what an upgrade does with it. What a tax books is compared as one object, every declaration box of every posting included. |
| `periodic_return_code(p_company_id uuid)` | The code of the periodic return the company's fiscal country files, when the installation carries exactly one. Null when it carries none — no pack for that country — and null when it carries several, because then no single form is what a column named after "the" return could mean. It is what holds companies.vat_period and company_filing_periods in step, and it names the form by asking the pack rather than by knowing a country. |
| `pin_referenced_accounts(p_company_id uuid)` | Pins every account this company points at by a role, a journal, a tax posting or a cash-basis transition, and returns how many accounts are pinned afterwards. Called by install_country_template(); callable again after an upgrade added a tax. |
| `portfolio_filings_touched_since(p_from date, p_to date)` | Declarations that have gone and whose period the ledger moved afterwards, in every company the caller holds filings.read on, and in no other — filings_touched_since() with the company named, the latest disturbance first. Every company of the portfolio is in the answer at least once: one that was not disturbed is a row with no filing, and `filed` says how many of its declarations were looked at. Invoker: it reads what the caller could have read company by company. |
| `portfolio_upcoming_filings(p_from date, p_to date)` | What falls due between two dates in every company the caller holds filings.read on, and in no other: the periods upcoming_filings() produces, kept when the day they are due is in the window. Every company of the portfolio is in the answer at least once, and a row without a date says why in `reason` — no_deadline_rule where the pack names no day for the form, nothing_due where nothing of the company falls in the window, no_form where the installation carries no return for it. Invoker: it reads what the caller could have read company by company. |
| `post_document(p_document_id uuid)` | Books a document: one entry, the bases on the accounts of the lines, the tax of each group rounded once and shared over the postings of the tax, each ledger line naming the posting type that wrote it. Refuses a tax whose applies_*_territory the document contradicts — read with territory_within_for_tax(), so a territory outside its parent's tax does not satisfy a condition naming the parent — or whose applies_supply_vs_seller it contradicts, by name, before anything reaches the ledger; chooses no tax for anybody. Writes the three territories it resolved on the document (seller_territory_code, buyer_territory_code, supply_territory_resolved). |
| `post_entry(p_entry_id uuid)` | Validates, numbers and posts an entry. Raises rather than warning: a swallowed error is a missing entry. Where the country forbids a hole in the sequence it refuses a number chosen by hand, unless the caller holds entries.import — and then the counter catches up to it. |
| `post_module_entry(p_company_id uuid, p_module_code text, p_ref text, p_date date, p_description text, p_lines jsonb, p_journal_id uuid)` | The only way a module reaches the ledger: it hands over lines as data and this builds the draft and calls post_entry(). The tag (module_code, ref) is unique per company, so posting the same thing twice is refused by the database. |
| `post_payment(p_payment_id uuid)` | Books a payment: the bank side from the payment's bank account or its journal, the third-party side by role, both in the company currency at the payment's rate. Matches nothing. |
| `posted_edit_policy(p_company_id uuid)` | What the country of a company says about a posted document: reversal_only or unpost_if_untouched. A country that says nothing gets reversal_only, the stricter of the two, which every law accepts. The only function that reads the column. |
| `preferred_languages(p_company_id uuid)` | The languages to try, in order: the signed-in user's own, then the company's, then the one the country pack declares. The particular case of preferred_languages(language, company) where the starting point comes from the session. |
| `preferred_languages(p_language text, p_company_id uuid)` | The languages to try, in order, from a starting point the caller names: that one, then the company's, then the one the country pack declares. Feed it to label_for(). The starting point is a person's preference for a reader who is signed in, and documents.language for a document being rendered. |
| `prepare_filing(p_company_id uuid, p_from date, p_to date, p_report_code text)` | Computes the declaration and keeps the answer, box by box and kind by kind, each figure at the unit the form is filed in (filing_rounding()). Called again on a draft it refreshes; on a declaration that has gone it refuses and says the word for what is needed instead — a corrective. |
| `purge_audit_log(p_before date)` | Drops audit rows older than a date the caller names, and records that it did. service_role only: retention is the operator's decision and no signed-in user may make it. |
| `reconcile(p_line_a uuid, p_line_b uuid, p_amount numeric)` | Matches a debit line against a credit line, in the currency the two share when it is not the company's, and books what the matching reveals: the realised exchange difference, and the share of a cash-basis tax that has become due. |
| `reconciliations_guard_cancelled()` | Refuses to undo a matching on the entry of a cancelled document: cancel_document() matched it against its credit note, and that matching is what makes cancelled true. Unmatching it would leave a document that says cancelled and not_paid at once. document_cancelled_stays_matched, for everybody. |
| `record_filing_outcome(p_filing_id uuid, p_state tax_filing_state, p_reference text, p_message text)` | What came back: accepted, rejected, or paid, written on the declaration and on the send it answers — with the administration's own words where it gave any. Paying follows acceptance, and a declaration that never went cannot come back at all. |
| `register_instance(p_contact_email text)` | Opt-in: records an address and a date so Ekwo can reach the operator. Never required, and reversible with unregister_instance(). |
| `rehearse_post_document(p_document_id uuid)` | What post_document() would write, without writing it: the function is called for real inside a block that is then rolled back, so every rule, lock and refusal is the real one. The entry number shown is the one it would take now; somebody else posting first takes it instead. Amounts are text. |
| `reopen_filing(p_filing_id uuid)` | Takes a rejected declaration back to draft so its figures can be worked out again. Only a rejected one: a declaration the administration accepted is replaced by a corrective, never rewritten. What was sent stays in tax_filing_deposits. |
| `reopen_fiscal_year(p_fiscal_year_id uuid)` | Undoes a close: reverses the appropriation and closing entries it wrote and clears is_closed. Refused once a later year is closed or holds entries of its own. |
| `resolve_counterpart_account(p_company_id uuid, p_contact_id uuid, p_is_sale boolean)` | Third-party account by role: contact override first, company default second. Never by code prefix. |
| `resolve_line_account(p_company_id uuid, p_doc_type doc_type, p_account_id uuid)` | Account of a document line: the line, then the company default, then the country model. Never a code prefix. |
| `resolve_line_account(p_company_id uuid, p_doc_type doc_type, p_product_id uuid, p_account_id uuid)` | Account of a document line: the line, the product, the company default, the country model. Never a code prefix. |
| `reverse_entry(p_entry_id uuid, p_date date)` | Undoes a posted entry: writes its mirror in the same journal — every line with its sides swapped, its tax, its box with the opposite sign and its analytic split — names it in reversed_entry_id, posts it through post_entry() and matches the two on every reconcilable line. Dated on the original's day while that period is open, and otherwise refused until a date is given (reversal_date_needed). Refused for an entry that is not posted, is a reversal, is already reversed, is matched, or belongs to a document (cancel_document()), a close (reopen_fiscal_year()), an opening, a payment, a bank transaction, a module, a declaration or a matching. |
| `revoke_api_key(p_api_key_id uuid)` | Withdraws a key. There is no un-withdraw: a secret that has been out of the building is issued again, not brought back. |
| `revoke_invitation(p_invitation_id uuid)` | Withdraws an invitation that has not been accepted. An accepted one is a member, and members are removed from company_members. |
| `revoke_share(p_share_id uuid)` | Withdraws a link, now and for good. A withdrawn link answers exactly like one that never existed; there is no un-withdraw, because a secret that has been out of the building is issued again rather than brought back. |
| `round_amount(p_amount numeric, p_rounding money_rounding)` | Rounds an amount at the decimals of its currency, by the method of its country. The only function of the schema that names a rounding method; every other one asks rounding_of() and passes the answer here. |
| `rounding_of(p_company_id uuid, p_currency_code text)` | How this company writes an amount in this currency, or in its own when none is named. The only place currencies.decimal_places and country_defaults.rounding_method are read. |
| `set_preferences(p_patch jsonb)` | Writes the signed-in user's preferences. A key that is present is written, null included; a key that is absent is left alone; a key nobody declared is refused. |
| `set_updated_at()` | Generic BEFORE UPDATE trigger keeping updated_at honest. |
| `settle_cash_basis_tax(p_document_id uuid, p_date date)` | Moves the share of a cash-basis tax that settlement has made due, from the transition account to the account and the box it is declared on. Derived from the ledger, so it is the same call whether a matching was made or undone. |
| `settle_filing(p_filing_id uuid, p_credit tax_credit_treatment, p_reference text, p_contact_id uuid, p_date date)` | Clears the tax accounts a declared period moved and carries the net to the account the pack names for what is owed to the administration — or, where the period ends in a credit, to the one it names for a credit, once the company has said whether it is carried forward or claimed back. One entry per declaration, through post_entry(), with the reference the payment will be matched by. Naming the administration as the contact is what makes the debt settle by itself: matching books a payment, and a payment is made to somebody. |
| `settle_from_statement(p_transaction_id uuid, p_line_ids uuid[])` | Books the payment a statement line is, and matches it against the open items named. One counterparty, one payment, `post_payment()` and `reconcile()` doing the accounting — nothing here writes a ledger of its own. |
| `share_document(p_document_id uuid, p_expires_at timestamp with time zone)` | Publishes a sales document behind a link and returns the token once — only its hash is stored. `url` is the instance's public base plus /shared/<token>, or null where the instance has not recorded one. A share is never edited: revoke it and make another. |
| `shared_document(p_token text)` | One document, read by whoever holds its link: the header, the lines with the price as it was keyed and whether that price holds the tax, the tax breakdown, the totals, the legal mentions in the language the document was written in, and what is still owed today. Returns null — the same null, in the same shape — for a token that is unknown, withdrawn, expired, or onto a document that may no longer be shared. |
| `significant_words(p_text text, p_minimum_length integer)` | The words of a name that are long enough to be evidence, lowercased and deduplicated. No stop list: a word shared by several contacts is disqualified by the count of what it reaches, which is a fact about this company rather than an opinion about a language. |
| `statement_account_matches(p_company_id uuid, p_statement_code text, p_from date, p_to date)` | Every account of a company with a balance in the period, and the statement line it falls on — null when no rule catches it. An income statement and an allocation section leave the closing entry out; a balance sheet keeps it. The single decision financial_statement() and unmapped_accounts() both read. |
| `suggest_combination(p_transaction_id uuid)` | A subset of one counterparty's open items that adds up to the statement line, oldest first. A proposal only: it is never applied automatically, because a sum that reaches the right total from the wrong documents leaves nothing behind to notice. |
| `suggest_contacts(p_transaction_id uuid)` | Who this statement line could be, with the score, the evidence in a sentence, and how many contacts that same evidence reached. It writes nothing and decides nothing: a caller that applies a match on its own is expected to require alternatives = 1. Only the contacts whose name shares a word with the line are scored, through contacts.name_words. |
| `suggest_matches(p_transaction_id uuid)` | What a statement line could settle: the open items it matches, the evidence, and how many candidates that same evidence produced. Writes nothing. A combination of several documents is offered by suggest_combination(), separately, because it is a resemblance and not an identification. |
| `supersede_filing(p_filing_id uuid)` | Opens a corrective: the declaration that went becomes superseded and a new draft is prepared from today's ledger, at the unit the form is filed in, pointing at it. What was sent stays as it was sent. |
| `tax_point_of(p_company_id uuid, p_document_date date, p_delivery_date date, p_payment_date date)` | The day the tax on a document falls due, under the rule its company's country declares. The only function that reads country_defaults.tax_point_rule, and the only place the vocabulary of that column is written out. Null where the country declares no rule or where the rule names a date the caller does not have, and null means the entry's own date to every reader of it. |
| `tax_posting_boxes_agree()` | Keeps declaration_box and declaration_boxes in step on a tax posting: a writer that moves one is handed the other. A writer that moves both is left alone and judged by the check constraint, and a writer that clears the box clears the list with it. |
| `tax_rate_at(p_tax_id uuid, p_date date)` | Percentage in force at a date, NULL when the tax does not apply then. |
| `taxes_reach_draft_lines()` | A tax whose category, rate or kind of amount changes rewrites the snapshot of the draft lines that carry it, and nothing else: a posted line keeps what it was posted with. |
| `territory_of(p_code text)` | The territory a code or a VAT prefix names, or null when this table carries none. A code wins over a prefix, so FR is France and not the Monaco row that identifies under it. |
| `territory_within(p_code text, p_of text)` | True when the first territory is the second one or lies inside it, following territories.parent_code: US-CA is within US, XI is within GB, and neither is within the other. False for a code this table does not carry. |
| `territory_within_for_tax(p_code text, p_of text)` | territory_within(), cut at every territory whose outside_parent_tax is true: the walk up territories.parent_code stops there. So ES-CN is within ES-CN and not within ES, and US-CA is within US as before. What post_document() reads to judge a tax's territory conditions. False for a code this table does not carry. |
| `touch_api_key(p_api_key_id uuid)` | Records that a key was used just now. A key that has never been used, and one that has not been used for a year, are both things an operator should be able to see. |
| `trial_balance(p_company_id uuid, p_from date, p_to date)` | Opening balance, movements of the period and closing balance per account, posted entries only. |
| `unmapped_accounts(p_company_id uuid, p_statement_code text, p_from date, p_to date)` | Accounts this statement is answerable for that carry a balance and that no rule of it catches. Empty is what makes the statement tie out; a row is an account somebody opened outside the pack. |
| `unpost_document(p_document_id uuid)` | Puts a posted invoice or credit note back to draft, where its country's posted_edit_policy is unpost_if_untouched and nothing about it has left — every condition is unpost_refusal(), raised by name otherwise, and each refusal says to cancel_document() instead or what to undo first. Records the act in document_unpostings, takes the entry away, gives the number back to the counter where it was the last drawn, and returns the draft — without the number where it was its entry's, and without the booking day and tax point where posting had derived them. Definer, because document_unpostings is written by nobody else; asks documents.post itself. |
| `unpost_refusal(p_document_id uuid)` | Why a posted document may not go back to draft, as the sentence unpost_document() would raise — null where it may. Read first by a client that chooses between unpost_document() and cancel_document(), so that the choice is made here and nowhere else. Asks, in order: documents.post, a posted invoice or credit note, a country whose posted_edit_policy is unpost_if_untouched, never sent nor on Peppol, not settled, not credited, named by no other entry, a period open for its day and every tax point, no declaration gone over them, and — where numbering is gapless — the last number of its journal. |
| `unreconcile(p_reconciliation_id uuid)` | Undoes a matching, and with it what the matching had booked: the exchange difference it realised and the share of a cash-basis tax it had made due. |
| `unregister_instance()` | Undoes register_instance(). Opting in is reversible, or it is not a choice. |
| `upcoming_filings(p_company_id uuid, p_from date, p_to date)` | What this company has to file between two dates: the periods its cadences produce — any whole number of months, anchored on 1 January — the day each is due where the pack says, and the declaration already prepared or sent against it. Read-only; sending the reminder is somebody else's job, because a reminder needs a channel and somebody to operate it. |
| `use_api_key(p_secret text)` | Presents a machine key for the current transaction: has_capability() answers for it until the transaction ends. Refuses a key that is unknown, withdrawn or expired. |
| `vat_prefix_of(p_code text)` | The two letters a territory's VAT identification numbers carry: EL for Greece, FR for Monaco, GB for the Isle of Man, and the code itself everywhere else — including for a territory this table does not carry, whose own two letters come back unchanged. Null when what it resolves to is not two letters, which is a territory that identifies under nobody. |
| `vat_return(p_company_id uuid, p_from date, p_to date, p_report_code text)` | Declaration boxes for a period: summed from the ledger by the day each figure's tax fell due — `entry_lines.tax_point_date`, the entry's own date where the line carries none — then the totals of the country's form worked out by evaluate_totals(), the same evaluator financial_statement() uses. Refuses a period the company does not file **this form** on, when it has recorded one for it. No country rule lives in this function. |
| `version_at_least(p_version text, p_floor text)` | Whether a three-part version is at or above another, number by number: 0.10.0 is above 0.9.0, which a comparison of text gets wrong. |

---

# Modules

One Postgres schema each, beside the socle. A module depends on `public` by foreign key
and reaches the ledger only through `post_module_entry()`. It is enabled per company, and
PostgREST serves its schema only once the project exposes it.

## `assets` — Fixed assets

Fixed assets, their depreciation schedule and their disposal. Durations, declining coefficients and the prorata convention are country pack data.

### Tables

| Table | Purpose |
|---|---|
| [`assets`](#assets-assets) | One fixed asset: what it cost, how it is depreciated, and the three accounts that carry it. The schedule is assets.depreciation_lines. |
| [`category_templates`](#assets-category_templates) | The usual duration and method of a kind of asset in one country, with the source it comes from. A suggestion an asset may depart from, which is why it is never copied into a company. |
| [`country_rules`](#assets-country_rules) | How one country depreciates and derecognises. Filled by `ekwo pack build` from packs/<cc>/assets.json, read where it stands, never copied into a company. |
| [`depreciation_lines`](#assets-depreciation_lines) | One planned period of depreciation. `entry_id` is the entry that booked it, and is what makes running the depreciation of a period twice a no-op. |
| [`disposals`](#assets-disposals) | What leaving the books cost or earned: one row per asset, written by assets.dispose_asset(). There is no undo, for the reason there is no unpost. |

<a id="assets-assets"></a>

#### `assets`

One fixed asset: what it cost, how it is depreciated, and the three accounts that carry it. The schedule is assets.depreciation_lines.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `description` | `text` |  |
| `category_code` | `text` |  |
| `document_line_id` | `uuid` |  |
| `contact_id` | `uuid` |  |
| `product_id` | `uuid` |  |
| `acquisition_date` | `date` | not null |
| `in_service_date` | `date` |  |
| `cost` | `numeric(16,2)` | not null |
| `residual_value` | `numeric(16,2)` | not null |
| `method` | `assets.depreciation_method` | not null |
| `duration_months` | `integer` | not null |
| `coefficient` | `numeric(7,3)` | Multiplier of the straight-line rate under a declining balance. France 1,25 / 1,75 / 2,25 by duration; Belgium doubles the rate. Required by a check constraint for that method, because a declining balance with no coefficient is a straight line nobody asked for. |
| `prorata` | `assets.prorata_rule` | How much of the first period this asset takes. Null reads the country rule for its method, and an asset in a country whose pack says nothing is refused by name rather than given another country's convention. |
| `asset_account_id` | `uuid` | not null |
| `depreciation_account_id` | `uuid` | not null |
| `expense_account_id` | `uuid` | not null |
| `state` | `assets.asset_state` | not null |
| `notes` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((cost > (0)::numeric))`
- `CHECK (((method <> 'declining_balance'::assets.depreciation_method) OR (coefficient IS NOT NULL)))`
- `CHECK ((duration_months > 0))`
- `CHECK (((in_service_date IS NULL) OR (in_service_date >= acquisition_date)))`
- `CHECK (((residual_value >= (0)::numeric) AND (residual_value < cost)))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, code)`

<a id="assets-category_templates"></a>

#### `category_templates`

The usual duration and method of a kind of asset in one country, with the source it comes from. A suggestion an asset may depart from, which is why it is never copied into a company.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `name_i18n` | `jsonb` | not null |
| `method` | `assets.depreciation_method` | not null |
| `duration_months` | `integer` | not null |
| `coefficient` | `numeric(7,3)` |  |
| `prorata` | `assets.prorata_rule` | Overrides the country rule for this category. Null is the ordinary case: the rule of the country, for the method this category uses. |
| `account_type` | `account_type` | Which of the eighteen account types the asset account of this category is, so a client can propose the accounts of a chart it has never seen. Advisory: nothing resolves an account from it. |
| `sequence` | `integer` | not null |
| `legal_reference` | `text` |  |

Constraints:

- `CHECK (((method <> 'declining_balance'::assets.depreciation_method) OR (coefficient IS NOT NULL)))`
- `CHECK ((duration_months > 0))`
- `PRIMARY KEY (country, code)`

<a id="assets-country_rules"></a>

#### `country_rules`

How one country depreciates and derecognises. Filled by `ekwo pack build` from packs/<cc>/assets.json, read where it stands, never copied into a company.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `prorata_straight_line` | `assets.prorata_rule` | not null |
| `prorata_declining` | `assets.prorata_rule` | not null |
| `day_count` | `assets.day_count` | not null |
| `declining_cap_percent` | `numeric(7,3)` | Largest annuity a declining balance may take in one period, as a percentage of the acquisition value. Null where the country caps nothing. |
| `declining_switch_to_linear` | `boolean` | not null — Whether the declining balance switches to the straight line over the remaining periods once that gives the larger annuity. True everywhere the declining balance is a tax incentive rather than a valuation method. |
| `disposal_style` | `assets.disposal_style` |  |
| `legal_reference` | `text` |  |

Constraints:

- `CHECK (((declining_cap_percent IS NULL) OR ((declining_cap_percent > (0)::numeric) AND (declining_cap_percent <= (100)::numeric))))`
- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `PRIMARY KEY (country)`

<a id="assets-depreciation_lines"></a>

#### `depreciation_lines`

One planned period of depreciation. `entry_id` is the entry that booked it, and is what makes running the depreciation of a period twice a no-op.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `asset_id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `sequence` | `integer` | not null |
| `period_start` | `date` | not null |
| `period_end` | `date` | not null |
| `amount` | `numeric(16,2)` | not null |
| `accumulated` | `numeric(16,2)` | not null |
| `net_book_value` | `numeric(16,2)` | not null |
| `entry_id` | `uuid` |  |
| `posted_at` | `timestamp with time zone` |  |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((amount >= (0)::numeric))`
- `CHECK ((period_end >= period_start))`
- `CHECK (((posted_at IS NULL) OR (entry_id IS NOT NULL)))`
- `PRIMARY KEY (id)`
- `UNIQUE (asset_id, period_end)`
- `UNIQUE (asset_id, sequence)`

<a id="assets-disposals"></a>

#### `disposals`

What leaving the books cost or earned: one row per asset, written by assets.dispose_asset(). There is no undo, for the reason there is no unpost.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `asset_id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `disposal_date` | `date` | not null |
| `proceeds` | `numeric(16,2)` | not null |
| `counterpart_account_id` | `uuid` |  |
| `contact_id` | `uuid` |  |
| `cost` | `numeric(16,2)` | not null |
| `accumulated` | `numeric(16,2)` | not null |
| `net_book_value` | `numeric(16,2)` | not null |
| `result` | `numeric(16,2)` | not null |
| `entry_id` | `uuid` |  |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((proceeds >= (0)::numeric))`
- `PRIMARY KEY (id)`
- `UNIQUE (asset_id)`

### Functions

| Function | Purpose |
|---|---|
| `accounts_in_use(p_company_id uuid)` | The accounts this module points at for one company: what its assets are booked, depreciated and charged on, and what a disposal was settled against. Read by public.accounts_in_use() through the module convention. |
| `archive_tables()` | What an archive of one company does with each table of this module. Read by `public.company_archive_tables()`. |
| `can_disable(p_company_id uuid)` | Why this company cannot disable the assets module, or null when it can. The convention disable_module() reads. |
| `create_asset(p_company_id uuid, p_code text, p_name text, p_acquisition_date date, p_cost numeric, p_asset_account text, p_depreciation_account text, p_expense_account text, p_category_code text, p_duration_months integer, p_method assets.depreciation_method, p_coefficient numeric, p_residual_value numeric, p_in_service_date date, p_document_line_id uuid, p_contact_id uuid, p_description text)` | Creates an asset and its schedule in one call. A category of the country pack fills in the method, the duration and the coefficient; anything the caller passes wins over it. |
| `days360(p_from date, p_to date)` | Days between two dates on a year of 360 days and months of 30, the day capped at the 30th. Half-open: days360(1 January, 1 January of the next year) is 360. |
| `dispose_asset(p_asset_id uuid, p_date date, p_proceeds numeric, p_counterpart_account text, p_contact_id uuid)` | Takes an asset off the books on a date: clears its cost and its accumulated depreciation, books the proceeds, and presents the result the way the country's pack says — one gain or loss line, or the value and the proceeds in full. |
| `generate_schedule(p_asset_id uuid)` | Writes the depreciation schedule of an asset, period by period, rounded at the decimals of the company's currency with the last line taking the remainder. Refuses to rewrite a schedule whose lines are already booked. |
| `movements(p_company_id uuid, p_from date, p_to date)` | What came in, what was written off and what went out between two dates, per asset — the movement table an annual account asks for beside the register. |
| `prorata_fraction(p_rule assets.prorata_rule, p_day_count assets.day_count, p_start date, p_period_start date, p_period_end date)` | The share of a period that runs from the day an asset entered service. A prorata in days counts the day of entry into service itself, which is the convention that makes a full year come to exactly one. |
| `register(p_company_id uuid, p_at date)` | The table of fixed assets at a date: what each one cost, what has been written off it, and what is left. Reads what has been booked, so it ties to the ledger. |
| `rules(p_company_id uuid)` | The depreciation rules of this company's country, or an empty row when its pack says nothing. The callers name what is missing rather than borrowing another country's answer. |
| `run_depreciation(p_company_id uuid, p_period_end date)` | Books every planned period that ends on or before a date, one entry per period, through post_module_entry(). Idempotent: a period already booked is skipped, and the unique tag on the entry refuses a second one anyway. A closed financial year refuses the posting, because post_entry() asserts the period is open. |

## `budgets` — Budgets

A budget per financial year, its lines per account and period, and the variance against what the ledger actually holds. No country data, and nothing written to the ledger.

### Tables

| Table | Purpose |
|---|---|
| [`budgets`](#budgets-budgets) | One budget of one company, usually for one financial year. A company may hold several — a plan and a revision are two budgets and not two columns. |
| [`lines`](#budgets-lines) | What one account is expected to carry over one period, in the sign a business says it: an income and a cost are both positive. |

<a id="budgets-budgets"></a>

#### `budgets`

One budget of one company, usually for one financial year. A company may hold several — a plan and a revision are two budgets and not two columns.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `fiscal_year_id` | `uuid` | The year this budget is for, where it is for one. Null on a rolling budget, whose lines carry their own periods anyway. |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `state` | `budgets.budget_state` | not null |
| `notes` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `PRIMARY KEY (id)`
- `UNIQUE (company_id, code)`

<a id="budgets-lines"></a>

#### `lines`

What one account is expected to carry over one period, in the sign a business says it: an income and a cost are both positive.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `budget_id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `account_id` | `uuid` | not null |
| `period_start` | `date` | not null |
| `period_end` | `date` | not null |
| `amount` | `numeric(16,2)` | not null |
| `note` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((period_end >= period_start))`
- `PRIMARY KEY (id)`
- `UNIQUE (budget_id, account_id, period_start, period_end)`

### Functions

| Function | Purpose |
|---|---|
| `accounts_in_use(p_company_id uuid)` | The accounts this module points at for one company: every account a budget line plans an amount on. Read by public.accounts_in_use() through the module convention. |
| `archive_tables()` | What an archive of one company does with each table of this module. Read by `public.company_archive_tables()`. |
| `variance(p_company_id uuid, p_budget_id uuid, p_from date, p_to date)` | Budget against ledger, per account, over a period, at the decimals of the company's currency. Both figures are in the sign a business states them in — an income account's credit balance is flipped — and the variance is the actual less the plan. Reads posted entries of kind `normal` only: a closing or appropriation entry is not what a period earned. |

---

*This file is generated by `scripts/generate-schema-doc.mjs`. Edit the
migrations and `docs/schema.intro.md`, then regenerate.*
