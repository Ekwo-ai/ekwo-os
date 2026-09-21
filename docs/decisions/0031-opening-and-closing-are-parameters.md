# Opening and closing are parameters, not code

> Status: accepted

## Context

A year-end close looks like a national variant per country. In practice every
close moves the result out of the income statement and zeroes every income and
expense account; what differs is the account the result travels through.

## Decision

**Three styles, named after the mechanism.** `country_defaults.closing_style`:

- `retained_earnings` — straight into retained earnings;
- `result_accounts` — into a current-year result account on the balance sheet,
  awaiting the meeting that allocates it (e.g. 120 / 129);
- `appropriation_accounts` — through accounts that are part of the income
  statement, then to retained earnings (e.g. 693 → 140, 793 → 141).

The values name the mechanism, never a country.

**A profit account and a loss account.** Charts that keep them apart would
otherwise need one account allowed to go debit, which their filing formats
refuse. The pack names `current_year_result_profit`,
`current_year_result_loss`, `retained_earnings`, `retained_earnings_loss` and
the `opening_journal_code`.

**None carries a default.** A default style is one country's mechanism handed
to every other. A pack that says nothing gets `no_closing_defaults` /
`no_opening_journal`; `ekwo pack check` catches the same gaps. The style is
asserted: `appropriation_accounts` requires accounts that do not carry forward,
the others accounts that do.

**The close writes no *à-nouveaux*.** Reports read the ledger cumulatively, so
a balance-sheet account already stands on 1 January at its 31 December figure;
an opening entry would count it twice, and a test forbids it. The opening
journal carries the *first* opening of a set of books (`opening_balance`) and
year-end entries. Reversing this means changing the reports first.

**`entries.kind` says what an entry is for, and only the year-end functions
set it**: `normal`, `opening`, `closing`, `appropriation`. A trigger refuses any
other value unless a transaction-local flag set by `opening_balance()`,
`close_fiscal_year()` or `reopen_fiscal_year()` is present. A reversal carries
the kind of what it undoes. The appropriation entry is posted separately,
before the closing entry, so a statutory income statement can show the
movement on its appropriation accounts.

**The allocation decided by a meeting is never in the close.** Dividends,
reserves and transfers of the result are later entries taken by people.

**An opening balance refuses the income statement** unless the caller passes
`p_allow_result_accounts` — for taking books over in the middle of a year.
It takes rows `{account_code, debit, credit, contact_id, label}`, what every
previous system exports.

**A close is undone by reversing.** `reopen_fiscal_year` reverses what the
close wrote and clears the flag, and refuses once a later year is closed or
holds entries.

## Consequences

- Once a year is closed, its income statement read from its own movements is
  zero, as in any post-closing trial balance; financial statements leave the
  closing entries out.
- Three conventions are the project's reading rather than cited rules (date of
  the closing entry; passing through appropriation accounts; posting the
  appropriation separately) and are flagged for an accountant in the module
  and pack READMEs.

## See also

- `tests/closing.test.ts`
- [0032 The FEC carries its opening balances](0032-the-fec-carries-its-opening-balances.md)
- [0013 Locks live in the database](0013-locks-live-in-the-database-and-everything-raises.md)
