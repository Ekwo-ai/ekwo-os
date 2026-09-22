# Where each language of the Thai pack comes from

The pack itself is written in Thai, which is `defaults.language`. Thailand has
no legally prescribed chart of accounts (see `pack.json`'s `charts[0]`), so
the account labels are not a transcription of an official document: they are
the terms Thai bookkeeping ordinarily uses for the same items — เงินสด,
ลูกหนี้การค้า, ภาษีซื้อ — written for this pack rather than copied from one.
The tax names and the box names of `TH-VAT-30` are likewise written for this
pack: the Revenue Department's own English page on form VAT 30
(`rd-vat-guide` in `pack.json`) names the topics the form covers and not its
printed item numbers or their Thai wording, which this session could not
read (see the pack's README). None of the Thai wording here should be read as
an official translation of a Revenue Department document; it is Thai
accounting usage, applied to a pack that is itself original.

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack and
`ekwo pack check` fails if it stops doing so. It was translated for this pack
alongside the Thai, not sourced from an official English version — the
Revenue Department's own English pages (`rd.go.th/english/...`) were read for
the law and the mechanics, not copied for wording, and are cited by their own
`source` key wherever a fact rests on them.

## Adding a language

One file, `i18n/<lang>.json`, and it is the only place that language's
wording lives. A file `pack.json` does not declare may be partial, and a key
it does not carry falls back to the Thai label; declaring a language in the
manifest is a promise that it covers everything, and `ekwo pack check` holds
you to it.
