# Decisions

Why Ekwo OS is shaped the way it is: one record per decision, each with its
context, the rule it sets and what follows from it, so that a contributor can
argue with the reason rather than guess at it.

Each record is written as the rule it establishes and states what holds today.
A decision that changes is rewritten in place, and its record says what the
rule now is; the history of the change is in the git log and in
[`CHANGELOG.md`](../../CHANGELOG.md).

A record has five parts: **Status**, **Context**, **Decision**,
**Consequences** and **See also** (the files, migrations, tests and other
records it relies on). New records take the next free number.

## The instance and who may act

- [0001](0001-one-installation-is-one-customer.md) — One installation belongs to one customer
- [0002](0002-the-surface-is-closed-not-merely-empty.md) — The surface is closed, not merely empty
- [0003](0003-the-schema-grants-its-own-rights.md) — The schema grants its own rights
- [0004](0004-a-permission-is-a-capability.md) — A permission is a capability; a role is a preset
- [0005](0005-a-guard-answers-true-or-false.md) — A guard answers true or false, and reads as the schema
- [0006](0006-a-machine-key-is-a-narrow-caller.md) — A machine key is a caller narrower than a person
- [0007](0007-an-invitation-names-an-address.md) — An invitation names an address, not a user id

## The ledger

- [0008](0008-documents-and-entries-are-two-layers.md) — Documents and entries are two joined layers
- [0009](0009-accounts-have-types-and-are-resolved-by-role.md) — Accounts have types and are resolved by role
- [0010](0010-amounts-are-positive-and-totals-derived.md) — Amounts are positive; totals are derived
- [0011](0011-an-amount-is-rounded-at-its-currency.md) — An amount is rounded at the decimals of its currency
- [0012](0012-a-number-follows-the-pattern-of-its-country.md) — A number is drawn at posting, from the country's pattern
- [0013](0013-locks-live-in-the-database-and-everything-raises.md) — Locks live in the database, and everything raises
- [0014](0014-a-posted-entry-is-immutable.md) — A posted entry is immutable, in an open period too
- [0015](0015-a-posted-document-is-frozen.md) — A posted document is frozen
- [0016](0016-a-correction-is-one-gesture.md) — A correction is one gesture
- [0017](0017-an-append-only-audit-trail.md) — An append-only audit trail surrounds the ledger
- [0018](0018-reports-read-the-ledger.md) — Reports read the ledger and know no country

## Taxes

- [0019](0019-tax-postings-carry-the-account-and-the-box.md) — A tax posting carries the account and the box
- [0020](0020-one-tax-engine-several-kinds-of-tax.md) — One tax engine, several kinds of tax
- [0021](0021-cash-basis-vat-and-realised-exchange-differences.md) — Cash-basis VAT waits; exchange differences are realised
- [0022](0022-a-price-that-holds-its-tax.md) — A price that holds its tax is converted per group
- [0023](0023-declaration-boxes-are-data.md) — Declaration boxes are data, with no expression language
- [0024](0024-a-tax-follows-the-territory-of-the-parties.md) — A tax follows the territory of the parties

## Country packs

- [0025](0025-a-country-is-a-pack-of-data.md) — A country is a pack of data, compiled into SQL
- [0026](0026-certification-names-a-reviewer.md) — Ekwo maintains a pack; only an accountant reviews one
- [0027](0027-the-sources-of-a-pack-are-a-register.md) — The sources of a pack are a register, not a bibliography
- [0028](0028-a-pack-upgrade-is-never-silent.md) — A pack upgrade is never silent
- [0029](0029-a-golden-year-is-the-contract-of-a-pack.md) — A golden year is the contract of a pack
- [0030](0030-charts-and-financial-statements-are-data.md) — A country has charts, and a financial statement is data
- [0031](0031-opening-and-closing-are-parameters.md) — Opening and closing are parameters, not code
- [0032](0032-the-fec-carries-its-opening-balances.md) — The audit file carries opening balances, never posted
- [0033](0033-what-a-country-requires-on-a-document-is-data.md) — What a country requires on a document is data
- [0034](0034-a-label-is-data.md) — A label is data, and a declared language is a promise
- [0035](0035-the-chart-stays-whole.md) — The chart stays whole; the working list is derived

## Declarations

- [0036](0036-how-often-a-company-files-is-data.md) — Filing cadence is data, counted in months
- [0037](0037-a-filed-declaration-is-frozen.md) — A filed declaration is frozen and superseded, not edited
- [0038](0038-a-deadline-is-a-rule-of-the-country.md) — A deadline is a rule of the country; null is an answer
- [0039](0039-a-deposit-is-an-event.md) — A deposit is an event, written from the frozen figures
- [0040](0040-a-portfolio-is-what-the-caller-may-read.md) — A portfolio is what the caller may read

## Companies, documents and the bank

- [0041](0041-a-company-has-a-profile-and-a-first-year.md) — A company has a profile; its first year is a parameter
- [0042](0042-a-document-is-shared-by-a-link.md) — A document is shared by a link that is the whole secret
- [0043](0043-a-company-leaves-with-its-books.md) — A company leaves with its books
- [0044](0044-a-product-is-a-catalogue-entry-in-the-core.md) — A product is a catalogue entry in the core, not stock
- [0045](0045-recognising-a-counterparty.md) — A counterparty is recognised from learned patterns
- [0046](0046-settling-applies-identification-and-offers-resemblance.md) — Settling applies identification, offers resemblance
- [0047](0047-a-statement-is-imported-once.md) — A bank statement is imported once

## Formats and modules

- [0048](0048-format-libraries-are-mit-one-package-per-format.md) — Format libraries are MIT, one package per format
- [0049](0049-a-statement-reader-reports-and-never-corrects.md) — A statement reader reports and never corrects
- [0050](0050-an-invoice-is-written-from-the-books.md) — An invoice file is written from the books
- [0051](0051-a-module-has-its-own-schema.md) — A module has its own schema and posts through a function

## Installer, command line and MCP server

- [0052](0052-the-installer-needs-only-node-and-a-customer-project.md) — The installer needs only Node and the customer's project
- [0053](0053-the-mcp-server-acts-as-the-user.md) — The MCP server acts as the user
- [0054](0054-the-command-line-output-contract.md) — The command line answers one document and an exit code
- [0055](0055-the-command-line-acts-as-a-signed-in-person.md) — The command line acts as a signed-in person
- [0056](0056-the-command-line-computes-no-amount.md) — The command line computes no amount
- [0057](0057-two-install-paths-one-installation.md) — Two install paths make one installation
- [0058](0058-doctor-compares-against-a-generated-inventory.md) — `ekwo doctor` compares against a generated inventory
- [0059](0059-releases-and-schema-versions.md) — A release has a tag, a schema version and a schema floor

## Load and licensing

- [0060](0060-the-plan-is-the-assertion-the-clock-is-a-report.md) — Under load, the plan is the assertion, not the clock
- [0061](0061-licensing-and-the-open-core-line.md) — AGPL core, MIT formats, an operational paid line
- [0062](0062-a-key-reaches-the-api.md) — A machine key reaches the API, and is on its own company
