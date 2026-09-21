# A product is a catalogue entry in the core, not stock

> Status: accepted

## Context

Every invoice line answers four questions — what is it called, what does it
cost, which account, which tax — and a catalogue is where those answers are
written once.

## Decision

**Products are in the core.** In a module, `document_lines.product_id` would
either not exist or point at a table the core does not ship.

**It is a catalogue, not stock.** No quantity on hand, valuation or movements:
stock has its own correctness problems, and next to the ledger a wrong movement
becomes a wrong entry.

**A product pre-fills a line and never constrains it.** The line keeps its own
text, price, unit, account and tax; what the caller gave wins. A renamed
product cannot alter last month's invoice. `product_id` on a posted line is a
reference to where it came from; `on delete restrict` and `active = false`
protect it.

**`product_id` is nullable, always.** Free text is how most invoices are
written; a catalogue of inventions is worse than none.

**The unit stays on `document_lines.unit_code` (BT-130).** The check on
`products.unit_code` is on shape only (three upper-case characters): UN/ECE
recommendation 20 has some eighteen hundred codes, and a short list in the
database would refuse valid ones. The short list lives in `@ekwo-ai/core` as
what a client *proposes*.

**BT-155 is `products.code` and lives nowhere else.** A line with no product
has none, which is correct since BT-155 is optional. `document_line_items`
puts BT-153, BT-154 and BT-155 side by side for invoice writers.

## Consequences

- An invoice never depends on the current state of the catalogue.

## See also

- [`mapping.md`](../mapping.md)
- [0009 Accounts are resolved by role](0009-accounts-have-types-and-are-resolved-by-role.md)
