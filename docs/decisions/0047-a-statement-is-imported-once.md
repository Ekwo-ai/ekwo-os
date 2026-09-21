# A bank statement is imported once

> Status: accepted

## Context

Statements overlap, get re-sent, and arrive in different formats. Importing
the same movement twice leaves the ledger with money nobody can find; merging
two genuine identical movements loses one.

## Decision

**A statement never becomes an entry.** `import_bank_statement()` stops at
`bank_transactions`, state `pending`; a line becomes a payment when something
says what it pays.

**The contract is a list of keys, not a package.** The function takes `jsonb`
and its header lists the keys it reads; readers return those keys. The core
does not import a brick, and a brick does not know the core.

**Idempotence is an index.** The key of a line:

- *with a bank reference* — the reference, the position in a split batch, the
  booking date and the amount. Text and counterparty name, which a bank may
  reword between an intraday view and the final statement, are left out;
- *without one* — everything the statement says about the line plus its
  **occurrence among identical lines of the same file**, which keeps two
  identical transfers apart and is stable under replay and overlap.

Two non-overlapping files each carrying one identical, reference-less line are
taken as one; it is written down rather than guessed around. The file checksum
is kept, not used as a key.

**A statement lists lines; a line exists once.** `bank_statement_lines` lets an
overlapping statement list lines another brought, and each statement proves its
own balance over what it lists.

**The balance is recomputed in the database.** A reader's `balanced` flag is
not a check; `unbalanced_statement` is refused with the difference.

**The whole file or none of it.** **An unknown account is refused, never
created.**

**A break in the chain is a view**, computed at read, so it closes itself when
the missing statement arrives.

**`security invoker`**; the policies already test `bank.write`.

**The same period in two formats.** A format replayed against itself creates
nothing. Across formats, lines are recognised only when the bank uses the same
reference in both; otherwise the period is imported twice without warning, and
a format with no bank reference cannot be reconciled with another at line
level. Recognising a duplicate *statement* (same account, closing date and
balances, another format) is the proposed fix.

## Consequences

- Amounts finer than two decimals and entries in another currency than their
  account are refused rather than converted.
- A numbering gap check subtracts sequence numbers and warns (not refuses) when
  a format restarts its numbering each year.

## See also

- `tests/bank_statement_import.test.ts`, `tests/coda_cfonb120.test.ts`,
  `tests/bank_statement_formats.test.ts`
- [0049 A statement reader reports and never corrects](0049-a-statement-reader-reports-and-never-corrects.md)
