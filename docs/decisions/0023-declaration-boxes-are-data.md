# Declaration boxes are data, with no expression language

> Status: accepted

## Context

A VAT return that hard-codes one country's frame (its totals, the boxes that
make up what is due and what is deductible, a `fiscal_country = 'BE'`) gives
every other country no totals at all.

## Decision

**A form is two tables filled by a pack.** `tax_report_templates` is one
declaration form of one country; `tax_report_box_templates` is one box, with
`plus_boxes`, `minus_boxes` and `floor_zero` where it is a total.

**No expression language.** A list to add, a list to subtract, a floor at
zero — readable by an accountant. The one further arithmetic a form writes out
in words is a **rate of a box** (`rate` plus `rate_of`, e.g. "multiply line 12
by 0.06"): two named fields, closed vocabulary, nothing to parse. A box is a
list or a rate, never both. A country that needs a real expression starts a
discussion about the core, not a field in a pack.

**A reference names a box and a kind.** `"54"` suffices where a line carries
one figure; `"08:base"` and `"08:tax"` where a line prints both. `kind` says
how a box gets its amount — the ledger fills a `base` or a `tax`, the form
works out a `total` — so a computed line is always `kind: "total"`, whatever
the form calls it.

**Totals are evaluated by dependency, not by print order.** `evaluate_totals()`
takes every total whose parts are known, pass after pass; a pass that settles
nothing is a cycle and names the boxes (`formula_cycle`). `print_sequence` is
separate from `sequence` (optional, defaults to it), and `vat_return()`
returns the resolved value so a renderer orders by one column.

**A posting may name a list of boxes.** Some forms print one amount in boxes
no total can derive from each other (a memo box inside a box inside a box; a
service received from abroad in both an output and an input box). `box` in
`taxes.json` takes a string or a list; the amount is written to each with the
same factor. A posting per box was refused (two definitions of one taxable
amount); a junction table was refused (postings have no identity of their own
and the list is one element long almost everywhere). `declaration_boxes
text[]` sits beside `declaration_box`, which stays first
(`declaration_boxes[1] = declaration_box` by check constraint, a trigger fills
whichever a writer omitted, reading what moved). `ekwo pack check` refuses
duplicates. A `hidden` box now means only an intermediate total the form does
not print.

**Forms are not copied into a company.** A chart is customisable; a form is
not. They are reference data `vat_return()` reads directly, without
`company_id`.

**A new version of a form is a new code**, keyed `(country, code)` with its
own validity; `vat_return()` takes the form in force at the end of the
period, so a past return keeps its answer.

**`vat_return(company, from, to, report_code)`** returns box, kind, amount,
computed, name, sequence, `hidden` and `report_code`. Hidden totals are
returned and flagged. Without `report_code`, the periodic return of the
company's fiscal country in force on the last day; two candidates is an error,
not a guess. A company in a country with no pack gets its ledger boxes and no
total.

## Consequences

- `ekwo pack check` refuses a bare reference matching two kinds, a reference to
  an undeclared box or to the box itself, a tax posting to a box the form does
  not declare, and a cycle.
- Three repository-wide tests forbid a country code in any function,
  migration, or source file of the CLI, MCP server and core.

## See also

- `tests/tax_report.test.ts`, `tests/vat_return_formats.test.ts`
- [0018 Reports read the ledger](0018-reports-read-the-ledger.md)
- [0037 A filed declaration is frozen](0037-a-filed-declaration-is-frozen.md)
