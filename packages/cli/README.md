# ekwo

The installer and the operator's tool for [Ekwo OS](https://github.com/Ekwo-ai/ekwo-os).
One command turns a Supabase project you already own into a set of double-entry
books: the schema, the chart of accounts, the VAT codes, the first
administrator, the first company and its first financial year.

```sh
npx -y ekwo-os@latest init
```

The package is `ekwo-os` and the command it installs is `ekwo`:
`npx -y ekwo-os@latest <command>` runs it without installing anything, and
after `npm install -g ekwo-os` every example below that starts with `ekwo `
works as written. Keep the version in the command: run from inside a clone of
the Ekwo repository, a bare `npx ekwo-os` finds the workspace package of the
same name, which links no command, and answers `ekwo: command not found`. With
`@latest`, `npx` fetches the published CLI wherever it is started; the clone's
own is `node packages/cli/dist/bin.js`, after `npm run build`.

You need Node 20 or later. That is the whole list. The Supabase CLI is not
required — this talks to Postgres directly — and Docker is not required
either.

## From a free Supabase account to a first invoice

1. **Create a project** at [supabase.com](https://supabase.com). The free plan
   is enough to start. Ekwo does not create it, does not pay for it and has no
   access to it: it is yours from the first row.
2. **Copy two things** from the dashboard:
   - Project Settings → Database → **Connection string** (URI). It contains
     your database password.
   - Project Settings → API Keys → the **secret key** (`sb_secret_…`), and the
     **Project URL**. A project created before the new keys has the legacy
     **`service_role` key** instead, and it works the same. These are used
     once, to create the first administrator in your own Supabase Auth, and
     are never written to disk.

   **Take the pooler string, not the direct one, unless you know you have
   IPv6.** The direct host `db.<ref>.supabase.co` resolves to an IPv6 address
   only on any recent project, so from an IPv4-only network it simply never
   connects. The session pooler answers on IPv4 and supports everything a
   migration needs:

   ```
   postgresql://postgres.<ref>:<password>@aws-1-<region>.pooler.supabase.com:5432/postgres
   ```

   The region is in the hostname the dashboard gives you, and so is the
   generation prefix, which the region does not determine: verified on a real
   project on 11 September 2026 in `eu-west-3`, where `aws-1` worked and
   `aws-0` answered "Tenant or user not found". Copy the line from the
   dashboard — Connect → Session pooler — rather than building it by hand.
3. **Run the installer.**

   ```sh
   npx -y ekwo-os@latest init
   ```

   It asks for the connection string, the country, the chart of accounts and
   the language where the pack offers a choice, your organisation, the
   currency, the first company, the address of the first administrator and —
   optionally — the IBAN of your main bank account, then does the rest. Five
   to ten seconds on a free project. Nothing is preselected for you on the
   three questions whose wrong answer is expensive: the country, the chart and
   the language.

4. **Sign in** to your project as that administrator and start booking — in
   the web application, [Ekwo Cloud](https://cloud.ekwo.ai), which opens your
   own instance, or through the REST API Supabase generates from the schema,
   `psql` or `@ekwo-ai/core`.

5. **Do the four things below**, while the dashboard is still open. The
   installer prints them at the end of a successful run, because three of them
   are settings of your project rather than rows in your database, and nothing
   holding a connection string can reach them.

Everything above in one non-interactive line:

```sh
npx -y ekwo-os@latest init \
  --db-url "postgresql://postgres.YOURREF:PASSWORD@aws-1-eu-west-3.pooler.supabase.com:5432/postgres" \
  --supabase-url "https://YOURREF.supabase.co" \
  --service-role-key "$SUPABASE_SERVICE_ROLE_KEY" \
  --country BE \
  --chart default \
  --language fr \
  --org "My Organisation" \
  --company "My Company" \
  --admin-email "you@example.com" \
  --admin-password "a-long-password" \
  --fiscal-year 2026 \
  --iban "BE71096123456769" \
  --yes
```

`--chart` and `--language` are in that line because the Belgian pack offers a
choice on both, and `--yes` means there is nobody to ask. See "Installing
without a terminal" below.

## Installing without a terminal

`--yes` turns off every question, and then every answer has to arrive as a flag
or an environment variable. Two of them are worth knowing about before you
write the script, because `ekwo init` **refuses rather than picking one for
you**:

- **the chart of accounts**, where the country publishes more than one. Belgium
  publishes two, a company chart and an association chart. Pass `--chart`; the
  refusal lists the codes the pack carries.
- **the language of the books**, where the pack publishes more than one. Pass
  `--language`; the refusal lists them. The choice decides which label of the
  pack lands in `accounts.name`, and the others stay beside it in `name_i18n`,
  so it is not irreversible — but it is not a question a script should answer
  by accident either.

`--country` behaves the same way and has no default at all: the refusal names
the packs the database holds. A preselected country is a chart of accounts
nobody chose.

The same is true of the financial year: a pack that declares no usual opening
month makes `--fiscal-year-start` required. Most packs name the calendar year
in `defaults.fiscal_year_default`; one that names none — the United Kingdom's,
where a company's year ends on the accounting reference date it chose — asks
for the day.

`ekwo company new` asks the same questions about every other company, and
refuses the same way.

## Several countries in one installation: `init --no-company`

An installation is not in a country; its companies are. `ekwo init` loads every
pack of the release whatever `--country` says, so one installation keeps the
books of companies in as many countries as it holds packs. When there is no
"first company" to name — a group, a firm, a holding with subsidiaries abroad —
install without one, then create each company in its own country:

```sh
npx -y ekwo-os@latest init --no-company \
  --db-url "$EKWO_DB_URL" --supabase-url "https://YOURREF.supabase.co" \
  --service-role-key "$SUPABASE_SERVICE_ROLE_KEY" \
  --org "My Group" --admin-email "you@example.com" --yes

ekwo company new "My Company Belgium" --country BE --chart default --language nl --yes
ekwo company new "My Company France"  --country FR --language fr --yes
ekwo company list
```

`--no-company` runs the migrations, the seeds of every pack, the modules, the
first administrator, `init_instance()` and `claim_instance_admin()`, and
nothing else. The instance row records no country. A flag that only describes
a company — `--country`, `--company`, `--chart`, `--language`, `--currency`,
`--fiscal-year`, `--fiscal-year-start`, `--vat-period`, `--filing-period`,
`--iban`, `--bic`, `--bank-name` — is refused with it, exit code 2, before the
database is touched: it would describe nothing.

**`ekwo company new` is `create_company()`**, the function the `create_company`
tool of the MCP server calls: the country pack copied in, the first financial
year opened, the administrator its first owner. It is called as an
administrator of the installation — `--as-user`, or the only one when there is
exactly one — so the database judges that person exactly as it judges the tool:
anybody else is refused, `not_instance_admin`, exit code 3. Before the call,
the CLI asks what `ekwo init` asks about its first company, from the packs the
installation holds, and refuses the same way off a terminal: no country without
`--country`, and `--chart`, `--language` and `--fiscal-year-start` wherever the
pack offers a choice. `--currency` and `--fiscal-year` override the pack and
this year.

Without `--no-company`, `ekwo init` does what it always did, and the installation
takes more companies later the same way. Neither writes a country into
`ekwo.json`: see below.

## Where table access comes from

**The schema grants its own rights.** Every table, view and function of Ekwo
names the roles that may reach it — `anon`, `authenticated`, `service_role` —
in the migration that creates it. `ekwo doctor` reads the privileges of a live
database and reports a grant that is missing, a grant wider than the release
declares, and a table `anon` can reach at all.

Two rules follow, and both are worth knowing before you change anything by
hand.

**`anon` holds no privilege on any table.** The anonymous role — the one behind
the publishable key your front end ships — may execute the ten helper functions
row level security calls on its behalf, and nothing else. An anonymous request
to a table is refused at the privilege, before any policy is read. If part of
your application reads a table without signing a user in, it will stop working,
and that is the intended answer: sign the user in, or grant a function
deliberately.

**`authenticated` may attempt exactly the verbs a policy of that table is
prepared to judge.** A grant and a policy are two halves of one sentence: a
grant says which verbs may be attempted, a policy says on which rows they
succeed. The reference tables a country pack fills, the tables written only by
a `security definer` function, and the audit trail are readable and not
writable — by privilege as well as by policy.

**It was not always so, and the history explains a symptom you may still meet
on an installation nobody has migrated.** Until the migration of 14 September
2026, nothing in `supabase/migrations` granted table access at all. Row level
security was written in the migrations in full and the underlying `GRANT` was
not: on a Supabase project it came from that project's own default privileges
on the `public` schema, which are there before Ekwo is. Those privileges live
in `pg_default_acl`, keyed by the schema, so dropping and recreating `public`
took them away — and then the reinstall succeeded, `ekwo doctor` reported a
healthy installation, and the first read through PostgREST answered
`permission denied for table companies`. Nothing was wrong with the schema; the
grant that had never been in it was missing.

On an installation that has run `ekwo migrate` since, that cannot happen: the
migrations put the privileges back themselves, and they take away the blanket
table access the project's defaults had handed `anon`. Dropping `public` is
still not something to do on a project you intend to keep — it takes your books
with it. The decision and what it changed are in
[decision 0003](../../docs/decisions/0003-the-schema-grants-its-own-rights.md).

## Before you go live: four things on your project

An installation leaves four things undone, and they are undone on purpose:
they are yours to decide, on a project Ekwo does not have access to. `ekwo
init` prints this list at the end of a successful run. `ekwo doctor` does not
check it and does not mention it — a database connection cannot see the
settings of the project it is connected to.

**1. Turn off self sign-up on your project.**
Supabase dashboard → **Authentication → Sign In / Providers → "Allow new users
to sign up"**, and switch it off. A fresh Supabase project accepts anyone who
posts an e-mail address and a password to its authentication endpoint, which is
the right default for a public application and the wrong one for a set of
books. An Ekwo installation is closed: the people who keep the books are
invited to it. Row level security means a stranger who signs up sees nothing —
they are a member of no company — but they are a row in `auth.users` that
nobody asked for, on a project whose sign-up endpoint is open to the internet.

**2. Keep two administrators.**
An instance administrator is what claims the instance and invites everybody
else. With one, a lost password, a closed mailbox or a person on holiday is a
set of books that nobody can let anyone into. Create the second account in your
Supabase Auth and add it with `claim_instance_admin()`, or invite it from the
application once it is signed in.

**3. Keep the service_role key off every machine that does not need it.**
It is not a powerful user: it is the absence of a door. A request carrying it
bypasses row level security entirely and reads every company in the instance.
This CLI reads it from a flag, an environment variable or a masked prompt, uses
it once to create the first account, and writes it nowhere — see
[Secrets](#secrets). Anywhere else it sits, it sits as a copy of your whole
ledger. `--admin-user-id` installs against an account that already exists and
needs no key at all.

**4. Read DISCLAIMER.md before you file anything.**
[`DISCLAIMER.md`](../../DISCLAIMER.md), at the root of the repository. A
country pack is a reading of a country's rules at the date of its version, and
its golden test proves that the pack agrees with itself — not that it agrees
with the law. `ekwo init` prints the certification status of the pack it
installs for the same reason. The books are yours, in every country where you
file.

None of these is an action Ekwo performs on your project, now or later. The
project is yours from the first row: the settings are yours to change, the key
is yours to hold, and what you file is yours to answer for.

Automatic verification of the first three is a phase 1 question, and it is not
free: they are answered by the Supabase management API, so checking them means
handing `ekwo doctor` a management token, and a token that can read a project's
settings can change them. Until that trade is worth making, the list is printed
and read by a person.

## What `init` does, step by step

| Step | What happens | Why it is done this way |
|---|---|---|
| 1 | Applies `supabase/migrations/*.sql` in order | Recorded in `supabase_migrations.schema_migrations`, the Supabase CLI's own history table, so `supabase db push` and `ekwo migrate` stay interchangeable |
| 2 | Applies every reference seed of `supabase/seed/`, in file-name order: `00_currencies.sql`, `00_territories.sql`, `05_framework_generic.sql`, then one `<n>_pack_<cc>.sql` per country pack, in the order of the number each pack declares | The currencies, the territories the tax rules name, the country-less financial statements every chart falls back on, and every country pack of the release — so a company in any of them can be created later without installing anything. They are exactly the seeds `supabase/config.toml` lists (a list `ekwo pack build` writes from `packs/`), so `supabase db push` installs the same set; a test compares both paths row by row. `90_demo_company.sql` is sample data and is never applied here |
| 3 | Creates the first administrator through the Supabase Auth admin API | See below: a database connection cannot be a signed-in user |
| 4 | `init_instance()`, `claim_instance_admin()`, the company, `company_members` as owner, `install_country_template()`, the first financial year, and the bank account when an IBAN was given | The six steps of the root README, in the same order, plus the one thing nobody can derive |
| 5 | Writes `ekwo.json` | The installation: project URL and schema version. Nothing else, ever — no country, since each company carries its own. A file written by 0.6 or earlier also names a country; it is still read, and the key is taken for nothing |
| 6 | Asks whether to register with Ekwo | The default answer is no, and no is a supported answer forever |

Every step checks before it acts. Running `ekwo init` twice on the same
project reports what was already there and creates nothing a second time.

### Why the first user goes through Supabase Auth

Every row level security policy in the schema compares `auth.uid()` against a
row, and `auth.uid()` reads the JWT of the request. The CLI holds a Postgres
connection, not a session: it runs as the database owner, `auth.uid()` is
NULL, and row level security is *bypassed* rather than satisfied. So the
installer cannot be the first user. It can only create one and then write the
rows that user will be recognised by.

Creating that user in SQL is not an option either. `auth.users` belongs to
GoTrue — the password hash, the confirmation state, the identity row — and
writing it by hand produces an account that looks right and cannot sign in.
Hence the order: the admin API first, its user id second, `instance_admins`
and `company_members` third.

This is the only reason `--service-role-key` exists. Pass `--admin-user-id`
instead if the account already exists, and no key is needed.

## Commands

| Command | What it does |
|---|---|
| `ekwo init` | The whole installation, interactive or not: the socle's migrations, the reference seeds, then the modules', as `ekwo migrate` applies them. `--no-company` stops before the first company: see [several countries](#several-countries-in-one-installation-init---no-company). |
| `ekwo migrate` | Applies the migrations this release adds, after showing the gap — the socle's, then the modules'. Re-applies the reference seeds, which are idempotent. `--no-modules` leaves the modules alone. |
| `ekwo status` | Schema version installed against available, pending migrations, the instance, its administrators, the country packs it holds and, per company, the pack version it copied. Exits 1 when something is pending. |
| `ekwo doctor` | Every object this release defines and every privilege it grants, against what the database holds; row level security on every table, a policy on every protected table, no pending migration, no membership pointing at a deleted user, every company with a bank account, statements that tie to their lines, posted entries that balance. Exits 1 on a problem, 0 on warnings. |
| `ekwo register` | Opt in to security advisories and release notes. Also the retry when the announcement did not go through. |
| `ekwo unregister` | Opt back out. Clears the address and the date on the instance row. |
| `ekwo demo` | Loads the sample company. Fictional data, explicit request only. |
| `ekwo module` | What is installed beside the socle, applies a module's migrations and its country seeds, and turns one on or off for a company. |
| `ekwo company` | `new` creates a company in its own country, through `create_company()`, and `list` shows the companies held here. One company leaves an installation with its books — `export` writes an archive anybody can read, as a member under row level security — and arrives in another one alive: `import` takes it in whole or not at all. |
| `ekwo pack` | Compiles a country pack into its seed, and refuses a seed that is no longer the output of its pack. Runs in a checkout of the repository only. |
| `ekwo login` | Signs in to an instance as yourself and keeps the session, in your own configuration directory. See [acting as a person](#acting-as-a-person-login-use-whoami). |
| `ekwo logout` | Ends that session, here and on the instance. |
| `ekwo use <company>` | Picks the company the next commands run on. |
| `ekwo whoami` | Who you are on which instance, the companies you can see, and what you may do on the one in use. |
| `ekwo contact add` / `list` | A customer or a supplier, and finding one again. |
| `ekwo doc new` / `doc line add` | A draft document — any kind, with `--type` — and one more line on it. A draft books nothing. `ekwo invoice` is the old name of `ekwo doc`, kept as an alias. |
| `ekwo post <document>` | Books it, through `post_document()`. `--dry-run` shows the entry the database would write and writes nothing. |
| `ekwo cancel <document>` | Undoes a posted invoice, and says how. Back to draft, through `unpost_document()`, where its country allows it and nothing about it has left; otherwise through `cancel_document()`: the credit note that names it, posted and matched against it, and the invoice cancelled. `--date` books the credit note on another day than the invoice's, which is how a locked period is stepped over; `--credit` asks for the note where a draft was possible. |
| `ekwo reverse <entry>` | Undoes a posted entry keyed by hand, through `reverse_entry()`: its mirror, posted and matched against it. By id or by number; `--date` as for `cancel`. |
| `ekwo payment record` | Money in or out, booked and matched. With `--doc`, against that document. |
| `ekwo match <transaction> <document>` | A bank statement line pays a document, through `settle_from_statement()`. |
| `ekwo import <source> <file>…` | Books kept elsewhere — `trial-balance`, `fec`, `journal-items`, `journal-report`, `xaf` — whole or not at all, through `import_books()`, with a correspondence of accounts and journals you save and give back; or a bank statement — `camt.053`, `coda`, `cfonb120` — as pending lines. `--dry-run` rehearses. See [taking over books](#taking-over-books-ekwo-import). |
| `ekwo doc list` / `show` | What exists, and with `--unpaid` what is posted and still owed. See [keeping books](#keeping-books). |

There is no `eject`, because there is nothing to eject from. The schema is in
your database, the migrations are in the repository under AGPL-3.0, and
`supabase db push` applies them without this CLI ever running again.

## What a command answers: `--json` and the exit codes

Every command prints for a person by default — aligned columns, colour only on
a terminal and never when `NO_COLOR` is set, no spinner and no line redrawn in
place, so the output reads the same in a file or a CI log — and takes `--json`
for a program.

`ekwo help --json` answers the list of commands and, in `usage`, the whole
text of `--help` without colour: every flag and variable, for an assistant
that reads one document rather than a terminal.

Under `--json` the standard output is **one JSON document and nothing else**;
the prose still goes by, on the standard error. The document has the same
shape whatever happened:

```json
{
  "ok": false,
  "command": "module enable",
  "exitCode": 3,
  "warnings": [],
  "error": {
    "kind": "refusal",
    "name": "not_allowed",
    "message": "not_allowed: enabling a module on this company needs company.write",
    "sqlstate": "42501"
  }
}
```

| Field | |
|---|---|
| `ok` | `exitCode` is 0. |
| `command` | The words that named it: `status`, `pack upgrade`. |
| `exitCode` | The code the process ends on. |
| `data` | What the command has to say. Its shape is per command, under `$defs/data/<command>` of the schema. Absent when it failed before having anything to say. |
| `warnings` | Every warning the command printed, without the colours. |
| `error` | Only when something went wrong: `kind` (`refusal`, `usage` or `technical`), the `message` word for word, the `name` it starts with when it has one, and the `sqlstate`, `detail` and `hint` when the database gave them. |

The shape is published as
[`schema/output.1.json`](schema/output.1.json), ships in the package, and is
what `tests/cli/output-contract.test.ts` validates every command against. An
amount is a decimal string and never a JSON number; a date is ISO 8601.

| Exit code | Means |
|---|---|
| `0` | Done. |
| `1` | It failed for a reason that is not the books — the network, a database that does not answer, a bug — **or a check found something**: a `doctor` problem, a pending migration in `status`, a stale seed in `pack check`, a company behind its pack. In the second case `data` says what and there is no `error`. |
| `2` | The command was called wrong: an unknown option, a missing argument, or a question that needed an answer with no terminal to ask it on. |
| `3` | **The database refused.** A locked period, a capability you do not hold, a row level security policy, a constraint. The call was well formed and everything worked; the accounting said no. |

A refusal is printed as the database wrote it — `period_locked: …`,
`tax_territory_mismatch: …` — and never rephrased; the CLI does not move a
date or retry differently to get past one. Its name is the part to match on,
in a field of its own under `--json`.

**No command waits on a question when there is nobody to answer.** Off a
terminal, or under `--json`, or with `--yes`, a missing answer is exit code 2
with the flag to pass. That holds underneath the commands too: a prompt that
is reached with no terminal stops instead of waiting.

## Acting as a person: `login`, `use`, `whoami`

The commands above install and operate, and connect as the owner of the
database — they say so when they connect. Anything that keeps books acts as
**a person**, through the instance's API, under row level security: the same
route, and the same functions of the schema, as the MCP server.

```bash
ekwo login --supabase-url https://<ref>.supabase.co --anon-key <publishable key> --email you@example.test
ekwo whoami
ekwo use "Example One"
ekwo whoami --json
```

`login` asks the instance for a session and keeps it. In a directory that has
an `ekwo.json`, the URL is read from it. The password is prompted, masked, when
`--password` and `EKWO_PASSWORD` are absent; it is sent to the instance once
and written nowhere. Signing in again after a session ended is `ekwo login`
and a password: the profile remembers the rest.

**Where the session is kept.** In `$EKWO_CONFIG_DIR`, else
`$XDG_CONFIG_HOME/ekwo`, else `~/.config/ekwo`, in two files written `0600` in
a `0700` directory: `profiles.json` says where each profile points and holds
no token; `credentials.json` holds the access token and the refresh token.
The CLI refuses — `config_dir_in_repository` — to write either inside a
repository, where one `git add .` would publish them. The access token lasts
about an hour and is renewed on its own, ahead of time and again if the
instance answers 401 anyway; the rotated refresh token replaces the old one
on disk before the call is retried. A session that cannot be renewed is
`session_expired`, exit code 2, and the fix is `ekwo login`.

**Profiles.** `--profile <name>`, or `EKWO_PROFILE`: a demo instance,
production, one client of a firm. Each holds one instance, one person and one
company in use. The profile last signed in to is the one used when none is
named.

**The environment comes first, and touches no file.** With `SUPABASE_URL`,
`SUPABASE_ANON_KEY` and either `EKWO_ACCESS_TOKEN` or `EKWO_EMAIL` with
`EKWO_PASSWORD` — the variables the MCP server reads — a command signs in for
its own duration, reads no profile and writes nothing: a CI job. The
environment is taken whole: a user there with no instance beside it is a wrong
call, never a fallback on a profile's instance. It has nowhere to keep a
company, so pass `--company`.

**The company in use.** `ekwo use <name or id>` checks the company against the
instance, as you, and records it; `--company` names another for one command.
A company you cannot see is `unknown_company`, and is not named in the
refusal. Under `--json` every answer of a command that acts as a person
carries a `context` — the profile, the instance and **the company the answer
was rendered for**, `null` when none is in use — on success and on a refusal
alike. A caller that keeps two sets of books reads it before it believes the
rest.

```json
{ "ok": true, "command": "whoami", "exitCode": 0,
  "context": { "profile": "default", "instance": "https://<ref>.supabase.co",
               "company": { "id": "…", "name": "Example One" } },
  "data": { "user": { "id": "…", "email": "you@example.test" },
            "instance": { "url": "…", "schemaVersion": "0.3.0" },
            "capabilities": ["…"], "companies": [ … ] },
  "warnings": [] }
```

`whoami` works nothing out. The companies are the rows the policies let you
read, the capabilities are what `member_capabilities()` answers for the
company in use — the function behind `your_capabilities` in the MCP server —
and the schema version is `ekwo_schema_version()`.

**Never a `service_role` key.** It is refused by name, `service_role_refused`,
with exit code 2 and before anything is sent, at every door it can arrive by:
`--anon-key` or `SUPABASE_ANON_KEY`, `EKWO_ACCESS_TOKEN`, a session file
somebody edited, and `--service-role-key` typed out of habit. The test for it
and the sentence are in `@ekwo-ai/core`, where the MCP server reads them too.
`ekwo init` remains the one command that takes that key, to create the first
user, and never keeps it.

| Refusal of the CLI's own | Exit code | Means |
|---|---|---|
| `not_signed_in`, `unknown_profile`, `session_expired` | 2 | There is nobody to act as. `ekwo login`. |
| `service_role_refused`, `config_dir_in_repository`, `missing_configuration` | 2 | The call has to change, not be retried. |
| `unknown_company`, `ambiguous_company` | 2 | Name it differently, or by its id. |
| `no_company` | 2 | A verb that keeps books ran with no company in use. `ekwo use`, or `--company`. |
| `unknown_contact`, `ambiguous_contact`, `unknown_document`, `unknown_account_code`, `unknown_tax_code`, `document_not_draft`, `nothing_open`, `bad_line`, `unknown_field`, `bad_json` | 2 | Decided before the database was asked, by the CLI or by the functions it shares with the MCP server. The call has to change. |
| `sign_in_failed`, `instance_unreachable` | 1 | The instance declined the address and the password, or did not answer. |

A refusal of the database that arrives over this route is still exit code 3:
PostgREST passes on the SQLSTATE, the detail and the hint, and the CLI reads
them as it reads a driver's.

## Keeping books

```bash
ekwo contact add "Client Example" --country <cc> --ref crm-42
ekwo doc new --contact client --date 2026-06-15 --ref job-7 \
     --line "name=Audit,price=1500.00,account=<account code>,tax=<tax code>"
ekwo doc line add job-7 --name Travel --price 250.00 --account <account code>
ekwo post job-7 --dry-run        # the entry the database would write; nothing is written
ekwo post job-7                  # post_document()
ekwo cancel job-7                # back to draft where the country allows it, else the credit note
ekwo payment record --doc job-7 --amount 1750.00 --date 2026-06-30 --bank-account <id> --ref bank-1
ekwo match <bank transaction id> job-9
ekwo doc list --unpaid --since 2026-06-01 --json
```

They run as the person signed in, on the company in use ([above](#acting-as-a-person-login-use-whoami)),
and none is ever picked for you: with no company in use a verb ends on
`no_company`, exit code 2, and `context.company` is `null`.

**Each verb is one function, and it is not ours.** The functions live in
`@ekwo-ai/core` and the MCP server calls the same ones: `contact add` is
`create_contact`, `doc new` is `create_document`, `post` is
`post_document`, `cancel` is `unpost_document` or `cancel_document` — `unpost_refusal` chooses —, `reverse` is `reverse_entry`,
`payment record` is `record_payment`, `doc list` and
`doc show` are `list_documents` and `get_document`. Underneath them the rules
are the schema's — the balance, the numbering, the locks, the taxes, the
territory, the tax point. **This CLI computes no amount**: what you type goes
in as text, what is printed is what came back, and
`tests/cli/no-rules.test.ts` reads the commands to keep it that way. An amount
is a decimal string in both directions, `1500.00`.

**A refusal is the answer.** A locked period, a policy, a constraint: exit
code 3, the database's sentence word for word, its name in `error.name`. The
CLI does not move a date or try something else. What is refused *before* the
database is asked — an account code that does not exist, a document that is
not a draft, a document with nothing open — is exit code 2: the call has to
change.

**`--ref`, so that nothing is created twice.** On what creates (`contact add`,
`doc new`, `payment record`), `--ref <your reference>` is kept on the row,
unique per company. The same reference a second time returns what the first
call created, with `"replayed": true`, and writes nothing — and finishes what
a dropped connection left half done: a draft whose lines never arrived, a
payment inserted and never booked. Two callers racing each other are settled
by the unique index, which refuses the slower one with exit code 3. A
`<document>` is its id, its number, or the `--ref` it was created under, which
is how a draft — it has no number yet — is named.

**`--dry-run`, where the database can answer without writing.** Today that is
`post`. `rehearse_post_document()` calls `post_document()` for real inside a
block it then rolls back, so the entry shown is the one that would be written,
under the number it would take, and a rehearsal is refused exactly as posting
would be. No other verb has one, because for no other verb does the database
know how.

**`--stdin`, the form that is authoritative.** One JSON object on the standard
input, with the fields of the MCP tool of the same meaning (`contact_type`,
`document_date`, `lines: [{ name, unit_price, account_code, tax_code, … }]`,
`client_ref`). A field nobody defined is refused rather than dropped. Flags
given beside it win.

```bash
echo '{"contact":"client","document_date":"2026-06-15","client_ref":"job-8",
       "lines":[{"name":"Review, \"urgent\"","unit_price":"200.00","account_code":"<code>"}]}' \
  | ekwo doc new --stdin --json
```

**`--line`, for a person.** Named fields, never positions: `name`, `price`,
`qty`, `account`, `tax`, `product`, `unit`, `discount`, `description`; a comma
inside a value is `\,`. A tax and an account are named by their **code** —
never a rate, since several taxes share one. The free-text form
(`"Audit 1 500 EUR@21"`) is not accepted: `1 500` is one number or two, `@21`
is a rate where the books need a tax, and a currency belongs to the document
(`--currency`), not to a line.

Two values are supplied when nobody gives them, and said when they are:
`--type` is `sale_invoice`, and `--date` is today on the machine running the
command. Whether that date may be booked on is the database's decision.

## Taking over books: `ekwo import`

To try Ekwo on your own books, bring them. One command, one reader per
source, and nothing is posted while an account has no answer:

```bash
ekwo import fec 123456789FEC20251231.txt --dry-run --open-years --save-mapping map.json
#   read, propose a correspondence, rehearse the import in the database, take it back
$EDITOR map.json                                   # answer what is null — read `suggested` — correct what is wrong
ekwo import fec 123456789FEC20251231.txt --mapping map.json --open-years
ekwo import trial-balance balance.csv --opening-date 2026-01-01 --dry-run --save-mapping map.json
ekwo import journal-items items.csv accounts.csv partners.csv --dry-run --save-mapping map.json
ekwo import journal-report report.csv chart.csv --date-order dmy --dry-run --save-mapping map.json
ekwo import xaf books.xaf --open-years --dry-run --save-mapping map.json
ekwo import camt.053 statement.xml                 # or coda, cfonb120: pending lines for `ekwo match`
```

| Source | What it reads |
|---|---|
| `trial-balance` | A trial balance as CSV — `account`, `debit`, `credit`, or one signed `balance` — which becomes the opening entry of the year `--opening-date` starts |
| `fec` | A *fichier des écritures comptables*: the eighteen columns of the arrêté of 29 July 2013, tab or bar separated |
| `journal-items` | The lines of every entry exported as CSV from the list view of an ERP whose ledger is a table of lines, with the chart of accounts and the partners exported beside it |
| `journal-report` | A journal report or a general ledger detail, saved as CSV from a cloud service's spreadsheet export, with its Journal ID and Account Code columns, and the chart and the contacts beside it |
| `xaf` | An XML Audit File Financial, version 3.2 or 4.0: the accounts, the parties, the opening balance — on the day the file gives it — and every transaction of a year, in one file |
| `camt.053`, `coda`, `cfonb120` | A bank statement: its lines, pending, ready for `ekwo match` |

Each reader is a brick of [`packages/formats/`](../formats/README.md), named
after the file; its README says which columns it reads and which official
pages the format was read from. The exports of other ledgers can also be named
by the software they come from: `ekwo import --help` lists those names, and
[`docs/compatibility.md`](../../docs/compatibility.md) gives each one's export,
official page and state.

**The correspondence is yours.** Every account of the old chart has to become
an account of the company's chart, and every old journal a journal of the
company. The codes give a candidate — the same code, the same digits without
the zeros a chart pads with (`411` and `411000`), or the account whose digits
are the longest beginning of the old code, three at least (`401ACME` and
`401000`); a tie is no answer — and what the files say of the old account —
the type its export gives it, its name, the side of its balance — is held
against the type of the candidate in the chart, because two charts give the
same digits to different things. Only the same code, not contradicted, is
`exact`. Anything else is `suggested`, with its reason, and waits for you; a
candidate the files contradict is dropped for the one account of the chart of
the kind they say. `--dry-run` prints the lines to read first, each with its
reason, and `--save-mapping` writes the correspondence as JSON:

```json
{
  "version": 1,
  "source": "fec",
  "accounts": { "411000": "411000", "401ACME": null, "471200": null },
  "journals": { "VE": "SAL", "AN": "@opening", "BQ1": "MISC" },
  "suggested": { "401ACME": { "target": "401000", "reason": "the longest beginning of the code the chart has; …" } }
}
```

and `--mapping` gives it back: what it answers wins over the proposal, so the
second run posts what the first one showed. A suggestion is confirmed by
writing its code under `accounts`; `--accept-suggestions` takes all of them
once you have read them. Nothing is posted while one the books use is only
suggested. A journal mapped to `@opening`
becomes the opening entry of its year instead of ordinary entries — the
*à-nouveaux* of a FEC, typically. A journal whose code is the one the pack
opens years on is proposed as `@opening` on its own; `*` stands for entries
the source gives no journal.

**Whole or not at all.** `import_books()` is one call and one transaction: the
fiscal years it needs (with `--open-years`, as years of the same length and
first day as the company's own; without, an entry outside every year is
refused by name), the parties the lines name — found by their code or their
name, or created as customers or suppliers according to where their lines are
booked — every entry as a draft then posted by `post_entry()`, and the opening
through `opening_balance()`. One refusal — a locked period, an account the
chart does not have, a capability you do not hold — and nothing stays, not
even the years or the parties.

**`--dry-run` is the real thing, taken back.** The database runs the whole
import and rolls it back, so the numbers shown are the ones the entries would
take now and a refusal is the one the import would give. For a bank statement a
dry run reads the file and asks nothing: a statement books nothing anyway.

What else to know:

- **Refused before the database is asked**, and listed under `refusals` by a
  dry run: an account or a journal with no answer or only a suggestion, books whose reader found
  something that does not add up (an entry that does not balance, a line of a
  draft entry), a currency the files name that is not the company's.
- **The numbers** are drawn by the journal each entry goes to; the old number
  is kept as the entry's reference. `--keep-numbers` posts each under its old
  number instead, where the country allows a number chosen by hand or you hold
  `entries.import`.
- **No tax.** An imported line carries an account and an amount, not the tax
  that produced it: the history feeds the ledger, the trial balance and the
  statements, and no box of a VAT return. A period kept elsewhere was declared
  from where it was kept.
- **The same files twice are refused** (`import_already_done`): `book_imports`
  keeps the checksum of what each import read, and the refusal says which
  files, when, and what that import wrote.
- **Dates and encodings are said, never guessed**: `--encoding` for a file
  that is not UTF-8, `--date-order` for a report that writes dates in digits.
- **Reconciliation marks are read and not re-applied yet**: the matching of an
  imported receivable against its payment is done in Ekwo, with `reconcile`.

The MCP server offers the same as `import_books`, and `import_bank_statement`
for a statement. [`docs/import.md`](../../docs/import.md) is the long form.

## `ekwo module`

A module is a Postgres schema beside the socle — `assets` for fixed assets,
`budgets` for a plan against the ledger. Its migrations travel with this
package, and `ekwo migrate` applies them by default.

```sh
ekwo module list                          # what this release carries, and what the database holds
ekwo module migrate [<code>]              # the migrations, and the country seeds they need
ekwo module enable assets --company "…"   # turn it on for one company
ekwo module disable assets --company "…"  # turn it off; nothing it wrote is deleted
```

`enable` and `disable` go through `enable_module()` and `disable_module()`
rather than writing the table: the guard is in the function, so it applies to
psql and PostgREST alike. The CLI sets the request claim for an owner of the
company, the way `ekwo register` does, and `--as-user <uuid>` names another.

**One thing this CLI cannot do**, and says so every time: PostgREST serves a
schema other than `public` only once the project lists it under its exposed
schemas. That is a setting of the API, not of the database, so `ekwo module
enable` prints the line to add — Supabase dashboard → Project Settings → API,
or `[api] schemas` in `supabase/config.toml`.

**Before `supabase db push`**, run `ekwo migrate --no-modules`. The Supabase
CLI knows the socle's migration files and not a module's, so it would report
them as history it has no file for.

## `ekwo company`

A firm keeps several companies in one installation, each in its own country,
and each of them belongs to somebody. `new` creates one and `list` shows them —
see [several countries](#several-countries-in-one-installation-init---no-company):

```sh
ekwo company new "My Company Belgium" --country BE --chart default --language fr
ekwo company new "My Company France" --country FR --language fr
ekwo company list                                     # name, country, currency, language, chart, pack, members
```

`company new --json` answers the company (`id`, `country`, `currency`,
`language`, `chart`, `packVersion`), its first financial year and its owner;
`company list --json` answers `companies`, one per company. Both shapes are
under `$defs/data` of the output schema, and the exit codes are the ones every
command has: 2 for a missing answer, 3 when the database refuses.

The two commands below are how a company leaves, and arrives somewhere else.

```sh
ekwo company export "My Company" --out ./my-company   # manifest.json + data/<schema>.<table>.jsonl
ekwo company import ./my-company --owner <user id>    # whole, or not at all
```

**`export` runs as a member, under row level security**, although the
connection belongs to the owner of the database: inside one transaction the CLI
steps down to `authenticated` with the claim of the member it acts for —
`--as-user`, an owner of the company by default. That member needs
`company.export`, which the `owner` and `client` presets hold. An archive is
whole or it is not written: a member who may not read one of the tables is
refused, by table, with exit code 3. The act is written on the audit trail of
the company.

**`import` is for the installer or an administrator of the installation**
(`--as-user`), the two who may create a company. The files are checked against
the manifest before the database is asked anything; then `import_company()`
takes all of it or none of it. A company already there is refused — exit code
3, `company_already_here` — which is also what running the command twice gets.
Members do not travel: `--owner` names the first one.

**The files the attachments point at are not carried.** They are in the storage
bucket, not in the database; `manifest.json` lists them and both commands say
how many are left to copy.

The format, what travels and what does not, and every refusal are in
[`docs/company-archive.md`](../../docs/company-archive.md).

## `ekwo doctor`

What a healthy installation is true of, and nothing in the schema can enforce
on its own. It reads and reports; it never repairs, because the fix for a
missing policy is a migration and the fix for an orphaned membership is a
decision about who should have access.

```sh
ekwo doctor --db-url "$URL"          # readable
ekwo doctor --db-url "$URL" --json   # the whole report, findings included
```

**The `catalogue` check compares your database to an inventory of everything
this release defines** — tables and their columns, views, functions with their
identity arguments, policies, triggers and types. That inventory is
[`assets/expected-objects.json`](assets/expected-objects.json), generated from
the migrations themselves and shipped inside this package, so it cannot be a
list somebody forgot to update. In `--json` output it is the check named
`catalogue`. Four outcomes, and they are not the same thing:

| Finding | What it means | Severity |
|---|---|---|
| Missing | The installation is behind or has been damaged. | Problem |
| Extra | Your own table, function or trigger. Reported so you know it is there. | Information |
| Extra or missing **policy** on a table of this schema | Row level security is the security model. A policy that is gone closes everything; one that was added is a grant nobody reviewed. | Problem |
| A column whose type has moved | The schema was patched by hand. Reported as **changed**, not as missing: "missing" would send you looking for a migration that did land. | Problem |

A module's objects are required only of a database that carries the module.
One you never installed is named and skipped.

**A database older than this CLI is still compared.** The report says which
schema version the inventory describes and which one the database reports, and
goes on to list what differs — refusing to look would be refusing the case the
check exists for.

**Exit codes.** `0` when there is no problem, warnings and information
included; `1` when there is at least one problem, or when the schema is not
installed at all. Nothing else. So `ekwo doctor` is usable as a deployment
gate, and an operator's own extra table never turns a pipeline red.

**What the catalogue does not cover.** Constraints, indexes and the bodies of
functions. A dropped unique index is real damage and this check will not see
it: the question it answers is "is the object there, and is it still that
shape". `docs/schema.md` lists the constraints for a human reader, and the
argument against putting them in the inventory is that each is an order of
magnitude more text for a diff that would move on every Postgres upgrade — and
an inventory whose diff nobody reads is worth nothing.

**The `grants` check compares the privileges**, from the same inventory: the
`grants` section of each schema says which of `anon`, `authenticated` and
`service_role` may reach each table, view and function, and with which verbs.
Its own check rather than a category of `catalogue`, because the rule is not
the same.

| Finding | What it means | Severity |
|---|---|---|
| A privilege the release grants and the database does not hold | Nothing else notices it, and it reaches a client as `permission denied for table companies`. | Problem |
| Any privilege `anon` holds beyond what the release grants | The anonymous role reaches the ten policy helpers and no table. One more is a surface nobody reviewed. | Problem |
| A privilege `authenticated` or `service_role` holds and the release does not grant | Usually a local customisation. Row level security is then the only thing refusing a verb the schema meant to withhold. | Warning |
| A default privilege still standing on a schema | A privilege that comes from there comes from something no migration wrote, and a recreated schema takes it away. | Warning |

In a checkout, `npm run inventory` regenerates the inventory from the
migrations; the CI regenerates it and fails on any difference, the way it does
for `docs/schema.md`, and a second job checks that the copy shipped in `dist`
is the one in the repository.

## `ekwo pack`, in a checkout

A country is data: `packs/<cc>/` holds a manifest, the chart of accounts as
CSV, the taxes and where they post, the boxes of the declaration, the financial
statements, the sentences the country requires on an invoice, the translations,
and a year of books with the figures it produces. The compiler turns one into
`supabase/seed/<n>_pack_<cc>.sql`, which is committed — and, where a pack
carries a section for a module, into
`supabase/seed/modules/<code>/<n>_pack_<cc>.sql`, applied by the module
migration runner and by nothing else.

```sh
ekwo pack list           # the packs this checkout carries, and their certification
ekwo pack describe       # everything each of them says; one country with `describe <cc>`
ekwo pack build be       # write supabase/seed/10_pack_be.sql from packs/be, and the lists of packs
ekwo pack build --all
ekwo pack check be       # validate one pack, compare its seed and the lists of packs
ekwo pack check --all    # exit 1 if a committed seed or list is not the output of the packs
```

The lists are the blocks of other files that name every pack — the seeds of
`supabase/config.toml` and of the root README, the `/packs/<cc>/` lines of
`.github/CODEOWNERS`, the table of `docs/packs.md` — each between a
`generated:<name>` marker and `/generated`. They are written from `packs/` the
way a seed is, so a country is added in `packs/<cc>/` and nowhere else.

`list` is a line per country. `describe` is the whole of one: the charts and
who each is published for, the taxes and their distinct rates, the periodic
declaration with its cadences and its boxes, whether the country states a rule
for when the return is due, the brick that writes the file it is deposited as
or that it is filed by hand on a portal, the e-invoicing profile and the day it
starts, the accounts the tax balance lands on, every bank statement format the
country names and whether anything here reads it, the financial statements, and
the texts the pack was built from with the day each was last opened. Every
answer is read from the pack, and a "not yet" is printed rather than left out.

```sh
ekwo pack describe --json | jq '.data.packs[] | {country, version}'
```

Under `--json` the whole description of every pack is the result. It is the
same object the site at [ekwo.ai](https://ekwo.ai/countries/) builds each
country's page from, so the site and the command line cannot come to say
different things about a country.

`check` validates every file of the pack against
[`packs/schema/pack.1.json`](../../packs/schema/pack.1.json) and against the
rest of the pack, then compares the committed seed with what the compiler makes
of it now. It is what the CI runs, so the SQL cannot drift from the pack. Every
rule it applies is listed in [`docs/packs.md`](../../docs/packs.md), under
"What `ekwo pack check` refuses".

Neither command touches a database: the seed is applied by `ekwo init`,
`supabase db push` or `psql -f`, like every other seed. A published
installation has the compiled seeds and no `packs/` folder, and the command
says so rather than guessing.

Two commands under `ekwo pack` do the opposite and read an installation rather
than a checkout, so they take a connection and work without `packs/`:

```sh
ekwo pack status --db-url "$EKWO_DB_URL"          # which pack version each company copied
ekwo pack upgrade "My Company" --db-url "…"       # move it to the version this installation holds
```

`status` changes nothing and exits 1 while a company is behind, so a scheduled
job can ask. `upgrade` applies an addition and a closed validity by itself,
lists everything else for a person to read, and never removes anything from a
company's books; `--apply` is what accepts the differences it listed.

## Flags

Every command takes the connection flags:

| Flag | Meaning |
|---|---|
| `--db-url <url>` | Postgres connection string. The reliable way. |
| `--project-ref <ref>` | With `--db-password` and `--db-region`, the session pooler host. |
| `--db-password <pw>` | Database password. Prompted, masked, when omitted. |
| `--db-region <region>` | With `--project-ref`, the session pooler in that region. Both generation prefixes are tried and the one that answers is kept. |
| `--supabase-url <url>` | `https://<ref>.supabase.co`. Needed only to create a user. |
| `--service-role-key <key>` | Needed only to create a user. Either form Supabase issues: a secret key, `sb_secret_…`, sent on the `apikey` header alone because it is not a JWT, or the legacy `service_role` JWT, sent on `apikey` and as a Bearer as before. |
| `--yes`, `-y` | Never ask a question. Everything must come from flags or the environment. |

`--project-ref` with `--db-password` and `--db-region` builds the session
pooler host. It no longer guesses which one: the pooler hostname carries a
generation prefix as well as a region, and the region does not determine it,
so `aws-0-<region>` and `aws-1-<region>` are both opened on port 5432 and the
one that answers is kept and printed. Without `--db-region` nothing is
derived — the CLI asks for the connection string, because the direct host
`db.<ref>.supabase.co` is IPv6-only on recent projects and deriving it
silently produces a hang rather than an error. `--db-url`, copied from the
dashboard under Connect → Session pooler, is the form that is never derived.

`ekwo init` adds:

| Flag | Meaning |
|---|---|
| `--country <cc>` | Which country pack: its chart of accounts, its journals, its taxes and its declaration. One of the packs the database holds — `ekwo pack list` names them, and there is no default. |
| `--chart <code>` | Which chart of accounts, where the country publishes several. Required outside a terminal when it does. |
| `--org <name>` | Your organisation, written on the instance row. |
| `--company <name>` | The first company. Defaults to `--org`. |
| `--admin-email <address>` | The first administrator, created in your Supabase Auth. |
| `--admin-password <pw>` | Their password. Omitted, an invite link is generated and printed. |
| `--admin-user-id <uuid>` | Use an account that already exists, instead of creating one. |
| `--fiscal-year <year>` | Calendar year of the first financial year. Defaults to this year. |
| `--fiscal-year-start <date>` | The day that year opens, as `YYYY-MM-DD`. Needed only where the pack names no usual opening month (`defaults.fiscal_year_default`). |
| `--currency <code>` | Currency of the company. Defaults to the pack's `defaults.currency`. |
| `--language <xx>` | Language of the books, two letters. Defaults to `country_defaults.language_default`, which the pack fills. It decides which label of the pack lands on each account; the others are kept in `name_i18n`. |
| `--iban <iban>` | Creates the main bank account, wired to the bank journal and its ledger account. Omitted, no bank account is created and `ekwo doctor` says so. |
| `--bic <bic>` | Optional, on that account. |
| `--bank-name <name>` | Optional. It also names the account in the books. |
| `--demo` | Also load the sample company. |
| `--register` | Register without being asked. `--register-email` sets the address. |
| `--registry-url <url>` | Where the registration is announced. |
| `--no-modules` | Leave the modules out. By default `init` installs them, as `ekwo migrate` does — empty schemas until a company enables one. |
| `--no-company` | Install without a company: schema, every pack, the modules, the first administrator, and no country on the instance row. The flags that only describe a company are refused with it. Then `ekwo company new`, once per company. |

`ekwo company new <name>` takes `--country`, `--chart`, `--language`,
`--currency`, `--fiscal-year` and `--fiscal-year-start` as `init` does, and
`--as-user <uuid>`: the administrator of the installation it is created as,
who becomes its owner — the only one, when there is exactly one.

Every command takes `--json`; see [what a command answers](#what-a-command-answers---json-and-the-exit-codes).
`ekwo migrate` takes `--skip-seeds`.

## Environment variables

| Variable | Same as |
|---|---|
| `EKWO_DB_URL` | `--db-url`. `SUPABASE_DB_URL` also works. |
| `EKWO_DB_PASSWORD` | `--db-password` |
| `SUPABASE_URL` | `--supabase-url` |
| `SUPABASE_SERVICE_ROLE_KEY` | `--service-role-key`. `ekwo init` only. |
| `SUPABASE_ANON_KEY` | `--anon-key` |
| `EKWO_EMAIL`, `EKWO_PASSWORD` | Sign in for one command, writing nothing. `ekwo login` reads them too. |
| `EKWO_ACCESS_TOKEN` | The same, with a session token already in hand. It is not renewed. |
| `EKWO_PROFILE` | `--profile` |
| `EKWO_CONFIG_DIR` | Where profiles and sessions are kept. |
| `EKWO_REGISTRY_URL` | `--registry-url`. Default `https://api.ekwo.ai/v1/registrations`. |
| `NO_COLOR` | Plain output. |

See [`.env.example`](../../.env.example) at the root of the repository.

## Secrets

The CLI never writes a password or a key to disk. The database password and
the `service_role` key are read from a flag, an environment variable or a
masked prompt, used, and forgotten; nothing is in `ekwo.json` but the project
URL, the country and the schema version.

One thing is kept, since `ekwo login`: the session of the person who signed
in — an access token and the refresh token that renews it — in their own
configuration directory, readable by them alone, and refused anywhere inside a
repository. It is in a file and not in the keychain of the operating system;
`ekwo logout` removes it and ends it on the instance, and a job that should
keep nothing sets the environment variables instead.

It has one runtime dependency from outside this repository, the Postgres
driver. Argument parsing, prompts and the masked input are a few dozen lines
each in this package rather than packages from the registry, because
everything this CLI is handed is a secret and every dependency added is one
more thing that could read it. The other dependency is `@ekwo-ai/core`, this
repository's own, where the CLI and the MCP server read a refusal of the
database the same way.

## Registering with Ekwo

At the end of `ekwo init` you are asked:

> Register this installation with Ekwo to receive security advisories and
> release notes?

The default answer is no, and no is supported forever. Community works
unregistered: nothing in the schema and nothing in this CLI reads
`contact_email` or `registered_at` to decide what you may do, and `edition`
gates no feature.

If you say yes, two things happen, independently. `register_instance(email)`
writes the address and a date onto your instance row, and a POST goes to
`EKWO_REGISTRY_URL` carrying exactly six fields:

```json
{
  "instance_id": "…",
  "organization": "My Organisation",
  "country": "BE",
  "edition": "community",
  "schema_version": "0.2.0",
  "contact_email": "you@example.com"
}
```

No ledger data, no user list, no connection string. `instance_id` is generated
locally by your own database and is not a licence key: no code path anywhere
checks it.

**The endpoint does not exist yet.** A failed POST is a soft message, not a
failed install: the local record stands and `ekwo register` retries it later.
`ekwo unregister` clears the local fields; it sends nothing, because the CLI
only holds the local row.

## Testing it against a real project

The test suite runs against Postgres compiled to WebAssembly, so it proves the
migration runner, the installation sequence and the checks without a Supabase
project. Four things it cannot prove: the network driver, PostgREST, GoTrue,
and the extensions a hosted project has.

**The automated way.** From a checkout of the repository, against an empty
project you can throw away:

```sh
npm run e2e:supabase
```

It installs, migrates, upgrades the pack, signs in, books, files the
declaration and closes the year, and prints a pass/fail table with **how long
each step took** — which is the number worth reading, because what matters
about a release is which step holds it rather than the total. Everything comes
from the environment and no secret reaches the output; it refuses a database
that already holds an `instance` row, and `--reset` empties a throwaway project
so a failed run can be replayed.

Point `EKWO_E2E_PREVIOUS` at the last tag to make the run upgrade an
installation instead of creating one. The packages are not on npm yet, so it
takes **a path to a built binary of an older checkout** rather than a version:

```sh
git worktree add /tmp/prev v0.2.0
(cd /tmp/prev && npm ci && npm run build)
EKWO_E2E_PREVIOUS=/tmp/prev/packages/cli/dist/bin.js npm run e2e:supabase
```

[`docs/releasing.md`](../../docs/releasing.md) lists every variable it reads and
every refusal it makes. It is run by hand before a release is tagged, never by
the CI.

**By hand**, if you want to watch each step:

```sh
npm install && npm run build

# 1. A project you can throw away. Note its ref, password, URL and key.
#    --chart and --language are required here and not optional: the Belgian
#    pack publishes two charts of accounts and four languages, and `ekwo init`
#    refuses to pick either for you when there is nobody to ask.
node packages/cli/dist/bin.js init \
  --db-url "postgresql://postgres.SCRATCHREF:PASSWORD@aws-1-REGION.pooler.supabase.com:5432/postgres" \
  --supabase-url "https://SCRATCHREF.supabase.co" \
  --service-role-key "$KEY" \
  --country BE --chart default --language fr \
  --org "Scratch" --company "Scratch BV" \
  --admin-email "you@example.com" --admin-password "a-long-password" \
  --fiscal-year 2026 --iban "BE71096123456769" --yes

# 2. Everything should be green, and nothing pending.
node packages/cli/dist/bin.js status --db-url "$URL"
node packages/cli/dist/bin.js doctor --db-url "$URL"

# 3. The history must be the Supabase one: this should report no difference.
supabase link --project-ref SCRATCHREF
supabase migration list

# 4. And the other direction: db push finds nothing left to do.
supabase db push

# 5. Run init again. Every step should say it was already there.
node packages/cli/dist/bin.js init --db-url "$URL" --country BE \
  --chart default --language fr \
  --org "Scratch" --company "Scratch BV" --admin-email "you@example.com" \
  --admin-user-id "<the uuid from step 1>" --fiscal-year 2026 --yes

# 6. Sign in as the administrator and confirm row level security really binds:
#    a company you were not invited to must be invisible.
```

## Licence

[AGPL-3.0-only](../../LICENSE) © Ekwo AI.
