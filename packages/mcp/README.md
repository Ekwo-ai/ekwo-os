# @ekwo-ai/mcp

The [Model Context Protocol](https://modelcontextprotocol.io) server for
[Ekwo OS](https://github.com/Ekwo-ai/ekwo-os). It lets an AI agent work on
the books in your own Postgres: read the ledger, raise an invoice, post it, match
a payment, prepare the VAT return — **as you**, under the row
level security of your own installation.

There are two ways to reach it, and they are the same server.

## Hosted, at `https://mcp.ekwo.ai/mcp`

For a client that adds remote servers rather than launching them — claude.ai,
or any other that speaks **Streamable HTTP**. Nothing is installed, and no
password or key is written into a configuration file.

```
https://mcp.ekwo.ai/mcp
```

Point a client at that address and it discovers the rest. An unauthenticated
call is answered with `401` and a `WWW-Authenticate` header naming the
server's protected-resource metadata (RFC 9728); the client follows it to the
authorization server (RFC 8414), registers itself (RFC 7591, so it needs no
credentials of its own) and sends the person to their browser to approve the
connection. The scope asked for is `books`.

An agent reading this without a browser can start from
[`/.well-known/oauth-protected-resource`](https://mcp.ekwo.ai/.well-known/oauth-protected-resource).

The books stay where they are: the hosted server holds none, and connects to
the instance the person chooses when they approve it. On the same screen they decide
whether the agent may write; otherwise it reads. The hosted server is operated
by [Ekwo Cloud](https://cloud.ekwo.ai), and signing in there needs an account.

## Locally, over stdio

```sh
npx -y @ekwo-ai/mcp@latest
```

For a client that launches its own servers — Claude Desktop, Claude Code, any
editor that reads `.mcp.json` — against any installation, with no account.
Keep `@latest` in the command: from inside a clone of the repository, a bare
`npx @ekwo-ai/mcp` finds the unbuilt workspace package and answers
`ekwo-mcp: command not found`.

## What it is, and what it is not

The server holds no privileges of its own. It signs in as the person using it,
or is handed their access token, and everything it can do afterwards is
exactly what that person can do: a viewer reads and cannot write, a member of
one company cannot see another, a locked period refuses a posting. None of
that is checked in this package — the policies and the triggers in the schema
decide, and this server reports what they answered.

Three things it will never do:

- **Write a ledger line.** Every entry comes out of the schema's own
  functions, which carry the accounting rules. Direct inserts are for the
  objects a person types: contacts, draft documents and their lines, payments,
  bank transactions.
- **Delete or edit a posted entry.** No tool removes one. A posted invoice is
  undone the one way its country allows — back to draft where nothing about it
  has left, otherwise by the credit note that names it — and an entry keyed by
  hand by its reversal.
- **Use a `service_role` key.** It would work, and that is the objection: it
  bypasses every policy, so the agent would answer for companies its user
  was never invited to. The server refuses to start with one.

## Configuration

### The recommended route: PostgREST, as the signed-in user

```json
{
  "mcpServers": {
    "ekwo": {
      "command": "npx",
      "args": ["-y", "@ekwo-ai/mcp@latest"],
      "env": {
        "SUPABASE_URL": "https://YOURREF.supabase.co",
        "SUPABASE_ANON_KEY": "your anon (publishable) key",
        "EKWO_EMAIL": "you@example.com",
        "EKWO_PASSWORD": "your password"
      }
    }
  }
}
```

That block goes in `claude_desktop_config.json` for Claude Desktop, or in
`.mcp.json` at the root of a project for Claude Code. `EKWO_ACCESS_TOKEN`
replaces the address and the password when you already hold a session; with
the password, the session is kept in memory and refreshed, and nothing is
written to disk.

### The fallback: a direct Postgres connection

For a self-hosted installation with no PostgREST in front of the database, or
for tests.

```json
{
  "env": {
    "EKWO_DB_URL": "postgresql://…",
    "EKWO_ACT_AS_USER_ID": "the auth.users id this server acts for"
  }
}
```

`EKWO_ACT_AS_USER_ID` is **required**, and that is the whole point of this
mode. A database connection is nobody: `auth.uid()` is null, row level
security is bypassed rather than satisfied, and a server running that way
would be a way round the policies rather than a client of them. So every
query runs inside a transaction that sets `request.jwt.claims` to that user
and switches to the `authenticated` role, and the policies bind exactly as
they do over the API. This mode needs the `postgres` package installed
alongside the server; the recommended route needs no driver at all.

| Variable | Meaning |
|---|---|
| `SUPABASE_URL` | `https://<ref>.supabase.co` |
| `SUPABASE_ANON_KEY` | The anon (publishable) key. A `service_role` key is refused. |
| `EKWO_EMAIL` / `EKWO_PASSWORD` | The user this agent acts as |
| `EKWO_ACCESS_TOKEN` | A session already in hand, instead of the two above |
| `EKWO_DB_URL` | A direct Postgres connection, for a self-hosted installation |
| `EKWO_ACT_AS_USER_ID` | Required with `EKWO_DB_URL`: the `auth.users` id to act for |
| `EKWO_NO_REGISTER_INVITE` | Optional. `1` leaves the invitation to register out of the instructions |
| `EKWO_EINVOICE_DIRECTORY` | Optional. The folder electronic invoices are sent to by `einvoicing_issue` with `send`. Unset, files are issued and kept, and sending is refused as `no_transport` |

### Started with nothing set

A client lists a server's tools as soon as it is added, and so do the
directories that index MCP servers. So with **none** of the variables above —
or with half of them — the server still starts, still answers the list of
tools, and every tool call returns a `not_configured` error that names the
variables to set and where. It connects nowhere until then, and it offers the
tools of the socle only: which modules an installation carries is read from
its database.

Only absence is forgiven. A `service_role` key, in either slot, and an
`EKWO_ACT_AS_USER_ID` that is not a uuid are values somebody wrote, and the
server still refuses to start with them.

```sh
npm run build -w @ekwo-ai/mcp
node packages/mcp/scripts/introspect.mjs     # starts it with no environment and lists the tools
```

The `Dockerfile` at the root of the repository builds the same server from the
checkout; `docker run -i --rm <image>` speaks MCP over stdio, with the variables
passed as `-e`.

## Over HTTP: hosting it for others

The same server, reached by URL instead of started by a client:
`handleHttpRequest` answers the **Streamable HTTP** transport of MCP. It is
**stateless** — each request builds a server, answers in JSON and closes it,
with no session id and nothing kept — so it runs on a function platform,
behind a load balancer, or in one process. A `GET` is answered `405`: this
server never speaks first, so there is no stream to open.

It does not decide who is calling: the host authenticates the request its own
way, then hands in **the connection that request may use**.

```ts
import { handleHttpRequest } from '@ekwo-ai/mcp';

export default async function (request: Request): Promise<Response> {
  const who = await yourOwnAuthentication(request);      // a token you issued
  if (who === undefined) return new Response(null, { status: 401 });
  return handleHttpRequest(request, {
    supabaseUrl: who.supabaseUrl,                         // https://<ref>.supabase.co
    anonKey: who.publishableKey,                          // never the service_role key
    apiKey: who.ekwoKey,                                  // or: accessToken: who.session
  });
}
```

A connection is one of two things, never both:

- **A person's access token** on the instance. Row level security decides,
  exactly as for that person in a browser.
- **A key of Ekwo OS**, as `create_api_key()` issues it. It travels in the
  `X-Ekwo-Api-Key` header with no `Authorization` beside it, the schema's
  pre-request hook presents it (decision
  [0062](../../docs/decisions/0062-a-key-reaches-the-api.md)), and the caller
  is on that key's one company with that key's capabilities. A key issued
  without a capability that writes gives an agent that reads.

A `service_role` key is refused in all three slots, as on stdio. For
`node:http` (or anything built on it), `handleNodeRequest(req, res,
connection, { origin })` is the same handler.

### Putting it in front of people: authorization

A remote MCP client expects the server to follow the [authorization part of
the MCP
specification](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization):
OAuth 2.1 with PKCE, protected resource metadata (RFC 9728), authorization
server metadata (RFC 8414) and dynamic client registration (RFC 7591). That
belongs to the host, not to this package: the host signs the person in, issues
its own tokens, and maps each one to a connection above. The database stays
the only place that decides what may be read or written.

## The tools

Every write names its company explicitly.

| Tool | What it does |
|---|---|
| `list_companies` | The companies you are a member of, with your role on each |
| `get_company` | Financial years, lock dates, journals, default accounts |
| `list_accounts` | The accounts a company works with, by code prefix, type or name. `include_all` for the whole chart |
| `search_contacts` | Customers and suppliers, by name, type or VAT number |
| `search_products` | The catalogue: code, unit, price, account and tax of what is sold and bought |
| `list_documents` | Invoices, credit notes and quotes, filtered |
| `get_document` | One document with its lines and the entry it produced |
| `render_invoice_pdf` | The PDF of a sale invoice or credit note, as a PDF resource (base64) beside a JSON summary, rendered from the books by [`@ekwo-ai/invoice-pdf`](../formats/invoice-pdf/README.md). `factur_x` embeds the CII of a posted sale (Factur-X, EN 16931, PDF/A-3) and returns the rules it breaks; `labels` gives the words of the layout in the document's language. The logo is fetched by the server from the company's `logo_url`, never from a local or private address. Records nothing |
| `list_bank_accounts` | The bank accounts of a company, with the journal and ledger account behind each |
| `list_bank_transactions` | Statement lines, pending by default |
| `trial_balance` | Opening, movements and closing per account |
| `general_ledger` | Every posted line of an account, with a running balance |
| `aged_balance` | What is still owed, bucketed by age, read from the ledger |
| `vat_return` | The boxes for a period, summed from the ledger |
| `ec_sales_list` | The recapitulative statement of European Union supplies: one line per customer VAT number and per nature |
| `portfolio_upcoming_filings` | *Portfolio* = the companies you may read: for an accounting firm, its clients ([`docs/firms.md`](../../docs/firms.md)). What falls due between two dates in every company you hold `filings.read` on. One row per company at least: a pack that names no deadline is listed without a date, and says so |
| `portfolio_filings_touched_since` | Declarations that have gone and whose period received entries afterwards, across the same companies, with the company named |
| `list_statements` / `financial_statement` | The schemes a company can be presented on, and one statement |
| `generate_fec` | The French FEC as text, with its checks and its filename, for a company that keeps French books |
| `read_audit_log` | Who changed what and when: the configuration of a company, and the acts that change a state. Append-only for every client; only the database writes it |
| `get_preferences` | What you prefer, and the language chain to read labels with |
| `list_invitations` | Who has been invited into a company and not yet joined |
| `list_api_keys` | The machine keys of a company, and what each may do |
| `describe_pack` | Which country packs this installation holds: their version, how much anyone has read them, and the register of texts each was built from — title, official publisher, link and the day it was opened |
| `status` | Schema version, instance, connection, companies |
| `create_contact` | A customer, supplier or other third party |
| `create_product` | A catalogue row: code, name, unit, price, account, tax |
| `update_product` | Changes one, or retires it with `active: false` |
| `pin_accounts` | Adds accounts to the working chart a company sees first, or takes one back out with `pinned: false` |
| `create_document` | A draft invoice, credit note or quote, with its lines. With `client_ref`, calling twice creates once |
| `update_document_lines` | Replaces the lines of a **draft** |
| `post_document` | Books it. `dry_run: true` returns the entry the database would write, and writes nothing |
| `cancel_document` | Undoes a posted invoice, and says how in `undone_by`: back to `draft` where its country's `posted_edit_policy` allows it and nothing about it has left (`unpost_document()`), otherwise a `credit_note` that names it, posted and matched against it, and the invoice cancelled (`cancel_document()`), with `why` the draft was ruled out. A credit note is dated on the invoice's day while that period is open; otherwise the caller gives a date. A date, or `credit_note: true`, asks for the credit note |
| `reverse_entry` | Undoes a posted entry keyed by hand: its mirror, posted under the next number and matched against it. Same rule for the date |
| `record_payment` | Books money in or out and matches it against open invoices — or, with `document_id`, against that document alone, which then names the contact and the direction. With `client_ref`, recording twice records once |
| `reconcile` / `unreconcile` | Matches two ledger lines, or undoes one matching |
| `create_bank_account` | Registers an account from its identifier, in the scheme the company's country uses (an IBAN, a routing number and an account number, a sort code and an account number…), and wires it to the bank journal. Running it twice with the same identifier creates nothing |
| `create_bank_transaction` | One statement line by hand, for an installation with no feed |
| `import_bank_statement` | A statement file (`camt.053`, `coda`, `cfonb120`) into statements and pending lines. Books nothing; the same file twice creates nothing; an unknown account or a statement that does not add up is refused by name, a missing statement is signalled |
| `lock_period` | Moves the accounting and VAT lock dates. Needs `company.write`. |
| `opening_balance` | The trial balance of whatever kept the books before, as the opening entry |
| `import_books` | Books kept elsewhere — a FEC, an export of journal items, a journal report, a trial balance — whole or not at all. `dry_run: true` first: the correspondence proposed for every account and journal — `exact` only for the same code the files do not contradict, otherwise `suggested` with its reason, or `none` — what has no answer, and the import rehearsed by the database and taken back. Then again with the completed `mapping`, or `accept_suggestions` once the user has read every suggestion; nothing is posted while one is unconfirmed. Every entry through `post_entry()`; no tax; the same files twice refused, saying when and what. The files travel as text, 256 KiB at most: beyond, the tool answers with the `ekwo import` command that reads them from the disk. `ekwo import` is the same function |
| `close_fiscal_year` / `reopen_fiscal_year` | Closes a year the way the country pack says, or reverses a close run too early |
| `create_company` | A company on a country pack, with its chart and its first financial year. An instance-level act |
| `update_company_profile` | What a company says about itself on its documents |
| `set_preferences` | Your own language, timezone, formats and default company |
| `invite_member` / `revoke_invitation` | Invites an address into a company, or withdraws the invitation. The token is shown once |
| `remove_member` / `set_member_role` | Takes a member out of a company — leaving oneself needs no `members.manage` — or moves them to another preset, clearing their per-member adjustments. The last owner is neither removed nor demoted |
| `create_api_key` / `revoke_api_key` | A key for a machine, scoped to one company and a list of capabilities |
| `share_document` / `list_shares` / `revoke_share` | Publishes a posted sales document behind a link the customer opens without an account, lists the links with how often each was opened, or withdraws one ([`docs/sharing.md`](../../docs/sharing.md)) |

**`list_accounts` answers with the working chart, not the whole one.** A
country pack transcribes the regulation — sometimes more than a thousand
accounts — and a company works with a few dozen. The default is the accounts
with posted entries, those the company's settings or an enabled module point
at, and those somebody pinned with `pin_accounts`. `include_all` returns the
whole chart, and every write tool still accepts any account of it.

`post_document`, `cancel_document`, `reverse_entry`, `record_payment`,
`update_document_lines`, `unreconcile`, `lock_period`, `opening_balance`, `import_books`,
`close_fiscal_year`, `reopen_fiscal_year`, `revoke_invitation`, `remove_member`,
`set_member_role`, `revoke_api_key` and `revoke_share` are annotated destructive in the protocol, so a client can ask
before calling them.

**What a tool may do is the capability the user holds**, not the tool's own
right: the server acts as the person it signed in as, so `post_document` works
for an accountant and is refused to a viewer, by the database, with the
database's own words. `get_company` returns `your_capabilities` for exactly
that reason.

**The modules.** A module of this installation gets its own tools, under the
prefix its `module.json` declares, and the server reads `public.modules` at
startup to know which: `fixed_assets_list`, `fixed_assets_create`,
`fixed_assets_schedule`, `fixed_assets_run_depreciation`,
`fixed_assets_dispose`, `budgets_list`, `budgets_upsert_lines`,
`budgets_variance`, `einvoicing_validate`, `einvoicing_issue`,
`einvoicing_status`, `einvoicing_list`. A module that is not installed is not
offered. When the project does not expose a module's schema yet, the tool says
which setting to change.

The electronic invoicing tools send through a transport the server is given,
never one a model chooses: the folder of `EKWO_EINVOICE_DIRECTORY`, or a
transport a host hands to `buildServer()` as `einvoiceTransport`. No
credential of a network ever reaches a tool. See
[`modules/einvoicing`](../../modules/einvoicing/README.md).

**Resources.** `ekwo://companies/{id}/chart` is the whole chart of accounts;
`ekwo://companies/{id}/taxes` is every tax with the ledger account and the
declaration box each of its postings feeds.

**Prompts.** `close_month` walks the month-end checklist — drafts, unmatched
bank lines, the balance, the VAT, what is still open. `prepare_vat_return`
pulls the boxes and ties them back to the ledger before anything is filed.

## What an agent reads first

The instructions of the handshake are a first session in five steps:
`list_companies`, then `get_company` for the financial years and the lock
dates, then `list_accounts` and the taxes resource for the codes a line names,
then `search_contacts` and `create_document`, and `post_document` once the user
agrees. They say how to read `vat_return`, how a posted document or entry is
corrected (`cancel_document`, `reverse_entry`), and that a refusal comes with
its next step. The descriptions of those tools each name the tool to call next.
[`docs/agents.md`](../../docs/agents.md) is the same session for the person
setting the agent up, with the command line beside it.

On an installation that is not registered with Ekwo, the instructions carry
one more line: an invitation the agent may relay to the person once, at a
natural pause, with what registering gives and the command. The `status` tool
carries it as the field `registration`. Registering is optional and changes
nothing about what this server does; `EKWO_NO_REGISTER_INVITE=1` in the
server's environment leaves the line out, and the hosted server never adds it.

## Conventions

- **Amounts are decimal strings.** `"1210.00"`, never a float. They go in that
  way and come back that way, because `numeric` is exact and a float is not.
- **Dates are ISO**, `2026-06-15`. Identifiers are uuids.
- **Totals are computed by the database.** `create_document` returns the draft
  with the totals the schema derived, not with anything the caller supplied.
- **Refusals travel unchanged.** `period_locked:`, `entry_unbalanced:`,
  `document_total_mismatch:` and the rest arrive with the message the database
  raised, plus one sentence saying what it means. They are answers, not
  obstacles to route around.
- **A product fills a line in and never constrains it.** A line naming
  `product_code` takes the catalogue's text, description, unit, price, account
  and tax; anything the line carries wins over that. What is already posted is
  never touched when the catalogue changes, and a product referenced by a line
  is retired with `active: false` rather than deleted.
- **A missing tax is a missing tax.** A line with no tax books a base with no
  VAT box, which is not the same as 0 %. A missing *account* is different: it
  can only mean "resolve it", because a product line with no account is
  refused by a check constraint. So a line may leave `account_code` out, and
  the database fills it — the company default, then the country model.

## Testing it by hand

The automated tests run every tool against the real schema in Postgres
compiled to WebAssembly (`tests/mcp/`), refusals included. To exercise
PostgREST and Supabase Auth too, install on a project you can throw away
(`npx -y ekwo-os@latest init`), point a client at it with the block above, and
try a first session:

1. **"List my companies."** The company you created, with `your_role: owner`.
2. **"Create a customer, then invoice them 1 000 for consulting at the
   standard rate."** `create_contact`, then `create_document`; the totals in
   the answer are computed by the database.
3. **"Post it."** `post_document`, which takes the next number of the sales
   journal.
4. **"They paid 500 on the 10th."** `record_payment`; the invoice becomes
   partially paid.
5. **"Show me the trial balance and the VAT for the quarter."**
   `trial_balance` and `vat_return`.
6. **"Lock June."** `lock_period`; anything dated in June is then refused with
   `period_locked:`.

A company installed from its country pack has bank and cash journals already
wired to their accounts, so `record_payment` works with nothing else set up;
`create_bank_account` registers the real account.

## Licence

[AGPL-3.0-only](../../LICENSE) © Ekwo AI.
