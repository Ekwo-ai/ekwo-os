# Settling applies identification, offers resemblance

> Status: accepted

## Context

A wrong counterparty misfiles a line. A wrong settlement misstates a debt: it
marks paid an invoice nobody paid, and the books balance either way, so the
error stays invisible until a customer disputes it.

## Decision

**Applied: identification.** A reference the statement carries, or an amount
matching exactly one open item within the company's window and tolerance — one
piece of evidence pointing at one thing.

**Offered, never applied: resemblance.** A subset of invoices adding up to the
transaction is the usual shape of a customer paying a month at once. The
greedy oldest-first walk finds one deterministically, and cannot prove that no
other subset also fits. A wrong combination is the one mistake the ledger
cannot show afterwards.

**Never automatic: a partial payment.** Less money than is open is a deposit, a
discount, a short payment or an error — four treatments nothing in the books
distinguishes. The machine proposes; a person decides.

**Never a settlement: an internal transfer.** Money between two accounts of the
same company is recognised by the counterparty account being the company's
own, named, and left.

**A statement line becomes a payment, not an entry.** `post_payment()` and
`reconcile()` already do the accounting; a function writing the ledger from a
statement would be a second way of booking money.

**A pass reports every line.** `auto_settle()` returns, for every line inside
its window, an action and a reason — including "nothing matches" and a refusal
caught per line in the database's own words. A hard-coded bound or an
exception escaping the loop would skip lines in silence.

## Consequences

- An automatic pass never marks an invoice paid on resemblance.
- A person reviews combinations and partial payments.

## See also

- `tests/statement_settlement.test.ts`
- [0047 A statement is imported once](0047-a-statement-is-imported-once.md)
