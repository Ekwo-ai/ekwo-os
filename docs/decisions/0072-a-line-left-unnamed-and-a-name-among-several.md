# A line may be left unnamed, and a name among several is a doubt

> Status: accepted

## Context

`suggest_line_contacts()` proposes a contact for every open receivable or
payable line that names nobody
([0070](0070-a-line-that-names-nobody-is-named-once.md)). Two things show on
real books.

Some of those lines have nobody worth creating as a contact: a cash
difference, a one-off refund to somebody who will never be a customer again.
Every pass of the screen proposes them again, and the list never empties.

And the name evidence scores each contact as if it were alone. A payable line
labelled "Remb Pedro Microsoft/Cleverbridge" is a debt to Pedro, who paid a
software licence for the company; the label carries three names, and the one
that scored highest was the supplier of the licence, not the person owed.

## Decision

**Leaving a line unnamed is a decision, and it is recorded.**
`leave_line_unnamed(line, reason)` writes the line and the reason, with who
decided it, in `lines_left_unnamed`; `undo_leave_line_unnamed(line)` removes
it. Both ask `reconcile.write`, which is what naming a line asks, and the
trail records both acts. Only a posted, open receivable or payable line that
names nobody is left this way. `suggest_line_contacts()` no longer proposes
such a line. Nothing of the line moves: it stays an open item, it can be
matched, and `set_line_contact()` can still name it, which makes the record
moot.

**A name among several names none of them for sure.** When the words of a
line reach more than one contact by name, the name evidence of each is capped
at 0.600 and its sentence says how many contacts the text reached;
`alternatives` already counts them. A label that is a contact's whole name
keeps 0.950: it names that contact and nothing else. The account, a learned
motif and the number of a document are not touched, so a document quoted in
the text stays first. The cap lives in `contact_candidates()`, the one scoring
path, so a statement line carrying several names is answered the same way.

## Consequences

- The list of lines to name can be emptied, and what was left out says why.
- A person reading three candidates at 0.600 sees a question, not an answer,
  and a learned motif — confirmed once, 0.667 — outranks them the next time.
- A line with a single contact's name in it scores as before.

## See also

- `supabase/migrations/20261018210500_a_line_is_left_unnamed_and_a_crowded_name_is_doubted.sql`
- `tests/line_unnamed.test.ts`
- [0045](0045-recognising-a-counterparty.md) — A counterparty is recognised from learned patterns
- [0070](0070-a-line-that-names-nobody-is-named-once.md) — A third-party line that names nobody is named once
- [0071](0071-several-lines-settle-together-and-a-difference-is-booked.md) — Several lines settle together, and a small difference is booked
