-- Ekwo OS — the period of a tax return is read through an index.
--
-- `20261005160858` stores on every ledger line the day it counts for a
-- return, `declared_on`, and `20261005160859` filled it on the lines already
-- written and indexed it. This file moves every reader of the rule onto it.
--
-- **One predicate.** Which lines belong to a period is now said in one place,
-- `declared_lines(company, from, to)`: the lines of the company whose
-- `declared_on` falls between the two dates. It is a plain SQL function,
-- stable, invoker and without settings, so Postgres inlines it into the
-- statement that calls it and plans the period as an ordinary range on an
-- indexed column. Three functions read it, and they were the three that wrote
-- `coalesce(l.tax_point_date, e.entry_date) between …` themselves:
--
--   vat_return()             the boxes of a period
--   filing_tax_movements()   the tax accounts a declared period moved
--   filings_touched_since()  the declarations the ledger moved after they went
--
-- `settle_filing()` and `filing_drift()` read the first two and change with
-- them. Each function is written again below as it was published, with the
-- period read through `declared_lines()` and nothing else changed.
--
-- A caller that asks for the lines naming a box — the return and the list of
-- disturbed declarations — adds `declaration_box is not null`, and the
-- planner reaches the period through `entry_lines_declared_on_idx`. The tax
-- accounts of a filing are read on the tax lines of the period, with or
-- without a box, exactly as before.
--
-- **The archive.** `import_company()` loads with the triggers of the tables it
-- fills switched off, so `declared_on` arrives with the rows of the archive
-- and leaves with the next export, identical. Two additions, written into the
-- function below and nowhere else:
--
--   * an archive written before the column existed carries none. The import
--     derives it from the archive's own lines and entries, with
--     `declared_on_of()`, before it loads them;
--   * an archive that carries one has it checked against the same rule once
--     the rows are in, like the balance of an entry: a day that is not the
--     rule's is `declared_on_mismatch`, and nothing is imported.

-- ---------------------------------------------------------------------------
-- declared_lines — which lines belong to a period
-- ---------------------------------------------------------------------------

create or replace function declared_lines(p_company_id uuid, p_from date, p_to date)
returns setof entry_lines
language sql
stable
as $$
  select l.*
    from entry_lines l
   where l.company_id = p_company_id
     and l.declared_on between p_from and p_to;
$$;

comment on function declared_lines(uuid, date, date) is
  'The ledger lines of a company that count for a tax return of the period from–to, both days included: those whose declared_on falls inside it. The one statement of period membership, read by vat_return(), filing_tax_movements() and filings_touched_since(). Inlined by the planner, so a caller that adds `declaration_box is not null` reads the period through entry_lines_declared_on_idx. Under the caller''s row level security.';

revoke execute on function declared_lines(uuid, date, date) from public, anon;
grant execute on function declared_lines(uuid, date, date) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- vat_return — `20260916126000`, the period read through declared_lines()
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
        -- The period a figure belongs to is the day its tax fell due: the
        -- line's `declared_on`, which `declared_lines()` reads.
        from declared_lines(p_company_id, p_from, p_to) l
        join entries e on e.id = l.entry_id
       where e.state = 'posted'
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
  'Declaration boxes for a period: summed from the ledger by the day each figure''s tax fell due — `entry_lines.declared_on`, read through declared_lines() — then the totals of the country''s form worked out by evaluate_totals(), the same evaluator financial_statement() uses. Refuses a period the company does not file **this form** on, when it has recorded one for it. No country rule lives in this function.';

revoke execute on function vat_return(uuid, date, date, text) from public, anon;
grant execute on function vat_return(uuid, date, date, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- filing_tax_movements and filings_touched_since — `20260917200000`, the
-- period read through declared_lines()
-- ---------------------------------------------------------------------------

create or replace function filing_tax_movements(p_filing_id uuid)
returns table (account_id uuid, balance numeric)
language sql
stable
security invoker
as $$
  with f as (
    select * from tax_filings where id = p_filing_id
  ),
  moved as (
    select l.account_id, sum(l.balance) as balance
      from f
      cross join lateral declared_lines(f.company_id, f.period_start, f.period_end) l
      join entries e     on e.id = l.entry_id
     where e.state = 'posted'
       and l.tax_line
     group by l.account_id
  ),
  already as (
    select l.account_id, sum(l.balance) as balance
      from f
      join tax_filings p
        on p.company_id = f.company_id
       and p.report_code = f.report_code
       and p.period_start = f.period_start
       and p.period_end = f.period_end
       and p.id <> f.id
       and p.settlement_entry_id is not null
      join entry_lines l on l.entry_id = p.settlement_entry_id
      join moved m       on m.account_id = l.account_id
     group by l.account_id
  )
  select m.account_id,
         round_amount(m.balance + coalesce(a.balance, 0), rounding_of(f.company_id))
    from f, moved m
    left join already a on a.account_id = m.account_id
   where round_amount(m.balance + coalesce(a.balance, 0), rounding_of(f.company_id)) <> 0;
$$;

comment on function filing_tax_movements(uuid) is
  'The tax accounts a declared period moved and by how much, on the same window and the same tax-point rule the return read, net of what an earlier settlement of the same period already carried. What settle_filing() clears — the whole period the first time, the difference on a corrective — and what anybody can read before it does.';

revoke execute on function filing_tax_movements(uuid) from public, anon;
grant execute on function filing_tax_movements(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- filings_touched_since
--
-- The reading the whole freeze was for. A declaration is listed when the
-- ledger moved inside its period **after** it was filed — not when the figures
-- happen to differ, which is `filing_drift()`'s question, because an entry
-- that nets to nothing in every box is still an entry somebody posted into a
-- period that had gone.
--
-- What counts as moving it is a line that names a box, which is the same test
-- the tax lock uses to decide what it protects. Two readings of "an entry
-- that concerns the declaration" would eventually disagree, and a payroll
-- entry landing in a declared quarter is not news. It also leaves out the
-- settlement of the declaration itself, which is posted at the end of the
-- period and after the filing, and is the opposite of a disturbance.
--
-- Read-only, and it names nothing to do: whether a change is a corrective to
-- file, an entry in the wrong period, or a legitimate movement that changes no
-- figure, is a judgement, and the database's job is to stop it being invisible.
-- ---------------------------------------------------------------------------

create or replace function filings_touched_since(
  p_company_id uuid,
  p_from       date default null,
  p_to         date default null
)
returns table (
  filing_id     uuid,
  report_code   text,
  period_start  date,
  period_end    date,
  state         tax_filing_state,
  filed_at      timestamptz,
  entries       integer,
  last_entry_at timestamptz,
  boxes_moved   integer
)
language sql
stable
security invoker
as $$
  select f.id, f.report_code, f.period_start, f.period_end, f.state, f.filed_at,
         t.entries::integer, t.last_entry_at,
         (select count(*) from filing_drift(f.id))::integer
    from tax_filings f
    cross join lateral (
      select count(distinct e.id) as entries, max(e.posted_at) as last_entry_at
        from declared_lines(f.company_id, f.period_start, f.period_end) l
        join entries e on e.id = l.entry_id
       where e.state = 'posted'
         and e.posted_at > f.filed_at
         and l.declaration_box is not null
    ) t
   where f.company_id = p_company_id
     and f.filed_at is not null
     and f.state <> 'superseded'
     and (p_from is null or f.period_end >= p_from)
     and (p_to is null or f.period_start <= p_to)
     and t.entries > 0
   order by f.period_start, f.report_code;
$$;

-- ---------------------------------------------------------------------------
-- import_company — `20260929151700`, with declared_on derived for an archive
-- that predates it and checked for one that carries it
-- ---------------------------------------------------------------------------

create or replace function import_company(p_archive jsonb, p_owner_user_id uuid default null)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_archive   jsonb;
  v_manifest  jsonb;
  v_tables    jsonb;
  v_company   uuid;
  v_owner     uuid := coalesce(p_owner_user_id, auth.uid());
  v_item      jsonb;
  v_problem   record;
  v_table     record;
  v_class     regclass;
  v_rows      jsonb;
  v_count     bigint;
  v_checksum  text;
  v_values    text;
  v_columns   text[];
  v_deferred  text[];
  v_unknown   text;
  v_select    text;
  v_silenced  regclass[] := '{}';
  v_second    jsonb := '[]'::jsonb;
  v_were_off  jsonb := '[]'::jsonb;
  v_pass      jsonb;
  v_fk        record;
  v_total     bigint := 0;
  v_name      text;
  v_found     text;
begin
  -- The guard, first and in the open: the two callers who may create a company
  -- here, and nobody else. A definer function that checks nobody is how two
  -- doors were found open on 18 September.
  --
  -- `is not true`, not `not`: a helper that answers NULL turns `if not … and
  -- not …` into an `if NULL`, which does not raise. `is_installer()` did, until
  -- `20260918140000`, for the backend role through the API. The guard is
  -- written so that it holds whatever the helpers answer.
  if is_installer() is not true and is_instance_admin() is not true then
    raise exception 'not_instance_admin: taking a company into this installation is an instance-level act'
      using errcode = '42501';
  end if;

  -- A table a module has renamed since the archive was written is read under
  -- the name it has today; nothing else of the archive changes.
  v_archive  := archive_under_current_names(p_archive);
  v_manifest := v_archive -> 'manifest';
  v_tables   := coalesce(v_archive -> 'tables', '{}'::jsonb);

  if v_manifest is null or v_manifest ->> 'format' is distinct from 'ekwo.company-archive' then
    raise exception 'not_an_archive: this document does not say it is an ekwo.company-archive';
  end if;
  if v_manifest ->> 'format_version' is distinct from '1' then
    raise exception 'unknown_archive_version: this installation reads version 1 of the format, and the archive says %',
      coalesce(v_manifest ->> 'format_version', 'nothing');
  end if;
  if not coalesce(version_at_least(ekwo_schema_version(), v_manifest ->> 'socle_version'), false) then
    raise exception 'socle_too_old: the archive was written by socle % and this installation is %. Run `ekwo migrate` first.',
      v_manifest ->> 'socle_version', ekwo_schema_version()
      using errcode = '55006';
  end if;

  -- What the company needs is read from its rows as well as from the manifest:
  -- the manifest is a summary somebody could have edited, the rows are what
  -- will be here afterwards.
  for v_item in
    select jsonb_build_object('country', e ->> 'country', 'version', e ->> 'version')
      from jsonb_array_elements(coalesce(v_tables -> 'public.company_packs', '[]'::jsonb)) e
    union
    select jsonb_build_object('country', m ->> 'country', 'version', m ->> 'version')
      from jsonb_array_elements(coalesce(v_manifest -> 'packs', '[]'::jsonb)) m
  loop
    select p.version into v_found from country_packs p where p.country = v_item ->> 'country';
    if not found then
      raise exception 'pack_missing: the company holds the % pack and this installation does not', v_item ->> 'country'
        using errcode = '55006';
    end if;
    if not coalesce(version_at_least(v_found, v_item ->> 'version'), false) then
      raise exception 'pack_too_old: the company is on version % of the % pack and this installation holds %',
        v_item ->> 'version', v_item ->> 'country', v_found
        using errcode = '55006';
    end if;
  end loop;

  for v_item in
    select jsonb_build_object('code', m ->> 'code', 'version', m ->> 'version')
      from jsonb_array_elements(coalesce(v_manifest -> 'modules', '[]'::jsonb)) m
    union
    select jsonb_build_object('code', e ->> 'module_code', 'version', null)
      from jsonb_array_elements(coalesce(v_tables -> 'public.company_modules', '[]'::jsonb)) e
  loop
    select m.version into v_found from modules m where m.code = v_item ->> 'code';
    if not found then
      raise exception 'module_missing: the company uses the % module and this installation does not carry it', v_item ->> 'code'
        using errcode = '55006';
    end if;
    if v_item ->> 'version' is not null and not version_at_least(v_found, v_item ->> 'version') then
      raise exception 'module_too_old: the company used version % of the % module and this installation holds %',
        v_item ->> 'version', v_item ->> 'code', v_found
        using errcode = '55006';
    end if;
  end loop;

  v_company := (v_manifest #>> '{company,id}')::uuid;
  if v_company is null then
    raise exception 'not_an_archive: the manifest names no company';
  end if;
  -- Identifiers are kept, so a company is here or it is not. This is also what
  -- a second run of the same import meets.
  if exists (select 1 from companies c where c.id = v_company) then
    raise exception 'company_already_here: % is a company of this installation. An import never merges: a company arrives whole, once.', v_company
      using errcode = '23505';
  end if;

  select * into v_problem from company_archive_unclassified() limit 1;
  if found then
    raise exception 'unclassified_table: %.% % — this installation cannot say what an archive is made of',
      v_problem.table_schema, v_problem.table_name, v_problem.problem
      using errcode = '55006';
  end if;

  -- The manifest and the tables say the same thing, and every table is one
  -- this installation exports itself.
  for v_name in select jsonb_object_keys(v_tables) loop
    if not exists (select 1 from jsonb_array_elements(v_manifest -> 'tables') m where m ->> 'name' = v_name) then
      raise exception 'archive_corrupt: the archive carries rows of % and its manifest does not list it', v_name;
    end if;
  end loop;
  for v_item in select jsonb_array_elements(coalesce(v_manifest -> 'tables', '[]'::jsonb)) loop
    v_name := v_item ->> 'name';
    if not exists (select 1 from company_archive_tables() t
                    where t.table_schema || '.' || t.table_name = v_name and t.disposition = 'exported') then
      raise exception 'unknown_table: the archive carries %, which this installation does not know as a table of a company', v_name
        using errcode = '55006';
    end if;
    v_rows := coalesce(v_tables -> v_name, '[]'::jsonb);
    -- Two checksums, and the manifest says which one this archive carries.
    -- `values_sha256` is over the canonical form of the rows, which a reader
    -- reproduces after parsing them; `sha256` is over the bytes the database
    -- wrote, which is what `shasum` checks on the file and what an archive
    -- from 0.8.0 or earlier carries alone. Whichever is checked, the answer to
    -- a changed value is the same refusal.
    select count(*),
           encode(sha256(convert_to(coalesce(string_agg(x.r::text || E'\n', '' order by x.n), ''), 'UTF8')), 'hex'),
           encode(sha256(convert_to(coalesce(string_agg(canonical_json(x.r)::text || E'\n', '' order by x.n), ''), 'UTF8')), 'hex')
      into v_count, v_checksum, v_values
      from jsonb_array_elements(v_rows) with ordinality as x(r, n);
    if v_count is distinct from (v_item ->> 'rows')::bigint then
      raise exception 'archive_corrupt: % does not match its manifest (% rows against %)',
        v_name, v_count, v_item ->> 'rows';
    end if;
    if v_item ? 'values_sha256' then
      if v_values is distinct from v_item ->> 'values_sha256' then
        raise exception 'archive_corrupt: the values of % are not the ones its manifest was written for', v_name;
      end if;
    elsif v_checksum is distinct from v_item ->> 'sha256' then
      raise exception 'archive_corrupt: % does not match its manifest (another checksum). An archive written before 0.9.0 carries a checksum of its bytes, so a reader that printed it again changed them — keep the archive as the database wrote it, or export it again.',
        v_name;
    end if;
  end loop;

  if jsonb_array_length(coalesce(v_tables -> 'public.companies', '[]'::jsonb)) <> 1 then
    raise exception 'foreign_row: an archive holds one company, and this one holds % rows of public.companies',
      jsonb_array_length(coalesce(v_tables -> 'public.companies', '[]'::jsonb));
  end if;

  -- An archive written before `entry_lines.declared_on` existed carries none.
  -- The day is derived from the archive's own lines and entries, by the rule
  -- the column stores, before anything is loaded; the checksums above were
  -- read on the archive as it was written.
  if jsonb_array_length(coalesce(v_tables -> 'public.entry_lines', '[]'::jsonb)) > 0
     and not ((v_tables -> 'public.entry_lines' -> 0) ? 'declared_on') then
    v_tables := jsonb_set(v_tables, array['public.entry_lines'], (
      select jsonb_agg(x.l || jsonb_build_object('declared_on',
                         declared_on_of((x.l ->> 'tax_point_date')::date, (e.v ->> 'entry_date')::date))
                       order by x.n)
        from jsonb_array_elements(v_tables -> 'public.entry_lines') with ordinality as x(l, n)
        left join jsonb_array_elements(coalesce(v_tables -> 'public.entries', '[]'::jsonb)) as e(v)
          on e.v ->> 'id' = x.l ->> 'entry_id'));
  end if;

  -- First pass: the rows, in the order the registry names.
  for v_table in
    select t.table_schema, t.table_name, t.load_order,
           t.table_schema || '.' || t.table_name as name
      from company_archive_tables() t
     where t.disposition = 'exported'
     order by t.load_order, t.table_schema, t.table_name
  loop
    v_rows := coalesce(v_tables -> v_table.name, '[]'::jsonb);
    continue when jsonb_array_length(v_rows) = 0;
    v_class := to_regclass(format('%I.%I', v_table.table_schema, v_table.table_name));
    v_total := v_total + jsonb_array_length(v_rows);

    -- A column this installation does not have is data it would drop in
    -- silence. It refuses instead.
    select k.key into v_unknown
      from (select distinct jsonb_object_keys(e) as key from jsonb_array_elements(v_rows) e) k
     where not exists (select 1 from pg_attribute a
                        where a.attrelid = v_class and a.attname = k.key
                          and a.attnum > 0 and not a.attisdropped)
     limit 1;
    if v_unknown is not null then
      raise exception 'unknown_column: %.% is in the archive and not in this installation', v_table.name, v_unknown
        using errcode = '55006';
    end if;

    -- Every row has the columns of the first. The list of columns written is
    -- read from one row; a key that only a later row carries would be dropped
    -- in silence, and one it lacks would be written as null over a default.
    if exists (select 1 from jsonb_array_elements(v_rows) e
                where (select array_agg(k order by k) from jsonb_object_keys(e) k)
                      is distinct from
                      (select array_agg(k order by k) from jsonb_object_keys(v_rows -> 0) k)) then
      raise exception 'archive_corrupt: the rows of % do not all have the same columns', v_table.name;
    end if;

    -- Every row says which company it is of, and it is the one that arrives.
    if v_table.name = 'public.companies' then
      if jsonb_array_length(v_rows) <> 1 or (v_rows -> 0 ->> 'id') is distinct from v_company::text then
        raise exception 'foreign_row: an archive holds one company, the one its manifest names';
      end if;
    elsif exists (select 1 from pg_attribute a
                   where a.attrelid = v_class and a.attname = 'company_id' and not a.attisdropped) then
      if exists (select 1 from jsonb_array_elements(v_rows) e
                  where e ->> 'company_id' is distinct from v_company::text) then
        raise exception 'foreign_row: % holds a row of another company than the one the archive names', v_table.name;
      end if;
    end if;

    -- A reference to a table that loads later, or to its own table, waits for
    -- the second pass. Derived from the foreign keys, so a new one needs no
    -- line here; it has to be nullable, and a test says so before a user does.
    select coalesce(array_agg(distinct a.attname), '{}') into v_deferred
      from pg_constraint c
      join unnest(c.conkey) as k(attnum) on true
      join pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.attnum
      join pg_class rc on rc.oid = c.confrelid
      join pg_namespace rn on rn.oid = rc.relnamespace
      join company_archive_tables() r
        on r.table_schema = rn.nspname and r.table_name = rc.relname and r.disposition = 'exported'
     where c.contype = 'f' and c.conrelid = v_class
       and r.load_order >= v_table.load_order
       and a.attname <> 'company_id';

    if exists (select 1 from pg_attribute a
                where a.attrelid = v_class and a.attname = any (v_deferred) and a.attnotnull) then
      raise exception 'cannot_order: % holds a required reference to a table that loads after it', v_table.name;
    end if;

    -- What is written: every column of the table the archive names, but the
    -- generated ones, which compute themselves, and an identity, which is
    -- local to an installation and is drawn again.
    select array_agg(a.attname order by a.attnum) into v_columns
      from pg_attribute a
     where a.attrelid = v_class and a.attnum > 0 and not a.attisdropped
       and a.attgenerated = '' and a.attidentity = ''
       and (v_rows -> 0) ? a.attname;

    select string_agg(case when c = any (v_deferred) then format('null as %I', c) else format('r.%I', c) end, ', ')
      into v_select
      from unnest(v_columns) as c;

    -- The guards of a table are written for a person booking one thing at a
    -- time, in order, today. They are switched off on the tables being filled
    -- and nowhere else, inside this transaction, under a lock that makes every
    -- other writer of the table wait — and only where there is one to switch
    -- off, so `audit_log`, whose only trigger refuses updates and deletes,
    -- is never touched.
    if exists (select 1 from pg_trigger g
                where g.tgrelid = v_class and not g.tgisinternal
                  and ((g.tgtype & 4) <> 0 or ((g.tgtype & 16) <> 0 and cardinality(v_deferred) > 0))) then
      -- A trigger an operator had set otherwise — off, or firing on a replica
      -- — is put back the way it was.
      v_were_off := v_were_off || coalesce((
        select jsonb_agg(jsonb_build_object(
                 'class', v_class::text, 'name', g.tgname,
                 'verb', case g.tgenabled when 'D' then 'disable trigger'
                                          when 'R' then 'enable replica trigger'
                                          else 'enable always trigger' end))
          from pg_trigger g
         where g.tgrelid = v_class and not g.tgisinternal and g.tgenabled <> 'O'), '[]'::jsonb);
      execute format('alter table %s disable trigger user', v_class);
      v_silenced := v_silenced || v_class;
    end if;

    -- In the order of the archive, so that an identity drawn again — the ids
    -- of the trail — follows the order the rows were written in.
    execute format('insert into %s (%s) select %s from jsonb_array_elements($1) with ordinality as e(v, n)
                      cross join lateral jsonb_populate_record(null::%s, e.v) as r order by e.n',
                   v_class, (select string_agg(format('%I', c), ', ') from unnest(v_columns) c),
                   v_select, v_class)
      using v_rows;

    if cardinality(v_deferred) > 0 then
      v_second := v_second || jsonb_build_object('table', v_table.name, 'class', v_class::text,
                                                 'columns', to_jsonb(v_deferred));
    end if;
  end loop;

  -- Second pass: the references that pointed forward.
  for v_pass in select jsonb_array_elements(v_second) loop
    select array_agg(c) into v_deferred
      from jsonb_array_elements_text(v_pass -> 'columns') c
     where (v_tables -> (v_pass ->> 'table') -> 0) ? c;
    continue when v_deferred is null;
    execute format(
      'update %s t set %s from jsonb_populate_recordset(null::%s, $1) r where %s and (%s)',
      v_pass ->> 'class',
      (select string_agg(format('%I = r.%I', c, c), ', ') from unnest(v_deferred) c),
      v_pass ->> 'class',
      -- By the primary key, read from the catalogue rather than assumed to be `id`.
      (select string_agg(format('t.%I = r.%I', a.attname, a.attname), ' and ')
         from pg_index i
         join pg_attribute a on a.attrelid = i.indrelid and a.attnum = any (i.indkey)
        where i.indrelid = (v_pass ->> 'class')::regclass and i.indisprimary),
      (select string_agg(format('r.%I is not null', c), ' or ') from unnest(v_deferred) c))
      using v_tables -> (v_pass ->> 'table');
  end loop;

  foreach v_class in array v_silenced loop
    execute format('alter table %s enable trigger user', v_class);
  end loop;
  for v_pass in select jsonb_array_elements(v_were_off) loop
    execute format('alter table %s %s %I', v_pass ->> 'class', v_pass ->> 'verb', v_pass ->> 'name');
  end loop;

  -- What the triggers would have guaranteed, asked of the result.

  -- 1. Everything that arrived is of this company: a row that hung itself on
  --    a parent of another company is missing from this count.
  for v_table in
    select t.table_schema, t.table_name, t.table_schema || '.' || t.table_name as name
      from company_archive_tables() t where t.disposition = 'exported'
  loop
    execute format('select count(*) from %I.%I t where %s', v_table.table_schema, v_table.table_name,
                   company_archive_predicate(v_table.table_schema, v_table.table_name, 't'))
       into v_count using v_company;
    if v_count <> jsonb_array_length(coalesce(v_tables -> v_table.name, '[]'::jsonb)) then
      raise exception 'foreign_row: % holds % rows of this company after the import and the archive carried %',
        v_table.name, v_count, jsonb_array_length(coalesce(v_tables -> v_table.name, '[]'::jsonb));
    end if;
  end loop;

  -- 2. No reference leaves the company. Most foreign keys of the schema carry
  --    `company_id` and refuse this themselves; the ones that do not are why
  --    this is asked of all of them.
  for v_fk in
    select c.conrelid::regclass as child, c.confrelid::regclass as parent,
           cn.nspname as child_schema, ck.relname as child_table,
           pn.nspname as parent_schema, pk.relname as parent_table,
           ca.attname as child_column, pa.attname as parent_column
      from pg_constraint c
      join pg_class ck on ck.oid = c.conrelid
      join pg_namespace cn on cn.oid = ck.relnamespace
      join pg_class pk on pk.oid = c.confrelid
      join pg_namespace pn on pn.oid = pk.relnamespace
      join pg_attribute ca on ca.attrelid = c.conrelid and ca.attnum = c.conkey[1]
      join pg_attribute pa on pa.attrelid = c.confrelid and pa.attnum = c.confkey[1]
      join company_archive_tables() ct
        on ct.table_schema = cn.nspname and ct.table_name = ck.relname and ct.disposition = 'exported'
      join company_archive_tables() pt
        on pt.table_schema = pn.nspname and pt.table_name = pk.relname and pt.disposition = 'exported'
     where c.contype = 'f' and cardinality(c.conkey) = 1
  loop
    execute format(
      'select count(*) from %s t join %s p on p.%I = t.%I where %s and not (%s)',
      v_fk.child, v_fk.parent, v_fk.parent_column, v_fk.child_column,
      company_archive_predicate(v_fk.child_schema, v_fk.child_table, 't'),
      company_archive_predicate(v_fk.parent_schema, v_fk.parent_table, 'p'))
      into v_count using v_company;
    if v_count > 0 then
      raise exception 'foreign_row: %.% points at a row of another company in % (% rows)',
        v_fk.child, v_fk.child_column, v_fk.parent, v_count;
    end if;
  end loop;

  -- 3. The ledger: an entry agrees with its lines, and a posted one balances.
  select e.number into v_found
    from entries e
    left join lateral (select coalesce(sum(l.debit), 0) as debit, coalesce(sum(l.credit), 0) as credit
                         from entry_lines l where l.entry_id = e.id) s on true
   where e.company_id = v_company
     and (e.total_debit <> s.debit or e.total_credit <> s.credit
          or (e.state = 'posted' and s.debit <> s.credit))
   limit 1;
  if found then
    raise exception 'unbalanced_entry: entry % does not balance, or does not agree with its lines', coalesce(v_found, '(no number)');
  end if;

  --    And every line counts for a return on the day the rule gives it, which
  --    is what the trigger would have written.
  select coalesce(e.number, '(no number)') || ', line ' || l.sequence into v_found
    from entry_lines l
    join entries e on e.id = l.entry_id
   where l.company_id = v_company
     and l.declared_on is distinct from declared_on_of(l.tax_point_date, e.entry_date)
   limit 1;
  if found then
    raise exception 'declared_on_mismatch: entry % carries a declared_on that is not its tax point, nor the date of its entry where it has none', v_found;
  end if;

  -- 4. The matching: what a line says is matched is what its matchings add up to.
  select l.id::text into v_found
    from entry_lines l
   where l.company_id = v_company
     and l.matched_amount <> coalesce((select sum(r.amount) from reconciliations r
                                        where r.debit_line_id = l.id or r.credit_line_id = l.id), 0)
   limit 1;
  if found then
    raise exception 'matching_mismatch: line % says it is matched for another amount than its matchings add up to', v_found;
  end if;

  -- 5. The numbered books: no counter is behind a number already used, or the
  --    next entry would take a number that exists.
  select e.number into v_found
    from entries e
    join journals j on j.id = e.journal_id
    cross join lateral numbering_rules(v_company) n
   where e.company_id = v_company and e.number is not null
     and number_counter(n.number_format, e.number) is not null
     and number_counter(n.number_format, e.number) > coalesce((
           select s.last_number from journal_sequences s
            where s.journal_id = j.id
              and s.year = case when n.number_format ~ '\{(YYYY|YY)\}'
                                then extract(year from e.entry_date)::smallint
                                else 0::smallint end), 0)
   limit 1;
  if found then
    raise exception 'counter_behind: entry % carries a number its journal has not counted up to; the next entry would collide', v_found;
  end if;

  --    The letters of the matching, the same way.
  select l.matching_number into v_found
    from entry_lines l
   where l.company_id = v_company and l.matching_number ~ '[0-9]+$'
     and substring(l.matching_number from '[0-9]+$')::bigint
         > coalesce((select s.last_number from matching_sequences s where s.company_id = v_company), 0)
   limit 1;
  if found then
    raise exception 'counter_behind: the matching letter % is ahead of the counter of the company; the next matching would reuse a letter', v_found;
  end if;

  -- 6. The financial years do not overlap: every date belongs to one year or
  --    to none, which is what a lock and a closing are read against.
  select x.name into v_found
    from fiscal_years x
    join fiscal_years y on y.company_id = x.company_id and y.id <> x.id
     and daterange(x.start_date, x.end_date, '[]') && daterange(y.start_date, y.end_date, '[]')
   where x.company_id = v_company
   limit 1;
  if found then
    raise exception 'overlapping_years: the financial year % overlaps another one of the same company', v_found;
  end if;

  -- The first member. The people of the other installation did not travel.
  if v_owner is not null then
    insert into company_members (company_id, user_id, role)
    values (v_company, v_owner, 'owner')
    on conflict (company_id, user_id) do nothing;
  end if;

  -- Where this installation's own testimony starts: everything on the trail
  -- of this company before this row is what the archive said.
  perform audit_record(v_company, 'companies', v_company, v_manifest #>> '{company,name}',
                       'insert', 'company_imported', null,
                       jsonb_build_object(
                         'origin_instance', v_manifest -> 'origin_instance',
                         'exported_at', v_manifest -> 'exported_at',
                         'exported_by', v_manifest -> 'exported_by',
                         'socle_version', v_manifest -> 'socle_version',
                         'rows', v_total));

  return jsonb_build_object(
    'company_id', v_company,
    'name', v_manifest #>> '{company,name}',
    'rows', v_total,
    'owner', v_owner,
    'tables', (select jsonb_object_agg(m ->> 'name', (m ->> 'rows')::bigint)
                 from jsonb_array_elements(v_manifest -> 'tables') m),
    'files_to_carry', jsonb_array_length(coalesce(v_manifest #> '{files,list}', '[]'::jsonb)));
end;
$$;

comment on function import_company(jsonb, uuid) is
  'Takes one company archive into this installation, whole or not at all. Checks the manifest against the values of the rows — `values_sha256`, which a reader reproduces after parsing the archive — and against their bytes for an archive written before 0.9.0. A table a module has renamed since is read under its name of today. entry_lines.declared_on is derived for an archive written before it existed, and checked against declared_on_of() for one that carries it.';

revoke execute on function import_company(jsonb, uuid) from public, anon;
grant execute on function import_company(jsonb, uuid) to authenticated, service_role;

-- Rule 6 of supabase/migrations/README.md: a function created here comes out
-- closed to PUBLIC; the grants above, by name, are what opens it.
revoke execute on all functions in schema public from public;
