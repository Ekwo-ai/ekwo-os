# Where each language of the Danish pack comes from

The pack itself is written in Danish, which is `defaults.language`. Danish is
the language momsloven, momsbekendtgørelsen and årsregnskabsloven are enacted
in, so the labels in `accounts.csv`, `taxes.json`, `tax_report.json`,
`statements.json` and the legal mentions of `pack.json` are the statutory
wording and not a translation of anything.

## `en.json`

English is declared in `pack.json`, so it covers every label of the pack and
`ekwo pack check` fails if it stops doing so.

`tax_report_boxes` follows the wording Skattestyrelsen itself gives on its
English pages where it gives one — the office keeps the box identifiers
themselves in the Latin letters they already are, `Rubrik A`, `Rubrik B`,
`Rubrik C`.

Everything else here is translated for this pack and has no official
standing:

- **The chart of accounts.** Denmark prescribes none — bogføringslovens § 6
  asks only for a written description of the bookkeeping procedures — so no
  administration publishes English names for a chart that does not exist in
  the first place. The account names, the journals and the chart's own name
  are this pack's translation.
- **The statement lines.** Årsregnskabsloven's bilag 2 has no official
  English rendering; the labels here read close to how an English-language
  annual report for a Danish company is usually worded, and a reviewer is
  free to disagree with a specific word.
- **The tax names and the invoice sentences.** Momsloven has an English
  translation on some private sites, none of them official; the wording here
  is this pack's own, close to the statute's own words.

## Adding a language

One file, `i18n/<lang>.json`, and it is the only place that language's
wording lives. A file that `pack.json` does not declare may be partial, and a
key it does not carry falls back to the Danish label; declaring the language
in the manifest is a promise that it covers everything, and `ekwo pack check`
holds you to it.
