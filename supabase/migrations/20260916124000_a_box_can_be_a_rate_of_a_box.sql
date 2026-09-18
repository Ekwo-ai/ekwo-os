-- Ekwo OS — a box of a declaration can be a rate applied to another box, and
-- the order a form is printed in stops deciding the order it is worked out in.
--
-- Two changes, and they are one change: the second is what the first needs to
-- be safe.
--
-- ---------------------------------------------------------------------------
-- 1. `rate` and `rate_of_box`
-- ---------------------------------------------------------------------------
--
-- Until now a computed box was a list of boxes to add and a list to subtract.
-- That covers every European return this repository carries, because a
-- European return reports a tax the ledger already holds: the amount was
-- worked out document by document, posted, and the form only adds it up.
--
-- A form that is not a value added tax return does not work that way.
-- CDTFA-401-A states four of its lines as a multiplication in as many words:
-- line 13 is line 12 times 0.06, line 14 is line 12 times 0.0025, line 15 is
-- line 12 times 0.01, and Sections C and D are a base times 0.05 and times
-- 0.039375. The taxable total is worked out once, for the period, and the
-- rates are applied to it.
--
-- **A rate is not an expression.** It is the one arithmetic a declaration form
-- actually writes out, and it is said here with two named fields and no
-- syntax: `rate` is a percentage and `rate_of_box` is the box it applies to.
-- There is still nothing a pack can execute, nothing to parse, and a reviewer
-- reads `6.00 of box 12` in the diff. The alternative — an expression language
-- — is the thing `20260912090407` refused and this does not reopen it.
--
-- Three rules hold it in place, as constraints rather than as conventions:
--
--   * a rate names a box, and a box named by a rate needs a rate: the pair is
--     declared together or not at all;
--   * only a computed box carries one, which is the rule `plus` and `minus`
--     already follow — `kind` says how a box gets its amount, and a box the
--     ledger fills cannot also be derived;
--   * a rate and a list are two ways of computing one box, so a box takes one
--     or the other. A box that was both would be a formula, quietly.
--
-- A box that names itself is refused here too, by name, rather than left to
-- the evaluator's cycle detection: `rate_of_box` is one reference, so the
-- shortest cycle is visible to a `check`.
--
-- ---------------------------------------------------------------------------
-- 2. `print_sequence`
-- ---------------------------------------------------------------------------
--
-- `sequence` has meant two things at once since the boxes became data: the
-- order a form prints its boxes in, and the order they are worked out in.
-- Three packs have now paid for that. Luxembourg's eCDF return prints a
-- subtotal above the boxes it adds up; Estonia escaped it by luck; and
-- CDTFA-401-A prints line 11 on page 1 and computes it from Sections A and B
-- on page 3, so `packs/us` orders its form by dependency and the order the
-- administration prints it in is lost.
--
-- `evaluate_totals()` has worked the totals out in the order they depend on
-- each other since `20260912104719`, so the evaluation half of the conflation
-- was already fiction: what remained was a rule in `ekwo pack check` refusing
-- a total that names a total declared after it, which forced a pack to spend
-- its one ordering field on the evaluator. That rule goes, replaced by the
-- cycle check the statements already have, and `print_sequence` carries the
-- order the form is printed in where it differs from the order the pack
-- declares its boxes in.
--
-- Null means "the same as `sequence`", which is what every pack written before
-- this said, and `vat_return()` answers the resolved value so a renderer has
-- one column to order by and never two.
--
-- A rate makes the separation necessary rather than merely tidy: a box worked
-- out from another box has a dependency the form's own print order knows
-- nothing about, and a pack should not have to choose which of the two it
-- writes down.

-- ---------------------------------------------------------------------------
-- The columns
-- ---------------------------------------------------------------------------

alter table tax_report_box_templates
  add column if not exists rate           numeric,
  add column if not exists rate_of_box    text,
  add column if not exists print_sequence integer;

comment on column tax_report_box_templates.rate is
  'Percentage this box applies to the box named by rate_of_box. The one arithmetic a declaration form writes out; not an expression, and never a second way to say plus.';
comment on column tax_report_box_templates.rate_of_box is
  'The box the rate is applied to, bare or qualified with its kind (`12:total`), resolved the way a plus reference is.';
comment on column tax_report_box_templates.print_sequence is
  'Where the administration prints this box, when that is not where the pack declares it. Null means the same as sequence: a form prints a subtotal above what it adds up, and the evaluation order is the dependencies and never this.';

alter table tax_report_box_templates
  add constraint tax_report_box_templates_rate_names_a_box
    check ((rate is null) = (rate_of_box is null)),
  add constraint tax_report_box_templates_rate_is_a_total
    check (rate is null or kind = 'total'),
  add constraint tax_report_box_templates_rate_or_a_list
    check (rate is null or (plus_boxes = '{}'::text[] and minus_boxes = '{}'::text[])),
  add constraint tax_report_box_templates_rate_is_not_itself
    check (rate_of_box is null or split_part(rate_of_box, ':', 1) <> box);

-- ---------------------------------------------------------------------------
-- evaluate_totals — the one evaluator, which now knows one more shape
-- ---------------------------------------------------------------------------
--
-- Replaced whole, because a function is replaced whole in PostgreSQL. The
-- signature does not move, so there is nothing to drop and nothing to grant
-- again. Everything but the rate is `20260914121200` unchanged.
--
-- A formula may now carry `rate` and `rate_of` instead of `plus` and `minus`.
-- It is the same machine either way: the reference set decides when the
-- formula is ready, and a pass that settles nothing is still a cycle that says
-- which keys are in it. A statement passes neither field and reads exactly as
-- it did.

create or replace function evaluate_totals(
  p_values    jsonb,
  p_formulas  jsonb,
  p_rounding  money_rounding,
  p_keep_zero boolean default false
)
returns jsonb
language plpgsql
immutable
as $$
declare
  v_values  jsonb := coalesce(p_values, '{}'::jsonb);
  v_out     jsonb := '{}'::jsonb;
  v_done    jsonb := '{}'::jsonb;
  v_all     jsonb := coalesce(p_formulas, '[]'::jsonb);
  v_left    integer;
  v_settled integer;
  v_ready   boolean;
  v_amount  numeric;
  v_part    numeric;
  v_refs    text[];
  v_ref     text;
  v_key     text;
  v_rate    numeric;
  v_of      text;
  v_stuck   text;
  f         jsonb;
begin
  select count(*) into v_left from jsonb_array_elements(v_all);

  while v_left > 0 loop
    v_settled := 0;

    for f in
      select t.x from jsonb_array_elements(v_all) with ordinality as t(x, ord)
       order by coalesce((t.x ->> 'sequence')::integer, 0), t.ord
    loop
      v_key := f ->> 'key';
      if v_done ? v_key then
        continue;
      end if;

      v_rate := (f ->> 'rate')::numeric;
      v_of   := f ->> 'rate_of';

      -- Every reference this formula reads, whichever shape it is written in.
      -- A rate has exactly one, and it is held to the same readiness rule as a
      -- member of a plus list: a box worked out from a box has to wait for it.
      select coalesce(array_agg(e.value), '{}'::text[]) into v_refs
        from (
          select jsonb_array_elements_text(coalesce(f -> 'plus', '[]'::jsonb)) as value
          union all
          select jsonb_array_elements_text(coalesce(f -> 'minus', '[]'::jsonb))
          union all
          select v_of where v_of is not null
        ) as e;

      -- Ready when every reference that names another formula has been worked
      -- out already.
      v_ready := true;
      foreach v_ref in array v_refs loop
        if exists (
          select 1 from jsonb_array_elements(v_all) as g(x)
           where (g.x ->> 'key') <> v_key
             and not (v_done ? (g.x ->> 'key'))
             and case when strpos(v_ref, ':') > 0
                      then (g.x ->> 'key') = replace(v_ref, ':', '|')
                      else split_part((g.x ->> 'key'), '|', 1) = v_ref
                 end
        ) then
          v_ready := false;
        end if;
      end loop;
      if not v_ready then
        continue;
      end if;

      if v_of is not null then
        -- A rate: one reference, resolved exactly as a plus reference is, and
        -- a percentage applied to it.
        select coalesce(sum(e.value::numeric), 0) into v_part
          from jsonb_each_text(v_values) as e(key, value)
         where case when strpos(v_of, ':') > 0
                    then e.key = replace(v_of, ':', '|')
                    else split_part(e.key, '|', 1) = v_of
               end;
        v_amount := v_part * v_rate / 100;
      else
        v_amount := 0;
        for v_ref in
          select jsonb_array_elements_text(coalesce(f -> 'plus', '[]'::jsonb))
        loop
          select coalesce(sum(e.value::numeric), 0) into v_part
            from jsonb_each_text(v_values) as e(key, value)
           where case when strpos(v_ref, ':') > 0
                      then e.key = replace(v_ref, ':', '|')
                      else split_part(e.key, '|', 1) = v_ref
                 end;
          v_amount := v_amount + v_part;
        end loop;
        for v_ref in
          select jsonb_array_elements_text(coalesce(f -> 'minus', '[]'::jsonb))
        loop
          select coalesce(sum(e.value::numeric), 0) into v_part
            from jsonb_each_text(v_values) as e(key, value)
           where case when strpos(v_ref, ':') > 0
                      then e.key = replace(v_ref, ':', '|')
                      else split_part(e.key, '|', 1) = v_ref
                 end;
          v_amount := v_amount - v_part;
        end loop;
      end if;

      -- The floor belongs to the pair it splits — the Belgian 71 and 72, the
      -- French 25 and 28 — so it applies before the sign the caller reads the
      -- line with.
      if coalesce((f ->> 'floor_zero')::boolean, false) then
        v_amount := greatest(v_amount, 0);
      end if;
      v_amount := round_amount(v_amount * coalesce((f ->> 'factor')::numeric, 1), p_rounding);

      v_values := v_values || jsonb_build_object(v_key, v_amount);
      v_done   := v_done   || jsonb_build_object(v_key, true);
      if p_keep_zero or v_amount <> 0 then
        v_out := v_out || jsonb_build_object(v_key, v_amount);
      end if;
      v_settled := v_settled + 1;
      v_left := v_left - 1;
    end loop;

    if v_settled = 0 then
      select string_agg(t.x ->> 'key', ', ' order by t.x ->> 'key') into v_stuck
        from jsonb_array_elements(v_all) as t(x)
       where not (v_done ? (t.x ->> 'key'));
      raise exception 'formula_cycle: these totals depend on each other and on nothing else: %', v_stuck;
    end if;
  end loop;

  return v_out;
end;
$$;

comment on function evaluate_totals(jsonb, jsonb, money_rounding, boolean) is
  'Works out the totals of a declaration form or of a financial statement — a plus/minus list, or a rate applied to one other key — in the order they depend on each other. The one place that calculation lives: vat_return() and financial_statement() both call it.';

-- ---------------------------------------------------------------------------
-- vat_return — passes the rate through, and answers the print order
-- ---------------------------------------------------------------------------
--
-- Dropped and recreated rather than replaced, because the returned table gains
-- a column and PostgreSQL will not change that in place. The three-argument
-- call every client makes keeps working: `p_report_code` still defaults.
--
-- Two changes, and everything else is `20260916094500` unchanged:
--
--   * the formulas handed to the evaluator carry `rate` and `rate_of`, so a
--     box stated as a percentage of another box is worked out by the same
--     function as every other total;
--   * every row answers `print_sequence`, resolved — the box's own where it
--     declares one, `sequence` where it does not — so a renderer orders by one
--     column. The rows themselves still come back in `sequence` order, which
--     is the order the pack declares and what every caller reads today.

drop function if exists vat_return(uuid, date, date, text);

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
           b.sequence as lsequence,
           coalesce(b.print_sequence, b.sequence) as lprint,
           coalesce(b.hidden, false) as lhidden
      from ledger g
      left join tax_report_box_templates b
        on b.country = v_in and b.report_code = v_report
       and b.box = g.lbox and b.kind = g.lkind
     order by coalesce(b.sequence, 2147483647), g.lbox, g.lkind
  loop
    v_values := v_values || jsonb_build_object(r.lbox || '|' || r.lkind, r.lamount);
    v_rows := v_rows || jsonb_build_array(jsonb_build_object(
      'box', r.lbox, 'kind', r.lkind, 'amount', r.lamount, 'computed', false,
      'name', r.lname, 'sequence', r.lsequence, 'print_sequence', r.lprint,
      'hidden', r.lhidden, 'report_code', v_report));
  end loop;

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
  'Declaration boxes for a period: summed from the ledger, then the totals of the country''s form — a plus/minus list or a rate of another box — worked out by evaluate_totals(), the same evaluator financial_statement() uses. Answers print_sequence beside sequence, because the order a form is printed in is not the order it is worked out in. No country rule lives in this function.';

-- Rule 6 of supabase/migrations/README.md: a function created here comes out
-- executable by PUBLIC otherwise.
revoke execute on all functions in schema public from public;

-- And rule 7: the object this file creates names the roles that may reach it.
revoke execute on function vat_return(uuid, date, date, text) from public, anon;
grant execute on function vat_return(uuid, date, date, text) to authenticated, service_role;

-- `evaluate_totals()` was replaced in place and keeps the grants
-- `20260914121200` gave it; the blanket revoke above is never aimed at `anon`,
-- which holds explicit grants on the policy helpers, so naming it here takes
-- nothing else away.
revoke execute on function evaluate_totals(jsonb, jsonb, money_rounding, boolean) from public, anon;
grant execute on function evaluate_totals(jsonb, jsonb, money_rounding, boolean) to authenticated, service_role;
