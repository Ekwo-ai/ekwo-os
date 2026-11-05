# Settling applies identification, offers resemblance

> Status: accepted

## Context

A wrong counterparty misfiles a line. A wrong settlement misstates a debt: it
marks paid an invoice nobody paid, and the accounts balance either way, so the
error stays invisible until a customer disputes it.

## Decision

**Applied: identification.** A reference the statement carries, or an amount
matching exactly one open item within the company's window and tolerance — one
piece of evidence pointing at one thing.

**Offered, never applied: resemblance.** A subset of invoices adding up to the
transaction is the usual shape of a customer paying a month at once. The
greedy oldest-first walk finds one deterministically, and cannot prove that no
other subset also fits. A wrong combination is the one mistake the accounts
cannot show afterwards.

**Never automatic: a partial payment.** Less money than is open is a deposit, a
discount, a short payment or an error — four treatments nothing in the accounts
distinguishes. The machine proposes; a person decides — and says it, with the
amount each item is settled by when the oldest-first walk is not what
happened.

**Never automatic either: what the money is net of.** A payout of a payment
provider is the invoices less the fee it kept; a payment to a supplier may
carry the charges of the bank. The difference is a charge only a person can
name — its account, and the tax it bears, which the provider's invoice says
and the statement does not. Named, it is recorded beside the settlement as an
extra line, and the statement line balances to the cent against the items and
those lines, or nothing is recorded.

**Never a settlement: an internal transfer.** Money between two accounts of the
same company is recognised by the counterparty account being the company's
own, named, and left.

**A statement line becomes a payment, not a transaction of its own.** `post_payment()` and
`reconcile()` already do the accounting; a function writing the accounts from a
statement would be a second way of recording money. The one exception is a line
with extra lines: its transaction carries the two lines `post_payment()` would write
— the bank on the same ladder, the counterparty on
`resolve_counterpart_account()` — and the extra lines beside them, a tax on one
recorded from the lines of a purchase invoice. It goes through
`post_entry()`, the payment points at it for what it settles, and the
matchings are still `reconcile()`'s. One transaction rather than a payment plus a
second transaction for the fee, because the bank line is one movement and points at
one transaction.

**A pass reports every line.** `auto_settle()` returns, for every line inside
its window, an action and a reason — including "nothing matches" and a refusal
caught per line in the database's own words. A hard-coded bound or an
exception escaping the loop would skip lines in silence.

## Consequences

- An automatic pass never marks an invoice paid on resemblance.
- A person reviews combinations and partial payments.
- `auto_settle()` records no extra line: a fee is never inferred from a
  difference.
- An extra line is in the currency of the company: a statement line carries no
  rate to record one at, and one in another currency is refused.

## See also

- `tests/statement_settlement.test.ts`
- `tests/settle_with_extra_lines.test.ts`, migration `20261014081008`
- [0047 A statement is imported once](0047-a-statement-is-imported-once.md)
