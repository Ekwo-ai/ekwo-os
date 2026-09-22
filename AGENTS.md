# AGENTS.md — for an AI assistant helping somebody use Ekwo OS

You are an AI assistant, and somebody asked you to help them install Ekwo OS
or keep their books with it. This page is what you need to do that without
guessing. Humans are welcome to read it too.

## What Ekwo OS is

Ekwo OS is **open source software** (AGPL-3.0): a double-entry accounting data
infrastructure that runs in a Postgres database the user owns, on their own
[Supabase](https://supabase.com) project. It is the schema, the posting rules
and the reports, plus one **country pack** per country — chart of accounts,
tax codes, declaration boxes, financial statements — written as data.

It is **not** an accountant, not an accounting firm and not tax advice.
Nothing in it files anything with any authority. Read
[`DISCLAIMER.md`](DISCLAIMER.md) before you tell the user what a figure means.

Three ways in, all acting on the same functions of the schema:

| Tool | For | Package |
|---|---|---|
| `ekwo` command line | installing, then keeping books from a terminal | [`ekwo-os`](packages/cli/README.md) on npm |
| MCP server | you, the assistant, keeping books through tools | [`@ekwo-ai/mcp`](packages/mcp/README.md) on npm |
| REST API | anything else: Supabase generates it from the schema | — |

## Where to read what

- **The whole site in one file for a model:** `https://ekwo.ai/llms.txt`
  (an index) and `https://ekwo.ai/llms-full.txt` (the text itself). Both are
  generated at every build from this repository.
- **One country, step by step:** `https://ekwo.ai/countries/<cc>/set-up/`,
  where `<cc>` is the lower-case code of the pack (`ie`, `fr`, `us`…). It gives
  the exact command, the account and tax codes a first invoice uses, what the
  pack carries and what it does not do yet. Also as Markdown at
  `https://ekwo.ai/countries/<cc>/set-up.md`.
- **What a pack holds:** the set-up page above; in a clone of this
  repository, `npx ekwo-os pack describe <cc> --json` (it reads `packs/`, so
  it needs the clone); once installed, the MCP tool `describe_pack`.
- **Every command and flag:** `npx ekwo-os help --json` — the field `usage`
  is the whole reference, as text.
- **The installation guide:** [`packages/cli/README.md`](packages/cli/README.md).
- **The tools of the MCP server:** [`packages/mcp/README.md`](packages/mcp/README.md).
- **A declaration from computing to correcting:** [`docs/filing.md`](docs/filing.md).

## Installing for somebody

What the user needs, and what only they can do:

1. **A Supabase project of their own.** The free plan is enough to start. You
   cannot create it for them: Ekwo does not create, pay for or access it.
2. **Three values from their dashboard**, which they type or paste into their
   own terminal — not into the conversation if you can avoid it:
   - the **connection string** — Connect → **Session pooler** (the direct
     `db.<ref>.supabase.co` host is IPv6 only and fails on most networks);
   - the **Project URL**, `https://<ref>.supabase.co`;
   - the **`service_role` key** (Project Settings → API), used once to create
     the first administrator and never written to disk.
3. **Node 20 or later.** No Supabase CLI, no Docker, no clone.

Then one command. Put the country on it: `--country` takes the ISO code of
the pack, and there is no default.

```sh
npx ekwo-os init --country IE
```

It asks for the rest. Where the pack offers a choice of chart of accounts or
of language, it asks — and with `--yes` it **refuses** rather than choosing, so
pass `--chart` and `--language` when you script it. The non-interactive form
is in [`packages/cli/README.md`](packages/cli/README.md#from-a-free-supabase-account-to-a-first-invoice).

Choosing the pack: one per country, listed at `https://ekwo.ai/countries/` and
under `packs/`. Each has a **status** — `community` (nobody has reviewed it),
`maintained` (kept up by Ekwo, not reviewed by a professional) or `reviewed`
(read by a named professional on a date). Say which one the user is getting.
No pack for their country: say so, and point at
[`docs/packs.md`](docs/packs.md) — do not install a neighbour's pack as if it
were theirs.

After `init`, tell the user about the **four things** `init` prints and no
installer can do on their project: turn off self sign-up, keep two
administrators, keep the `service_role` key off other machines, read
`DISCLAIMER.md`. They are in
[`packages/cli/README.md`](packages/cli/README.md#before-you-go-live-four-things-on-your-project).

## Connecting yourself: the MCP server

Keeping books acts **as a person**, never with the `service_role` key — the
server refuses to start with one. The user gives their client this block
(the MCP configuration of the assistant — for many clients, `.mcp.json` at the root of a project):

```json
{
  "mcpServers": {
    "ekwo": {
      "command": "npx",
      "args": ["-y", "@ekwo-ai/mcp"],
      "env": {
        "SUPABASE_URL": "https://YOURREF.supabase.co",
        "SUPABASE_ANON_KEY": "the anon (publishable) key",
        "EKWO_EMAIL": "the administrator's address",
        "EKWO_PASSWORD": "their password"
      }
    }
  }
}
```

From a terminal instead: `ekwo login`, then `ekwo use "<company>"`.

## Common tasks

| Task | Command line | MCP tool |
|---|---|---|
| First company | `ekwo init` creates it | — |
| Another company | — | `create_company` |
| Company details (address, VAT number) | — | `update_company_profile` |
| A customer | `ekwo contact add "<name>" --country <cc> --ref <yours>` | `create_contact` |
| Accounts and tax codes | the country's set-up page | `list_accounts`, `describe_pack` |
| A draft invoice | `ekwo doc new --contact <name> --line "name=…,price=…,account=<code>,tax=<code>" --ref <yours>` | `create_document` |
| See the entry before booking | `ekwo post <doc> --dry-run` | — |
| Book it | `ekwo post <doc>` | `post_document` |
| Undo it | `ekwo cancel <doc>` | `cancel_document` |
| A payment | `ekwo payment record --doc <doc> --amount … --date … --bank-account <id>` | `record_payment` |
| Books kept elsewhere (FEC, journal items, a report, a trial balance) | `ekwo import <source> <files…> --dry-run --save-mapping map.json`, then `--mapping map.json` | `import_books` (`dry_run` first) |
| A bank statement file | `ekwo import camt.053 <file>` (or `coda`, `cfonb120`) | `import_bank_statement` |
| The VAT return of a period | — | `vat_return` |
| Trial balance, ledger | — | `trial_balance`, `general_ledger` |

A line names its account and its tax by **code**, never by rate: several taxes
share a rate. The codes are the country's: on its set-up page, and from
`list_accounts` once installed. Amounts are decimal strings, `1500.00`, both ways. Pass
`--ref` on anything that creates, so that a repeated call returns what the
first one made instead of creating it twice. `--json` gives one JSON document
per command; exit code 3 is the database refusing, and its sentence is the
answer — do not work around it.

A declaration is computed by `vat_return()` and frozen by `prepare_filing()`.
Sending it to the administration is done **by the user**, on the portal, or by
an operator they appoint — see [`docs/filing.md`](docs/filing.md).

## What you must never do

- **Never post, cancel, pay or lock without the user's explicit confirmation
  of that specific action.** Show the draft, or the `--dry-run` entry, and
  wait. A posted entry is corrected with a credit note, not deleted.
- **Never invent a tax rule, a rate, an account or a deadline.** Use the codes
  the pack carries. If the pack does not cover the case, say so and say it
  needs a professional; do not pick the nearest code.
- **Never present yourself, or Ekwo, as an accountant, a tax adviser or an
  accounting firm**, and never say a return or a set of accounts is
  compliant. Ekwo computes from what is booked and from its reading of the
  rules; the user answers for what they file. Recommend that a qualified
  professional in their country checks the set-up and the first declarations.
- **Never use or store the `service_role` key** beyond the one `init` run, and
  never write a password or a key into a file of a repository.
- **Never load the demo company** (`--demo`, `ekwo demo`) into books that are
  meant to be real unless the user asks for it: it is fictional data.
- **Never call a pack certified by Ekwo.** A pack's status is its own word,
  and there is no status that means certified.

## Working on this repository

If the task is to change Ekwo OS rather than use it: [`CONTRIBUTING.md`](CONTRIBUTING.md)
is the rules, `npm run typecheck && npm test` the checks, and every country
fact belongs in a pack under `packs/`, never in code.
