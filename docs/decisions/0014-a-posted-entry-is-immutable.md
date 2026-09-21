# A posted entry is immutable, in an open period too

> Status: accepted

## Context

Period locks protect a *locked* period. In an open period, a member holding
`entries.write` could otherwise delete the lines of a posted entry, delete the
entry or set it back to draft, and — because the audit trail records the act
of posting and not the lines — leave no trace. The way in matters as much: an
`update entries set state = 'posted', number = …` could choose a number by
hand in a gapless country, skip the financial year or post an empty entry.

## Decision

**Every internal path already writes the same way**: insert a draft, insert its
lines, call `post_entry()` — `post_document()`, `post_payment()`,
`post_module_entry()`, `opening_balance()`, `settle_cash_basis_tax()`,
`settle_filing()`, `close_fiscal_year()`. Where the schema undoes an entry it
writes a mirror naming the first in `reversed_entry_id`. The guard makes that
the only way for anybody.

**The way out is closed.** Once an entry has left `draft` it is not deleted,
its state does not change, no column moves but `updated_at`, and its lines
take no delete and keep every column but `matching_number` and
`matched_amount` — matching is not a change to the accounts. Refused as
`entry_posted`, SQLSTATE `55006`. Nobody is exempt, the installer included.

**Nobody is born posted.** An entry inserted already posted, or a line
inserted under one, is `entry_born_posted`. Books kept elsewhere arrive
through `import_company()`, which switches the triggers of the tables it fills
off by name inside its own transaction (see
[0043](0043-a-company-leaves-with-its-books.md)); constraints such as
`entries_posted_is_balanced` still judge what it loads.

**The way in is judged on facts, not on who writes.** A session flag cannot
say "`post_entry()` is running" (see
[0005](0005-a-guard-answers-true-or-false.md)). So the transition to `posted`
must carry everything `post_entry()` produces: a posting instant, the
financial year the date falls in (or null, see the machine-key limit), at
least one line, an open period asked the way the function asks, and — in a
gapless country, for a caller without `entries.import` — the last number the
journal's counter delivered, which the unique index makes equivalent to "just
drawn". A row that satisfies all of it *is* the row `post_entry()` writes and
is let through; otherwise `entry_posted_by_hand`.

**The totals of a posted entry are no longer recomputed** from its lines:
`entries_refresh_totals()` acts on drafts.

**The guards are `security definer`**, because a guard asked under the
caller's policies is answered "no row" by whoever cannot read.

## Consequences

- The conditions of `post_entry()` are read in two places.
  `tests/posted_by_hand.test.ts` walks each refusal of the function beside the
  same attempt by hand, from three seats (accountant, owner, key), so a
  condition added to one and not the other fails.
- The period guards keep their own question — *may anything be written at this
  date* — distinct from *may this row still change*.
- A future migration that must restate posted rows has to disable the trigger
  by name in its own file, where a reviewer reads it.

## See also

- `tests/posted_entry.test.ts`, `tests/posted_by_hand.test.ts`,
  `tests/posted_archive.test.ts`
- [0015 A posted document is frozen](0015-a-posted-document-is-frozen.md)
- [0016 A correction is one gesture](0016-a-correction-is-one-gesture.md)
