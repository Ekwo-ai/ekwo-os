# A third-party line that names nobody is named once

> Status: accepted

## Context

A recorded transaction does not move ([0014](0014-a-posted-entry-is-immutable.md)):
its lines keep every column but the two the matching writes. That includes
`contact_id`, and most of the time it should — the counterparty of an invoice
is part of what was recorded.

Accounts brought in from another system break the assumption that every line on
a receivable or a payable account names somebody. An account detail exported
line by line, an opening of the payables as one amount, a salary recorded by
hand: the line is on the customer or supplier account and names no contact,
and its label is all that says who it is — "Invoice 25010013 - Acme", "Salary
04". Matching reads the counterparty to settle the items of one party
([0046](0046-settling-applies-identification-and-offers-resemblance.md)), the
aged balance reads it to say who owes what, and a line that names nobody is
answered by neither. With the column frozen, nobody can say who it is, and
the only correction left — reversing and recording again — rewrites a transaction
to add a fact the transaction never contradicted.

## Decision

**The contact of an open third-party line that names nobody may be named
once, from nothing to a contact, through `set_line_contact()`.** The line is
on an account whose type the pack gives as receivable or payable — the type,
never a code —, its transaction is recorded, nothing of it is matched yet, and its
contact is null. A line that names somebody keeps them: changing a
counterparty that was recorded is a correction, and a correction is a reversal.
A matched line keeps what it was matched as. A draft needs no function: its
lines are the caller's until it is recorded.

**Nothing else of a recorded line moves.** The guard of recorded lines
(`entry_lines_guard_posted`) lets exactly `contact_id` through, from null to a
value, on exactly the line the function named, under a setting local to the
transaction, and for a caller who holds `reconcile.write` — the pattern every
controlled exemption of this schema follows, because any session may raise a
setting. Every other column is refused as before, and so is a second naming.

**The act is in the trail.** The guard that lets it through writes it,
`line_contact_named`, with the line, the contact and who did it — the line
itself has no trail of its own, since the trail holds
the recording of a transaction and not its lines.

**A suggestion comes from the evidence statement lines already use.**
`suggest_line_contacts()` answers, line by line, with candidates scored by the
function `suggest_contacts()` reads ([0045](0045-recognising-a-counterparty.md)):
a learned or declared motif, the words of a contact's name, and one piece of
evidence an account line carries and a statement line rarely does — the number of
a document of the company, of its own side, in the label, the description or
the reference of the transaction. Each candidate says why and how many contacts the
same evidence reached. Nothing is named without somebody choosing.

**Naming teaches the same memory a statement line does.** `set_line_contact()`
learns through the code `confirm_contact()` learns through: the label as
written becomes a motif of the contact, and every motif that had pointed at
somebody else pays a use without a success.

## Consequences

- Imported open items can be attributed in place, and matching and the aged
  balance read them like any other line.
- Naming does not touch an amount, an account, a tax box or a period: it is
  allowed in a locked period, as a matching is.
- A wrong naming is not edited. The transaction is reversed and recorded again,
  as for any recorded line.
- `open_items()` can be asked for the receivable and payable lines alone, so
  a matching screen does not receive the bank's own lines.

## See also

- `supabase/migrations/20261018180416_a_line_that_names_nobody_is_named_once.sql`
- `tests/line_contact.test.ts`
- [0014](0014-a-posted-entry-is-immutable.md) — A recorded transaction is immutable
- [0045](0045-recognising-a-counterparty.md) — A counterparty is recognised from learned patterns
- [0046](0046-settling-applies-identification-and-offers-resemblance.md) — Settling applies identification, offers resemblance
