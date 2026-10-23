# Where each language's wording comes from

**Arabic** (`defaults.language`) is the language of the Income and Sales Tax
Department's forms and tables. This pack's research did not extend to producing
its own precise Arabic accounting and tax terminology across the chart, the
taxes, the return boxes and the statement lines: an imprecise translation is
worse than an honest gap. Every name in `accounts.csv`, `pack.json`,
`taxes.json`, `tax_report.json` and `statements.json` is therefore written in
English directly, even though `defaults.language` stays `ar` — the language a
company of this country is installed in unless it asks for another. A
reviewer fluent in Jordanian accounting terminology should supply the Arabic
wording.

**English** (`en.json`) is an exact mirror of the labels already carried: not
a second language, but the complete coverage `tests/languages.test.ts` asks of
every language a pack declares.

The `legal_reference` and `description` fields are written in English
throughout: they are this pack's research notes on where a rule comes from.
