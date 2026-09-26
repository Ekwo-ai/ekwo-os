# Where each language comes from

The pack itself is written in Macedonian (`defaults.language`). This is not a
translation of anything: every text it cites — the Law on Value Added Tax,
the ДДВ-04 form and its instructions, the Regulation on the Chart of Accounts
— is already official in Macedonian, and Macedonian is the language the
prescribed chart of accounts and the VAT return are published in.

## Why `i18n/en.json` exists

`i18n/en.json` is a **working translation of this pack**, made by its own
contributor, not an official English version of the Law on Value Added Tax,
of the Regulation on the Chart of Accounts or of the ДДВ-04 form: none of
these texts has one. Every `legal_reference` of the whole pack stays in
Macedonian and cites the Macedonian article; the translation touches only the
names of accounts, journals, taxes, boxes of the return, lines of the
statements and the wording on an invoice.

## Adding a language

The format takes one file, `i18n/<lang>.json`, and every wording of one
language lives there. A file not listed in `languages` of `pack.json` may be
partial; one that is listed has to cover every key, and `ekwo pack check`
names what is missing.
