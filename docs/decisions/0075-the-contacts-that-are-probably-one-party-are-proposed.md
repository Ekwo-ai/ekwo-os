# The contacts that are probably one party are proposed

> Status: accepted

## Context

`merge_contacts()` joins two contacts once somebody has said which two
([0074](0074-two-contacts-of-one-company-are-merged.md)). Books taken over in
two passes leave dozens of such pairs among thousands of contacts — "Marlow
Jane" and "Jane Marlow", "Dupont" and "Dupont Holdings", one supplier imported
with its VAT number and again with its bank account — and nobody reads two
thousand contacts side by side to find them.

The books already know how a party is recognised. A statement line and a
ledger line that name nobody are weighed by `contact_candidates()`
([0045](0045-recognising-a-counterparty.md),
[0070](0070-a-line-that-names-nobody-is-named-once.md)): the account, the
learned motifs, the significant words of a name, and a doubt when those words
reach several contacts ([0072](0072-a-line-left-unnamed-and-a-name-among-several.md)).
A second way of saying that two names agree would sooner or later disagree with
the first.

## Decision

**`suggest_duplicate_contacts(company)` proposes the pairs, and decides
nothing.** One row per probable pair of active contacts of the company,
strongest first:

| Column | Type | What it says |
|---|---|---|
| `keep_id` | `uuid` | The contact to keep: the one more ledger lines and documents name, then the older, then the smaller id |
| `absorb_id` | `uuid` | The contact to absorb into it |
| `score` | `numeric` | 0 to 1, the strongest evidence of the pair |
| `evidence` | `text` | The kinds of evidence, strongest first, comma-separated: `vat_number`, `registration_number`, `account`, `name` |
| `because` | `text` | The evidence in sentences, in the same order, separated by `; ` |

It writes nothing. `merge_contacts(keep_id, absorb_id)` is still the act, and a
person still chooses it.

**The evidence is what the books recognise a party by.**

- The same **VAT number** or the same **registration number**, compared once
  punctuation and case are set aside: 1.
- The same **bank account**, on the contact or in a learned motif
  (`counterparty_account`): 1, as `contact_candidates()` scores it.
- The same **significant words of the name** in any order, or every word of
  one name in the other: the score `contact_candidates()` gives a name — 0.950
  for the same name, 0.900 for the words of one inside the other — capped at
  0.600 when the words of the shorter name reach several contacts, since it
  cannot say which one is the twin. Two names that merely share a word are not
  a pair: thirty suppliers whose names end in one legal form are not thirty
  duplicates. The words are `significant_words()` at the company's minimum
  length, and the threshold is the company's `name_threshold`.

**One scoring path.** The score of a name and its cap move out of
`contact_candidates()` into `name_agreement()` and `name_among_several()`,
which `contact_candidates()` now calls, as `suggest_duplicate_contacts()`
does. How a bank account is compared moves into `account_key()`, and how a
VAT or registration number is compared into `party_identifier()`, which
`merge_contacts()` now reads to refuse `different_identifiers`. A pair the
merge would refuse is therefore never proposed.

**Never proposed:** a pair across two companies; an inactive or merged
contact; a contact and its own parent or branch, which are linked on purpose;
two contacts carrying different VAT or registration numbers. A merged pair
disappears at the next call, and the kept contact is proposed again with any
third contact it still resembles.

**Bounded by construction.** The pairs of a name are found through the rarest
word of each name — every word of the shorter is in the longer, its rarest one
too — never by comparing every contact with every other; identifiers are
joined on their value. The function plans its joins as hash joins whatever the
statistics say. At 2 000 contacts on PGlite it answers in about 40 ms.

**Security invoker.** It reads the contacts, motifs, lines and documents the
caller may read; a company of somebody else gives no row.

## Consequences

- A screen lists the pairs, shows the two contacts and the sentences, and
  calls `merge_contacts()` on the pair a person confirms.
- A statement line, a ledger line and a pair of contacts are weighed by one
  rule; a change to how a name scores changes all three.
- Contacts with the same name and nothing else to tell them apart are
  proposed. Many contacts sharing one exact name are many pairs; that is what
  the books say.

## See also

- `supabase/migrations/20261019104812_the_contacts_that_are_probably_one_party.sql`
- `tests/duplicate_contacts.test.ts`
- [0045](0045-recognising-a-counterparty.md) — A counterparty is recognised from learned patterns
- [0072](0072-a-line-left-unnamed-and-a-name-among-several.md) — A line may be left unnamed, and a name among several is a doubt
- [0074](0074-two-contacts-of-one-company-are-merged.md) — Two contacts of one company are merged, and the absorbed one is retired
