# For agents: a first session with Ekwo

This page is for an AI agent that keeps books with Ekwo OS for somebody, and
for the person who sets that agent up. It gives the five steps of a first
session, the same on the MCP server and on the command line, and what the
agent reads at each one. Installing comes before it, and is in
[`AGENTS.md`](../AGENTS.md) and [`start-with-claude.md`](start-with-claude.md).

Both ways in act on the same functions of the schema: a rule that holds for
one holds for the other, because there is one implementation of it, in the
database and in `@ekwo-ai/core`.

| | MCP server | Command line |
|---|---|---|
| What the agent reads first | the instructions of the handshake | `npx -y ekwo-os@latest help --json` (the field `usage`) |
| Machine-readable output | every tool answers JSON | `--json` on every command: one document on the standard output, the shape in [`packages/cli/schema/output.1.json`](../packages/cli/schema/output.1.json) |
| A refusal | the tool error starts with its name, then a sentence saying what to do | exit code 3, `error.name`, `error.message` and `error.hint` |

## The five steps

The examples run across several countries on purpose: a consultancy in Kenya
invoicing in Kenyan shillings, a studio in Japan in yen, a shop in Canada in
Canadian dollars, a firm in Germany in euros. Nothing in the steps changes from
one to the other; the codes do, and they always come from the company's own
country pack.

### 1. Find the company

| MCP | Command line |
|---|---|
| `list_companies` | `ekwo login`, then `ekwo whoami --json` |

Every other call takes a company. The answer lists the companies the signed-in
person is a member of, with the country, the currency and their role on each.
An empty list means the person has not been invited to a company yet; `status`
(or `ekwo whoami`) says who the agent is acting as. On the command line,
`ekwo use "<company>"` picks the one the next commands run on, and every
`--json` document repeats it under `context.company`.

### 2. Read its settings: financial years, lock dates, journals

| MCP | Command line |
|---|---|
| `get_company` | `ekwo company show --json` |

The financial years and whether each is closed, the lock dates, the journals,
and the accounts that play the receivable, payable and suspense roles — the
same document on both sides, from one function of `@ekwo-ai/core`. A date the
agent books on falls in an open year, after the lock date.

### 3. Learn the codes a line names

| MCP | Command line |
|---|---|
| `list_accounts`, the resource `ekwo://companies/{companyId}/taxes`, `describe_pack` | the country's set-up page, `https://ekwo.ai/countries/<cc>/set-up/` |

A document line names its account and its tax **by code**, because several
taxes share a rate. A Japanese consumption tax code, a Canadian GST/HST code
and a Kenyan VAT code each come from their pack. `describe_pack` says which
pack a code comes from, its version, and how far it has been reviewed:
`community`, `maintained`, `proven` (it reproduced the accepted filing of a
real company, for the scopes its `evidence` names, and says which were not
tested) or `reviewed`.

### 4. Make a draft, show it, post it once the person agrees

| MCP | Command line |
|---|---|
| `search_contacts`, `create_contact` if nobody matches, `create_document` | `ekwo contact list`, `ekwo contact add`, `ekwo doc new … --ref <yours>` |
| `get_document` | `ekwo post <doc> --dry-run` |
| `post_document`, after the person says yes | `ekwo post <doc>`, after the person says yes |

The draft comes back with the totals the database computed. The agent shows it
— and on the command line the entry `--dry-run` would write — and posts once
the person has agreed to that document. `--ref` on anything that creates makes
a repeated call return what the first one made. When the money moves,
`record_payment` (`ekwo payment record`) books it and matches it.

### 5. Read the return, and correct what is posted

| MCP | Command line |
|---|---|
| `vat_return`, the prompt `prepare_vat_return` | — |
| `cancel_document`, `reverse_entry` | `ekwo cancel <doc>`, `ekwo reverse <entry>` |

`vat_return` gives the boxes of a period with their names and amounts, summed
from what was posted; a draft is in no box. It prepares figures, and filing
them is done by the person, on their administration's portal or through an
operator they appoint ([`filing.md`](filing.md)). The prompt
`prepare_vat_return` walks through checking the boxes against the ledger.

A posted entry stays as it was posted, and is corrected by another one.
`cancel_document` undoes an invoice the one way its country allows — back to
draft where nothing has left, by the credit note that names it otherwise — and
says which. `reverse_entry` undoes an entry keyed by hand. A paid document is
unmatched first with `unreconcile`, when the person says so.

## When the database says no

A refusal is the answer, and it says what to do next. It starts with a name —
`period_locked`, `entry_unbalanced`, `reversal_date_needed`,
`unknown_contact`, `not_found` — followed by a sentence: book on a later date,
ask the person for a date, look the contact up with `search_contacts`, list
the companies with `list_companies`. On the command line the same sentence is
in `error.hint` of the `--json` document, and the exit code is 3 for a refusal
of the books and 2 for a call to change.

## What the agent asks the person first

Every post, cancellation, reversal, payment and lock is confirmed by the
person, for that specific action — and for posting a document, the database
holds the agent to it (below). A tax rule, a rate, an account or a deadline
always comes from the pack; where the pack does not cover the case, the agent
says so and brings in the person's accountant, who works in the same books —
or, for a person without one, the accountants who work with Ekwo at
[ekwo.ai/partners/directory](https://ekwo.ai/partners/directory/).

## Review or autopilot

Ekwo treats an agent the way a coding agent treats its permissions: a default
mode in the settings, a flag the person passes to one session to skip the
questions, and a setting that forbids that flag.

- **The setting** is the company's `agent_posting`, in its settings beside its
  profile (`ekwo company agent-posting`, `update_company_profile`, the Settings
  page of Ekwo Cloud). `review`, the default: an agent posts a document only
  once a person approved that draft as it stands (`ekwo doc approve
  <document>`), and a draft changed afterwards is approved again — otherwise
  `post_document` is refused with `approval_required`. `autopilot`: agents
  post directly, within the rights of the person they act for. `review_only`:
  as review, and no session may switch to autopilot. Only a person with
  `company.write` changes it; an agent may make it stricter when asked, never
  looser.
- **The session** is the person's choice for one session of their agent:
  `ekwo-mcp --autopilot` or `ekwo mcp --autopilot` (or
  `EKWO_AGENT_POSTING=autopilot`, or the header `X-Ekwo-Agent: autopilot`
  beside a key) posts without approvals wherever the company allows it, the
  way `--dangerously-skip-permissions` does for one session of Claude Code;
  `--review` asks for approvals even where the company is in autopilot. In a
  company that is `review_only`, a session in autopilot is refused by name,
  `autopilot_forbidden`.

Autopilot is the person's decision, for their session or their company, never
the agent's. Every posting an agent makes is on the audit trail as
`document_posted_by_agent`, with the mode, the session and the key, so what
an agent booked in autopilot can always be told apart. The MCP server says at
start-up and in `status` which mode its session runs in, and `post_document`
says it in its description. A person signed in posts as before.

## Registering the installation

Registering an installation with Ekwo is optional, and everything works the
same without it. On an installation that is not registered, three places
mention it once, with what it gives and the one command:

- the end of an `ekwo init` that asked no questions (`--yes`, `--json`);
- `ekwo status`, as a short block for a person, and as the field
  `registration` of its `--json` document;
- the MCP server's instructions, as one line the agent may relay to the person
  once, at a natural pause — and the field `registration` of the `status`
  tool.

What it gives today: a note when a security advisory concerns the version the
installation runs, release notes for new versions of the schema and the
country packs, and the country and the version counted among the
installations Ekwo serves. It sends six fields and no ledger data; they are
listed in
[`packages/cli/README.md`](../packages/cli/README.md#registering-with-ekwo).

```sh
npx -y ekwo-os@latest register --email <your address>
```

`ekwo unregister` undoes it, and `EKWO_NO_REGISTER_INVITE=1` hides the
invitation everywhere: on the command line and in an MCP server started with
it in its environment.

## An Ekwo Cloud account

Nothing here needs an account. A free one on
[Ekwo Cloud](https://cloud.ekwo.ai/signup) adds the web application on the
same books, a nightly backup of every company the person links, and the
connector `https://mcp.ekwo.ai/mcp`, approved in the browser, in place of the
address, key and password of the configuration above. The command line offers
it in one line after `ekwo init` and after a first `ekwo company export`, each
once; the MCP server started from its environment carries it once in its
instructions, for the agent to relay after a first task to a person who has no
account. `EKWO_NO_CLOUD_OFFER=1` hides it on both, and neither shows it in CI
or sends anything to Ekwo.
