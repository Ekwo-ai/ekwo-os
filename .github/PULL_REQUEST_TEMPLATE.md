<!--
Say what changes and why, in the words you would use to somebody who was not
there. A reviewer reads this before the diff.
-->

## What changes

## Why

## How it was checked

<!-- The commands you ran, and what they said. `npm test`, `npm run typecheck`,
`ekwo pack check --all` for a pack. -->

## Before asking for a review

- [ ] A change to the schema was discussed in an issue first, and it is a **new** migration: no published migration is edited.
- [ ] A new table has row level security and its grants in the same migration, and `npm run inventory` was run and committed.
- [ ] No country, currency or language is written into a function, a migration or a command. What differs by country is a row of a pack.
- [ ] A pack that moved was rebuilt with `ekwo pack build <cc>` and the generated seed is committed with it; every rate, box and statement line cites the text it comes from.
- [ ] No data of a real company, person or bank account, in a test or anywhere else.
- [ ] `CHANGELOG.md` has a line under `[Unreleased]` for anything somebody running Ekwo would notice.
