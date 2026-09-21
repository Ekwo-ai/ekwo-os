# The audit file carries opening balances, never posted

> Status: accepted

## Context

The French *fichier des écritures comptables* (FEC) is a per-year file. A tax
inspector reads the *à-nouveaux* first, yet the ledger deliberately holds none
(see [0031](0031-opening-and-closing-are-parameters.md)).

## Decision

**Opening lines exist in the export and nowhere else.** The ledger stays
cumulative; the file carries them because the file is per year. Amounts come
from `trial_balance()`, the one place a cumulative balance is computed.

**A balance-sheet account is one that carries forward**, a fact of its type
(`accounts.carries_forward`); no code prefix is read.

**An unclosed year carries its result, and the export is never refused for
it.** The accumulated result goes on one more line, on the account the close
would have left it on, which `closing_style` decides (a result account under
`result_accounts`; retained earnings otherwise, never an appropriation account
inside the income statement). A pack naming no such account, or an income
account, gets `no_result_account`.

**The entries a close writes are left out of the file of the year they
close.** Kept, they would show the result twice and the income statement read
from the file would be nil. Left out, the file of a closed year is byte for
byte the file of the same year open. Two tests hold that.

**`financial_statement()` keeps appropriation entries and the audit file
leaves out both kinds**, deliberately: an appropriation section is part of a
statutory income statement; the audit file is the movements themselves.

**Only a whole financial year gets opening lines.** An extract of a quarter is
an extract of movements.

**The wording is a value of the country model.** `defaults.opening_entry_label`
(not an i18n key: the file is addressed to an administration) keeps a neutral
English fallback, because the format fixes no wording and a missing label is no
reason to hold an export back.

## Consequences

- Opening lines are one entry per year, aggregated per account, with no
  sub-ledger detail — the project's reading, flagged for an accountant.
- `@ekwo-ai/fec` writes the file; the core no longer re-exports it.

## See also

- `tests/fec.test.ts`, `packages/formats/fec/`
- [0018 Reports read the ledger](0018-reports-read-the-ledger.md)
