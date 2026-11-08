-- Ekwo OS — an electronic invoice received arrives by the same door as a
-- page sent from a phone (decision 0091).
--
-- `receive_purchase_document()` is the one call a received purchase document
-- enters the books by: its pages are put in the private bucket `attachments`
-- under `<company_id>/inbox/<reference>/`, then announced, and the call
-- writes one draft purchase with no contact and no line, its pages as
-- attachments. Until now it took images and PDF only, the pages a phone
-- photographs.
--
-- A structured electronic invoice — a UBL or CII file received from an
-- e-invoicing network through an access point — is one XML page. Whoever
-- reads the inbox reads that page exactly, with the readers of the core, and
-- turns it into the draft's supplier, lines and taxes; the books only keep
-- it, as they keep a photograph. So the door now takes `application/xml` and
-- `text/xml` beside images and PDF, and nothing else changes: the same
-- rights (`documents.write`, for a person or a machine key alike), the same
-- paths, the same idempotency on the reference, the same refusals by name —
-- `inbox_file_type` now says « images, PDF and XML ».
--
-- The function is replaced whole, as `create or replace` asks; its body is
-- the one of `20261028152338_a_purchase_arrives_from_the_phone.sql` but for
-- the check of the type. Its privileges are restated, as every file of this
-- directory does.

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
    if v_type !~ '^image/[a-z0-9][a-z0-9.+-]*$' and v_type not in ('application/pdf', 'application/xml', 'text/xml') then
      raise exception 'inbox_file_type: page % is %, and the inbox takes images, PDF and XML', v_file.n, coalesce(nullif(v_type, ''), 'of no type')
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
  'A purchase document sent to the inbox of a company — pages from a phone, or the XML file of an electronic invoice received: one draft purchase_invoice, client_ref the reference its sender gave it, dated the day it was taken (the caller''s time zone when they set one), in the company''s currency, with no contact and no line yet, and one attachments row per page on it, in the order given. p_files is [{storage_path, file_name, mime_type, byte_size}]; every path is a file under <company_id>/inbox/<reference>/ of the bucket attachments, and an object there where the installation has Storage (inbox_path_outside, inbox_file_missing); every type an image, a PDF, or XML — the file of an electronic invoice received (inbox_file_type). Needs documents.write (not_allowed, 42501). Idempotent on (company, reference): a second call returns the same document and adds only the pages it does not hold, by path. Security invoker. Decision 0091.';

revoke execute on function receive_purchase_document(uuid, text, timestamptz, jsonb) from public, anon;
grant execute on function receive_purchase_document(uuid, text, timestamptz, jsonb) to authenticated, service_role;

-- `create or replace` keeps the privileges the function already had, and the
-- revoke is what every file of this directory ends with.
revoke execute on all functions in schema ekwo from public;

notify pgrst, 'reload schema';
