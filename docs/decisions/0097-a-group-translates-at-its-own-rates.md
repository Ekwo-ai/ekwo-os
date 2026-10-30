# A group translates a member's currency at the rates it sets itself, by the closing rate method

> Status: accepted

## Context

A group presents its figures in one currency, and a member may keep its books
in another. Before the figures of the companies are added up, each balance of
such a member has to be expressed in the group's currency, and three questions
follow: which method, which rates, and where the difference the rates leave
goes.

The socle has a table of dated rates, `currency_rates`. Its rows are units of
a currency for one unit of "the instance reference currency", which no column
or setting names, and the API writes nothing in it: it is reference data the
seeds would carry, and today they carry none. A document stores the rate it
used; nothing reads the table to compute a figure.

## Decision

**The closing rate method.** What a member owns and owes is translated at the
closing rate of the last day of the period; what it earned and spent over the
period at the average rate of that period; its equity at the closing rate in
force on the day it entered the group. The three do not leave the translated
balance at zero, and what remains is the **translation difference**, a line of
equity of its own for each company kept in another currency.

**The rates are the group's.** `consolidation.rates` holds, per group,
currency and period, the closing rate of its last day and the average rate of
the period, with their source. They are typed by whoever writes the group,
through `set_rate()`; the same currency and last day again replaces the row.
`translated_balances()` reads nothing else: a rate it needs and does not find
refuses the translation by name, `consolidation_rate_missing`, naming the
currency, the date and the company.

**A rate is written as the socle writes one**: units of the member's currency
for one unit of the group's, as `documents.exchange_rate` holds units of the
document currency for one of the company's. The translated amount is the
balance divided by it, rounded in the group's currency by `round_amount()`.

## Consequences

- A group that translates sets two rates per currency and year, plus the
  closing rate of the period before a member entered. A missing one is a
  sentence, not a figure at the wrong rate.
- All of a member's equity, reserves and retained earnings included, stays at
  the rate of the day it entered the group. The result of earlier years is
  translated at that rate too, and its gap with the rates of those years lands
  in the translation difference: the total is right, its split inside equity
  is the accountant's to check. Historical rates per movement of equity may
  come later.
- A member that entered or left during the period is translated for the whole
  period, as its books carry it.
- Nothing is written in a member or to the ledger; the consolidated statements
  read these lines and come next.

## Alternatives considered

- **Reading `currency_rates`.** Rejected for now: its rows are relative to a
  reference currency nothing names, the API cannot write them, and the rate
  that closes a group's year is a choice the group documents, not a quote of
  the day. A command that fills a group's rates from a published series may
  come later, and would write through `set_rate()`.
- **The temporal method** (monetary items at the closing rate, the rest at
  historical rates). Rejected as the default: it fits a member that is an
  extension of its parent, needs a historical rate for every non-monetary item,
  and is the exception in the standards rather than the rule.
- **One rate for everything.** Rejected: the result would be translated at a
  rate it was not earned at, and no difference would show where the rates
  moved.

## See also

- `modules/consolidation/supabase/migrations/20261030070000_consolidation_translation.sql`
- `modules/consolidation/tests/translation.test.ts`
- [0095](0095-a-group-is-owned-by-its-parent.md) — A group of companies is owned by its parent, and reads its members as the caller
