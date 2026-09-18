-- Ekwo OS — a company records one cadence per declaration, not one cadence.
--
-- `20260914163943` gave a company a filing cadence and named the column after
-- the return it was about: `companies.vat_period`. That was one column short of
-- the fact. A company is subject to **several** declarations, and each of them
-- has a cadence of its own that the return's does not decide:
--
--   * the recapitulative statement of intra-Community supplies is monthly in
--     France from the first euro, monthly in Belgium above a threshold that
--     counts goods alone whatever the return's cadence, filed on separately
--     chosen cadences for goods and for services in Luxembourg, and filed with
--     the return in Estonia;
--   * the annual return, where a country files one beside the periodic one, is
--     annual by definition and says nothing about the periodic one;
--   * and a company registered in two countries files each country's form on
--     that country's cadence.
--
-- So `ec_sales_list()` refused no period at all, where `vat_return()` refused
-- one the company does not file on. Borrowing the return's guard would have
-- refused a lawful monthly statement from a quarterly Belgian filer, which is
-- the ordinary case — the statement had no cadence of its own to read, and one
-- column named after one form could not give it one. `docs/international.md`
-- recorded it under *A company records how often it files its return, and that
-- is not how often it files anything else*.
--
-- Three pieces here, and the third is the one that carries the change.
--
--   `tax_report_templates.period_default`  what the **form** is filed on unless
--       the company says otherwise. It moves the proposal from the country to
--       the form, which is where it belongs: a country proposing one cadence
--       could only ever speak about one declaration, and the moment a company
--       records a cadence per form the proposal has to be per form too.
--   `company_filing_periods`               what **this company** files, one row
--       per declaration it is subject to. Absent means not recorded, which is
--       not an error and not a cadence.
--   `companies.vat_period`                 kept, deprecated, and **derived**.
--       See below: it is a mirror of one row of the table and never a second
--       place the fact is decided.
--
-- **Why `companies.vat_period` is kept.** It has been published since v0.3.0:
-- `ekwo status` prints it, `ekwo init` writes it, and an installation's own
-- clients read it over PostgREST. Dropping it would break a reader outside this
-- repository for a column whose value is still exactly right — a company files
-- its periodic return on one cadence, and that is what it says.
--
-- **Why it is not a second truth.** The rule of this repository is one source
-- for one fact, and two writable columns holding one cadence is how they drift.
-- So the table is the source and the column is its mirror, held in step by two
-- triggers that each write only when the other is out of date: a row written
-- for the country's periodic return updates the column, and a write to the
-- column writes the row. That is the shape `20260915200000` used for
-- `declaration_box` and `declaration_boxes`, and it is here for the same
-- reason: a published column stays readable and a writer that knows only the
-- old name still writes the new fact.
--
-- The mirror needs to know **which** of a company's declarations is the one the
-- column is named after, and it finds it the way the rest of the core finds
-- anything about a country: by asking the pack. `periodic_return_code()`
-- returns the code of the form the company's fiscal country files periodically
-- when there is exactly one, and null when there is none or more than one — a
-- country that files two periodic returns at once has no single form the column
-- could mean, and the column then stays where it is while the table carries
-- both. No country is named anywhere in this file.
--
-- **What is not moved.** A company whose installation carries no periodic
-- return form for its country keeps whatever is in the column and gains no row:
-- there is no declaration to name, so there is nothing the value could be
-- recorded against. Nothing is lost and nothing is invented.

-- ---------------------------------------------------------------------------
-- What a form proposes
-- ---------------------------------------------------------------------------
--
-- `country_defaults.vat_period_default` asked the wrong question. It asked what
-- a *country* proposes, and a country proposes nothing: a law proposes a
-- cadence for a form. As long as a pack carried one form the two were the same
-- sentence, and the day a pack carries two the country-level answer cannot say
-- which one it is about.
--
-- It also made a rule out of an accident. `ekwo pack check` let a pack propose
-- a cadence only where its form accepts exactly one, on the reasoning that a
-- form filed on several means the answer depends on a fact about the company —
-- turnover, which is how Belgium, France and Luxembourg all set it. That
-- reasoning is about the *law* and the rule read the *length of a list*, and
-- the two part company: regulation 25(1) of the Value Added Tax Regulations
-- 1995 makes the prescribed accounting period three months for everybody, and a
-- month or a year is something the Commissioners allow or direct on
-- application. A form filed on three cadences whose law gives one default was
-- the case the rule could not express. With the proposal on the form, it can:
-- the form says what it accepts and what it is filed on when nobody has asked
-- for anything else, and `ekwo pack check` only refuses a proposal the form
-- does not accept.

alter table tax_report_templates
  add column if not exists period_default declaration_period;

alter table tax_report_templates
  add constraint tax_report_templates_default_is_offered check (
    period_default is null or period_default = any (periods)
  );

comment on column tax_report_templates.period_default is
  'Cadence this form is filed on unless the company has asked the administration for another, from packs/<cc>/tax_report.json. Null where the law makes the cadence depend on a fact about the company — turnover — because proposing one of several lawful answers there would be choosing a filing deadline for somebody the pack knows nothing about. Set where the law gives one answer to everybody, whatever else the form accepts. Read at install; never read by the return.';

-- What the packs already proposed, moved onto the form it was about. A country
-- default that names a cadence the form does not accept is left behind rather
-- than written into a column that refuses it: `ekwo pack check` has refused
-- that combination since the proposal existed, so there is none to move.
update tax_report_templates t
   set period_default = d.vat_period_default
  from country_defaults d
 where d.country = t.country
   and t.is_periodic_return
   and d.vat_period_default is not null
   and d.vat_period_default = any (t.periods)
   and t.period_default is null;

comment on column country_defaults.vat_period_default is
  'Deprecated by tax_report_templates.period_default, which asks the same question of the form rather than of the country. Kept because it is published and still written by the pack compiler, with the value of the periodic return''s own default; a country that files two periodic returns has two answers and this column can hold one, which is why the form is now the place. Read nothing new from here.';

-- ---------------------------------------------------------------------------
-- Which of a company's declarations the deprecated column is named after
-- ---------------------------------------------------------------------------

create or replace function periodic_return_code(p_company_id uuid)
returns text
language sql
stable
as $$
  select case when count(distinct t.code) = 1 then min(t.code) end
    from companies c
    join tax_report_templates t on t.country = c.fiscal_country
   where c.id = p_company_id
     and t.is_periodic_return;
$$;

comment on function periodic_return_code(uuid) is
  'The code of the periodic return the company''s fiscal country files, when the installation carries exactly one. Null when it carries none — no pack for that country — and null when it carries several, because then no single form is what a column named after "the" return could mean. It is what holds companies.vat_period and company_filing_periods in step, and it names the form by asking the pack rather than by knowing a country.';

revoke execute on function periodic_return_code(uuid) from public, anon;
grant execute on function periodic_return_code(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- What this company files, declaration by declaration
-- ---------------------------------------------------------------------------
--
-- The key is the company and the code of the form, because that is what the
-- fact is: *this company files that declaration every month*. No surrogate
-- identifier — the pair is the natural key, it is the key every reader joins
-- on, and `company_members` and the rest of the schema already key a row of a
-- company on what names it.
--
-- `report_code` carries no foreign key onto `tax_report_templates`, and that is
-- deliberate. The form is keyed on `(country, code)`, a company's fiscal
-- country can change, and a company registered in a second country files that
-- country's form while its own fiscal country is elsewhere — a foreign key on
-- the pair would refuse a lawful row and a foreign key on the code alone does
-- not exist. What replaces it is a trigger that refuses a code no form of this
-- installation carries, which is the typo a foreign key would have caught and
-- nothing more.

create table company_filing_periods (
  company_id  uuid not null references companies(id) on delete cascade,
  report_code text not null,
  period      declaration_period not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  primary key (company_id, report_code),
  constraint company_filing_periods_has_a_report check (length(report_code) > 0)
);

comment on table company_filing_periods is
  'How often this company files each declaration it is subject to: one row per form of tax_report_templates, and no row where nothing has been recorded. A company files its periodic return on one cadence and its recapitulative statement on another, and the second is not derivable from the first in any country read so far.';
comment on column company_filing_periods.report_code is
  'The form, by the code tax_report_templates gives it. Not a foreign key: the form is keyed on (country, code) and a company may file a form of a country that is not its own. A trigger refuses a code no form of this installation carries.';
comment on column company_filing_periods.period is
  'How often this company files that form. Not null: a row that recorded nothing would say the same thing as no row, in a second way.';

create trigger company_filing_periods_set_updated_at
  before update on company_filing_periods
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- A code that names no form is refused, by name
-- ---------------------------------------------------------------------------

create or replace function company_filing_periods_names_a_form()
returns trigger
language plpgsql
as $$
begin
  if not exists (select 1 from tax_report_templates t where t.code = new.report_code) then
    raise exception 'unknown_tax_report: % is not a declaration form of this installation', new.report_code;
  end if;
  return new;
end;
$$;

comment on function company_filing_periods_names_a_form() is
  'Refuses a filing cadence recorded against a form this installation does not carry. Raise, do not warn: a row nothing can resolve is a cadence nobody files on, and the guards that read it would simply never fire.';

revoke execute on function company_filing_periods_names_a_form() from public, anon, authenticated, service_role;

create trigger company_filing_periods_names_a_form
  before insert or update on company_filing_periods
  for each row execute function company_filing_periods_names_a_form();

-- ---------------------------------------------------------------------------
-- Reading one cadence
-- ---------------------------------------------------------------------------

create or replace function filing_period(p_company_id uuid, p_report_code text)
returns declaration_period
language sql
stable
as $$
  select f.period
    from company_filing_periods f
   where f.company_id = p_company_id
     and f.report_code = p_report_code;
$$;

comment on function filing_period(uuid, text) is
  'How often this company files that declaration, or null when it has not been recorded. Null is not a cadence and not an error: the books are kept the same either way, and a guard that reads it refuses nothing.';

revoke execute on function filing_period(uuid, text) from public, anon;
grant execute on function filing_period(uuid, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- What was recorded before, moved onto the declaration it was about
-- ---------------------------------------------------------------------------

insert into company_filing_periods (company_id, report_code, period)
select c.id, periodic_return_code(c.id), c.vat_period
  from companies c
 where c.vat_period is not null
   and periodic_return_code(c.id) is not null
on conflict (company_id, report_code) do nothing;

-- ---------------------------------------------------------------------------
-- The deprecated column, kept in step
-- ---------------------------------------------------------------------------
--
-- Each trigger writes only when the other side is out of date, which is what
-- makes the pair terminate: the second write finds the value already there and
-- changes no row, so no third trigger fires.

create or replace function company_filing_periods_mirror()
returns trigger
language plpgsql
as $$
declare
  v_company uuid;
  v_code    text;
  v_was     text;
  v_return  text;
  v_now     declaration_period;
begin
  -- `old` and `new` are each assigned for two of the three operations, so both
  -- are read in a branch that knows which one this is rather than in one
  -- condition relying on the order an `or` happens to be evaluated in.
  if tg_op = 'DELETE' then
    v_company := old.company_id;
    v_code    := old.report_code;
    v_was     := old.report_code;
  elsif tg_op = 'UPDATE' then
    v_company := new.company_id;
    v_code    := new.report_code;
    v_was     := old.report_code;
  else
    v_company := new.company_id;
    v_code    := new.report_code;
    v_was     := new.report_code;
  end if;

  -- A row about any other declaration says nothing about a column named after
  -- the periodic return. The code the row had is looked at too, so an update
  -- that renames a row away from the return clears the column.
  v_return := periodic_return_code(v_company);
  if v_code is distinct from v_return and v_was is distinct from v_return then
    return null;
  end if;

  v_now := filing_period(v_company, v_return);
  update companies c
     set vat_period = v_now
   where c.id = v_company
     and c.vat_period is distinct from v_now;
  return null;
end;
$$;

comment on function company_filing_periods_mirror() is
  'Writes companies.vat_period from the row that records how often this company files its country''s periodic return. The column is a mirror and never a second decision: it is written here, from the table, and only when the two differ.';

revoke execute on function company_filing_periods_mirror() from public, anon, authenticated, service_role;

create trigger company_filing_periods_mirror
  after insert or update or delete on company_filing_periods
  for each row execute function company_filing_periods_mirror();

create or replace function companies_vat_period_is_a_filing_period()
returns trigger
language plpgsql
as $$
declare
  v_code text;
begin
  -- Nothing moved, so there is nothing to record. `old` is read only in the
  -- branch where it exists.
  if tg_op = 'UPDATE' then
    if new.vat_period is not distinct from old.vat_period then
      return null;
    end if;
  elsif new.vat_period is null then
    return null;
  end if;
  v_code := periodic_return_code(new.id);
  -- Nothing names the declaration this value is about, so there is nothing to
  -- record it against. The column keeps what it was given.
  if v_code is null then
    return null;
  end if;
  if new.vat_period is null then
    delete from company_filing_periods f
     where f.company_id = new.id and f.report_code = v_code;
  else
    insert into company_filing_periods (company_id, report_code, period)
    values (new.id, v_code, new.vat_period)
    on conflict (company_id, report_code) do update
       set period = excluded.period
     where company_filing_periods.period is distinct from excluded.period;
  end if;
  return null;
end;
$$;

comment on function companies_vat_period_is_a_filing_period() is
  'Records a write to the deprecated companies.vat_period as what it is: how often this company files its country''s periodic return. Everything written before this migration named that column and nothing else, and this is what keeps such a writer correct without it learning a table.';

revoke execute on function companies_vat_period_is_a_filing_period() from public, anon, authenticated, service_role;

create trigger companies_vat_period_is_a_filing_period
  after insert or update of vat_period on companies
  for each row execute function companies_vat_period_is_a_filing_period();

comment on column companies.vat_period is
  'Deprecated by company_filing_periods, and derived from it: how often this company files its country''s periodic return, which is one of the several declarations it is subject to. Null means nothing has been recorded, which is not an error and not a cadence. Write the table; this column is written from it, and a write here is recorded there.';

-- ---------------------------------------------------------------------------
-- Who reads and who writes
-- ---------------------------------------------------------------------------
--
-- Reading is reading a company: the same reach as the row this used to be a
-- column of. Writing is `company.write`, which is what governs
-- `companies.vat_period` today, and the two match on purpose — a capability
-- that could write the table and not the column would make the mirror a write
-- that does not take, which is the worst kind.

alter table company_filing_periods enable row level security;

create policy company_filing_periods_select on company_filing_periods
  for select using (is_company_member(company_id));
create policy company_filing_periods_write on company_filing_periods
  for all using (has_capability(company_id, 'company.write'))
  with check (has_capability(company_id, 'company.write'));

comment on policy company_filing_periods_select on company_filing_periods is
  'A member of the company reads how often it files, exactly as they read the company itself.';
comment on policy company_filing_periods_write on company_filing_periods is
  'company.write, the capability that governs the deprecated column this mirrors. Anything narrower would let somebody record a cadence the mirror could not write.';

grant select, insert, update, delete on table company_filing_periods
  to authenticated, service_role;

create trigger company_filing_periods_audit
  after insert or update or delete on company_filing_periods
  for each row execute function audit_changes('{"company":"company_id","key":["report_code"]}');

-- ---------------------------------------------------------------------------
-- The return reads the cadence of the return it was asked for
-- ---------------------------------------------------------------------------
--
-- Replaced whole, because a function is replaced whole in PostgreSQL.
-- Everything but the guard is `20260915200000` unchanged.
--
-- The change is one word wide and it is the whole point of this migration: the
-- cadence read is the one recorded **for the form being asked for**, not the
-- one recorded for the company. A company that files its return quarterly and
-- its recapitulative statement monthly is two rows, and each guard reads its
-- own.

create or replace function vat_return(
  p_company_id  uuid,
  p_from        date,
  p_to          date,
  p_report_code text default null
)
returns table (
  box         text,
  kind        text,
  amount      numeric,
  computed    boolean,
  name        text,
  sequence    integer,
  hidden      boolean,
  report_code text
)
language plpgsql
stable
as $$
declare
  -- 'box|kind' -> amount, for every box summed from the ledger, then the
  -- totals `evaluate_totals()` derives from them. The key carries the kind
  -- because the French CA3 puts a base and a tax on line 08 and a formula has
  -- to be able to name one of them.
  v_values   jsonb := '{}'::jsonb;
  v_formulas jsonb := '[]'::jsonb;
  v_totals   jsonb := '{}'::jsonb;
  v_rows     jsonb := '[]'::jsonb;
  v_country  char(2);
  v_report   text;
  v_in       char(2);
  v_count    integer;
  v_codes    text;
  -- How often this company files, what the form accepts, and what the two
  -- dates asked for actually are.
  v_files    declaration_period;
  v_accepts  declaration_period[];
  v_asked    declaration_period;
  -- A declaration figure is not a ledger figure, but it is written in the
  -- same currency and with the same decimals.
  v_round    money_rounding;
  r          record;
begin
  select c.fiscal_country into v_country
    from companies c where c.id = p_company_id;
  if not found then
    raise exception 'unknown_company: %', p_company_id;
  end if;
  v_round := rounding_of(p_company_id);

  -- Which form. The caller names one, or the country files exactly one on
  -- that date. Two and no name is a question only the caller can answer — a
  -- Canadian company files the federal return and the Québec one at once — so
  -- this asks instead of guessing.
  if p_report_code is not null then
    select t.country, t.code into v_in, v_report
      from tax_report_templates t
     where t.code = p_report_code
       and t.valid_from <= p_to
       and (t.valid_to is null or t.valid_to >= p_to)
     order by t.country
     limit 1;
    if v_report is null then
      raise exception 'unknown_tax_report: % is not a declaration form in force on %',
        p_report_code, p_to;
    end if;
  else
    select count(*), min(t.code), string_agg(t.code, ', ' order by t.code)
      into v_count, v_report, v_codes
      from tax_report_templates t
     where t.country = v_country
       and t.is_periodic_return
       and t.valid_from <= p_to
       and (t.valid_to is null or t.valid_to >= p_to);
    if v_count > 1 then
      raise exception 'ambiguous_tax_report: % files several declarations on % (%); name one',
        v_country, p_to, v_codes;
    end if;
    v_in := v_country;
    if v_count = 0 then
      v_report := null;  -- no pack for this country: the ledger boxes, and no total.
    end if;
  end if;

  -- The period asked for against the one this company files **this form** on.
  -- Four things have to hold before this refuses, and the fourth is what keeps
  -- it out of everybody's way: the company has recorded a cadence for this
  -- declaration, the form is filed on that cadence, the dates are themselves a
  -- whole cadence of that form, and the two are not the same. A fortnight, a
  -- half-year, a form the company has recorded nothing about — none of those is
  -- a filing on the wrong cadence, and none of them is refused.
  if v_report is not null then
    v_files := filing_period(p_company_id, v_report);
    if v_files is not null then
      select t.periods into v_accepts
        from tax_report_templates t
       where t.country = v_in and t.code = v_report;
      v_asked := declaration_period_of(p_from, p_to);
      if v_asked is not null
         and v_files = any(v_accepts)
         and v_asked = any(v_accepts)
         and v_asked <> v_files then
        raise exception
          'wrong_declaration_period: this company files % returns on %; % to % is a %',
          v_files, v_report, p_from, p_to, v_asked;
      end if;
    end if;
  end if;

  -- 1. What the tax postings wrote on the ledger, in every box each of them
  --    names. A line carries the box it is known by; the posting behind it
  --    carries the whole list, which is one box for all but the handful of
  --    forms that print a figure twice. No country rule here either: the
  --    expansion is `unnest`, and which boxes there are is the pack's answer.
  for r in
    with lines as (
      select l.declaration_box as lbox,
             case when l.tax_line then 'tax' else 'base' end as lkind,
             l.tax_id as ltax,
             l.box_amount as lamount
        from entry_lines l
        join entries e on e.id = l.entry_id
       where l.company_id = p_company_id
         and e.state = 'posted'
         and e.entry_date between p_from and p_to
         and l.declaration_box is not null
    ),
    -- The posting that wrote the line: which form it is on, and every box it
    -- prints in. A line with no posting behind it — an entry keyed by hand,
    -- a tax a company wrote itself — is on this form and in the one box it
    -- names, which is what the left join leaves.
    sourced as (
      select ln.lbox, ln.lkind, ln.lamount,
             coalesce(p.boxes, array[ln.lbox]) as lboxes
        from lines ln
        left join lateral (
          select min(tp.report_code) as report_code,
                 array_agg(distinct b.box) as boxes
            from tax_postings tp
            cross join lateral unnest(tp.declaration_boxes) as b(box)
           where tp.tax_id = ln.ltax
             and tp.declaration_box = ln.lbox
             and tp.posting_type = ln.lkind::tax_posting_type
        ) p on true
       -- A box number belongs to one form. A line whose posting names
       -- another form is not on this declaration; one that names none is
       -- the single-return case every European company is in.
       where v_report is null or coalesce(p.report_code, v_report) = v_report
    ),
    ledger as (
      select x.box as lbox, s.lkind,
             round_amount(sum(s.lamount), v_round) as lamount
        from sourced s
        cross join lateral unnest(s.lboxes) as x(box)
       group by 1, 2
      having round_amount(sum(s.lamount), v_round) <> 0
    )
    select g.lbox, g.lkind, g.lamount, b.name as lname,
           b.sequence as lsequence, coalesce(b.hidden, false) as lhidden
      from ledger g
      left join tax_report_box_templates b
        on b.country = v_in and b.report_code = v_report
       and b.box = g.lbox and b.kind = g.lkind
     order by coalesce(b.sequence, 2147483647), g.lbox, g.lkind
  loop
    v_values := v_values || jsonb_build_object(r.lbox || '|' || r.lkind, r.lamount);
    v_rows := v_rows || jsonb_build_array(jsonb_build_object(
      'box', r.lbox, 'kind', r.lkind, 'amount', r.lamount, 'computed', false,
      'name', r.lname, 'sequence', r.lsequence, 'hidden', r.lhidden,
      'report_code', v_report));
  end loop;

  -- 2. The totals of the form, through the evaluator the statements use. A
  --    return prints what it has, so a nil total is left out of the answer —
  --    and kept in the working set, so a later total that names it reads a
  --    zero rather than a gap.
  if v_report is not null then
    select coalesce(jsonb_agg(jsonb_build_object(
             'key', b.box || '|total', 'plus', to_jsonb(b.plus_boxes),
             'minus', to_jsonb(b.minus_boxes), 'floor_zero', b.floor_zero,
             'sequence', b.sequence
           ) order by b.sequence, b.box), '[]'::jsonb)
      into v_formulas
      from tax_report_box_templates b
     where b.country = v_in
       and b.report_code = v_report
       and b.kind = 'total'
       and (b.valid_from is null or b.valid_from <= p_to)
       and (b.valid_to is null or b.valid_to >= p_to);

    v_totals := evaluate_totals(v_values, v_formulas, v_round, false);

    for r in
      select b.box as tbox, b.name as tname, b.sequence as tsequence, b.hidden as thidden
        from tax_report_box_templates b
       where b.country = v_in
         and b.report_code = v_report
         and b.kind = 'total'
         and (b.valid_from is null or b.valid_from <= p_to)
         and (b.valid_to is null or b.valid_to >= p_to)
         and v_totals ? (b.box || '|total')
       order by b.sequence, b.box
    loop
      v_rows := v_rows || jsonb_build_array(jsonb_build_object(
        'box', r.tbox, 'kind', 'total',
        'amount', (v_totals ->> (r.tbox || '|total'))::numeric, 'computed', true,
        'name', r.tname, 'sequence', r.tsequence, 'hidden', r.thidden,
        'report_code', v_report));
    end loop;
  end if;

  return query
  select (x ->> 'box')::text,
         (x ->> 'kind')::text,
         (x ->> 'amount')::numeric,
         (x ->> 'computed')::boolean,
         (x ->> 'name')::text,
         (x ->> 'sequence')::integer,
         (x ->> 'hidden')::boolean,
         (x ->> 'report_code')::text
    from jsonb_array_elements(v_rows) as x;
end;
$$;

comment on function vat_return(uuid, date, date, text) is
  'Declaration boxes for a period: summed from the ledger, then the totals of the country''s form worked out by evaluate_totals(), the same evaluator financial_statement() uses. Refuses a period the company does not file **this form** on, when it has recorded one for it. No country rule lives in this function.';

revoke execute on function vat_return(uuid, date, date, text) from public, anon;
grant execute on function vat_return(uuid, date, date, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- The recapitulative statement gains the same guard
-- ---------------------------------------------------------------------------
--
-- The statement now has somewhere to read its own cadence from, so it can
-- refuse a period the company does not file it on — with the same reticence as
-- the return, and one condition more.
--
-- **It has to be told which declaration it is.** `vat_return()` finds its form
-- from the country, because a periodic return is flagged as one. Nothing flags
-- a recapitulative statement, and no pack of this repository declares one: the
-- pack format carries a single `tax_report.json`, which is the periodic return.
-- So the caller names the form, and a caller that names none is asking for the
-- figures rather than filing — nothing is refused. That is the prudent half of
-- the same principle: refuse only where the refusal is certain.
--
-- The gap that leaves — a country files several declarations and a pack
-- declares one form — is written up in `docs/international.md` rather than
-- patched here. Widening the pack format to a list of forms is a change to
-- every pack and to `ekwo pack check`, and it is not what this migration is.
--
-- The rest of the function is `20260915181500` unchanged.

drop function if exists ec_sales_list(uuid, date, date);

create or replace function ec_sales_list(
  p_company_id  uuid,
  p_from        date,
  p_to          date,
  p_report_code text default null
)
returns table (
  vat_country   char(2),
  vat_number    text,
  nature        text,
  amount        numeric,
  currency_code char(3),
  documents     integer,
  contact_ids   uuid[],
  contact_names text[],
  issue         text
)
language plpgsql
stable
as $$
declare
  v_country  char(2);
  v_prefix   char(2);
  v_currency char(3);
  v_round    money_rounding;
  v_files    declaration_period;
  v_accepts  declaration_period[];
  v_asked    declaration_period;
begin
  select c.fiscal_country, c.currency_code into v_country, v_currency
    from companies c where c.id = p_company_id;
  if not found then
    raise exception 'unknown_company: %', p_company_id;
  end if;
  if not exists (select 1 from territories) then
    raise exception 'no_territories: apply supabase/seed/00_territories.sql';
  end if;

  -- Which period this is, when the caller said which statement they are
  -- filing. Five things have to hold: a form was named, it exists, the company
  -- has recorded a cadence for it, the dates are themselves a whole cadence the
  -- form is filed on, and the two differ. A monthly statement from a quarterly
  -- filer is the ordinary case in three of the four countries read while this
  -- was written, and nothing here touches it: the cadence read is the
  -- statement's own.
  if p_report_code is not null then
    select t.periods into v_accepts
      from tax_report_templates t
     where t.code = p_report_code
       and t.valid_from <= p_to
       and (t.valid_to is null or t.valid_to >= p_to)
     order by t.country
     limit 1;
    if v_accepts is null then
      raise exception 'unknown_tax_report: % is not a declaration form in force on %',
        p_report_code, p_to;
    end if;
    v_files := filing_period(p_company_id, p_report_code);
    v_asked := declaration_period_of(p_from, p_to);
    if v_files is not null
       and v_asked is not null
       and v_files = any(v_accepts)
       and v_asked = any(v_accepts)
       and v_asked <> v_files then
      raise exception
        'wrong_declaration_period: this company files % on %; % to % is a %',
        v_files, p_report_code, p_from, p_to, v_asked;
    end if;
  end if;

  v_prefix := vat_prefix_of(v_country);
  v_round  := rounding_of(p_company_id);

  return query
  with supply as (
    select d.contact_id,
           ct.name                                              as contact_name,
           regexp_replace(t.treatment::text, '^intracom_', '')   as nature,
           upper(regexp_replace(coalesce(ct.vat_number, ''), '[^A-Za-z0-9]', '', 'g')) as vat_raw,
           ct.country                                           as contact_country,
           e.entry_date,
           e.document_id,
           l.credit - l.debit                                   as amount
      from entry_lines l
      join entries  e  on e.id = l.entry_id
      join taxes    t  on t.id = l.tax_id
      left join documents d on d.id = e.document_id
      left join contacts  ct on ct.id = d.contact_id
     where l.company_id = p_company_id
       and e.state = 'posted'
       and e.entry_date between p_from and p_to
       and not l.tax_line
       and t.treatment::text like 'intracom!_%' escape '!'
       and t.treatment::text not like 'intracom!_acquisition!_%' escape '!'
  ),
  keyed as (
    select s.*,
           vat_prefix_of(
             case when s.vat_raw ~ '^[A-Z]{2}' then substring(s.vat_raw from 1 for 2)
                  when s.vat_raw = ''          then null
                  else s.contact_country
             end
           ) as vat_country,
           case when s.vat_raw = ''          then null
                when s.vat_raw ~ '^[A-Z]{2}' then substring(s.vat_raw from 3)
                else s.vat_raw
           end as vat_number
      from supply s
  ),
  scoped as (
    select k.*, eu_vat_scope_of(k.vat_country, k.entry_date) as scope
      from keyed k
  ),
  judged as (
    select s.*,
           case
             when s.contact_id is null                        then 'no_customer'
             when s.vat_number is null or s.vat_number = ''   then 'no_vat_number'
             when s.vat_country is null                       then 'no_vat_country'
             when s.vat_country = v_prefix                    then 'vat_country_is_the_company_country'
             when s.scope = 'none'                            then 'vat_country_outside_the_union'
             when s.scope <> 'full' and s.nature = 'services'
                                                              then 'vat_country_outside_the_union_for_this_supply'
           end as issue
      from scoped s
  )
  select j.vat_country::char(2),
         j.vat_number,
         j.nature,
         round_amount(sum(j.amount), v_round),
         v_currency,
         count(distinct j.document_id)::integer,
         array_agg(distinct j.contact_id)   filter (where j.contact_id is not null),
         array_agg(distinct j.contact_name) filter (where j.contact_name is not null),
         j.issue
    from judged j
   group by j.vat_country, j.vat_number, j.nature, j.issue,
            case when j.issue is not null then j.contact_id end
  having round_amount(sum(j.amount), v_round) <> 0
   order by (j.issue is not null), j.vat_country, j.vat_number, j.nature;
end;
$$;

comment on function ec_sales_list(uuid, date, date, text) is
  'The recapitulative statement of intra-Community supplies for a period: one line per customer VAT identification number and per nature — goods, services, and whatever the treatment vocabulary gains next — summed from the posted ledger in the company''s currency, credit notes deducted. The country of a line is the prefix the customer''s numbers carry, read from `territories`, so a Greek customer is listed under EL. A supply that cannot be declared comes back with the reason in `issue` rather than being left out. Name the form in p_report_code to have the period checked against the cadence this company files **that statement** on, which is not the cadence of its periodic return in any country read so far; name none and nothing is refused. No country rule lives in this function.';

revoke execute on function ec_sales_list(uuid, date, date, text) from public, anon;
grant  execute on function ec_sales_list(uuid, date, date, text) to authenticated, service_role;
