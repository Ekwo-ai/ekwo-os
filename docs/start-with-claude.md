# Start with Claude: try Ekwo on your own books

This is the shortest way to see your own books in Ekwo: a free database of
your own, one command to install, and then Claude — the desktop application or
Claude Code — doing the rest in plain sentences. You bring an export of your
books from wherever they are kept today; Claude takes them over, answers
questions about them and prepares your next VAT return. No web interface is
involved, because there is none yet.

It takes about twenty minutes, most of it in the Supabase dashboard. You do
not need to be a developer, but you will paste a few lines into a terminal and
one block into a settings file.

**Before you start, know what is not there yet** — the full list is at the end,
under [What this does not do yet](#what-this-does-not-do-yet):

- there is no web interface: you work through Claude, or the command line;
- Ekwo prepares a declaration and does not file it: sending it is yours;
- the history you import carries no VAT: it feeds the ledger and the balances,
  not the boxes of a return;
- the reconciliation marks of your old books are not re-applied.

## What you need

- A **Supabase account**. The free plan is enough. Ekwo never sees the
  project: it is yours from the first row.
- **Node.js 20 or later**, from [nodejs.org](https://nodejs.org). Type
  `node --version` in a terminal to check.
- **Claude Desktop** ([claude.ai/download](https://claude.ai/download)) or
  **Claude Code**.
- **An export of your books.** The simplest is a trial balance as a CSV file —
  account, debit, credit — which every ledger can produce. An export from
  another ledger works too, as it comes out of it: the journal entries, the
  chart of accounts and the customers and suppliers.
  [`compatibility.md`](compatibility.md) lists every export Ekwo reads today,
  with the official page that says how to produce each one.

Try it on a copy first. The steps below create a project for the purpose, and
nothing here touches the software your books come from.

## 1. Create a free Supabase project

1. Sign in at [supabase.com](https://supabase.com) and create a **new
   project**. Pick a name, a region near you, and a **database password** —
   write the password down, you need it once, in the next step.
2. When the project is ready, collect three things from the dashboard:
   - **Connect** (at the top of the project page) → **Session pooler** → the
     connection string. It looks like
     `postgresql://postgres.<ref>:[YOUR-PASSWORD]@aws-1-<region>.pooler.supabase.com:5432/postgres`.
     Put your database password where it says `[YOUR-PASSWORD]`. Take the
     *session pooler* line and not the direct one: the direct host answers on
     IPv6 only, and many home and office networks cannot reach it.
   - **Project Settings → API Keys**: the **publishable key**
     (`sb_publishable_…`). If your dashboard only shows the older keys, the
     **`anon`** key does the same job. This is the key Claude will use.
   - On the same page, under **Legacy API Keys**, the **`service_role`** key.
     The installer uses it once, to create your user, and writes it nowhere.
     Use the legacy `service_role` key, not a new secret key (`sb_secret_…`):
     the installer of the 0.6 release sends it as a bearer token, which a
     secret key does not accept.

The **Project URL** is `https://<ref>.supabase.co`, where `<ref>` is the part
after `postgres.` in the connection string. The installer works it out from
the connection string; Claude needs it written in full.

## 2. Install Ekwo into it

In a terminal:

```sh
npx ekwo-os init
```

The installer asks its questions one by one:

| It asks | What to answer |
|---|---|
| The connection string | The session pooler line from step 1, with your password in it |
| The country | The country whose rules your books follow. Nothing is preselected: the list is the country packs Ekwo holds |
| Your organisation, then the first company | Names. The company is the one whose books you are bringing |
| The first day of the financial year | Only where the country does not fix one — for example the United Kingdom, where each company chooses its year |
| The chart of accounts and the language of the books | Only where the country publishes more than one |
| How often the company files its VAT return | Only where that depends on the company |
| An IBAN | Optional. Enter skips it |
| The administrator's e-mail address, the `service_role` key and a password | This is **you**: the user Claude will sign in as. Choose a real password and keep it |

It takes a few seconds and ends with a summary: the company, its chart, the
return it files and its first financial year. Then it lists **four things to
do on your project** — among them, switching off public sign-up in
Authentication. Do them while the dashboard is open; they are explained in the
[installation guide](../packages/cli/README.md#before-you-go-live-four-things-on-your-project).

Everything can also be given as flags, for example
`npx ekwo-os init --country EE` or `npx ekwo-os init --country GB
--fiscal-year-start 2026-04-01`; the
[installation guide](../packages/cli/README.md) lists them.

The installer needs a country for this first company: there is no
installation without one today. Every other company, in the same country or
another, comes later and needs no second installation — see
[Several companies, several countries](#4-several-companies-several-countries).

## 3. Connect Ekwo to Claude

The connection is the Ekwo MCP server, [`@ekwo-ai/mcp`](../packages/mcp/README.md),
published on npm and listed in the official MCP registry as `ai.ekwo/mcp`.
Claude starts it on your computer. It signs in to your project as the user you
just created, and can do exactly what that user can do and nothing more: it
never holds the `service_role` key, and refuses to start with one.

It needs four values:

| Variable | Value |
|---|---|
| `SUPABASE_URL` | `https://<ref>.supabase.co` |
| `SUPABASE_ANON_KEY` | The publishable key, or the legacy `anon` key |
| `EKWO_EMAIL` | The administrator's address you gave the installer |
| `EKWO_PASSWORD` | Its password |

### In Claude Desktop

1. Open **Settings** from the Claude menu of your computer's menu bar (not the
   settings inside the chat window), then **Developer → Edit Config**. That
   opens `claude_desktop_config.json`:
   - macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - Windows: `%APPDATA%\Claude\claude_desktop_config.json`
2. Put this in it — or, if the file already has an `mcpServers` section, add
   the `"ekwo"` entry inside it:

   ```json
   {
     "mcpServers": {
       "ekwo": {
         "command": "npx",
         "args": ["-y", "@ekwo-ai/mcp@latest"],
         "env": {
           "SUPABASE_URL": "https://YOURREF.supabase.co",
           "SUPABASE_ANON_KEY": "sb_publishable_…",
           "EKWO_EMAIL": "you@example.com",
           "EKWO_PASSWORD": "the password you chose"
         }
       }
     }
   }
   ```

3. **Quit Claude Desktop completely and open it again.** In a new
   conversation, the **+** button at the bottom left of the message box →
   **Connectors** lists `ekwo`; **Manage connectors** shows its tools.

If it does not appear, the logs are in `~/Library/Logs/Claude` on macOS
(`%APPDATA%\Claude\logs` on Windows): `mcp-server-ekwo.log` holds what the
server said. The procedure is the one in
[Connect to local MCP servers](https://modelcontextprotocol.io/docs/develop/connect-local-servers),
the Model Context Protocol's own guide, which uses Claude Desktop as its
example.

### In Claude Code

One command, from any directory:

```sh
claude mcp add --scope user \
  --env SUPABASE_URL=https://YOURREF.supabase.co \
  --env SUPABASE_ANON_KEY=sb_publishable_… \
  --env EKWO_EMAIL=you@example.com \
  --env EKWO_PASSWORD='the password you chose' \
  --transport stdio ekwo -- npx -y @ekwo-ai/mcp@latest
```

Everything before `--` is for Claude Code; everything after it is the command
that starts the server. Keep the `@latest`: without a version, `npx` run from
inside a clone of the Ekwo repository finds the workspace package of the same
name, which has no built command, and answers `ekwo-mcp: command not found`.
With it, `npx` always fetches the published server, wherever it is started. `--scope user` keeps the entry in your own
`~/.claude.json`, for every project. Do not use `--scope project`: it writes
the block, password included, into a `.mcp.json` meant to be committed with
the project. Then run `/mcp` inside Claude Code: `ekwo` should read
**connected**. The reference is
[Connect Claude Code to tools via MCP](https://code.claude.com/docs/en/mcp).

The password sits in plain text in either file, like any value in a client's
configuration. It is the password of your Ekwo user on your own project;
keep the file to yourself.

## 4. Several companies, several countries

Start a conversation. Claude reads the name and description of every tool, so
you speak about your books, not about tools. The examples in this guide are
two companies kept side by side in one installation — one in Estonia, one in
the United Kingdom. The names and amounts are invented; the answers are what
the server returned when this guide was run end to end (see
[Checked for real](#checked-for-real)).

**"Is Ekwo connected? List my companies."** Claude calls `status` and
`list_companies`: the schema version, and the company the installer created,
with you as its owner.

One installation keeps the books of as many companies as you like, and they
need not share a country. The installer loads the rules of every country Ekwo
has a pack for, not only the one you chose, so a company in another country is
one sentence away:

**"Create a second company, Harbourlight Ledger Ltd, in the United Kingdom,
its financial year starting on 1 January 2026."** Claude calls
`create_company`. The company gets the United Kingdom's chart of accounts,
journals, taxes and VAT return, in pounds, with you as its owner — while the
first keeps Estonia's, in euros. Asked again, `list_companies` shows both:

| Company | Country | Currency | Your role |
|---|---|---|---|
| Põhjatuul OÜ | EE | EUR | owner |
| Harbourlight Ledger Ltd | GB | GBP | owner |

Every tool that reads or writes the books names its company, so tell Claude
which one you mean — "for Harbourlight, …" — whenever it could be either.
Creating a company is an act on the whole installation: it needs an
administrator, which the installer made you. A country whose year does not
open on a fixed day — the United Kingdom again — needs the first day said: the tool
refuses to pick one, so Claude asks you.

In the terminal, the company the commands run on is chosen with `ekwo use`,
once you are signed in:

```sh
npx ekwo-os login            # asks the project URL, the key, your address and password
npx ekwo-os use "Harbourlight Ledger Ltd"
npx ekwo-os whoami           # the companies you can see, and the one in use
```

The command line needs a country only once, for the first company, at
`init`; it does not create companies after that. Ask Claude.

## 5. Ask Claude to take over your books

Each company arrives with the trial balance of its previous ledger.

**"Here is the trial balance of Põhjatuul OÜ at 1 January 2026. Import it —
show me first what you would do."** Attach the CSV to the message (in Claude
Code, give its path). Claude calls `import_books` with `dry_run` on, which
writes nothing. The answer is the **correspondence**: for every account of
your old books, the account of the new chart it would go to, how it was found,
and why.

| Old account | Proposed | Basis, and why |
|---|---|---|
| 101000 Bank current account | 1010 | suggested, same digits — its name says a bank account, and 1010 is one |
| 120000 Customers | 1200 | suggested, same digits — its name says a receivable, and 1200 is one |
| 297000 Retained earnings | 2970 | suggested, same digits — its balance is on the credit side, and 2970 is an equity account |

**Read every line before you agree.** The codes give a candidate: the same
code, the same code without the zeros padded on the right, or the longest
beginning the chart has. Then what the file says of the old account — the type
an export gives it, its name, the side of its balance — is held against what
the new chart says the candidate is. Only the same code, confirmed, is
`exact`; everything else is `suggested` and waits for you, or `none`. Nothing
is posted while a line is only suggested. Two charts can use the same digits
for different things, and the other company shows why:

| Old account | Proposed | Basis, and why |
|---|---|---|
| 090 Business current account | — | none — the chart has neither the code nor its digits |
| 610 Accounts receivable | 1100 | suggested, kind — 6100 has the same digits and is an **expense** account, so it is not proposed; 1100 Trade debtors is the chart's receivable |
| 710 Office equipment | 7100 | suggested, same digits — only the side of the balance agrees, and 7100 is Rent: **wrong** |
| 711 Office equipment depreciation | 7110 | suggested, same digits — its balance is on the credit side, and 7110 is an expense account: **wrong** |
| 800 Accounts payable | 2100 | suggested, kind — 8000 is an **expense** account, so it is not proposed; 2100 Trade creditors is the chart's payable |
| 970 Owner capital | — | none |

**"610 is 1100 and 800 is 2100, as you suggest. 090 is the bank current
account, 1300. 710 is office equipment, 0140, and 711 its depreciation, 0141.
970 is share capital, 3300; 960 is 3400."** Claude calls the rehearsal again
with your answers. When nothing is left open, the database runs the whole
import and takes it back, so what you see — the accounts, the customers and
suppliers it would create, the numbers — is what would happen, and any refusal
is the real one. For the first company every suggestion was right, so the
answer can be shorter: **"Every suggestion is right, accept them."**
Claude passes `accept_suggestions`, which takes every suggested line as it was
shown — only once you have read them all.

**"That's right. Import it for real."** `import_books` without `dry_run`. The
opening entry is posted, all of it or none of it, and the file is recorded:
the same file a second time is refused rather than counted twice, and the
refusal says which file it was, when it was imported and what it wrote.

For a larger history — the entries of a whole year, from an export of
another ledger — the steps are the same: the rehearsal, the correspondence,
then the import. A file that does not balance, or a date the file does not
make unambiguous, is refused by name rather than guessed. The export each
source expects is in [`compatibility.md`](compatibility.md) and the mechanics
in [`import.md`](import.md).

**A large export goes through the terminal.** The tool receives the files as
text inside the conversation, and refuses more than 256 KiB of them — a year
of entries is often more — with the command to run instead. Signed in once
with `npx -y ekwo-os@latest login`,

```sh
npx -y ekwo-os@latest import <source> <files> --company "<company>" --dry-run --save-mapping correspondence.json
```

reads the files from the disk and runs the same import as the tool: the same
correspondence, printed with the lines to read first, the same rehearsal, the
same refusals. Answer the correspondence in `correspondence.json`, then run it
again with `--mapping correspondence.json` and without `--dry-run`.
`npx -y ekwo-os@latest import --help` lists the sources. Claude Code can run
these commands for you.

Bank statements are not books: say **"import this bank statement"** and Claude
uses `import_bank_statement`, which records the lines to be matched and books
nothing.

## 6. Ask questions, prepare a return

Now it is your books. Sentences that work, and what answers them:

| You say | Claude uses |
|---|---|
| "What is in the bank on 1 January?" | `trial_balance` — for the two companies above, 8 400.00 on 1010 and 12 300.00 on 1300, and the debit and credit columns agree |
| "Show me the trial balance for 2026." | `trial_balance` |
| "Every movement on the customers account." | `general_ledger` |
| "Who owes me money, and since when?" | `aged_balance` |
| "Invoice Lõuna Pagarid 1 000 for consulting at the standard rate, and post it." | `search_contacts`, `create_document`, `post_document` — a customer the import created is found by name |
| "Prepare my VAT return for January." | `vat_return` |

The return is computed from what was booked in Ekwo during the period. With
one invoice of 1 000 at the standard rate, the Estonian company's January
return (form KMD) came back with 1 000.00 in box 1 and 240.00 in boxes 4 and
12; the British company's first quarter (the VAT return) with 200.00 in boxes
1, 3 and 5 and 1 000.00 in box 6. Asked for before that invoice, both were
empty — the imported history carries no tax, as said below.

**Filing is yours.** Ekwo prepares the figures; it does not send them. Copy
them into your tax administration's portal, or give them to whoever files for
you. What a declaration goes through after it is computed — freezing it,
keeping what was sent, noticing a period that changed afterwards — is in
[`filing.md`](filing.md).

## What this does not do yet

Said plainly, so that nothing is a surprise:

- **No web interface.** Ekwo is a database, a command line and the MCP server
  today. A Community web application is planned and not released.
- **No filing.** Ekwo prepares a declaration and does not transmit it to any
  administration. Sending it, and answering for it, is yours.
- **No VAT on imported history.** An imported line has an account and an
  amount, not the tax that produced it. It feeds the ledger, the trial balance
  and the financial statements, and no box of a VAT return: a period kept
  elsewhere was declared from where it was kept.
- **No reconciliation marks.** Which invoice a payment settled in the old books
  is read and not re-applied. Open items are matched again in Ekwo, with
  `reconcile` ("match this payment with that invoice").
- **No new accounts.** An old account the new chart does not have is not
  created: you point it at one that exists, or add it first.
- **No documents.** Old invoices arrive as the entries they were posted as, not
  as documents that can be sent again.

[`compatibility.md`](compatibility.md) keeps the list of sources and of what
an import does not take over, and is kept up to date as readers are added.
Before you rely on anything Ekwo prepares, read [DISCLAIMER.md](../DISCLAIMER.md):
a country pack is a reading of the rules at the date of its version, and the
books are yours.

## Checked for real

Every step above was run against a throwaway Supabase project with the
published `ekwo-os` and `@ekwo-ai/mcp` 0.6.0, and the project deleted
afterwards. The run is a script, so it can be repeated on any release:
[`docs/demo/start-with-claude/walkthrough.mjs`](demo/start-with-claude/walkthrough.mjs)
runs the installer, starts the MCP server with exactly the four variables
above, and calls the tools Claude calls for the sentences of this guide — two
companies in two countries, the second created through `create_company` and
chosen in the terminal with `ekwo use`, the rehearsal, the correction, the import, the
refused second import, the balances, an invoice and the two returns. The two
trial balances and the answered correspondence are beside it; the data is
invented. The two correspondence tables of step 4 are those of the release
after 0.6.0, which holds each proposal against what the files say; the tests
of the repository compute them from the same two files and the two charts.
