-- Ekwo OS — a company files under a VAT scheme.
--
-- A pack has carried declaration forms and a company has recorded how often
-- it files each of them (`company_filing_periods`). What nothing recorded was
-- the fact that decides **which forms a company files at all**: its VAT
-- scheme. Most countries have more than one. A normal scheme, with a monthly
-- or quarterly return. A simplified one, with one annual return and payments
-- on account during the year. And a small business exemption, under which the
-- company charges no VAT, recovers none and files no periodic return. A
-- company on the simplified scheme handed a monthly return to fill was the
-- ordinary case, and nothing could refuse it.
--
-- Everything here is additive, and a company that records no scheme keeps
-- exactly the behaviour it had. No country is named.
--
--   * A form says what it is (`tax_report_templates.role`) and, where it
--     restates another form's figures — an annual return over the boxes of the
--     monthly one — whose postings it reads (`reads_postings_of`); each of its
--     boxes says which boxes of that form it adds up (`from_boxes`), or that
--     it holds the payments on account of the declaration (`reads`).
--   * `vat_schemes`, `vat_scheme_forms`, `vat_scheme_ceilings` and
--     `vat_scheme_instalments` are reference data compiled from a pack's
--     `vat_schemes.json`: the forms filed under each scheme and on which
--     cadences, whether VAT is charged, ceilings with their currency and their
--     article, and a schedule of instalments.
--   * `company_vat_schemes` is the company's own statement: this scheme from
--     the first day of this financial year. No default and no guess.
--   * The filing periods follow the scheme. Recording a scheme writes the rows
--     of `company_filing_periods` it implies and removes those of forms it
--     does not file; a row the scheme does not allow is refused. The table
--     stays the one place a cadence is written; the scheme checks it.
--   * `vat_return()` refuses, by name, a form the company's scheme does not
--     file and a cadence it does not file it on; asked for no form, it takes
--     the one the scheme files.
--   * Under a scheme that charges no VAT, a sale carrying VAT is refused at
--     posting, and the mention the pack declares with `applies_when`
--     `small_business` is printed — a condition the views could not resolve
--     until a company could say it was on such a scheme.
--   * `declaration_instalments` records what was paid on account of a
--     declaration; `instalment_plan()` says what was due, from the box of the
--     previous year's return the pack names; an annual return deducts either
--     in the box that reads it.
--   * `upcoming_filings()` and `portfolio_upcoming_filings()` list the
--     instalments beside the returns, in a column of their own, and stop
--     listing a form the scheme does not file.
--   * `vat_scheme_ceilings_crossed()` compares the books of a year with the
--     ceilings of the company's scheme. An alert: nothing changes a scheme by
--     itself.

-- ---------------------------------------------------------------------------
-- 1. What a form is, and where its figures come from
-- ---------------------------------------------------------------------------

alter table tax_report_templates
  add column if not exists role text,
  add column if not exists reads_postings_of text;

alter table tax_report_templates
  add constraint tax_report_templates_role check (role in ('periodic', 'annual')),
  add constraint tax_report_templates_role_is_periodic check (role is null or (role = 'periodic') = is_periodic_return),
  add constraint tax_report_templates_reads_another check (reads_postings_of is null or reads_postings_of <> code);

comment on column tax_report_templates.role is
  'What the form is to the companies that file it, from packs/<cc>/tax_report.json: periodic, the return the tax postings are for, or annual, a return filed once a year beside it or instead of it under a scheme that says so. Null where the pack carries one form and says nothing, which is_periodic_return already answers; when set it agrees with is_periodic_return.';
comment on column tax_report_templates.reads_postings_of is
  'The form of the same country whose postings this one adds up, for a form that restates on lines of its own what another form''s boxes received — an annual return over the boxes of the monthly one. Null: the form reads the postings made for it. Each box then names the boxes it adds up in from_boxes.';

alter table tax_report_box_templates
  add column if not exists from_boxes text[] not null default '{}'::text[],
  add column if not exists reads text;

alter table tax_report_box_templates
  add constraint tax_report_box_templates_reads check (reads in ('instalments_paid', 'instalments_due')),
  add constraint tax_report_box_templates_one_source check (
    kind <> 'total' or (cardinality(from_boxes) = 0 and reads is null)
  ),
  add constraint tax_report_box_templates_from_or_reads check (cardinality(from_boxes) = 0 or reads is null);

comment on column tax_report_box_templates.from_boxes is
  'On a form that reads the postings of another (tax_report_templates.reads_postings_of): the boxes of that form this base or tax box adds up, as the pack writes them — "08:base", or bare for every kind of the box. Empty on every box of a form that reads its own postings.';
comment on column tax_report_box_templates.reads is
  'A tax box whose figure is the payments on account of this declaration rather than the ledger: instalments_paid, what declaration_instalments records as paid for the period; instalments_due, what instalment_plan() says was due, or what was paid where that is more. Null on every box summed from the ledger or computed.';

-- ---------------------------------------------------------------------------
-- 2. What a country says: its schemes
-- ---------------------------------------------------------------------------

create table if not exists vat_schemes (
  country         char(2) not null,
  code            text    not null,
  name            text    not null,
  -- False under a small business exemption.
  charges_vat     boolean not null default true,
  legal_reference text    not null,
  source_key      text,
  sequence        integer not null default 10,
  primary key (country, code),
  constraint vat_schemes_country_format check (country ~ '^[A-Z]{2}$')
);

comment on table vat_schemes is
  'The VAT schemes of a country, compiled from packs/<cc>/vat_schemes.json: the fact that decides which declaration forms a company files at all. A country with no row has no scheme, and its companies file as they always did.';
comment on column vat_schemes.charges_vat is
  'False under a small business exemption: a company on the scheme charges no VAT on its sales, which are refused at posting if they carry any, recovers none, and its invoices carry the mention of legal_mention_templates whose applies_when is small_business.';

alter table vat_schemes enable row level security;
create policy vat_schemes_select on vat_schemes for select using (is_known_caller());
comment on policy vat_schemes_select on vat_schemes is
  'Reference data of the packs, read by anybody signed in, as tax_report_templates is.';
grant select on table vat_schemes to authenticated, service_role;

create table if not exists vat_scheme_forms (
  country        char(2) not null,
  scheme_code    text    not null,
  report_code    text    not null,
  periods        declaration_period[] not null,
  period_default declaration_period,
  primary key (country, scheme_code, report_code),
  foreign key (country, scheme_code) references vat_schemes (country, code) on delete cascade,
  constraint vat_scheme_forms_periods check (cardinality(periods) >= 1),
  constraint vat_scheme_forms_default_is_offered check (period_default is null or period_default = any (periods))
);

comment on table vat_scheme_forms is
  'The declaration forms a company on a scheme files, each on the cadences the scheme allows. A form of the country that no scheme names is outside every scheme and is filed as before; a form some scheme names is filed only under the schemes that name it.';
comment on column vat_scheme_forms.report_code is
  'A form of tax_report_templates of the same country. Not a foreign key, for the reason company_filing_periods gives: the pack writes its forms and its schemes in one seed, in that order.';

alter table vat_scheme_forms enable row level security;
create policy vat_scheme_forms_select on vat_scheme_forms for select using (is_known_caller());
comment on policy vat_scheme_forms_select on vat_scheme_forms is
  'Reference data of the packs, read by anybody signed in.';
grant select on table vat_scheme_forms to authenticated, service_role;

create table if not exists vat_scheme_ceilings (
  country         char(2) not null,
  scheme_code     text    not null,
  sequence        integer not null,
  measure         text    not null,
  activity        text    not null default 'all',
  amount          numeric(18,2) not null,
  currency_code   char(3) not null,
  valid_from      date    not null,
  valid_to        date,
  legal_reference text    not null,
  source_key      text,
  primary key (country, scheme_code, sequence),
  foreign key (country, scheme_code) references vat_schemes (country, code) on delete cascade,
  constraint vat_scheme_ceilings_measure check (
    measure in ('turnover_previous_year', 'turnover_current_year', 'tax_previous_year')
  ),
  constraint vat_scheme_ceilings_activity check (activity in ('all', 'goods', 'services')),
  constraint vat_scheme_ceilings_amount check (amount > 0),
  constraint vat_scheme_ceilings_dates check (valid_to is null or valid_to >= valid_from)
);

comment on table vat_scheme_ceilings is
  'Up to which amount a company may be on a scheme: a measure from a closed vocabulary, the part of the activity it is counted on, an amount in a currency, the dates it applies between and the article that sets it. Read by vat_scheme_ceilings_crossed(), an alert; nothing moves a company from one scheme to another by itself.';

alter table vat_scheme_ceilings enable row level security;
create policy vat_scheme_ceilings_select on vat_scheme_ceilings for select using (is_known_caller());
comment on policy vat_scheme_ceilings_select on vat_scheme_ceilings is
  'Reference data of the packs, read by anybody signed in.';
grant select on table vat_scheme_ceilings to authenticated, service_role;

create table if not exists vat_scheme_instalments (
  country          char(2)  not null,
  scheme_code      text     not null,
  sequence         smallint not null,
  -- The form the instalment is paid on account of, and deducted on.
  report_code      text     not null,
  due_month        smallint not null,
  due_day          smallint,
  percent          numeric(9,4) not null,
  -- The box of the previous period's return the percentage is of.
  base_report_code text     not null,
  base_box         text     not null,
  base_kind        text     not null default 'total',
  minimum_base     numeric(18,2),
  legal_reference  text     not null,
  source_key       text,
  primary key (country, scheme_code, sequence),
  foreign key (country, scheme_code) references vat_schemes (country, code) on delete cascade,
  constraint vat_scheme_instalments_month check (due_month between 1 and 12),
  constraint vat_scheme_instalments_day check (due_day is null or due_day between 1 and 31),
  constraint vat_scheme_instalments_percent check (percent > 0 and percent <= 100),
  constraint vat_scheme_instalments_base_kind check (base_kind in ('base', 'tax', 'total')),
  constraint vat_scheme_instalments_minimum check (minimum_base is null or minimum_base >= 0)
);

comment on table vat_scheme_instalments is
  'The payments on account a scheme asks for during the year a return covers: in which month (and on which day, where the law gives one to everybody), which percentage of which box of the previous period''s return, and the base below which nothing is due. instalment_plan() reads it.';
comment on column vat_scheme_instalments.due_day is
  'Null where the day of the month depends on the taxpayer; the instalment is then listed with its month and no date.';

alter table vat_scheme_instalments enable row level security;
create policy vat_scheme_instalments_select on vat_scheme_instalments for select using (is_known_caller());
comment on policy vat_scheme_instalments_select on vat_scheme_instalments is
  'Reference data of the packs, read by anybody signed in.';
grant select on table vat_scheme_instalments to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 3. What a company says: the scheme it is on
-- ---------------------------------------------------------------------------
--
-- One row per change, from the first day of a financial year — the law of
-- every country read so far moves a company from one scheme to another at the
-- start of a year — until the next row. No row: the company has said nothing,
-- and it files exactly as before. Nothing writes a row on its behalf.

create table if not exists company_vat_schemes (
  company_id  uuid    not null references companies(id) on delete cascade,
  valid_from  date    not null,
  country     char(2) not null,
  scheme_code text    not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  primary key (company_id, valid_from),
  -- A scheme a company is on is not removed by a pack upgrade under it.
  foreign key (country, scheme_code) references vat_schemes (country, code)
);

comment on table company_vat_schemes is
  'The VAT scheme a company is on, from the first day of a financial year until the next row. No row: the company has not said, and files exactly as it did before schemes existed — no default and no guess. The forms and cadences it implies are written into company_filing_periods, which stays the one place a cadence is recorded.';
comment on column company_vat_schemes.country is
  'The country of the scheme: the company''s fiscal country, written by the trigger, so the scheme is a foreign key and a pack upgrade cannot remove one a company is on.';

create trigger company_vat_schemes_set_updated_at
  before update on company_vat_schemes
  for each row execute function set_updated_at();

alter table company_vat_schemes enable row level security;
create policy company_vat_schemes_select on company_vat_schemes
  for select using (is_company_member(company_id));
create policy company_vat_schemes_write on company_vat_schemes
  for all using (has_capability(company_id, 'company.write'))
  with check (has_capability(company_id, 'company.write'));

comment on policy company_vat_schemes_select on company_vat_schemes is
  'A member of the company reads the scheme it is on, as they read how often it files.';
comment on policy company_vat_schemes_write on company_vat_schemes is
  'company.write, the capability that writes company_filing_periods: the scheme writes those rows, and a capability that could write one and not the other would make the scheme a write that does not take.';

grant select, insert, update, delete on table company_vat_schemes to authenticated, service_role;

create trigger company_vat_schemes_audit
  after insert or update or delete on company_vat_schemes
  for each row execute function audit_changes('{"company":"company_id","key":["valid_from"]}');

create or replace function vat_scheme_at(p_company_id uuid, p_date date)
returns vat_schemes
language sql
stable
set search_path = public, pg_temp
as $$
  select s.*
    from company_vat_schemes g
    join vat_schemes s on s.country = g.country and s.code = g.scheme_code
   where g.company_id = p_company_id
     and g.valid_from <= p_date
   order by g.valid_from desc
   limit 1;
$$;

comment on function vat_scheme_at(uuid, date) is
  'The VAT scheme the company is on that day: the row of company_vat_schemes that starts last on or before it. Null when the company has recorded none, which is not an error. Asked for ''infinity'', the last scheme the company recorded, which is the one its filing periods follow.';

revoke execute on function vat_scheme_at(uuid, date) from public, anon;
grant execute on function vat_scheme_at(uuid, date) to authenticated, service_role;

create or replace function vat_scheme_files(p_company_id uuid, p_report_code text, p_date date)
returns boolean
language sql
stable
set search_path = public, pg_temp
as $$
  select case
    when s.code is null then true
    when not exists (select 1 from vat_scheme_forms f
                      where f.country = s.country and f.report_code = p_report_code) then true
    else exists (select 1 from vat_scheme_forms f
                  where f.country = s.country and f.scheme_code = s.code and f.report_code = p_report_code)
  end
  from (select (vat_scheme_at(p_company_id, p_date)).*) s;
$$;

comment on function vat_scheme_files(uuid, text, date) is
  'Whether the company files that form on that day as far as its scheme is concerned: true when it has recorded no scheme, true for a form no scheme of its country names, and otherwise whether its scheme names the form.';

revoke execute on function vat_scheme_files(uuid, text, date) from public, anon;
grant execute on function vat_scheme_files(uuid, text, date) to authenticated, service_role;

create or replace function company_vat_schemes_check()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  select c.fiscal_country into new.country from companies c where c.id = new.company_id;
  if not exists (select 1 from vat_schemes s where s.country = new.country and s.code = new.scheme_code) then
    raise exception 'unknown_vat_scheme: % is not a VAT scheme of the pack of this company''s fiscal country', new.scheme_code
      using errcode = '23514';
  end if;
  if not exists (select 1 from fiscal_years y
                  where y.company_id = new.company_id and y.start_date = new.valid_from) then
    raise exception 'scheme_change_mid_year: % starts on %, which is not the first day of a financial year of this company',
      new.scheme_code, new.valid_from
      using errcode = '23514';
  end if;
  return new;
end;
$$;

comment on function company_vat_schemes_check() is
  'Refuses a scheme the pack of the company''s fiscal country does not carry (unknown_vat_scheme) and one that does not start on the first day of a financial year (scheme_change_mid_year); writes the country of the scheme.';

revoke execute on function company_vat_schemes_check() from public, anon, authenticated, service_role;

create trigger company_vat_schemes_check
  before insert or update on company_vat_schemes
  for each row execute function company_vat_schemes_check();

-- The filing periods follow the last scheme the company recorded. Rows of the
-- forms some scheme of the country names and this one does not are removed;
-- each form of the scheme keeps the cadence the company recorded where the
-- scheme allows it, or takes the scheme's default, or the one cadence the
-- scheme allows. Where the scheme allows several and proposes none, nothing
-- is written: a cadence is a fact about the company, not a guess.
create or replace function company_vat_schemes_follow()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
declare
  v_company uuid;
  v_scheme  vat_schemes;
  r         record;
  v_now     declaration_period;
begin
  v_company := case when tg_op = 'DELETE' then old.company_id else new.company_id end;
  v_scheme := vat_scheme_at(v_company, 'infinity'::date);
  if v_scheme.code is null then
    return null;
  end if;

  delete from company_filing_periods p
   where p.company_id = v_company
     and exists (select 1 from vat_scheme_forms f
                  where f.country = v_scheme.country and f.report_code = p.report_code)
     and not exists (select 1 from vat_scheme_forms f
                      where f.country = v_scheme.country and f.scheme_code = v_scheme.code
                        and f.report_code = p.report_code
                        and p.period = any (f.periods));

  for r in
    select f.report_code, f.periods, f.period_default
      from vat_scheme_forms f
     where f.country = v_scheme.country and f.scheme_code = v_scheme.code
  loop
    if exists (select 1 from company_filing_periods p
                where p.company_id = v_company and p.report_code = r.report_code) then
      continue;
    end if;
    v_now := coalesce(r.period_default, case when cardinality(r.periods) = 1 then r.periods[1] end);
    if v_now is not null then
      insert into company_filing_periods (company_id, report_code, period)
      values (v_company, r.report_code, v_now);
    end if;
  end loop;
  return null;
end;
$$;

comment on function company_vat_schemes_follow() is
  'Writes company_filing_periods from the last scheme the company recorded: removes the cadences of forms the scheme does not file or of cadences it does not allow, and records for each form it files the scheme''s default or the one cadence it allows, never a guess among several.';

revoke execute on function company_vat_schemes_follow() from public, anon, authenticated, service_role;

create trigger company_vat_schemes_follow
  after insert or update or delete on company_vat_schemes
  for each row execute function company_vat_schemes_follow();

create or replace function company_filing_periods_within_scheme()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
declare
  v_scheme  vat_schemes;
  v_periods declaration_period[];
begin
  v_scheme := vat_scheme_at(new.company_id, 'infinity'::date);
  if v_scheme.code is null
     or not exists (select 1 from vat_scheme_forms f
                     where f.country = v_scheme.country and f.report_code = new.report_code) then
    return new;
  end if;
  select f.periods into v_periods
    from vat_scheme_forms f
   where f.country = v_scheme.country and f.scheme_code = v_scheme.code and f.report_code = new.report_code;
  if v_periods is null then
    raise exception 'form_not_in_vat_scheme: this company is on the scheme %, which does not file %',
      v_scheme.code, new.report_code
      using errcode = '23514';
  end if;
  if not new.period = any (v_periods) then
    raise exception 'wrong_declaration_period: under the scheme % this company files % on %, not %',
      v_scheme.code, new.report_code, array_to_string(v_periods, ', '), new.period
      using errcode = '23514';
  end if;
  return new;
end;
$$;

comment on function company_filing_periods_within_scheme() is
  'Refuses a cadence recorded for a form the company''s last recorded scheme does not file (form_not_in_vat_scheme), or on a cadence the scheme does not allow (wrong_declaration_period). A company with no scheme, and a form no scheme names, are not concerned.';

revoke execute on function company_filing_periods_within_scheme() from public, anon, authenticated, service_role;

create trigger company_filing_periods_within_scheme
  before insert or update on company_filing_periods
  for each row execute function company_filing_periods_within_scheme();

-- ---------------------------------------------------------------------------
-- 4. Payments on account of a declaration
-- ---------------------------------------------------------------------------

create table if not exists declaration_instalments (
  id           uuid primary key default gen_random_uuid(),
  company_id   uuid not null references companies(id) on delete cascade,
  -- The declaration it is paid on account of: its form and its period.
  report_code  text not null,
  period_start date not null,
  period_end   date not null,
  -- Which instalment of the scheme's schedule it is.
  sequence     smallint not null,
  paid_on      date not null,
  amount       numeric(18,2) not null,
  -- The entry that carried the payment, where the company booked one.
  entry_id     uuid references entries(id),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  constraint declaration_instalments_period check (period_end >= period_start),
  constraint declaration_instalments_amount check (amount > 0),
  constraint declaration_instalments_sequence check (sequence >= 1)
);

comment on table declaration_instalments is
  'What a company paid on account of a declaration during its period: which instalment of the scheme''s schedule, the day, the amount and the entry that carried it, where there is one. Several rows for one instalment are a payment made in parts. The annual return deducts them in the box whose reads is instalments_paid or instalments_due.';

create index if not exists declaration_instalments_period_idx
  on declaration_instalments (company_id, report_code, period_start, period_end);
create index if not exists declaration_instalments_entry_idx on declaration_instalments (entry_id);

create trigger declaration_instalments_set_updated_at
  before update on declaration_instalments
  for each row execute function set_updated_at();

alter table declaration_instalments enable row level security;
create policy declaration_instalments_select on declaration_instalments
  for select using (has_capability(company_id, 'filings.read'));
create policy declaration_instalments_write on declaration_instalments
  for all using (has_capability(company_id, 'filings.write'))
  with check (has_capability(company_id, 'filings.write'));

comment on policy declaration_instalments_select on declaration_instalments is
  'filings.read, as the declarations they are paid on account of.';
comment on policy declaration_instalments_write on declaration_instalments is
  'filings.write, as the declarations they are paid on account of.';

grant select, insert, update, delete on table declaration_instalments to authenticated, service_role;

create trigger declaration_instalments_audit
  after insert or update or delete on declaration_instalments
  for each row execute function audit_changes('{"company":"company_id","key":["report_code","period_start","sequence"]}');

create or replace function instalment_plan(p_company_id uuid, p_from date, p_to date)
returns table (
  report_code  text,
  sequence     smallint,
  due_month    date,
  due_date     date,
  base         numeric,
  percent      numeric,
  amount_due   numeric,
  paid         numeric,
  outstanding  numeric,
  reason       text
)
language plpgsql
stable
set search_path = public, pg_temp
as $$
declare
  v_scheme  vat_schemes;
  v_rule    vat_scheme_instalments;
  v_round   money_rounding;
  v_prev_from date := (p_from - interval '1 year')::date;
  v_prev_to   date := (p_from - interval '1 day')::date;
  v_base    numeric;
  v_reason  text;
begin
  v_scheme := vat_scheme_at(p_company_id, p_to);
  if v_scheme.code is null then
    return;
  end if;
  select i.* into v_rule
    from vat_scheme_instalments i
   where i.country = v_scheme.country and i.scheme_code = v_scheme.code
   order by i.sequence
   limit 1;
  if v_rule.scheme_code is null then
    return;
  end if;
  v_round := rounding_of(p_company_id);

  -- The base: the box of the previous period's return as it was frozen, or,
  -- where nothing was frozen, as the books compute it — a company that has
  -- just moved onto the scheme files no such return for the year before, and
  -- its tax of that year is still what the base is a share of.
  select b.amount into v_base
    from tax_filings f
    join tax_filing_boxes b on b.filing_id = f.id
   where f.company_id = p_company_id
     and f.report_code = v_rule.base_report_code
     and f.period_start = v_prev_from
     and f.period_end = v_prev_to
     and f.state <> 'superseded'
     and b.box = v_rule.base_box
     and b.kind = v_rule.base_kind
   order by (f.state = 'draft'), f.prepared_at desc nulls last
   limit 1;
  if not found
     and exists (select 1 from fiscal_years y where y.company_id = p_company_id and y.start_date <= v_prev_from)
     and vat_scheme_files(p_company_id, v_rule.base_report_code, v_prev_to) then
    select coalesce(sum(v.amount), 0) into v_base
      from vat_return(p_company_id, v_prev_from, v_prev_to, v_rule.base_report_code) v
     where v.box = v_rule.base_box and v.kind = v_rule.base_kind;
  end if;

  v_reason := case
    when v_base is null then 'no_base'
    when v_rule.minimum_base is not null and v_base < v_rule.minimum_base then 'below_minimum'
  end;

  return query
  select i.report_code,
         i.sequence,
         make_date(extract(year from p_from)::integer, i.due_month, 1),
         case when i.due_day is null then null
              else make_date(extract(year from p_from)::integer, i.due_month,
                             least(i.due_day::integer,
                                   extract(day from (make_date(extract(year from p_from)::integer, i.due_month, 1)
                                                     + interval '1 month' - interval '1 day'))::integer))
         end,
         v_base,
         i.percent,
         case when v_reason = 'no_base' then null
              when v_reason = 'below_minimum' or v_base <= 0 then 0::numeric
              else round_amount(v_base * i.percent / 100, v_round) end,
         coalesce(p.paid, 0),
         greatest(coalesce(case when v_reason = 'no_base' then null
                                when v_reason = 'below_minimum' or v_base <= 0 then 0::numeric
                                else round_amount(v_base * i.percent / 100, v_round) end, 0)
                  - coalesce(p.paid, 0), 0),
         v_reason
    from vat_scheme_instalments i
    left join lateral (
      select sum(d.amount) as paid
        from declaration_instalments d
       where d.company_id = p_company_id
         and d.report_code = i.report_code
         and d.period_start = p_from
         and d.period_end = p_to
         and d.sequence = i.sequence
    ) p on true
   where i.country = v_scheme.country and i.scheme_code = v_scheme.code
   order by i.sequence;
end;
$$;

comment on function instalment_plan(uuid, date, date) is
  'The payments on account of the declaration of a period the company''s scheme asks for: for each instalment of vat_scheme_instalments, the month (and the day, where the law gives one), the base — the box the pack names on the previous period''s return as frozen by prepare_filing(), or as vat_return() computes it where nothing was frozen — the percentage, what was due, what declaration_instalments records as paid and what is outstanding. reason says no_base where there is no previous period to read, below_minimum where the base is under the scheme''s minimum and nothing is due. No row for a company with no scheme or a scheme without instalments.';

revoke execute on function instalment_plan(uuid, date, date) from public, anon;
grant execute on function instalment_plan(uuid, date, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5. The return reads the scheme, restates another form, deducts instalments
-- ---------------------------------------------------------------------------
--
-- Replaced whole, because a function is replaced whole in PostgreSQL.
-- `20261011160431` unchanged but for three things, each marked where it
-- happens: the scheme of the company chooses the form when none is named and
-- refuses one it does not file; a form that reads the postings of another
-- reads them and adds up, box by box, the boxes it names; and a box that reads
-- the payments on account of the declaration takes them. For a company that
-- recorded no scheme and a form that reads its own postings, which is every
-- form of every pack before this file, the answer is the same to the cent.

create or replace function vat_return(
  p_company_id  uuid,
  p_from        date,
  p_to          date,
  p_report_code text default null
)
returns table (
  box            text,
  kind           text,
  amount         numeric,
  computed       boolean,
  name           text,
  sequence       integer,
  print_sequence integer,
  hidden         boolean,
  report_code    text
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
  -- The scheme the company is on at the end of the period, the form it was
  -- asked for or the one that scheme files, and the form whose postings the
  -- boxes are read from: the form itself, or the one it restates.
  v_scheme   vat_schemes;
  v_asked_report text := p_report_code;
  v_postings text;
  v_scheme_periods declaration_period[];
  v_source   jsonb := '{}'::jsonb;
  r          record;
begin
  select c.fiscal_country into v_country
    from companies c where c.id = p_company_id;
  if not found then
    raise exception 'unknown_company: %', p_company_id;
  end if;
  v_round := rounding_of(p_company_id);

  -- The scheme decides which forms there are to ask for. A company that has
  -- recorded none is not asked anything new; one that has is given the form
  -- its scheme files when it names none, and told by name when its scheme
  -- files no return at all, or several.
  v_scheme := vat_scheme_at(p_company_id, p_to);
  if v_asked_report is null and v_scheme.code is not null then
    select count(*), min(f.report_code), string_agg(f.report_code, ', ' order by f.report_code)
      into v_count, v_asked_report, v_codes
      from vat_scheme_forms f
      join tax_report_templates t on t.country = f.country and t.code = f.report_code
     where f.country = v_scheme.country
       and f.scheme_code = v_scheme.code
       and t.valid_from <= p_to
       and (t.valid_to is null or t.valid_to >= p_to);
    if v_count = 0 then
      raise exception 'vat_scheme_files_no_return: on % this company is on the scheme %, under which it files no VAT return',
        p_to, v_scheme.code;
    elsif v_count > 1 then
      raise exception 'ambiguous_tax_report: on % the scheme % files several declarations (%); name one',
        p_to, v_scheme.code, v_codes;
    end if;
  end if;

  -- Which form. The caller names one, or the country files exactly one on
  -- that date. Two and no name is a question only the caller can answer — a
  -- Canadian company files the federal return and the Québec one at once — so
  -- this asks instead of guessing.
  if v_asked_report is not null then
    select t.country, t.code into v_in, v_report
      from tax_report_templates t
     where t.code = v_asked_report
       and t.valid_from <= p_to
       and (t.valid_to is null or t.valid_to >= p_to)
     order by t.country
     limit 1;
    if v_report is null then
      raise exception 'unknown_tax_report: % is not a declaration form in force on %',
        v_asked_report, p_to;
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
  -- The scheme refuses a form it does not file, and a cadence of the form it
  -- does not file it on — the second only when the dates asked for are a
  -- whole cadence the form is filed on, for the reason the guard below gives.
  if v_report is not null and not vat_scheme_files(p_company_id, v_report, p_to) then
    raise exception 'form_not_in_vat_scheme: on % this company is on the scheme %, which does not file %',
      p_to, v_scheme.code, v_report;
  end if;
  if v_report is not null and v_scheme.code is not null then
    select f.periods into v_scheme_periods
      from vat_scheme_forms f
     where f.country = v_scheme.country and f.scheme_code = v_scheme.code and f.report_code = v_report;
    select t.periods into v_accepts
      from tax_report_templates t
     where t.country = v_in and t.code = v_report;
    v_asked := declaration_period_of(p_from, p_to);
    if v_scheme_periods is not null and v_asked is not null
       and v_asked = any(v_accepts) and not v_asked = any(v_scheme_periods) then
      raise exception
        'wrong_declaration_period: under the scheme % this company files % on %; % to % is a %',
        v_scheme.code, v_report, array_to_string(v_scheme_periods, ', '), p_from, p_to, v_asked;
    end if;
  end if;

  -- Whose postings the boxes are read from: this form's, or those of the
  -- form it restates.
  if v_report is not null then
    select coalesce(t.reads_postings_of, t.code) into v_postings
      from tax_report_templates t
     where t.country = v_in and t.code = v_report;
  end if;

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
  --    names. Since `20261011160431` a line carries the whole list and the
  --    form it is on, frozen when it was written from the posting that wrote
  --    it — so a posting changed afterwards, by hand or by a pack upgrade,
  --    moves no return already computed. A line without them, which only an
  --    archive written before that file brings, is read through the postings
  --    of today by `declaration_boxes_of()`, the rule the freezing applies. No
  --    country rule here either: the expansion is `unnest`, and which boxes
  --    there are is the pack's answer.
  for r in
    with lines as (
      select l.declaration_box as lbox,
             case when l.tax_line then 'tax' else 'base' end as lkind,
             l.tax_id as ltax,
             l.tax_line as ltaxline,
             l.box_amount as lamount,
             l.declaration_boxes as lboxes,
             l.report_code as lreport
        -- The period a figure belongs to is the day its tax fell due: the
        -- line's `declared_on`, which `declared_lines()` reads.
        from declared_lines(p_company_id, p_from, p_to) l
        join entries e on e.id = l.entry_id
       where e.state = 'posted'
         and l.declaration_box is not null
    ),
    -- Which form the line is on, and every box it prints in: what the line
    -- carries. A line that carries nothing asks the postings, in a branch of
    -- a `case`, so the question is put for that line only — a lateral join
    -- would put it for every line, and the postings are read under row level
    -- security. A line with no posting behind it — an entry keyed by hand
    -- before `20261011155947`, a tax a company wrote itself — is on this form
    -- and in the one box it names.
    asked as (
      select ln.lbox, ln.lkind, ln.lamount,
             case when ln.lboxes is not null then ln.lboxes
                  else coalesce((select d.boxes
                                   from declaration_boxes_of(ln.ltax, ln.lbox, ln.ltaxline) d),
                                array[ln.lbox]) end as lboxes,
             case when ln.lboxes is not null then ln.lreport
                  else (select d.report_code
                          from declaration_boxes_of(ln.ltax, ln.lbox, ln.ltaxline) d) end as lreport
        from lines ln
    ),
    sourced as (
      select a.lbox, a.lkind, a.lamount, a.lboxes
        from asked a
       -- A box number belongs to one form. A line whose posting names
       -- another form is not on this declaration; one that names none is
       -- the single-return case every European company is in.
       where v_report is null or coalesce(a.lreport, v_postings) = v_postings
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
           b.sequence as lsequence,
           coalesce(b.print_sequence, b.sequence) as lprint,
           coalesce(b.hidden, false) as lhidden
      from ledger g
      left join tax_report_box_templates b
        on b.country = v_in and b.report_code = v_postings
       and b.box = g.lbox and b.kind = g.lkind
     order by coalesce(b.sequence, 2147483647), g.lbox, g.lkind
  loop
    if v_postings is distinct from v_report then
      -- The boxes of the form restated, kept aside: this form's own boxes
      -- are worked out from them below.
      v_source := v_source || jsonb_build_object(r.lbox || '|' || r.lkind, r.lamount);
      continue;
    end if;
    v_values := v_values || jsonb_build_object(r.lbox || '|' || r.lkind, r.lamount);
    v_rows := v_rows || jsonb_build_array(jsonb_build_object(
      'box', r.lbox, 'kind', r.lkind, 'amount', r.lamount, 'computed', false,
      'name', r.lname, 'sequence', r.lsequence, 'print_sequence', r.lprint,
      'hidden', r.lhidden, 'report_code', v_report));
  end loop;

  -- 1b. A form that restates another adds up, box by box, the boxes of that
  --     form it names (`from_boxes`, "08:base"; bare, every kind of the box).
  --     And a box that reads the payments on account of this declaration
  --     takes them from declaration_instalments or from instalment_plan().
  if v_report is not null then
    for r in
      select b.box as mbox, b.kind as mkind, b.name as mname, b.sequence as msequence,
             coalesce(b.print_sequence, b.sequence) as mprint, coalesce(b.hidden, false) as mhidden,
             case
               when b.reads = 'instalments_paid' then
                 (select coalesce(sum(i.amount), 0)
                    from declaration_instalments i
                   where i.company_id = p_company_id and i.report_code = v_report
                     and i.period_start = p_from and i.period_end = p_to)
               when b.reads = 'instalments_due' then
                 (select coalesce(sum(greatest(coalesce(pl.amount_due, 0), pl.paid)), 0)
                    from instalment_plan(p_company_id, p_from, p_to) pl)
               else
                 (select coalesce(sum((e.value)::numeric), 0)
                    from unnest(b.from_boxes) as f(ref)
                    join jsonb_each_text(v_source) e
                      on e.key = replace(f.ref, ':', '|')
                      or (position(':' in f.ref) = 0 and split_part(e.key, '|', 1) = f.ref))
             end as mamount
        from tax_report_box_templates b
       where b.country = v_in
         and b.report_code = v_report
         and b.kind <> 'total'
         and (cardinality(b.from_boxes) > 0 or b.reads is not null)
         and (b.valid_from is null or b.valid_from <= p_to)
         and (b.valid_to is null or b.valid_to >= p_to)
       order by b.sequence, b.box
    loop
      r.mamount := round_amount(r.mamount, v_round);
      continue when r.mamount = 0;
      v_values := v_values || jsonb_build_object(r.mbox || '|' || r.mkind, r.mamount);
      v_rows := v_rows || jsonb_build_array(jsonb_build_object(
        'box', r.mbox, 'kind', r.mkind, 'amount', r.mamount, 'computed', false,
        'name', r.mname, 'sequence', r.msequence, 'print_sequence', r.mprint,
        'hidden', r.mhidden, 'report_code', v_report));
    end loop;
  end if;

  -- 2. The totals of the form, through the evaluator the statements use. A
  --    return prints what it has, so a nil total is left out of the answer —
  --    and kept in the working set, so a later total that names it reads a
  --    zero rather than a gap.
  if v_report is not null then
    select coalesce(jsonb_agg(jsonb_build_object(
             'key', b.box || '|total', 'plus', to_jsonb(b.plus_boxes),
             'minus', to_jsonb(b.minus_boxes), 'floor_zero', b.floor_zero,
             'rate', b.rate, 'rate_of', b.rate_of_box,
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
      select b.box as tbox, b.name as tname, b.sequence as tsequence,
             coalesce(b.print_sequence, b.sequence) as tprint, b.hidden as thidden
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
        'name', r.tname, 'sequence', r.tsequence, 'print_sequence', r.tprint,
        'hidden', r.thidden, 'report_code', v_report));
    end loop;
  end if;

  return query
  select (x ->> 'box')::text,
         (x ->> 'kind')::text,
         (x ->> 'amount')::numeric,
         (x ->> 'computed')::boolean,
         (x ->> 'name')::text,
         (x ->> 'sequence')::integer,
         (x ->> 'print_sequence')::integer,
         (x ->> 'hidden')::boolean,
         (x ->> 'report_code')::text
    from jsonb_array_elements(v_rows) as x;
end;
$$;

comment on function vat_return(uuid, date, date, text) is
  'Declaration boxes for a period: summed from the ledger by the day each figure''s tax fell due — `entry_lines.declared_on`, read through declared_lines() — into the boxes and on the form each line was frozen with when it was written (entry_lines.declaration_boxes and report_code), so a posting changed afterwards moves no return; then the totals of the country''s form worked out by evaluate_totals(), the same evaluator financial_statement() uses. A form that restates another (reads_postings_of) adds up the boxes of that form each of its boxes names, and a box that reads the payments on account of the declaration takes them from declaration_instalments or instalment_plan(). Refuses a period the company does not file **this form** on, when it has recorded one for it; under the scheme the company is on (company_vat_schemes) refuses a form the scheme does not file and a cadence it does not file it on, and takes the scheme''s form when none is named. No country rule lives in this function.';

revoke execute on function vat_return(uuid, date, date, text) from public, anon;
grant execute on function vat_return(uuid, date, date, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 6. Under a scheme that charges no VAT
-- ---------------------------------------------------------------------------

create or replace function documents_refuse_vat_under_exemption()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
declare
  v_scheme vat_schemes;
  v_tax    record;
begin
  if new.doc_type not in ('sale_invoice', 'sale_credit_note') then
    return new;
  end if;
  v_scheme := vat_scheme_at(new.company_id, coalesce(new.accounting_date, new.document_date));
  if v_scheme.code is null or v_scheme.charges_vat then
    return new;
  end if;
  select t.code, l.sequence into v_tax
    from document_lines l
    join taxes t on t.id = l.tax_id
   where l.document_id = new.id
     and t.tax_kind = 'vat'
     and t.amount <> 0
   order by l.sequence
   limit 1;
  if found then
    raise exception 'vat_charged_under_exemption: line % carries %, and on % this company is on the scheme %, under which it charges no VAT; book the line without it',
      v_tax.sequence, v_tax.code, coalesce(new.accounting_date, new.document_date), v_scheme.code
      using errcode = '23514';
  end if;
  return new;
end;
$$;

comment on function documents_refuse_vat_under_exemption() is
  'Refuses to post a sale invoice or credit note a line of which charges VAT — a tax of kind vat at a rate other than zero — on a day the company is on a scheme of vat_schemes that charges none (vat_charged_under_exemption).';

revoke execute on function documents_refuse_vat_under_exemption() from public, anon, authenticated, service_role;

create trigger documents_refuse_vat_under_exemption
  before update of state on documents
  for each row
  when (new.state = 'posted' and old.state is distinct from 'posted')
  execute function documents_refuse_vat_under_exemption();

-- The mention of an exemption is printed on the sales of a company on such a
-- scheme. `20260918141605` to the letter, with the one condition it could not
-- resolve: small_business, which was a regime the core did not record.
create or replace view document_legal_mentions
  with (security_invoker = true) as
  with document_taxes as (
    select d.id             as document_id,
           d.company_id,
           c.fiscal_country as country,
           d.document_date,
           d.doc_type,
           d.language,
           coalesce(
             array_agg(distinct t.treatment::text) filter (where t.treatment is not null),
             array[]::text[]
           )                                 as treatments,
           coalesce(bool_or(t.cash_basis), false) as on_cash_basis
      from documents d
      join companies c           on c.id = d.company_id
      left join document_lines l on l.document_id = d.id
      left join taxes t          on t.id = l.tax_id
     group by d.id, d.company_id, c.fiscal_country, d.document_date, d.doc_type, d.language
  )
  select dt.document_id,
         dt.company_id,
         m.country,
         m.code,
         m.applies_when,
         dt.language,
         label_for(m.text, m.text_i18n,
                   preferred_languages(dt.language, dt.company_id)) as text,
         m.text_i18n,
         m.sequence,
         m.legal_reference
    from document_taxes dt
    join legal_mention_templates m
      on m.country = dt.country
     and m.valid_from <= dt.document_date
     and (m.valid_to is null or m.valid_to >= dt.document_date)
   where case m.applies_when
           when 'always'       then true
           when 'cash_basis'   then dt.on_cash_basis
           when 'late_payment' then dt.doc_type in ('sale_invoice', 'sale_credit_note')
           when 'small_business' then dt.doc_type in ('sale_invoice', 'sale_credit_note')
                                  and coalesce(not (vat_scheme_at(dt.company_id, dt.document_date)).charges_vat, false)
           else coalesce(dt.treatments && legal_mention_treatments(m.applies_when), false)
         end;

-- ---------------------------------------------------------------------------
-- 7. A ceiling crossed: an alert, never a switch
-- ---------------------------------------------------------------------------

create or replace function vat_scheme_ceilings_crossed(p_company_id uuid, p_from date, p_to date)
returns table (
  scheme_code     text,
  measure         text,
  activity        text,
  ceiling         numeric,
  currency_code   char(3),
  measured        numeric,
  crossed         boolean,
  legal_reference text
)
language sql
stable
set search_path = public, pg_temp
as $$
  select s.code,
         l.measure,
         l.activity,
         l.amount,
         l.currency_code,
         m.value,
         case when m.value is null then null else m.value > l.amount end,
         l.legal_reference
    from (select (vat_scheme_at(p_company_id, p_to)).*) s
    join vat_scheme_ceilings l
      on l.country = s.country and l.scheme_code = s.code
     and l.valid_from <= p_to
     and (l.valid_to is null or l.valid_to >= p_to)
    cross join lateral (
      select case l.measure
               when 'turnover_current_year' then turnover_of(p_company_id, p_from, p_to)
               when 'turnover_previous_year'
                 then turnover_of(p_company_id, (p_from - interval '1 year')::date, (p_from - interval '1 day')::date)
               else null
             end as value
    ) m
   where s.code is not null
   order by l.sequence;
$$;

comment on function vat_scheme_ceilings_crossed(uuid, date, date) is
  'The ceilings of the scheme the company is on at the end of the period, against its books: the turnover of the period or of the one before it, as turnover_of() reads it, and whether it is above the ceiling. A ceiling counted on goods or on services alone is compared with the whole turnover, which the ledger does not split by activity, so it can only over-warn. measured and crossed are null for a measure the books do not give (tax_previous_year). An alert: it changes no scheme.';

revoke execute on function vat_scheme_ceilings_crossed(uuid, date, date) from public, anon;
grant execute on function vat_scheme_ceilings_crossed(uuid, date, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 8. What is to be filed, and paid on account
-- ---------------------------------------------------------------------------
--
-- `20261020090000` with two changes, and a column more, which is why the
-- function and the portfolio reading it are dropped and created again rather
-- than replaced: a form the company's scheme does not file is not listed for
-- the periods the scheme covers, and the instalments of the scheme are listed
-- beside the returns, one row each, `instalment` carrying its sequence. On an
-- instalment row the period is the month it falls due in and report_code the
-- declaration it is paid on account of; due_date is its day where the law
-- gives one to everybody; state and filing_id are null. Every return row has
-- a null instalment.

drop function if exists portfolio_upcoming_filings(date, date);
drop function if exists upcoming_filings(uuid, date, date);

create function upcoming_filings(
  p_company_id uuid,
  p_from       date,
  p_to         date
)
returns table (
  report_code  text,
  period_start date,
  period_end   date,
  due_date     date,
  state        tax_filing_state,
  filing_id    uuid,
  instalment   smallint
)
language sql
stable
security invoker
as $$
  with forms as (
    -- Every form this company has a cadence for, and the periodic return it
    -- files even when nobody has written a cadence down for it.
    select p.report_code, p.period as cadence
      from company_filing_periods p
     where p.company_id = p_company_id
    union
    select periodic_return_code(p_company_id),
           coalesce(
             (select p.period from company_filing_periods p
               where p.company_id = p_company_id
                 and p.report_code = periodic_return_code(p_company_id)),
             (select t.period_default from tax_report_templates t
               join companies c on c.id = p_company_id
              where t.code = periodic_return_code(p_company_id)
                and t.country in (c.country, c.fiscal_country)))
     where periodic_return_code(p_company_id) is not null
  ),
  periods as (
    select f.report_code,
           g.start::date as period_start,
           (g.start + make_interval(months => declaration_period_months(f.cadence))
            - interval '1 day')::date as period_end
    from forms f
    cross join lateral generate_series(
      declaration_period_start(f.cadence, p_from)::timestamp,
      p_to::timestamp,
      make_interval(months => declaration_period_months(f.cadence))
    ) as g(start)
    where f.cadence is not null
  ),
  returns as (
    select p.report_code,
           p.period_start,
           p.period_end,
           filing_deadline(p_company_id, p.report_code, p.period_end) as due_date,
           f.state,
           f.id as filing_id,
           null::smallint as instalment
    from periods p
    left join tax_filings f
      on f.company_id = p_company_id
     and f.report_code = p.report_code
     and f.period_start = p.period_start
     and f.period_end = p.period_end
     and f.state <> 'superseded'
    -- A company under a regime that replaces VAT for the whole period does not
    -- file the periodic VAT return of that period.
    where not (p.report_code is not distinct from periodic_return_code(p_company_id)
               and coalesce('vat'::tax_kind = any ((turnover_tax_regime_at(p_company_id, p.period_start)).replaces), false)
               and coalesce('vat'::tax_kind = any ((turnover_tax_regime_at(p_company_id, p.period_end)).replaces), false))
      -- Nor a form its scheme does not file.
      and vat_scheme_files(p_company_id, p.report_code, p.period_end)
  ),
  -- The instalments of every year the window touches, from the scheme the
  -- company is on at the end of that year.
  years as (
    select g.y::date as year_start, (g.y + interval '1 year' - interval '1 day')::date as year_end
      from generate_series(date_trunc('year', p_from), p_to::timestamp, interval '1 year') as g(y)
  ),
  instalments as (
    select i.report_code,
           i.due_month as period_start,
           (i.due_month + interval '1 month' - interval '1 day')::date as period_end,
           i.due_date,
           null::tax_filing_state as state,
           null::uuid as filing_id,
           i.sequence as instalment
      from years y
      cross join lateral instalment_plan(p_company_id, y.year_start, y.year_end) i
     where (i.due_month + interval '1 month' - interval '1 day')::date >= p_from
       and i.due_month <= p_to
       and coalesce(i.reason, '') <> 'below_minimum'
  )
  select * from returns
  union all
  select * from instalments
  order by 3, 1, 7 nulls first;
$$;

comment on function upcoming_filings(uuid, date, date) is
  'What this company has to file and pay on account between two dates: the periods its cadences produce — any whole number of months, anchored on 1 January — the day each is due where the pack says, and the declaration already prepared or sent against it; and the instalments its scheme asks for, one row each with instalment set to its sequence and the month it falls due in as its period. The periodic return is left out of the periods a regime of turnover_tax_regimes that replaces VAT covers entirely, and a form is left out of the periods the company''s VAT scheme does not file it in. Read-only; sending the reminder is somebody else''s job, because a reminder needs a channel and somebody to operate it.';

revoke execute on function upcoming_filings(uuid, date, date) from public, anon;
grant execute on function upcoming_filings(uuid, date, date) to authenticated, service_role;

create function portfolio_upcoming_filings(
  p_from date,
  p_to   date
)
returns table (
  company_id   uuid,
  company_name text,
  report_code  text,
  period_start date,
  period_end   date,
  due_date     date,
  state        tax_filing_state,
  filing_id    uuid,
  reason       text,
  instalment   smallint
)
language sql
stable
security invoker
as $$
  with portfolio as (
    select c.id, c.name
      from companies c
     where has_capability(c.id, 'filings.read')
  ),
  -- A return is due in the month that follows its period, plus the days an
  -- administration grants. So the periods that can fall due from `p_from` on
  -- ended at most two months and that many days before it, and the calendar
  -- of a company is asked for once, from there.
  reach as (
    select (p_from - interval '2 month'
            - make_interval(days => coalesce(max(t.deadline_plus_days), 0)))::date as start
      from tax_report_templates t
  ),
  listed as (
    select p.id as company_id, u.*
      from portfolio p
      cross join reach r
      cross join lateral upcoming_filings(p.id, r.start, p_to) u
     where case
             when u.due_date is not null then u.due_date between p_from and p_to
             else u.period_end < p_to
                  and (date_trunc('month', u.period_end + interval '2 month')
                       - interval '1 day')::date >= p_from
           end
  )
  select p.id,
         p.name,
         l.report_code,
         l.period_start,
         l.period_end,
         l.due_date,
         l.state,
         l.filing_id,
         case
           when l.company_id is not null and l.due_date is null then 'no_deadline_rule'
           when l.company_id is not null then null
           when periodic_return_code(p.id) is null
                and not exists (select 1 from company_filing_periods f
                                 where f.company_id = p.id) then 'no_form'
           else 'nothing_due'
         end,
         l.instalment
    from portfolio p
    left join listed l on l.company_id = p.id
   order by l.due_date nulls last, l.period_end nulls last, p.name, p.id, l.report_code, l.instalment nulls first;
$$;

comment on function portfolio_upcoming_filings(date, date) is
  'What falls due between two dates in every company the caller holds filings.read on, and in no other: the periods and the instalments upcoming_filings() produces, kept when the day they are due is in the window. Every company of the portfolio is in the answer at least once, and a row without a date says why in `reason` — no_deadline_rule where the pack names no day for the form, nothing_due where nothing of the company falls in the window, no_form where the installation carries no return for it. instalment is set on a payment on account and null on a return. Invoker: it reads what the caller could have read company by company.';

revoke execute on function portfolio_upcoming_filings(date, date) from public, anon;
grant execute on function portfolio_upcoming_filings(date, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 9. A company leaves with its scheme and what it paid on account
-- ---------------------------------------------------------------------------

insert into company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('company_vat_schemes', 'exported', 32, null, null,
   'The VAT scheme the company recorded, after the financial years its dates are checked against.'),
  ('declaration_instalments', 'exported', 68, null, null,
   'What the company paid on account of its declarations, after the entries that carried the payments.')
on conflict (table_schema, table_name) do nothing;
