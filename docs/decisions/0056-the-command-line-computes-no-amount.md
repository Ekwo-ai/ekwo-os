# The command line computes no amount

> Status: accepted

## Context

The command line writes contacts, drafts and lines, posts, records payments,
matches and lists what is owed — the same acts the MCP server performs. Two
implementations would book the same invoice differently the day one is fixed.

## Decision

**The functions moved to the core; they were not written again.** Column
lists, amount formatting and the functions for contacts, documents, posting,
payments and matching live in `packages/core/src/books`, which imports nothing
from outside the repository. The CLI's `Backend` is its PostgREST client.

**Three kinds of "no".** The database refusing is 3; the CLI's own checks are
2; the shared layer's refusals (`unknown_account_code`, `document_not_draft`,
`nothing_open`, `not_found`) are 2, since the call must change. `not_found`
cannot distinguish a hidden row from a missing one and does not pretend to.

**No amount is computed on this side, and a test holds the means away.**
`tests/cli/no-rules.test.ts` refuses `Number(`, `parseFloat`, `toFixed`,
`Math.` and arithmetic on anything named an amount, a price or a total, and
refuses a command that queries a table or calls a schema function directly.

**`--ref` is a column, not a lookup.** `client_ref` on `contacts`, `documents`
and `payments`, unique per company where given, trimmed and not blank. A replay
returns the row with `replayed: true` and *finishes* what a dropped connection
left (a draft without lines gets them; an unbooked payment is booked; matching
runs again on what is still open). It does not compare contents.

**`--dry-run` is the database rehearsing.** `rehearse_post_document()` calls
`post_document()` in a block and leaves it by its own exception, so the
subtransaction rolls back and the answer survives. Any description of what
posting would do would be a second implementation of posting.

**No short line syntax.** A string like `"Audit 1 500 EUR@21"` parses several
ways and turns a rate into a choice of tax. `--line` takes named fields by
code; `--stdin` takes JSON with the MCP tool's field names, refusing unknown
fields.

**`payment record --doc` reads the ledger** (`open_items()`) for direction and
counterparty, not a table of document types in TypeScript. `match` names the
document's open items and chooses nothing.

**Two defaults, said aloud:** `invoice new` is a `sale_invoice` dated today on
the running machine unless told otherwise; the answer says so. Neither is a
country, currency or language.

## Consequences

- A creation is still two requests; `--ref` makes the cut recoverable. One
  transaction would need a `create_document(jsonb)`.
- Numbers returned by functions over PostgREST are JSON numbers and are
  rendered back to two decimals, which misprints a three-decimal currency.

## See also

- `tests/cli/`, `tests/rehearsal_and_client_ref.test.ts`
- [0053 The MCP server acts as the user](0053-the-mcp-server-acts-as-the-user.md)
