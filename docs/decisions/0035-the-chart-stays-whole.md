# The chart stays whole; the working list is derived

> Status: accepted

## Context

A pack transcribes the regulation, so charts run from about a hundred to over
a thousand accounts. Somebody looking for the account of a purchase invoice, or
an assistant reading the chart before every question, is handed hundreds of
rows, while an ordinary company uses a small fraction of them — and different
companies use a different fraction.

## Decision

**The chart is not narrowed; a second question is added.**
`accounts_in_use(company, from, to)` answers from what the company already
holds:

- **moved** — the account carries a line of a posted entry (inside the period,
  or ever);
- **referenced** — the configuration names it by foreign key: a role, a
  contact override, a journal, a tax posting, a cash-basis transition account,
  a bank account, a product (undated);
- **a module** — an enabled module holds it, asked through
  `<schema>.accounts_in_use(uuid)` by the convention of `can_disable()`;
- **pinned** — somebody said so;

minus `deprecated`.

**Refused alternatives.** Shipping a small core and creating accounts on
demand makes the pack a subset again; subsets by activity put a classification
of businesses into a chart. Both replace a fact with an opinion.

**`accounts.pinned` is the column an operator edits**, and
`install_country_template()` pins what it wires: roles, financial journal
accounts, tax posting accounts, transition accounts — about a dozen per
country whatever the chart's size.

**Pinning restricts nothing.** A line takes any non-deprecated account. A tool
that narrowed what may be booked would make a wrong entry by being helpful.

**Left out on purpose:** closing accounts resolved only when a year is closed;
parents of used accounts (headings would bring the hierarchy back); accounts on
draft documents (an undated draft would be in use in every period).

**`list_accounts` answers with this set and says which scope it used**;
`include_all` and `include_deprecated` widen it.

## Consequences

- The chart keeps its legal depth while the list offered to a person or an assistant stays short.
- Nothing restricts what may be booked.

## See also

- `tests/accounts_in_use.test.ts`
- [0026 Certification names a reviewer](0026-certification-names-a-reviewer.md)
