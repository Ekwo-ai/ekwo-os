-- Ekwo — the `einvoicing` module: the electronic invoice of a posted sale, and
-- every time it was sent.
--
-- The socle already holds everything an electronic invoice says. A posted
-- sale keeps the category and the rate of each line, the breakdown reads the
-- lines, both parties have an electronic address, and `document_header`,
-- `document_line_items` and `document_tax_summary` publish the lot. The bricks
-- of `packages/formats/` already write the file. What nobody did was the act
-- in between — "issue the e-invoice of this document" — and the memory of it:
-- which file, which rules it broke, when it left, through whom, and what came
-- back. That is this module, and nothing more:
--
--   * **an issue** is one file written for one posted sale, kept as it was
--     written — the exact text, its SHA-256 and every rule of the format it
--     breaks, word for word. The file is produced by a brick, in TypeScript,
--     because that is where the bricks are; the database checks what it can
--     check without trusting the caller: that the document is a posted sale,
--     that the profile is the one the company's country pack declares, and
--     that the checksum is the checksum of the text. The same file twice is
--     one issue.
--   * **a transmission** is one sending of one issue: the channel in two
--     words, the service by name as free text, the reference the service gave,
--     and a state that only moves forward. *A 2xx is not a delivery*: handing a
--     file over is `submitted`, the access point taking it is
--     `accepted_by_access_point`, the buyer's side having it is `delivered`.
--   * **an event** is one answer the service gave, kept in its own words and
--     never rewritten. A refusal summarised is a refusal half-read.
--
-- **The module knows no country.** Which format a company issues in is the
-- `einvoicing.profile` of the pack of its fiscal country, as the socle already
-- compiles it into `country_defaults.einvoice_profile`. There is no pack
-- section of the module's own: the data was there before the module was.
-- Which brick writes which profile is a fact about formats, not countries, and
-- it is the TypeScript side's (`@ekwo-ai/core`, `EINVOICE_FORMATS`); a profile
-- no brick writes is refused there by name, `format_without_brick`.
--
-- **A file that breaks a rule does not leave.** `record_transmission()`
-- refuses an issue whose list of broken rules is not empty and repeats the
-- rules verbatim. The way out is not this module: it is the books — the
-- buyer's electronic address, a due date, an order reference — and a new
-- issue, which is a new row, the old one kept.
--
-- **A rejection is a state one sends again from**, the way `tax_filing_deposits`
-- treats a declaration: a rejected or failed transmission closes, and the next
-- one is a second row of the same document. At most one transmission of a
-- document is ever alive or delivered, and a unique index says so.
--
-- **A posted document is never modified**, with one exception the socle made
-- for exactly this: `documents.peppol_status` and `documents.peppol_message_id`
-- are on the closed list of columns that may still move after posting, and
-- `unpost_document()` reads them to refuse taking back to draft a document that
-- has left. Once a transmission has left — submitted or further — this module
-- writes its state and reference there. The module's tables are the record;
-- the two columns are the socle's signal that the number is in a customer's
-- hands. The names say Peppol, and a profile that travels elsewhere writes
-- them too: renaming them is the socle's to do, not a module's.
--
-- This module posts nothing; its manifest says `"posts": false` and a test
-- holds it to that.

create schema einvoicing;

comment on schema einvoicing is
  'Ekwo module `einvoicing`: the electronic invoice of a posted sale, kept as the exact file with the rules it breaks, and every sending of it with what the service answered, word for word. The format is the profile of the company''s country pack; the module knows no country and posts nothing.';

-- ---------------------------------------------------------------------------
-- Vocabulary
-- ---------------------------------------------------------------------------

create type einvoicing.channel as enum ('self', 'service');

comment on type einvoicing.channel is
  'How a file was sent. self: the company took it where it goes itself — a folder another program reads, an upload on a portal, an e-mail. service: a transmission somebody operates, an access point or a platform, named as free text in `service`. Two words, because the module describes the act and never the provider.';

create type einvoicing.transmission_state as enum (
  'prepared',
  'submitted',
  'accepted_by_access_point',
  'delivered',
  'rejected',
  'failed'
);

comment on type einvoicing.transmission_state is
  'Where one sending stands, in an order that only moves forward. prepared: recorded, not yet handed over. submitted: the transport took the file and gave a reference — a 2xx, which is not a delivery. accepted_by_access_point: the service that carries it validated it and took charge of it. delivered: the receiving side has it. rejected: somebody on the way refused it, in words kept on the event. failed: it never left — the transport could not hand it over. The last three close the transmission; a document is sent again by a new one.';

-- ---------------------------------------------------------------------------
-- Issues: one file, as it was written
-- ---------------------------------------------------------------------------

create table einvoicing.issues (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references public.companies(id) on delete cascade,
  document_id   uuid not null,
  -- 1, 2, 3: a document whose books were completed is issued again, and the
  -- first file is kept beside the second.
  sequence      integer not null,
  profile       text not null,
  brick         text not null,
  specification text,
  filename      text not null,
  media_type    text not null,
  content       text not null,
  byte_size     integer not null,
  checksum      text not null,
  violations    jsonb not null default '[]'::jsonb,
  sendable      boolean not null,
  issued_at     timestamptz not null default now(),
  issued_by     uuid,
  foreign key (document_id, company_id) references public.documents (id, company_id),
  unique (document_id, sequence),
  unique (document_id, checksum),
  constraint einvoicing_issues_checksum_shape check (checksum ~ '^[0-9a-f]{64}$'),
  constraint einvoicing_issues_violations_list check (jsonb_typeof(violations) = 'array'),
  constraint einvoicing_issues_sendable check (sendable = (jsonb_array_length(violations) = 0)),
  constraint einvoicing_issues_size check (byte_size = octet_length(content))
);

comment on table einvoicing.issues is
  'One electronic invoice written for one posted sale: the exact file, its SHA-256, the format it follows and every rule of that format it breaks. Written by einvoicing.record_issue(), never edited and never deleted: what was issued is evidence of what was issued.';
comment on column einvoicing.issues.profile is
  'The e-invoicing profile of the company''s country pack the file was written in — `country_defaults.einvoice_profile` of its fiscal country on the day it was issued.';
comment on column einvoicing.issues.brick is
  'The package of packages/formats/ that wrote the file, by its published name.';
comment on column einvoicing.issues.specification is
  'What the file itself declares it follows — the customization identifier of a UBL file, the guideline of a CII one — as the brick wrote it.';
comment on column einvoicing.issues.content is
  'The file, byte for byte as the brick wrote it, as UTF-8 text. A format that is not text would need a column of its own; none of the bricks this version reads writes one.';
comment on column einvoicing.issues.checksum is
  'SHA-256 of content as UTF-8, in lower-case hexadecimal. Computed again by the database on every insert, so a file that does not match its checksum is refused rather than kept.';
comment on column einvoicing.issues.violations is
  'Every rule of the format the file breaks, as the brick named them: [{"code": "BR-CO-25", "message": "…", "line": "10"}]. Empty is the only state a file is sent in.';
comment on column einvoicing.issues.sendable is
  'Whether the file breaks no rule. Derived from violations, and held to it by a constraint.';

create unique index einvoicing_issues_id_company_idx on einvoicing.issues (id, company_id);
create index einvoicing_issues_company_idx on einvoicing.issues (company_id, issued_at desc);
create index einvoicing_issues_document_company_idx on einvoicing.issues (document_id, company_id);

-- ---------------------------------------------------------------------------
-- Transmissions: one sending, and where it stands
-- ---------------------------------------------------------------------------

create table einvoicing.transmissions (
  id           uuid primary key default gen_random_uuid(),
  company_id   uuid not null references public.companies(id) on delete cascade,
  document_id  uuid not null,
  issue_id     uuid not null,
  -- 1, 2, 3 per document: a rejected sending is sent again, and each is a row.
  sequence     integer not null,
  channel      einvoicing.channel not null,
  -- The name of the service, where one was used. Free text on purpose: the
  -- module records what was used and never holds a list of what may be.
  service      text,
  -- What the service gave back to find this sending again. A provider's
  -- reference does not change once given.
  reference    text,
  state        einvoicing.transmission_state not null default 'prepared',
  state_at     timestamptz not null default now(),
  -- The last words the service said, as they were said. Every answer is an
  -- event; this is the latest one, for a list.
  message      text,
  prepared_at  timestamptz not null default now(),
  prepared_by  uuid,
  foreign key (document_id, company_id) references public.documents (id, company_id),
  foreign key (issue_id, company_id) references einvoicing.issues (id, company_id),
  unique (document_id, sequence),
  constraint einvoicing_transmissions_service_named check (
    channel = 'self' or nullif(btrim(service), '') is not null
  )
);

comment on table einvoicing.transmissions is
  'One sending of one issued file: the channel, the service by name, the reference it gave, and a state that only moves forward. A document rejected on the way is sent again by a second row; at most one of its transmissions is ever alive or delivered.';
comment on column einvoicing.transmissions.service is
  'The name of the transmission service, where one was used — an access point, a platform. Free text: the module records what was used and holds no list of what may be, which is what keeps it uncoupled from any provider.';
comment on column einvoicing.transmissions.reference is
  'What the transport gave back to find this sending again: a message identifier, a tracking number, the path a file was written to. Set once.';
comment on column einvoicing.transmissions.message is
  'What the service said last, in its own words. The full history is einvoicing.transmission_events.';

create unique index einvoicing_transmissions_id_company_idx on einvoicing.transmissions (id, company_id);
create index einvoicing_transmissions_company_idx on einvoicing.transmissions (company_id, prepared_at desc);
create index einvoicing_transmissions_document_company_idx on einvoicing.transmissions (document_id, company_id);
create index einvoicing_transmissions_issue_company_idx on einvoicing.transmissions (issue_id, company_id);

-- A document has at most one sending that is alive or that arrived. Sending
-- it a second time while the first is on its way is how a customer receives
-- the same invoice twice; the database refuses it rather than the client
-- remembering to look.
create unique index einvoicing_transmissions_one_alive_idx on einvoicing.transmissions (document_id)
  where state in ('prepared', 'submitted', 'accepted_by_access_point', 'delivered');

-- ---------------------------------------------------------------------------
-- Events: what came back, in its own words
-- ---------------------------------------------------------------------------

create table einvoicing.transmission_events (
  id              uuid primary key default gen_random_uuid(),
  company_id      uuid not null references public.companies(id) on delete cascade,
  transmission_id uuid not null,
  sequence        integer not null,
  state           einvoicing.transmission_state not null,
  reference       text,
  -- The service's own words, not summarised, not translated.
  message         text,
  -- Whatever structured answer came with them, as it came.
  detail          jsonb,
  -- When the service says it happened, where it says; when it was recorded.
  occurred_at     timestamptz,
  recorded_at     timestamptz not null default now(),
  recorded_by     uuid,
  foreign key (transmission_id, company_id) references einvoicing.transmissions (id, company_id),
  unique (transmission_id, sequence)
);

comment on table einvoicing.transmission_events is
  'Every state a transmission reached, with what the service said at that moment, word for word, and the structured answer as it came. Appended by einvoicing.record_transmission() and einvoicing.record_transmission_outcome(); never edited, never deleted.';
comment on column einvoicing.transmission_events.message is
  'What the service answered, in its own words. Not summarised: a refusal is read to know what to change.';

create index einvoicing_transmission_events_company_idx on einvoicing.transmission_events (company_id);
create index einvoicing_transmission_events_transmission_company_idx
  on einvoicing.transmission_events (transmission_id, company_id);

-- ---------------------------------------------------------------------------
-- The order of the states
-- ---------------------------------------------------------------------------

create or replace function einvoicing.state_rank(p_state einvoicing.transmission_state)
returns integer
language sql
immutable
as $$
  select case p_state
           when 'prepared' then 0
           when 'submitted' then 1
           when 'accepted_by_access_point' then 2
           else 3
         end;
$$;

comment on function einvoicing.state_rank(einvoicing.transmission_state) is
  'How far a sending has gone: prepared 0, submitted 1, accepted_by_access_point 2, and 3 for the three states that close it — delivered, rejected, failed. A state only ever moves to a higher rank.';

create or replace function einvoicing.state_has_left(p_state einvoicing.transmission_state)
returns boolean
language sql
immutable
as $$
  select p_state in ('submitted', 'accepted_by_access_point', 'delivered', 'rejected');
$$;

comment on function einvoicing.state_has_left(einvoicing.transmission_state) is
  'Whether a sending in this state has left the company: everything but prepared and failed. A rejected file left, and somebody on the way read its number.';

-- ---------------------------------------------------------------------------
-- The guards: what was issued and what came back do not move
--
-- Triggers rather than the absence of a grant alone, so the rule holds for
-- the owner of a function as much as for a client — and for a company that
-- arrives by import_company(), whose files are checked against their
-- checksums like any other.
-- ---------------------------------------------------------------------------

create or replace function einvoicing.guard_issue()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    if new.checksum is distinct from encode(sha256(convert_to(new.content, 'UTF8')), 'hex') then
      raise exception 'einvoice_checksum_mismatch: the file % does not have the checksum it was given; it is refused rather than kept under a fingerprint that is not its own',
        new.filename
        using errcode = '23514';
    end if;
    return new;
  end if;
  raise exception 'einvoice_issued: an issued file is evidence of what was issued, and is not %. Issue the document again: the new file is a new row, and this one stays.',
    case tg_op when 'UPDATE' then 'rewritten' else 'deleted' end
    using errcode = '55006';
end;
$$;

comment on function einvoicing.guard_issue() is
  'Checks the SHA-256 of a file as it is inserted, and refuses every update and every delete of an issue: einvoice_issued.';

create trigger einvoicing_issues_guard
  before insert or update or delete on einvoicing.issues
  for each row execute function einvoicing.guard_issue();

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
    if (new.company_id, new.document_id, new.issue_id, new.sequence, new.channel, new.service,
        new.prepared_at, new.prepared_by)
       is distinct from
       (old.company_id, old.document_id, old.issue_id, old.sequence, old.channel, old.service,
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
  'Holds a transmission to what it is: never deleted; its document, file, channel and service fixed; its reference set once; its state only moving forward, and never again once closed; and a reference wherever somebody took the file.';

create trigger einvoicing_transmissions_guard
  before insert or update or delete on einvoicing.transmissions
  for each row execute function einvoicing.guard_transmission();

create or replace function einvoicing.guard_event()
returns trigger
language plpgsql
as $$
begin
  raise exception 'transmission_event_recorded: what a service answered is kept as it was said, and is not %',
    case tg_op when 'UPDATE' then 'rewritten' else 'deleted' end
    using errcode = '55006';
end;
$$;

comment on function einvoicing.guard_event() is
  'Refuses every update and every delete of a transmission event: the history of what came back is appended to, never rewritten.';

create trigger einvoicing_transmission_events_guard
  before update or delete on einvoicing.transmission_events
  for each row execute function einvoicing.guard_event();

-- ---------------------------------------------------------------------------
-- What the module asks before it writes
-- ---------------------------------------------------------------------------

create or replace function einvoicing.require(p_company_id uuid, p_capability text, p_what text)
returns void
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
begin
  if not public.module_is_enabled(p_company_id, 'einvoicing') then
    raise exception 'module_not_enabled: the electronic invoicing module (einvoicing) is not enabled on this company'
      using errcode = '42501';
  end if;
  if not public.is_installer() and not public.has_capability(p_company_id, p_capability) then
    raise exception 'not_allowed: % needs %', p_what, p_capability
      using errcode = '42501';
  end if;
end;
$$;

comment on function einvoicing.require(uuid, text, text) is
  'Raises module_not_enabled when the module is off for the company, and not_allowed when the caller does not hold the capability. The first lines of every function of this module that writes.';

-- ---------------------------------------------------------------------------
-- record_issue: keep the file a brick wrote for a posted sale
-- ---------------------------------------------------------------------------

create or replace function einvoicing.record_issue(
  p_document_id   uuid,
  p_profile       text,
  p_brick         text,
  p_specification text,
  p_filename      text,
  p_media_type    text,
  p_content       text,
  p_checksum      text,
  p_violations    jsonb default '[]'::jsonb
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
    from einvoicing.issues i where i.document_id = p_document_id;

  insert into einvoicing.issues
    (company_id, document_id, sequence, profile, brick, specification, filename, media_type,
     content, byte_size, checksum, violations, sendable, issued_by)
  values
    (v_doc.company_id, p_document_id, v_next, p_profile, p_brick, p_specification, p_filename, p_media_type,
     p_content, octet_length(p_content), lower(p_checksum), p_violations,
     jsonb_array_length(p_violations) = 0, public.acting_user())
  returning * into v_issue;

  return v_issue;
end;
$$;

comment on function einvoicing.record_issue(uuid, text, text, text, text, text, text, text, jsonb) is
  'Keeps the file a brick wrote for a posted sale invoice or credit note, with the rules it breaks. Refuses a document that is not a posted sale (document_not_a_sale, document_not_posted), a company whose pack declares no profile (no_einvoicing_profile), a file written in another profile (einvoice_profile_mismatch) and a checksum that is not the SHA-256 of the text (einvoice_checksum_mismatch). The same file twice returns the first issue. Needs einvoicing.send and documents.read.';

-- ---------------------------------------------------------------------------
-- record_transmission: a sending begins
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

  -- The rules, verbatim. A file that breaks one is the file an access point
  -- refuses, and sending it anyway only moves the refusal further away.
  if not v_issue.sendable then
    select string_agg(
             (v ->> 'code') || coalesce(' (line ' || (v ->> 'line') || ')', '') || ': ' || (v ->> 'message'),
             '; ' order by o)
      into v_rules
      from jsonb_array_elements(v_issue.violations) with ordinality as x(v, o);
    raise exception 'einvoice_not_sendable: the electronic invoice of % breaks % rule(s) of %, and a file that breaks one is not sent — %. Complete the books it is written from and issue it again.',
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
  -- one to send: the newer issue says more, and the customer gets one.
  select max(i.sequence) into v_latest from einvoicing.issues i where i.document_id = v_issue.document_id;
  if v_issue.sequence < v_latest then
    raise exception 'einvoice_superseded: % was issued again since this file (issue % of %); send the latest',
      v_what, v_issue.sequence, v_latest;
  end if;

  select * into v_alive from einvoicing.transmissions t
   where t.document_id = v_issue.document_id
     and t.state in ('prepared', 'submitted', 'accepted_by_access_point', 'delivered')
   limit 1;
  if found then
    raise exception 'einvoice_already_sent: % is % already (transmission %, %), and a customer receives an invoice once. A sending that is rejected or failed is sent again; one on its way is followed with its status.',
      v_what, v_alive.state, v_alive.sequence, coalesce(v_alive.reference, 'no reference yet')
      using errcode = '55006';
  end if;

  select coalesce(max(t.sequence), 0) + 1 into v_next
    from einvoicing.transmissions t where t.document_id = v_issue.document_id;

  insert into einvoicing.transmissions
    (company_id, document_id, issue_id, sequence, channel, service, prepared_by)
  values
    (v_issue.company_id, v_issue.document_id, v_issue.id, v_next, p_channel, nullif(btrim(p_service), ''), public.acting_user())
  returning * into v_row;

  insert into einvoicing.transmission_events
    (company_id, transmission_id, sequence, state, recorded_by)
  values
    (v_row.company_id, v_row.id, 1, 'prepared', public.acting_user());

  return v_row;
end;
$$;

comment on function einvoicing.record_transmission(uuid, einvoicing.channel, text) is
  'Records that an issued file is about to be sent, as prepared: the channel, and the service by name where one is used. Refuses a file that breaks a rule, repeating the rules verbatim (einvoice_not_sendable), an older file of a document issued again since (einvoice_superseded), and a document already on its way or delivered (einvoice_already_sent). Needs einvoicing.send.';

-- ---------------------------------------------------------------------------
-- record_transmission_outcome: what came back
-- ---------------------------------------------------------------------------

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

  -- Asking twice is not an event. A status that has not moved, with nothing
  -- new to say, records nothing and returns the sending as it stands.
  if p_state = v_row.state
     and (p_reference is null or p_reference = v_row.reference)
     and (p_message is null or p_message is not distinct from v_row.message)
     and p_detail is null then
    return v_row;
  end if;

  -- The guard on the table decides what may move — forward only, never once
  -- closed, a reference set once — so the rule is one place for this
  -- function and for anybody holding the table.
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

  -- The socle's signal that the number is in somebody else's hands: the two
  -- columns `unpost_document()` reads before taking a document back to draft.
  -- Written once the file has left, and only then: a state past prepared, and
  -- a reference, which is the proof somebody took it. A file refused at the
  -- door, before anybody gave it one, never reached a customer.
  if einvoicing.state_has_left(v_row.state) and v_row.reference is not null then
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
  'Records what a transport or a service answered about a sending: its new state, its reference where it gave one, and its words verbatim, as one more event. A state only moves forward and a closed sending does not move (transmission_state_backwards, transmission_closed); the same answer twice records nothing. Once the file has left, writes the state and the reference on documents.peppol_status and peppol_message_id, which is what keeps unpost_document() from taking it back to draft. Needs einvoicing.send.';

-- ---------------------------------------------------------------------------
-- The conventions the socle looks a module up by
-- ---------------------------------------------------------------------------

create or replace function einvoicing.can_disable(p_company_id uuid)
returns text
language sql
stable
as $$
  select case when exists (
                select 1 from einvoicing.transmissions t
                 where t.company_id = p_company_id
                   and t.state in ('prepared', 'submitted', 'accepted_by_access_point'))
              then 'an electronic invoice is on its way, and what comes back would have nowhere to be recorded. Follow it to delivered or rejected first.'
         end;
$$;

comment on function einvoicing.can_disable(uuid) is
  'Null when the module may be turned off for a company; a sentence while a sending is still on its way. Turning it off deletes nothing: the files and the history come back with it.';

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
    ('transmission_events',      'exported',       null,       null,       null,       3);
$$;

comment on function einvoicing.archive_tables() is
  'What an archive of one company does with each table of this module: all three travel — the files as they were issued, the sendings and what came back. Read by `public.company_archive_tables()`.';

-- ---------------------------------------------------------------------------
-- Capabilities
--
-- Reading goes to whoever reads the books, client included. Sending is its
-- own word and not posting's: an accountant who books an invoice and the
-- person who lets it leave the company may be two people, and a member who
-- holds documents.post without einvoicing.send books and sends nothing.
-- ---------------------------------------------------------------------------

insert into public.capabilities (code, area, description) values
  ('einvoicing.read', 'einvoicing', 'Read the electronic invoices issued for a company, the rules each file breaks, every sending and what came back.'),
  ('einvoicing.send', 'einvoicing', 'Issue the electronic invoice of a posted sale and send it, and record what the transport answered. A file leaves the company: not the same act as booking it.')
on conflict (code) do update set area = excluded.area, description = excluded.description;

insert into public.role_capabilities (role, capability) values
  ('viewer'::public.member_role,     'einvoicing.read'),
  ('accountant'::public.member_role, 'einvoicing.read'),
  ('accountant'::public.member_role, 'einvoicing.send'),
  ('owner'::public.member_role,      'einvoicing.read'),
  ('owner'::public.member_role,      'einvoicing.send')
on conflict do nothing;

-- The client preset holds what a viewer holds. Its label is read from the
-- catalogue rather than written as a literal, so this file applies on a socle
-- older than the preset.
insert into public.role_capabilities (role, capability)
select e.enumlabel::text::public.member_role, 'einvoicing.read'
  from pg_catalog.pg_enum e
  join pg_catalog.pg_type t on t.oid = e.enumtypid
  join pg_catalog.pg_namespace n on n.oid = t.typnamespace
 where n.nspname = 'public' and t.typname = 'member_role' and e.enumlabel = 'client'
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- Row level security
--
-- Read with einvoicing.read, on a company that holds the module. Written by
-- nobody but the three functions above, which are definer: there is no write
-- policy and no write grant.
-- ---------------------------------------------------------------------------

alter table einvoicing.issues              enable row level security;
alter table einvoicing.transmissions       enable row level security;
alter table einvoicing.transmission_events enable row level security;

create policy einvoicing_issues_select on einvoicing.issues
  for select using (
    public.module_enabled(company_id, 'einvoicing')
    and public.has_capability(company_id, 'einvoicing.read')
  );
create policy einvoicing_transmissions_select on einvoicing.transmissions
  for select using (
    public.module_enabled(company_id, 'einvoicing')
    and public.has_capability(company_id, 'einvoicing.read')
  );
create policy einvoicing_transmission_events_select on einvoicing.transmission_events
  for select using (
    public.module_enabled(company_id, 'einvoicing')
    and public.has_capability(company_id, 'einvoicing.read')
  );

-- ---------------------------------------------------------------------------
-- Privileges, by name
-- ---------------------------------------------------------------------------

grant usage on schema einvoicing to anon, authenticated, service_role;

grant select on table
  einvoicing.issues,
  einvoicing.transmissions,
  einvoicing.transmission_events
to authenticated, service_role;

revoke execute on function einvoicing.state_rank(einvoicing.transmission_state) from public, anon;
revoke execute on function einvoicing.state_has_left(einvoicing.transmission_state) from public, anon;
revoke execute on function einvoicing.require(uuid, text, text) from public, anon;
revoke execute on function einvoicing.record_issue(uuid, text, text, text, text, text, text, text, jsonb) from public, anon;
revoke execute on function einvoicing.record_transmission(uuid, einvoicing.channel, text) from public, anon;
revoke execute on function einvoicing.record_transmission_outcome(uuid, einvoicing.transmission_state, text, text, jsonb, timestamptz) from public, anon;
revoke execute on function einvoicing.can_disable(uuid) from public, anon;
revoke execute on function einvoicing.archive_tables() from public, anon;

grant execute on function einvoicing.state_rank(einvoicing.transmission_state) to authenticated, service_role;
grant execute on function einvoicing.state_has_left(einvoicing.transmission_state) to authenticated, service_role;
grant execute on function einvoicing.require(uuid, text, text) to authenticated, service_role;
grant execute on function einvoicing.record_issue(uuid, text, text, text, text, text, text, text, jsonb) to authenticated, service_role;
grant execute on function einvoicing.record_transmission(uuid, einvoicing.channel, text) to authenticated, service_role;
grant execute on function einvoicing.record_transmission_outcome(uuid, einvoicing.transmission_state, text, text, jsonb, timestamptz) to authenticated, service_role;
grant execute on function einvoicing.can_disable(uuid) to authenticated, service_role;
grant execute on function einvoicing.archive_tables() to authenticated, service_role;

-- The trigger bodies are fired by their tables and called by nobody.
revoke execute on function einvoicing.guard_issue() from public, anon, authenticated, service_role;
revoke execute on function einvoicing.guard_transmission() from public, anon, authenticated, service_role;
revoke execute on function einvoicing.guard_event() from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The registry row
-- ---------------------------------------------------------------------------

insert into public.modules (code, name, description, schema_name, version, status, requires_socle_min)
values (
  'einvoicing',
  'Electronic invoicing',
  'The electronic invoice of a posted sale, in the profile its country pack declares: the exact file with the rules it breaks, and every sending of it with what the service answered, word for word. Knows no country, names no provider, and writes nothing to the ledger.',
  'einvoicing',
  '1.0.0',
  'available',
  '20261007060225'
)
on conflict (code) do update set
  name               = excluded.name,
  description        = excluded.description,
  schema_name        = excluded.schema_name,
  version            = excluded.version,
  status             = excluded.status,
  requires_socle_min = excluded.requires_socle_min;
