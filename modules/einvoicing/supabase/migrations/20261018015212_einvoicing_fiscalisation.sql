-- Ekwo — the `einvoicing` module, version 1.1.0: fiscalisation, the chained
-- record a country requires for every invoice the software issues.
--
-- Many countries ask the invoicing software itself to leave, for every
-- invoice it issues, a record that cannot be changed, chained to the record
-- before it by a hash, often shown on the invoice as a QR code and a sentence,
-- and sent to the tax authority at once or later. The module already had the
-- shape: a posted sale, an artefact a brick writes, a transmission through a
-- transport the host brings, a state recorded, all in `security definer`
-- functions. A fiscal record is a second artefact of the same document, sent
-- to another counter. So this file adds, and changes nothing that was issued:
--
--   * **the chain**, `einvoicing.fiscal_chain`: one row per record, numbered
--     1, 2, 3 within one company and one invoicing system, each carrying the
--     hash of the one before it. The first record says it is the first. The
--     hash is the brick's — the text it hashes is format-specific — but the
--     database checks what it can without trusting the caller: that the hash
--     is the digest the pack names of the text it was given, that the record
--     holds every field the pack says the hash covers, and that the record
--     before it is the tail of the chain and is itself intact;
--   * **the events**, `einvoicing.fiscal_events`: what the system records
--     beside the invoices where the law asks it to — a summary every so many
--     hours, a start, a stop, an anomaly — appended, never rewritten;
--   * **the file** of a record, kept where every file of a document is kept:
--     `einvoicing.issues`, which learns an artefact kind. An electronic
--     invoice is `einvoice`; a fiscal record is `fiscal_record`. A sending
--     is of one artefact, and the rule "one sending alive per document" holds
--     per artefact: the invoice on its way to the customer does not stop the
--     record on its way to the authority.
--
-- **The module still knows no country.** Whether a company has such a regime,
-- which format its records are written in, which digest chains them and which
-- fields it covers is the `einvoicing.fiscalisation` block of the pack of its
-- fiscal country, compiled by the socle into
-- `country_defaults.einvoice_fiscalisation`. The XML is written by a brick of
-- `packages/formats/`, run by `@ekwo-ai/core`; a format no brick writes is
-- refused there, by name.
--
-- **The socle column comes first.** `country_defaults.einvoice_fiscalisation`
-- is added by the socle migration `20261018014537`. The manifest keeps its
-- `requires_socle_min`, which every migration of a module must sort after;
-- the functions below read the column when they run, not when they are
-- created, and `ekwo migrate` applies the socle before the modules.
--
-- **Nothing is fiscalised by a trigger.** A posted sale of a company whose
-- pack declares a regime and that has no record is named by the status, and
-- the record is made by an explicit gesture — `ekwo einvoice fiscalise`,
-- `einvoicing_fiscalise` — so that the person who chains a record is the one
-- who decided to.

-- ---------------------------------------------------------------------------
-- Vocabulary
-- ---------------------------------------------------------------------------

create type einvoicing.artefact as enum ('einvoice', 'fiscal_record');

comment on type einvoicing.artefact is
  'What a kept file is to its document. einvoice: the electronic invoice, for the customer. fiscal_record: the record a fiscalisation regime requires of the invoicing software, for the tax authority. Each is issued and sent on its own.';

create type einvoicing.fiscal_record_kind as enum ('alta', 'anulacion');

comment on type einvoicing.fiscal_record_kind is
  'What a fiscal record says of its invoice. alta: the invoice was issued. anulacion: the record of an issued invoice is cancelled. The two words are the ones the regimes the packs carry use for the two kinds; a regime with one kind uses alta.';

-- ---------------------------------------------------------------------------
-- Issues and transmissions learn the artefact they are of
-- ---------------------------------------------------------------------------

alter table einvoicing.issues
  add column artefact einvoicing.artefact not null default 'einvoice';

comment on column einvoicing.issues.artefact is
  'What the file is to the document: the electronic invoice (einvoice) or a fiscal record (fiscal_record). For a fiscal record, profile is the format of the pack''s fiscalisation block, and the row is written by einvoicing.append_fiscal_record() alone.';

-- Numbered per artefact: the first fiscal record of a document is its first,
-- whatever electronic invoices were issued before it.
alter table einvoicing.issues drop constraint issues_document_id_sequence_key;
alter table einvoicing.issues add constraint issues_document_artefact_sequence_key
  unique (document_id, artefact, sequence);

alter table einvoicing.transmissions
  add column artefact einvoicing.artefact not null default 'einvoice';

comment on column einvoicing.transmissions.artefact is
  'The artefact of the issue this sending carries, copied from it when the sending is recorded: an electronic invoice goes to the customer, a fiscal record to the tax authority, and each has its own sending alive at most.';

drop index einvoicing.einvoicing_transmissions_one_alive_idx;
create unique index einvoicing_transmissions_one_alive_idx on einvoicing.transmissions (document_id, artefact)
  where state in ('prepared', 'submitted', 'accepted_by_access_point', 'delivered');

-- The guard of a sending holds its artefact fixed with the rest of what was sent.
create or replace function einvoicing.guard_transmission()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'DELETE' then
    raise exception 'transmission_recorded: a sending is part of the history of a document and is not deleted'
      using errcode = '55006';
  end if;

  if tg_op = 'UPDATE' then
    if (new.company_id, new.document_id, new.issue_id, new.artefact, new.sequence, new.channel, new.service,
        new.prepared_at, new.prepared_by)
       is distinct from
       (old.company_id, old.document_id, old.issue_id, old.artefact, old.sequence, old.channel, old.service,
        old.prepared_at, old.prepared_by) then
      raise exception 'transmission_recorded: what was sent, how and by whom does not change once recorded; only the state, the reference and the last message move'
        using errcode = '55006';
    end if;
    if old.reference is not null and new.reference is distinct from old.reference then
      raise exception 'transmission_reference_differs: this sending is % at the service, and a reference once given does not change (got %)',
        old.reference, coalesce(new.reference, 'none')
        using errcode = '55006';
    end if;
    if new.state <> old.state then
      if einvoicing.state_rank(old.state) = 3 then
        raise exception 'transmission_closed: this sending is %, and a closed sending does not move. Send the document again: that is a new transmission.',
          old.state
          using errcode = '55006';
      end if;
      if einvoicing.state_rank(new.state) <= einvoicing.state_rank(old.state) then
        raise exception 'transmission_state_backwards: a sending that is % does not go back to %',
          old.state, new.state
          using errcode = '55006';
      end if;
      if new.state = 'failed' and old.state <> 'prepared' then
        raise exception 'transmission_already_left: a sending that is % has left, and cannot have failed to; a refusal on the way is rejected',
          old.state
          using errcode = '55006';
      end if;
    end if;
  end if;

  if einvoicing.state_has_left(new.state) and new.state <> 'rejected' and new.reference is null then
    raise exception 'transmission_reference_missing: a sending that is % was taken by somebody, who gave it a reference; record it',
      new.state
      using errcode = '23514';
  end if;
  return new;
end;
$$;

comment on function einvoicing.guard_transmission() is
  'Holds a transmission to what it is: never deleted; its document, file, artefact, channel and service fixed; its reference set once; its state only moving forward, and never again once closed; and a reference wherever somebody took the file.';

-- ---------------------------------------------------------------------------
-- The digest a pack names, computed by the database
-- ---------------------------------------------------------------------------

create or replace function einvoicing.fiscal_digest(p_algorithm text, p_encoding text, p_input text)
returns text
language sql
immutable
as $$
  select case coalesce(p_encoding, 'hex-lower')
           when 'base64' then encode(d, 'base64')
           when 'hex-upper' then upper(encode(d, 'hex'))
           else encode(d, 'hex')
         end
    from (select case p_algorithm
                   when 'SHA-256' then sha256(convert_to(p_input, 'UTF8'))
                   when 'SHA-384' then sha384(convert_to(p_input, 'UTF8'))
                   when 'SHA-512' then sha512(convert_to(p_input, 'UTF8'))
                 end as d) x;
$$;

comment on function einvoicing.fiscal_digest(text, text, text) is
  'The digest of a text as a fiscalisation regime writes it: SHA-256, SHA-384 or SHA-512 of its UTF-8 bytes, in hexadecimal capitals, lower case or base64 as the pack''s hash.encoding says (lower-case hexadecimal where it says nothing). Null for an algorithm it does not know, which the callers refuse.';

-- ---------------------------------------------------------------------------
-- The chain
-- ---------------------------------------------------------------------------

create table einvoicing.fiscal_chain (
  id                uuid primary key default gen_random_uuid(),
  company_id        uuid not null references public.companies(id) on delete cascade,
  -- The invoicing system the chain is kept by: its identifier and its
  -- installation, as the caller names them. One chain per company and system.
  system_id         text not null,
  seq               integer not null,
  document_id       uuid not null,
  kind              einvoicing.fiscal_record_kind not null,
  format            text not null,
  -- What identifies the invoice in the chain, as the record wrote it: the
  -- next record names its predecessor by these four and its hash.
  issuer_tax_id     text not null,
  series            text not null default '',
  number            text not null,
  issued_on         date not null,
  -- The fields the hash covers, by the names the pack gives them, each as the
  -- exact text that was hashed.
  record            jsonb not null,
  hash_input        text not null,
  hash_algorithm    text not null,
  hash_encoding     text,
  hash              text not null,
  previous_hash     text,
  is_first          boolean not null,
  -- When the record was generated, as the record says it, with the offset it
  -- was written with: the regimes hash the text, and a time zone lost is a
  -- hash that no longer matches.
  generated_at      text not null,
  generated_instant timestamptz not null,
  mode              text not null,
  verification_url  text,
  issue_id          uuid not null,
  recorded_at       timestamptz not null default now(),
  recorded_by       uuid,
  foreign key (document_id, company_id) references public.documents (id, company_id),
  foreign key (issue_id, company_id) references einvoicing.issues (id, company_id),
  unique (company_id, system_id, seq),
  constraint einvoicing_fiscal_chain_seq check (seq >= 1),
  constraint einvoicing_fiscal_chain_first check (is_first = (seq = 1) and is_first = (previous_hash is null)),
  constraint einvoicing_fiscal_chain_system check (nullif(btrim(system_id), '') is not null),
  constraint einvoicing_fiscal_chain_record check (jsonb_typeof(record) = 'object'),
  constraint einvoicing_fiscal_chain_mode check (mode in ('realtime', 'batch', 'none')),
  constraint einvoicing_fiscal_chain_generated_at check (
    generated_at ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?([+-][0-9]{2}:[0-9]{2}|Z)$'
  )
);

comment on table einvoicing.fiscal_chain is
  'The chain of fiscal records of one company in one invoicing system: one row per record, numbered from 1, each carrying the hash of the one before it. Written by einvoicing.append_fiscal_record() alone, never edited and never deleted; einvoicing.verify_fiscal_chain() walks it both ways.';
comment on column einvoicing.fiscal_chain.system_id is
  'The invoicing system and installation the chain is kept by, as the caller names it. A company keeps one chain per system.';
comment on column einvoicing.fiscal_chain.record is
  'The fields the hash covers, by the names the pack''s hash.fields gives them, each as the text that was hashed.';
comment on column einvoicing.fiscal_chain.hash_input is
  'The exact text the brick hashed. The database computes its digest again on every insert and refuses a hash that is not it.';
comment on column einvoicing.fiscal_chain.generated_at is
  'When the record was generated, as the record writes it: ISO 8601 with its offset. generated_instant is the same moment as a timestamp, for ordering.';
comment on column einvoicing.fiscal_chain.mode is
  'How this record reaches the authority, one of the modes the pack''s submission.modes allows: realtime, batch, or none (kept, handed over on request). It decides the verification URL.';
comment on column einvoicing.fiscal_chain.verification_url is
  'What the QR code of the invoice encodes, as the brick wrote it for this record''s mode. The PDF of the invoice reads it here.';
comment on column einvoicing.fiscal_chain.issue_id is
  'The file of the record, kept in einvoicing.issues as a fiscal_record artefact of the document.';

create unique index einvoicing_fiscal_chain_id_company_idx on einvoicing.fiscal_chain (id, company_id);
create index einvoicing_fiscal_chain_document_company_idx on einvoicing.fiscal_chain (document_id, company_id);
create index einvoicing_fiscal_chain_issue_company_idx on einvoicing.fiscal_chain (issue_id, company_id);

-- ---------------------------------------------------------------------------
-- The events
-- ---------------------------------------------------------------------------

create table einvoicing.fiscal_events (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references public.companies(id) on delete cascade,
  system_id   text not null,
  seq         integer not null,
  kind        text not null,
  detail      jsonb not null default '{}'::jsonb,
  at          timestamptz not null default now(),
  recorded_by uuid,
  unique (company_id, system_id, seq),
  constraint einvoicing_fiscal_events_kind check (kind ~ '^[a-z][a-z0-9_]{0,59}$'),
  constraint einvoicing_fiscal_events_system check (nullif(btrim(system_id), '') is not null),
  constraint einvoicing_fiscal_events_detail check (jsonb_typeof(detail) = 'object')
);

comment on table einvoicing.fiscal_events is
  'What an invoicing system records beside its fiscal records where the law asks it to — a summary every so many hours, a start, a stop, an anomaly found in the chain — numbered per company and system. Appended by einvoicing.log_fiscal_event(), never edited, never deleted.';
comment on column einvoicing.fiscal_events.kind is
  'What happened, as a short name the caller chooses: summary, started, stopped, chain_break. The pack says how often a summary is due; the module records whatever is logged.';

create index einvoicing_fiscal_events_company_idx on einvoicing.fiscal_events (company_id, at desc);

-- ---------------------------------------------------------------------------
-- The guards: what was chained does not move
-- ---------------------------------------------------------------------------

create or replace function einvoicing.guard_fiscal()
returns trigger
language plpgsql
as $$
begin
  raise exception 'fiscal_record_kept: % is a record the law requires to stay as it was made, and is not %. A mistake is corrected by a new record — an anulacion, then a new alta — and the old one stays.',
    tg_table_name,
    case tg_op when 'UPDATE' then 'rewritten' else 'deleted' end
    using errcode = '55006';
end;
$$;

comment on function einvoicing.guard_fiscal() is
  'Refuses every update and every delete of a fiscal record or a fiscal event: fiscal_record_kept.';

create trigger einvoicing_fiscal_chain_guard
  before update or delete on einvoicing.fiscal_chain
  for each row execute function einvoicing.guard_fiscal();

create trigger einvoicing_fiscal_events_guard
  before update or delete on einvoicing.fiscal_events
  for each row execute function einvoicing.guard_fiscal();

-- ---------------------------------------------------------------------------
-- record_issue: the same function, and an artefact
--
-- Dropped and created again rather than overloaded: two functions of one name
-- whose calls differ by a default are a call PostgREST cannot resolve.
-- ---------------------------------------------------------------------------

drop function einvoicing.record_issue(uuid, text, text, text, text, text, text, text, jsonb);

create or replace function einvoicing.record_issue(
  p_document_id   uuid,
  p_profile       text,
  p_brick         text,
  p_specification text,
  p_filename      text,
  p_media_type    text,
  p_content       text,
  p_checksum      text,
  p_violations    jsonb default '[]'::jsonb,
  p_artefact      einvoicing.artefact default 'einvoice'
)
returns einvoicing.issues
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_doc      public.documents%rowtype;
  v_what     text;
  v_profile  text;
  v_issue    einvoicing.issues%rowtype;
  v_next     integer;
  v_bad      jsonb;
  v_artefact einvoicing.artefact := coalesce(p_artefact, 'einvoice');
begin
  -- A document of a company the caller may not know of is answered as one
  -- that does not exist, before any capability is asked about it.
  select * into v_doc from public.documents d where d.id = p_document_id;
  if not found or not public.may_know_of_company(v_doc.company_id) then
    raise exception 'unknown_document: document % does not exist', p_document_id
      using errcode = 'P0002';
  end if;
  perform einvoicing.require(v_doc.company_id, 'einvoicing.send', 'issuing an electronic invoice');
  if not public.is_installer() and not public.has_capability(v_doc.company_id, 'documents.read') then
    raise exception 'not_allowed: issuing the electronic invoice of a document needs documents.read'
      using errcode = '42501';
  end if;

  v_what := v_doc.doc_type || ' ' || coalesce(v_doc.number, v_doc.id::text);
  if v_doc.doc_type not in ('sale_invoice', 'sale_credit_note') then
    raise exception 'document_not_a_sale: % is not a sale invoice or a sale credit note, and only a sale is issued electronically by its seller',
      v_what;
  end if;
  if v_doc.state <> 'posted' then
    raise exception 'document_not_posted: % is %, and only a posted document is issued: post it first, and the file says what the books say',
      v_what, v_doc.state;
  end if;

  if v_artefact = 'fiscal_record' then
    -- The file of a fiscal record exists because a record was chained: it is
    -- kept by append_fiscal_record(), in the same transaction, and by nobody
    -- else, so a file never stands for a record the chain does not hold.
    if current_setting('einvoicing.fiscal_append', true) is distinct from p_document_id::text then
      raise exception 'fiscal_record_outside_chain: the file of a fiscal record is kept by einvoicing.append_fiscal_record(), which chains the record it is the file of';
    end if;
    select d.einvoice_fiscalisation ->> 'format' into v_profile
      from public.companies c
      left join public.country_defaults d on d.country = c.fiscal_country
     where c.id = v_doc.company_id;
    if v_profile is null then
      raise exception 'no_fiscalisation_regime: the country pack of this company declares no fiscalisation regime, so % has no fiscal record to keep',
        v_what;
    end if;
    if p_profile is distinct from v_profile then
      raise exception 'fiscal_format_mismatch: the fiscal record of % is written as %, the format of this company''s country pack, not as %',
        v_what, v_profile, coalesce(p_profile, 'nothing');
    end if;
  else
    -- The format is the country's, read where the socle compiled it, on the day
    -- of issue. A file written in another profile is refused rather than kept
    -- under this one's name.
    select d.einvoice_profile into v_profile
      from public.companies c
      left join public.country_defaults d on d.country = c.fiscal_country
     where c.id = v_doc.company_id;
    if v_profile is null then
      raise exception 'no_einvoicing_profile: the country pack of this company declares no e-invoicing profile, so there is no format to issue % in. A pack says which one in its einvoicing section.',
        v_what;
    end if;
    if p_profile is distinct from v_profile then
      raise exception 'einvoice_profile_mismatch: % is issued as %, the profile of this company''s country pack, not as %',
        v_what, v_profile, coalesce(p_profile, 'nothing');
    end if;
  end if;

  if p_violations is null or jsonb_typeof(p_violations) <> 'array' then
    raise exception 'bad_violations: the rules a file breaks are a list, empty when it breaks none';
  end if;
  select v into v_bad
    from jsonb_array_elements(p_violations) v
   where jsonb_typeof(v) <> 'object'
      or jsonb_typeof(v -> 'code') is distinct from 'string'
      or jsonb_typeof(v -> 'message') is distinct from 'string'
   limit 1;
  if found then
    raise exception 'bad_violations: each broken rule is an object with a code and a message, as the brick named it; got %', v_bad;
  end if;
  if p_content is null or p_content = '' or nullif(btrim(p_filename), '') is null
     or nullif(btrim(p_brick), '') is null or nullif(btrim(p_media_type), '') is null then
    raise exception 'bad_einvoice: a file, its name, its media type and the brick that wrote it are all needed';
  end if;

  -- One writer per document at a time: two issues cannot take one number.
  perform pg_advisory_xact_lock(hashtextextended('einvoicing:' || p_document_id::text, 0));

  -- The same file twice is one issue. What the brick writes from the same
  -- books is the same bytes, so asking again returns what was kept.
  select * into v_issue from einvoicing.issues i
   where i.document_id = p_document_id and i.checksum = lower(p_checksum);
  if found then
    return v_issue;
  end if;

  select coalesce(max(i.sequence), 0) + 1 into v_next
    from einvoicing.issues i where i.document_id = p_document_id and i.artefact = v_artefact;

  insert into einvoicing.issues
    (company_id, document_id, artefact, sequence, profile, brick, specification, filename, media_type,
     content, byte_size, checksum, violations, sendable, issued_by)
  values
    (v_doc.company_id, p_document_id, v_artefact, v_next, p_profile, p_brick, p_specification, p_filename, p_media_type,
     p_content, octet_length(p_content), lower(p_checksum), p_violations,
     jsonb_array_length(p_violations) = 0, public.acting_user())
  returning * into v_issue;

  return v_issue;
end;
$$;

comment on function einvoicing.record_issue(uuid, text, text, text, text, text, text, text, jsonb, einvoicing.artefact) is
  'Keeps the file a brick wrote for a posted sale invoice or credit note, with the rules it breaks: its electronic invoice (artefact einvoice, the default) or the file of a fiscal record (fiscal_record, kept by append_fiscal_record() alone). Refuses a document that is not a posted sale (document_not_a_sale, document_not_posted), a company whose pack declares no profile or no regime (no_einvoicing_profile, no_fiscalisation_regime), a file written in another format than the pack''s (einvoice_profile_mismatch, fiscal_format_mismatch) and a checksum that is not the SHA-256 of the text (einvoice_checksum_mismatch). The same file twice returns the first issue. Needs einvoicing.send and documents.read.';

-- ---------------------------------------------------------------------------
-- record_transmission: a sending is of one artefact
-- ---------------------------------------------------------------------------

create or replace function einvoicing.record_transmission(
  p_issue_id  uuid,
  p_channel   einvoicing.channel,
  p_service   text default null
)
returns einvoicing.transmissions
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_issue  einvoicing.issues%rowtype;
  v_doc    public.documents%rowtype;
  v_what   text;
  v_alive  einvoicing.transmissions%rowtype;
  v_latest integer;
  v_next   integer;
  v_row    einvoicing.transmissions%rowtype;
  v_rules  text;
begin
  select * into v_issue from einvoicing.issues i where i.id = p_issue_id;
  if not found or not public.may_know_of_company(v_issue.company_id) then
    raise exception 'unknown_einvoice: no electronic invoice % was issued', p_issue_id
      using errcode = 'P0002';
  end if;
  perform einvoicing.require(v_issue.company_id, 'einvoicing.send', 'sending an electronic invoice');

  select * into v_doc from public.documents d where d.id = v_issue.document_id;
  v_what := v_doc.doc_type || ' ' || coalesce(v_doc.number, v_doc.id::text);
  if v_issue.artefact = 'fiscal_record' then
    v_what := 'the fiscal record of ' || v_what;
  end if;

  -- The rules, verbatim. A file that breaks one is the file an access point
  -- refuses, and sending it anyway only moves the refusal further away.
  if not v_issue.sendable then
    select string_agg(
             (v ->> 'code') || coalesce(' (line ' || (v ->> 'line') || ')', '') || ': ' || (v ->> 'message'),
             '; ' order by o)
      into v_rules
      from jsonb_array_elements(v_issue.violations) with ordinality as x(v, o);
    raise exception 'einvoice_not_sendable: % breaks % rule(s) of %, and a file that breaks one is not sent — %. Complete the books it is written from and issue it again.',
      v_what, jsonb_array_length(v_issue.violations), v_issue.profile, v_rules;
  end if;

  if v_doc.state <> 'posted' then
    raise exception 'document_not_posted: % is %, and only a posted document is sent', v_what, v_doc.state;
  end if;

  if p_channel = 'service' and nullif(btrim(p_service), '') is null then
    raise exception 'service_not_named: a sending through a service names the service, as free text';
  end if;

  perform pg_advisory_xact_lock(hashtextextended('einvoicing:' || v_issue.document_id::text, 0));

  -- An older file of a document whose books were completed since is not the
  -- one to send: the newer issue says more, and the customer gets one. A
  -- fiscal record is never superseded: each one is a link of the chain, and
  -- each one is sent.
  if v_issue.artefact = 'einvoice' then
    select max(i.sequence) into v_latest from einvoicing.issues i
     where i.document_id = v_issue.document_id and i.artefact = v_issue.artefact;
    if v_issue.sequence < v_latest then
      raise exception 'einvoice_superseded: % was issued again since this file (issue % of %); send the latest',
        v_what, v_issue.sequence, v_latest;
    end if;
  end if;

  select * into v_alive from einvoicing.transmissions t
   where t.document_id = v_issue.document_id
     and t.artefact = v_issue.artefact
     and t.state in ('prepared', 'submitted', 'accepted_by_access_point', 'delivered')
     and (v_issue.artefact = 'einvoice' or t.issue_id = v_issue.id)
   limit 1;
  if found then
    raise exception 'einvoice_already_sent: % is % already (transmission %, %), and a file is received once. A sending that is rejected or failed is sent again; one on its way is followed with its status.',
      v_what, v_alive.state, v_alive.sequence, coalesce(v_alive.reference, 'no reference yet')
      using errcode = '55006';
  end if;

  select coalesce(max(t.sequence), 0) + 1 into v_next
    from einvoicing.transmissions t where t.document_id = v_issue.document_id;

  insert into einvoicing.transmissions
    (company_id, document_id, issue_id, artefact, sequence, channel, service, prepared_by)
  values
    (v_issue.company_id, v_issue.document_id, v_issue.id, v_issue.artefact, v_next, p_channel,
     nullif(btrim(p_service), ''), public.acting_user())
  returning * into v_row;

  insert into einvoicing.transmission_events
    (company_id, transmission_id, sequence, state, recorded_by)
  values
    (v_row.company_id, v_row.id, 1, 'prepared', public.acting_user());

  return v_row;
end;
$$;

comment on function einvoicing.record_transmission(uuid, einvoicing.channel, text) is
  'Records that an issued file — an electronic invoice or a fiscal record — is about to be sent, as prepared: the channel, and the service by name where one is used. Refuses a file that breaks a rule, repeating the rules verbatim (einvoice_not_sendable), an older electronic invoice of a document issued again since (einvoice_superseded), and a file already on its way or delivered (einvoice_already_sent). Needs einvoicing.send.';

-- The two columns of the socle say a document left for its customer. A
-- fiscal record leaves for the authority, and writes nothing there: the
-- module's tables are its record. Only that condition changes.
create or replace function einvoicing.record_transmission_outcome(
  p_transmission_id uuid,
  p_state           einvoicing.transmission_state,
  p_reference       text default null,
  p_message         text default null,
  p_detail          jsonb default null,
  p_occurred_at     timestamptz default null
)
returns einvoicing.transmissions
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row  einvoicing.transmissions%rowtype;
  v_next integer;
begin
  select * into v_row from einvoicing.transmissions t where t.id = p_transmission_id;
  if not found or not public.may_know_of_company(v_row.company_id) then
    raise exception 'unknown_transmission: no sending % was recorded', p_transmission_id
      using errcode = 'P0002';
  end if;
  perform einvoicing.require(v_row.company_id, 'einvoicing.send', 'recording what came back from a sending');

  if p_state = 'prepared' then
    raise exception 'not_an_outcome: prepared is where a sending starts, not something a service answers';
  end if;

  perform pg_advisory_xact_lock(hashtextextended('einvoicing:' || v_row.document_id::text, 0));
  select * into v_row from einvoicing.transmissions t where t.id = p_transmission_id;

  if p_state = v_row.state
     and (p_reference is null or p_reference = v_row.reference)
     and (p_message is null or p_message is not distinct from v_row.message)
     and p_detail is null then
    return v_row;
  end if;

  update einvoicing.transmissions t
     set state     = p_state,
         state_at  = case when p_state <> t.state then now() else t.state_at end,
         reference = coalesce(p_reference, t.reference),
         message   = coalesce(p_message, t.message)
   where t.id = p_transmission_id
  returning * into v_row;

  select coalesce(max(e.sequence), 0) + 1 into v_next
    from einvoicing.transmission_events e where e.transmission_id = p_transmission_id;
  insert into einvoicing.transmission_events
    (company_id, transmission_id, sequence, state, reference, message, detail, occurred_at, recorded_by)
  values
    (v_row.company_id, v_row.id, v_next, p_state, p_reference, p_message, p_detail, p_occurred_at, public.acting_user());

  if v_row.artefact = 'einvoice' and einvoicing.state_has_left(v_row.state) and v_row.reference is not null then
    update public.documents d
       set peppol_status     = v_row.state::text,
           peppol_message_id = coalesce(v_row.reference, d.peppol_message_id)
     where d.id = v_row.document_id
       and (d.peppol_status is distinct from v_row.state::text
            or d.peppol_message_id is distinct from coalesce(v_row.reference, d.peppol_message_id));
  end if;

  return v_row;
end;
$$;

comment on function einvoicing.record_transmission_outcome(uuid, einvoicing.transmission_state, text, text, jsonb, timestamptz) is
  'Records what a transport or a service answered about a sending: its new state, its reference where it gave one, and its words verbatim, as one more event. A state only moves forward and a closed sending does not move (transmission_state_backwards, transmission_closed); the same answer twice records nothing. Once an electronic invoice has left, writes the state and the reference on documents.peppol_status and peppol_message_id, which is what keeps unpost_document() from taking it back to draft; a fiscal record writes nothing there. Needs einvoicing.send.';

-- ---------------------------------------------------------------------------
-- The regime of a company, as its pack declares it
-- ---------------------------------------------------------------------------

create or replace function einvoicing.fiscal_regime(p_company_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
begin
  return (select d.einvoice_fiscalisation
            from public.companies c
            left join public.country_defaults d on d.country = c.fiscal_country
           where c.id = p_company_id
             and public.may_know_of_company(c.id));
end;
$$;

comment on function einvoicing.fiscal_regime(uuid) is
  'The einvoicing.fiscalisation block of the pack of the company''s fiscal country, as the socle compiled it; null where the country has no such regime, or the caller may not know of the company.';

-- ---------------------------------------------------------------------------
-- append_fiscal_record: one more link, and its file
-- ---------------------------------------------------------------------------

create or replace function einvoicing.append_fiscal_record(
  p_document_id      uuid,
  p_system_id        text,
  p_kind             einvoicing.fiscal_record_kind,
  p_format           text,
  p_mode             text,
  p_issuer_tax_id    text,
  p_series           text,
  p_number           text,
  p_issued_on        date,
  p_record           jsonb,
  p_hash_input       text,
  p_hash             text,
  p_previous_hash    text,
  p_generated_at     text,
  p_verification_url text,
  p_brick            text,
  p_specification    text,
  p_filename         text,
  p_media_type       text,
  p_content          text,
  p_checksum         text,
  p_violations       jsonb default '[]'::jsonb
)
returns einvoicing.fiscal_chain
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_doc       public.documents%rowtype;
  v_what      text;
  v_regime    jsonb;
  v_algorithm text;
  v_encoding  text;
  v_fields    jsonb;
  v_missing   text;
  v_tail      einvoicing.fiscal_chain%rowtype;
  v_before    einvoicing.fiscal_chain%rowtype;
  v_last      einvoicing.fiscal_record_kind;
  v_issue     einvoicing.issues%rowtype;
  v_row       einvoicing.fiscal_chain%rowtype;
  v_rules     text;
begin
  select * into v_doc from public.documents d where d.id = p_document_id;
  if not found or not public.may_know_of_company(v_doc.company_id) then
    raise exception 'unknown_document: document % does not exist', p_document_id
      using errcode = 'P0002';
  end if;
  perform einvoicing.require(v_doc.company_id, 'einvoicing.send', 'chaining a fiscal record');
  if not public.is_installer() and not public.has_capability(v_doc.company_id, 'documents.read') then
    raise exception 'not_allowed: chaining the fiscal record of a document needs documents.read'
      using errcode = '42501';
  end if;

  v_what := v_doc.doc_type || ' ' || coalesce(v_doc.number, v_doc.id::text);
  if v_doc.doc_type not in ('sale_invoice', 'sale_credit_note') then
    raise exception 'document_not_a_sale: % is not a sale invoice or a sale credit note, and a fiscal record is kept by the issuer of a sale',
      v_what;
  end if;
  if v_doc.state <> 'posted' then
    raise exception 'document_not_posted: % is %, and only a posted document has a fiscal record', v_what, v_doc.state;
  end if;

  select d.einvoice_fiscalisation into v_regime
    from public.companies c
    left join public.country_defaults d on d.country = c.fiscal_country
   where c.id = v_doc.company_id;
  if v_regime is null then
    raise exception 'no_fiscalisation_regime: the country pack of this company declares no fiscalisation regime, so % has no fiscal record to chain',
      v_what;
  end if;
  if p_format is distinct from v_regime ->> 'format' then
    raise exception 'fiscal_format_mismatch: the fiscal records of this company are written as %, the format of its country pack, not as %',
      v_regime ->> 'format', coalesce(p_format, 'nothing');
  end if;
  if p_mode is null or not coalesce(v_regime -> 'submission' -> 'modes', '[]'::jsonb) ? p_mode then
    raise exception 'fiscal_mode_not_allowed: a record of this company is sent as one of %, not as %',
      v_regime -> 'submission' -> 'modes', coalesce(p_mode, 'nothing');
  end if;

  -- A record that breaks a rule is not a link: the next one would be chained
  -- to a record the authority refuses.
  if p_violations is null or jsonb_typeof(p_violations) <> 'array' then
    raise exception 'bad_violations: the rules a record breaks are a list, empty when it breaks none';
  end if;
  if jsonb_array_length(p_violations) > 0 then
    select string_agg(coalesce(v ->> 'code', '?') || ': ' || coalesce(v ->> 'message', ''), '; ' order by o)
      into v_rules
      from jsonb_array_elements(p_violations) with ordinality as x(v, o);
    raise exception 'fiscal_record_not_chainable: the fiscal record of % breaks % rule(s) of %, and a record that breaks one is not chained — %. Complete the books it is written from and fiscalise it again.',
      v_what, jsonb_array_length(p_violations), p_format, v_rules;
  end if;

  if p_generated_at is null
     or p_generated_at !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?([+-][0-9]{2}:[0-9]{2}|Z)$' then
    raise exception 'bad_generated_at: a record says when it was generated as ISO 8601 with its offset, 2027-01-04T10:15:00+01:00; got %',
      coalesce(p_generated_at, 'nothing');
  end if;
  if nullif(btrim(p_system_id), '') is null or nullif(btrim(p_number), '') is null
     or nullif(btrim(p_issuer_tax_id), '') is null or p_issued_on is null then
    raise exception 'bad_fiscal_record: a record names its system, its issuer, the number and the date of its invoice';
  end if;

  -- The digest, computed again. The text is the brick's, the algorithm the
  -- pack's: a hash that is not the digest of the text it came with is refused
  -- rather than chained under a fingerprint that is not its own.
  v_algorithm := v_regime -> 'hash' ->> 'algorithm';
  v_encoding := v_regime -> 'hash' ->> 'encoding';
  if einvoicing.fiscal_digest(v_algorithm, v_encoding, p_hash_input) is null then
    raise exception 'fiscal_hash_unknown: the pack names %, a digest this module does not compute', coalesce(v_algorithm, 'no algorithm');
  end if;
  if p_hash is distinct from einvoicing.fiscal_digest(v_algorithm, v_encoding, coalesce(p_hash_input, '')) then
    raise exception 'fiscal_hash_mismatch: the hash given for the fiscal record of % is not the % of the text it was given with',
      v_what, v_algorithm
      using errcode = '23514';
  end if;

  -- Every field the pack says the hash covers is in the record.
  v_fields := coalesce(v_regime -> 'hash' -> 'fields' -> (p_kind::text), v_regime -> 'hash' -> 'fields' -> '*');
  if p_record is null or jsonb_typeof(p_record) <> 'object' then
    raise exception 'bad_fiscal_record: the fields of a record are an object, by name';
  end if;
  if v_fields is not null then
    select string_agg(f, ', ') into v_missing
      from jsonb_array_elements_text(v_fields) f
     where not p_record ? f;
    if v_missing is not null then
      raise exception 'fiscal_record_fields_missing: the pack says the hash of a % record covers %, and this record does not hold %',
        p_kind, v_fields, v_missing;
    end if;
  end if;

  -- One writer per chain at a time: two records cannot take one place.
  perform pg_advisory_xact_lock(hashtextextended('einvoicing:fiscal:' || v_doc.company_id::text || ':' || p_system_id, 0));

  select * into v_tail from einvoicing.fiscal_chain c
   where c.company_id = v_doc.company_id and c.system_id = p_system_id
   order by c.seq desc limit 1;

  if not found then
    if p_previous_hash is not null then
      raise exception 'fiscal_chain_not_first: system % keeps no record for this company yet, so this one is the first and names no previous hash (got %)',
        p_system_id, p_previous_hash
        using errcode = '23514';
    end if;
  else
    -- The tail is intact before anything is chained to it: its own digest,
    -- and its link to the record before it.
    if v_tail.hash is distinct from einvoicing.fiscal_digest(v_tail.hash_algorithm, v_tail.hash_encoding, v_tail.hash_input) then
      raise exception 'fiscal_chain_broken: record % of system % does not carry the digest of its own text; nothing is chained to it. einvoicing.verify_fiscal_chain() says where the chain breaks.',
        v_tail.seq, p_system_id
        using errcode = '55006';
    end if;
    if v_tail.seq > 1 then
      select * into v_before from einvoicing.fiscal_chain c
       where c.company_id = v_doc.company_id and c.system_id = p_system_id and c.seq = v_tail.seq - 1;
      if not found or v_tail.previous_hash is distinct from v_before.hash then
        raise exception 'fiscal_chain_broken: record % of system % is not chained to record %; nothing is chained to it. einvoicing.verify_fiscal_chain() says where the chain breaks.',
          v_tail.seq, p_system_id, v_tail.seq - 1
          using errcode = '55006';
      end if;
    end if;
    if p_previous_hash is distinct from v_tail.hash then
      raise exception 'fiscal_chain_link: the last record of system % is record %, whose hash is %; a new record names it as previous (got %)',
        p_system_id, v_tail.seq, v_tail.hash, coalesce(p_previous_hash, 'none')
        using errcode = '23514';
    end if;
  end if;

  -- An invoice is issued once, and cancelled once it was.
  select c.kind into v_last from einvoicing.fiscal_chain c
   where c.company_id = v_doc.company_id and c.system_id = p_system_id and c.document_id = p_document_id
   order by c.seq desc limit 1;
  if p_kind = 'alta' and v_last = 'alta' then
    raise exception 'fiscal_record_exists: % has its record in system % already; a mistake is corrected by cancelling it first',
      v_what, p_system_id
      using errcode = '55006';
  end if;
  if p_kind = 'anulacion' and v_last is distinct from 'alta' then
    raise exception 'fiscal_nothing_to_cancel: % has no record in system % that is not cancelled already',
      v_what, p_system_id
      using errcode = '55006';
  end if;

  perform set_config('einvoicing.fiscal_append', p_document_id::text, true);
  v_issue := einvoicing.record_issue(p_document_id, p_format, p_brick, p_specification, p_filename, p_media_type,
                                     p_content, p_checksum, p_violations, 'fiscal_record');
  perform set_config('einvoicing.fiscal_append', '', true);

  insert into einvoicing.fiscal_chain
    (company_id, system_id, seq, document_id, kind, format, issuer_tax_id, series, number, issued_on,
     record, hash_input, hash_algorithm, hash_encoding, hash, previous_hash, is_first,
     generated_at, generated_instant, mode, verification_url, issue_id, recorded_by)
  values
    (v_doc.company_id, p_system_id, coalesce(v_tail.seq, 0) + 1, p_document_id, p_kind, p_format,
     p_issuer_tax_id, coalesce(p_series, ''), p_number, p_issued_on,
     p_record, p_hash_input, v_algorithm, v_encoding, p_hash, p_previous_hash, v_tail.seq is null,
     p_generated_at, p_generated_at::timestamptz, p_mode, p_verification_url, v_issue.id, public.acting_user())
  returning * into v_row;

  return v_row;
end;
$$;

comment on function einvoicing.append_fiscal_record(uuid, text, einvoicing.fiscal_record_kind, text, text, text, text, text, date, jsonb, text, text, text, text, text, text, text, text, text, text, text, jsonb) is
  'Chains one fiscal record of a posted sale and keeps its file. Checks the company''s pack declares a regime in this format and mode (no_fiscalisation_regime, fiscal_format_mismatch, fiscal_mode_not_allowed), that the record breaks no rule (fiscal_record_not_chainable), that its hash is the digest the pack names of the text it came with (fiscal_hash_mismatch) and that it holds every field the hash covers (fiscal_record_fields_missing); that the tail of the chain is intact (fiscal_chain_broken) and is the record it names as previous — none for the first (fiscal_chain_not_first, fiscal_chain_link); and that an invoice is recorded once and cancelled once (fiscal_record_exists, fiscal_nothing_to_cancel). Needs einvoicing.send and documents.read.';

-- ---------------------------------------------------------------------------
-- verify_fiscal_chain: walk it both ways
-- ---------------------------------------------------------------------------

create or replace function einvoicing.verify_fiscal_chain(p_company_id uuid, p_system_id text)
returns table (seq integer, record_id uuid, problem text, detail text)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_row       einvoicing.fiscal_chain%rowtype;
  v_expected  integer := 1;
  v_prev_hash text;
  v_count     integer;
  v_target    integer;
begin
  if not public.may_know_of_company(p_company_id) then
    raise exception 'unknown_company: company % does not exist', p_company_id
      using errcode = 'P0002';
  end if;
  perform einvoicing.require(p_company_id, 'einvoicing.read', 'verifying a chain of fiscal records');

  -- Forward, from the first record: the numbering has no hole, the first says
  -- it is the first, each record carries the digest of its own text and names
  -- the hash of the record before it.
  for v_row in
    select * from einvoicing.fiscal_chain c
     where c.company_id = p_company_id and c.system_id = p_system_id
     order by c.seq
  loop
    if v_row.seq <> v_expected then
      return query select v_row.seq, v_row.id, 'sequence_gap'::text,
        format('record %s follows record %s', v_row.seq, v_expected - 1);
      return;
    end if;
    if v_row.seq = 1 and (not v_row.is_first or v_row.previous_hash is not null) then
      return query select v_row.seq, v_row.id, 'first_not_first'::text,
        'the first record names a previous hash'::text;
      return;
    end if;
    if v_row.seq > 1 and v_row.previous_hash is distinct from v_prev_hash then
      return query select v_row.seq, v_row.id, 'link_broken'::text,
        format('names %s as previous, and record %s has %s', coalesce(v_row.previous_hash, 'none'), v_row.seq - 1, v_prev_hash);
      return;
    end if;
    if v_row.hash is distinct from einvoicing.fiscal_digest(v_row.hash_algorithm, v_row.hash_encoding, v_row.hash_input) then
      return query select v_row.seq, v_row.id, 'hash_mismatch'::text,
        format('carries %s, which is not the %s of its text', v_row.hash, v_row.hash_algorithm);
      return;
    end if;
    v_prev_hash := v_row.hash;
    v_expected := v_expected + 1;
  end loop;

  -- Backward, from the tail: each previous hash names exactly one record of
  -- the chain, the one just before, so the chain can be followed back to its
  -- first record without a fork.
  for v_row in
    select * from einvoicing.fiscal_chain c
     where c.company_id = p_company_id and c.system_id = p_system_id
     order by c.seq desc
  loop
    continue when v_row.previous_hash is null;
    select count(*), max(c.seq) into v_count, v_target
      from einvoicing.fiscal_chain c
     where c.company_id = p_company_id and c.system_id = p_system_id and c.hash = v_row.previous_hash;
    if v_count <> 1 or v_target <> v_row.seq - 1 then
      return query select v_row.seq, v_row.id, 'link_unresolved'::text,
        format('names %s as previous, which %s', v_row.previous_hash,
               case when v_count = 0 then 'no record of the chain carries'
                    when v_count > 1 then format('%s records carry', v_count)
                    else format('is record %s, not record %s', v_target, v_row.seq - 1) end);
      return;
    end if;
  end loop;
end;
$$;

comment on function einvoicing.verify_fiscal_chain(uuid, text) is
  'Walks the chain of fiscal records of a company in one system forward — numbering, first record, each digest, each link — then backward from the tail, each previous hash naming exactly the record before. Returns the first break it finds (seq, record_id, problem, detail), or no row when the chain is intact. Needs einvoicing.read.';

-- ---------------------------------------------------------------------------
-- log_fiscal_event
-- ---------------------------------------------------------------------------

create or replace function einvoicing.log_fiscal_event(
  p_company_id uuid,
  p_system_id  text,
  p_kind       text,
  p_detail     jsonb default '{}'::jsonb
)
returns einvoicing.fiscal_events
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row einvoicing.fiscal_events%rowtype;
begin
  if not public.may_know_of_company(p_company_id) then
    raise exception 'unknown_company: company % does not exist', p_company_id
      using errcode = 'P0002';
  end if;
  perform einvoicing.require(p_company_id, 'einvoicing.send', 'recording a fiscal event');
  if p_kind is null or p_kind !~ '^[a-z][a-z0-9_]{0,59}$' then
    raise exception 'bad_fiscal_event: an event is named in lower case, summary or chain_break; got %', coalesce(p_kind, 'nothing');
  end if;
  if nullif(btrim(p_system_id), '') is null then
    raise exception 'bad_fiscal_event: an event names the system it happened in';
  end if;
  if p_detail is not null and jsonb_typeof(p_detail) <> 'object' then
    raise exception 'bad_fiscal_event: the detail of an event is an object';
  end if;

  perform pg_advisory_xact_lock(hashtextextended('einvoicing:fiscal-events:' || p_company_id::text || ':' || p_system_id, 0));
  insert into einvoicing.fiscal_events (company_id, system_id, seq, kind, detail, recorded_by)
  values (p_company_id, p_system_id,
          (select coalesce(max(e.seq), 0) + 1 from einvoicing.fiscal_events e
            where e.company_id = p_company_id and e.system_id = p_system_id),
          p_kind, coalesce(p_detail, '{}'::jsonb), public.acting_user())
  returning * into v_row;
  return v_row;
end;
$$;

comment on function einvoicing.log_fiscal_event(uuid, text, text, jsonb) is
  'Appends one event of an invoicing system to the fiscal events of a company, numbered per system. Needs einvoicing.send.';

-- ---------------------------------------------------------------------------
-- The conventions the socle looks a module up by
-- ---------------------------------------------------------------------------

create or replace function einvoicing.can_disable(p_company_id uuid)
returns text
language sql
stable
as $$
  select case
           when exists (
                select 1 from einvoicing.transmissions t
                 where t.company_id = p_company_id
                   and t.state in ('prepared', 'submitted', 'accepted_by_access_point'))
             then 'an electronic invoice or a fiscal record is on its way, and what comes back would have nowhere to be recorded. Follow it to delivered or rejected first.'
           when exists (
                select 1 from einvoicing.fiscal_chain c
                 where c.company_id = p_company_id
                   and c.mode <> 'none'
                   and not exists (
                         select 1 from einvoicing.transmissions t
                          where t.issue_id = c.issue_id
                            and t.state in ('accepted_by_access_point', 'delivered')))
             then 'a fiscal record of this company has not reached the tax authority, and the law asks for it to be sent. Send it first; turning the module off would leave it behind.'
         end;
$$;

comment on function einvoicing.can_disable(uuid) is
  'Null when the module may be turned off for a company; a sentence while a sending is still on its way, or while a fiscal record that is to be sent has not reached the authority. Turning it off deletes nothing: the files, the chain and the history come back with it.';

create or replace function einvoicing.archive_tables()
returns table (
  table_name  text,
  disposition text,
  reason      text,
  via_column  text,
  via_table   text,
  load_order  integer
)
language sql
immutable
as $$
  values
    ('issues'::text,             'exported'::text, null::text, null::text, null::text, 1),
    ('transmissions',            'exported',       null,       null,       null,       2),
    ('transmission_events',      'exported',       null,       null,       null,       3),
    ('fiscal_chain',             'exported',       null,       null,       null,       4),
    ('fiscal_events',            'exported',       null,       null,       null,       5);
$$;

comment on function einvoicing.archive_tables() is
  'What an archive of one company does with each table of this module: all five travel — the files as they were issued, the sendings and what came back, the chain of fiscal records and its events. Read by `public.company_archive_tables()`.';

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table einvoicing.fiscal_chain  enable row level security;
alter table einvoicing.fiscal_events enable row level security;

create policy einvoicing_fiscal_chain_select on einvoicing.fiscal_chain
  for select using (
    public.module_enabled(company_id, 'einvoicing')
    and public.has_capability(company_id, 'einvoicing.read')
  );
create policy einvoicing_fiscal_events_select on einvoicing.fiscal_events
  for select using (
    public.module_enabled(company_id, 'einvoicing')
    and public.has_capability(company_id, 'einvoicing.read')
  );

-- ---------------------------------------------------------------------------
-- Privileges, by name
-- ---------------------------------------------------------------------------

grant select on table einvoicing.fiscal_chain, einvoicing.fiscal_events to authenticated, service_role;

revoke execute on function einvoicing.fiscal_digest(text, text, text) from public, anon;
revoke execute on function einvoicing.fiscal_regime(uuid) from public, anon;
revoke execute on function einvoicing.record_issue(uuid, text, text, text, text, text, text, text, jsonb, einvoicing.artefact) from public, anon;
revoke execute on function einvoicing.append_fiscal_record(uuid, text, einvoicing.fiscal_record_kind, text, text, text, text, text, date, jsonb, text, text, text, text, text, text, text, text, text, text, text, jsonb) from public, anon;
revoke execute on function einvoicing.verify_fiscal_chain(uuid, text) from public, anon;
revoke execute on function einvoicing.log_fiscal_event(uuid, text, text, jsonb) from public, anon;

grant execute on function einvoicing.fiscal_digest(text, text, text) to authenticated, service_role;
grant execute on function einvoicing.fiscal_regime(uuid) to authenticated, service_role;
grant execute on function einvoicing.record_issue(uuid, text, text, text, text, text, text, text, jsonb, einvoicing.artefact) to authenticated, service_role;
grant execute on function einvoicing.append_fiscal_record(uuid, text, einvoicing.fiscal_record_kind, text, text, text, text, text, date, jsonb, text, text, text, text, text, text, text, text, text, text, text, jsonb) to authenticated, service_role;
grant execute on function einvoicing.verify_fiscal_chain(uuid, text) to authenticated, service_role;
grant execute on function einvoicing.log_fiscal_event(uuid, text, text, jsonb) to authenticated, service_role;

revoke execute on function einvoicing.guard_fiscal() from public, anon, authenticated, service_role;
revoke execute on function einvoicing.guard_transmission() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The registry row
-- ---------------------------------------------------------------------------

update public.modules
   set version            = '1.1.0',
       description        = 'The electronic invoice of a posted sale, in the profile its country pack declares, and the chained fiscal record its pack''s fiscalisation regime requires: the exact files with the rules they break, the chain, and every sending with what the service answered, word for word. Knows no country, names no provider, and writes nothing to the ledger.'
 where code = 'einvoicing';
