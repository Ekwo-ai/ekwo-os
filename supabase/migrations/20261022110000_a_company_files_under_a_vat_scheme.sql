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
--
-- The readers that change with the scheme — vat_return(), upcoming_filings(),
-- portfolio_upcoming_filings() and the view document_legal_mentions — are
-- replaced in the next file,
-- `20261022110100`, so an upgrade test can leave them out and apply them
-- after the migrations they are written against, while the seeds, which
-- write the columns and tables of this file, still load.

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

create index if not exists company_vat_schemes_scheme_idx on company_vat_schemes (country, scheme_code);

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
-- 5. Under a scheme that charges no VAT
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

-- ---------------------------------------------------------------------------
-- 6. A ceiling crossed: an alert, never a switch
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
-- 7. A company leaves with its scheme and what it paid on account
-- ---------------------------------------------------------------------------

insert into company_archive_registry (table_name, disposition, load_order, via_column, via_table, reason) values
  ('company_vat_schemes', 'exported', 32, null, null,
   'The VAT scheme the company recorded, after the financial years its dates are checked against.'),
  ('declaration_instalments', 'exported', 68, null, null,
   'What the company paid on account of its declarations, after the entries that carried the payments.')
on conflict (table_schema, table_name) do nothing;
