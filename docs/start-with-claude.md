# Start with Claude: try Ekwo on your own books

This is the shortest way to see your own books in Ekwo: a free database of
your own, one command to install, and then Claude — the desktop application or
Claude Code — doing the rest in plain sentences. You bring an export of your
books from wherever they are kept today; Claude takes them over, answers
questions about them and prepares your next VAT return. The web application,
[Ekwo Cloud](https://cloud.ekwo.ai), opens this same instance whenever you
would rather click than type.

It takes about twenty minutes, most of it in the Supabase dashboard. You do
not need to be a developer, but you will paste a few lines into a terminal and
one block into a settings file.

**Before you start, know what is not there yet** (the full list is
[at the end](#what-this-does-not-do-yet)): Ekwo prepares a declaration and you
file it; imported history carries no VAT; the reconciliation marks of your old
books are not re-applied.

## What you need

- A **Supabase account**. The free plan is enough. Ekwo never sees the
  project: it is yours from the first row.
- **Node.js 20 or later**, from [nodejs.org](https://nodejs.org). Type
  `node --version` in a terminal to check.
- **Claude Desktop** ([claude.ai/download](https://claude.ai/download)) or
  **Claude Code**.
- **An export of your books.** The simplest is a trial balance as a CSV file —
  account, debit, credit — which every ledger can produce. A full export from
  another ledger works too. [`compatibility.md`](compatibility.md) lists every
  export Ekwo reads, with the official page that says how to produce each one.

Try it on a copy first: nothing here touches the software your books come from.

## 1. Create a free Supabase project

1. Sign in at [supabase.com](https://supabase.com) and create a **new
   project**. Pick a name, a region near you, and a **database password** —
   write it down, you need it once, in the next step.
2. When the project is ready, collect three things from the dashboard:
   - **Connect** → **Session pooler** → the connection string, with your
     database password where it says `[YOUR-PASSWORD]`. Take the session
     pooler line rather than the direct one, which many networks cannot reach.
   - **Project Settings → API Keys**: the **publishable key**
     (`sb_publishable_…`, or the older **`anon`** key). This is the key Claude
     will use.
   - On the same page, the **secret key** (`sb_secret_…`, or the legacy
     **`service_role`** key). The installer uses it once, to create your user,
     and writes it nowhere.

The **Project URL** is `https://<ref>.supabase.co`, where `<ref>` is the part
after `postgres.` in the connection string.

## 2. Install Ekwo into it

In a terminal:

```sh
npx -y ekwo-os@latest init
```

The installer asks its questions one by one:

| It asks | What to answer |
|---|---|
| The connection string | The session pooler line from step 1, with your password in it |
| The country | The country whose rules your books follow. Nothing is preselected |
| Your organisation, then the first company | Names. The company is the one whose books you are bringing |
| The first day of the financial year | Only where the country does not fix one |
| The chart of accounts and the language of the books | Only where the country publishes more than one |
| How often the company files its VAT return | Only where that depends on the company |
| Your main bank account | Optional, written the way your country's banks write it. Enter skips it |
| The administrator's e-mail address, the secret key and a password | This is **you**: the user Claude will sign in as. Choose a real password and keep it |

It takes a few seconds and ends with a summary, then lists **four things to do
on your project** — among them, switching off public sign-up. Do them while
the dashboard is open; they are explained in the
[installation guide](../packages/cli/README.md#before-you-go-live-four-things-on-your-project).
At the very end it offers to register the installation with Ekwo for security
advisories and release notes; it is optional, and the
[installation guide](../packages/cli/README.md#registering-with-ekwo) lists
what it sends.

## 3. Connect Ekwo to Claude

The connection is the Ekwo MCP server, [`@ekwo-ai/mcp`](../packages/mcp/README.md),
published on npm and listed in the official MCP registry as `ai.ekwo/mcp`.
Claude starts it on your computer. It signs in to your project as the user you
just created, and can do exactly what that user can do and nothing more.

It needs four values:

| Variable | Value |
|---|---|
| `SUPABASE_URL` | `https://<ref>.supabase.co` |
| `SUPABASE_ANON_KEY` | The publishable key, or the legacy `anon` key |
| `EKWO_EMAIL` | The administrator's address you gave the installer |
| `EKWO_PASSWORD` | Its password |

### In Claude Desktop

1. Open **Settings** from the Claude menu of your computer's menu bar, then
   **Developer → Edit Config**. That opens `claude_desktop_config.json`.
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
   conversation, the **+** button → **Connectors** lists `ekwo`.

If it does not appear, the server's log is `mcp-server-ekwo.log`, in
`~/Library/Logs/Claude` on macOS or `%APPDATA%\Claude\logs` on Windows.

### In Claude Code

```sh
claude mcp add --scope user \
  --env SUPABASE_URL=https://YOURREF.supabase.co \
  --env SUPABASE_ANON_KEY=sb_publishable_… \
  --env EKWO_EMAIL=you@example.com \
  --env EKWO_PASSWORD='the password you chose' \
  --transport stdio ekwo -- npx -y @ekwo-ai/mcp@latest
```

`--scope user` keeps the entry in your own `~/.claude.json`. Do not use
`--scope project`: it would write the password into a file meant to be
committed. Then run `/mcp` inside Claude Code: `ekwo` should read
**connected**.

The password sits in plain text in either file, like any value in a client's
configuration; keep the file to yourself.

**With an Ekwo Cloud account**, there is a shorter way with nothing in a file:
add `https://mcp.ekwo.ai/mcp` as a custom connector and approve it in your
browser. [`packages/mcp`](../packages/mcp/README.md) explains both routes.

## 4. Several companies, several countries

Start a conversation. Claude reads the description of every tool, so you speak
about your books, not about tools.

**"Is Ekwo connected? List my companies."** Claude calls `status` and
`list_companies`: the schema version, and the company the installer created,
with you as its owner.

One installation keeps the books of as many companies as you like, in as many
countries: the installer loads the rules of every country Ekwo has a pack for.

**"Create a second company, Harbourlight Ledger Ltd, in the United Kingdom,
its financial year starting on 1 January 2026."** Claude calls
`create_company`. The company gets its country's chart of accounts, journals,
taxes and VAT return, in its own currency, with you as its owner:

| Company | Country | Currency | Your role |
|---|---|---|---|
| Põhjatuul OÜ | EE | EUR | owner |
| Harbourlight Ledger Ltd | GB | GBP | owner |

Every tool that reads or writes the books names its company, so tell Claude
which one you mean whenever it could be either. Where a country leaves a
choice open — the first day of the year, a chart, a language — the tool
refuses to guess, and Claude asks you.

The command line does the same: `ekwo company new` creates a company, and
`ekwo use` picks the one the next commands run on. An installation with no
single first company — a group, a firm — can start with
`ekwo init --no-company`; see the
[installation guide](../packages/cli/README.md#several-countries-in-one-installation-init---no-company).

## 5. Ask Claude to take over your books

**"Here is the trial balance of Põhjatuul OÜ at 1 January 2026. Import it —
show me first what you would do."** Attach the CSV (in Claude Code, give its
path). Claude calls `import_books` with `dry_run` on, which writes nothing. The
answer is the **correspondence**: for every account of your old books, the
account of the new chart it would go to, and why. A few lines of it, from the
two companies above:

| Old account | Proposed | Basis, and why |
|---|---|---|
| 101000 Bank current account | 1010 | suggested, same digits — its name is the one 1010 has in the chart |
| 120000 Customers | 1200 | suggested, same digits — its name says a receivable, and 1200 is one |
| 610 Accounts receivable | 1100 | suggested, kind — 6100 has the same digits but is an expense account, so the chart's receivable is proposed instead |
| 090 Business current account | — | none — the chart has neither the code nor its digits |

**Read every line before you agree.** Only the same code, confirmed by what
the file says of the account, is `exact`; everything else is `suggested` and
waits for you, or `none`. Two charts can use the same digits for different
things, so a suggestion can be wrong. Nothing is posted while a line is only
suggested.

**"610 is 1100, as you suggest. 090 is the bank current account, 1300."**
Claude runs the rehearsal again with your answers. When nothing is left open,
the database runs the whole import and takes it back, so what you see is what
would happen, and any refusal is the real one. When every suggestion is right:
**"Every suggestion is right, accept them."**

**"That's right. Import it for real."** The opening entry is posted, all of it
or none of it. The same file a second time is refused rather than counted
twice.

For a larger history — the entries of a whole year — the steps are the same.
A file that does not balance, or a date it does not make unambiguous, is
refused by name rather than guessed. The tool takes up to 256 KiB of text;
beyond that it answers with the `ekwo import` command that reads the files
from your disk and runs the same import ([`import.md`](import.md)). Claude Code
can run it for you.

Bank statements are not books: say **"import this bank statement"** and Claude
uses `import_bank_statement`, which records the lines to be matched and books
nothing.

## 6. Ask questions, prepare a return

Now it is your books. Sentences that work, and what answers them:

| You say | Claude uses |
|---|---|
| "Show me the trial balance for 2026." | `trial_balance` |
| "Every movement on the customers account." | `general_ledger` |
| "Who owes me money, and since when?" | `aged_balance` |
| "Invoice Lõuna Pagarid 1 000 for consulting at the standard rate, and post it." | `search_contacts`, `create_document`, `post_document` |
| "Send them a link to the invoice." | `share_document` |
| "Prepare my VAT return for January." | `vat_return` |

The return is computed from what was booked in Ekwo during the period, box by
box, in the form the country's administration uses.

Claude finds its way on its own: the server tells it, at the handshake, what to
call first and how to correct what is posted. The same first session, tool by
tool, is in [`agents.md`](agents.md).

**Filing is yours.** Ekwo prepares the figures; you send them on your tax
administration's portal, or give them to whoever files for you. What a
declaration goes through after it is computed — freezing it, keeping what was
sent, noticing a period that changed afterwards — is in [`filing.md`](filing.md).

## What this does not do yet

- **No filing.** Ekwo prepares a declaration and does not transmit it to an
  administration. Sending it, and answering for it, is yours.
- **No VAT on imported history.** An imported line feeds the ledger, the
  balances and the financial statements, and no box of a VAT return: a period
  kept elsewhere was declared from where it was kept.
- **No reconciliation marks.** Open items are matched again in Ekwo, with
  `reconcile` ("match this payment with that invoice").
- **No new accounts.** An old account the new chart does not have is pointed
  at one that exists, or added first.
- **No documents.** Old invoices arrive as the entries they were posted as.

Before you rely on anything Ekwo prepares, read [DISCLAIMER.md](../DISCLAIMER.md):
a country pack is a reading of the rules at the date of its version, and the
books are yours.

## Checked for real

Every step above runs end to end against throwaway Supabase projects with the
published packages, from a script that can be repeated on any release:
[`docs/demo/start-with-claude/walkthrough.mjs`](demo/start-with-claude/walkthrough.mjs).
The trial balances it imports are beside it; the data is invented.
