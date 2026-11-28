-- Ekwo OS — a form names the territory it is filed in.
--
-- A pack carried one periodic return, and that was one too few for a country
-- with no national return and one per state. The United States levies its
-- sales tax by state, each on its own form, to its own administration: the
-- pack us carried California's CDTFA-401-A and had nowhere to put New York's
-- ST-100, so the New York tax was posted to the ledger and reached no box of
-- any return (docs/international.md, "What the United States showed").
--
-- The core already held more than one form per country — `vat_return()` takes
-- `p_report_code`, `company_filing_periods` records a cadence per form, and a
-- posting names the form its boxes are on (`20260915200000`). What it could
-- not say is **whose** periodic return a form is. Two periodic forms of one
-- country were one return too many: `periodic_return_code()` answered null,
-- `vat_return()` without a form refused as ambiguous, and the calendar listed
-- nothing.
--
-- **One column.** `tax_report_templates.territory_code`, a territory inside
-- the form's country, null on a form of the whole country. A form that names
-- one is the periodic return of a company established inside that territory,
-- and of nobody else. A company of another territory files it where it records
-- a cadence for it in `company_filing_periods` — a Californian seller with
-- nexus in New York — and names it when it asks for the return.
--
-- **Two readers follow it, and nothing else changes.**
--
--   `periodic_return_code()`  the periodic form of the company's country that
--       is the whole country's or its territory's. A company with no
--       territory recorded is held to every periodic form of its country, as
--       before, so a pack that names none answers exactly what it answered.
--   `vat_return()`            the same filter where no form is named; the
--       body is otherwise the one of `20261022110100`, as the catalogue holds
--       it since `20261028040000` moved it to `ekwo`.
--
-- The mirror of `companies.vat_period`, the calendar of `upcoming_filings()`
-- and `filing_deadline()` read `periodic_return_code()` and follow without
-- being touched.
--
-- **A seed that names no territory does not mention the column**, so every
-- pack whose forms are the whole country's still loads on a schema from before
-- this file. Additive: a column and two functions redefined with their
-- arguments and their answer.

alter table ekwo.tax_report_templates
  add column if not exists territory_code text references ekwo.territories (code);
create index if not exists tax_report_templates_territory_idx on ekwo.tax_report_templates (territory_code);

comment on column ekwo.tax_report_templates.territory_code is
  'The territory inside the form''s country this form is filed in, from packs/<cc>/tax_report.json `territory`: California''s return names US-CA. Null on a form of the whole country. A periodic form that names one is the periodic return of a company established inside that territory (periodic_return_code(), vat_return() when no form is named); a company elsewhere files it where it records a cadence for it.';

create or replace function ekwo.periodic_return_code(p_company_id uuid)
returns text
language sql
stable
as $$
  select case when count(distinct t.code) = 1 then min(t.code) end
    from companies c
    join tax_report_templates t on t.country = c.fiscal_country
   where c.id = p_company_id
     and t.is_periodic_return
     and (t.territory_code is null or c.territory_code is null
          or territory_within(c.territory_code, t.territory_code));
$$;
comment on function ekwo.periodic_return_code(uuid) is
  'The code of the periodic return the company files where it is: the form of its fiscal country that is the whole country''s, or the one of the territory the company is established in (tax_report_templates.territory_code), when the installation carries exactly one. Null when it carries none — no pack for that country — and null when it carries several, because then no single form is what a column named after "the" return could mean. It is what holds companies.vat_period and company_filing_periods in step, and it names the form by asking the pack rather than by knowing a country.';

create or replace function ekwo.vat_return(p_company_id uuid, p_from date, p_to date, p_report_code text default null)
returns table(box text, kind text, amount numeric, computed boolean, name text, sequence integer, print_sequence integer, hidden boolean, report_code text)
language plpgsql
stable
set search_path = ekwo, pg_temp
as $function$
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
  -- Where the company is, below its country: the form of its territory is
  -- the one it files when it names none.
  v_territory text;
  r          record;
begin
  select c.fiscal_country, c.territory_code into v_country, v_territory
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
  -- that date for where the company is: a form that names a territory is the
  -- periodic return of a company established inside it, and of nobody else.
  -- Two and no name is a question only the caller can answer — a Canadian
  -- company files the federal return and the Québec one at once — so this
  -- asks instead of guessing.
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
       and (t.territory_code is null or v_territory is null
            or territory_within(v_territory, t.territory_code))
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
$function$;

comment on function ekwo.vat_return(uuid, date, date, text) is
  'Declaration boxes for a period: summed from the ledger by the day each figure''s tax fell due — `entry_lines.declared_on`, read through declared_lines() — into the boxes and on the form each line was frozen with when it was written (entry_lines.declaration_boxes and report_code), so a posting changed afterwards moves no return; then the totals of the country''s form worked out by evaluate_totals(), the same evaluator financial_statement() uses. A form that restates another (reads_postings_of) adds up the boxes of that form each of its boxes names, and a box that reads the payments on account of the declaration takes them from declaration_instalments or instalment_plan(). With no form named it takes the periodic return of the company''s country that is the whole country''s or the one of its territory (tax_report_templates.territory_code), and asks when there are several. Refuses a period the company does not file **this form** on, when it has recorded one for it; under the scheme the company is on (company_vat_schemes) refuses a form the scheme does not file and a cadence it does not file it on, and takes the scheme''s form when none is named. No country rule lives in this function.';

