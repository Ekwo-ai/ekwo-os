# A document sent from a phone is a draft purchase

> Status: accepted

## Context

A receipt is photographed where it is handed over, on a phone, and read later,
at a desk. The purchase inbox of Ekwo Cloud read a dropped file in the
browser and wrote nothing before *Post*: a phone had nowhere to put a page
for later, and nothing in the books said a document was waiting.

The books already have a place for each half of it. A purchase is a row of
`documents`; its pages are rows of `attachments` on that document (decision
0069); a creation repeated after a dropped connection is found again by
`documents.client_ref`, the idempotency key of a creation. What they did not have is a document
whose supplier nobody knows yet: `documents.contact_id` was required from the
first draft, and nothing has read the page when the phone sends it.

Nor did the socle say where the files of a company are stored, or who may
write there: the private Storage bucket `attachments` was a convention of the
web application, created by hand or not at all.

## Decision

**One call announces a document sent from a phone.**
`receive_purchase_document(company, reference, taken_at, files)` writes one
draft `purchase_invoice` — `client_ref` the phone's reference, dated the day
it was taken in the caller's time zone when they set one, in the company's
currency, with no line and so no amount — and one `attachments` row per page
on it, in the order sent. It is security invoker and asks `documents.write`
first (`not_allowed`, 42501): the rights of a draft, for a person or a machine
key alike.

**A draft may wait for its contact; nothing after it does.**
`documents.contact_id` is nullable on a draft only
(`documents_contact_unless_draft`), and a document that leaves draft without
one is refused by name (`document_without_contact`) before any other rule of
posting speaks. A draft without a contact is, by construction, a document a
phone sent and nobody has read: that is how an inbox finds them.

**The paths are checked, not trusted.** Each page is a file under
`<company>/inbox/<reference>/`, an image or a PDF, and — where the
installation has Supabase Storage — an object of the bucket. Each refusal has
its name: `inbox_path_outside`, `inbox_file_type`, `inbox_file_missing`,
`inbox_no_files`, `inbox_reference_invalid`, `inbox_reference_taken`.

**Twice is once.** A second call with the same reference returns the same
document and adds only the pages it does not hold, by path.

**The socle keeps the bucket.** Where Supabase Storage is present the
migration creates the private bucket `attachments` and three permissive
policies on `storage.objects`: the first folder of a path is the company; a
person reads there with `documents.read` or `filings.read`, writes and removes
with `documents.write` or `filings.write` — the capabilities of the rows that
name those files. A policy an operator wrote by hand stays beside them.

## Consequences

- A phone uploads with the person's own session and calls one function; no
  byte passes through Ekwo Cloud.
- Whoever reads the inbox — Ekwo Cloud's *Purchases*, an agent — finds the
  drafts with no contact, reads their pages, names the supplier, writes the
  lines and posts: the draft becomes the ordinary purchase, with its pages.
- A reader of `documents` meets a null `contact_id` on such a draft, and only
  there.
- An installation older than this file answers `PGRST202` for the function;
  the phone keeps the document and says the company cannot receive it yet.

## See also

- `supabase/migrations/20261028152338_a_purchase_arrives_from_the_phone.sql`
- `tests/receive_purchase_document.test.ts`
- [0069](0069-a-piece-goes-on-its-document.md) — A piece goes on its document
