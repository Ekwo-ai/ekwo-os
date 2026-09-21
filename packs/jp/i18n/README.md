# Where each language of the Japanese pack comes from

The pack itself is written in Japanese, which is `defaults.language`. The
labels of the accounts are the names Japanese bookkeeping uses, the labels of
the statement lines are the items of 会社計算規則 (arts. 74 to 94), the labels
of the boxes are the wording of the 消費税及び地方消費税の申告書（一般用） and of
its schedules 付表1-3 and 付表2-3, and the legal mentions cite the article of
the 消費税法 they rest on. None of them is a translation.

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack and
`ekwo pack check` fails if it stops doing so.

**None of it is official.** The National Tax Agency publishes English guidance
on the consumption tax, but no English wording of the return, of its schedules
or of the Ordinance on Company Accounting, so every label in this file was
translated for the pack. A reader comparing an Ekwo statement with a filed
return compares it with the Japanese label, which is the one that has legal
effect.

## Adding a language

One file, `i18n/<lang>.json`, and it is the only place that language's wording
lives. A file that `pack.json` does not declare may be partial, and a key it
does not carry falls back to the Japanese label; declaring the language in the
manifest is a promise that it covers everything, and `ekwo pack check` holds
you to it.
