# A label is data, and a declared language is a promise

> Status: accepted

## Context

A schema can be bilingual in shape — `name_i18n` beside `name` — and
monolingual in fact. A company keeping its books in one of its country's
languages should get the chart, the journals, the taxes and the return in that
language.

## Decision

**Identifiers are English, permanently; labels are data.** Tables, columns,
enum values, functions and error codes are English `snake_case`, part of the
interface programs test against. Error messages are English, prefixed by a
stable code, so a client writes its own sentence. Everything a person reads
because a country said so is a row.

**Every labelled table carries a translation column** — accounts, charts,
journals, taxes, boxes, statement lines, mentions, asset categories, and the
country's own name.

**A declared language must be complete; an undeclared one may be partial.**
`languages` in the manifest is a promise, and `ekwo pack check` fails naming
what is missing. A half-translated pack leaves nobody able to tell an
incomplete program from a different rule. An undeclared file falls back key by
key, so contributions can land before they are finished.

**A translation lives in one file per language**, `i18n/<lang>.json`,
reviewable by somebody who reads that language and nothing else.

**Where a country publishes the wording, the pack uses it** and cites it.
Where an official translation does not exist, the pack says whose wording it
uses. Where neither exists, the key is left absent: an absent key is visibly
untranslated; a guessed one is wrong and looks right.

**The check lists structural errors before translation errors**, so one
structural mistake does not bury itself under dozens of consequences.

**`ekwo init` asks for the language**, from `country_defaults.languages`, with
nothing preselected; `--language` is required non-interactively when there is
a choice.

**One resolution function.** `label_for(name, name_i18n, languages)` is the
only spelling of the fallback, and `preferred_languages(company)` builds the
chain: the user, the company, the pack. A chart is copied in the company's
language, not the installer's. The MCP server hands a client the chain and the
material; which label to print is the renderer's question.

## Consequences

- A pack can be contributed in a language before the translation is complete, without claiming it.
- A missing label is visible; a wrong one is never invented.

## See also

- `tests/languages.test.ts`, `tests/document_language.test.ts`
- [`languages.md`](../languages.md)
