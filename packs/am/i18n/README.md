# Where this pack's wording comes from

The pack itself is written in Armenian (`defaults.language`). Every text it
cites is official Armenian text: the Tax Code (HO-165-N), the order of the
Chairman of the State Revenue Committee No. 298-N (the unified VAT and excise
tax return), Order No. 353-N of the Minister of Finance (the chart of accounts)
and the Law on Accounting. The account names are copied from the Armenian
text of Order No. 353-N; the five accounts this pack adds are marked in the
pack's README.md and named by the contributor.

## Why there is an `i18n/en.json`

`i18n/en.json` is a **working translation of this pack**, made by its
contributor. Armenia publishes the chart of accounts and the return form in
Armenian only, and the English rendering of the Tax Code on arlis.am is a
translation rather than the authentic text. The file translates the names of
the accounts, the journals, the taxes, the boxes of the return and the lines of
the statements; every `legal_reference` stays in Armenian and cites the
Armenian article.

## Adding a language

The format asks for one file, `i18n/<lang>.json`. A file not listed in
`pack.json`'s `languages` may be partial; one that is listed has to cover every
key, and `ekwo pack check` names what is missing.
