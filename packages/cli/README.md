# ekwo

The installer and the operator's tool for [Ekwo OS](https://github.com/Ekwo-ai/ekwo-os).
One command turns a Supabase project you already own into a set of double-entry
books: the schema, every country pack, the first administrator, the first
company and its first financial year. The same command line then keeps books,
as a signed-in person.

```sh
npx -y ekwo-os@latest init
```

The package is `ekwo-os` and the command it installs is `ekwo`:
`npx -y ekwo-os@latest <command>` runs it without installing anything, and
after `npm install -g ekwo-os` every example below that starts with `ekwo `
works as written. Keep `@latest` in the command: from inside a clone of the
repository, a bare `npx ekwo-os` finds the workspace package and answers
`ekwo: command not found`.

You need Node 20 or later. No Supabase CLI, no Docker.

## From a free Supabase account to a first invoice

1. **Create a project** at [supabase.com](https://supabase.com). The free plan
   is enough to start. Ekwo does not create it, does not pay for it and has no
   access to it: it is yours from the first row.
2. **Copy two things** from the dashboard:
   - **Connect → Session pooler**: the connection string. It contains your
     database password. Take the session pooler line rather than the direct
     one: the direct host answers on IPv6 only, which many networks cannot
     reach.
   - **Project Settings → API Keys**: the **secret key** (`sb_secret_…`, or
     the legacy `service_role` key on an older project) and the **Project
     URL**. They are used once, to create the first administrator in your own
     Supabase Auth, and are never written to disk.
3. **Run the installer.**

   ```sh
   npx -y ekwo-os@latest init
   ```

   It asks for the connection string, the country, the chart of accounts and
   the language where the pack offers a choice, your organisation, the
   currency, the first company, the address of the first administrator and —
   optionally — your main bank account, written the way your country's banks
   write it. A few seconds on a free project. Nothing is preselected on the
   three questions whose wrong answer is expensive: the country, the chart and
   the language.

4. **Sign in** as that administrator and start booking — in the web
   application, [Ekwo Cloud](https://cloud.ekwo.ai), which opens your own
   instance; through an AI agent and the [MCP server](../mcp/README.md); from
   this command line; or through the REST API Supabase generates.

5. **Do the four things below** while the dashboard is still open. The
   installer prints them at the end of a successful run.

Everything above in one non-interactive line:

```sh
npx -y ekwo-os@latest init \
  --db-url "postgresql://postgres.YOURREF:PASSWORD@aws-1-REGION.pooler.supabase.com:5432/postgres" \
  --supabase-url "https://YOURREF.supabase.co" \
  --service-role-key "$SUPABASE_SERVICE_ROLE_KEY" \
  --country <cc> \
  --org "My Organisation" \
  --company "My Company" \
  --admin-email "you@example.com" \
  --admin-password "a-long-password" \
  --fiscal-year 2026 \
  --yes
```

With `--yes` nobody is asked anything, so **`ekwo init` refuses rather than
choosing for you**: no country without `--country`, and `--chart`,
`--language` or `--fiscal-year-start` wherever the country's pack offers more
than one answer. Each refusal lists the values the pack accepts.
`ekwo pack describe <cc>` (in a clone) or the country's page on
[ekwo.ai/countries](https://ekwo.ai/countries/) says which a country needs.

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

ekwo company new "My Company One" --country <cc> --yes
ekwo company new "My Company Two" --country <other cc> --yes
ekwo company list
```

`--no-company` refuses every flag that only describes a company — `--country`,
`--chart`, `--language`, `--currency` and the rest — since there is no company
for it to describe. `ekwo company new` is the same `create_company()` the MCP
tool calls: it runs as an administrator of the installation (`--as-user`, or
the only one), asks the same questions as `init` and refuses the same way off a
terminal.

## Before you go live: four things on your project

An installation leaves four things undone on purpose: they are yours to
decide, on a project Ekwo has no access to. `ekwo init` prints this list at the
end of a successful run.

**1. Turn off self sign-up on your project.**
Supabase dashboard → **Authentication → Sign In / Providers → "Allow new users
to sign up"**, switched off. An Ekwo installation is closed: the people who
keep the books are invited. A stranger who signs up sees nothing, but there is
no reason to let them in.

**2. Keep two administrators.**
An instance administrator invites everybody else. With one, a lost password or
a closed mailbox is a set of books nobody can let anyone into. Create a second
account and add it with `claim_instance_admin()`, or invite it from the
application.

**3. Keep the service_role key off every machine that does not need it.**
A request carrying it bypasses row level security and reads every company in
the instance. This CLI uses it once, to create the first account, and writes it
nowhere. `--admin-user-id` installs against an account that already exists and
needs no key at all. A script that needs to work on its own gets an API key,
scoped to one company.

**4. Read DISCLAIMER.md before you file anything.**
[`DISCLAIMER.md`](../../DISCLAIMER.md), at the root of the repository. A
country pack is a reading of a country's rules at the date of its version.
`ekwo init` prints the review status of the pack it installs for the same
reason. The books are yours, in every country where you file.

## What `init` does, step by step

| Step | What happens |
|---|---|
| 1 | Applies `supabase/migrations/*.sql` in order, recorded in the Supabase CLI's own history table — so `supabase db push` and `ekwo migrate` stay interchangeable |
| 2 | Applies every reference seed: currencies, territories, the generic financial statements, and every country pack of the release |
| 3 | Creates the first administrator through the Supabase Auth admin API — a database connection cannot be a signed-in user, which is the only reason the secret key is asked for |
| 4 | Records the instance, takes the administrator seat, creates the company with you as owner, copies its country pack, opens the first financial year, and adds the bank account when one was given |
| 5 | Writes `ekwo.json`: the project URL and the schema version, nothing else |
| 6 | Asks whether to register with Ekwo; the default answer is no |

Every step checks before it acts. Running `ekwo init` twice on the same
project reports what was already there and creates nothing a second time.

## Commands

| Command | What it does |
|---|---|
| `ekwo init` | The whole installation, interactive or not: the socle's migrations, the reference seeds, then the modules', as `ekwo migrate` applies them. `--no-company` stops before the first company: see [several countries](#several-countries-in-one-installation-init---no-company). |
| `ekwo migrate` | Applies the migrations this release adds, after showing the gap — the socle's, then the modules'. Re-applies the reference seeds, which are idempotent. `--no-modules` leaves the modules alone. |
| `ekwo status` | Schema version installed against available, pending migrations, the instance, its administrators, the country packs it holds and, per company, the pack version it copied. On an installation that is not registered, a short invitation to [register](#registering-with-ekwo). Exits 1 when something is pending. |
| `ekwo doctor` | Every object this release defines and every privilege it grants, against what the database holds; row level security on every table, a policy on every protected table, no pending migration, no membership pointing at a deleted user, every company with a bank account, statements that tie to their lines, posted entries that balance. Exits 1 on a problem, 0 on warnings. |
| `ekwo register` | Opt in to security advisories and release notes. Optional: everything works the same without it. Also the retry when the announcement did not go through. |
| `ekwo unregister` | Opt back out. Clears the address and the date on the instance row. |
| `ekwo demo` | Loads the sample company. Fictional data, explicit request only. |
| `ekwo module` | What is installed beside the socle, applies a module's migrations and its country seeds, and turns one on or off for a company. |
| `ekwo company` | `new` creates a company in its own country, through `create_company()`, and `list` shows the companies held here. `show` reads the company in use as the person signed in — its financial years, lock dates, journals and accounts by role — the same document as the MCP tool `get_company`. One company leaves an installation with its books — `export` writes an archive anybody can read, as a member under row level security — and arrives in another one alive: `import` takes it in whole or not at all. |
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
| `ekwo import <source> <file>…` | Books kept elsewhere — `trial-balance`, `fec`, `journal-items`, `journal-report`, `transaction-journal`, `xaf` — whole or not at all, through `import_books()`, with a correspondence of accounts and journals you save and give back; or a bank statement — `camt.053`, `coda`, `cfonb120` — as pending lines. `--dry-run` rehearses. See [taking over books](#taking-over-books-ekwo-import). |
| `ekwo doc list` / `show` | What exists, and with `--unpaid` what is posted and still owed. See [keeping books](#keeping-books). |
| `ekwo doc pdf <document>` | The PDF of a sale invoice or credit note, rendered from the books by [`@ekwo-ai/invoice-pdf`](../formats/invoice-pdf/README.md), with the logo the company names by URL (fetched by this command, from a public http(s) address only). Written to `--out`, or under its own name in the current directory. `--factur-x` embeds the CII of a posted sale and makes it a Factur-X PDF/A-3 (the rules it breaks end on exit 1); `--page-size Letter`; `--labels <file.json>` gives the words of the layout in the document's language. `ekwo document` is the whole word of `ekwo doc`. Records nothing. |
| `ekwo proof stamp` / `upgrade` / `verify` | The sha256 of a filed file — a declaration, the annual accounts of a financial year, a document — committed to Bitcoin through the public OpenTimestamps calendars; only the hash leaves. `upgrade` completes the pending proofs of the company and is made to run on a schedule; `verify` checks a file against its proof and the block it names, and `--out` writes the `.ots` file any verifier reads. See [`docs/filing-proofs.md`](../../docs/filing-proofs.md). |
| `ekwo einvoice validate` / `issue` / `status` / `list` | The electronic invoice of a posted sale, in the format its country pack declares, through the `einvoicing` module: `validate` writes it and names the rules it breaks (exit 1 if any), `issue` keeps it and with `--send --to <directory>` writes it to that folder, `status --refresh` follows it. See [`modules/einvoicing`](../../modules/einvoicing/README.md). |

There is no `eject`, because there is nothing to eject from. The schema is in
your database, the migrations are in the repository under AGPL-3.0, and
`supabase db push` applies them without this CLI ever running again.

## What a command answers: `--json` and the exit codes

Every command prints for a person by default, and takes `--json` for a
program. Under `--json` the standard output is **one JSON document and nothing
else**, with the same shape whatever happened:

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

`data` carries what the command has to say; its shape per command is
published in [`schema/output.1.json`](schema/output.1.json). Amounts are
decimal strings, dates are ISO 8601. `ekwo help --json` answers the whole
reference of commands and flags in one document, for an agent.

| Exit code | Means |
|---|---|
| `0` | Done. |
| `1` | It failed for a reason that is not the books — the network, a bug — **or a check found something** (`doctor`, `status`, `pack check`). |
| `2` | The command was called wrong, or needed an answer with no terminal to ask it on. |
| `3` | **The database refused**: a locked period, a capability you do not hold, a constraint. The call was well formed; the accounting said no. |

A refusal is printed as the database wrote it — `period_locked: …` — and never
rephrased or worked around. **No command waits on a question when there is
nobody to answer**: off a terminal, under `--json` or with `--yes`, a missing
answer is exit code 2 with the flag to pass.

## Acting as a person: `login`, `use`, `whoami`

`init`, `migrate`, `status` and `doctor` connect as the owner of the database.
Anything that keeps books acts as **a person**, through the instance's API,
under row level security — the same route and the same functions as the MCP
server.

```bash
ekwo login --supabase-url https://<ref>.supabase.co --anon-key <publishable key> --email you@example.com
ekwo whoami
ekwo use "Example One"
```

- **The session** is kept in `$EKWO_CONFIG_DIR`, else `$XDG_CONFIG_HOME/ekwo`,
  else `~/.config/ekwo`, readable by you alone, renewed on its own, and refused
  inside a repository. The password is sent to the instance once and written
  nowhere. `ekwo logout` ends it.
- **Profiles** (`--profile`, `EKWO_PROFILE`) keep one instance, one person and
  one company in use each: a demo, production, one client of a firm.
- **For a CI job**, `SUPABASE_URL`, `SUPABASE_ANON_KEY` and either
  `EKWO_ACCESS_TOKEN` or `EKWO_EMAIL` with `EKWO_PASSWORD` sign in for one
  command and write nothing; pass `--company`.
- **The company in use** is set with `ekwo use`, or `--company` for one
  command. Under `--json`, every answer carries a `context` naming the profile,
  the instance and the company it was rendered for.
- **Never a `service_role` key**: it is refused by name, at every door it could
  arrive by. `ekwo init` remains the one command that takes it.

## Keeping books

```bash
ekwo contact add "Client Example" --country <cc> --ref crm-42
ekwo doc new --contact client --date 2026-06-15 --ref job-7 \
     --line "name=Audit,price=1500.00,account=<account code>,tax=<tax code>"
ekwo doc line add job-7 --name Travel --price 250.00 --account <account code>
ekwo post job-7 --dry-run        # the entry the database would write; nothing is written
ekwo post job-7
ekwo cancel job-7                # back to draft where the country allows it, else the credit note
ekwo payment record --doc job-7 --amount 1750.00 --date 2026-06-30 --bank-account <id> --ref bank-1
ekwo match <bank transaction id> job-9
ekwo doc list --unpaid --since 2026-06-01 --json
```

- **Each verb is one function of `@ekwo-ai/core`**, the same the MCP server
  calls, and the rules underneath are the schema's. This CLI computes no
  amount: what you type goes in as text, what is printed is what came back.
- **A tax and an account are named by their code**, never by a rate: several
  taxes share one. The codes come from the company's country pack.
- **`--ref`, so that nothing is created twice.** The same reference a second
  time returns what the first call created and writes nothing. A `<document>`
  is its id, its number, or the `--ref` it was created under.
- **`--dry-run` on `post`** runs the posting for real and rolls it back, so the
  entry shown is the one that would be written, and a refusal is the real one.
- **`--stdin`** takes one JSON object with the fields of the matching MCP tool,
  for a program.

## Taking over books: `ekwo import`

To try Ekwo on your own books, bring them. One reader per source, and nothing
is posted while an account has no answer:

```bash
ekwo import fec FEC20251231.txt --dry-run --open-years --save-mapping map.json
$EDITOR map.json                                   # answer what is null, check what is suggested
ekwo import fec FEC20251231.txt --mapping map.json --open-years
ekwo import camt.053 statement.xml                 # or coda, cfonb120: pending lines for `ekwo match`
```

| Source | What it reads |
|---|---|
| `trial-balance` | A trial balance as CSV, which becomes the opening entry of the year `--opening-date` starts |
| `fec` | A French *fichier des écritures comptables* |
| `journal-items` | The lines of every entry exported as CSV from a ledger kept as a table of lines, with its chart of accounts and partners |
| `journal-report` | A journal report or general ledger detail saved as CSV, with its chart and contacts |
| `transaction-journal` | A transaction journal saved as CSV, with its list of accounts |
| `xaf` | An XML Audit File Financial, version 3.2 or 4.0 |
| `camt.053`, `coda`, `cfonb120` | A bank statement: its lines, pending, ready for `ekwo match` |

`ekwo import --help` also lists the exports of other ledgers by the software
they come from, and [`docs/compatibility.md`](../../docs/compatibility.md)
gives each one's export and official page.

- **The correspondence is yours.** Every account and journal of the old books
  needs an answer in the company's chart. Ekwo proposes one for each — `exact`
  only for the same code, otherwise `suggested` with its reason — and
  `--save-mapping` writes them as JSON for you to check. `--mapping` gives it
  back; `--accept-suggestions` takes every suggestion once you have read them.
- **`--dry-run` is the real import, taken back**, so the numbers shown are the
  ones the entries would take and a refusal is the real one.
- **Whole or not at all.** The import is one transaction: one refusal and
  nothing stays. The same files twice are refused, saying when they were
  imported and what that import wrote.
- **No tax on history.** An imported line feeds the ledger, the balances and
  the statements, not the boxes of a declaration: a period kept elsewhere was
  declared from where it was kept.

The MCP server offers the same as `import_books`, and `import_bank_statement`
for a statement. [`docs/import.md`](../../docs/import.md) is the long form.

## `ekwo module`

A module is a Postgres schema beside the core — fixed assets, budgets,
corporate income tax, electronic invoicing. Its migrations travel with this
package, and `ekwo migrate` applies them by default.

```sh
ekwo module list                          # what this release carries, and what the database holds
ekwo module migrate [<code>]              # the migrations, and the country seeds they need
ekwo module enable assets --company "…"   # turn it on for one company
ekwo module disable assets --company "…"  # turn it off; nothing it wrote is deleted
```

PostgREST serves a schema other than `public` only once the project lists it
under its exposed schemas — a setting of the API that no database connection
can change — so `ekwo module enable` prints the line to add (Supabase
dashboard → Project Settings → API). Before `supabase db push`, run
`ekwo migrate --no-modules`.

## `ekwo company`

```sh
ekwo company new "My Company" --country <cc>
ekwo company list                                     # name, country, currency, language, chart, pack, members
ekwo company show --json                              # the company in use: years, lock dates, journals, accounts by role
ekwo company export "My Company" --out ./my-company   # manifest.json + one JSON Lines file per table
ekwo company import ./my-company --owner <user id>    # whole, or not at all
```

**A company leaves with its books.** `export` runs as a member holding
`company.export`, under row level security, and writes an archive anybody can
read. `import` takes it into another installation in one transaction, or
refuses; members do not travel, `--owner` names the first one. Attached files
live in storage and are listed in the manifest to copy. The format is in
[`docs/company-archive.md`](../../docs/company-archive.md).

## `ekwo doctor`

What a healthy installation is true of. It reads and reports; it never
repairs.

```sh
ekwo doctor --db-url "$URL"          # readable
ekwo doctor --db-url "$URL" --json   # the whole report
```

It compares the database with an inventory of everything this release defines
— tables, columns, views, functions, policies, triggers, types, and the
privileges each role holds — shipped inside this package and generated from
the migrations. A missing object, a missing or extra policy, a changed column
type and a privilege the anonymous role should not hold are problems; your own
extra tables are reported as information. It also checks row level security on
every table, pending migrations, memberships of deleted users, companies
without a bank account, and posted entries that do not balance.

Exit code `0` when there is no problem, `1` otherwise — usable as a deployment
gate.

## `ekwo pack`, in a checkout

A country is data under `packs/<cc>/`; the compiler turns it into the seed
`ekwo init` applies. These commands run in a clone of the repository:

```sh
ekwo pack list           # the packs this checkout carries, and their review status
ekwo pack describe <cc>  # everything one pack says; --json for the whole object
ekwo pack build <cc>     # write its seed, and the lists of packs in the docs
ekwo pack check --all    # exit 1 if a committed seed or list is not the output of the packs
```

`pack describe --json` is the same object the site builds each country's page
from. The format and every rule `pack check` applies are in
[`docs/packs.md`](../../docs/packs.md).

Two commands read an installation instead, and need no clone:

```sh
ekwo pack status --db-url "$EKWO_DB_URL"          # which pack version each company copied
ekwo pack upgrade "My Company" --db-url "…"       # move it to the version this installation holds
```

`upgrade` applies additions on its own, lists everything else for a person to
read, never removes anything from a company's books, and takes `--apply` to
accept what it listed.

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

Without `--db-url` or `--db-region`, nothing is derived and the CLI asks for
the connection string: copy it from the dashboard, Connect → Session pooler.

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
| `--bank-identifier <value>` | Creates the main bank account, wired to the bank journal and its ledger account. What it is written in is the country's: an IBAN, an ABA routing number and an account number (`"021000021 123456789"`), a sort code and an account number, a BSB, an IFSC, a CLABE… `ekwo pack describe <cc>` names it, and it is checked. A country whose pack declares none is asked for an account number as the bank wrote it. `--iban` is the old spelling and is refused where the banks do not use IBANs. Omitted, no bank account is created and `ekwo doctor` says so. |
| `--bic <bic>` | Optional, on that account, for a bank that has one. |
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
| `EKWO_EINVOICE_DIRECTORY` | `--to`, for `ekwo einvoice`. The MCP server reads it too. |
| `EKWO_CONFIG_DIR` | Where profiles and sessions are kept. |
| `EKWO_REGISTRY_URL` | `--registry-url`. Default `https://api.ekwo.ai/v1/registrations`. |
| `EKWO_NO_REGISTER_INVITE` | Set to `1` to hide the invitation to register that `ekwo init` and `ekwo status` show on an installation that is not registered. The MCP server reads it too. |
| `NO_COLOR` | Plain output. |

See [`.env.example`](../../.env.example) at the root of the repository.

## Secrets

The CLI never writes a password or a key to disk. The database password and
the secret key are read from a flag, an environment variable or a masked
prompt, used, and forgotten; `ekwo.json` holds the project URL and the schema
version.

The one thing kept is the session of the person who signed in with
`ekwo login`, in their own configuration directory, readable by them alone,
and refused anywhere inside a repository. `ekwo logout` removes it.

Outside this repository the CLI has one runtime dependency, the Postgres
driver: everything it is handed is a secret, and every dependency is one more
thing that could read it.

## Registering with Ekwo

At the end of an interactive `ekwo init`, you are asked:

> Register this installation with Ekwo, for security advisories that concern
> your version and release notes? Everything works the same without it.

The default answer is no, and no is supported forever. Where nobody is asked
(`--yes`, `--json`), the end of `ekwo init` and `ekwo status` show a short
invitation instead, with the one command:

```sh
npx -y ekwo-os@latest register --email <your address>
```

`EKWO_NO_REGISTER_INVITE=1` hides the invitation. Community works
unregistered: nothing reads the registration to decide what you may do.

Registering writes the address and a date on your instance row, and sends
exactly six fields:

```json
{
  "instance_id": "…",
  "organization": "My Organisation",
  "country": "<cc>",
  "edition": "community",
  "schema_version": "0.11.1",
  "contact_email": "you@example.com"
}
```

No ledger data, no user list, no connection string. `instance_id` is generated
by your own database and is not a licence key. A failed announcement is a soft
message, not a failed install: `ekwo register` retries it. `ekwo unregister`
clears the local fields.

## Testing it against a real project

The test suite runs against Postgres compiled to WebAssembly. To exercise the
network, PostgREST and Supabase Auth as well, run the end-to-end script from a
clone, against an empty project you can throw away:

```sh
npm run e2e:supabase
```

It installs, migrates, signs in, books, files a declaration and closes the
year, and prints a pass/fail table with how long each step took.
[`docs/releasing.md`](../../docs/releasing.md) lists what it reads.

## Licence

[AGPL-3.0-only](../../LICENSE) © Ekwo AI.
