-- Ekwo OS — the readers of a declaration read the company's VAT scheme.
--
-- The second half of `20261022110000`, which adds the schemes, the scheme a
-- company is on and the payments on account of a declaration. Here the
-- functions that read them are replaced: vat_return() refuses a form the
-- company's scheme does not file and takes the scheme's form when none is
-- named, restates the boxes of another form and deducts the instalments;
-- upcoming_filings() and portfolio_upcoming_filings() list the instalments
-- beside the returns. For a company that recorded no scheme, every answer is
-- what it was.

-- ---------------------------------------------------------------------------
-- 1. The return reads the scheme, restates another form, deducts instalments
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
-- 2. What is to be filed, and paid on account
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
