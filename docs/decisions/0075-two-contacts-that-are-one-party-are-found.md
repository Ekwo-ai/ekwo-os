# Two contacts that are probably one party are found, and a person joins them

> Status: accepted

## Context

`merge_contacts()` joins two contacts once somebody has seen that they are one
party ([0074](0074-two-contacts-of-one-company-are-merged.md)). Seeing it was
left to them. Books taken over in two passes create "Marlow Jane" and "Jane
Marlow", a supplier under its trade name and under its legal name with the
same VAT number, and nothing in the books pointed at the pair: a person had to
read the whole list of contacts to find the two rows of one debtor.

## Decision

**`suggest_contact_duplicates(company)` answers the pairs of contacts that are
probably one party, each once, strongest first, and decides nothing.** A
person chooses; `merge_contacts()` joins.

**The evidence is the evidence the books already recognise a party by**
([0045](0045-recognising-a-counterparty.md)), on the scale of
`contact_candidates()`:

| Evidence | Score | Why that score |
|---|---|---|
| The same VAT number, registration number or bank account | 1 | An identifier is carried or not; it is not a resemblance |
| The same name, letter for letter | 0.950 | What a label that is a contact's whole name earns |
| Every word of one name inside the other's, in any order | 0.900 | What the words of a contact's name inside a label earn |

The numbers are compared without their spaces and punctuation, as
`merge_contacts()` compares them. The words are the company's significant
words (`matching_settings.minimum_word_length`), so a legal form shorter than
that does not make two companies one.

**A name that only shares some of its words is not proposed.** "Harbor
Bakery" and "Harbor Freight Partners" share a word and are two parties. On a
statement line a partial name is worth a graded score, because the amount and
the date stand beside it; between two contacts nothing else does, and a list
of every pair sharing a word would hide the pairs that matter.

**A pair `merge_contacts()` would refuse is not proposed.** Two different VAT
numbers, or two different registration numbers, are two legal persons whatever
their names say (`different_identifiers`); a merged contact is retired into
another, and an inactive one is out of use. What is proposed can be merged as
it is.

**Which one to keep is proposed, not decided.** The contact more ledger lines
and documents name is proposed as the one to keep, since a merge then moves
less; on a tie, the older one. The counts are in the answer, so a person sees
why, and may keep the other: `merge_contacts()` takes the two in either order.

**One row per pair**, with its strongest evidence in a sentence and every kind
of evidence found, so a pair carrying a number and a name says both. The
function is `security invoker`: a person sees the pairs of the contacts they
can read, counted with the lines and documents they can read, and somebody
outside the company sees none.

## Consequences

- The pairs left by an import are a list to go through, not a search: the
  command line has `ekwo contact duplicates`, the MCP server
  `suggest_contact_duplicates`, and an application a one-click review over
  `merge_contacts()`.
- A pair a person decides is two parties is proposed again until one of them
  carries a number that tells them apart; recording that decision is left for
  when the review screen needs it.
- Every pair is compared with every other contact of the company, in one
  query on the stored contacts: the cost grows with the square of the number
  of contacts, which a company of thousands of contacts still answers in a
  request.

## See also

- `supabase/migrations/20261019093817_two_contacts_that_are_one_party_are_found.sql`
- `tests/contact_duplicates.test.ts`
- [0045](0045-recognising-a-counterparty.md) — A counterparty is recognised from learned patterns
- [0074](0074-two-contacts-of-one-company-are-merged.md) — Two contacts of one company are merged, and the absorbed one is retired
