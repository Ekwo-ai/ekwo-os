# A company numbers its documents its own way

> Status: accepted

## Context

The number of a document was the country's: `numbering_rules()` read the
pattern of the pack, and `{CODE}` printed the code of the journal that drew
it. A company that already numbers its invoices `FAC-2026-0001` in another
system, wants six digits, or one series that does not restart each year,
could not say so. Most laws ask for a sequence that identifies the invoice
uniquely and leave its shape to the seller; the pack's pattern is a sound
default, and nothing more.

## Decision

**The company's pattern before the pack's.** `companies.number_format`, in
the grammar of `country_defaults.number_format`, is read first by
`numbering_rules()`, so every reader of the pattern follows it. It must carry
`{CODE}` (`number_format_without_code`): each journal counts on its own, and
two journals printing one pattern without themselves in it would print the
same numbers.

**A prefix per journal, the code untouched.** `journals.number_prefix` is
what `{CODE}` prints. The code stays what the pack, the imports and the
exports know the journal by. A prefix another journal of the company prints,
as its prefix or its code, is refused (`number_prefix_taken`).

**A change continues the series.** The counter is held per journal and per
year when the pattern carries the year, under year 0 when it does not. When
a change makes the pattern start or stop carrying the year, each journal's
last number is carried into the counter the new pattern reads; the years
after start at 1, with the year in the number. A change of prefix or width
keeps the same counter. No hole where the law forbids one, no number twice;
the unique index on `entries (company_id, number)` stays the last word.

**One reader of the pack.** `numbering_rules()` gains `pack_number_format`,
the pack's own pattern, so that the trigger that carries the counters and a
screen that offers the company's pattern beside the pack's read it there.

## Consequences

- Null in both columns is the pack, as before: no company changes number
  until it says so.
- The pack states no constraint on the shape of a number yet. Where a
  country prescribes one — digits only, a maximum length, a series
  registered with the authority before use — the pack will declare it and
  the company's pattern will be checked against it.
- A document that returns to draft after a change gives its number back only
  if its number is the last one the current pattern would print.

## See also

- `supabase/migrations/20261020160000_a_company_numbers_its_documents_its_own_way.sql`
- `tests/company_numbering.test.ts`
