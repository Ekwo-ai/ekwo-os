-- Ekwo OS — a declaration that was filed is a row, not a report.
--
-- `vat_return()` recomputes from the ledger every time it is asked. That is
-- right for preparing a return and wrong for having filed one: post an entry
-- into a period that was declared three months ago — a late supplier invoice,
-- a correction, an accountant's adjustment — and the same function now answers
-- different figures than the ones the administration holds. **Nothing in the
-- database says which were the ones sent.**
--
-- That is where a tax audit starts, and it is the first thing this file fixes:
-- filing freezes the figures, box by box, and the freeze is what the file sent
-- is built from and what a later disagreement is measured against.
--
-- Three shapes hold it:
--
--   tax_filings        one row per declaration of a period, with its state
--   tax_filing_boxes   the figures as filed, one row per box
--   filing_drift()     what the ledger would say today against what was sent
--
-- The boxes are rows and not a JSON document on purpose. A box is already an
-- object of this schema — it has a name, a sequence, a legal reference — and a
-- filed return has to be queryable the way everything else is: summed,
-- compared period to period, joined to the form it belongs to. A JSON blob
-- would make the filed figures the only numbers in this database nobody can
-- ask a question about.

create type tax_filing_state as enum (
  'draft', 'ready', 'filed', 'accepted', 'rejected', 'paid', 'superseded'
);

comment on type tax_filing_state is
  'Where a declaration is. draft while it is being prepared, ready when a person has approved the figures, filed once it has gone, accepted or rejected by the administration, paid when the money followed, superseded when a corrective replaced it.';

create table tax_filings (
  id            uuid primary key default gen_random_uuid(),
  company_id    uuid not null references companies(id) on delete cascade,
  -- The form, as the pack names it. No foreign key, for the reason
  -- `company_filing_periods` has none: `tax_report_templates` is keyed on
  -- (country, code) and a company may file the form of a country that is not
  -- its own. A trigger refuses a code no pack carries.
  report_code   text not null,
  period_start  date not null,
  period_end    date not null,
  state         tax_filing_state not null default 'draft',
  due_date      date,
  -- What the administration gave back: a deposit number, a receipt, whatever
  -- the portal calls it. Free text because every administration calls it
  -- something else, and a closed vocabulary here would be an opinion about
  -- portals rather than about accounting.
  reference     text,
  -- When the figures were last computed into this filing. Distinct from
  -- having figures at all: a period where nothing happened produces a
  -- declaration with no lines, and a nil return is a return — most
  -- administrations require it and fine its absence.
  prepared_at   timestamptz,
  filed_at      timestamptz,
  filed_by      uuid,
  -- The filing this one replaces. A corrective never overwrites: what was sent
  -- was sent.
  supersedes_id uuid references tax_filings(id) on delete set null,
  notes         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint tax_filings_period check (period_start <= period_end),
  constraint tax_filings_filed_has_a_date check (
    (state in ('draft', 'ready')) = (filed_at is null)
    or state = 'superseded'
  )
);

comment on table tax_filings is
  'One row per declaration of a period: what was filed, when, under which reference, and in which state. The figures are in tax_filing_boxes and they are frozen — this table exists so that "what did we declare" is a question with an answer.';

comment on column tax_filings.report_code is
  'The form, as the pack names it. A company may file the form of a country that is not its own, which is why this is a code and not a foreign key.';
comment on column tax_filings.supersedes_id is
  'The filing this corrective replaces, which moves to superseded. Nothing is ever overwritten: a declaration that went out stays as it went out.';
comment on column tax_filings.prepared_at is
  'When the figures were last computed into this filing. A declaration with no lines is not an unprepared one: a period where nothing happened is filed nil, and that is an obligation rather than an omission.';
comment on column tax_filings.reference is
  'What the administration gave back — a deposit number, a receipt. Free text: every portal calls it something else.';

create unique index tax_filings_live_period_idx
  on tax_filings (company_id, report_code, period_start, period_end)
  where state <> 'superseded';
create index tax_filings_company_state_idx on tax_filings (company_id, state);
create index tax_filings_due_idx on tax_filings (company_id, due_date);
create index tax_filings_supersedes_idx on tax_filings (supersedes_id);

create trigger tax_filings_set_updated_at
  before update on tax_filings
  for each row execute function set_updated_at();

create table tax_filing_boxes (
  filing_id uuid not null references tax_filings(id) on delete cascade,
  box       text not null,
  amount    numeric(16, 2) not null,
  primary key (filing_id, box)
);

comment on table tax_filing_boxes is
  'The figures as they were filed, one row per box. Frozen at filing and never recomputed: this is what the administration holds.';

create index tax_filing_boxes_box_idx on tax_filing_boxes (box);

alter table tax_filings enable row level security;
alter table tax_filing_boxes enable row level security;

-- ---------------------------------------------------------------------------
-- Who may file
--
-- `entries.read` is not enough and `company.write` is too much. Filing is an
-- act with an outside consequence — an administration receives something in
-- the company's name — and it is exactly the act a company may want to keep
-- for one person while several people keep the books. It sits on the two
-- presets that already carry the other outward acts.
-- ---------------------------------------------------------------------------

insert into capabilities (code, area, description) values
  ('filings.read',  'filings', 'Read the declarations this company has prepared and filed, and their figures.'),
  ('filings.write', 'filings', 'Prepare a declaration, freeze its figures, record that it was filed, accepted, rejected or paid.')
on conflict (code) do nothing;

insert into role_capabilities (role, capability)
select r.role, c.code
  from (values ('owner'::member_role), ('accountant'::member_role)) as r(role),
       (values ('filings.read'), ('filings.write')) as c(code)
on conflict do nothing;

-- Reading is granted more widely than filing: whoever can read the ledger can
-- see what the company declared from it.
insert into role_capabilities (role, capability)
select r.role, 'filings.read'
  from (select distinct role from role_capabilities where capability = 'entries.read') as r
on conflict do nothing;

create policy tax_filings_select on tax_filings
  for select using (has_capability(company_id, 'filings.read'));
create policy tax_filings_write on tax_filings
  for all using (has_capability(company_id, 'filings.write'))
  with check (has_capability(company_id, 'filings.write'));

create policy tax_filing_boxes_select on tax_filing_boxes
  for select using (exists (
    select 1 from tax_filings f
    where f.id = tax_filing_boxes.filing_id
      and has_capability(f.company_id, 'filings.read')));
create policy tax_filing_boxes_write on tax_filing_boxes
  for all using (exists (
    select 1 from tax_filings f
    where f.id = tax_filing_boxes.filing_id
      and has_capability(f.company_id, 'filings.write')))
  with check (exists (
    select 1 from tax_filings f
    where f.id = tax_filing_boxes.filing_id
      and has_capability(f.company_id, 'filings.write')));

comment on policy tax_filings_select on tax_filings is
  'filings.read: what a company declared is not the same secret as what it books, and a bookkeeper reads it without being able to file.';
comment on policy tax_filings_write on tax_filings is
  'filings.write: preparing and filing is an act with an outside consequence, granted apart from keeping the books.';

grant select, insert, update, delete on table tax_filings to authenticated, service_role;
grant select, insert, update, delete on table tax_filing_boxes to authenticated, service_role;

create trigger tax_filings_audit
  after insert or update or delete on tax_filings
  for each row execute function audit_changes('{"company":"company_id","key":["report_code","period_start"]}');

-- A form nobody carries is a typo, and a typo caught at filing time is a
-- declaration filed under the wrong form. Same guard, and same reason, as the
-- one `company_filing_periods` carries on the same column.
create or replace function tax_filings_report_exists()
returns trigger
language plpgsql
as $$
begin
  if not exists (select 1 from tax_report_templates t where t.code = new.report_code) then
    raise exception 'unknown_report_code: no pack in this installation carries the form %',
      new.report_code;
  end if;
  return new;
end;
$$;

revoke execute on function tax_filings_report_exists() from public, anon;

create trigger tax_filings_report_exists
  before insert or update of report_code on tax_filings
  for each row execute function tax_filings_report_exists();

-- A filed declaration's figures are the ones that were filed. Changing them
-- afterwards is the one thing this whole file exists to prevent, so it is
-- refused by the database rather than by a convention.
create or replace function tax_filing_boxes_are_frozen()
returns trigger
language plpgsql
as $$
declare
  v_state tax_filing_state;
begin
  select f.state into v_state
  from tax_filings f
  where f.id = coalesce(new.filing_id, old.filing_id);

  if v_state not in ('draft', 'ready') then
    raise exception 'filing_is_frozen: the figures of a % declaration are what was filed', v_state;
  end if;
  return coalesce(new, old);
end;
$$;

revoke execute on function tax_filing_boxes_are_frozen() from public, anon;

create trigger tax_filing_boxes_are_frozen
  before insert or update or delete on tax_filing_boxes
  for each row execute function tax_filing_boxes_are_frozen();

-- ---------------------------------------------------------------------------
-- prepare_filing
--
-- Reads the declaration the way anybody would, and keeps the answer. Called
-- again on a draft it refreshes: preparing is iterative, and the figures move
-- until somebody says they are ready.
-- ---------------------------------------------------------------------------

create or replace function prepare_filing(
  p_company_id  uuid,
  p_from        date,
  p_to          date,
  p_report_code text default null
)
returns tax_filings
language plpgsql
volatile
security invoker
as $$
declare
  v_code   text;
  v_filing tax_filings;
begin
  v_code := coalesce(p_report_code, periodic_return_code(p_company_id));
  if v_code is null then
    raise exception 'no_report_code: the pack of this company names no periodic return, so say which form this is';
  end if;

  select * into v_filing
  from tax_filings f
  where f.company_id = p_company_id
    and f.report_code = v_code
    and f.period_start = p_from
    and f.period_end = p_to
    and f.state <> 'superseded';

  if found and v_filing.state not in ('draft', 'ready') then
    raise exception 'filing_already_% : % for % to % has gone; a change to it is a corrective',
      v_filing.state, v_code, p_from, p_to;
  end if;

  if not found then
    insert into tax_filings (company_id, report_code, period_start, period_end)
    values (p_company_id, v_code, p_from, p_to)
    returning * into v_filing;
  else
    update tax_filings set state = 'draft' where id = v_filing.id returning * into v_filing;
    delete from tax_filing_boxes where filing_id = v_filing.id;
  end if;

  insert into tax_filing_boxes (filing_id, box, amount)
  select v_filing.id, r.box, r.amount
  from vat_return(p_company_id, p_from, p_to, v_code) r
  where not r.hidden;

  update tax_filings set prepared_at = now() where id = v_filing.id
  returning * into v_filing;

  return v_filing;
end;
$$;

comment on function prepare_filing(uuid, date, date, text) is
  'Computes the declaration and keeps the answer, box by box. Called again on a draft it refreshes; on a declaration that has gone it refuses and says the word for what is needed instead — a corrective.';

revoke execute on function prepare_filing(uuid, date, date, text) from public, anon;
grant execute on function prepare_filing(uuid, date, date, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The transitions
--
-- Functions and not an `update`, for the reason posting is a function: what
-- changes is a state, and the row is one the member may already write. Each
-- refusal says which state the declaration is in, because "not allowed" on a
-- return somebody is trying to file is the least useful sentence a database
-- can produce.
-- ---------------------------------------------------------------------------

create or replace function file_filing(
  p_filing_id uuid,
  p_reference text default null,
  p_filed_at  timestamptz default null
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
  if v_filing.state not in ('draft', 'ready') then
    raise exception 'filing_already_%: this declaration has already gone', v_filing.state;
  end if;

  if v_filing.prepared_at is null then
    raise exception 'filing_not_prepared: compute the figures before filing them';
  end if;

  update tax_filings
     set state     = 'filed',
         reference = coalesce(p_reference, reference),
         filed_at  = coalesce(p_filed_at, now()),
         filed_by  = auth.uid()
   where id = p_filing_id
  returning * into v_filing;
  return v_filing;
end;
$$;

comment on function file_filing(uuid, text, timestamptz) is
  'Records that a declaration has gone, with the reference the administration gave back. It asks that the figures were computed, not that there are any: a period where nothing happened is filed nil. From here the figures are frozen by a trigger, and a change to them is a corrective.';

create or replace function record_filing_outcome(
  p_filing_id uuid,
  p_state     tax_filing_state,
  p_reference text default null
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

  update tax_filings
     set state     = p_state,
         reference = coalesce(p_reference, reference)
   where id = p_filing_id
  returning * into v_filing;
  return v_filing;
end;
$$;

comment on function record_filing_outcome(uuid, tax_filing_state, text) is
  'What came back: accepted, rejected, or paid. Paying follows acceptance, and a declaration that never went cannot come back at all.';

create or replace function supersede_filing(p_filing_id uuid)
returns tax_filings
language plpgsql
volatile
security invoker
as $$
declare
  v_old tax_filings;
  v_new tax_filings;
begin
  select * into v_old from tax_filings f where f.id = p_filing_id;
  if not found then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;
  if v_old.state in ('draft', 'ready') then
    raise exception 'filing_not_sent: a declaration that has not gone is corrected by preparing it again';
  end if;
  if v_old.state = 'superseded' then
    raise exception 'filing_already_superseded: % was already replaced', p_filing_id;
  end if;

  update tax_filings set state = 'superseded' where id = p_filing_id;

  insert into tax_filings (company_id, report_code, period_start, period_end,
                           due_date, supersedes_id)
  values (v_old.company_id, v_old.report_code, v_old.period_start, v_old.period_end,
          v_old.due_date, v_old.id)
  returning * into v_new;

  insert into tax_filing_boxes (filing_id, box, amount)
  select v_new.id, r.box, r.amount
  from vat_return(v_old.company_id, v_old.period_start, v_old.period_end, v_old.report_code) r
  where not r.hidden;

  update tax_filings set prepared_at = now() where id = v_new.id returning * into v_new;

  return v_new;
end;
$$;

comment on function supersede_filing(uuid) is
  'Opens a corrective: the declaration that went becomes superseded and a new draft is prepared from today''s ledger, pointing at it. What was sent stays as it was sent.';

revoke execute on function file_filing(uuid, text, timestamptz) from public, anon;
grant execute on function file_filing(uuid, text, timestamptz) to authenticated, service_role;
revoke execute on function record_filing_outcome(uuid, tax_filing_state, text) from public, anon;
grant execute on function record_filing_outcome(uuid, tax_filing_state, text) to authenticated, service_role;
revoke execute on function supersede_filing(uuid) from public, anon;
grant execute on function supersede_filing(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- filing_drift
--
-- What the ledger would say today, against what was sent. It falls out of the
-- freeze for nothing, and it is the most useful health check this schema has:
-- a figure that moved after filing is either a correction somebody owes the
-- administration, or an entry that landed in the wrong period.
-- ---------------------------------------------------------------------------

create or replace function filing_drift(p_filing_id uuid)
returns table (
  box        text,
  filed      numeric,
  ledger     numeric,
  difference numeric
)
language plpgsql
stable
security invoker
as $$
declare
  v_filing tax_filings;
begin
  select * into v_filing from tax_filings f where f.id = p_filing_id;
  if not found then
    raise exception 'not_found: filing %', p_filing_id using errcode = 'no_data_found';
  end if;

  return query
  with today as (
    select r.box, r.amount
    from vat_return(v_filing.company_id, v_filing.period_start, v_filing.period_end,
                    v_filing.report_code) r
    where not r.hidden
  ),
  filed as (
    select b.box, b.amount from tax_filing_boxes b where b.filing_id = p_filing_id
  )
  select coalesce(f.box, t.box),
         coalesce(f.amount, 0),
         coalesce(t.amount, 0),
         coalesce(t.amount, 0) - coalesce(f.amount, 0)
  from filed f
  full outer join today t on t.box = f.box
  where coalesce(t.amount, 0) <> coalesce(f.amount, 0)
  order by 1;
end;
$$;

comment on function filing_drift(uuid) is
  'Box by box, what the ledger says now against what was filed, for the boxes where the two disagree. Empty is the answer everybody wants; anything else is either a corrective to file or an entry in the wrong period.';

revoke execute on function filing_drift(uuid) from public, anon;
grant execute on function filing_drift(uuid) to authenticated, service_role;

-- The file that was sent and the receipt that came back are attachments, like
-- every other piece: one place where files live, one set of policies, one
-- storage path convention.
alter table attachments drop constraint attachments_entity_type;
alter table attachments add constraint attachments_entity_type check (
  entity_type in ('company', 'contact', 'document', 'entry', 'payment',
                  'bank_statement', 'bank_transaction', 'fiscal_year', 'tax_filing')
);
