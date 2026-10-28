-- Ekwo OS — a purchase document sent from a phone arrives as a draft purchase
-- (decision 0091).
--
-- A phone photographs a receipt or an invoice and sends it to the purchase
-- inbox of a company. The pages go to the installation's private Storage
-- bucket `attachments`, with the person's own session, under
-- `<company_id>/inbox/<reference>/`; then one call announces them:
--
--   receive_purchase_document(company, reference, taken_at, files)
--
-- which writes what the books already have a place for. **One draft
-- purchase** in `documents` — `purchase_invoice`, `client_ref` the reference
-- the phone gave it, dated the day it was taken, in the company's currency,
-- with no line and so no amount — and **one `attachments` row per page** on
-- that document, in the order the phone sent them. No new table. Whoever
-- reads the inbox finds the draft, reads its pages and turns it into the
-- purchase the person posts.
--
-- **The supplier is not known yet.** Nothing has read the pages when the
-- phone sends them, so the draft names no contact: `documents.contact_id`
-- becomes nullable **on a draft only**. A document that leaves draft names its
-- contact — `documents_need_a_contact()` refuses it by name before the check
-- `documents_contact_unless_draft` would, so `post_document()` and everything
-- after it still meet a document with a contact, as they always have. A draft
-- without a contact is, by construction, a document a phone sent and nobody
-- has read yet: that is how the inbox finds them.
--
-- **The rights are the socle's own.** The function is security invoker: the
-- draft and its pages are written under the row level security of
-- `documents` and `attachments`, and the caller is asked `documents.write`
-- first, refused `42501` by name — the capability every draft is written
-- with, for a person or a machine key alike.
--
-- **The paths are checked, not trusted.** Every `storage_path` is under
-- `<company_id>/inbox/<reference>/`, names a file rather than a folder, and
-- carries no `..`; every type is an image or a PDF; where the installation
-- has Supabase Storage, every path is an object of the bucket. Each refusal
-- has its name.
--
-- **Twice is once.** The reference is the idempotency key the socle already
-- has, `documents.client_ref`, unique per company: a second call with the
-- same reference returns the same document and adds only the pages it does
-- not hold yet, by path. A reference another kind of document already
-- carries is refused, never reused.
--
-- **Storage.** No migration of the socle created the bucket a company's files
-- are kept in, nor said who may write there. Where the installation has
-- Supabase Storage, this file creates the private bucket `attachments` when it
-- is missing and adds three policies on `storage.objects`, permissive like
-- any other, beside whatever an operator wrote by hand: the first folder of a
-- path is the company, and a person reads there with `documents.read` or
-- `filings.read`, writes and removes there with `documents.write` or
-- `filings.write` — the capabilities of the `attachments` rows that name
-- those files. That covers the inbox of the phone and the
-- `<company_id>/document/…` the web application already writes. A database
-- without Storage, or a role that may not alter it, skips this part with a
-- notice; `ekwo doctor` does not depend on it.

-- ---------------------------------------------------------------------------
-- 1. A draft may wait for its contact
-- ---------------------------------------------------------------------------

alter table documents alter column contact_id drop not null;

alter table documents drop constraint if exists documents_contact_unless_draft;
alter table documents add constraint documents_contact_unless_draft
  check (state = 'draft' or contact_id is not null);

comment on column documents.contact_id is
  'The customer of a sale, the supplier of a purchase. Null only on a draft nobody has read yet — a purchase document sent from a phone (receive_purchase_document()) — and named before the document leaves draft (documents_need_a_contact()).';

create or replace function documents_need_a_contact()
returns trigger
language plpgsql
set search_path = ekwo, pg_temp
as $$
begin
  if new.state <> 'draft' and new.contact_id is null then
    raise exception 'document_without_contact: % names no contact yet. Name its supplier or its customer on the draft, then post it.',
      coalesce(new.supplier_reference, new.client_ref, new.id::text)
      using errcode = '23514';
  end if;
  return new;
end;
$$;

comment on function documents_need_a_contact() is
  'Refuses document_without_contact for a document that leaves draft, or is written in another state, without a contact. A draft may wait for its contact; nothing after it does.';

revoke execute on function documents_need_a_contact() from public, anon, authenticated, service_role;

-- Named to fire before the other row triggers of documents, which run in
-- the order of their names: the missing contact is the first thing said.
drop trigger if exists documents_contact_named on documents;
create trigger documents_contact_named
  before insert or update of state, contact_id on documents
  for each row execute function documents_need_a_contact();

-- ---------------------------------------------------------------------------
-- 2. receive_purchase_document()
-- ---------------------------------------------------------------------------

create or replace function receive_purchase_document(
  p_company_id uuid,
  p_reference  text,
  p_taken_at   timestamptz,
  p_files      jsonb
)
returns uuid
language plpgsql
security invoker
set search_path = ekwo, pg_temp
as $$
declare
  v_folder   text;
  v_document documents;
  v_currency char(3);
  v_zone     text;
  v_file     record;
  v_path     text;
  v_type     text;
  v_name     text;
  v_size     bigint;
  v_found    boolean;
begin
  if p_company_id is null or not may_know_of_company(p_company_id) then
    raise exception 'unknown_company: %', p_company_id using errcode = 'no_data_found';
  end if;
  if not has_capability(p_company_id, 'documents.write') then
    raise exception 'not_allowed: adding a purchase to this company needs documents.write'
      using errcode = '42501';
  end if;

  if p_reference is null or p_reference <> btrim(p_reference) or length(p_reference) not between 1 and 200
     or p_reference ~ '[/\\]' or p_reference in ('.', '..') then
    raise exception 'inbox_reference_invalid: the reference of a document sent to the inbox is one to 200 characters, without a slash or surrounding spaces'
      using errcode = '22023';
  end if;
  if p_files is null or jsonb_typeof(p_files) <> 'array' or jsonb_array_length(p_files) = 0 then
    raise exception 'inbox_no_files: a document sent to the inbox carries at least one page, as a JSON array of {storage_path, file_name, mime_type, byte_size}'
      using errcode = '22023';
  end if;

  -- Every page is checked before anything is written.
  v_folder := p_company_id::text || '/inbox/' || p_reference || '/';
  for v_file in select value as page, ordinality as n from jsonb_array_elements(p_files) with ordinality loop
    if jsonb_typeof(v_file.page) <> 'object' then
      raise exception 'inbox_no_files: page % is not a JSON object', v_file.n using errcode = '22023';
    end if;
    v_path := v_file.page ->> 'storage_path';
    if v_path is null or left(v_path, length(v_folder)) <> v_folder or length(v_path) = length(v_folder)
       or right(v_path, 1) = '/' or v_path like '%/../%' or v_path like '%/./%' or v_path ~ '//' then
      raise exception 'inbox_path_outside: page % is stored at %, which is not a file under %', v_file.n, coalesce(v_path, 'no path'), v_folder
        using errcode = '22023';
    end if;
    v_type := lower(coalesce(v_file.page ->> 'mime_type', ''));
    if v_type !~ '^image/[a-z0-9][a-z0-9.+-]*$' and v_type <> 'application/pdf' then
      raise exception 'inbox_file_type: page % is %, and the inbox takes images and PDF', v_file.n, coalesce(nullif(v_type, ''), 'of no type')
        using errcode = '22023';
    end if;
    if v_file.page ? 'byte_size' and jsonb_typeof(v_file.page -> 'byte_size') <> 'null'
       and (jsonb_typeof(v_file.page -> 'byte_size') <> 'number' or (v_file.page ->> 'byte_size')::numeric < 0
            or (v_file.page ->> 'byte_size')::numeric <> trunc((v_file.page ->> 'byte_size')::numeric)) then
      raise exception 'inbox_no_files: page % gives a byte_size that is not a whole number of bytes', v_file.n
        using errcode = '22023';
    end if;
    -- Where the installation has Supabase Storage, the page is there.
    if to_regclass('storage.objects') is not null then
      execute 'select exists (select 1 from storage.objects where bucket_id = $1 and name = $2)'
        into v_found using 'attachments', v_path;
      if not v_found then
        raise exception 'inbox_file_missing: page % is not in the bucket attachments at %. Upload it first, then announce it.', v_file.n, v_path
          using errcode = 'no_data_found';
      end if;
    end if;
  end loop;

  select * into v_document from documents
   where company_id = p_company_id and client_ref = p_reference;

  if found and v_document.doc_type not in ('purchase_invoice', 'purchase_credit_note') then
    raise exception 'inbox_reference_taken: the reference % already names another kind of document in this company', p_reference
      using errcode = '23505';
  end if;

  if not found then
    select c.currency_code into v_currency from companies c where c.id = p_company_id;
    -- The day it was taken, where the person is: their own time zone when
    -- they set one, else the day of the instant as it was sent.
    select p.timezone into v_zone from user_preferences p
     where p.user_id = auth.uid() and p.timezone in (select name from pg_timezone_names);
    insert into documents (company_id, doc_type, contact_id, document_date, currency_code, client_ref)
    values (p_company_id, 'purchase_invoice', null,
            (coalesce(p_taken_at, now()) at time zone coalesce(v_zone, 'UTC'))::date,
            v_currency, p_reference)
    returning * into v_document;
  end if;

  -- The pages it does not hold yet, in the order they were sent.
  for v_file in select value as page, ordinality as n from jsonb_array_elements(p_files) with ordinality loop
    v_path := v_file.page ->> 'storage_path';
    continue when exists (select 1 from attachments a
                           where a.entity_type = 'document' and a.entity_id = v_document.id
                             and a.storage_path = v_path);
    v_name := nullif(btrim(coalesce(v_file.page ->> 'file_name', '')), '');
    v_size := case when jsonb_typeof(v_file.page -> 'byte_size') = 'number' then (v_file.page ->> 'byte_size')::bigint end;
    insert into attachments (company_id, entity_type, entity_id, file_name, mime_type, byte_size, storage_path, created_at)
    values (p_company_id, 'document', v_document.id,
            coalesce(v_name, regexp_replace(v_path, '^.*/', '')),
            lower(v_file.page ->> 'mime_type'), v_size, v_path, clock_timestamp());
  end loop;

  return v_document.id;
end;
$$;

comment on function receive_purchase_document(uuid, text, timestamptz, jsonb) is
  'A purchase document sent from a phone to the inbox of a company: one draft purchase_invoice, client_ref the reference the phone gave it, dated the day it was taken (the caller''s time zone when they set one), in the company''s currency, with no contact and no line yet, and one attachments row per page on it, in the order given. p_files is [{storage_path, file_name, mime_type, byte_size}]; every path is a file under <company_id>/inbox/<reference>/ of the bucket attachments, and an object there where the installation has Storage (inbox_path_outside, inbox_file_missing); every type an image or a PDF (inbox_file_type). Needs documents.write (not_allowed, 42501). Idempotent on (company, reference): a second call returns the same document and adds only the pages it does not hold, by path. Security invoker. Decision 0091.';

revoke execute on function receive_purchase_document(uuid, text, timestamptz, jsonb) from public, anon;
grant execute on function receive_purchase_document(uuid, text, timestamptz, jsonb) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. The bucket a company's files are kept in, and who may write there
-- ---------------------------------------------------------------------------

create or replace function storage_path_company(p_name text)
returns uuid
language sql
immutable
set search_path = ekwo, pg_temp
as $$
  select case
           when split_part(p_name, '/', 1) ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
             then split_part(p_name, '/', 1)::uuid
         end;
$$;

comment on function storage_path_company(text) is
  'The company a file of the bucket attachments belongs to: the first folder of its path when it is a company id, else null. Read by the policies of storage.objects on that bucket.';

revoke execute on function storage_path_company(text) from public, anon;
grant execute on function storage_path_company(text) to authenticated, service_role;

do $$
begin
  if to_regclass('storage.objects') is null or to_regclass('storage.buckets') is null then
    raise notice 'ekwo: no Supabase Storage in this database; the bucket attachments and its policies are left to the installation.';
    return;
  end if;

  insert into storage.buckets (id, name, public) values ('attachments', 'attachments', false)
  on conflict (id) do nothing;

  drop policy if exists ekwo_attachments_read on storage.objects;
  create policy ekwo_attachments_read on storage.objects
    for select to authenticated
    using (bucket_id = 'attachments'
           and (ekwo.has_capability(ekwo.storage_path_company(name), 'documents.read')
                or ekwo.has_capability(ekwo.storage_path_company(name), 'filings.read')));

  drop policy if exists ekwo_attachments_write on storage.objects;
  create policy ekwo_attachments_write on storage.objects
    for insert to authenticated
    with check (bucket_id = 'attachments'
                and (ekwo.has_capability(ekwo.storage_path_company(name), 'documents.write')
                     or ekwo.has_capability(ekwo.storage_path_company(name), 'filings.write')));

  drop policy if exists ekwo_attachments_remove on storage.objects;
  create policy ekwo_attachments_remove on storage.objects
    for delete to authenticated
    using (bucket_id = 'attachments'
           and (ekwo.has_capability(ekwo.storage_path_company(name), 'documents.write')
                or ekwo.has_capability(ekwo.storage_path_company(name), 'filings.write')));
exception
  when insufficient_privilege then
    raise notice 'ekwo: could not create the bucket attachments or its policies on storage.objects (%). Somebody with the privilege runs this file''s third part again; until then a phone cannot upload to the inbox.', sqlerrm;
end $$;

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every file of this directory ends with.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
