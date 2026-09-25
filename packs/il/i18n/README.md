# Where each language of the Israeli pack comes from

The pack itself is written in Hebrew, which is `defaults.language`. Israel
has no statutory chart of accounts (see `pack.json`'s `charts[0]`), so the
account labels are not a transcription of an official document: they are the
terms Israeli bookkeeping ordinarily uses for the same items — לקוחות, ספקים,
מע״מ תשומות — written for this pack rather than copied from one. The tax
names, the boxes of `IL-VAT-PERIODIC` and the lines of `IL-IAS1-SFP` /
`IL-IAS1-IS` are likewise written for this pack: none of the Hebrew wording
here should be read as an official translation of a Tax Authority form or of
an IFRS text — it is ordinary Israeli usage, applied to a pack whose box
numbering and statement lines are themselves original (see the pack's
README for what each one rests on).

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack and
`ekwo pack check` fails if it stops doing so. It was translated for this pack
alongside the Hebrew, not sourced from an official English version of
anything — the law itself has no official English translation this pack's
research could verify, so every English wording here is this pack's own
rendering of the Hebrew, and the legal citations in `taxes.json`,
`tax_report.json` and `statements.json` stay in Hebrew, quoting the text
they read.

## Adding a language

One file, `i18n/<lang>.json`, and it is the only place that language's
wording lives. A file `pack.json` does not declare may be partial, and a key
it does not carry falls back to the Hebrew label; declaring a language in the
manifest is a promise that it covers everything, and `ekwo pack check` holds
you to it.
