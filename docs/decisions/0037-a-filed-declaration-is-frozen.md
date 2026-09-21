# A filed declaration is frozen and superseded, not edited

> Status: accepted

## Context

Everything else in the schema is derived on demand. A filed declaration has
left the building: the administration holds a set of figures, and the ledger
will differ the moment anything is posted into the period.

## Decision

### The freeze

**The figures are kept, not recomputed.** A copy that exists because the
original went elsewhere is the record of what was claimed, not a duplicate.

**Box by box, in rows** (`tax_filing_boxes`), keyed on box **and kind**,
because some forms print a base and a tax on one line. A JSON snapshot would
make the filed figures the only numbers nobody can query.

**A nil return is a return.** What is checked is that the figures were
computed (`prepared_at`), not that there are any.

**Frozen by a trigger**, not by convention.

**A frozen box is at the unit of its form.** `tax_filing_boxes.amount` is an
unscaled `numeric`; `tax_report_templates.rounding_unit` (a power of ten) is
read by `filing_rounding()` only, applied by `prepare_filing()`,
`supersede_filing()` and `filing_drift()`. `vat_return()` keeps answering
exact figures. Each box is rounded from its own exact figure.

### Settlement

**The accounts are roles of the pack** (`tax_payable`, `tax_receivable`),
refused by name when missing. They must be distinct from the accounts the taxes
post to, or settling would net a period against itself; where a national chart
keeps a claim on the State among assets and a debt among liabilities, the pack
adds two reconcilable sub-accounts named after what they hold.

**It settles the ledger, not the boxes.** The lines cleared are those the
return read; the debt is what they sum to. `filing_drift()` says how far the
boxes and the ledger differ; no account absorbs the difference.

**A credit has two outcomes and no default.** Carried forward or claimed back
is the company's choice, which `settle_filing()` requires and records.

**The administration is a third party**, whose contact account must be the one
the pack names; this is checked when the entry is written.

**No rounding of the debt** unless a pack declares a rule.

### After filing

**An entry in a declared period is ordinary, and it is signalled.**
`filings_touched_since()` lists declarations whose period moved after they
went, entry by entry — an entry is "about" a declaration when a line names a
box, the same test the tax lock uses.

**The lock is its own function and comes last.** Locking at filing would lock
the declaration's own settlement out of its period; the order is file, hear
back, settle, then `lock_filed_period()`, which refuses while tax accounts
remain to clear.

**A corrective never overwrites.** The filing that went becomes `superseded`
and the new one points at it; it settles only the difference
(`filing_tax_movements()` nets earlier settlements). What a country does with a
correction — replacement, adjustment, threshold — is pack data not yet
modelled.

## Consequences

- The database can always say which figures were sent, and how far the ledger has moved since.
- Late entries are allowed and visible; corrections supersede, never overwrite.

## See also

- `tests/tax_filings.test.ts`, `tests/filing_settlement.test.ts`,
  `tests/filing_corrective.test.ts`
- [0039 A deposit is an event](0039-a-deposit-is-an-event.md)
- [`filing.md`](../filing.md)
