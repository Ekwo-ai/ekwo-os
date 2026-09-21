# Locks live in the database, and everything raises

> Status: accepted

## Context

The path that bypasses the application — psql, a script, another client — is
exactly the path that needs stopping. And an error handler that logs and
returns leaves the document saved and the entry missing, cleanly and
silently.

## Decision

**Locks are triggers on `entries` and `entry_lines`.** `lock_date`,
`tax_lock_date` and a closed fiscal year are enforced in the database.
Matching is exempt: it changes no account and stays possible after a period
closes.

**`is_closed` changes only through the year-end functions.** A trigger refuses
a change of `is_closed` or `closed_at` unless `ekwo.closing_fiscal_year` is set,
transaction-locally, by `close_fiscal_year()` or `reopen_fiscal_year()`.
Creating a year that is already closed stays allowed: it describes a year kept
elsewhere and computes nothing.

**`state`, `payment_state` and `sent_at` are three questions.** One column
mixing draft, sent and paid can answer none of them.

**Everything raises; nothing warns.** Errors carry a stable prefix —
`period_locked:`, `entry_unbalanced:`, `document_total_mismatch:` — so callers
match on the code, and any client can write its own sentence in any language.
Messages are English; identifiers are English `snake_case`.

**Raise, and say what would answer.** A refusal names the missing field, flag
or role (`no_closing_defaults`, `no_party_territory`, `reversal_date_needed`)
rather than falling back on a value somebody else chose.

**A report is not a filter.** A pass over many lines (automatic settlement,
imports) catches a refusal per line, reports it against that line in the
database's own words and continues: every line in the window comes back with
an action and a reason. Silence is not a possible output.

## Consequences

- The command line maps these refusals to exit code 3 by SQLSTATE, and the MCP
  server hands the name to the model unchanged (see
  [0054](0054-the-command-line-output-contract.md),
  [0053](0053-the-mcp-server-acts-as-the-user.md)).

## See also

- `tests/locks.test.ts`
- [0014 A posted entry is immutable](0014-a-posted-entry-is-immutable.md)
- [0031 Opening and closing are parameters](0031-opening-and-closing-are-parameters.md)
