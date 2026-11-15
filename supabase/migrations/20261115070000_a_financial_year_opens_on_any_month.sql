-- Ekwo OS — a financial year opens on any of the twelve months.
--
-- `country_defaults.fiscal_year_default` named four opening months —
-- `calendar`, `april`, `july`, `october` — where the law of most countries
-- names twelve. The United States lets a company end its year on the last
-- day of any month; so do many countries whose packs chose `calendar` as the
-- ordinary answer and wrote that the law leaves the choice open. A pack whose
-- country fixes another month (a year opening on 1 March, on 1 September)
-- had nothing to declare it with. The pack us named the gap.
--
-- The vocabulary becomes the twelve months: `calendar` keeps its meaning,
-- the year that opens on 1 January — every pack written so far says it, and
-- one month keeps one name — and the eleven others are named in English,
-- `february` to `december`. `april`, `july` and `october` mean what they
-- meant. Nothing a pack declared changes, and no year already opened moves:
-- `fiscal_years` holds what each company keeps, and this default is only
-- what a first year is offered.
--
-- **The reader and the check say the same list.** The constraint is dropped
-- and written again with the twelve names, and `fiscal_year_bounds()` reads
-- the month by its place in the same list, so a name the check admits is a
-- name the function opens on.
--
-- **Still out of reach:** the 52-53-week year, which does not open on the
-- first of a month at all. `fiscal_years` takes any two dates, and a company
-- that keeps one names them (`--fiscal-year-start`); a pack cannot yet
-- propose one.
--
-- Additive in what it accepts: every value admitted before is admitted
-- after, and the function keeps its signature, its grants and its errors.

alter table ekwo.country_defaults
  drop constraint if exists country_defaults_fiscal_year_default_known;

alter table ekwo.country_defaults
  add constraint country_defaults_fiscal_year_default_known
    check (fiscal_year_default is null or fiscal_year_default in (
      'calendar', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'
    ));

comment on column ekwo.country_defaults.fiscal_year_default is
  'Month the financial year usually opens on: calendar (January), february, march, april, may, june, july, august, september, october, november or december. A default offered, never imposed — fiscal_years holds what a company actually keeps.';

create or replace function ekwo.fiscal_year_bounds(
  p_country    char(2),
  p_year       integer,
  p_start      date default null,
  out start_date date,
  out end_date   date
)
language plpgsql
stable
as $$
declare
  v_opening text;
  v_month   integer;
begin
  if p_start is not null then
    start_date := p_start;
  else
    select fiscal_year_default into v_opening
      from ekwo.country_defaults where country = p_country;

    if v_opening is null then
      raise exception 'no_fiscal_year_default: the % pack declares no defaults.fiscal_year_default, so there is no month to open the first year on. Name the first day instead', p_country;
    end if;

    v_month := array_position(
      array['calendar', 'february', 'march', 'april', 'may', 'june',
            'july', 'august', 'september', 'october', 'november', 'december'],
      v_opening
    );
    if v_month is null then
      raise exception 'unknown_fiscal_year_default: % is not one of calendar, february, march, april, may, june, july, august, september, october, november, december', v_opening;
    end if;

    start_date := make_date(p_year, v_month, 1);
  end if;

  end_date := (start_date + interval '1 year' - interval '1 day')::date;
end;
$$;

comment on function ekwo.fiscal_year_bounds(char, integer, date) is
  'The first and last day of a financial year opening in a given calendar year, on the month the country pack declares (calendar for January, or one of the eleven other months by name) — or on a day the caller names. Raises rather than assuming January.';
