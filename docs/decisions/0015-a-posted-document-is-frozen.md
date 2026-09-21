# A posted document is frozen

> Status: accepted

## Context

A posted invoice is the source of an entry and a document somebody received.
Without a guard, a member holding `documents.write` could change its lines,
totals, number, dates, customer or currency, unhook it from its entry, set it
back to draft (after which it would be posted twice) or mark it `cancelled`
without reversing anything — against a ledger that still says the original.

## Decision

**A closed list of what may still move; everything else is frozen by
default.** A `before` trigger compares the whole row as JSON and lets through
only the keys it names, so a column added later is frozen the day it lands.
Refused as `document_posted`, SQLSTATE `55006`. On a document that is no
longer a draft, only these move:

| column | why |
|---|---|
| `amount_paid` | only to the figure `document_amount_paid()` gives from the matching; the guard judges the value, not the path (`document_amount_paid_is_derived`) |
| `payment_state`, `amount_residual` | follow from it (`document_payment_state_is_derived`) |
| `sent_at`, `peppol_status`, `peppol_message_id` | what happened after issue |
| `updated_at` | |

Not `due_date` (BT-9 and the maturity of the receivable), not `note` (BT-22
is printed), not `reversed_document_id`, not `entry_id`. Lines keep every
column. Attachments and share links are other tables and are untouched.

**The state goes one way.** `draft` → `posted` requires a posted entry that
names this document (`entries.document_id`), booked on the document's day and
carrying its number (`document_posted_without_entry`,
`document_posted_by_hand`). `draft` → `cancelled` is an abandoned draft. Out
of `posted` there are exactly two ways, each judged on facts or on a row (see
[0016](0016-a-correction-is-one-gesture.md)).

**A line keeps the category and the rate it was posted with.**
`document_lines.vat_category` and `vat_rate` are derived and never keyed: a
draft follows its tax, including when the tax changes under it
(`taxes_reach_draft_lines`, which also refreshes the draft's totals); a posted
line keeps its snapshot. Reading through `tax_id` would read the tax of today,
and a pack upgrade rewrites a tax in place — a rate changing on 1 January would
restate every invoice of December. `document_tax_summary` (BT-118, BT-119)
groups on what the lines carry, so the breakdown and the lines never disagree.

**The totals of a posted document are not recomputed.** The totals trigger
acts on drafts.

**Nobody is exempt and nobody is born posted.** No statement of the guard
reads `is_installer()` or `is_instance_admin()`; a document inserted posted is
`document_born_posted` for everybody. `import_company()` loads posted books by
switching triggers off by name in its own transaction, and the archive wins
over the tax of the day: a line arrives frozen at the rate it was posted at.

## Consequences

- An issued invoice is corrected by a credit note naming it, posted and
  matched against it.
- The guard fires first among the `before` triggers of a line, so a posted
  line is refused by this name.
- **Known gap:** a machine key cannot write a document line at all, because
  the line trigger rounds by company and a key cannot read `companies`.

## See also

- `tests/posted_document.test.ts`, `tests/posted_archive.test.ts`,
  `tests/vat_category.test.ts`
- [0014 A posted entry is immutable](0014-a-posted-entry-is-immutable.md)
- [0050 An invoice is written from the books](0050-an-invoice-is-written-from-the-books.md)
