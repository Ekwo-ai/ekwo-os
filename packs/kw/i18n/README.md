# Where each language's wording comes from

**Arabic** (`defaults.language`) is the language Kuwait's own texts are
enacted in. This pack's research did not extend to producing precise Arabic
accounting terminology across the chart of accounts, the taxes and the
statement lines: an imprecise translation is worse than an honest gap, the
same judgement the Oman pack makes. Every account, journal, tax and statement
line name in `accounts.csv`, `pack.json`, `taxes.json` and `statements.json`
is therefore written in English directly, even though `defaults.language`
stays `ar` — the language a company of this country is installed in unless it
asks for another. A reviewer fluent in Kuwaiti Arabic accounting terminology
should supply the Arabic wording.

**English** (`en.json`) is consequently an exact mirror of those labels: the
complete coverage `tests/languages.test.ts` asks of every declared language,
kept as a separate file so a later pass that writes real Arabic labels only
has to change content, not shape. There is no `tax_report_boxes` entry (no
return) and no `legal_mentions` entry (no mention).

The `legal_reference` and `description` fields are English throughout: they
are this pack's research notes, not labels the `i18n` mechanism translates.
