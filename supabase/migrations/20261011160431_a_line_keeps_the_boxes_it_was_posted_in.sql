-- Ekwo OS — a ledger line keeps the boxes it was posted in.
--
-- Reported by Pieterjan Muller on 11 October 2026 (issue #90).
--
-- A line carries one box, `declaration_box`, the one its posting is known by.
-- Since `20260915200000` a posting may print one amount in several boxes, and
-- since `20260912080311` it names the form it is on, `report_code`; neither
-- was on the line. `vat_return()` read both from **today's** `tax_postings`,
-- joined on the tax and the box at the moment the return is asked for. And
-- `tax_postings` changes: a member holding `settings.write` edits it, and
-- `pack_upgrade()` deletes and writes again every posting of a tax it moves.
-- Nothing compared that with `companies.tax_lock_date`. So a return already
-- filed, for a period already locked, could come out with other figures the
-- next time it was computed — and `filing_drift()` would say so afterwards,
-- with nothing having prevented it.
--
-- **The list and the form are frozen on the line.** Two columns,
-- `entry_lines.declaration_boxes` and `entry_lines.report_code`, written when
-- the line is written, from the posting that writes it, by the trigger of
-- `20261011155947` — which now both checks the box and copies what the
-- posting says about it. The line's box was always copied at that moment;
-- the boxes it is printed in and the form it is on are now copied with it,
-- and a posting changed afterwards moves no line already written. A posted
-- line moves no more than it did (`entry_lines_guard_posted`), so what it
-- says is what every return of its period will read.
--
-- **The rule is the one `vat_return()` applied at reading, applied once at
-- writing**, and written once: `declaration_boxes_of(tax, box, tax_line)`,
-- the postings of the tax that carry the box as the one they are known by, on
-- the side of the line, every box of their lists and the form they name — or
-- the line's own box alone and no form, where no posting answers. Which is
-- why freezing changes no figure of any return: the backfill below writes on
-- every line what the return read for it until today.
--
-- A reversal is the one writer that copies a line rather than a posting, and
-- it copies the frozen columns of the line it mirrors with its box: an entry
-- is undone in the boxes it was declared in, whatever the posting says now.
-- The two columns are the trigger's to write — a value given on an insert is
-- replaced, the way `declared_on` is, and a change by hand is refused,
-- `declaration_boxes_from_posting` — and `vat_return()` reads them, falling
-- back to `declaration_boxes_of()` only for a line that has none, which only
-- an archive written before this file brings through `import_company()`.
--
-- **The backfill** writes the two columns on every line that names a box,
-- with the guards of `20261005160859` lifted for the statement and put back
-- after it: `entry_lines_guard_posted`, because a posted line is being
-- completed and not changed; `entry_lines_guard_period`, because a locked
-- period is being completed too; `entry_lines_set_updated_at`, so that no
-- line is dated as edited; and the trigger of `20261011155947`, which would
-- otherwise put back what the backfill writes. The two triggers that fire on
-- other columns — the totals and `declared_on` — do not fire here.

-- ---------------------------------------------------------------------------
-- 1. The columns
-- ---------------------------------------------------------------------------

alter table entry_lines
  add column if not exists declaration_boxes text[],
  add column if not exists report_code text;

comment on column entry_lines.declaration_boxes is
  'Every box of the declaration this line is summed into, frozen when the line was written from the posting that wrote it: declaration_boxes_of() of its tax, its box and its side. Its first element is not necessarily declaration_box; the list is sorted. Null exactly where declaration_box is, except on a line restored from an archive written before 20261011160431, which vat_return() reads through the postings of today. Written by entry_lines_box_from_posting(), never by hand.';

comment on column entry_lines.report_code is
  'The declaration form the posting that wrote this line is on, frozen with declaration_boxes. Null where the posting names no form, which is the single return of a country that files one.';

-- ---------------------------------------------------------------------------
-- 2. The rule, once
-- ---------------------------------------------------------------------------

create or replace function declaration_boxes_of(
  p_tax_id   uuid,
  p_box      text,
  p_tax_line boolean,
  out boxes       text[],
  out report_code text
)
language sql
stable
as $$
  select array_agg(distinct b.box), min(tp.report_code)
    from tax_postings tp
    cross join lateral unnest(tp.declaration_boxes) as b(box)
   where tp.tax_id = p_tax_id
     and tp.declaration_box = p_box
     and tp.posting_type = (case when p_tax_line then 'tax' else 'base' end)::tax_posting_type;
$$;

comment on function declaration_boxes_of(uuid, text, boolean) is
  'What the postings of a tax say today about a ledger line of that tax in that box, on the tax side or not: every box their lists print it in, and the form they name. Null and null where none answers. The rule entry_lines_box_from_posting() freezes on a line when it is written, and the one vat_return() falls back on for a line that carries nothing frozen. Under the caller''s row level security.';

-- ---------------------------------------------------------------------------
-- 3. The trigger checks the box, and copies what the posting says about it
-- ---------------------------------------------------------------------------

create or replace function entry_lines_box_from_posting()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_boxes  text[];
  v_report text;
begin
  -- Nothing the frozen columns are read from has moved: they are what they
  -- were written as, and a hand that changes them is told so.
  if tg_op = 'UPDATE'
     and new.declaration_box is not distinct from old.declaration_box
     and new.tax_id is not distinct from old.tax_id
     and new.tax_line is not distinct from old.tax_line
     and new.posting_type is not distinct from old.posting_type then
    if new.declaration_boxes is distinct from old.declaration_boxes
       or new.report_code is distinct from old.report_code then
      raise exception 'declaration_boxes_from_posting: line % keeps the boxes and the form its posting gave it when it was written. They follow its box and its tax, and are not written by hand.',
        old.sequence
        using errcode = '55006';
    end if;
    return new;
  end if;

  if new.declaration_box is null then
    new.declaration_boxes := null;
    new.report_code := null;
    return new;
  end if;

  -- The mirror of a line already in the ledger, in the box that line carries
  -- and in every box it was declared in.
  select coalesce(o.declaration_boxes, array[o.declaration_box]), o.report_code
    into v_boxes, v_report
    from entries r
    join entry_lines o on o.entry_id = r.reversed_entry_id and o.company_id = r.company_id
   where r.id = new.entry_id
     and r.company_id = new.company_id
     and o.tax_id is not distinct from new.tax_id
     and o.tax_line is not distinct from new.tax_line
     and o.declaration_box = new.declaration_box
   order by o.sequence
   limit 1;
  if found then
    new.declaration_boxes := v_boxes;
    new.report_code := v_report;
    return new;
  end if;

  -- A posting of the line's tax that writes this box on this side.
  if not is_installer()
     and (new.tax_id is null or not exists (
       select 1 from tax_postings tp
        where tp.tax_id = new.tax_id
          and tp.company_id = new.company_id
          and tp.declaration_box = new.declaration_box
          and case when new.tax_line then tp.posting_type = 'tax'
                   else tp.posting_type in ('base', 'tax_on_base') end
          and (new.posting_type is null or tp.posting_type = new.posting_type))) then
    raise exception 'declaration_box_without_posting: line % names box %, and %. A box is written by the tax posting that produces the line.',
      new.sequence, new.declaration_box,
      case when new.tax_id is null then 'no tax'
           else 'no posting of its tax writes that box on the ' || case when new.tax_line then 'tax' else 'base' end || ' side' end
      using errcode = '23514';
  end if;

  select d.boxes, d.report_code into v_boxes, v_report
    from declaration_boxes_of(new.tax_id, new.declaration_box, new.tax_line) d;
  new.declaration_boxes := coalesce(v_boxes, array[new.declaration_box]);
  new.report_code := v_report;
  return new;
end;
$$;

comment on function entry_lines_box_from_posting() is
  'Refuses a ledger line whose declaration box is not one its tax posting writes — a line naming a box names a tax, and a posting of that tax writes that box: a tax posting for a tax line, a base or tax_on_base posting otherwise, of the line''s own posting_type when it states one (declaration_box_without_posting) — and freezes on the line what the posting says about the box: declaration_boxes and report_code, from declaration_boxes_of(). A reversal mirroring a line of the entry it reverses takes that line''s box and frozen columns. Fires on insert and on a change of the box, the tax, tax_line, posting_type or the two frozen columns; changed while nothing they are read from moved, they are refused (declaration_boxes_from_posting). The installer is not checked, and is frozen like everybody.';

drop trigger entry_lines_box_from_posting on entry_lines;
create trigger entry_lines_box_from_posting
  before insert or update of declaration_box, tax_id, tax_line, posting_type,
                             declaration_boxes, report_code on entry_lines
  for each row execute function entry_lines_box_from_posting();

-- ---------------------------------------------------------------------------
-- 4. The lines already written
-- ---------------------------------------------------------------------------

alter table entry_lines disable trigger entry_lines_guard_posted;
alter table entry_lines disable trigger entry_lines_guard_period;
alter table entry_lines disable trigger entry_lines_set_updated_at;
alter table entry_lines disable trigger entry_lines_box_from_posting;

update entry_lines l
   set declaration_boxes = coalesce(d.boxes, array[l.declaration_box]),
       report_code = d.report_code
  from entry_lines s
  cross join lateral declaration_boxes_of(s.tax_id, s.declaration_box, s.tax_line) d
 where s.id = l.id
   and l.declaration_box is not null;

alter table entry_lines enable trigger entry_lines_guard_posted;
alter table entry_lines enable trigger entry_lines_guard_period;
alter table entry_lines enable trigger entry_lines_set_updated_at;
alter table entry_lines enable trigger entry_lines_box_from_posting;

-- ---------------------------------------------------------------------------
-- 5. vat_return — `20261005160900`, the boxes and the form read on the line
-- ---------------------------------------------------------------------------

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
       where v_report is null or coalesce(a.lreport, v_report) = v_report
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
  'Declaration boxes for a period: summed from the ledger by the day each figure''s tax fell due — `entry_lines.declared_on`, read through declared_lines() — into the boxes and on the form each line was frozen with when it was written (entry_lines.declaration_boxes and report_code), so a posting changed afterwards moves no return; then the totals of the country''s form worked out by evaluate_totals(), the same evaluator financial_statement() uses. Refuses a period the company does not file **this form** on, when it has recorded one for it. No country rule lives in this function.';

-- ---------------------------------------------------------------------------
-- Grants
--
-- declaration_boxes_of() is read by vat_return(), under the caller's row
-- level security, by a signed-in user and by the operator. vat_return() and
-- the trigger body are replaced, which keeps their privileges; they are said
-- again all the same.
-- ---------------------------------------------------------------------------

revoke execute on function declaration_boxes_of(uuid, text, boolean) from public, anon;
grant execute on function declaration_boxes_of(uuid, text, boolean) to authenticated, service_role;

revoke execute on function entry_lines_box_from_posting() from public, anon, authenticated, service_role;

revoke execute on function vat_return(uuid, date, date, text) from public, anon;
grant execute on function vat_return(uuid, date, date, text) to authenticated, service_role;
