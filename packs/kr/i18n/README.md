# Where each language of the Korean pack comes from

The pack itself is written in Korean, which is `defaults.language`. The
account names are the ones Korean bookkeeping uses, the tax names and
declaration boxes are the wording of 별지 제21호서식 (the NTS's own VAT return
form) and of 부가가치세법 itself, and the statement lines follow the current /
non-current presentation 일반기업회계기준 requires. None of it is a
translation.

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack and
`ekwo pack check` fails if it stops doing so.

**None of it is official.** No Korean statute or the National Tax Service
publish an English wording of 별지 제21호서식 or of a chart of accounts — the
NTS's own English guidance pages summarise the law in prose, not box by box —
so every label in this file was translated for the pack. A reader comparing
an Ekwo statement or return with a filed 부가가치세 신고서 compares it with the
Korean label, which is the one with legal effect.

## Adding a language

One file, `i18n/<lang>.json`, and it is the only place that language's wording
lives. A file that `pack.json` does not declare may be partial, and a key it
does not carry falls back to the Korean label; declaring the language in the
manifest is a promise that it covers everything, and `ekwo pack check` holds
you to it.
