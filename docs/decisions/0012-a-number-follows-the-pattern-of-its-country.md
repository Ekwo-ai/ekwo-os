# A number is drawn at posting, from the country's pattern

> Status: accepted

## Context

Entry numbers must be unique, often gapless by law, and readable. A company
taking over books from another system arrives with years of numbers its
returns and its auditor already know.

## Decision

**A number is assigned at posting, not at creation.** A deleted draft leaves
no hole.

**The counter is a row of `journal_sequences`**, per journal and per period
the pattern implies, so concurrent bookings serialise on that row and not on
the journal.

**The pattern is pack data.** `country_defaults.number_format` uses a closed
grammar: `{CODE}`, `{YYYY}`, `{YY}`, `{MM}` and a `{N…}` counter padded to its
own width. `format_number()` raises on an unknown token rather than printing
it. There is no fallback literal: a pack that declares nothing gets
`no_number_format`. A pattern containing the year restarts with the year; a
pattern with none keeps one series for the life of the journal. `{MM}` prints
the month and does not restart the counter: a monthly series would be a new
behaviour no pack has asked for.

**Whether a number may skip is a separate question**, `numbering_gapless`.
`post_entry()` refuses a number chosen by hand where the country forbids a
hole.

**Importing is a capability in no preset.** `entries.import` lets an explicit
number through; an owner grants it to the person doing the import and takes it
back. Duplicates are still refused by the unique index on
`(company_id, number)`. The rule has no exemption for the installation,
because gapless numbering is a rule about the books, not a permission.

**The counter catches up.** `number_counter()` reads a counter back out of a
number through its pattern, and `catch_up_journal_sequence()` advances the
sequence, so the first entry after an import continues the series. A number in
another system's shape does not parse and leaves the counter alone.

**Undoing gives the number back only where that leaves no hole.** See
[0016](0016-a-correction-is-one-gesture.md).

## Consequences

- A company can take over its history with its original numbers, and continue the series.
- A country that wants a monthly series will need a new, declared behaviour.

## See also

- `tests/numbering.test.ts`
- [0014 A posted entry is immutable](0014-a-posted-entry-is-immutable.md)
- [0033 What a country requires on a document is data](0033-what-a-country-requires-on-a-document-is-data.md)
