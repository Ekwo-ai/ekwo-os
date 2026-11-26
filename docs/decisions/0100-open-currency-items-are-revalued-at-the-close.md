# What is still open in a foreign currency is revalued at the close, and reversed the next day

> Status: accepted

## Context

A document or a payment in a foreign currency is booked in the company's
currency at its own rate, with the amount in the foreign currency beside it,
and a matching realises the exchange difference ([0021](0021-cash-basis-vat-and-realised-exchange-differences.md)).
Until the item is settled nothing moves it: a receivable of 1 000 USD booked
at 900 still stands at 900 on the balance sheet of a year that closes with
the dollar at 1,25 per unit of the company's currency. Every framework in
scope states the monetary items in a foreign currency at the closing rate.
Where the difference goes is the country's: the French plan and the SYSCOHADA
defer it to a translation-difference account on the balance sheet, IFRS and
most charts put it in the result.

## Decision

**The close revalues, before it works out the result.** `close_fiscal_year()`
calls `revalue_currency_positions()` first, so the result includes the
difference wherever the pack puts it. The revaluation is an ordinary entry of
the miscellaneous journal on the last day of the year — it belongs to the
period's figures, unlike the closing entry. `currency_revaluation(company,
day)` says what it would book and writes nothing.

**What is revalued** is every posted line in a currency other than the
company's, with its amount in that currency, dated on or before the last day:
on a receivable or payable account, for the part no matching *whose two lines
are dated on or before that day* had settled — a matching made later of a
payment received later leaves the item open on the day; on the ledger account
of a bank account kept in that currency, whole. Summed by account,
counterparty and currency. A line in the company's currency is not a position
in another one, whatever account it is on.

**The rate is an input, of that day.** `closing_rates` holds, per company,
currency and day, the units of the currency for one unit of the company's —
the convention of `documents.exchange_rate`. The close reads the row of the
last day exactly; a currency still open without one refuses the close,
`fx_closing_rate_missing`. `currency_rates` is not read, for the reasons
[0097](0097-a-group-translates-at-its-own-rates.md) gives.

**The accounts are roles of the pack, never a default.** A receivable or
payable is revalued against `defaults.roles.fx_unrealised_gain` and
`fx_unrealised_loss` (`country_defaults.fx_unrealised_gain_code`,
`fx_unrealised_loss_code`), gains and losses on their own lines because a
chart that defers them keeps them on opposite sides of the balance sheet. A
bank account is revalued against `fx_gain` and `fx_loss`, the accounts a
matching already uses: money held in a currency is stated at the closing rate
and its difference is part of the result in every chart in scope. A role the
year's difference needs and the pack does not name refuses by name
(`no_fx_revaluation_accounts`, `no_fx_accounts`). A company with nothing open
in a foreign currency, or whose rate moves nothing, needs neither the roles
nor an entry, and closes as before.

**Reversed on the next day, by the gesture that reverses.** The mirror is
posted with `reverse_entry()` on the first day after the year, which matches
each receivable or payable line with its mirror, so neither stands as an open
item. A matching in the new year then realises the difference from the rate
the item was booked at, as 0021 computes it, and nothing is counted twice; the
next close revalues from the same historical rates. `currency_revaluations`
records the pair; `reopen_fiscal_year()` posts the mirror of each and matches
the two new entries together, and the next close starts again.

## Consequences

- Closing a year that holds foreign-currency items asks for one rate per open
  currency, recorded beforehand, and for `reconcile.write` beside
  `year_end.close`, which every preset that closes already holds.
- The packs that carry translation-difference accounts in their official
  chart name them: France (476, 477) and the seventeen OHADA members (478, 479).
  Every other pack refuses a revaluation that moves something until it names
  its accounts; its README is where a missing pair is said.
- A provision for an unrealised loss, where a chart requires one besides the
  deferral, is not computed: it is the accountant's entry.
- Revaluation between two closes — a monthly one, for a management account —
  is not done; `closing_rates` is per day so that it can come without a new
  table.

## See also

- `supabase/migrations/20261126143200_open_currency_items_are_revalued_at_the_close.sql`
- `tests/closing_currency_revaluation.test.ts`
- [0021](0021-cash-basis-vat-and-realised-exchange-differences.md) — Cash-basis VAT waits; exchange differences are realised
