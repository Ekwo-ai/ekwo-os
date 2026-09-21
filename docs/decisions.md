# Decisions

Why the schema is shaped this way. One paragraph each, with the reason, so a
future contributor can argue with the reason rather than guess at it.

## The instance

**One installation belongs to one customer, and `instance` records it.** A
single row — primary key `1`, plus a check constraint, so a second one is
impossible rather than merely unusual — holding a locally generated
`instance_id`, the organisation's name, its country, the edition, the schema
version and the install date. This table is the reason there is no
`tenant_id` anywhere in the schema: the instance *is* the tenant, so the
cross-customer column and its risk of leaking never exist. What remains
inside an instance is several companies and several people with different
rights, which is `company_id` and row level security.

**Registering with Ekwo is an opt-in, and never a condition of use.**
`contact_email` and `registered_at` are empty on a fresh install. Nothing
writes them unless the operator calls `register_instance()`, nothing in this
repository reads them, and `unregister_instance()` puts them back —
because opting in that cannot be undone is not a choice. `instance_id` is
generated locally and is not a licence key: no code path checks it, and no
feature depends on it.

**`edition` records who operates the installation, and gates nothing.**
`community` when you run it yourself, `cloud` when Ekwo does. It is there so
support and migrations know what they are looking at, not so a feature can be
switched off. Gating an accounting feature on a column would make the open
core a demo.

**There is an instance-level role, and it lives in its own table.**
`instance_admins` is keyed on the user alone, because that is genuinely its
key: a company role is keyed by (company, user). Making `company_id` nullable
in `company_members` to hold an instance role would break its primary key and
the meaning of every row in it. The table name carries the role, so there is
no `role` column to get wrong. `member_role` still carries `instance_admin`
as a value, so an interface can render one list of roles for the whole
installation, and `company_members` refuses it by check constraint.

**An instance administrator creates companies and invites members; that is
all.** They can list the companies and administer them, and they cannot read
a ledger they were not invited to. Administering an installation is not the
same as being on the books, and a test asserts the difference.

**The first user to ask takes the instance.** `claim_instance_admin()` is
open while `instance_members` is empty and closed afterwards, which is the
same bootstrap the first member of a company gets. It avoids an installer
that has to hold a password.

**A select policy has to follow every insert policy.** `insert ... returning`
is checked against the select policy as well, and PostgREST always returns
the row, so an administrator creating a company would have seen the row
created and an error returned. `companies_select` and
`company_members_select` therefore admit the instance administrator too. This
is worth writing down because the symptom — "violates row-level security" on
a row that was in fact written — points at the wrong policy.

**Users live in the customer's own Supabase Auth.** `company_members.user_id`
and `instance_admins.user_id` hold an `auth.users.id` from the customer's
project, matched against `auth.uid()` in every policy. Ekwo holds no account
and no directory.

**The foreign key onto `auth.users` is on `instance_admins` and deliberately
not on `company_members`.** An administrator is necessarily a signed-in user,
so there is nothing to accommodate and the key costs nothing. A company
membership is different: inviting someone into a company before they have an
account is a normal thing to want, and a foreign key would forbid it. The
price of the asymmetry is that a deleted auth user leaves an orphan company
membership, which a cleanup job handles; the instance administrator row
cascades away on its own. Outside Supabase the schema needs an `auth.users`
table to exist — `tests/helpers/supabase-shim.sql` shows the two columns that
are enough.

**Reading the instance row is for people who are on this installation.** A
member of at least one company, or an administrator. Not simply anyone
holding a valid token: on a shared Supabase project that would tell a
stranger which organisation runs here.

## Structure

**Documents and entries stay two layers, joined by a foreign key.** An invoice
answers to EN 16931 and Peppol; an entry answers to the chart of accounts and
to the FEC. Merging them into one table buys a shorter schema and costs a
display-type discriminator with nine values on every ledger line. Unified
accounting APIs that had no reason to copy anyone — Merge, Apideck — keep the
two apart, and so do we. What we do not keep is the string join: `documents.entry_id`
is a real foreign key, not `reference = 'INVOICE-' || number`.

**Sales invoices, purchase invoices, credit notes and quotes are one table
with a `doc_type`.** Not to imitate anyone, but because matching, attachments,
bank reconciliation and Peppol are otherwise written once per table. One path
per object.

**Document lines are a table, not JSON.** EN 16931 requires a VAT category per
line, Peppol validation checks it, the FEC wants the detail, and JSON is
neither indexable nor aggregatable nor constrainable.

**No `tenant_id`.** One instance belongs to one customer. Several companies
inside one instance is the normal case — a firm with its clients — so
`company_id` and role-based row level security stay, and the cross-customer
layer disappears along with its risk of leaking.

**`company_id` is repeated on child tables, and a composite foreign key keeps
it honest.** `entry_lines(entry_id, company_id)` references
`entries(id, company_id)`, so the denormalisation cannot drift. The alternative
— a join to the parent inside every policy — makes row level security a
performance problem on the largest tables.

**`entry_date`, `state` and `journal_id` are *not* copied onto entry lines.**
Denormalising them makes reports faster and gives the schema a second source
of truth for three facts. Reports join; if that ever hurts, an index or a
materialised view is the answer, not a copy.

## Accounts

**Eighteen account types instead of five.** `asset_receivable` and
`liability_payable` are what make the aged balance, reconcilability and the
statement mapping computable. With five types, all of that lives in code
patterns on account codes — and `411` means *customers* on the French chart
and *recoverable VAT* on the Belgian one, so a pattern that works in one
country silently books to the wrong account in the other.

**The balance-sheet group is derived, not stored.** `internal_group` is a
generated column over `account_type`, and `carries_forward` likewise. Neither
can drift from the type.

**A receivable or payable account that is not reconcilable is refused by a
check constraint.** Without matching there is no residual, no aged balance and
no FEC letter, so the configuration is not merely unusual, it is broken.

**Accounts are resolved by role, never by code prefix.** Order of resolution:
the contact's override, then the company default. `tax_postings.account_id`
does the same for VAT. `LIKE '411%' ORDER BY code LIMIT 1` is how a customer
debit ends up on a VAT account.

## Amounts and signs

**Amounts are always positive; a reversal flips the side.** A credit note
debits what the invoice credited, with the same positive figures. Negative
debits break every check constraint that says a line has one side, and they
make a trial balance unreadable.

**Totals are derived from the lines, never keyed in.** `document_lines.amount_untaxed`
is a generated column; document and entry totals are maintained by trigger.
Where a header and its lines can disagree, one day they will, and the ledger
is the one that has to be right.

**What a document has been settled by is derived from its matching.**
`documents.amount_paid` is recomputed from the matched amounts on the
third-party lines of its entry, so `amount_residual` and `payment_state`
follow from the ledger rather than from whoever remembered to update the
header. It shipped as a column somebody had to write by hand, which was the
rule above broken on its own terms; the recomputation is folded into the
existing reconciliation trigger rather than added as a second one, because two
`after` row triggers on the same table fire in name order and this one has to
run after the line residuals are updated. A value written by hand still
sticks until the next matching, because the socle does not yet model a
prepayment that is settled against nothing.

**The counterpart line is the difference of everything already written.** The
entry therefore balances by construction, and when the document header
disagrees with it, `post_document` raises and names the document. The header
is what is wrong; patching a ledger line to make the header true is how a
wrong invoice becomes a wrong ledger.

**One discount rule in the whole system: a percentage off the line.**
`quantity x unit_price x (1 - discount / 100)`, rounded once, at the decimals
of the document's currency.
Three coexisting discount semantics is a real failure mode, and an absolute
discount amount can be expressed as a percentage or as its own line.

**VAT is rounded once per tax group, on the rounded basis.** That is
EN 16931 BR-CO-14 and what every validator checks. Not per line, which
accumulates drift; not on the document total, which loses the breakdown.

**A missing tax is a missing tax, never zero per cent.** A line with no
`tax_id` produces a base line with no declaration box. Defaulting to zero
turns a data-entry gap into a false return.

## Taxes

**`tax_postings` carry both the ledger account and the declaration box.**
Country rules become rows: a tax says how much, its postings say where it
lands. Adding a régime is data, not a release, and the VAT return needs no
country-specific code — `vat_return()` just sums what the postings wrote.

**A positive `factor_percent` keeps the side of the base; a negative one flips
it.** That single rule expresses self-assessment: +100 on the recoverable
account and -100 on the payable one net to zero in the ledger while both
boxes are filled. The alternative — a boolean for reverse charge that nothing
reads — leaves the ledger and the return disagreeing on every intra-community
purchase, by construction.

**`box_factor_percent` is separate from `factor_percent`.** A box is filled
with the sign the form expects, which has nothing to do with which side of the
ledger the amount landed on. Conflating them means a box comes out negative
and the file is rejected.

**A tax whose tax postings net to zero is not added to the document total.**
That falls out of the postings rather than needing a flag: on a self-assessed
purchase the supplier is owed the net amount, and the VAT never leaves.

**Goods, services and capital goods are separate taxes, not a guess.** Boxes
81, 82 and 83 in Belgium cannot be derived from a rate and a country. Three
taxes at the same rate is the honest model, and it is how national
localisations everywhere do it.

**Taxes have `valid_from` and `valid_to`.** A rate change is a period, not a
new record to be archived; `post_document` refuses a tax that is not in force
on the accounting date, rather than silently rewriting history.

## Numbering, locks and state

**Entry numbers are `CODE/YYYY/NNNN`, counted per journal *and* per year.** A
counter per journal alone makes the year in the number decorative. The counter
is a row in `journal_sequences`, so concurrent bookings serialise on that row
and not on the journal.

**A number is assigned at posting, not at creation.** A draft that is deleted
should not leave a hole in the sequence.

**`state` and `payment_state` are different questions, and so is `sent_at`.**
One column that mixes "draft", "sent" and "paid" cannot answer any of the
three.

**Locks are triggers on `entries` and `entry_lines`, not application checks.**
`lock_date`, `tax_lock_date` and a closed fiscal year are enforced in the
database, because the path that bypasses the application is exactly the path
that needs stopping. Matching is exempt: it changes no account and stays
possible after a period closes.

**Everything raises. Nothing warns.** An exception handler that logs and
returns leaves the document saved and the entry missing, cleanly and silently.
Postgres error codes are prefixed with a stable identifier
(`period_locked:`, `entry_unbalanced:`) so callers can match on them.

## Reports

**Posted entries are filtered in `WHERE`, never in a `LEFT JOIN` condition.**
A line whose entry is not posted survives an outer join with a null entry and
walks straight into the closing balance. This is a named class of bug and the
schema tests for it.

**The aged balance reads the ledger, not the invoices.** It buckets what is
still unmatched on reconcilable third-party accounts, by `date_maturity`. An
aged balance computed from documents can never tie back to the balance sheet,
and a test asserts that this one does.

**`vat_return()` knows no country rule.** It sums `declaration_box` and
`box_amount` off the ledger lines. The only exception is boxes 71 and 72 for
Belgium, which are the arithmetic of the other boxes and are flagged
`computed = true`.

## The installer

**Ekwo provisions no Supabase project and pays for none.** The customer
creates the project; `npx ekwo init` connects to it. The alternative — a
Management API call that creates a project under an Ekwo-held token — would
make every Community installation depend on an Ekwo account and an Ekwo
billing relationship, which is the thing this project exists not to do. It
also costs the operator nothing: the free plan is enough to start, and their
books are on their account from the first row.

**The CLI requires Node and nothing else.** Not the Supabase CLI, not Docker,
not psql. It opens a Postgres connection and applies the SQL itself. Requiring
a second tool to install the first one loses people at the step where they
have decided to try it.

**The migration history is Supabase's, not ours.** `ekwo migrate` writes
`supabase_migrations.schema_migrations` — the same schema, the same table, the
same `version` / `name` / `statements` columns, `version` being the timestamp
prefix of the filename. So `supabase db push` and `ekwo migrate` are
interchangeable in both directions, and an operator who prefers the Supabase
CLI never has to choose. A private history table would have been simpler to
write and would have forked the ecosystem at the first `db push`.

**Each migration is applied whole, in one transaction with its history row.**
The file is sent as a single command string, so Postgres runs it as one unit;
the insert that records it commits with it. A migration that fails halfway
therefore leaves neither half-applied schema nor a history row that lies, and
the next run resumes at the file that failed. The consequence, which is a rule
for contributors: no migration may open a transaction of its own.

**`statements` is recorded but never executed.** The column is split out of
the file by a small parser that understands dollar quoting, `E''` escapes and
nested block comments. Execution does not go through it. A bug in the splitter
can therefore make that column less pretty and can never break an
installation — which is the right place to put a parser nobody has to trust.

**The first administrator is created through GoTrue, not through SQL.** Every
policy compares `auth.uid()` against a row, and `auth.uid()` reads the JWT of
the request. The CLI holds a connection, not a session: it runs as the
database owner, `auth.uid()` is NULL and row level security is *bypassed*
rather than satisfied. So the installer cannot be the first user; it can only
create one and write the rows that user will be recognised by. Writing
`auth.users` by hand was the alternative and it produces an account that looks
right and cannot sign in — the password hash, the confirmation state and the
identity row belong to GoTrue. This is the only reason the `service_role` key
is ever asked for, and `--admin-user-id` avoids it entirely when the account
already exists.

**Where a guard lives in a function, the CLI satisfies it rather than going
round it.** `register_instance()` refuses anyone who is not an instance
administrator, and a superuser connection is nobody. So the CLI sets
`request.jwt.claims` the way PostgREST does, for the administrator it is
acting for, and calls the function. It would have been one line shorter to
update the column directly; it would also have meant the rule only applies to
clients that happen to respect it.

**No secret is ever written to disk.** The database password and the
`service_role` key come from a flag, an environment variable or a masked
prompt, and are forgotten. `ekwo.json` holds the project URL, the country and
the schema version — a file that is safe to commit, so it stays useful. A
credential cache would have saved one paste per command and would have made
the first accidental `git add .` a disclosure.

**One runtime dependency, the Postgres driver.** Argument parsing, the
prompts and the masked input are written out in the package. Everything this
CLI is handed is a secret, so every dependency is one more thing that could
read it, and the three it replaces are a few dozen lines each.

**Orphaned memberships are a `doctor` warning, not a foreign key.**
`company_members` has no key to `auth.users` on purpose: inviting someone into
a company before they have an account is a normal thing to want, and a key
forbids it. The price is that deleting a user leaves a row behind. Those rows
grant nothing — `auth.uid()` can never match them — but they misreport who has
access, so `ekwo doctor` names them and leaves the decision alone. Deleting
them automatically would silently undo an invitation that has not been taken
up yet. `instance_admins` does have the key, and cascades, because an
administrator is necessarily a signed-in user.

**There is no `eject`.** Nothing is held to eject from: the data is already in
the customer's database, the schema is AGPL-3.0 in this repository, and
`supabase db push` keeps applying it if the CLI is never run again. The help
says so rather than staying silent, because "how do I get out" is the first
question an open-core promise has to answer.

**The demo seed is a command of its own and refuses to be routine.** It
invents a company *and* a fictional administrator, because it has to stand
alone on an empty database. `ekwo init` never applies it, `ekwo migrate` never
applies it, and `ekwo demo` asks before adding it to an installation that
already holds a company.

**The account of a document line is resolved in the database, and the tax is
not.** Order for the account, most specific first: the line, the product, the
company default (`default_sales_account_id` / `default_purchase_account_id`),
the country model (`country_defaults.sales_account_code` /
`purchase_account_code`). It runs in a trigger on `document_lines` rather than
in each client, because `document_lines_product_has_account` forbids a product
line with no account — so a null account can only ever mean "resolve it", and
every client that inserts a line, MCP server or PostgREST or psql, has to get
the same answer. A null *tax* is the opposite case: it means no tax at all,
which is a real answer, so nothing fills it in. What a product carries besides
its account — description, price, unit, tax — is a pre-fill done by whoever is
typing the line, the way an ERP's onchange works: those columns accept a
chosen value, and overwriting them in a trigger would take the choice away.

**Three columns of `country_defaults` were given a reader rather than
deleted.** `sales_account_code`, `purchase_account_code` and `currency_code`
shipped in the first release and were read by nothing, which is the state the
naming policy forbids: keep it or use it, never "in case". The first two are
the last step of the resolution above. The third is read by `ekwo init`, which
offers it as the currency of the company — and it has to be read there,
because `companies.currency_code` is `not null default 'EUR'` and is therefore
never empty by the time `install_country_template` runs. Deleting a published
column is irreversible and would have been the easier decision to defend and
the harder one to undo.

**A bank account is created from its IBAN and nothing else is asked.** The
journal and the ledger account behind it are already chosen — the country
template points the bank journal at 550000 or 512000 — so asking for them
would be asking the operator to repeat what the model already says. The IBAN
is the one fact nobody can derive, and it is also the natural key: a unique
index on `(company_id, iban)` makes `ekwo init --iban …` and
`create_bank_account` idempotent without a flag for it. A company with no bank
account is a `doctor` warning and never an error: payments still book on the
journal's default account, but there is no IBAN for an invoice and no
statement to reconcile against.

**`--db-region` no longer derives a hostname.** The pooler host carries a
generation prefix as well as a region, and the region does not determine it: a
project created in `eu-west-3` in September 2026 answered on `aws-1-eu-west-3`
and returned "Tenant or user not found" on `aws-0-` — a message that reads
like a wrong password. So both are opened and the one that answers is kept and
printed. Without a region nothing is built at all: the direct host
`db.<ref>.supabase.co` is IPv6-only on recent projects, and deriving it
silently produces a hang rather than an error, so the CLI asks for the string
the dashboard prints instead. A convenience that fails in a way that points at
the wrong cause is worse than a question.

## Products

**A product is in the core, not in a module beside it.** Every invoice line
answers the same four questions — what is it called, what does it cost, which
account, which tax — and a catalogue is the place those answers are written
once. Putting it in a module would mean `document_lines.product_id` either
does not exist (and the module reinvents the join) or exists and points at a
table the core does not ship, which is the worst of the two.

**It is a catalogue, not stock.** No quantity on hand, no valuation, no
movements. Stock is a different piece of software with its own correctness
problems — costing methods, negative quantities, period-end valuation — and
the moment those live next to the ledger, a wrong stock movement becomes a
wrong entry. What a business sells is in the core; what it holds in a
warehouse is not.

**A product pre-fills a line and never constrains it.** The line keeps its own
text, price, unit, account and tax, and anything the caller gave wins over the
catalogue. So `products.name` changing next month cannot alter what an invoice
said last month, and `product_id` on a posted line is a reference to where the
line came from rather than a source the line is read through. This is also why
`document_lines.product_id` has `on delete restrict` and why withdrawing a
product is `active = false`: deleting one referenced by a posted invoice would
quietly rewrite a document.

**`product_id` is nullable and always will be.** Free text is how most
invoices are written. A schema that demands a catalogue row per line makes the
operator invent one, and a catalogue of inventions is worse than no catalogue.

**The unit stays on `document_lines.unit_code`, and the product fills it in.**
That column shipped in the first release, mapped to BT-130. A second `unit`
column beside it would be two answers to one question. The check on
`products.unit_code` is on the shape only — three characters, upper case —
because UN/ECE recommendation 20 carries some eighteen hundred codes and a
short list in the database would refuse `KWH` or `TNE` on the grounds that a
developer had not thought of them. The short list lives in `@ekwo-ai/core` as
what a client *proposes*.

**BT-155 is the product code and lives nowhere else.** The seller's item
identifier is exactly what `products.code` is, so a line with no product has
none — which is the correct answer, since BT-155 is optional in EN 16931,
rather than a gap to fill with the line number. `document_line_items` is the
view that puts BT-153, BT-154 and BT-155 side by side for whoever is building
a Factur-X or Peppol document; `docs/mapping.md` carries the field-by-field
mapping, and it is written down rather than imported because
`@ekwo-ai/factur-x` is in a private repository that CI cannot install from.
*(Superseded on 12 September 2026 by "Format libraries live in this
repository" below: the brick is now `packages/formats/factur-x`, and CI builds
and tests it with everything else. The mapping stays written down — it is
documentation, not a dependency.)*

## The MCP server

**It acts as the user, and never as `service_role`.** The server signs in with
the operator's own address and password — or takes their access token — and
everything it can then read or write is what row level security lets that
person read or write. The alternative was one service key and a `company_id`
argument, which is shorter to write and means an assistant that can answer for
every company of an installation, including the ones its user was never
invited to. The key is refused at startup in both shapes Supabase has issued,
because a mistake that appears to work is the expensive kind.

**The direct-Postgres mode demands the user it acts for.** `EKWO_DB_URL` exists
for a self-hosted installation with no PostgREST in front of the database, and
a database connection is nobody: `auth.uid()` is null and row level security
is bypassed rather than satisfied. So that mode requires
`EKWO_ACT_AS_USER_ID`, and every query runs inside a transaction that sets
`request.jwt.claims` and switches to the `authenticated` role. Without that,
the fallback would quietly be the privileged mode, and it is the one an
operator in a hurry would reach for.

**Every ledger write goes through a function of the schema.** `post_document`,
`post_payment`, `post_entry`, `reconcile`, `unreconcile`. Nothing in the MCP
package inserts an `entries` or an `entry_lines` row; the direct inserts it
does are the objects a person types — contacts, draft documents and their
lines, payments, bank transactions. The moment a client writes ledger lines,
the rules about sides, accounts, rounding and locks live in that client, and
the next client answers differently. `post_payment` was added for exactly this
reason: money moving had no function, so a client would have had to assemble
the two lines itself.

**No tool deletes or edits a posted entry.** There is no unpost and no way to
ask for one. A mistake is corrected with a credit note, which is how
accounting has always worked and what an audit trail means. `unreconcile` is
the only undo in the server, and matching changes no account.

**Amounts cross as decimal strings, in both directions.** `numeric` is exact
and a float is not; a table read asks for `amount::text` and a date for
`date::text`, so `"1210.00"` and `"2026-06-15"` arrive as themselves on either
route rather than as whatever a driver or JSON made of them. The one place a
float can appear is a function result crossing PostgREST as JSON, and it is
rendered back to two decimals in one place.

**Refusals are answers.** `period_locked:`, `entry_unbalanced:`,
`document_total_mismatch:` travel to the model with the message the database
raised, plus one sentence saying what it means. Paraphrasing them, or catching
them and retrying with a different date, would turn a company's own rule into
an obstacle the assistant routes around.

**One query language for two backends.** Tool handlers are written against
five operations — select, insert, update, delete, call a function — and each
backend implements them: PostgREST through `@supabase/supabase-js`, Postgres
through parameterised SQL. The library is a dependency this repository would
otherwise have avoided, but the two things it does here are the password grant
with its refresh and the PostgREST query string, which are exactly the parts
no test in this repository can exercise. Untested code of our own was the
worse trade.

## Licensing and packaging

**AGPL-3.0 for the core, MIT for the format libraries.** The format libraries'
value is ubiquity — they should be able to end up inside a competitor, a
software house or an administration. The core's value is that nobody can turn
it into a closed service. Installing it and running it internally, modified or
not, obliges the installer to nothing.

**A contributor licence agreement is mandatory.** Without it the project can
never change its licence, and recent history shows that projects sometimes
have to.

**`ee/` lives in this repository, with its own licence.** A separate private
repository would make every schema change a two-repository coordination
problem, and this project does not have the people to pay for that.

**The line between free and paid is operational, not functional.** If it keeps
working when Ekwo disappears, it is free. Removing the footer attribution is
never sold: it is an attribution, not a toll.

## Scope of this release

**No Odoo-compatible RPC adapter.** Nobody consumes an Odoo-compatible
*server*; every verified integration is a client reading a real Odoo. The route
to the French filing tools is the FEC, which is an order of the
administration rather than an API, and Odoo has dated the removal of
`/xmlrpc` and `/jsonrpc`. A published mapping table costs five per cent of an
adapter and is more useful — see [mapping.md](mapping.md).

**Only percentage taxes can be posted.** `amount_type = 'fixed'` exists in the
schema and `post_document` refuses it rather than guessing how to spread a
fixed amount over lines.

**No fiscal year closing function yet.** Carrying balances forward and merging
the result into retained earnings is a real piece of work with several
national variants; `fiscal_years.is_closed` already blocks writes, and the
closing entry itself comes next. *(Superseded on 12 September 2026 by "Opening and closing are
parameters, not code" below.)*

**No multi-currency revaluation.** `currencies`, `currency_rates`,
`amount_currency` and `documents.exchange_rate` are in place; the periodic
revaluation of open items in foreign currency is not.


## The anonymous role executes only the policy helpers (11 September 2026)

Postgres grants EXECUTE on a new function to PUBLIC, and Supabase exposes the
functions of `public` as RPC endpoints, so every function of the schema was
callable without signing in. Row level security made each call return an
empty set, which is safe and still wrong: the surface should be closed, not
merely empty. Migration `20260911210131` revokes EXECUTE from PUBLIC and from
`anon`, grants it to `authenticated` and `service_role`, and changes the
default privileges so that a function written next month starts closed.

Eight helpers keep their grant to `anon`: `company_role`, `is_company_member`,
`can_write_company`, `is_company_owner`, `is_instance_admin`,
`is_any_company_member`, `company_has_no_member`, `instance_has_no_admin`.
Policies call them on behalf of whoever is asking, and without EXECUTE an
anonymous SELECT would raise "permission denied for function" instead of
returning nothing. They answer only about `auth.uid()`, which is null for
`anon`, so what they give away is the word *no*.

In the same migration, `instance_admins` stops being readable by every
signed-in user. Self sign-up is on by default on a Supabase project, so a
signed-in stranger is an ordinary thing; administrators are visible to the
members of a company, to administrators, and to oneself. The README now says
to turn public sign-ups off, which the schema cannot do by itself.


## A country is a pack of data, compiled into SQL (12 September 2026)

The one taxonomy in the international plan that will not get to be redone,
settled before any code was written.

**The truth of a country lives in `packs/<cc>/`**: JSON with a published JSON
schema for everything structured, one `accounts.csv` for the chart, an
`i18n/` folder of labels, and a `golden/` folder of expected results —
**built on 14 September 2026**; see the section at the end of this file. No YAML, no
TOML, no package per country: the CLI has one dependency and Node reads JSON.
`ekwo pack build` compiles a pack into a seed SQL file that is committed, and
the CI refuses a seed that is not the exact output of its pack — the SQL is
a build artefact, like `docs/schema.md`. `supabase db push` and `psql -f`
remain enough to install without the CLI. The runtime stays the existing
`*_templates` tables, extended additively; a company still copies them at
install time.

**A pack is versioned** (semver in its manifest); `country_packs` records what
the instance holds and `company_packs` what each company copied.
`ekwo pack upgrade` — **built on 14 September 2026**, together with `ekwo pack
status`; see the section at the end of this file — diffs by
natural key `(country, code)` and follows three rules: an addition is applied,
a validity that closes is applied, everything else is listed and never applied
without explicit consent. A new VAT rate is
a new tax plus a `valid_to` on the old one, never an edit. Once published, an
account code and its type, a tax code and its meaning, and a box in a form
version are immutable: things are retired, never renamed or deleted.

**Two findings that changed the plan.** The seeds were `on conflict do
nothing`, so an installed instance received no pack change at all — not even
for a company created afterwards; generated seeds upsert on the template
tables only. And the French pack is wrong today for every service business,
because French VAT on services is due on collection; cash-basis VAT is a
Belgian-French hole before it is a British option.

**Declaration boxes and financial statements become data** with declarative
formulas — lists of boxes to add and subtract and a floor at zero, no
expression language — which removes the last `fiscal_country = 'BE'` from
`vat_return()`. A test asserts that no function of the schema contains a
country code. A generic statement by account type gives a readable balance
sheet on any chart, including the code-less charts of the UK and the US.

**Kept in phase 0**: the pack format; opening balances and a parameterised
year-end close; cash-basis VAT and non-deductible VAT (`tax_on_base`);
realised exchange differences at matching; translated labels; and the
append-only `audit_log` by trigger, **built on 14 September 2026** with the two
`ekwo pack` subcommands above. **Deferred**: revaluation of open items, cash
accounting as a ledger (a report derived from matched payments instead), the
cash-flow statement (indirect, when it comes), several taxes on one line
(`document_line_taxes`, with Canada). Shifted and 52/53-week years were
already covered by `fiscal_years`.

**A golden test is the contract of a pack, not proof of legal truth.** Each
box and each tax cites its legal source, the manifest carries a certification
status that `ekwo init` prints, and a pack moves to *reviewed* only after a
named professional has read it. Ekwo **maintains** Belgium and France — the
line above said "certifies" until the scale was settled on 12 September, and
there is deliberately no status that means certified by Ekwo.


## The pack format, built: `packs/`, a compiler, and two tables (12 September 2026)

What the decision above became, in two changes, and what it deliberately left
for later.

**Built.** `packs/be/` and `packs/fr/` hold a manifest, the chart as
`accounts.csv`, the taxes and their postings as `taxes.json`, the boxes of the
periodic return as `tax_report.json`, an empty `statements.json` and an
`i18n/` folder. `packs/schema/pack.1.json` is the published JSON Schema for
all of them. `ekwo pack build` compiles a pack into a committed seed and
`ekwo pack check --all` — which the CI runs — refuses one that is stale. The
CLI gained no dependency: its validator walks the subset of JSON Schema the
format uses, because a binary handed a `service_role` key should not grow a
package tree.

Belgium and France carry over with no change of content, and the proof is a
test rather than a promise: the four hand-written seeds are kept in
`tests/fixtures/seeds-before-packs/`, loaded into one database while the
compiled pair is loaded into another, and every row of the five template
tables is compared — 353 and 392 accounts, 12 journals, 36 taxes, 128
postings, 2 country models.

Then migration `20260912074712`: `country_packs` (what this installation
holds, with a sha256 of the pack and the certification status `ekwo init`
prints), `company_packs` (what each company copied, backfilled at `1.0.0`),
`name_i18n` and `statement_hint` on `account_templates` and `accounts`,
`companies.language`, `country_defaults.language_default`, and
`install_country_template(company, country, language)` — which copies
`coalesce(name_i18n->>language, name)` into `accounts.name` and records the
version in `company_packs`. **The generated seeds upsert** on the template
tables and on nothing else, which closes the hole the analysis found: an
installed instance used to receive no pack change at all, not even for a
company created afterwards.

**Found on the way.** `alter default privileges … revoke execute on functions
from public` does not close a function created later — PostgreSQL merges the
stored default with the built-in one — so `20260911210131` did not keep the
promise it made, and `install_country_template` came out of its migration
executable by PUBLIC. Every migration that adds a function now ends with
`revoke execute on all functions in schema public from public;`, from PUBLIC
and never from `anon`, which holds explicit grants on the eight policy
helpers.

**Canada, before it arrives.** Two columns land now rather than with the pack
that needs them, because adding them later would mean migrating
`tax_postings` a second time, over years of postings:
`report_code` on `tax_posting_templates` and `tax_postings` — a box number is
unique inside one form, and a Canadian company files two returns at once,
where line 101 of the federal one is not line 101 of the Québec one — and
`region` on `companies` and `contacts`, because Canadian tax follows the
buyer's province and the core can only suggest a tax if it knows where the
parties are. Canadian **rates live in the pack**: fifteen or so stable
combinations published by the CRA are data, unlike the thousands of
American jurisdictions that change monthly and belong to a maintained feed.
What waits for the pack itself is the group tax (`tax_amount_type = group`
plus `tax_group_members`) and `entry_line_boxes`, the table that lets one base
line feed two forms; both are phase 1, and `report_code` and `region` are here
now so that migration happens once.

The header comment of `20260912080311` names `entry_lines` as a second table
`report_code` would have to be added to. It was never added there, and it is
not needed there: a ledger line carries `declaration_box`, and which form that
box belongs to is a fact about the posting it came from, which already holds
it. The comment is in a published migration, so it stays where it is and this
paragraph is the correction.

**Accepted, validated, not yet compiled**, because the tables they need do not
exist: `tax_report.json`, `statements.json`, the `documents`, `einvoicing`
and `bank` sections of the manifest, and the journal, tax and box labels of
`i18n/` (only account labels are compiled). The compiler names each one it
skipped, in its output and in the header of every seed it writes, so nothing
is quietly dropped. `tax_report.json` is written for both countries already —
the Belgian 71/72 and the French CA3 totals — so that the declaration boxes
have the data they need on the day that work starts. *(All of these have since
been compiled; the entries below say when.)*


## Ekwo maintains a pack; only an accountant reviews one (12 September 2026)

The certification scale shipped that morning with three values, and `ekwo`
meant "certified by Ekwo". That is a claim we cannot make: we write the pack,
a golden test proves it is internally coherent, and neither is an accountant
reading it against the law. The word *certified* should describe a review by a
named professional, or nothing.

So `pack_certification` gains **`maintained`** — maintained by Ekwo, not yet
reviewed by an accountant — which is what Belgium and France are. `reviewed`
keeps its meaning and now carries who read it and when. `ekwo` stays in the
enum, because a published column never loses a value, and is deprecated:
nothing writes it, the pack schema refuses it, and migration `20260912081015`
moves the rows that hold it, emptying `certified_by` along the way — it held
"Ekwo AI", which was the claim itself. Migrations `20260912081014` and
`20260912081015` are two files because PostgreSQL refuses a new enum value in
the transaction that added it.

One sentence describes a pack, written once in the CLI and printed by
`ekwo init`, by `ekwo status` and in the header of every generated seed:
"maintained by Ekwo — not yet reviewed by an accountant", "reviewed by X on
Y", "community pack — not reviewed". This supersedes the last line of the
paragraph above, which said Ekwo certifies Belgium and France.



## Declaration boxes are data (12 September 2026)

`vat_return()` summed whatever the tax postings wrote on the ledger lines —
which never knew a country — and then hard-coded the Belgian frame VI: boxes
71 and 72, the six boxes that make up what is due, the three that make up what
is deductible, and `c.fiscal_country = 'BE'`. It was the last country rule in
the core. A French company got no total at all, and a British one never would
have.

A form is now two tables filled by a pack. **`tax_report_templates`** is one
declaration form of one country; **`tax_report_box_templates`** is one box,
with `plus_boxes`, `minus_boxes` and `floor_zero` where it is a total. There
is deliberately **no expression language**: a list to add, a list to subtract,
a floor at zero, evaluated in the `sequence` the form declares. That covers
the Belgian 71/72, the French 16, 23, 25 and 28, and the British box 5, and an
accountant can read it. The day a country needs a real expression it is a
discussion about the core, not a field added to a pack.

Three things follow from the shape.

**A reference names a box and a kind.** `"54"` is enough on a Belgian form;
the French CA3 carries a base and a tax on line 08, so it writes `"08:base"`
and `"08:tax"`. `ekwo pack check` refuses a bare reference that would match
both, one that names a box the form does not carry, one that names the box
itself, and one that names a total computed later in the sequence — the totals
are evaluated once, in order, so a forward reference would silently read a
zero. It also refuses a tax that posts to a box the form does not declare.

**These tables are not copied into a company.** A chart of accounts is
customisable and a form is not: an operator does not get to redefine box 59.
They stay reference data that `vat_return()` reads directly, which is also why
they carry no `company_id`.

**A new version of a form is a new code**, with its own `valid_from` and
`valid_to`, the way a new VAT rate is a new tax code. The key is
`(country, code)`, and `vat_return()` takes the form in force at the end of
the period — so the return of a past period keeps giving the same answer. The
original sketch keyed the table on `(country, code, valid_from)`; one key and
one row per form version is the simpler half of the same guarantee.

`vat_return(company, from, to, report_code default null)` returns what it
always returned — `box`, `kind`, `amount`, `computed` — plus the `name` of the
box, its `sequence`, `hidden` and `report_code`. Hidden totals (the Belgian XX
and YY) are **returned and flagged** rather than dropped: a caller that wants
to check a total the form does not print can, and a renderer filters on one
column. A nil box is still left out, computed or not, exactly as before.
`report_code` picks the form where a country files several; without it, the
periodic return of the company's fiscal country in force on the last day of
the period, and an error rather than a guess if there are two. A company in a
country with no pack still gets its ledger boxes and no total.

The guard that keeps this true is three tests: no function in `public`, no
file under `supabase/migrations/`, and no source file of the CLI, the MCP
server or the core may hold a country code. They pass today, and they are what
makes "a country is data" checkable rather than aspirational. Making them pass
took five deletions beyond `vat_return()` — four backfills that named Belgium
and France in published migrations, and the `PCMN`/`PCG` labels and Belgian
default of `ekwo init`. The backfilled values are pack data that the compiled
seeds upsert, so nothing was lost by deleting them; `ekwo init` now builds its
question from `country_packs` and **preselects nothing**, because the one
question whose wrong answer is a chart of accounts has no right default, and a
system that ships with a country already chosen is not international.

Editing published migrations breaks rule 1 of
`supabase/migrations/README.md`. It was done once, knowingly, because no
installation anywhere had run those files, and because a country literal in a
published migration is a country literal in the repository whatever the file's
date says. The exception is written into that README beside the rule.


## Opening and closing are parameters, not code (12 September 2026)

The first release said the year-end close was "a real piece of work with
several national variants". The variants turned out to be one value.

**Three styles, named after the mechanism.** In Belgium, in France, in the
United Kingdom and in the United States a close does the same two things:
move the result out of the income statement, then zero every income and
expense account. What differs is the account the result travels through, and
that is now `country_defaults.closing_style`: `retained_earnings` closes
straight into retained earnings (United Kingdom, United States);
`result_accounts` closes into a current-year result account that sits on the
balance sheet and waits for the meeting that allocates it (France, 120 for a
profit and 129 for a loss); `appropriation_accounts` travels through an
account that is itself part of the income statement and lands on retained
earnings (Belgium, 693 to 140 and 793 to 141). The enum values name the
mechanism and never a country, because the third style is not "the Belgian
one" — it is what any chart does that ends its income statement on an
appropriation section.

**A profit account and a loss account, not one.** Belgium and France both
keep the two apart on the chart, and a single account would have to be
allowed to go debit, which is exactly what their filing formats refuse. So
the pack names `current_year_result_profit`, `current_year_result_loss`,
`retained_earnings` and `retained_earnings_loss`, and
`country_defaults.opening_journal_code` names the journal all of this is
booked on. Five columns, all read: none of them is there "in case".

**None of the five carries a default, and that is the whole point.** A
default `closing_style` is one country's mechanism handed to every country
that has not spoken, and `'OPN'` is the journal code Belgium and France happen
to use. A pack that says nothing gets a refusal naming the field it is
missing — `no_closing_defaults`, `no_opening_journal` — and never somebody
else's answer. `ekwo pack check` catches the same gaps before a seed is
written: a pack that declares a `closing_style` has to name the accounts that
style needs and a journal of type `opening`. The one fallback left is inside a
pack and not between countries: `retained_earnings_loss` left empty means the
chart keeps one account for both signs, which is the ordinary case outside
Belgium and France.

**The style is asserted, not trusted.** `appropriation_accounts` requires an
account that does *not* carry forward, the other two require one that does. A
pack that named an income account where the balance sheet is expected would
otherwise close a year into an account that is zeroed the same evening, and
the result would vanish quietly.

**The close writes no *à-nouveaux*, and that is the one place we depart from
what a Belgian or French package prints.** Every report in this schema reads
the ledger from the beginning — `trial_balance` computes the opening balance
of a period as the sum of everything booked before it — so a balance-sheet
account already stands on 1 January at the figure it carried on 31 December.
An opening entry on top of that does not carry a balance forward, it counts
it twice; the first version of this function did, and a test now forbids it.
What the opening journal carries is the *first* opening of a set of books,
which is `opening_balance`, and the year-end entries themselves. Reversing
this decision means changing the reports first — to a balance computed inside
one exercise — and the à-nouveaux entry after; doing it the other way round
doubles every carried balance on the day it ships.

One consequence to know: once a year is closed, its income statement read
from the *movements* of that year is zero, because the closing entry is one of
them. That is what a post-closing trial balance is, and it is true of every
system that closes the income statement at all. The financial statements read
a closed year by leaving out `entries.kind <> 'normal'`.

**`entries.kind` says what an entry is for, and is not writable by hand.**
`normal`, `opening`, `closing`. The first draft of this change identified a
closing entry by a heuristic — a journal of type `opening`, dated on the first
or the last day of a fiscal year — and a statement built on a heuristic goes
wrong the first time somebody books something by hand on that journal. The
column is set by `opening_balance()`, `close_fiscal_year()` and
`reopen_fiscal_year()` and by nothing else: a trigger refuses any other value
unless `ekwo.year_end_entry` is set, which only those three do, and only while
they write. The reason is the one behind `is_closed`: a label any client may
set is a label a report cannot be built on, and an ordinary purchase invoice
quietly marked `closing` would leave an income statement without anything
looking wrong. A reversal carries the kind of what it undoes, so a closing
entry and its reversal leave a report together.

**The allocation decided by a meeting is never in the close.** A dividend, the
legal reserve, a French 120 moved to 110 or to 106 — all of it is a later
entry taken by people. A close that guessed at it would be writing a decision
nobody made, and it would be wrong for most companies most years.

**`is_closed` stops being an ordinary column.** It decides whether a whole
period accepts entries, and until now any client that could write a fiscal
year could flip it, which is the same as having no lock. A trigger refuses the
*transition*: an update that changes `is_closed` or `closed_at` raises unless
`ekwo.closing_fiscal_year` is set, and only `close_fiscal_year()` and
`reopen_fiscal_year()` set it — transaction-locally, so it is gone when they
return. Creating a year that is *already* closed stays allowed, because that
is a different act: it describes a year that happened in whatever kept the
books before, it computes nothing and it writes no entry. That is how a
company arrives with three closed years, one open one, and an opening balance
that carries their result.

**An opening balance refuses the income statement.** `opening_balance` takes a
trial balance as rows — `{account_code, debit, credit, contact_id, label}` —
because that is what every previous system exports, and it refuses an income
or expense account unless the caller passes `p_allow_result_accounts`. A year
that starts with a profit already on it is the commonest way an import goes
wrong. The flag exists for the one case where it is right: taking the books
over in the middle of a year that has already run.

**A close is undone by reversing, never by deleting.** `reopen_fiscal_year`
reverses the entries the close wrote and clears the flag, and refuses the
moment a later year is closed or holds entries of its own — re-opening changes
a result those years stand on. It is the same rule as everywhere else here:
there is no unpost.

**For an accountant to read.** Three things in this are our reading of the
mechanics rather than a rule we can cite. The closing entry is dated on the
last day of the year, which is the convention everywhere but is not written
anywhere. Belgium goes through 693 and 793 rather than straight to 140 and
141, which is what the minimum chart's appropriation section is for, but a
firm that books it directly is not doing anything unusual. And the
appropriation entry is posted as a separate entry *before* the closing entry,
so that a statutory income statement can show a movement on 693: merged into
one entry the two movements cancel and the line disappears.

## One tax engine, several kinds of tax (12 September 2026)

The core knew one tax: European VAT, fully deductible, computed on a price
that excludes it, rounded to the cent. The pack format already had words for
everything else — `kind`, `recoverable`, `price_include`, `jurisdiction`,
`cash_basis`, `rounding_method`, `cash_rounding_unit` were in
`packs/schema/pack.1.json` marked *deferred*, and the compiler dropped them on
the floor. This step gives each of them a column, and adds the one behaviour
that could not be written as a flag.

**A kind is a label, never an input to the calculation.** `tax_kind` is
`vat | gst | sales_tax | withholding | other` and drives reports only: a GST is
computed exactly like a VAT, and a report that lists "the VAT" of a Canadian
company needs to know which of two taxes it is looking at. Deriving that from
a tax code is how a localisation ends up in application code. Same for
`recoverable` and `jurisdiction`: they say what a tax *is*, so nothing has to
guess.

**Non-deductible VAT is a cost, and a cost has an account — the line's.**
`tax_posting_type` gains `tax_on_base`. Like `base` it carries no account,
because the account is the one the document line names; unlike `base`, its
amount is a share of the tax. A Belgian company car at 21 % with the deduction
capped at 50 % by art. 45 § 2 CTVA books 1 000 on the vehicle, 105 on the
deductible VAT account, 105 more on the vehicle, and 1 210 to the supplier.
Belgium's grid 83 comes out at 1 105: the form says « montant (TVA déductible
non comprise) », which excludes the *deductible* VAT and not all of it, and
the Intervat notice spells it out. That needed no new column —
`box_factor_percent` has always been independent from `factor_percent`, so the
base posting reports 100 % of the base in box 83 and the `tax_on_base` posting
reports 50 % of the tax in the same box. France needs none of this: the CA3
has no grid for the base of a purchase at all, so the French fuel tax is
ledger-only on its non-deductible fifth.

**A `tax_on_base` line is not a tax line.** It sits on a base account and
belongs to the base side of the declaration, which is exactly why Belgium puts
it in 82/83. Marking it `tax_line = true` would split one grid into two rows in
`vat_return()` and would send every reader that filters on `tax_line` looking
for it among the VAT accounts, where it is not.

**The postings of one side share out the tax of the group; the last takes the
remainder.** Until now no tax had more than one posting per side, so each one
could round on its own. Two halves cannot: 3,00 € at 21 % is 0,63, and
rounding 0,315 twice books 0,64 against a document that totals 3,63. The tax
of the group is still rounded once (BR-CO-14, unchanged) and is then shared
out — 0,32 and 0,31. Every tax that existed before comes out to the same cent,
and `posting.test.ts` was not touched, which is the proof. The same rule runs
one level down when a `tax_on_base` share is spread over the several accounts
of an invoice, in proportion to their bases.

**A declaration figure is not a ledger figure.** Box amounts keep rounding per
posting, so on that 3,00 € invoice the ledger books 0,31 where box 82 reports
0,32. Only the ledger has to balance, `box_factor_percent` was separate from
`factor_percent` by design, and the alternative is to let a grid drive a
posting.

**No country is anybody's default.** A pack says how its country rounds; a
pack that says nothing gets the column's own default, and the compiler writes
`default` rather than a value of its own — otherwise the CLI becomes a second
place where a country model is decided, and the first country that rounds
differently finds out by reading TypeScript. `half_up`, `recoverable = true`
and `tax_kind = 'vat'` are the neutral mechanism, not Belgium and not France.
The repo-wide guard catches a country *literal*; `tax_on_base.test.ts` adds
the subtler one, a country's *answer* used as a fallback.

**`cash_basis`, `rounding_method` and `cash_rounding_unit` land without a
reader.** VAT on collection comes later; `half_up` is what `round()` on a
numeric already does in every country, so the default changes nothing; the
Swiss five-centime unit waits for Switzerland. The alternative was migrating a
table of tax rows and their postings a second time, which is the argument
`20260912080311` made for `report_code`. Three columns is where this stops.

**Both packs move to 1.1.0** — and have moved on since: Belgium and France are
both at **1.4.0** as this is written, `generic` at 1.1.0. Belgium gains the
vehicle taxes at 50 % and a
wholly non-deductible one for frais de réception (art. 45 § 3 CTVA); France
gains fuel at 20 % with the 80 % deduction of CGI art. 298, 4, 1°. Adding a
tax is a minor version, and `ekwo pack upgrade` will diff on that number when
it is built, so a pack that grows without saying so is a pack nobody can
upgrade to. The before/after test the pack format shipped with still
proves that **nothing that existed changed**: `after`
is narrowed to the natural keys `before` held, and the four new codes are
named in a test of their own, so a row that appears without anyone saying so
still fails.


## A country has charts, and a financial statement is data (12 September 2026)

Two changes in one sub-task, in that order, because the second depends on the
first: a statement presents a chart, so which chart has to exist before what
presents it.

**`account_templates` was keyed on `(country, code)`, and a country has more
than one chart of accounts.** A Belgian ASBL keeps its books on the PCMN as
the associations title of the Code des sociétés et des associations applies
it; a French association on ANC 2018-06; Germany ships SKR03 and SKR04. So a
chart becomes a dimension: `chart_templates` lists what a country offers,
`account_templates.chart_code` says which one an account belongs to — the key
is now `(country, chart_code, code)` — and `company_packs.chart_code` records
which one a company copied. Every published row is backfilled to `default`,
which is a mechanism word and not a chart name: the pack says the chart is
called PCMN or PCG, in its own data.

**The journals, the taxes and the declaration form stay common to the charts
of a country.** An association buys, sells and banks through the same journals
as a company and files the same VAT return; only the accounts differ, and what
presents them. The roles — which account is receivable, payable, suspense —
stay on `country_defaults` for the same reason, and `ekwo pack check` refuses
a pack whose role codes and tax posting accounts are not in *every* chart it
ships. That check is what lets one set of taxes install on any chart, and it
fails where it can be read, in the pack, rather than at install time.

**`ekwo init --chart`, and a question only when there is something to choose.**
A country with one chart is not a question. A country with two is asked about,
with nothing preselected beyond the default the pack itself declares, and
non-interactively the flag is required and the refusal lists the charts. Same
rule as the country question: the one whose wrong answer is a plan of accounts
has no right default.

**A financial statement is three tables and one function.**
`statement_templates` is one scheme, `statement_line_templates` its lines with
the plus/minus lists a total is computed from, `statement_line_rules` how
accounts reach a line — by code range, code prefix, account type or one code.
`financial_statement(company, code, from, to)` returns the whole frame, nil
lines included, in the order the scheme prints it. A balance sheet reads
balances cumulative to the end of the period, an income statement the
movements inside it, which is the one difference `kind` decides.

**Mapping by code range is presentation, and presentation is allowed.** The
rule that forbids choosing an account *to post to* by prefix is about posting.
The NBB scheme, the liasse and every XBRL taxonomy map by ranges of the legal
chart — in Belgium the rubric code *is* the range, `40/41` being accounts 40
and 41 — and refusing that would mean hand-listing four hundred codes per
country. A range compares the head of the code, so `40`..`41` takes 400000 and
411000 and stops at 42.

**`balance_side` is what splits one account between two lines.** A suspense
account is a receivable while it is in debit and a payable while it is in
credit; French VAT lives in the 445 family on both sides of the balance sheet.
Two lines may share an account only when their sides exclude each other, and
`ekwo pack check` refuses any other overlap.

**The check that makes a statement tie out is in the pack, not in the
runtime.** Every account of a chart that can be posted to reaches a line of
some statement of that chart — a heading, an account with children, may reach
none, because it straddles the lines its children are split over. At runtime
`unmapped_accounts()` answers the same question for a company, which catches
the account somebody opened outside the pack, and the MCP tool returns that
list beside the statement so a model cannot present a balance sheet that does
not balance.

**One evaluator, called twice.** A declaration form and a financial statement
derive their totals the same way, so they derive them in one function:
`evaluate_totals(values, formulas, keep_zero)`, which `vat_return()` and
`financial_statement()` both call. The first draft of this sub-task wrote the
evaluation a second time and argued that the two differed — a return omits a
box that comes to nothing, a statement prints its whole frame. They are one
argument (`p_keep_zero`) and, for the sign a scheme reads a line with, a
second (`factor`). Two implementations of one calculation is the thing this
repository is built against, and the cost of undoing it — replacing a function
published the same morning, in a file of its own because it was published —
was an hour.

**The totals are evaluated in the order they depend on each other**, not the
order they are printed in: a balance sheet prints `ACTIFS IMMOBILISÉS` above
the three lines it adds up, and one of those three is itself a total. Each
pass takes every total whose parts are known; a reference that names no
formula is a value, present or nil, so a total over ledger boxes is ready on
the first pass; a pass that settles nothing is a cycle and names the totals in
it. `vat_return()` gains that: it used to evaluate strictly in the order the
form declares, where a forward reference read a silent zero — which
`ekwo pack check` refuses anyway, so no pack changes answer.

**A closing entry is not what a period earned.** `close_fiscal_year()` books
the mirror image of every income and expense account so the next year starts
at nil, and marks the entry `kind = 'closing'`. An income statement leaves
those out — a closed year would otherwise read as a result of zero — and a
balance sheet keeps them, because that entry is what carries the result onto
the line the balance sheet shows it on.

**And an appropriation entry is not a closing entry.** Where a country
appropriates through accounts of its own income statement — Belgium, 693 for a
profit and 793 for a loss — `close_fiscal_year()` writes two entries: one that
moves the result into those accounts and on to retained earnings, one that
takes every income and expense account back to zero, that pair included. Both
were marked `closing`, so they cancelled each other out and the "Affectations
et prélèvements" section of the Belgian annual accounts read nil the moment a
year was closed. They are two acts and they now have two names:
`entries.kind` gains `appropriation`, an allocation section reads it and
leaves the closing entry out, an income statement leaves out both, and a
balance sheet keeps both because together they are what puts the result on the
line it shows. `reopen_fiscal_year()` undoes both, and a reversal keeps the
kind of what it undoes. The guard on the column needed nothing: it already
admits any value under the session flag the three year-end functions set, and
refuses everything but `normal` outside it.

**The generic balance sheet derives the result; the legal ones do not.** The
NBB frame and the liasse are filed after the year is closed, so they show the
result on the line the close put it on — rubric 14 in Belgium, `DI` in France
— and show nothing while the year is open. The generic scheme has a line that
sums the income and expense types instead, so it balances on its own whether
or not the year is closed, and reads nil once the close has moved the
movements away. A management balance sheet and a filing frame are not the same
document, and this is where they part.

**The generic framework is a pack with no country.** `packs/generic/` compiles
like any other pack into `supabase/seed/05_framework_generic.sql`, and its
rules are all `account_type` — a reader refuses any other kind in it. That is
what the eighteen account types buy: a readable balance sheet on any chart,
including the code-less charts of the United Kingdom and the United States,
and the fallback for a chart that declares no scheme of its own. The Belgian
association chart ships exactly that way.

**What the packs gained.** Belgium: the NBB abbreviated balance sheet, income
statement and allocation section, from the 2021 standard model — and the micro
model is the same three schemes, so one set serves both. France: the 2050/2051
balance sheet and the 2052/2053 income statement of the 2026 liasse. Both were
read off the published forms rather than off the tables that circulate, which
matters more than it sounds: `20/28`, `70/74`, `60/64` and `9902` are
pre-2016 Belgian codes that no longer exist, and the French `CS`/`CU` pair
swapped meaning in the 2026 millésime — participations moved from `CU` to
`CS`, and the public mappings have not followed.

**`xbrl_element` holds a fact key, not an element name.** The premise that the
NBB CBSO taxonomy has one element per rubric is false: it is dimensional, with
fifteen generic metrics, and a rubric is a metric plus a set of dimension
members. So the column carries `met:am1|bas:m9|rst:m2`, verified against
taxonomy 26.0.15, and null on the lines where nothing could be verified.
`@ekwo-ai/xbrl-cbso` reads it — and that library targets framework 25.0 and
has two rubrics swapped, which is its own fix.


## What a country requires on a document is data (12 September 2026)

An invoice is where a country speaks loudest, and the core answered for it.
The number was built as `CODE/YYYY/NNNN` in a function; the legal payment
term existed nowhere; the e-invoicing profile and the bank formats existed
nowhere; and the legal mentions existed nowhere at all, so a renderer either
printed "Autoliquidation" from its own source or printed nothing. Twelve
columns of `country_defaults`, one table of sentences, and two views move all
of it into the pack.

**Nothing executable, and that is the sub-task.** This change adds no
function. Two views read the data — one enriched, one new — so a renderer or
the e-invoice brick has something to select, and a test asserts that no
function body mentions any of the new columns.

**`numbering_gapless` and `number_format` are two questions, not one.**
Whether a number may skip is the law: most of Europe forbids a hole, some
countries only ask for an order. What the number *looks like* is a pattern —
`{CODE}`, `{YYYY}` or `{YY}`, `{MM}`, and a run of `N` for a counter padded to
its own width. Whether the counter restarts each year is readable in the
pattern itself, because a pattern that carries the year restarts with it,
which is why the four numbering styles of the pack format compile to one
boolean without losing anything. **`next_entry_number()` does not read the
pattern**, and this change does not make it: a numbering engine that consumes
a format is its own piece of work, and both packs declare exactly the pattern
the engine already produces, so nothing moves under anybody's feet the day it
lands.

**`tax_point_rule` is the country's general rule, and the exception is on the
tax.** France taxes goods on delivery and services on collection. A second
country column for the second half would be a country model that contradicts
itself; the service rule is `taxes.cash_basis`, which the tax engine landed and
cash-basis VAT gives behaviour to. So France declares `delivery_date` and its service taxes
will say the rest themselves.

*Amended 16 September 2026.* The decision holds — a rule that varies by tax is
still a property of the tax — but the vocabulary was one word short of saying a
rule that varies by *nothing*. Most of Europe puts the fait générateur at the
supply and derogates to the invoice, which is one rule and not two, and three
packs had declared the derogation alone. `invoice_if_issued` and
`earliest_of_delivery_or_payment` join the three original values, and
`tax_point_of()` becomes the column's only reader — `post_document()` dates a
tax by them and `vat_return()` files it by them, so the word is no longer a
comment. `docs/international.md` has the texts and what each one actually
says.

**`party_scheme` and `vat_scheme` are both there because they are not the same
identifier.** A company is addressed on the network by its registration
number — ISO 6523 `0208` in Belgium, `0009` in France — and taxed on its VAT
number, `9925` and `9957`. Four digits, checked by the schema: the Belgian
pack used to carry `BE:VAT`, which is a string nobody can look up in a
register. Where a country has two registration identifiers, the pack declares
the one its invoices carry and names the other in the legal reference: France
declares SIRET and says in the same breath that SIREN is the same company
without its establishment.

**`applies_when` is a closed vocabulary of nine values, never an expression.**
The same decision as the plus and minus lists of a declaration total, for the
same reason: an accountant reads `reverse_charge` and knows what it means, and
a pack that could write a condition would be a pack that executes. Six of the
nine are resolved from the treatment of the taxes a document's lines already
carry, so nothing new has to be recorded on a document for its mentions to
come out right. `late_payment` is about the direction — interest and recovery
costs belong on what a seller issues, never on an invoice somebody else
wrote. `cash_basis` is about the tax. The day a country needs a tenth value it
is a discussion about the core, not a field a pack may fill with anything.

**`small_business` is data the view never selects, and says so.** A franchise
regime is a property of the seller, and the core records no such column. The
sentence is in the table so a renderer that knows the regime can fetch it by
code, and `document_legal_mentions` does not pretend to know: it has no branch
for it, a test asserts that the view returns it for no document anywhere, and
the day a regime becomes a column the view gains one line. The alternative was
to invent a flag on `companies` in a sub-task about country data, or to drop a
sentence that two countries genuinely require.

**The mentions are not copied into a company**, for the reason a declaration
form is not: a chart of accounts is customisable and the law is not. An
operator does not get to rewrite article 39bis. A wording that changes is a
`valid_to` and a new row, and the view joins on the **document's own date**, so
a reprint of an old invoice carries the wording of its own year.

**The country of a document is the company's `fiscal_country`**, not its
address. A Belgian company with a French VAT registration invoices under
French rules, and that distinction was already in the schema; the view uses it
rather than adding a second answer.

**The generated seed writes these columns with an `update`, not a second
insert.** The row is created a few lines above by the same file, and an insert
would have to restate the name, the currency and the two account roles its
not-null columns need — the same values twice in one generated file. The
update touches only the columns this section owns, which also keeps the two
blocks of the compiler independent of each other.

**What a pack may declare and what it may not.** The closed vocabularies live
in `packs/schema/pack.1.json`, so an editor sees them and `ekwo pack check`
enforces them before a seed is written: the nine conditions, the three tax
points, the four fiscal year openings, the bank formats by name, four digits
for an ISO 6523 scheme, a date for the obligation. Four things the schema
cannot say are checked in the reader — a duplicate mention code, a validity
that runs backwards, a mention with no legal reference, and a number format
with an unknown token or without a counter — plus one that is a half-declared
pack: a day an obligation starts with no profile saying what becomes
obligatory.

**For an accountant to read.** Belgium declares a thirty-day legal term (loi
du 2 août 2002, art. 4), interest at the ECB rate plus eight points with the
40 € indemnity (art. 5 and 6), the tax point at the issue of the invoice
(art. 17 of the VAT code), Peppol BIS 3 mandatory between taxable persons from
1 January 2026, CODA and camt.053 statements, pain.001 payments, and six
mentions (AR n° 1 art. 20, art. 39bis, art. 21 § 2, art. 39, art. 56bis, and
the late payment terms). France declares thirty days (art. L441-10), the same
40 € indemnity (art. D441-5), the tax point on delivery with the service
exception on the tax, Factur-X from 1 September 2026 for reception, SIRET and
the French VAT scheme, camt.053 and CFONB 120 statements, pain.001 and
CFONB 160 payments, and six mentions (art. 283, 262 ter I, 283-2, 262 I,
293 B, and the late payment terms). **Three things are deliberately absent.**
The French *escompte* mention is one: article L441-9 requires the invoice to
state the discount conditions, and "néant" is a seller's commercial choice
that a country pack has no business asserting. The emission calendar of the
French reform is the second: it depends on the size of the company, which the
core does not hold, so the date in the column is reception — the one that
binds everybody at once — and the calendar is in the legal reference. The
third is an `exempt` mention for either country: both packs carry an
exemption tax, neither law prescribes one sentence for it, and a sentence we
would have written ourselves is not data.
## VAT when the cash moves, and the exchange difference when it settles (12 September 2026)

Two rules a country decides that the core had no way of applying, and they
meet in one place: the moment a document is settled.

**The French pack was wrong for every service business, and it is the reason
this sub-task exists.** French VAT on a supply of services falls due when the
price is collected, not when the invoice is issued (CGI art. 269-2-c); goods
fall due on delivery. A pack that offers one sale tax per rate offers the
goods answer to everybody, and a service company filing on it declares its VAT
one to three months early, every month. The columns to say otherwise landed
with the tax engine — `cash_basis` and `cash_basis_transition_account_id` —
and nothing read them. Now something does.

**A tax that waits is booked on an account that says so, and on no box.**
`post_document` puts the tax of a cash-basis tax on the transition account the
pack names and writes no declaration box, because nothing is due. The matching
moves the settled share to the account and the box it is finally declared on,
dated on the day the settlement completes, as an entry of its own.
`vat_return()` needed no change at all, which is the proof that the boxes are
the only thing that moved: it sums lines that name a box, and until the
transfer there is no such line.

**The base travels with its tax.** A cash-basis return reports the base
*collected* — line 08 of the CA3 carries a base column and a tax column, and
they have to be the same operation. So the base line of a cash-basis document
also waits, and the transfer carries it: a line with a box, an amount to
report and no debit and no credit. That is not a trick, it is the distinction
this schema has made since the tax engine — a declaration figure is not a
ledger figure — used for what it is worth. Revenue is still earned when it is
invoiced; only the declaration waits. Cash accounting as a *ledger* stays out
of scope, and a cash-basis report stays derived from matched payments.

**The share is cumulative, and the last payment carries the remainder.**
`settle_cash_basis_tax()` works out what *should* have been transferred at the
current settlement ratio, subtracts what earlier matchings already sent on,
and books the difference. Nothing is stored about the history: the ledger is
the history. A tax of 200,00 settled in three parts of 400,00 out of 1 200,00
comes to 66,67 then 66,66 then 66,67, because each step rounds the whole and
not the step. And because the function only ever books a difference, it is the
same call when a matching is *undone*: the share falls, the difference is
negative, and the mirror entry is posted. `unreconcile` needed one line.

**A cash-basis tax takes one tax posting per document kind.** The transition
lines of a document have to be told apart when the matching sends each of them
on, and two postings on one transition account cannot be. It is not a
limitation in practice: a tax whose postings net out is self-assessed, and a
self-assessed tax has no cash to wait for. `post_document` refuses it by name
and `ekwo pack check` refuses it before a seed is written — as it does a
cash-basis tax that names no transition account, and one that also carries a
non-deductible share, because a cost is not deferred to a payment.

**The French pack gains six taxes and two accounts, and changes none.**
`FR-S-20-ENC`, `FR-S-10-ENC`, `FR-S-055-ENC` for services sold and
`FR-P-20-ENC`, `FR-P-10-ENC`, `FR-P-055-ENC` for services bought — the
purchase side because the right to deduct arises when the tax falls due at the
supplier (CGI art. 271-I-2), which for a service is the payment. The accounts
they wait on are `445870` and `445860`, under the 4458 head the PCG calls
*taxes sur le chiffre d'affaires à régulariser ou en attente*. **The option
for the debits is the tax that was already there**: a services company that has
opted for the debits invoices on `FR-S-20`, unchanged, and declaring a second
identical tax to mean "the same thing without the option" would be two rows
for one calculation. Belgium gains nothing here: the Belgian regime has no
general cash-basis option in the socle, and inventing one would be a country
rule written by us.

**The ledger did not convert, and now it does.** A document in a foreign
currency booked its foreign figures into `debit` and `credit` as if they were
the company's own, and `entry_lines.amount_currency` — which the FEC exports —
was written by nothing. Without that, an exchange difference cannot exist,
because both sides are already equal. So `post_document` and `post_payment`
book the company's currency in the ledger and the document's beside it, at the
rate carried by `documents.exchange_rate` and by the new
`payments.exchange_rate`: units of the foreign currency for one of the
company's, which is how `currency_rates` has always stated one. There is no
rate feed and there will not be one here; the rate is an input.

**Every amount is worked out in the document's currency and divided once.**
The share-out of a tax between postings, the rounding of the group, the split
of a non-deductible share over the accounts of the lines: all unchanged, in
the document's currency, and each result divided by the rate as it is written.
At a rate of 1 the division is the identity, which is why `posting.test.ts`
was not touched and is green. The counterpart still balances by construction,
and it balances in both currencies; the total it is checked against is the one
`documents.amount_total` is stated in, which is the document's.

**A matching between two lines in the same foreign currency is worked out in
that currency.** That is where they are equal: 1 000,00 USD settles 1 000,00
USD, whatever each side was booked at. Each side turns it back into the
company's currency at its own rate, the two figures differ, and the difference
is realised — booked on `fx_gain_code` / `fx_loss_code` of the country model,
against the third-party account, so that account goes to nil and the customer
who has paid in full owes nothing. `p_amount` is read in the shared currency in
that case, and in the company's in every other, which is every matching made
before this change. A missing role is a refusal *the day a difference arises*
and not a day earlier: a pack that never meets a foreign currency never has to
name an account it does not use.

**The transfer and the difference go on the miscellaneous journal, not the
bank.** A bank journal has to tie to a bank statement, and neither of these is
a movement of money. They are dated on the day the settlement completes — the
later of the two entries matched — and `post_entry` asserts the period is open,
including the tax lock, so a matching that would move a declared figure is
refused rather than booked quietly.

**What a matching caused is part of what it returns.** `reconciliations` gains
`fx_entry_id` and `tax_transfer_entry_id`, the MCP server exposes both, and
`unreconcile` uses the first to take the difference back: its companion
matching is deleted and a mirror entry cancels it on its own date.

**Out of scope, said plainly.** Revaluation of open items at a closing date —
the difference that is *not* realised — is not here; `755`/`655` in Belgium and
`476`/`477` in France are the accounts it would need, and it is a question for
audited accounts rather than for a first invoice. Neither is a gross-to-net
computation for a tax-inclusive price, which waits for the country that sells
that way.


## Format libraries live in this repository, under MIT, one package per format (12 September 2026)

A country is data; a file format is code, and a format is not a country: Factur-X
is French and German, UBL is universal, camt.053 is European. So the export bricks
are organised by format under `packages/formats/`, never by country — the pack says
which formats a country uses, in `einvoice_profile` and the bank format lists.
They join this repository for the reason `ee/` did: a taxonomy change is one pull
request, not a two-repository coordination, and the golden test that proves the
pack and the brick agree can only run where both are. Each package keeps its own
MIT `LICENSE`, imports nothing from the core, and declares the row shapes it reads
in its own types; a test enforces all three. The truth of a mapping stays in the
pack; the brick carries only the official taxonomy, generated from the published
package, and `ekwo pack check` resolves every key against it — for the NBB schemes
a key has to resolve to the very line code that carries it. A brick declares no
`schema_min`: the contract is the shape of the rows, and the end-to-end test is
what breaks when it moves. `@ekwo-ai/xbrl-cbso` and `@ekwo-ai/factur-x` come in by
subtree; the FEC leaves `@ekwo-ai/core` for `@ekwo-ai/fec` — `packages/core`
still re-exports it from `src/fec.ts`, marked `@deprecated` and unchanged, so
that `@ekwo-ai/core` and `@ekwo-ai/core/fec` keep working for one version;
the re-export goes in the next. Should the core still
be private when the phase 1 formats begin, `packages/formats/` splits out as one
public repository with the same structure.


## Modules — one schema each, and the ledger only through a function (13 September 2026)

The socle is an accounting core, and fixed assets, budgets, a carbon ledger or
a crypto register are not it. Each of them is a set of tables, a calculation
and a report that a company either wants or does not — and every one of them
ends the same way, with an entry. The question this answers is where they live
and what they are allowed to touch.

**One Postgres schema per module, and the socle stays in `public`.** `assets`,
`budgets`, `carbon`. The alternative was a prefix on the socle's own tables —
`asset_*`, `budget_*` — which is what most products do and what makes a schema
nobody can read after the fourth module. A schema is also what makes the rest
of this possible: one line of PostgREST configuration turns a module on for the
API, one `revoke` closes it, `docs/schema.md` has a section per module, and a
module that is not installed is not an empty table, it is nothing at all.

**The registry is a table, not a plugin system.** `public.modules` holds one row
per module this installation carries, written by the last statement of the
module's own first migration; `company_modules` says which company has enabled
which. There is deliberately no registry in TypeScript: a module that is
installed is a schema that exists and a row that says so, and one query answers
"what is here" for the CLI, the MCP server and a human. A plugin registry in
code would have been a second place to keep in step with the database, and the
first release where they disagreed would be a module that half exists.

**A module never writes the ledger by hand: `post_module_entry()` does.** This
is the whole architecture. The sub-task as written asked for a *privilege* —
revoke insert on `entries` from the module schema — and Postgres has no such
thing: privileges belong to roles, not to schemas, and a module's functions run
as the signed-in user, who legitimately writes the ledger through
`post_document`. So the rule was made structural instead. A module hands over a
company, a date, a tag and its lines as data, and the socle builds the draft and
calls `post_entry()` — exactly what `post_document`, `post_payment` and
`close_fiscal_year` already do. The words `entries` and `entry_lines` therefore
do not appear in a write statement anywhere under `modules/`, and a test over
every file proves it. That is a stronger guarantee than the revoke would have
been, and it is checkable.

**The tag is what makes a module idempotent, and the database enforces it.**
`entries.module_code` and `entries.module_ref`, with a unique index on
`(company_id, module_code, module_ref)`. `assets.run_depreciation` cannot book
the same period twice because the second insert fails, not because the function
remembered to look. Every package that guards a posting with a flag it checks
first has the same hole: a stale screen, a double click or two clients at once,
and the entry is there twice with nothing looking wrong. Tagging by
`(module_code, ref)` is also why `entry_kind` gains no value per module: a
depreciation entry is an ordinary entry that a report may leave in, and a
fifteenth enum value per module would be a report that has to know every module
before it can filter.

**A module is enabled per company, and the table has no write policy.**
`enable_module()` and `disable_module()` are definer functions with the owner
check written inside, for the reason `register_instance()` is: a guard that
lives in the function applies to psql and to PostgREST alike, and a guard that
lives in a policy applies to whoever respects it. `module_enabled(company,
code)` — the module being on *and* the caller being a member — is the one call
every module policy makes, which is why it joins the eight helpers `anon` may
execute: what it gives away to a stranger is the word `is_company_member`
already gives them.

**Disabling asks the module, by convention and not by column.**
`disable_module()` looks for `<schema>.can_disable(uuid)` and runs it if it
exists: null allows, a sentence refuses and is quoted in the error. A column on
`modules` naming the function would have been one more thing to keep in step
with the code; the absence of the function is itself meaningful, and `budgets`
is the module that exercises it — turning it off takes nothing away, because
row level security hides the rows and enabling it again gives them back.
Nothing a module wrote is ever deleted by a disable.

**A country is data inside a module too, and the accounts are roles of the
chart.** `packs/<cc>/assets.json` says how a country prorates a first period,
whether its declining balance is capped and how it derecognises an asset;
`ekwo pack build` compiles it into `supabase/seed/modules/assets/`, applied by
the module migration runner and by nothing else, because those tables do not
exist on an installation without the module. The accounts, though, went into
`country_defaults` and `defaults.roles` rather than into a table of the
module's own: a role is the answer to "which account of this chart plays this
part", there is one place a pack answers that, and putting the fourth answer
somewhere else would mean `ekwo pack check` — which already refuses a role code
missing from any chart the pack ships — was not checking it.

**A disposal is two mechanisms, and the enum names them and not the
countries.** Belgium clears the asset and puts the difference on one account,
763 or 663; France books the net book value as a charge on 675 and the proceeds
as an income on 775, both in full, and the income statement prints the two.
Neither is a variant of the other, so `assets.country_rules.disposal_style` is
`net_result` or `gross`, named after the mechanism — the same decision
`closing_style` made, for the same reason. Four nullable role columns follow,
two per style, none with a default: a pack that has said nothing gets a refusal
naming the role it is missing.

**Migrations of a module share the socle's history, and sort after it.**
`supabase_migrations.schema_migrations`, the plain timestamp as `version`, the
module in the `name` — `assets/assets`. Anything else forks the history that
makes `ekwo migrate` and `supabase db push` interchangeable, which is the whole
point of having written it Supabase's way. The consequence is a rule and a
test: a module's timestamps come after every socle migration, and no two
migrations anywhere share a version. `ekwo migrate` applies the modules by
default — a schema whose migrations are half applied is the state nobody can
reason about, and an empty table under row level security is not a feature
anybody has been given — and `--no-modules` is what to pass before running
`supabase db push`, which knows the socle's files and not a module's.

**The one thing no migration can do is expose the schema.** PostgREST serves
what the project lists under its exposed schemas, which is a setting of the API.
So `ekwo module enable` prints the line to add, every time, and the MCP server
turns the profile error PostgREST answers with into the same sentence rather
than into something that reads like a bug in the server.

**What `assets` deliberately does not do.** It refuses a schedule by output
(`units_of_production` is in the enum and raises by name, the way
`post_document` refuses a fixed-amount tax), it refuses to rewrite a schedule
whose lines are already booked, and it refuses a disposal while a period that
has already ended is unbooked. Each of those is a place where guessing would
have produced a register that no longer ties to the ledger, which is the one
thing a fixed asset register is for.

**Three conventions here are our reading of the mechanics.** A prorata in days
counts the day of entry into service — 184/365 for a Belgian asset in service on
1 July, 256/360 for a French one on 15 April — which is the convention that
makes a full year come to exactly one, and not the only one in use. A declining
balance measures what is left to run in periods and not in months. And Belgium
prorates the first annuity for every company, because article 196, § 2, 1° CIR
92 obliges it for companies that are not small ones and the core holds no
"small company" column; a small company that takes the whole first annuity sets
`prorata = 'none'` on the asset. All three are in `modules/assets/README.md`
under a heading that says an accountant should read them.

## A company has a face, members have capabilities, machines have keys (13 September 2026)

Everything an accounting product has that the core did not: a company profile
an invoice can be printed from, invitations, user preferences, fine
permissions, a numbering engine that reads the pack, machine keys, and a first
financial year that is not January by assumption. Seven changes, one theme — the core knew how to
keep books and did not know who was keeping them.

**A role becomes a preset, and a capability becomes what a policy tests.**
`company_members.role` had three values and every policy in the schema read
one of them, through `is_company_member`, `can_write_company` and
`is_company_owner`. That is a permission model with three positions: a
bookkeeper who may post invoices and must never move a period lock has no row
to sit on, and the answer in every product that meets the case is a fourth
role, then a fifth. So `capabilities` is a table of twenty codes — twenty-one
since `entries.import` (`20260913092527`), and five more once the `assets` and
`budgets` modules add their own —
`role_capabilities` says what each preset holds, and
`company_members.capabilities_granted` / `capabilities_revoked` adjust one
member in both directions. A revoke wins over a grant and over a preset —
including on an owner, because a company that wants its owner unable to close
a year is describing its own separation of duties, not making a mistake. Every
policy **of the socle** now calls `has_capability()` — a module's policies
went on asking `can_write_company()` until 13 September 2026, when each module
took its own codes — and `can_write_company()` is rewritten on
top of it rather than left beside it: it is the answer to `entries.write` and
nothing else. **The three roles do exactly what they did the day before**, and
that is the half of it a test would notice.

**No fourth role, and two capabilities that were not written.** `admin` was
considered and left out: the existing helpers drew one line — write the books,
or administer the company — and `owner` is already the second half of it, so a
role between them would have been a name with no work to do. Somebody who
needs exactly that is an accountant with `members.manage` granted. And
`reports.read` and `exports.run` are absent on purpose: `trial_balance()` and
the statements sum ledger lines that row level security has already filtered,
so a member without `entries.read` gets an empty report today. A second lock
on the same door is a lock nobody turns, and a capability nothing can refuse
on is the thing the naming policy forbids.

**Posting and closing are acts, so they are guarded by triggers.**
`documents.post`, `entries.post` and `year_end.close` name three things a
policy on a table cannot express: what changes is a state, on a row the member
may already write. A trigger on the transition holds for every path into it,
including a client that updates the column itself, and it does not require
republishing a function that carries a thousand lines of accounting for four
lines of permission.

**A guard written a day earlier had never fired.** `next_entry_number()` and
`next_matching_number()` became `SECURITY DEFINER` on 11 September with a check
that the caller may write the company — "a definer function that skipped that
check would be a way to burn numbers in somebody else's journal". The check
was `if auth.uid() is not null and not can_write_company(...)`, and
`can_write_company()` was `company_role(...) in ('owner','accountant')`:
`company_role()` returns NULL for a stranger, `NULL in (…)` is NULL, and `if
not NULL then raise` does nothing. So any signed-in stranger could draw
numbers in any journal of the installation. `has_capability()` returns false
rather than null and the guard fires; the test that would have caught it is in
`tests/capabilities.test.ts`. The demo seed fell over the fix, correctly: it
was booking as whoever ran `ekwo demo`, who is not a member of the fictional
company, and it now sets the claim to its own fictional owner for the length
of its transaction.

**An invitation names an address, not a user id.** `company_members.user_id`
has no foreign key to `auth.users` precisely so a membership can exist before
the person signs up — and there was no act that produced one, so somebody had
to read an id out of the Auth dashboard. `invite_member()` returns a token
once and stores a sha256 of it; `accept_invitation()` requires that
`auth.email()` match the address invited, case-insensitively, and is single
use and expiring. `sha256()` is core Postgres since 11, so no extension —
`pgcrypto` is not available in PGlite and the schema does without it.
Accepting is deliberately not an MCP tool: it is the invitee's own act, from
the application or from any client holding their session. `ekwo
accept-invitation` is not in this release because the CLI has no GoTrue
sign-in — it creates the first administrator through the admin API and holds a
database connection, not a session — and adding a password grant to a binary
that is handed a `service_role` key is not a small decision.

**A preference has no default, and a label is chosen in one place.**
Every *preference* column of `user_preferences` is nullable and carries no
default — `preferred_company_id`, `language`, `timezone`,
`date_display_format`, `number_display_format`, `theme` — and null means "take
the company's answer, then the pack's", which is the rule the document and
year-end decisions already keep for a country. Three columns are not nullable and are not
preferences: `user_id`, which is the key, and `created_at` / `updated_at`,
which are when the row was written. A row's own timestamp is not an answer
somebody inherits, so `now()` on those two is not the kind of default this
rule is about. `label_for(name, name_i18n, languages)` is now the only spelling of
the resolution that was written out wherever it was needed, and
`preferred_languages(company)` builds the chain — the user, then the company,
then the pack. `install_country_template()` is republished on it and keeps
passing one language, the company's: a chart of accounts is copied in the
language the books are kept in, not in the language of whoever ran the
installer. The MCP hands a client the chain and the material; it does not pick
a label for it, because which label a renderer prints is the renderer's
question.

**A display format is not a numbering pattern, and they stop sharing a name.**
The preference columns are `date_display_format` and `number_display_format`:
`country_defaults.number_format` already existed, where it is the pattern a
document number is built from, and two questions that have nothing to do with
each other should not answer to one name — a reader meeting both would have to
know which table they were in to know what they had. The guard that watches
for a country rule leaking into a function had already had to learn the
difference, which is what made the homonym visible.

**The numbering engine the document rules deferred.** That entry said, in as
many words,
that `next_entry_number()` did not read `number_format` and that "a numbering
engine that consumes a format is its own piece of work". This is it, on the
grammar already published: `{CODE}`, `{YYYY}`, `{YY}`, `{MM}` and a `{N…}`
counter padded to its own width, and `format_number()` raises on a token it
does not know rather than printing it. There is **no fallback literal**: a
pack that declares nothing gets `no_number_format` naming the field it has to
fill. The counter follows the pattern — a year in it restarts with the year,
and a pattern with none keeps one series for the life of the journal, under
period 0 in `journal_sequences`. A `{MM}` **prints** the month and does not
restart the counter: a monthly series is a fifth numbering style, no pack
declares one, and inventing the behaviour before a pack asks for it is how a
guess becomes a rule. Belgium and France declare exactly the pattern the
engine used to hard-code, so nothing about their numbers changed, and the
demo's FEC is byte for byte what it was.

**`numbering_gapless` gets its reader, and the exception has a name.**
`post_entry()` refuses a number chosen by hand where the country forbids a
hole in the sequence, because a number that skips the counter is exactly how a
hole appears. The argument that rule would have with an import arrived
immediately rather than later: a company moving from another system arrives
with years of entries whose numbers its returns, its filings and its auditor
already know, and refusing them would make the core unable to take over a set
of books.

So **`entries.import` is a capability, in no preset**. Not a flag on the call,
not a session setting: the one thing that lets an explicit number through is
something an owner grants on purpose to the person doing the import, and takes
back after it. Importing is not something an accountant does on a Tuesday.
What it does not relax: a duplicate is still refused, by the unique index on
`(company_id, number)` that has been there since the first release — stricter
than per journal, and it fires when the entry is written rather than when it
is posted — and an explicit number from somebody without the capability is
refused exactly as before. The guard carries no exemption for the
installation, unlike the permission checks, because a gapless sequence is a
rule about the books and not a permission: an importer running over a
superuser connection sets the request claim for the user it acts for, the way
`ekwo demo` already does. It asks for the capability and for nothing else,
which is also how a machine key holding `entries.import` is admitted.

**And the counter catches up.** `number_counter()` reads a counter back out of
a number through the pattern it was written with, and
`catch_up_journal_sequence()` advances `journal_sequences` to it — so the
first entry booked after an import continues the series instead of restarting
at one and colliding with it. A number written in another system's shape does
not parse against the pattern, and then the counter is left alone, because
there is nothing in it the counter could learn.

**A key is a third kind of caller, and it is narrower than both the others.**
A script has no browser to sign in with, and the two usual answers are wrong:
a `service_role` key gives it every company and every table, and a fake user
puts a password in a crontab and makes the audit trail say a person did it. An
`api_keys` row belongs to one company, carries an explicit list of
capabilities, expires when it is told to and is stored as a sha256. Nobody
mints a key stronger than they are — every capability on it has to be one the
issuer holds — which is also what makes revoking a person's capability revoke
the keys they left behind. **How it authenticates**: the holder calls
`use_api_key(secret)` at the start of a transaction, which puts the key's
fingerprint in `ekwo.api_key` transaction-locally, and `has_capability()` then
answers for it. The alternative was exchanging a key for a GoTrue session,
which needs either a fake user per key — the thing this avoids — or a service
that mints tokens, which is a second secret to hold. The setting is simpler
and its blast radius is one transaction. What it is not, stated rather than
discovered: a key is not a session. `auth.uid()` stays null, so the policies
that ask for a signed-in user rather than for a capability — the reference
tables, the company row — stay closed to it; and because PostgREST runs each
request in its own transaction, a key is for a client that holds a connection,
which is the self-hosted route the MCP server already has. Forging the setting
buys nothing: what goes into it is the hash, and the hash is only readable by
somebody who already holds `members.manage` and can simply issue a key.

**The installer is named, because "no session" turned out to mean "a key".**
Eleven guards were written as `auth.uid() is not null and not
has_capability(…)`, meaning "the installation itself is exempt": `ekwo
migrate`, the seeds and the CLI hold a database connection and no session, and
a guard that asks for a capability would refuse the install. A key is
precisely a caller with no `auth.uid()` — that is the design, not an accident
— so every one of those guards stood aside for it, and the narrowest caller in
the schema became the widest: a key issued with `["entries.read"]` could post
an entry, book a document, close a year, invite a member, create a company and
issue itself a second key carrying everything. Corrected on 13 September 2026
by **`is_installer()`**, which is true only when the runner set
`ekwo.installing` on its own connection, and false outright when there is a
session or when `ekwo.api_key` is set. A caller reaching the database through
PostgREST cannot set a GUC, and a caller holding a key has one set for it, so
neither can ever be the installer whatever it does. `has_capability()` is now
the only authority over people and machines alike, which is what this section
already claimed it was.

**A guard that answers NULL never fires.** The same audit found the other half
of it: `is_company_owner()` and `can_write_company()` were built on
`company_role()`, which is NULL for somebody who is not a member. In a policy
that is harmless — `USING (NULL)` admits nothing — but `if not
is_company_owner(c) then raise` does not branch on NULL, and
`enable_module()` / `disable_module()` are SECURITY DEFINER on a table with no
write policy, so they were the only door and it was open to any signed-in
stranger. Both helpers now answer `false`, the two module functions ask for
`company.write` instead of a role, and `hardening.test.ts` calls every boolean
helper of the schema as a stranger and refuses one that answers NULL — so the
shape stays safe for whoever writes the next guard.

**A company has a face.** Eight columns on `companies` — trade name, logo URL
or storage path (the core keeps no file), stated capital with its own
currency, activity code with the register it belongs to, default bank account,
document template. No `registry_reference`: `registration_number` already is
the number the commercial register holds, and a second column for it would be
two answers to one question. The capital with no currency takes the company's
own, in a trigger, because the alternative was a literal. A sales document
with no payee IBAN takes the default bank account, in a trigger on `documents`
for the reason the account of a line is resolved in one — every client has to
get the same answer — and a purchase document never does, because the payee
there is somebody else. `document_header` is the third view a renderer needs
beside `document_line_items` and `document_legal_mentions`, and `get_document`
was rewritten onto it rather than keeping its own assembly.

**The first financial year is a parameter.** `ekwo init` opened it on 1
January in two string literals, which is right for Belgium and France and
wrong for the United Kingdom, India and Australia — and
`country_defaults.fiscal_year_default` has carried the answer since the
country model learned what a document requires.
`fiscal_year_bounds()` is its reader, in the schema rather than in the CLI
because three callers ask the same question and three answers is how a company
ends up with two overlapping first years. A pack that says nothing gets
`no_fiscal_year_default` naming the field and the flag, never a January nobody
chose.

**`create_company()` and `bootstrap()` both create a company, and that is
deliberate.** The two rules involved — what a country pack puts in a company,
and what two dates a financial year has — live in `install_country_template()`
and `fiscal_year_bounds()`, and both callers delegate to them. What is
duplicated is the order of four inserts, and what differs is the behaviour
that cannot be shared: the installer is check-then-act, reports "already
there" for every step and can be run twice on a half-finished project, where
the function creates or raises.

**One rule of the modules change had to be narrowed, and it would have had to
be narrowed by whatever landed next.** A module's migrations were asked to
sort after *every* socle migration, so that one recorded history reads in
order. This release was the first socle change to land after a module, and it
broke
that test by existing: the socle will always gain a migration the week after a
module ships, and the only way to restore a total order is to rename a
published module migration — the one thing rule 1 of
`supabase/migrations/README.md` forbids. What a module can promise, and what
the order actually needs, was already the test beside it: every migration of a
module sorts after the socle migration its manifest declares it needs. The
applied order never depended on the timestamps anyway — `ekwo migrate` runs
the socle first and the modules after.

**The module policies already go through `has_capability()`, and their own
codes are theirs to add.** `assets` and `budgets` wrote
`module_enabled(company, code) and can_write_company(company)`, and
`can_write_company()` is one capability — so a member who lost `entries.write`
lost the module with it, which was the behaviour that was there before. **Done
on 13 September 2026**, each in its own migration, because a migration of the
socle that named `assets` would be the socle knowing what is built beside it.
`assets` declares `assets.read` / `assets.write` / `assets.post`, `budgets`
declares `budgets.read` / `budgets.write` and no `post` because it writes
nothing to the ledger; `capabilities.area` is the module code, which is what
that column was for. `assets.post` is asked *as well as* `entries.post`, not
instead of it: one says the module may send this to the ledger, the other is
the socle's own question, and an accountant who posts the books may be
deliberately kept off the asset register. The presets follow the socle's — a
viewer reads, an accountant works, an owner holds everything — and a code
added after the socle's migration has to name the owner itself, because that
preset was filled with `select 'owner', code from capabilities` at the time.

## The audit of 13 September 2026

**A currency and a decimal are rounded half up, on the absolute value, at the
currency's decimals — one rule, in every language this repository is written
in.** Three packages answered it three ways: `factur-x` added an epsilon and
rounded, `xbrl-cbso` rounded without one, and the MCP server used
`toFixed(2)`. All three are `Math.round` underneath in spirit, and `Math.round`
goes towards positive infinity — so -0.005 became -0.00 in one place and -0.01
in another, and a credit note stopped being its invoice with the sign flipped.
The other case is the one a binary float cannot hold: `2.675 * 100` is
267.49999999999994, so half up gives 2.67 where the rule says 2.68.

Half up on the absolute value is what an invoice, a VAT return and a set of
annual accounts are written with, and it is symmetric by construction. The
decimals are the currency's, which is two for every currency this repository
has met and is not two for all of them — `currencies.decimal_places` is the
column that will answer it, and until something reads that column the helpers
take the number as an argument and default it to two.

A format brick may not import the core or another brick, so the rule cannot be
shared as code: `rounding.ts` is the same file in `packages/formats/factur-x`,
`packages/formats/xbrl-cbso` and `packages/mcp`, and `tests/rounding.test.ts`
runs one vector through all three and then compares the three files byte for
byte. A copy that drifts fails the build.

**Five columns are declared and read by nobody, and now they say so.**
`country_defaults.rounding_method`, `country_defaults.cash_rounding_unit`,
`country_defaults.bank_statement_formats`, `country_defaults.payment_formats`
and `currencies.decimal_places` are each filled by a pack and consulted by no
code path. Every one of them was added for the right reason — the alternative
is migrating a table of years of rows a second time — and none is removed.
What was missing is the sentence that tells the next reader which columns are
load-bearing and which are a promise, because a column with a plausible name
and no reader is read as behaviour, and a pack author fills it expecting
something to happen. `20260913105120` puts that sentence in each column's own
comment, and `docs/schema.md` is generated from those.

One of the five has to stop being a comment: **`decimal_places` is what "at
the currency's decimals" means**, and every rounding in the schema and in the
three copies of `rounding.ts` is at two. Two is right for every currency the
packs carry and wrong for the yen, which has none, and the dinar, which has
three. Making the rule read the column is its own piece of work — it touches
`post_document`, `post_payment`, `settle_cash_basis_tax`, the statements and
the three format packages, and it needs a currency with something other than
two decimals in a pack before it can be tested honestly. It is not done here.

## A label is data, and a declared language is a promise (13 September 2026)

The schema had been bilingual in shape since the country packs landed —
`name_i18n` beside `name`, `label_for()` to choose between them — and
monolingual in fact. All four language files of Belgium and France held
`{}`. A Belgian company keeping its books in Dutch got a chart of accounts, a
set of journals and a VAT return in French, because the columns existed and
nobody had written the rows.

**Identifiers are English, permanently; labels are data.** Table names, column
names, enum values, function names and error codes are English `snake_case`
and are part of the interface a program tests against. Error messages are
English too, prefixed by a stable code — `period_locked: …` — so that a client
matching on the code can write its own sentence in any language without the
core ever holding two vocabularies. Everything a person reads because a
country said so is a row.

**Two tables were missing their column, and that was the whole gap.** The
accounts, the charts, the declaration boxes, the statement lines, the legal
mentions and the fixed-asset categories already carried a translation; the
journals and the taxes did not. So "translate Belgium" was never only a data
job: a company reading `Verkoopdagboek` over a chart in Dutch needed
`journal_templates.name_i18n` and `tax_templates.name_i18n` to exist first.
`country_defaults.name_i18n` came with them, because the country's own name is
shown as often as anything else.

**A declared language must be complete, and an undeclared one may be partial.**
These are the two halves of one rule. `languages` in the manifest is a promise
to a reader, and `ekwo pack check` holds the pack to it: every account of every
chart, every journal, every tax, every box, every statement line, every legal
mention and every asset category, or the check fails naming what is missing. A
half-translated pack is worse than an untranslated one — a chart of accounts in
Dutch under a return in French leaves nobody able to tell whether the software
is incomplete or the rule is different. But refusing anything short of complete
would mean no language ever gets contributed, so a file that is *not* declared
is allowed to be partial and falls back key by key. That is the path: write
what you are sure of, add the code to `languages` on the day it is finished.

**A translation lives in one file and nowhere else.** A legal mention carried
its `text_i18n` inline in the manifest and an asset category its `name_i18n`
inline in `assets.json`, which meant that adding Dutch to Belgium touched three
files and that two of them could disagree with the third. They moved into
`i18n/<lang>.json`, which now carries every section. One file per language is
what makes a translation reviewable by somebody who reads that language and
nothing else.

**Where a country publishes the wording, the pack uses it rather than
translating.** Belgium publishes its minimum chart of accounts in four
languages, its VAT return boxes in three and the models of its Central Balance
Sheet Office in four; those are the labels, and their source is cited in
`packs/be/i18n/README.md`. The German set is the Accounting Standards
Commission's own, which that Commission itself publishes as an unofficial
translation — so it is authoritative exactly as far as that document is, and
the README says so. France has no official English chart of accounts and there
is nothing to transcribe, so `packs/fr/i18n/en.json` is the wording the
profession uses, said plainly in its README. The rule when neither exists is to
leave the key absent: an absent key falls back and is visibly untranslated,
where a guessed one is wrong and looks right.

**The check lists the cause before the consequence.** Take a box out of a
declaration form and every language stops resolving it, so a single structural
mistake used to bury itself under forty translation errors. Structural problems
are now listed first. Nothing about the check changed except the order, and the
order is what makes it usable.

**`ekwo init` asks rather than assumes.** It offered the pack's own language as
the answer to press Enter on, which is right for one Belgian company in three.
The question now lists what the pack publishes, with nothing pre-selected, and
`--language` is required outside an interactive session whenever there is a
choice. `country_defaults.languages` is where the list comes from, because an
installation has the compiled seeds and no pack folder to read.

## The FEC carries its opening balances, and an unclosed year carries its result (13 September 2026)

`fec_lines()` returned the movements of a period and nothing else, so the file
of a financial year could not rebuild the balance sheet it belongs to: every
account started the year at nil. A tax inspector reads the *à-nouveaux* first,
and the closing decision of the release before this one had made them
impossible to post — every report here reads the ledger from the beginning, so
an opening entry does not carry a balance forward, it counts it twice.

**So they are computed, and never posted.** The opening lines exist in the
export and nowhere else. That is the whole reconciliation of the two
decisions: the ledger stays cumulative and free of *à-nouveaux*, and the file
carries them because the file is a per-year artefact and the ledger is not.
The amounts come from `trial_balance()`, which is where this repository
computes a cumulative balance — a second way of computing one is a second
answer waiting to differ from the first.

**A balance-sheet account is one that carries forward, and that is a fact
about its type.** The lines are selected on `accounts.carries_forward`, derived
from `account_type`, so nothing reads a code prefix: a chart that numbers its
assets in a fifth class is read correctly without anyone saying so.

**An unclosed year carries its result, and the export is never refused for
it.** An accountant produces the file of a year long before the meeting that
closes the one before it. The accounts that do not carry forward are the mirror
image of the balance-sheet ones, so leaving them out leaves the opening lines
short by exactly the accumulated result — and that amount goes on one more
line, on the balance-sheet account **the close would have left it on**. Which
account that is comes from `closing_style`, and the three answers are not the
same: `result_accounts` keeps it on a balance-sheet account of its own until a
meeting allocates it (France, 120 or 129); the other two have already reached
retained earnings by the time the year is over — an appropriation account is
*inside* the income statement and the closing entry empties it, so 693 is
never what a Belgian balance sheet carries forward, 140 is. A pack that names
no such account gets `no_result_account`, and so does one that names an income
or expense account, which would carry nothing at all.

**The entries a close writes are left out of the file of the year they
close.** A closing entry books the mirror image of every income and expense
account, and an appropriation entry moves the result to retained earnings;
both are dated inside the year being exported. Kept, they show the result
twice — once in the ordinary movements, once on the balance sheet — and the
income statement read from the file is nil. Left out, the file of a closed
year is byte for byte the file of the same year still open, and the result
reaches the balance sheet in the opening lines of the year that follows, which
is where a French or a Belgian package prints it too. Two tests hold that
sentence: closing a year does not change its file, and the opening lines of
the year after are the same whether the year before is closed or not.

**`financial_statement()` leaves out `closing` and keeps `appropriation`, and
the FEC leaves out both — deliberately, not by oversight.** They are not the
same question. An appropriation account is part of the statutory income
statement of the countries that have one, and the section that shows the
allocation would read nil without it. The FEC is not a statement: it is the
movements themselves, and it already carries the whole income statement in its
ordinary lines. Forcing the two readers through one predicate would mean one
of them is wrong; what they share is the column, and this paragraph.

**Only a whole financial year gets opening lines.** The FEC is a file per
financial year — its name is built from the year end — and an extract of a
quarter is an extract of movements. A period that starts or ends anywhere but
on the bounds of a year gets exactly what it got before this change.

**The wording of those lines is a value of the country model.** The
specification fixes eighteen columns and the format of each; it fixes no
wording for `EcritureLib`, and an administration reads the file in its own
language. So `defaults.opening_entry_label` sits in the pack next to
`closing_style` — France says *À-nouveaux* — and it is not an i18n key: the
label is addressed to an administration and not to whoever happens to be
signed in. Unlike an account code it keeps a fallback rather than a refusal, a
neutral English label, because a format that fixes no wording has no wrong
answer to give and a missing label is not a reason to hold an export back.
A pack is asked for nothing at all when there is nothing to carry: a first set
of books opens on nil and needs neither a journal nor a result account.

**And the deprecated FEC re-export is gone**, which is the other half of a
sentence written on 12 September: `packages/core` kept `src/fec.ts` alive,
marked `@deprecated` and unchanged, so that `@ekwo-ai/core` and
`@ekwo-ai/core/fec` went on working for one version — "the re-export goes in
the next". This is the next one. The core still depends on `@ekwo-ai/fec`,
because `EkwoClient.generateFec()` writes the file it has just fetched; what it
no longer does is re-export somebody else's API as its own.

**For an accountant to read.** Three things here are our reading rather than a
rule we can cite. The opening lines are one entry per year rather than one per
account, numbered from the opening journal's code and the day the year opens —
the format requires a number and fixes none. They are aggregated per account
and carry no sub-ledger code, so the *à-nouveaux* of a customer account is one
line and not one line per customer; a firm that details them by auxiliary is
not doing anything unusual, and that is the change to ask for if an inspection
expects it. And the destination of a result no meeting has allocated is the
account the close would have used — 120 or 129 in France, 140 or 141 in
Belgium rather than 693 or 793, which are inside the income statement and
would carry nothing forward.


## An append-only audit trail, and the first pack upgrade (14 September 2026)

Two things that had been promised in this file since 12 September and did not
exist: a record of who changed what, and a way to move a company from the pack
version it copied to the one the installation now holds.

### What is recorded, and what is deliberately not

Everything the ledger does is already immutable: an entry is posted once and
corrected by a reversal. What sat outside that guarantee is everything
*around* the ledger — the chart of accounts, the journals, the taxes and the
accounts they post to, the bank accounts, the contacts, the products, the
financial years, who is a member of a company and with which role, which pack
version the company holds. Those decide how every future entry is booked, and
nothing recorded that one of them had moved. An auditor asking who changed the
VAT account on this tax, and when, had no answer, and neither did the operator.

`audit_log` is one table, one generic trigger function and seventeen triggers.
It records `who` (`auth.uid()`, and the machine key where one was presented),
`what` (the table, the natural key, the row before and after as `jsonb`, the
operation), `when`, and the `company_id` row level security reads. Beside the
ordinary edits it records the *acts*: a document posted or cancelled, an entry
posted or reversed, a payment booked, matched or unmatched, a financial year
closed or reopened, a pack upgraded.

**The ledger itself is not audited.** `entries` and `entry_lines` are immutable
once posted and are corrected by a reversal, which is already a visible act; a
second copy of every ledger line would double the largest table in the schema
to record what it already holds. What is recorded is the act of posting, never
the content.

**Not `pgaudit`.** The extension is unavailable under PGlite, so none of this
could be tested where the rest of the schema is tested, and its output goes to
the Postgres log — a file an application cannot query and a self-hosted
operator often cannot reach. An audit trail nobody can read is a promise, not a
control.

### Three decisions inside it

**Append-only is a trigger, not a policy.** Policies do not apply to the table
owner, and on Supabase `service_role` carries BYPASSRLS — so an audit trail
defended only by row level security is one the operator can quietly rewrite. A
`before update or delete` trigger that raises holds for everyone. The one
exception is `purge_audit_log(date)`, which lifts it for its own transaction,
takes the cutoff it is asked for rather than a default retention, is reachable
by `service_role` alone, and writes its own row saying how many it dropped.

**`company_id` carries no foreign key.** The trail outlives the rows it
describes: a cascade from `companies` would delete the record of the company's
own deletion. It is indexed and the policy reads it, which is all a foreign key
would have bought.

**The installer's bulk copy is not audited row by row.** Installing a country
pack copies a thousand accounts into a company, and a thousand rows saying
"account created" carry nothing the single `company_packs` row does not.
`is_installer()` is already this schema's name for the migration runner, the
seeds and `ekwo init`, so the trigger stands down for it and for nothing else.
A person, a machine key, and anyone connecting with `psql` are all audited —
`is_installer()` is set by the runner on its own connection and can never be a
session or a key. Creating a company through `create_company()`, which is what
an instance administrator actually calls, is audited in full.

Two secrets are never copied into the trail: `api_keys.key_hash` and
`company_invitations.token_hash` are replaced by null. A hash is a credential
that can be attacked offline, and the trail is read by more people than the
table that owns it.

### The upgrade, and why the version sometimes does not move

A chart of accounts is not a file to overwrite — the company has been booking
on those accounts for a year — so the difference is computed by natural key and
every difference falls into one of the three rules this file promised in
September: an addition is copied in, a closed validity is applied, and
everything else is listed and left exactly where it was. That third rule is the
point of the whole thing: silently overwriting a company's chart from a pack is
how an upgrade destroys a year of bookkeeping, and there is no way to be sure
from here which of the two is right, because an operator may have renamed an
account deliberately.

One thing is never applied whatever is asked: a row the company holds and the
pack does not. Nothing is removed from a company's books by an upgrade.

**The recorded version moves only when nothing is left waiting.** A company
that still holds a difference nobody has decided on has not finished
upgrading, and moving the number would hide that difference at the next run.

The rules live in the schema — `pack_upgrade_diff()` and `pack_upgrade()` — and
not in the CLI, so an application, a module or an assistant asking the same
question gets the same answer. `ekwo pack status` is the read-only half.

**The test is from 1.0.0, not from a fixture.** The first upgrade is the risk
nobody can rehearse twice, so `tests/pack_upgrade.test.ts` replays the four
published 1.0.0 seeds kept under `tests/fixtures/seeds-before-packs/` since the
pack format replaced them, installs a company from them, loads the packs of
this release on top, and asks what an upgrade does. Without that, "never
silent" is an intention.

### Versioning the socle

The schema version was already exposed in `instance` and printed by `ekwo
status`. Three things joined it.

**Each package declares a `schema_min`**, in `package.json` under `ekwo.schemaMin`
and as a constant in its source, the way a country pack declares one in its
manifest — the rows a package reads and the functions it calls are a contract
with a version of the database. **The MCP server enforces it**: it asks
`ekwo_schema_version()` before it offers a single tool and refuses an older
database by name, because what an assistant does with a missing column is
improvise, and the improvisation is an accounting entry. The CLI declares one
and prints it; it cannot fail on it, since it is the package that carries the
migrations.

**`ekwo migrate` recommends a snapshot before it applies anything**, and says
why: migrations move forward only, there is no `down` and there will not be
one, so undoing a schema change on a database with a year of entries in it is a
restore and not a script.

The rule that no published migration is ever edited is enforced by CI since
13 September and was not redone here. The tag that rule is measured against
arrived the next day: `v0.2.0`, on 14 September 2026, is the first release of
this repository, and from it the rule is absolute rather than conditional on
nothing having been installed.

**`ekwo doctor` gained one check and not an inventory.** It now reads the
catalogue and says whether the audit trail is still what it claims to be: the
guard trigger on the table, row level security on, no policy that lets a client
write, update or delete a row, and `purge_audit_log` executable by nothing but
`service_role`. A migration added later that put an insert policy on `audit_log`
"so the application can log too" would break the one property the table exists
for, and nothing else would notice. What is **left out** is the full
expected-object comparison the card also scoped: an inventory of every table,
column and function this release defines is a generated artefact like
`docs/schema.md`, not a list kept by hand in the CLI, and it is worth its own
change.

## An amount is rounded at the decimals of its currency (14 September 2026)

The audit of 13 September left one sentence to be made true: *"`decimal_places`
is what 'at the currency's decimals' means"*, and until then every rounding in
the schema was `round(x, 2)`. There were fifty-one of them, in eighteen
functions, a view and a generated column, and two columns that every pack
filled and nothing read — `currencies.decimal_places` and
`country_defaults.rounding_method`.

Two decimals is right for the euro and for every currency the packs carry. It
is wrong for the yen, which has none, and for the dinar, which has three; and
"half up" was never a decision anywhere, it was what Postgres `round()` happens
to do. A yen invoice of 1 234,5 would have been booked at 1 234,50 and settled
at 1 235, and the half unit that does not exist in that currency would have sat
on a suspense account until somebody went looking for it.

**One pair, one arithmetic, one lookup.** `money_rounding` is the pair that
answers "how is this amount written": the decimals of a currency and the method
of a country. `round_amount(amount, rounding)` is the arithmetic, and the only
place in the schema where a rounding method is named — it switches on all four
the pack format allows, looks nothing up, and is therefore immutable and usable
from a view. `rounding_of(company, currency)` is the lookup, and the only
reader of the two columns; the currency defaults to the company's own, which is
what a ledger line is stated in. A test asks the catalogue for both lists and
fails on a third name in either.

**Nothing is guessed.** A currency the installation does not carry, a company
that does not exist, a country with no model: each is refused by name —
`unknown_currency`, `unknown_company`, `no_country_model`. There is no fallback
currency and no fallback country. What a pack that says nothing about rounding
gets is the column's own default, decided once in the schema by
`20260912091918` and written into the row when the pack was compiled; that was
settled on 13 September and nothing here reopens it.

**A function rounds in as many currencies as it handles.** `post_document`
writes the base and the tax of a document in the document's currency and the
ledger lines in the company's, and it resolves both. So do `post_payment` and
`reconcile`. A document in a currency with three decimals settled from an
account in one with two rounds each side at the decimals that side has, instead
of assuming both have two.

**A local that carries a scale is a second rounding rule.** `v_amount
numeric(16, 2)` rounds on every assignment, silently, at two decimals, whatever
the currency — so the declarations of every rewritten function are plain
`numeric` and the only thing that rounds is `round_amount`. For the same
reason a cast to `numeric(n, 2)` in the body of a reporting function is a
rounding wearing the clothes of a type, and the ones in `assets.register`,
`assets.movements`, `budgets.variance` and `fec_lines` are gone.

**A tolerance is a fraction of a unit, not of a cent.** `0.005` meant "half a
cent" and `0.001` "a tenth of one". In a currency with no decimals they are a
two-hundredth and a thousandth of the smallest coin there is, which is to say
nothing at all. They are written against `currency_unit()` now, which answers
1 for the yen and 0,01 for the euro.

**`document_lines.amount_untaxed` stops being a generated column.** Its
expression was `round(quantity * unit_price * (1 - discount / 100), 2)`, and a
generated column may not look anything up — so it could not ask what currency
the document is in. It becomes a column a `before` trigger writes on every
insert and update. The guarantee that mattered is intact: the total is derived
and can never be keyed in.

**The rule is the same one in four places, and a test proves it.** A format
brick may not import the core, so `roundCurrency` lives in three copies of
`rounding.ts` that are compared byte for byte. `round_amount` is the fourth,
and `tests/currency_rounding.test.ts` runs the same vector — zero, halves,
negatives, three decimals, a currency with none — through the SQL function and
through the TypeScript one and asserts they agree. The vector itself is one
file, so neither test can quietly stop covering a case the other still does.

**The proof is a whole ledger, not a unit test.** A fixture pack — the Belgian
chart, taxes and declaration form, moved to a country code that exists nowhere
and given a currency with no decimals — carries a document through its entry,
a payment, the matching, the VAT return, the trial balance and the close of the
year. Every figure is a whole unit. It is a fixture and not a pack of
`packs/`, because `packs/` is the law of real places and no real place uses it.

**What is not done: the columns still hold two decimals.** Every monetary
column of the schema is `numeric(16, 2)`, so an amount in a currency with three
decimals is rounded correctly by the engine and then rounded again, to two, by
the column it is stored in. Widening them is its own migration and its own
decision: the scale of a `numeric` column is what makes an amount print as
`100.00` rather than `100`, so widening rewrites the text of every amount this
schema returns, and dropping the scale instead leaves the normalisation to
whatever wrote the row. Neither belongs in the same change as the engine. A
test pins the present behaviour so that the gap is visible rather than
discovered, and `currencies.decimal_places` says it in its own comment.

**And the format bricks still round half up only.** `roundCurrency` takes
decimals and not a method, because every pack in this repository declares
`half_up` and a Factur-X or CBSO file is written from amounts the ledger has
already rounded. The first pack to declare `half_even` will have to hand the
method to the bricks as well; the vector test is where that will be noticed.

## The first release is v0.2.0 (14 September 2026)

The repository had a `[0.1.0]` section in its changelog and no tag. That was
the honest state — 0.1.0 was the first schema and nothing outside this
repository had run it, which is the one circumstance in which editing a
published migration costs nothing, and it is what the exception of 11 to 13
September relied on. A tag ends that circumstance, and it ends it for good:
from here a mistake in a published migration is corrected by a new migration,
and CI measures the rule against the latest tag on every push.

**The number is 0.2.0 and not 0.1.1 or 1.0.0.** Everything between the two is
additive — the installer, the MCP server, country packs, capabilities and
machine keys, modules, the audit trail, the generalised tax engine, financial
statements, languages, currency-aware rounding — so a minor is what semantic
versioning asks for. 1.0.0 is a promise about stability that a schema three
days old cannot make.

**The schema floor moves with it.** `ekwo`, `@ekwo-ai/core` and `@ekwo-ai/mcp`
declare `schema_min` 0.2.0, because the packages of this release read
`audit_log`, the rounding functions and `company_packs`, and a 0.1.0 database
has none of them. The floor is a floor and not the version: a later release
that adds nothing a package reads leaves it where it is.

**A release bumps `ekwo_schema_version()` in a migration of its own**, and
nothing else in that file. The column default and `init_instance()` call the
function, so a fresh installation records the new number without a second
edit; an installation that already exists gets it from `ekwo migrate`, which
writes the answer back onto `instance.schema_version`. The two were always
going to drift otherwise, and the number that drifts is the one a client
refuses an old database on.

**The packages are not on npm.** There is no account for the organisation yet,
so `npx ekwo init` is what the CLI will be called and not what it is reachable
as today. The order is deliberate when there is one: tag first, publish after,
so a version on npm is always a version whose source someone can read.
`docs/releasing.md` is the procedure.


## A golden year per country, and what it immediately found (14 September 2026)

The pack format has been able to describe a country since 12 September: a
chart, taxes and where they post, the boxes of a return, financial statements.
What it has never had is a way of being *wrong in a way anyone would notice*.
A tax that posts to the wrong grid and a grid that expects the wrong postings
agree with each other. The seed compiles, `ekwo pack check` is silent, every
unit test passes, and the return is wrong.

**So a pack now carries a year of books and the figures they produce.**
`packs/<cc>/golden/scenario.json` is ten documents at least and the payments
that settle some of them, declarative like the rest of the pack; beside it,
generated and never hand-written, `vat_return.json`, `statements.json` and
`trial_balance.json` — every box, every statement line and every account that
moved, to the cent, in the pack's currency. `UPDATE_GOLDEN=1 npm test --
tests/golden.test.ts` rewrites the three and never the scenario: a runner that
can rewrite its own inputs proves nothing.

**One runner, no country in it.** `tests/golden.test.ts` reads `packs/`,
installs a company on each pack from what that pack's own scenario declares,
and replays it through `post_document`, `post_payment` and `reconcile` before
comparing `vat_return`, `financial_statement` and `trial_balance`. What it
demands of a scenario, it demands of the *pack*: a tax due on collection is
required of a scenario whose pack has one, and of no other. The alternative —
a list of Belgian and French things a scenario must contain — is the country
code in the test file that the whole pack format exists to remove.

**A pack with no golden is refused**, by `readPack` and therefore by `ekwo pack
check` and the CI. A pack that cannot have one says so in its manifest, in a
sentence the commands print: `packs/generic` is the only one here, and the
reason is structural — a framework has no chart, no journal, no tax and no
currency, so no company can be installed on it. An exemption is a claim
somebody made and it is printed, never a silence.

**The expectations are outside the pack's checksum, the scenario is inside
it.** A scenario is a decision about what a country's books look like and
moving it moves the pack. The three expectation files are what the engine made
of that scenario — a build artefact, like the seed and like `docs/schema.md` —
and a checksum that moved because the statements function gained a line would
tell every operator that Belgium had changed.

### What it proves, and what carries the rest

Internal coherence, and nothing else. A box expected wrongly and a posting
written wrongly pass together, and no test reaches past that. Two things
carry the rest and both are now enforced rather than encouraged:
`legal_reference` is **required** on every tax and on every box of a
declaration — `ekwo pack check` refuses a pack that leaves one out, and a
`"TODO"` is not a source — and `certification.status` says out loud how much
anyone has read, which `ekwo init` prints before a company is created.
`.github/CODEOWNERS` names an owner per pack, for the same reason: a rate is
right or wrong against a law, and the person who knows is the person who
applies it.

### Two things the first run found, both in the French pack

Reported and not quietly corrected. A golden that is adjusted until it passes
is a golden that records a bug.

**Line 01 of the CA3 can come out negative.** It is computed as the sum of the
taxable bases — `plus: ["08:base", "09:base", "9B:base", "13:base"]` — so a
quarter whose credit notes exceed its sales reports a negative turnover, which
is not a figure the form accepts. The second quarter of the French golden
shows −1 200,00.

**Line 08 does not tie to itself on an intra-Union acquisition.** The
acquisition posts its base to line 03 and its tax to line 08, so `08:tax` is
not 20 % of `08:base` in any period that carries one: the golden's second
quarter reports 460,00 of tax against −1 200,00 of base. On the paper form,
cadre B line 08 carries every operation taxed at 20 %, acquisitions included,
and cadre A line 01 is only the sales — they are two totals, not one derived
from the other. The pack derives line 01 from line 08, which is right only
while line 08 carries nothing but sales.

The two are the same defect seen from either end, and fixing them is one
decision about what cadre A owes cadre B on the CA3 — a decision for the
French pack and for an accountant reading it, not for the change that made
them visible. They are the argument for the golden, made on the day it
shipped.

## Two install paths, one installation, proved end to end (14 September 2026)

**The README has always said the two routes are interchangeable; nothing
checked it.** `npx ekwo init` runs the CLI's migration runner and its seed
loader; `supabase db push` followed by `psql -f` runs neither — the Supabase
CLI reads the same folder of files, and the operator applies the seeds by
hand. "Interchangeable" is a claim about the state of a database, so
`tests/e2e/install_parity.test.ts` builds one of each and compares them: the
migration history, the columns of every table, the body of every function, and
every row of every table the seeds write, rendered as JSON and sorted. The
second path deliberately imports nothing from `packages/cli` — a test that
drove both through the same runner would prove the runner is deterministic,
which nobody doubted.

**The list of tables is read from the seeds, not written down.** A list
written down is one a new pack section quietly falls out of. Three kinds of
column are left out and each is named: `id` where it is a surrogate key behind
`gen_random_uuid()`, the clock (`created_at`, `updated_at`, `installed_at`),
and a uuid that is a foreign key to another template — for which the dump
refuses to guess and demands a natural key. A migration that adds a reference
between two template tables fails this test until somebody names it, which is
the intended behaviour: comparing two random numbers and calling them equal is
worse than not comparing at all.

**What it found: the README told an operator to apply two seed files of the
four.** `config.toml` lists `00_currencies`, `05_framework_generic` and the two
packs; the by-hand instructions named the currencies and one pack. An
installation made that way came up with a chart of accounts and no generic
financial statements — the fallback for a chart that declares none of its own —
and nothing failed, anywhere, until somebody asked for a balance sheet. The
README is fixed, and a test now reads it: every seed file the installer applies
must be named in it. Beyond that the two paths agreed on every byte.

**The year is played out, not asserted at.** `tests/e2e/lifecycle.test.ts`
starts where a real installation starts — the frozen 1.0.0 seeds, a company
created from them, four releases of schema since — brings it to this release,
upgrades its pack through `ekwo pack upgrade`, and then does the year: the
opening balance, a sale, a purchase, the VAT return, both financial statements,
the close, the re-opening, the close again. It runs once per country the frozen
seeds carry and names none of them: the accounts, the journals, the tax, the
declaration form and the schemes all come out of the pack, and a country that
names no opening journal fails by name rather than silently.

**Every figure is compared to one the test works out itself.** A test that
reads `financial_statement()` and compares it to `financial_statement()` proves
the database is deterministic. `tests/e2e/expected.ts` starts from
`sum(debit) - sum(credit)` — an aggregate no function of this schema takes part
in — and from the pack's own rows, and rebuilds the answer in TypeScript: the
rule engine that puts an account on a line of a scheme, the evaluator the
declaration forms and the statements share, and the boxes a tax posting writes.
It is a reimplementation and not a second opinion, which is worth saying
plainly: it follows the same rules, because the rules are the specification.
What it cannot do is share a bug with the SQL. The rounding is the one
deliberate exception — `roundCurrency` is the TypeScript half of a rule already
pinned against the SQL half — so the two engines agree about rounding and about
nothing else.

**Closing is what makes a balance sheet balance, and the test says so.** Before
the result of the year is appropriated, the accounts that carry forward are out
by exactly that result and every scheme prints the gap; after the close they
net to nil. Both figures are asserted, in both countries, which is how the
end-to-end test would notice a closing style that moved the result to the wrong
side.

**What only a real run proves, and why it is not in the CI.** PGlite is real
Postgres, and four things it is not. It is not the published binary over a
pooler connection. It is not PostgREST — a function that exists and was never
granted to `authenticated` passes every test in this repository and answers
"permission denied" to the first user. It is not GoTrue, so row level security
is judged on a session variable a test set rather than on a JWT a person was
issued. And it is not a hosted project's extensions, roles and defaults.
`scripts/e2e-supabase.mjs` covers those four against a real project, through
`node packages/cli/dist/bin.js`, a GoTrue sign-in and PostgREST, and prints a
pass/fail table. It is run by hand before a release is tagged and never by the
CI: it costs money and it needs a project nobody minds losing.

**It refuses a database that is not empty.** The script installs an instance,
an administrator and a company, books into them and closes a financial year.
Run against books that matter it would be a disaster with a pass/fail table at
the end, so the first thing it does is ask whether `public.instance` holds a
row and stop if it does. It deletes nothing on its own: what is left behind is
the evidence. `--reset` is the exception and exists for one reason — a run that
fails halfway leaves an instance row, so the next one is refused, which is
right and useless while a script is being written. It is deliberately not an
`ekwo` command: an installer that can empty a database is one somebody points
at the wrong connection string.

**What the first real run found, in the order it found it.** All four are
things no test against PGlite could have said.

*`ekwo init` cannot be run unattended on a pack with several charts or several
languages* — it refuses to pick, by name, and says which flag to pass. That is
the right answer and not a defect; it is written down here because every
script that installs Ekwo will meet it.

*Nothing in `supabase/migrations` grants table access to `anon` or
`authenticated`.* On a real project those come from the project's own default
privileges on `public`, and the test harness supplies them from a shim. Drop
and recreate the `public` schema without putting them back — which is what the
first `--reset` did — and the reinstall succeeds, `ekwo doctor` is content, and
the first read through PostgREST answers `permission denied for table
companies`. The reset restores them now. The schema being self-contained on
that point is a decision for another day; what is decided here is that the gap
is visible rather than discovered.

*`ekwo pack upgrade` left the company behind.* It asked for the difference and
returned early when it was empty, saying the company was already at the version
this installation holds — two different claims. A patch release moves the
version and touches no natural key, so the difference is empty and the company
recorded the old version for ever. The early return is gone; `pack_upgrade()`
already did the right thing with an empty difference.

*`ekwo doctor` told the operator to upgrade a CLI that was already current.*
`ekwo migrate` applies the modules' migrations beside the socle's, into the
same history; `status` and `doctor` computed their gap against the socle alone
and read the eight module versions as history they had no file for. One command
after another, on the same database, the two disagreed. All three build the
same set now.

## `ekwo doctor` knows what a release defines (14 September 2026)

The change of 13 September gave the doctor one catalogue check — whether the
audit trail is still append-only — and left the rest for its own change, with
the reason written down: *"an inventory of every table, column and function
this release defines is a generated artefact like `docs/schema.md`, not a list
kept by hand in the CLI"*. This is that change.

**The inventory is generated, committed and shipped.**
`scripts/generate-expected-objects.mjs` applies the migrations under PGlite —
the same way `scripts/generate-schema-doc.mjs` does — and writes
`packages/cli/assets/expected-objects.json`: per schema, the tables and their
columns, the views, the functions with their identity arguments, the policies,
the triggers and the types. `copy-assets.mjs` puts it in `dist/assets` so it
travels with `npx ekwo`, and two CI jobs hold it in place: one regenerates it
and fails on any difference, one diffs the shipped copy against the repository's.
A list typed out by a human is wrong the first time somebody adds a table and
forgets the list, and then it lies in both directions at once.

**Everything sorts on a key, and `oid` is never one.** A name, or a name and a
signature; columns by name rather than by `attnum`. `oid` is an allocation
order, not an order anybody chose, so it belongs nowhere except as a tiebreaker
between two objects that a human would call the same name — which is exactly
what `docs/schema.md` needed and did not have: its function table was ordered
by `proname` alone, and the two `resolve_line_account` overloads sat in
whatever order the rows came off the heap. It now orders by `proname, oid` and
the two overloads swapped places once, for good. The inventory does not use
that tiebreaker at all: it keys a function on its name **and** its identity
arguments, which is what makes an overload a different function in the first
place, so it needs no tiebreaker and cannot be moved by one.

**Missing, extra and a policy are three different answers.** Something missing
means the installation is behind or has been damaged, and that is a problem.
Something extra means an operator added their own table or their own function,
which is their business and is reported as information — a doctor that failed
on it would be a doctor telling people not to use their own database. A
**policy** is the exception in both directions: row level security is the whole
security model here, so a policy that is gone closes a table to everyone and a
policy that was added is a grant nobody reviewed. Both are problems. A column
whose type has moved is a problem too, and is reported as changed rather than
as missing, because "missing" would send the operator looking for a migration
that did land.

**The exit code says one thing.** `0` when nothing is a problem, information and
warnings included; `1` on the first problem. That is what makes `ekwo doctor`
usable as a deployment gate, and what keeps an operator's extra table from
turning a pipeline red.

**A module is required of a database that carries it, and of no other.** The
inventory holds a section per module, and the comparison asks `public.modules`
what this installation actually holds. A module whose migrations never ran is
named and skipped rather than reported as two hundred missing objects. Whether
a *company* has enabled the module is a different question with a different
table, and it changes nothing about what the schema must contain.

**A database older than the CLI is compared anyway.** The report names the
version the inventory describes and the version the database reports, and then
lists what differs. Gating on the version would refuse precisely the
installation somebody runs the doctor on.

**What is left out.** Constraints, indexes, grants and function bodies. A
dropped unique index is real damage and this will not see it; the inventory
answers "is it there and is it still that shape", and the three of them are
each an order of magnitude more text for a diff that would move on every
Postgres upgrade. `docs/schema.md` carries the constraints for a human reader
today, and an inventory that nobody reads the diff of is worth nothing.

Grants came back the same day: the entry below gave the schema its own
privileges, which made them a thing the migrations state rather than a thing
the project happens to hold — and a statement is exactly what an inventory can
check. They are a `grants` section of this file and a `grants` check of the
doctor, kept apart from the categories above because missing, extra and
changed do not mean the same thing about a privilege.


## The country pack is finished as a taxonomy, and is written down (14 September 2026)

Phase 0 set out to make a country describable in data rather than in code, and
it is done. This entry closes the chapter: what the format ended up carrying,
what was deliberately left out of it, and what the documentation now promises.

**What a pack turned out to need.** The first sketch was a chart of accounts,
taxes and their postings. It shipped as eleven things, and the six that were
not in the sketch are the six that would each have become a country-shaped hole
in the core: the boxes of a declaration and their totals; financial statements
and a country-less framework behind any chart that prescribes none; several
charts per country, because an association and a company file the same return
on different accounts; what the country puts on a document — numbering, the
payment term, the tax point, the e-invoicing profile, the bank formats, and the
sentences the law requires with a closed vocabulary of conditions; the labels of
all of it in every language the pack declares; and a year of books with the
figures it produces. Each was found the same way: by trying to write the second
country and noticing what still lived in a function.

**The taxonomy is the part that will not be redone**, and it is three rules, all
of which held. A pack is data and cannot execute: no expression language, no
hook, no field through which a country could run anything, so a formula is a
list to add and a list to subtract and a condition is a value out of a closed
list. Nothing in the core carries a country, a currency or a language of its
own, and nothing falls back on one: a reader that needs a value a pack did not
give names the value, and a default closing style would have been one country's
mechanism handed to every country that had not spoken. And nothing is ever
deleted from a pack — an account is deprecated, a tax gets a `valid_to`, a form
version gets a new `valid_from` — because the return of a past period has to
keep giving the same answer for as long as anyone can be asked about it.

**What was deliberately left out, and why it is not a gap.** The rates of
American sales tax: tens of thousands of jurisdictions changing monthly is a
feed, not data somebody reviews, and the form belongs in a pack while the rates
do not. Canadian rates *are* in a pack, because fifteen stable combinations
published by one administration is data. Revaluation of open items, cash
accounting as a ledger, several taxes stacked on one line, the gross-to-net
computation of a tax-inclusive price, and the cash-flow statement: each is
declared or accepted by the format and implemented by nobody, waiting for the
country that needs it rather than being guessed at from Belgium. Analytics,
fixed-asset regimes beyond what a module carries, payroll, inventory, and the
translation of the application itself, which is a different problem from the
translation of a chart of accounts.

**Certification stayed honest, which cost a status.** There is no value meaning
"certified by Ekwo", and the one that existed was deprecated and migrated away.
Writing a pack and testing that it holds together is not reviewing it. So the
scale is `community`, `maintained`, `reviewed`; `reviewed` names a person and a
date and nothing else counts; `legal_reference` is a required field on every tax
and every box so that a reviewer has something to read against; and
`.github/CODEOWNERS` puts a name next to each pack, which is who is asked and
not who has signed.

**The documentation is a deliverable of the phase and not a write-up of it.**
[`packs.md`](packs.md) is the format file by file, the compiler and what it
writes, every rule `ekwo pack check` applies grouped by what it guards, the
certification policy, and a ten-step walkthrough for adding a country in a day.
The reason for the list of refusals is narrow: a contributor meets those rules
one error message at a time, and a rule they cannot find written down reads as
the tool being arbitrary.

**And four things an installation cannot do for its operator are now printed
rather than assumed.** Disabling self sign-up, keeping a second administrator,
keeping the `service_role` key off machines that do not need it, and reading
[`DISCLAIMER.md`](../DISCLAIMER.md) before filing anything. Three of the four
are settings of a Supabase project rather than rows in a database, so no
connection string reaches them and `ekwo doctor` cannot check them. They are
printed at the end of a successful `ekwo init`, where the person still has the
dashboard open, and written in the installation guide in the same words — with
a test reading both, because a checklist kept in two places drifts. Checking
them automatically would mean handing the CLI a Supabase management token, and
a token that can read a project's settings can change them; that is a phase 1
trade and it is not obviously worth making. None of it is ever an action Ekwo
takes on somebody else's project.

**Three things the installation guide was not saying**, all of which a script
meets before it meets anything else. `ekwo init` refuses to pick a country, a
chart of accounts or a language when there is nobody to ask, and names the flag
— which is the right behaviour and was written down as a finding rather than as
documentation. Table access for `anon` and `authenticated` is not in
`supabase/migrations`: it comes from a Supabase project's own default
privileges on `public`, so dropping and recreating that schema without putting
them back leaves an installation the doctor calls healthy and PostgREST answers
`permission denied for table companies` on. It is recorded as a known gap, not
as a promise; whether the migrations should be self-contained on that point is
still a decision for another day. And the catalogue check now says what it does
not cover, because a check whose boundaries are unwritten is read as covering
everything.


## The schema grants its own rights (14 September 2026)

Answering the question the two entries above both leave open, in the same
words: *whether the migrations should be self-contained on that point is still
a decision for another day*. This is that day.

**What was borrowed.** A Supabase project carries default privileges on
`public` — `grant all on tables`, `on sequences`, `on functions`, to
`postgres`, `anon`, `authenticated` and `service_role` — so every table a
migration created came out readable and writable by the three API roles
without a single `grant` in `supabase/migrations`. The arrangement worked and
was wrong twice over.

It was a hole. Those defaults give `anon` — the role behind the publishable
key that any visitor holds — INSERT, UPDATE and DELETE on every table of the
ledger, with row level security as the only thing in the way. That is one
layer where the rest of this project has two, and it sat under a doctrine
which says, in the entry above about the anonymous role, that a surface should
be closed rather than merely empty.

And it was a dependency nobody had written down. The defaults live in
`pg_default_acl`, keyed by the schema; drop `public` and they go with it. The
reinstall then succeeds, `ekwo doctor` reports a healthy database, and the
first read through PostgREST answers `permission denied for table companies`.

**Migration `20260914151207` declares them instead**, by name, table by table
and view by view, with two module migrations doing the same for `assets` and
`budgets`. The rule it writes down is that the grant and the policy are two
halves of one sentence: `authenticated` may attempt exactly the verbs the
policies of that table are prepared to judge. Twenty-six tables carry a policy
`for all` and get the four; twenty-four have a select policy and get SELECT
alone — the reference tables a pack installs, the five written only by a
`security definer` function, and `audit_log`. `anon` holds nothing on any
table, view or sequence anywhere, and keeps the ten policy helpers it already
had. `service_role` gets what a person gets and no more: it bypasses row level
security, so its grants are the only limit it has.

**DELETE is granted where deleting is bookkeeping.** On `entries`,
`entry_lines`, `documents` and `payments`, deleting a draft is an ordinary act
and deleting a posted one is refused by the period lock and by
`entries_guard_period`. Withholding the privilege would break the first and
change nothing about the second. On `audit_log` it is withheld, and so is
UPDATE and INSERT: the trigger already refuses them for every role including
the owner, and the missing privilege is the statement of intent beside the
guarantee.

**No wildcard grant, and no `alter default privileges` as the mechanism.**
`grant all on all tables` is how a table added next year becomes writable by a
role nobody thought about, and a default privilege is the same thing one level
down — which is the mechanism being removed, so it cannot also be the fix. The
convention from here: **a migration that creates a table, a view or a function
grants it in the same file**, beside the `revoke execute … from public` that
was already compulsory. Ekwo's own default privilege that granted EXECUTE on
future functions to `authenticated` is revoked too; functions created before
keep what they hold, and a function created after is granted in its own
migration or is reachable by nobody.

**What enforces it, because a convention nobody checks is a comment.**
The `grants` section of `packages/cli/assets/expected-objects.json` — the
inventory that already carries the objects a release defines, because a
privilege and the object it sits on ship in the same migration — is generated
from a freshly migrated database by `scripts/generate-expected-objects.mjs`
and committed; the
CI regenerates it and refuses a diff, so a migration that forgets its grants
moves a file and is caught before it is merged. `tests/grants.test.ts`
compares the catalogue to it and asserts the doctrine separately — `anon`
reaches no table, a grant says what the policies say, a trigger body is
callable by nobody. `ekwo doctor` asks a live database the same question: a
missing grant is a problem, an extra grant to `anon` is a problem, an extra
grant to `authenticated` is a warning, and a default privilege still standing
is a warning.

**The test harness stopped helping.** `tests/helpers/supabase-shim.sql` ended
with those default privileges and `freshDatabase` with a `grant … on all
tables in schema public`, which between them made every test in the repository
pass against privileges no installation was guaranteed to have. Both are gone.
Every test file is now also a test of the grants, and `tests/grants.test.ts`
goes further: it builds a database where the three roles begin with nothing at
all and no default privilege exists, replays the migrations, and books a whole
country pack's golden year through it as `authenticated`. The last test of
that file takes one grant away and shows the year stops, because a scenario
that would pass whatever the grants are proves nothing about them.

**Two things it found, neither of which any test could have said before.**

*`anon` could read every table of the `assets` and `budgets` modules.* Their
opening migrations carried `grant select on all tables in schema … to anon` —
the only place in the whole schema where the anonymous role held a privilege
on a table. Row level security answered every such read with an empty set, so
nothing leaked; the surface is closed now.

*`ekwo pack upgrade` could not have worked through PostgREST.* `pack_upgrade()`
records its own line in the audit trail rather than leaving it to a trigger,
and it was `security invoker`, so the call to `audit_record()` was made as the
caller — who has not been able to execute it since `20260914103412` closed it.
Nothing noticed because the harness granted EXECUTE on every function back.
On a real project the writes would have committed and the trail would not.
`20260914152840` makes the function `security definer`, like `enable_module()`
and `invite_member()` and for the same reason: it already refuses a caller
without `company.write` on the company it was given, by name, before it
touches anything.

**What is deliberately not decided here.** Which companies a role may see —
that is row level security, and not one policy of this schema changed. A grant
says which verbs may be attempted; a policy says on which rows they succeed.
This settles the half that was being borrowed.

## Luxembourg is a pack, and it is `community` (14 September 2026)

The third country, and the first written from published sources alone rather
than from books somebody was already keeping. Three decisions in it are worth
recording, because each of them is the kind a later pack will meet again.

**The whole chart, at the depth the law prescribes.** The *plan comptable
normalisé* runs to 1 026 accounts, 747 of them postable, where Belgium ships 353
and France 394. The temptation was to ship a working subset, and it was refused:
Luxembourg publishes no abridged chart — what it abridges for a small company is
the *presentation*, not the chart — so a subset would have been this
repository's opinion of which accounts matter, sitting in a file that claims to
be the regulation. What the pack ships is a transcription, and a company that
needs an account it does not use simply has it.

**The mapping to the financial statements is the State's own, account by
account.** The same annex carries the chart and the *tableau de passage* — which
line of the abridged balance sheet or profit and loss account each account
reports in — so all 747 postable accounts reach exactly one line by an
`account_code` rule naming the code. Compressing that into ranges would have
been about a third as many rules and would have been an inference: a range says
"everything between these two codes", which is true of the chart as it stands
today and is not what the regulation says. A reviewer checking one account finds
one line.

**`community`, and the pack says what a reviewer should read first.** Belgium
and France are `maintained` because the maintainers keep them current and use
them. Nobody here files a Luxembourg return, so the honest status is the one
that means *contributed, not read by an accountant* — and the pack's README ends
on ten points where the text allows more than one answer, from whether article
63 requires a gapless number to whether the domestic reverse charge is worth
offering at all. A list of known soft spots is worth more to a reviewer than a
status that overstates the work.

What the pack could not say, and what would fix it, is in
[`international.md`](international.md) under the countries: a company records no
declaration periodicity, a form's `period` cannot name three cadences, the
`sequence` of a declaration box means print order and evaluation order at once,
and a computed statement line may carry a sign that is applied twice. None of
the four was patched into the core for Luxembourg's sake. That is the whole
point of a pack being data — and three of the four were closed on their own
merits on 14 September 2026, for every country, in the last two entries of
this file.

## Estonia was written to test the format, not to open a market (14 September 2026)

The plan put the United Kingdom and Canada first. Estonia went ahead of both,
alongside Luxembourg, and the reason is what the pack format was for.

**A country nobody designed the format for is the only thing that proves a
format is a format.** Belgium and France were extracted from a core that had
been built around them, so everything they needed was there by construction. A
pack written from the outside in — by somebody reading a foreign statute, with
no permission to change the core — is the honest test of the claim that a
country is data. Estonia was picked because it is small enough to finish and
awkward enough to be interesting: a standard rate that moved twice in eighteen
months, a return whose boxes nest three deep, a reduced rate that went 9 %, 5 %
and 9 % again, and **no legal chart of accounts at all**, which is the case the
format had never met.

**The rule held, and the pack is entirely data.** No migration, no function, no
column, and no change to `tests/golden.test.ts`, which installed a company on
the new pack and replayed fourteen documents without knowing that Estonia
exists. Six things the core cannot say turned up, and all six are written in
[`international.md`](international.md) with a fix and with the workaround the
pack uses instead — because a gap fixed quietly during a pack is a gap the next
contributor meets again.

**The one place where the format bent is worth naming.** A tax carries one
`base` posting per kind of document, so it reports to one box; form KMD asks
for the same amount in a box, in the memo box inside it, and sometimes in a
third. The pack posts to the innermost box and rebuilds the printed parents as
totals, which needs six boxes the form does not print. That is exact and it is
not obvious, so it is documented in the pack's own README rather than left for
somebody to find in a diff. The alternative — filling the parent and leaving
the memo boxes empty — would have produced a return the tax authority
cross-checks and rejects, and would have looked fine in every test.

**Estonia is `community`, and stays there.** Nobody has read it against the law
they apply. Writing a pack carefully, citing an article on every rate and every
box, and proving that fourteen documents produce the figures somebody wrote
down is exactly what `community` means: contributed, not reviewed. The status
moves when an Estonian accountant puts their name in the manifest, and not
before.

## A test may book in a country. It may not expect one.

*14 September 2026*

The suite named `BE`, `FR` and `LU` by hand in eleven files: six loops over a
literal pair of slugs, and tables of rows keyed by country — the statements and
their line counts, the declaration forms and their box counts, the exchange
accounts, the charts, the closing parameters, the fixed-asset rules. Luxembourg
landed a week earlier and most of those tables had to be edited for it to be
seen at all. Which is the argument: **until a test walks the packs, a new pack
proves nothing, because nothing looks at it.**

The line drawn is between the two halves of a test. **Setting up may name a
country** — a scenario books invoices somewhere, with some chart and some tax
code, and saying which is how it stays readable; a new pack never has to touch
that line. **Expecting may not** — what a test asserts about the core comes
from the pack, or it is an assertion about the countries somebody remembered.

Three things follow.

**`tests/helpers/packs.ts` reads every pack once.** `allPacks` to loop,
`packWhere('taxes on collection', …)` to pick by the property under test rather
than by the country that happens to have it, `somePack` where any pack will do.
`packWhere` throws when no pack carries the property, naming it: a loop that
silently checked nothing is the failure being prevented, not a lesser one.

**A claim only one pack can make lives with that pack.** A fact key of a
national filing taxonomy is written in `statements.json`, so a test comparing
the two would compare a file to itself — and a generic test cannot check it
either. It goes to `packs/<cc>/golden/expectations.json`, beside the golden and
outside the pack checksum, loaded by one runner. A contributor states a claim by
editing their own pack. The alternative, a `tests/packs/<cc>.ts` per country,
was refused for exactly the reason the whole change exists: it would have put a
file under `tests/` back on the path of adding a pack.

**A grep guard in the CI**, because the pull request that reintroduces one
literal is the one nobody notices. It fails on a country code inside an
`expect(…)`, on a list of two or more country codes, and on a pack named by hand
where `listPacks()` would have found it. One comment, with a reason, is the way
out.

What is deliberately left: `tests/closing.test.ts` still books its scenarios in
a named country, because the amounts it asserts carry that country's VAT rate.
Deriving those from the pack's own taxes is a change to the fixtures, not to an
enumeration, and it is worth doing separately.

## The chart stays whole and the list gets short (14 September 2026)

A country pack transcribes the regulation: Estonia ships 120 accounts, Belgium
353, France 394, Luxembourg 1 026. That was decided on purpose — an abridged
chart would be this repository's opinion of which accounts matter, sitting in a
file that claims to be the law — and nothing here takes it back. What it costs
is a different thing: somebody looking for the account a purchase invoice goes
on is handed three hundred rows, and an assistant reading the chart through the
MCP server is handed the same three hundred rows before every question.

Two production installations were measured on a full year of books. One used
**60 accounts out of roughly 300**; the other **126 out of roughly 300**. Both
are ordinary companies of the same country, and neither would have been served
by a smaller pack — they use a different sixty.

**So the chart is not narrowed; a second question is added beside it.**
`accounts_in_use(company, from, to)` answers "which of these accounts is this
company working with", and the answer is read from what the company already
holds rather than kept in a list somebody has to maintain:

- **moved** — the account carries a line of a posted entry. With a period, a
  line dated inside it; without one, ever.
- **referenced** — the configuration of the company names the account by
  foreign key: a role default, a contact override, a journal, a tax posting,
  the transition account of a cash-basis tax, a bank account, a product. A
  configuration reference is not dated, and only the movement is. An account a
  product posts to is in use before anything is booked on it, and stays in use
  in a quarter nothing was booked in.
- **a module** — a module the company has enabled holds it.
- **pinned** — somebody said so.

minus `deprecated`, which is already how a chart retires an account.

**Two alternatives were considered and refused.** A *core plus creation on
demand* — ship thirty accounts and add one when it is needed — would have made
the pack a subset again, and the account somebody needs is exactly the one they
cannot name. *Subsets by activity inside the pack* — a retail set, a services
set — would have put a classification of businesses into a file that is
supposed to hold a chart of accounts, and it would have to be maintained per
country by whoever maintains the pack. Both replace a fact with an opinion. The
fact is in the database already.

**`accounts.pinned` is the column an operator edits**, and
`install_country_template()` pins what it wires: the roles of the country
model, the accounts its financial journals post to, the accounts its taxes book
on, the transition account of a cash-basis tax. That is **eleven accounts on
Belgium, eleven on Estonia, fifteen on France, eleven on Luxembourg** — fewer
than the thirty the first sketch assumed, because the roles and the tax
postings overlap heavily and a country model names about a dozen accounts, not
thirty. It names about a dozen whatever the size of the chart: Estonia's
hundred and twenty accounts and Luxembourg's thousand wire the same eleven.
The union above would have found most of them anyway; what pinning adds is that
the set is written down, so a company that later points a role at a different
account keeps the first one in the list it has been reading for a year.

**Pinning restricts nothing.** A document line takes any account of the chart
that is not deprecated, exactly as before, and every write tool still accepts
one. This is a reading, and the only thing it changes is what is offered first.
A tool that narrowed what may be booked on would be a tool that makes a wrong
entry by being helpful.

**The socle still ignores its modules.** `accounts_in_use()` does not name
`assets` or `budgets`. It asks each module the company has enabled for
`<schema>.accounts_in_use(uuid)` — the convention `disable_module()` already
reads for `<schema>.can_disable(uuid)` — and `to_regprocedure` answers null for
a module that references no account. The dependency keeps pointing one way: a
module reads the socle, the socle asks its modules a question they may decline
to answer.

**What the working chart does not include**, and the reason in each case. The
accounts a pack names for opening and closing — the result of the year, the
accumulated loss — are resolved by `close_fiscal_year()` from the pack at the
moment it runs and are never written onto the company, so nothing points at
them until the first year is closed, and then the movement does. The parent of
a used account is left out: a heading is not an account anybody books on, and
including headings would put the whole hierarchy back. A line of a *draft*
document is left out too, because it would make the period argument useless —
an account named on an undated draft would be in use in every quarter.

`list_accounts` answers with this set, and says in its output which scope it
used, so a model that finds nothing knows there is a wider question to ask.
`include_all` gives the whole chart, `include_deprecated` gives it with the
retired accounts, and `ekwo://companies/{id}/chart` was already the resource
that carries everything.

## A code is frozen by the first line booked on it (14 September 2026)

Every reference to an account inside a company is a foreign key on
`accounts(id)`: the roles of the company, the overrides of a contact, the
journals, the tax postings, the lines of every document and of the ledger, and
the tables of the modules. That was checked, and it held. So renaming an
account breaks nothing, and renumbering one appears to break nothing either —
the keys follow.

**The rules do not follow the key.** A financial statement maps an account to a
line by its code: `statement_line_rules` carries `account_code` rules, and on
the Belgian chart a rubric code *is* a range of codes. A declaration box is
reached through a tax posting whose account the pack named by code.
`account_id_by_code()` is how half the schema finds an account at all. Moving
`700000` to `701000` therefore moves the account to a different line of the
balance sheet or the profit and loss account, and the year already booked on it
moves with it — silently, and in a statement somebody has filed.

`accounts_write` could not have stopped it: a policy judges which rows a caller
may touch and has nothing to say about which column changes. So there is a
trigger, and it raises by name.

- `account_code_frozen` — the code may not change once the account carries a
  line of the ledger, is named by a tax posting, or plays one of the company's
  roles.
- `account_type_frozen` — neither may the type, for the same reason. The
  eighteen types are what put an account on one side of the balance sheet or in
  the income statement, and `internal_group` and `carries_forward` are
  generated from it.

Everything else stays editable at any moment: the label, the translations, the
notes, the parent, `reconcilable`, `deprecated`, `pinned`. Renaming an account
is ordinary work — it is the first thing an operator does to a chart they have
just installed — and `pack_upgrade` does it too when a pack changes a label.

**Deprecating is the way out, and it always was.** An account that was given the
wrong code is deprecated and a new one takes the entries from here on, which is
the same rule that says nothing is ever deleted from a pack: the statements of a
past period have to keep giving the same answer.

One consequence is deliberate. `pack_upgrade(…, apply => true)` now fails by
name rather than moving a used account between statements. That difference was
already classified `review` — the rule that exists precisely because there is no
way to be sure from here which of the two is right — and a refusal is the honest
end of that sentence.

## A sign belongs to a line summed from the ledger (14 September 2026)

A statement line carries `sign: -1` when the scheme prints a credit balance as
a positive figure, and `financial_statement()` applies it when it sums that
line from the ledger. A total is worked out afterwards, from lines that already
read the way the scheme prints them — and the evaluator multiplied the total by
the total's own sign as well. So a scheme that flips a credit line and flips
the subtotal above it got the figure back the way it started, silently. It cost
the Luxembourg pack a wrong set of golden figures, caught by somebody reading
them rather than by any check.

**`ekwo pack check` refuses `sign` on a line with `plus` or `minus`**, next to
the rule that already refuses a line that is both summed and computed. The
explicit `1` is refused too: it changes no figure, and a pack that writes it is
saying something about a total that a total cannot say — the moment to tell its
author is while they are writing the pack, not when a reviewer is checking the
figures.

**The evaluator is not changed, and the option to change it is not left open
either.** "Apply the sign once" has no meaning while every line under the total
carries its own: there is no second application to remove, only a first one on
figures that were already read correctly. The day a country wants a total
presented against the direction of its components, the honest shape is a line
of its own — a total is what the lines add up to, not a place to reverse them —
and `minus` is what expresses the subtraction meanwhile. No pack combined the
two, so the refusal moved no golden figure.

## How often a company files is data, and the return reads it (14 September 2026)

`vat_return()` takes two dates, which is right: a return is a period and the
caller knows which one. What nothing held was how often the company files at
all. Luxembourg sets the cadence by turnover — annual up to 112 000 euros,
quarterly to 620 000, monthly above — and Belgium and France each have a
principal cadence and a threshold below which another is allowed. A quarterly
filer could be handed a July return and nothing anywhere said so.

**Three pieces, each in the place that owns the answer.**
`tax_report_templates.periods` is what the *form* accepts, a list because one
set of boxes may be filed on more than one cadence. `companies.vat_period` is
what *this company* files. `country_defaults.vat_period_default` is what the
*pack* proposes. Splitting it that way is what keeps `vat_return()` free of a
country: the form says what is possible, the company says what is true, and
neither is a constant in a function.

**One vocabulary, not two.** `month`, `quarter`, `year` — an enum now, where
they were three spellings agreed by convention in a check constraint. A second
set of words for the same three facts (`monthly`, `quarterly`) would have been
the same fact written twice, which is the one thing this schema will not do.
`month_or_quarter` was never a cadence anybody files on; it was two of them
pretending to be one, and there was no `month_or_quarter_or_year` to invent
next. It is read as the two it names, so a pack written before the list keeps
working.

**The column default is the part that had to go.** `period` defaulted to
`month_or_quarter`, so a pack that had never considered its cadence filed on
Belgium's and France's, silently, in a column a reader would take for data.
There is no default now, and a form that names none is refused by name.

**A pack proposes a cadence only where the law gives one answer that does not
depend on a fact about the company.** One of the four does. Estonia's taxable
period is the calendar month for everybody, with no option and no threshold
(käibemaksuseadus § 27 lõige 1), so `packs/ee` proposes `month` and a company
installed there never sees the question.
Belgium's law makes the monthly return the rule (Code de la TVA, art. 53, §1er,
alinéa 1er, 2°) and allows the quarterly one below turnover thresholds (AR n. 1,
art. 18, §2); France's is the same shape (CGI, art. 287, 2 — monthly, quarterly
admitted under 4 000 euros of annual tax); Luxembourg's three cadences follow
turnover outright. In those three, which one applies is a fact about the
company and not about the country, so `vat_period_default` is null and each
pack cites the article on its form instead. This is the same argument the language
question settled: offering one of several lawful answers as the one to press
Enter on is how the other one ends up installed. A wrong cadence is a missed
deadline.

**What the return does with it, and what it deliberately does not.** It refuses
a period the company does not file on, and only when the refusal is certain:
the company has recorded a cadence, the form offers that cadence, the dates
asked for are themselves a whole cadence of that form, and the two differ.
Everything else goes through — a fortnight, a half-year, the annual
recapitulative form a quarterly filer also files. `vat_return()` is a control
query as often as it is a filing, and a guard that refused an analysis would be
a guard people work around.

## A document is shared by a link, and the link is the whole secret (15 September 2026)

A customer who receives an invoice wants to look at it, and everything that
would let them is behind row level security: they are not a member of the
company and never will be. The two usual answers are both bad. An account for
somebody who will read one invoice is a login nobody maintains and a password
nobody remembers. A PDF attached to an e-mail is a copy that stops being true
the day the invoice is paid.

**A share is a row and a function.** `document_shares` says that one document
may be read by whoever presents one secret; `shared_document(token)` takes the
secret and returns the document as it was sent, with what is still owed on it
today. The application draws the page; the core answers the question.

**The token is hashed, and 256 bits wide.** Only `sha256(token)` is stored, so
a backup, a replica or a support engineer reading the table hands nobody a live
link — the arrangement `company_invitations` and `api_keys` were already built
on. The width is the answer to "could somebody guess one": at 244 bits of
randomness inside 32 bytes, no. The 244 rather than 256 is where the bytes come
from, and that is the second decision.

**The bytes are two `gen_random_uuid()`, not `gen_random_bytes(32)`.** The
latter is `pgcrypto`, and `pgcrypto` is not available under PGlite, which is
what the whole of `tests/` runs on. An invariant that cannot be tested is an
invariant nobody is keeping, and a token generator that only works on a hosted
project is exactly the kind of difference between "it works here" and "it works
where you run it" this project refuses. `gen_random_uuid()` is core Postgres
and is where every primary key in this schema already comes from; a v4 UUID
fixes six bits for its version and its variant, so two of them are 244 random
bits rendered into 43 base64url characters. `sha256()` is core too, since
PostgreSQL 11.

**`anon` gets one function and not one table.** The doctrine of `20260911210131`
and `20260914151207` is that the anonymous role holds no privilege on any table
or view and reaches only functions that answer about the caller.
`shared_document` is the first function it reaches that is not a policy helper,
and the invariant is kept rather than bent: it is `security definer`, the
visitor has no rights of their own, and what comes out is one document rendered
into one jsonb. There is no view to select from, no filter to widen and no
second row to reach. `tests/hardening.test.ts` and `tests/grants.test.ts` both
assert the list by name, so an eleventh entry is a decision somebody argued for.

**Unknown, withdrawn, expired and no-longer-shareable are the same null.** Four
different refusals would be an oracle: somebody feeding tokens at the function
would learn which of their guesses had been a real link. The function takes the
token and nothing else, so it is an oracle for nothing at all.

**No IP address and no user agent.** `view_count` and `last_viewed_at` answer
the question a sender actually has — did they open it. A log of the people a
company invoices, with where they were when they read the invoice, is personal
data with a retention policy, a lawful basis and a subject-access request
behind it, and the core does not collect what it is not prepared to answer for.
An application that is prepared to keeps its own.

**There is no access code, and the door is left open for one.** A second factor
— a code read out over the phone, the customer's own VAT number, a one-time
password by e-mail — is a useful option and a bad floor: it turns every link
into a conversation, and most invoices go to somebody who is expected to open
them. The day it is wanted it is a column on `document_shares` and a second
argument to `shared_document`, which is why neither is shaped to prevent it.

**Sales only.** A purchase invoice is a third party's own document: their
prices, their bank details, their legal mentions. Publishing it under a link
this company controls would be publishing somebody else's data, and there is no
request behind it — nobody shares a supplier's invoice with the supplier.
`share_not_a_sale` says so by name.

**A share is not edited.** No update policy and no `change_share()`. An expiry
that can move is a lifetime nobody can rely on, and a token that outlives the
decision to withdraw it is the one failure this feature must not have. Revoke
it and make another; there is no un-withdraw, for the reason there is none on a
machine key.

**`subject_kind` exists with one value in it.** A statement of account, an
ageing balance, a financial statement sent to a customer are the same act with
another subject, and the shape that survives the second one is decided now or
paid for later. `document_id` is nullable and tied to the kind by a check, so
the kind that arrives next adds its own column and its own branch of the same
check, and every row written before it keeps meaning what it meant.

**The list of links is row level security, not a function.** `list_shares()`
would have been a fourth function producing a list that a `select` on
`document_shares` already produces correctly, under a policy this schema
already has to write. Two places where the same rule is decided is the one
thing this schema will not do.

**`instance.public_base_url` is nullable and has no default.** A link has to be
absolute, and a self-hosted installation answers at the address its operator
chose. A core that guessed would hand out links to somebody else's host, and no
URL of Ekwo's is written anywhere. Where it is empty, `share_document` returns
the token with a null `url` and the caller builds the link — which is the same
answer `no_currency_default` and the filing cadence give: a value nobody has
stated is null and said to be null, never one country's answer given to
everyone.

## The sources of a pack are a register, not a bibliography (15 September 2026)

`legal_reference` has been required on every tax and every box since the format
existed, and it is half an answer. *Arrêté royal n° 20 du 20 juillet 1970,
tableau A* tells a reviewer what is being claimed and leaves them a search
engine to find out whether it is true. `certification.sources` was the other
half and was not: a list of bare titles, in a manifest, with no link on any of
them.

**A register, and a key on the rule.** Each text is declared once — a key, a
title, the official publisher, an absolute `https` URL and the day somebody
opened it — and every rule names the key of the text its own article is in. The
alternative was a URL on each rule, which would have put the same link on
thirty-one Belgian boxes and made a publisher's site reorganisation a sweep
across four files. The article is the claim and belongs where the claim is; the
link is where a text lives and changes on the publisher's schedule, not on the
pack's.

**The publisher is a field, not part of the title.** A link says where
something is served and not who stands behind it, and those come apart exactly
when it matters: a mirror, a commentary, a law firm's copy of a statute all
resolve. A reviewer checks the publisher first, so the pack says it in a column
rather than hoping the hostname does.

**Six kinds, closed.** `law`, `regulation`, `form`, `standard`, `portal`,
`guidance`. A register that is readable across countries is worth more than one
that lets each pack invent its own words for the same six things, and the split
that earns its keep is `law` against `form`: the rate comes from a statute and
the box comes from a form, and in three of the four packs here they are
different documents published by different administrations.

**A portal is in the register although it is not a legal source.** Whoever
installs a pack needs to know where the return is filed, and the register is
the one place in a pack where they will look for it. It is also the thing a new
contributor is least likely to write down and most likely to need.

**Nothing is copied.** No pack holds a sentence of the law it transcribes. A
quotation ages without anybody noticing and would make a country pack a second,
unversioned edition of a statute — which is the failure mode this repository
avoids everywhere else by deriving rather than restating.

**The register is what a reviewed pack is refused for leaving out.** A
professional who reads a pack against the law reads something, and a status
that let them leave that unsaid would be a signature rather than a review. So
`reviewed` requires a source on every tax and every box; `maintained` warns,
because the register arrived after four packs did and a missing link is a link
that is missing, never a figure that is wrong; `community` asks nothing, which
is what `community` means.

**Following the links is not a check.** `ekwo pack check --links` exists and
the CI will never run it. Légifrance answers `403` to anything without a
browser behind it — all four of its entries here do — Riigi Teataja serves the
same page for a text and for a typo, and a ministry moves a form the week
before a deadline. A gate on any of that fails a contributor's pull request for
something nobody in it did, and the cheapest way to make it green is to delete
the link, which is the opposite of what the register is for. It reports a
reading. A maintainer decides.

## A price that already holds its tax (15 September 2026)

`taxes.price_include` had been a column since the tax engine landed and was
read by nothing. A retail price in the United Kingdom, in Australia and in
almost anything sold to a consumer is quoted with the tax already in it, and a
line carrying such a tax was booked with the tax added *on top* of the price
the customer had paid.

**The group is the unit of the conversion, not the line.** For every tax group
of a document quoted gross, the tax is `round(gross - gross / (1 + rate/100))`
— rounded once, at the decimals of the document's currency, by the method of
its country — and the base is the gross less that tax. EN 16931 BR-CO-14 asks
for exactly that one rounding per group, and HMRC's VAT Notice 700 admits it to
a retailer in §§ 17.5 and 17.6 as the invoice-by-invoice method, beside a
line-by-line one. Nothing here invents a word for the choice between them:
`rounding_method` is the *arithmetic* of a country and not the unit the
arithmetic is applied to, and a pack declaring "per line" would be declaring an
invoice that fails validation. Where a country really does let a trader choose,
that is a gap, and `docs/international.md` is where it is written down.

**The base is subtracted, never computed.** `gross x 100 / (100 + rate)`
rounded on its own, beside a tax rounded on its own, misses the gross by a unit
about one price in fifty at 20 %. Subtracting makes `base + tax = gross` true by
construction, which is the one thing a customer holding the receipt can check.

**And the tax is never re-derived from the base.** The breakdown used to
compute every group's tax as `round(base x rate / 100)`. Applied to a base that
came out of the subtraction, that is not always the tax that produced it: 99,99
at 20 % gives a tax of 16,67 and a base of 83,32, and 83,32 at 20 % rounds back
to 16,66 — a total of 99,98 against a price of 99,99. So `document_tax_summary`
computes an inclusive group's tax from the gross it was quoted at, and every
other group exactly as before. No figure of any pack that prices without the
tax moves by a cent.

**The base is shared over the lines, and the last one takes the remainder.**
The same technique `post_document` uses to share a `tax_on_base` over the
accounts it lands on, for the same reason: the shares have to add up to the
figure that was rounded once. `document_lines.amount_untaxed` stays the truth
and stays derived — its `before` trigger writes what one line on its own comes
to, which is the whole answer when the group has one line, and the `after`
trigger that refreshes the document's totals replaces it with the line's share.

**The line keeps the gross and the flag.** `amount_incl_tax` is the price as it
was quoted, which is the only figure a retailer recognises and the only one the
conversion can be redone from; `unit_price_includes_tax` is a snapshot taken
from the tax while the document is a draft and frozen when it is posted, the
rule BT-151 and BT-152 already follow. A pack upgrade that turns the flag on a
tax must not rewrite an invoice somebody has already sent.

**`unit_price` is the price as it was keyed, and that is no longer BT-146.**
`document_line_items` publishes the flag and the gross beside the base, and
`shared_document()` carries both into the payload behind a link — it names every
field of a line by hand, so a column added to the view does not reach it on its
own, and a customer opening a retail invoice would otherwise have been shown a
gross price beside a net line amount with nothing saying which is which. Neither
publishes the net unit price. The honest definition is
the base divided by the quantity — the only one that keeps BR-CO-10, quantity
times BT-146 equals BT-131, true after the group's remainder has landed on a
line — and writing it needs the precision of the *price* column rather than the
currency's, which `round_amount` does not express and a cast would smuggle past
the one place decimals are decided. It is a gap, and `docs/international.md`
carries it rather than an exception to the rounding rule.

**Three refusals, each as early as it can be made.** A fixed-amount tax cannot
price with the tax in it, because there is no rate to divide by: a check
constraint on `taxes` and on `tax_templates`, and `ekwo pack check` before a
seed is written. A line whose price includes a tax has to name one: a check
constraint. And a tax group cannot be half inclusive — the only way to build
one is to change the tax between two line writes of the same draft —
`mixed_price_include` says so where it happens rather than letting the document
be posted with a gross line added to a net one.

**What still rounds at two decimals.** `document_lines.amount_untaxed` and
`amount_incl_tax` are `numeric(16, 2)` like every other monetary column here,
so a currency with three decimals loses the third on the way into the column
rather than in the rule. That gap is named above and in
`tests/currency_rounding.test.ts`, and it is why the three-decimal case is
asserted on the figure the view computes and not on the one the column stores.
## A posting names its boxes, and a list is not a table (15 September 2026)

A tax carries one `base` posting per kind of document. That rule is what keeps
a taxable amount from having two definitions, and it is not what is being
relaxed here. What it could not express is a form that prints one amount in
boxes **no total can derive from one another** — and two of the four packs
that carry a periodic return meet it.

Form KMD reports an intra-Community acquisition of goods in box 6.1, in box 6
around it and in box 1 around that. Box 6 looks like a sum of what is printed
under it, and it is not: the rest of box 6 is services received from another
Member State, which the form never prints on its own. The British VAT Return
does the same thing sideways, with the value of a service received from a
supplier established abroad in box 6, which is outputs, and in box 7, which is
inputs. Until now each pack invented a leaf box, marked it `hidden`, posted
there and rebuilt every printed parent as a total: six such boxes on a form of
thirty, three on a form of nine. Both were exact and both were a reader's
problem.

**A posting names a list of boxes.** `box` in `taxes.json` takes a string or a
list of strings; the amount is written to each, with the same `box_factor`,
because a form that prints one figure in three places prints the same figure in
all three. Nine hidden boxes disappeared and not one golden figure moved.

**A `text[]` beside the column, not a junction table, and not a posting per
box.** Three shapes were on the table.

*A posting per box* was rejected first, and it is the one worth being explicit
about, because it looks like the tidy answer. Two base postings are two
definitions of one taxable amount, kept in step by whoever reads the pack next;
`ekwo pack check` refuses them, and that refusal is load-bearing. A variant —
a new posting type that reports to a box and writes nothing to the ledger —
would have been worse in a quieter way: it puts a row on the *ledger* side of
the format for something that is not a ledger fact at all.

*A junction table* is the answer a schema review gives, and it is the right one
when the rows have an identity. These do not. A posting has no identity of its
own in this schema — `pack upgrade` compares the postings of a tax as one
object and replaces them all when anything differs, because "this tax now books
its non-deductible share somewhere else" is one fact and not four — so the rows
of a junction would carry a primary key nothing ever names. Against that: a
table is a policy, a grant, an inventory entry, a cascade and a second order to
keep, for a list that is one element long in four hundred and forty of the four
hundred and sixty-six postings of these five packs that name a box at all.

*An array* is what was built. `vat_return()` reads it with one `unnest` where a
junction is a join, and the expansion stays where it belongs — in the return,
not in the books. The ledger still gets one line per posting, carrying one box.

**`declaration_box` stays, and stays first.** It is what a posting is known by,
what a line is read back on, and what every reader written before this change
still sees. A check constraint holds `declaration_boxes[1] = declaration_box`,
and a trigger fills whichever of the two a writer did not give — read from what
*moved*, never from what is null, because a trigger that took `declaration_box
is null` to mean "say nothing" would put the box back from the list and quietly
undo a write that cleared it.

**Duplicates are refused by `ekwo pack check` and not by the database.** A
check constraint cannot hold a subquery, and there is no way to say "this array
has no repeated element" without one. A duplicate changes no figure that a
constraint could protect — `unnest` would add the same line to the same box
twice, which is a defect in the pack — so it is refused at the moment somebody
is writing the pack, which is where every other pack rule is refused.

**What a `hidden` box means now.** One thing: an intermediate `total` the form
works out inside a formula and does not print, which is what Belgium's two are.
A hidden box a posting writes into was the workaround, and a test refuses one.

## A box may be a rate of a box, and print order is not evaluation order (16 September 2026)

Two changes that turned out to be one. Both come from the sixth pack, and
neither was made for it.

**A rate is not an expression.** A computed box was a list of boxes to add and
a list to subtract, and that covered five packs because a European return
reports a tax the ledger already worked out, document by document. CDTFA-401-A
does not: it works the taxable total out for the period, on line 12, and then
says *multiply line 12 by 0.06*, *by 0.0025*, *by 0.01*. There is nothing to
add up. The pack's answer until now was to apportion — one `tax` posting per
line of the form, each carrying the share its rate is of the combined rate, the
last one taking the remainder — which agreed with the form to the cent in all
three quarters of the golden year and was never promised to, because the form
multiplies once and the apportionment shares a figure that was rounded document
by document.

The field is `rate`, a percentage, with `rate_of`, the one box it applies to,
resolved exactly as a `plus` reference is. Two named fields, closed vocabulary,
nothing to parse, nothing a pack could execute; a reviewer reads *six per cent
of line 12* in the diff and can check it against the instruction. The
alternative was an expression language, which is what `20260912090407` refused
and what this deliberately does not reopen: a rate is the **one** arithmetic a
declaration form actually writes out in words, and a second shape for the one
case that exists is not the first step of a syntax.

Three rules keep it that way, all of them constraints: only a computed box
carries a rate, a box is a list or a rate and never both, and the percentage and
the box it applies to are declared together. `evaluate_totals()` — still the
one evaluator, still shared with the financial statements — treats the rate's
reference exactly as it treats a member of a plus list, so a rate is worked out
when its source has been and a cycle is `formula_cycle` rather than a loop.

**And a total is a `total`, whatever the form calls the line.** Line 13 prints
as a tax and the pack declares it `kind: "total"`, which moved three keys of the
American golden from `13:tax` to `13:total` and not one cent of any figure.
`kind` says how a box gets its amount — the ledger fills a `base` or a `tax`,
the form works out a `total` — and letting a `tax` box carry a formula would
have made `kind` mean two things at once and put two sources on one key. What
the line *is* on the form is said by its name and its legal reference.

**Print order and evaluation order stop being one field.** `sequence` had meant
both since the boxes became data, and three packs paid for it: every eCDF
subtotal prints above what it adds, Estonia's box 1 escaped by luck, and
CDTFA-401-A prints line 11 on page one and computes it from page three. The
evaluation half had already been fiction since `20260912104719`, when
`evaluate_totals()` started resolving by dependency; what held the conflation in
place was one rule in `ekwo pack check` refusing a total that named a total
declared after it, which forced a pack to spend its only ordering field on the
evaluator. That rule is gone, replaced by the cycle check the statements have
always had, which names the boxes. `print_sequence` is optional on a box and
means `sequence` where it is left out, so no pack written before this changes,
and `vat_return()` answers the resolved value beside `sequence` so a renderer
orders by one column and never two.

The two changes are one because the first forces the second: a box worked out
from another box carries a dependency the administration's print order knows
nothing about, and a pack cannot be asked which of the two it would rather
write down.
## A tax follows the territory of the parties (16 September 2026)

Two packs stopped at the same wall from opposite sides. `packs/gb/` cannot
carry the Northern Ireland taxes, because a company in Manchester would be
offered them; `packs/us/` offers a Californian company the New York and the
Oregon codes, because `jurisdiction` is a label on the tax that nothing reads.
Both notes in [`international.md`](international.md) proposed the same fix in
the same words — *let a tax name a territory, and let a party record the one it
is in* — and the American one added the half the British one did not need: a
sale is taxed where the goods are delivered, so the tax follows the **buyer**
and not only the seller.

The fix is two questions, and the second is worthless without a good answer to
the first.

### Where a party's territory comes from

A company and a contact each carry a country. A country is not a territory: the
tax that matters here is levied by California and not by the United States, and
Northern Ireland is not spelled `GB-NI` in any register the Union uses — it is
`XI`, a code of the Union's own systems with no parent in ISO 3166-2 at all. So
a territory cannot be composed out of the two columns that exist.

It was tried. `companies.region` holds `CA`, `fiscal_country` holds `US`, and
`fiscal_country || '-' || region` reaches `US-CA` and never reaches `XI`. A
rule with one exception written into it is a rule that will collect the second
exception silently. And `region` is documented as ISO 3166-2 *without* the
prefix, for a Canadian pack that will want to ask "which province" as a
question with a short list of answers — which is a different question from
"which body of tax law is this party under".

**So a territory is a column of its own, and it is a key of `territories`.**
Four of them:

| Column | Says |
|---|---|
| `companies.territory_code` | where this company is established for tax |
| `contacts.territory_code` | where this party is |
| `documents.supply_territory_code` | where the supply takes place |
| `taxes.applies_*_territory` | where each party has to be for this tax to apply |

All four are foreign keys to `territories(code)`, which is what makes them
reviewable: a code nobody can look up is a string, and a string is what
`jurisdiction` has been since the day it was added.

**Null is the ordinary case and it resolves rather than refuses.** A Belgian
company will never set `territory_code`, and asking every installation in
Europe to answer a question the common system does not pose would be the
country-default mistake with the sign flipped. So each of the three party
territories has a ladder, and every rung of it is a fact somebody already
recorded:

- **The seller and the buyer** are the company on one side and the contact on
  the other, decided by the kind of document and never by the row: on a sale
  the company is the seller, on a purchase it is the buyer. Each resolves to
  its own `territory_code`, and failing that to its country —
  `companies.fiscal_country`, which is the country whose rules the company
  files under, and `contacts.country`.
- **The supply** is `documents.supply_territory_code`, failing that
  `documents.delivery_country` — BG-15 of EN 16931, which `documents` has
  carried since the day it existed and which is exactly the statement that the
  place of delivery is not the billing address — and failing that the
  **buyer's** territory, because a supply nobody said anything else about is
  delivered to the person who bought it.

The last rung is the one worth arguing about, and the argument is that the
alternative is worse. A supply with no delivery address is not an unknown
place; it is the ordinary case of a seller and a buyer in one room, and
refusing to post it would refuse every invoice in Belgium the day a pack there
conditioned one tax on a territory. What is refused is the case where the
ladder runs out — a contact with no country and no territory, on a document
with no delivery address, carrying a tax that asks where the supply was. Then
`post_document()` raises `no_party_territory` and names the party, the tax and
the column that would answer, which is the rule `CONTRIBUTING.md` states as
*raise, do not warn*.

### What a tax may say about it

`applies_when` on a tax, and it is a closed vocabulary in the same sense the
mentions' `applies_when` is one — three keys, each naming one territory:

```json
{ "code": "US-CA-S-725", "rate": 7.25, "scope": "sale",
  "applies_when": { "seller_in": "US-CA", "supply_in": "US-CA" } }
```

Every key present has to hold. There is no operator, no negation, no
disjunction and no nesting: what a pack can say is that a party is in a place,
and the only arithmetic anywhere near it is the one `valid_from` and `valid_to`
already do with dates. A reviewer reads two lines and knows which sales the
code is for.

**A condition is satisfied by the territory named and by every territory inside
it.** `territories.parent_code` already draws that tree — `XI` hangs off `GB`,
`ES-CE` off `ES` — so `seller_in: "GB"` covers a seller in Northern Ireland and
`seller_in: "XI"` does not cover a seller in Great Britain. This is what lets
one country's pack carry two sets of taxes: the British VAT codes say nothing
and reach everybody, the Northern Irish ones say `XI` and reach only a company
that recorded it.

Three shapes were weighed against it.

*A list of conditions* — `[{party, territory}, …]` — reads better in a schema
and is the beginning of an expression language. The moment a list exists,
somebody wants two entries for one party, and two entries for one party is a
disjunction with no word for itself. Three keys cannot grow an operator without
a migration and a review, which is the property the format is built on.

*Reusing `jurisdiction`* was tempting, because for the Californian sales tax
the levying state and the required place of supply are the same string.
They are not the same fact. `jurisdiction` says who levies the tax and belongs
on the invoice and in a report; `applies_when` says when the tax can be
reached, and for `US-P-0` — a purchase not subject to sales tax — the two
would have to disagree. They stay separate, and `ekwo pack check` now asks that
a `jurisdiction`, where a pack gives one, name a territory the table carries —
the field has been a free string with no reader since it was added, which is
exactly the state a second pack spelling the same state differently would never
be caught in.

*A rule table* — `tax_rule_templates` and a `suggest_tax()` — is phase 1 and is
still phase 1. It answers a different question: *which tax should this line
carry*. The core deliberately chooses no tax for anyone, in any country, and
nothing here changes that. What the core may do is refuse a tax that cannot
apply, which is the difference between an assistant and an authority.

### What the engine does with it

`post_document()` resolves the three party territories once per document and
refuses a tax whose conditions the document contradicts:

```
tax_territory_mismatch: tax US-CA-S-725 applies where the supply is in US-CA;
on this document the supply is in US-NY
```

It does not choose, substitute or suggest. A bookkeeper who picks the
California code on a delivery to New York is told, by name, on the document,
before anything reaches the ledger — which is the first time in this repository
that a tax code and a place have ever been compared.

`ekwo pack check` reads the same conditions from the other end, and one of its
refusals moved because of them. Whether the VATEX list of EN 16931 reaches a
tax was a question about the pack's country; it is now a question about the
territory the tax applies in, where the tax names one. That is what makes
Northern Ireland expressible: `eu_vat_scope` of `XI` is `goods`, so a tax
applying in `XI` is inside the common system exactly where its treatment is a
supply or an acquisition of **goods**, and outside it everywhere else — which
is the Protocol on Ireland/Northern Ireland written as a check rather than as a
paragraph of a README.

### What this does not reach

**The New York tax still joins no box.** It can now be attached to `US-NY` and
refused on a Californian delivery, which is what was asked of this change. It
cannot be *declared*, because `packs/us/` carries one declaration form and that
form is California's. A list of forms per pack, each naming the territory it
belongs to, is the fix `international.md` proposes and it is not this one.

**A supply outside the taxing territory has no word of its own.** `applies_when`
names a place a party is in and cannot name a place a party is *not* in, which
is what `US-CA-S-SHIPPED` — a sale the contract requires to be shipped out of
California — would need. A fourth key, `supply_outside`, is the obvious shape
and is deliberately not added: nothing in this repository would read it yet,
and the gap it belongs to is the missing `treatment`, not the missing
condition. What this change gives that work is its anchor — a tax now names the
territory that levies it and a document now names the territory of the supply,
so a treatment that says "outside the taxing territory" finally has two things
to be checked against.

**Nexus and resale certificates are untouched**, as `international.md` says
they must be: whether a seller must collect in a state is a running total
nobody keeps here, and whether a buyer handed over a certificate is a document
nobody files here. A territory condition says which taxes *exist* for a party.
It does not say which one is right.

## Recognising a counterparty, and what teaches it (17 September 2026)

The schema could record that a statement line belongs to a contact and had
nowhere to record **how that was known**, so the same decision was made again
every month. `contact_patterns` is that memory, and three choices in it are
worth writing down.

**The vocabulary is closed and the values are learned.** Four kinds — an
account, a spelling of a name, a word of the description, a band of amounts —
and a fifth needs a migration. Nothing stored is executed: no regular
expression, no expression language, no threshold written beside a rule. This is
the same invariant the packs are held to, applied to something a *user*
produces rather than a contributor, which is the case where it matters most.

**Ambiguity replaces a stop list.** Comparing two names needs a way to ignore
`sarl`, `bvba`, `gmbh`, `llc` — and such a list is country data, which the core
does not carry. So the rule is the count instead: `suggest_contacts()` says how
many contacts each piece of evidence reached, and evidence that reached two
contacts is evidence of nothing. It is strictly better than the list it
replaces, because it also catches the words a list forgets — a town, a trade,
the name of a group — and it adapts to the company rather than to the language.

**Being wrong has to cost something.** `confirm_contact()` charges a use
without a success to every motif that named somebody else. A learning system
that only records its successes is a system that never unlearns: after enough
months every motif is certain and the earliest mistake outranks the correction.
The confidence is the two counters and nothing else — `(success + 1) / (usage +
2)`, the smoothing making an unused motif worth half rather than worth
everything after one lucky match.

**And the numbers are data.** Five of them, in `matching_settings`, per
company, null meaning the shipped answer. Each is a number the production this
design comes from carries as a literal, moved to the one place a company can
disagree without forking. A tolerance is expressed in **units of the currency's smallest
denomination** rather than in cents, because `round_amount` and
`currencies.decimal_places` already say that a cent is a fact about the euro.

**What this does not do, and must not.** Knowing who the money came from is not
knowing what it pays. `confirm_contact()` writes a contact, never a matching,
never a paid invoice — the distinction between `matched` and `validated`, and
the one whose loss marks an invoice paid that nobody paid.
Reconciling a payment against a document is the next piece of work.

## Settling a statement line: what is applied and what is only offered (17 September 2026)

Recognising a counterparty misfiles a line when it is wrong. Settling misstates
a debt: it marks an invoice paid that nobody paid, and the error is invisible
because the books balance either way. So the two halves of the matching are
held to different standards, and the line between them is written here.

**Applied: identification.** A reference the statement carries, or an amount
that matches exactly one open item inside the company's own window and
tolerance. In both cases a single piece of evidence points at a single thing.

**Offered, never applied: resemblance.** A subset of invoices that adds up to
the transaction is the ordinary shape of a customer paying a month at once, and
the greedy oldest-first walk finds it — deterministically, the same answer every
time. What it cannot do is prove that no other subset also adds up. The
production this design comes from applies combinations at two units of
tolerance and is right often enough to make this tempting; the reason not to is
that a wrong combination is the one mistake the ledger cannot show you
afterwards. Both sides balance, both documents are marked paid, and the
discovery happens months later when a customer disputes an invoice that was
never actually settled.

**Never automatic: a partial payment.** Less money than is open is a deposit, a
discount, a short payment or an error — four accounting treatments, and nothing
in the books distinguishes them. The machine proposes and a person decides,
which is the same rule as the tax the core refuses to choose for anybody.

**Never a settlement at all: an internal transfer.** Money moving between two
accounts of the same company settles nothing, and left unnamed it gets matched
to whatever invoice happens to carry the same amount. It is recognised by the
counterparty account being one of the company's own, named, and left.

**And a statement line becomes a payment, not an entry.** The alternative — a
function writing the ledger directly from a statement — would be a second way
of booking money, with its own idea of the counterpart account, the journal and
the currency. `post_payment()` and `reconcile()` already do the accounting;
this only decides what to hand them.

## Where the second incident is kept, and a comment that named one file (17 September 2026)

`20260917090000_a_counterparty_that_learns` says, in its header, that it
carries **two** incidents of the production this design comes from as tests,
and that both are in `tests/contact_matching.test.ts`. When it was written only
one of them was: the name matched on five characters, which made `SARL` equal
to `SASU`.

The second is now written, and it could not live in that file. It is about the
pass over a period — a hard-coded upper bound on the date sent a whole year of
statement lines past the matching in silence — so it belongs beside
`auto_settle()`, in `tests/statement_settlement.test.ts`, under *nothing is
skipped in silence*. What it pins is not that the window is a parameter, which
is necessary and not sufficient, but that **every line inside the window comes
back with an action and a reason**, even when the answer is that nothing
matches. Silence is not a possible output.

The migration's comment is not corrected, and that is the rule rather than an
oversight: a published migration is never edited, including its prose, because
it has run on databases we do not control and a file that changes after the
fact is no longer the thing that ran. This entry is where the record is put
straight.

## A filed declaration is frozen, and a nil one is still a declaration (17 September 2026)

**The figures are kept, not recomputed.** Everything else in this schema is
derived on demand — a trial balance, an aged balance, a VAT return — and that
is the right default: one source, no copies to drift. A filed declaration is
the exception, and the reason is that it has left the building. The
administration holds a set of figures; the ledger will hold different ones the
moment anything is posted into the period; and without the freeze the database
cannot say which were sent. A copy that exists **because the original went
somewhere else** is not a duplicate of the truth, it is the record of what was
claimed.

**Box by box, in rows.** A JSON snapshot would have been less code and would
have made the filed figures the only numbers here nobody can query — no sum, no
comparison between periods, no join to the form. A box is already an object of
this schema; a filed box is one too.

**A nil return is a return.** The first version refused to file a declaration
with no lines, which reads as a sensible guard and is wrong: a period where
nothing happened still has to be declared in most countries, and the fine is
for not filing it. What is checked instead is that the figures were *computed*
— `prepared_at` — which is a different question from whether there are any.
A test keeps it.

**Frozen by the database.** The trigger refuses a change to the figures of a
declaration that has gone, rather than a convention that nobody should. This is
the one property the whole table exists for, so it is not left to discipline.

**A corrective never overwrites.** The filing that went becomes `superseded`
and the new one points at it. Administrations differ on what a corrective *is*
— a full replacement, an adjustment on the next period, a threshold below which
nothing is done — and that is pack data nobody has written yet. What does not
differ is that the first declaration was really sent.

## A deadline is a rule of the country, and a null is an answer (17 September 2026)

**The date is pack data.** It could have been a function with a `case` on the
country — twenty lines, no migration, and the exact mistake this repository was
built to stop making. A deadline is a rule of a country, it changes when that
country changes it, and it belongs beside the form it applies to, with the
article that sets it.

**Two shapes, and the third is a gap rather than an operator.** A fixed day of
the month that follows, or the last day of it, plus an optional number of days
for an administration that grants an extension. That covers four of the six
packs. It does not cover France, whose dates are assigned from the taxpayer's
identification number and legal form — and the answer there is that the pack
says nothing and the function returns null. A null that means *this country
does not publish a rule of this shape* is worth more than a date that is right
for one filer in ten, and it is visible in `upcoming_filings()`, which lists
the period with no date rather than hiding it.

**The extension is stated where it usually applies, and the exception is
named.** The United Kingdom's seven days do not reach a business on annual
accounting or payments on account. The pack carries the seven days, because
that is the ordinary case, and says the exception in the reference — because
nothing in this schema records which scheme a company is in, and pretending
otherwise would make the wrong date look authoritative.

**No working-day shift.** Moving a deadline to the next working day needs a
calendar of public holidays, which is national, sometimes regional, and
amended by law. No pack carries one, none should invent one, and a date that
lands on a Sunday is a visible gap rather than a silent error.

## What a declaration owes, and where it lands (17 September 2026)

**The accounts are roles of the pack.** Where the net of a declared period goes
is a fact about a chart of accounts, so `tax_payable` and `tax_receivable` sit
with `rounding` and `retained_earnings`, and a pack that names neither gets a
refusal that says which role to set. Three packs name them today. Belgium and
Estonia do not, and the reason is worth keeping: their charts post the taxes
themselves on the account the role would want, so naming one there means adding
a control account to a national chart — a change to those packs, made with
their own goldens, rather than a line of code that assumes it.

**It settles the ledger, not the boxes.** The lines cleared are the ones the
return read — same window, same tax-point rule — and the figure carried to the
debt is what those lines sum to, not what the frozen boxes say. The two can
differ, and `filing_drift()` is the function that says so. An account invented
here to absorb the difference would hide exactly what the freeze exists to
show.

**A credit has two outcomes and no default.** Carried forward it is absorbed by
the next declaration; claimed back it is a receivable somebody is waiting on.
Administrations ask, some make the answer conditional on an amount, and the
choice belongs to the company — so `settle_filing()` refuses a credit until it
is told, and records what it was told.

**The administration is a third party like any other.** Naming it as the
contact of the settlement is what lets the payment match by itself, and it only
works if that contact's account is the one the pack names — otherwise the
payment lands in the payables and the debt stays open for ever. That is checked
when the entry is written, where the sentence can still name what to change,
rather than discovered later as a line nobody reconciled.

**A late entry in a settled period is not picked up.** It falls inside the
window of a declaration that has gone. Its treatment is a corrective, and a
corrective supersedes the filing and settles the difference — which is D5, and
is not this.

**No rounding of the debt.** Some administrations claim whole units and carry
the fraction forward. That is a rule of a country and no pack carries it, so
nothing here rounds: the debt is the sum of the lines, to the cent.

## Two things the test found (17 September 2026)

**A box is a number and a kind.** `tax_filing_boxes` was keyed on the box
alone. That is right on a form that prints a base and a tax on separate lines,
and it is a unique-constraint violation on the French CA3, where line 08 prints
both — so preparing a French declaration failed outright. The key carries the
kind now, and so does `filing_drift()`. The lesson is older than this table: a
key that works in the country you wrote it in is a key you have not tested.

**A pass must not die on one line.** `auto_settle()` called
`settle_from_statement()`, which refuses an open item that names nobody — a
payment is made to or by somebody — and the exception walked straight out of
the pass, rolling back everything already settled and reporting nothing at all.
The refusal was right; what it did to the run was not. It is caught now,
reported against its line in the database's own words, and the walk continues.
The rule it serves is the one written the day before: a report has a row for
every line of the window, because silence is not an available answer.

## Signalled, not refused — and the lock that has to come last (17 September 2026)

**An entry in a declared period is ordinary.** Invoices arrive late, adjustments
are made, corrections land. Refusing them would be refusing bookkeeping, and a
product that refuses bookkeeping gets worked around. What the schema owes is
that none of it is invisible: `filings_touched_since()` lists the declarations
that have gone and whose period moved afterwards.

**Listed on the entry, not on the difference.** An entry whose amounts net to
nothing in every box is still an entry somebody posted into a period that had
been declared, and it is worth seeing. `filing_drift()` answers the other
question — how much the figures moved — and the two are kept apart on purpose.

**One test of what concerns a declaration.** A line that names a box, which is
the same test the tax lock uses. Two readings of "an entry that concerns the
declaration" would drift apart, and a payroll entry landing in a declared
quarter is not news. It also leaves the settlement out, which names no box.

**The lock is its own function, and the test is why.** It was a flag on
`file_filing()` first, which reads well and is wrong: `post_entry()` checks the
tax lock for every entry it posts, so locking at the moment of filing locks the
declaration's own settlement out of its period — permanently. The order the
work actually has is file, hear back, settle, then shut, and
`lock_filed_period()` refuses while there are still tax accounts to clear
rather than letting somebody close a door on themselves.

**A corrective settles the difference.** The period was cleared once; clearing
it again would book the debt twice. `filing_tax_movements()` nets the window
against the settlement entries of the declarations that came before it on the
same period, restricted to the accounts the window itself moved — which is what
leaves out their counterpart line on the debt account. Nothing moved, nothing
to settle, and the refusal says so.

**What a country does with a correction is not modelled.** A replacement
return, an adjustment carried on the next period, a threshold below which
nothing is filed at all: three different mechanisms, none of them universal,
and the texts have not been read. `supersede_filing()` does the one thing that
is true everywhere — what was sent stays sent, and the new declaration points
at it.

## The file a declaration is deposited as (18 September 2026)

**A brick per format, and the first one for a periodic return.** Seven bricks
existed and none of them wrote the declaration a company actually files. The
new one is Belgian in what it writes and not in how it is organised: it is
named after the document — `VATConsignment` — the way `intra-consignment` is,
and a second country depositing the same shape would name the same brick.

**Its input is the freeze, not a computation.** `generateVatConsignment()`
takes `tax_filing_boxes` — the figures as they were filed — because what is
deposited has to be what the declaration says. A brick that recomputed from the
ledger would drift from the filing it is meant to carry, which is exactly the
failure D1 exists to prevent.

**One value per grid, and the refusal that says so.** This form gives every
grid a single figure. A form that prints a base and a tax on one line has no
representation here, so the same grid twice comes back as a violation rather
than one of the two being dropped. That is a fact about this file, not a defect
in the figures — and it is the mirror of the key that was wrong on
`tax_filing_boxes` yesterday.

**Nothing is invented to satisfy a validator.** The production this design
comes from defaults an absent telephone number to a made-up one so the schema
is happy. A made-up number travels to an administration as a number. Here an
absent field is an absent element, and where the schema turns out to require
one, the answer is to let the caller supply it.

**The XSD was not read offline**, and the README says so. The structure is the
one a filing service writes and Intervat accepts; validating an instance
against the published schema, inside the brick's own tests, is what it needs
next and is written down rather than implied.

**A form names its file.** `tax_report_templates.file_format` holds the name of
the brick, not of the country, and null is the ordinary answer: most forms have
no brick, and filing by hand on a portal is how that is done. The guard that
refuses a pack naming a format nobody can write belongs with the one owed to
`bank_statement_formats` and `payment_formats` — one guard over the three.

## A deposit is an event, and a rejection is not a correction (18 September 2026)

**Rejected is a state you send again from.** The schema treated a refusal as an
end state: `file_filing()` took drafts only, so the sole way out of a rejected
declaration was `supersede_filing()`. That is wrong in the one way that
matters — a corrective replaces what an administration holds, and a refused
declaration is not held by anybody. Now a rejection is answered by sending
again, and each send is a row.

**Sending is operated; what comes back is not.** The credentials, the
certificate, the portal session and the person answerable when a return is late
stay in `ee/`. The deposit number, the acknowledgement, the sentence the
administration wrote and the file that went are the company's proof that it
filed, and they live in its own database under the same policies as its books.
Stopping the subscription must not take the proof with it.

**Two words for the channel, and no list of providers.** `portal` is a person
uploading the file themselves — complete, free, and how most installations will
do it. `service` is a transmission somebody holds, whose name is text. A closed
list of providers in the core is the coupling this project refuses: one
interface, one provider at a time, and the core never knows which.

**The answer is written on the send it answers.** A declaration sent three
times has three references and up to three refusals, and reading the last one
off the declaration would lose the first two. The state on `tax_filings` stays
the current one, because that is the question everybody asks; the history is
the deposits.

**Reopening is safe because the sends are kept.** `reopen_filing()` empties
`filed_at` and the reference — the schema's own rule that a draft carries no
filing date — and nothing is lost, because the refused send is a row. Archiving
the file that went is what makes it lossless; the core cannot impose that, so
it makes it possible, names the column, and says so.

## How far a pack got is the assertion (18 September 2026)

**A test that measures instead of failing.** Six packs declare a form. One
names a file a brick can write, three name the account a return settles to,
none does both. A test that required the whole chain would be red for every
pack; a test that checked only what each pack happens to do would prove
nothing about the repository. So each pack walks as far as it can, the steps it
cannot take are skipped **by reading the pack** and not by naming it, and the
last block refuses a checkout where nobody can do each of the three.

**The number is printed.** `be: freezes, writes a file, no settlement` is worth
more in a CI log than a green tick, because it is what changes when somebody
adds a brick or a role — and it is the honest answer to "does this country
file?".

**One reading, two readers.** `filingReadiness()` answers five questions from
the pack, and both `ekwo pack list` and the end-to-end test read it. It holds
no list of formats on purpose: whether a brick exists is proved by writing the
file, and a list in the CLI would be a second place a country model lives.

## Reading the schema, and what it cost not to (18 September 2026)

**A production that files is evidence, not proof.** The first version of the
Belgian return brick reproduced the structure of a service that really deposits
on Intervat, and its README said plainly that the XSD had not been read. Both
statements were true, and the brick was still wrong four times: a nil return
was invalid, a required element was optional, negative amounts went through,
and any two digits passed for a grid. The production never hit them because it
never filed a nil return, always sent the element, and never had a negative
grid. **What a working system does not do is not visible in what it does.**

**The schemas are fixtures, not dependencies.** Five files, unmodified, under
the brick's `test/xsd/` with where each came from and when. The package ships
none of them and reads none at runtime; `xmllint-wasm` is a development
dependency, so validation runs on a laptop and in the CI with no network and no
system tool, and the published package still depends on nothing.

**A violation is something the schema would have refused.** The test puts each
one back into the file and watches validation fail. That is the line between a
rule of the format and an opinion of the package, and it keeps the list honest.

**The nil return is a choice the schema forces and does not make.** One
`Amount` is required and no grid is named. Zero on the grid that carries what
is owed says exactly what a nil return means; it is exported as `NIL_GRID` and
described as ours.

## Two accounts beneath 411 and 451 (18 September 2026)

**Apart from the accounts the taxes post to.** The Belgian pack books collected
VAT on 451000 and deductible VAT on 411000. Settling a period into either would
net it against itself, which `settle_filing()` refuses by name. So the debt and
the claim get sub-accounts of their own, reconcilable, because a payment is
matched against them.

**Two and not one.** A control account carrying both signs is what the United
Kingdom pack does, because that chart has one. The PCMN keeps a claim on the
State among the assets and a debt to it among the liabilities, so a credit on a
451 would sit on the wrong side of a Belgian balance sheet.

**Named after what they hold.** Not after the *compte courant* — the
administration replaced it with a provisions account, and an account named
after an instrument is wrong the day the instrument changes.

**The ratchet.** `tests/filing_golden.test.ts` now refuses a checkout where no
country freezes, writes its file and settles. One country doing all three is
worth more than six doing two, and the test is what keeps it that way.

## One file for every client of a firm (18 September 2026)

**The shape was in the schema all along.** `VATDeclaration` repeats,
`VATDeclarationsNbr` counts them, and `VATConsignment` opens on an optional
`Representative`. The format was drawn so that a firm deposits the returns of
all its clients at once, in its own name; the brick wrote one return and nobody
filing it. A firm holding several companies in one instance is the normal case
of this project, so its file has to be too.

**Entirely or not at all.** The block is optional and every field inside it is
required — identifier, name, street, post code, city, country, e-mail,
telephone. A declarant's missing telephone is left out, because the schema lets
it be. A representative's is refused by exception: completing it would send an
invented fact to an administration, and dropping the block would send the file
under another authority than the one that was meant. Neither is a violation to
report next to a valid file; there is no valid file.

**The schema's states, not ISO's.** The identifier is issued by a
`MSCountryCode`, a closed list where Greece is `EL` and `XI` and `XU` exist.
It is exported as `ISSUERS` and compared with the schema file code for code,
like the grids.

**The sequence number is the only thing that tells two returns apart** in one
file, so two under one number are refused, and a violation carries the number
of the return it is in — only when there are several, where it says something.

**Not checked, and written.** Whether the representative holds a mandate for
each declarant is a fact of the administration's records. The mandate as an
object of the ledger — who may file for whom, with which administration, from
when to when — is a table this project does not have yet.

## A client is a guest who reads and hands over (18 September 2026)

**The case.** A firm keeps the books of N companies in one installation — the
normal case this schema was shaped for — and the person who runs one of them is
invited into it. They read, they hand pieces over, and they never write a line.
`viewer` could not hand anything over; `accountant` can draft an invoice.

**It was not only data.** The brief was "the capabilities exist, a preset is a
row". They did not quite: a piece is a row of `attachments`, and the one policy
that admitted an insert tested `documents.write` — the capability whose
description reads *create and change draft documents, their lines and their
attachments*. Granting it to a client to let them drop a receipt would have let
them write the purchase invoice the firm is paid to write. So one capability
was added, `documents.deposit`, and it is as narrow as the act:

- **Insert only.** No update and no delete ride on it. What was handed over is
  the firm's to file, to move onto the document it becomes, or to discard, and
  all three are `documents.write`.
- **On the company, and nowhere else.** `attachments` is polymorphic and
  nothing checks that `entity_id` exists. A deposit that could name any row
  could sit on a `tax_filing`, beside the acknowledgement the administration
  sent, and be read as one. `entity_type = 'company'` with `entity_id` equal to
  the company is the one target every depositor can name without reading
  anything, and a file sitting on the company is what an in-tray is. No
  `inbox` table: it would have been `attachments` again with fewer columns.
- **Signed.** `uploaded_by` defaults to `auth.uid()` and the policy refuses a
  deposit that says anybody else, or nobody. It was a free column before.

**Reading back.** `insert … returning` is checked against the SELECT policies.
A client holds `documents.read`, so theirs passes; a scanner key granted
`documents.deposit` alone would have been refused a row it may write. A second
SELECT policy — own deposits, for a holder of the capability — covers it, and
it reads no table, so it cannot recurse the way a self-referencing SELECT
policy does.

**What the preset holds: what `viewer` holds, plus the deposit.** Copied from
`role_capabilities` rather than listed again, so the two cannot drift at the
day of the migration. The ledger is in it on purpose. The principle every
product in this market ends on is that the client owns the books and the
accountant is the guest, even when the installation is the accountant's; a
preset that hid a company's entries from the person answerable for them would
describe another relationship. A firm that wants less revokes per member.
`settings.read`, `contacts.read` and `products.read` are in it because a
document without its contact and a ledger without its chart are not readable.

**`owner` and `accountant` hold `documents.deposit` too.** They could already
do the act through `documents.write`. Naming it on them means an interface asks
one question — may this person drop a file here — and a company that revokes
`documents.write` from somebody does not silently take the in-tray away.

**Modules.** `assets` and `budgets` each gained a migration that gives their
`.read` to `client`. The label is read from `pg_enum` instead of written as a
literal, because a module can be applied on a socle that predates the preset,
where the literal does not parse; there it inserts nothing, and the socle's
migration copies the row from `viewer` the day it arrives. A module's
`requires_socle_min` is one value and every migration of the module has to sort
after it, so raising it was not available.

**No approval.** The brief allowed an approval "if the socle already has one
that is not a write". It does not: `tax_filings.state = 'ready'` is reached
through `filings.write`. An approval a client can give is its own act with its own capability, and it
belongs with the separation between preparing and filing, not here.

**What the test found.** `tests/client_preset.test.ts` sweeps the catalogue
rather than a list: every writable table, every callable volatile function,
the database fingerprinted before and after. Row level security held
everywhere — no table let a client write, and no table or function showed them
the other company. Two `SECURITY DEFINER` functions did not check their caller
and are fixed in `20260918114322`: `catch_up_journal_sequence()` moved the
counter of any journal for anybody signed in, and `touch_api_key()` stamped any
key as used. Neither needed the `client` preset to be reached; the preset is
what made somebody walk every door.

**Left as it is, and written down.**

- *Eleven functions answer a guest without raising.* `record_filing_outcome()`,
  `reopen_filing()`, `unreconcile()`, `auto_settle()`, `confirm_contact()`,
  `settle_cash_basis_tax()`, `pin_referenced_accounts()`, the three
  `documents_refresh_*` and `assets.run_depreciation()` run an update that row
  level security empties, and return. Nothing moves — the test asserts it — but
  a caller is told nothing, where `post_document()` says `unknown_document`.
  The list is frozen in the test so it cannot grow unnoticed.
- *The proof of a filing is read through `documents.read`, not
  `filings.read`,* because it is an attachment. A client holds both. A member
  granted `filings.read` alone reads the deposit and not its two files, and
  anybody with `documents.write` can delete them; `on delete set null` keeps
  the deposit row. Attachments of a `tax_filing` should follow the filing's
  capabilities.
- *A guest reads a little of the firm.* `instance` and `instance_admins` are
  readable by any member of any company, and `audit_log` by any member of the
  company it is about — so a client sees the firm's name, the user ids of its
  administrators, and which user id posted what in their own books. Nothing of
  another company. It is what a client of a firm would expect to know; it is
  written here because nobody had decided it.
- *There is no MCP tool and no CLI command that deposits.* The policy is the
  floor; uploading the bytes to storage and inserting the row is the
  application's, and the storage bucket needs a policy that mirrors this one.
- *A deposit cannot be withdrawn by its author.* Deliberate for now: the firm
  may already have booked from it.

## The output contract of the command line (18 September 2026)

The first card of the epic that gives the CLI the verbs the MCP server has.
It adds no verb. It decides what every command answers, so the verbs that
follow are usable by a caller that has a shell and nothing else.

**One document, one shape, whatever happened.** Under `--json` the standard
output is a single JSON document — `ok`, `command`, `exitCode`, `data`,
`warnings`, `error` — on success, on a finding and on a refusal alike, and the
prose moves to the standard error. `status`, `doctor`, `pack status` and
`pack upgrade` used to print their report bare; it is now under `data`. That
breaks a script that read them, at 0.3, once, in exchange for a caller never
having to know which command it is parsing before it knows whether it worked.

**`--json` is accepted by the parser, not listed by each command.** A command
added next year answers in JSON because it runs under `execute()`, not because
somebody remembered a flag. The test reads the list of commands from the CLI
and fails when one has no case.

**Exit code 3 is decided by the SQLSTATE, never by the wording.** `P0001` and
`P0002` (a raise of the schema's own), `42501` (a capability, a policy),
`55006` (a lock, a closed year) and class `23` (a constraint) are the database
declining. Anything else from Postgres, and anything that did not come from
Postgres, is 1. A message of the CLI's own that starts like a refusal —
`module_not_migrated:` — keeps its name in the document and is not promoted to
3: the books were never asked.

**Exit code 1 keeps its second meaning.** `doctor`, `status`, `pack check`,
`pack status` and `pack upgrade` already ended on 1 when they found something,
and CI jobs are built on that. Rather than spend a fifth code, a finding is 1
with `data` and no `error`, and a failure is 1 with an `error`. A caller that
needs to tell them apart reads one field.

**What a refusal is called is read in one place, and that place moved.**
`socleCode()` lived in the MCP server. The CLI needs the same reading, so it
moved to `@ekwo-ai/core` beside `isRefusalState()`, and the MCP server
re-exports it under the name it always had. This makes the core a runtime
dependency of the CLI, which amends "one runtime dependency, the Postgres
driver" above to *one from outside this repository*. The argument was about
who can read a secret: the core is published by the same hands as the CLI, and
a test now refuses a core that depends on anything which is not ours. The
verbs to come need the access layer shared the same way, so the question was
going to be answered in this epic; it is answered here on three lines of code
rather than on three thousand. The build order says so too: the root
`workspaces` names `packages/core` before `packages/*`.

**A prompt cannot block, by construction.** Each command already refused to ask
off a terminal. Now `--json` counts as "nobody to ask", and the prompt
functions themselves stop with exit code 2 when reached with no terminal — for
the day a command forgets.

**Bad arguments in `init` are exit code 2.** `--chart` naming no chart, a date
that is not one, a missing `--country` with nobody to ask: they were plain
errors, so they would have been 1, "it failed", for what is a wrong call.

**Known gaps, written down.**

- *No shipped command can reach a locked period.* The test that proves code 3
  and `period_locked` provokes the refusal through `execute()` — the function
  every command runs under — with a handler that calls `post_document()`, which
  is what the first booking verb will do. A shipped command is refused for
  real in the same file (`module enable` acting for a stranger, `42501`). The
  day a verb exists, the locked-period test should go through it.
- *`data` is validated per command by the test, not by the schema alone.* The
  schema describes each shape under `$defs/data/<command>`; choosing the branch
  from `command` needs `if`/`then`, which the CLI's small validator does not
  read. A stock validator checks the envelope and leaves `data` an object.
- *The reports under `data` keep the spelling they had.* `pack upgrade` passes
  on what `pack_upgrade()` returned, snake case included, beside camel case
  elsewhere. Re-spelling a function's answer in the CLI is how two spellings
  become three.
- *A refusal that reaches the CLI without an SQLSTATE is 1.* Both drivers in
  use carry it. A future transport that does not — PostgREST, when the CLI
  signs in as a user — has to bring its own mapping to the same three kinds.
- *No amount is printed by any command yet*, so "amounts are decimal strings"
  is a rule of the schema with nothing to break it. It binds the first report
  that carries one.
- *`NO_COLOR` set to the empty string still switches colour off*, where the
  convention says it should not. Left as it was.

## A portfolio is what the caller may read (18 September 2026)

**The case.** `upcoming_filings()` and `filings_touched_since()` answer for one
company. A firm that keeps N of them in one installation asks one question of
all of them: what falls due in the fortnight, and what moved after it went.
`portfolio_upcoming_filings(from, to)` and
`portfolio_filings_touched_since(from, to)` answer it.

**No firm, no client list, no `tenant_id`.** The portfolio is not an object. It
is the set of companies on which the caller holds `filings.read`, worked out at
the moment of the call. That serves the accountant of forty companies, the
person who runs one of them, and a group keeping three of its own, with one
sentence and no new table. Groups of collaborators, when they come, will write
rows of `company_members` or something that resolves to them, and this reading
will not change. The name says `portfolio` and not `firm` for the same reason.

**`security invoker`, and one filter in the open.** Both functions read what
the caller could have read by asking company by company, so neither needs the
owner's rights, and after the two definer functions found on 18 September that
checked nobody, the default is not to write a third. But row level security
settles *which declarations* are read, not *which companies are walked*:
`companies` admits any member and the administrator of the instance, while
`tax_filings` asks for `filings.read`. Walking every visible company would list
a calendar with every state empty — which reads as "nothing has been started"
and means "you may not know". So the list of companies is filtered on
`has_capability(id, 'filings.read')`, written in the function and not left to
a policy that was never about this. The test revokes the capability from a
member and watches the company leave their portfolio on both readings.

**The administrator of the instance has an empty portfolio.** Checked rather
than assumed: they read every row of `companies`, because they create them, and
no row of `tax_filings`, because that policy never named them. A firm's
administrator who also keeps books is a member of those companies, and gets
them as a member. Nothing was changed; it is now a test.

**Silence is not an output.** Every company of the portfolio is in every
answer, at least once. `reason` is a closed vocabulary of three words, in text
like `ec_sales_list().issue`: `no_deadline_rule`, `nothing_due`, `no_form`. The
first is the one that matters — a pack that names no deadline on purpose,
because its schedule depends on who is filing, must not make its companies
disappear from the list a firm plans its fortnight on. On the other reading a
company nothing moved in is a row with no filing, and `filed` says how many
declarations were looked at, because "six returns, none disturbed" and "no
return has ever gone" are different news.

**The window is on the due date.** `upcoming_filings()` takes two dates and
generates the *periods* that start between them, which is a calendar; asked for
the next fifteen days it answers with the period that has just begun, due in
two months. A portfolio is asked what is *due*, so the new function asks the
per-company one for a calendar reaching back two months and the longest
`deadline_plus_days` of the installation — a return is due in the month after
its period, plus those days — and keeps the rows whose date is in the window.
A period with no date is kept while the month after it overlaps the window: it
is the only place either rule of the vocabulary puts a date, so it is where a
person would look for one. A third rule that reaches further than a month
moves the reach with it.

**Built on the two functions, not beside them.** A second implementation of
"which periods does this company owe" would be a second answer to it. Both
portfolio functions call the per-company ones in a lateral join.

**Cost, as far as it was looked at.** The per-company function is a single
SQL statement and the planner inlines it: the plan for forty companies is one
nested loop, and each turn of it is index probes — the company by key, its
cadences by key, the form by key, the live filing of a period through
`tax_filings_live_period_idx` — plus `has_capability()` once. Forty companies
answer in about forty milliseconds in PGlite, linear in the companies, and the
most repeated cost is `periodic_return_code()`, called several times per
company by the function underneath. On the other reading the ledger is only
touched for declarations that have gone, through the partial index on
`entry_lines (company_id, declaration_box)`, and `filing_drift()` — the one
heavy call, a `vat_return()` — runs only for a declaration that *was*
disturbed, since it sits in the select list behind `entries > 0`. Without a
window it looks at every declaration ever filed; a caller with years of
history passes `p_from`. Nothing was measured at thousands of companies or on
a real ledger: that is the load card, and it is not this one.

**What is missing, and written.**

- **A machine key has no portfolio.** A key is not a session: the company row
  stays closed to it, as stated on 13 September. So a key holding
  `filings.read` gets an empty answer here — and, found on the way, cannot use
  `upcoming_filings()` or `filings_touched_since()` on its own company either:
  the first answers nothing because it cannot read the country of the company,
  the second raises `unknown_company` the moment a declaration was disturbed,
  from the figures `filing_drift()` recomputes. Reading tables under a key
  works; these functions do not. It needs a decision about
  what of `companies` a key may read, not a patch here. Tested as it stands.
- **`upcoming_filings()` still answers somebody who may see a company and not
  its declarations** — the administrator of the instance, a member whose
  `filings.read` was revoked — with a calendar whose states are all empty. It
  leaks nothing; it says "nothing started" where it means "not yours to know".
  The portfolio does not have the defect; the per-company function was left as
  published.
- **`service_role` has no portfolio either**: it holds no capability, because
  it is nobody. A scheduler that reminds every company walks `companies` and
  calls the per-company function, which row level security does not stop it
  doing.
- **A form of another country has no date.** `filing_deadline()` looks for the
  form among those of the company's country and fiscal country, so a company
  filing a return abroad gets `no_deadline_rule` even where that pack names
  one. The word is then wrong by one notch — the rule exists and was not
  found.
- **Periods follow the calendar year**, as they do underneath; no mandate, no
  "who files for whom" — that is the next card of the same epic.

## An invoice is written from the books, and judged by the published rules (18 September 2026)

**The brick that was missing.** `einvoicing.profile` has said `peppol-bis-3` in
four packs since the packs had the key, and `packages/formats/` wrote EN 16931
in one syntax only: CII, inside Factur-X. `@ekwo-ai/peppol-ubl` writes the other
one. It is not a module — invoicing is `documents` and `post_document()`, in the
core — and it is not a transmission: that takes a certified access point and
stays in `ee/`, on the line the bank feed and the deposit of a return are
already on.

**It does not reuse the input of `factur-x`, and that is decided, not
overlooked.** Both bricks write the same semantic model, and the older one
takes an `Invoice` object, computes its totals and defaults its currency to the
euro, its unit to `C62` and its payment means to `58`. Every one of those is
what the bricks written since are forbidden: a file that recomputes can
disagree with the ledger it carries, and a default is a value nobody chose
travelling to somebody who will believe it. So this brick reads what
`packages/formats/README.md` says a brick reads — the flat rows of
`document_header`, `document_line_items` and `document_tax_summary` — and
writes the figures as posted. Two types that look alike are two types; the day
`factur-x` is brought to the same contract, it is `factur-x` that moves.

**No figure is a `number`.** The rules compare with `=`. Amounts arrive as the
text of a `numeric`, are compared as `bigint` decimals, and leave as the same
digits. This is not `rounding.ts`, and the brick has no copy of it: it rounds
nothing it writes. The one rounding in it is XPath's — half towards positive
infinity — used to re-read rules that are written with it.

**A violation is named by the rule, and the rule is checked.** `code` is
`BR-CO-15`, not `total_mismatch`: it is what an access point will answer, and a
caller should not need a table to translate. That is only honest if the
re-reading was compared with the original, so:

- the UBL 2.1 schemas of OASIS are fixtures and every file is validated;
- the code lists are generated from the Schematron and compared code for code;
- the Schematron is XSLT 2.0. SaxonJS is the only processor that runs on Node;
  it is not a dependency this repository takes for a test, and its licence is
  not an open-source one. **It was played out of tree** against 100 committed
  files, and `verdicts.json` is what it said. The suite pins the files byte for
  byte and the reported rules to the recorded ones exactly, requires every named
  rule to have been reported by the real thing at least once, and the README
  says in so many words that agreement on a hundred documents is not agreement
  on all of them. Taking `saxon-js` as a development dependency would turn the
  record into a test; that is a decision about a licence and is left open.

**The Peppol Schematron is not vendored.** Its repository has no licence. The
EN 16931 one is EUPL 1.2 and is a fixture, in the copy Peppol ships — which is
not CEN's own 1.3.15: Peppol added an identifier scheme to it, and what the
network validates with is what counts.

**What the sources refuted.** Written from the specification, then played:
`0999999999`, the company number of every test here, fails the check digits
Peppol verifies (the fixtures use `0999999922`); EN 16931 lists seven
electronic address schemes Peppol refuses; `BR-DEC-13` cannot fire as it is
written; `BR-CO-16` rounds in one branch only; an absent price also breaks
`BR-27`, a group without a rate `BR-S-09`, a VAT total without a breakdown two
Peppol rules and not one; and the UBL binding has rules of its own beside the
standard's, so three decimals are `UBL-DT-01` as well as `BR-DEC-*` and a line
without a category `UBL-SR-48` as well as `BR-CO-04`. Nine lines of
`src/rules.ts` that reading alone got wrong.

**What the end-to-end test found in the core and the packs.** None of it is
fixed here — the card asks for a brick — and all of it is now visible:

- `document_lines.vat_category` and `.vat_rate` are **never filled**: every
  line of every golden year has them null, and the view publishes them as
  BT-151 and BT-152. The brick reads a silent line through its tax, by
  `tax_id`. The columns should be filled at posting or dropped from the view.
- `party_scheme` is documented as the scheme a party is *addressed* by and was
  first read here as the scheme of its registration number (BT-30-1). For two
  of the four packs that is not an ISO 6523 scheme at all (`BR-CL-11`). The
  brick takes the scheme of a registration number as an option and reads
  nothing from the pack for it.
- `companies` has **no electronic address**. `contacts` has `peppol_scheme` and
  `peppol_identifier`; the company that sends has neither, and BT-34 is
  mandatory. The test registers the company under its VAT number and says it
  is the test's choice.
- `document_header` does not carry `tax_point_date`, the delivery address, the
  buyer's electronic address or the text of an exemption (`legal_reference`);
  `document_tax_summary` does not carry the exemption code. The brick declares
  them as optional columns of its rows, marked *not in the view today*.
- The United Kingdom pack gives its exempt, export and reverse-charge taxes
  **no exemption code**, so those invoices break `BR-E-10`, `BR-G-10` and
  `BR-AE-10`. The other three packs code theirs.
- A price keyed with its tax in it still has no BT-146, as
  `docs/international.md` already says. The brick reports `BR-26` and works
  nothing out.
- A golden scenario records no order reference, no delivery and no buyer
  address, because no ledger asks. Its documents are therefore not sendable,
  and the test derives, document by document, exactly which rules say so —
  then posts one that is, and expects nothing.
- `docs/releasing.md` names the ninth brick after the eighth, before the core
  that no brick depends on: twelve packages to publish.

## Who the command line is, and where it keeps that (18 September 2026)

The second card of the epic. It still adds no verb that books anything; it
decides who every such verb will act as, on which instance and for which
company, so that the verbs can be written without any of them taking a
connection string.

**A person, over the instance's API — never the connection the installer
uses.** `--db-url` is the owner of the database: `auth.uid()` is null and no
policy applies. That is right for `init` and `migrate` and wrong for anything
that touches a ledger. So the bookkeeping side signs in to the instance and
goes through PostgREST with the user's own token, which is the route the MCP
server recommends and the one on which row level security is *satisfied*
rather than imitated. The commands that connect as the owner now say so when
they connect — all of them, not only `init` and `migrate`, because `status`
and `doctor` are the same exception and a reader of a log should not have to
know which is which.

**The session is a file, in the user's configuration directory, and refused
inside a repository.** `$EKWO_CONFIG_DIR`, else `$XDG_CONFIG_HOME/ekwo`, else
`~/.config/ekwo`; two files at `0600` in a `0700` directory. `profiles.json`
holds what a dashboard already shows (URL, publishable key, address, company
in use) and `credentials.json` holds the two tokens, so the first can be
looked at, diffed and backed up without the second. The write is a temporary
file renamed over the old one, because the instance rotates the refresh token
and a half-written file would be a session lost. "Never in the repository" is
enforced and not only promised: a `.git` in the directory or above it is
`config_dir_in_repository`, before anything is sent. This amends "the CLI
never writes a secret to disk", which was true of an installer and cannot be
true of a command used twenty times a day; the help and the README now say
what is kept, where, and what never is — a password, a database password, a
`service_role` key.

**Written on `fetch`, where the MCP server uses `@supabase/supabase-js`.** The
two packages answer the same question differently and both answers stand. The
server says a library known to work beats code of ours that no test can run
against a real project. The CLI says it is handed a password, and that every
package it loads could read it — the argument that made it parse its own
arguments. What decided it: the exchange is three auth requests and two
PostgREST ones, and unlike the server's it *is* tested here, against a real
Postgres behind a stand-in for the two HTTP surfaces
(`tests/cli/fake-supabase.ts`), rotation and a lost token included. The CLI
still has one runtime dependency from outside this repository.

**What moved to the core, and what did not.** `isServiceRoleKey()`, the
sentence of the refusal and the names of the five variables moved from the MCP
server to `@ekwo-ai/core` (`identity.ts`, which imports nothing); the server
re-exports the first under the name it had, and its two messages are byte for
byte what they were. The refusal takes who is speaking as an argument — "this
server", "this command line" — so it is one sentence with two subjects and
not two sentences. The PostgREST client did *not* move: the server's is a
wrapper over a library the CLI does not load. It is shaped to grow into the
`Backend` interface the MCP tools are written against (`rpc`, `select`), and
the card that brings the first verb has to move those tools to the core and
decide that — it is the large version of the question answered here on a
small one.

**The environment first, whole, and without a file.** The order is the card's.
"Whole" is ours: `EKWO_ACCESS_TOKEN` in the environment with the instance
taken from a profile would send a token to a host nobody wrote next to it, so
it is `missing_configuration` and not a fallback. A command run this way reads
no profile and writes nothing, which is also why `ekwo use` refuses there
(`no_profile`): the environment has nowhere to keep a company, and `--company`
is the answer. `EKWO_COMPANY` was not added — the card names the flag only.

**The company is in the document, not only in `data`.** `context` is a field
of the envelope — profile, instance, company or `null` — set as soon as it is
known and emitted on a refusal too, because the refusal is where a caller on
the wrong company most needs to see it. It is an addition to
`output.1.json`, optional, so a reader of version 1 is not broken; the
commands that install carry none, since they act as nobody. No company is
ever picked on the user's behalf, not even the only one: `null` is an answer.
Signing in to a profile as somebody else, or somewhere else, drops the company
it held.

**Exit codes of the new refusals.** Nothing here is the books saying no, so
nothing here is 3. Nobody to act as — `not_signed_in`, `unknown_profile`,
`session_expired` — is 2: the call has to change (sign in) and retrying it
will not help, which is what separates 2 from 1 for a caller. A
`service_role` key is 2 for the same reason. A wrong password is 1
(`sign_in_failed`, the MCP server's name for it): the instance was asked and
declined, and the CLI cannot tell a typo from an account that is locked.

**Code 3 over the new route.** PostgREST answers an error of the database with
the fields Postgres gave it, so the error the client throws carries `code`,
`detail` and `hint` as both SQL drivers do, and `classify()` did not change. A
`PGRST…` code is not five characters of the SQL alphabet and stays a failure.
This closes the gap written under the output contract.

**Found on the way.**

- *The CLI resolved a company three ways*: `pack upgrade` by id or name,
  case-insensitively, as a plain error (exit 1); `module enable` by exact name,
  as a usage error (exit 2), picking the only company when none is named. The
  new commands share the first one's matching (`company.ts`), which becomes a
  usage error — so `pack upgrade` on an unknown company now ends on 2.
  `module enable` was left as it is; its silent pick of the only company is
  the behaviour this card decided against, and changing it belongs to the card
  that gives `module` a signed-in route.
- *A test asserted "It never writes a secret to disk"* as a sentence of the
  help. It was rewritten with the sentence, rather than kept true by calling a
  session something else.

**Known gaps, written down.**

- *The session is not in the operating system's keychain.* A file at `0600` is
  what `gh` and the Supabase CLI fall back to; a keychain needs a native
  module or a process spawned per platform, and either is a dependency with a
  view on the token. `ekwo logout` and the environment are the two ways to
  keep nothing.
- *File modes mean nothing on Windows.* The directory is under the user's
  profile there, and the exposure warning is skipped.
- *A home directory that is itself a repository* (dotfiles kept with a `.git`
  in `~`) is refused like any other; `EKWO_CONFIG_DIR` is the way out and the
  refusal names it. A bare-repository dotfiles setup is not detected.
- *No self-hosted route.* The MCP server can act for a user over a direct
  connection (`EKWO_DB_URL` with `EKWO_ACT_AS_USER_ID`); the CLI's person side
  speaks PostgREST only. An installation with no PostgREST in front of it has
  `whoami` to wait for.
- *No sign-in other than address and password*: no magic link, no OAuth, no
  second factor. A holder of a token obtained otherwise sets
  `EKWO_ACCESS_TOKEN`, which is not renewed. *(Corrected the same day: this
  line first said the schema has no API key of its own. It has — `api_keys`
  and `use_api_key()`, above — and what is missing is a way for the CLI to use
  one: a key authenticates per transaction, over a direct connection, and the
  CLI's person side speaks PostgREST only. Same gap as the self-hosted route.)*
- *`whoami` reads the capabilities of the company in use only.* One call per
  visible company would be two hundred calls for a firm; `--company` asks for
  another.
- *Two commands at the same moment can both renew.* The instance rotates the
  refresh token and tolerates a reuse within a few seconds; outside that window
  the slower one gets `session_expired` and signs in again. There is no lock
  file.
- *Numbers over this route are JSON numbers.* Nothing read here is an amount.
  The first report that carries one has to ask for `amount::text`, as the MCP
  server's columns do, or the decimal-string rule of the contract breaks on
  this route first.
- *The stand-in instance is ours.* It runs the real policies and the real
  raises, and it is not GoTrue: the shape of its auth errors was written from
  the documented ones. `npm run e2e:supabase` does not cover `login` yet.

## A setting that was never set (18 September 2026)

**The defect.** `is_installer()` compared `current_setting('ekwo.installing',
true)` with `'on'`. Emptied, the setting answers `''` and the comparison is
false. Never set, it answers NULL and so did the function — and
`if not NULL and not false` does not raise. Every guard of the family let the
caller with no session and no key through: `service_role` over PostgREST, a
direct connection. Found while writing the import of a company, by reloading a
database into a new instance; the migration that introduced the function was,
of all things, the one about guards that could answer NULL.

**Why no test saw it.** The harness sets the variable on the one connection it
has — `'on'` for the owner, `''` inside `asUser` — so "never set" did not exist
in any test. *A test that prepares the session cannot test the session nobody
prepared.* `tests/fresh_session.test.ts` dumps the data directory and loads it
into a second instance, and asks there.

**The rule that follows.** A boolean a guard negates answers true or false.
The test sweeps the catalogue for every argument-less boolean function of the
schema and asks each as the caller with nothing; a new helper that can answer
NULL fails the build.

**What it does not change.** `service_role` bypasses row level security on the
platform it comes from, by that platform's design, and nothing here pretends
otherwise. It does not bypass a function that raises, which is why the rules
of an installation are in functions — and why a guard that is skipped matters
more than a policy that is.

## A brick that reads, and what a reader has to prove (18 September 2026)

**The gap.** Six packs say their banks send `camt.053`, the core has held
statements and their lines since the first migration of the bank, and
`suggest_matches()` and `auto_settle()` work on those lines. Nothing produced
one. `@ekwo-ai/camt053` reads the file; importing what it returns is the next
change and is not in this one.

**Named after the document.** `camt053`, not `camt` and not `bank-statement`.
camt.052 and camt.054 share most types with the statement and would read with
the same code — and a report has no closing booked balance to check and a
notification has no balance at all. The guarantee this brick gives is the
balance; a document that cannot carry it is another document, and is refused by
name (`not_a_statement`) until somebody needs it. CODA, CFONB 120 and MT940 are
other bricks: two formats that look alike are two formats.

**The output is declared by the brick, and an account is not an IBAN.** A brick
that writes declares the rows it reads; one that reads declares the rows it
returns, in its own `types.ts`, importing nothing. `AccountIdentifier` is
`{ kind: 'iban', value }` or `{ kind: 'other', value, scheme, issuer }` because
that is the choice ISO 20022 gives (`IBAN` | `Othr`), and because six columns of
the core already made the opposite assumption and have a change of their own
waiting for it. The reader must not be the seventh place. An IBAN's check
digits are verified — ISO 7064 is part of what "IBAN" means — and a failure is
a violation, the value returned as written; an `other` identifier is validated
by nothing, since its scheme is a label the bank chose.

**One line per transaction where it is provably the same money; one per entry
otherwise.** The question was which of `Ntry` and `TxDtls` is a line.
Reconciliation wants the transaction: a batch of thirty customer payments
booked as one credit matches no invoice. The balance wants the entry: it is
what moved on the account, and the bank's own arithmetic is over entries. So an
entry with several transactions is split **only if** each transaction carries
an amount in the entry's currency and they add up to the entry exactly — and
then each line carries `entry`, `detail`, `detailCount` and `entryAmount`, so
whoever stores them can rebuild the batch. When they do not add up (charges
netted, amounts absent, mixed currencies) the entry stays one line with
`batch_not_split`. In both cases the lines of a statement sum to its movement,
so the balance check never depends on the choice, and neither does an
importer's.

**A statement that does not add up is reported, not refused and not
corrected.** The roadmap card said "refused". What it meant is kept: the
difference is named to the last decimal and `balanced` is `false`, so nothing
downstream can take the statement for a sound one without having been told. But
the brick returns it, because refusing to *read* is the wrong place for the
decision: a person looking for the missing line needs the other three hundred,
and an importer that wants to refuse can — on one boolean. Correcting is never
an option: a computed closing balance substituted for the declared one erases
the only evidence of a truncated file. Only booked entries are summed; a
pending one is returned and marked.

**Exceptions are for files, violations for lines.** Thrown: what leaves no
statement to report on — not XML, not UTF-8, over a limit, not a camt.053, no
account. Returned: everything about a line or a balance. The test of the split
is whether the rest of the file is still worth having.

**The XML reader is in the brick, and refuses more than it reads.** Zero
runtime dependencies is the rule of the directory, and it is the right rule
here for a second reason: the dangerous features of XML are features of
general parsers. No DOCTYPE means no entity declarations, internal or external,
so the billion-laughs and XXE families are refused at one `startsWith`. Limits
on size (before reading), depth and element count (while reading), no
recursion, fatal UTF-8 decoding, ASCII names. A bank whose export needs a DTD
or ISO-8859-1 will be refused by name, and that is preferred to the
alternative.

**Dates are the day the bank wrote.** A `DtTm` with an offset is not moved to
UTC: a booking at 23:30 +02:00 is that day's booking, and the ledger of a
company east or west of Greenwich should not depend on where the code ran.

**Amounts are strings with the digits the file wrote.** `100.00` stays
`100.00` and `749.5` stays `749.5`; sums are `bigint` hundred-thousandths,
because the schema allows five decimals. Rounding to a currency's decimals is
the importer's, which knows the currency table; the reader does not.

**What the sources refuted**, the hour they were fetched: `BIC` became `BICFI`
in version 03, not 04 as the draft had it (the schema of 03 refused the
fixture); ISO serves a version 14, dated March 2026, the draft did not know;
and it serves a version 01 whose message element is `BkToCstmrStmtV01`, whose
balance type and account choice are shaped differently — read by a lenient
reader it would have come back as a statement with no balances. It is refused
(`unsupported_version`).

**What is not proved, written where a user will read it.** No real statement
was used: every fixture is invented, since a real one is somebody's account,
and the schema says what a bank may send, not what any bank does. Which
reference a given bank fills, whether it details its batches, how it writes a
card payment: unknown until the first file from each. No usage guideline (EPC,
CGI-MP, national federations) is tested. That the parties of a reversed entry
keep their original roles is a reading of the message definition, not a fact
of the schema. Paginated statements (interim balances as opening and closing)
are returned and not interpreted. The brick's README lists these under *Not
verified*.
## What the core says for a posted invoice to be sendable (18 September 2026)

The section above ends on a list of what the end-to-end test of the Peppol
brick found missing in the core and the packs. This closes it, largest first,
in three migrations — `20260918141107`, `20260918141342`, `20260918141605` —
and the test that found the list is the test that checks it: a posted sale now
comes out with no rule broken from **three reads of three views and no
option**.

**A line keeps the category and the rate it was posted with.**
`document_lines.vat_category` and `.vat_rate` were never written, and three
migrations had cited them as the precedent for a snapshot. The choice was to
fill them or to take them out of the view and read through `tax_id`. They are
filled, because reading through `tax_id` reads the tax *of today*, and a tax is
rewritten in place by a pack upgrade — `amount` and `vat_category` among the
columns of one `update`. A rate that changes on 1 January would restate
every invoice of December the first time one was rendered.

The rule is the one `documents.language` follows, and deliberately the same
shape: derived and never keyed; a draft follows its tax, including when the
tax moves under a draft nobody touches (`taxes_reach_draft_lines`, which also
brings a draft's totals up to the new rate — until now they waited for
somebody to edit a line); a line of a document that is no longer a draft
refuses the change by name, `document_line_tax_frozen`. `vat_rate` is a
percentage, so a fixed-amount tax leaves it null.

**And the breakdown reads the line.** This went further than the finding, and
it had to: `document_tax_summary` is BT-118 and BT-119, and it took both from
the tax. Filling the lines and leaving the breakdown on the tax would make the
two halves of one invoice disagree on the day a rate moves — BR-S-08 on a
document nobody touched. It would also have kept an older hazard nobody had
written down: `documents_refresh_totals()` reads that view on every write of a
line, so correcting a description on a posted invoice recomputed its totals at
the rate of the day. The view now groups on what the lines carry, which for a
draft is the tax by construction. `post_document()` reads the same view at the
moment the snapshot and the tax are equal, so no figure of any golden year
moves.

**The lines already there take the tax as it stands, once.** A posted line is
not rewritten — that is the rule being installed — and yet every posted line
has these two columns empty. The precedent is the backfill of
`documents.language`: the chain applied once, called a guess, and nothing
guessed afterwards. Here the ledger kept the amounts and not the percentage, so
the tax of today is the only evidence there is; it is what every read of those
documents has answered until now and what their totals were last computed
from, so the backfill changes no figure, and the test checks that on a
database built without the migration. A line an application had stamped itself
keeps its stamp. This is not the deprecate-and-mirror of
`companies.vat_period`: nothing is deprecated, the columns finally do what
their comment said.

*Left open, and smaller:* the share of a tax that reaches the buyer
(`tax_charged`) still reads `tax_postings` as they stand, and BT-121 and
BT-120 still read the tax and the pack. None changes a base or a rate. And no
trigger refuses a change of `quantity`, `unit_price` or `tax_id` on a posted
line: the ledger is immutable and the document that produced it is only partly
so. That is wider than this change and is the next thing to look at.

**A company has an electronic address.** `companies.peppol_scheme` and
`.peppol_identifier`, the names `contacts` has used from the first day: a
scheme and a value, the shape `docs/international.md` asks of every identifier
after finding that a bank account is not an IBAN. No list of schemes in the
core — `contacts` has none, the list is revised twice a year, and EN 16931 and
Peppol do not even share one; the brick carries both and names the rule. One
constraint `contacts` does not have: the pair is whole or absent
(`companies_electronic_address_whole`). On new columns it refuses nothing that
exists; on `contacts` it could refuse an unrelated edit of a row somebody
half-filled, so it waits for a release that looks at the data first. Writing it
is `company.write`, because it is the company's row and `companies_update`
judges the row.

**The views carry what the schema knew.** `document_header` gains the tax
point, the four delivery columns `documents` has, and both electronic
addresses. What the schema does not know is absent rather than approximated: a
second delivery line, a delivery region, a deliver-to party (BT-70), a location
identifier (BT-71).

**BT-120 is a sentence for a customer, not the pack's argument.** The finding
named `taxes.legal_reference` as the text of an exemption, and it is the
obvious column and the wrong one. A legal reference is written for whoever
reviews the pack — which article, why this code, what the pack declined to do.
Some are six words; one discusses this repository's own choice of codes. None
was written to be printed on an invoice. The sentence a country wants on an
invoice that charges no tax already exists, per country, translated and dated,
in `legal_mention_templates`, and is printed at the foot of the same document.
So `document_tax_summary.exemption_reason` is the mention of the tax's
treatment, in `documents.language`, valid on the document's date; null where
the pack has no sentence for the treatment, which includes every tax that
charges something — a reason on a standard-rated group is BR-S-10.
`legal_reference` is published beside it under its own name. Which treatments a
condition covers was a `case` inside `document_legal_mentions`; it is now
`legal_mention_treatments()`, read by both views, because a second copy would
drift the day a treatment is added.

**The United Kingdom pack gets no exemption code, and no longer needs one.**
The finding read "the other three packs code theirs". Looked at again, the pack
had not forgotten: its `legal_reference` says that the VATEX list names
articles of Directive 2006/112/EC and national codes of Member States, and the
United Kingdom is neither. The list bears that out (CEF, *VATEX*, as Peppol BIS
Billing 3.0 publishes it). `VATEX-EU-132` is "Exempt based on article 132 of
Council Directive 2006/112/EC", which is not the law Schedule 9 of the Value
Added Tax Act 1994 exempts under. `VATEX-EU-G` is "Export outside the EU", and
since 1 January 2021 a British export to a Member State is an export *into*
it. `VATEX-EU-AE`, "Reverse charge", and `VATEX-EU-O`, "Not subject to VAT",
are worded generally and could be argued; they sit in the same list under the
same prefix, no source says a third country may use them, and a pack that
codes two of its four cases on an argument is harder to review than one that
codes none on a principle. They stay empty.

What made those invoices break BR-E-10, BR-G-10 and BR-AE-10 was never the
missing code: each rule asks for a code **or a text**, the pack has had the
text since it had mentions, and the view did not carry it. With
`exemption_reason` in the breakdown the three rules pass for every sale of the
British golden year, and the end-to-end test now says so for every pack rather
than deriving who fails. The pack is unchanged, at the same version. One case
is still open and is a gap of the vocabulary, not of the pack:
`applies_when` has no condition for a supply outside the scope of the tax, so
a category-O sale (`GB-S-OUTSIDE`) has neither code nor sentence and would
break BR-O-10. No golden year sells one.

**`party_scheme` was misread because it was misdescribed.** Its comment said
"ISO 6523 ICD", and so did `vat_scheme`'s. The packs fill both from the EAS
list, which contains the ICD list and more — the VAT schemes of the 99xx range
are not ISO 6523 at all. The comments now say EAS, say that the column is a
default an application may propose and not anybody's address, and say that it
is not the scheme a registration number is written in.

**The brick loses its two workarounds.** The join of a silent line to its tax
by `tax_id` is gone — a line that does not say its category has none, which is
BR-CO-04 and is true — and the electronic addresses are read from the header,
the options remaining for a caller whose header has none or who sends under
another address. The 100 fixtures and the recorded verdicts did not move by a
byte: same input, same file.

Still out of scope and still written down: BT-146 for a price keyed with its
tax in it, order and delivery references in the golden scenarios, allowances
and charges.

## The plan is the assertion, the clock is a report (18 September 2026)

The question was whether the schema holds with tens of thousands of invoices,
and the honest answer was that nobody knew. 173 indexes and two guards in
`tests/schema.test.ts` proved that indexes exist; every test booked fifteen
documents at most, and Postgres plans fifteen rows the same way with or without
them. `tests/load/` is the first test that gives the planner something to
decide. `docs/load.md` is the reference; this is why it is built the way it is.

**The build breaks on the shape of a plan and never on a time.** A time on a
shared runner, on Postgres compiled to WebAssembly, is noise with a trend in
it; a test that fails on it gets re-run until it passes, and then it guards
nothing. What is stable over deterministic data is whether a hot path reaches
`entry_lines` through an index or walks it. Times are reported next to a
budget, and no `expect()` reads them. The times worth quoting come from a real
Postgres, through `scripts/e2e-supabase.mjs`, which reads the same six
definitions — wired, and like the rest of that script not yet run.

**"Does not appear", not "appears".** The assertion is that no sequential scan
of a large table occurs inside a hot path. It is not that a given index is
used: which of two good indexes wins depends on statistics and cost constants,
and pinning it would make the test fail on a PGlite upgrade for no reason a
user would care about. The same file passes unchanged on four packs with
different charts and row counts.

**Several companies, or the test forbids the right plan.** With one company in
the instance `company_id = $1` keeps every row, and a sequential scan of the
ledger is then the correct plan for a trial balance. A selective predicate is
what turns "which plan" into a question, so the instance holds five.

**The volume is a copy of what the engine posted.** Three options were on the
table. Posting every document through `post_document()` is the only one that
proves the rows are real, and it costs seven milliseconds a document on PGlite:
over a minute for 10 000, a quarter of an hour for 100 000. Inserting invented
ledger rows is fast and proves nothing about coherence — they balance because
the generator says so, and they drift from the engine the day it learns
something. So each company books its pack's golden year through the real
functions, and that year is cloned by SQL with new identifiers and the dates
moved back by whole financial years, the column lists read from the catalogue.
A copy skips triggers and foreign keys, which is what makes it take one second
per 10 000 documents; the price is paid afterwards, by re-checking every
foreign key of the copied tables with an anti-join, every entry for balance,
and by posting one more document through the engine into the loaded company.
A test also watches which tables a replay writes to and fails, by name, the
day the engine writes to one the generator does not know.

**Plans are read with `auto_explain`, because `EXPLAIN` cannot see them.**
`explain select * from vat_return(…)` answers "Function Scan". The statements
that matter are inside plpgsql, and `auto_explain` with
`log_nested_statements` reports each with the plan the executor really used.
The alternative — extracting the query text from the function body and
explaining a copy — tests the copy.

### The three things the roadmap suspected

**1. `vat_return()` cannot use an index on its period — confirmed, not fixed.**
No sequential scan: it reaches the declaration lines through
`entry_lines_box_idx (company_id, declaration_box)`. But `coalesce(l.tax_point_date,
e.entry_date) between …` spans two tables and no index can serve it, so it
reads every declaration line the company ever wrote and discards the ones
outside the period — 86 000 rows read for the ten boxes of one quarter out of
twenty. 37 ms today at 10 000 documents, 255 ms at 100 000, and linear in the
years kept. It is left for its own card because the same filter now stands in
four functions (`vat_return()`, and three of the filing functions of 17
September), and the right fix touches all four and the posting engine: a
stored `declared_on` date on the ledger line, written where `tax_point_date` is
written, indexed `(company_id, declared_on) where declaration_box is not null`,
and one predicate the four functions share. Splitting the filter into two
indexable branches inside each function was considered and rejected: four
copies of a union, to avoid one column.

**2. `suggest_contacts()` is linear in the contacts — confirmed, fixed.** 3.5 s
for a month of statement against 500 contacts, all of it spent entering a SQL
function once per contact. `20260918143352` stores the words of a name and sets
aside the contacts that share none with the line before anything is scored.
The argument that this is a filter and never a change of answer is in the
migration header; the evidence is the old and the new body run side by side
over 167 lines, 974 suggestions compared field by field. It is still linear in
the contacts that *do* share a word — thirty suppliers called "… Services" are
thirty scorings — which is the behaviour the function documents. A GIN index on
the column was tried, used by the planner, and worth a tenth of the time; it
was left out, and an index nobody needed yet is the kind of thing this card
was opened against. One observation in passing: the sentence in `because`
lists the shared words in the order `intersect` yields them, which is not
stable from one execution to the next. Harmless to a reader, and a reason not
to compare that column as a string.

**3. Row level security under load — never measured, and the worst of the
three.** The roadmap said `has_capability()` is `stable`, "so evaluated once
per query". `stable` is a promise made *to* the planner, not a cache: with a
column as argument the function runs for every row the scan visits, and being
`security definer` it cannot be inlined. 359 000 calls for one trial balance;
3 266 ms as a member against 72 ms as the owner, on the same plan. It went
unnoticed because every measurement anybody had made was made as the owner of
the database — which is also why the load test runs each path twice.

The fix keeps one definition of who may do what.
`companies_with_capability()` does not restate the rules of
`has_capability()`; it lists the companies where the answer *can* be yes — the
caller's memberships and the company of a presented key — and asks
`has_capability()` about each. A policy compares `company_id` against that
array inside a sub-select, which Postgres evaluates once per statement, and
the comparison being a plain `=` on an indexed column, the planner may now use
the policy to find rows where it could only filter them before: the trial
balance is *faster* as a member than as the owner, because the function itself
never says which company's ledger lines it wants and the policy does.

**What was left per-row, on purpose:** the policies that combine the test with
another condition (`attachments`, `api_keys`, `company_members`, `companies`),
those that reach the company through a parent row (`journal_sequences`,
`tax_filing_boxes`, `tax_filing_deposits`), the three written on
`is_company_member()`, and the ten of the modules, which also ask
`module_enabled()`. None guards a table a report walks. `with check` clauses
are untouched everywhere: once per row written is what a check is. The module
policies are the first candidates if a module table ever grows.

**Not granted to `anon`.** The policy helpers are executable by `anon`
because a policy may be evaluated on its behalf. Since `20260914151207` `anon`
holds no privilege on any table, so no policy is, and one more helper in that
list would be a decision with nothing behind it.
## The verbs that keep books, and where their code lives (18 September 2026)

The third card of the epic, and the one the two before it were for: the
command line writes a contact, a draft and its lines, posts, records a
payment, matches a statement line and lists what is owed.

**The functions moved; they were not written again.** The MCP server held
them, written against a `Backend` of five operations. Between a database
function and a tool there is real code that is not an accounting rule and is
still not nothing: codes turned into ids in one query per table, a product
filling in what a line left out, a creation that is two inserts, which open
items a payment is offered to and on which currency's scale. A second copy of
that in the CLI would have been a second implementation in everything but
name — two surfaces that book the same invoice differently the day one of
them is fixed. So the interface, the column lists, the amount formatting and
the functions for contacts, documents, posting, payments and matching moved
to `packages/core/src/books`, which still imports nothing from outside this
repository. What stayed in the server is what is the server's: the zod inputs
and the descriptions a model reads, `explain()` and its hints, the two
backends. The functions take plain argument types, and the server re-exports
them under the names they had, so its tests did not change. The rounding copy
that `tests/rounding.test.ts` pins byte for byte against the two format bricks
is now the core's.

The rest of the server's tools — products, the bank, the reports, the closing —
did not move, because no verb of this card calls them. They move when one
does; the path is now worn.

**The CLI's `Backend` is its PostgREST client.** The one written for `whoami`
grew the three operations it lacked. It throws what PostgREST answered, with
the SQLSTATE, so a refusal met inside a shared function is still exit code 3.
The server's own backends pass the message through `explain()`, which keeps
the name and drops the SQLSTATE — right for a model, and the reason the CLI
could not borrow them even without the dependency argument.

**Three kinds of "no", three places they come from.** The database refusing
is 3. The CLI's own checks are 2. The shared layer's refusals (`BooksError`:
`unknown_account_code`, `document_not_draft`, `nothing_open`, `not_found`) are
2 as well: they are decided before the database is asked, or about a row it
did not return, and what the caller has to do is change the call. `not_found`
is the debatable one — a row a policy hid looks like a row that is not there —
and it is 2 because the CLI cannot tell the two apart and should not pretend
to. Their sentences were written for a model and name MCP tools
(`list_accounts`, `search_products`); they are repeated as they are rather
than rewritten per surface, which is a known roughness.

**No amount is computed on this side, and a test holds the means away.**
`tests/cli/no-rules.test.ts` reads every file under `commands/` and `books.ts`
and refuses `Number(`, `parseFloat`, `toFixed`, `Math.`, and arithmetic on
anything called an amount, a price or a total; and refuses a bookkeeping
command that queries a table or calls a function of the schema itself. It
cannot prove there is no rule. It proves a command cannot add.

**`--ref` needed a column, so it got one.** An idempotency key that lives in
a client is a lookup, and a lookup is a race. `client_ref` is on `contacts`,
`documents` and `payments`, unique per company where given, trimmed and not
blank so two spellings cannot be one reference. The shared functions look it
up first and return the row with `replayed: true`; the index refuses the
slower of two racing callers, which is then a 3. A replay also *finishes*: a
document is a header and then lines, a payment is an insert and then
`post_payment()` and then the matching, and a connection can drop between any
two. A draft found with no lines gets them; a payment found unbooked is
booked; matching runs again, and matches only what is still open. What a
replay does not do is compare: the same reference with different content
returns the first creation and says `replayed`, and does not notice the
difference.

**`--dry-run` is the database rehearsing, or it does not exist.** The card
said "where the database can answer without writing", and before this card it
could nowhere. `rehearse_post_document()` calls `post_document()` inside a
block and leaves it by an exception of its own, so the subtransaction is
rolled back and the answer, held in a variable, survives. It is the only
honest rehearsal: any description of what posting would do is a second
implementation of posting. The test counts entries, lines, journal counters
and audit rows before and after. The number it shows is the one the entry
would take *now*. Only `post` has it. `payment record --dry-run` would need
the same treatment of `post_payment()` and the matching, and is not in this
card.

**The short line syntax was arbitrated out.** `"Audit 1 500 EUR@21"` reads
well and parses three ways: `1 500` is one number or two; `@21` is a rate
where the books need a tax, and several taxes share a rate — choosing among
them is a rule; the currency is the document's. `--line` takes named fields,
by code, and `--stdin` takes JSON with the MCP tool's field names, refused
when a field is unknown. JSON is the authoritative form, as the card asked.

**`payment record --doc` reads the ledger, not the document type.** Which way
the money goes and who it is from come from `open_items()` — the side of what
is still open — rather than from a table of document types in TypeScript,
which would be a rule. The matching is then offered to that document alone,
where `record_payment` without one takes the contact's oldest items first.
`match` is `settle_from_statement()` with the document's open items as the
lines named; it chooses nothing.

**Two defaults, both said aloud.** `invoice new` without `--type` is a
`sale_invoice`, and without `--date` is dated today on the machine running
it; the answer says so. Neither is a country, a currency or a language, and
whether the date may be booked on remains the database's decision. No
contact type is defaulted here: the column has its own default and the CLI
leaves it to it.

**Known gaps, written down.**

- *`match` and `invoice line add` have no MCP tool.* The functions are in the
  core (`settleFromStatement`, `addDocumentLine`) for the server to register;
  the statement tools are another card's work in progress, and the server
  already replaces a draft's lines wholesale.
- *A creation is still two requests.* `--ref` makes the cut recoverable, not
  impossible. One transaction needs a `create_document(jsonb)` in the schema.
- *`open_items()` is read whole and filtered here* for one document; it takes
  a contact and a date, not a document.
- *The line table of `doc show` prints the ledger account's name where
  `post` prints its code*: they are two answers of two functions, and
  re-spelling one is how two spellings become three.
- *Flags come after positionals.* `ekwo post --dry-run job-7` reads `job-7` as
  the value of `--dry-run` and is refused as such; the parser is the one the
  installer has always had.
- *An older database* without this migration answers `--ref` and `--dry-run`
  with a failure of PostgREST, exit code 1, not with a sentence about
  migrating. `whoami` warns about the schema version; the verbs do not check.
- *Numbers from a function over PostgREST are still JSON numbers* where the
  function returns `numeric` (`reconcile`, `post_payment`), and `money()`
  puts them back to two decimals as it does for the server. A currency with
  three decimals is misprinted by both surfaces alike; the rows read from
  tables are exact.


## A company leaves with its books (18 September 2026)

**The case.** Several companies in one installation is the normal case, and
`pg_dump` takes the installation or nothing. So the company whose owner changes
accountant could not be handed its ledger by anything in this repository — only
by the goodwill of the firm. "The client owns the books" was a sentence.
`export_company()` writes one company out and `import_company()` takes it into
another installation, where it is a living company. The format is
[`company-archive.md`](company-archive.md).

**What belongs to a company is read from the catalogue.** A table is of a
company when it carries `company_id` or a foreign key leads from it to
`companies`, directly or through another such table. A list would have been
right on the day it was written. `company_archive_registry` says of each such
table `exported`, or `excluded` with a sentence, and a table that says neither
is unclassified — which fails a test, and **stops every export at run time**,
by name. The second half matters more than the first: a test protects this
repository, and an installation is not this repository. An operator who adds a
table of their own, or a module written elsewhere, meets a refusal that names
the table instead of an archive that silently lacks it. Classifying is a row.

**A module answers through a function in its own schema**,
`<schema>.archive_tables()`, looked up the way `can_disable()` is. Rows in the
socle's registry would have been simpler and wrong: a module migration may be
applied on a socle that predates the registry — the constraint `client` met the
same morning — and a function in the module's schema depends on nothing. A
module that ships without one is caught by the same refusal as any other
unclassified table.

**The right is its own, `company.export`, and the client holds it.** Not part
of a reading capability: it reads everything at once, and carries it out. The
question was whether only `owner` should hold it. In the firm's installation
the firm is the `owner` of every company and the person whose company it is
holds `client`. A right to leave that only the firm can exercise is not a right
of the client, it is a courtesy of the firm — the very lock-in this card exists
to remove, moved from the software into a permission. So `owner` and `client`
hold it, `accountant` and `viewer` do not: a collaborator of the firm has no
business walking out with a client's ledger, and a reader was invited to read.
A firm that must withhold it — a dispute, a lien where the law gives one —
revokes it per member like any other capability, and that revocation is a row
on the audit trail of the company, where the client can point at it.

**Under row level security, and whole or not written.** Every export function
is `security invoker`, and `service_role` and the owner of the database are
refused outright: for a role that bypasses row level security "what the caller
may read" means nothing, and whoever holds such a role already has `pg_dump`.
The CLI's connection is the owner's, so it steps down to `authenticated` inside
one transaction with the claim of the member it acts for. But row level
security alone fails in the wrong direction — it hands back fewer rows and says
nothing, so a member whose `bank.read` was revoked would leave with books that
have no bank in them and a manifest that looks complete. Each table is
therefore counted twice, as the caller and by `company_archive_row_count()`, a
definer function guarded by the same capability that answers a number and
nothing else. A difference is `export_incomplete`. The test found that a
`client` holds every reading the archive needs, modules included; it would have
said so if one had been missing.

**One snapshot.** An archive whose lines were read a moment after their
entries fails on arrival — after the company has left. `export_company_table()`
and `export_company_manifest()` are therefore `stable`: they read the snapshot
of the statement that calls them, and `export_company()` calls both in one
statement. Called table after table, as the CLI does to stream a large company,
they need a repeatable read transaction around them, which the CLI opens, and
it checks each file against the manifest as it writes it. The first draft had
them volatile, each statement on a snapshot of its own; a read of the functions
found it, not a test — PGlite has one connection and nobody to book meanwhile.

**An export is recorded, and the record is not a control.** `company_exported`
goes on the audit trail, written by `export_company()` and by the CLI before
they read, because a firm should know a ledger left and a client should know
the firm took a copy. It cannot be more than a record: the export reads nothing
its caller could not read table by table, without any function at all. It is
written by a definer function guarded by `company.export`; a holder could write
the line without exporting, which claims only that they could have.

**The format is rows.** JSON Lines per table, a manifest with the versions an
installation needs and a sha256 per file. Not `pg_dump`: it cannot cut one
company out, and its output is not something a living installation can take in.
Not SQL inserts either, which was the brief of the card this one reads
(`export --everything`): an `insert` script is restorable on an empty database
by whoever owns it, and runs with their rights — it cannot be refused row by
row, and an archive offered to a firm's installation by a stranger must be.
Decimals are strings because `1210.00` parsed as a float is how a ledger loses
a cent in transit. `jsonb` columns are carried as stored, so a tool that
rewrites an archive must copy lines and not parse them; the CLI does, and the
first run of the round trip is what found that it had to.

**Identifiers are kept.** A uuid is referenced from places no foreign key
knows: `attachments.entity_id`, `audit_log.record_id`, `entries.module_ref`,
the `jsonb` of the trail. A mapping would have to find all of them, forever.
Kept identifiers also decide what a second import does: the company is already
here, and `company_already_here` is the answer. An import never merges. It
follows that a company cannot come home while its original is still there,
which is right — two living copies of one ledger is the state to refuse.

**The people stay and their trace travels.** Members, invitations, keys and
shared links are excluded, each with its reason in the registry. The columns
that say who acted — `created_by`, `filed_by`, `sent_by`, the `actor_id` of the
trail — are not foreign keys, by the decision about `company_members` at the
top of this file, so they arrive unchanged and name nobody. A table of
correspondence was considered and not built: it would carry names and addresses
of the firm's staff into the client's hands, to make a trace prettier. If the
two installations share an identity provider the identifiers still mean
something; if not, they still tell two acts of one person from two people.

**Rows are inserted, not replayed.** Replaying through `post_entry()` draws new
numbers, stamps today on every act of the trail, and asks the period locks for
leave to rebuild what they protect. So `import_company()` inserts, with the
user triggers of the tables it fills switched off inside its own transaction —
`alter table … disable trigger user`, which leaves foreign keys on and takes a
lock that makes every other writer of the table wait, so nobody books without
guards in the meantime. `session_replication_role` would have been one line,
and switches the foreign keys off too. `audit_log` is never touched: its only
trigger refuses updates and deletes, and the function reads the catalogue to
see there is nothing to switch off. A reference that points forward or at its
own table — `companies` to its accounts, an entry to the one it reverses — is
filled in a second pass; which those are is read from the foreign keys and the
load order, not listed.

**What the triggers would have guaranteed is checked afterwards, and the
archive is not trusted.** It may come from anywhere. Before writing: checksums,
every row's `company_id`, no unknown table, no unknown column — data this
installation would drop in silence is a reason to refuse. After: every table
holds exactly the rows that arrived when read through the company, which
catches a row hung on a parent of a company that was already here; every
foreign key between exported tables stays inside the company, read from the
catalogue because most of them carry `company_id` and some do not; entries
agree with their lines and posted ones balance; matched amounts agree with the
matchings; no journal counter is behind a number already used. One failure and
nothing stays. The letters of the matching are held to their counter the same
way, and two financial years may not overlap. What is *not* re-derived: the
totals of a document against its lines, `amount_paid` against the matchings,
the computed balance of a statement, that a module tag names a module the
company holds, that the boxes of a tax posting agree — each is a trigger that
was off, each is content the archive is believed on, and none of them lets a
row reach another company. Nor is the law of a country: that a frozen
declaration's figures are what the ledger said then is taken from the archive,
as an opening balance is taken from a previous system.

**`security definer`, guarded on its first line.** Nobody holds a right on a
company that does not exist yet, so it cannot be invoker. The guard is
`create_company()`'s, in the same words: the installer, or an administrator of
the installation. After 18 September's two definer functions that checked
nobody, the refusal is tested for a member, for `service_role` and for a
client, and the function is in the sweep of `tests/client_preset.test.ts`.

**Where the new installation's testimony starts.** `company_imported` is
written on the trail with the origin, the date and the member who exported.
Everything before that line is what the archive said; everything after is what
this installation saw. The imported rows of the trail get new ids — an identity
is local — and keep their order.

**What the round trip found.**

- *`service_role` with a member's claim left with the books.* `has_capability()`
  reads `auth.uid()` whatever the role, so the first draft, which asked for the
  capability and nothing else, exported for a backend that put a user id in its
  claims — with row level security bypassed and the completeness check
  comparing a number with itself. The refusal of roles that bypass row level
  security came from there.
- *`is_installer()` answered NULL, and a guard that says `not` lets NULL
  through.* The first draft of `import_company()` took a company in for
  `service_role` with no claim at all. It was the whole family of guards, not
  this one: the section above is what came of it, and `20260918140000` makes
  the helper answer false. The guards of this migration are written
  `is not true` all the same, so that they hold whatever a helper answers, and
  the test asks them from a session where nothing was ever set.
- *A parsed archive is a changed archive.* `{"fee": 1.50}` inside a `jsonb`
  column came back `1.5` from `JSON.parse`, and the import refused its own
  export as corrupt. The checksum was right; the test was the tool that should
  not exist. The rule is now written in the format and the CLI never parses a
  row.
- *No leak between companies, in either direction.* The sweep compares every
  identifier in the archive of the company that leaves with every identifier in
  the archive of the one that stays, furnished the same way on purpose, on
  every pack that files: the two sets share the installation's id and nothing else. A
  predicate broken on purpose is caught three times — by the completeness
  check, by the sweep, and by the import.
- *The client can leave.* Every reading an archive needs is in the preset.

**Missing, and written.**

- **The files.** The bytes of the attachments are in a storage bucket. The
  manifest lists them and both commands say how many are to be carried by hand.
  A bucket-to-bucket copy is a job for the CLI signed in to both projects, and
  needs the storage policy that mirrors `attachments` — which does not exist
  yet either.
- **`attachments.storage_path` arrives as written.** Nothing in the database
  reads it as a permission, and the storage policy that will exist must not
  either: a hostile archive can name any path.
- **One call, one document.** `import_company()` takes the archive as one
  `jsonb`, bounded by Postgres at a gigabyte and by the client's memory well
  before. Tens of thousands of entries are comfortable; a company with millions
  of lines needs a staged load — rows into a staging table, then the same
  checks — and the checks are written so that they would not change.
- **The lock.** Importing makes every other writer of the filled tables wait.
  Nothing was measured on a busy installation.
- **A module turned off with rows in it stops the export** until somebody who
  may turns it back on, because turning a module off hides its rows from
  everybody. Honest, and a door the firm holds; an export that reads a disabled
  module's rows needs the module's policies to say so.
- **A machine key cannot export**, for the reason it has no portfolio: the
  company row is closed to it. Tested as it stands.
- **A company cannot be removed.** Leaving copies; nothing in the schema
  deletes a company and its ledger, and `audit_log` would outlive it by design.
  So "come home" and "move, then close the original" both wait for that card.
- **Older archives.** An archive of an older socle imports while every column
  it names still exists. There is no migration of archives; the day a column is
  renamed, `format_version` moves or the import learns the old name.
- **No MCP tool**, and no legal formats in the archive (FEC, XBRL, the invoices
  as files): the first is a small card, the second is `export --everything`
  proper, of which this is the part that had to exist before a firm is sold to.
- **Not run against a real Supabase project.** `alter table … disable trigger
  user` needs the function's owner to own the tables, which is how `ekwo
  migrate` leaves them. `scripts/e2e-supabase.mjs` does not walk this yet.
## A statement is imported once, and what "once" is keyed on (18 September 2026)

**A statement never becomes an entry.** `import_bank_statement()` stops at
`bank_transactions`, state `pending`. The doctrine of the settlement holds one
step earlier: a statement line becomes a payment when something says what it
pays, and an import that booked would be a second way of booking money.

**The contract is a list of keys, not a package.** The function takes jsonb —
what `@ekwo-ai/camt053` returns — and its header lists the keys it reads. The
core does not import the brick and the brick does not know the core; a reader
of another format returns the same keys or the importer is taught new ones.
That is not a shared abstraction between bricks: it is the core saying what it
takes, the way a brick that writes says what rows it reads.

**The key of a line.** Idempotence had to be an index, not a lookup — a module
already showed the form (`entries.module_code` / `module_ref`). What goes in it
was the question.

- *With a bank reference*: the reference, the position in a split batch, the
  booking date and the amount. The reference is the identity. Date and amount
  are not there to identify but to contain a bank that reuses references over
  the years, and they cost nothing, since a replayed movement has both
  unchanged. What the bank may reword between an intraday view and the final
  statement — the text, the counterparty's name — is deliberately left out, and
  a test rewords a line to show it is still known.
- *Without one*: everything the statement says about the line, **plus its
  occurrence among identical lines of the same file**. The alternative keys
  each lose something. Position in the statement is not stable across
  overlapping statements. A plain fingerprint merges two identical transfers on
  one day — two tenants, the same rent, the same word — and the ledger is then
  short of money nobody can find. The occurrence number keeps them apart and
  stays stable under replay and under overlap, because an overlapping statement
  lists the same day's identical lines in the same number.
- *What it cannot do*: two different, non-overlapping files that each carry one
  line identical in every field, from a bank that gives no reference and no
  end-to-end identifier. The second is taken for the first. It takes two
  statements of one account on one day to get there; it is written down rather
  than guessed around, because every guess (period overlap, statement order)
  breaks a commoner case.
- The file's checksum is **kept and not used** as a key: the same statement
  arrives in files that differ by a creation timestamp.

**A statement lists lines; a line exists once.** The published model had a line
belong to one statement, and `is_consistent` proved the closing balance over
the lines a statement owned. An overlapping statement would then either
duplicate lines or fail its own proof. `bank_statement_lines` is the list; the
line stays stored under the first statement that brought it; the two trigger
functions that compute `balance_end_computed` were replaced — not edited — to
sum what a statement lists or holds. A line entered by hand under a statement
counts as before.

**The balance is recomputed in the database.** The reader reports `balanced`,
and the function does not read that flag: a client is not a check. It sums the
booked lines it was given and refuses `unbalanced_statement` with the
difference. This is where the roadmap's "refused, by name" lives — the reader
returns the statement so a person can find the missing line; the importer
refuses it so the books never hold a statement that does not add up.

**The whole file or none of it.** A file of two statements with one unknown
account imports neither. Half a file imported is a state nobody asked for and
nobody can name afterwards.

**An unknown account is refused, never created.** A bank account decides a
journal and a ledger account; one created by an import is mapped to neither
and was decided by nobody. The message names the identifier.

**A break in the chain is a view, not a column.** "Previous" is the latest
statement that closed on or before the day this one opens *and opened before
it* — the second half keeps a fortnight from being the predecessor of the
month that contains it. Stored at import, a gap would stay recorded after the
missing month was imported; computed at read, it closes itself.

**`security invoker`.** The policies on the three tables already test
`bank.write`; nothing here needed to pass them. The explicit check at the top
exists for the message only. One consequence, kept: somebody who is not a
member is told `unknown_company`, because under their own eyes there is none.

**The guard "a pack names a format nobody reads"** is a test, not a command:
`tests/bank_statement_formats.test.ts` holds each name a pack gives as read or
owed. The `pack check` half belongs to the command line and is left for it.

**Not done, and written in `docs/international.md`**: amounts finer than two
decimals are refused because the columns hold two; an entry in another
currency than its account is refused rather than converted through
`currency_rates`, because no file that does it has been met; a CODA and a
camt.053 of the same month would import twice, and the test that says so waits
for the second reader. No CLI command. The MCP tool takes the file as text,
which bounds it to what a model can carry: a large statement wants the CLI.

## What produced an entry does not move (18 September 2026)

The previous section left one line open — "no trigger refuses a change of
`quantity`, `unit_price` or `tax_id` on a posted line" — and called it wider
than the change it was found in. It was wider than that sentence too.

**What went through, established before anything was written.** From the seat
of a member holding `documents.write` and nothing more — the `accountant`
preset — under row level security, in an open period, on an invoice
`post_document()` had just posted at 150:

- every column of `document_lines`: quantity, price, discount, tax (another, or
  none), account, name, description, unit, sequence, line type; a line inserted;
  a line deleted. The totals of the document followed each time — 750, 1 149,
  50 — against a ledger that still said 150;
- every column of `documents`: the three totals, `amount_paid`,
  `payment_state`, the number, the document date, the accounting date, the tax
  point, the customer, the currency and its rate, the type, the journal;
  `entry_id` nulled, which unhooks the document from its entry; `state` back
  to `draft`, after which `post_document()` books it a second time; `state` to
  `cancelled`, which no function of the schema does and which reverses nothing;
  and the row deleted, its entry left behind with no document.

What was refused: the language of the document and the category and rate of a
line, each by a guard of the last three days, and a second `post_document()`.
The period locks guard `entries` and `entry_lines` and say nothing of a
document.

The same probe found that the entry was no better off in an open period. That
is the section after this one, on its own, because every internal path that
writes an entry had to be read first. This one is the document.

**The rule is a closed list of what may still move, and the default is
frozen.** `20260918161204`, in the shape `tax_filing_boxes_are_frozen` has: a
`before` trigger that asks whether the state has left `draft` and refuses by
name, with SQLSTATE `55006` — the state of the period locks, which
`isRefusalState()` reads as the books saying no, so the command line exits 3
and the MCP server hands the name to the model. The guard compares the whole
row as JSON and lets through only the keys it names, so a column added next
month is frozen the day it is added; the test reads the columns from the
catalogue and tries every one, from three seats — an accountant, the owner, a
machine key — so that column has to be classified the day it lands.

On a document that is no longer a draft, what still moves:

| column | why |
|---|---|
| `amount_paid` | only to the figure the matching gives: `document_amount_paid()`, taken out of `documents_refresh_amount_paid()` so the writer and the judge cannot disagree. The guard judges the **value and not the path** — `reconcile()`, `unreconcile()` and whatever settles a document tomorrow pass without the guard knowing them; a figure keyed by hand is `document_amount_paid_is_derived` |
| `payment_state`, `amount_residual` | follow from it, by trigger and by the column's own definition; keyed, `document_payment_state_is_derived` |
| `sent_at`, `peppol_status`, `peppol_message_id` | what happened to the document *after* it was issued, which by definition is written after |
| `updated_at` | |

Nothing else. Not `due_date`: it is BT-9 on the invoice and the maturity of
the receivable in the ledger. Not `note`: BT-22 is printed, this table has no
internal note, and the day it has one it joins the list by name. Not
`reversed_document_id`: a credit note says what it credits while it is a
draft. Not `entry_id`: deleting the entry of a document would null it, so a
document now holds the entry it produced. Its **lines** keep every column and
lose none. Attachments and share links are rows of other tables and are
untouched: filing a scan under an invoice changes nothing the customer was
issued.

**The state goes one way.** `draft` to `posted` is one statement of
`post_document()` on a row that is still a draft, so it passes without the
guard knowing the function exists; the guard adds only that a document does not
become posted without an entry (`document_posted_without_entry`). `draft` to
`cancelled` is a draft abandoned. Out of `posted` there is no way, `cancelled`
included: no function cancels a posted document, and until one does — writing
the reversal with it — an `update` that says `cancelled` is a lie about the
ledger.

**How an issued invoice is corrected, then.** By a credit note: a document of
type `sale_credit_note` or `purchase_credit_note`, naming the invoice in
`reversed_document_id`, posted by the same `post_document()`, whose entry
mirrors the first, and matched against it with `reconcile()` so that both read
`paid`. That path existed and is now tested end to end as the accountant. It is
four statements where it should be one: `credit_document()` is the obvious next
function.

**Nobody is exempt, because nobody needed to be.** Nothing in the file asks
who the caller is. `post_document()` passes because
of *when* it writes; the matching because of *what* it writes;
`taxes_reach_draft_lines` and `contacts_language_reaches_drafts` because they
only ever touched drafts; a pack upgrade because it rewrites taxes and never a
document. The whole suite — every golden year, every module, the closing and
reopening of a year — ran against the guard and the only function that changed
is the one the figure was taken out of. One exemption is a fact rather than a
privilege: when the *company* is deleted the cascade removes its documents, and
the company's row is already gone when the cascade arrives.

**Nobody is born posted either, and an exemption was written and then
withdrawn.** A document inserted already posted, or a line inserted under one,
has no draft to have been: it is somebody loading books that were kept
elsewhere, which is what `import_company()` does. The first version of this
change opened the insert — and the insert only — to whoever may load a company,
the installer and an administrator of the instance. It would have been the one
exemption by identity in the file, and on most self-hosted installations the
administrator of the instance *is* the accountant.

It is gone, because the import does not need it: `import_company()` switches
the triggers of the tables it fills off, by name, inside its own transaction,
behind its own guard, and switches them back on. That is the rule this change
sets for a backfill, applied by a function — the guard is stepped around in one
place, where a reviewer reads it, and asks nobody who they are. So
`document_born_posted` is refused to everybody, the connection that installed
the schema included, and "nobody is exempt" is true of the whole file: no
statement in it reads `is_installer()` or `is_instance_admin()`.

Two other ways of letting a load through were looked at and dropped. Going
through a draft — the order the books were written in — is not faithful to the
cent: a draft line takes its snapshot and its amounts from the tax *as it
stands*. And a criterion of fact, "the line arrives in the transaction that
created its document", reads `xmin` and stops being true at the first
savepoint, which is every `exception` block of a function that loads a company.

`tests/posted_archive.test.ts` holds what that arrangement owes. The guards
are back on after a load that succeeded and after one that failed in the
middle. What arrived posted is frozen for the owner it was given to and for
the administrator who loaded it. And **the archive wins over the tax of the
day**, shown on a contradiction rather than assumed: an invoice posted at one
rate, the tax moved afterwards, the company exported — the archive carries a
tax at the new rate and a line frozen at the old one, and the line that arrives
is the old one, with a breakdown that still adds up.

**A document becomes posted only with an entry that is itself posted.**
`post_document()` posts the entry first and then the document, in that order,
so the guard can ask for it: `document_posted_without_entry` covers a missing
entry and one that is still a draft, since a draft entry is not yet in the
ledger the document claims to have produced. Being born posted dispenses from
nothing either: what `import_company()` loads is judged by the constraints, which
no trigger switch turns off — `documents_posted_has_number`,
`entries_posted_is_balanced` — and by the checks the import runs on the result.

**The totals of a posted document are no longer recomputed.** The trigger that
derived them fired on every write of a line, whatever the state — which is how
a changed line restated a sent invoice. The lines no longer move, so it acts on
drafts. `documents_refresh_totals()` is unchanged.

**The guards read as the schema, not as the caller** — and a test found it, not
foresight. The first version asked "is the company still there?" under the
caller's row level security. A machine key cannot read `companies`, was
answered *no row*, and "no row" was the answer that let the delete through: a
key could delete a posted invoice that an owner could not. Both guards are
`security definer`: what a guard decides must not depend on what the person it
guards against is allowed to see. That is why the third seat is in the test
for good.

The same seat found a defect that is older and not closed here: **a machine key
cannot write a document line at all**, draft or not. The line's own trigger
rounds by the company (`rounding_of()`), which reads `companies` as the caller,
and `companies_select` knows members and not keys — `unknown_company`.

**One guard on a line, not two.** `document_line_tax_frozen`, a day old, is
folded into `document_posted`; `document_lines_snapshot_tax()` keeps writing
the snapshot of a draft and refuses nothing. The guard of a line is named to
fire first among the `before` triggers of its table, so that a posted line is
refused by this name and not by whatever an older trigger trips over on the
way, and so that a derived column keyed on a posted line is judged as it was
keyed. `documents_guard_language` stays: it fires first and its sentence is the
better one for what it refuses.

**What the tests had to give up.** Two tests reached a posted row to stand on a
floor — a check constraint proved on a posted line, a share link judged on a
document made `cancelled`. They now switch the guard off *by name*
(`withoutTrigger` in the test helpers). That is also the instruction for a
future migration that must restate posted rows: it will be refused, and has to
disable the trigger in its own file, where a reviewer reads it. Two more replay
an older backfill last, on a database built without it; they now leave this
guard out of that database too, since on a real one the backfill ran before
anything froze the rows. Three tests that edited a posted line to prove
something about a snapshot prove it without touching the line.

## A posted entry is immutable, in an open period too (18 September 2026)

The schema has said so from the first day — in its comments, in every decision
that leans on it, and in the description of the audit trail the MCP server
hands to a model: "a posted entry is immutable and is corrected by a reversal,
so what is recorded is the act of posting and never the lines". What enforced
it was `entries_guard_period`, and that guards a *locked* period.

**What went through in an open one**, from the seat of a member holding
`entries.write`, under row level security: the lines of a posted entry deleted,
all of them; the entry deleted; its state set back to `draft`, after which it
is an ordinary draft. One amount changed on its own was refused — by
`entries_posted_is_balanced`, which two amounts changed together satisfy. And
because the audit trail records the posting and not the lines, on the ground
that they cannot change, none of it left a trace. The sentence the model was
given was false, and it was false about the one table an accountant must be
able to take on trust.

**Every path that writes an entry was read first**, because a guard nobody is
exempt from has to be one nobody needs an exemption from. They all do one
thing — insert a `draft`, insert its lines, call `post_entry()`:
`post_document()`, `post_payment()`, `post_module_entry()` (which is how every
module reaches the ledger), `opening_balance()`, `settle_cash_basis_tax()`,
`settle_filing()`, and `close_fiscal_year()` twice — its one `delete from
entries` is of a closing entry it has just created as a draft and found nothing
to put in. Where the schema undoes an entry it already does it by a **mirror**
naming the first in `reversed_entry_id`: `unreconcile()` for an exchange
difference, `reopen_fiscal_year()` for the entries of a close. Two functions
write to a posted row: `reconciliations_refresh_lines()`, the two matching
columns; and `entries_refresh_totals()`, which rewrote the totals on every
write of a line whatever the state. So the reversal was already the only way
this schema undoes an entry. What was missing is that nothing made it the only
way for anybody else.

**The same guard as the document's**, `20260918161538`, with the same closed
lists, the same SQLSTATE and the same absence of an exemption on `update` and
`delete`: once an entry has left `draft` it is not deleted, its state does not
change, no column of it moves but `updated_at`, and its lines take no delete
and keep every column but `matching_number` and `matched_amount` — the
exception `entry_lines_guard_period` has made for a locked period since the
first migration, because matching is not a change to the accounts. `entry_posted`,
by name. The whole suite ran against it and no function had to change to keep
working; `entries_refresh_totals()` changed for the reason below.

**Nobody is born posted**, as for a document: an entry inserted already
posted, or a line inserted under one, is `entry_born_posted` for everybody, the
installer included, and the exemption by identity that was first written for a
load was withdrawn here too. Books kept elsewhere arrive through
`import_company()`, which switches the triggers of the tables it fills off by
name. What it loads is still judged by what no switch turns off —
`entries_posted_is_balanced`, `entries_posted_has_number` — and by the checks
the import runs on the result; the period guards are triggers and are off with
the rest, which is right for an archive that brings its closed years with it
and is the import's question to answer, not this guard's.
`tests/posted_archive.test.ts` holds that the four guards are back on after a
load, failed or not, and that the entry which arrived is frozen for the
administrator who loaded it. `entries_refresh_totals()` now acts on drafts: a
trigger that restates the totals of a posted entry from its lines is how a
changed line used to become a changed entry.

**Definer**, for the reason found on the document: a guard asked under the
caller's policies is answered *no row* by whoever cannot read. Not named to
fire first, unlike the guard of a document line: the older guards of these two
tables — who may post, what a module tag may become, which period is locked —
refuse more precisely what they refuse, and keep answering first where they
do.

**The period guards keep their job.** A draft dated in a locked period is theirs
to refuse. The two are different questions — *may anything be written at this
date* and *may this row still change* — and the second no longer depends on the
first.

Still open: `reverse_entry()` does not exist. The path is sound and tested as
the accountant — a second entry, the sides swapped, naming the first — and it
is five statements where it should be one. And an entry's *date* in a closed
year is still only as safe as the lock: the freeze is about the row, not about
when it may be born.

## Two formats of fixed positions, and the same month twice (18 September 2026)

**The gap.** The Belgian pack says its banks send CODA and the French one
CFONB 120, and `tests/bank_statement_formats.test.ts` held both as owed.
`@ekwo-ai/coda` and `@ekwo-ai/cfonb120` read them. Both were written from the
published lay-out — Febelfin's standard 2.6 and 2.8, the CFONB brochure of 2004
and its SEPA addendum of 2010 — and from no example.

**Two bricks, and the same fields.** A format is not a country, and two formats
that look alike are two formats: 128 positions and 120, a sign in its own
position and a sign written over a digit, three decimals always and a number of
decimals read from the record. They share no code — each carries its own
decoder, its own forty lines of MOD 97. They do return the same fields under
the same names as `@ekwo-ai/camt053`, each in its own `types.ts`. That is the
decision of the import, which said "the contract is a list of keys, not a
package", applied from the other side: a reader returns those keys, and an
integration test hands what it returns to `import_bank_statement()` with
nothing in between. What only one format says comes after, under its own name.

**A wrong length is thrown, a wrong sum is returned.** The camt.053 reader drew
the line — thrown when there is no statement to hang a violation on, returned
when there is — and these two keep it. A record that is not exactly as long as
the format says moves every field after it, so it is thrown, with its number,
and nothing is padded: a reader that pads cannot tell a trimmed record from a
truncated one. An unknown record, a record out of place, a record of another
account in the middle of a statement: thrown. A balance that does not follow, a
trailer that disagrees with the file (CODA counts its records and totals its
debits and credits), a structured communication that fails its modulo 97:
returned, as written, never corrected.

**An encoding is said, never guessed.** UTF-8 decoded fatally reads the ASCII
both standards write. ISO-8859-1 is an option the caller sets, because every
sequence of bytes is valid ISO-8859-1 and a fallback that cannot fail is not a
check. EBCDIC, which the CFONB brochure describes, is refused by name.

**A total and its details are never both counted.** CODA's trailer defines its
own totals as "the sum of the amounts in type 2 records with detail number
0000", which settles what a movement is. The records under the same sequence
number are its details; the movement is split into them when, and only when,
they add up to it exactly — the rule of the camt.053 reader, word for word —
and a type 9 is followed beneath its type 7 by the same rule. The globalisation
code is returned and not used: the hierarchy the transaction type gives is the
one the trailer's arithmetic supports.

**The Belgian structured communication comes back as twelve digits**, with
`type: 'SCOR'` and `issuer: 'BBA'`, because that is how a camt.053 carries the
same payment and the core strips everything but letters and digits before it
compares. `+++…/…/…+++` is how it is printed, and a function gives it.

**CFONB 120 carries no country, so the reader supplies none.** Its account is a
bank code, a branch code and a number; the core finds an account by what is in
`bank_accounts.iban`. The reader returns the three joined unless the caller
names a country (`ibanCountry`), and then returns the IBAN they make there —
the key of the relevé d'identité bancaire, then ISO 13616. The country is an
argument of whoever imports, which knows where the account is held; it is not a
default, and the MCP tool passes it on (`iban_country`) and never fills it in.

**A year on two digits** is read around a pivot the caller can move (80). It is
a limit of both formats, written in both READMEs.

**The same month in two formats — what is guaranteed, and what is not.** The
roadmap named this trap, and the import had written it down to wait for the
second reader. Measured in `tests/coda_cfonb120.test.ts`:

- *Guaranteed*: a format replayed against itself creates nothing. A CODA line
  is keyed on its bank reference, its position in a split total, its date and
  its amount; a CFONB 120 line, which has no bank reference, on the fingerprint
  of everything the file says about it and its occurrence among identical
  lines.
- *Holds when the bank is consistent*: a CODA then a camt.053 of the same day
  whose `AcctSvcrRef` is the CODA reference — the lines are known, none is
  imported twice. The statement is still stored twice, because the two formats
  name it differently (`2026-042`, made of the year and the sequence number,
  against whatever `Stmt/Id` the bank chose); each lists the same lines and
  proves its own balance, which is what `bank_statement_lines` was made for.
- *Not guaranteed, and asserted as it is*: when the references differ or the
  camt.053 has none, **the day is imported twice and no warning is raised**.
  Febelfin's own standard (§ 7.4) calls the reference "purely informative",
  says the bank "may change this reference without prior notice" and advises
  against "any kind of programming in this field". So the good case is a
  courtesy of the bank.
- *Never*: a CFONB 120 and a camt.053 of the same month. The format gives a
  movement nothing the bank calls it by — the entry number is a cheque number
  or zeros, the `REF` complement is the payer's — so there is nothing to
  recognise a line by, and the month is imported twice.

This is a gap and is not dressed up as anything else. The fix is not in the
key: a fingerprint across formats compares a name cut at thirty-five characters
with one that is not, a label with a remittance. What *is* comparable across
formats is the statement — same account, same closing date, same two balances,
another `source_format` — and an import that met one could say so by name. It
needs a migration and a decision about fortnights and months, and is written in
`docs/international.md` as the next change.

**What reading the standards found.**

- The import's numbering check (`statement_number_gap`) subtracts sequence
  numbers, and CODA's **restarts at 001 every year**: the first statement of
  January is "numbered 1 and the previous one 250", a gap of −250. It is a
  warning and not a refusal, and it will be wrong once a year per account.
  For the same reason the reader does not offer the *paper* statement number as
  `legalSequenceNumber`, which the import prefers: the standard lets a bank
  write a Julian date or zeros there, and a Monday would be two missing
  statements.
- A CODA **day without movement has no new balance record** — header, old
  balance, trailer — so it has no closing balance and the import refuses it
  (`statement_without_balances`). The reader invents none. Importing nothing
  for a day on which nothing moved loses nothing; the hole it leaves in the
  numbering is the warning above.
- `source_format` is read from a key called `namespace`, which is XML's word.
  The two readers fill it (`coda.2`, `cfonb120`) rather than teach the import a
  second key in a change that has no migration; a `format` key is returned too,
  for the day it is read.

**MT940: a separate card, and the argument.** The roadmap asked for the choice
to be made here. Not now. The balance, the dates and the amounts of an MT940
read as reliably as a CODA's; the counterparty and the communication do not —
they arrive in field `:86:`, whose sub-fields (`?20`…`?32`, or none, or
`/NAME/`-style tags) differ by country and by bank, with no single published
lay-out to read them from. A reader that returned the money and a blob of text
would import lines the reconciliation can never match, and it would look
finished. The two formats in this change each have one public specification
that says where the counterparty is; MT940 has the dialects of the banks that
send it. It wants a user with files, and the first dialect named after the
bank it was read from.

**Not done.** No file from a real bank was read by either reader — every
fixture is invented, and builder and reader share an author. CODA's annex II
(what each transaction code means) and twenty of its structured communications
are returned as written, not decoded. No CLI command imports a statement yet,
in any format. Windows-1252 and EBCDIC are refused rather than read.
## An entry is posted by post_entry(), and the guard judges facts (18 September 2026)

The two guards of this morning froze what is posted and looked only at the way
*out*. The way in was left alone on the ground that it is one statement of
`post_entry()`. It is also one statement of anybody's.

**What went through.** As the `accountant` preset, which holds `entries.post`,
under row level security, on a balanced draft: `update entries set state =
'posted', number = 'HAND/1'`. Two check constraints, the capability and the
period lock stood in the way. What did not: the number was chosen by hand in a
country whose law forbids a hole in the sequence — the one thing
`post_entry()` refuses by name, `numbering_gapless`; `posted_at` and
`fiscal_year_id` stayed null; an entry with no line balances at zero and was
accepted; the period was not asked the stricter question. And the guard then
froze the result for good. On a document, `update documents set state =
'posted', entry_id = …` pointing at a legitimately posted entry that was *not*
the one the document produced went through as well: `document_posted_without_entry`
only asked that the entry be posted.

**A flag would not have held.** The obvious fix is a transaction-local setting
raised by `post_entry()` and read by the guard. A custom setting is writable by
any session that can run `set_config`, and `post_entry()` runs as its caller,
so there is no privilege to hide the flag behind: it would say "post_entry is
running" for whoever said so first. `is_installer()` reads a setting too, but
it also requires that there be no session and no key, which is exactly what
cannot be required here.

**So the transition is held to what `post_entry()` produces**, all of which is
on the row or in the counter (`20260918171946`): an instant it was posted at;
no financial year but the one the date falls in; at least one line; an open
period, asked the way the function asks; and the number. In a country that
numbers without a hole, for a caller who does not hold `entries.import`, the
number has to be the last one the counter of its journal delivered.
`next_entry_number()` advances that counter in the same statement and holds
its row until the transaction ends, and a number already used is refused by
the unique index — so "equal to the last delivered, and unique" *is* "just
drawn". Elsewhere a number chosen by hand is what `post_entry()` allows too, and
the guard brings the counter up to it as the function does. `entry_posted_by_hand`.

A row that satisfies all of it is, fact for fact, the row `post_entry()`
writes, and is let through whoever wrote it. That is not a door left open: a
rule about facts cannot refuse the facts, and nothing is lost by it.
`post_entry()` and the seven functions that call it are unchanged, as are
`rehearse_post_document()`, `post_module_entry()` and the golden years;
`import_company()` switches the guard off for a load, as before.

**The cost, said plainly**: the conditions of `post_entry()` are now read in two
places. `tests/posted_by_hand.test.ts` walks each refusal of the function
beside the same attempt by hand, from three seats, so that a condition added to
one and not to the other fails a test. The check is written inside the trigger
and not in a function beside it: a function nobody may call is one the grants
doctrine has no honest line for, and `tests/grants.test.ts` said so.

**For a document the facts are on two rows**: the entry names this document —
`entries.document_id`, written by `post_document()` when it builds the entry
and frozen with it —, the document is booked on its entry's day, and it carries
the number it had or its entry's. `document_posted_by_hand` otherwise. A member
can still build, by hand, a draft entry that names their draft document, post
it through `post_entry()`, and then flip the document: every fact is then true,
and what they have done is keep books by hand, which `entries.write` is the
right to do. What they cannot do any more is hang an invoice on somebody
else's entry.

Found on the way, not closed here: **a machine key posts an entry with no
financial year.** `post_entry()` reads `fiscal_years` as its caller, a key
cannot, and the year comes back null — which is why the guard accepts null and
refuses only a year that is wrong. It belongs with the other defect of the same
seat, `rounding_of()` reading `companies`.


## What is posted is undone in one gesture (19 September 2026)

The guards of 18 September said how a posted row is undone and nothing did it.
The decision of 18 September left `reverse_entry()` as the open item; this is
it, and its twin for a document (`20260919090000`).

**Two functions, each the whole gesture.** `reverse_entry()` writes the mirror
of a posted entry in its journal — every line on the other side, with its tax,
its box at the opposite sign and its analytic split — names the original, posts
it through `post_entry()` and matches the two. `cancel_document()` writes the
credit note of a posted invoice from its lines, names the invoice, posts it
through `post_document()`, matches the two entries and marks the invoice
`cancelled`. Both insert a draft and call the one function that posts it, so
there is no second reading of the numbering, the locks or the capability, and
the audit trail records the acts through the triggers that already record them.

**The date is not chosen for the caller.** The original's while its period is
open; refused by name, `reversal_date_needed`, when it is not. Picking "today"
or the first open day would decide which declaration the correction falls in,
and that is somebody's decision about a filing.

**A credit note is written from the invoice's lines, not mirrored from its
entry.** It is a document of its own, printed and sent, and its entry is
`post_document()`'s to write under the credit-note postings of each tax. So it
mirrors the invoice only as long as the same lines give the same figures, which
is checked before anything is posted (`credit_note_differs`). The rate is the
invoice's, so the two ledgers match to the cent; no date is copied, so the tax
point of the correction is its own day under the country's rule.

**What something else wrote is undone there.** A document's entry, a close's,
an opening, a payment's, a bank line's, a module's, a declaration's settlement,
a matching's exchange difference or tax transfer: each is refused with the
thing that undoes it named. A matched entry or a paid invoice is refused too:
unmatching is a decision about money that moved, and it is left to whoever
makes it.

**The matching is part of the gesture**, so both functions ask for
`reconcile.write` up front, and `match_reversal()` refuses a caller who cannot
read the chart — which lines are reconcilable is written there, and a caller
who cannot see it would otherwise find nothing to match and leave both open
without a word. That was found by a test, from the seat of a key.

**One way out of `posted` for a document**, judged on facts as the way in is:
a posted credit note of the matching type names it, carries its total, and the
document's third-party lines are matched in full against that credit note's
entry and nothing else; the caller holds `documents.post`. Anything else is
`document_cancelled_by_hand`. `payment_state` derives `reversed` for it.

Still open: unmatching the pair after the cancellation is not refused, and
leaves a cancelled invoice reading `not_paid`, which is what its matching then
says. And a country whose law lets a posted document go back to draft — a
`posted_edit_policy` of the pack — waits for a product decision.

## What has not left goes back to draft, where the country allows it (19 September 2026)

The two items the entry above left open, closed (`20260919190727`).

**The country says it, as data.** `documents.posted_edit_policy` of the pack —
`reversal_only` or `unpost_if_untouched` — compiles to `country_defaults`
with the article behind it, like the other document rules. A pack that says
nothing is read as `reversal_only`. That is the one place a null is read as a
value rather than raised on, and the reason is the direction: the other nulls
would borrow a country's law to *bind*; this one withholds a permission, and
the answer it gives is the stricter one, which every law accepts. The rule
that loosens is also the one `ekwo pack check` asks a citation of on every
status, `community` included.

**Belgium and France say `reversal_only`, and no pack says the other word
yet.** The texts the Belgian pack already cites require it: the Code de droit
économique, art. III.87, § 2, keeps books "de manière à garantir […]
l'irréversibilité des écritures", art. III.88 keeps a rectified entry
legible, and the royal decree of 21 October 2018 that the pack's chart comes
from applies both to books kept by computer (art. 4). None of the pack's
sources carves out a provisional stage during which a booked invoice could become a draft again — nor does the
commission's opinion on computerised books (CNC 2016/22). France is the clear
case: PCG art. 921-3 turns "no blank, no alteration" into a validation that
forbids modifying or deleting an entry, and the tax code wants a continuous
sequence. So both declare `reversal_only` with the citation, and the others
stay silent. A pack moves to `unpost_if_untouched` when somebody cites the
text that allows it; the mechanism is complete and tested on a pack the test
database is told to treat that way.

**What "nothing has left" is**, each refused by name with what to do instead:
never sent (`sent_at`) nor on Peppol; not settled and not credited; named by no
entry beyond its own; its period open for its booking day and for every tax
point of its lines, asked the stricter question posting asks; no declaration
gone over those days, whether or not the tax lock was moved after filing; and,
where numbering is gapless, its number the last its journal drew.
`unpost_refusal()` is that list, once. `unpost_document()` raises what it
returns, and the command line and the MCP server ask it to choose.

**The number goes back to the counter; the draft gives it up.** Keeping the
number on the draft cannot be made right. Either the counter stays, and the
journal shows a hole where the entry was — exactly what a gapless country
forbids, and what the last-number rule is there to prevent — or the counter
steps back, and the next document of the journal is issued under a number a
draft still wears. So where the number was the last drawn, the counter steps
back by one and the draft carries no number; posting again draws the same one.
A number the draft had of its own before posting, one that was not its
entry's, stays. Where the country allows a hole and the number was not the
last, it is given back to nobody, and the record says so. The booking day and
the tax point go back to null where posting had derived them, so that a draft
corrected afterwards is booked on what it now says; a value that differs was
keyed and stays.

**The exception is a row, not a fact and not a flag.** The way to `cancelled`
is judged on facts because the facts are there afterwards: a credit note, a
matching. Here they are not — once the document is a draft and the entry gone,
nothing says which happened first or by whose hand, and an entry keyed by hand
that names a draft document would look exactly like the one that was taken
away. A transaction-local setting was refused on 18 September for being
writable by anybody. So `unpost_document()` writes `document_unpostings`, a
table no role may insert into, and the guards let through exactly the
transition and the delete that row names, in the transaction that wrote it.
The function is `security definer` for that alone, and asks for
`documents.post` itself before reading anything. The row is also the record of
the act — the only trace of an entry that no longer exists — so it travels
with a company's archive and its insert is audited as `document_unposted`,
beside the `document_draft` of the document.

**One entry point, two functions.** `cancel_document` in the MCP server and
`ekwo cancel` ask `unpost_refusal()`: nothing against it, back to draft;
anything, the credit note, with that sentence as the reason. Both say which
they did, in `undone_by`. A date, or `credit_note` / `--credit`, asks for
the credit note outright — a date is when a correction is booked, which only a
credit note has. The choice is written once, in `undoDocument()` of the core.

**A cancelled invoice stays matched to its credit note.** Unmatching the pair
after `cancel_document()` left an invoice that said `cancelled` and `not_paid`
at once. The matching is what makes `cancelled` true, and nothing takes it
back: `reconciliations_guard_cancelled()` refuses it, for everybody, as
`document_cancelled_stays_matched`. A document that was right after all is
issued again.

## A cadence is a number of months, and a frozen box is at the unit of its form (21 September 2026)

**Three new cadences, and no list of names in the functions.** `bimonth`,
`four_month` and `half_year` join `month`, `quarter` and `year` in
`declaration_period`, in their own migration because an enum value cannot be
used in the transaction that adds it. Every function that turns a cadence into
dates now reads `declaration_period_months()` — 1, 2, 3, 4, 6, 12 — and
`declaration_period_start()`, anchored on 1 January. The alternative, a `case`
per function, is what `upcoming_filings()` had, and it filed anything that was
not a month or a quarter as a year without a word. The anchoring is the
calendar year's for all six because it is the only one the three older
cadences ever had and the one the Irish Act writes; a cadence anchored on a
fiscal year would be a new value, not a new anchoring of an old one.

**The guard of `vat_return()` is not replaced.** It calls
`declaration_period_of()`, which now recognises the new shapes, and its four
conditions are unchanged: a half-year asked of a form that is not filed
half-yearly is still an analysis and goes through.

**A frozen box has no scale.** `tax_filing_boxes.amount` goes from
`numeric(16, 2)` to `numeric`. Lifting the precision of a numeric does not
rewrite the table and changes no stored value, which is what immutability of a
filed declaration asks. The ledger itself stays at two decimals: widening it is
twenty columns, generated columns and views, and belongs to its own change.

**The unit is the form's, applied at the freeze, not in the return.**
`tax_report_templates.rounding_unit` (a power of ten, with its text) is read by
`filing_rounding()` only, which coarsens the currency's `money_rounding`, and
`prepare_filing()`, `supersede_filing()` and `filing_drift()` pass each figure
through it. `vat_return()` keeps answering exact figures: it is also the
analysis, the golden and the drift, and a return that answered whole dollars
would hide the cents the ledger holds. Each box is rounded from its own exact
figure, so a total is the exact total rounded; a form that asks for the sum of
rounded lines would be a second word here, and none does so far. `vat_return()`
gains no `filed_amount` column, which the design had proposed: changing its
return type means dropping and recreating it, and `round_amount(amount,
filing_rounding(company, report_code))` says the same thing to any reader who
wants it.

**Seeds that do not use it do not change.** The compiler writes the three
columns only for a form that declares `rounding`, as it did for
`einvoice_obligation`: every other seed is byte for byte what it was, and runs
on a schema from before the column.
