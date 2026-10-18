# A piece goes on its document

> Status: accepted

## Context

`attachments` is one polymorphic table: a file belongs to a company, a
contact, a document, an entry, a payment, a bank statement or transaction, a
fiscal year or a filing. Every reader of a piece — the screen of an invoice,
an accountant's review, an export, an audit — looks for it in one place.

A document and the entry it posted are two layers of the same fact (decision
0008): the invoice, with its supplier, lines and taxes, and the debit and
credit it produced in the ledger. The supplier's PDF, the scanned receipt, the
rendered invoice belong to the first. Until this record, nothing stopped a
caller from keeping the same file on the entry instead, or on both: a second
copy in a second place, invisible to whoever opens the document, and two
answers to "where is the receipt of this purchase?".

An import showed the risk: a year closed in the books held its purchases as
ledger entries only, and the first reflex was to hang each PDF on its entry.
The clean answer was to bring the purchases in as documents, and the files
with them.

## Decision

**An invoice, a credit note or a receipt is attached to its document.**
`attachments.entity_type = 'document'`, `entity_id` = the document. Ekwo Cloud
offers no other place for it: the invoice screen and the purchase inbox attach
to the document, and nothing else.

**An entry that a document posted refuses a file.** The trigger
`attachments_guard_document` reads `entries.document_id` (and
`documents.entry_id`) and refuses the row with
`attachment_belongs_on_document`, naming the document, so the caller knows
where to put it. It holds for every caller — a person, a machine key, the
service role — on insert and when an existing file is moved.

**An entry that no document posted keeps its own piece.** A journal entry
keyed by hand, a year-end adjustment, an opening, a ledger line imported from
another system: nothing else would hold the justification, so the entry does.

**When books are taken over, purchases and sales come in as documents.** A
history that arrives as ledger entries only gets its invoices recreated as
documents when the pieces exist, and the pieces go on those documents
([`docs/import.md`](../import.md)).

## Consequences

- One place for the piece of an invoice: the document. A screen, an export or
  an agent that wants the receipt reads `attachments` where
  `entity_type = 'document'`.
- A tool that used to attach a receipt to an entry gets an error that names the
  document to use instead.
- Files already on entries posted by a document are not touched by the
  migration; the trigger reads what is written from now on.

## See also

- `supabase/migrations/20261018102431_a_piece_goes_on_its_document.sql`
- `tests/attachment_on_document.test.ts`
- [0008](0008-documents-and-entries-are-two-layers.md) — Documents and entries are two joined layers
