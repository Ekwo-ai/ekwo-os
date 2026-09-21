# Where each language of the German pack comes from

The pack itself is written in German, which is `defaults.language`. The labels
of the statement lines are the wording of §§ 266 and 275 HGB, the labels of the
boxes are the wording of form USt 1 A 2026, and the legal mentions are the
wording the UStG and the UStDV prescribe where they prescribe one. None of them
is a translation.

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack and
`ekwo pack check` fails if it stops doing so.

**None of it is official.** No German administration publishes an English
wording of the HGB schemes, of the UStG notations or of form USt 1 A, so every
label in this file was translated for the pack. A reader comparing an Ekwo
statement with a filed Jahresabschluss or Voranmeldung compares it with the
German label, which is the one that has legal effect.

## Adding a language

One file, `i18n/<lang>.json`, and it is the only place that language's wording
lives. A file that `pack.json` does not declare may be partial, and a key it
does not carry falls back to the German label; declaring the language in the
manifest is a promise that it covers everything, and `ekwo pack check` holds
you to it.
