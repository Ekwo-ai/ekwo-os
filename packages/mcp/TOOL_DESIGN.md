# Designing a tool of `@ekwo-ai/mcp`

A tool is read by a model before it is read by a person. The model has the
description and the input schema, nothing else, and it decides from them
whether to call, with what, and whether to ask first. These are the rules a
tool of this server follows. The ones a machine can check are checked by
[`tests/mcp/surface.test.ts`](../../tests/mcp/surface.test.ts), on every tool
a client is offered, the modules' included.

## 1. Curate: one tool per task, not one per table

A tool answers something a person does with their books — read the
statement of a contact, post a document, record a payment — and returns what
the next step needs. It is not a window onto a table: the database already
has a REST interface for that. Before adding a tool, look for the one it
should be a filter of.

## 2. A name a model can guess

- `snake_case`, at most 64 characters, starting with a letter (checked).
- A read starts with what it does: `list_`, `get_`, `search_`, `suggest_`,
  or is the name of the report it returns (`trial_balance`, `vat_return`).
- A write is a verb on its object: `create_contact`, `post_document`.
- A module's tools are `<prefix>_<verb>`, the prefix of its `module.json`
  (checked by `tests/mcp/modules.test.ts`).

## 3. A title and a description written for a model

- The `title` is a few human words; the server copies it into
  `annotations.title`, which some directories read alone (checked).
- The description says **when** to reach for the tool, **what comes back**,
  and **what it will not do** — that last part is the one a model acts on.
  It names the tool that comes next. More than 80 characters (checked).
- A refusal the tool can meet is named, with the word the database answers:
  `period_locked`, `approval_required`.

## 4. Say what it does to the books

Every tool carries its effect in its annotations, and a registration without
them does not compile (`EffectAnnotations` in
[`src/tools/effect.ts`](src/tools/effect.ts)):

| Effect | Annotations | When |
|---|---|---|
| read | `readOnlyHint: true` | Nothing changes. A report, a search, a suggestion |
| additive | `readOnlyHint: false`, `destructiveHint: false` | Something is added or changed that a person can look at, change back or leave unused: a draft, a contact, a card, a note, a setting |
| destructive | `readOnlyHint: false`, `destructiveHint: true` | It posts or cancels, replaces what was there, removes, or reaches outside the books: a machine key, a public link, a file sent |

Choose the stronger one when in doubt. A tool that may post — a schedule
with `auto_post`, say — is destructive even when it usually makes drafts.
Beside the effect, say `idempotentHint: true` when calling twice does what
calling once did, and `openWorldHint: true` when it reaches a service outside
the database. A module tool says the same with `effect`, `idempotent` and
`openWorld`.

The annotations are hints for the client. What a tool may actually do is the
database's to decide: row level security, the company's `agent_posting`, the
lock dates.

## 5. Inputs a model fills in without guessing

- Every write names its company: `company_id` is required (checked for the
  socle's writes).
- A closed list of values is a `z.enum`, never free text the tool then
  parses; its values are the database's words.
- Filters rather than pagination: a period, a status, a contact, an account
  code — so that one call returns what is needed, and a limit only caps it.
- Amounts are decimal strings (`"1210.00"`), dates ISO (`2026-06-15`),
  identifiers uuids. An account and a tax are named by code, never by rate.
- Every field is `describe`d, with what leaving it out means.

## 6. Answers and refusals

A tool answers JSON. A refusal is a tool error whose text starts with the
database's own words, followed by the sentence that says what to do next —
never a paraphrase, and never a broken connection.

## 7. On demand

With `EKWO_MCP_TOOLS=on_demand` a session starts with `CORE_TOOLS`
([`src/tools/loading.ts`](src/tools/loading.ts)) and finds the others with
`search_tools`, which reads the name, the title and the description — one
more reason to write them as above. Adding a tool to `CORE_TOOLS` is a
decision about every on-demand session: it belongs there only if a first
session with a set of books needs it.
