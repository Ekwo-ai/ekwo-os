-- Ekwo OS — a client reads, and hands over a piece. It writes nothing.
--
-- Several companies inside one installation is the normal case: a firm and
-- the companies it keeps the books of. The person who runs one of those
-- companies had no preset to sit on. `viewer` reads and cannot hand anything
-- over; `accountant` hands over and can also draft an invoice, which is the
-- one thing the firm is there to do.
--
-- **What was missing was not a preset.** Filing a piece is an insert into
-- `attachments`, and the only policy that admits one tests `documents.write`
-- — the capability that also creates and changes draft documents and their
-- lines. There was no way to say "may give us the receipt" without saying
-- "may write the purchase invoice". So this migration adds one capability,
-- `documents.deposit`, and the narrowest policy that can carry it:
--
--   * INSERT only. There is no update and no delete behind it: a piece that
--     was handed over is the firm's to file, to re-point at the document it
--     becomes, or to discard, and all three are `documents.write`.
--   * On the company itself — `entity_type = 'company'`, `entity_id` the
--     company. `attachments` is polymorphic, and a capability that attached
--     to any row would let its holder pin a file of their own making on a
--     filed declaration, beside the receipt the administration sent. The
--     company row is the one thing a depositor is certain to be able to name,
--     and a file sitting on it is what an in-tray is.
--   * Signed. `uploaded_by` must be the caller, and the column now defaults
--     to it, so the firm reads who handed over what without trusting the
--     application to have said so.
--
-- **Reading back what one handed over.** `insert … returning` is checked
-- against the SELECT policies, and the one on `attachments` tests
-- `documents.read`. A client holds it; a member or a key granted
-- `documents.deposit` alone — a scanner in a hallway — does not, and would
-- have its insert refused for a row it is allowed to write. A second SELECT
-- policy lets a depositor read their own deposits. It reads no table, so it
-- cannot recurse.
--
-- **The preset.** `client` holds what `viewer` holds, read from
-- `role_capabilities` rather than listed again, plus `documents.deposit`. The
-- ledger is included on purpose: the books are the client's, the firm is the
-- guest, and a preset that hid a company's own entries from the person
-- answerable for them would be describing a different relationship. A firm
-- that wants less revokes it, per member — that is what
-- `capabilities_revoked` is for.
--
-- There is no approval in this preset because there is no act of approval in
-- the schema that is not also a write: `tax_filings.state = 'ready'` is
-- reached through `filings.write`. `docs/decisions.md` says so under this
-- date.

insert into capabilities (code, area, description) values
  ('documents.deposit', 'documents',
   'Hand a file over to the company: an attachment on the company itself, signed by whoever dropped it. Insert only — filing it, moving it and deleting it are documents.write.')
on conflict (code) do nothing;

-- Whoever may write a document may already file an attachment anywhere, so
-- the two working presets hold the narrower act as well: an interface asks
-- one question — may this person drop a file here — and gets one answer.
insert into role_capabilities (role, capability) values
  ('owner'::member_role,      'documents.deposit'),
  ('accountant'::member_role, 'documents.deposit'),
  ('client'::member_role,     'documents.deposit')
on conflict do nothing;

insert into role_capabilities (role, capability)
select 'client'::member_role, rc.capability
  from role_capabilities rc
 where rc.role = 'viewer'
on conflict do nothing;

alter table attachments alter column uploaded_by set default auth.uid();

comment on column attachments.uploaded_by is
  'Who filed it. Defaults to the caller; a deposit is refused unless it says the caller.';

create policy attachments_deposit on attachments
  for insert with check (
    has_capability(company_id, 'documents.deposit')
    and entity_type = 'company'
    and entity_id = company_id
    and uploaded_by is not distinct from auth.uid()
  );

comment on policy attachments_deposit on attachments is
  'A piece handed over: on the company itself, signed by the caller, insert only. Everything else on this table is documents.write.';

create policy attachments_select_own_deposit on attachments
  for select using (
    uploaded_by = auth.uid()
    and has_capability(company_id, 'documents.deposit')
  );

comment on policy attachments_select_own_deposit on attachments is
  'A depositor reads back what they handed over, so that `insert … returning` answers for somebody who holds documents.deposit and not documents.read.';

comment on table company_members is
  'Who may read or write a company. A role is a preset resolved through `role_capabilities`: `owner` administers, `accountant` books, `viewer` reads, `client` reads and hands pieces over.';
