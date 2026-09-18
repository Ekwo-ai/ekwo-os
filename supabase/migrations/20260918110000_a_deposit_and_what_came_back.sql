-- Ekwo OS — a deposit, and what came back.
--
-- Filing was one act with one date: `filed_at`, `reference`, and a state that
-- went `filed` then `accepted` or `rejected`. That is the happy path and it is
-- the only one the schema could describe. A declaration is refused for a
-- malformed file, for a certificate that expired mid-session, for a figure the
-- administration disputes — and then it is **sent again**, which the schema had
-- no way of saying: `file_filing()` refused everything that was not a draft, so
-- a rejected declaration was a dead end whose only exit was a corrective. A
-- corrective replaces a declaration the administration **accepted**. One it
-- never received has nothing to correct.
--
-- So a deposit becomes an object of its own:
--
--   tax_filing_deposits   one row per send, with what came back
--   file_filing()         records a send, and accepts a rejected declaration
--   reopen_filing()       a rejected declaration goes back to draft to be redone
--
-- **Why this is in the open core.** Sending the file is the operated side —
-- credentials, a certificate, a portal session, somebody answerable when a
-- return is late — and it stays in `ee/`, on the same line as the bank. What
-- comes back does not: the deposit number, the acknowledgement, the words the
-- administration used, and the file that was sent are the company's proof that
-- it filed. A company that stops paying for the transmission keeps every one of
-- them, in its own database, under the same policies as the rest of its books.
-- That is the whole argument for installing this.
--
-- The channel is two words and not a list of providers. `portal` is a person
-- uploading the file themselves, which is complete and free and is how most
-- installations will do it; `service` is a transmission held by somebody, whose
-- name is recorded as text. A closed list of providers here would be the
-- coupling this project refuses — one interface, one provider at a time, and
-- the core never knows which.

create type filing_channel as enum ('portal', 'service');

comment on type filing_channel is
  'How a declaration was sent: portal — a person uploaded it themselves — or service, a transmission somebody operates. Two words, because the core describes the act and never the provider.';

create table tax_filing_deposits (
  id           uuid primary key default gen_random_uuid(),
  filing_id    uuid not null references tax_filings(id) on delete cascade,
  -- 1, 2, 3: a rejected declaration is sent again, and each send is a row.
  sequence     integer not null,
  channel      filing_channel not null default 'portal',
  -- The name of the service, where one was used. Free text on purpose: the
  -- core records what was used and never holds a list of what may be.
  service      text,
  sent_at      timestamptz not null default now(),
  sent_by      uuid,
  -- What the administration gave back for **this** send.
  reference    text,
  outcome      tax_filing_state,
  outcome_at   timestamptz,
  -- Its own words. A refusal summarised is a refusal half-read, and the
  -- sentence is what a person needs to know what to change.
  message      text,
  -- The two files of a deposit, where they were kept: what was sent, and the
  -- receipt. Both are rows of `attachments` on this declaration; naming them
  -- here is what tells them apart.
  sent_file_id        uuid references attachments(id) on delete set null,
  acknowledgement_id  uuid references attachments(id) on delete set null,
  created_at   timestamptz not null default now(),
  unique (filing_id, sequence),
  constraint tax_filing_deposits_outcome check (
    outcome is null or outcome in ('accepted', 'rejected', 'paid')
  ),
  constraint tax_filing_deposits_outcome_has_a_date check (
    (outcome is null) = (outcome_at is null)
  )
);

comment on table tax_filing_deposits is
  'One row per send of a declaration, with what came back: the deposit number, the outcome, the administration''s own words, and the two files — what was sent and the receipt. A rejected declaration is sent again, so a declaration has as many deposits as it took.';
comment on column tax_filing_deposits.service is
  'The name of the transmission service, where one was used. Free text: the core records what was used and holds no list of what may be, which is what keeps it uncoupled from any provider.';
comment on column tax_filing_deposits.message is
  'What the administration answered, in its own words. Not summarised: a refusal is read to know what to change.';
comment on column tax_filing_deposits.sent_file_id is
  'The file that was sent, kept as an attachment of this declaration. Keeping it is what makes reopening a rejected declaration lossless — the core makes it possible and cannot impose it.';

create index tax_filing_deposits_filing_idx on tax_filing_deposits (filing_id, sequence desc);
-- The two files, indexed like every other foreign key of this schema: a
-- deleted attachment has to find the deposits that point at it without a scan.
create index tax_filing_deposits_sent_file_idx on tax_filing_deposits (sent_file_id);
create index tax_filing_deposits_acknowledgement_idx on tax_filing_deposits (acknowledgement_id);

alter table tax_filing_deposits enable row level security;

create policy tax_filing_deposits_select on tax_filing_deposits
  for select using (exists (
    select 1 from tax_filings f
    where f.id = tax_filing_deposits.filing_id
      and has_capability(f.company_id, 'filings.read')));
create policy tax_filing_deposits_write on tax_filing_deposits
  for all using (exists (
    select 1 from tax_filings f
    where f.id = tax_filing_deposits.filing_id
      and has_capability(f.company_id, 'filings.write')))
  with check (exists (
    select 1 from tax_filings f
    where f.id = tax_filing_deposits.filing_id
      and has_capability(f.company_id, 'filings.write')));

comment on policy tax_filing_deposits_select on tax_filing_deposits is
  'filings.read: what was sent and what came back is proof of filing, and it is read by whoever reads the declarations.';

grant select, insert, update, delete on table tax_filing_deposits to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- file_filing, which now records the send
--
-- Replaces the three-argument function rather than sitting beside it: two
-- overloads with defaults would make the call everybody writes ambiguous.
-- ---------------------------------------------------------------------------

drop function if exists file_filing(uuid, text, timestamptz);

create or replace function file_filing(
  p_filing_id uuid,
  p_reference text default null,
  p_filed_at  timestamptz default null,
  p_channel   filing_channel default 'portal',
  p_service   text default null
)
returns tax_filings
language plpgsql
volatile
security invoker
as $$
declare
  v_filing tax_filings;
  v_at     timestamptz;
  v_next   integer;
begin
  select * into v_filing from tax_filings f where f.id = p_filing_id;
  if not found then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;

  -- Rejected is a state a declaration is sent again from. It was never
  -- received, so there is nothing to correct and no corrective to open.
  if v_filing.state not in ('draft', 'ready', 'rejected') then
    raise exception 'filing_already_%: this declaration has already gone', v_filing.state;
  end if;

  if v_filing.prepared_at is null then
    raise exception 'filing_not_prepared: compute the figures before filing them';
  end if;

  v_at := coalesce(p_filed_at, now());

  select coalesce(max(d.sequence), 0) + 1 into v_next
    from tax_filing_deposits d where d.filing_id = p_filing_id;

  insert into tax_filing_deposits (filing_id, sequence, channel, service, sent_at, sent_by, reference)
  values (p_filing_id, v_next, p_channel, p_service, v_at, auth.uid(), p_reference);

  update tax_filings
     set state     = 'filed',
         reference = coalesce(p_reference, reference),
         filed_at  = v_at,
         filed_by  = auth.uid()
   where id = p_filing_id
  returning * into v_filing;

  return v_filing;
end;
$$;

comment on function file_filing(uuid, text, timestamptz, filing_channel, text) is
  'Records that a declaration has gone, with the reference the administration gave back, and keeps the send as a row of tax_filing_deposits. It asks that the figures were computed, not that there are any: a period where nothing happened is filed nil. A rejected declaration may be sent again — it was never received — and the second send is a second deposit, not a corrective.';

revoke execute on function file_filing(uuid, text, timestamptz, filing_channel, text) from public, anon;
grant execute on function file_filing(uuid, text, timestamptz, filing_channel, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- record_filing_outcome, which writes on the deposit it answers
-- ---------------------------------------------------------------------------

drop function if exists record_filing_outcome(uuid, tax_filing_state, text);

create or replace function record_filing_outcome(
  p_filing_id uuid,
  p_state     tax_filing_state,
  p_reference text default null,
  p_message   text default null
)
returns tax_filings
language plpgsql
volatile
security invoker
as $$
declare
  v_filing tax_filings;
begin
  select * into v_filing from tax_filings f where f.id = p_filing_id;
  if not found then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;

  if p_state not in ('accepted', 'rejected', 'paid') then
    raise exception 'not_an_outcome: % is not something an administration answers', p_state;
  end if;
  if v_filing.state = 'draft' or v_filing.state = 'ready' then
    raise exception 'filing_not_sent: a declaration that has not gone cannot come back %', p_state;
  end if;
  if p_state = 'paid' and v_filing.state <> 'accepted' then
    raise exception 'filing_not_accepted: paying follows acceptance, and this one is %', v_filing.state;
  end if;

  -- On the last send, because that is the one being answered.
  update tax_filing_deposits d
     set outcome    = p_state,
         outcome_at = now(),
         reference  = coalesce(p_reference, d.reference),
         message    = coalesce(p_message, d.message)
   where d.filing_id = p_filing_id
     and d.sequence = (select max(x.sequence) from tax_filing_deposits x where x.filing_id = p_filing_id);

  update tax_filings
     set state     = p_state,
         reference = coalesce(p_reference, reference)
   where id = p_filing_id
  returning * into v_filing;
  return v_filing;
end;
$$;

comment on function record_filing_outcome(uuid, tax_filing_state, text, text) is
  'What came back: accepted, rejected, or paid, written on the declaration and on the send it answers — with the administration''s own words where it gave any. Paying follows acceptance, and a declaration that never went cannot come back at all.';

revoke execute on function record_filing_outcome(uuid, tax_filing_state, text, text) from public, anon;
grant execute on function record_filing_outcome(uuid, tax_filing_state, text, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- reopen_filing
--
-- A rejection on the substance is not answered by sending the same file again:
-- the figures have to be worked out afresh, and `prepare_filing()` refuses
-- anything that has left draft. So this is the door back, and it opens for one
-- state only.
--
-- It is safe because of the table above: what was sent is a deposit, with its
-- reference, its answer and — where somebody kept it — the file itself. The
-- core cannot force an installation to archive that file; it can make keeping
-- it the thing that makes this lossless, and say so.
-- ---------------------------------------------------------------------------

create or replace function reopen_filing(p_filing_id uuid)
returns tax_filings
language plpgsql
volatile
security invoker
as $$
declare
  v_filing tax_filings;
begin
  select * into v_filing from tax_filings f where f.id = p_filing_id;
  if not found then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;
  if v_filing.state <> 'rejected' then
    raise exception 'filing_not_rejected: a % declaration is not redone, it is superseded by a corrective',
      v_filing.state;
  end if;

  -- The declaration goes back to being prepared. `filed_at` empties with it —
  -- the schema's own rule that a draft carries no filing date — and nothing is
  -- lost, because the send that was refused is a row of tax_filing_deposits.
  update tax_filings
     set state     = 'draft',
         filed_at  = null,
         filed_by  = null,
         reference = null
   where id = p_filing_id
  returning * into v_filing;
  return v_filing;
end;
$$;

comment on function reopen_filing(uuid) is
  'Takes a rejected declaration back to draft so its figures can be worked out again. Only a rejected one: a declaration the administration accepted is replaced by a corrective, never rewritten. What was sent stays in tax_filing_deposits.';

revoke execute on function reopen_filing(uuid) from public, anon;
grant execute on function reopen_filing(uuid) to authenticated, service_role;
