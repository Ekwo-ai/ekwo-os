# A counterparty is recognised from learned patterns

> Status: accepted

## Context

The schema could record that a statement line belongs to a contact but not how
that was known, so the same decision was made again every month.

## Decision

**`contact_patterns` is that memory. The vocabulary is closed and the values
are learned.** Four kinds — an account, a spelling of a name, a word of the
description, a band of amounts; a fifth needs a migration. Nothing stored is
executed: no regular expression, no threshold beside a rule. It is the pack
invariant applied to what a user produces.

**Ambiguity replaces a stop list.** Ignoring legal-form words (`sarl`, `gmbh`,
`llc`…) would need country data. Instead `suggest_contacts()` says how many
contacts each piece of evidence reached, and evidence that reaches two
contacts is evidence of nothing — which also catches towns, trades and group
names, and adapts to the company.

**Being wrong costs something.** `confirm_contact()` charges a use without a
success to every pattern that named somebody else; a system that records only
successes never unlearns. Confidence is `(success + 1) / (usage + 2)`, so an
unused pattern is worth a half.

**The numbers are data.** Five of them in `matching_settings`, per company,
null meaning the shipped value. A tolerance is in units of the currency's
smallest denomination.

**Name comparison is by whole words.** A prefix of a few characters makes
different legal forms equal; stored words of a name also let the function set
aside contacts that share none with a line before scoring, which keeps it from
being linear in all contacts.

**Knowing who paid is not knowing what it pays.** `confirm_contact()` writes a
contact, never a matching.

## Consequences

- Recognition improves with use and forgets its mistakes.
- No country-specific word list is needed.

## See also

- `tests/contact_matching.test.ts`
- [0046 Settling applies identification and offers resemblance](0046-settling-applies-identification-and-offers-resemblance.md)
