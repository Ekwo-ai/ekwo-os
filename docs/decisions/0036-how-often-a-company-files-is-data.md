# Filing cadence is data, counted in months

> Status: accepted

## Context

`vat_return()` takes two dates, which is right: a return is a period. But
nothing said how often a company files, so a quarterly filer could be handed a
monthly return without a word. Cadences are set by law — sometimes one answer
for everybody, often by turnover or by option.

## Decision

**Three pieces, each where the answer lives.**
`tax_report_templates.periods` is what the form accepts (a list);
`companies.vat_period` is what this company files;
`country_defaults.vat_period_default` is what the pack proposes.

**One vocabulary, an enum:** `month`, `bimonth`, `quarter`, `four_month`,
`half_year`, `year` (`declaration_period`). A combined value such as
`month_or_quarter` is read as the two it names, so older packs keep working,
and is never a cadence of its own.

**No column default.** A pack that never considered its cadence must not
silently file on another country's; a form that names none is refused by name.

**A pack proposes a cadence only where the law gives one answer independent of
the company.** Where the cadence depends on turnover or an option, the default
is null and the pack cites the article on the form: offering one lawful answer
as the one to press Enter on is how the other ends up installed, and a wrong
cadence is a missed deadline.

**Every function that turns a cadence into dates reads
`declaration_period_months()` and `declaration_period_start()`**, anchored on
1 January — not a `case` per function, which silently files unknown cadences
as years. A cadence anchored on a fiscal year would be a new value.

**The return refuses a period only when the refusal is certain:** the company
has a cadence, the form offers it, the dates asked are a whole period of the
form's cadences, and the two differ. Anything else — a fortnight, an annual
recapitulative form — goes through, because `vat_return()` is a control query
as often as a filing, and a guard that refused analysis would be worked
around.

## Consequences

- A company with a recorded cadence cannot be handed a return for the wrong period by mistake.
- Adding a cadence is an enum value and a number of months, not a new branch in each function.

## See also

- `tests/filing_periods.test.ts`, `tests/filing_cadences.test.ts`
- [0038 A deadline is a rule of the country](0038-a-deadline-is-a-rule-of-the-country.md)
