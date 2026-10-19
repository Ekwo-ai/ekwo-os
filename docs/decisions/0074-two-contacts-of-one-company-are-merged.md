# Two contacts of one company are merged, and the absorbed one is retired

> Status: accepted

## Context

Books taken over in two passes — a ledger exported line by line, then the
documents, or two exports of two systems — create the same party twice under
two spellings: "Marlow Jane" and "Jane Marlow". Each contact then carries
half of one history. The aged balance shows two rows for one debtor, a payment
booked against one cannot be matched with an invoice of the other
(`reconcile_contact_mismatch`, a matching settles the items of one party), and
what the books learned about the party is split between them.

Nothing could join them. A posted line keeps its contact
([0014](0014-a-posted-entry-is-immutable.md)), so does an issued document
([0015](0015-a-posted-document-is-frozen.md)), and `set_line_contact()` names
a line once, from nobody to somebody
([0070](0070-a-line-that-names-nobody-is-named-once.md)) — never from one
contact to another. Reversing every entry to book it again under the right
name rewrites a ledger that was never wrong about anything but a spelling.

## Decision

**`merge_contacts(keep, absorb)` moves every reference of the absorbed contact
onto the kept one, in one transaction, and retires the absorbed contact.** It
is not deleted: it stays, inactive, with `merged_into` naming the contact that
took its history. The trail, an archive taken before the merge and the
caller's own reference (`client_ref`) still find it, and it says where its
history went.

**What moves is read from the catalogue, not from a list.** Every foreign key
to `contacts`, in the socle and in the modules: the ledger lines, posted ones
included; the documents, issued ones included; the statement lines; the
payments; the contacts whose parent it was; the rows of a module, such as a
disposal of an asset. A table added later is moved without a line here. Two
references are not foreign keys and are moved by name: the files attached to
the contact (`attachments`, `entity_type = 'contact'`), and the learned motifs
(`contact_patterns`) — folded rather than copied: a motif both contacts had
becomes one, with its counters added and its confidence derived from them
again; the others move.

**The guards of what was posted let exactly this through.** One exemption in
the guard of a posted line and one in the guard of an issued document:
`contact_id` alone, from the absorbed contact to the kept one, in the
transaction in which `merge_contacts()` recorded that merge in
`contact_merges`. It is the transaction-local exemption of
`set_line_contact()`, held to a row rather than to a setting: any session may
raise a setting, so a member allowed to merge could have raised one by hand
and moved a single posted line of their choosing; nobody but `merge_contacts()`
writes a merge, as nobody but `unpost_document()` writes an unposting. No
amount, account, date, tax box or number moves. Each line and document let
through is written to the trail where it is let through
(`line_contact_merged`, `document_contact_merged`), and the merge itself once,
with what it moved and what it filled (`contacts_merged`).

**`contact_merges` is the record of the act**: which contact was absorbed into
which, by whom, when, what moved table by table and which fields were filled.
One row per absorbed contact, read by whoever reads the contacts, written by
`merge_contacts()` alone, and carried by a company that leaves.

**It asks `contacts.write` and `reconcile.write`.** The first is the record of
the party. The second is who an item belongs to: naming the counterparty of a
posted line already asks it, and a merge restates the counterparty of matched
and open items alike. It does not ask `entries.write` or `documents.post`,
because it writes no entry and issues nothing. The function is `security
definer`, so that a policy the caller does not meet — on the statement lines,
on the payments — cannot leave part of the history behind without a word: a
merge is whole or refused.

**A matching stays the matching of one party.** Both sides of every matching
end on the kept contact, or on one commercial entity with it. Where the
absorbed contact was matched against its parent's items and the kept contact
has no parent, the kept contact takes that parent; where it has another, the
merge is refused (`matching_across_parties`) rather than leave a matching
across two parties.

**The kept contact is completed, never overwritten.** A field it leaves empty
is taken from the absorbed contact: the VAT and registration numbers, the
auxiliary code (moved, since it is unique), the email and the phone, the
language and the currency, the receivable and payable accounts, the notes, the
parent. Fields that mean something only together are taken together or not at
all: the postal address, the bank account and its BIC, the electronic address.
A customer merged with a supplier becomes `both`; a contact of type `other`
takes the type of the one it absorbs.

**Refused by name:** `unknown_contact` — either is not a contact the caller
can read, or the two are of different companies; `same_contact`;
`already_merged` — either side was merged before: the history is merged into
the contact that holds it;
`different_identifiers` — the two carry different VAT numbers, or different
registration numbers: two legal persons, and a declaration reads the number;
`matching_across_parties`; and `not_allowed`.

**An absorbed contact is not used again.** A trigger on every table that
references `contacts` refuses a row that names a merged contact
(`contact_merged`, with the name of the one to use instead); a module calls
the same function on its own schema. A merged contact cannot be made active
again and is not deleted. Its `merged_into` changes only to follow the contact
it names when that one is merged in its turn, so that it always names a
contact in use.

**What does not move, and why:**

- **The trail, and the record of earlier merges.** They say what was true when
  they were written; the rows they name still exist.
- **The absorbed contact's own record.** Its name, numbers and address stay as
  they were — the record of what was imported — and its reference stays with
  it.
- **What left the company.** A filing frozen by `prepare_filing()` keeps its
  figures, an electronic invoice issued keeps its bytes, a document shared by
  a link keeps its link.
- **Lines left unnamed.** They name nobody, and a merge has nothing to move
  on them.

There is no unmerge: the trail lists every line and document that moved, and
two contacts that should not have been merged are a correction an accountant
makes with that list.

## Consequences

- One party has one contact again: one row in the aged balance, every open
  item of both histories in one list, and the matching across the two spellings
  is possible.
- The kept contact is recognised by everything either was recognised by.
- An invoice issued to the absorbed contact and printed again from the books
  names the kept contact; the file that was sent is the record of what was
  sent.
- A call naming the absorbed contact — by a reference kept in another system,
  say — is refused with the name to use, instead of writing on a contact
  nobody looks at.

## See also

- `supabase/migrations/20261019090000_two_contacts_of_one_company_are_merged.sql`
- `tests/merge_contacts.test.ts`
- [0014](0014-a-posted-entry-is-immutable.md) — A posted entry is immutable, in an open period too
- [0015](0015-a-posted-document-is-frozen.md) — A posted document is frozen
- [0045](0045-recognising-a-counterparty.md) — A counterparty is recognised from learned patterns
- [0070](0070-a-line-that-names-nobody-is-named-once.md) — A third-party line that names nobody is named once
