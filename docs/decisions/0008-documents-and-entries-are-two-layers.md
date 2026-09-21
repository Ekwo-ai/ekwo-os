# Documents and entries are two joined layers

> Status: accepted

## Context

An invoice answers to EN 16931 and Peppol; an entry answers to the chart of
accounts and to the audit file. A single table for both gives a shorter
schema and a display-type discriminator on every ledger line.

## Decision

**Two layers.** `documents` and their lines on one side, `entries` and
`entry_lines` on the other, joined by `documents.entry_id` — a real foreign
key, never a string join such as `reference = 'INVOICE-' || number`.
Unified accounting APIs designed from scratch keep the two apart as well.

**Sales invoices, purchase invoices, credit notes and quotes are one table
with a `doc_type`.** Matching, attachments, bank reconciliation and Peppol are
otherwise written once per table.

**Document lines are a table, not JSON.** EN 16931 requires a VAT category per
line, Peppol validation checks it, the audit file wants the detail, and JSON
is neither indexable, aggregatable nor constrainable.

**`company_id` is repeated on child tables and kept honest by a composite
foreign key.** `entry_lines(entry_id, company_id)` references
`entries(id, company_id)`, so the denormalisation cannot drift, and row level
security needs no join to the parent on the largest tables.

**`entry_date`, `state` and `journal_id` are not copied onto entry lines.**
Reports join. If that ever hurts, the answer is an index or a materialised
view, not a second source of truth for three facts.

## Consequences

- Matching, attachments and e-invoicing are written once, for one document table.
- Reports pay a join to the entry header; that is the accepted cost.

## See also

- [0010 Amounts are positive and totals are derived](0010-amounts-are-positive-and-totals-derived.md)
- [0015 A posted document is frozen](0015-a-posted-document-is-frozen.md)
- [`schema.md`](../schema.md), [`mapping.md`](../mapping.md)
