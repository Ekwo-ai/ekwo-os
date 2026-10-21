# Where each language of the Cambodian pack comes from

The pack itself is written in Khmer, which is `defaults.language`. Cambodia's
Law on Accounting and Auditing requires accounts, but no chart of accounts
could be read from an open source (see `pack.json`'s `charts[0]`), so the
account labels are not a transcription of an official document: they are the
terms Khmer bookkeeping ordinarily uses for the same items, written for this
pack. The tax names and the box names of `KH-VAT` are likewise the pack's
own; the terms for the value added tax itself (អាករលើតម្លៃបន្ថែម), input credit
(ឥណទានអាករលើធាតុចូល) and output tax (អាករលើធាតុចេញ) are those of
Sub-Decree 49 (2024). **None of the Khmer wording has been read by a native
accountant, and none of it should be taken as an official translation.**

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack and
`ekwo pack check` fails if it stops doing so. It was written for this pack
alongside the Khmer; the General Department of Taxation publishes no English
version of the texts the pack rests on.

## Adding a language

One file, `i18n/<lang>.json`, and it is the only place that language's wording
lives. A file `pack.json` does not declare may be partial, and a key it does
not carry falls back to the Khmer label.
