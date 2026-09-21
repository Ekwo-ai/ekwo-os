# A correction is one gesture

> Status: accepted

## Context

Once posted rows are immutable ([0014](0014-a-posted-entry-is-immutable.md),
[0015](0015-a-posted-document-is-frozen.md)), undoing must be a function, not a
sequence of statements a caller assembles.

## Decision

**`reverse_entry()`** writes the mirror of a posted entry in its journal —
every line on the other side, with its tax, its box at the opposite sign and
its analytic split — names the original, posts it through `post_entry()` and
matches the two. **`cancel_document()`** writes the credit note of a posted
invoice from its lines, names the invoice, posts it through
`post_document()`, matches the two entries and marks the invoice `cancelled`.
Both insert a draft and call the one function that posts, so numbering, locks,
capabilities and the audit trail are not read a second time.

**The date is not chosen for the caller.** The original's while its period is
open; otherwise `reversal_date_needed`. "Today" would decide which declaration
the correction falls in.

**A credit note is written from the invoice's lines, not mirrored from its
entry.** It is a document of its own; it mirrors the invoice only while the
same lines give the same figures, checked before posting
(`credit_note_differs`). The rate is the invoice's; the tax point is the
credit note's own day.

**What something else wrote is undone there.** A close, an opening, a
payment, a bank line, a module entry, a declaration's settlement, an exchange
difference or tax transfer: each is refused with the function that undoes it
named. A matched entry or a paid invoice is refused too: unmatching is a
decision about money that moved.

**The way to `cancelled` is judged on facts:** a posted credit note of the
matching type names the document, carries its total, and the document's
third-party lines are matched in full against it and nothing else; the caller
holds `documents.post`. Otherwise `document_cancelled_by_hand`.
`payment_state` derives `reversed`. The matching of the pair cannot be undone
afterwards (`document_cancelled_stays_matched`): a document that was right
after all is issued again.

**Back to draft is a country's permission, as data.**
`documents.posted_edit_policy` of the pack is `reversal_only` or
`unpost_if_untouched`, with its legal reference. A pack that says nothing is
read as `reversal_only` — the one null read as a value, because it withholds a
permission and gives the stricter answer every law accepts. Belgium and France
declare `reversal_only` (irreversibility of entries under their accounting
law); a pack moves only when somebody cites the text that allows otherwise.

**"Nothing has left" is a list, once.** `unpost_refusal()`: never sent nor on
Peppol; not settled nor credited; named by no other entry; its period open for
its booking day and every tax point; no declaration gone over those days; and,
where numbering is gapless, its number the last its journal drew.
`unpost_document()` raises what it returns.

**The number goes back to the counter.** Where it was the last drawn, the
counter steps back and the draft carries no number; posting again draws the
same one. Derived dates return to null; keyed ones stay.

**The exception is a row.** Once the entry is gone nothing on the books says
which act happened, so `unpost_document()` (definer, checking
`documents.post`) writes `document_unpostings` — a table no role may insert
into — and the guards let through exactly the transition that row names, in
its transaction. The row travels with the company's archive and is audited.

**One entry point.** `undoDocument()` in the core asks `unpost_refusal()`:
nothing against it, back to draft; anything, a credit note with that reason.
The MCP tool and `ekwo cancel` say which they did in `undone_by`; a date or
`--credit` asks for the credit note outright.

## Consequences

- There is no unpost of an entry and no free-form cancellation: every undo leaves a posted trace or a recorded row.
- A country allowing unposting must say so in its pack, with a citation.

## See also

- `tests/undo_in_one_gesture.test.ts`, `tests/unpost_document.test.ts`
- [0012 A number is drawn at posting](0012-a-number-follows-the-pattern-of-its-country.md)
