# The MCP server acts as the user

> Status: accepted

## Context

An assistant connected to the books must see exactly what its user may see,
and must not become a second place where accounting rules are decided.

## Decision

**It acts as the user, never as `service_role`.** It signs in with the
operator's address and password or takes their access token; row level
security decides the rest. A service key plus a `company_id` argument would
answer for companies the user was never invited to. The key is refused at
startup in every shape the platform has issued.

**The direct-Postgres mode demands the user it acts for.** `EKWO_DB_URL`
requires `EKWO_ACT_AS_USER_ID`, and every query runs in a transaction that sets
`request.jwt.claims` and switches to `authenticated`. Otherwise the fallback
would silently be the privileged mode.

**Every ledger write goes through a function of the schema** — `post_document`,
`post_payment`, `post_entry`, `reconcile`, `unreconcile`. Direct inserts are
limited to what a person types: contacts, draft documents and lines, payments,
bank transactions.

**No tool edits a posted entry.** Corrections are reversals and credit notes
([0016](0016-a-correction-is-one-gesture.md)).

**Amounts cross as decimal strings in both directions** (`amount::text`,
`date::text`); where a function result crosses PostgREST as JSON, it is
rendered back in one place.

**Refusals are answers.** `period_locked:` and its kind travel to the model
with the database's message plus one sentence of meaning. Paraphrasing or
retrying around them would turn a company's rule into an obstacle.

**One query language for two backends.** Tool handlers use five operations —
select, insert, update, delete, call — implemented over PostgREST (through the
platform's client library, for the password grant and query string no local
test can exercise) and over parameterised SQL.

**It refuses an older database.** Each package declares a `schema_min`; the
server checks `ekwo_schema_version()` before offering a tool, because an
assistant improvising around a missing column improvises an entry.

**The shared bookkeeping layer lives in the core.** The functions between a
tool and the database (codes to ids, product pre-fill, two-step creations)
are in `packages/core/src/books`, shared with the CLI; the server keeps its
input schemas, descriptions, `explain()` and its backends.

## Consequences

- An assistant cannot see or do more than its user.
- Accounting rules live in the schema, not in the server.

## See also

- [`packages/mcp/README.md`](../../packages/mcp/README.md)
- [0056 The command line computes no amount](0056-the-command-line-computes-no-amount.md)
