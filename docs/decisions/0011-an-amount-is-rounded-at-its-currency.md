# An amount is rounded at the decimals of its currency

> Status: accepted

## Context

JavaScript's `Math.round` goes towards positive infinity, so `-0.005` becomes
`-0.00` in one implementation and `-0.01` in another, and a credit note stops
being its invoice with the sign flipped. A binary float cannot hold some
halves: `2.675 * 100` is `267.49999999999994`, so a naive half-up gives `2.67`
where the rule says `2.68`. And `round(x, 2)` everywhere is right for the euro
and wrong for the yen (no decimals) and the dinar (three): a yen invoice of
1 234,5 would be booked at 1 234,50 and settled at 1 235.

## Decision

**One rule in every language of the repository: half up on the absolute
value, at the currency's decimals.** It is what invoices, VAT returns and
annual accounts are written with, and it is symmetric by construction.

**One pair, one arithmetic, one lookup.** `money_rounding` is the pair (the
decimals of a currency, the method of a country). `round_amount(amount,
rounding)` is the arithmetic and the only place a rounding method is named; it
looks nothing up, so it is immutable and usable from a view.
`rounding_of(company, currency)` is the lookup and the only reader of
`currencies.decimal_places` and `country_defaults.rounding_method`. A test asks
the catalogue for both lists and fails on a third name.

**Nothing is guessed.** An unknown currency, company or country model is
refused by name (`unknown_currency`, `unknown_company`, `no_country_model`).
There is no fallback currency and no fallback country.

**A function rounds in as many currencies as it handles.** `post_document`,
`post_payment` and `reconcile` round each side at the decimals that side has.

**A local variable with a scale is a second rounding rule.** `numeric(16, 2)`
rounds on every assignment, silently, at two decimals. Declarations are plain
`numeric`, and a cast to `numeric(n, 2)` in a reporting function is a rounding
in disguise; only `round_amount` rounds.

**A tolerance is a fraction of the currency's unit, not of a cent.**
`currency_unit()` answers 1 for the yen and 0.01 for the euro.

**The TypeScript rule is one file in three places.** A format brick may not
import the core or another brick, so `rounding.ts` is copied into the core and
two bricks; `tests/rounding.test.ts` compares them byte for byte and
`tests/currency_rounding.test.ts` runs one shared vector (zero, halves,
negatives, three decimals, no decimals) through the SQL and the TypeScript and
asserts they agree.

**A column that nothing reads says so in its comment.** A plausible column
name with no reader is read as behaviour; `docs/schema.md` is generated from
the comments, so the reader learns which columns are promises.

## Consequences

- A whole ledger in a zero-decimal currency — a fixture pack with a fictional
  country code — goes through entry, payment, matching, return, trial balance
  and close with every figure a whole unit.
- **Known gap:** monetary columns are still `numeric(16, 2)`, so a
  three-decimal amount rounded correctly by the engine is rounded again by the
  column. Widening changes the text of every amount returned and is its own
  change; a test pins the present behaviour. Frozen declaration boxes already
  have no scale (see [0037](0037-a-filed-declaration-is-frozen.md)).
- The format bricks round half up only; the first pack to declare another
  method will have to pass it to them, and the vector test is where that shows.

## See also

- `scripts/check-rounding.mjs`, `tests/rounding.test.ts`,
  `tests/currency_rounding.test.ts`
- [0020 One tax engine, several kinds of tax](0020-one-tax-engine-several-kinds-of-tax.md)
