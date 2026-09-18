-- Ekwo OS — a box is a number *and* a kind.
--
-- `tax_filing_boxes` was keyed on (filing, box), and that key is wrong. A box
-- number does not identify a figure on every form: the French CA3 prints the
-- base and the tax of the same rate on one line, which is why `vat_return()`
-- has answered with a `kind` beside every box since the day it was written,
-- and why `report_arithmetic` can name `08|base` and `08|tax` apart.
--
-- Freezing that return into a table keyed on the box alone loses the
-- distinction, and it does not lose it quietly: the second row of the same
-- line collides, and preparing a French declaration fails on a unique
-- constraint. A Belgian one does not, because that form prints the two on
-- separate lines — which is exactly how a key that is right in one country and
-- wrong in the next gets written in the first place.
--
-- Found by the test that settles a declaration in the pack that names the
-- account for it, three days after the table landed. Kept here as the third
-- incident this schema carries: **a figure of a declaration is identified by
-- the box and by what the box is holding.**

-- The kind, as the return already gives it: `base`, `tax`, or `total` for a
-- figure the form computes from others.
alter table tax_filing_boxes
  add column if not exists kind text not null default 'tax';

-- What was already frozen, where the form itself answers. A box that exists
-- under one kind only on the form it belongs to is that kind, whatever the
-- default above put there; a box that exists under two could not have been
-- stored twice under the old key, so there is nothing ambiguous left to fix.
update tax_filing_boxes b
   set kind = t.kind
  from tax_filings f
  join tax_report_templates r on r.code = f.report_code
  join tax_report_box_templates t
    on t.country = r.country and t.report_code = r.code
 where b.filing_id = f.id
   and t.box = b.box
   and not exists (
     select 1 from tax_report_box_templates o
      where o.country = t.country and o.report_code = t.report_code
        and o.box = t.box and o.kind <> t.kind
   );

alter table tax_filing_boxes drop constraint tax_filing_boxes_pkey;
alter table tax_filing_boxes add primary key (filing_id, box, kind);

alter table tax_filing_boxes
  add constraint tax_filing_boxes_kind check (kind in ('base', 'tax', 'total'));

comment on column tax_filing_boxes.kind is
  'What this figure is on the form: the base of a rate, the tax on it, or a total the form computes. Part of the key, because a form is free to print a base and a tax on the same line and two of them have to be able to sit there.';

-- ---------------------------------------------------------------------------
-- The three functions that read or write those rows
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

  insert into tax_filing_boxes (filing_id, box, kind, amount)
  select v_filing.id, r.box, r.kind, r.amount
  from vat_return(p_company_id, p_from, p_to, v_code) r
  where not r.hidden;

  update tax_filings set prepared_at = now() where id = v_filing.id
  returning * into v_filing;

  return v_filing;
end;
$$;

comment on function prepare_filing(uuid, date, date, text) is
  'Computes the declaration and keeps the answer, box by box and kind by kind. Called again on a draft it refreshes; on a declaration that has gone it refuses and says the word for what is needed instead — a corrective.';

revoke execute on function prepare_filing(uuid, date, date, text) from public, anon;
grant execute on function prepare_filing(uuid, date, date, text) to authenticated, service_role;

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

  insert into tax_filing_boxes (filing_id, box, kind, amount)
  select v_new.id, r.box, r.kind, r.amount
  from vat_return(v_old.company_id, v_old.period_start, v_old.period_end, v_old.report_code) r
  where not r.hidden;

  update tax_filings set prepared_at = now() where id = v_new.id returning * into v_new;

  return v_new;
end;
$$;

comment on function supersede_filing(uuid) is
  'Opens a corrective: the declaration that went becomes superseded and a new draft is prepared from today''s ledger, pointing at it. What was sent stays as it was sent.';

revoke execute on function supersede_filing(uuid) from public, anon;
grant execute on function supersede_filing(uuid) to authenticated, service_role;

-- The drift is compared on the same key, and answers with it: a line saying
-- box 08 moved, on a form where 08 is a base and a tax, is half an answer.
drop function if exists filing_drift(uuid);

create or replace function filing_drift(p_filing_id uuid)
returns table (
  box        text,
  kind       text,
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
    select r.box, r.kind, r.amount
    from vat_return(v_filing.company_id, v_filing.period_start, v_filing.period_end,
                    v_filing.report_code) r
    where not r.hidden
  ),
  filed as (
    select b.box, b.kind, b.amount from tax_filing_boxes b where b.filing_id = p_filing_id
  )
  select coalesce(f.box, t.box),
         coalesce(f.kind, t.kind),
         coalesce(f.amount, 0),
         coalesce(t.amount, 0),
         coalesce(t.amount, 0) - coalesce(f.amount, 0)
  from filed f
  full outer join today t on t.box = f.box and t.kind = f.kind
  where coalesce(t.amount, 0) <> coalesce(f.amount, 0)
  order by 1, 2;
end;
$$;

comment on function filing_drift(uuid) is
  'Box by box and kind by kind, what the ledger says now against what was filed, for the figures where the two disagree. Empty is the answer everybody wants; anything else is either a corrective to file or an entry in the wrong period.';

revoke execute on function filing_drift(uuid) from public, anon;
grant execute on function filing_drift(uuid) to authenticated, service_role;
