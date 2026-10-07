-- Ekwo OS — a filing, proved by its hash.
--
-- A company files a declaration, deposits its annual accounts, issues a
-- document. Later somebody asks: is this the file that went, and did it exist
-- on that day? The schema already keeps what was sent (`tax_filing_deposits`,
-- `attachments`) and the figures as filed (`tax_filing_boxes`), but everything
-- it keeps is in the company's own database, which the company can rewrite.
-- A proof that the company alone holds proves nothing to a third party.
--
-- A **filing proof** is the answer that does not depend on trusting the
-- company or this installation: the sha256 of the exact bytes of a file,
-- committed to a public ledger that nobody controls, with the proof that it
-- was. Anybody holding the file recomputes the hash, reads the proof, and
-- checks it against the ledger with software of their own choosing.
--
--   filing_proofs              one row per hash and per method
--   record_filing_proof()      a member records a proof that was just made
--   upgrade_filing_proof()     the proof is completed once the ledger anchors it
--   tax_filing_values_sha256() the figures of a declaration, in canonical form
--   filing_proof(sha256)       the public door: given a hash, the proof
--
-- Six decisions, each of them a thing that could have been done otherwise.
--
-- **Only the hash leaves.** The bytes of a declaration never reach a
-- calendar, a chain or anybody else: a sha256 reveals nothing of what it was
-- computed over. What the company publishes is that *some* file existed at a
-- date; what the file says stays where it was.
--
-- **The proof is made outside the database.** Submitting a hash to a public
-- calendar and coming back for the anchor are network calls, and a database
-- function that dials out is a function that hangs a transaction on somebody
-- else's server. The client — the command line, a scheduled job, an
-- application — talks to the calendars and hands the database the bytes it
-- got back. The database keeps them, and refuses what does not fit.
--
-- **The method is a column, and two values exist.** `opentimestamps` is the
-- first one implemented: free, no account, the proof is a small file anybody
-- verifies against Bitcoin block headers. `eas` is the Ethereum Attestation
-- Service, a public attestation signed by an address the company controls;
-- it is reserved here so that a second layer arrives as rows and not as a
-- rewrite (`docs/filing-proofs.md` evaluates it). One file may carry one
-- proof per method.
--
-- **A complete proof does not move.** A pending proof is upgraded as the
-- ledger catches up; once the anchor is recorded the row is frozen. There is
-- no update policy and no delete policy: writes go through two definer
-- functions, each of which checks what a policy would have.
--
-- **`anon` gets one function and not one table**, as for `document_shares`.
-- `filing_proof(sha256)` answers about one hash and nothing else: no company,
-- no subject, no identifier of any row. A hash is 256 bits; whoever presents
-- one already holds the file, and learns only that it was proved and when.
-- A malformed hash and a hash proved by nobody get the same empty answer.
--
-- **The canonical hash is optional and reuses what exists.** The bytes of a
-- file are what a third party holds, so `sha256` is required. The figures of
-- a declaration can also be hashed in the canonical form an archive already
-- uses (`canonical_json()`, one JSON line per row, `20260923110000`), so that
-- a reader with the figures and no file can still match them:
-- `tax_filing_values_sha256()` computes it, and a proof of a declaration
-- records it.

-- ---------------------------------------------------------------------------
-- 1. Vocabulary
-- ---------------------------------------------------------------------------

create type filing_proof_subject as enum ('tax_filing', 'fiscal_year', 'document');

comment on type filing_proof_subject is
  'What a proof is about: a declaration (tax_filings), the annual accounts of a financial year (fiscal_years), or a document. The file proved is any rendering of it — the file sent, the statements deposited, the invoice issued.';

create type filing_proof_method as enum ('opentimestamps', 'eas');

comment on type filing_proof_method is
  'How the hash was committed to a public ledger. opentimestamps: aggregated by public calendars into a Bitcoin transaction, proof verifiable against block headers. eas: an Ethereum Attestation Service attestation, reserved for a second, signed layer and not written by this release.';

create type filing_proof_status as enum ('pending', 'complete');

comment on type filing_proof_status is
  'pending: the hash was submitted and the proof waits for the ledger to anchor it. complete: the anchor is recorded and the row is frozen.';

-- ---------------------------------------------------------------------------
-- 2. The table
-- ---------------------------------------------------------------------------

create table filing_proofs (
  id               uuid primary key default gen_random_uuid(),
  company_id       uuid not null references companies(id) on delete cascade,
  subject_kind     filing_proof_subject not null,
  tax_filing_id    uuid references tax_filings(id) on delete cascade,
  fiscal_year_id   uuid references fiscal_years(id) on delete cascade,
  document_id      uuid references documents(id) on delete cascade,
  -- The stored file whose bytes were hashed, where it is kept here.
  attachment_id    uuid references attachments(id) on delete set null,
  -- sha256 of the exact bytes of the file, hex.
  sha256           text not null,
  -- sha256 of the figures in canonical form, where there are figures.
  values_sha256    text,
  method           filing_proof_method not null,
  status           filing_proof_status not null default 'pending',
  -- The proof itself: a detached .ots file for opentimestamps.
  proof            bytea not null,
  -- Where the hash was submitted: the calendars of an opentimestamps proof.
  calendars        text[],
  anchor_chain     text,
  anchor_height    bigint,
  anchor_time      timestamptz,
  anchor_reference text,
  created_by       uuid,
  created_at       timestamptz not null default now(),
  upgraded_at      timestamptz,
  completed_at     timestamptz,
  constraint filing_proofs_subject_matches_kind check (
    num_nonnulls(tax_filing_id, fiscal_year_id, document_id) = 1
    and (subject_kind = 'tax_filing') = (tax_filing_id is not null)
    and (subject_kind = 'fiscal_year') = (fiscal_year_id is not null)
    and (subject_kind = 'document') = (document_id is not null)
  ),
  constraint filing_proofs_sha256_shape check (sha256 ~ '^[0-9a-f]{64}$'),
  constraint filing_proofs_values_sha256_shape check (values_sha256 is null or values_sha256 ~ '^[0-9a-f]{64}$'),
  constraint filing_proofs_proof_not_empty check (length(proof) > 0),
  constraint filing_proofs_anchor_height check (anchor_height is null or anchor_height >= 0),
  constraint filing_proofs_complete_has_an_anchor check (
    (status = 'complete') = (completed_at is not null)
    and (status = 'pending' or (anchor_chain is not null
                                and (anchor_height is not null or anchor_reference is not null)))
  ),
  constraint filing_proofs_one_per_method unique (company_id, sha256, method)
);

comment on table filing_proofs is
  'Proofs that a file existed at a date: the sha256 of its exact bytes, committed to a public ledger, with the proof that it was. Written through record_filing_proof() and upgrade_filing_proof(); a complete proof is frozen. filing_proof(sha256) is the public way to read one.';
comment on column filing_proofs.sha256 is
  'sha256 of the exact bytes of the file proved, hex. The file itself never leaves: only this hash is submitted.';
comment on column filing_proofs.values_sha256 is
  'sha256 of the figures in canonical form (canonical_json, one line per row), so the figures can be matched without the file. Computed by tax_filing_values_sha256() for a declaration; given by the caller otherwise, or null.';
comment on column filing_proofs.proof is
  'The proof, as bytes: a detached OpenTimestamps file (.ots) for opentimestamps, the signed attestation for eas.';
comment on column filing_proofs.calendars is
  'The calendars an opentimestamps hash was submitted to. Recorded so a scheduled upgrade knows where to come back, and so a reader knows who aggregated it.';
comment on column filing_proofs.anchor_chain is
  'The ledger the proof is anchored in, as its usual name: bitcoin for opentimestamps.';
comment on column filing_proofs.anchor_height is
  'The block height the proof is anchored at, where the ledger has heights.';
comment on column filing_proofs.anchor_time is
  'The time of that block, as its header states it. The proof says the file existed no later than this.';
comment on column filing_proofs.anchor_reference is
  'An identifier on the ledger where a height is not the natural one: the uid of an attestation, a transaction hash.';
comment on column filing_proofs.created_by is
  'auth.users.id of whoever recorded the proof. No foreign key, for the same reason company_members has none.';

create index filing_proofs_company_idx on filing_proofs (company_id, created_at desc);
create index filing_proofs_sha256_idx on filing_proofs (sha256);
create index filing_proofs_pending_idx on filing_proofs (company_id, status) where status = 'pending';
create index filing_proofs_tax_filing_idx on filing_proofs (tax_filing_id);
create index filing_proofs_fiscal_year_idx on filing_proofs (fiscal_year_id);
create index filing_proofs_document_idx on filing_proofs (document_id);
create index filing_proofs_attachment_idx on filing_proofs (attachment_id);

-- ---------------------------------------------------------------------------
-- 3. Proving is its own capability
--
-- `filings.write` would have been close enough to work and wrong to read: a
-- proof is published, and publishing in the company's name on a public ledger
-- is an outward act a company may keep for fewer people than those who
-- prepare a declaration. It sits on the two presets that carry the other
-- outward acts.
-- ---------------------------------------------------------------------------

insert into capabilities (code, area, description) values
  ('filings.prove', 'filings',
   'Commit the hash of a declaration, of annual accounts or of a document to a public ledger, and record the proof.')
on conflict (code) do nothing;

insert into role_capabilities (role, capability)
select r.role, 'filings.prove'
  from (values ('owner'::member_role), ('accountant'::member_role)) as r(role)
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- 4. The figures of a declaration, in canonical form
--
-- One JSON line for the declaration — its form and its period — then one per
-- box and kind, in the order of the box code then the kind, each rendered by
-- `canonical_json()`, the form `values_sha256` of an archive is computed over.
-- A reader with the figures and any JSON parser recomputes it.
-- ---------------------------------------------------------------------------

create or replace function tax_filing_values_sha256(p_filing_id uuid)
returns text
language sql
stable
security invoker
set search_path = public, pg_temp
as $$
  select encode(sha256(convert_to(
           canonical_json(jsonb_build_object(
             'report_code',  f.report_code,
             'period_start', f.period_start,
             'period_end',   f.period_end))::text || E'\n' ||
           coalesce((
             select string_agg(canonical_json(jsonb_build_object('box', b.box, 'kind', b.kind, 'amount', b.amount))::text || E'\n',
                               '' order by b.box, b.kind)
               from tax_filing_boxes b
              where b.filing_id = f.id), ''),
         'UTF8')), 'hex')
    from tax_filings f
   where f.id = p_filing_id
     and f.prepared_at is not null;
$$;

comment on function tax_filing_values_sha256(uuid) is
  'sha256 of the figures of a declaration in canonical form: one canonical_json() line for {report_code, period_start, period_end}, then one per box {box, kind, amount} in box then kind order. Null for a declaration whose figures were never computed, or that the caller may not read.';

-- ---------------------------------------------------------------------------
-- 5. Recording a proof
--
-- Definer: no client inserts into the table. The company is the subject's,
-- never the caller's word; the hash is checked for its shape; the same bytes
-- proved twice by the same method are one proof, returned again rather than
-- refused, so a client that retries after a timeout does not have to know
-- whether the first call landed.
-- ---------------------------------------------------------------------------

create or replace function record_filing_proof(
  p_subject_kind  filing_proof_subject,
  p_subject_id    uuid,
  p_sha256        text,
  p_method        filing_proof_method,
  p_proof_base64  text,
  p_calendars     jsonb default null,
  p_attachment_id uuid default null,
  p_values_sha256 text default null
)
returns filing_proofs
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_company  uuid;
  v_proof    bytea;
  v_sha256   text := lower(coalesce(p_sha256, ''));
  v_values   text := lower(p_values_sha256);
  v_existing filing_proofs%rowtype;
  v_row      filing_proofs%rowtype;
begin
  if p_subject_kind = 'tax_filing' then
    select f.company_id into v_company from tax_filings f where f.id = p_subject_id;
  elsif p_subject_kind = 'fiscal_year' then
    select y.company_id into v_company from fiscal_years y where y.id = p_subject_id;
  elsif p_subject_kind = 'document' then
    select d.company_id into v_company from documents d where d.id = p_subject_id;
  end if;

  if v_company is null or not may_know_of_company(v_company) then
    raise exception 'unknown_subject: no % with id %', p_subject_kind, p_subject_id;
  end if;

  if not is_installer() and not has_capability(v_company, 'filings.prove') then
    raise exception 'not_allowed: recording a proof for this company needs filings.prove'
      using errcode = '42501';
  end if;

  if v_sha256 !~ '^[0-9a-f]{64}$' then
    raise exception 'bad_sha256: a sha256 is 64 hexadecimal characters, got "%"', p_sha256;
  end if;
  if v_values is not null and v_values !~ '^[0-9a-f]{64}$' then
    raise exception 'bad_sha256: values_sha256 is 64 hexadecimal characters, got "%"', p_values_sha256;
  end if;

  begin
    v_proof := decode(coalesce(p_proof_base64, ''), 'base64');
  exception when others then
    raise exception 'bad_proof: the proof is not base64';
  end;
  if length(v_proof) = 0 then
    raise exception 'bad_proof: the proof is empty';
  end if;

  if p_calendars is not null and (jsonb_typeof(p_calendars) <> 'array' or exists (
    select 1 from jsonb_array_elements(p_calendars) e where jsonb_typeof(e) <> 'string'
  )) then
    raise exception 'bad_calendars: the calendars are a JSON array of addresses';
  end if;

  if p_attachment_id is not null and not exists (
    select 1 from attachments a where a.id = p_attachment_id and a.company_id = v_company
  ) then
    raise exception 'unknown_attachment: no attachment % in the company of that %', p_attachment_id, p_subject_kind;
  end if;

  -- The figures of a declaration are derived, never taken from the caller:
  -- a hash that could disagree with the boxes would one day.
  if p_subject_kind = 'tax_filing' then
    v_values := tax_filing_values_sha256(p_subject_id);
  end if;

  select * into v_existing
    from filing_proofs fp
   where fp.company_id = v_company and fp.sha256 = v_sha256 and fp.method = p_method;
  if v_existing.id is not null then
    if v_existing.subject_kind = p_subject_kind
       and coalesce(v_existing.tax_filing_id, v_existing.fiscal_year_id, v_existing.document_id) = p_subject_id then
      return v_existing;
    end if;
    raise exception 'proof_already_recorded: these bytes are already proved by % for another % of this company',
      p_method, v_existing.subject_kind;
  end if;

  insert into filing_proofs (company_id, subject_kind, tax_filing_id, fiscal_year_id, document_id,
                             attachment_id, sha256, values_sha256, method, proof, calendars, created_by)
  values (v_company, p_subject_kind,
          case when p_subject_kind = 'tax_filing' then p_subject_id end,
          case when p_subject_kind = 'fiscal_year' then p_subject_id end,
          case when p_subject_kind = 'document' then p_subject_id end,
          p_attachment_id, v_sha256, v_values, p_method, v_proof,
          case when p_calendars is not null
               then array(select jsonb_array_elements_text(p_calendars)) end,
          acting_user())
  returning * into v_row;

  perform audit_record(
    v_company, 'filing_proofs', v_row.id, v_row.sha256, 'insert', 'filing_proof_recorded',
    null,
    jsonb_build_object('subject_kind', p_subject_kind, 'subject_id', p_subject_id,
                       'method', p_method, 'sha256', v_row.sha256));

  return v_row;
end;
$$;

comment on function record_filing_proof(filing_proof_subject, uuid, text, filing_proof_method, text, jsonb, uuid, text) is
  'Records the proof a client just obtained for the sha256 of a file about a declaration, annual accounts or a document. Needs filings.prove. The proof is given as base64, the calendars as a JSON array. The same bytes recorded again by the same method return the existing row; for a declaration, values_sha256 is computed from its boxes and never taken from the caller.';

-- ---------------------------------------------------------------------------
-- 6. Upgrading a proof
--
-- A calendar answers with a pending proof; hours later it can return the
-- path to a Bitcoin block. The client fetches it and hands the database the
-- longer proof. With an anchor the row becomes complete, and nothing moves
-- after that.
-- ---------------------------------------------------------------------------

create or replace function upgrade_filing_proof(
  p_proof_id         uuid,
  p_proof_base64     text,
  p_anchor_chain     text default null,
  p_anchor_height    bigint default null,
  p_anchor_time      timestamptz default null,
  p_anchor_reference text default null
)
returns filing_proofs
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row   filing_proofs%rowtype;
  v_proof bytea;
begin
  select * into v_row from filing_proofs where id = p_proof_id;
  if v_row.id is null or not may_know_of_company(v_row.company_id) then
    raise exception 'unknown_proof: no proof with that id';
  end if;

  if not is_installer() and not has_capability(v_row.company_id, 'filings.prove') then
    raise exception 'not_allowed: upgrading a proof of this company needs filings.prove'
      using errcode = '42501';
  end if;

  if v_row.status = 'complete' then
    raise exception 'proof_complete: that proof is anchored and does not move';
  end if;

  begin
    v_proof := decode(coalesce(p_proof_base64, ''), 'base64');
  exception when others then
    raise exception 'bad_proof: the proof is not base64';
  end;
  if length(v_proof) = 0 then
    raise exception 'bad_proof: the proof is empty';
  end if;

  if p_anchor_chain is not null and p_anchor_height is null and p_anchor_reference is null then
    raise exception 'anchor_incomplete: an anchor names a block height or a reference on %', p_anchor_chain;
  end if;
  if p_anchor_chain is null and (p_anchor_height is not null or p_anchor_time is not null or p_anchor_reference is not null) then
    raise exception 'anchor_incomplete: an anchor names the ledger it is on';
  end if;

  update filing_proofs
     set proof            = v_proof,
         upgraded_at      = now(),
         anchor_chain     = p_anchor_chain,
         anchor_height    = p_anchor_height,
         anchor_time      = p_anchor_time,
         anchor_reference = p_anchor_reference,
         status           = case when p_anchor_chain is null then 'pending' else 'complete' end::filing_proof_status,
         completed_at     = case when p_anchor_chain is null then null else now() end
   where id = p_proof_id
  returning * into v_row;

  if v_row.status = 'complete' then
    perform audit_record(
      v_row.company_id, 'filing_proofs', v_row.id, v_row.sha256, 'update', 'filing_proof_anchored',
      null,
      jsonb_build_object('anchor_chain', v_row.anchor_chain, 'anchor_height', v_row.anchor_height,
                         'anchor_time', v_row.anchor_time, 'anchor_reference', v_row.anchor_reference));
  end if;

  return v_row;
end;
$$;

comment on function upgrade_filing_proof(uuid, text, text, bigint, timestamptz, text) is
  'Replaces the bytes of a pending proof with the longer proof a calendar returned. With an anchor — the ledger, and a block height or a reference — the proof becomes complete and is frozen. Needs filings.prove.';

-- ---------------------------------------------------------------------------
-- 7. The public door
--
-- Given a hash, every proof of it, one row per method: status, anchor, and
-- the proof as base64, which is all a verifier needs. Nothing about who
-- proved it or what it is about. No row — the same empty answer — for a
-- malformed hash and for a hash nobody proved. Rows rather than one jsonb, so
-- PostgREST and a direct connection hand a client the same shape. Base64
-- without line breaks: `encode()` wraps at 76 characters.
-- ---------------------------------------------------------------------------

create or replace function filing_proof(p_sha256 text)
returns table (
  sha256           text,
  method           filing_proof_method,
  status           filing_proof_status,
  anchor_chain     text,
  anchor_height    bigint,
  anchor_time      timestamptz,
  anchor_reference text,
  recorded_at      timestamptz,
  completed_at     timestamptz,
  proof_base64     text
)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select fp.sha256, fp.method, fp.status, fp.anchor_chain, fp.anchor_height, fp.anchor_time,
         fp.anchor_reference, fp.created_at, fp.completed_at,
         translate(encode(fp.proof, 'base64'), E'\n', '')
    from filing_proofs fp
   where fp.sha256 = lower(p_sha256)
     and lower(p_sha256) ~ '^[0-9a-f]{64}$'
   order by fp.method, fp.created_at;
$$;

comment on function filing_proof(text) is
  'The public way to read a proof: given the sha256 of a file, one row per proof recorded for it — method, status, anchor and the proof bytes as base64 — and nothing about who proved it or what it is about. No row, the same empty answer, for a malformed hash and for a hash nobody proved.';

-- ---------------------------------------------------------------------------
-- 8. Row level security
--
-- Reading the proofs of a company is reading its filings. Nothing writes the
-- table through the API: the two functions above are the only way in.
-- ---------------------------------------------------------------------------

alter table filing_proofs enable row level security;

create policy filing_proofs_select on filing_proofs
  for select using (company_id = any (companies_with_capability('filings.read')));

comment on policy filing_proofs_select on filing_proofs is
  'Anyone who may read the declarations of the company may read the proofs recorded for it. Writes go through record_filing_proof() and upgrade_filing_proof().';

-- ---------------------------------------------------------------------------
-- 9. A company leaves with its proofs
--
-- A proof is about the company's own files and is verified against a public
-- ledger, not against this installation: it means the same thing anywhere.
-- ---------------------------------------------------------------------------

insert into company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('filing_proofs', 'exported', 64, null, null,
   'The proofs that the files of the company existed at a date. Verified against a public ledger, so they mean the same thing in any installation.')
on conflict (table_schema, table_name) do nothing;

-- ---------------------------------------------------------------------------
-- 10. Grants
-- ---------------------------------------------------------------------------

revoke execute on all functions in schema public from public;

grant select on table filing_proofs to authenticated, service_role;

revoke execute on function tax_filing_values_sha256(uuid) from public, anon;
grant execute on function tax_filing_values_sha256(uuid) to authenticated, service_role;

revoke execute on function record_filing_proof(filing_proof_subject, uuid, text, filing_proof_method, text, jsonb, uuid, text) from public, anon;
grant execute on function record_filing_proof(filing_proof_subject, uuid, text, filing_proof_method, text, jsonb, uuid, text) to authenticated, service_role;

revoke execute on function upgrade_filing_proof(uuid, text, text, bigint, timestamptz, text) from public, anon;
grant execute on function upgrade_filing_proof(uuid, text, text, bigint, timestamptz, text) to authenticated, service_role;

revoke execute on function filing_proof(text) from public;
grant execute on function filing_proof(text) to anon, authenticated, service_role;
