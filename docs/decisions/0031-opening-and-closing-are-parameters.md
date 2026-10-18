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
previous system exports, on the first day of the year or on the day inside it
the books were taken over, with the invoices still open as documents
([0067](0067-an-opening-on-the-day-of-the-takeover.md)).

**An ordinary close is undone by reversing.** `reopen_fiscal_year` reverses
what the close wrote and clears the flag, whatever the later years hold. The
close writes nothing in the year after, which reads this one's result from the
ledger; so a year reopened, corrected and closed again carries its new result
to the later years without an entry in them, and when nothing changed nothing
moves there. There is no opening to rewrite, and none is written. An opening
the year after carries because books were taken over on that day is that
system's figure and a person's entry, and it is left alone.

**The closed years are a run from the first one.** A close refuses a year
whose successor is closed (`later_fiscal_year_closed`), and a reopening
refuses the same, under the same name: the later year is reopened first. This
is what moving a lock date back does — it opens every year after the new
date — with one audited act per year, latest first. Reopening an earlier year
alone would leave an open year under a closed one, which no close produces.

**A final close is not undone, by anybody.** `close_fiscal_year_finally`
stamps `fiscal_years.finally_closed_at` on a closed year, after every closed
year before it. From then on `reopen_fiscal_year` refuses it
(`fiscal_year_finally_closed`), and a guard refuses every change to the year —
its flag, its dates, the stamp, its deletion — for the installer and
`service_role` as for a person, whatever setting the session raised: a setting
any session may raise is not what makes a close final. A correction is booked
in an open year. It needs `year_end.close`, like the close.

**Whether a country requires the final close, and by when, is its pack's.**
`defaults.final_close` names the rule — `before_next_fiscal_year_ends`, the
close carried out at the latest before the following year ends — and the
article behind it, into `country_defaults.final_close_due`.
`fiscal_year_final_close` reads it for one year, with the day it is due by
once the following year exists. A pack that says nothing offers the final
close and never asks for it. Neither function names a country.

**Every close and every reopening is an act of the audit trail**
([0017](0017-an-append-only-audit-trail.md)): `fiscal_year_closed`,
`fiscal_year_reopened`, `fiscal_year_finally_closed`. A piece attached to a
document of a closed year is not a change of the books
([0069](0069-a-piece-goes-on-its-document.md)).

## Consequences

- Once a year is closed, its income statement read from its own movements is
  zero, as in any post-closing trial balance; financial statements leave the
  closing entries out.
- A year closed in the ordinary way is a lock, as in the lock-date model: it
  is reopened to correct it, the later years follow by reading the ledger, and
  a result a meeting has already allocated in a later year is the user's to
  adjust there. A final close is the freeze some laws require, and the only
  state the schema never leaves.
- Three conventions are the project's reading rather than cited rules (date of
  the closing entry; passing through appropriation accounts; posting the
  appropriation separately) and are flagged for an accountant in the module
  and pack READMEs.

## See also

- `tests/closing.test.ts`
- [0032 The FEC carries its opening balances](0032-the-fec-carries-its-opening-balances.md)
- [0067 An opening on the day of the takeover](0067-an-opening-on-the-day-of-the-takeover.md)
- [0013 Locks live in the database](0013-locks-live-in-the-database-and-everything-raises.md)
- [0017 An append-only audit trail](0017-an-append-only-audit-trail.md)
- [0069 A piece goes on its document](0069-a-piece-goes-on-its-document.md)
