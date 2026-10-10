# Where each language's wording comes from

**Arabic** (`defaults.language`) is the language Qatar's own laws are enacted
and filed in — the Income Tax Law, the Excise Tax Law and the General Tax
Authority's Dhareeba portal are Arabic first, with English texts published
beside them. This pack's research did not extend to producing its own precise
Arabic accounting terminology across the chart of accounts, the taxes and the
statement lines: an imprecise translation is worse than an honest gap, the
same judgement `docs/packs.md` asks of a status of `community`. Every account,
journal, tax and statement line name in `accounts.csv`, `pack.json`,
`taxes.json` and `statements.json` is therefore written in English directly,
even though `defaults.language` stays `ar` — the language a company of this
country is installed in unless it asks for another, which is what the field
means, not a claim that the labels themselves are Arabic prose. A reviewer
fluent in Qatari Arabic accounting terminology should supply the Arabic
wording this pack could not verify.

**English** (`en.json`) is consequently an exact mirror of the labels already
carried natively: not a translation of a second language, but the complete
coverage `tests/languages.test.ts` asks of every language a pack declares,
kept as a separate file so a later pass that writes real Arabic labels only
has to change the content of one file, not the shape of two.

The `legal_reference` and `description` fields of this pack are written in
English throughout: they are this pack's research notes on where a rule comes
from, not labels the `i18n` mechanism translates.
