# A quote carries its dated facts; the deal carries the commercial status

> Status: accepted

## Context

A `sale_quote` and a `purchase_order` are documents of the socle that are
never booked: `post_document()` refuses them (`document_not_accountable`).
What happens to one is that it is sent and that the other party accepts it or
declines it. `sent_at` said the first; nothing said the second, so a company
that issued quotes could not tell an accepted quote from a draft.

The `crm` module has deals moving through the stages of a pipeline, each
stage `open`, `won` or `lost`, and a won deal makes its party a customer. A
deal and a document had no link, so a quote accepted did not win anything.

Two shapes were possible: a status column on the document, moved by whoever
records the answer, and read by the module; or facts on the document and the
status on the deal. The owner chose the second (November 2026): two distinct
objects, linked, the quote holding only what happened to it and when, the deal
holding where the business stands. The word is "deal" everywhere.

## Decision

**A quote carries dated facts, and no status column.** `documents.accepted_at`,
`declined_at` and `accepted_by` (free text), beside `sent_at`; `due_date`
stays the day a quote is valid until. Never both dates at once, and only on a
`sale_quote` or a `purchase_order` — checks of the table, so no path writes
anything else. Nothing is written to the ledger.

**The status is derived by one function.** `quote_status(document)` answers
`draft`, `sent`, `accepted`, `declined`, `expired` — neither answer and the
`due_date` past — or `cancelled`, and null for a document no answer is given
to. Every reader asks it: `quote_statuses()` for a list, `get_document` and
`list_documents` through `@ekwo-ai/core`, the `crm` module for the documents
of a deal, PostgREST as a computed field. The words a screen shows for each
value live with the words of a document, in each language file of
`@ekwo-ai/invoice-pdf`; `quoteStatusLabel()` reads them.

**One function per fact.** `accept_document()`, `decline_document()`,
`undo_document_answer()`: each refuses by name what it cannot do
(`document_not_answerable`, `document_already_answered`,
`document_not_answered`, `answer_in_the_future`, `document_cancelled`), asks
`documents.write`, and writes the act on the audit trail. The same answer
twice records it once.

**An agent answers in the mode its company chose, on the posting's rule.**
The trigger of decision [0089](0089-an-agent-posts-in-the-mode-its-company-chose.md),
`documents_posting_mode`, fires on a change of `accepted_at` or `declined_at`
as on a posting: in review, an agent's answer needs a person's approval of
the document as it stands (`approve_document()`), `approval_required`
otherwise; in autopilot it is recorded directly; every answer by an agent is
`document_answered_by_agent` on the trail. One rule, never a second path.

**The link and its consequence live in the module.** The socle knows no
module, so `crm.deal_documents` links a document to one deal at most, of the
same company, and a deal to several documents. A trigger of the module on the
socle's `documents` follows the answer of a document a deal carries,
deterministically and with no agent or approval of its own:

- accepted: the deal moves to the first `won` stage of its pipeline, through
  the body `crm.move_deal()` uses (`crm.place_deal()`), so its party becomes a
  customer;
- declined: to the first `lost` stage, only when no other answerable document
  of the deal is still alive — neither declined, expired nor cancelled;
- sent or expired: nothing moves; the open stages are each company's own, and
  the module presumes none;
- undone: a deal this answer closed, and still closed that way, opens again
  at the stage it was at before, else the last open stage of its pipeline.

A pipeline without a `won` (or `lost`) stage keeps the deal where it is; a
document no deal carries and a company without the module are left alone.
The trigger is `security definer`: whoever records the answer holds
`documents.write`, and the module's rule applies whatever else they hold; the
move is on the deal's timeline as a system activity naming the document.

## Consequences

- A database without the `crm` module has no trigger and no link: the socle's
  functions answer the same with or without it.
- An answer recorded before the quote was attached moves nothing; attaching
  does not replay it.
- The module's manifest keeps the `requires_socle_min` it was first written
  for, because every migration of a module sorts after it; the migration that
  needs `quote_status()` checks for it by name (`socle_too_old`).
- A client reads the facts and the status from schema 0.26.0
  (`SCHEMA_FEATURES.quote_answer`); below it they are absent, and the three
  calls are refused by name.

## See also

- `supabase/migrations/20261118144012_a_quote_carries_its_answer.sql`
- `modules/crm/supabase/migrations/20261118145000_crm_deal_documents.sql`
- `tests/quote_answer.test.ts`, `modules/crm/tests/deal_documents.test.ts`
- [0008 Documents and entries are two joined layers](0008-documents-and-entries-are-two-layers.md)
- [0051 A module has its own schema](0051-a-module-has-its-own-schema.md)
- [0089 An agent posts in the mode its company chose](0089-an-agent-posts-in-the-mode-its-company-chose.md)
