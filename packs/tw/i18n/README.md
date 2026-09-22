# Languages of the Taiwan pack

`defaults.language` is `zh` (Traditional Chinese, the language of every law and
every form this pack transcribes) and `languages` declares `en`, which
`ekwo pack check` holds to covering every account, journal, tax, box, statement
line and legal mention of the pack.

**The account names are official, and nothing else here is.** 商業會計項目表
(the Business Accounting Items Table the Department of Commerce publishes
under article 27 of the Business Accounting Act) prints a Chinese and an
English name side by side for every item — `1111 現金` is `Cash on hand`
there and nowhere else, and this pack's `i18n/en.json` transcribes that
English column rather than translating the Chinese one a second time. It is
the same reason `packs/jp/`'s own English labels for a taxonomy the National
Tax Agency itself never named in English would have been a guess: here the
guess was never needed.

**Everything else is this pack's own wording, because no administration
publishes an English version of it.** The name of a tax code, the box of form
401, a line of the balance sheet or the income statement, and the two
sentences a document carries under `documents.mentions` are this pack's
transcription of a Chinese-language statute and a Chinese-language form; the
English column of `i18n/en.json` for these is written for a reader who does
not read Chinese, and the Chinese wording in the pack's own files is the one
with legal effect. A reader comparing this pack's output with a return filed
in Taiwan compares it against the Chinese label, not the English one.

## Adding a language

One file, `i18n/<lang>.json`. `ekwo pack check` names every key a declared
language is missing; a file that is not declared in `languages` may cover
only part of the pack, and a key it does not carry falls back to the pack's
own Chinese label.
