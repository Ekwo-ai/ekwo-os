# An operation between companies of a group is paired by their identifiers and its number, never guessed

> Status: accepted

## Context

A consolidated figure removes what the companies of a group sold to each
other: the revenue of one and the expense of the other, the receivable of one
and the payable of the other. Before anything is removed, the two sides have
to be found — the sale in the seller's books, the purchase in the buyer's —
and each company keeps its own contacts, typed by its own people. The buyer
knows the seller as a supplier among others, under whatever name it was
given.

Two questions follow: when is a contact of one company another company of the
group, and when are a sale and a purchase the same operation.

## Decision

**A contact is a company of the group when its identifiers are that
company's.** Its VAT number, or its registration number in the same country,
equal to the company's, compared as `party_identifier()` compares two numbers
— letters and digits only, upper case — the comparison `merge_contacts()` and
`suggest_duplicate_contacts()` already make. A name is never enough.
`consolidation.intragroup_parties()` lists who was recognised, and by which
number.

**A sale and a purchase are one operation when the purchase carries the
sale's number.** The buyer's `supplier_reference` is the seller's `number`,
compared the same way, between the same two companies, an invoice with an
invoice and a credit note with a credit note.

**What does not pair is listed, never forced.** `intragroup_documents()` gives
every pair, and every side without one, a status — `matched`,
`amount_differs`, `period_differs`, `purchase_missing`, `sale_missing` — for a
person to correct in the books of the company that is wrong. A document counts
when both companies are in the group on its date.

## Consequences

- A company of the group whose contact carries no VAT or registration number
  is not recognised: its operations do not appear until the number is typed.
  `intragroup_parties()` is where to look first.
- A purchase booked without the seller's number comes out as
  `sale_missing`, and its sale as `purchase_missing`: two rows, each pointing
  at a document to complete.
- Amounts are compared in the currency of each document, as booked. The
  translation of currencies comes with the consolidated figures.
- Nothing is written: the eliminations themselves, and the adjustments of the
  module's own schema, read these pairs and come next.

## Alternatives considered

- **Recognising a company by name.** Rejected: two companies may share a name,
  a contact may carry the old name of a company, and a group's figures are not
  built on a resemblance.
- **Pairing on amount and date when the number is missing.** Rejected as a
  rule of the function: two operations of the same amount in the same week are
  common between companies of a group, and a wrong pair is worse than an
  absent one. A suggestion, made to a person and confirmed by them, may come
  later.

## See also

- `modules/consolidation/supabase/migrations/20261029071412_consolidation_intragroup.sql`
- `modules/consolidation/tests/intragroup.test.ts`
- [0095](0095-a-group-is-owned-by-its-parent.md) — A group of companies is owned by its parent, and reads its members as the caller
- [0075](0075-the-contacts-that-are-probably-one-party-are-proposed.md) — The contacts that are probably one party are proposed, by the same comparison of two numbers
