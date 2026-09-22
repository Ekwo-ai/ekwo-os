# Where each language of the United Arab Emirates pack comes from

The pack itself is written in English, which is `defaults.language`. This is
not a translation of an Arabic original: the Federal Tax Authority and the
Ministry of Finance publish the Decree-Law, the Executive Regulation, the
Ministerial Decisions and every guide this pack cites in English alongside
Arabic, both carrying legal or administrative effect, and every text this
pack's research actually opened was the English edition. `pack.json`
declares `"languages": []` for exactly this reason.

## No `ar.json` in this release

The United Arab Emirates' other official language is Arabic, and a partial
`ar.json` — labels for the chart, the taxes, the boxes of the return — would
belong here once someone has read the Arabic texts themselves and can cite
them the way every other `legal_reference` in this pack cites an English
one. This research pass did not open an Arabic-language source for any of
it: writing Arabic labels from memory, or by translating the English ones,
would be exactly the kind of unsourced claim `docs/packs.md` asks a pack not
to make, dressed up as a language file instead of a tax rate.

## Adding a language

One file, `i18n/<lang>.json`, and it is the only place that language's
wording lives. A file `pack.json` does not declare in `languages` may be
partial, and a key it does not carry falls back to the English label —
`ekwo pack check` does not hold an undeclared file to the same completeness
the manifest promises for a declared one. Whoever adds `ar.json` should read
the Arabic FTA and Ministry of Finance texts directly and cite them in
`i18n/ar.json`'s own `source` field, the way this pack's English
`legal_reference` fields cite the English ones.
