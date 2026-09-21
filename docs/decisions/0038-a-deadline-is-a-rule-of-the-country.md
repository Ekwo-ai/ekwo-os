# A deadline is a rule of the country; null is an answer

> Status: accepted

## Context

A filing deadline could be a function with a `case` on the country — the
mistake this repository exists to avoid. It changes when a country changes it
and belongs beside the form it applies to, with the article that sets it.

## Decision

**The date is pack data**, in two shapes: a fixed day of the month that
follows the period, or the last day of it, plus an optional number of days of
extension.

**The third shape is a gap, not an operator.** Where a country assigns dates
from a taxpayer's identifier or legal form, the pack says nothing and
`filing_deadline()` returns null. A null meaning *this country publishes no
rule of this shape* is worth more than a date right for one filer in ten, and
`upcoming_filings()` lists the period with no date rather than hiding it
(`reason = 'no_deadline_rule'`).

**An extension is stated where it usually applies, and the exception is
named** in the reference, because nothing in the schema records the special
scheme that would exclude it.

**No working-day shift.** Moving a date to the next working day needs a
national, sometimes regional, calendar of holidays that no pack carries; a date
on a Sunday is a visible gap rather than a silent error.

## Consequences

- A calendar can show a period with no computable date instead of hiding it.

## See also

- `tests/filing_calendar.test.ts`
- [0040 A portfolio is what the caller may read](0040-a-portfolio-is-what-the-caller-may-read.md)
