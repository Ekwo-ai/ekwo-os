# Where each language's wording comes from

**Arabic** (`defaults.language`) is the pack's own language, and every account,
journal, tax, box, statement line and mention name is written in it directly
in `accounts.csv`, `pack.json`, `taxes.json`, `tax_report.json` and
`statements.json` — Arabic is the language the two texts this pack leans on
most, VAT Law No. 67 of 2016 and the Unified Tax Procedures Law No. 206 of
2020, are enacted in, and the language ETA's own portal is written in first.

**English** (`en.json`) is this pack's own translation of every one of those
labels, so that a reader of the ETA's own English translations of the two
laws — used throughout this pack's `legal_reference` fields — can follow the
chart, the taxes and the return without reading Arabic. It is not an official
Egyptian text: no official English chart of accounts, tax code list or
return exists to translate from, the same gap `packs/ae` and `packs/sa`
record for their own charts.

The `legal_reference` and `description` fields of this pack are written in
English throughout, in both languages' files alike: they are this pack's own
research notes on where a rule comes from, not a label the `i18n` mechanism
translates, and English is what lets the citations of ETA's own bilingual
publications — most of them issued in Arabic with an ETA English translation
— be checked against both.
