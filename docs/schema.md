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
           └─ attachments                files; an invoice's piece on its document
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
   `fiscal_years.is_closed`. Matching stays allowed. A closed year is
   reopened by `reopen_fiscal_year()`; a year under a final close
   (`fiscal_years.finally_closed_at`) is never reopened or changed, by anybody.
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
8. **A piece goes on its document.** An invoice, a credit note or a receipt
   is attached to the document (`attachments.entity_type = 'document'`). An
   entry that a document posted refuses a file and names the document to use;
   an entry no document posted keeps its own piece (decision 0069).
9. **A tax lands by its code, not on a line.** A document line carries its
   base and names its tax (`document_lines.tax_id`); the posting writes the
   tax on the account the tax points to (`tax_postings`). A line put on such
   an account is refused (`tax_account_on_a_line`), with the taxes that land
   there named; the credit note of a document that already carries one copies
   it, so the document can still be undone (decision 0083).

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

A Belgian purchase of goods from another Member State of the European Union at 21 % is therefore four rows:

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

## Settling a statement line

`settle_from_statement(transaction, line_ids, amounts, extra_lines)` books a
bank statement line as the payment it is and matches it against the open
items named, in one entry. `amounts` says how much settles each item, in the
order named; left out, the items are settled oldest first — in full when
there are extra lines. `extra_lines` are
what the money is net of or carries besides — the fee a payment provider kept
from a payout, the charges of a bank, a small difference — as
`{account, amount, tax?, description?}`, by code, a positive amount a charge
(debited), a tax inside the amount and booked from the postings of a purchase
invoice. The line balances to the cent: money in is the items less the extra
lines, money out the items plus them, and `settlement_unbalanced` names the
difference otherwise. A payout of 97.00 for an invoice of 100.00 is

| account | debit | credit |
|---|---|---|
| bank | 97.00 | |
| customer | | 100.00 |
| fee | 3.00 | |

with the customer line matched against the invoice. Extra lines alone settle a
bank charge that pays no item.


## Tables

| Table | Purpose |
|---|---|
| [`account_templates`](#account_templates) | Reference charts of accounts, one set per country. |
| [`accounts`](#accounts) | Chart of accounts, one per company. |
| [`analysis_aggregates`](#analysis_aggregates) | The aggregates an analysis of the books is computed from, and how each is read. Vocabulary of the core, the same in every country; the accounts that make each one are a pack's, in analysis_rules. |
| [`analysis_rules`](#analysis_rules) | How an account of a company reaches an aggregate: the rules of a statement line, with the same columns and the same test, account_rule_catches(). An account reaches an aggregate once, whatever the number of its rules that take it; two aggregates may take the same account — cash is part of the current assets, which are part of the total. |
| [`analysis_templates`](#analysis_templates) | The aggregates a pack defines for one of its charts, or a framework for any chart, and where that reading comes from. Written by the seed of a pack that carries analysis.json; financial_analysis() reads the country's rows when the company's chart has any, and a framework's otherwise. |
| [`analytic_axes`](#analytic_axes) | Analytic dimensions: cost centre, project, activity. |
| [`analytic_values`](#analytic_values) | Values of an axis, optionally hierarchical. |
| [`api_keys`](#api_keys) | Machine access to one company. Hashed at rest, scoped to an explicit list of capabilities, and never wider than the person who issued it — at issuance and at every use. |
| [`attachments`](#attachments) | Files attached to any record. `entity_type` is constrained rather than free text. An invoice or a receipt goes on its document; an entry takes a file only when no document posted it (trigger attachments_guard_document). |
| [`audit_log`](#audit_log) | Append-only record of every change to the configuration and reference data of a company, and of the acts that change the state of a document, a payment, a financial year or a pack. Written by trigger, never by a client, and no client rewrites it: no role is granted update, delete or truncate, and triggers refuse them. The owner of the database is bound only while it leaves those triggers enabled. |
| [`bank_accounts`](#bank_accounts) | Bank and card accounts, each mapped to a ledger account and a journal. |
| [`bank_statement_lines`](#bank_statement_lines) | Which lines a statement lists. A line is stored once, in bank_transactions, under the first statement that brought it; a later statement that overlaps the first lists the same line here instead of duplicating it, and its closing balance is proved over the list. |
| [`bank_statements`](#bank_statements) | Imported statements. `is_consistent` compares the declared closing balance with the sum of the lines. |
| [`bank_transactions`](#bank_transactions) | Statement lines. `amount` is signed; `raw` keeps whatever the source sent. |
| [`book_imports`](#book_imports) | One row per set of books taken over by import_books(): which reader, the checksum of the files, how many entries and lines, and the numbers they were posted under. The same files twice in one company are refused by the unique checksum. |
| [`capabilities`](#capabilities) | Everything a member may be allowed to do, one row per code. Seeded by this migration for the core; a module adds its own with `area` set to the module code. |
| [`chart_templates`](#chart_templates) | Charts of accounts a country offers, from the `charts` list of packs/<cc>/pack.json. One of them is the default `ekwo init` installs when nobody names one. |
| [`classification_schemes`](#classification_schemes) | The classifications of goods and services a country uses on its documents, compiled from its pack: the attribute of a line or a product that holds the code, the name of the classification, the anchored pattern of its codes and the article that prescribes it. A code held under one of these names in document_lines.attributes or products.attributes must match the pattern (decision 0078). |
| [`companies`](#companies) | Legal entities kept in this instance. One instance may hold several. |
| [`company_archive_registry`](#company_archive_registry) | What an archive of one company does with each table of the socle that belongs to a company: `exported`, or `excluded` with the reason. A table of a company that is not named here stops every export. Modules answer for their own tables through `<schema>.archive_tables()`. |
| [`company_filing_periods`](#company_filing_periods) | How often this company files each declaration it is subject to: one row per form of tax_report_templates, and no row where nothing has been recorded. A company files its periodic return on one cadence and its recapitulative statement on another, and the second is not derivable from the first in any country read so far. |
| [`company_invitations`](#company_invitations) | Pending and past invitations into a company. The token is handed over once and kept only as a sha256 hash. |
| [`company_members`](#company_members) | Who may read or write a company. A role is a preset resolved through `role_capabilities`: `owner` administers, `accountant` books, `viewer` reads, `client` reads and hands pieces over. |
| [`company_modules`](#company_modules) | Modules enabled on a company, and the settings that company keeps for each. Written by enable_module() and disable_module() and by nothing else: there is no write policy. |
| [`company_packs`](#company_packs) | Which version of which country pack a company copied. A company may hold two: a foreign VAT registration is one. |
| [`company_tax_regimes`](#company_tax_regimes) | The regime of turnover_tax_regimes a company is under, from the first day of a financial year to the last day of one, or open-ended. No row: the company is under the ordinary regime of its taxes (decision 0080). |
| [`company_vat_schemes`](#company_vat_schemes) | The VAT scheme a company is on, from the first day of a financial year until the next row. No row: the company has not said, and files exactly as it did before schemes existed — no default and no guess. The forms and cadences it implies are written into company_filing_periods, which stays the one place a cadence is recorded. |
| [`contact_merges`](#contact_merges) | Every merge of two contacts, by merge_contacts() (decision 0074): the contact absorbed, the one kept, who merged them and when, what moved and what was filled. Written by merge_contacts() and by nothing else — no role may insert — so the guards of a posted line and of an issued document read a row here, written in the same transaction, as the exemption that lets contact_id move from the absorbed contact to the kept one. |
| [`contact_patterns`](#contact_patterns) | How a counterparty shows up on this company's statements: one row per learned or declared motif, of four closed kinds. Read by suggest_contacts(), written by confirm_contact(). The core still chooses no contact for anybody — it answers with candidates and says why. |
| [`contacts`](#contacts) | Third parties. `contact_type` is explicit rather than two hidden counters. |
| [`country_defaults`](#country_defaults) | Which template account plays which role, per country. |
| [`country_packs`](#country_packs) | Country packs loaded in this installation, with their version and certification. |
| [`currencies`](#currencies) | ISO 4217 currencies known to this instance. |
| [`currency_rates`](#currency_rates) | Dated exchange rates. A document stores the rate it used; this table is the history. |
| [`declaration_instalments`](#declaration_instalments) | What a company paid on account of a declaration during its period: which instalment of the scheme's schedule, the day, the amount and the entry that carried it, where there is one. Several rows for one instalment are a payment made in parts. The annual return deducts them in the box whose reads is instalments_paid or instalments_due. |
| [`document_line_analytics`](#document_line_analytics) | Analytic split of a document line, one row per value, share in percent. Copied onto the ledger line by post_document(); after posting the ledger split is the one read. |
| [`document_lines`](#document_lines) | Lines of a document. A product line carries its base, its account and its tax (tax_id); the tax itself is written by the posting on the account the tax points to, and a line on such an account is refused (trigger document_lines_guard_tax_account). |
| [`document_shares`](#document_shares) | Public links onto a document. The token is handed over once and kept only as a sha256; the link is withdrawn by revoking it, never by editing it. |
| [`document_unpostings`](#document_unpostings) | Every posted document put back to draft by unpost_document(): the entry that was taken away, its number, journal and day, and whether the number went back to the counter. Written by unpost_document() and by nothing else — no role may insert — so the guards read a row here, written in the same transaction, as the one exception to "a posted document does not go back to draft" and "a posted entry is not deleted". |
| [`documents`](#documents) | Sales and purchase invoices, credit notes, quotes and orders. `state` is the document, `payment_state` the settlement. |
| [`entries`](#entries) | Journal entries. A document and its entry are two layers joined by a foreign key. |
| [`entry_line_analytics`](#entry_line_analytics) | Analytic split of a ledger line. One row per value, share in percent. |
| [`entry_lines`](#entry_lines) | Ledger lines. Amounts are always positive; a reversal flips the side, it never negates. |
| [`filing_proofs`](#filing_proofs) | Proofs that a file existed at a date: the sha256 of its exact bytes, committed to a public ledger, with the proof that it was. Written through record_filing_proof() and upgrade_filing_proof(); a complete proof is frozen. filing_proof(sha256) is the public way to read one. |
| [`fiscal_years`](#fiscal_years) | Accounting periods. An exercise is an object, not two integers on the company. |
| [`instance`](#instance) | The installation itself. Exactly one row. Registration with Ekwo is optional and empty by default. |
| [`instance_admins`](#instance_admins) | Instance administrators: they create companies and invite members. One row per user, keyed on auth.users of the customer's own Supabase project. |
| [`journal_sequences`](#journal_sequences) | Counter behind next_entry_number(). One row per journal and year. |
| [`journal_templates`](#journal_templates) |  |
| [`journals`](#journals) | Books of entry. The code is the first segment of every entry number. |
| [`legal_mention_templates`](#legal_mention_templates) | The sentences a country requires on an invoice, and the closed condition that says when each applies. Reference data filled by a pack, never copied into a company. |
| [`lines_left_unnamed`](#lines_left_unnamed) | Open lines on a receivable or payable account that a person decided to leave without a contact, with the reason: suggest_line_contacts() no longer proposes them. Written by leave_line_unnamed(), removed by undo_leave_line_unnamed(). The line itself does not move and stays an open item (decision 0072). |
| [`matching_sequences`](#matching_sequences) |  |
| [`matching_settings`](#matching_settings) | What this company considers close enough. Every column is nullable and null means the shipped answer, which lives in matching_policy_of() and nowhere else — so a reader always gets a number and a company that never had an opinion has no row. |
| [`modules`](#modules) | One row per module this installation carries, written by the module's own first migration. The registry is a table, not code. |
| [`payments`](#payments) | Money in and out. Amounts are positive; `direction` carries the sign. |
| [`products`](#products) | What a document line is filled in from: code, name, unit, price, account and tax. Not stock: no quantity on hand and no valuation. |
| [`reconciliation_batches`](#reconciliation_batches) | Matchings made in one gesture: reconcile_batch() writes the row and names it on every matching it wrote (reconciliations.batch_id); unreconcile_batch() undoes those still standing and says when and by whom. Written by those two functions alone (decision 0073). |
| [`reconciliations`](#reconciliations) | One row per pairing of a debit with a credit. Full matching is the sum of partials. |
| [`role_capabilities`](#role_capabilities) | What each preset holds. A role is never tested by a policy; it is resolved here into capabilities. |
| [`statement_line_rules`](#statement_line_rules) | How an account of a company reaches a line. Presentation maps by range of the legal chart; choosing an account to post to by prefix stays forbidden, and is a different question. |
| [`statement_line_templates`](#statement_line_templates) | The lines of a statement, in the order it prints them, and the plus/minus lists a total is computed from. |
| [`statement_templates`](#statement_templates) | Financial statements per framework, from packs/<cc>/statements.json and packs/generic/. Reference data: never copied into a company. |
| [`tax_filing_boxes`](#tax_filing_boxes) | The figures as they were filed, one row per box. Frozen at filing and never recomputed: this is what the administration holds. |
| [`tax_filing_deposits`](#tax_filing_deposits) | One send of a declaration and what came back. Written only by file_filing(), record_filing_outcome() and record_filing_files(); read under filings.read. |
| [`tax_filings`](#tax_filings) | One row per declaration of a period: what was filed, when, under which reference, and in which state. The figures are in tax_filing_boxes and they are frozen — this table exists so that "what did we declare" is a question with an answer. |
| [`tax_posting_templates`](#tax_posting_templates) |  |
| [`tax_postings`](#tax_postings) | Where a tax lands: ledger account and VAT-return box, per tax and per document kind. |
| [`tax_report_box_templates`](#tax_report_box_templates) | The boxes of a declaration form, and the plus/minus lists a total is computed from. Read by vat_return(). |
| [`tax_report_templates`](#tax_report_templates) | Declaration forms per country, from packs/<cc>/tax_report.json. Reference data: a form is not customisable, so it is never copied into a company. |
| [`tax_templates`](#tax_templates) | Reference taxes per country, with their period of validity. |
| [`taxes`](#taxes) | VAT and similar taxes, with temporal validity and a legal reference. |
| [`territories`](#territories) | The territories of the common system of value added tax: the Member States with the day each became bound, the United Kingdom with the day it stopped being, Northern Ireland, and the territories articles 6 and 7 of Directive 2006/112/EC take out of the system or put into it. Framework data filled by the release, like currencies — no company owns a row and no country pack writes one. A territory this table does not carry is outside the common system, which is the answer for every third country. |
| [`turnover_tax_assessments`](#turnover_tax_assessments) | The tax on turnover of a period as post_turnover_tax() computed and posted it: the figures of turnover_tax_return() as they were, the entry that booked the tax (null for a period that owed nothing) and the filing it prepared. Written by that function and by nothing else. |
| [`turnover_tax_brackets`](#turnover_tax_brackets) | The brackets of a regime of turnover_tax_regimes, dated: the highest base each takes (inclusive; null for the last), its nominal rate in percent and the deduction subtracted from base x rate. The tax of a period is its turnover x (base x nominal_rate / 100 - deduction) / base, the base being the window's turnover. A flat rate is one bracket with no threshold and no deduction. |
| [`turnover_tax_regimes`](#turnover_tax_regimes) | A regime of a country where one tax on turnover replaces the kinds of tax it names, compiled from the pack's turnover_tax.json: the form it is declared on, the window its bracket is read over, the account its tax is an expense on and the article that sets it (decision 0080). |
| [`user_preferences`](#user_preferences) | What one person prefers, across every company they are a member of. Every column is nullable and none has a default: null means "take the company's answer, then the pack's". |
| [`vat_scheme_ceilings`](#vat_scheme_ceilings) | Up to which amount a company may be on a scheme: a measure from a closed vocabulary, the part of the activity it is counted on, an amount in a currency, the dates it applies between and the article that sets it. Read by vat_scheme_ceilings_crossed(), an alert; nothing moves a company from one scheme to another by itself. |
| [`vat_scheme_forms`](#vat_scheme_forms) | The declaration forms a company on a scheme files, each on the cadences the scheme allows. A form of the country that no scheme names is outside every scheme and is filed as before; a form some scheme names is filed only under the schemes that name it. |
| [`vat_scheme_instalments`](#vat_scheme_instalments) | The payments on account a scheme asks for during the year a return covers: in which month (and on which day, where the law gives one to everybody), which percentage of which box of the previous period's return, and the base below which nothing is due. instalment_plan() reads it. |
| [`vat_schemes`](#vat_schemes) | The VAT schemes of a country, compiled from packs/<cc>/vat_schemes.json: the fact that decides which declaration forms a company files at all. A country with no row has no scheme, and its companies file as they always did. |

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

### `analysis_aggregates`

The aggregates an analysis of the books is computed from, and how each is read. Vocabulary of the core, the same in every country; the accounts that make each one are a pack's, in analysis_rules.

| Column | Type | Notes |
|---|---|---|
| `code` | `text` | not null |
| `reading` | `text` | not null — movements: what the period added, posted entries dated inside it, less the entries close_fiscal_year() marks closing — as an income statement reads. closing: the balance at the end of the period, every posted entry up to it — as a balance sheet reads. |
| `sign` | `smallint` | not null — Multiplies the debit-minus-credit balance so the aggregate reads as its name says: 1 where a debit is the figure (an asset, a charge), -1 where a credit is (revenue, equity, a debt, a profit). |
| `adds_unclosed_result` | `boolean` | not null — Whether the aggregate also takes the result nobody has closed: the balance of every income and expense account its rules do not catch, on the account year_result_account() names. True of equity alone. |
| `sequence` | `integer` | not null |
| `description` | `text` | not null |

Constraints:

- `CHECK ((reading = ANY (ARRAY['movements'::text, 'closing'::text])))`
- `CHECK ((sign = ANY (ARRAY[1, '-1'::integer])))`
- `CHECK (((NOT adds_unclosed_result) OR (reading = 'closing'::text)))`
- `PRIMARY KEY (code)`

### `analysis_rules`

How an account of a company reaches an aggregate: the rules of a statement line, with the same columns and the same test, account_rule_catches(). An account reaches an aggregate once, whatever the number of its rules that take it; two aggregates may take the same account — cash is part of the current assets, which are part of the total.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` |  |
| `chart_code` | `text` |  |
| `aggregate` | `text` | not null |
| `sequence` | `integer` | not null |
| `rule_kind` | `text` | not null |
| `code_from` | `text` |  |
| `code_to` | `text` |  |
| `account_type` | `account_type` |  |
| `balance_side` | `text` | not null — Which side of the account the aggregate takes, read on the balance the aggregate reads: `debit` and `credit` split an account the balance sheet itself splits — a bank account in debit is cash, in credit a debt. |
| `framework` | `text` | The framework the rule belongs to; null on a country's rule. A framework's rules are account_type rules only. |

Constraints:

- `CHECK (
CASE rule_kind
    WHEN 'account_type'::text THEN ((account_type IS NOT NULL) AND (code_from IS NULL) AND (code_to IS NULL))
    WHEN 'code_range'::text THEN ((code_from IS NOT NULL) AND (code_to IS NOT NULL) AND (account_type IS NULL))
    ELSE ((code_from IS NOT NULL) AND (code_to IS NULL) AND (account_type IS NULL))
END)`
- `CHECK (((country IS NULL) OR (country ~ '^[A-Z]{2}$'::text)))`
- `CHECK (((country IS NOT NULL) OR (rule_kind = 'account_type'::text)))`
- `CHECK ((rule_kind = ANY (ARRAY['account_code'::text, 'code_range'::text, 'code_prefix'::text, 'account_type'::text])))`
- `CHECK (
CASE
    WHEN (country IS NULL) THEN ((chart_code IS NULL) AND (framework IS NOT NULL))
    ELSE ((chart_code IS NOT NULL) AND (framework IS NULL))
END)`
- `CHECK ((balance_side = ANY (ARRAY['debit'::text, 'credit'::text, 'any'::text])))`
- `UNIQUE (framework, aggregate, sequence)`
- `UNIQUE (country, chart_code, aggregate, sequence)`

### `analysis_templates`

The aggregates a pack defines for one of its charts, or a framework for any chart, and where that reading comes from. Written by the seed of a pack that carries analysis.json; financial_analysis() reads the country's rows when the company's chart has any, and a framework's otherwise.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | The country of the pack this reading of a chart comes from. Null on a framework's row, which reads account types and fits any chart of any country. |
| `chart_code` | `text` | The chart the rules are written for. Null on a framework's row. |
| `aggregate` | `text` | not null |
| `legal_reference` | `text` | not null — The classes of the chart or the rubric of the statement the aggregate mirrors, cited as the country cites them. |
| `source_key` | `text` | Key of the entry of the pack's source register where that reference can be read. |
| `framework` | `text` | The framework this row belongs to, as its pack names it — the code statement_templates.framework carries for the same framework. Null on a country's row. |

Constraints:

- `CHECK (((country IS NULL) OR (country ~ '^[A-Z]{2}$'::text)))`
- `CHECK (
CASE
    WHEN (country IS NULL) THEN ((chart_code IS NULL) AND (framework IS NOT NULL))
    ELSE ((chart_code IS NOT NULL) AND (framework IS NULL))
END)`
- `UNIQUE (framework, aggregate)`
- `UNIQUE (country, chart_code, aggregate)`

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
| `required_on` | `text` | not null — Which lines must carry this axis whole at posting: none (the default), expense, income, or result (both). A document or an entry keyed by a person whose line of that group has less than 100 % on the axis is refused, analytic_axis_required. |

Constraints:

- `CHECK ((required_on = ANY (ARRAY['none'::text, 'expense'::text, 'income'::text, 'result'::text])))`
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
- `UNIQUE (axis_id, code, company_id)`

### `api_keys`

Machine access to one company. Hashed at rest, scoped to an explicit list of capabilities, and never wider than the person who issued it — at issuance and at every use.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `name` | `text` | not null |
| `prefix` | `text` | not null — The readable head of the secret. It identifies a key without being one. |
| `key_hash` | `text` | not null |
| `capabilities` | `text[]` | not null — Exactly what this key may do. Not a role: a machine has a job, not a job title. |
| `created_by` | `uuid` | auth.users.id of the person the key is a delegation from: whoever issued it, or the person behind the key that issued it. Null for a key the installation issued itself. The key never holds more than this person holds today, and what it writes is recorded against this person (acting_user()). No foreign key, for the same reason company_members has none. |
| `created_at` | `timestamp with time zone` | not null |
| `expires_at` | `timestamp with time zone` |  |
| `last_used_at` | `timestamp with time zone` | When this key was last presented in a transaction that could write it down. A read over the API runs read-only and is not stamped, so this is a floor and never a ceiling: a key with an old date may still be in daily use for reading. |
| `revoked_at` | `timestamp with time zone` |  |
| `posting_mode` | `text` | not null — How this key posts a document, fixed when it is issued: review (the default), as the company's agent_posting says — only a draft a person approved, unless the company chose autopilot; autopilot, directly — issued only by a person holding company.write, and refused (autopilot_forbidden) in a company whose agent_posting is review_only. Its requests ignore the mark X-Ekwo-Agent. Never changed afterwards: a key wanted in another mode is issued again. |

Constraints:

- `CHECK (((expires_at IS NULL) OR (expires_at > created_at)))`
- `CHECK ((cardinality(capabilities) > 0))`
- `CHECK ((posting_mode = ANY (ARRAY['review'::text, 'autopilot'::text])))`
- `PRIMARY KEY (id)`
- `UNIQUE (key_hash)`

### `attachments`

Files attached to any record. `entity_type` is constrained rather than free text. An invoice or a receipt goes on its document; an entry takes a file only when no document posted it (trigger attachments_guard_document).

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

Append-only record of every change to the configuration and reference data of a company, and of the acts that change the state of a document, a payment, a financial year or a pack. Written by trigger, never by a client, and no client rewrites it: no role is granted update, delete or truncate, and triggers refuse them. The owner of the database is bound only while it leaves those triggers enabled.

| Column | Type | Notes |
|---|---|---|
| `id` | `bigint` | not null — The row's number in the installation. Not granted to a signed-in user: the gap between two ids of one company is the work of every other company in between. Read the trail in the order of occurred_at and sequence. |
| `occurred_at` | `timestamp with time zone` | not null |
| `actor_id` | `uuid` | The person the change was made for: the signed-in user, or the person who issued the machine key presented (acting_user()). Null on a direct connection, and for a key the installation issued itself. |
| `api_key_id` | `uuid` | The machine key presented in the transaction, when one was. Beside actor_id, the trail says for whom and through what. |
| `company_id` | `uuid` | The company the change belongs to, and what row level security reads. No foreign key: the trail outlives the row it describes. |
| `table_name` | `text` | not null |
| `record_id` | `uuid` |  |
| `record_key` | `text` | not null — The natural key of the row — an account code, a country, a user id — so a deleted row is still identifiable. |
| `operation` | `audit_operation` | not null |
| `action` | `text` | The business act this change is, when it is one. Null for an ordinary edit. |
| `old_values` | `jsonb` | The row before, as jsonb. Null on an insert. Secrets are replaced by null, never stored twice. |
| `new_values` | `jsonb` | The row after, as jsonb. Null on a delete. |
| `sequence` | `integer` | not null — The order of this change among those its transaction made to the same company (or to the installation itself), from 1. With occurred_at, the order a reader sorts the trail by. It counts nothing but rows of that company: unlike id, which is the installation's, it says nothing of anybody else's work (decision 0065). 0 on a row an archive brought in from an installation that did not write it. |

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
| `account_scheme` | `text` | The scheme account_identifier is written in, as the country pack names it. Null on a free-text account number. |
| `account_identifier` | `text` | What identifies the account at its bank, in the canonical form of its scheme: the parts in order, one space between them. An IBAN is one such identifier and has its own column too, kept for what already reads it. |

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

- `PRIMARY KEY (statement_id, transaction_id, company_id)`

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

### `classification_schemes`

The classifications of goods and services a country uses on its documents, compiled from its pack: the attribute of a line or a product that holds the code, the name of the classification, the anchored pattern of its codes and the article that prescribes it. A code held under one of these names in document_lines.attributes or products.attributes must match the pattern (decision 0078).

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `attribute` | `text` | not null |
| `name` | `text` | not null |
| `pattern` | `text` | not null |
| `legal_reference` | `text` | not null |
| `source_key` | `text` |  |
| `sequence` | `integer` | not null |

Constraints:

- `CHECK ((attribute ~ '^[a-z][a-z0-9_]{0,39}$'::text))`
- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `CHECK ((pattern ~ '^\^.*\$$'::text))`
- `PRIMARY KEY (country, attribute)`

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
| `created_by` | `uuid` | The person who created the company — acting_user() when it was written — or null when the installation did (the installer, a migration, an archive brought in). Written once and never changed: it is what companies_per_person counts on a shared installation, whoever owns the company today (decision 0065). No foreign key: it outlives the account, like the trail. |
| `invoice_accent_color` | `text` | The accent colour of this company's invoice PDF, written #rrggbb: the title, the rules and the bands of the layout. Null is the default of @ekwo-ai/invoice-pdf. |
| `invoice_logo_position` | `text` | The side of this company's invoice PDF its logo is printed on: left or right. Null is the default of @ekwo-ai/invoice-pdf (left). |
| `identifiers` | `jsonb` | not null — Every identifier of the company that has no column of its own, by the code of its scheme: {"<scheme>": "<identifier>"}. The scheme is the code the register or the e-invoicing format of the country names it by — a tax identification number, a registration for a tax that is not a VAT — and the country pack says which ones its format reads. vat_number and registration_number keep their own columns and are not repeated here. Empty, not null, where there is none. |
| `activity_description` | `text` | The company's own words for its activity, beside activity_code and activity_scheme. A format that carries the code of the activity carries its description too, and the description of a register's code is not always the words the company uses. |
| `archived_at` | `timestamp with time zone` | When the owner archived the company; null while its books are kept. An archived company is read-only for the ledger: posting an entry, booking a document or a payment and closing a year are refused with company_archived, while reading, exporting, the members and the profile stay available. Set by archive_company() and cleared by unarchive_company(), never written by hand. |
| `number_format` | `text` | This company's pattern of a document number, in the grammar of country_defaults.number_format: {CODE}, {YYYY} or {YY}, {MM}, {N...}. Carries {CODE}. Null keeps the pattern of the country pack. |
| `invoice_typeface` | `text` | The pair of typefaces of this company's invoice PDF, by the name @ekwo-ai/invoice-pdf embeds it under: elegant (Inter, with Fraunces for the title, the names and the headings) or classic (Noto Sans). Null is the default, elegant. |
| `agent_posting` | `text` | not null — How an agent — a machine key, or the MCP server — books a document of this company: review (the default), once a person has approved the draft as it stands (approve_document()), unless the session opted into autopilot; autopilot, directly, within the capabilities it holds; review_only, as review, and no session may opt into autopilot. A person signed in posts as before in all three. Written with company.write; an agent may only make it stricter. |
| `invoice_late_payment_mention` | `boolean` | not null — Whether this company's sale invoices to a business print the late payment mention of its country pack (legal_mention_templates.applies_when = late_payment). True by default; never on a credit note, nor on an invoice to a consumer (contacts.is_company false), whatever it says. |

Constraints:

- `CHECK ((agent_posting = ANY (ARRAY['review'::text, 'autopilot'::text, 'review_only'::text])))`
- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `CHECK ((currency_code ~ '^[A-Z]{3}$'::text))`
- `CHECK (((peppol_scheme IS NULL) = (peppol_identifier IS NULL)))`
- `CHECK ((fiscal_country ~ '^[A-Z]{2}$'::text))`
- `CHECK (((jsonb_typeof(identifiers) = 'object'::text) AND (NOT (identifiers ? ''::text)) AND (NOT jsonb_path_exists(identifiers, '$.*?(@.type() != "string" || @ like_regex "^\\s*$")'::jsonpath))))`
- `CHECK ((invoice_accent_color ~ '^#[0-9A-Fa-f]{6}$'::text))`
- `CHECK ((invoice_logo_position = ANY (ARRAY['left'::text, 'right'::text])))`
- `CHECK ((invoice_typeface = ANY (ARRAY['classic'::text, 'elegant'::text])))`
- `CHECK ((btrim(number_format) <> ''::text))`
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

### `company_tax_regimes`

The regime of turnover_tax_regimes a company is under, from the first day of a financial year to the last day of one, or open-ended. No row: the company is under the ordinary regime of its taxes (decision 0080).

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `regime_code` | `text` | not null |
| `valid_from` | `date` | not null |
| `valid_to` | `date` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, valid_from)`

### `company_vat_schemes`

The VAT scheme a company is on, from the first day of a financial year until the next row. No row: the company has not said, and files exactly as it did before schemes existed — no default and no guess. The forms and cadences it implies are written into company_filing_periods, which stays the one place a cadence is recorded.

| Column | Type | Notes |
|---|---|---|
| `company_id` | `uuid` | not null |
| `valid_from` | `date` | not null |
| `country` | `character(2)` | not null — The country of the scheme: the company's fiscal country, written by the trigger, so the scheme is a foreign key and a pack upgrade cannot remove one a company is on. |
| `scheme_code` | `text` | not null |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `PRIMARY KEY (company_id, valid_from)`

### `contact_merges`

Every merge of two contacts, by merge_contacts() (decision 0074): the contact absorbed, the one kept, who merged them and when, what moved and what was filled. Written by merge_contacts() and by nothing else — no role may insert — so the guards of a posted line and of an issued document read a row here, written in the same transaction, as the exemption that lets contact_id move from the absorbed contact to the kept one.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `kept_id` | `uuid` | not null — The contact that took the history. It may itself be merged later; contacts.merged_into then follows, and this row keeps saying what happened. |
| `absorbed_id` | `uuid` | not null — The contact retired by the merge. Absorbed once: a merged contact is not merged again. |
| `moved` | `jsonb` | not null — What moved onto the kept contact, table by table, with the number of rows: every foreign key to contacts, the branches (contacts.parent_id), the files (attachments), the learned motifs moved (contact_patterns) and folded into one the kept contact had (contact_patterns_folded). |
| `filled` | `text[]` | not null — The fields of the kept contact that were empty and were taken from the absorbed one. |
| `merged_by` | `uuid` | Who merged: the signed-in user, or the person who issued the machine key presented (acting_user()); null for the installer. |
| `merged_at` | `timestamp with time zone` | not null |
| `transaction_id` | `bigint` | not null — The transaction that merged, the only one in which the guards honour this row. |

Constraints:

- `CHECK ((kept_id <> absorbed_id))`
- `PRIMARY KEY (id)`

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
| `merged_into` | `uuid` | The contact this one was merged into by merge_contacts(), which moved every reference of this one onto it (decision 0074). Null for a contact in use. A merged contact is inactive, stays as the record of what was imported, and is named by no row again. |
| `analytic_value_id` | `uuid` | The analytic value the lines of a document naming this contact start with, at 100 %, on an axis the product left free; a contact that has none takes its parent's, one level up. Pre-fills the line, never constrains it. |
| `identifiers` | `jsonb` | not null — Every identifier of the party that has no column of its own, by the code of its scheme: {"<scheme>": "<identifier>"}, as companies.identifiers. Empty, not null, where there is none. |

Constraints:

- `CHECK (((client_ref IS NULL) OR ((client_ref = btrim(client_ref)) AND ((length(client_ref) >= 1) AND (length(client_ref) <= 200)))))`
- `CHECK (((country IS NULL) OR (country ~ '^[A-Z]{2}$'::text)))`
- `CHECK (((jsonb_typeof(identifiers) = 'object'::text) AND (NOT (identifiers ? ''::text)) AND (NOT jsonb_path_exists(identifiers, '$.*?(@.type() != "string" || @ like_regex "^\\s*$")'::jsonpath))))`
- `CHECK (((merged_into IS NULL) OR ((merged_into <> id) AND (NOT active))))`
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
| `bank_account_scheme` | `text` | How a bank of this country identifies an account: iban, aba-routing-account, sort-code-account, bsb-account, ifsc-account, clabe, zengin, transit-institution-account. From the pack. Null where the pack declares none, which clients read as a free-text account number and never as an IBAN. |
| `einvoice_fiscalisation` | `jsonb` | The fiscalisation regime of the country, as its pack declares it in einvoicing.fiscalisation and `ekwo pack build` normalises it: kind (chained: a record per invoice, chained by its hash; reporting: the documents' data reported, nothing chained, hash null), format (the brick that writes the record or the report), mandatory_from (always a list of {who, from}, empty while the obligation is only announced), announced_from, announced_by, announced_on, hash, qr, mention, submission (with channel and cadence), events, reported, tax_attributes, legal_reference, source. Null where the country has no such regime. Read by the einvoicing module, which keeps the chain of a chained regime. |
| `final_close_due` | `text` | Whether this country requires a final close of every fiscal year, and by when: before_next_fiscal_year_ends, or null where the pack says nothing and the final close is offered without being asked for. fiscal_year_final_close() is the function that reads it. |
| `final_close_legal_reference` | `text` | The article that requires the final close, as the pack cites it. |
| `final_close_source_key` | `text` | Key of the entry in the pack's source register where that article is read. |
| `tax_payee_name` | `text` | The administration a declaration of this country is paid to, by its official name in the pack's language — the payee of the debt settle_filing() carries to tax_payable_code. tax_payee() creates the company's contact for it under this name. Null until a pack names one, and then a settlement names nobody unless a contact already books to that account. |
| `tax_payee_source_key` | `text` | The key of the entry of the pack's source register where the administration's name is read. |
| `tax_payee_name_i18n` | `jsonb` | not null — The name of the administration in tax_payee_name, by language, as the administration publishes it in each language of the pack. tax_payee() creates the contact under the company's language here, else under tax_payee_name. |

Constraints:

- `CHECK ((cash_rounding_unit >= (0)::numeric))`
- `CHECK (((einvoice_fiscalisation IS NULL) OR ((jsonb_typeof(einvoice_fiscalisation) = 'object'::text) AND (jsonb_typeof((einvoice_fiscalisation -> 'format'::text)) = 'string'::text) AND (COALESCE(jsonb_typeof((einvoice_fiscalisation -> 'hash'::text)), 'null'::text) = ANY (ARRAY['object'::text, 'null'::text])) AND (COALESCE(jsonb_typeof((einvoice_fiscalisation -> 'announced_from'::text)), 'null'::text) = ANY (ARRAY['string'::text, 'null'::text])) AND (COALESCE(jsonb_typeof((einvoice_fiscalisation -> 'kind'::text)), 'null'::text) = ANY (ARRAY['string'::text, 'null'::text])) AND (jsonb_typeof((einvoice_fiscalisation -> 'submission'::text)) = 'object'::text) AND (jsonb_typeof((einvoice_fiscalisation -> 'legal_reference'::text)) = 'string'::text))))`
- `CHECK (
CASE einvoice_obligation
    WHEN 'mandatory'::text THEN (einvoice_mandatory_from IS NOT NULL)
    WHEN 'on_request'::text THEN (einvoice_mandatory_from IS NULL)
    WHEN 'none'::text THEN (einvoice_mandatory_from IS NULL)
    ELSE true
END)`
- `CHECK (((einvoice_obligation IS NULL) OR (einvoice_obligation = ANY (ARRAY['mandatory'::text, 'on_request'::text, 'none'::text]))))`
- `CHECK (((final_close_due IS NULL) OR (final_close_due = 'before_next_fiscal_year_ends'::text)))`
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
| `certification_status` | `pack_certification` | not null — How much a pack has been read, printed by `ekwo init`: community (contributed, unread), maintained (by Ekwo, not yet reviewed), proven (it reproduced the accepted filing of a real company; the pack manifest carries the evidence), reviewed (by the professional named in certified_by). |
| `certified_by` | `text` | The professional who reviewed the pack. Only on a reviewed pack: maintaining is not reviewing. |
| `certified_at` | `date` |  |
| `checksum` | `text` | sha256 of the pack files, so a changed pack is visible without a diff. |
| `installed_at` | `timestamp with time zone` | not null |
| `sources` | `jsonb` | not null — Register of the texts this pack was built from, in the pack's own order: [{key, title, publisher, url, consulted_on, kind, reason_codes}]. `kind` is one of law, regulation, form, standard, portal, guidance. `reason_codes` is true on the one entry — at most one, and a `standard` — that publishes the list an exemption reason code of this country comes from; absent everywhere else. Written by the generated seed; never a copy of the text itself. |
| `evidence` | `jsonb` | not null — What a proven pack was proven on, in the pack's own order: [{scope, result, fiscal_year, filing, summary, checked_on}]. `result` is one of reproduced, partly_reproduced, not_tested. An entry names the kind of filing and never the company. Written by the generated seed of a pack that carries evidence; empty otherwise. |

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

### `declaration_instalments`

What a company paid on account of a declaration during its period: which instalment of the scheme's schedule, the day, the amount and the entry that carried it, where there is one. Several rows for one instalment are a payment made in parts. The annual return deducts them in the box whose reads is instalments_paid or instalments_due.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `report_code` | `text` | not null |
| `period_start` | `date` | not null |
| `period_end` | `date` | not null |
| `sequence` | `smallint` | not null |
| `paid_on` | `date` | not null |
| `amount` | `numeric(18,2)` | not null |
| `entry_id` | `uuid` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((amount > (0)::numeric))`
- `CHECK ((period_end >= period_start))`
- `CHECK ((sequence >= 1))`
- `PRIMARY KEY (id)`

### `document_line_analytics`

Analytic split of a document line, one row per value, share in percent. Copied onto the ledger line by post_document(); after posting the ledger split is the one read.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `document_line_id` | `uuid` | not null |
| `analytic_value_id` | `uuid` | not null |
| `percentage` | `numeric(7,3)` | not null |
| `amount` | `numeric(16,2)` | The share of the line's untaxed amount in the document's currency, derived by the database. The shares of one axis are rounded in the order of their codes, so a whole split adds up to its line. |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (((percentage > (0)::numeric) AND (percentage <= (100)::numeric)))`
- `PRIMARY KEY (id)`
- `UNIQUE (document_line_id, analytic_value_id, company_id)`

### `document_lines`

Lines of a document. A product line carries its base, its account and its tax (tax_id); the tax itself is written by the posting on the account the tax points to, and a line on such an account is refused (trigger document_lines_guard_tax_account).

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
| `attributes` | `jsonb` | not null — What an electronic invoice format asks of this line that no other column says, by the name the format's brick reads: {"<name>": "<value>"}, as products.attributes. Wins over the country pack's line_attributes and tax_attributes for this line. Pre-filled from the product with the names the line does not carry; frozen with the document once posted. Empty, not null, where there is none. |
| `base_includes_tax` | `boolean` | not null — The tax of this line is computed inside its own base. Derived from the tax while the document is a draft and kept when it is posted, like unit_price_includes_tax, so a later change to the tax cannot rewrite an invoice that has been sent. |

Constraints:

- `CHECK (((jsonb_typeof(attributes) = 'object'::text) AND (NOT (attributes ? ''::text)) AND (NOT jsonb_path_exists(attributes, '$.*?(@.type() != "string" || @ like_regex "^\\s*$")'::jsonpath))))`
- `CHECK (((NOT base_includes_tax) OR (tax_id IS NOT NULL)))`
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
| `contact_id` | `uuid` | The customer of a sale, the supplier of a purchase. Null only on a draft nobody has read yet — a purchase document sent from a phone (receive_purchase_document()) — and named before the document leaves draft (documents_need_a_contact()). |
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
- `CHECK (((state = 'draft'::doc_state) OR (contact_id IS NOT NULL)))`
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
| `amount` | `numeric(16,2)` | The share of the line's balance (debit minus credit) in the company's currency, derived by the database. The shares of one axis are rounded in the order of their codes, so a whole split adds up to its line. |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (((percentage > (0)::numeric) AND (percentage <= (100)::numeric)))`
- `PRIMARY KEY (id)`
- `UNIQUE (entry_line_id, analytic_value_id, company_id)`

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
| `declared_on` | `date` | not null — The day this line counts for a tax return: its tax_point_date where the posting engine worked one out, the date of its entry otherwise (declared_on_of()). Written by the trigger entry_lines_set_declared_on on every insert and on every change of what it derives from — never typed: a value written by hand on a draft is replaced by the rule's, and on a posted line refused by entry_lines_guard_posted. The period of a return is read on this column, through declared_lines(). |
| `declaration_boxes` | `text[]` | Every box of the declaration this line is summed into, frozen when the line was written from the posting that wrote it: declaration_boxes_of() of its tax, its box and its side. Its first element is not necessarily declaration_box; the list is sorted. Null exactly where declaration_box is, except on a line restored from an archive written before 20261011160431, which vat_return() reads through the postings of today. Written by entry_lines_box_from_posting(), never by hand. |
| `report_code` | `text` | The declaration form the posting that wrote this line is on, frozen with declaration_boxes. Null where the posting names no form, which is the single return of a country that files one. |

Constraints:

- `CHECK (((debit >= (0)::numeric) AND (credit >= (0)::numeric)))`
- `CHECK (((matched_amount >= (0)::numeric) AND (matched_amount <= abs((debit - credit)))))`
- `CHECK (((debit = (0)::numeric) OR (credit = (0)::numeric)))`
- `CHECK (((posting_type IS NULL) OR (tax_id IS NOT NULL)))`
- `PRIMARY KEY (id)`

### `filing_proofs`

Proofs that a file existed at a date: the sha256 of its exact bytes, committed to a public ledger, with the proof that it was. Written through record_filing_proof() and upgrade_filing_proof(); a complete proof is frozen. filing_proof(sha256) is the public way to read one.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `subject_kind` | `filing_proof_subject` | not null |
| `tax_filing_id` | `uuid` |  |
| `fiscal_year_id` | `uuid` |  |
| `document_id` | `uuid` |  |
| `attachment_id` | `uuid` |  |
| `sha256` | `text` | not null — sha256 of the exact bytes of the file proved, hex. The file itself never leaves: only this hash is submitted. |
| `values_sha256` | `text` | sha256 of the figures in canonical form (canonical_json, one line per row), so the figures can be matched without the file. Computed by tax_filing_values_sha256() for a declaration; given by the caller otherwise, or null. |
| `method` | `filing_proof_method` | not null |
| `status` | `filing_proof_status` | not null |
| `proof` | `bytea` | not null — The proof, as bytes: a detached OpenTimestamps file (.ots) for opentimestamps, the signed attestation for eas. |
| `calendars` | `text[]` | The calendars an opentimestamps hash was submitted to. Recorded so a scheduled upgrade knows where to come back, and so a reader knows who aggregated it. |
| `anchor_chain` | `text` | The ledger the proof is anchored in, as its usual name: bitcoin for opentimestamps. |
| `anchor_height` | `bigint` | The block height the proof is anchored at, where the ledger has heights. |
| `anchor_time` | `timestamp with time zone` | The time of that block, as its header states it. The proof says the file existed no later than this. |
| `anchor_reference` | `text` | An identifier on the ledger where a height is not the natural one: the uid of an attestation, a transaction hash. |
| `created_by` | `uuid` | auth.users.id of whoever recorded the proof. No foreign key, for the same reason company_members has none. |
| `created_at` | `timestamp with time zone` | not null |
| `upgraded_at` | `timestamp with time zone` |  |
| `completed_at` | `timestamp with time zone` |  |

Constraints:

- `CHECK (((anchor_height IS NULL) OR (anchor_height >= 0)))`
- `CHECK ((((status = 'complete'::filing_proof_status) = (completed_at IS NOT NULL)) AND ((status = 'pending'::filing_proof_status) OR ((anchor_chain IS NOT NULL) AND ((anchor_height IS NOT NULL) OR (anchor_reference IS NOT NULL))))))`
- `CHECK ((length(proof) > 0))`
- `CHECK ((sha256 ~ '^[0-9a-f]{64}$'::text))`
- `CHECK (((num_nonnulls(tax_filing_id, fiscal_year_id, document_id) = 1) AND ((subject_kind = 'tax_filing'::filing_proof_subject) = (tax_filing_id IS NOT NULL)) AND ((subject_kind = 'fiscal_year'::filing_proof_subject) = (fiscal_year_id IS NOT NULL)) AND ((subject_kind = 'document'::filing_proof_subject) = (document_id IS NOT NULL))))`
- `CHECK (((values_sha256 IS NULL) OR (values_sha256 ~ '^[0-9a-f]{64}$'::text)))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, sha256, method)`

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
| `finally_closed_at` | `timestamp with time zone` | When the year was finally closed by close_fiscal_year_finally(). Null for a year that is open or under an ordinary close. Once set, the year is never reopened, its dates never move and the stamp is never cleared — by anybody. |

Constraints:

- `CHECK ((end_date > start_date))`
- `CHECK (((finally_closed_at IS NULL) OR is_closed))`
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
| `shared` | `boolean` | not null — Whether this installation is shared by several unrelated people, each with companies of their own (decision 0065). Off by default: an installation is one customer's. |
| `companies_per_person` | `integer` | On a shared installation, how many companies one signed-in person may create and own. Null when the installation is not shared. |

Constraints:

- `CHECK (((companies_per_person IS NULL) OR ((companies_per_person >= 0) AND (companies_per_person <= 1000))))`
- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `CHECK (((public_base_url IS NULL) OR (public_base_url ~ '^https?://[^[:space:]]+$'::text)))`
- `CHECK (((registered_at IS NULL) OR (contact_email IS NOT NULL)))`
- `CHECK (((NOT shared) OR (companies_per_person IS NOT NULL)))`
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
| `number_prefix` | `text` | What {CODE} prints in the numbers this journal draws. Null prints the journal's code. The code itself is unchanged. |

Constraints:

- `CHECK ((code ~ '^[A-Z0-9]{2,8}$'::text))`
- `CHECK (((number_prefix = btrim(number_prefix)) AND (number_prefix <> ''::text) AND (length(number_prefix) <= 20) AND (number_prefix !~ '[{}]'::text)))`
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

### `lines_left_unnamed`

Open lines on a receivable or payable account that a person decided to leave without a contact, with the reason: suggest_line_contacts() no longer proposes them. Written by leave_line_unnamed(), removed by undo_leave_line_unnamed(). The line itself does not move and stays an open item (decision 0072).

| Column | Type | Notes |
|---|---|---|
| `line_id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `reason` | `text` | not null — Why the line names nobody, in the words of the person who decided it. |
| `created_by` | `uuid` | Who decided it: the signed-in user, or the person who issued the machine key presented (acting_user()). |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (((length(btrim(reason)) >= 1) AND (length(btrim(reason)) <= 500)))`
- `PRIMARY KEY (line_id, company_id)`

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
| `difference_tolerance_units` | `integer` | How many smallest units of the currency a set of lines may be apart and still be closed by reconcile_with_difference(), which books the difference. Its own number: amount_tolerance_units decides what is applied without anybody. |

Constraints:

- `CHECK ((amount_tolerance_units >= 0))`
- `CHECK ((date_window_days >= 0))`
- `CHECK ((difference_tolerance_units >= 0))`
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
| `analytic_value_id` | `uuid` | The analytic value a line filled in from this product starts with, at 100 %. Pre-fills the line, never constrains it. |
| `attributes` | `jsonb` | not null — What an electronic invoice format asks of a line selling this product that no other column says, by the name the format's brick reads: {"<name>": "<value>"} — the entry of a tax authority's list of goods and services, the reason of an exemption. The country pack says which names its format reads. A line filled in from the product takes the ones it does not carry. Empty, not null, where there is none. |

Constraints:

- `CHECK (((jsonb_typeof(attributes) = 'object'::text) AND (NOT (attributes ? ''::text)) AND (NOT jsonb_path_exists(attributes, '$.*?(@.type() != "string" || @ like_regex "^\\s*$")'::jsonpath))))`
- `CHECK ((length(btrim(code)) > 0))`
- `CHECK (((purchase_price IS NULL) OR (purchase_price >= (0)::numeric)))`
- `CHECK (((sale_price IS NULL) OR (sale_price >= (0)::numeric)))`
- `CHECK ((unit_code ~ '^[A-Z0-9]{1,3}$'::text))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, code)`

### `reconciliation_batches`

Matchings made in one gesture: reconcile_batch() writes the row and names it on every matching it wrote (reconciliations.batch_id); unreconcile_batch() undoes those still standing and says when and by whom. Written by those two functions alone (decision 0073).

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `pair_count` | `integer` | not null — How many pairs of lines the gesture matched. |
| `amount` | `numeric` | not null — The total matched, in the company's currency. |
| `created_by` | `uuid` | Who matched: the signed-in user, or the person who issued the machine key presented (acting_user()). |
| `created_at` | `timestamp with time zone` | not null |
| `undone_by` | `uuid` | Who undid it, as acting_user() said; null for the installer. |
| `undone_at` | `timestamp with time zone` | When unreconcile_batch() undid the gesture; null while it stands. |

Constraints:

- `CHECK ((amount > (0)::numeric))`
- `CHECK ((pair_count > 0))`
- `CHECK (((undone_by IS NULL) OR (undone_at IS NOT NULL)))`
- `PRIMARY KEY (id)`

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
| `adjustment_entry_id` | `uuid` | The entry reconcile_with_difference() posted for the difference, on the matchings of its third-party line. unreconcile() of one of them takes the entry back with its mirror (decision 0071). |
| `batch_id` | `uuid` | The gesture that made this matching, when reconcile_batch() made it; unreconcile_batch() undoes every matching that names it (decision 0073). |

Constraints:

- `CHECK ((amount > (0)::numeric))`
- `CHECK ((debit_line_id <> credit_line_id))`
- `PRIMARY KEY (id)`
- `UNIQUE (debit_line_id, credit_line_id, company_id)`

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
| `result_in_progress` | `text` | On a balance sheet: whether the line that receives the result of the year in progress also takes other balances (combined: the result brought forward, retained earnings, reserves) or is the result alone. A combined scheme shows the result in progress as a sub-line in financial_statement_of_kind(). Set by the pack and checked against its model by ekwo pack check; null on any other statement. |
| `result_in_progress_name` | `text` | The label of the sub-line of the result in progress, in the language of the pack. Set exactly when result_in_progress is combined. |
| `result_in_progress_name_i18n` | `jsonb` | not null — The same label in the other languages of the pack, by language code. |

Constraints:

- `CHECK (((chart_code IS NULL) OR (country IS NOT NULL)))`
- `CHECK (((country IS NULL) OR (country ~ '^[A-Z]{2}$'::text)))`
- `CHECK ((kind = ANY (ARRAY['balance_sheet'::text, 'income_statement'::text, 'cash_flow'::text, 'allocation'::text])))`
- `CHECK ((result_in_progress = ANY (ARRAY['combined'::text, 'alone'::text])))`
- `CHECK (((result_in_progress IS NULL) OR (kind = 'balance_sheet'::text)))`
- `CHECK (
CASE
    WHEN (result_in_progress = 'combined'::text) THEN (result_in_progress_name IS NOT NULL)
    ELSE (result_in_progress_name IS NULL)
END)`
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

One send of a declaration and what came back. Written only by file_filing(), record_filing_outcome() and record_filing_files(); read under filings.read.

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
| `due_date` | `date` | The day the declaration of this period is due: filing_deadline() of its form and its last day, written by prepare_filing() and copied by supersede_filing(). Null where the pack names no rule for the form, or names depends_on_taxpayer. The maturity of the debt settle_filing() posts. |
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
| `from_boxes` | `text[]` | not null — On a form that reads the postings of another (tax_report_templates.reads_postings_of): the boxes of that form this base or tax box adds up, as the pack writes them — "08:base", or bare for every kind of the box. Empty on every box of a form that reads its own postings. |
| `reads` | `text` | A tax box whose figure is the payments on account of this declaration rather than the ledger: instalments_paid, what declaration_instalments records as paid for the period; instalments_due, what instalment_plan() says was due, or what was paid where that is more. Null on every box summed from the ledger or computed. |

Constraints:

- `CHECK (((kind = 'total'::text) OR ((plus_boxes = '{}'::text[]) AND (minus_boxes = '{}'::text[]))))`
- `CHECK (((cardinality(from_boxes) = 0) OR (reads IS NULL)))`
- `CHECK ((kind = ANY (ARRAY['base'::text, 'tax'::text, 'total'::text])))`
- `CHECK (((kind <> 'total'::text) OR ((cardinality(from_boxes) = 0) AND (reads IS NULL))))`
- `CHECK (((rate IS NULL) OR (kind = 'total'::text)))`
- `CHECK (((rate_of_box IS NULL) OR (split_part(rate_of_box, ':'::text, 1) <> box)))`
- `CHECK (((rate IS NULL) = (rate_of_box IS NULL)))`
- `CHECK (((rate IS NULL) OR ((plus_boxes = '{}'::text[]) AND (minus_boxes = '{}'::text[]))))`
- `CHECK ((reads = ANY (ARRAY['instalments_paid'::text, 'instalments_due'::text])))`
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
| `role` | `text` | What the form is to the companies that file it, from packs/<cc>/tax_report.json: periodic, the return the tax postings are for, or annual, a return filed once a year beside it or instead of it under a scheme that says so. Null where the pack carries one form and says nothing, which is_periodic_return already answers; when set it agrees with is_periodic_return. |
| `reads_postings_of` | `text` | The form of the same country whose postings this one adds up, for a form that restates on lines of its own what another form's boxes received — an annual return over the boxes of the monthly one. Null: the form reads the postings made for it. Each box then names the boxes it adds up in from_boxes. |

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
- `CHECK (((reads_postings_of IS NULL) OR (reads_postings_of <> code)))`
- `CHECK ((role = ANY (ARRAY['periodic'::text, 'annual'::text])))`
- `CHECK (((role IS NULL) OR ((role = 'periodic'::text) = is_periodic_return)))`
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
| `base_includes_tax` | `boolean` | not null — The taxable base of this tax contains the tax itself. Compiled from the pack and copied onto the tax a company installs. Decision 0077. |

Constraints:

- `CHECK (((NOT base_includes_tax) OR ((amount_type = 'percent'::tax_amount_type) AND (amount < (100)::numeric))))`
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
| `base_includes_tax` | `boolean` | not null — The taxable base of this tax contains the tax itself: on a net amount N at rate r the tax is N x r / (100 - r), and on a price that holds it the tax is the price x r / 100. The rate is the rate of the law. Only a percentage below 100 may say so. Decision 0077. |

Constraints:

- `CHECK (((NOT base_includes_tax) OR ((amount_type = 'percent'::tax_amount_type) AND (amount < (100)::numeric))))`
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

### `turnover_tax_assessments`

The tax on turnover of a period as post_turnover_tax() computed and posted it: the figures of turnover_tax_return() as they were, the entry that booked the tax (null for a period that owed nothing) and the filing it prepared. Written by that function and by nothing else.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `regime_code` | `text` | not null |
| `period_start` | `date` | not null |
| `period_end` | `date` | not null |
| `turnover` | `numeric(18,2)` | not null |
| `window_turnover` | `numeric(18,2)` | not null |
| `window_months_counted` | `integer` | not null |
| `base` | `numeric` | not null |
| `bracket_sequence` | `integer` | not null |
| `nominal_rate` | `numeric(9,4)` | not null |
| `deduction` | `numeric(18,2)` | not null |
| `effective_rate` | `numeric` | not null |
| `tax` | `numeric(18,2)` | not null |
| `entry_id` | `uuid` |  |
| `filing_id` | `uuid` |  |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `PRIMARY KEY (id)`
- `UNIQUE (company_id, regime_code, period_start, period_end)`

### `turnover_tax_brackets`

The brackets of a regime of turnover_tax_regimes, dated: the highest base each takes (inclusive; null for the last), its nominal rate in percent and the deduction subtracted from base x rate. The tax of a period is its turnover x (base x nominal_rate / 100 - deduction) / base, the base being the window's turnover. A flat rate is one bracket with no threshold and no deduction.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `regime_code` | `text` | not null |
| `valid_from` | `date` | not null |
| `valid_to` | `date` |  |
| `sequence` | `integer` | not null |
| `up_to` | `numeric(18,2)` |  |
| `nominal_rate` | `numeric(9,4)` | not null |
| `deduction` | `numeric(18,2)` | not null |
| `legal_reference` | `text` | not null |
| `source_key` | `text` |  |

Constraints:

- `CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))`
- `CHECK ((deduction >= (0)::numeric))`
- `CHECK (((nominal_rate >= (0)::numeric) AND (nominal_rate < (100)::numeric)))`
- `CHECK (((up_to IS NULL) OR (up_to > (0)::numeric)))`
- `PRIMARY KEY (country, regime_code, valid_from, sequence)`

### `turnover_tax_regimes`

A regime of a country where one tax on turnover replaces the kinds of tax it names, compiled from the pack's turnover_tax.json: the form it is declared on, the window its bracket is read over, the account its tax is an expense on and the article that sets it (decision 0080).

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `replaces` | `tax_kind[]` | not null — The kinds of tax a company under the regime neither charges nor recovers. A document line carrying a tax of one of them is refused at posting. |
| `report_code` | `text` | not null |
| `window_months` | `smallint` | The months of turnover the bracket is read over — twelve for a regime graded on the trailing year. Null: the bracket is read on the turnover of the period itself. |
| `window_includes_period` | `boolean` | not null — The window ends with the period declared, rather than with the month before it. |
| `short_window` | `text` | not null — What the window of a company active for fewer months than it counts becomes: annualise (the turnover of the months it has, times window_months over their number; the period's own when it has none) or as_is (the turnover it has). |
| `expense_account_code` | `text` | not null |
| `legal_reference` | `text` | not null |
| `source_key` | `text` |  |
| `sequence` | `integer` | not null |

Constraints:

- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `CHECK ((cardinality(replaces) > 0))`
- `CHECK ((short_window = ANY (ARRAY['annualise'::text, 'as_is'::text])))`
- `CHECK (((window_months IS NULL) OR ((window_months >= 1) AND (window_months <= 60))))`
- `CHECK (((window_months IS NOT NULL) OR (NOT window_includes_period)))`
- `PRIMARY KEY (country, code)`

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

### `vat_scheme_ceilings`

Up to which amount a company may be on a scheme: a measure from a closed vocabulary, the part of the activity it is counted on, an amount in a currency, the dates it applies between and the article that sets it. Read by vat_scheme_ceilings_crossed(), an alert; nothing moves a company from one scheme to another by itself.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `scheme_code` | `text` | not null |
| `sequence` | `integer` | not null |
| `measure` | `text` | not null |
| `activity` | `text` | not null |
| `amount` | `numeric(18,2)` | not null |
| `currency_code` | `character(3)` | not null |
| `valid_from` | `date` | not null |
| `valid_to` | `date` |  |
| `legal_reference` | `text` | not null |
| `source_key` | `text` |  |

Constraints:

- `CHECK ((activity = ANY (ARRAY['all'::text, 'goods'::text, 'services'::text])))`
- `CHECK ((amount > (0)::numeric))`
- `CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))`
- `CHECK ((measure = ANY (ARRAY['turnover_previous_year'::text, 'turnover_current_year'::text, 'tax_previous_year'::text])))`
- `PRIMARY KEY (country, scheme_code, sequence)`

### `vat_scheme_forms`

The declaration forms a company on a scheme files, each on the cadences the scheme allows. A form of the country that no scheme names is outside every scheme and is filed as before; a form some scheme names is filed only under the schemes that name it.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `scheme_code` | `text` | not null |
| `report_code` | `text` | not null — A form of tax_report_templates of the same country. Not a foreign key, for the reason company_filing_periods gives: the pack writes its forms and its schemes in one seed, in that order. |
| `periods` | `declaration_period[]` | not null |
| `period_default` | `declaration_period` |  |

Constraints:

- `CHECK (((period_default IS NULL) OR (period_default = ANY (periods))))`
- `CHECK ((cardinality(periods) >= 1))`
- `PRIMARY KEY (country, scheme_code, report_code)`

### `vat_scheme_instalments`

The payments on account a scheme asks for during the year a return covers: in which month (and on which day, where the law gives one to everybody), which percentage of which box of the previous period's return, and the base below which nothing is due. instalment_plan() reads it.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `scheme_code` | `text` | not null |
| `sequence` | `smallint` | not null |
| `report_code` | `text` | not null |
| `due_month` | `smallint` | not null |
| `due_day` | `smallint` | Null where the day of the month depends on the taxpayer; the instalment is then listed with its month and no date. |
| `percent` | `numeric(9,4)` | not null |
| `base_report_code` | `text` | not null |
| `base_box` | `text` | not null |
| `base_kind` | `text` | not null |
| `minimum_base` | `numeric(18,2)` |  |
| `legal_reference` | `text` | not null |
| `source_key` | `text` |  |

Constraints:

- `CHECK ((base_kind = ANY (ARRAY['base'::text, 'tax'::text, 'total'::text])))`
- `CHECK (((due_day IS NULL) OR ((due_day >= 1) AND (due_day <= 31))))`
- `CHECK (((minimum_base IS NULL) OR (minimum_base >= (0)::numeric)))`
- `CHECK (((due_month >= 1) AND (due_month <= 12)))`
- `CHECK (((percent > (0)::numeric) AND (percent <= (100)::numeric)))`
- `PRIMARY KEY (country, scheme_code, sequence)`

### `vat_schemes`

The VAT schemes of a country, compiled from packs/<cc>/vat_schemes.json: the fact that decides which declaration forms a company files at all. A country with no row has no scheme, and its companies file as they always did.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `charges_vat` | `boolean` | not null — False under a small business exemption: a company on the scheme charges no VAT on its sales, which are refused at posting if they carry any, recovers none, and its invoices carry the mention of legal_mention_templates whose applies_when is small_business. |
| `legal_reference` | `text` | not null |
| `source_key` | `text` |  |
| `sequence` | `integer` | not null |

Constraints:

- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `PRIMARY KEY (country, code)`

## Functions

| Function | Purpose |
|---|---|
| `accept_invitation(p_token text)` | Turns an invitation into a membership for the signed-in user, whose address has to be the one invited. Single use, and refused once expired. |
| `account_carries_analytics(p_account_id uuid)` | Whether a line on this account may carry an analytic split: an income or expense account (accounts.internal_group), or a fixed asset (account type asset_fixed). Read from the account type the pack gives the account, never from its code. |
| `account_id_by_code(p_company_id uuid, p_code text)` | Account of a company by its code, or NULL. |
| `account_key(p_account text)` | A bank account as two of them are compared: without spaces, upper case; null when nothing is left. Read by contact_candidates() and suggest_duplicate_contacts(). |
| `account_rule_catches(p_rule_kind text, p_code_from text, p_code_to text, p_rule_type account_type, p_side text, p_code text, p_account_type account_type, p_balance numeric)` | Whether a rule takes an account with this code, type and balance: by one code, by the head of the code, by a range of heads or by account type, on the side the rule names. The one spelling of that test, read through statement_rule_catches() by the statements and directly by financial_analysis(). |
| `accounts_guard_frozen()` | Refuses a change of code or of account_type on an account that carries ledger lines, is named by a tax posting or plays a company role. The label, the translations, the parent, reconcilable, deprecated and pinned stay editable. |
| `accounts_in_use(p_company_id uuid, p_from date, p_to date)` | The accounts of a company that are in use: moved by a posted entry in the period — ever, when no period is given — or referenced by the configuration of the company — a role default, a contact override, a journal, a tax posting, a cash-basis transition, a bank account, a product — or held by a module the company has enabled, or pinned. Deprecated accounts are left out. A configuration reference is not dated; only the movement is. This is a reading: nothing here restricts what may be booked. |
| `acting_user()` | The person a write is recorded against: the signed-in user, or the person who issued the machine key presented in this transaction (api_keys.created_by). Null on a direct connection and for a key the installation issued itself. It attributes and never authorises: what a key may do is still has_capability(), and auth.uid() stays null for a key. |
| `aged_balance(p_company_id uuid, p_at date, p_group text)` | Ageing of what is still open, read from the ledger and from the matching, written at the decimals of the company's currency. Two groups, receivable and payable; anything else is refused by name. |
| `agent_call()` | Whether this transaction is an agent's: a machine key is presented (current_api_key()), or the MCP server marked it — the setting ekwo.agent on a direct connection, the header X-Ekwo-Agent through PostgREST. Decides how a document is posted under companies.agent_posting. |
| `agent_mark(p_name text)` | What the MCP server says of this transaction: the setting ekwo.<name> on a direct connection, the header X-Ekwo-<Name> through PostgREST. agent is the mark of an agent and its session's posting mode, agent_session the name of its session. For a request made with a machine key, the posting mode is the key's (api_keys.posting_mode) and this mark is ignored. |
| `agent_posting_mode(p_company_id uuid)` | The mode an agent's posting in this transaction meets in a company: autopilot for a machine key issued in autopilot, and for a session that chose it (the mark agent); review for a session that chose review; the company's agent_posting otherwise — for a key issued in review whatever its request's mark says. Review in a company that is review_only, and autopilot_forbidden when the key or the session is in autopilot there. Null for a company the caller cannot see. |
| `amount_text_format(p_rounding money_rounding)` | The to_char mask an amount of this currency is written with. Two decimals for the euro, none for the yen, three for the dinar. |
| `analytic_axis_required_for(p_required_on text, p_group text)` | Whether an axis required on p_required_on (analytic_axes.required_on) is required on a line of the account group p_group (accounts.internal_group). |
| `analytic_refresh_document_line(p_line_id uuid)` | Writes the amount of every share of a document line's split from its untaxed amount, rounded at the document's currency, cumulated in the order of the value codes on each axis. |
| `analytic_refresh_entry_line(p_line_id uuid)` | Writes the amount of every share of a ledger line's split from its balance (debit minus credit) in the company's currency, cumulated in the order of the value codes on each axis. |
| `analytic_report(p_company_id uuid, p_axis_id uuid, p_from date, p_to date)` | The result of each value of an analytic axis over a period, read from the posted ledger, in the company's currency. One row per value a share of the axis reaches, itself or below it (row_kind value), in the order of the tree, with level its depth: income, expense, result and fixed_assets (the net movement of the fixed-asset accounts, ordinary entries only) of the value and every value below it; the direct_ columns hold its own amount alone. Then row_kind unassigned, the part no share of the axis reaches, and total, the whole income statement of the period and the whole movement of the fixed assets. The direct_ columns of the values and the unassigned row add up to the total, closing entry left out. Refuses unknown_company, not_allowed (entries.read and settings.read), invalid_period and unknown_analytic_axis. |
| `api_key_on_company(p_company_id uuid)` | Whether the machine key presented in this transaction reaches anything on this company — at least one capability of its list that key_holds() still grants there. What is_company_member() asks for a key. False, never NULL, and false without a key. |
| `approve_document(p_document_id uuid)` | A person who may post a draft approves it, as it stands, for an agent to post in review: writes a document_approved row on the audit trail naming document_version(). A change to the draft afterwards voids it. Refused to an agent or a machine key (approval_by_a_person), without documents.post (not_allowed), and on a document that is not a draft. Returns the version approved. |
| `archive_company(p_company_id uuid)` | Archives a company: its books become read-only for the ledger, while reading, exporting, the members and the profile stay available. The act of the owner preset, refused to everybody else with not_allowed. Archiving a company that is already archived changes nothing and answers the row. Writes company_archived on the trail. |
| `archive_statement_timeout()` | The statement_timeout a request is given when it carries a whole company: export_company(), its manifest and tables, and import_company(). Applied by ekwo_pre_request(), only ever upwards. |
| `archive_under_current_names(p_archive jsonb)` | The archive with its tables and its manifest filed under the names of today: a `public.<table>` of the socle read as `ekwo.<table>`, then a former name of a module (`<schema>.archive_former_names()`) read as its current one. An archive carrying one table under two names is refused. |
| `assert_analytic_account(p_account_id uuid, p_what text)` | Refuses analytic_not_on_this_account unless account_carries_analytics() says the account carries a split: income, expense or fixed asset, from its account type. Read by the guards of document_line_analytics and entry_line_analytics. |
| `assert_analytic_value_in_use(p_value_id uuid, p_company_id uuid, p_what text)` | Refuses analytic_value_retired when the value is retired (analytic_values.active = false). Read by the guards of document_line_analytics and entry_line_analytics on a new share. |
| `assert_classifications(p_company_id uuid, p_attributes jsonb, p_what text)` | Refuses classification_code_invalid when an attribute whose name is a classification of the company's fiscal country, in classification_schemes, holds a code off its pattern. Attributes of any other name pass. The one check of the classifications held in products.attributes and document_lines.attributes. |
| `assert_company_live(p_company_id uuid)` | Raises company_archived while companies.archived_at is set. Asked by the guards of the acts that write a posted entry — posting an entry, booking a document or a payment, an entry of a module, closing or re-opening a year — once the capability of the caller has been checked. |
| `assert_document_analytic_axes(p_document_id uuid)` | Refuses analytic_axis_required when a billable line of the document, on an account of a group an active axis is required on (analytic_axes.required_on), carries less than 100 % of that axis. A credit note naming what it undoes is not asked. Called by post_document() before it writes the entry. |
| `assert_may_export_company(p_company_id uuid)` | The two conditions of leaving: company.export on the company, and a caller that row level security applies to. Invoker, so `current_user` is the role that asked. |
| `assert_period_open(p_company_id uuid, p_date date, p_is_tax boolean)` | Raises when a date is protected by a lock date or a closed fiscal year. |
| `assert_references_within_company(p_schema text)` | Raises reference_across_companies, naming every table and column and how many rows, when a row of the schema names a row of another company by a key scope_references_to_company() is about to make composite. One anti-join per key, run before anything changes. For migrations (decision 0065). |
| `assert_writes_into_known_company(p_company_id uuid)` | Refuses a person or a machine key who writes a row into a company they may not know of (may_know_of_company()), with one answer whether the company exists or not. Called by the definer guards before they read anything for that row. The backend role, the owner and the installer are neither, and pass: the guard then runs for them in full (decision 0065). |
| `attachment_is_filing_deposit_file(p_attachment_id uuid)` | Whether a deposit of a declaration names this attachment as the file that was sent or as the receipt. Definer, because the policy of attachments asks it for callers who may not read the deposits — which is the case it exists for; it answers about one id and nothing else, and about a company the caller may not know of as about nobody (decision 0065). |
| `attachments_guard_document()` | Refuses a file on an entry that a document posted: the invoice or receipt is the piece of the document, and goes on it (entity_type = document). An entry no document posted keeps its own pieces. |
| `audit_changes()` | The generic audit trigger. One jsonb argument names the company column, the natural key, the columns to redact and the acts an insert or a delete stands for. |
| `audit_entry_posting()` | Records that an entry was posted, cancelled, or posted as the reversal of another. The lines themselves are not audited: a posted entry is immutable and is corrected by a reversal. |
| `audit_log_is_append_only()` | Refuses every update and every delete on audit_log to any role a grant reaches — no client holds those verbs, and this refuses them again. A delete passes only while ekwo.audit_purge names a date, for a row older than it, by the owner of the table, which is how purge_audit_log() runs. The owner can disable this trigger: it keeps clients from rewriting the history, not the owner of the database. |
| `audit_log_purge_is_recorded()` | Writes audit_log_purged after every delete on audit_log — the cutoff, the number of rows and the login — whether it came through purge_audit_log() or not. A trigger of its own, so switching the guard off by name leaves it on. |
| `audit_log_refuses_truncate()` | Refuses TRUNCATE on audit_log, which a row trigger never sees. |
| `audit_record(p_company_id uuid, p_table text, p_record_id uuid, p_record_key text, p_operation audit_operation, p_action text, p_old jsonb, p_new jsonb)` | Writes one row of the audit trail. Called by the triggers of this schema and by the functions that perform an act; never by a client. |
| `audit_state_change()` | Records the act a state column stands for — a document posted, a payment booked, a year closed — with the fields that identify the row and never the whole of it. |
| `authenticated_statement_timeout()` | The statement_timeout configured for the role `authenticated` on this database, or NULL when none is. Definer because the catalogue of role settings is not every role's to read; it answers that one value and nothing else. |
| `auto_settle(p_company_id uuid, p_from date, p_to date, p_apply boolean)` | Walks the pending statement lines of a period and settles the ones a single piece of evidence identifies — a reference, or an exact amount with one candidate. Everything else comes back with the reason it was left: a combination, a partial payment, an internal transfer, nothing open that fits, or a refusal the database made, quoted. With p_apply false it changes nothing and says what it would do. |
| `available_statements(p_company_id uuid, p_at date)` | Statements a company may ask for: those of its country and chart, plus the generic framework. `is_default` marks the ones its chart declares. |
| `bank_accounts_read_identifier()` | Keeps iban, account_scheme and account_identifier saying one thing: an IBAN fills the identifier, an identifier of the iban scheme fills iban, and no other scheme ever writes iban. |
| `bank_statement_movement(p_statement_id uuid)` | The sum of the lines a statement lists or holds, each counted once. What balance_end_computed adds to balance_start. |
| `bank_transactions_guard()` | Keeps a statement line honest about whether it is settled. state moves between pending and ignored by hand; reconciled and entry_id are written by settle_from_statement() alone, under the setting ekwo.settling_statement, honoured for a caller holding reconcile.write (bank_transaction_settled_by_rpc otherwise, and on an insert that arrives settled). A line pointing at an entry keeps its amount, day, currency and bank account (bank_transaction_settled). When the entry is gone, the foreign key nulls entry_id and the line is pending again. The installer passes. |
| `caller_companies()` | The companies the current caller is on — the question is_company_member() answers, asked once for all of them, over the only companies where its answer can be yes. What a row level security policy compares company_id against, inside a sub-select, so that it is worked out once per statement instead of once per row. |
| `can_write_company(p_company_id uuid)` | Whether the current caller may write the books of a company. One capability, not a role, and false rather than NULL for a stranger. |
| `cancel_document(p_document_id uuid, p_date date)` | Undoes a posted invoice: writes its credit note — the same lines, taxes, accounts, attributes, contact, currency, rate and analytic split — naming it in reversed_document_id, posts it through post_document(), matches the two entries and marks the invoice cancelled. Returns the credit note. Dated on the invoice's booking day while that period is open, and otherwise refused until a date is given (reversal_date_needed). Refused for a document that is not a posted invoice, is already cancelled or credited, or is settled in part or in full (unreconcile() first). |
| `canonical_json(p_value jsonb)` | A value with every number it holds, at any depth, re-rendered through trim_scale(): the form two sides agree on once a JSON parser has been between them. What the `values_sha256` of an archive is computed over. Normalises notation and never magnitude. |
| `catch_up_journal_sequence(p_journal_id uuid, p_date date, p_number text)` | Advances the counter of a journal to the counter inside a number that was written by hand, so the next automatic number continues the series. Definer, because nobody writes `journal_sequences` directly — and guarded like `next_entry_number()`: the installer, or entries.post on the company of the journal. |
| `claim_instance_admin(p_user_id uuid)` | Makes a user an instance administrator. The first claim is open; afterwards only an administrator may appoint one. |
| `close_fiscal_year(p_fiscal_year_id uuid)` | Closes a fiscal year: the result leaves the income statement the way the country model says, and every income and expense account goes back to zero. The entry that moves the result is `appropriation`, the one that empties the income statement is `closing`. The balance sheet needs no entry — the reports read the ledger from the beginning. The allocation decided by a meeting is never part of it. |
| `close_fiscal_year_finally(p_fiscal_year_id uuid)` | Closes a closed fiscal year for good: sets finally_closed_at, after which reopen_fiscal_year() refuses it for everybody and nothing about the year changes. Refused on an open year (fiscal_year_not_closed), on a year already final, and while a closed year before it is not final. Needs year_end.close. Whether the country requires it is fiscal_year_final_close(). |
| `combination_subsets(p_amounts numeric[], p_target numeric, p_tolerance numeric, p_min_lines integer, p_max_results integer)` | The subsets of a list of positive amounts that add up to a target within a tolerance, as positions in the list, in the order a depth-first walk meets them: an item is taken when it is no more than what is left plus the tolerance, so the first subset is the one an oldest-first greedy walk finds when it finds one. At least p_min_lines positions each, at most p_max_results subsets, within matching_search_bounds(). Pure arithmetic: it reads no table. |
| `commercial_entity(p_contact_id uuid)` | Root of the contact parent chain; the entity a document is booked against. |
| `companies_agent_posting_by_a_person()` | Refuses, in a transaction of an agent (agent_call()), a change of companies.agent_posting that loosens it — review_only to review, review to autopilot — and a company created looser than review. Stricter is allowed. |
| `companies_creator_is_fixed()` | Writes companies.created_by from acting_user() when a company is created, and refuses to change it afterwards. The installer writes what it brings in as it is. |
| `companies_default_capital_currency()` | A capital stated with no currency is stated in the company's own. The alternative was a literal in the schema, which is one country's answer given to every country. |
| `companies_guard_archived()` | Refuses a hand-written change to archived_at. The setting archive_company() and unarchive_company() raise is honoured only for the installer or the owner of the company, because any session may set it. A column any client may flip is not a state. |
| `companies_number_format_carries()` | When a company's number pattern starts or stops carrying the year, carries each journal's last number into the counter the new pattern reads, so the series goes on without a hole or a repeat. |
| `companies_number_format_is_valid()` | Refuses a company number pattern that does not carry {CODE}, carries no counter or names a token outside the grammar. |
| `companies_vat_period_is_a_filing_period()` | Records a write to the deprecated companies.vat_period as what it is: how often this company files its country's periodic return. Everything written before this migration named that column and nothing else, and this is what keeps such a writer correct without it learning a table. |
| `companies_with_capability(p_capability text)` | The companies in which the current caller may do one named thing — the question has_capability() answers, asked once for all of them. It is what a row level security policy compares company_id against, inside a sub-select, so that the answer is worked out once per statement instead of once per row. |
| `company_archive_predicate(p_schema text, p_table text, p_alias text)` | The SQL condition that keeps the rows of one company in one table, with the company as `$1`. One place, read by the export, by the count and by the checks of an import. |
| `company_archive_predicate_via(p_schema text, p_table text, p_via_column text, p_via_table text, p_alias text)` | The condition of company_archive_predicate(), from a line of company_archive_tables() the caller already holds: a loop over the tables of an archive builds it without listing them again for each one. |
| `company_archive_row_count(p_company_id uuid, p_table text)` | How many rows one table holds for one company, whatever the caller may read of them. Definer, guarded by company.export, and it answers a number and nothing else: it is what lets an export notice that row level security handed it less than there is. |
| `company_archive_row_counts(p_company_id uuid)` | company_archive_row_count() for every table an archive carries, asked once: how many rows each holds for one company, whatever the caller may read of them. Definer, guarded by company.export, and it answers numbers and nothing else. |
| `company_archive_rows_query(p_schema text, p_table text, p_where text)` | The query that writes the rows of one table of an archive, given the condition that keeps one company (`$1`): `r`, one JSON object a row — decimals as text, no identity column — and `n`, its place in primary key order, or, for a table whose primary key is an identity, in the order of every column that leaves. The one definition both export_company_table() and export_company_archive() read their rows through. |
| `company_archive_tables()` | The registry of the socle and what every installed module answers through `<schema>.archive_tables()`, as one list. Modules load after the socle. |
| `company_archive_unclassified()` | What stands between this installation and an honest archive: a table of a company nobody classified, a classification of a table that is gone, an exported table with no way to a company. Empty is the only answer an export accepts. |
| `company_column(p_table regclass)` | The column a table names its company by: company_id, or id for companies itself, whose own id is its company. Null for a table that holds no company's rows. For migrations (decision 0065). |
| `company_filing_periods_mirror()` | Writes companies.vat_period from the row that records how often this company files its country's periodic return. The column is a mirror and never a second decision: it is written here, from the table, and only when the two differ. |
| `company_filing_periods_names_a_form()` | Refuses a filing cadence recorded against a form this installation does not carry. Raise, do not warn: a row nothing can resolve is a cadence nobody files on, and the guards that read it would simply never fire. |
| `company_filing_periods_within_scheme()` | Refuses a cadence recorded for a form the company's last recorded scheme does not file (form_not_in_vat_scheme), or on a cadence the scheme does not allow (wrong_declaration_period). A company with no scheme, and a form no scheme names, are not concerned. |
| `company_has_no_member(p_company_id uuid)` | Whether a company has no member yet, which lets its first member claim it. On a shared installation only the installer and an instance administrator are told, and claim (decision 0065). |
| `company_members_join_of_their_own_accord()` | On a shared installation, refuses a membership written for anybody but the signed-in person writing it — accept_invitation() and create_company() write the caller's own — and any change of who or which company a membership is for; the installer and an instance administrator excepted. One answer whether the person named has an account or not. Unchanged on an installation that is not shared (decision 0065). |
| `company_members_list(p_company_id uuid)` | The members of a company with the address each signed up with, their preset, their stored adjustments and when they joined. Needs members.manage. An address is null for a member whose account is gone. |
| `company_references_by_id(p_schema text)` | Every foreign key of a schema by one uuid column from a table that holds a company's rows (company_column()) to another table that does: what scope_references_to_company() makes composite. For migrations (decision 0065). |
| `company_role(p_company_id uuid)` | Role of the current user on a company, or NULL when they are not a member. |
| `company_scoped_tables()` | Every table that belongs to a company, read from the catalogue: it carries `company_id`, or a foreign key leads from it to `companies`, directly or through another such table. |
| `company_tax_regimes_check()` | Refuses a regime the pack of the company's fiscal country does not carry (unknown_turnover_regime), one that does not start on the first day of a financial year or end on the last day of one (regime_change_mid_year), and one that overlaps another (regime_overlap); records the cadence of the regime's form in company_filing_periods. |
| `company_vat_schemes_check()` | Refuses a scheme the pack of the company's fiscal country does not carry (unknown_vat_scheme) and one that does not start on the first day of a financial year (scheme_change_mid_year); writes the country of the scheme. |
| `company_vat_schemes_follow()` | Writes company_filing_periods from the last scheme the company recorded: removes the cadences of forms the scheme does not file or of cadences it does not allow, and records for each form it files the scheme's default or the one cadence it allows, never a guess among several. |
| `confirm_contact(p_transaction_id uuid, p_contact_id uuid)` | Attributes a statement line to a contact and learns from it, through learn_contact_patterns(): the account and the name as this bank writes them become motifs, and every motif that had named somebody else is charged a use without a success. Knowing who the money came from is not knowing what it pays — this function never touches a document and never reconciles anything. |
| `contact_candidates(p_company_id uuid, p_where text, p_name text, p_description text, p_words text, p_account text, p_amount numeric, p_currency character, p_document_types doc_type[])` | The one scoring of a counterparty, for whatever line carries the facts: the account it moved on, the motifs of contact_patterns, the number of a document of the types named (none named, none looked for), and the words of a contact's name — capped at 0.600 when the words reach several contacts, unless the label is a contact's whole name. Each candidate with its score, the evidence in a sentence and how many contacts that same evidence reached. Read by suggest_contacts() for a statement line and by suggest_line_contacts() for a ledger line; it writes nothing and decides nothing. |
| `contacts_guard_merged()` | Keeps a merged contact retired (decision 0074): merged_into is written by merge_contacts() alone, in the transaction that recorded the merge in contact_merges (contact_merged_by_merge_contacts otherwise, and on an insert that arrives merged); once written it changes only to follow the contact it names when that one is merged in its turn, the contact is not made active again and is not deleted while its company stands (contact_merged). |
| `contacts_language_reaches_drafts()` | A customer who changes language changes the drafts addressed to them, and nothing else: a posted document keeps the language it was sent in. |
| `create_api_key(p_company_id uuid, p_name text, p_capabilities jsonb, p_expires_at timestamp with time zone, p_posting_mode text)` | Issues a machine key on one company and returns the secret once. Only the hash is stored. No capability can be put on a key that the person issuing it does not hold, and at every use the key holds only what that person still holds (key_holds). A key issued while another key is presented records the person behind that key. p_posting_mode fixes how it posts a document, for good: review (the default) or autopilot, which needs company.write, is refused in a company that is review_only (autopilot_forbidden), and is refused to an agent not itself in autopilot there. |
| `create_company(p_name text, p_country character, p_currency_code character, p_language character, p_chart_code text, p_fiscal_year integer, p_fiscal_year_start date, p_owner_user_id uuid)` | Creates a company, makes its owner the first member, copies the country pack into it and opens its first financial year on the month that pack declares. An instance-level act; on a shared installation, also a signed-in person's for a company of their own, up to companies_per_person counted on what they created (decision 0065). |
| `create_document(p_document jsonb, p_lines jsonb)` | Creates a draft and its lines in one statement: a refused line creates nothing, rather than an empty draft. The header names company_id, doc_type, contact_id, document_date and currency_code, and optionally due_date, accounting_date, number, supplier_reference, journal_id, payment_reference and client_ref. Security invoker. |
| `currency_of_bank_account()` | Fills a statement line's currency_code from its bank account, and from the company as a last resort. |
| `currency_of_company()` | Fills currency_code from the company when the caller named none. The one place the question is answered for a table that belongs to a company. |
| `currency_unit(p_rounding money_rounding)` | The smallest amount a currency has: a cent in the euro, a yen in the yen. A tolerance is written as a fraction of this rather than as a fraction of a cent. |
| `current_api_key()` | The key presented in this transaction, or nothing. What a client reads back to know what it may do. |
| `declaration_boxes_of(p_tax_id uuid, p_box text, p_tax_line boolean, OUT boxes text[], OUT report_code text)` | What the postings of a tax say today about a ledger line of that tax in that box, on the tax side or not: every box their lists print it in, and the form they name. Null and null where none answers. The rule entry_lines_box_from_posting() freezes on a line when it is written, and the one vat_return() falls back on for a line that carries nothing frozen. Under the caller's row level security. |
| `declaration_period_months(p_period declaration_period)` | How many months a cadence lasts: 1, 2, 3, 4, 6 or 12. Every function that works out a period reads this number rather than a list of names, so a cadence added to the type is a line here and nowhere else. |
| `declaration_period_of(p_from date, p_to date)` | The cadence a pair of dates is a whole one of — month, bimonth, quarter, four_month, half_year, year, each anchored on 1 January — or null when the two dates are not a filing period at all. |
| `declaration_period_start(p_period declaration_period, p_day date)` | The first day of the period of this cadence a day falls in, anchored on 1 January: a bimonth starts in January, March, May, July, September or November, a four-month period in January, May or September, a half-year in January or July. |
| `declared_lines(p_company_id uuid, p_from date, p_to date)` | The ledger lines of a company that count for a tax return of the period from–to, both days included: those whose declared_on falls inside it. The one statement of period membership, read by vat_return(), filing_tax_movements() and filings_touched_since(). Inlined by the planner, so a caller that adds `declaration_box is not null` reads the period through entry_lines_declared_on_idx. Under the caller's row level security. |
| `declared_on_of(p_tax_point_date date, p_entry_date date)` | The day a ledger line counts for a tax return: the tax point the posting engine wrote on the line, or the date of its entry where the line carries none. The one statement of that rule: the trigger that writes entry_lines.declared_on, its backfill and import_company() all call it. |
| `default_statement_code(p_company_id uuid, p_kind text, p_at date)` | The statement of a kind this company reports on: one its chart declares, else one of its country, else the generic framework. Null when it has none of that kind. The one place that choice is made, so two readers cannot disagree about which balance sheet is the company's. |
| `delete_company(p_company_id uuid, p_confirm_name text)` | Deletes a company and, through the foreign keys, everything that belongs to it. The act of the owner preset; p_confirm_name must be the name of the company exactly (company_name_mismatch). Refused while another member still reaches the books through it (company_has_other_members) and while a machine key scoped to it is live (company_has_live_keys). The user triggers of the company's tables are off for the transaction, as import_company() has them. The trail keeps its rows about the company and ends them with company_deleted. The only way a company leaves: no policy lets a client delete from companies. |
| `disable_module(p_company_id uuid, p_code text)` | Disables a module on a company, unless the module says it still holds data — `<schema>.can_disable(company)` returning a sentence refuses, returning null allows. Nothing the module wrote is deleted. Needs company.write. |
| `document_amount_paid(p_document_id uuid)` | What a document has been settled by: the matched amounts on the third-party lines of its entry, in the document's currency. The one definition — documents_refresh_amount_paid() writes it and documents_guard_posted() accepts no other figure. |
| `document_line_analytics_guard()` | The split of a document line: refused on a document that is no longer a draft (document_posted), on a line whose account carries no split (analytic_not_on_this_account), on a new share of a retired value (analytic_value_retired) but on the credit note cancel_document() writes, and beyond 100 % on one axis (analytic_split_over_100). |
| `document_line_split_key(p_line_id uuid)` | The analytic split of a document line as one text, null when it has none. post_document() groups lines by it. |
| `document_lines_amount_untaxed()` | Derives a line's amounts from its quantity, price and discount, rounded once at the decimals of the document's currency: the net, the gross where the price includes the tax, and the snapshots of whether it does and of whether its tax is computed inside its own base (decision 0077). |
| `document_lines_analytic_defaults()` | Pre-fills the analytic split of a document line from the default value of its product, then of the document's contact or, when it has none, of that contact's parent one level up, at 100 % on each axis the line has no share on yet, only on an account that carries a split and only with a value in use. Never replaces what the line carries. |
| `document_lines_attributes_from_product()` | Pre-fills the attributes of a document line from those of its product, for every name the line does not carry, when the line is written or its product changes. Never replaces what the line carries, and leaves alone the lines a credit note copies from the invoice it undoes. |
| `document_lines_check_classifications()` | Asks assert_classifications() of a document line whose attributes or product are written, after the product has pre-filled them. |
| `document_lines_guard_posted()` | Once a document has left draft, its lines are the lines that were issued: no insert, no delete, no column changed. Refuses document_posted, by name, to everybody. |
| `document_lines_guard_tax_account()` | Refuses a document line on an account that a tax of the company lands on (tax_postings, posting_type = tax): the tax of a line is its tax_id, and the posting writes it there. Lets the credit note of a cancelled document copy such a line, so a document posted before the guard can still be undone. |
| `document_lines_refresh_totals()` | After a line of a draft moves: shares out the base of every tax group quoted with its tax in it, then refreshes the three totals of the document. A document that is no longer a draft keeps the totals it was posted, or loaded, with. |
| `document_lines_snapshot_tax()` | Writes BT-151 and BT-152 on a line from its tax for as long as the document is a draft. Once it is not, document_lines_guard_posted() refuses any change to the line, these two columns included. |
| `document_share_refusal(p_document documents)` | Why this document may not be shared, or null when it may. Sales only, never cancelled, never an unposted invoice, always numbered. |
| `document_territory(p_document_id uuid, p_party text)` | The territory of one party to a document: seller, buyer or supply. The seller is the company on a sale and the contact on a purchase, each resolving to its own territory_code and failing that to its country. The supply is the document's supply_territory_code, failing that its delivery_country (BG-15), failing that the buyer's territory. Null where none of those was ever recorded. |
| `document_version(p_document_id uuid)` | A digest of a document and its lines as they stand, every column but updated_at: what approve_document() approves, and what a posting by an agent in review compares to it. Any change to the draft gives another. Null for a document the caller cannot read. |
| `documents_allocate_included_tax(p_document_id uuid)` | Turns the gross of every tax group quoted with the tax in it into a base: the tax rounded once on the group (BR-CO-14), as tax_amount_of() computes it, the base the gross less that tax, shared over the lines in proportion to their gross with the remainder on the last. Refuses a group that is half inclusive, by name. |
| `documents_default_payee_iban()` | A sales document with no payee account takes the company's default bank account, whatever scheme it is written in. A purchase document never does: the payee there is somebody else. |
| `documents_guard_language()` | Fills documents.language from the customer, then the company, then the country pack when a document is created, keeps a draft in step with the customer it is addressed to, and refuses document_language_frozen on anything that is no longer a draft. |
| `documents_guard_posted()` | Once a document has left draft: it is not deleted, no column moves but the closed list of what happens to a document after it is issued — amount_paid (to the figure the matching gives, and no other), payment_state, sent_at, peppol_status, peppol_message_id — and its state has two ways out: posted to cancelled, taken by cancel_document() and held to a posted credit note of the matching type that names it and settles it in full, for a caller holding documents.post (document_cancelled_by_hand otherwise); and posted to draft, taken by unpost_document(). Refuses document_posted, by name, to everybody. Becoming posted is held to what post_document() writes (document_posted_by_hand otherwise), and nobody inserts a document that is already posted (document_born_posted). One exemption (decision 0074): contact_id alone, from the absorbed contact to the kept one, in the transaction in which merge_contacts() recorded that merge in contact_merges, written to the trail as document_contact_merged. |
| `documents_match_credit_note_on_posting()` | As a credit note that names its invoice (reversed_document_id) is posted, matches its third-party lines with the invoice's through match_reversal() — for what both still have open, so a credit note for part of an invoice settles that part — when the invoice is posted, of the matching kind, in the same currency at the same rate, and the caller may match (may_match_on_posting()). Decision 0073. |
| `documents_need_a_contact()` | Refuses document_without_contact for a document that leaves draft, or is written in another state, without a contact. A draft may wait for its contact; nothing after it does. |
| `documents_posting_mode()` | Holds the posting of a document by an agent (agent_call()) to agent_posting_mode(): autopilot_forbidden when the key or the session is in autopilot in a company that is review_only; in review, approval_required unless a person approved the draft as it stood (approve_document()) since it last went back to draft. Every posting by an agent writes document_posted_by_agent on the audit trail: the mode, the company's setting, the session, and in review the approval; the key is the row's api_key_id. A rehearsal is not held to it. |
| `documents_refresh_amount_paid(p_document_id uuid)` | Recomputes what a document has been settled by, from the matched amounts on its third-party lines. |
| `documents_refresh_payment_state()` | Derives payment_state from amount_paid against amount_total: not_paid, partially_paid, paid, overpaid — and reversed for a document cancelled after it was posted and settled in full by its credit note. Never keyed. |
| `documents_refuse_replaced_tax()` | Refuses to post a document a line of which carries a tax of a kind the company's regime of turnover_tax_regimes replaces on the document's date (tax_replaced_by_regime). |
| `documents_refuse_vat_under_exemption()` | Refuses to post a sale invoice or credit note a line of which charges VAT — a tax of kind vat at a rate other than zero — on a day the company is on a scheme of vat_schemes that charges none (vat_charged_under_exemption). |
| `ec_sales_list(p_company_id uuid, p_from date, p_to date, p_report_code text)` | The recapitulative statement of intra-Community supplies for a period: one line per customer VAT identification number and per nature — goods, services, and whatever the treatment vocabulary gains next — summed from the posted ledger in the company's currency, credit notes deducted. The country of a line is the prefix the customer's numbers carry, read from `territories`, so a Greek customer is listed under EL. A supply that cannot be declared comes back with the reason in `issue` rather than being left out. Name the form in p_report_code to have the period checked against the cadence this company files **that statement** on, which is not the cadence of its periodic return in any country read so far; name none and nothing is refused. A supply is a base line of the tax: a line a `tax_on_base` posting wrote is a cost and is left out. No country rule lives in this function. |
| `ekwo_pre_request()` | Called by PostgREST at the start of every request (pgrst.db_pre_request). Presents the key in X-Ekwo-Api-Key when there is one, then moves the request off `anon` so that row level security decides instead of the grants, and gives it the statement_timeout configured for `authenticated`, when one is. A call that carries a whole company (is_archive_request) by a key or a signed-in session is given archive_statement_timeout(), only ever upwards. No header and no archive, no effect. |
| `ekwo_schema_version()` | Schema version of the installed release. Bumped by a migration, never by hand. |
| `enable_module(p_company_id uuid, p_code text, p_settings jsonb)` | Enables a module on a company, and updates its settings when it is already enabled. Needs company.write, checked here because the table has no write policy. |
| `entries_declared_on_follows()` | Carries a new date of an entry to the declared_on of its lines that have no tax point of their own. Only a draft changes its date: a posted entry keeps it, by entries_guard_posted(). |
| `entries_guard_kind()` | Keeps entries.kind on `normal` outside the three functions that open and close a year. The setting they raise while they write is honoured only for the installer or a caller holding the capability of the act — year_end.close, or entries.post for an opening — because any session may set it. A label any client may set is a label a statement cannot be built on. |
| `entries_guard_module()` | Keeps the module tag of an entry honest: a module the company holds, never posted on insert, never moved afterwards. |
| `entries_guard_posted()` | Once an entry has left draft: its state does not change and no column moves (entry_posted); it is not deleted, but for the entry of a document unpost_document() has put back to draft, recorded in document_unpostings in the same transaction and pointed at by no document any more; nobody inserts one that is already posted (entry_born_posted). Becoming posted is held to what post_entry() produces, read on the row and in the counter — an instant it was posted at, no financial year but the one its date falls in, at least one line, an open period, and, where the country numbers without a hole and the caller does not hold entries.import, the number the counter of its journal has just delivered: entry_posted_by_hand otherwise. |
| `entries_match_reversal_on_posting()` | As an entry that names what it undoes (reversed_entry_id) is posted, matches its third-party lines with that entry's through match_reversal(), when the caller may match (may_match_on_posting()). Whatever wrote the reversal: reverse_entry(), a draft keyed by hand, the mirror unreconcile() posts (decision 0073). |
| `entries_refresh_totals()` | Keeps the totals of a draft entry in step with its lines. A posted entry keeps the totals it was posted, or loaded, with. |
| `entries_require_analytic_axes()` | As an entry keyed by a person is posted, refuses analytic_axis_required when one of its lines, on an account of a group an active axis is required on, carries less than 100 % of that axis. Not asked of a document's entry (post_document() asked its lines), a mirror, an opening, a closing, an appropriation, a module's entry, or what a matching or a bank line settles. |
| `entry_line_analytics_guard()` | The split of a ledger line: refused on a posted line whose period is locked or whose fiscal year is closed (period_locked, fiscal_year_closed, from assert_period_open()), on a line whose account carries no split (analytic_not_on_this_account), on a new share of a retired value (analytic_value_retired) but on the entry post_document() writes and on a mirror, and beyond 100 % on one axis (analytic_split_over_100). |
| `entry_lines_box_from_posting()` | Refuses a ledger line whose declaration box is not one its tax posting writes — a line naming a box names a tax, and a posting of that tax writes that box: a tax posting for a tax line, a base or tax_on_base posting otherwise, of the line's own posting_type when it states one (declaration_box_without_posting) — and freezes on the line what the posting says about the box: declaration_boxes and report_code, from declaration_boxes_of(). A reversal mirroring a line of the entry it reverses takes that line's box and frozen columns. Fires on insert and on a change of the box, the tax, tax_line, posting_type or the two frozen columns; changed while nothing they are read from moved, they are refused (declaration_boxes_from_posting). The installer is not checked, and is frozen like everybody. |
| `entry_lines_guard_posted()` | Once an entry has left draft, its lines are the lines that were posted: no insert, no delete, and no column changed but the two the matching writes, matching_number and matched_amount. Refuses entry_posted, by name, to everybody. Two exemptions, contact_id alone each time: from null to a contact, on an unmatched line of a receivable or payable account, under the setting ekwo.naming_line_contact holding that line's id — raised by set_line_contact() — for a caller holding reconcile.write, written to the trail as line_contact_named (decision 0070); and from the absorbed contact to the kept one, in the transaction in which merge_contacts() recorded that merge in contact_merges, written to the trail as line_contact_merged (decision 0074). |
| `entry_lines_set_declared_on()` | Writes entry_lines.declared_on from the rule of declared_on_of(), before every insert of a line and every update of its tax point, of its entry or of the column itself. Definer, so the date of the entry is read whoever the caller is. |
| `eu_vat_scope_of(p_code text, p_on date)` | How much of the common system of VAT applied to a territory on a day: all of it, supplies of goods only, or none. A territory this table does not carry answers none, which is the right answer for every third country. |
| `evaluate_totals(p_values jsonb, p_formulas jsonb, p_rounding money_rounding, p_keep_zero boolean)` | Works out the totals of a declaration form or of a financial statement — a plus/minus list, or a rate applied to one other key — in the order they depend on each other. The one place that calculation lives: vat_return() and financial_statement() both call it. |
| `export_company(p_company_id uuid)` | The whole archive as one document, read in one snapshot: `manifest`, and `tables` keyed by table name. It is what `import_company()` takes, and it writes `company_exported` on the audit trail. A large company is better read table by table, which is what the CLI does; this is the same rows in one answer. |
| `export_company_archive(p_company_id uuid, p_with_rows boolean)` | The archive of one company, read once: `manifest`, and — when asked for — `tables` keyed by table name. The right, the sweep of the catalogue and the list of tables are asked once, and each table is read once for its count, both checksums and its rows. Runs as its caller and needs company.export; stable, so it reads the snapshot of the statement that calls it. What export_company(), export_company_manifest() and export_company_tables() answer. |
| `export_company_manifest(p_company_id uuid)` | What an archive of this company is: the format and its version, the socle, the packs and the modules an installation needs to take it in, every table with its row count and the sha256 of its rows, the tables left behind with the reason, and the list of the files the attachments point at — which the archive does not carry. |
| `export_company_table(p_company_id uuid, p_table text)` | The rows of one table for one company, one JSON object each, in primary key order — or, for a table whose primary key is an identity, which does not leave, in the order of every column that does: decimals as text, timestamps in UTC. Runs as its caller, needs company.export, refuses when the caller may read fewer rows than the table holds, and refuses while any table of a company is unclassified. Stable, so it reads the snapshot of the statement that calls it: called table after table, it needs a repeatable read transaction around the calls for the tables to agree with each other and with the manifest — which is what the CLI opens — or use export_company(), which is one statement. |
| `export_company_tables(p_company_id uuid)` | Every exported table of one company as one object, keyed by table name. The `tables` half of export_company(). |
| `fec_lines(p_company_id uuid, p_from date, p_to date)` | The eighteen columns of the French FEC for a period: the opening balances of the financial year first, computed and never posted, then its movements in chronological order. The entries the close wrote are left out — the file carries the income statement in its ordinary lines, and the result reaches the balance sheet in the opening lines of the year that follows. |
| `file_filing(p_filing_id uuid, p_reference text, p_filed_at timestamp with time zone, p_channel filing_channel, p_service text)` | Records that a declaration has gone, with the reference the administration gave back, and keeps the send as a row of tax_filing_deposits. It asks that the figures were computed, not that there are any: a period where nothing happened is filed nil. A rejected declaration may be sent again — it was never received — and the second send is a second deposit, not a corrective. Asks filings.write. |
| `filing_deadline(p_company_id uuid, p_report_code text, p_period_end date)` | When a period closed on this date has to be declared, under the rule the pack carries. Null where the pack declares none, and null where it declares depends_on_taxpayer — a country whose schedule depends on the filer, not a country without deadlines. |
| `filing_drift(p_filing_id uuid)` | Box by box and kind by kind, what the ledger says now — at the unit the form is filed in — against what was filed, for the figures where the two disagree. Empty is the answer everybody wants; anything else is either a corrective to file or an entry in the wrong period. |
| `filing_period(p_company_id uuid, p_report_code text)` | How often this company files that declaration, or null when it has not been recorded. Null is not a cadence and not an error: the books are kept the same either way, and a guard that reads it refuses nothing. |
| `filing_proof(p_sha256 text)` | The public way to read a proof: given the sha256 of a file, one row per proof recorded for it — method, status, anchor and the proof bytes as base64 — and nothing about who proved it or what it is about. No row, the same empty answer, for a malformed hash and for a hash nobody proved. |
| `filing_rounding(p_company_id uuid, p_report_code text)` | How a figure of this form is written when it is frozen for this company: the currency's decimals and the country's method, coarsened to the unit of the form where the form names one. The only reader of tax_report_templates.rounding_unit. |
| `filing_tax_movements(p_filing_id uuid)` | The tax accounts a declared period moved on the filing's own form and by how much, on the same window and the same tax-point rule the return read, net of what an earlier settlement of the same period already carried. A tax line is on the form when the box it names is on it (the form frozen on the line; none named is the single return), or when it names no box, its tax writes a box of the form through another posting, and it is not on the tax's cash-basis transition account. A tax booked on a liability no box of the form carries stays for its own return. What settle_filing() clears — the whole period the first time, the difference on a corrective — what lock_filed_period() waits for, and what anybody can read before it does. |
| `filings_touched_since(p_company_id uuid, p_from date, p_to date)` | Declarations that have gone and whose period the ledger moved afterwards: how many entries carrying a declaration box landed in it, when the last one did, and how many of the filed figures now disagree. An entry that changes no figure is still listed — it was posted into a period that had been declared, and that is the fact being reported. |
| `financial_analysis(p_company_id uuid, p_from date, p_to date)` | The aggregates of a company over a period, in the order of analysis_aggregates: the amount in the company currency, signed as the aggregate is named, the accounts that make it as [{code, name, amount}], each amount with that same sign, and source. source is pack when the company's country pack defines an analysis for its chart, and the rows are the ones it defines; framework otherwise, and the rows are those a framework reads by account type — the framework whose statements the chart declares, else the one the installation carries — which leaves out the aggregates no account type tells apart. Movements are read from p_from to p_to, less the closing entries; balances at p_to. equity adds the result no close has moved yet, on the account year_result_account() names (code and name null where the pack names none). No row when neither the pack nor a framework defines an analysis. Security invoker: entries.read, and the caller's own rights on the ledger. |
| `financial_statement(p_company_id uuid, p_statement_code text, p_from date, p_to date)` | One financial statement of a company for a period: each line summed from the accounts its rules catch, then the totals evaluated in the order the scheme declares them. No country rule lives in this function. |
| `financial_statement_of_kind(p_company_id uuid, p_kind text, p_from date, p_to date)` | One financial statement of a company by kind — balance_sheet, income_statement, allocation, cash_flow — for a caller that does not know which scheme its country pack carries. Resolves through default_statement_code() at the end date of the period, then answers as financial_statement() does, with the code it chose in the first column. On a balance sheet whose line for the result also takes other balances (statement_templates.result_in_progress = combined), the result nobody has closed yet follows that line as a row of its own: key <line>:result_in_progress, parent the line, the pack's label, not a total — a detail of its parent that no total adds. |
| `fiscal_year_at(p_company_id uuid, p_date date)` | Fiscal year covering a date, or NULL. |
| `fiscal_year_bounds(p_country character, p_year integer, p_start date, OUT start_date date, OUT end_date date)` | The first and last day of a financial year opening in a given calendar year, on the month the country pack declares — or on a day the caller names. Raises rather than assuming January. |
| `fiscal_year_final_close(p_fiscal_year_id uuid)` | Whether the country of the company requires a final close of this fiscal year, by when (due, and due_date once the following year exists), under which article, and whether it was done. Read from country_defaults.final_close_due, which the pack writes; null where the pack says nothing. |
| `fiscal_years_guard_closed()` | Refuses a hand-written change to is_closed or closed_at. The setting close_fiscal_year() and reopen_fiscal_year() raise is honoured only for the installer or a caller holding year_end.close, because any session may set it. A column any client may flip is not a lock. |
| `fiscal_years_guard_final()` | Keeps a final close final. Refuses, for everybody, any change to a finally closed year — is_closed, closed_at, finally_closed_at, its dates — and deleting it; and refuses setting finally_closed_at anywhere but in close_fiscal_year_finally(), for a caller holding year_end.close. |
| `format_number(p_format text, p_code text, p_date date, p_number integer)` | One document number, rendered from the pattern the country pack declares. Raises rather than guessing at a token it does not know. |
| `general_ledger(p_company_id uuid, p_from date, p_to date, p_account_ids uuid[])` | Posted lines of a period per account, with the balance carried forward from before the period. Each line names its contact (contact_id, contact_name) when it has one. |
| `has_capability(p_company_id uuid, p_capability text)` | Whether the current caller may do one named thing in one company — a signed-in member by their preset and their adjustments (member_holds), or a machine key by its own list and by what its issuer still holds there (key_holds). Revoked beats granted, a key is never wider than its issuer today, and a non-member holding no key holds nothing. |
| `has_opening_entry(p_fiscal_year_id uuid)` | Whether a fiscal year already carries an opening entry that still stands — an imported balance or the re-opening of the year before. |
| `import_bank_statement(p_company_id uuid, p_file jsonb, p_source jsonb, p_bank_account_id uuid)` | Writes what a format reader read out of a bank file into bank_statements and bank_transactions, and nothing else: no entry, no payment, no matching. Idempotent on import_key — a replayed file imports nothing, an overlapping statement imports what is new and lists the rest. Refuses, by name and before writing anything: an account the company does not have (unknown_bank_account), a statement that does not add up (unbalanced_statement) or has no balances, a booked line it cannot hold as it is (unreadable_statement_line), a currency that is not the account's, and the same statement with other balances (statement_conflict). Signals and does not refuse: an opening balance that is not the previous closing one, a hole in the bank's numbering. One row per statement of the file; the whole file is imported or none of it. |
| `import_books(p_company_id uuid, p_books jsonb, p_dry_run boolean, p_open_years boolean, p_allow_result_accounts boolean)` | Takes over books read from another system, whole or not at all: the fiscal years they need (p_open_years), their parties, every entry posted through post_entry() and a trial balance through opening_balance(), on the day the files open it, with the open items they list as documents. Account codes arrive already translated into the company's chart. p_dry_run does all of it and rolls it back, so the answer and the refusals are the real ones. The same files twice are refused (import_already_done). |
| `import_company(p_archive jsonb, p_owner_user_id uuid)` | Takes one company archive into this installation, whole or not at all. Checks the manifest against the values of the rows — `values_sha256`, which a reader reproduces after parsing the archive — and against their bytes for an archive written before 0.9.0. A table a module has renamed since is read under its name of today. entry_lines.declared_on is derived for an archive written before it existed, and checked against declared_on_of() for one that carries it. |
| `import_fiscal_year_for(p_company_id uuid, p_date date)` | The fiscal year a date falls in, opened when there is none as a year of the same length and on the same first day as the company's earliest one. Called by import_books() when the caller asks for years to be opened. |
| `init_instance(p_organization_name text, p_country character, p_edition instance_edition)` | Records the installation. Called once, by the installer. Leaves the registration fields empty. |
| `install_country_template(p_company_id uuid, p_country character, p_language character, p_chart_code text)` | Copies one chart of a country pack into a company in one language, with the country's journals and taxes, wires the default roles, pins the accounts it wired, and records the pack version and the chart in company_packs. A tax posting is copied with every declaration box it prints in. |
| `installed_schema_version()` | The schema version this installation runs, and its edition, for a caller it knows: a signed-in account that is on no company yet, or the holder of a machine key that still reaches something. No rows for anybody else, so an anonymous call learns nothing. Nothing else of the instance row comes with it. |
| `instalment_plan(p_company_id uuid, p_from date, p_to date)` | The payments on account of the declaration of a period the company's scheme asks for: for each instalment of vat_scheme_instalments, the month (and the day, where the law gives one), the base — the box the pack names on the previous period's return as frozen by prepare_filing(), or as vat_return() computes it where nothing was frozen — the percentage, what was due, what declaration_instalments records as paid and what is outstanding. reason says no_base where there is no previous period to read, below_minimum where the base is under the scheme's minimum and nothing is due. No row for a company with no scheme or a scheme without instalments. |
| `instance_admins_keep_one()` | Refuses to remove the last administrator of a shared installation, whoever asks (decision 0065). |
| `instance_has_no_admin()` | Whether the first signed-in user may claim this installation: it has no administrator, and it is not shared (decision 0065). |
| `instance_is_shared()` | Whether this installation is shared by several unrelated people (decision 0065). False on an installation with no instance row yet. |
| `instance_sharing()` | Whether this installation is shared, and how many companies one person may create on it. Says nothing about anybody's companies. |
| `invite_member(p_company_id uuid, p_email text, p_role member_role, p_capabilities jsonb, p_valid_for interval)` | Invites an address into a company and returns the token once. Only the hash is stored; re-inviting the same address revokes the pending invitation. |
| `is_any_company_member()` | Whether the caller belongs to at least one company of this installation, as a member or as the holder of a machine key that still reaches something on its company. |
| `is_archive_request(p_path text)` | Whether a PostgREST path names a call that carries a whole company, and is given archive_statement_timeout(). |
| `is_company_member(p_company_id uuid)` | Whether the caller is on a company: a member of it, or the holder of a machine key that still reaches something there. False, never NULL, for a stranger. |
| `is_company_owner(p_company_id uuid)` | Whether the current user is on the owner preset of a company. False, never NULL, for somebody who is not a member — a guard written as `if not is_company_owner(…)` has to fire for a stranger. |
| `is_eu_member(p_code text, p_on date)` | True when the whole of the common system of VAT applied to the territory on that day: every Member State, and Monaco, whose transactions article 7(1) treats as French. False for Northern Ireland, which is inside the system for goods alone, and false for a State from the day it left. |
| `is_installer()` | Whether the caller is the installation itself — the migration runner, the seeds, the CLI — rather than a person or a machine key. True only when there is no session and no key, ekwo.installing is on, and the login that opened the connection is a member of the role that owns the tables: a setting any session may write is not enough on its own. False, never NULL, because the guards negate it. |
| `is_instance_admin()` | Whether the current user administers this installation. |
| `is_known_caller()` | Whether this installation knows who is asking: a signed-in user, or the holder of a live machine key that still reaches something. What the policies of the reference tables ask. |
| `journal_book(p_company_id uuid, p_from date, p_to date, p_journal_ids uuid[])` | The book of one journal, of several, or of all of them (p_journal_ids null): every line of every posted entry of the period, in the order a book is read — day, journal, entry number, line. Each line names its entry, the document behind it and that document's type, its account and its contact. No running balance: that is general_ledger(), per account. |
| `journal_totals(p_company_id uuid, p_from date, p_to date)` | The head of each journal's book: one row per journal of the company, with how many posted entries and lines went through it in the period and their debit and credit — zero where nothing did. A screen draws these figures rather than adding the lines of journal_book() up again. |
| `journals_number_prefix_is_its_own()` | Refuses a journal whose number prefix (or code, where it has none) is what another journal of the company already prints. |
| `key_holds(p_key api_keys, p_company_id uuid, p_capability text)` | Whether one machine key holds one capability on one company now: the key is live and on that company, the capability is on its list, and the person who issued it holds it there today (member_holds). A key the installation issued, created_by null, is bounded by its list alone. Worked out at the call, never stored. |
| `label_for(p_name text, p_i18n jsonb, p_languages text[])` | The label in the first language of the list that has one, and the row's own name when none of them does. The only place a translated label is chosen. |
| `learn_contact_patterns(p_company_id uuid, p_contact_id uuid, p_where text, p_name text, p_description text, p_words text, p_account text, p_amount numeric, p_currency character, p_document_types doc_type[])` | What a decision teaches contact_patterns, from the same facts contact_candidates() scored: every motif that had named somebody else is charged a use without a success, and the account and the name as the line wrote them become learned motifs of the contact chosen. Called by confirm_contact() and set_line_contact(), the only two places a motif is learned. |
| `leave_line_unnamed(p_line_id uuid, p_reason text)` | Records that a person decided an open line on a receivable or payable account names nobody, with the reason: suggest_line_contacts() no longer proposes it. The line does not move and stays an open item. Needs reconcile.write. Refuses unknown_line, not_allowed, reason_required, reason_too_long, line_not_posted, line_has_contact, line_not_third_party, line_left_unnamed by name. undo_leave_line_unnamed() takes it back (decision 0072). |
| `legal_mention_treatments(p_applies_when text)` | The tax treatments a condition of legal_mention_templates.applies_when covers, or null for a condition that is not about a treatment (always, late_payment, cash_basis, small_business). The one place that says so: document_legal_mentions reads it to print the sentence, document_tax_summary to give a VAT group its reason. |
| `line_contact_facts(p_line_id uuid)` | What a ledger line says about who it is, as contact_candidates() reads it: the label, the text of the label, the entry's description and reference, the amount in the currency the line is stated in, and the types of document whose number is evidence — sales for a receivable, purchases for a payable, by account_type. |
| `locale_of_country_pack()` | Fills a company's currency and language from the pack of its fiscal country when the caller named neither. A pack that says nothing leaves them null, and NOT NULL refuses the row. |
| `lock_filed_period(p_filing_id uuid)` | Carries the tax lock to the end of the period a declaration covers, so nothing more falls into it. Forward only, refused on a declaration that has not gone, and refused while the period still has tax accounts to clear — because the lock would then refuse the very entry that clears them. Returns the lock date the company ends up with. Nobody is obliged to call it: a period left open is a period filings_touched_since() reports on. |
| `match_lines(p_line_ids uuid[], p_reason text)` | The one implementation of reconcile_many() and reconcile_with_difference(): checks the set of lines, books the difference when a reason is given, and pairs the debits with the credits oldest first through reconcile(). Call those two rather than this. |
| `match_reversal(p_entry_id uuid, p_reversal_id uuid)` | Matches every reconcilable line of a posted entry against the line of its posted reversal — or of the credit note of its document — on the same account, the other side and the same counterparty, through reconcile(). Returns how many matchings it made. Called by reverse_entry() and cancel_document(), and as a reversal or a credit note is posted (decision 0073). |
| `matchable_lines(p_company_id uuid, p_contact_id uuid)` | The open receivable and payable lines the matching searches: posted, naming a contact, in the company's currency, each with its party (commercial_entity()), its entry and what that entry or its document undoes, and the references a settlement may carry. Of one party when p_contact_id is given. Read by suggest_item_combinations() and suggest_sure_pairs(). |
| `matching_difference_reasons(p_company_id uuid)` | The reasons reconcile_with_difference() accepts for this company, each with the account the difference is booked on and whether it can be: rounding (the company's rounding account, from the pack role rounding) for either side, exchange_difference on the exchange loss account for a charge and on the exchange gain account for an income (pack roles fx_loss and fx_gain). available is false, with the reason in because, where the pack or the company names no usable account. No pack carries a role for bank charges or a payment discount, so neither is a reason. No row for a company the caller cannot read. |
| `matching_difference_tolerance(p_company_id uuid)` | The largest difference reconcile_with_difference() books for this company: in units of the currency (matching_settings.difference_tolerance_units, 500 when the company has no opinion) and as an amount of the company's currency. No row for a company the caller cannot read. |
| `matching_policy_of(p_company_id uuid)` | The six numbers, for this company: its own where it has an opinion, the shipped ones otherwise. The only function that carries a default. |
| `matching_search_bounds()` | The bounds of the search for several open items that settle one line, in the one place they are written: how many candidates, how many lines in a subset, how many steps of the walk, how many proposals for a line. Read by combination_subsets(), suggest_combination() and suggest_item_combinations(). |
| `may_know_of_company(p_company_id uuid)` | Whether the caller may learn anything of this company, even that it exists: always on an installation that is not shared; on a shared one, its members, a key of it, an instance administrator and the installer (decision 0065). |
| `may_match_on_posting(p_company_id uuid)` | Whether a posting matches what it undoes on the spot: the caller holds reconcile.write and settings.read in the company, or is the installer. Read by the triggers of decision 0073. |
| `member_capabilities(p_company_id uuid, p_user_id uuid)` | The capabilities one member effectively holds on one company, preset and adjustments resolved. Reading another member's needs members.manage. |
| `member_holds(p_member company_members, p_capability text)` | Whether one membership holds one capability: revoked beats granted, granted beats the preset. The one place a person's rights on a company are decided — has_capability(), member_capabilities() and key_holds() all ask it. False, never NULL. |
| `merge_contacts(p_keep uuid, p_absorb uuid)` | Merges two contacts of one company (decision 0074): every reference of p_absorb — every foreign key to contacts, read from the catalogue, posted lines and issued documents included, the branches whose parent it was, the files attached to it — moves onto p_keep in one transaction; its learned motifs are folded into the kept contact's; the kept contact's empty fields are filled from the absorbed one, never overwritten; and the absorbed contact is retired, inactive with merged_into = p_keep, never deleted. Needs contacts.write and reconcile.write. Refuses unknown_contact, same_contact, already_merged, different_identifiers (two VAT or registration numbers), matching_across_parties and not_allowed by name. Recorded in contact_merges, which the two guards of what was posted read in this transaction alone, and written to the trail as contacts_merged, with line_contact_merged and document_contact_merged for each posted row moved. Answers the row of contact_merges: the two contacts, who merged them, what moved, table by table, and what was filled. |
| `module_enabled(p_company_id uuid, p_code text)` | The helper a module's row level security policies call: this module is enabled on this company and the caller is a member of it. One call, and the answer to a stranger is no. |
| `module_entry_id(p_company_id uuid, p_module_code text, p_ref text)` | The entry a module already posted under a reference, or null. What a module reads before deciding it has work to do. |
| `module_functions_follow_the_socle(p_schema text)` | Gives every function of a module's schema that carries no search_path one of its own — the module's schema, then ekwo — and the same to the SQL helpers of the socle the module's policies fold in, so that what runs under a request served with the module's profile finds the socle. Called by the installer after a module's migrations; answers how many were set. Owner only. |
| `module_is_enabled(p_company_id uuid, p_code text)` | Whether a module is enabled on a company. Definer so a policy on company_modules cannot recurse into it. On a shared installation, false to a caller who may not know of the company (decision 0065). |
| `module_settings(p_company_id uuid, p_code text)` | The settings a company keeps for one of its modules, or null when the module is not enabled. The socle never looks inside the object. On a shared installation, null to a caller who may not know of the company (decision 0065). |
| `name_agreement(p_text text, p_words text[], p_name text, p_name_words text[])` | How far a text agrees with a contact's name, from their significant_words(): 0.950 when the text is the whole name, 0.900 when every word of one is in the other, 0.650 to 0.900 by the share of the shorter that the two have in common, null when they share nothing. The one score of a name, read by contact_candidates() and suggest_duplicate_contacts(). |
| `name_among_several(p_score numeric, p_reached bigint)` | The score of a name once it is known how many contacts the same words reached (decision 0072): capped at 0.600 when they reached more than one, unless the text is the whole name (0.950). Read by contact_candidates() and suggest_duplicate_contacts(). |
| `next_entry_number(p_journal_id uuid, p_date date)` | Next number for a journal, on the pattern the country pack declares. Atomic: the counter row is locked, not the journal. Definer, because the counter is infrastructure and nobody writes it by hand. |
| `next_matching_number(p_company_id uuid)` | Next reconciliation letter for a company, as A0001. Definer, for the same reason as next_entry_number. |
| `note_company_export(p_company_id uuid)` | Writes `company_exported` on the audit trail. Called by `export_company()` and by `ekwo company export` before they read. A record of the act, not a control: a member can always read, table by table, what they may read. Definer because nobody writes the trail; guarded by company.export. |
| `number_counter(p_format text, p_number text)` | The counter inside a number, read back through the pattern it was written with, or null when the number does not follow that pattern. What lets an import advance the sequence it interrupted. |
| `numbering_rules(p_company_id uuid, OUT number_format text, OUT numbering_gapless boolean, OUT pack_number_format text)` | The pattern of a company's document numbers — its own, or its country's — whether the law forbids a hole, and the country's pattern alone. The only function that reads the pack's numbering. |
| `open_items(p_company_id uuid, p_contact_id uuid, p_as_of date, p_third_party_only boolean)` | Lines with something still open on a reconcilable account, with the document behind each and the references it carries. Where there is no document — the debt of a declaration, an entry keyed by hand — the entry's own reference answers. p_third_party_only keeps the receivable and payable lines alone, by account_type; left out, every reconcilable account answers, the bank's included. Read by the matching, and by anybody asking what is still owed. |
| `opening_balance(p_company_id uuid, p_fiscal_year_id uuid, p_lines jsonb, p_allow_result_accounts boolean, p_opening_date date, p_items jsonb)` | Posts a trial balance from a previous system as the opening entry of a fiscal year, on p_opening_date — the day the books were taken over, the first day of the year by default. Balance-sheet accounts only, unless the caller allows the others. p_items are the invoices and credit notes still open on that day, each posted as a document by post_document() against the suspense account, carrying the balance of the receivable or payable account they fall on, which they must add up to. |
| `opening_journal_id(p_company_id uuid)` | The journal the opening and year-end entries go on, named by the pack of this company's country. Null when the pack names none, and the callers refuse rather than guessing at a code. |
| `pack_upgrade(p_company_id uuid, p_country character, p_apply boolean)` | Moves a company onto the pack version this installation holds, or lists what it would do with p_apply false. Needs company.write, of a signed-in member or of the machine key presented — the installer alone is exempt, and a key is never the installer. |
| `pack_upgrade_diff(p_company_id uuid, p_country character)` | What separates a company from the country pack this installation now holds, by natural key, each difference carrying the rule that decides what an upgrade does with it. What a tax books is compared as one object, every declaration box of every posting included. |
| `party_identifier(p_number text)` | A VAT or registration number as two of them are compared: letters and digits only, upper case; null when nothing is left. Read by merge_contacts() to refuse different_identifiers and by suggest_duplicate_contacts() to propose a pair, so the two never disagree on what is one number. |
| `periodic_return_code(p_company_id uuid)` | The code of the periodic return the company's fiscal country files, when the installation carries exactly one. Null when it carries none — no pack for that country — and null when it carries several, because then no single form is what a column named after "the" return could mean. It is what holds companies.vat_period and company_filing_periods in step, and it names the form by asking the pack rather than by knowing a country. |
| `pin_referenced_accounts(p_company_id uuid)` | Pins every account this company points at by a role, a journal, a tax posting or a cash-basis transition, and returns how many accounts are pinned afterwards. Called by install_country_template(); callable again after an upgrade added a tax. |
| `portfolio_filings_touched_since(p_from date, p_to date)` | Declarations that have gone and whose period the ledger moved afterwards, in every company the caller holds filings.read on, and in no other — filings_touched_since() with the company named, the latest disturbance first. Every company of the portfolio is in the answer at least once: one that was not disturbed is a row with no filing, and `filed` says how many of its declarations were looked at. Invoker: it reads what the caller could have read company by company. |
| `portfolio_upcoming_filings(p_from date, p_to date)` | What falls due between two dates in every company the caller holds filings.read on, and in no other: the periods and the instalments upcoming_filings() produces, kept when the day they are due is in the window. Every company of the portfolio is in the answer at least once, and a row without a date says why in `reason` — no_deadline_rule where the pack names no day for the form, nothing_due where nothing of the company falls in the window, no_form where the installation carries no return for it. instalment is set on a payment on account and null on a return. Invoker: it reads what the caller could have read company by company. |
| `post_document(p_document_id uuid)` | Books a document: one entry, the bases on the accounts of the lines, the tax of each group rounded once and shared over the postings of the tax, each ledger line naming the posting type that wrote it. Refuses a tax whose applies_*_territory the document contradicts — read with territory_within_for_tax(), so a territory outside its parent's tax does not satisfy a condition naming the parent — or whose applies_supply_vs_seller it contradicts, by name, before anything reaches the ledger; chooses no tax for anybody. Writes the three territories it resolved on the document (seller_territory_code, buyer_territory_code, supply_territory_resolved). Groups the lines by account, tax and analytic split, and copies the split of each group onto the ledger line it writes; refuses analytic_axis_required, before anything is written, when a line leaves part of a required axis off (decision 0076). For a tax computed inside its own base the box of the base reports the base plus its cumulated share of the group's tax, and a group whose lines disagree on it is refused, mixed_base_includes_tax (decision 0077). |
| `post_entry(p_entry_id uuid)` | Validates, numbers and posts an entry. Raises rather than warning: a swallowed error is a missing entry. Where the country forbids a hole in the sequence it refuses a number chosen by hand, unless the caller holds entries.import — and then the counter catches up to it. |
| `post_module_entry(p_company_id uuid, p_module_code text, p_ref text, p_date date, p_description text, p_lines jsonb, p_journal_id uuid)` | The only way a module reaches the ledger: it hands over lines as data and this builds the draft and calls post_entry(). The tag (module_code, ref) is unique per company, so posting the same thing twice is refused by the database. |
| `post_payment(p_payment_id uuid)` | Books a payment: the bank side from the payment's bank account or its journal, the third-party side by role, both in the company currency at the payment's rate. Matches nothing. |
| `post_turnover_tax(p_company_id uuid, p_from date, p_to date, p_date date)` | Posts the tax on turnover of one period as turnover_tax_return() computes it — the expense on the account the regime names, the debt on the account the pack names for what a declaration owes, one entry in the miscellaneous journal through post_entry() — prepares the filing of the period on the regime's form and keeps the computation in turnover_tax_assessments. Once per period: turnover_tax_already_posted. A period that owes nothing posts no entry and still prepares its nil return. |
| `posted_edit_policy(p_company_id uuid)` | What the country of a company says about a posted document: reversal_only or unpost_if_untouched. A country that says nothing gets reversal_only, the stricter of the two, which every law accepts. The only function that reads the column. |
| `preferred_languages(p_company_id uuid)` | The languages to try, in order: the signed-in user's own, then the company's, then the one the country pack declares. The particular case of preferred_languages(language, company) where the starting point comes from the session. |
| `preferred_languages(p_language text, p_company_id uuid)` | The languages to try, in order, from a starting point the caller names: that one, then the company's, then the one the country pack declares. Feed it to label_for(). On a shared installation the company's are left out for a caller who may not know of it (decision 0065). |
| `prepare_filing(p_company_id uuid, p_from date, p_to date, p_report_code text)` | Computes the declaration and keeps the answer, box by box and kind by kind, each figure at the unit the form is filed in (filing_rounding()), with the day it is due under the pack's rule (filing_deadline()) — written when the filing is created, filled on a draft that has none, never overwritten. Called again on a draft it refreshes; on a declaration that has gone it refuses and says the word for what is needed instead — a corrective. |
| `present_api_key(p_secret text)` | Presents a machine key for the current transaction and answers nothing. What `ekwo_pre_request()` calls, and the only form of the question an anonymous caller may ask: the refusals of use_api_key() word for word, and no row. |
| `product_report(p_company_id uuid, p_from date, p_to date)` | What each product brought in and cost over a period, read from the posted invoices and credit notes dated in it: for each product named on a line, on each side (sale, purchase), the documents that named it, the quantity and the untaxed amount in the company's currency, a credit note counting against its invoice. Drafts, quotes, orders and lines naming no product say nothing. A retired product keeps reporting, with active false. Security invoker: documents.read, through the row level security of the lines. |
| `products_check_classifications()` | Asks assert_classifications() of a product whose attributes are written. |
| `purge_audit_log(p_before date)` | Drops audit rows older than a date the caller names; the table checks the date again and records the purge. service_role only: retention is the operator's decision and no signed-in user may make it. |
| `receive_purchase_document(p_company_id uuid, p_reference text, p_taken_at timestamp with time zone, p_files jsonb)` | A purchase document sent from a phone to the inbox of a company: one draft purchase_invoice, client_ref the reference the phone gave it, dated the day it was taken (the caller's time zone when they set one), in the company's currency, with no contact and no line yet, and one attachments row per page on it, in the order given. p_files is [{storage_path, file_name, mime_type, byte_size}]; every path is a file under <company_id>/inbox/<reference>/ of the bucket attachments, and an object there where the installation has Storage (inbox_path_outside, inbox_file_missing); every type an image or a PDF (inbox_file_type). Needs documents.write (not_allowed, 42501). Idempotent on (company, reference): a second call returns the same document and adds only the pages it does not hold, by path. Security invoker. Decision 0091. |
| `reconcile(p_line_a uuid, p_line_b uuid, p_amount numeric)` | Matches a debit line against a credit line of one counterparty — two lines that both name one have the same commercial_entity() (reconcile_contact_mismatch otherwise), and a line naming nobody is attributed by the matching — in the currency the two share when it is not the company's, and books what the matching reveals: the realised exchange difference, and the share of a cash-basis tax that has become due. The one writer of reconciliations, with unreconcile(). |
| `reconcile_batch(p_pairs jsonb)` | Matches several pairs of lines in one gesture — the pairs suggest_sure_pairs() gives, or any a person accepts — and records it in reconciliation_batches, named on each matching. p_pairs is a JSON array of {"debit_line_id", "credit_line_id"} objects or of [line, line] arrays. Each pair goes through match_lines(), the checks of reconcile_many(): posted, one company, one reconcilable account, one counterparty, the company's currency, open, a debit and a credit, equal to the cent. All or nothing: the first refusal refuses the batch, with its name first and the pair it was given for, "(pair k of n)". Refuses before that no_pairs_named, pair_malformed, duplicate_line, unknown_line, reconcile_company_mismatch and not_allowed (reconcile.write). Returns the batch; unreconcile_batch() undoes it. |
| `reconcile_many(p_line_ids uuid[])` | Matches several lines together — one payment against three invoices, one invoice against three instalments — when their open debits and credits are equal to the cent: posted lines of one company, on one reconcilable account, of one counterparty (a line naming nobody is attributed by the matching), in the company's currency, each with something open. Pairs them oldest first through reconcile(), under one letter. Refuses by name: no_lines_named, duplicate_line, unknown_line, reconcile_company_mismatch, not_allowed (reconcile.write), line_not_posted, reconcile_account_mismatch, account_not_reconcilable, reconcile_contact_mismatch, reconcile_foreign_currency, line_not_open, reconcile_same_side, reconcile_unbalanced. Returns the letter, the amount matched and the matchings written. |
| `reconcile_with_difference(p_line_ids uuid[], p_reason text)` | Matches the same set of lines as reconcile_many() when their totals differ by no more than the company's difference tolerance (matching_difference_tolerance()): posts an entry in the miscellaneous journal, on the day of the latest line, that books the difference on the same account and counterparty against the account the pack gives for p_reason (matching_difference_reasons(): rounding, exchange_difference), then matches everything under one letter. unreconcile() of the matching of the difference line takes the entry back. Refuses as reconcile_many() does, and unknown_difference_reason, no_difference, difference_above_tolerance, no_account_for_reason, account_takes_no_entries, no_miscellaneous_journal. |
| `reconciliation_batches_guard()` | Refuses a batch of matchings written or changed other than by reconcile_batch() and unreconcile_batch(): batch_by_reconcile_batch. They raise ekwo.reconciling around their writes, honoured for a caller holding reconcile.write. |
| `reconciliations_guard_cancelled()` | Refuses to undo a matching on the entry of a cancelled document: cancel_document() matched it against its credit note, and that matching is what makes cancelled true. Unmatching it would leave a document that says cancelled and not_paid at once. document_cancelled_stays_matched, for everybody. |
| `reconciliations_guard_reconcile()` | Keeps reconciliations to the two functions that check a matching and book what it moves: a row is inserted or updated by reconcile() and deleted by unreconcile(), under the setting ekwo.reconciling, honoured for a caller holding reconcile.write. reconciliation_by_reconcile otherwise. The cascades of a company and of an entry line pass, and so does the installer. |
| `record_filing_files(p_filing_id uuid, p_sent_file_id uuid, p_acknowledgement_id uuid)` | Names the two files of the last send of a declaration: the file that was sent and the acknowledgement that came back, each an attachment of that declaration. A file left null keeps what the deposit named. Asks filings.write, the right of file_filing(), and refuses a declaration that was not sent, one a corrective replaced, and a file kept on something else or in another company. |
| `record_filing_outcome(p_filing_id uuid, p_state tax_filing_state, p_reference text, p_message text)` | What came back: accepted, rejected, or paid, written on the declaration and on the send it answers — with the administration's own words where it gave any. Paying follows acceptance, and a declaration that never went cannot come back at all. Asks filings.write. |
| `record_filing_proof(p_subject_kind filing_proof_subject, p_subject_id uuid, p_sha256 text, p_method filing_proof_method, p_proof_base64 text, p_calendars jsonb, p_attachment_id uuid, p_values_sha256 text)` | Records the proof a client just obtained for the sha256 of a file about a declaration, annual accounts or a document. Needs filings.prove. The proof is given as base64, the calendars as a JSON array. The same bytes recorded again by the same method return the existing row; for a declaration, values_sha256 is computed from its boxes and never taken from the caller. |
| `refuse_merged_contact()` | Trigger, its argument the column that names a contact: refuses contact_merged on a row written or moved to name a contact that merge_contacts() retired, with the contact that holds its history now (decision 0074). Attached to every table referencing contacts by refuse_merged_contacts_in(). |
| `refuse_merged_contacts_in(p_schema text)` | Attaches refuse_merged_contact() to every column of a schema that references contacts, read from the foreign keys, so that no row names a merged contact (decision 0074). Returns how many it attached. For migrations, the socle's and the modules'; executable by nobody else. |
| `register_instance(p_contact_email text)` | Opt-in: records an address and a date so Ekwo can reach the operator. Never required, and reversible with unregister_instance(). |
| `rehearse_post_document(p_document_id uuid)` | What post_document() would write, without writing it: the function is called for real inside a block that is then rolled back, so every rule, lock and refusal is the real one. The entry number shown is the one it would take now; somebody else posting first takes it instead. Amounts are text. |
| `remove_member(p_company_id uuid, p_user_id uuid)` | Takes a member out of a company and returns the row that left. Needs members.manage, except to leave oneself. The last owner of a company is refused, themself included: promote a successor first. Pending invitations are not touched; revoke_invitation() withdraws them. |
| `reopen_filing(p_filing_id uuid)` | Takes a rejected declaration back to draft so its figures can be worked out again. Only a rejected one: a declaration the administration accepted is replaced by a corrective, never rewritten. What was sent stays in tax_filing_deposits. |
| `reopen_fiscal_year(p_fiscal_year_id uuid)` | Undoes an ordinary close: reverses the appropriation and closing entries it wrote and clears is_closed, whatever a later year holds — the close wrote nothing there, and the later year reads the result from the ledger. Refused for a year under a final close (fiscal_year_finally_closed), for everybody, and while a later year is closed (later_fiscal_year_closed), which is reopened first. |
| `replace_document_lines(p_document_id uuid, p_lines jsonb)` | Replaces every line of a draft with the lines given, in one statement: when the database refuses one of them, the draft keeps the lines it had. Security invoker, so row level security and the guards of document_lines decide as for a direct write. |
| `resolve_counterpart_account(p_company_id uuid, p_contact_id uuid, p_is_sale boolean)` | Third-party account by role: contact override first, company default second. Never by code prefix. |
| `resolve_line_account(p_company_id uuid, p_doc_type doc_type, p_account_id uuid)` | Account of a document line: the line, then the company default, then the country model. Never a code prefix. |
| `resolve_line_account(p_company_id uuid, p_doc_type doc_type, p_product_id uuid, p_account_id uuid)` | Account of a document line: the line, the product, the company default, the country model. Never a code prefix. |
| `reverse_entry(p_entry_id uuid, p_date date)` | Undoes a posted entry: writes its mirror in the same journal — every line with its sides swapped, its tax, its box with the opposite sign and its analytic split — names it in reversed_entry_id, posts it through post_entry() and matches the two on every reconcilable line. Dated on the original's day while that period is open, and otherwise refused until a date is given (reversal_date_needed). Refused for an entry that is not posted, is a reversal, is already reversed, is matched, or belongs to a document (cancel_document()), a close (reopen_fiscal_year()), an opening, a payment, a bank transaction, a module, a declaration or a matching. |
| `revoke_api_key(p_api_key_id uuid)` | Withdraws a key. There is no un-withdraw: a secret that has been out of the building is issued again, not brought back. |
| `revoke_invitation(p_invitation_id uuid)` | Withdraws an invitation that has not been accepted. An accepted one is a member, and members are removed from company_members. |
| `revoke_share(p_share_id uuid)` | Withdraws a link, now and for good. A withdrawn link answers exactly like one that never existed; there is no un-withdraw, because a secret that has been out of the building is issued again rather than brought back. |
| `round_amount(p_amount numeric, p_rounding money_rounding)` | Rounds an amount at the decimals of its currency, by the method of its country. The only function of the schema that names a rounding method; every other one asks rounding_of() and passes the answer here. |
| `rounding_of(p_company_id uuid, p_currency_code text)` | How this company writes an amount in this currency, or in its own when none is named. The only place currencies.decimal_places and country_defaults.rounding_method are read. |
| `scope_references_to_company(p_schema text)` | Makes every reference of a schema from a company's table to another company's table by id alone a composite key with the company — company_id, or the id of companies itself (company_column()) — keeping its delete action, and drops the single-column key: where a composite one stood beside it too, the two failed with different names for an id of another company and an id of nobody. Then adds the company to every unique key of those tables that holds such a reference and not the company, which a row naming another company's row collided with before any foreign key was asked (decision 0065). Asks assert_references_within_company() first, so a row that would fail a new key stops it before anything changes. Returns how many it changed. For migrations, the socle's and the modules'; executable by nobody else. |
| `set_line_contact(p_line_id uuid, p_contact_id uuid)` | Names the contact of an open line on a receivable or payable account that names nobody — once, from null to a contact of the same company — and learns from it through learn_contact_patterns(), as confirm_contact() does for a statement line. Needs reconcile.write. Refuses unknown_line, line_not_posted, line_has_contact, line_matched, line_not_third_party and unknown_contact by name. The guard of a posted line lets this one column through for this function alone and writes line_contact_named to the trail (decision 0070). |
| `set_member_role(p_company_id uuid, p_user_id uuid, p_role member_role, p_capabilities jsonb)` | Moves a member to another preset. Needs members.manage; the last owner of a company is not demoted. The per-member adjustments are reset, as accept_invitation() writes a new member: capabilities_granted becomes p_capabilities (none by default) and capabilities_revoked is emptied, because an adjustment was decided against the preset the member leaves. |
| `set_preferences(p_patch jsonb)` | Writes the signed-in user's preferences. A key that is present is written, null included; a key that is absent is left alone; a key nobody declared is refused. |
| `set_updated_at()` | Generic BEFORE UPDATE trigger keeping updated_at honest. |
| `settle_cash_basis_tax(p_document_id uuid, p_date date)` | Moves the share of a cash-basis tax that settlement has made due, from the transition account to the account and the box it is declared on. Derived from the ledger, so it is the same call whether a matching was made or undone. |
| `settle_filing(p_filing_id uuid, p_credit tax_credit_treatment, p_reference text, p_contact_id uuid, p_date date)` | Clears the tax accounts a declared period moved and carries the net to the account the pack names for what is owed to the administration — or, where the period ends in a credit, to the one it names for a credit, once the company has said whether it is carried forward or claimed back. One entry per declaration, through post_entry(), with the reference the payment will be matched by. The net names the administration: the contact passed, or else the company's own, found or created by tax_payee() — matching books a payment, and a payment is made to somebody. |
| `settle_from_statement(p_transaction_id uuid, p_line_ids uuid[], p_amounts numeric[], p_extra_lines jsonb)` | Books the payment a statement line is, and matches it against the open items named, in one entry through post_entry() and one transaction. p_amounts, beside p_line_ids, says how much settles each item (partial settlement, several items at once); without it the items are settled oldest first, and in full when there are extra lines. p_extra_lines books beside the settlement what the money is net of or carries besides — a fee a payment provider kept, bank charges, a small difference — as [{account, amount, tax?, description?}]: account and tax are codes of the company, a positive amount is a charge (debit) and a negative one a credit, and a tax is taken out of the amount from the postings of a purchase invoice. The line balances to the cent — money in is the items less the charges, money out the items plus the charges — or settlement_unbalanced names the difference; extra lines alone settle a bank charge with no item. Without extra lines, post_payment() books the payment as before. The matchings are reconcile()'s, one counterparty; the one writer of bank_transactions.entry_id and of the reconciled state, which bank_transactions_guard() holds it to. |
| `share_document(p_document_id uuid, p_expires_at timestamp with time zone)` | Publishes a sales document behind a link and returns the token once — only its hash is stored. `url` is the instance's public base plus /shared/<token>, or null where the instance has not recorded one. A share is never edited: revoke it and make another. |
| `share_instance(p_companies_per_person integer)` | Turns the shared setting on (decision 0065): a signed-in person may create up to this many companies of their own, and nobody learns of a company they may not know of. The installer or an instance administrator, on an installation that has an administrator. |
| `shared_document(p_token text)` | One document, read by whoever holds its link: the header, the lines with the price as it was keyed and whether that price holds the tax, the tax breakdown, the totals, the legal mentions in the language the document was written in, and what is still owed today. Returns null — the same null, in the same shape — for a token that is unknown, withdrawn, expired, or onto a document that may no longer be shared. |
| `significant_words(p_text text, p_minimum_length integer)` | The words of a name that are long enough to be evidence, lowercased and deduplicated. No stop list: a word shared by several contacts is disqualified by the count of what it reaches, which is a fact about this company rather than an opinion about a language. |
| `statement_account_matches(p_company_id uuid, p_statement_code text, p_from date, p_to date)` | Which line of a statement each account of a company falls on, with its balance: cumulative to the end date on a balance sheet, over the period otherwise. On a balance sheet the income and expense accounts no line catches are the result nobody has closed yet, and stand as one balance on year_result_account(); in_progress is the part of each balance that is that result — an income or expense account a line catches, or the moved result — and nil elsewhere. The one place statement_figures() and unmapped_accounts() read. |
| `statement_figures(p_company_id uuid, p_statement_code text, p_from date, p_to date)` | A financial statement as financial_statement() returns it, with in_progress beside each line: the part of the line that is the result of the year nobody has closed, read with the line's sign — nil on a total, on a statement that is not a balance sheet, and once the year is closed. Read by financial_statement() and financial_statement_of_kind(), so the ledger is summed once. |
| `statement_rule_catches(p_rule statement_line_rules, p_code text, p_account_type account_type, p_balance numeric)` | Whether a rule of a statement line takes an account with this code, type and balance. A call to account_rule_catches(), so a statement and an analysis read a rule the same way; read by statement_account_matches(). |
| `storage_path_company(p_name text)` | The company a file of the bucket attachments belongs to: the first folder of its path when it is a company id, else null. Read by the policies of storage.objects on that bucket. |
| `suggest_combination(p_transaction_id uuid)` | A subset of one counterparty's open items that adds up to the statement line, found by combination_subsets() over the oldest items of the window — the oldest-first answer when there is one. A proposal only: it is never applied automatically, because a sum that reaches the right total from the wrong documents leaves nothing behind to notice. |
| `suggest_contacts(p_transaction_id uuid)` | Who this statement line could be, with the score, the evidence in a sentence, and how many contacts that same evidence reached — contact_candidates() with the facts of the line. It writes nothing and decides nothing: a caller that applies a match on its own is expected to require alternatives = 1. |
| `suggest_duplicate_contacts(p_company_id uuid)` | The contacts of a company that are probably one party (decision 0075): one row per contact to absorb, strongest first — keep_id, the contact of its group the most ledger lines and documents name (then the older), absorb_id, score from 0 to 1, evidence (the kinds, strongest first, comma-separated: vat_number, registration_number, account, name), because (the evidence in sentences) and proposed_name, the simplest name the group carries (the fewest words carried by contacts outside the group, then the fewest words, then the shortest). The pairs are found on the same VAT or registration number (party_identifier()), the same bank account on the contact or in a learned motif (account_key()), both scoring 1, and by name, each word weighing 1 over the contacts of the company that carry it, scored as contact_candidates() scores a name; the contacts a chain of pairs joins are one group, with one contact to keep. Rows of one group share their keep_id. A pair across companies, with two different VAT or registration numbers, or of a contact and its own parent is never proposed. It writes nothing and decides nothing; merge_contacts() joins a pair a person chose, and the name proposed is written only by the person. |
| `suggest_item_combinations(p_company_id uuid, p_contact_id uuid)` | What open receivable and payable lines of one counterparty on one account could settle each other — of the company, or of one contact (a branch and its parent are one party), as matchable_lines() reads them. For each open line (line_id), up to three proposals, in this order: one line of the other side for the same amount (kind pair, said once, from the debit), several lines that add up to it to the cent (kind combination, found by combination_subsets()), and only when nothing is exact, a pair then several lines within the company's difference tolerance (difference, signed: the line less the total). proposal_id is stable for the same lines; alternatives counts the proposals of the line. Lines in another currency than the company's are not searched. It writes nothing and decides nothing: reconcile_many() and reconcile_with_difference() settle a proposal a person chose; suggest_sure_pairs() says which pairs leave nothing to choose. |
| `suggest_line_contacts(p_company_id uuid, p_line_ids uuid[])` | Who each open line on a receivable or payable account that names nobody could be — every such line of the company, or those of p_line_ids — with the candidates contact_candidates() finds, one row per line and contact, best first: a motif, the number of a document of the line's side, the words of a name (capped at 0.600 when they reach several contacts). A line left unnamed by leave_line_unnamed() is not proposed. It writes nothing and decides nothing; set_line_contact() names the line. Lines it cannot read, or of another company, give no row. |
| `suggest_matches(p_transaction_id uuid)` | What a statement line could settle: the open items it matches, the evidence, and how many candidates that same evidence produced. Writes nothing. A combination of several documents is offered by suggest_combination(), separately, because it is a resemblance and not an identification. |
| `suggest_sure_pairs(p_company_id uuid, p_contact_id uuid)` | The pairs of open lines that leave nothing to choose, among the lines matchable_lines() reads (of the company, or of one party): a debit and a credit of one counterparty on one account, open for the same amount to the cent, each line in one pair at most. evidence says why, in the order the rules are read, each on what the earlier ones left: same_document (both lines of one document, or the settlement's entry carries the document's number or payment reference), reversal (an entry and what undoes it: reversed_entry_id, or a credit note naming the invoice), unique_amount (the one open debit and the one open credit of that amount), recurring_in_date_order (several lines of one amount: the oldest invoice — the debit of a receivable, the credit of a payable — with the first settlement dated on or after it, then the next; a settlement dated before an invoice is never its pair). It writes nothing: reconcile_batch() matches the pairs a person accepts, as one gesture undone by unreconcile_batch(). |
| `supersede_filing(p_filing_id uuid)` | Opens a corrective: the declaration that went becomes superseded and a new draft is prepared from today's ledger, at the unit the form is filed in, pointing at it. What was sent stays as it was sent. |
| `tax_amount_of(p_amount numeric, p_rate numeric, p_price_include boolean, p_base_includes_tax boolean)` | The tax of a group, unrounded: on the net at the rate, or taken out of the gross where the price includes the tax, and in both cases computed inside its own base where the tax says base_includes_tax (decision 0077). The one place the arithmetic is written; the breakdown, the allocator and the line all ask it. |
| `tax_filing_deposits_files_are_its_own()` | Refuses a deposit whose sent file or receipt is not an attachment of its declaration's company, in the same words for a file of another company and a file of nobody, before either foreign key is asked; and a person or a key who names a declaration of a company they may not know of, before anything is read (decision 0065). |
| `tax_filing_values_sha256(p_filing_id uuid)` | sha256 of the figures of a declaration in canonical form: one canonical_json() line for {report_code, period_start, period_end}, then one per box {box, kind, amount} in box then kind order. Null for a declaration whose figures were never computed, or that the caller may not read. |
| `tax_filings_paid_by_matching()` | Records a declaration paid once the line its settlement carried the net on is matched in full, and accepted again when that matching is undone — by whatever path the money was matched: the bank, auto_settle(), reconcile(), an import. Through write_filing_outcome(), the body of record_filing_outcome(), so the last send carries the outcome as it would by hand, whoever matched the payment. |
| `tax_payee(p_company_id uuid)` | The contact of this company that is its tax administration: the one contact that books to the account the pack names for what a declaration owes — under a name the pack gives, in any of its languages, where several do — created on first need under the name the pack gives in the company's language (country_defaults.tax_payee_name_i18n), else in the pack's own (tax_payee_name), booking both ways to the accounts settle_filing() uses. Null where no contact books to that account and the pack names no administration. Asks filings.write. |
| `tax_point_of(p_company_id uuid, p_document_date date, p_delivery_date date, p_payment_date date)` | The day the tax on a document falls due, under the rule its company's country declares. The only function that reads country_defaults.tax_point_rule, and the only place the vocabulary of that column is written out. Null where the country declares no rule or where the rule names a date the caller does not have, and null means the entry's own date to every reader of it. |
| `tax_posting_boxes_agree()` | Keeps declaration_box and declaration_boxes in step on a tax posting: a writer that moves one is handed the other. A writer that moves both is left alone and judged by the check constraint, and a writer that clears the box clears the list with it. |
| `tax_rate_at(p_tax_id uuid, p_date date)` | Percentage in force at a date, NULL when the tax does not apply then. |
| `taxes_reach_draft_lines()` | A tax whose category, rate or kind of amount changes rewrites the snapshot of the draft lines that carry it, and nothing else: a posted line keeps what it was posted with. |
| `territory_of(p_code text)` | The territory a code or a VAT prefix names, or null when this table carries none. A code wins over a prefix, so FR is France and not the Monaco row that identifies under it. |
| `territory_within(p_code text, p_of text)` | True when the first territory is the second one or lies inside it, following territories.parent_code: US-CA is within US, XI is within GB, and neither is within the other. False for a code this table does not carry. |
| `territory_within_for_tax(p_code text, p_of text)` | territory_within(), cut at every territory whose outside_parent_tax is true: the walk up territories.parent_code stops there. So ES-CN is within ES-CN and not within ES, and US-CA is within US as before. What post_document() reads to judge a tax's territory conditions. False for a code this table does not carry. |
| `touch_api_key(p_api_key_id uuid)` | Records that a key was used just now. A key that has never been used, and one that has not been used for a year, are both things an operator should be able to see. |
| `trial_balance(p_company_id uuid, p_from date, p_to date)` | Opening balance, movements of the period and closing balance per account, posted entries only. |
| `turnover_of(p_company_id uuid, p_from date, p_to date)` | What the posted sale invoices and credit notes booked between two days put on the income accounts, credit less debit, in the company's currency: the turnover a tax on turnover is computed on. |
| `turnover_tax_regime_at(p_company_id uuid, p_date date)` | The regime of turnover_tax_regimes the company is under on that day, or null when it is under the ordinary regime of its taxes. |
| `turnover_tax_return(p_company_id uuid, p_from date, p_to date)` | The tax on turnover of one period of a company under a regime of turnover_tax_regimes, with its arithmetic: the turnover of the period, the window the bracket is read over and its turnover, the months of it the company was active and the base they give, the bracket, its nominal rate and deduction, the effective rate (base x nominal_rate / 100 - deduction) / base, and the tax, the turnover times that rate rounded once at the unit of the form. Reads and writes nothing else. |
| `unarchive_company(p_company_id uuid)` | Restores an archived company: posting, booking and closing are possible again. The act of the owner preset, refused to everybody else with not_allowed. Restoring a company that is not archived changes nothing and answers the row. Writes company_unarchived on the trail. |
| `undo_leave_line_unnamed(p_line_id uuid)` | Takes back leave_line_unnamed(): the line is proposed a contact again. Returns the record it removed. Needs reconcile.write. Refuses unknown_line, not_allowed and line_not_left_unnamed by name. |
| `unmapped_accounts(p_company_id uuid, p_statement_code text, p_from date, p_to date)` | Accounts this statement is answerable for that carry a balance and that no rule of it catches. Empty is what makes the statement tie out; a row is an account somebody opened outside the pack. |
| `unpost_document(p_document_id uuid)` | Puts a posted invoice or credit note back to draft, where its country's posted_edit_policy is unpost_if_untouched and nothing about it has left — every condition is unpost_refusal(), raised by name otherwise, and each refusal says to cancel_document() instead or what to undo first. Records the act in document_unpostings, takes the entry away, gives the number back to the counter where it was the last drawn, and returns the draft — without the number where it was its entry's, and without the booking day and tax point where posting had derived them. Definer, because document_unpostings is written by nobody else; asks documents.post itself. |
| `unpost_refusal(p_document_id uuid)` | Why a posted document may not go back to draft, as the sentence unpost_document() would raise — null where it may. Read first by a client that chooses between unpost_document() and cancel_document(), so that the choice is made here and nowhere else. Asks, in order: documents.post, a posted invoice or credit note, a country whose posted_edit_policy is unpost_if_untouched, never sent nor on Peppol, not settled, not credited, named by no other entry, a period open for its day and every tax point, no declaration gone over them, and — where numbering is gapless — the last number of its journal. |
| `unreconcile(p_reconciliation_id uuid)` | Undoes a matching, and with it what the matching had booked: the exchange difference it realised (its mirror is posted and matched with it), the difference reconcile_with_difference() booked (every matching of its line goes, its mirror is posted and the two lines are matched together), and the share of a cash-basis tax it had made due. The one way a matching is removed; unreconcile_batch() calls it for each matching of a batch. |
| `unreconcile_batch(p_batch_id uuid)` | Undoes a gesture of reconcile_batch(): every matching of the batch still standing goes through unreconcile(), the last written first, and the batch records when and by whom. Refuses unknown_batch (a batch of another company is one that does not exist), not_allowed (reconcile.write) and batch_already_undone. All or nothing, as the batch was. |
| `unregister_instance()` | Undoes register_instance(). Opting in is reversible, or it is not a choice. |
| `unshare_instance()` | Turns the shared setting off: the installation is one customer's again, and creating a company an instance-level act. The installer or an instance administrator. |
| `upcoming_filings(p_company_id uuid, p_from date, p_to date)` | What this company has to file and pay on account between two dates: the periods its cadences produce — any whole number of months, anchored on 1 January — the day each is due where the pack says, and the declaration already prepared or sent against it; and the instalments its scheme asks for, one row each with instalment set to its sequence and the month it falls due in as its period. The periodic return is left out of the periods a regime of turnover_tax_regimes that replaces VAT covers entirely, and a form is left out of the periods the company's VAT scheme does not file it in. Read-only; sending the reminder is somebody else's job, because a reminder needs a channel and somebody to operate it. |
| `upgrade_filing_proof(p_proof_id uuid, p_proof_base64 text, p_anchor_chain text, p_anchor_height bigint, p_anchor_time timestamp with time zone, p_anchor_reference text)` | Replaces the bytes of a pending proof with the longer proof a calendar returned. With an anchor — the ledger, and a block height or a reference — the proof becomes complete and is frozen. Needs filings.prove. |
| `use_api_key(p_secret text)` | Presents a machine key for the current transaction: has_capability() answers for it until the transaction ends. Refuses a key that is unknown, withdrawn or expired. Records the use when the transaction may write — a read request runs in a read-only transaction, where the stamp is worth less than the request. |
| `user_preferences_company_is_known()` | Refuses a preferred company that does not exist or that the person may not know of, with one answer for both (decision 0065). |
| `vat_prefix_of(p_code text)` | The two letters a territory's VAT identification numbers carry: EL for Greece, FR for Monaco, GB for the Isle of Man, and the code itself everywhere else — including for a territory this table does not carry, whose own two letters come back unchanged. Null when what it resolves to is not two letters, which is a territory that identifies under nobody. |
| `vat_return(p_company_id uuid, p_from date, p_to date, p_report_code text)` | Declaration boxes for a period: summed from the ledger by the day each figure's tax fell due — `entry_lines.declared_on`, read through declared_lines() — into the boxes and on the form each line was frozen with when it was written (entry_lines.declaration_boxes and report_code), so a posting changed afterwards moves no return; then the totals of the country's form worked out by evaluate_totals(), the same evaluator financial_statement() uses. A form that restates another (reads_postings_of) adds up the boxes of that form each of its boxes names, and a box that reads the payments on account of the declaration takes them from declaration_instalments or instalment_plan(). Refuses a period the company does not file **this form** on, when it has recorded one for it; under the scheme the company is on (company_vat_schemes) refuses a form the scheme does not file and a cadence it does not file it on, and takes the scheme's form when none is named. No country rule lives in this function. |
| `vat_scheme_at(p_company_id uuid, p_date date)` | The VAT scheme the company is on that day: the row of company_vat_schemes that starts last on or before it. Null when the company has recorded none, which is not an error. Asked for 'infinity', the last scheme the company recorded, which is the one its filing periods follow. |
| `vat_scheme_ceilings_crossed(p_company_id uuid, p_from date, p_to date)` | The ceilings of the scheme the company is on at the end of the period, against its books: the turnover of the period or of the one before it, as turnover_of() reads it, and whether it is above the ceiling. A ceiling counted on goods or on services alone is compared with the whole turnover, which the ledger does not split by activity, so it can only over-warn. measured and crossed are null for a measure the books do not give (tax_previous_year). An alert: it changes no scheme. |
| `vat_scheme_files(p_company_id uuid, p_report_code text, p_date date)` | Whether the company files that form on that day as far as its scheme is concerned: true when it has recorded no scheme, true for a form no scheme of its country names, and otherwise whether its scheme names the form. |
| `version_at_least(p_version text, p_floor text)` | Whether a three-part version is at or above another, number by number: 0.10.0 is above 0.9.0, which a comparison of text gets wrong. |
| `write_filing_outcome(p_filing_id uuid, p_state tax_filing_state, p_reference text, p_message text)` | Writes what came back on a declaration and on its last send, with no check of who asks: called by record_filing_outcome() once the caller's right is checked, and by tax_filings_paid_by_matching as the ledger. Granted to nobody. |
| `year_result_account(p_company_id uuid, p_balance numeric)` | The balance-sheet account the result of a year nobody has closed stands on, for a balance of the income and expense accounts (debit minus credit, so a profit is negative): the current-year result account of a result_accounts pack, retained earnings — the company's own first, for a profit — otherwise. Null when the pack names none. Read by statement_account_matches() and fec_lines(), so a balance sheet and an opening balance put it in one place. |

---

# Modules

One Postgres schema each, beside the socle. A module depends on the socle (`ekwo`) by foreign key
and reaches the ledger only through `post_module_entry()`. It is enabled per company, and
PostgREST serves its schema only once the project exposes it.

## `fixed_assets` — Fixed assets

Fixed assets, their depreciation schedule and their disposal. Durations, declining coefficients and the prorata convention are country pack data.

### Tables

| Table | Purpose |
|---|---|
| [`category_templates`](#fixed_assets-category_templates) | The usual duration and method of a kind of asset in one country, with the source it comes from. A suggestion an asset may depart from, which is why it is never copied into a company. |
| [`country_rules`](#fixed_assets-country_rules) | How one country depreciates and derecognises. Filled by `ekwo pack build` from packs/<cc>/fixed_assets.json, read where it stands, never copied into a company. |
| [`depreciation_lines`](#fixed_assets-depreciation_lines) | One planned period of depreciation. `entry_id` is the entry that booked it, and is what makes running the depreciation of a period twice a no-op. |
| [`disposals`](#fixed_assets-disposals) | What leaving the books cost or earned: one row per fixed asset, written by fixed_assets.dispose_fixed_asset(). There is no undo, for the reason there is no unpost. |
| [`fixed_assets`](#fixed_assets-fixed_assets) | One fixed asset: what it cost, how it is depreciated, and the three accounts that carry it. The schedule is fixed_assets.depreciation_lines. Called assets.assets until version 2.0.0 of the module. |

<a id="fixed_assets-category_templates"></a>

#### `category_templates`

The usual duration and method of a kind of asset in one country, with the source it comes from. A suggestion an asset may depart from, which is why it is never copied into a company.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `name_i18n` | `jsonb` | not null |
| `method` | `fixed_assets.depreciation_method` | not null |
| `duration_months` | `integer` | not null |
| `coefficient` | `numeric(7,3)` |  |
| `prorata` | `fixed_assets.prorata_rule` | Overrides the country rule for this category. Null is the ordinary case: the rule of the country, for the method this category uses. |
| `account_type` | `account_type` | Which of the eighteen account types the asset account of this category is, so a client can propose the accounts of a chart it has never seen. Advisory: nothing resolves an account from it. |
| `sequence` | `integer` | not null |
| `legal_reference` | `text` |  |

Constraints:

- `CHECK (((method <> 'declining_balance'::fixed_assets.depreciation_method) OR (coefficient IS NOT NULL)))`
- `CHECK ((duration_months > 0))`
- `PRIMARY KEY (country, code)`

<a id="fixed_assets-country_rules"></a>

#### `country_rules`

How one country depreciates and derecognises. Filled by `ekwo pack build` from packs/<cc>/fixed_assets.json, read where it stands, never copied into a company.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `prorata_straight_line` | `fixed_assets.prorata_rule` | not null |
| `prorata_declining` | `fixed_assets.prorata_rule` | not null |
| `day_count` | `fixed_assets.day_count` | not null |
| `declining_cap_percent` | `numeric(7,3)` | Largest annuity a declining balance may take in one period, as a percentage of the acquisition value. Null where the country caps nothing. |
| `declining_switch_to_linear` | `boolean` | not null — Whether the declining balance switches to the straight line over the remaining periods once that gives the larger annuity. True everywhere the declining balance is a tax incentive rather than a valuation method. |
| `disposal_style` | `fixed_assets.disposal_style` |  |
| `legal_reference` | `text` |  |

Constraints:

- `CHECK (((declining_cap_percent IS NULL) OR ((declining_cap_percent > (0)::numeric) AND (declining_cap_percent <= (100)::numeric))))`
- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `PRIMARY KEY (country)`

<a id="fixed_assets-depreciation_lines"></a>

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
- `UNIQUE (asset_id, period_end, company_id)`
- `UNIQUE (asset_id, sequence, company_id)`

<a id="fixed_assets-disposals"></a>

#### `disposals`

What leaving the books cost or earned: one row per fixed asset, written by fixed_assets.dispose_fixed_asset(). There is no undo, for the reason there is no unpost.

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
- `UNIQUE (asset_id, company_id)`

<a id="fixed_assets-fixed_assets"></a>

#### `fixed_assets`

One fixed asset: what it cost, how it is depreciated, and the three accounts that carry it. The schedule is fixed_assets.depreciation_lines. Called assets.assets until version 2.0.0 of the module.

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
| `method` | `fixed_assets.depreciation_method` | not null |
| `duration_months` | `integer` | not null |
| `coefficient` | `numeric(7,3)` | Multiplier of the straight-line rate under a declining balance. France 1,25 / 1,75 / 2,25 by duration; Belgium doubles the rate. Required by a check constraint for that method, because a declining balance with no coefficient is a straight line nobody asked for. |
| `prorata` | `fixed_assets.prorata_rule` | How much of the first period this asset takes. Null reads the country rule for its method, and an asset in a country whose pack says nothing is refused by name rather than given another country's convention. |
| `asset_account_id` | `uuid` | not null |
| `depreciation_account_id` | `uuid` | not null |
| `expense_account_id` | `uuid` | not null |
| `state` | `fixed_assets.asset_state` | not null |
| `notes` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((cost > (0)::numeric))`
- `CHECK (((method <> 'declining_balance'::fixed_assets.depreciation_method) OR (coefficient IS NOT NULL)))`
- `CHECK ((duration_months > 0))`
- `CHECK (((in_service_date IS NULL) OR (in_service_date >= acquisition_date)))`
- `CHECK (((residual_value >= (0)::numeric) AND (residual_value < cost)))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, code)`

### Functions

| Function | Purpose |
|---|---|
| `accounts_in_use(p_company_id uuid)` | The accounts this module points at for one company: what its fixed assets are booked, depreciated and charged on, and what a disposal was settled against. Read by ekwo.accounts_in_use() through the module convention. |
| `archive_former_names()` | The names an archive of version 1 of this module filed its tables under, with the name each has today. Read by `ekwo.archive_under_current_names()` before an import. |
| `archive_tables()` | What an archive of one company does with each table of this module. Read by `ekwo.company_archive_tables()`. |
| `can_disable(p_company_id uuid)` | Why this company cannot disable the fixed assets module, or null when it can. The convention disable_module() reads. |
| `create_fixed_asset(p_company_id uuid, p_code text, p_name text, p_acquisition_date date, p_cost numeric, p_asset_account text, p_depreciation_account text, p_expense_account text, p_category_code text, p_duration_months integer, p_method fixed_assets.depreciation_method, p_coefficient numeric, p_residual_value numeric, p_in_service_date date, p_document_line_id uuid, p_contact_id uuid, p_description text)` | Creates an asset and its schedule in one call. A category of the country pack fills in the method, the duration and the coefficient; anything the caller passes wins over it. |
| `days360(p_from date, p_to date)` | Days between two dates on a year of 360 days and months of 30, the day capped at the 30th. Half-open: days360(1 January, 1 January of the next year) is 360. |
| `dispose_fixed_asset(p_asset_id uuid, p_date date, p_proceeds numeric, p_counterpart_account text, p_contact_id uuid)` | Takes an asset off the books on a date: clears its cost and its accumulated depreciation, books the proceeds, and presents the result the way the country's pack says — one gain or loss line, or the value and the proceeds in full. |
| `generate_schedule(p_asset_id uuid)` | Writes the depreciation schedule of an asset, period by period, rounded at the decimals of the company's currency with the last line taking the remainder. Refuses to rewrite a schedule whose lines are already booked. |
| `movements(p_company_id uuid, p_from date, p_to date)` | What came in, what was written off and what went out between two dates, per asset — the movement table an annual account asks for beside the register. |
| `prorata_fraction(p_rule fixed_assets.prorata_rule, p_day_count fixed_assets.day_count, p_start date, p_period_start date, p_period_end date)` | The share of a period that runs from the day an asset entered service. A prorata in days counts the day of entry into service itself, which is the convention that makes a full year come to exactly one. |
| `register(p_company_id uuid, p_at date)` | The table of fixed assets at a date: what each one cost, what has been written off it, and what is left. Reads what has been booked, so it ties to the ledger. |
| `rules(p_company_id uuid)` | The depreciation rules of this company's country, or an empty row when its pack says nothing. The callers name what is missing rather than borrowing another country's answer. |
| `run_depreciation(p_company_id uuid, p_period_end date)` | Books every planned period that ends on or before a date, one entry per period, through post_module_entry(). Idempotent: a period already booked is skipped. An asset added after its period was booked supplements it with an entry tagged depreciation:<period end>:<n>. A closed financial year refuses the posting, because post_entry() asserts the period is open. |
| `split_into_months(p_asset_id uuid)` | Splits each annuity of a schedule into months, over the months the asset is in service in: from the month it entered service and, for a straight line, to the month its life ends. The last eligible month of each annuity takes the rounding remainder. |

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
- `UNIQUE (budget_id, account_id, period_start, period_end, company_id)`

### Functions

| Function | Purpose |
|---|---|
| `accounts_in_use(p_company_id uuid)` | The accounts this module points at for one company: every account a budget line plans an amount on. Read by ekwo.accounts_in_use() through the module convention. |
| `archive_tables()` | What an archive of one company does with each table of this module. Read by `ekwo.company_archive_tables()`. |
| `variance(p_company_id uuid, p_budget_id uuid, p_from date, p_to date)` | Budget against ledger, per account, over a period, at the decimals of the company's currency. Both figures are in the sign a business states them in — an income account's credit balance is flipped — and the variance is the actual less the plan. Reads posted entries of kind `normal` only: a closing or appropriation entry is not what a period earned. |

## `contracts` — Contracts

What a company agreed with another party, kept beside the books on the same contacts: dates, renewal, notice, value, the signed file, amendments and templates, and schedules that issue draft sales or purchase invoices when their periods come. Knows no country, and never writes the ledger itself.

### Tables

| Table | Purpose |
|---|---|
| [`amendments`](#contracts-amendments) | Every text a contract had and every change made to it, numbered from 1 in the contract: a version of the text with its file, an amendment — what changes, from when, signed when, with the signed file — or a tacit renewal. |
| [`contracts`](#contracts-contracts) | One agreement with one party of the books: what it is about, which side the company is on, where it stands, its dates, how it renews and with how much notice, its value in its currency, the signed file. Its number is the company's own, unique in the company, and is written on every document it issues (contract_reference, EN 16931 BT-12). |
| [`issues`](#contracts-issues) | Which document of the socle a schedule issued for which period: one row per schedule and first day of a period, written by contracts.issue_due(). A draft that is deleted takes its row with it. |
| [`schedules`](#contracts-schedules) | A line a contract invoices, at its own rhythm: what (a product, or a name), how many, in which unit, at what price, under which tax, every week, month, quarter or year from next_on until until. Each period that has come is issued as one draft document by contracts.issue_due(). |
| [`templates`](#contracts-templates) | What a contract starts from: its clauses — an html text or a docx file — with the variables they name, a category, and a template schedule. contracts.from_template() makes a draft contract of one. |

<a id="contracts-amendments"></a>

#### `amendments`

Every text a contract had and every change made to it, numbered from 1 in the contract: a version of the text with its file, an amendment — what changes, from when, signed when, with the signed file — or a tacit renewal.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `contract_id` | `uuid` | not null |
| `number` | `integer` | not null — The place of the row in the contract's history, 1 first. A version keeps the number its file had. |
| `kind` | `contracts.amendment_kind` | not null |
| `summary` | `text` | not null — What changes, in words. |
| `changes` | `jsonb` | not null — What changes, as data: the fields of the contract that took a new value, and under "schedules" the fields of each schedule, by id. Empty for a version. |
| `effective_on` | `date` | not null — From when the change holds: the first day of the new term for a renewal. |
| `signed_on` | `date` |  |
| `attachment_id` | `uuid` | The file of this version or of the signed amendment: an attachment of the socle, with its checksum. |
| `created_by` | `uuid` | Who recorded it: acting_user(), the signed-in person or the issuer of the key presented; null for a renewal written by the module. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((jsonb_typeof(changes) = 'object'::text))`
- `CHECK ((number > 0))`
- `CHECK ((length(btrim(summary)) > 0))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, contract_id, number)`

<a id="contracts-contracts"></a>

#### `contracts`

One agreement with one party of the books: what it is about, which side the company is on, where it stands, its dates, how it renews and with how much notice, its value in its currency, the signed file. Its number is the company's own, unique in the company, and is written on every document it issues (contract_reference, EN 16931 BT-12).

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `contact_id` | `uuid` | not null — The other party: a customer on a sale, a supplier on a purchase. A row of ekwo.contacts of the same company. |
| `number` | `text` | not null — The company's reference for the contract, unique in the company. Copied onto every document the contract issues, as contract_reference. |
| `name` | `text` | not null |
| `kind` | `contracts.contract_kind` | not null |
| `direction` | `contracts.direction` | not null |
| `state` | `contracts.contract_state` | not null |
| `signed_on` | `date` | The day it was signed. Written with the day a contract reaches signed when nobody gave one. |
| `starts_on` | `date` |  |
| `ends_on` | `date` | The last day of the current term. Null: open-ended, it runs until it is terminated. |
| `renews_on` | `date` | The first day of the next term, when the contract renews. Set to the day after ends_on for a tacit renewal when nobody gave one, and moved with it. |
| `renewal` | `contracts.renewal` | not null |
| `notice_days` | `integer` | How many days before the next term — or before the end, where it does not renew — notice has to be given. The notice deadline of contracts.deadlines is that day. |
| `currency_code` | `character(3)` | not null — The currency of its value and of the documents it issues. The company's own when the contract was created without one. |
| `total_value` | `numeric(18,2)` | What the contract is worth over its term, excluding tax, as the parties said it. A figure of the agreement, never added to the books. |
| `attachment_id` | `uuid` | The signed file: an attachment of the socle, with its checksum, of the same company. The file itself is filed on the other party (entity_type contact). |
| `template_id` | `uuid` | The template it was made from, if any. |
| `notes` | `text` | What somebody — a member, an agent — wrote about the contract: its risks, what to watch. |
| `analysis` | `jsonb` | not null — A structured reading of the contract, as a JSON object: its key clauses, its obligations, a level of risk. Written by whoever read it; the module only keeps it. |
| `attributes` | `jsonb` | not null — The fields a company keeps that the module does not name, as a JSON object. contracts.from_template() writes the template variables here, under "variables". |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((jsonb_typeof(analysis) = 'object'::text))`
- `CHECK ((jsonb_typeof(attributes) = 'object'::text))`
- `CHECK (((ends_on IS NULL) OR (starts_on IS NULL) OR (ends_on >= starts_on)))`
- `CHECK ((length(btrim(name)) > 0))`
- `CHECK (((notice_days IS NULL) OR (notice_days >= 0)))`
- `CHECK ((length(btrim(number)) > 0))`
- `CHECK (((renewal <> 'tacit'::contracts.renewal) OR ((starts_on IS NOT NULL) AND (ends_on IS NOT NULL))))`
- `CHECK (((total_value IS NULL) OR (total_value >= (0)::numeric)))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, number)`
- `UNIQUE (id, company_id)`

<a id="contracts-issues"></a>

#### `issues`

Which document of the socle a schedule issued for which period: one row per schedule and first day of a period, written by contracts.issue_due(). A draft that is deleted takes its row with it.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `contract_id` | `uuid` | not null |
| `schedule_id` | `uuid` | not null |
| `document_id` | `uuid` | not null |
| `period_start` | `date` | not null |
| `period_end` | `date` | not null |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((period_end >= period_start))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, schedule_id, period_start)`

<a id="contracts-schedules"></a>

#### `schedules`

A line a contract invoices, at its own rhythm: what (a product, or a name), how many, in which unit, at what price, under which tax, every week, month, quarter or year from next_on until until. Each period that has come is issued as one draft document by contracts.issue_due().

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `contract_id` | `uuid` | not null |
| `sequence` | `integer` | not null |
| `product_id` | `uuid` | The catalogue row the line was filled in from, when there is one. Its name, unit, price and tax pre-fill the schedule when it is created; the account of the line is the product's, resolved by the socle. |
| `name` | `text` | not null |
| `description` | `text` |  |
| `quantity` | `numeric(16,4)` | not null |
| `unit_code` | `text` | not null |
| `unit_price` | `numeric(16,6)` | not null — The price of one unit, excluding tax, in the contract's currency. The product's price for the side of the contract when it is created from a product without one. |
| `tax_code` | `text` | The tax of the line, by its code in the company's list of taxes (ekwo.taxes.code). Null: no tax on the line. Read at each issue, so a tax that changed its rate under the same code is applied as it stands. |
| `frequency` | `contracts.frequency` | not null |
| `next_on` | `date` | not null — The first day of the next period to issue. contracts.issue_due() issues every period whose first day is on or before the day it is given, and moves this to the period after. |
| `until` | `date` | The last day a period may start on. Null: as long as the contract runs. |
| `indexation` | `jsonb` | How the price is indexed, as data, never as code: a JSON object {"index": the name of the index, "formula": the clause as the contract writes it, "base": the value of the index the price was set on, "base_on": its date, "next_on": the day the next indexation is due}. Nothing is computed from it: the deadline is shown in contracts.deadlines, and the new price is an amendment. |
| `auto_post` | `boolean` | not null — True: the documents this schedule issues are booked as soon as they are written, by the socle's post_document(), which needs documents.post. False: they stay drafts for somebody to read. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (contracts.valid_indexation(indexation))`
- `CHECK ((length(btrim(name)) > 0))`
- `CHECK ((unit_price >= (0)::numeric))`
- `CHECK ((quantity > (0)::numeric))`
- `CHECK ((unit_code ~ '^[A-Z0-9]{1,3}$'::text))`
- `PRIMARY KEY (id)`
- `UNIQUE (id, company_id)`

<a id="contracts-templates"></a>

#### `templates`

What a contract starts from: its clauses — an html text or a docx file — with the variables they name, a category, and a template schedule. contracts.from_template() makes a draft contract of one.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `name` | `text` | not null |
| `description` | `text` |  |
| `category` | `text` | How the company files its templates — services, licences, employment, confidentiality — in its own words. |
| `format` | `contracts.template_format` | not null |
| `html` | `text` | The clauses as html, with {{key}} where a variable goes. Required when format is html. |
| `attachment_id` | `uuid` | The docx file of the clauses, an attachment of the socle with its checksum. Required when format is docx. |
| `variables` | `jsonb` | not null — The variables the clauses name, as a JSON array of objects: {"key": …, "label": …, "type": …, "required": true\|false, "default_value": …}. contracts.from_template() refuses a required one left empty. |
| `schedule` | `jsonb` | not null — The schedule a contract made from this template starts with, as a JSON array of the fields contracts.upsert_schedule() takes: {"name", "product_code", "quantity", "unit_code", "unit_price", "tax_code", "frequency", "auto_post"}. |
| `active` | `boolean` | not null |
| `created_by` | `uuid` | Who wrote the template: acting_user(), the signed-in person or the issuer of the key presented. No foreign key, as company_members has none. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (((format <> 'docx'::contracts.template_format) OR (attachment_id IS NOT NULL)))`
- `CHECK (((format <> 'html'::contracts.template_format) OR (html IS NOT NULL)))`
- `CHECK ((length(btrim(name)) > 0))`
- `CHECK ((jsonb_typeof(schedule) = 'array'::text))`
- `CHECK ((jsonb_typeof(variables) = 'array'::text))`
- `PRIMARY KEY (id)`
- `UNIQUE (id, company_id)`

### Functions

| Function | Purpose |
|---|---|
| `amend(p_company_id uuid, p_contract_id uuid, p_summary text, p_effective_on date, p_changes jsonb, p_kind contracts.amendment_kind, p_signed_on date, p_attachment_id uuid)` | Records what changes in a contract and from when, numbered next in its history, with the signed file. An amendment applies its changes as it is recorded: the fields of the contract through contracts.upsert_contract(), and under "schedules", by id, the fields of each schedule through contracts.upsert_schedule() — with their refusals. A version records another text with its file and changes no field. A renewal is refused: contracts.roll_forward() writes it. Needs contracts.write. |
| `archive_tables()` | What an archive of one company does with each table of this module: all five travel — what a company agreed is part of its books. Read by `ekwo.company_archive_tables()`. |
| `card_of(p_company_id uuid, p_contract_id uuid)` | Everything on one contract, as one JSON object: the contract, its party, its signed file with its checksum, its schedules, its history of versions, amendments and renewals, the 24 latest documents it issued with their number, state and total, and its deadlines. Needs contracts.read. |
| `complete_contract()` | Before a contract is written: takes the company's currency when none is named, sets renews_on to the day after ends_on for a tacit renewal that has none, writes signed_on on a contract that reaches signed without one, and refuses a state that goes back (contracts_state_backwards), a move out of a final state (contracts_closed), a running contract cancelled or an unsigned one terminated (contracts_bad_state). |
| `from_template(p_company_id uuid, p_template_id uuid, p_contact_id uuid, p_number text, p_direction contracts.direction, p_kind contracts.contract_kind, p_starts_on date, p_values jsonb, p_name text)` | Makes a draft contract of a template: the number, party, side and kind given, starting on p_starts_on, named after the template unless p_name is given, the values of the variables kept in attributes.variables — a default of the template filling an empty one, a required one still empty refused by name, contracts_missing_variable — and the template schedule copied, each line starting on p_starts_on. Answers the contract, its schedules, and the clauses: the html with the values in place, or the docx attachment to fill. Needs contracts.write. |
| `guard_attachment()` | Refuses a file that is not an attachment of the row's own company (contracts_unknown_attachment): ekwo.attachments has no composite key to name, so the company is checked here. |
| `issue_due(p_company_id uuid, p_on_date date)` | Issues every period that has come: for each schedule of a signed or active contract whose next_on is on or before the day — and before its until and the contract's end — one draft document of the socle per period, a sales invoice on a sale and a purchase invoice on a purchase, dated the first day of the period, to the contract's party, in its currency, contract_reference set to its number, with one line of the schedule; recorded in contracts.issues with the period it covers, and next_on moved to the period after. Renewals and expiries of contracts.roll_forward() come first. Idempotent per schedule and period: the document carries client_ref contracts:<schedule>:<first day>, which the socle refuses twice. A schedule with auto_post has its documents booked by post_document(). Needs contracts.issue, contracts.write and documents.write — documents.post for auto_post — each refused by name. Returns one row per document. |
| `list_contracts(p_company_id uuid, p_state contracts.contract_state, p_direction contracts.direction, p_contact_id uuid, p_query text, p_limit integer)` | The contracts of a company, filtered by state, side, party, or a text found in the number, the name or the party's name — every filter optional — each with its party's name and its nearest deadline. In the order of their numbers, at most p_limit rows (50). Needs contracts.read. |
| `list_templates(p_company_id uuid, p_include_inactive boolean)` | The templates of a company, by category and name — the active ones unless p_include_inactive. Needs contracts.read. |
| `render(p_text text, p_values jsonb)` | The text with each {{key}} replaced by its value in p_values. A key with no value is left as it is written, so what is missing stays visible. |
| `require(p_company_id uuid, p_capability text, p_what text)` | Raises contracts_module_not_enabled when the module is off for the company or the caller is not a member of it, and contracts_not_allowed when the caller does not hold the capability. The first lines of every function of this module; the policies still decide every row. |
| `roll_forward(p_company_id uuid, p_on_date date)` | Brings the contracts of a company to a day: a signed contract whose start has come is active; an active one whose last day is past expires when it does not renew, and renews tacitly otherwise — one term of the length of the term that ends, recorded as a renewal amendment, as many times as the day asks. A contract given notice is terminated by its user beforehand and is not touched. Returns one row per change. Needs contracts.write. |
| `state_rank(p_state contracts.contract_state)` | The order a contract moves in: draft, sent, negotiation, signed, active, then the three final states. |
| `step(p_from date, p_frequency contracts.frequency, p_steps integer)` | The day p_steps periods after p_from. Counted from the same first day every time, so the 31st of a month gives the last day of a shorter one and the 31st again after it. |
| `upsert_contract(p_company_id uuid, p_number text, p_patch jsonb)` | Creates the contract of that number in the company, or changes it: each field the patch names takes its value, every other one keeps its own. A new contract needs contact_id, name, kind and direction; its currency is the company's unless currency_code is named. Once it has issued a document, its contact_id, direction and currency_code do not change (contracts_already_issued). An unknown key is refused by name, contracts_unknown_field. Needs contracts.write. Returns the contract. |
| `upsert_schedule(p_company_id uuid, p_contract_id uuid, p_schedule_id uuid, p_patch jsonb)` | Adds a schedule to a contract (p_schedule_id null) or changes one: each field the patch names takes its value. The fields are sequence, product_id or product_code, name, description, quantity, unit_code, unit_price, tax_code, frequency, next_on, until, indexation and auto_post. A new schedule from a product takes the product's name, unit, price and tax for the side of the contract where the patch gives none; it needs a name, a unit_price, a frequency and a next_on. A product or a tax code the company does not have is refused by name. Needs contracts.write. |
| `valid_indexation(p_indexation jsonb)` | Whether an indexation is a JSON object whose next_on and base_on, where given, are dates. |

## `crm` — Customer relationship

The record of a relationship, kept beside the books on the same contacts: cards, segments, pipelines, deals and activities, exposed as functions an agent or a screen calls. A deal won makes its party a customer. Knows no country, and writes nothing to the ledger.

### Tables

| Table | Purpose |
|---|---|
| [`activities`](#crm-activities) | Everything that happened with a contact, one row each: a note, an e-mail, a call, a meeting, a signal, a deal moving. Optionally about one deal. An activity read from elsewhere carries its source and its identifier there, and is written once. |
| [`cards`](#crm-cards) | One card per contact the company follows: where the relationship stands, how much it matters, who works it and when anything last happened. The contact itself — its name, e-mail, country, organisation — is the socle's row and is not repeated here. |
| [`deals`](#crm-deals) | A piece of business with one contact, moving through the stages of one pipeline. Closed, with its date and its outcome, when it reaches a won or a lost stage. An amount is in a currency, always named. |
| [`pipelines`](#crm-pipelines) | A sequence of stages a deal moves through: sales, partnerships, hiring. None is created for a company: a pipeline is a decision of the company, written by insertion. |
| [`segment_members`](#crm-segment_members) | A contact in a segment. A contact who leaves keeps the row, with left_at set; joining again clears it. One row per segment and contact. |
| [`segments`](#crm-segments) | A group of contacts, in a tree: a taxonomy branch, a target, a cohort, a brand. A parent belongs to the same company, and the chain of parents has no cycle and at most 32 levels. |
| [`stages`](#crm-stages) | One step of a pipeline, in the order of position. A deal opens at the first open stage; reaching a won or a lost stage closes it. |

<a id="crm-activities"></a>

#### `activities`

Everything that happened with a contact, one row each: a note, an e-mail, a call, a meeting, a signal, a deal moving. Optionally about one deal. An activity read from elsewhere carries its source and its identifier there, and is written once.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `contact_id` | `uuid` | not null |
| `deal_id` | `uuid` |  |
| `kind` | `crm.activity_kind` | not null |
| `actor` | `text` | Who did it, as a handle: a member, an agent, the contact. Free text. |
| `occurred_at` | `timestamp with time zone` | not null |
| `subject` | `text` |  |
| `body` | `text` |  |
| `link` | `text` |  |
| `payload` | `jsonb` | not null — Whatever structured detail came with the activity, as a JSON object. |
| `source` | `text` | Where the activity was read from: a mailbox, a calendar, a messaging service, an import. With source_ref, unique in the company. |
| `source_ref` | `text` | The identifier of the activity at its source — a message identifier, an event identifier. The same pair twice is the same activity. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((jsonb_typeof(payload) = 'object'::text))`
- `PRIMARY KEY (id)`

<a id="crm-cards"></a>

#### `cards`

One card per contact the company follows: where the relationship stands, how much it matters, who works it and when anything last happened. The contact itself — its name, e-mail, country, organisation — is the socle's row and is not repeated here.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `contact_id` | `uuid` | not null |
| `status` | `crm.relationship_status` | not null |
| `priority` | `crm.priority` | not null |
| `owner` | `text` | Who works the relationship, as a handle: a member, an agent, a team. Free text: the module holds no list of who may. |
| `job_title` | `text` |  |
| `linkedin_url` | `text` |  |
| `source` | `text` | Where the contact came from — an import, a form, an event — in the words of whoever recorded it. |
| `tags` | `text[]` | not null |
| `no_outbound` | `boolean` | not null — True when the contact is not to be approached first: no prospecting e-mail, no unsolicited message. An answer to the contact is still an answer. |
| `custom` | `jsonb` | not null — The fields a company keeps that the module does not name, as a JSON object. |
| `last_activity_at` | `timestamp with time zone` | The latest occurred_at of the contact's activities, kept by a trigger on crm.activities. Null while nothing has happened. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((jsonb_typeof(custom) = 'object'::text))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, contact_id)`

<a id="crm-deals"></a>

#### `deals`

A piece of business with one contact, moving through the stages of one pipeline. Closed, with its date and its outcome, when it reaches a won or a lost stage. An amount is in a currency, always named.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `pipeline_id` | `uuid` | not null |
| `stage_id` | `uuid` | not null |
| `contact_id` | `uuid` | not null — Who the deal is with: an organisation, or a person of one. Winning it makes the organisation at the root of the contact's chain a customer. |
| `title` | `text` | not null |
| `amount` | `numeric(18,2)` |  |
| `currency_code` | `character(3)` |  |
| `expected_on` | `date` |  |
| `external_url` | `text` | Where the deal is described elsewhere: a proposal, a tender, a thread. |
| `owner` | `text` |  |
| `closed_at` | `timestamp with time zone` |  |
| `closed_outcome` | `crm.stage_outcome` | won or lost once the deal is closed, null while it is open. Written by crm.move_deal() with closed_at. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (((amount IS NULL) OR (currency_code IS NOT NULL)))`
- `CHECK (((closed_at IS NULL) = (closed_outcome IS NULL)))`
- `CHECK (((closed_outcome IS NULL) OR (closed_outcome <> 'open'::crm.stage_outcome)))`
- `PRIMARY KEY (id)`

<a id="crm-pipelines"></a>

#### `pipelines`

A sequence of stages a deal moves through: sales, partnerships, hiring. None is created for a company: a pipeline is a decision of the company, written by insertion.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `name` | `text` | not null |
| `slug` | `text` | not null |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((slug ~ '^[a-z0-9][a-z0-9_-]*$'::text))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, slug)`

<a id="crm-segment_members"></a>

#### `segment_members`

A contact in a segment. A contact who leaves keeps the row, with left_at set; joining again clears it. One row per segment and contact.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `segment_id` | `uuid` | not null |
| `contact_id` | `uuid` | not null |
| `added_by` | `text` | Who put the contact in the segment, as a handle. Free text. |
| `joined_at` | `timestamp with time zone` | not null |
| `left_at` | `timestamp with time zone` | When the contact left the segment. Null while the contact is in it. |
| `note` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `PRIMARY KEY (id)`
- `UNIQUE (company_id, segment_id, contact_id)`

<a id="crm-segments"></a>

#### `segments`

A group of contacts, in a tree: a taxonomy branch, a target, a cohort, a brand. A parent belongs to the same company, and the chain of parents has no cycle and at most 32 levels.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `parent_id` | `uuid` |  |
| `kind` | `crm.segment_kind` | not null |
| `name` | `text` | not null |
| `slug` | `text` | not null — The segment's name for a machine: lower case, digits, hyphens and underscores, unique in the company. |
| `description` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (((parent_id IS NULL) OR (parent_id <> id)))`
- `CHECK ((slug ~ '^[a-z0-9][a-z0-9_-]*$'::text))`
- `PRIMARY KEY (id)`
- `UNIQUE (id, company_id)`
- `UNIQUE (company_id, slug)`

<a id="crm-stages"></a>

#### `stages`

One step of a pipeline, in the order of position. A deal opens at the first open stage; reaching a won or a lost stage closes it.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `pipeline_id` | `uuid` | not null |
| `name` | `text` | not null |
| `position` | `smallint` | not null |
| `outcome` | `crm.stage_outcome` | not null — open while a deal at this stage is still being worked; won or lost when reaching it closes the deal. |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `PRIMARY KEY (id)`
- `UNIQUE (company_id, pipeline_id, "position")`
- `UNIQUE (id, pipeline_id)`

### Functions

| Function | Purpose |
|---|---|
| `archive_tables()` | What an archive of one company does with each table of this module: all seven travel — a relationship is the company's as much as its books. Read by `ekwo.company_archive_tables()`. |
| `board(p_company_id uuid, p_pipeline_id uuid, p_include_closed boolean)` | One pipeline of a company as a board, or every pipeline when none is named: its stages in order, each with its deals — the open ones, and the closed ones too under p_include_closed — how many there are, and the sum of their amounts by currency. The pipeline carries the same totals over all its stages. A deal without an amount is counted and summed in no currency. Amounts are decimal strings. A pipeline of another company is refused by name, crm_unknown_pipeline. Needs crm.read. |
| `card_of(p_company_id uuid, p_contact_id uuid)` | Everything on one contact, as one JSON object: the contact as the socle holds it, its organisation, its card, the segments it is in now, the open deals with it — and, for an organisation, with its people — and its 20 latest activities. Needs crm.read. |
| `fold_card_on_merge()` | During merge_contacts(), and only then: when the kept contact already has a card, folds it with the absorbed contact's card into one — the kept card's answers first, the absorbed one's filling the gaps, the tags joined, a no_outbound on either side kept — so the merge does not collide with the one card per contact. |
| `fold_membership_on_merge()` | During merge_contacts(), and only then: when the kept contact is already in the segment, folds the two memberships into one — the earliest joining, still in it if either was — so the merge does not collide with the one membership per segment and contact. |
| `guard_segment_parent()` | Refuses a parent that would make the tree of segments a cycle (crm_segment_cycle) or deeper than 32 levels (crm_segment_too_deep), the bound commercial_entity() keeps on contacts. |
| `join_segment(p_company_id uuid, p_segment_id uuid, p_contact_id uuid, p_added_by text, p_note text)` | Puts a contact in a segment of the same company. A contact who had left joins again on the same row: left_at goes back to null and joined_at is the day of the return. A contact already in it stays as it is, with the note replaced when one is given. Needs crm.write. |
| `leave_segment(p_company_id uuid, p_segment_id uuid, p_contact_id uuid)` | Takes a contact out of a segment by setting left_at; the row stays, so the membership is remembered. Leaving twice keeps the first date. Refuses a contact that was never in it, crm_not_a_member. Needs crm.write. |
| `log_activity(p_company_id uuid, p_contact_id uuid, p_kind crm.activity_kind, p_subject text, p_body text, p_deal_id uuid, p_actor text, p_occurred_at timestamp with time zone, p_link text, p_payload jsonb, p_source text, p_source_ref text)` | Writes one activity of a contact, optionally about one deal of the same company, and moves the card's last_activity_at. An activity read from elsewhere names its source and its identifier there: the same pair a second time writes nothing and returns the activity already kept, which is what makes an import idempotent. Needs crm.write. |
| `move_deal(p_company_id uuid, p_deal_id uuid, p_stage_id uuid)` | Moves a deal to another stage of its pipeline and logs it as a system activity. Reaching a won or a lost stage closes the deal with its date and its outcome; going back to an open stage opens it again. A deal won makes the organisation at the root of its contact's chain a customer — other becomes customer, supplier becomes both — which needs contacts.write. The same stage again changes nothing. Needs crm.write. |
| `open_deal(p_company_id uuid, p_pipeline_id uuid, p_contact_id uuid, p_title text, p_amount numeric, p_currency_code character, p_expected_on date, p_external_url text, p_owner text)` | Opens a deal with a contact at the first open stage of a pipeline of the same company, and logs it as a system activity. An amount given without a currency is in the company's own currency. Refuses a pipeline with no open stage, crm_pipeline_without_open_stage. Needs crm.write. |
| `require(p_company_id uuid, p_capability text, p_what text)` | Raises crm_module_not_enabled when the module is off for the company or the caller is not a member of it, and crm_not_allowed when the caller does not hold the capability. The first lines of every function of this module; the policies still decide every row. |
| `search_cards(p_company_id uuid, p_query text, p_status crm.relationship_status, p_segment_id uuid, p_stage_id uuid, p_country character, p_language character, p_owner text, p_no_outbound boolean, p_active_since timestamp with time zone, p_inactive_since timestamp with time zone, p_limit integer)` | The cards of a company, filtered: a text found in the name, the e-mail or the organisation's name, a status, a segment the contact is in now, a stage one of its deals is at, a country and a language (the contact's, or its organisation's where it has none), an owner, no_outbound, active since or inactive since a moment. Every filter is optional. Merged contacts are left out. Most recently active first, at most p_limit rows (50). |
| `segment_tree(p_company_id uuid)` | Every segment of a company as a tree: each one with its parent, its depth (0 at a root), the path of slugs from the root down to it, and how many contacts are in it now — a contact who left is not counted. Ordered by path, so a parent comes just before its children. Needs crm.read. |
| `timeline(p_company_id uuid, p_contact_id uuid, p_deal_id uuid, p_since timestamp with time zone, p_kinds text[], p_limit integer)` | The activities of one contact, or of one deal, or of both at once — most recent first, from p_since on, of the kinds named (crm.activity_kind; a kind it does not have is refused), at most p_limit rows (50). Naming neither a contact nor a deal is refused, crm_bad_timeline. Needs crm.read. |
| `touch_card()` | After an activity is written, moves the last_activity_at of the contact's card to its occurred_at when that is later. Does nothing where the contact has no card. |
| `upsert_card(p_company_id uuid, p_contact_id uuid, p_patch jsonb)` | Creates the card of a contact, or changes it: each field the patch names takes its value, every other one keeps its own. The fields are status, priority, owner, job_title, linkedin_url, source, tags, no_outbound and custom; any other key is refused by name, crm_unknown_field. Needs crm.write. Returns the card. |

## `einvoicing` — Electronic invoicing

The electronic invoice of a posted sale in the profile its country pack declares, and the fiscal record or the clearance by the authority its pack's fiscalisation regime requires: the exact files with the rules they break, the chain, the validations, and every sending with what came back, word for word. Knows no country, names no provider, and writes nothing to the ledger.

### Tables

| Table | Purpose |
|---|---|
| [`clearances`](#einvoicing-clearances) | Every submission of a posted sale to the tax authority under a clearance regime, numbered per document, with the state the authority's answers brought it to and what it gave the invoice: its identifier, the moment of validation, the verification link. Written by einvoicing.record_clearance_submission() and einvoicing.record_clearance_answer() alone; a state only moves forward and nothing is deleted. The answers themselves, verbatim, are in einvoicing.fiscal_events. |
| [`fiscal_chain`](#einvoicing-fiscal_chain) | The chain of fiscal records of one company in one invoicing system: one row per record, numbered from 1, each carrying the hash of the one before it. Written by einvoicing.append_fiscal_record() alone, never edited and never deleted; einvoicing.verify_fiscal_chain() walks it both ways. |
| [`fiscal_events`](#einvoicing-fiscal_events) | What an invoicing system records beside its fiscal records where the law asks it to — a summary every so many hours, a start, a stop, an anomaly found in the chain — numbered per company and system. Appended by einvoicing.log_fiscal_event(), never edited, never deleted. |
| [`issues`](#einvoicing-issues) | One electronic invoice written for one posted sale: the exact file, its SHA-256, the format it follows and every rule of that format it breaks. Written by einvoicing.record_issue(), never edited and never deleted: what was issued is evidence of what was issued. |
| [`transmission_events`](#einvoicing-transmission_events) | Every state a transmission reached, with what the service said at that moment, word for word, and the structured answer as it came. Appended by einvoicing.record_transmission() and einvoicing.record_transmission_outcome(); never edited, never deleted. |
| [`transmissions`](#einvoicing-transmissions) | One sending of one issued file: the channel, the service by name, the reference it gave, and a state that only moves forward. A document rejected on the way is sent again by a second row; at most one of its transmissions is ever alive or delivered. |

<a id="einvoicing-clearances"></a>

#### `clearances`

Every submission of a posted sale to the tax authority under a clearance regime, numbered per document, with the state the authority's answers brought it to and what it gave the invoice: its identifier, the moment of validation, the verification link. Written by einvoicing.record_clearance_submission() and einvoicing.record_clearance_answer() alone; a state only moves forward and nothing is deleted. The answers themselves, verbatim, are in einvoicing.fiscal_events.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `document_id` | `uuid` | not null |
| `attempt` | `integer` | not null — The submission's number among those of its document, from 1. An attempt the authority rejected is followed by the next; a validated or cancelled one is the last. |
| `format` | `text` | not null |
| `state` | `einvoicing.clearance_state` | not null |
| `issue_id` | `uuid` |  |
| `reference` | `text` |  |
| `submitted_at` | `timestamp with time zone` | not null |
| `submitted_by` | `uuid` |  |
| `identifier` | `text` | The identifier the authority gave the invoice when it validated it. Unique per format: no two invoices carry one. |
| `validated_at` | `timestamp with time zone` |  |
| `verification_url` | `text` | The link to the authority's verification of the invoice, which the invoice carries — usually as a QR code — where the regime has one: returned by the authority, or computed by the issuer from its answer, as the pack's clearance.verification says. |
| `rejected_by` | `text` | Who rejected it: the authority, which did not validate it, or the buyer, after its validation and within the regime's rejection_window. |
| `rejected_at` | `timestamp with time zone` |  |
| `rejection_reason` | `text` |  |
| `cancelled_at` | `timestamp with time zone` |  |
| `cancellation_reason` | `text` |  |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((attempt >= 1))`
- `CHECK (((state <> 'cancelled'::einvoicing.clearance_state) OR ((cancelled_at IS NOT NULL) AND (NULLIF(btrim(cancellation_reason), ''::text) IS NOT NULL))))`
- `CHECK ((NULLIF(btrim(format), ''::text) IS NOT NULL))`
- `CHECK (((state <> 'rejected'::einvoicing.clearance_state) OR ((rejected_by IS NOT NULL) AND (rejected_at IS NOT NULL) AND (NULLIF(btrim(rejection_reason), ''::text) IS NOT NULL))))`
- `CHECK (((rejected_by IS NULL) OR (rejected_by = ANY (ARRAY['authority'::text, 'buyer'::text]))))`
- `CHECK (((state <> 'submitted'::einvoicing.clearance_state) OR ((identifier IS NULL) AND (validated_at IS NULL) AND (rejected_at IS NULL) AND (cancelled_at IS NULL))))`
- `CHECK (((verification_url IS NULL) OR (verification_url ~ '^https://'::text)))`
- `CHECK ((((state <> ALL (ARRAY['validated'::einvoicing.clearance_state, 'cancelled'::einvoicing.clearance_state])) AND (NOT ((state = 'rejected'::einvoicing.clearance_state) AND (rejected_by = 'buyer'::text)))) OR ((NULLIF(btrim(identifier), ''::text) IS NOT NULL) AND (validated_at IS NOT NULL))))`
- `PRIMARY KEY (id)`
- `UNIQUE (document_id, attempt)`

<a id="einvoicing-fiscal_chain"></a>

#### `fiscal_chain`

The chain of fiscal records of one company in one invoicing system: one row per record, numbered from 1, each carrying the hash of the one before it. Written by einvoicing.append_fiscal_record() alone, never edited and never deleted; einvoicing.verify_fiscal_chain() walks it both ways.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `system_id` | `text` | not null — The invoicing system and installation the chain is kept by, as the caller names it. A company keeps one chain per system. |
| `seq` | `integer` | not null |
| `document_id` | `uuid` | not null |
| `kind` | `einvoicing.fiscal_record_kind` | not null |
| `format` | `text` | not null |
| `issuer_tax_id` | `text` | not null |
| `series` | `text` | not null |
| `number` | `text` | not null |
| `issued_on` | `date` | not null |
| `record` | `jsonb` | not null — The fields the hash covers, by the names the pack's hash.fields gives them, each as the text that was hashed. |
| `hash_input` | `text` | not null — The exact text the brick hashed. The database computes its digest again on every insert and refuses a hash that is not it. |
| `hash_algorithm` | `text` | not null |
| `hash_encoding` | `text` |  |
| `hash` | `text` | not null |
| `previous_hash` | `text` |  |
| `is_first` | `boolean` | not null |
| `generated_at` | `text` | not null — When the record was generated, as the record writes it: ISO 8601 with its offset. generated_instant is the same moment as a timestamp, for ordering. |
| `generated_instant` | `timestamp with time zone` | not null |
| `mode` | `text` | not null — How this record reaches the authority, one of the modes the pack's submission.modes allows: realtime, batch, or none (kept, handed over on request). It decides the verification URL. |
| `verification_url` | `text` | What the QR code of the invoice encodes, as the brick wrote it for this record's mode. The PDF of the invoice reads it here. |
| `issue_id` | `uuid` | not null — The file of the record, kept in einvoicing.issues as a fiscal_record artefact of the document. |
| `recorded_at` | `timestamp with time zone` | not null |
| `recorded_by` | `uuid` |  |

Constraints:

- `CHECK (((is_first = (seq = 1)) AND (is_first = (previous_hash IS NULL))))`
- `CHECK ((generated_at ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?([+-][0-9]{2}:[0-9]{2}|Z)$'::text))`
- `CHECK ((mode = ANY (ARRAY['realtime'::text, 'batch'::text, 'none'::text])))`
- `CHECK ((jsonb_typeof(record) = 'object'::text))`
- `CHECK ((seq >= 1))`
- `CHECK ((NULLIF(btrim(system_id), ''::text) IS NOT NULL))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, system_id, seq)`

<a id="einvoicing-fiscal_events"></a>

#### `fiscal_events`

What an invoicing system records beside its fiscal records where the law asks it to — a summary every so many hours, a start, a stop, an anomaly found in the chain — numbered per company and system. Appended by einvoicing.log_fiscal_event(), never edited, never deleted.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `system_id` | `text` | not null |
| `seq` | `integer` | not null |
| `kind` | `text` | not null — What happened, as a short name the caller chooses: summary, started, stopped, chain_break. The pack says how often a summary is due; the module records whatever is logged. |
| `detail` | `jsonb` | not null |
| `at` | `timestamp with time zone` | not null |
| `recorded_by` | `uuid` |  |

Constraints:

- `CHECK ((jsonb_typeof(detail) = 'object'::text))`
- `CHECK ((kind ~ '^[a-z][a-z0-9_]{0,59}$'::text))`
- `CHECK ((NULLIF(btrim(system_id), ''::text) IS NOT NULL))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, system_id, seq)`

<a id="einvoicing-issues"></a>

#### `issues`

One electronic invoice written for one posted sale: the exact file, its SHA-256, the format it follows and every rule of that format it breaks. Written by einvoicing.record_issue(), never edited and never deleted: what was issued is evidence of what was issued.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `document_id` | `uuid` | not null |
| `sequence` | `integer` | not null |
| `profile` | `text` | not null — The e-invoicing profile of the company's country pack the file was written in — `country_defaults.einvoice_profile` of its fiscal country on the day it was issued. |
| `brick` | `text` | not null — The package of packages/formats/ that wrote the file, by its published name. |
| `specification` | `text` | What the file itself declares it follows — the customization identifier of a UBL file, the guideline of a CII one — as the brick wrote it. |
| `filename` | `text` | not null |
| `media_type` | `text` | not null |
| `content` | `text` | not null — The file, byte for byte as the brick wrote it, as UTF-8 text. A format that is not text would need a column of its own; none of the bricks this version reads writes one. |
| `byte_size` | `integer` | not null |
| `checksum` | `text` | not null — SHA-256 of content as UTF-8, in lower-case hexadecimal. Computed again by the database on every insert, so a file that does not match its checksum is refused rather than kept. |
| `violations` | `jsonb` | not null — Every rule of the format the file breaks, as the brick named them: [{"code": "BR-CO-25", "message": "…", "line": "10"}]. Empty is the only state a file is sent in. |
| `sendable` | `boolean` | not null — Whether the file breaks no rule. Derived from violations, and held to it by a constraint. |
| `issued_at` | `timestamp with time zone` | not null |
| `issued_by` | `uuid` |  |
| `artefact` | `einvoicing.artefact` | not null — What the file is to the document: the electronic invoice (einvoice) or a fiscal record (fiscal_record). For a fiscal record, profile is the format of the pack's fiscalisation block, and the row is written by einvoicing.append_fiscal_record() alone. |

Constraints:

- `CHECK ((checksum ~ '^[0-9a-f]{64}$'::text))`
- `CHECK ((sendable = (jsonb_array_length(violations) = 0)))`
- `CHECK ((byte_size = octet_length(content)))`
- `CHECK ((jsonb_typeof(violations) = 'array'::text))`
- `PRIMARY KEY (id)`
- `UNIQUE (document_id, artefact, sequence)`
- `UNIQUE (document_id, checksum)`

<a id="einvoicing-transmission_events"></a>

#### `transmission_events`

Every state a transmission reached, with what the service said at that moment, word for word, and the structured answer as it came. Appended by einvoicing.record_transmission() and einvoicing.record_transmission_outcome(); never edited, never deleted.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `transmission_id` | `uuid` | not null |
| `sequence` | `integer` | not null |
| `state` | `einvoicing.transmission_state` | not null |
| `reference` | `text` |  |
| `message` | `text` | What the service answered, in its own words. Not summarised: a refusal is read to know what to change. |
| `detail` | `jsonb` |  |
| `occurred_at` | `timestamp with time zone` |  |
| `recorded_at` | `timestamp with time zone` | not null |
| `recorded_by` | `uuid` |  |

Constraints:

- `PRIMARY KEY (id)`
- `UNIQUE (transmission_id, sequence)`

<a id="einvoicing-transmissions"></a>

#### `transmissions`

One sending of one issued file: the channel, the service by name, the reference it gave, and a state that only moves forward. A document rejected on the way is sent again by a second row; at most one of its transmissions is ever alive or delivered.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `document_id` | `uuid` | not null |
| `issue_id` | `uuid` | not null |
| `sequence` | `integer` | not null |
| `channel` | `einvoicing.channel` | not null |
| `service` | `text` | The name of the transmission service, where one was used — an access point, a platform. Free text: the module records what was used and holds no list of what may be, which is what keeps it uncoupled from any provider. |
| `reference` | `text` | What the transport gave back to find this sending again: a message identifier, a tracking number, the path a file was written to. Set once. |
| `state` | `einvoicing.transmission_state` | not null |
| `state_at` | `timestamp with time zone` | not null |
| `message` | `text` | What the service said last, in its own words. The full history is einvoicing.transmission_events. |
| `prepared_at` | `timestamp with time zone` | not null |
| `prepared_by` | `uuid` |  |
| `artefact` | `einvoicing.artefact` | not null — The artefact of the issue this sending carries, copied from it when the sending is recorded: an electronic invoice goes to the customer, a fiscal record to the tax authority, and each has its own sending alive at most. |

Constraints:

- `CHECK (((channel = 'self'::einvoicing.channel) OR (NULLIF(btrim(service), ''::text) IS NOT NULL)))`
- `PRIMARY KEY (id)`
- `UNIQUE (document_id, sequence)`

### Functions

| Function | Purpose |
|---|---|
| `append_fiscal_record(p_document_id uuid, p_system_id text, p_kind einvoicing.fiscal_record_kind, p_format text, p_mode text, p_issuer_tax_id text, p_series text, p_number text, p_issued_on date, p_record jsonb, p_hash_input text, p_hash text, p_previous_hash text, p_generated_at text, p_verification_url text, p_brick text, p_specification text, p_filename text, p_media_type text, p_content text, p_checksum text, p_violations jsonb)` | Chains one fiscal record of a posted sale and keeps its file. Checks the company's pack declares a regime in this format and mode (no_fiscalisation_regime, fiscal_format_mismatch, fiscal_mode_not_allowed), that the record breaks no rule (fiscal_record_not_chainable), that its hash is the digest the pack names of the text it came with (fiscal_hash_mismatch) and that it holds every field the hash covers (fiscal_record_fields_missing); that the tail of the chain is intact (fiscal_chain_broken) and is the record it names as previous — none for the first (fiscal_chain_not_first, fiscal_chain_link); and that an invoice is recorded once and cancelled once (fiscal_record_exists, fiscal_nothing_to_cancel). Needs einvoicing.send and documents.read. |
| `archive_tables()` | What an archive of one company does with each table of this module: all six travel — the files as they were issued, the sendings and what came back, the chain of fiscal records and its events, and the submissions to the authority under a clearance regime. Read by `ekwo.company_archive_tables()`. |
| `can_disable(p_company_id uuid)` | Null when the module may be turned off for a company; a sentence while a sending is still on its way, while a fiscal record that is to be sent has not reached the authority, or while an invoice waits for the authority's validation. Turning it off deletes nothing: the files, the chain, the clearances and the history come back with it. |
| `clearance_document(p_document_id uuid, p_what text)` | The document a clearance is recorded for, after every check the two clearance functions share: the document exists and the caller may know of it (unknown_document), einvoicing.send and documents.read (not_allowed), a sale (document_not_a_sale) that was posted (document_not_posted), a regime (no_fiscalisation_regime) of kind clearance (fiscal_regime_not_clearance). |
| `fiscal_digest(p_algorithm text, p_encoding text, p_input text)` | The digest of a text as a fiscalisation regime writes it: SHA-256, SHA-384 or SHA-512 of its UTF-8 bytes, in hexadecimal capitals, lower case or base64 as the pack's hash.encoding says (lower-case hexadecimal where it says nothing). Null for an algorithm it does not know, which the callers refuse. |
| `fiscal_regime(p_company_id uuid)` | The einvoicing.fiscalisation block of the pack of the company's fiscal country, as the socle compiled it; null where the country has no such regime, or the caller may not know of the company. |
| `guard_clearance()` | Refuses a delete of a clearance, a change of what was submitted, of what the authority gave on validation or of a rejection once recorded (clearance_recorded), and every move of state but the five forward ones: submitted to validated, submitted to rejected by the authority, validated to rejected by the buyer, validated to cancelled, rejected by the buyer to cancelled (clearance_state_backwards). |
| `guard_event()` | Refuses every update and every delete of a transmission event: the history of what came back is appended to, never rewritten. |
| `guard_fiscal()` | Refuses every update and every delete of a fiscal record or a fiscal event: fiscal_record_kept. |
| `guard_issue()` | Checks the SHA-256 of a file as it is inserted, and refuses every update and every delete of an issue: einvoice_issued. |
| `guard_transmission()` | Holds a transmission to what it is: never deleted; its document, file, artefact, channel and service fixed; its reference set once; its state only moving forward, and never again once closed; and a reference wherever somebody took the file. |
| `log_fiscal_event(p_company_id uuid, p_system_id text, p_kind text, p_detail jsonb)` | Appends one event of an invoicing system to the fiscal events of a company, numbered per system. Needs einvoicing.send. |
| `record_clearance_answer(p_document_id uuid, p_state einvoicing.clearance_state, p_identifier text, p_validated_at timestamp with time zone, p_verification_url text, p_reason text, p_by text, p_at timestamp with time zone, p_answer jsonb)` | Records what the authority answered about the latest submission of a document, and keeps the answer verbatim in fiscal_events: validated, with the identifier it gave, the moment it validated and the verification link where the regime has one (bad_clearance_answer, clearance_verification_missing, clearance_identifier_taken); rejected, with its reason, by the authority (from submitted) or by the buyer (from validated, within the pack's rejection_window: clearance_buyer_cannot_reject, clearance_window_closed); cancelled by the issuer, with its reason, from validated or rejected by the buyer, within the pack's cancellation_window (clearance_not_cancellable, clearance_window_closed). The same answer twice records nothing; any other move is clearance_state_backwards. Calls nobody. Needs einvoicing.send and documents.read. |
| `record_clearance_submission(p_document_id uuid, p_reference text, p_issue_id uuid, p_submitted_at timestamp with time zone, p_answer jsonb)` | Records that a posted sale was submitted to the authority under its company's clearance regime: the next attempt of the document, the reference the authority gave on receipt where it gave one, the file submitted where this module kept it (an einvoice issue that breaks no rule), the moment, and the answer verbatim in fiscal_events. Calls nobody. Refuses a submission while one waits for its answer (clearance_pending), after a validation (clearance_already_validated) or a cancellation (clearance_cancelled), and everything clearance_document() refuses. Needs einvoicing.send and documents.read. |
| `record_issue(p_document_id uuid, p_profile text, p_brick text, p_specification text, p_filename text, p_media_type text, p_content text, p_checksum text, p_violations jsonb, p_artefact einvoicing.artefact)` | Keeps the file a brick wrote for a posted sale invoice or credit note, with the rules it breaks: its electronic invoice (artefact einvoice, the default) or the file of a fiscal record (fiscal_record, kept by append_fiscal_record() alone). Refuses a document that is not a posted sale (document_not_a_sale, document_not_posted), a company whose pack declares no profile or no regime (no_einvoicing_profile, no_fiscalisation_regime), a file written in another format than the pack's (einvoice_profile_mismatch, fiscal_format_mismatch) and a checksum that is not the SHA-256 of the text (einvoice_checksum_mismatch). The same file twice returns the first issue. Needs einvoicing.send and documents.read. |
| `record_transmission(p_issue_id uuid, p_channel einvoicing.channel, p_service text)` | Records that an issued file — an electronic invoice or a fiscal record — is about to be sent, as prepared: the channel, and the service by name where one is used. Refuses a file that breaks a rule, repeating the rules verbatim (einvoice_not_sendable), an older electronic invoice of a document issued again since (einvoice_superseded), and a file already on its way or delivered (einvoice_already_sent). Needs einvoicing.send. |
| `record_transmission_outcome(p_transmission_id uuid, p_state einvoicing.transmission_state, p_reference text, p_message text, p_detail jsonb, p_occurred_at timestamp with time zone)` | Records what a transport or a service answered about a sending: its new state, its reference where it gave one, and its words verbatim, as one more event. A state only moves forward and a closed sending does not move (transmission_state_backwards, transmission_closed); the same answer twice records nothing. Once an electronic invoice has left, writes the state and the reference on documents.peppol_status and peppol_message_id, which is what keeps unpost_document() from taking it back to draft; a fiscal record writes nothing there. Needs einvoicing.send. |
| `require(p_company_id uuid, p_capability text, p_what text)` | Raises module_not_enabled when the module is off for the company, and not_allowed when the caller does not hold the capability. The first lines of every function of this module that writes. |
| `state_has_left(p_state einvoicing.transmission_state)` | Whether a sending in this state has left the company: everything but prepared and failed. A rejected file left, and somebody on the way read its number. |
| `state_rank(p_state einvoicing.transmission_state)` | How far a sending has gone: prepared 0, submitted 1, accepted_by_access_point 2, and 3 for the three states that close it — delivered, rejected, failed. A state only ever moves to a higher rank. |
| `verify_fiscal_chain(p_company_id uuid, p_system_id text)` | Walks the chain of fiscal records of a company in one system forward — numbering, first record, each digest, each link — then backward from the tail, each previous hash naming exactly the record before. Returns the first break it finds (seq, record_id, problem, detail), or no row when the chain is intact. Needs einvoicing.read. |

## `tax` — Corporate income tax

Corporate income tax estimated from the books: the accounting result, the adjustments, the losses, the rates and their conditions of a country are pack data, and what a company declares about itself is its own. Books the provision of a computation through post_module_entry(), and plans the prepayments of a year.

### Tables

| Table | Purpose |
|---|---|
| [`adjustment_rule_templates`](#tax-adjustment_rule_templates) | One rule of a country between the accounting result and the taxable one, for the days it is in force. A rule is never edited: a percentage that changes is a new row with a new valid_from and a valid_to on the old one, so a past year keeps its answer. |
| [`adjustments`](#tax-adjustments) | What a company says falls under a rule of its country, in one of two ways. An account: its balance over the year is the base, read from the ledger each time, for one year or — with no fiscal_year_id — for every year. An amount: stated once, for one year. The rule, its percentage and its article stay in the pack. |
| [`company_parameters`](#tax-company_parameters) | What a company states about itself for one financial year, under a code its country pack declares: a judgement or an amount. Stated per year because both change from one year to the next, and never worked out from the books. |
| [`computation_lines`](#tax-computation_lines) | The lines tax.estimate() returned when a computation was recorded, as they were: the result, each adjustment with its rule and its article, the losses used, the base, each rate with its slice, the credits and the tax. |
| [`computations`](#tax-computations) | One computation of the tax of one financial year as it stood on a day, numbered per year. Written by tax.record_computation() and by nothing else: no role holds a write privilege on it. The four figures on the row are read off its lines when it is recorded. |
| [`country_rules`](#tax-country_rules) | What one country calls its corporate income tax, which line of which income statement the computation starts from, and the accounts of its chart the tax is booked on. Filled by `ekwo pack build` from packs/<cc>/corporate_tax.json, read where it stands, never copied into a company. |
| [`credit_templates`](#tax-credit_templates) | A credit a company of this country may set against its tax. The amount is the company's to declare; what the pack says is that the credit exists, whether what exceeds the tax is paid back, and the article it comes from. |
| [`credits`](#tax-credits) | A credit a company holds against the tax of one financial year, under a code its country pack declares. The amount is declared: working out a credit is the business of whatever grants it. |
| [`loss_rule_templates`](#tax-loss_rule_templates) | How far a loss of an earlier year may be set against the profit of this one: in full where the two limits are null, otherwise up to floor_amount plus percent_above of the profit beyond it. carry_forward_years is null where a loss never lapses. |
| [`loss_uses`](#tax-loss_uses) | How much of one loss a final computation set against its profit. Written when the computation is finalised and removed when it is withdrawn, so the stock is always what the final computations say. |
| [`losses`](#tax-losses) | The tax losses of a company by the year they come from. A row with no computation_id is declared: the stock a company brought in from before these books. A row with one was written when that computation was finalised. What is left of each is tax.loss_stock(). |
| [`parameter_templates`](#tax-parameter_templates) | The facts a company of one country has to declare for its tax to be computed: a judgement (is it a small company) or an amount (what it paid its director). The conditions of a rate name them, and nothing infers one. |
| [`prepayment_templates`](#tax-prepayment_templates) | When a company of this country pays its tax in advance, and what each payment is worth. Read by tax.prepayment_plan(). |
| [`prepayments`](#tax-prepayments) | One payment a company made in advance on the corporate income tax of a financial year, on the day it made it. Declared with tax.write; read by tax.prepayment_plan(), which counts it towards the first instalment due on or after that day. |
| [`rate_templates`](#tax-rate_templates) | One rate of a country, for the days it is in force. A rate with up_to applies to the slice of the taxable base below that amount; the one without applies to what is left. A rate whose conditions are not all met is not applied, and the estimate says which condition failed. |

<a id="tax-adjustment_rule_templates"></a>

#### `adjustment_rule_templates`

One rule of a country between the accounting result and the taxable one, for the days it is in force. A rule is never edited: a percentage that changes is a new row with a new valid_from and a valid_to on the old one, so a past year keeps its answer.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `code` | `text` | not null |
| `valid_from` | `date` | not null |
| `valid_to` | `date` |  |
| `valid_on` | `tax.validity_basis` | not null |
| `name` | `text` | not null |
| `name_i18n` | `jsonb` | not null |
| `direction` | `tax.adjustment_direction` | not null |
| `percent` | `numeric(9,6)` | The share of the base the rule moves: 100 for an expense refused in full, 31 for one refused for 31 %. Null where a formula works it out from what the company declares. |
| `formula` | `jsonb` | A closed vocabulary, read by tax.formula_percent(): a straight line of one declared variable, with an optional coefficient picked by a declared word, a floor, a ceiling and steps. Data, not an expression language. |
| `account_rules` | `jsonb` | not null — The accounts of the pack's chart whose whole balance falls under this rule, in the vocabulary of statement_line_rules: account_code, code_prefix, code_range. Empty where the chart keeps no account for it, and then a company says which of its accounts, or which amount, the rule applies to. |
| `legal_reference` | `text` | not null |
| `source_key` | `text` |  |
| `sequence` | `integer` | not null |

Constraints:

- `CHECK ((jsonb_typeof(account_rules) = 'array'::text))`
- `CHECK (((percent IS NULL) OR (percent >= (0)::numeric)))`
- `CHECK (((percent IS NULL) <> (formula IS NULL)))`
- `CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))`
- `PRIMARY KEY (country, code, valid_from)`

<a id="tax-adjustments"></a>

#### `adjustments`

What a company says falls under a rule of its country, in one of two ways. An account: its balance over the year is the base, read from the ledger each time, for one year or — with no fiscal_year_id — for every year. An amount: stated once, for one year. The rule, its percentage and its article stay in the pack.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `fiscal_year_id` | `uuid` |  |
| `rule_code` | `text` | not null |
| `account_id` | `uuid` | An account of the company whose whole balance is the base of the rule. An account named here is taken out of what the pack's own account rules catch, so it is never counted twice. |
| `amount` | `numeric` |  |
| `parameters` | `jsonb` | not null — What a rule with a formula needs to know about this expense — the emission of a car, its fuel — under the names the formula uses. |
| `note` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (((account_id IS NULL) <> (amount IS NULL)))`
- `CHECK (((amount IS NULL) OR (fiscal_year_id IS NOT NULL)))`
- `CHECK (((amount IS NULL) OR (amount >= (0)::numeric)))`
- `CHECK ((jsonb_typeof(parameters) = 'object'::text))`
- `PRIMARY KEY (id)`

<a id="tax-company_parameters"></a>

#### `company_parameters`

What a company states about itself for one financial year, under a code its country pack declares: a judgement or an amount. Stated per year because both change from one year to the next, and never worked out from the books.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `fiscal_year_id` | `uuid` | not null |
| `code` | `text` | not null |
| `value_boolean` | `boolean` |  |
| `value_amount` | `numeric` |  |
| `note` | `text` |  |
| `declared_by` | `uuid` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK (((value_boolean IS NULL) <> (value_amount IS NULL)))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, fiscal_year_id, code)`

<a id="tax-computation_lines"></a>

#### `computation_lines`

The lines tax.estimate() returned when a computation was recorded, as they were: the result, each adjustment with its rule and its article, the losses used, the base, each rate with its slice, the credits and the tax.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `computation_id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `sequence` | `integer` | not null |
| `kind` | `text` | not null |
| `code` | `text` |  |
| `name` | `text` |  |
| `base` | `numeric` |  |
| `rate` | `numeric` |  |
| `amount` | `numeric` |  |
| `legal_reference` | `text` |  |
| `source_key` | `text` |  |

Constraints:

- `PRIMARY KEY (id)`
- `UNIQUE (computation_id, sequence, company_id)`

<a id="tax-computations"></a>

#### `computations`

One computation of the tax of one financial year as it stood on a day, numbered per year. Written by tax.record_computation() and by nothing else: no role holds a write privilege on it. The four figures on the row are read off its lines when it is recorded.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `fiscal_year_id` | `uuid` | not null |
| `version` | `integer` | not null |
| `status` | `tax.computation_status` | not null |
| `computed_at` | `date` | not null — The day the ledger was read up to. A final computation is read up to the last day of the financial year. |
| `tax_code` | `text` | not null |
| `currency_code` | `character(3)` | not null |
| `accounting_result` | `numeric` | not null |
| `taxable_base` | `numeric` | not null |
| `loss_of_period` | `numeric` | not null |
| `tax` | `numeric` | not null — The tax this computation comes to. An estimate while status is estimate; what the company holds to be due once status is final. |
| `recorded_by` | `uuid` |  |
| `recorded_at` | `timestamp with time zone` | not null |
| `finalised_by` | `uuid` |  |
| `finalised_at` | `timestamp with time zone` |  |
| `superseded_by` | `uuid` |  |
| `superseded_at` | `timestamp with time zone` |  |

Constraints:

- `CHECK (((status = 'estimate'::tax.computation_status) = (finalised_at IS NULL)))`
- `CHECK (((status = 'superseded'::tax.computation_status) = (superseded_at IS NOT NULL)))`
- `CHECK ((version > 0))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, fiscal_year_id, version)`

<a id="tax-country_rules"></a>

#### `country_rules`

What one country calls its corporate income tax, which line of which income statement the computation starts from, and the accounts of its chart the tax is booked on. Filled by `ekwo pack build` from packs/<cc>/corporate_tax.json, read where it stands, never copied into a company.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `tax_code` | `text` | not null |
| `name` | `text` | not null |
| `name_i18n` | `jsonb` | not null |
| `result_statement_code` | `text` | not null |
| `result_line_code` | `text` | not null — The line of result_statement_code that is the accounting result the tax starts from. A country whose statement prints a result before income tax names that line; one that prints only the net result names it and adds the tax charge back by a rule. |
| `result_legal_reference` | `text` | not null |
| `result_source_key` | `text` |  |
| `expense_account_code` | `text` | not null — The account the tax charge of the year is booked on, by tax.book_provision(). |
| `payable_account_code` | `text` | not null — The account the estimated tax debt is carried on, against the charge tax.book_provision() books. |
| `receivable_account_code` | `text` | The account a prepayment or a refund to come is carried on, where the chart keeps one apart. **Declared, no reader yet**: the company books its payments itself, and tax.prepayments says what they were. |
| `accounts_legal_reference` | `text` | not null |
| `accounts_source_key` | `text` |  |
| `legal_reference` | `text` | not null |
| `source_key` | `text` |  |

Constraints:

- `CHECK ((country ~ '^[A-Z]{2}$'::text))`
- `PRIMARY KEY (country)`

<a id="tax-credit_templates"></a>

#### `credit_templates`

A credit a company of this country may set against its tax. The amount is the company's to declare; what the pack says is that the credit exists, whether what exceeds the tax is paid back, and the article it comes from.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `code` | `text` | not null |
| `valid_from` | `date` | not null |
| `valid_to` | `date` |  |
| `valid_on` | `tax.validity_basis` | not null |
| `name` | `text` | not null |
| `name_i18n` | `jsonb` | not null |
| `refundable` | `boolean` | not null |
| `legal_reference` | `text` | not null |
| `source_key` | `text` |  |
| `sequence` | `integer` | not null |

Constraints:

- `CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))`
- `PRIMARY KEY (country, code, valid_from)`

<a id="tax-credits"></a>

#### `credits`

A credit a company holds against the tax of one financial year, under a code its country pack declares. The amount is declared: working out a credit is the business of whatever grants it.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `fiscal_year_id` | `uuid` | not null |
| `credit_code` | `text` | not null |
| `amount` | `numeric` | not null |
| `note` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((amount > (0)::numeric))`
- `PRIMARY KEY (id)`

<a id="tax-loss_rule_templates"></a>

#### `loss_rule_templates`

How far a loss of an earlier year may be set against the profit of this one: in full where the two limits are null, otherwise up to floor_amount plus percent_above of the profit beyond it. carry_forward_years is null where a loss never lapses.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `valid_from` | `date` | not null |
| `valid_to` | `date` |  |
| `valid_on` | `tax.validity_basis` | not null |
| `floor_amount` | `numeric` |  |
| `percent_above` | `numeric(9,6)` |  |
| `carry_forward_years` | `integer` |  |
| `legal_reference` | `text` | not null |
| `source_key` | `text` |  |

Constraints:

- `CHECK (((floor_amount IS NULL) = (percent_above IS NULL)))`
- `CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))`
- `CHECK (((carry_forward_years IS NULL) OR (carry_forward_years > 0)))`
- `PRIMARY KEY (country, valid_from)`

<a id="tax-loss_uses"></a>

#### `loss_uses`

How much of one loss a final computation set against its profit. Written when the computation is finalised and removed when it is withdrawn, so the stock is always what the final computations say.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `loss_id` | `uuid` | not null |
| `computation_id` | `uuid` | not null |
| `amount` | `numeric` | not null |
| `created_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((amount > (0)::numeric))`
- `PRIMARY KEY (id)`
- `UNIQUE (loss_id, computation_id, company_id)`

<a id="tax-losses"></a>

#### `losses`

The tax losses of a company by the year they come from. A row with no computation_id is declared: the stock a company brought in from before these books. A row with one was written when that computation was finalised. What is left of each is tax.loss_stock().

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `origin_period_end` | `date` | not null — The last day of the financial year the loss was made in. Losses are used oldest first. |
| `amount` | `numeric` | not null |
| `computation_id` | `uuid` |  |
| `note` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((amount > (0)::numeric))`
- `PRIMARY KEY (id)`
- `UNIQUE (company_id, origin_period_end)`

<a id="tax-parameter_templates"></a>

#### `parameter_templates`

The facts a company of one country has to declare for its tax to be computed: a judgement (is it a small company) or an amount (what it paid its director). The conditions of a rate name them, and nothing infers one.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `code` | `text` | not null |
| `name` | `text` | not null |
| `name_i18n` | `jsonb` | not null |
| `value_type` | `tax.parameter_type` | not null |
| `legal_reference` | `text` | not null |
| `source_key` | `text` |  |
| `sequence` | `integer` | not null |

Constraints:

- `PRIMARY KEY (country, code)`

<a id="tax-prepayment_templates"></a>

#### `prepayment_templates`

When a company of this country pays its tax in advance, and what each payment is worth. Read by tax.prepayment_plan().

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `valid_from` | `date` | not null |
| `valid_to` | `date` |  |
| `valid_on` | `tax.validity_basis` | not null |
| `method` | `text` | not null — surcharge_on_shortfall: nothing is compulsory, the tax is raised by surcharge_percent and each instalment paid in time earns the credit_percent it carries. share_of_reference_tax: each instalment is share_percent of the tax of a reference year, and none is asked where that tax does not exceed exempt_up_to. |
| `month_basis` | `text` | not null — fiscal: an instalment falls in the n-th month of the financial year. calendar: it falls in a month of the calendar, whatever the financial year. |
| `instalments` | `jsonb` | not null |
| `surcharge_percent` | `numeric(9,6)` |  |
| `exempt_up_to` | `numeric` |  |
| `legal_reference` | `text` | not null |
| `source_key` | `text` |  |

Constraints:

- `CHECK ((jsonb_typeof(instalments) = 'array'::text))`
- `CHECK ((method = ANY (ARRAY['surcharge_on_shortfall'::text, 'share_of_reference_tax'::text])))`
- `CHECK ((month_basis = ANY (ARRAY['fiscal'::text, 'calendar'::text])))`
- `CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))`
- `PRIMARY KEY (country, valid_from)`

<a id="tax-prepayments"></a>

#### `prepayments`

One payment a company made in advance on the corporate income tax of a financial year, on the day it made it. Declared with tax.write; read by tax.prepayment_plan(), which counts it towards the first instalment due on or after that day.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | not null |
| `company_id` | `uuid` | not null |
| `fiscal_year_id` | `uuid` | not null |
| `paid_on` | `date` | not null |
| `amount` | `numeric` | not null |
| `entry_id` | `uuid` | The entry of the ledger that carried the payment, where the company points at it: its bank entry. Optional, and never read for the amount: the amount is the one declared here. |
| `note` | `text` |  |
| `created_at` | `timestamp with time zone` | not null |
| `updated_at` | `timestamp with time zone` | not null |

Constraints:

- `CHECK ((amount > (0)::numeric))`
- `PRIMARY KEY (id)`

<a id="tax-rate_templates"></a>

#### `rate_templates`

One rate of a country, for the days it is in force. A rate with up_to applies to the slice of the taxable base below that amount; the one without applies to what is left. A rate whose conditions are not all met is not applied, and the estimate says which condition failed.

| Column | Type | Notes |
|---|---|---|
| `country` | `character(2)` | not null |
| `code` | `text` | not null |
| `valid_from` | `date` | not null |
| `valid_to` | `date` |  |
| `valid_on` | `tax.validity_basis` | not null |
| `name` | `text` | not null |
| `name_i18n` | `jsonb` | not null |
| `rate` | `numeric(9,6)` | not null |
| `up_to` | `numeric` |  |
| `up_to_prorata` | `text` | not null — none: the threshold is the same whatever the length of the financial year. months: it is stated for twelve months and shared out over the months the year actually has. |
| `conditions` | `jsonb` | not null — Every one has to be met. Each names a parameter the company declares and a test from a closed list — is_true, is_false, at_least, at_most, below, above — read by tax.condition_failure(). |
| `legal_reference` | `text` | not null |
| `source_key` | `text` |  |
| `sequence` | `integer` | not null |

Constraints:

- `CHECK (((rate >= (0)::numeric) AND (rate <= (100)::numeric)))`
- `CHECK ((jsonb_typeof(conditions) = 'array'::text))`
- `CHECK ((up_to_prorata = ANY (ARRAY['none'::text, 'months'::text])))`
- `CHECK (((up_to IS NULL) OR (up_to > (0)::numeric)))`
- `CHECK (((valid_to IS NULL) OR (valid_to >= valid_from)))`
- `PRIMARY KEY (country, code, valid_from)`

### Functions

| Function | Purpose |
|---|---|
| `account_matches(p_account_code text, p_account_rules jsonb)` | Whether an account code is caught by the account rules of an adjustment rule. The three kinds are the ones a statement line maps accounts with, compared the same way. |
| `accounts_in_use(p_company_id uuid)` | The accounts this module points at for one company: every account it says falls under an adjustment rule. Read by ekwo.accounts_in_use() through the module convention. |
| `archive_tables()` | What an archive of one company does with each table of this module: all eight travel. The seven reference tables belong to the installation and to no company. Read by `ekwo.company_archive_tables()`. |
| `book_provision(p_computation_id uuid)` | Books the tax of a recorded computation as a charge of its year: the difference between what the computation says and what the expense account of the pack already carries for the year up to the day of the computation, against the payable account of the pack, through post_module_entry(), dated on that day. Returns the entry, or null when there was nothing to book. The latest computation of a year, estimate or final; one entry per computation, so a second call returns the first. Needs tax.write, and the right to post entries. |
| `condition_failure(p_condition jsonb, p_values jsonb, p_taxable_base numeric)` | Null when a condition of a rate is met by what the company declared, otherwise which parameter stands in the way and how: not_declared, or not_met. A parameter nobody declared is never assumed either way. |
| `estimate(p_company_id uuid, p_fiscal_year_id uuid, p_at date)` | The corporate income tax of one financial year as the ledger stands on a day — the whole year when no day is given — line by line: the accounting result the country pack names, each adjustment with its rule and its article, the losses of earlier years as far as they reach, the taxable base, each rate with the slice it takes, the credits, and the figure, called estimated_tax. Reads and writes nothing. A condition the company has not declared is not met and is said so in a rate_not_applied line. No country rule lives in this function. |
| `finalise_computation(p_computation_id uuid)` | Calls the latest computation of a financial year final: what the company holds to be the tax of the year. Only a computation of the whole year, only while the ledger, the declarations and the rules still give the same lines, and only while no later year is final. Its last line becomes tax_due, the losses it used leave the stock and the loss it made enters it. Needs tax.finalize, which the owner preset holds and the accountant preset does not. |
| `formula_percent(p_formula jsonb, p_parameters jsonb)` | The percentage of its base a rule with a formula moves, from what an adjustment states. A straight line of one variable — intercept plus slope times coefficient times the variable — rounded where the law rounds it, held between a floor and a ceiling, then replaced by a step where one is reached. A formula that yields the deductible share answers with what is left of a hundred. Raises by name when the adjustment does not state what the formula needs. |
| `guard_declaration()` | Holds what a company declares to the codes its country pack carries — a parameter and its type, a rule, a credit — and to a financial year of its own, and writes every declared amount at the decimals of the company's currency. |
| `guard_loss()` | Writes a loss at the decimals of the company's currency, and refuses to change the amount or the year of one a final computation has used. |
| `in_force(p_valid_from date, p_valid_to date, p_valid_on tax.validity_basis, p_start date, p_end date)` | Whether a dated rule applies to a financial year: its validity read on the first or on the last day of the year, as the rule itself says. The only place valid_on is read. |
| `instalment_date(p_month_basis text, p_month integer, p_day integer, p_start date, p_end date)` | The day an instalment falls on in a financial year: the given day of the n-th month of the year (fiscal), or of the first month of that name on or after the year opens (calendar); the last day of the month where the month is shorter. Null when that day is outside the year. |
| `line(p_kind text, p_code text, p_name text, p_base numeric, p_rate numeric, p_amount numeric, p_legal_reference text, p_source_key text)` | One line of an estimate, as tax.estimate() gathers them before returning them in order. |
| `loss_stock(p_company_id uuid, p_before date)` | The losses of a company by year of origin: what each was, what final computations have used of it, and what is left. With a date, as the stock stood for a financial year opening on that day: losses of earlier years, less what earlier years used. |
| `plan_instalments(p_instalments jsonb)` | The instalments tax.prepayment_plan() gathers, as rows, in the order it gathered them. |
| `prepayment_plan(p_company_id uuid, p_fiscal_year_id uuid, p_at date, p_tax numeric)` | The prepayments of a financial year under the rule of its country pack, line by line: each instalment with its day, its percentage, what it is worth and what was paid towards it. share_of_reference_tax: each instalment is its share of the final tax of the year before, or of a reference the company states, and nothing where that tax is within the exemption. surcharge_on_shortfall: the surcharge on the tax of the latest computation of the year, or of a tax the company states, what the payments made already earn against it, and the same amount at each instalment due on or after p_at that leaves no surcharge — never more, together, than the tax still unpaid. Reads and writes nothing else. |
| `record_computation(p_company_id uuid, p_fiscal_year_id uuid, p_at date)` | Keeps what tax.estimate() says on a day as the next computation of the year, with every line. An estimate, and called one. Refused once the year has a final computation. Needs tax.write. |
| `round_prepayment()` | Writes a payment in advance at the decimals of the company currency, and refuses one that rounds to nothing. |
| `withdraw_computation(p_computation_id uuid)` | Withdraws a final computation: it becomes superseded and is kept, the losses it used go back to the stock and the loss it recorded leaves it. Refused while a later financial year has a final computation: the years are taken back in the reverse of their order. Needs tax.finalize. |

---

*This file is generated by `scripts/generate-schema-doc.mjs`. Edit the
migrations and `docs/schema.intro.md`, then regenerate.*
