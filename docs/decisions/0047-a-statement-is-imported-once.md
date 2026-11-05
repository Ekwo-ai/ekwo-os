# A bank statement is imported once

> Status: accepted

## Context

Statements overlap, get re-sent, and arrive in different formats. Importing
the same movement twice leaves the accounts with money nobody can find; merging
two genuine identical movements loses one.

## Decision

**A statement never becomes a transaction.** `import_bank_statement()` stops at
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

**The same period in two formats is recognised as a statement.** A format
replayed against itself creates nothing, line by line. Across formats, lines
are recognised only when the bank uses the same reference in both, which
CODA's standard does not promise and CFONB 120 cannot do — it gives a
movement no bank reference. So the import recognises the *statement*: the
same bank account, the same closing day, the same opening and closing
balances, from another source format, is refused by name,
`statement_already_covered`, before anything is written
(`20261101070518`). A refusal and not a quiet import of nothing new: two
statements that read the same in every figure are the same month far more
often than not, and when they are not, a person has to know why. A statement
entered by hand carries no source format and is never taken for a duplicate.

**A statement with no movement closes where it opens.** A CODA of a day
without movement has no new balance record, and the reader invents none
([0049](0049-a-statement-reader-reports-and-never-corrects.md)). The import
knows what that means: with no line, the closing balance is the opening
one, on the end of the period or the day of that balance. A statement *with*
lines and no closing balance is still refused, `statement_without_balances`.

**The source format** is read from the reader's `format` and `version`
(`coda.2`, `cfonb120`), then from `namespace`, the XML word of camt.053 the
first reader used — the word stored is the same either way.

## Consequences

- Amounts finer than two decimals and lines in another currency than their
  account are refused rather than converted.
- A numbering gap is signalled, never refused. A number that does not grow,
  on a statement of a later year than the previous one, is a numbering that
  starts again at 1 — CODA's does every January — and what is missing is
  counted within the new year.
- A CODA amount carries three decimals whatever the currency. A third decimal
  that is not zero is kept by the reader and refused by the import, which
  holds two.

## See also

- `tests/bank_statement_import.test.ts`, `tests/coda_cfonb120.test.ts`,
  `tests/bank_statement_formats.test.ts`
- [0049 A statement reader reports and never corrects](0049-a-statement-reader-reports-and-never-corrects.md)
