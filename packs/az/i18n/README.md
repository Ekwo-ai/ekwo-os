# Where this pack's wording comes from

The pack itself is written in Azerbaijani (`defaults.language`). This is a
choice, not a translation: the Tax Code, the State Tax Service's return form,
its booklets and the chart of accounts are official Azerbaijani texts, and
every `legal_reference` of the pack cites them in Azerbaijani.

## Why there is an `i18n/en.json`

`i18n/en.json` is a **working translation** by the pack's contributor for
English-speaking readers. It is not an official English version of the Tax
Code, of the return form or of the chart of accounts: none of them was found in
English. It covers the names of the accounts, the journals, the taxes, the
boxes of the return and the lines of the statements. The wording of the chart
follows the Azerbaijani list line by line; the five sub-accounts the pack adds
(2411, 2412, 2413, 5211, 5212) are the pack's own English wording.

## Adding a language

One file, `i18n/<lang>.json`, covering every key the manifest's `languages`
list requires. `ekwo pack check` names what is missing.
