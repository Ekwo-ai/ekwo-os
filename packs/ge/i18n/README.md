# Where this pack's wording comes from

The pack itself is written in Georgian (`defaults.language`). This is not a
translation: every text it cites — the Tax Code of Georgia, the Minister of
Finance's order No. 1048 (VAT declaration form), order No. 84 (tax invoice
instruction), the Law of Georgia on Accounting, Reporting and Auditing — is
already official Georgian text.

There is no official Georgian chart of accounts to transcribe: the
Accounting, Reporting and Auditing law sets reporting *standards* (IFRS, IFRS
for SMEs, or the simplified standards a category-IV entity follows) by
category of entity, not a national list of account codes with fixed numbers.
The chart of accounts of this pack is this contributor's own transcription,
in Georgian, of the account groupings IFRS and IFRS for SMEs use — not a
translation of a statutory chart, because none exists. See the pack's own
README.md.

## Why there is an `i18n/en.json`

`i18n/en.json` is a **working translation of this pack**, made by its
contributor, and not an official English version of the Tax Code, of order
No. 1048 or of the Law on Accounting, Reporting and Auditing: none of those
texts has one. Every `legal_reference` of the whole pack stays in Georgian and
cites the Georgian article; the translation only reaches the names of the
accounts, the journals, the taxes, the boxes of the declaration, the lines of
the statements and the mention on the invoice.

## Adding a language

The format asks for one file, `i18n/<lang>.json`, and every wording of one
language lives there. A file not listed in `pack.json`'s `languages` may be
partial; one that is listed has to cover every key, and `ekwo pack check`
names what is missing.
