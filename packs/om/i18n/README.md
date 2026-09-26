# Where each language's wording comes from

**Arabic** (`defaults.language`) is the language Oman's own texts are
enacted and filed in — the Value Added Tax Law, its Executive Regulations
and the Tax Authority's own portal are Arabic first, with an English
translation of the Law alone. This pack's research did not extend to
producing its own precise Arabic accounting and tax terminology across the
chart of accounts, the taxes, the return boxes and the statement lines: an
imprecise translation is worse than an honest gap, the same judgement
`docs/packs.md` asks of a status of `community`. Every account, journal,
tax, box, statement line and mention name in `accounts.csv`, `pack.json`,
`taxes.json`, `tax_report.json` and `statements.json` is therefore written
in English directly, even though `defaults.language` stays `ar` — the
language a company of this country is installed in unless it asks for
another, which is what the field means, not a claim that the labels
themselves are Arabic prose. A reviewer fluent in Omani Arabic accounting
terminology should supply the Arabic wording this pack could not verify,
the same way a future pass would replace this note once that work is done.

**English** (`en.json`) is consequently an exact mirror of the labels
already carried natively: not a translation of a second language, but the
complete coverage `tests/languages.test.ts` asks of every language a pack
declares, kept as a separate file so the mechanism is exercised and so a
later pass that does write real Arabic labels only has to change one file's
content, not the shape of two.

The `legal_reference` and `description` fields of this pack are written in
English throughout: they are this pack's own research notes on where a rule
comes from, not a label the `i18n` mechanism translates.
